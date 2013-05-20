/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <ORFoundation/ORTracer.h>
#import <CPUKernel/CPTypes.h>
#import "ORTrailI.h"
#include <pthread.h>


@interface ORProblemI : NSObject<NSCoding,ORProblem> {    // a semantic sub-problem description (as a set of constraints aka commands)
   ORCommandList* _cstrs;
   ORInt          _id;
}
-(ORProblemI*) init;
-(void) dealloc;
-(NSString*) description;
-(void) addCommand: (id<ORCommand>) c;
-(NSData*) packFromSolver: (id<ORSearchEngine>) engine;
-(ORBool) apply: (BOOL(^)(id<ORCommand>))clo;
-(ORCommandList*) theList;
-(ORInt)sizeEstimate;
@end

@interface ORCheckpointI : NSObject<NSCoding,ORCheckpoint> { // a semantic path description (for incremental jumping around).
   @package
   ORCmdStack* _path;
   ORInt     _nodeId;
   ORInt        _cnt;
}
-(ORCheckpointI*)initCheckpoint: (ORCmdStack*) cmds;
-(void)dealloc;
-(NSString*)description;
-(void)setNode:(ORInt)nid;
-(ORInt)nodeId;
-(NSData*)packFromSolver: (id<ORSearchEngine>) engine;
-(void)letgo;
-(id)grab;
-(ORInt)sizeEstimate;
@end


@interface ORCmdStack : NSObject<NSCoding> {
@private
   ORCommandList** _tab;
   ORUInt _mxs;
   ORUInt _sz;
}
-(ORCmdStack*) initCPCmdStack: (ORUInt) mx;
-(void) dealloc;
-(void) pushList: (ORInt) node;
-(void) pushCommandList: (ORCommandList*) list;
-(void) addCommand:(id<ORCommand>)c;
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

-(void)pushList:(ORInt)node
{
   if (_sz >= _mxs) {
      _tab = realloc(_tab,sizeof(ORCommandList*)*_mxs*2);
      _mxs <<= 1;
   }
   //ORCommandList* list = [[ORCommandList alloc] initCPCommandList:node];
   ORCommandList* list = [ORCommandList newCommandList:node];
   _tab[_sz++] = list;
}
-(void)pushCommandList:(ORCommandList*)list
{
   pushCommandList(self, list);
}
-(void)addCommand:(id<ORCommand>)c
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
-(void)encodeWithCoder:(NSCoder *)aCoder
{
   [aCoder encodeValueOfObjCType:@encode(ORUInt) at:&_mxs];
   [aCoder encodeValueOfObjCType:@encode(ORUInt) at:&_sz];
   for (ORUInt i = 0; i < _sz; i++)
      [aCoder encodeObject:_tab[i]];
}
-(id)initWithCoder:(NSCoder *)aDecoder
{
   self = [super init];
   [aDecoder decodeValueOfObjCType:@encode(ORUInt) at:&_mxs];
   [aDecoder decodeValueOfObjCType:@encode(ORUInt) at:&_sz];
   _tab = malloc(sizeof(ORCommandList*)*_mxs);
   for (ORUInt i =0; i<_sz; i++) {
      _tab[i] = [[aDecoder decodeObject] retain];
      assert(_tab[i]->_cnt > 0);
   }
   return self;
}
@end


#if defined(__MAC_OS_X_VERSION_MIN_REQUIRED) || defined(__linux__)
@interface CPUnarchiver : NSUnarchiver
#else
@interface CPUnarchiver : NSKeyedUnarchiver
#endif
{
   id<ORSearchEngine> _fdm;
}
-(CPUnarchiver*)initForReadingWithData:(NSData*) data andSolver:(id<ORSearchEngine>)fdm;
-(id<ORSearchEngine>)engine;
@end

@implementation CPUnarchiver
-(CPUnarchiver*)initForReadingWithData:(NSData*) data andSolver:(id<ORSearchEngine>)fdm
{
   self = [super initForReadingWithData:data];
   _fdm = [fdm retain];
   return self;
}
-(void)dealloc
{
   [_fdm release];
   [super dealloc];
}
-(id<ORSearchEngine>)engine
{
   return _fdm;
}
@end

@interface CPProxyTrail : NSObject<NSCoding> {
}
-(id)initProxyTrail;
@end

