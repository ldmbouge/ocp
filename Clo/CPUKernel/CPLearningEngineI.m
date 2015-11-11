/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <CPLearningEngineI.h>

@implementation CPLearningEngineI
-(CPLearningEngineI*) initEngine: (id<ORTrail>) trail memory:(id<ORMemoryTrail>)mt
{
   self = [super init];
   [super initEngine:trail memory:mt];
   _capacity = 8;
   _globalStore = malloc(sizeof(CPBVConflict*)*_capacity);
   _size = 0;
   _newConstraint = false;
   _lastConflict = nil;
   _backjumpLevel = -1;
   return self;
}


-(ORStatus) restoreLostConstraints:(ORUInt) level
{
   //re-insert lost constraints (at lower levels in search tree)
   //at the current level
   ORStatus s;
   ORStatus status = ORSuspend;
   
   for (int n = 0; n<_size; n++) {
      if ((_globalStore[n]->level > level) && (_globalStore[n]->vars->numAntecedents > 0)){
         CPBVConflict* test = _globalStore[n];
         CPBitConflict* c = [CPFactory bitConflict:_globalStore[n]->vars];
         s = [self add:c];
//         NSLog(@"Adding new global constraint %@ to constraint store",c);
         if (s == ORFailure)
            return ORFailure;
         [self propagate];
//         if (status == ORFailure) {
//            NSLog(@"failure in restoring constraint %d\n",n);
//            NSLog(@"--------------------Begin Global Constraint Store--------------------\n");
//            for(int i=0;i<_size;i++){
//               NSLog(@"******************************");
//               NSLog(@"_globalStore[%d]\n",i);
//               for(int j=0;j<_globalStore[i]->vars->numAntecedents;j++)
//                  NSLog(@"0x%lx[%d] = %d\n",_globalStore[i]->vars->antecedents[j]->var,_globalStore[i]->vars->antecedents[j]->index,_globalStore[i]->vars->antecedents[j]->value);
//            }
//            NSLog(@"--------------------End Global Constraint Store--------------------\n");
//         }
//         ORUInt l;
//         for(int j=0;j<_globalStore[n]->vars->numAntecedents;j++){
//            if (_backjumpLevel > (l=[(CPBitVarI*)_globalStore[n]->vars->antecedents[j]->var getLevelBitWasSet:_globalStore[n]->vars->antecedents[j]->index]) &&
//                (l!=0)) {
//               _backjumpLevel = l;
//            }
//         }
         _globalStore[n]->level = level;
         _newConstraint = true;
      }
   }
   _backjumpLevel = -1;
   return status;
}
-(void) addConstraint:(CPBitAntecedents*) a
{
   _lastConflict = a;
   if (a->numAntecedents <= 0)
   {
      free(a->antecedents);
      free(a);
      return;
   }
   
//   ORBool newConstraint = false;
//   ORBool inConstraintStore;
//   for(int n=0;n<_size;n++){
//      if (_globalStore[n]->vars->numAntecedents != a->numAntecedents) {
//         continue;
//      }
////      inConstraintStore = true;
//      for (int v=0; v<_globalStore[n]->vars->numAntecedents; v++) {
//         if ((_globalStore[n]->vars->antecedents[v]->var != a->antecedents[v]->var) ||
//             (_globalStore[n]->vars->antecedents[v]->index != a->antecedents[v]->index) ||
//             (_globalStore[n]->vars->antecedents[v]->value != a->antecedents[v]->value)) {
//            inConstraintStore = false;
//         }
//      }
//   }
   
   CPBVConflict* newConflict = malloc(sizeof(CPBVConflict));
   newConflict->vars = a;
   newConflict->level = _currLevel;
   
   if (_size >= _capacity) {
      _capacity <<= 1;
      CPBVConflict** newStore = malloc(sizeof(CPBVConflict*)*_capacity);
      for (int i = 0; i<_size; i++) {
         newStore[i] = _globalStore[i];
      }
      free(_globalStore);
      _globalStore = newStore;
   }
   ORUInt l;
   for (int i=0; i<a->numAntecedents; i++) {
      if (((l=[a->antecedents[i]->var getLevelBitWasSet:a->antecedents[i]->index]) < _backjumpLevel) && (l > 0)) {
         _backjumpLevel = l;
      }
   }
   _globalStore[_size++] = newConflict;
}
//-(void) addConstraint:(NSArray*) vars withConflicts:(ORUInt*)conflictBits withValues:(ORUInt**)bitValues
//{
////   NSLog(@"New conflict constraint found\n");
//   _lastConflict = [[bvConflict alloc] initBVConflict:vars withConflicts:conflictBits withValues:bitValues atLevel:_currLevel];
//   [_globalStore addObject:_lastConflict];
//   _newConstraint = true;
//   //don't add constraint to engine here, we're going to backjump anyhow
//}
-(void) setLevel:(ORUInt)level
{
   _currLevel = level;
}
-(void) setBaseLevel:(ORUInt)level
{
   _baseLevel = level;
}
-(ORUInt) getLevel
{
   return _currLevel;
}

-(ORUInt) getBackjumpLevel{
//   ORUInt lvl;
//   ORUInt wordLength =[[_vars objectAtIndex:0] getWordLength];
//   ORUInt* bitMask = [_lastConflict getConflictBits];
//   NSArray* vars = [_lastConflict getVars];
//   
//   if(!bitMask) return _baseLevel;
//      for (ORUInt i = 0; i<wordLength; i++) {
//         for (ORUInt j = 0; j<32; j++) {
//            for (int k = 0; k<[vars count]; k++) {
//               if (bitMask[i] & 0x1) {
//                  lvl = [(CPBitVarI*)vars[k] getLevelBitWasSet:(i*32)+j];
//                  if ((lvl < backJumpLevel) && (lvl >= _baseLevel)) {
//                     backJumpLevel = lvl;
//                  }
//                  //else backJumpLevel = _baseLevel; //Added 7/21/15
//               }
//            }
//            bitMask[i] >>= 1;
//         }
//      }
return _backjumpLevel;
}
-(ORBool) newConstraint{
   ORBool newOne = _newConstraint;
   _newConstraint = false;
   return newOne;
}
@end