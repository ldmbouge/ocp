/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORUtilities/ORUtilities.h>
#import <ORFoundation/ORTracker.h>

@protocol ORSearchEngine;
@protocol ORObjectiveFunction;
@protocol ORTrail;

@interface ORFailException : NSObject
-(ORFailException*)init;
@end

@protocol OREngine <NSObject,ORTracker>
@end

@protocol ORSearchEngine <OREngine>
-(ORStatus)           close;
-(ORBool)            closed;
-(id)   trackMutable:(id)obj;
-(NSMutableArray*) variables;
-(id<ORTrail>) trail;
-(ORStatus)currentStatus;
-(ORStatus)propagate;
-(ORStatus)enforceObjective;
-(void)tryEnforceObjective;
-(id<ORObjectiveFunction>)objective;
-(ORUInt) getBackjumpLevel;
@end
