/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "Foundation/Foundation.h"
#import "ORUtilities/ORUtilities.h"
#import "ORFoundation/ORTracker.h"

@protocol OREngine;

@protocol ORSnapshot
-(void) restoreInto: (NSArray*) av;
-(int)  intValue;
-(BOOL) boolValue;
@end

@protocol ORSavable<NSObject>
-(id) snapshot;
@end

@protocol ORSolution <NSObject>
-(ORInt) intValue: (id) var;
-(BOOL) boolValue: (id) var;
-(NSUInteger) count;
-(void) restoreInto: (id<OREngine>) engine;
@end

@protocol ORSolutionProtocol <NSObject>
-(void)        saveSolution;
-(void)     restoreSolution;
-(id<ORSolution>) solution;
@end

@interface ORFailException : NSObject
-(ORFailException*)init;
@end

@protocol OREngine <NSObject,ORTracker,ORSolutionProtocol>
-(ORStatus)        close;
-(bool)            closed;
-(void)            trackObject:(id)obj;
-(NSMutableArray*) allVars;
-(id) trail;
-(void)propagate;
@end