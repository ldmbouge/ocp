/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <Foundation/Foundation.h>
#import "ORTracker.h"
#import "ORSet.h"


@interface OROPTSelect : NSObject

-(OROPTSelect*) initOROPTSelectWithRange: (id<ORIntIterator>) range suchThat: (ORInt2Bool) filter orderedBy: (ORInt2Float) order randomized: (BOOL) randomized;
-(void)           dealloc;
-(ORInt)              min;
-(ORInt)              max;
-(ORInt)              any;
-(ORInt)           choose;
@end


@interface ORSelectI : NSObject<ORSelect>
-(id<ORSelect>) initORSelectI: (id<ORIntIterator>) range suchThat: (ORInt2Bool) filter orderedBy: (ORInt2Float) order randomized: (BOOL) randomized;
-(void)           dealloc;
-(ORInt)              min;
-(ORInt)              max;
-(ORInt)              any;
@end

