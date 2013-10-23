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
#import "ORMIPFlatten.h"
#import "ORLinearize.h"

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

+(id<ORModelTransformation>) createFlattener:(id<ORAddToModel>)into annotation:(id<ORAnnotation>)notes
{
  return [[ORFlatten alloc] initORFlatten:into annotation:notes];
}
+(id<ORModelTransformation>) createLPFlattener:(id<ORAddToModel>)into annotation:(id<ORAnnotation>)notes
{
   return [[ORLPFlatten alloc] initORLPFlatten:into annotation:notes];
}
+(id<ORModelTransformation>) createMIPFlattener:(id<ORAddToModel>)into annotation:(id<ORAnnotation>)notes
{
   return [[ORMIPFlatten alloc] initORMIPFlatten:into annotation:notes];
}
+(id<ORModelTransformation>) createLinearizer:(id<ORAddToModel>)into
{
   return [[ORLinearize alloc] initORLinearize:into];
}
+(id<ORSolutionPool>) createSolutionPool
{
   return [[ORSolutionPoolI alloc] init];
}
+(id<ORConstraintSet>) createConstraintSet {
    return [[ORConstraintSetI alloc] init];
}
+(id<OROrderedConstraintSet>) orderedConstraintSet: (id<ORTracker>) tracker range: (id<ORIntRange>)range with: (id<ORConstraint>(^)(ORInt index)) block {
    id<OROrderedConstraintSet> s = [[OROrderedConstraintSetI alloc] init];
    for(ORInt i = [range low]; i <= [range up]; i++) {
        [s addConstraint: block(i)];
    }
    //[tracker trackMutable: s];
    return s;
}
@end
