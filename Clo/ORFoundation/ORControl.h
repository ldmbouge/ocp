/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <Foundation/Foundation.h>
#import "ORFoundation/ORSet.h"

@interface ORControl : NSObject
+(void) forall: (id<ORIntIterator>) S suchThat: (ORInt2Bool) suchThat orderedBy: (ORInt2Int) order do: (ORInt2Void) body;
@end
