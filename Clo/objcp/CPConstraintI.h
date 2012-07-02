/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <Foundation/Foundation.h>
#import "CPTypes.h"
#import "CPTrail.h"
#import "CPCommand.h"

@class CPSolverI;

typedef enum {
   CPChecked,
   CPTocheck,
   CPOff
} CPTodo;


@interface CPCoreConstraint : NSObject<NSCoding,CPCommand,CPConstraint> {
@package
    CPTodo _todo;
    bool   _idempotent;
    int    _priority;
    CPUInt _name;
}
-(CPCoreConstraint*) initCPCoreConstraint;
-(CPStatus) doIt;
-(CPStatus) post;
-(CPStatus) propagate;
-(void) setId:(CPUInt)name;
-(CPUInt)getId;
-(NSSet*)allVars;
-(CPUInt)nbUVars;
@end

@interface CPActiveConstraint : CPCoreConstraint {
   CPTrail* _trail;
   TRInt    _active;
}
-(id) initCPActiveConstraint: (id<CPSolver>) m;
@end

