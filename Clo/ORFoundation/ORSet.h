/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <Foundation/Foundation.h>
#import <ORFoundation/ORObject.h>
#import "rationalUtilities.h"
@protocol ORTracker;

@protocol ORIntIterable <ORObject>
-(void)enumerateWithBlock:(ORInt2Void)block;
-(ORInt) size;
-(ORInt) low;
-(ORInt) atRank:(ORInt)r;
-(id<IntEnumerator>) enumerator;
@end

@protocol ORIntSet <ORIntIterable>
-(ORBool) member: (ORInt) v;
-(void) insert: (ORInt) v;
-(void) delete: (ORInt) v;
-(ORInt) min;
-(ORInt) max;
-(ORInt) atRank:(ORInt)r;
-(NSString*) description;
-(void) copyInto: (id<ORIntSet>) S;
-(id<ORIntSet>)inter:(id<ORIntSet>)s2;
@end

@protocol ORIntRange <ORIntIterable>
-(ORInt) low;
-(ORInt) up;
-(ORBool) isDefined;
-(ORBool) inRange: (ORInt)e;
-(ORBool) isBool;
-(ORInt) atRank:(ORInt)r;
-(NSString*) description;
-(void)enumerateWithBlock:(ORInt2Void)block;
@end

@protocol ORRealRange
-(ORDouble)low;
-(ORDouble)up;
-(ORBool)isDefined;
-(ORBool)inRange:(ORDouble)e;
-(NSString*)description;
@end

@protocol ORFloatRange
-(ORFloat)low;
-(ORFloat)up;
-(ORBool)isDefined;
-(ORBool)inRange:(ORFloat)e;
-(NSString*)description;
@end

@protocol ORRationalRange
-(id<ORRational>)low;
-(id<ORRational>)up;
-(ORBool)isDefined;
-(ORBool)inRange:(id<ORRational>)e;
-(NSString*)description;
@end

@protocol ORDoubleRange
-(ORDouble)low;
-(ORDouble)up;
-(ORBool)isDefined;
-(ORBool)inRange:(ORDouble)e;
-(NSString*)description;
@end



@protocol ORLDoubleRange
-(ORLDouble)low;
-(ORLDouble)up;
-(ORBool)isDefined;
-(ORBool)inRange:(ORLDouble)e;
-(NSString*)description;
@end


id<ORIntSet> filterSet(id<ORTracker> t,id<ORIntIterable> s,ORBool(^cond)(ORInt i));
ORInt sumSet(id<ORIntIterable> s,ORInt(^term)(ORInt i));
