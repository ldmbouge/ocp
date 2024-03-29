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


#define ISTRUE(up, low) ((up) & (low))
#define ISFALSE(up, low) ((~up) & (~low))
#define ISSET(up, low) (~((up)^(low)))
#define ISFREE(up,low) ((up) & (~(low)))

#define UIMIN(a,b) ((a < b) ? a : b)
#define UIMAX(a,b) ((a > b) ? a : b)

CPBitAntecedents* getLTAntecedents(CPBitVarI* x, CPBitVarI* y, CPBitVarI* z, CPBitAssignment* a, ORUInt** state)
{
   ORUInt bitLength = [x bitLength];
   ORUInt wordLength = [x getWordLength];
   
   CPBitAntecedents* ants = malloc(sizeof(CPBitAntecedents));
   CPBitAssignment** vars = malloc(sizeof(CPBitAssignment*)*(bitLength<<1));
   ants->numAntecedents = 0;
   ants->antecedents = vars;

   ORUInt level = [a->var getLevelBitWasSet:a->index];
   ORUInt* xSetBits = alloca(sizeof(ORUInt)*wordLength);
   ORUInt* ySetBits = alloca(sizeof(ORUInt)*wordLength);

   if([a->var isFree:a->index]){
      for(int i=0;i<wordLength;i++){
         xSetBits[i] = ~(state[0][i] ^ state[1][i]);
         ySetBits[i] = ~(state[2][i] ^ state[3][i]);
      }
   }
   else {
      if(a->var == x)
         [x getState:xSetBits whenBitSet:a->index];
      else
         [x getState:xSetBits afterLevel:level];
      
      if(a->var == y)
         [y getState:ySetBits whenBitSet:a->index];
      else
         [y getState:ySetBits afterLevel:level];
   }
   
   ORInt index = a->index;
   ORInt idx=0;
   ORUInt* x1y0 = alloca(sizeof(ORUInt)*wordLength);
   
   for(int i=wordLength-1;i>=0;i--){
      x1y0[i] = ((state[1][i] & xSetBits[i]) & (~state[2][i] & ySetBits[i]));
      if(x1y0[i] != 0){
         idx = (i*BITSPERWORD)+(BITSPERWORD - __builtin_clz(x1y0[i])-1);
         break;
      }
   }

   ORBool xAtIndex, yAtIndex, zAt0;
   xAtIndex = yAtIndex = zAt0 = false;
   
   if((a->var == x) || (a->var == y)){
      if(![z isFree:0]){
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->index = 0;
         vars[ants->numAntecedents]->var = z;
         vars[ants->numAntecedents]->value = *state[5];
         ants->numAntecedents++;
      }
   }
   
   
   if(a->var == x){
      if(![y isFree:index]){
         yAtIndex = true;
         if ((index>idx) && ([x getBit:index] != [y getBit:index]))
            index=idx;
      }
   }
   else if(a->var == y){
      if(![x isFree:index]){
         xAtIndex = true;
         if ((index>idx) && ([x getBit:index] != [y getBit:index]))
            index=idx;
      }
   }
   else if(a->var == z){
      index = idx;
      if(![x isFree:index]){
         xAtIndex = true;
      }
      if(![y isFree:index]){
         yAtIndex = true;
      }
   }
   
   for(int i=index; i<bitLength;i++){
      if(((i!=a->index) && (xSetBits[i/BITSPERWORD] & 0x1<<i%BITSPERWORD)) || ((i==a->index) && xAtIndex)){
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->index = i;
         vars[ants->numAntecedents]->var = x;
         vars[ants->numAntecedents]->value = [x getBit:i];
         ants->numAntecedents++;
      }
      if(((i!=a->index) && (ySetBits[i/BITSPERWORD] & 0x1<<i%BITSPERWORD)) || ((i==a->index) && yAtIndex)){
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->index = i;
         vars[ants->numAntecedents]->var = y;
         vars[ants->numAntecedents]->value = [y getBit:i];
         ants->numAntecedents++;
      }
   }

   return ants;
}

NSString* bitvar2NSString(ORUInt* low, ORUInt* up, int bitLength)
{
   NSMutableString* string = [[[NSMutableString alloc] init] autorelease];
   ORUInt wordLength = (bitLength/BITSPERWORD) + (((bitLength%BITSPERWORD) == 0) ? 0 : 1);
   
   
   int remainingbits = (bitLength%32 == 0) ? 32 : bitLength%32;
   ORUInt boundLow = (~ up[wordLength-1]) & (~low[wordLength-1]);
   ORUInt boundUp = up[wordLength-1] & low[wordLength-1];
   ORUInt err = ~up[wordLength-1] & low[wordLength-1];
   ORUInt mask = CP_DESC_MASK;
   
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
//   [element->var incrementActivity:element->index];
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
          (element->index == stack[i]->index) )//&&
//          (element->value == stack[i]->value))
         return true;
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
void printQueue(CPBitAssignment** queue, ORInt* front, ORInt* back, ORUInt* cap)
{
    ORInt size = (((*back)-(*front))%(*cap))+1;
    CPBitAssignment* a;
    
    NSLog(@"Queue:");
    for(int k=0;k<size;k++){
        a=queue[(k+*front)%(*cap)];
        NSLog(@"\t%i:%@[%i]=%i@%i",[a->var getId],a->var,a->index,a->value,[a->var getLevelBitWasSet:a->index]);
    }
}

