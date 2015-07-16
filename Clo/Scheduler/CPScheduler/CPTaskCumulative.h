/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2013-14 NICTA, Andreas Schutt and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <CPUKernel/CPConstraintI.h>
#import <objcp/CPBitDom.h>
#import <objcp/CPVar.h>

@class CPIntVar;

@protocol CPTaskVarArray;
@protocol CPTaskVar;

    // NOTE there this constraints makes following assumptions.
    //  - The arrays 'tasks' and 'usages' have the same number of elements with
    //    the same indices.
    //  - A solution of this constraint only contains non-negative integer for
    //    the duration and usage of tasks and the capacity
    //  - A negative integer for any of them will throw an exception.
@interface CPTaskCumulative : CPCoreConstraint {
    id<CPTaskVarArray> _tasks;      // Array of tasks
    id<ORIntArray>     _resTasks;
    id<CPIntVarArray>  _usages;     // Resource usage of the tasks on the resource
    id<CPIntVar>       _capacity;   // Resource capacity
}
-(id) initCPTaskCumulative: (id<CPTaskVarArray>)tasks with: (id<CPIntVarArray>)usages and: (id<CPIntVar>)capacity;
-(id) initCPTaskCumulative: (id<CPTaskVarArray>)tasks resourceTasks:(id<ORIntArray>)resTasks with: (id<CPIntVarArray>)usages and: (id<CPIntVar>)capacity;
-(void) dealloc;
-(ORStatus) post;
-(void) propagate;
-(NSSet*) allVars;
//-(CPTaskVarPrec *) getPartialOrder: (ORInt *) posize;
-(ORUInt) nbUVars;
@end
