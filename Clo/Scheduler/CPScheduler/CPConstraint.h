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



//    // Alternative propagator
//    //
//@interface CPAlternative : CPCoreConstraint<NSCoding> {
//    id<CPActivity>      _act;
//    id<CPActivityArray> _alter;
//}
//
//-(id) initCPAlternative: (id<CPActivity>) act alternatives: (id<CPActivityArray>) alter;
//-(void) dealloc;
//-(ORStatus) post;
//-(void) propagate;
//-(NSSet*) allVars;
//-(ORUInt) nbUVars;
//@end

@interface CPTaskPrecedence : CPCoreConstraint<NSCoding> {
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

@interface CPOptionalTaskPrecedence : CPCoreConstraint<NSCoding> {
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

@interface CPTaskIsFinishedBy : CPCoreConstraint<NSCoding> {
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

