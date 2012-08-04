/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <ORFoundation/cont.h>
#import <objcp/CPTypes.h>

@protocol CPSolver;
@protocol ORTracer;
@protocol CPExplorer;
@class Checkpoint;

@interface CPHeist : NSObject {
   NSCont*        _cont;
   Checkpoint*   _theCP;
}
-(CPHeist*)initCPProblem:(NSCont*)c from:(Checkpoint*)cp;
-(NSCont*)cont;
-(Checkpoint*)theCP;
@end

@protocol CPStealing
-(CPHeist*) steal;
-(BOOL)willingToShare;
@end

/*
@protocol CPSearchController <NSObject,NSCopying>
-(void)                      setController: (id<CPSearchController>) controller;
-(id<CPSearchController>)    controller;
-(void)       setup;
-(void)       cleanup;

-(CPInt)      addChoice: (NSCont*) k;
-(void)       fail;
-(void)       succeeds;
-(void)       trust;

-(void)       startTry;
-(void)       startTryLeft;
-(void)       exitTryLeft;
-(void)       startTryRight;
-(void)       exitTryRight;
-(void)       exitTry;

-(void)       startTryall;
-(void)       exitTryall;
-(void)       startTryallBody;
-(void)       exitTryallBody;
-(void)       startTryallOnFailure;
-(void)       exitTryallOnFailure;
-(BOOL)       isFinitelyFailed;
-(id)         copy;
@optional -(CPHeist*)steal;
@optional -(BOOL)willingToShare;
@end
*/

@class Checkpoint;
@protocol ControllerEvt 
@optional -(void)newChoice:(Checkpoint*)cp onSolver:(id<CPSolver>)solver;
@end


