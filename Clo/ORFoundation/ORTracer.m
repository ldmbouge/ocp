/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#include <pthread.h>


@interface ORProblemI : NSObject<ORProblem> {    // a semantic sub-problem description (as a set of constraints aka commands)
   ORCommandList* _cstrs;
   ORInt          _id;
}
-(ORProblemI*) init;
-(void) dealloc;
-(NSString*) description;
-(void) addCommand: (id<ORConstraint>) c;
-(ORBool) apply: (BOOL(^)(id<ORConstraint>))clo;
-(ORCommandList*) theList;
-(ORInt)sizeEstimate;
@end

@interface ORCheckpointI : NSObject<ORCheckpoint> { // a semantic path description (for incremental jumping around).
   @package
   ORCmdStack* _path;
   ORInt     _nodeId;
   ORInt        _cnt;
   id<ORMemoryTrail> _mt;
}
-(ORCheckpointI*)initCheckpoint: (ORCmdStack*) cmds memory:(id<ORMemoryTrail>)mt;
-(void)dealloc;
-(NSString*)description;
-(void)setNode:(ORInt)nid;
-(ORInt)nodeId;
-(void)letgo;
-(id)grab;
-(ORInt)sizeEstimate;
-(id<ORMemoryTrail>)getMT;
@end


@interface ORCmdStack : NSObject {
//@private
@package
   ORCommandList** _tab;
   ORUInt _mxs;
   ORUInt _sz;
}
-(ORCmdStack*) initCPCmdStack: (ORUInt) mx;
-(void) dealloc;
-(void) pushList: (ORInt) node memory:(ORInt)mh;
-(void) pushCommandList: (ORCommandList*) list;
-(void) addCommand:(id<ORConstraint>)c;
-(ORCommandList*) popList;
-(ORCommandList*) peekAt:(ORUInt)d;
-(ORUInt) size;
@end

// =======================================================================

@implementation ORCmdStack
-(ORCmdStack*)initCPCmdStack:(ORUInt)mx
{
   self = [super init];
   _mxs = mx;
   _sz  = 0;
   _tab = malloc(sizeof(ORCommandList*)*_mxs);
   return self;
}
-(void)dealloc
{
   //NSLog(@"dealloc command stack %p [%lu]\n",self,_sz);
   for(ORInt i=(ORInt)_sz-1;i>=0;--i)
      [_tab[i] letgo];
   free(_tab);
   [super dealloc];
}

inline static void pushCommandList(ORCmdStack* cmd,ORCommandList* list)
{
   if (cmd->_sz >= cmd->_mxs) {
      cmd->_tab = realloc(cmd->_tab,sizeof(ORCommandList*)*cmd->_mxs*2);
      cmd->_mxs <<= 1;
   }
   cmd->_tab[cmd->_sz++] = grab(list);
}
inline static ORCommandList* peekAt(ORCmdStack* cmd,ORUInt d) { return cmd->_tab[d];}
inline static ORUInt getStackSize(ORCmdStack* cmd) { return cmd->_sz;}
inline static ORCommandList* popList(ORCmdStack* cmd) { return cmd->_tab[--cmd->_sz];}

-(void)pushList:(ORInt)node memory:(ORInt)mh
{
   if (_sz >= _mxs) {
      _tab = realloc(_tab,sizeof(ORCommandList*)*_mxs*2);
      _mxs <<= 1;
   }
   if (_sz  >= 1) {
      [_tab[_sz - 1] setMemoryTo:mh];
   }
   ORCommandList* list = [ORCommandList newCommandList:node from:mh to:mh];
   _tab[_sz++] = list;
}
-(void)pushCommandList:(ORCommandList*)list
{
   pushCommandList(self, list);
}
-(void)addCommand:(id<ORConstraint>)c
{
   [_tab[_sz-1] insert:c];
}
-(ORCommandList*)popList
{
   assert(_sz > 0);
   return _tab[--_sz];
}
-(ORCommandList*)peekAt:(ORUInt)d
{
   return _tab[d];
}
-(ORUInt)size
{
   return _sz;
}
-(NSString*)description
{
   NSMutableString* buf = [NSMutableString stringWithCapacity:512];
   for(ORUInt i = 0;i<_sz;i++) {
      [buf appendFormat:@"d:%d = ",i];
      [buf appendString:[_tab[i] description]];
      [buf appendString:@"\n"];
   }
   return buf;
}
@end