__attribute__((noinline))
void findAntecedents(ORUInt level, CPBitAssignment* conflict, id<CPBVConstraint> constraint, CPBitAntecedents* antecedents,
                CPBitAssignment*** conflictVars, ORUInt* numConflictVars, ORUInt* capConflictVars,
                CPBitAssignment*** visited, ORUInt* vsize, ORUInt* vcap)
{
   CPBitAssignment** queue;
   
   id<CPBVConstraint> c;
    
//    ORUInt y=0;
//    ORUInt levelCoord = 20;
    CPBitAssignment* ant;
   
   ORUInt qcap = antecedents->numAntecedents > 8 ? antecedents->numAntecedents : 8;

   ORInt qfront = -1;
   ORInt qback = -1;
   
   queue = malloc(sizeof(CPBitAssignment*)*qcap);
   
   CPBitAssignment* temp;
   ORInt setLevel;
    
    
//    setLevel = [conflict->var getLevelBitWasSet:conflict->index];
//
//    printf("\\node[label={\\tiny %i[%i]=%i@%i}] (n%i-%i) at (%i,%i) {};%s %s \n",[conflict->var getId],conflict->index,conflict->value,setLevel, [conflict->var getId], conflict->index, 25, 0, "%", [[constraint description] cString]);
    
   for (int i=0; i<antecedents->numAntecedents; i++) {
      temp = antecedents->antecedents[i];
       
//       setLevel =[temp->var getLevelBitWasSet:temp->index];
//       if(setLevel>4){
//           printf("\\node[label={\\tiny %i[%i]=%i@%i}] (n%i-%i) at (%i,%i) {};%s %s \n",[temp->var getId],temp->index,temp->value,setLevel,[temp->var getId], temp->index, levelCoord,  y*5, "%", [[constraint description] cString]);
//    //       printf("\\node[label={\\tiny %i[%i]=%i@%i}] (n%i) at (%i,%i) {};\n",[temp->var getId],temp->index,temp->value,setLevel,y,setLevel, 2*y);
//           printf("n%i-%i/n%i-%i\n",[conflict->var getId],conflict->index,[temp->var getId], temp->index);
//           y++;
//       }
       if(member(*visited,vsize,temp))
      {
         free(temp);
         continue;
      }
       //TODO: problem here with ITE now that it can detect conflict even if it was not set before.
       //So, _i bitvar may not be set even though a conflict was detected
       
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
//    levelCoord -= 5;

   free(antecedents->antecedents);
   free(antecedents);
   
//    if(qfront >= 0)
//        printQueue(queue, &qfront, &qback, &qcap);
   ORBool more;
  
//    more = true;

    more = qfront != qback;

   while (more){
      
      if (qfront==-1){
         break;
      }
      //get antecedents of first assignment in queue
      temp = dequeue(queue, &qfront, &qback, &qcap);
       ant=temp;
       more = qfront != qback;

      if(![temp->var isFree:temp->index])
      {
         c = [(CPBitVarI*)temp->var getImplicationForBit:temp->index];
         //but bit might not be set yet if it was in the constraint that generated the conflict!
         if(c==nil){
            ORInt lvl = (ORInt)[temp->var getLevelBitWasSet:temp->index];
            //bit was set by choice
            if(lvl > 4){
               *conflictVars = push(*conflictVars, numConflictVars, capConflictVars, temp);
            }
             continue;
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
//         if (((ORInt)[temp->var getLevelBitWasSet:temp->index] > 4) || [temp->var isFree:temp->index])
//         if ((ORInt)[temp->var getLevelBitWasSet:temp->index] > 4)
//            *conflictVars = push(*conflictVars, numConflictVars, capConflictVars, temp);
         continue;
      }
//       if(([conflict->var getId]==21) && (conflict->index == 7) && !conflict->value)
//       NSLog(@"Tracing back antecedents for %@[%i]=%i@%i:",temp->var, temp->index, temp->value, [temp->var getLevelBitWasSet:temp->index]);
//       for(int i=0;i<antecedents->numAntecedents;i++)
//           NSLog(@"\t%i:%@[%i]=%i@%i",[antecedents->antecedents[i]->var getId], antecedents->antecedents[i]->var, antecedents->antecedents[i]->index, antecedents->antecedents[i]->value,[antecedents->antecedents[i]->var getLevelBitWasSet:antecedents->antecedents[i]->index]);
//
//       NSLog(@"");
       
//       y=0;

      //Process all of the antecedents of this assignment
      for (int i=0; i<antecedents->numAntecedents; i++) {
         temp = antecedents->antecedents[i];
         if(member(*visited,vsize, temp))
         {
            free(temp);
            continue;
         }
         setLevel =[temp->var getLevelBitWasSet:temp->index];
         *visited = push(*visited, vsize, vcap, temp);
//          if(setLevel>4){
//          printf("\\node[label={\\tiny %i[%i]=%i@%i}] (n%i-%i) at (%i,%i) {};%s %s \n",[temp->var getId],temp->index,temp->value,setLevel,[temp->var getId], temp->index, levelCoord, y*5, "%", [[c description] cString]);
//          levelCoord++;
//          y++;
////          printf("\\node[label={\\tiny %i[%i]=%i@%i}] (n%i) at (%i,%i) {};\n",[temp->var getId],temp->index,temp->value,setLevel,y,setLevel, 2*y);
//          printf("n%i-%i/n%i-%i,\n",[ant->var getId],ant->index,[temp->var getId],temp->index);
////          y++;
//          }
          
          
          
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
//       if(qfront >= 0)
//           printQueue(queue, &qfront, &qback, &qcap);

      more = qfront != qback;
      
      free(antecedents->antecedents);
      free(antecedents);
       
//       levelCoord -= 5;
   }

   while(qfront != -1){
      temp = dequeue(queue, &qfront, &qback, &qcap);
//      [temp->var incrementActivity:temp->index];
      *conflictVars = push(*conflictVars, numConflictVars, capConflictVars, temp);
   }
   free(queue);
}

__attribute__((noinline))
void analyzeUIP(id<CPLEngine> engine, CPBitAssignment* conflict, id<CPBVConstraint> constraint)
{
   
   CPBitAssignment** conflictVars = malloc(sizeof(CPBitAssignment*)*32);
   CPBitAssignment** visited = malloc(sizeof(CPBitAssignment*)*256);
   
   //Get antecedents in the constraint that detected the conflict
   //These will not have been written to the constraint store
   id<CPBVConstraint> c = [(CPBitVarI*)conflict->var getImplicationForBit:conflict->index];
    
   //assert(![conflict->var isFree:conflict->index]);

   ORUInt capConflictVars = 32;
   ORUInt numConflictVars = 0;
   ORUInt vcap = 256;
   ORUInt vsize = 0;
   
   ORUInt level = [engine getLevel];
   
   CPBitAntecedents* antecedents = NULL;
   CPBitAntecedents* moreAntecedents = NULL;
   
//   if([conflict->var isFree:conflict->index])
//      NSLog(@"");
   if ((c == nil) && ![conflict->var isFree:conflict->index]) {//bit at failure was set by a choice
      CPBitAssignment* v = malloc(sizeof(CPBitAssignment));
      v->var = conflict->var;
      v->index = conflict->index;
      v->value = [conflict->var getBit:conflict->index];
      conflictVars = push(conflictVars, &numConflictVars, &capConflictVars, v);
      visited = push(visited, &vsize, &vcap, v);
   }
   else{
//      conflictVars = push(conflictVars, &numConflictVars, &capConflictVars, conflict);
//      visited = push(visited, &vsize, &vcap, v);
//   }
   CPBitAssignment assignmentBeforeConflictDetected;
      assignmentBeforeConflictDetected.var = conflict->var;
      assignmentBeforeConflictDetected.index = conflict->index;
      if([conflict->var isFree:conflict->index])
         assignmentBeforeConflictDetected.value = !conflict->value;
      else
         assignmentBeforeConflictDetected.value = [conflict->var getBit:conflict->index];
      antecedents = [c getAntecedentsFor:&assignmentBeforeConflictDetected];
}
      moreAntecedents = [constraint getAntecedents:conflict];

//   }
   
    //TEST
//    conflict->value ^= 0x1;
    
   
//    NSLog(@"Conflict in %@[%i]=%i@%i",conflict->var, conflict->index, conflict->value,[conflict->var getLevelBitWasSet:conflict->index]);
//    if(antecedents != NULL){
//    NSLog(@"Antecedents:");
//    for(int i=0;i<antecedents->numAntecedents;i++)
//        NSLog(@"\t%i:%@[%i]=%i@%i",[antecedents->antecedents[i]->var getId], antecedents->antecedents[i]->var, antecedents->antecedents[i]->index, antecedents->antecedents[i]->value,[antecedents->antecedents[i]->var getLevelBitWasSet:antecedents->antecedents[i]->index]);
//    }
//    NSLog(@"Antecedents:");
//    for(int i=0;i<moreAntecedents->numAntecedents;i++)
//        NSLog(@"\t%i:%@[%i]=%i@%i", [moreAntecedents->antecedents[i]->var getId], moreAntecedents->antecedents[i]->var, moreAntecedents->antecedents[i]->index, moreAntecedents->antecedents[i]->value,[moreAntecedents->antecedents[i]->var getLevelBitWasSet:moreAntecedents->antecedents[i]->index]);


   ORUInt numAntecedents = 0;
   
   if ((c!=nil) && antecedents != NULL)
      numAntecedents = antecedents->numAntecedents;

   if (moreAntecedents != NULL)
      numAntecedents += moreAntecedents->numAntecedents;
   
   CPBitAntecedents* reasonSide = malloc(sizeof(CPBitAntecedents));
   
   reasonSide->antecedents = malloc(sizeof(CPBitAssignment*)*numAntecedents);
   
   ORUInt idx = 0;

//<<<<<<< HEAD
//    if((c!=nil) && antecedents != nil)
//        for(int i=0;i<antecedents->numAntecedents;i++)
//            reasonSide->antecedents[idx++] = antecedents->antecedents[i];
//
//    if (moreAntecedents != nil)
//        for(int i = 0; i<moreAntecedents->numAntecedents;i++)
//            reasonSide->antecedents[idx++] = moreAntecedents->antecedents[i];
//
//=======
   if((c!=nil) && antecedents != NULL)
      for(int i=0;i<antecedents->numAntecedents;i++)
         reasonSide->antecedents[idx++] = antecedents->antecedents[i];
   
   if (moreAntecedents != NULL)
      for(int i = 0; i<moreAntecedents->numAntecedents;i++)
         reasonSide->antecedents[idx++] = moreAntecedents->antecedents[i];
   
//>>>>>>> 116184882f379e03de2b0ba0ae0408e9a4959a0b
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
   else{
      //free reasonSide memory
      if (reasonSide->antecedents)
         free(reasonSide->antecedents);
      free(reasonSide);
      NSLog(@"No antecedents to trace");
   }
   
   if (numConflictVars > 0) {
      //      NSLog(@"Adding constraint to constraint store\n");
      CPBitAntecedents* final = malloc(sizeof(CPBitAntecedents));
      CPBitAssignment** finalVars = malloc(sizeof(CPBitAssignment*)*(numConflictVars));
      ORUInt backjumpLevel = -1;
      for (int i=0; i<numConflictVars; i++) {
         CPBitAssignment* a = malloc(sizeof(CPBitAssignment));
         a->var = conflictVars[i]->var;
         a->index = conflictVars[i]->index;
         if(![conflictVars[i]->var isFree:conflictVars[i]->index])
            a->value = [conflictVars[i]->var getBit:conflictVars[i]->index];
         else
            a->value = conflictVars[i]->value;
         finalVars[i] = a;
//         [a->var incrementActivity:a->index];
         if ((ORInt)[finalVars[i]->var getLevelBitWasSet:finalVars[i]->index] < level)
//            if (((ORInt)[finalVars[i]->var getLevelBitWasSet:finalVars[i]->index] > 4) && ((ORInt)[finalVars[i]->var getLevelBitWasSet:finalVars[i]->index] < level))
            backjumpLevel = MAX((ORInt)backjumpLevel,(ORInt)[finalVars[i]->var getLevelBitWasSet:finalVars[i]->index]);
      }
      final->antecedents = finalVars;
      final->numAntecedents = numConflictVars;
      c = [CPFactory bitConflict:final];
//      if((backjumpLevel==-1) && numConflictVars==1){
//            NSLog(@"Backjump level: %d",backjumpLevel);
//         NSLog(@"%@",c);
//      }


      [engine addConstraint:c withJumpLevel:backjumpLevel];
       
//       if(([finalVars[0]->var getId]==507) && ([finalVars[1]->var getId]==510)&&(numConflictVars==46))
//           NSLog(@"");
       
       

//       printf("ants = malloc(sizeof(CPBitAntecedents));\n");
//       printf("vars= malloc(sizeof(CPBitAssignment*)*%d);\n",numConflictVars);
//       for(int i=0;i<numConflictVars;i++){
//           printf("vars[%d] = malloc(sizeof(CPBitAssignment));\n",i);
//           printf("vars[%d]->var = [engineVars objectAtIndex:%d];\n",i,[finalVars[i]->var getId]);
//           printf("vars[%d]->index = %d;",i,finalVars[i]->index);
//           if(finalVars[i]->value)
//               printf("vars[%d]->value = true;\n",i);
//           else
//               printf("vars[%d]->value = false;\n",i);
//        }
//       printf("ants->antecedents = vars;\n");
//       printf("ants->numAntecedents = %d;\n",numConflictVars);
//       printf("c =  [CPFactory bitConflict:ants];\n");
//       printf("[[cp engine] add:c];\n\n");

      
//       NSLog(@"New Constraint: %@\n\n\n\n",c);
//      NSLog(@"-------------------------------------------------------------");
//      if(final->numAntecedents==1){
//         NSLog(@"New Constraint: %@\n\n\n\n",c);
//         NSLog(@"");
//      }

   }
//   else{
//      NSLog(@"No choices found in tracing back antecedents");
//   }
   
   free(conflictVars);
   for(int i=0;i<vsize;i++)
      free(visited[i]);
   free(visited);

}

__attribute__((noinline))
ORBool checkDomainConsistency(CPBitVarI* var, ORUInt* low, ORUInt* up, ORUInt len, id<CPBVConstraint> constraint)
{
   ORUInt upXORlow;
//<<<<<<< HEAD
//   ORUInt mask;
//   ORUInt index;
//   ORUxInt bitlength = [var bitLength];
//=======
   //ORUInt mask,index,bitlength = [var bitLength];
//>>>>>>> 116184882f379e03de2b0ba0ae0408e9a4959a0b
   ORBool isConflict = false;
   
   ORUInt* conflicts = alloca(sizeof(ORUInt)*len);

//   NSLog(@"-------------------------------------------------------------------------------------------------");
//   NSLog(@"%@",constraint);
//   NSLog(@"%@",bitvar2NSString(low, up, bitlength));
   
//   ORUInt bitLength = [var bitLength];
//   up[len-1] &= CP_UMASK >> (bitLength%BITSPERWORD);
//   low[len-1] &= CP_UMASK >> (bitLength%BITSPERWORD);

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
             while(conflicts[i]){

                ORInt index = BITSPERWORD - __builtin_clz(conflicts[i]) - 1;
                assert(index<[var bitLength]);
                 ORUInt mask = 0x1 << index;
                CPBitAssignment* a = malloc(sizeof(CPBitAssignment));
                a->var = var;
                a->index = i*BITSPERWORD+index;
                if(![var isFree:a->index])
                   a->value = ![var getBit:a->index];
                else
                   a->value = false;
//                      NSLog(@"Analyzing conflict in constraint %@ for variable %lx[%d]",constraint,(unsigned long)a->var,a->index);
    //             if([constraint isKindOfClass:[CPBitShiftL class]])
    //                 NSLog(@"");
                   analyzeUIP((id<CPLEngine>)[var engine], a, constraint);
//                   failNow();
    //               mask <<=1;
    //            }
                 conflicts[i] &= ~mask;
             }
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
      ORUInt boundLow = ~low[i]._val & ~ up[i]._val;
      ORUInt boundUp = up[i]._val & low[i]._val;
      setBits += __builtin_popcount(boundLow || boundUp);
   }
   return setBits;
}

ORUInt numSetBitsORUInt(ORUInt* low, ORUInt* up, int wordLength)
{
   ORUInt setBits = 0;
   for(int i=0; i< wordLength;i++){
      ORUInt boundLow = ~low[i] & ~ up[i];
      ORUInt boundUp = up[i] & low[i];
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
//   id<CPBVConstraint> o = [[CPBitDivide alloc] initCPBitDivide:(CPBitVarI*)x
//                                                           dividedby:(CPBitVarI*)y
//                                                          equals:(CPBitVarI*)q
//                                                            rem:(CPBitVarI*)r];
   id<CPBVConstraint> o = [[CPBitDivideComposed alloc] initCPBitDivideComposed:(CPBitVarI*)x
                                                                     dividedBy:(CPBitVarI*)y
                                                                        equals:(CPBitVarI*)q
                                                                 withRemainder:(CPBitVarI*)r];
   [[x engine] trackMutable:o];
   return o;
}

+(id<CPBVConstraint>) bitDivideSigned:(id<CPBitVar>)x dividedby:(id<CPBitVar>) y equals:(id<CPBitVar>) q rem:(id<CPBitVar>)r
{
    id<CPBVConstraint> o = [[CPBitDivideSigned alloc] initCPBitDivideSigned:(CPBitVarI*)x
//    id<CPBVConstraint> o = [[CPBitDivide alloc] initCPBitDivide:(CPBitVarI*)x
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
//   id<CPBVConstraint> o = [[CPBitNotb alloc] initCPBitNotb:x eval:r];
   id<CPBVConstraint> o = [[CPBitNOT alloc] initCPBitNOT:x equals:r];

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
    _state = malloc(sizeof(ORUInt*)*2);
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
-(ORUInt)nbUVars
{
   return ![_x bound];
}
-(void) post
{
#ifdef BIT_DEBUG
   NSLog(@"Bit Equalc Constraint propagated.");
#endif
   ORUInt wordLength = [_x getWordLength];
   assert(wordLength == 1);
   
    ULRep xr = getULVarRep(_x);
    TRUInt *xLow = xr._low, *xUp = xr._up;

    ORUInt* up = alloca(sizeof(ORUInt)*wordLength);
   ORUInt* low = alloca(sizeof(ORUInt)*wordLength);
   
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
    if(_state != nil)
        free(_state);
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
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_y bound];
}
-(void) post
{
   [self propagate];
   if (![_x bound])
      [_x whenChangePropagate: self];
   if (![_y bound])
      [_y whenChangePropagate: self];
   [self propagate];
   [_x incrementActivityAll];
   [_y incrementActivityAll];

}

-(void) propagate
{
#ifdef BIT_DEBUG
   NSLog(@"Bit Equal Constraint propagated.");
#endif
   
   ORUInt wordLength = [_x getWordLength];
    
    ULRep xr = getULVarRep(_x);
    ULRep yr = getULVarRep(_y);
    TRUInt *xLow = xr._low, *xUp = xr._up;
    TRUInt *yLow = yr._low, *yUp = yr._up;
    
   ORUInt* up = alloca(sizeof(ORUInt)*wordLength);
   ORUInt* low = alloca(sizeof(ORUInt)*wordLength);

   
   for(int i=0;i<wordLength;i++){
      up[i] = xUp[i]._val & yUp[i]._val;
      low[i] = xLow[i]._val | yLow[i]._val;
   }
    
//    if([_x bitLength] < 32){
//       NSLog(@"BitEqual propagated");
//       NSLog(@"x = %@",_x);
//       NSLog(@"newX = %@",bitvar2NSString(low, up, [_x bitLength]));
//       NSLog(@"y = %@",_y);
//       NSLog(@"newY = %@\n\n",bitvar2NSString(low, up, [_y bitLength]));
//    }
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
    if(_state != nil)
        free(_state);
    [super dealloc];
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
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_y bound];
}
-(void) post
{
   [self propagate];
   if (![_x bound])
      [_x whenChangePropagate: self];
   if (![_y bound])
      [_y whenChangePropagate: self];
   [self propagate];
   [_x incrementActivityAll];
   [_y incrementActivityAll];

}

-(void) propagate
{
#ifdef BIT_DEBUG
   NSLog(@"**********************************");
   NSLog(@"Bit NOT Constraint propagated.");
#endif
   
   ORUInt wordLength = [_x getWordLength];
   ORUInt bitLength = [_x bitLength];

    ULRep xr = getULVarRep(_x);
    ULRep yr = getULVarRep(_y);
    TRUInt *xLow = xr._low, *xUp = xr._up;
    TRUInt *yLow = yr._low, *yUp = yr._up;

   
   
   ORUInt* newXUp = alloca(sizeof(ORUInt)*wordLength);
   ORUInt* newXLow = alloca(sizeof(ORUInt)*wordLength);
   ORUInt* newYUp = alloca(sizeof(ORUInt)*wordLength);
   ORUInt* newYLow = alloca(sizeof(ORUInt)*wordLength);

#ifdef BIT_DEBUG
   NSLog(@"     ~(X =%@)",_x);
   NSLog(@"  =    Y =%@",_y);
#endif
   
//   ORUInt bitMask = 0xFFFFFFFF >> (32 - bitLength%32);
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
      
   }
   
   
   if (bitLength%32 !=0)  {
      ORUInt bitMask = CP_UMASK >> (32 - (bitLength % 32));
      newXUp[wordLength-1] &= bitMask;
      newXLow[wordLength-1] &= bitMask;
      newYUp[wordLength-1] &= bitMask;
      newYLow[wordLength-1] &= bitMask;
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
   if(_state != NULL)
      free(_state);
   [super dealloc];

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
      if ((![_y isFree:index] || (~ISFREE(state[2][index/BITSPERWORD], state[3][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD)))) && ![_z getBit:index]){
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
      if ((![_x isFree:index] || (~ISFREE(state[0][index/BITSPERWORD], state[1][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD)))) && ![_z getBit:index]){
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

      if ((!xFree || (~ISFREE(state[0][index/BITSPERWORD], state[1][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD)))) && (assignment->value == xVal)) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _x;
         vars[ants->numAntecedents]->index = index;
         vars[ants->numAntecedents]->value = xVal;
         ants->numAntecedents++;
      }
      if ((!yFree || (~ISFREE(state[2][index/BITSPERWORD], state[3][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD)))) && (assignment->value == yVal)) {
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
      if (![_y isFree:index]){
//      if (![_y isFree:index]  && ![_z getBit:index]) {
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
      
//      if (![_x isFree:index] && ![_z getBit:index]){
      if (![_x isFree:index]){
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

      if (!xFree){
//      if (!xFree && (assignment->value  == xVal)){
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _x;
         vars[ants->numAntecedents]->index = index;
         vars[ants->numAntecedents]->value = [_x getBit:index];
         ants->numAntecedents++;
      }
      if (!yFree){
//         if (!yFree && (assignment->value  == yVal)){
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _y;
         vars[ants->numAntecedents]->index = index;
         vars[ants->numAntecedents]->value = [_y getBit:index];
         ants->numAntecedents++;
      }
   }
//   if(ants->numAntecedents < 2)
//      NSLog(@"BitAND traced back giving %d antecedents",ants->numAntecedents);
//   
   
//   NSLog(@"                                                3322222222221111111111");
//   NSLog(@"                                                10987654321098765432109876543210");
//   NSLog(@"x  %@",_x);
//   NSLog(@"y  %@",_y);
//   NSLog(@"z  %@",_z);
//   NSLog(@"Assignment:    %@[%d] = %d",assignment->var,assignment->index,assignment->value);
//   if(ants->numAntecedents > 0)
//      NSLog(@"antecedent[0]: %@[%d] = %d",ants->antecedents[0]->var,ants->antecedents[0]->index,ants->antecedents[0]->value);
//   if(ants->numAntecedents > 1)
//      NSLog(@"antecedent[1]: %@[%d] = %d\n\n\n",ants->antecedents[1]->var,ants->antecedents[1]->index,ants->antecedents[1]->value);
//   NSLog(@"\n\n\n");
   
   return ants;
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_y bound]+ ![_z bound];
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
   [_x incrementActivityAll];
   [_y incrementActivityAll];
   [_z incrementActivityAll];
}
-(void) propagate
{
#ifdef BIT_DEBUG
   NSLog(@"**********************************");
   NSLog(@"Bit AND Constraint propagated.");
#endif
   
    ORUInt wordLength = [_x getWordLength];
    
    ULRep xr = getULVarRep(_x);
    ULRep yr = getULVarRep(_y);
    ULRep zr = getULVarRep(_z);
    TRUInt *xLow = xr._low, *xUp = xr._up;
    TRUInt *yLow = yr._low, *yUp = yr._up;
    TRUInt *zLow = zr._low, *zUp = zr._up;

   ORUInt* newXUp = alloca(sizeof(ORUInt)*wordLength);
   ORUInt* newXLow  = alloca(sizeof(ORUInt)*wordLength);
   ORUInt* newYUp = alloca(sizeof(ORUInt)*wordLength);
   ORUInt* newYLow  = alloca(sizeof(ORUInt)*wordLength);
   ORUInt* newZUp = alloca(sizeof(ORUInt)*wordLength);
   ORUInt* newZLow  = alloca(sizeof(ORUInt)*wordLength);

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
    if(_state != nil)
        free(_state);
   [super dealloc];
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
      
      if ((!xFree || (~ISFREE(state[0][index/BITSPERWORD], state[1][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD)))) && (!assignment->value|| xVal) && (assignment->value == xVal))          {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
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
//      if ((![_y isFree:index]) && ![_z isFree:index] && [_z getBit:index]) {
       if ((![_y isFree:index] ) && ([_y getBit:index] != assignment->value)) {
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
//      if ((![_x isFree:index]) && ![_z isFree:index] && [_z getBit:index]){
       if ((![_x isFree:index]) && ([_x getBit:index] != assignment->value)) {
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
//      if ((![_x isFree:index]) && (assignment->value == [_x getBit:index])) {
       if ((![_x isFree:index]) && ([_x getBit:index] == assignment->value)){
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _x;
         vars[ants->numAntecedents]->index = index;
         vars[ants->numAntecedents]->value = [_x getBit:index];
//         if((assignment->value && vars[ants->numAntecedents]->value) || assignment->value == 0)
            ants->numAntecedents++;
      }
//      if ((![_y isFree:index]) && (assignment->value  == [_y getBit:index])) {
       if ((![_y isFree:index]) && ([_y getBit:index] == assignment->value)){
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _y;
         vars[ants->numAntecedents]->index = index;
         vars[ants->numAntecedents]->value = [_y getBit:index];
//         if((assignment->value && vars[ants->numAntecedents]->value) || assignment->value == 0)
            ants->numAntecedents++;
      }
   }
//    if(ants->numAntecedents < 2){
//      NSLog(@"BitOR traced back giving %d antecedents",ants->numAntecedents);
//
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
//    }
   return ants;
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_y bound]+ ![_z bound];
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
   [_x incrementActivityAll];
   [_y incrementActivityAll];
   [_z incrementActivityAll];

}
-(void) propagate
{
#ifdef BIT_DEBUG
   NSLog(@"**********************************");
   NSLog(@"Bit OR Constraint propagated.");
#endif
   ORUInt wordLength = [_x getWordLength];
   
    ULRep xr = getULVarRep(_x);
    ULRep yr = getULVarRep(_y);
    ULRep zr = getULVarRep(_z);
    TRUInt *xLow = xr._low, *xUp = xr._up;
    TRUInt *yLow = yr._low, *yUp = yr._up;
    TRUInt *zLow = zr._low, *zUp = zr._up;

   
   ORUInt* newXUp = alloca(sizeof(ORUInt)*wordLength);
   ORUInt* newXLow  = alloca(sizeof(ORUInt)*wordLength);
   ORUInt* newYUp = alloca(sizeof(ORUInt)*wordLength);
   ORUInt* newYLow  = alloca(sizeof(ORUInt)*wordLength);
   ORUInt* newZUp = alloca(sizeof(ORUInt)*wordLength);
   ORUInt* newZLow  = alloca(sizeof(ORUInt)*wordLength);
   
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
    if(_state != NULL)
        free(_state);
   [super dealloc];
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
//   if(ants->numAntecedents < 2)
//      NSLog(@"BitXOR traced back giving %d antecedents",ants->numAntecedents);

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
//   if(ants->numAntecedents < 2)
//      NSLog(@"BitXOR traced back giving %d antecedents",ants->numAntecedents);
    
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
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_y bound]+ ![_z bound];
}
-(void) post
{
   [self propagate];
//   if (![_x bound])
      [_x whenChangePropagate: self];
//   if (![_y bound])
      [_y whenChangePropagate: self];
//   if (![_z bound])
      [_z whenChangePropagate: self];
   [self propagate];
   [_x incrementActivityAll];
   [_y incrementActivityAll];
   [_z incrementActivityAll];
}
-(void) propagate
{
#ifdef BIT_DEBUG
   NSLog(@"**********************************");
   NSLog(@"Bit XOR Constraint propagated.");
#endif

   ORUInt wordLength = getVarWordLength(_x);

   ULRep xr = getULVarRep(_x);
   ULRep yr = getULVarRep(_y);
   ULRep zr = getULVarRep(_z);
   TRUInt *xLow = xr._low, *xUp = xr._up;
   TRUInt *yLow = yr._low, *yUp = yr._up;
   TRUInt *zLow = zr._low, *zUp = zr._up;
   
   
   ORUInt* newXUp = alloca(sizeof(ORUInt)*wordLength);
   ORUInt* newXLow  = alloca(sizeof(ORUInt)*wordLength);
   ORUInt* newYUp = alloca(sizeof(ORUInt)*wordLength);
   ORUInt* newYLow  = alloca(sizeof(ORUInt)*wordLength);
   ORUInt* newZUp = alloca(sizeof(ORUInt)*wordLength);
   ORUInt* newZLow  = alloca(sizeof(ORUInt)*wordLength);
   
#ifdef BIT_DEBUG
   NSLog(@"      X =%@",_x);
   NSLog(@" XOR  Y =%@",_y);
   NSLog(@"   =  Z=%@\n\n",_z);
#endif
   
   for(int i=0;i<wordLength;i++){
      
      // x_k=0 & y_k=0 => z_k=0
      // x_k=1 & y_k=1 => z_k=0
      newZUp[i] = zUp[i]._val & (xUp[i]._val | yUp[i]._val) & ~(xLow[i]._val & yLow[i]._val);

      //x_k=0 & y_k=1 => z_k=1
      //x_k=1 & y_k=0 => z_k=1
      newZLow[i] = zLow[i]._val | (~xUp[i]._val & yLow[i]._val) | (xLow[i]._val & ~yUp[i]._val);
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
- (void) dealloc
{
    if(_state != nil)
        free(_state);
    [super dealloc];
}
-(NSSet*) allVars
{
   return [[[NSSet alloc] initWithObjects:_w,_x,_y, _z, nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_w bound] + ![_x bound] + ![_y bound]+ ![_z bound];
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
   [_w incrementActivityAll];
   [_x incrementActivityAll];
   [_y incrementActivityAll];
   [_z incrementActivityAll];
}
-(void) propagate
{
   ORUInt wordLength = [_x getWordLength];
   
   TRUInt* wLow = [_w getLow];
   TRUInt* wUp = [_w getUp];
   TRUInt* xLow = [_x getLow];
   TRUInt* xUp = [_x getUp];
   TRUInt* yLow = [_y getLow];
   TRUInt* yUp = [_y getUp];
   TRUInt* zLow = [_z getLow];
   TRUInt* zUp = [_z getUp];
   
   ORUInt* newWUp = alloca(sizeof(ORUInt)*wordLength);
   ORUInt* newWLow = alloca(sizeof(ORUInt)*wordLength);
   ORUInt* newXUp = alloca(sizeof(ORUInt)*wordLength);
   ORUInt* newXLow  = alloca(sizeof(ORUInt)*wordLength);
   ORUInt* newYUp = alloca(sizeof(ORUInt)*wordLength);
   ORUInt* newYLow  = alloca(sizeof(ORUInt)*wordLength);
   ORUInt* newZUp = alloca(sizeof(ORUInt)*wordLength);
   ORUInt* newZLow  = alloca(sizeof(ORUInt)*wordLength);
   
   ORUInt fixed;
   ORUInt opposite;
   ORUInt trueInWY;
   ORUInt trueInWZ;
   ORUInt falseInWY;
   ORUInt falseInWZ;
   
   ORUInt upXORlow;
   
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
    [string appendString:[NSString stringWithFormat:@" %d places with ",_places]];
   [string appendString:[NSString stringWithFormat:@"%@ ",_x]];
   [string appendString:[NSString stringWithFormat:@"and %@\n",_y]];
   
   return string;
}

- (void) dealloc
{
    if(_state != nil)
        free(_state);
   [super dealloc];
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
//   NSLog(@"Assignment:    %@[%d] = %d",assignment->var,assignment->index,assignment->value);
//   if(ants->numAntecedents > 0)
//      NSLog(@"antecedent[0]: %@[%d] = %d",ants->antecedents[0]->var,ants->antecedents[0]->index,ants->antecedents[0]->value);
//   NSLog(@"\n\n\n");
//    if (ants->numAntecedents == 0)
//        NSLog(@"");
//    NSLog(@"%@\n",self);
//    NSLog(@"%@[%d]\n",assignment->var,assignment->index);
//    NSLog(@"%@[%d]\n",ants->antecedents[0]->var, ants->antecedents[0]->index);
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
   
//   NSLog(@"x  %@",_x);
//   NSLog(@"y  %@",_y);
//   NSLog(@"Assignment:    %@[%d] = %d",assignment->var,assignment->index,assignment->value);
//   if(ants->numAntecedents > 0)
//      NSLog(@"antecedent[0]: %@[%d] = %d",ants->antecedents[0]->var,ants->antecedents[0]->index,ants->antecedents[0]->value);

//   if(ants->numAntecedents == 0)
//      NSLog(@"No antecedents in bit shift l constraint");
//    if (ants->numAntecedents == 0)
//        NSLog(@"");
   return ants;
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_y bound];
}
-(void) post
{
   [self propagate];
   if (![_x bound])
      [_x whenChangePropagate: self];
   if (![_y bound])
      [_y whenChangePropagate: self];
   [self propagate];
//   [_x incrementActivityAll];
   for(ORUInt i=0; i<[_x bitLength]-_places-1;i++)
      [_x increaseActivity:i by:1];
   [_y incrementActivityAll];
}
-(void) propagate
{
#ifdef BIT_DEBUG
   NSLog(@"Bit Shift Left Constraint propagated.");
#endif
   ORUInt wordLength = [_x getWordLength];
   ORUInt bitLength = [_x bitLength];
    
    ULRep xr = getULVarRep(_x);
    ULRep yr = getULVarRep(_y);
    TRUInt *xLow = xr._low, *xUp = xr._up;
    TRUInt *yLow = yr._low, *yUp = yr._up;

   ORUInt* newXUp = alloca((sizeof(ORUInt))*(wordLength+1));
   ORUInt* newXLow  = alloca((sizeof(ORUInt))*(wordLength+1));
   ORUInt* newYUp = alloca((sizeof(ORUInt))*(wordLength+1));
   ORUInt* newYLow  = alloca((sizeof(ORUInt))*(wordLength+1));
   
//   ORUInt mask = 0xFFFFFFFF << (bitLength%BITSPERWORD + (BITSPERWORD - (_places % BITSPERWORD)));
//
//   ORUInt x;
//   ORUInt y;
   
   for(ORUInt i=0;i<wordLength;i++){
      newXLow[i] = xLow[i]._val;
      newXUp[i] = xUp[i]._val;
      newYLow[i] = yLow[i]._val;
      newYUp[i] = yUp[i]._val;
   }
   
   for(ORUInt i=0;i<_places/BITSPERWORD;i++){
//      newXLow[i] = xLow[i]._val;
//      newXUp[i] = xUp[i]._val;
      newYLow[i] = 0;
      newYUp[i] = 0;
   }
   
   ORUInt low, up;
   
   for(ORInt i=_places/BITSPERWORD;i<wordLength;i++){
      low = yLow[i]._val>>_places%BITSPERWORD;
      up = yUp[i]._val>>_places%BITSPERWORD;

      if ((_places%BITSPERWORD > 0) && (i+1<wordLength)){
         low |= yLow[i+1]._val << (BITSPERWORD-(_places%BITSPERWORD));
         up |= yUp[i+1]._val << (BITSPERWORD-(_places%BITSPERWORD));
         if (bitLength%BITSPERWORD)
            up |= CP_UMASK << (bitLength%BITSPERWORD -_places%BITSPERWORD);
      }
      else
//         up |= CP_UMASK << (BITSPERWORD-(bitLength%BITSPERWORD+_places%BITSPERWORD));
         up |= CP_UMASK << (bitLength%BITSPERWORD -_places%BITSPERWORD);

      newXLow[i-_places/BITSPERWORD] |= low;
      newXUp[i-_places/BITSPERWORD] &= up;

//      NSLog(@"%d"),i-_places/BITSPERWORD;
      
      low = xLow[i-_places/BITSPERWORD]._val << _places%BITSPERWORD;
      up = xUp[i-_places/BITSPERWORD]._val << _places%BITSPERWORD;
      if(((_places%BITSPERWORD) > 0) && ((i-((ORInt)_places/BITSPERWORD)-1)>=0)){
         low |= xLow[i-(_places/BITSPERWORD)-1]._val >> (BITSPERWORD-(_places%BITSPERWORD));
         up |= xUp[i-(_places/BITSPERWORD)-1]._val >> (BITSPERWORD-(_places%BITSPERWORD));
      }
      else if (bitLength%BITSPERWORD > 0)
         up |= CP_UMASK << (BITSPERWORD-(_places%BITSPERWORD));
      
      newYLow[i] |= low;
      newYUp[i] &= up;
   }
   
   
//   y = (yLow[_places/BITSPERWORD]._val >> _places%BITSPERWORD);
//   if((wordLength>1) && (_places/BITSPERWORD ==0))
//      y |= (yLow[_places/BITSPERWORD+1]._val << ((BITSPERWORD - _places)%BITSPERWORD));
//
//   newXLow[_places/BITSPERWORD] = xLow[_places/BITSPERWORD]._val | y;
//
//   y = yUp[_places/BITSPERWORD]._val >> _places%BITSPERWORD;
//   if(_places/BITSPERWORD >= wordLength)
//      y |= (yUp[_places/BITSPERWORD+1]._val << ((BITSPERWORD - _places)%BITSPERWORD));
//   else
//      y |= CP_UMASK  << ((BITSPERWORD - _places)%BITSPERWORD);
//
//   //mask out 0 bits shifted in with the shift right of ylow and yup
//   newXUp[_places/BITSPERWORD] = xUp[_places/BITSPERWORD]._val & y;
//
//   if(wordLength>1){
//      y=0;
//      y = yLow[wordLength-1-_places/BITSPERWORD]._val >> _places%BITSPERWORD;
//      newXLow[wordLength-1] = xLow[wordLength-1]._val | y;
//      y = yUp[wordLength-1]._val;
//      y>>= _places%BITSPERWORD;
//      y |= CP_UMASK << ((BITSPERWORD-_places)%BITSPERWORD);
//      newXUp[wordLength-1] = xUp[wordLength-1]._val & y;
//
//      newYLow[wordLength-1] = yLow[wordLength-1]._val | xLow[wordLength-1]._val << _places%BITSPERWORD;
//      newYLow[wordLength-1] |= xLow[wordLength-2]._val >> (BITSPERWORD-_places)%BITSPERWORD;
//      x= xUp[wordLength-1]._val << _places%BITSPERWORD |xUp[wordLength-2]._val >> (BITSPERWORD-_places)%BITSPERWORD;
//      newYUp[wordLength-1] = yUp[wordLength-1]._val & x;
//   }
//   else{
//      newXLow[wordLength-1] = xLow[wordLength-1]._val;
//      newXUp[wordLength-1] = xUp[wordLength-1]._val;
//      newYLow[wordLength-1] = yLow[wordLength-1]._val;
//      newYUp[wordLength-1] = yUp[wordLength-1]._val;
//   }
//
//
//
//
//   newYLow[_places/BITSPERWORD] = yLow[_places/BITSPERWORD]._val | xLow[_places/BITSPERWORD]._val << _places%BITSPERWORD;
//   newYUp[_places/BITSPERWORD] = yUp[_places/BITSPERWORD]._val & xUp[_places/BITSPERWORD]._val << _places%BITSPERWORD;
   
//   for(int i=0;i<wordLength;i++){
//      if ((int)(i+(((int)_places)/BITSPERWORD)) < wordLength) {
//         //if there are higher bits to shift here
//          if(((i<wordLength-1) &&(bitLength%BITSPERWORD)!=0))
//              mask =~(CP_UMASK << (bitLength%BITSPERWORD));
//          else
//              mask = CP_UMASK;
//          if (i==0)
//              newYUp[i] = (yUp[i]._val & (((xUp[i]._val << (_places%BITSPERWORD)))));// & mask) | ~mask));
//          else
//              newYUp[i] = (yUp[i]._val & ((xUp[i]._val << (_places%BITSPERWORD))|CP_UMASK>>(BITSPERWORD-_places%32)));// & mask) | ~mask));
//          newYLow[i] = yLow[i]._val | ((xLow[i]._val << (_places%BITSPERWORD))& mask);
//         if (((int)(i-(((int)_places)/BITSPERWORD))-1 >= 0) && (_places%BITSPERWORD != 0)) {
//            newYUp[i] &= (xUp[i-_places/32-1]._val >>(BITSPERWORD - _places%32)) | (CP_UMASK << (_places%BITSPERWORD));
//            newYLow[i] |= xLow[i-_places/32-1]._val>>(BITSPERWORD - _places%32);
//         }
//      }
//      else{
//         newYUp[i] = 0;
//         newYLow[i] = 0;
//      }
//      if ((int)(i+(int)_places/32) < wordLength) {
//          if(((bitLength%BITSPERWORD)!=0) && (i==wordLength-1))
//              mask =CP_UMASK << ((bitLength%BITSPERWORD) - (_places%BITSPERWORD));
//          else
//              mask =CP_UMASK << (BITSPERWORD-(_places%BITSPERWORD));
//
//          newXUp[i] = xUp[i]._val & (yUp[i]._val>> (_places%32)|mask);
//          newXLow[i] = xLow[i]._val |(yLow[i]._val >> _places%32);
//
//         if(((int)(i+(int)_places/32+1) < wordLength)  && (_places%BITSPERWORD != 0)){
//            newXUp[i] &= (yUp[(i+(int)_places/32+1)]._val<<(32-(_places%32)))|(CP_UMASK >> _places%BITSPERWORD);
//            newXLow[i] |= yLow[(i+(int)_places/32+1)]._val<<(32-(_places%32));
//         }
//      }
//   }
   
    ORUInt padding = CP_UMASK << (bitLength%32);
    //mask padding bits
    if(bitLength%BITSPERWORD!=0){
        newYUp[wordLength-1] &= ~padding;
        newYLow[wordLength-1] &= ~padding;
        newXUp[wordLength-1] &= ~padding;
        newXLow[wordLength-1] &= ~padding;

    }
    

//   ORUInt* fixedBitsX = alloca(sizeof(ORUInt)*wordLength);
//   ORUInt* fixedBitsY = alloca(sizeof(ORUInt)*wordLength);
//
//
//   for(ORUInt i=0;i<wordLength;i++){
//      fixedBitsX[i] = ~(newXLow[i]^newXUp[i]);
//      fixedBitsY[i] = ~(newYLow[i]^newYUp[i]);
//   }
//   for(ORInt j=0;j<bitLength;j++){
//      if ((j+_places)<bitLength){
//         if(~(newXUp[j/BITSPERWORD]^newXLow[j/BITSPERWORD]) & 0x1<<j%BITSPERWORD)
//            fixedBitsY[(j+_places)/BITSPERWORD] |= 0x1 << ((j+_places)%BITSPERWORD);
//      }
//      if((j-(ORInt)_places)>=0){
//         if(~(newYUp[j/BITSPERWORD]^newYLow[j/BITSPERWORD]) & 0x1<<j%BITSPERWORD)
//            fixedBitsX[(j-_places)/BITSPERWORD] |= 0x1 << ((j-_places)%BITSPERWORD);
//      }
//   }
//   for(ORUInt i=0;i<_places;i++)
//      fixedBitsY[i/BITSPERWORD] |= 0x1 << i%BITSPERWORD;
//
//   ORUInt temp;
//   for(ORUInt i=0;i<wordLength;i++){
//      temp = ~(newYLow[i]^newYUp[i])^fixedBitsY[i];
//         if (temp != 0)
//            NSLog(@"BUG HERE");
//      temp = ~(newXLow[i]^newXUp[i])^fixedBitsX[i];
//      if (temp != 0)
//         NSLog(@"BUG HERE");
//   }

//   if(bitLength>32){
//      NSLog(@"*******************************************");
//      NSLog(@"x << p = y");
//      NSLog(@"p= %d\n",_places);
//      NSLog(@"x= %@ with |x| = %d\n",_x,bitLength);
//      NSLog(@"y=  %@\n",_y);
//      NSLog(@"newX = %@",bitvar2NSString(newXLow, newXUp, bitLength));
//      NSLog(@"newY =         %@",bitvar2NSString(newYLow, newYUp, bitLength));
//      NSLog(@"\n");
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
   ORUInt bitLength = [_x bitLength];
   _places = places;
   _pUps4X = malloc(sizeof(ORUInt)*bitLength);
   _pLows4X = malloc(sizeof(ORUInt)*bitLength);
   _pUps4Y = malloc(sizeof(ORUInt)*bitLength);
   _pLows4Y = malloc(sizeof(ORUInt)*bitLength);
   _state = malloc(sizeof(ORUInt*)*4);
   return self;
   
}
-(NSString*) description
{
   NSMutableString* string = [NSMutableString stringWithString:[super description]];
   [string appendString:@" with "];
   [string appendString:[NSString stringWithFormat:@"%@ ",_x]];
   [string appendString:@" shift left by "];
   [string appendString:[NSString stringWithFormat:@"%@ ",_places]];
   [string appendString:[NSString stringWithFormat:@"and %@\n",_y]];
   
   return string;
}

- (void) dealloc
{
    if(_state != nil)
        free(_state);
   if (_pUps4X != nil)
      free(_pUps4X);
   if(_pLows4X != nil)
      free(_pLows4X);
   if(_pUps4Y != nil)
      free(_pUps4Y);
   if(_pLows4Y != nil)
      free(_pLows4Y);
    [super dealloc];
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

//    ORInt placesLength =[_places bitLength];
//   ORInt placesLength = _pUps4X[assignment->index] - _pLows4X[assignment->index]+1;

   ORUInt len = [_x bitLength];

   CPBitAntecedents* ants = malloc(sizeof(CPBitAntecedents));
   CPBitAssignment** vars;
   vars  = malloc(sizeof(CPBitAssignment*)*(BITSPERWORD+1+len));
   ants->numAntecedents = 0;
   
   ORInt index = assignment->index;
   ants->antecedents = vars;
   
   
//   ORUInt places = [_places getLow]->_val;
   
   if (assignment->var == _x) {
//      index = assignment->index + places;
//      if((index < len) && (![_y isFree:index] || ~ISFREE(state[2][index/BITSPERWORD], state[3][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD)))) {
//         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
//         vars[ants->numAntecedents]->var = _y;
//         vars[ants->numAntecedents]->index = index;
//         if(![_y isFree:index])
//            vars[ants->numAntecedents]->value = [_y getBit:index];
//         else
//            vars[ants->numAntecedents]->value = !((ISTRUE(state[2][index/BITSPERWORD], state[3][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD))) == 0);
//         ants->numAntecedents++;
//      }
      for(ORUInt i=_pLows4X[assignment->index];i<=_pUps4X[assignment->index];i++){
         index = assignment->index + i;
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
   }
   else
   {
      for(ORUInt i=_pLows4Y[assignment->index];i<=_pUps4Y[assignment->index];i++){
         index = assignment->index - i;
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
   }
    for(int i=0;i<BITSPERWORD;i++){
        if (![_places isFree:i])
        {
            vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
            vars[ants->numAntecedents]->var = _places;
            vars[ants->numAntecedents]->index = i;
            vars[ants->numAntecedents]->value = [_places getBit:i];
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

//   ORInt placesLength =[_places bitLength];
//   ORInt placesLength = _pUps4X[assignment->index] - _pLows4X[assignment->index]+1;
   ORUInt len = [_x bitLength];

   
   CPBitAntecedents* ants = malloc(sizeof(CPBitAntecedents));
   CPBitAssignment** vars;
    vars  = malloc(sizeof(CPBitAssignment*)*((2*len*BITSPERWORD)+1));
   ants->numAntecedents = 0;
   
//   ORUInt places = [_places getLow]->_val;
   ORInt index = assignment->index;
   ants->antecedents = vars;
    
    if(assignment->var == _places)
        NSLog(@"stop");
//
   if (assignment->var == _x) {
      for(ORUInt i=_pLows4X[assignment->index];i<=_pUps4X[assignment->index];i++){
         index = assignment->index + i;
         if((index < len) && ![_y isFree:index])
         {
            vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
            vars[ants->numAntecedents]->var = _y;
            vars[ants->numAntecedents]->index = index;
            vars[ants->numAntecedents]->value = [_y getBit:index];
            ants->numAntecedents++;
         }
      }
      for(int i=0;i<BITSPERWORD;i++)
         if ((~(_pUps4X[assignment->index] ^ _pLows4X[assignment->index])) & (0x1 << i)){
                vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
                vars[ants->numAntecedents]->var = _places;
                vars[ants->numAntecedents]->index = i;
                vars[ants->numAntecedents]->value = [_places getBit:i];
                ants->numAntecedents++;
         }
   }
   else
   {
      for(ORUInt i=_pLows4Y[assignment->index];i<=_pUps4Y[assignment->index];i++){
         index = assignment->index - i;
         if ((index >= 0) && ![_x isFree:index])
         {
            vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
            vars[ants->numAntecedents]->var = _x;
            vars[ants->numAntecedents]->index = index;
            vars[ants->numAntecedents]->value = [_x getBit:index];
            ants->numAntecedents++;
         }

      }
      for(int i=0;i<BITSPERWORD;i++)
         if ((~(_pUps4Y[assignment->index] ^ _pLows4Y[assignment->index])) & (0x1 << i)){
            vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
            vars[ants->numAntecedents]->var = _places;
            vars[ants->numAntecedents]->index = i;
            vars[ants->numAntecedents]->value = [_places getBit:i];
            ants->numAntecedents++;
         }
   }
//    for(int i=0;i<BITSPERWORD;i++){
//        if ((~((_pUp4X[assignment->index] ^ pLow4X[assignment->index))) & (0x1 << i))
//        {
//            vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
//            vars[ants->numAntecedents]->var = _places;
//            vars[ants->numAntecedents]->index = i;
//            vars[ants->numAntecedents]->value = [_places getBit:i];
//            ants->numAntecedents++;
//        }
//    }
   //   if(ants->numAntecedents == 0)
   //      NSLog(@"No antecedents in bit shift l constraint");
   return ants;
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_y bound]+ ![_places bound];
}
-(void) post
{
   [self propagate];
   if (![_x bound])
      [_x whenChangePropagate: self];
   if (![_y bound])
      [_y whenChangePropagate: self];
   if(![_places bound])
      [_places whenChangePropagate: self];
   [self propagate];
   TRUInt *up, *low;
   //ORUInt wordLength = [_x getWordLength];
//   up = alloca(sizeof(TRUInt)*wordLength);
//   low = alloca(sizeof(TRUInt)*wordLength);
   [_places getUp:&up andLow:&low];
   ORUInt p = __builtin_popcount(up->_val ^ low->_val);
   [_x incrementActivityAllBy:p];
   [_y incrementActivityAllBy:p];
   [_places incrementActivityAllBy:p*2];
}
-(void) propagate
{
#ifdef BIT_DEBUG
   NSLog(@"Bit Shift Left (by Bit Vector) Constraint propagated.");
#endif
    
    if(([_x bound] && [_y bound]) && ![_places bound])
        NSLog(@"stop");
   
   ULRep xr = getULVarRep(_x);
   ULRep yr = getULVarRep(_y);
   ULRep pr = getULVarRep(_places);
   TRUInt *xLow = xr._low, *xUp = xr._up;
   TRUInt *yLow = yr._low, *yUp = yr._up;
   TRUInt pLow = *pr._low, pUp = *pr._up;
   
   ORUInt bitLength = [_x bitLength];
   ORUInt wordLength = (bitLength / BITSPERWORD) + ((bitLength%BITSPERWORD == 0) ? 0:1);
   ORUInt totPlaces = pUp._val - pLow._val + 1;
//   ORUInt totPlaces = [_places bitLength];
   ORUInt xUps[totPlaces][wordLength], xLows[totPlaces][wordLength],
          yUps[totPlaces][wordLength], yLows[totPlaces][wordLength];
   ORUInt pBitsSet = ~(pLow._val ^ pUp._val);
   ORUInt numShifted = 0;
   
   ORUInt low, up;
   
   ORUInt   newXUp[wordLength],
            newXLow[wordLength],
            newYUp[wordLength],
            newYLow[wordLength];


//   NSLog(@"*******************************************");
//   NSLog(@"x << p = y");
//   NSLog(@"p=%@\n",_places);
//   NSLog(@"x=%@\n",_x);
//   NSLog(@"y=        %@\n",_y);

   for(ORUInt i = pLow._val;i<=pUp._val;i++){
      if(pBitsSet & (i ^ pLow._val))
         continue;
      
      for(ORUInt j=0;j<=i/BITSPERWORD;j++){
//         //      newXLow[i] = xLow[i]._val;
//         //      newXUp[i] = xUp[i]._val;
////         yLows[i-pLow._val][j] = yLow[j]._val;
////         yUps[i-pLow._val][j] = yUp[j]._val;
         yLows[numShifted][j] = yLow[j]._val;
         yUps[numShifted][j] = yUp[j]._val;
      }
      
      for(ORInt j=i/BITSPERWORD;j<wordLength;j++){
         low = yLow[j]._val>>i%BITSPERWORD;
         up = yUp[j]._val>>i%BITSPERWORD;
         
         if ((i%BITSPERWORD > 0) && (j+1<wordLength)){
            low |= yLow[j+1]._val << (BITSPERWORD-(i%BITSPERWORD));
            up &= yUp[j+1]._val << (BITSPERWORD-(i%BITSPERWORD));
            if (bitLength%BITSPERWORD)
               up |= CP_UMASK << (bitLength%BITSPERWORD -i%BITSPERWORD);
         }
         else
            //         up |= CP_UMASK << (BITSPERWORD-(bitLength%BITSPERWORD+_places%BITSPERWORD));
            up |= CP_UMASK << (bitLength%BITSPERWORD -i%BITSPERWORD);
         
            xLows[numShifted][j-i/BITSPERWORD] = low;
            xUps[numShifted][j-i/BITSPERWORD] = up;
//         newXLow[j-i/BITSPERWORD] |= low;
//         newXUp[j-i/BITSPERWORD] &= up;
         
         low = xLow[j-i/BITSPERWORD]._val << i%BITSPERWORD;
         up = xUp[j-i/BITSPERWORD]._val << i%BITSPERWORD;
         if(((i%BITSPERWORD) > 0) && ((j-((ORInt)i/BITSPERWORD)-1)>=0)){
            low |= xLow[j-(i/BITSPERWORD)-1]._val >> (BITSPERWORD-(i%BITSPERWORD));
            up &= xUp[j-(i/BITSPERWORD)-1]._val >> (BITSPERWORD-(i%BITSPERWORD));
         }
         else if (bitLength%BITSPERWORD > 0)
            up |= CP_UMASK << (BITSPERWORD-(i%BITSPERWORD));
         
            yLows[numShifted][j] = low;
            yUps[numShifted][j] = up;
//         newYLow[i] |= low;
//         newYUp[i] &= up;
      }
      numShifted++;
   }
   ORUInt allXLows[wordLength];
   ORUInt allXUps[wordLength];
   ORUInt allYLows[wordLength];
   ORUInt allYUps[wordLength];
   
   for(ORUInt j=0;j<wordLength;j++){
      allXUps[j] = ~xUps[0][j];
      allXLows[j] = xLows[0][j];
      allYUps[j] = ~yUps[0][j];
      allYLows[j] = yLows[0][j];
   }
   
   for(ORUInt i=0;i<numShifted;i++){
      for(ORUInt j=0;j<wordLength;j++){
         allXUps[j] &= ~xUps[i][j];
         allXLows[j] &= xLows[i][j];
         allYUps[j] &= ~yUps[i][j];
         allYLows[j] &= yLows[i][j];
      }
   }
   
   
   for(ORUInt i=0;i<wordLength;i++){
      newXUp[i] = xUp[i]._val & ~allXUps[i];
      newXLow[i] = xLow[i]._val | allXLows[i];
      newYUp[i] = yUp[i]._val & ~allYUps[i];
      newYLow[i] = yLow[i]._val | allYLows[i];
   }
   
   ORUInt changesX[wordLength], changesY[wordLength];
   ORUInt index;
   ORUInt mask;
   
   for(ORUInt i = 0; i<wordLength;i++){
      changesX[i] = (xUp[i]._val ^ newXUp[i]) | (xLow[i]._val ^ newXLow[i]);
      changesY[i] = (yUp[i]._val ^ newYUp[i]) | (yLow[i]._val ^ newYLow[i]);

      while(changesX[i]){
         index = BITSPERWORD - __builtin_clz(changesX[i]) - 1;
         mask = 0x1 << index;
         //update _places up and low for this bit that has just been fixed
         _pUps4X[(i*BITSPERWORD)+index] = pUp._val;
         _pLows4X[(i*BITSPERWORD)+index] = pLow._val;
         changesX[i] &= ~mask;
      }
      while(changesY[i]){
         index = BITSPERWORD - __builtin_clz(changesY[i]) - 1;
         mask = 0x1 << index;
         //update _places up and low for this bit that has just been fixed
         _pUps4Y[(i*BITSPERWORD)+index] = pUp._val;
         _pLows4Y[(i*BITSPERWORD)+index] = pLow._val;
         changesY[i] &= ~mask;
      }
   }

//   NSLog(@"newX = %@",bitvar2NSString(newXLow, newXUp, bitLength));
//   NSLog(@"newY =         %@",bitvar2NSString(newYLow, newYUp, bitLength));

   ORBool xFail = checkDomainConsistency(_x, newXLow, newXUp, wordLength, self);
   ORBool yFail = checkDomainConsistency(_y, newYLow, newYUp, wordLength, self);
   if ( xFail || yFail) {
      failNow();
   }

   [_x setUp:newXUp andLow:newXLow for:self];
   [_y setUp:newYUp andLow:newYLow for:self];

//    NSLog(@"%@", [[_x engine] model]);
   
//   if([_places bound])
//   {
//      TRUInt* pLow;
//      pLow = [_places getLow];
//      ORUInt places = pLow->_val;
//      ORUInt wordLength = [_x getWordLength];
//      ORUInt bitLength = [_x bitLength];
//
////      ORUInt mask = 0xFFFFFFFF << (bitLength%BITSPERWORD + (BITSPERWORD - (places % BITSPERWORD)));
////       ORUInt mask;
////       if (bitLength%BITSPERWORD == 0)
////           mask = 0;
////       else
////           mask = 0xFFFFFFFF << bitLength;
//       ORUInt mask = 0xFFFFFFFF << (bitLength%BITSPERWORD + (BITSPERWORD - (places % BITSPERWORD)));
//
////      TRUInt* xLow;
////      TRUInt* xUp;
////      TRUInt* yLow;
////      TRUInt* yUp;
////
////      [_x getUp:&xUp andLow:&xLow];
////      [_y getUp:&yUp andLow:&yLow];
//
//       ULRep xr = getULVarRep(_x);
//       ULRep yr = getULVarRep(_y);
//       TRUInt *xLow = xr._low, *xUp = xr._up;
//       TRUInt *yLow = yr._low, *yUp = yr._up;
//
//      ORUInt* newXUp = alloca((sizeof(ORUInt))*(wordLength+1));
//      ORUInt* newXLow  = alloca((sizeof(ORUInt))*(wordLength+1));
//      ORUInt* newYUp = alloca((sizeof(ORUInt))*(wordLength+1));
//      ORUInt* newYLow  = alloca((sizeof(ORUInt))*(wordLength+1));
////      ORUInt* yUpForX  = alloca((sizeof(ORUInt))*(wordLength+1));
//
////            NSLog(@"*******************************************");
////            NSLog(@"x << p = y");
////            NSLog(@"p=%@\n",_places);
////            NSLog(@"x=%@\n",_x);
////            NSLog(@"y=        %@\n",_y);
//
//
//      for(ORUInt i=0;i<wordLength;i++){
//         newXLow[i] = xLow[i]._val;
//         newXUp[i] = xUp[i]._val;
//         newYLow[i] = yLow[i]._val;
//         newYUp[i] = yUp[i]._val;
//      }
//
//      for(ORUInt i=0;i<places/BITSPERWORD;i++){
//         //      newXLow[i] = xLow[i]._val;
//         //      newXUp[i] = xUp[i]._val;
//         newYLow[i] = 0;
//         newYUp[i] = 0;
//      }
//
//      ORUInt low, up;
//
//      for(ORInt i=places/BITSPERWORD;i<wordLength;i++){
//         low = yLow[i]._val>>places%BITSPERWORD;
//         up = yUp[i]._val>>places%BITSPERWORD;
//
//         if ((places%BITSPERWORD > 0) && (i+1<wordLength)){
//            low |= yLow[i+1]._val << (BITSPERWORD-(places%BITSPERWORD));
//            up |= yUp[i+1]._val << (BITSPERWORD-(places%BITSPERWORD));
//            if (bitLength%BITSPERWORD)
//               up |= CP_UMASK << (bitLength%BITSPERWORD -places%BITSPERWORD);
//         }
//         else
//            //         up |= CP_UMASK << (BITSPERWORD-(bitLength%BITSPERWORD+_places%BITSPERWORD));
//            up |= CP_UMASK << (bitLength%BITSPERWORD -places%BITSPERWORD);
//
//
//         newXLow[i-places/BITSPERWORD] |= low;
//         newXUp[i-places/BITSPERWORD] &= up;
//
//         low = xLow[i-places/BITSPERWORD]._val << places%BITSPERWORD;
//         up = xUp[i-places/BITSPERWORD]._val << places%BITSPERWORD;
//         if(((places%BITSPERWORD) > 0) && ((i-((ORInt)_places/BITSPERWORD)-1)>=0)){
//            low |= xLow[i-(places/BITSPERWORD)-1]._val >> (BITSPERWORD-(places%BITSPERWORD));
//            up |= xUp[i-(places/BITSPERWORD)-1]._val >> (BITSPERWORD-(places%BITSPERWORD));
//         }
//         else if (bitLength%BITSPERWORD > 0)
//            up |= CP_UMASK << (BITSPERWORD-(places%BITSPERWORD));
//
//         newYLow[i] |= low;
//         newYUp[i] &= up;
//      }
//
//       //mask padding bits
//       if(bitLength%BITSPERWORD!=0){
//           ORUInt padding = CP_UMASK << (bitLength%32);
//           newYUp[wordLength-1] &= ~padding;
//           newYLow[wordLength-1] &= ~padding;
//           newXUp[wordLength-1] &= ~padding;
//           newXLow[wordLength-1] &= ~padding;
//
//       }
//
////            NSLog(@"newX = %@",bitvar2NSString(newXLow, newXUp, bitLength));
////            NSLog(@"newY =         %@",bitvar2NSString(newYLow, newYUp, bitLength));
//
//      _state[0] = newXUp;
//      _state[1] = newXLow;
//      _state[2] = newYUp;
//      _state[3] = newYLow;
//
//      ORBool xFail = checkDomainConsistency(_x, newXLow, newXUp, wordLength, self);
//      ORBool yFail = checkDomainConsistency(_y, newYLow, newYUp, wordLength, self);
//      if ( xFail || yFail) {
//         failNow();
//      }
//
//      [_x setUp:newXUp andLow:newXLow for:self];
//      [_y setUp:newYUp andLow:newYLow for:self];
//   }
//   else{
//       //mask off the lowest _places.low bits in y
//       ULRep yr = getULVarRep(_y);
//       TRUInt *yLow = yr._low, *yUp = yr._up;
//       ORUInt wordLength = [_y getWordLength];
//       ORUInt* newYUp = alloca((sizeof(ORUInt))*(wordLength));
//       ORUInt* newYLow  = alloca((sizeof(ORUInt))*(wordLength));
//       TRUInt* pLow = [_places getLow];
//
//       for(ORUInt i=0;i<wordLength;i++){
//           newYUp[i] = yUp[i]._val;
//           newYLow[i] = yLow[i]._val;
//           if(i < pLow[0]._val/BITSPERWORD)
//               newYUp[i]=0;
//           else if (i==pLow[0]._val/BITSPERWORD)
//               newYUp[i]=CP_UMASK << pLow[0]._val;
//
//        }
//       ORBool yFail = checkDomainConsistency(_y, newYLow, newYUp, wordLength, self);
//       if (yFail) {
//           failNow();
//       }
//
//       [_y setUp:newYUp andLow:newYLow for:self];
//
//   }
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
    if(_state != nil)
        free(_state);
    [super dealloc];
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
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_y bound];
}
-(void) post
{
   [self propagate];
   if (![_x bound])
      [_x whenChangePropagate: self];
   if (![_y bound])
      [_y whenChangePropagate: self];
   [self propagate];
//   [_x incrementActivityAll];
   for(ORUInt i=_places;i<[_x bitLength];i++)
      [_x increaseActivity:i by:1];
   [_y incrementActivityAll];
}
-(void) propagate
{
#ifdef BIT_DEBUG
   NSLog(@"Bit Shift Right Constraint propagated.");
#endif
   ORUInt wordLength = [_x getWordLength];
    ORUInt bitLength = [_x bitLength];
   
//   TRUInt* xLow;
//   TRUInt* xUp;
//   TRUInt* yLow;
//   TRUInt* yUp;
//
//   [_x getUp:&xUp andLow:&xLow];
//   [_y getUp:&yUp andLow:&yLow];
   
    ULRep xr = getULVarRep(_x);
    ULRep yr = getULVarRep(_y);
    TRUInt *xLow = xr._low, *xUp = xr._up;
    TRUInt *yLow = yr._low, *yUp = yr._up;

    ORUInt* newXUp = alloca((sizeof(ORUInt))*(wordLength+1));
   ORUInt* newXLow  = alloca((sizeof(ORUInt))*(wordLength+1));
   ORUInt* newYUp = alloca((sizeof(ORUInt))*(wordLength+1));
   ORUInt* newYLow  = alloca((sizeof(ORUInt))*(wordLength+1));
   
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
   
   ORUInt* fixedBitsX = alloca(sizeof(ORUInt)*wordLength);
   ORUInt* fixedBitsY = alloca(sizeof(ORUInt)*wordLength);
   
   
   for(ORUInt i=0;i<wordLength;i++){
      fixedBitsX[i] = ~(newXLow[i]^newXUp[i]);
      fixedBitsY[i] = ~(newYLow[i]^newYUp[i]);
   }
   for(ORInt j=0;j<bitLength;j++){
      if ((j-_places)<bitLength){
         if(~(newXUp[j/BITSPERWORD]^newXLow[j/BITSPERWORD]) & 0x1<<j%BITSPERWORD)
            fixedBitsY[(j-_places)/BITSPERWORD] |= 0x1 << ((j-_places)%BITSPERWORD);
      }
      if((j-(ORInt)_places)>=0){
         if(~(newYUp[j/BITSPERWORD]^newYLow[j/BITSPERWORD]) & 0x1<<j%BITSPERWORD)
            fixedBitsX[(j+_places)/BITSPERWORD] |= 0x1 << ((j+_places)%BITSPERWORD);
      }
   }
   for(ORUInt i=bitLength;i>bitLength-_places;i--)
      fixedBitsY[i/BITSPERWORD] |= 0x1 << i%BITSPERWORD;
   
   ORUInt temp;
   for(ORUInt i=0;i<wordLength;i++){
      temp = ~(newYLow[i]^newYUp[i])^fixedBitsY[i];
      if (temp != 0)
         NSLog(@"BUG HERE");
      temp = ~(newXLow[i]^newXUp[i])^fixedBitsX[i];
      if (temp != 0)
         NSLog(@"BUG HERE");
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
    if(_state != nil)
        free(_state);
    [super dealloc];
}
-(NSSet*) allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y, nil] autorelease];
}
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment
{
  //NSLog(@"Implication for 0x%lx[%u] = %@  traced back through %@", (unsigned long)assignment->var, assignment->index, (CPBitVarI*)assignment->var, self);



   return NULL;
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_y bound];
}
-(void) post
{
   [self propagate];
   if (![_x bound])
      [_x whenChangePropagate: self];
   if (![_y bound])
      [_y whenChangePropagate: self];
   [self propagate];
   [_x incrementActivityAll];
   [_y incrementActivityAll];
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
    if(_state != nil)
        free(_state);
    [super dealloc];
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
      if (index == len-1){
//         ULRep xr = getULVarRep(_x);
//         ULRep yr = getULVarRep(_y);
//         TRUInt *xLow = xr._low, *xUp = xr._up;
//         TRUInt *yLow = yr._low, *yUp = yr._up;
         
         ORUInt signBit = (len-_places)%BITSPERWORD-1;
//         ORUInt bitmask = 0x1 << signBit;
//         if(assignment->value){
            for(ORUInt i = signBit;i<len;i++){
//               if(yLow[i/BITSPERWORD]._val & bitmask){
               if(![_y isFree:i]){
                  vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
                  vars[ants->numAntecedents]->var = _y;
                  vars[ants->numAntecedents]->index = i;
//                  vars[ants->numAntecedents]->value = true;
               vars[ants->numAntecedents]->value = [_y getBit:i];
                  ants->numAntecedents++;
               }
//               bitmask <<= 1;
            }
//         }
//         else{
//            for(ORUInt i = signBit;i<len;i++){
//               if(~yUp[i/BITSPERWORD]._val & bitmask){
//                  vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
//                  vars[ants->numAntecedents]->var = _y;
//                  vars[ants->numAntecedents]->index = i;
//                  vars[ants->numAntecedents]->value = false;
//                  ants->numAntecedents++;
//               }
//               bitmask <<= 1;
//            }
//         }
      }
   else{
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
   }
   else{
      index = assignment->index + _places;
      if ((index < (len-1)) && ((![_x isFree:index]) || (~ISFREE(state[0][index/BITSPERWORD], state[1][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD))) == 0)) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _x;
         vars[ants->numAntecedents]->index = index;
         if(![_x isFree:index])
            vars[ants->numAntecedents]->value = [_x getBit:index];
         else
            vars[ants->numAntecedents]->value = !((ISTRUE(state[0][index/BITSPERWORD], state[1][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD))) == 0);
         ants->numAntecedents++;
      }
      else if ((index >= (len-1)) && (![_x isFree:len-1] || (~ISFREE(state[0][index/BITSPERWORD], state[1][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD))))){
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
   if(ants->numAntecedents==0)
      NSLog(@"");
   return ants;
}

-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment
{
   //NSLog(@"Implication for 0x%lx[%u] = %@  traced back through %@", (unsigned long)assignment->var, assignment->index, (CPBitVarI*)assignment->var, self);
   CPBitAntecedents* ants = malloc(sizeof(CPBitAntecedents));
   CPBitAssignment** vars;
   vars  = malloc(sizeof(CPBitAssignment*)*(_places+2));
   ants->numAntecedents = 0;
   
   ORInt index = assignment->index;
   ants->antecedents = vars;
   
   ORUInt len = [_x bitLength];
   
   ORUInt setLevel = [assignment->var getLevelBitWasSet:assignment->index];
   
   if (assignment->var == _x) {
      if (index == len-1){
//         ULRep xr = getULVarRep(_x);
         ULRep yr = getULVarRep(_y);
//         TRUInt *xLow = xr._low, *xUp = xr._up;
         TRUInt *yLow = yr._low, *yUp = yr._up;

         ORUInt signBit = (len-_places)%BITSPERWORD-1;
         ORUInt bitmask = 0x1 << signBit;
         if(assignment->value){
            for(ORUInt i = signBit;i<len;i++){
               if((yLow[i/BITSPERWORD]._val & bitmask) && ([_y getLevelBitWasSet:i]<=setLevel)){
                  vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
                  vars[ants->numAntecedents]->var = _y;
                  vars[ants->numAntecedents]->index = i;
                  vars[ants->numAntecedents]->value = [_y getBit:i];
                  ants->numAntecedents++;
               }
               bitmask <<= 1;
            }
         }
         else{
            for(ORUInt i = signBit;i<len;i++){
               if((~yUp[i/BITSPERWORD]._val & bitmask) && ([_y getLevelBitWasSet:i]<=setLevel)){
                  vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
                  vars[ants->numAntecedents]->var = _y;
                  vars[ants->numAntecedents]->index = i;
                  vars[ants->numAntecedents]->value = [_y getBit:i];
                  ants->numAntecedents++;
               }
               bitmask <<= 1;
            }
         }
      }
      else{
         index = assignment->index - _places;
         if((index >= 0) && ![_y isFree:index]){
            vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
            vars[ants->numAntecedents]->var = _y;
            vars[ants->numAntecedents]->index = index;
            vars[ants->numAntecedents]->value = [_y getBit:index];
            ants->numAntecedents++;
         }
      }
   }
   else{
      index = assignment->index + _places;
      if ((index < (len - 1 - _places)) && ![_x isFree:index]) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _x;
         vars[ants->numAntecedents]->index = index;
         vars[ants->numAntecedents]->value = [_x getBit:index];
         ants->numAntecedents++;
      }
//      else if ((index >= (len-1)) && ![_x isFree:len-1]){
      else if (![_x isFree:len-1]){
         index = len - 1;
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _x;
         vars[ants->numAntecedents]->index = index;
         vars[ants->numAntecedents]->value = [_x getBit:index];
         ants->numAntecedents++;
//         ULRep xr = getULVarRep(_x);
         ULRep yr = getULVarRep(_y);
//         TRUInt *xLow = xr._low, *xUp = xr._up;
          TRUInt *yLow = yr._low; //, *yUp = yr._up;
         
         ORUInt signBit = len%BITSPERWORD-_places%BITSPERWORD-1;
         ORUInt bitmask = 0x1 << signBit;
//         if(assignment->value){
            for(ORUInt i = signBit;i<len;i++){
               if((yLow[i/BITSPERWORD]._val & bitmask) && ([_y getLevelBitWasSet:i]<=setLevel)){
                  vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
                  vars[ants->numAntecedents]->var = _y;
                  vars[ants->numAntecedents]->index = i;
                  vars[ants->numAntecedents]->value = [_y getBit:i];
                  ants->numAntecedents++;
               }
               bitmask <<= 1;
            }
//         }
//         else{
//            for(ORUInt i = signBit;i<len;i++){
//               if((~yUp[i/BITSPERWORD]._val & bitmask) && ([_y getLevelBitWasSet:i]<=setLevel)){
//                  vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
//                  vars[ants->numAntecedents]->var = _y;
//                  vars[ants->numAntecedents]->index = i;
//                  vars[ants->numAntecedents]->value = [_y getBit:i];
//                  ants->numAntecedents++;
//               }
//               bitmask <<= 1;
//            }
//         }

      }
   }
//   NSLog(@"Assignment: %@[%d]",assignment->var,assignment->index);
//   NSLog(@"Found %d antecedents.",ants->numAntecedents);
   if(ants->numAntecedents==0)
      NSLog(@"");
   return ants;
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_y bound];
}
-(void) post
{
   [self propagate];
   if (![_x bound])
      [_x whenChangePropagate: self];
   if (![_y bound])
      [_y whenChangePropagate: self];
   [self propagate];
   [_x incrementActivityAll];
   [_y incrementActivityAll];
   [_x increaseActivity:[_x bitLength]-1 by:_places];
   for(ORUInt i=0;i<_places;i++)
      [_y increaseActivity:[_y bitLength]-_places by:_places];
}
-(void) propagate
{
#ifdef BIT_DEBUG
   NSLog(@"Bit Shift Right Arithmetic Constraint propagated.");
#endif
   ORUInt wordLength = [_x getWordLength];
   ORUInt bitLength = [_x bitLength];
   
    ULRep xr = getULVarRep(_x);
    ULRep yr = getULVarRep(_y);
    TRUInt *xLow = xr._low, *xUp = xr._up;
    TRUInt *yLow = yr._low, *yUp = yr._up;

//   ORUInt signmask = 1 << (([_x bitLength]-1)%BITSPERWORD);
//   ORUInt signSet = ((~(xLow[wordLength-1]._val^xUp[wordLength-1]._val)) & signmask);
   
   ORInt* newXUp = alloca((sizeof(ORInt))*(wordLength+1));
   ORInt* newXLow  = alloca((sizeof(ORInt))*(wordLength+1));
   ORInt* newYUp = alloca((sizeof(ORInt))*(wordLength+1));
   ORInt* newYLow  = alloca((sizeof(ORInt))*(wordLength+1));
   
//    ORInt yWordLength = [_y getWordLength];
//    ORInt yBitLength = [_y bitLength];
    
//    for(int i=0;i<wordLength;i++){
//        newXUp[i] = xUp[i]._val;
//        newXLow[i] = xLow[i]._val;
//        newYUp[i] = yUp[i]._val;
//        newYLow[i] = yLow[i]._val;
//    }

    
//    if(bitLength%BITSPERWORD !=0){
//        newXUp[wordLength-1] <<=  BITSPERWORD-(bitLength%BITSPERWORD)-1;
//        newXLow[wordLength-1] <<= BITSPERWORD-(bitLength%BITSPERWORD)-1;
//        newYUp[wordLength-1] <<= BITSPERWORD-(bitLength%BITSPERWORD)-1-_places;
//        newYLow[wordLength-1] <<= BITSPERWORD-(bitLength%BITSPERWORD)-1-_places;
//    }

//   NSLog(@"*******************************************");
//   NSLog(@"x >>a places = y");
//   NSLog(@"x=%@\n",_x);
//   NSLog(@"places=%u\n",_places);
//   NSLog(@"y=%@\n\v",_y);


   
//   for(int i=0;i<wordLength;i++){
//      if ((i+_places/32) < wordLength) {
//         newYUp[i] = ~(ISFALSE(yUp[i]._val,yLow[i]._val)|((ISFALSE(xUp[i+_places/32]._val, xLow[i+_places/32]._val)>>(_places%32))));
//         newYLow[i] = ISTRUE(yUp[i]._val,yLow[i]._val)|((ISTRUE(xUp[i+_places/32]._val, xLow[i+_places/32]._val)>>(_places%32)));
//         //         NSLog(@"i=%i",i+_places/32);
//         if((i+_places/32+1) < wordLength) {
//            newYUp[i] &= ~(ISFALSE(xUp[i+_places/32+1]._val, xLow[i+_places/32+1]._val)<<(32-(_places%32)));
//            newYLow[i] |= ISTRUE(xUp[i+_places/32+1]._val, xLow[i+_places/32+1]._val)<<(32-(_places%32));
//            //            NSLog(@"i=%i",i+_places/32+1);
//         }
//         else if (signSet & ~xUp[wordLength-1]._val) {
//            newYUp[i] &= ~(UP_MASK << (32-(_places%32)));
//            newYLow[i] &= ~(UP_MASK << (32-(_places%32)));
//         } else if (signSet * xLow[wordLength-1]._val){
//            newYUp[i] |= (UP_MASK << (32-(_places%32)));
//            newYLow[i] |= (UP_MASK << (32-(_places%32)));
//         }
//      }
//      else{
//         newYUp[i] = 0;
//         newYLow[i] = 0;
//      }
//
//      if ((i-(int)_places/32) >= 0) {
//         newXUp[i] = ~(ISFALSE(xUp[i]._val,xLow[i]._val)|((ISFALSE(yUp[i-_places/32]._val, yLow[i-_places/32]._val)<<(_places%32))));
//         newXLow[i] = ISTRUE(xUp[i]._val,xLow[i]._val)|((ISTRUE(yUp[i-_places/32]._val, yLow[i-_places/32]._val)<<(_places%32)));
//         //         NSLog(@"i=%i",i-_places/32);
//         if((i-(int)_places/32-1) >= 0) {
//            newXUp[i] &= ~(ISFALSE(yUp[(i-(int)_places/32-1)]._val,yLow[(i-(int)_places/32-1)]._val)>>(32-(_places%32)));
//            newXLow[i] |= ISTRUE(yUp[(i-(int)_places/32-1)]._val,yLow[(i-(int)_places/32-1)]._val)>>(32-(_places%32));
//            //            NSLog(@"i=%i",i-(int)_places/32-1);
//         }
//      }
//      else{
//         newXUp[i] = xUp[i]._val;
//         newXLow[i] = xLow[i]._val;
//      }
//   }

    
    for(int i=0;i<wordLength;i++){
        newXUp[i] = xUp[i]._val;
        newXLow[i] = xLow[i]._val;
        newYUp[i] = yUp[i]._val;
        newYLow[i] = yLow[i]._val;
    }
    //clear out padding bits
    ORUInt mask;
    if(bitLength%BITSPERWORD)
        mask = CP_UMASK << (BITSPERWORD - (bitLength%BITSPERWORD));
    else
        mask = 0;
    if(bitLength%BITSPERWORD != 0){
        newXUp[wordLength-1] |= mask;
        newYUp[wordLength-1] |= mask;
    }

    ORInt padding = BITSPERWORD - (bitLength%BITSPERWORD);
    padding = (padding < 32) ? padding:0;

    for(int i=0;i<wordLength;i++){
        if ((i+_places/BITSPERWORD) < wordLength) {
//            newYUp[i] = ~((ORInt)ISFALSE(newYUp[i],newYLow[i])|(((ORInt)ISFALSE(newXUp[i+_places/32], newXLow[i+_places/32])>>(_places%32))));
//            newYLow[i] = (ORInt)ISTRUE(newYUp[i],newYLow[i])|(((ORInt)ISTRUE(newXUp[i+_places/32], newXLow[i+_places/32])>>(_places%32)));
//            //         NSLog(@"i=%i",i+_places/32);
            newYUp[i] &= ((ORInt)(xUp[i]._val << padding)) >> (padding+(_places%BITSPERWORD));
            newYLow[i] |= ((ORInt)(xLow[i]._val << padding)) >> (padding+(_places%BITSPERWORD));
            if((i+_places/BITSPERWORD+1) < wordLength) {
//                newYUp[i] &= ~((ORInt)ISFALSE(newXUp[i+_places/32+1], newXLow[i+_places/32+1])<<(32-(_places%32)));
//                newYLow[i] |= (ORInt)ISTRUE(newXUp[i+_places/32+1], newXLow[i+_places/32+1])<<(32-(_places%32));
//                //            NSLog(@"i=%i",i+_places/32+1);
                newYUp[i] &= ((ORInt)(xUp[i+_places/BITSPERWORD+1]._val << padding)) >> (padding+(_places%BITSPERWORD));
                newYLow[i] |= ((ORInt)(xLow[i+_places/BITSPERWORD+1]._val << padding)) >> (padding+(_places%BITSPERWORD));

            }
        }
        else{
            newYUp[i] = 0;
            newYLow[i] = 0;
        }
        

        if ((i-(int)_places/32) >= 0) {
            
//            newXUp[i] = ~(((ORInt)ISFALSE(newXUp[i],newXLow[i])|(((ORInt)ISFALSE(newYUp[i-_places/32], newYLow[i-_places/32])<<(_places%32)))));
//            newXLow[i] = ((ORInt)ISTRUE(newXUp[i],newXLow[i])|(((ORInt)ISTRUE(newYUp[i-_places/32], newYLow[i-_places/32])<<(_places%32))));
//            //         NSLog(@"i=%i",i-_places/32);
            newXUp[i] &= (((ORInt)(newYUp[i] << (_places%BITSPERWORD))) | ~(CP_UMASK << (_places%BITSPERWORD)));
            newXLow[i] |= ((ORInt)(newYLow[i] << (_places%BITSPERWORD)));

            if((i-(int)_places/32-1) >= 0) {
//                newXUp[i] &= ~((ORInt)ISFALSE(newYUp[(i-(int)_places/32-1)],newYLow[(i-(int)_places/32-1)])>>(32-(_places%32)));
//                newXLow[i] |= ((ORInt)ISTRUE(newYUp[(i-(int)_places/32-1)],newYLow[(i-(int)_places/32-1)])>>(32-(_places%32)));
//                //            NSLog(@"i=%i",i-(int)_places/32-1);
                newXUp[i] &= ((ORInt)(yUp[(i-(int)_places/32-1)]._val) << padding) | ~mask;
                newXLow[i] |= ((ORInt)(yLow[(i-(int)_places/32-1)]._val) << padding);
            }
        }
        else{
            newXUp[i] = xUp[i]._val;
            newXLow[i] = xLow[i]._val;
        }
        
//        ORUInt signMask = CP_UMASK << (BITSPERWORD-_places + (BITSPERWORD%bitLength));
        //check if sign bits set in _y
        if(newYLow[wordLength-1-(_places/BITSPERWORD)] & (CP_UMASK <<(BITSPERWORD -((_places%BITSPERWORD)+padding)))){
            newYLow[wordLength-1-(_places/BITSPERWORD)] |= (CP_UMASK << (BITSPERWORD - (padding+(_places%BITSPERWORD))));
            newYLow[wordLength-1-(_places/BITSPERWORD)] |= mask;
            newXLow[wordLength-1-(_places/BITSPERWORD)] |= (CP_UMASK << (bitLength-1));
        }
        if ((~newYUp[wordLength-1-(_places/BITSPERWORD)] & ~mask)>>((BITSPERWORD-padding)-(_places%BITSPERWORD))){
            newYUp[wordLength-1-(_places/BITSPERWORD)] &= (~mask >> (_places%BITSPERWORD));
            newXUp[wordLength-1-(_places/BITSPERWORD)] &= (~mask >> 1);
        }
        
        if(newYLow[wordLength-1-(_places/BITSPERWORD)] & (CP_UMASK <<(BITSPERWORD -((_places%BITSPERWORD)+padding)))){
            newYLow[wordLength-1-(_places/BITSPERWORD)] |= (CP_UMASK << (BITSPERWORD - (padding+(_places%BITSPERWORD))));
            newYLow[wordLength-1-(_places/BITSPERWORD)] |= mask;
            newXLow[wordLength-1-(_places/BITSPERWORD)] |= (CP_UMASK << (bitLength-1));
        }
        if ((~newYUp[wordLength-1-(_places/BITSPERWORD)] & ~mask)>>((BITSPERWORD-padding)-(_places%BITSPERWORD))){
            newYUp[wordLength-1-(_places/BITSPERWORD)] &= (~mask >> (_places%BITSPERWORD));
            newXUp[wordLength-1-(_places/BITSPERWORD)] &= (~mask >> 1);
        }

    }
    
    

    //reset padding bits
    if(bitLength%BITSPERWORD != 0){
        newXUp[wordLength-1] &= ~mask;
        newXLow[wordLength-1] &= ~mask;
        newYUp[wordLength-1] &= ~mask;
        newYLow[wordLength-1] &= ~mask;
    }
    
//    int x = newXLow[0];
//    if(x>>_places != newYLow[0]){
//       NSLog(@"newX = %@",bitvar2NSString((ORUInt*)newXLow, (ORUInt*)newXUp, bitLength));
//       NSLog(@"newY = %@",bitvar2NSString((ORUInt*)newYLow, (ORUInt*)newYUp, bitLength));
//       NSLog(@"Places=%d",_places);
//    }
//   NSLog(@"newX = %@",bitvar2NSString((ORUInt*)newXLow, (ORUInt*)newXUp, bitLength));
//   NSLog(@"newY = %@",bitvar2NSString((ORUInt*)newYLow, (ORUInt*)newYUp, bitLength));
//    NSLog(@"Places=%d",_places);
   
//    if(bitLength%BITSPERWORD !=0){
//        newXUp[wordLength-1] >>=  BITSPERWORD-(bitLength%BITSPERWORD)-1;
//        newXLow[wordLength-1] >>= BITSPERWORD-(bitLength%BITSPERWORD)-1;
//        newYUp[wordLength-1] >>= BITSPERWORD-(bitLength%BITSPERWORD)-1-_places;
//        newYLow[wordLength-1] >>= BITSPERWORD-(bitLength%BITSPERWORD)-1-_places;
//    }

   _state[0] = (ORUInt*)newXUp;
   _state[1] = (ORUInt*)newXLow;
   _state[2] = (ORUInt*)newYUp;
   _state[3] = (ORUInt*)newYLow;
   
   ORBool xFail = checkDomainConsistency(_x, (ORUInt*)newXLow, (ORUInt*)newXUp, wordLength, self);
   ORBool yFail = checkDomainConsistency(_y, (ORUInt*)newYLow, (ORUInt*)newYUp, wordLength, self);
   if ( xFail || yFail) {
      failNow();
   }

   [_x setUp:(ORUInt*)newXUp andLow:(ORUInt*)newXLow for:self];
   [_y setUp:(ORUInt*)newYUp andLow:(ORUInt*)newYLow for:self];
   
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
   [string appendString:[NSString stringWithFormat:@"%@ places ",_places]];
   [string appendString:[NSString stringWithFormat:@"and %@\n",_y]];
   
   return string;
}

- (void) dealloc
{
    if(_state != nil)
        free(_state);
    [super dealloc];
}
-(NSSet*) allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y, nil] autorelease];
}
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment
{
  //NSLog(@"Implication for 0x%lx[%u] = %@  traced back through %@", (unsigned long)assignment->var, assignment->index, (CPBitVarI*)assignment->var, self);



   return NULL;
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_y bound];
}
-(void) post
{
   [self propagate];
   if (![_x bound])
      [_x whenChangePropagate: self];
   if (![_y bound])
      [_y whenChangePropagate: self];
   [self propagate];
   [_x incrementActivityAll];
   [_y incrementActivityAll];
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
    if(_state != nil)
        free(_state);
    [super dealloc];
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
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_y bound];
}
-(void) post
{
   [self propagate];
   if (![_x bound])
      [_x whenChangePropagate: self];
   if (![_y bound])
      [_y whenChangePropagate: self];
   [self propagate];
   [_x incrementActivityAll];
   [_y incrementActivityAll];
}
-(void) propagate
{
#ifdef BIT_DEBUG
   NSLog(@"********************************************************");
   NSLog(@"Bit Rotate Left Constraint propagated.");
#endif
   ORUInt wordLength = [_x getWordLength];
   ORUInt bitLength = [_x bitLength];
    
    ULRep xr = getULVarRep(_x);
    ULRep yr = getULVarRep(_y);
    TRUInt *xLow = xr._low, *xUp = xr._up;
    TRUInt *yLow = yr._low, *yUp = yr._up;

    ORUInt bitmask = CP_UMASK << _places;
   
   
   ORUInt* newXUp = alloca((sizeof(ORUInt))*wordLength);
   ORUInt* newXLow  = alloca((sizeof(ORUInt))*wordLength);
   ORUInt* newYUp = alloca((sizeof(ORUInt))*wordLength);
   ORUInt* newYLow  = alloca((sizeof(ORUInt))*wordLength);
   
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
    if(_state != nil)
        free(_state);
    [super dealloc];
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
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_y bound]+ ![_z bound];
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
   [_x incrementActivityAll];
   [_y incrementActivityAll];
   [_z incrementActivityAll];
}
-(void) propagate
{//   NSLog(@"Bit Sum Constraint Propagated");
   
   ORUInt wordLength = [_x getWordLength];
   
//   ORUInt bitLength = [_x bitLength];
//   if (bitLength < 32) {
//      NSLog(@"Short Bit Vector in Add");
//   }
   
   
   ORUInt change = true;
   
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
   
   ORUInt* prevXUp = alloca(sizeof(ORUInt)*wordLength);
   ORUInt* prevXLow  = alloca(sizeof(ORUInt)*wordLength);
   ORUInt* prevYUp = alloca(sizeof(ORUInt)*wordLength);
   ORUInt* prevYLow  = alloca(sizeof(ORUInt)*wordLength);
   ORUInt* prevZUp = alloca(sizeof(ORUInt)*wordLength);
   ORUInt* prevZLow  = alloca(sizeof(ORUInt)*wordLength);
   ORUInt* prevCinUp = alloca(sizeof(ORUInt)*wordLength);
   ORUInt* prevCinLow  = alloca(sizeof(ORUInt)*wordLength);
   ORUInt* prevCoutUp = alloca(sizeof(ORUInt)*wordLength);
   ORUInt* prevCoutLow  = alloca(sizeof(ORUInt)*wordLength);
   
   
   ORUInt* newXUp = alloca(sizeof(ORUInt)*wordLength);
   ORUInt* newXLow  = alloca(sizeof(ORUInt)*wordLength);
   ORUInt* newYUp = alloca(sizeof(ORUInt)*wordLength);
   ORUInt* newYLow  = alloca(sizeof(ORUInt)*wordLength);
   ORUInt* newZUp = alloca(sizeof(ORUInt)*wordLength);
   ORUInt* newZLow  = alloca(sizeof(ORUInt)*wordLength);
   ORUInt* newCinUp = alloca(sizeof(ORUInt)*wordLength);
   ORUInt* newCinLow  = alloca(sizeof(ORUInt)*wordLength);
   ORUInt* newCoutUp = alloca(sizeof(ORUInt)*wordLength);
   ORUInt* newCoutLow  = alloca(sizeof(ORUInt)*wordLength);
   
   ORUInt* shiftedCinUp = alloca(sizeof(ORUInt)*wordLength);
   ORUInt* shiftedCinLow  = alloca(sizeof(ORUInt)*wordLength);
   ORUInt* shiftedCoutUp = alloca(sizeof(ORUInt)*wordLength);
   ORUInt* shiftedCoutLow  = alloca(sizeof(ORUInt)*wordLength);
   
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
    if(_state != nil)
        free(_state);
    [super dealloc];
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
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_p bound];
}
-(void) post
{
   [self propagate];
   if (![_x bound])
      [_x whenChangePropagate: self];
   if (![_p bound])
      [_p whenChangePropagate: self];
   [self propagate];
   [_x incrementActivityAll];
}

