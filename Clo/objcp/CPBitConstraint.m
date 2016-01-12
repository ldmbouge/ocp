/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "CPBitConstraint.h"
#import "CPUKernel/CPEngineI.h"
//#import <CPUKernel/CPLearningEngineI.h>
#import "CPBitMacros.h"
#import "CPBitVarI.h"

#define ISTRUE(up, low) ((up) & (low))
#define ISFALSE(up, low) ((~up) & (~low))

//fix visited set 
void analyzeConflict(CPLearningEngineI* engine, CPBitAssignment* conflict, CPCoreConstraint* constraint)
{
//   NSLog(@"Starting analysis of conflict in %lx at index %d ...",conflict->var,conflict->index);
//   NSLog(@"%@",[engine model]);
   CPBitAssignment** queue;
   CPBitAssignment** visited;
   CPBitAssignment** conflictVars;
   CPBitAssignment* var;
   ORBool haveVisited = false;
   ORBool inQueue = false;
   
   CPBitAntecedents* antecedents = [constraint getAntecedentsFor:conflict];
   CPCoreConstraint* c = [(CPBitVarI*)conflict->var getImplicationForBit:conflict->index];
   if((c != NULL) && ((ORInt)c != -1)){
      CPBitAntecedents* moreAntecedents = [c getAntecedentsFor:conflict];
      CPBitAssignment** allAntecedents = malloc(sizeof(CPBitAssignment*)*(antecedents->numAntecedents+moreAntecedents->numAntecedents));
      for (int i=0; i<antecedents->numAntecedents; i++) {
         allAntecedents[i] = antecedents->antecedents[i];
      }
      for (int i = 0; i<moreAntecedents->numAntecedents; i++) {
         allAntecedents[antecedents->numAntecedents+i] = moreAntecedents->antecedents[i];
      }
      free(antecedents->antecedents);
      antecedents->antecedents = allAntecedents;
      antecedents->numAntecedents += moreAntecedents->numAntecedents;
      free(moreAntecedents->antecedents);
      free(moreAntecedents);
   }
   //else if conflict var was set by a choice (c==NULL) then add it to the queue
   else if (c==NULL){
      CPBitAssignment** allAntecedents = malloc(sizeof(CPBitAssignment*)*(antecedents->numAntecedents+1));
      for (int i=0; i<antecedents->numAntecedents; i++) {
         allAntecedents[i] = antecedents->antecedents[i];
      }
      allAntecedents[antecedents->numAntecedents] = conflict;
      //free(antecedents->antecedents);
      antecedents->antecedents = allAntecedents;
      antecedents->numAntecedents++;
   }
      
   if (!antecedents)
      return;
   
   ORUInt qcap = antecedents->numAntecedents > 8 ? antecedents->numAntecedents : 8;
   ORUInt vcap = 8;
   
   ORUInt qfront = -1;
   ORUInt qback = -1;
   ORUInt vsize = 0;
   
   queue = alloca(sizeof(CPBitAssignment*)*qcap);
   visited = alloca(sizeof(CPBitAssignment*)*vcap);
   
   
   ORUInt capConflictVars = 8;
   ORUInt numConflictVars = 0;
   conflictVars  = alloca(sizeof(CPBitAssignment)*capConflictVars);

   
   //Add antecedents of conflict variable to the queue
   for (int i = 0; i<antecedents->numAntecedents; i++){
      if (!antecedents->antecedents[i]) {
         continue;
      }
      qback=(qback+1);
      queue[qback%qcap] = antecedents->antecedents[i];
      if(qfront==-1)
         qfront=qback;
   }
   
   //add conflict variable/index to the visited list
//   visited[0] = conflict;
//   vsize++;

   
   while (qfront != -1){
      //remove bit assignment from queue
      var = (queue[qfront%qcap]);

      if(qfront==qback)
         qfront=qback=-1;
      else
         qfront++;
      
      if(!var)
         continue;
      
      haveVisited=false;
      
      //check if we visited this assignment already
      for (int v = 0; v < vsize; v++) {
         if((var->var == visited[v]->var) &&
            (var->index == visited[v]->index))
         {
            haveVisited = true;
            break;
         }
         
      }
//      if (haveVisited || [var->var isFree:var->index]){
      //may not be officially set if based on uncommitted changes
      if (haveVisited){
         //free(var);
         continue;
      }
      //Add to list of visited bit assignments
      if(vsize >= vcap){
         CPBitAssignment** newVisited = alloca(sizeof(CPBitAssignment*)*vcap*2);
         for (int j = 0; j<vsize; j++) {
            newVisited[j] = visited[j];
         }
         vcap *= 2;
         visited = newVisited;
      }

      visited[vsize] = var;
      vsize++;
      
//      NSLog(@"Processing 0x%lx[%d] from queue.",var->var, var->index);
      //If this bit was set by a choice in search
      if (([var->var getImplicationForBit:var->index] == NULL) && ([var->var getLevelBitWasSet:var->index] != -1)){
      
         if (numConflictVars >= capConflictVars) {
            CPBitAssignment** newArray = alloca(sizeof(CPBitAssignment*)*capConflictVars*2);
            for (int j = 0; j<numConflictVars; j++) {
               newArray[j] = conflictVars[j];
            }
            capConflictVars *= 2;
            conflictVars = newArray;
         }
         conflictVars[numConflictVars] = var;
         numConflictVars++;
      }
      //if bit was set by another constraint
      else if ([var->var getImplicationForBit:var->index] != NULL) {
         //getImplicationForBit returns a constraint... must extract the other bitvars involved in the constraint
         id<CPConstraint> c = [var->var getImplicationForBit:var->index];
         CPBitAntecedents* a = (CPBitAntecedents*)[c getAntecedentsFor:var];
         if (a==NULL || a->numAntecedents == 0) {
            continue;
         }
         for (int j = 0; j<a->numAntecedents; j++) {
            haveVisited = false;
            inQueue = false;
            for (int k=0; k<vsize; k++) {
               if((a->antecedents[j]->var == visited[k]->var) &&
                  (a->antecedents[j]->index == visited[k]->index))
                  //is checking value necessary?
                  //(a->antecedents[j]->value == visited[k]->value))
//                  free(a->antecedents[j]);
                  haveVisited = true;
            }
            if(qfront != qback){
               for (int k=qfront; k<=qback; k++) {
                  if ((a->antecedents[j]->var == queue[k%qcap]->var) &&
                      (a->antecedents[j]->index == queue[k%qcap]->index)){
                     inQueue = true;
                     break;
                  }
               }
            }
            if (!haveVisited && !inQueue) {//add antecedent to queue
               //expand queue if full
               if (((qback-qfront)%qcap)+1 == qcap) {
                  CPBitAssignment** newQueue = alloca(sizeof(CPBitAssignment*)*qcap*2);

                  for(int k=0;k<qcap;k++)
                     newQueue[k] = queue[(k+qfront)%qcap];
                  queue=newQueue;
                  qfront=0;
                  qback=qcap-1;
                  qcap *= 2;
               }
//               NSLog(@"Adding 0x%lx[%d] to the queue.",a->antecedents[j]->var, a->antecedents[j]->index);
               qback=(qback+1);
               queue[qback%qcap] = a->antecedents[j];
               if(qfront==-1)
                  qfront=qback;
            }
         }
//         free(a);
//         free(var);
      }
//      else{
         //Bit assignment was made a priori of search
         //NSLog(@"No implication but level is not default %lx",var->var);
         //free(var);
//      }
   }
   
   if (numConflictVars > 0) {
//      NSLog(@"Adding constraint to constraint store\n");
      CPBitAntecedents* final = malloc(sizeof(CPBitAntecedents));
      CPBitAssignment** finalVars = malloc(sizeof(CPBitAssignment*)*(numConflictVars));
      for (int i=0; i<numConflictVars; i++) {
         finalVars[i] = conflictVars[i];
//         NSLog(@"\tVariable 0x%lx[%d]=%d\t\t%@",finalVars[i]->var,finalVars[i]->index,finalVars[i]->value, finalVars[i]->var);
//         if((conflictVars[i]->var == conflict->var) && (conflictVars[i]->index == conflict->index))
//            NSLog(@"Conflict constraint includes conflict variable and index");
      }
      final->antecedents = finalVars;
      final->numAntecedents = numConflictVars;
      CPCoreConstraint* c = [CPFactory bitConflict:final];
      [(CPLearningEngineI*)engine addConstraint:c];
   }
//   else
//      NSLog(@"No choices found in tracing back antecedents");
   
//   for (int i=0; i<antecedents->numAntecedents; i++) {
//      free(antecedents->antecedents[i]);
//   }
//   NSLog(@"Analysis complete.");
//   NSLog(@"%d nodes visited.",vsize);
}

ORBool checkDomainConsistency(CPBitVarI* var, unsigned int* low, unsigned int* up, ORUInt len, CPCoreConstraint* constraint)
{
   ORUInt upXORlow;
   ORUInt mask;
   ORBool isConflict = false;
   
   unsigned int* conflicts = alloca(sizeof(unsigned int)*len);
   
   for (int i=0; i<len; i++) {
      upXORlow = up[i] ^ low[i];
      conflicts[i] = (upXORlow&(~up[i]))&(upXORlow & low[i]);
      if (conflicts[i]) {
         isConflict = true;
         //analyze all conflicts in this "word" of the bit vector
         mask = 0x1;
         for(int j=0;j<BITSPERWORD;j++){
            if (mask & conflicts[i]) {
               CPBitAssignment* a = malloc(sizeof(CPBitAssignment));
               a->var = var;
               a->index = i*BITSPERWORD+j;
//               NSLog(@"Analyzing conflict in constraint %@ for variable %lx[%d]",constraint,a->var,a->index);
//               NSLog(@"\tAntecedents:");
//               for (int x=0; x<conflictAntecedents->numAntecedents; x++) {
//                  NSLog(@"\t\tVariable 0x%lx[%d]=%@",conflictAntecedents->antecedents[x]->var,conflictAntecedents->antecedents[x]->index,conflictAntecedents->antecedents[x]->var);
//               }
               analyzeConflict((CPLearningEngineI*)[var engine], a, constraint);
            }
            mask <<=1;
         }
         
      }
   }
   if(isConflict)
      failNow();
   
   return isConflict;
}

