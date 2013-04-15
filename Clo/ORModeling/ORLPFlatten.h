/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <Foundation/Foundation.h>
#import <ORModeling/ORModelTransformation.h>

@interface ORLPFlatten : NSObject<ORModelTransformation>
-(id) initORLPFlatten:(id<ORAddToModel>)target;
-(void) apply:(id<ORModel>)m;
+(void) flatten:(id<ORConstraint>)c into:(id<ORAddToModel>)m;
+(id<ORConstraint>) flattenExpression:(id<ORExpr>)e into:(id<ORAddToModel>)m annotation:(ORAnnotation)note;
@end
