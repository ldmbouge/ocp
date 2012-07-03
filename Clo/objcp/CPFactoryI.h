/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/


#import <Foundation/Foundation.h>
#import "CPSolver.h"
#import "CP.h"
#import "CPFactory.h"

@class CPAVLTree;

@interface CPInternalFactory : NSObject

+(CPAVLTree*) AVLTree: (id<CP>) cp;
+(id<IntEnumerator>) AVLTreeKeyIntEnumerator: (id<CP>) cp for: (CPAVLTree*) tree;

@end;
