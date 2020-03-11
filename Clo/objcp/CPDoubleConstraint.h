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
#import <objcp/CPDoubleDom.h>
#import <objcp/CPRationalDom.h>
#import <objcp/CPRationalVarI.h>

@class CPDoubleVarI;
@class CPFloatVarI;

//unary minus constraint
@interface CPDoubleUnaryMinus : CPCoreConstraint<CPArithmConstraint> {
   CPDoubleVarI* _x;
   CPDoubleVarI* _y;
}
-(id) init:(id)x eqm:(id)y  rewrite:(ORBool)rewrite;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPDoubleCast : CPCoreConstraint<CPArithmConstraint> {
   CPDoubleVarI* _res;
   CPFloatVarI* _initial;
}
-(id) init:(id)x equals:(id)y  rewrite:(ORBool)rewrite;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end


@interface CPDoubleEqual : CPCoreConstraint {
    CPDoubleVarI* _x;
    CPDoubleVarI* _y;
}
-(id) init:(id)x equals:(id)y rewrite:(ORBool)rewrite;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPDoubleEqualc : CPCoreConstraint {
    CPDoubleVarI* _x;
    ORDouble      _c;
}
-(id) init:(id)x and:(ORDouble)c;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPDoubleAssign : CPCoreConstraint<CPArithmConstraint> {
   CPDoubleVarI* _x;
   CPDoubleVarI* _y;
}
-(id) init:(id)x set:(id)y;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPDoubleAssignC : CPCoreConstraint<CPArithmConstraint> {
   CPDoubleVarI* _x;
   ORDouble      _c;
}
-(id) init:(id)x set:(ORDouble)c;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPDoubleNEqual : CPCoreConstraint {
    CPDoubleVarI* _x;
    CPDoubleVarI* _y;
}
-(id) init:(id)x nequals:(id)y;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPDoubleNEqualc : CPCoreConstraint {
    CPDoubleVarI* _x;
    ORDouble      _c;
}
-(id) init:(id)x and:(ORDouble)c;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPDoubleLT : CPCoreConstraint {
    CPDoubleVarI* _x;
    CPDoubleVarI* _y;
}
-(id) init:(id)x lt:(id)y;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPDoubleGT : CPCoreConstraint {
    CPDoubleVarI* _x;
    CPDoubleVarI* _y;
}
-(id) init:(id)x gt:(id)y;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end


@interface CPDoubleLEQ : CPCoreConstraint {
    CPDoubleVarI* _x;
    CPDoubleVarI* _y;
}
-(id) init:(id)x leq:(id)y;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPDoubleGEQ : CPCoreConstraint {
    CPDoubleVarI* _x;
    CPDoubleVarI* _y;
}
-(id) init:(id)x geq:(id)y;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end


@interface CPDoubleTernaryAdd : CPCoreConstraint<CPABSConstraint,CPArithmConstraint> { // z = x + y
   CPDoubleVarI* _z;
   CPDoubleVarI* _x;
   CPDoubleVarI* _y;
   ORInt _precision;
   ORDouble _percent;
   ORBool _rewriting;
   ORInt _rounding;
   // cpjm: Use a trailed object for eo to insure that its value is saved
   //CPRationalDom* _eo;
   id<CPRationalVar> _eo;
}
-(id) init:(id)z equals:(id)x plus:(id)y ;
-(id) init:(id)z equals:(id)x plus:(id)y rewriting:(ORBool) f;
-(id) init:(id)z equals:(id)x plus:(id)y kbpercent:(ORDouble)p;
-(id) init:(id)z equals:(id)x plus:(id)y kbpercent:(ORDouble)p rewriting:(ORBool) f;
-(void) post;
-(NSSet*)allVars;
-(ORBool) canLeadToAnAbsorption;
-(id<CPDoubleVar>) varSubjectToAbsorption:(id<CPDoubleVar>)x;
-(ORUInt)nbUVars;
-(id<CPRationalVar>)getOperationError;
@end


