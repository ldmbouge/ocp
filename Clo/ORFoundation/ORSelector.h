/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <Foundation/Foundation.h>
#import <ORUtilities/ORTypes.h>

@protocol ORSelect <NSObject>
-(ORInt)              min;
-(ORInt)              max;
-(ORInt)              any;
@end

@protocol ORSweep<NSObject>
-(void)commit;
-(void)forMininum:(ORFloat)v do:(ORClosure)block;
@end