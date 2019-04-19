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

@class CPDoubleVarI;
@class CPFloatVarI;

//unary minus constraint
@interface CPDoubleUnaryMinus : CPCoreConstraint {
   CPDoubleVarI* _x;
   CPDoubleVarI* _y;
}
-(id) init:(id)x eqm:(id)y;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPDoubleCast : CPCoreConstraint {
   CPDoubleVarI* _res;
   CPFloatVarI* _initial;
}
-(id) init:(id)x equals:(id)y;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end


@interface CPDoubleEqual : CPCoreConstraint {
   CPDoubleVarI* _x;
   CPDoubleVarI* _y;
}
-(id) init:(id)x equals:(id)y;
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

@interface CPDoubleAssign : CPCoreConstraint {
   CPDoubleVarI* _x;
   CPDoubleVarI* _y;
}
-(id) init:(id)x set:(id)y;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPDoubleAssignC : CPCoreConstraint {
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


@interface CPDoubleTernaryAdd : CPCoreConstraint<CPABSConstraint> { // z = x + y
   CPDoubleVarI* _z;
   CPDoubleVarI* _x;
   CPDoubleVarI* _y;
   ORInt _precision;
   ORDouble _percent;
   ORInt _rounding;
}
-(id) init:(id)z equals:(id)x plus:(id)y ;
-(id) init:(id)z equals:(id)x plus:(id)y kbpercent:(ORDouble)p;
-(void) post;
-(NSSet*)allVars;
-(ORBool) canLeadToAnAbsorption;
-(id<CPDoubleVar>) varSubjectToAbsorption:(id<CPDoubleVar>)x;
-(ORUInt)nbUVars;
@end


@interface CPDoubleTernarySub : CPCoreConstraint<CPABSConstraint> { // z = x - y
   CPDoubleVarI* _z;
   CPDoubleVarI* _x;
   CPDoubleVarI* _y;
   ORInt _precision;
   ORDouble _percent;
   ORInt _rounding;
}
-(id) init:(id)z equals:(id)x minus:(id)y;
-(id) init:(id)z equals:(id)x minus:(id)y kbpercent:(ORDouble) p;
-(void) post;
-(NSSet*)allVars;
-(ORBool) canLeadToAnAbsorption;
-(id<CPDoubleVar>) varSubjectToAbsorption:(id<CPDoubleVar>)x;
-(ORUInt)nbUVars;
@end

@interface CPDoubleTernaryMult : CPCoreConstraint { // z = x * y
   CPDoubleVarI* _z;
   CPDoubleVarI* _x;
   CPDoubleVarI* _y;
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


@interface CPDoubleTernaryDiv : CPCoreConstraint { // z = x / y
   CPDoubleVarI* _z;
   CPDoubleVarI* _x;
   CPDoubleVarI* _y;
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
-(id) initCPReifyEqual:(id<CPIntVar>)b when:(id<CPDoubleVar>)x eqi:(id<CPDoubleVar>)c;
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


@interface CPDoubleAbs : CPCoreConstraint {
@private
   CPDoubleVarI* _x;
   CPDoubleVarI* _res;
}
-(id) init:(id<CPDoubleVar>)res eq:(id<CPDoubleVar>)x ;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPDoubleSquare : CPCoreConstraint {
@private
   CPDoubleVarI* _x;
   CPDoubleVarI* _res;
}
-(id) init:(id<CPDoubleVar>)res eq:(id<CPDoubleVar>)x ;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPDoubleSqrt : CPCoreConstraint {
@private
   CPDoubleVarI* _x;
   CPDoubleVarI* _res;
}
-(id) init:(id<CPDoubleVar>)res eq:(id<CPDoubleVar>)x ;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end
