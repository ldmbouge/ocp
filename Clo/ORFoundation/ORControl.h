/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <Foundation/Foundation.h>
#import <ORFoundation/ORSet.h>


@protocol ORForall <NSObject>
-(id<ORForall>) suchThat: (ORInt2Bool) suchThat;
-(id<ORForall>) orderedBy: (ORInt2Int) orderedBy;
-(void) do: (ORInt2Void) body;
@end


@interface ORFactory (Control)
+(id<ORForall>) forall: (id<ORTracker>) tracker set: (id<ORIntIterable>) S;
@end

@interface ORControl : NSObject
+(void) forall: (id<ORIntIterable>) S suchThat: (ORInt2Bool) suchThat orderedBy: (ORInt2Int) order do: (ORInt2Void) body;
+(void) forall: (id<ORIntIterable>) S suchThat: (ORInt2Bool) suchThat orderedByFloat: (ORInt2Float) order do: (ORInt2Void) body;
+(id<ORForall>) forall: (id<ORTracker>) tracker set: (id<ORIntIterable>) S;
@end
