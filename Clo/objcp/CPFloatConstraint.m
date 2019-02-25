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
#import "ORConstraintI.h"
#import <fenv.h>

#define PERCENT 5.0


//unary minus constraint
@implementation CPFloatUnaryMinus{
   int _precision;
   int _rounding;
   float_interval _xi;
   float_interval _yi;
}
-(id) init:(CPFloatVarI*)x eqm:(CPFloatVarI*)y //x = -y
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
      inter = intersection(_yi, yTmp, 0.0f);
      if(inter.changed)
         [_y updateInterval:inter.result.inf and:inter.result.sup];
      
      float_interval xTmp = makeFloatInterval(_xi.inf, _xi.sup);
      fpi_minusf(_precision,_rounding, &xTmp, &_yi);
      inter = intersection(_xi, xTmp, 0.0f);
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

@implementation CPFloatEqual
-(id) init:(CPFloatVarI*)x equals:(CPFloatVarI*)y
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
      //hzi : if x in [-0.0,0.0]f : x is bound, but value return x.min
      //the domain of y must stay  [-0.0,0.0]f and not just -0.0f
      if(is_eqf([_x min],-0.0f) && is_eqf([_x max],+0.0f))
         [_y updateInterval:[_x min] and:[_x max]];
      else
         [_y bind:[_x value]];
      assignTRInt(&_active, NO, _trail);
      return;
   }else if([_y bound]){
      if(is_eqf([_y min],-0.0f) && is_eqf([_y max],+0.0f))
         [_x updateInterval:[_y min] and:[_y max]];
      else
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
   if(is_eqf(_c,0.f))
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
}
-(void) propagate
{
      updateFloatInterval(&_xi,_x);
      updateFloatInterval(&_yi,_y);
      intersectionInterval inter;
      if(isDisjointWith(_x,_y)){
         failNow();
      }else{
         float_interval xTmp = makeFloatInterval(_xi.inf, _xi.sup);
         fpi_setf(_precision, _rounding, &xTmp, &_yi);
         
         inter = intersection(_xi, xTmp, 0.0f);
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
         if (is_eqf([_x min],[_y min]))
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
            if([_x max] == [_y min]){
               [_y updateMin:fp_next_float([_y max])];
               assignTRInt(&_active, NO, _trail);
            }
            if([_x max] == [_y max]) {
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
      if([_x min] == [_y max]) {
         [_x updateMin:fp_next_float([_x min])];
         assignTRInt(&_active, NO, _trail);
      }
      if([_x max] == [_y min]){
         [_x updateMax:fp_previous_float([_x max])];
         assignTRInt(&_active, NO, _trail);
      }
      if([_x max] == [_y max]) {
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


@implementation CPFloatTernaryAdd
-(id) init:(CPFloatVarI*)z equals:(CPFloatVarI*)x plus:(CPFloatVarI*)y
{
   return [self init:z equals:x plus:y kbpercent:PERCENT];
}
-(id) init:(CPFloatVarI*)z equals:(CPFloatVarI*)x plus:(CPFloatVarI*)y kbpercent:(ORDouble)p
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
      inter = intersection(z, zTemp,_percent);
      z = inter.result;
      changed |= inter.changed;
      
      xTemp = x;
      yTemp = y;
      fpi_add_invsub_boundsf(_precision, _rounding, &xTemp, &yTemp, &z);
      inter = intersection(x , xTemp,_percent);
      x = inter.result;
      changed |= inter.changed;
      
      inter = intersection(y, yTemp,_percent);
      y = inter.result;
      changed |= inter.changed;
      
      xTemp = x;
      fpi_addxf_inv(_precision, _rounding, &xTemp, &z, &y);
      inter = intersection(x , xTemp,_percent);
      x = inter.result;
      changed |= inter.changed;
      
      yTemp = y;
      fpi_addyf_inv(_precision, _rounding, &yTemp, &z, &x);
      inter = intersection(y, yTemp,_percent);
      y = inter.result;
      changed |= inter.changed;
      gchanged |= changed;
   } while(changed);
   if(gchanged){
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
-(id<CPFloatVar>) varSubjectToAbsorption:(id<CPFloatVar>)x
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
@end


@implementation CPFloatTernarySub
-(id) init:(CPFloatVarI*)z equals:(CPFloatVarI*)x minus:(CPFloatVarI*)y kbpercent:(ORDouble)p
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
-(id) init:(CPFloatVarI*)z equals:(CPFloatVarI*)x minus:(CPFloatVarI*)y
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
   float_interval zTemp,yTemp,xTemp,z,x,y;
   intersectionInterval inter;
   z = makeFloatInterval([_z min],[_z max]);
   x = makeFloatInterval([_x min],[_x max]);
   y = makeFloatInterval([_y min],[_y max]);
   do {
      changed = false;
      zTemp = z;
      fpi_subf(_precision, _rounding, &zTemp, &x, &y);
      inter = intersection(z, zTemp,_percent);
      z = inter.result;
      changed |= inter.changed;
      
      xTemp = x;
      yTemp = y;
      fpi_sub_invsub_boundsf(_precision, _rounding, &xTemp, &yTemp, &z);
      inter = intersection(x , xTemp,_percent);
      x = inter.result;
      changed |= inter.changed;
      
      inter = intersection(y, yTemp,_percent);
      y = inter.result;
      changed |= inter.changed;
      
      xTemp = x;
      fpi_subxf_inv(_precision, _rounding, &xTemp, &z, &y);
      inter = intersection(x , xTemp,_percent);
      x = inter.result;
      changed |= inter.changed;
      
      yTemp = y;
      fpi_subyf_inv(_precision, _rounding, &yTemp, &z, &x);
      inter = intersection(y, yTemp,_percent);
      y = inter.result;
      changed |= inter.changed;
      gchanged |= changed;
   } while(changed);
   if(gchanged){
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
-(id<CPFloatVar>) varSubjectToAbsorption:(id<CPFloatVar>)x
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
      fpi_multf(_precision, _rounding, &zTemp, &x, &y);
      inter = intersection(z, zTemp,_percent);
      z = inter.result;
      changed |= inter.changed;
      
      xTemp = x;
      fpi_multxf_inv(_precision, _rounding, &xTemp, &z, &y);
      inter = intersection(x , xTemp,_percent);
      x = inter.result;
      changed |= inter.changed;
      
      yTemp = y;
      fpi_multyf_inv(_precision, _rounding, &yTemp, &z, &x);
      inter = intersection(y, yTemp,_percent);
      y = inter.result;
      changed |= inter.changed;
      gchanged |= changed;
   } while(changed);
   if(gchanged){
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
-(id<CPFloatVar>) result
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
      inter = intersection(z, zTemp,_percent);
      z = inter.result;
      changed |= inter.changed;
      
      xTemp = x;
      fpi_divxf_inv(_precision, _rounding, &xTemp, &z, &y);
      inter = intersection(x , xTemp,_percent);
      x = inter.result;
      changed |= inter.changed;
      
      yTemp = y;
      fpi_divyf_inv(_precision, _rounding, &yTemp, &z, &x);
      inter = intersection(y, yTemp,_percent);
      y = inter.result;
      changed |= inter.changed;
      gchanged |= changed;
   } while(changed);
   if(gchanged){
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
   if (bound(_b)) {
      if (minDom(_b)) {
         [[_b engine] addInternal: [CPFactory floatNEqual:_x to:_y]];         // Rewrite as x==y  (addInternal can throw)
         assignTRInt(&_active, NO, _trail);
         return ;
      } else {
         [[_b engine] addInternal: [CPFactory floatEqual:_x to:_y]];     // Rewrite as x==y  (addInternal can throw)
         assignTRInt(&_active, NO, _trail);
         return ;
      }
   }
   else if ([_x bound] && [_y bound]) {       //  b <=> c == d =>  b <- c==d
      [_b bind:[_x min] != [_y min]];
      assignTRInt(&_active, NO, _trail);
      return;
   }else if ([_x bound]) {
      [[_b engine] addInternal: [CPFactory floatReify:_b with:_y neqi:[_x min]]];
      return ;
   }
   else if ([_y bound]) {
      [[_b engine] addInternal: [CPFactory floatReify:_b with:_x neqi:[_y min]]];
      return ;
   } else {      // nobody is bound. D(x) INTER D(y) = EMPTY => b = YES
      if ([_x max] < [_y min] || [_y max] < [_x min])
         [_b bind:YES];
      else {   // nobody bound and domains of (x,y) overlap
         [_b whenBindPropagate:self];
         [_x whenChangeBoundsPropagate:self];
         [_y whenChangeBoundsPropagate:self];
      }
   }
}

-(void)propagate
{
   if (minDom(_b)) {            // b is TRUE
      if ([_x bound]){            // TRUE <=> (y != c)
         [[_b engine] addInternal: [CPFactory floatNEqualc:_y to:[_x min]]];         // Rewrite as x==y  (addInternal can throw)
         assignTRInt(&_active, NO, _trail);
         return;
      }else  if ([_y bound]) {     // TRUE <=> (x != c)
         [[_b engine] addInternal: [CPFactory floatNEqualc:_x to:[_y min]]];         // Rewrite as x==y  (addInternal can throw)
         assignTRInt(&_active, NO, _trail);
         return;
      }
   }
   else if (maxDom(_b)==0) {     // b is FALSE
      if ([_x bound]){
         if(is_eqf([_x min],-0.0f) && is_eqf([_x max],+0.0f))
            [_y updateInterval:[_x min] and:[_x max]];
         else
            [_y bind:[_x min]];
         assignTRInt(&_active, NO, _trail);
         return;
      } else if ([_y bound]){
         if(is_eqf([_y min],-0.0f) && is_eqf([_y max],+0.0f))
            [_x updateInterval:[_y min] and:[_y max]];
         else
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

@implementation CPFloatReifyEqual
-(id) initCPReifyEqual:(CPIntVar*)b when:(CPFloatVarI*)x eqi:(CPFloatVarI*)y
{
   self = [super initCPCoreConstraint:[x engine]];
   _b = b;
   _x = x;
   _y = y;
   return self;
}
-(void) post
{
   if (bound(_b)) {
      if (minDom(_b)) {
         [[_b engine] addInternal: [CPFactory floatEqual:_x to:_y]]; // Rewrite as x==y  (addInternal can throw)
         return;
      } else {
         [[_b engine] addInternal: [CPFactory floatNEqual:_x to:_y]];     // Rewrite as x!=y  (addInternal can throw)
         return;
      }
   }
   else if ([_x bound] && [_y bound])        //  b <=> c == d =>  b <- c==d
      [_b bind:[_x min] == [_y min]];
   else if ([_x bound]) {
      [[_b engine] add: [CPFactory floatReify:_b with:_y eqi:[_x min]]];
      assignTRInt(&_active, 0, _trail);
      return;
   }
   else if ([_y bound]) {
      [[_b engine] add: [CPFactory floatReify:_b with:_x eqi:[_y min]]];
      assignTRInt(&_active, 0, _trail);
      return;
   } else {      // nobody is bound. D(x) INTER D(y) = EMPTY => b = NO
      if ([_x max] < [_y min] || [_y max] < [_x min])
         [_b bind:NO];
      else {   // nobody bound and domains of (x,y) overlap
         [_b whenBindPropagate:self];
         [_x whenChangeBoundsPropagate:self];
         [_y whenChangeBoundsPropagate:self];
      }
   }
}

-(void)propagate
{
   if (minDom(_b)) {            // b is TRUE
      if ([_x bound]) {           // TRUE <=> (y == c)
         assignTRInt(&_active, 0, _trail);
         if(is_eqf([_x min],-0.0f) && is_eqf([_x max],+0.0f))
            [_y updateInterval:[_x min] and:[_x max]];
         else
            [_y bind:[_x min]];
      }else  if ([_y bound]) {     // TRUE <=> (x == c)
         assignTRInt(&_active, 0, _trail);
         if(is_eqf([_y min],-0.0f) && is_eqf([_y max],+0.0f))
            [_x updateInterval:[_y min] and:[_y max]];
         else
            [_x bind:[_y min]];
      } else {                    // TRUE <=> (x == y)
         [_x updateInterval:[_y min] and:[_y max]];
         [_y updateInterval:[_x min] and:[_x max]];
      }
   }
   else if (maxDom(_b)==0) {     // b is FALSE
      if ([_y bound])
         [[_b engine] addInternal: [CPFactory floatNEqualc:_y to:[_x min]]]; // Rewrite as min(x)!=y  (addInternal can throw)
      else if ([_y bound])
         [[_b engine] addInternal: [CPFactory floatNEqualc:_x to:[_y min]]]; // Rewrite as min(y)!=x  (addInternal can throw)
   }
   else {                        // b is unknown
      if ([_x bound] && [_y bound])
         [_b bind: [_x min] == [_y min]];
      else if ([_x max] < [_y min] || [_y max] < [_x min])
         [_b bind:NO];
   }
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
         [[_b engine] addInternal: [CPFactory floatNEqualc:_x to:_c]];     // Rewrite as x!=c  (addInternal can throw)
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
            [[_b engine] addInternal: [CPFactory floatNEqualc:_x to:_c]];     // Rewrite as x!=c  (addInternal can throw)
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
         [[_b engine] addInternal: [CPFactory floatNEqualc:_x to:_c]];     // Rewrite as x!=c  (addInternal can throw)
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
            [[_b engine] addInternal: [CPFactory floatNEqualc:_x to:_c]];     // Rewrite as x!=c  (addInternal can throw)
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

