/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <Foundation/Foundation.h>
#import "CPTypes.h"
#import "CPConstraintI.h"
#import "CPSolver.h"
#import "ORTrail.h"
#import "CPTypes.h"
#import "ORConcurrency.h"
#import "CPSolution.h"
#import "CPData.h"

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

@interface CPSolverI : NSObject <CPSolver,NSCoding> {
   BOOL                     _closed;
   ORTrail*                 _trail;
   NSMutableArray*          _vars;
   NSMutableArray*          _cStore;
   NSMutableArray*          _mStore;
   NSMutableArray*          _oStore;
   CPAC3Queue*              _ac3[NBPRIORITIES];
   CPAC5Queue*              _ac5;
   CPStatus                 _status;
   CPInt                _propagating;
   CPUInt               _nbpropag;
   CPCoreConstraint*        _last;               
   IMP                      _propagIMP;
   SEL                      _propagSEL;
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
-(CPStatus)  propagate;
-(CPStatus)  add:(id<CPExpr>)lhs equal:(id<CPExpr>)rhs consistency:(CPConsistency)cons;
-(CPStatus)  add:(id<CPConstraint>)c;
-(CPStatus)  post:(id<CPConstraint>)c;
-(CPStatus)  label:(id)var with:(CPInt)val;
-(CPStatus)  diff:(id)var with:(CPInt)val;
-(CPStatus)  lthen:(id)var with:(CPInt)val;
-(CPStatus)  gthen:(id)var with:(CPInt)val;
-(CPStatus)  restrict: (id<CPIntVar>) var to: (id<ORIntSet>) S;
-(id)virtual:(id)obj;
-(CPInt)virtualOffset:(id)obj;
-(NSMutableArray*)allVars;
-(NSMutableArray*)allConstraints;
-(NSMutableArray*)allModelConstraints;
-(void)      saveSolution;
-(void)      restoreSolution;
-(id<CPSolution>) solution;
-(CPStatus)  close;
-(CPStatus)  status;
-(bool)      closed;
-(CPUInt) nbPropagation;
-(CPUInt) nbVars;
-(id<ORInformer>) propagateFail;
-(id<ORInformer>) propagateDone;
@end
