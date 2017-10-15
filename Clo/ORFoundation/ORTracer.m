/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <ORFoundation/ORCommand.h>
#import <ORFoundation/ORTrailI.h>
#import <ORFoundation/ORCommand.h>
#import <ORFoundation/ORTrailI.h>
#import <pthread.h>


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
   int _level;
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
-(void) patchMT:(ORMemoryTrailI*)mt;
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
   assert(cmd->_sz==0 || list.memoryFrom >= cmd->_tab[cmd->_sz-1].memoryTo);
   cmd->_tab[cmd->_sz++] = list;
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
   assert(_sz == 0 || mh >= _tab[_sz-1].memoryTo);
   ORCommandList* list = [ORCommandList newCommandList:node from:mh to:mh];
   _tab[_sz++] = list;
}
-(void) patchMT:(ORMemoryTrailI*)mt
{
   if (_sz  >= 1) {
      if (_tab[_sz-1]->_frozen) {
         ORCommandList* old = _tab[_sz - 1];
         _tab[_sz-1] = [_tab[_sz-1] copy];
         [old letgo];
      }
      [_tab[_sz - 1] setMemoryTo:mt.trailSize];
   }
}

-(void)pushCommandList:(ORCommandList*)list
{
   pushCommandList(self, list);
}
-(void)addCommand:(id<ORConstraint>)c
{
   ORCommandList* cl = _tab[_sz-1];
   if (cl->_frozen) {
      _tab[_sz - 1] = [cl copy];
      [cl letgo];
   }
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
      [buf appendFormat:@"d:%2d = ",i];
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
   for(ORInt i=0;i< ub;i++) {
      assert(i==0 || cmds->_tab[i].memoryFrom >= cmds->_tab[i-1].memoryTo);
      ORCommandList* cl = peekAt(cmds, i);
      //ORCommandList* cc = [cl copy];
      //cc->_frozen = YES;
      grab(cl);
      cl->_frozen = YES;
      pushCommandList(_path,cl);
   }
   _nodeId = -1;
   _mt = [mt copy];
   _level = -1;
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
         ORCommandList* cl = peekAt(theCP->_path, i);
         pfxEq = commandsEqual(peekAt(cmds, i), cl);
         cl->_frozen = YES;
         i += pfxEq;
      }
      while (i != getStackSize(theCP->_path)) {
         ORCommandList* lst = popList(theCP->_path);
         [lst letgo];
      }
      ORInt ub = getStackSize(cmds);
      for(;i < ub;i++) {
         ORCommandList* cl = peekAt(cmds, i); //.copy;
         grab(cl);
         cl->_frozen = YES;
         pushCommandList(theCP->_path,cl);
      }
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
      //[_mt clear];
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
-(void) addCommand: (id<ORConstraint>) com
{
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
   assert([_cmds size] == [_trStack size]);
   [_trStack pushNode: _lastNode];
   [_cmds pushList: _lastNode memory:[_mt trailSize]];     // add a list of constraint
   [_trail incMagic];
   _lastNode++;
   //removed following line 8/18/15 GAJ
//   assert([_cmds size] == [_trStack size]);
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

   [_trStack popNode: n];
   // not clear this is needed for the intended uses but this is safe anyway
   [_trail incMagic];
   return nil;
}
-(void)       trust
{
//<<<<<<< HEAD
//   assignTRInt(&_level,_level._val+1,_trail);
//   [self pushNode];
//=======
   assignTRInt(&_level,_level._val+1,_trail);
   //[self pushNode];  // [ldm] trying to remove this but it causes trouble.
//>>>>>>> master
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
   [_cmds patchMT:_mt];
   ORCheckpointI* ncp = [ORCheckpointI  newCheckpoint:_cmds memory:_mt];
   ncp->_level  = _level._val;
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

   assert([_cmds size] == [_trStack size]);
   ORCmdStack* toRestore =  acp->_path;
   int i=0;
   bool pfxEq = true;
   ORInt cmdSz = getStackSize(_cmds);
   ORInt trtSz = getStackSize(toRestore);
   while (pfxEq && i <  cmdSz && i < trtSz) {
      pfxEq = commandsEqual(_cmds->_tab[i], toRestore->_tab[i]);
      i += pfxEq;
   }
   if (i <= cmdSz && i <= trtSz) {
      // the suffix in _cmds [i+1 .. cmd.top] should be backtracked.
      // the suffix in toRestore [i+1 toR.top] should be replayed
      assert([_cmds size] == [_trStack size]);
      while (i != cmdSz--) {
         trailPop(_trStack);
         ORCommandList* lst = popList(_cmds);
         assert([_cmds size] == [_trStack size]);
         [lst letgo];
      }
      assert([_cmds size] == [_trStack size]);
      ORStatus status = [engine currentStatus];
      if (status == ORFailure)
         return status;

      //NSLog(@"SemTracer AFTER SUFFIXUNDO: %@ - in thread %p",[self description],[NSThread currentThread]);
      //NSLog(@"allVars: %p %@",[NSThread currentThread],[fdm allVars]);
      [_trail incMagic];
      for(ORInt j=i;j < trtSz;j++) {
         assert([_cmds size] == [_trStack size]);
         ORCommandList* theList = toRestore->_tab[j];
         [_trStack pushNode:theList->_ndId];
         [_mt comply:acp->_mt upTo:theList];
         [_trail incMagic];
         ORStatus s = tryfail(^ORStatus{
            ORStatus status = ORSuspend;
            for(id<ORConstraint> c in theList) {
               status = [model post:c];
               if (status == ORFailure)
                  break;
            }
//            [theList apply: ^BOOL(id<ORConstraint> c) {
//               ORStatus s = [model post:c];
//               return s != ORFailure;
//            }];
//            ORStatus status = [engine currentStatus];
            if (status == ORFailure) {
               trailPop(_trStack);
               assert([_cmds size] == [_trStack size]);
               return status;
            }
/*            status = [engine propagate];
            if (status == ORFailure) {
               trailPop(_trStack);
               assert([_cmds size] == [_trStack size]);
               return status;
            }
 */
            [_cmds pushCommandList:grab(theList)]; // .copy
            assert([_cmds size] == [_trStack size]);
            return status;
         }, ^ORStatus{
            [_cmds pushCommandList:grab(theList)]; // .copy
            assert([_cmds size] == [_trStack size]);
            return ORFailure;
         });
         if (s==ORFailure)
            return s;
      }
      assignTRInt(&_level, acp->_level, _trail);
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
          ORStatus s = [model post:c];
         return s != ORFailure;
      }];
      ORStatus status = [engine currentStatus];
      if (status == ORFailure) {
         trailPop(_trStack);
         assert([_cmds size] == [_trStack size]);
         return status;
      }
#pragma clang diagnostic pop
      ORCommandList* tl = [p.theList grab];
      [tl setNodeId:_lastNode-1];
      [_cmds pushList:tl->_ndId memory:[_mt trailSize]];
      [tl apply:^BOOL(id<ORConstraint> c) {
         [_cmds addCommand:c];
         return YES;
      }];
      //[_cmds pushCommandList:tl];
      assert([_cmds size] == [_trStack size]);
      ORStatus rv = [engine propagate];
      return rv;
   }, ^ORStatus{
      assert([_cmds size] == [_trStack size]);
      ORCommandList* tl = [p.theList grab];
      [_cmds pushCommandList:tl];
      assert([_cmds size] == [_trStack size]);
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