@interface CPDoubleTernarySub : CPCoreConstraint<CPABSConstraint,CPArithmConstraint> { // z = x - y
   CPDoubleVarI* _z;
   CPDoubleVarI* _x;
   CPDoubleVarI* _y;
   ORInt _precision;
   ORDouble _percent;
   ORBool _rewriting;
   ORInt _rounding;
   // cpjm: Use a trailed object for eo to insure that its value is saved
   //CPRationalDom* _eo;
   id<CPRationalVar> _eo;
}
-(id) init:(id)z equals:(id)x minus:(id)y;
-(id) init:(id)z equals:(id)x minus:(id)y rewriting:(ORBool) f;
-(id) init:(id)z equals:(id)x minus:(id)y kbpercent:(ORDouble) p;
-(id) init:(id)z equals:(id)x minus:(id)y kbpercent:(ORDouble) p rewriting:(ORBool) f;
-(void) post;
-(NSSet*)allVars;
-(ORBool) canLeadToAnAbsorption;
-(id<CPDoubleVar>) varSubjectToAbsorption:(id<CPDoubleVar>)x;
-(ORUInt)nbUVars;
-(id<CPRationalVar>)getOperationError;
@end

@interface CPDoubleTernaryMult : CPCoreConstraint<CPArithmConstraint> { // z = x * y
   CPDoubleVarI* _z;
   CPDoubleVarI* _x;
   CPDoubleVarI* _y;
   ORInt _precision;
   ORDouble _percent;
   ORInt _rounding;
   // cpjm: Use a trailed object for eo to insure that its value is saved
   //CPRationalDom* _eo;
   id<CPRationalVar> _eo;
}
-(id) init:(id)z equals:(id)x mult:(id)y ;
-(id) init:(id)z equals:(id)x mult:(id)y kbpercent:(ORDouble) p;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
-(id<CPRationalVar>)getOperationError;
@end


@interface CPDoubleTernaryDiv : CPCoreConstraint<CPArithmConstraint> { // z = x / y
   CPDoubleVarI* _z;
   CPDoubleVarI* _x;
   CPDoubleVarI* _y;
   ORInt _precision;
   ORDouble _percent;
   ORInt _rounding;
   // cpjm: Use a trailed object for eo to insure that its value is saved
   //CPRationalDom* _eo;
   id<CPRationalVar> _eo;

}
-(id) init:(id)z equals:(id)x div:(id)y ;
-(id) init:(id)z equals:(id)x div:(id)y kbpercent:(ORDouble) p;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
-(id<CPRationalVar>)getOperationError;
@end

@interface CPDoubleReifyGEqual : CPCoreConstraint {
@private
    CPIntVar* _b;
    CPDoubleVarI* _x;
    CPDoubleVarI* _y;
}
-(id) initCPReifyGEqual:(id<CPIntVar>)b when:(id<CPDoubleVar>)x geqi:(id<CPDoubleVar>)y;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end


@interface CPDoubleReifyGThen : CPCoreConstraint {
@private
    CPIntVar* _b;
    CPDoubleVarI* _x;
    CPDoubleVarI* _y;
}
-(id) initCPReifyGThen:(id<CPIntVar>)b when:(id<CPDoubleVar>)x gti:(id<CPDoubleVar>)y;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPDoubleReifyNEqual : CPCoreConstraint {
@private
    CPIntVar* _b;
    CPDoubleVarI* _x;
    CPDoubleVarI* _y;
}
-(id) initCPReify:(id<CPIntVar>)b when:(id<CPDoubleVar>)x neq:(id<CPDoubleVar>)y;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPDoubleReifyEqual : CPCoreConstraint {
@private
    CPIntVar* _b;
    CPDoubleVarI* _x;
    CPDoubleVarI* _y;
}
-(id) initCPReifyEqual:(id<CPIntVar>)b when:(id<CPDoubleVar>)x eqi:(id<CPDoubleVar>)c dynRewrite:(ORBool) r staticRewrite:(ORBool) s;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPDoubleReifyLEqual : CPCoreConstraint {
@private
    CPIntVar* _b;
    CPDoubleVarI* _x;
    CPDoubleVarI* _y;
}
-(id) initCPReifyLEqual:(id<CPIntVar>)b when:(id<CPDoubleVar>)x leqi:(id<CPDoubleVar>)c;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPDoubleReifyLThen : CPCoreConstraint {
@private
    CPIntVar* _b;
    CPDoubleVarI* _x;
    CPDoubleVarI* _y;
}
-(id) initCPReifyLThen:(id<CPIntVar>)b when:(id<CPDoubleVar>)x lti:(id<CPDoubleVar>)c;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPDoubleReifyEqualc : CPCoreConstraint {
@private
    CPIntVar* _b;
    CPDoubleVarI* _x;
    ORDouble      _c;
}
-(id) initCPReifyEqualc:(id<CPIntVar>)b when:(id<CPDoubleVar>)x eqi:(ORDouble)c;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPDoubleReifyAssignc : CPCoreConstraint {
@private
   CPIntVar* _b;
   CPDoubleVarI* _x;
   ORDouble      _c;
}
-(id) initCPReify:(id<CPIntVar>)b when:(id<CPDoubleVar>)x set:(ORDouble)c;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPDoubleReifyAssign : CPCoreConstraint {
@private
   CPIntVar* _b;
   CPDoubleVarI* _x;
   CPDoubleVarI* _y;
}
-(id) initCPReify:(id<CPIntVar>)b when:(id<CPDoubleVar>)x set:(id<CPDoubleVar>)c;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPDoubleReifyLEqualc : CPCoreConstraint {
@private
    CPIntVar* _b;
    CPDoubleVarI* _x;
    ORDouble      _c;
}
-(id) initCPReifyLEqualc:(id<CPIntVar>)b when:(id<CPDoubleVar>)x leqi:(ORDouble)y;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end


