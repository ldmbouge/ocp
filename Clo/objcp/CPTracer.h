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
@class Checkpoint;
@class CPProblem;

// PVH: This optional must disappear

@interface DFSTracer : NSObject<CPTracer> {
@private
   ORTrail*          _trail;
   ORTrailStack*   _trStack;
   ORInt          _lastNode;
   TRInt             _level;
}
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

@interface CPCmdStack : NSObject<NSCoding> {
@private
   ORCommandList** _tab;
   ORUInt _mxs;
   ORUInt _sz;
}
-(CPCmdStack*) initCPCmdStack: (ORUInt) mx;
-(void) dealloc;
-(void) pushList: (ORInt) node;
-(void) pushCommandList: (ORCommandList*) list;
-(void) addCommand:(id<ORCommand>)c;
-(ORCommandList*) popList;
-(ORCommandList*) peekAt:(ORUInt)d;
-(ORUInt) size;
@end

@class SemTracer;

@interface CPProblem : NSObject<NSCoding> {
   ORCommandList* _cstrs;
}
-(CPProblem*) init;
-(void) dealloc;
-(NSString*) description;
-(void) addCommand: (id<ORCommand>) c;
-(NSData*) packFromSolver: (id<ORSolver>)solver;
-(bool) apply: (bool(^)(id<ORCommand>))clo;
-(ORCommandList*) theList;
+(CPProblem*) unpack: (NSData*)msg forSolver:(id)cp;
@end

@interface Checkpoint : NSObject<NSCoding> {
   CPCmdStack* _path;
   ORInt   _nodeId;
}
-(Checkpoint*)initCheckpoint: (ORUInt) sz;
-(void)dealloc;
-(NSString*)description;
-(void)pushCommandList:(ORCommandList*)aList;
-(void)setNode:(ORInt)nid;
-(ORInt)nodeId;
-(NSData*)packFromSolver: (id<ORSolver>) solver;
+(Checkpoint*)unpack:(NSData*)msg forSolver:(id)solver;
@end

@protocol CPSemTracer <NSObject>
-(ORInt)      pushNode;
-(id)         popNode;
-(id)         popToNode: (ORInt) n;
-(void)       reset;
-(ORTrail*)   trail;
-(void)       trust;
-(ORInt)      level;
@optional -(void) addCommand: (id<ORCommand>) com;
@optional -(Checkpoint*) captureCheckpoint;
@optional -(ORStatus) restoreCheckpoint:(Checkpoint*)acp  inSolver:(id<ORSolver>)solver;
@optional -(ORStatus) restoreProblem:(CPProblem*)p inSolver:(id<ORSolver>)solver;
@optional -(CPProblem*) captureProblem;
@end

@interface SemTracer : NSObject<CPTracer> {
@private
   ORTrail*          _trail;
   ORTrailStack*   _trStack;
   ORInt          _lastNode;
   CPCmdStack*        _cmds;
   TRInt             _level;
}
-(SemTracer*) initSemTracer: (ORTrail*) trail;
-(void)       dealloc;
-(ORInt)      pushNode;
-(id)         popNode;
-(id)         popToNode: (ORInt) n;
-(void)       reset;
-(ORTrail*)   trail;
-(void)       addCommand:(id<ORCommand>)com;
-(Checkpoint*)captureCheckpoint;
-(ORStatus)   restoreCheckpoint:(Checkpoint*)acp  inSolver: (id<ORSolver>)solver;
-(ORStatus)   restoreProblem:(CPProblem*)p  inSolver: (id<ORSolver>)solver;
-(CPProblem*)  captureProblem;
-(void)       trust;
-(ORInt)      level;
@end
