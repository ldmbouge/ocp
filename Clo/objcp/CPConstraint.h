/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <objcp/CP.h>
#import <objcp/CPFactory.h>
#import <objcp/CPTable.h>
#import <objcp/CPArray.h>

@interface CPFactory (Constraint)

+(id<CPConstraint>) alldifferent: (id<CPSolver>) solver over: (id<ORIntVarArray>) x;
+(id<CPConstraint>) alldifferent: (id<CPSolver>) solver over: (id<ORIntVarArray>) x consistency: (CPConsistency) c;
+(id<CPConstraint>) alldifferent: (id<ORIntVarArray>) x;
+(id<CPConstraint>) alldifferent: (id<ORIntVarArray>) x consistency: (CPConsistency) c;

+(id<CPConstraint>) cardinality: (id<CPIntVarArray>) x low: (id<CPIntArray>) low up: (id<CPIntArray>) up;
+(id<CPConstraint>) cardinality: (id<CPIntVarArray>) x low: (id<CPIntArray>) low up: (id<CPIntArray>) up consistency: (CPConsistency) c;

+(id<CPConstraint>) minimize: (id<ORIntVar>) x;
+(id<CPConstraint>) maximize: (id<ORIntVar>) x;

+(id<CPConstraint>) reify: (id<ORIntVar>) b with: (id<ORIntVar>) x eq: (id<ORIntVar>) y consistency:(CPConsistency)c;
+(id<CPConstraint>) reify: (id<ORIntVar>) b with: (id<ORIntVar>) x eqi: (CPInt) i;
+(id<CPConstraint>) reify: (id<ORIntVar>) b with: (id<ORIntVar>) x neq: (CPInt) i;
+(id<CPConstraint>) reify: (id<ORIntVar>) b with: (id<ORIntVar>) x leq: (CPInt) i;
+(id<CPConstraint>) reify: (id<ORIntVar>) b with: (id<ORIntVar>) x geq: (CPInt) i;

+(id<CPConstraint>) sumbool: (id<CPIntVarArray>) x geq: (CPInt) c;
+(id<CPConstraint>) sumbool: (id<CPIntVarArray>) x eq: (CPInt) c;
+(id<CPConstraint>) sum: (id<CPIntVarArray>) x eq: (CPInt) c consistency: (CPConsistency)cons;
+(id<CPConstraint>) sum: (id<CPIntVarArray>) x eq: (CPInt) c;
+(id<CPConstraint>) sum: (id<CPIntVarArray>) x leq: (CPInt) c;

+(id<CPConstraint>) boolean:(id<ORIntVar>)x or:(id<ORIntVar>)y equal:(id<ORIntVar>)b;
+(id<CPConstraint>) boolean:(id<ORIntVar>)x and:(id<ORIntVar>)y equal:(id<ORIntVar>)b;
+(id<CPConstraint>) boolean:(id<ORIntVar>)x imply:(id<ORIntVar>)y equal:(id<ORIntVar>)b;

+(id<CPConstraint>) circuit: (id<CPIntVarArray>) x;
+(id<CPConstraint>) nocycle: (id<CPIntVarArray>) x;
+(id<CPConstraint>) packing: (id<CPIntVarArray>) item itemSize: (id<CPIntArray>) itemSize binSize: (id<CPIntArray>) binSize;
+(id<CPConstraint>) packing: (id<CPIntVarArray>) item itemSize: (id<CPIntArray>) itemSize load: (id<CPIntVarArray>) load;
+(id<CPConstraint>) packOne: (id<CPIntVarArray>) item itemSize: (id<CPIntArray>) itemSize bin: (CPInt) b binSize: (id<ORIntVar>) binSize;
+(id<CPConstraint>) knapsack: (id<CPIntVarArray>) x weight:(id<CPIntArray>) w capacity:(id<ORIntVar>)c;

+(id<CPConstraint>) equal3: (id<ORIntVar>) x to: (id<ORIntVar>) y plus:(id<ORIntVar>) z consistency: (CPConsistency)cons;
+(id<CPConstraint>) equal: (id<ORIntVar>) x to: (id<ORIntVar>) y plus:(int) c consistency: (CPConsistency)cons;
+(id<CPConstraint>) equal: (id<ORIntVar>) x to: (id<ORIntVar>) y plus: (int) c;
+(id<CPConstraint>) equalc: (id<ORIntVar>) x to:(int) c;
+(id<CPConstraint>) notEqual: (id<ORIntVar>) x to: (id<ORIntVar>) y plus: (int) c;
+(id<CPConstraint>) notEqual: (id<ORIntVar>) x to: (id<ORIntVar>) y;
+(id<CPConstraint>) notEqualc:(id<ORIntVar>)x to:(CPInt)c;
+(id<CPConstraint>) lEqual: (id<ORIntVar>)x to: (id<ORIntVar>) y;
+(id<CPConstraint>) lEqualc: (id<ORIntVar>)x to: (CPInt) c;
+(id<CPConstraint>) less: (id<ORIntVar>)x to: (id<ORIntVar>) y;
+(id<CPConstraint>) mult: (id<ORIntVar>)x by:(id<ORIntVar>)y equal:(id<ORIntVar>)z;
+(id<CPConstraint>) abs: (id<ORIntVar>)x equal:(id<ORIntVar>)y consistency:(CPConsistency)c;
+(id<CPConstraint>) element:(id<ORIntVar>)x idxCstArray:(id<ORIntArray>)c equal:(id<ORIntVar>)y;
+(id<CPConstraint>) element:(id<ORIntVar>)x idxVarArray:(id<CPIntVarArray>)c equal:(id<ORIntVar>)y;
+(id<CPConstraint>) table: (id<CPTable>) table on: (id<CPIntVarArray>) x;
+(id<CPConstraint>) table: (id<CPTable>) table on: (id<ORIntVar>) x : (id<ORIntVar>) y : (id<ORIntVar>) z;
//+(id<CPConstraint>) expr: (id<CPExpr>)e  consistency: (CPConsistency) c;
//+(id<CPConstraint>) expr: (id<CPExpr>)e;

+(id<CPConstraint>) assignment: (id<CPIntVarArray>) x matrix: (id<CPIntMatrix>) matrix cost: (id<ORIntVar>) cost;
+(id<CPConstraint>) lex:(id<CPIntVarArray>)x leq:(id<CPIntVarArray>)y;
@end


