/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORProgram/CPBitVarVSIDS.h>
#import <CPUKernel/CPEngine.h>
#import <objcp/CPBitVar.h>
#import <objcp/CPBitVarI.h>
struct _CPBitAntecedents;
typedef struct _CPBitAntecedents CPBitAntecedents;

struct _CPBitAssignment;
typedef struct _CPBitAssignment CPBitAssignment;

@interface BitLiteral : NSObject{
   @public
   CPBitAssignment    *_a;
   ORDouble         _count;
}
-(id) initBitLiteral:(CPBitAssignment*)a withCount:(ORDouble)c;
-(BOOL) isEqual:(BitLiteral*)object;
-(NSUInteger) hash;
-(NSString*)description;
@end

@implementation BitLiteral
-(id) initBitLiteral:(CPBitAssignment*)a withCount:(ORDouble)c
{
   _a = a;
   _count = c;
   return self;
}
-(BOOL) isEqual:(BitLiteral*)object
{
   return ([_a->var getId] == [object->_a->var getId]) &&
            (_a->index == object->_a->index) &&
            (_a->value == object->_a->value);
}
-(NSUInteger)hash {
   NSUInteger bvId = [_a->var getId];
   NSUInteger h = (bvId << 32) + (_a->index <<1) + (_a->value ? 1 : 0);
   
   return h;
}
-(NSString*)description
{
   NSUInteger bvId = [_a->var getId];
   NSUInteger h = (bvId << 32) + (_a->index <<1) + (_a->value ? 1 : 0);
   
   NSMutableString* string = [NSMutableString stringWithString:@"Bit Literal with var: "];
   [string appendString:[NSString stringWithFormat:@"%@ ",_a->var]];
   [string appendString:[NSString stringWithFormat:@"[%d] ", _a->index]];
   [string appendString:[NSString stringWithFormat:@"= %d,  ",_a->value]];
   [string appendString:[NSString stringWithFormat:@"with key:%ld and count: %.6f", h, _count]];
   
   return string;

}
@end

void heapSiftDown(BitLiteral** heap, ORUInt index, ORUInt size)
{
   ORUInt leftChild = (2*index)+1;
   ORUInt rightChild = (2*index)+2;
   
   ORBool leftBigger = (leftChild < size) && (heap[leftChild]->_count > heap[index]->_count);
   ORBool rightBigger = (rightChild < size) && (heap[rightChild]->_count > heap[index]->_count);
   
   BitLiteral* tempLiteral;
   
   if(leftBigger && (!rightBigger || heap[leftChild]->_count >= heap[rightChild]->_count)){
      tempLiteral = heap[index];
      heap[index] = heap[leftChild];
      heap[leftChild] = tempLiteral;
      heapSiftDown(heap, leftChild, size);
   }
   else if(rightBigger && (!leftBigger || heap[rightChild]->_count >= heap[leftChild]->_count)){
      tempLiteral = heap[index];
      heap[index] = heap[rightChild];
      heap[rightChild] = tempLiteral;
      heapSiftDown(heap, rightChild, size);
   }
   
}

void heapRemove(BitLiteral** heap, ORUInt* size){
   if (*size == 0)
      return;
   (*size)--;
   heap[0] = heap[*size];
   heapSiftDown(heap, 0, *size);
}
void heapSiftUp(BitLiteral** heap, ORUInt index){
   ORUInt parent = floor((index-1)/2);
   if(index == 0 || heap[parent]->_count > heap[index]->_count)
      return;
   BitLiteral* tempLiteral = heap[parent];
   heap[parent] = heap[index];
   heap[index] = tempLiteral;
   heapSiftUp(heap,parent);
}

BitLiteral** heapInsert(BitLiteral** heap, ORUInt* size, ORUInt* cap, BitLiteral* assign)
{
   BitLiteral** h=heap;
   if((*size)>= (*cap)){
      BitLiteral** newHeap= malloc(sizeof(BitLiteral*)*(*cap)*2);
      for(ORUInt i=0;i<(*size);i++){
         newHeap[i] = heap[i];
      }
      free(heap);
      h = newHeap;
      (*cap) <<=1;
   }
   h[*size] = assign;
   heapSiftUp(h, *size);
   (*size)++;
   return h;
}

