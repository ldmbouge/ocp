/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <Foundation/Foundation.h>

@protocol ORObjective <NSObject>
-(ORStatus) check;
-(void)     updatePrimalBound;
-(ORInt)    primalBound;
@end

@protocol ORSolver <NSObject,ORTracker,ORSolutionProtocol>
-(ORStatus)        close;
-(bool)            closed;
-(void)            trackObject:(id)obj;
-(NSMutableArray*) allVars;
-(id<ORObjective>) objective;
@end