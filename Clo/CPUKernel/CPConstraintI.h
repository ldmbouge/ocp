/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <CPUKernel/CPUKernel.h>

@class CPEngineI;

@interface CPCoreConstraint : ORObject<CPConstraint> {
@public
   CPTodo            _todo;
   ORInt         _priority;
   IMP          _propagate;
   id<ORTrail>      _trail;
   TRInt           _active;
   id<CPGroup>      _group;
}
-(CPCoreConstraint*) initCPCoreConstraint:(id<ORSearchEngine>)m;
-(void) post;
-(void) propagate;
-(NSSet*) allVars;
-(ORUInt) nbUVars;
-(ORUInt) nbVars;
-(void)setGroup:(id<CPGroup>)g;
-(id<CPGroup>)group;
@end
