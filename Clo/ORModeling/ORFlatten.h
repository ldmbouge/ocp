/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <Foundation/Foundation.h>
#import <ORModeling/ORModelTransformation.h>

@interface ORNOopVisit : NSObject<ORVisitor>
@end

@interface ORFlatten : ORNOopVisit<ORModelTransformation,ORVisitor> {
   id<ORAddToModel>   _into;
   id               _result;
}
-(id)initORFlatten:(id<ORAddToModel>) into;
-(void) apply:(id<ORModel>)m;
-(id<ORAddToModel>)target;
+(void) flatten:(id<ORConstraint>)c into:(id<ORAddToModel>)m;
+(id<ORConstraint>) flattenExpression:(id<ORExpr>)e into:(id<ORAddToModel>)m annotation:(ORAnnotation)note;
@end

@interface ORReplace : ORNOopVisit<ORModelTransformation,ORVisitor>
+(id<ORExpr>)subst:(id<ORExpr>)e with:(id(^)(id))f;
@end