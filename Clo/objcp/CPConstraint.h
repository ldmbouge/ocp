/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <objcp/CPFactory.h>

@interface CPFactory (Constraint)

+(id<CPConstraint>) alldifferent: (id<CPEngine>) solver over: (id<CPIntVarArray>) x;
+(id<CPConstraint>) alldifferent: (id<CPEngine>) solver over: (id<CPIntVarArray>) x annotation: (ORCLevel) c;
+(id<CPConstraint>) alldifferent: (id<CPIntVarArray>) x;
+(id<CPConstraint>) alldifferent: (id<CPIntVarArray>) x annotation: (ORCLevel) c;

+(id<CPConstraint>) cardinality: (id<CPIntVarArray>) x low: (id<ORIntArray>) low up: (id<ORIntArray>) up;
+(id<CPConstraint>) cardinality: (id<CPIntVarArray>) x low: (id<ORIntArray>) low up: (id<ORIntArray>) up annotation: (ORCLevel) c;

+(id<CPConstraint>) minimize: (id<CPIntVar>) x;
+(id<CPConstraint>) maximize: (id<CPIntVar>) x;

+(id<CPIntVar>) reifyView: (id<CPIntVar>) x eqi:(ORInt)c;

+(id<CPConstraint>) reify: (id<CPIntVar>) b with: (id<CPIntVar>) x eq: (id<CPIntVar>) y annotation:(ORCLevel)c;
+(id<CPConstraint>) reify: (id<CPIntVar>) b with: (id<CPIntVar>) x neq: (id<CPIntVar>) y annotation:(ORCLevel)c;
+(id<CPConstraint>) reify: (id<CPIntVar>) b with: (id<CPIntVar>) x leq:(id<CPIntVar>)y annotation:(ORCLevel)c;
+(id<CPConstraint>) reify: (id<CPIntVar>) b with: (id<CPIntVar>) x eqi: (ORInt) i;
+(id<CPConstraint>) reify: (id<CPIntVar>) b with: (id<CPIntVar>) x neqi: (ORInt) i;
+(id<CPConstraint>) reify: (id<CPIntVar>) b with: (id<CPIntVar>) x leqi: (ORInt) i;
+(id<CPConstraint>) reify: (id<CPIntVar>) b with: (id<CPIntVar>) x geqi: (ORInt) i;
+(id<CPConstraint>) hreify: (id<CPIntVar>) b array:(id<CPIntVarArray>)x eqi:(ORInt) c annotation:(ORCLevel)c;
+(id<CPConstraint>) hreify: (id<CPIntVar>) b array:(id<CPIntVarArray>)x geqi:(ORInt) c annotation:(ORCLevel)c;

+(id<CPConstraint>) sumbool: (id<CPIntVarArray>) x geq: (ORInt) c;
+(id<CPConstraint>) sumbool: (id<CPIntVarArray>) x eq: (ORInt) c;
+(id<CPConstraint>) sum: (id<CPIntVarArray>) x eq: (ORInt) c annotation: (ORCLevel)cons;
+(id<CPConstraint>) sum: (id<CPIntVarArray>) x eq: (ORInt) c;
+(id<CPConstraint>) sum: (id<CPIntVarArray>) x leq: (ORInt) c;

+(id<CPConstraint>) boolean:(id<CPIntVar>)x or:(id<CPIntVar>)y equal:(id<CPIntVar>)b;
+(id<CPConstraint>) boolean:(id<CPIntVar>)x and:(id<CPIntVar>)y equal:(id<CPIntVar>)b;
+(id<CPConstraint>) boolean:(id<CPIntVar>)x imply:(id<CPIntVar>)y equal:(id<CPIntVar>)b;

+(id<CPConstraint>) circuit: (id<CPIntVarArray>) x;
+(id<CPConstraint>) nocycle: (id<CPIntVarArray>) x;
+(id<CPConstraint>) packOne: (id<CPIntVarArray>) item itemSize: (id<ORIntArray>) itemSize bin: (ORInt) b binSize: (id<CPIntVar>) binSize;
+(id<CPConstraint>) knapsack: (id<CPIntVarArray>) x weight:(id<ORIntArray>) w capacity:(id<CPIntVar>)c;
+(id<CPConstraint>) affine:(id<CPIntVar>)y equal:(ORInt)a times:(id<CPIntVar>)x plus:(ORInt)b annotation:(ORCLevel)n;
+(id<CPConstraint>) equal3: (id<CPIntVar>) x to: (id<CPIntVar>) y plus:(id<CPIntVar>) z annotation: (ORCLevel)cons;
+(id<CPConstraint>) equal: (id<CPIntVar>) x to: (id<CPIntVar>) y plus:(ORInt) c annotation: (ORCLevel)cons;
+(id<CPConstraint>) equal: (id<CPIntVar>) x to: (id<CPIntVar>) y plus: (ORInt) c;
+(id<CPConstraint>) equalc: (id<CPIntVar>) x to:(ORInt) c;
+(id<CPConstraint>) notEqual: (id<CPIntVar>) x to: (id<CPIntVar>) y plus: (ORInt) c;
+(id<CPConstraint>) notEqual: (id<CPIntVar>) x to: (id<CPIntVar>) y;
+(id<CPConstraint>) notEqualc:(id<CPIntVar>)x to:(ORInt)c;

