/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORProgram/ORProgram.h>
#import <objcp/objcp.h>

@interface ORSEqual : ORObject<ORSTask> {
   id<ORIntVar> _x;
   ORInt        _v;
   id<CPCommonProgram> _solver;
}
-(id)initWith:(id<CPCommonProgram>)solver var:(id<ORIntVar>)x andVal:(ORInt)v;
@end

@interface ORSDiff : ORObject<ORSTask> {
   id<ORIntVar> _x;
   ORInt        _v;
   id<CPCommonProgram> _solver;
}
-(id)initWith:(id<CPCommonProgram>)solver var:(id<ORIntVar>)x andVal:(ORInt)v;
@end

@interface ORSFFTask : ORObject<ORSTask> {
   id<ORIntVarArray> _vars;
   id<CPCommonProgram> _solver;
}
-(id)initWith:(id<CPCommonProgram>)solver vars:(id<ORIntVarArray>)x;
@end

@interface ORSDo : ORObject<ORSTask> {
   id<CPCommonProgram> _solver;
   void(^_body)(void);
}
-(id)initWith:(id<CPCommonProgram>)solver block:(void(^)(void))body;
@end

@interface ORSLimitSolutionsDo : ORObject<ORSTask> {
   id<CPProgram> _solver;
   id<ORSTask>(^_body)(void);
   ORInt _lim;
}
-(id)initWith:(id<CPCommonProgram>)solver limit:(ORInt)k block:(id<ORSTask>(^)(void))body;
@end

@interface ORSSequence : ORObject<ORSTask> {
   id<CPCommonProgram> _solver;
   id<ORSTask>*      _tasks;
   ORInt               _cnt;
}
-(id)initWith:(id<CPCommonProgram>)solver tasks:(id*)t count:(int)n;
@end

@interface ORSAlts : ORObject<ORSTask> {
   id<CPCommonProgram> _solver;
   id<ORIntRange>      _r;
   id<ORSTask>*      _tasks;
   ORInt               _cnt;
}
-(id)initWith:(id<CPCommonProgram>)solver tasks:(id*)buf count:(ORInt)n;
@end

@interface ORSDoWhile : ORObject<ORSTask>
-(id)initWith:(id<CPCommonProgram>)solver condition:(bool(^)(void))cond body:(id<ORSTask>(^)(void))body;
@end

@interface ORSForallDo : ORObject<ORSTask>
-(id)initWith:(id<CPCommonProgram>)solver
        range:(id<ORIntRange>)range
         body:(id<ORSTask>(^)(ORInt))body;
@end

// -----------------------------------------------------------------------------------------------
// Implementation
// -----------------------------------------------------------------------------------------------

@implementation ORSEqual
-(id)initWith:(id<CPCommonProgram>)solver var:(id<ORIntVar>)x andVal:(ORInt)v
{
   self = [super init];
   _solver = solver;
   _x = x;
   _v = v;
   return self;
}
-(void)dealloc
{
   [super dealloc];
}
-(id<ORTracker>)tracker
{
   return _solver;
}
-(id)retain
{
   return [super retain];
}
-(id)autorelease
{
   return [super autorelease];
}
-(oneway void)release
{
   //printf("Release called on solver: RC=%d [%s]\n",_rc,[[[self class] description] UTF8String]);
   [super release];
}
-(void)execute
{
   [_solver label:_x with:_v];
}
@end

@implementation ORSDiff
-(id)initWith:(id<CPCommonProgram>)solver var:(id<ORIntVar>)x andVal:(ORInt)v
{
   self = [super init];
   _solver = solver;
   _x = x;
   _v = v;
   return self;
}
-(void)dealloc
{
   [super dealloc];
}
-(id<ORTracker>)tracker
{
   return _solver;
}
-(void)execute
{
   [_solver diff:_x with:_v];
}
@end


@implementation ORSFFTask
-(id)initWith:(id<CPCommonProgram>)solver vars:(id<ORIntVarArray>)x
{
   self = [super init];
   _solver = solver;
   _vars = x;
   return self;
}
-(id<ORTracker>)tracker
{
   return _solver;
}
-(void)execute
{
   const ORInt sz  = _vars.range.size;
   const ORInt low = _vars.range.low;
   id<CPIntVar> cx[sz];
   for(ORInt i=0;i < sz;i++)
      cx[i]  = [_solver concretize:_vars[i + low]];
   do {
      ORInt sd = FDMAXINT,sdk = -1;
      for(ORInt i=0;i < sz;i++) {
         if ([cx[i] bound]) continue;
         ORInt vids = [cx[i] domsize];
         if (vids < sd) {
            sd = vids;
            sdk = i;
         }
      }
      if (sd == FDMAXINT) break;
      ORBounds xb = [cx[sdk] bounds];
      while (xb.min != xb.max) {
         [_solver try:^{
            [_solver label:_vars[sdk + low] with:xb.min];
         } alt:^{
            [_solver diff:_vars[sdk + low] with:xb.min];
         }];
         xb = [cx[sdk] bounds];
      }
   } while (true);
}
@end

@implementation ORSDo
-(id)initWith:(id<CPCommonProgram>)solver block:(void(^)(void))body
{
   self = [super init];
   _solver = solver;
   _body = [body copy];
   return self;
}
-(void)dealloc
{
   [_body release];
   [super dealloc];
}
-(void)execute
{
   _body();
}
-(id<ORTracker>)tracker
{
   return _solver;
}
@end

