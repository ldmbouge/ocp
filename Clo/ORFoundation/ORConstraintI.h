/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORUtilities/ORTypes.h>
#import <ORFoundation/ORObject.h>
#import <ORFoundation/ORConstraint.h>
#import <ORFoundation/ORArray.h>
#import <ORFoundation/ORSet.h>
#import <ORFoundation/ORVar.h>
#import <ORFoundation/ORExprI.h>
#import <ORFoundation/ORVisit.h>

@interface ORGroupI : ORObject<ORGroup>
-(ORGroupI*)initORGroupI:(id<ORTracker>)model type:(enum ORGroupType)gt;
-(ORGroupI*)initORGroupI:(id<ORTracker>)model type:(enum ORGroupType)gt guard:(id<ORIntVar>)g;
-(id<ORConstraint>)add:(id<ORConstraint>)c;
-(NSString*) description;
-(void)enumerateObjectWithBlock:(void(^)(id<ORConstraint>))block;
-(void)clear;
-(ORInt) size;
-(id<ORConstraint>) at: (ORInt) idx;
-(id<ORIntVar>)guard;
-(enum ORGroupType)type;
-(id<ORConstraint>)alphaVars:(id<ORVarArray>) xa;
@end

@interface ORCDisjGroupI : ORGroupI<ORCDGroup>
-(ORCDisjGroupI*)initORCDGroupI:(id<ORTracker>)model;
-(ORCDisjGroupI*)initORCDGroupI:(id<ORTracker>)model witMap:(NSArray*)vMap;
@end

@interface OR3BGroupI : ORGroupI
-(OR3BGroupI*)initOR3BGroupI:(id<ORTracker>)model;
@end

@interface ORFail : ORConstraintI<ORFail>
-(ORFail*)init;
@end

@interface ORRestrict : ORConstraintI<ORRestrict>
-(ORRestrict*)initRestrict:(id<ORIntVar>)x to:(id<ORIntSet>)d;
-(id<ORIntVar>)var;
-(id<ORIntSet>)restriction;
@end

@interface OREqualc : ORConstraintI<OREqualc>
-(OREqualc*)initOREqualc:(id<ORIntVar>)x eqi:(ORInt)c;
-(id<ORIntVar>) left;
-(ORInt) cst;
@end

@interface ORRealEqualc : ORConstraintI<ORRealEqualc>
-(OREqualc*)init:(id<ORRealVar>)x eqi:(ORDouble)c;
-(id<ORRealVar>) left;
-(ORDouble) cst;
@end

@interface ORNEqualc : ORConstraintI<ORNEqualc>
-(ORNEqualc*)initORNEqualc:(id<ORIntVar>)x neqi:(ORInt)c;
-(id<ORIntVar>) left;
-(ORInt) cst;
@end

@interface ORFloatEqualc : ORConstraintI<ORFloatEqualc>
-(ORFloatEqualc*)initORFloatEqualc:(id<ORFloatVar>)x eqi:(ORFloat)c;
-(id<ORFloatVar>) left;
-(ORFloat) cst;
@end

@interface ORFloatNEqualc : ORConstraintI<ORFloatNEqualc>
-(ORFloatNEqualc*)initORFloatNEqualc:(id<ORFloatVar>)x neqi:(ORFloat)c;
-(id<ORFloatVar>) left;
-(ORFloat) cst;
@end

@interface ORDoubleEqualc : ORConstraintI<ORDoubleEqualc>
-(ORDoubleEqualc*)initORDoubleEqualc:(id<ORDoubleVar>)x eqi:(ORDouble)c;
-(id<ORDoubleVar>) left;
-(ORDouble) cst;
@end

@interface ORDoubleNEqualc : ORConstraintI<ORDoubleNEqualc>
-(ORDoubleNEqualc*)initORDoubleNEqualc:(id<ORDoubleVar>)x neqi:(ORDouble)c;
-(id<ORDoubleVar>) left;
-(ORDouble) cst;
@end


@interface ORLEqualc : ORConstraintI<ORLEqualc>
-(ORLEqualc*)initORLEqualc:(id<ORIntVar>)x leqi:(ORInt)c;
-(id<ORIntVar>) left;
-(ORInt) cst;
@end

@interface ORGEqualc : ORConstraintI<ORGEqualc>
-(ORGEqualc*)initORGEqualc:(id<ORIntVar>)x geqi:(ORInt)c;
-(id<ORIntVar>) left;
-(ORInt) cst;
@end

@interface OREqual : ORConstraintI<OREqual>
-(id)initOREqual: (id<ORVar>) x eq: (id<ORVar>) y plus: (ORInt) c;
-(id<ORVar>) left;
-(id<ORVar>) right;
-(ORInt) cst;
@end

@interface ORAffine :ORConstraintI<ORAffine>
-(ORAffine*)initORAffine: (id<ORIntVar>) y eq:(ORInt)a times:(id<ORIntVar>) x plus: (ORInt) b;
-(id<ORIntVar>) left;
-(id<ORIntVar>) right;
-(ORInt)coef;
-(ORInt)cst;
@end


@interface ORNEqual : ORConstraintI<ORNEqual,NSCoding>
-(ORNEqual*) initORNEqual: (id<ORIntVar>) x neq: (id<ORIntVar>) y;
-(ORNEqual*) initORNEqual: (id<ORIntVar>) x neq: (id<ORIntVar>) y plus: (ORInt) c;
-(id<ORIntVar>) left;
-(id<ORIntVar>) right;
-(ORInt) cst;
@end

@interface ORSoftNEqual : ORNEqual<ORSoftNEqual,NSCoding>
-(id) initORSoftNEqual: (id<ORIntVar>) x neq: (id<ORIntVar>) y slack: (id<ORVar>)slack;
-(id) initORSoftNEqual: (id<ORIntVar>) x neq: (id<ORIntVar>) y plus: (ORInt) c slack: (id<ORVar>)slack;
-(id<ORVar>) slack;
@end

@interface ORLEqual : ORConstraintI<ORLEqual>
-(ORLEqual*)initORLEqual: (id<ORIntVar>) x leq: (id<ORIntVar>) y plus: (ORInt) c;
-(ORLEqual*)initORLEqual:(ORInt)a times:(id<ORIntVar>)x leq:(ORInt)b times:(id<ORIntVar>)y plus:(ORInt)c;
-(id<ORIntVar>) left;
-(id<ORIntVar>) right;
-(ORInt) cst;
-(ORInt) coefLeft;
-(ORInt) coefRight;
@end

@interface ORPlus : ORConstraintI<ORPlus>
-(ORPlus*)initORPlus:(id<ORIntVar>)x eq:(id<ORIntVar>)y plus:(id<ORIntVar>)z;
-(id<ORIntVar>) res;
-(id<ORIntVar>) left;
-(id<ORIntVar>) right;
@end

@interface ORMult : ORConstraintI<ORMult>
-(ORMult*)initORMult:(id<ORVar>)x eq:(id<ORVar>)y times:(id<ORVar>)z;
-(id<ORVar>) res;
-(id<ORVar>) left;
-(id<ORVar>) right;
@end

@interface ORSquare : ORConstraintI<ORSquare>
-(ORSquare*)init:(id<ORVar>)z square:(id<ORVar>)x;
-(id<ORVar>)res;
-(id<ORVar>)op;
@end

@interface ORRealSquare : ORSquare
@end

@interface ORMod : ORConstraintI<ORMod>
-(ORMod*)initORMod:(id<ORIntVar>)x mod:(id<ORIntVar>)y equal:(id<ORIntVar>)z;
-(id<ORIntVar>) res;
-(id<ORIntVar>) left;
-(id<ORIntVar>) right;
@end

