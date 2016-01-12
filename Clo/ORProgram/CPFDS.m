/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORProgram/CPFDS.h>
#import <ORProgram/CPSolver.h>
#import <ORFoundation/ORTracer.h>
#import <CPUKernel/CPUKernel.h>
#import <ORPRogram/CPConcretizer.h>
#import <objcp/CPStatisticsMonitor.h>
#import <objcp/CPVar.h>
#import <objcp/CPFactory.h>

#if defined(__linux__)
#import <values.h>
#endif


@interface CPFDSKillRange : NSObject {
   @package
   ORInt _low;
   ORInt _up;
   ORUInt _nbKilled;
}
-(id)initCPKillRange:(ORInt)f to:(ORInt)to size:(ORUInt)sz;
-(void)dealloc;
-(ORBool)isEqual:(CPFDSKillRange*)kr;
-(ORInt) low;
-(ORInt) up;
-(ORInt) killed;
@end

@implementation CPFDSKillRange
-(id)initCPKillRange:(ORInt)f to:(ORInt)to  size:(ORUInt)sz
{
   self = [super init];
   _low = f;
   _up  = to;
   _nbKilled = sz;
   return self;
}
-(void)dealloc
{
   [super dealloc];
}
-(ORBool)isEqual:(CPFDSKillRange*)kr
{
   return (_low == kr->_low && _up == kr->_up);
}
-(ORInt) low
{
   return _low;
}
-(ORInt) up
{
   return _up;
}
-(ORInt) killed
{
   return _nbKilled;
}
@end

@interface ORAvgRating : NSObject {
   double _nb;
   double _ttl;
}
-(id)init;
-(double)avgRating;
-(void)addSample:(double)val;
@end

@interface ORCBranch : NSObject<NSCopying> {
   id     _var;
   ORInt  _val;
   short  _side;  // C+ / C-
}
-(id)initWithLTOn:(id)var cst:(ORInt)val;
-(id)initWithGTOn:(id)var cst:(ORInt)val;
-(id)initSide:(short)side var:(id)var cst:(ORInt)val;
- (id)copyWithZone:(NSZone *)zone;
@end

@interface ORRating : NSObject {
   double _rating;
}
-(id)init;
-(void)setRating:(double)r;
-(double)rating;
@end

@implementation ORRating
-(id)init
{
   self = [super init];
   _rating = 1.0;
   return self;
}
-(void)setRating:(double)r
{
   assert(r != +INFINITY);
   _rating = r;
}
-(double)rating
{
   return _rating;
}
@end

@implementation ORAvgRating
-(id)init
{
   self = [super init];
   _nb = 0.0;
   _ttl = 0.0;
   return self;
}
-(double)avgRating
{
   if (_nb == 0 || _ttl == 0)
      return 1.0;
   return _ttl / _nb;
}
-(void)addSample:(double)val
{
   _nb += 1.0;
   _ttl += val;
}
@end


@implementation ORCBranch
-(id)initWithLTOn:(id)var cst:(ORInt)val
{
   self = [super init];
   _var = var;
   _val = val;
   _side = 1;
   return self;
}
-(id)initWithGTOn:(id)var cst:(ORInt)val
{
   self = [super init];
   _var = var;
   _val = val;
   _side = -1;
   return self;
}
-(id)initSide:(short)side var:(id)var cst:(ORInt)val
{
   self = [super init];
   _var = var;
   _val = val;
   _side = side;
   return self;
}
- (id)copyWithZone:(NSZone *)zone
{
   return [[ORCBranch allocWithZone:zone] initSide:_side var:_var cst:_val];
}
- (BOOL)isEqual:(id)object
{
   Class oc = [object class];
   if (oc == [ORCBranch class]) {
      ORCBranch* to = object;
      return getId(_var) == getId(to->_var) && _val == to->_val && _side == to->_side;
   } else return NO;
}
- (NSUInteger)hash
{
   return (getId(_var)<<16) + _val * _side;
}
@end

#define ALPHA 0.95

@implementation CPFDS {
   id<CPEngine>             _engine;
   CPStatisticsMonitor*    _monitor;
   ORULong                     _nbv;
   NSMutableDictionary*    _avgRating;
   NSMutableDictionary*    _branchRating;
   NSMutableDictionary*    _choiceRating;
   double                  _lcr;
}

