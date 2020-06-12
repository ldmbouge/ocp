/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import "CPFloatConstraint.h"
#import "CPFloatVarI.h"
#import "CPDoubleVarI.h"
#import "ORConstraintI.h"
#import <fenv.h>

#define PERCENT 5.0


@implementation CPFloatCast{
   int _precision;
   int _rounding;
   float_interval _resi;
   double_interval _initiali;
   ORBool _rewrite;
}
-(id) init:(CPFloatVarI*)res equals:(CPDoubleVarI*)initial rewrite:(ORBool) rewrite
{
   self = [super initCPCoreConstraint: [res engine]];
   _res = res;
   _initial = initial;
   _resi = makeFloatInterval(_res.min, _res.max);
   _initiali = makeDoubleInterval(_initial.min, _initial.max);
   _precision = 1;
   _rounding = FE_TONEAREST;
   _rewrite = rewrite;
   return self;
}
-(void) post
{
   [self propagate];
   if(![_res bound])        [_res whenChangeBoundsPropagate:self];
   if(![_initial bound])    [_initial whenChangeBoundsPropagate:self];
   if(_rewrite){
      [[[_res engine] mergedVar] notifyWith:_res andId:_initial isStatic:YES];
      [[_res engine] incNbRewrites:1];
   }
}
-(void) propagate
{
   if([_initial bound]){
      if(is_eqf([_initial min],-0.0f) && is_eqf([_initial max],+0.0f))
         [_res updateInterval:[_initial min] and:[_initial max]];
      else
         [_res bind:[_initial value]];
      assignTRInt(&_active, NO, _trail);
      return;
   }
   if(isDisjointWithDV([_res min],[_res max],[_initial min],[_initial max])){
      failNow();
   }else {
      updateFloatInterval(&_resi,_res);
      updateDoubleInterval(&_initiali,_initial);
      intersectionInterval inter;
      float_interval resTmp = makeFloatInterval(_resi.inf, _resi.sup);
      fpi_dtof(_precision, _rounding, &resTmp, &_initiali);
      inter = intersection(_res, _resi, resTmp, 0.0f);
      if(inter.changed)
         [_res updateInterval:inter.result.inf and:inter.result.sup];
      
      
      updateFloatInterval(&_resi,_res);
      double_interval initialTmp = makeDoubleInterval(_initiali.inf, _initiali.sup);
      intersectionIntervalD inter2;
      fpi_dtof_inv(_precision, _rounding, &initialTmp,&_resi);
      inter2 = intersectionD(_initial,_initiali, initialTmp, 0.0f);
      if(inter2.changed)
         [_initial updateInterval:inter2.result.inf and:inter2.result.sup];
   }
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_res,_initial,nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_res,_initial,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_res bound] + ![_initial bound];
}
-(NSString*)description
{
   return [NSString stringWithFormat:@"<%@ castedTo %@>",_initial,_res];
}
- (id<CPVar>)result
{
   return _res;
}
@end

//unary minus constraint
@implementation CPFloatUnaryMinus{
   int _precision;
   int _rounding;
   float_interval _xi;
   float_interval _yi;
   ORBool _rewrite;
}
-(id) init:(CPFloatVarI*)x eqm:(CPFloatVarI*)y rewrite:(ORBool) r
{
   self = [super initCPCoreConstraint: [x engine]];
   _x = x;
   _y = y;
   _xi = makeFloatInterval(x.min, x.max);
   _yi = makeFloatInterval(y.min, y.max);
   _precision = 1;
   _rounding = FE_TONEAREST;
   _rewrite = r;
   return self;
}
-(void) post
{
   [self propagate];
   if(![_x bound])  [_x whenChangeBoundsPropagate:self];
   if(![_y bound])  [_y whenChangeBoundsPropagate:self];
   if(_rewrite){
      [[[_x engine] mergedVar] notifyWith:_x andId:_y isStatic:YES];
      [[_x engine] incNbRewrites:1];
   }
}
-(void) propagate
{
   if([_x bound]){
      if([_y bound]){
         if([_x value] != - [_y value]) failNow();
         assignTRInt(&_active, NO, _trail);
      }else{
         [_y bind:-[_x value]];
         assignTRInt(&_active, NO, _trail);
      }
   }else if([_y bound]){
      [_x bind:-[_y value]];
      assignTRInt(&_active, NO, _trail);
   }else {
      updateFloatInterval(&_xi,_x);
      updateFloatInterval(&_yi,_y);
      intersectionInterval inter;
      float_interval yTmp = makeFloatInterval(_yi.inf, _yi.sup);
      fpi_minusf(_precision,_rounding, &yTmp, &_xi);
      inter = intersection(_y, _yi, yTmp, 0.0f);
      if(inter.changed)
         [_y updateInterval:inter.result.inf and:inter.result.sup];
      
      updateFloatInterval(&_yi,_y);
      float_interval xTmp = makeFloatInterval(_xi.inf, _xi.sup);
      fpi_minusf(_precision,_rounding, &xTmp, &_yi);
      inter = intersection(_x, _xi, xTmp, 0.0f);
      if(inter.changed)
         [_x updateInterval:inter.result.inf and:inter.result.sup];
   }
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_y,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_y bound];
}
-(NSString*)description
{
   return [NSString stringWithFormat:@"<%@ == -%@>",_x,_y];
}
- (id<CPVar>)result
{
   return _x;
}
@end

@implementation CPFloatEqual{
   ORBool _rewrite;
}
-(id) init:(CPFloatVarI*)x equals:(CPFloatVarI*)y  rewrite:(ORBool) rewrite
{
   self = [super initCPCoreConstraint: [x engine]];
   _x = x;
   _y = y;
   _rewrite = rewrite;
   return self;
}
-(void) post
{
   [self propagate];
   if(![_x bound])  [_x whenChangeBoundsPropagate:self];
   if(![_y bound])  [_y whenChangeBoundsPropagate:self];
   if(isPositiveOrNegative(_x) && isPositiveOrNegative(_y))
      [_x setCenter:_y];
   if(_rewrite){
      [[[_x engine] mergedVar] notifyWith:_x andId:_y isStatic:[[_x engine] isPosting]];
      [[_x engine] incNbRewrites:1];
   }
}
-(void) propagate
{
   if([_x bound]){
      [_y bind:[_x value]];
      assignTRInt(&_active, NO, _trail);
      return;
   }else if([_y bound]){
      [_x bind:[_y value]];
      assignTRInt(&_active, NO, _trail);
      return;
   }
   if(isDisjointWith(_x,_y)){
      failNow();
   }else{
      ORFloat min = maxFlt([_x min], [_y min]);
      ORFloat max = minFlt([_x max], [_y max]);
      [_x updateInterval:min and:max];
      [_y updateInterval:min and:max];
      if(_x.min == _x.max && _y.min == _y.max) //to deal with -0,0
         assignTRInt(&_active, NO, _trail);
         
   }
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_y,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_y bound];
}
-(NSString*)description
{
   return [NSString stringWithFormat:@"<%@ == %@>",_x,_y];
}
@end

@implementation CPFloatEqualc
-(id) init:(CPFloatVarI*)x and:(ORFloat)c
{
   self = [super initCPCoreConstraint: [x engine]];
   _x = x;
   _c = c;
   return self;
   
}
-(void) post
{
   //hzi : equality constraint is different from assignment constraint for 0.0
   //in case when check equality -0.0f == 0.0f
   //in case of assignement x = -0.0f != from x = 0.0f
   if(_c == 0.f)
      [_x updateInterval:-0.0f and:+0.0f];
   else
      [_x bind:_c];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_x bound];
}
-(NSString*)description
{
   return [NSString stringWithFormat:@"<%@ == %16.16e>",_x,_c];
}
@end

@implementation CPFloatAssign{
   int _precision;
   int _rounding;
   float_interval _xi;
   float_interval _yi;
}
-(id) init:(CPFloatVarI*)x set:(CPFloatVarI*)y
{
   self = [super initCPCoreConstraint: [x engine]];
   _x = x;
   _y = y;
   _xi = makeFloatInterval(x.min, x.max);
   _yi = makeFloatInterval(y.min, y.max);
   _precision = 1;
   _rounding = FE_TONEAREST;
   return self;
}
-(void) post
{
   [self propagate];
    if(![_x bound])  [_x whenChangeBoundsPropagate:self];
    if(![_y bound])  [_y whenChangeBoundsPropagate:self];
   [_x setCenter:_y];
}
-(void) propagate
{
   if(isDisjointWith(_x,_y)){
      failNow();
   }
   updateFloatInterval(&_xi,_x);
   updateFloatInterval(&_yi,_y);
   intersectionInterval inter;
   float_interval yTmp = makeFloatInterval(_yi.inf, _yi.sup);
   fpi_setf(_precision,_rounding, &yTmp, &_xi);
   inter = intersection(_y, _yi, yTmp, 0.0f);
   if(inter.changed)
      [_y updateInterval:inter.result.inf and:inter.result.sup];
   
   updateFloatInterval(&_yi,_y);
   float_interval xTmp = makeFloatInterval(_xi.inf, _xi.sup);
   fpi_setf(_precision,_rounding, &xTmp, &_yi);
   inter = intersection(_x, _xi, xTmp, 0.0f);
   if(inter.changed)
      [_x updateInterval:inter.result.inf and:inter.result.sup];
   
   if([_x bound] && [_y bound])
      assignTRInt(&_active, NO, _trail);
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_y bound];
}
-(NSString*)description
{
   return [NSString stringWithFormat:@"<%@ <- %@>",_x,_y];
}
- (id<CPVar>)result
{
   return _x;
}
@end

