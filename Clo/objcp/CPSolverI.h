/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <objcp/CPTypes.h>
#import <objcp/CPSolver.h>
#import <objcp/CPSolution.h>
#import <objcp/CPConstraintI.h>

@class ORTrail;
@class ORTrailStack;
@class CPAC3Queue;
@class CPAC5Queue;

#define NBPRIORITIES ((CPInt)8)
#define LOWEST_PRIO  ((CPInt)0)
#define HIGHEST_PRIO ((CPInt)7)


// PVH: This guy covers two cases: the case where this is really a constraint and the case where this is a callback
// Ideally, the callback case should be in the AC-5 category

@interface VarEventNode : NSObject {
    @package
    VarEventNode*         _node;
    id                 _trigger;  // type is {ConstraintCallback}
    CPCoreConstraint*     _cstr;
    CPInt             _priority;
}
-(VarEventNode*) initVarEventNode: (VarEventNode*) next trigger: (id) t cstr: (CPCoreConstraint*) c at: (CPInt) prio;
-(void)dealloc;
@end

// We have all kinds of arrays. 

@interface CPFailException : NSObject
-(CPFailException*)init;
@end

enum CPSolverState {
   CPOpen    = 0,
   CPClosing = 1,
   CPClosed  = 2
   };

@interface CPSolverI : NSObject <CPSolver,NSCoding> {
   enum CPSolverState       _state;
   ORTrail*                 _trail;
   NSMutableArray*          _vars;
   NSMutableArray*          _cStore;
   NSMutableArray*          _mStore;
   NSMutableArray*          _oStore;
   CPAC3Queue*              _ac3[NBPRIORITIES];
   CPAC5Queue*              _ac5;
   ORStatus                 _status;
   CPInt                _propagating;
   CPUInt               _nbpropag;
   CPCoreConstraint*        _last;               
   UBType                   _propagIMP;
   id<CPSolution>           _aSol;
   @package
   id<ORIntInformer>        _propagFail;
   id<ORVoidInformer>       _propagDone;
   CPFailException*         _fex;
}
-(CPSolverI*) initSolver: (ORTrail*) trail;
-(void)      dealloc;
-(id<CPSolver>) solver;
-(void)      trackVariable:(id)var;
-(void)      trackObject:(id)obj;
-(id)        trail;
-(void)      scheduleTrigger:(ConstraintCallback)cb onBehalf:(CPCoreConstraint*)c;
-(void)      scheduleAC3:(VarEventNode**)mlist;
-(void)      scheduleAC5:(VarEventNode*)list with:(CPInt)val;
-(ORStatus)  propagate;
-(id<CPConstraint>) wrapExpr:(id<CPRelation>) e  consistency:(CPConsistency)cons;
-(ORStatus)  add:(id<CPExpr>)lhs leq:(id<CPExpr>)rhs consistency:(CPConsistency)cons;
-(ORStatus)  add:(id<CPExpr>)lhs equal:(id<CPExpr>)rhs consistency:(CPConsistency)cons;
-(ORStatus)  add:(id<CPConstraint>)c;
-(ORStatus)  post:(id<CPConstraint>)c;
-(ORStatus)  label:(id)var with:(CPInt)val;
-(ORStatus)  diff:(id)var with:(CPInt)val;
-(ORStatus)  lthen:(id)var with:(CPInt)val;
-(ORStatus)  gthen:(id)var with:(CPInt)val;
-(ORStatus)  restrict: (id<CPIntVar>) var to: (id<ORIntSet>) S;
-(id)virtual:(id)obj;
-(CPInt)virtualOffset:(id)obj;
-(NSMutableArray*)allVars;
-(NSMutableArray*)allConstraints;
-(NSMutableArray*)allModelConstraints;
-(void)      saveSolution;
-(void)      restoreSolution;
-(id<CPSolution>) solution;
-(ORStatus)  close;
-(ORStatus)  status;
-(bool)      closed;
-(CPUInt) nbPropagation;
-(CPUInt) nbVars;
-(id<ORInformer>) propagateFail;
-(id<ORInformer>) propagateDone;
@end