NSString* bitvar2NSString(unsigned int* low, unsigned int* up, int wordLength)
{
   NSMutableString* string = [[NSMutableString alloc] init];
   for(int i=wordLength-1; i>=0;i--){
      unsigned int boundLow = ~low[i] & ~ up[i];
      unsigned int boundUp = up[i] & low[i];
      unsigned int err = ~up[i] & low[i];
      unsigned int mask = CP_DESC_MASK;
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
   return string;
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
+(id<CPConstraint>) bitEqual:(CPBitVarI*)x to:(CPBitVarI*)y
{
   id<CPConstraint> o = [[CPBitEqual alloc] initCPBitEqual:x and:y];
   [[x engine] trackMutable:o];
   return o;
}

+(id<CPConstraint>) bitAND:(CPBitVarI*)x and:(CPBitVarI*)y equals:(CPBitVarI*)z
{
   id<CPConstraint> o = [[CPBitAND alloc] initCPBitAND:x and:y equals:z];
   [[x engine] trackMutable:o];
   return o;
}

+(id<CPConstraint>) bitOR:(CPBitVarI*)x or:(CPBitVarI*) y equals:(CPBitVarI*)z
{
   id<CPConstraint> o = [[CPBitOR alloc] initCPBitOR:x or:y equals:z];
   [[x engine] trackMutable:o];
   return o;
}
+(id<CPConstraint>) bitXOR:(CPBitVarI*)x xor:(CPBitVarI*)y equals:(CPBitVarI*) z
{
   id<CPConstraint> o = [[CPBitXOR alloc] initCPBitXOR:x xor:y equals:z];
   [[x engine] trackMutable:o];
   return o;
   
}
+(id<CPConstraint>) bitNOT:(CPBitVarI*)x equals:(CPBitVarI*) y
{
   id<CPConstraint> o = [[CPBitNOT alloc] initCPBitNOT:x equals:y];
   [[x engine] trackMutable:o];
   return o;
   
}

+(id<CPConstraint>) bitShiftL:(CPBitVarI*)x by:(int) p equals:(CPBitVarI*) y
{
   id<CPConstraint> o = [[CPBitShiftL alloc] initCPBitShiftL:x shiftLBy:p equals:y];
   [[x engine] trackMutable:o];
   return o;
}

+(id<CPConstraint>) bitShiftR:(CPBitVarI*)x by:(int) p equals:(CPBitVarI*) y
{
   id<CPConstraint> o = [[CPBitShiftR alloc] initCPBitShiftR:x shiftRBy:p equals:y];
   [[x engine] trackMutable:o];
   return o;
}

+(id<CPConstraint>) bitRotateL:(CPBitVarI*)x by:(int) p equals:(CPBitVarI*) y
{
   id<CPConstraint> o = [[CPBitRotateL alloc] initCPBitRotateL:x rotateLBy:p equals:y];
   [[x engine] trackMutable:o];
   return o;
   
}

+(id<CPConstraint>) bitADD:(id<CPBitVar>)x plus:(id<CPBitVar>) y withCarryIn:(id<CPBitVar>) cin equals:(id<CPBitVar>) z withCarryOut:(id<CPBitVar>) cout
{
   id<CPConstraint> o = [[CPBitADD alloc] initCPBitAdd:(CPBitVarI*)x
                                                  plus:(CPBitVarI*)y
                                                equals:(CPBitVarI*)z
                                           withCarryIn:(CPBitVarI*)cin
                                           andCarryOut:(CPBitVarI*)cout];
   [[x engine] trackMutable:o];
   return o;
}

+(id<CPConstraint>) bitIF:(id<CPBitVar>)w equalsOneIf:(id<CPBitVar>)x equals:(id<CPBitVar>)y andZeroIfXEquals:(id<CPBitVar>) z
{
   id<CPConstraint> o = [[CPBitIF alloc] initCPBitIF:(CPBitVarI*)w
                                         equalsOneIf:(CPBitVarI*)x
                                              equals:(CPBitVarI*)y
                                    andZeroIfXEquals:(CPBitVarI*)z];
   [[x engine] trackMutable:o];
   return o;
}
+(id<CPConstraint>) bitCount:(id<CPBitVar>)x count:(id<CPIntVar>)p
{
   id<CPConstraint> o = [[CPBitCount alloc] initCPBitCount:(CPBitVarI*)x count:(CPIntVarI*)p];
   [[x engine] trackMutable:o];
   return o;
}
+(id<CPConstraint>) bitZeroExtend:(id<CPBitVar>)x extendTo:(id<CPBitVar>)y
{
   id<CPConstraint> o = [[CPBitZeroExtend alloc] initCPBitZeroExtend:(CPBitVarI*)x extendTo:(CPBitVarI*)y];
   [[x engine] trackMutable:o];
   return o;
}
+(id<CPConstraint>) bitConcat:(id<CPBitVar>)x concat:(id<CPBitVar>)y eq:(id<CPBitVar>)z
{
   id<CPConstraint> o = [[CPBitConcat alloc] initCPBitConcat:(CPBitVarI*)x concat:(CPBitVarI*)y eq:(CPBitVarI*)z];
   [[x engine] trackMutable:o];
   return o;
}
+(id<CPConstraint>) bitExtract:(id<CPBitVar>)x from:(ORUInt)lsb to:(ORUInt)msb eq:(id<CPBitVar>)y
{
   id<CPConstraint> o = [[CPBitExtract alloc] initCPBitExtract:(CPBitVarI*)x from:lsb to:msb eq:(CPBitVarI*)y];
   [[x engine] trackMutable:o];
   return o;
}
+(id<CPConstraint>) bitLogicalEqual:(id<CPBitVar>)x EQ:(id<CPBitVar>)y eval:(id<CPBitVar>) z
{
   id<CPConstraint> o = [[CPBitLogicalEqual alloc] initCPBitLogicalEqual:(CPBitVarI*)x EQ:(CPBitVarI*)y eval:(CPBitVarI*)z];
   [[x engine] trackMutable:o];
   return o;
   
}
+(id<CPConstraint>) bitLT:(id<CPBitVar>)x LT:(id<CPBitVar>)y eval:(id<CPBitVar>) z
{
   id<CPConstraint> o = [[CPBitLT alloc] initCPBitLT:(CPBitVarI*)x LT:(CPBitVarI*)y eval:(CPBitVarI*)z];
   [[x engine] trackMutable:o];
   return o;
   
}
+(id<CPConstraint>) bitLE:(id<CPBitVar>)x LE:(id<CPBitVar>)y eval:(id<CPBitVar>) z
{
   id<CPConstraint> o = [[CPBitLE alloc] initCPBitLE:(CPBitVarI*)x LE:(CPBitVarI*)y eval:(CPBitVarI*)z];
   [[x engine] trackMutable:o];
   return o;
}
+(id<CPConstraint>) bitITE:(id<CPBitVar>)i then:(id<CPBitVar>)t else:(id<CPBitVar>)e result:(id<CPBitVar>)r
{
   id<CPConstraint> o = [[CPBitITE alloc] initCPBitITE:(CPBitVarI*)i then:(CPBitVarI*)t else:(CPBitVarI*)e result:(CPBitVarI*)r];
   [[i engine] trackMutable:o];
   return o;
}
+(id<CPConstraint>) bitLogicalAnd:(id<CPBitVarArray>)x eval:(CPBitVarI*)r
{
   id<CPConstraint> o = [[CPBitLogicalAnd alloc] initCPBitLogicalAnd:x eval:r];
   [[x[0] engine] trackMutable:o];
   return o;
}
+(id<CPConstraint>) bitLogicalOr:(id<CPBitVarArray>)x eval:(CPBitVarI*)r
{
   id<CPConstraint> o = [[CPBitLogicalOr alloc] initCPBitLogicalOr:x eval:r];
   [[x[0] engine] trackMutable:o];
   return o;
}
+(id<CPConstraint>) bitConflict:(CPBitAntecedents*)a
{
   id<CPConstraint> o = [[CPBitConflict  alloc] initCPBitConflict:a];

   [[a->antecedents[0]->var engine] trackMutable:o];
   return o;
}
+(id<CPConstraint>) bitORb:(CPBitVarI*)x or:(CPBitVarI*) y eval:(CPBitVarI*)r
{
   id<CPConstraint> o = [[CPBitORb alloc] initCPBitORb:x or:y eval:r];
   [[x engine] trackMutable:o];
   return o;
}
+(id<CPConstraint>) bitNotb:(CPBitVarI*)x eval:(CPBitVarI*)r
{
   id<CPConstraint> o = [[CPBitNotb alloc] initCPBitNotb:x eval:r];
   [[x engine] trackMutable:o];
   return o;
}
+(id<CPConstraint>) bitEqualb:(CPBitVarI*)x equal:(CPBitVarI*) y eval:(CPBitVarI*)r
{
   id<CPConstraint> o = [[CPBitEqualb alloc] initCPBitEqualb:x equals:y eval:r];
   [[x engine] trackMutable:o];
   return o;
}

@end

@implementation CPBitEqual

-(id) initCPBitEqual:(CPBitVarI*) x and:(CPBitVarI*) y
{
   self = [super initCPCoreConstraint: [x engine]];
   _x = x;
   _y = y;
   return self;
}

- (void) dealloc
{
   [super dealloc];
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
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment
{
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
   self = [super initCPCoreConstraint:[x engine]];
   _x = x;
   _y = y;
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
}
-(NSSet*) allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y, nil] autorelease];
}
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment
{
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
         uint32 bitMask = CP_UMASK >> (32 - ([_x bitLength] % 32));
         newXUp[i] &= bitMask;
         newXLow[i] &= bitMask;
         newYUp[i] &= bitMask;
         newYLow[i] &= bitMask;
      }
   }
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
-(id) initCPBitAND:(CPBitVarI*)x and:(CPBitVarI*)y equals:(CPBitVarI*)z{
   self = [super initCPCoreConstraint:[x engine]];
   _x = x;
   _y = y;
   _z = z;
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
}
-(NSSet*) allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y, _z, nil] autorelease];
}
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment
{
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
-(id) initCPBitOR:(CPBitVarI*)x or:(CPBitVarI*)y equals:(CPBitVarI*)z{
   self = [super initCPCoreConstraint:[x engine]];
   _x = x;
   _y = y;
   _z = z;
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
}
-(NSSet*) allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y, _z, nil] autorelease];
}
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment
{
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
-(id) initCPBitXOR:(CPBitVarI*)x xor:(CPBitVarI*)y equals:(CPBitVarI*)z{
   self = [super initCPCoreConstraint:[x engine]];
   _x = x;
   _y = y;
   _z = z;
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
}
-(NSSet*) allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y, _z, nil] autorelease];
}
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment
{
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
   ORBool fail = false;
   
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
   self = [super initCPCoreConstraint:[x engine]];
   _w = w;
   _x = x;
   _y = y;
   _z = z;
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
- (void) dealloc
{
   [super dealloc];
}
-(NSSet*) allVars
{
   return [[[NSSet alloc] initWithObjects:_w,_x,_y, _z, nil] autorelease];
}

-(void) post
{
   [self propagate];
   //<<<<<<< HEAD
   //   if (![_w bound])
   //      [_w whenChangePropagate: self];
   //   if (![_x bound])
   //      [_x whenChangePropagate: self];
   //   if (![_y bound])
   //      [_y whenChangePropagate: self];
   //   if (![_z bound])
   //      [_z whenChangePropagate: self];
   //////   if (![_x bound] || ![_y bound]) {
   ////   if (![_x bound] || ![_y bound] || ![_z bound] || ![_w bound]) {\
   ////      //_w added by GAJ on 11/29/12
   ////      [_w whenBitFixed: self at: HIGHEST_PRIO do: ^() { [self propagate];} ];
   ////      [_x whenBitFixed: self at: HIGHEST_PRIO do: ^() { [self propagate];} ];
   ////      [_y whenBitFixed: self at: HIGHEST_PRIO do: ^() { [self propagate];} ];
   ////      [_z whenBitFixed: self at: HIGHEST_PRIO do: ^() { [self propagate];} ];
   ////   }
   ////   [self propagate];
   //   return ORSuspend;
   //=======
   ////   if (![_x bound] || ![_y bound]) {
   if (![_x bound] || ![_y bound] || ![_z bound] || ![_w bound]) {
      //_w added by GAJ on 11/29/12
      [_w whenBitFixed: self at: HIGHEST_PRIO do: ^() { [self propagate];} ];
      [_x whenBitFixed: self at: HIGHEST_PRIO do: ^() { [self propagate];} ];
      [_y whenBitFixed: self at: HIGHEST_PRIO do: ^() { [self propagate];} ];
      [_z whenBitFixed: self at: HIGHEST_PRIO do: ^() { [self propagate];} ];
   }
   [self propagate];
   //>>>>>>> master
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
@end

@implementation CPBitShiftL
-(id) initCPBitShiftL:(CPBitVarI*)x shiftLBy:(int)places equals:(CPBitVarI*)y{
   self = [super initCPCoreConstraint:[x engine]];
   _x = x;
   _y = y;
   _places = places;
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
}
-(NSSet*) allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y, nil] autorelease];
}
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment
{
   CPBitAntecedents* ants = malloc(sizeof(CPBitAntecedents));
   CPBitAssignment** vars;
   vars  = malloc(sizeof(CPBitAssignment*));
   ants->numAntecedents = 0;

   ORInt index = assignment->index;
   ants->antecedents = vars;
   
   ORUInt len = [_x bitLength];
   
   if (assignment->var == _x) {
      index = assignment->index + _places;
      if((index < len) && ![_y isFree:index]){
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _y;
         vars[ants->numAntecedents]->index = index;
         vars[ants->numAntecedents]->value = [_y getBit:index];
         ants->numAntecedents++;
      }
   }
   else{
      index = assignment->index -_places;
      if ((index >= 0) && ![_x isFree:index]) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _x;
         vars[ants->numAntecedents]->index = index;
         vars[ants->numAntecedents]->value = [_x getBit:index];
         ants->numAntecedents++;
      }
   }
