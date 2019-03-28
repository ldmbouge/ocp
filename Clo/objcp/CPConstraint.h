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
+(id<CPGroup>)cdisj:(id<CPEngine>)engine originals:(id<CPVarArray>)origs  varmap:(NSArray*)vm;
+(id<CPGroup>) group3B:(id<CPEngine>)engine tracer:(id<ORTracer>)tracer percent: (ORDouble) p;
+(id<CPGroup>) group3B:(id<CPEngine>)engine tracer:(id<ORTracer>)tracer avars:(NSSet*) avars gamma:(id<ORGamma>) solver;
+(id<CPGroup>) group3B:(id<CPEngine>)engine tracer:(id<ORTracer>)tracer percent: (ORDouble) p avars:(NSSet*) avars gamma:(id<ORGamma>) solver;

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
+(id<CPConstraint>) floatAssign: (id<CPFloatVar>) x to:(id<CPFloatVar>) y;
+(id<CPConstraint>) floatAssignC: (id<CPFloatVar>) x to:(ORFloat) c;
+(id<CPConstraint>) floatEqual: (id<CPFloatVar>) x to:(id<CPFloatVar>) y;
+(id<CPConstraint>) floatEqualc: (id<CPFloatVar>) x to:(ORFloat) c;
+(id<CPConstraint>) floatNEqualc: (id<CPFloatVar>) x to:(ORFloat) c;
+(id<CPConstraint>) floatNEqual: (id<CPFloatVar>) x to:(id<CPFloatVar>) y;
+(id<CPConstraint>) floatLTc: (id<CPFloatVar>) x to:(ORFloat) c;
+(id<CPConstraint>) floatGTc: (id<CPFloatVar>) x to:(ORFloat) c;
+(id<CPConstraint>) floatLT: (id<CPFloatVar>) x to:(id<CPFloatVar>) y;
+(id<CPConstraint>) floatGT: (id<CPFloatVar>) x to:(id<CPFloatVar>) y;
+(id<CPConstraint>) floatSum:(id<CPFloatVarArray>)x coef:(id<ORFloatArray>)coefs eqi:(ORFloat)c annotation:(id<ORAnnotation>) notes;
+(id<CPConstraint>) floatSum:(id<CPFloatVarArray>)x coef:(id<ORFloatArray>)coefs neqi:(ORFloat)c annotation:(id<ORAnnotation>) notes;
+(id<CPConstraint>) floatSum:(id<CPFloatVarArray>)x coef:(id<ORFloatArray>)coefs lt:(ORFloat)c annotation:(id<ORAnnotation>) notes;
+(id<CPConstraint>) floatSum:(id<CPFloatVarArray>)x coef:(id<ORFloatArray>)coefs gt:(ORFloat)c annotation:(id<ORAnnotation>) notes;
+(id<CPConstraint>) floatSum:(id<CPFloatVarArray>)x coef:(id<ORFloatArray>)coefs leq:(ORFloat)c annotation:(id<ORAnnotation>) notes;
+(id<CPConstraint>) floatSum:(id<CPFloatVarArray>)x coef:(id<ORFloatArray>)coefs geq:(ORFloat)c annotation:(id<ORAnnotation>) notes;
+(id<CPConstraint>) floatMult: (id<CPFloatVar>)x by:(id<CPFloatVar>)y equal:(id<CPFloatVar>)z annotation:(id<ORAnnotation>) notes;
+(id<CPConstraint>) floatDiv: (id<CPFloatVar>)x by:(id<CPFloatVar>)y equal:(id<CPFloatVar>)z annotation:(id<ORAnnotation>) notes;
+(id<CPConstraint>) floatReify: (id<CPIntVar>) b with: (id<CPFloatVar>) x eq: (id<CPFloatVar>) y annotation:(ORCLevel)c;
+(id<CPConstraint>) floatReify: (id<CPIntVar>) b with: (id<CPFloatVar>) x geq: (id<CPFloatVar>) y annotation:(ORCLevel)c;
+(id<CPConstraint>) floatReify: (id<CPIntVar>) b with: (id<CPFloatVar>) x neq: (id<CPFloatVar>) y annotation:(ORCLevel)c;
+(id<CPConstraint>) floatReify: (id<CPIntVar>) b with: (id<CPFloatVar>) x leq:(id<CPFloatVar>)y annotation:(ORCLevel)c;
+(id<CPConstraint>) floatReify: (id<CPIntVar>) b with: (id<CPFloatVar>) x lt:(id<CPFloatVar>)y annotation:(ORCLevel)c;
+(id<CPConstraint>) floatReify: (id<CPIntVar>) b with: (id<CPFloatVar>) x gt: (id<CPFloatVar>) y annotation:(ORCLevel)c;
+(id<CPConstraint>) floatReify: (id<CPIntVar>) b with: (id<CPFloatVar>) x eqi: (ORFloat) i;
+(id<CPConstraint>) floatReify: (id<CPIntVar>) b with: (id<CPFloatVar>) x neqi: (ORFloat) i;
+(id<CPConstraint>) floatReify: (id<CPIntVar>) b with: (id<CPFloatVar>) x leqi: (ORFloat) i;
+(id<CPConstraint>) floatReify: (id<CPIntVar>) b with: (id<CPFloatVar>) x geqi: (ORFloat) i;
+(id<CPConstraint>) floatReify: (id<CPIntVar>) b with: (id<CPFloatVar>) x lti: (ORFloat) i;
+(id<CPConstraint>) floatReify: (id<CPIntVar>) b with: (id<CPFloatVar>) x gti: (ORFloat) i;
+(id<CPConstraint>) floatMinimize: (id<CPFloatVar>) x;
+(id<CPConstraint>) floatMaximize: (id<CPFloatVar>) x;
@end

