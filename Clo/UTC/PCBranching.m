//
//  PCBranching.m
//  Clo
//
//  Created by Laurent Michel on 4/12/16.
//
//

#import "PCBranching.h"

@interface VStat : NSObject {
   double _down;
   double _up;
   double _nbl,_nbu;
}
-(id)init;
-(id)initLow:(double)d up:(double)u;
-(void)recordLow:(double)d up:(double)u;
-(void)recordLow:(double)d;
-(void)recordUp:(double)u;
-(double)pseudoDown;
-(double)pseudoUp;
-(double)scoreWn:(double)wn Wp:(double)wp;
@end


@implementation VStat
-(id)init
{
   self = [super init];
   _nbl = _nbu = 0;
   return self;
}
-(id)initLow:(double)d up:(double)u
{
   self = [super init];
   _down = d;
   _up   = u;
   _nbl = _nbu = 1;
   return self;
}
-(NSString*)description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<VStat(%f,%f) :: %f,%f  AVG: %f,%f>",_nbl,_nbu,_down,_up,self.pseudoDown,self.pseudoUp];
   return buf;
}
-(void)recordLow:(double)d up:(double)u
{
   _nbl++;_nbu++;
   _down += d;
   _up   +=u;
}
-(void)recordLow:(double)d
{
   _nbl++;
   _down += d;
}
-(void)recordUp:(double)d
{
   _nbu++;
   _up += d;
}

-(double)pseudoDown
{
   return _nbl > 0 ? _down / _nbl : FDMAXINT;
}
-(double)pseudoUp
{
   return _nbu > 0 ? _up / _nbu : FDMAXINT;
}
-(double)scoreWn:(double)wn Wp:(double)wp
{
   static const double mu = 1.0 / 6.0;
   double qn = wn * [self pseudoDown];
   double qp = wp * [self pseudoUp];
   return (1 - mu) * min(qn,qp) + mu * max(qn,qp);
}
@end

@implementation PCBranching {
   id<ORRelaxation>   _relax;
   id<ORIntVarArray>   _vars;
   id<CPCommonProgram>    _p;
   NSMutableDictionary*  _pc;
   ORDouble            _flip;
   VStat*           _overall;
}
-(id)init:(id<ORRelaxation>)relax over:(id<ORIntVarArray>)vars program:(id<CPCommonProgram>)p
{
   self =  [super init];
   _relax = relax;
   _vars  = vars;
   _p     = p;
   _flip = [[_p objective] isMinimization] ? 1.0 : -1.0;
   _overall = [[VStat alloc] init];
   _pc    = [[NSMutableDictionary alloc] init];
   [[p explorer] applyController:[[ORSemDFSController alloc] initTheController:[p tracer] engine:[p engine] posting:nil]
   in:^{
      double io = [relax objective];
      for(ORInt i=_vars.range.low;i <= _vars.range.up;i++) {
         id<ORIntVar> vi = _vars[i];
         double vir = [_relax value:vi];
         double g   = 0;
         double f   = modf(vir,&g);
         if (f != 0) {
            double dm  = f,um  = 1.0 - f;
            __block ORDouble downRate = 0;
            __block ORDouble upRate   = 0;
            double lb = [relax lowerBound:vi];
            double ub = [relax upperBound:vi];
            [relax updateUpperBound:vi with:g];
            OROutcome sLow = [relax solve];
            assert(sLow == ORoptimal);
            double roDown = [relax objective];
            downRate = _flip * (roDown - io) / dm;
            [relax updateUpperBound:vi with:ub];
            [relax updateLowerBound:vi with:g+1];
            OROutcome sUp = [relax solve];
            assert(sUp == ORoptimal);
            double roUp = [relax objective];
            upRate = _flip * (roUp - io) / um;
            [relax updateLowerBound:vi with:lb];
            OROutcome back = [relax solve];
            assert(back == ORoptimal);
            double finalOBJ = [relax objective];
            assert(finalOBJ==io);
            printf("DOWN/UP(%d) [%f]  = %f,%f\n",vi.getId,vir,roDown,roUp);
            VStat* vs = [_pc objectForKey:@(vi.getId)];
            if (vs==nil) {
               vs = [[VStat alloc] initLow:downRate up:upRate];
               [_pc setObject:vs forKey:@(vi.getId)];
               [vs release];
            } else {
               [vs recordLow:downRate up:upRate];
            }
            [_overall recordLow:downRate up:upRate];
         }
      }
   }];
   return self;
}
-(void)dealloc
{
   [_pc release];
   [_overall release];
   [super dealloc];
}
-(VStat*)pCost:(id<ORVar>)x
{
   NSNumber* key = [NSNumber numberWithInt:x.getId];
   VStat* vs = [_pc objectForKey:key];
   [key release];
   return vs ? vs : _overall;
}
-(ORInt)selectVar
{
   ORInt  bk = _vars.range.low - 1;
   double BSF =  - MAXDBL;
   for(ORInt i=_vars.range.low;i <= _vars.range.up;i++) {
      double vir = [_relax value:_vars[i]];
      double g   = 0;
      double f   = modf(vir,&g);
      if (f == 0) continue;
      double fn  = f, fp = 1.0 - f;
      VStat* pc = [self pCost:_vars[i]];
      assert(pc != nil);
      double q = [pc scoreWn:fn Wp:fp];
      if (q > BSF) {
         bk = i;
         BSF = q;
      }
   }
   return bk;
}
-(void)recordVar:(id<ORVar>)x low:(double)low
{
   VStat* vs = [_pc objectForKey:@(x.getId)];
   if (vs==nil) {
      vs = [[VStat alloc] init];
      [_pc setObject:vs forKey:@(x.getId)];
      [vs release];
   }
   [vs recordLow:low];
   [_overall recordLow:low];
}
-(void)recordVar:(id<ORVar>)x up:(double)up
{
   VStat* vs = [_pc objectForKey:@(x.getId)];
   if (vs==nil) {
      vs = [[VStat alloc] init];
      [_pc setObject:vs forKey:@(x.getId)];
      [vs release];
   }
   [vs recordUp:up];
   [_overall recordUp:up];
}
-(void)measureDown:(id<ORVar>)x for:(ORClosure)cl
{
   double xv = [_relax value:x];
   double xi = 0;
   double xf = modf(xv,&xi);
   double m  = xf;
   double f0 = [_relax objective];
   cl();
   double f1 = [_relax objective];
   double df = _flip * (f1 - f0);
   double downRate = df / m;
   [self recordVar:x low:downRate];
}
-(void)measureUp:(id<ORVar>)x for:(ORClosure)cl
{
   double xv = [_relax value:x];
   double xi = 0;
   double xf = modf(xv,&xi);
   double m  = 1.0 - xf;
   double f0 = [_relax objective];
   cl();
   double f1 = [_relax objective];
   double df = _flip * (f1 - f0);
   double upRate = df / m;
   [self recordVar:x up:upRate];
}
@end
