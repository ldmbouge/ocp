/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <CPUKernel/CPTypes.h>
#import <CPUKernel/CPConstraintI.h>
#import "ORFloatLinear.h"

@interface ORMIPLinearizer : NSObject<ORVisitor>
+(id<ORFloatLinear>) linearFrom: (id<ORExpr>)e  model: (id<ORAddToModel>)model annotation: (ORAnnotation)n;
+(id<ORFloatLinear>) addToLinear: (id<ORFloatLinear>) terms from: (id<ORExpr>)e  model: (id<ORAddToModel>) model annotation: (ORAnnotation) n;
@end

@interface ORMIPNormalizer : ORNOopVisit<ORVisitor>
+(id<ORLinear>) normalize:(id<ORExpr>) expr into: (id<ORAddToModel>)model annotation:(ORAnnotation)n;
@end

