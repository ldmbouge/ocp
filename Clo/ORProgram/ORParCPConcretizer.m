/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "CPConcretizer.h"
#import <CPUKernel/CPUKernel.h>
#import <objcp/CPFactory.h>

/*

@interface ORParIntVarI : ORExprI<ORIntVar> {
   id<ORIntVar>* _concrete;
   ORInt               _nb;
}
-(ORParIntVarI*)init:(ORInt)nb;
-(id<ORIntRange>) domain;
-(ORInt) value;
-(ORInt) min;
-(ORInt) max;
-(ORInt) domsize;
-(ORBounds)bounds;
-(BOOL) member: (ORInt) v;
-(BOOL) isBool;
-(id<ORIntVar>) dereference;
-(ORInt)scale;
-(ORInt)shift;
-(id<ORIntVar>)base;
-(void)setConcrete:(ORInt)k to:(id<ORIntVar>)v;
@end

@interface ORParConstraintI : NSObject<ORConstraint> {
   id<ORConstraint>* _concrete;
   ORInt                   _nb;
   ORInt                   _id;
}
-(ORParConstraintI*) initORParConstraintI:(ORInt)nb;
-(void) setId: (ORUInt) name;
-(ORInt)getId;
-(void)setConcrete:(ORInt)k to:(id<ORConstraint>)c;
-(id<ORConstraint>)dereference;
-(void) visit: (id<ORSolverConcretizer>) concretizer;
@end

@interface ORParObjectiveI : NSObject<ORObjective> {
   id<ORObjective>*  _concrete;
   ORInt                   _nb;
}
-(ORParObjectiveI*)initORParObjectiveI:(ORInt)nb;
-(void)setConcrete:(ORInt)k to:(id<ORObjective>)c;
-(id<ORObjective>)dereference;
-(void) visit: (id<ORSolverConcretizer>) concretizer;
-(id<ORIntVar>) var;
-(ORStatus) check;
-(void)     updatePrimalBound;
-(void) tightenPrimalBound:(ORInt)newBound;
-(ORInt)    primalBound;
@end

@interface ORParIdArrayI : NSObject<ORIdArray> {
   id<ORIdArray>*    _concrete;
   ORInt                   _nb;
}
-(ORParIdArrayI*) initORParIdArrayI:(ORInt)nb;
-(void)setConcrete:(ORInt)k to:(id<ORIdArray>)c;
-(id<ORIdArray>)dereference;
-(void) visit: (id<ORSolverConcretizer>) concretizer;
-(id) at: (ORInt) value;
-(void) set: (id) x at: (ORInt) value;
-(id)objectAtIndexedSubscript:(NSUInteger)key;
-(void)setObject:(id)newValue atIndexedSubscript:(NSUInteger)idx;
-(ORInt) low;
-(ORInt) up;
-(id<ORIntRange>) range;
-(NSUInteger)count;
-(NSString*) description;
-(id<ORTracker>) tracker;
@end


@implementation CPParConcretizerI {
   id<CPParSolver> _solver;
   CPConcretizerI* _cc;
}
-(CPParConcretizerI*) initCPParConcretizerI: (id<CPParSolver>) solver
{
   self = [super init];
   _solver = solver;
   _cc = [[CPConcretizerI alloc] initCPConcretizerI:solver];
   return self;
}
-(void)dealloc
{
   [_cc release];
   [super dealloc];
}
-(id<ORIntVar>) intVar: (id<ORIntVar>) v
{
   int nbw = [_solver nbWorkers];
   ORParIntVarI* pVar = [[ORParIntVarI alloc] init:nbw];
   [_solver trackObject:pVar];
   return pVar;
}
-(id<ORFloatVar>) floatVar: (id<ORFloatVar>) v
{
   @throw [[ORExecutionError alloc] initORExecutionError: "No concretization for floatVar"];
   return nil;
}
-(id<ORIntVar>) affineVar:(id<ORIntVar>) v
{
   int nbw = [_solver nbWorkers];
   ORParIntVarI* pVar = [[ORParIntVarI alloc] init:nbw];
   [_solver trackObject:pVar];
   return pVar;
}
-(id<ORIdArray>) idArray: (id<ORIdArray>) a
{
   ORParIdArrayI* rv = [[ORParIdArrayI alloc] initORParIdArrayI:[_solver nbWorkers]];
   [_solver trackObject:rv];
   return rv;
}
-(id<ORConstraint>) alldifferent: (id<ORAlldifferent>) cstr
{
   ORParConstraintI* rv = [[ORParConstraintI alloc] initORParConstraintI:[_solver nbWorkers]];
   [_solver trackObject:rv];
   return rv;
}
-(id<ORConstraint>) binPacking: (id<ORBinPacking>) cstr
{
   ORParConstraintI* rv = [[ORParConstraintI alloc] initORParConstraintI:[_solver nbWorkers]];
   [_solver trackObject:rv];
   return rv;
}
-(id<ORConstraint>) algebraicConstraint: (id<ORAlgebraicConstraint>) cstr
{
   ORParConstraintI* rv = [[ORParConstraintI alloc] initORParConstraintI:[_solver nbWorkers]];
   [_solver trackObject:rv];
   return rv;
}
-(id<ORConstraint>) cardinality: (ORCardinalityI*) cstr
{
   ORParConstraintI* rv = [[ORParConstraintI alloc] initORParConstraintI:[_solver nbWorkers]];
   [_solver trackObject:rv];
   return rv;
}
-(id<ORConstraint>) tableConstraint: (ORTableConstraintI*) cstr
{
   ORParConstraintI* rv = [[ORParConstraintI alloc] initORParConstraintI:[_solver nbWorkers]];
   [_solver trackObject:rv];
   return rv;
}
-(id<ORObjectiveFunction>) minimize: (id<ORObjectiveFunction>) obj
{
   ORParObjectiveI* rv = [[ORParObjectiveI alloc] initORParObjectiveI:[_solver nbWorkers]];
   [_solver trackObject:rv];
   return rv;
}
-(id<ORObjectiveFunction>) maximize: (id<ORObjectiveFunction>) obj
{
   ORParObjectiveI* rv = [[ORParObjectiveI alloc] initORParObjectiveI:[_solver nbWorkers]];
   [_solver trackObject:rv];
   return rv;
}
@end



@implementation ORParIntVarI
-(ORParIntVarI*)init:(ORInt)nb
{
   self = [super init];
   _nb = nb;
   _concrete = malloc(sizeof(id<ORIntVar>)*_nb);
   return self;
}
-(void)dealloc
{
   free(_concrete);
   [super dealloc];
}
-(void)setConcrete:(ORInt)k to:(id<ORIntVar>)v
{
   _concrete[k] = v;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"PAR(%d)[",_nb];
   for(int k=0;k<_nb;k++)
      [buf appendFormat:@"%@%c",_concrete[k],k<_nb-1 ? ',' : ']'];
   return buf;
}
-(ORUInt) getId
{
   ORInt tid = [NSThread threadID];
   assert(tid >= 0 && tid < _nb);
   return [_concrete[tid] getId];
}
-(BOOL) bound
{
   ORInt tid = [NSThread threadID];
   assert(tid >= 0 && tid < _nb);
   return [_concrete[tid] bound];
}
-(id<ORSolver>) solver
{
   ORInt tid = [NSThread threadID];
   assert(tid >= 0 && tid < _nb);
   return [_concrete[tid] solver];
}
-(NSSet*)constraints
{
   ORInt tid = [NSThread threadID];
   assert(tid >= 0 && tid < _nb);
   return [_concrete[tid] constraints];
}
-(id<ORIntRange>) domain
{
   ORInt tid = [NSThread threadID];
   assert(tid >= 0 && tid < _nb);
   return [_concrete[tid] domain];
}
-(ORInt) value
{
   ORInt tid = [NSThread threadID];
   assert(tid >= 0 && tid < _nb);
   return [_concrete[tid] value];
}
-(ORInt) min
{
   ORInt tid = [NSThread threadID];
   assert(tid >= 0 && tid < _nb);
   return [_concrete[tid] min];
}
-(ORInt) max
{
   ORInt tid = [NSThread threadID];
   assert(tid >= 0 && tid < _nb);
   return [_concrete[tid] max];
}
-(ORInt) domsize
{
   ORInt tid = [NSThread threadID];
   assert(tid >= 0 && tid < _nb);
   return [_concrete[tid] domsize];
}
-(ORBounds)bounds
{
   ORInt tid = [NSThread threadID];
   assert(tid >= 0 && tid < _nb);
   return [_concrete[tid] bounds];
}
-(BOOL) member: (ORInt) v
{
   ORInt tid = [NSThread threadID];
   assert(tid >= 0 && tid < _nb);
   return [_concrete[tid] member:v];
}
-(BOOL) isBool
{
   ORInt tid = [NSThread threadID];
   assert(tid >= 0 && tid < _nb);
   return [_concrete[tid] isBool];
}
-(id<ORIntVar>) dereference
{
   ORInt tid = [NSThread threadID];
   assert(tid >= 0 && tid < _nb);
   return _concrete[tid];
}
-(ORInt)scale
{
   return 1;
}
-(ORInt)shift
{
   return 0;
}
-(id<ORIntVar>)base
{
   return self;
}
@end

@implementation ORParConstraintI
-(ORParConstraintI*) initORParConstraintI:(ORInt)nbc
{
   self = [super init];
   _nb = nbc;
   _concrete = malloc(sizeof(id<ORConstraint>)*_nb);
   return self;
}
-(void)dealloc
{
   free(_concrete);
   [super dealloc];
}
-(void) setId: (ORUInt) name
{
   _id = name;
}
-(ORInt)getId
{
   return _id;
}
-(void)setConcrete:(ORInt)k to:(id<ORConstraint>)c
{
   _concrete[k] = c;
}
-(id<ORConstraint>)dereference
{
   ORInt tid = [NSThread threadID];
   assert(tid >= 0 && tid < _nb);
   return _concrete[tid];
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"PAR(%d)[",_nb];
   for(int k=0;k<_nb;k++)
      [buf appendFormat:@"%@%c",_concrete[k],k<_nb-1 ? ',' : ']'];
   return buf;
}
-(void) visit: (id<ORSolverConcretizer>) concretizer
{
   @throw [[ORExecutionError alloc] initORExecutionError:"Should never concrete a par-constraint"];
}
@end

@implementation ORParObjectiveI
-(ORParObjectiveI*)initORParObjectiveI:(ORInt)nbo
{
   self = [super init];
   _nb = nbo;
   _concrete = malloc(sizeof(id<ORObjective>)*_nb);
   return self;
}
-(void)dealloc
{
   free(_concrete);
   [super dealloc];
}
-(void)setConcrete:(ORInt)k to:(id<ORObjective>)c
{
   _concrete[k] = c;
}
-(id<ORObjective>)dereference
{
   ORInt tid = [NSThread threadID];
   assert(tid >= 0 && tid < _nb);
   return _concrete[tid];
}
-(void) visit: (id<ORSolverConcretizer>) concretizer
{
   @throw [[ORExecutionError alloc] initORExecutionError:"Should never concrete a par-objective"];
}
-(id<ORIntVar>) var
{
   return [[self dereference] var];
}
-(ORStatus) check
{
   return [[self dereference] check];
}
-(void) updatePrimalBound
{
   [[self dereference] updatePrimalBound];
}
-(void) tightenPrimalBound:(ORInt)newBound
{
   @synchronized(self) {
      for(ORInt i=0;i<_nb;i++) {
         [_concrete[i] tightenPrimalBound:newBound];
      }
   }
}

-(ORInt)    primalBound
{
   return [[self dereference] primalBound];
}
@end

@implementation ORParIdArrayI
-(ORParIdArrayI*) initORParIdArrayI:(ORInt)nbc
{
   self = [super init];
   _nb = nbc;
   _concrete = malloc(sizeof(id<ORIdArray>)*_nb);
   return self;
}
-(void)dealloc
{
   free(_concrete);
   [super dealloc];
}
-(void)setConcrete:(ORInt)k to:(id<ORIdArray>)c
{
   _concrete[k] = c;
}
-(id<ORIdArray>)dereference
{
   ORInt tid = [NSThread threadID];
   assert(tid >= 0 && tid < _nb);
   return _concrete[tid];
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"PAR(%d)[",_nb];
   for(int k=0;k<_nb;k++)
      [buf appendFormat:@"%@%c",_concrete[k],k<_nb-1 ? ',' : ']'];
   return buf;
}
-(void)enumerateWith:(void(^)(id obj,int idx))block
{
   for(int k=0;k<_nb;k++)
      block(_concrete[k],k);
}
-(void) visit: (id<ORSolverConcretizer>) concretizer
{
   @throw [[ORExecutionError alloc] initORExecutionError:"Should never concrete a par-constraint"];
}

-(id) at: (ORInt) value
{
   return [[self dereference] at:value];
}
-(void) set: (id) x at: (ORInt) value
{
   [[self dereference] set:x at:value];
}
-(id)objectAtIndexedSubscript:(NSUInteger)key
{
   return [[self dereference] objectAtIndexedSubscript:key];
}
-(void)setObject:(id)newValue atIndexedSubscript:(NSUInteger)idx
{
   [[self dereference] setObject:newValue atIndexedSubscript:idx];
}
-(ORInt) low
{
   return [[self dereference] low];
}
-(ORInt) up
{
   return [[self dereference] up];
}
-(id<ORIntRange>) range
{
   return [[self dereference] range];
}
-(NSUInteger)count
{
   return [[self dereference] count];
}
-(id<ORTracker>) tracker
{
   return [[self dereference] tracker];
}
@end

*/