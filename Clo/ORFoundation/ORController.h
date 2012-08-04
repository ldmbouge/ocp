/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <ORFoundation/cont.h>

@protocol CPSearchController <NSObject,NSCopying>
-(void)                      setController: (id<CPSearchController>) controller;
-(id<CPSearchController>)    controller;
-(void)       setup;
-(void)       cleanup;

-(ORInt)      addChoice: (NSCont*) k;
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
-(ORInt)  addChoice: (NSCont*) k;
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

