/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <CPUKernel/CPTypes.h>
#import <CPUKernel/CPCstr.h>

@class CPEngineI;
@class CPGroup;

typedef id (*SELPROTO)(id,SEL,...);

@interface CPCoreConstraint : ORObject<CPConstraint> {
@public
   CPTodo            _todo;
   ORInt         _priority;
   SELPROTO     _propagate;
   id<ORTrail>      _trail;
   TRInt           _active;
   CPGroup*      _group;
}
-(CPCoreConstraint*) initCPCoreConstraint:(id<ORSearchEngine>)m;
-(void) post;
-(void) propagate;
-(NSSet*) allVars;
-(ORUInt) nbUVars;
-(ORUInt) nbVars;
-(void)setGroup:(id<CPGroup>)g;
-(id<CPGroup>)group;
-(void) toCheck;
-(ORBool)entailed;
@end


@protocol CPABSConstraint
-(id<CPVar>) varSubjectToAbsorption:(id<CPVar>)x;
-(ORBool) canLeadToAnAbsorption;
@end
