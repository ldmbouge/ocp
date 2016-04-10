/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <ORScheduler/ORScheduler.h>

@interface ORLinearizeScheduling : ORLinearize
-(id)initORLinearizeSched:(id<ORAddToModel>)into;
-(void) apply:(id<ORModel>)m with:(id<ORAnnotation>)notes;
@end

// Time Indexed
@interface ORLinearizeSchedulingTI : ORLinearize
-(id)initORLinearizeSched:(id<ORAddToModel>)into;
-(void) apply:(id<ORModel>)m with:(id<ORAnnotation>)notes;
@end

typedef enum MIPSchedEncoding {
   MIPSchedDisjunctive,
   MIPSchedTimeIndexed
} MIPSchedEncoding;

@interface ORFactory (SchedLinearize)
+(id<ORModel>) linearizeSchedulingModel: (id<ORModel>)m
                               encoding: (MIPSchedEncoding)enc;
@end
