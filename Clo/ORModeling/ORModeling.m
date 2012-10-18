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
#import "ORLinearize.h"

@implementation ORFactory (ORModeling)
+(id<ORModel>) createModel
{
   return [[[ORModelI alloc]  initORModelI] autorelease];
}
+(id<ORModelTransformation>)createFlattener
{
   return [[[ORFlatten alloc] initORFlatten] autorelease];
}
+(id<ORModelTransformation>)createLinearizer
{
    return [[[ORLinearize alloc] initORLinearize] autorelease];
}
+(id<ORIntVarArray>) binarizeIntVar: (id<ORIntVar>)x tracker: (id<ORTracker>) tracker
{
    id<ORIntRange> range = [x domain];
    id<ORIdArray> o = [ORFactory idArray:tracker range:range];
    for(ORInt k=range.low;k <= range.up;k++)
        [o set: [ORFactory intVar: tracker domain: RANGE(tracker, 0, 1)] at: k];
    if([tracker conformsToProtocol: @protocol(ORModel)]) {
        id<ORExpr> sumExpr = [ORFactory sum: tracker over: range suchThat: nil of:^id<ORExpr>(ORInt i) { return [o at: i]; }];
        [(id<ORModel>)tracker add: [ORFactory expr: sumExpr equal: [ORFactory integer: tracker value: 1]]];
    }
    return (id<ORIntVarArray>)o;
}

@end