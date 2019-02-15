/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <Foundation/Foundation.h>
#import <ORUtilities/ORTypes.h>

typedef struct {
    ORInt found;
    ORInt index;
} ORSelectorResult;

@protocol ORSelect <NSObject>
-(void) setTieBreak:(ORInt2Double) tb;
-(ORSelectorResult)              min;
-(ORSelectorResult)              max;
-(ORSelectorResult)              any;
@end

@protocol ORSelector<NSObject>
-(void)commit;
-(void)neighbor:(ORDouble)v do:(ORClosure)block;
@end
