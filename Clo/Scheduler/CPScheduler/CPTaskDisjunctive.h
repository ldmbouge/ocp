/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2013-14 NICTA, Andreas Schutt and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <Foundation/Foundation.h>
#import <CPUKernel/CPUKernel.h>
#import <CPUKernel/CPConstraintI.h>
#import <objcp/CPVar.h>

@protocol CPTaskVarArray;
@protocol CPTaskVar;

@interface CPTaskDisjunctive : CPCoreConstraint {
    id<CPTaskVarArray>  _tasks;     // TaskVar
    id<ORIntArray>      _resTasks;  // Whether a task is treated as resource task
}
-(id) initCPTaskDisjunctive: (id<CPTaskVarArray>) tasks;
-(id) initCPTaskDisjunctive: (id<CPTaskVarArray>) tasks resourceTasks: (id<ORIntArray>)res;
-(void) dealloc;
-(ORStatus) post;
-(void) propagate;
-(NSSet*) allVars;
-(ORUInt) nbUVars;
-(ORInt) globalSlack;
-(ORInt) localSlack;
@end

@protocol CPDisjunctiveArray <ORObject>
-(CPTaskDisjunctive*) at: (ORInt) idx;
-(void) set: (CPTaskDisjunctive*) value at: (ORInt)idx;
-(CPTaskDisjunctive*)objectAtIndexedSubscript:(NSUInteger)key;
-(void)setObject:(CPTaskDisjunctive*)newValue atIndexedSubscript:(NSUInteger)idx;
-(ORInt) low;
-(ORInt) up;
-(id<ORIntRange>) range;
-(NSUInteger) count;
-(NSString*) description;
-(id<ORTracker>) tracker;
@end