@implementation CPBitVarVSIDS {
   id<CPEngine>    _engine;
   
   ORBool   _alternateHeuristic;
   
   //DDeg alternate heuristic
   ORUInt*          _map;
//   id<CPCommonProgram>     _cp;
   ORULong          _nbv;
   NSSet* __strong*     _cv;
}
-(CPBitVarVSIDS*)initCPBitVarVSIDS:(id<CPProgram>)cp restricted:(id<ORVarArray>)rvars
{
   self = [super init];
   _cp = cp;
   _engine  = [cp engine];
   _vars = nil;
   _rvars = rvars;
   _countMax = 16;
   _count = _countMax;
   _alternateHeuristic = false;
   
   _heapCap = 0x1 << 20;
   _heap = malloc(sizeof(BitLiteral*)*_heapCap);
   _heapSize = 0;
   
   _countedBits = [[NSMutableDictionary alloc] init];

   _assignedLiterals = [[NSMutableSet alloc] init];
   
   return self;
}
- (id)copyWithZone:(NSZone *)zone
{
   CPBitVarVSIDS * cp = [[CPBitVarVSIDS alloc] initCPBitVarVSIDS:_cp restricted:_rvars];
   return cp;
}
-(void)dealloc
{
   NSLog(@"Tracking %ld literals at finish",(unsigned long)[_countedBits count]);
   [_countedBits dealloc];
   free(_heap);
   //Dealloc DDeg state
   for(int k=0; k < _nbv;k++)
      [_cv[k] release];
   free(_cv);
   free(_map);
   
   [super dealloc];
}
-(id<CPProgram>)solver
{
   return _cp;
}
-(id<ORVarArray>)allBitVars
{
   return (id<ORVarArray>) (_rvars!=nil ? _rvars : _cvs);
}

-(CPBitAssignment*) getNextLiteral
{
   if(_heapSize == 0)
      return NULL;
   
   CPBitAssignment* a = malloc(sizeof(CPBitAssignment));
   do {
      a->var = _heap[0]->_a->var;
      a->index = _heap[0]->_a->index;
      a->value = _heap[0]->_a->value;
      
      [_assignedLiterals addObject:_heap[0]];
      
      heapRemove(_heap,&_heapSize);
      
   } while ((_heapSize>0) && (![a->var isFree:a->index]));
   
   if(![a->var isFree:a->index]){
      free(a);
      return NULL;
   }
   return a;
}

