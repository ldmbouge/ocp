/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "ORDataI.h"
#import "ORSet.h"

@implementation ORIntegerI
{
	ORInt           _value;
   id<ORTracker> _tracker;
}

-(ORIntegerI*) initORIntegerI:(id<ORTracker>)tracker value:(ORInt) value
{
   self = [super init];
   _value = value;
   _tracker = tracker;
   return self;
}
-(ORInt) value 
{
   return _value;
}
-(void) setValue: (ORInt) value
{
   _value = value;
}
-(void) incr
{
   _value++;
}
-(void) decr;
{
   _value--;
}
-(ORInt) min
{
   return _value;
}
-(ORInt) max
{
   return _value;
}
-(BOOL) isConstant
{
   return YES;
}
-(BOOL) isVariable
{
   return NO;
}
-(id<ORTracker>) tracker
{
   return _tracker;
}
-(NSString*)description
{
   return [NSString stringWithFormat:@"%d",_value];
}
- (void) encodeWithCoder:(NSCoder *)aCoder
{
   [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_value];
}
- (id) initWithCoder:(NSCoder *)aDecoder
{
   self = [super init];
   [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_value];
   return self;
}
-(void) visit: (id<ORExprVisitor>) visitor
{
   [visitor visitIntegerI: self];
}
@end


static ORInt _nbStreams;
static ORInt _deterministic;

@implementation ORStreamManager
+(void) initialize
{
   _nbStreams = 1;
   _deterministic = 1;
}
+(void) setRandomized
{
   _deterministic = 0;
}
+(void) setDeterministic
{
   _deterministic = 1;
}
+(ORInt) deterministic
{
   return _deterministic;
}
+(void) initSeed: (unsigned short*) seed
{
   if (_deterministic) {
      seed[0] = 1238 * 7 * _nbStreams;
      seed[1] = 4369 * 13 *_nbStreams;
      seed[2] = 2875 + _nbStreams;
      ++_nbStreams;
   }
   else {
      seed[0] = (7 * _nbStreams * [ORRuntimeMonitor microseconds]) & 0177777;
      seed[1] = 13 * _nbStreams * getpid();
      seed[2] = _nbStreams + getppid();
      ++_nbStreams;
   }
}
@end

@implementation ORRandomStreamI
{
   unsigned short _seed[3];
}
-(ORRandomStreamI*) init
{
   self = [super init];
   [ORStreamManager initSeed: _seed];
   return self;
}
-(void) dealloc
{
   [super dealloc];
}
-(ORLong) next
{
   return nrand48(_seed);
}
@end;

@implementation ORZeroOneStreamI
{
   unsigned short _seed[3];
}
-(ORZeroOneStreamI*) init
{
   self = [super init];
   [ORStreamManager initSeed: _seed];
   return self;
}
-(void) dealloc
{
   [super dealloc];
}
-(double) next
{
   return erand48(_seed);
}
@end;

@implementation ORUniformDistributionI
{
   id<ORIntRange>   _range;
   ORRandomStreamI* _stream;
   ORInt            _size;
}
-(ORUniformDistributionI*) initORUniformDistribution: (id<ORIntRange>) r
{
   self = [super init];
   _range = r;
   _stream = [[ORRandomStreamI alloc] init];
   _size = [_range up] - [_range low] + 1;
   return self;
}
-(void) dealloc
{
   [_stream release];
   [super dealloc];
}
-(ORInt) next
{
   return _range.low + [_stream next] % _size;
}
@end;

@implementation ORRuntimeMonitor
+(ORLong) cputime
{
   struct rusage r;
   getrusage(RUSAGE_SELF,&r);
   struct timeval t;
   t = r.ru_utime;
   return 1000 * t.tv_sec + t.tv_usec / 1000;
}
+(ORLong) microseconds
{
   struct rusage r;
   getrusage(RUSAGE_SELF,&r);
   struct timeval t;
   t = r.ru_utime;
   return t.tv_usec;
}
@end;

