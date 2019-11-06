/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <Foundation/Foundation.h>
#import <CPUKernel/CPUKernel.h>
#import <CPUKernel/CPConstraintI.h>
#import <objcp/CPVar.h>
#import <objcp/CPFloatDom.h>


@class CPFloatVarI;
@class CPDoubleVarI;


@interface CPFloatCast : CPCoreConstraint<CPArithmConstraint> {
   CPFloatVarI* _res;
   CPDoubleVarI* _initial;
}
-(id) init:(id)x equals:(id)y  rewrite:(ORBool) rewrite;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

//unary minus constraint
@interface CPFloatUnaryMinus : CPCoreConstraint<CPArithmConstraint> {
   CPFloatVarI* _x;
   CPFloatVarI* _y;
}
-(id) init:(id)x eqm:(id)y  rewrite:(ORBool) rewrite;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPFloatEqual : CPCoreConstraint {
    CPFloatVarI* _x;
    CPFloatVarI* _y;
}
-(id) init:(id)x equals:(id)y  rewrite:(ORBool) rewrite;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPFloatEqualc : CPCoreConstraint {
    CPFloatVarI* _x;
    ORFloat      _c;
}
-(id) init:(id)x and:(ORFloat)c;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPFloatAssign : CPCoreConstraint<CPArithmConstraint> {
   CPFloatVarI* _x;
   CPFloatVarI* _y;
}
-(id) init:(id)x set:(id)y;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPFloatAssignC : CPCoreConstraint<CPArithmConstraint> {
   CPFloatVarI* _x;
   ORFloat      _c;
}
-(id) init:(id)x set:(ORFloat)c;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPFloatNEqual : CPCoreConstraint {
    CPFloatVarI* _x;
    CPFloatVarI* _y;
}
-(id) init:(id)x nequals:(id)y;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPFloatNEqualc : CPCoreConstraint {
    CPFloatVarI* _x;
    ORFloat      _c;
}
-(id) init:(id)x and:(ORFloat)c;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPFloatLT : CPCoreConstraint {
    CPFloatVarI* _x;
    CPFloatVarI* _y;
}
-(id) init:(id)x lt:(id)y;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPFloatGT : CPCoreConstraint {
    CPFloatVarI* _x;
    CPFloatVarI* _y;
}
-(id) init:(id)x gt:(id)y;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end


@interface CPFloatLEQ : CPCoreConstraint {
    CPFloatVarI* _x;
    CPFloatVarI* _y;
}
-(id) init:(id)x leq:(id)y;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPFloatGEQ : CPCoreConstraint {
    CPFloatVarI* _x;
    CPFloatVarI* _y;
}
-(id) init:(id)x geq:(id)y;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end


@interface CPFloatTernaryAdd : CPCoreConstraint<CPABSConstraint,CPArithmConstraint> { // z = x + y
    CPFloatVarI* _z;
    CPFloatVarI* _x;
    CPFloatVarI* _y;
    ORInt _precision;
    ORDouble _percent;
    ORInt _rounding;
}
-(id) init:(id)z equals:(id)x plus:(id)y ;
-(id) init:(id)z equals:(id)x plus:(id)y rewrite:(ORBool)f;
-(id) init:(id)z equals:(id)x plus:(id)y kbpercent:(ORDouble)p;
-(id) init:(id)z equals:(id)x plus:(id)y kbpercent:(ORDouble)p rewrite:(ORBool) f;
-(void) post;
-(NSSet*)allVars;
-(ORBool) canLeadToAnAbsorption;
-(id<CPFloatVar>) varSubjectToAbsorption:(id<CPFloatVar>)x;
-(ORDouble) leadToACancellation:(id<ORVar>)x;
-(ORUInt)nbUVars;
@end


