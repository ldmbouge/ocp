/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import "ORFoundation/ORArray.h"
#import "objcp/CPData.h"

@protocol CPTRIntArray <NSObject> 
-(ORInt)  at: (ORInt) value;
-(void)  set: (ORInt) value at: (ORInt) value;  
-(ORInt) low;
-(ORInt) up;
-(NSUInteger) count;
-(NSString*) description;
-(id<CPSolver>) cp;
@end


@protocol CPTRIntMatrix <NSObject> 
-(ORInt) at: (ORInt) i1 : (ORInt) i2;
-(ORInt) at: (ORInt) i1 : (ORInt) i2 : (ORInt) i3;
-(void) set: (ORInt) value at: (ORInt) i1 : (ORInt) i2;
-(void) set: (ORInt) value at: (ORInt) i1 : (ORInt) i2 : (ORInt) i3;
-(ORInt) add: (ORInt) delta at: (ORInt) i1 : (ORInt) i2;
-(ORInt) add: (ORInt) delta at: (ORInt) i1 : (ORInt) i2 : (ORInt) i3;
-(id<ORIntRange>) range: (ORInt) i;
-(NSUInteger)count;
-(NSString*) description;
-(id<CPSolver>) solver;
@end


