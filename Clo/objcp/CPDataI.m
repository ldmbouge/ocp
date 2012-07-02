/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import "CPDataI.h"
#import "CPI.h"
#include <stdlib.h>

#if !defined(__APPLE__)
#include <sys/types.h>
#include <sys/time.h>
#include <sys/resource.h>
#include <unistd.h>
#endif

@implementation CPIntegerI 
-(CPIntegerI*) initCPIntegerI: (CPInt) value
{
  self = [super init];
  _value = value;
  return self;
}
-(CPInt) value 
{
  return _value;
}
-(void) setValue: (CPInt) value
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
-(CPInt) min
{
    return _value;
}
-(CPInt) max
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
-(id<CP>) cp
{
    return nil;
}
-(NSString*)description
{
   return [NSString stringWithFormat:@"%ld",_value];
}
- (void) encodeWithCoder:(NSCoder *)aCoder
{
   [aCoder encodeValueOfObjCType:@encode(CPInt) at:&_value];
}
- (id) initWithCoder:(NSCoder *)aDecoder
{
   self = [super init];
   [aDecoder decodeValueOfObjCType:@encode(CPInt) at:&_value];
   return self;
}
@end

static CPInt _nbStreams;
static CPInt _deterministic;

@implementation CPStreamManager
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
+(CPInt) deterministic
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
    seed[0] = (7 * _nbStreams * [CPRuntimeMonitor microseconds]) & 0177777;
    seed[1] = 13 * _nbStreams * getpid();
    seed[2] = _nbStreams + getppid();
    ++_nbStreams;
  }
}
@end

@implementation CPRandomStream 
-(CPRandomStream*) init
{
  self = [super init];
  [CPStreamManager initSeed: _seed];
  return self;
}
-(void) dealloc
{
  [super dealloc];
}
-(CPInt) next
{
  return nrand48(_seed);
}
@end;

@implementation CPZeroOneStream 
-(CPZeroOneStream*) init
{
  self = [super init];
  [CPStreamManager initSeed: _seed];
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

@implementation CPUniformDistribution
-(CPUniformDistribution*) initCPUniformDistribution: (CPRange) r
{
  self = [super init];
  _range = r;
  _stream = [[CPRandomStream alloc] init];
  _size = _range.up - _range.low + 1;
  return self;
}
-(void) dealloc
{
  [_stream release];
  [super dealloc];
}
-(CPInt) next
{
  return _range.low + [_stream next] % _size;  
}
@end;

@implementation CPRuntimeMonitor 
+(CPInt) cputime
{
  struct rusage r;
  getrusage(RUSAGE_SELF,&r);
  struct timeval t;
  t = r.ru_utime;
  return 1000 * t.tv_sec + t.tv_usec / 1000;
}
+(CPInt) microseconds
{
  struct rusage r;
  getrusage(RUSAGE_SELF,&r);
  struct timeval t;
  t = r.ru_utime;
  return t.tv_usec;
}
@end;
