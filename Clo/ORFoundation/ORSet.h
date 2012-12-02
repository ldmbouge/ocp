/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <Foundation/Foundation.h>
#import "ORFoundation/ORAVLTree.h"

@protocol ORIntIterator <NSObject>
-(void) iterate: (ORInt2Void) f;
-(ORInt) size;
-(id<IntEnumerator>) enumerator;
@end

@protocol ORIntSet <ORIntIterator>
-(bool) member: (ORInt) v;
-(void) insert: (ORInt) v;
-(void) delete: (ORInt) v;
-(ORInt) min;
-(ORInt) max;
-(NSString*) description;
@end

@protocol ORIntRange <ORIntIterator>
-(ORInt) low;
-(ORInt) up;
-(bool) inRange: (ORInt)e;
-(bool) isDefined;
-(NSString*) description;
@end
