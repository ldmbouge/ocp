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

typedef enum {
    CVAR_S = 0,     // Input variables: start time
    CVAR_SD,        // Input variables: start time, duration, area
    CVAR_SR,        // Input variables: start time, resource usage, area
    CVAR_SDR,       // Input variables: start time, duration, resource usage, but fixed area
    CVAR_SA,        // Input variables: start time, duration, resource usage, area
    CVAR_SE,
    CVAR_SDE,
    CVAR_SDRE,
    CVAR_SAE
} TaskType;

@interface CPCumulative : CPCoreConstraint {
    id<CPIntVarArray> _start;   // Start times of tasks
    id<CPIntVarArray> _dur;     // Durations of tasks
    id<CPIntVarArray> _usage;   // Resource usages of tasks
    id<CPIntVarArray> _area;    // Area/Energy of tasks
    id<CPIntVarArray> _end;     // End times of tasks
    TaskType*         _type;    // Task Type
    CPIntVar*         _cap;     // Resource capacity
}

-(id) initCPCumulative:(id<CPIntVarArray>)s duration:(id<CPIntVarArray>)d usage:(id<CPIntVarArray>)r energy:(id<CPIntVarArray>)a end:(id<CPIntVarArray>)e type:(TaskType*)t capacity:(id<CPIntVar>)c;
-(void) dealloc;
-(ORStatus) post;
-(void) propagate;
-(NSSet*) allVars;
-(ORUInt) nbUVars;
@end
