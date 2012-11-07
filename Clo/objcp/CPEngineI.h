/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <objcp/CPTypes.h>
#import <objcp/CPEngine.h>
#import <objcp/CPConstraintI.h>

@class ORTrailI;
@class ORTrailIStack;
@class CPAC3Queue;
@class CPAC5Queue;

#define NBPRIORITIES ((ORInt)8)
#define LOWEST_PRIO  ((ORInt)0)
#define HIGHEST_PRIO ((ORInt)7)


// PVH: This guy covers two cases: the case where this is really a constraint and the case where this is a callback
// Ideally, the callback case should be in the AC-5 category

@interface VarEventNode : NSObject {
   @package
   VarEventNode*         _node;
   id                 _trigger;  // type is {ConstraintCallback}
   CPCoreConstraint*     _cstr;
   ORInt             _priority;
}
-(VarEventNode*) initVarEventNode: (VarEventNode*) next trigger: (id) t cstr: (CPCoreConstraint*) c at: (ORInt) prio;
-(void)dealloc;
@end

enum CPEngineState {
   CPOpen    = 0,
   CPClosing = 1,
   CPClosed  = 2
};

@interface CPEngineI : NSObject <CPEngine,NSCoding> {
   enum CPEngineState       _state;
   id<ORTrail>              _trail;
   NSMutableArray*          _vars;
   NSMutableArray*          _cStore;
   NSMutableArray*          _mStore;
   NSMutableArray*          _oStore;
   id<ORObjective>          _objective;
   CPAC3Queue*              _ac3[NBPRIORITIES];
   CPAC5Queue*              _ac5;
   ORStatus                _status;
   ORInt                _propagating;
   ORUInt               _nbpropag;
   CPCoreConstraint*        _last;
   UBType                   _propagIMP;
//   id<ORSolution>           _aSol;
   @package
   id<ORIntInformer>        _propagFail;
   id<ORVoidInformer>       _propagDone;
   ORFailException*         _fex;
}
-(CPEngineI*) initEngine: (id<ORTrail>) trail;
-(void)      dealloc;
-(id<CPEngine>) solver;
-(void)      trackVariable:(id)var;
-(void)      trackObject:(id)obj;
-(id)        trail;
-(void)      scheduleTrigger:(ConstraintCallback)cb onBehalf: (CPCoreConstraint*)c;
-(void)      scheduleAC3:(VarEventNode**)mlist;
-(void)      scheduleAC5:(VarEventNode*)list with: (ORInt)val;
-(ORStatus)  propagate;
-(void) setObjective: (id<ORObjective>) obj;
-(id<ORObjective>)objective;
-(ORStatus)  addInternal:(id<ORConstraint>) c;
-(ORStatus)  add:(id<ORConstraint>)c;
-(ORStatus)  post:(id<ORConstraint>)c;
-(ORStatus)  label:(id<CPIntVar>) var with: (ORInt) val;
-(ORStatus)  diff:(id<CPIntVar>) var with: (ORInt) val;
-(ORStatus)  lthen:(id<CPIntVar>) var with: (ORInt) val;
-(ORStatus)  gthen:(id<CPIntVar>) var with: (ORInt) val;
-(ORStatus)  restrict: (id<CPIntVar>) var to: (id<ORIntSet>) S;
-(NSMutableArray*) allVars;
-(NSMutableArray*) allConstraints;
-(NSMutableArray*) allModelConstraints;
-(ORStatus)  close;
-(ORStatus)  status;
-(bool)      closed;
-(ORUInt) nbPropagation;
-(ORUInt) nbVars;
-(id<ORInformer>) propagateFail;
-(id<ORInformer>) propagateDone;
-(ORStatus)enforceObjective;
@end
