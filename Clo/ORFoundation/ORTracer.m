/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <ORFoundation/ORTracer.h>

@implementation DFSTracer
{
@private
   ORTrail*          _trail;
   ORTrailStack*   _trStack;
   ORInt          _lastNode;
   TRInt             _level;
}
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
-(ORTrail*)   trail
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

