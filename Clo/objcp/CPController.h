/************************************************************************
 MIT License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 Permission is hereby granted, free of charge, to any person obtaining
 a copy of this software and associated documentation files (the
 "Software"), to deal in the Software without restriction, including
 without limitation the rights to use, copy, modify, merge, publish,
 distribute, sublicense, and/or sell copies of the Software, and to
 permit persons to whom the Software is furnished to do so, subject to
 the following conditions:
 
 The above copyright notice and this permission notice shall be
 included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 ***********************************************************************/

#import <Foundation/Foundation.h>
#import "cont.h"

@protocol CPSolver;
@protocol CPTracer;
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
-(CPHeist*)steal;
-(BOOL)willingToShare;
@end

@protocol CPSearchController <NSObject,NSCopying>
-(void)                   setController: (id<CPSearchController>) controller;
-(id<CPSearchController>)    controller;
-(void)       setup;
-(void)       cleanup;

-(CPInt)  addChoice: (NSCont*) k;
-(void)       fail;
-(void)       succeeds;

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

@class Checkpoint;
@protocol ControllerEvt 
@optional -(void)newChoice:(Checkpoint*)cp onSolver:(id<CPSolver>)solver;
@end


@interface CPDefaultController : NSObject <NSCopying,CPSearchController>
{
   id<CPSearchController> _controller;    // Delegation chain for stackable limits
}
-(id) initCPDefaultController;
-(void) setController: (id<CPSearchController>) controller;
-(id<CPSearchController>) controller;
-(void)       setup;
-(void)       cleanup;
-(CPInt)  addChoice: (NSCont*) k;
-(void)       fail;
-(void)       succeeds;

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
@end

@interface CPNestedController : CPDefaultController {
   id<CPSearchController> _parent;        // This is not a mistake. Delegation chain for NESTED controllers (failAll).   
   BOOL                   _isFF;
}
-(id)initCPNestedController:(id<CPSearchController>)chain;
-(void) setParent:(id<CPSearchController>) controller;
-(void) fail;
-(void) succeeds;
-(void) finitelyFailed;
-(BOOL) isFinitelyFailed;
@end
