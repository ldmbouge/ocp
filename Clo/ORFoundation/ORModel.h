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


@protocol ORVar <ORObject,ORExpr>
-(ORUInt) getId;
-(BOOL) bound;
-(id<ORSolver>) solver;
-(NSSet*)constraints;
@end


@protocol ORIntVar <ORVar>
-(id<ORIntRange>) domain;
-(ORInt) value;
-(ORInt) min;
-(ORInt) max;
-(ORInt) domsize;
-(ORBounds)bounds;
-(BOOL) member: (ORInt) v;
-(BOOL) isBool;
-(id<ORIntVar>) dereference;
-(ORInt)scale;
-(ORInt)shift;
-(id<ORIntVar>)base;
@end

@protocol ORVarArray <ORIdArray>
-(id<ORVar>) at: (ORInt) value;
-(void) set: (id<ORVar>) x at: (ORInt) value;
-(id<ORExpr>) elt: (id<ORExpr>) idx;
-(id<ORVar>) objectAtIndexedSubscript: (NSUInteger) key;
-(void) setObject: (id<ORVar>) newValue atIndexedSubscript: (NSUInteger) idx;
@end

@protocol ORIntVarArray <ORVarArray>
-(id<ORIntVar>) at: (ORInt) value;
-(void) set: (id<ORIntVar>) x at: (ORInt) value;
-(id<ORIntVar>) objectAtIndexedSubscript: (NSUInteger) key;
-(void) setObject: (id<ORIntVar>) newValue atIndexedSubscript: (NSUInteger) idx;
-(id<ORSolver>) solver;
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
-(id<ORSolver>) solver;
@end

@protocol ORAlldifferent <ORConstraint>
-(id<ORIntVarArray>) array;
@end

@protocol ORBinPacking <ORConstraint>
-(id<ORIntVarArray>) item;
-(id<ORIntArray>) itemSize;
-(id<ORIntVarArray>) binSize;
@end


@protocol ORAlgebraicConstraint <ORConstraint>
-(id<ORExpr>) expr;
@end

@protocol ORTableConstraint <ORConstraint>
-(id<ORIntVarArray>) array;
-(id<ORTable>) table;
@end

@protocol ORCardinality <ORConstraint>
-(id<ORIntVarArray>) array;
-(id<ORIntArray>) low;
-(id<ORIntArray>) up;
@end

@protocol ORObjectiveFunction
-(id<ORIntVar>) var;
@end

@protocol ORModel <NSObject,ORTracker>
-(NSString*)description;
-(void) add: (id<ORConstraint>) cstr;
-(void) minimize: (id<ORIntVar>) x;
-(void) maximize: (id<ORIntVar>) x;
-(void) instantiate: (id<ORSolver>) solver;
-(void) applyOnVar:(void(^)(id<ORObject>))doVar onObjects:(void(^)(id<ORObject>))doObjs onConstraints:(void(^)(id<ORObject>))doCons;
-(id<ORObjectiveFunction>)objective;
@end
