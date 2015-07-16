/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <Foundation/Foundation.h>
#import <ORFoundation/ORTracker.h>
#import <ORFoundation/ORSet.h>


@interface OROPTSelect : NSObject
-(OROPTSelect*) initOROPTSelectWithRange: (id<ORIntIterable>) range suchThat: (ORInt2Bool) filter orderedBy: (ORInt2Float) order randomized: (ORBool) randomized;
-(ORInt)              min;
-(ORInt)              max;
-(ORInt)              any;
-(ORInt)           choose;
@end


@interface ORSelectI : ORObject<ORSelect>
-(id<ORSelect>) initORSelectI: (id<ORIntIterable>) range suchThat: (ORInt2Bool) filter orderedBy: (ORInt2Float) order randomized: (ORBool) randomized;
-(ORInt)              min;
-(ORInt)              max;
-(ORInt)              any;
@end


@interface ORMinSelector : ORObject<ORSelector>
-(id)init;
-(void)commit;
-(void)neighbor:(ORFloat)v do:(ORClosure)block;
@end