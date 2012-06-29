/************************************************************************
 MIT License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 Permission is hereby granted, free of charge, to any person obtaining
 a copy of this software and associated documentation files (the
 "Software"), to deal in the Software without restriction, including
 without limitation the rights to use, copy, modify, merge, publish,
 distribute, sublicense, and/or sell copies of the Software, and to
 permit persons to whom the Software is furnished to do so, subject to
 the following conditions:
 
 The above copyright notice and this permission notice shall be
 included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 ***********************************************************************/

#import <Foundation/Foundation.h>
#import "CPTypes.h"
#import "CPConstraintI.h"
#import "CPSolver.h"
#import "CPTrail.h"
#import "CPTypes.h"
#import "CPConcurrency.h"
#import "CPSolution.h"

@class CPTrail;
@class CPTrailStack;
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

@interface CPSolverI : NSObject <CPSolver,NSCoding> {
   BOOL                     _closed;
   CPTrail*                 _trail;
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
   id<CPIntInformer>        _propagFail;
   id<CPVoidInformer>       _propagDone;
   id<CPSolution>           _aSol;
}
-(CPSolverI*) initSolver: (CPTrail*) trail;
-(void)      dealloc;
-(id<CPSolver>) solver;
-(void)      trackVariable:(id)var;
-(void)      trackObject:(id)obj;
-(id)        trail;
-(void)      scheduleTrigger:(ConstraintCallback)cb onBehalf:(CPCoreConstraint*)c;
-(void)      scheduleAC3:(VarEventNode**)mlist;
-(void)      scheduleAC5:(VarEventNode*)list with:(CPInt)val;
-(CPStatus)  propagate;
-(CPStatus)  add:(id<CPConstraint>)c;
-(CPStatus)  post:(id<CPConstraint>)c;
-(CPStatus)  label:(id)var with:(CPInt)val;
-(CPStatus)  diff:(id)var with:(CPInt)val;
-(CPStatus)  lthen:(id)var with:(CPInt)val;
-(CPStatus)  gthen:(id)var with:(CPInt)val;
-(CPStatus)  restrict: (id<CPIntVar>) var to: (id<CPIntSet>) S;
-(id)virtual:(id)obj;
-(CPInt)virtualOffset:(id)obj;
-(NSMutableArray*)allVars;
-(NSMutableArray*)allConstraints;
-(NSMutableArray*)allModelConstraints;
-(void)      saveSolution;
-(void)      restoreSolution;
-(CPStatus)  close;
-(bool)      closed;
-(CPUInt) nbPropagation;
-(CPUInt) nbVars;
-(id<CPInformer>) propagateFail;
-(id<CPInformer>) propagateDone;
@end

