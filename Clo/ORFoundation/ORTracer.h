/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORTrail.h>
#import <ORFoundation/OREngine.h>

@protocol ORCommand;
@protocol ORSearchEngine;
@protocol ORProblem;
@protocol ORCheckpoint;
@protocol ORTrail;
@protocol ORPost;
@class ORCommandList;
@class ORTrailI;
@class ORMemoryTrailI;
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
@optional -(void) addCommand: (id<ORConstraint>) com;
@optional -(id<ORCheckpoint>) captureCheckpoint;
@optional -(ORStatus) restoreCheckpoint:(id<ORCheckpoint>)acp  inSolver:(id<ORSearchEngine>)engine model:(id<ORPost>)model;
@optional -(ORStatus) restoreProblem:(id<ORProblem>)p inSolver:(id<ORSearchEngine>)engine model:(id<ORPost>)model;
@optional -(id<ORProblem>) captureProblem;
@end

@protocol ORProblem <NSObject>
-(void) addCommand: (id<ORConstraint>) c;
-(ORBool) apply: (bool(^)(id<ORConstraint>))clo;
-(ORCommandList*) theList;
-(ORInt)sizeEstimate;
@end

@protocol ORCheckpoint <NSObject>
-(void)letgo;
-(id)grab;
-(void)setNode:(ORInt)nid;
-(ORInt)nodeId;
-(ORInt)sizeEstimate;
@end

@interface DFSTracer : NSObject<ORTracer> 
-(DFSTracer*) initDFSTracer: (id<ORTrail>) trail memory:(id<ORMemoryTrail>)mt;
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
-(SemTracer*) initSemTracer: (id<ORTrail>) trail memory:(id<ORMemoryTrail>)mt;
-(void)       dealloc;
-(ORInt)      pushNode;
-(id)         popNode; 
-(id)         popToNode: (ORInt) n;
-(void)       reset;
-(id<ORTrail>)   trail;
-(void)       addCommand:(id<ORConstraint>)com;
-(id<ORCheckpoint>)captureCheckpoint;
-(ORStatus)   restoreCheckpoint:(id<ORCheckpoint>)acp  inSolver: (id<ORSearchEngine>) engine model:(id<ORPost>)m;
-(ORStatus)   restoreProblem:(id<ORProblem>)p  inSolver: (id<ORSearchEngine>) engine model:(id<ORPost>)m;
-(id<ORProblem>)  captureProblem;
-(void)       trust;
-(ORInt)      level;
@end
