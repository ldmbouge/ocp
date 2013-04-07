/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORModeling/ORModeling.h>
#import "ORModelI.h"
#import "ORFlatten.h"
#import "ORCopy.h"
#import "ORLPFlatten.h"
#import "ORMIPFlatten.h"
#import "ORLinearize.h"

@implementation ORFactory (ORModeling)
+(id<ORModel>) createModel
{
   return [[[ORModelI alloc]  initORModelI] autorelease];
}
+(id<ORModel>) cloneModel: (id<ORModel>)m {
    ORCopy* copier = [[ORCopy alloc] initORCopy: nil];
    id<ORModel> copyModel = [copier copyModel: m];
    [copier release];
    return copyModel;
}
+(id<ORAddToModel>) createBatchModel: (id<ORModel>) flatModel source:(id<ORModel>)srcModel
{
   return [[ORBatchModel alloc]  init: flatModel source:srcModel];
}

+(id<ORModelTransformation>) createFlattener:(id<ORAddToModel>)into
{
   return [[[ORFlatten alloc] initORFlatten:into] autorelease];
}
+(id<ORModelTransformation>) createLPFlattener:(id<ORAddToModel>)into
{
   return [[[ORLPFlatten alloc] initORLPFlatten:into] autorelease];
}
+(id<ORModelTransformation>) createMIPFlattener:(id<ORAddToModel>)into
{
   return [[[ORMIPFlatten alloc] initORMIPFlatten:into] autorelease];
}
+(id<ORModelTransformation>) createLinearizer:(id<ORAddToModel>)into
{
   return [[[ORLinearize alloc] initORLinearize:into] autorelease];
}
+(id<ORSolutionPool>) createSolutionPool
{
   return [[ORSolutionPoolI alloc] init];
}
+(id<ORConstraintSet>) createConstraintSet {
    return [[ORConstraintSetI alloc] init];
}
@end
