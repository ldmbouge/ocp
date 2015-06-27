//
//  ORProgram.m
//  Clo
//
//  Created by Laurent Michel on 6/24/15.
//
//

#import <ORProgram/ORProgram.h>

@interface ORSEqual : ORObject<ORSTask> {
   id<ORIntVar> _x;
   ORInt        _v;
   id<CPCommonProgram> _solver;
}
-(id)initWith:(id<CPCommonProgram>)solver var:(id<ORIntVar>)x andVal:(ORInt)v;
-(void)execute;
@end

@interface ORSDiff : ORObject<ORSTask> {
   id<ORIntVar> _x;
   ORInt        _v;
   id<CPCommonProgram> _solver;
}
-(id)initWith:(id<CPCommonProgram>)solver var:(id<ORIntVar>)x andVal:(ORInt)v;
-(void)execute;
@end

@interface ORSFFTask : ORObject<ORSTask> {
   id<ORIntVarArray> _vars;
   id<CPCommonProgram> _solver;
}
-(id)initWith:(id<CPCommonProgram>)solver vars:(id<ORIntVarArray>)x;
-(void)execute;
@end

@interface ORSSequence : ORObject<ORSTask> {
   NSArray* _t;
}
-(id)initWith:(NSArray*)t;
-(void)execute;
@end

@interface ORSAlts : ORObject<ORSTask> {
   id<CPCommonProgram> _solver;
   NSArray* _t;
   id<ORIntRange> _r;
}
-(id)initWith:(id<CPCommonProgram>)solver tasks:(NSArray*)t;
-(void)execute;
@end

@interface ORSBranch : ORObject<ORSTask>
-(id)initWithVar:(id<ORIntVar>(^)())varSel
             val:(ORInt(^)(id<ORIntVar>))valSel
          branch:(id<ORSTask>(^)(id<ORIntVar>,ORInt))branch;
-(void)execute;
@end


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

@implementation ORSSequence
-(id)initWith:(NSArray*)t
{
   self = [super init];
   _t = [t retain];
   return self;
}
-(void)dealloc
{
   [_t release];
   [super dealloc];
}
-(void)execute
{
   for(id<ORSTask> t in _t) {
      [t execute];
   }
}
@end

@implementation ORSAlts
-(id)initWith:(id<CPCommonProgram>)solver tasks:(NSArray*)t
{
   self = [super init];
   _t = [t retain];
   _r = [ORFactory intRange:solver low:0 up:(ORInt)_t.count-1];
   _solver = solver;
   return self;
}
-(void)dealloc
{
   [_t release];
   [super dealloc];
}
-(void)execute
{
   [_solver tryall:_r
          suchThat:nil
                do:^(ORInt k) {
                   [(id<ORSTask>)(_t[k]) execute];
                }];
}
@end

@implementation ORSBranch {
   id<ORIntVar>(^_varSel)();
   ORInt(^_valSel)(id<ORIntVar>);
   id<ORSTask>(^_branch)(id<ORIntVar>,ORInt);
}
-(id)initWithVar:(id<ORIntVar>(^)())varSel
             val:(ORInt(^)(id<ORIntVar>))valSel
          branch:(id<ORSTask>(^)(id<ORIntVar>,ORInt))branch
{
   self = [super init];
   _varSel  = [varSel copy];
   _valSel  = [valSel copy];
   _branch  = [branch copy];
   return self;
}
-(void)dealloc
{
   [_varSel release];
   [_valSel release];
   [_branch release];
   [super dealloc];
}
-(void)execute
{
   do {
      id<ORIntVar> sv = _varSel();
      if (sv==nil) return;
      else {
         ORInt value      = _valSel(sv);
         id<ORSTask> alts = _branch(sv,value);
         [alts execute];
      }
   } while(true);
}
@end

id<ORSTask> firstFail(id<CPCommonProgram> solver,id<ORIntVarArray> x)
{
   ORSFFTask* task = [[ORSFFTask alloc] initWith:solver vars:x];
   [solver trackObject:task];
   return task;
}

id<ORSTask> sequence(id<CPCommonProgram> solver,NSArray* s)
{
   id<ORSTask> task = [[ORSSequence alloc] initWith:s];
   [solver trackObject:task];
   return task;
}

id<ORSTask> selectAndBranch(id<CPCommonProgram> solver,
                           id<ORIntVar>(^varSel)(),
                           ORInt(^valSel)(id<ORIntVar>),
                           id<ORSTask>(^branch)(id<ORIntVar>,ORInt))
{
   id<ORSTask> task = [[ORSBranch alloc] initWithVar:varSel val:valSel branch:branch];
   [solver trackObject:task];
   return task;
}

id<ORSTask> alts(id<CPCommonProgram> solver,NSArray* s)
{
   id<ORSTask> task = [[ORSAlts alloc] initWith:solver tasks:s];
   [solver trackObject:task];
   return task;
}
id<ORSTask> equal(id<CPCommonProgram> solver,id<ORIntVar> x,ORInt v)
{
   id<ORSTask> task = [[ORSEqual alloc] initWith:solver var:x andVal:v];
   [solver trackObject:task];
   return task;
}
id<ORSTask> diff(id<CPCommonProgram> solver,id<ORIntVar> x,ORInt v)
{
   id<ORSTask> task = [[ORSDiff alloc] initWith:solver var:x andVal:v];
   [solver trackObject:task];
   return task;
}

