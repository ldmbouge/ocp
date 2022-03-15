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
   CPBitVarI       *_var;
   ORUInt           _index;
   ORDouble         _tCount;
   ORDouble         _fCount;
}
-(id) initBitLiteral:(CPBitVarI*)v at:(ORUInt)i withTCount:(ORDouble)tc andFCount:(ORDouble)fc;
-(BOOL) isEqual:(BitLiteral*)object;
-(ORDouble) maxCount;
-(NSUInteger) hash;
-(NSString*)description;
@end

@implementation BitLiteral
-(id) initBitLiteral:(CPBitVarI*)v at:(ORUInt)i withTCount:(ORDouble)tc andFCount:(ORDouble)fc
{
   _var = v;
   _index = i;
   _tCount = tc;
   _fCount = fc;
   return self;
}
-(BOOL) isEqual:(BitLiteral*)object
{
   return ([_var getId] == [object->_var getId]) &&
            (_index == object->_index);
}
-(NSUInteger)hash {
   NSUInteger bvId = [_var getId];
   NSUInteger h = (bvId << 32) + _index;
   
   return h;
}

-(ORDouble) maxCount {
   return max(_tCount, _fCount);
}

-(NSString*)description
{
   NSUInteger bvId = [_var getId];
   NSUInteger h = (bvId << 32) + _index;
   
   NSMutableString* string = [NSMutableString stringWithString:@"Bit Literal with var: "];
   [string appendString:[NSString stringWithFormat:@"%@ ",_var]];
   [string appendString:[NSString stringWithFormat:@"[%d] ", _index]];
   [string appendString:[NSString stringWithFormat:@"with key:%ld t-count %.6f and f-count: %.6f", h, _tCount, _fCount]];
   
   return string;

}
@end

