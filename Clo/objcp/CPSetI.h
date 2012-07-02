/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <Foundation/Foundation.h>
#import "CP.h"
#import "CPSet.h"
#import "CPAVLTree.h"


@interface CPIntSetI : NSObject<CPIntSet> {
    id<CP>         _cp;
    CPAVLTree*     _avl;
}
-(id<CPIntSet>) initCPIntSetI: (id<CP>) cp;
-(void) dealloc;
-(bool) member: (CPInt) v;
-(void) insert: (CPInt) v;
-(void) delete: (CPInt) v;
-(CPInt) size;
-(NSString*) description;
-(id<CP>) cp;
-(id<IntEnumerator>) enumerator;
-(void)encodeWithCoder:(NSCoder *)aCoder;
-(id)initWithCoder:(NSCoder *)aDecoder;
@end

