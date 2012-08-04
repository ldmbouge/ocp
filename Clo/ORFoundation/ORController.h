/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <ORFoundation/cont.h>
#import <ORFoundation/ORTracer.h>

@protocol ORTracer;

@protocol ORSearchController <NSObject,NSCopying>
-(void)                      setController: (id<ORSearchController>) controller;
-(id<ORSearchController>)    controller;
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

@interface ORDefaultController : NSObject <NSCopying,ORSearchController>
{
   id<ORSearchController> _controller;    // Delegation chain for stackable limits
}
-(id) initCPDefaultController;
-(void) setController: (id<ORSearchController>) controller;
-(id<ORSearchController>) controller;
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

@interface ORNestedController : ORDefaultController

-(id)initCPNestedController:(id<ORSearchController>)chain;
-(void) setParent:(id<ORSearchController>) controller;
-(void) fail;
-(void) succeeds;
-(void) finitelyFailed;
-(BOOL) isFinitelyFailed;
@end

@interface ORDFSController : ORDefaultController <NSCopying,ORSearchController> {
@private
   NSCont**          _tab;
   ORInt              _sz;
   ORInt              _mx;
   id<ORTracer>   _tracer;
   ORInt          _atRoot;
}
-(id)   initDFSController:(id<ORTracer>) tracer;
-(void) dealloc;
-(void) setup;
-(void) cleanup;
-(ORInt) addChoice:(NSCont*)k;
-(void) trust;
-(void) fail;
@end

