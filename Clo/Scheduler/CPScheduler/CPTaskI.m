/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2014 NICTA, Andreas Schutt and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <Foundation/Foundation.h>
#import <ORModeling/ORModeling.h>
#import "CPTaskI.h"

@implementation CPTask
{
   id<CPEngine>   _engine;
   id<ORTrail>    _trail;
   id<ORIntRange> _horizon;
   ORInt          _duration;
   TRInt          _start;
   
}
-(id<CPTask>) initCPTask: (id<CPEngine>) engine horizon: (id<ORIntRange>) horizon duration: (ORInt) duration
{
   self = [super init];
   _engine = engine;
   _trail = [engine trail];
   _start = makeTRInt(_trail,horizon.low);
   return self;
}
-(ORInt) start
{
   return _start._val;
}
-(ORInt) end
{
   return 0;
}
-(ORInt) minDuration
{
   return 0;
}
-(ORInt) maxDuration
{
   return 0;
}
-(void) updateStart: (ORInt) newStart
{
   
}
-(void) updateEnd: (ORInt) newEnd
{
   
}
-(void) updateMinDuration: (ORInt) newMinDuration
{
   
}
-(void) updateMaxDuration: (ORInt) newMaxDuration
{
   
}
@end
