/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>


@protocol ORCommand;
@protocol OREngine;
@protocol ORProblem;
@protocol ORCheckpoint;
@protocol ORTrail;
@class ORCommandList;
@class ORTrailI;
@class SemTracer;
@class ORCmdStack;

@protocol ORTracer <NSObject>
-(ORInt)      pushNode;
-(id)         popNode;
-(id)         popToNode: (ORInt) n;
-(void)       reset;
-(id<ORTrail>)   trail;
-(void)       trust;
-(ORInt)      level;
@optional -(void) addCommand: (id<ORCommand>) com;
@optional -(id<ORCheckpoint>) captureCheckpoint;
@optional -(ORStatus) restoreCheckpoint:(id<ORCheckpoint>)acp  inSolver:(id<OREngine>) engine;
@optional -(ORStatus) restoreProblem:(id<ORProblem>)p inSolver:(id<OREngine>) engine;
@optional -(id<ORProblem>) captureProblem;
@end

@protocol ORProblem <NSObject>
-(void) addCommand: (id<ORCommand>) c;
-(NSData*) packFromSolver: (id<OREngine>) engine;
-(bool) apply: (bool(^)(id<ORCommand>))clo;
-(ORCommandList*) theList;
@end

@protocol ORCheckpoint <NSObject>
-(void)pushCommandList:(ORCommandList*)aList;
-(void)setNode:(ORInt)nid;
-(ORInt)nodeId;
-(NSData*)packFromSolver: (id<OREngine>) engine;
@end

@interface DFSTracer : NSObject<ORTracer> 
-(DFSTracer*) initDFSTracer: (id<ORTrail>) trail;
-(void)       dealloc;
-(ORInt)      pushNode;
-(id)         popNode;
-(id)         popToNode: (ORInt) n;
-(void)       reset;
-(id<ORTrail>)   trail;
-(void)       trust;
-(ORInt)      level;
@end

@interface SemTracer : NSObject<ORTracer>
-(SemTracer*) initSemTracer: (id<ORTrail>) trail;
-(void)       dealloc;
-(ORInt)      pushNode;
-(id)         popNode;
-(id)         popToNode: (ORInt) n;
-(void)       reset;
-(id<ORTrail>)   trail;
-(void)       addCommand:(id<ORCommand>)com;
-(id<ORCheckpoint>)captureCheckpoint;
-(ORStatus)   restoreCheckpoint:(id<ORCheckpoint>)acp  inSolver: (id<OREngine>) engine;
-(ORStatus)   restoreProblem:(id<ORProblem>)p  inSolver: (id<OREngine>) engine;
-(id<ORProblem>)  captureProblem;
-(void)       trust;
-(ORInt)      level;
@end

@interface SemTracer (Packing)
+(id<ORProblem>)      unpackProblem:(NSData*)msg forEngine:(id<OREngine>) engine;
+(id<ORCheckpoint>)unpackCheckpoint:(NSData*)msg forEngine:(id<OREngine>) engine;
@end