@implementation ORSLimitSolutionsDo
-(id)initWith:(id<CPCommonProgram>)solver limit:(ORInt)k block:(id<ORSTask>(^)(void))body
{
   self = [super init];
   _solver = (id)solver;
   _body = [body copy];
   _lim  = k;
   return self;
}
-(void)dealloc
{
   [_body release];
   [super dealloc];
}
-(void)execute
{
   [_solver limitSolutions:_lim in: ^{      
      id<ORSTask> todo = _body();
      [todo execute];
   }];
}
-(id<ORTracker>)tracker
{
   return _solver;
}
@end



@implementation ORSSequence
-(id)initWith:(id<CPCommonProgram>)solver tasks:(id*)t count:(int)n
{
   self = [super init];
   _solver = solver;
   _tasks = malloc(sizeof(id)*n);
   _cnt = n;
   memcpy(_tasks, t, sizeof(id)*n);
   return self;
}
-(void)dealloc
{
   free(_tasks);
   [super dealloc];
}
-(id<ORTracker>)tracker
{
   return _solver;
}
-(void)execute
{
   for(int k=0;k<_cnt;k++)
      [_tasks[k] execute];
}
@end

@implementation ORSAlts
-(id)initWith:(id<CPCommonProgram>)solver tasks:(id*)buf count:(ORInt)n
{
   self = [super init];
   _cnt   = n;
   _tasks = malloc(n*sizeof(id));
   memcpy(_tasks, buf, sizeof(id)*n);
   _r = [ORFactory intRange:solver low:0 up:(ORInt)n-1];
   _solver = solver;
   return self;
}
-(void)dealloc
{
   free(_tasks);
   [super dealloc];
}
-(id<ORTracker>)tracker
{
   return _solver;
}
-(void)execute
{
   id<ORSTask>* ptr = _tasks;
   [_solver tryall:_r
          suchThat:nil
                do:^(ORInt k) {
                   [ptr[k] execute];
                }];
}
@end

@implementation ORSDoWhile {
   bool(^_cond)(void);
   id<ORSTask>(^_body)(void);
   id<CPCommonProgram> _solver;
}
-(id)initWith:(id<CPCommonProgram>)solver condition:(bool(^)(void))cond body:(id<ORSTask>(^)(void))body
{
   self = [super init];
   _solver = solver;
   _cond = [cond copy];
   _body = [body copy];
   return self;
}
-(void)dealloc
{
   [_cond release];
   [_body release];
   [super dealloc];
}
-(id<ORTracker>)tracker
{
   return _solver;
}
-(void)execute
{
   while (_cond()) {
      id<ORSTask> t = _body();
      [t execute];
   }
}
@end

@implementation ORSForallDo {
   id<ORIntRange> _range;
   id<ORSTask>(^_body)(ORInt);
   id<CPCommonProgram> _solver;
}
-(id)initWith:(id<CPCommonProgram>)solver range:(id<ORIntRange>)range body:(id<ORSTask>(^)(ORInt))body
{
   self = [super init];
   _solver = solver;
   _range = range;
   _body  = [body copy];
   return self;
}
-(void)dealloc
{
   [_body release];
   [super dealloc];
}
-(id<ORTracker>)tracker
{
   return _solver;
}
-(void)execute
{
   ORInt l = _range.low,u =_range.up;
   for(ORInt k=l;k <= u;k++) {
      id<ORSTask> alts = _body(k);
      [alts execute];
   }
}
@end

void* firstFail(id<CPCommonProgram> solver,id<ORIntVarArray> x)
{
   ORSFFTask* task = [[ORSFFTask alloc] initWith:solver vars:x];
   [solver trackObject:task];
   return task;
}

void* sequence(id<CPCommonProgram> solver,int n,void** s)
{
   id<ORSTask> task = [[ORSSequence alloc] initWith:solver tasks:(id*)s count:n];
   [solver trackObject:task];
   return task;
}
void* alts(id<CPCommonProgram> solver,int n,void** s)
{
   id<ORSTask> task = [[ORSAlts alloc] initWith:solver tasks:(id*)s count:n];
   [solver trackObject:task];
   return task;
}
void* equal(id<CPCommonProgram> solver,id<ORIntVar> x,ORInt v)
{
   id<ORSTask> task = [[ORSEqual alloc] initWith:solver var:x andVal:v];
   [solver trackObject:task];
   return task;
}
void* diff(id<CPCommonProgram> solver,id<ORIntVar> x,ORInt v)
{
   id<ORSTask> task = [[ORSDiff alloc] initWith:solver var:x andVal:v];
   [solver trackObject:task];
   return task;
}

void* PNONNULL whileDo(id<CPCommonProgram> solver,
                        bool(^PNONNULL cond)(void),
                        void* PNONNULL (^PNONNULL body)(void))
{
   id<ORSTask> task = [[ORSDoWhile alloc] initWith:solver condition:cond body:(id)body];
   [solver trackObject:task];
   return task;
}

void* PNONNULL forallDo(id<CPCommonProgram> solver,
                         id<ORIntRange> R,
                         void* PNONNULL(^PNONNULL body)(NSInteger)
                         )
{
   id<ORSTask> task = [[ORSForallDo alloc] initWith:solver range:R body:(id)body];
   [solver trackObject:task];
   return task;
}

void* PNONNULL Do(id<CPCommonProgram> solver,void(^PNONNULL body)(void))
{
   id<ORSTask> task = [[ORSDo alloc] initWith:solver block:(id)body];
   [solver trackObject:task];
   return task;
}

void* PNONNULL limitSolutionsDo(id<CPCommonProgram> solver,ORInt k,void*(^PNONNULL body)(void))
{
   id<ORSTask> task = [[ORSLimitSolutionsDo alloc] initWith:solver limit:k block:(id)body];
   [solver trackObject:task];
   return task;
}