-(void) propagate
{
#ifdef BIT_DEBUG
   NSLog(@"Bit Count Constraint propagated.");
#endif
   
   ORUInt wordLength = getVarWordLength(_x);//  [_x getWordLength];
   
//   TRUInt* xLow;
//   TRUInt* xUp;
   ORInt pLow;
   ORInt pUp;
   
    ULRep xr = getULVarRep(_x);
    TRUInt *xLow = xr._low, *xUp = xr._up;

    
//    [_x getUp:&xUp andLow:&xLow];
   pLow = [_p min];
   pUp = [_p max];
   
   ORUInt* up = alloca(sizeof(ORUInt)*wordLength);
   ORUInt* low = alloca(sizeof(ORUInt)*wordLength);
//   ORUInt  upXORlow;
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
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_xc bound];
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
//   [_x incrementActivityAll];
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
    if(_state != nil)
        free(_state);
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
-(CPBitAntecedents*) getAntecedents:(CPBitAssignment*)assignment{
   return ([self getAntecedentsFor:assignment withState:_state]);
}
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment withState:(ORUInt**)state
{
//<<<<<<< HEAD
  //NSLog(@"Implication for 0x%lx[%u] = %@  traced back through %@", (unsigned long)assignment->var, assignment->index, (CPBitVarI*)assignment->var, self);
    ORInt xLength = [_x bitLength];
    ORInt yLength = [_y bitLength];
    
//=======
//  //NSLog(@"Implication for 0x%lx[%u] = %@  traced back through %@", (unsigned long)assignment->var, assignment->index, (CPBitVarI*)assignment->var, self);
//
//   if (assignment->index >= [_x bitLength])
//      return NULL;
//
//>>>>>>> 116184882f379e03de2b0ba0ae0408e9a4959a0b
   CPBitAntecedents* ants = malloc(sizeof(CPBitAntecedents));
   CPBitAssignment** vars;
   
    vars  = malloc(sizeof(CPBitAssignment*)*yLength);
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
      else{
          index = xLength-1;
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
       }
   }
    if((assignment->index >= xLength-1))
        for(int i=yLength-1;i>=xLength;i--){
            if((assignment->var==_y)&&(i==assignment->index))
                continue;
            if ((i!=index) && (![_y isFree:i] || ~ISFREE(state[2][i/BITSPERWORD], state[3][i/BITSPERWORD]) & (0x1 << (i%BITSPERWORD)))) {
                vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
                vars[ants->numAntecedents]->var = _y;
                vars[ants->numAntecedents]->index = i;
                if(![_y isFree:i])
                    vars[ants->numAntecedents]->value = [_y getBit:i];
                else
                    vars[ants->numAntecedents]->value = !((ISTRUE(state[2][i/BITSPERWORD], state[3][i/BITSPERWORD]) & (0x1 << (i%BITSPERWORD))) == 0);
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
//<<<<<<< HEAD
  //NSLog(@"Implication for 0x%lx[%u] = %@  traced back through %@", (unsigned long)assignment->var, assignment->index, (CPBitVarI*)assignment->var, self);
//=======
//  //NSLog(@"Implication for 0x%lx[%u] = %@  traced back through %@", (unsigned long)assignment->var, assignment->index, (CPBitVarI*)assignment->var, self);
//
//   if (assignment->index >= [_x bitLength])
//      return NULL;
//>>>>>>> 116184882f379e03de2b0ba0ae0408e9a4959a0b

    ORInt xLength = [_x bitLength];
    ORInt yLength = [_y bitLength];
   CPBitAntecedents* ants = malloc(sizeof(CPBitAntecedents));
   CPBitAssignment** vars;
   
    vars  = malloc(sizeof(CPBitAssignment*)*(yLength-xLength+1));
   ants->numAntecedents = 0;
   
   ORUInt index = assignment->index;
   ants->antecedents = vars;
   
   if (assignment->var == _x) {
      if ((index < xLength) && (![_y isFree:index])) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _y;
         vars[ants->numAntecedents]->index = index;
         vars[ants->numAntecedents]->value = [_y getBit:index];
         ants->numAntecedents++;
      }

   }
   else if (assignment->var == _y){
      if ((index < xLength) && (![_x isFree:index])) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _x;
         vars[ants->numAntecedents]->index = index;
         vars[ants->numAntecedents]->value = [_x getBit:index];
         ants->numAntecedents++;
      }
      else{
          index = xLength-1;
          if  (![_x isFree:index]){
          vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
          vars[ants->numAntecedents]->var = _x;
          vars[ants->numAntecedents]->index = index;
          vars[ants->numAntecedents]->value = [_x getBit:index];
          ants->numAntecedents++;
          }
      }
   }

    
   if((assignment->index >= xLength-1))
    for(int i=yLength-1;i>=xLength;i--){
        if((assignment->var == _y) && (i==assignment->index))
            continue;
        if ((![_y isFree:index])) {
            vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
            vars[ants->numAntecedents]->var = _y;
            vars[ants->numAntecedents]->index = i;
            vars[ants->numAntecedents]->value = [_y getBit:i];
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
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_y bound];
}
-(void) post
{
   //   ORUInt xWordLength = [_x getWordLength];
   //   ORUInt yWordLength = [_y getWordLength];
   //   ORUInt wordDiff = yWordLength - xWordLength;
   //
   //   TRUInt* yLow;
   //   TRUInt* yUp;
   //   [_y getUp:&yUp andLow:&yLow];
   //   ORUInt* up = alloca(sizeof(ORUInt)*xWordLength);
   //   ORUInt* low = alloca(sizeof(ORUInt)*yWordLength);
   //   ORUInt  upXORlow;
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
   [_x incrementActivityAll];
   [_y incrementActivityAll];
//   return ORSuspend;
}

-(void) propagate
{
#ifdef BIT_DEBUG
   NSLog(@"Bit ZeroExtend Constraint propagated.");
#endif
//   NSLog(@"%@",[[_x engine]model]);

   //Check to see that upper (zero) bits are not set to 1
   ORUInt xWordLength = [_x getWordLength];
   ORUInt yWordLength = [_y getWordLength];
    //ORUInt xBitLength = [_x bitLength];
    //ORUInt yBitLength = [_y bitLength];
   //   ORUInt wordDiff = yWordLength - xWordLength;
    
    ULRep xr = getULVarRep(_x);
    ULRep yr = getULVarRep(_y);
    TRUInt *xLow = xr._low, *xUp = xr._up;
    TRUInt *yLow = yr._low, *yUp = yr._up;

//   NSLog(@"*******************************************");
//   NSLog(@"x zero extend to y");
//   NSLog(@"x=                        %@\n",_x);
//   NSLog(@"y=%@\n",_y);


   ORUInt* up = alloca(sizeof(ORUInt)*yWordLength);
   ORUInt* low = alloca(sizeof(ORUInt)*yWordLength);
//   ORUInt  upXORlow;
   
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
//       NSLog(@"newX =                         %@",bitvar2NSString(low, up, xBitLength));
//       NSLog(@"newY = %@",bitvar2NSString(low, up, yBitLength));
//   NSLog(@"");
//
//   if((yBitLength - xBitLength) < 32)
//    if(![_x bound] && [_y bound])
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
   
//   NSLog(@"%@",[[_x engine]model]);

   
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
    ORInt yLength = [_y bitLength];
    ORInt xLength = [_x bitLength];
   
   vars  = malloc(sizeof(CPBitAssignment*)*yLength);
   ants->antecedents = vars;
   ants->numAntecedents = 0;
   
   
   
   ORUInt index = assignment->index;
   
   if (assignment->var == _x) {
      if (![_y isFree:index]) {
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
         if (![_x isFree:signBit]) {
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
//       else {
//           if (![_x isFree:index] || ~ISFREE(state[0][index/BITSPERWORD], state[1][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD))) {
//             vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
//             vars[ants->numAntecedents]->var = _x;
//             vars[ants->numAntecedents]->index = index;
//             if(![_x isFree:index])
//                vars[ants->numAntecedents]->value = [_x getBit:index];
//             else
//                vars[ants->numAntecedents]->value = !((ISTRUE(state[0][index/BITSPERWORD], state[1][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD))) == 0);
//             ants->numAntecedents++;
//          }
//
//       }

   }
    if((assignment->index >= xLength-1))
        for(int i=yLength-1;i>=xLength-1;i--){
            if((assignment->var==_y)&&(i==assignment->index))
                continue;
            if ((i!=index) && (![_y isFree:i])) {
                vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
                vars[ants->numAntecedents]->var = _y;
                vars[ants->numAntecedents]->index = i;
                if(![_y isFree:i])
                    vars[ants->numAntecedents]->value = [_y getBit:i];
                else
                    vars[ants->numAntecedents]->value = !((ISTRUE(state[2][i/BITSPERWORD], state[3][i/BITSPERWORD]) & (0x1 << (i%BITSPERWORD))) == 0);
                ants->numAntecedents++;
            }
        }
//   NSLog(@"Assignment: %@[%d]",assignment->var,assignment->index);
//   NSLog(@"Found %d antecedents.",ants->numAntecedents);

    return ants;
   
}

-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment
{
  //NSLog(@"Implication for 0x%lx[%u] = %@  traced back through %@", (unsigned long)assignment->var, assignment->index, (CPBitVarI*)assignment->var, self);

    ORInt xLength = [_x bitLength];
    ORInt yLength = [_y bitLength];

   CPBitAntecedents* ants = malloc(sizeof(CPBitAntecedents));
   CPBitAssignment** vars;
   
    vars  = malloc(sizeof(CPBitAssignment*)*yLength);
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
    
    if((assignment->index >= xLength-1))
        for(int i=yLength-1;i>=xLength-1;i--){
            if((assignment->var == _y) && (i==assignment->index))
                continue;
            if ((![_y isFree:index])) {
                vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
                vars[ants->numAntecedents]->var = _y;
                vars[ants->numAntecedents]->index = i;
                vars[ants->numAntecedents]->value = [_y getBit:i];
                ants->numAntecedents++;
            }
        }

//   NSLog(@"Assignment: %@[%d]",assignment->var,assignment->index);
//   NSLog(@"Found %d antecedents.",ants->numAntecedents);
   return ants;
   
}
- (void) dealloc
{
    if(_state != nil)
        free(_state);
    [super dealloc];
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_y bound];
}
-(void) post
{
   //   ORUInt xWordLength = [_x getWordLength];
   //   ORUInt yWordLength = [_y getWordLength];
   //   ORUInt wordDiff = yWordLength - xWordLength;
   //
   //   TRUInt* yLow;
   //   TRUInt* yUp;
   //   [_y getUp:&yUp andLow:&yLow];
   //   ORUInt* up = alloca(sizeof(ORUInt)*xWordLength);
   //   ORUInt* low = alloca(sizeof(ORUInt)*yWordLength);
   //   ORUInt  upXORlow;
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
   
   ORUInt xBitLength = [_x bitLength];
   ORUInt yBitLength = [_y bitLength];
   ORUInt difference = yBitLength-xBitLength;
   [_x incrementActivityAll];
   [_x increaseActivity:xBitLength-1 by:difference];
   [_y incrementActivityAll];
   for(ORUInt i = xBitLength-1; i<yBitLength;i++)
      [_y increaseActivity:i by:difference];
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
   //   ORUInt wordDiff = yWordLength - xWordLength;
    
    ULRep xr = getULVarRep(_x);
    ULRep yr = getULVarRep(_y);
    TRUInt *xLow = xr._low, *xUp = xr._up;
    TRUInt *yLow = yr._low, *yUp = yr._up;

    ORUInt* newXUp = alloca(sizeof(ORUInt)*xWordLength);
   ORUInt* newXLow = alloca(sizeof(ORUInt)*xWordLength);
   ORUInt* newYUp = alloca(sizeof(ORUInt)*yWordLength);
   ORUInt* newYLow = alloca(sizeof(ORUInt)*yWordLength);
    
//   ORUInt  upXORlow;
   
   
//   NSLog(@"*******************************************");
//   NSLog(@"x sign extend to y");
//   NSLog(@"x=%@\n",_x);
//   NSLog(@"y=%@\n",_y);

   for (int i=0; i<xWordLength; i++) {
      newXUp[i] = xUp[i]._val;
      newXLow[i] = xLow[i]._val;
      newYUp[i] = yUp[i]._val;
      newYLow[i] = yLow[i]._val;
   }
   for(int i=xWordLength;i<yWordLength;i++){
      newYUp[i] = yUp[i]._val;
      newYLow[i] = yLow[i]._val;
   }
   
//   NSLog(@"\nx=%@\ny=%@\nnewX=%@\nnewY=%@\n",_x, _y,bitvar2NSString(newXLow, newXLow, bitLength),bitvar2NSString(newYLow, newYUp, bitLength));

   
   //copy shared bits
   if (xBitLength%BITSPERWORD)
      newXUp[xWordLength-1] |= CP_UMASK << xBitLength%BITSPERWORD;
   
   for(int i=0;i<xWordLength;i++){
//      newXUp[i] = newYUp[i] = xUp[i]._val & yUp[i]._val;
      if((i==(xWordLength-1)) && (xBitLength%BITSPERWORD)){
         newXUp[i] = xUp[i]._val & yUp[i]._val;
         newYUp[i] = ((UP_MASK << (xBitLength%BITSPERWORD)) | xUp[i]._val) & yUp[i]._val;
      }
      else
         newXUp[i] = newYUp[i] = xUp[i]._val & yUp[i]._val;

      newXLow[i] = newYLow[i] = xLow[i]._val | yLow[i]._val;
   }
   
   //mask out bits in x that are not valid in x
   newXUp[xWordLength-1] &= UP_MASK >> (BITSPERWORD - (xBitLength%BITSPERWORD));
   newXLow[xWordLength-1]&= UP_MASK >> (BITSPERWORD - (xBitLength%BITSPERWORD));
    
    
//    if ((xBitLength%BITSPERWORD != 0) && (xLow[xWordLength-1]._val & ONEAT((xBitLength-1)%32))){
//        newXUp[xWordLength-1] |= ~(((0x1 << (xBitLength%BITSPERWORD))-1));
//        newXLow[xWordLength-1] |= ~(((0x1 << (xBitLength%BITSPERWORD))-1));
//    }
//
//    if ((yBitLength%BITSPERWORD !=0) && (yLow[yWordLength-1]._val & ~(((0x1 << ((yBitLength)%BITSPERWORD))-1)))){
//        newYUp[yWordLength-1] |= ~(((0x1 << (yBitLength%BITSPERWORD))-1));
//        newYLow[yWordLength-1] |= ~(((0x1 << (yBitLength%BITSPERWORD))-1));
//    }

   //extend sign if possible
//   ORUInt signMask = UP_MASK << (xBitLength % BITSPERWORD);
    ORUInt signMask = 0x1 << ((xBitLength%BITSPERWORD)-1);
   ORUInt signIsSet = (~(xUp[xWordLength-1]._val ^ xLow[xWordLength-1]._val)) & signMask;

   if(signIsSet){
      if (signMask & xLow[xWordLength-1]._val) {
         //x is negative
         if(xBitLength%BITSPERWORD)
            newYLow[xWordLength-1] |= UP_MASK << (xBitLength%BITSPERWORD);
         for (int i=xWordLength; i<yWordLength; i++) {
            newYLow[i] |= UP_MASK;
         }
      }
      else{
         //x is positive
         newYUp[xWordLength-1] &= UP_MASK >> (BITSPERWORD -(xBitLength%BITSPERWORD));
         for (int i=xWordLength; i<yWordLength; i++) {
            newYUp[i] = 0;
         }
      }
   }
   
   ORUInt* ySignBits = alloca(sizeof(ORUInt)*yWordLength);
//    ORUInt word = ISSET(newYUp[yWordLength-1], newYLow[yWordLength-1]);
//    if (ISSET(newYUp[yWordLength-1], newYLow[yWordLength-1]) & (0x1 << (yBitLength%BITSPERWORD -1)))
//        NSLog(@"");
//
//    if (ISSET(newXUp[xWordLength-1], newXLow[xWordLength-1]) & (0x1 << (xBitLength%BITSPERWORD-1)))
//        NSLog(@"");

   //get sign from y if possible
   for (int i=0; i<yWordLength; i++) {
      //find set sign bits in y
//      ySignBits[i] = ~(yUp[i]._val ^ yLow[i]._val);
      ySignBits[i] = 0;
   }
//   //clear out x data bits (not part of the sign)
//   for (int i=0; i<xWordLength-1; i++) {
//      ySignBits[i] = 0;
//   }
//   if(xBitLength%BITSPERWORD)
//      ySignBits[xWordLength-1] &= (~(yUp[xWordLength-1]._val ^ yLow[xWordLength-1]._val) & (UP_MASK << (xBitLength%BITSPERWORD)));
//
//   //_y may not be on 32bit boundary
//   //Clear out unused bits
//   ySignBits[yWordLength-1] &=(~(yUp[xWordLength-1]._val ^ yLow[xWordLength-1]._val) & (UP_MASK >> (BITSPERWORD - (yBitLength%BITSPERWORD))));

   if(xBitLength%BITSPERWORD)
      ySignBits[xWordLength-1] =  (UP_MASK << (xBitLength%BITSPERWORD));
   for(int i=xWordLength;i<yWordLength;i++){
      ySignBits[i]= UP_MASK;
   }
   if(yBitLength%BITSPERWORD)
      ySignBits[yWordLength-1] &=  (UP_MASK >> (BITSPERWORD-(yBitLength%BITSPERWORD)));

   
   
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
//         else if (ySignBits[i] & yLow[i]._val)
         if (ySignBits[i] & yLow[i]._val)
         {
            //sign is -
            newXLow[xWordLength-1] |= signMask;
            newYLow[xWordLength-1] |= UP_MASK << ((xBitLength%BITSPERWORD)-1);
            for (int i=xWordLength; i<yWordLength; i++) {
               newYLow[i] |= UP_MASK;
            }
         }
      }
   }
   
    //clear padding bits
    if(xBitLength%BITSPERWORD !=0){
    newXUp[xWordLength-1] &= (((0x1 << (xBitLength%BITSPERWORD))-1));
    newXLow[xWordLength-1] &= (((0x1 << (xBitLength%BITSPERWORD))-1));
    }
    if(yBitLength%BITSPERWORD != 0){
    newYUp[yWordLength-1] &= (((0x1 << (yBitLength%BITSPERWORD))-1));
    newYLow[yWordLength-1] &= (((0x1 << (yBitLength%BITSPERWORD))-1));
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
   
  // assert([_y bitLength] == (_msb-_lsb));
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
    if(_state != nil)
        free(_state);
   [super dealloc];

}
-(NSString*) description
{
   NSMutableString* string = [NSMutableString stringWithString:[super description]];
   [string appendString:@" with "];
   [string appendString:[NSString stringWithFormat:@"%@ from %u to %u ",_x, _lsb, _msb]];
   [string appendString:[NSString stringWithFormat:@"and %@\n",_y]];
   
   return string;
}

