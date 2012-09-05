/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "ORDataI.h"
#import "ORSet.h"
#import <sys/time.h>

@implementation NSObject (Concretization)
-(void) concretize: (id<ORSolverConcretizer>) concretizer
{
   
}
-(id) dereference
{
   return self;
}
@end;

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
+(ORLong) wctime
{
   struct timeval now;
   struct timezone tz;
   int st = gettimeofday(&now,&tz);
   if (st==0) {
      now.tv_sec -= (0xfff << 20);
      return 1000 * now.tv_sec + now.tv_usec/1000;
   }
   else return 0;
}
@end;


@implementation ORTableI

-(ORTableI*) initORTableI: (id<ORSolver>) solver arity: (ORInt) arity
{
   self = [super init];
   _solver = solver;
   _arity = arity;
   _nb = 0;
   _size = 2;
   _column = malloc(sizeof(ORInt*)*_arity);
   for(ORInt i = 0; i < _arity; i++)
      _column[i] = malloc(sizeof(ORInt)*_size);
   _closed = false;
   return self;
}

-(void) dealloc
{
   NSLog(@"ORTableI dealloc called ...");
   for(ORInt i = 0; i < _arity; i++)
      free(_column[i]);
   free(_column);
   if (_closed) {
      for(ORInt i = 0; i < _arity; i++) {
         free(_nextSupport[i]);
         _support[i] += _min[i];
         free(_support[i]);
      }
      free(_nextSupport);
      free(_support);
      free(_min);
      free(_max);
   }
   [super dealloc];
}

-(void) resize
{
   for(ORInt j = 0; j < _arity; j++) {
      ORInt* nc = malloc(sizeof(ORInt)*2*_size);
      for(ORInt i = 0; i < _nb; i++)
         nc[i] = _column[j][i];
      free(_column[j]);
      _column[j] = nc;
   }
   _size *= 2;
}

-(void) addEmptyTuple
{
   if (_closed)
      @throw [[ORExecutionError alloc] initORExecutionError: "The table is already closed"];
   if (_nb == _size)
      [self resize];
   _nb++;
}

-(void) fill: (ORInt) j with: (ORInt) val
{
   if (_closed)
      @throw [[ORExecutionError alloc] initORExecutionError: "The table is already closed"];
   if (j < 0 || j >= _arity)
      @throw [[ORExecutionError alloc] initORExecutionError: "No such index in the table tuples"];
   if (_nb == _size)
      [self resize];
   _column[j][_nb-1] = val;
}

-(void) insert: (ORInt) i : (ORInt) j : (ORInt) k
{
   if (_closed)
      @throw [[ORExecutionError alloc] initORExecutionError: "The table is already closed"];
   if (_nb == _size)
      [self resize];
   _column[0][_nb] = i;
   _column[1][_nb] = j;
   _column[2][_nb] = k;
   _nb++;
}

-(void) index: (ORInt) j
{
   ORInt m = MAXINT;
   ORInt M = -MAXINT;
   for(ORInt i = 0; i < _nb; i++) {
      if (_column[j][i] < m)
         m = _column[j][i];
      if (_column[j][i] > M)
         M = _column[j][i];
   }
   _min[j] = m;
   _max[j] = M;
   ORInt nbValues = M - m + 1;
   _nextSupport[j] = malloc(sizeof(ORInt)*_nb);
   _support[j] = malloc(sizeof(ORInt)*nbValues);
   _support[j] -= m;
   for(ORInt i = 0; i < _nb; i++)
      _nextSupport[j][i] = -1;
   for(ORInt v = m; v <= M; v++)
      _support[j][v] = -1;
   for(ORInt i = 0; i < _nb; i++) {
      int v = _column[j][i];
      _nextSupport[j][i] = _support[j][v];
      _support[j][v] = i;
   }
}

-(void) close
{
   if (!_closed) {
      _closed = true;
      _min = malloc(sizeof(ORInt)*_arity);
      _max = malloc(sizeof(ORInt)*_arity);
      _nextSupport = malloc(sizeof(ORInt*)*_arity);
      _support = malloc(sizeof(ORInt*)*_arity);
      for(ORInt j = 0; j < _arity; j++)
         [self index: j];
   }
}

-(void) print
{
   for(ORInt i = 0; i < _nb; i++) {
      printf("%d = < ",i);
      for(ORInt j = 0; j < _arity; j++)
         printf("%d ",_column[j][i]);
      printf("> \n");
   }
   for(ORInt j = 0; j < _arity; j++)
      for(ORInt v = _min[j]; v <= _max[j]; v++)
         printf("support[%d,%d] = %d\n",j,v,_support[j][v]);
   printf("\n");
   for(ORInt j = 0; j < _arity; j++)
      for(ORInt i = 0; i < _nb; i++)
         printf("_nextSupport[%d,%d]=%d\n",j,i,_nextSupport[j][i]);
}

-(void) encodeWithCoder: (NSCoder*) aCoder
{
   [aCoder encodeObject:_solver];
   [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_arity];
   [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_nb];
   for(ORInt i = 0; i < _nb; i++)
      for(ORInt j = 0; j < _arity; j++)
         [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_column[j][i]];
}

-(id) initWithCoder: (NSCoder*) aDecoder
{
   id<ORSolver> solver = [[aDecoder decodeObject] retain];
   ORInt arity;
   [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&arity];
   [self initORTableI: solver arity: arity];
   ORInt size;
   [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&size];
   for(ORInt i = 0; i < size; i++) {
      [self addEmptyTuple];
      for(ORInt j = 0; j < _arity; j++)
         [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_column[j][i]];
   }
   return self;
}
@end