@interface ORModc : ORConstraintI<ORModc>
-(ORModc*)initORModc:(id<ORIntVar>)x mod:(ORInt)y equal:(id<ORIntVar>)z;
-(id<ORIntVar>) res;
-(id<ORIntVar>) left;
-(ORInt) right;
@end

@interface ORMin : ORConstraintI<ORMin>
-(ORMod*)init:(id<ORIntVar>)x and:(id<ORIntVar>)y equal:(id<ORIntVar>)z;
-(id<ORIntVar>) res;
-(id<ORIntVar>) left;
-(id<ORIntVar>) right;
@end

@interface ORMax : ORConstraintI<ORMax>
-(ORMod*)init:(id<ORIntVar>)x and:(id<ORIntVar>)y equal:(id<ORIntVar>)z;
-(id<ORIntVar>) res;
-(id<ORIntVar>) left;
-(id<ORIntVar>) right;
@end

// PVH: should add annotation
@interface ORAbs : ORConstraintI<ORAbs>
-(ORAbs*)initORAbs:(id<ORIntVar>)x eqAbs:(id<ORIntVar>)y;
-(id<ORIntVar>) res;
-(id<ORIntVar>) left;
@end

@interface OROr : ORConstraintI<OROr>
-(OROr*)initOROr:(id<ORIntVar>)x eq:(id<ORIntVar>)y or:(id<ORIntVar>)z;
-(id<ORIntVar>) res;
-(id<ORIntVar>) left;
-(id<ORIntVar>) right;
@end

@interface ORAnd : ORConstraintI<ORAnd>
-(ORAnd*)initORAnd:(id<ORIntVar>)x eq:(id<ORIntVar>)y and:(id<ORIntVar>)z;
-(id<ORIntVar>) res;
-(id<ORIntVar>) left;
-(id<ORIntVar>) right;
@end

@interface ORImply : ORConstraintI<ORImply>
-(ORImply*)initORImply:(id<ORIntVar>)x eq:(id<ORIntVar>)y imply:(id<ORIntVar>)z;
-(id<ORIntVar>) res;
-(id<ORIntVar>) left;
-(id<ORIntVar>) right;
@end

@interface ORBinImply : ORConstraintI<ORBinImply>
-(ORImply*)init:(id<ORIntVar>)x imply:(id<ORIntVar>)y;
-(id<ORIntVar>) left;
-(id<ORIntVar>) right;
@end

@interface ORElementCst : ORConstraintI<ORElementCst>
-(ORElementCst*)initORElement:(id<ORIntVar>)idx array:(id<ORIntArray>)y equal:(id<ORIntVar>)z; // y[idx] == z
-(id<ORIntArray>) array;
-(id<ORIntVar>)   idx;
-(id<ORIntVar>)   res;
@end

@interface ORElementVar : ORConstraintI<ORElementVar>
-(ORElementVar*)initORElement:(id<ORIntVar>)idx array:(id<ORIntVarArray>)y equal:(id<ORIntVar>)z; // y[idx] == z
-(id<ORIntVarArray>) array;
-(id<ORIntVar>)   idx;
-(id<ORIntVar>)   res;
@end

@interface ORElementBitVar : ORConstraintI<ORElementBitVar>
-(ORElementBitVar*)initORElement:(id<ORBitVar>)idx array:(id<ORIdArray>)y equal:(id<ORBitVar>)z; // y[idx] == z
-(id<ORIdArray>) array;
-(id<ORBitVar>)   idx;
-(id<ORBitVar>)   res;
@end

@interface ORElementMatrixVar : ORConstraintI<ORElementMatrixVar>
-(id)initORElement:(id<ORIntVarMatrix>)m elt:(id<ORIntVar>)v0 elt:(id<ORIntVar>)v1 equal:(id<ORIntVar>)y;
-(id<ORIntVarMatrix>)matrix;
-(id<ORIntVar>)index0;
-(id<ORIntVar>)index1;
-(id<ORIntVar>) res;
@end

@interface ORRealElementCst : ORConstraintI<ORRealElementCst>
-(ORElementCst*)initORElement:(id<ORIntVar>)idx array:(id<ORDoubleArray>)y equal:(id<ORRealVar>)z; // y[idx] == z
-(id<ORDoubleArray>) array;
-(id<ORIntVar>)       idx;
-(id<ORRealVar>)     res;
@end

@interface ORRealReifyEqualc : ORConstraintI<ORRealReifyEqualc>
-(ORRealReifyEqualc*)initRealReify:(id<ORIntVar>)b equiv:(id<ORRealVar>)x eqi:(ORDouble)c;
@end

@interface ORRealReifyGEqualc : ORConstraintI<ORRealReifyGEqualc>
-(ORRealReifyGEqualc*)initRealReify:(id<ORIntVar>)b equiv:(id<ORRealVar>)x geqi:(ORDouble)c;
@end

@interface ORRealReifyEqual : ORConstraintI<ORRealReifyEqual>
-(ORRealReifyEqual*)initRealReify:(id<ORIntVar>)b equiv:(id<ORRealVar>)x eq:(id<ORRealVar>)c;
@end


@interface ORImplyEqualc : ORConstraintI<ORImplyEqualc>
-(ORImplyEqualc*)initImply:(id<ORIntVar>)b equiv:(id<ORIntVar>)x eqi:(ORInt)c;
@end

@interface ORReifyEqualc : ORConstraintI<ORReifyEqualc>
-(ORReifyEqualc*)initReify:(id<ORIntVar>)b equiv:(id<ORIntVar>)x eqi:(ORInt)c;
@end

@interface ORReifyNEqualc : ORConstraintI<ORReifyNEqualc>
-(ORReifyNEqualc*) initReify:(id<ORIntVar>)b equiv:(id<ORIntVar>)x neqi:(ORInt)c;
-(id<ORIntVar>) b;
-(id<ORIntVar>) x;
-(ORInt)        cst;
@end

@interface ORReifyEqual : ORConstraintI<ORReifyEqual>
-(ORReifyEqual*) initReify:(id<ORIntVar>)b equiv:(id<ORIntVar>)x eq:(id<ORIntVar>)y;
-(id<ORIntVar>) b;
-(id<ORIntVar>) x;
-(id<ORIntVar>) y;
@end

@interface ORReifyNEqual : ORConstraintI<ORReifyNEqual>
-(ORReifyNEqual*) initReify:(id<ORIntVar>)b equiv:(id<ORIntVar>)x neq:(id<ORIntVar>)y;
-(id<ORIntVar>) b;
-(id<ORIntVar>) x;
-(id<ORIntVar>) y;
@end

@interface ORReifyLEqualc : ORConstraintI<ORReifyLEqualc>
-(ORReifyLEqualc*) initReify:(id<ORIntVar>)b equiv:(id<ORIntVar>)x leqi:(ORInt)y;
-(id<ORIntVar>) b;
-(id<ORIntVar>) x;
-(ORInt)        cst;
@end

@interface ORReifyLEqual : ORConstraintI<ORReifyLEqual>
-(ORReifyLEqual*) initReify:(id<ORIntVar>)b equiv:(id<ORIntVar>)x leq:(id<ORIntVar>)y;
-(id<ORIntVar>) b;
-(id<ORIntVar>) x;
-(id<ORIntVar>) y;
@end

@interface ORReifyGEqualc : ORConstraintI<ORReifyGEqualc>
-(ORReifyGEqualc*) initReify:(id<ORIntVar>)b equiv:(id<ORIntVar>)x geqi:(ORInt)y;
-(id<ORIntVar>) b;
-(id<ORIntVar>) x;
-(ORInt)        cst;
@end