@interface CPFactory (ORRational)
/*+(id<CPConstraint>) rationalAssign: (id<CPRationalVar>) x to:(id<CPRationalVar>) y;
+(id<CPConstraint>) rationalAssignC: (id<CPRationalVar>) x to:(id<ORRational>) c;*/
+(id<CPConstraint>) rationalEqual: (id<CPRationalVar>) x to:(id<CPRationalVar>) y;
+(id<CPConstraint>) errorOf: (id<CPFloatVar>) x is:(id<CPRationalVar>) y;
+(id<CPConstraint>) channel: (id<CPFloatVar>) x with:(id<CPRationalVar>) y;
+(id<CPConstraint>) rationalEqualc: (id<CPRationalVar>) x to:(id<ORRational>) c;
+(id<CPConstraint>) rationalNEqualc: (id<CPRationalVar>) x to:(id<ORRational>) c;
+(id<CPConstraint>) rationalNEqual: (id<CPRationalVar>) x to:(id<CPRationalVar>) y;
+(id<CPConstraint>) rationalLTc: (id<CPRationalVar>) x to:(id<ORRational>) c;
+(id<CPConstraint>) rationalGTc: (id<CPRationalVar>) x to:(id<ORRational>) c;
+(id<CPConstraint>) rationalLT: (id<CPRationalVar>) x to:(id<CPRationalVar>) y;
+(id<CPConstraint>) rationalGT: (id<CPRationalVar>) x to:(id<CPRationalVar>) y;
+(id<CPConstraint>) rationalSum:(id<CPRationalVarArray>)x coef:(id<ORRationalArray>)coefs eqi:(id<ORRational>)c annotation:(id<ORAnnotation>) notes;
//+(id<CPConstraint>) rationalSum:(id<CPRationalVarArray>)x coef:(id<ORRationalArray>)coefs neqi:(id<ORRational>)c annotation:(id<ORAnnotation>) notes;
//+(id<CPConstraint>) rationalSum:(id<CPRationalVarArray>)x coef:(id<ORRationalArray>)coefs lt:(id<ORRational>)c annotation:(id<ORAnnotation>) notes;
//+(id<CPConstraint>) rationalSum:(id<CPRationalVarArray>)x coef:(id<ORRationalArray>)coefs gt:(id<ORRational>)c annotation:(id<ORAnnotation>) notes;
+(id<CPConstraint>) rationalSum:(id<CPRationalVarArray>)x coef:(id<ORRationalArray>)coefs leq:(id<ORRational>)c annotation:(id<ORAnnotation>) notes;
+(id<CPConstraint>) rationalSum:(id<CPRationalVarArray>)x coef:(id<ORRationalArray>)coefs geq:(id<ORRational>)c annotation:(id<ORAnnotation>) notes;
//+(id<CPConstraint>) rationalMult: (id<CPRationalVar>)x by:(id<CPRationalVar>)y equal:(id<CPRationalVar>)z annotation:(id<ORAnnotation>) notes;
//+(id<CPConstraint>) rationalDiv: (id<CPRationalVar>)x by:(id<CPRationalVar>)y equal:(id<CPRationalVar>)z annotation:(id<ORAnnotation>) notes;
//+(id<CPConstraint>) rationalReify: (id<CPIntVar>) b with: (id<CPRationalVar>) x eq: (id<CPRationalVar>) y annotation:(ORCLevel)c;
//+(id<CPConstraint>) rationalReify: (id<CPIntVar>) b with: (id<CPRationalVar>) x geq: (id<CPRationalVar>) y annotation:(ORCLevel)c;
//+(id<CPConstraint>) rationalReify: (id<CPIntVar>) b with: (id<CPRationalVar>) x neq: (id<CPRationalVar>) y annotation:(ORCLevel)c;
//+(id<CPConstraint>) rationalReify: (id<CPIntVar>) b with: (id<CPRationalVar>) x leq:(id<CPRationalVar>)y annotation:(ORCLevel)c;
//+(id<CPConstraint>) rationalReify: (id<CPIntVar>) b with: (id<CPRationalVar>) x lt:(id<CPRationalVar>)y annotation:(ORCLevel)c;
//+(id<CPConstraint>) rationalReify: (id<CPIntVar>) b with: (id<CPRationalVar>) x gt: (id<CPRationalVar>) y annotation:(ORCLevel)c;
//+(id<CPConstraint>) rationalReify: (id<CPIntVar>) b with: (id<CPRationalVar>) x eqi: (id<ORRational>) i;
//+(id<CPConstraint>) rationalReify: (id<CPIntVar>) b with: (id<CPRationalVar>) x neqi: (id<ORRational>) i;
//+(id<CPConstraint>) rationalReify: (id<CPIntVar>) b with: (id<CPRationalVar>) x leqi: (id<ORRational>) i;
//+(id<CPConstraint>) rationalReify: (id<CPIntVar>) b with: (id<CPRationalVar>) x geqi: (id<ORRational>) i;
//+(id<CPConstraint>) rationalReify: (id<CPIntVar>) b with: (id<CPRationalVar>) x lti: (id<ORRational>) i;
//+(id<CPConstraint>) rationalReify: (id<CPIntVar>) b with: (id<CPRationalVar>) x gti: (id<ORRational>) i;
+(id<CPConstraint>) rationalMinimize: (id<CPRationalVar>) x;
+(id<CPConstraint>) rationalMaximize: (id<CPRationalVar>) x;
@end


