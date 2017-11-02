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

@interface CPFloatEqual : CPCoreConstraint {
    CPFloatVarI* _x;
    CPFloatVarI* _y;
}
-(id) init:(id)x equals:(id)y;
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


@interface CPFloatTernaryAdd : CPCoreConstraint { // z = x + y
    CPFloatVarI* _z;
    CPFloatVarI* _x;
    CPFloatVarI* _y;
    ORInt _precision;
    ORDouble _percent;
    ORInt _rounding;
}
-(id) init:(id)z equals:(id)x plus:(id)y ;
-(void) post;
-(NSSet*)allVars;
-(ORDouble) leadToAnAbsorption:(id<ORVar>)x;
-(ORDouble) leadToACancellation:(id<ORVar>)x;
-(ORUInt)nbUVars;
@end


@interface CPFloatTernarySub : CPCoreConstraint { // z = x - y
    CPFloatVarI* _z;
    CPFloatVarI* _x;
    CPFloatVarI* _y;
    ORInt _precision;
    ORDouble _percent;
    ORInt _rounding;
}
-(id) init:(id)z equals:(id)x minus:(id)y ;
-(void) post;
-(NSSet*)allVars;
-(ORDouble) leadToAnAbsorption:(id<ORVar>)x;
-(ORDouble) leadToACancellation:(id<ORVar>)x;
-(ORUInt)nbUVars;
@end

@interface CPFloatTernaryMult : CPCoreConstraint { // z = x * y
    CPFloatVarI* _z;
    CPFloatVarI* _x;
    CPFloatVarI* _y;
    ORInt _precision;
    ORDouble _percent;
    ORInt _rounding;
}
-(id) init:(id)z equals:(id)x mult:(id)y ;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end


@interface CPFloatTernaryDiv : CPCoreConstraint { // z = x / y
    CPFloatVarI* _z;
    CPFloatVarI* _x;
    CPFloatVarI* _y;
    ORInt _precision;
    ORDouble _percent;
    ORInt _rounding;
}
-(id) init:(id)z equals:(id)x div:(id)y ;
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

