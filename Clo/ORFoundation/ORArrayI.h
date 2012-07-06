/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <Foundation/Foundation.h>
#import "ORTypes.h"
#import "ORData.h"
#import "ORTracker.h"
#import "ORArray.h"

@interface ORIntArrayI : NSObject<NSCoding,ORIntArray> {
   id<ORTracker> _tracker;
   ORInt*          _array;
   ORInt             _low;
   ORInt              _up;
   ORInt              _nb;
}
-(ORIntArrayI*) initORIntArray: (id<ORTracker>) tracker size: (ORInt) nb value: (ORInt) v;
-(ORIntArrayI*) initORIntArray: (id<ORTracker>) tracker size: (ORInt) nb with: (ORInt(^)(ORInt)) clo;
-(ORIntArrayI*) initORIntArray: (id<ORTracker>) tracker range: (ORRange) range value: (ORInt) v;
-(ORIntArrayI*) initORIntArray: (id<ORTracker>) tracker range: (ORRange) range with: (ORInt(^)(ORInt)) clo;
-(ORIntArrayI*) initORIntArray: (id<ORTracker>) tracker range: (ORRange) r1 range: (ORRange) r2 with:(ORInt(^)(ORInt,ORInt)) clo;
-(void) dealloc;
-(ORInt) at: (ORInt) value;
-(ORInt) low;
-(ORInt) up;
-(NSUInteger)count;
-(NSString*)description;
-(id<ORTracker>) tracker;
//-(ORInt)virtualOffset;   
-(id<ORExpr>) index: (id<ORExpr>) idx;
- (void)encodeWithCoder:(NSCoder *)aCoder;
- (id)initWithCoder:(NSCoder *)aDecoder;
@end

@interface ORIdArrayI : NSObject<NSCoding,ORIdArray> {
   id<ORTracker>  _tracker;
   id*              _array;
   ORInt              _low;
   ORInt               _up;
   ORInt               _nb;   
}
-(ORIdArrayI*)initORIdArray: (id<ORTracker>)tracker range:(ORRange)range;
-(id) at: (ORInt) value;
-(void) set: (id) x at: (ORInt) value;
-(ORInt) low;
-(ORInt) up;
-(NSUInteger)count;
-(NSString*)description;
-(id<ORTracker>) tracker;
//-(CPInt) virtualOffset;   
-(id<ORExpr>) index: (id<ORExpr>) idx;
-(void)encodeWithCoder:(NSCoder*) aCoder;
-(id)initWithCoder:(NSCoder*) aDecoder;
@end