@implementation CPFloatAssignC
-(id) init:(CPFloatVarI*)x set:(ORFloat)c
{
   self = [super initCPCoreConstraint: [x engine]];
   _x = x;
   _c = c;
   return self;
   
}
-(void) post
{
   [_x bind:_c];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_x bound];
}
-(NSString*)description
{
   return [NSString stringWithFormat:@"<%@ = %16.16e>",_x,_c];
}
- (id<CPVar>)result
{
   return _x;
}
@end


@implementation CPFloatNEqual
-(id) init:(CPFloatVarI*)x nequals:(CPFloatVarI*)y
{
   self = [super initCPCoreConstraint: [x engine]];
   _x = x;
   _y = y;
   return self;
   
}
-(void) post
{
   [self propagate];
   if(![_x bound])[_x whenBindPropagate:self];
   if(![_y bound])[_y whenBindPropagate:self];
}
-(void) propagate
{
   if ([_x bound]) {
      if([_y bound]){
         if ([_x min] == [_y min])
            failNow();
         else{
            if([_x min] == [_y min]){
               [_y updateMin:fp_next_float([_y min])];
               assignTRInt(&_active, NO, _trail);
            }
            if([_x min] == [_y max]) {
               [_y updateMax:fp_previous_float([_y max])];
               assignTRInt(&_active, NO, _trail);
            }
         }
         return;
      }
   }else  if([_y bound]){
      if([_x min] == [_y min]){
         [_x updateMin:fp_next_float([_x min])];
         assignTRInt(&_active, NO, _trail);
      }
      if([_x max] == [_y min]){
         [_x updateMax:fp_previous_float([_x max])];
         assignTRInt(&_active, NO, _trail);
      }
   }
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_y,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_y bound];
}
-(NSString*)description
{
   return [NSString stringWithFormat:@"<%@ != %@>",_x,_y];
}
@end

@implementation CPFloatNEqualc
-(id) init:(CPFloatVarI*)x and:(ORFloat)c
{
   self = [super initCPCoreConstraint: [x engine]];
   _x = x;
   _c = c;
   return self;
}
-(void)dealloc
{
   [super dealloc];
}
-(void) post
{
   [self propagate];
   if(![_x bound]){
      [_x whenBindPropagate:self];
      [_x whenChangeBoundsPropagate:self];
   }
}
-(void) propagate
{
   if ([_x bound]) {
      if([_x min] == _c)
         failNow();
   }else{
      if([_x min] == _c){
         [_x updateMin:fp_next_float(_c)];
         assignTRInt(&_active, NO, _trail);
      }
      if([_x max] == _c){
         [_x updateMax:fp_previous_float(_c)];
         assignTRInt(&_active, NO, _trail);
      }
   }
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_x bound];
}
-(NSString*)description
{
   return [NSString stringWithFormat:@"<%@ != %f>",_x,_c];
}
@end

@implementation CPFloatLT
-(id) init:(CPFloatVarI*)x lt:(CPFloatVarI*)y
{
   self = [super initCPCoreConstraint: [x engine]];
   _x = x;
   _y = y;
   return self;
}
-(void) post
{
   [self propagate];
   if(![_y bound]) [_y whenChangeBoundsPropagate:self];
   if(![_x bound]) [_x whenChangeBoundsPropagate:self];
}
-(void) propagate
{
   if(canFollow(_x,_y))
      failNow();
   if(isIntersectingWith(_x,_y)){
      if([_x min] >= [_y min]){
         ORFloat nmin = fp_next_float([_x min]);
         [_y updateMin:nmin];
      }
      if([_x max] >= [_y max]){
         ORFloat pmax = fp_previous_float([_y max]);
         [_x updateMax:pmax];
      }
   }
   if([_x bound] || [_y bound]){
      assignTRInt(&_active, NO, _trail);
      return;
   }
   
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_y,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_y bound];
}
-(NSString*)description
{
   return [NSString stringWithFormat:@"<%@ < %@>",_x,_y];
}
@end

@implementation CPFloatGT
-(id) init:(CPFloatVarI*)x gt:(CPFloatVarI*)y
{
   self = [super initCPCoreConstraint: [x engine]];
   _x = x;
   _y = y;
   return self;
}
-(void) post
{
   [self propagate];
   if(![_y bound]) [_y whenChangeBoundsPropagate:self];
   if(![_x bound]) [_x whenChangeBoundsPropagate:self];
}
-(void) propagate
{
   if(canPrecede(_x,_y))
      failNow();
   if(isIntersectingWith(_x,_y)){
      if([_x min] <= [_y min]){
         ORFloat pmin = fp_next_float([_y min]);
         [_x updateMin:pmin];
      }
      if([_x max] <= [_y max]){
         ORFloat nmax = fp_previous_float([_x max]);
         [_y updateMax:nmax];
      }
   }
   if([_x bound] || [_y bound]){
      assignTRInt(&_active, NO, _trail);
      return;
   }
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_y,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_y bound];
}

-(NSString*)description
{
   return [NSString stringWithFormat:@"<%@ > %@>",_x,_y];
}
@end


@implementation CPFloatLEQ
-(id) init:(CPFloatVarI*)x leq:(CPFloatVarI*)y
{
   self = [super initCPCoreConstraint: [x engine]];
   _x = x;
   _y = y;
   return self;
}
-(void) post
{
   [self propagate];
   if(![_y bound]) [_y whenChangeBoundsPropagate:self];
   if(![_x bound]) [_x whenChangeBoundsPropagate:self];
}
-(void) propagate
{
   if(canFollow(_x,_y))
      failNow();
   if(isIntersectingWith(_x,_y)){
      if([_x min] > [_y min]){
         ORFloat nmin = [_x min];
         [_y updateMin:nmin];
      }
      if([_x max] > [_y max]){
         ORFloat pmax = [_y max];
         [_x updateMax:pmax];
      }
   }
   if([_x bound] || [_y bound]){
      assignTRInt(&_active, NO, _trail);
      return;
   }
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_y,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_y bound];
}
-(NSString*)description
{
   return [NSString stringWithFormat:@"<%@ <= %@>",_x,_y];
}
@end

@implementation CPFloatGEQ
-(id) init:(CPFloatVarI*)x geq:(CPFloatVarI*)y
{
   self = [super initCPCoreConstraint: [x engine]];
   _x = x;
   _y = y;
   return self;
}
-(void) post
{
   [self propagate];
   if(![_y bound]) [_y whenChangeBoundsPropagate:self];
   if(![_x bound]) [_x whenChangeBoundsPropagate:self];
}
-(void) propagate
{
   if(canPrecede(_x,_y))
      failNow();
   if(isIntersectingWith(_x,_y)){
      if([_x min] < [_y min]){
         ORFloat pmin = [_y min];
         [_x updateMin:pmin];
      }
      if([_x max] < [_y max]){
         ORFloat nmax = [_x max];
         [_y updateMax:nmax];
      }
   }
   if([_x bound] || [_y bound]){
      assignTRInt(&_active, NO, _trail);
      return;
   }
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_y,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_y bound];
}
-(NSString*)description
{
   return [NSString stringWithFormat:@"<%@ >= %@>",_x,_y];
}
@end


