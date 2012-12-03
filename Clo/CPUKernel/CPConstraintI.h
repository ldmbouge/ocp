/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <CPUKernel/CPUKernel.h>

@class CPEngineI;

@interface CPCoreConstraint : NSObject<NSCoding,ORCommand,CPConstraint> {
@public
   CPTodo          _todo:2;
   bool      _idempotent:1;
   int        _priority:29;
   ORUInt            _name;
   IMP          _propagate;
   id<ORTrail>      _trail;
   TRInt           _active;
}
-(CPCoreConstraint*) initCPCoreConstraint:(id<OREngine>)m;
-(ORStatus) doIt;
-(ORStatus) post;
-(void) propagate;
-(void) setId:(ORUInt)name;
-(ORUInt)getId;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end
