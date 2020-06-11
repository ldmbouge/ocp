/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/OREngine.h>
#import <ORFoundation/ORConstraint.h>
#import <CPUKernel/CPEngine.h>

@protocol CPValueEvent;
@protocol CPConstraint;
@protocol CPClosureList;
@class CPCoreConstraint;

@protocol CPLEngine <CPEngine>
-(void) addConstraint:(CPCoreConstraint*)c;
-(void) addConstraint:(CPCoreConstraint *)c withJumpLevel:(ORUInt) level;
-(ORUInt) getLevel;
-(ORUInt) getBackjumpLevel;
-(ORBool) retry;
@end
