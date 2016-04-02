/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "CPLearningEngineI.h"

@implementation CPLearningEngineI
-(CPLearningEngineI*) initEngine: (id<ORTrail>) trail memory:(id<ORMemoryTrail>)mt tracer:(id<ORTracer>)tr
{
   self = [super init];
   [super initEngine:trail memory:mt];
   _tracer = tr;
   _capacity = 8;
   _globalStore = malloc(sizeof(CPBVConflict*)*_capacity);
   _size = 0;
   _backjumpLevel = -1;
   _retry = false;
   return self;
}


//-(ORStatus) restoreLostConstraints:(ORUInt) level
//{
//   //re-insert lost constraints (at lower levels in search tree)
//   //at the current level
//   ORStatus s;
//   ORStatus status = ORSuspend;
//   
//   for (int n = 0; n<_size; n++) {
//      if (_globalStore[n]->level > level){
////         s= [self addConstraintDuringSearch:c];
//         s = [self post:_globalStore[n]->constraint];
////         NSLog(@"Adding new global constraint %@ to constraint store",c);
////         [self propagate];
//         if (s == ORFailure){
//            return ORFailure;
//         }
////         if (status == ORFailure) {
////            NSLog(@"failure in restoring constraint %d\n",n);
////            NSLog(@"--------------------Begin Global Constraint Store--------------------\n");
////            for(int i=0;i<_size;i++){
////               NSLog(@"******************************");
////               NSLog(@"_globalStore[%d]\n",i);
////               for(int j=0;j<_globalStore[i]->vars->numAntecedents;j++)
////                  NSLog(@"0x%lx[%d] = %d\n",_globalStore[i]->vars->antecedents[j]->var,_globalStore[i]->vars->antecedents[j]->index,_globalStore[i]->vars->antecedents[j]->value);
////            }
////            NSLog(@"--------------------End Global Constraint Store--------------------\n");
////         }
////         ORUInt l;
////         for(int j=0;j<_globalStore[n]->vars->numAntecedents;j++){
////            if (_backjumpLevel > (l=[(CPBitVarI*)_globalStore[n]->vars->antecedents[j]->var getLevelBitWasSet:_globalStore[n]->vars->antecedents[j]->index]) &&
////                (l!=0)) {
////               _backjumpLevel = l;
////            }
////         }
//         _globalStore[n]->level = level;
//         _newConstraint = true;
//      }
//   }
//   _backjumpLevel = -1;
//   return status;
//}
-(void) addConstraint:(CPCoreConstraint*) c
{
   
   CPBVConflict* newConflict = malloc(sizeof(CPBVConflict));
   newConflict->constraint = [c retain];
   newConflict->level = [_tracer level];
   
   if (_size >= _capacity) {
      _capacity <<= 1;
      CPBVConflict** newStore = malloc(sizeof(CPBVConflict*)*_capacity);
      for (int i = 0; i<_size; i++) {
         newStore[i] = _globalStore[i];
      }
      free(_globalStore);
      _globalStore = newStore;
   }
   _globalStore[_size++] = newConflict;
   _retry = true;
}
-(void) addConstraint:(CPCoreConstraint*) c withJumpLevel:(ORUInt) level
{
   [self addConstraint:c];
   _backjumpLevel = (level < _backjumpLevel) ? level:_backjumpLevel;
}
-(ORUInt) getLevel
{
   return [_tracer level];
}

-(ORUInt) getBackjumpLevel
{
   ORUInt tmp = _backjumpLevel;
   _backjumpLevel = -1;
   return tmp;
}

-(ORBool) retry
{
   ORBool tmp = _retry;
   _retry = false;
   return tmp;
}

-(ORStatus) enforceObjective
{
   ORStatus s;
   ORInt currLevel = [_tracer level];
   // Add missing constraints back to constraint store here
   s = tryfail(^ORStatus{
      ORStatus status;
      for (int n = 0; n<_size; n++) {
         if (_globalStore[n]->level > currLevel){
            status=[self post:_globalStore[n]->constraint];
            if(status==ORFailure){
               return ORFailure;
            }
            _globalStore[n]->level = currLevel;
         }
      }
      status = propagateFDM(self);
      return status;
   }, ^ORStatus{
      return ORFailure;
   });
   
   if (s==ORFailure)
      return ORFailure;

   if (_objective == nil)
      return ORSuspend;
   return tryfail(^ORStatus{
      ORStatus ok = [_objective check];
      if (ok)
         ok = propagateFDM(self);
      return ok;
   }, ^ORStatus{
      return ORFailure;
   });
}


@end