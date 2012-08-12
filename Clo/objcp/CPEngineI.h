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
#import <objcp/CPSolution.h>
#import <objcp/CPConstraintI.h>

@class ORTrail;
@class ORTrailStack;
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

@interface CPFailException : NSObject
-(CPFailException*)init;
@end

enum CPEngineState {
   CPOpen    = 0,
   CPClosing = 1,
   CPClosed  = 2
};

@interface CPEngineI : NSObject <CPEngine,NSCoding> {
   enum CPEngineState       _state;
   ORTrail*                 _trail;
   NSMutableArray*          _vars;
   NSMutableArray*          _cStore;
   NSMutableArray*          _mStore;
   NSMutableArray*          _oStore;
   CPAC3Queue*              _ac3[NBPRIORITIES];
   CPAC5Queue*              _ac5;
   ORStatus                 _status;
   ORInt                _propagating;
   CPUInt               _nbpropag;
   CPCoreConstraint*        _last;
   UBType                   _propagIMP;
   id<ORSolution>           _aSol;
   @package
   id<ORIntInformer>        _propagFail;
   id<ORVoidInformer>       _propagDone;
   CPFailException*         _fex;
}
-(CPEngineI*) initSolver: (ORTrail*) trail;
-(void)      dealloc;
-(id<CPEngine>) solver;
-(void)      trackVariable:(id)var;
-(void)      trackObject:(id)obj;
-(id)        trail;
-(void)      scheduleTrigger:(ConstraintCallback)cb onBehalf: (CPCoreConstraint*)c;
-(void)      scheduleAC3:(VarEventNode**)mlist;
-(void)      scheduleAC5:(VarEventNode*)list with: (ORInt)val;
-(ORStatus)  propagate;
-(id<CPConstraint>) wrapExpr: (id<ORSolver>) solver for: (id<CPRelation>) e  consistency: (CPConsistency)cons;
-(ORStatus)  add:(id<ORConstraint>)c;
-(ORStatus)  post:(id<ORConstraint>)c;
-(ORStatus)  label:(id<ORIntVar>) var with: (ORInt) val;
-(ORStatus)  diff:(id<ORIntVar>) var with: (ORInt) val;
-(ORStatus)  lthen:(id<ORIntVar>) var with: (ORInt) val;
-(ORStatus)  gthen:(id<ORIntVar>) var with: (ORInt) val;
-(ORStatus)  restrict: (id<ORIntVar>) var to: (id<ORIntSet>) S;
-(id)virtual:(id)obj;
-(ORInt)virtualOffset:(id)obj;
-(NSMutableArray*) allVars;
-(NSMutableArray*) allConstraints;
-(NSMutableArray*) allModelConstraints;
-(void)      saveSolution;
-(void)      restoreSolution;
-(id<ORSolution>) solution;
-(ORStatus)  close;
-(ORStatus)  status;
-(bool)      closed;
-(CPUInt) nbPropagation;
-(CPUInt) nbVars;
-(id<ORInformer>) propagateFail;
-(id<ORInformer>) propagateDone;
@end