@interface ORReifyGEqual : ORConstraintI<ORReifyGEqual>
-(ORReifyGEqual*) initReify:(id<ORIntVar>)b equiv:(id<ORIntVar>)x geq:(id<ORIntVar>)y;
-(id<ORIntVar>) b;
-(id<ORIntVar>) x;
-(id<ORIntVar>) y;
@end

@interface ORClause : ORConstraintI<ORClause>
-(id) init:(id<ORIntVarArray>)ba eq:(id<ORIntVar>)c;
-(id<ORIntVarArray>)vars;
-(id<ORIntVar>)targetValue;
@end

@interface ORSumBoolEqc : ORConstraintI<ORSumBoolEqc>
-(ORSumBoolEqc*) initSumBool:(id<ORIntVarArray>)ba eqi:(ORInt)c;
-(id<ORIntVarArray>)vars;
-(ORInt)cst;
@end

@interface ORSumBoolNEqc : ORConstraintI<ORSumBoolNEqc>
-(ORSumBoolNEqc*) initSumBool:(id<ORIntVarArray>)ba neqi:(ORInt)c;
-(id<ORIntVarArray>)vars;
-(ORInt)cst;
@end

@interface ORSumBoolLEqc : ORConstraintI<ORSumBoolLEqc>
-(ORSumBoolLEqc*)initSumBool:(id<ORIntVarArray>)ba leqi:(ORInt)c;
-(id<ORIntVarArray>)vars;
-(ORInt)cst;
@end

@interface ORSumBoolGEqc : ORConstraintI<ORSumBoolGEqc>
-(ORSumBoolGEqc*)initSumBool:(id<ORIntVarArray>)ba geqi:(ORInt)c;
-(id<ORIntVarArray>)vars;
-(ORInt)cst;
@end

@interface ORReifySumBoolEqc : ORConstraintI<ORReifySumBoolEqc>
-(ORSumBoolEqc*) init:(id<ORIntVar>)b array:(id<ORIntVarArray>)ba eqi:(ORInt)c;
-(id<ORIntVar>) b;
-(id<ORIntVarArray>)vars;
-(ORInt)cst;
@end

@interface ORReifySumBoolGEqc : ORConstraintI<ORReifySumBoolGEqc>
-(ORSumBoolEqc*) init:(id<ORIntVar>)b array:(id<ORIntVarArray>)ba geqi:(ORInt)c;
-(id<ORIntVar>) b;
-(id<ORIntVarArray>)vars;
-(ORInt)cst;
@end

@interface ORHReifySumBoolEqc : ORConstraintI<ORReifySumBoolEqc>
-(ORSumBoolEqc*) init:(id<ORIntVar>)b array:(id<ORIntVarArray>)ba eqi:(ORInt)c;
-(id<ORIntVar>) b;
-(id<ORIntVarArray>)vars;
-(ORInt)cst;
@end

@interface ORHReifySumBoolGEqc : ORConstraintI<ORReifySumBoolGEqc>
-(ORSumBoolEqc*) init:(id<ORIntVar>)b array:(id<ORIntVarArray>)ba geqi:(ORInt)c;
-(id<ORIntVar>) b;
-(id<ORIntVarArray>)vars;
-(ORInt)cst;
@end

@interface ORSumEqc : ORConstraintI<ORSumEqc>
-(ORSumEqc*)initSum:(id<ORIntVarArray>)ia eqi:(ORInt)c;
-(id<ORIntVarArray>)vars;
-(ORInt)cst;
@end

@interface ORSumLEqc : ORConstraintI<ORSumLEqc>
-(ORSumLEqc*)initSum:(id<ORIntVarArray>)ia leqi:(ORInt)c;
-(id<ORIntVarArray>)vars;
-(ORInt)cst;
@end

@interface ORSumGEqc : ORConstraintI<ORSumGEqc>
-(ORSumGEqc*)initSum:(id<ORIntVarArray>)ia geqi:(ORInt)c;
-(id<ORIntVarArray>)vars;
-(ORInt)cst;
@end

@interface ORLinearEq : ORConstraintI<ORLinearEq>
-(ORLinearEq*) initLinearEq: (id<ORIntVarArray>) ia coef: (id<ORIntArray>) ca cst: (ORInt) c;
-(id<ORIntVarArray>) vars;
-(id<ORIntArray>) coefs;
-(ORInt) cst;
@end

@interface ORLinearLeq : ORConstraintI<ORLinearLeq>
-(id) initLinearLeq: (id<ORIntVarArray>) ia coef: (id<ORIntArray>) ca cst: (ORInt)c;
-(id<ORIntVarArray>) vars;
-(id<ORIntArray>) coefs;
-(ORInt) cst;
@end

@interface ORLinearGeq : ORConstraintI<ORLinearGeq>
-(id) initLinearGeq: (id<ORIntVarArray>) ia coef: (id<ORIntArray>) ca cst: (ORInt)c;
-(id<ORIntVarArray>) vars;
-(id<ORIntArray>) coefs;
-(ORInt) cst;
@end

@interface ORFloatAssignC : ORConstraintI<ORFloatAssignC>
-(id) initORFloatAssignC: (id<ORVar>) var to: (ORFloat) c;
-(id<ORFloatVar>) left;
-(ORFloat) cst;
@end


@interface ORFloatAssign : ORConstraintI<ORFloatAssign>
-(id) initORFloatAssign: (id<ORVar>) x to: (id<ORVar>) y;
-(id<ORFloatVar>) left;
-(id<ORFloatVar>) right;
@end

@interface ORFloatLinearEq : ORConstraintI<ORFloatLinearEq>
-(id) initFloatLinearEq: (id<ORVarArray>) ia coef: (id<ORFloatArray>) ca cst: (ORFloat) c;
-(id<ORVarArray>) vars;
-(id<ORFloatArray>) coefs;
-(ORFloat) cst;
@end

@interface ORFloatLinearLT : ORConstraintI<ORFloatLinearLT>
-(id) initFloatLinearLT: (id<ORVarArray>) ia coef: (id<ORFloatArray>) ca cst: (ORFloat) c;
-(id<ORVarArray>) vars;
-(id<ORFloatArray>) coefs;
-(ORFloat) cst;
@end

@interface ORFloatLinearGT : ORConstraintI<ORFloatLinearGT>
-(id) initFloatLinearGT: (id<ORVarArray>) ia coef: (id<ORFloatArray>) ca cst: (ORFloat) c;
-(id<ORVarArray>) vars;
-(id<ORFloatArray>) coefs;
-(ORFloat) cst;
@end

@interface ORFloatLinearLEQ : ORConstraintI<ORFloatLinearLEQ>
-(id) initFloatLinearLEQ: (id<ORVarArray>) ia coef: (id<ORFloatArray>) ca cst: (ORFloat) c;
-(id<ORVarArray>) vars;
-(id<ORFloatArray>) coefs;
-(ORFloat) cst;
@end

@interface ORFloatLinearGEQ : ORConstraintI<ORFloatLinearGEQ>
-(id) initFloatLinearGEQ: (id<ORVarArray>) ia coef: (id<ORFloatArray>) ca cst: (ORFloat) c;
-(id<ORVarArray>) vars;
-(id<ORFloatArray>) coefs;
-(ORFloat) cst;
@end

@interface ORFloatLinearNEq : ORConstraintI<ORFloatLinearNEq>
-(id) initFloatLinearNEq: (id<ORVarArray>) ia coef: (id<ORFloatArray>) ca cst: (ORFloat) c;
-(id<ORVarArray>) vars;
-(id<ORFloatArray>) coefs;
-(ORFloat) cst;
@end

