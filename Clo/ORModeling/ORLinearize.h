/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <Foundation/Foundation.h>
#import <ORModeling/ORModelTransformation.h>

@interface ORLinearize : NSObject<ORModelTransformation>
-(id)initORLinearize:(id<ORAddToModel>)into;
-(void) apply:(id<ORModel>)m with:(id<ORAnnotation>)notes;
+(id<ORModel>)linearize:(id<ORModel>)model;
@end

@interface ORLinearizeScheduling : ORLinearize
-(id)initORLinearizeSched:(id<ORAddToModel>)into;
-(void) apply:(id<ORModel>)m with:(id<ORAnnotation>)notes;
@end

// Time Indexed
@interface ORLinearizeSchedulingTI : ORLinearize
-(id)initORLinearizeSched:(id<ORAddToModel>)into;
-(void) apply:(id<ORModel>)m with:(id<ORAnnotation>)notes;
@end

typedef enum {
    MIPSchedDisjunctive,
    MIPSchedTimeIndexed
} MIPSchedEncoding;

@interface ORFactory(Linearize)
+(id<ORModel>) linearizeModel: (id<ORModel>)m;
+(id<ORModel>) linearizeSchedulingModel: (id<ORModel>)m encoding: (MIPSchedEncoding)enc;
@end
