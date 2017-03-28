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
#include <fpi.h>

@class CPFloatVarI;

typedef struct {
    float_interval  result;
    float_interval  interval;
    int  changed;
} intersectionInterval;


static inline float_interval makeFloatInterval(float min, float max)
{
    return (float_interval){min,max};
}

static inline intersectionInterval intersection(int changed,float_interval r, float_interval x)
{
    fpi_narrowf(&r, &x, &changed);
    return (intersectionInterval){r,x,changed};
}

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
}
-(id) init:(id)z equals:(id)x plus:(id)y ;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end


@interface CPFloatTernarySub : CPCoreConstraint { // z = x + y
    CPFloatVarI* _z;
    CPFloatVarI* _x;
    CPFloatVarI* _y;
}
-(id) init:(id)z equals:(id)x minus:(id)y ;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPFloatTernaryMult : CPCoreConstraint { // z = x * y
    CPFloatVarI* _z;
    CPFloatVarI* _x;
    CPFloatVarI* _y;
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
}
-(id) init:(id)z equals:(id)x div:(id)y ;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

// phy function to link ssa variables
@interface CPFloatSSA : CPCoreConstraint {
    CPFloatVarI* _x;
    CPFloatVarI* _y;
}
-(id) init:(id)x ssa:(id)y ;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end


