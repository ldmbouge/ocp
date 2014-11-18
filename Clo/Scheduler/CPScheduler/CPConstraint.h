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

@protocol CPTaskVar;
@protocol CPTaskVarArray;


    // Alternative propagator
    //
@interface CPAlternative : CPCoreConstraint {
    id<CPTaskVar>      _task;
    id<CPTaskVarArray> _alt;
}
-(id) initCPAlternative: (id<CPTaskVar>) task alternatives: (id<CPTaskVarArray>) alt;
-(void) dealloc;
-(ORStatus) post;
//-(void) propagate;
-(NSSet*) allVars;
-(ORUInt) nbUVars;
@end

// Span propagator
//
@interface CPSpan : CPCoreConstraint {
    id<CPTaskVar>      _task;
    id<CPTaskVarArray> _compound;
}
-(id) initCPSpan: (id<CPTaskVar>) task compound: (id<CPTaskVarArray>) compound;
-(void) dealloc;
-(ORStatus) post;
-(NSSet*) allVars;
-(ORUInt) nbUVars;
@end

@interface CPTaskPrecedence : CPCoreConstraint {
   id<CPTaskVar> _before;
   id<CPTaskVar> _after;
}
-(id) initCPTaskPrecedence: (id<CPTaskVar>) before after: (id<CPTaskVar>) after;
-(void) dealloc;
-(ORStatus) post;
-(void) propagate;
-(NSSet*) allVars;
-(ORUInt) nbUVars;
@end

@interface CPOptionalTaskPrecedence : CPCoreConstraint {
   id<CPTaskVar> _before;
   id<CPTaskVar> _after;
}
-(id) initCPOptionalTaskPrecedence: (id<CPTaskVar>) before after: (id<CPTaskVar>) after;
-(void) dealloc;
-(ORStatus) post;
-(void) propagate;
-(NSSet*) allVars;
-(ORUInt) nbUVars;
@end

@interface CPTaskIsFinishedBy : CPCoreConstraint {
   id<CPTaskVar> _task;
   id<CPIntVar> _date;
}
-(id) initCPTaskIsFinishedBy: (id<CPTaskVar>) task : (id<CPIntVar>) date;
-(void) dealloc;
-(ORStatus) post;
-(void) propagate;
-(NSSet*) allVars;
-(ORUInt) nbUVars;
@end

@interface CPTaskDuration : CPCoreConstraint {
   id<CPTaskVar> _task;
   id<CPIntVar> _duration;
}
-(id) initCPTaskDuration: (id<CPTaskVar>) task : (id<CPIntVar>) duration;
-(void) dealloc;
-(ORStatus) post;
-(void) propagate;
-(NSSet*) allVars;
-(ORUInt) nbUVars;
@end

@interface CPTaskAddTransitionTime : CPCoreConstraint {
   id<CPTaskVar> _normal;
   id<CPTaskVar> _extended;
   id<CPIntVar>  _time;
}
-(id) initCPTaskAddTransitionTime: (id<CPTaskVar>) normal extended: (id<CPTaskVar>) extended time: (id<CPIntVar>) time;
-(void) dealloc;
-(ORStatus) post;
-(void) propagate;
-(NSSet*) allVars;
-(ORUInt) nbUVars;
@end