+(id<CPConstraint>) lEqual: (id<CPIntVar>)x to: (id<CPIntVar>) y;
+(id<CPConstraint>) lEqual: (id<CPIntVar>)x to: (id<CPIntVar>) y plus:(ORInt)c;
+(id<CPConstraint>) lEqualc: (id<CPIntVar>)x to: (ORInt) c;
+(id<CPConstraint>) gEqualc: (id<CPIntVar>)x to: (ORInt) c;
+(id<CPConstraint>) less: (id<CPIntVar>)x to: (id<CPIntVar>) y;
+(id<CPConstraint>) mult: (id<CPIntVar>)x by:(id<CPIntVar>)y equal:(id<CPIntVar>)z;
+(id<CPConstraint>) square: (id<CPIntVar>)x equal:(id<CPIntVar>)z annotation:(ORCLevel)c;
+(id<CPConstraint>) mod: (id<CPIntVar>)x modi:(ORInt)c equal:(id<CPIntVar>)y annotation:(ORCLevel)note;
+(id<CPConstraint>) mod: (id<CPIntVar>)x mod:(id<CPIntVar>)y equal:(id<CPIntVar>)z;
+(id<CPConstraint>) min: (id<CPIntVar>)x and:(id<CPIntVar>)y equal:(id<CPIntVar>)z;
+(id<CPConstraint>) max: (id<CPIntVar>)x and:(id<CPIntVar>)y equal:(id<CPIntVar>)z;
+(id<CPConstraint>) abs: (id<CPIntVar>)x equal:(id<CPIntVar>)y annotation:(ORCLevel)c;
+(id<CPConstraint>) element:(id<CPIntVar>)x idxCstArray:(id<ORIntArray>)c equal:(id<CPIntVar>)y annotation:(ORCLevel)n;
+(id<CPConstraint>) element:(id<CPIntVar>)x idxVarArray:(id<CPIntVarArray>)c equal:(id<CPIntVar>)y annotation:(ORCLevel)n;
+(id<CPConstraint>) table: (id<ORTable>) table on: (id<CPIntVarArray>) x;
+(id<CPConstraint>) table: (id<ORTable>) table on: (id<CPIntVar>) x : (id<CPIntVar>) y : (id<CPIntVar>) z;
+(id<CPConstraint>) assignment: (id<CPEngine>) engine array: (id<CPIntVarArray>) x matrix: (id<ORIntMatrix>) matrix cost: (id<CPIntVar>) cost;
+(id<CPConstraint>) lex:(id<CPIntVarArray>)x leq:(id<CPIntVarArray>)y;
+(id<CPConstraint>) restrict:(id<CPIntVar>)x to:(id<ORIntSet>)r;

+(id<CPConstraint>) relaxation: (NSArray*) mv var: (NSArray*) cv relaxation: (id<ORRelaxation>) relaxation;
@end

@interface CPFactory (ORFloat)
+(id<CPConstraint>) floatSum:(id<CPFloatVarArray>)x coef:(id<ORFloatArray>)coefs eqi:(ORFloat)c;
+(id<CPConstraint>) floatSum:(id<CPFloatVarArray>)x coef:(id<ORFloatArray>)coefs leqi:(ORFloat)c;
+(id<CPConstraint>) floatSquare: (id<CPFloatVar>)x equal:(id<CPFloatVar>)z annotation:(ORCLevel)c;
+(id<CPConstraint>) floatEqualc: (id<CPIntVar>) x to:(ORFloat) c;
+(id<CPConstraint>) floatElement:(id<CPIntVar>)x idxCstArray:(id<ORFloatArray>)c equal:(id<CPFloatVar>)y annotation:(ORCLevel)n;
+(id<CPConstraint>) floatMinimize: (id<CPFloatVar>) x;
+(id<CPConstraint>) floatMaximize: (id<CPFloatVar>) x;
@end

@interface CPSearchFactory : NSObject
+(id<CPConstraint>) equalc: (id<CPIntVar>) x to:(ORInt) c;
+(id<CPConstraint>) notEqualc:(id<CPIntVar>)x to:(ORInt)c;
+(id<CPConstraint>) lEqualc: (id<CPIntVar>)x to: (ORInt) c;
@end