@implementation CPFloatTernaryAdd{
   ORBool _rewrite;
}
-(id) init:(CPFloatVarI*)z equals:(CPFloatVarI*)x plus:(CPFloatVarI*)y
{
   return [self init:z equals:x plus:y kbpercent:PERCENT rewrite:NO];
}
-(id) init:(CPFloatVarI*)z equals:(CPFloatVarI*)x plus:(CPFloatVarI*)y kbpercent:(ORDouble)p
{
   return [self init:z equals:x plus:y kbpercent:p rewrite:NO];
}
-(id) init:(CPFloatVarI*)z equals:(CPFloatVarI*)x plus:(CPFloatVarI*)y rewrite:(ORBool)f
{
   return [self init:z equals:x plus:y kbpercent:PERCENT rewrite:f];
}
-(id) init:(CPFloatVarI*)z equals:(CPFloatVarI*)x plus:(CPFloatVarI*)y kbpercent:(ORDouble)p rewrite:(ORBool) f
{
   self = [super initCPCoreConstraint: [x engine]];
   _z = z;
   _x = x;
   _y = y;
   _precision = 1;
   _percent = p;
   _rounding = FE_TONEAREST;
   _rewrite = f;
   return self;
}
-(void) post
{
   [self propagate];
   if (![_x bound]) {
      [_x whenChangeBoundsPropagate:self];
      if(_rewrite)
         [_x whenChangeBoundsDo:^{
            [self propagateFixPoint];
         } priority:LOWEST_PRIO onBehalf:self];
   }
   if (![_y bound]) {
      [_y whenChangeBoundsPropagate:self];
      if(_rewrite)
         [_y whenChangeBoundsDo:^{
            [self propagateFixPoint];
         } priority:LOWEST_PRIO onBehalf:self];
   }
   if (![_z bound]) [_z whenChangeBoundsPropagate:self];
   
}
//hzi : _Temps variables are useless ? inter.result ? x is already changed ?
-(void) propagate
{
   int gchanged,changed;
   changed = gchanged = false;
   float_interval zTemp,yTemp,xTemp,z,x,y;
   intersectionInterval inter;
   z = makeFloatInterval([_z min],[_z max]);
   x = makeFloatInterval([_x min],[_x max]);
   y = makeFloatInterval([_y min],[_y max]);
   do {
      changed = false;
      zTemp = z;
      fpi_addf(_precision, _rounding, &zTemp, &x, &y);
      inter = intersection(_z, z, zTemp,_percent);
      z = inter.result;
      changed |= inter.changed;
      
      xTemp = x;
      yTemp = y;
      fpi_add_invsub_boundsf(_precision, _rounding, &xTemp, &yTemp, &z);
      inter = intersection(_x, x , xTemp,_percent);
      x = inter.result;
      changed |= inter.changed;
      
      inter = intersection(_y, y, yTemp,_percent);
      y = inter.result;
      changed |= inter.changed;
      
      xTemp = x;
      fpi_addxf_inv(_precision, _rounding, &xTemp, &z, &y);
      inter = intersection(_x, x , xTemp,_percent);
      x = inter.result;
      changed |= inter.changed;
      
      yTemp = y;
      fpi_addyf_inv(_precision, _rounding, &yTemp, &z, &x);
      inter = intersection(_y, y, yTemp,_percent);
      y = inter.result;
      changed |= inter.changed;
      gchanged |= changed;
   } while(changed);
   if(gchanged) {
      [_x updateInterval:x.inf and:x.sup];
      [_y updateInterval:y.inf and:y.sup];
      [_z updateInterval:z.inf and:z.sup];
      if(![self nbUVars])
         assignTRInt(&_active, NO, _trail);
   }
   fesetround(FE_TONEAREST);
}
-(void) propagateFixPoint
{
   if([self nbUVars]){
      if(absorb(_x,_y)){
//         NSLog(@"Absorb rewriting %@",self);
         assignTRInt(&_active, NO, _trail);
         [self addConstraint:[CPFactory floatEqual:_z to:_x rewrite:YES] engine:[_x engine]];
      }else if(absorb(_y,_x) ){
//         NSLog(@"Absorb rewriting %@",self);
         assignTRInt(&_active, NO, _trail);
         [self addConstraint:[CPFactory floatEqual:_z to:_y rewrite:YES] engine:[_x engine]];
      }
   }
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_z,_x,_y,nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_y,_z,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_y bound] + ![_z bound];
}
-(id<CPVar>) varSubjectToAbsorption:(id<CPFloatVar>)x
{
   if([x getId] == [_x getId])
      return _y;
   else if([x getId] == [_y getId])
      return _x;
   return nil;
}
-(ORBool) canLeadToAnAbsorption
{
   return true;
}
//hzi : todo check cancellation for odometrie_10
-(ORDouble) leadToACancellation:(id<ORVar>)x
{
   ORInt exmin, exmax, eymin,eymax,ezmin,ezmax,gmax,zmin;
   frexpf(fabs([_x min]),&exmin);
   frexpf(fabs([_x max]),&exmax);
   frexpf(fabs([_y min]),&eymin);
   frexpf(fabs([_y max]),&eymax);
   frexpf(fabs([_z min]),&ezmin);
   frexpf(fabs([_z max]),&ezmax);
   gmax = max(exmin, exmax);
   gmax = max(gmax,eymin);
   gmax = max(gmax,eymax);
   zmin = (([_z min] <= 0 && [_z max] >= 0) || ([_x min] == 0.f && [_x max] == 0.f) ||([_y min] == 0.0f && [_y max] == 0.0f)) ? 0.0 : min(ezmin,ezmax);
   return gmax-zmin;
}
-(NSString*)description
{
   return [NSString stringWithFormat:@"<%@ = %@ + %@>",_z, _x, _y];
}
- (id<CPVar>)result
{
   return _z;
}
@end


@implementation CPFloatTernarySub{
   ORBool _rewrite;
}
-(id) init:(CPFloatVarI*)z equals:(CPFloatVarI*)x minus:(CPFloatVarI*)y kbpercent:(ORDouble)p rewrite:(ORBool) f
{
   self = [super initCPCoreConstraint: [x engine]];
   _z = z;
   _x = x;
   _y = y;
   _precision = 1;
   _percent = p;
   _rounding = FE_TONEAREST;
   _rewrite = f;
   return self;
}
-(id) init:(CPFloatVarI*)z equals:(CPFloatVarI*)x minus:(CPFloatVarI*)y kbpercent:(ORDouble)p
{
   return [self init:z equals:x minus:y kbpercent:p rewrite:NO];
}
-(id) init:(CPFloatVarI*)z equals:(CPFloatVarI*)x minus:(CPFloatVarI*)y rewrite:(ORBool)f
{
   return [self init:z equals:x minus:y kbpercent:PERCENT rewrite:f];
}
-(id) init:(CPFloatVarI*)z equals:(CPFloatVarI*)x minus:(CPFloatVarI*)y
{
   return [self init:z equals:x minus:y kbpercent:PERCENT rewrite:NO];
}
-(void) post
{
   [self propagate];
   if (![_x bound]) {
      [_x whenChangeBoundsPropagate:self];
      if(_rewrite)
         [_x whenChangeBoundsDo:^{
            [self propagateFixPoint];
         } priority:LOWEST_PRIO onBehalf:self];
   }
   if (![_y bound]) {
      [_y whenChangeBoundsPropagate:self];
      if(_rewrite)
         [_y whenChangeBoundsDo:^{
            [self propagateFixPoint];
         } priority:LOWEST_PRIO onBehalf:self];
   }
   if (![_z bound]) [_z whenChangeBoundsPropagate:self];
   
}
-(void) propagate
{
   int gchanged,changed;
   changed = gchanged = false;
   float_interval zTemp,yTemp,xTemp,z,x,y;
   intersectionInterval inter;
   z = makeFloatInterval([_z min],[_z max]);
   x = makeFloatInterval([_x min],[_x max]);
   y = makeFloatInterval([_y min],[_y max]);
   do {
      changed = false;
      zTemp = z;
      fpi_subf(_precision, _rounding, &zTemp, &x, &y);
      inter = intersection(_z, z, zTemp,_percent);
      z = inter.result;
      changed |= inter.changed;
      
      xTemp = x;
      yTemp = y;
      fpi_sub_invsub_boundsf(_precision, _rounding, &xTemp, &yTemp, &z);
      inter = intersection(_x, x , xTemp,_percent);
      x = inter.result;
      changed |= inter.changed;
      
      inter = intersection(_y, y, yTemp,_percent);
      y = inter.result;
      changed |= inter.changed;
      
      xTemp = x;
      fpi_subxf_inv(_precision, _rounding, &xTemp, &z, &y);
      inter = intersection(_x, x , xTemp,_percent);
      x = inter.result;
      changed |= inter.changed;
      
      yTemp = y;
      fpi_subyf_inv(_precision, _rounding, &yTemp, &z, &x);
      inter = intersection(_y, y, yTemp,_percent);
      y = inter.result;
      changed |= inter.changed;
      gchanged |= changed;
   } while(changed);
   if(gchanged) {
      [_x updateInterval:x.inf and:x.sup];
      [_y updateInterval:y.inf and:y.sup];
      [_z updateInterval:z.inf and:z.sup];
      if(![self nbUVars])
         assignTRInt(&_active, NO, _trail);
   }
      fesetround(FE_TONEAREST);
}
-(void) propagateFixPoint
{
   if([self nbUVars]){
      if(absorb(_x,_y)){
//         NSLog(@"Absorb rewriting %@",self);
         assignTRInt(&_active, NO, _trail);
         [self addConstraint:[CPFactory floatEqual:_z to:_x rewrite:YES] engine:[_x engine]];
      }else if(absorb(_y,_x) ){
//         NSLog(@"Absorb rewriting %@",self);
         assignTRInt(&_active, NO, _trail);
         [self addConstraint:[CPFactory floatEqual:_z to:_y rewrite:YES] engine:[_x engine]];
      }
   }
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_z,_x,_y,nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_y,_z,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_y bound] + ![_z bound];
}
-(id<CPVar>) varSubjectToAbsorption:(id<CPFloatVar>)x
{
   if([x getId] == [_x getId])
      return _y;
   else if([x getId] == [_y getId])
      return _x;
   return nil;
}
-(ORBool) canLeadToAnAbsorption
{
   return true;
}
-(ORDouble) leadToACancellation:(id<ORVar>)x
{
   ORInt exmin, exmax, eymin,eymax,ezmin,ezmax,gmax,zmin;
   frexpf([_x min],&exmin);
   frexpf([_x max],&exmax);
   frexpf([_y min],&eymin);
   frexpf([_y max],&eymax);
   frexpf([_z min],&ezmin);
   frexpf([_z max],&ezmax);
   gmax = max(exmin, exmax);
   gmax = max(gmax,eymin);
   gmax = max(gmax,eymax);
   zmin = (([_z min] <= 0 && [_z max] >= 0) || ([_x min] == 0.f && [_x max] == 0.f) ||([_y min] == 0.0f && [_y max] == 0.0f)) ? 0.0 : min(ezmin,ezmax);
   return gmax-zmin;
}
-(NSString*)description
{
   return [NSString stringWithFormat:@"<%@ = %@ - %@>",_z, _x, _y];
}
- (id<CPVar>)result
{
   return _z;
}
@end

