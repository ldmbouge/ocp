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
@class ORCommandList;
@class ORTrailI;
@class ORCheckpoint;
@class ORProblem;
@class SemTracer;
@class ORCmdStack;

@protocol ORTracer <NSObject>
-(ORInt)      pushNode;
-(id)         popNode;
-(id)         popToNode: (ORInt) n;
-(void)       reset;
-(ORTrailI*)   trail;
-(void)       trust;
-(ORInt)      level;
@optional -(void) addCommand: (id<ORCommand>) com;
@optional -(ORCheckpoint*) captureCheckpoint;
@optional -(ORStatus) restoreCheckpoint:(ORCheckpoint*)acp  inSolver:(id<OREngine>) engine;
@optional -(ORStatus) restoreProblem:(ORProblem*)p inSolver:(id<OREngine>) engine;
@optional -(ORProblem*) captureProblem;
@end

@interface DFSTracer : NSObject<ORTracer> 
-(DFSTracer*) initDFSTracer: (ORTrailI*) trail;
-(void)       dealloc;
-(ORInt)      pushNode;
-(id)         popNode;
-(id)         popToNode: (ORInt) n;
-(void)       reset;
-(ORTrailI*)   trail;
-(void)       trust;
-(ORInt)      level;
@end

@interface ORProblem : NSObject<NSCoding> {    // a semantic sub-problem description (as a set of constraints aka commands)
   ORCommandList* _cstrs;
}
-(ORProblem*) init;
-(void) dealloc;
-(NSString*) description;
-(void) addCommand: (id<ORCommand>) c;
-(NSData*) packFromSolver: (id<OREngine>) engine;
-(bool) apply: (bool(^)(id<ORCommand>))clo;
-(ORCommandList*) theList;
+(ORProblem*) unpack: (NSData*)msg fOREngine:(id<ORSolver>) solver;
@end

@interface ORCheckpoint : NSObject<NSCoding> { // a semantic path description (for incremental jumping around).
   ORCmdStack* _path;
   ORInt     _nodeId;
}
-(ORCheckpoint*)initCheckpoint: (ORUInt) sz;
-(void)dealloc;
-(NSString*)description;
-(void)pushCommandList:(ORCommandList*)aList;
-(void)setNode:(ORInt)nid;
-(ORInt)nodeId;
-(NSData*)packFromSolver: (id<OREngine>) engine;
+(ORCheckpoint*)unpack:(NSData*)msg fOREngine:(id<ORSolver>) solver;
@end

@interface SemTracer : NSObject<ORTracer>
-(SemTracer*) initSemTracer: (ORTrailI*) trail;
-(void)       dealloc;
-(ORInt)      pushNode;
-(id)         popNode;
-(id)         popToNode: (ORInt) n;
-(void)       reset;
-(ORTrailI*)   trail;
-(void)       addCommand:(id<ORCommand>)com;
-(ORCheckpoint*)captureCheckpoint;
-(ORStatus)   restoreCheckpoint:(ORCheckpoint*)acp  inSolver: (id<OREngine>) engine;
-(ORStatus)   restoreProblem:(ORProblem*)p  inSolver: (id<OREngine>) engine;
-(ORProblem*)  captureProblem;
-(void)       trust;
-(ORInt)      level;
@end