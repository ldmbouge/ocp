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
#import <sys/types.h>
#import <sys/resource.h>
#import <unistd.h>
#import <ORUtilities/ORConcurrency.h>
#import <ORFoundation/ORVisit.h>

@implementation NSObject (Concretization)
-(void) setImpl: (id) impl
{
   @throw [[ORExecutionError alloc] initORExecutionError: "setImpl is totally obsolete"];
   NSLog(@"%@",self); 
   @throw [[ORExecutionError alloc] initORExecutionError: "setImpl: No implementation in this object"];
}
-(void) makeImpl
{
   @throw [[ORExecutionError alloc] initORExecutionError: "makeImpl is totally obsolete"];
   NSLog(@"%@",self);
   @throw [[ORExecutionError alloc] initORExecutionError: "makeImpl: This object is already an implementation"];
}
-(id) impl
{
   @throw [[ORExecutionError alloc] initORExecutionError: "impl is totally obsolete"];
   return self;
}
-(void) visit: (ORVisitor*) visitor
{
   NSLog(@"%@",self);
   @throw [[ORExecutionError alloc] initORExecutionError: "visit: No implementation in this object"];
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
-(id)copyWithZone:(NSZone *)zone
{
   return [[ORIntegerI allocWithZone:zone] initORIntegerI:_tracker value:_value];
}
- (BOOL)isEqual:(id)anObject
{
   if ([anObject isKindOfClass:[self class]])
      return _value == [(ORIntegerI*)anObject value] && _tracker == [anObject tracker];
   else return NO;
}
- (NSUInteger)hash
{
   return _value;
}
-(ORFloat) floatValue
{
   return _value;
}
-(ORInt) value
{
   return _value;
}
-(ORInt) min
{
   return _value;
}
-(ORInt) max
{
   return _value;
}
-(ORBool) isConstant
{
   return YES;
}
-(ORBool) isVariable
{
   return NO;
}
-(enum ORVType) vtype
{
   return ORTInt;
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
-(void) visit: (ORVisitor*) visitor
{
   [visitor visitIntegerI: self];
}
@end

@implementation ORMutableIntegerI
{
	ORInt           _value;
   id<ORTracker> _tracker;
}

-(ORMutableIntegerI*) initORMutableIntegerI:(id<ORTracker>)tracker value:(ORInt) value
{
   self = [super init];
   _value = value;
   _tracker = tracker;
   return self;
}
-(ORInt) initialValue
{
   return _value;
}
-(ORInt) intValue
{
   return _value;
}
-(ORFloat) floatValue
{
   return _value;
}
-(ORInt) incr
{
   return ++_value;
}
-(ORInt) decr
{
   return --_value;
}
-(ORInt) setValue: (ORInt) value 
{
   return _value = value;
}
-(ORFloat) floatValue: (id<ORGamma>) solver
{
   return _value;
}
-(ORInt) intValue: (id<ORGamma>) solver
{
   return [(id)[solver concretize:self] intValue];
}
-(ORInt) value: (id<ORGamma>) solver
{
   return [(ORMutableIntegerI*)[solver concretize: self] initialValue];
}
-(ORInt) setValue: (ORInt) value in: (id<ORGamma>) solver
{
   return [((ORMutableIntegerI*)[solver concretize: self]) setValue: value];
}
-(ORInt) incr: (id<ORGamma>) solver
{
   return [(ORMutableIntegerI*)[solver concretize: self] incr];
}
-(ORInt) decr: (id<ORASolver>) solver
{
   return [(ORMutableIntegerI*)[solver concretize: self] decr];
}
-(ORBool) isConstant
{
   return YES;
}
-(ORBool) isVariable
{
   return NO;
}
-(enum ORVType) vtype
{
   return ORTInt;
}
-(id<ORTracker>) tracker
{
   return _tracker;
}
-(NSString*) description
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
-(void) visit: (ORVisitor*) visitor
{
   [visitor visitMutableIntegerI: self];
}
@end

@implementation ORMutableId
-(id) initWith:(id)v
{
   self = [super init];
   _value = v;
   return self;
}
-(void)dealloc
{
   //NSLog(@"ORMutableId dealloc'd : %p",self);
   [super dealloc];
}
-(id) idValue
{
   return _value;
}
-(id) idValue:(id<ORGamma>)solver
{
   return [(ORMutableId*)[solver concretize:self] idValue];
}
-(void) setId:(id)v in:(id<ORGamma>)solver
{
   [(ORMutableId*)[solver concretize:self] setId:v];
}
-(void)setId:(id)v
{
   _value = v;
}
-(NSString*)description
{
   return [NSString stringWithFormat:@"<MutableId>(%@)",_value];
}
@end

@implementation ORFloatI
{
	ORFloat       _value;
   id<ORTracker> _tracker;
}

-(ORFloatI*) initORFloatI: (id<ORTracker>) tracker value: (ORFloat) value
{
   self = [super init];
   _value = value;
   _tracker = tracker;
   return self;
}
-(ORInt) min
{
   return (ORInt)floor(_value);
}
-(ORInt) max
{
   return (ORInt)ceil(_value);
}
-(ORFloat) value
{
   return _value;
}
-(ORInt) intValue
{
   return (ORInt) _value;
}
-(ORFloat) floatValue
{
   return _value;
}
-(ORBool) isConstant
{
   return YES;
}
-(ORBool) isVariable
{
   return NO;
}
-(enum ORVType) vtype
{
   return ORTFloat;
}
-(id<ORTracker>) tracker
{
   return _tracker;
}
-(NSString*)description
{
   return [NSString stringWithFormat:@"%f",_value];
}
- (void) encodeWithCoder:(NSCoder *) aCoder
{
   [aCoder encodeValueOfObjCType:@encode(ORFloat) at:&_value];
}
- (id) initWithCoder:(NSCoder *) aDecoder
{
   self = [super init];
   [aDecoder decodeValueOfObjCType:@encode(ORFloat) at:&_value];
   return self;
}
-(void) visit: (ORVisitor*) visitor
{
   [visitor visitFloatI: self];
}
@end

@implementation ORMutableFloatI
{
	ORFloat       _value;
   id<ORTracker> _tracker;
}

-(ORMutableFloatI*) initORMutableFloatI: (id<ORTracker>) tracker value: (ORFloat) value
{
   self = [super init];
   _value = value;
   _tracker = tracker;
   return self;
}
-(ORFloat) initialValue
{
   return _value;
}
-(ORFloat) floatValue
{
   return _value;
}
-(ORFloat) value: (id<ORGamma>) solver;
{
   return [(ORMutableIntegerI*)[solver concretize: self] floatValue];
}
-(ORFloat) floatValue: (id<ORGamma>) solver;
{
   return [(ORMutableIntegerI*)[solver concretize: self] floatValue];
}
-(ORFloat) setValue: (ORFloat) value in: (id<ORGamma>) solver;
{
   return [((ORMutableIntegerI*)[solver concretize: self]) setValue: value];
}
-(ORBool) isConstant
{
   return YES;
}
-(ORBool) isVariable
{
   return NO;
}
-(enum ORVType) vtype
{
   return ORTFloat;
}
-(id<ORTracker>) tracker
{
   return _tracker;
}
-(NSString*)description
{
   return [NSString stringWithFormat:@"%f",_value];
}
- (void) encodeWithCoder:(NSCoder *) aCoder
{
   [aCoder encodeValueOfObjCType:@encode(ORFloat) at:&_value];
}
- (id) initWithCoder:(NSCoder *) aDecoder
{
   self = [super init];
   [aDecoder decodeValueOfObjCType:@encode(ORFloat) at:&_value];
   return self;
}
-(void) visit: (ORVisitor*) visitor
{
   [visitor visitMutableFloatI: self];
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
-(void) visit: (ORVisitor*) visitor
{
   [visitor visitRandomStream:self];
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
-(void) visit: (ORVisitor*) visitor
{
   [visitor visitZeroOneStream:self];
}
@end

@implementation ORUniformDistributionI
{
   ORUInt           _name;
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
-(void)setId:(ORUInt)name
{
   _name = name;
}
-(void) visit: (ORVisitor*) visitor
{
   [visitor visitUniformDistribution:self];
}
@end

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

-(ORTableI*) initORTableI:(ORInt) arity
{
   self = [super init];
   _arity = arity;
   _nb = 0;
   _size = 2;
   _column = malloc(sizeof(ORInt*)*_arity);
   for(ORInt i = 0; i < _arity; i++)
      _column[i] = malloc(sizeof(ORInt)*_size);
   _closed = false;
   return self;
}

-(ORTableI*) initORTableWithTableI: (ORTableI*) table
{
   self = [super init];
   _arity = table->_arity;
   _nb = table->_nb;
   _size = table->_size;
   _column = malloc(sizeof(ORInt*)*_arity);
   for(ORInt i = 0; i < _arity; i++)
      _column[i] = malloc(sizeof(ORInt)*_size);
   for(ORInt j = 0; j < _arity; j++) {
      for(ORInt i = 0; i < _nb; i++)
         _column[j][i] = table->_column[j][i];
   }
   assert(table->_closed == false);
   _closed = false;
   return self;
}
-(id)copyWithZone:(NSZone *)zone
{
   ORTableI* t = [[ORTableI allocWithZone:zone] initORTableWithTableI:self];
   return t;
}
- (BOOL)isEqual:(id)anObject
{
   if ([anObject isKindOfClass:[self class]]) {
      ORTableI* o = anObject;
      if (_arity == o->_arity && _nb == o->_nb) {
         for(ORInt j = 0; j < _arity; j++) {
            for(ORInt i = 0; i < _nb; i++) {
               BOOL eq = _column[j][i] == o->_column[j][i];
               if (!eq)
                  return NO;
            }
         }
         return YES;
      } else return NO;
   } else return NO;
}
-(NSUInteger)hash
{
   return _arity * _nb;
}
-(void) dealloc
{
   //NSLog(@"ORTableI dealloc called ...");
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

-(void)insertTuple:(ORInt*)t
{
   if (_closed)
      @throw [[ORExecutionError alloc] initORExecutionError: "The table is already closed"];
   if (_nb == _size)
      [self resize];
   for (ORInt k=0; k<_arity; k++)
      _column[k][_nb] = t[k];
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

-(NSString*)description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   for(ORInt i = 0; i < _nb; i++) {
      [buf appendFormat:@"%d = < ",i];
      for(ORInt j = 0; j < _arity; j++)
         [buf appendFormat:@"%d ",_column[j][i]];
      [buf appendString:@"> \n"];
   }
   return buf;
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
-(void) visit:(ORVisitor*)visitor
{
   [visitor visitTable:self];
}

-(void) encodeWithCoder: (NSCoder*) aCoder
{
   [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_arity];
   [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_nb];
   for(ORInt i = 0; i < _nb; i++)
      for(ORInt j = 0; j < _arity; j++)
         [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_column[j][i]];
}

-(id) initWithCoder: (NSCoder*) aDecoder
{
   self = [super init];
   ORInt arity;
   [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&arity];
   [self initORTableI: arity];
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

@implementation ORAutomatonI
-(id) init: (id<ORIntRange>)alphabet states:(id<ORIntRange>)states transition:(ORTransition*)tf size:(ORInt)stf
   initial: (ORInt) is
     final: (id<ORIntSet>)fs table:(ORTableI*)table
{
   self = [super init];
   _alpha = alphabet;
   _states = states;
   _nbt   = stf;
   _initial = is;
   _final = fs;
   _transition = table;
   for(ORInt i = 0;i<_nbt;i++)
      [_transition insertTuple:tf[i]];
   return self;
}
-(void)dealloc
{
   [super dealloc];
}
-(ORInt) initial
{
   return _initial;
}
-(id<ORIntSet>)final
{
   return _final;
}
-(id<ORIntRange>)alphabet
{
   return _alpha;
}
-(id<ORIntRange>)states
{
   return _states;
}
-(ORInt)nbTransitions
{
   return _nbt;
}
-(ORTableI*)transition
{
   return _transition;
}
-(void) encodeWithCoder: (NSCoder*) aCoder
{
   [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_nbt];
   [aCoder encodeObject:_alpha];
   [aCoder encodeObject:_states];
   [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_initial];
   [aCoder encodeObject:_final];
   [aCoder encodeObject:_transition];
}
-(id) initWithCoder: (NSCoder*) aDecoder
{
   self = [super init];
   [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_nbt];
   _alpha  = [aDecoder decodeObject];
   _states = [aDecoder decodeObject];
   [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_initial];
   _final  = [aDecoder decodeObject];
   _transition = [aDecoder decodeObject];
   return self;
}
@end

// ------------------------------------------------------------------------------------------

@implementation ORBindingArrayI
{
   id*              _array;
   ORInt            _nb;
}
-(ORBindingArrayI*) initORBindingArray: (ORInt) nb
{
   self = [super init];
   _nb = nb;
   _array = malloc(_nb * sizeof(id));
   memset(_array,0,sizeof(id)*_nb);
   return self;
}
-(void) dealloc
{
   free(_array);
   [super dealloc];
}
-(id) at: (ORInt) value
{
   if (value < 0|| value >= _nb)
      @throw [[ORExecutionError alloc] initORExecutionError: "Index out of range in ORBindingArray"];
   return _array[value];
}
-(void) set: (id) x at: (ORInt) value
{
   if (value < 0 || value >= _nb)
      @throw [[ORExecutionError alloc] initORExecutionError: "Index out of range in ORVarArrayElement"];
   _array[value] = x;
}
-(ORInt) nb
{
   return _nb;
}
-(id) objectAtIndexedSubscript: (NSUInteger) key
{
   if (key >= _nb)
      @throw [[ORExecutionError alloc] initORExecutionError: "Index out of range in ORBindingArray"];
   return _array[key];
}
-(void) setObject: (id) newValue atIndexedSubscript: (NSUInteger) key
{
   if (key >= _nb)
      @throw [[ORExecutionError alloc] initORExecutionError: "Index out of range in ORVarArrayElement"];
   _array[key] = newValue;
}
-(void) setImpl: (id) impl
{
   ORInt k = [NSThread threadID];
   if (_array[k] == NULL)
      _array[k] = impl;
   else
      [_array[k] setImpl: impl];
}
-(id) impl
{
   return self;
}
-(NSString*)description
{
   NSMutableString* buf = [[NSMutableString alloc] initWithCapacity:64];
   [buf appendFormat:@"binding["];
   for(ORInt i=0;i<_nb;i++) {
      [buf appendFormat:@"%@%c",[_array[i] description], i < _nb-1 ? ',' : ' '];
   }
   [buf appendFormat:@"]"];
   return buf;
}

@end

@implementation ORGamma
-(ORGamma*) initORGamma
{
   self = [super init];
   _gamma = NULL;
   _mappings = NULL;
   return self;
}
-(void) dealloc
{
   free(_gamma);
   [super dealloc];
}
-(void) setGamma: (id*) gamma
{
   _gamma = gamma;
}
-(void) setModelMappings: (id<ORModelMappings>) mappings
{
   _mappings = mappings;
}
-(id<ORModelMappings>) modelMappings
{
   return _mappings;
}
-(id*) gamma
{
   return _gamma;
}
-(id) concretize: (id<ORObject>) o
{
   ORInt i = o.getId;
   id<ORObject> ob =  _gamma[i];
   if (ob)
      return ob;
   else {
      id<ORTau> tau = _mappings.tau;
      ob = o;
      id<ORObject> nob = [tau get: ob];
      while (nob) {
         ob = nob;
         nob = [tau get: ob];
      }
      return _gamma[ob.getId];
   }
}
@end