-(id)initCPFDS:(id<CPCommonProgram>)cp restricted:(id<ORVarArray>)rvars
{
   self = [super init];
   _cp = cp;
   _engine = [cp engine];
   _monitor = nil;
   _vars = nil;
   _rvars = rvars;
   _avgRating    = [[NSMutableDictionary alloc] initWithCapacity:32];
   _branchRating = [[NSMutableDictionary alloc] initWithCapacity:32];
   _choiceRating = [[NSMutableDictionary alloc] initWithCapacity:32];
   return self;
}
- (id)copyWithZone:(NSZone *)zone
{
   return [[CPFDS alloc] initCPFDS:_cp restricted:_rvars];
}
-(void)dealloc
{
   [_avgRating release];
   [_branchRating release];
   [super dealloc];
}
-(id<CPCommonProgram>)solver
{
   return _cp;
}

-(ORDouble)varOrdering:(id<CPIntVar>)x
{
   return [self choiceRatingFor:x].rating;
}
-(ORDouble)valOrdering:(int)v forVar:(id<CPIntVar>)x
{
   return 0.0;
}
-(ORAvgRating*)avgRatingAtDepth:(ORInt)d
{
   ORAvgRating* art = [_avgRating objectForKey:@(d)];
   if (art == nil) {
      art = [[ORAvgRating alloc] init];
      [_avgRating setObject:art forKey:@(d)];
   }
   return art;
}
-(ORRating*)branchForSide:(short)side var:(id)var cst:(ORInt)val
{
   ORCBranch* sel = [[ORCBranch alloc] initSide:side var:var cst:val];
   ORRating* r = [_branchRating objectForKey:sel];
   if (r==nil) {
      r = [[ORRating alloc] init];
      [_branchRating setObject:r forKey:sel];
   }
   [sel release];
   return r;
}
-(ORRating*)choiceRatingFor:(id)var
{
   ORRating* r = [_choiceRating objectForKey:@([var getId])];
   if (r == nil) {
      r = [[ORRating alloc] init];
      [_choiceRating setObject:r forKey:@([var getId])];
   }
   return r;
}
-(double)lastChoiceRating
{
   return _lcr;
}

