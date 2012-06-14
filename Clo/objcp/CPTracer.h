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
#import <objcp/CPTypes.h>
#import <objcp/CPData.h>
#import "CPTrail.h"

@protocol CPConstraint;
@protocol CPCommand;
@protocol CPSolver;
@protocol AbstractSolver;
@class CPCommandList;
@class CPSolverI;
@class Checkpoint;
@class CPProblem;

// PVH: This optional must disappear
@protocol CPTracer <NSObject>
-(CPInt)  pushNode;
-(id)         popNode;
-(id)         popToNode: (CPInt) n;
-(void)       reset;
-(CPTrail*)   trail;
@optional -(void)addCommand:(id<CPCommand>)com;
@optional -(Checkpoint*)captureCheckpoint;
@optional -(CPStatus)restoreCheckpoint:(Checkpoint*)acp  inSolver:(id<AbstractSolver>)fdm;
@optional -(CPStatus)restoreProblem:(CPProblem*)p inSolver:(id<AbstractSolver>)fdm;
@optional -(CPProblem*)captureProblem;
@end

@interface DFSTracer : NSObject<CPTracer> {
@private
    CPTrail*          _trail;
    CPTrailStack*   _trStack;
    CPInt      _lastNode;
}
-(DFSTracer*) initDFSTracer: (CPTrail*) trail;
-(void)       dealloc;
-(CPInt)  pushNode;
-(id)         popNode;
-(id)         popToNode: (CPInt) n;
-(void)       reset;
-(CPTrail*)   trail;
@end

@interface CPCmdStack : NSObject<NSCoding> {
@private
   CPCommandList** _tab;
   CPUInt _mxs;
   CPUInt _sz;
}
-(CPCmdStack*)initCPCmdStack:(CPUInt)mx;
-(void)dealloc;
-(void)pushList:(CPInt)node;
-(void)pushCommandList:(CPCommandList*)list;
-(void)addCommand:(id<CPCommand>)c;
-(CPCommandList*)popList;
-(CPCommandList*)peekAt:(CPUInt)d;
-(CPUInt)size;
@end

@class SemTracer;

@interface CPProblem : NSObject<NSCoding> {
   CPCommandList* _cstrs;
}
-(CPProblem*)init;
-(void)dealloc;
-(NSString*)description;
-(void)addCommand:(id<CPCommand>)c;
-(NSData*)packFromSolver:(id<CPSolver>)fdm;
-(bool)apply:(bool(^)(id<CPCommand>))clo;
-(CPCommandList*)theList;
+(CPProblem*)unpack:(NSData*)msg forSolver:(id)cp;
@end

@interface Checkpoint : NSObject<NSCoding> {
   CPCmdStack* _path;
   CPInt   _nodeId;
}
-(Checkpoint*)initCheckpoint:(CPUInt)sz;
-(void)dealloc;
-(NSString*)description;
-(void)pushCommandList:(CPCommandList*)aList;
-(void)setNode:(CPInt)nid;
-(CPInt)nodeId;
-(NSData*)packFromSolver:(id<CPSolver>)fdm;
+(Checkpoint*)unpack:(NSData*)msg forSolver:(id)fdm;
@end

@interface SemTracer : NSObject<CPTracer> {
@private
   CPTrail*          _trail;
   CPTrailStack*   _trStack;
   CPInt      _lastNode;
   CPCmdStack*        _cmds;
}
-(SemTracer*)initSemTracer:(CPTrail*)trail;
-(void)dealloc;
-(CPInt) pushNode;
-(id)         popNode;
-(id)         popToNode: (CPInt) n;
-(void)       reset;
-(CPTrail*)   trail;
-(void)addCommand:(id<CPCommand>)com;
-(Checkpoint*)captureCheckpoint;
-(CPStatus)restoreCheckpoint:(Checkpoint*)acp  inSolver:(id<AbstractSolver>)fdm;
-(CPStatus)restoreProblem:(CPProblem*)p inSolver:(id<AbstractSolver>)fdm;
-(CPProblem*)captureProblem;
@end
