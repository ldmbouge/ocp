/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <Foundation/Foundation.h>
#import <ORModeling/ORModelTransformation.h>

@interface ORLPFlatten : ORNOopVisit<ORModelTransformation>
-(id) initORLPFlatten: (id<ORAddToModel>) target annotation:(id<ORAnnotation>)notes;
-(void) apply:(id<ORModel>) m;
-(id<ORAddToModel>) target;
+(id<ORConstraint>) flattenExpression:(id<ORExpr>)e into:(id<ORAddToModel>)m;
@end