-(void)initInternal:(id<ORVarArray>)t with:(id<CPVarArray>)cvs
{
   id<ORPost> pItf = [[CPINCModel alloc] init:_cp];
   [[_cp explorer] push:[[ORSemFDSController alloc] initTheController:[_cp tracer]
                                                               engine:[_cp engine]
                                                              posting:pItf
                                                            heuristic:self]];
   _vars = t;
   _cvs  = cvs;
   id<ORIntVarArray> av = [self allIntVars];
   id* gamma = [_cp gamma];
   id<CPIntVarArray> cav = [CPFactory intVarArray:_cp range:av.range with:^id<CPIntVar>(ORInt i) {
      return gamma[av[i].getId];
   }];
   id<ORTracer> tracer = [_cp tracer];
   _monitor = [[CPStatisticsMonitor alloc] initCPMonitor:[_cp engine] vars:cav];
   _nbv = [_cvs count];
   [_engine post:_monitor];
   [ORConcurrency pumpEvents];
   [self initRatings:cav];
   
   [[[_cp portal] retLT] wheneverNotifiedDo:^void(id var,ORInt val) {
      int d = [tracer level];
      double localRating = 1.0 + [_monitor reduction];
      //NSLog(@"[%d]%@ ≤ %d ==> %f",d,var,val,localRating);
      ORAvgRating* art = [self avgRatingAtDepth:d];
      ORRating* theRating = [self branchForSide:1 var:var cst:val];
      double ratingChoice = _lcr = ALPHA * theRating.rating + (1- ALPHA) * localRating/art.avgRating;
      [art addSample:localRating];
      [theRating setRating:ratingChoice];
      ORRating* vr = [self choiceRatingFor:var];
      ORRating* theOtherRating = [self branchForSide:-1 var:var cst:val+1];
      [vr setRating:ratingChoice + theOtherRating.rating];
   }];
   [[[_cp portal] retGT] wheneverNotifiedDo:^void(id var,ORInt val) {
      int d = [tracer level];
      double localRating = 1.0 + [_monitor reduction];
      //NSLog(@"[%d]%@ ≥ %d ==> %f",d,var,val,localRating);
      ORAvgRating* art = [self avgRatingAtDepth:d];
      ORRating* theRating = [self branchForSide:-1 var:var cst:val];
      double ratingChoice = _lcr = ALPHA * theRating.rating + (1- ALPHA) * localRating/art.avgRating;
      [theRating setRating:ratingChoice];
      [art addSample:localRating];

      ORRating* vr = [self choiceRatingFor:var];
      ORRating* theOtherRating = [self branchForSide:+1 var:var cst:val+1];
      [vr setRating:ratingChoice + theOtherRating.rating];
   }];
   [[[_cp portal] failLT] wheneverNotifiedDo:^void(id var,ORInt val) {
      int d = [tracer level];
      double localRating = 0.0;
      //NSLog(@"[%d]%@ ≤FAIL %d ==> %f",d,var,val,localRating);
      ORAvgRating* art = [self avgRatingAtDepth:d];
      ORRating* theRating = [self branchForSide:1 var:var cst:val];
      double ratingChoice = _lcr = ALPHA * theRating.rating;
      [art addSample:localRating];
      [theRating setRating:ratingChoice];
      ORRating* vr = [self choiceRatingFor:var];
      ORRating* theOtherRating = [self branchForSide:-1 var:var cst:val+1];
      [vr setRating:ratingChoice + theOtherRating.rating];
   }];
   [[[_cp portal] failGT] wheneverNotifiedDo:^void(id var,ORInt val) {
      int d = [tracer level];
      double localRating = 0.0;
      //NSLog(@"[%d]%@ ≥FAIL %d ==> %f",d,var,val,localRating);
      ORAvgRating* art = [self avgRatingAtDepth:d];
      ORRating* theRating = [self branchForSide:-1 var:var cst:val];
      double ratingChoice = _lcr = ALPHA * theRating.rating;
      [art addSample:localRating];
      [theRating setRating:ratingChoice];
      ORRating* vr = [self choiceRatingFor:var];
      ORRating* theOtherRating = [self branchForSide:+1 var:var cst:val+1];
      [vr setRating:ratingChoice + theOtherRating.rating];
   }];
   [[_cp engine] tryEnforceObjective];
   if ([[_cp engine] objective] != NULL)
      NSLog(@"FDS ready... %@",[[_cp engine] objective]);
   else
      NSLog(@"FDS ready... ");
}

-(id<ORIntVarArray>)allIntVars
{
   return (id<ORIntVarArray>) (_rvars!=nil ? _rvars : _vars);
}

-(void)initRatings:(id<CPIntVarArray>)cav
{
   ORInt blockWidth = 1;
   for(ORInt k=cav.low; k <= cav.up;k++) {
      NSMutableSet* sacs = [[NSMutableSet alloc] initWithCapacity:2];
      id<CPIntVar> v = cav[k];
      ORBounds vb = [v bounds];
      [_monitor rootRefresh];
      [self dichotomize:[[_cp tracer] level] var:v from:vb.min to:vb.max block:blockWidth sac:sacs];
      ORInt rank = 0;
      ORInt lastRank = (ORInt)[sacs count]-1;
      ORStatus status = ORSuspend;
      for(CPFDSKillRange* kr in sacs) {
         if (rank == 0 && [kr low] == [v min]) {
            if ([_engine enforce: ^{ [v updateMin:[kr up]+1];}] == ORFailure)   // gthen:v with:[kr up]];
               status = ORFailure;
         }
         else if (rank == lastRank && [kr up] == [v max]) {
            if ([_engine enforce: ^{ [v updateMax:[kr low]-1];}] == ORFailure) // lthen:v with:[kr low]];
               status = ORFailure;
         }
         else {
            for(ORInt i=[kr low];i <= [kr up];i++)
               if ([_engine enforce: ^{ [v remove:i];}] == ORFailure) // diff:v with:i];
                  status = ORFailure;
         }
         rank++;
      }
      [sacs release];
      if (status == ORFailure)
         failNow();
      //NSLog(@"ROUND(X) : %@  impact: %f",v,[self varOrdering:v]);
   }
   [_monitor rootRefresh];
   //NSLog(@"VARS AT END OF INIT:%@ ",av);
}