@implementation ORProblemI
-(ORProblemI*)init
{
   static ORInt _counter = 0;
   self = [super init];
   _cstrs = [ORCommandList newCommandList:-1 from:0 to:0];
   _id = _counter++;
   return self;
}
-(void)dealloc
{
   [_cstrs letgo];
   [super dealloc];
}
-(ORInt)sizeEstimate
{
   return [_cstrs length];
}
-(void)addCommand:(id<ORConstraint>)c
{
   [_cstrs insert:c];
}
-(ORBool)apply:(BOOL(^)(id<ORConstraint>))clo
{
   return [_cstrs apply:clo];
}
-(ORCommandList*)theList
{
   return _cstrs;
}

-(NSString*)description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<ORProblemI: %p @  %d  = %@>",self,_id,_cstrs];
   return buf;
}
@end

@implementation ORCheckpointI
-(ORCheckpointI*)initCheckpoint:(ORCmdStack*) cmds memory:(id<ORMemoryTrail>)mt
{
   self = [super init];
   _path = [[ORCmdStack alloc] initCPCmdStack:64];
   ORInt ub = getStackSize(cmds);
   for(ORInt i=0;i< ub;i++)
      pushCommandList(_path, peekAt(cmds, i));
   _nodeId = -1;
   _mt = [mt copy];
   return self;
}
-(void)dealloc
{
   NSLog(@"dealloc checkpoint %p\n",self);
   [_path release];
   [_mt release];
   [super dealloc];
}
-(NSString*)description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"checkpoint = %@",_path];
   return buf;
}
-(id<ORMemoryTrail>)getMT
{
   return _mt;
}
-(ORInt)sizeEstimate
{
   return [_path size];
}
-(void)setNode:(ORInt)nid
{
   _nodeId = nid;
}
-(ORInt)nodeId
{
   return _nodeId;
}
-(ORCmdStack*)commands
{
   return _path;
}

#if TARGET_OS_IPHONE
+(id)newCheckpoint:(ORCmdStack*) cmds memory:(id<ORMemoryTrail>)mt
{
   id ptr = [super allocWithZone:NULL];
   *(Class*)ptr = self;
   ptr = [ptr initCheckpoint:cmds memory:mt];
   ((ORCheckpointI*)ptr)->_cnt = 1;
   return ptr;
}
-(void) letgo
{
   assert(_cnt > 0);
   if (--_cnt == 0) {
      [_mt clear];
      [self release];
   }
}
#else
static __thread id checkPointCache = NULL;

+(id)newCheckpoint:(ORCmdStack*) cmds memory:(id<ORMemoryTrail>)mt
{
   id ptr = checkPointCache;
   if (ptr) {
      checkPointCache = *(id*)ptr;
      *(Class*)ptr = self;
      ORCheckpointI* theCP = (ORCheckpointI*)ptr;
      theCP->_cnt = 1;      
      ORInt i = 0;
      BOOL pfxEq = YES;
      const ORInt csz = getStackSize(cmds);
      const ORInt cpsz = getStackSize(theCP->_path);
      while (pfxEq && i < csz  && i < cpsz) {
         pfxEq = commandsEqual(peekAt(cmds, i), peekAt(theCP->_path, i));
         i += pfxEq;
      }
      while (i != getStackSize(theCP->_path)) {
         ORCommandList* lst = popList(theCP->_path);
         [lst letgo];
      }
      ORInt ub = getStackSize(cmds);
      for(;i < ub;i++)
         pushCommandList(theCP->_path, peekAt(cmds, i));
      [theCP->_mt reload:mt];
   } else {
      //NSLog(@"Fresh checkpoint...");
      ptr = [super allocWithZone:NULL];
      *(Class*)ptr = self;
      ptr = [ptr initCheckpoint:cmds memory:mt];
      ((ORCheckpointI*)ptr)->_cnt = 1;
   }
   return ptr;
}
-(void) letgo
{
   assert(_cnt > 0);
   if (--_cnt == 0) {
      [_mt clear];
      id vLossCache = checkPointCache;
      *(id*)self = vLossCache;
      checkPointCache = self;
   }
}
#endif

