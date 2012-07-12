/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <Foundation/Foundation.h>
#import "CP.h"
#import "CPFactory.h"
#import "CPTable.h"
#import "CPArray.h"

@interface CPFactory (Constraint)

+(id<CPConstraint>) alldifferent: (id<CPIntVarArray>) x;
+(id<CPConstraint>) alldifferent: (id<CPIntVarArray>) x consistency: (CPConsistency) c;

+(id<CPConstraint>) cardinality: (id<CPIntVarArray>) x low: (id<CPIntArray>) low up: (id<CPIntArray>) up;
+(id<CPConstraint>) cardinality: (id<CPIntVarArray>) x low: (id<CPIntArray>) low up: (id<CPIntArray>) up consistency: (CPConsistency) c;

+(id<CPConstraint>) minimize: (id<CPIntVar>) x;
+(id<CPConstraint>) maximize: (id<CPIntVar>) x;

+(id<CPConstraint>) reify: (id<CPIntVar>) b with: (id<CPIntVar>) x eq: (CPInt) i;
+(id<CPConstraint>) reify: (id<CPIntVar>) b with: (id<CPIntVar>) x neq: (CPInt) i;
+(id<CPConstraint>) reify: (id<CPIntVar>) b with: (id<CPIntVar>) x leq: (CPInt) i;
+(id<CPConstraint>) reify: (id<CPIntVar>) b with: (id<CPIntVar>) x geq: (CPInt) i;

+(id<CPConstraint>) sumbool: (id<CPIntVarArray>) x geq: (CPInt) c;
+(id<CPConstraint>) sumbool: (id<CPIntVarArray>) x eq: (CPInt) c;
+(id<CPConstraint>) sum: (id<CPIntVarArray>) x eq: (CPInt) c consistency: (CPConsistency)cons;
+(id<CPConstraint>) sum: (id<CPIntVarArray>) x eq: (CPInt) c;
+(id<CPConstraint>) sum: (id<CPIntVarArray>) x leq: (CPInt) c;

+(id<CPConstraint>) boolean:(id<CPIntVar>)x or:(id<CPIntVar>)y equal:(id<CPIntVar>)b;
+(id<CPConstraint>) boolean:(id<CPIntVar>)x and:(id<CPIntVar>)y equal:(id<CPIntVar>)b;
+(id<CPConstraint>) boolean:(id<CPIntVar>)x imply:(id<CPIntVar>)y equal:(id<CPIntVar>)b;

+(id<CPConstraint>) circuit: (id<CPIntVarArray>) x;
+(id<CPConstraint>) nocycle: (id<CPIntVarArray>) x;
+(id<CPConstraint>) packing: (id<CPIntVarArray>) item itemSize: (id<CPIntArray>) itemSize binSize: (id<CPIntArray>) binSize;
+(id<CPConstraint>) packing: (id<CPIntVarArray>) item itemSize: (id<CPIntArray>) itemSize load: (id<CPIntVarArray>) load;

+(id<CPConstraint>) equal3: (id<CPIntVar>) x to: (id<CPIntVar>) y plus:(id<CPIntVar>) z consistency: (CPConsistency)cons;
+(id<CPConstraint>) equal: (id<CPIntVar>) x to: (id<CPIntVar>) y plus:(int) c consistency: (CPConsistency)cons;
+(id<CPConstraint>) equal: (id<CPIntVar>) x to: (id<CPIntVar>) y plus: (int) c;
+(id<CPConstraint>) equalc: (id<CPIntVar>) x to:(int) c;
+(id<CPConstraint>) notEqual: (id<CPIntVar>) x to: (id<CPIntVar>) y plus: (int) c;
+(id<CPConstraint>) notEqual: (id<CPIntVar>) x to: (id<CPIntVar>) y;
+(id<CPConstraint>) notEqualc:(id<CPIntVar>)x to:(CPInt)c;
+(id<CPConstraint>) lEqual: (id<CPIntVar>)x to: (id<CPIntVar>) y;
+(id<CPConstraint>) lEqualc: (id<CPIntVar>)x to: (CPInt) c;
+(id<CPConstraint>) less: (id<CPIntVar>)x to: (id<CPIntVar>) y;
+(id<CPConstraint>) mult: (id<CPIntVar>)x by:(id<CPIntVar>)y equal:(id<CPIntVar>)z;
+(id<CPConstraint>) abs: (id<CPIntVar>)x equal:(id<CPIntVar>)y consistency:(CPConsistency)c;
+(id<CPConstraint>) element:(id<CPIntVar>)x idxCstArray:(id<ORIntArray>)c equal:(id<CPIntVar>)y;
+(id<CPConstraint>) element:(id<CPIntVar>)x idxVarArray:(id<CPIntVarArray>)c equal:(id<CPIntVar>)y;
+(id<CPConstraint>) table: (id<CPTable>) table on: (id<CPIntVarArray>) x;
+(id<CPConstraint>) table: (id<CPTable>) table on: (id<CPIntVar>) x : (id<CPIntVar>) y : (id<CPIntVar>) z;
//+(id<CPConstraint>) expr: (id<CPExpr>)e  consistency: (CPConsistency) c;
//+(id<CPConstraint>) expr: (id<CPExpr>)e;

+(id<CPConstraint>) assignment: (id<CPIntVarArray>) x matrix: (id<CPIntMatrix>) matrix cost: (id<CPIntVar>) cost;
+(id<CPConstraint>) lex:(id<CPIntVarArray>)x leq:(id<CPIntVarArray>)y;
@end


