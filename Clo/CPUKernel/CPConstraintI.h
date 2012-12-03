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
   CPTodo _todo;
   bool   _idempotent;
   int    _priority;
   ORUInt _name;
   IMP    _propagate;
}
-(CPCoreConstraint*) initCPCoreConstraint;
-(ORStatus) doIt;
-(ORStatus) post;
-(void) propagate;
-(void) setId: (ORUInt) name;
-(ORUInt) getId;
-(NSSet*) allVars;
-(ORUInt) nbUVars;
@end

@interface CPActiveConstraint : CPCoreConstraint {
   id<ORTrail> _trail;
   TRInt       _active;
}
-(id) initCPActiveConstraint: (id<OREngine>) m;
@end