@interface ORFloatUnaryMinus : ORConstraintI<ORFloatUnaryMinus>
-(ORFloatUnaryMinus*)initORFloatUnaryMinus:(id<ORVar>)x eqm:(id<ORVar>)y;
-(id<ORVar>) left;
-(id<ORVar>) right;
@end


@interface ORFloatMult : ORConstraintI<ORFloatMult>
-(ORFloatMult*)initORFloatMult:(id<ORVar>)x eq:(id<ORVar>)y times:(id<ORVar>)z;
-(id<ORVar>) res;
-(id<ORVar>) left;
-(id<ORVar>) right;
@end

@interface ORFloatDiv : ORConstraintI<ORFloatDiv>
-(ORFloatDiv*)initORFloatDiv:(id<ORVar>)x eq:(id<ORVar>)y times:(id<ORVar>)z;
-(id<ORVar>) res;
-(id<ORVar>) left;
-(id<ORVar>) right;
@end


@interface ORFloatReifyEqualc : ORConstraintI<ORFloatReifyEqualc>
-(ORFloatReifyEqualc*)initFloatReify:(id<ORIntVar>)b equiv:(id<ORFloatVar>)x eqi:(ORFloat)c;
@end

@interface ORFloatReifyNEqualc : ORConstraintI<ORFloatReifyNEqualc>
-(ORFloatReifyNEqualc*) initFloatReify:(id<ORIntVar>)b equiv:(id<ORFloatVar>)x neqi:(ORFloat)c;
-(id<ORIntVar>) b;
-(id<ORFloatVar>) x;
-(ORFloat)        cst;
@end

@interface ORFloatReifyEqual : ORConstraintI<ORFloatReifyEqual>
-(ORFloatReifyEqual*) initFloatReify:(id<ORIntVar>)b equiv:(id<ORFloatVar>)x eq:(id<ORFloatVar>)y;
-(id<ORIntVar>) b;
-(id<ORFloatVar>) x;
-(id<ORFloatVar>) y;
@end

@interface ORFloatReifyNEqual : ORConstraintI<ORFloatReifyNEqual>
-(ORFloatReifyNEqual*) initFloatReify:(id<ORIntVar>)b equiv:(id<ORFloatVar>)x neq:(id<ORFloatVar>)y;
-(id<ORIntVar>) b;
-(id<ORFloatVar>) x;
-(id<ORFloatVar>) y;
@end

@interface ORFloatReifyLEqualc : ORConstraintI<ORFloatReifyLEqualc>
-(ORFloatReifyLEqualc*) initFloatReify:(id<ORIntVar>)b equiv:(id<ORFloatVar>)x leqi:(ORFloat)y;
-(id<ORIntVar>) b;
-(id<ORFloatVar>) x;
-(ORFloat)        cst;
@end

@interface ORFloatReifyLEqual : ORConstraintI<ORFloatReifyLEqual>
-(ORFloatReifyLEqual*) initFloatReify:(id<ORIntVar>)b equiv:(id<ORFloatVar>)x leq:(id<ORFloatVar>)y;
-(id<ORIntVar>) b;
-(id<ORFloatVar>) x;
-(id<ORFloatVar>) y;
@end

@interface ORFloatReifyLThen : ORConstraintI<ORFloatReifyLThen>
-(ORFloatReifyLThen*) initFloatReify:(id<ORIntVar>)b equiv:(id<ORFloatVar>)x lt:(id<ORFloatVar>)y;
-(id<ORIntVar>) b;
-(id<ORFloatVar>) x;
-(id<ORFloatVar>) y;
@end

@interface ORFloatReifyLThenc : ORConstraintI<ORFloatReifyLThenc>
-(ORFloatReifyLThenc*) initFloatReify:(id<ORIntVar>)b equiv:(id<ORFloatVar>)x lti:(ORFloat)y;
-(id<ORIntVar>) b;
-(id<ORFloatVar>) x;
-(ORFloat)        cst;
@end

@interface ORFloatReifyGEqualc : ORConstraintI<ORFloatReifyGEqualc>
-(ORFloatReifyGEqualc*) initFloatReify:(id<ORIntVar>)b equiv:(id<ORFloatVar>)x geqi:(ORFloat)y;
-(id<ORIntVar>) b;
-(id<ORFloatVar>) x;
-(ORFloat)        cst;
@end

@interface ORFloatReifyGEqual : ORConstraintI<ORFloatReifyGEqual>
-(ORFloatReifyGEqual*) initFloatReify:(id<ORIntVar>)b equiv:(id<ORFloatVar>)x geq:(id<ORFloatVar>)y;
-(id<ORIntVar>) b;
-(id<ORFloatVar>) x;
-(id<ORFloatVar>) y;
@end

@interface ORFloatReifyGThenc : ORConstraintI<ORFloatReifyGThenc>
-(ORFloatReifyGThenc*) initFloatReify:(id<ORIntVar>)b equiv:(id<ORFloatVar>)x gti:(ORFloat)y;
-(id<ORIntVar>) b;
-(id<ORFloatVar>) x;
-(ORFloat)        cst;
@end

@interface ORFloatReifyGThen : ORConstraintI<ORFloatReifyGThen>
-(ORFloatReifyGThen*) initFloatReify:(id<ORIntVar>)b equiv:(id<ORFloatVar>)x gt:(id<ORFloatVar>)y;
-(id<ORIntVar>) b;
-(id<ORFloatVar>) x;
-(id<ORFloatVar>) y;
@end

//------


@interface ORDoubleAssignC : ORConstraintI<ORDoubleAssignC>
-(id) initORDoubleAssignC: (id<ORVar>) var to: (ORDouble) c;
-(id<ORDoubleVar>) left;
-(ORDouble) cst;
@end


@interface ORDoubleAssign : ORConstraintI<ORDoubleAssign>
-(id) initORDoubleAssign: (id<ORVar>) x to: (id<ORVar>) y;
-(id<ORDoubleVar>) left;
-(id<ORDoubleVar>) right;
@end

@interface ORDoubleReifyEqualc : ORConstraintI<ORDoubleReifyEqualc>
-(ORDoubleReifyEqualc*) initDoubleReify:(id<ORIntVar>)b equiv:(id<ORDoubleVar>)x eqi:(ORDouble)c;
@end

@interface ORDoubleReifyNEqualc : ORConstraintI<ORDoubleReifyNEqualc>
-(ORDoubleReifyNEqualc*) initDoubleReify:(id<ORIntVar>)b equiv:(id<ORDoubleVar>)x neqi:(ORDouble)c;
-(id<ORIntVar>) b;
-(id<ORDoubleVar>) x;
-(ORDouble)        cst;
@end

@interface ORDoubleReifyEqual : ORConstraintI<ORDoubleReifyEqual>
-(ORDoubleReifyEqual*) initDoubleReify:(id<ORIntVar>)b equiv:(id<ORDoubleVar>)x eq:(id<ORDoubleVar>)y;
-(id<ORIntVar>) b;
-(id<ORDoubleVar>) x;
-(id<ORDoubleVar>) y;
@end

@interface ORDoubleReifyNEqual : ORConstraintI<ORDoubleReifyNEqual>
-(ORDoubleReifyNEqual*) initDoubleReify:(id<ORIntVar>)b equiv:(id<ORDoubleVar>)x neq:(id<ORDoubleVar>)y;
-(id<ORIntVar>) b;
-(id<ORDoubleVar>) x;
-(id<ORDoubleVar>) y;
@end

