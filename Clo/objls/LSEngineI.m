/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "LSEngineI.h"
#import "LSPriority.h"
#import "LSPropagator.h"

@implementation LSEngineI

-(LSEngineI*)initEngine
{
   self = [super init];
   _vars = [[NSMutableArray alloc] initWithCapacity:64];
   _objs = [[NSMutableArray alloc] initWithCapacity:64];
   _cstr = [[NSMutableArray alloc] initWithCapacity:64];
   _invs = [[NSMutableArray alloc] initWithCapacity:64];
   _pSpace = [[LSPrioritySpace alloc] init];
   _nbObjects = 0;
   return self;
}
-(void)dealloc
{
   [_vars release];
   [_objs release];
   [_cstr release];
   [_invs release];
   [super dealloc];
}
-(NSString*)description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<LSEngineI: %p>",self];
   return buf;
}
-(id<ORTracker>) tracker
{
   return self;
}
-(id) trackVariable: (id) var
{
   [var setId:_nbObjects++];
   [_vars addObject:var];
   return var;
}
-(id) trackMutable:(id)obj
{
   [obj setId:_nbObjects++];
   [_objs addObject:obj];
   return obj;
}
-(id) trackObject: (id) obj
{
   [obj setId:_nbObjects++];
   [_objs addObject:obj];
   return obj;
}
-(id) trackImmutable: (id) obj
{
   return obj;
}
-(id) trackObjective:(id) obj
{
   return obj;
}
-(id) trackConstraintInGroup:(id) obj
{
   return obj;
}
-(LSPrioritySpace*)space
{
   return _pSpace;
}
-(ORStatus) close
{
   if (_closed) return ORSuspend;
   _closed = YES;
   PStore* store = [[PStore alloc] initPStore:self];
   [store prioritize];
   [store release];
   return ORSuspend;
}
-(ORBool) closed
{
   return _closed;
}
-(ORUInt)nbObjects
{
   return _nbObjects;
}
-(NSMutableArray*) variables
{
   return _vars;
}
-(NSMutableArray*)invariants
{
   return _invs;
}
-(id<ORTrail>) trail
{
   return nil;
}
-(ORStatus)propagate
{
   return ORSuspend;
}
-(ORStatus)enforceObjective
{
   return ORSuspend;
}

-(void)clearStatus
{
}
-(void)add:(LSPropagator*)i
{
   [_invs addObject:i];
   [i define];
}
@end
