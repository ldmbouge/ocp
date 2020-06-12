/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORUtilities/ORUtilities.h>
#import <ORFoundation/ORTracer.h>

@protocol ORTracer;
@protocol ORObjectiveValue;
@class ORHeist;

@protocol ORStealing
-(ORHeist*) steal;
-(ORBool)willingToShare;
@end

@interface ORHeist : NSObject {
   NSCont*                _cont;
   id<ORCheckpoint>      _theCP;
   id<ORObjectiveValue> _oValue;
}
-(ORHeist*)init:(NSCont*)c from:(id<ORCheckpoint>)cp oValue:(id<ORObjectiveValue>)ov;
-(NSCont*)cont;
-(id<ORCheckpoint>)theCP;
-(ORInt)sizeEstimate;
-(id<ORObjectiveValue>)oValue;
@end

@protocol ORClone
-(id)clone;
@end

@protocol ORSearchController <NSObject,NSCopying,ORClone>
-(void)                      setController: (id<ORSearchController>) controller;
-(id<ORSearchController>)    controller;
-(void)       setup;
-(void)       cleanup;
-(id<ORSearchController>)clone;
-(id<ORSearchController>)tuneWith:(id<ORTracer>)tracer engine:(id<OREngine>)engine pItf:(id<ORPost>)pItf;
-(ORInt)      addChoice: (NSCont*) k;
-(void)       fail;
-(void)       fail: (BOOL) pruned;
-(void)       succeeds;
-(void)       abort;
-(void)       trust;
-(ORUInt)      depth;


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
-(ORBool)     isFinitelyFailed;
-(ORBool)     isAborted;
-(id)         copy;
@end

@interface ORDefaultController : NSObject <NSCopying,ORSearchController>
{
   id<ORSearchController,ORStealing> _controller;    // Delegation chain for stackable limits
}
-(id) initORDefaultController;
-(void) setController: (id<ORSearchController>) controller;
-(id<ORSearchController>) controller;
-(void)       setup;
-(void)       cleanup;
-(ORInt)      addChoice: (NSCont*) k;
-(void)       fail;
-(void)       fail: (ORBool) pruned;
-(void)       succeeds;
-(void)       abort;
-(void)       trust;
-(ORUInt)      depth;

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
-(ORBool)     isFinitelyFailed;
-(ORBool)     isAborted;
@end

@interface ORNestedController : ORDefaultController
-(id)init:(id<ORSearchController>)chain parent:(id<ORSearchController>)par;
-(void) setParent:(id<ORSearchController>) controller;
-(void) fail;
-(void) succeeds;
-(void) abort;
-(void) finitelyFailed;
-(ORBool) isFinitelyFailed;
-(ORBool) isAborted;
@end

@interface ORDFSController : ORDefaultController <NSCopying,ORSearchController>
+(id<ORSearchController>)proto;
-(id) initTheController:(id<ORTracer>)tracer engine:(id<ORSearchEngine>)engine posting:(id<ORPost>)model;
-(void) dealloc;
-(void) setup;
-(void) cleanup;
-(ORInt) addChoice:(NSCont*)k;
-(void) trust;
-(void) fail;
@end

@protocol ORControllerFactory<NSObject>
-(id<ORSearchController>) makeRootController;
-(id<ORSearchController>) makeNestedController;
@end
