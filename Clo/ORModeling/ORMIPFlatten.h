/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <Foundation/Foundation.h>
#import <ORFoundation/ORVisit.h>
#import <ORModeling/ORModelTransformation.h>
#import <ORFoundation/ORVisit.h>

@interface ORMIPFlatten : ORNOopVisit<ORModelTransformation>
-(id) initORMIPFlatten: (id<ORAddToModel>) target;
-(void) apply:(id<ORModel>) m  with:(id<ORAnnotation>)notes;
-(id<ORAddToModel>) target;
+(id<ORConstraint>) flattenExpression:(id<ORExpr>)e into:(id<ORAddToModel>)m;
@end