-(id)grab
{
   _cnt += 1;
   return self;
}

@end

// =======================================================================
@implementation DFSTracer
{
@private
   ORTrailI*          _trail;
   ORMemoryTrailI*       _mt;
   ORTrailIStack*   _trStack;
   ORInt           _lastNode;
   TRInt              _level;
}
-(DFSTracer*) initDFSTracer: (ORTrailI*) trail memory:(ORMemoryTrailI*)mt
{
   self = [super init];
   _trail = [trail retain];
   _mt    = [mt retain];
   _trStack = [[ORTrailIStack alloc] initTrailStack: _trail memory:_mt];
   _lastNode = 0;
   _level = makeTRInt(_trail, 0);
   return self;
}
-(void) dealloc
{
   NSLog(@"Releasing DFSTracer %p\n",self);
   [_trail release];
   [_mt release];
   [_trStack release];
   [super dealloc];
}
-(ORInt) pushNode
{
   [_trStack pushNode: _lastNode];
   [_trail incMagic];
   _lastNode++;
   assignTRInt(&_level, _level._val + 1, _trail);
   return _lastNode - 1;
}
-(id) popNode
{
   [_trStack popNode];
   // necessary since the "onFailure" executes in the parent.
   // Indeed, any change must be trailed in the parent node again
   // so the magic must increase.
   [_trail incMagic];
   return nil;
}
-(id) popToNode: (ORInt) n
{
   [_trStack popNode: n];
   // not clear this is needed for the intended uses but this is safe anyway
   [_trail incMagic];
   return nil;
}
-(void) reset
{
   while (![_trStack empty]) {
      [_trStack popNode];
   }
   [self pushNode];
}
-(id<ORTrail>)   trail
{
   return _trail;
}
-(void)       trust
{
   assignTRInt(&_level, _level._val + 1, _trail);
}
-(ORInt)      level
{
   return _level._val;
}
@end

// ==============================================================================

@implementation SemTracer {
   ORTrailI*          _trail;
   ORMemoryTrailI*       _mt;
   ORTrailIStack*   _trStack;
   ORInt           _lastNode;
   ORCmdStack*         _cmds;
   TRInt              _level;
}
-(SemTracer*) initSemTracer: (ORTrailI*) trail memory:(ORMemoryTrailI*)mt
{
   self = [super init];
   _trail = trail;
   _mt    = mt;
   _trStack = [[ORTrailIStack alloc] initTrailStack: _trail memory:mt];
   _lastNode = 0;
   _cmds = [[ORCmdStack alloc] initCPCmdStack:32];
   _level = makeTRInt(_trail, 0);
   return self;
}
-(void) dealloc
{
   NSLog(@"Releasing SemTracer %p\n",self);
   [self reset];
   [_trStack release];
   [_cmds release];
   [super dealloc];
}
-(ORInt) pushNode
{
   [_trStack pushNode: _lastNode];
   [_cmds pushList: _lastNode memory:[_mt trailSize]];     // add a list of constraint
   [_trail incMagic];
   _lastNode++;
   assert([_cmds size] == [_trStack size]);
   assignTRInt(&_level,_level._val+1,_trail);
   return _lastNode - 1;
}
-(id) popNode
{
   [_trStack popNode];
   ORCommandList* theList = [_cmds popList];
   // necessary since the "onFailure" executes in the parent.
   // Indeed, any change must be trailed in the parent node again
   // so the magic must increase.
   [_trail incMagic];
   assert([_cmds size] == [_trStack size]);
   return theList;
}
-(id) popToNode: (ORInt) n
{
   assert(false);
   [_trStack popNode: n];
   // not clear this is needed for the intended uses but this is safe anyway
   [_trail incMagic];
   return nil;
}
-(void)       trust
{
 //  assignTRInt(&_level,_level._val+1,_trail);
   [self pushNode];
}
-(ORInt)      level
{
   return _level._val;
}

