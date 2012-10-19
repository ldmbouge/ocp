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

+(id<CPConstraint>) alldifferent: (id<CPSolver>) solver over: (id<CPIntVarArray>) x;
+(id<CPConstraint>) alldifferent: (id<CPSolver>) solver over: (id<CPIntVarArray>) x consistency: (ORAnnotation) c;
+(id<CPConstraint>) alldifferent: (id<CPIntVarArray>) x;
+(id<CPConstraint>) alldifferent: (id<CPIntVarArray>) x consistency: (ORAnnotation) c;

+(id<CPConstraint>) cardinality: (id<ORIntVarArray>) x low: (id<ORIntArray>) low up: (id<ORIntArray>) up;
+(id<CPConstraint>) cardinality: (id<ORIntVarArray>) x low: (id<ORIntArray>) low up: (id<ORIntArray>) up consistency: (ORAnnotation) c;

+(id<CPConstraint>) minimize: (id<ORIntVar>) x;
+(id<CPConstraint>) maximize: (id<ORIntVar>) x;

+(id<CPIntVar>) reifyView: (id<ORIntVar>) x eqi:(ORInt)c;

+(id<CPConstraint>) reify: (id<ORIntVar>) b with: (id<ORIntVar>) x eq: (id<ORIntVar>) y consistency:(ORAnnotation)c;
+(id<CPConstraint>) reify: (id<ORIntVar>) b with: (id<ORIntVar>) x eqi: (ORInt) i;
+(id<CPConstraint>) reify: (id<ORIntVar>) b with: (id<ORIntVar>) x neq: (ORInt) i;
+(id<CPConstraint>) reify: (id<ORIntVar>) b with: (id<ORIntVar>) x leq: (ORInt) i;
+(id<CPConstraint>) reify: (id<ORIntVar>) b with: (id<ORIntVar>) x geq: (ORInt) i;

+(id<CPConstraint>) sumbool: (id<ORIntVarArray>) x geq: (ORInt) c;
+(id<CPConstraint>) sumbool: (id<ORIntVarArray>) x eq: (ORInt) c;
+(id<CPConstraint>) sum: (id<ORIntVarArray>) x eq: (ORInt) c consistency: (ORAnnotation)cons;
+(id<CPConstraint>) sum: (id<ORIntVarArray>) x eq: (ORInt) c;
+(id<CPConstraint>) sum: (id<ORIntVarArray>) x leq: (ORInt) c;

+(id<CPConstraint>) boolean:(id<ORIntVar>)x or:(id<ORIntVar>)y equal:(id<ORIntVar>)b;
+(id<CPConstraint>) boolean:(id<ORIntVar>)x and:(id<ORIntVar>)y equal:(id<ORIntVar>)b;
+(id<CPConstraint>) boolean:(id<ORIntVar>)x imply:(id<ORIntVar>)y equal:(id<ORIntVar>)b;

+(id<CPConstraint>) circuit: (id<ORIntVarArray>) x;
+(id<CPConstraint>) nocycle: (id<ORIntVarArray>) x;
+(id<CPConstraint>) packing: (id<ORIntVarArray>) item itemSize: (id<ORIntArray>) itemSize load: (id<ORIntVarArray>) load;
+(id<CPConstraint>) packOne: (id<ORIntVarArray>) item itemSize: (id<ORIntArray>) itemSize bin: (ORInt) b binSize: (id<ORIntVar>) binSize;
+(id<CPConstraint>) knapsack: (id<ORIntVarArray>) x weight:(id<ORIntArray>) w capacity:(id<ORIntVar>)c;

+(id<CPConstraint>) equal3: (id<ORIntVar>) x to: (id<ORIntVar>) y plus:(id<ORIntVar>) z consistency: (ORAnnotation)cons;
+(id<CPConstraint>) equal: (id<ORIntVar>) x to: (id<ORIntVar>) y plus:(ORInt) c consistency: (ORAnnotation)cons;
+(id<CPConstraint>) equal: (id<ORIntVar>) x to: (id<ORIntVar>) y plus: (ORInt) c;
+(id<CPConstraint>) equalc: (id<ORIntVar>) x to:(ORInt) c;
+(id<CPConstraint>) notEqual: (id<ORIntVar>) x to: (id<ORIntVar>) y plus: (ORInt) c;
+(id<CPConstraint>) notEqual: (id<ORIntVar>) x to: (id<ORIntVar>) y;
+(id<CPConstraint>) notEqualc:(id<ORIntVar>)x to:(ORInt)c;
+(id<CPConstraint>) lEqual: (id<CPIntVar>)x to: (id<CPIntVar>) y;
+(id<CPConstraint>) lEqual: (id<CPIntVar>)x to: (id<CPIntVar>) y plus:(ORInt)c;
+(id<CPConstraint>) lEqualc: (id<CPIntVar>)x to: (ORInt) c;
+(id<CPConstraint>) less: (id<CPIntVar>)x to: (id<ORIntVar>) y;
+(id<CPConstraint>) mult: (id<ORIntVar>)x by:(id<ORIntVar>)y equal:(id<ORIntVar>)z;
+(id<CPConstraint>) abs: (id<ORIntVar>)x equal:(id<ORIntVar>)y consistency:(ORAnnotation)c;
+(id<CPConstraint>) element:(id<ORIntVar>)x idxCstArray:(id<ORIntArray>)c equal:(id<ORIntVar>)y;
+(id<CPConstraint>) element:(id<ORIntVar>)x idxVarArray:(id<ORIntVarArray>)c equal:(id<ORIntVar>)y;
+(id<CPConstraint>) table: (id<ORTable>) table on: (id<ORIntVarArray>) x;
+(id<CPConstraint>) table: (id<ORTable>) table on: (id<ORIntVar>) x : (id<ORIntVar>) y : (id<ORIntVar>) z;
+(id<CPConstraint>) assignment: (id<ORIntVarArray>) x matrix: (id<ORIntMatrix>) matrix cost: (id<ORIntVar>) cost;
+(id<CPConstraint>) lex:(id<ORIntVarArray>)x leq:(id<ORIntVarArray>)y;

@end


