/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <Foundation/Foundation.h>
#import <CPUKernel/CPUKernel.h>
#import <CPUKernel/CPConstraintI.h>
#import <objcp/CPBitDom.h>
#import <objcp/CPVar.h>

@class CPFloatVarI;
@class CPEngine;
@protocol CPFloatVarArray;

@interface CPFloatSquareBC : CPCoreConstraint { // z == x^2
   CPFloatVarI* _x;
   CPFloatVarI* _z;
}
-(id)initCPFloatSquareBC:(id)z equalSquare:(id)x;
-(ORStatus)post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPFloatEquationBC : CPCoreConstraint {
   id<CPFloatVarArray> _x;
   id<ORFloatArray>    _coefs;
   ORFloat             _c;
}
-(id)init:(id<CPFloatVarArray>)x coef:(id<ORFloatArray>)coefs eqi:(ORFloat)c;
-(ORStatus)post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPFloatINEquationBC : CPCoreConstraint {
   id<CPFloatVarArray> _x;
   id<ORFloatArray>    _coefs;
   ORFloat             _c;
}
-(id)init:(id<CPFloatVarArray>)x coef:(id<ORFloatArray>)coefs leqi:(ORFloat)c;
-(ORStatus)post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPFloatEqualc : CPCoreConstraint {
   CPFloatVarI* _x;
   ORFloat      _c;
}
-(id) init:(id)x and:(ORFloat)c;
-(ORStatus)post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end
