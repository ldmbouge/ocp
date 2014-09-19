/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <Foundation/Foundation.h>
#import <ORModeling/ORModelTransformation.h>
#import <ORFoundation/ORAnnotation.h>

@interface ORFlatten : ORNOopVisit<ORModelTransformation> {
   id<ORAddToModel>   _into;
   id               _result;
   id<ORAnnotation>  _fresh;
}
-(id)initORFlatten: (id<ORAddToModel>) into;
-(void) apply: (id<ORModel>)m with:(id<ORAnnotation>)notes;
-(id<ORAddToModel>) target;
-(id)flattenIt:(id)obj;
+(void) flatten:(id<ORConstraint>)c into:(id<ORAddToModel>)m;
+(id<ORConstraint>) flattenExpression:(id<ORExpr>)e into:(id<ORAddToModel>)m;
@end

@interface ORReplace : ORNOopVisit<ORModelTransformation>
+(id<ORExpr>)subst:(id<ORExpr>)e with:(id(^)(id))f;
@end