@interface ORDoubleReifyLEqualc : ORConstraintI<ORDoubleReifyLEqualc>
-(ORDoubleReifyLEqualc*) initDoubleReify:(id<ORIntVar>)b equiv:(id<ORDoubleVar>)x leqi:(ORDouble)y;
-(id<ORIntVar>) b;
-(id<ORDoubleVar>) x;
-(ORDouble)        cst;
@end

@interface ORDoubleReifyLEqual : ORConstraintI<ORDoubleReifyLEqual>
-(ORDoubleReifyLEqual*) initDoubleReify:(id<ORIntVar>)b equiv:(id<ORDoubleVar>)x leq:(id<ORDoubleVar>)y;
-(id<ORIntVar>) b;
-(id<ORDoubleVar>) x;
-(id<ORDoubleVar>) y;
@end

@interface ORDoubleReifyLThen : ORConstraintI<ORDoubleReifyLThen>
-(ORDoubleReifyLThen*) initDoubleReify:(id<ORIntVar>)b equiv:(id<ORDoubleVar>)x lt:(id<ORDoubleVar>)y;
-(id<ORIntVar>) b;
-(id<ORDoubleVar>) x;
-(id<ORDoubleVar>) y;
@end

@interface ORDoubleReifyLThenc : ORConstraintI<ORDoubleReifyLThenc>
-(ORDoubleReifyLThenc*) initDoubleReify:(id<ORIntVar>)b equiv:(id<ORDoubleVar>)x lti:(ORDouble)y;
-(id<ORIntVar>) b;
-(id<ORDoubleVar>) x;
-(ORDouble)        cst;
@end

@interface ORDoubleReifyGEqualc : ORConstraintI<ORDoubleReifyGEqualc>
-(ORDoubleReifyGEqualc*) initDoubleReify:(id<ORIntVar>)b equiv:(id<ORDoubleVar>)x geqi:(ORDouble)y;
-(id<ORIntVar>) b;
-(id<ORDoubleVar>) x;
-(ORDouble)        cst;
@end

@interface ORDoubleReifyGEqual : ORConstraintI<ORDoubleReifyGEqual>
-(ORDoubleReifyGEqual*) initDoubleReify:(id<ORIntVar>)b equiv:(id<ORDoubleVar>)x geq:(id<ORDoubleVar>)y;
-(id<ORIntVar>) b;
-(id<ORDoubleVar>) x;
-(id<ORDoubleVar>) y;
@end

@interface ORDoubleReifyGThenc : ORConstraintI<ORDoubleReifyGThenc>
-(ORDoubleReifyGThenc*) initDoubleReify:(id<ORIntVar>)b equiv:(id<ORDoubleVar>)x gti:(ORDouble)y;
-(id<ORIntVar>) b;
-(id<ORDoubleVar>) x;
-(ORDouble)   cst;
@end

@interface ORDoubleReifyGThen : ORConstraintI<ORDoubleReifyGThen>
-(ORDoubleReifyGThen*) initDoubleReify:(id<ORIntVar>)b equiv:(id<ORDoubleVar>)x gt:(id<ORDoubleVar>)y;
-(id<ORIntVar>) b;
-(id<ORDoubleVar>) x;
-(id<ORDoubleVar>) y;
@end
//--------

@interface ORDoubleLinearEq : ORConstraintI<ORDoubleLinearEq>
-(id) initDoubleLinearEq: (id<ORVarArray>) ia coef: (id<ORDoubleArray>) ca cst: (ORDouble) c;
-(id<ORVarArray>) vars;
-(id<ORDoubleArray>) coefs;
-(ORDouble) cst;
@end

@interface ORDoubleLinearLT : ORConstraintI<ORDoubleLinearLT>
-(id) initDoubleLinearLT: (id<ORVarArray>) ia coef: (id<ORDoubleArray>) ca cst: (ORDouble) c;
-(id<ORVarArray>) vars;
-(id<ORDoubleArray>) coefs;
-(ORDouble) cst;
@end

@interface ORDoubleLinearGT : ORConstraintI<ORDoubleLinearGT>
-(id) initDoubleLinearGT: (id<ORVarArray>) ia coef: (id<ORDoubleArray>) ca cst: (ORDouble) c;
-(id<ORVarArray>) vars;
-(id<ORDoubleArray>) coefs;
-(ORDouble) cst;
@end

@interface ORDoubleLinearLEQ : ORConstraintI<ORDoubleLinearLEQ>
-(id) initDoubleLinearLEQ: (id<ORVarArray>) ia coef: (id<ORDoubleArray>) ca cst: (ORDouble) c;
-(id<ORVarArray>) vars;
-(id<ORDoubleArray>) coefs;
-(ORDouble) cst;
@end

@interface ORDoubleLinearGEQ : ORConstraintI<ORDoubleLinearGEQ>
-(id) initDoubleLinearGEQ: (id<ORVarArray>) ia coef: (id<ORDoubleArray>) ca cst: (ORDouble) c;
-(id<ORVarArray>) vars;
-(id<ORDoubleArray>) coefs;
-(ORDouble) cst;
@end


@interface ORDoubleLinearNEq : ORConstraintI<ORDoubleLinearNEq>
-(id) initDoubleLinearNEq: (id<ORVarArray>) ia coef: (id<ORDoubleArray>) ca cst: (ORDouble) c;
-(id<ORVarArray>) vars;
-(id<ORDoubleArray>) coefs;
-(ORDouble) cst;
@end

@interface ORDoubleMult : ORConstraintI<ORDoubleMult>
-(ORDoubleMult*)initORDoubleMult:(id<ORVar>)x eq:(id<ORVar>)y times:(id<ORVar>)z;
-(id<ORVar>) res;
-(id<ORVar>) left;
-(id<ORVar>) right;
@end

@interface ORDoubleDiv : ORConstraintI<ORDoubleDiv>
-(ORDoubleDiv*)initORDoubleDiv:(id<ORVar>)x eq:(id<ORVar>)y times:(id<ORVar>)z;
-(id<ORVar>) res;
-(id<ORVar>) left;
-(id<ORVar>) right;
@end

@interface ORRealLinearEq : ORConstraintI<ORRealLinearEq>
-(id) initRealLinearEq: (id<ORVarArray>) ia coef: (id<ORDoubleArray>) ca cst: (ORDouble) c;
-(id<ORVarArray>) vars;
-(id<ORDoubleArray>) coefs;
-(ORDouble) cst;
@end

@interface ORRealLinearLeq : ORConstraintI<ORRealLinearLeq>
-(id) initRealLinearLeq: (id<ORVarArray>) ia coef: (id<ORDoubleArray>) ca cst: (ORDouble) c;
-(id<ORVarArray>) vars;
-(id<ORDoubleArray>) coefs;
-(ORDouble) cst;
@end

@interface ORRealLinearGeq : ORConstraintI<ORRealLinearGeq>
-(id) initRealLinearGeq: (id<ORVarArray>) ia coef: (id<ORDoubleArray>) ca cst: (ORDouble) c;
-(id<ORVarArray>) vars;
-(id<ORDoubleArray>) coefs;
-(ORDouble) cst;
@end

@interface ORAlldifferentI : ORConstraintI<ORAlldifferent>
-(ORAlldifferentI*) initORAlldifferentI: (id<ORExprArray>) x;
-(id<ORExprArray>) array;
@end

@interface ORRegularI : ORConstraintI<ORRegular>
-(id)init:(id<ORIntVarArray>)x  for:(id<ORAutomaton>)a;
-(id<ORIntVarArray>) array;
-(id<ORAutomaton>)automaton;
@end