@interface CPProxyVar : NSObject<NSCoding> {
@private
   ORUInt _id;
}
-(id)initProxyVar:(ORUInt)vid;
@end

@implementation CPProxyTrail

-(id)initProxyTrail
{
   self = [super init];
   return self;
}
-(void)dealloc
{
   [super dealloc];
}
-(void)encodeWithCoder:(NSCoder *)aCoder
{
}
-(id)initWithCoder:(CPUnarchiver *)aDecoder
{
   self = [super init];
   [self dealloc];
   id<ORTrail> theTrail = [[aDecoder engine] trail];
   [theTrail retain];
   return (CPProxyTrail*)theTrail;
}
@end

@implementation CPProxyVar
-(id)initProxyVar:(ORUInt)vid
{
   self = [super init];
   _id = vid;
   return self;
}
-(void)dealloc
{
   [super dealloc];
}
-(void)encodeWithCoder:(NSCoder *)aCoder
{
   [aCoder encodeValueOfObjCType:@encode(ORUInt) at:&_id];
}
-(id)initWithCoder:(CPUnarchiver*)aDecoder
{
   self = [super init];
   [aDecoder decodeValueOfObjCType:@encode(ORUInt) at:&_id];
   id<ORSearchEngine> fdm = [aDecoder engine];
   id theVar = [[[fdm variables] objectAtIndex:_id] retain];
   [self release];
   return theVar;
}
@end

@implementation ORProblemI
-(ORProblemI*)init
{
   static ORInt _counter = 0;
   self = [super init];
   _cstrs = [ORCommandList newCommandList:-1];
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
-(void)addCommand:(id<ORCommand>)c
{
   [_cstrs insert:c];
}
-(ORBool)apply:(BOOL(^)(id<ORCommand>))clo
{
   return [_cstrs apply:clo];
}
-(ORCommandList*)theList
{
   return _cstrs;
}
-(void)encodeWithCoder:(NSCoder *)aCoder
{
   [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_id];
   [aCoder encodeObject:_cstrs];
}
-(id)initWithCoder:(NSCoder *)aDecoder
{
   self = [super init];
   [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_id];
   _cstrs = [[aDecoder decodeObject] retain];
   return self;
}
-(NSString*)description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<ORProblemI: %p @  %d  = %@>",self,_id,_cstrs];
   return buf;
}
-(NSData*)packFromSolver:(id<ORSearchEngine>)fdm
{
   NSMutableData* thePack = [[NSMutableData alloc] initWithCapacity:32];
#if defined(__MAC_OS_X_VERSION_MIN_REQUIRED) || defined(__linux__)
   NSArchiver* archiver = [[NSArchiver alloc] initForWritingWithMutableData:thePack];
#else
   NSKeyedArchiver* archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:thePack];
#endif
   NSArray* dico = [fdm variables];
   //NSLog(@"DICO: %@",dico);
   ORULong nbProxies = [[fdm variables] count] + 1; // 1 extra for the trail proxy
   id* proxies = malloc(sizeof(id)*nbProxies);
   [archiver encodeValueOfObjCType:@encode(ORUInt) at:&nbProxies];
   [dico enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
      proxies[idx] = [[CPProxyVar alloc] initProxyVar:(ORUInt)idx];  // create a proxy
      [archiver encodeObject:proxies[idx]];                  // encode proxy in archive
   }];
   proxies[nbProxies-1]  = [[CPProxyTrail alloc] initProxyTrail];
   [archiver encodeObject:proxies[nbProxies-1]];
   
   [dico enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
      [archiver replaceObject:obj withObject:proxies[idx]];  // setup proxying between real and fake
   }];
   [archiver replaceObject:[fdm trail] withObject:proxies[nbProxies-1]];
   [archiver encodeRootObject:self]; // encode the path.
//   [self release]; // somehow the encodeRootObject retains us twice?
#if defined(__MAC_OS_X_VERSION_MIN_REQUIRED) || defined(__linux__)
#else
   [archiver finishEncoding];
#endif
   [archiver release];
   for(ORInt k=0;k<nbProxies;k++)
      [proxies[k] release];
   free(proxies);
   return thePack;
}
@end

