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
#include <fpi.h>

@class CPDoubleVarI;

typedef struct {
    double_interval  result;
    double_interval  interval;
    int  changed;
} intersectionDoubleInterval;

static inline double_interval makeDoubleInterval(double min, double max)
{
    return (double_interval){min,max};
}
static inline intersectionDoubleInterval intersectionDouble(int changed,double_interval r, double_interval x)
{
    fpi_narrowd(&r, &x, &changed);
    return (intersectionDoubleInterval){r,x,changed};
}

static inline unsigned long long cardinalityD(double xmin, double xmax){
    double_cast i_inf;
    double_cast i_sup;
    if(xmin == xmax) return 1;
    if(xmin == -infinity() && xmax == infinity()) return MAXDBL;
    i_inf.f = xmin;
    i_sup.f = xmax;
    return (i_sup.parts.exponent - i_inf.parts.exponent) * NB_DOUBLE_BY_E - i_inf.parts.mantisa + i_sup.parts.mantisa;
}
static inline bool isDisjointWithD(double xmin,double xmax,double ymin, double ymax)
{
    return (xmin < ymin &&  xmax < ymin) || (ymin < xmin && ymax < xmin);
}
static inline bool isIntersectionWithD(double xmin,double xmax,double ymin, double ymax)
{
    return !isDisjointWithD(xmin, xmax, ymin, ymax);
}

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


@interface CPDoubleTernaryAdd : CPCoreConstraint { // z = x + y
    CPDoubleVarI* _z;
    CPDoubleVarI* _x;
    CPDoubleVarI* _y;
}
-(id) init:(id)z equals:(id)x plus:(id)y ;
-(void) post;
-(NSSet*)allVars;
-(ORDouble) leadToAnAbsorption:(id<ORVar>)x;
-(ORDouble) leadToACancellation:(id<ORVar>)x;
-(ORUInt)nbUVars;
@end


@interface CPDoubleTernarySub : CPCoreConstraint { // z = x - y
    CPDoubleVarI* _z;
    CPDoubleVarI* _x;
    CPDoubleVarI* _y;
}
-(id) init:(id)z equals:(id)x minus:(id)y ;
-(void) post;
-(NSSet*)allVars;
-(ORDouble) leadToAnAbsorption:(id<ORVar>)x;
-(ORDouble) leadToACancellation:(id<ORVar>)x;
-(ORUInt)nbUVars;
@end

@interface CPDoubleTernaryMult : CPCoreConstraint { // z = x * y
    CPDoubleVarI* _z;
    CPDoubleVarI* _x;
    CPDoubleVarI* _y;
}
-(id) init:(id)z equals:(id)x mult:(id)y ;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end


@interface CPDoubleTernaryDiv : CPCoreConstraint { // z = x / y
    CPDoubleVarI* _z;
    CPDoubleVarI* _x;
    CPDoubleVarI* _y;
}
-(id) init:(id)z equals:(id)x div:(id)y ;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

// phy function to link ssa variables
@interface CPDoubleSSA : CPCoreConstraint {
    CPDoubleVarI* _z;
    CPDoubleVarI* _x;
    CPDoubleVarI* _y;
}
-(id) init:(id)z ssa:(id)x with:(id)y;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end


