/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Andreas Schutt and Pascal Van Hentenryck
 
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



@interface CPDisjunctive : CPCoreConstraint {
    id<CPTaskVarArray>  _tasks;   // TaskVar
    id<CPIntVarArray>   _start; // Start times of tasks
    id<CPIntVarArray>   _dur;   // Durations of tasks
}

-(id) initCPDisjunctive: (id<CPIntVarArray>) s duration: (id<CPIntVarArray>) d;
-(void) dealloc;
-(void) post;
-(void) propagate;
-(NSSet*) allVars;
-(ORUInt) nbUVars;
-(ORInt) globalSlack;
-(ORInt) localSlack;
@end