@interface CPFactory (ORDouble)
+(id<CPConstraint>) doubleAssign: (id<CPDoubleVar>) x to:(id<CPDoubleVar>) y;
+(id<CPConstraint>) doubleAssignC: (id<CPDoubleVar>) x to:(ORDouble) c;
+(id<CPConstraint>) doubleEqual: (id<CPDoubleVar>) x to:(id<CPDoubleVar>) y;
+(id<CPConstraint>) doubleEqualc: (id<CPDoubleVar>) x to:(ORDouble) c;
+(id<CPConstraint>) doubleNEqualc: (id<CPDoubleVar>) x to:(ORDouble) c;
+(id<CPConstraint>) doubleNEqual: (id<CPDoubleVar>) x to:(id<CPDoubleVar>) y;
+(id<CPConstraint>) doubleLTc: (id<CPDoubleVar>) x to:(ORDouble) c;
+(id<CPConstraint>) doubleGTc: (id<CPDoubleVar>) x to:(ORDouble) c;
+(id<CPConstraint>) doubleLT: (id<CPDoubleVar>) x to:(id<CPDoubleVar>) y;
+(id<CPConstraint>) doubleGT: (id<CPDoubleVar>) x to:(id<CPDoubleVar>) y;
+(id<CPConstraint>) doubleSum:(id<CPDoubleVarArray>)x coef:(id<ORDoubleArray>)coefs eqi:(ORDouble)c annotation:(id<ORAnnotation>) notes;
+(id<CPConstraint>) doubleSum:(id<CPDoubleVarArray>)x coef:(id<ORDoubleArray>)coefs neqi:(ORDouble)c annotation:(id<ORAnnotation>) notes;
+(id<CPConstraint>) doubleSum:(id<CPDoubleVarArray>)x coef:(id<ORDoubleArray>)coefs lt:(ORDouble)c annotation:(id<ORAnnotation>) notes;
+(id<CPConstraint>) doubleSum:(id<CPDoubleVarArray>)x coef:(id<ORDoubleArray>)coefs gt:(ORDouble)c annotation:(id<ORAnnotation>) notes;
+(id<CPConstraint>) doubleSum:(id<CPDoubleVarArray>)x coef:(id<ORDoubleArray>)coefs leq:(ORDouble)c annotation:(id<ORAnnotation>) notes;
+(id<CPConstraint>) doubleSum:(id<CPDoubleVarArray>)x coef:(id<ORDoubleArray>)coefs geq:(ORDouble)c annotation:(id<ORAnnotation>) notes;
+(id<CPConstraint>) doubleMult: (id<CPDoubleVar>)x by:(id<CPDoubleVar>)y equal:(id<CPDoubleVar>)z annotation:(id<ORAnnotation>) notes;
+(id<CPConstraint>) doubleDiv: (id<CPDoubleVar>)x by:(id<CPDoubleVar>)y equal:(id<CPDoubleVar>)z annotation:(id<ORAnnotation>) notes;
+(id<CPConstraint>) doubleReify: (id<CPIntVar>) b with: (id<CPDoubleVar>) x eq: (id<CPDoubleVar>) y annotation:(ORCLevel)c;
+(id<CPConstraint>) doubleReify: (id<CPIntVar>) b with: (id<CPDoubleVar>) x geq: (id<CPDoubleVar>) y annotation:(ORCLevel)c;
+(id<CPConstraint>) doubleReify: (id<CPIntVar>) b with: (id<CPDoubleVar>) x neq: (id<CPDoubleVar>) y annotation:(ORCLevel)c;
+(id<CPConstraint>) doubleReify: (id<CPIntVar>) b with: (id<CPDoubleVar>) x leq:(id<CPDoubleVar>)y annotation:(ORCLevel)c;
+(id<CPConstraint>) doubleReify: (id<CPIntVar>) b with: (id<CPDoubleVar>) x lt:(id<CPDoubleVar>)y annotation:(ORCLevel)c;
+(id<CPConstraint>) doubleReify: (id<CPIntVar>) b with: (id<CPDoubleVar>) x gt: (id<CPDoubleVar>) y annotation:(ORCLevel)c;
+(id<CPConstraint>) doubleReify: (id<CPIntVar>) b with: (id<CPDoubleVar>) x eqi: (ORDouble) i;
+(id<CPConstraint>) doubleReify: (id<CPIntVar>) b with: (id<CPDoubleVar>) x neqi: (ORDouble) i;
+(id<CPConstraint>) doubleReify: (id<CPIntVar>) b with: (id<CPDoubleVar>) x leqi: (ORDouble) i;
+(id<CPConstraint>) doubleReify: (id<CPIntVar>) b with: (id<CPDoubleVar>) x geqi: (ORDouble) i;
+(id<CPConstraint>) doubleReify: (id<CPIntVar>) b with: (id<CPDoubleVar>) x lti: (ORDouble) i;
+(id<CPConstraint>) doubleReify: (id<CPIntVar>) b with: (id<CPDoubleVar>) x gti: (ORDouble) i;
@end

@interface CPFactory (ORIntSet)
+(id<CPConstraint>) inter:(id<CPIntSetVar>)x with:(id<CPIntSetVar>)y eq:(id<CPIntSetVar>)z;
@end

@interface CPSearchFactory : NSObject
+(id<CPConstraint>) equalc: (id<CPIntVar>) x to:(ORInt) c;
+(id<CPConstraint>) notEqualc:(id<CPIntVar>)x to:(ORInt)c;
+(id<CPConstraint>) lEqualc: (id<CPIntVar>)x to: (ORInt) c;
@end