-(void)addKillSetFrom:(ORInt)from to:(ORInt)to size:(ORUInt)sz into:(NSMutableSet*)set
{
   for(CPFDSKillRange* kr in set) {
      if (to+1 == kr->_low) {
         CPFDSKillRange* newRange = [[CPFDSKillRange alloc] initCPKillRange:from to:kr->_up size:kr->_nbKilled + sz];
         [set addObject:newRange];
         [newRange release];
         [set removeObject:kr];
         return;
      } else if (kr->_up + 1 == from) {
         CPFDSKillRange* newRange = [[CPFDSKillRange alloc] initCPKillRange:kr->_low to:to size:kr->_nbKilled + sz];
         [set addObject:newRange];
         [newRange release];
         [set removeObject:kr];
         return;
      }
   }
   CPFDSKillRange* newRange = [[CPFDSKillRange alloc] initCPKillRange:from to:to size:sz];
   [set addObject:newRange];
   [newRange release];
   return;
}

-(void)dichotomize:(ORInt)d var:(id<CPIntVar>)x from:(ORInt)low to:(ORInt)up block:(ORInt)b sac:(NSMutableSet*)set
{
   if (up - low + 1 <= b) {
      //NSLog(@"Bottom of probe...");
   } else {
      ORInt mid = low + (up - low)/2;
      id<ORTracer> tracer = [_cp tracer];
      [tracer pushNode];
      ORStatus s1 = [_engine enforce:^{ [x updateMax:mid];}];
      [ORConcurrency pumpEvents];
      if (s1!=ORFailure) {
         double localRating = 1.0 + [_monitor reduction];
         //NSLog(@"[%d]%@ ≤ %d ==> %f",d,var,val,localRating);
         ORAvgRating* art = [self avgRatingAtDepth:d];
         ORRating* theRating = [self branchForSide:1 var:x cst:mid];
         double ratingChoice = _lcr = ALPHA * theRating.rating + (1- ALPHA) * localRating/art.avgRating;
         [art addSample:localRating];
         [theRating setRating:ratingChoice];
         ORRating* vr = [self choiceRatingFor:x];
         ORRating* theOtherRating = [self branchForSide:-1 var:x cst:mid+1];
         [vr setRating:ratingChoice + theOtherRating.rating];

         [self dichotomize:d+1 var:x from:low to:mid block:b sac:set];
      } else {
         // [ldm] We know that x IN [l..mid] leads to an inconsistency. -> record a SAC.
         [self addKillSetFrom:low to:mid size:[x countFrom:low to:mid] into:set];
      }
      [tracer popNode];
      [tracer pushNode];
      ORStatus s2 = [_engine enforce: ^{ [x updateMin:mid+1];}];// gthen:x with:mid];
      [ORConcurrency pumpEvents];
      if (s2!=ORFailure) {
         double localRating = 1.0 + [_monitor reduction];
         //NSLog(@"[%d]%@ ≥ %d ==> %f",d,var,val,localRating);
         ORAvgRating* art = [self avgRatingAtDepth:d];
         ORRating* theRating = [self branchForSide:-1 var:x cst:mid+1];
         double ratingChoice = _lcr = ALPHA * theRating.rating + (1- ALPHA) * localRating/art.avgRating;
         [theRating setRating:ratingChoice];
         [art addSample:localRating];
         ORRating* vr = [self choiceRatingFor:x];
         ORRating* theOtherRating = [self branchForSide:+1 var:x cst:mid];
         [vr setRating:ratingChoice + theOtherRating.rating];
         
         [self dichotomize:d+1 var:x from:mid+1 to:up block:b sac:set];
      } else {
         // [ldm] We know that x IN [mid+1..up] leads to an inconsistency. -> record a SAC.
         [self addKillSetFrom:mid+1 to:up size:[x countFrom:mid+1 to:up] into:set];
      }
      [tracer popNode];
   }
}
@end
