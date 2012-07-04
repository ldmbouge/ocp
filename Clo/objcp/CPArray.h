/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import "ORFoundation/ORArray.h"

@protocol CPIntArray <ORIntArray>
@end

@protocol CPVarArray <NSObject>
-(id<CPVar>) at: (CPInt) value;
-(void) set: (id<CPVar>) x at: (CPInt) value;
-(CPInt) low;
-(CPInt) up;
-(NSUInteger)count;
-(NSString*) description;
-(id<CP>) cp;
@end

@protocol CPIntVarArray <NSObject> 
-(id<CPIntVar>) at: (CPInt) value;
-(void) set: (id<CPIntVar>) x at: (CPInt) value;
-(CPInt) low;
-(CPInt) up;
-(NSUInteger)count;
-(NSString*) description;
-(id<CP>) cp;
@end

@protocol CPIntVarMatrix <NSObject> 
-(id<CPIntVar>) at: (CPInt) i1 : (CPInt) i2;
-(id<CPIntVar>) at: (CPInt) i1 : (CPInt) i2 : (CPInt) i3;
-(CPRange) range: (CPInt) i;
-(NSUInteger)count;
-(NSString*) description;
-(id<CP>) cp;
@end

@protocol CPTRIntArray <NSObject> 
-(CPInt)  at: (CPInt) value;
-(void)  set: (CPInt) value at: (CPInt) value;  
-(CPInt) low;
-(CPInt) up;
-(NSUInteger) count;
-(NSString*) description;
-(id<CP>) cp;
@end

@protocol CPIntMatrix <NSObject> 
-(CPInt) at: (CPInt) i1 : (CPInt) i2;
-(CPInt) at: (CPInt) i1 : (CPInt) i2 : (CPInt) i3;
-(void) set: (CPInt) value at: (CPInt) i1 : (CPInt) i2;
-(void) set: (CPInt) value at: (CPInt) i1 : (CPInt) i2 : (CPInt) i3;
-(CPRange) range: (CPInt) i;
-(NSUInteger)count;
-(NSString*) description;
-(id<CP>) cp;
@end

@protocol CPTRIntMatrix <NSObject> 
-(CPInt) at: (CPInt) i1 : (CPInt) i2;
-(CPInt) at: (CPInt) i1 : (CPInt) i2 : (CPInt) i3;
-(void) set: (CPInt) value at: (CPInt) i1 : (CPInt) i2;
-(void) set: (CPInt) value at: (CPInt) i1 : (CPInt) i2 : (CPInt) i3;
-(CPRange) range: (CPInt) i;
-(NSUInteger)count;
-(NSString*) description;
-(id<CP>) cp;
@end