void heapSiftDown(BitLiteral** heap, ORUInt index, ORUInt size)
{
   ORUInt leftChild = (2*index)+1;
   ORUInt rightChild = (2*index)+2;
   
   ORBool leftBigger = (leftChild < size) && ([heap[leftChild] maxCount] > [heap[index] maxCount]);
   ORBool rightBigger = (rightChild < size) && ([heap[rightChild] maxCount] > [heap[index] maxCount]);
   
   BitLiteral* tempLiteral;
   
   if(leftBigger && (!rightBigger || [heap[leftChild] maxCount] >= [heap[rightChild] maxCount])){
      tempLiteral = heap[index];
      heap[index] = heap[leftChild];
      heap[leftChild] = tempLiteral;
      heapSiftDown(heap, leftChild, size);
   }
   else if(rightBigger && (!leftBigger || [heap[rightChild] maxCount] >= [heap[leftChild] maxCount])){
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
   if(index == 0 || [heap[parent] maxCount] > [heap[index] maxCount])
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
   ORUInt*          _map;
   ORULong          _nbv;
   NSSet* __strong*     _cv;
   ORDouble _reduction;
   
//   id<ORZeroOneStream>   _valStream;
}
-(CPBitVarVSIDS*)initCPBitVarVSIDS:(id<CPProgram>)cp restricted:(id<ORVarArray>)rvars
{
   self = [super init];
   _cp = cp;
   _engine  = [cp engine];
   _vars = nil;
   _rvars = rvars;
   _countMax = 256;
   _count = _countMax;
   _reduction = 2;
   
   //_valStream = [ORFactory zeroOneStream:_engine];
   
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
      a->var = _heap[0]->_var;
      a->index = _heap[0]->_index;
//      if(_heap[0]->_tCount == _heap[0]->_fCount)
//         a->value = [_valStream next];
//      else
         a->value = _heap[0]->_tCount > _heap[0]->_fCount;
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
   memset(_cv,0,sizeof(NSSet*)*len);
   memset(_map,0,sizeof(ORUInt)*(maxID+1));
   ORInt low = [t low],up = [t up];
   for(ORInt k=low;k <= up;k++) {
      _map[_cvs[k].getId] = k - low;
      _cv[k-low] = [[_cvs[k] constraints] retain];
   }
   _nbv = len;
   
   ORULong bvId;
   ORULong key;
   BitLiteral* lit;
//   CPBitAssignment* a;
   ORDouble count;
   ORDouble tBoost, fBoost;
   ORUInt freeBits;
   ORUInt i, bit,  mask;
   NSSet* constraints;
   
   NSEnumerator *iter = [[_engine variables] objectEnumerator];
   CPBitVarI* x;

   while((x = [iter nextObject]))
//   for(CPBitVarI* x in [_engine variables])
//   for(ORInt k=low;k <= up;k++)
   {
//      x=(CPBitVarI*)_cvs[k];
      if([x bound])
         continue;
      count=0.0;
      ULRep xr = getULVarRep(x);
      TRUInt *xLow = xr._low, *xUp = xr._up;
      
      constraints = [(CPBitVarI*)x constraints];
      
      for(ORInt k=0;k<[x getWordLength];k++){
         freeBits = xLow[k]._val ^ xUp[k]._val;
         bvId = [(CPBitVarI*)x getId];
         
         while(freeBits != 0){
            bit  =  BITSPERWORD - __builtin_clz(freeBits) - 1;
            i = (k * BITSPERWORD) + bit;

            tBoost = fBoost = 0.0;
            for(id obj in constraints) {
//               count += [obj nbUVars]-1;
               tBoost += [obj prefer:x at:i with:true];
               fBoost += [obj prefer:x at:i with:false];
            }

            key = (bvId << 32) + i;
            
//            ORUInt   d = [(CPBitVarI*)x domsize];
            ORDouble t = (count+tBoost);//log2(d);
            ORDouble f = (count+fBoost);//log2(d);

            lit = [[BitLiteral alloc] initBitLiteral:x at:i withTCount:t andFCount:f];
            [_countedBits setObject:lit forKey:[NSNumber numberWithUnsignedLong:key]];
            heapInsert(_heap, &_heapSize, &_heapCap, lit);

            mask = 0x1 << bit;
            freeBits &= ~mask;
         }
      }
      [constraints dealloc];
   }
   
   NSLog(@"Tracking %ld literal pairs at start",(unsigned long)[_countedBits count]);

   [[_engine callingContinuation] wheneverNotifiedDo:^{
      NSMutableSet *toRemove = [[NSMutableSet alloc] init];
      for(BitLiteral* lit in _assignedLiterals){
         if([lit->_var isFree:lit->_index]){
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
                        ((BitLiteral*)obj)->_tCount /= _reduction;
                        ((BitLiteral*)obj)->_fCount /= _reduction;
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
            NSUInteger key = (bvId << 32) + ants->antecedents[i]->index;
            
            BitLiteral* lit = (BitLiteral*)[_countedBits objectForKey:[NSNumber numberWithUnsignedLong:key]];
            
            if(lit){

               if (ants->antecedents[i]->value)
                  (lit->_tCount) += [constraint prefer:ants->antecedents[i]->var at:ants->antecedents[i]->index with:true];
               else
                  (lit->_fCount) += [constraint prefer:ants->antecedents[i]->var at:ants->antecedents[i]->index with:false];
               
            }
            //any unlocated literal counts should be for bits set before search started when branching on concrete variables,
            // must add if branching on model variables
            else if ((ORInt)[ants->antecedents[i]->var getLevelBitWasSet:ants->antecedents[i]->index]>4){
               NSSet* constraints = [ants->antecedents[i]->var constraints];

               ORDouble count = 0;

               ORDouble tc = 0.0;
               ORDouble fc = 0.0;

               for(id obj in constraints) {
                  count = [obj nbUVars]-1;
                  if(obj == constraint)
                     continue;
                  tc += count + [obj prefer:ants->antecedents[i]->var at:ants->antecedents[i]->index with:true];
                  fc += count + [obj prefer:ants->antecedents[i]->var at:ants->antecedents[i]->index with:false];
               }

//               ORUInt numReductions = [[ants->antecedents[i]->var engine] nbFailures] / _countMax;
//               ORDouble reduction = pow(_reduction, numReductions);
//               tc *= reduction;
//               fc *= reduction;
//               if (ants->antecedents[i]->value)
//                  fc += [constraint prefer:ants->antecedents[i]->var at:ants->antecedents[i]->index with:true];
//               else
//                  tc += [constraint prefer:ants->antecedents[i]->var at:ants->antecedents[i]->index with:false];

//               ORUInt domsize = log2([ants->antecedents[i]->var domsize]);
//               tc/=domsize;
//               fc/=domsize;
                lit = [[BitLiteral alloc] initBitLiteral:ants->antecedents[i]->var at:ants->antecedents[i]->index withTCount:tc andFCount:fc];

               if([lit->_var isFree:lit->_index])
                  heapInsert(_heap, &_heapSize, &_heapCap, lit);
               else
                  [_assignedLiterals addObject:lit];

               [_countedBits setObject:lit forKey:[NSNumber numberWithUnsignedLong:key]];
               [constraints dealloc];
            }
         }
      }
    }
   }];
   NSLog(@"VSIDS ready...");
}
@end