@implementation SemTracer (Packing)
+(id<ORProblem>)unpackProblem:(NSData*)msg fORSearchEngine:(id<ORSearchEngine>)fdm
{
   ORUInt nbProxies = 0;
   id arp  = [[NSAutoreleasePool alloc] init];
   CPUnarchiver* decoder = [[CPUnarchiver alloc] initForReadingWithData:msg andSolver:fdm];
   [decoder decodeValueOfObjCType:@encode(ORUInt) at:&nbProxies];
   id* proxies = malloc(sizeof(id)*nbProxies);
   for(ORUInt k = 0;k<nbProxies;k++) {
      proxies[k] = [decoder decodeObject];
   }
   id<ORProblem> theProblem = [[decoder decodeObject] retain];
   [decoder release];
   [arp release];
   free(proxies);
   return theProblem;
}
+(id<ORCheckpoint>)unpackCheckpoint:(NSData*)msg fORSearchEngine:(id<ORSearchEngine>) fdm
{
   id arp = [[NSAutoreleasePool alloc] init];
   ORUInt nbProxies = 0;
   CPUnarchiver* decoder = [[CPUnarchiver alloc] initForReadingWithData:msg andSolver:fdm];
   [decoder decodeValueOfObjCType:@encode(ORUInt) at:&nbProxies];
   id* proxies = alloca(sizeof(id)*nbProxies);
   for(ORUInt k = 0;k<nbProxies;k++) {
      proxies[k] = [decoder decodeObject];
   }
   id<ORCheckpoint> theCP = [[decoder decodeObject] retain];
   [decoder release];
   [arp release];
   return theCP;
}
@end

@implementation ORCheckpointI
-(ORCheckpointI*)initCheckpoint:(ORCmdStack*) cmds
{
   self = [super init];
   _path = [[ORCmdStack alloc] initCPCmdStack:64];
   ORInt ub = getStackSize(cmds);
   for(ORInt i=0;i< ub;i++)
      pushCommandList(_path, peekAt(cmds, i));
   _nodeId = -1;
   return self;
}
-(void)dealloc
{
   NSLog(@"dealloc checkpoint %p\n",self);
   [_path release];
   [super dealloc];
}
-(NSString*)description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"snap (%p) = %@",self,_path];
   return buf;
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
-(void)encodeWithCoder:(NSCoder *)aCoder
{
   [aCoder encodeObject:_path];
}
-(id)initWithCoder:(NSCoder *)aDecoder
{
   self = [super init];
   _path = [[aDecoder decodeObject] retain];
   return self;
}
-(NSData*)packFromSolver:(id<ORSearchEngine>) solver
{
   NSMutableData* thePack = [[NSMutableData alloc] initWithCapacity:32];
#if defined(__MAC_OS_X_VERSION_MIN_REQUIRED) || defined(__linux__)
   NSArchiver* archiver = [[NSArchiver alloc] initForWritingWithMutableData:thePack];
#else
   NSKeyedArchiver* archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:thePack];
#endif
   NSArray* dico = [solver variables];
   ORULong nbProxies = [[solver variables] count] + 1; // 1 extra for the trail proxy
   __block id* proxies = alloca(sizeof(CPProxyVar*)*nbProxies);
   [archiver encodeValueOfObjCType:@encode(ORUInt) at:&nbProxies];
   [dico enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
      proxies[idx] = [[CPProxyVar alloc] initProxyVar:(ORUInt)idx];  // create a proxy
      [archiver encodeObject:proxies[idx]];                  // encode proxy in archive
   }];
   proxies[nbProxies-1]  = [[CPProxyTrail alloc] initProxyTrail];
   [archiver encodeObject:proxies[nbProxies-1]];
   
   [dico enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
      [archiver replaceObject:obj withObject:proxies[idx]];  // setup proxying between real and fake
   }];
   [archiver replaceObject:[solver trail] withObject:proxies[nbProxies-1]];
   [archiver encodeRootObject:self];                         // encode the path.
#if defined(__MAC_OS_X_VERSION_MIN_REQUIRED) || defined(__linux__)
#else
   [archiver finishEncoding];
#endif
   [archiver release];
   for(ORInt k=0;k<nbProxies;k++)
      [proxies[k] release];
   return thePack;
}


static __thread id checkPointCache = NULL;

