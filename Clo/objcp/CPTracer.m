/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import "CPTracer.h"
#import "CPCommand.h"
#import "CPBasicConstraint.h"
#import "CPSolverI.h"
#import "CPI.h"


#if defined(__MAC_OS_X_VERSION_MIN_REQUIRED) || defined(__linux__)
@interface CPUnarchiver : NSUnarchiver {
#else
@interface CPUnarchiver : NSKeyedUnarchiver {
#endif
    id<CPSolver> _fdm;
}
-(CPUnarchiver*)initForReadingWithData:(NSData*) data andSolver:(id<CPSolver>)fdm;
-(id<CPSolver>)solver;
@end

@implementation CPUnarchiver 
-(CPUnarchiver*)initForReadingWithData:(NSData*) data andSolver:(id<CPSolver>)fdm
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
-(id<CPSolver>)solver
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
   CPUInt _id;
}
-(id)initProxyVar:(CPUInt)vid;
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
   return [[[aDecoder solver] trail] retain];
}
@end

@implementation CPProxyVar
-(id)initProxyVar:(CPUInt)vid
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
   [aCoder encodeValueOfObjCType:@encode(CPUInt) at:&_id];
}
-(id)initWithCoder:(CPUnarchiver*)aDecoder
{
   self = [super init];
   [aDecoder decodeValueOfObjCType:@encode(CPUInt) at:&_id];
   id<CPSolver> fdm = [aDecoder solver];
   id theVar = [[[fdm allVars] objectAtIndex:_id] retain];
   [self release];
   return theVar;
}
@end

@implementation DFSTracer
-(DFSTracer*) initDFSTracer: (ORTrail*) trail
{
   self = [super init];
   _trail = [trail retain];
   _trStack = [[ORTrailStack alloc] initTrailStack: _trail];
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
-(CPInt) pushNode
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
-(id) popToNode: (CPInt) n
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
-(ORTrail*)   trail
{
   return _trail;
}
-(void)       trust
{
   assignTRInt(&_level, _level._val + 1, _trail);
}
-(CPInt)      level
{
   return _level._val;
}
@end

@implementation CPProblem
-(CPProblem*)init
{
   self = [super init];
   _cstrs = [[CPCommandList alloc] initCPCommandList];
   return self;
}
-(void)dealloc
{
   [_cstrs release];
   [super dealloc];
}
-(NSString*)description
{
   return [_cstrs description];
}
-(void)addCommand:(id<CPCommand>)c
{
   [_cstrs insert:c];
}
-(bool)apply:(bool(^)(id<CPCommand>))clo
{
   return [_cstrs apply:clo];
}
-(CPCommandList*)theList
{
   return _cstrs;
}
-(void)encodeWithCoder:(NSCoder *)aCoder
{
   [aCoder encodeObject:_cstrs];
}
-(id)initWithCoder:(NSCoder *)aDecoder
{
   self = [super init];
   _cstrs = [[aDecoder decodeObject] retain];
   return self;
}

-(NSData*)packFromSolver:(id<CPSolver>)fdm
{
   NSMutableData* thePack = [[NSMutableData alloc] initWithCapacity:32];
#if defined(__MAC_OS_X_VERSION_MIN_REQUIRED) || defined(__linux__)
   NSArchiver* archiver = [[NSArchiver alloc] initForWritingWithMutableData:thePack];
#else
   NSKeyedArchiver* archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:thePack];
#endif
   NSArray* dico = [fdm allVars];
   CPULong nbProxies = [[fdm allVars] count] + 1; // 1 extra for the trail proxy
   __block id* proxies = alloca(sizeof(CPProxyVar*)*nbProxies);
   [archiver encodeValueOfObjCType:@encode(CPUInt) at:&nbProxies];
   [dico enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
      proxies[idx] = [[CPProxyVar alloc] initProxyVar:(CPUInt)idx];  // create a proxy
      [archiver encodeObject:proxies[idx]];                  // encode proxy in archive
   }];   
   proxies[nbProxies-1]  = [[CPProxyTrail alloc] initProxyTrail];
   [archiver encodeObject:proxies[nbProxies-1]];
   
   [dico enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
      [archiver replaceObject:obj withObject:proxies[idx]];  // setup proxying between real and fake
   }];   
   [archiver replaceObject:[fdm trail] withObject:proxies[nbProxies-1]];    
   [archiver encodeRootObject:self];                         // encode the path.
#if defined(__MAC_OS_X_VERSION_MIN_REQUIRED) || defined(__linux__)
#else
   [archiver finishEncoding];
#endif
   [archiver release];   
   for(CPInt k=0;k<nbProxies;k++)
      [proxies[k] release];
   return thePack;
}
+(CPProblem*)unpack:(NSData*)msg forSolver:(id)cp
{
   id<CPSolver> fdm = [cp solver];
   CPUInt nbProxies = 0;
   id arp  = [[NSAutoreleasePool alloc] init];
   CPUnarchiver* decoder = [[CPUnarchiver alloc] initForReadingWithData:msg andSolver:fdm];
   [decoder decodeValueOfObjCType:@encode(CPUInt) at:&nbProxies];
   id* proxies = alloca(sizeof(id)*nbProxies);
   for(CPUInt k = 0;k<nbProxies;k++) {
      proxies[k] = [decoder decodeObject];
   }   
   CPProblem* theProblem = [[decoder decodeObject] retain];
   [decoder release];
   [arp release];
   return theProblem;
}
@end