@interface CPFloatTernarySub : CPCoreConstraint<CPABSConstraint,CPArithmConstraint> { // z = x - y
    CPFloatVarI* _z;
    CPFloatVarI* _x;
    CPFloatVarI* _y;
    ORInt _precision;
    ORDouble _percent;
    ORInt _rounding;
}
-(id) init:(id)z equals:(id)x minus:(id)y;
-(id) init:(id)z equals:(id)x minus:(id)y rewrite:(ORBool) f;
-(id) init:(id)z equals:(id)x minus:(id)y kbpercent:(ORDouble) p;
-(id) init:(id)z equals:(id)x minus:(id)y kbpercent:(ORDouble)p rewrite:(ORBool) f;
-(void) post;
-(NSSet*)allVars;
-(ORBool) canLeadToAnAbsorption;
-(id<CPFloatVar>) varSubjectToAbsorption:(id<CPFloatVar>)x;
-(ORDouble) leadToACancellation:(id<ORVar>)x;
-(ORUInt)nbUVars;
@end

@interface CPFloatTernaryMult : CPCoreConstraint<CPArithmConstraint> { // z = x * y
    CPFloatVarI* _z;
    CPFloatVarI* _x;
    CPFloatVarI* _y;
    ORInt _precision;
    ORDouble _percent;
    ORInt _rounding;
}
-(id) init:(id)z equals:(id)x mult:(id)y ;
-(id) init:(id)z equals:(id)x mult:(id)y kbpercent:(ORDouble) p;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end


@interface CPFloatTernaryDiv : CPCoreConstraint<CPArithmConstraint> { // z = x / y
    CPFloatVarI* _z;
    CPFloatVarI* _x;
    CPFloatVarI* _y;
    ORInt _precision;
    ORDouble _percent;
    ORInt _rounding;
}
-(id) init:(id)z equals:(id)x div:(id)y ;
-(id) init:(id)z equals:(id)x div:(id)y kbpercent:(ORDouble) p;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPFloatReifyGEqual : CPCoreConstraint {
@private
    CPIntVar* _b;
    CPFloatVarI* _x;
    CPFloatVarI* _y;
}
-(id) initCPReifyGEqual:(id<CPIntVar>)b when:(id<CPFloatVar>)x geqi:(id<CPFloatVar>)y;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end


@interface CPFloatReifyGThen : CPCoreConstraint {
@private
   CPIntVar* _b;
   CPFloatVarI* _x;
   CPFloatVarI* _y;
}
-(id) initCPReifyGThen:(id<CPIntVar>)b when:(id<CPFloatVar>)x gti:(id<CPFloatVar>)y;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPFloatReifyNEqual : CPCoreConstraint {
@private
    CPIntVar* _b;
    CPFloatVarI* _x;
    CPFloatVarI* _y;
}
-(id) initCPReify:(id<CPIntVar>)b when:(id<CPFloatVar>)x neq:(id<CPFloatVar>)y;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPFloatReifyEqual : CPCoreConstraint {
@private
    CPIntVar* _b;
    CPFloatVarI* _x;
    CPFloatVarI* _y;
}
-(id) initCPReifyEqual:(id<CPIntVar>)b when:(id<CPFloatVar>)x eqi:(id<CPFloatVar>)c;
-(id) initCPReifyEqual:(id<CPIntVar>)b when:(id<CPFloatVar>)x eqi:(id<CPFloatVar>)c dynRewrite:(ORBool) r staticRewrite:(ORBool) s;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPFloatReifyAssign : CPCoreConstraint {
@private
   CPIntVar* _b;
   CPFloatVarI* _x;
   CPFloatVarI* _y;
}
-(id) initCPReify:(id<CPIntVar>)b when:(id<CPFloatVar>)x set:(id<CPFloatVar>)c;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPFloatReifyLEqual : CPCoreConstraint {
@private
    CPIntVar* _b;
    CPFloatVarI* _x;
    CPFloatVarI* _y;
}
-(id) initCPReifyLEqual:(id<CPIntVar>)b when:(id<CPFloatVar>)x leqi:(id<CPFloatVar>)c;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPFloatReifyLThen : CPCoreConstraint {
@private
   CPIntVar* _b;
   CPFloatVarI* _x;
   CPFloatVarI* _y;
}
-(id) initCPReifyLThen:(id<CPIntVar>)b when:(id<CPFloatVar>)x lti:(id<CPFloatVar>)c;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPFloatReifyEqualc : CPCoreConstraint {
@private
   CPIntVar* _b;
   CPFloatVarI* _x;
   ORFloat      _c;
}
-(id) initCPReifyEqualc:(id<CPIntVar>)b when:(id<CPFloatVar>)x eqi:(ORFloat)c;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPFloatReifyAssignc : CPCoreConstraint {
@private
   CPIntVar* _b;
   CPFloatVarI* _x;
   ORFloat      _c;
}
-(id) initCPReify:(id<CPIntVar>)b when:(id<CPFloatVar>)x set:(ORFloat)c;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPFloatReifyLEqualc : CPCoreConstraint {
@private
    CPIntVar* _b;
    CPFloatVarI* _x;
    ORFloat      _c;
}
-(id) initCPReifyLEqualc:(id<CPIntVar>)b when:(id<CPFloatVar>)x leqi:(ORFloat)y;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end


