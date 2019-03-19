/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import "CPDoubleConstraint.h"
#import "CPDoubleVarI.h"
#import "CPFloatVarI.h"
#import "ORConstraintI.h"
#import <fenv.h>

#define PERCENT 5.0


//unary minus constraint
@implementation CPDoubleUnaryMinus{
int _precision;
int _rounding;
double_interval _xi;
double_interval _yi;
}
-(id) init:(CPDoubleVarI*)x eqm:(CPDoubleVarI*)y
{
   self = [super initCPCoreConstraint: [x engine]];
   _x = x;
   _y = y;
   _xi = makeDoubleInterval(x.min, x.max);
   _yi = makeDoubleInterval(y.min, y.max);
   _precision = 1;
   _rounding = FE_TONEAREST;
   return self;
}
-(void) post
{
   [self propagate];
   if(![_x bound])  [_x whenChangeBoundsPropagate:self];
   if(![_y bound])  [_y whenChangeBoundsPropagate:self];
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
      updateDoubleInterval(&_xi,_x);
      updateDoubleInterval(&_yi,_y);
      intersectionIntervalD inter;
      double_interval yTmp = makeDoubleInterval(_yi.inf, _yi.sup);
      fpi_minusd(_precision,_rounding, &yTmp, &_xi);
      inter = intersectionD(_y,_yi, yTmp, 0.0f);
      if(inter.changed)
         [_y updateInterval:inter.result.inf and:inter.result.sup];
      
      updateDoubleInterval(&_yi,_y);
      double_interval xTmp = makeDoubleInterval(_xi.inf, _xi.sup);
      fpi_minusd(_precision,_rounding, &xTmp, &_yi);
      inter = intersectionD(_x,_xi, xTmp, 0.0f);
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
@end


@implementation CPDoubleCast {
   int _precision;
   int _rounding;
   double_interval _resi;
   float_interval _initiali;
}
-(id) init:(CPDoubleVarI*)res equals:(CPFloatVarI*)initial
{
   self = [super initCPCoreConstraint: [res engine]];
   _res = res;
   _initial = initial;
   _resi = makeDoubleInterval(_res.min, _res.max);
   _initiali = makeFloatInterval(_initial.min, _initial.max);
   _precision = 1;
   _rounding = FE_TONEAREST;
   return self;
}
-(void) post
{
   [self propagate];
   if(![_res bound])        [_res whenChangeBoundsPropagate:self];
   if(![_initial bound])    [_initial whenChangeBoundsPropagate:self];
}
-(void) propagate
{
   if([_res bound]){
      if(is_eq([_res min],-0.0) && is_eq([_res max],+0.0))
         [_initial updateInterval:[_res min] and:[_res max]];
      else
         [_initial bind:[_res value]];
      assignTRInt(&_active, NO, _trail);
      return;
   }
   if(isDisjointWithDV([_res min],[_res max],[_initial min],[_initial max])){
      failNow();
   }else {
      updateDoubleInterval(&_resi,_res);
      updateFloatInterval(&_initiali,_initial);
      intersectionIntervalD inter;
      double_interval resTmp = makeDoubleInterval(_resi.inf, _resi.sup);
      fpi_ftod(_precision, _rounding, &resTmp, &_initiali);
      inter = intersectionD(_res, _resi, resTmp, 0.0f);
      if(inter.changed)
         [_res updateInterval:inter.result.inf and:inter.result.sup];
      
      
      updateDoubleInterval(&_resi,_res);
      float_interval initialTmp = makeFloatInterval(_initiali.inf, _initiali.sup);
      intersectionInterval inter2;
      fpi_ftod_inv(_precision, _rounding, &initialTmp,&_resi);
      inter2 = intersection(_initial, _initiali, initialTmp, 0.0f);
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
@end


@implementation CPDoubleEqual
-(id) init:(CPDoubleVarI*)x equals:(CPDoubleVarI*)y
{
   self = [super initCPCoreConstraint: [x engine]];
   _x = x;
   _y = y;
   return self;
}
-(void) post
{
   [self propagate];
   if(![_x bound])  [_x whenChangeBoundsPropagate:self];
   if(![_y bound])  [_y whenChangeBoundsPropagate:self];
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
   if(isDisjointWithD(_x,_y)){
      failNow();
   }else{
      ORDouble min = maxDbl([_x min], [_y min]);
      ORDouble max = minDbl([_x max], [_y max]);
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

@implementation CPDoubleEqualc
-(id) init:(CPDoubleVarI*)x and:(ORDouble)c
{
   self = [super initCPCoreConstraint: [x engine]];
   _x = x;
   _c = c;
   return self;
   
}
-(void) post
{
   if(_c == 0.)
      [_x updateInterval:-0.0 and:+0.0];
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

@implementation CPDoubleAssign{
   int _precision;
   int _rounding;
   double_interval _xi;
   double_interval _yi;
}
-(id) init:(CPDoubleVarI*)x set:(CPDoubleVarI*)y
{
   self = [super initCPCoreConstraint: [x engine]];
   _x = x;
   _y = y;
   _xi = makeDoubleInterval(x.min, x.max);
   _yi = makeDoubleInterval(y.min, y.max);
   _precision = 1;
   _rounding = FE_TONEAREST;
   return self;
}
-(void) post
{
   [self propagate];
   if(![_x bound])  [_x whenChangeBoundsPropagate:self];
   if(![_y bound])  [_y whenChangeBoundsPropagate:self];
}
-(void) propagate
{
   updateDoubleInterval(&_xi,_x);
   updateDoubleInterval(&_yi,_y);
   intersectionIntervalD inter;
   if(isDisjointWithD(_x,_y)){
      failNow();
   }else{
      double_interval xTmp = makeDoubleInterval(_xi.inf, _xi.sup);
      fpi_set(_precision, _rounding, &xTmp, &_yi);
      
      inter = intersectionD(_x, _xi, xTmp, 0.0);
      if(inter.changed)
         [_x updateInterval:inter.result.inf and:inter.result.sup];
      if ((_yi.inf != inter.result.inf) || (_yi.sup != inter.result.sup))
         [_y updateInterval:inter.result.inf and:inter.result.sup];
   }
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
   return [NSString stringWithFormat:@"<%@ = %@>",_x,_y];
}
@end

@implementation CPDoubleAssignC
-(id) init:(CPDoubleVarI*)x set:(ORDouble)c
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
@end


@implementation CPDoubleNEqual
-(id) init:(CPDoubleVarI*)x nequals:(CPDoubleVarI*)y
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
               [_y updateMin:fp_next_double([_y min])];
               assignTRInt(&_active, NO, _trail);
            }
            if([_x min] == [_y max]) {
               [_y updateMax:fp_previous_double([_y max])];
               assignTRInt(&_active, NO, _trail);
            }
            if([_x max] == [_y min]){
               [_y updateMin:fp_next_double([_y max])];
               assignTRInt(&_active, NO, _trail);
            }
            if([_x max] == [_y max]) {
               [_y updateMax:fp_previous_double([_y max])];
               assignTRInt(&_active, NO, _trail);
            }
         }
         return;
      }
   }else  if([_y bound]){
      if([_x min] == [_y min]){
         [_x updateMin:fp_next_double([_x min])];
         assignTRInt(&_active, NO, _trail);
      }
      if([_x min] == [_y max]) {
         [_x updateMin:fp_next_double([_x min])];
         assignTRInt(&_active, NO, _trail);
      }
      if([_x max] == [_y min]){
         [_x updateMax:fp_previous_double([_x max])];
         assignTRInt(&_active, NO, _trail);
      }
      if([_x max] == [_y max]) {
         [_x updateMax:fp_previous_double([_x max])];
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

@implementation CPDoubleNEqualc
-(id) init:(CPDoubleVarI*)x and:(ORDouble)c
{
   self = [super initCPCoreConstraint: [x engine]];
   _x = x;
   _c = c;
   return self;
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
         [_x updateMin:fp_next_double(_c)];
         assignTRInt(&_active, NO, _trail);
      }
      if([_x max] == _c){
         [_x updateMax:fp_previous_double(_c)];
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

@implementation CPDoubleLT
-(id) init:(CPDoubleVarI*)x lt:(CPDoubleVarI*)y
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
   if(canFollowD(_x,_y))
      failNow();
   if(isIntersectingWithD(_x,_y)){
      if([_x min] >= [_y min]){
         ORDouble nmin = fp_next_double([_x min]);
         [_y updateMin:nmin];
      }
      if([_x max] >= [_y max]){
         ORDouble pmax = fp_previous_double([_y max]);
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

@implementation CPDoubleGT
-(id) init:(CPDoubleVarI*)x gt:(CPDoubleVarI*)y
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
   if(canPrecedeD(_x,_y))
      failNow();
   if(isIntersectingWithD(_x,_y)){
      if([_x min] <= [_y min]){
         ORDouble pmin = fp_next_double([_y min]);
         [_x updateMin:pmin];
      }
      if([_x max] <= [_y max]){
         ORDouble nmax = fp_previous_double([_x max]);
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


@implementation CPDoubleLEQ
-(id) init:(CPDoubleVarI*)x leq:(CPDoubleVarI*)y
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
   if(canFollowD(_x,_y))
      failNow();
   if(isIntersectingWithD(_x,_y)){
      if([_x min] > [_y min]){
         ORDouble nmin = [_x min];
         [_y updateMin:nmin];
      }
      if([_x max] > [_y max]){
         ORDouble pmax = [_y max];
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

@implementation CPDoubleGEQ
-(id) init:(CPDoubleVarI*)x geq:(CPDoubleVarI*)y
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
   if(canPrecedeD(_x,_y))
      failNow();
   if(isIntersectingWithD(_x,_y)){
      if([_x min] < [_y min]){
         ORDouble pmin = [_y min];
         [_x updateMin:pmin];
      }
      if([_x max] < [_y max]){
         ORDouble nmax = [_x max];
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


@implementation CPDoubleTernaryAdd
-(id) init:(CPDoubleVarI*)z equals:(CPDoubleVarI*)x plus:(CPDoubleVarI*)y
{
   return [self init:z equals:x plus:y kbpercent:PERCENT];
}
-(id) init:(CPDoubleVarI*)z equals:(CPDoubleVarI*)x plus:(CPDoubleVarI*)y kbpercent:(ORDouble)p
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
   double_interval zTemp,yTemp,xTemp,z,x,y;
   intersectionIntervalD inter;
   z = makeDoubleInterval([_z min],[_z max]);
   x = makeDoubleInterval([_x min],[_x max]);
   y = makeDoubleInterval([_y min],[_y max]);
   do {
      changed = false;
      zTemp = z;
      fpi_addd(_precision, _rounding, &zTemp, &x, &y);
      inter = intersectionD(_z, z, zTemp,_percent);
      z = inter.result;
      changed |= inter.changed;
      
      xTemp = x;
      yTemp = y;
      fpi_add_invsub_bounds(_precision, _rounding, &xTemp, &yTemp, &z);
      inter = intersectionD(_x, x , xTemp,_percent);
      x = inter.result;
      changed |= inter.changed;
      
      inter = intersectionD(_y, y, yTemp,_percent);
      y = inter.result;
      changed |= inter.changed;
      
      xTemp = x;
      fpi_addxd_inv(_precision, _rounding, &xTemp, &z, &y);
      inter = intersectionD(_x, x , xTemp,_percent);
      x = inter.result;
      changed |= inter.changed;
      
      yTemp = y;
      fpi_addyd_inv(_precision, _rounding, &yTemp, &z, &x);
      inter = intersectionD(_y, y, yTemp,_percent);
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
-(id<CPVar>) varSubjectToAbsorption:(id<CPDoubleVar>)x
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
   return 0.0;
}
-(NSString*)description
{
   return [NSString stringWithFormat:@"<%@ = %@ + %@>",_z, _x, _y];
}
@end


@implementation CPDoubleTernarySub
-(id) init:(CPDoubleVarI*)z equals:(CPDoubleVarI*)x minus:(CPDoubleVarI*)y kbpercent:(ORDouble)p
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
-(id) init:(CPDoubleVarI*)z equals:(CPDoubleVarI*)x minus:(CPDoubleVarI*)y
{
   return [self init:z equals:x minus:y kbpercent:PERCENT];
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
   double_interval zTemp,yTemp,xTemp,z,x,y;
   intersectionIntervalD inter;
   z = makeDoubleInterval([_z min],[_z max]);
   x = makeDoubleInterval([_x min],[_x max]);
   y = makeDoubleInterval([_y min],[_y max]);
   do {
      changed = false;
      zTemp = z;
      fpi_subd(_precision, _rounding, &zTemp, &x, &y);
      inter = intersectionD(_z, z, zTemp,_percent);
      z = inter.result;
      changed |= inter.changed;
      
      xTemp = x;
      yTemp = y;
      fpi_sub_invsub_bounds(_precision, _rounding, &xTemp, &yTemp, &z);
      inter = intersectionD(_x, x , xTemp,_percent);
      x = inter.result;
      changed |= inter.changed;
      
      inter = intersectionD(_y, y, yTemp,_percent);
      y = inter.result;
      changed |= inter.changed;
      
      xTemp = x;
      fpi_subxd_inv(_precision, _rounding, &xTemp, &z, &y);
      inter = intersectionD(_x, x , xTemp,_percent);
      x = inter.result;
      changed |= inter.changed;
      
      yTemp = y;
      fpi_subyd_inv(_precision, _rounding, &yTemp, &z, &x);
      inter = intersectionD(_y, y, yTemp,_percent);
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
-(id<CPVar>) varSubjectToAbsorption:(id<CPDoubleVar>)x
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
   return 0.0;
}
-(NSString*)description
{
   return [NSString stringWithFormat:@"<%@ = %@ - %@>",_z, _x, _y];
}
@end

@implementation CPDoubleTernaryMult
-(id) init:(CPDoubleVarI*)z equals:(CPDoubleVarI*)x mult:(CPDoubleVarI*)y kbpercent:(ORDouble)p
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
-(id) init:(CPDoubleVarI*)z equals:(CPDoubleVarI*)x mult:(CPDoubleVarI*)y
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
   int gchanged,changed;
   changed = gchanged = false;
   double_interval zTemp,yTemp,xTemp,z,x,y;
   intersectionIntervalD inter;
   z = makeDoubleInterval([_z min],[_z max]);
   x = makeDoubleInterval([_x min],[_x max]);
   y = makeDoubleInterval([_y min],[_y max]);
   do {
      changed = false;
      zTemp = z;
      fpi_multd(_precision, _rounding, &zTemp, &x, &y);
      inter = intersectionD(_z, z, zTemp,_percent);
      z = inter.result;
      changed |= inter.changed;
      
      xTemp = x;
      fpi_multxd_inv(_precision, _rounding, &xTemp, &z, &y);
      inter = intersectionD(_x, x , xTemp,_percent);
      x = inter.result;
      changed |= inter.changed;
      
      yTemp = y;
      fpi_multyd_inv(_precision, _rounding, &yTemp, &z, &x);
      inter = intersectionD(_y, y, yTemp,_percent);
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
-(id<CPDoubleVar>) result
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

@implementation CPDoubleTernaryDiv
-(id) init:(CPDoubleVarI*)z equals:(CPDoubleVarI*)x div:(CPDoubleVarI*)y kbpercent:(ORDouble)p
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
-(id) init:(CPDoubleVarI*)z equals:(CPDoubleVarI*)x div:(CPDoubleVarI*)y
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
   double_interval zTemp,yTemp,xTemp,z,x,y;
   intersectionIntervalD inter;
   z = makeDoubleInterval([_z min],[_z max]);
   x = makeDoubleInterval([_x min],[_x max]);
   y = makeDoubleInterval([_y min],[_y max]);
   do {
      changed = false;
      zTemp = z;
      fpi_divd(_precision, _rounding, &zTemp, &x, &y);
      inter = intersectionD(_z, z, zTemp,_percent);
      z = inter.result;
      changed |= inter.changed;
      
      xTemp = x;
      fpi_divxd_inv(_precision, _rounding, &xTemp, &z, &y);
      inter = intersectionD(_x, x , xTemp,_percent);
      x = inter.result;
      changed |= inter.changed;
      
      yTemp = y;
      fpi_divyd_inv(_precision, _rounding, &yTemp, &z, &x);
      inter = intersectionD(_y, y, yTemp,_percent);
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
@end

@implementation CPDoubleReifyNEqual
-(id) initCPReify:(CPIntVar*)b when:(CPDoubleVarI*)x neq:(CPDoubleVarI*)y
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
         [[_b engine] addInternal: [CPFactory doubleNEqualc:_y to:[_x min]]];         // Rewrite as x==y  (addInternal can throw)
         assignTRInt(&_active, NO, _trail);
         return;
      }else  if ([_y bound] || [_y min] == [_y max]) {     // TRUE <=> (x != c)
         [[_b engine] addInternal: [CPFactory doubleNEqualc:_x to:[_y min]]];         // Rewrite as x==y  (addInternal can throw)
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
   return [NSMutableString stringWithFormat:@"<CPDoubleReifyNEqual:%02d %@ <=> (%@ != %@)>",_name,_b,_x,_y];
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

@implementation CPDoubleReifyEqual
-(id) initCPReifyEqual:(CPIntVar*)b when:(CPDoubleVarI*)x eqi:(CPDoubleVarI*)y
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
         [[_b engine] addInternal: [CPFactory doubleNEqualc:_y to:[_x min]]]; // Rewrite as min(x)!=y  (addInternal can throw)
      else if ([_y bound] || [_y min] == [_y max])
         [[_b engine] addInternal: [CPFactory doubleNEqualc:_x to:[_y min]]]; // Rewrite as min(y)!=x  (addInternal can throw)
   }
   else {                        // b is unknown
      if (([_x bound] && [_y bound]) || ([_x min] == [_x max] &&  [_y min] == [_y max]))
         [_b bind: [_x min] == [_y min]];
      else if ([_x max] < [_y min] || [_y max] < [_x min])
         [_b bind:NO];
   }
   if(([_b bound] && [_x bound] && [_y bound])  || ([_b bound] && ([_x min] == [_x max] &&  [_y min] == [_y max]))) assignTRInt(&_active, 0, _trail);
}
-(NSString*)description
{
   return [NSMutableString stringWithFormat:@"<CPDoubleReifyEqual:%02d %@ <=> (%@ == %@)>",_name,_b,_x,_y];
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

@implementation CPDoubleReifyGThen
-(id) initCPReifyGThen:(CPIntVar*)b when:(CPDoubleVarI*)x gti:(CPDoubleVarI*)y
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
         if(canPrecedeD(_x,_y))
            failNow();
         if(isIntersectingWithD(_x,_y)){
            if([_x min] <= [_y min]){
               ORDouble pmin = fp_next_double([_y min]);
               [_x updateMin:pmin];
            }
            if([_x max] <= [_y max]){
               ORDouble nmax = fp_previous_double([_x max]);
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
   return [NSMutableString stringWithFormat:@"<CPDoubleReifyGEqual:%02d %@ <=> (%@ > %@)>",_name,_b,_x,_y];
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


@implementation CPDoubleReifyGEqual
-(id) initCPReifyGEqual:(CPIntVar*)b when:(CPDoubleVarI*)x geqi:(CPDoubleVarI*)y
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
         [_y updateMax:fp_next_double([_x max])];
         [_x updateMin:fp_previous_double([_y min])];
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
   return [NSMutableString stringWithFormat:@"<CPDoubleReifyGEqual:%02d %@ <=> (%@ >= %@)>",_name,_b,_x,_y];
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


@implementation CPDoubleReifyLEqual
-(id) initCPReifyLEqual:(CPIntVar*)b when:(CPDoubleVarI*)x leqi:(CPDoubleVarI*)y
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
         [_x updateMin:fp_next_double([_y min])];
         [_y updateMax:fp_previous_double([_x max])];
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
   return [NSMutableString stringWithFormat:@"<CPDoubleReifyLEqual:%02d %@ <=> (%@ <= %@)>",_name,_b,_x,_y];
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


@implementation CPDoubleReifyLThen
-(id) initCPReifyLThen:(CPIntVar*)b when:(CPDoubleVarI*)x lti:(CPDoubleVarI*)y
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
         if(canFollowD(_x,_y))
            failNow();
         if(isIntersectingWithD(_x,_y)){
            if([_x min] >= [_y min]){
               ORDouble nmin = fp_next_double([_x min]);
               [_y updateMin:nmin];
            }
            if([_x max] >= [_y max]){
               ORDouble pmax = fp_previous_double([_y max]);
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
}
-(NSString*)description
{
   return [NSMutableString stringWithFormat:@"<CPDoubleReifyLThen:%02d %@ <=> (%@ < %@)>",_name,_b,_x,_y];
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




@implementation CPDoubleReifyEqualc
-(id) initCPReifyEqualc:(CPIntVar*)b when:(CPDoubleVarI*)x eqi:(ORDouble)c
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
         [[_b engine] addInternal: [CPFactory doubleNEqualc:_x to:_c]];     // Rewrite as x!=c  (addInternal can throw)
   }
   else if ([_x bound])
      [_b bind:[_x min] == _c];
   else if (![_x member:_c])
      [_b bind:false];
   else {
      [_b setBindTrigger: ^ {
         if ([_b min] == true) {
            [_x bind:_c];
         } else {
            [[_b engine] addInternal: [CPFactory doubleNEqualc:_x to:_c]];     // Rewrite as x!=c  (addInternal can throw)
         }
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
   return [NSMutableString stringWithFormat:@"<CPDoubleReifyEqual:%02d %@ <=> (%@ == %16.16e)>",_name,_b,_x,_c];
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

@implementation CPDoubleReifyLEqualc
-(id) initCPReifyLEqualc:(CPIntVar*)b when:(CPDoubleVarI*)x leqi:(ORDouble)c
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
         [_x updateMin:fp_next_double(_c)];
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
   return [NSMutableString stringWithFormat:@"<CPDoubleReifyLThen:%02d %@ <=> (%@ <= %16.16e)>",_name,_b,_x,_c];
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


@implementation CPDoubleReifyLThenc
-(id) initCPReifyLThenc:(CPIntVar*)b when:(CPDoubleVarI*)x lti:(ORDouble)c
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
         [_x updateMax:fp_previous_double(_c)];
      else
         [_x updateMin:_c];
      assignTRInt(&_active, NO, _trail);
   } else {
      if ([_x min] >= _c) {
         assignTRInt(&_active, NO, _trail);
         bindDom(_b, NO);
      } else if ([_x max] < _c) {
         assignTRInt(&_active, NO, _trail);
         bindDom(_b, YES);
      }
   }
}
-(NSString*)description
{
   return [NSMutableString stringWithFormat:@"<CPDoubleReifyLThenc:%02d %@ <=> (%@ < %16.16e)>",_name,_b,_x,_c];
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


@implementation CPDoubleReifyNotEqualc
-(id) initCPReifyNotEqualc:(CPIntVar*)b when:(CPDoubleVarI*)x neqi:(ORDouble)c
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
         [[_b engine] addInternal: [CPFactory doubleNEqualc:_x to:_c]];     // Rewrite as x!=c  (addInternal can throw)
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
            [[_b engine] addInternal: [CPFactory doubleNEqualc:_x to:_c]];     // Rewrite as x!=c  (addInternal can throw)
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
   return [NSMutableString stringWithFormat:@"<CPDoubleReifyNotEqualc:%02d %@ <=> (%@ != %16.16e)>",_name,_b,_x,_c];
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

@implementation CPDoubleReifyGEqualc
-(id) initCPReifyGEqualc:(CPIntVar*)b when:(CPDoubleVarI*)x geqi:(ORDouble)c
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
         [_x updateMax:fp_previous_double(_c)];
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
   return [NSMutableString stringWithFormat:@"<CPDoubleReifyGEqualc:%02d %@ <=> (%@ >= %16.16e)>",_name,_b,_x,_c];
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


@implementation CPDoubleReifyGThenc
-(id) initCPReifyGThenc:(CPIntVar*)b when:(CPDoubleVarI*)x gti:(ORDouble)c
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
         [_x updateMin:fp_next_double(_c)];
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
   return [NSMutableString stringWithFormat:@"<CPDoubleReifyGEqualc:%02d %@ <=> (%@ >= %16.16e)>",_name,_b,_x,_c];
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

@implementation CPDoubleAbs{
   int _precision;
   int _rounding;
   double_interval _xi;
   double_interval _resi;
}
-(id) init:(CPDoubleVarI*)res eq:(CPDoubleVarI*)x //res = |x|
{
   self = [super initCPCoreConstraint: [x engine]];
   _x = x;
   _res = res;
   _xi = makeDoubleInterval(x.min, x.max);
   _resi = makeDoubleInterval(res.min, res.max);
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
      updateDoubleInterval(&_xi,_x);
      updateDoubleInterval(&_resi,_res);
      intersectionIntervalD inter;
      double_interval resTmp = makeDoubleInterval(_res.min, _res.max);
      fpi_fabsd(_precision, _rounding, &resTmp, &_xi);
      inter = intersectionD(_res, _resi, resTmp, 0.0f);
      if(inter.changed)
         [_res updateInterval:inter.result.inf and:inter.result.sup];
      
      updateDoubleInterval(&_xi,_x);
      double_interval xTmp = makeDoubleInterval(_x.min, _x.max);
      fpi_fabs_invd(_precision,_rounding, &xTmp, &_resi);
      inter = intersectionD(_x, _xi, xTmp, 0.0f);
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
@end

@implementation CPDoubleSqrt{
   int _precision;
   int _rounding;
   double_interval _xi;
   double_interval _resi;
}
-(id) init:(CPDoubleVarI*)res eq:(CPDoubleVarI*)x //res = |x|
{
   self = [super initCPCoreConstraint: [x engine]];
   _x = x;
   _res = res;
   _xi = makeDoubleInterval(x.min, x.max);
   _resi = makeDoubleInterval(res.min, res.max);
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
   updateDoubleInterval(&_xi,_x);
   updateDoubleInterval(&_resi,_res);
   intersectionIntervalD inter;
   double_interval resTmp = makeDoubleInterval(_resi.inf, _resi.sup);
   fpi_sqrtd(_precision,_rounding, &resTmp, &_xi);
   inter = intersectionD(_res, _resi, resTmp, 0.0f);
   if(inter.changed)
      [_res updateInterval:inter.result.inf and:inter.result.sup];
   
   updateDoubleInterval(&_xi,_x);
   double_interval xTmp = makeDoubleInterval(_xi.inf, _xi.sup);
   fpi_sqrtd_inv(_precision,_rounding, &xTmp, &_resi);
   inter = intersectionD(_x, _xi, xTmp, 0.0f);
   if(inter.changed)
      [_x updateInterval:inter.result.inf and:inter.result.sup];
   if([_res bound] && [_x bound]){
      assignTRInt(&_active, NO, _trail);
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
   return [NSString stringWithFormat:@"<%@ == sqrt(%@)>",_res,_x];
}
@end