@implementation Checkpoint
-(Checkpoint*)initCheckpoint:(CPUInt)sz
{
   self = [super init];
   _path = [[CPCmdStack alloc] initCPCmdStack:sz];
   _nodeId = -1;
   return self;
}
-(void)dealloc
{
   //NSLog(@"dealloc checkpoint %p\n",self);
   [_path release];
   [super dealloc];
}
-(NSString*)description
{
   return [_path description];
}
-(void)pushCommandList:(CPCommandList*)aList
{
   [_path pushCommandList:aList];
}
-(void)setNode:(CPInt)nid
{
   _nodeId = nid;
}
-(CPInt)nodeId
{
   return _nodeId;
}
-(CPCmdStack*)commands
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
-(NSData*)packFromSolver:(id<CPSolver>) solver
{
   NSMutableData* thePack = [[NSMutableData alloc] initWithCapacity:32];
#if defined(__MAC_OS_X_VERSION_MIN_REQUIRED) || defined(__linux__)
   NSArchiver* archiver = [[NSArchiver alloc] initForWritingWithMutableData:thePack];
#else
   NSKeyedArchiver* archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:thePack];
#endif
    NSArray* dico = [solver allVars];
   CPULong nbProxies = [[solver allVars] count] + 1; // 1 extra for the trail proxy
   __block id* proxies = alloca(sizeof(CPProxyVar*)*nbProxies);
   [archiver encodeValueOfObjCType:@encode(CPUInt) at:&nbProxies];
   [dico enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
      proxies[idx] = [[CPProxyVar alloc] initProxyVar:(CPUInt)idx];  // create a proxy
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
   for(CPInt k=0;k<nbProxies;k++)
      [proxies[k] release];
   return thePack;
}
+(Checkpoint*)unpack:(NSData*)msg forSolver:(id)cp
{   
   id arp = [[NSAutoreleasePool alloc] init];
   id<CPSolver> fdm = [cp solver];
   CPUInt nbProxies = 0;
   CPUnarchiver* decoder = [[CPUnarchiver alloc] initForReadingWithData:msg andSolver:fdm];
   [decoder decodeValueOfObjCType:@encode(CPUInt) at:&nbProxies];
   id* proxies = alloca(sizeof(id)*nbProxies);
   for(CPUInt k = 0;k<nbProxies;k++) {
      proxies[k] = [decoder decodeObject];
   }   
   Checkpoint* theCP = [[decoder decodeObject] retain];
   [decoder release];
   [arp release];
   return theCP;
}

@end


@implementation SemTracer
-(SemTracer*) initSemTracer: (ORTrail*) trail
{
   self = [super init];
   _trail = trail;
   _trStack = [[ORTrailStack alloc] initTrailStack: _trail];
   _lastNode = 0;
   _cmds = [[CPCmdStack alloc] initCPCmdStack:32];
   return self;
}
-(void) dealloc
{
   NSLog(@"Releasing SemTracer %p\n",self);
   [_trStack release];
   [_cmds release];
   [super dealloc];    
}
-(CPInt) pushNode
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
   CPCommandList* theList = [_cmds popList];
	// necessary since the "onFailure" executes in the parent.
	// Indeed, any change must be trailed in the parent node again
	// so the magic must increase. 
	[_trail incMagic]; 
   assert([_cmds size] == [_trStack size]);
   return theList;
}
-(id) popToNode: (CPInt) n
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
-(CPInt)      level
{
   return _level._val;
}

-(void) reset
{
   assert([_cmds size] == [_trStack size]);
   while (![_trStack empty]) {
      [_trStack popNode];
      CPCommandList* clist = [_cmds popList];
      [clist release];
   }
   assert(_level._val == 0);
	[self pushNode];
}
-(ORTrail*)   trail
{
   return _trail;
}
-(void)addCommand:(id<CPCommand>)com
{
   [_cmds addCommand:com];
}
-(Checkpoint*)captureCheckpoint
{
   CPUInt ub = [_cmds size];
   //bool isEmpty = [[_cmds peekAt:ub-1] empty];
   Checkpoint* ncp = [[Checkpoint alloc] initCheckpoint:[_cmds size]];
   for(CPInt i=0;i< ub;i++)
      [ncp pushCommandList: [_cmds peekAt:i]];
   [ncp setNode: [self pushNode]];
   return ncp;
}
-(CPProblem*)captureProblem
{
   CPUInt ub = [_cmds size];
   CPProblem* np = [[CPProblem alloc] init];
   for(CPInt i=0;i< ub;i++) {
      [[_cmds peekAt:i] apply:^bool(id<CPCommand> theCommand) {
         [np addCommand:[theCommand retain]];
         return true;
      }];
   }
   return np;
}

