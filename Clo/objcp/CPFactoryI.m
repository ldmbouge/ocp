/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/


#import "CPFactoryI.h"
#import "CPI.h"
#import "CPAVLTree.h"

@implementation CPInternalFactory 

+(CPAVLTree*) AVLTree: (id<CP>) cp
{
    return [[CPAVLTree alloc] initEmptyAVL];
}
+(id<IntEnumerator>) AVLTreeKeyIntEnumerator: (id<CP>) cp for: (CPAVLTree*) tree
{
    return [[CPAVLTreeKeyIntEnumerator alloc] initCPAVLTreeKeyIntEnumerator: tree];
}
@end;