-(void) reset
{
   assert([_cmds size] == [_trStack size]);
   while (![_trStack empty]) {
      [_trStack popNode];
      ORCommandList* clist = [_cmds popList];
      [clist letgo];
   }
   assert(_level._val == 0);
   [self pushNode];
}
-(id<ORTrail>)   trail
{
   return _trail;
}
-(id<ORMemoryTrail>)getMT
{
   return _mt;
}
-(void)addCommand:(id<ORConstraint>)com
{
   [_cmds addCommand:com];
}
-(id<ORCheckpoint>)captureCheckpoint
{
   ORCheckpointI* ncp = [ORCheckpointI  newCheckpoint:_cmds memory:_mt];
   ncp->_nodeId = [self pushNode];
   return ncp;
}
-(id<ORProblem>)captureProblem
{
   ORUInt ub = [_cmds size];
   ORProblemI* np = [[ORProblemI alloc] init];
   for(ORInt i=0;i< ub;i++) {
      [[_cmds peekAt:i] apply:^BOOL(id<ORConstraint> theCommand) {
         [np addCommand:[theCommand retain]];
         return true;
      }];
   }
   return np;
}

-(ORStatus)restoreCheckpoint:(ORCheckpointI*)acp inSolver:(id<ORSearchEngine>)engine model:(id<ORPost>)model
{
   /*
    NSLog(@"SemTracer STATE: %@ - in thread %p",[self description],[NSThread currentThread]);
   NSLog(@"restoreCP  : %@",acp);
   NSLog(@"into tracer: %@",_cmds);
   NSLog(@"-----------------------------");
    */
   ORCmdStack* toRestore =  acp->_path;
   int i=0;
   bool pfxEq = true;
   while (pfxEq && i <  getStackSize(_cmds) && i < getStackSize(toRestore)) {
      pfxEq = commandsEqual(peekAt(_cmds, i), peekAt(toRestore, i));
      i += pfxEq;
   }
   if (i <= getStackSize(_cmds) && i <= getStackSize(toRestore)) {
      // the suffix in _cmds [i+1 .. cmd.top] should be backtracked.
      // the suffix in toRestore [i+1 toR.top] should be replayed
      while (i != getStackSize(_cmds)) {
         trailPop(_trStack);
         ORCommandList* lst = popList(_cmds);
         [lst letgo];
      }
      //NSLog(@"SemTracer AFTER SUFFIXUNDO: %@ - in thread %p",[self description],[NSThread currentThread]);
      //NSLog(@"allVars: %p %@",[NSThread currentThread],[fdm allVars]);
      [_trail incMagic];
      for(ORInt j=i;j < getStackSize(toRestore);j++) {
         ORCommandList* theList = peekAt(toRestore,j);
         [_mt comply:acp->_mt upTo:theList];
         [_trStack pushNode:theList->_ndId];
         [_trail incMagic];
         ORStatus s = tryfail(^ORStatus{
            BOOL pOk = [theList apply: ^BOOL(id<ORConstraint> c) {
               ORStatus cok = [model post:c];
               return cok != ORFailure;
            }];
            if (!pOk) {
               //NSLog(@"allVars: %p %@",[NSThread currentThread],[fdm allVars]);
               return ORFailure;
            }
            [engine propagate];
            [_cmds pushCommandList:theList];
            assert([_cmds size] == [_trStack size]);
            return ORSuspend;
         }, ^ORStatus{
            [_cmds pushCommandList:theList];
            assert([_cmds size] == [_trStack size]);
            return ORFailure;
         });
         if (s==ORFailure)
            return s;
      }
      //[_mt comply:acp->_mt from:[peekAt(_cmds, getStackSize(_cmds)-1) memoryTo] to:[acp->_mt trailSize]];
      return [engine enforceObjective];
   }
   return ORSuspend;
}

-(ORStatus)restoreProblem:(id<ORProblem>)p inSolver:(id<ORSearchEngine>)engine model:(id<ORPost>)model
{
   [_trStack pushNode: _lastNode++];
   [_trail incMagic];
   return tryfail(^ORStatus{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-variable"
      bool ok = [p apply:^bool(id<ORConstraint> c) {
          return [model post:c] != ORFailure;
      }];
      assert(ok);
#pragma clang diagnostic pop
      [[p theList] setNodeId:_lastNode-1];
      [_cmds pushCommandList:[p theList]];
      assert([_cmds size] == [_trStack size]);
      return [engine propagate];
   }, ^ORStatus{
      [_cmds pushCommandList:[p theList]];
      return ORFailure;
   });
}

-(NSString*)description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"TRACER(%p) = %@",self,_cmds];
   return buf;
}
@end