-(ORUInt)nbUVars
{
   return ![_x bound] + ![_y bound];
}
-(void) post
{
   [self propagate];
   if (![_x bound])
      [_x whenChangePropagate: self];
   if (![_y bound])
      [_y whenChangePropagate: self];
   [self propagate];
   for(ORUInt i=_lsb; i<=_msb;i++)
      [_x incrementActivity:i];
////   [_x incrementActivityAll];
   [_y incrementActivityAll];
}

-(void) propagate
{
#ifdef BIT_DEBUG
   NSLog(@"Bit Extract Constraint propagated.");
#endif
   
    
    //TODO: Mangles bits > 32 for _x
   ORUInt xWordLength = [_x getWordLength];
   ORUInt yWordLength = [_y getWordLength];
//   ORUInt xBitLength = [_x bitLength];
   ORUInt yBitLength = [_y bitLength];
   
    ULRep xr = getULVarRep(_x);
    ULRep yr = getULVarRep(_y);
    TRUInt *xLow = xr._low, *xUp = xr._up;
    TRUInt *yLow = yr._low, *yUp = yr._up;

//      NSLog(@"*******************************************");
//      NSLog(@"bit extract");
//      NSLog(@"x=%@\n",_x);
//      NSLog(@"From %u to %u",_lsb, _msb);
//      NSLog(@"y=%@\n",_y);
   
   ORUInt* up = alloca(sizeof(ORUInt)*yWordLength);
   ORUInt* low = alloca(sizeof(ORUInt)*yWordLength);
   //   ORUInt* xUpForY = alloca(sizeof(ORUInt)*yWordLength);
   //   ORUInt* xLowForY =  alloca(sizeof(ORUInt)*yWordLength);
   ORUInt* newXUp = alloca(sizeof(ORUInt)*xWordLength);
   ORUInt* newXLow = alloca(sizeof(ORUInt)*xWordLength);
   ORUInt* yLowForX = alloca(sizeof(ORUInt)*yWordLength);
   ORUInt* yUpForX = alloca(sizeof(ORUInt)*yWordLength);
   
//   ORUInt  upXORlow;
   bool    inconsistencyFound = false;
   
   for(int i=0;i<xWordLength;i++){
      newXUp[i] = xUp[i]._val;
      newXLow[i] = xLow[i]._val;
   }

   for (int i = 0; i < yWordLength; i++) {
      low[i] = yLowForX[i] = yLow[i]._val;
      up[i] = yUpForX[i] = yUp[i]._val;
      
   }
   if ((yBitLength%BITSPERWORD)!=0)
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
   }
   ORUInt upperBitMask = CP_UMASK<<(_lsb%BITSPERWORD);
   ORUInt lowerBitMask = ~ upperBitMask;
   for(int i=_lsb/BITSPERWORD;i<=_msb/BITSPERWORD;i++){
      newXUp[i] = xUp[i]._val & ((yUpForX[i-(_lsb/BITSPERWORD)]<<_lsb%BITSPERWORD) | lowerBitMask);
      newXLow[i] = xLow[i]._val | ((yLowForX[i-(_lsb/BITSPERWORD)]<<_lsb%BITSPERWORD) & upperBitMask);
      if((i-(_lsb/BITSPERWORD)+1) < yWordLength){
         newXUp[i]  &= (yUpForX[i-(_lsb/BITSPERWORD)+1] >> (BITSPERWORD - (_lsb%BITSPERWORD))) | upperBitMask;
         newXLow[i] |= (yLowForX[i-(_lsb/BITSPERWORD)+1] >> (BITSPERWORD - (_lsb%BITSPERWORD))) & upperBitMask;
      }
   }
   
//   for(int i=0;i<yWordLength;i++){
//      if ((i-(int)_lsb/32) >= 0) {
//         newXUp[i] = ~(ISFALSE(xUp[i]._val,xLow[i]._val)|((ISFALSE(yUpForX[i-_lsb/32], yLowForX[i-_lsb/32])<<(_lsb%32))));
//         newXLow[i] = ISTRUE(xUp[i]._val,xLow[i]._val)|((ISTRUE(yUpForX[i-_lsb/32], yLowForX[i-_lsb/32])<<(_lsb%32)));
//         //         NSLog(@"i=%i",i-_places/32);
//         if(((_msb - _lsb)>BITSPERWORD) && (i-(int)_lsb/32-1) >= 0) {
//            newXUp[i] &= ~(ISFALSE(yUpForX[(i-(int)_lsb/32-1)],yLowForX[(i-(int)_lsb/32-1)])>>(32-(_lsb%32)));
//            newXLow[i] |= ISTRUE(yUpForX[(i-(int)_lsb/32-1)],yLowForX[(i-(int)_lsb/32-1)])>>(32-(_lsb%32));
//            //            NSLog(@"i=%i",i-(int)_places/32-1);
//         }
//      }
//      else{
//         newXUp[i] = xUp[i]._val;
//         newXLow[i] = xLow[i]._val;
//      }
//   }
   //clear unused upper bits
      ORUInt mask = ~(CP_UMASK << (_msb-_lsb+1)%32);
   if(mask){
      up[yWordLength-1] &= mask;
      low[yWordLength-1] &= mask;
   }
   
   
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
    if(_state != nil)
        free(_state);
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

-(ORUInt)nbUVars
{
   return ![_x bound] + ![_y bound]+ ![_z bound];
}
-(void) post
{
   ORUInt xWordLength = [_x getWordLength];
   ORUInt yWordLength = [_y getWordLength];
   ORUInt zWordLength = [_z getWordLength];
   
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
   [_x incrementActivityAll];
   [_y incrementActivityAll];
   [_z incrementActivityAll];
}

-(void) propagate
{
#ifdef BIT_DEBUG
   NSLog(@"Bit Concat Constraint propagated.");
#endif
    
    ULRep xr = getULVarRep(_x);
    ULRep yr = getULVarRep(_y);
    ULRep zr = getULVarRep(_z);
    TRUInt *xLow = xr._low, *xUp = xr._up;
    TRUInt *yLow = yr._low, *yUp = yr._up;
    TRUInt *zLow = zr._low, *zUp = zr._up;

    ORUInt xWordLength = [_x getWordLength];
   ORUInt yWordLength = [_y getWordLength];
   ORUInt zWordLength = [_z getWordLength];
   
//   ORUInt xBitLength = [_x bitLength];
   ORUInt yBitLength = [_y bitLength];
   ORUInt zBitLength = [_z bitLength];
   
   ORUInt* newXUp = alloca(sizeof(ORUInt)*xWordLength);
   ORUInt* newXLow = alloca(sizeof(ORUInt)*xWordLength);
   ORUInt* newYUp = alloca(sizeof(ORUInt)*yWordLength);
   ORUInt* newYLow = alloca(sizeof(ORUInt)*yWordLength);
   ORUInt* zUpForX = alloca(sizeof(ORUInt)*zWordLength);
   ORUInt* zLowForX = alloca(sizeof(ORUInt)*zWordLength);
   ORUInt* zUpForY = alloca(sizeof(ORUInt)*zWordLength);
   ORUInt* zLowForY = alloca(sizeof(ORUInt)*zWordLength);
   ORUInt* newZUp = alloca(sizeof(ORUInt)*zWordLength);
   ORUInt* newZLow = alloca(sizeof(ORUInt)*zWordLength);
//   ORUInt  upXORlow;
   
//   NSLog(@"*******************************************");
//   NSLog(@"x|y = z");
//   NSLog(@"x=%@\n",_x);
//   NSLog(@"y=%@\n",_y);
//   NSLog(@"z=%@\n\n",_z);

    
//   if([_x getId]==512)
//       NSLog(@"");
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
      zUpForX[i] = zUp[i+xWordShift]._val>>xBitShift | CP_UMASK << (BITSPERWORD-xBitShift);
      zLowForX[i] = zLow[i+xWordShift]._val>>xBitShift;
       //if bits in z corresponding to bits in a are split between adjacent words
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
   
   //make yUp for z
    ORUInt* yUpForZ = alloca(sizeof(ORUInt)*yWordLength);
    ORUInt* yLowForZ = alloca(sizeof(ORUInt)*yWordLength);

    for(int i=0;i<yWordLength;i++){
        yUpForZ[i] = yUp[i]._val;
        yLowForZ[i] = yLow[i]._val;
    }
    yUpForZ[yWordLength-1] |= CP_UMASK << (yBitLength%BITSPERWORD);
   
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
      newZUp[i] &= yUpForZ[i];
      newZLow[i] |= yLowForZ[i];
   }
//    newZUp[yWordLength-1] |= ~mask;
//    newZLow[yWordLength-1] &= mask;
    
   mask = CP_UMASK;
   mask = (CP_UMASK >> (32 - [_x bitLength])) << xBitShift;
   //   newZUp[yWordLength-1] &= mask;
   //   newZLow[yWordLength-1] &= mask;
   
   //fix for bv not on 32 bit boundary
   for(int i=0;i<xWordLength;i++){
       newZUp[i+xWordShift] &= (xUp[i]._val<<xBitShift) | ~mask;//>>xBitShift;
      newZLow[i+xWordShift] |= (xLow[i]._val<<xBitShift) & mask;//>>xBitShift;
      if (xBitShift!=0 && ((i+1+xWordShift) < zWordLength)) {
         newZUp[i+xWordShift+1] &= newXUp[i] >> (32 - xBitShift);
         newZLow[i+xWordShift+1] |= newXLow[i] >> (32 - xBitShift);
      }
   }
    mask = CP_UMASK >> (BITSPERWORD - zBitLength);
    newZUp[zWordLength-1] &= mask;
    newZLow[zWordLength-1] &= mask;
//   NSLog(@"%@\n",bitvar2NSString(newZLow, newZUp, zBitLength));
//   for(int i=0;i<zWordLength;i++){
//      upXORlow = newZUp[i] ^ newZLow[i];
//      if(((upXORlow & (~newZUp[i])) & (upXORlow & newZLow[i])) != 0){
//         failNow();
//      }
//   }
   


   _state[0] = newXUp;
   _state[1] = newXLow;
   _state[2] = newYUp;
   _state[3] = newYLow;
   _state[4] = newZUp;
   _state[5] = newZLow;
   
    if(([_z bitLength]%32)!= 0){
        ORUInt mask = CP_UMASK >> (BITSPERWORD - [_z bitLength]%32);
        newZUp[zWordLength-1] &= mask;
        newZLow[zWordLength-1] &= mask;
    }

//   NSLog(@"newX = %@",bitvar2NSString(newXLow, newXUp, xBitLength));
//   NSLog(@"newY = %@",bitvar2NSString(newYLow, newYUp, yBitLength));
//   NSLog(@"newZ = %@",bitvar2NSString(newZLow, newZUp, zBitLength));
   
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
//   ORUInt bitLength = [_x bitLength];
   ORUInt wordLength = [_x getWordLength];
   _state = malloc(sizeof(ORUInt*)*6);
   _xWhenZSet = malloc(sizeof(ORUInt*)*wordLength);
   _yWhenZSet = malloc(sizeof(ORUInt*)*wordLength);
   if([_z bound]){
      ULRep xr = getULVarRep(_x);
      ULRep yr = getULVarRep(_y);
      TRUInt *xLow = xr._low, *xUp = xr._up;
      TRUInt *yLow = yr._low, *yUp = yr._up;
      for(ORUInt i = 0; i<wordLength;i++){
         _xWhenZSet[i] = ~(xUp[i]._val ^ xLow[i]._val);
         _yWhenZSet[i] = ~(yUp[i]._val ^ yLow[i]._val);
      }
   }

   return self;
   
}
-(NSString*) description
{
   NSMutableString* string = [NSMutableString stringWithString:[super description]];
   [string appendString:[NSString stringWithFormat:@" with %@, and %@ and %@",_x, _y, _z]];
   
   return string;
}