//   if(ants->numAntecedents==0)
//      NSLog(@"Empty antecedents\n");
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
   
   
   for(int i=0;i<wordLength;i++){
      if ((i+_places/32) < wordLength) {
         newYUp[i] = ~(ISFALSE(yUp[i]._val,yLow[i]._val)|((ISFALSE(xUp[i+_places/32]._val, xLow[i+_places/32]._val)<<(_places%32))));
         newYLow[i] = ISTRUE(yUp[i]._val,yLow[i]._val)|((ISTRUE(xUp[i+_places/32]._val, xLow[i+_places/32]._val)<<(_places%32)));
         //         NSLog(@"i=%i",i+_places/32);
         if((i+_places/32+1) < wordLength) {
            newYUp[i] &= ~(ISFALSE(xUp[i+_places/32+1]._val, xLow[i+_places/32+1]._val)>>(32-(_places%32)));
            newYLow[i] |= ISTRUE(xUp[i+_places/32+1]._val, xLow[i+_places/32+1]._val)>>(32-(_places%32));
            //            NSLog(@"i=%i",i+_places/32+1);
         }
         else{
            newYUp[i] &= ~(UP_MASK >> (32-(_places%32)));
            newYLow[i] &= ~(UP_MASK >> (32-(_places%32)));
         }
      }
      else{
         newYUp[i] = 0;
         newYLow[i] = 0;
      }
      
      if ((i-(int)_places/32) >= 0) {
         newXUp[i] = ~(ISFALSE(xUp[i]._val,xLow[i]._val)|((ISFALSE(yUp[i-_places/32]._val, yLow[i-_places/32]._val)>>(_places%32))));
         newXLow[i] = ISTRUE(xUp[i]._val,xLow[i]._val)|((ISTRUE(yUp[i-_places/32]._val, yLow[i-_places/32]._val)>>(_places%32)));
         //         NSLog(@"i=%i",i-_places/32);
         if((i-(int)_places/32-1) >= 0) {
            newXUp[i] &= ~(ISFALSE(yUp[(i-(int)_places/32-1)]._val,yLow[(i-(int)_places/32-1)]._val)<<(32-(_places%32)));
            newXLow[i] |= ISTRUE(yUp[(i-(int)_places/32-1)]._val,yLow[(i-(int)_places/32-1)]._val)<<(32-(_places%32));
            //            NSLog(@"i=%i",i-(int)_places/32-1);
         }
      }
      else{
         newXUp[i] = xUp[i]._val;
         newXLow[i] = xLow[i]._val;
      }

   }

   ORBool xFail = checkDomainConsistency(_x, newXLow, newXUp, wordLength, self);
   ORBool yFail = checkDomainConsistency(_y, newYLow, newYUp, wordLength, self);
   if ( xFail || yFail) {
      failNow();
   }
   
   [_x setUp:newXUp andLow:newXLow for:self];
   [_y setUp:newYUp andLow:newYLow for:self];
}
@end

@implementation CPBitShiftR
-(id) initCPBitShiftR:(CPBitVarI*)x shiftRBy:(int)places equals:(CPBitVarI*)y{
   self = [super initCPCoreConstraint:[x engine]];
   _x = x;
   _y = y;
   _places = places;
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
}
-(NSSet*) allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y, nil] autorelease];
}
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment
{
   CPBitAntecedents* ants = malloc(sizeof(CPBitAntecedents));
   CPBitAssignment** vars;
   vars  = malloc(sizeof(CPBitAssignment*));
   ants->numAntecedents = 0;

   ORInt index = assignment->index;
   ants->antecedents = vars;
   
   ORUInt len = [_x bitLength];
   
   if (assignment->var == _x) {
      index = assignment->index -_places;
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
   }
//   if(ants->numAntecedents==0)
//      NSLog(@"Empty antecedents\n");
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
   
   ORBool xFail = checkDomainConsistency(_x, newXLow, newXUp, wordLength, self);
   ORBool yFail = checkDomainConsistency(_y, newYLow, newYUp, wordLength, self);
   if ( xFail || yFail) {
      failNow();
   }
   
   [_x setUp:newXUp andLow:newXLow for:self];
   [_y setUp:newYUp andLow:newYLow for:self];
}
@end