@implementation CPFloatTernaryMult
-(id) init:(CPFloatVarI*)z equals:(CPFloatVarI*)x mult:(CPFloatVarI*)y kbpercent:(ORDouble)p
{
   self = [super initCPCoreConstraint: [x engine]];
   _z = z;
   _x = x;
   _y = y;
   _precision = 1;
   _percent = p;
   _rounding = FE_TONEAREST;
   return self;
}
-(id) init:(CPFloatVarI*)z equals:(CPFloatVarI*)x mult:(CPFloatVarI*)y
{
   return [self init:z equals:x mult:y kbpercent:PERCENT];
}
-(void) post
{
   [self propagate];
   if (![_x bound]) [_x whenChangeBoundsPropagate:self];
   if (![_y bound]) [_y whenChangeBoundsPropagate:self];
   if (![_z bound]) [_z whenChangeBoundsPropagate:self];
}
-(void) propagate
{
   CPFloatVarI* cz;CPFloatVarI* cx;CPFloatVarI* cy;
   cz = [_z getCenter];
   cx = [_x getCenter];
   cy = [_y getCenter];
   if(cx == cy){
      assignTRInt(&_active, NO, _trail);
      [self addConstraint: [CPFactory floatSquare:cx eq:cz]engine:[cz engine]];;
      return;
   }
   int gchanged,changed;
   changed = gchanged = false;
   float_interval zTemp,yTemp,xTemp,z,x,y;
   intersectionInterval inter;
   z = makeFloatInterval([cz min],[cz max]);
   x = makeFloatInterval([cx min],[cx max]);
   y = makeFloatInterval([cy min],[cy max]);
   do {
      changed = false;
      zTemp = z;
      fpi_multf(_precision, _rounding, &zTemp, &x, &y);
      inter = intersection(cz, z, zTemp,_percent);
      z = inter.result;
      changed |= inter.changed;
      
      xTemp = x;
      fpi_multxf_inv(_precision, _rounding, &xTemp, &z, &y);
      inter = intersection(cx, x , xTemp,_percent);
      x = inter.result;
      changed |= inter.changed;
      
      yTemp = y;
      fpi_multyf_inv(_precision, _rounding, &yTemp, &z, &x);
      inter = intersection(cy, y, yTemp,_percent);
      y = inter.result;
      changed |= inter.changed;
      gchanged |= changed;
   } while(changed);
   if(gchanged) {
      [_x updateInterval:x.inf and:x.sup];
      [_y updateInterval:y.inf and:y.sup];
      [_z updateInterval:z.inf and:z.sup];
      if([cx bound] && [cy bound] && [cz bound])
         assignTRInt(&_active, NO, _trail);
   }
   fesetround(FE_TONEAREST);
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_z,_x,_y,nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_y,_z,nil] autorelease];
}
-(id<CPVar>) result
{
   return _z;
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_y bound] + ![_z bound];
}
-(NSString*)description
{
   return [NSString stringWithFormat:@"<%@ = %@ * %@>",_z, _x, _y];
}
@end

@implementation CPFloatTernaryDiv
-(id) init:(CPFloatVarI*)z equals:(CPFloatVarI*)x div:(CPFloatVarI*)y kbpercent:(ORDouble)p
{
   self = [super initCPCoreConstraint: [x engine]];
   _z = z;
   _x = x;
   _y = y;
   _precision = 1;
   _percent = p;
   _rounding = FE_TONEAREST;
   return self;
}
-(id) init:(CPFloatVarI*)z equals:(CPFloatVarI*)x div:(CPFloatVarI*)y
{
   return [self init:z equals:x div:y kbpercent:PERCENT];
}
-(void) post
{
   [self propagate];
   if (![_x bound]) [_x whenChangeBoundsPropagate:self];
   if (![_y bound]) [_y whenChangeBoundsPropagate:self];
   if (![_z bound]) [_z whenChangeBoundsPropagate:self];
}
-(void) propagate
{
   int gchanged,changed;
   changed = gchanged = false;
   float_interval zTemp,yTemp,xTemp,z,x,y;
   intersectionInterval inter;
   z = makeFloatInterval([_z min],[_z max]);
   x = makeFloatInterval([_x min],[_x max]);
   y = makeFloatInterval([_y min],[_y max]);
   do {
      changed = false;
      zTemp = z;
      fpi_divf(_precision, _rounding, &zTemp, &x, &y);
      inter = intersection(_z, z, zTemp,_percent);
      z = inter.result;
      changed |= inter.changed;
      
      xTemp = x;
      fpi_divxf_inv(_precision, _rounding, &xTemp, &z, &y);
      inter = intersection(_x, x , xTemp,_percent);
      x = inter.result;
      changed |= inter.changed;
      
      yTemp = y;
      fpi_divyf_inv(_precision, _rounding, &yTemp, &z, &x);
      inter = intersection(_y, y, yTemp,_percent);
      y = inter.result;
      changed |= inter.changed;
      gchanged |= changed;
   } while(changed);
   if(gchanged) {
      [_x updateInterval:x.inf and:x.sup];
      [_y updateInterval:y.inf and:y.sup];
      [_z updateInterval:z.inf and:z.sup];
      if([_x bound] && [_y bound] && [_z bound])
         assignTRInt(&_active, NO, _trail);
   }
   fesetround(FE_TONEAREST);
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_z,_x,_y,nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_y,_z,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_y bound] + ![_z bound];
}
-(NSString*)description
{
   return [NSString stringWithFormat:@"<%@ = %@ / %@>",_z, _x, _y];
}
- (id<CPVar>)result
{
   return _z;
}
@end

@implementation CPFloatReifyNEqual
-(id) initCPReify:(CPIntVar*)b when:(CPFloatVarI*)x neq:(CPFloatVarI*)y
{
   self = [super initCPCoreConstraint:[x engine]];
   _b = b;
   _x = x;
   _y = y;
   return self;
}

-(void) post
{
   [self propagate];
   if(![_b bound])
      [_b whenBindPropagate:self];
   if(![_x bound])
      [_x whenChangeBoundsPropagate:self];
   if(![_y bound])
      [_y whenChangeBoundsPropagate:self];
}
-(void)propagate
{
   if (minDom(_b)) {            // b is TRUE
      if ([_x bound] || [_x min] == [_x max]){            // TRUE <=> (y != c)
         [self addConstraint: [CPFactory floatNEqualc:_y to:[_x max]] engine:[_b engine]];         // Rewrite as x==y  (addInternal can throw)
         assignTRInt(&_active, NO, _trail);
         return;
      }else  if ([_y bound] || [_y min] == [_y max]) {     // TRUE <=> (x != c)
         [self addConstraint: [CPFactory floatNEqualc:_x to:[_y max]] engine:[_b engine]];         // Rewrite as x==y  (addInternal can throw)
         assignTRInt(&_active, NO, _trail);
         return;
      }
   }
   else if (maxDom(_b)==0) {     // b is FALSE
      if ([_x bound]){
         [_y bind:[_x min]];
         assignTRInt(&_active, NO, _trail);
         return;
      } else if ([_y bound]){
         [_x bind:[_y min]];
         assignTRInt(&_active, NO, _trail);
         return;
      }else {                    // FALSE <=> (x == y)
         [_x updateInterval:[_y min] and:[_y max]];
         [_y updateInterval:[_x min] and:[_x max]];
      }
   }
   else {                        // b is unknown
      if ([_x bound] && [_y bound]){
         [_b bind: [_x min] != [_y min]];
         assignTRInt(&_active, NO, _trail);
      } else if ([_x max] < [_y min] || [_y max] < [_x min]){
         [_b bind:YES];
         assignTRInt(&_active, NO, _trail);
         
      }
   }
}
-(NSString*)description
{
   return [NSMutableString stringWithFormat:@"<CPFloatReifyNEqual:%02d %@ <=> (%@ != %@)>",_name,_b,_x,_y];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,_b, nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_y,_b,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_x bound] +  ![_y bound] + ![_b bound];
}
@end

