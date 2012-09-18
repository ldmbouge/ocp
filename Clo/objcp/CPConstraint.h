/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <objcp/CPSolver.h>
#import <objcp/CPFactory.h>

@interface CPFactory (Constraint)

+(id<ORConstraint>) alldifferent: (id<CPSolver>) solver over: (id<ORIntVarArray>) x;
+(id<ORConstraint>) alldifferent: (id<CPSolver>) solver over: (id<ORIntVarArray>) x consistency: (CPConsistency) c;
+(id<ORConstraint>) alldifferent: (id<ORIntVarArray>) x;
+(id<ORConstraint>) alldifferent: (id<ORIntVarArray>) x consistency: (CPConsistency) c;

+(id<ORConstraint>) cardinality: (id<ORIntVarArray>) x low: (id<ORIntArray>) low up: (id<ORIntArray>) up;
+(id<ORConstraint>) cardinality: (id<ORIntVarArray>) x low: (id<ORIntArray>) low up: (id<ORIntArray>) up consistency: (CPConsistency) c;

+(id<ORConstraint>) minimize: (id<ORIntVar>) x;
+(id<ORConstraint>) maximize: (id<ORIntVar>) x;

+(id<ORIntVar>) reifyView: (id<ORIntVar>) x eqi:(ORInt)c;

+(id<ORConstraint>) reify: (id<ORIntVar>) b with: (id<ORIntVar>) x eq: (id<ORIntVar>) y consistency:(CPConsistency)c;
+(id<ORConstraint>) reify: (id<ORIntVar>) b with: (id<ORIntVar>) x eqi: (ORInt) i;
+(id<ORConstraint>) reify: (id<ORIntVar>) b with: (id<ORIntVar>) x neq: (ORInt) i;
+(id<ORConstraint>) reify: (id<ORIntVar>) b with: (id<ORIntVar>) x leq: (ORInt) i;
+(id<ORConstraint>) reify: (id<ORIntVar>) b with: (id<ORIntVar>) x geq: (ORInt) i;

+(id<ORConstraint>) sumbool: (id<ORIntVarArray>) x geq: (ORInt) c;
+(id<ORConstraint>) sumbool: (id<ORIntVarArray>) x eq: (ORInt) c;
+(id<ORConstraint>) sum: (id<ORIntVarArray>) x eq: (ORInt) c consistency: (CPConsistency)cons;
+(id<ORConstraint>) sum: (id<ORIntVarArray>) x eq: (ORInt) c;
+(id<ORConstraint>) sum: (id<ORIntVarArray>) x leq: (ORInt) c;

+(id<ORConstraint>) boolean:(id<ORIntVar>)x or:(id<ORIntVar>)y equal:(id<ORIntVar>)b;
+(id<ORConstraint>) boolean:(id<ORIntVar>)x and:(id<ORIntVar>)y equal:(id<ORIntVar>)b;
+(id<ORConstraint>) boolean:(id<ORIntVar>)x imply:(id<ORIntVar>)y equal:(id<ORIntVar>)b;

+(id<ORConstraint>) circuit: (id<ORIntVarArray>) x;
+(id<ORConstraint>) nocycle: (id<ORIntVarArray>) x;
+(id<ORConstraint>) packing: (id<ORIntVarArray>) item itemSize: (id<ORIntArray>) itemSize binSize: (id<ORIntArray>) binSize;
+(id<ORConstraint>) packing: (id<ORIntVarArray>) item itemSize: (id<ORIntArray>) itemSize load: (id<ORIntVarArray>) load;
+(id<ORConstraint>) packOne: (id<ORIntVarArray>) item itemSize: (id<ORIntArray>) itemSize bin: (ORInt) b binSize: (id<ORIntVar>) binSize;
+(id<ORConstraint>) knapsack: (id<ORIntVarArray>) x weight:(id<ORIntArray>) w capacity:(id<ORIntVar>)c;

+(id<ORConstraint>) equal3: (id<ORIntVar>) x to: (id<ORIntVar>) y plus:(id<ORIntVar>) z consistency: (CPConsistency)cons;
+(id<ORConstraint>) equal: (id<ORIntVar>) x to: (id<ORIntVar>) y plus:(ORInt) c consistency: (CPConsistency)cons;
+(id<ORConstraint>) equal: (id<ORIntVar>) x to: (id<ORIntVar>) y plus: (ORInt) c;
+(id<ORConstraint>) equalc: (id<ORIntVar>) x to:(ORInt) c;
+(id<ORConstraint>) notEqual: (id<ORIntVar>) x to: (id<ORIntVar>) y plus: (ORInt) c;
+(id<ORConstraint>) notEqual: (id<ORIntVar>) x to: (id<ORIntVar>) y;
+(id<ORConstraint>) notEqualc:(id<ORIntVar>)x to:(ORInt)c;
+(id<ORConstraint>) lEqual: (id<ORIntVar>)x to: (id<ORIntVar>) y;
+(id<ORConstraint>) lEqual: (id<ORIntVar>)x to: (id<ORIntVar>) y plus:(ORInt)c;
+(id<ORConstraint>) lEqualc: (id<ORIntVar>)x to: (ORInt) c;
+(id<ORConstraint>) less: (id<ORIntVar>)x to: (id<ORIntVar>) y;
+(id<ORConstraint>) mult: (id<ORIntVar>)x by:(id<ORIntVar>)y equal:(id<ORIntVar>)z;
+(id<ORConstraint>) abs: (id<ORIntVar>)x equal:(id<ORIntVar>)y consistency:(CPConsistency)c;
+(id<ORConstraint>) element:(id<ORIntVar>)x idxCstArray:(id<ORIntArray>)c equal:(id<ORIntVar>)y;
+(id<ORConstraint>) element:(id<ORIntVar>)x idxVarArray:(id<ORIntVarArray>)c equal:(id<ORIntVar>)y;
+(id<ORConstraint>) table: (id<ORTable>) table on: (id<ORIntVarArray>) x;
+(id<ORConstraint>) table: (id<ORTable>) table on: (id<ORIntVar>) x : (id<ORIntVar>) y : (id<ORIntVar>) z;
+(id<ORConstraint>) relation2Constraint: (id<CPSolver>) solver expr: (id<ORExpr>) e consistency: (CPConsistency) c;
+(id<ORConstraint>) relation2Constraint: (id<CPSolver>) solver expr: (id<ORExpr>) e;

+(id<ORConstraint>) assignment: (id<ORIntVarArray>) x matrix: (id<ORIntMatrix>) matrix cost: (id<ORIntVar>) cost;
+(id<ORConstraint>) lex:(id<ORIntVarArray>)x leq:(id<ORIntVarArray>)y;
@end


