/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <Foundation/Foundation.h>
#import "ORExpr.h"
#import "ORTracker.h"
#import "ORArray.h"

@protocol ORSolver;
@protocol ORSolverConcretizer;


@protocol ORVar <ORAbstract,ORExpr>
-(ORUInt) getId;
-(BOOL) bound;
@end

@protocol ORIntVar <ORVar>
-(id<ORIntRange>) domain;
-(ORInt) value;
-(ORInt) min;
-(ORInt) max;
-(ORInt) domsize;
-(bool) member: (ORInt) v;
-(id<ORIntVar>) dereference;
@end

@protocol ORVarArray <ORIdArray>
-(id<ORVar>) at: (ORInt) value;
-(void) set: (id<ORVar>) x at: (ORInt) value;
-(id<ORExpr>) elt: (id<ORExpr>) idx;
@end

@protocol ORIntVarArray <ORVarArray>
-(id<ORIntVar>) at: (ORInt) value;
-(void) set: (id<ORIntVar>) x at: (ORInt) value;
-(id<ORIntVar>) objectAtIndexedSubscript: (NSUInteger) key;
-(void) setObject: (id<ORIntVar>) newValue atIndexedSubscript: (NSUInteger) idx;
@end

@protocol ORIntVarMatrix <ORIdMatrix>
-(ORInt) arity;
-(id<ORIntVar>) flat:(ORInt)i;
-(id<ORIntVar>) at: (ORInt) i1 : (ORInt) i2;
-(id<ORIntVar>) at: (ORInt) i1 : (ORInt) i2 : (ORInt) i3;
-(void) set: (id) x at: (ORInt) i1 : (ORInt) i2;
-(void) set: (id) x at: (ORInt) i1 : (ORInt) i2 : (ORInt) i3;
-(id<ORIntRange>) range: (ORInt) i;
-(NSUInteger)count;
-(NSString*) description;
@end

@protocol ORAlldifferent <ORConstraint>
-(id<ORIntVarArray>) array;
@end

@protocol ORModel <NSObject,ORTracker>
-(void) add: (id<ORConstraint>) cstr;
-(void) minimize: (id<ORIntVar>) x;
-(void) maximize: (id<ORIntVar>) x;

-(void) instantiate: (id<ORSolver>) solver;
@end