@implementation CPFloatReifyEqual{
   ORBool _drewrite;
   ORBool _srewrite;
}
-(id) initCPReifyEqual:(CPIntVar*)b when:(CPFloatVarI*)x eqi:(CPFloatVarI*)y dynRewrite:(ORBool) r staticRewrite:(ORBool) s
{
   self = [super initCPCoreConstraint:[x engine]];
   _b = b;
   _x = x;
   _y = y;
   _drewrite = r;
   _srewrite = s;
   return self;
}
-(id) initCPReifyEqual:(CPIntVar*)b when:(CPFloatVarI*)x eqi:(CPFloatVarI*)y
{
   self = [self initCPReifyEqual:b when:x eqi:y dynRewrite:NO staticRewrite:NO];
   return self;
}
-(void) post
{
   [self propagate];
   if(![_b bound])
      [_b whenBindPropagate:self];
   if(![_x bound])
      [_x whenChangeBoundsPropagate:self];
   if(![_y bound])
      [_y whenChangeBoundsPropagate:self];
   [_b whenBindDo:^{
        if( minDom(_b)){
           [_x setCenter:_y];
           if((_drewrite && ![[_x engine] isPosting]) || (_srewrite && [[_x engine] isPosting])){
              [[[_x engine] mergedVar] notifyWith:_x andId:_y  isStatic:[[_x engine] isPosting]];
                         [[_x engine] incNbRewrites:1];
           }
        }
     } onBehalf:self];
}
-(void)propagate
{
   if (minDom(_b)) {            // b is TRUE
      if ([_x bound]) {           // TRUE <=> (y == c)
         assignTRInt(&_active, 0, _trail);
         [_y bind:[_x min]];
      }else  if ([_y bound]) {     // TRUE <=> (x == c)
         assignTRInt(&_active, 0, _trail);
         [_x bind:[_y min]];
      } else {
         [_x updateInterval:[_y min] and:[_y max]];
         [_y updateInterval:[_x min] and:[_x max]];
      }
   }
   else if (maxDom(_b)==0) {     // b is FALSE
      if ([_x bound] || [_x min] == [_x max] )
         [self addConstraint: [CPFactory floatNEqualc:_y to:[_x min]] engine:[_b engine]];
      else if ([_y bound] || [_y min] == [_y max])
         [self addConstraint: [CPFactory floatNEqualc:_y to:[_x min]] engine:[_b engine]];
   }else {                        // b is unknown
      if (([_x bound] && [_y bound]) || ([_x min] == [_x max] &&  [_y min] == [_y max]))
         [_b bind: [_x min] == [_y min]];
      else if ([_x max] < [_y min] || [_y max] < [_x min])
         [_b bind:NO];
   }
   if(([_b bound] && [_x bound] && [_y bound])  || ([_b bound] && ([_x min] == [_x max] &&  [_y min] == [_y max]))) assignTRInt(&_active, 0, _trail);
}
-(NSString*)description
{
   return [NSMutableString stringWithFormat:@"<CPFloatReifyEqual:%02d %@ <=> (%@ == %@)>",_name,_b,_x,_y];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,_b, nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_y,_b,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_x bound] +  ![_y bound] + ![_b bound];
}
@end

@implementation CPFloatReifyAssignc{
   ORInt _precision;
   ORInt _rounding;
}
-(id) initCPReify:(CPIntVar*)b when:(CPFloatVarI*)x set:(ORFloat)c
{
   self = [super initCPCoreConstraint:[x engine]];
   _b = b;
   _x = x;
   _c = c;
   _precision = 1;
   _rounding = FE_TONEAREST;
   return self;
}
-(void) post
{
   [self propagate];
   if(![_b bound])
      [_b whenBindPropagate:self];
   if(![_x bound])
      [_x whenChangeBoundsPropagate:self];
}
-(void)propagate
{
   if([_b bound]){
      if(minDom(_b)){
         assignTRInt(&_active, NO, _trail);
         [self addConstraint:[CPFactory floatAssignC:_x to:_c] engine:[_x engine]];
      }else{
         if ([_x bound]){
            if(is_eqf([_x min],_c)) failNow();
         }else{
            if(is_eqf([_x min],_c)){
               [_x updateMin:fp_next_float(_c)];
               assignTRInt(&_active, NO, _trail);
            }else if(is_eqf([_x max],_c)){
               [_x updateMax:fp_previous_float(_c)];
               assignTRInt(&_active, NO, _trail);
            }
         }
      }
   }else{
      if ([_x bound]) {
         [_b bind:is_eqf([_x min],_c)];
         assignTRInt(&_active, NO, _trail);
      }else{
         if([_x min] > _c || [_x max] < _c){
            [_b bind:NO];
            assignTRInt(&_active, NO, _trail);
         }
      }
   }
   if([_b bound] && [_x bound]) assignTRInt(&_active, 0, _trail);
}

-(NSString*)description
{
   return [NSMutableString stringWithFormat:@"<CPFloatReifyAssignC:%02d %@ <=> (%@ <- %16.16e)>",_name,_b,_x,_c];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_b, nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_b,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_x bound] +   ![_b bound];
}
@end

@implementation CPFloatReifyAssign{
   ORInt _precision;
   ORInt _rounding;
   float_interval _xi;
   float_interval _yi;
}
-(id) initCPReify:(CPIntVar*)b when:(CPFloatVarI*)x set:(CPFloatVarI*)y
{
   self = [super initCPCoreConstraint:[x engine]];
   _b = b;
   _x = x;
   _y = y;
   _xi = makeFloatInterval(x.min, x.max);
   _yi = makeFloatInterval(y.min, y.max);
   _precision = 1;
   _rounding = FE_TONEAREST;
   return self;
}
-(void) post
{
   [self propagate];
   if(![_b bound])
      [_b whenBindPropagate:self];
   if(![_x bound])
      [_x whenChangeBoundsPropagate:self];
   if(![_y bound])
      [_y whenChangeBoundsPropagate:self];
    [_b whenBindDo:^{
   //       if b is true and x and y don't have 0 in their domain equality is same than assignnation
       if( minDom(_b) && isPositiveOrNegative(_x) && isPositiveOrNegative(_y)){
         [_x setCenter:_y];
         [[[_x engine] mergedVar] notifyWith:_x andId:_y isStatic:YES];
         [[_x engine] incNbRewrites:1];
       }
      } onBehalf:self];
}
-(void)propagate
{
   if([_b bound]){
      if(minDom(_b)){
         assignTRInt(&_active, NO, _trail);
         [self addConstraint:[CPFactory floatAssign:_x to:_y] engine:[_x engine]];
      }else{
         if ([_x bound]) {
            if([_y bound]){
               if (is_eqf([_x min],[_y min]))
                  failNow();
            }else{
                  if(is_eqf([_x min],[_y min])){
                     [_y updateMin:fp_next_float([_y min])];
                     assignTRInt(&_active, NO, _trail);
                  }
                  if(is_eqf([_x min],[_y max])) {
                     [_y updateMax:fp_previous_float([_y max])];
                     assignTRInt(&_active, NO, _trail);
                  }
               }
         }else  if([_y bound]){
            if(is_eqf([_x min],[_y min])){
               [_x updateMin:fp_next_float([_x min])];
               assignTRInt(&_active, NO, _trail);
            }
            if(is_eqf([_x max],[_y min])){
               [_x updateMax:fp_previous_float([_x max])];
               assignTRInt(&_active, NO, _trail);
            }
         }
      }
   }else{
      if ([_x bound] && [_y bound])
         [_b bind:is_eqf([_x min], [_y min])];
   }
   if([_b bound] && [_x bound] && [_y bound]) assignTRInt(&_active, 0, _trail);
}

-(NSString*)description
{
   return [NSMutableString stringWithFormat:@"<CPFloatReifyAssign:%02d %@ <=> (%@ <- %@)>",_name,_b,_x,_y];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,_b, nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_y,_b,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_x bound] +  ![_y bound] + ![_b bound];
}
@end

@implementation CPFloatReifyGThen
-(id) initCPReifyGThen:(CPIntVar*)b when:(CPFloatVarI*)x gti:(CPFloatVarI*)y
{
   self = [super initCPCoreConstraint:[x engine]];
   _b = b;
   _x = x;
   _y = y;
   return self;
}
-(void) post
{
   [self propagate];
   if(![_b bound])
      [_b whenBindPropagate:self];
   if(![_x bound])
      [_x whenChangeBoundsPropagate:self];
   if(![_y bound])
      [_y whenChangeBoundsPropagate:self];
}
-(void)propagate
{
   if (bound(_b)) {
      if (minDom(_b)) {
         if(canPrecede(_x,_y))
            failNow();
         if(isIntersectingWith(_x,_y)){
            if([_x min] <= [_y min]){
               ORFloat pmin = fp_next_float([_y min]);
               [_x updateMin:pmin];
            }
            if([_x max] <= [_y max]){
               ORFloat nmax = fp_previous_float([_x max]);
               [_y updateMax:nmax];
            }
         }
      } else {
         if ([_x bound]) { // c <= y
            [_y updateMin:[_x min]];
         } else {         // x <= y
            [_y updateMin:[_x min]];
            [_x updateMax:[_y max]];
         }
      }
   } else {
      if ([_y max] < [_x min]) {
         assignTRInt(&_active, NO, _trail);
         bindDom(_b,YES);
      } else if ([_x max] <= [_y min]){
         assignTRInt(&_active, NO, _trail);
         bindDom(_b,NO);
      }
   }
}
-(NSString*)description
{
   return [NSMutableString stringWithFormat:@"<CPFloatReifyGEqual:%02d %@ <=> (%@ > %@)>",_name,_b,_x,_y];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,_b, nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_y,_b,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_x bound] + ![_b bound];
}
@end