@interface CPDoubleReifyNotEqualc : CPCoreConstraint {
@private
    CPIntVar* _b;
    CPDoubleVarI* _x;
    ORDouble      _c;
}
-(id) initCPReifyNotEqualc:(id<CPIntVar>)b when:(id<CPDoubleVar>)x neqi:(ORDouble)c;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPDoubleReifyGEqualc : CPCoreConstraint {
@private
    CPIntVar* _b;
    CPDoubleVarI* _x;
    ORDouble      _c;
}
-(id) initCPReifyGEqualc:(id<CPIntVar>)b when:(id<CPDoubleVar>)x geqi:(ORDouble)c;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPDoubleReifyGThenc : CPCoreConstraint {
@private
    CPIntVar* _b;
    CPDoubleVarI* _x;
    ORDouble      _c;
}
-(id) initCPReifyGThenc:(id<CPIntVar>)b when:(id<CPDoubleVar>)x gti:(ORDouble)c;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPDoubleReifyLThenc : CPCoreConstraint {
@private
    CPIntVar* _b;
    CPDoubleVarI* _x;
    ORDouble      _c;
}
-(id) initCPReifyLThenc:(id<CPIntVar>)b when:(id<CPDoubleVar>)x lti:(ORDouble)c;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end


@interface CPDoubleAbs : CPCoreConstraint<CPArithmConstraint> {
@private
   CPDoubleVarI* _x;
   CPDoubleVarI* _res;
}
-(id) init:(id<CPDoubleVar>)res eq:(id<CPDoubleVar>)x ;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPDoubleSquare : CPCoreConstraint<CPArithmConstraint> {
@private
   CPDoubleVarI* _x;
   CPDoubleVarI* _res;
   // cpjm: Use a trailed object for eo to insure that its value is saved
   //CPRationalDom* _eo;
   id<CPRationalVar> _eo;
}
-(id) init:(id<CPDoubleVar>)res eq:(id<CPDoubleVar>)x ;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
-(id<CPRationalVar>)getOperationError;
@end

@interface CPDoubleSqrt : CPCoreConstraint<CPArithmConstraint> {
@private
   CPDoubleVarI* _x;
   CPDoubleVarI* _res;
}
-(id) init:(id<CPDoubleVar>)res eq:(id<CPDoubleVar>)x ;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPDoubleIsPositive : CPCoreConstraint {
   CPIntVar*   _b;
   CPDoubleVarI* _x;
}
-(id) init:(id<CPDoubleVar>)x isPositive:(id<CPIntVar>)x ;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPDoubleIsZero : CPCoreConstraint {
   CPIntVar*   _b;
   CPDoubleVarI* _x;
}
-(id) init:(id<CPDoubleVar>)x isZero:(id<CPIntVar>)x ;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPDoubleIsInfinite : CPCoreConstraint {
   CPIntVar*   _b;
   CPDoubleVarI* _x;
}
-(id) init:(id<CPDoubleVar>)x isInfinite:(id<CPIntVar>)x ;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPDoubleIsNormal : CPCoreConstraint {
   CPIntVar*   _b;
   CPDoubleVarI* _x;
}
-(id) init:(id<CPDoubleVar>)x isNormal:(id<CPIntVar>)x ;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPDoubleIsSubnormal : CPCoreConstraint {
   CPIntVar*   _b;
   CPDoubleVarI* _x;
}
-(id) init:(id<CPDoubleVar>)x isSubnormal:(id<CPIntVar>)x ;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end
