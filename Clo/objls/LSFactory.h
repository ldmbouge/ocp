/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2014 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import "LSEngine.h"
#import <objls/LSVar.h>


@interface LSFactory : NSObject
+(id<LSIntVar>)intVar:(id<LSEngine>)engine domain:(id<ORIntRange>)r;
+(id<LSIntVar>)intVarView:(id<LSEngine>)engine domain:(id<ORIntRange>)r fun:(ORInt(^)())fun src:(NSArray*)src;
+(id<LSIntVar>)intVarView:(id<LSEngine>)engine var:(id<LSIntVar>)x eq:(ORInt)lit;
+(id<LSIntVar>)intVarView:(id<LSEngine>)engine a:(ORInt)a times:(id<LSIntVar>)x plus:(ORInt)b;
+(id<LSIntVarArray>) intVarArray: (id<ORTracker>) cp range: (id<ORIntRange>) range;
+(id<LSIntVarArray>) intVarArray: (id<ORTracker>) cp range: (id<ORIntRange>) range domain:(id<ORIntRange>)dom;
+(id<LSIntVarArray>) intVarArray: (id<ORTracker>)cp range: (id<ORIntRange>) range with: (id<LSIntVar>(^)(ORInt)) clo;
@end