@interface CPFloatReifyNotEqualc : CPCoreConstraint {
@private
    CPIntVar* _b;
    CPFloatVarI* _x;
    ORFloat      _c;
}
-(id) initCPReifyNotEqualc:(id<CPIntVar>)b when:(id<CPFloatVar>)x neqi:(ORFloat)c;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPFloatReifyGEqualc : CPCoreConstraint {
@private
    CPIntVar* _b;
    CPFloatVarI* _x;
    ORFloat      _c;
}
-(id) initCPReifyGEqualc:(id<CPIntVar>)b when:(id<CPFloatVar>)x geqi:(ORFloat)c;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPFloatReifyGThenc : CPCoreConstraint {
@private
   CPIntVar* _b;
   CPFloatVarI* _x;
   ORFloat      _c;
}
-(id) initCPReifyGThenc:(id<CPIntVar>)b when:(id<CPFloatVar>)x gti:(ORFloat)c;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPFloatReifyLThenc : CPCoreConstraint {
@private
   CPIntVar* _b;
   CPFloatVarI* _x;
   ORFloat      _c;
}
-(id) initCPReifyLThenc:(id<CPIntVar>)b when:(id<CPFloatVar>)x lti:(ORFloat)c;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPFloatSquare : CPCoreConstraint<CPArithmConstraint> {
@private
   CPFloatVarI* _x;
   CPFloatVarI* _res;
}
-(id) init:(id<CPFloatVar>)res eq:(id<CPFloatVar>)x ;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPFloatAbs : CPCoreConstraint<CPArithmConstraint> {
@private
   CPFloatVarI* _x;
   CPFloatVarI* _res;
}
-(id) init:(id<CPFloatVar>)res eq:(id<CPFloatVar>)x ;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end


@interface CPFloatSqrt : CPCoreConstraint<CPArithmConstraint> {
@private
   CPFloatVarI* _x;
   CPFloatVarI* _res;
}
-(id) init:(id<CPFloatVar>)res eq:(id<CPFloatVar>)x ;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPFloatIsPositive : CPCoreConstraint {
   CPIntVarI*   _b;
   CPFloatVarI* _x;
}
-(id) init:(id<CPFloatVar>)x isPositive:(id<CPIntVar>)x ;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPFloatIsZero : CPCoreConstraint {
   CPIntVarI*   _b;
   CPFloatVarI* _x;
}
-(id) init:(id<CPFloatVar>)x isZero:(id<CPIntVar>)x ;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPFloatIsInfinite : CPCoreConstraint {
   CPIntVarI*   _b;
   CPFloatVarI* _x;
}
-(id) init:(id<CPFloatVar>)x isInfinite:(id<CPIntVar>)x ;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPFloatIsNormal : CPCoreConstraint {
   CPIntVarI*   _b;
   CPFloatVarI* _x;
}
-(id) init:(id<CPFloatVar>)x isNormal:(id<CPIntVar>)x ;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPFloatIsSubnormal : CPCoreConstraint {
   CPIntVarI*   _b;
   CPFloatVarI* _x;
}
-(id) init:(id<CPFloatVar>)x isSubnormal:(id<CPIntVar>)x ;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end