@implementation CPBitRotateL
-(id) initCPBitRotateL:(CPBitVarI*)x rotateLBy:(int)places equals:(CPBitVarI*)y{
   self = [super initCPCoreConstraint:[x engine]];
   _x = x;
   _y = y;
   _places = places;
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
}
-(NSSet*) allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y, nil] autorelease];
}
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment
{
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
//   if(ants->numAntecedents==0)
//      NSLog(@"Empty antecedents\n");
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
   
   TRUInt* xLow;
   TRUInt* xUp;
   TRUInt* yLow;
   TRUInt* yUp;
   
   [_x getUp:&xUp andLow:&xLow];
   [_y getUp:&yUp andLow:&yLow];
   
   
   unsigned int* newXUp = alloca((sizeof(unsigned int))*wordLength);
   unsigned int* newXLow  = alloca((sizeof(unsigned int))*wordLength);
   unsigned int* newYUp = alloca((sizeof(unsigned int))*wordLength);
   unsigned int* newYLow  = alloca((sizeof(unsigned int))*wordLength);
   
#ifdef BIT_DEBUG
   NSLog(@"         X =%@",_x);
   NSLog(@" ROTL %d  Y =%@",_places,_y);
#endif
   
   for(int i=0;i<wordLength;i++){
      newYUp[i] = ~(ISFALSE(yUp[i]._val,yLow[i]._val) | (ISFALSE(xUp[(i+(_places/32))%wordLength]._val, xLow[(i+(_places/32))%wordLength]._val) << _places%32)
                    | (ISFALSE(xUp[(i+(_places/32)+1)%wordLength]._val, xLow[(i+(_places/32)+1)%wordLength]._val) >> (32-(_places%32))));
      
      newYLow[i] = ISTRUE(yUp[i]._val,yLow[i]._val)   | (ISTRUE(xUp[(i+(_places/32))%wordLength]._val, xLow[(i+(_places/32))%wordLength]._val) << _places%32)
      | (ISTRUE(xUp[(i+(_places/32)+1)%wordLength]._val, xLow[(i+(_places/32)+1)%wordLength]._val) >> (32-(_places%32)));
      
      newXUp[i] = ~(ISFALSE(xUp[i]._val,xLow[i]._val) | (ISFALSE(yUp[(i-(_places/32))%wordLength]._val, yLow[(i-(_places/32))%wordLength]._val) >> _places%32)
                    | (ISFALSE(yUp[(i-(_places/32)-1)%wordLength]._val, yLow[(i-(_places/32)-1)%wordLength]._val) << (32-(_places%32))));
      
      newXLow[i] = ISTRUE(xUp[i]._val,xLow[i]._val)   | (ISTRUE(yUp[(i-(_places/32))%wordLength]._val, yLow[(i-(_places/32))%wordLength]._val) >> _places%32)
      | (ISTRUE(yUp[(i-(_places/32)-1)%wordLength]._val, yLow[(i-(_places/32)-1)%wordLength]._val) << (32-(_places%32)));
      
   }
   
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

@implementation CPBitADD
-(id) initCPBitAdd:(id<CPBitVar>)x plus:(id<CPBitVar>)y equals:(id<CPBitVar>)z withCarryIn:(id<CPBitVar>)cin andCarryOut:(id<CPBitVar>)cout
{
   self = [super initCPCoreConstraint:[x engine]];
   _x = (CPBitVarI*)x;
   _y = (CPBitVarI*)y;
   _z = (CPBitVarI*)z;
   _cin = (CPBitVarI*)cin;
   _cout = (CPBitVarI*)cout;
   return self;
}
-(NSString*) description
{
   NSMutableString* string = [NSMutableString stringWithString:[super description]];
   [string appendString:@" with "];
   [string appendString:[NSString stringWithFormat:@"%@ ",_x]];
   [string appendString:[NSString stringWithFormat:@"and %@ ",_y]];
   [string appendString:[NSString stringWithFormat:@"and %@\n",_z]];
   
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
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment
{
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
   if(ants->numAntecedents==0)
      NSLog(@"Unable to find antecedents in CPBitADD constraint");
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
   bool change = true;
   
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
   //   NSLog(@" Cin  =%@",bitvar2NSString(prevCinLow,prevCinUp, wordLength));
   //   NSLog(@" X    =%@",bitvar2NSString(prevXLow, prevXUp, wordLength));
   //   NSLog(@"+Y    =%@",bitvar2NSString(prevYLow, prevYUp, wordLength));
   //   NSLog(@"_______________________________________________________");
   //   NSLog(@" Z    =%@",bitvar2NSString(prevZLow, prevZUp, wordLength));
   //   NSLog(@" Cout =%@\n\n",bitvar2NSString(prevCoutLow, prevCoutUp, wordLength));
   
   
   while (change) {
      
      //       NSLog(@"propagating sum constraint");
      //       NSLog(@" Cin  =%@",bitvar2NSString(prevCinLow,prevCinUp, wordLength));
      //       NSLog(@" X    =%@",bitvar2NSString(prevXLow, prevXUp, wordLength));
      //       NSLog(@"+Y    =%@",bitvar2NSString(prevYLow, prevYUp, wordLength));
      //       NSLog(@"_______________________________________________________");
      //       NSLog(@" Z    =%@",bitvar2NSString(prevZLow, prevZUp, wordLength));
      //       NSLog(@" Cout =%@\n\n",bitvar2NSString(prevCoutLow, prevCoutUp, wordLength));
      
      change = false;
      //      NSLog(@"top of iteration for sum constraint");
      //             NSLog(@" Cin  =%@",bitvar2NSString(prevCinLow,prevCinUp, wordLength));
      //             NSLog(@" X    =%@",bitvar2NSString(prevXLow, prevXUp, wordLength));
      //             NSLog(@"+Y    =%@",bitvar2NSString(prevYLow, prevYUp, wordLength));
      //             NSLog(@"_______________________________________________________");
      //             NSLog(@" Z    =%@",bitvar2NSString(prevZLow, prevZUp, wordLength));
      //             NSLog(@" Cout =%@\n\n",bitvar2NSString(prevCoutLow, prevCoutUp, wordLength));
      ORBool xFail = checkDomainConsistency(_x, newXLow, newXUp, wordLength, self);
      
      ORBool yFail = checkDomainConsistency(_y, newYLow, newYUp, wordLength, self);
      
      ORBool zFail = checkDomainConsistency(_z, newZLow, newZUp, wordLength, self);

      ORBool cinFail = checkDomainConsistency(_cin, newCinLow, newCinUp, wordLength, self);
      
      ORBool coutFail = checkDomainConsistency(_cout, newCoutLow, newCoutUp, wordLength, self);

      if (xFail || yFail || zFail || cinFail || coutFail){
#ifdef BIT_DEBUG
         NSLog(@"Inconsistency in Bitwise sum constraint in (shifted) Carry In.\n");
         
         NSLog(@" Cin  =%@",bitvar2NSString(prevCinLow,prevCinUp, wordLength));
         NSLog(@" X    =%@",bitvar2NSString(prevXLow, prevXUp, wordLength));
         NSLog(@"+Y    =%@",bitvar2NSString(prevYLow, prevYUp, wordLength));
         NSLog(@"_______________________________________________________");
         NSLog(@" Z    =%@",bitvar2NSString(prevZLow, prevZUp, wordLength));
         NSLog(@" Cout =%@\n\n",bitvar2NSString(prevCoutLow, prevCoutUp, wordLength));
         
         NSLog(@" Cin  =%@",bitvar2NSString(shiftedCinLow,shiftedCinUp, wordLength));
         NSLog(@" X    =%@",bitvar2NSString(prevXLow, prevXUp, wordLength));
         NSLog(@"+Y    =%@",bitvar2NSString(prevYLow, prevYUp, wordLength));
         NSLog(@"_______________________________________________________");
         NSLog(@" Z    =%@",bitvar2NSString(prevZLow, prevZUp, wordLength));
         NSLog(@" Cout =%@\n\n",bitvar2NSString(shiftedCoutLow, shiftedCoutUp, wordLength));
#endif
          failNow();
      }
      
      
      //No failure, save intermediate state of variables
      [_x setUp:newXUp andLow:newXLow for:self];
      [_y setUp:newYUp andLow:newYLow for:self];
      [_z setUp:newZUp andLow:newZLow for:self];
      [_cin setUp:newCinUp andLow:newCinLow for:self];
      [_cout setUp:newCoutUp andLow:newCoutLow for:self];
      
      

      
      
      
      
      for(int i=0;i<wordLength;i++){
         //          NSLog(@"\ttop of shift iteration for sum constraint");
         //          NSLog(@"\t Cin  =%@",bitvar2NSString(prevCinLow,prevCinUp, wordLength));
         //          NSLog(@"\t X    =%@",bitvar2NSString(prevXLow, prevXUp, wordLength));
         //          NSLog(@"\t+Y    =%@",bitvar2NSString(prevYLow, prevYUp, wordLength));
         //          NSLog(@"\t_______________________________________________________");
         //          NSLog(@"\t Z    =%@",bitvar2NSString(prevZLow, prevZUp, wordLength));
         //          NSLog(@"\t Cout =%@\n\n",bitvar2NSString(prevCoutLow, prevCoutUp, wordLength));
         
         // Pasted shift constraint code to directly compute new CIN from the new COUT
         //          for(int j=0;j<wordLength;j++){
         if (i < wordLength) {
            shiftedCinUp[i] = ~(ISFALSE(prevCinUp[i],prevCinLow[i])|((ISFALSE(prevCoutUp[i], prevCoutLow[i])<<1)));
            shiftedCinLow[i] = ISTRUE(prevCinUp[i],prevCinLow[i])|(ISTRUE(prevCoutUp[i], prevCoutLow[i])<<1);
            //         NSLog(@"i=%i",i+1/32);
            if((i+1) < wordLength) {
               shiftedCinUp[i] &= ~(ISFALSE(prevCoutUp[i+1], prevCoutLow[i+1])>>31);
               shiftedCinLow[i] |= ISTRUE(prevCoutUp[i+1], prevCoutLow[i+1])>>31;
               //            NSLog(@"i=%i",i+1/32+1);
            }
            else{
               shiftedCinUp[i] &= ~(UP_MASK >> 31);
               shiftedCinLow[i] &= ~(UP_MASK >> 31);
            }
         }
         else{
            shiftedCinUp[i] = 0;
            shiftedCinLow[i] = 0;
         }
         
         if (i >= 0) {
            shiftedCoutUp[i] = ~(ISFALSE(prevCoutUp[i],prevCoutLow[i])|(ISFALSE(prevCinUp[i], prevCinLow[i])>>1));
            shiftedCoutLow[i] = ISTRUE(prevCoutUp[i],prevCoutLow[i])|(ISTRUE(prevCinUp[i], prevCinLow[i])>>1);
            //         NSLog(@"i=%i",i-1/32);
            if((i-1) >= 0) {
               shiftedCoutUp[i] &= ~(ISFALSE(prevCinUp[i-1],prevCinLow[i-1])<<31);
               shiftedCoutLow[i] |= ISTRUE(prevCinUp[i-1],prevCinLow[i-1])<<31;
               //            NSLog(@"i=%i",i-(int)_places/32-1);
            }
         }
         else{
            shiftedCoutUp[i] = prevCoutUp[i];
            shiftedCoutLow[i] = prevCoutLow[i];
         }
         change |= shiftedCinUp[i] ^ prevCinUp[i];
         change |= shiftedCinLow[i] ^ prevCinLow[i];
         change |= shiftedCoutUp[i] ^ prevCoutUp[i];
         change |= shiftedCoutLow[i] ^ prevCoutLow[i];
         
         //             //testing for internal consistency
         //             upXORlow = shiftedCinUp[i] ^ shiftedCinLow[i];
         //             inconsistencyFound |= (upXORlow&(~shiftedCinUp[i]))&(upXORlow & shiftedCinLow[i]);
         //#ifdef BIT_DEBUG
         //             if (inconsistencyFound){
         //                NSLog(@"Inconsistency in Bitwise sum constraint in (shifted) Carry In.\n");
         //
         //                          NSLog(@" Cin  =%@",bitvar2NSString(prevCinLow,prevCinUp, wordLength));
         //                          NSLog(@" X    =%@",bitvar2NSString(prevXLow, prevXUp, wordLength));
         //                          NSLog(@"+Y    =%@",bitvar2NSString(prevYLow, prevYUp, wordLength));
         //                          NSLog(@"_______________________________________________________");
         //                          NSLog(@" Z    =%@",bitvar2NSString(prevZLow, prevZUp, wordLength));
         //                          NSLog(@" Cout =%@\n\n",bitvar2NSString(prevCoutLow, prevCoutUp, wordLength));
         //
         //                          NSLog(@" Cin  =%@",bitvar2NSString(shiftedCinLow,shiftedCinUp, wordLength));
         //                          NSLog(@" X    =%@",bitvar2NSString(prevXLow, prevXUp, wordLength));
         //                          NSLog(@"+Y    =%@",bitvar2NSString(prevYLow, prevYUp, wordLength));
         //                          NSLog(@"_______________________________________________________");
         //                          NSLog(@" Z    =%@",bitvar2NSString(prevZLow, prevZUp, wordLength));
         //                          NSLog(@" Cout =%@\n\n",bitvar2NSString(shiftedCoutLow, shiftedCoutUp, wordLength));
         //                failNow();
         //          }
         //#endif
         
         prevCoutLow[i] = shiftedCoutLow[i];
         prevCoutUp[i] = shiftedCoutUp[i];
         prevCinLow[i] = shiftedCinLow[i];
         prevCinUp[i] = shiftedCinUp[i];
         
         
         //          NSLog(@" Cin  =%@",bitvar2NSString(prevCinLow,prevCinUp, wordLength));
         //          NSLog(@" X    =%@",bitvar2NSString(prevXLow, prevXUp, wordLength));
         //          NSLog(@"+Y    =%@",bitvar2NSString(prevYLow, prevYUp, wordLength));
         //          NSLog(@"_______________________________________________________");
         //          NSLog(@" Z    =%@",bitvar2NSString(prevZLow, prevZUp, wordLength));
         //          NSLog(@" Cout =%@\n\n",bitvar2NSString(prevCoutLow, prevCoutUp, wordLength));
         
         //commented out on 2/11/13 by GAJ (vars are checked below)
         //          //Chgeck consistency of new domain for Cin variable.
         //             inconsistencyFound |= ((prevXLow[i] & ~prevXUp[i]) |
         //                                    (prevXLow[i] & prevYLow[i] & ~prevCoutUp[i]) |
         //                                    (prevXLow[i] & ~prevZUp[i] & ~prevCoutUp[i]) |
         //                                    (~prevXUp[i] & ~prevYUp[i] & prevCoutLow[i]) |
         //                                    (~prevXUp[i] & prevZLow[i] & prevCoutLow[i]) |
         //                                    (prevYLow[i] & ~prevYUp[i]) |
         //                                    (prevYLow[i] & ~prevZUp[i] & ~prevCoutUp[i]) |
         //                                    (~prevYUp[i] & prevZLow[i] & prevCoutLow[i]) |
         //                                    (prevZLow[i] & ~prevZUp[i]) |
         //                                    (prevCoutLow[i] & ~prevCoutUp[i]));
         
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
         //          inconsistencyFound |= ((prevCinLow[i] & ~prevCinUp[i]) |
         //                                (prevCinLow[i] & prevYLow[i] & ~prevCoutUp[i]) |
         //                                (prevCinLow[i] & ~prevZUp[i] & ~prevCoutUp[i]) |
         //                                (~prevCinUp[i] & ~prevYUp[i] & prevCoutLow[i]) |
         //                                (~prevCinUp[i] & prevZLow[i] & prevCoutLow[i]) |
         //                                (prevYLow[i] & ~prevYUp[i]) |
         //                                (prevYLow[i] & ~prevZUp[i] & ~prevCoutUp[i]) |
         //                                (~prevYUp[i] & prevZLow[i] & prevCoutLow[i]) |
         //                                (prevZLow[i] & ~prevZUp[i]) |
         //                                (prevCoutLow[i] & ~prevCoutUp[i]));
         //#ifdef BIT_DEBUG
         //          if (inconsistencyFound){
         //             NSLog(@"Logical inconsistency in Bitwise sum constraint variable x.\n");
         //             NSLog(@"In the %d th word: %x\n\n",i,inconsistencyFound);
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
         //          upXORlow = newXUp[i] ^ newXLow[i];
         //          inconsistencyFound |= (upXORlow&(~newXUp[i]))&(upXORlow & newXLow[i]);
         ////#ifdef BIT_DEBUG
         //          if (inconsistencyFound){
         //             NSLog(@"Inconsistency in Bitwise sum constraint variable x.\n");
         //             NSLog(@"In the %d th word: %x\n\n",i,inconsistencyFound);
         //             NSLog(@" Cin  =%@\t\t Cin  =%@",bitvar2NSString(prevCinLow,prevCinUp, wordLength),bitvar2NSString(newCinLow, newCinUp, wordLength));
         //             NSLog(@" X    =%@\t\t X    =%@",bitvar2NSString(prevXLow, prevXUp, wordLength),bitvar2NSString(newXLow, newXUp, wordLength));
         //             NSLog(@"+Y    =%@\t\t+Y    =%@",bitvar2NSString(prevYLow, prevYUp, wordLength),bitvar2NSString(newYLow, newYUp, wordLength));
         //             NSLog(@"_____________________________________________________________________________________________________________________________________________________");
         //             NSLog(@" Z    =%@\t\t Z    =%@",bitvar2NSString(prevZLow, prevZUp, wordLength),bitvar2NSString(newZLow, newZUp, wordLength));
         //             NSLog(@" Cout =%@\t\t Cout =%@\n\n",bitvar2NSString(prevCoutLow, prevCoutUp, wordLength),bitvar2NSString(newCoutLow, newCoutUp, wordLength));
         //             failNow();
         //          }
         //#endif
         //          //Check consistency of new domain for Y variable
         //          inconsistencyFound |= ((prevCinLow[i] & ~prevCinUp[i]) |
         //                                 (prevCinLow[i] & prevXLow[i] & ~prevCoutUp[i]) |
         //                                 (prevCinLow[i] & ~prevZUp[i] & ~prevCoutUp[i]) |
         //                                 (~prevCinUp[i] & ~prevXUp[i] & prevCoutLow[i]) |
         //                                 (~prevCinUp[i] & prevZLow[i] & prevCoutLow[i]) |
         //                                 (prevXLow[i] & ~prevXUp[i]) |
         //                                 (prevXLow[i] & ~prevZUp[i] & ~prevCoutUp[i]) |
         //                                 (~prevXUp[i] & prevZLow[i] & prevCoutLow[i]) |
         //                                 (prevZLow[i] & ~prevZUp[i]) |
         //                                 (prevCoutLow[i] & ~prevCoutUp[i]));
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
      }

   
   
   
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

@implementation CPBitCount

-(id) initCPBitCount:(CPBitVarI*) x count:(CPIntVarI*) p
{
   self = [super initCPCoreConstraint: [x engine]];
   _x = x;
   _p = p;
   return self;
}

- (void) dealloc
{
   [super dealloc];
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
   
   unsigned int wordLength = [_x getWordLength];
   
   TRUInt* xLow;
   TRUInt* xUp;
   ORInt pLow;
   ORInt pUp;
   
   [_x getUp:&xUp andLow:&xLow];
   pLow = [_p min];
   pUp = [_p max];
   
   unsigned int* up = alloca(sizeof(unsigned int)*wordLength);
   unsigned int* low = alloca(sizeof(unsigned int)*wordLength);
   unsigned int  upXORlow;
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
      [_p updateMin:pLow andMax:pUp];
   }
   
   //domain consistency check on _x
   for (int i=0; i<wordLength; i++) {
      upXORlow = up[i] ^ low[i];
      inconsistencyFound |= (upXORlow&(~up[i]))&(upXORlow & low[i]);
   }
   if (inconsistencyFound)
      failNow();
   
   //set _x and _p to new values
   [_x setUp:up andLow:low for:self];
}
@end

@implementation CPBitZeroExtend

-(id) initCPBitZeroExtend:(CPBitVarI*) x extendTo:(CPBitVarI *)y
{
   self = [super initCPCoreConstraint: [x engine]];
   _x = x;
   _y = y;
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
   //   unsigned int wordDiff = yWordLength - xWordLength;
   
   TRUInt* xLow;
   TRUInt* xUp;
   TRUInt* yLow;
   TRUInt* yUp;
   
   [_x getUp:&xUp andLow:&xLow];
   [_y getUp:&yUp andLow:&yLow];
   
   unsigned int* up = alloca(sizeof(unsigned int)*yWordLength);
   unsigned int* low = alloca(sizeof(unsigned int)*yWordLength);
   unsigned int  upXORlow;
   
   for (int i=0; i<yWordLength; i++) {
      up[i] = 0;
      low[i] = 0;
   }
   
   for(int i=0;i<xWordLength;i++){
      up[i] = xUp[i]._val & yUp[i]._val;
      low[i] = xLow[i]._val | yLow[i]._val;
      upXORlow = up[i] ^ low[i];
      if(((upXORlow & (~up[i])) & (upXORlow & low[i])) != 0){
         failNow();
      }
   }
   
   [_x setUp:up andLow:low for:self];
   [_y setUp:up andLow:low for:self];
   
}
@end

@implementation CPBitExtract

-(id) initCPBitExtract:(CPBitVarI*) x from:(ORUInt)lsb to:(ORUInt)msb eq:(CPBitVarI*)y
{
   self = [super initCPCoreConstraint: [x engine]];
   _x = x;
   _y = y;
   _lsb = lsb;
   _msb = msb;
   return self;
}

- (void) dealloc
{
   [super dealloc];
}
-(NSString*) description
{
   NSMutableString* string = [NSMutableString stringWithString:[super description]];
   [string appendString:@" with "];
   [string appendString:[NSString stringWithFormat:@"%@ ",_x]];
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
   
   TRUInt* xLow;
   TRUInt* xUp;
   TRUInt* yLow;
   TRUInt* yUp;
   
   [_x getUp:&xUp andLow:&xLow];
   [_y getUp:&yUp andLow:&yLow];
   
   //   NSLog(@"*******************************************");
   //   NSLog(@"x=%@\n",_x);
   //   NSLog(@"y=%@\n",_y);
   //
   unsigned int* up = alloca(sizeof(unsigned int)*yWordLength);
   unsigned int* low = alloca(sizeof(unsigned int)*yWordLength);
   //   unsigned int* xUpForY = alloca(sizeof(unsigned int)*yWordLength);
   //   unsigned int* xLowForY =  alloca(sizeof(unsigned int)*yWordLength);
   unsigned int* newXUp = alloca(sizeof(unsigned int)*xWordLength);
   unsigned int* newXLow = alloca(sizeof(unsigned int)*xWordLength);
   unsigned int* yLowForX = alloca(sizeof(unsigned int)*yWordLength);
   unsigned int* yUpForX = alloca(sizeof(unsigned int)*yWordLength);
   
   unsigned int  upXORlow;
   bool    inconsistencyFound = false;
   
   for (int i = 0; i < yWordLength; i++) {
      low[i] = yLowForX[i] = yLow[i]._val;
      up[i] = yUpForX[i] = yUp[i]._val;
      
   }
   yUpForX[yWordLength-1] |= CP_UMASK << [_y bitLength];
   yLowForX[yWordLength-1] &= ~(CP_UMASK << [_y bitLength]);
   
   //   NSLog(@"yForX = %@\n",bitvar2NSString(yLowForX, yUpForX, yWordLength));
   
   for(int i=0;i<xWordLength;i++){
      if ((i+_lsb/32) < xWordLength) {
         
         up[i] = ~(ISFALSE(yUp[i]._val,yLow[i]._val)|((ISFALSE(xUp[i+_lsb/32]._val, xLow[i+_lsb/32]._val)>>(_lsb%32))));
         low[i] = ISTRUE(yUp[i]._val,yLow[i]._val)|((ISTRUE(xUp[i+_lsb/32]._val, xLow[i+_lsb/32]._val)>>(_lsb%32)));
         //         NSLog(@"i=%i",i+_places/32);
         if((i+_lsb/32+1) < xWordLength) {
            up[i] &= ~(ISFALSE(xUp[i+_lsb/32+1]._val, xLow[i+_lsb/32+1]._val)<<(32-(_lsb%32)));
            low[i] |= ISTRUE(xUp[i+_lsb/32+1]._val, xLow[i+_lsb/32+1]._val)<<(32-(_lsb%32));
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
      
      if ((i-(int)_lsb/32) >= 0) {
         newXUp[i] = ~(ISFALSE(xUp[i]._val,xLow[i]._val)|((ISFALSE(yUpForX[i-_lsb/32], yLow[i-_lsb/32]._val)<<(_lsb%32))));
         newXLow[i] = ISTRUE(xUp[i]._val,xLow[i]._val)|((ISTRUE(yUpForX[i-_lsb/32], yLow[i-_lsb/32]._val)<<(_lsb%32)));
         //         NSLog(@"i=%i",i-_places/32);
         if((i-(int)_lsb/32-1) >= 0) {
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
   
   //check domain consistency
   for(int i=0;i<xWordLength;i++){
      upXORlow = newXUp[i] ^ newXLow[i];
      inconsistencyFound |= (upXORlow&(~newXUp[i]))&(upXORlow & newXLow[i]);
      if (inconsistencyFound){
         NSLog(@"Inconsistency found in Bit Extract constraint X Variable.");
         NSLog(@"x=%@\n",bitvar2NSString(newXLow, newXUp, xWordLength));
         failNow();
      }
      
      upXORlow = up[i] ^ low[i];
      inconsistencyFound |= (upXORlow&(~up[i]))&(upXORlow & low[i]);
      if (inconsistencyFound){
         NSLog(@"Inconsistency found in Bit Extract constraint Y Variable.");
         NSLog(@"y=%@\n",bitvar2NSString(low, up, yWordLength));
         failNow();
      }
      
   }
   
   if (inconsistencyFound){
      NSLog(@"Inconsistency found in Bit Extract constraint.");
      failNow();
   }
   
   [_x setUp:newXUp andLow:newXLow for:self];
   [_y setUp:up andLow:low for:self];
}
@end

@implementation CPBitConcat
-(id) initCPBitConcat:(CPBitVarI*) x concat:(CPBitVarI *)y eq:(CPBitVarI *)z
{
   self = [super initCPCoreConstraint: [x engine]];
   _x = x;
   _y = y;
   _z = z;
   return self;
}

- (void) dealloc
{
   [super dealloc];
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
   unsigned int  upXORlow;
   
   for(int i=0;i<zWordLength;i++){
      newZUp[i] = zUp[i]._val;
      newZLow[i] = zLow[i]._val;
   }
   
   for(int i=0;i<yWordLength;i++){
      zUpForY[i] = zUp[i]._val;
      zLowForY[i] = zLow[i]._val;
   }
   uint32 mask = CP_UMASK;
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
      upXORlow = newXUp[i] ^ newXLow[i];
      if(((upXORlow & (~newXUp[i])) & (upXORlow & newXLow[i])) != 0){
         failNow();
      }
   }
   
   
   
   for(int i=0;i<yWordLength;i++){
      newYUp[i] = yUp[i]._val & zUpForY[i];
      newYLow[i] = yLow[i]._val | zLowForY[i];
      upXORlow = newXUp[i] ^ newXLow[i];
      if(((upXORlow & (~newYUp[i])) & (upXORlow & newYLow[i])) != 0){
         failNow();
      }
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
   for(int i=0;i<xWordLength;i++){
      newZUp[i+xWordShift] &= ((xUp[i]._val<<xBitShift) & mask) | ~mask;//>>xBitShift;
      newZLow[i+xWordShift] |= (xLow[i]._val<<xBitShift) & mask;//>>xBitShift;
      if (xBitShift!=0 && ((i+1) < xWordLength)) {
         newZUp[i+xWordShift] &= newXUp[i+1] << (32 - xBitShift);
         newZLow[i+xWordShift] |= newXLow[i+1] << (32 - xBitShift);
      }
   }
   
   NSLog(@"%@\n",bitvar2NSString(newZLow, newZUp, zWordLength));
   for(int i=0;i<zWordLength;i++){
      upXORlow = newZUp[i] ^ newZLow[i];
      if(((upXORlow & (~newZUp[i])) & (upXORlow & newZLow[i])) != 0){
         failNow();
      }
   }
   
   [_x setUp:newXUp andLow:newXLow for:self];
   [_y setUp:newYUp andLow:newYLow for:self];
   [_z setUp:newZUp andLow:newZLow for:self];
}
@end

@implementation CPBitLT
-(id) initCPBitLT:(CPBitVarI *)x LT:(CPBitVarI *)y eval:(CPBitVarI *)z{
   self = [super initCPCoreConstraint:[x engine]];
   _x = x;
   _y = y;
   _z = z;
   return self;
   
}

- (void) dealloc
{
   [super dealloc];
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
   unsigned int zWordLength = [_z getWordLength];
   unsigned int zBitLength = [_z bitLength];
   
   TRUInt* xLow;
   TRUInt* xUp;
   TRUInt* yLow;
   TRUInt* yUp;
   TRUInt* zLow;
   TRUInt* zUp;
   
   [_x getUp:&xUp andLow:&xLow];
   [_y getUp:&yUp andLow:&yLow];
   [_z getUp:&zUp andLow:&zLow];
   
   unsigned int* zero = alloca(sizeof(unsigned int)*wordLength);
   unsigned int* one = alloca(sizeof(unsigned int)*wordLength);
   unsigned int* newZUp;
   unsigned int* newZLow;
   //   unsigned int  upXORlow;
   
   
   for (int i = 0; i<[_z getWordLength]; i++) {
      zero[i] = one[i] = 0x00000000;
   }
   one[0] = 0x00000001;
   
   ORUInt mask = CP_UMASK;
   mask >>= zBitLength % BITSPERWORD;
   one[zWordLength] &=mask;
   
   ORBool zFixed = false;
   for(int i = wordLength - 1; i >= 0; i--){
      
      ORUInt setBitsInX = ~(xUp[i]._val ^ xLow[i]._val);
      ORUInt setBitsInY = ~(yUp[i]._val ^ yLow[i]._val);
      
      ORUInt setUpInX = setBitsInX & xLow[i]._val;
      ORUInt setUpInY = setBitsInY & yLow[i]._val;
      
      
      if (__builtin_clz(setUpInX) < __builtin_clz(yUp[i]._val)) {
         newZUp = newZLow = one;
         zFixed = true;
         break;
      }
      
      if (__builtin_clz(setUpInY) < __builtin_clz(xUp[i]._val)) {
         newZUp = newZLow = zero;
         zFixed = true;
         break;
      }
      
   }
#ifdef BIT_DEBUG
   NSLog(@"      X =%@",_x);
   NSLog(@"   <  Y =%@",_y);
   NSLog(@"   =  Z =%@\n\n",_z);
#endif
   if(zFixed)
      [_z setUp:newZUp andLow:newZLow for:self];
}
@end

@implementation CPBitLE
-(id) initCPBitLE:(CPBitVarI *)x LE:(CPBitVarI *)y eval:(CPBitVarI *)z{
   self = [super initCPCoreConstraint:[x engine]];
   _x = x;
   _y = y;
   _z = z;
   return self;
   
}

- (void) dealloc
{
   [super dealloc];
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
   unsigned int zWordLength = [_z getWordLength];
   unsigned int zBitLength = [_z bitLength];
   
   TRUInt* xLow;
   TRUInt* xUp;
   TRUInt* yLow;
   TRUInt* yUp;
   TRUInt* zLow;
   TRUInt* zUp;
   
   [_x getUp:&xUp andLow:&xLow];
   [_y getUp:&yUp andLow:&yLow];
   [_z getUp:&zUp andLow:&zLow];
   
   unsigned int* zero = alloca(sizeof(unsigned int)*wordLength);
   unsigned int* one = alloca(sizeof(unsigned int)*wordLength);
   unsigned int* newZUp;
   unsigned int* newZLow;
   //   unsigned int  upXORlow;
   
   
   for (int i = 0; i<[_z getWordLength]; i++) {
      zero[i] = one[i] = 0x00000000;
   }
   one[0] = 0x00000001;
   
   ORUInt mask = CP_UMASK;
   mask >>= zBitLength % BITSPERWORD;
   one[zWordLength] &=mask;
   
   ORBool xyFixed = true;
   ORBool xyEqual = true;
   ORBool zFixed = false;
   
   
   for (int i=0; i<wordLength; i++) {
      if (!((xUp[i]._val == xLow[i]._val) && (yUp[i]._val == yLow[i]._val))){
         xyFixed = false;
      }
      if(!((xUp[i]._val == yUp[i]._val)&& (xLow[i]._val == yLow[i]._val)))
         xyEqual = false;
   }
   if (xyFixed && xyEqual) {
      [_z setUp:one andLow:one for:self];
      return;
   }
   for(int i = wordLength - 1; i >= 0; i--){
      
      ORUInt setBitsInX = ~(xUp[i]._val ^ xLow[i]._val);
      ORUInt setBitsInY = ~(yUp[i]._val ^ yLow[i]._val);
      
      ORUInt setUpInX = setBitsInX & xLow[i]._val;
      ORUInt setUpInY = setBitsInY & yLow[i]._val;
      
      
      if (__builtin_clz(setUpInX) < __builtin_clz(yUp[i]._val)) {
         newZUp = newZLow = one;
         zFixed = true;
         break;
      }
      
      if (__builtin_clz(setUpInY) < __builtin_clz(xUp[i]._val)) {
         newZUp = newZLow = zero;
         zFixed = true;
         break;
      }
      
   }
#ifdef BIT_DEBUG
   NSLog(@"      X =%@",_x);
   NSLog(@"   <  Y =%@",_y);
   NSLog(@"   =  Z =%@\n\n",_z);
#endif
   if(zFixed)
      [_z setUp:newZUp andLow:newZLow for:self];
}
@end

@implementation CPBitITE
-(id) initCPBitITE:(CPBitVarI *)i then:(CPBitVarI *)t else:(CPBitVarI *)e result:(CPBitVarI*)r{
   self = [super initCPCoreConstraint:[i engine]];
   _i = i;
   _t = t;
   _e = e;
   _r = r;
   return self;
   
}

- (void) dealloc
{
   [super dealloc];
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
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment
{
   CPBitAntecedents* ants = malloc(sizeof(CPBitAntecedents));
   CPBitAssignment** vars;

   vars  = malloc(sizeof(CPBitAssignment*)*4);
   ants->numAntecedents = 0;

   ORUInt index = assignment->index;
   ants->antecedents = vars;

   if (assignment->var == _i) {
      if (![_t isFree:index]) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _t;
         vars[ants->numAntecedents]->index = index;
         vars[ants->numAntecedents]->value = [_t getBit:index];
         ants->numAntecedents++;
      }
      if (![_e isFree:index]) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _e;
         vars[ants->numAntecedents]->index = index;
         vars[ants->numAntecedents]->value = [_e getBit:index];
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
   else if (assignment->var == _t){
      if (![_i isFree:index]) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _i;
         vars[ants->numAntecedents]->index = index;
         vars[ants->numAntecedents]->value = [_i getBit:index];
         ants->numAntecedents++;
      }
      if (![_e isFree:index]) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _e;
         vars[ants->numAntecedents]->index = index;
         vars[ants->numAntecedents]->value = [_e getBit:index];
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
   else if (assignment->var == _e){
      if (![_i isFree:index]) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _i;
         vars[ants->numAntecedents]->index = index;
         vars[ants->numAntecedents]->value = [_i getBit:index];
         ants->numAntecedents++;
      }
      if (![_t isFree:index]) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _t;
         vars[ants->numAntecedents]->index = index;
         vars[ants->numAntecedents]->value = [_t getBit:index];
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
      if (![_i isFree:index]) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _i;
         vars[ants->numAntecedents]->index = index;
         vars[ants->numAntecedents]->value = [_i getBit:index];
         ants->numAntecedents++;
      }
      if (![_t isFree:index]) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _t;
         vars[ants->numAntecedents]->index = index;
         vars[ants->numAntecedents]->value = [_t getBit:index];
         ants->numAntecedents++;
      }
      if (![_e isFree:index]) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _e;
         vars[ants->numAntecedents]->index = index;
         vars[ants->numAntecedents]->value = [_e getBit:index];
         ants->numAntecedents++;
      }
   }
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
   
   unsigned int* up = alloca(sizeof(unsigned int)*wordLength);
   unsigned int* low = alloca(sizeof(unsigned int)*wordLength);
   unsigned int  upXORlow;
   
   //   ORUInt tXORe = 0;
   
   unsigned int setbits = 0;
   for (int i=0; i<wordLength; i++) {
      setbits += __builtin_popcount(iLow[i]._val);
   }
   
   if (setbits > 0) {
      for(int i=0;i<wordLength;i++){
         up[i] = tUp[i]._val & rUp[i]._val;
         low[i] = tLow[i]._val | rLow[i]._val;
//         upXORlow = up[i] ^ low[i];
//         if(((upXORlow & (~up[i])) & (upXORlow & low[i])) != 0)
         ORBool tFail = checkDomainConsistency(_t, low, up, wordLength, self);
         if(tFail)
            failNow();
      }
      
      [_t setUp:up andLow:low for:self];
      [_r setUp:up andLow:low for:self];
      return;
   }
   else if ([_i bound]) {
      for(int i=0;i<wordLength;i++){
         up[i] = eUp[i]._val & rUp[i]._val;
         low[i] = eLow[i]._val | rLow[i]._val;
//         upXORlow = up[i] ^ low[i];
//         //Bitrev failing here, must add nogood learning here
//         if(((upXORlow & (~up[i])) & (upXORlow & low[i])) != 0){
         ORBool iFail = checkDomainConsistency(_i, low, up, wordLength, self);
         if(iFail){
            failNow();
         }
      }
      
      [_e setUp:up andLow:low for:self];
      [_r setUp:up andLow:low for:self];
      return;
   }
   
   //   if ([_i bound] && [_r bound]) {
   //
   //      setbits = 0;
   //      for (int i=0; i<wordLength; i++)
   //         setbits += __builtin_popcount(iLow[i]._val);
   //      if (setbits==0)
   //         failNow();
   //
   //   }
   //if then and else are the same (if condition is irrelevant)
   //   if ([_t bound] && [_e bound]) {
   //
   //   }
   
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
         for (int i=0; i<wordLength; i++)
            setbits += __builtin_popcount(iLow[i]._val);
         //    if countbits in i is zero
         //       fail
         if ([_i bound] && setbits==0)
            failNow();
         ORUInt trueVector[wordLength];
         for (int i=1; i<wordLength; i++) {
            trueVector[i] = 0;
         }
         trueVector[0] = 1;
         [_i setUp:trueVector andLow:trueVector for:self];
      }
      // else if (_r == _e) && (_r != _t)
      else if (!rNEQe) {
         for (int i=0; i<wordLength; i++)
            setbits += __builtin_popcount(iLow[i]._val);
         //    if countbits in i is > zero
         //       fail
         if (setbits>0)
            failNow();
         ORUInt zeroVector[wordLength];
         if(![_i bound]){
            for (int i=0; i<wordLength; i++) {
               zeroVector[i] = 0;
            }
            [_i setUp:zeroVector andLow:zeroVector for:self];
         }
      }
   }
   
   //   if ([_t bound] && [_e bound]) {
   //      for(int i=0;i<wordLength;i++)
   //         tXORe |= tLow[i]._val ^ eLow[i]._val;
   //      if (tXORe == 0) {
   //         for(int i=0;i<wordLength;i++){
   //            up[i] = eUp[i]._val;
   //            low[i] = eLow[i]._val;
   //            upXORlow = up[i] ^ low[i];
   //            if(((upXORlow & (~up[i])) & (upXORlow & low[i])) != 0){
   //               failNow();
   //            }
   //         }
   //
   //         [_r setUp:up andLow:low];
   //      }
   //   }
   
   return;
}
@end

@implementation CPBitLogicalEqual
-(id) initCPBitLogicalEqual:(CPBitVarI *)x EQ:(CPBitVarI *)y eval:(CPBitVarI *)z{
   self = [super initCPCoreConstraint:[x engine]];
   _x = x;
   _y = y;
   _z = z;
   return self;
   
}

- (void) dealloc
{
   [super dealloc];
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
   
   unsigned int* up = alloca(sizeof(unsigned int)*wordLength);
   unsigned int* low = alloca(sizeof(unsigned int)*wordLength);
   unsigned int  upXORlow;
   
   [_x getUp:&xUp andLow:&xLow];
   [_y getUp:&yUp andLow:&yLow];
   [_z getUp:&zUp andLow:&zLow];
   
   unsigned int different = 0;
   unsigned int makesame = 0;
   for (int i=0; i<wordLength; i++) {
      different |= (xLow[i]._val & ~yUp[i]._val);// ^ xLow[i]._val;
      different |= (~xUp[i]._val & yLow[i]._val);// ^ ~xUp[i]._val;
   }
   
   for (int i=0; i<[_z getWordLength]; i++) {
      makesame |= zLow[i]._val;
   }
   
   if(makesame){
      for(int i=0;i<wordLength;i++){
         up[i] = xUp[i]._val & yUp[i]._val;
         low[i] = xLow[i]._val | yLow[i]._val;
//         upXORlow = up[i] ^ low[i];
//         if(((upXORlow & (~up[i])) & (upXORlow & low[i])) != 0){
         ORBool xFail = checkDomainConsistency(_x, low, up, wordLength, self);
         if (xFail)
            failNow();
//         }
      }
      
      [_x setUp:up andLow:low for:self];
      [_y setUp:up andLow:low for:self];
   }
   
   if (different) {
      for (int i=0; i<zWordLength; i++) {
         newZUp[i] = zUp[i]._val & zero[i];
         newZLow[i] = zLow[i]._val | zero[i];
//         upXORlow = newZUp[i] ^ newZLow[i];
//         if(((upXORlow & (~newZUp[i])) & (upXORlow & newZLow[i])) != 0)
         ORBool zFail = checkDomainConsistency(_z, newZLow, newZUp, zWordLength, self);
         if (zFail)
            failNow();
      }
      [_z setUp:newZUp andLow:newZLow for:self];
   }
   else if ([_x bound] && [_y bound]){
      //LSB should be 1
      newZUp[0] = zUp[0]._val & one[0];
      newZLow[0] = zLow[0]._val | one[0];
      upXORlow = newZUp[0] ^ newZLow[0];
//      if(((upXORlow & (~newZUp[0])) & (upXORlow & newZLow[0])) != 0)
//         failNow();
      ORBool zFail = checkDomainConsistency(_z, newZLow, newZUp, zWordLength, self);
      if (zFail)
         failNow();
      
      //check the rest of the words in the bitvector if present
      for (int i=1; i<zWordLength; i++) {
         newZUp[i] = zUp[i]._val & zero[i];
         newZLow[i] = zLow[i]._val | zero[i];
//         upXORlow = newZUp[i] ^ newZLow[i];
//         if(((upXORlow & (~newZUp[i])) & (upXORlow & newZLow[i])) != 0)
//            failNow();
         ORBool zFail = checkDomainConsistency(_z, newZLow, newZUp, zWordLength, self);
         if (zFail)
            failNow();
      }
      [_z setUp:newZUp andLow:newZLow for:self];
   }
   return;
}
@end

@implementation CPBitLogicalAnd

-(id) initCPBitLogicalAnd:(id<CPBitVarArray>) x eval:(CPBitVarI *)r
{
   self = [super initCPCoreConstraint: [x[0] engine]];
   _x = x;
   return self;
}

- (void) dealloc
{
   [super dealloc];
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
   //   [self propagate];
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
   
   //TODO: Check for failures
   for (int i=[_x low]; i<=[_x up]; i++) {
      [(CPBitVarI*)_x[i] getUp:&xUp andLow:&xLow];
      
      if (![_x[i] bound]){
         numUnboundVars++;
         lastUnboundVar = _x[i];
      }
      fullbv = 0;
      for (int j=0; j<[(CPBitVarI*)_x[j] getWordLength]; j++)
         fullbv |= xUp[j]._val;
      
      //fullbv shows if any bit is set up, or can be set up later, in _x[j]
      if (!fullbv) {
         ORInt rLength = [_r getWordLength];
         for (int k=0; k<rLength; k++)
            rlow[k] = 0x0;
         ORBool rFail = checkDomainConsistency(_r, rlow, rup, rLength, self);
         if (rFail) {
            failNow();
         }
         else{
            [_r setUp:rup andLow:rlow for:self];
         }
         return;
      }
   }
   if (numUnboundVars == 0) {
      ORInt rLength = [_r getWordLength];
      //if all _x variables are bound and all have at least one bit set up (since we got here)
      //must ensure at least one bit is set in _r
      if ([_r domsize] == 1) {
         rlow[0] = 0x1;
      }
      ORBool rFail = checkDomainConsistency(_r, rlow, rup, rLength, self);
      if (rFail) {
         failNow();
      }
      else{
         [_r setUp:rup andLow:rlow for:self];
      }
      return;
   }
   if((numUnboundVars==1) && ([lastUnboundVar domsize]==1)){
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
      
      if ([_r bound] && rlow[0] > 0){
         if (fullbv == 0)
            xup[bitIndex/WORDLENGTH] |= mask;
         else
            xlow[bitIndex/WORDLENGTH] &= ~mask;
         
         ORBool xFail = checkDomainConsistency((CPBitVarI*)lastUnboundVar, xlow, xup, xLength, self);
         if (xFail) {
            failNow();
         }
         else [(CPBitVarI*)lastUnboundVar setUp:xup andLow:xlow for:self];
      }
   }
   return;
}
@end

@implementation CPBitLogicalOr

-(id) initCPBitLogicalOr:(id<CPBitVarArray>) x eval:(CPBitVarI *)r
{
   self = [super initCPCoreConstraint: [x[0] engine]];
   _x = x;
   return self;
}

- (void) dealloc
{
   [super dealloc];
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
   
   //TODO: Check for failures
   for (int i=[_x low]; i<=[_x up]; i++) {
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
         else{
            [_r setUp:rup andLow:rlow for:self];
         }
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
      else{
         [_r setUp:rup andLow:rlow for:self];
      }
      return;
   }
   if((numUnboundVars==1) && ([lastUnboundVar domsize]==1)){
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
         else [(CPBitVarI*)lastUnboundVar setUp:xup andLow:xlow for:self];
      }
   }
   return;
}
@end

@implementation CPBitConflict
-(id) initCPBitConflict:(CPBitAntecedents*)a
{
   self = [super initCPCoreConstraint: [a->antecedents[0]->var engine]];
   _assignments = a;
   return self;
}

- (void) dealloc
{
//   free (_conflictValues);
   [super dealloc];
}

-(void) post
{
   //TODO:Check that all variables are of the same length
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

-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment
{
//   NSLog(@"Tracing back antecedents for CPBitConflict with:");
//   for (int i = 0; i<_assignments->numAntecedents; i++) {
//      NSLog(@"0x%lx",_assignments->antecedents[i]->var);
//   }
   CPBitAntecedents* ants = malloc(sizeof(CPBitAntecedents));
   CPBitAssignment** vars;
   vars  = malloc(sizeof(CPBitAssignment*)*(_assignments->numAntecedents-1));
   ants->numAntecedents = 0;

   ants->antecedents = vars;
   
   for (int i = 0; i<_assignments->numAntecedents; i++) {
      if ((_assignments->antecedents[i]->var == assignment->var) || [_assignments->antecedents[i]->var isFree:_assignments->antecedents[i]->index]){
         continue;
      }
      
//      if (((l=[_assignments->antecedents[i]->var getLevelBitWasSet:_assignments->antecedents[i]->index]) <= level) || (l==-1)){
         ants->antecedents[ants->numAntecedents] = _assignments->antecedents[i];
         ants->numAntecedents++;
//      }
   }
   return ants;
}
-(void) propagate
{
   ORULong numVars = _assignments->numAntecedents;
   CPBitArrayDom** domains;
   ORInt* currentVals;
   ORBool conflict = true;
   ORInt numFree = 0;
   ORBool mismatch= false;
   
   
   //   conflict = 0x1 << (_bit % 32);
   domains = alloca(sizeof(CPBitArrayDom*)*numVars);
   currentVals = alloca(sizeof(ORInt)*numVars);
   for (int i=0; i<numVars; i++) {
      domains[i] = [_assignments->antecedents[i]->var domain];
      if ([domains[i] isFree:_assignments->antecedents[i]->index]) {
         currentVals[i] = -1;
         numFree++;
//         conflict = false;
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
            CPBitAssignment* c = alloca(sizeof(CPBitAssignment));
            c->var = _assignments->antecedents[i]->var;
            c->index = _assignments->antecedents[i]->index;
            CPBitAntecedents* conflictAntecedents = [self getAntecedentsFor:c];
            analyzeConflict((CPLearningEngineI*)[c->var engine], c, self);
         }
      }
      if (conflict) {
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
            [_assignments->antecedents[i]->var setUp:up andLow:low for:self];
            return;
         }
      }
   }
}
@end


@implementation CPBitORb

-(id) initCPBitORb:(CPBitVarI*)x or:(CPBitVarI*)y eval:(CPBitVarI*)r
{
   self = [super initCPCoreConstraint:[x engine]];
   _x = x;
   _y = y;
   _r = r;
   return self;
}

- (void) dealloc
{
   [super dealloc];
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

   ORBool xFail = checkDomainConsistency(_x, &newXLow, &newXUp, 1, self);
   ORBool yFail = checkDomainConsistency(_y, &newYLow, &newYUp, 1, self);
   ORBool rFail = checkDomainConsistency(_r, &newRLow, &newRUp, 1, self);
   
   if(xFail || yFail || rFail)
      failNow();
   
   [_x setUp:&newXUp andLow:&newXLow for:self];
   [_y setUp:&newYUp andLow:&newYLow for:self];
   [_r setUp:&newRUp andLow:&newRLow for:self];
   
}
@end

@implementation CPBitNotb

-(id) initCPBitNotb:(CPBitVarI*)x eval:(CPBitVarI*)r
{
   self = [super initCPCoreConstraint:[x engine]];
   _x = x;
   _r = r;
   return self;
}

- (void) dealloc
{
   [super dealloc];
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
   
   ORBool xFail = checkDomainConsistency(_x, &newXLow, &newXUp, 1, self);
   ORBool rFail = checkDomainConsistency(_r, &newRLow, &newRUp, 1, self);
   
   if(xFail || rFail)
      failNow();
   
   [_x setUp:&newXUp andLow:&newXLow for:self];
   [_r setUp:&newRUp andLow:&newRLow for:self];
   
}
@end

@implementation CPBitEqualb

-(id) initCPBitEqualb:(CPBitVarI*)x equals:(CPBitVarI*)y eval:(CPBitVarI*)r
{
   self = [super initCPCoreConstraint:[x engine]];
   _x = x;
   _y = y;
   _r = r;
   return self;
}

- (void) dealloc
{
   [super dealloc];
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
      if (![_r isFree:0]) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _r;
         vars[ants->numAntecedents]->index = 0;
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
      if (![_r isFree:0]) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _r;
         vars[ants->numAntecedents]->index = 0;
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
   
   unsigned int* newXUp = alloca(sizeof(unsigned int)*wordLength);
   unsigned int* newXLow  = alloca(sizeof(unsigned int)*wordLength);
   unsigned int* newYUp = alloca(sizeof(unsigned int)*wordLength);
   unsigned int* newYLow  = alloca(sizeof(unsigned int)*wordLength);
   unsigned int newRUp, newRLow;
   
   [_x getUp:&xUp andLow:&xLow];
   [_y getUp:&yUp andLow:&yLow];
   [_r getUp:&rUp andLow:&rLow];
   
   for(int i=0;i<wordLength;i++){
      newXUp[i] = xUp[i]._val;
      newXLow[i] = xLow[i]._val;
      newYUp[i] = yUp[i]._val;
      newYLow[i] = yLow[i]._val;
   }
   newRUp = rUp->_val;
   newRLow = rLow->_val;
   
   if(rUp->_val && rLow->_val){
      //make _x and _y equal (evaluates to true)
      for(int i=0;i<wordLength;i++){
         newXUp[i] = newYUp[i] = xUp[i]._val & yUp[i]._val;
         newXLow[i] = newYLow[i] = xLow[i]._val | yLow[i]._val;
      }
   }
   else{
      //if _x or _y have only one free bit, we may be able to fix it
      //if _x and _y are bound, you can fix _r
      ORUInt xyfree = 0x0;
      ORUInt xyneq = 0x0;
      for (int i=0; i<wordLength; i++) {
         xyfree |= xUp[i]._val ^ xLow[i]._val;
         xyfree |= yUp[i]._val ^ yLow[i]._val;
         xyneq |= xLow[i]._val ^ yLow[i]._val;
      }
      if (!xyfree) {
         if (xyneq)
            newRUp = newRLow = 0x0;
         else
            newRUp = newRLow = 0x1;
         
      }

   }
   
   
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