@interface ORCardinalityI : ORConstraintI<ORCardinality>
-(ORCardinalityI*) initORCardinalityI: (id<ORIntVarArray>) x low: (id<ORIntArray>) low up: (id<ORIntArray>) up;
-(id<ORIntVarArray>) array;
-(id<ORIntArray>) low;
-(id<ORIntArray>) up;
@end;

@interface ORAlgebraicConstraintI : ORConstraintI<ORAlgebraicConstraint>
-(ORAlgebraicConstraintI*) initORAlgebraicConstraintI: (id<ORRelation>) expr;
-(id<ORRelation>) expr;
@end

@interface ORSoftAlgebraicConstraintI : ORAlgebraicConstraintI<ORSoftConstraint>
-(ORSoftAlgebraicConstraintI*) initORSoftAlgebraicConstraintI: (id<ORRelation>) expr slack: (id<ORVar>)slack;
-(id<ORVar>) slack;
@end

@interface ORRealWeightedVarI : ORConstraintI<ORWeightedVar>
-(ORRealWeightedVarI*) initRealWeightedVar: (id<ORVar>)x;
-(id<ORVar>) z;
-(id<ORVar>)x;
-(id<ORParameter>)weight;
@end

@interface ORTableConstraintI : ORConstraintI<ORTableConstraint>
-(ORTableConstraintI*) initORTableConstraintI: (id<ORIntVarArray>) x table: (id<ORTable>) table;
-(id<ORIntVarArray>) array;
-(id<ORTable>) table;
@end

@interface ORLexLeq : ORConstraintI<ORLexLeq>
-(ORLexLeq*)initORLex:(id<ORIntVarArray>)x leq:(id<ORIntVarArray>)y;
-(id<ORIntVarArray>)x;
-(id<ORIntVarArray>)y;
@end

@interface ORCircuit : ORConstraintI<ORCircuit>
-(ORCircuit*)initORCircuit:(id<ORIntVarArray>)x;
-(id<ORIntVarArray>) array;
@end

@interface ORPath : ORConstraintI<ORPath>
-(ORPath*)initORPath:(id<ORIntVarArray>)x;
-(id<ORIntVarArray>) array;
@end

@interface ORSubCircuit : ORConstraintI<ORSubCircuit>
-(ORSubCircuit*)initORSubCircuit:(id<ORIntVarArray>)x;
-(id<ORIntVarArray>) array;
@end

@interface ORNoCycleI : ORConstraintI<ORNoCycle>
-(ORNoCycleI*)initORNoCycleI:(id<ORIntVarArray>)x;
-(id<ORIntVarArray>) array;
@end

@interface ORPackOneI : ORConstraintI<ORPackOne>
-(ORPackOneI*)initORPackOneI:(id<ORIntVarArray>) item itemSize: (id<ORIntArray>) itemSize bin: (ORInt) b binSize: (id<ORIntVar>) binSize;
-(id<ORIntVarArray>) item;
-(id<ORIntArray>) itemSize;
-(ORInt) bin;
-(id<ORIntVar>) binSize;
@end

@interface ORPackingI : ORConstraintI<ORPacking>
-(ORPackingI*)initORPackingI:(id<ORIntVarArray>) x itemSize: (id<ORIntArray>) itemSize load: (id<ORIntVarArray>) load;
-(id<ORIntVarArray>) item;
-(id<ORIntArray>) itemSize;
-(id<ORIntVarArray>) binSize;
@end

@interface ORMultiKnapsackI : ORConstraintI<ORMultiKnapsack>
-(ORMultiKnapsackI*)initORMultiKnapsackI:(id<ORIntVarArray>) x itemSize: (id<ORIntArray>) itemSize capacity: (id<ORIntArray>) cap;
-(id<ORIntVarArray>) item;
-(id<ORIntArray>) itemSize;
-(id<ORIntArray>) capacity;
@end

@interface ORMultiKnapsackOneI : ORConstraintI<ORMultiKnapsackOne>
-(ORMultiKnapsackOneI*)initORMultiKnapsackOneI:(id<ORIntVarArray>) x itemSize: (id<ORIntArray>) itemSize bin: (ORInt) b capacity: (ORInt) cap;
-(id<ORIntVarArray>) item;
-(id<ORIntArray>) itemSize;
-(ORInt) bin;
-(ORInt) capacity;
@end

@interface ORMeetAtmostI : ORConstraintI<ORMeetAtmost>
-(ORMeetAtmostI*)initORMeetAtmostI:(id<ORIntVarArray>) x and: (id<ORIntVarArray>) y atmost: (ORInt) k;
-(id<ORIntVarArray>) x;
-(id<ORIntVarArray>) y;
-(ORInt) atmost;
@end

@interface ORKnapsackI : ORConstraintI<ORKnapsack>
-(ORKnapsackI*)initORKnapsackI:(id<ORIntVarArray>) x weight:(id<ORIntArray>) w capacity:(id<ORIntVar>)c;
-(id<ORIntVarArray>) item;
-(id<ORIntArray>) weight;
-(id<ORIntVar>) capacity;
@end

@interface ORSoftKnapsackI : ORKnapsackI<ORSoftKnapsack>
-(ORSoftKnapsackI*)initORSoftKnapsackI:(id<ORIntVarArray>) x weight:(id<ORIntArray>) w capacity:(id<ORIntVar>)c slack: (id<ORVar>)slack;
-(id<ORVar>)slack;
@end

@interface ORAssignmentI: ORConstraintI<ORAssignment>
-(ORAssignmentI*)initORAssignment:(id<ORIntVarArray>) x matrix: (id<ORIntMatrix>) matrix cost: (id<ORIntVar>) cost;
-(id<ORIntVarArray>) x;
-(id<ORIntMatrix>) matrix;
-(id<ORIntVar>) cost;
@end

@interface ORObjectiveValueIntI : ORObject<ORObjectiveValueInt> {
   ORInt _value;
   ORInt _direction;
   ORInt _pBound;
}
-(id) initObjectiveValueIntI: (ORInt) pb minimize: (ORBool) b ;
-(ORInt)value;
-(ORInt)intValue;
-(ORDouble)doubleValue;
-(ORInt)primal;
-(ORDouble)key;
-(NSString*)description;
@end

@interface ORObjectiveValueRealI : ORObject<ORObjectiveValueReal> {
   ORDouble _value;
   ORInt _direction;
   ORInt _pBound;
}
-(id) initObjectiveValueRealI: (ORDouble) pb minimize: (ORBool) b ;
-(ORDouble)value;
-(ORDouble)doubleValue;
-(ORDouble)primal;
-(ORDouble)key;
-(NSString*)description;
@end


@interface ORObjectiveFunctionI : ORObject<ORObjectiveFunction>
-(ORObjectiveFunctionI*) initORObjectiveFunctionI;
@end

@interface ORObjectiveFunctionVarI : ORObjectiveFunctionI<ORObjectiveFunctionVar>
{
   id<ORVar>             _var;
}
-(ORObjectiveFunctionVarI*) initORObjectiveFunctionVarI: (id<ORVar>) x;
-(id<ORVar>) var;
-(id<ORObjectiveValue>) value;
-(void) visit: (ORVisitor*) visitor;
@end

@interface ORObjectiveFunctionLinearI : ORObjectiveFunctionI<ORObjectiveFunctionLinear>
{
   id<ORVarArray> _array;
   id<ORDoubleArray> _coef;
}
-(ORObjectiveFunctionLinearI*) initORObjectiveFunctionLinearI: (id<ORVarArray>) array coef: (id<ORDoubleArray>) coef;
-(id<ORVarArray>) array;
-(id<ORDoubleArray>) coef;
-(void) visit: (ORVisitor*) visitor;
@end

