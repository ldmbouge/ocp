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


