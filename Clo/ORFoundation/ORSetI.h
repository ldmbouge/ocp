/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <Foundation/Foundation.h>
#import "ORFoundation/ORSet.h"
#import "ORFoundation/ORAVLTree.h"

@interface ORIntSetI : NSObject<ORIntSet> {
    ORAVLTree*     _avl;
}
-(id<ORIntSet>) initORIntSetI;
-(void) dealloc;
-(bool) member: (ORInt) v;
-(void) insert: (ORInt) v;
-(void) delete: (ORInt) v;
-(ORInt) size;
-(NSString*) description;
-(id<IntEnumerator>) enumerator;
-(void)encodeWithCoder:(NSCoder *)aCoder;
-(id)initWithCoder:(NSCoder *)aDecoder;
@end

