/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "CPLearningEngineI.h"

//#import "objcp/CPBitConstraint.h"

@implementation CPLearningEngineI
-(CPLearningEngineI*) initEngine: (id<ORTrail>) trail memory:(id<ORMemoryTrail>)mt tracer:(id<ORTracer>)tr
{
   self = [super init];
   [super initEngine:trail memory:mt];
   _tracer = tr;
   _capacity = 32;
   _globalStore = malloc(sizeof(CPBVConflict*)*_capacity);
   _size = 0;
   _backjumpLevel = -1;
   _retry = false;
   return self;
}

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
   _globalStore[_size] = newConflict;
   _size++;
   
   _retry = true;
}
-(void) addConstraint:(CPCoreConstraint*) c withJumpLevel:(ORUInt) level
{
   [self addConstraint:c];
//   NSLog(@"Adding constraint at level %d and backjumping to level %d",[self getLevel], level);
    if ((ORInt)level < 5){
      level = [_tracer level];
    }
    //if backjumpLevel hasn't been set yet or if this constraint jumps higher
    //then level is the new level to jump back to
//    if ((ORInt)level < 5){
//        _backjumpLevel =[_tracer level];
//    }
//   else if ((_backjumpLevel < 4) || ((ORInt)level < _backjumpLevel))
//       _backjumpLevel = level;
    
      _backjumpLevel = (((ORInt)level > _backjumpLevel) && ((ORInt)level > 4)) ? level:_backjumpLevel;
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
//   NSLog(@"Restoring constraints at level %d",currLevel);
   // Add missing constraints back to constraint store here
   s = tryfail(^ORStatus{
      ORStatus status;
      for (int n = 0; n<_size; n++) {
         if (_globalStore[n]->level > currLevel){
             status = [self addInternal:_globalStore[n]->constraint];
//            status=[self post:_globalStore[n]->constraint];
            if(status==ORFailure){
               return ORFailure;
            }
            _globalStore[n]->level = currLevel;
         }
      }
      status = propagateFDM(self);
       if (status == ORFailure)
           return status;
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

//-(ORStatus)   close{
//
//    NSMutableArray* engineVars = [self variables];
//    CPBitAntecedents* ants = malloc(sizeof(CPBitAntecedents));
//    CPBitAssignment** vars;
//    vars= malloc(sizeof(CPBitAssignment*)*10);
//    vars[0] = malloc(sizeof(CPBitAssignment));
//    vars[0]->var = [engineVars objectAtIndex:103];
//    vars[0]->index = 30;
//    vars[0]->value = 1;
//    ants->antecedents = vars;
//    ants->numAntecedents = 1;
//    id<CPBVConstraint> c =  [CPFactory bitConflict:ants];
//    [self addConstraint:c];
//    
//    ORStatus s =  [super close];
//    return s;
//}

@end
