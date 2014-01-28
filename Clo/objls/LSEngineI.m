/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "LSEngineI.h"
#import "LSPriority.h"

@implementation LSEngineI

-(LSEngineI*)initEngine
{
   self = [super init];
   _vars = [[NSMutableArray alloc] initWithCapacity:64];
   _cstr = [[NSMutableArray alloc] initWithCapacity:64];
   _invs = [[NSMutableArray alloc] initWithCapacity:64];
   _pSpace = [[LSPrioritySpace alloc] init];
   return self;
}
-(void)dealloc
{
   [_vars release];
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
   [var setId:(ORUInt)[_vars count]];
   [_vars addObject:var];
   return var;
}
-(id) trackMutable:(id)obj
{
   [obj setId:(ORUInt)[_cstr count]];
   [_cstr addObject:obj];
   return obj;
}
-(id) trackObject: (id) obj
{
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

-(ORStatus) close
{
   assert(NO);
}
-(ORBool) closed
{
   return _closed;
}
-(NSMutableArray*) variables
{
   return _vars;
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

@end
