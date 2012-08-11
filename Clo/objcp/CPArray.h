/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import "ORFoundation/ORArray.h"
#import "objcp/CPData.h"

/*
@protocol CPIntArray <ORIntArray>
-(id<ORExpr>) elt: (id<ORExpr>) idx;
@end


@protocol CPVarArray <ORIdArray>
-(id<CPVar>) at: (ORInt) value;
-(void) set: (id<CPVar>) x at: (ORInt) value;
-(id<CPExpr>) elt: (id<CPExpr>) idx;
-(id<CPSolver>) cp;
@end

@protocol CPIntVarArray <CPVarArray> 
-(id<ORIntVar>) at: (ORInt) value;
-(void) set: (id<ORIntVar>) x at: (ORInt) value;
-(id<ORIntVar>)objectAtIndexedSubscript: (NSUInteger)key;
-(void)setObject: (id<ORIntVar>) newValue atIndexedSubscript: (NSUInteger) idx;
@end

@protocol CPIntVarMatrix <ORIdMatrix>
-(ORInt) arity;
-(id<ORIntVar>) flat:(ORInt)i;
-(id<ORIntVar>) at: (ORInt) i1 : (ORInt) i2;
-(id<ORIntVar>) at: (ORInt) i1 : (ORInt) i2 : (ORInt) i3;
-(void) set: (id) x at: (ORInt) i1 : (ORInt) i2;
-(void) set: (id) x at: (ORInt) i1 : (ORInt) i2 : (ORInt) i3;
-(id<ORIntRange>) range: (ORInt) i;
-(NSUInteger)count;
-(NSString*) description;
-(id<CPSolver>) cp;
@end
*/

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
-(id<CPSolver>) cp;
@end


