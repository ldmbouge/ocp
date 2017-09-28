/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <objcp/CPFactory.h>

@interface CPFactory (Constraint)
+(id<CPGroup>)group:(id<CPEngine>)engine guard:(id<CPIntVar>)guard;

+(id<CPConstraint>) fail:(id<CPEngine>)engine;
+(id<CPConstraint>) alldifferent: (id<CPEngine>) solver over: (id<CPIntVarArray>) x;
+(id<CPConstraint>) alldifferent: (id<CPEngine>) solver over: (id<CPIntVarArray>) x annotation: (ORCLevel) c;
+(id<CPConstraint>) alldifferent: (id<CPIntVarArray>) x;
+(id<CPConstraint>) alldifferent: (id<CPIntVarArray>) x annotation: (ORCLevel) c;

+(id<CPConstraint>) cardinality: (id<CPIntVarArray>) x low: (id<ORIntArray>) low up: (id<ORIntArray>) up;
+(id<CPConstraint>) cardinality: (id<CPIntVarArray>) x low: (id<ORIntArray>) low up: (id<ORIntArray>) up annotation: (ORCLevel) c;

+(id<CPConstraint>) minimize: (id<CPIntVar>) x;
+(id<CPConstraint>) maximize: (id<CPIntVar>) x;

+(id<CPIntVar>) reifyView: (id<CPIntVar>) x eqi:(ORInt)c;

+(id<CPConstraint>) imply: (id<CPIntVar>) b with: (id<CPIntVar>) x eqi: (ORInt) i;

+(id<CPConstraint>) reify: (id<CPIntVar>) b with: (id<CPIntVar>) x eq: (id<CPIntVar>) y annotation:(ORCLevel)c;
+(id<CPConstraint>) reify: (id<CPIntVar>) b with: (id<CPIntVar>) x neq: (id<CPIntVar>) y annotation:(ORCLevel)c;
+(id<CPConstraint>) reify: (id<CPIntVar>) b with: (id<CPIntVar>) x leq:(id<CPIntVar>)y annotation:(ORCLevel)c;
+(id<CPConstraint>) reify: (id<CPIntVar>) b with: (id<CPIntVar>) x eqi: (ORInt) i;
+(id<CPConstraint>) reify: (id<CPIntVar>) b with: (id<CPIntVar>) x neqi: (ORInt) i;
+(id<CPConstraint>) reify: (id<CPIntVar>) b with: (id<CPIntVar>) x leqi: (ORInt) i;
+(id<CPConstraint>) reify: (id<CPIntVar>) b with: (id<CPIntVar>) x geqi: (ORInt) i;
+(id<CPConstraint>) reify:(id<CPIntVar>) b array:(id<CPIntVarArray>)x eqi:(ORInt) c annotation:(ORCLevel)note;
+(id<CPConstraint>) reify:(id<CPIntVar>) b array:(id<CPIntVarArray>)x geqi:(ORInt) c annotation:(ORCLevel)note;
+(id<CPConstraint>) hreify: (id<CPIntVar>) b array:(id<CPIntVarArray>)x eqi:(ORInt) c annotation:(ORCLevel)note;
+(id<CPConstraint>) hreify: (id<CPIntVar>) b array:(id<CPIntVarArray>)x geqi:(ORInt) c annotation:(ORCLevel)note;

+(id<CPConstraint>) clause:(id<CPIntVarArray>) x eq:(id<CPIntVar>)tv;
+(id<CPConstraint>) sumbool: (id<CPIntVarArray>) x geq: (ORInt) c;
+(id<CPConstraint>) sumbool: (id<CPIntVarArray>) x eq: (ORInt) c;
+(id<CPConstraint>) sumbool: (id<CPIntVarArray>) x neq: (ORInt) c;

+(id<CPConstraint>) sum: (id<CPIntVarArray>) x eq: (ORInt) c annotation: (ORCLevel)cons;
+(id<CPConstraint>) sum: (id<CPIntVarArray>) x eq: (ORInt) c;
+(id<CPConstraint>) sum: (id<CPIntVarArray>) x leq: (ORInt) c;

+(id<CPConstraint>) boolean:(id<CPIntVar>)x or:(id<CPIntVar>)y equal:(id<CPIntVar>)b;
+(id<CPConstraint>) boolean:(id<CPIntVar>)x and:(id<CPIntVar>)y equal:(id<CPIntVar>)b;
+(id<CPConstraint>) boolean:(id<CPIntVar>)x imply:(id<CPIntVar>)y equal:(id<CPIntVar>)b;
+(id<CPConstraint>) boolean:(id<CPIntVar>)x imply:(id<CPIntVar>)y;