@interface ORObjectiveFunctionExprI : ORObjectiveFunctionI<ORObjectiveFunctionExpr>
{
   id<ORExpr> _expr;
}
-(ORObjectiveFunctionExprI*) initORObjectiveFunctionExprI: (id<ORExpr>) expr;
-(id<ORExpr>) expr;
-(void) visit: (ORVisitor*) visitor;
@end

@interface ORMinimizeVarI : ORObjectiveFunctionVarI<ORObjectiveFunctionVar>
-(ORMinimizeVarI*) initORMinimizeVarI: (id<ORVar>) x;
@end

@interface ORMaximizeVarI : ORObjectiveFunctionVarI<ORObjectiveFunctionVar>
-(ORMaximizeVarI*) initORMaximizeVarI: (id<ORVar>) x;
@end

@interface ORMinimizeExprI : ORObjectiveFunctionExprI<ORObjectiveFunctionExpr>
-(ORMinimizeExprI*) initORMinimizeExprI: (id<ORExpr>) e;
@end

@interface ORMaximizeExprI : ORObjectiveFunctionExprI<ORObjectiveFunctionExpr>
-(ORMaximizeExprI*) initORMaximizeExprI: (id<ORExpr>) e;
@end

@interface ORMinimizeLinearI : ORObjectiveFunctionLinearI<ORObjectiveFunctionLinear>
-(ORMinimizeLinearI*) initORMinimizeLinearI: (id<ORVarArray>) array coef: (id<ORDoubleArray>) coef;
@end

@interface ORMaximizeLinearI : ORObjectiveFunctionLinearI<ORObjectiveFunctionLinear>
-(ORMaximizeLinearI*) initORMaximizeLinearI: (id<ORVarArray>) array coef: (id<ORDoubleArray>) coef;
@end

@interface ORBitEqBool : ORConstraintI<ORBitEqBool>
-(ORBitEqBool*)init:(id<ORBitVar>)x eq:(id<ORIntVar>)bx;
-(id<ORBitVar>)x;
-(id<ORIntVar>)bx;
@end

@interface ORBitEqualAt : ORConstraintI<ORBitEqualAt>
-(ORBitEqualAt*)init:(id<ORBitVar>)x at:(ORInt)k with:(ORInt)c;
-(id<ORBitVar>)left;
-(ORInt)cst;
-(ORInt)bit;
@end

@interface ORBitEqualc : ORConstraintI<ORBitEqualc>
-(ORBitEqualc*)init:(id<ORBitVar>)x eqc:(ORInt)c;
-(id<ORBitVar>)left;
-(ORInt)cst;
@end

@interface ORBitEqual : ORConstraintI<ORBitEqual>
-(ORBitEqual*)initORBitEqual: (id<ORBitVar>) x eq: (id<ORBitVar>) y;
-(id<ORBitVar>) left;
-(id<ORBitVar>) right;
@end

@interface ORBitOr : ORConstraintI<ORBitOr>
-(ORBitOr*)initORBitOr: (id<ORBitVar>) x bor: (id<ORBitVar>) y eq:(id<ORBitVar>)z;
-(id<ORBitVar>) res;
-(id<ORBitVar>) left;
-(id<ORBitVar>) right;
@end

@interface ORBitAnd : ORConstraintI<ORBitAnd>
-(ORBitAnd*)initORBitAnd: (id<ORBitVar>) x band: (id<ORBitVar>) y eq:(id<ORBitVar>)z;
-(id<ORBitVar>) res;
-(id<ORBitVar>) left;
-(id<ORBitVar>) right;
@end

@interface ORBitNot : ORConstraintI<ORBitNot>
-(ORBitNot*)initORBitNot: (id<ORBitVar>) x bnot: (id<ORBitVar>) y;
-(id<ORBitVar>) left;
-(id<ORBitVar>) right;
@end

@interface ORBitXor : ORConstraintI<ORBitXor>
-(ORBitXor*)initORBitXor: (id<ORBitVar>) x bxor: (id<ORBitVar>) y eq:(id<ORBitVar>)z;
-(id<ORBitVar>) res;
-(id<ORBitVar>) left;
-(id<ORBitVar>) right;
@end

@interface ORBitShiftL : ORConstraintI<ORBitShiftL>
-(ORBitShiftL*)initORBitShiftL: (id<ORBitVar>) x by:(ORInt)p eq: (id<ORBitVar>) y;
-(ORInt) places;
-(id<ORBitVar>) left;
-(id<ORBitVar>) right;
@end

@interface ORBitShiftL_BV : ORConstraintI<ORBitShiftL_BV>
-(ORBitShiftL_BV*)initORBitShiftL_BV: (id<ORBitVar>) x by:(id<ORBitVar>)p eq: (id<ORBitVar>) y;
-(id<ORBitVar>) places;
-(id<ORBitVar>) left;
-(id<ORBitVar>) right;
@end

@interface ORBitShiftR : ORConstraintI<ORBitShiftR>
-(ORBitShiftR*)initORBitShiftR: (id<ORBitVar>) x by:(ORInt)p eq: (id<ORBitVar>) y;
-(ORInt) places;
-(id<ORBitVar>) left;
-(id<ORBitVar>) right;
@end

@interface ORBitShiftR_BV : ORConstraintI<ORBitShiftR_BV>
-(ORBitShiftR_BV*)initORBitShiftR_BV: (id<ORBitVar>) x by:(id<ORBitVar>)p eq: (id<ORBitVar>) y;
-(id<ORBitVar>) places;
-(id<ORBitVar>) left;
-(id<ORBitVar>) right;
@end

@interface ORBitShiftRA : ORConstraintI<ORBitShiftRA>
-(ORBitShiftRA*)initORBitShiftRA: (id<ORBitVar>) x by:(ORInt)p eq: (id<ORBitVar>) y;
-(ORInt) places;
-(id<ORBitVar>) left;
-(id<ORBitVar>) right;
@end

@interface ORBitShiftRA_BV : ORConstraintI<ORBitShiftRA_BV>
-(ORBitShiftRA_BV*)initORBitShiftRA_BV: (id<ORBitVar>) x by:(id<ORBitVar>)p eq: (id<ORBitVar>) y;
-(id<ORBitVar>) places;
-(id<ORBitVar>) left;
-(id<ORBitVar>) right;
@end

@interface ORBitRotateL : ORConstraintI<ORBitRotateL>
-(ORBitRotateL*)initORBitRotateL: (id<ORBitVar>) x by:(ORInt)p eq: (id<ORBitVar>) y;
-(ORInt) places;
-(id<ORBitVar>) left;
-(id<ORBitVar>) right;
@end

@interface ORBitNegative : ORConstraintI<ORBitNegative>
-(ORBitNegative*)initORBitNegative: (id<ORBitVar>) x eq:(id<ORBitVar>)y;
-(id<ORBitVar>) left;
-(id<ORBitVar>) res;
@end

@interface ORBitSum : ORConstraintI<ORBitSum>
-(ORBitSum*)initORBitSum: (id<ORBitVar>) x plus:(id<ORBitVar>) y in:(id<ORBitVar>)ci eq:(id<ORBitVar>)z out:(id<ORBitVar>)co;
-(id<ORBitVar>) left;
-(id<ORBitVar>) right;
-(id<ORBitVar>) res;
-(id<ORBitVar>) in;
-(id<ORBitVar>) out;
@end

