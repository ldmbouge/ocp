
/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <objcp/CPBitConstraint.h>
#import <CPUKernel/CPEngine.h>
#import <CPUKernel/CPLEngine.h>
#import <CPUKernel/CPUKernel.h>
#import <objcp/CPBitMacros.h>
#import <objcp/CPBitVarI.h>

typedef struct _CPBitAssignment {
   CPBitVarI* var;
   ORUInt   index;
   ORBool   value;
} CPBitAssignment;

typedef struct _CPBitAntecedents {
   CPBitAssignment**    antecedents;
   ORUInt            numAntecedents;
} CPBitAntecedents;


#define ISTRUE(up, low) ((up) & (low))
#define ISFALSE(up, low) ((~up) & (~low))
#define ISSET(up, low) (~((up)^(low)))
#define ISFREE(up,low) ((up) & (~(low)))

#define UIMIN(a,b) ((a < b) ? a : b)
#define UIMAX(a,b) ((a > b) ? a : b)

NSString* bitvar2NSString(unsigned int* low, unsigned int* up, int bitLength)
{
   NSMutableString* string = [[[NSMutableString alloc] init] autorelease];
   ORUInt wordLength = (bitLength/BITSPERWORD) + (((bitLength%BITSPERWORD) == 0) ? 0 : 1);
   
   
   int remainingbits = (bitLength%32 == 0) ? 32 : bitLength%32;
   unsigned int boundLow = (~ up[wordLength-1]) & (~low[wordLength-1]);
   unsigned int boundUp = up[wordLength-1] & low[wordLength-1];
   unsigned int err = ~up[wordLength-1] & low[wordLength-1];
   unsigned int mask = CP_DESC_MASK;
   
   mask >>= 32 - remainingbits;
   
   for (int j=0; j<remainingbits; j++){
      if ((mask & boundLow) !=0)
         [string appendString: @"0"];
      else if ((mask & boundUp) !=0)
         [string appendString: @"1"];
      else if ((mask & err) != 0)
         [string appendString: @"X"];
      else
         [string appendString: @"?"];
      mask >>= 1;
   }
   
   if(wordLength > 1){
      for(int i=wordLength-2; i>=0;i--){
         boundLow = (~ up[i]) & (~low[i]);
         boundUp = up[i] & low[i];
         err = ~up[i] & low[i];
         mask = CP_DESC_MASK;
         
         for (int j=0; j<32; j++){
            if ((mask & boundLow) != 0)
               [string appendString: @"0"];
            else if ((mask & boundUp) != 0)
               [string appendString: @"1"];
            else if ((mask & err) != 0)
               [string appendString: @"X"];
            else
               [string appendString: @"?"];
            mask >>= 1;
         }
      }
   }
   return string;

}

__attribute__((noinline))
static CPBitAssignment** enqueue(CPBitAssignment** queue, ORInt* front, ORInt* back, ORUInt* cap, CPBitAssignment* element)
{
   ORBool inQueue = false;
   CPBitAssignment** newQueue = queue;
   
   if(*front != -1){
      for (int k=*front; k<=*back; k++) {
         if ((element->var == queue[k%(*cap)]->var) &&
             (element->index == queue[k%(*cap)]->index) &&
             (element->value == queue[k%(*cap)]->value)) {
            inQueue = true;
            break;
         }
      }
   }
   if (!inQueue) {//add antecedent to queue
      //expand queue if full
      if ((((*back)-(*front))%(*cap))+1 >= *cap) {
         newQueue = malloc(sizeof(CPBitAssignment*)*(*cap)*2);
         for(int k=0;k<(*cap);k++)
            newQueue[k] = queue[(k+*front)%(*cap)];
         free(queue);
         *front=0;
         *back=*cap-1;
         *cap <<= 1;
      }
      
      (*back)++;
      if(*front==-1)
         *front=*back;
      newQueue[(*back)%(*cap)] = element;
   }
   else{
      free(element);
   }
   return newQueue;
}

__attribute__((noinline))
static CPBitAssignment* dequeue(CPBitAssignment** queue, ORInt* front, ORInt* back, ORUInt* cap)
{
   CPBitAssignment* temp = queue[(*front)%(*cap)];

   if(*front==*back)
      *front=*back=-1;
   else
      (*front)++;
   
   return temp;
}

__attribute__((noinline))
static ORBool member(CPBitAssignment** stack, ORUInt* size, CPBitAssignment* element)
{
   assert(element->var != nil);
   for(int i=0;i<(*size);i++)
   {
      assert(stack[i]->var != nil);
      if ((element->var == stack[i]->var) &&
          (element->index == stack[i]->index) &&
          (element->value == stack[i]->value)) {
         
         return true;
      }
   }
   return false;
}

__attribute__((noinline))
static CPBitAssignment** push(CPBitAssignment** stack, ORUInt* size, ORUInt* cap, CPBitAssignment* element)
{
   assert(element->var != nil);
   
   if(member(stack,size,element))
      return stack;
   
   CPBitAssignment** newStack = stack;
   if (*size >= *cap) {
      newStack = malloc(sizeof(CPBitAssignment*)*(*cap)*2);
      for (int j = 0; j<(*size); j++) {
         newStack[j] = stack[j];
      }
      free (stack);
      (*cap) <<= 1;
   }
   newStack[*size] = element;
   (*size)++;
   return newStack;
}


__attribute__((noinline))
void findAntecedents(ORUInt level, CPBitAssignment* conflict, id<CPBVConstraint> constraint, CPBitAntecedents* antecedents,
                CPBitAssignment*** conflictVars, ORUInt* numConflictVars, ORUInt* capConflictVars,
                CPBitAssignment*** visited, ORUInt* vsize, ORUInt* vcap)
{
   CPBitAssignment** queue;
   
   id<CPBVConstraint> c;
   
   ORUInt qcap = antecedents->numAntecedents > 8 ? antecedents->numAntecedents : 8;

   ORInt qfront = -1;
   ORInt qback = -1;
   
   queue = malloc(sizeof(CPBitAssignment*)*qcap);
   
   CPBitAssignment* temp;
   ORInt setLevel;
   
   for (int i=0; i<antecedents->numAntecedents; i++) {
      temp = antecedents->antecedents[i];
      if(member(*visited,vsize,temp))
      {
         free(temp);
         continue;
      }
      setLevel =[temp->var getLevelBitWasSet:temp->index];
      *visited = push(*visited, vsize, vcap, temp);
      if((setLevel==level)  || [temp->var isFree:temp->index])
      {         //bit was set on this level, add to the queue
         queue = enqueue(queue, &qfront, &qback, &qcap, temp);
      }
      else if (setLevel > 4)
      {
         //bit was set at a previous level during search, add it to the nogood
         *conflictVars = push(*conflictVars, numConflictVars, capConflictVars, temp);
      }
   }
   
   free(antecedents->antecedents);
   free(antecedents);
   
   ORBool more;
   

//   if(qfront==-1)
//      more=false;
//   else
//      more=true;
   
   more = qfront != qback;
//   more=true;
   while (more){
      
      if (qfront==-1){
         break;
      }
      //get antecedents of first assignment in queue
      temp = dequeue(queue, &qfront, &qback, &qcap);
      
      if(![temp->var isFree:temp->index])
      {
         c = [(CPBitVarI*)temp->var getImplicationForBit:temp->index];
         //but bit might not be set yet if it was in the constraint that generated the conflict!
         if(c==nil){
            //bit was set by choice
            if ([temp->var getLevelBitWasSet:temp->index] != -1) {
               *conflictVars = push(*conflictVars, numConflictVars, capConflictVars, temp);
               continue;
            }
            else
               c =  constraint;  // 3-17-17 GAJ
         }
         antecedents  = [c getAntecedentsFor:temp];
      }
      else{
         antecedents = [constraint getAntecedents:temp];
         c = constraint;
      }
      
      if((antecedents == NULL) || (antecedents->numAntecedents == 0)) {
         if (antecedents){
            free(antecedents->antecedents);
            free(antecedents);
         }
         //2 lines uncommented 3/5/17
         if (((ORInt)[temp->var getLevelBitWasSet:temp->index] > 4) || [temp->var isFree:temp->index])
            *conflictVars = push(*conflictVars, numConflictVars, capConflictVars, temp);
         continue;
      }
      
      //Process all of the antecedents at this level until there is only one
      for (int i=0; i<antecedents->numAntecedents; i++) {
         temp = antecedents->antecedents[i];
         if(member(*visited,vsize, temp))
         {
            free(temp);
            continue;
         }
         setLevel =[temp->var getLevelBitWasSet:temp->index];
         *visited = push(*visited, vsize, vcap, temp);
         if((setLevel==level) || [temp->var isFree:temp->index])
         {
            //bit was set on this level, add to the queue
            queue = enqueue(queue, &qfront, &qback, &qcap, temp);
         }
         else if (setLevel > 4)
         {
            //bit was set at a previous level, add it to the nogood
            *conflictVars = push(*conflictVars, numConflictVars, capConflictVars, temp);
         }
      }
      
      more = qfront != qback;
      
      free(antecedents->antecedents);
      free(antecedents);
   }

   while(qfront != -1){
      temp = dequeue(queue, &qfront, &qback, &qcap);
      *conflictVars = push(*conflictVars, numConflictVars, capConflictVars, temp);
   }
   free(queue);
}

__attribute__((noinline))
void analyzeUIP(id<CPLEngine> engine, CPBitAssignment* conflict, id<CPBVConstraint> constraint)
{
   
   CPBitAssignment** conflictVars = malloc(sizeof(CPBitAssignment*)*32);
   CPBitAssignment** visited = malloc(sizeof(CPBitAssignment*)*128);
   
   //Get antecedents in the constraint that detected the conflict
   //These will not have been written to the constraint store
   id<CPBVConstraint> c = [(CPBitVarI*)conflict->var getImplicationForBit:conflict->index];
   
   ORUInt capConflictVars = 32;
   ORUInt numConflictVars = 0;
   ORUInt vcap = 128;
   ORUInt vsize = 0;
   
   ORUInt level = [engine getLevel];
   
   CPBitAntecedents* antecedents = NULL;
   CPBitAntecedents* moreAntecedents = NULL;
   if (c == nil) //failure was at choice
      conflictVars = push(conflictVars, &numConflictVars, &capConflictVars, conflict);
   else{
      CPBitAssignment assignmentBeforeConflictDetected;
      assignmentBeforeConflictDetected.var = conflict->var;
      assignmentBeforeConflictDetected.index = conflict->index;
      assignmentBeforeConflictDetected.value = !conflict->value;
      antecedents = [c getAntecedentsFor:&assignmentBeforeConflictDetected];
   }
   
   moreAntecedents = [constraint getAntecedents:conflict];

   ORUInt numAntecedents = 0;
   
   if ((c!=nil) && antecedents != NULL)
      numAntecedents = antecedents->numAntecedents;

   if (moreAntecedents != NULL)
      numAntecedents += moreAntecedents->numAntecedents;
   
   CPBitAntecedents* reasonSide = malloc(sizeof(CPBitAntecedents));
   
   reasonSide->antecedents = malloc(sizeof(CPBitAssignment*)*numAntecedents);
   
   ORUInt idx = 0;

   if((c!=nil) && antecedents != NULL)
      for(int i=0;i<antecedents->numAntecedents;i++)
         reasonSide->antecedents[idx++] = antecedents->antecedents[i];
   
   if (moreAntecedents != NULL)
      for(int i = 0; i<moreAntecedents->numAntecedents;i++)
         reasonSide->antecedents[idx++] = moreAntecedents->antecedents[i];
   
   reasonSide->numAntecedents = idx;
   
   if(antecedents != NULL){
      if(antecedents->antecedents != NULL)
         free (antecedents->antecedents);
      free (antecedents);
   }
   if(moreAntecedents != NULL){
      if (moreAntecedents->antecedents != NULL)
         free (moreAntecedents->antecedents);
      free (moreAntecedents);
   }
   
   
   if ((reasonSide->numAntecedents != 0) && (reasonSide->antecedents != NULL))
      findAntecedents(level, conflict, constraint, reasonSide, &conflictVars, &numConflictVars, &capConflictVars, &visited, &vsize, &vcap);
   else
      NSLog(@"No antecedents to trace");
   
   
   if (numConflictVars > 0) {
      //      NSLog(@"Adding constraint to constraint store\n");
      CPBitAntecedents* final = malloc(sizeof(CPBitAntecedents));
      CPBitAssignment** finalVars = malloc(sizeof(CPBitAssignment*)*(numConflictVars));
      ORUInt backjumpLevel = 0;
      for (int i=0; i<numConflictVars; i++) {
         CPBitAssignment* a = malloc(sizeof(CPBitAssignment));
         a->var = conflictVars[i]->var;
         a->index = conflictVars[i]->index;
         if(![conflictVars[i]->var isFree:conflictVars[i]->index])
            a->value = [conflictVars[i]->var getBit:conflictVars[i]->index];
         else
            a->value = conflictVars[i]->value;
         finalVars[i] = a;
         if (((ORInt)[finalVars[i]->var getLevelBitWasSet:finalVars[i]->index] > 4) && ((ORInt)[finalVars[i]->var getLevelBitWasSet:finalVars[i]->index] < level))
            backjumpLevel = MAX(backjumpLevel,(ORInt)[finalVars[i]->var getLevelBitWasSet:finalVars[i]->index]);
      }
      final->antecedents = finalVars;
      final->numAntecedents = numConflictVars;
      c = [CPFactory bitConflict:final];
      //      NSLog(@"Backjump level: %d",backjumpLevel);
      
      [engine addConstraint:c withJumpLevel:backjumpLevel];
//      NSLog(@"New Constraint: %@\n\n\n\n",c);
//      NSLog(@"\n\n\n\n");
   }   else{
      NSLog(@"No choices found in tracing back antecedents");
   }
   
   free(conflictVars);
   for(int i=0;i<vsize;i++)
      free(visited[i]);
   free(visited);

}

__attribute__((noinline))
ORBool checkDomainConsistency(CPBitVarI* var, unsigned int* low, unsigned int* up, ORUInt len, id<CPBVConstraint> constraint)
{
   ORUInt upXORlow;
   //ORUInt mask,index,bitlength = [var bitLength];
   ORBool isConflict = false;
   
   unsigned int* conflicts = alloca(sizeof(unsigned int)*len);

//   NSLog(@"-------------------------------------------------------------------------------------------------");
//   NSLog(@"%@",constraint);
//   NSLog(@"%@",bitvar2NSString(low, up, bitlength));
   
   ORUInt bitLength = [var bitLength];
   up[len] &= CP_UMASK >> (bitLength%BITSPERWORD);
   low[len] &= CP_UMASK >> (bitLength%BITSPERWORD);

   for (int i=0; i<len; i++) {
      upXORlow = up[i] ^ low[i];
      conflicts[i] = (upXORlow&(~up[i]))&(upXORlow & low[i]);
      if (conflicts[i]) {
         isConflict = true;
         if ([[var engine] conformsToProtocol:@protocol(CPLEngine)]){
            //analyze all conflicts in this "word" of the bit vector
//            mask = 0x1;
//            for(int j=0;j<BITSPERWORD;j++){
//               index =i*BITSPERWORD+j;
//               if (index >= bitlength)
//                  break;
//               if (mask & conflicts[i]) {
//                  if ([[var engine] conformsToProtocol:@protocol(CPLEngine)]) {
//                     CPBitAssignment* a = malloc(sizeof(CPBitAssignment));
//                     a->var = var;
//                     a->index = i*BITSPERWORD+j;
//                     if(![var isFree:a->index])
//                        a->value = ![var getBit:a->index];
//                     else
//                        a->value = 0;
////                  NSLog(@"Analyzing conflict in constraint %@ for variable %lx[%d]",constraint,a->var,a->index);
//                        analyzeUIP((id<CPLEngine>)[var engine], a, constraint);
//                  }
            ORInt index = BITSPERWORD - __builtin_clz(conflicts[i]) - 1;
            CPBitAssignment* a = malloc(sizeof(CPBitAssignment));
            a->var = var;
            a->index = i*BITSPERWORD+index;
            if(![var isFree:a->index])
               a->value = ![var getBit:a->index];
            else
               a->value = 0;
//                  NSLog(@"Analyzing conflict in constraint %@ for variable %lx[%d]",constraint,a->var,a->index);
               analyzeUIP((id<CPLEngine>)[var engine], a, constraint);
               failNow();
//               mask <<=1;
//            }
         }
         failNow();
      }
   }
   if(isConflict){
//      NSLog(@"%@", constraint);
      failNow();
   }
   return isConflict;
}

ORUInt numSetBits(TRUInt* low, TRUInt* up, int wordLength)
{
   ORUInt setBits = 0;
   for(int i=0; i< wordLength;i++){
      unsigned int boundLow = ~low[i]._val & ~ up[i]._val;
      unsigned int boundUp = up[i]._val & low[i]._val;
      setBits += __builtin_popcount(boundLow || boundUp);
   }
   return setBits;
}

ORUInt numSetBitsORUInt(ORUInt* low, ORUInt* up, int wordLength)
{
   ORUInt setBits = 0;
   for(int i=0; i< wordLength;i++){
      unsigned int boundLow = ~low[i] & ~ up[i];
      unsigned int boundUp = up[i] & low[i];
      setBits += __builtin_popcount(boundLow || boundUp);
   }
   return setBits;
}

@implementation CPFactory (BitConstraint)
//Bit Vector Constraints
+(id<CPBVConstraint>) bitEqualAt:(CPBitVarI*)x at:(ORInt)k to:(ORInt)c
{
   id<CPBVConstraint> o = [[CPBitEqualAt alloc] init:x at:k to:c];
   [[x engine] trackMutable:o];
   return o;
}
+(id<CPBVConstraint>) bitEqualc:(CPBitVarI*)x to:(ORInt)c
{
   id<CPBVConstraint> o = [[CPBitEqualc alloc] initCPBitEqualc:x and:c];
   [[x engine] trackMutable:o];
   return o;
}

+(id<CPBVConstraint>) bitEqual:(CPBitVarI*)x to:(CPBitVarI*)y
{
   id<CPBVConstraint> o = [[CPBitEqual alloc] initCPBitEqual:x and:y];
   [[x engine] trackMutable:o];
   return o;
}

+(id<CPBVConstraint>) bitAND:(CPBitVarI*)x band:(CPBitVarI*)y equals:(CPBitVarI*)z
{
   id<CPBVConstraint> o = [[CPBitAND alloc] initCPBitAND:x band:y equals:z];
   [[x engine] trackMutable:o];
   return o;
}

+(id<CPBVConstraint>) bitOR:(CPBitVarI*)x bor:(CPBitVarI*) y equals:(CPBitVarI*)z
{
   id<CPBVConstraint> o = [[CPBitOR alloc] initCPBitOR:x bor:y equals:z];
   [[x engine] trackMutable:o];
   return o;
}
+(id<CPBVConstraint>) bitXOR:(CPBitVarI*)x bxor:(CPBitVarI*)y equals:(CPBitVarI*) z
{
   id<CPBVConstraint> o = [[CPBitXOR alloc] initCPBitXOR:x bxor:y equals:z];
   [[x engine] trackMutable:o];
   return o;
   
}
+(id<CPBVConstraint>) bitNOT:(CPBitVarI*)x equals:(CPBitVarI*) y
{
   id<CPBVConstraint> o = [[CPBitNOT alloc] initCPBitNOT:x equals:y];
   [[x engine] trackMutable:o];
   return o;
   
}

+(id<CPBVConstraint>) bitShiftL:(CPBitVarI*)x by:(int) p equals:(CPBitVarI*) y
{
   id<CPBVConstraint> o = [[CPBitShiftL alloc] initCPBitShiftL:x shiftLBy:p equals:y];
   [[x engine] trackMutable:o];
   return o;
}

+(id<CPBVConstraint>) bitShiftLBV:(CPBitVarI*)x by:(CPBitVarI*) p equals:(CPBitVarI*) y
{
   id<CPBVConstraint> o = [[CPBitShiftLBV alloc] initCPBitShiftLBV:x shiftLBy:p equals:y];
   [[x engine] trackMutable:o];
   return o;
}

+(id<CPBVConstraint>) bitShiftR:(CPBitVarI*)x by:(int) p equals:(CPBitVarI*) y
{
   id<CPBVConstraint> o = [[CPBitShiftR alloc] initCPBitShiftR:x shiftRBy:p equals:y];
   [[x engine] trackMutable:o];
   return o;
}
+(id<CPBVConstraint>) bitShiftRBV:(CPBitVarI*)x by:(CPBitVarI*) p equals:(CPBitVarI*) y
{
   id<CPBVConstraint> o = [[CPBitShiftRBV alloc] initCPBitShiftRBV:x shiftRBy:p equals:y];
   [[x engine] trackMutable:o];
   return o;
}

+(id<CPBVConstraint>) bitShiftRA:(CPBitVarI*)x by:(int) p equals:(CPBitVarI*) y
{
   id<CPBVConstraint> o = [[CPBitShiftRA alloc] initCPBitShiftRA:x shiftRBy:p equals:y];
   [[x engine] trackMutable:o];
   return o;
}
+(id<CPBVConstraint>) bitShiftRABV:(CPBitVarI*)x by:(CPBitVarI*)p equals:(CPBitVarI*) y
{
   id<CPBVConstraint> o = [[CPBitShiftRABV alloc] initCPBitShiftRABV:x shiftRBy:p equals:y];
   [[x engine] trackMutable:o];
   return o;
}

+(id<CPBVConstraint>) bitRotateL:(CPBitVarI*)x by:(int) p equals:(CPBitVarI*) y
{
   id<CPBVConstraint> o = [[CPBitRotateL alloc] initCPBitRotateL:x rotateLBy:p equals:y];
   [[x engine] trackMutable:o];
   return o;
   
}

+(id<CPBVConstraint>) bitNegative:(id<CPBitVar>)x equals:(id<CPBitVar>) y
{
   id<CPBVConstraint> o = [[CPBitNegative alloc] initCPBitNegative:(CPBitVarI*)x
                                                          equals:(CPBitVarI*)y];
   [[x engine] trackMutable:o];
   return o;
}

+(id<CPBVConstraint>) bitADD:(id<CPBitVar>)x plus:(id<CPBitVar>) y withCarryIn:(id<CPBitVar>) cin equals:(id<CPBitVar>) z withCarryOut:(id<CPBitVar>) cout
{
//   id<CPBVConstraint> o = [[CPBitADD alloc] initCPBitAdd:(CPBitVarI*)x
   id<CPBVConstraint> o = [[CPBitSum alloc] initCPBitSum:(CPBitVarI*)x
                                                    plus:(CPBitVarI*)y
                                                  equals:(CPBitVarI*)z
                                             withCarryIn:(CPBitVarI*)cin
                                             andCarryOut:(CPBitVarI*)cout];
   [[x engine] trackMutable:o];
   return o;
}

+(id<CPBVConstraint>) bitSubtract:(id<CPBitVar>)x minus:(id<CPBitVar>) y equals:(id<CPBitVar>) z
{
   id<CPBVConstraint> o = [[CPBitSubtract alloc] initCPBitSubtract:(CPBitVarI*)x
                                                           minus:(CPBitVarI*)y
                                                          equals:(CPBitVarI*)z];
   [[x engine] trackMutable:o];
   return o;
}

+(id<CPBVConstraint>) bitMultiply:(id<CPBitVar>)x times:(id<CPBitVar>) y equals:(id<CPBitVar>) z
{
//   id<CPBVConstraint> o = [[CPBitMultiply alloc] initCPBitMultiply:(CPBitVarI*)x
   id<CPBVConstraint> o = [[CPBitMultiplyComposed alloc] initCPBitMultiplyComposed:(CPBitVarI*)x
                                                           times:(CPBitVarI*)y
                                                          equals:(CPBitVarI*)z];
   [[x engine] trackMutable:o];
   return o;
}
+(id<CPBVConstraint>) bitMultiplyComposed:(id<CPBitVar>)x times:(id<CPBitVar>) y equals:(id<CPBitVar>) z
{
   assert(NO);
   return nil;
}

+(id<CPBVConstraint>) bitDivide:(id<CPBitVar>)x dividedby:(id<CPBitVar>) y equals:(id<CPBitVar>) q rem:(id<CPBitVar>)r
{
   id<CPBVConstraint> o = [[CPBitDivide alloc] initCPBitDivide:(CPBitVarI*)x
                                                           dividedby:(CPBitVarI*)y
                                                          equals:(CPBitVarI*)q
                                                            rem:(CPBitVarI*)r];
   [[x engine] trackMutable:o];
   return o;
}
+(id<CPBVConstraint>) bitIF:(id<CPBitVar>)w equalsOneIf:(id<CPBitVar>)x equals:(id<CPBitVar>)y andZeroIfXEquals:(id<CPBitVar>) z
{
   id<CPBVConstraint> o = [[CPBitIF alloc] initCPBitIF:(CPBitVarI*)w
                                         equalsOneIf:(CPBitVarI*)x
                                              equals:(CPBitVarI*)y
                                    andZeroIfXEquals:(CPBitVarI*)z];
   [[x engine] trackMutable:o];
   return o;
}
+(id<CPBVConstraint>) bitCount:(id<CPBitVar>)x count:(id<CPIntVar>)p
{
   id<CPBVConstraint> o = [[CPBitCount alloc] initCPBitCount:(CPBitVarI*)x count:(CPIntVarI*)p];
   [[x engine] trackMutable:o];
   return o;
}
+(id<CPBVConstraint>) bitChannel:(id<CPBitVar>)x channel:(id<CPIntVar>)y
{
   id<CPBVConstraint> o = [[CPBitChannel alloc] init:(CPBitVarI*)x channel:(CPIntVarI*)y];
   [[x engine] trackMutable:o];
   return o;
}
+(id<CPBVConstraint>) bitZeroExtend:(id<CPBitVar>)x extendTo:(id<CPBitVar>)y
{
   id<CPBVConstraint> o = [[CPBitZeroExtend alloc] initCPBitZeroExtend:(CPBitVarI*)x extendTo:(CPBitVarI*)y];
   [[x engine] trackMutable:o];
   return o;
}
+(id<CPBVConstraint>) bitSignExtend:(id<CPBitVar>)x extendTo:(id<CPBitVar>)y
{
   id<CPBVConstraint> o = [[CPBitSignExtend alloc] initCPBitSignExtend:(CPBitVarI*)x extendTo:(CPBitVarI*)y];
   [[x engine] trackMutable:o];
   return o;
}
+(id<CPBVConstraint>) bitConcat:(id<CPBitVar>)x concat:(id<CPBitVar>)y eq:(id<CPBitVar>)z
{
   id<CPBVConstraint> o = [[CPBitConcat alloc] initCPBitConcat:(CPBitVarI*)x concat:(CPBitVarI*)y eq:(CPBitVarI*)z];
   [[x engine] trackMutable:o];
   return o;
}
+(id<CPBVConstraint>) bitExtract:(id<CPBitVar>)x from:(ORUInt)lsb to:(ORUInt)msb eq:(id<CPBitVar>)y
{
   id<CPBVConstraint> o = [[CPBitExtract alloc] initCPBitExtract:(CPBitVarI*)x from:lsb to:msb eq:(CPBitVarI*)y];
   [[x engine] trackMutable:o];
   return o;
}
+(id<CPBVConstraint>) bitLogicalEqual:(id<CPBitVar>)x EQ:(id<CPBitVar>)y eval:(id<CPBitVar>) z
{
   id<CPBVConstraint> o = [[CPBitLogicalEqual alloc] initCPBitLogicalEqual:(CPBitVarI*)x EQ:(CPBitVarI*)y eval:(CPBitVarI*)z];
   [[x engine] trackMutable:o];
   return o;
   
}
+(id<CPBVConstraint>) bitLT:(id<CPBitVar>)x LT:(id<CPBitVar>)y eval:(id<CPBitVar>) z
{
   id<CPBVConstraint> o = [[CPBitLT alloc] initCPBitLT:(CPBitVarI*)x LT:(CPBitVarI*)y eval:(CPBitVarI*)z];
   [[x engine] trackMutable:o];
   return o;
   
}
+(id<CPBVConstraint>) bitLE:(id<CPBitVar>)x LE:(id<CPBitVar>)y eval:(id<CPBitVar>) z
{
   id<CPBVConstraint> o = [[CPBitLE alloc] initCPBitLE:(CPBitVarI*)x LE:(CPBitVarI*)y eval:(CPBitVarI*)z];
   [[x engine] trackMutable:o];
   return o;
}
+(id<CPBVConstraint>) bitSLE:(id<CPBitVar>)x SLE:(id<CPBitVar>)y eval:(id<CPBitVar>) z
{
   id<CPBVConstraint> o = [[CPBitSLE alloc] initCPBitSLE:(CPBitVarI*)x SLE:(CPBitVarI*)y eval:(CPBitVarI*)z];
   [[x engine] trackMutable:o];
   return o;
}
+(id<CPBVConstraint>) bitSLT:(id<CPBitVar>)x SLT:(id<CPBitVar>)y eval:(id<CPBitVar>) z
{
   id<CPBVConstraint> o = [[CPBitSLT alloc] initCPBitSLT:(CPBitVarI*)x SLT:(CPBitVarI*)y eval:(CPBitVarI*)z];
   [[x engine] trackMutable:o];
   return o;
}
+(id<CPBVConstraint>) bitITE:(id<CPBitVar>)i then:(id<CPBitVar>)t else:(id<CPBitVar>)e result:(id<CPBitVar>)r
{
   id<CPBVConstraint> o = [[CPBitITE alloc] initCPBitITE:(CPBitVarI*)i then:(CPBitVarI*)t else:(CPBitVarI*)e result:(CPBitVarI*)r];
   [[i engine] trackMutable:o];
   return o;
}
+(id<CPBVConstraint>) bitLogicalAnd:(id<CPBitVarArray>)x eval:(CPBitVarI*)r
{
   id<CPBVConstraint> o = [[CPBitLogicalAnd alloc] initCPBitLogicalAnd:x eval:r];
   [[x[0] engine] trackMutable:o];
   return o;
}
+(id<CPBVConstraint>) bitLogicalOr:(id<CPBitVarArray>)x eval:(CPBitVarI*)r
{
   id<CPBVConstraint> o = [[CPBitLogicalOr alloc] initCPBitLogicalOr:x eval:r];
   [[x[0] engine] trackMutable:o];
   return o;
}
+(id<CPBVConstraint>) bitConflict:(CPBitAntecedents*)a
{
   id<CPBVConstraint> o = [[CPBitConflict  alloc] initCPBitConflict:a];

   [[a->antecedents[0]->var engine] trackMutable:o];
   return o;
}
+(id<CPBVConstraint>) bitOrb:(CPBitVarI*)x bor:(CPBitVarI*) y eval:(CPBitVarI*)r
{
   id<CPBVConstraint> o = [[CPBitORb alloc] initCPBitORb:x bor:y eval:r];
   [[x engine] trackMutable:o];
   return o;
}
+(id<CPBVConstraint>) bitNotb:(CPBitVarI*)x eval:(CPBitVarI*)r
{
   id<CPBVConstraint> o = [[CPBitNotb alloc] initCPBitNotb:x eval:r];
   [[x engine] trackMutable:o];
   return o;
   
   
}
+(id<CPBVConstraint>) bitEqualb:(CPBitVarI*)x equal:(CPBitVarI*) y eval:(CPBitVarI*)r
{
   id<CPBVConstraint> o = [[CPBitEqualb alloc] initCPBitEqualb:x equals:y eval:r];
   [[x engine] trackMutable:o];
   return o;
}

+(id<CPBVConstraint>) bitDistinct:(CPBitVarI*)x distinctFrom:(CPBitVarI*)y eval:(CPBitVarI*)z
{
   id<CPBVConstraint> o = [[CPBitDistinct alloc] initCPBitDistinct:x distinctFrom:y eval:z];
   [[x engine] trackMutable:o];
   return o;
}
@end

@implementation CPBitCoreConstraint
-(id)initCPBitCoreConstraint:(id<CPEngine>)engine
{
   self = [super initCPCoreConstraint: engine];
   return self;
}
-(CPBitAntecedents*) getAntecedents:(CPBitAssignment*)assignment
{
   return NULL;
}
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*)assignment
{
   return NULL;
}
@end

@implementation CPBitEqualAt
-(id)init:(CPBitVarI*)x at:(ORInt)bit to:(ORInt)v
{
   self = [super initCPBitCoreConstraint:[x engine]];
   _x = x;
   _at = bit;
   _c = v;
   return self;
}
-(NSString*) description
{
   NSMutableString* string = [NSMutableString stringWithString:[super description]];
   [string appendString:@" with "];
   [string appendString:[NSString stringWithFormat:@"%@ ",_x]];
   [string appendString:[NSString stringWithFormat:@"at %d to %d\n",_at,_c]];
   return string;
}
-(NSSet*) allVars
{
   return [[[NSSet alloc] initWithObjects:_x,nil] autorelease];
}
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment
{
   return ([self getAntecedentsFor:assignment withState:_state]);
}
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment withState:(ORUInt**)state
{
   return NULL;
}
-(CPBitAntecedents*) getAntecedents:(CPBitAssignment*) assignment
{
   return NULL;
}
-(void) post
{
   [_x bind:_at to:_c];
}
@end

@implementation CPBitEqualc
-(id) initCPBitEqualc: (CPBitVarI*) x and: (ORInt) c
{
   self = [super initCPBitCoreConstraint: [x engine]];
   _x = x;
   _c = c;
   return self;
}
-(void) dealloc
{
   [super dealloc];
}
-(NSString*) description
{
   NSMutableString* string = [NSMutableString stringWithString:[super description]];
   [string appendString:@" with "];
   [string appendString:[NSString stringWithFormat:@"%@ ",_x]];
   [string appendString:[NSString stringWithFormat:@"and %d\n",_c]];
   return string;
}
-(NSSet*) allVars
{
   return [[[NSSet alloc] initWithObjects:_x,nil] autorelease];
}
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment
{
   return ([self getAntecedentsFor:assignment withState:_state]);
}
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment withState:(ORUInt**)state
{
   return NULL;
}
-(CPBitAntecedents*) getAntecedents:(CPBitAssignment*) assignment
{
   return NULL;
}
-(void) post
{
#ifdef BIT_DEBUG
   NSLog(@"Bit Equalc Constraint propagated.");
#endif
   unsigned int wordLength = [_x getWordLength];
   assert(wordLength == 1);
   TRUInt* xLow;
   TRUInt* xUp;
   [_x getUp:&xUp andLow:&xLow];
   
   unsigned int* up = alloca(sizeof(unsigned int)*wordLength);
   unsigned int* low = alloca(sizeof(unsigned int)*wordLength);
   
   for(int i=0;i<wordLength;i++){
      up[i] = xUp[i]._val & _c;
      low[i] = xLow[i]._val & _c;
   }
//   _state[0] = up;
//   _state[1] = low;
//   _state[2] = up;
//   _state[3] = low;
   ORBool xFail = checkDomainConsistency(_x, low, up, wordLength, self);
   if (xFail)
      failNow();
   
   [_x setUp:up andLow:low for:self];
 }
@end

@implementation CPBitEqual

-(id) initCPBitEqual:(CPBitVarI*) x and:(CPBitVarI*) y
{
   self = [super initCPBitCoreConstraint: [x engine]];
   _x = x;
   _y = y;
   _state = malloc(sizeof(ORUInt*)*4);
   return self;
}

- (void) dealloc
{
   [super dealloc];
   free(_state);
}
-(NSString*) description
{
   NSMutableString* string = [NSMutableString stringWithString:[super description]];
   [string appendString:@" with "];
   [string appendString:[NSString stringWithFormat:@"%@ ",_x]];
   [string appendString:[NSString stringWithFormat:@"and %@\n",_y]];
   
   return string;
}
-(NSSet*) allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y, nil] autorelease];
}
-(CPBitAntecedents*) getAntecedents:(CPBitAssignment*)assignment{
   return ([self getAntecedentsFor:assignment withState:_state]);
}

-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment withState:(ORUInt**)state
{
  //NSLog(@"Implication for 0x%lx[%u] = %@  traced back through %@", (unsigned long)assignment->var, assignment->index, (CPBitVarI*)assignment->var, self);
   
   CPBitAntecedents* ants = malloc(sizeof(CPBitAntecedents));
   CPBitAssignment** vars;
   
   vars  = malloc(sizeof(CPBitAssignment*));
   ants->antecedents = vars;
   ants->numAntecedents = 0;

   ORInt index = assignment->index;
   
   if (assignment->var == _x) {
      if (![_y isFree:index] || ~ISFREE(state[2][index/BITSPERWORD], state[3][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD))) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _y;
         vars[ants->numAntecedents]->index = index;
         if (![_y isFree:index])
            vars[ants->numAntecedents]->value = [_y getBit:index];
         else
            vars[ants->numAntecedents]->value = !((ISTRUE(state[2][index/BITSPERWORD], state[3][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD))) == 0);
         ants->numAntecedents++;
      }
   }
   else if (assignment->var == _y){
      if (![_x isFree:index] || ~ISFREE(state[0][index/BITSPERWORD], state[1][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD))) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _x;
         vars[ants->numAntecedents]->index = index;
         if (![_x isFree:index])
            vars[ants->numAntecedents]->value = [_x getBit:index];
         else
            vars[ants->numAntecedents]->value = !((ISTRUE(state[0][index/BITSPERWORD], state[1][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD))) == 0);
         ants->numAntecedents++;
      }
   }
   return ants;
}

-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment
{
  //NSLog(@"Implication for 0x%lx[%u] = %@  traced back through %@", (unsigned long)assignment->var, assignment->index, (CPBitVarI*)assignment->var, self);
   CPBitAntecedents* ants = malloc(sizeof(CPBitAntecedents));
   CPBitAssignment** vars;

   vars  = malloc(sizeof(CPBitAssignment*));
   ants->numAntecedents = 0;

   ORUInt index = assignment->index;
   ants->antecedents = vars;

   if (assignment->var == _x) {
      if (![_y isFree:index]) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _y;
         vars[ants->numAntecedents]->index = index;
         vars[ants->numAntecedents]->value = [_y getBit:index];
         ants->numAntecedents++;
      }
   }
   else if (assignment->var == _y){
      if (![_x isFree:index]) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _x;
         vars[ants->numAntecedents]->index = index;
         vars[ants->numAntecedents]->value = [_x getBit:index];
         ants->numAntecedents++;
      }
   }
   return ants;
}

-(void) post
{
   [self propagate];
   if (![_x bound])
      [_x whenChangePropagate: self];
   if (![_y bound])
      [_y whenChangePropagate: self];
   [self propagate];
}

-(void) propagate
{
#ifdef BIT_DEBUG
   NSLog(@"Bit Equal Constraint propagated.");
#endif
   
   unsigned int wordLength = [_x getWordLength];
   
   TRUInt* xLow;
   TRUInt* xUp;
   TRUInt* yLow;
   TRUInt* yUp;
   
   [_x getUp:&xUp andLow:&xLow];
   [_y getUp:&yUp andLow:&yLow];
   
   unsigned int* up = alloca(sizeof(unsigned int)*wordLength);
   unsigned int* low = alloca(sizeof(unsigned int)*wordLength);

   
   for(int i=0;i<wordLength;i++){
      up[i] = xUp[i]._val & yUp[i]._val;
      low[i] = xLow[i]._val | yLow[i]._val;
   }
   _state[0] = up;
   _state[1] = low;
   _state[2] = up;
   _state[3] = low;
   
   ORBool xFail = checkDomainConsistency(_x, low, up, wordLength, self);
   ORBool yFail = checkDomainConsistency(_y, low, up, wordLength, self);
   if (xFail || yFail){
      failNow();
   }
   
   [_x setUp:up andLow:low for:self];
   [_y setUp:up andLow:low for:self];
   
}
@end

@implementation CPBitNOT

-(id) initCPBitNOT: (CPBitVarI*) x equals:(CPBitVarI*) y
{
   self = [super initCPBitCoreConstraint:[x engine]];
   _x = x;
   _y = y;
   _state = malloc(sizeof(ORUInt*)*4);
   return self;
}
-(NSString*) description
{
   NSMutableString* string = [NSMutableString stringWithString:[super description]];
   [string appendString:@" with "];
   [string appendString:[NSString stringWithFormat:@"%@ ",_x]];
   [string appendString:[NSString stringWithFormat:@"and %@\n",_y]];
   
   return string;
}

- (void) dealloc
{
   [super dealloc];
   free(_state);
}
-(NSSet*) allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y, nil] autorelease];
}
-(CPBitAntecedents*) getAntecedents:(CPBitAssignment*)assignment{
   return ([self getAntecedentsFor:assignment withState:_state]);
}
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment withState:(ORUInt**)state
{
  //NSLog(@"Implication for 0x%lx[%u] = %@  traced back through %@", (unsigned long)assignment->var, assignment->index, (CPBitVarI*)assignment->var, self);
   
   CPBitAntecedents* ants = malloc(sizeof(CPBitAntecedents));
   CPBitAssignment** vars;
   
   vars  = malloc(sizeof(CPBitAssignment*));
   ants->antecedents = vars;
   ants->numAntecedents = 0;
   
   ORInt index = assignment->index;
   
   if (assignment->var == _x) {
      if (![_y isFree:index] || (~ISFREE(state[2][index/BITSPERWORD], state[3][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD)))) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _y;
         vars[ants->numAntecedents]->index = index;
         if(![_y isFree:index])
            vars[ants->numAntecedents]->value = [_y getBit:index];
         else
            vars[ants->numAntecedents]->value = !((ISTRUE(state[2][index/BITSPERWORD], state[3][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD))) == 0);
         ants->numAntecedents++;
      }
   }
   else if (assignment->var == _y){
      if (![_x isFree:index] || (~ISFREE(state[0][index/BITSPERWORD], state[1][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD)))) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _x;
         vars[ants->numAntecedents]->index = index;
         if(![_x isFree:index])
            vars[ants->numAntecedents]->value = [_x getBit:index];
         else
            vars[ants->numAntecedents]->value = !((ISTRUE(state[0][index/BITSPERWORD], state[1][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD))) == 0);
         ants->numAntecedents++;
      }
   }
   return ants;
}
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment
{
  //NSLog(@"Implication for 0x%lx[%u] = %@  traced back through %@", (unsigned long)assignment->var, assignment->index, (CPBitVarI*)assignment->var, self);
   CPBitAntecedents* ants = malloc(sizeof(CPBitAntecedents));
   CPBitAssignment** vars;
   vars  = malloc(sizeof(CPBitAssignment*));
   ants->numAntecedents = 0;

   ORUInt index = assignment->index;
   ants->antecedents = vars;

   if (assignment->var == _x) {
      if (![_y isFree:index]) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _y;
         vars[ants->numAntecedents]->index = index;
         vars[ants->numAntecedents]->value = [_y getBit:index];
         ants->numAntecedents++;
      }
   }
   else if (assignment->var == _y){
      if (![_x isFree:index]) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _x;
         vars[ants->numAntecedents]->index = index;
         vars[ants->numAntecedents]->value = [_x getBit:index];
         ants->numAntecedents++;
      }
   }
   return ants;
}

-(void) post
{
   [self propagate];
   if (![_x bound])
      [_x whenChangePropagate: self];
   if (![_y bound])
      [_y whenChangePropagate: self];
   
   [self propagate];
}

-(void) propagate
{
#ifdef BIT_DEBUG
   NSLog(@"**********************************");
   NSLog(@"Bit NOT Constraint propagated.");
#endif
   
   unsigned int wordLength = [_x getWordLength];
   
   TRUInt* xLow;
   TRUInt* xUp;
   TRUInt* yLow;
   TRUInt* yUp;
   
   [_x getUp:&xUp andLow:&xLow];
   [_y getUp:&yUp andLow:&yLow];
   
   
   unsigned int* newXUp = alloca(sizeof(unsigned int)*wordLength);
   unsigned int* newXLow = alloca(sizeof(unsigned int)*wordLength);
   unsigned int* newYUp = alloca(sizeof(unsigned int)*wordLength);
   unsigned int* newYLow = alloca(sizeof(unsigned int)*wordLength);

#ifdef BIT_DEBUG
   NSLog(@"     ~(X =%@)",_x);
   NSLog(@"  =    Y =%@",_y);
#endif
   
//   unsigned int bitMask = 0xFFFFFFFF >> (32 - wordLength%32);
//   uint32 bitMask = CP_UMASK >> (32 - ([_x bitLength] % 32));
   for(int i=0;i<wordLength;i++){
      //x_k=0 => y_k=1
      newYLow[i] = ~xUp[i]._val | yLow[i]._val;
      
      //x_k=1 => y_k=0
      newYUp[i] = ~xLow[i]._val & yUp[i]._val;
      
      //y_k=0 => x_k=1
      newXLow[i] = ~yUp[i]._val | xLow[i]._val;
      
      //y_k=1 => x_k=0
      newXUp[i] = ~yLow[i]._val & xUp[i]._val;
      
//             if(i==wordLength-1){
//                uint32 bitmask = CP_UMASK >> (32 - ([_x bitLength] % 32));
//                newXUp[i] &= bitmask;
//                newXLow[i] &= bitmask;
//                newYUp[i] &= bitmask;
//                newYLow[i] &= bitmask;
//             }
      
      if ((wordLength%32 !=0) && (i==(wordLength-1))) {
         ORUInt bitMask = CP_UMASK >> (32 - ([_x bitLength] % 32));
         newXUp[i] &= bitMask;
         newXLow[i] &= bitMask;
         newYUp[i] &= bitMask;
         newYLow[i] &= bitMask;
      }
   }


//   NSLog(@"BitNOT propagated");
//   NSLog(@"x = %@",_x);
//   NSLog(@"newX = %@",bitvar2NSString(newXLow, newXUp, [_x bitLength]));
//   NSLog(@"y = %@",_y);
//   NSLog(@"newY = %@\n\n",bitvar2NSString(newYLow, newYUp, [_y bitLength]));
   
   _state[0] = newXUp;
   _state[1] = newXLow;
   _state[2] = newYUp;
   _state[3] = newYLow;
   
   ORBool xFail = checkDomainConsistency(_x, newXLow, newXUp, wordLength, self);
   ORBool yFail = checkDomainConsistency(_y, newYLow, newYUp, wordLength, self);

   if(xFail || yFail)
      failNow();

   [_x setUp:newXUp andLow:newXLow for:self];
   [_y setUp:newYUp andLow:newYLow for:self];
   
#ifdef BIT_DEBUG
   NSLog(@"     ~(X =%@)",_x);
   NSLog(@"  =    Y =%@",_y);
   NSLog(@"**********************************");
#endif
}
@end

@implementation CPBitAND
-(id) initCPBitAND:(CPBitVarI*)x band:(CPBitVarI*)y equals:(CPBitVarI*)z{
   self = [super initCPBitCoreConstraint:[x engine]];
   _x = x;
   _y = y;
   _z = z;
   _state = malloc(sizeof(ORUInt*)*6);
   return self;
   
}
-(NSString*) description
{
   NSMutableString* string = [NSMutableString stringWithString:[super description]];
   [string appendString:@" with \n"];
   [string appendString:[NSString stringWithFormat:@"%@, \n",_x]];
   [string appendString:[NSString stringWithFormat:@"%@ and \n",_y]];
   [string appendString:[NSString stringWithFormat:@"%@\n",_z]];
   
   return string;
}
- (void) dealloc
{
   [super dealloc];
   free(_state);
}
-(NSSet*) allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y, _z, nil] autorelease];
}
-(CPBitAntecedents*) getAntecedents:(CPBitAssignment*)assignment{
   return ([self getAntecedentsFor:assignment withState:_state]);
}
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment withState:(ORUInt**)state
{
  //NSLog(@"Implication for 0x%lx[%u] = %@  traced back through %@", (unsigned long)assignment->var, assignment->index, (CPBitVarI*)assignment->var, self);
   
   CPBitAntecedents* ants = malloc(sizeof(CPBitAntecedents));
   CPBitAssignment** vars;
   vars  = malloc(sizeof(CPBitAssignment*)*2);
   ants->numAntecedents = 0;
   
   ORUInt index = assignment->index;
   ants->antecedents = vars;
   
   if (assignment->var == _x) {
      if ((![_y isFree:index] || (~ISFREE(state[2][index/BITSPERWORD], state[3][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD)))) &&
          !assignment->value){
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _y;
         vars[ants->numAntecedents]->index = index;
         if(![_y isFree:index])
            vars[ants->numAntecedents]->value = [_y getBit:index];
         else
            vars[ants->numAntecedents]->value = !((ISTRUE(state[2][index/BITSPERWORD], state[3][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD))) == 0);
         ants->numAntecedents++;
      }
      if (![_z isFree:index] || (~ISFREE(state[4][index/BITSPERWORD], state[5][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD)))) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _z;
         vars[ants->numAntecedents]->index = index;
         if(![_z isFree:index])
            vars[ants->numAntecedents]->value = [_z getBit:index];
         else
            vars[ants->numAntecedents]->value = !((ISTRUE(state[4][index/BITSPERWORD], state[5][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD))) == 0);
         ants->numAntecedents++;
      }
   }
   else if (assignment->var == _y){
      if ((![_x isFree:index] || (~ISFREE(state[0][index/BITSPERWORD], state[1][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD)))) &&
          !assignment->value){
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _x;
         vars[ants->numAntecedents]->index = index;
         if(![_x isFree:index])
            vars[ants->numAntecedents]->value = [_x getBit:index];
         else
            vars[ants->numAntecedents]->value = !((ISTRUE(state[0][index/BITSPERWORD], state[1][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD))) == 0);
         ants->numAntecedents++;
      }
      if (![_z isFree:index] || (~ISFREE(state[4][index/BITSPERWORD], state[5][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD)))) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _z;
         vars[ants->numAntecedents]->index = index;
         if(![_z isFree:index])
            vars[ants->numAntecedents]->value = [_z getBit:index];
         else
            vars[ants->numAntecedents]->value = !((ISTRUE(state[4][index/BITSPERWORD], state[5][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD))) == 0);
         ants->numAntecedents++;
      }
   }
   else if (assignment->var == _z){
      ORUInt xVal, yVal;
      ORBool xFree = [_x isFree:index];
      ORBool yFree = [_y isFree:index];

      if(!xFree)
         xVal = [_x getBit:index];
      else
         xVal = !((ISTRUE(state[0][index/BITSPERWORD], state[1][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD))) == 0);

      if(!yFree)
         yVal = [_y getBit:index];
      else
         yVal = !((ISTRUE(state[2][index/BITSPERWORD], state[3][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD))) == 0);

      if ((!xFree || (~ISFREE(state[0][index/BITSPERWORD], state[1][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD)))) && (assignment->value  == xVal)) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _x;
         vars[ants->numAntecedents]->index = index;
         vars[ants->numAntecedents]->value = xVal;
         ants->numAntecedents++;
      }
      if ((!yFree || (~ISFREE(state[2][index/BITSPERWORD], state[3][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD)))) && (assignment->value == yVal))  {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _y;
         vars[ants->numAntecedents]->index = index;
         vars[ants->numAntecedents]->value = yVal;
         ants->numAntecedents++;
      }

   }
//   if(ants->numAntecedents < 2)
//      NSLog(@"BitAND traced back giving %d antecedents",ants->numAntecedents);
//   
//      NSLog(@"                                                 3322222222221111111111");
//      NSLog(@"                                                 10987654321098765432109876543210");
//      NSLog(@"x = %@",_x);
//      NSLog(@"y = %@",_y);
//      NSLog(@"z = %@",_z);
//   NSLog(@"Assignment: %@[%d] = %d",assignment->var,assignment->index,assignment->value);
//   if(ants->numAntecedents > 0)
//      NSLog(@"antecedent[0]: %@[%d] = %d",ants->antecedents[0]->var,ants->antecedents[0]->index,ants->antecedents[0]->value);
//   if(ants->numAntecedents > 1)
//      NSLog(@"antecedent[1]: %@[%d] = %d\n\n\n",ants->antecedents[1]->var,ants->antecedents[1]->index,ants->antecedents[1]->value);
//   NSLog(@"\n\n\n");

   return ants;
}

-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment
{
  //NSLog(@"Implication for 0x%lx[%u] = %@  traced back through %@", (unsigned long)assignment->var, assignment->index, (CPBitVarI*)assignment->var, self);

   CPBitAntecedents* ants = malloc(sizeof(CPBitAntecedents));
   CPBitAssignment** vars;
   vars  = malloc(sizeof(CPBitAssignment*)*2);
   ants->numAntecedents = 0;

   ORUInt index = assignment->index;
   ants->antecedents = vars;

   if (assignment->var == _x) {
//      if (![_y isFree:index]){
      if (![_y isFree:index]  && !assignment->value) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _y;
         vars[ants->numAntecedents]->index = index;
         vars[ants->numAntecedents]->value = [_y getBit:index];
         ants->numAntecedents++;
      }
      if (![_z isFree:index]) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _z;
         vars[ants->numAntecedents]->index = index;
         vars[ants->numAntecedents]->value = [_z getBit:index];
         ants->numAntecedents++;
      }
   }
   else if (assignment->var == _y){
      //Include X only if y set to 0 at this index
      
      if (![_x isFree:index] && !assignment->value) {
//      if (![_x isFree:index]){
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _x;
         vars[ants->numAntecedents]->index = index;
         vars[ants->numAntecedents]->value = [_x getBit:index];
         ants->numAntecedents++;
      }
      if (![_z isFree:index]) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _z;
         vars[ants->numAntecedents]->index = index;
         vars[ants->numAntecedents]->value = [_z getBit:index];
         ants->numAntecedents++;
      }
   }
   else if (assignment->var == _z){
      ORBool xVal, yVal;
      ORBool xFree = [_x isFree:index];
      ORBool yFree = [_y isFree:index];
      
      if(!xFree)
         xVal = [_x getBit:index];
      
      if(!yFree)
         yVal = [_y getBit:index];

//      if (!xFree){
      if (!xFree && (assignment->value  == xVal)){
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _x;
         vars[ants->numAntecedents]->index = index;
         vars[ants->numAntecedents]->value = [_x getBit:index];
         ants->numAntecedents++;
      }
//      if (!yFree){
         if (!yFree && (assignment->value  == yVal)){
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _y;
         vars[ants->numAntecedents]->index = index;
         vars[ants->numAntecedents]->value = [_y getBit:index];
         ants->numAntecedents++;
      }
   }
//   if(ants->numAntecedents < 2)
//      NSLog(@"BitAND traced back giving %d antecedents",ants->numAntecedents);
   
   
//   NSLog(@"                                                3322222222221111111111");
//   NSLog(@"                                                10987654321098765432109876543210");
//   NSLog(@"x  %@",_x);
//   NSLog(@"y  %@",_y);
//   NSLog(@"z  %@",_z);
//   NSLog(@"Assignment: %@[%d] = %d",assignment->var,assignment->index,assignment->value);
//   if(ants->numAntecedents > 0)
//      NSLog(@"antecedent[0]: %@[%d] = %d",ants->antecedents[0]->var,ants->antecedents[0]->index,ants->antecedents[0]->value);
//   if(ants->numAntecedents > 1)
//      NSLog(@"antecedent[1]: %@[%d] = %d\n\n\n",ants->antecedents[1]->var,ants->antecedents[1]->index,ants->antecedents[1]->value);
//   NSLog(@"\n\n\n");
   
   return ants;
}
-(void) post
{
   [self propagate];
   if (![_x bound])
      [_x whenChangePropagate: self];
   if (![_y bound])
      [_y whenChangePropagate: self];
   if (![_z bound])
      [_z whenChangePropagate: self];
   
   [self propagate];
}
-(void) propagate
{
#ifdef BIT_DEBUG
   NSLog(@"**********************************");
   NSLog(@"Bit AND Constraint propagated.");
#endif
   
   unsigned int wordLength = [_x getWordLength];
   TRUInt* xLow;
   TRUInt* xUp;
   TRUInt* yLow;
   TRUInt* yUp;
   TRUInt* zLow;
   TRUInt* zUp;
   
   [_x getUp:&xUp andLow:&xLow];
   [_y getUp:&yUp andLow:&yLow];
   [_z getUp:&zUp andLow:&zLow];
   
   
   unsigned int* newXUp = alloca(sizeof(unsigned int)*wordLength);
   unsigned int* newXLow  = alloca(sizeof(unsigned int)*wordLength);
   unsigned int* newYUp = alloca(sizeof(unsigned int)*wordLength);
   unsigned int* newYLow  = alloca(sizeof(unsigned int)*wordLength);
   unsigned int* newZUp = alloca(sizeof(unsigned int)*wordLength);
   unsigned int* newZLow  = alloca(sizeof(unsigned int)*wordLength);

#ifdef BIT_DEBUG
   NSLog(@"       X =%@",_x);
   NSLog(@"  AND  Y =%@",_y);
   NSLog(@"   =   Z =%@",_z);
#endif
   
   for(int i=0;i<wordLength;i++){
      
      // x_k=1 & y_k=1 => z_k=1
      newZLow[i] = (xLow[i]._val & yLow[i]._val) | zLow[i]._val;
      
      //z_k=1 => x_k=1
      //z_k=1 => y_k=1
      newXLow[i] = xLow[i]._val | zLow[i]._val;
      newYLow[i] = yLow[i]._val | zLow[i]._val;
      
      //z_k=0 & y_k=1 =>x_k=0
      newXUp[i] = (~(~zUp[i]._val & yLow[i]._val)) & xUp[i]._val;
      
      //z_k=0 & x_k=1 =>y_k=0
      newYUp[i] = (~(~zUp[i]._val & xLow[i]._val)) & yUp[i]._val;
      
      //x_k=0 | y_k=0 =>z_k=0
      newZUp[i] = (xUp[i]._val & yUp[i]._val) & zUp[i]._val;
   
   }
   
//   NSLog(@"%@",bitvar2NSString(newXLow, newXUp, 32));
//   NSLog(@"%@",bitvar2NSString(newYLow, newYUp, 32));
//   NSLog(@"%@",bitvar2NSString(newZLow, newZUp, 32));

   _state[0] = newXUp;
   _state[1] = newXLow;
   _state[2] = newYUp;
   _state[3] = newYLow;
   _state[4] = newZUp;
   _state[5] = newZLow;
   
   ORBool xFail = checkDomainConsistency(_x, newXLow, newXUp, wordLength, self);
   
   ORBool yFail = checkDomainConsistency(_y, newYLow, newYUp, wordLength, self);

   ORBool zFail = checkDomainConsistency(_z, newZLow, newZUp, wordLength, self);

   if (xFail || yFail || zFail)
      failNow();
   
   [_x setUp:newXUp andLow:newXLow for:self];
   [_y setUp:newYUp andLow:newYLow for:self];
   [_z setUp:newZUp andLow:newZLow for:self];
   
#ifdef BIT_DEBUG
   NSLog(@"       X =%@",_x);
   NSLog(@"  AND  Y =%@",_y);
   NSLog(@"   =   Z =%@",_z);
   NSLog(@"**********************************");
#endif
}
@end

@implementation CPBitOR
-(id) initCPBitOR:(CPBitVarI*)x bor:(CPBitVarI*)y equals:(CPBitVarI*)z{
   self = [super initCPBitCoreConstraint:[x engine]];
   _x = x;
   _y = y;
   _z = z;
   _state = malloc(sizeof(ORUInt*)*6);
   return self;
   
}
-(NSString*) description
{
   NSMutableString* string = [NSMutableString stringWithString:[super description]];
   [string appendString:@" with "];
   [string appendString:[NSString stringWithFormat:@"%@, ",_x]];
   [string appendString:[NSString stringWithFormat:@"%@ and ",_y]];
   [string appendString:[NSString stringWithFormat:@"%@\n",_z]];
   
   return string;
}
- (void) dealloc
{
   [super dealloc];
   free(_state);
}
-(NSSet*) allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y, _z, nil] autorelease];
}
-(CPBitAntecedents*) getAntecedents:(CPBitAssignment*)assignment{
   return ([self getAntecedentsFor:assignment withState:_state]);
}
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*)assignment withState:(ORUInt**)state
{
   //NSLog(@"Implication for 0x%lx[%u] = %@  traced back through %@", (unsigned long)assignment->var, assignment->index, (CPBitVarI*)assignment->var, self);
   
   CPBitAntecedents* ants = malloc(sizeof(CPBitAntecedents));
   CPBitAssignment** vars;
   vars  = malloc(sizeof(CPBitAssignment*)*2);
   ants->numAntecedents = 0;
   
   ORUInt index = assignment->index;
   ants->antecedents = vars;
   
   if (assignment->var == _x) {
      if ((![_y isFree:index] || (~ISFREE(state[2][index/BITSPERWORD], state[3][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD)))) && ((ISTRUE(state[2][index/BITSPERWORD], state[3][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD))) == 0)) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _y;
         vars[ants->numAntecedents]->index = index;
         if(![_y isFree:index])
            vars[ants->numAntecedents]->value = [_y getBit:index];
         else
            vars[ants->numAntecedents]->value = !((ISTRUE(state[2][index/BITSPERWORD], state[3][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD))) == 0);
         ants->numAntecedents++;
      }
      if (![_z isFree:index] || (~ISFREE(state[4][index/BITSPERWORD], state[5][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD)))) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _z;
         vars[ants->numAntecedents]->index = index;
         if(![_z isFree:index])
            vars[ants->numAntecedents]->value = [_z getBit:index];
         else
            vars[ants->numAntecedents]->value = !((ISTRUE(state[4][index/BITSPERWORD], state[5][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD))) == 0);
         ants->numAntecedents++;
      }
   }
   else if (assignment->var == _y){
      if ((![_x isFree:index] || ~ISFREE(state[0][index/BITSPERWORD], state[1][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD))) && ((ISTRUE(state[0][index/BITSPERWORD], state[1][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD))) == 0)) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _x;
         vars[ants->numAntecedents]->index = index;
         if(![_x isFree:index])
            vars[ants->numAntecedents]->value = [_x getBit:index];
         else
            vars[ants->numAntecedents]->value = !((ISTRUE(state[0][index/BITSPERWORD], state[1][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD))) == 0);
         ants->numAntecedents++;
      }
      if (![_z isFree:index] || ~ISFREE(state[4][index/BITSPERWORD], state[5][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD))) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _z;
         vars[ants->numAntecedents]->index = index;
         if(![_z isFree:index])
            vars[ants->numAntecedents]->value = [_z getBit:index];
         else
            vars[ants->numAntecedents]->value = !((ISTRUE(state[4][index/BITSPERWORD], state[5][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD))) == 0);
         ants->numAntecedents++;
      }
   }
   else if (assignment->var == _z){
      ORUInt xVal, yVal;
      ORBool xFree = [_x isFree:index];
      ORBool yFree = [_y isFree:index];
      
      if(!xFree)
         xVal = [_x getBit:index];
      else
         xVal = !((ISTRUE(state[0][index/BITSPERWORD], state[1][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD))) == 0);
      
      if(!yFree)
         yVal = [_y getBit:index];
      else
         yVal = !((ISTRUE(state[2][index/BITSPERWORD], state[3][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD))) == 0);
      
      if ((!xFree || (~ISFREE(state[0][index/BITSPERWORD], state[1][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD)))) && (!assignment->value|| xVal) && (assignment->value == xVal))          {vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _x;
         vars[ants->numAntecedents]->index = index;
         if(![_x isFree:index])
            vars[ants->numAntecedents]->value = [_x getBit:index];
         else
            vars[ants->numAntecedents]->value = !((ISTRUE(state[0][index/BITSPERWORD], state[1][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD))) == 0);
         if((assignment->value && vars[ants->numAntecedents]->value) || assignment->value == 0)
            ants->numAntecedents++;
      }
      if ((!yFree || ~ISFREE(state[2][index/BITSPERWORD], state[3][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD)))  && (!assignment->value || yVal) && (assignment->value == yVal)){
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _y;
         vars[ants->numAntecedents]->index = index;
         if(![_y isFree:index])
            vars[ants->numAntecedents]->value = [_y getBit:index];
         else
            vars[ants->numAntecedents]->value = !((ISTRUE(state[2][index/BITSPERWORD], state[3][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD))) == 0);
         if((assignment->value && vars[ants->numAntecedents]->value) || assignment->value == 0)
            ants->numAntecedents++;
      }
   }
//   if(ants->numAntecedents < 2)
//      NSLog(@"BitOR traced back giving %d antecedents",ants->numAntecedents);
//   NSLog(@"                                                 3322222222221111111111");
//   NSLog(@"                                                 10987654321098765432109876543210");
//   NSLog(@"x = %@",_x);
//   NSLog(@"y = %@",_y);
//   NSLog(@"z = %@",_z);
//   NSLog(@"Assignment: %@[%d] = %d",assignment->var,assignment->index,assignment->value);
//   if(ants->numAntecedents > 0)
//      NSLog(@"antecedent[0]: %@[%d] = %d",ants->antecedents[0]->var,ants->antecedents[0]->index,ants->antecedents[0]->value);
//   if(ants->numAntecedents > 1)
//      NSLog(@"antecedent[1]: %@[%d] = %d\n\n\n",ants->antecedents[1]->var,ants->antecedents[1]->index,ants->antecedents[1]->value);
//   NSLog(@"\n\n\n");

   return ants;
}

-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment
{
  //NSLog(@"Implication for 0x%lx[%u] = %@  traced back through %@", (unsigned long)assignment->var, assignment->index, (CPBitVarI*)assignment->var, self);

   CPBitAntecedents* ants = malloc(sizeof(CPBitAntecedents));
   CPBitAssignment** vars;
   vars  = malloc(sizeof(CPBitAssignment*)*2);
   ants->numAntecedents = 0;

   ORUInt index = assignment->index;
   ants->antecedents = vars;
   
   if (assignment->var == _x) {
      if ((![_y isFree:index]) && ![_z isFree:index] && [_z getBit:index]) {
//      if (![_y isFree:index]) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _y;
         vars[ants->numAntecedents]->index = index;
         vars[ants->numAntecedents]->value = [_y getBit:index];
         ants->numAntecedents++;
      }
      if (![_z isFree:index]) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _z;
         vars[ants->numAntecedents]->index = index;
         vars[ants->numAntecedents]->value = [_z getBit:index];
         ants->numAntecedents++;
      }
   }
   else if (assignment->var == _y){
      if ((![_x isFree:index]) && ![_z isFree:index] && [_z getBit:index]){
//      if (![_x isFree:index]) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _x;
         vars[ants->numAntecedents]->index = index;
         vars[ants->numAntecedents]->value = [_x getBit:index];
         ants->numAntecedents++;
      }
      if (![_z isFree:index]) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _z;
         vars[ants->numAntecedents]->index = index;
         vars[ants->numAntecedents]->value = [_z getBit:index];
         ants->numAntecedents++;
      }
   }
   else if (assignment->var == _z){
      if ((![_x isFree:index]) && (assignment->value == [_x getBit:index])) {
//      if ((![_x isFree:index])){
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _x;
         vars[ants->numAntecedents]->index = index;
         vars[ants->numAntecedents]->value = [_x getBit:index];
//         if((assignment->value && vars[ants->numAntecedents]->value) || assignment->value == 0)
            ants->numAntecedents++;
      }
      if ((![_y isFree:index]) && (assignment->value  == [_y getBit:index])) {
//      if ((![_y isFree:index])){
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _y;
         vars[ants->numAntecedents]->index = index;
         vars[ants->numAntecedents]->value = [_y getBit:index];
//         if((assignment->value && vars[ants->numAntecedents]->value) || assignment->value == 0)
            ants->numAntecedents++;
      }
   }
//   if(ants->numAntecedents < 2)
//      NSLog(@"BitOR traced back giving %d antecedents",ants->numAntecedents);
   
//   NSLog(@"                                                 3322222222221111111111");
//   NSLog(@"                                                 10987654321098765432109876543210");
//   NSLog(@"x = %@",_x);
//   NSLog(@"y = %@",_y);
//   NSLog(@"z = %@",_z);
//   NSLog(@"Assignment: %@[%d] = %d",assignment->var,assignment->index,assignment->value);
//   if(ants->numAntecedents > 0)
//      NSLog(@"antecedent[0]: %@[%d] = %d",ants->antecedents[0]->var,ants->antecedents[0]->index,ants->antecedents[0]->value);
//   if(ants->numAntecedents > 1)
//      NSLog(@"antecedent[1]: %@[%d] = %d\n\n\n",ants->antecedents[1]->var,ants->antecedents[1]->index,ants->antecedents[1]->value);
//   NSLog(@"\n\n\n");

   return ants;
}
-(void) post
{
   [self propagate];
   if (![_x bound])
      [_x whenChangePropagate: self];
   if (![_y bound])
      [_y whenChangePropagate: self];
   if (![_z bound])
      [_z whenChangePropagate: self];
   [self propagate];
}
-(void) propagate
{
#ifdef BIT_DEBUG
   NSLog(@"**********************************");
   NSLog(@"Bit OR Constraint propagated.");
#endif
   unsigned int wordLength = [_x getWordLength];
   TRUInt* xLow;
   TRUInt* xUp;
   TRUInt* yLow;
   TRUInt* yUp;
   TRUInt* zLow;
   TRUInt* zUp;
   
   [_x getUp:&xUp andLow:&xLow];
   [_y getUp:&yUp andLow:&yLow];
   [_z getUp:&zUp andLow:&zLow];
   
   
   unsigned int* newXUp = alloca(sizeof(unsigned int)*wordLength);
   unsigned int* newXLow  = alloca(sizeof(unsigned int)*wordLength);
   unsigned int* newYUp = alloca(sizeof(unsigned int)*wordLength);
   unsigned int* newYLow  = alloca(sizeof(unsigned int)*wordLength);
   unsigned int* newZUp = alloca(sizeof(unsigned int)*wordLength);
   unsigned int* newZLow  = alloca(sizeof(unsigned int)*wordLength);
   
#ifdef BIT_DEBUG
   NSLog(@"      X =%@",_x);
   NSLog(@"  OR  Y =%@",_y);
   NSLog(@"   =  Z =%@",_z);
#endif
   for(int i=0;i<wordLength;i++){
      
      // x_k=1 | y_k=1 => z_k=1
      newZLow[i] = xLow[i]._val | yLow[i]._val | zLow[i]._val;
      
      //z_k=0 => x_k=0
      //z_k=0 => y_k=0
      newXUp[i] = zUp[i]._val & xUp[i]._val;
      newYUp[i] = zUp[i]._val & yUp[i]._val;
      
      //z_k=1 & y_k=0 =>x_k=1
      newXLow[i] =  (~yUp[i]._val & zLow[i]._val) | xLow[i]._val;
      
      //z_k=1 & x_k=0 =>y_k=1
      newYLow[i] =  (~xUp[i]._val & zLow[i]._val) | yLow[i]._val;
      
      //x_k=0 & y_k=0 =>z_k=0
      newZUp[i] = (xUp[i]._val | yUp[i]._val) & zUp[i]._val;
      
   }
   
   
   _state[0] = newXUp;
   _state[1] = newXLow;
   _state[2] = newYUp;
   _state[3] = newYLow;
   _state[4] = newZUp;
   _state[5] = newZLow;
   
   ORBool xFail = checkDomainConsistency(_x, newXLow, newXUp, wordLength, self);
   ORBool yFail = checkDomainConsistency(_y, newYLow, newYUp, wordLength, self);
   ORBool zFail = checkDomainConsistency(_z, newZLow, newZUp, wordLength, self);
   
   if (xFail || yFail || zFail)
      failNow();

   [_x setUp:newXUp andLow:newXLow for:self];
   [_y setUp:newYUp andLow:newYLow for:self];
   [_z setUp:newZUp andLow:newZLow for:self];
   
   
#ifdef BIT_DEBUG
   NSLog(@"      X =%@",_x);
   NSLog(@"  OR  Y =%@",_y);
   NSLog(@"   =  Z =%@",_z);
   NSLog(@"**********************************");
#endif
}
@end

@implementation CPBitXOR
-(id) initCPBitXOR:(CPBitVarI*)x bxor:(CPBitVarI*)y equals:(CPBitVarI*)z{
   self = [super initCPBitCoreConstraint:[x engine]];
   _x = x;
   _y = y;
   _z = z;
   _state = malloc(sizeof(ORUInt*)*6);
   return self;
   
}
-(NSString*) description
{
   NSMutableString* string = [NSMutableString stringWithString:[super description]];
   [string appendString:@" with "];
   [string appendString:[NSString stringWithFormat:@"%@, ",_x]];
   [string appendString:[NSString stringWithFormat:@"%@ and ",_y]];
   [string appendString:[NSString stringWithFormat:@"%@",_z]];
   
   return string;
}
- (void) dealloc
{
   [super dealloc];
   free(_state);
}
-(NSSet*) allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y, _z, nil] autorelease];
}
-(CPBitAntecedents*) getAntecedents:(CPBitAssignment*)assignment{
   return ([self getAntecedentsFor:assignment withState:_state]);
}
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment withState:(ORUInt**)state
{
  //NSLog(@"Implication for 0x%lx[%u] = %@  traced back through %@", (unsigned long)assignment->var, assignment->index, (CPBitVarI*)assignment->var, self);
   
   //   NSLog(@"Tracing back BitXOR constraint with 0x%lx, 0x%lx and 0x%lx",_x,_y,_z);
   CPBitAntecedents* ants = malloc(sizeof(CPBitAntecedents));
   CPBitAssignment** vars;
   vars  = malloc(sizeof(CPBitAssignment*)*2);
   ants->numAntecedents = 0;
   
   ORUInt index = assignment->index;
   ants->antecedents = vars;
   
   if (assignment->var == _x) {
      if (![_y isFree:index] || (~ISFREE(state[2][index/BITSPERWORD], state[3][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD)))) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _y;
         vars[ants->numAntecedents]->index = index;
         if(![_y isFree:index])
            vars[ants->numAntecedents]->value = [_y getBit:index];
         else
            vars[ants->numAntecedents]->value = !((ISTRUE(state[2][index/BITSPERWORD], state[3][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD))) == 0);
         ants->numAntecedents++;
      }
      if (![_z isFree:index] || (~ISFREE(state[4][index/BITSPERWORD], state[5][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD)))) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _z;
         vars[ants->numAntecedents]->index = index;
         if(![_z isFree:index])
            vars[ants->numAntecedents]->value = [_z getBit:index];
         else
            vars[ants->numAntecedents]->value = !((ISTRUE(state[4][index/BITSPERWORD], state[5][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD))) == 0);
         ants->numAntecedents++;
      }
   }
   else if (assignment->var == _y){
      if (![_x isFree:index] || (~ISFREE(state[0][index/BITSPERWORD], state[1][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD)))) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _x;
         vars[ants->numAntecedents]->index = index;
         if(![_x isFree:index])
            vars[ants->numAntecedents]->value = [_x getBit:index];
         else
            vars[ants->numAntecedents]->value = !((ISTRUE(state[0][index/BITSPERWORD], state[1][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD))) == 0);
         ants->numAntecedents++;
      }
      if (![_z isFree:index] || (~ISFREE(state[4][index/BITSPERWORD], state[5][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD)))) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _z;
         vars[ants->numAntecedents]->index = index;
         if(![_z isFree:index])
            vars[ants->numAntecedents]->value = [_z getBit:index];
         else
            vars[ants->numAntecedents]->value = !((ISTRUE(state[4][index/BITSPERWORD], state[5][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD))) == 0);
         ants->numAntecedents++;
      }
   }
   else if (assignment->var == _z){
      if (![_x isFree:index] || (~ISFREE(state[0][index/BITSPERWORD], state[1][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD)))) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _x;
         vars[ants->numAntecedents]->index = index;
         if(![_x isFree:index])
            vars[ants->numAntecedents]->value = [_x getBit:index];
         else
            vars[ants->numAntecedents]->value = !((ISTRUE(state[0][index/BITSPERWORD], state[1][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD))) == 0);
         ants->numAntecedents++;
      }
      if (![_y isFree:index] || (~ISFREE(state[2][index/BITSPERWORD], state[3][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD)))) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _y;
         vars[ants->numAntecedents]->index = index;
         if(![_y isFree:index])
            vars[ants->numAntecedents]->value = [_y getBit:index];
         else
            vars[ants->numAntecedents]->value = !((ISTRUE(state[2][index/BITSPERWORD], state[3][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD))) == 0);
         ants->numAntecedents++;
      }
   }
   if(ants->numAntecedents < 2)
      NSLog(@"BitXOR traced back giving %d antecedents",ants->numAntecedents);
//   NSLog(@"                                                 3322222222221111111111");
//   NSLog(@"                                                 10987654321098765432109876543210");
//   NSLog(@"x = %@",_x);
//   NSLog(@"y = %@",_y);
//   NSLog(@"z = %@",_z);
//   NSLog(@"Assignment: %@[%d] = %d",assignment->var,assignment->index,assignment->value);
//   if(ants->numAntecedents > 0)
//      NSLog(@"antecedent[0]: %@[%d] = %d",ants->antecedents[0]->var,ants->antecedents[0]->index,ants->antecedents[0]->value);
//   if(ants->numAntecedents > 1)
//      NSLog(@"antecedent[1]: %@[%d] = %d\n\n\n",ants->antecedents[1]->var,ants->antecedents[1]->index,ants->antecedents[1]->value);
//   NSLog(@"\n\n\n");
   return ants;
}

-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment
{
  //NSLog(@"Implication for 0x%lx[%u] = %@  traced back through %@", (unsigned long)assignment->var, assignment->index, (CPBitVarI*)assignment->var, self);

//   NSLog(@"Tracing back BitXOR constraint with 0x%lx, 0x%lx and 0x%lx",_x,_y,_z);
   CPBitAntecedents* ants = malloc(sizeof(CPBitAntecedents));
   CPBitAssignment** vars;
   vars  = malloc(sizeof(CPBitAssignment*)*2);
   ants->numAntecedents = 0;
   
   ORUInt index = assignment->index;
   ants->antecedents = vars;
   
   if (assignment->var == _x) {
      if (![_y isFree:index]) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _y;
         vars[ants->numAntecedents]->index = index;
         vars[ants->numAntecedents]->value = [_y getBit:index];
         ants->numAntecedents++;
      }
      if (![_z isFree:index]) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _z;
         vars[ants->numAntecedents]->index = index;
         vars[ants->numAntecedents]->value = [_z getBit:index];
         ants->numAntecedents++;
      }
   }
   else if (assignment->var == _y){
      if (![_x isFree:index]) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _x;
         vars[ants->numAntecedents]->index = index;
         vars[ants->numAntecedents]->value = [_x getBit:index];
         ants->numAntecedents++;
      }
      if (![_z isFree:index]) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _z;
         vars[ants->numAntecedents]->index = index;
         vars[ants->numAntecedents]->value = [_z getBit:index];
         ants->numAntecedents++;
      }
   }
   else if (assignment->var == _z){
      if (![_x isFree:index]) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _x;
         vars[ants->numAntecedents]->index = index;
         vars[ants->numAntecedents]->value = [_x getBit:index];
         ants->numAntecedents++;
      }
      if (![_y isFree:index]) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _y;
         vars[ants->numAntecedents]->index = index;
         vars[ants->numAntecedents]->value = [_y getBit:index];
         ants->numAntecedents++;
      }
   }
   if(ants->numAntecedents < 2)
      NSLog(@"BitXOR traced back giving %d antecedents",ants->numAntecedents);
//   NSLog(@"                                                  3322222222221111111111");
//   NSLog(@"                                                  10987654321098765432109876543210");
//   NSLog(@"x = %@",_x);
//   NSLog(@"y = %@",_y);
//   NSLog(@"z = %@",_z);
//   NSLog(@"Assignment: %@[%d] = %d",assignment->var,assignment->index,assignment->value);
//   if(ants->numAntecedents > 0)
//      NSLog(@"antecedent[0]: %@[%d] = %d",ants->antecedents[0]->var,ants->antecedents[0]->index,ants->antecedents[0]->value);
//   if(ants->numAntecedents > 1)
//      NSLog(@"antecedent[1]: %@[%d] = %d\n\n\n",ants->antecedents[1]->var,ants->antecedents[1]->index,ants->antecedents[1]->value);
//   NSLog(@"\n\n\n");
   return ants;
}

-(void) post
{
   [self propagate];
   if (![_x bound])
      [_x whenChangePropagate: self];
   if (![_y bound])
      [_y whenChangePropagate: self];
   if (![_z bound])
      [_z whenChangePropagate: self];
   
   [self propagate];
}
-(void) propagate
{
#ifdef BIT_DEBUG
   NSLog(@"**********************************");
   NSLog(@"Bit XOR Constraint propagated.");
#endif
   
   unsigned int wordLength = getVarWordLength(_x);
//   TRUInt* xLow;
//   TRUInt* xUp;
//   TRUInt* yLow;
//   TRUInt* yUp;
//   TRUInt* zLow;
//   TRUInt* zUp;
   ULRep xr = getULVarRep(_x);
   ULRep yr = getULVarRep(_y);
   ULRep zr = getULVarRep(_z);
   TRUInt *xLow = xr._low, *xUp = xr._up;
   TRUInt *yLow = yr._low, *yUp = yr._up;
   TRUInt *zLow = zr._low, *zUp = zr._up;
   
//   [_x getUp:&xUp andLow:&xLow];
//   [_y getUp:&yUp andLow:&yLow];
//   [_z getUp:&zUp andLow:&zLow];
   
   unsigned int* newXUp = alloca(sizeof(unsigned int)*wordLength);
   unsigned int* newXLow  = alloca(sizeof(unsigned int)*wordLength);
   unsigned int* newYUp = alloca(sizeof(unsigned int)*wordLength);
   unsigned int* newYLow  = alloca(sizeof(unsigned int)*wordLength);
   unsigned int* newZUp = alloca(sizeof(unsigned int)*wordLength);
   unsigned int* newZLow  = alloca(sizeof(unsigned int)*wordLength);
//   ORBool fail = false;
   
#ifdef BIT_DEBUG
   NSLog(@"      X =%@",_x);
   NSLog(@" XOR  Y =%@",_y);
   NSLog(@"   =  Z=%@\n\n",_z);
#endif
   
   for(int i=0;i<wordLength;i++){
      
      // x_k=0 & y_k=0 => z_k=0
      // x_k=1 & y_k=1 => z_k=0
      //        newZUp[i] = ~((~xUp[i]._val & ~yUp[i]._val) | (xLow[i]._val & yLow[i]._val) | ~zUp[i]._val);
      newZUp[i] = (xUp[i]._val | yUp[i]._val) & ~(xLow[i]._val & yLow[i]._val) & zUp[i]._val;
      
      //x_k=0 & y_k=1 => z_k=1
      //x_k=1 & y_k=0 => z_k=1
      newZLow[i] = (~xUp[i]._val & yLow[i]._val) | (xLow[i]._val & ~yUp[i]._val) | zLow[i]._val;
      
      //z_k=0 & y_k=0 => x_k=0
      //z_k=1 & y_k=1 => x_k=0
      newXUp[i] = (zUp[i]._val | yUp[i]._val) & ~(yLow[i]._val & zLow[i]._val) & xUp[i]._val;
      
      //z_k=0 & y_k=1 => x_k=1
      //z_k=1 & y_k=0 => x_k=1
      newXLow[i] = (~zUp[i]._val & yLow[i]._val) | (zLow[i]._val & ~yUp[i]._val) | xLow[i]._val;
      
      //z_k=0 & x_k=0 => y_k=0
      //z_k=1 & x_k=1 => y_k=0
      newYUp[i] = (zUp[i]._val | xUp[i]._val) & ~(xLow[i]._val & zLow[i]._val) & yUp[i]._val;
      
      //z_k=0 & x_k=1 => y_k=1
      //z_k=1 & x_k=0 => y_k=1
      newYLow[i] =  (~zUp[i]._val & xLow[i]._val) | (zLow[i]._val & ~xUp[i]._val) | yLow[i]._val;
      
   }

   _state[0] = newXUp;
   _state[1] = newXLow;
   _state[2] = newYUp;
   _state[3] = newYLow;
   _state[4] = newZUp;
   _state[5] = newZLow;
   
   ORBool xFail = checkDomainConsistency(_x, newXLow, newXUp, wordLength, self);
   ORBool yFail = checkDomainConsistency(_y, newYLow, newYUp, wordLength, self);
   ORBool zFail = checkDomainConsistency(_z, newZLow, newZUp, wordLength, self);
   if (xFail || yFail || zFail)
      failNow();

   [_x setUp:newXUp andLow:newXLow for:self];
   [_y setUp:newYUp andLow:newYLow for:self];
   [_z setUp:newZUp andLow:newZLow for:self];
   
#ifdef BIT_DEBUG
   NSLog(@"      X =%@",_x);
   NSLog(@" XOR  Y =%@",_y);
   NSLog(@"   =  Z=%@",_z);
   NSLog(@"**********************************");
#endif
}
@end

@implementation CPBitIF
// TODO: Update propagate to learn nogoods and work with backjumping controller
-(id) initCPBitIF: (CPBitVarI*) w equalsOneIf:(CPBitVarI*) x equals: (CPBitVarI*) y andZeroIfXEquals: (CPBitVarI*) z {
   self = [super initCPBitCoreConstraint:[x engine]];
   _w = w;
   _x = x;
   _y = y;
   _z = z;
   _state = malloc(sizeof(ORUInt*)*8);
   return self;
   
}
-(NSString*) description
{
   NSMutableString* string = [NSMutableString stringWithString:[super description]];
   [string appendString:@" with "];
   [string appendString:[NSString stringWithFormat:@"%@ ",_w]];
   [string appendString:[NSString stringWithFormat:@"and %@ ",_x]];
   [string appendString:[NSString stringWithFormat:@"and %@ ",_y]];
   [string appendString:[NSString stringWithFormat:@"and %@\n",_z]];
   
   return string;
}
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment
{
  //NSLog(@"Implication for 0x%lx[%u] = %@  traced back through %@", (unsigned long)assignment->var, assignment->index, (CPBitVarI*)assignment->var, self);
   return NULL;
}

- (CPBitAntecedents *)getAntecedents:(CPBitAssignment *)assignment
{
   // Todo
   return NULL;
}

- (void) dealloc
{
   [super dealloc];
   free(_state);
}
-(NSSet*) allVars
{
   return [[[NSSet alloc] initWithObjects:_w,_x,_y, _z, nil] autorelease];
}

- (void)close {
   // Todo
}


-(void) post
{
   [self propagate];
   if (![_x bound] || ![_y bound] || ![_z bound] || ![_w bound]) {
      //_w added by GAJ on 11/29/12
      [_w whenBitFixed: self at: HIGHEST_PRIO do: ^() { [self propagate];} ];
      [_x whenBitFixed: self at: HIGHEST_PRIO do: ^() { [self propagate];} ];
      [_y whenBitFixed: self at: HIGHEST_PRIO do: ^() { [self propagate];} ];
      [_z whenBitFixed: self at: HIGHEST_PRIO do: ^() { [self propagate];} ];
   }
   [self propagate];
}
-(void) propagate
{
   unsigned int wordLength = [_x getWordLength];
   
   TRUInt* wLow = [_w getLow];
   TRUInt* wUp = [_w getUp];
   TRUInt* xLow = [_x getLow];
   TRUInt* xUp = [_x getUp];
   TRUInt* yLow = [_y getLow];
   TRUInt* yUp = [_y getUp];
   TRUInt* zLow = [_z getLow];
   TRUInt* zUp = [_z getUp];
   
   unsigned int* newWUp = alloca(sizeof(unsigned int)*wordLength);
   unsigned int* newWLow = alloca(sizeof(unsigned int)*wordLength);
   unsigned int* newXUp = alloca(sizeof(unsigned int)*wordLength);
   unsigned int* newXLow  = alloca(sizeof(unsigned int)*wordLength);
   unsigned int* newYUp = alloca(sizeof(unsigned int)*wordLength);
   unsigned int* newYLow  = alloca(sizeof(unsigned int)*wordLength);
   unsigned int* newZUp = alloca(sizeof(unsigned int)*wordLength);
   unsigned int* newZLow  = alloca(sizeof(unsigned int)*wordLength);
   
   unsigned int fixed;
   unsigned int opposite;
   unsigned int trueInWY;
   unsigned int trueInWZ;
   unsigned int falseInWY;
   unsigned int falseInWZ;
   
   unsigned int upXORlow;
   
   bool    inconsistencyFound = false;
   
   for(int i=0;i<wordLength;i++){
      
      newWUp[i] = (~xLow[i]._val | yUp[i]._val) & (xUp[i]._val | zUp[i]._val) & (yUp[i]._val | zUp[i]._val) & wUp[i]._val;
      newWLow[i] = (~xLow[i]._val | yLow[i]._val) | (xUp[i]._val | zLow[i]._val) | (yLow[i]._val & zLow[i]._val) | wLow[i]._val;
      
      fixed = ~(yLow[i]._val ^ yUp[i]._val) & ~(zLow[i]._val & zUp[i]._val);
      opposite = fixed & (yLow[i]._val ^ zLow[i]._val);
      
      trueInWY = yLow[i]._val & opposite & wLow[i]._val;
      trueInWZ = zLow[i]._val & opposite & wLow[i]._val;
      falseInWY = ~yUp[i]._val & opposite & ~wUp[i]._val;
      falseInWZ = ~zUp[i]._val & opposite & ~wUp[i]._val;
      
      newXLow[i] =  xLow[i]._val | trueInWY | falseInWY;
      newXUp[i] = xUp[i]._val & ~trueInWZ & ~falseInWZ;
      
      newYLow[i] =  (~xLow[i]._val | wLow[i]._val) | yLow[i]._val;
      newYUp[i] = (~xLow[i]._val | wUp[i]._val) & yUp[i]._val;
      
      newZLow[i] = (xUp[i]._val | wLow[i]._val) | xLow[i]._val;
      newZUp[i] = (xUp[i]._val | wUp[i]._val) & zUp[i]._val;
      
      upXORlow = newWUp[i] ^ newWLow[i];
      inconsistencyFound |= (upXORlow&(~newWUp[i]))&(upXORlow & newWLow[i]);
      upXORlow = newXUp[i] ^ newXLow[i];
      inconsistencyFound |= (upXORlow&(~newXUp[i]))&(upXORlow & newXLow[i]);
      upXORlow = newYUp[i] ^ newYLow[i];
      inconsistencyFound |= (upXORlow&(~newYUp[i]))&(upXORlow & newYLow[i]);
      upXORlow = newZUp[i] ^ newZLow[i];
      inconsistencyFound |= (upXORlow&(~newZUp[i]))&(upXORlow & newZLow[i]);
      if (inconsistencyFound)
         failNow();
   }
   [_w setLow:newWLow];
   [_w setUp:newWUp];
   [_x setLow:newXLow];
   [_x setUp:newXUp];
   [_y setLow:newYLow];
   [_y setUp:newYUp];
   [_z setLow:newZLow];
   [_z setUp:newZUp];
   
}
- (void)visit:(ORVisitor *)visitor
{
   
}
@end

@implementation CPBitShiftL
-(id) initCPBitShiftL:(CPBitVarI*)x shiftLBy:(int)places equals:(CPBitVarI*)y{
   self = [super initCPBitCoreConstraint:[x engine]];
   _x = x;
   _y = y;
   _places = places;
   _state = malloc(sizeof(ORUInt*)*4);
   return self;
   
}
-(NSString*) description
{
   NSMutableString* string = [NSMutableString stringWithString:[super description]];
   [string appendString:@" with "];
   [string appendString:[NSString stringWithFormat:@"%@ ",_x]];
   [string appendString:[NSString stringWithFormat:@"and %@\n",_y]];
   
   return string;
}

- (void) dealloc
{
   [super dealloc];
   free(_state);
}
-(NSSet*) allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y, nil] autorelease];
}
-(CPBitAntecedents*) getAntecedents:(CPBitAssignment*)assignment{
   return ([self getAntecedentsFor:assignment withState:_state]);
}
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment withState:(ORUInt**)state
{
  //NSLog(@"Implication for 0x%lx[%u] = %@  traced back through %@", (unsigned long)assignment->var, assignment->index, (CPBitVarI*)assignment->var, self);
   
   CPBitAntecedents* ants = malloc(sizeof(CPBitAntecedents));
   CPBitAssignment** vars;
   vars  = malloc(sizeof(CPBitAssignment*));
   ants->numAntecedents = 0;
   
   ORInt index = assignment->index;
   ants->antecedents = vars;
   
   ORUInt len = [_x bitLength];
   
   

   if (assignment->var == _x) {
      index = assignment->index + _places;
      if((index < len) && (![_y isFree:index] || ~ISFREE(state[2][index/BITSPERWORD], state[3][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD)))) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _y;
         vars[ants->numAntecedents]->index = index;
         if(![_y isFree:index])
            vars[ants->numAntecedents]->value = [_y getBit:index];
         else
            vars[ants->numAntecedents]->value = !((ISTRUE(state[2][index/BITSPERWORD], state[3][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD))) == 0);
         ants->numAntecedents++;
      }
   }
   else
   {
      index = assignment->index - _places;
      if ((index >= 0) && (![_x isFree:index] || ~ISFREE(state[0][index/BITSPERWORD], state[1][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD)))) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _x;
         vars[ants->numAntecedents]->index = index;
         if(![_x isFree:index])
            vars[ants->numAntecedents]->value = [_x getBit:index];
         else
            vars[ants->numAntecedents]->value = !((ISTRUE(state[0][index/BITSPERWORD], state[1][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD))) == 0);
         ants->numAntecedents++;
      }
   }
//      if(ants->numAntecedents == 0)
//         NSLog(@"No antecedents in bit shift l constraint");
//   NSLog(@"x  %@",_x);
//   NSLog(@"y  %@",_y);
//   NSLog(@"Assignment: %@[%d] = %d",assignment->var,assignment->index,assignment->value);
//   if(ants->numAntecedents > 0)
//      NSLog(@"antecedent[0]: %@[%d] = %d",ants->antecedents[0]->var,ants->antecedents[0]->index,ants->antecedents[0]->value);
//   NSLog(@"\n\n\n");
   return ants;
}

-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment
{
  //NSLog(@"Implication for 0x%lx[%u] = %@  traced back through %@", (unsigned long)assignment->var, assignment->index, (CPBitVarI*)assignment->var, self);

   CPBitAntecedents* ants = malloc(sizeof(CPBitAntecedents));
   CPBitAssignment** vars;
   vars  = malloc(sizeof(CPBitAssignment*));
   ants->numAntecedents = 0;

   ORInt index = assignment->index;
   ants->antecedents = vars;
   
   ORUInt len = [_x bitLength];
   
   if (assignment->var == _x) {
      index = assignment->index + _places;
      if((index < len) && ![_y isFree:index])
      {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _y;
         vars[ants->numAntecedents]->index = index;
         vars[ants->numAntecedents]->value = [_y getBit:index];
         ants->numAntecedents++;
      }
      
   }
   else
   {
      index = assignment->index - _places;
      if ((index >= 0) && ![_x isFree:index])
      {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _x;
         vars[ants->numAntecedents]->index = index;
         vars[ants->numAntecedents]->value = [_x getBit:index];
         ants->numAntecedents++;
      }
   }
//   if(ants->numAntecedents == 0)
//      NSLog(@"No antecedents in bit shift l constraint");
   return ants;
}

-(void) post
{
   [self propagate];
   if (![_x bound])
      [_x whenChangePropagate: self];
   if (![_y bound])
      [_y whenChangePropagate: self];
   [self propagate];
}
-(void) propagate
{
#ifdef BIT_DEBUG
   NSLog(@"Bit Shift Left Constraint propagated.");
#endif
   unsigned int wordLength = [_x getWordLength];
   ORUInt bitLength = [_x bitLength];
   
   TRUInt* xLow;
   TRUInt* xUp;
   TRUInt* yLow;
   TRUInt* yUp;
   
   [_x getUp:&xUp andLow:&xLow];
   [_y getUp:&yUp andLow:&yLow];
   
   
   unsigned int* newXUp = alloca((sizeof(unsigned int))*(wordLength+1));
   unsigned int* newXLow  = alloca((sizeof(unsigned int))*(wordLength+1));
   unsigned int* newYUp = alloca((sizeof(unsigned int))*(wordLength+1));
   unsigned int* newYLow  = alloca((sizeof(unsigned int))*(wordLength+1));
   unsigned int* yUpForX  = alloca((sizeof(unsigned int))*(wordLength+1));
   
   ORUInt mask = 0xFFFFFFFF << (bitLength%BITSPERWORD + (BITSPERWORD - (_places % BITSPERWORD)));
      
//   if (bitLength<32){
//      NSLog(@"*******************************************");
//      NSLog(@"x << p = y");
//      NSLog(@"p= %d\n",_places);
//      NSLog(@"x= %@ with |x| = %d\n",_x,bitLength);
//      NSLog(@"y=  %@\n",_y);
//   }

   
   for(int i=0;i<wordLength;i++)
      yUpForX[i] = yUp[i]._val;
   if (bitLength%BITSPERWORD != 0)
      yUpForX[wordLength-1] |= mask;

   for(int i=0;i<wordLength;i++){
      if ((int)(i-(((int)_places)/BITSPERWORD)) >= 0) {
         //if there are higher bits to shift here
         newYUp[i] = ~(ISFALSE(yUp[i]._val,yLow[i]._val)|((ISFALSE(xUp[i-_places/32]._val, xLow[i-_places/32]._val)<<(_places%32))));
         newYLow[i] = ISTRUE(yUp[i]._val,yLow[i]._val)|((ISTRUE(xUp[i-_places/32]._val, xLow[i-_places/32]._val)<<(_places%32)));
         //         NSLog(@"i=%i",i+_places/32);
         if (((int)(i-(((int)_places)/BITSPERWORD)-1) >= 0) && (_places%BITSPERWORD != 0)) {
            newYUp[i] &= ~(ISFALSE(xUp[i-_places/32-1]._val, xLow[i-_places/32-1]._val)>>(32-(_places%32)));
            newYLow[i] |= ISTRUE(xUp[i-_places/32-1]._val, xLow[i-_places/32-1]._val)>>(32-(_places%32));
            //            NSLog(@"i=%i",i+_places/32+1);
         }
         else if (_places%32 !=0){
            newYUp[i] &= ~(UP_MASK >> (32-(_places%32)));
            newYLow[i] &= ~(UP_MASK >> (32-(_places%32)));
         }
      }
      else{
         newYUp[i] = 0;
         newYLow[i] = 0;
      }
      if ((int)(i+(int)_places/32) < wordLength) {
         newXUp[i] = ~(ISFALSE(xUp[i]._val,xLow[i]._val)| (ISFALSE(yUpForX[i+_places/32], yLow[i+_places/32]._val)>>(_places%32)));
         newXLow[i] = ISTRUE(xUp[i]._val,xLow[i]._val)|((ISTRUE(yUpForX[i+_places/32], yLow[i+_places/32]._val)>>(_places%32)));
         //         NSLog(@"i=%i",i-_places/32);
         if(((int)(i+(int)_places/32+1) < wordLength)  && (_places%BITSPERWORD != 0)){
            newXUp[i] &= ~(ISFALSE(yUpForX[(i+(int)_places/32+1)],yLow[(i+(int)_places/32+1)]._val)<<(32-(_places%32)))|mask;
            newXLow[i] |= ISTRUE(yUpForX[(i+(int)_places/32+1)],yLow[(i+(int)_places/32+1)]._val)<<(32-(_places%32));
            //            NSLog(@"i=%i",i-(int)_places/32-1);
         }
      }
      else{
         newXUp[i] = xUp[i]._val;
         newXLow[i] = xLow[i]._val;
      }

   }
   
   
//   if (bitLength<32){
//      NSLog(@"newX = %@",bitvar2NSString(newXLow, newXUp, bitLength));
//      NSLog(@"newY =  %@",bitvar2NSString(newYLow, newYUp, bitLength));
//      NSLog(@"\n");
//   }
//
//   if ((bitLength < 32) && ((newXLow[0] | newXUp[0] | newYLow[0] | newYUp[0]) > ((1 << bitLength)-1) )){
//      NSLog(@"newX = %@",bitvar2NSString(newXLow, newXUp, bitLength));
//      NSLog(@"newY =         %@",bitvar2NSString(newYLow, newYUp, bitLength));
//   }
   
   _state[0] = newXUp;
   _state[1] = newXLow;
   _state[2] = newYUp;
   _state[3] = newYLow;

   ORBool xFail = checkDomainConsistency(_x, newXLow, newXUp, wordLength, self);
   ORBool yFail = checkDomainConsistency(_y, newYLow, newYUp, wordLength, self);
   if ( xFail || yFail) {
      failNow();
   }
   
   [_x setUp:newXUp andLow:newXLow for:self];
   [_y setUp:newYUp andLow:newYLow for:self];
  
}
@end

@implementation CPBitShiftLBV
-(id) initCPBitShiftLBV:(CPBitVarI*)x shiftLBy:(CPBitVarI*)places equals:(CPBitVarI*)y{
   self = [super initCPBitCoreConstraint:[x engine]];
   _x = x;
   _y = y;
   _places = places;
   _state = malloc(sizeof(ORUInt*)*4);
//   _placesBound = makeTRUInt([[_x engine] trail], 0);
   return self;
   
}
-(NSString*) description
{
   NSMutableString* string = [NSMutableString stringWithString:[super description]];
   [string appendString:@" with "];
   [string appendString:[NSString stringWithFormat:@"%@ ",_x]];
   [string appendString:[NSString stringWithFormat:@"and %@\n",_y]];
   
   return string;
}

- (void) dealloc
{
   [super dealloc];
   free(_state);
}
-(NSSet*) allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y, nil] autorelease];
}

-(CPBitAntecedents*) getAntecedents:(CPBitAssignment*)assignment{
   return ([self getAntecedentsFor:assignment withState:_state]);
}
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment withState:(ORUInt**)state
{
  //NSLog(@"Implication for 0x%lx[%u] = %@  traced back through %@", (unsigned long)assignment->var, assignment->index, (CPBitVarI*)assignment->var, self);
   
   CPBitAntecedents* ants = malloc(sizeof(CPBitAntecedents));
   CPBitAssignment** vars;
   vars  = malloc(sizeof(CPBitAssignment*));
   ants->numAntecedents = 0;
   
   ORInt index = assignment->index;
   ants->antecedents = vars;
   
   ORUInt len = [_x bitLength];
   
   ORUInt places = [_places getLow]->_val;
   
   if (assignment->var == _x) {
      index = assignment->index + places;
      if((index < len) && (![_y isFree:index] || ~ISFREE(state[2][index/BITSPERWORD], state[3][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD)))) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _y;
         vars[ants->numAntecedents]->index = index;
         if(![_y isFree:index])
            vars[ants->numAntecedents]->value = [_y getBit:index];
         else
            vars[ants->numAntecedents]->value = !((ISTRUE(state[2][index/BITSPERWORD], state[3][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD))) == 0);
         ants->numAntecedents++;
      }
   }
   else
   {
      index = assignment->index - places;
      if ((index >= 0) && (![_x isFree:index] || ~ISFREE(state[0][index/BITSPERWORD], state[1][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD)))) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _x;
         vars[ants->numAntecedents]->index = index;
         if(![_x isFree:index])
            vars[ants->numAntecedents]->value = [_x getBit:index];
         else
            vars[ants->numAntecedents]->value = !((ISTRUE(state[0][index/BITSPERWORD], state[1][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD))) == 0);
         ants->numAntecedents++;
      }
   }
   //      if(ants->numAntecedents == 0)
   //         NSLog(@"No antecedents in bit shift l constraint");
   return ants;
}

-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment
{
   //NSLog(@"Implication for 0x%lx[%u] = %@  traced back through %@", (unsigned long)assignment->var, assignment->index, (CPBitVarI*)assignment->var, self);
   
   CPBitAntecedents* ants = malloc(sizeof(CPBitAntecedents));
   CPBitAssignment** vars;
   vars  = malloc(sizeof(CPBitAssignment*));
   ants->numAntecedents = 0;
   
   ORUInt places = [_places getLow]->_val;
   ORInt index = assignment->index;
   ants->antecedents = vars;
   
   ORUInt len = [_x bitLength];
   
   if (assignment->var == _x) {
      index = assignment->index + places;
      if((index < len) && ![_y isFree:index])
      {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _y;
         vars[ants->numAntecedents]->index = index;
         vars[ants->numAntecedents]->value = [_y getBit:index];
         ants->numAntecedents++;
      }
   }
   else
   {
      index = assignment->index - places;
      if ((index >= 0) && ![_x isFree:index])
      {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _x;
         vars[ants->numAntecedents]->index = index;
         vars[ants->numAntecedents]->value = [_x getBit:index];
         ants->numAntecedents++;
      }
   }
   //   if(ants->numAntecedents == 0)
   //      NSLog(@"No antecedents in bit shift l constraint");
   return ants;
}


-(void) post
{
   [self propagate];
   if (![_x bound])
      [_x whenChangePropagate: self];
   if (![_y bound])
      [_y whenChangePropagate: self];
   [self propagate];
}
-(void) propagate
{
#ifdef BIT_DEBUG
   NSLog(@"Bit Shift Left (by Bit Vector) Constraint propagated.");
#endif
   if([_places bound])
   {
      TRUInt* pLow;
      pLow = [_places getLow];
      ORUInt places = pLow->_val;
      unsigned int wordLength = [_x getWordLength];
      ORUInt bitLength = [_x bitLength];
      
      ORUInt mask = 0xFFFFFFFF << (bitLength%BITSPERWORD + (BITSPERWORD - (places % BITSPERWORD)));
      
      TRUInt* xLow;
      TRUInt* xUp;
      TRUInt* yLow;
      TRUInt* yUp;
      
      [_x getUp:&xUp andLow:&xLow];
      [_y getUp:&yUp andLow:&yLow];
      
      
      unsigned int* newXUp = alloca((sizeof(unsigned int))*(wordLength+1));
      unsigned int* newXLow  = alloca((sizeof(unsigned int))*(wordLength+1));
      unsigned int* newYUp = alloca((sizeof(unsigned int))*(wordLength+1));
      unsigned int* newYLow  = alloca((sizeof(unsigned int))*(wordLength+1));
      unsigned int* yUpForX  = alloca((sizeof(unsigned int))*(wordLength+1));
      
//            NSLog(@"*******************************************");
//            NSLog(@"x << p = y");
//            NSLog(@"p=%@\n",places);
//            NSLog(@"x=%@\n",_x);
//            NSLog(@"y=        %@\n",_y);

      
      for(int i=0;i<wordLength;i++)
         yUpForX[i] = yUp[i]._val;
      if (bitLength%BITSPERWORD != 0)
         yUpForX[wordLength-1] |= mask;
      
      for(int i=0;i<wordLength;i++){
         if ((int)(i-(((int)places)/BITSPERWORD)) >= 0) {
            //if there are higher bits to shift here
            newYUp[i] = ~(ISFALSE(yUp[i]._val,yLow[i]._val)|((ISFALSE(xUp[i-places/32]._val, xLow[i-places/32]._val)<<(places%32))));
            newYLow[i] = ISTRUE(yUp[i]._val,yLow[i]._val)|((ISTRUE(xUp[i-places/32]._val, xLow[i-places/32]._val)<<(places%32)));
            //         NSLog(@"i=%i",i+places/32);
            if (((int)(i-(((int)places)/BITSPERWORD)-1) >= 0) && (places%BITSPERWORD != 0)) {
               newYUp[i] &= ~(ISFALSE(xUp[i-places/32-1]._val, xLow[i-places/32-1]._val)>>(32-(places%32)));
               newYLow[i] |= ISTRUE(xUp[i-places/32-1]._val, xLow[i-places/32-1]._val)>>(32-(places%32));
               //            NSLog(@"i=%i",i+places/32+1);
            }
            else if (places%32 !=0){
               newYUp[i] &= ~(UP_MASK >> (32-(places%32)));
               newYLow[i] &= ~(UP_MASK >> (32-(places%32)));
            }
         }
         else{
            newYUp[i] = 0;
            newYLow[i] = 0;
         }
         if ((int)(i+(int)places/32) < wordLength) {
            newXUp[i] = ~(ISFALSE(xUp[i]._val,xLow[i]._val)| (ISFALSE(yUpForX[i+places/32], yLow[i+places/32]._val)>>(places%32)));
            newXLow[i] = ISTRUE(xUp[i]._val,xLow[i]._val)|((ISTRUE(yUpForX[i+places/32], yLow[i+places/32]._val)>>(places%32)));
            //         NSLog(@"i=%i",i-places/32);
            if(((int)(i+(int)_places/32+1) < wordLength)  && (places%BITSPERWORD != 0)){
               newXUp[i] &= ~(ISFALSE(yUpForX[(i+(int)places/32+1)],yLow[(i+(int)places/32+1)]._val)<<(32-(places%32)))|mask;
               newXLow[i] |= ISTRUE(yUpForX[(i+(int)places/32+1)],yLow[(i+(int)places/32+1)]._val)<<(32-(places%32));
               //            NSLog(@"i=%i",i-(int)places/32-1);
            }
         }
         else{
            newXUp[i] = xUp[i]._val;
            newXLow[i] = xLow[i]._val;
         }
         
      }
      
//            NSLog(@"newX = %@",bitvar2NSString(newXLow, newXUp, bitLength));
//            NSLog(@"newY =         %@",bitvar2NSString(newYLow, newYUp, bitLength));
      
      _state[0] = newXUp;
      _state[1] = newXLow;
      _state[2] = newYUp;
      _state[3] = newYLow;
      
      ORBool xFail = checkDomainConsistency(_x, newXLow, newXUp, wordLength, self);
      ORBool yFail = checkDomainConsistency(_y, newYLow, newYUp, wordLength, self);
      if ( xFail || yFail) {
         failNow();
      }
      
      [_x setUp:newXUp andLow:newXLow for:self];
      [_y setUp:newYUp andLow:newYLow for:self];
   }
}
- (void)visit:(ORVisitor *)visitor {
}

@end


@implementation CPBitShiftR
-(id) initCPBitShiftR:(CPBitVarI*)x shiftRBy:(int)places equals:(CPBitVarI*)y{
   self = [super initCPBitCoreConstraint:[x engine]];
   _x = x;
   _y = y;
   _places = places;
   _state = malloc(sizeof(ORUInt*)*4);
   return self;
   
}
-(NSString*) description
{
   NSMutableString* string = [NSMutableString stringWithString:[super description]];
   [string appendString:@" with "];
   [string appendString:[NSString stringWithFormat:@"%@ ",_x]];
   [string appendString:[NSString stringWithFormat:@"and %@\n",_y]];
   
   return string;
}

- (void) dealloc
{
   [super dealloc];
   free(_state);
}
-(NSSet*) allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y, nil] autorelease];
}
-(CPBitAntecedents*) getAntecedents:(CPBitAssignment*)assignment{
   return ([self getAntecedentsFor:assignment withState:_state]);
}
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment withState:(ORUInt**)state
{
 //NSLog(@"Implication for 0x%lx[%u] = %@  traced back through %@", (unsigned long)assignment->var, assignment->index, (CPBitVarI*)assignment->var, self);

   CPBitAntecedents* ants = malloc(sizeof(CPBitAntecedents));
   CPBitAssignment** vars;
   vars  = malloc(sizeof(CPBitAssignment*));
   ants->numAntecedents = 0;

   ORInt index = assignment->index;
   ants->antecedents = vars;
   
   ORUInt len = [_x bitLength];
   
   if (assignment->var == _x) {
      index = assignment->index -_places;
      if((index >= 0) && (![_y isFree:index] || ~ISFREE(state[2][index/BITSPERWORD], state[3][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD)))) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _y;
         vars[ants->numAntecedents]->index = index;
         if(![_y isFree:index])
            vars[ants->numAntecedents]->value = [_y getBit:index];
         else
            vars[ants->numAntecedents]->value = !((ISTRUE(state[2][index/BITSPERWORD], state[3][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD))) == 0);
         ants->numAntecedents++;
      }
   }
   else{
      index = assignment->index + _places;
      if ((index < len) && (![_x isFree:index] || ~ISFREE(state[0][index/BITSPERWORD], state[1][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD)))) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _x;
         vars[ants->numAntecedents]->index = index;
         if(![_x isFree:index])
            vars[ants->numAntecedents]->value = [_x getBit:index];
         else
            vars[ants->numAntecedents]->value = !((ISTRUE(state[0][index/BITSPERWORD], state[1][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD))) == 0);
         ants->numAntecedents++;
      }
   }
   return ants;
}
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment
{
   //NSLog(@"Implication for 0x%lx[%u] = %@  traced back through %@", (unsigned long)assignment->var, assignment->index, (CPBitVarI*)assignment->var, self);
   
   CPBitAntecedents* ants = malloc(sizeof(CPBitAntecedents));
   CPBitAssignment** vars;
   vars  = malloc(sizeof(CPBitAssignment*));
   ants->numAntecedents = 0;
   
   ORInt index = assignment->index;
   ants->antecedents = vars;
   
   ORUInt len = [_x bitLength];
   
   if (assignment->var == _x) {
      index = assignment->index -_places;
      if((index >= 0) && ![_y isFree:index])
      {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _y;
         vars[ants->numAntecedents]->index = index;
         vars[ants->numAntecedents]->value = [_y getBit:index];
         ants->numAntecedents++;
      }
   }
   else{
      index = assignment->index + _places;
      if ((index < len) && ![_x isFree:index])
      {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _x;
         vars[ants->numAntecedents]->index = index;
         vars[ants->numAntecedents]->value = [_x getBit:index];
         ants->numAntecedents++;
      }
   }
   return ants;
}

-(void) post
{
   [self propagate];
   if (![_x bound])
      [_x whenChangePropagate: self];
   if (![_y bound])
      [_y whenChangePropagate: self];
   [self propagate];
}
-(void) propagate
{
#ifdef BIT_DEBUG
   NSLog(@"Bit Shift Right Constraint propagated.");
#endif
   unsigned int wordLength = [_x getWordLength];
   
   TRUInt* xLow;
   TRUInt* xUp;
   TRUInt* yLow;
   TRUInt* yUp;
   
   [_x getUp:&xUp andLow:&xLow];
   [_y getUp:&yUp andLow:&yLow];
   
   unsigned int* newXUp = alloca((sizeof(unsigned int))*(wordLength+1));
   unsigned int* newXLow  = alloca((sizeof(unsigned int))*(wordLength+1));
   unsigned int* newYUp = alloca((sizeof(unsigned int))*(wordLength+1));
   unsigned int* newYLow  = alloca((sizeof(unsigned int))*(wordLength+1));
   
//      NSLog(@"*******************************************");
//      NSLog(@">>");
//      NSLog(@"x=%@\n",_x);
//      NSLog(@">> %u",_places);
//      NSLog(@"y=%@\n",_y);

   
   for(int i=0;i<wordLength;i++){
      if ((i+_places/32) < wordLength) {
         newYUp[i] = ~(ISFALSE(yUp[i]._val,yLow[i]._val)|((ISFALSE(xUp[i+_places/32]._val, xLow[i+_places/32]._val)>>(_places%32))));
         newYLow[i] = ISTRUE(yUp[i]._val,yLow[i]._val)|((ISTRUE(xUp[i+_places/32]._val, xLow[i+_places/32]._val)>>(_places%32)));
         //         NSLog(@"i=%i",i+_places/32);
         if((i+_places/32+1) < wordLength) {
            newYUp[i] &= ~(ISFALSE(xUp[i+_places/32+1]._val, xLow[i+_places/32+1]._val)<<(32-(_places%32)));
            newYLow[i] |= ISTRUE(xUp[i+_places/32+1]._val, xLow[i+_places/32+1]._val)<<(32-(_places%32));
            //            NSLog(@"i=%i",i+_places/32+1);
         }
         else{
            newYUp[i] &= ~(UP_MASK << (32-(_places%32)));
            newYLow[i] &= ~(UP_MASK << (32-(_places%32)));
         }
      }
      else{
         newYUp[i] = 0;
         newYLow[i] = 0;
      }
      
      if ((i-(int)_places/32) >= 0) {
         newXUp[i] = ~(ISFALSE(xUp[i]._val,xLow[i]._val)|((ISFALSE(yUp[i-_places/32]._val, yLow[i-_places/32]._val)<<(_places%32))));
         newXLow[i] = ISTRUE(xUp[i]._val,xLow[i]._val)|((ISTRUE(yUp[i-_places/32]._val, yLow[i-_places/32]._val)<<(_places%32)));
         //         NSLog(@"i=%i",i-_places/32);
         if((i-(int)_places/32-1) >= 0) {
            newXUp[i] &= ~(ISFALSE(yUp[(i-(int)_places/32-1)]._val,yLow[(i-(int)_places/32-1)]._val)>>(32-(_places%32)));
            newXLow[i] |= ISTRUE(yUp[(i-(int)_places/32-1)]._val,yLow[(i-(int)_places/32-1)]._val)>>(32-(_places%32));
            //            NSLog(@"i=%i",i-(int)_places/32-1);
         }
      }
      else{
         newXUp[i] = xUp[i]._val;
         newXLow[i] = xLow[i]._val;
      }
   }
   
   
   
//   NSLog(@"newX = %@",bitvar2NSString(newXLow, newXUp, [_x bitLength]));
//   NSLog(@"newY = %@",bitvar2NSString(newYLow, newYUp, [_y bitLength]));
   _state[0] = newXUp;
   _state[1] = newXLow;
   _state[2] = newYUp;
   _state[3] = newYLow;

   ORBool xFail = checkDomainConsistency(_x, newXLow, newXUp, wordLength, self);
   ORBool yFail = checkDomainConsistency(_y, newYLow, newYUp, wordLength, self);
   if ( xFail || yFail) {
      failNow();
   }
   [_x setUp:newXUp andLow:newXLow for:self];
   [_y setUp:newYUp andLow:newYLow for:self];
   
   
}
@end

@implementation CPBitShiftRBV
-(id) initCPBitShiftRBV:(CPBitVarI*)x shiftRBy:(CPBitVarI*)places equals:(CPBitVarI*)y{
   self = [super initCPBitCoreConstraint:[x engine]];
   _x = x;
   _y = y;
   _places = places;
   _placesBound = makeTRUInt([[_x engine] trail], 0);
   _state = malloc(sizeof(ORUInt*)*4);
   return self;
   
}
-(NSString*) description
{
   NSMutableString* string = [NSMutableString stringWithString:[super description]];
   [string appendString:@" with "];
   [string appendString:[NSString stringWithFormat:@"%@ ",_x]];
   [string appendString:[NSString stringWithFormat:@"and %@\n",_y]];
   
   return string;
}

- (void) dealloc
{
   [super dealloc];
   free(_state);
}
-(NSSet*) allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y, nil] autorelease];
}

- (void)close {
}

-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment withState:(ORUInt**)state
{
   return NULL;
}

-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment
{
   //NSLog(@"Implication for 0x%lx[%u] = %@  traced back through %@", (unsigned long)assignment->var, assignment->index, (CPBitVarI*)assignment->var, self);
   
   return NULL;
}

- (CPBitAntecedents *)getAntecedents:(CPBitAssignment *)assignment {
   return NULL;
}


-(void) post
{
   [self propagate];
   if (![_x bound])
      [_x whenChangePropagate: self];
   if (![_y bound])
      [_y whenChangePropagate: self];
   [self propagate];
}
-(void) propagate
{
#ifdef BIT_DEBUG
   NSLog(@"Bit Shift Right (by Bit Vector) Constraint propagated.");
#endif
   
   if(_placesBound._val != 0)
      return;
   if([_places bound])
   {
      TRUInt* pLow;
      assignTRUInt(&_placesBound, 1, [[_x engine] trail]);
      pLow = [_places getLow];
      ORUInt places = pLow->_val;
      [[_x engine] addInternal:[[CPBitShiftR alloc] initCPBitShiftR:_x shiftRBy:places equals:_y]];
   }
}
- (void)visit:(ORVisitor *)visitor {
}

@end


@implementation CPBitShiftRA
-(id) initCPBitShiftRA:(CPBitVarI*)x shiftRBy:(int)places equals:(CPBitVarI*)y{
   self = [super initCPBitCoreConstraint:[x engine]];
   _x = x;
   _y = y;
   _state = malloc(sizeof(ORUInt*)*4);
   _places = places;
   return self;
   
}
-(NSString*) description
{
   NSMutableString* string = [NSMutableString stringWithString:[super description]];
   [string appendString:@" with "];
   [string appendString:[NSString stringWithFormat:@"%@ ",_x]];
   [string appendString:[NSString stringWithFormat:@"%u ",_places]];
   [string appendString:[NSString stringWithFormat:@"and %@\n",_y]];
   
   return string;
}

- (void) dealloc
{
   [super dealloc];
   free(_state);
}
-(NSSet*) allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y, nil] autorelease];
}
-(CPBitAntecedents*) getAntecedents:(CPBitAssignment*)assignment{
   return ([self getAntecedentsFor:assignment withState:_state]);
}
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment withState:(ORUInt**)state
{
 //NSLog(@"Implication for 0x%lx[%u] = %@  traced back through %@", (unsigned long)assignment->var, assignment->index, (CPBitVarI*)assignment->var, self);

   CPBitAntecedents* ants = malloc(sizeof(CPBitAntecedents));
   CPBitAssignment** vars;
   vars  = malloc(sizeof(CPBitAssignment*));
   ants->numAntecedents = 0;
   
   ORInt index = assignment->index;
   ants->antecedents = vars;
   
   ORUInt len = [_x bitLength];
   
   if (assignment->var == _x) {
      index = assignment->index - _places;
      if((index >= 0) && (![_y isFree:index] || (~ISFREE(state[2][index/BITSPERWORD], state[3][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD))))){
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _y;
         vars[ants->numAntecedents]->index = index;
         if(![_y isFree:index])
            vars[ants->numAntecedents]->value = [_y getBit:index];
         else
            vars[ants->numAntecedents]->value = !((ISTRUE(state[2][index/BITSPERWORD], state[3][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD))) == 0);
         ants->numAntecedents++;
      }
   }
   else{
      index = assignment->index + _places;
      if ((index < len) && ((![_x isFree:index]) || (~ISFREE(state[0][index/BITSPERWORD], state[1][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD))) == 0)) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _x;
         vars[ants->numAntecedents]->index = index;
         if(![_x isFree:index])
            vars[ants->numAntecedents]->value = [_x getBit:index];
         else
            vars[ants->numAntecedents]->value = !((ISTRUE(state[0][index/BITSPERWORD], state[1][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD))) == 0);
         ants->numAntecedents++;
      }
      else if ((index >= len) && (![_x isFree:len-1] || (~ISFREE(state[0][index/BITSPERWORD], state[1][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD))))){
         index = len - 1;
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _x;
         vars[ants->numAntecedents]->index = index;
         if(![_x isFree:index])
            vars[ants->numAntecedents]->value = [_x getBit:index];
         else
            vars[ants->numAntecedents]->value = !((ISTRUE(state[0][index/BITSPERWORD], state[1][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD))) == 0);
         ants->numAntecedents++;
      }
   }
   return ants;
}

-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment
{
   //NSLog(@"Implication for 0x%lx[%u] = %@  traced back through %@", (unsigned long)assignment->var, assignment->index, (CPBitVarI*)assignment->var, self);
   
   CPBitAntecedents* ants = malloc(sizeof(CPBitAntecedents));
   CPBitAssignment** vars;
   vars  = malloc(sizeof(CPBitAssignment*));
   ants->numAntecedents = 0;
   
   ORInt index = assignment->index;
   ants->antecedents = vars;
   
   ORUInt len = [_x bitLength];
   
   if (assignment->var == _x) {
      index = assignment->index - _places;
      if((index >= 0) && ![_y isFree:index]){
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _y;
         vars[ants->numAntecedents]->index = index;
         vars[ants->numAntecedents]->value = [_y getBit:index];
         ants->numAntecedents++;
      }
   }
   else{
      index = assignment->index + _places;
      if ((index < len) && ![_x isFree:index]) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _x;
         vars[ants->numAntecedents]->index = index;
         vars[ants->numAntecedents]->value = [_x getBit:index];
         ants->numAntecedents++;
      }
      else if ((index >= len) && ![_x isFree:len-1]){
         index = len - 1;
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _x;
         vars[ants->numAntecedents]->index = index;
         vars[ants->numAntecedents]->value = [_x getBit:index];
         ants->numAntecedents++;
      }
   }
   return ants;
}

-(void) post
{
   [self propagate];
   if (![_x bound])
      [_x whenChangePropagate: self];
   if (![_y bound])
      [_y whenChangePropagate: self];
   [self propagate];
}
-(void) propagate
{
#ifdef BIT_DEBUG
   NSLog(@"Bit Shift Right Arithmetic Constraint propagated.");
#endif
   ORUInt wordLength = [_x getWordLength];
//   ORUInt bitLength = [_x bitLength];
   
   TRUInt* xLow;
   TRUInt* xUp;
   TRUInt* yLow;
   TRUInt* yUp;
   
   [_x getUp:&xUp andLow:&xLow];
   [_y getUp:&yUp andLow:&yLow];
   
   ORUInt signmask = 1 << (([_x bitLength]-1)%BITSPERWORD);
   ORUInt signSet = ((~(xLow[wordLength-1]._val^xUp[wordLength-1]._val)) & signmask);
   
   ORUInt* newXUp = alloca((sizeof(unsigned int))*(wordLength+1));
   ORUInt* newXLow  = alloca((sizeof(unsigned int))*(wordLength+1));
   ORUInt* newYUp = alloca((sizeof(unsigned int))*(wordLength+1));
   ORUInt* newYLow  = alloca((sizeof(unsigned int))*(wordLength+1));
   
   
//   NSLog(@"*******************************************");
//   NSLog(@"x >>a places = y");
//   NSLog(@"x=%@\n",_x);
//   NSLog(@"places=%u\n",_places);
//   NSLog(@"y=%@\n\v",_y);

   
   for(int i=0;i<wordLength;i++){
      if ((i+_places/32) < wordLength) {
         newYUp[i] = ~(ISFALSE(yUp[i]._val,yLow[i]._val)|((ISFALSE(xUp[i+_places/32]._val, xLow[i+_places/32]._val)>>(_places%32))));
         newYLow[i] = ISTRUE(yUp[i]._val,yLow[i]._val)|((ISTRUE(xUp[i+_places/32]._val, xLow[i+_places/32]._val)>>(_places%32)));
         //         NSLog(@"i=%i",i+_places/32);
         if((i+_places/32+1) < wordLength) {
            newYUp[i] &= ~(ISFALSE(xUp[i+_places/32+1]._val, xLow[i+_places/32+1]._val)<<(32-(_places%32)));
            newYLow[i] |= ISTRUE(xUp[i+_places/32+1]._val, xLow[i+_places/32+1]._val)<<(32-(_places%32));
            //            NSLog(@"i=%i",i+_places/32+1);
         }
         else if (signSet & ~xUp[wordLength-1]._val) {
            newYUp[i] &= ~(UP_MASK << (32-(_places%32)));
            newYLow[i] &= ~(UP_MASK << (32-(_places%32)));
         } else if (signSet * xLow[wordLength-1]._val){
            newYUp[i] |= (UP_MASK << (32-(_places%32)));
            newYLow[i] |= (UP_MASK << (32-(_places%32)));
         }
      }
      else{
         newYUp[i] = 0;
         newYLow[i] = 0;
      }
      
      if ((i-(int)_places/32) >= 0) {
         newXUp[i] = ~(ISFALSE(xUp[i]._val,xLow[i]._val)|((ISFALSE(yUp[i-_places/32]._val, yLow[i-_places/32]._val)<<(_places%32))));
         newXLow[i] = ISTRUE(xUp[i]._val,xLow[i]._val)|((ISTRUE(yUp[i-_places/32]._val, yLow[i-_places/32]._val)<<(_places%32)));
         //         NSLog(@"i=%i",i-_places/32);
         if((i-(int)_places/32-1) >= 0) {
            newXUp[i] &= ~(ISFALSE(yUp[(i-(int)_places/32-1)]._val,yLow[(i-(int)_places/32-1)]._val)>>(32-(_places%32)));
            newXLow[i] |= ISTRUE(yUp[(i-(int)_places/32-1)]._val,yLow[(i-(int)_places/32-1)]._val)>>(32-(_places%32));
            //            NSLog(@"i=%i",i-(int)_places/32-1);
         }
      }
      else{
         newXUp[i] = xUp[i]._val;
         newXLow[i] = xLow[i]._val;
      }
   }
   
//   NSLog(@"newX = %@",bitvar2NSString(newXLow, newXUp, bitLength));
//   NSLog(@"newY = %@",bitvar2NSString(newYLow, newYUp, bitLength));
   
   _state[0] = newXUp;
   _state[1] = newXLow;
   _state[2] = newYUp;
   _state[3] = newYLow;
   
   ORBool xFail = checkDomainConsistency(_x, newXLow, newXUp, wordLength, self);
   ORBool yFail = checkDomainConsistency(_y, newYLow, newYUp, wordLength, self);
   if ( xFail || yFail) {
      failNow();
   }

   [_x setUp:newXUp andLow:newXLow for:self];
   [_y setUp:newYUp andLow:newYLow for:self];
   
}
@end

@implementation CPBitShiftRABV
-(id) initCPBitShiftRABV:(CPBitVarI*)x shiftRBy:(CPBitVarI*)places equals:(CPBitVarI*)y{
   self = [super initCPBitCoreConstraint:[x engine]];
   _x = x;
   _y = y;
   _places = places;
   _state = malloc(sizeof(ORUInt*)*4);
   _placesBound = makeTRUInt([[_x engine] trail], 0);
   return self;
   
}
-(NSString*) description
{
   NSMutableString* string = [NSMutableString stringWithString:[super description]];
   [string appendString:@" with "];
   [string appendString:[NSString stringWithFormat:@"%@ ",_x]];
   [string appendString:[NSString stringWithFormat:@"and %@\n",_y]];
   
   return string;
}

- (void) dealloc
{
   [super dealloc];
   free(_state);
}
-(NSSet*) allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y, nil] autorelease];
}

- (void)close {
}

-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment withState:(ORUInt**)state
{
   return NULL;
}

-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment
{
   //NSLog(@"Implication for 0x%lx[%u] = %@  traced back through %@", (unsigned long)assignment->var, assignment->index, (CPBitVarI*)assignment->var, self);
   
   return NULL;
}

- (CPBitAntecedents *)getAntecedents:(CPBitAssignment *)assignment {
   return NULL;
}


-(void) post
{
   [self propagate];
   if (![_x bound])
      [_x whenChangePropagate: self];
   if (![_y bound])
      [_y whenChangePropagate: self];
   [self propagate];
}
-(void) propagate
{
#ifdef BIT_DEBUG
   NSLog(@"Bit Shift Right Arithmetic (by Bit Vector) Constraint propagated.");
#endif
   
   
   
   if(_placesBound._val != 0)
      return;
   if([_places bound])
   {
      id<CPEngine> engine = [_x engine];
      TRUInt* pLow;
      
      assignTRUInt(&_placesBound, 1, [engine trail]);
      pLow = [_places getLow];
      ORUInt places = pLow->_val;
      [engine addInternal:[[CPBitShiftRA alloc] initCPBitShiftRA:_x shiftRBy:places equals:_y]];
   }
}
- (void)visit:(ORVisitor *)visitor {
}

@end

@implementation CPBitRotateL
-(id) initCPBitRotateL:(CPBitVarI*)x rotateLBy:(int)places equals:(CPBitVarI*)y{
   self = [super initCPBitCoreConstraint:[x engine]];
   _x = x;
   _y = y;
   _places = places;
   _state = malloc(sizeof(ORUInt*)*4);
   return self;
   
}
-(NSString*) description
{
   NSMutableString* string = [NSMutableString stringWithString:[super description]];
   [string appendString:@" with "];
   [string appendString:[NSString stringWithFormat:@"%@ ",_x]];
   [string appendString:[NSString stringWithFormat:@"and %@\n",_y]];
   
   return string;
}

- (void) dealloc
{
   [super dealloc];
   free(_state);
}
-(NSSet*) allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y, nil] autorelease];
}
-(CPBitAntecedents*) getAntecedents:(CPBitAssignment*)assignment{
   return ([self getAntecedentsFor:assignment withState:_state]);
}
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment withState:(ORUInt**)state
{
 //NSLog(@"Implication for 0x%lx[%u] = %@  traced back through %@", (unsigned long)assignment->var, assignment->index, (CPBitVarI*)assignment->var, self);

//   NSLog(@"Tracing back BitRotateL constraint with 0x%lx and 0x%lx",_x,_y);
   CPBitAntecedents* ants = malloc(sizeof(CPBitAntecedents));
   CPBitAssignment** vars;
   vars  = malloc(sizeof(CPBitAssignment*));
   ants->numAntecedents = 0;

   ORUInt index = assignment->index;
   ants->antecedents = vars;
   
   ORUInt len = [_x bitLength];
   
   if (assignment->var == _x) {
      index = (assignment->index + _places) % len;
      if (![_y isFree:index] || (~ISFREE(state[2][index/BITSPERWORD], state[3][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD)))) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _y;
         vars[ants->numAntecedents]->index = index;
         if(![_y isFree:index])
            vars[ants->numAntecedents]->value = [_y getBit:index];
         else
         vars[ants->numAntecedents]->value = !((ISTRUE(state[2][index/BITSPERWORD], state[3][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD))) == 0);
         ants->numAntecedents++;
      }
   }
   else{
      index = ((assignment->index + len)-_places) % len;
      if (![_x isFree:index] || (~ISFREE(state[0][index/BITSPERWORD], state[1][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD)))) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _x;
         vars[ants->numAntecedents]->index = index;
         if(![_x isFree:index])
            vars[ants->numAntecedents]->value = [_x getBit:index];
         else
            vars[ants->numAntecedents]->value = !((ISTRUE(state[0][index/BITSPERWORD], state[1][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD))) == 0);
         ants->numAntecedents++;
      }
   }
   return ants;
}
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment
{
   //NSLog(@"Implication for 0x%lx[%u] = %@  traced back through %@", (unsigned long)assignment->var, assignment->index, (CPBitVarI*)assignment->var, self);
   
   //   NSLog(@"Tracing back BitRotateL constraint with 0x%lx and 0x%lx",_x,_y);
   CPBitAntecedents* ants = malloc(sizeof(CPBitAntecedents));
   CPBitAssignment** vars;
   vars  = malloc(sizeof(CPBitAssignment*));
   ants->numAntecedents = 0;
   
   ORUInt index = assignment->index;
   ants->antecedents = vars;
   
   ORUInt len = [_x bitLength];
   
   if (assignment->var == _x) {
      index = (assignment->index + _places) % len;
      if(![_y isFree:index]){
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _y;
         vars[ants->numAntecedents]->index = index;
         vars[ants->numAntecedents]->value = [_y getBit:index];
         ants->numAntecedents++;
      }
   }
   else{
      index = ((assignment->index + len)-_places) % len;
      if (![_x isFree:index]) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _x;
         vars[ants->numAntecedents]->index = index;
         vars[ants->numAntecedents]->value = [_x getBit:index];
         ants->numAntecedents++;
      }
   }
   return ants;
}

-(void) post
{
   [self propagate];
   if (![_x bound])
      [_x whenChangePropagate: self];
   if (![_y bound])
      [_y whenChangePropagate: self];
   
   [self propagate];
}
-(void) propagate
{
#ifdef BIT_DEBUG
   NSLog(@"********************************************************");
   NSLog(@"Bit Rotate Left Constraint propagated.");
#endif
   unsigned int wordLength = [_x getWordLength];
   unsigned int bitLength = [_x bitLength];
   
   TRUInt* xLow;
   TRUInt* xUp;
   TRUInt* yLow;
   TRUInt* yUp;
   
   [_x getUp:&xUp andLow:&xLow];
   [_y getUp:&yUp andLow:&yLow];
   
   ORUInt bitmask = CP_UMASK << _places;
   
   
   unsigned int* newXUp = alloca((sizeof(unsigned int))*wordLength);
   unsigned int* newXLow  = alloca((sizeof(unsigned int))*wordLength);
   unsigned int* newYUp = alloca((sizeof(unsigned int))*wordLength);
   unsigned int* newYLow  = alloca((sizeof(unsigned int))*wordLength);
   
#ifdef BIT_DEBUG
   NSLog(@"         X =%@",_x);
   NSLog(@" ROTL %d  Y =%@",_places,_y);
#endif
   if(bitLength >= BITSPERWORD){
      ORUInt lowBitsShift = ((bitLength%BITSPERWORD) == 0) ? BITSPERWORD : (bitLength%BITSPERWORD);
      lowBitsShift -= _places%BITSPERWORD;
      newYUp[0] = 0;
      newYLow[0] = 0;
      for(int i=0;i<wordLength;i++){
         newYUp[i] = ~(ISFALSE(yUp[i]._val,yLow[i]._val)) & (~(ISFALSE(xUp[(i+(_places/BITSPERWORD))%wordLength]._val, xLow[(i+(_places/BITSPERWORD))%wordLength]._val) << _places%BITSPERWORD)
                       & ~(ISFALSE(xUp[(i+(_places/BITSPERWORD)+1)%wordLength]._val, xLow[(i+(_places/BITSPERWORD)+1)%wordLength]._val) >> lowBitsShift));
         
//         newYUp[i] = yUp[i]._val & (bitmask | (xUp[(i+(_places/BITSPERWORD))%wordLength]._val << _places%BITSPERWORD)) & (bitmask | (xUp[(i+(_places/BITSPERWORD)+1)%wordLength]._val >> lowBitsShift));
         newYLow[i] = ISTRUE(yUp[i]._val,yLow[i]._val)   | (ISTRUE(xUp[(i+(_places/BITSPERWORD))%wordLength]._val, xLow[(i+(_places/BITSPERWORD))%wordLength]._val) << _places%BITSPERWORD)
         | (ISTRUE(xUp[(i+(_places/BITSPERWORD)+1)%wordLength]._val, xLow[(i+(_places/BITSPERWORD)+1)%wordLength]._val) >> lowBitsShift);
         
         newXUp[i] = ~(ISFALSE(xUp[i]._val,xLow[i]._val) | (ISFALSE(yUp[(i-(_places/BITSPERWORD))%wordLength]._val, yLow[(i-(_places/BITSPERWORD))%wordLength]._val) >> _places%BITSPERWORD)
                       | (ISFALSE(yUp[(i-(_places/BITSPERWORD)-1)%wordLength]._val, yLow[(i-(_places/BITSPERWORD)-1)%wordLength]._val) << lowBitsShift));
         
         newXLow[i] = ISTRUE(xUp[i]._val,xLow[i]._val)   | (ISTRUE(yUp[(i-(_places/BITSPERWORD))%wordLength]._val, yLow[(i-(_places/BITSPERWORD))%wordLength]._val) >> _places%BITSPERWORD)
         | (ISTRUE(yUp[(i-(_places/BITSPERWORD)-1)%wordLength]._val, yLow[(i-(_places/BITSPERWORD)-1)%wordLength]._val) << lowBitsShift);
         
      }
   }
   else{
      ORUInt mask = -1;
      mask >>= BITSPERWORD - bitLength;
      
      newXUp[0] = xUp[0]._val & ((yUp[0]._val >> _places) | ((yUp[0]._val << (bitLength -_places))& bitmask));
      newXLow[0] = xLow[0]._val | ((yLow[0]._val >> _places) | ((yLow[0]._val << (bitLength -_places))& bitmask));
      newYUp[0] = yUp[0]._val & ((xUp[0]._val >> (bitLength -_places)) | ((xUp[0]._val << _places)));
      newYLow[0] = yLow[0]._val | ((xLow[0]._val >> (bitLength - _places)) | ((xLow[0]._val << _places)));
      
      newXUp[0] &= mask;
      newXLow[0] &= mask;
      newYUp[0] &= mask;
      newYLow[0] &= mask;
   }
   _state[0] = newXUp;
   _state[1] = newXLow;
   _state[2] = newYUp;
   _state[3] = newYLow;
   
   ORBool xFail = checkDomainConsistency(_x, newXLow, newXUp, wordLength, self);
   ORBool yFail = checkDomainConsistency(_y, newYLow, newYUp, wordLength, self);
   
   if (xFail || yFail)
      failNow();
   
   [_x setUp:newXUp andLow:newXLow for:self];
   [_y setUp:newYUp andLow:newYLow for:self];
   
#ifdef BIT_DEBUG
   NSLog(@"         X =%@",_x);
   NSLog(@" ROTL %d  Y =%@",_places,_y);
   NSLog(@"********************************************************");
#endif
}
@end

@implementation CPBitADD {
@private
   CPBitVarI*      _x;
   CPBitVarI*      _y;
   CPBitVarI*      _z;
   CPBitVarI*      _cin;
   CPBitVarI*      _cout;
   ORUInt**        _state;
}
-(id) initCPBitAdd:(id<CPBitVar>)x plus:(id<CPBitVar>)y equals:(id<CPBitVar>)z withCarryIn:(id<CPBitVar>)cin andCarryOut:(id<CPBitVar>)cout
{
   self = [super initCPBitCoreConstraint:[x engine]];
   _x = (CPBitVarI*)x;
   _y = (CPBitVarI*)y;
   _z = (CPBitVarI*)z;
   _cin = (CPBitVarI*)cin;
   _cout = (CPBitVarI*)cout;
   _state = malloc(sizeof(ORUInt*)*10);
   return self;
}
-(NSString*) description
{
   NSMutableString* string = [NSMutableString stringWithString:[super description]];
   [string appendString:@" with "];
   [string appendString:[NSString stringWithFormat:@"%@ ",_x]];
   [string appendString:[NSString stringWithFormat:@"and %@ ",_y]];
   [string appendString:[NSString stringWithFormat:@"and %@\n",_z]];
   [string appendString:[NSString stringWithFormat:@"with Carry In %@\n",_cin]];
   [string appendString:[NSString stringWithFormat:@"and Carry Out%@\n",_cout]];
   
   
   return string;
}

- (void) dealloc
{
   [super dealloc];
   free(_state);
}
-(NSSet*) allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y, _z, _cin, _cout, nil] autorelease];
}
-(CPBitAntecedents*) getAntecedents:(CPBitAssignment*)assignment{
   return ([self getAntecedentsFor:assignment withState:_state]);
}
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment withState:(ORUInt**)state
{
  //NSLog(@"Implication for 0x%lx[%u] = %@  traced back through %@", (unsigned long)assignment->var, assignment->index, (CPBitVarI*)assignment->var, self);
   
   CPBitAntecedents* ants = malloc(sizeof(CPBitAntecedents));
   CPBitAssignment** vars;
   vars  = malloc(sizeof(CPBitAssignment*)*6);
   ants->numAntecedents = 0;
   
   ORUInt index = assignment->index;
   ants->antecedents = vars;
   
   if (assignment->var == _x) {
      if (![_y isFree:index] || (~ISFREE(state[2][index/BITSPERWORD], state[3][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD)))) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _y;
         vars[ants->numAntecedents]->index = index;
         if(![_y isFree:index])
            vars[ants->numAntecedents]->value = [_y getBit:index];
         else
            vars[ants->numAntecedents]->value = !((ISTRUE(state[2][index/BITSPERWORD], state[3][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD))) == 0);
         ants->numAntecedents++;
      }
      if (![_z isFree:index] || (~ISFREE(state[4][index/BITSPERWORD], state[5][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD)))) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _z;
         vars[ants->numAntecedents]->index = index;
         if(![_z isFree:index])
            vars[ants->numAntecedents]->value = [_z getBit:index];
         else
            vars[ants->numAntecedents]->value = !((ISTRUE(state[4][index/BITSPERWORD], state[5][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD))) == 0);
         ants->numAntecedents++;
      }
      if (![_cin isFree:index] || (~ISFREE(state[6][index/BITSPERWORD], state[7][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD)))) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _cin;
         vars[ants->numAntecedents]->index = index;
         if(![_cin isFree:index])
            vars[ants->numAntecedents]->value = [_cin getBit:index];
         else
            vars[ants->numAntecedents]->value = !((ISTRUE(state[6][index/BITSPERWORD], state[7][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD))) == 0);
         ants->numAntecedents++;
      }
      if (![_cout isFree:index] || (~ISFREE(state[8][index/BITSPERWORD], state[9][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD)))) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _cout;
         vars[ants->numAntecedents]->index = index;
         if(![_cout isFree:index])
            vars[ants->numAntecedents]->value = [_cout getBit:index];
         else
            vars[ants->numAntecedents]->value = !((ISTRUE(state[8][index/BITSPERWORD], state[9][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD))) == 0);
         ants->numAntecedents++;
      }
   }
   else if (assignment->var == _y){
      if (![_x isFree:index] || (~ISFREE(state[0][index/BITSPERWORD], state[1][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD)))) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _x;
         vars[ants->numAntecedents]->index = index;
         if(![_x isFree:index])
            vars[ants->numAntecedents]->value = [_x getBit:index];
         else
            vars[ants->numAntecedents]->value = !((ISTRUE(state[0][index/BITSPERWORD], state[1][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD))) == 0);
         ants->numAntecedents++;
      }
      if (![_z isFree:index] || (~ISFREE(state[4][index/BITSPERWORD], state[5][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD)))) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _z;
         vars[ants->numAntecedents]->index = index;
         if(![_z isFree:index])
            vars[ants->numAntecedents]->value = [_z getBit:index];
         else
            vars[ants->numAntecedents]->value = !((ISTRUE(state[4][index/BITSPERWORD], state[5][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD))) == 0);
         ants->numAntecedents++;
      }
      if (![_cin isFree:index] || (~ISFREE(state[6][index/BITSPERWORD], state[7][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD)))) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _cin;
         vars[ants->numAntecedents]->index = index;
         if(![_cin isFree:index])
            vars[ants->numAntecedents]->value = [_cin getBit:index];
         else
            vars[ants->numAntecedents]->value = !((ISTRUE(state[6][index/BITSPERWORD], state[7][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD))) == 0);
         ants->numAntecedents++;
      }
      if (![_cout isFree:index] || (~ISFREE(state[8][index/BITSPERWORD], state[9][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD)))) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _cout;
         vars[ants->numAntecedents]->index = index;
         if(![_cout isFree:index])
            vars[ants->numAntecedents]->value = [_cout getBit:index];
         else
            vars[ants->numAntecedents]->value = !((ISTRUE(state[8][index/BITSPERWORD], state[9][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD))) == 0);
         ants->numAntecedents++;
      }
   }
   else if (assignment->var == _z){
      if (![_x isFree:index] || (~ISFREE(state[0][index/BITSPERWORD], state[1][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD)))) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _x;
         vars[ants->numAntecedents]->index = index;
         if(![_x isFree:index])
            vars[ants->numAntecedents]->value = [_x getBit:index];
         else
            vars[ants->numAntecedents]->value = !((ISTRUE(state[0][index/BITSPERWORD], state[1][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD))) == 0);
         ants->numAntecedents++;
      }
      if (![_y isFree:index] || (~ISFREE(state[2][index/BITSPERWORD], state[3][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD)))) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _y;
         vars[ants->numAntecedents]->index = index;
         if(![_y isFree:index])
            vars[ants->numAntecedents]->value = [_y getBit:index];
         else
            vars[ants->numAntecedents]->value = !((ISTRUE(state[2][index/BITSPERWORD], state[3][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD))) == 0);
         ants->numAntecedents++;
      }
      if (![_cin isFree:index] || (~ISFREE(state[6][index/BITSPERWORD], state[7][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD)))) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _cin;
         vars[ants->numAntecedents]->index = index;
         if(![_cin isFree:index])
            vars[ants->numAntecedents]->value = [_cin getBit:index];
         else
            vars[ants->numAntecedents]->value = !((ISTRUE(state[6][index/BITSPERWORD], state[7][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD))) == 0);
         ants->numAntecedents++;
      }
      if (![_cout isFree:index] || (~ISFREE(state[8][index/BITSPERWORD], state[9][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD)))) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _cout;
         vars[ants->numAntecedents]->index = index;
         if(![_cout isFree:index])
            vars[ants->numAntecedents]->value = [_cout getBit:index];
         else
            vars[ants->numAntecedents]->value = !((ISTRUE(state[8][index/BITSPERWORD], state[9][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD))) == 0);
         ants->numAntecedents++;
      }
   }
   else if (assignment->var == _cin){
      if (![_x isFree:index] || (~ISFREE(state[0][index/BITSPERWORD], state[1][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD)))) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _x;
         vars[ants->numAntecedents]->index = index;
         if(![_x isFree:index])
            vars[ants->numAntecedents]->value = [_x getBit:index];
         else
            vars[ants->numAntecedents]->value = !((ISTRUE(state[0][index/BITSPERWORD], state[1][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD))) == 0);
         ants->numAntecedents++;
      }
      if (![_y isFree:index] || (~ISFREE(state[2][index/BITSPERWORD], state[3][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD)))) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _y;
         vars[ants->numAntecedents]->index = index;
         if(![_y isFree:index])
            vars[ants->numAntecedents]->value = [_y getBit:index];
         else
            vars[ants->numAntecedents]->value = !((ISTRUE(state[2][index/BITSPERWORD], state[3][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD))) == 0);
         ants->numAntecedents++;
      }
      if (![_z isFree:index] || (~ISFREE(state[4][index/BITSPERWORD], state[5][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD)))) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _z;
         vars[ants->numAntecedents]->index = index;
         if(![_z isFree:index])
            vars[ants->numAntecedents]->value = [_z getBit:index];
         else
            vars[ants->numAntecedents]->value = !((ISTRUE(state[4][index/BITSPERWORD], state[5][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD))) == 0);
         ants->numAntecedents++;
      }
      if (![_cout isFree:index] || (~ISFREE(state[8][index/BITSPERWORD], state[9][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD)))) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _cout;
         vars[ants->numAntecedents]->index = index;
         if(![_cout isFree:index])
            vars[ants->numAntecedents]->value = [_cout getBit:index];
         else
            vars[ants->numAntecedents]->value = !((ISTRUE(state[8][index/BITSPERWORD], state[9][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD))) == 0);
         ants->numAntecedents++;
      }
      if ((index > 0) && (![_cout isFree:index-1] || ~ISFREE(state[8][(index-1)/BITSPERWORD], state[9][(index-1)/BITSPERWORD]) & (0x1 << ((index-1)%BITSPERWORD)))){

         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _cout;
         vars[ants->numAntecedents]->index = index-1;
         if(![_cout isFree:index-1])
            vars[ants->numAntecedents]->value = [_cout getBit:index-1];
         else
            vars[ants->numAntecedents]->value = !((ISTRUE(state[8][(index-1)/BITSPERWORD], state[9][(index-1)/BITSPERWORD]) & (0x1 << ((index-1)%BITSPERWORD))) == 0);
         ants->numAntecedents++;
      }
   }
   else if (assignment->var == _cout){
      if (![_x isFree:index] || (~ISFREE(state[0][index/BITSPERWORD], state[1][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD)))) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _x;
         vars[ants->numAntecedents]->index = index;
         if(![_x isFree:index])
            vars[ants->numAntecedents]->value = [_x getBit:index];
         else
            vars[ants->numAntecedents]->value = !((ISTRUE(state[0][index/BITSPERWORD], state[1][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD))) == 0);
         ants->numAntecedents++;
      }
      if (![_y isFree:index] || (~ISFREE(state[2][index/BITSPERWORD], state[3][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD)))) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _y;
         vars[ants->numAntecedents]->index = index;
         if(![_y isFree:index])
            vars[ants->numAntecedents]->value = [_y getBit:index];
         else
            vars[ants->numAntecedents]->value = !((ISTRUE(state[2][index/BITSPERWORD], state[3][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD))) == 0);
         ants->numAntecedents++;
      }
      if (![_z isFree:index] || (~ISFREE(state[4][index/BITSPERWORD], state[5][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD)))) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _z;
         vars[ants->numAntecedents]->index = index;
         if(![_z isFree:index])
            vars[ants->numAntecedents]->value = [_z getBit:index];
         else
            vars[ants->numAntecedents]->value = !((ISTRUE(state[4][index/BITSPERWORD], state[5][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD))) == 0);
         ants->numAntecedents++;
      }
      if (![_cin isFree:index] || (~ISFREE(state[6][index/BITSPERWORD], state[7][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD)))) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _cin;
         vars[ants->numAntecedents]->index = index;
         if(![_cin isFree:index])
            vars[ants->numAntecedents]->value = [_cin getBit:index];
         else
            vars[ants->numAntecedents]->value = !((ISTRUE(state[6][index/BITSPERWORD], state[7][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD))) == 0);
         ants->numAntecedents++;
      }
      if ((index+1 < [_cin bitLength]) && (![_cin isFree:index+1] || ~ISFREE(state[6][(index+1)/BITSPERWORD], state[7][(index+1)/BITSPERWORD]) & (0x1 << ((index+1)%BITSPERWORD)))) {

         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _cin;
         vars[ants->numAntecedents]->index = index+1;
         if(![_cin isFree:index+1])
            vars[ants->numAntecedents]->value = [_cin getBit:index+1];
         else
            vars[ants->numAntecedents]->value = !((ISTRUE(state[6][(index+1)/BITSPERWORD], state[7][(index+1)/BITSPERWORD]) & (0x1 << ((index+1)%BITSPERWORD))) == 0);
         ants->numAntecedents++;
      }
   }
   //   if(ants->numAntecedents==0)
   //      NSLog(@"Unable to find antecedents in CPBitADD constraint");
   return ants;
}


-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment
{
  //NSLog(@"Implication for 0x%lx[%u] = %@  traced back through %@", (unsigned long)assignment->var, assignment->index, (CPBitVarI*)assignment->var, self);

   CPBitAntecedents* ants = malloc(sizeof(CPBitAntecedents));
   CPBitAssignment** vars;
   vars  = malloc(sizeof(CPBitAssignment*)*6);
   ants->numAntecedents = 0;

   ORUInt index = assignment->index;
   ants->antecedents = vars;

   if (assignment->var == _x) {
      if (![_y isFree:index]) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _y;
         vars[ants->numAntecedents]->index = index;
         vars[ants->numAntecedents]->value = [_y getBit:index];
         ants->numAntecedents++;
      }
      if (![_z isFree:index]) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _z;
         vars[ants->numAntecedents]->index = index;
         vars[ants->numAntecedents]->value = [_z getBit:index];
         ants->numAntecedents++;
      }
      if (![_cin isFree:index]) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _cin;
         vars[ants->numAntecedents]->index = index;
         vars[ants->numAntecedents]->value = [_cin getBit:index];
         ants->numAntecedents++;
      }
      if (![_cout isFree:index]) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _cout;
         vars[ants->numAntecedents]->index = index;
         vars[ants->numAntecedents]->value = [_cout getBit:index];
         ants->numAntecedents++;
      }
   }
   else if (assignment->var == _y){
      if (![_x isFree:index]) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _x;
         vars[ants->numAntecedents]->index = index;
         vars[ants->numAntecedents]->value = [_x getBit:index];
         ants->numAntecedents++;
      }
      if (![_z isFree:index]) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _z;
         vars[ants->numAntecedents]->index = index;
         vars[ants->numAntecedents]->value = [_z getBit:index];
         ants->numAntecedents++;
      }
      if (![_cin isFree:index]) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _cin;
         vars[ants->numAntecedents]->index = index;
         vars[ants->numAntecedents]->value = [_cin getBit:index];
         ants->numAntecedents++;
      }
      if (![_cout isFree:index]) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _cout;
         vars[ants->numAntecedents]->index = index;
         vars[ants->numAntecedents]->value = [_cout getBit:index];
         ants->numAntecedents++;
      }
   }
   else if (assignment->var == _z){
      if (![_x isFree:index]) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _x;
         vars[ants->numAntecedents]->index = index;
         vars[ants->numAntecedents]->value = [_x getBit:index];
         ants->numAntecedents++;
      }
      if (![_y isFree:index]) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _y;
         vars[ants->numAntecedents]->index = index;
         vars[ants->numAntecedents]->value = [_y getBit:index];
         ants->numAntecedents++;
      }
      if (![_cin isFree:index]) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _cin;
         vars[ants->numAntecedents]->index = index;
         vars[ants->numAntecedents]->value = [_cin getBit:index];
         ants->numAntecedents++;
      }
      if (![_cout isFree:index]) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _cout;
         vars[ants->numAntecedents]->index = index;
         vars[ants->numAntecedents]->value = [_cout getBit:index];
         ants->numAntecedents++;
      }
   }
   else if (assignment->var == _cin){
      if (![_x isFree:index]) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _x;
         vars[ants->numAntecedents]->index = index;
         vars[ants->numAntecedents]->value = [_x getBit:index];
         ants->numAntecedents++;
      }
      if (![_y isFree:index]) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _y;
         vars[ants->numAntecedents]->index = index;
         vars[ants->numAntecedents]->value = [_y getBit:index];
         ants->numAntecedents++;
      }
      if (![_z isFree:index]) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _z;
         vars[ants->numAntecedents]->index = index;
         vars[ants->numAntecedents]->value = [_z getBit:index];
         ants->numAntecedents++;
      }
      if (![_cout isFree:index]) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _cout;
         vars[ants->numAntecedents]->index = index;
         vars[ants->numAntecedents]->value = [_cout getBit:index];
         ants->numAntecedents++;
      }
      if ((index > 0) && ![_cout isFree:index-1]) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _cout;
         vars[ants->numAntecedents]->index = index-1;
         vars[ants->numAntecedents]->value = [_cout getBit:index-1];
         ants->numAntecedents++;
      }
   }
   else if (assignment->var == _cout){
      if (![_x isFree:index]) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _x;
         vars[ants->numAntecedents]->index = index;
         vars[ants->numAntecedents]->value = [_x getBit:index];
         ants->numAntecedents++;
      }
      if (![_y isFree:index]) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _y;
         vars[ants->numAntecedents]->index = index;
         vars[ants->numAntecedents]->value = [_y getBit:index];
         ants->numAntecedents++;
      }
      if (![_z isFree:index]) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _z;
         vars[ants->numAntecedents]->index = index;
         vars[ants->numAntecedents]->value = [_z getBit:index];
         ants->numAntecedents++;
      }
      if (![_cin isFree:index]) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _cin;
         vars[ants->numAntecedents]->index = index;
         vars[ants->numAntecedents]->value = [_cin getBit:index];
         ants->numAntecedents++;
      }
      if ((index+1 < [_cin bitLength]) && ![_cin isFree:index+1] ) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _cin;
         vars[ants->numAntecedents]->index = index+1;
         vars[ants->numAntecedents]->value = [_cin getBit:index+1];
         ants->numAntecedents++;
      }
   }
//   if(ants->numAntecedents==0)
//      NSLog(@"Unable to find antecedents in CPBitADD constraint");
   return ants;
}

-(void) post
{
   //   NSLog(@"Bit Sum Constraint Posted");
   [self propagate];
   if (![_x bound])
      [_x whenChangePropagate: self];
   if (![_y bound])
      [_y whenChangePropagate: self];
   if (![_z bound])
      [_z whenChangePropagate: self];
   [self propagate];
}
-(void) propagate
{//   NSLog(@"Bit Sum Constraint Propagated");
   
   unsigned int wordLength = [_x getWordLength];
   
//   ORUInt bitLength = [_x bitLength];
//   if (bitLength < 32) {
//      NSLog(@"Short Bit Vector in Add");
//   }
   
   
   unsigned int change = true;
   
   TRUInt* xLow;
   TRUInt* xUp;
   TRUInt* yLow;
   TRUInt* yUp;
   TRUInt* zLow;
   TRUInt* zUp;
   TRUInt* cinLow;
   TRUInt* cinUp;
   TRUInt* coutLow;
   TRUInt* coutUp;
   
//   ORUInt inconsistencyFound = 0;
   
   [_x getUp:&xUp andLow:&xLow];
   [_y getUp:&yUp andLow:&yLow];
   [_z getUp:&zUp andLow:&zLow];
   [_cin getUp:&cinUp andLow:&cinLow];
   [_cout getUp:&coutUp andLow:&coutLow];
   
#ifdef BIT_CONSISTENT_CHECK
   ORUInt xSetBitsBefore = numSetBits(xLow, xUp, wordLength);
   ORUInt ySetBitsBefore = numSetBits(yLow, yUp, wordLength);
   ORUInt zSetBitsBefore = numSetBits(zLow, zUp, wordLength);
   ORUInt cinSetBitsBefore = numSetBits(cinLow, cinUp, wordLength);
   ORUInt coutSetBitsBefore = numSetBits(coutLow, coutUp, wordLength);
#endif
   
   unsigned int* prevXUp = alloca(sizeof(unsigned int)*wordLength);
   unsigned int* prevXLow  = alloca(sizeof(unsigned int)*wordLength);
   unsigned int* prevYUp = alloca(sizeof(unsigned int)*wordLength);
   unsigned int* prevYLow  = alloca(sizeof(unsigned int)*wordLength);
   unsigned int* prevZUp = alloca(sizeof(unsigned int)*wordLength);
   unsigned int* prevZLow  = alloca(sizeof(unsigned int)*wordLength);
   unsigned int* prevCinUp = alloca(sizeof(unsigned int)*wordLength);
   unsigned int* prevCinLow  = alloca(sizeof(unsigned int)*wordLength);
   unsigned int* prevCoutUp = alloca(sizeof(unsigned int)*wordLength);
   unsigned int* prevCoutLow  = alloca(sizeof(unsigned int)*wordLength);
   
   
   unsigned int* newXUp = alloca(sizeof(unsigned int)*wordLength);
   unsigned int* newXLow  = alloca(sizeof(unsigned int)*wordLength);
   unsigned int* newYUp = alloca(sizeof(unsigned int)*wordLength);
   unsigned int* newYLow  = alloca(sizeof(unsigned int)*wordLength);
   unsigned int* newZUp = alloca(sizeof(unsigned int)*wordLength);
   unsigned int* newZLow  = alloca(sizeof(unsigned int)*wordLength);
   unsigned int* newCinUp = alloca(sizeof(unsigned int)*wordLength);
   unsigned int* newCinLow  = alloca(sizeof(unsigned int)*wordLength);
   unsigned int* newCoutUp = alloca(sizeof(unsigned int)*wordLength);
   unsigned int* newCoutLow  = alloca(sizeof(unsigned int)*wordLength);
   
   unsigned int* shiftedCinUp = alloca(sizeof(unsigned int)*wordLength);
   unsigned int* shiftedCinLow  = alloca(sizeof(unsigned int)*wordLength);
   unsigned int* shiftedCoutUp = alloca(sizeof(unsigned int)*wordLength);
   unsigned int* shiftedCoutLow  = alloca(sizeof(unsigned int)*wordLength);
   
   for(int i = 0; i<wordLength;i++){
      prevXUp[i] = newXUp[i] = xUp[i]._val;
      prevXLow[i] = newXLow[i] = xLow[i]._val;
      prevYUp[i] = newYUp[i] = yUp[i]._val;
      prevYLow[i] = newYLow[i] = yLow[i]._val;
      prevZUp[i] = newZUp[i] = zUp[i]._val;
      prevZLow[i] = newZLow[i] = zLow[i]._val;
      
      //       newXUp[i] = xUp[i]._val;
      //       newXLow[i] = xLow[i]._val;
      //       newYUp[i] = yUp[i]._val;
      //       newYLow[i] = yLow[i]._val;
      //       newZUp[i] = zUp[i]._val;
      //       newZLow[i] = zLow[i]._val;
      
      prevCinUp[i] = newCinUp[i] = cinUp[i]._val;
      prevCinLow[i] = newCinLow[i] = cinLow[i]._val;
      prevCoutUp[i] = newCoutUp[i] = coutUp[i]._val;
      prevCoutLow[i] = newCoutLow[i] = coutLow[i]._val;
      
      //       newCinUp[i] = cinUp[i]._val;
      //       newCinLow[i] = cinLow[i]._val;
      //       newCoutUp[i] = coutUp[i]._val;
      //       newCoutLow[i] = coutLow[i]._val;
      
   }
   
#ifdef BIT_DEBUG
   NSLog(@"********************************************************");
   NSLog(@"propagating sum constraint");
   NSLog(@" Cin  =%@",_cin);
   NSLog(@" X    =%@",_x);
   NSLog(@"+Y    =%@",_y);
   NSLog(@"_______________________________________________________");
   NSLog(@" Z    =%@",_z);
   NSLog(@" Cout =%@\n\n",_cout);
   NSLog(@"\n\n");
#endif
   //   NSLog(@" Cin  =%@",bitvar2NSString(prevCinLow,prevCinUp, bitLength));
   //   NSLog(@" X    =%@",bitvar2NSString(prevXLow, prevXUp, bitLength));
   //   NSLog(@"+Y    =%@",bitvar2NSString(prevYLow, prevYUp, bitLength));
   //   NSLog(@"_______________________________________________________");
   //   NSLog(@" Z    =%@",bitvar2NSString(prevZLow, prevZUp, bitLength));
   //   NSLog(@" Cout =%@\n\n",bitvar2NSString(prevCoutLow, prevCoutUp, bitLength));
   
   
   while (change) {

//             NSLog(@"propagating sum constraint");
//             NSLog(@" Cin  =%@",bitvar2NSString(prevCinLow,prevCinUp, bitLength));
//             NSLog(@" X    =%@",bitvar2NSString(prevXLow, prevXUp, bitLength));
//             NSLog(@"+Y    =%@",bitvar2NSString(prevYLow, prevYUp, bitLength));
//             NSLog(@"_______________________________________________________");
//             NSLog(@" Z    =%@",bitvar2NSString(prevZLow, prevZUp, bitLength));
//             NSLog(@" Cout =%@\n\n",bitvar2NSString(prevCoutLow, prevCoutUp, bitLength));
      
      change = false;
      //      NSLog(@"top of iteration for sum constraint");
      //             NSLog(@" Cin  =%@",bitvar2NSString(prevCinLow,prevCinUp, bitLength));
      //             NSLog(@" X    =%@",bitvar2NSString(prevXLow, prevXUp, bitLength));
      //             NSLog(@"+Y    =%@",bitvar2NSString(prevYLow, prevYUp, bitLength));
      //             NSLog(@"_______________________________________________________");
      //             NSLog(@" Z    =%@",bitvar2NSString(prevZLow, prevZUp, bitLength));
      //             NSLog(@" Cout =%@\n\n",bitvar2NSString(prevCoutLow, prevCoutUp, bitLength));


      
      for(int i=0;i<wordLength;i++){
         //          NSLog(@"\ttop of shift iteration for sum constraint");
         //          NSLog(@"\t Cin  =%@",bitvar2NSString(prevCinLow,prevCinUp, bitLength));
         //          NSLog(@"\t X    =%@",bitvar2NSString(prevXLow, prevXUp, bitLength));
         //          NSLog(@"\t+Y    =%@",bitvar2NSString(prevYLow, prevYUp, bitLength));
         //          NSLog(@"\t_______________________________________________________");
         //          NSLog(@"\t Z    =%@",bitvar2NSString(prevZLow, prevZUp, bitLength));
         //          NSLog(@"\t Cout =%@\n\n",bitvar2NSString(prevCoutLow, prevCoutUp, bitLength));
         
         // Pasted shift constraint code to directly compute new CIN from the new COUT
         //          for(int j=0;j<wordLength;j++){
//         if (i < wordLength) {
            shiftedCinUp[i] = ~(ISFALSE(prevCinUp[i],prevCinLow[i])|((ISFALSE(prevCoutUp[i], prevCoutLow[i])<<1)));
            shiftedCinLow[i] = ISTRUE(prevCinUp[i],prevCinLow[i])|(ISTRUE(prevCoutUp[i], prevCoutLow[i])<<1);
            //         NSLog(@"i=%i",i+1/32);
            if(i > 0) {
               shiftedCinUp[i] &= ~(ISFALSE(prevCoutUp[i-1], prevCoutLow[i-1])>>31);
               shiftedCinLow[i] |= ISTRUE(prevCoutUp[i-1], prevCoutLow[i-1])>>31;
               //            NSLog(@"i=%i",i+1/32+1);
            }
            else{
               shiftedCinUp[i] &= ~(UP_MASK >> 31);
               shiftedCinLow[i] &= ~(UP_MASK >> 31);
            }
//         }
//         else{
//            shiftedCinUp[i] = 0;
//            shiftedCinLow[i] = 0;
//         }
      
//         if (i >= 0)   {
            shiftedCoutUp[i] = ~(ISFALSE(prevCoutUp[i],prevCoutLow[i])|(ISFALSE(prevCinUp[i], prevCinLow[i])>>1));
            shiftedCoutLow[i] = ISTRUE(prevCoutUp[i],prevCoutLow[i])|(ISTRUE(prevCinUp[i], prevCinLow[i])>>1);
            //         NSLog(@"i=%i",i-1/32);
//            if((i-1) >= 0) {
            if((i+1)<wordLength){
               shiftedCoutUp[i] &= ~(ISFALSE(prevCinUp[i+1],prevCinLow[i+1])<<31);
               shiftedCoutLow[i] |= ISTRUE(prevCinUp[i+1],prevCinLow[i+1])<<31;
               //            NSLog(@"i=%i",i-(int)_places/32-1);
            }
//         }
//         else{
//            shiftedCoutUp[i] = prevCoutUp[i];
//            shiftedCoutLow[i] = prevCoutLow[i];
//         }
         change |= shiftedCinUp[i] ^ prevCinUp[i];
         change |= shiftedCinLow[i] ^ prevCinLow[i];
         change |= shiftedCoutUp[i] ^ prevCoutUp[i];
         change |= shiftedCoutLow[i] ^ prevCoutLow[i];
         
//         ORUInt schange = 0;
//         schange |= shiftedCinUp[i] ^ prevCinUp[i];
//         schange |= shiftedCinLow[i] ^ prevCinLow[i];
//         schange |= shiftedCoutUp[i] ^ prevCoutUp[i];
//         schange |= shiftedCoutLow[i] ^ prevCoutLow[i];
//
//         
//         if(schange)
//            NSLog(@"shifted chagne");
         
//         if((shiftedCoutLow[0] & 0x80000000)!=0){
//            NSLog(@"MSB set to 1");
//         }

         
         //             //testing for internal consistency
         //             upXORlow = shiftedCinUp[i] ^ shiftedCinLow[i];
         //             inconsistencyFound |= (upXORlow&(~shiftedCinUp[i]))&(upXORlow & shiftedCinLow[i]);
         //#ifdef BIT_DEBUG
         //             if (inconsistencyFound){
         //                NSLog(@"Inconsistency in Bitwise sum constraint in (shifted) Carry In.\n");
         //
         //                          NSLog(@" Cin  =%@",bitvar2NSString(prevCinLow,prevCinUp, bitLength));
         //                          NSLog(@" X    =%@",bitvar2NSString(prevXLow, prevXUp, bitLength));
         //                          NSLog(@"+Y    =%@",bitvar2NSString(prevYLow, prevYUp, bitLength));
         //                          NSLog(@"_______________________________________________________");
         //                          NSLog(@" Z    =%@",bitvar2NSString(prevZLow, prevZUp, bitLength));
         //                          NSLog(@" Cout =%@\n\n",bitvar2NSString(prevCoutLow, prevCoutUp, bitLength));
         //
         //                          NSLog(@" Cin  =%@",bitvar2NSString(shiftedCinLow,shiftedCinUp, bitLength));
         //                          NSLog(@" X    =%@",bitvar2NSString(prevXLow, prevXUp, bitLength));
         //                          NSLog(@"+Y    =%@",bitvar2NSString(prevYLow, prevYUp, bitLength));
         //                          NSLog(@"_______________________________________________________");
         //                          NSLog(@" Z    =%@",bitvar2NSString(prevZLow, prevZUp, bitLength));
         //                          NSLog(@" Cout =%@\n\n",bitvar2NSString(shiftedCoutLow, shiftedCoutUp, bitLength));
         //                failNow();
         //          }
         //#endif
         
         prevCoutLow[i] = shiftedCoutLow[i];
         prevCoutUp[i] = shiftedCoutUp[i];
         prevCinLow[i] = shiftedCinLow[i];
         prevCinUp[i] = shiftedCinUp[i];
         
         
         //          NSLog(@" Cin  =%@",bitvar2NSString(prevCinLow,prevCinUp, bitLength));
         //          NSLog(@" X    =%@",bitvar2NSString(prevXLow, prevXUp, bitLength));
         //          NSLog(@"+Y    =%@",bitvar2NSString(prevYLow, prevYUp, bitLength));
         //          NSLog(@"_______________________________________________________");
         //          NSLog(@" Z    =%@",bitvar2NSString(prevZLow, prevZUp, bitLength));
         //          NSLog(@" Cout =%@\n\n",bitvar2NSString(prevCoutLow, prevCoutUp, bitLength));
         
         //commented out on 2/11/13 by GAJ (vars are checked below)
                   //Chgeck consistency of new domain for Cin variable.
//                      inconsistencyFound |= ((prevXLow[i] & ~prevXUp[i]) |
//                                             (prevXLow[i] & prevYLow[i] & ~prevCoutUp[i]) |
//                                             (prevXLow[i] & ~prevZUp[i] & ~prevCoutUp[i]) |
//                                             (~prevXUp[i] & ~prevYUp[i] & prevCoutLow[i]) |
//                                             (~prevXUp[i] & prevZLow[i] & prevCoutLow[i]) |
//                                             (prevYLow[i] & ~prevYUp[i]) |
//                                             (prevYLow[i] & ~prevZUp[i] & ~prevCoutUp[i]) |
//                                             (~prevYUp[i] & prevZLow[i] & prevCoutLow[i]) |
//                                             (prevZLow[i] & ~prevZUp[i]) |
//                                             (prevCoutLow[i] & ~prevCoutUp[i]));
         
         //          }
         
         
         // End of pasted code
         
         //          if(![_x bound]){
         newXUp[i] = prevXUp[i] &
         ~((~prevCinLow[i] & ~prevCinUp[i] & ~prevYLow[i] & ~prevYUp[i] & ~prevZLow[i] & ~prevZUp[i] & ~prevCoutLow[i]) |
           (~prevCinLow[i] & ~prevCinUp[i] & prevYLow[i] & prevYUp[i] & prevZLow[i] & prevZUp[i] & ~prevCoutLow[i]) |
           (~prevCinLow[i] & ~prevYLow[i] & ~prevZLow[i] & ~prevZUp[i] & ~prevCoutLow[i] & ~prevCoutUp[i]) |
           (~prevCinLow[i] & prevYLow[i] & prevYUp[i] & prevZUp[i] & ~prevCoutLow[i] & ~prevCoutUp[i]) |
           (prevCinLow[i] & prevCinUp[i] & ~prevYLow[i] & ~prevYUp[i] & prevZLow[i] & prevZUp[i] & ~prevCoutLow[i]) |
           (prevCinLow[i] & prevCinUp[i] & ~prevYLow[i] & prevZUp[i] & ~prevCoutLow[i] & ~prevCoutUp[i]) |
           (prevCinLow[i] & prevCinUp[i] & prevYLow[i] & prevYUp[i] & ~prevZLow[i] & ~prevZUp[i] & prevCoutUp[i]));
         
         newXLow[i] = prevXLow[i] |
         ((~prevCinLow[i] & ~prevCinUp[i] & ~prevYLow[i] & ~prevYUp[i] & prevZLow[i] & prevZUp[i] & ~prevCoutLow[i]) |
          (~prevCinLow[i] & ~prevCinUp[i] & prevYLow[i] & prevYUp[i] & ~prevZLow[i] & ~prevZUp[i] & prevCoutUp[i]) |
          (~prevCinLow[i] & ~prevCinUp[i] & prevYUp[i] & ~prevZLow[i] & prevCoutLow[i] & prevCoutUp[i]) |
          (prevCinLow[i] & prevCinUp[i] & ~prevYLow[i] & ~prevYUp[i] & ~prevZLow[i] & ~prevZUp[i] & prevCoutUp[i]) |
          (prevCinLow[i] & prevCinUp[i] & prevYLow[i] & prevYUp[i] & prevZLow[i] & prevZUp[i] & prevCoutUp[i]) |
          (prevCinUp[i] & ~prevYLow[i] & ~prevYUp[i] & ~prevZLow[i] & prevCoutLow[i] & prevCoutUp[i]) |
          (prevCinUp[i] & prevYUp[i] & prevZLow[i] & prevZUp[i] & prevCoutLow[i] & prevCoutUp[i]));
         
         
         //          }
         
         //          if(![_y bound]){
         newYUp[i] = prevYUp[i] &
         ~((~prevCinLow[i] & ~prevCinUp[i] & ~prevXLow[i] & ~prevXUp[i] & ~prevZLow[i] & ~prevZUp[i] & ~prevCoutLow[i]) |
           (~prevCinLow[i] & ~prevCinUp[i] & prevXLow[i] & prevXUp[i] & prevZLow[i] & prevZUp[i] & ~prevCoutLow[i]) |
           (~prevCinLow[i] & ~prevXLow[i] & ~prevZLow[i] & ~prevZUp[i] & ~prevCoutLow[i] & ~prevCoutUp[i]) |
           (~prevCinLow[i] & prevXLow[i] & prevXUp[i] & prevZUp[i] & ~prevCoutLow[i] & ~prevCoutUp[i]) |
           (prevCinLow[i] & prevCinUp[i] & ~prevXLow[i] & ~prevXUp[i] & prevZLow[i] & prevZUp[i] & ~prevCoutLow[i]) |
           (prevCinLow[i] & prevCinUp[i] & ~prevXLow[i] & prevZUp[i] & ~prevCoutLow[i] & ~prevCoutUp[i]) |
           (prevCinLow[i] & prevCinUp[i] & prevXLow[i] & prevXUp[i] & ~prevZLow[i] & ~prevZUp[i] & prevCoutUp[i]));
         
         newYLow[i] = prevYLow[i] |
         ((~prevCinLow[i] & ~prevCinUp[i] & ~prevXLow[i] & ~prevXUp[i] & prevZLow[i] & prevZUp[i] & ~prevCoutLow[i]) |
          (~prevCinLow[i] & ~prevCinUp[i] & prevXLow[i] & prevXUp[i] & ~prevZLow[i] & ~prevZUp[i] & prevCoutUp[i]) |
          (~prevCinLow[i] & ~prevCinUp[i] & prevXUp[i] & ~prevZLow[i] & prevCoutLow[i] & prevCoutUp[i]) |
          (prevCinLow[i] & prevCinUp[i] & ~prevXLow[i] & ~prevXUp[i] & ~prevZLow[i] & ~prevZUp[i] & prevCoutUp[i]) |
          (prevCinLow[i] & prevCinUp[i] & prevXLow[i] & prevXUp[i] & prevZLow[i] & prevZUp[i] & prevCoutUp[i]) |
          (prevCinUp[i] & ~prevXLow[i] & ~prevXUp[i] & ~prevZLow[i] & prevCoutLow[i] & prevCoutUp[i]) |
          (prevCinUp[i] & prevXUp[i] & prevZLow[i] & prevZUp[i] & prevCoutLow[i] & prevCoutUp[i]));
         
         
         //          }
         
         
         //          if(![_z bound]){
         newZUp[i] = prevZUp[i] &
         ~((~prevCoutLow[i] & ~prevCinLow[i] & ~prevCinUp[i] & ~prevXLow[i] & ~prevXUp[i] & ~prevYLow[i] & ~prevYUp[i]) |
           (prevCoutLow[i] & prevCoutUp[i] & ~prevCinLow[i] & ~prevCinUp[i] & prevXUp[i] & prevYUp[i]) |
           (prevCoutLow[i] & prevCoutUp[i] & prevCinUp[i] & ~prevXLow[i] & ~prevXUp[i] & prevYUp[i]) |
           (prevCoutLow[i] & prevCoutUp[i] & prevCinUp[i] & prevXUp[i] & ~prevYLow[i] & ~prevYUp[i]) |
           (prevCoutUp[i] & ~prevCinLow[i] & ~prevCinUp[i] & prevXLow[i] & prevXUp[i] & prevYLow[i] & prevYUp[i]) |
           (prevCoutUp[i] & prevCinLow[i] & prevCinUp[i] & ~prevXLow[i] & ~prevXUp[i] & prevYLow[i] & prevYUp[i]) |
           (prevCoutUp[i] & prevCinLow[i] & prevCinUp[i] & prevXLow[i] & prevXUp[i] & ~prevYLow[i] & ~prevYUp[i]));
         
         
         newZLow[i] = prevZLow[i] |
         ((~prevCoutLow[i] & ~prevCoutUp[i] & ~prevCinLow[i] & ~prevXLow[i] & prevYLow[i] & prevYUp[i]) |
          (~prevCoutLow[i] & ~prevCoutUp[i] & ~prevCinLow[i] & prevXLow[i] & prevXUp[i] & ~prevYLow[i]) |
          (~prevCoutLow[i] & ~prevCoutUp[i] & prevCinLow[i] & prevCinUp[i] & ~prevXLow[i] & ~prevYLow[i]) |
          (~prevCoutLow[i] & ~prevCinLow[i] & ~prevCinUp[i] & ~prevXLow[i] & ~prevXUp[i] & prevYLow[i] & prevYUp[i]) |
          (~prevCoutLow[i] & ~prevCinLow[i] & ~prevCinUp[i] & prevXLow[i] & prevXUp[i] & ~prevYLow[i] & ~prevYUp[i]) |
          (~prevCoutLow[i] & prevCinLow[i] & prevCinUp[i] & ~prevXLow[i] & ~prevXUp[i] & ~prevYLow[i] & ~prevYUp[i]) |
          (prevCoutUp[i] & prevCinLow[i] & prevCinUp[i] & prevXLow[i] & prevXUp[i] & prevYLow[i] & prevYUp[i]));
         
         //Check consistency of new domain for Z variable
//         inconsistencyFound |=((prevCoutLow[i] & ~prevCoutUp[i]) |
//                               (prevCoutLow[i] & ~prevCinUp[i] & ~prevXUp[i]) |
//                               (prevCoutLow[i] & ~prevCinUp[i] & ~prevYUp[i]) |
//                               (prevCoutLow[i] & ~prevXUp[i] & ~prevYUp[i]) |
//                               (~prevCoutUp[i] & prevCinLow[i] & prevXLow[i]) |
//                               (~prevCoutUp[i] & prevCinLow[i] & prevYLow[i]) |
//                               (~prevCoutUp[i] & prevXLow[i] & prevYLow[i]) |
//                               (prevCinLow[i] & ~prevCinUp[i]) |
//                               (prevXLow[i] & ~prevXUp[i]) |
//                               (prevYLow[i] & ~prevYUp[i]));
         
         //          }
         
         //          if(![_cin bound]){
         newCinUp[i] = prevCinUp[i] &
         ~((~prevXLow[i] & ~prevXUp[i] & ~prevYLow[i] & ~prevYUp[i] & ~prevZLow[i] & ~prevZUp[i] & ~prevCoutLow[i]) |
           (~prevXLow[i] & ~prevXUp[i] & prevYLow[i] & prevYUp[i] & prevZLow[i] & prevZUp[i] & ~prevCoutLow[i]) |
           (~prevXLow[i] & ~prevYLow[i] & ~prevZLow[i] & ~prevZUp[i] & ~prevCoutLow[i] & ~prevCoutUp[i]) |
           (~prevXLow[i] & prevYLow[i] & prevYUp[i] & prevZUp[i] & ~prevCoutLow[i] & ~prevCoutUp[i]) |
           (prevXLow[i] & prevXUp[i] & ~prevYLow[i] & ~prevYUp[i] & prevZLow[i] & prevZUp[i] & ~prevCoutLow[i]) |
           (prevXLow[i] & prevXUp[i] & ~prevYLow[i] & prevZUp[i] & ~prevCoutLow[i] & ~prevCoutUp[i]) |
           (prevXLow[i] & prevXUp[i] & prevYLow[i] & prevYUp[i] & ~prevZLow[i] & ~prevZUp[i] & prevCoutUp[i]));
         
         
         newCinLow[i] = prevCinLow[i] |
         ((~prevXLow[i] & ~prevXUp[i] & ~prevYLow[i] & ~prevYUp[i] & prevZLow[i] & prevZUp[i] & ~prevCoutLow[i]) |
          (~prevXLow[i] & ~prevXUp[i] & prevYLow[i] & prevYUp[i] & ~prevZLow[i] & ~prevZUp[i] & prevCoutUp[i]) |
          (~prevXLow[i] & ~prevXUp[i] & prevYUp[i] & ~prevZLow[i] & prevCoutLow[i] & prevCoutUp[i]) |
          (prevXLow[i] & prevXUp[i] & ~prevYLow[i] & ~prevYUp[i] & ~prevZLow[i] & ~prevZUp[i] & prevCoutUp[i]) |
          (prevXLow[i] & prevXUp[i] & prevYLow[i] & prevYUp[i] & prevZLow[i] & prevZUp[i] & prevCoutUp[i]) |
          (prevXUp[i] & ~prevYLow[i] & ~prevYUp[i] & ~prevZLow[i] & prevCoutLow[i] & prevCoutUp[i]) |
          (prevXUp[i] & prevYUp[i] & prevZLow[i] & prevZUp[i] & prevCoutLow[i] & prevCoutUp[i]));
         
         //Chgeck consistency of new domain for Cin variable.
         //AB'+ACH'+AF'H'+B'CE+B'D'G+B'EG+CD'+CF'H'+D'EG+EF'+GH'
//         inconsistencyFound |= ((prevXLow[i] & ~prevXUp[i]) |
//                                (prevXLow[i] & prevYLow[i] & ~prevCoutUp[i]) |
//                                (prevXLow[i] & ~prevZUp[i] & ~prevCoutUp[i]) |
//                                (~prevXUp[i] & ~prevYUp[i] & prevCoutLow[i]) |
//                                (~prevXUp[i] & prevZLow[i] & prevCoutLow[i]) |
//                                (prevYLow[i] & ~prevYUp[i]) |
//                                (prevYLow[i] & ~prevZUp[i] & ~prevCoutUp[i]) |
//                                (~prevYUp[i] & prevZLow[i] & prevCoutLow[i]) |
//                                (prevZLow[i] & ~prevZUp[i]) |
//                                (prevCoutLow[i] & ~prevCoutUp[i]));
         
         
         
         
         //          }
         
         //          if(![_cout bound]){
         newCoutUp[i] = prevCoutUp[i] &
         ~((~prevZLow[i] & ~prevCinLow[i] & ~prevCinUp[i] & ~prevXLow[i] & ~prevXUp[i] & ~prevYLow[i]) |
           (~prevZLow[i] & ~prevCinLow[i] & ~prevCinUp[i] & ~prevXLow[i] & ~prevYLow[i] & ~prevYUp[i]) |
           (~prevZLow[i] & ~prevCinLow[i] & ~prevXLow[i] & ~prevXUp[i] & ~prevYLow[i] & ~prevYUp[i]) |
           (prevZLow[i] & prevZUp[i] & ~prevCinLow[i] & ~prevCinUp[i] & ~prevXLow[i] & prevYUp[i]) |
           (prevZLow[i] & prevZUp[i] & ~prevCinLow[i] & ~prevCinUp[i] & prevXUp[i] & ~prevYLow[i]) |
           (prevZLow[i] & prevZUp[i] & ~prevCinLow[i] & ~prevXLow[i] & ~prevXUp[i] & prevYUp[i]) |
           (prevZLow[i] & prevZUp[i] & ~prevCinLow[i] & prevXUp[i] & ~prevYLow[i] & ~prevYUp[i]) |
           (prevZLow[i] & prevZUp[i] & prevCinUp[i] & ~prevXLow[i] & ~prevXUp[i] & ~prevYLow[i]) |
           (prevZLow[i] & prevZUp[i] & prevCinUp[i] & ~prevXLow[i] & ~prevYLow[i] & ~prevYUp[i]) |
           (prevZUp[i] & ~prevCinLow[i] & ~prevCinUp[i] & ~prevXLow[i] & ~prevXUp[i] & prevYUp[i]) |
           (prevZUp[i] & ~prevCinLow[i] & ~prevCinUp[i] & prevXUp[i] & ~prevYLow[i] & ~prevYUp[i]) |
           (prevZUp[i] & prevCinUp[i] & ~prevXLow[i] & ~prevXUp[i] & ~prevYLow[i] & ~prevYUp[i]));
         
         newCoutLow[i] = prevCoutLow[i] |
         ((~prevZLow[i] & ~prevZUp[i] & ~prevCinLow[i] & prevXLow[i] & prevXUp[i] & prevYUp[i]) |
          (~prevZLow[i] & ~prevZUp[i] & ~prevCinLow[i] & prevXUp[i] & prevYLow[i] & prevYUp[i]) |
          (~prevZLow[i] & ~prevZUp[i] & prevCinLow[i] & prevCinUp[i] & ~prevXLow[i] & prevYUp[i]) |
          (~prevZLow[i] & ~prevZUp[i] & prevCinLow[i] & prevCinUp[i] & prevXUp[i] & ~prevYLow[i]) |
          (~prevZLow[i] & ~prevZUp[i] & prevCinUp[i] & ~prevXLow[i] & prevYLow[i] & prevYUp[i]) |
          (~prevZLow[i] & ~prevZUp[i] & prevCinUp[i] & prevXLow[i] & prevXUp[i] & ~prevYLow[i]) |
          (~prevZLow[i] & ~prevCinLow[i] & prevXLow[i] & prevXUp[i] & prevYLow[i] & prevYUp[i]) |
          (~prevZLow[i] & prevCinLow[i] & prevCinUp[i] & ~prevXLow[i] & prevYLow[i] & prevYUp[i]) |
          (~prevZLow[i] & prevCinLow[i] & prevCinUp[i] & prevXLow[i] & prevXUp[i] & ~prevYLow[i]) |
          (prevZUp[i] & prevCinLow[i] & prevCinUp[i] & prevXLow[i] & prevXUp[i] & prevYUp[i]) |
          (prevZUp[i] & prevCinLow[i] & prevCinUp[i] & prevXUp[i] & prevYLow[i] & prevYUp[i]) |
          (prevZUp[i] & prevCinUp[i] & prevXLow[i] & prevXUp[i] & prevYLow[i] & prevYUp[i]));
         
//         if(i==4){
//            NSLog(@"Finished last word in bitvector");
//         }

         //         }
//         failure[i] = 0;
//         upXORlow[i] = newXUp[i] ^ newXLow[i];
//         failure[i] |= (upXORlow[i] & (~newXUp[i])) & (upXORlow[i] & newXLow[i]);
//         inconsistencyFound |= (upXORlow[i]&(~newXUp[i]))&(upXORlow[i] & newXLow[i]);
//         upXORlow[i] = newYUp[i] ^ newYLow[i];
//         failure[i] |= (upXORlow[i] & (~newYUp[i])) & (upXORlow[i] & newYLow[i]);
//         inconsistencyFound |= (upXORlow[i]&(~newYUp[i]))&(upXORlow[i] & newYLow[i]);
//         upXORlow[i] = newZUp[i] ^ newZLow[i];
//         failure[i] |= (upXORlow[i] & (~newZUp[i])) & (upXORlow[i] & newZLow[i]);
//         inconsistencyFound |= (upXORlow[i]&(~newXUp[i]))&(upXORlow[i] & newXLow[i]);
//         upXORlow[i] = newCinUp[i] ^ newCinLow[i];
//         failure[i] |= (upXORlow[i] & (~newCinUp[i])) & (upXORlow[i] & newCinLow[i]);
//         inconsistencyFound |= (upXORlow[i]&(~newCinUp[i]))&(upXORlow[i] & newCinLow[i]);
//         upXORlow[i] = newCoutUp[i] ^ newCoutLow[i];
//         failure[i] |= (upXORlow[i] & (~newCoutUp[i])) & (upXORlow[i] & newCoutLow[i]);
//         inconsistencyFound |= (upXORlow[i]&(~newCoutUp[i]))&(upXORlow[i] & newCoutLow[i]);
         
         //          //Check consistency of new domain for X variable
//                   inconsistencyFound |= ((prevCinLow[i] & ~prevCinUp[i]) |
//                                         (prevCinLow[i] & prevYLow[i] & ~prevCoutUp[i]) |
//                                         (prevCinLow[i] & ~prevZUp[i] & ~prevCoutUp[i]) |
//                                         (~prevCinUp[i] & ~prevYUp[i] & prevCoutLow[i]) |
//                                         (~prevCinUp[i] & prevZLow[i] & prevCoutLow[i]) |
//                                         (prevYLow[i] & ~prevYUp[i]) |
//                                         (prevYLow[i] & ~prevZUp[i] & ~prevCoutUp[i]) |
//                                         (~prevYUp[i] & prevZLow[i] & prevCoutLow[i]) |
//                                         (prevZLow[i] & ~prevZUp[i]) |
//                                         (prevCoutLow[i] & ~prevCoutUp[i]));
         //#ifdef BIT_DEBUG
         //          if (inconsistencyFound){
         //             NSLog(@"Logical inconsistency in Bitwise sum constraint variable x.\n");
         //             NSLog(@"In the %d th word: %x\n\n",i,inconsistencyFound);
         //             NSLog(@" Cin  =%@\t\t Cin  =%@",bitvar2NSString(prevCinLow,prevCinUp, bitLength),bitvar2NSString(newCinLow, newCinUp, bitLength));
         //             NSLog(@" X    =%@\t\t X    =%@",bitvar2NSString(prevXLow, prevXUp, bitLength),bitvar2NSString(newXLow, newXUp, bitLength));
         //             NSLog(@"+Y    =%@\t\t+Y    =%@",bitvar2NSString(prevYLow, prevYUp, bitLength),bitvar2NSString(newYLow, newYUp, bitLength));
         //             NSLog(@"_____________________________________________________________________________________________________________________________________________________");
         //             NSLog(@" Z    =%@\t\t Z    =%@",bitvar2NSString(prevZLow, prevZUp, bitLength),bitvar2NSString(newZLow, newZUp, bitLength));
         //             NSLog(@" Cout =%@\t\t Cout =%@\n\n",bitvar2NSString(prevCoutLow, prevCoutUp, bitLength),bitvar2NSString(newCoutLow, newCoutUp, bitLength));
         //             failNow();
         //          }
         ////#endif
         //
         //          //testing for internal consistency
         //          upXORlow = newXUp[i] ^ newXLow[i];
         //          inconsistencyFound |= (upXORlow&(~newXUp[i]))&(upXORlow & newXLow[i]);
         ////#ifdef BIT_DEBUG
         //          if (inconsistencyFound){
         //             NSLog(@"Inconsistency in Bitwise sum constraint variable x.\n");
         //             NSLog(@"In the %d th word: %x\n\n",i,inconsistencyFound);
         //             NSLog(@" Cin  =%@\t\t Cin  =%@",bitvar2NSString(prevCinLow,prevCinUp, bitLength),bitvar2NSString(newCinLow, newCinUp, bitLength));
         //             NSLog(@" X    =%@\t\t X    =%@",bitvar2NSString(prevXLow, prevXUp, bitLength),bitvar2NSString(newXLow, newXUp, bitLength));
         //             NSLog(@"+Y    =%@\t\t+Y    =%@",bitvar2NSString(prevYLow, prevYUp, bitLength),bitvar2NSString(newYLow, newYUp, bitLength));
         //             NSLog(@"_____________________________________________________________________________________________________________________________________________________");
         //             NSLog(@" Z    =%@\t\t Z    =%@",bitvar2NSString(prevZLow, prevZUp, bitLength),bitvar2NSString(newZLow, newZUp, bitLength));
         //             NSLog(@" Cout =%@\t\t Cout =%@\n\n",bitvar2NSString(prevCoutLow, prevCoutUp, bitLength),bitvar2NSString(newCoutLow, newCoutUp, bitLength));
         //             failNow();
         //          }
         //#endif
         //          //Check consistency of new domain for Y variable
//                   inconsistencyFound |= ((prevCinLow[i] & ~prevCinUp[i]) |
//                                          (prevCinLow[i] & prevXLow[i] & ~prevCoutUp[i]) |
//                                          (prevCinLow[i] & ~prevZUp[i] & ~prevCoutUp[i]) |
//                                          (~prevCinUp[i] & ~prevXUp[i] & prevCoutLow[i]) |
//                                          (~prevCinUp[i] & prevZLow[i] & prevCoutLow[i]) |
//                                          (prevXLow[i] & ~prevXUp[i]) |
//                                          (prevXLow[i] & ~prevZUp[i] & ~prevCoutUp[i]) |
//                                          (~prevXUp[i] & prevZLow[i] & prevCoutLow[i]) |
//                                          (prevZLow[i] & ~prevZUp[i]) |
//                                          (prevCoutLow[i] & ~prevCoutUp[i]));
         //
         //
         //#ifdef BIT_DEBUG
         //          if (inconsistencyFound){
         //             NSLog(@"Inconsistency in Bitwise sum constraint variable y. [unstable sum constraint]\n");
         //             NSLog(@" Cin  =%@\t\t Cin  =%@",bitvar2NSString(prevCinLow,prevCinUp, wordLength),bitvar2NSString(newCinLow, newCinUp, wordLength));
         //             NSLog(@" X    =%@\t\t X    =%@",bitvar2NSString(prevXLow, prevXUp, wordLength),bitvar2NSString(newXLow, newXUp, wordLength));
         //             NSLog(@"+Y    =%@\t\t+Y    =%@",bitvar2NSString(prevYLow, prevYUp, wordLength),bitvar2NSString(newYLow, newYUp, wordLength));
         //             NSLog(@"_____________________________________________________________________________________________________________________________________________________");
         //             NSLog(@" Z    =%@\t\t Z    =%@",bitvar2NSString(prevZLow, prevZUp, wordLength),bitvar2NSString(newZLow, newZUp, wordLength));
         //             NSLog(@" Cout =%@\t\t Cout =%@\n\n",bitvar2NSString(prevCoutLow, prevCoutUp, wordLength),bitvar2NSString(newCoutLow, newCoutUp, wordLength));
         //             failNow();
         //          }
         ////#endif
         //
         //
         //          //testing for internal consistency
         //          upXORlow = newYUp[i] ^ newYLow[i];
         //          inconsistencyFound |= (upXORlow&(~newYUp[i]))&(upXORlow & newYLow[i]);
         ////#ifdef BIT_DEBUG
         //          if (inconsistencyFound){
         //             NSLog(@"Inconsistency in Bitwise sum constraint variable y. [unstable bitvar]\n");
         //             NSLog(@" Cin  =%@\t\t Cin  =%@",bitvar2NSString(prevCinLow,prevCinUp, wordLength),bitvar2NSString(newCinLow, newCinUp, wordLength));
         //             NSLog(@" X    =%@\t\t X    =%@",bitvar2NSString(prevXLow, prevXUp, wordLength),bitvar2NSString(newXLow, newXUp, wordLength));
         //             NSLog(@"+Y    =%@\t\t+Y    =%@",bitvar2NSString(prevYLow, prevYUp, wordLength),bitvar2NSString(newYLow, newYUp, wordLength));
         //             NSLog(@"_____________________________________________________________________________________________________________________________________________________");
         //             NSLog(@" Z    =%@\t\t Z    =%@",bitvar2NSString(prevZLow, prevZUp, wordLength),bitvar2NSString(newZLow, newZUp, wordLength));
         //             NSLog(@" Cout =%@\t\t Cout =%@\n\n",bitvar2NSString(prevCoutLow, prevCoutUp, wordLength),bitvar2NSString(newCoutLow, newCoutUp, wordLength));
         //             failNow();
         //          }
         //#endif
         
         
         //#ifdef BIT_DEBUG
         //          if (inconsistencyFound){
         //             NSLog(@"Inconsistency in Bitwise sum constraint variable z [impossible bit pattern for variable].\n");
         //             NSLog(@" Cin  =%@\t\t Cin  =%@",bitvar2NSString(prevCinLow,prevCinUp, wordLength),bitvar2NSString(newCinLow, newCinUp, wordLength));
         //             NSLog(@" X    =%@\t\t X    =%@",bitvar2NSString(prevXLow, prevXUp, wordLength),bitvar2NSString(newXLow, newXUp, wordLength));
         //             NSLog(@"+Y    =%@\t\t+Y    =%@",bitvar2NSString(prevYLow, prevYUp, wordLength),bitvar2NSString(newYLow, newYUp, wordLength));
         //             NSLog(@"_____________________________________________________________________________________________________________________________________________________");
         //             NSLog(@" Z    =%@\t\t Z    =%@",bitvar2NSString(prevZLow, prevZUp, wordLength),bitvar2NSString(newZLow, newZUp, wordLength));
         //             NSLog(@" Cout =%@\t\t Cout =%@\n\n",bitvar2NSString(prevCoutLow, prevCoutUp, wordLength),bitvar2NSString(newCoutLow, newCoutUp, wordLength));
         //             failNow();
         //          }
         ////#endif
         //
         //          //testing for internal consistency
         //          upXORlow = newZUp[i] ^ newZLow[i];
         //          inconsistencyFound[i] |= (upXORlow&(~newZUp[i]))&(upXORlow & newZLow[i]);
         ////#ifdef BIT_DEBUG
         //          if (inconsistencyFound){
         //             NSLog(@"Inconsistency in Bitwise sum constraint variable z.\n");
         //             NSLog(@" Cin  =%@\t\t Cin  =%@",bitvar2NSString(prevCinLow,prevCinUp, wordLength),bitvar2NSString(newCinLow, newCinUp, wordLength));
         //             NSLog(@" X    =%@\t\t X    =%@",bitvar2NSString(prevXLow, prevXUp, wordLength),bitvar2NSString(newXLow, newXUp, wordLength));
         //             NSLog(@"+Y    =%@\t\t+Y    =%@",bitvar2NSString(prevYLow, prevYUp, wordLength),bitvar2NSString(newYLow, newYUp, wordLength));
         //             NSLog(@"_____________________________________________________________________________________________________________________________________________________");
         //             NSLog(@" Z    =%@\t\t Z    =%@",bitvar2NSString(prevZLow, prevZUp, wordLength),bitvar2NSString(newZLow, newZUp, wordLength));
         //             NSLog(@" Cout =%@\t\t Cout =%@\n\n",bitvar2NSString(prevCoutLow, prevCoutUp, wordLength),bitvar2NSString(newCoutLow, newCoutUp, wordLength));
         //             failNow();
         //          }
         //
         //          if (inconsistencyFound){
         //             NSLog(@"Inconsistency in Bitwise sum constraint in Carry In logical inconsistency.\n");
         //             NSLog(@" Cin  =%@\t\t Cin  =%@",bitvar2NSString(prevCinLow,prevCinUp, wordLength),bitvar2NSString(newCinLow, newCinUp, wordLength));
         //             NSLog(@" X    =%@\t\t X    =%@",bitvar2NSString(prevXLow, prevXUp, wordLength),bitvar2NSString(newXLow, newXUp, wordLength));
         //             NSLog(@"+Y    =%@\t\t+Y    =%@",bitvar2NSString(prevYLow, prevYUp, wordLength),bitvar2NSString(newYLow, newYUp, wordLength));
         //             NSLog(@"_____________________________________________________________________________________________________________________________________________________");
         //             NSLog(@" Z    =%@\t\t Z    =%@",bitvar2NSString(prevZLow, prevZUp, wordLength),bitvar2NSString(newZLow, newZUp, wordLength));
         //             NSLog(@" Cout =%@\t\t Cout =%@\n\n",bitvar2NSString(prevCoutLow, prevCoutUp, wordLength),bitvar2NSString(newCoutLow, newCoutUp, wordLength));
         //             failNow();
         //          }
         ////#endif
         //
         //
         //          //testing for internal consistency
         //          upXORlow[i] = newCinUp[i] ^ newCinLow[i];
         //          inconsistencyFound |= (upXORlow&(~newCinUp[i]))&(upXORlow & newCinLow[i]);
         ////#ifdef BIT_DEBUG
         //          if (inconsistencyFound){
         //             NSLog(@"Inconsistency in Bitwise sum constraint in Carry In.\n");
         //             NSLog(@" Cin  =%@\t\t Cin  =%@",bitvar2NSString(prevCinLow,prevCinUp, wordLength),bitvar2NSString(newCinLow, newCinUp, wordLength));
         //             NSLog(@" X    =%@\t\t X    =%@",bitvar2NSString(prevXLow, prevXUp, wordLength),bitvar2NSString(newXLow, newXUp, wordLength));
         //             NSLog(@"+Y    =%@\t\t+Y    =%@",bitvar2NSString(prevYLow, prevYUp, wordLength),bitvar2NSString(newYLow, newYUp, wordLength));
         //             NSLog(@"_____________________________________________________________________________________________________________________________________________________");
         //             NSLog(@" Z    =%@\t\t Z    =%@",bitvar2NSString(prevZLow, prevZUp, wordLength),bitvar2NSString(newZLow, newZUp, wordLength));
         //             NSLog(@" Cout =%@\t\t Cout =%@\n\n",bitvar2NSString(prevCoutLow, prevCoutUp, wordLength),bitvar2NSString(newCoutLow, newCoutUp, wordLength));
         //             failNow();
         //          }
         //#endif
         
         //Check consistency of new domain for Cout variable
//         inconsistencyFound |= ((prevZLow[i] & ~prevZUp[i]) |
//                                (prevZLow[i] & prevCinLow[i] & prevXLow[i] & ~prevYUp[i]) |
//                                (prevZLow[i] & prevCinLow[i] & ~prevXUp[i] & prevYLow[i]) |
//                                (prevZLow[i] & ~prevCinUp[i] & prevXLow[i] & prevYLow[i]) |
//                                (prevZLow[i] & ~prevCinUp[i] & ~prevXUp[i] & ~prevYUp[i]) |
//                                (~prevZUp[i] & prevCinLow[i] & prevXLow[i] & prevYLow[i]) |
//                                (~prevZUp[i] & prevCinLow[i] & ~prevXUp[i] & ~prevYUp[i]) |
//                                (~prevZUp[i] & ~prevCinUp[i] & prevXLow[i] & ~prevYUp[i]) |
//                                (~prevZUp[i] & ~prevCinUp[i] & ~prevXUp[i] & prevYLow[i]) |
//                                (prevCinLow[i] & ~prevCinUp[i]) |
//                                (prevXLow[i] & ~prevXUp[i]) |
//                                (prevYLow[i] & ~prevYUp[i]));
         
         
         //testing for internal consistency
//         upXORlow[i] = newCoutUp[i] ^ newCoutLow[i];
//         inconsistencyFound |= (upXORlow[i]&(~newCoutUp[i]))&(upXORlow[i] & newCoutLow[i]);
         
         //          if (inconsistencyFound){
         //#ifdef BIT_DEBUG
         //             NSLog(@"Inconsistency in Bitwise sum constraint in carry out.\n");
         //             NSLog(@" Cin  =%@\t\t Cin  =%@",bitvar2NSString(prevCinLow,prevCinUp, wordLength),bitvar2NSString(newCinLow, newCinUp, wordLength));
         //             NSLog(@" X    =%@\t\t X    =%@",bitvar2NSString(prevXLow, prevXUp, wordLength),bitvar2NSString(newXLow, newXUp, wordLength));
         //             NSLog(@"+Y    =%@\t\t+Y    =%@",bitvar2NSString(prevYLow, prevYUp, wordLength),bitvar2NSString(newYLow, newYUp, wordLength));
         //             NSLog(@"_____________________________________________________________________________________________________________________________________________________");
         //             NSLog(@" Z    =%@\t\t Z    =%@",bitvar2NSString(prevZLow, prevZUp, wordLength),bitvar2NSString(newZLow, newZUp, wordLength));
         //             NSLog(@" Cout =%@\t\t Cout =%@\n\n",bitvar2NSString(prevCoutLow, prevCoutUp, wordLength),bitvar2NSString(newCoutLow, newCoutUp, wordLength));
         //#endif
         //             failNow();
         //          }
         
         //          //Check consistency of new domain for Z variable
         //          inconsistencyFound |= (ISFALSE(newXUp[i], newXLow[i]) & ISFALSE(newCinUp[i], newCinLow[i]) & ISTRUE(newCoutUp[i], newCoutLow[i])) |
         //          (ISTRUE(newYUp[i], newYLow[i]) & ISTRUE(newCinUp[i], newCinLow[i]) & ISFALSE(newCoutUp[i], newCoutLow[i])) |
         //          (ISTRUE(newXUp[i], newXLow[i]) & ISTRUE(newCinUp[i], newCinLow[i]) & ISFALSE(newCoutUp[i], newCoutLow[i])) |
         //          (ISFALSE(newXUp[i], newXLow[i]) & ISFALSE(newYUp[i], newYLow[i]) & ISTRUE(newCoutUp[i], newCoutLow[i])) |
         //          (ISTRUE(newXUp[i], newXLow[i]) & ISTRUE(newYUp[i], newYLow[i]) & ISFALSE(newCoutUp[i], newCoutLow[i])) |
         //          (ISFALSE(newYUp[i], newYLow[i]) & ISFALSE(newCinUp[i], newCinLow[i]) & ISTRUE(newCoutUp[i], newCoutLow[i]));
         //
         //          if (inconsistencyFound){
         //             NSLog(@"Inconsistency in Bitwise sum constraint variable z [impossible bit pattern for variable].\n");
         //             failNow();
         //          }
         //
         //          //testing for internal consistency
         //          upXORlow = newZUp[i] ^ newZLow[i];
         //          inconsistencyFound |= (upXORlow&(~newZUp[i]))&(upXORlow & newZLow[i]);
         //          if (inconsistencyFound){
         //             NSLog(@"Inconsistency in Bitwise sum constraint variable z.\n");
         //             failNow();
         //          }
         
         
         change |= newXUp[i] ^ prevXUp[i];
         change |= newXLow[i] ^ prevXLow[i];
         change |= newYUp[i] ^ prevYUp[i];
         change |= newYLow[i] ^ prevYLow[i];
         change |= newZUp[i] ^ prevZUp[i];
         change |= newZLow[i] ^ prevZLow[i];
         change |= newCinUp[i] ^ prevCinUp[i];
         change |= newCinLow[i] ^ prevCinLow[i];
         change |= newCoutUp[i] ^ prevCoutUp[i];
         change |= newCoutLow[i] ^ prevCoutLow[i];
         
         //            if(change)
         //               NSLog(@"At least one variable has changed in propagation of Sum constraint");
         //
         
         //          NSLog(@" Cin  =%@\t\t Cin  =%@",bitvar2NSString(prevCinLow,prevCinUp, wordLength),bitvar2NSString(newCinLow, newCinUp, wordLength));
         //          NSLog(@" X    =%@\t\t X    =%@",bitvar2NSString(prevXLow, prevXUp, wordLength),bitvar2NSString(newXLow, newXUp, wordLength));
         //          NSLog(@"+Y    =%@\t\t+Y    =%@",bitvar2NSString(prevYLow, prevYUp, wordLength),bitvar2NSString(newYLow, newYUp, wordLength));
         //          NSLog(@"_____________________________________________________________________________________________________________________________________________________");
         //          NSLog(@" Z    =%@\t\t Z    =%@",bitvar2NSString(prevZLow, prevZUp, wordLength),bitvar2NSString(newZLow, newZUp, wordLength));
         //          NSLog(@" Cout =%@\t\t Cout =%@\n\n",bitvar2NSString(prevCoutLow, prevCoutUp, wordLength),bitvar2NSString(newCoutLow, newCoutUp, wordLength));
         
         
         
         
         
//         NSLog(@" Cin  =%@",bitvar2NSString(prevCinLow,prevCinUp, bitLength));
//         NSLog(@" X    =%@",bitvar2NSString(prevXLow, prevXUp, bitLength));
//         NSLog(@"+Y    =%@",bitvar2NSString(prevYLow, prevYUp, bitLength));
//         NSLog(@"_______________________________________________________");
//         NSLog(@" Z    =%@",bitvar2NSString(prevZLow, prevZUp, bitLength));
//         NSLog(@" Cout =%@\n\n",bitvar2NSString(prevCoutLow, prevCoutUp, bitLength));
         
//         if(((newCinLow[4] & 0x80000000)!=0) || ((newXLow[4] & 0x80000000)!=0) || ((newYLow[4] & 0x80000000)!=0) ||
//            ((newZLow[4] & 0x80000000)!=0) || ((newCoutLow[4] & 0x80000000)!=0)){
//            NSLog(@"MSB set to 1");
//         }
         
         _state[0] = newXUp;
         _state[1] = newXLow;
         _state[2] = newYUp;
         _state[3] = newYLow;
         _state[4] = newZUp;
         _state[5] = newZLow;
         _state[6] = newCinUp;
         _state[7] = newCinLow;
         _state[8] = newCoutUp;
         _state[9] = newCoutLow;
         
         ORBool xFail = checkDomainConsistency(_x, newXLow, newXUp, wordLength, self);
         
         ORBool yFail = checkDomainConsistency(_y, newYLow, newYUp, wordLength, self);
         
         ORBool zFail = checkDomainConsistency(_z, newZLow, newZUp, wordLength, self);
         
         ORBool cinFail = checkDomainConsistency(_cin, newCinLow, newCinUp, wordLength, self);
         
         ORBool coutFail = checkDomainConsistency(_cout, newCoutLow, newCoutUp, wordLength, self);
         
         if (xFail || yFail || zFail || cinFail || coutFail){
#ifdef BIT_DEBUG
            NSLog(@"Inconsistency in Bitwise sum constraint in (shifted) Carry In.\n");
            
            NSLog(@" Cin  =%@",bitvar2NSString(prevCinLow,prevCinUp, bitLength));
            NSLog(@" X    =%@",bitvar2NSString(prevXLow, prevXUp, bitLength));
            NSLog(@"+Y    =%@",bitvar2NSString(prevYLow, prevYUp, bitLength));
            NSLog(@"_______________________________________________________");
            NSLog(@" Z    =%@",bitvar2NSString(prevZLow, prevZUp, bitLength));
            NSLog(@" Cout =%@\n\n",bitvar2NSString(prevCoutLow, prevCoutUp, bitLength));
            
            NSLog(@" Cin  =%@",bitvar2NSString(shiftedCinLow,shiftedCinUp, bitLength));
            NSLog(@" X    =%@",bitvar2NSString(prevXLow, prevXUp, bitLength));
            NSLog(@"+Y    =%@",bitvar2NSString(prevYLow, prevYUp, bitLength));
            NSLog(@"_______________________________________________________");
            NSLog(@" Z    =%@",bitvar2NSString(prevZLow, prevZUp, bitLength));
            NSLog(@" Cout =%@\n\n",bitvar2NSString(shiftedCoutLow, shiftedCoutUp, bitLength));
#endif
            failNow();
         }
         prevXUp[i] = newXUp[i];
         prevXLow[i] = newXLow[i];
         prevYUp[i] = newYUp[i];
         prevYLow[i] = newYLow[i];
         prevZUp[i] = newZUp[i];
         prevZLow[i] = newZLow[i];
         prevCinUp[i] = newCinUp[i];
         prevCinLow[i] = newCinLow[i];
         prevCoutUp[i] = newCoutUp[i];
         prevCoutLow[i] = newCoutLow[i];


         //      //save intermediate state of variables
         [_x setUp:newXUp andLow:newXLow for:self];
         [_y setUp:newYUp andLow:newYLow for:self];
         [_z setUp:newZUp andLow:newZLow for:self];
         [_cin setUp:newCinUp andLow:newCinLow for:self];
         [_cout setUp:newCoutUp andLow:newCoutLow for:self];
         
      }
   }
   
//   NSLog(@"");
//   NSLog(@"x = %@",_x);
//   NSLog(@"y = %@",_y);
//   NSLog(@"z = %@",_z);
//   NSLog(@"newX = %@",bitvar2NSString(newXLow, newXUp, [_x bitLength]));
//   NSLog(@"newY = %@",bitvar2NSString(newYLow, newYUp, [_y bitLength]));
//   NSLog(@"newZ = %@\n\n",bitvar2NSString(newZLow, newZUp, [_z bitLength]));
   
   
//   NSLog(@" Cin  =%@",bitvar2NSString(newCinLow,newCinUp, bitLength));
//   NSLog(@" X    =%@",bitvar2NSString(newXLow, newXUp, bitLength));
//   NSLog(@"+Y    =%@",bitvar2NSString(newYLow, newYUp, bitLength));
//   NSLog(@"_______________________________________________________");
//   NSLog(@" Z    =%@",bitvar2NSString(newZLow, newZUp, bitLength));
//   NSLog(@" Cout =%@\n\n",bitvar2NSString(newCoutLow, newCoutUp, bitLength));

   
   _state[0] = newXUp;
   _state[1] = newXLow;
   _state[2] = newYUp;
   _state[3] = newYLow;
   _state[4] = newZUp;
   _state[5] = newZLow;
   _state[6] = newCinUp;
   _state[7] = newCinLow;
   _state[8] = newCoutUp;
   _state[9] = newCoutLow;
   
   ORBool xFail = checkDomainConsistency(_x, newXLow, newXUp, wordLength, self);
   
   ORBool yFail = checkDomainConsistency(_y, newYLow, newYUp, wordLength, self);
   
   ORBool zFail = checkDomainConsistency(_z, newZLow, newZUp, wordLength, self);
   
   ORBool cinFail = checkDomainConsistency(_cin, newCinLow, newCinUp, wordLength, self);
   
   ORBool coutFail = checkDomainConsistency(_cout, newCoutLow, newCoutUp, wordLength, self);

   if (xFail || yFail || zFail || cinFail || coutFail){
      failNow();
   }
   
   [_x setUp:newXUp andLow:newXLow for:self];
   [_y setUp:newYUp andLow:newYLow for:self];
   [_z setUp:newZUp andLow:newZLow for:self];
   [_cin setUp:newCinUp andLow:newCinLow for:self];
   [_cout setUp:newCoutUp andLow:newCoutLow for:self];
   
#ifdef BIT_CONSISTENT_CHECK
   ORUInt xSetBitsAfter = numSetBitsORUInt(newXLow, newXUp, wordLength);
   ORUInt ySetBitsAfter = numSetBitsORUInt(newYLow, newYUp, wordLength);
   ORUInt zSetBitsAfter = numSetBitsORUInt(newZLow, newZUp, wordLength);
   ORUInt cinSetBitsAfter = numSetBitsORUInt(newCinLow, newCinUp, wordLength);
   ORUInt coutSetBitsAfter = numSetBitsORUInt(newCoutLow, newCoutUp, wordLength);
   
   NSAssert(xSetBitsBefore <= xSetBitsAfter, @"ERROR - Number of set bits decreased after Sum constraint propagated?!");
   NSAssert(ySetBitsBefore <= ySetBitsAfter, @"ERROR - Number of set bits decreased after Sum constraint propagated?!");
   NSAssert(zSetBitsBefore <= zSetBitsAfter, @"ERROR - Number of set bits decreased after Sum constraint propagated?!");
   NSAssert(cinSetBitsBefore <= cinSetBitsAfter, @"ERROR - Number of set bits decreased after Sum constraint propagated?!");
   NSAssert(coutSetBitsBefore <= coutSetBitsAfter, @"ERROR - Number of set bits decreased after Sum constraint propagated?!");
#endif
   
#ifdef BIT_DEBUG
   NSLog(@"Done propagating sum constraint");
   NSLog(@" Cin  =%@",_cin);
   NSLog(@" X    =%@",_x);
   NSLog(@"+Y    =%@",_y);
   NSLog(@"_______________________________________________________");
   NSLog(@" Z    =%@",_z);
   NSLog(@" Cout =%@\n\n",_cout);
   NSLog(@"********************************************************\n");
#endif
}
@end

@implementation CPBitCount {
@private
   CPBitVarI*  _x;
   CPIntVarI*  _p;
   ORUInt**    _state;
}
-(id) initCPBitCount:(CPBitVarI*) x count:(CPIntVarI*) p
{
   self = [super initCPBitCoreConstraint: [x engine]];
   _x = x;
   _p = p;
   _state =  malloc(sizeof(ORUInt*)*2);
   return self;
}
-(NSString*) description
{
   NSMutableString* string = [NSMutableString stringWithString:[super description]];
   [string appendString:@" with "];
   [string appendString:[NSString stringWithFormat:@"%@ ",_x]];
   [string appendString:[NSString stringWithFormat:@"and %@",_p]];
   return string;
}

- (void) dealloc
{
   [super dealloc];
   free(_state);
}
-(CPBitAntecedents*) getAntecedents
{
   return NULL;
}

-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment withState:(ORUInt **)state
{
   //NSLog(@"Implication for 0x%lx[%u] = %@  traced back through %@", (unsigned long)assignment->var, assignment->index, (CPBitVarI*)assignment->var, self);
   
   return NULL;
}
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment
{
  //NSLog(@"Implication for 0x%lx[%u] = %@  traced back through %@", (unsigned long)assignment->var, assignment->index, (CPBitVarI*)assignment->var, self);

   return NULL;
}

- (CPBitAntecedents *)getAntecedents:(CPBitAssignment *)assignment {
   return NULL;
}

-(void) post
{
   [self propagate];
   if (![_x bound])
      [_x whenChangePropagate: self];
   if (![_p bound])
      [_p whenChangePropagate: self];
   [self propagate];
}

-(void) propagate
{
#ifdef BIT_DEBUG
   NSLog(@"Bit Count Constraint propagated.");
#endif
   
   unsigned int wordLength = getVarWordLength(_x);//  [_x getWordLength];
   
   TRUInt* xLow;
   TRUInt* xUp;
   ORInt pLow;
   ORInt pUp;
   
   [_x getUp:&xUp andLow:&xLow];
   pLow = [_p min];
   pUp = [_p max];
   
   unsigned int* up = alloca(sizeof(unsigned int)*wordLength);
   unsigned int* low = alloca(sizeof(unsigned int)*wordLength);
   //   unsigned int  upXORlow;
   bool    inconsistencyFound = false;
   
   ORInt xPopcount = 0;
   ORInt xFreebits = 0;
   
   for(int i=0;i<wordLength;i++){
      up[i] = xUp[i]._val;
      low[i] = xLow[i]._val;
      xPopcount += __builtin_popcount(low[i]);
      xFreebits += __builtin_popcount(up[i] ^ low[i]);
   }
   //Consistency Check
   if((pLow > (xFreebits + xPopcount)) || (pUp < xPopcount))
      failNow();
   
   //Shrink domain of _p if possible
   if(pUp > (xPopcount+xFreebits))
      pUp = xPopcount+xFreebits;
   if(pLow < xPopcount)
      pLow =  xPopcount;
   
   
   //set or clear unbound bits in _x if possible
   //   If
   if ((xFreebits + xPopcount) == pLow) {
      if (![_p bound])
         [_p bind:pLow];
      for (int i=0; i<wordLength; i++)
         low[i] = up[i];
   }else if(xPopcount == pUp){
      if(![_p bound])
         [_p bind:pUp];
      for (int i=0; i<wordLength; i++)
         up[i] = low[i];
   }else{
      if (pUp < pLow)
         failNow();
      [_p updateMin:pLow andMax:pUp];
   }
   
   //domain consistency check on _x
   //   for (int i=0; i<wordLength; i++) {
   //      upXORlow = up[i] ^ low[i];
   //      inconsistencyFound |= (upXORlow&(~up[i]))&(upXORlow & low[i]);
   //   }
   inconsistencyFound = checkDomainConsistency(_x, low, up, wordLength, self);
   if (inconsistencyFound)
      failNow();
   
   //set _x and _p to new values
   [_x setUp:up andLow:low for:self];
   
}
- (void)visit:(ORVisitor *)visitor {
}

- (void)close {
}

@end

@implementation CPBitChannel {
   CPBitVarI*  _x;
   CPIntVarI* _xc;
}
-(id) init: (CPBitVarI*) x channel: (CPIntVarI*) p
{
   self = [super initCPBitCoreConstraint: [x engine]];
   _x = x;
   _xc = p;
   return self;
}
-(void) dealloc
{
   [super dealloc];
}
-(NSString*) description
{
   NSMutableString* string = [NSMutableString stringWithString:[super description]];
   [string appendString:@" with "];
   [string appendString:[NSString stringWithFormat:@"%@ ",_x]];
   [string appendString:[NSString stringWithFormat:@" channel %@",_xc]];
   return string;
}
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment
{
   return NULL;
}
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment withState:(ORUInt**)state
{
   return NULL;
}
-(CPBitAntecedents*) getAntecedents:(CPBitAssignment*) assignment
{
   return NULL;
}
-(void) post
{
  //NSLog(@"channel(post -BEFORE): %@",[self description]);
   [self propagate];
   if (![_x bound])
      [_x whenChangeDo:^{
         [self propagateBitToInt];
      } priority:HIGHEST_PRIO onBehalf:self];
   if (![_xc bound])
      [_xc whenChangeDo:^{
         [self propagateIntToBit];
      } onBehalf:self];
   [self propagate];
   //NSLog(@"channel(post -AFTER): %@",[self description]);   
}
-(void) propagate
{
  [_xc updateMin:(ORInt)_x.min andMax: (ORInt)_x.max];
  [_x updateMin:(ORULong)_xc.min];
  [_x updateMax:(ORULong)_xc.max];
}
-(void) propagateIntToBit
{
   [_x updateMax:(ORULong)[_xc max]];  // Better to update the max *first* 
   [_x updateMin:(ORULong)[_xc min]];
}
-(void) propagateBitToInt
{
   [_xc updateMin:(ORInt)[_x min] andMax:(ORInt)[_x max]];
}
@end

@implementation CPBitZeroExtend {
@private
   CPBitVarI*  _x;
   CPBitVarI*  _y;
   ORUInt**    _state;
}
-(id) initCPBitZeroExtend:(CPBitVarI*) x extendTo:(CPBitVarI *)y
{
   self = [super initCPBitCoreConstraint: [x engine]];
   _x = x;
   _y = y;
   _state = malloc(sizeof(ORUInt*)*4);
   return self;
}
- (void) dealloc
{
   [super dealloc];
   free(_state);
}
-(NSString*) description
{
   NSMutableString* string = [NSMutableString stringWithString:[super description]];
   [string appendString:@" with "];
   [string appendString:[NSString stringWithFormat:@"%@ ",_x]];
   [string appendString:[NSString stringWithFormat:@"and %@\n",_y]];
   
   return string;
}
-(CPBitAntecedents*) getAntecedents:(CPBitAssignment*)assignment{
   return ([self getAntecedentsFor:assignment withState:_state]);
}
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment withState:(ORUInt**)state
{
  //NSLog(@"Implication for 0x%lx[%u] = %@  traced back through %@", (unsigned long)assignment->var, assignment->index, (CPBitVarI*)assignment->var, self);
   
   if (assignment->index >= [_x bitLength])
      return NULL;
   
   CPBitAntecedents* ants = malloc(sizeof(CPBitAntecedents));
   CPBitAssignment** vars;
   
   vars  = malloc(sizeof(CPBitAssignment*));
   ants->numAntecedents = 0;
   
   ORUInt index = assignment->index;
   ants->antecedents = vars;
   
   if (assignment->var == _x) {
      if ((index < [_x bitLength]) && (![_y isFree:index] || ~ISFREE(state[2][index/BITSPERWORD], state[3][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD)))) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _y;
         vars[ants->numAntecedents]->index = index;
         if(![_y isFree:index])
            vars[ants->numAntecedents]->value = [_y getBit:index];
         else
            vars[ants->numAntecedents]->value = !((ISTRUE(state[2][index/BITSPERWORD], state[3][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD))) == 0);
         ants->numAntecedents++;
      }
   }
   else if (assignment->var == _y){
      if ((index < [_x bitLength]) && (![_x isFree:index] || ~ISFREE(state[0][index/BITSPERWORD], state[1][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD)))) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _x;
         vars[ants->numAntecedents]->index = index;
         if(![_x isFree:index])
            vars[ants->numAntecedents]->value = [_x getBit:index];
         else
            vars[ants->numAntecedents]->value = !((ISTRUE(state[0][index/BITSPERWORD], state[1][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD))) == 0);

         ants->numAntecedents++;
      }
   }

//   NSLog(@"x  %@",_x);
//   NSLog(@"y  %@",_y);
//   NSLog(@"Assignment: %@[%d] = %d",assignment->var,assignment->index,assignment->value);
//   if(ants->numAntecedents > 0)
//      NSLog(@"antecedent[0]: %@[%d] = %d",ants->antecedents[0]->var,ants->antecedents[0]->index,ants->antecedents[0]->value);
//   NSLog(@"\n\n\n");

   
   return ants;
   
}
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment
{
  //NSLog(@"Implication for 0x%lx[%u] = %@  traced back through %@", (unsigned long)assignment->var, assignment->index, (CPBitVarI*)assignment->var, self);

   if (assignment->index >= [_x bitLength])
      return NULL;

   CPBitAntecedents* ants = malloc(sizeof(CPBitAntecedents));
   CPBitAssignment** vars;
   
   vars  = malloc(sizeof(CPBitAssignment*));
   ants->numAntecedents = 0;
   
   ORUInt index = assignment->index;
   ants->antecedents = vars;
   
   if (assignment->var == _x) {
      if ((index < [_x bitLength]) && (![_y isFree:index])) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _y;
         vars[ants->numAntecedents]->index = index;
         vars[ants->numAntecedents]->value = [_y getBit:index];
         ants->numAntecedents++;
      }
   }
   else if (assignment->var == _y){
      if ((index < [_x bitLength]) && (![_x isFree:index])) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _x;
         vars[ants->numAntecedents]->index = index;
         vars[ants->numAntecedents]->value = [_x getBit:index];
         ants->numAntecedents++;
      }
   }
   
   
//   NSLog(@"x  %@",_x);
//   NSLog(@"y  %@",_y);
//   NSLog(@"Assignment: %@[%d] = %d",assignment->var,assignment->index,assignment->value);
//   if(ants->numAntecedents > 0)
//      NSLog(@"antecedent[0]: %@[%d] = %d",ants->antecedents[0]->var,ants->antecedents[0]->index,ants->antecedents[0]->value);
//   NSLog(@"\n\n\n");

   
   return ants;

}

-(void) post
{
   //   unsigned int xWordLength = [_x getWordLength];
   //   unsigned int yWordLength = [_y getWordLength];
   //   unsigned int wordDiff = yWordLength - xWordLength;
   //
   //   TRUInt* yLow;
   //   TRUInt* yUp;
   //   [_y getUp:&yUp andLow:&yLow];
   //   unsigned int* up = alloca(sizeof(unsigned int)*xWordLength);
   //   unsigned int* low = alloca(sizeof(unsigned int)*yWordLength);
   //   unsigned int  upXORlow;
   //
   //   for (int i=0; i<wordDiff; i++) {
   //      up[i] = 0;
   //      low[i] = 0;
   //   }
   //
   //   for(int i=wordDiff;i<yWordLength;i++){
   //      up[i] = yUp[i]._val;
   //      low[i] = yLow[i]._val;
   //      upXORlow = up[i] ^ low[i];
   //      if(((upXORlow & (~up[i])) & (upXORlow & low[i])) != 0){
   //         failNow();
   //      }
   //   }
   //
   //   [_y setUp:up andLow:low];
   
   [self propagate];
   if (![_x bound])
      [_x whenChangePropagate: self];
   if (![_y bound])
      [_y whenChangePropagate: self];
   [self propagate];
//   return ORSuspend;
}

-(void) propagate
{
#ifdef BIT_DEBUG
   NSLog(@"Bit ZeroExtend Constraint propagated.");
#endif
   //Check to see that upper (zero) bits are not set to 1
   unsigned int xWordLength = [_x getWordLength];
   unsigned int yWordLength = [_y getWordLength];
//   ORUInt xBitLength = [_x bitLength];
//   ORUInt yBitLength = [_y bitLength];
   //   unsigned int wordDiff = yWordLength - xWordLength;
   
   TRUInt* xLow;
   TRUInt* xUp;
   TRUInt* yLow;
   TRUInt* yUp;
   
   [_x getUp:&xUp andLow:&xLow];
   [_y getUp:&yUp andLow:&yLow];
   
   
//   NSLog(@"*******************************************");
//   NSLog(@"x zero extend to y");
//   NSLog(@"x=                        %@\n",_x);
//   NSLog(@"y=%@\n",_y);

   
   unsigned int* up = alloca(sizeof(unsigned int)*yWordLength);
   unsigned int* low = alloca(sizeof(unsigned int)*yWordLength);
//   unsigned int  upXORlow;
   
   for (int i=0; i<yWordLength; i++) {
      up[i] = 0;
      low[i] = 0;
   }
   
   for(int i=0;i<xWordLength;i++){
      up[i] = xUp[i]._val & yUp[i]._val;
      low[i] = xLow[i]._val | yLow[i]._val;
//      upXORlow = up[i] ^ low[i];
//      if(((upXORlow & (~up[i])) & (upXORlow & low[i])) != 0){
//         failNow();
//      }
   }

//   NSLog(@"newX =                         %@",bitvar2NSString(low, up, xBitLength));
//   NSLog(@"newY = %@",bitvar2NSString(low, up, yBitLength));
//   
//   if((yBitLength - xBitLength) < 32)
//      NSLog(@"");
   _state[0] = up;
   _state[1] = low;
   _state[2] = up;
   _state[3] = low;
   
   ORBool xFail = checkDomainConsistency(_x, low, up, xWordLength, self);
   ORBool yFail = checkDomainConsistency(_y, low, up, yWordLength, self);
   
   if (xFail || yFail) {
      failNow();
   }
   
   [_x setUp:up andLow:low for:self];
   [_y setUp:up andLow:low for:self];
   
}
@end

@implementation CPBitSignExtend {
@private
   CPBitVarI*  _x;
   CPBitVarI*  _y;
   ORUInt**    _state;
}
-(id) initCPBitSignExtend:(CPBitVarI*) x extendTo:(CPBitVarI *)y
{
   self = [super initCPBitCoreConstraint: [x engine]];
   _x = x;
   _y = y;
   _state = malloc(sizeof(ORUInt*)*4);
   return self;
}
-(NSString*) description
{
   NSMutableString* string = [NSMutableString stringWithString:[super description]];
   [string appendString:@" with "];
   [string appendString:[NSString stringWithFormat:@"%@ ",_x]];
   [string appendString:[NSString stringWithFormat:@"and %@\n",_y]];
   
   return string;
}
-(CPBitAntecedents*) getAntecedents:(CPBitAssignment*)assignment{
   return ([self getAntecedentsFor:assignment withState:_state]);
}
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment withState:(ORUInt **)state
{
   //NSLog(@"Implication for 0x%lx[%u] = %@  traced back through %@", (unsigned long)assignment->var, assignment->index, (CPBitVarI*)assignment->var, self);
   
   CPBitAntecedents* ants = malloc(sizeof(CPBitAntecedents));
   CPBitAssignment** vars;
   
   vars  = malloc(sizeof(CPBitAssignment*));
   ants->antecedents = vars;
   ants->numAntecedents = 0;
   
   
   
   ORUInt index = assignment->index;
   
   if (assignment->var == _x) {
      if (![_y isFree:index] || ~ISFREE(state[2][index/BITSPERWORD], state[3][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD))) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _y;
         vars[ants->numAntecedents]->index = index;
         if(![_y isFree:index])
            vars[ants->numAntecedents]->value = [_y getBit:index];
         else
            vars[ants->numAntecedents]->value = !((ISTRUE(state[2][index/BITSPERWORD], state[3][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD))) == 0);
         ants->numAntecedents++;
      }
   }
   else if (assignment->var == _y){
      if (assignment->index >= [_x bitLength]){
         ORUInt signBit = [_x bitLength]-1;
         if (![_x isFree:signBit] || ~ISFREE(state[0][signBit/BITSPERWORD], state[1][signBit/BITSPERWORD]) & (0x1 << (signBit%BITSPERWORD))) {
            vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
            vars[ants->numAntecedents]->var = _x;
            vars[ants->numAntecedents]->index = signBit;
            if(![_x isFree:signBit])
               vars[ants->numAntecedents]->value = [_x getBit:signBit];
            else
               vars[ants->numAntecedents]->value = !((ISTRUE(state[0][signBit/BITSPERWORD], state[1][signBit/BITSPERWORD]) & (0x1 << (signBit%BITSPERWORD))) == 0);
            ants->numAntecedents++;
         }
      }
      else if (![_x isFree:index] || ~ISFREE(state[0][index/BITSPERWORD], state[1][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD))) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _x;
         vars[ants->numAntecedents]->index = index;
         if(![_x isFree:index])
            vars[ants->numAntecedents]->value = [_x getBit:index];
         else
            vars[ants->numAntecedents]->value = !((ISTRUE(state[0][index/BITSPERWORD], state[1][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD))) == 0);
         ants->numAntecedents++;
      }
   }
   return ants;
   
}

-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment
{
  //NSLog(@"Implication for 0x%lx[%u] = %@  traced back through %@", (unsigned long)assignment->var, assignment->index, (CPBitVarI*)assignment->var, self);

   CPBitAntecedents* ants = malloc(sizeof(CPBitAntecedents));
   CPBitAssignment** vars;
   
   vars  = malloc(sizeof(CPBitAssignment*));
   ants->antecedents = vars;
   ants->numAntecedents = 0;
   

   
   ORUInt index = assignment->index;
   
   if (assignment->var == _x) {
      if (![_y isFree:index]) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _y;
         vars[ants->numAntecedents]->index = index;
         vars[ants->numAntecedents]->value = [_y getBit:index];
         ants->numAntecedents++;
      }
   }
   else if (assignment->var == _y){
      if (assignment->index >= [_x bitLength]){
         ORUInt signBit = [_x bitLength]-1;
         if (![_x isFree:signBit]) {
            vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
            vars[ants->numAntecedents]->var = _x;
            vars[ants->numAntecedents]->index = signBit;
            vars[ants->numAntecedents]->value = ([_x getBit:signBit] != 0);
            ants->numAntecedents++;
         }
      }
      else if (![_x isFree:index]) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _x;
         vars[ants->numAntecedents]->index = index;
         vars[ants->numAntecedents]->value = [_x getBit:index];
         ants->numAntecedents++;
      }
   }
   return ants;
   
}
- (void) dealloc
{
   [super dealloc];
   free(_state);
}

-(void) post
{
   //   unsigned int xWordLength = [_x getWordLength];
   //   unsigned int yWordLength = [_y getWordLength];
   //   unsigned int wordDiff = yWordLength - xWordLength;
   //
   //   TRUInt* yLow;
   //   TRUInt* yUp;
   //   [_y getUp:&yUp andLow:&yLow];
   //   unsigned int* up = alloca(sizeof(unsigned int)*xWordLength);
   //   unsigned int* low = alloca(sizeof(unsigned int)*yWordLength);
   //   unsigned int  upXORlow;
   //
   //   for (int i=0; i<wordDiff; i++) {
   //      up[i] = 0;
   //      low[i] = 0;
   //   }
   //
   //   for(int i=wordDiff;i<yWordLength;i++){
   //      up[i] = yUp[i]._val;
   //      low[i] = yLow[i]._val;
   //      upXORlow = up[i] ^ low[i];
   //      if(((upXORlow & (~up[i])) & (upXORlow & low[i])) != 0){
   //         failNow();
   //      }
   //   }
   //
   //   [_y setUp:up andLow:low];
   
   [self propagate];
   if (![_x bound])
      [_x whenChangePropagate: self];
   if (![_y bound])
      [_y whenChangePropagate: self];
   [self propagate];
   //   return ORSuspend;
}

-(void) propagate
{
#ifdef BIT_DEBUG
   NSLog(@"Bit SignExtend Constraint propagated.");
#endif
   //Check to see that upper (zero) bits are not set to 1
   ORUInt xWordLength = [_x getWordLength];
   ORUInt xBitLength = [_x bitLength];
   ORUInt yWordLength = [_y getWordLength];
   ORUInt yBitLength = [_y bitLength];
   //   unsigned int wordDiff = yWordLength - xWordLength;
   
   TRUInt* xLow;
   TRUInt* xUp;
   TRUInt* yLow;
   TRUInt* yUp;
   
   [_x getUp:&xUp andLow:&xLow];
   [_y getUp:&yUp andLow:&yLow];
   
   ORUInt* newXUp = alloca(sizeof(unsigned int)*xWordLength);
   ORUInt* newXLow = alloca(sizeof(unsigned int)*xWordLength);
   ORUInt* newYUp = alloca(sizeof(unsigned int)*yWordLength);
   ORUInt* newYLow = alloca(sizeof(unsigned int)*yWordLength);

//   ORUInt  upXORlow;
   
   
//   NSLog(@"*******************************************");
//   NSLog(@"x sign extend to y");
//   NSLog(@"x=%@\n",_x);
//   NSLog(@"y=%@\n",_y);

   
   
   
   for (int i=0; i<yWordLength; i++) {
      newXUp[i] = xUp[i]._val;
      newXLow[i] = xLow[i]._val;
      newYUp[i] = yUp[i]._val;
      newYLow[i] = yLow[i]._val;
   }
   
//   NSLog(@"\nx=%@\ny=%@\nnewX=%@\nnewY=%@\n",_x, _y,bitvar2NSString(newXLow, newXLow, bitLength),bitvar2NSString(newYLow, newYUp, bitLength));

   
   //copy shared bits
   for(int i=0;i<xWordLength;i++){
      newXUp[i]= newYUp[i] = xUp[i]._val & yUp[i]._val;
      newXLow[i] = newYLow[i] = xLow[i]._val | yLow[i]._val;
//      upXORlow = newXUp[i] ^ newXLow[i];
//      if(((upXORlow & (~up[i])) & (upXORlow & low[i])) != 0){
//         failNow();
//      }
   }
   
   //mask out bits in x that are not valid in x
   newXUp[xWordLength-1] &= UP_MASK >> (BITSPERWORD - (xBitLength%BITSPERWORD));
   newXLow[xWordLength-1]&= UP_MASK >> (BITSPERWORD - (xBitLength%BITSPERWORD));
   
   newYUp[xWordLength-1] |= UP_MASK << (xBitLength%BITSPERWORD);
   
   for (int i=xWordLength-1; i<yWordLength; i++) {
      newYUp[i] &= yUp[i]._val;
      newYLow[i] |= yLow[i]._val;
   }
   
   //extend sign if possible
   ORUInt signMask = 1 << ((xBitLength-1) % BITSPERWORD);
   ORUInt signIsSet = (~(xUp[xWordLength-1]._val ^ xLow[xWordLength-1]._val)) & signMask;
   
   if(signIsSet){
      if (signMask & xLow[xWordLength-1]._val) {
         //x is negative
         newYLow[xWordLength-1] |= UP_MASK << (xBitLength%BITSPERWORD);
         for (int i=xWordLength; i<yWordLength; i++) {
            newYLow[i] |= UP_MASK;
         }
      }
      else{
         //x is positive
         newYUp[xWordLength-1] &= UP_MASK >> (BITSPERWORD -(xBitLength%BITSPERWORD));
         for (int i=xWordLength; i<yWordLength; i++) {
            newYUp[i] &= UP_MASK;
         }
      }
   }
   
   ORUInt* ySignBits = alloca(sizeof(ORUInt)*yWordLength);
   
   //get sign from y if possible
   for (int i=0; i<yWordLength; i++) {
      //find set sign bits in y
      ySignBits[i] = ~(yUp[i]._val ^ yLow[i]._val);
   }
   //clear out x data bits (not part of the sign)
   for (int i=0; i<xWordLength-1; i++) {
      ySignBits[i] = UP_MASK;
   }
   ySignBits[xWordLength-1] &= (~(yUp[xWordLength-1]._val ^ yLow[xWordLength-1]._val) & (UP_MASK << (xBitLength%BITSPERWORD)));
   
   //_y may not be on 32bit boundary
   //Clear out unused bits
   ySignBits[yWordLength-1] &=(~(yUp[xWordLength-1]._val ^ yLow[xWordLength-1]._val) & (UP_MASK >> (BITSPERWORD - (yBitLength%BITSPERWORD))));
   
   ORUInt ySignBitSet = 0;
   for (int i=0; i<yWordLength; i++) {
      //find set sign bits in y
      ySignBitSet |= ySignBits[i] & ~(yUp[i]._val ^ yLow[i]._val);
   }
   
   if (ySignBitSet) {
      for (int i = yWordLength-1; i>=0; i--) {
         if (ySignBits[i] & ~yUp[i]._val) {
            //sign is +
            newXUp[xWordLength-1] &= UP_MASK >> (BITSPERWORD -(xBitLength%BITSPERWORD)+1);
            newYUp[xWordLength-1] &= UP_MASK >> (BITSPERWORD -(xBitLength%BITSPERWORD)+1);
            for (int i=xWordLength; i<yWordLength; i++) {
               newYUp[i] &= UP_MASK;
            }
         }
         else if (ySignBits[i] & yLow[i]._val)
         {
            //sign is -
            newXLow[xWordLength-1] |= signMask;
            newYLow[xWordLength-1] |= UP_MASK << (xBitLength%BITSPERWORD);
            for (int i=xWordLength; i<yWordLength; i++) {
               newYLow[i] |= UP_MASK;
            }
         }
      }
   }
   
   
   
//   NSLog(@"\nx=%@\ny=%@\nnewX=%@\nnewY=%@\n\n\n",_x, _y,bitvar2NSString(newXLow, newXLow, xBitLength),bitvar2NSString(newYLow, newYUp, yBitLength));
   
//   NSLog(@"newX = %@",bitvar2NSString(newXLow, newXUp, xBitLength));
//   NSLog(@"newY = %@",bitvar2NSString(newYLow, newYUp, yBitLength));

   
   _state[0] = newXUp;
   _state[1] = newXLow;
   _state[2] = newYUp;
   _state[3] = newYLow;
   
   ORBool xFail = checkDomainConsistency(_x, newXLow, newXUp, xWordLength, self);
   ORBool yFail = checkDomainConsistency(_y, newYLow, newYUp, yWordLength, self);
   
   if(xFail || yFail)
      failNow();
   
   [_x setUp:newXUp andLow:newXLow for:self];
   [_y setUp:newYUp andLow:newYLow for:self];
   
}
@end

@implementation CPBitExtract {
@private
   CPBitVarI*  _x;
   ORUInt      _lsb;
   ORUInt      _msb;
   CPBitVarI*  _y;
   ORUInt**    _state;
}
-(id) initCPBitExtract:(CPBitVarI*) x from:(ORUInt)lsb to:(ORUInt)msb eq:(CPBitVarI*)y
{
   self = [super initCPBitCoreConstraint: [x engine]];
   _x = x;
   _y = y;
   _lsb = lsb;
   _msb = msb;
   _state = malloc(sizeof(ORUInt*)*4);
   return self;
}
-(CPBitAntecedents*) getAntecedents:(CPBitAssignment*)assignment{
   return ([self getAntecedentsFor:assignment withState:_state]);
}
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment withState:(ORUInt**)state
{
  //NSLog(@"Implication for 0x%lx[%u] = %@  traced back through %@", (unsigned long)assignment->var, assignment->index, (CPBitVarI*)assignment->var, self);
   
   //   if ((assignment->var == _y) && (assignment->index < _lsb || assignment->index > _msb))
   //      return NULL;
   
   CPBitAntecedents* ants = malloc(sizeof(CPBitAntecedents));
   CPBitAssignment** vars;
   
   vars  = malloc(sizeof(CPBitAssignment*));
   ants->numAntecedents = 0;
   
   ORUInt index;
   ants->antecedents = vars;
   
   if (assignment->var == _x) {
      index = assignment->index - _lsb;
      if (index < [_y bitLength] && (![_y isFree:index] || ~ISFREE(state[2][index/BITSPERWORD], state[3][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD)))) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _y;
         vars[ants->numAntecedents]->index = index;
         if(![_y isFree:index])
            vars[ants->numAntecedents]->value = [_y getBit:index];
         else
            vars[ants->numAntecedents]->value = !((ISTRUE(state[2][index/BITSPERWORD], state[3][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD))) == 0);
         ants->numAntecedents++;
      }
   }
   else if (assignment->var == _y){
      index = assignment->index + _lsb;
      if (index < [_x bitLength] && (![_x isFree:index] || ~ISFREE(state[0][index/BITSPERWORD], state[1][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD)))) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _x;
         vars[ants->numAntecedents]->index = index;
         if(![_x isFree:index])
            vars[ants->numAntecedents]->value = [_x getBit:index];
         else
            vars[ants->numAntecedents]->value = !((ISTRUE(state[0][index/BITSPERWORD], state[1][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD))) == 0);
         ants->numAntecedents++;
      }
   }
   return ants;
}

-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment
{
  //NSLog(@"Implication for 0x%lx[%u] = %@  traced back through %@", (unsigned long)assignment->var, assignment->index, (CPBitVarI*)assignment->var, self);

//   if ((assignment->var == _y) && (assignment->index < _lsb || assignment->index > _msb))
//      return NULL;
   
   CPBitAntecedents* ants = malloc(sizeof(CPBitAntecedents));
   CPBitAssignment** vars;
   
   vars  = malloc(sizeof(CPBitAssignment*));
   ants->numAntecedents = 0;
   
   ORUInt index;
   ants->antecedents = vars;
   
   if (assignment->var == _x) {
      index = assignment->index - _lsb;
      if (index < [_y bitLength] && ![_y isFree:index]) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _y;
         vars[ants->numAntecedents]->index = index;
         vars[ants->numAntecedents]->value = [_y getBit:index];
         ants->numAntecedents++;
      }
   }
   else if (assignment->var == _y){
      index = assignment->index + _lsb;
      if (index < [_x bitLength] && ![_x isFree:index]) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _x;
         vars[ants->numAntecedents]->index = index;
         vars[ants->numAntecedents]->value = [_x getBit:index];
         ants->numAntecedents++;
      }
   }
   return ants;
}

- (void) dealloc
{
   [super dealloc];
   free(_state);
}
-(NSString*) description
{
   NSMutableString* string = [NSMutableString stringWithString:[super description]];
   [string appendString:@" with "];
   [string appendString:[NSString stringWithFormat:@"%@ from %u to %u ",_x, _lsb, _msb]];
   [string appendString:[NSString stringWithFormat:@"and %@\n",_y]];
   
   return string;
}


-(void) post
{
   [self propagate];
   if (![_x bound])
      [_x whenChangePropagate: self];
   if (![_y bound])
      [_y whenChangePropagate: self];
   [self propagate];
//   return ORSuspend;
}

-(void) propagate
{
#ifdef BIT_DEBUG
   NSLog(@"Bit Extract Constraint propagated.");
#endif
   
   unsigned int xWordLength = [_x getWordLength];
   unsigned int yWordLength = [_y getWordLength];
//   unsigned int xBitLength = [_x bitLength];
//   unsigned int yBitLength = [_y bitLength];
   
   TRUInt* xLow;
   TRUInt* xUp;
   TRUInt* yLow;
   TRUInt* yUp;
   
   [_x getUp:&xUp andLow:&xLow];
   [_y getUp:&yUp andLow:&yLow];
   
//      NSLog(@"*******************************************");
//      NSLog(@"bit extract");
//      NSLog(@"x=%@\n",_x);
//      NSLog(@"From %u to %u",_lsb, _msb);
//      NSLog(@"y=%@\n",_y);
   
   unsigned int* up = alloca(sizeof(unsigned int)*yWordLength);
   unsigned int* low = alloca(sizeof(unsigned int)*yWordLength);
   //   unsigned int* xUpForY = alloca(sizeof(unsigned int)*yWordLength);
   //   unsigned int* xLowForY =  alloca(sizeof(unsigned int)*yWordLength);
   unsigned int* newXUp = alloca(sizeof(unsigned int)*xWordLength);
   unsigned int* newXLow = alloca(sizeof(unsigned int)*xWordLength);
   unsigned int* yLowForX = alloca(sizeof(unsigned int)*yWordLength);
   unsigned int* yUpForX = alloca(sizeof(unsigned int)*yWordLength);
   
//   unsigned int  upXORlow;
   bool    inconsistencyFound = false;

   for(int i=0;i<xWordLength;i++){
      newXUp[i] = xUp[i]._val;
      newXLow[i] = xLow[i]._val;
   }

   for (int i = 0; i < yWordLength; i++) {
      low[i] = yLowForX[i] = yLow[i]._val;
      up[i] = yUpForX[i] = yUp[i]._val;
      
   }
   yUpForX[yWordLength-1] |= (CP_UMASK << ([_y bitLength]%BITSPERWORD)) | yUp[yWordLength-1]._val;
   yLowForX[yWordLength-1] &= (CP_UMASK >> (BITSPERWORD - ([_y bitLength]%BITSPERWORD)));
   
//   NSLog(@"yForX = %@\n",bitvar2NSString(yLowForX, yUpForX, yBitLength));
//   
//   if(yLow[0]._val != 0)
//      NSLog(@"");
   
   for(int i=0;i<yWordLength;i++){
      if ((i+_lsb/32) < xWordLength) {
         
         up[i] = ~(ISFALSE(yUp[i]._val,yLow[i]._val)|((ISFALSE(xUp[i+_lsb/32]._val, xLow[i+_lsb/32]._val)>>(_lsb%32))));
         low[i] = ISTRUE(yUp[i]._val,yLow[i]._val)|((ISTRUE(xUp[i+_lsb/32]._val, xLow[i+_lsb/32]._val)>>(_lsb%32)));
         //         NSLog(@"i=%i",i+_places/32);
         if(((_lsb%32)!=0) && (i+(_lsb/32)+1) < xWordLength) {
            up[i] &= ~(ISFALSE(xUp[i+(_lsb/32)+1]._val, xLow[i+(_lsb/32)+1]._val)<<(32-(_lsb%32)));
            low[i] |= ISTRUE(xUp[i+(_lsb/32)+1]._val, xLow[i+(_lsb/32)+1]._val)<<(32-(_lsb%32));
            //            NSLog(@"i=%i",i+_places/32+1);
         }
         if (i==(yWordLength-1)) {
            up[i] &= UP_MASK >> (32 - ([_y bitLength]%32));
            low[i] &= UP_MASK >> (32 - ([_y bitLength]%32));
         }
      }
      //      else{
      //         up[i] = 0;
      //         low[i] = 0;
      //      }
//   }
//   for(int i=0;i<xWordLength;i++){

      if ((i-(int)_lsb/32) >= 0) {
         newXUp[i] = ~(ISFALSE(xUp[i]._val,xLow[i]._val)|((ISFALSE(yUpForX[i-_lsb/32], yLowForX[i-_lsb/32])<<(_lsb%32))));
         newXLow[i] = ISTRUE(xUp[i]._val,xLow[i]._val)|((ISTRUE(yUpForX[i-_lsb/32], yLowForX[i-_lsb/32])<<(_lsb%32)));
         //         NSLog(@"i=%i",i-_places/32);
         if(((_msb - _lsb)>BITSPERWORD) && (i-(int)_lsb/32-1) >= 0) {
            newXUp[i] &= ~(ISFALSE(yUpForX[(i-(int)_lsb/32-1)],yLowForX[(i-(int)_lsb/32-1)])>>(32-(_lsb%32)));
            newXLow[i] |= ISTRUE(yUpForX[(i-(int)_lsb/32-1)],yLowForX[(i-(int)_lsb/32-1)])>>(32-(_lsb%32));
            //            NSLog(@"i=%i",i-(int)_places/32-1);
         }
      }
      else{
         newXUp[i] = xUp[i]._val;
         newXLow[i] = xLow[i]._val;
      }
   }
   //clear unused upper bits
   //   ORUInt mask = CP_UMASK << (_msb-_lsb)%32;
   //   newXUp[xWordLength-1] |= mask;
   //   newXLow[xWordLength-1] &= ~mask;
   
   
   
   //   NSLog(@"");
   //   NSLog(@"x = %@",_x);
   //   NSLog(@"y = %@",_y);

//   NSLog(@"newX = %@",bitvar2NSString(newXLow, newXUp, xBitLength));
//   NSLog(@"newY = %@\n\n",bitvar2NSString(low, up, yBitLength));

   
   
   //check domain consistency
//   for(int i=0;i<xWordLength;i++){
//      upXORlow = newXUp[i] ^ newXLow[i];
//      inconsistencyFound |= (upXORlow&(~newXUp[i]))&(upXORlow & newXLow[i]);

//   }
   
   _state[0] = newXUp;
   _state[1] = newXLow;
   _state[2] = up;
   _state[3] = low;
   
      inconsistencyFound = checkDomainConsistency(_x, newXLow, newXUp, xWordLength, self);
      inconsistencyFound |= checkDomainConsistency(_y, low, up, yWordLength, self);
      if (inconsistencyFound){
         failNow();
      }
      
   [_x setUp:newXUp andLow:newXLow for:self];
   [_y setUp:up andLow:low for:self];
   
}
@end

@implementation CPBitConcat
-(id) initCPBitConcat:(CPBitVarI*) x concat:(CPBitVarI *)y eq:(CPBitVarI *)z
{
   self = [super initCPBitCoreConstraint: [x engine]];
   _x = x;
   _y = y;
   _z = z;
   _state = malloc(sizeof(ORUInt*)*6);
   return self;
}
-(CPBitAntecedents*) getAntecedents:(CPBitAssignment*)assignment{
   return ([self getAntecedentsFor:assignment withState:_state]);
}
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment withState:(ORUInt**)state
{
  //NSLog(@"Implication for 0x%lx[%u] = %@  traced back through %@", (unsigned long)assignment->var, assignment->index, (CPBitVarI*)assignment->var, self);
   
   CPBitAntecedents* ants = malloc(sizeof(CPBitAntecedents));
   CPBitAssignment** vars;
   ORUInt index;
   
   
   
   vars  = malloc(sizeof(CPBitAssignment*));
   ants->antecedents = vars;
   ants->numAntecedents = 0;
   
   if (assignment->var == _x) {
      
      index = assignment->index + [_y bitLength];
      if (![_z isFree:index] || (~ISFREE(state[4][index/BITSPERWORD], state[5][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD)))) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _z;
         vars[ants->numAntecedents]->index = index;
         if(![_z isFree:index])
            vars[ants->numAntecedents]->value = [_z getBit:index];
         else
            vars[ants->numAntecedents]->value = !((ISTRUE(state[4][index/BITSPERWORD], state[5][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD))) == 0);
         ants->numAntecedents++;
      }
   }
   else if (assignment->var == _y){
      index = assignment->index;
      if (![_z isFree:index] || (~ISFREE(state[4][index/BITSPERWORD], state[5][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD)))) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _z;
         vars[ants->numAntecedents]->index = index;
         if(![_z isFree:index])
            vars[ants->numAntecedents]->value = [_z getBit:index];
         else
            vars[ants->numAntecedents]->value = !((ISTRUE(state[4][index/BITSPERWORD], state[5][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD))) == 0);
         ants->numAntecedents++;
      }
   }
   else{
      vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
      if (assignment->index  >= [_y bitLength]) {
         index = assignment->index - [_y bitLength];
         if (![_x isFree:index] || (~ISFREE(state[0][index/BITSPERWORD], state[1][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD)))) {
            vars[ants->numAntecedents]->var = _x;
            vars[ants->numAntecedents]->index = index;
            if(![_x isFree:index])
               vars[ants->numAntecedents]->value = [_x getBit:index];
            else
               vars[ants->numAntecedents]->value = !((ISTRUE(state[0][index/BITSPERWORD], state[1][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD))) == 0);
         }
      }
      else{
         index = assignment->index;
         if (![_y isFree:index] || (~ISFREE(state[2][index/BITSPERWORD], state[3][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD)))) {
            vars[ants->numAntecedents]->var = _y;
            vars[ants->numAntecedents]->index = index;
            if(![_y isFree:index])
               vars[ants->numAntecedents]->value = [_y getBit:index];
            else
               vars[ants->numAntecedents]->value = !((ISTRUE(state[2][index/BITSPERWORD], state[3][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD))) == 0);
         }
      }
      ants->numAntecedents++;
   }
   
   return ants;
}
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment
{
  //NSLog(@"Implication for 0x%lx[%u] = %@  traced back through %@", (unsigned long)assignment->var, assignment->index, (CPBitVarI*)assignment->var, self);

   CPBitAntecedents* ants = malloc(sizeof(CPBitAntecedents));
   CPBitAssignment** vars;
   ORUInt index;
   
   
   
   vars  = malloc(sizeof(CPBitAssignment*));
   ants->antecedents = vars;
   ants->numAntecedents = 0;

   if (assignment->var == _x) {
      
      index = assignment->index + [_y bitLength];
      if(![_z isFree:index]){
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _z;
         vars[ants->numAntecedents]->index = index;
         vars[ants->numAntecedents]->value = ([_z getBit:index]!=0);
         ants->numAntecedents++;
      }
   }
   else if (assignment->var == _y){
      index = assignment->index;
      if(![_z isFree:index]){
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _z;
         vars[ants->numAntecedents]->index = index;
         vars[ants->numAntecedents]->value = ([_z getBit:index]!=0);
         ants->numAntecedents++;
      }
   }
   else{
      vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
      if (assignment->index  >= [_y bitLength]) {
         index = assignment->index - [_y bitLength];
         if(![_x isFree:index]){
            vars[ants->numAntecedents]->var = _x;
            vars[ants->numAntecedents]->index = index;
            vars[ants->numAntecedents]->value = ([_x getBit:index]!=0);
         }
      }
      else{
         index = assignment->index;
         if(![_y isFree:index]){
            vars[ants->numAntecedents]->var = _y;
            vars[ants->numAntecedents]->index = index;
            vars[ants->numAntecedents]->value = ([_y getBit:index]!=0);
         }
      }
      ants->numAntecedents++;
   }
   
   return ants;
}

- (void) dealloc
{
   [super dealloc];
   free(_state);
}
-(NSString*) description
{
   NSMutableString* string = [NSMutableString stringWithString:[super description]];
   [string appendString:@" with "];
   [string appendString:[NSString stringWithFormat:@"%@, ",_x]];
   [string appendString:[NSString stringWithFormat:@"%@, ",_y]];
   [string appendString:[NSString stringWithFormat:@"and %@\n",_z]];
   
   return string;
}


-(void) post
{
   unsigned int xWordLength = [_x getWordLength];
   unsigned int yWordLength = [_y getWordLength];
   unsigned int zWordLength = [_z getWordLength];
   
   if (zWordLength < (xWordLength + yWordLength)-1) {
      failNow();
   }
   
   [self propagate];
   if (![_x bound])
      [_x whenChangePropagate: self];
   if (![_y bound])
      [_y whenChangePropagate: self];
   if (![_z bound])
      [_z whenChangePropagate: self];
   [self propagate];
//   return ORSuspend;
}

-(void) propagate
{
#ifdef BIT_DEBUG
   NSLog(@"Bit Concat Constraint propagated.");
#endif
   
   TRUInt* xLow;
   TRUInt* xUp;
   TRUInt* yLow;
   TRUInt* yUp;
   TRUInt* zLow;
   TRUInt* zUp;
   [_x getUp:&xUp andLow:&xLow];
   [_y getUp:&yUp andLow:&yLow];
   [_z getUp:&zUp andLow:&zLow];
   
   unsigned int xWordLength = [_x getWordLength];
   unsigned int yWordLength = [_y getWordLength];
   unsigned int zWordLength = [_z getWordLength];
   
//   ORUInt xBitLength = [_x bitLength];
//   ORUInt yBitLength = [_y bitLength];
//   ORUInt zBitLength = [_z bitLength];
   
   unsigned int* newXUp = alloca(sizeof(unsigned int)*xWordLength);
   unsigned int* newXLow = alloca(sizeof(unsigned int)*xWordLength);
   unsigned int* newYUp = alloca(sizeof(unsigned int)*yWordLength);
   unsigned int* newYLow = alloca(sizeof(unsigned int)*yWordLength);
   unsigned int* zUpForX = alloca(sizeof(unsigned int)*zWordLength);
   unsigned int* zLowForX = alloca(sizeof(unsigned int)*zWordLength);
   unsigned int* zUpForY = alloca(sizeof(unsigned int)*zWordLength);
   unsigned int* zLowForY = alloca(sizeof(unsigned int)*zWordLength);
   unsigned int* newZUp = alloca(sizeof(unsigned int)*zWordLength);
   unsigned int* newZLow = alloca(sizeof(unsigned int)*zWordLength);
//   unsigned int  upXORlow;
   
//   NSLog(@"*******************************************");
//   NSLog(@"x|y = z");
//   NSLog(@"x=%@\n",_x);
//   NSLog(@"y=%@\n",_y);
//   NSLog(@"z=%@\n\n",_z);

   
   for(int i=0;i<zWordLength;i++){
      newZUp[i] = zUp[i]._val;
      newZLow[i] = zLow[i]._val;
   }
   
   for(int i=0;i<yWordLength;i++){
      zUpForY[i] = zUp[i]._val;
      zLowForY[i] = zLow[i]._val;
   }
   ORUInt mask = CP_UMASK;
   mask >>= 32 - ([_y bitLength]%32);
   zUpForY[yWordLength-1] &= mask;
   zLowForY[yWordLength-1] &= mask;
   
   int xWordShift = ([_y bitLength]/32);
   
   int xBitShift = ([_y bitLength]%32);
   for(int i=0;i<xWordLength;i++){
      zUpForX[i] = zUp[i+xWordShift]._val>>xBitShift;
      zLowForX[i] = zLow[i+xWordShift]._val>>xBitShift;
      if (xBitShift!=0 && ((i+1) < xWordLength)) {
         zUpForX[i] &= zUp[i+xWordShift+1]._val << (32 - xBitShift);
         zLowForX[i] |= zLow[i+xWordShift+1]._val << (32 - xBitShift);
      }
   }
   mask = CP_UMASK;
   mask >>= 32 - [_x bitLength]%32;
   zUpForX[xWordLength-1] &= mask;
   zLowForX[xWordLength-1] &= mask;
   
   for(int i=0;i<xWordLength;i++){
      newXUp[i] = xUp[i]._val & zUpForX[i];
      newXLow[i] = xLow[i]._val | zLowForX[i];
//      upXORlow = newXUp[i] ^ newXLow[i];
//      if(((upXORlow & (~newXUp[i])) & (upXORlow & newXLow[i])) != 0){
//         failNow();
//      }
   }
   
   
   
   for(int i=0;i<yWordLength;i++){
      newYUp[i] = yUp[i]._val & zUpForY[i];
      newYLow[i] = yLow[i]._val | zLowForY[i];
//      upXORlow = newXUp[i] ^ newXLow[i];
//      if(((upXORlow & (~newYUp[i])) & (upXORlow & newYLow[i])) != 0){
//         failNow();
//      }
   }
   mask = CP_UMASK;
   mask >>= 32 - xBitShift;
   for(int i=0;i<yWordLength;i++){
      newZUp[i] &= (yUp[i]._val & mask) | ~mask;
      newZLow[i] |= (yLow[i]._val & mask);
   }
   
   mask = CP_UMASK;
   mask = (CP_UMASK >> (32 - [_x bitLength])) << xBitShift;
   //   newZUp[yWordLength-1] &= mask;
   //   newZLow[yWordLength-1] &= mask;
   
   //fix for bv not on 32 bit boundary
   for(int i=0;i<zWordLength;i++){
      newZUp[i+xWordShift] &= ((xUp[i]._val<<xBitShift) & mask) | ~mask;//>>xBitShift;
      newZLow[i+xWordShift] |= (xLow[i]._val<<xBitShift) & mask;//>>xBitShift;
      if (xBitShift!=0 && ((i-1) < xWordLength)) {
         newZUp[i+xWordShift] &= newXUp[i-1] << (32 - xBitShift);
         newZLow[i+xWordShift] |= newXLow[i-1] << (32 - xBitShift);
      }
   }
   
//   NSLog(@"%@\n",bitvar2NSString(newZLow, newZUp, zBitLength));
//   for(int i=0;i<zWordLength;i++){
//      upXORlow = newZUp[i] ^ newZLow[i];
//      if(((upXORlow & (~newZUp[i])) & (upXORlow & newZLow[i])) != 0){
//         failNow();
//      }
//   }
   
//   NSLog(@"newX = %@",bitvar2NSString(newXLow, newXUp, xBitLength));
//   NSLog(@"newY = %@",bitvar2NSString(newYLow, newYUp, yBitLength));
//   NSLog(@"newZ = %@",bitvar2NSString(newZLow, newZUp, zBitLength));

   _state[0] = newXUp;
   _state[1] = newXLow;
   _state[2] = newYUp;
   _state[3] = newYLow;
   _state[4] = newZUp;
   _state[5] = newZLow;
   
   ORBool xFail = checkDomainConsistency(_x, newXLow, newXUp, xWordLength, self);
   ORBool yFail = checkDomainConsistency(_y, newYLow, newYUp, yWordLength, self);
   ORBool zFail = checkDomainConsistency(_z, newZLow, newZUp, zWordLength, self);
   
   if (xFail || yFail || zFail) {
      failNow();
   }
   
   [_x setUp:newXUp andLow:newXLow for:self];
   [_y setUp:newYUp andLow:newYLow for:self];
   [_z setUp:newZUp andLow:newZLow for:self];
   
}
@end

@implementation CPBitLT
-(id) initCPBitLT:(CPBitVarI *)x LT:(CPBitVarI *)y eval:(CPBitVarI *)z{
   self = [super initCPBitCoreConstraint:[x engine]];
   _x = x;
   _y = y;
   _z = z;
   _state = malloc(sizeof(ORUInt*)*6);
   
   return self;
   
}
-(NSString*) description
{
   NSMutableString* string = [NSMutableString stringWithString:[super description]];
   [string appendString:[NSString stringWithFormat:@" with %@, and %@ and %@",_x, _y, _z]];
   
   return string;
}

-(CPBitAntecedents*) getAntecedents:(CPBitAssignment*)assignment{
   return ([self getAntecedentsFor:assignment withState:_state]);
}
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment withState:(ORUInt**)state
{
  //NSLog(@"Implication for 0x%lx[%u] = %@  traced back through %@", (unsigned long)assignment->var, assignment->index, (CPBitVarI*)assignment->var, self);
   ORUInt wordLength = [_x getWordLength];
   ORUInt bitLength = [_x bitLength];
   
   CPBitAntecedents* ants = malloc(sizeof(CPBitAntecedents));
   CPBitAssignment** vars;
   vars = malloc(sizeof(CPBitAssignment*)*(wordLength*BITSPERWORD*2+1));
   ants->numAntecedents = 0;
   ants->antecedents = vars;
   
   ORInt index = assignment->index;
   ORInt diffIndex =0;

   TRUInt* xUp;
   TRUInt* xLow;
   TRUInt* yUp;
   TRUInt* yLow;
   TRUInt* zUp;
   TRUInt* zLow;
   
   [_x getUp:&xUp andLow:&xLow];
   [_y getUp:&yUp andLow:&yLow];
   [_z getUp:&zUp andLow:&zLow];
   
   ORUInt* x1y0 = alloca(sizeof(ORUInt)*wordLength);
   ORInt idx=0;
   for(int i=wordLength-1;i>=0;i--){
      x1y0[i] = (xLow[i]._val & ~yUp[i]._val);
      if(x1y0[i] != 0){
         idx = (i*BITSPERWORD)+(BITSPERWORD - __builtin_clz(x1y0[i])-1);
         break;
      }
   }
   
//   NSLog(@"                                             3322222222221111111111");
//   NSLog(@"                                             10987654321098765432109876543210");
//   if(assignment->var == _x)
//      NSLog(@"%@[%d]=%d",_x,assignment->index, assignment->value);
//   else
//      NSLog(@"%@",_x);
//   
//   if(assignment->var == _y)
//      NSLog(@"%@[%d]=%d",_y,assignment->index, assignment->value);
//   else
//      NSLog(@"%@",_y);

   ORBool xAtIndex, yAtIndex, zAt0;
   xAtIndex = yAtIndex = zAt0 = false;

   if(assignment->var == _x){
      if (![_y isFree:index] || (~ISFREE(state[2][index/BITSPERWORD], state[3][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD)))) {
         yAtIndex = true;
//         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
//         vars[ants->numAntecedents]->index = index;
//         vars[ants->numAntecedents]->var = _y;
         if(![_y isFree:index])
            vars[ants->numAntecedents]->value = [_y getBit:index];
         else
            vars[ants->numAntecedents]->value = !((ISTRUE(state[2][index/BITSPERWORD], state[3][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD))) == 0);
         if ((index>idx) && (assignment->value == 0) && (vars[ants->numAntecedents]->value == 1))
//         if ((index>idx) && (assignment->value == 0) && ([_y getBit:index]))
            index=idx-1;
//         ants->numAntecedents++;
      }
      if (![_z isFree:0] || (~ISFREE(state[4][0], state[5][0]) & 0x1)) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->index = 0;
         vars[ants->numAntecedents]->var = _z;
         if(![_z isFree:0])
            vars[ants->numAntecedents]->value = [_z getBit:0];
         else
            vars[ants->numAntecedents]->value = !((ISTRUE(state[4][0], state[5][0]) & 0x1) == 0);
         ants->numAntecedents++;
      }
   }
   else if(assignment->var == _y){
      if (![_x isFree:index] || (~ISFREE(state[0][index/BITSPERWORD], state[1][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD)))) {
         xAtIndex = true;
//         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
//         vars[ants->numAntecedents]->index = index;
//         vars[ants->numAntecedents]->var = _x;
         if(![_x isFree:index])
            vars[ants->numAntecedents]->value = [_x getBit:index];
         else
            vars[ants->numAntecedents]->value = !((ISTRUE(state[0][index/BITSPERWORD], state[1][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD))) == 0);
         if ((index>idx) && (assignment->value == 1) && (vars[ants->numAntecedents]->value == 0))
            index=idx-1;
//         ants->numAntecedents++;
      }
      if (![_z isFree:0] || (~ISFREE(state[4][0], state[5][0]) & 0x1)) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->index = 0;
         vars[ants->numAntecedents]->var = _z;
         if(![_z isFree:0])
            vars[ants->numAntecedents]->value = [_z getBit:0];
         else
            vars[ants->numAntecedents]->value = !((ISTRUE(state[4][0], state[5][0]) & 0x1) == 0);
         ants->numAntecedents++;
      }
   }
   else if(assignment->var == _z){
      ORUInt* different = alloca(sizeof(ORUInt)*wordLength);
      for(int i=wordLength-1;i>=0;i--){
         different[i] = (state[0][i] ^ state[2][i]) | (state[1][i] ^ state[3][i]);
         if(different[i] != 0){
            diffIndex = (i*BITSPERWORD)+(BITSPERWORD - __builtin_clz(different[i])-1);
            break;
         }
      }
      if(![_z getBit:0])
         index = diffIndex;
      else
         index = idx;

         if (![_x isFree:index] || (~ISFREE(state[0][index/BITSPERWORD], state[1][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD)))) {
            xAtIndex = true;
//            vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
//            vars[ants->numAntecedents]->index = index;
//            vars[ants->numAntecedents]->var = _x;
//            if(![_x isFree:index])
//               vars[ants->numAntecedents]->value = [_x getBit:index];
//            else
//               vars[ants->numAntecedents]->value = !((ISTRUE(state[0][index/BITSPERWORD], state[1][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD))) == 0);
//            ants->numAntecedents++;
         }
         if (![_y isFree:index] || (~ISFREE(state[2][index/BITSPERWORD], state[3][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD)))) {
            yAtIndex = true;
//            vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
//            vars[ants->numAntecedents]->index = index;
//            vars[ants->numAntecedents]->var = _y;
//            if(![_y isFree:index])
//               vars[ants->numAntecedents]->value = [_y getBit:index];
//            else
//               vars[ants->numAntecedents]->value = !((ISTRUE(state[2][index/BITSPERWORD], state[3][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD))) == 0);
//            ants->numAntecedents++;
         }
   }
//   if((assignment->var == _y) && (assignment->value == 1) && [_y bound] && (__builtin_popcount(yUp[0]._val & yLow[0]._val)==1))
//      for(int i=0; i<index;i++){
//         if(![_y isFree:i]){
//            vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
//            vars[ants->numAntecedents]->index = i;
//            vars[ants->numAntecedents]->var = _y;
//            vars[ants->numAntecedents]->value = [_y getBit:i];
//            ants->numAntecedents++;
//         }
//      }
   
//   for(int i=index+1;i<bitLength;i++){
//      if(i==assignment->index)
//         continue;
   for(int i=index; i<bitLength;i++){
      if(((i==assignment->index) && xAtIndex) || ((i!=assignment->index) && (![_x isFree:i] || (~ISFREE(state[0][i/BITSPERWORD], state[1][i/BITSPERWORD]) & (0x1 << (i%BITSPERWORD)))))) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->index = i;
         vars[ants->numAntecedents]->var = _x;
         if(![_x isFree:i])
            vars[ants->numAntecedents]->value = [_x getBit:i];
         else
            vars[ants->numAntecedents]->value = !((ISTRUE(state[0][i/BITSPERWORD], state[1][i/BITSPERWORD]) & (0x1 << (i%BITSPERWORD))) == 0);
         ants->numAntecedents++;
      }
      if (((i==assignment->index) && yAtIndex) || ((i!=assignment->index) && (![_y isFree:i] || (~ISFREE(state[2][i/BITSPERWORD], state[3][i/BITSPERWORD]) & (0x1 << (i%BITSPERWORD)))))) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->index = i;
         vars[ants->numAntecedents]->var = _y;
         if(![_y isFree:i])
            vars[ants->numAntecedents]->value = [_y getBit:i];
         else
            vars[ants->numAntecedents]->value = !((ISTRUE(state[2][i/BITSPERWORD], state[3][i/BITSPERWORD]) & (0x1 << (i%BITSPERWORD))) == 0);
         ants->numAntecedents++;
      }
   }
//   if(ants->numAntecedents > (wordLength*BITSPERWORD*2+1))
//   if((assignment->var == _z) && (assignment->value == 1))
//      NSLog(@"%d  %d",ants->numAntecedents,2*(32-assignment->index));
   return ants;
}

-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment
{
  //NSLog(@"Implication for 0x%lx[%u] = %@  traced back through %@", (unsigned long)assignment->var, assignment->index, (CPBitVarI*)assignment->var, self);
   ORUInt wordLength = [_x getWordLength];
   ORUInt bitLength = [_x bitLength];
   
   CPBitAntecedents* ants = malloc(sizeof(CPBitAntecedents));
   CPBitAssignment** vars;
   vars = malloc(sizeof(CPBitAssignment*)*(wordLength*BITSPERWORD*2+1));
   ants->numAntecedents = 0;
   ants->antecedents = vars;
   
   TRUInt* xUp;
   TRUInt* xLow;
   TRUInt* yUp;
   TRUInt* yLow;
   TRUInt* zUp;
   TRUInt* zLow;
   
   [_x getUp:&xUp andLow:&xLow];
   [_y getUp:&yUp andLow:&yLow];
   [_z getUp:&zUp andLow:&zLow];
   
   ORInt index = assignment->index;
   
   ORUInt* x1y0 = alloca(sizeof(ORUInt)*wordLength);
   ORInt idx=0;
   for(int i=wordLength-1;i>=0;i--){
      x1y0[i] = (xLow[i]._val & ~yUp[i]._val);
      if(x1y0[i] != 0){
         idx = (i*BITSPERWORD)+(BITSPERWORD - __builtin_clz(x1y0[i])-1);
         break;
      }
   }

   
//   NSLog(@"                                             3322222222221111111111");
//   NSLog(@"                                             10987654321098765432109876543210");
//   if(assignment->var == _x)
//      NSLog(@"%@[%d]=%d",_x,assignment->index, assignment->value);
//   else
//      NSLog(@"%@",_x);
//   
//   if(assignment->var == _y)
//      NSLog(@"%@[%d]=%d",_y,assignment->index, assignment->value);
//   else
//      NSLog(@"%@",_y);
   
   
   ORBool xAtIndex, yAtIndex, zAt0;
   xAtIndex = yAtIndex = zAt0 = false;

   if(assignment->var == _x){
      if(![_y isFree:index]){
         yAtIndex = true;
//         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
//         vars[ants->numAntecedents]->index = index;
//         vars[ants->numAntecedents]->var = _y;
//         vars[ants->numAntecedents]->value = [_y getBit:index];
         if ((index>idx) && !assignment->value && [_y getBit:index])
            index=idx;
//         ants->numAntecedents++;
      }
      if(![_z isFree:0]){
//         zAt0 = true;
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->index = 0;
         vars[ants->numAntecedents]->var = _z;
         vars[ants->numAntecedents]->value = [_z getBit:0];
         ants->numAntecedents++;
      }
   }
   else if(assignment->var == _y){
      if(![_x isFree:index]){
         xAtIndex = true;
//         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
//         vars[ants->numAntecedents]->index = index;
//         vars[ants->numAntecedents]->var = _x;
//         vars[ants->numAntecedents]->value = [_x getBit:index];
         if((index>idx) && assignment->value && ![_x getBit:index])
            index=idx;
//         ants->numAntecedents++;
      }
      if(![_z isFree:0]){
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->index = 0;
         vars[ants->numAntecedents]->var = _z;
         vars[ants->numAntecedents]->value = [_z getBit:0];
         ants->numAntecedents++;
      }
   }
   else if(assignment->var == _z){
      ORUInt* different = alloca(sizeof(ORUInt)*wordLength);
      ORInt diffIndex =0;
      for(int i=wordLength-1;i>=0;i--){
         different[i] = (xUp[i]._val ^ yUp[i]._val) | (xLow[i]._val ^ yLow[i]._val);
         if(different[i] != 0){
            diffIndex = (i*BITSPERWORD)+(BITSPERWORD - __builtin_clz(different[i])-1);
            break;
         }
      }
      if([_z getBit:0] == false)
         index = diffIndex;
      else
         index = idx;
      if(![_x isFree:index]){
         xAtIndex = true;
//         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
//         vars[ants->numAntecedents]->index = index;
//         vars[ants->numAntecedents]->var = _x;
//         vars[ants->numAntecedents]->value = [_x getBit:index];
//         ants->numAntecedents++;
      }
      if(![_y isFree:index]){
         yAtIndex = true;
//         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
//         vars[ants->numAntecedents]->index = index;
//         vars[ants->numAntecedents]->var = _y;
//         vars[ants->numAntecedents]->value = [_y getBit:index];
//         ants->numAntecedents++;
      }
   }
   
//   if((assignment->var == _y) && (assignment->value == 1) && [_y bound] && (__builtin_popcount(yUp[0]._val & yLow[0]._val)==1))
//      for(int i=0; i<index;i++){
//         if(![_y isFree:i]){
//            vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
//            vars[ants->numAntecedents]->index = i;
//            vars[ants->numAntecedents]->var = _y;
//            vars[ants->numAntecedents]->value = [_y getBit:i];
//            ants->numAntecedents++;
//         }
//      }
   
//   for(int i=index+1;i<bitLength;i++){
//      if(i==assignment->index)
//         continue;
   for(int i=index; i<bitLength;i++){
      if(((i!=assignment->index) && ![_x isFree:i]) || ((i==assignment->index) && xAtIndex)){
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->index = i;
         vars[ants->numAntecedents]->var = _x;
         vars[ants->numAntecedents]->value = [_x getBit:i];
         ants->numAntecedents++;
      }
      if(((i!=assignment->index) && ![_y isFree:i]) || ((i==assignment->index) && yAtIndex)){
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->index = i;
         vars[ants->numAntecedents]->var = _y;
         vars[ants->numAntecedents]->value = [_y getBit:i];
         ants->numAntecedents++;
      }
   }
//   if(ants->numAntecedents > (wordLength*BITSPERWORD*2+1))
//   if((assignment->var == _z) && (assignment->value == 1))
//      NSLog(@"%d  %d",ants->numAntecedents,2*(32-assignment->index));
   return ants;
}

- (void) dealloc
{
   [super dealloc];
   free(_state);
}

-(void) post
{
   [self propagate];
   if (![_x bound])
      [_x whenChangePropagate: self];
   if (![_y bound])
      [_y whenChangePropagate: self];
   if (![_z bound])
      [_z whenChangePropagate: self];
   [self propagate];
//   return ORSuspend;
}
-(void) propagate
{
#ifdef BIT_DEBUG
   NSLog(@"**********************************");
   NSLog(@"Bit < Constraint propagated.");
#endif
   
   unsigned int wordLength = [_x getWordLength];
//   unsigned int bitLength = [_x bitLength];
   unsigned int zWordLength = [_z getWordLength];
//   unsigned int zBitLength = [_z bitLength];
   
   TRUInt* xLow;
   TRUInt* xUp;
   TRUInt* yLow;
   TRUInt* yUp;
   TRUInt* zLow;
   TRUInt* zUp;
   
   [_x getUp:&xUp andLow:&xLow];
   [_y getUp:&yUp andLow:&yLow];
   [_z getUp:&zUp andLow:&zLow];
   
   unsigned int* newXUp = alloca(sizeof(unsigned int)*wordLength);
   unsigned int* newXLow = alloca(sizeof(unsigned int)*wordLength);
   unsigned int* newYUp = alloca(sizeof(unsigned int)*wordLength);
   unsigned int* newYLow = alloca(sizeof(unsigned int)*wordLength);
   unsigned int* newZUp = alloca(sizeof(unsigned int)*zWordLength);
   unsigned int* newZLow = alloca(sizeof(unsigned int)*zWordLength);
   
//      NSLog(@"*******************************************");
//      NSLog(@"x < y ? z");
//      NSLog(@"x=%@\n",_x);
//      NSLog(@"y=%@\n",_y);
//      NSLog(@"z=%@\n\n",_z);
   
   for (int i=0; i<wordLength; i++) {
      newXUp[i] = xUp[i]._val;
      newXLow[i] = xLow[i]._val;
      newYUp[i] = yUp[i]._val;
      newYLow[i] = yLow[i]._val;
   }
   
   
   for(int i=0;i<zWordLength;i++){
      newZUp[i] = zUp[i]._val;
      newZLow[i] = zLow[i]._val;
   }
   
   ORBool xlty = false;
   ORBool xgty = false;
   ORBool xeqy = true;
   
   
   for (int i=wordLength-1; i>=0; i--) {
      if (((newXUp[i] ^ newXLow[i]) | (newYUp[i]^ newYLow[i]) | (newXLow[i] ^ newYLow[i])) == 0)
         continue;
      else
         xeqy = false;
      if (xLow[i]._val > yUp[i]._val) {
         xgty = true;
         break;
      }
      else if ( xUp[i]._val < yLow[i]._val) {
         xlty = true;
         break;
      }
   }
   
   if(xlty){
      newZLow[0] |= 0x1;
   }
   if(xgty || xeqy){
      for (int i=0; i<zWordLength; i++)
         newZUp[i] = 0;
   }
   
   _state[0] = newXUp;
   _state[1] = newXLow;
   _state[2] = newYUp;
   _state[3] = newYLow;
   _state[4] = newZUp;
   _state[5] = newZLow;

   checkDomainConsistency(_z, newZLow, newZUp, zWordLength, self);
   [_z setUp:newZUp andLow:newZLow for:self];
   
   ORUInt *freeX = alloca(sizeof(ORUInt)*wordLength);
   ORUInt *freeY = alloca(sizeof(ORUInt)*wordLength);
   ORUInt *different = alloca(sizeof(ORUInt)*wordLength);
   
   ORUInt numFreeBitsX = 0;
   ORUInt numFreeBitsY = 0;
   
   //Find most sig. unset bit in x
   for(ORInt i = wordLength-1;i>=0;i--){
      freeX[i] = xUp[i]._val ^ xLow[i]._val;
      numFreeBitsX += __builtin_popcount(freeX[i]);
   }
   //Find most sig. unset bit in y
   for(ORInt i = wordLength-1;i>=0;i--){
      freeY[i] = yUp[i]._val ^ yLow[i]._val;
      numFreeBitsY += __builtin_popcount(freeY[i]);
   }
   
   //Find bits that are different in x and y
   for (int i=0;i<wordLength;i++)
      different[i] = (newXUp[i] ^ newYUp[i]) | (newXLow[i] ^ newYLow[i]);
   ORInt diffIndex;
   ORBool more;
   
   if(numFreeBitsX != 0){
      do{
         diffIndex =-1;
         for(int i=wordLength-1;i>=0;i--){
            if(different[i] != 0){
               diffIndex = (BITSPERWORD - __builtin_clz(different[i]))-1;
               break;
            }
         }
         if(diffIndex < 0){
            break;
         }

         more = false;
         //Find most sig unset bit in x
         ORInt bitIndex = -1;
         ORUInt wordIndex = 0;
         for(int i=wordLength-1;i>=0;i--){
            if(freeX[i] != 0){
               bitIndex = (BITSPERWORD - __builtin_clz(freeX[i]))-1;
               wordIndex = i;
               break;
            }
         }
         
         if(bitIndex < 0)
            break;
         
         ORUInt mask = 0x1 << bitIndex;
         if(diffIndex <= bitIndex){
            //Can we fix bit?
            ORUInt temp;
            
            if(zLow[0]._val){
               temp = newXLow[wordIndex] | mask;
               if(temp >= newYUp[wordIndex]){
                  newXUp[wordIndex] &= ~mask;
                  freeX[wordIndex] &= ~mask;
                  different[wordIndex] = (newXUp[wordIndex] ^ newYUp[wordIndex]) | (newXLow[wordIndex] ^ newYLow[wordIndex]);
                  numFreeBitsX--;
                  more = true;
                  _state[0] = newXUp;
                  _state[1] = newXLow;
                  _state[2] = newYUp;
                  _state[3] = newYLow;
                  _state[4] = newZUp;
                  _state[5] = newZLow;

                  checkDomainConsistency(_x, newXLow, newXUp, wordLength, self);
                  [_x setUp:newXUp andLow:newXLow for:self];
               }
//               else if(temp >= newYLow[wordIndex] && (numFreeBitsY == 0)){
//                  newXUp[wordIndex] &= ~mask;
//                  freeX[wordIndex] &= ~mask;
//                  different[wordIndex] = (newXUp[wordIndex] ^ newYUp[wordIndex]) | (newXLow[wordIndex] ^ newYLow[wordIndex]);
//                  numFreeBitsX--;
//                  more = true;
//               }

            }
            else if (zUp[0]._val == 0){
               temp = newXUp[wordIndex] & ~mask;
               //x must be >= y
               if(temp < newYLow[wordIndex]){
                  newXLow[wordIndex] |= mask;
                  freeX[wordIndex] &= ~mask;
                  different[wordIndex] = (newXUp[wordIndex] ^ newYUp[wordIndex]) | (newXLow[wordIndex] ^ newYLow[wordIndex]);
                  numFreeBitsX--;
                  more = true;
                  _state[0] = newXUp;
                  _state[1] = newXLow;
                  _state[2] = newYUp;
                  _state[3] = newYLow;
                  _state[4] = newZUp;
                  _state[5] = newZLow;
                  
                  checkDomainConsistency(_x, newXLow, newXUp, wordLength, self);
                  [_x setUp:newXUp andLow:newXLow for:self];
               }
            }
         }
      }while(more);
   }
   
   if(numFreeBitsY != 0){
      do{
         diffIndex =-1;
         for(int i=wordLength-1;i>=0;i--){
            if(different[i] != 0){
               diffIndex = (BITSPERWORD - __builtin_clz(different[i])-1);
               break;
            }
         }
         if(diffIndex < 0){
            break;
         }
         
         more = false;
         //Find most sig unset bit in x
         ORInt bitIndex = -1;
         ORUInt wordIndex = 0;
         for(int i=wordLength-1;i>=0;i--){
            if(freeY[i] != 0){
               bitIndex = (BITSPERWORD - __builtin_clz(freeY[i])-1);
               wordIndex = i;
               break;
            }
         }
         
         if(bitIndex < 0)
            break;
         
         ORUInt mask = 0x1 << bitIndex;
         if(diffIndex <= bitIndex){
            //Can we fix bit?
            ORUInt temp;
            
            if(zLow[0]._val){ // If x < y = t, then will clearing this bit make xmin > ymax?
               temp = newYUp[wordIndex] & ~mask;
               if(temp <= newXLow[wordIndex]){
                  newYLow[wordIndex] |= mask;
                  freeY[wordIndex] &= ~mask;
                  different[wordIndex] = (newXUp[wordIndex] ^ newYUp[wordIndex]) | (newXLow[wordIndex] ^ newYLow[wordIndex]);
                  numFreeBitsY--;
                  more = true;
                  _state[0] = newXUp;
                  _state[1] = newXLow;
                  _state[2] = newYUp;
                  _state[3] = newYLow;
                  _state[4] = newZUp;
                  _state[5] = newZLow;
                  
                  checkDomainConsistency(_y, newYLow, newYUp, wordLength, self);
                  [_y setUp:newYUp andLow:newYLow for:self];
               }
            }
            else if (zUp[0]._val == 0){
               temp = newYLow[wordIndex] | mask;
               //x must be >= y
               if(temp > newXUp[wordIndex]){//if we set bit in y is ymin > xmax?
                  newYUp[wordIndex] &= ~mask;
                  freeY[wordIndex] &= ~mask;
                  different[wordIndex] = (newXUp[wordIndex] ^ newYUp[wordIndex]) | (newXLow[wordIndex] ^ newYLow[wordIndex]);
                  numFreeBitsY--;
                  more = true;
                  _state[0] = newXUp;
                  _state[1] = newXLow;
                  _state[2] = newYUp;
                  _state[3] = newYLow;
                  _state[4] = newZUp;
                  _state[5] = newZLow;
                  
                  checkDomainConsistency(_y, newYLow, newYUp, wordLength, self);
                  [_y setUp:newYUp andLow:newYLow for:self];
               }
            }
         }
      }while(more);
   }
   

   
//      NSLog(@"newX =          %@",bitvar2NSString(newXLow, newXUp, bitLength));
//      NSLog(@"newY =          %@",bitvar2NSString(newYLow, newYUp, bitLength));
//      NSLog(@"newZ =          %@",bitvar2NSString(newZLow, newZUp, zBitLength));
//   
//   if ((newXLow[0] != xLow->_val) || (newXUp[0] != xUp->_val) || (newYLow[0] != yLow->_val) || (newYUp[0] != yUp->_val))
//      NSLog(@"");
   
#ifdef BIT_DEBUG
   //   NSLog(@"      X =%@",_x);
   //   NSLog(@"   <  Y =%@",_y);
   //   NSLog(@"   =  Z =%@\n\n",_z);
#endif
   
   _state[0] = newXUp;
   _state[1] = newXLow;
   _state[2] = newYUp;
   _state[3] = newYLow;
   _state[4] = newZUp;
   _state[5] = newZLow;
   
   ORBool xFail = checkDomainConsistency(_x, newXLow, newXUp, wordLength, self);
   ORBool yFail = checkDomainConsistency(_y, newYLow, newYUp, wordLength, self);
   ORBool zFail = checkDomainConsistency(_z, newZLow, newZUp, zWordLength, self);
   if (xFail || yFail || zFail) {
      failNow();
   }
   
   [_x setUp:newXUp andLow:newXLow for:self];
   [_y setUp:newYUp andLow:newYLow for:self];
   [_z setUp:newZUp andLow:newZLow for:self];
   
   //   NSLog(@"x=%@\n",_x);
   //   NSLog(@"y=%@\n",_y);
   //   NSLog(@"z=%@\n\n",_z);
   
}


@end

@implementation CPBitLE
-(id) initCPBitLE:(CPBitVarI *)x LE:(CPBitVarI *)y eval:(CPBitVarI *)z{
   self = [super initCPBitCoreConstraint:[x engine]];
   _x = x;
   _y = y;
   _z = z;
   _state = malloc(sizeof(ORUInt*)*6);
   return self;
   
}
-(NSString*) description
{
   NSMutableString* string = [NSMutableString stringWithString:[super description]];
   [string appendString:[NSString stringWithFormat:@" with %@, and %@ and %@",_x, _y, _z]];
   
   return string;
}

-(CPBitAntecedents*) getAntecedents:(CPBitAssignment*)assignment{
   return ([self getAntecedentsFor:assignment withState:_state]);
}
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment withState:(ORUInt**)state
{
   //NSLog(@"Implication for 0x%lx[%u] = %@  traced back through %@", (unsigned long)assignment->var, assignment->index, (CPBitVarI*)assignment->var, self);
   ORUInt wordLength = [_x getWordLength];
   ORUInt bitLength = [_x bitLength];
   
   CPBitAntecedents* ants = malloc(sizeof(CPBitAntecedents));
   CPBitAssignment** vars;
   vars = malloc(sizeof(CPBitAssignment*)*(wordLength*BITSPERWORD*2+1));
   ants->numAntecedents = 0;
   ants->antecedents = vars;
   
   ORInt index = assignment->index;
   ORInt diffIndex =0;
   
   TRUInt* xUp;
   TRUInt* xLow;
   TRUInt* yUp;
   TRUInt* yLow;
   TRUInt* zUp;
   TRUInt* zLow;
   
   [_x getUp:&xUp andLow:&xLow];
   [_y getUp:&yUp andLow:&yLow];
   [_z getUp:&zUp andLow:&zLow];
   
   ORUInt* x1y0 = alloca(sizeof(ORUInt)*wordLength);
   ORInt idx=0;
   for(int i=wordLength-1;i>=0;i--){
      x1y0[i] = (xLow[i]._val & ~yUp[i]._val);
      if(x1y0[i] != 0){
         idx = (i*BITSPERWORD)+(BITSPERWORD - __builtin_clz(x1y0[i])-1);
         break;
      }
   }
   
//      NSLog(@"                                             3322222222221111111111");
//      NSLog(@"                                             10987654321098765432109876543210");
//      if(assignment->var == _x)
//         NSLog(@"%@[%d]=%d",_x,assignment->index, assignment->value);
//      else
//         NSLog(@"%@",_x);
//   
//      if(assignment->var == _y)
//         NSLog(@"%@[%d]=%d",_y,assignment->index, assignment->value);
//      else
//         NSLog(@"%@",_y);
   
   ORBool xAtIndex, yAtIndex, zAt0;
   xAtIndex = yAtIndex = zAt0 = false;
   
   if(assignment->var == _x){
      if (![_y isFree:index] || (~ISFREE(state[2][index/BITSPERWORD], state[3][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD)))) {
         yAtIndex = true;
         //         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         //         vars[ants->numAntecedents]->index = index;
         //         vars[ants->numAntecedents]->var = _y;
         if(![_y isFree:index])
            vars[ants->numAntecedents]->value = [_y getBit:index];
         else
            vars[ants->numAntecedents]->value = !((ISTRUE(state[2][index/BITSPERWORD], state[3][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD))) == 0);
         if ((index>idx) && (assignment->value == 0) && (vars[ants->numAntecedents]->value == 1))
            //         if ((index>idx) && (assignment->value == 0) && ([_y getBit:index]))
            index=idx-1;
         //         ants->numAntecedents++;
      }
      if (![_z isFree:0] || (~ISFREE(state[4][0], state[5][0]) & 0x1)) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->index = 0;
         vars[ants->numAntecedents]->var = _z;
         if(![_z isFree:0])
            vars[ants->numAntecedents]->value = [_z getBit:0];
         else
            vars[ants->numAntecedents]->value = !((ISTRUE(state[4][0], state[5][0]) & 0x1) == 0);
         ants->numAntecedents++;
      }
   }
   else if(assignment->var == _y){
      if (![_x isFree:index] || (~ISFREE(state[0][index/BITSPERWORD], state[1][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD)))) {
         xAtIndex = true;
         //         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         //         vars[ants->numAntecedents]->index = index;
         //         vars[ants->numAntecedents]->var = _x;
         if(![_x isFree:index])
            vars[ants->numAntecedents]->value = [_x getBit:index];
         else
            vars[ants->numAntecedents]->value = !((ISTRUE(state[0][index/BITSPERWORD], state[1][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD))) == 0);
         if ((index>idx) && (assignment->value == 1) && (vars[ants->numAntecedents]->value == 0))
            index=idx-1;
         //         ants->numAntecedents++;
      }
      if (![_z isFree:0] || (~ISFREE(state[4][0], state[5][0]) & 0x1)) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->index = 0;
         vars[ants->numAntecedents]->var = _z;
         if(![_z isFree:0])
            vars[ants->numAntecedents]->value = [_z getBit:0];
         else
            vars[ants->numAntecedents]->value = !((ISTRUE(state[4][0], state[5][0]) & 0x1) == 0);
         ants->numAntecedents++;
      }
   }
   else if(assignment->var == _z){
      ORUInt* different = alloca(sizeof(ORUInt)*wordLength);
      for(int i=wordLength-1;i>=0;i--){
         different[i] = (state[0][i] ^ state[2][i]) | (state[1][i] ^ state[3][i]);
         if(different[i] != 0){
            diffIndex = (i*BITSPERWORD)+(BITSPERWORD - __builtin_clz(different[i])-1);
            break;
         }
      }
      if(![_z getBit:0])
         index = diffIndex;
      else
         index = idx;
      
      if (![_x isFree:index] || (~ISFREE(state[0][index/BITSPERWORD], state[1][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD)))) {
         xAtIndex = true;
         //            vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         //            vars[ants->numAntecedents]->index = index;
         //            vars[ants->numAntecedents]->var = _x;
         //            if(![_x isFree:index])
         //               vars[ants->numAntecedents]->value = [_x getBit:index];
         //            else
         //               vars[ants->numAntecedents]->value = !((ISTRUE(state[0][index/BITSPERWORD], state[1][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD))) == 0);
         //            ants->numAntecedents++;
      }
      if (![_y isFree:index] || (~ISFREE(state[2][index/BITSPERWORD], state[3][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD)))) {
         yAtIndex = true;
         //            vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         //            vars[ants->numAntecedents]->index = index;
         //            vars[ants->numAntecedents]->var = _y;
         //            if(![_y isFree:index])
         //               vars[ants->numAntecedents]->value = [_y getBit:index];
         //            else
         //               vars[ants->numAntecedents]->value = !((ISTRUE(state[2][index/BITSPERWORD], state[3][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD))) == 0);
         //            ants->numAntecedents++;
      }
   }
   //   if((assignment->var == _y) && (assignment->value == 1) && [_y bound] && (__builtin_popcount(yUp[0]._val & yLow[0]._val)==1))
   //      for(int i=0; i<index;i++){
   //         if(![_y isFree:i]){
   //            vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
   //            vars[ants->numAntecedents]->index = i;
   //            vars[ants->numAntecedents]->var = _y;
   //            vars[ants->numAntecedents]->value = [_y getBit:i];
   //            ants->numAntecedents++;
   //         }
   //      }
   
   //   for(int i=index+1;i<bitLength;i++){
   //      if(i==assignment->index)
   //         continue;
   for(int i=index; i<bitLength;i++){
      if(((i==assignment->index) && xAtIndex) || ((i!=assignment->index) && (![_x isFree:i] || (~ISFREE(state[0][i/BITSPERWORD], state[1][i/BITSPERWORD]) & (0x1 << (i%BITSPERWORD)))))) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->index = i;
         vars[ants->numAntecedents]->var = _x;
         if(![_x isFree:i])
            vars[ants->numAntecedents]->value = [_x getBit:i];
         else
            vars[ants->numAntecedents]->value = !((ISTRUE(state[0][i/BITSPERWORD], state[1][i/BITSPERWORD]) & (0x1 << (i%BITSPERWORD))) == 0);
         ants->numAntecedents++;
      }
      if (((i==assignment->index) && yAtIndex) || ((i!=assignment->index) && (![_y isFree:i] || (~ISFREE(state[2][i/BITSPERWORD], state[3][i/BITSPERWORD]) & (0x1 << (i%BITSPERWORD)))))) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->index = i;
         vars[ants->numAntecedents]->var = _y;
         if(![_y isFree:i])
            vars[ants->numAntecedents]->value = [_y getBit:i];
         else
            vars[ants->numAntecedents]->value = !((ISTRUE(state[2][i/BITSPERWORD], state[3][i/BITSPERWORD]) & (0x1 << (i%BITSPERWORD))) == 0);
         ants->numAntecedents++;
      }
   }
   //   if(ants->numAntecedents > (wordLength*BITSPERWORD*2+1))
   //   if((assignment->var == _z) && (assignment->value == 1))
//         NSLog(@"%d  %d",ants->numAntecedents,2*(32-assignment->index));
   return ants;
}

-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment
{
   //NSLog(@"Implication for 0x%lx[%u] = %@  traced back through %@", (unsigned long)assignment->var, assignment->index, (CPBitVarI*)assignment->var, self);
   ORUInt wordLength = [_x getWordLength];
   ORUInt bitLength = [_x bitLength];
   
   CPBitAntecedents* ants = malloc(sizeof(CPBitAntecedents));
   CPBitAssignment** vars;
   vars = malloc(sizeof(CPBitAssignment*)*(wordLength*BITSPERWORD*2+1));
   ants->numAntecedents = 0;
   ants->antecedents = vars;
   
   TRUInt* xUp;
   TRUInt* xLow;
   TRUInt* yUp;
   TRUInt* yLow;
   TRUInt* zUp;
   TRUInt* zLow;
   
   [_x getUp:&xUp andLow:&xLow];
   [_y getUp:&yUp andLow:&yLow];
   [_z getUp:&zUp andLow:&zLow];
   
   ORInt index = assignment->index;
   
   ORUInt* x1y0 = alloca(sizeof(ORUInt)*wordLength);
   ORInt idx=0;
   for(int i=wordLength-1;i>=0;i--){
      x1y0[i] = (xLow[i]._val & ~yUp[i]._val);
      if(x1y0[i] != 0){
         idx = (i*BITSPERWORD)+(BITSPERWORD - __builtin_clz(x1y0[i])-1);
         break;
      }
   }
   
   
//      NSLog(@"                                             3322222222221111111111");
//      NSLog(@"                                             10987654321098765432109876543210");
//      if(assignment->var == _x)
//         NSLog(@"%@[%d]=%d",_x,assignment->index, assignment->value);
//      else
//         NSLog(@"%@",_x);
//   
//      if(assignment->var == _y)
//         NSLog(@"%@[%d]=%d",_y,assignment->index, assignment->value);
//      else
//         NSLog(@"%@",_y);
   
   
   ORBool xAtIndex, yAtIndex, zAt0;
   xAtIndex = yAtIndex = zAt0 = false;
   
   if(assignment->var == _x){
      if(![_y isFree:index]){
         yAtIndex = true;
         //         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         //         vars[ants->numAntecedents]->index = index;
         //         vars[ants->numAntecedents]->var = _y;
         //         vars[ants->numAntecedents]->value = [_y getBit:index];
         if ((index>idx) && !assignment->value && [_y getBit:index])
            index=idx;
         //         ants->numAntecedents++;
      }
      if(![_z isFree:0]){
         //         zAt0 = true;
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->index = 0;
         vars[ants->numAntecedents]->var = _z;
         vars[ants->numAntecedents]->value = [_z getBit:0];
         ants->numAntecedents++;
      }
   }
   else if(assignment->var == _y){
      if(![_x isFree:index]){
         xAtIndex = true;
         //         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         //         vars[ants->numAntecedents]->index = index;
         //         vars[ants->numAntecedents]->var = _x;
         //         vars[ants->numAntecedents]->value = [_x getBit:index];
         if((index>idx) && assignment->value && ![_x getBit:index])
            index=idx;
         //         ants->numAntecedents++;
      }
      if(![_z isFree:0]){
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->index = 0;
         vars[ants->numAntecedents]->var = _z;
         vars[ants->numAntecedents]->value = [_z getBit:0];
         ants->numAntecedents++;
      }
   }
   else if(assignment->var == _z){
      ORUInt* different = alloca(sizeof(ORUInt)*wordLength);
      ORInt diffIndex =0;
      for(int i=wordLength-1;i>=0;i--){
         different[i] = (xUp[i]._val ^ yUp[i]._val) | (xLow[i]._val ^ yLow[i]._val);
         if(different[i] != 0){
            diffIndex = (i*BITSPERWORD)+(BITSPERWORD - __builtin_clz(different[i])-1);
            break;
         }
      }
      if([_z getBit:0] == false)
         index = diffIndex;
      else
         index = idx;
      if(![_x isFree:index]){
         xAtIndex = true;
         //         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         //         vars[ants->numAntecedents]->index = index;
         //         vars[ants->numAntecedents]->var = _x;
         //         vars[ants->numAntecedents]->value = [_x getBit:index];
         //         ants->numAntecedents++;
      }
      if(![_y isFree:index]){
         yAtIndex = true;
         //         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         //         vars[ants->numAntecedents]->index = index;
         //         vars[ants->numAntecedents]->var = _y;
         //         vars[ants->numAntecedents]->value = [_y getBit:index];
         //         ants->numAntecedents++;
      }
   }
   
   //   if((assignment->var == _y) && (assignment->value == 1) && [_y bound] && (__builtin_popcount(yUp[0]._val & yLow[0]._val)==1))
   //      for(int i=0; i<index;i++){
   //         if(![_y isFree:i]){
   //            vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
   //            vars[ants->numAntecedents]->index = i;
   //            vars[ants->numAntecedents]->var = _y;
   //            vars[ants->numAntecedents]->value = [_y getBit:i];
   //            ants->numAntecedents++;
   //         }
   //      }
   
   //   for(int i=index+1;i<bitLength;i++){
   //      if(i==assignment->index)
   //         continue;
   for(int i=index; i<bitLength;i++){
      if(((i!=assignment->index) && ![_x isFree:i]) || ((i==assignment->index) && xAtIndex)){
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->index = i;
         vars[ants->numAntecedents]->var = _x;
         vars[ants->numAntecedents]->value = [_x getBit:i];
         ants->numAntecedents++;
      }
      if(((i!=assignment->index) && ![_y isFree:i]) || ((i==assignment->index) && yAtIndex)){
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->index = i;
         vars[ants->numAntecedents]->var = _y;
         vars[ants->numAntecedents]->value = [_y getBit:i];
         ants->numAntecedents++;
      }
   }
   //   if(ants->numAntecedents > (wordLength*BITSPERWORD*2+1))
   //   if((assignment->var == _z) && (assignment->value == 1))
//         NSLog(@"%d  %d",ants->numAntecedents,2*(32-assignment->index));
   return ants;
}


- (void) dealloc
{
   [super dealloc];
   free(_state);
}

-(void) post
{
   [self propagate];
   if (![_x bound])
      [_x whenChangePropagate: self];
   if (![_y bound])
      [_y whenChangePropagate: self];
   if (![_z bound])
      [_z whenChangePropagate: self];
   [self propagate];
//   return ORSuspend;
}
-(void) propagate
{
#ifdef BIT_DEBUG
   NSLog(@"**********************************");
   NSLog(@"Bit <= Constraint propagated.");
#endif
   
   unsigned int wordLength = [_x getWordLength];
//   unsigned int bitLength = [_x bitLength];
   unsigned int zWordLength = [_z getWordLength];
//   unsigned int zBitLength = [_z bitLength];
   
   TRUInt* xLow;
   TRUInt* xUp;
   TRUInt* yLow;
   TRUInt* yUp;
   TRUInt* zLow;
   TRUInt* zUp;
   
   [_x getUp:&xUp andLow:&xLow];
   [_y getUp:&yUp andLow:&yLow];
   [_z getUp:&zUp andLow:&zLow];
   
//   unsigned int* zero = alloca(sizeof(unsigned int)*wordLength);
//   unsigned int* one = alloca(sizeof(unsigned int)*wordLength);
   unsigned int* newXUp = alloca(sizeof(unsigned int)*wordLength);
   unsigned int* newXLow = alloca(sizeof(unsigned int)*wordLength);
   unsigned int* newYUp = alloca(sizeof(unsigned int)*wordLength);
   unsigned int* newYLow = alloca(sizeof(unsigned int)*wordLength);
   unsigned int* newZUp = alloca(sizeof(unsigned int)*wordLength);
   unsigned int* newZLow = alloca(sizeof(unsigned int)*wordLength);
   //   unsigned int  upXORlow;
   
//   ORUInt signmask = 1 << (([_x bitLength]-1)%BITSPERWORD);
   
//   NSLog(@"*******************************************");
//   NSLog(@"x <= y ? z");
//   NSLog(@"x=%@\n",_x);
//   NSLog(@"y=%@\n",_y);
//   NSLog(@"z=%@\n\n",_z);
   
   
   for (int i=0; i<wordLength; i++) {
      newXUp[i] = xUp[i]._val;
      newXLow[i] = xLow[i]._val;
      newYUp[i] = yUp[i]._val;
      newYLow[i] = yLow[i]._val;
   }
   for(int i=0;i<zWordLength;i++){
      newZUp[i] = zUp[i]._val;
      newZLow[i] = zLow[i]._val;
   }
   
//   ORUInt* xmin = [_x minArray];
//   ORUInt* ymin = [_y minArray];
//   ORUInt* xmax = [_x maxArray];
//   ORUInt* ymax = [_y maxArray];
   
   ORBool xlty = false;
   ORBool xgty = false;
   ORBool xeqy = true;
   
   for (int i=wordLength-1; i>=0; i--) {
      if (((newXUp[i] ^ newXLow[i]) | (newYUp[i]^ newYLow[i]) | (newXLow[i] ^ newYLow[i])) == 0)
         continue;
      else
         xeqy = false;
      if (xLow[i]._val > yUp[i]._val) {
//         xeqy = false;
         xgty = true;
         break;
      }
      else if ( xUp[i]._val < yLow[i]._val) {
//         xeqy=false;
         xlty = true;
         break;
      }
   }
   
   if(xlty | xeqy){
      newZLow[0] |= 0x1;
   }
   if(xgty){
      for (int i=0; i<zWordLength; i++)
         newZUp[i] = 0;
   }
   
   _state[0] = newXUp;
   _state[1] = newXLow;
   _state[2] = newYUp;
   _state[3] = newYLow;
   _state[4] = newZUp;
   _state[5] = newZLow;
   
   checkDomainConsistency(_z, newZLow, newZUp, zWordLength, self);
   [_z setUp:newZUp andLow:newZLow for:self];

   
   ORUInt *freeX = alloca(sizeof(ORUInt)*wordLength);
   ORUInt *freeY = alloca(sizeof(ORUInt)*wordLength);
   ORUInt *different = alloca(sizeof(ORUInt)*wordLength);
   
   ORUInt numFreeBitsX = 0;
   ORUInt numFreeBitsY = 0;
   
   //Find most sig. unset bit in x
   for(ORInt i = wordLength-1;i>=0;i--){
      freeX[i] = xUp[i]._val ^ xLow[i]._val;
      numFreeBitsX += __builtin_popcount(freeX[i]);
   }
   //Find most sig. unset bit in y
   for(ORInt i = wordLength-1;i>=0;i--){
      freeY[i] = yUp[i]._val ^ yLow[i]._val;
      numFreeBitsY += __builtin_popcount(freeY[i]);
   }
   
   //Find bits that are different in x and y
   for (int i=0;i<wordLength;i++)
      different[i] = (newXUp[i] ^ newYUp[i]) | (newXLow[i] ^ newYLow[i]);
   ORInt diffIndex;
   ORBool more;
   
   if(numFreeBitsX != 0){
      do{
         diffIndex =-1;
         for(int i=wordLength-1;i>=0;i--){
            if(different[i] != 0){
               diffIndex = (BITSPERWORD - __builtin_clz(different[i]))-1;
               break;
            }
         }
         if(diffIndex < 0){
            break;
         }
         
         more = false;
         //Find most sig unset bit in x
         ORInt bitIndex = -1;
         ORUInt wordIndex = 0;
         for(int i=wordLength-1;i>=0;i--){
            if(freeX[i] != 0){
               bitIndex = (BITSPERWORD - __builtin_clz(freeX[i]))-1;
               wordIndex = i;
               break;
            }
         }
         
         if(bitIndex < 0)
            break;
         
         ORUInt mask = 0x1 << bitIndex;
         if(diffIndex <= bitIndex){
            //Can we fix bit?
            ORUInt temp;
            
            if(zLow[0]._val){
               temp = newXLow[wordIndex] | mask;
               if(temp > newYUp[wordIndex]){
                  newXUp[wordIndex] &= ~mask;
                  freeX[wordIndex] &= ~mask;
                  different[wordIndex] = (newXUp[wordIndex] ^ newYUp[wordIndex]) | (newXLow[wordIndex] ^ newYLow[wordIndex]);
                  numFreeBitsX--;
                  more = true;
                  _state[0] = newXUp;
                  _state[1] = newXLow;
                  _state[2] = newYUp;
                  _state[3] = newYLow;
                  _state[4] = newZUp;
                  _state[5] = newZLow;

                  checkDomainConsistency(_x, newXLow, newXUp, wordLength, self);
                  [_x setUp:newXUp andLow:newXLow for:self];
               }
            }
            else if (zUp[0]._val == 0){
               temp = newXUp[wordIndex] & ~mask;
               //x must be > y
               if(temp <= newYLow[wordIndex]){
                  newXLow[wordIndex] |= mask;
                  freeX[wordIndex] &= ~mask;
                  different[wordIndex] = (newXUp[wordIndex] ^ newYUp[wordIndex]) | (newXLow[wordIndex] ^ newYLow[wordIndex]);
                  numFreeBitsX--;
                  more = true;
                  _state[0] = newXUp;
                  _state[1] = newXLow;
                  _state[2] = newYUp;
                  _state[3] = newYLow;
                  _state[4] = newZUp;
                  _state[5] = newZLow;
                  
                  checkDomainConsistency(_x, newXLow, newXUp, wordLength, self);
                  [_x setUp:newXUp andLow:newXLow for:self];
               }
            }
         }
      }while(more);
   }
   
   if(numFreeBitsY != 0){
      do{
         diffIndex =-1;
         for(int i=wordLength-1;i>=0;i--){
            if(different[i] != 0){
               diffIndex = (BITSPERWORD - __builtin_clz(different[i])-1);
               break;
            }
         }
         if(diffIndex < 0){
            break;
         }
         
         more = false;
         //Find most sig unset bit in x
         ORInt bitIndex = -1;
         ORUInt wordIndex = 0;
         for(int i=wordLength-1;i>=0;i--){
            if(freeY[i] != 0){
               bitIndex = (BITSPERWORD - __builtin_clz(freeY[i])-1);
               wordIndex = i;
               break;
            }
         }
         
         if(bitIndex < 0)
            break;
         
         ORUInt mask = 0x1 << bitIndex;
         if(diffIndex <= bitIndex){
            //Can we fix bit?
            ORUInt temp;
            
            if(zLow[0]._val){ // If x < y = t, then will clearing this bit make xmin > ymax?
               temp = newYUp[wordIndex] & ~mask;
               if(temp < newXLow[wordIndex]){
                  newYLow[wordIndex] |= mask;
                  freeY[wordIndex] &= ~mask;
                  different[wordIndex] = (newXUp[wordIndex] ^ newYUp[wordIndex]) | (newXLow[wordIndex] ^ newYLow[wordIndex]);
                  numFreeBitsY--;
                  more = true;
                  _state[0] = newXUp;
                  _state[1] = newXLow;
                  _state[2] = newYUp;
                  _state[3] = newYLow;
                  _state[4] = newZUp;
                  _state[5] = newZLow;
                  
                  checkDomainConsistency(_y, newYLow, newYUp, wordLength, self);
                  [_y setUp:newYUp andLow:newYLow for:self];
               }
            }
            else if (zUp[0]._val == 0){
               temp = newYLow[wordIndex] | mask;
               //x must be >= y
               if(temp >= newXUp[wordIndex]){//if we set bit in y is ymin > xmax?
                  newYUp[wordIndex] &= ~mask;
                  freeY[wordIndex] &= ~mask;
                  different[wordIndex] = (newXUp[wordIndex] ^ newYUp[wordIndex]) | (newXLow[wordIndex] ^ newYLow[wordIndex]);
                  numFreeBitsY--;
                  more = true;
                  _state[0] = newXUp;
                  _state[1] = newXLow;
                  _state[2] = newYUp;
                  _state[3] = newYLow;
                  _state[4] = newZUp;
                  _state[5] = newZLow;
                  
                  checkDomainConsistency(_y, newYLow, newYUp, wordLength, self);
                  [_y setUp:newYUp andLow:newYLow for:self];
               }
            }
         }
      }while(more);
   }

   if ((newZLow[0]^newZUp[0]) == 0){
      if(newZLow[0]){
         if (newXLow[0] > newYUp[0])
            NSLog(@"Problem!");
      }
      else{
         if (newXUp[0] <= newYLow[0])
            NSLog(@"Problem!");
      }
   }
   
   
//   NSLog(@"newX =          %@",bitvar2NSString(newXLow, newXUp, bitLength));
//   NSLog(@"newY =          %@",bitvar2NSString(newYLow, newYUp, bitLength));
//   NSLog(@"newZ =          %@",bitvar2NSString(newZLow, newZUp, zBitLength));
//
//   if ((newXLow[0] != xLow->_val) || (newXUp[0] != xUp->_val) || (newYLow[0] != yLow->_val) || (newYUp[0] != yUp->_val))
//      NSLog(@"");

#ifdef BIT_DEBUG
   NSLog(@"      X =%@",_x);
   NSLog(@"   <  Y =%@",_y);
   NSLog(@"   =  Z =%@\n\n",_z);
#endif

   _state[0] = newXUp;
   _state[1] = newXLow;
   _state[2] = newYUp;
   _state[3] = newYLow;
   _state[4] = newZUp;
   _state[5] = newZLow;
   
   ORBool xFail = checkDomainConsistency(_x, newXLow, newXUp, wordLength, self);
   ORBool yFail = checkDomainConsistency(_y, newYLow, newYUp, wordLength, self);
   ORBool zFail = checkDomainConsistency(_z, newZLow, newZUp, zWordLength, self);
   if (xFail || yFail || zFail) {
      failNow();
   }
   [_x setUp:newXUp andLow:newXLow for:self];
   [_y setUp:newYUp andLow:newYLow for:self];
   [_z setUp:newZUp andLow:newZLow for:self];
   
//   NSLog(@"x=%@\n",_x);
//   NSLog(@"y=%@\n",_y);
//   NSLog(@"z=%@\n\n",_z);

}
@end

@implementation CPBitSLE
-(id) initCPBitSLE:(CPBitVarI *)x SLE:(CPBitVarI *)y eval:(CPBitVarI *)z{
   self = [super initCPBitCoreConstraint:[x engine]];
   _x = x;
   _y = y;
   _z = z;
   _state = malloc(sizeof(ORUInt*)*6);
   return self;
   
}
-(NSString*) description
{
   NSMutableString* string = [NSMutableString stringWithString:[super description]];
   [string appendString:[NSString stringWithFormat:@" with %@, and %@ and %@",_x, _y, _z]];
  
   return string;
}

-(CPBitAntecedents*) getAntecedents:(CPBitAssignment*)assignment{
   return ([self getAntecedentsFor:assignment withState:_state]);
}
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment withState:(ORUInt**)state
{
   //NSLog(@"Implication for 0x%lx[%u] = %@  traced back through %@", (unsigned long)assignment->var, assignment->index, (CPBitVarI*)assignment->var, self);
   ORUInt wordLength = [_x getWordLength];
   ORUInt bitLength = [_x bitLength];
   
   CPBitAntecedents* ants = malloc(sizeof(CPBitAntecedents));
   CPBitAssignment** vars;
   vars = malloc(sizeof(CPBitAssignment*)*(wordLength*BITSPERWORD*2+1));
   ants->numAntecedents = 0;
   ants->antecedents = vars;
   
   ORInt index = assignment->index;
   ORInt diffIndex =0;
   
   TRUInt* xUp;
   TRUInt* xLow;
   TRUInt* yUp;
   TRUInt* yLow;
   TRUInt* zUp;
   TRUInt* zLow;
   
   [_x getUp:&xUp andLow:&xLow];
   [_y getUp:&yUp andLow:&yLow];
   [_z getUp:&zUp andLow:&zLow];
   
   ORUInt* x1y0 = alloca(sizeof(ORUInt)*wordLength);
   ORInt idx=0;
   for(int i=wordLength-1;i>=0;i--){
      x1y0[i] = (xLow[i]._val & ~yUp[i]._val);
      if(x1y0[i] != 0){
         idx = (i*BITSPERWORD)+(BITSPERWORD - __builtin_clz(x1y0[i])-1);
         break;
      }
   }
   
   //   NSLog(@"                                             3322222222221111111111");
   //   NSLog(@"                                             10987654321098765432109876543210");
   //   if(assignment->var == _x)
   //      NSLog(@"%@[%d]=%d",_x,assignment->index, assignment->value);
   //   else
   //      NSLog(@"%@",_x);
   //
   //   if(assignment->var == _y)
   //      NSLog(@"%@[%d]=%d",_y,assignment->index, assignment->value);
   //   else
   //      NSLog(@"%@",_y);
   
   ORBool xAtIndex, yAtIndex, zAt0;
   xAtIndex = yAtIndex = zAt0 = false;
   
   if(assignment->var == _x){
      if (![_y isFree:index] || (~ISFREE(state[2][index/BITSPERWORD], state[3][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD)))) {
         yAtIndex = true;
         //         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         //         vars[ants->numAntecedents]->index = index;
         //         vars[ants->numAntecedents]->var = _y;
         if(![_y isFree:index])
            vars[ants->numAntecedents]->value = [_y getBit:index];
         else
            vars[ants->numAntecedents]->value = !((ISTRUE(state[2][index/BITSPERWORD], state[3][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD))) == 0);
         if ((index>idx) && (assignment->value == 0) && (vars[ants->numAntecedents]->value == 1))
            //         if ((index>idx) && (assignment->value == 0) && ([_y getBit:index]))
            index=idx-1;
         //         ants->numAntecedents++;
      }
      if (![_z isFree:0] || (~ISFREE(state[4][0], state[5][0]) & 0x1)) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->index = 0;
         vars[ants->numAntecedents]->var = _z;
         if(![_z isFree:0])
            vars[ants->numAntecedents]->value = [_z getBit:0];
         else
            vars[ants->numAntecedents]->value = !((ISTRUE(state[4][0], state[5][0]) & 0x1) == 0);
         ants->numAntecedents++;
      }
   }
   else if(assignment->var == _y){
      if (![_x isFree:index] || (~ISFREE(state[0][index/BITSPERWORD], state[1][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD)))) {
         xAtIndex = true;
         //         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         //         vars[ants->numAntecedents]->index = index;
         //         vars[ants->numAntecedents]->var = _x;
         if(![_x isFree:index])
            vars[ants->numAntecedents]->value = [_x getBit:index];
         else
            vars[ants->numAntecedents]->value = !((ISTRUE(state[0][index/BITSPERWORD], state[1][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD))) == 0);
         if ((index>idx) && (assignment->value == 1) && (vars[ants->numAntecedents]->value == 0))
            index=idx-1;
         //         ants->numAntecedents++;
      }
      if (![_z isFree:0] || (~ISFREE(state[4][0], state[5][0]) & 0x1)) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->index = 0;
         vars[ants->numAntecedents]->var = _z;
         if(![_z isFree:0])
            vars[ants->numAntecedents]->value = [_z getBit:0];
         else
            vars[ants->numAntecedents]->value = !((ISTRUE(state[4][0], state[5][0]) & 0x1) == 0);
         ants->numAntecedents++;
      }
   }
   else if(assignment->var == _z){
      ORUInt* different = alloca(sizeof(ORUInt)*wordLength);
      for(int i=wordLength-1;i>=0;i--){
         different[i] = (state[0][i] ^ state[2][i]) | (state[1][i] ^ state[3][i]);
         if(different[i] != 0){
            diffIndex = (i*BITSPERWORD)+(BITSPERWORD - __builtin_clz(different[i])-1);
            break;
         }
      }
      if(![_z getBit:0])
         index = diffIndex;
      else
         index = idx;
      
      if (![_x isFree:index] || (~ISFREE(state[0][index/BITSPERWORD], state[1][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD)))) {
         xAtIndex = true;
         //            vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         //            vars[ants->numAntecedents]->index = index;
         //            vars[ants->numAntecedents]->var = _x;
         //            if(![_x isFree:index])
         //               vars[ants->numAntecedents]->value = [_x getBit:index];
         //            else
         //               vars[ants->numAntecedents]->value = !((ISTRUE(state[0][index/BITSPERWORD], state[1][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD))) == 0);
         //            ants->numAntecedents++;
      }
      if (![_y isFree:index] || (~ISFREE(state[2][index/BITSPERWORD], state[3][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD)))) {
         yAtIndex = true;
         //            vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         //            vars[ants->numAntecedents]->index = index;
         //            vars[ants->numAntecedents]->var = _y;
         //            if(![_y isFree:index])
         //               vars[ants->numAntecedents]->value = [_y getBit:index];
         //            else
         //               vars[ants->numAntecedents]->value = !((ISTRUE(state[2][index/BITSPERWORD], state[3][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD))) == 0);
         //            ants->numAntecedents++;
      }
   }
   //   if((assignment->var == _y) && (assignment->value == 1) && [_y bound] && (__builtin_popcount(yUp[0]._val & yLow[0]._val)==1))
   //      for(int i=0; i<index;i++){
   //         if(![_y isFree:i]){
   //            vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
   //            vars[ants->numAntecedents]->index = i;
   //            vars[ants->numAntecedents]->var = _y;
   //            vars[ants->numAntecedents]->value = [_y getBit:i];
   //            ants->numAntecedents++;
   //         }
   //      }
   
   //   for(int i=index+1;i<bitLength;i++){
   //      if(i==assignment->index)
   //         continue;
   for(int i=index; i<bitLength;i++){
      if(((i==assignment->index) && xAtIndex) || ((i!=assignment->index) && (![_x isFree:i] || (~ISFREE(state[0][i/BITSPERWORD], state[1][i/BITSPERWORD]) & (0x1 << (i%BITSPERWORD)))))) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->index = i;
         vars[ants->numAntecedents]->var = _x;
         if(![_x isFree:i])
            vars[ants->numAntecedents]->value = [_x getBit:i];
         else
            vars[ants->numAntecedents]->value = !((ISTRUE(state[0][i/BITSPERWORD], state[1][i/BITSPERWORD]) & (0x1 << (i%BITSPERWORD))) == 0);
         ants->numAntecedents++;
      }
      if (((i==assignment->index) && yAtIndex) || ((i!=assignment->index) && (![_y isFree:i] || (~ISFREE(state[2][i/BITSPERWORD], state[3][i/BITSPERWORD]) & (0x1 << (i%BITSPERWORD)))))) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->index = i;
         vars[ants->numAntecedents]->var = _y;
         if(![_y isFree:i])
            vars[ants->numAntecedents]->value = [_y getBit:i];
         else
            vars[ants->numAntecedents]->value = !((ISTRUE(state[2][i/BITSPERWORD], state[3][i/BITSPERWORD]) & (0x1 << (i%BITSPERWORD))) == 0);
         ants->numAntecedents++;
      }
   }
   //   if(ants->numAntecedents > (wordLength*BITSPERWORD*2+1))
   //   if((assignment->var == _z) && (assignment->value == 1))
   //      NSLog(@"%d  %d",ants->numAntecedents,2*(32-assignment->index));
   return ants;
}

-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment
{
   //NSLog(@"Implication for 0x%lx[%u] = %@  traced back through %@", (unsigned long)assignment->var, assignment->index, (CPBitVarI*)assignment->var, self);
   ORUInt wordLength = [_x getWordLength];
   ORUInt bitLength = [_x bitLength];
   
   CPBitAntecedents* ants = malloc(sizeof(CPBitAntecedents));
   CPBitAssignment** vars;
   vars = malloc(sizeof(CPBitAssignment*)*(wordLength*BITSPERWORD*2+1));
   ants->numAntecedents = 0;
   ants->antecedents = vars;
   
   TRUInt* xUp;
   TRUInt* xLow;
   TRUInt* yUp;
   TRUInt* yLow;
   TRUInt* zUp;
   TRUInt* zLow;
   
   [_x getUp:&xUp andLow:&xLow];
   [_y getUp:&yUp andLow:&yLow];
   [_z getUp:&zUp andLow:&zLow];
   
   ORInt index = assignment->index;
   
   ORUInt* x1y0 = alloca(sizeof(ORUInt)*wordLength);
   ORInt idx=0;
   for(int i=wordLength-1;i>=0;i--){
      x1y0[i] = (xLow[i]._val & ~yUp[i]._val);
      if(x1y0[i] != 0){
         idx = (i*BITSPERWORD)+(BITSPERWORD - __builtin_clz(x1y0[i])-1);
         break;
      }
   }
   
   
   //   NSLog(@"                                             3322222222221111111111");
   //   NSLog(@"                                             10987654321098765432109876543210");
   //   if(assignment->var == _x)
   //      NSLog(@"%@[%d]=%d",_x,assignment->index, assignment->value);
   //   else
   //      NSLog(@"%@",_x);
   //
   //   if(assignment->var == _y)
   //      NSLog(@"%@[%d]=%d",_y,assignment->index, assignment->value);
   //   else
   //      NSLog(@"%@",_y);
   
   
   ORBool xAtIndex, yAtIndex, zAt0;
   xAtIndex = yAtIndex = zAt0 = false;
   
   if(assignment->var == _x){
      if(![_y isFree:index]){
         yAtIndex = true;
         //         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         //         vars[ants->numAntecedents]->index = index;
         //         vars[ants->numAntecedents]->var = _y;
         //         vars[ants->numAntecedents]->value = [_y getBit:index];
         if ((index>idx) && !assignment->value && [_y getBit:index])
            index=idx;
         //         ants->numAntecedents++;
      }
      if(![_z isFree:0]){
         //         zAt0 = true;
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->index = 0;
         vars[ants->numAntecedents]->var = _z;
         vars[ants->numAntecedents]->value = [_z getBit:0];
         ants->numAntecedents++;
      }
   }
   else if(assignment->var == _y){
      if(![_x isFree:index]){
         xAtIndex = true;
         //         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         //         vars[ants->numAntecedents]->index = index;
         //         vars[ants->numAntecedents]->var = _x;
         //         vars[ants->numAntecedents]->value = [_x getBit:index];
         if((index>idx) && assignment->value && ![_x getBit:index])
            index=idx;
         //         ants->numAntecedents++;
      }
      if(![_z isFree:0]){
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->index = 0;
         vars[ants->numAntecedents]->var = _z;
         vars[ants->numAntecedents]->value = [_z getBit:0];
         ants->numAntecedents++;
      }
   }
   else if(assignment->var == _z){
      ORUInt* different = alloca(sizeof(ORUInt)*wordLength);
      ORInt diffIndex =0;
      for(int i=wordLength-1;i>=0;i--){
         different[i] = (xUp[i]._val ^ yUp[i]._val) | (xLow[i]._val ^ yLow[i]._val);
         if(different[i] != 0){
            diffIndex = (i*BITSPERWORD)+(BITSPERWORD - __builtin_clz(different[i])-1);
            break;
         }
      }
      if([_z getBit:0] == false)
         index = diffIndex;
      else
         index = idx;
      if(![_x isFree:index]){
         xAtIndex = true;
         //         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         //         vars[ants->numAntecedents]->index = index;
         //         vars[ants->numAntecedents]->var = _x;
         //         vars[ants->numAntecedents]->value = [_x getBit:index];
         //         ants->numAntecedents++;
      }
      if(![_y isFree:index]){
         yAtIndex = true;
         //         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         //         vars[ants->numAntecedents]->index = index;
         //         vars[ants->numAntecedents]->var = _y;
         //         vars[ants->numAntecedents]->value = [_y getBit:index];
         //         ants->numAntecedents++;
      }
   }
   
   //   if((assignment->var == _y) && (assignment->value == 1) && [_y bound] && (__builtin_popcount(yUp[0]._val & yLow[0]._val)==1))
   //      for(int i=0; i<index;i++){
   //         if(![_y isFree:i]){
   //            vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
   //            vars[ants->numAntecedents]->index = i;
   //            vars[ants->numAntecedents]->var = _y;
   //            vars[ants->numAntecedents]->value = [_y getBit:i];
   //            ants->numAntecedents++;
   //         }
   //      }
   
   //   for(int i=index+1;i<bitLength;i++){
   //      if(i==assignment->index)
   //         continue;
   for(int i=index; i<bitLength;i++){
      if(((i!=assignment->index) && ![_x isFree:i]) || ((i==assignment->index) && xAtIndex)){
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->index = i;
         vars[ants->numAntecedents]->var = _x;
         vars[ants->numAntecedents]->value = [_x getBit:i];
         ants->numAntecedents++;
      }
      if(((i!=assignment->index) && ![_y isFree:i]) || ((i==assignment->index) && yAtIndex)){
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->index = i;
         vars[ants->numAntecedents]->var = _y;
         vars[ants->numAntecedents]->value = [_y getBit:i];
         ants->numAntecedents++;
      }
   }
   //   if(ants->numAntecedents > (wordLength*BITSPERWORD*2+1))
   //   if((assignment->var == _z) && (assignment->value == 1))
   //      NSLog(@"%d  %d",ants->numAntecedents,2*(32-assignment->index));
   return ants;
}

- (void) dealloc
{
   [super dealloc];
   free(_state);
}

-(void) post
{
   [self propagate];
   if (![_x bound])
      [_x whenChangePropagate: self];
   if (![_y bound])
      [_y whenChangePropagate: self];
   if (![_z bound])
      [_z whenChangePropagate: self];
   [self propagate];
   //   return ORSuspend;
}
-(void) propagate
{
   //TODO: Fix so that _z can be larger than 32 bits if this is the design decision made
#ifdef BIT_DEBUG
   NSLog(@"**********************************");
   NSLog(@"Bit (signed) <= Constraint propagated.");
#endif
   
   unsigned int wordLength = [_x getWordLength];
   unsigned int bitLength = [_x bitLength];
   unsigned int zWordLength = [_z getWordLength];
//   unsigned int zBitLength = [_z bitLength];
   
   TRUInt* xLow;
   TRUInt* xUp;
   TRUInt* yLow;
   TRUInt* yUp;
   TRUInt* zLow;
   TRUInt* zUp;
   
   [_x getUp:&xUp andLow:&xLow];
   [_y getUp:&yUp andLow:&yLow];
   [_z getUp:&zUp andLow:&zLow];

   unsigned int* newXUp = alloca(sizeof(unsigned int)*wordLength);
   unsigned int* newXLow = alloca(sizeof(unsigned int)*wordLength);

   unsigned int* newYUp = alloca(sizeof(unsigned int)*wordLength);
   unsigned int* newYLow = alloca(sizeof(unsigned int)*wordLength);
   
   unsigned int* newZUp = alloca(sizeof(unsigned int)*zWordLength);
   unsigned int* newZLow = alloca(sizeof(unsigned int)*zWordLength);
   
//   ORUInt signmask = 1 << (([_x bitLength]-1)%BITSPERWORD);
   
//   NSLog(@"*******************************************");
//   NSLog(@"s|x <= s|y ? z");
//   NSLog(@"x=%@\n",_x);
//   NSLog(@"y=%@\n",_y);
//   NSLog(@"z=%@\n\n",_z);
   
   for (int i=0; i<wordLength; i++) {
      newXUp[i] = xUp[i]._val;
      newXLow[i] = xLow[i]._val;
      newYUp[i] = yUp[i]._val;
      newYLow[i] = yLow[i]._val;
   }
   for(int i=0;i<zWordLength;i++){
      newZUp[i] = zUp[i]._val;
      newZLow[i] = zLow[i]._val;
   }
   
   
   ORUInt *freeX = alloca(sizeof(ORUInt)*wordLength);
   ORUInt *freeY = alloca(sizeof(ORUInt)*wordLength);
   ORUInt *different = alloca(sizeof(ORUInt)*wordLength);

   ORUInt signMask = 0x1 << (BITSPERWORD - (bitLength%BITSPERWORD)-1);
   
   
   ORUInt numFreeBitsX = 0;
   ORUInt numFreeBitsY = 0;
   
   //Find most sig. unset bit in x
   for(ORInt i = wordLength-1;i>=0;i--){
      freeX[i] = xUp[i]._val ^ xLow[i]._val;
      numFreeBitsX += __builtin_popcount(freeX[i]);
   }
   //Find most sig. unset bit in y
   for(ORInt i = wordLength-1;i>=0;i--){
      freeY[i] = yUp[i]._val ^ yLow[i]._val;
      numFreeBitsY += __builtin_popcount(freeY[i]);
   }

   //flip most sig .sign bit if set
   if(~freeX[wordLength-1] & signMask){
      newXUp[wordLength-1] ^= signMask;
      newXLow[wordLength-1] ^= signMask;
   }
   if(~freeY[wordLength-1] & signMask){
      newYUp[wordLength-1] ^= signMask;
      newYLow[wordLength-1] ^= signMask;
   }
   
   
   ORBool xlty = false;
   ORBool xgty = false;
   ORBool xeqy = true;
   
   for (int i=wordLength-1; i>=0; i--) {
      if (((newXUp[i] ^ newXLow[i]) | (newYUp[i]^ newYLow[i]) | (newXLow[i] ^ newYLow[i])) == 0)
         continue;
      else
         xeqy = false;
      if (newXLow[i] > newYUp[i]) {
         xgty = true;
         break;
      }
      else if (newXUp[i] <= newYLow[i]) {
         xlty = true;
         break;
      }
   }
   
   if(xlty || xeqy){
      newZLow[0] |= 0x1;
   }
   if(xgty){
      for (int i=0; i<zWordLength; i++)
         newZUp[i] = 0;
   }
   _state[0] = newXUp;
   _state[1] = newXLow;
   _state[2] = newYUp;
   _state[3] = newYLow;
   _state[4] = newZUp;
   _state[5] = newZLow;

   checkDomainConsistency(_z, newZLow, newZUp, zWordLength, self);
   [_z setUp:newZUp andLow:newZLow for:self];


   //Find bits that are different in x and y
   for (int i=0;i<wordLength;i++)
      different[i] = (newXUp[i] ^ newYUp[i]) | (newXLow[i] ^ newYLow[i]);
   ORInt diffIndex;
   ORBool more;
   
   if(numFreeBitsX != 0){
      do{
         diffIndex =-1;
         for(int i=wordLength-1;i>=0;i--){
            if(different[i] != 0){
               diffIndex = (BITSPERWORD - __builtin_clz(different[i]))-1;
               break;
            }
         }
         if(diffIndex < 0){
            break;
         }
         
         more = false;
         //Find most sig unset bit in x
         ORInt bitIndex = -1;
         ORUInt wordIndex = 0;
         for(int i=wordLength-1;i>=0;i--){
            if(freeX[i] != 0){
               bitIndex = (BITSPERWORD - __builtin_clz(freeX[i]))-1;
               wordIndex = i;
               break;
            }
         }
         
         if(bitIndex < 0)
            break;
         
         ORUInt mask = 0x1 << bitIndex;
         if(diffIndex <= bitIndex){
            //Can we fix bit?
            ORUInt temp;
            
            if(zLow[0]._val){
               temp = newXLow[wordIndex] | mask;
               if(temp > newYUp[wordIndex]){
                  newXUp[wordIndex] &= ~mask;
                  freeX[wordIndex] &= ~mask;
                  different[wordIndex] = (newXUp[wordIndex] ^ newYUp[wordIndex]) | (newXLow[wordIndex] ^ newYLow[wordIndex]);
                  numFreeBitsX--;
                  more = true;
//                  checkDomainConsistency(_x, newXLow, newXUp, wordLength, self);
//                  [_x setUp:newXUp andLow:newXLow for:self];
               }
            }
            else if (zUp[0]._val == 0){
               temp = newXUp[wordIndex] & ~mask;
               //x must be >= y
               if(temp <= newYLow[wordIndex]){
                  newXLow[wordIndex] |= mask;
                  freeX[wordIndex] &= ~mask;
                  different[wordIndex] = (newXUp[wordIndex] ^ newYUp[wordIndex]) | (newXLow[wordIndex] ^ newYLow[wordIndex]);
                  numFreeBitsX--;
                  more = true;
//                  checkDomainConsistency(_x, newXLow, newXUp, wordLength, self);
//                  [_x setUp:newXUp andLow:newXLow for:self];
               }
            }
         }
      }while(more);
   }
   
   if(numFreeBitsY != 0){
      do{
         diffIndex =-1;
         for(int i=wordLength-1;i>=0;i--){
            if(different[i] != 0){
               diffIndex = (BITSPERWORD - __builtin_clz(different[i])-1);
               break;
            }
         }
         if(diffIndex < 0){
            break;
         }
         
         more = false;
         //Find most sig unset bit in x
         ORInt bitIndex = -1;
         ORUInt wordIndex = 0;
         for(int i=wordLength-1;i>=0;i--){
            if(freeY[i] != 0){
               bitIndex = (BITSPERWORD - __builtin_clz(freeY[i])-1);
               wordIndex = i;
               break;
            }
         }
         
         if(bitIndex < 0)
            break;
         
         ORUInt mask = 0x1 << bitIndex;
         if(diffIndex <= bitIndex){
            //Can we fix bit?
            ORUInt temp;
            
            if(zLow[0]._val){ // If x < y = t, then will clearing this bit make xmin > ymax?
               temp = newYUp[wordIndex] & ~mask;
               if(temp < newXLow[wordIndex]){
                  newYLow[wordIndex] |= mask;
                  freeY[wordIndex] &= ~mask;
                  different[wordIndex] = (newXUp[wordIndex] ^ newYUp[wordIndex]) | (newXLow[wordIndex] ^ newYLow[wordIndex]);
                  numFreeBitsY--;
                  more = true;
//                  checkDomainConsistency(_y, newYLow, newYUp, wordLength, self);
//                  [_y setUp:newYUp andLow:newYLow for:self];
               }
            }
            else if (zUp[0]._val == 0){
               temp = newYLow[wordIndex] | mask;
               //x must be > y
               if(temp >= newXUp[wordIndex]){//if we set bit in y is ymin > xmax?
                  newYUp[wordIndex] &= ~mask;
                  freeY[wordIndex] &= ~mask;
                  different[wordIndex] = (newXUp[wordIndex] ^ newYUp[wordIndex]) | (newXLow[wordIndex] ^ newYLow[wordIndex]);
                  numFreeBitsY--;
                  more = true;
//                  checkDomainConsistency(_y, newYLow, newYUp, wordLength, self);
//                  [_y setUp:newYUp andLow:newYLow for:self];
               }
            }
         }
      }while(more);
   }

   //flip most sig .sign bit if set
   if(~freeX[wordLength-1] & signMask){
      newXUp[wordLength-1] ^= signMask;
      newXLow[wordLength-1] ^= signMask;
   }
   if(~freeY[wordLength-1] & signMask){
      newYUp[wordLength-1] ^= signMask;
      newYLow[wordLength-1] ^= signMask;
   }
   
   

//   NSLog(@"newX = %@",bitvar2NSString(newXLow, newXUp, bitLength));
//   NSLog(@"newY = %@",bitvar2NSString(newYLow, newYUp, bitLength));
//   NSLog(@"newZ = %@",bitvar2NSString(newZLow, newZUp, zBitLength));
   
   _state[0] = newXUp;
   _state[1] = newXLow;
   _state[2] = newYUp;
   _state[3] = newYLow;
   _state[4] = newZUp;
   _state[5] = newZLow;
   
   ORBool xFail = checkDomainConsistency(_x, newXLow, newXUp, wordLength, self);
   ORBool yFail = checkDomainConsistency(_y, newYLow, newYUp, wordLength, self);
   ORBool zFail = checkDomainConsistency(_z, newZLow, newZUp, zWordLength, self);
   if (xFail || yFail || zFail) {
      failNow();
   }
//   NSLog(@"x=%@\n",_x);
//   NSLog(@"y=%@\n",_y);
//   NSLog(@"z=%@\n\n",_z);

   [_x setUp:newXUp andLow:newXLow for:self];
   [_y setUp:newYUp andLow:newYLow for:self];
   [_z setUp:newZUp andLow:newZLow for:self];
   
   
#ifdef BIT_DEBUG
   NSLog(@"      X =%@",_x);
   NSLog(@"   <  Y =%@",_y);
   NSLog(@"   =  Z =%@\n\n",_z);
#endif
}
@end

@implementation CPBitSLT
-(id) initCPBitSLT:(CPBitVarI *)x SLT:(CPBitVarI *)y eval:(CPBitVarI *)z
{
   self = [super initCPBitCoreConstraint:[x engine]];
   _x = x;
   _y = y;
   _z = z;
   _state = malloc(sizeof(ORUInt*)*6);
   return self;
   
}
-(NSString*) description
{
   NSMutableString* string = [NSMutableString stringWithString:[super description]];
   [string appendString:[NSString stringWithFormat:@" with %@, and %@ and %@",_x, _y, _z]];
   return string;
}

-(CPBitAntecedents*) getAntecedents:(CPBitAssignment*)assignment{
   return ([self getAntecedentsFor:assignment withState:_state]);
}
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment withState:(ORUInt**)state
{
   //NSLog(@"Implication for 0x%lx[%u] = %@  traced back through %@", (unsigned long)assignment->var, assignment->index, (CPBitVarI*)assignment->var, self);
   ORUInt wordLength = [_x getWordLength];
   ORUInt bitLength = [_x bitLength];
   
   CPBitAntecedents* ants = malloc(sizeof(CPBitAntecedents));
   CPBitAssignment** vars;
   vars = malloc(sizeof(CPBitAssignment*)*(wordLength*BITSPERWORD*2+1));
   ants->numAntecedents = 0;
   ants->antecedents = vars;
   
   ORInt index = assignment->index;
   ORInt diffIndex =0;
   
   TRUInt* xUp;
   TRUInt* xLow;
   TRUInt* yUp;
   TRUInt* yLow;
   TRUInt* zUp;
   TRUInt* zLow;
   
   [_x getUp:&xUp andLow:&xLow];
   [_y getUp:&yUp andLow:&yLow];
   [_z getUp:&zUp andLow:&zLow];
   
   ORUInt* x1y0 = alloca(sizeof(ORUInt)*wordLength);
   ORInt idx=0;
   for(int i=wordLength-1;i>=0;i--){
      x1y0[i] = (xLow[i]._val & ~yUp[i]._val);
      if(x1y0[i] != 0){
         idx = (i*BITSPERWORD)+(BITSPERWORD - __builtin_clz(x1y0[i])-1);
         break;
      }
   }
   
   //   NSLog(@"                                             3322222222221111111111");
   //   NSLog(@"                                             10987654321098765432109876543210");
   //   if(assignment->var == _x)
   //      NSLog(@"%@[%d]=%d",_x,assignment->index, assignment->value);
   //   else
   //      NSLog(@"%@",_x);
   //
   //   if(assignment->var == _y)
   //      NSLog(@"%@[%d]=%d",_y,assignment->index, assignment->value);
   //   else
   //      NSLog(@"%@",_y);
   
   ORBool xAtIndex, yAtIndex, zAt0;
   xAtIndex = yAtIndex = zAt0 = false;
   
   if(assignment->var == _x){
      if (![_y isFree:index] || (~ISFREE(state[2][index/BITSPERWORD], state[3][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD)))) {
         yAtIndex = true;
         //         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         //         vars[ants->numAntecedents]->index = index;
         //         vars[ants->numAntecedents]->var = _y;
         if(![_y isFree:index])
            vars[ants->numAntecedents]->value = [_y getBit:index];
         else
            vars[ants->numAntecedents]->value = !((ISTRUE(state[2][index/BITSPERWORD], state[3][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD))) == 0);
         if ((index>idx) && (assignment->value == 0) && (vars[ants->numAntecedents]->value == 1))
            //         if ((index>idx) && (assignment->value == 0) && ([_y getBit:index]))
            index=idx-1;
         //         ants->numAntecedents++;
      }
      if (![_z isFree:0] || (~ISFREE(state[4][0], state[5][0]) & 0x1)) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->index = 0;
         vars[ants->numAntecedents]->var = _z;
         if(![_z isFree:0])
            vars[ants->numAntecedents]->value = [_z getBit:0];
         else
            vars[ants->numAntecedents]->value = !((ISTRUE(state[4][0], state[5][0]) & 0x1) == 0);
         ants->numAntecedents++;
      }
   }
   else if(assignment->var == _y){
      if (![_x isFree:index] || (~ISFREE(state[0][index/BITSPERWORD], state[1][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD)))) {
         xAtIndex = true;
         //         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         //         vars[ants->numAntecedents]->index = index;
         //         vars[ants->numAntecedents]->var = _x;
         if(![_x isFree:index])
            vars[ants->numAntecedents]->value = [_x getBit:index];
         else
            vars[ants->numAntecedents]->value = !((ISTRUE(state[0][index/BITSPERWORD], state[1][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD))) == 0);
         if ((index>idx) && (assignment->value == 1) && (vars[ants->numAntecedents]->value == 0))
            index=idx-1;
         //         ants->numAntecedents++;
      }
      if (![_z isFree:0] || (~ISFREE(state[4][0], state[5][0]) & 0x1)) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->index = 0;
         vars[ants->numAntecedents]->var = _z;
         if(![_z isFree:0])
            vars[ants->numAntecedents]->value = [_z getBit:0];
         else
            vars[ants->numAntecedents]->value = !((ISTRUE(state[4][0], state[5][0]) & 0x1) == 0);
         ants->numAntecedents++;
      }
   }
   else if(assignment->var == _z){
      ORUInt* different = alloca(sizeof(ORUInt)*wordLength);
      for(int i=wordLength-1;i>=0;i--){
         different[i] = (state[0][i] ^ state[2][i]) | (state[1][i] ^ state[3][i]);
         if(different[i] != 0){
            diffIndex = (i*BITSPERWORD)+(BITSPERWORD - __builtin_clz(different[i])-1);
            break;
         }
      }
      if(![_z getBit:0])
         index = diffIndex;
      else
         index = idx;
      
      if (![_x isFree:index] || (~ISFREE(state[0][index/BITSPERWORD], state[1][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD)))) {
         xAtIndex = true;
         //            vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         //            vars[ants->numAntecedents]->index = index;
         //            vars[ants->numAntecedents]->var = _x;
         //            if(![_x isFree:index])
         //               vars[ants->numAntecedents]->value = [_x getBit:index];
         //            else
         //               vars[ants->numAntecedents]->value = !((ISTRUE(state[0][index/BITSPERWORD], state[1][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD))) == 0);
         //            ants->numAntecedents++;
      }
      if (![_y isFree:index] || (~ISFREE(state[2][index/BITSPERWORD], state[3][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD)))) {
         yAtIndex = true;
         //            vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         //            vars[ants->numAntecedents]->index = index;
         //            vars[ants->numAntecedents]->var = _y;
         //            if(![_y isFree:index])
         //               vars[ants->numAntecedents]->value = [_y getBit:index];
         //            else
         //               vars[ants->numAntecedents]->value = !((ISTRUE(state[2][index/BITSPERWORD], state[3][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD))) == 0);
         //            ants->numAntecedents++;
      }
   }
   //   if((assignment->var == _y) && (assignment->value == 1) && [_y bound] && (__builtin_popcount(yUp[0]._val & yLow[0]._val)==1))
   //      for(int i=0; i<index;i++){
   //         if(![_y isFree:i]){
   //            vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
   //            vars[ants->numAntecedents]->index = i;
   //            vars[ants->numAntecedents]->var = _y;
   //            vars[ants->numAntecedents]->value = [_y getBit:i];
   //            ants->numAntecedents++;
   //         }
   //      }
   
   //   for(int i=index+1;i<bitLength;i++){
   //      if(i==assignment->index)
   //         continue;
   for(int i=index; i<bitLength;i++){
      if(((i==assignment->index) && xAtIndex) || ((i!=assignment->index) && (![_x isFree:i] || (~ISFREE(state[0][i/BITSPERWORD], state[1][i/BITSPERWORD]) & (0x1 << (i%BITSPERWORD)))))) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->index = i;
         vars[ants->numAntecedents]->var = _x;
         if(![_x isFree:i])
            vars[ants->numAntecedents]->value = [_x getBit:i];
         else
            vars[ants->numAntecedents]->value = !((ISTRUE(state[0][i/BITSPERWORD], state[1][i/BITSPERWORD]) & (0x1 << (i%BITSPERWORD))) == 0);
         ants->numAntecedents++;
      }
      if (((i==assignment->index) && yAtIndex) || ((i!=assignment->index) && (![_y isFree:i] || (~ISFREE(state[2][i/BITSPERWORD], state[3][i/BITSPERWORD]) & (0x1 << (i%BITSPERWORD)))))) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->index = i;
         vars[ants->numAntecedents]->var = _y;
         if(![_y isFree:i])
            vars[ants->numAntecedents]->value = [_y getBit:i];
         else
            vars[ants->numAntecedents]->value = !((ISTRUE(state[2][i/BITSPERWORD], state[3][i/BITSPERWORD]) & (0x1 << (i%BITSPERWORD))) == 0);
         ants->numAntecedents++;
      }
   }
   //   if(ants->numAntecedents > (wordLength*BITSPERWORD*2+1))
   //   if((assignment->var == _z) && (assignment->value == 1))
   //      NSLog(@"%d  %d",ants->numAntecedents,2*(32-assignment->index));
   return ants;
}

-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment
{
   //NSLog(@"Implication for 0x%lx[%u] = %@  traced back through %@", (unsigned long)assignment->var, assignment->index, (CPBitVarI*)assignment->var, self);
   ORUInt wordLength = [_x getWordLength];
   ORUInt bitLength = [_x bitLength];
   
   CPBitAntecedents* ants = malloc(sizeof(CPBitAntecedents));
   CPBitAssignment** vars;
   vars = malloc(sizeof(CPBitAssignment*)*(wordLength*BITSPERWORD*2+1));
   ants->numAntecedents = 0;
   ants->antecedents = vars;
   
   TRUInt* xUp;
   TRUInt* xLow;
   TRUInt* yUp;
   TRUInt* yLow;
   TRUInt* zUp;
   TRUInt* zLow;
   
   [_x getUp:&xUp andLow:&xLow];
   [_y getUp:&yUp andLow:&yLow];
   [_z getUp:&zUp andLow:&zLow];
   
   ORInt index = assignment->index;
   
   ORUInt* x1y0 = alloca(sizeof(ORUInt)*wordLength);
   ORInt idx=0;
   for(int i=wordLength-1;i>=0;i--){
      x1y0[i] = (xLow[i]._val & ~yUp[i]._val);
      if(x1y0[i] != 0){
         idx = (i*BITSPERWORD)+(BITSPERWORD - __builtin_clz(x1y0[i])-1);
         break;
      }
   }
   
   
   //   NSLog(@"                                             3322222222221111111111");
   //   NSLog(@"                                             10987654321098765432109876543210");
   //   if(assignment->var == _x)
   //      NSLog(@"%@[%d]=%d",_x,assignment->index, assignment->value);
   //   else
   //      NSLog(@"%@",_x);
   //
   //   if(assignment->var == _y)
   //      NSLog(@"%@[%d]=%d",_y,assignment->index, assignment->value);
   //   else
   //      NSLog(@"%@",_y);
   
   
   ORBool xAtIndex, yAtIndex, zAt0;
   xAtIndex = yAtIndex = zAt0 = false;
   
   if(assignment->var == _x){
      if(![_y isFree:index]){
         yAtIndex = true;
         //         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         //         vars[ants->numAntecedents]->index = index;
         //         vars[ants->numAntecedents]->var = _y;
         //         vars[ants->numAntecedents]->value = [_y getBit:index];
         if ((index>idx) && !assignment->value && [_y getBit:index])
            index=idx;
         //         ants->numAntecedents++;
      }
      if(![_z isFree:0]){
         //         zAt0 = true;
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->index = 0;
         vars[ants->numAntecedents]->var = _z;
         vars[ants->numAntecedents]->value = [_z getBit:0];
         ants->numAntecedents++;
      }
   }
   else if(assignment->var == _y){
      if(![_x isFree:index]){
         xAtIndex = true;
         //         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         //         vars[ants->numAntecedents]->index = index;
         //         vars[ants->numAntecedents]->var = _x;
         //         vars[ants->numAntecedents]->value = [_x getBit:index];
         if((index>idx) && assignment->value && ![_x getBit:index])
            index=idx;
         //         ants->numAntecedents++;
      }
      if(![_z isFree:0]){
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->index = 0;
         vars[ants->numAntecedents]->var = _z;
         vars[ants->numAntecedents]->value = [_z getBit:0];
         ants->numAntecedents++;
      }
   }
   else if(assignment->var == _z){
      ORUInt* different = alloca(sizeof(ORUInt)*wordLength);
      ORInt diffIndex =0;
      for(int i=wordLength-1;i>=0;i--){
         different[i] = (xUp[i]._val ^ yUp[i]._val) | (xLow[i]._val ^ yLow[i]._val);
         if(different[i] != 0){
            diffIndex = (i*BITSPERWORD)+(BITSPERWORD - __builtin_clz(different[i])-1);
            break;
         }
      }
      if([_z getBit:0] == false)
         index = diffIndex;
      else
         index = idx;
      if(![_x isFree:index]){
         xAtIndex = true;
         //         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         //         vars[ants->numAntecedents]->index = index;
         //         vars[ants->numAntecedents]->var = _x;
         //         vars[ants->numAntecedents]->value = [_x getBit:index];
         //         ants->numAntecedents++;
      }
      if(![_y isFree:index]){
         yAtIndex = true;
         //         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         //         vars[ants->numAntecedents]->index = index;
         //         vars[ants->numAntecedents]->var = _y;
         //         vars[ants->numAntecedents]->value = [_y getBit:index];
         //         ants->numAntecedents++;
      }
   }
   
   //   if((assignment->var == _y) && (assignment->value == 1) && [_y bound] && (__builtin_popcount(yUp[0]._val & yLow[0]._val)==1))
   //      for(int i=0; i<index;i++){
   //         if(![_y isFree:i]){
   //            vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
   //            vars[ants->numAntecedents]->index = i;
   //            vars[ants->numAntecedents]->var = _y;
   //            vars[ants->numAntecedents]->value = [_y getBit:i];
   //            ants->numAntecedents++;
   //         }
   //      }
   
   //   for(int i=index+1;i<bitLength;i++){
   //      if(i==assignment->index)
   //         continue;
   for(int i=index; i<bitLength;i++){
      if(((i!=assignment->index) && ![_x isFree:i]) || ((i==assignment->index) && xAtIndex)){
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->index = i;
         vars[ants->numAntecedents]->var = _x;
         vars[ants->numAntecedents]->value = [_x getBit:i];
         ants->numAntecedents++;
      }
      if(((i!=assignment->index) && ![_y isFree:i]) || ((i==assignment->index) && yAtIndex)){
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->index = i;
         vars[ants->numAntecedents]->var = _y;
         vars[ants->numAntecedents]->value = [_y getBit:i];
         ants->numAntecedents++;
      }
   }
   //   if(ants->numAntecedents > (wordLength*BITSPERWORD*2+1))
   //   if((assignment->var == _z) && (assignment->value == 1))
   //      NSLog(@"%d  %d",ants->numAntecedents,2*(32-assignment->index));
   return ants;
}

- (void) dealloc
{
   [super dealloc];
   free(_state);
}

-(void) post
{
   [self propagate];
   if (![_x bound])
      [_x whenChangePropagate: self];
   if (![_y bound])
      [_y whenChangePropagate: self];
   if (![_z bound])
      [_z whenChangePropagate: self];
   [self propagate];
   //   return ORSuspend;
}
-(void) propagate
{
   //TODO: Fix so that _z can be larger than 32 bits if this is the design decision made
   
   
   
   
   
   
#ifdef BIT_DEBUG
   NSLog(@"**********************************");
   NSLog(@"Bit (signed) < Constraint propagated.");
#endif
   
   unsigned int wordLength = [_x getWordLength];
   unsigned int bitLength = [_x bitLength];
   unsigned int zWordLength = [_z getWordLength];
//   unsigned int zBitLength = [_z bitLength];
   
   TRUInt* xLow;
   TRUInt* xUp;
   TRUInt* yLow;
   TRUInt* yUp;
   TRUInt* zLow;
   TRUInt* zUp;
   
   [_x getUp:&xUp andLow:&xLow];
   [_y getUp:&yUp andLow:&yLow];
   [_z getUp:&zUp andLow:&zLow];
   
   ORUInt* newXUp = alloca(sizeof(ORUInt)*wordLength);
   ORUInt* newXLow = alloca(sizeof(ORUInt)*wordLength);
   
   ORUInt* newYUp = alloca(sizeof(ORUInt)*wordLength);
   ORUInt* newYLow = alloca(sizeof(ORUInt)*wordLength);
   
   ORUInt* newZUp = alloca(sizeof(ORUInt)*zWordLength);
   ORUInt* newZLow = alloca(sizeof(ORUInt)*zWordLength);
   
//   NSLog(@"*******************************************");
//   NSLog(@"s|x < s|y ? z");
//   NSLog(@"x=%@\n",_x);
//   NSLog(@"y=%@\n",_y);
//   NSLog(@"z=%@\n\n",_z);
   
   
   for (int i=0; i<wordLength; i++) {
      newXUp[i] = xUp[i]._val;
      newXLow[i] = xLow[i]._val;
      newYUp[i] = yUp[i]._val;
      newYLow[i] = yLow[i]._val;
   }
   for(int i=0;i<zWordLength;i++){
      newZUp[i] = zUp[i]._val;
      newZLow[i] = zLow[i]._val;
   }
   
   ORUInt *freeX = alloca(sizeof(ORUInt)*wordLength);
   ORUInt *freeY = alloca(sizeof(ORUInt)*wordLength);
   ORUInt *different = alloca(sizeof(ORUInt)*wordLength);
   
   ORUInt signMask = 0x1 << (BITSPERWORD - (bitLength%BITSPERWORD) -1);
   
   
   ORUInt numFreeBitsX = 0;
   ORUInt numFreeBitsY = 0;
   
   //Find most sig. unset bit in x
   for(ORInt i = wordLength-1;i>=0;i--){
      freeX[i] = xUp[i]._val ^ xLow[i]._val;
      numFreeBitsX += __builtin_popcount(freeX[i]);
   }
   //Find most sig. unset bit in y
   for(ORInt i = wordLength-1;i>=0;i--){
      freeY[i] = yUp[i]._val ^ yLow[i]._val;
      numFreeBitsY += __builtin_popcount(freeY[i]);
   }
   
   //Find bits that are different in x and y
   for (int i=0;i<wordLength;i++)
      different[i] = (newXUp[i] ^ newYUp[i]) | (newXLow[i] ^ newYLow[i]);
   ORInt diffIndex;
   ORBool more;

   
   //flip most sig .sign bit if set
   if((~freeX[wordLength-1]) & signMask){
      newXUp[wordLength-1] ^= signMask;
      newXLow[wordLength-1] ^= signMask;
   }
   if((~freeY[wordLength-1]) & signMask){
      newYUp[wordLength-1] ^= signMask;
      newYLow[wordLength-1] ^= signMask;
   }
   
   
   ORBool xlty = false;
   ORBool xgty = false;
   ORBool xeqy = true;
   
   for (int i=wordLength-1; i>=0; i--) {
      if (((newXUp[i] ^ newXLow[i]) | (newYUp[i]^ newYLow[i]) | (newXLow[i] ^ newYLow[i])) == 0)
         continue;
      else
         xeqy = false;
      if ( newXLow[i] > newYUp[i]) {
         xgty = true;
         break;
      }
      else if (newXUp[i] < newYLow[i]) {
         xlty = true;
         break;
      }
   }
   

   if(xlty){
      newZLow[0] |= 0x1;
   }
   if(xgty || xeqy){
      for (int i=0; i<zWordLength; i++)
         newZUp[i] = 0;
   }
   _state[0] = newXUp;
   _state[1] = newXLow;
   _state[2] = newYUp;
   _state[3] = newYLow;
   _state[4] = newZUp;
   _state[5] = newZLow;
   
   checkDomainConsistency(_z, newZLow, newZUp, zWordLength, self);
   [_z setUp:newZUp andLow:newZLow for:self];

   
   if(numFreeBitsX != 0){
      do{
         diffIndex =-1;
         for(int i=wordLength-1;i>=0;i--){
            if(different[i] != 0){
               diffIndex = (BITSPERWORD - __builtin_clz(different[i]))-1;
               break;
            }
         }
         if(diffIndex < 0){
            break;
         }
         
         more = false;
         //Find most sig unset bit in x
         ORInt bitIndex = -1;
         ORUInt wordIndex = 0;
         for(int i=wordLength-1;i>=0;i--){
            if(freeX[i] != 0){
               bitIndex = (BITSPERWORD - __builtin_clz(freeX[i]))-1;
               wordIndex = i;
               break;
            }
         }
         
         if(bitIndex < 0)
            break;
         
         ORUInt mask = 0x1 << bitIndex;
         if(diffIndex <= bitIndex){
            //Can we fix bit?
            ORUInt temp;
            
            if(zLow[0]._val){
               temp = newXLow[wordIndex] | mask;
               if(temp >= newYUp[wordIndex]){
                  newXUp[wordIndex] &= ~mask;
                  freeX[wordIndex] &= ~mask;
                  different[wordIndex] = (newXUp[wordIndex] ^ newYUp[wordIndex]) | (newXLow[wordIndex] ^ newYLow[wordIndex]);
                  numFreeBitsX--;
                  more = true;
//                  checkDomainConsistency(_x, newXLow, newXUp, wordLength, self);
//                  [_x setUp:newXUp andLow:newXLow for:self];
               }
//               else if((temp >= newYLow[wordIndex]) && (numFreeBitsY == 0)){
//                  newXUp[wordIndex] &= ~mask;
//                  freeX[wordIndex] &= ~mask;
//                  different[wordIndex] = (newXUp[wordIndex] ^ newYUp[wordIndex]) | (newXLow[wordIndex] ^ newYLow[wordIndex]);
//                  numFreeBitsX--;
//                  more = true;
//               }
//
            }
            else if (zUp[0]._val == 0){
               temp = newXUp[wordIndex] & ~mask;
               //x must be >= y
               if(temp < newYLow[wordIndex]){
                  newXLow[wordIndex] |= mask;
                  freeX[wordIndex] &= ~mask;
                  different[wordIndex] = (newXUp[wordIndex] ^ newYUp[wordIndex]) | (newXLow[wordIndex] ^ newYLow[wordIndex]);
                  numFreeBitsX--;
                  more = true;
//                  checkDomainConsistency(_x, newXLow, newXUp, wordLength, self);
//                  [_x setUp:newXUp andLow:newXLow for:self];
               }
            }
         }
      }while(more);
   }
   
   if(numFreeBitsY != 0){
      do{
         diffIndex =-1;
         for(int i=wordLength-1;i>=0;i--){
            if(different[i] != 0){
               diffIndex = (BITSPERWORD - __builtin_clz(different[i])-1);
               break;
            }
         }
         if(diffIndex < 0){
            break;
         }
         
         more = false;
         //Find most sig unset bit in x
         ORInt bitIndex = -1;
         ORUInt wordIndex = 0;
         for(int i=wordLength-1;i>=0;i--){
            if(freeY[i] != 0){
               bitIndex = (BITSPERWORD - __builtin_clz(freeY[i])-1);
               wordIndex = i;
               break;
            }
         }
         
         if(bitIndex < 0)
            break;
         
         ORUInt mask = 0x1 << bitIndex;
         if(diffIndex <= bitIndex){
            //Can we fix bit?
            ORUInt temp;
            
            if(zLow[0]._val){ // If x < y = t, then will clearing this bit make xmin > ymax?
               temp = newYUp[wordIndex] & ~mask;
               if(temp <= newXLow[wordIndex]){
                  newYLow[wordIndex] |= mask;
                  freeY[wordIndex] &= ~mask;
                  different[wordIndex] = (newXUp[wordIndex] ^ newYUp[wordIndex]) | (newXLow[wordIndex] ^ newYLow[wordIndex]);
                  numFreeBitsY--;
                  more = true;
//                  checkDomainConsistency(_y, newYLow, newYUp, wordLength, self);
//                  [_y setUp:newYUp andLow:newYLow for:self];
               }
            }
            else if (zUp[0]._val == 0){
               temp = newYLow[wordIndex] | mask;
               //x must be >= y
               if(temp > newXUp[wordIndex]){//if we set bit in y is ymin > xmax?
                  newYUp[wordIndex] &= ~mask;
                  freeY[wordIndex] &= ~mask;
                  different[wordIndex] = (newXUp[wordIndex] ^ newYUp[wordIndex]) | (newXLow[wordIndex] ^ newYLow[wordIndex]);
                  numFreeBitsY--;
                  more = true;
//                  checkDomainConsistency(_y, newYLow, newYUp, wordLength, self);
//                  [_y setUp:newYUp andLow:newYLow for:self];
               }
            }
         }
      }while(more);
   }

   //flip most sig .sign bit if set
   if((~freeX[wordLength-1]) & signMask){
      newXUp[wordLength-1] ^= signMask;
      newXLow[wordLength-1] ^= signMask;
   }
   if((~freeY[wordLength-1]) & signMask){
      newYUp[wordLength-1] ^= signMask;
      newYLow[wordLength-1] ^= signMask;
   }
   
   
//   if (checkDomainConsistency(_x, newXLow, newXUp, wordLength, self))
//      failNow();
//   
//   if (checkDomainConsistency(_y, newYLow, newYUp, wordLength, self))
//      failNow();
//   
//   [_x setUp:newXUp andLow:newXLow for:self];
//   [_y setUp:newYUp andLow:newYLow for:self];


//   NSLog(@"newX = %@",bitvar2NSString(newXLow, newXUp, bitLength));
//   NSLog(@"newY = %@",bitvar2NSString(newYLow, newYUp, bitLength));
//   NSLog(@"newZ = %@",bitvar2NSString(newZLow, newZUp, zBitLength));

   _state[0] = newXUp;
   _state[1] = newXLow;
   _state[2] = newYUp;
   _state[3] = newYLow;
   _state[4] = newZUp;
   _state[5] = newZLow;
   
   ORBool xFail = checkDomainConsistency(_x, newXLow, newXUp, wordLength, self);
   ORBool yFail = checkDomainConsistency(_y, newYLow, newYUp, wordLength, self);
   ORBool zFail = checkDomainConsistency(_z, newZLow, newZUp, zWordLength, self);
   if (xFail || yFail || zFail) {
      failNow();
   }
   [_x setUp:newXUp andLow:newXLow for:self];
   [_y setUp:newYUp andLow:newYLow for:self];
   [_z setUp:newZUp andLow:newZLow for:self];
   
//   NSLog(@"x=%@\n",_x);
//   NSLog(@"y=%@\n",_y);
//   NSLog(@"z=%@\n\n",_z);

   
#ifdef BIT_DEBUG
//   NSLog(@"      X =%@",_x);
//   NSLog(@"   <  Y =%@",_y);
//   NSLog(@"   =  Z =%@\n\n",_z);
#endif
}
@end

@implementation CPBitITE
-(id) initCPBitITE:(CPBitVarI *)i then:(CPBitVarI *)t else:(CPBitVarI *)e result:(CPBitVarI*)r{
   self = [super initCPBitCoreConstraint:[i engine]];
   _i = i;
   _t = t;
   _e = e;
   _r = r;
   _state = malloc(sizeof(ORUInt*)*8);
   return self;
   
}

- (void) dealloc
{
   [super dealloc];
   free(_state);
}
-(NSString*) description
{
   NSMutableString* string = [NSMutableString stringWithString:[super description]];
   [string appendString:@" with "];
   [string appendString:[NSString stringWithFormat:@"%@, ",_i]];
   [string appendString:[NSString stringWithFormat:@"%@, ",_t]];
   [string appendString:[NSString stringWithFormat:@"%@, ",_e]];
   [string appendString:[NSString stringWithFormat:@"and %@\n",_r]];
   
   return string;
}


-(void) post
{
   [self propagate];
   if (![_i bound])
      [_i whenChangePropagate: self];
   if (![_t bound])
      [_t whenChangePropagate: self];
   if (![_e bound])
      [_e whenChangePropagate: self];
   if (![_r bound])
      [_r whenChangePropagate: self];
   [self propagate];
//   return ORSuspend;
}

-(CPBitAntecedents*) getAntecedents:(CPBitAssignment*)assignment{
   return ([self getAntecedentsFor:assignment withState:_state]);
}
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment withState:(ORUInt**)state
{
  //NSLog(@"Implication for 0x%lx[%u] = %@  traced back through %@", (unsigned long)assignment->var, assignment->index, (CPBitVarI*)assignment->var, self);
   
   CPBitAntecedents* ants = malloc(sizeof(CPBitAntecedents));
   CPBitAssignment** vars;
   
   //   vars  = malloc(sizeof(CPBitAssignment*)*4);
   ants->numAntecedents = 0;
   
   ORUInt index = assignment->index;
   //   ants->antecedents = vars;
   
   ORUInt wordLength = [_r getWordLength];
   ORUInt bitLength = [_r bitLength];
   
   CPBitVarI* var;
   ORUInt* varUp;
   ORUInt* varLow;
   
   varUp = malloc(sizeof(ORUInt)*wordLength);
   varLow = malloc(sizeof(ORUInt)*wordLength);
   
   if (assignment->var == _i) {
      
      vars  = malloc(sizeof(CPBitAssignment*)*2*bitLength);
      
      
      ORBool teqr = true;
      ORBool eeqr = true;
      for (int i =0; i<wordLength; i++) {
         if ((state[2][i] != state[6][i]) || (state[3][i] != state[7][i])) {
            teqr = false;
         }
         if ((state[4][i] != state[6][i]) || (state[5][i] != state[7][i])) {
            eeqr = false;
         }
      }
      
      if (teqr) {
         var = _t;
         for(int i=0;i<wordLength;i++){
            varUp[i] = state[2][i];
            varLow[i] = state[3][i];
         }
      }
      if (eeqr) {
         var = _e;
         for(int i=0;i<wordLength;i++){
            varUp[i] = state[4][i];
            varLow[i] = state[5][i];
         }
      }
      
      for (int i = 0; i<bitLength; i++) {
         if (![var isFree:i] || (~ISFREE(varUp[i/BITSPERWORD], varLow[i/BITSPERWORD]) & (0x1 << (i%BITSPERWORD)))) {
            vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
            vars[ants->numAntecedents]->var = var;
            vars[ants->numAntecedents]->index = i;
            if(![var isFree:i])
               vars[ants->numAntecedents]->value = [var getBit:i];
            else
               vars[ants->numAntecedents]->value = !((ISTRUE(varUp[i/BITSPERWORD], varLow[i/BITSPERWORD]) & (0x1 << (i%BITSPERWORD))) == 0);
            ants->numAntecedents++;
         }
         if (![_r isFree:i] || (~ISFREE(state[6][index/BITSPERWORD], state[7][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD)))) {
            vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
            vars[ants->numAntecedents]->var = _r;
            vars[ants->numAntecedents]->index = i;
            if(![_r isFree:i])
               vars[ants->numAntecedents]->value = [_r getBit:i];
            else
               vars[ants->numAntecedents]->value = !((ISTRUE(state[6][i/BITSPERWORD], state[7][i/BITSPERWORD]) & (0x1 << (i%BITSPERWORD))) == 0);
            ants->numAntecedents++;
         }
      }
   }
   
   else if (assignment->var == _t){
      vars  = malloc(sizeof(CPBitAssignment*)*(bitLength+1));
      if (![_i isFree:0] || (~ISFREE(state[0][0], state[1][0]) & 0x1)) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _i;
         vars[ants->numAntecedents]->index = 0;
         if(![_i isFree:0])
            vars[ants->numAntecedents]->value = [_i getBit:0];
         else
            vars[ants->numAntecedents]->value = !((ISTRUE(state[0][0], state[1][0]) & 0x1) == 0);
         ants->numAntecedents++;
      }
      
      if (![_r isFree:index] || (~ISFREE(state[6][index/BITSPERWORD], state[7][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD)))) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _r;
         vars[ants->numAntecedents]->index = index;
         if(![_r isFree:index])
            vars[ants->numAntecedents]->value = [_r getBit:index];
         else
            vars[ants->numAntecedents]->value = !((ISTRUE(state[6][index/BITSPERWORD], state[7][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD))) == 0);
         ants->numAntecedents++;
      }
   }
   else if (assignment->var == _e){
      vars  = malloc(sizeof(CPBitAssignment*)*(bitLength+1));
      if (![_i isFree:0] || (~ISFREE(state[0][0], state[1][0]) & 0x1)) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _i;
         vars[ants->numAntecedents]->index = 0;
         if(![_i isFree:0])
            vars[ants->numAntecedents]->value = [_i getBit:0];
         else
            vars[ants->numAntecedents]->value = !((ISTRUE(state[0][0], state[1][0]) & 0x1) == 0);
         ants->numAntecedents++;
      }
      if (![_r isFree:index] || (~ISFREE(state[6][index/BITSPERWORD], state[7][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD)))) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _r;
         vars[ants->numAntecedents]->index = index;
         if(![_r isFree:index])
            vars[ants->numAntecedents]->value = [_r getBit:index];
         else
            vars[ants->numAntecedents]->value = !((ISTRUE(state[6][index/BITSPERWORD], state[7][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD))) == 0);
         ants->numAntecedents++;
      }
   }
   else if (assignment->var == _r){
      vars  = malloc(sizeof(CPBitAssignment*)*(bitLength+1));
      if (![_i isFree:0] || (~ISFREE(state[0][0], state[1][0]) & 0x1)) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _i;
         vars[ants->numAntecedents]->index = 0;
         if(![_i isFree:0])
            vars[ants->numAntecedents]->value = [_i getBit:0];
         else
            vars[ants->numAntecedents]->value = !((ISTRUE(state[0][0], state[1][0]) & 0x1) == 0);
         ants->numAntecedents++;
      }
      ORBool ifTrue = !((ISTRUE(state[0][0], state[1][0]) & 0x1) == 0);
      CPBitVarI* var;
      if (ifTrue) {
         var = _t;
         for(int i=0;i<wordLength;i++){
            varUp[i] = state[2][i];
            varLow[i] = state[3][i];
         }
      }
      else{
         var = _e;
         for(int i=0;i<wordLength;i++){
            varUp[i] = state[4][i];
            varLow[i] = state[5][i];
         }
      }
      if (![var isFree:index] || (~ISFREE(varUp[index/BITSPERWORD], varLow[index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD)))) {
         {
            vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
            vars[ants->numAntecedents]->var = var;
            vars[ants->numAntecedents]->index = index;
            if(![var isFree:index])
               vars[ants->numAntecedents]->value = [var getBit:index];
            else
               vars[ants->numAntecedents]->value = !((ISTRUE(varUp[index/BITSPERWORD], varLow[index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD))) == 0);
            ants->numAntecedents++;
         }
      }
   }
   else {
      vars=NULL;
   }
   ants->antecedents = vars;
   return ants;
}


-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment
{
  //NSLog(@"Implication for 0x%lx[%u] = %@  traced back through %@", (unsigned long)assignment->var, assignment->index, (CPBitVarI*)assignment->var, self);

   CPBitAntecedents* ants = malloc(sizeof(CPBitAntecedents));
   CPBitAssignment** vars;

//   vars  = malloc(sizeof(CPBitAssignment*)*4);
   ants->numAntecedents = 0;

   ORUInt index = assignment->index;
//   ants->antecedents = vars;
   
   ORUInt wordLength = [_r getWordLength];
   ORUInt bitLength = [_r bitLength];


   if (assignment->var == _i) {
      
      vars  = malloc(sizeof(CPBitAssignment*)*2*bitLength);

      TRUInt* tUp;
      TRUInt* tLow;
      TRUInt* eUp;
      TRUInt* eLow;
      TRUInt* rUp;
      TRUInt* rLow;
      
      
      [_t getUp:&tUp andLow:&tLow];
      [_e getUp:&eUp andLow:&eLow];
      [_r getUp:&rUp andLow:&rLow];
      
      ORBool teqr = true;
      ORBool eeqr = true;
      for (int i =0; i<wordLength; i++) {
         if ((tUp[i]._val != rUp[i]._val) || (tLow[i]._val != rLow[i]._val)) {
            teqr = false;
         }
         if ((eUp[i]._val != rUp[i]._val) || (eLow[i]._val != rLow[i]._val)) {
            eeqr = false;
         }
      }
      
      CPBitVarI* var;
      
      if (teqr) {
         var = _t;
      }
      if (eeqr) {
         var = _e;
      }
      for (int i = 0; i<bitLength; i++) {
         if (![var isFree:i]) {
            {
               vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
               vars[ants->numAntecedents]->var = var;
               vars[ants->numAntecedents]->index = i;
               vars[ants->numAntecedents]->value = [var getBit:i];
               ants->numAntecedents++;
            }
         }
         if (![_r isFree:index]) {
            vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
            vars[ants->numAntecedents]->var = _r;
            vars[ants->numAntecedents]->index = i;
            vars[ants->numAntecedents]->value = [_r getBit:i];
            ants->numAntecedents++;
         }
      }
   }

   else if (assignment->var == _t){
      vars  = malloc(sizeof(CPBitAssignment*)*(bitLength+1));

      if (![_i isFree:0]) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _i;
         vars[ants->numAntecedents]->index = 0;
         vars[ants->numAntecedents]->value = [_i getBit:0];
         ants->numAntecedents++;
      }
      if (![_r isFree:index]) {
         {
            vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
            vars[ants->numAntecedents]->var = _r;
            vars[ants->numAntecedents]->index = index;
            vars[ants->numAntecedents]->value = [_r getBit:index];
            ants->numAntecedents++;
         }
      }
   }
   else if (assignment->var == _e){
      vars  = malloc(sizeof(CPBitAssignment*)*(bitLength+1));
      if (![_i isFree:0]) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _i;
         vars[ants->numAntecedents]->index = 0;
         vars[ants->numAntecedents]->value = [_i getBit:0];
         ants->numAntecedents++;
      }
      if (![_r isFree:index]) {
         {
            vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
            vars[ants->numAntecedents]->var = _r;
            vars[ants->numAntecedents]->index = index;
            vars[ants->numAntecedents]->value = [_r getBit:index];
            ants->numAntecedents++;
         }
      }
   }
   else if (assignment->var == _r){
      vars  = malloc(sizeof(CPBitAssignment*)*(bitLength+1));
      if (![_i isFree:0]) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _i;
         vars[ants->numAntecedents]->index = 0;
         vars[ants->numAntecedents]->value = [_i getBit:0];
         ants->numAntecedents++;
      }
      ORBool ifTrue = [_i getBit:0];
      CPBitVarI* var;
      if (ifTrue) {
         var = _t;
      }
      else{
         var = _e;
      }
      if (![var isFree:index]) {
         {
            vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
            vars[ants->numAntecedents]->var = var;
            vars[ants->numAntecedents]->index = index;
            vars[ants->numAntecedents]->value = [var getBit:index];
            ants->numAntecedents++;
         }
      }
   }
   else {
      vars=NULL;
   }
   ants->antecedents = vars;
   return ants;
}

-(void) propagate
{
#ifdef BIT_DEBUG
   NSLog(@"**********************************");
   NSLog(@"Bit If-Then-Else Constraint propagated.");
#endif
   
   unsigned int wordLength = [_t getWordLength];
   
   TRUInt* iLow;
   TRUInt* iUp;
   TRUInt* tLow;
   TRUInt* tUp;
   TRUInt* eLow;
   TRUInt* eUp;
   TRUInt* rLow;
   TRUInt* rUp;
   
   [_i getUp:&iUp andLow:&iLow];
   [_t getUp:&tUp andLow:&tLow];
   [_e getUp:&eUp andLow:&eLow];
   [_r getUp:&rUp andLow:&rLow];
   
   unsigned int* newIUp = alloca(sizeof(unsigned int));
   unsigned int* newILow = alloca(sizeof(unsigned int));
   unsigned int* newTUp = alloca(sizeof(unsigned int)*wordLength);
   unsigned int* newTLow = alloca(sizeof(unsigned int)*wordLength);
   unsigned int* newEUp = alloca(sizeof(unsigned int)*wordLength);
   unsigned int* newELow = alloca(sizeof(unsigned int)*wordLength);
   unsigned int* newRUp = alloca(sizeof(unsigned int)*wordLength);
   unsigned int* newRLow = alloca(sizeof(unsigned int)*wordLength);
   
   
//      NSLog(@"*******************************************");
//      NSLog(@"if %@\n",_i);
//      NSLog(@"then %@\n",_t);
//      NSLog(@"else %@\n",_e);
//      NSLog(@"res %@\n\n",_r);
   
   
//   if(![_i bound] && [_e bound] && [_r bound])
//      NSLog(@"Stop");

   newILow[0] = iLow[0]._val;
   newIUp[0] = iUp[0]._val;
   
   for (int i=0; i<wordLength; i++) {
      newTLow[i] = tLow[i]._val;
      newTUp[i] = tUp[i]._val;
      newELow[i] = eLow[i]._val;
      newEUp[i] = eUp[i]._val;
      newRLow[i] = rLow[i]._val;
      newRUp[i] = rUp[i]._val;
   }

   if (iLow[0]._val > 0) {
      for(int i=0;i<wordLength;i++){
         newTUp[i] = newRUp[i] = tUp[i]._val & rUp[i]._val;
         newTLow[i] = newRLow[i] = tLow[i]._val | rLow[i]._val;
      }
   }
   else if ([_i bound]) {
      for(int i=0;i<wordLength;i++){
         newEUp[i] = newRUp[i] = eUp[i]._val & rUp[i]._val;
         newELow[i] = newRLow[i] = eLow[i]._val | rLow[i]._val;
      }
   }
   //if _r is bound
   if ([_r bound]) {
      ORUInt rNEQt = 0;
      ORUInt rNEQe = 0;
      for (int i=0; i<wordLength; i++) {
         rNEQt |= (tLow[i]._val & ~rUp[i]._val);// ^ xLow[i]._val;
         rNEQt |= (~tUp[i]._val & rLow[i]._val);// ^ ~xUp[i]._val;
         rNEQe |= (eLow[i]._val & ~rUp[i]._val);// ^ xLow[i]._val;
         rNEQe |= (~eUp[i]._val & rLow[i]._val);// ^ ~xUp[i]._val;
      }
      // if (_r == _t) && (_r != _e) && (_i is bound)
      if (!rNEQt && rNEQe) {
         //    if countbits in i is zero
         //       fail
         newILow[0] = 1;
      }
      // else if (_r == _e) && (_r != _t)
      else if (!rNEQe && rNEQt) {
//         for (int i=0; i<wordLength; i++)
         //    if countbits in i is > zero
         //       fail
            newIUp[0] = 0;
         }
      }
   _state[0] = newIUp;
   _state[1] = newILow;
   _state[2] = newTUp;
   _state[3] = newTLow;
   _state[4] = newEUp;
   _state[5] = newELow;
   _state[6] = newRUp;
   _state[7] = newRLow;
   
   

   ORBool iFail = checkDomainConsistency(_i, newILow, newIUp, 1, self);
   ORBool tFail = checkDomainConsistency(_t, newTLow, newTUp, wordLength, self);
   ORBool eFail = checkDomainConsistency(_e, newELow, newEUp, wordLength, self);
   ORBool rFail = checkDomainConsistency(_r, newRLow, newRUp, wordLength, self);
   
   if(iFail || tFail || eFail || rFail){
      failNow();
   }

   [_i setUp:newIUp andLow:newILow for:self];
   [_t setUp:newTUp andLow:newTLow for:self];
   [_e setUp:newEUp andLow:newELow for:self];
   [_r setUp:newRUp andLow:newRLow for:self];
   
//   NSLog(@"if %@\n",_i);
//   NSLog(@"then %@\n",_t);
//   NSLog(@"else %@\n",_e);
//   NSLog(@"res %@\n\n",_r);
   
   return;
}
@end

@implementation CPBitLogicalEqual
-(id) initCPBitLogicalEqual:(CPBitVarI *)x EQ:(CPBitVarI *)y eval:(CPBitVarI *)z{
   self = [super initCPBitCoreConstraint:[x engine]];
   _x = x;
   _y = y;
   _z = z;
   _state = malloc(sizeof(ORUInt*)*6);
   return self;
   
}

- (void) dealloc
{
   [super dealloc];
   free(_state);
}

-(NSString*) description
{
   NSMutableString* string = [NSMutableString stringWithString:[super description]];
   [string appendString:@" with "];
   [string appendString:[NSString stringWithFormat:@"%@, ",_x]];
   [string appendString:[NSString stringWithFormat:@"%@, ",_y]];
   [string appendString:[NSString stringWithFormat:@"and %@\n",_z]];
   
   return string;
}

-(void) post
{
   [self propagate];
   if (![_x bound])
      [_x whenChangePropagate: self];
   if (![_y bound])
      [_y whenChangePropagate: self];
   if (![_z bound])
      [_z whenChangePropagate: self];
   [self propagate];
}
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment
{
   //NSLog(@"Implication for 0x%lx[%u] = %@  traced back through %@", (unsigned long)assignment->var, assignment->index, (CPBitVarI*)assignment->var, self);
   
   CPBitAntecedents* ants = malloc(sizeof(CPBitAntecedents));
   CPBitAssignment** vars;
   ants->numAntecedents = 0;
   
   ORUInt index = assignment->index;
   
   if (assignment->var == _x) {
      vars  = malloc(sizeof(CPBitAssignment*)*2);
      if (![_y isFree:index]) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _y;
         vars[ants->numAntecedents]->index = index;
         vars[ants->numAntecedents]->value = [_y getBit:index];
         ants->numAntecedents++;
      }
      if (![_z isFree:0]) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _z;
         vars[ants->numAntecedents]->index = 0;
         vars[ants->numAntecedents]->value = [_z getBit:0];
         ants->numAntecedents++;
      }
   }
   else if (assignment->var == _y){
      vars  = malloc(sizeof(CPBitAssignment*)*2);
      if (![_x isFree:index]) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _x;
         vars[ants->numAntecedents]->index = index;
         vars[ants->numAntecedents]->value = [_x getBit:index];
         ants->numAntecedents++;
      }
      if (![_z isFree:0]) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _z;
         vars[ants->numAntecedents]->index = 0;
         vars[ants->numAntecedents]->value = [_z getBit:0];
         ants->numAntecedents++;
      }
   }
   else if (assignment->var == _z){
      ORBool zVal = [_z getBit:0];
      ORUInt bitLength = [_x bitLength];
      //If _x == _y was expected to be false, all bits contribute
      if (!zVal) {
         vars  = malloc(sizeof(CPBitAssignment*)*bitLength*2);
         for(int i=0;i<bitLength;i++){
            vars[i] = malloc(sizeof(CPBitAssignment));
            vars[i]->var = _x;
            vars[i]->index = i;
            vars[i]->value = [_x getBit:i];
            vars[i+bitLength] = malloc(sizeof(CPBitAssignment));
            vars[i+bitLength]->var = _y;
            vars[i+bitLength]->index = i;
            vars[i+bitLength]->value = [_y getBit:i];
         }
         ants->numAntecedents = bitLength*2;
      }
      else{
         //get index of least significant dissimilar bit
         vars  = malloc(sizeof(CPBitAssignment*)*2);
         TRUInt *xLow, *yLow;
         ORUInt wordLength = [_x getWordLength];
         ORUInt xXORy;
         xLow = [_x getLow];
         yLow = [_y getLow];
         
         for (int i = 0; i<wordLength; i++) {
            xXORy = xLow->_val ^ yLow->_val;
            if (xXORy != 0) {
               index = __builtin_ctz(xXORy) + (i * BITSPERWORD);
               break;
            }
         }
         vars[0] = malloc(sizeof(CPBitAssignment));
         vars[0]->var = _x;
         vars[0]->index = index;
         vars[0]->value = [_x getBit:index];
         vars[1] = malloc(sizeof(CPBitAssignment));
         vars[1]->var = _y;
         vars[1]->index = index;
         vars[1]->value = [_y getBit:index];
         ants->numAntecedents=2;
      }
   }
   else{
      vars = NULL;
   }
   ants->antecedents = vars;
   return ants;
}

-(CPBitAntecedents*) getAntecedents:(CPBitAssignment*)assignment{
   return ([self getAntecedentsFor:assignment withState:_state]);
}
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment withState:(ORUInt**)state
{
 //NSLog(@"Implication for 0x%lx[%u] = %@  traced back through %@", (unsigned long)assignment->var, assignment->index, (CPBitVarI*)assignment->var, self);

   CPBitAntecedents* ants = malloc(sizeof(CPBitAntecedents));
   CPBitAssignment** vars;
   ants->numAntecedents = 0;

   ORUInt index = assignment->index;
   
   if (assignment->var == _x) {
      vars  = malloc(sizeof(CPBitAssignment*)*2);
      if (![_y isFree:index] || (~ISFREE(state[2][index/BITSPERWORD], state[3][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD)))) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _y;
         vars[ants->numAntecedents]->index = index;
         if(![_y isFree:index])
            vars[ants->numAntecedents]->value = [_y getBit:index];
         else
            vars[ants->numAntecedents]->value = !((ISTRUE(state[2][index/BITSPERWORD], state[3][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD))) == 0);
         ants->numAntecedents++;
      }
      if (![_z isFree:0] || (~ISFREE(state[4][0], state[5][0]) & 0x1)) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _z;
         vars[ants->numAntecedents]->index = 0;
         if(![_z isFree:0])
            vars[ants->numAntecedents]->value = [_z getBit:0];
         else
            vars[ants->numAntecedents]->value = !((ISTRUE(state[4][0], state[5][0]) & 0x1) == 0);
         ants->numAntecedents++;
      }
   }
   else if (assignment->var == _y){
      vars  = malloc(sizeof(CPBitAssignment*)*2);
      if (![_x isFree:index] || (~ISFREE(state[0][index/BITSPERWORD], state[1][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD)))) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _x;
         vars[ants->numAntecedents]->index = index;
         if(![_x isFree:index])
            vars[ants->numAntecedents]->value = [_x getBit:index];
         else
            vars[ants->numAntecedents]->value = !((ISTRUE(state[0][index/BITSPERWORD], state[1][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD))) == 0);
         ants->numAntecedents++;
      }
      if (![_z isFree:0] || (~ISFREE(state[4][0], state[5][0]) & 0x1)) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _z;
         vars[ants->numAntecedents]->index = 0;
         if(![_z isFree:0])
            vars[ants->numAntecedents]->value = [_z getBit:0];
         else
            vars[ants->numAntecedents]->value = !((ISTRUE(state[4][0], state[5][0]) & 0x1) == 0);
         ants->numAntecedents++;
      }
   }
   else if (assignment->var == _z){
     // ORBool zVal = [_z getBit:0];
      ORUInt bitLength = [_x bitLength];
      //If _x == _y was expected to be false, all bits contribute
      if (ISTRUE(state[4][0], state[5][0]) & 0x1) {
         vars  = malloc(sizeof(CPBitAssignment*)*bitLength*2);
         for(int i=0;i<bitLength;i++){
            vars[i] = malloc(sizeof(CPBitAssignment));
            vars[i]->var = _x;
            vars[i]->index = i;
            if(![_x isFree:i])
               vars[i]->value = [_x getBit:i];
            else
               vars[i]->value = !((ISTRUE(state[0][i/BITSPERWORD], state[1][i/BITSPERWORD]) & (0x1 << (i%BITSPERWORD))) == 0);
            vars[i+bitLength] = malloc(sizeof(CPBitAssignment));
            vars[i+bitLength]->var = _y;
            vars[i+bitLength]->index = i;
            if(![_y isFree:i])
               vars[i+bitLength]->value = [_y getBit:i];
            else
               vars[i+bitLength]->value = !((ISTRUE(state[2][i/BITSPERWORD], state[3][i/BITSPERWORD]) & (0x1 << (i%BITSPERWORD))) == 0);
         }
         ants->numAntecedents = bitLength*2;
      }
      else{
         //get index of least significant dissimilar bit
         vars  = malloc(sizeof(CPBitAssignment*)*2);
//         TRUInt *xLow, *yLow;
         ORUInt wordLength = [_x getWordLength];
         ORUInt xXORy;
//         xLow = [_x getLow];
//         yLow = [_y getLow];
         
         for (int i = 0; i<wordLength; i++) {
            xXORy = state[1][i] ^ state[3][i];
            if (xXORy != 0) {
               index = __builtin_ctz(xXORy) + (i * BITSPERWORD);
               break;
            }
         }
         vars[0] = malloc(sizeof(CPBitAssignment));
         vars[0]->var = _x;
         vars[0]->index = index;
         if(![_x isFree:index])
            vars[0]->value = [_x getBit:index];
         else
            vars[0]->value = !((ISTRUE(state[0][index/BITSPERWORD], state[1][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD))) == 0);
//         vars[0]->value = !((ISTRUE(state[0][index/BITSPERWORD], state[1][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD))) == 0);
         vars[1] = malloc(sizeof(CPBitAssignment));
         vars[1]->var = _y;
         vars[1]->index = index;
         if(![_y isFree:index])
            vars[1]->value = [_y getBit:index];
         else
            vars[1]->value = !((ISTRUE(state[2][index/BITSPERWORD], state[3][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD))) == 0);
         ants->numAntecedents=2;
      }
   }
   else{
      vars = NULL;
   }
   ants->antecedents = vars;
   return ants;
}

-(void) propagate
{
#ifdef BIT_DEBUG
   NSLog(@"**********************************");
   NSLog(@"Bit BitLogicalEqual Constraint propagated.");
#endif
   
   unsigned int wordLength = [_x getWordLength];
   unsigned int zWordLength = [_z getWordLength];
   
   TRUInt* xLow;
   TRUInt* xUp;
   TRUInt* yLow;
   TRUInt* yUp;
   TRUInt* zLow;
   TRUInt* zUp;
   
   unsigned int one[zWordLength];
   unsigned int zero[zWordLength];
   for (int i=1; i<zWordLength; i++) {
      one[i] = zero[i] = 0x00000000;
   }
   one[0] = 0x00000001;
   zero[0] = 0x00000000;
   
   unsigned int* newZUp = alloca(sizeof(unsigned int)*zWordLength);
   unsigned int* newZLow = alloca(sizeof(unsigned int)*zWordLength);
   
   unsigned int* newXUp = alloca(sizeof(unsigned int)*wordLength);
   unsigned int* newXLow = alloca(sizeof(unsigned int)*wordLength);
   unsigned int* newYUp = alloca(sizeof(unsigned int)*wordLength);
   unsigned int* newYLow = alloca(sizeof(unsigned int)*wordLength);
   unsigned int  upXORlow;
   
   [_x getUp:&xUp andLow:&xLow];
   [_y getUp:&yUp andLow:&yLow];
   [_z getUp:&zUp andLow:&zLow];
   
   for(int i=0;i<wordLength;i++){
      newXUp[i] = xUp[i]._val;
      newXLow[i] = xLow[i]._val;
      newYUp[i] = yUp[i]._val;
      newYLow[i] = yLow[i]._val;
   }
   
   unsigned int different = 0;
   unsigned int makesame = 0;
   for (int i=0; i<wordLength; i++) {
      different |= (xLow[i]._val & ~yUp[i]._val);// ^ xLow[i]._val;
      different |= (~xUp[i]._val & yLow[i]._val);// ^ ~xUp[i]._val;
   }
   
   for (int i=0; i<[_z getWordLength]; i++) {
      newZUp[i] = zUp[i]._val;
      newZLow[i] = zLow[i]._val;
      makesame |= zLow[i]._val;
   }
   
   if(makesame){
      for(int i=0;i<wordLength;i++){
         newXUp[i] = xUp[i]._val & yUp[i]._val;
         newYUp[i] = newXUp[i];
         newXLow[i] = xLow[i]._val | yLow[i]._val;
         newYLow[i] =  newXLow[i];
//         upXORlow = up[i] ^ low[i];
//         if(((upXORlow & (~up[i])) & (upXORlow & low[i])) != 0){
         _state[0] = newXUp;
         _state[1] = newXLow;
         _state[2] = newYUp;
         _state[3] = newYLow;
         _state[4] = newZUp;
         _state[5] = newZLow;
         

         ORBool xFail = checkDomainConsistency(_x, newXLow, newXUp, wordLength, self);
         if (xFail)
            failNow();
//         }
         [_x setUp:newXUp andLow:newXLow for:self];
         [_y setUp:newYUp andLow:newYLow for:self];
         
      }
      
   }
   
   if (different) {
      for (int i=0; i<zWordLength; i++) {
         newZUp[i] = zUp[i]._val & zero[i];
         newZLow[i] = zLow[i]._val | zero[i];
//         upXORlow = newZUp[i] ^ newZLow[i];
//         if(((upXORlow & (~newZUp[i])) & (upXORlow & newZLow[i])) != 0)
         _state[0] = newXUp;
         _state[1] = newXLow;
         _state[2] = newYUp;
         _state[3] = newYLow;
         _state[4] = newZUp;
         _state[5] = newZLow;

         ORBool zFail = checkDomainConsistency(_z, newZLow, newZUp, zWordLength, self);
         if (zFail)
            failNow();
         [_z setUp:newZUp andLow:newZLow for:self];
      }
   }
   else if ([_x bound] && [_y bound]){
      //LSB should be 1
      newZUp[0] = zUp[0]._val & one[0];
      newZLow[0] = zLow[0]._val | one[0];
      upXORlow = newZUp[0] ^ newZLow[0];
//      if(((upXORlow & (~newZUp[0])) & (upXORlow & newZLow[0])) != 0)
//         failNow();
      _state[0] = newXUp;
      _state[1] = newXLow;
      _state[2] = newYUp;
      _state[3] = newYLow;
      _state[4] = newZUp;
      _state[5] = newZLow;

      ORBool zFail = checkDomainConsistency(_z, newZLow, newZUp, zWordLength, self);
      if (zFail)
         failNow();
//      [_z setUp:newZUp andLow:newZLow for:self];
      
      //check the rest of the words in the bitvector if present
      for (int i=1; i<zWordLength; i++) {
         newZUp[i] = zUp[i]._val & zero[i];
         newZLow[i] = zLow[i]._val | zero[i];
//         upXORlow = newZUp[i] ^ newZLow[i];
//         if(((upXORlow & (~newZUp[i])) & (upXORlow & newZLow[i])) != 0)
//            failNow();
         _state[0] = newXUp;
         _state[1] = newXLow;
         _state[2] = newYUp;
         _state[3] = newYLow;
         _state[4] = newZUp;
         _state[5] = newZLow;

         ORBool zFail = checkDomainConsistency(_z, newZLow, newZUp, zWordLength, self);
         if (zFail)
            failNow();
      }
      [_z setUp:newZUp andLow:newZLow for:self];
   }
   
   _state[0] = newXUp;
   _state[1] = newXLow;
   _state[2] = newYUp;
   _state[3] = newYLow;
   _state[4] = newZUp;
   _state[5] = newZLow;

   ORBool xFail = checkDomainConsistency(_x, newXLow, newXUp, wordLength, self);
   ORBool yFail = checkDomainConsistency(_y, newYLow, newYUp, wordLength, self);
   ORBool zFail = checkDomainConsistency(_z, newZLow, newZUp, zWordLength, self);

   if(xFail || yFail || zFail){
      failNow();
   }
   [_x setUp:newXUp andLow:newXLow for:self];
   [_y setUp:newYUp andLow:newYLow for:self];
   [_z setUp:newZUp andLow:newZLow for:self];
   

   return;
}
@end

@implementation CPBitLogicalAnd

-(id) initCPBitLogicalAnd:(id<CPBitVarArray>) x eval:(CPBitVarI *)r
{
   self = [super initCPBitCoreConstraint: [x[0] engine]];
   _x = x;
   _r = r;
   _state = malloc(sizeof(ORUInt*)*([_x count]+1)*2);
   return self;
}
-(NSString*) description
{
   NSMutableString* string = [NSMutableString stringWithString:[super description]];
   [string appendString:@" with "];
   [string appendString:[NSString stringWithFormat:@"%@ ",_x]];
   [string appendString:[NSString stringWithFormat:@", and %@\n",_r]];
   return string;
}

-(CPBitAntecedents*) getAntecedents:(CPBitAssignment*)assignment{
   return ([self getAntecedentsFor:assignment withState:_state]);
}
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment withState:(ORUInt**)state
{
  //NSLog(@"Implication for 0x%lx[%u] = %@  traced back through %@", (unsigned long)assignment->var, assignment->index, (CPBitVarI*)assignment->var, self);
   
   CPBitAntecedents* ants = malloc(sizeof(CPBitAntecedents));
   CPBitAssignment** vars;
   ORULong numOperands = [_x count];
   vars = malloc(sizeof(CPBitAssignment*)*(numOperands+1));
   ants->numAntecedents = 0;

   ORULong rIndex = numOperands >> 1;

   if ((assignment->var == _r) && ([_r bound])) {
      //      vars = malloc(sizeof(CPBitAssignment*)*[_x count]);
      NSLog(@"%@", bitvar2NSString(state[rIndex+1], state[rIndex], 1));
      if (ISTRUE(state[rIndex][0], state[rIndex+1][0])) {
         for (int i = 0;i<numOperands;i++){
            if (![[_x at:i] isFree:0] || (~ISFREE(state[i*2][0], state[i*2+1][0]) & 0x1)) {
               vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
               vars[ants->numAntecedents]->var = (CPBitVarI*)[_x at:i];
               vars[ants->numAntecedents]->index = 0;
               if(![(CPBitVarI*)[_x at:i] isFree:0])
                  vars[ants->numAntecedents]->value = [(CPBitVarI*)[_x at:i] getBit:0];
               else
                  vars[ants->numAntecedents]->value = !((ISTRUE(state[i*2][0], state[i*2+1][0]) & 0x1) == 0);
               ants->numAntecedents++;
            }
         }
      }
      else {
         for (int i = 0;i<numOperands;i++){
            if (![[_x at:i] isFree:0] || (~ISFREE(state[i*2][0], state[i*2+1][0]) & 0x1)) {
               vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
               vars[ants->numAntecedents]->var = (CPBitVarI*)[_x at:i];
               vars[ants->numAntecedents]->index = 0;
               vars[ants->numAntecedents]->value = false;
               ants->numAntecedents++;
            }
         }
      }
   }
   else {
//      if([_r bound] && [_r getBit:0]){
      NSLog(@"%@", bitvar2NSString(state[rIndex+1], state[rIndex], 1));
      if (ISTRUE(state[rIndex][0], state[rIndex+1][0]) & 0x1){
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _r;
         vars[ants->numAntecedents]->index = 0;
         if(![_r isFree:0])
            vars[ants->numAntecedents]->value = [_r getBit:0];
         else
            vars[ants->numAntecedents]->value = !(((ISTRUE(state[rIndex][0], state[rIndex+1][0]) & 0x1)) == 0);
         ants->numAntecedents++;
      }
   else if (ISFALSE(state[rIndex][0], state[rIndex+1][0]) & 0x1){
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _r;
         vars[ants->numAntecedents]->index = 0;
         if(![_r isFree:0])
            vars[ants->numAntecedents]->value = [_r getBit:0];
         else
            vars[ants->numAntecedents]->value = !(((ISTRUE(state[rIndex][0], state[rIndex+1][0]) & 0x1)) == 0);
         ants->numAntecedents++;
         for (int i = 0;i<numOperands;i++){
            if (([_x at:i] != assignment->var) && ISFALSE(state[i*2][0], state[i*2+1][0]) & 0x1){
               vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
               vars[ants->numAntecedents]->var = (id) [_x at:i];
               vars[ants->numAntecedents]->index = 0;
               if(![(CPBitVarI*)[_x at:i] isFree:0])
                  vars[ants->numAntecedents]->value = [(CPBitVarI*)[_x at:i] getBit:0];
               else
                  vars[ants->numAntecedents]->value = !((ISTRUE(state[i*2][0], state[i*2+1][0]) & 0x1) == 0);
//               vars[ants->numAntecedents]->value = !(((ISTRUE(state[i*2][0], state[i*2+1][0]) & 0x1)) == 0);
               ants->numAntecedents++;
            }
            else
               NSLog(@"Stop Here");
         }
      }
      
   }
   
   ants->antecedents = vars;
   
   if(ants->numAntecedents == 0)
      NSLog(@"No antecedents in bit logical and constraint");
   
   return ants;
}
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment
{
  //NSLog(@"Implication for 0x%lx[%u] = %@  traced back through %@", (unsigned long)assignment->var, assignment->index, (CPBitVarI*)assignment->var, self);

   CPBitAntecedents* ants = malloc(sizeof(CPBitAntecedents));
   CPBitAssignment** vars;
   vars = malloc(sizeof(CPBitAssignment*)*([_x count]+1));
   ants->numAntecedents = 0;
   
   if ((assignment->var == _r) && ([_r bound])) {
//      vars = malloc(sizeof(CPBitAssignment*)*[_x count]);
      if ([_r getBit:0]) {
         for (id var in _x){
            if (![var isFree:0]) {
               vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
               vars[ants->numAntecedents]->var = var;
               vars[ants->numAntecedents]->index = 0;
               vars[ants->numAntecedents]->value = [var getBit:0];
               ants->numAntecedents++;

            }
         }
      }
      else {
         for (id var in _x){
            if (![var isFree:0]) {
               vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
               vars[ants->numAntecedents]->var = var;
               vars[ants->numAntecedents]->index = 0;
               vars[ants->numAntecedents]->value = false;
               ants->numAntecedents++;
            }
         }
      }
   }
   else {
      if([_r bound] && [_r getBit:0]){
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _r;
         vars[ants->numAntecedents]->index = 0;
         vars[ants->numAntecedents]->value = [_r getBit:0];
         ants->numAntecedents++;
      }
      else if ([_r bound]){
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _r;
         vars[ants->numAntecedents]->index = 0;
         vars[ants->numAntecedents]->value = [_r getBit:0];
         ants->numAntecedents++;
         for (id var in _x){
            if ((var != assignment->var) && (![var getBit:0])) {
               vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
               vars[ants->numAntecedents]->var = var;
               vars[ants->numAntecedents]->index = 0;
               vars[ants->numAntecedents]->value = [var getBit:0];
               ants->numAntecedents++;
            }
         }
      }
   
   }

   ants->antecedents = vars;
   
      if(ants->numAntecedents == 0)
         NSLog(@"No antecedents in bit logical and constraint");

//   if(assignment->var==_r)
//      NSLog(@"Assignment in _r variable");
//   if(ants->antecedents[0]->var != _r)
//      NSLog(@"_r is not the antecedent");

   return ants;
}

- (void) dealloc
{
   [super dealloc];
   free(_state);
}

-(void) post
{
[self propagate];
   for (int i=[_x low]; i<=[_x up]; i++) {
      if (![_x[i] bound])
         [(CPBitVarI*)[_x at:i] whenChangePropagate: self];
   }
   if (![_r bound]) {
      [_r whenChangePropagate: self];
   }
[self propagate];
//   return ORSuspend;
}

-(void) propagate
{
#ifdef BIT_DEBUG
   NSLog(@"Bit Logical AND Constraint propagated.");
#endif
//   //TODO: If r is bound, should we check if only one bit in all of the x[i]
//   //are free and need to be set up or low?
//   TRUInt* xLow;
//   TRUInt* xUp;
//   TRUInt* rLow;
//   TRUInt* rUp;
//   unsigned int* rup = alloca(sizeof(unsigned int)* [_r getWordLength]);
//   unsigned int* rlow = alloca(sizeof(unsigned int)* [_r getWordLength]);
//   
//   [_r getUp:&rUp andLow:&rLow];
//   
//   ORUInt fullbv;
//   ORUInt unboundExists = false;
//   
//   
//   //TODO: Check for failures
//   for (int i=[_x low]; i<=[_x up]; i++) {
//      [(CPBitVarI*)_x[i] getUp:&xUp andLow:&xLow];
//      
//      if (![_x[i] bound])
//         unboundExists = true;
//      
//      fullbv = 0;
//      for (int j=0; j<[(CPBitVarI*)_x[j] getWordLength]; j++)
//         fullbv |= xUp[j]._val;
//      
//      if (!fullbv) {
//         for (int k=0; k<[_r getWordLength]; k++)
//            rup[k] = rlow[k] = 0;
//         [_r setUp:rup andLow:rlow for:self];
//         return;
//      }
//   }
//   if (!unboundExists) {
//      for (int k=1; k<[_r getWordLength]; k++)
//         rup[k] = rlow[k] = 0;
//      rup[0] = rlow[0] = 1;
//      [_r setUp:rup andLow:rlow for:self];
//      return;
//   }
//   return;

   TRUInt* xLow;
   TRUInt* xUp;
   TRUInt* rLow;
   TRUInt* rUp;
   ORInt rLength = [_r getWordLength];
   
   ORUInt newXUp;
   ORUInt newXLow;
   ORUInt xLength;
   
   ORUInt fail;

   unsigned int* rup = alloca(sizeof(unsigned int)* rLength);
   unsigned int* rlow = alloca(sizeof(unsigned int)* rLength);
   
   [_r getUp:&rUp andLow:&rLow];
   
   
   
//   NSLog(@"*******************************************");
//   NSLog(@"x0 && x1 ...  ? r");
////   for (int i=0; i<[_x count]; i++) {
////      NSLog(@"x[%u] = %@",i,[_x at:i]);
////   }
////   NSLog(@"x=%@\n",_x);
////   NSLog(@"r=%@\n\n",_r);
//   NSLog(@"%@, %@",_x,_r);
//
//   
//   if(((![(CPBitVarI*)_x[0] bound])) &&
//      (([(CPBitVarI*)_x[1] bound]) && ([(CPBitVarI*)_x[1] getBit:0]!=0)) &&
//      (([(CPBitVarI*)_r bound]) && ([(CPBitVarI*)_r getBit:0]==0))){
//      NSLog(@"Stop");
//   }
   
   ORUInt rTrue = 0;
   for (int i=0;i<rLength;i++){
      rup[i] = rUp[i]._val;
      rlow[i] = rLow[i]._val;
      rTrue |= rlow[i];
   }
   
   if (rTrue) {
      for (int i=[_x low]; i<=[_x up]; i++) {
         [(CPBitVarI*)[_x at:i] getUp:&xUp andLow:&xLow];
         newXLow = xLow->_val | 0x1;
         newXUp = xUp->_val;
         fail = checkDomainConsistency((CPBitVarI*)[_x at:i], &newXLow, &newXUp, [(CPBitVarI*)[_x at:i] getWordLength], self);
         if (fail) {
            failNow();
         }
         [(CPBitVarI*)[_x at:i] setUp:&newXUp andLow:&newXLow for:self];
      }
//      return;
   }
   
   ORUInt fullbv;
   ORUInt numUnboundVars = 0;
   CPBitVarI* lastUnboundVar;
   
   ORUInt allFalse = 0;
   ORUInt allTrue = 1;
   for (int i=[_x low]; i<=[_x up]; i++) {
      [(CPBitVarI*)_x[i] getUp:&xUp andLow:&xLow];
      xLength = [(CPBitVarI*)_x[i] getWordLength];
      for (int j=0; j<xLength; j++) {
         allFalse |= xUp->_val;
         if (!(xUp[i]._val ^ xLow[i]._val)) {
            allTrue &= xUp[0]._val;
         }
      }
      if (![_x[i] bound]){
         numUnboundVars++;
         lastUnboundVar = (CPBitVarI*)_x[i];
         continue;
      }
      fullbv = 0;
      for (int j=0; j<[(CPBitVarI*)_x[i] getWordLength]; j++)
         fullbv |= xUp[j]._val;
      
      //fullbv shows if any bit is set up, or can be set up later, in _x[j]
      if (fullbv==0) {
         ORInt rLength = [_r getWordLength];
         for (int k=0; k<rLength; k++)
            rup[k] = 0x0;
         ORBool rFail = checkDomainConsistency(_r, rlow, rup, rLength, self);
         if (rFail) {
            failNow();
         }
//         else{
//            [_r setUp:rup andLow:rlow for:self];
//         }
//         return;
      }
   }
//   if (numUnboundVars == 0) {
//      ORInt rLength = [_r getWordLength];
//      //if all _x variables are bound and all have at least one bit set up (since we got here)
//      //must ensure at least one bit is set in _r
//      
//      
//      //can only set _r to 1 if ALL _x vars are bound to 1
//      if ([_r domsize] == 1) {
//         rlow[0] = 0x1;
//      }
//      ORBool rFail = checkDomainConsistency(_r, rlow, rup, rLength, self);
//      if (rFail) {
//         failNow();
//      }
////      else{
////         [_r setUp:rup andLow:rlow for:self];
////      }
////      return;
//   }
   if((numUnboundVars==1) && ([lastUnboundVar domsize]==2)){
      fullbv=0;
      [(CPBitVarI*)lastUnboundVar getUp:&xUp andLow:&xLow];
      unsigned int* xup = alloca(sizeof(unsigned int)* [lastUnboundVar getWordLength]);
      unsigned int* xlow = alloca(sizeof(unsigned int)* [lastUnboundVar getWordLength]);
      ORInt rLength = [_r getWordLength];
      for (int k=0; k<rLength; k++)
         fullbv |= rlow[k];
      ORInt bitIndex = [lastUnboundVar lsFreeBit];
      ORUInt mask = 0x1 << bitIndex % BITSPERWORD;
      ORInt xLength =[(CPBitVarI*)lastUnboundVar getWordLength];
      for (int x=0;x<xLength;x++){
         xup[x] = xUp[x]._val;
         xlow[x] = xLow[x]._val;
      }
      
      if ([_r bound] && (rlow[0] > 0)){
         if (fullbv == 0)
            xup[bitIndex/WORDLENGTH] |= mask;
         else
            xlow[bitIndex/WORDLENGTH] &= ~mask;
         
         ORBool xFail = checkDomainConsistency((CPBitVarI*)lastUnboundVar, xlow, xup, xLength, self);
         if (xFail) {
            failNow();
         }
         [(CPBitVarI*)lastUnboundVar setUp:xup andLow:xlow for:self];

      }
      else if ((rup[0] == 0) && allTrue){
         xup[0] = 0;
         ORBool xFail = checkDomainConsistency((CPBitVarI*)lastUnboundVar, xlow, xup, xLength, self);
         if (xFail) {
            failNow();
         }
         [(CPBitVarI*)lastUnboundVar setUp:xup andLow:xlow for:self];
         
      }
      
   }
   
   if ((allTrue) && (numUnboundVars == 0)) {
      //bug here with _x = [0,1] and _r = 0, done
      rlow[0] = 1;
   }

   
   ORBool rFail = checkDomainConsistency(_r, rlow, rup, rLength, self);
   if (rFail) {
      failNow();
   }
   [_r setUp:rup andLow:rlow for:self];

   
//   NSLog(@"%@, %@",_x,_r);
   
   
   
   if([_r bound] && [_r getBit:0]){
      for(int i=[_x low]; i<=[_x up];i++)
      {
         if([_x[i] bound] && ![_x[i] bitAt:0])    // [LDM] this was calling getBit: (which does not exist.) I guess this was meant to be "bitAt:"
            NSLog(@"x variable false in LogicalAND");
      }
   }
   
//   if((([(CPBitVarI*)_x[0] bound]) && ([(CPBitVarI*)_x[0] getBit:0]!=0)) &&
//      (([(CPBitVarI*)_x[1] bound]) && ([(CPBitVarI*)_x[1] getBit:0]!=0)) &&
//      (([(CPBitVarI*)_r bound]) && ([(CPBitVarI*)_r getBit:0]==0))){
//      NSLog(@"Stop");
//   }
//

   return;
}
@end

@implementation CPBitLogicalOr

-(id) initCPBitLogicalOr:(id<CPBitVarArray>) x eval:(CPBitVarI *)r
{
   self = [super initCPBitCoreConstraint: [x[0] engine]];
   _x = x;
   _r = r;
   _state = malloc(sizeof(ORUInt*)*([_x count]+1)*2);
   return self;
}
-(NSString*) description
{
   NSMutableString* string = [NSMutableString stringWithString:[super description]];
   [string appendString:@" with "];
   [string appendString:[NSString stringWithFormat:@"%@, ",_x]];
   [string appendString:[NSString stringWithFormat:@"and %@\n",_r]];
   
   return string;
}

-(CPBitAntecedents*) getAntecedents
{
   return NULL;
}

-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment withState:(ORUInt**)state
{
   return NULL;
}

-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment
{
  //NSLog(@"Implication for 0x%lx[%u] = %@  traced back through %@", (unsigned long)assignment->var, assignment->index, (CPBitVarI*)assignment->var, self);

   return NULL;
}

- (CPBitAntecedents *)getAntecedents:(CPBitAssignment *)assignment {
   return NULL;
}


- (void) dealloc
{
   [super dealloc];
   free(_state);
}

-(void) post
{
   [self propagate];
   for (int i=[_x low]; i<=[_x up]; i++) {
      if (![_x[i] bound])
         [(CPBitVarI*)_x[i] whenChangePropagate: self];
   }
   if (![_r bound]) {
      [_r whenChangePropagate: self];
   }
   [self propagate];
   //   return ORSuspend;
}

-(void) propagate
{
#ifdef BIT_DEBUG
   NSLog(@"Bit Logical OR Constraint propagated.");
#endif
   //TODO: If r is bound, should we check if only one bit in all of the x[i]
   //are free and need to be set up or low?
   
   TRUInt* xLow;
   TRUInt* xUp;
   TRUInt* rLow;
   TRUInt* rUp;
   ORInt rLength = [_r getWordLength];
   
   unsigned int* rup = alloca(sizeof(unsigned int)* rLength);
   unsigned int* rlow = alloca(sizeof(unsigned int)* rLength);
   
   [_r getUp:&rUp andLow:&rLow];
   
   for (int i=0;i<rLength;i++){
      rup[i] = rUp[i]._val;
      rlow[i] = rLow[i]._val;
   }
   
   
   ORUInt fullbv;
   ORUInt numUnboundVars = 0;
   id<CPBitVar> lastUnboundVar;
   ORUInt from = [_x low];
   ORUInt to = [_x up];
   
   //TODO: Check for failures
   for (int i=from; i<=to; i++) {
      [(CPBitVarI*)_x[i] getUp:&xUp andLow:&xLow];
      
      if (![_x[i] bound]){
         numUnboundVars++;
         lastUnboundVar = _x[i];
      }
      fullbv = 0;
      for (int j=0; j<[(CPBitVarI*)_x[j] getWordLength]; j++)
         fullbv |= xLow[j]._val;
      
      if (fullbv) {
         ORInt rLength = [_r getWordLength];
         for (int k=0; k<rLength; k++)
            rlow[k] = 0x00000001;
         ORBool rFail = checkDomainConsistency(_r, rlow, rup, rLength, self);
         if (rFail) {
            failNow();
         }
         [_r setUp:rup andLow:rlow for:self];
         return;
      }
   }
   if (numUnboundVars == 0) {
      ORInt rLength = [_r getWordLength];
      for (int k=0; k<rLength; k++)
         rup[k] = 0;
      ORBool rFail = checkDomainConsistency(_r, rlow, rup, rLength, self);
      if (rFail) {
         failNow();
      }
      [_r setUp:rup andLow:rlow for:self];
      return;
   }
   if((numUnboundVars==1) && ([lastUnboundVar domsize]==2)){
      fullbv=0;
      [(CPBitVarI*)lastUnboundVar getUp:&xUp andLow:&xLow];
      unsigned int* xup = alloca(sizeof(unsigned int)* [_r getWordLength]);
      unsigned int* xlow = alloca(sizeof(unsigned int)* [_r getWordLength]);
      ORInt rLength = [_r getWordLength];
      for (int k=0; k<rLength; k++)
         fullbv |= rlow[k];
      ORInt bitIndex = [lastUnboundVar lsFreeBit];
      ORUInt mask = 0x1 << bitIndex % WORDLENGTH;
      ORInt xLength =[(CPBitVarI*)lastUnboundVar getWordLength];
      for (int x=0;x<xLength;x++){
         xup[x] = xUp[x]._val;
         xlow[x] = xLow[x]._val;
      }
      
      if ([_r bound]){
         if (fullbv == 0)
            xup[bitIndex/WORDLENGTH] &= mask;
         else
            xlow[bitIndex/WORDLENGTH] |= mask;
         
         ORBool xFail = checkDomainConsistency((CPBitVarI*)lastUnboundVar, xlow, xup, xLength, self);
         if (xFail) {
            failNow();
         }
         [(CPBitVarI*)lastUnboundVar setUp:xup andLow:xlow for:self];
         
      }
   }
   return;
}
- (void)visit:(ORVisitor *)visitor {
}

- (void)close {
}

@end

@implementation CPBitConflict
-(id) initCPBitConflict:(CPBitAntecedents*)a
{
   self = [super initCPBitCoreConstraint: [a->antecedents[0]->var engine]];
   _assignments = a;
   _state = malloc(sizeof(ORUInt*)*(_assignments->numAntecedents)*2);
   return self;
}

- (void) dealloc
{
//   free (_conflictValues);
   [super dealloc];
   free(_state);
}

-(void) post
{
   [self propagate];
   for (int i = 0; i<_assignments->numAntecedents; i++) {
//      if (![(CPBitVarI*)_assignments->antecedents[i]->var bound])
         [(CPBitVarI*)_assignments->antecedents[i]->var whenChangePropagate: self];
   }
   [self propagate];

}
-(NSString*) description{
   NSMutableString* string = [NSMutableString stringWithString:[super description]];
   [string appendString:@" with "];

   for (int i = 0; i<_assignments->numAntecedents; i++) {
      [string appendString:[NSString stringWithFormat:@"%@[%d]=%d, ",_assignments->antecedents[i]->var, _assignments->antecedents[i]->index, _assignments->antecedents[i]->value]];
   }
   return string;
}
-(NSSet*) allVars
{
   ORULong numVars =_assignments->numAntecedents;
   id<CPBitVar>* vars = alloca(sizeof(CPBitVarI*)*numVars);
   for(int i=0;i<numVars;i++)
      vars[i] = _assignments->antecedents[i]->var;
   return [[[NSSet alloc] initWithObjects:vars count:numVars] autorelease];
}
-(CPBitAntecedents*)getAssignments
{
   return _assignments;
}
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment
{
 //NSLog(@"Implication for 0x%lx[%u] = %@  traced back through %@", (unsigned long)assignment->var, assignment->index, (CPBitVarI*)assignment->var, self);

//   NSLog(@"Tracing back antecedents for CPBitConflict with:");
//   for (int i = 0; i<_assignments->numAntecedents; i++) {
//      NSLog(@"0x%lx",_assignments->antecedents[i]->var);
//   }
   CPBitAntecedents* ants = malloc(sizeof(CPBitAntecedents));
   CPBitAssignment** vars = malloc(sizeof(CPBitAssignment*)*(_assignments->numAntecedents-1));
   ants->numAntecedents = 0;

   ants->antecedents = vars;
   
   for (int i = 0; i<_assignments->numAntecedents; i++) {
//      if (((_assignments->antecedents[i]->var == assignment->var) && (_assignments->antecedents[i]->index == assignment->index))|| [_assignments->antecedents[i]->var isFree:_assignments->antecedents[i]->index]){
      if ((_assignments->antecedents[i]->var == assignment->var) && (_assignments->antecedents[i]->index == assignment->index)){
         continue;
      }
      
//      if (((l=[_assignments->antecedents[i]->var getLevelBitWasSet:_assignments->antecedents[i]->index]) <= level) || (l==-1)){
      ants->antecedents[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
      ants->antecedents[ants->numAntecedents]->var = _assignments->antecedents[i]->var;
//      ants->antecedents[ants->numAntecedents]->value = [_assignments->antecedents[i]->var getBit:_assignments->antecedents[i]->index];
      ants->antecedents[ants->numAntecedents]->value = _assignments->antecedents[i]->value;
      ants->antecedents[ants->numAntecedents]->index = _assignments->antecedents[i]->index;

         ants->numAntecedents++;
//      }
   }
//   NSLog(@"%d variables, %d antecedents", _assignments->numAntecedents, ants->numAntecedents);
   return ants;
}
-(CPBitAntecedents*) getAntecedents:(CPBitAssignment*)assignment{
//   return ([self getAntecedentsFor:assignment withState:_state]);
   return ([self getAntecedentsFor:assignment]);
}
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment withState:(ORUInt**)state
{
  //NSLog(@"Implication for 0x%lx[%u] = %@  traced back through %@", (unsigned long)assignment->var, assignment->index, (CPBitVarI*)assignment->var, self);
   
   //   NSLog(@"Tracing back antecedents for CPBitConflict with:");
   //   for (int i = 0; i<_assignments->numAntecedents; i++) {
   //      NSLog(@"0x%lx",_assignments->antecedents[i]->var);
   //   }
   CPBitAntecedents* ants = malloc(sizeof(CPBitAntecedents));
   CPBitAssignment** vars = malloc(sizeof(CPBitAssignment*)*(_assignments->numAntecedents-1));
   ants->numAntecedents = 0;
   
   ants->antecedents = vars;
   
   for (int i = 0; i<_assignments->numAntecedents; i++) {
//      if (((_assignments->antecedents[i]->var == assignment->var) && (_assignments->antecedents[i]->index == assignment->index)) || !(~ISFREE(state[i*2][(_assignments->antecedents[i]->index)/BITSPERWORD], state[i*2+1][(_assignments->antecedents[i]->index)/BITSPERWORD])) & (0x1 << ((_assignments->antecedents[i]->index)%BITSPERWORD))){
      if ((_assignments->antecedents[i]->var == assignment->var) && (_assignments->antecedents[i]->index == assignment->index)){
          continue;
      }
      
      //      if (((l=[_assignments->antecedents[i]->var getLevelBitWasSet:_assignments->antecedents[i]->index]) <= level) || (l==-1)){
      ants->antecedents[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
      ants->antecedents[ants->numAntecedents]->var = _assignments->antecedents[i]->var;
      if(![_assignments->antecedents[i]->var isFree:_assignments->antecedents[i]->index])
         vars[ants->numAntecedents]->value = [_assignments->antecedents[i]->var getBit:_assignments->antecedents[i]->index];
      else
         ants->antecedents[ants->numAntecedents]->value = !((ISTRUE(state[i*2][i/BITSPERWORD], state[i*2+1][i/BITSPERWORD]) & (0x1 << (i%BITSPERWORD))) == 0);
      ants->antecedents[ants->numAntecedents]->index = _assignments->antecedents[i]->index;
      
      ants->numAntecedents++;
      //      }
   }
//   NSLog(@"%d variables, %d antecedents", _assignments->numAntecedents, ants->numAntecedents);
   return ants;
}
-(void) propagate
{
   ORULong numVars = _assignments->numAntecedents;
   CPBitArrayDom** domains;
   ORInt* currentVals;
   ORBool conflict = true;
   ORInt numFree = 0;
//   ORBool mismatch= false;
   
   
   //   conflict = 0x1 << (_bit % 32);
   domains = alloca(sizeof(CPBitArrayDom*)*numVars);
   currentVals = alloca(sizeof(ORUInt)*numVars);
   for (int i=0; i<numVars; i++) {
      domains[i] = [_assignments->antecedents[i]->var domain];
      if ([domains[i] isFree:_assignments->antecedents[i]->index]) {
         currentVals[i] = -1;
         numFree++;
         conflict = false;
      }
      else{
         currentVals[i] = [domains[i] getBit:_assignments->antecedents[i]->index];
         if (_assignments->antecedents[i]->value != currentVals[i])
            return;
      }
   }
   
   if (numFree == 0){
      for (int i = 0; i<numVars; i++) {
         if (currentVals[i] != _assignments->antecedents[i]->value) {
            conflict = false;
            break;
         }
      }
      if (conflict) {
         ORUInt idx;
         ORBool val;
         ORUInt maxLevel = 5;
         ORUInt currLevel = [(CPLearningEngineI*)[_assignments->antecedents[0]->var engine] getLevel];
         CPBitVarI* var = nil;
         for(int i=0;i<numVars;i++){
            ORUInt setLevel = [_assignments->antecedents[i]->var getLevelBitWasSet:_assignments->antecedents[i]->index];
//            if ((setLevel != -1) && (setLevel >= maxLevel) && (setLevel > 4) && (setLevel <= currLevel)){
            if ((setLevel != -1) && (setLevel >= maxLevel)&& (setLevel <= currLevel)){
               maxLevel = setLevel;
//               currLevel = setLevel;
               var =_assignments->antecedents[i]->var;
               idx =_assignments->antecedents[i]->index;
               val=_assignments->antecedents[i]->value;
            }
         }
         
         if (var == nil)
            failNow();
         
         
//         var =_assignments->antecedents[0]->var;
//         idx =_assignments->antecedents[0]->index;
//         val=_assignments->antecedents[0]->value;
         
         TRUInt* up;
         TRUInt* low;
         
         [var getUp:&up andLow:&low];
         ORUInt wordLength =[var getWordLength];
         ORUInt* newUp = alloca(sizeof(ORUInt)*wordLength);
         ORUInt* newLow = alloca(sizeof(ORUInt)*wordLength);
         for(int j=0;j<wordLength;j++)
         {
            newUp[j] = up[j]._val;
            newLow[j] = low[j]._val;
         }
         ORUInt mask = 1 <<idx%BITSPERWORD;
         
         if(val){
            newUp[idx/BITSPERWORD] ^= mask;
         }
         else{
            newLow[idx/BITSPERWORD] ^= mask;
         }
         _state = alloca(sizeof(ORUInt*)*numVars*2);
         for(int j=0;j<numVars;j++)
         {
            if (_assignments->antecedents[j]->var == var)
            {
               _state[j*2] = newUp;
               _state[j*2+1] = newLow;
            }
            else
            {
               _state[j*2] = alloca(sizeof(ORUInt)*(wordLength));
               _state[j*2+1] = alloca(sizeof(ORUInt)*(wordLength));
               [_assignments->antecedents[j]->var getUp:&up andLow:&low];
               for (int k=0; k<wordLength; k++) {
                  _state[j*2][k] = up[k]._val;
                  _state[j*2+1][k] = low[k]._val;
               }
            }
         }
         if(checkDomainConsistency(var, newLow, newUp, [var bitLength], self))
            failNow();
         
      }
   }
   
   if (numFree == 1) {
      for (int i = 0; i<numVars; i++) {
         if (currentVals[i] == -1) {
            ORUInt wordLength = [_assignments->antecedents[i]->var getWordLength];
            TRUInt* vup;
            TRUInt* vlow;
            ORUInt* up = alloca(sizeof(ORUInt)*wordLength);
            ORUInt* low = alloca(sizeof(ORUInt)*wordLength);
            [domains[i] getUp:&vup andLow:&vlow];
            for (int j=0; j<wordLength; j++) {
               up[j] = vup[j]._val;
               low[j] = vlow[j]._val;
            }
            ORUInt mask;
            mask = 0x1 << (_assignments->antecedents[i]->index % 32);
            if (_assignments->antecedents[i]->value) {
               //set only free bit to zero
               up[_assignments->antecedents[i]->index/32] &= ~mask;
            }
            else{
               //set only free bit to one
               low[_assignments->antecedents[i]->index/32] |= mask;
            }
            _state = alloca(sizeof(ORUInt*)*numVars*2);
            for(int j=0;j<numVars;j++)
            {
               if (j==i)
               {
                  _state[j*2] = up;
                  _state[j*2+1] = low;
               }
               else
               {
                  _state[j*2] = alloca(sizeof(ORUInt)*(wordLength));
                  _state[j*2+1] = alloca(sizeof(ORUInt)*(wordLength));
                  [domains[j] getUp:&vup andLow:&vlow];
                  for (int k=0; k<wordLength; k++) {
                     _state[j*2][k] = vup[k]._val;
                     _state[j*2+1][k] = vlow[k]._val;
                  }
               }
            }
            if (checkDomainConsistency(_assignments->antecedents[i]->var, low, up, wordLength, self)) {
               failNow();
            }
            [_assignments->antecedents[i]->var setUp:up andLow:low for:self];
            return;
         }
      }
   }
}
@end


@implementation CPBitORb

-(id) initCPBitORb:(CPBitVarI*)x bor:(CPBitVarI*)y eval:(CPBitVarI*)r
{
   self = [super initCPBitCoreConstraint:[x engine]];
   _x = x;
   _y = y;
   _r = r;
   _state = malloc(sizeof(ORUInt*)*6);
   return self;
}
-(NSString*) description
{
   NSMutableString* string = [NSMutableString stringWithString:[super description]];
   [string appendString:@" with "];
   [string appendString:[NSString stringWithFormat:@"%@, ",_x]];
   [string appendString:[NSString stringWithFormat:@"%@, ",_y]];
   [string appendString:[NSString stringWithFormat:@"and %@\n",_r]];
   
   return string;
}

- (void) dealloc
{
   [super dealloc];
   free(_state);
}

-(void) post
{
   [self propagate];
   if (![_x bound])
      [_x whenChangePropagate: self];
   if (![_y bound])
      [_y whenChangePropagate: self];
   if (![_r bound])
      [_r whenChangePropagate: self];
   [self propagate];
}
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment
{
  //NSLog(@"Implication for 0x%lx[%u] = %@  traced back through %@", (unsigned long)assignment->var, assignment->index, (CPBitVarI*)assignment->var, self);

   CPBitAntecedents* ants = malloc(sizeof(CPBitAntecedents));
   CPBitAssignment** vars;
   vars  = malloc(sizeof(CPBitAssignment*)*2);
   ants->numAntecedents = 0;
   
   ORUInt index = assignment->index;
   ants->antecedents = vars;
   
   if (index !=0) {
      assert(0);
   }
   
   if (assignment->var == _x) {
      if (![_y isFree:index]) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _y;
         vars[ants->numAntecedents]->index = index;
         vars[ants->numAntecedents]->value = [_y getBit:index];
         ants->numAntecedents++;
      }
      if (![_r isFree:index]) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _r;
         vars[ants->numAntecedents]->index = index;
         vars[ants->numAntecedents]->value = [_r getBit:index];
         ants->numAntecedents++;
      }
   }
   else if (assignment->var == _y){
      if (![_x isFree:index]) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _x;
         vars[ants->numAntecedents]->index = index;
         vars[ants->numAntecedents]->value = [_x getBit:index];
         ants->numAntecedents++;
      }
      if (![_r isFree:index]) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _r;
         vars[ants->numAntecedents]->index = index;
         vars[ants->numAntecedents]->value = [_r getBit:index];
         ants->numAntecedents++;
      }
   }
   else if (assignment->var == _r){
      if (![_x isFree:index]) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _x;
         vars[ants->numAntecedents]->index = index;
         vars[ants->numAntecedents]->value = [_x getBit:index];
         ants->numAntecedents++;
      }
      if (![_y isFree:index]) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _y;
         vars[ants->numAntecedents]->index = index;
         vars[ants->numAntecedents]->value = [_y getBit:index];
         ants->numAntecedents++;
      }
   }
   return ants;
}

- (CPBitAntecedents *)getAntecedents:(CPBitAssignment *)assignment {
   return NULL;
}


-(void) propagate
{
#ifdef BIT_DEBUG
   NSLog(@"Bit Boolean OR Constraint propagated.");
#endif
   
   TRUInt* xLow;
   TRUInt* xUp;
   TRUInt* yLow;
   TRUInt* yUp;
   TRUInt* rLow;
   TRUInt* rUp;
   
   unsigned int newXUp, newXLow;
   unsigned int newYUp, newYLow;
   unsigned int newRUp, newRLow;
   
   [_x getUp:&xUp andLow:&xLow];
   [_y getUp:&yUp andLow:&yLow];
   [_r getUp:&rUp andLow:&rLow];
   
   newXUp = xUp->_val & ((yUp->_val & rUp->_val) | (~yLow->_val & rUp->_val));
   newXUp &= CP_BITMASK;
   newXLow = xLow->_val | (~yUp->_val & ~yLow->_val & rUp->_val & rLow->_val);
   newXUp &= CP_BITMASK;
   
   newYUp = yUp->_val & ((xUp->_val & rUp->_val) | (~xLow->_val & rUp->_val));
   newYUp &= CP_BITMASK;
   newYLow = yLow->_val | (~xUp->_val & ~xLow->_val & rUp->_val & rLow->_val);
   newYUp &= CP_BITMASK;
   
   newRUp = rUp->_val & ((xUp->_val & yUp->_val) | (xUp->_val & ~ yLow->_val) | (~xLow->_val & yUp->_val));
   newRUp &= CP_BITMASK;
   newRLow = rLow->_val | ((xUp->_val & xLow->_val & yUp->_val) | (xUp->_val & yUp->_val & yLow->_val) | (~xLow->_val & yUp->_val & yLow->_val));
   newRLow &= CP_BITMASK;
   
   _state[0] = &newXUp;
   _state[1] = &newXLow;
   _state[2] = &newYUp;
   _state[3] = &newYLow;
   _state[4] = &newRUp;
   _state[5] = &newRLow;
   
   ORBool xFail = checkDomainConsistency(_x, &newXLow, &newXUp, 1, self);
   ORBool yFail = checkDomainConsistency(_y, &newYLow, &newYUp, 1, self);
   ORBool rFail = checkDomainConsistency(_r, &newRLow, &newRUp, 1, self);
   
   if(xFail || yFail || rFail)
      failNow();
   
   [_x setUp:&newXUp andLow:&newXLow for:self];
   [_y setUp:&newYUp andLow:&newYLow for:self];
   [_r setUp:&newRUp andLow:&newRLow for:self];
   
}
- (void)visit:(ORVisitor *)visitor {
}

- (void)close {
}

@end

@implementation CPBitNotb

-(id) initCPBitNotb:(CPBitVarI*)x eval:(CPBitVarI*)r
{
   self = [super initCPBitCoreConstraint:[x engine]];
   _x = x;
   _r = r;
   _state = malloc(sizeof(ORUInt*)*4);
   return self;
}
-(NSString*) description
{
   NSMutableString* string = [NSMutableString stringWithString:[super description]];
   [string appendString:@" with "];
   [string appendString:[NSString stringWithFormat:@"%@, ",_x]];
   [string appendString:[NSString stringWithFormat:@"and %@\n",_r]];
   
   return string;
}

- (void) dealloc
{
   [super dealloc];
   free(_state);
}

-(void) post
{
   [self propagate];
   if (![_x bound])
      [_x whenChangePropagate: self];
   if (![_r bound])
      [_r whenChangePropagate: self];
   [self propagate];
}
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment
{
  //NSLog(@"Implication for 0x%lx[%u] = %@  traced back through %@", (unsigned long)assignment->var, assignment->index, (CPBitVarI*)assignment->var, self);

   CPBitAntecedents* ants = malloc(sizeof(CPBitAntecedents));
   CPBitAssignment** vars;
   vars  = malloc(sizeof(CPBitAssignment*));
   ants->numAntecedents = 0;
   
   ORUInt index = assignment->index;
   ants->antecedents = vars;
   
   if (assignment->var == _x) {
      if (![_r isFree:index]) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _r;
         vars[ants->numAntecedents]->index = index;
         vars[ants->numAntecedents]->value = [_r getBit:index];
         ants->numAntecedents++;
      }
   }
   else if (assignment->var == _r){
      if (![_x isFree:index]) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _x;
         vars[ants->numAntecedents]->index = index;
         vars[ants->numAntecedents]->value = [_x getBit:index];
         ants->numAntecedents++;
      }
   }
   return ants;
}

- (CPBitAntecedents *)getAntecedents:(CPBitAssignment *)assignment {
   return NULL;
}


-(void) propagate
{
#ifdef BIT_DEBUG
   NSLog(@"Bit Boolean Not Constraint propagated.");
#endif
   
   TRUInt* xLow;
   TRUInt* xUp;
   TRUInt* rLow;
   TRUInt* rUp;
   
   unsigned int newXUp, newXLow;
   unsigned int newRUp, newRLow;
   
   //   NSLog(@"*******************************************");
   //   NSLog(@"Boolean ~");
   //   NSLog(@"x=%@\n",_x);
   //   NSLog(@"r=%@\n\n",_r);
   
   [_x getUp:&xUp andLow:&xLow];
   [_r getUp:&rUp andLow:&rLow];
   
   newXUp = xUp->_val & ~ rLow->_val;
   newXUp &= CP_BITMASK;
   newXLow = xLow->_val | (~rLow->_val & ~rUp->_val);
   newXLow &= CP_BITMASK;
   
   newRUp = rUp->_val & ~xLow->_val;
   newRUp &= CP_BITMASK;
   newRLow = rLow->_val | (~xLow->_val & ~xUp->_val);
   newRLow &= CP_BITMASK;
   
   _state[0] = &newXUp;
   _state[1] = &newXLow;
   _state[2] = &newRUp;
   _state[3] = &newRLow;

   ORBool xFail = checkDomainConsistency(_x, &newXLow, &newXUp, 1, self);
   ORBool rFail = checkDomainConsistency(_r, &newRLow, &newRUp, 1, self);
   
   if(xFail || rFail)
      failNow();
   
   [_x setUp:&newXUp andLow:&newXLow for:self];
   [_r setUp:&newRUp andLow:&newRLow for:self];
   
}
- (void)visit:(ORVisitor *)visitor {
}

- (void)close {
}

@end

@implementation CPBitEqualb

-(id) initCPBitEqualb:(CPBitVarI*)x equals:(CPBitVarI*)y eval:(CPBitVarI*)r
{
   self = [super initCPBitCoreConstraint:[x engine]];
   _x = x;
   _y = y;
   _r = r;
   _state = malloc(sizeof(ORUInt*)*6);
   return self;
}
-(NSString*) description
{
   NSMutableString* string = [NSMutableString stringWithString:[super description]];
   [string appendString:@" with "];
   [string appendString:[NSString stringWithFormat:@"%@, ",_x]];
   [string appendString:[NSString stringWithFormat:@"%@, ",_y]];
   [string appendString:[NSString stringWithFormat:@"and %@\n",_r]];
   
   return string;
}

- (void) dealloc
{
   [super dealloc];
   free(_state);
}

-(void) post
{
   [self propagate];
   if (![_x bound])
      [_x whenChangePropagate: self];
   if (![_y bound])
      [_y whenChangePropagate: self];
   if (![_r bound])
      [_r whenChangePropagate: self];
   [self propagate];
}
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment
{
  //NSLog(@"Implication for 0x%lx[%u] = %@  traced back through %@", (unsigned long)assignment->var, assignment->index, (CPBitVarI*)assignment->var, self);
   ORUInt bitLength = [_x bitLength];
   ORUInt wordLength = [_x getWordLength];
   CPBitAntecedents* ants = malloc(sizeof(CPBitAntecedents));
   CPBitAssignment** vars;
   ants->numAntecedents = 0;
   
   ORUInt index = assignment->index;
//   ants->antecedents = vars;
   
   vars  = malloc(sizeof(CPBitAssignment*)*2*bitLength);
   
   if (assignment->var == _x) {
      if (![_y isFree:index]) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _y;
         vars[ants->numAntecedents]->index = index;
         vars[ants->numAntecedents]->value = [_y getBit:index];
         ants->numAntecedents++;
      }
      if (![_r isFree:0]) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _r;
         vars[ants->numAntecedents]->index = 0;
         vars[ants->numAntecedents]->value = [_r getBit:0];
         ants->numAntecedents++;
      }
   }
   else if (assignment->var == _y){
      if (![_x isFree:index]) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _x;
         vars[ants->numAntecedents]->index = index;
         vars[ants->numAntecedents]->value = [_x getBit:index];
         ants->numAntecedents++;
      }
      if (![_r isFree:0]) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _r;
         vars[ants->numAntecedents]->index = 0;
         vars[ants->numAntecedents]->value = [_r getBit:0];
         ants->numAntecedents++;
      }
   }
   else if (assignment->var == _r){
      if (assignment->value){
         for(int i=0;i<bitLength;i++){
   //         if(i == index)
   //            continue;
            if(![_x isFree:i]){
               vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
               vars[ants->numAntecedents]->index = i;
               vars[ants->numAntecedents]->var = _x;
               vars[ants->numAntecedents]->value = [_x getBit:i];
               ants->numAntecedents++;
            }
            if(![_y isFree:i]){
               vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
               vars[ants->numAntecedents]->index = i;
               vars[ants->numAntecedents]->var = _y;
               vars[ants->numAntecedents]->value = [_y getBit:i];
               ants->numAntecedents++;
            }
         }
      }
      else{
         //find the bits that are different and only include those in the antecedents
         TRUInt* xUp;
         TRUInt* xLow;
         TRUInt* yUp;
         TRUInt* yLow;
         
         [_x getUp:&xUp andLow:&xLow];
         [_y getUp:&yUp andLow:&yLow];

         ORUInt* different = alloca(sizeof(ORUInt)*wordLength);
         ORInt diffIndex =0;
         for(int i=wordLength-1;i>=0;i--){
            different[i] = (xUp[i]._val ^ yUp[i]._val) | (xLow[i]._val ^ yLow[i]._val);
            if(different[i] != 0){
               diffIndex = (i*BITSPERWORD)+(BITSPERWORD - __builtin_clz(different[i])-1);
               break;
            }
         }
         if(![_x isFree:diffIndex]){
            vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
            vars[ants->numAntecedents]->index = diffIndex;
            vars[ants->numAntecedents]->var = _x;
            vars[ants->numAntecedents]->value = [_x getBit:diffIndex];
            ants->numAntecedents++;
         }
         if(![_y isFree:diffIndex]){
            vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
            vars[ants->numAntecedents]->index = diffIndex;
            vars[ants->numAntecedents]->var = _y;
            vars[ants->numAntecedents]->value = [_y getBit:diffIndex];
            ants->numAntecedents++;
         }

      }
   }
   if((assignment->var != _r) && ([_r getBit:0]==0)){
      for(int i=0;i<bitLength;i++){
         if(i == index)
            continue;
         if(![_x isFree:i]){
            vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
            vars[ants->numAntecedents]->index = i;
            vars[ants->numAntecedents]->var = _x;
            vars[ants->numAntecedents]->value = [_x getBit:i];
            ants->numAntecedents++;
         }
         if(![_y isFree:i]){
            vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
            vars[ants->numAntecedents]->index = i;
            vars[ants->numAntecedents]->var = _y;
            vars[ants->numAntecedents]->value = [_y getBit:i];
            ants->numAntecedents++;
         }
      }
   }
   
   ants->antecedents = vars;
   

//   NSLog(@"\n\n\n");
//   NSLog(@"x = %@",_x);
//   NSLog(@"y = %@",_y);
//   NSLog(@"r = %@",_r);
//   NSLog(@"Assignment: %@[%d]",assignment->var,assignment->index);
//   if(ants->numAntecedents > 0)
//      NSLog(@"antecedent[0]: %@[%d]",ants->antecedents[0]->var,ants->antecedents[0]->index);
//   if(ants->numAntecedents > 1)
//      NSLog(@"antecedent[1]: %@[%d]",ants->antecedents[1]->var,ants->antecedents[1]->index);
//
//      NSLog(@"BitEqualb traced back giving %d antecedents\n\n\n",ants->numAntecedents);
   return ants;
}
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment withState:(ORUInt **)state
{
   //NSLog(@"Implication for 0x%lx[%u] = %@  traced back through %@", (unsigned long)assignment->var, assignment->index, (CPBitVarI*)assignment->var, self);
   ORUInt bitLength = [_x bitLength];
   CPBitAntecedents* ants = malloc(sizeof(CPBitAntecedents));
   CPBitAssignment** vars;
   ants->numAntecedents = 0;
   
   ORUInt index = assignment->index;
   //   ants->antecedents = vars;
   
   vars  = malloc(sizeof(CPBitAssignment*)*(2*bitLength+1));
   
   if (assignment->var == _x) {
      if (![_y isFree:index] || ~ISFREE(state[2][index/BITSPERWORD], state[3][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD))) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _y;
         vars[ants->numAntecedents]->index = index;
         if(![_y isFree:index])
            vars[ants->numAntecedents]->value = [_y getBit:index];
         else
            vars[ants->numAntecedents]->value = !((ISTRUE(state[2][index/BITSPERWORD], state[3][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD))) == 0);
         ants->numAntecedents++;
      }
      if (![_r isFree:0] || ~ISFREE(state[4][0], state[5][0]) & 0x1) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _r;
         vars[ants->numAntecedents]->index = 0;
         if(![_r isFree:0])
            vars[ants->numAntecedents]->value = [_r getBit:0];
         else
            vars[ants->numAntecedents]->value = !((ISTRUE(state[4][0], state[5][0]) & 0x1) == 0);
         ants->numAntecedents++;
      }
   }
   else if (assignment->var == _y){
      if (![_x isFree:index] || ~ISFREE(state[0][index/BITSPERWORD], state[1][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD))) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _x;
         vars[ants->numAntecedents]->index = index;
         if(![_x isFree:index])
            vars[ants->numAntecedents]->value = [_x getBit:index];
         else
            vars[ants->numAntecedents]->value = !((ISTRUE(state[0][index/BITSPERWORD], state[1][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD))) == 0);
         ants->numAntecedents++;
      }
      if (![_r isFree:0] || ~ISFREE(state[4][0], state[5][0]) & 0x1) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _r;
         vars[ants->numAntecedents]->index = 0;
         if(![_r isFree:0])
            vars[ants->numAntecedents]->value = [_r getBit:0];
         else
            vars[ants->numAntecedents]->value = !((ISTRUE(state[4][0], state[5][0]) & 0x1) == 0);
         ants->numAntecedents++;
      }
   }
   else if (assignment->var == _r){
//      if (![_x isFree:index] || ~ISFREE(state[0][index/BITSPERWORD], state[1][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD))) {
//         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
//         vars[ants->numAntecedents]->var = _x;
//         vars[ants->numAntecedents]->index = index;
//         if(![_x isFree:index])
//            vars[ants->numAntecedents]->value = [_x getBit:index];
//         else
//            vars[ants->numAntecedents]->value = !((ISTRUE(state[0][index/BITSPERWORD], state[1][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD))) == 0);
//         ants->numAntecedents++;
//      }
//      if (![_y isFree:index] || ~ISFREE(state[2][index/BITSPERWORD], state[3][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD))) {
//         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
//         vars[ants->numAntecedents]->var = _y;
//         vars[ants->numAntecedents]->index = index;
//         if(![_y isFree:index])
//            vars[ants->numAntecedents]->value = [_y getBit:index];
//         else
//            vars[ants->numAntecedents]->value = !((ISTRUE(state[2][index/BITSPERWORD], state[3][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD))) == 0);
//         ants->numAntecedents++;
//      }
   
      for(int i=0;i<bitLength;i++){
//         if(i == index)
//            continue;
         if (![_x isFree:i] || ~ISFREE(state[0][i/BITSPERWORD], state[1][i/BITSPERWORD]) & (0x1 << (i%BITSPERWORD))) {
            vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
            vars[ants->numAntecedents]->index = i;
            vars[ants->numAntecedents]->var = _x;
            if(![_x isFree:i])
               vars[ants->numAntecedents]->value = [_x getBit:i];
            else
               vars[ants->numAntecedents]->value = !((ISTRUE(state[0][i/BITSPERWORD], state[1][i/BITSPERWORD]) & (0x1 << (i%BITSPERWORD))) == 0);
            ants->numAntecedents++;
         }
         if (![_y isFree:i] || ~ISFREE(state[2][i/BITSPERWORD], state[3][i/BITSPERWORD]) & (0x1 << (i%BITSPERWORD))) {
            vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
            vars[ants->numAntecedents]->index = i;
            vars[ants->numAntecedents]->var = _y;
            if(![_y isFree:i])
               vars[ants->numAntecedents]->value = [_y getBit:i];
            else
               vars[ants->numAntecedents]->value = !((ISTRUE(state[2][i/BITSPERWORD], state[3][i/BITSPERWORD]) & (0x1 << (i%BITSPERWORD))) == 0);
            ants->numAntecedents++;
         }
      }     
   }
   if((assignment->var != _r)  && ([_r getBit:0]==0)){
      for(int i=0;i<bitLength;i++){
         if(i == index)
            continue;
         if (![_x isFree:i] || ~ISFREE(state[0][i/BITSPERWORD], state[1][i/BITSPERWORD]) & (0x1 << (i%BITSPERWORD))) {
            vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
            vars[ants->numAntecedents]->index = i;
            vars[ants->numAntecedents]->var = _x;
            if(![_x isFree:i])
               vars[ants->numAntecedents]->value = [_x getBit:i];
            else
               vars[ants->numAntecedents]->value = !((ISTRUE(state[0][i/BITSPERWORD], state[1][i/BITSPERWORD]) & (0x1 << (i%BITSPERWORD))) == 0);
            ants->numAntecedents++;
         }
         if (![_y isFree:i] || ~ISFREE(state[2][i/BITSPERWORD], state[3][i/BITSPERWORD]) & (0x1 << (i%BITSPERWORD))) {
            vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
            vars[ants->numAntecedents]->index = i;
            vars[ants->numAntecedents]->var = _y;
            if(![_y isFree:i])
               vars[ants->numAntecedents]->value = [_y getBit:i];
            else
               vars[ants->numAntecedents]->value = !((ISTRUE(state[2][i/BITSPERWORD], state[3][i/BITSPERWORD]) & (0x1 << (i%BITSPERWORD))) == 0);
            ants->numAntecedents++;
         }
      }
   }

   ants->antecedents = vars;
//   NSLog(@"\n\n\n");
//   NSLog(@"x = %@",_x);
//   NSLog(@"y = %@",_y);
//   NSLog(@"r = %@",_r);
//   NSLog(@"Assignment: %@[%d]",assignment->var,assignment->index);
//   if(ants->numAntecedents > 0)
//      NSLog(@"antecedent[0]: %@[%d]",ants->antecedents[0]->var,ants->antecedents[0]->index);
//   if(ants->numAntecedents > 1)
//      NSLog(@"antecedent[1]: %@[%d]",ants->antecedents[1]->var,ants->antecedents[1]->index);
//   
//   NSLog(@"BitEqualb traced back giving %d antecedents",ants->numAntecedents);
   return ants;
}
-(CPBitAntecedents*) getAntecedents:(CPBitAssignment*)assignment{
   return ([self getAntecedentsFor:assignment withState:_state]);
}
-(void) propagate
{
#ifdef BIT_DEBUG
   NSLog(@"Bit Boolean = Constraint propagated.");
#endif
   
   TRUInt* xLow;
   TRUInt* xUp;
   TRUInt* yLow;
   TRUInt* yUp;
   TRUInt* rLow;
   TRUInt* rUp;
   
   ORUInt wordLength = [_x getWordLength];
//   ORUInt bitLength = [_x bitLength];
   
   ORUInt* newXUp = alloca(sizeof(ORUInt)*wordLength);
   ORUInt* newXLow  = alloca(sizeof(ORUInt)*wordLength);
   ORUInt* newYUp = alloca(sizeof(ORUInt)*wordLength);
   ORUInt* newYLow  = alloca(sizeof(ORUInt)*wordLength);
   ORUInt newRUp, newRLow;
   
   ORUInt xyfree = 0x0;
   ORUInt* xyneq = alloca(sizeof(ORUInt)*wordLength);
//   ORUInt mask = 0x1;

//   NSLog(@"*******************************************");
//   NSLog(@"Boolean =");
//   NSLog(@"x=%@\n",_x);
//   NSLog(@"y=%@\n",_y);
//   NSLog(@"r=%@\n",_r);

   
   [_x getUp:&xUp andLow:&xLow];
   [_y getUp:&yUp andLow:&yLow];
   [_r getUp:&rUp andLow:&rLow];
   
   for(int i=0;i<wordLength;i++){
      newXUp[i] = xUp[i]._val;
      newXLow[i] = xLow[i]._val;
      newYUp[i] = yUp[i]._val;
      newYLow[i] = yLow[i]._val;
      xyneq[i] = 0;
   }
   newRUp = rUp->_val;
   newRLow = rLow->_val;
   
   if(newRUp & newRLow){
      //make _x and _y equal (evaluates to true)
      for(int i=0;i<wordLength;i++){
         newXUp[i] = newYUp[i] = xUp[i]._val & yUp[i]._val;
         newXLow[i] = newYLow[i] = xLow[i]._val | yLow[i]._val;
      }
   }
   else {
      ORUInt numXFree=0;
      ORUInt numYFree=0;
      ORUInt* xfree = alloca(sizeof(ORUInt)*wordLength);
      ORUInt* yfree = alloca(sizeof(ORUInt)*wordLength);
      
      ORUInt numXYDiff = 0;

      for (int i=0; i<wordLength; i++) {
         xfree[i] = xUp[i]._val ^ xLow[i]._val;
         numXFree += __builtin_popcount(xfree[i]);
         xyfree |= xfree[i];
         yfree[i] = yUp[i]._val ^ yLow[i]._val;
         numYFree += __builtin_popcount(yfree[i]);
         xyfree |= yfree[i];
//         xyneq[i] = ((xLow[i]._val ^ yLow[i]._val) | (xUp[i]._val ^ yUp[i]._val)) & ~xfree[i] & ~yfree[i];
        xyneq[i] = ((xLow[i]._val ^ yLow[i]._val) | (xUp[i]._val ^ yUp[i]._val));
         numXYDiff += __builtin_popcount(xyneq[i]);
      }

      //If r is set, is there a final bit in x or y we can set?
      if (((numXFree + numYFree)==1) && (numXYDiff == 1)){
         //if _x or _y have only one free bit, we may be able to fix it
         if (rUp->_val == 0) {
            //only if all of the set bits are identical in x and y
            if (numXFree)
               for (int j=0; j<wordLength; j++){
                  if ((xyneq[j] ^ xfree[j]) == 0)
                  {
                     newXLow[j] |= xfree[j] & ~yUp[j]._val;
                     newXUp[j] &= ~xfree[j] | ~yUp[j]._val;
                  }
               }
            else if (numYFree)
               for (int j=0; j<wordLength; j++){
                  if ((xyneq[j] ^ yfree[j]) == 0)
                  {
                     newYLow[j] |= yfree[j] & ~xUp[j]._val;
                     newYUp[j] &= ~yfree[j] | ~xUp[j]._val;
                  }
               }
         }
      }
      //if _x and _y are bound, you can fix _r
      if ((numXYDiff != 0) && !xyfree)
         newRUp = 0x0;
      else if (!xyfree)
         newRLow = 0x1;
   }

//      NSLog(@"newX = %@",bitvar2NSString(newXLow, newXUp, bitLength));
//      NSLog(@"newY = %@",bitvar2NSString(newYLow, newYUp, bitLength));
//      NSLog(@"newR = %@\n\n",bitvar2NSString(&newRLow, &newRUp, 1));

//   NSLog(@"");
//   NSLog(@"x = %@",_x);
//   NSLog(@"y = %@",_y);
//   NSLog(@"r = %@",_r);
   _state[0] = newXUp;
   _state[1] = newXLow;
   _state[2] = newYUp;
   _state[3] = newYLow;
   _state[4] = &newRUp;
   _state[5] = &newRLow;

   
   ORBool xFail = checkDomainConsistency(_x, newXLow, newXUp, wordLength, self);
   ORBool yFail = checkDomainConsistency(_y, newYLow, newYUp, wordLength, self);
   ORBool rFail = checkDomainConsistency(_r, &newRLow, &newRUp, 1, self);
   
   if(xFail || yFail || rFail)
      failNow();

   [_x setUp:newXUp andLow:newXLow for:self];
   [_y setUp:newYUp andLow:newYLow for:self];
   [_r setUp:&newRUp andLow:&newRLow for:self];
   
   
}
@end

//@implementation CPBitInc
//
//-(id) initCPBitInc:(CPBitVarI*)x equals:(CPBitVarI*)y
//{
//   self = [super initCPBitCoreConstraint:[x engine]];
//   _x = x;
//   _y = y;
//   _z = z;
//   
//   CPEngineI* engine = [_x engine];
//   
//   ORUInt bitLength = [_x bitLength];
//   ORUInt wordLength = bitLength/32 + ((bitLength%32 ==0) ? 0 : 1);
//   
//   ORUInt*   up;
//   ORUInt*   low;
//   ORUInt*   one;
//   
//   up = malloc(sizeof(ORUInt)*wordLength);
//   low = malloc(sizeof(ORUInt)*wordLength);
//   
//   for (int i=0; i<wordLength; i++) {
//      up[i] = 0xFFFFFFFF;
//      low[i] = 0x00000000;
//      one[i] = 0x00000000;
//   }
//   one[0] = 0x00000001;
//   
//   _notY = [[CPBitVarI alloc] initCPExplicitBitVar:engine withLow:low andUp:up andLen:bitLength];
//   _negYCin = [[CPBitVarI alloc] initCPExplicitBitVar:engine withLow:low andUp:up andLen:bitLength];
//   _negYCout = [[CPBitVarI alloc] initCPExplicitBitVar:engine withLow:low andUp:up andLen:bitLength];
//   _negY = [[CPBitVarI alloc] initCPExplicitBitVar:engine withLow:low andUp:up andLen:bitLength];
//   _cin = [[CPBitVarI alloc] initCPExplicitBitVar:engine withLow:low andUp:up andLen:bitLength];
//   _cout = [[CPBitVarI alloc] initCPExplicitBitVar:engine withLow:low andUp:up andLen:bitLength];
//   
//   
//   return self;
//}
//-(NSString*) description
//{
//   NSMutableString* string = [NSMutableString stringWithString:[super description]];
//   [string appendString:@" with "];
//   [string appendString:[NSString stringWithFormat:@"%@, ",_x]];
//   [string appendString:[NSString stringWithFormat:@"%@, ",_y]];
//   [string appendString:[NSString stringWithFormat:@"and %@\n",_z]];
//   
//   return string;
//}
//
//- (void) dealloc
//{
//   [super dealloc];
//}
//
//-(void) post
//{
//   CPEngineI* engine = [_x engine];
//   
//   [engine addInternal: [[CPBitNOT alloc] initCPBitNOT:_x equals:_y]];
//   [engine addInternal:[[CPBitADD alloc] initCPBitAdd:(CPBitVarI*)_notY
//                                                 plus:(CPBitVarI*)_negY
//                                               equals:(CPBitVarI*)_z
//                                          withCarryIn:(CPBitVarI*)_cin
//                                          andCarryOut:(CPBitVarI*)_cout]];
//   [engine addInternal:[[CPBitADD alloc] initCPBitAdd:(CPBitVarI*)_x
//                                                 plus:(CPBitVarI*)_negY
//                                               equals:(CPBitVarI*)_z
//                                          withCarryIn:(CPBitVarI*)_cin
//                                          andCarryOut:(CPBitVarI*)_cout]];
//   
//}
//-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment
//{
//   return nil;
//}
//
//-(void) propagate{}
//@end

@implementation CPBitSum {
@private
   CPBitVarI*      _x;
   CPBitVarI*      _y;
   CPBitVarI*      _z;
   CPBitVarI*      _cin;
   CPBitVarI*      _cout;

   CPBitVarI*     _temp0;
   CPBitVarI*     _temp1;
   CPBitVarI*     _temp2;
   
}
-(id) initCPBitSum:(id<CPBitVar>)x plus:(id<CPBitVar>)y equals:(id<CPBitVar>)z withCarryIn:(id<CPBitVar>)cin andCarryOut:(id<CPBitVar>)cout
{
   self = [super initCPBitCoreConstraint:[x engine]];
   _x = (CPBitVarI*)x;
   _y = (CPBitVarI*)y;
   _z = (CPBitVarI*)z;
   _cin = (CPBitVarI*)cin;
   _cout = (CPBitVarI*)cout;

   id<CPEngine> engine = [_x engine];
   
   ORUInt bitLength = [_x bitLength];
   
   ORUInt wordLength = bitLength/32 + ((bitLength%32 ==0) ? 0 : 1);
   
   ORUInt*   up;
   ORUInt*   low;
   ORUInt*   one;
   
   up = alloca(sizeof(ORUInt)*wordLength);
   low = alloca(sizeof(ORUInt)*wordLength);
   one = alloca(sizeof(ORUInt)*wordLength);
   
   for (int i=0; i<wordLength; i++) {
      up[i] = 0xFFFFFFFF;
      low[i] = 0x00000000;
   }
   

   _temp0 = (CPBitVarI*)[CPFactory bitVar:engine withLow:low andUp:up andLength:bitLength];
   _temp1 = (CPBitVarI*)[CPFactory bitVar:engine withLow:low andUp:up andLength:bitLength];
   _temp2 = (CPBitVarI*)[CPFactory bitVar:engine withLow:low andUp:up andLength:bitLength];
   
   return self;
}
-(NSString*) description
{
   NSMutableString* string = [NSMutableString stringWithString:[super description]];
   [string appendString:@" with "];
   [string appendString:[NSString stringWithFormat:@"%@ ",_x]];
   [string appendString:[NSString stringWithFormat:@"and %@ ",_y]];
   [string appendString:[NSString stringWithFormat:@"and %@\n",_z]];
   [string appendString:[NSString stringWithFormat:@"with Carry In %@\n",_cin]];
   [string appendString:[NSString stringWithFormat:@"and Carry Out%@\n",_cout]];
   
   
   return string;
}

- (void) dealloc
{
   [super dealloc];
}
-(NSSet*) allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y, _z, _cin, _cout, nil] autorelease];
}
-(void) post
{
   id<CPEngine> engine = [_x engine];

   [engine addInternal:[CPFactory bitXOR:_x bxor:_y equals:_temp0]];
   [engine addInternal:[CPFactory bitXOR:_temp0 bxor:_cin equals:_z]];
   [engine addInternal:[CPFactory bitAND:_x band:_y equals:_temp1]];
   [engine addInternal:[CPFactory bitAND:_cin band:_temp0 equals:_temp2]];
   [engine addInternal:[CPFactory bitOR:_temp1 bor:_temp2 equals:_cout]];
   [engine addInternal:[CPFactory bitShiftL:_cout by:1 equals:_cin]];
}
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment
{
   //NSLog(@"Implication for 0x%lx[%u] = %@  traced back through %@", (unsigned long)assignment->var, assignment->index, (CPBitVarI*)assignment->var, self);
  
  return NULL;
}
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment withState:(ORUInt **)state
{
   //NSLog(@"Implication for 0x%lx[%u] = %@  traced back through %@", (unsigned long)assignment->var, assignment->index, (CPBitVarI*)assignment->var, self);
   
  return NULL;
}
-(CPBitAntecedents*) getAntecedents:(CPBitAssignment*) assignment
{
   //NSLog(@"Implication for 0x%lx[%u] = %@  traced back through %@", (unsigned long)assignment->var, assignment->index, (CPBitVarI*)assignment->var, self);
   
  return NULL;
}
-(void) propagate
{}
@end

@implementation CPBitNegative

-(id) initCPBitNegative:(CPBitVarI*)x equals:(CPBitVarI*)y
{
   self = [super initCPBitCoreConstraint:[x engine]];
   _x = x;
   _y = y;
   _state = malloc(sizeof(ORUInt*)*4);
   id<CPEngine> engine = [_x engine];
   
   ORUInt bitLength = [_x bitLength];
   ORUInt wordLength = bitLength/32 + ((bitLength%32 ==0) ? 0 : 1);
   
   ORUInt*   up;
   ORUInt*   low;
   ORUInt*   one;
   
   up = alloca(sizeof(ORUInt)*wordLength);
   low = alloca(sizeof(ORUInt)*wordLength);
   one = alloca(sizeof(ORUInt)*wordLength);
   
   for (int i=0; i<wordLength; i++) {
      up[i] = UP_MASK;
      low[i] = 0x00000000;
      one[i] = 0x00000000;
   }
   one[0] = 0x00000001;
   
   _notX = (CPBitVarI*)[CPFactory bitVar:engine withLow:low andUp:up andLength:bitLength];
   _one = (CPBitVarI*)[CPFactory bitVar:engine withLow:one andUp:one andLength:bitLength];
   _negXCin = (CPBitVarI*)[CPFactory bitVar:engine withLow:low andUp:up andLength:bitLength];
   _negXCout = (CPBitVarI*)[CPFactory bitVar:engine withLow:low andUp:up andLength:bitLength];
//   _cin = (CPBitVarI*)[CPFactory bitVar:engine withLow:low andUp:up andLength:bitLength];
//   _cout = (CPBitVarI*)[CPFactory bitVar:engine withLow:low andUp:up andLength:bitLength];
   
   
   return self;
}
-(NSString*) description
{
   NSMutableString* string = [NSMutableString stringWithString:[super description]];
   [string appendString:@" with "];
   [string appendString:[NSString stringWithFormat:@"%@, ",_x]];
   [string appendString:[NSString stringWithFormat:@"%@, ",_y]];
   
   return string;
}

- (void) dealloc
{
   [super dealloc];
   free(_state);
}

-(void) post
{
   id<CPEngine> engine = [_x engine];

   [engine addInternal:[CPFactory bitNOT:_x equals:_notX]];
   [engine addInternal:[CPFactory bitADD:_notX
                                    plus:(CPBitVarI*)_one
                             withCarryIn:(CPBitVarI*)_negXCin
                                  equals:(CPBitVarI*)_y
                            withCarryOut:(CPBitVarI*)_negXCout]];
}

-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment withState:(ORUInt**)state
{
   return NULL;
}

-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment
{
  //NSLog(@"Implication for 0x%lx[%u] = %@  traced back through %@", (unsigned long)assignment->var, assignment->index, (CPBitVarI*)assignment->var, self);
   
   return NULL;
}

- (CPBitAntecedents *)getAntecedents:(CPBitAssignment *)assignment {
   return NULL;
}


-(void) propagate{}
- (void)visit:(ORVisitor *)visitor {
}

- (void)close {
}

@end


@implementation CPBitSubtract

-(id) initCPBitSubtract:(CPBitVarI*)x minus:(CPBitVarI*)y equals:(CPBitVarI*)z
{
   self = [super initCPBitCoreConstraint:[x engine]];
   _x = x;
   _y = y;
   _z = z;
   
   id<CPEngine> engine = [_x engine];

   ORUInt bitLength = [_x bitLength];

   ORUInt wordLength = bitLength/32 + ((bitLength%32 ==0) ? 0 : 1);
   
   ORUInt*   cinup;
   ORUInt*   up;
   ORUInt*   low;
//   ORUInt*   one;
   
   up = alloca(sizeof(ORUInt)*wordLength);
   low = alloca(sizeof(ORUInt)*wordLength);
//   one = alloca(sizeof(ORUInt)*wordLength);
   cinup = alloca(sizeof(ORUInt)*wordLength);
   
   for (int i=0; i<wordLength; i++) {
      cinup[i] = up[i] = 0xFFFFFFFF;
      low[i] = 0x00000000;
//      one[i] = 0x00000000;
   }
//   one[0] = 0x00000001;
   cinup[0] = 0xFFFFFFFE;
   
   _one = (CPBitVarI*)[CPFactory bitVar:engine withLow:low andUp:low andLength:bitLength];
   _cin = (CPBitVarI*)[CPFactory bitVar:engine withLow:low andUp:cinup andLength:bitLength];
   _cout = (CPBitVarI*)[CPFactory bitVar:engine withLow:low andUp:up andLength:bitLength];
   

   return self;
}
-(NSString*) description
{
   NSMutableString* string = [NSMutableString stringWithString:[super description]];
   [string appendString:@" with "];
   [string appendString:[NSString stringWithFormat:@"%@, ",_x]];
   [string appendString:[NSString stringWithFormat:@"%@, ",_y]];
   [string appendString:[NSString stringWithFormat:@"and %@\n",_z]];
//   [string appendString:[NSString stringWithFormat:@"using ~y %@\n",_notY]];
//   [string appendString:[NSString stringWithFormat:@"and one %@\n",_one]];
//   [string appendString:[NSString stringWithFormat:@"and -y %@\n",_negY]];
   [string appendString:[NSString stringWithFormat:@"and -y cin %@\n",_negYCin]];
   [string appendString:[NSString stringWithFormat:@"and -y cout %@\n",_negYCout]];
   return string;
}

- (void) dealloc
{
   [super dealloc];
}

-(void) post
{
   id<CPEngine> engine = [_x engine];

   [engine addInternal:[CPFactory bitADD:_y
                                    plus:_z
                             withCarryIn:_cin
                                  equals:_x
                            withCarryOut:_cout]];
}
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment
{
  //NSLog(@"Implication for 0x%lx[%u] = %@  traced back through %@", (unsigned long)assignment->var, assignment->index, (CPBitVarI*)assignment->var, self);

   return NULL;
}

- (CPBitAntecedents *)getAntecedents:(CPBitAssignment *)assignment {
   return NULL;
}


-(void) propagate{}
- (void)visit:(ORVisitor *)visitor {
}
- (void)close {
}
@end

@implementation CPBitDivide

-(id) initCPBitDivide:(CPBitVarI*)x dividedby:(CPBitVarI*)y equals:(CPBitVarI*)q rem:(CPBitVarI*)r
{
   self = [super initCPBitCoreConstraint:[x engine]];
   _x = x;
   _y = y;
   _q = q;
   _r = r;
   
   ORUInt bitLength = [_x bitLength];
   ORUInt wordLength = bitLength/32 + ((bitLength%32 ==0) ? 0 : 1);

   ORUInt* up = alloca(sizeof(ORUInt)*wordLength);
   ORUInt* low = alloca(sizeof(ORUInt)*wordLength);
   
   for (int i=0; i<wordLength; i++) {
      up[i] = 0xFFFFFFFF;
      low[i] = 0x00000000;
   }
   
   id<CPEngine> engine = [_x engine];
   
   _product = (CPBitVarI*)[CPFactory bitVar:engine withLow:low andUp:up andLength:bitLength];
//   _r = (CPBitVarI*)[CPFactory bitVar:engine withLow:low andUp:up andLength:bitLength];
   _cin = (CPBitVarI*)[CPFactory bitVar:engine withLow:low andUp:up andLength:bitLength];
   _cout = (CPBitVarI*)[CPFactory bitVar:engine withLow:low andUp:up andLength:bitLength];
   ORUInt tLow = 0x1;
   ORUInt tUp = 0x1;

   _trueVal = (CPBitVarI*)[CPFactory bitVar:engine withLow:&tLow andUp:&tUp andLength:1];

   return self;
}
-(NSString*) description
{
   NSMutableString* string = [NSMutableString stringWithString:[super description]];
   [string appendString:@" with "];
   [string appendString:[NSString stringWithFormat:@"%@, ",_x]];
   [string appendString:[NSString stringWithFormat:@"%@, ",_y]];
   [string appendString:[NSString stringWithFormat:@"%@, ",_q]];
   [string appendString:[NSString stringWithFormat:@"and %@\n",_r]];
   
   return string;
}

- (void) dealloc
{
   [super dealloc];
}

-(void) post
{
   id<CPEngine> engine = [_x engine];
   
   [engine addInternal:[CPFactory bitMultiply:_y times:_q equals:_product]];

   [engine addInternal:[CPFactory bitADD:_product
                                    plus:_r
                             withCarryIn:_cin
                                  equals:_x
                             withCarryOut:_cout]];

   [engine addInternal:[CPFactory bitLT:_r LT:_y eval:_trueVal]];
}

-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment withState:(ORUInt**)state
{
   return NULL;
}

-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment
{
   //NSLog(@"Implication for 0x%lx[%u] = %@  traced back through %@", (unsigned long)assignment->var, assignment->index, (CPBitVarI*)assignment->var, self);
   
   return NULL;
}

- (CPBitAntecedents *)getAntecedents:(CPBitAssignment *)assignment {
   return NULL;
}


-(void) propagate{}
- (void)visit:(ORVisitor *)visitor {
}

- (void)close {
}

@end

@implementation CPBitMultiplyComposed{
@private
   CPBitVarI* _opx;
   CPBitVarI* _opy;
   CPBitVarI* _x;
   CPBitVarI* _y;
   CPBitVarI* _z;
   CPBitVarI** _cin;
   CPBitVarI** _cout;
   CPBitVarI** _shifted;
   CPBitVarI** _partialProduct;
   CPBitVarI** _intermediate;
   ORUInt**    _state;
   CPBitVarI** _bit;
   CPBitVarI* _zero;

   ORUInt   _opLength;
   ORUInt   _bitLength;
}


-(id) initCPBitMultiplyComposed:(CPBitVarI*)x times:(CPBitVarI*)y equals:(CPBitVarI*)z
{
   self = [super initCPBitCoreConstraint:[x engine]];
   _opx = x;
   _opy = y;
   _z = z;
   
   id<CPEngine> engine = [_opx engine];
   
   _opLength = [_opx bitLength];
   
   _state = malloc(sizeof(ORUInt*)*2*(_opLength+1));
   
   _bitLength = _opLength << 1;
   ORUInt wordLength = _bitLength/BITSPERWORD + ((_bitLength%BITSPERWORD ==0) ? 0 : 1);
   
   ORUInt*   up;
   ORUInt*   low;
   ORUInt*  cinUp;
   ORUInt*   one;
   
   up = alloca(sizeof(ORUInt)*wordLength);
   low = alloca(sizeof(ORUInt)*wordLength);
   one = alloca(sizeof(ORUInt)*wordLength);
   cinUp = alloca(sizeof(ORUInt)*wordLength);
   
   for (int i=0; i<wordLength; i++) {
      cinUp[i] = up[i] = 0xFFFFFFFF;
      low[i] = 0x00000000;
      one[i] = 0x00000000;
   }
   one[0] = 0x00000001;
   cinUp[0] = 0xFFFFFFFE;
   
//   _x = (CPBitVarI*)[CPFactory bitVar:engine withLow:low andUp:up andLength:_bitLength];
//   _y = (CPBitVarI*)[CPFactory bitVar:engine withLow:low andUp:up andLength:_bitLength];
   
   _zero =(CPBitVarI*)[CPFactory bitVar:engine withLow:low andUp:low andLength:_opLength];

   _bit = malloc(sizeof(CPBitVarI*)*_opLength);
   _shifted = malloc(sizeof(CPBitVarI*)*_opLength);
   _cin = malloc(sizeof(CPBitVarI*)*_opLength);
   _cout = malloc(sizeof(CPBitVarI*)*_opLength);
   _intermediate = malloc(sizeof(CPBitVarI*)*_opLength);
   _partialProduct = malloc(sizeof(CPBitVarI*)*_opLength);
   
   
   _bit[0] = (CPBitVarI*)[CPFactory bitVar:engine withLow:low andUp:one andLength:1];
//   _cin[0] = (CPBitVarI*)[CPFactory bitVar:engine withLow:low andUp:low andLength:_bitLength];
//   _cout[0] = (CPBitVarI*)[CPFactory bitVar:engine withLow:low andUp:up andLength:_bitLength];
//   _partialProduct[0] = (CPBitVarI*)[CPFactory bitVar:engine withLow:low andUp:up andLength:_bitLength];
   _intermediate[0] = (CPBitVarI*)[CPFactory bitVar:engine withLow:low andUp:up andLength:_opLength];
//   _shifted[0] = (CPBitVarI*)[CPFactory bitVar:engine withLow:low andUp:up andLength:_bitLength];

   //TODO: No need for cin[0] or cout[0]
   for (int i=1; i<_opLength-1; i++) {
      _bit[i] = (CPBitVarI*)[CPFactory bitVar:engine withLow:low andUp:one andLength:1];
      _cin[i] = (CPBitVarI*)[CPFactory bitVar:engine withLow:low andUp:cinUp andLength:_opLength];
      _cout[i] = (CPBitVarI*)[CPFactory bitVar:engine withLow:low andUp:up andLength:_opLength];
      _partialProduct[i] = (CPBitVarI*)[CPFactory bitVar:engine withLow:low andUp:up andLength:_opLength];
      _intermediate[i] = (CPBitVarI*)[CPFactory bitVar:engine withLow:low andUp:up andLength:_opLength];
      _shifted[i] = (CPBitVarI*)[CPFactory bitVar:engine withLow:low andUp:up andLength:_opLength];
   }
   //no need for intermediate variable as last element in the array
   _bit[_opLength-1] = (CPBitVarI*)[CPFactory bitVar:engine withLow:low andUp:one andLength:1];
   _cin[_opLength-1] = (CPBitVarI*)[CPFactory bitVar:engine withLow:low andUp:cinUp andLength:_opLength];
   _cout[_opLength-1] = (CPBitVarI*)[CPFactory bitVar:engine withLow:low andUp:up andLength:_opLength];
   _partialProduct[_opLength-1] = (CPBitVarI*)[CPFactory bitVar:engine withLow:low andUp:up andLength:_opLength];
   _shifted[_opLength-1] = (CPBitVarI*)[CPFactory bitVar:engine withLow:low andUp:up andLength:_opLength];
   
   return self;
}
-(NSString*) description
{
   NSMutableString* string = [NSMutableString stringWithString:[super description]];
   [string appendString:@" with "];
   [string appendString:[NSString stringWithFormat:@"%@, ",_x]];
   [string appendString:[NSString stringWithFormat:@"%@, ",_y]];
   [string appendString:[NSString stringWithFormat:@"%@, ",_z]];
   
   return string;
}

- (void) dealloc
{
   [super dealloc];
}

-(void) post
{
   id<CPEngine> engine = [_opx engine];
//   [engine addInternal:[CPFactory bitZeroExtend:_opx extendTo:_x]];
//   
//   [engine addInternal:[CPFactory bitZeroExtend:_opy extendTo:_y]];
   
   [engine addInternal:[CPFactory bitExtract:_opy from:0 to:0 eq:_bit[0]]];
   [engine addInternal:[CPFactory bitITE:_bit[0] then:_opx else:_zero result:_intermediate[0]]];
   
//   [engine addInternal:[CPFactory bitEqual:_intermediate[0] to:_partialProduct[0]]];
   
   for (int i=1; i<_opLength-1; i++) {
      [engine addInternal:[CPFactory bitShiftL:_opx by:i equals:_shifted[i]]];
      [engine addInternal:[CPFactory bitExtract:_opy from:i to:i eq:_bit[i]]];
      [engine addInternal:[CPFactory bitITE:_bit[i] then:_shifted[i] else:_zero result:_partialProduct[i]]];
      [engine addInternal:[CPFactory bitADD:_intermediate[i-1]
                                       plus:_partialProduct[i]
                                withCarryIn:_cin[i]
                                     equals:_intermediate[i]
                               withCarryOut:_cout[i]]];
   }
   [engine addInternal:[CPFactory bitShiftL:_opx by:_opLength-1 equals:_shifted[_opLength-1]]];
   [engine addInternal:[CPFactory bitExtract:_opy from:_opLength-1 to:_opLength-1 eq:_bit[_opLength-1]]];
   [engine addInternal:[CPFactory bitITE:_bit[_opLength-1] then:_shifted[_opLength-1] else:_zero result:_partialProduct[_opLength-1]]];
   [engine addInternal:[CPFactory bitADD: _intermediate[_opLength-2]
                                    plus:(CPBitVarI*)_partialProduct[_opLength-1]
                             withCarryIn:(CPBitVarI*)_cin[_opLength-1]
                                  equals:(CPBitVarI*)_z
                            withCarryOut:(CPBitVarI*)_cout[_opLength-1]]];

}
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment
{
   //NSLog(@"Implication for 0x%lx[%u] = %@  traced back through %@", (unsigned long)assignment->var, assignment->index, (CPBitVarI*)assignment->var, self);
   
   return NULL;
}

-(void) propagate{}
@end

@implementation CPBitMultiply {
@private
   CPBitVarI* _opx;
   CPBitVarI* _opy;
   CPBitVarI* _x;
   CPBitVarI* _y;
   CPBitVarI* _z;
   CPBitVarI** _cin;
   CPBitVarI** _cout;
   CPBitVarI** _partialProduct;
   CPBitVarI** _intermediate;
   ORUInt**    _state;
   
   ORUInt   _opLength;
   ORUInt   _bitLength;
}
-(id) initCPBitMultiply:(CPBitVarI*)x times:(CPBitVarI*)y equals:(CPBitVarI*)z
{
   self = [super initCPBitCoreConstraint:[x engine]];
   _opx = x;
   _opy = y;
   _z = z;
   
   id<CPEngine> engine = [_opx engine];
   
   _opLength = [_opx bitLength];
   
   _state = malloc(sizeof(ORUInt*)*2*(_opLength+1));
   
   _bitLength = _opLength << 1;
   ORUInt wordLength = _bitLength/BITSPERWORD + ((_bitLength%BITSPERWORD ==0) ? 0 : 1);
   
   ORUInt*   up;
   ORUInt*   low;
   ORUInt*   one;
   
   up = alloca(sizeof(ORUInt)*wordLength);
   low = alloca(sizeof(ORUInt)*wordLength);
   one = alloca(sizeof(ORUInt)*wordLength);
   
   for (int i=0; i<wordLength; i++) {
      up[i] = 0xFFFFFFFF;
      low[i] = 0x00000000;
      one[i] = 0x00000000;
   }
   one[0] = 0x00000001;
   
   _x = (CPBitVarI*)[CPFactory bitVar:engine withLow:low andUp:up andLength:_bitLength];
   _y = (CPBitVarI*)[CPFactory bitVar:engine withLow:low andUp:up andLength:_bitLength];

   _cin = malloc(sizeof(CPBitVarI*)*_opLength);
   _cout = malloc(sizeof(CPBitVarI*)*_opLength);
   _intermediate = malloc(sizeof(CPBitVarI*)*_opLength);
   _partialProduct = malloc(sizeof(CPBitVarI*)*_opLength);

   //TODO: No need for cin[0] or cout[0]
   for (int i=0; i<_opLength-1; i++) {
      _cin[i] = (CPBitVarI*)[CPFactory bitVar:engine withLow:low andUp:up andLength:_bitLength];
      _cout[i] = (CPBitVarI*)[CPFactory bitVar:engine withLow:low andUp:up andLength:_bitLength];
      _partialProduct[i] = (CPBitVarI*)[CPFactory bitVar:engine withLow:low andUp:up andLength:_bitLength];
      _intermediate[i] = (CPBitVarI*)[CPFactory bitVar:engine withLow:low andUp:up andLength:_bitLength];
   }
   //no need for intermediate variable as last element in the array
   _cin[_opLength-1] = (CPBitVarI*)[CPFactory bitVar:engine withLow:low andUp:up andLength:_bitLength];
   _cout[_opLength-1] = (CPBitVarI*)[CPFactory bitVar:engine withLow:low andUp:up andLength:_bitLength];
   _partialProduct[_opLength-1] = (CPBitVarI*)[CPFactory bitVar:engine withLow:low andUp:up andLength:_bitLength];
   
   return self;
}
-(NSString*) description
{
   NSMutableString* string = [NSMutableString stringWithString:[super description]];
   [string appendString:@" with "];
   [string appendString:[NSString stringWithFormat:@"%@, ",_x]];
   [string appendString:[NSString stringWithFormat:@"%@, ",_y]];
   [string appendString:[NSString stringWithFormat:@"and %@\n",_z]];
   
   return string;
}

- (void) dealloc
{
   [super dealloc];
   free(_state);
   for (int i=0; i<_opLength-1; i++) {
      free (_cin[i]);
      free (_cout[i]);
      free (_partialProduct[i]);
      free (_intermediate[i]);
   }
   free(_cin);
   free(_cout);
   free(_partialProduct);
   free(_intermediate);

}

-(void) post
{
   id<CPEngine> engine = [_x engine];

   [engine addInternal:[CPFactory bitZeroExtend:_opx extendTo:_x]];

   [engine addInternal:[CPFactory bitZeroExtend:_opy extendTo:_y]];

   [engine addInternal:[CPFactory bitEqual:_intermediate[0] to:_partialProduct[0]]];

//   [engine addInternal:[[CPBitADD alloc] initCPBitAdd:(CPBitVarI*)_x
//                                                 plus:(CPBitVarI*)_partialProduct[0]
//                                               equals:(CPBitVarI*)_intermediate[0]
//                                          withCarryIn:(CPBitVarI*)_cin[0]
//                                          andCarryOut:(CPBitVarI*)_cout[0]]];
   for (int i=1; i<_opLength-1; i++) {
      [engine addInternal:[CPFactory bitADD:_intermediate[i-1]
                                       plus:_partialProduct[i]
                                withCarryIn:_cin[i]
                                     equals:_intermediate[i]
                               withCarryOut:_cout[i]]];
   }
   [engine addInternal:[CPFactory bitADD: _intermediate[_opLength-2]
                                    plus:(CPBitVarI*)_partialProduct[_opLength-1]
                             withCarryIn:(CPBitVarI*)_cin[_opLength-1]
                                  equals:(CPBitVarI*)_z
                            withCarryOut:(CPBitVarI*)_cout[_opLength-1]]];
   
   [self propagate];
   if (![_x bound])
      [_x whenChangePropagate: self];
   if (![_y bound])
      [_y whenChangePropagate: self];
   if (![_z bound])
      [_z whenChangePropagate: self];
   [self propagate];

}
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment
{
  //NSLog(@"Implication for 0x%lx[%u] = %@  traced back through %@", (unsigned long)assignment->var, assignment->index, (CPBitVarI*)assignment->var, self);

   CPBitAntecedents* ants = malloc(sizeof(CPBitAntecedents));
   CPBitAssignment** vars;
   ants->numAntecedents = 0;

   if(assignment->var == _z){
      ORBool xZero = true;
      ORBool yZero = true;
      
      ORUInt wordLength = [_opx getWordLength];
      
      TRUInt* xUp, *xLow;
      TRUInt* yUp, *yLow;
      
      [_x getUp:&xUp andLow:&xLow];
      [_y getUp:&yUp andLow:&yLow];
      
      for (int i=0; i<wordLength; i++) {
         if (xUp[i]._val != 0) {
            xZero = false;
         }
         if (yUp[i]._val != 0) {
            yZero = false;
         }
      }

      ORUInt bitLength;
      if(xZero){
         bitLength =[_x bitLength];
         vars  = malloc(sizeof(CPBitAssignment*)*bitLength);
         for (int i=0; i<bitLength; i++) {
            vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
            vars[ants->numAntecedents]->var = _x;
            vars[ants->numAntecedents]->index = i;
            vars[ants->numAntecedents]->value = [_x getBit:i];
            ants->numAntecedents++;
         }
      }
      else if (yZero){
         bitLength =[_y bitLength];
         vars  = malloc(sizeof(CPBitAssignment*)*bitLength);
         for (int i=0; i<bitLength; i++) {
            vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
            vars[ants->numAntecedents]->var = _y;
            vars[ants->numAntecedents]->index = i;
            vars[ants->numAntecedents]->value = [_y getBit:i];
            ants->numAntecedents++;
         }
      }
      else{
         vars=NULL;
      }
   }
   else {
      vars  = malloc(sizeof(CPBitAssignment*)*2);
      for (int i = 0; i< _opLength; i++) {
         if (assignment->var == _partialProduct[i]) {
            ORUInt index = assignment->index - i;
            if(![_y isFree:i]){
               vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
               vars[ants->numAntecedents]->var = _y;
               vars[ants->numAntecedents]->index = i;
               vars[ants->numAntecedents]->value = [_y getBit:i];
               ants->numAntecedents++;
            }
            if((index < _opLength) && ![_x isFree:index]){
               vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
               vars[ants->numAntecedents]->var = _x;
               vars[ants->numAntecedents]->index = index;
               vars[ants->numAntecedents]->value = [_x getBit:index];
               ants->numAntecedents++;
            }
         }
      }

   }
   ants->antecedents = vars;
   return ants;
}

- (CPBitAntecedents *)getAntecedents:(CPBitAssignment *)assignment {
   return NULL;
}
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment withState:(ORUInt**)state
{
   return NULL;
}


-(void) propagate{
   
   //   CPEngineI* engine = [_x engine];
   
   TRUInt* xLow;
   TRUInt* xUp;
   TRUInt* yLow;
   TRUInt* yUp;
   //   TRUInt* opyLow;
   //   TRUInt* opyUp;
   TRUInt* zLow;
   TRUInt* zUp;
   
   TRUInt* tempUp;
   TRUInt* tempLow;
   
   ORUInt wordLength = _bitLength/BITSPERWORD + ((_bitLength%BITSPERWORD ==0) ? 0 : 1);
   
   //   ORUInt mask = 0x1;
   //   ORUInt temp;
   //
   //   unsigned int* newXUp = alloca(sizeof(unsigned int)*wordLength);
   //   unsigned int* newXLow  = alloca(sizeof(unsigned int)*wordLength);
   //   unsigned int* newYUp = alloca(sizeof(unsigned int)*wordLength);
   //   unsigned int* newYLow  = alloca(sizeof(unsigned int)*wordLength);
   unsigned int* newZUp = alloca(sizeof(unsigned int)*wordLength);
   unsigned int* newZLow  = alloca(sizeof(unsigned int)*wordLength);
   
   unsigned int* newUp = alloca(sizeof(unsigned int)*wordLength);
   unsigned int* newLow  = alloca(sizeof(unsigned int)*wordLength);
   
   ORUInt* boundBits = alloca(sizeof(unsigned int)*wordLength);
   ORUInt* boundUp = alloca(sizeof(unsigned int)*wordLength);
   ORUInt* boundLow = alloca(sizeof(unsigned int)*wordLength);
   
   [_x getUp:&xUp andLow:&xLow];
   [_y getUp:&yUp andLow:&yLow];
   //   [_opy getUp:&opyUp andLow:&opyLow];
   [_z getUp:&zUp andLow:&zLow];
   
   for(int i=0;i<wordLength;i++){
      boundBits[i] = ~(yLow[i]._val ^ yUp[i]._val);
      boundUp[i] = yLow[i]._val & boundBits[i];
      boundLow[i] = ~yUp[i]._val & boundBits[i];
   }
   
   for (int i=0; i<wordLength; i++) {
      newZUp[i] = zUp[i]._val;
      newZLow[i] = zLow[i]._val;
   }
   ORBool xZero = true;
   ORBool yZero = true;
   
   for (int i=0; i<wordLength; i++) {
      if (xUp[i]._val != 0) {
         xZero = false;
      }
      if (yUp[i]._val != 0) {
         yZero = false;
      }
   }
   
   if (xZero || yZero) {
      for (int i=0 ; i<wordLength; i++) {
         newZUp[i] = 0;
      }
   }
   
   TRUInt* pUp;
   TRUInt* pLow;
   for(int i=0;i<_opLength;i++){
      [_partialProduct[i] getUp:&pUp andLow:&pLow];
      _state[i*2] = alloca(sizeof(ORUInt)*wordLength);
      _state[i*2+1] = alloca(sizeof(ORUInt)*wordLength);
      for(int j=0;j<wordLength;j++){
         _state[i*2][j] = pUp[i]._val;
         _state[i*2+1][j] = pLow[i]._val;
      }
   }
   //   ORUInt* tUp = alloca(sizeof(ORUInt)*wordLength);
   //   ORUInt* tLow = alloca(sizeof(ORUInt)*wordLength);
   //operand[i] = y << i;
   
   //   NSLog(@"\n%@\n%@\n%@",_x,_y,_z);
   //   NSLog(@"Multiplication Partial Products");
   //TODO:if any bit set in partial product... corresponding bit in y must be 1
   ORUInt anyBitSet;
   for(int i=0; i<_opLength;i++){
      anyBitSet = 0;
      [_partialProduct[i] getUp:&tempUp andLow:&tempLow];
      for (int j=0; j<wordLength; j++) {
         anyBitSet |= tempLow[j]._val;
      }
      //      NSLog(@"%@",_partialProduct[i]);
      if (anyBitSet || (boundUp[i/BITSPERWORD]) & (0x1 << (i%BITSPERWORD))) {
         //         if (anyBitSet) {
         //            NSLog(@"BitMult");
         //         }
         //         [engine addInternal:[[CPBitShiftL alloc] initCPBitShiftL:_x shiftLBy:i equals:_partialProduct[i]]];
         ORUInt places = i;
         for(int x=0;x<wordLength;x++){
            if (places == 0) {
               newUp[x] = xUp[x]._val & tempUp[x]._val;
               newLow[x] = xLow[x]._val | tempLow[x]._val;
            }
            else
               if ((int)(x-(((int)places)/BITSPERWORD)) >= 0) {
                  newUp[x] = ~(ISFALSE(tempUp[x]._val,tempLow[x]._val)|((ISFALSE(xUp[x-places/BITSPERWORD]._val, xLow[x-places/BITSPERWORD]._val)<<(places%BITSPERWORD))));
                  newLow[x] = ISTRUE(tempUp[x]._val,tempLow[x]._val)|((ISTRUE(xUp[x-places/BITSPERWORD]._val, xLow[x-places/BITSPERWORD]._val)<<(places%BITSPERWORD)));
                  //         NSLog(@"i=%i",i+_places/32);
                  if((int)(x-(((int)places)/BITSPERWORD)-1) >= 0) {
                     newUp[x] &= ~(ISFALSE(xUp[x-places/BITSPERWORD-1]._val, xLow[x-places/BITSPERWORD-1]._val)>>(BITSPERWORD-(places%BITSPERWORD)));
                     newLow[x] |= ISTRUE(xUp[x-places/BITSPERWORD-1]._val, xLow[x-places/BITSPERWORD-1]._val)>>(BITSPERWORD-(places%BITSPERWORD));
                     //            NSLog(@"i=%i",i+_places/32+1);
                  }
                  else {
                     newUp[x] &= ~(UP_MASK >> (BITSPERWORD-(places%BITSPERWORD)));
                     newLow[x] &= ~(UP_MASK >> (BITSPERWORD-(places%BITSPERWORD)));
                  }
               }
               else{
                  newUp[x] = 0;
                  newLow[x] = 0;
               }
         }
         _state[i*2] = alloca(sizeof(ORUInt)*wordLength);
         _state[i*2+1] = alloca(sizeof(ORUInt)*wordLength);
         for(int x=0;x<wordLength;x++){
            _state[i*2][x] = newUp[x];
            _state[i*2+1][x] = newLow[x];
         }
         if(checkDomainConsistency(_partialProduct[i], newLow, newUp, wordLength, self))
            failNow();
         [_partialProduct[i] setUp:newUp andLow:newLow for:self];
      }
      else if((boundLow[i/BITSPERWORD]) & (0x1 << (i%BITSPERWORD))) {
         //         [_partialProduct[i] getUp:&tempUp andLow:&tempLow];
         for (int j=0; j<wordLength; j++) {
            newUp[j] = 0;
            newLow[j] = tempLow[j]._val;
         }
         _state[i*2] = alloca(sizeof(ORUInt)*wordLength);
         _state[i*2+1] = alloca(sizeof(ORUInt)*wordLength);
         for(int x=0;x<wordLength;x++){
            _state[i*2][x] = newUp[x];
            _state[i*2+1][x] = newLow[x];
         }
         if(checkDomainConsistency(_partialProduct[i], newLow, newUp, wordLength, self))
            failNow();
         [_partialProduct[i] setUp:newUp andLow:newLow for:self];
      }
      else{
         continue;
      }
      _state[i*2] = alloca(sizeof(ORUInt)*wordLength);
      _state[i*2+1] = alloca(sizeof(ORUInt)*wordLength);
      for(int x=0;x<wordLength;x++){
         _state[i*2][x] = newUp[x];
         _state[i*2+1][x] = newLow[x];
      }
      if(checkDomainConsistency(_partialProduct[i], newLow, newUp, wordLength, self))
         failNow();
      [_partialProduct[i] setUp:newUp andLow:newLow for:self];
   }
   //   for (int i=0; i<_opLength; i++) {
   //      NSLog(@"partial product [%d] = %@",i, _partialProduct[i]);
   //   }
   _state[_opLength*2] = newZUp;
   _state[_opLength*2+1] = newZLow;
   if(checkDomainConsistency(_z, newZLow, newZUp, wordLength, self))
      failNow();
   [_z setUp:newZUp andLow:newZLow for:self];
   
   //   NSLog(@"\t%@", _x);
   //   NSLog(@"x\t%@", _y);
   //   NSLog(@"=\t%@\n\n", _z);
   
}
- (void)visit:(ORVisitor *)visitor {
}

- (void)close {
}

@end

@implementation CPBitDistinct

-(id) initCPBitDistinct:(CPBitVarI*)x distinctFrom:(CPBitVarI*)y eval:(CPBitVarI*) z
{
   self = [super initCPBitCoreConstraint:[x engine]];
   _x = x;
   _y = y;
   _z = z;
   _state = malloc(sizeof(ORUInt*)*6);
   
   id<CPEngine> engine = [_x engine];
   
   ORUInt*   up;
   ORUInt*   low;
   
   up = malloc(sizeof(ORUInt));
   low = malloc(sizeof(ORUInt));
   
   *up = 0xFFFFFFFF;
   *low = 0x00000000;

   _equal = (CPBitVarI*)[CPFactory bitVar:engine withLow:low andUp:up andLength:1];

   return self;
}
-(NSString*) description
{
   NSMutableString* string = [NSMutableString stringWithString:[super description]];
   [string appendString:@" with "];
   [string appendString:[NSString stringWithFormat:@"%@, ",_x]];
   [string appendString:[NSString stringWithFormat:@"%@, ",_y]];
   [string appendString:[NSString stringWithFormat:@"and %@\n",_z]];
   
   return string;
}

- (void) dealloc
{
   [super dealloc];
   free(_state);
}

-(void) post
{
   id<CPEngine> engine = [_x engine];
   
   [engine addInternal:[CPFactory bitEqualb:_x equal:_y eval:_equal]];

   [engine addInternal:[CPFactory bitNotb: _equal eval:_z]];
}
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment
{
  //NSLog(@"Implication for 0x%lx[%u] = %@  traced back through %@", (unsigned long)assignment->var, assignment->index, (CPBitVarI*)assignment->var, self);

   return NULL;
}

- (CPBitAntecedents *)getAntecedents:(CPBitAssignment *)assignment {
   return NULL;
}


-(void) propagate{}
- (void)visit:(ORVisitor *)visitor {
}

- (void)close {
}

@end
