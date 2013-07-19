/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <Foundation/Foundation.h>
#import "ORFoundation/ORAVLTree.h"
#import "ORObject.h"

@protocol ORIntIterable <ORObject>
-(void)enumerateWithBlock:(ORInt2Void)block;
-(ORInt) size;
-(ORInt) low;
-(id<IntEnumerator>) enumerator;
@end

@protocol ORIntSet <ORIntIterable>
-(ORBool) member: (ORInt) v;
-(void) insert: (ORInt) v;
-(void) delete: (ORInt) v;
-(ORInt) min;
-(ORInt) max;
-(NSString*) description;
-(void) copyInto: (id<ORIntSet>) S;
-(id<ORIntSet>)inter:(id<ORIntSet>)s2;
@end

@protocol ORIntRange <ORIntIterable>
-(ORInt) low;
-(ORInt) up;
-(ORBool) isDefined;
-(ORBool) inRange: (ORInt)e;
-(NSString*) description;
-(void)enumerateWithBlock:(ORInt2Void)block;
@end

@protocol ORFloatRange
-(ORFloat)low;
-(ORFloat)up;
-(ORBool)isDefined;
-(ORBool)inRange:(ORFloat)e;
-(NSString*)description;
@end