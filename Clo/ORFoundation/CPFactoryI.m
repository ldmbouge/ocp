/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/


#import "CPFactoryI.h"
#import "ORFoundation/ORAVLTree.h"

@implementation CPInternalFactory 

+(ORAVLTree*) AVLTree
{
    return [[ORAVLTree alloc] initEmptyAVL];
}
+(id<IntEnumerator>) AVLTreeKeyIntEnumerator: (ORAVLTree*) tree
{
    return [[ORAVLTreeKeyIntEnumerator alloc] initORAVLTreeKeyIntEnumerator: tree];
}
@end;