@interface ORBitSubtract : ORConstraintI<ORBitSubtract>
-(ORBitSubtract*)initORBitSubtract: (id<ORBitVar>) x minus:(id<ORBitVar>) y eq:(id<ORBitVar>)z;
-(id<ORBitVar>) left;
-(id<ORBitVar>) right;
-(id<ORBitVar>) res;
@end

@interface ORBitMultiply : ORConstraintI<ORBitMultiply>
-(ORBitMultiply*)initORBitMultiply: (id<ORBitVar>) x times:(id<ORBitVar>) y eq:(id<ORBitVar>)z;
-(id<ORBitVar>) left;
-(id<ORBitVar>) right;
-(id<ORBitVar>) res;
@end

@interface ORBitDivide: ORConstraintI<ORBitDivide>
-(ORBitDivide*)initORBitDivide: (id<ORBitVar>) x dividedby:(id<ORBitVar>) y eq:(id<ORBitVar>)z rem:(id<ORBitVar>)r;
-(id<ORBitVar>) left;
-(id<ORBitVar>) right;
-(id<ORBitVar>) res;
-(id<ORBitVar>) rem;
@end

@interface ORBitIf : ORConstraintI<ORBitIf>
-(ORBitIf*)initORBitIf: (id<ORBitVar>) w trueIf:(id<ORBitVar>) x equals:(id<ORBitVar>)y zeroIfXEquals:(id<ORBitVar>)z;
-(id<ORBitVar>) res;
-(id<ORBitVar>) trueIf;
-(id<ORBitVar>) equals;
-(id<ORBitVar>) zeroIfXEquals;
@end

@interface ORBitCount : ORConstraintI<ORBitCount>
-(ORBitCount*)initORBitCount: (id<ORBitVar>) x count:(id<ORIntVar>)p;
-(id<ORBitVar>) left;
-(id<ORIntVar>) right;
@end

@interface ORBitChannel: ORConstraintI<ORBitChannel>
-(ORBitCount*)init: (id<ORBitVar>) x channel:(id<ORIntVar>)p;
-(id<ORBitVar>) left;
-(id<ORIntVar>) right;
@end

@interface ORBitZeroExtend : ORConstraintI<ORBitZeroExtend>
-(ORBitZeroExtend*)initORBitZeroExtend: (id<ORBitVar>) x extendTo: (id<ORBitVar>) y;
-(id<ORBitVar>) left;
-(id<ORBitVar>) right;
@end

@interface ORBitSignExtend : ORConstraintI<ORBitSignExtend>
-(ORBitSignExtend*)initORBitSignExtend: (id<ORBitVar>) x extendTo: (id<ORBitVar>) y;
-(id<ORBitVar>) left;
-(id<ORBitVar>) right;
@end

@interface ORBitConcat : ORConstraintI<ORBitConcat>
-(ORBitConcat*)initORBitConcat: (id<ORBitVar>) x concat: (id<ORBitVar>) y eq:(id<ORBitVar>)z;
-(id<ORBitVar>) res;
-(id<ORBitVar>) left;
-(id<ORBitVar>) right;
@end

@interface ORBitExtract : ORConstraintI<ORBitExtract>
-(ORBitExtract*)initORBitExtract: (id<ORBitVar>) x from:(ORUInt)lsb to:(ORUInt)msb eq:(id<ORBitVar>)y;
-(id<ORBitVar>) left;
-(ORUInt) lsb;
-(ORUInt) msb;
-(id<ORBitVar>) right;
@end

@interface ORBitLogicalEqual : ORConstraintI<ORBitLogicalEqual>
-(ORBitLogicalEqual*)initORBitLogicalEqual:(id<ORBitVar>)x EQ:(id<ORBitVar>)y eval:(id<ORBitVar>)z;
-(id<ORBitVar>) res;
-(id<ORBitVar>) left;
-(id<ORBitVar>) right;
@end

@interface ORBitLT : ORConstraintI<ORBitLT>
-(ORBitLT*)initORBitLT:(id<ORBitVar>)x LT:(id<ORBitVar>)y eval:(id<ORBitVar>)z;
-(id<ORBitVar>) res;
-(id<ORBitVar>) left;
-(id<ORBitVar>) right;
@end

@interface ORBitLE : ORConstraintI<ORBitLE>
-(ORBitLE*)initORBitLE:(id<ORBitVar>)x LE:(id<ORBitVar>)y eval:(id<ORBitVar>)z;
-(id<ORBitVar>) res;
-(id<ORBitVar>) left;
-(id<ORBitVar>) right;
@end

@interface ORBitSLE : ORConstraintI<ORBitSLE>
-(ORBitSLE*)initORBitSLE:(id<ORBitVar>)x SLE:(id<ORBitVar>)y eval:(id<ORBitVar>)z;
-(id<ORBitVar>) res;
-(id<ORBitVar>) left;
-(id<ORBitVar>) right;
@end

@interface ORBitSLT : ORConstraintI<ORBitSLT>
-(ORBitSLT*)initORBitSLT:(id<ORBitVar>)x SLT:(id<ORBitVar>)y eval:(id<ORBitVar>)z;
-(id<ORBitVar>) res;
-(id<ORBitVar>) left;
-(id<ORBitVar>) right;
@end

@interface ORBitITE : ORConstraintI<ORBitITE>
-(ORBitITE*)initORBitITE:(id<ORBitVar>)i then:(id<ORBitVar>)t else:(id<ORBitVar>)e result:(id<ORBitVar>)r;
-(id<ORBitVar>) res;
-(id<ORBitVar>) left;
-(id<ORBitVar>) right1;
-(id<ORBitVar>) right2;
@end
@interface ORBitLogicalAnd : ORConstraintI<ORBitLogicalAnd>
-(ORBitLogicalAnd*)initORBitLogicalAnd:(id<ORBitVarArray>)x eval:(id<ORBitVar>)r;
-(id<ORBitVar>) res;
-(id<ORBitVarArray>) left;
@end

@interface ORBitLogicalOr : ORConstraintI<ORBitLogicalOr>
-(ORBitLogicalOr*)initORBitLogicalOr:(id<ORBitVarArray>)x eval:(id<ORBitVar>)r;
-(id<ORBitVar>) res;
-(id<ORBitVarArray>) left;
@end

@interface ORBitOrb : ORConstraintI<ORBitOrb>
-(ORBitOrb*)initORBitOrb: (id<ORBitVar>) x bor: (id<ORBitVar>) y eval:(id<ORBitVar>)r;
-(id<ORBitVar>) res;
-(id<ORBitVar>) left;
-(id<ORBitVar>) right;
@end

@interface ORBitNotb : ORConstraintI<ORBitNotb>
-(ORBitNotb*)initORBitNotb: (id<ORBitVar>) x eval:(id<ORBitVar>)r;
-(id<ORBitVar>) res;
-(id<ORBitVar>) left;
@end

@interface ORBitEqualb : ORConstraintI<ORBitEqualb>
-(ORBitEqualb*)initORBitEqualb: (id<ORBitVar>) x equal: (id<ORBitVar>) y eval:(id<ORBitVar>)r;
-(id<ORBitVar>) res;
-(id<ORBitVar>) left;
-(id<ORBitVar>) right;
@end

@interface ORBitDistinct : ORConstraintI<ORBitDistinct>
-(ORBitDistinct*)initORBitDistinct: (id<ORBitVar>) x distinctFrom: (id<ORBitVar>) y eval:(id<ORBitVar>)r;
-(id<ORBitVar>) res;
-(id<ORBitVar>) left;
-(id<ORBitVar>) right;
@end