-(CPBitAntecedents*) getAntecedents:(CPBitAssignment*)assignment{
//   return ([self getAntecedentsFor:assignment withState:_state]);
   return ([self getAntecedentsFor:assignment state:_state]);
}
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment withState:(ORUInt**)state
{
  //NSLog(@"Implication for 0x%lx[%u] = %@  traced back through %@", (unsigned long)assignment->var, assignment->index, (CPBitVarI*)assignment->var, self);

//   if(_state[5][0]){
//      return getLTAntecedents(_x, _y, _z, assignment, _state);
//   }
//   else{
//      ORUInt** state = malloc(sizeof(ORUInt*)*6);
//      state[0] = _state[2];
//      state[1] = _state[3];
//      state[2] = _state[0];
//      state[3] = _state[1];
//      state[4] = _state[4];
//      state[5] = _state[5];
//      return getLTAntecedents(_x, _y, _z, assignment, state);
//   }
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
//   TRUInt* zUp;
//   TRUInt* zLow;
   
   [_x getUp:&xUp andLow:&xLow];
   [_y getUp:&yUp andLow:&yLow];
//   [_z getUp:&zUp andLow:&zLow];

   ORUInt* xSetBits = alloca(sizeof(ORUInt)*wordLength);
   ORUInt* ySetBits = alloca(sizeof(ORUInt)*wordLength);
   

   ORInt idx=0;
   ORUInt* x1y0 = alloca(sizeof(ORUInt)*wordLength);
   
   ORUInt* xl;
   ORUInt* xu;
   ORUInt* yl;
   ORUInt* yu;
   
//   if(![_z isFree:0] && [_z getBit:0]){
   if(((assignment->var == _z) && assignment->value) || ((assignment->var != _z) && ![_z isFree:0] && [_z getBit:0])){
      for(int i=0;i<wordLength;i++){
         xl = _state[1];
         xu = _state[0];
         yl = _state[3];
         yu = _state[2];
      }
   }
   else{
      for(int i=0;i<wordLength;i++){
         xl = _state[3];
         xu = _state[2];
         yl = _state[1];
         yu = _state[0];
      }
   }
   
   for(int i=0;i<wordLength;i++){
      xSetBits[i] = ~(xl[i] ^ xu[i]);
      ySetBits[i] = ~(yl[i] ^ yu[i]);
   }

   for(int i=wordLength-1;i>=0;i--){
      x1y0[i] = ((xl[i] & xSetBits[i]) & (~yu[i] & ySetBits[i]));
      //        x1y0[i] = xLow[i]._val & ~yUp[i]._val;
      if(x1y0[i] != 0){
         idx = (i*BITSPERWORD)+(BITSPERWORD - __builtin_clz(x1y0[i])-1);
         break;
      }
   }
   index=idx;

//   NSLog(@"                                               3322222222221111111111");
//   NSLog(@"                                               10987654321098765432109876543210");
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

    
    
    if((assignment->var == _x) || (assignment->var == _y)){
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

   if(assignment->var == _x){
      if (![_y isFree:assignment->index] || (~ISFREE(state[2][assignment->index/BITSPERWORD], state[3][assignment->index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD)))) {
         yAtIndex = true;
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->index = index;
         vars[ants->numAntecedents]->var = _y;
         if(![_y isFree:index])
            vars[ants->numAntecedents]->value = [_y getBit:index];
         else
            vars[ants->numAntecedents]->value = !((ISTRUE(state[2][index/BITSPERWORD], state[3][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD))) == 0);
         if ((index>idx) && (assignment->value == 0) && (vars[ants->numAntecedents]->value == 1))
//         if ((index>idx) && (assignment->value == 0) && ([_y getBit:index]))
            index=idx-1;
//         ants->numAntecedents++;
      }
//      if (![_z isFree:0] || (~ISFREE(state[4][0], state[5][0]) & 0x1)) {
//         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
//         vars[ants->numAntecedents]->index = 0;
//         vars[ants->numAntecedents]->var = _z;
//         if(![_z isFree:0])
//            vars[ants->numAntecedents]->value = [_z getBit:0];
//         else
//            vars[ants->numAntecedents]->value = !((ISTRUE(state[4][0], state[5][0]) & 0x1) == 0);
//         ants->numAntecedents++;
//      }
   }
   else if(assignment->var == _y){
      if (![_x isFree:assignment->index] || (~ISFREE(state[0][assignment->index/BITSPERWORD], state[1][assignment->index/BITSPERWORD]) & (0x1 << (assignment->index%BITSPERWORD)))) {
         xAtIndex = true;
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->index = index;
         vars[ants->numAntecedents]->var = _x;
         if(![_x isFree:index])
            vars[ants->numAntecedents]->value = [_x getBit:index];
         else
            vars[ants->numAntecedents]->value = !((ISTRUE(state[0][index/BITSPERWORD], state[1][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD))) == 0);
         if ((index>idx) && (assignment->value == 1) && (vars[ants->numAntecedents]->value == 0))
            index=idx-1;
//         ants->numAntecedents++;
      }
//      if (![_z isFree:0] || (~ISFREE(state[4][0], state[5][0]) & 0x1)) {
//         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
//         vars[ants->numAntecedents]->index = 0;
//         vars[ants->numAntecedents]->var = _z;
//         if(![_z isFree:0])
//            vars[ants->numAntecedents]->value = [_z getBit:0];
//         else
//            vars[ants->numAntecedents]->value = !((ISTRUE(state[4][0], state[5][0]) & 0x1) == 0);
//         ants->numAntecedents++;
//      }
   }
   else if(assignment->var == _z){
//      if([_z getImplicationForBit:0] != self){
//         for(ORUInt i = 0;i<wordLength;i++){
//            xSetBits[i] = _xWhenZSet[i];
//            ySetBits[i] = _yWhenZSet[i];
//         }
//      }
      
      ORUInt* different = alloca(sizeof(ORUInt)*wordLength);
      for(int i=wordLength-1;i>=0;i--){
//         different[i] = (state[0][i] ^ state[2][i]) | (state[1][i] ^ state[3][i]);
//         different[i] = (~(xl[i]^xu[i]) & ~(yl[i]^yu[i])) & (xl[i] ^ yl[i]);
//         different[i] = ((xl[i]^xu[i]) & ~(yl[i]^yu[i])) & (xl[i] ^ yl[i]);
         different[i] = xSetBits[i] & ySetBits[i] & (xl[i] ^ yl[i]);

         if(different[i] != 0){
            diffIndex = (i*BITSPERWORD)+(BITSPERWORD - __builtin_clz(different[i]))-1;
            //             //find number of consecutive bits with x=1 and y=0
            //             //starting at msb where this is the case
//            int countBits = 0;
//            ORUInt mask = 0x1<<(diffIndex/BITSPERWORD);
//            //TODO: Should consider bit vectors over multiple words in memory
//            while((different[i] & (mask<<(diffIndex-countBits))) != 0){
//               countBits++;
//            }
//            diffIndex-=countBits-1;
            break;
         }
      }

//      if(![_z getBit:0])
         index = diffIndex;
//      else
//         index = idx;

         if (![_x isFree:assignment->index] || (~ISFREE(state[0][assignment->index/BITSPERWORD], state[1][assignment->index/BITSPERWORD]) & (0x1 << (assignment->index%BITSPERWORD)))) {
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
         if (![_y isFree:assignment->index] || (~ISFREE(state[2][assignment->index/BITSPERWORD], state[3][assignment->index/BITSPERWORD]) & (0x1 << (assignment->index%BITSPERWORD)))) {
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
      if((xSetBits[i/BITSPERWORD] & 0x1<<i%BITSPERWORD) && (((i==assignment->index) && xAtIndex) || (i!=assignment->index))){
//      if(((i==assignment->index) && xAtIndex) || ((i!=assignment->index) && (![_x isFree:i] || (~ISFREE(state[0][i/BITSPERWORD], state[1][i/BITSPERWORD]) & (0x1 << (i%BITSPERWORD)))))) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->index = i;
         vars[ants->numAntecedents]->var = _x;
         if(![_x isFree:i])
            vars[ants->numAntecedents]->value = [_x getBit:i];
         else
            vars[ants->numAntecedents]->value = !((ISTRUE(state[0][i/BITSPERWORD], state[1][i/BITSPERWORD]) & (0x1 << (i%BITSPERWORD))) == 0);
         ants->numAntecedents++;
      }
      if((ySetBits[i/BITSPERWORD] & 0x1<<i%BITSPERWORD) && (((i==assignment->index) && yAtIndex) || (i!=assignment->index))){
//      if (((i==assignment->index) && yAtIndex) || ((i!=assignment->index) && (![_y isFree:i] || (~ISFREE(state[2][i/BITSPERWORD], state[3][i/BITSPERWORD]) & (0x1 << (i%BITSPERWORD)))))) {
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
   ORInt wordLength = [_x getWordLength];
   ORUInt** state = alloca(sizeof(ORUInt*)*6);
   ORUInt*  setBits = alloca(sizeof(ORUInt)*wordLength);
   ORUInt level = [assignment->var getLevelBitWasSet:assignment->index];
   
   ULRep xr = getULVarRep(_x);
   ULRep yr = getULVarRep(_y);
   ULRep zr = getULVarRep(_z);
   TRUInt *xLow = xr._low, *xUp = xr._up;
   TRUInt *yLow = yr._low, *yUp = yr._up;
   TRUInt *zLow = zr._low, *zUp = zr._up;
   
   for(ORUInt i = 0; i<6;i++)
      state[i] = alloca(sizeof(ORUInt)*wordLength);
   
//   ORUInt* setBits = alloca(sizeof(ORUInt)*wordLength);

   if(assignment->var == _x)
      [_x getState:setBits whenBitSet:assignment->index];
   else
      [_x getState:setBits afterLevel:level];

//   [_x getState:setBits afterLevel:level];
   for(ORUInt i = 0; i<wordLength;i++){
      state[0][i] = xUp[i]._val | ~setBits[i];
      state[1][i] = xLow[i]._val & setBits[i];
   }
   
   if(assignment->var == _y)
      [_y getState:setBits whenBitSet:assignment->index];
   else
      [_y getState:setBits afterLevel:level];
   for(ORUInt i = 0; i<wordLength;i++){
      state[2][i] = yUp[i]._val | ~setBits[i];
      state[3][i] = yLow[i]._val & setBits[i];
   }
   
   if(assignment->var == _z)
      [_z getState:setBits whenBitSet:assignment->index];
   else
      [_z getState:setBits afterLevel:level];
   //   [_z getState:setBits afterLevel:level];
   state[4][0] = zUp[0]._val | ~setBits[0];
   state[5][0] = zLow[0]._val & setBits[0];
   
   return [self getAntecedentsFor:assignment state:state];
}
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment state:(ORUInt**)state
{
  //NSLog(@"Implication for 0x%lx[%u] = %@  traced back through %@", (unsigned long)assignment->var, assignment->index, (CPBitVarI*)assignment->var, self);

   ORUInt wordLength = [_x getWordLength];
   ORUInt bitLength = [_x bitLength];
   
   CPBitAntecedents* ants = malloc(sizeof(CPBitAntecedents));
   CPBitAssignment** vars;
   vars = malloc(sizeof(CPBitAssignment*)*(wordLength*BITSPERWORD*2+1));
   ants->numAntecedents = 0;
   ants->antecedents = vars;
   
//   TRUInt* xUp;
//   TRUInt* xLow;
//   TRUInt* yUp;
//   TRUInt* yLow;
//
//   [_x getUp:&xUp andLow:&xLow];
//   [_y getUp:&yUp andLow:&yLow];
//
//    ORUInt* xSetBits = alloca(sizeof(ORUInt)*wordLength);
//    ORUInt* ySetBits = alloca(sizeof(ORUInt)*wordLength);
//   ORUInt* lSetBits;
//   ORUInt* gSetBits;
//
//    ORUInt level = [assignment->var getLevelBitWasSet:assignment->index];
//
//    if(assignment->var == _x)
//        [_x getState:xSetBits whenBitSet:assignment->index];
//    else
//        [_x getState:xSetBits afterLevel:level];
//
//    if(assignment->var == _y)
//        [_y getState:ySetBits whenBitSet:assignment->index];
//    else
//        [_y getState:ySetBits afterLevel:level];
//
//   ORUInt* xl = alloca(sizeof(ORUInt)*wordLength);
//   ORUInt* xu = alloca(sizeof(ORUInt)*wordLength);
//   ORUInt* yl = alloca(sizeof(ORUInt)*wordLength);
//   ORUInt* yu = alloca(sizeof(ORUInt)*wordLength);

   ORUInt* xl;
   ORUInt* xu;
   ORUInt* yl;
   ORUInt* yu;
   
   if(![_z isFree:0] && [_z getBit:0]){
//      for(int i=0;i<wordLength;i++){
         xl = state[1];
         xu = state[0];
         yl = state[3];
         yu = state[2];
//      }
//      lSetBits=xSetBits;
//      gSetBits=ySetBits;
   }
   else{
         xl = state[3];
         xu = state[2];
         yl = state[1];
         yu = state[0];
//      }
//      lSetBits=ySetBits;
//      gSetBits=xSetBits;
   }
   

   ORInt index = assignment->index;
   ORInt idx=0;
   ORUInt* x1y0 = alloca(sizeof(ORUInt)*wordLength);

   for(int i=wordLength-1;i>=0;i--){
//      x1y0[i] = ((xl[i] & lSetBits[i]) & (~yu[i] & gSetBits[i]));
      x1y0[i] = xl[i] & ~yu[i] ;
      if(x1y0[i] != 0){
         idx = (i*BITSPERWORD)+(BITSPERWORD - __builtin_clz(x1y0[i])-1);
         break;
      }
   }

   index=idx;
   
//   NSLog(@"                                               3322222222221111111111");
//   NSLog(@"                                               10987654321098765432109876543210");
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
    
    if((assignment->var == _x) || (assignment->var == _y)){
        if(![_z isFree:0]){
            vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
            vars[ants->numAntecedents]->index = 0;
            vars[ants->numAntecedents]->var = _z;
            vars[ants->numAntecedents]->value = [_z getBit:0];
            ants->numAntecedents++;
        }
    }


   if(assignment->var == _x){
      if(![_y isFree:assignment->index]){
         yAtIndex = true;
          if ((index>idx) && ([_x getBit:index] != [_y getBit:index]))
            index=idx;
      }
   }
   else if(assignment->var == _y){
      if(![_x isFree:assignment->index]){
         xAtIndex = true;
          if ((index>idx) && ([_x getBit:index] != [_y getBit:index]))
            index=idx;
      }
   }
   else if(assignment->var == _z){
      ORUInt* different = alloca(sizeof(ORUInt)*wordLength);
      ORInt diffIndex =0;
      if([_z getImplicationForBit:0] == self)
         for(int i=wordLength-1;i>=0;i--){
   //         different[i] = (~(xUp[i]._val^xLow[i]._val) & ~(yUp[i]._val^yLow[i]._val)) & ((xUp[i]._val ^ yUp[i]._val) | (xLow[i]._val ^ yLow[i]._val));
   //         different[i] = (~(xl[i]^xu[i]) & ~(yl[i]^yu[i])) & (xl[i] ^ yl[i]);
            if([_z getImplicationForBit:0]==self)
               different[i] = _xWhenZSet[i] & _yWhenZSet[i] & (xl[i] ^ yl[i]);
            else
               different[i]= (~(xl[i]^xu[i]) & ~(yl[i]^yu[i])) & (xl[i] ^ yl[i]);

            if(different[i] != 0){
               diffIndex = (i*BITSPERWORD)+(BITSPERWORD - __builtin_clz(different[i]))-1;
               //             //find number of consecutive bits with x=1 and y=0
               //             //starting at msb where this is the case
   //            int countBits = 0;
   //            ORUInt mask = 0x1<<(diffIndex/BITSPERWORD);
   //            //TODO: Should consider bit vectors over multiple words in memory
   //            while((different[i] & (mask<<(diffIndex-countBits))) != 0){
   //               countBits++;
   //            }
   //            diffIndex-=countBits-1;
               break;
            }
         }

      if([_z getImplicationForBit:0]==self)
         for(ORUInt i = 0;i<wordLength;i++){
   //         xSetBits[i] = _xWhenZSet[i];
   //         ySetBits[i] = _yWhenZSet[i];
            state[0][i] |= ~_xWhenZSet[i];
            state[1][i] &= _xWhenZSet[i];
            state[2][i] |= ~_yWhenZSet[i];
            state[3][i] &= _yWhenZSet[i];

         }

//      NSLog(@"%@",_x);
//      NSLog(@"%@",_y);
//      NSLog(@"%@",_z);
//      if(![_z getBit:0])
         index = diffIndex;
//      else
//         index = idx;
      
//      if(![_x isFree:assignment->index]){
      if((~(state[0][assignment->index/BITSPERWORD]^state[1][assignment->index/BITSPERWORD])) & (0x1 << assignment->index%BITSPERWORD)){
         xAtIndex = true;
      }
//      if(![_y isFree:assignment->index]){
      if((~(state[2][assignment->index/BITSPERWORD]^state[3][assignment->index/BITSPERWORD])) & (0x1 << assignment->index%BITSPERWORD)){
         yAtIndex = true;
      }
   }
   
   for(int i=index; i<bitLength;i++){
      if(((~(state[0][i/BITSPERWORD]^state[1][i/BITSPERWORD])) & (0x1 << i%BITSPERWORD)) && ((i!=assignment->index) || ((i==assignment->index) && xAtIndex))){
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->index = i;
         vars[ants->numAntecedents]->var = _x;
//         vars[ants->numAntecedents]->value = [_x getBit:i];
         vars[ants->numAntecedents]->value =(state[1][i/BITSPERWORD] & (0x1 << i%BITSPERWORD)) != 0;
         ants->numAntecedents++;
      }
      if(((~(state[2][i/BITSPERWORD]^state[3][i/BITSPERWORD])) & (0x1 << i%BITSPERWORD)) && ((i!=assignment->index) || ((i==assignment->index) && yAtIndex))){
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->index = i;
         vars[ants->numAntecedents]->var = _y;
//         vars[ants->numAntecedents]->value = [_y getBit:i];
         vars[ants->numAntecedents]->value =(state[3][i/BITSPERWORD] & (0x1 << i%BITSPERWORD)) != 0;
         ants->numAntecedents++;
         
      }
   }
    
    

//   if(ants->numAntecedents > (wordLength*BITSPERWORD*2+1))
//   if((assignment->var == _z) && (assignment->value == 1))
//      NSLog(@"%d  %d",ants->numAntecedents,2*(32-assignment->index));
//    printf("%i\n",index);
   return ants;
}

- (void) dealloc
{
    if(_state != nil)
        free(_state);
    [super dealloc];
}

-(ORUInt)nbUVars
{
   return ![_x bound] + ![_y bound]+ ![_z bound];
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
//   [_x incrementActivityBySignificance];
//   [_y incrementActivityBySignificance];
//   [_z incrementActivityBySignificance];
   [_x incrementActivityAllBy:[_x bitLength]];
   [_y incrementActivityAllBy:[_x bitLength]];
//   [_z increaseActivity:0 by:[_x bitLength]+[_y bitLength]];
   [_z incrementActivityAll];

}
-(void) propagate
{
#ifdef BIT_DEBUG
   NSLog(@"**********************************");
   NSLog(@"Bit < Constraint propagated.");
#endif
   
   ORUInt wordLength = [_x getWordLength];
   if(wordLength>1)
      NSLog(@"");
//   ORUInt bitLength = [_x bitLength];
   ORUInt zWordLength = [_z getWordLength];
//   ORUInt zBitLength = [_z bitLength];
    
    ULRep xr = getULVarRep(_x);
    ULRep yr = getULVarRep(_y);
    ULRep zr = getULVarRep(_z);
    TRUInt *xLow = xr._low, *xUp = xr._up;
    TRUInt *yLow = yr._low, *yUp = yr._up;
    TRUInt *zLow = zr._low, *zUp = zr._up;

    ORUInt* newXUp = alloca(sizeof(ORUInt)*wordLength);
   ORUInt* newXLow = alloca(sizeof(ORUInt)*wordLength);
   ORUInt* newYUp = alloca(sizeof(ORUInt)*wordLength);
   ORUInt* newYLow = alloca(sizeof(ORUInt)*wordLength);
   ORUInt* newZUp = alloca(sizeof(ORUInt)*zWordLength);
   ORUInt* newZLow = alloca(sizeof(ORUInt)*zWordLength);
   
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
//   ORBool xgeqy = true;
   
   
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
    
//    ORBool yLowZero = true;
   ORBool yUpZero = true;

    
    for (int i=wordLength-1; i>=0; i--) {
//        if(newYLow[i] != 0)
//            yLowZero = false;
       if(newYUp[i] !=0)
          yUpZero = false;
        if (((newXUp[i] ^ newXLow[i]) | (newYUp[i]^ newYLow[i]) | (newXLow[i] ^ newYLow[i])) == 0)
            continue;
        else
            xeqy = false;
        if (newXLow[i] > newYUp[i]) {
//            NSLog(@"%@",_x);
//            NSLog(@"%@\n",_y);
            xgty = true;
            break;
        }
        else if (newXUp[i] < newYLow[i]) {
//            NSLog(@"%@",_x);
//            NSLog(@"%@\n",_y);
            xlty = true;
            break;
        }
    }
    //   for(int i = 0;i<wordLength;i++)
    //      if(newXLow[i] >= newYUp[i]){
    //         xgeqy = true;
    //         break;
    //      }
    
    //   if(xgeqy)
    //      newZUp[0] = 0;
    
    if(xlty){
       if(zUp[0]._val ^ zLow[0]._val){
          for(ORUInt i = 0; i<wordLength;i++){
             _xWhenZSet[i] = ~(xUp[i]._val ^ xLow[i]._val);
             _yWhenZSet[i] = ~(yUp[i]._val ^ yLow[i]._val);
          }
       }
        newZLow[0] |= 0x1;
    }
    if(xgty || xeqy){
       if(zUp[0]._val ^ zLow[0]._val){
          for(ORUInt i = 0; i<wordLength;i++){
             _xWhenZSet[i] = ~(xUp[i]._val ^ xLow[i]._val);
             _yWhenZSet[i] = ~(yUp[i]._val ^ yLow[i]._val);
          }
       }
         newZUp[0] = 0;
    }

//    if ((numFreeBitsY == 0) && yLowZero)
//        newZUp[0] = 0;
   if(yUpZero){
      if(zUp[0]._val ^ zLow[0]._val){
         for(ORUInt i = 0; i<wordLength;i++){
            _xWhenZSet[i] = ~(xUp[i]._val ^ xLow[i]._val);
            _yWhenZSet[i] = ~(yUp[i]._val ^ yLow[i]._val);
         }
      }
       newZUp[0]=0;
   }
   
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
            
//            if(zLow[0]._val){
            if(newZLow[0]){
               temp = newXLow[wordIndex] | mask;
               if(temp >= newYUp[wordIndex]){
                  newXUp[wordIndex] &= ~mask;
                  freeX[wordIndex] &= ~mask;
                  different[wordIndex] = (newXUp[wordIndex] ^ newYUp[wordIndex]) | (newXLow[wordIndex] ^ newYLow[wordIndex]);
                  numFreeBitsX--;
                  more = true;
//                  _state[0] = newXUp;
//                  _state[1] = newXLow;
//                  _state[2] = newYUp;
//                  _state[3] = newYLow;
//                  _state[4] = newZUp;
//                  _state[5] = newZLow;

//                  checkDomainConsistency(_x, newXLow, newXUp, wordLength, self);
//                  [_x setUp:newXUp andLow:newXLow for:self];
               }
//               else if(temp >= newYLow[wordIndex] && (numFreeBitsY == 0)){
//                  newXUp[wordIndex] &= ~mask;
//                  freeX[wordIndex] &= ~mask;
//                  different[wordIndex] = (newXUp[wordIndex] ^ newYUp[wordIndex]) | (newXLow[wordIndex] ^ newYLow[wordIndex]);
//                  numFreeBitsX--;
//                  more = true;
//               }

            }
//            else if (zUp[0]._val == 0){
            else if (newZUp[0] == 0){
               temp = newXUp[wordIndex] & ~mask;
               //x must be >= y
               if(temp < newYLow[wordIndex]){
                  newXLow[wordIndex] |= mask;
                  freeX[wordIndex] &= ~mask;
                  different[wordIndex] = (newXUp[wordIndex] ^ newYUp[wordIndex]) | (newXLow[wordIndex] ^ newYLow[wordIndex]);
                  numFreeBitsX--;
                  more = true;
//                  _state[0] = newXUp;
//                  _state[1] = newXLow;
//                  _state[2] = newYUp;
//                  _state[3] = newYLow;
//                  _state[4] = newZUp;
//                  _state[5] = newZLow;
                  
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
            
//            if(zLow[0]._val){ // If x < y = t, then will clearing this bit make xmin > ymax?
            if(newZLow[0]){ // If x < y = t, then will clearing this bit make xmin > ymax?
               temp = newYUp[wordIndex] & ~mask;
               if(temp <= newXLow[wordIndex]){
                  newYLow[wordIndex] |= mask;
                  freeY[wordIndex] &= ~mask;
                  different[wordIndex] = (newXUp[wordIndex] ^ newYUp[wordIndex]) | (newXLow[wordIndex] ^ newYLow[wordIndex]);
                  numFreeBitsY--;
                  more = true;
//                  _state[0] = newXUp;
//                  _state[1] = newXLow;
//                  _state[2] = newYUp;
//                  _state[3] = newYLow;
//                  _state[4] = newZUp;
//                  _state[5] = newZLow;
                  
//                  checkDomainConsistency(_y, newYLow, newYUp, wordLength, self);
//                  [_y setUp:newYUp andLow:newYLow for:self];
               }
            }
//            else if (zUp[0]._val == 0){
            else if (newZUp[0] == 0){
               temp = newYLow[wordIndex] | mask;
               //x must be >= y
               if(temp > newXUp[wordIndex]){//if we set bit in y is ymin > xmax?
                  newYUp[wordIndex] &= ~mask;
                  freeY[wordIndex] &= ~mask;
                  different[wordIndex] = (newXUp[wordIndex] ^ newYUp[wordIndex]) | (newXLow[wordIndex] ^ newYLow[wordIndex]);
                  numFreeBitsY--;
                  more = true;
//                  _state[0] = newXUp;
//                  _state[1] = newXLow;
//                  _state[2] = newYUp;
//                  _state[3] = newYLow;
//                  _state[4] = newZUp;
//                  _state[5] = newZLow;
                  
//                  checkDomainConsistency(_y, newYLow, newYUp, wordLength, self);
//                  [_y setUp:newYUp andLow:newYLow for:self];
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
   
   
   

//   _state[0] = newXUp;
//   _state[1] = newXLow;
//   _state[2] = newYUp;
//   _state[3] = newYLow;
//   _state[4] = newZUp;
//   _state[5] = newZLow;
   
//   checkDomainConsistency(_z, newZLow, newZUp, zWordLength, self);
   //   [_z setUp:newZUp andLow:newZLow for:self];

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
   
//   if(newZLow[0]){
//      if (newXLow[0] >= newYUp[0])
//          NSLog(@"fail");
//   }else{
//      if (newXUp[0] < newYLow[0])
//         NSLog(@"fail");
//   }
//    if (!newZUp[0]){
//        if(newYLow[0] > newXUp[0])
//            NSLog(@"fail");
//    }else{
//        if (newYUp[0] < newXLow[0])
//            NSLog(@"fail");
//    }
   
//    ORUInt changed=0;
//    for(ORUInt i =0; i<wordLength;i++){
//        changed |= newXUp[i] ^ xUp[i]._val;
//        changed |= newXLow[i] ^ xLow[i]._val;
//        changed |= newYUp[i] ^ yUp[i]._val;
//        changed |= newYLow[i] ^ yLow[i]._val;
//    }
//    if(changed){
//        ORUInt* xChanges = malloc(sizeof(ORUInt)*wordLength);
//        ORUInt* yChanges = malloc(sizeof(ORUInt)*wordLength);
//        for(ORUInt i=0;i<wordLength;i++){
//            xChanges[i] = newXUp[i] ^ xUp[i]._val;
//            xChanges[i] |= newXLow[i] ^ xLow[i]._val;
//            yChanges[i] = newYUp[i] ^ yUp[i]._val;
//            yChanges[i] |= newYLow[i] ^ yLow[i]._val;
//        }
//        _xChanges[_top._val] = xChanges;
//        _yChanges[_top._val] = yChanges;
//        assignTRUInt(&_top, _top._val+1, [[_x engine]trail]);
//    }
    
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
   //ORUInt bitLength= [_x bitLength];
   ORUInt wordLength = [_x getWordLength];
   _state = malloc(sizeof(ORUInt*)*6);
   _xWhenZSet = malloc(sizeof(ORUInt*)*wordLength);
   _yWhenZSet = malloc(sizeof(ORUInt*)*wordLength);
   if([_z bound]){
      ULRep xr = getULVarRep(_x);
      ULRep yr = getULVarRep(_y);
      TRUInt *xLow = xr._low, *xUp = xr._up;
      TRUInt *yLow = yr._low, *yUp = yr._up;
      for(ORUInt i = 0; i<wordLength;i++){
         _xWhenZSet[i] = ~(xUp[i]._val ^ xLow[i]._val);
         _yWhenZSet[i] = ~(yUp[i]._val ^ yLow[i]._val);
      }
   }
   return self;
   
}
-(NSString*) description
{
   NSMutableString* string = [NSMutableString stringWithString:[super description]];
   [string appendString:[NSString stringWithFormat:@" with %@, and %@ and %@",_x, _y, _z]];
   
   return string;
}

-(CPBitAntecedents*) getAntecedents:(CPBitAssignment*)assignment{
   return ([self getAntecedentsFor:assignment state:_state]);
}
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment withState:(ORUInt**)state
{
   //NSLog(@"Implication for 0x%lx[%u] = %@  traced back through %@", (unsigned long)assignment->var, assignment->index, (CPBitVarI*)assignment->var, self);
//   if(_state[5][0]){
//      return getLTAntecedents(_x, _y, _z, assignment, _state);
//   }
//   else{
//      ORUInt** state = malloc(sizeof(ORUInt*)*6);
//      state[0] = _state[2];
//      state[1] = _state[3];
//      state[2] = _state[0];
//      state[3] = _state[1];
//      state[4] = _state[4];
//      state[5] = _state[5];
//      return getLTAntecedents(_x, _y, _z, assignment, state);
//   }

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
//   TRUInt* zUp;
//   TRUInt* zLow;
   
   [_x getUp:&xUp andLow:&xLow];
   [_y getUp:&yUp andLow:&yLow];
//   [_z getUp:&zUp andLow:&zLow];
   
   ORUInt* xSetBits = alloca(sizeof(ORUInt)*wordLength);
   ORUInt* ySetBits = alloca(sizeof(ORUInt)*wordLength);
   ORUInt* lSetBits;
   ORUInt* gSetBits;

   for(int i=0;i<wordLength;i++){
      xSetBits[i] = ~(state[0][i] ^ state[1][i]);
      ySetBits[i] = ~(state[2][i] ^ state[3][i]);
   }
   
   ORInt idx=0;
   ORUInt* x1y0 = alloca(sizeof(ORUInt)*wordLength);
   
   ORUInt* xl;
   ORUInt* xu;
   ORUInt* yl;
   ORUInt* yu;
   
   if(((assignment->var == _z) && assignment->value) || ((assignment->var != _z) && (![_z isFree:0] && [_z getBit:0]))){
      for(int i=0;i<wordLength;i++){
         xl = _state[1];
         xu = _state[0];
         yl = _state[3];
         yu = _state[2];
      }
      lSetBits=xSetBits;
      gSetBits=ySetBits;
   }
   else{
      for(int i=0;i<wordLength;i++){
         xl = _state[3];
         xu = _state[2];
         yl = _state[1];
         yu = _state[0];
      }
      lSetBits=ySetBits;
      gSetBits=xSetBits;
   }
   
   
   for(int i=wordLength-1;i>=0;i--){
      x1y0[i] = ((xl[i] & lSetBits[i]) & (~yu[i] & gSetBits[i]));
      //        x1y0[i] = xLow[i]._val & ~yUp[i]._val;
      if(x1y0[i] != 0){
         idx = (i*BITSPERWORD)+(BITSPERWORD - __builtin_clz(x1y0[i])-1);
         break;
      }
   }
//   if(idx<index)
      index=idx;

   
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

    if((assignment->var == _x) || (assignment->var == _y)){
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

    
   if(assignment->var == _x){
      if (![_y isFree:assignment->index] || (~ISFREE(state[2][assignment->index/BITSPERWORD], state[3][assignment->index/BITSPERWORD]) & (0x1 << (assignment->index%BITSPERWORD)))) {
         yAtIndex = true;
                  vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
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
//      if (![_z isFree:0] || (~ISFREE(state[4][0], state[5][0]) & 0x1)) {
//         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
//         vars[ants->numAntecedents]->index = 0;
//         vars[ants->numAntecedents]->var = _z;
//         if(![_z isFree:0])
//            vars[ants->numAntecedents]->value = [_z getBit:0];
//         else
//            vars[ants->numAntecedents]->value = !((ISTRUE(state[4][0], state[5][0]) & 0x1) == 0);
//         ants->numAntecedents++;
//      }
   }
   else if(assignment->var == _y){
      if (![_x isFree:assignment->index] || (~ISFREE(state[0][assignment->index/BITSPERWORD], state[1][assignment->index/BITSPERWORD]) & (0x1 << (assignment->index%BITSPERWORD)))) {
         xAtIndex = true;
                  vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
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
//      if (![_z isFree:0] || (~ISFREE(state[4][0], state[5][0]) & 0x1)) {
//         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
//         vars[ants->numAntecedents]->index = 0;
//         vars[ants->numAntecedents]->var = _z;
//         if(![_z isFree:0])
//            vars[ants->numAntecedents]->value = [_z getBit:0];
//         else
//            vars[ants->numAntecedents]->value = !((ISTRUE(state[4][0], state[5][0]) & 0x1) == 0);
//         ants->numAntecedents++;
//      }
   }
   else if(assignment->var == _z){
//      if([_z getImplicationForBit:0]==self){
//         for(ORUInt i = 0;i<wordLength;i++){
//            xSetBits[i] = _xWhenZSet[i];
//            ySetBits[i] = _yWhenZSet[i];
//         }
//      }

      ORUInt* different = alloca(sizeof(ORUInt)*wordLength);
      for(int i=wordLength-1;i>=0;i--){
//         different[i] = (state[0][i] ^ state[2][i]) | (state[1][i] ^ state[3][i]);
//         different[i] = (~(xu[i]^xl[i]) & ~(yu[i]^yl[i])) & ((xu[i] ^ yu[i]) | (xl[i] ^ yl[i]));
//         different[i] = (~(xl[i]^xu[i]) & ~(yl[i]^yu[i])) & (xl[i] ^ yl[i]);
         different[i] = xSetBits[i] & ySetBits[i] & (xl[i] ^ yl[i]);

         if(different[i] != 0){
            diffIndex = (i*BITSPERWORD)+(BITSPERWORD - __builtin_clz(different[i]))-1;
//            //find number of consecutive bits with x=1 and y=0
//            //starting at msb where this is the case
//            int countBits = 0;
//            ORUInt mask = 0x1<<(diffIndex/BITSPERWORD);
//            while((different[i] & (mask<<(diffIndex-countBits))) != 0){
//               countBits++;
//            }
//            diffIndex-=countBits-1;
//
            break;
         }
      }
//      if(![_z getBit:0])
         index = diffIndex;
//      else
//         index = idx;
      
      if (![_x isFree:assignment->index] || (~ISFREE(state[0][assignment->index/BITSPERWORD], state[1][assignment->index/BITSPERWORD]) & (0x1 << (assignment->index%BITSPERWORD)))) {
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
      if (![_y isFree:assignment->index] || (~ISFREE(state[2][assignment->index/BITSPERWORD], state[3][assignment->index/BITSPERWORD]) & (0x1 << (assignment->index%BITSPERWORD)))) {
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
//   for(int i=index; i<bitLength;i++){
       if((xSetBits[i/BITSPERWORD] & 0x1<<i%BITSPERWORD) && (((i==assignment->index) && xAtIndex) || (i!=assignment->index))){
//      if(((i==assignment->index) && xAtIndex) || ((i!=assignment->index) && (![_x isFree:i] || (~ISFREE(state[0][i/BITSPERWORD], state[1][i/BITSPERWORD]) & (0x1 << (i%BITSPERWORD)))))) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->index = i;
         vars[ants->numAntecedents]->var = _x;
         if(![_x isFree:i])
            vars[ants->numAntecedents]->value = [_x getBit:i];
         else
            vars[ants->numAntecedents]->value = !((ISTRUE(state[0][i/BITSPERWORD], state[1][i/BITSPERWORD]) & (0x1 << (i%BITSPERWORD))) == 0);
         ants->numAntecedents++;
      }
//      if (((i==assignment->index) && yAtIndex) || ((i!=assignment->index) && (![_y isFree:i] || (~ISFREE(state[2][i/BITSPERWORD], state[3][i/BITSPERWORD]) & (0x1 << (i%BITSPERWORD)))))) {
       if((ySetBits[i/BITSPERWORD] & 0x1<<i%BITSPERWORD) && (((i==assignment->index) && yAtIndex) || (i!=assignment->index))){
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
   ORInt wordLength = [_x getWordLength];
   ORUInt** state = alloca(sizeof(ORUInt*)*6);
   ORUInt*  setBits = alloca(sizeof(ORUInt)*wordLength);
   ORUInt level = [assignment->var getLevelBitWasSet:assignment->index];
   
   ULRep xr = getULVarRep(_x);
   ULRep yr = getULVarRep(_y);
   ULRep zr = getULVarRep(_z);
   TRUInt *xLow = xr._low, *xUp = xr._up;
   TRUInt *yLow = yr._low, *yUp = yr._up;
   TRUInt *zLow = zr._low, *zUp = zr._up;
   
   for(ORUInt i = 0; i<6;i++)
      state[i] = alloca(sizeof(ORUInt)*wordLength);
   
   //   ORUInt* setBits = alloca(sizeof(ORUInt)*wordLength);
   
   if(assignment->var == _x)
      [_x getState:setBits whenBitSet:assignment->index];
   else
      [_x getState:setBits afterLevel:level];
   
   //   [_x getState:setBits afterLevel:level];
   for(ORUInt i = 0; i<wordLength;i++){
      state[0][i] = xUp[i]._val | ~setBits[i];
      state[1][i] = xLow[i]._val & setBits[i];
   }
   
   if(assignment->var == _y)
      [_y getState:setBits whenBitSet:assignment->index];
   else
      [_y getState:setBits afterLevel:level];
   for(ORUInt i = 0; i<wordLength;i++){
      state[2][i] = yUp[i]._val | ~setBits[i];
      state[3][i] = yLow[i]._val & setBits[i];
   }
   
   if(assignment->var == _z)
      [_z getState:setBits whenBitSet:assignment->index];
   else
      [_z getState:setBits afterLevel:level];
   //   [_z getState:setBits afterLevel:level];
   state[4][0] = zUp[0]._val | ~setBits[0];
   state[5][0] = zLow[0]._val & setBits[0];
   
   return [self getAntecedentsFor:assignment state:state];
}
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment state:(ORUInt**)state
{
   //NSLog(@"Implication for 0x%lx[%u] = %@  traced back through %@", (unsigned long)assignment->var, assignment->index, (CPBitVarI*)assignment->var, self);
   
   ORUInt wordLength = [_x getWordLength];
   ORUInt bitLength = [_x bitLength];
   
   CPBitAntecedents* ants = malloc(sizeof(CPBitAntecedents));
   CPBitAssignment** vars;
   vars = malloc(sizeof(CPBitAssignment*)*(wordLength*BITSPERWORD*2+1));
   ants->numAntecedents = 0;
   ants->antecedents = vars;
   
   //   TRUInt* xUp;
   //   TRUInt* xLow;
   //   TRUInt* yUp;
   //   TRUInt* yLow;
   //
   //   [_x getUp:&xUp andLow:&xLow];
   //   [_y getUp:&yUp andLow:&yLow];
   //
   //    ORUInt* xSetBits = alloca(sizeof(ORUInt)*wordLength);
   //    ORUInt* ySetBits = alloca(sizeof(ORUInt)*wordLength);
   //   ORUInt* lSetBits;
   //   ORUInt* gSetBits;
   //
   //    ORUInt level = [assignment->var getLevelBitWasSet:assignment->index];
   //
   //    if(assignment->var == _x)
   //        [_x getState:xSetBits whenBitSet:assignment->index];
   //    else
   //        [_x getState:xSetBits afterLevel:level];
   //
   //    if(assignment->var == _y)
   //        [_y getState:ySetBits whenBitSet:assignment->index];
   //    else
   //        [_y getState:ySetBits afterLevel:level];
   //
   //   ORUInt* xl = alloca(sizeof(ORUInt)*wordLength);
   //   ORUInt* xu = alloca(sizeof(ORUInt)*wordLength);
   //   ORUInt* yl = alloca(sizeof(ORUInt)*wordLength);
   //   ORUInt* yu = alloca(sizeof(ORUInt)*wordLength);
   
   ORUInt* xl;
   ORUInt* xu;
   ORUInt* yl;
   ORUInt* yu;
   
   if(![_z isFree:0] && [_z getBit:0]){
      //      for(int i=0;i<wordLength;i++){
      xl = state[1];
      xu = state[0];
      yl = state[3];
      yu = state[2];
      //      }
      //      lSetBits=xSetBits;
      //      gSetBits=ySetBits;
   }
   else{
      xl = state[3];
      xu = state[2];
      yl = state[1];
      yu = state[0];
      //      }
      //      lSetBits=ySetBits;
      //      gSetBits=xSetBits;
   }
   
   
   ORInt index = assignment->index;
   ORInt idx=0;
   ORUInt* x1y0 = alloca(sizeof(ORUInt)*wordLength);
   
   for(int i=wordLength-1;i>=0;i--){
      //      x1y0[i] = ((xl[i] & lSetBits[i]) & (~yu[i] & gSetBits[i]));
      x1y0[i] = xl[i] & ~yu[i] ;
      if(x1y0[i] != 0){
         idx = (i*BITSPERWORD)+(BITSPERWORD - __builtin_clz(x1y0[i])-1);
         break;
      }
   }
   
//   index = idx;
   index=max(idx,index);
   
   //   NSLog(@"                                               3322222222221111111111");
   //   NSLog(@"                                               10987654321098765432109876543210");
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
   
   if((assignment->var == _x) || (assignment->var == _y)){
      if(![_z isFree:0]){
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->index = 0;
         vars[ants->numAntecedents]->var = _z;
         vars[ants->numAntecedents]->value = [_z getBit:0];
         ants->numAntecedents++;
      }
   }
   
   
   if(assignment->var == _x){
      if(![_y isFree:assignment->index]){
         yAtIndex = true;
         if ((index>idx) && ([_x getBit:index] != [_y getBit:index]))
            index=idx;
      }
   }
   else if(assignment->var == _y){
      if(![_x isFree:assignment->index]){
         xAtIndex = true;
         if ((index>idx) && ([_x getBit:index] != [_y getBit:index]))
            index=idx;
      }
   }
   else if(assignment->var == _z){
      ORUInt* different = alloca(sizeof(ORUInt)*wordLength);
      ORInt diffIndex =0;
      for(int i=wordLength-1;i>=0;i--){
         //         different[i] = (~(xUp[i]._val^xLow[i]._val) & ~(yUp[i]._val^yLow[i]._val)) & ((xUp[i]._val ^ yUp[i]._val) | (xLow[i]._val ^ yLow[i]._val));
         //         different[i] = (~(xl[i]^xu[i]) & ~(yl[i]^yu[i])) & (xl[i] ^ yl[i]);
         if([_z getImplicationForBit:0] == self)
            different[i] = _xWhenZSet[i] & _yWhenZSet[i] & (xl[i] ^ yl[i]);
         else
            different[i]= (~(xl[i]^xu[i]) & ~(yl[i]^yu[i])) & (xl[i] ^ yl[i]);
         
         if(different[i] != 0){
            diffIndex = (i*BITSPERWORD)+(BITSPERWORD - __builtin_clz(different[i]))-1;
            //             //find number of consecutive bits with x=1 and y=0
            //             //starting at msb where this is the case
            //            int countBits = 0;
            //            ORUInt mask = 0x1<<(diffIndex/BITSPERWORD);
            //            //TODO: Should consider bit vectors over multiple words in memory
            //            while((different[i] & (mask<<(diffIndex-countBits))) != 0){
            //               countBits++;
            //            }
            //            diffIndex-=countBits-1;
            break;
         }
      }
      
      if([_z getImplicationForBit:0] == self)
         for(ORUInt i = 0;i<wordLength;i++){
            //         xSetBits[i] = _xWhenZSet[i];
            //         ySetBits[i] = _yWhenZSet[i];
            state[0][i] |= ~_xWhenZSet[i];
            state[1][i] &= _xWhenZSet[i];
            state[2][i] |= ~_yWhenZSet[i];
            state[3][i] &= _yWhenZSet[i];
            
         }
      
      //      NSLog(@"%@",_x);
      //      NSLog(@"%@",_y);
      //      NSLog(@"%@",_z);
      //      if(![_z getBit:0])
      index = diffIndex;
      //      else
      //         index = idx;
      
      //      if(![_x isFree:assignment->index]){
      if((~(state[0][assignment->index/BITSPERWORD]^state[1][assignment->index/BITSPERWORD])) & (0x1 << assignment->index%BITSPERWORD)){
         xAtIndex = true;
      }
      //      if(![_y isFree:assignment->index]){
      if((~(state[2][assignment->index/BITSPERWORD]^state[3][assignment->index/BITSPERWORD])) & (0x1 << assignment->index%BITSPERWORD)){
         yAtIndex = true;
      }
   }
   if (assignment->var == _z){
      xAtIndex = yAtIndex = true;
   }
      
      
   for(int i=index; i<bitLength;i++){
      if(((~(state[0][i/BITSPERWORD]^state[1][i/BITSPERWORD])) & (0x1 << i%BITSPERWORD)) && ((i!=assignment->index) || ((i==assignment->index) && xAtIndex))){
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->index = i;
         vars[ants->numAntecedents]->var = _x;
         //         vars[ants->numAntecedents]->value = [_x getBit:i];
         vars[ants->numAntecedents]->value =(state[1][i/BITSPERWORD] & (0x1 << i%BITSPERWORD)) != 0;
         ants->numAntecedents++;
      }
      if(((~(state[2][i/BITSPERWORD]^state[3][i/BITSPERWORD])) & (0x1 << i%BITSPERWORD)) && ((i!=assignment->index) || ((i==assignment->index) && yAtIndex))){
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->index = i;
         vars[ants->numAntecedents]->var = _y;
         //         vars[ants->numAntecedents]->value = [_y getBit:i];
         vars[ants->numAntecedents]->value =(state[3][i/BITSPERWORD] & (0x1 << i%BITSPERWORD)) != 0;
         ants->numAntecedents++;
         
      }
   }
   
   
   
   //   if(ants->numAntecedents > (wordLength*BITSPERWORD*2+1))
   //   if((assignment->var == _z) && (assignment->value == 1))
   //      NSLog(@"%d  %d",ants->numAntecedents,2*(32-assignment->index));
   //    printf("%i\n",index);
   return ants;
}
//-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment
//{
//   //NSLog(@"Implication for 0x%lx[%u] = %@  traced back through %@", (unsigned long)assignment->var, assignment->index, (CPBitVarI*)assignment->var, self);
//   if([assignment->var isFree:assignment->index])
//      NSLog(@"");
//
//
//   ORUInt wordLength = [_x getWordLength];
//   ORUInt bitLength = [_x bitLength];
//
//   CPBitAntecedents* ants = malloc(sizeof(CPBitAntecedents));
//   CPBitAssignment** vars;
//   vars = malloc(sizeof(CPBitAssignment*)*(wordLength*BITSPERWORD*2+1));
//   ants->numAntecedents = 0;
//   ants->antecedents = vars;
//
//   TRUInt* xUp;
//   TRUInt* xLow;
//   TRUInt* yUp;
//   TRUInt* yLow;
//
//   [_x getUp:&xUp andLow:&xLow];
//   [_y getUp:&yUp andLow:&yLow];
//
//   ORUInt* xSetBits = alloca(sizeof(ORUInt)*wordLength);
//   ORUInt* ySetBits = alloca(sizeof(ORUInt)*wordLength);
//   ORUInt* lSetBits;
//   ORUInt* gSetBits;
//
//   ORUInt level = [assignment->var getLevelBitWasSet:assignment->index];
//
//   if(assignment->var == _x)
//      [_x getState:xSetBits whenBitSet:assignment->index];
//   else
//      [_x getState:xSetBits afterLevel:level];
//
//   if(assignment->var == _y)
//      [_y getState:ySetBits whenBitSet:assignment->index];
//   else
//      [_y getState:ySetBits afterLevel:level];
//
//   ORUInt* xl = alloca(sizeof(ORUInt)*wordLength);
//   ORUInt* xu = alloca(sizeof(ORUInt)*wordLength);
//   ORUInt* yl = alloca(sizeof(ORUInt)*wordLength);
//   ORUInt* yu = alloca(sizeof(ORUInt)*wordLength);
//
//   if([_z getBit:0]){
//      for(int i=0;i<wordLength;i++){
//         xl[i] = xLow[i]._val;
//         xu[i] = xUp[i]._val;
//         yl[i] = yLow[i]._val;
//         yu[i] = yUp[i]._val;
//      }
//      lSetBits=xSetBits;
//      gSetBits=ySetBits;
//   }
//   else{
//      for(int i=0;i<wordLength;i++){
//         xl[i] = yLow[i]._val;
//         xu[i] = yUp[i]._val;
//         yl[i] = xLow[i]._val;
//         yu[i] = xUp[i]._val;
//      }
//      lSetBits=ySetBits;
//      gSetBits=xSetBits;
//   }
//
//
//   ORInt index = assignment->index;
//   ORInt idx=0;
//   ORUInt* x1y0 = alloca(sizeof(ORUInt)*wordLength);
//
//   for(int i=wordLength-1;i>=0;i--){
//      x1y0[i] = ((xl[i] & lSetBits[i]) & (~yu[i] & gSetBits[i]));
//      if(x1y0[i] != 0){
//         idx = (i*BITSPERWORD)+(BITSPERWORD - __builtin_clz(x1y0[i])-1);
//         break;
//      }
//   }
//
////   if(idx<index)
//      index=idx;
//
////      NSLog(@"                                               3322222222221111111111");
////      NSLog(@"                                               10987654321098765432109876543210");
////      if(assignment->var == _x)
////         NSLog(@"%@[%d]=%d",_x,assignment->index, assignment->value);
////      else
////         NSLog(@"%@",_x);
////
////      if(assignment->var == _y)
////         NSLog(@"%@[%d]=%d",_y,assignment->index, assignment->value);
////      else
////         NSLog(@"%@",_y);
//
//
//   ORBool xAtIndex, yAtIndex, zAt0;
//   xAtIndex = yAtIndex = zAt0 = false;
//
//   if((assignment->var == _x) || (assignment->var == _y)){
//      if(![_z isFree:0]){
//         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
//         vars[ants->numAntecedents]->index = 0;
//         vars[ants->numAntecedents]->var = _z;
//         vars[ants->numAntecedents]->value = [_z getBit:0];
//         ants->numAntecedents++;
//      }
//   }
//
//
//   if(assignment->var == _x){
//      if(![_y isFree:assignment->index]){
//         yAtIndex = true;
//         if ((index>idx) && ([_x getBit:index] != [_y getBit:index]))
//            index=idx;
//      }
//   }
//   else if(assignment->var == _y){
//      if(![_x isFree:assignment->index]){
//         xAtIndex = true;
//         if ((index>idx) && ([_x getBit:index] != [_y getBit:index]))
//            index=idx;
//      }
//   }
//   else if(assignment->var == _z){
//      ORUInt* different = alloca(sizeof(ORUInt)*wordLength);
//      ORInt diffIndex =0;
//      for(int i=wordLength-1;i>=0;i--){
////         different[i] = (~(xUp[i]._val^xLow[i]._val) & ~(yUp[i]._val^yLow[i]._val)) & ((xUp[i]._val ^ yUp[i]._val) | (xLow[i]._val ^ yLow[i]._val));
////         different[i] = (~(xl[i]^xu[i]) & ~(yl[i]^yu[i])) & (xl[i] ^ yl[i]);
//         different[i] = _xWhenZSet[i] & _yWhenZSet[i] & (xl[i] ^ yl[i]);
//         if(different[i] != 0){
//            diffIndex = (i*BITSPERWORD)+(BITSPERWORD - __builtin_clz(different[i]))-1;
////             //find number of consecutive bits with x=1 and y=0
////             //starting at msb where this is the case
////            int countBits = 0;
////            ORUInt mask = 0x1<<(diffIndex/BITSPERWORD);
////            //TODO: Should consider bit vectors over multiple words in memory
////            while((different[i] & (mask<<(diffIndex-countBits))) != 0){
////                countBits++;
////            }
////            diffIndex-=countBits-1;
//            break;
//         }
//      }
//      for(ORUInt i = 0;i<wordLength;i++){
//         xSetBits[i] = _xWhenZSet[i];
//         ySetBits[i] = _yWhenZSet[i];
//      }
//      //            //          //find number of consecutive bits with x=1 and y=0
//      //            //          //starting at msb where this is the case
//      //            int countBits = 0;
//      //            ORUInt mask = 0x1<<(idx/BITSPERWORD);
//      //            while((x1y0[i] & (mask<<(idx-countBits))) != 0){
//      //                countBits++;
//      //            }
//      //            idx-=countBits-1;
//
////      if([_z getBit:0] == false)
////         index = diffIndex;
//      index=diffIndex;
////      else
////         index = idx;
//
//      if(![_x isFree:assignment->index]){
//         xAtIndex = true;
//      }
//      if(![_y isFree:assignment->index]){
//         yAtIndex = true;
//      }
//   }
//
//   for(int i=index; i<bitLength;i++){
//      if(((xSetBits[i/BITSPERWORD] & 0x1<<i%BITSPERWORD)) && ((i!=assignment->index) || ((i==assignment->index) && xAtIndex))){
//         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
//         vars[ants->numAntecedents]->index = i;
//         vars[ants->numAntecedents]->var = _x;
//         vars[ants->numAntecedents]->value = [_x getBit:i];
//         ants->numAntecedents++;
//      }
//      if(((ySetBits[i/BITSPERWORD] & 0x1<<i%BITSPERWORD)) && ((i!=assignment->index) || ((i==assignment->index) && yAtIndex))){
//         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
//         vars[ants->numAntecedents]->index = i;
//         vars[ants->numAntecedents]->var = _y;
//         vars[ants->numAntecedents]->value = [_y getBit:i];
//         ants->numAntecedents++;
//      }
//   }
//
//
//
//   //   if(ants->numAntecedents > (wordLength*BITSPERWORD*2+1))
//   //   if((assignment->var == _z) && (assignment->value == 1))
//   //      NSLog(@"%d  %d",ants->numAntecedents,2*(32-assignment->index));
//   //    printf("%i\n",index);
//   return ants;
//}

- (void) dealloc
{
    if(_state != nil)
        free(_state);
    [super dealloc];
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_y bound]+ ![_z bound];
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
//   [_x incrementActivityBySignificance];
//   [_y incrementActivityBySignificance];
//   [_z incrementActivityBySignificance];
   [_x incrementActivityAllBy:[_x bitLength]];
   [_y incrementActivityAllBy:[_x bitLength]];
//   [_z incrementActivityAll];
//   [_z increaseActivity:0 by:[_x bitLength]+[_y bitLength]];
   [_z incrementActivityAll];

}
-(void) propagate
{
#ifdef BIT_DEBUG
   NSLog(@"**********************************");
   NSLog(@"Bit <= Constraint propagated.");
#endif
   
   ORUInt wordLength = [_x getWordLength];
   //ORUInt bitLength = [_x bitLength];
   ORUInt zWordLength = [_z getWordLength];
//   ORUInt zBitLength = [_z bitLength];
   
    ULRep xr = getULVarRep(_x);
    ULRep yr = getULVarRep(_y);
    ULRep zr = getULVarRep(_z);
    TRUInt *xLow = xr._low, *xUp = xr._up;
    TRUInt *yLow = yr._low, *yUp = yr._up;
    TRUInt *zLow = zr._low, *zUp = zr._up;

//   ORUInt* zero = alloca(sizeof(ORUInt)*wordLength);
//   ORUInt* one = alloca(sizeof(ORUInt)*wordLength);
   ORUInt* newXUp = alloca(sizeof(ORUInt)*wordLength);
   ORUInt* newXLow = alloca(sizeof(ORUInt)*wordLength);
   ORUInt* newYUp = alloca(sizeof(ORUInt)*wordLength);
   ORUInt* newYLow = alloca(sizeof(ORUInt)*wordLength);
   ORUInt* newZUp = alloca(sizeof(ORUInt)*wordLength);
   ORUInt* newZLow = alloca(sizeof(ORUInt)*wordLength);
   //   ORUInt  upXORlow;
   
//   ORUInt signmask = 1 << (([_x bitLength]-1)%BITSPERWORD);
   
   
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
   
//    if ([bitvar2NSString(newXLow, newXUp, bitLength) isEqualToString:@"00000000000000000000000000001000"]){
//        NSLog(@"*******************************************");
//        NSLog(@"x <= y ? z");
//        NSLog(@"x=%@\n",_x);
//        NSLog(@"y=%@\n",_y);
//        NSLog(@"z=%@\n\n",_z);
//    }

    //   ORUInt* xmin = [_x minArray];
//   ORUInt* ymin = [_y minArray];
//   ORUInt* xmax = [_x maxArray];
//   ORUInt* ymax = [_y maxArray];
   
    ORBool xlty = false;
    ORBool xgty = false;
    ORBool xeqy = true;
   ORBool xUpEQ0 = true;
   ORBool xUpEqyLow=true;
    
    for (int i=wordLength-1; i>=0; i--) {
       if(newXUp[i] != 0)
          xUpEQ0 = false;
        if (((newXUp[i] ^ newXLow[i]) | (newYUp[i]^ newYLow[i]) | (newXLow[i] ^ newYLow[i])) == 0)
            continue;
        else
            xeqy = false;
        if(newXLow[i] > newYUp[i]) {
//            NSLog(@"%@",_x);
//            NSLog(@"%@\n",_y);
            xgty = true;
            break;
        }
        else if (newXUp[i] < newYLow[i]) {
//            NSLog(@"%@",_x);
//            NSLog(@"%@\n",_y);
            xlty = true;
            break;
        }
    }
   
   for (int i=wordLength-1; i>=0; i--) {
      if(xUp[i]._val != yLow[i]._val)
         xUpEqyLow = false;
   }
   
    if(xlty || xeqy || xUpEQ0 || xUpEqyLow){
       if(zUp[0]._val ^ zLow[0]._val){
          for(ORUInt i = 0; i<wordLength;i++){
             _xWhenZSet[i] = ~(xUp[i]._val ^ xLow[i]._val);
             _yWhenZSet[i] = ~(yUp[i]._val ^ yLow[i]._val);
          }
       }
        newZLow[0] |= 0x1;
    }
    if(xgty){
        if(zUp[0]._val ^ zLow[0]._val){
           for(ORUInt i = 0; i<wordLength;i++){
              _xWhenZSet[i] = ~(xUp[i]._val ^ xLow[i]._val);
              _yWhenZSet[i] = ~(yUp[i]._val ^ yLow[i]._val);
           }
        }
       newZUp[0] = 0;

    }
   if(xUpEQ0){
      newZLow[0] |= 0x1;
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
            
//            if(zLow[0]._val){
            if(newZLow[0]){
               temp = newXLow[wordIndex] | mask;
               if(temp > newYUp[wordIndex]){
                  newXUp[wordIndex] &= ~mask;
                  freeX[wordIndex] &= ~mask;
                  different[wordIndex] = (newXUp[wordIndex] ^ newYUp[wordIndex]) | (newXLow[wordIndex] ^ newYLow[wordIndex]);
                  numFreeBitsX--;
                  more = true;
//                  _state[0] = newXUp;
//                  _state[1] = newXLow;
//                  _state[2] = newYUp;
//                  _state[3] = newYLow;
//                  _state[4] = newZUp;
//                  _state[5] = newZLow;

//                  checkDomainConsistency(_x, newXLow, newXUp, wordLength, self);
//                  [_x setUp:newXUp andLow:newXLow for:self];
               }
            }
//            else if (zUp[0]._val == 0){
            else if (newZUp[0] == 0){
               temp = newXUp[wordIndex] & ~mask;
               //x must be > y
               if(temp <= newYLow[wordIndex]){
                  newXLow[wordIndex] |= mask;
                  freeX[wordIndex] &= ~mask;
                  different[wordIndex] = (newXUp[wordIndex] ^ newYUp[wordIndex]) | (newXLow[wordIndex] ^ newYLow[wordIndex]);
                  numFreeBitsX--;
                  more = true;
//                  _state[0] = newXUp;
//                  _state[1] = newXLow;
//                  _state[2] = newYUp;
//                  _state[3] = newYLow;
//                  _state[4] = newZUp;
//                  _state[5] = newZLow;
                  
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
//            if(newZLow[0]){ // If x < y = t, then will clearing this bit make xmin > ymax?
               temp = newYUp[wordIndex] & ~mask;
               if(temp < newXLow[wordIndex]){
                  newYLow[wordIndex] |= mask;
                  freeY[wordIndex] &= ~mask;
                  different[wordIndex] = (newXUp[wordIndex] ^ newYUp[wordIndex]) | (newXLow[wordIndex] ^ newYLow[wordIndex]);
                  numFreeBitsY--;
                  more = true;
//                  _state[0] = newXUp;
//                  _state[1] = newXLow;
//                  _state[2] = newYUp;
//                  _state[3] = newYLow;
//                  _state[4] = newZUp;
//                  _state[5] = newZLow;
                  
//                  checkDomainConsistency(_y, newYLow, newYUp, wordLength, self);
//                  [_y setUp:newYUp andLow:newYLow for:self];
               }
            }
            else if (zUp[0]._val == 0){
//            else if (newZUp[0] == 0){
               temp = newYLow[wordIndex] | mask;
               //x must be >= y
               if(temp >= newXUp[wordIndex]){//if we set bit in y is ymin > xmax?
                  newYUp[wordIndex] &= ~mask;
                  freeY[wordIndex] &= ~mask;
                  different[wordIndex] = (newXUp[wordIndex] ^ newYUp[wordIndex]) | (newXLow[wordIndex] ^ newYLow[wordIndex]);
                  numFreeBitsY--;
                  more = true;
//                  _state[0] = newXUp;
//                  _state[1] = newXLow;
//                  _state[2] = newYUp;
//                  _state[3] = newYLow;
//                  _state[4] = newZUp;
//                  _state[5] = newZLow;
                  
//                  checkDomainConsistency(_y, newYLow, newYUp, wordLength, self);
//                  [_y setUp:newYUp andLow:newYLow for:self];
               }
            }
         }
      }while(more);
   }


   
//    if ([bitvar2NSString(newXLow, newXUp, bitLength) isEqualToString:@"00000000000000000000000000000000"]){
//   NSLog(@"newX =          %@",bitvar2NSString(newXLow, newXUp, bitLength));
//   NSLog(@"newY =          %@",bitvar2NSString(newYLow, newYUp, bitLength));
//   NSLog(@"newZ =          %@",bitvar2NSString(newZLow, newZUp, zBitLength));
//              NSLog(@"");
//    }
//    NSLog(@"newX =          %@",bitvar2NSString(newXLow, newXUp, 32));
//    NSLog(@"newY =          %@",bitvar2NSString(newYLow, newYUp, 32));
//    NSLog(@"newZ =          %@",bitvar2NSString(newZLow, newZUp, 32));
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
    
//    if(newZLow[0]){
//        if (newXLow[0] > newYUp[0])
//            NSLog(@"fail");
//    }
////    else{
////        if (newXUp[0] < newYLow[0])
////            NSLog(@"fail");
////    }
//    if (!newZUp[0]){
//        if(newYLow[0] >= newXUp[0])
//            NSLog(@"fail");
//    }
////    else{
////        if ([_z bound] && (newYUp[0] <= newXLow[0]))
////            NSLog(@"fail");
////    }
    
//    ORUInt changed=0;
//    for(ORUInt i =0; i<wordLength;i++){
//        changed |= newXUp[i] ^ xUp[i]._val;
//        changed |= newXLow[i] ^ xLow[i]._val;
//        changed |= newYUp[i] ^ yUp[i]._val;
//        changed |= newYLow[i] ^ yLow[i]._val;
//    }
//    if(changed){
//        ORUInt* xChanges = malloc(sizeof(ORUInt)*wordLength);
//        ORUInt* yChanges = malloc(sizeof(ORUInt)*wordLength);
//        for(ORUInt i=0;i<wordLength;i++){
//            xChanges[i] = newXUp[i] ^ xUp[i]._val;
//            xChanges[i] |= newXLow[i] ^ xLow[i]._val;
//            yChanges[i] = newYUp[i] ^ yUp[i]._val;
//            yChanges[i] |= newYLow[i] ^ yLow[i]._val;
//        }
//        _xChanges[_top._val] = xChanges;
//        _yChanges[_top._val] = yChanges;
//        assignTRUInt(&_top, _top._val+1, [[_x engine]trail]);
//    }

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
//    ORUInt bitLength = [_x bitLength];
   _x = x;
   _y = y;
   _z = z;
   _state = malloc(sizeof(ORUInt*)*6);
//    _xChanges = malloc(sizeof(ORUInt*)*bitLength*2);
//    _yChanges = malloc(sizeof(ORUInt*)*bitLength*2);
//    _zChanges = malloc(sizeof(ORUInt*));
//    _top = makeTRUInt([[_x engine]trail], 0);

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
//   if(_state[5][0]){
//      return getLTAntecedents(_x, _y, _z, assignment, _state);
//   }
//   else{
//      ORUInt** state = malloc(sizeof(ORUInt*)*6);
//      state[0] = _state[2];
//      state[1] = _state[3];
//      state[2] = _state[0];
//      state[3] = _state[1];
//      state[4] = _state[4];
//      state[5] = _state[5];
//      return getLTAntecedents(_x, _y, _z, assignment, state);
//   }

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
//    TRUInt* zUp;
//    TRUInt* zLow;
    
    [_x getUp:&xUp andLow:&xLow];
    [_y getUp:&yUp andLow:&yLow];
//    [_z getUp:&zUp andLow:&zLow];
    
    ORInt idx=0;
    
//          NSLog(@"                                             3322222222221111111111");
//          NSLog(@"                                             10987654321098765432109876543210");
//          if(assignment->var == _x)
//             NSLog(@"%@[%d]=%d",_x,assignment->index, assignment->value);
//          else
//             NSLog(@"%@",_x);
//
//          if(assignment->var == _y)
//             NSLog(@"%@[%d]=%d",_y,assignment->index, assignment->value);
//          else
//             NSLog(@"%@",_y);
   
    ORBool xAtIndex, yAtIndex, zAt0;
    xAtIndex = yAtIndex = zAt0 = false;
    
    if(assignment->var == _x){
        if (![_y isFree:index] || (~ISFREE(state[2][index/BITSPERWORD], state[3][index/BITSPERWORD]) & (0x1 << (index%BITSPERWORD)))) {
            yAtIndex = true;
            vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
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
            vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
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
//        if(![_z getBit:0])
            index = diffIndex;
//        else
//            index = idx;
       
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
//             NSLog(@"%d  %d",ants->numAntecedents,2*(32-assignment->index));
//   NSLog(@"Assignment: %@[%d]",assignment->var,assignment->index);
//   NSLog(@"Found %d antecedents.",ants->numAntecedents);
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
//    TRUInt* zUp;
//    TRUInt* zLow;
    
    [_x getUp:&xUp andLow:&xLow];
    [_y getUp:&yUp andLow:&yLow];
//    [_z getUp:&zUp andLow:&zLow];
  
    ORUInt* xSetBits = alloca(sizeof(ORUInt)*wordLength);
    ORUInt* ySetBits = alloca(sizeof(ORUInt)*wordLength);
    
    ORUInt level = [assignment->var getLevelBitWasSet:assignment->index];

    if(assignment->var == _x)
        [_x getState:xSetBits whenBitSet:assignment->index];
    else
        [_x getState:xSetBits afterLevel:level];

    if(assignment->var == _y)
        [_y getState:ySetBits whenBitSet:assignment->index];
    else
        [_y getState:ySetBits afterLevel:level];

//    ORUInt** changes;
//    if(assignment->var == _x)
//        changes = _xChanges;
//    if(assignment->var == _y)
//        changes = _yChanges;
//    ORUInt mask = 0x1 << assignment->index%BITSPERWORD;
//    for(ORUInt i=0;i<_top._val;i++){
//        for(ORUInt j=0;j<wordLength;j++){
//            xSetBits[j] |= _xChanges[i][j];
//            ySetBits[j] |= _yChanges[i][j];
//        }
//        if(changes[i][assignment->index/BITSPERWORD] & mask)
//            break;
//    }

    ORInt index = assignment->index;
    
    ORUInt* x1y0 = alloca(sizeof(ORUInt)*wordLength);
    ORInt idx=0;
    
    ORUInt* xl = alloca(sizeof(ORUInt)*wordLength);
    ORUInt* xu = alloca(sizeof(ORUInt)*wordLength);
    ORUInt* yl = alloca(sizeof(ORUInt)*wordLength);
    ORUInt* yu = alloca(sizeof(ORUInt)*wordLength);
   
   if(![_z isFree:0] && [_z getBit:0]){
      for(int i=0;i<wordLength;i++){
         xl[i] = xLow[i]._val;
         xu[i] = xUp[i]._val;
         yl[i] = yLow[i]._val;
         yu[i] = yUp[i]._val;
      }
   }
   else{
       for(int i=0;i<wordLength;i++){
          xl[i] = yLow[i]._val;
          xu[i] = yUp[i]._val;
          yl[i] = xLow[i]._val;
          yu[i] = xUp[i]._val;
       }
      ORUInt* tempX = xSetBits;
      xSetBits = ySetBits;
      ySetBits = tempX;
   }
    ORUInt signMask = 0x1 << ((bitLength-1)%BITSPERWORD);
    
    if(~(xl[wordLength-1]^xu[wordLength-1]) & signMask){
        xl[wordLength-1] ^= signMask;
        xu[wordLength-1] ^= signMask;
    }
    if(~(yl[wordLength-1]^yu[wordLength-1]) & signMask){
        yl[wordLength-1] ^= signMask;
        yu[wordLength-1] ^= signMask;
    }
   
    for(int i=wordLength-1;i>=0;i--){
        x1y0[i] = ((xl[i] & xSetBits[i]) & (~yu[i] & ySetBits[i]));
        if(x1y0[i] != 0){
            idx = (i*BITSPERWORD)+(BITSPERWORD - __builtin_clz(x1y0[i])-1);
            break;
        }
    }
   index=idx;
    
//          NSLog(@"                                             3322222222221111111111");
//          NSLog(@"                                             10987654321098765432109876543210");
//          if(assignment->var == _x)
//             NSLog(@"%@[%d]=%d",_x,assignment->index, assignment->value);
//          else
//             NSLog(@"%@",_x);
//
//          if(assignment->var == _y)
//             NSLog(@"%@[%d]=%d",_y,assignment->index, assignment->value);
//          else
//             NSLog(@"%@",_y);
   
    
    ORBool xAtIndex, yAtIndex, zAt0;
    xAtIndex = yAtIndex = zAt0 = false;
    
    if(assignment->var == _x){
        if(![_y isFree:index]){
            yAtIndex = true;
            //         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
            //         vars[ants->numAntecedents]->index = index;
            //         vars[ants->numAntecedents]->var = _y;
            //         vars[ants->numAntecedents]->value = [_y getBit:index];
//            if ((index>idx) && !assignment->value && [_y getBit:index])
                if (index>idx)
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
//            if((index>idx) && assignment->value && ![_x getBit:index])
            if(index>idx)
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
//        if([_z getBit:0] == false)
            index = diffIndex;
//        else
//            index = idx;
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
    
//    ORUInt different = 0;
//    for(int i=0;i<wordLength;i++){
//        different |= xLow[i]._val ^ yLow[i]._val;
//        different |= xUp[i]._val ^ yUp[i]._val;
//    }
//    if(different == 0)
//        index=0;

    for(int i=index; i<bitLength;i++){
//        if(((i!=assignment->index) && ![_x isFree:i]) || ((i==assignment->index) && xAtIndex)){
        if(((i!=assignment->index) && (xSetBits[i/BITSPERWORD] & 0x1<<(i%BITSPERWORD))) || ((i==assignment->index) && xAtIndex)){
            vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
            vars[ants->numAntecedents]->index = i;
            vars[ants->numAntecedents]->var = _x;
            vars[ants->numAntecedents]->value = [_x getBit:i];
            ants->numAntecedents++;
        }
//        if(((i!=assignment->index) && ![_y isFree:i]) || ((i==assignment->index) && yAtIndex)){
        if(((i!=assignment->index) && (ySetBits[i/BITSPERWORD] & 0x1<<(i%BITSPERWORD))) || ((i==assignment->index) && yAtIndex)){
            vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
            vars[ants->numAntecedents]->index = i;
            vars[ants->numAntecedents]->var = _y;
            vars[ants->numAntecedents]->value = [_y getBit:i];
            ants->numAntecedents++;
        }
    }
    //   if(ants->numAntecedents > (wordLength*BITSPERWORD*2+1))
    //   if((assignment->var == _z) && (assignment->value == 1))
//             NSLog(@"%d  %d",ants->numAntecedents,2*(32-assignment->index));
   
//   if(![_z getBit:0])
//      NSLog(@"");
//   NSLog(@"Assignment: %@[%d]",assignment->var,assignment->index);
//   NSLog(@"Found %d antecedents.",ants->numAntecedents);

    return ants;
}

- (void) dealloc
{
    if(_state != nil)
        free(_state);
    [super dealloc];
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_y bound]+ ![_z bound];
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
//   [_x incrementActivityBySignificance];
//   [_y incrementActivityBySignificance];
//   [_z incrementActivityBySignificance];
   [_x incrementActivityAll];
   [_y incrementActivityAll];
//   [_z incrementActivityAll];
   [_z increaseActivity:0 by:[_x bitLength]+[_y bitLength]];
//   [_z incrementActivityAll];
}
-(void) propagate
{
   //TODO: Fix so that _z can be larger than 32 bits if this is the design decision made
#ifdef BIT_DEBUG
   NSLog(@"**********************************");
   NSLog(@"Bit (signed) <= Constraint propagated.");
#endif
   
   ORUInt wordLength = [_x getWordLength];
//   ORUInt bitLength = [_x bitLength];
   ORUInt zWordLength = [_z getWordLength];
//   ORUInt zBitLength = [_z bitLength];
   
//   TRUInt* xLow;
//   TRUInt* xUp;
//   TRUInt* yLow;
//   TRUInt* yUp;
//   TRUInt* zLow;
//   TRUInt* zUp;
//
//   [_x getUp:&xUp andLow:&xLow];
//   [_y getUp:&yUp andLow:&yLow];
//   [_z getUp:&zUp andLow:&zLow];

    ULRep xr = getULVarRep(_x);
    ULRep yr = getULVarRep(_y);
    ULRep zr = getULVarRep(_z);
    TRUInt *xLow = xr._low, *xUp = xr._up;
    TRUInt *yLow = yr._low, *yUp = yr._up;
    TRUInt *zLow = zr._low, *zUp = zr._up;

    ORUInt* newXUp = alloca(sizeof(ORUInt)*wordLength);
   ORUInt* newXLow = alloca(sizeof(ORUInt)*wordLength);

   ORUInt* newYUp = alloca(sizeof(ORUInt)*wordLength);
   ORUInt* newYLow = alloca(sizeof(ORUInt)*wordLength);
   
   ORUInt* newZUp = alloca(sizeof(ORUInt)*zWordLength);
   ORUInt* newZLow = alloca(sizeof(ORUInt)*zWordLength);
   
   ORUInt signMask = 1 << (([_x bitLength]-1)%BITSPERWORD);

//    NSLog(@"*******************************************");
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

//   ORUInt signMask = 0x1 << (BITSPERWORD - (bitLength%BITSPERWORD)-1);
//    ORUInt signMask = 0x1 << (BITSPERWORD - 1);
   
//    newXLow[wordLength-1] <<= BITSPERWORD - (bitLength%BITSPERWORD);
//    newXUp[wordLength-1] <<= BITSPERWORD - (bitLength%BITSPERWORD);
//    newYLow[wordLength-1] <<= BITSPERWORD - (bitLength%BITSPERWORD);
//    newYUp[wordLength-1] <<= BITSPERWORD - (bitLength%BITSPERWORD);

   
   ORUInt numFreeBitsX = 0;
   ORUInt numFreeBitsY = 0;
   
   //Find most sig. unset bit in x
   for(ORInt i = wordLength-1;i>=0;i--){
      freeX[i] = newXUp[i] ^ newXLow[i];
      numFreeBitsX += __builtin_popcount(freeX[i]);
   }
   //Find most sig. unset bit in y
   for(ORInt i = wordLength-1;i>=0;i--){
      freeY[i] = newYUp[i] ^ newYLow[i];
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
       if(newXLow[i] > newYUp[i]) {
         xgty = true;
         break;
      }
      else if (newXUp[i] < newYLow[i]) {
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
//   _state[0] = newXUp;
//   _state[1] = newXLow;
//   _state[2] = newYUp;
//   _state[3] = newYLow;
//   _state[4] = newZUp;
//   _state[5] = newZLow;

//   checkDomainConsistency(_z, newZLow, newZUp, zWordLength, self);
//   [_z setUp:newZUp andLow:newZLow for:self];


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
         //Find most sig unset bit in y
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
   freeX[wordLength-1] = newXUp[wordLength-1] ^ newXLow[wordLength-1];
   freeY[wordLength-1] = newYUp[wordLength-1] ^ newYLow[wordLength-1];

   if(~freeX[wordLength-1] & signMask){
      newXUp[wordLength-1] ^= signMask;
      newXLow[wordLength-1] ^= signMask;
   }
   if(~freeY[wordLength-1] & signMask){
      newYUp[wordLength-1] ^= signMask;
      newYLow[wordLength-1] ^= signMask;
   }
   
//    NSLog(@"newX = %@",bitvar2NSString(newXLow, newXUp, 32));
//    NSLog(@"newY = %@",bitvar2NSString(newYLow, newYUp, 32));
//    NSLog(@"newZ = %@",bitvar2NSString(newZLow, newZUp, 32));

//    newXLow[wordLength-1] >>= BITSPERWORD - (bitLength%BITSPERWORD);
//    newXUp[wordLength-1] >>= BITSPERWORD - (bitLength%BITSPERWORD);
//    newYLow[wordLength-1] >>= BITSPERWORD - (bitLength%BITSPERWORD);
//    newYUp[wordLength-1] >>= BITSPERWORD - (bitLength%BITSPERWORD);

//   NSLog(@"newX = %@",bitvar2NSString(newXLow, newXUp, bitLength));
//   NSLog(@"newY = %@",bitvar2NSString(newYLow, newYUp, bitLength));
//   NSLog(@"newZ = %@",bitvar2NSString(newZLow, newZUp, 1));

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

//   if((ORInt)newZLow[0]){
//      if ((ORInt)newXLow[0] > (ORInt)newYUp[0])
//         NSLog(@"fail");
//   }else if([_z bound]){
//      if ((ORInt)newXUp[0] <= (ORInt)newYLow[0])
//         NSLog(@"fail");
//   }
//    if(newZLow[0]){
//        if (newXLow[0] > newYUp[0])
//            NSLog(@"fail");
//    }else{
//        if (newXUp[0] <= newYLow[0])
//            NSLog(@"fail");
//    }
//    if (!(newZUp[0] & 0x1)){
//        if(newYLow[0] > newXUp[0])
//            NSLog(@"fail");
//    }else{
//        if (newYUp[0] < newXLow[0])
//            NSLog(@"fail");
//    }
//    ORUInt changed=0;
//    for(ORUInt i =0; i<wordLength;i++){
//        changed |= newXUp[i] ^ xUp[i]._val;
//        changed |= newXLow[i] ^ xLow[i]._val;
//        changed |= newYUp[i] ^ yUp[i]._val;
//        changed |= newYLow[i] ^ yLow[i]._val;
//    }
//    if(changed){
//        ORUInt* xChanges = malloc(sizeof(ORUInt)*wordLength);
//        ORUInt* yChanges = malloc(sizeof(ORUInt)*wordLength);
//        for(ORUInt i=0;i<wordLength;i++){
//            xChanges[i] = newXUp[i] ^ xUp[i]._val;
//            xChanges[i] |= newXLow[i] ^ xLow[i]._val;
//            yChanges[i] = newYUp[i] ^ yUp[i]._val;
//            yChanges[i] |= newYLow[i] ^ yLow[i]._val;
//        }
//        _xChanges[_top._val] = xChanges;
//        _yChanges[_top._val] = yChanges;
//        assignTRUInt(&_top, _top._val+1, [[_x engine]trail]);
//    }


   [_x setUp:newXUp andLow:newXLow for:self];
   [_y setUp:newYUp andLow:newYLow for:self];
   [_z setUp:newZUp andLow:newZLow for:self];
   
//    NSLog(@"x<=y? (signed)\n");
//    NSLog(@"x=%@\n",_x);
//    NSLog(@"y=%@\n",_y);
//    NSLog(@"z=%@\n\n",_z);

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
   //    ORUInt bitLength = [_x bitLength];
   _state = malloc(sizeof(ORUInt*)*6);
//    _xChanges = malloc(sizeof(ORUInt*)*bitLength*2);
//    _yChanges = malloc(sizeof(ORUInt*)*bitLength*2);
//    _zChanges = malloc(sizeof(ORUInt*));
//    _top = makeTRUInt([[_x engine]trail], 0);

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
//   if(_state[5][0]){
//      return getLTAntecedents(_x, _y, _z, assignment, _state);
//   }
//   else{
//      ORUInt** state = malloc(sizeof(ORUInt*)*6);
//      state[0] = _state[2];
//      state[1] = _state[3];
//      state[2] = _state[0];
//      state[3] = _state[1];
//      state[4] = _state[4];
//      state[5] = _state[5];
//      return getLTAntecedents(_x, _y, _z, assignment, state);
//   }

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
//    TRUInt* zUp;
//    TRUInt* zLow;
    
    [_x getUp:&xUp andLow:&xLow];
    [_y getUp:&yUp andLow:&yLow];
//    [_z getUp:&zUp andLow:&zLow];
    
    ORInt idx=0;
    
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
            vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
            vars[ants->numAntecedents]->index = index;
            vars[ants->numAntecedents]->var = _y;
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
            vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
            vars[ants->numAntecedents]->index = index;
            vars[ants->numAntecedents]->var = _x;
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
//        if(![_z isFree:0] && ![_z getBit:0])
            index = diffIndex;
//        else
//            index = idx;
       
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
//    TRUInt* zUp;
//    TRUInt* zLow;
    
    [_x getUp:&xUp andLow:&xLow];
    [_y getUp:&yUp andLow:&yLow];
//    [_z getUp:&zUp andLow:&zLow];
    
    ORInt index = assignment->index;
    
    ORUInt* xSetBits = alloca(sizeof(ORUInt)*wordLength);
    ORUInt* ySetBits = alloca(sizeof(ORUInt)*wordLength);
    
    ORUInt level = [assignment->var getLevelBitWasSet:assignment->index];

    if(assignment->var == _x)
        [_x getState:xSetBits whenBitSet:assignment->index];
    else
        [_x getState:xSetBits afterLevel:level];

    if(assignment->var == _y)
        [_y getState:ySetBits whenBitSet:assignment->index];
    else
        [_y getState:ySetBits afterLevel:level];

//    ORUInt** changes;
//    if(assignment->var == _x)
//        changes = _xChanges;
//    if(assignment->var == _y)
//        changes = _yChanges;
//    ORUInt mask = 0x1 << assignment->index%BITSPERWORD;
//    for(ORUInt i=0;i<_top._val;i++){
//        for(ORUInt j=0;j<wordLength;j++){
//            xSetBits[j] |= _xChanges[i][j];
//            ySetBits[j] |= _yChanges[i][j];
//        }
//        if(changes[i][assignment->index/BITSPERWORD] & mask)
//            break;
//    }

    ORUInt* x1y0 = alloca(sizeof(ORUInt)*wordLength);
    
   ORUInt* xl = alloca(sizeof(ORUInt)*wordLength);
   ORUInt* xu = alloca(sizeof(ORUInt)*wordLength);
   ORUInt* yl = alloca(sizeof(ORUInt)*wordLength);
   ORUInt* yu = alloca(sizeof(ORUInt)*wordLength);
   
   if(![_z isFree:0] && [_z getBit:0]){
      for(int i=0;i<wordLength;i++){
         xl[i] = xLow[i]._val;
         xu[i] = xUp[i]._val;
         yl[i] = yLow[i]._val;
         yu[i] = yUp[i]._val;
      }
   }
   else{
      for(int i=0;i<wordLength;i++){
         xl[i] = yLow[i]._val;
         xu[i] = yUp[i]._val;
         yl[i] = xLow[i]._val;
         yu[i] = xUp[i]._val;
      }
      ORUInt* tempX = xSetBits;
      xSetBits = ySetBits;
      ySetBits = tempX;
   }
   
   ORUInt signMask = 0x1 << ((bitLength-1)%BITSPERWORD);
   
   if(~(xl[wordLength-1]^xu[wordLength-1]) & signMask){
      xl[wordLength-1] ^= signMask;
      xu[wordLength-1] ^= signMask;
   }
   if(~(yl[wordLength-1]^yu[wordLength-1]) & signMask){
      yl[wordLength-1] ^= signMask;
      yu[wordLength-1] ^= signMask;
   }
   
   ORInt idx=0;
   for(int i=wordLength-1;i>=0;i--){
      x1y0[i] = ((xl[i] & xSetBits[i]) & (~yu[i] & ySetBits[i]));
      //        x1y0[i] = xLow[i]._val & ~yUp[i]._val;
      if(x1y0[i] != 0){
         idx = (i*BITSPERWORD)+(BITSPERWORD - __builtin_clz(x1y0[i])-1);
         //            //          //find number of consecutive bits with x=1 and y=0
         //            //          //starting at msb where this is the case
         //            int countBits = 0;
         //            ORUInt mask = 0x1<<(idx/BITSPERWORD);
         //            while((x1y0[i] & (mask<<(idx-countBits))) != 0){
         //                countBits++;
         //            }
         //            idx-=countBits-1;
         break;
      }
   }
   index=idx;
    
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
//            if ((index>idx) && !assignment->value && [_y getBit:index])
                if (index>idx)
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
//            if((index>idx) && assignment->value && ![_x getBit:index])
                if(index>idx)
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
//        if([_z getBit:0] == false)
            index = diffIndex;
//        else
//            index = idx;
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
//        if(((i!=assignment->index) && ![_x isFree:i]) || ((i==assignment->index) && xAtIndex)){
        if((((i!=assignment->index) && (xSetBits[i/BITSPERWORD] & 0x1<<(i%BITSPERWORD))) || ((i==assignment->index) && xAtIndex)) && ![_x isFree:i]){
            vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
            vars[ants->numAntecedents]->index = i;
            vars[ants->numAntecedents]->var = _x;
            vars[ants->numAntecedents]->value = [_x getBit:i];
            ants->numAntecedents++;
        }
//        if(((i!=assignment->index) && ![_y isFree:i]) || ((i==assignment->index) && yAtIndex)){
        if((((i!=assignment->index) && (ySetBits[i/BITSPERWORD] & 0x1<<(i%BITSPERWORD))) || ((i==assignment->index) && yAtIndex))&& ![_y isFree:i]){
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
//   if(![_z getBit:0])
//      NSLog(@"");

    return ants;
}

- (void) dealloc
{
    if(_state != nil)
        free(_state);
    [super dealloc];
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_y bound]+ ![_z bound];
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
//   [_x incrementActivityBySignificance];
//   [_y incrementActivityBySignificance];
//   [_z incrementActivityBySignificance];
   [_x incrementActivityAll];
   [_y incrementActivityAll];
//   [_z incrementActivityAll];
   [_z increaseActivity:0 by:[_x bitLength]+[_y bitLength]];
//   [_z incrementActivityAll];
}
-(void) propagate
{
   //TODO: Fix so that _z can be larger than 32 bits if this is the design decision made
   
#ifdef BIT_DEBUG
   NSLog(@"**********************************");
   NSLog(@"Bit (signed) < Constraint propagated.");
#endif
   
   ORUInt wordLength = [_x getWordLength];
   ORUInt bitLength = [_x bitLength];
   ORUInt zWordLength = [_z getWordLength];
//   ORUInt zBitLength = [_z bitLength];
   
//   TRUInt* xLow;
//   TRUInt* xUp;
//   TRUInt* yLow;
//   TRUInt* yUp;
//   TRUInt* zLow;
//   TRUInt* zUp;
//
//   [_x getUp:&xUp andLow:&xLow];
//   [_y getUp:&yUp andLow:&yLow];
//   [_z getUp:&zUp andLow:&zLow];
   
    ULRep xr = getULVarRep(_x);
    ULRep yr = getULVarRep(_y);
    ULRep zr = getULVarRep(_z);
    TRUInt *xLow = xr._low, *xUp = xr._up;
    TRUInt *yLow = yr._low, *yUp = yr._up;
    TRUInt *zLow = zr._low, *zUp = zr._up;

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
   
//    ORUInt signMask = 0x1 << (BITSPERWORD - (bitLength%BITSPERWORD) -1);
//    ORUInt signMask = 0x1 << (BITSPERWORD - 1);
   ORUInt signMask = 0x1 << ((bitLength-1)%BITSPERWORD);
   
//    newXLow[wordLength-1] <<= BITSPERWORD - (bitLength%BITSPERWORD);
//    newXUp[wordLength-1] <<= BITSPERWORD - (bitLength%BITSPERWORD);
//    newYLow[wordLength-1] <<= BITSPERWORD - (bitLength%BITSPERWORD);
//    newYUp[wordLength-1] <<= BITSPERWORD - (bitLength%BITSPERWORD);

   ORUInt numFreeBitsX = 0;
   ORUInt numFreeBitsY = 0;
   
   //Find most sig. unset bit in x
   for(ORInt i = wordLength-1;i>=0;i--){
      freeX[i] = newXUp[i] ^ newXLow[i];
      numFreeBitsX += __builtin_popcount(freeX[i]);
   }
   //Find most sig. unset bit in y
   for(ORInt i = wordLength-1;i>=0;i--){
      freeY[i] = newYUp[i] ^ newYLow[i];
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
//   ORBool xgeqy = false;
   
   for (int i=wordLength-1; i>=0; i--) {
      if (((newXUp[i] ^ newXLow[i]) | (newYUp[i]^ newYLow[i]) | (newXLow[i] ^ newYLow[i])) == 0)
         continue;
      else
         xeqy = false;
      if (newXLow[i] > newYUp[i]) {
         xgty = true;
         break;
      }
      else if (newXUp[i] < newYLow[i]) {
         xlty = true;
         break;
      }
   }
//   for(int i = 0;i<wordLength;i++)
//      if(newXLow[i] >= newYUp[i]){
//         xgeqy = true;
//         break;
//      }

//   if(xgeqy)
//      newZUp[0] = 0;
   
   if(xlty){
      newZLow[0] |= 0x1;
   }
   if(xgty || xeqy){
      for (int i=0; i<zWordLength; i++)
         newZUp[i] = 0;
   }
//      _state[0] = newXUp;
//      _state[1] = newXLow;
//      _state[2] = newYUp;
//      _state[3] = newYLow;
//      _state[4] = newZUp;
//      _state[5] = newZLow;
//
//      checkDomainConsistency(_z, newZLow, newZUp, zWordLength, self);
//      [_z setUp:newZUp andLow:newZLow for:self];

   
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

   
   
//   ORBool xlty = false;
//   ORBool xgty = false;
//   ORBool xeqy = true;
   
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
   
   
//   if(xgeqy)
//      newZUp[0] = 0;
//   if(xlty){
//      newZLow[0] |= 0x1;
//   }
//   if(xgty || xeqy){
//      for (int i=0; i<zWordLength; i++)
//         newZUp[i] = 0;
//   }
//   _state[0] = newXUp;
//   _state[1] = newXLow;
//   _state[2] = newYUp;
//   _state[3] = newYLow;
//   _state[4] = newZUp;
//   _state[5] = newZLow;
//   
//   checkDomainConsistency(_z, newZLow, newZUp, zWordLength, self);
//   [_z setUp:newZUp andLow:newZLow for:self];

   
   
   
   //flip most sig .sign bit if set
   freeX[wordLength-1] = newXUp[wordLength-1] ^ newXLow[wordLength-1];
   freeY[wordLength-1] = newYUp[wordLength-1] ^ newYLow[wordLength-1];
   
   if((~freeX[wordLength-1]) & signMask){
      newXUp[wordLength-1] ^= signMask;
      newXLow[wordLength-1] ^= signMask;
   }
   if((~freeY[wordLength-1]) & signMask){
      newYUp[wordLength-1] ^= signMask;
      newYLow[wordLength-1] ^= signMask;
   }
    
    
    
    
//    newXLow[wordLength-1] >>= BITSPERWORD - (bitLength%BITSPERWORD);
//    newXUp[wordLength-1] >>= BITSPERWORD - (bitLength%BITSPERWORD);
//    newYLow[wordLength-1] >>= BITSPERWORD - (bitLength%BITSPERWORD);
//    newYUp[wordLength-1] >>= BITSPERWORD - (bitLength%BITSPERWORD);

   
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

//       NSLog(@"newX = %@",bitvar2NSString(newXLow, newXUp, 32));
//       NSLog(@"newY = %@",bitvar2NSString(newYLow, newYUp, 32));
//       NSLog(@"newZ = %@",bitvar2NSString(newZLow, newZUp, 32));

    
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
   
//    if(newZLow[0]){
//        if ((ORInt)newXLow[0] >= (ORInt)newYUp[0])
//            NSLog(@"fail");
//    }else{
//        if ((ORInt)newXUp[0] < (ORInt)newYLow[0])
//            NSLog(@"fail");
//    }
//    if (!newZUp[0]){
//        if((ORInt)newYLow[0] > (ORInt)newXUp[0])
//            NSLog(@"fail");
//    }else{
//        if ((ORInt)newYUp[0] < (ORInt)newXLow[0])
//            NSLog(@"fail");
//    }
   
//    ORUInt changed=0;
//    for(ORUInt i =0; i<wordLength;i++){
//        changed |= newXUp[i] ^ xUp[i]._val;
//        changed |= newXLow[i] ^ xLow[i]._val;
//        changed |= newYUp[i] ^ yUp[i]._val;
//        changed |= newYLow[i] ^ yLow[i]._val;
//    }
//    if(changed){
//        ORUInt* xChanges = malloc(sizeof(ORUInt)*wordLength);
//        ORUInt* yChanges = malloc(sizeof(ORUInt)*wordLength);
//        for(ORUInt i=0;i<wordLength;i++){
//            xChanges[i] = newXUp[i] ^ xUp[i]._val;
//            xChanges[i] |= newXLow[i] ^ xLow[i]._val;
//            yChanges[i] = newYUp[i] ^ yUp[i]._val;
//            yChanges[i] |= newYLow[i] ^ yLow[i]._val;
//        }
//        _xChanges[_top._val] = xChanges;
//        _yChanges[_top._val] = yChanges;
//        assignTRUInt(&_top, _top._val+1, [[_x engine]trail]);
//    }

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
   _iWasSet = malloc(sizeof(ORUInt)*[_r getWordLength]);
   _state = malloc(sizeof(ORUInt*)*8);
   return self;
   
}

- (void) dealloc
{
    if(_state != nil)
        free(_state);
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

-(ORUInt)nbUVars
{
   return ![_i bound] + ![_t bound] + ![_e bound] + ![_r bound];
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
   ORUInt tBitLength = [_t bitLength];
//   [_i incrementActivityAll];
   [_i increaseActivity:0 by:tBitLength*3];
   [_t incrementActivityAllBy:2.0];
   [_e incrementActivityAllBy:2.0];
   [_r incrementActivityAllBy:3.0];
}

-(CPBitAntecedents*) getAntecedents:(CPBitAssignment*)assignment{
   return ([self getAntecedentsFor:assignment withState:_state]);
}
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment withState:(ORUInt**)state
{
  //NSLog(@"Implication for 0x%lx[%u] = %@  traced back through %@", (unsigned long)assignment->var, assignment->index, (CPBitVarI*)assignment->var, self);
//   if(assignment->var == _i && assignment->value)
//      NSLog(@"");
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
    
    
    //must decide if bits in r were set because of _i or because same in _t and _e
    
    ORInt ifLevel = (ORInt)[_i getLevelBitWasSet:0];
    if((assignment->var == _r) && ((ifLevel == -1) || ([assignment->var getLevelBitWasSet:assignment->index] < ifLevel))){
//    if(assignment->var == _r){
        vars  = malloc(sizeof(CPBitAssignment*)*2);
        if (![_t isFree:assignment->index] || (~ISFREE(state[2][assignment->index/BITSPERWORD],  state[3][assignment->index/BITSPERWORD]) & (0x1 << (assignment->index%BITSPERWORD)))) {
            vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
            vars[ants->numAntecedents]->var = _t;
            vars[ants->numAntecedents]->index = assignment->index;
            if(![_t isFree:assignment->index])
                vars[ants->numAntecedents]->value = [_t getBit:assignment->index];
            else
                vars[ants->numAntecedents]->value = !((ISTRUE(state[2][assignment->index/BITSPERWORD],  state[3][assignment->index/BITSPERWORD]) & (0x1 << (assignment->index%BITSPERWORD))) == 0);
            ants->numAntecedents++;
        }
        if (![_e isFree:assignment->index] || (~ISFREE(state[4][assignment->index/BITSPERWORD],  state[5][assignment->index/BITSPERWORD]) & (0x1 << (assignment->index%BITSPERWORD)))) {
            vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
            vars[ants->numAntecedents]->var = _e;
            vars[ants->numAntecedents]->index = assignment->index;
            if(![_e isFree:assignment->index])
                vars[ants->numAntecedents]->value = [_e getBit:assignment->index];
            else
                vars[ants->numAntecedents]->value = !((ISTRUE(state[4][assignment->index/BITSPERWORD],  state[5][assignment->index/BITSPERWORD]) & (0x1 << (assignment->index%BITSPERWORD))) == 0);
            ants->numAntecedents++;
        }
        ants->antecedents =  vars;
        return ants;
    }
   //else if assignment var is _r the bit was set because of _i and corresponding bit in _t/_e
    else if(assignment->var == _r){
       vars  = malloc(sizeof(CPBitAssignment*)*2);
       if (![_i isFree:0] || (~ISFREE(state[0][0],  state[1][0]) & 0x1)) {
          vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
          vars[ants->numAntecedents]->var = _i;
          vars[ants->numAntecedents]->index = 0;
          if(![_i isFree:0])
             vars[ants->numAntecedents]->value = [_i getBit:0];
          else
             vars[ants->numAntecedents]->value = !((ISTRUE(state[0][0],  state[1][0]) & 0x1) == 0);
          ants->numAntecedents++;
       }
       if([_i isFree:0] || [_i getBit:0]){
          vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
          vars[ants->numAntecedents]->var = _t;
          vars[ants->numAntecedents]->index = assignment->index;
          if(![_t isFree:assignment->index])
             vars[ants->numAntecedents]->value = [_t getBit:assignment->index];
          else
             vars[ants->numAntecedents]->value = !((ISTRUE(state[2][assignment->index/BITSPERWORD],  state[3][assignment->index/BITSPERWORD]) & (0x1 << (assignment->index%BITSPERWORD))) == 0);
          ants->numAntecedents++;
       }
       else if([_i isFree:0] || ~[_i getBit:0]){
          vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
          vars[ants->numAntecedents]->var = _e;
          vars[ants->numAntecedents]->index = assignment->index;
          if(![_e isFree:assignment->index])
             vars[ants->numAntecedents]->value = [_e getBit:assignment->index];
          else
             vars[ants->numAntecedents]->value = !((ISTRUE(state[4][assignment->index/BITSPERWORD],  state[5][assignment->index/BITSPERWORD]) & (0x1 << (assignment->index%BITSPERWORD))) == 0);
          ants->numAntecedents++;
       }
       ants->antecedents =  vars;
       return ants;
    }
   
    if (assignment->var == _i) {
      
      vars  = malloc(sizeof(CPBitAssignment*)*4*bitLength);
        ants->antecedents = vars;
       
//       ORUInt* eq = alloca(sizeof(ORUInt)*wordLength);
       ORUInt* neq = alloca(sizeof(ORUInt)*wordLength);

//        ULRep tr = getULVarRep(_t);
//        ULRep er = getULVarRep(_e);
        ULRep rr = getULVarRep(_r);
//        TRUInt *tLow = tr._low, *tUp = tr._up;
//        TRUInt *eLow = er._low, *eUp = er._up;
        TRUInt *rLow = rr._low, *rUp = rr._up;

        ORUInt* varUp;
        ORUInt* varLow;
        ORUInt* setMask = alloca(sizeof(ORUInt)*wordLength);
       ORUInt* rSetMask = alloca(sizeof(ORUInt)*wordLength);
       
       if(assignment->value || [_i isFree:0]){
//            //_t == _r and _e != r
            var = _e;
            varUp = state[4];
            varLow = state[5];
//            [_e getState:setMask afterLevel:ifLevel];
          
            for (int i =0; i<wordLength; i++) {
               rSetMask[i] = ~(_state[6][i] & ~_state[7][i]) | (~_state[6][i] & _state[7][i]);
               setMask[i] = ~(_state[4][i] & ~_state[5][i]) | (~_state[4][i] & _state[5][i]);
//                eq[i] = (~(tUp[i]._val ^ rUp[i]._val) & ~(tLow[i]._val ^ rLow[i]._val));
//                neq[i] = ((varUp[i] ^ state[6][i]) | (varLow[i] ^ state[7][i]))&setMask[i]&rSetMask[i];
               neq[i] = ((varUp[i] ^ rUp[i]._val) | (varLow[i] ^ rLow[i]._val))&setMask[i]&rSetMask[i];
            }
            for (int i = 0; i<bitLength; i++) {
                if(neq[i/BITSPERWORD] & (0x1<<(i%BITSPERWORD))){
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
                    else continue;
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
                }
            }
        }
       if(!assignment->value || [_i isFree:0] ){
            var = _t;
            varUp = state[2];
            varLow = state[3];
//            [_t getState:setMask afterLevel:ifLevel];
            for (int i =0; i<wordLength; i++) {
               rSetMask[i] = ~(_state[6][i] & ~_state[7][i]) | (~_state[6][i] & _state[7][i]);
               setMask[i] = ~(state[2][i] & ~state[3][i]) | (~_state[2][i] & _state[3][i]);
//                eq[i] = (~(eUp[i]._val ^ rUp[i]._val) & ~(eLow[i]._val ^ rLow[i]._val));
//                neq[i] = ((varUp[i] ^ state[6][i]) | (varLow[i] ^ state[7][i]))&setMask[i]&rSetMask[i];
               neq[i] = ((varUp[i] ^ rUp[i]._val) | (varLow[i] ^ rLow[i]._val))&setMask[i]&rSetMask[i];

            }
       
       //only include the bits that match in _r and the corresponding bitvar (_t/_e) and the bit that doesn't match
       //in _r and the non-matching bit vector.
          for (int i = 0; i<bitLength; i++) {
              if(neq[i/BITSPERWORD] & (0x1<<(i%BITSPERWORD))){
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
                  else continue;
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
            }
          }
        }

        return ants;
   }
   
   else if (assignment->var == _t){
      vars  = malloc(sizeof(CPBitAssignment*)*2);
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
      vars  = malloc(sizeof(CPBitAssignment*)*2);
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
      vars  = malloc(sizeof(CPBitAssignment*)*2);
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
//   if(assignment->var == _i && assignment->value)
//      NSLog(@"");
  //NSLog(@"Implication for 0x%lx[%u] = %@  traced back through %@", (unsigned long)assignment->var, assignment->index, (CPBitVarI*)assignment->var, self);
   CPBitAntecedents* ants = malloc(sizeof(CPBitAntecedents));
   CPBitAssignment** vars;

   ants->numAntecedents = 0;

   ORUInt index = assignment->index;
   
   ORUInt wordLength = [_r getWordLength];
   ORUInt bitLength = [_r bitLength];

    ORInt ifLevel = (ORInt)[_i getLevelBitWasSet:0];
    if((assignment->var == _r) && ([_i isFree:0] || ([assignment->var getLevelBitWasSet:assignment->index] < ifLevel))){
        vars  = malloc(sizeof(CPBitAssignment*)*2);
        if (![_t isFree:assignment->index]) {
            vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
            vars[ants->numAntecedents]->var = _t;
            vars[ants->numAntecedents]->index = assignment->index;
            vars[ants->numAntecedents]->value = [_t getBit:assignment->index];
            ants->numAntecedents++;
        }
        if (![_e isFree:assignment->index] ) {
            vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
            vars[ants->numAntecedents]->var = _e;
            vars[ants->numAntecedents]->index = assignment->index;
            vars[ants->numAntecedents]->value = [_e getBit:assignment->index];
            ants->numAntecedents++;
        }
        ants->antecedents =  vars;
        return ants;
    }
   else if(assignment->var == _r){
       vars  = malloc(sizeof(CPBitAssignment*)*2);
       if (![_i isFree:0]) {
          vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
          vars[ants->numAntecedents]->var = _i;
          vars[ants->numAntecedents]->index = 0;
          vars[ants->numAntecedents]->value = [_i getBit:0];
          ants->numAntecedents++;
       }
       if([_i isFree:0] || [_i getBit:0]){
          if (![_t isFree:assignment->index]) {
             vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
             vars[ants->numAntecedents]->var = _t;
             vars[ants->numAntecedents]->index = assignment->index;
             vars[ants->numAntecedents]->value = [_t getBit:assignment->index];
             ants->numAntecedents++;
          }
          
       }
       else {
          vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
          vars[ants->numAntecedents]->var = _e;
          vars[ants->numAntecedents]->index = assignment->index;
          vars[ants->numAntecedents]->value = [_e getBit:assignment->index];
          ants->numAntecedents++;
       }
       ants->antecedents =  vars;
       return ants;
    }

   if (assignment->var == _i) {
      
      vars  = malloc(sizeof(CPBitAssignment*)*2*bitLength);

       ORUInt* neq = alloca(sizeof(ORUInt)*wordLength);
       
       ULRep tr = getULVarRep(_t);
       ULRep er = getULVarRep(_e);
       ULRep rr = getULVarRep(_r);
       TRUInt *tLow = tr._low, *tUp = tr._up;
       TRUInt *eLow = er._low, *eUp = er._up;
       TRUInt *rLow = rr._low, *rUp = rr._up;
       
       CPBitVarI* var;
       ORUInt* setMask = alloca(sizeof(ORUInt)*wordLength);
      ORUInt* rSetMask = alloca(sizeof(ORUInt)*wordLength);
      
      if(!assignment->value){
         //_t == _r and _e != r
          var = _t;
          [_t getState:setMask afterLevel:ifLevel];
          [_r getState:rSetMask afterLevel:ifLevel];
          for (int i =0; i<wordLength; i++) {
             neq[i] = ((tUp[i]._val ^ rUp[i]._val) | (tLow[i]._val ^ rLow[i]._val))&setMask[i]&rSetMask[i];
          }
       }
       else{
          var = _e;
          [_e getState:setMask afterLevel:ifLevel];
          [_r getState:rSetMask afterLevel:ifLevel];
          for (int i =0; i<wordLength; i++) {
             neq[i] = ((eUp[i]._val ^ rUp[i]._val) | (eLow[i]._val ^ rLow[i]._val))&setMask[i]&rSetMask[i];
          }
       }
       
      for (int i = 0; i<bitLength; i++) {
          if(neq[i/BITSPERWORD] & (0x1<<(i%BITSPERWORD))){
              if (![_r isFree:i]) {
                  vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
                  vars[ants->numAntecedents]->var = _r;
                  vars[ants->numAntecedents]->index = i;
                  vars[ants->numAntecedents]->value = [_r getBit:i];
                  ants->numAntecedents++;
              }
              else
                 continue;
              if (![var isFree:i]) {
               vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
               vars[ants->numAntecedents]->var = var;
               vars[ants->numAntecedents]->index = i;
               vars[ants->numAntecedents]->value = [var getBit:i];
               ants->numAntecedents++;
             }
          }
      }
       ants->antecedents = vars;
       return ants;
   }

   else if (assignment->var == _t){
      vars  = malloc(sizeof(CPBitAssignment*)*2);

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
      vars  = malloc(sizeof(CPBitAssignment*)*2);
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
      vars  = malloc(sizeof(CPBitAssignment*)*2);
      if (_iWasSet[assignment->index/BITSPERWORD] & (0x1<<assignment->index%BITSPERWORD)) {
         vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
         vars[ants->numAntecedents]->var = _i;
         vars[ants->numAntecedents]->index = 0;
         vars[ants->numAntecedents]->value = [_i getBit:0];
         ants->numAntecedents++;

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
      else{
         if (![_t isFree:index])
            {
               vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
               vars[ants->numAntecedents]->var = _t;
               vars[ants->numAntecedents]->index = index;
               vars[ants->numAntecedents]->value = [_t getBit:index];
               ants->numAntecedents++;
            }
         if (![_e isFree:index])
            {
               vars[ants->numAntecedents] = malloc(sizeof(CPBitAssignment));
               vars[ants->numAntecedents]->var = _e;
               vars[ants->numAntecedents]->index = index;
               vars[ants->numAntecedents]->value = [_e getBit:index];
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
   
   ORUInt wordLength = [_t getWordLength];
   
    ULRep ir = getULVarRep(_i);
    ULRep tr = getULVarRep(_t);
    ULRep er = getULVarRep(_e);
    ULRep rr = getULVarRep(_r);
    TRUInt *iLow = ir._low, *iUp = ir._up;
    TRUInt *tLow = tr._low, *tUp = tr._up;
    TRUInt *eLow = er._low, *eUp = er._up;
    TRUInt *rLow = rr._low, *rUp = rr._up;

    ORUInt* newIUp = alloca(sizeof(ORUInt));
   ORUInt* newILow = alloca(sizeof(ORUInt));
   ORUInt* newTUp = alloca(sizeof(ORUInt)*wordLength);
   ORUInt* newTLow = alloca(sizeof(ORUInt)*wordLength);
   ORUInt* newEUp = alloca(sizeof(ORUInt)*wordLength);
   ORUInt* newELow = alloca(sizeof(ORUInt)*wordLength);
   ORUInt* newRUp = alloca(sizeof(ORUInt)*wordLength);
   ORUInt* newRLow = alloca(sizeof(ORUInt)*wordLength);
   
//      NSLog(@"*******************************************");
//      NSLog(@"if %@\n",_i);
//      NSLog(@"then %@\n",_t);
//      NSLog(@"else %@\n",_e);
//      NSLog(@"res %@\n\n",_r);
//        NSLog(@"");
   
   
   newILow[0] = iLow[0]._val;
   newIUp[0] = iUp[0]._val;
   
   ORUInt rNEQt = 0;
   ORUInt rNEQe = 0;
   for (int i=0; i<wordLength; i++) {
      rNEQt |= (tLow[i]._val & ~rUp[i]._val);// ^ xLow[i]._val;
      rNEQt |= (~tUp[i]._val & rLow[i]._val);// ^ ~xUp[i]._val;
      rNEQe |= (eLow[i]._val & ~rUp[i]._val);// ^ xLow[i]._val;
      rNEQe |= (~eUp[i]._val & rLow[i]._val);// ^ ~xUp[i]._val;
   }
   
   if (rNEQe)
      newILow[0] = 1;
   
   if (rNEQt)
      newIUp[0] = 0;

   
   for (int i=0; i<wordLength; i++) {
      newTLow[i] = tLow[i]._val;
      newTUp[i] = tUp[i]._val;
      newELow[i] = eLow[i]._val;
      newEUp[i] = eUp[i]._val;
      newRLow[i] = rLow[i]._val;
      newRUp[i] = rUp[i]._val;
   }

   if (newILow[0]) {
      for(int i=0;i<wordLength;i++){
         newTUp[i] = newRUp[i] = tUp[i]._val & rUp[i]._val;
         newTLow[i] = newRLow[i] = tLow[i]._val | rLow[i]._val;
      }
   }
   else if (newIUp[0] == 0){
      for(int i=0;i<wordLength;i++){
         newEUp[i] = newRUp[i] = eUp[i]._val & rUp[i]._val;
         newELow[i] = newRLow[i] = eLow[i]._val | rLow[i]._val;
      }
   }
    
     //if bit is same in then and else, set it in result
     for(int i=0;i<wordLength;i++){
         newRUp[i] &=  ~(~tUp[i]._val & ~eUp[i]._val);
         newRLow[i] |= (tLow[i]._val & eLow[i]._val);
     }
   
   //todo: double check the purpose of this
   if(!(iUp[0]._val ^ iLow[0]._val)){
      for(ORUInt i = 0; i<wordLength;i++){
         _iWasSet[i] = (rUp[i]._val ^ newRUp[i]) | (rLow[i]._val ^ newRLow[i]);
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
   
//   NSLog(@"*******************************************");
//   NSLog(@"if %@\n",_i);
//   NSLog(@"then %@\n",_t);
//   NSLog(@"else %@\n",_e);
//   NSLog(@"res %@\n\n",_r);
//   NSLog(@"");

   
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
    if(_state != nil)
        free(_state);
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
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_y bound] + ![_z bound];
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
   [_x incrementActivityAllBy:2.0];
   [_y incrementActivityAllBy:2.0];
   [_z incrementActivityAllBy:2.0];
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
   
   ORUInt wordLength = [_x getWordLength];
   ORUInt zWordLength = [_z getWordLength];
    
    ULRep xr = getULVarRep(_x);
    ULRep yr = getULVarRep(_y);
    ULRep zr = getULVarRep(_z);
    TRUInt *xLow = xr._low, *xUp = xr._up;
    TRUInt *yLow = yr._low, *yUp = yr._up;
    TRUInt *zLow = zr._low, *zUp = zr._up;

    ORUInt one[zWordLength];
   ORUInt zero[zWordLength];
   for (int i=1; i<zWordLength; i++) {
      one[i] = zero[i] = 0x00000000;
   }
   one[0] = 0x00000001;
   zero[0] = 0x00000000;
   
   ORUInt* newZUp = alloca(sizeof(ORUInt)*zWordLength);
   ORUInt* newZLow = alloca(sizeof(ORUInt)*zWordLength);

   ORUInt* newXUp = alloca(sizeof(ORUInt)*wordLength);
   ORUInt* newXLow = alloca(sizeof(ORUInt)*wordLength);
   ORUInt* newYUp = alloca(sizeof(ORUInt)*wordLength);
   ORUInt* newYLow = alloca(sizeof(ORUInt)*wordLength);
   //ORUInt  upXORlow;
    
   for(int i=0;i<wordLength;i++){
      newXUp[i] = xUp[i]._val;
      newXLow[i] = xLow[i]._val;
      newYUp[i] = yUp[i]._val;
      newYLow[i] = yLow[i]._val;
   }
   
   ORUInt different = 0;
   ORUInt makesame = 0;
   ORUInt makedifferent = 0;
   for (int i=0; i<wordLength; i++) {
      different |= (xLow[i]._val & ~yUp[i]._val);// ^ xLow[i]._val;
      different |= (~xUp[i]._val & yLow[i]._val);// ^ ~xUp[i]._val;
   }
   
   for (int i=0; i<[_z getWordLength]; i++) {
      newZUp[i] = zUp[i]._val;
      newZLow[i] = zLow[i]._val;
      makesame |= zLow[i]._val;
      makedifferent |= zUp[i]._val;
   }
   
   if(makedifferent==0){
      ORUInt* xFreeBits = alloca(sizeof(ORUInt)*wordLength);
      ORUInt* yFreeBits = alloca(sizeof(ORUInt)*wordLength);
      ORUInt numXFreeBits = 0;
      ORUInt numYFreeBits = 0;

      for(ORUInt i = 0; i<wordLength;i++){
         xFreeBits[i] = xLow[i]._val ^ xUp[i]._val;
         yFreeBits[i] = yLow[i]._val ^ yUp[i]._val;
         numXFreeBits += xFreeBits[i];
         numYFreeBits += yFreeBits[i];
      }
      ORBool justOne = true;
      if((different == 0) && ((numXFreeBits==0) || (numYFreeBits==0))){
         if(numXFreeBits==0){
            numYFreeBits = 0;
            for(ORUInt i=0;i<wordLength;i++){
               if(yFreeBits[i] && !(yFreeBits[i] & (yFreeBits[i]-1)))
                  numYFreeBits++;
               else if (yFreeBits[i])
                  justOne = false;
            }
            if (justOne && (numYFreeBits==1)){
               for(ORUInt i=0; i<wordLength;i++)
                  if(yFreeBits[i]){
                     if(yFreeBits[i] & xLow[i]._val)
                        newYUp[i] &= ~yFreeBits[i];
                     else
                        newYLow[i] |= yFreeBits[i];
                  }
            }
         }
         else{
            numXFreeBits = 0;
            for(ORUInt i=0;i<wordLength;i++){
               if(xFreeBits[i] && !(xFreeBits[i] & (xFreeBits[i]-1)))
                  numXFreeBits++;
               else if (xFreeBits[i])
                  justOne = false;
            }
            if (justOne && (numXFreeBits==1)){
               for(ORUInt i=0; i<wordLength;i++)
                  if(xFreeBits[i]){
                     if(xFreeBits[i] & yLow[i]._val)
                        newXUp[i] &= ~xFreeBits[i];
                     else
                        newXLow[i] |= xFreeBits[i];
                  }
            }
         }
      }

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
//         newZLow[i] = zLow[i]._val | zero[i];
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
//      newZUp[0] = zUp[0]._val & one[0];
      newZLow[0] = zLow[0]._val | one[0];
//      upXORlow = newZUp[0] ^ newZLow[0];
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
//         newZLow[i] = zLow[i]._val | zero[i];
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
    if(_state != nil)
        free(_state);
    [super dealloc];
}
-(ORUInt)nbUVars
{
   ORInt nbuv = 0;
   for(ORInt k=[_x low];k<=[_x up];k++)
      nbuv += !([(CPBitVarI*)[_x at: k] bound]);
   nbuv += [_r bound];
   return nbuv;
}
-(void) post
{
[self propagate];
   ORUInt xLow = [_x low];
   ORUInt xUp = [_x up];
   for (int i=xLow; i<=xUp; i++) {
      if (![_x[i] bound]){
         [(CPBitVarI*)[_x at:i] whenChangePropagate: self];
         [(CPBitVarI*)[_x at:i] incrementActivityAll];
      }
   }
   
   if (![_r bound]) {
      [_r whenChangePropagate: self];
      [_r incrementActivityAllBy:xUp-xLow];
   }
[self propagate];
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
//   ORUInt* rup = alloca(sizeof(ORUInt)* [_r getWordLength]);
//   ORUInt* rlow = alloca(sizeof(ORUInt)* [_r getWordLength]);
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
//   TRUInt* rLow;
//   TRUInt* rUp;
    ULRep rr = getULVarRep(_r);
    TRUInt *rLow = rr._low, *rUp = rr._up;
    
   ORInt rLength = [_r getWordLength];
   
   ORUInt newXUp;
   ORUInt newXLow;
   ORUInt xLength;
   
   ORUInt fail;

   ORUInt* rup = alloca(sizeof(ORUInt)* rLength);
   ORUInt* rlow = alloca(sizeof(ORUInt)* rLength);
   
//   [_r getUp:&rUp andLow:&rLow];
   
   
   
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
      ORUInt* xup = alloca(sizeof(ORUInt)* [lastUnboundVar getWordLength]);
      ORUInt* xlow = alloca(sizeof(ORUInt)* [lastUnboundVar getWordLength]);
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
//<<<<<<< HEAD
         if([_x[i] bound] && ![(CPBitVarI*)_x[i] getBit:0])
//=======
//         if([_x[i] bound] && ![_x[i] bitAt:0])    // [LDM] this was calling getBit: (which does not exist.) I guess this was meant to be "bitAt:"
//>>>>>>> 116184882f379e03de2b0ba0ae0408e9a4959a0b
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
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment
{
  //NSLog(@"Implication for 0x%lx[%u] = %@  traced back through %@", (unsigned long)assignment->var, assignment->index, (CPBitVarI*)assignment->var, self);



   return NULL;
}

- (void) dealloc
{
    if(_state != nil)
        free(_state);
    [super dealloc];
}
-(ORUInt)nbUVars
{
   ORInt nbuv = 0;
   for(ORInt k=[_x low];k<=[_x up];k++)
      nbuv += !([(CPBitVarI*)[_x at: k] bound]);
   nbuv += [_r bound];
   return nbuv;
}
-(void) post
{
   [self propagate];
   ORUInt xLow = [_x low];
   ORUInt xUp = [_x up];
   for (int i=xLow; i<=xUp; i++) {
      if (![_x[i] bound]){
         [(CPBitVarI*)_x[i] whenChangePropagate: self];
         [(CPBitVarI*)_x[i] incrementActivityAll];
      }
   }
   if (![_r bound]) {
      [_r whenChangePropagate: self];
      [_r incrementActivityAllBy:xUp-xLow];
}
   [self propagate];
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
//   TRUInt* rLow;
//   TRUInt* rUp;

//    ULRep xr = getULVarRep(_x);
    ULRep rr = getULVarRep(_r);
    TRUInt *rLow = rr._low, *rUp = rr._up;

   ORInt rLength = [_r getWordLength];

   ORUInt* rup = alloca(sizeof(ORUInt)* rLength);
   ORUInt* rlow = alloca(sizeof(ORUInt)* rLength);
   
//   [_r getUp:&rUp andLow:&rLow];
   
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
      ORUInt* xup = alloca(sizeof(ORUInt)* [_r getWordLength]);
      ORUInt* xlow = alloca(sizeof(ORUInt)* [_r getWordLength]);
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
    for(int i=0;i<_assignments->numAntecedents;i++)
        free(_assignments->antecedents[i]);
    free(_assignments->antecedents);
    free(_assignments);
//    if(_state != nil)
//        free(_state);
    [super dealloc];
}
-(ORUInt)nbUVars
{
   ORInt nbuv = 0;
   for (int i = 0; i<_assignments->numAntecedents; i++)
      nbuv += ![(CPBitVarI*)_assignments->antecedents[i]->var  bound];
   return nbuv;
}
-(void) post
{
   [self propagate];
   for (int i = 0; i<_assignments->numAntecedents; i++) {
       if (![(CPBitVarI*)_assignments->antecedents[i]->var bound]){
          [(CPBitVarI*)_assignments->antecedents[i]->var whenChangePropagate: self];
          //For bitFixedEvt, at: refers to priority, not bit position
//           [(CPBitVarI*)_assignments->antecedents[i]->var whenBitFixed:self at:_assignments->antecedents[i]->index do:^{[self propagate];}];
          [(CPBitVarI*)_assignments->antecedents[i]->var increaseActivity:_assignments->antecedents[i]->index by:_assignments->numAntecedents-1];
       }
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
//         failNow();
         ORUInt idx;
         ORBool val;
         ORInt maxLevel = 5;
//         ORUInt currLevel = [(CPLearningEngineI*)[_assignments->antecedents[0]->var engine] getLevel];
//         CPBitVarI* var = nil;
         CPBitVarI* var = _assignments->antecedents[0]->var;
         for(int i=0;i<numVars;i++){
            ORInt setLevel = (ORInt)[_assignments->antecedents[i]->var getLevelBitWasSet:_assignments->antecedents[i]->index];
//            if ((setLevel != -1) && (setLevel >= maxLevel) && (setLevel > 4) && (setLevel <= currLevel)){
            if ((setLevel != -1) && (setLevel >= maxLevel)){
               maxLevel = setLevel;
//               currLevel = setLevel;
               var =_assignments->antecedents[i]->var;
               idx =_assignments->antecedents[i]->index;
               val=_assignments->antecedents[i]->value;
            }
         }
         
//         if (var == nil)
//            failNow();
         
         
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
         if(checkDomainConsistency(var, newLow, newUp, wordLength, self))
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
            mask = 0x1 << (_assignments->antecedents[i]->index % BITSPERWORD);
            if (_assignments->antecedents[i]->value) {
               //set only free bit to zero
               up[_assignments->antecedents[i]->index/BITSPERWORD] &= ~mask;
            }
            else{
               //set only free bit to one
               low[_assignments->antecedents[i]->index/BITSPERWORD] |= mask;
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
    if(_state != nil)
        free(_state);
    [super dealloc];
}
   -(ORUInt)nbUVars
   {
      return ![_x bound] + ![_y bound] + ![_r bound];
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
   [_x incrementActivityAllBy:2.0];
   [_y incrementActivityAllBy:2.0];
   [_r incrementActivityAllBy:2.0];

}
-(CPBitAntecedents*) getAntecedents:(CPBitAssignment*)assignment{
    return ([self getAntecedentsFor:assignment withState:_state]);
}
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment withState:(ORUInt**)state
{
    return nil;
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

-(void) propagate
{
#ifdef BIT_DEBUG
   NSLog(@"Bit Boolean OR Constraint propagated.");
#endif
    
   ORUInt newXUp, newXLow;
   ORUInt newYUp, newYLow;
   ORUInt newRUp, newRLow;
    
    ULRep xr = getULVarRep(_x);
    ULRep yr = getULVarRep(_y);
    ULRep rr = getULVarRep(_r);
    TRUInt *xLow = xr._low, *xUp = xr._up;
    TRUInt *yLow = yr._low, *yUp = yr._up;
    TRUInt *rLow = rr._low, *rUp = rr._up;

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
    if(_state != nil)
        free(_state);
    [super dealloc];
}

-(ORUInt)nbUVars
{
   return ![_x bound] + ![_r bound];
}
-(void) post
{
   [self propagate];
   if (![_x bound])
      [_x whenChangePropagate: self];
   if (![_r bound])
      [_r whenChangePropagate: self];
   [self propagate];
   [_x incrementActivityAll];
   [_r incrementActivityAll];
}

-(CPBitAntecedents*) getAntecedents:(CPBitAssignment*)assignment{
    return ([self getAntecedentsFor:assignment withState:_state]);
}
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment withState:(ORUInt**)state
{
    return nil;
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

-(void) propagate
{
#ifdef BIT_DEBUG
   NSLog(@"Bit Boolean Not Constraint propagated.");
#endif
   
   TRUInt* xLow;
   TRUInt* xUp;
   TRUInt* rLow;
   TRUInt* rUp;
   
   ORUInt newXUp, newXLow;
   ORUInt newRUp, newRLow;
   
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

//   NSLog(@"x=%@\n",bitvar2NSString(&newXLow, &newXUp, 32));
//   NSLog(@"r=%@\n",bitvar2NSString(&newRLow, &newRUp, 32));
      
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
    if(_state != nil)
        free(_state);
    [super dealloc];
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_y bound] + ![_r bound];
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
   [_x incrementActivityAll];
   [_y incrementActivityAll];
   [_r incrementActivityAll];

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
         
         //Must include ALL bits that are different...
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
    
   ORUInt wordLength = [_x getWordLength];
   //ORUInt bitLength = [_x bitLength];
   
   ORUInt* newXUp = alloca(sizeof(ORUInt)*wordLength);
   ORUInt* newXLow  = alloca(sizeof(ORUInt)*wordLength);
   ORUInt* newYUp = alloca(sizeof(ORUInt)*wordLength);
   ORUInt* newYLow  = alloca(sizeof(ORUInt)*wordLength);
   ORUInt newRUp, newRLow;
    
    ULRep xr = getULVarRep(_x);
    ULRep yr = getULVarRep(_y);
    ULRep rr = getULVarRep(_r);
    TRUInt *xLow = xr._low, *xUp = xr._up;
    TRUInt *yLow = yr._low, *yUp = yr._up;
    TRUInt *rLow = rr._low, *rUp = rr._up;

   ORUInt xyfree = 0x0;
   ORUInt* xyneq = alloca(sizeof(ORUInt)*wordLength);
//   ORUInt mask = 0x1;

//   NSLog(@"*******************************************");
//   NSLog(@"Boolean =");
//   NSLog(@"x=%@\n",_x);
//   NSLog(@"y=%@\n",_y);
//   NSLog(@"r=%@\n",_r);

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
//   if(newRLow){
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
         xyneq[i] = ((xLow[i]._val ^ yLow[i]._val) | (xUp[i]._val ^ yUp[i]._val)) & ~xfree[i] & ~yfree[i];
//        xyneq[i] = ((xLow[i]._val ^ yLow[i]._val) | (xUp[i]._val ^ yUp[i]._val));
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
//      if ((numXYDiff != 0) && !xyfree)
      if (numXYDiff != 0)
         newRUp = 0x0;
      else{
         if (xyfree == 0)
            newRLow = 0x1;
         if ((numXFree+numYFree == 1) && (newRUp==0)){
            if (numXFree == 1){
               //Set free bit in _x to opposite what it is in _y
               for(ORUInt i=0;i<wordLength;i++){
                  if(newXLow[i] == newYLow[i])
                     newXLow[i] = newXUp[i];
                  else
                     newXUp[i] = newXLow[i];
               }
            }
            else{
               //Set free bit in _y to opposite what it is in _x
               for(ORUInt i=0;i<wordLength;i++){
                  if(newYLow[i] == newXLow[i])
                     newYLow[i] = newYUp[i];
                  else
                     newYUp[i] = newYLow[i];
               }

            }
         }
      }
   }
   
   
//   if(newRUp ==0){
//      ORUInt bitLength = [_x bitLength];
//   if(([_x getId]==62) && ([_y getId]==3)){
//      NSLog(@"*******************************************");
//      NSLog(@"Boolean =");
//      NSLog(@"x=%@\n",_x);
//      NSLog(@"y=%@\n",_y);
//      NSLog(@"r=%@\n",_r);
//      NSLog(@"newX = %@",bitvar2NSString(newXLow, newXUp, bitLength));
//      NSLog(@"newY = %@",bitvar2NSString(newYLow, newYUp, bitLength));
//      NSLog(@"newR = %@\n\n",bitvar2NSString(&newRLow, &newRUp, 1));
//      NSLog(@"");
//   }
//   NSLog(@"");
//   NSLog(@"x = %@",_x);xf
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

//   CPBitVarI*     _temp0b;
//   CPBitVarI*     _temp0c;

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
   
   ORUInt wordLength = bitLength/BITSPERWORD + ((bitLength%BITSPERWORD ==0) ? 0 : 1);
   
   ORUInt*   up;
   ORUInt*   low;
   
   up = alloca(sizeof(ORUInt)*wordLength);
   low = alloca(sizeof(ORUInt)*wordLength);
   
   for (int i=0; i<wordLength; i++) {
      up[i] = 0xFFFFFFFF;
      low[i] = 0x00000000;
   }

   _temp0 = (CPBitVarI*)[CPFactory bitVar:engine withLow:low andUp:up andLength:bitLength];
   _temp1 = (CPBitVarI*)[CPFactory bitVar:engine withLow:low andUp:up andLength:bitLength];
   _temp2 = (CPBitVarI*)[CPFactory bitVar:engine withLow:low andUp:up andLength:bitLength];

//   _temp0b = (CPBitVarI*)[CPFactory bitVar:engine withLow:low andUp:up andLength:bitLength];
//   _temp0c = (CPBitVarI*)[CPFactory bitVar:engine withLow:low andUp:up andLength:bitLength];

   return self;
}
-(NSString*) description
{
   NSMutableString* string = [NSMutableString stringWithString:[super description]];
   [string appendString:@" with \n "];
   [string appendString:[NSString stringWithFormat:@"%@ \n",_x]];
   [string appendString:[NSString stringWithFormat:@"+ %@ \n",_y]];
   [string appendString:[NSString stringWithFormat:@"= %@\n",_z]];
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
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_y bound] + ![_z bound] + ![_cin bound] + ![_cout bound];
}
-(void) post
{
   id<CPEngine> engine = [_x engine];
    
   [engine addInternal:[CPFactory bitXOR:_x bxor:_y equals:_temp0]];
   [engine addInternal:[CPFactory bitXOR:_temp0 bxor:_cin equals:_z]];
   
//   [engine addInternal:[CPFactory bitXOR:_cin bxor:_x equals:_temp0b]];
//   [engine addInternal:[CPFactory bitXOR:_temp0b bxor:_y equals:_z]];

//   [engine addInternal:[CPFactory bitXOR:_y bxor:_cin equals:_temp0c]];
//   [engine addInternal:[CPFactory bitXOR:_temp0c bxor:_x equals:_z]];

   [engine addInternal:[CPFactory bitAND:_x band:_y equals:_temp1]];
   [engine addInternal:[CPFactory bitAND:_cin band:_temp0 equals:_temp2]];
   [engine addInternal:[CPFactory bitOR:_temp1 bor:_temp2 equals:_cout]];
   [engine addInternal:[CPFactory bitShiftL:_cout by:1 equals:_cin]];
   
//   if([_x bitLength]<32){
//      NSLog(@"%@",self);
//      NSLog(@"");
//   }
}
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment
{
  return NULL;
}
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment withState:(ORUInt **)state
{
  return NULL;
}
-(CPBitAntecedents*) getAntecedents:(CPBitAssignment*) assignment
{
  return NULL;
}
@end


@implementation CPBitNegative
-(id) initCPBitNegative:(CPBitVarI*)x equals:(CPBitVarI*)y
{
   self = [super initCPBitCoreConstraint:[x engine]];
   _x = x;
   _y = y;
    _state = nil;
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
   
   return self;
}
-(NSString*) description
{
   NSMutableString* string = [NSMutableString stringWithString:[super description]];
   [string appendString:@" with \n"];
   [string appendString:[NSString stringWithFormat:@"%@, \n",_x]];
   [string appendString:[NSString stringWithFormat:@"%@, \n",_y]];
   [string appendString:[NSString stringWithFormat:@"with cin = %@, \n",_negXCin]];
   [string appendString:[NSString stringWithFormat:@"and cout = %@, \n",_negXCout]];

   return string;
}

- (void) dealloc
{
   [super dealloc];
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
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment
{
   return NULL;
}

-(void) propagate{}
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
    
   ORUInt wordLength = bitLength/BITSPERWORD + ((bitLength%BITSPERWORD ==0) ? 0 : 1);
   
   ORUInt*   up;
   ORUInt*   low;
   //ORUInt*   one;

   up = alloca(sizeof(ORUInt)*wordLength);
   low = alloca(sizeof(ORUInt)*wordLength);
//   one = alloca(sizeof(ORUInt)*wordLength);

   for (int i=0; i<wordLength; i++) {
      up[i] = 0xFFFFFFFF;
      low[i] = 0x00000000;
//      one[i] = 0x00000000;
   }
//   one[0] = 0x1;
//   _one = (CPBitVarI*)[CPFactory bitVar:engine withLow:one andUp:one andLength:bitLength];
//
   _cin = (CPBitVarI*)[CPFactory bitVar:engine withLow:low andUp:up andLength:bitLength];
   _cout = (CPBitVarI*)[CPFactory bitVar:engine withLow:low andUp:up andLength:bitLength];

//   _cin2 = (CPBitVarI*)[CPFactory bitVar:engine withLow:low andUp:up andLength:bitLength];
//   _cout2 = (CPBitVarI*)[CPFactory bitVar:engine withLow:low andUp:up andLength:bitLength];
//   _notY = (CPBitVarI*)[CPFactory bitVar:engine withLow:low andUp:up andLength:bitLength];
//   _temp = (CPBitVarI*)[CPFactory bitVar:engine withLow:low andUp:up andLength:bitLength];
//   _tempCin = (CPBitVarI*)[CPFactory bitVar:engine withLow:low andUp:up andLength:bitLength];
//   _tempCout = (CPBitVarI*)[CPFactory bitVar:engine withLow:low andUp:up andLength:bitLength];

//    _negY = (CPBitVarI*)[CPFactory bitVar:engine withLow:low andUp:up andLength:bitLength];
//    _negYCin = (CPBitVarI*)[CPFactory bitVar:engine withLow:low andUp:up andLength:bitLength];
//    _negYCout = (CPBitVarI*)[CPFactory bitVar:engine withLow:low andUp:up andLength:bitLength];

//   _negZ = (CPBitVarI*)[CPFactory bitVar:engine withLow:low andUp:up andLength:bitLength];
//   _negZCin = (CPBitVarI*)[CPFactory bitVar:engine withLow:low andUp:up andLength:bitLength];
//   _negZCout = (CPBitVarI*)[CPFactory bitVar:engine withLow:low andUp:up andLength:bitLength];

   return self;
}
-(NSString*) description
{
   NSMutableString* string = [NSMutableString stringWithString:[super description]];
   [string appendString:@" with "];
   [string appendString:[NSString stringWithFormat:@"%@, ",_x]];
   [string appendString:[NSString stringWithFormat:@"%@, ",_y]];
   [string appendString:[NSString stringWithFormat:@"and %@\n",_z]];
   [string appendString:[NSString stringWithFormat:@"using ~y %@\n",_notY]];
   [string appendString:[NSString stringWithFormat:@"and -y %@\n",_negY]];
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

//    [engine addInternal:[CPFactory bitNegative :_y equals:_negY]];
//    [engine addInternal:[CPFactory bitADD:_x
//                                     plus:_negY
//                              withCarryIn:_negYCin
//                                   equals:_z
//                             withCarryOut:_negYCout]];
//
//   [engine addInternal:[CPFactory bitNOT:_y equals:_notY]];
//   [engine addInternal:[CPFactory bitADD:_x
//                                    plus:_notY
//                             withCarryIn:_tempCin
//                                  equals:_temp
//                            withCarryOut:_tempCout]];
//   [engine addInternal:[CPFactory bitADD:_temp
//                                    plus:_one
//                             withCarryIn:_cin2
//                                  equals:_z
//                            withCarryOut:_cout2]];
////
////
//   [engine addInternal:[CPFactory bitNegative :_z equals:_negZ]];
//   [engine addInternal:[CPFactory bitADD:_x
//                                    plus:_negZ
//                             withCarryIn:_negZCin
//                                  equals:_y
//                            withCarryOut:_negZCout]];
}
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment
{
   return NULL;
}

-(void) propagate{}
@end

@implementation CPBitDivide

-(id) initCPBitDivide:(CPBitVarI*)x dividedby:(CPBitVarI*)y equals:(CPBitVarI*)q rem:(CPBitVarI*)r
{
   self = [super initCPBitCoreConstraint:[x engine]];
    //dividend
   _x = x;
    //divsor
   _y = y;
    //quotient
   _q = q;
    //remainder
   _r = r;
   
   ORUInt bitLength = [_x bitLength];
//   ORUInt wordLength = bitLength/32 + ((bitLength%32 ==0) ? 0 : 1);
   ORUInt productWordLength = (bitLength*2)/32 + (((bitLength*2)%32 ==0) ? 0 : 1);
   ORUInt* up = alloca(sizeof(ORUInt)*productWordLength);
   ORUInt* low = alloca(sizeof(ORUInt)*productWordLength);
    ORUInt* one = alloca(sizeof(ORUInt)*productWordLength);

   for (int i=0; i<productWordLength; i++) {
      up[i] = 0xFFFFFFFF;
      low[i] = 0x00000000;
       one[i]=0x00000000;
   }
    ORUInt zero = 0x0;
    one[0] = 0x1;
   
   id<CPEngine> engine = [_x engine];
    
    _falseVal = (CPBitVarI*)[CPFactory bitVar:engine withLow:&zero andUp:&zero andLength:1];
    _zeroBitVar = (CPBitVarI*)[CPFactory bitVar:engine withLow:&zero andUp:&zero andLength:bitLength];
    _oneBitVar = (CPBitVarI*)[CPFactory bitVar:engine withLow:one andUp:one andLength:bitLength];
   _product = (CPBitVarI*)[CPFactory bitVar:engine withLow:low andUp:up andLength:bitLength*2];
   _productLow = (CPBitVarI*)[CPFactory bitVar:engine withLow:low andUp:up andLength:bitLength];
//   _productHigh = (CPBitVarI*)[CPFactory bitVar:engine withLow:low andUp:low andLength:bitLength];
   _cin = (CPBitVarI*)[CPFactory bitVar:engine withLow:low andUp:up andLength:bitLength];
   _cout = (CPBitVarI*)[CPFactory bitVar:engine withLow:low andUp:up andLength:bitLength];
   
   
    
//    _xlty = (CPBitVarI*)[CPFactory bitVar:engine withLow:&zero andUp:one andLength:1];
//    _yeq0 = (CPBitVarI*)[CPFactory bitVar:engine withLow:&zero andUp:one andLength:1];
//    _yneq0 = (CPBitVarI*)[CPFactory bitVar:engine withLow:&zero andUp:one andLength:1];
//    _qeq1 = (CPBitVarI*)[CPFactory bitVar:engine withLow:&zero andUp:one andLength:1];
//    _xeq0 = (CPBitVarI*)[CPFactory bitVar:engine withLow:&zero andUp:one andLength:1];
//    _xneq0 = (CPBitVarI*)[CPFactory bitVar:engine withLow:&zero andUp:one andLength:1];
//    _overflow = (CPBitVarI*)[CPFactory bitVar:engine withLow:low andUp:low andLength:1];
   _trueVal = (CPBitVarI*)[CPFactory bitVar:engine withLow:one andUp:one andLength:1];

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
    ORInt bitLength = [_x bitLength];
    
//    [engine addInternal:[CPFactory bitEqualb:_y equal:_zeroBitVar eval:_falseVal]];
//    [engine addInternal:[CPFactory bitEqualb:_y equal:_zeroBitVar eval:_yeq0]];
//    [engine addInternal:[CPFactory bitEqualb:_q equal:_oneBitVar eval:_qeq1]];
//    [engine addInternal:[CPFactory bitEqualb:_x equal:_zeroBitVar eval:_xeq0]];
//    [engine addInternal:[CPFactory bitNOT:_yeq0 equals:_yneq0]];
//    [engine addInternal:[CPFactory bitOR:_yneq0 bor:_qeq1 equals:_trueVal]];

   [engine addInternal:[CPFactory bitSignExtend:_productLow extendTo:_product]];
   [engine addInternal:[CPFactory bitExtract:_product from:0 to:bitLength-1 eq:_productLow]];
   [engine addInternal:[CPFactory bitMultiply:_y times:_q equals:_product]];
   
//   [engine addInternal:[CPFactory bitEqual:_productHigh to:_zeroBitVar]];
//   [engine addInternal:[CPFactory bitExtract:_product from:bitLength to:(bitLength*2)-1 eq:_productHigh]];
//    [engine addInternal:[CPFactory bitMultiply:_q times:_y equals:_product]];
   
   //if x<y then q=0
//    [engine addInternal:[CPFactory bitLT:_x LT:_y eval:_xlty]];
//    [engine addInternal:[CPFactory bitEqualb:_q equal:_zeroBitVar eval:_xlty]];
//    [engine addInternal:[CPFactory bitEqualb:_r equal:_x eval:_xlty]];

   [engine addInternal:[CPFactory bitLT:_r LT:_y eval:_trueVal]];

   [engine addInternal:[CPFactory bitADD:_productLow
                                    plus:_r
                             withCarryIn:_cin
                                  equals:_x
                             withCarryOut:_cout]];
    
}
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment
{
   return nil;
}

-(void) propagate{}
@end

@implementation CPBitDivideSigned

-(id) initCPBitDivideSigned:(CPBitVarI*)x dividedby:(CPBitVarI*)y equals:(CPBitVarI*)q rem:(CPBitVarI*)r
{
    self = [super initCPBitCoreConstraint:[x engine]];
    //dividend
    _x = x;
    //divsor
    _y = y;
    //quotient
    _q = q;
    //remainder
    _r = r;
    
    ORUInt bitLength = [_x bitLength];
    ORUInt wordLength = bitLength/32 + ((bitLength%32 ==0) ? 0 : 1);
    
    ORUInt* up = alloca(sizeof(ORUInt)*wordLength);
    ORUInt* low = alloca(sizeof(ORUInt)*wordLength);
    
    for (int i=0; i<wordLength; i++) {
        up[i] = 0xFFFFFFFF;
        low[i] = 0x00000000;
    }
        ORUInt zero = 0x0;
        ORUInt one = 0x1;
    
    id<CPEngine> engine = [_x engine];
    
//    _falseVal = (CPBitVarI*)[CPFactory bitVar:engine withLow:&zero andUp:&zero andLength:1];
    _trueVal = (CPBitVarI*)[CPFactory bitVar:engine withLow:&one andUp:&one andLength:1];

    _xSign = (CPBitVarI*)[CPFactory bitVar:engine withLow:&zero andUp:&one andLength:1];
    _ySign = (CPBitVarI*)[CPFactory bitVar:engine withLow:&zero andUp:&one andLength:1];
    _qSign = (CPBitVarI*)[CPFactory bitVar:engine withLow:&zero andUp:&one andLength:1];
    _rSign = (CPBitVarI*)[CPFactory bitVar:engine withLow:&zero andUp:&one andLength:1];
   
   _diffSign = (CPBitVarI*)[CPFactory bitVar:engine withLow:&zero andUp:&one andLength:1];
//    _sameSign = (CPBitVarI*)[CPFactory bitVar:engine withLow:&zero andUp:&one andLength:1];
//    _xlty = (CPBitVarI*)[CPFactory bitVar:engine withLow:&zero andUp:&one andLength:1];
//    _qIsPos = (CPBitVarI*)[CPFactory bitVar:engine withLow:&zero andUp:&one andLength:1];

    _x2Comp =(CPBitVarI*)[CPFactory bitVar:engine withLow:low andUp:up andLength:bitLength];
    _y2Comp =(CPBitVarI*)[CPFactory bitVar:engine withLow:low andUp:up andLength:bitLength];
//    _q2Comp =(CPBitVarI*)[CPFactory bitVar:engine withLow:low andUp:up andLength:bitLength];
//    _r2Comp =(CPBitVarI*)[CPFactory bitVar:engine withLow:low andUp:up andLength:bitLength];

//    _zeroBitVar = (CPBitVarI*)[CPFactory bitVar:engine withLow:low andUp:low andLength:bitLength];
   
    _posX = (CPBitVarI*)[CPFactory bitVar:engine withLow:low andUp:up andLength:bitLength];
    _posY = (CPBitVarI*)[CPFactory bitVar:engine withLow:low andUp:up andLength:bitLength];

    _posQ = (CPBitVarI*)[CPFactory bitVar:engine withLow:low andUp:up andLength:bitLength];
    _posR = (CPBitVarI*)[CPFactory bitVar:engine withLow:low andUp:up andLength:bitLength];
    _negQ = (CPBitVarI*)[CPFactory bitVar:engine withLow:low andUp:up andLength:bitLength];
    _negR = (CPBitVarI*)[CPFactory bitVar:engine withLow:low andUp:up andLength:bitLength];

   _xIsZero = (CPBitVarI*)[CPFactory bitVar:engine withLow:&zero andUp:&one andLength:1];
   _xNonZero = (CPBitVarI*)[CPFactory bitVar:engine withLow:&zero andUp:&one andLength:1];
   _rIsZero = (CPBitVarI*)[CPFactory bitVar:engine withLow:&zero andUp:&one andLength:1];
   _rNonZero = (CPBitVarI*)[CPFactory bitVar:engine withLow:&zero andUp:&one andLength:1];

   _zeroBitVar = (CPBitVarI*)[CPFactory bitVar:engine withLow:low andUp:low andLength:bitLength];
   
//    _product = (CPBitVarI*)[CPFactory bitVar:engine withLow:low andUp:up andLength:bitLength];
//    _r = (CPBitVarI*)[CPFactory bitVar:engine withLow:low andUp:up andLength:bitLength];
//    _cin = (CPBitVarI*)[CPFactory bitVar:engine withLow:low andUp:up andLength:bitLength];
//    _cout = (CPBitVarI*)[CPFactory bitVar:engine withLow:low andUp:up andLength:bitLength];
    return self;
}
-(NSString*) description
{
    NSMutableString* string = [NSMutableString stringWithString:[super description]];
    [string appendString:@" with "];
    [string appendString:[NSString stringWithFormat:@"x=%@, ",_x]];
   [string appendString:[NSString stringWithFormat:@"2comp(x)=%@, ",_x2Comp]];

    [string appendString:[NSString stringWithFormat:@"y=%@, ",_y]];
   [string appendString:[NSString stringWithFormat:@"2comp(y)=%@, ",_y2Comp]];
    [string appendString:[NSString stringWithFormat:@"q=%@, ",_q]];
   [string appendString:[NSString stringWithFormat:@"+q=%@, ",_posQ]];
   [string appendString:[NSString stringWithFormat:@"-q=%@, ",_negQ]];

    [string appendString:[NSString stringWithFormat:@"and r=%@\n",_r]];
   [string appendString:[NSString stringWithFormat:@"+r=%@, ",_posR]];
   [string appendString:[NSString stringWithFormat:@"-r=%@, ",_negR]];

    return string;
}

- (void) dealloc
{
    [super dealloc];
}

-(void) post
{
    id<CPEngine> engine = [_x engine];
    
    ORUInt bitLength = [_x bitLength];
   
//   [engine addInternal:[CPFactory bitEqualb:_y equal:_zeroBitVar eval:_falseVal]];

    [engine addInternal:[CPFactory bitNegative:_x equals:_x2Comp]];
    [engine addInternal:[CPFactory bitNegative:_y equals:_y2Comp]];

    [engine addInternal:[CPFactory bitNegative:_posQ equals:_negQ]];
    [engine addInternal:[CPFactory bitNegative:_posR equals:_negR]];

//   [engine addInternal:[CPFactory bitNegative:_negQ equals:_posQ]];
//   [engine addInternal:[CPFactory bitNegative:_negR equals:_posR]];

    [engine addInternal:[CPFactory bitExtract:_x from:(bitLength-1) to:(bitLength-1) eq:_xSign]];
    [engine addInternal:[CPFactory bitExtract:_y from:(bitLength-1) to:(bitLength-1) eq:_ySign]];
    [engine addInternal:[CPFactory bitExtract:_q from:(bitLength-1) to:(bitLength-1) eq:_qSign]];
    [engine addInternal:[CPFactory bitExtract:_r from:(bitLength-1) to:(bitLength-1) eq:_rSign]];

//   [engine addInternal:[CPFactory bitExtract:_negQ from:(bitLength-1) to:(bitLength-1) eq:_trueVal]];
//   [engine addInternal:[CPFactory bitExtract:_negR from:(bitLength-1) to:(bitLength-1) eq:_trueVal]];

    [engine addInternal:[CPFactory bitITE:_xSign then:_x2Comp else:_x result:_posX]];
    [engine addInternal:[CPFactory bitITE:_ySign then:_y2Comp else:_y result:_posY]];
    [engine addInternal:[CPFactory bitITE:_qSign then:_negQ else:_posQ result:_q]];
    [engine addInternal:[CPFactory bitITE:_rSign then:_negR else:_posR result:_r]];

    [engine addInternal:[CPFactory bitXOR:_xSign bxor:_ySign equals:_diffSign]];
    //dividend and remainder have the same sign
   [engine addInternal:[CPFactory bitEqualb:_r equal:_zeroBitVar eval:_rIsZero]];
   [engine addInternal:[CPFactory bitNOT:_rIsZero equals:_rNonZero]];
   [engine addInternal:[CPFactory bitAND:_xSign band:_rNonZero equals:_rSign]];
//   [engine addInternal:[CPFactory bitEqual:_xSign to:_rSign]];
   
//   [engine addInternal:[CPFactory bitITE:_rSign then:_negR else:_posR result:_r]];

    //quotient is negative if signs disagree (and dividend is not zero)
   [engine addInternal:[CPFactory bitEqualb:_x equal:_zeroBitVar eval:_xIsZero]];
   [engine addInternal:[CPFactory bitNOT:_xIsZero equals:_xNonZero]];
   [engine addInternal:[CPFactory bitAND:_diffSign band:_xNonZero equals:_qSign]];
//   [engine addInternal:[CPFactory bitITE:_qSign then:_negQ else:_posQ result:_q]];

//   [engine addInternal:[CPFactory bitITE:_xIsZero then:_zeroBitVar else:_q result:_q]];
//   [engine addInternal:[CPFactory bitITE:_xIsZero then:_zeroBitVar else:_r result:_r]];

    [engine addInternal:[CPFactory bitDivide:_posX dividedby:_posY equals:_posQ rem:_posR]];
    
}
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment
{
   return nil;
}

-(void) propagate{}
@end

@implementation CPBitDivideComposed{
   
@private
   CPBitVarI** _AQ;
   CPBitVarI** _shifted;
   CPBitVarI** _shiftQ;
   CPBitVarI** _shiftA;
   CPBitVarI** _newQ;
   CPBitVarI** _Qp1;
   CPBitVarI** _cin;
   CPBitVarI** _cout;
   CPBitVarI** _Q;
   CPBitVarI* _M;
   CPBitVarI* _negM;
   CPBitVarI** _A;
   CPBitVarI** _ASign;
   CPBitVarI** _ApM;
   CPBitVarI** _ACin;
   CPBitVarI** _ACout;
   CPBitVarI** _AmM;
   
   CPBitVarI* _zero;
   CPBitVarI* _one;
   CPBitVarI* _true;

   CPBitVarI* _dividend;
   CPBitVarI* _divisor;
   CPBitVarI* _quotient;
   CPBitVarI* _remainder;

}


-(id) initCPBitDivideComposed:(CPBitVarI*)dividend dividedBy:(CPBitVarI*)divisor equals:(CPBitVarI*)quotient withRemainder:(CPBitVarI*)remainder
{
   self = [super initCPBitCoreConstraint:[dividend engine]];

   _dividend = dividend;
   _divisor = divisor;
   _quotient = quotient;
   _remainder = remainder;

   id<CPEngine> engine = [_dividend engine];

   ORUInt bitLength = [dividend bitLength];
   ORUInt registerLength = bitLength << 1;
   ORUInt wordLength = registerLength/BITSPERWORD + ((registerLength%BITSPERWORD ==0) ? 0 : 1);

   ORUInt*   up;
   ORUInt*   low;
   ORUInt*   one;
   
   up = alloca(sizeof(ORUInt)*wordLength);
   low = alloca(sizeof(ORUInt)*wordLength);
   one = alloca(sizeof(ORUInt)*wordLength);
   //    max = alloca(sizeof(ORUInt)*wordLength);
   
   //   cout = alloca(sizeof(ORUInt)*wordLength);
   
   for (int i=0; i<wordLength; i++) {
      up[i] = 0xFFFFFFFF;
      low[i] = 0x00000000;
      one[i] = 0x00000000;
   }
   one[0] = 0x00000001;
   
   _M = _divisor;
   _negM = (CPBitVarI*)[CPFactory bitVar:engine withLow:low andUp:up andLength:bitLength];
   _zero = (CPBitVarI*)[CPFactory bitVar:engine withLow:low andUp:low andLength:bitLength];
   _one = (CPBitVarI*)[CPFactory bitVar:engine withLow:one andUp:one andLength:bitLength];
   _true = (CPBitVarI*)[CPFactory bitVar:engine withLow:one andUp:one andLength:1];

   _AQ = malloc(sizeof(CPBitVarI*)*(bitLength+2));
   _shifted = malloc(sizeof(CPBitVarI*)*(bitLength+2));
   _shiftQ = malloc(sizeof(CPBitVarI*)*(bitLength+2));
   _shiftA = malloc(sizeof(CPBitVarI*)*(bitLength+2));
   _newQ = malloc(sizeof(CPBitVarI*)*(bitLength+2));
   _Qp1 = malloc(sizeof(CPBitVarI*)*(bitLength+2));
   _cin = malloc(sizeof(CPBitVarI*)*(bitLength+2));
   _cout = malloc(sizeof(CPBitVarI*)*(bitLength+2));
   _Q = malloc(sizeof(CPBitVarI*)*(bitLength+2));
   _A = malloc(sizeof(CPBitVarI*)*(bitLength+2));
   _ASign = malloc(sizeof(CPBitVarI*)*(bitLength+2));
   _ApM = malloc(sizeof(CPBitVarI*)*(bitLength+2));
   _ACin = malloc(sizeof(CPBitVarI*)*(bitLength+2));
   _ACout = malloc(sizeof(CPBitVarI*)*(bitLength+2));
   _AmM = malloc(sizeof(CPBitVarI*)*(bitLength+2));

   
   for (int i=0; i<=bitLength+1; i++) {
      _AQ[i] = (CPBitVarI*)[CPFactory bitVar:engine withLow:low andUp:up andLength:registerLength];
      _shifted[i] = (CPBitVarI*)[CPFactory bitVar:engine withLow:low andUp:up andLength:registerLength];
      _shiftQ[i] = (CPBitVarI*)[CPFactory bitVar:engine withLow:low andUp:up andLength:bitLength];
      _shiftA[i] = (CPBitVarI*)[CPFactory bitVar:engine withLow:low andUp:up andLength:bitLength];
      _newQ[i] = (CPBitVarI*)[CPFactory bitVar:engine withLow:low andUp:up andLength:bitLength];
      _Qp1[i] = (CPBitVarI*)[CPFactory bitVar:engine withLow:low andUp:up andLength:bitLength];
      _cin[i] = (CPBitVarI*)[CPFactory bitVar:engine withLow:low andUp:up andLength:bitLength];
      _cout[i] = (CPBitVarI*)[CPFactory bitVar:engine withLow:low andUp:up andLength:bitLength];
      _Q[i] = (CPBitVarI*)[CPFactory bitVar:engine withLow:low andUp:up andLength:bitLength];
      _A[i] = (CPBitVarI*)[CPFactory bitVar:engine withLow:low andUp:up andLength:bitLength];
      _ASign[i] = (CPBitVarI*)[CPFactory bitVar:engine withLow:low andUp:one andLength:1];
      _ApM[i] = (CPBitVarI*)[CPFactory bitVar:engine withLow:low andUp:up andLength:bitLength];
      _ACin[i] = (CPBitVarI*)[CPFactory bitVar:engine withLow:low andUp:up andLength:bitLength];
      _ACout[i] = (CPBitVarI*)[CPFactory bitVar:engine withLow:low andUp:up andLength:bitLength];
      _AmM[i] = (CPBitVarI*)[CPFactory bitVar:engine withLow:low andUp:up andLength:bitLength];
   }
   return self;
}
-(NSString*) description
{
   NSMutableString* string = [NSMutableString stringWithString:[super description]];
   [string appendString:@" with \n"];
   [string appendString:[NSString stringWithFormat:@"  %@\n",_dividend]];
   [string appendString:[NSString stringWithFormat:@"/ %@\n",_divisor]];
   [string appendString:[NSString stringWithFormat:@"--------------------------------\n"]];
//   for(int i=0;i<[_opx bitLength]-1;i++){
//      [string appendString:[NSString stringWithFormat:@"  %@\n",_cin[i]]];
//      [string appendString:[NSString stringWithFormat:@"  %@\n",_cout[i]]];
//      [string appendString:[NSString stringWithFormat:@"+ %@\n",_partialProduct[i]]];
//      [string appendString:[NSString stringWithFormat:@"  %@\n",_intermediate[i]]];
//   }
//   [string appendString:[NSString stringWithFormat:@"--------------------------------\n"]];
   [string appendString:[NSString stringWithFormat:@"  %@\n",_quotient]];
   [string appendString:[NSString stringWithFormat:@"  %@\n",_remainder]];

   return string;
}

- (void) dealloc
{
   [super dealloc];
}

-(void) post
{
   id<CPEngine> engine = [_dividend engine];
   ORUInt bitLength = [_dividend bitLength];
   
   [engine addInternal:[CPFactory bitLT:_remainder LT:_divisor eval:_true]];
   //Non-Restoring Division
   //Preconditions:
   //Q=Dividend
   //M=Divisor
   //A=0
   [engine addInternal:[CPFactory bitEqual:_Q[0] to:_dividend]];
   [engine addInternal:[CPFactory bitEqual:_M to:_divisor]];
   [engine addInternal:[CPFactory bitNegative:_M equals:_negM]];
   [engine addInternal:[CPFactory bitEqual:_A[0] to:_zero]];

   [engine addInternal:[CPFactory bitExtract:_AQ[0] from:0 to:bitLength-1 eq:_Q[0]]];
   [engine addInternal:[CPFactory bitExtract:_AQ[0] from:bitLength to:(bitLength<<1)-1 eq:_A[0]]];
   [engine addInternal:[CPFactory bitConcat:_A[0] concat:_Q[0] eq:_AQ[0]]];
   
   //Shift Left register AQ
   [engine addInternal:[CPFactory bitShiftL:_AQ[0] by:1 equals:_shifted[0]]];
   [engine addInternal:[CPFactory bitExtract:_A[0] from:bitLength-1 to:bitLength-1 eq:_ASign[0]]];
//   [engine addInternal:[CPFactory bitADD:_shiftA[0] plus:_M withCarryIn:_ACin[i] equals:_ApM[i] withCarryOut:_ACout[i]]];
//   [engine addInternal:[CPFactory bitSubtract:_shiftA[i] minus:_M equals:_AmM[i]]];
   for (int i=1; i<=bitLength; i++) {
      [engine addInternal:[CPFactory bitExtract:_shifted[i-1] from:0 to:bitLength-1 eq:_shiftQ[i]]];
      [engine addInternal:[CPFactory bitExtract:_shifted[i-1] from:bitLength to:(bitLength<<1)-1 eq:_shiftA[i]]];
      [engine addInternal:[CPFactory bitADD:_shiftA[i] plus:_M withCarryIn:_ACin[i] equals:_ApM[i] withCarryOut:_ACout[i]]];
      [engine addInternal:[CPFactory bitSubtract:_shiftA[i] minus:_M equals:_AmM[i]]];
      
      [engine addInternal:[CPFactory bitShiftL:_AQ[i] by:1 equals:_shifted[i]]];
      [engine addInternal:[CPFactory bitExtract:_AQ[i] from:0 to:bitLength-1 eq:_Q[i]]];
      [engine addInternal:[CPFactory bitExtract:_AQ[i] from:bitLength to:(bitLength<<1)-1 eq:_A[i]]];
      [engine addInternal:[CPFactory bitConcat:_A[i] concat:_Q[i] eq:_AQ[i]]];

      //If A is negative
      //AQ<<1,A=A+M
      //Else
      //AQ<<1,A=A-M
      [engine addInternal:[CPFactory bitITE:_ASign[i-1] then:_ApM[i] else:_AmM[i] result:_A[i]]];

      
//            [engine addInternal:[CPFactory bitADD:_shiftQ[i] plus:_one withCarryIn:_cin[i] equals:_Qp1[i] withCarryOut:_cout[i]]];
      //If sign bit is 1 Q[0] become 0 otherwise Q[0] become 1 (Q[0] means least significant bit of register Q)
      [engine addInternal:[CPFactory bitOR:_shiftQ[i] bor:_one equals:_Qp1[i]]];
      [engine addInternal:[CPFactory bitExtract:_A[i] from:bitLength-1 to:bitLength-1 eq:_ASign[i]]];
      [engine addInternal:[CPFactory bitITE:_ASign[i] then:_shiftQ[i] else:_Qp1[i] result:_Q[i]]];
//      [engine addInternal:[CPFactory bitExtract:_shifted[i] from:0 to:bitLength-1 eq:_shiftQ[i]]];
//      [engine addInternal:[CPFactory bitADD:_shiftQ[i] plus:_one withCarryIn:_cin[i] equals:_Qp1[i] withCarryOut:_cout[i]]];
   }
   [engine addInternal:[CPFactory bitADD:_A[bitLength] plus:_M withCarryIn:_ACin[bitLength+1] equals:_ApM[bitLength+1] withCarryOut:_ACout[bitLength+1]]];
   [engine addInternal:[CPFactory bitITE:_ASign[bitLength] then:_ApM[bitLength+1] else:_A[bitLength] result:_remainder]];
//   [engine addInternal:[CPFactory bitExtract:_AQ[bitLength] from:0 to:bitLength-1 eq:_quotient]];
   [engine addInternal:[CPFactory bitEqual:_Q[bitLength] to:_quotient]];
}
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment
{
   return NULL;
}

-(void) propagate{}
@end





@implementation CPBitMultiplyComposed{
    
@private
   CPBitVarI* _opx;
   CPBitVarI* _opy;
    CPBitVarI* _opz;
   CPBitVarI* _x;
   CPBitVarI* _y;
   CPBitVarI* _z;
   CPBitVarI** _cin;
   CPBitVarI** _cout;
   CPBitVarI** _shifted;
   CPBitVarI** _partialProduct;
   CPBitVarI** _intermediate;
//   ORUInt**    _state;
    CPBitVarI** _bit;
//    CPBitVarI** _overflow;
   CPBitVarI* _zero;
    CPBitVarI* _falseVar;
    CPBitVarI* _trueVar;
    CPBitVarI* _upperWord;
   ORUInt   _opLength;
    ORUInt   _bitLength;
}


-(id) initCPBitMultiplyComposed:(CPBitVarI*)x times:(CPBitVarI*)y equals:(CPBitVarI*)z
{
   self = [super initCPBitCoreConstraint:[x engine]];
   _opx = x;
   _opy = y;
//   _opz = z;
   _z=z;
   id<CPEngine> engine = [_opx engine];
   
   _opLength = [_opx bitLength];
   
   
   _bitLength = _opLength << 1;
//    ORUInt intMax = 0x1 << _opLength;
   ORUInt wordLength = _bitLength/BITSPERWORD + ((_bitLength%BITSPERWORD ==0) ? 0 : 1);
   
   ORUInt*   up;
   ORUInt*   low;
//   ORUInt*  cinUp;
   ORUInt*   one;
//    ORUInt* max;
   
//   ORUInt* cout;
   
   up = alloca(sizeof(ORUInt)*wordLength);
   low = alloca(sizeof(ORUInt)*wordLength);
   one = alloca(sizeof(ORUInt)*wordLength);
//    max = alloca(sizeof(ORUInt)*wordLength);
   
//   cout = alloca(sizeof(ORUInt)*wordLength);

   for (int i=0; i<wordLength; i++) {
       up[i] = 0xFFFFFFFF;
      low[i] = 0x00000000;
      one[i] = 0x00000000;
//       max[i] = 0x0;
//      cout[i] = 0xFFFFFFFF;
   }
   one[0] = 0x00000001;
//    max[wordLength - _opLength/BITSPERWORD-1] = 0x1 << _opLength%BITSPERWORD;
//   cout[0] >>= 1;
   
   _x = (CPBitVarI*)[CPFactory bitVar:engine withLow:low andUp:up andLength:_bitLength];
   _y = (CPBitVarI*)[CPFactory bitVar:engine withLow:low andUp:up andLength:_bitLength];
//   _z = (CPBitVarI*)[CPFactory bitVar:engine withLow:low andUp:up andLength:_bitLength];

   _zero =(CPBitVarI*)[CPFactory bitVar:engine withLow:low andUp:low andLength:_bitLength];
   _falseVar = (CPBitVarI*)[CPFactory bitVar:engine withLow:low andUp:low andLength:1];
   _trueVar = (CPBitVarI*)[CPFactory bitVar:engine withLow:one andUp:one andLength:1];

   _bit = malloc(sizeof(CPBitVarI*)*_bitLength);
//    _overflow = malloc(sizeof(CPBitVarI*)*_opLength);
   _shifted = malloc(sizeof(CPBitVarI*)*_bitLength);
   _cin = malloc(sizeof(CPBitVarI*)*_bitLength);
   _cout = malloc(sizeof(CPBitVarI*)*_bitLength);
   _intermediate = malloc(sizeof(CPBitVarI*)*_bitLength);
   _partialProduct = malloc(sizeof(CPBitVarI*)*_bitLength);
   
   
   _bit[0] = (CPBitVarI*)[CPFactory bitVar:engine withLow:low andUp:one andLength:1];
   _intermediate[0] = (CPBitVarI*)[CPFactory bitVar:engine withLow:low andUp:up andLength:_bitLength];
   for (int i=1; i<_bitLength-1; i++) {
      _bit[i] = (CPBitVarI*)[CPFactory bitVar:engine withLow:low andUp:one andLength:1];
//      _overflow[i] = (CPBitVarI*)[CPFactory bitVar:engine withLow:low andUp:low andLength:1];
      _cin[i] = (CPBitVarI*)[CPFactory bitVar:engine withLow:low andUp:up andLength:_bitLength];
      _cout[i] = (CPBitVarI*)[CPFactory bitVar:engine withLow:low andUp:up andLength:_bitLength];
      _partialProduct[i] = (CPBitVarI*)[CPFactory bitVar:engine withLow:low andUp:up andLength:_bitLength];
      _intermediate[i] = (CPBitVarI*)[CPFactory bitVar:engine withLow:low andUp:up andLength:_bitLength];
      _shifted[i] = (CPBitVarI*)[CPFactory bitVar:engine withLow:low andUp:up andLength:_bitLength];
   }
   //no need for intermediate variable as last element in the array
   _bit[_bitLength-1] = (CPBitVarI*)[CPFactory bitVar:engine withLow:low andUp:one andLength:1];
//    _overflow[_opLength-1] = (CPBitVarI*)[CPFactory bitVar:engine withLow:low andUp:low andLength:1];
   _cin[_bitLength-1] = (CPBitVarI*)[CPFactory bitVar:engine withLow:low andUp:up andLength:_bitLength];
   _partialProduct[_bitLength-1] = (CPBitVarI*)[CPFactory bitVar:engine withLow:low andUp:up andLength:_bitLength];
   _shifted[_bitLength-1] = (CPBitVarI*)[CPFactory bitVar:engine withLow:low andUp:up andLength:_bitLength];
//   up[wordLength-1] >>= 1;
   _cout[_bitLength-1] = (CPBitVarI*)[CPFactory bitVar:engine withLow:low andUp:up andLength:_bitLength];
   return self;
}
-(NSString*) description
{
   NSMutableString* string = [NSMutableString stringWithString:[super description]];
   [string appendString:@" with \n"];
   [string appendString:[NSString stringWithFormat:@"  %@\n",_opx]];
   [string appendString:[NSString stringWithFormat:@"x %@\n",_opy]];
    [string appendString:[NSString stringWithFormat:@"--------------------------------\n"]];
   for(int i=0;i<[_opx bitLength]-1;i++){
      [string appendString:[NSString stringWithFormat:@"  %@\n",_cin[i]]];
      [string appendString:[NSString stringWithFormat:@"  %@\n",_cout[i]]];
      [string appendString:[NSString stringWithFormat:@"+ %@\n",_partialProduct[i]]];
      [string appendString:[NSString stringWithFormat:@"  %@\n",_intermediate[i]]];
   }
    [string appendString:[NSString stringWithFormat:@"--------------------------------\n"]];
   [string appendString:[NSString stringWithFormat:@"  %@\n",_z]];
   
   return string;
}

- (void) dealloc
{
   [super dealloc];
}

-(void) post
{
   id<CPEngine> engine = [_opx engine];
    
    [engine addInternal:[CPFactory bitSignExtend:_opx extendTo:_x]];
    [engine addInternal:[CPFactory bitSignExtend:_opy extendTo:_y]];
//    [engine addInternal:[CPFactory bitSignExtend:_opz extendTo:_z]];
   
//    [engine addInternal:[CPFactory bitExtract:_z from:0 to:[_opz bitLength]-1 eq:_opz]];
//    [engine addInternal:[CPFactory bitLT:_z LT:_upperWord eval:_trueVar]];
   
   [engine addInternal:[CPFactory bitExtract:_opy from:0 to:0 eq:_bit[0]]];
   [engine addInternal:[CPFactory bitITE:_bit[0] then:_x else:_zero result:_intermediate[0]]];
    
   for (int i=1; i<_bitLength-1; i++) {
      [engine addInternal:[CPFactory bitShiftL:_x by:i equals:_shifted[i]]];
      [engine addInternal:[CPFactory bitExtract:_y from:i to:i eq:_bit[i]]];
      [engine addInternal:[CPFactory bitITE:_bit[i] then:_shifted[i] else:_zero result:_partialProduct[i]]];
      [engine addInternal:[CPFactory bitADD:_intermediate[i-1]
                                       plus:_partialProduct[i]
                                withCarryIn:_cin[i]
                                     equals:_intermediate[i]
                               withCarryOut:_cout[i]]];
   }
   [engine addInternal:[CPFactory bitShiftL:_x by:_bitLength-1 equals:_shifted[_bitLength-1]]];
   [engine addInternal:[CPFactory bitExtract:_y from:_bitLength-1 to:_bitLength-1 eq:_bit[_bitLength-1]]];
   [engine addInternal:[CPFactory bitITE:_bit[_bitLength-1] then:_shifted[_bitLength-1] else:_zero result:_partialProduct[_bitLength-1]]];
   [engine addInternal:[CPFactory bitADD: _intermediate[_bitLength-2]
                                    plus:(CPBitVarI*)_partialProduct[_bitLength-1]
                             withCarryIn:(CPBitVarI*)_cin[_bitLength-1]
                                  equals:(CPBitVarI*)_z
                            withCarryOut:(CPBitVarI*)_cout[_bitLength-1]]];

}
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment
{
    return NULL;
}

-(void) propagate{}
@end


@implementation CPBitDistinct

-(id) initCPBitDistinct:(CPBitVarI*)x distinctFrom:(CPBitVarI*)y eval:(CPBitVarI*) z
{
   self = [super initCPBitCoreConstraint:[x engine]];
   _x = x;
   _y = y;
   _z = z;
   
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
}

-(void) post
{
   id<CPEngine> engine = [_x engine];
   
   [engine addInternal:[CPFactory bitEqualb:_x equal:_y eval:_equal]];
   [engine addInternal:[CPFactory bitNotb: _equal eval:_z]];
}
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment
{
   return NULL;
}

-(void) propagate{}
@end