+(id)newCheckpoint:(ORCmdStack*) cmds
{
   id ptr = checkPointCache;
   if (ptr) {
      checkPointCache = *(id*)ptr;
      *(Class*)ptr = self;
      ORCheckpointI* theCP = (ORCheckpointI*)ptr;
      theCP->_cnt = 1;      
      ORInt i = 0;
      BOOL pfxEq = YES;
      while (pfxEq && i <  getStackSize(cmds) && i < getStackSize(theCP->_path)) {
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
   } else {
      //NSLog(@"Fresh checkpoint...");
      ptr = [super allocWithZone:NULL];
      *(Class*)ptr = self;
      ptr = [ptr initCheckpoint:cmds];
      ((ORCheckpointI*)ptr)->_cnt = 1;
   }
   return ptr;
}
-(void) letgo
{
   assert(_cnt > 0);
   if (--_cnt == 0) {
      id vLossCache = checkPointCache;
      *(id*)self = vLossCache;
      checkPointCache = self;
   }
}

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
   ORTrailI*        _trail;
   ORTrailIStack*   _trStack;
   ORInt          _lastNode;
   TRInt             _level;
}
-(DFSTracer*) initDFSTracer: (ORTrailI*) trail
{
   self = [super init];
   _trail = [trail retain];
   _trStack = [[ORTrailIStack alloc] initTrailStack: _trail];
   _lastNode = 0;
   _level = makeTRInt(_trail, 0);
   return self;
}
-(void) dealloc
{
   NSLog(@"Releasing DFSTracer %p\n",self);
   [_trail release];
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
   ORTrailIStack*   _trStack;
   ORInt           _lastNode;
   ORCmdStack*         _cmds;
   TRInt              _level;
}
-(SemTracer*) initSemTracer: (ORTrailI*) trail
{
   self = [super init];
   _trail = trail;
   _trStack = [[ORTrailIStack alloc] initTrailStack: _trail];
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
   [_cmds pushList: _lastNode];     // add a list of constraint
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
   assignTRInt(&_level,_level._val+1,_trail);
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
-(void)addCommand:(id<ORCommand>)com
{
   [_cmds addCommand:com];
}
-(id<ORCheckpoint>)captureCheckpoint
{
   //ORCheckpointI* ncp = [[ORCheckpointI alloc] initCheckpoint:_cmds];
   ORCheckpointI* ncp = [ORCheckpointI  newCheckpoint:_cmds];
   ncp->_nodeId = [self pushNode];
   return ncp;
}
-(id<ORProblem>)captureProblem
{
   ORUInt ub = [_cmds size];
   ORProblemI* np = [[ORProblemI alloc] init];
   for(ORInt i=0;i< ub;i++) {
      [[_cmds peekAt:i] apply:^BOOL(id<ORCommand> theCommand) {
         [np addCommand:[theCommand retain]];
         return true;
      }];
   }
   return np;
}

-(ORStatus)restoreCheckpoint:(ORCheckpointI*)acp inSolver:(id<ORSearchEngine>)fdm
{
   /*
    NSLog(@"SemTracer STATE: %@ - in thread %p",[self description],[NSThread currentThread]);
   NSLog(@"restoreCP  : %@",acp);
   NSLog(@"into tracer: %@",_cmds);
   NSLog(@"-----------------------------");
    */
   [fdm clearStatus];
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
         [_trStack pushNode:theList->_ndId];
         [_trail incMagic];
         ORStatus s = tryfail(^ORStatus{
            BOOL pOk = [theList apply:^BOOL(id<ORCommand> c) {
               return [c doIt] != ORFailure;
            }];
            if (!pOk) {
               //NSLog(@"allVars: %p %@",[NSThread currentThread],[fdm allVars]);
               return ORFailure;
            }
            [fdm propagate];
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
      return [fdm enforceObjective];
   }
   return ORSuspend;
}

-(ORStatus)restoreProblem:(id<ORProblem>)p inSolver:(id<ORSearchEngine>)fdm
{
   [_trStack pushNode: _lastNode++];
   [_trail incMagic];
   return tryfail(^ORStatus{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-variable"
      bool ok = [p apply:^bool(id<ORCommand> c) {
         return [c doIt];
      }];
      assert(ok);
#pragma clang diagnostic pop
      [[p theList] setNodeId:_lastNode-1];
      [_cmds pushCommandList:[p theList]];
      assert([_cmds size] == [_trStack size]);
      return [fdm propagate];
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
