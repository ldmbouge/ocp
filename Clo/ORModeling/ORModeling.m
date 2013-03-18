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
#import "ORLPFlatten.h"
#import "ORLinearize.h"

@implementation ORFactory (ORModeling)
+(id<ORModel>) createModel
{
   return [[[ORModelI alloc]  initORModelI] autorelease];
}
+(id<ORAddToModel>) createBatchModel: (id<ORModel>) flatModel source:(id<ORModel>)srcModel
{
   return [[ORBatchModel alloc]  init: flatModel source:srcModel];
}
+(id<ORModelTransformation>) createFlattener
{
   return [[[ORFlatten alloc] initORFlatten] autorelease];
}
+(id<ORModelTransformation>) createLPFlattener
{
   return [[[ORLPFlatten alloc] initORLPFlatten] autorelease];
}
+(id<ORModelTransformation>) createLinearizer
{
    return [[[ORLinearize alloc] initORLinearize] autorelease];
}
+(id<ORSolutionPool>) createSolutionPool
{
   return [[ORSolutionPoolI alloc] init];
}
@end
