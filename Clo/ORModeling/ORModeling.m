/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORModeling/ORModeling.h>
#import <ORModeling/ORFlatten.h>
#import <ORModeling/ORLSFlatten.h>
#import <ORModeling/ORLPFlatten.h>
#import <ORModeling/ORMIPFlatten.h>
#import <ORModeling/ORLinearize.h>
#import <ORModeling/ORModelI.h>

@implementation ORFactory (ORModeling)
+(id<ORModel>) createModel
{
   return [[[ORModelI alloc] initORModelI] autorelease];
}
+(id<ORModel>) createModel: (ORUInt) nbo mappings: (id<ORModelMappings>) mappings
{
   return [[[ORModelI alloc] initORModelI: nbo mappings: mappings] autorelease];
}
+(id<ORModel>) cloneModel: (id<ORModel>)m
{
   return [m copy];
}
+(id<ORAddToModel>) createBatchModel: (id<ORModel>) flatModel source:(id<ORModel>)srcModel annotation:(id<ORAnnotation>)notes
{
   return [[ORBatchModel alloc]  init: flatModel source:srcModel annotation:notes];
}
+(id<ORParameterizedModel>)createParametricModel:(id<ORModel>)m relax:(NSArray*)cstrs
{
   return [[ORParameterizedModelI alloc] initWithModel:m relax:cstrs];
}
+(id<ORModelTransformation>) createFlattener:(id<ORAddToModel>)into
{
  return [[ORFlatten alloc] initORFlatten:into];
}
+(id<ORModelTransformation>) createLSFlattener:(id<ORAddToModel>)into
{
   return [[ORLSFlatten alloc] initORLSFlatten:into];
}
+(id<ORModelTransformation>) createLPFlattener:(id<ORAddToModel>)into
{
   return [[ORLPFlatten alloc] initORLPFlatten:into];
}
+(id<ORModelTransformation>) createMIPFlattener:(id<ORAddToModel>)into
{
   return [[ORMIPFlatten alloc] initORMIPFlatten:into];
}
+(id<ORModelTransformation>) createLinearizer:(id<ORAddToModel>)into
{
   return [[ORLinearize alloc] initORLinearize:into];
}
+(id<ORConstraintSet>) createConstraintSet
{
    return [[ORConstraintSetI alloc] init];
}
@end