+(id<CPConstraint>) circuit: (id<CPIntVarArray>) x;
+(id<CPConstraint>) path: (id<CPIntVarArray>) x;
+(id<CPConstraint>) subCircuit: (id<CPIntVarArray>) x;
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
+(id<CPConstraint>) element:(id<CPBitVar>)x idxBitVarArray:(id<ORIdArray>)array equal:(id<CPBitVar>)y annotation:(ORCLevel)n;
+(id<CPConstraint>) table: (id<ORTable>) table on: (id<CPIntVarArray>) x;
+(id<CPConstraint>) table: (id<ORTable>) table on: (id<CPIntVar>) x : (id<CPIntVar>) y : (id<CPIntVar>) z;
+(id<CPConstraint>) assignment: (id<CPEngine>) engine array: (id<CPIntVarArray>) x matrix: (id<ORIntMatrix>) matrix cost: (id<CPIntVar>) cost;
+(id<CPConstraint>) lex:(id<CPIntVarArray>)x leq:(id<CPIntVarArray>)y;
+(id<CPConstraint>) restrict:(id<CPIntVar>)x to:(id<ORIntSet>)r;

+(id<CPConstraint>) relaxation: (NSArray*) mv var: (NSArray*) cv relaxation: (id<ORRelaxation>) relaxation;
@end

@interface CPFactory (ORReal)
+(id<CPConstraint>) realSum:(id<CPRealVarArray>)x coef:(id<ORDoubleArray>)coefs eqi:(ORDouble)c;
+(id<CPConstraint>) realSum:(id<CPRealVarArray>)x coef:(id<ORDoubleArray>)coefs leqi:(ORDouble)c;
+(id<CPConstraint>) realSum:(id<CPRealVarArray>)x coef:(id<ORDoubleArray>)coefs geqi:(ORDouble)c;
+(id<CPConstraint>) realSquare: (id<CPRealVar>)x equal:(id<CPRealVar>)z annotation:(ORCLevel)c;
+(id<CPConstraint>) realWeightedVar: (id<CPRealVar>)z equal:(id<CPRealVar>)x weight: (id<CPRealParam>)w;
+(id<CPConstraint>) realEqualc: (id<CPIntVar>) x to:(ORDouble) c;
+(id<CPConstraint>) realElement:(id<CPIntVar>)x idxCstArray:(id<ORDoubleArray>)c equal:(id<CPRealVar>)y annotation:(ORCLevel)n;
+(id<CPConstraint>) realMinimize: (id<CPRealVar>) x;
+(id<CPConstraint>) realMaximize: (id<CPRealVar>) x;
@end

@interface CPFactory (ORFloat)
+(id<CPConstraint>) floatEqual: (id<CPFloatVar>) x to:(id<CPFloatVar>) y;
+(id<CPConstraint>) floatEqualc: (id<CPFloatVar>) x to:(ORFloat) c;
+(id<CPConstraint>) floatNEqualc: (id<CPFloatVar>) x to:(ORFloat) c;
+(id<CPConstraint>) floatLTc: (id<CPFloatVar>) x to:(ORFloat) c;
+(id<CPConstraint>) floatGTc: (id<CPFloatVar>) x to:(ORFloat) c;
+(id<CPConstraint>) floatLT: (id<CPFloatVar>) x to:(id<CPFloatVar>) y;
+(id<CPConstraint>) floatGT: (id<CPFloatVar>) x to:(id<CPFloatVar>) y;
+(id<CPConstraint>) floatSum:(id<CPFloatVarArray>)x coef:(id<ORFloatArray>)coefs eqi:(ORFloat)c;
+(id<CPConstraint>) floatSum:(id<CPFloatVarArray>)x coef:(id<ORFloatArray>)coefs neqi:(ORFloat)c;
+(id<CPConstraint>) floatSum:(id<CPFloatVarArray>)x coef:(id<ORFloatArray>)coefs lt:(ORFloat)c;
+(id<CPConstraint>) floatSum:(id<CPFloatVarArray>)x coef:(id<ORFloatArray>)coefs gt:(ORFloat)c;
+(id<CPConstraint>) floatSum:(id<CPFloatVarArray>)x coef:(id<ORFloatArray>)coefs leq:(ORFloat)c;
+(id<CPConstraint>) floatSum:(id<CPFloatVarArray>)x coef:(id<ORFloatArray>)coefs geq:(ORFloat)c;
+(id<CPConstraint>) floatMult: (id<CPFloatVar>)x by:(id<CPFloatVar>)y equal:(id<CPFloatVar>)z;
+(id<CPConstraint>) floatDiv: (id<CPFloatVar>)x by:(id<CPFloatVar>)y equal:(id<CPFloatVar>)z;
+(id<CPConstraint>) floatSSA: (id<CPFloatVar>)x with:(id<CPFloatVar>)y equal:(id<CPFloatVar>)z;
@end

@interface CPFactory (ORIntSet)
+(id<CPConstraint>) inter:(id<CPIntSetVar>)x with:(id<CPIntSetVar>)y eq:(id<CPIntSetVar>)z;
@end

@interface CPSearchFactory : NSObject
+(id<CPConstraint>) equalc: (id<CPIntVar>) x to:(ORInt) c;
+(id<CPConstraint>) notEqualc:(id<CPIntVar>)x to:(ORInt)c;
+(id<CPConstraint>) lEqualc: (id<CPIntVar>)x to: (ORInt) c;
@end