@implementation CPFloatReifyGEqual
-(id) initCPReifyGEqual:(CPIntVar*)b when:(CPFloatVarI*)x geqi:(CPFloatVarI*)y
{
   self = [super initCPCoreConstraint:[x engine]];
   _b = b;
   _x = x;
   _y = y;
   return self;
}
-(void) post
{
   [self propagate];
   if(![_b bound])
      [_b whenBindPropagate:self];
   if(![_x bound])
      [_x whenChangeBoundsPropagate:self];
   if(![_y bound])
      [_y whenChangeBoundsPropagate:self];
}
-(void)propagate
{
   if (bound(_b)) {
      if (minDom(_b)) {
         [_y updateMax:[_x max]];
         [_x updateMin:[_y min]];
      } else {
         [_y updateMax:fp_next_float([_x max])];
         [_x updateMin:fp_previous_float([_y min])];
      }
   } else {
      if ([_y max] <= [_x min]) {
         assignTRInt(&_active, NO, _trail);
         bindDom(_b,YES);
      } else if ([_x min] < [_y max]) {
         assignTRInt(&_active, NO, _trail);
         bindDom(_b,NO);
      }
   }
}
-(NSString*)description
{
   return [NSMutableString stringWithFormat:@"<CPFloatReifyGEqual:%02d %@ <=> (%@ >= %@)>",_name,_b,_x,_y];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,_b, nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_y,_b,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_x bound] + ![_b bound];
}
@end


@implementation CPFloatReifyLEqual
-(id) initCPReifyLEqual:(CPIntVar*)b when:(CPFloatVarI*)x leqi:(CPFloatVarI*)y
{
   self = [super initCPCoreConstraint:[x engine]];
   _b = b;
   _x = x;
   _y = y;
   return self;
}
-(void) post
{
   [self propagate];
   if(![_b bound])
      [_b whenBindPropagate:self];
   if(![_x bound])
      [_x whenChangeBoundsPropagate:self];
   if(![_y bound])
      [_y whenChangeBoundsPropagate:self];
}
-(void)propagate
{
   if (bound(_b)) {
      if (minDom(_b)) {
         [_x updateMax:[_y max]];
         [_y updateMin:[_x min]];
      } else {
         [_x updateMin:fp_next_float([_y min])];
         [_y updateMax:fp_previous_float([_x max])];
      }
   } else {
      if ([_x max] <= [_y min]) {
         assignTRInt(&_active, NO, _trail);
         bindDom(_b,YES);
      } else if ([_x min] > [_y max]) {
         assignTRInt(&_active, NO, _trail);
         bindDom(_b,NO);
      }
   }
}
-(NSString*)description
{
   return [NSMutableString stringWithFormat:@"<CPFloatReifyLEqual:%02d %@ <=> (%@ <= %@)>",_name,_b,_x,_y];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,_b, nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_y,_b,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_y bound] + ![_b bound];
}
@end


@implementation CPFloatReifyLThen
-(id) initCPReifyLThen:(CPIntVar*)b when:(CPFloatVarI*)x lti:(CPFloatVarI*)y
{
   self = [super initCPCoreConstraint:[x engine]];
   _b = b;
   _x = x;
   _y = y;
   return self;
}
-(void) post
{
   [self propagate];
   if(![_b bound])
      [_b whenBindPropagate:self];
   if(![_x bound])
      [_x whenChangeBoundsPropagate:self];
   if(![_y bound])
      [_y whenChangeBoundsPropagate:self];
}
-(void)propagate
{
   if (bound(_b)) {
      if (minDom(_b)) {
         if(canFollow(_x,_y))
            failNow();
         if(isIntersectingWith(_x,_y)){
            if([_x min] >= [_y min]){
               ORFloat nmin = fp_next_float([_x min]);
               [_y updateMin:nmin];
            }
            if([_x max] >= [_y max]){
               ORFloat pmax = fp_previous_float([_y max]);
               [_x updateMax:pmax];
            }
         }
      } else {
         [_y updateMax:[_x max]];
         [_x updateMin:[_y min]];
      }
   } else {
      if ([_x max] < [_y min]) {
         assignTRInt(&_active, NO, _trail);
         bindDom(_b,YES);
      } else if ([_x min] >= [_y max]) {
         assignTRInt(&_active, NO, _trail);
         bindDom(_b,NO);
      }
   }
   if([_b bound] && [_x bound] && [_y bound])
      assignTRInt(&_active, NO, _trail);
}
-(NSString*)description
{
   return [NSMutableString stringWithFormat:@"<CPFloatReifyLThen:%02d %@ <=> (%@ < %@)>",_name,_b,_x,_y];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,_b, nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_y,_b,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_y bound] + ![_b bound];
}
@end




@implementation CPFloatReifyEqualc
-(id) initCPReifyEqualc:(CPIntVar*)b when:(CPFloatVarI*)x eqi:(ORFloat)c
{
   self = [super initCPCoreConstraint:[x engine]];
   _b = b;
   _x = x;
   _c = c;
   return self;
}
-(void) post
{
   if ([_b bound]) {
      if ([_b min] == true)
         [_x bind:_c];
      else
         [self addConstraint: [CPFactory floatNEqualc:_x to:_c] engine:[_b engine]];    // Rewrite as x!=c  (addInternal can throw)
   }
   else if ([_x bound])
      [_b bind:[_x min] == _c];
   else if (![_x member:_c])
      [_b bind:false];
   else {
      [_b setBindTrigger: ^ {
         if ([_b min] == true)
            [_x bind:_c];
          else
            [self addConstraint: [CPFactory floatNEqualc:_x to:_c] engine:[_b engine]];     // Rewrite as x!=c  (addInternal can throw)
      } onBehalf:self];
      [_x whenChangeBoundsDo: ^ {
         if ([_x bound])
            [_b bind:[_x min] == _c];
         else if (![_x member:_c])
            [_b remove:true];
      } onBehalf:self];
      [_x whenBindDo: ^ {
         [_b bind:[_x min] == _c];
      } onBehalf:self];
   }
}
-(NSString*)description
{
   return [NSMutableString stringWithFormat:@"<CPFloatReifyEqual:%02d %@ <=> (%@ == %16.16e)>",_name,_b,_x,_c];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_b, nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_b,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_b bound];
}
@end

@implementation CPFloatReifyLEqualc
-(id) initCPReifyLEqualc:(CPIntVar*)b when:(CPFloatVarI*)x leqi:(ORFloat)c
{
   self = [super initCPCoreConstraint:[x engine]];
   _b = b;
   _x = x;
   _c = c;
   return self;
}
-(void) post
{
   [self propagate];
   if(![_b bound])
      [_b whenBindPropagate:self];
   if(![_x bound])
      [_x whenChangeBoundsPropagate:self];
}
-(void) propagate
{
   if (bound(_b)) {
      assignTRInt(&_active, NO, _trail);
      if (minDom(_b))
         [_x updateMax:_c];
      else
         [_x updateMin:fp_next_float(_c)];
   } else {
      if ([_x min] > _c) {
         assignTRInt(&_active, NO, _trail);
         bindDom(_b, NO);
      } else if ([_x max] <= _c) {
         assignTRInt(&_active, NO, _trail);
         bindDom(_b, YES);
      }
   }
}
-(NSString*)description
{
   return [NSMutableString stringWithFormat:@"<CPFloatReifyLEqualc:%02d %@ <=> (%@ <= %16.16e)>",_name,_b,_x,_c];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_b, nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_b,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_b bound];
}
@end


@implementation CPFloatReifyLThenc
-(id) initCPReifyLThenc:(CPIntVar*)b when:(CPFloatVarI*)x lti:(ORFloat)c
{
   self = [super initCPCoreConstraint:[x engine]];
   _b = b;
   _x = x;
   _c = c;
   return self;
}
-(void) post
{
   [self propagate];
   if(![_b bound])
      [_b whenBindPropagate:self];
   if(![_x bound])
      [_x whenChangeBoundsPropagate:self];
}
-(void) propagate
{
   if (bound(_b)) {
      if (minDom(_b))
         [_x updateMax:fp_previous_float(_c)];
      else
         [_x updateMin:_c];
      assignTRInt(&_active, NO, _trail);
   } else {
      if ([_x min] > _c) {
         assignTRInt(&_active, NO, _trail);
         bindDom(_b, NO);
      } else if ([_x max] <= _c) {
         assignTRInt(&_active, NO, _trail);
         bindDom(_b, YES);
      }
   }
}
-(NSString*)description
{
   return [NSMutableString stringWithFormat:@"<CPFloatReifyLThenc:%02d %@ <=> (%@ < %16.16e)>",_name,_b,_x,_c];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_b, nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_b,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_b bound];
}
@end


