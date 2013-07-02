/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <Foundation/Foundation.h>
#import <ORUtilities/ORTypes.h>
#import "ORObject.h"
#import "ORData.h"
#import "ORSet.h"
#import "ORAVLTree.h"
@protocol ORVisitor;

@interface ORIntSetI : ORObject<ORIntSet>

-(id<ORIntSet>) initORIntSetI;
-(void) dealloc;
-(ORBool) member: (ORInt) v;
-(void) insert: (ORInt) v;
-(void) delete: (ORInt) v;
-(ORInt) min;
-(ORInt) max;
-(ORInt) size;
-(void) copyInto: (id<ORIntSet>) S;
-(void)enumerateWithBlock:(ORInt2Void)block;
-(NSString*) description;
-(id<IntEnumerator>) enumerator;
-(void)visit:(id<ORVisitor>)v;
-(id<ORIntSet>)inter:(id<ORIntSet>)s2;
-(void)encodeWithCoder:(NSCoder *)aCoder;
-(id)initWithCoder:(NSCoder *)aDecoder;
@end

@interface ORIntRangeI : ORObject<ORIntRange,NSCopying>
-(id<ORIntRange>) initORIntRangeI: (ORInt) low up: (ORInt) up;
-(ORInt) low;
-(ORInt) up;
-(ORBool) isDefined;
-(ORBool) inRange: (ORInt)e;
-(ORInt) size;
-(NSString*) description;
-(void)visit:(id<ORVisitor>)v;
-(id<IntEnumerator>) enumerator;
-(void)enumerateWithBlock:(ORInt2Void)block;
-(void)encodeWithCoder:(NSCoder *)aCoder;
-(id)initWithCoder:(NSCoder *)aDecoder;
@end