-(void)initInternal:(id<ORVarArray>)t and:(id<CPVarArray>)cv
{
   //init state for VSIDS heuristic
   _vars = t;
   _cvs  = cv;
   
   //init state for alternate heuristic (DDeg)
   ORUInt len = (ORUInt)[_vars count];
   ORUInt maxID = 0;
   for(int k=0;k<len;k++)
      maxID = max(maxID,[t at:k].getId);
   _cv = malloc(sizeof(NSSet*)*len);
   _map = malloc(sizeof(ORUInt)*(maxID+1));
   memset(_cv,sizeof(NSSet*)*len,0);
   memset(_map,sizeof(ORUInt)*(maxID+1),0);
   ORInt low = [t low],up = [t up];
   for(ORInt k=low;k <= up;k++) {
      _map[_cvs[k].getId] = k - low;
      _cv[k-low] = [[_cvs[k] constraints] retain];
   }
   _nbv = len;
   
   NSUInteger bvId;
   NSUInteger key;
   BitLiteral* lit;
   CPBitAssignment* a;
   ORDouble count;

//   NSEnumerator *iter = [[_engine variables] objectEnumerator];
   CPBitVarI* x;

//   while((x = [iter nextObject]))
//   for(CPBitVarI* x in [_engine variables])
   for(ORInt k=low;k <= up;k++)
   {
      x=(CPBitVarI*)_cvs[k];
      if([x bound])
         continue;
      count=0.0;

      NSSet* constraints = [(CPBitVarI*)x constraints];
      count = [constraints count];

      ORDouble tBoost, fBoost;
   
      for(ORInt i=[(CPBitVarI*)x bitLength]-1; i>=0;i--){
//      for(ORInt i=0; i<[(CPBitVarI*)x bitLength];i++){
         if([(CPBitVarI*)x isFree:i]){
            tBoost = fBoost = 0.0;
            for(id obj in constraints) {
               tBoost += [obj prefer:x at:i with:true];
               fBoost += [obj prefer:x at:i with:false];
            }

            bvId = [(CPBitVarI*)x getId];
            key = (bvId << 32) + (i << 1);

            a = malloc(sizeof(CPBitAssignment));
            a->var = x;
            a->index = i;
            a->value = true;
            lit = [[BitLiteral alloc] initBitLiteral:a withCount:(count+tBoost)/log2([(CPBitVarI*)x domsize])];
//            lit = [[BitLiteral alloc] initBitLiteral:a withCount:count+tBoost];
            [_countedBits setObject:lit forKey:[NSNumber numberWithUnsignedLong:key+1]];
            heapInsert(_heap, &_heapSize, &_heapCap, lit);

            a = malloc(sizeof(CPBitAssignment));
            a->var = x;
            a->index = i;
            a->value = false;
            lit = [[BitLiteral alloc] initBitLiteral:a withCount:(count+fBoost)/log2([(CPBitVarI*)x domsize])];
//            lit = [[BitLiteral alloc] initBitLiteral:a withCount:count+fBoost];
            [_countedBits setObject:lit forKey:[NSNumber numberWithUnsignedLong:key]];
            heapInsert(_heap, &_heapSize, &_heapCap, lit);
         }
      }
      [constraints dealloc];
   }
   
   NSLog(@"Tracking %ld literals at start",(unsigned long)[_countedBits count]);

   [[_engine callingContinuation] wheneverNotifiedDo:^{
//      _heapSize = 0;
//      [_countedBits enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
//         if([((BitLiteral*)obj)->_a->var isFree:((BitLiteral*)obj)->_a->index])
//            heapInsert(_heap, &_heapSize, &_heapCap, obj);
//      }];
      NSMutableSet *toRemove = [[NSMutableSet alloc] init];
      for(BitLiteral* lit in _assignedLiterals){
         if([lit->_a->var isFree:lit->_a->index]){
            heapInsert(_heap, &_heapSize, &_heapCap, lit);
            [toRemove addObject:lit];
         }
      }
      [_assignedLiterals minusSet:toRemove];
      [toRemove dealloc];
      assert([_assignedLiterals count]+_heapSize == [_countedBits count]);
   }];
   
   [[_engine propagateFail] wheneverNotifiedDo: ^{
      if(_count <=0)
      {
         //Reduce count for all currently counted literals
         [_countedBits enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            ((BitLiteral*)obj)->_count *= 0.5;
         }];
         _count = _countMax;
      }
      else
         _count--;
      
      //Add new literals
    if([_engine isKindOfClass:[CPLearningEngineI class]]){
      NSSet* newConstraints = [(CPLearningEngineI*)_engine getNewConstraints];
      for(CPBitConflict* constraint in newConstraints)
      {
         CPBitAntecedents* ants = [constraint getAssignments];
         for(ORUInt i=0;i<ants->numAntecedents;i++)
         {
            NSUInteger bvId = [ants->antecedents[i]->var getId];
            NSUInteger key = (bvId << 32) + (ants->antecedents[i]->index << 1) + (ants->antecedents[i]->value ? 0 : 1);
            
            BitLiteral* lit = (BitLiteral*)[_countedBits objectForKey:[NSNumber numberWithUnsignedLong:key]];
            
            if(lit){
               (lit->_count) += (1.0 + [constraint nbUVars])/log2([lit->_a->var domsize]);
//               (lit->_count) += 1.0 + [constraint prefer:lit->_a->var at:lit->_a->index with:lit->_a->value];
            }
            //any unlocated literal counts should be for bits set before search started when branching on concrete variables,
            // must add if branching on model variables
            else if ((ORInt)[ants->antecedents[i]->var getLevelBitWasSet:ants->antecedents[i]->index]>4){
               NSSet* constraints = [ants->antecedents[i]->var constraints];

               ORDouble count = 1.0;
               
               CPBitAssignment* a = malloc(sizeof(CPBitAssignment));
               a->var = ants->antecedents[i]->var;
               a->index = ants->antecedents[i]->index;
               a->value = !ants->antecedents[i]->value;

               count += [constraints count];
               for(id obj in constraints) {
                     count += [obj prefer:a->var at:a->index with:a->value];
               }
               count /= log2([a->var domsize]);
//               lit = [[BitLiteral alloc] initBitLiteral:ants->antecedents[i] withCount: count];
              lit = [[BitLiteral alloc] initBitLiteral:a withCount: count];
               [_assignedLiterals addObject:lit];
               [_countedBits setObject:lit forKey:[NSNumber numberWithUnsignedLong:key]];
//               [_countedBits setObject:lit forKey:[NSNumber numberWithUnsignedLong:key]];
               [constraints dealloc];
            }
         }
      }
    }
   }];
   NSLog(@"VSIDS ready...");
}
@end
