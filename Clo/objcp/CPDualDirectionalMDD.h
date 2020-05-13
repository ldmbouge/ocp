/************************************************************************
 Mozilla Public License

 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <objcp/objcp.h>
#import <objcp/CPTopDownMDDNode.h>
#import "CPTopDownMDDWithArcs.h"
#import <CPUKernel/CPUKernel.h>
#import <CPUKernel/CPConstraintI.h>
#import <CPUKernel/CPGroup.h>
#import <objcp/CPBitDom.h>
#import <objcp/CPVar.h>

@interface CPDualDirectionalMDD : CPMDDRelaxationWithArcs {
@protected
    size_t _numBottomUpBytes;
}
-(id) initCPDualDirectionalMDD:(id<CPEngine>)engine over:(id<CPIntVarArray>)x relaxationSize:(ORInt)relaxationSize spec:(MDDStateSpecification *)spec equalBuckets:(bool)equalBuckets usingSlack:(bool)usingSlack recommendationStyle:(MDDRecommendationStyle)recommendationStyle gamma:(id*)gamma;
-(void) recalcBottomUpArcCache:(MDDArc*)arc childTopDown:(char*)childTopDown childBottomUp:(char*)childBottomUp variable:(int)variable;
-(void) performBottomUpWithCache;
-(void) performBottomUpWithoutCache;
@end
