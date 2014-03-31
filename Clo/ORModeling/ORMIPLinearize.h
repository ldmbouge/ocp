/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012,2013 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <Foundation/Foundation.h>
#import <ORModeling/ORModelTransformation.h>
#import <ORModeling/ORModeling.h>
#import <ORFoundation/ORArrayI.h>
#import <ORFoundation/ORVisit.h>

@interface ORMIPLinearize : ORNOopVisit<ORModelTransformation>
-(id) initORMIPLinearize: (id<ORAddToModel>) into;
-(void) apply: (id<ORModel>) m with:(id<ORAnnotation>)notes;
+(id<ORModel>) linearize: (id<ORModel>) model;
@end

@interface ORFactory (MIPLinearize)
+(id<ORModel>) linearizeModelForMIP: (id<ORModel>) m;
@end
