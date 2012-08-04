/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <ORFoundation/ORTrail.h>

@protocol ORCommand;
@protocol ORSolver;
@class ORCommandList;

@protocol ORTracer <NSObject>
-(ORInt)      pushNode;
-(id)         popNode;
-(id)         popToNode: (ORInt) n;
-(void)       reset;
-(ORTrail*)   trail;
-(void)       trust;
-(ORInt)      level;
@end

@interface DFSTracer : NSObject<ORTracer> 
-(DFSTracer*) initDFSTracer: (ORTrail*) trail;
-(void)       dealloc;
-(ORInt)      pushNode;
-(id)         popNode;
-(id)         popToNode: (ORInt) n;
-(void)       reset;
-(ORTrail*)   trail;
-(void)       trust;
-(ORInt)      level;
@end