@implementation CPFloatReifyNotEqualc
-(id) initCPReifyNotEqualc:(CPIntVar*)b when:(CPFloatVarI*)x neqi:(ORFloat)c
{
   self = [super initCPCoreConstraint:[x engine]];
   _b = b;
   _x = x;
   _c = c;
   return self;
}
-(void) post
{
   if ([_b bound]) {
      if ([_b min] == true)
         [self addConstraint: [CPFactory floatNEqualc:_x to:_c] engine:[_b engine]];     // Rewrite as x!=c  (addInternal can throw)
      else
         [_x bind:_c];
   }
   else if ([_x bound])
      [_b bind:[_x min] != _c];
   else if (![_x member:_c])
      [_b remove:false];
   else {
      [_b whenBindDo: ^void {
         if ([_b min]==true)
            [self addConstraint: [CPFactory floatNEqualc:_x to:_c] engine:[_b engine]];     // Rewrite as x!=c  (addInternal can throw)
         else
            [_x bind:_c];
      } onBehalf:self];
      [_x whenChangeBoundsDo:^{
         if ([_x bound])
            [_b bind:[_x min] != _c];
         else if (![_x member:_c])
            [_b remove:false];
      } onBehalf:self];
      [_x whenBindDo: ^(void) { [_b bind:[_x min] != _c];} onBehalf:self];
   }
}
-(NSString*)description
{
   return [NSMutableString stringWithFormat:@"<CPFloatReifyNotEqualc:%02d %@ <=> (%@ != %16.16e)>",_name,_b,_x,_c];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_b, nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_b,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_b bound];
}
@end

@implementation CPFloatReifyGEqualc
-(id) initCPReifyGEqualc:(CPIntVar*)b when:(CPFloatVarI*)x geqi:(ORFloat)c
{
   self = [super initCPCoreConstraint:[x engine]];
   _b = b;
   _x = x;
   _c = c;
   return self;
}
-(void) post  // b <=>  x >= c
{
   [self propagate];
   if(![_b bound])
      [_b whenBindPropagate:self];
   if(![_x bound])
      [_x whenChangeBoundsPropagate:self];
}
-(void) propagate
{
   if (bound(_b)) {
      assignTRInt(&_active, NO, _trail);
      if (minDom(_b))
         [_x updateMin:_c];
      else
         [_x updateMax:fp_previous_float(_c)];
   } else {
      if ([_x min] >= _c) {
         assignTRInt(&_active, NO, _trail);
         bindDom(_b,YES);
      } else if ([_x max] < _c) {
         assignTRInt(&_active, NO, _trail);
         bindDom(_b,NO);
      }
   }
}
-(NSString*)description
{
   return [NSMutableString stringWithFormat:@"<CPFloatReifyGEqualc:%02d %@ <=> (%@ >= %16.16e)>",_name,_b,_x,_c];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_b, nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_b,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_b bound];
}
@end


@implementation CPFloatReifyGThenc
-(id) initCPReifyGThenc:(CPIntVar*)b when:(CPFloatVarI*)x gti:(ORFloat)c
{
   self = [super initCPCoreConstraint:[x engine]];
   _b = b;
   _x = x;
   _c = c;
   return self;
}
-(void) post  // b <=>  x > c
{
   [self propagate];
   if(![_b bound])
      [_b whenBindPropagate:self];
   if(![_x bound])
      [_x whenChangeBoundsPropagate:self];
}
-(void) propagate
{
   if (bound(_b)) {
      assignTRInt(&_active, NO, _trail);
      if (minDom(_b))
         [_x updateMin:fp_next_float(_c)];
      else
         [_x updateMax:_c];
   } else {
      if ([_x min] > _c) {
         assignTRInt(&_active, NO, _trail);
         bindDom(_b,YES);
      } else if ([_x max] <= _c) {
         assignTRInt(&_active, NO, _trail);
         bindDom(_b,NO);
      }
   }
}
-(NSString*)description
{
   return [NSMutableString stringWithFormat:@"<CPFloatReifyGEqualc:%02d %@ <=> (%@ > %16.16e)>",_name,_b,_x,_c];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_b, nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_b,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_b bound];
}
@end

@implementation CPFloatSquare{
   int _precision;
   int _rounding;
   float_interval _xi;
   float_interval _resi;
}
-(id) init:(CPFloatVarI*)res eq:(CPFloatVarI*)x //res = x^2
{
   self = [super initCPCoreConstraint: [x engine]];
   _x = x;
   _res = res;
   _xi = makeFloatInterval(x.min, x.max);
   _resi = makeFloatInterval(res.min, res.max);
   _precision = 1;
   _rounding = FE_TONEAREST;
   return self;
}
-(void) post
{
   [self propagate];
   if(![_x bound])  [_x whenChangeBoundsPropagate:self];
   if(![_res bound])  [_res whenChangeBoundsPropagate:self];
}
-(void) propagate
{
   updateFloatInterval(&_xi,_x);
   updateFloatInterval(&_resi,_res);
   intersectionInterval inter;
   float_interval resTmp = makeFloatInterval(_resi.inf, _resi.sup);
   fpi_xxf(_precision, _rounding, &resTmp, &_xi);
   inter = intersection(_res, _resi, resTmp, 0.0f);
   if(inter.changed)
      [_res updateInterval:inter.result.inf and:inter.result.sup];
   
   updateFloatInterval(&_xi,_x);
   float_interval xTmp = makeFloatInterval(_xi.inf, _xi.sup);
   fpi_xxf_inv(_precision,_rounding, &xTmp, &_resi);
   inter = intersection(_x, _xi, xTmp, 0.0f);
   if(inter.changed)
      [_x updateInterval:inter.result.inf and:inter.result.sup];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_res,nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_res,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_res bound];
}
-(NSString*)description
{
   return [NSString stringWithFormat:@"<%@ == (%@^2)>",_res,_x];
}
- (id<CPVar>)result
{
   return _res;
}
@end

@implementation CPFloatAbs{
   int _precision;
   int _rounding;
   float_interval _xi;
   float_interval _resi;
}
-(id) init:(CPFloatVarI*)res eq:(CPFloatVarI*)x //res = |x|
{
   self = [super initCPCoreConstraint: [x engine]];
   _x = x;
   _res = res;
   _xi = makeFloatInterval(x.min, x.max);
   _resi = makeFloatInterval(res.min, res.max);
   _precision = 1;
   _rounding = FE_TONEAREST;
   return self;
}
-(void) post
{
   [self propagate];
   if(![_x bound])  [_x whenChangeBoundsPropagate:self];
   if(![_res bound])  [_res whenChangeBoundsPropagate:self];
}
-(void) propagate
{
   if([_x bound]){
      if([_res bound]){
         if(([_res value] !=  -[_x value]) && ([_res value] != [_x value])) failNow();
         assignTRInt(&_active, NO, _trail);
      }else{
         [_res bind:([_x value] >= 0) ? [_x value] : -[_x value]];
         assignTRInt(&_active, NO, _trail);
      }
   }else if([_res bound]){
       if([_x member:-[_res value]]){
         if([_x member:[_res value]])
            [_x updateInterval:-[_res value] and:[_res value]];
         else
            [_x bind:-[_res value]];
      }else if([_x member:[_res value]])
         [_x bind:[_res value]];
      else
         failNow();
   }else {
      updateFloatInterval(&_xi,_x);
      updateFloatInterval(&_resi,_res);
      intersectionInterval inter;
      float_interval resTmp = makeFloatInterval(_resi.inf, _resi.sup);
      fpi_fabsf(_precision, _rounding, &resTmp, &_xi);
      inter = intersection(_res, _resi, resTmp, 0.0f);
      if(inter.changed)
         [_res updateInterval:inter.result.inf and:inter.result.sup];
      
      updateFloatInterval(&_xi,_x);
      float_interval xTmp = makeFloatInterval(_xi.inf, _xi.sup);
      fpi_fabs_invf(_precision,_rounding, &xTmp, &_resi);
      inter = intersection(_x, _xi, xTmp, 0.0f);
      if(inter.changed)
         [_x updateInterval:inter.result.inf and:inter.result.sup];
   }
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_res,nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_res,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_res bound];
}
-(NSString*)description
{
   return [NSString stringWithFormat:@"<%@ == |%@|>",_res,_x];
}
- (id<CPVar>)result
{
   return _res;
}
@end