-(CPStatus)restoreCheckpoint:(Checkpoint*)acp inSolver:(id<CPSolver>)fdm
{
   //NSLog(@"SemTracer STATE: %@ - in thread %p",[self description],[NSThread currentThread]);
   CPCmdStack* toRestore = [acp commands];
   int i=0;
   bool pfxEq = true;
   while (pfxEq && i < [_cmds size] && i < [toRestore size]) {
      pfxEq = [[_cmds peekAt:i] equalTo: [toRestore peekAt:i]];      
      i += pfxEq;      
   }
   if (i <= [_cmds size] && i <= [toRestore size]) {
      // the suffix in _cmds [i+1 .. cmd.top] should be backtracked. 
      // the suffix in toRestore [i+1 toR.top] should be replayed
      while (i != [_cmds size]) {
         [_trStack popNode];
         CPCommandList* lst = [_cmds popList];
         [lst release];
      }
      //NSLog(@"SemTracer AFTER SUFFIXUNDO: %@ - in thread %p",[self description],[NSThread currentThread]);
      //NSLog(@"allVars: %p %@",[NSThread currentThread],[fdm allVars]);
      [_trail incMagic]; 
      for(CPInt j=i;j < [toRestore size];j++) {
         CPCommandList* theList = [toRestore peekAt:j];
         [_trStack pushNode:[theList getNodeId]];
         [_trail incMagic];
         bool pOk = [theList apply:^bool(id<CPCommand> c) {
            return [c doIt];               
         }];
         if (!pOk) {
            //NSLog(@"allVars: %p %@",[NSThread currentThread],[fdm allVars]);
            return CPFailure;  
         }
         @try {
            [fdm propagate];
         } @catch(CPFailException* ex) {
            @throw;
         } @finally {
            [_cmds pushCommandList:theList];
            assert([_cmds size] == [_trStack size]);            
         }
      }
   }
   return CPSuspend;
}

-(CPStatus)restoreProblem:(CPProblem*)p inSolver:(id<CPSolver>)fdm
{
   [_trStack pushNode: _lastNode++];
   [_trail incMagic];
   bool ok = [p apply:^bool(id<CPCommand> c) {
      return [c doIt];
   }];
   if (!ok) return CPFailure;
   [_cmds pushCommandList:[p theList]];
   assert([_cmds size] == [_trStack size]);
   return [fdm propagate];
}

-(NSString*)description
{
   return [_cmds description];
}
@end

@implementation CPCmdStack
-(CPCmdStack*)initCPCmdStack:(CPUInt)mx
{
   self = [super init];
   _mxs = mx;
   _sz  = 0;
   _tab = malloc(sizeof(CPCommandList*)*_mxs);   
   return self;
}
-(void)dealloc
{
   //NSLog(@"dealloc command stack %p [%lu]\n",self,_sz);
   for(CPInt i=(CPInt)_sz-1;i>=0;--i)
      [_tab[i] release];
   free(_tab);
   [super dealloc];
}
-(void)pushList:(CPInt)node
{
   if (_sz >= _mxs) {
      _tab = realloc(_tab,sizeof(id<CPCommand>)*_mxs*2);
      _mxs <<= 1;
   }
   CPCommandList* list = [[CPCommandList alloc] initCPCommandList:node];
   _tab[_sz++] = list;
}
-(void)pushCommandList:(CPCommandList*)list
{  
   if (_sz >= _mxs) {
      _tab = realloc(_tab,sizeof(id<CPCommand>)*_mxs*2);
      _mxs <<= 1;
   }
   _tab[_sz++] = [list retain];
}
-(void)addCommand:(id<CPCommand>)c
{
   [_tab[_sz-1] insert:c];
}
-(CPCommandList*)popList
{
   assert(_sz > 0);
   return _tab[--_sz];
}
-(CPCommandList*)peekAt:(CPUInt)d
{
   return _tab[d];
}
-(CPUInt)size
{
   return _sz;
}
-(NSString*)description
{
   NSMutableString* buf = [NSMutableString stringWithCapacity:512];
   for(CPUInt i = 0;i<_sz;i++) {
      [buf appendFormat:@"d:%d = ",i];
      [buf appendString:[_tab[i] description]];
      [buf appendString:@"\n"];
   }
   return buf;
}
-(void)encodeWithCoder:(NSCoder *)aCoder
{
   [aCoder encodeValueOfObjCType:@encode(CPUInt) at:&_mxs];
   [aCoder encodeValueOfObjCType:@encode(CPUInt) at:&_sz];   
   for (CPUInt i = 0; i < _sz; i++) 
      [aCoder encodeObject:_tab[i]];   
}
-(id)initWithCoder:(NSCoder *)aDecoder
{
   self = [super init];
   [aDecoder decodeValueOfObjCType:@encode(CPUInt) at:&_mxs];
   [aDecoder decodeValueOfObjCType:@encode(CPUInt) at:&_sz];
   _tab = malloc(sizeof(CPCommandList*)*_mxs);
   for (CPUInt i =0; i<_sz; i++) {
      _tab[i] = [[aDecoder decodeObject] retain];
   }
   return self;
}
@end