@implementation CPFloatSqrt{
   int _precision;
   int _rounding;
   float_interval _xi;
   float_interval _resi;
}
-(id) init:(CPFloatVarI*)res eq:(CPFloatVarI*)x //res = |x|
{
   self = [super initCPCoreConstraint: [x engine]];
   _x = x;
   _res = res;
   _xi = makeFloatInterval(x.min, x.max);
   _resi = makeFloatInterval(res.min, res.max);
   _precision = 1;
   _rounding = FE_TONEAREST;
   return self;
}
-(void) post
{
   [self propagate];
   if(![_x bound])  [_x whenChangeBoundsPropagate:self];
   if(![_res bound])  [_res whenChangeBoundsPropagate:self];
}
-(void) propagate
{
   updateFloatInterval(&_xi,_x);
   updateFloatInterval(&_resi,_res);
   intersectionInterval inter;
   float_interval resTmp = makeFloatInterval(_resi.inf, _resi.sup);
   fpi_sqrtf(_precision,_rounding, &resTmp, &_xi);
   inter = intersection(_res, _resi, resTmp, 0.0f);
   if(inter.changed)
      [_res updateInterval:inter.result.inf and:inter.result.sup];
   
   updateFloatInterval(&_xi,_x);
   float_interval xTmp = makeFloatInterval(_xi.inf, _xi.sup);
   fpi_sqrtf_inv(_precision,_rounding, &xTmp, &_resi);
   inter = intersection(_x, _xi, xTmp, 0.0f);
   if(inter.changed)
      [_x updateInterval:inter.result.inf and:inter.result.sup];
   if([_res bound] && [_x bound])
      assignTRInt(&_active, NO, _trail);
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_res,nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_res,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_res bound];
}
-(NSString*)description
{
   return [NSString stringWithFormat:@"<%@ == sqrt(%@)>",_res,_x];
}
- (id<CPVar>)result
{
   return _res;
}
@end

@implementation CPFloatIsPositive
-(id) init:(CPFloatVarI*) x isPositive:(CPIntVarI*) b
{
   self = [super initCPCoreConstraint: [x engine]];
   _x = x;
   _b = b;
   return self;
}
-(void) post
{
   [self propagate];
   if(![_b bound])
      [_b whenBindPropagate:self];
   if(![_x bound])
      [_x whenChangeBoundsPropagate:self];
}
-(void) propagate
{
   if (bound(_b)) {
      assignTRInt(&_active, NO, _trail);
      if (minDom(_b))
         [_x updateMin:+0.0f];
      else
         [_x updateMax:-0.0f];
   } else {
      if (is_positivef([_x min])) {
         assignTRInt(&_active, NO, _trail);
         bindDom(_b,YES);
      } else if (is_negativef([_x max])) {
         assignTRInt(&_active, NO, _trail);
         bindDom(_b,NO);
      }
   }
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_b,nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_b,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_b bound];
}
-(NSString*)description
{
   return [NSString stringWithFormat:@"<%@ <=> isPositive(%@)>",_b,_x];
}
@end

@implementation CPFloatIsZero
-(id) init:(CPFloatVarI*) x isZero:(CPIntVarI*) b
{
   self = [super initCPCoreConstraint: [x engine]];
   _x = x;
   _b = b;
   return self;
}
-(void) post
{
   [self propagate];
   if(![_b bound])
      [_b whenBindPropagate:self];
   if(![_x bound])
      [_x whenChangeBoundsPropagate:self];
}
-(void) propagate
{
   if (bound(_b)) {
      assignTRInt(&_active, NO, _trail);
      if (minDom(_b))
         [_x updateInterval:-0.0f and:+0.0f];
      else
         [self addConstraint:[CPFactory floatNEqualc:_x to:0.0f] engine:[_x engine]];
   } else {
      if([_x bound]){
         bindDom(_b, [_x min] == 0.0f);
         assignTRInt(&_active, NO, _trail);
      }else if ([_x min] == 0.0f && [_x max] == 0.0f) {
         assignTRInt(&_active, NO, _trail);
         bindDom(_b,YES);
      } else if ([_x min] > 0.0f && [_x max] < 0.0f) {
         assignTRInt(&_active, NO, _trail);
         bindDom(_b,NO);
      }
   }
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_b,nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_b,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_b bound];
}
-(NSString*)description
{
   return [NSString stringWithFormat:@"<%@ <=> isZero(%@)>",_b,_x];
}
@end

@implementation CPFloatIsInfinite
-(id) init:(CPFloatVarI*) x isInfinite:(CPIntVarI*) b
{
   self = [super initCPCoreConstraint: [x engine]];
   _x = x;
   _b = b;
   return self;
}
-(void) post
{
   [self propagate];
   if(![_b bound])
      [_b whenBindPropagate:self];
   if(![_x bound])
      [_x whenChangeBoundsPropagate:self];
}
-(void) propagate
{
   if (bound(_b)) {
      assignTRInt(&_active, NO, _trail);
      if (minDom(_b)){
         if([_x max] < +INFINITY) [_x bind:-INFINITY];
         if([_x min] > -INFINITY) [_x bind:+INFINITY];
      }else
         [_x updateInterval:fp_next_float(-INFINITY) and:fp_previous_float(+INFINITY)];
   } else {
      if ([_x max] == -INFINITY || [_x min] == +INFINITY) {
         assignTRInt(&_active, NO, _trail);
         bindDom(_b,YES);
      } else if ([_x min] > -INFINITY && [_x max] < +INFINITY) {
         assignTRInt(&_active, NO, _trail);
         bindDom(_b,NO);
      }
   }
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_b,nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_b,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_b bound];
}
-(NSString*)description
{
   return [NSString stringWithFormat:@"<%@ <=> isInfinite(%@)>",_b,_x];
}
@end

@implementation CPFloatIsNormal
-(id) init:(CPFloatVarI*)x isNormal:(CPIntVarI*)b
{
   self = [super initCPCoreConstraint: [x engine]];
   _x = x;
   _b = b;
   return self;
}
-(void) post
{
   [self propagate];
   if(![_b bound])
      [_b whenBindPropagate:self];
   if(![_x bound])
      [_x whenChangeBoundsPropagate:self];
}
-(void) propagate
{
   if (bound(_b)) {
      if (minDom(_b)){
         if([_x bound] && is_infinityf([_x min]))
            failNow();
         
         if([_x min] >= -maxdenormalf() && [_x min] <= maxdenormalf()){
            [_x updateMin:minnormalf()];
            assignTRInt(&_active, NO, _trail);
         }else if(is_infinityf([_x min]))
            [_x updateMin:fp_next_float(-infinityf())];
         
         if([_x max] >= -maxdenormalf() && [_x max] <= maxdenormalf()){
            [_x updateMax:-minnormalf()];
            assignTRInt(&_active, NO, _trail);
         }else if(is_infinityf([_x max]))
            [_x updateMax:fp_previous_float(infinityf())];
         
      }else{
         [_x updateInterval:-maxdenormalf() and:maxdenormalf()];
         assignTRInt(&_active, NO, _trail);
      }
   }else{
      if([_x min] >= -maxdenormalf() && [_x max] <= maxdenormalf()){
         [_b bind:0];
         assignTRInt(&_active, NO, _trail);
      }else if(([_x max] <= -minnormalf() || [_x min] >= minnormalf()) && !is_infinityf([_x max]) && !is_infinityf([_x min])){
         [_b bind:1];
         assignTRInt(&_active, NO, _trail);
      }
   }
}

-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_b,nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_b,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_b bound];
}
-(NSString*)description
{
   return [NSString stringWithFormat:@"<%@ <=> isNormal(%@)>",_b,_x];
}
@end

@implementation CPFloatIsSubnormal
-(id) init:(CPFloatVarI*)x isSubnormal:(CPIntVarI*)b
{
   self = [super initCPCoreConstraint: [x engine]];
   _x = x;
   _b = b;
   return self;
}
-(void) post
{
   [self propagate];
   if(![_b bound])
      [_b whenBindPropagate:self];
   if(![_x bound])
      [_x whenChangeBoundsPropagate:self];
}
-(void) propagate
{
   if (bound(_b)) {
      if (minDom(_b)){
         [_x updateInterval:-maxdenormalf() and:maxdenormalf()];
         [self addConstraint:[CPFactory floatNEqualc:_x to:0.0f] engine:[_x engine]];
         assignTRInt(&_active, NO, _trail);
      }else{
         [self addConstraint:[CPFactory floatNEqualc:_x to:0.0f] engine:[_x engine]];
         if([_x min] >= -maxdenormalf() && [_x min] <= maxdenormalf()){
            [_x updateMin:minnormalf()];
            assignTRInt(&_active, NO, _trail);
         }
         if([_x max] >= -maxdenormalf() && [_x max] <= maxdenormalf()){
            [_x updateMax:-minnormalf()];
            assignTRInt(&_active, NO, _trail);
         }
      }
   }else{
      if(([_x min] >= -maxdenormalf() && [_x max] <= -mindenormalf()) || ([_x min] >= mindenormalf() && [_x max] <= maxdenormalf())){
         [_b bind:1];
         assignTRInt(&_active, NO, _trail);
      }else if([_x max] <= -minnormalf() || [_x min] >= minnormalf() || ([_x min] == 0.0f && [_x min] == 0.0f)){
         [_b bind:0];
         assignTRInt(&_active, NO, _trail);
      }
   }
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_b,nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_b,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_b bound];
}
-(NSString*)description
{
   return [NSString stringWithFormat:@"<%@ <=> isSubnormal(%@)>",_b,_x];
}
@end
