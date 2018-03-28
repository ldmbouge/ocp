/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import "CPBasicConstraint.h"
#import "CPIntVarI.h"
#import "CPFloatVarI.h"
#import "CPEngineI.h"
#import "fpi.h"


@implementation CPRestrictI
-(id) initRestrict:(id<CPIntVar>)x to:(id<ORIntSet>)r
{
   self = [super initCPCoreConstraint:[x engine]];
   _x = (CPIntVar*)x;
   _r = r;
   return self;
}
-(void) post
{
   [_x inside:_r];
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
   return [NSString stringWithFormat:@"<CPRestrict: x[%d] IN %@>",[_x getId],_r];
}
@end

@implementation CPFalse
-(id)init:(id<CPEngine>)engine
{
   self = [super initCPCoreConstraint:engine];
   return self;
}
-(void)post
{
   failNow();
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] init] autorelease];
}
-(ORUInt)nbUVars
{
   return 0;
}
-(NSString*)description
{
   return [NSString stringWithFormat:@"<CPFalse>"];
}
@end


@implementation CPEqualc
-(id) initCPEqualc: (id<CPIntVar>) x and:(ORInt)c
{
   self = [super initCPCoreConstraint: [x engine]];
   _x = (CPIntVar*)x;
   _c = c;
   return self;
}

-(void) dealloc
{
   //NSLog(@"@dealloc CPEqualc %@ == %d  (self=%p)\n",_x,_c,self);
   [super dealloc];
}

-(void) post
{
   [_x bind: _c];
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
   return [NSString stringWithFormat:@"<x[%d] == %d>",[_x getId],_c];
}
@end

@implementation CPDiffc
-(id) initCPDiffc:(id<CPIntVar>) x and:(ORInt)c
{
   self = [super initCPCoreConstraint:[x engine]];
   _x = (CPIntVar*) x;
   _c = c;
   return self;
}

-(void) dealloc
{
   //NSLog(@"@dealloc CPDiffc %@ != %d  (self=%p)\n",_x,_c,self);
   [super dealloc];
}

-(void) post
{
   [_x remove:_c];
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
   return [NSString stringWithFormat:@"<x[%d] != %d>",[_x getId],_c];
}
@end

@implementation CPEqualBC

-(id) initCPEqualBC: (CPIntVar*) x and: (CPIntVar*) y  and: (ORInt) c
{
   self = [super initCPCoreConstraint: [x engine]];
   _x = x;
   _y = y;
   _c = c;
   return self;
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_y bound];
}

-(void) post
{
   if (![_x bound] || ![_y bound]) {
      [_x whenChangeBoundsPropagate: self];
      [_y whenChangeBoundsPropagate: self];
   }
   [self propagate];
}

-(void) propagate
{
  if (bound(_x)) {
      bindDom(_y,minDom(_x) - _c);
      assignTRInt(&_active,NO,_trail);
   } else if (bound(_y)) {
       bindDom(_x,minDom(_y) + _c);
      assignTRInt(&_active,NO,_trail);
   } else {
       updateMinAndMaxOfDom(_x, minDom(_y)+_c, maxDom(_y)+_c);
       updateMinAndMaxOfDom(_y, minDom(_x)-_c, maxDom(_x)-_c);
    }
}
-(NSString*)description
{
   return [NSMutableString stringWithFormat:@"<CPEqualBC:%02d %@ == %@ + %d>",_name,_x,_y,_c];
}
@end


@implementation CPEqualDC
-(id) initCPEqualDC: (CPIntVar*) x and: (CPIntVar*) y  and: (ORInt) c
{
   self = [super initCPCoreConstraint:[x engine]];
   _x = x;
   _y = y;
   _c = c;
   return self;
}
-(NSSet*)allVars
{
   return [[NSSet alloc] initWithObjects:_x,_y,nil];
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_y bound];
}
-(void) post
{
   if (bound(_x)) {
      [_y bind:minDom(_x) - _c];
   } else if (bound(_y)) {
      [_x bind:minDom(_y) + _c];
   } else {
      [_x updateMin:[_y min]+_c andMax:[_y max] + _c];
      [_y updateMin:[_x min] - _c andMax:[_x max] - _c];
      ORBounds bx = bounds(_x);
      ORBounds by = bounds(_y);
      for(ORInt i = bx.min;i <= bx.max; i++)
         if (![_x member:i])
            [_y remove:i - _c];
      for(ORInt i = by.min; i <= by.max; i++)
         if (![_y member:i])
            [_x remove:i + _c];
      
      [_x whenLoseValue:self do:^(ORInt val) {
         [_y remove: val - _c];
      }];
      [_y whenLoseValue:self do:^(ORInt val) {
         [_x remove: val + _c];
      }];
      [_x whenBindDo:^{
         [_y bind:minDom(_x) - _c];
      } onBehalf:self];
      [_y whenBindDo:^{
         [_x bind:minDom(_y) + _c];
      } onBehalf:self];
   }
}
-(NSString*)description
{
   return [NSMutableString stringWithFormat:@"<CPEqualDC:%02d %@ == %@ + %d>",_name,_x,_y,_c];
}
@end

@implementation CPAffineBC
-(id)initCPAffineBC:(CPIntVar*)y equal:(ORInt)a times:(CPIntVar*)x plus:(ORInt)b
{
   self = [super initCPCoreConstraint:[y engine]];
   _x = x;
   _y = y;
   _a = a;
   _b = b;
   return self;
}
-(void) post
{
   [self propagate];
   if (![_x bound] || ![_y bound]) {
      [_x whenChangeBoundsPropagate: self];
      [_y whenChangeBoundsPropagate: self];
   }
   [self propagate];
}
-(void) propagate    // y == a * x + b
{
   if (bound(_x)) {
      [_y bind:_a * minDom(_x) + _b];
   }
   else if (bound(_y)) {    //  (y - b) / a == x
      ORInt ymb = minDom(_y) - _b;
      ORInt r   = ymb % _a;
      if (r != 0)
         failNow();
      else
         [_x bind:ymb / _a];
   }
   else {
      ORBounds xb = bounds(_x);
      if (_a > 0) {
         [_y updateMin:_a * xb.min + _b andMax:_a * xb.max + _b];
         ORBounds yb = bounds(_y);
         yb.min -= _b;
         yb.max -= _b;
         ORInt ymaxs = yb.max > 0  ? 0  : -1;
         ORInt ymaxr = yb.max % _a ? 1  : 0;
         ORInt ymins = yb.min > 0  ? +1 : 0;
         ORInt yminr = yb.min % _a ? 1  : 0;
         [_x updateMin:yb.min / _a + ymins * yminr andMax:yb.max / _a + ymaxs * ymaxr];
      } else {
         [_y updateMin:_a * xb.max + _b andMax:_a * xb.min + _b];
         ORBounds yb = bounds(_y);
         yb.min -= _b;
         yb.max -= _b;
         ORInt ymaxs = yb.max < 0  ? +1 : 0;
         ORInt ymaxr = yb.max % _a ? 1  : 0;
         ORInt ymins = yb.min > 0  ? -1 : 0;
         ORInt yminr = yb.min % _a ? 1  : 0;
         [_x updateMin:yb.max / _a + ymaxs * ymaxr andMax:yb.min / _a + ymins * yminr];
      }
   }
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_y bound];
}
-(NSString*)description
{
   return [NSMutableString stringWithFormat:@"<CPAffineBC:%02d %@ == %d * %@ + %d>",_name,_y,_a,_x,_b];
}
@end

@implementation CPAffineAC
-(id)initCPAffineAC:(CPIntVar*)y equal:(ORInt)a times:(CPIntVar*)x plus:(ORInt)b
{
   self = [super initCPCoreConstraint:[y engine]];
   _x = x;
   _y = y;
   _a = a;
   _b = b;
   if (a == 0)
      @throw [[ORExecutionError alloc] initORExecutionError:"CPAffineAC a == 0!"];
   return self;
}
-(void) post
{
   if (bound(_x)) {
      bindDom(_y, _a * minDom(_x) + _b);
   } else if (bound(_y)) {
      ORInt ymb = minDom(_y) - _b;
      ORInt r   = ymb % _a;
      if (r != 0)
         failNow();
      else
         [_x bind:ymb / _a];
   } else {
      for(ORInt i=minDom(_x);i <= maxDom(_x);i++) {
         ORInt v = _a * i + _b;
         if (memberDom(_x, i)) {
            if (!memberDom(_y, v))
               [_x remove:i];
         } else {
            if (memberDom(_y,v))
               [_y remove:v];
         }
      }
      for(ORInt i=minDom(_y);i <= maxDom(_y);i++) {
         if (memberDom(_y,i)) {
            ORInt v = i - _b;
            if (v % _a)          // i \in D(y) cannot reach anything _exactly_ in D(x) -> remove.
               [_y remove:i];
            else {
               ORInt w = v / _a; // in \in D(y) can reach w. if w \NOTIN D(x) remove i from D(y)
               if (!memberDom(_x, w))
                  [_y remove:i];
            }
         } else {
            ORInt v = i - _b;
            if (v % _a == 0)
               [_x remove:v / _a];
         }
      }
      if (!bound(_x))
         [_x whenLoseValue:self do:^(ORInt v) {
            ORInt w = _a * v + _b;
            [_y remove:w];
         }];
      if (!bound(_y))
         [_y whenLoseValue:self do:^(ORInt v) {
            ORInt w = v - _b;
            if (w % _a == 0)
               [_x remove:w / _a];
         }];
   }
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_y bound];
}
-(NSString*)description
{
   return [NSMutableString stringWithFormat:@"<CPAffineAC:%02d %@ == %d * %@ + %d>",_name,_y,_a,_x,_b];
}
@end

@implementation CPEqual3BC
-(id) initCPEqual3BC: (CPIntVar*) x plus: (CPIntVar*) y  equal: (CPIntVar*) z
{
   self = [super initCPCoreConstraint:[x engine]];
   _x = x;
   _y = y;
   _z = z;
   return self;
}
-(void) post
{
   [self propagate];
   if (!bound(_x))
      [_x whenChangeBoundsPropagate:self];
   if (!bound(_y))
      [_y whenChangeBoundsPropagate:self];
   if (!bound(_z))
      [_z whenChangeBoundsPropagate:self];
   [self propagate];
}
-(void)propagate
{
   ORBounds xb = bounds(_x);
   ORBounds yb = bounds(_y);
   ORBounds zb = bounds(_z);
   do {
      _todo = CPChecked;
      if (xb.min == xb.max) {
         if (yb.min == yb.max) {
            assignTRInt(&_active, NO, _trail);
            bindDom(_z,xb.min = xb.max = xb.min + yb.min);
         } else if (zb.min == zb.max) {
            assignTRInt(&_active, NO, _trail);
            bindDom(_y,yb.min = yb.max = zb.min - xb.min);
         } else {
            ORInt c = xb.min;
            yb = updateMinAndMaxOfDom(_y, zb.min - c, zb.max - c);
            zb = updateMinAndMaxOfDom(_z, yb.min + c, yb.max + c);
         }
      } else if (yb.min == yb.max) {  // we are here: bound(_x) is FALSE
         if (zb.min == zb.max) {
            assignTRInt(&_active, NO, _trail);
            bindDom(_x,xb.min = xb.max = zb.min - yb.min);
         } else {
            ORInt c = yb.min;
            xb.min = max(xb.min,zb.min - c);
            xb.max = min(xb.max,zb.max - c);
            xb = updateMinAndMaxOfDom(_x, xb.min, xb.max);
            zb.min = max(zb.min,xb.min + c);
            zb.max = min(zb.max,xb.max + c);
            zb = updateMinAndMaxOfDom(_z, zb.min, zb.max);
         }
      } else if (zb.min == zb.max) {  // bound(_x) is FALSE AND bound(_y) is FALSE
         ORInt c = zb.min;
         xb.min = max(xb.min,c - yb.max);
         xb.max = min(xb.max,c - yb.min);
         xb = updateMinAndMaxOfDom(_x, xb.min, xb.max);
         yb.min = max(yb.min,c - xb.max);
         yb.max = min(yb.max,c - xb.min);
         yb = updateMinAndMaxOfDom(_y, yb.min, yb.max);
      } else {
         zb = updateMinAndMaxOfDom(_z, xb.min + yb.min, xb.max + yb.max);
         xb = updateMinAndMaxOfDom(_x, zb.min - yb.max, zb.max - yb.min);
         yb = updateMinAndMaxOfDom(_y, zb.min - xb.max, zb.max - xb.min);
      }
   } while (_todo == CPTocheck);
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,_z,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_y bound] + ![_z bound];
}
-(NSString*)description
{
   return [NSMutableString stringWithFormat:@"<CPEqual3BC:%02d %@ + %@ == %@>",_name,_x,_y,_z];
}
@end

@implementation CPEqual3DC
-(id) initCPEqual3DC: (CPIntVar*) x plus: (CPIntVar*) y  equal: (CPIntVar*) z
{
   self = [super initCPCoreConstraint:[x engine]];
   _x = x;
   _y = y;
   _z = z;
   _xs = _ys = _zs = (TRIntArray){0,0,NULL};
   return self;
}
-(void)dealloc
{
   [_fx release];
   [_fy release];
   [_fz release];
   freeTRIntArray(_xs);
   freeTRIntArray(_ys);
   freeTRIntArray(_zs);
   [super dealloc];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,_z,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_y bound] + ![_z bound];
}
static inline TRIntArray createSupport(CPIntVar* v)
{
   return makeTRIntArray([[v engine] trail], [v max] - [v min] + 1, [v min]);
}
static void constAddScanB(ORInt a,CPBitDom* bd,CPBitDom* cd,CPIntVar* c,TRIntArray cs,id<ORTrail> trail) // a + D(b) IN D(c)
{
   ORInt min = minCPDom(bd),max = maxCPDom(bd);
   for(ORInt j=min;j<=max;++j) {
      if (!getCPDom(bd,j)) continue;
      ORInt t = a + j;
      if (memberCPDom(cd, t)) {
         ORInt cv = assignTRIntArray(cs, t, getTRIntArray(cs, t) - 1,trail);
         if (cv == 0) {
            removeDom(c, t);
         }
      }
   }
}
static void constSubScanB(ORInt a,CPBitDom* bd,CPBitDom* cd,CPIntVar* c,TRIntArray cs,id<ORTrail> trail) // a - D(b) IN D(c)
{
   ORInt min = minCPDom(bd),max = maxCPDom(bd);
   for(ORInt j=min;j<=max;j++) {
      if (!getCPDom(bd,j)) continue;
      ORInt t = a - j;
      if (memberCPDom(cd, t)) {
         ORInt cv = assignTRIntArray(cs, t, getTRIntArray(cs, t) - 1,trail);
         if (cv == 0) {
            removeDom(c, t);
         }
      }
   }
}
static void scanASubConstB(CPBitDom* ad,ORInt b,CPBitDom* cd,CPIntVar* c,TRIntArray cs,id<ORTrail> trail)  // D(a) - b IN D(c)
{
   ORInt min = minCPDom(ad),max = maxCPDom(ad);
   for(ORInt j=min;j<=max;j++) {
      if (!getCPDom(ad,j)) continue;
      ORInt t = j - b;
      if (memberCPDom(cd, t)) {
         ORInt cv = assignTRIntArray(cs, t, getTRIntArray(cs, t) - 1,trail);
         if (cv == 0) {
            removeDom(c, t);
         }
      }
   }
}

-(void)pruneVar:(CPIntVar*) v flat:(CPBitDom*) vd support:(TRIntArray) vs
{
   ORInt min = minCPDom(vd),max = maxCPDom(vd);
   for(ORInt i = min;i <= max;i++) {
      if (memberCPDom(vd, i) && getTRIntArray(vs, i) == 0) {
         setCPDom(vd, i, NO);
         [v remove:i];
      }
   }
   if (v == _x) {
      [_x whenLoseValue:self do:^(ORInt val) {
         setCPDom(_fx, val, NO);
         assignTRIntArray(_xs, val, 0,_trail);
         constAddScanB(val,_fy,_fz,_z,_zs,_trail);   // xc + D(y) in D(z)
         scanASubConstB(_fz,val,_fy,_y,_ys,_trail);   // D(z) - xc in D(y)
      }];
   } else if (v == _y) {
      [_y whenLoseValue:self do:^(ORInt val) {
         setCPDom(_fy, val, NO);
         assignTRIntArray(_ys, val, 0,_trail);
         constAddScanB(val,_fx,_fz,_z,_zs,_trail);  // yc + D(x) in D(z)
         scanASubConstB(_fz,val,_fx,_x,_xs,_trail);  // D(z) - yc in D(x)
      }];
   } else {
      [_z whenLoseValue:self do:^(ORInt val) {
         setCPDom(_fz, val, NO);
         assignTRIntArray(_zs, val, 0,_trail);
         constSubScanB(val,_fx,_fy,_y,_ys,_trail);  // zc - D(x) in D(y)
         constSubScanB(val,_fy,_fx,_x,_xs,_trail);   // zc - D(y) in D(x)
      }];
   }
}

-(void) post
{
   [self propagate];
   _fx = [_x flatDomain];
   _fy = [_y flatDomain];
   _fz = [_z flatDomain];
   _xs = createSupport(_x);
   _ys = createSupport(_y);
   _zs = createSupport(_z);
   ORInt minX = minCPDom(_fx),maxX = maxCPDom(_fx);
   ORInt minY = minCPDom(_fy),maxY = maxCPDom(_fy);
   ORInt minZ = minCPDom(_fz),maxZ = maxCPDom(_fz);
   for(ORInt i = minX;i <= maxX;i++) {
      if (memberCPDom(_fx, i)) {
         for(ORInt j=minY;j <= maxY;j++) {
            if (memberCPDom(_fy, j)) {
               ORInt v = i + j;
               if (memberCPDom(_fz, v))
                  assignTRIntArray(_zs, v, getTRIntArray(_zs, v) + 1,_trail);
            }
         }
      }
   }
   for(ORInt i = minZ;i <= maxZ;i++) {
      if (memberCPDom(_fz, i)) {
         for(ORInt j=minX;j <= maxX;j++) {
            if (memberCPDom(_fx, j)) {
               ORInt v = i - j;
               if (memberCPDom(_fy, v))
                  assignTRIntArray(_ys, v, getTRIntArray(_ys, v) + 1,_trail);
            }
         }
         for(ORInt j=minY;j <= maxY;j++) {
            if (memberCPDom(_fy, j)) {
               ORInt v = i - j;
               if (memberCPDom(_fx, v))
                  assignTRIntArray(_xs, v, getTRIntArray(_xs, v) + 1,_trail);
            }
         }
      }
   }
   [self pruneVar:_x flat:_fx support:_xs];
   [self pruneVar:_y flat:_fy support:_ys];
   [self pruneVar:_z flat:_fz support:_zs];
}

-(void) propagate
{
   do {
      if (bound(_x)) {
         if (bound(_y)) {
            assignTRInt(&_active, NO, _trail);
            [_z bind:minDom(_x) + minDom(_y)];
            return;
         } else if (bound(_z)) {
            assignTRInt(&_active, NO, _trail);
            [_y bind:minDom(_z) - minDom(_x)];
            return;
         } else {
            _todo = CPChecked;
            int c = minDom(_x);
            [_y updateMin:minDom(_z) - c andMax:[_z max] - c];
            [_z updateMin:minDom(_y)+c andMax:maxDom(_y)+c];
         }
      } else if (bound(_y)) { // _x is NOT bound
         if (bound(_z)) {
            assignTRInt(&_active, NO, _trail);
            [_x bind:minDom(_z) - minDom(_y)];
            return;
         } else {
            _todo = CPChecked;
            int c = minDom(_y);
            [_x updateMin:minDom(_z) - c andMax:[_z max] - c];
            [_z updateMin:minDom(_x)+c andMax:maxDom(_x)+c];
         }
      } else if (bound(_z)) {  // neither _x NOR _y are bound.
         _todo = CPChecked;
         int c = minDom(_z);
         [_x updateMin:c - maxDom(_y) andMax:c - minDom(_y)];
         [_y updateMin:c - maxDom(_x) andMax:c - minDom(_x)];
      } else {
         _todo = CPChecked;
         ORBounds xb = bounds(_x),yb = bounds(_y),zb = bounds(_z);
         ORInt lb = xb.min + yb.min;
         ORInt ub = xb.max + yb.max;
         if (lb > zb.min || ub < zb.max)
            [_z updateMin:lb andMax:ub];
         lb = zb.min - yb.max;
         ub = zb.max - yb.min;
         if (lb > xb.min || ub < xb.max)
            [_x updateMin:lb andMax:ub];
         lb = zb.min - xb.max;
         ub = zb.max - xb.min;
         if (lb > yb.min || ub < yb.max)
            [_y updateMin:lb andMax:ub];
      }
   } while (_todo == CPTocheck);
}
-(NSString*)description
{
   return [NSMutableString stringWithFormat:@"<CPEqual3DC:%02d %@ + %@ == %@>",_name,_x,_y,_z];
}
@end

@implementation CPNotEqual

-(id)initCPNotEqual:(CPIntVar*) x and:(CPIntVar*) y  and: (ORInt) c
{
   self = [super initCPCoreConstraint:[x engine]];
   _x = x;
   _y = y;
   _c = c;
   return self;
}

-(void) dealloc
{
   //   NSLog(@"!=::dealloc(%p)\n",self);
   [super dealloc];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_y bound];
}

-(void) post // x != y + c
{
   if ([_x bound])
      [_y remove:minDom(_x) - _c];
   else if ([_y bound])
      [_x remove:minDom(_y) + _c];
   else {
      [_x whenBindPropagate: self];
      [_y whenBindPropagate: self];
   }
}

-(void) propagate
{
   if (!_active._val) return;
   assignTRInt(&_active, NO, _trail);
   if (bound(_x))
      removeDom(_y,minDom(_x)-_c);
   else
      removeDom(_x,minDom(_y)+_c);
}
-(NSString*)description
{
   return [NSMutableString stringWithFormat:@"<CPNotEqual: %02d %@ != %@ + %d>",_name,_x,_y,_c];
}
@end

@implementation CPBasicNotEqual
-(id) initCPBasicNotEqual:(id<CPIntVar>) x and: (id<ORIntVar>) y
{
   self = [super initCPCoreConstraint:[x engine]];
   _x = (CPIntVar*) x;
   _y = (CPIntVar*) y;
   return self;
}
-(void)dealloc
{
   [super dealloc];
}
-(void) post
{
   if ([_x bound])
      [_y remove:[_x min]];
   else if ([_y bound])
      [_x remove:[_y min]];
   else {
      [_x whenBindDo:^void{
         if (!_active._val) return;
         assignTRInt(&_active, NO, _trail);
         [_y remove:minDom(_x)];
      } priority:HIGHEST_PRIO onBehalf:self];
      [_y whenBindDo:^void {
         if (!_active._val) return;
         assignTRInt(&_active, NO, _trail);
         [_x remove:minDom(_y)];
      } priority:HIGHEST_PRIO onBehalf:self];
   }
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_y bound];
}
-(NSString*)description
{
   return [NSMutableString stringWithFormat:@"<CPBasicNotEqual: %02d %@ != %@>",_name,_x,_y];
}
@end

@implementation CPLEqualBC
-(id) initCPLEqualBC:(CPIntVar*)x and:(CPIntVar*) y plus:(ORInt) c
{
   self = [super initCPCoreConstraint:[x engine]];
   _x = x;
   _y = y;
   _c = c;
   return self;
}
-(void)dealloc
{
   [super dealloc];
}
-(void) post  // x <= y + c
{
   [self propagate];
   if (!bound(_x))
      [_x whenChangeMinPropagate: self];
   if (!bound(_y))
      [_y whenChangeMaxPropagate: self];
}
-(void) propagate
{
   updateMaxDom(_x, maxDom(_y) + _c);
   updateMinDom(_y, minDom(_x) - _c);
   if (bound(_x) || bound(_y))
      assignTRInt(&_active, NO, _trail);
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_y bound];
}
-(NSString*)description
{
   return [NSMutableString stringWithFormat:@"<CPLEqualBC: %02d %@ <= %@ + %d>",_name,_x,_y,_c];
}
@end

@implementation CPAbsDC
-(id)initCPAbsDC:(id<CPIntVar>)x equal:(id<CPIntVar>)y
{
   self = [super initCPCoreConstraint: [x engine]];
   _x = (CPIntVar*) x;
   _y = (CPIntVar*) y;
   return self;
}
-(void) post
{
   if (bound(_x)) {
      [_y bind:abs(minDom(_x))];
   }
   ORBounds xb = bounds(_x);
   int mxy = max( - xb.min,xb.max);
   [_y updateMin:0 andMax:mxy];
   [_x updateMin:-mxy andMax:mxy];
   ORBounds yb = bounds(_y);
   for(int k=yb.min; k<=yb.max;k++) {
      if ([_y member:k]) {
         if (![_x member:k] && ![_y member:k])
            [_y remove:k];
      } else {
         [_x remove:k];
         [_x remove:-k];
      }
   }
   yb = bounds(_y);
   for(int k=0;k<yb.min;k++) {  // ----0----y_min-------------y_max----  kill values between 0..y_min
      if ([_x member:k])
         [_x remove:k];
      if ([_x member:-k])
         [_x remove:-k];
   }
   if (!bound(_x)) {
      [_x whenLoseValue:self do:^(ORInt val) {
         if (!memberDom(_x, -val)) {
            [_y remove:abs(val)];
         }
      }];
      [_x whenBindDo:^{
         [_y bind:abs(minDom(_x))];
      } onBehalf:self];
   }
   if (!bound(_y)) {
      [_y whenLoseValue:self do:^(ORInt val) {
         [_x remove:val];
         [_x remove:-val];
      }];
      [_y whenBindDo:^{
         ORInt val = minDom(_y);
         if (!memberDom(_x, val) && !memberDom(_x, -val)) {
            failNow();
         }
         else if (memberDom(_x, val) ^ memberDom(_x, -val)) {
            [_x bind:memberDom(_x, val) ? val : -val];
         } else {
            ORBounds xb = bounds(_x);
            for(int k=xb.min; k <= xb.max;k++)
               if (k != val && k != - val)
                  [_x remove:k];
         }
      }  onBehalf:self];
   }
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_y bound];
}
-(NSString*)description
{
   return [NSMutableString stringWithFormat:@"<CPAbsDC: %02d %@ = abs(%@)>",_name,_y,_x];
}
@end

@implementation CPAbsBC
-(id)initCPAbsBC:(id<CPIntVar>)x equal:(id<CPIntVar>)y
{
   self = [super initCPCoreConstraint:[x engine]];
   _x =  (CPIntVar*) x;
   _y =  (CPIntVar*) y;
   return self;
}
-(void) post
{
   [self propagate];
   if (!bound(_x)) [_x whenChangeBoundsPropagate:self];
   if (!bound(_y)) [_y whenChangeBoundsPropagate:self];
}
-(void) propagate
{
   do {
      _todo = CPChecked;
      ORBounds xb = bounds(_x);
      ORInt  ub = - xb.min > xb.max ? -xb.min  : xb.max;
      BOOL  cZ = xb.min < 0 && xb.max > 0;
      if (cZ) {
         ORRange aZ = [_x around:0];
         ORInt lb = min(-aZ.low,aZ.up);
         [_y updateMin:lb andMax:ub];
      } else if (xb.min >= 0) {
         [_y updateMin:xb.min andMax:xb.max];
         [_x updateMin:minDom(_y)];
      } else {
         [_y updateMin:-xb.max andMax:-xb.min];
         [_x updateMax:-minDom(_y)];
      }
      ORBounds yb = bounds(_y);
      [_x updateMin:-yb.max andMax:yb.max];
   } while(_todo == CPTocheck);
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y, nil] autorelease];
}
-(ORUInt)nbUVars
{
   return !bound(_x) + !bound(_y);
}
-(NSString*)description
{
   return [NSMutableString stringWithFormat:@"<CPAbsBC: %02d %@ == abs(%@)>",_name,_y,_x];
}
@end

@implementation CPOrDC
-(id)initCPOrDC:(id<CPIntVar>) b equal:(id<CPIntVar>) x or:(id<CPIntVar>) y
{
   self = [super initCPCoreConstraint:[b engine]];
   _b = (CPIntVar*) b;
   _x = (CPIntVar*) x;
   _y = (CPIntVar*) y;
   return self;
}
-(void) post
{
   [self propagate];
   if (!bound(_b)) [_b whenBindPropagate:self];
   if (!bound(_x)) [_x whenBindPropagate:self];
   if (!bound(_y)) [_y whenBindPropagate:self];
}
-(void)propagate
{
   if (bound(_b)) {
      BOOL bVal = minDom(_b);
      if (bVal) {
         if (maxDom(_x)==0) {
            assignTRInt(&_active, NO, _trail);
            bindDom(_y,TRUE);
         }
         else if (maxDom(_y)==0) {
            assignTRInt(&_active, NO, _trail);
            bindDom(_x,TRUE);
         }
      } else {
         assignTRInt(&_active, NO, _trail);
         bindDom(_x,NO);
         bindDom(_y,NO);
      }
   } else {
      if (bound(_x) && bound(_y)) {
         assignTRInt(&_active, NO, _trail);
         bindDom(_b,minDom(_x) || minDom(_y));
      } else if (minDom(_x)>0 || minDom(_y)>0) {
         assignTRInt(&_active, NO, _trail);
         bindDom(_b,TRUE);
      }
   }
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_b,_x,_y, nil] autorelease];
}
-(ORUInt)nbUVars
{
   return !bound(_b) + !bound(_x) + !bound(_y);
}
-(NSString*)description
{
   return [NSMutableString stringWithFormat:@"<CPOrDC: %02d %@ == (%@ || %@)>",_name,_b,_x,_y];
}
@end

@implementation CPAndDC
-(id)initCPAndDC:(CPIntVar*)b equal:(id<CPIntVar>) x and: (id<CPIntVar>) y
{
   self = [super initCPCoreConstraint:[b engine]];
   _b = (CPIntVar*) b;
   _x = (CPIntVar*) x;
   _y = (CPIntVar*) y;
   return self;
}
-(void) post
{
   [self propagate];
   if (!bound(_b)) [_b whenBindPropagate:self];
   if (!bound(_x)) [_x whenBindPropagate:self];
   if (!bound(_y)) [_y whenBindPropagate:self];
}
-(void)propagate
{
   ORBounds bb = bounds(_b);
   if (bb.min == bb.max) {
      if (bb.min) {
         assignTRInt(&_active, NO, _trail);
         bindDom(_x,TRUE);
         bindDom(_y,TRUE);
      } else {
         if (minDom(_x)==1) {
            assignTRInt(&_active, NO, _trail);
            bindDom(_y,FALSE);
         }
         else if (minDom(_y)==1) {
            assignTRInt(&_active, NO, _trail);
            bindDom(_x,FALSE);
         }
      }
   } else {
      ORBounds bx = bounds(_x),by = bounds(_y);
      if (bx.min==bx.max && by.min==by.max) {
         assignTRInt(&_active, NO, _trail);
         bindDom(_b,bx.min && by.min);
      } else if (bx.max==0 || by.max==0) {
         assignTRInt(&_active, NO, _trail);
         bindDom(_b,FALSE);
      }
   }
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_b,_x,_y, nil] autorelease];
}
-(ORUInt)nbUVars
{
   return !bound(_b) + !bound(_x) + !bound(_y);
}
-(NSString*)description
{
   return [NSMutableString stringWithFormat:@"<CPAndDC: %02d %@ == (%@ && %@)>",_name,_b,_x,_y];
}
@end

@implementation CPImplyDC
-(id)initCPImplyDC:(id<CPIntVar>)b equal:(id<CPIntVar>)x imply:(id<CPIntVar>)y
{
   self = [super initCPCoreConstraint:[b  engine]];
   _b = (CPIntVar*) b;
   _x = (CPIntVar*) x;
   _y = (CPIntVar*) y;
   return self;
}
-(void) post
{
   [self propagate];
   if (!bound(_b)) [_b whenBindPropagate:self];
   if (!bound(_x)) [_x whenBindPropagate:self];
   if (!bound(_y)) [_y whenBindPropagate:self];
}
-(void)propagate
{
   if (bound(_b)) {
      BOOL bVal = minDom(_b);
      if (bVal) {                // x=>y is true:  thus NOT(x) || y is true.
         if (minDom(_x)>0)       [_y bind:TRUE];
         else if (maxDom(_y)==0) [_x bind:FALSE];
      } else {                   // x=>y is false: thus NOT(x) || y is false.
         [_x bind:TRUE];
         [_y bind:FALSE];
      }
   } else {
      if (bound(_x) && bound(_y))
         [_b bind:!minDom(_x) || minDom(_y)];
      else if (maxDom(_x)==0 || minDom(_y)>0)
         [_b bind:TRUE];
   }
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_b,_x,_y, nil] autorelease];
}
-(ORUInt)nbUVars
{
   return !bound(_b) + !bound(_x) + !bound(_y);
}
-(NSString*)description
{
   return [NSMutableString stringWithFormat:@"<CPImplyDC: %02d %@ == (%@ => %@)>",_name,_b,_x,_y];
}
@end


@implementation CPBinImplyDC
-(id)initCPBinImplyDC:(id<CPIntVar>)x imply:(id<CPIntVar>)y
{
   self = [super initCPCoreConstraint:[x engine]];
   _x = (CPIntVar*) x;
   _y = (CPIntVar*) y;
   return self;
}
-(void) post
{
   [self propagate];
   if (!bound(_x)) [_x whenBindPropagate:self];
   if (!bound(_y)) [_y whenBindPropagate:self];
}
-(void)propagate
{
   // x=>y is true:  thus NOT(x) || y is true.
   if (minDom(_x)>0)
      bindDom(_y,TRUE);
   else if (maxDom(_y)==0)
      bindDom(_x,FALSE);
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y, nil] autorelease];
}
-(ORUInt)nbUVars
{
   return  !bound(_x) + !bound(_y);
}
-(NSString*)description
{
   return [NSMutableString stringWithFormat:@"<CPBinImplyDC: %02d %@ => %@>",_name,_x,_y];
}
@end

@implementation CPLEqualc
-(id) initCPLEqualc:(id<CPIntVar>)x and:(ORInt) c
{
   self = [super initCPCoreConstraint: [x engine]];
   _x = (CPIntVar*) x;
   _c = c;
   return self;
}
-(void) post
{
   [_x updateMax:_c];
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
   return [NSMutableString stringWithFormat:@"<CPLEqualc: %02d %@ <= %d>",_name,_x,_c];
}
@end

@implementation CPGEqualc
-(id) initCPGEqualc:(id<CPIntVar>)x and:(ORInt) c
{
   self = [super initCPCoreConstraint: [x engine]];
   _x = (CPIntVar*) x;
   _c = c;
   return self;
}
-(void) post
{
   [_x updateMin:_c];
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
   return [NSMutableString stringWithFormat:@"<CPGEqualc: %02d %@ >= %d>",_name,_x,_c];
}
@end


@implementation CPMultBC
-(id) initCPMultBC:(id<CPIntVar>)x times:(id<CPIntVar>)y equal:(id<CPIntVar>)z
{
   self = [super initCPCoreConstraint:[x engine]];
   _x = (CPIntVar*) x;
   _y = (CPIntVar*) y;
   _z = (CPIntVar*) z;
   return self;
}
-(void)dealloc
{
   [super dealloc];
}
static inline ORInt minDiv(ORLong c,ORLong d1,ORLong d2)  {
   const ORLong rd1 = c % d1,rd2 = c % d2;
   const ORLong q1 = c / d1 + (rd1 && d1*c>0);
   const ORLong q2 = c / d2 + (rd2 && d2*c>0);
   return bindDown(q1 < q2 ? q1 : q2);
}
static inline ORInt maxDiv(ORLong c,ORLong d1,ORLong d2)  {
   const ORLong rd1 = c % d1,rd2 = c % d2;
   const ORLong q1 = c / d1 - (rd1 && d1*c<0);
   const ORLong q2 = c / d2 - (rd2 && d2*c<0);
   return bindUp(q1 > q2 ? q1 : q2);
}
static inline ORLong minSeq(ORLong v[4])  {
   ORLong min = MAXINT;
   for(int i=0;i<4;i++)
      min = min > v[i] ? v[i] : min;
   return min;
}
static inline ORLong maxSeq(ORLong v[4])  {
   ORLong mx = MININT;
   for(int i=0;i<4;i++)
      mx = mx < v[i] ? v[i] : mx;
   return mx;
}
static inline int minDiv4(ORLong a,ORLong b,ORLong c,ORLong d) {
   const ORLong acr = a%c && a*c>0;
   const ORLong adr = a%d && a*d>0;
   const ORLong bcr = b%c && b*c>0;
   const ORLong bdr = b%d && b*d>0;
   return bindDown(minSeq((ORLong[4]){a/c+acr,a/d+adr,b/c+bcr,b/d+bdr}));
}
static inline int maxDiv4(ORLong a,ORLong b,ORLong c,ORLong d) {
   const ORLong acr = a%c && a*c<0;
   const ORLong adr = a%d && a*d<0;
   const ORLong bcr = b%c && b*c<0;
   const ORLong bdr = b%d && b*d<0;
   return bindUp(maxSeq((ORLong[4]){a/c-acr,a/d-adr,b/c-bcr,b/d-bdr}));
}
// RXC:  Range | Variable | Constant
static void propagateRXC(CPMultBC* mc,ORBounds r,CPIntVar* x,ORInt c)
{
   ORInt a = r.min,b = r.max;
   if (a > 0 || b < 0) {
      [x updateMin:minDiv(c,a,b) andMax:maxDiv(c,a,b)];
   } else if (a==0 || b == 0) {
      ORRange az = [x around:0];
      int s = a==0 ? az.up  : az.low;
      int l = a==0 ? b : a;
      [x updateMin:minDiv(c,s,l) andMax:maxDiv(c,s,l)];
   } else {
      ORRange az = [x around:0];
      ORInt xm1 = minDiv(c,az.low,az.up);
      ORInt xM1 = maxDiv(c,az.low,az.up);
      ORInt xm2 = minDiv(c,a,b);
      ORInt xM2 = maxDiv(c,a,b);
      ORInt xm = xm1 < xm2 ? xm1 : xm2;
      ORInt xM = xM1 > xM2 ? xM1 : xM2;
      [x updateMin:xm andMax:xM];
   }
}
-(void) propagateCXZ:(ORLong)c mult:(CPIntVar*)x equal:(ORBounds)zb
{
   int nz = ![_z member:0];
   int newMin = zb.min/c + (nz && zb.min >= 0 && zb.min % c);
   int newMax = zb.max/c - (nz && zb.max <  0 && zb.max % c);
   [x updateMin:newMin andMax:newMax];
}
-(void) postCX:(ORLong)c mult:(CPIntVar*)x equal:(CPIntVar*)z
{
   if ([x bound])
      [z bind:bindDown(c * [x min])];
   else {
      if (c > 0) {
         ORInt newMax  = bindUp(c * [x max]);
         ORInt newMin  = bindDown(c * [x min]);
         [z updateMin:newMin andMax:newMax];
         [self propagateCXZ:c mult:x equal:bounds(z)];
         [z whenChangeBoundsPropagate:self];
         [x whenChangeBoundsPropagate:self];
      } else if (c == 0) {
         [z bind:0];
      } else {
         int newMin = bindDown(c * [x max]);
         int newMax = bindUp(c * [x min]);
         [z updateMin:newMin andMax:newMax];
         [self propagateCXZ:-c mult:x equal:negBounds(z)];
         [z whenChangeBoundsPropagate:self];
         [x whenChangeBoundsPropagate:self];
      }
   }
}
static void propagateCX(CPMultBC* mc,ORLong c,CPIntVar* x,CPIntVar* z)
{
   if ([x bound]) {
      [z bind:bindDown(c * [x min])];
   }
   else {
      if (c > 0) {
         ORInt newMax  = bindUp(c * [x max]);
         ORInt newMin  = bindDown(c * [x min]);
         [z updateMin:newMin andMax:newMax];
         [mc propagateCXZ:c mult:x equal:bounds(z)];
      } else if (c == 0) {
         [z bind:0];
      } else {
         [z updateMin:bindDown(c * [x max]) andMax:bindDown(c * [x min])];
         [mc propagateCXZ:-c mult:x equal:negBounds(z)];
      }
   }
}

-(void) propagateXCR:(CPIntVar*)x mult:(CPIntVar*)y equal:(ORBounds)r
{
   ORInt a = r.min,b=r.max;
   ORInt c = [y min],d = [y max];
   if (c==0 && d==0)  {
      [_z bind:0];
   } else if (c>0) {
      [x updateMin:minDiv4(a,b,c,d) andMax:maxDiv4(a,b,c,d)];
   } else if (d<0) {
      [x updateMin:minDiv4(a,b,c,d) andMax:maxDiv4(a,b,c,d)];
   } else {
      if (a <= 0 && b >= 0)
         return;
      else {
         if (c==0 || d == 0) {
            if (a <= 0 && b >= 0) return;
            ORRange az = [y around:0]; // around zero
            int s = c==0 ? az.up : az.low;
            int l = c==0 ? d : c;
            [x updateMin:minDiv4(a,b,s,l) andMax:maxDiv4(a,b,s,l)];
         } else {
            ORRange az = [y around:0]; // around zero
            ORInt xm1 = minDiv4(a,b,az.low,az.up);
            ORInt xM1 = maxDiv4(a,b,az.low,az.up);
            ORInt xm2 = minDiv4(a,b,c,d);
            ORInt xM2 = maxDiv4(a,b,c,d);
            ORInt xm = xm1 < xm2 ? xm1 : xm2;
            ORInt xM = xM1 > xM2 ? xM1 : xM2;
            [x updateMin:xm andMax:xM];
         }
      }
   }
}
-(void) propagateXYZ
{
   if (![_z member:0]) {
      [_x remove:0];
      [_y remove:0];
   }
   ORBounds xb = [_x bounds],yb  = [_y bounds],zb;
   ORLong t[4] = {(ORLong)xb.min*yb.min,(ORLong)xb.min*yb.max,(ORLong)xb.max*yb.min,(ORLong)xb.max*yb.max};
   [_z updateMin:bindDown(minSeq(t)) andMax:bindUp(maxSeq(t))];
   zb = [_z bounds];
   [self propagateXCR:_x mult:_y equal:zb];
   [self propagateXCR:_y mult:_x equal:zb];
}
-(void) post
{
   if ([_x bound])
      [self postCX:[_x min] mult:_y equal:_z];
   else if ([_y bound])
      [self postCX:[_y min] mult:_x equal:_z];
   else if ([_z bound]) {
      if ([_z min] == 0) {
         BOOL xZero = [_x member:0];
         BOOL yZero = [_y member:0];
         if (xZero || yZero) {
            if (xZero ^ yZero) {
               if (xZero) [_x bind:0];
               if (yZero) [_y bind:0];
            } else {
               [_x whenChangePropagate:self];
               [_y whenChangePropagate:self];
            }
         }
         else
            failNow();
      } else {
         propagateRXC(self,bounds(_x),_y,[_z min]);
         propagateRXC(self,bounds(_y),_x,[_z min]);
         if (![_x bound]) [_x whenChangeBoundsPropagate:self];
         if (![_y bound]) [_y whenChangeBoundsPropagate:self];
      }
   } else {
      [self propagateXYZ];
      [_x whenChangeBoundsPropagate:self];
      [_y whenChangeBoundsPropagate:self];
      [_z whenChangeBoundsPropagate:self];
   }
}
-(void) propagate
{
   if (!_active._val) return;
   if ([_x bound]) {
      propagateCX(self,[_x min],_y,_z);
      if ([_y bound] && [_z  bound])
         assignTRInt(&_active, NO, _trail);
   } else if ([_y bound]) {
      propagateCX(self,[_y min],_x,_z);
      if ([_x bound] && [_z bound])
         assignTRInt(&_active, NO, _trail);
   } else if ([_z bound]) {
      if ([_z min] == 0) {
         BOOL xZero = [_x member:0],yZero = [_y member:0];
         if (xZero || yZero) {
            if (xZero ^ yZero) {
               if (xZero)
                  [_x bind:0];
               else [_y bind:0];
            }
         }
         else
            failNow();
      } else {
         propagateRXC(self,bounds(_x),_y,[_z min]);
         propagateRXC(self,bounds(_y),_x,[_z min]);
      }
      if ([_x bound] && [_y bound])
         assignTRInt(&_active, NO, _trail);
   } else {
      [self propagateXYZ];
   }
}

-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,_z,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_y bound] + ![_z bound];
}
-(NSString*)description
{
   return [NSMutableString stringWithFormat:@"<CPMultBC:%02d %@ == %@ * %@>",_name,_z,_x,_y];
}
@end

@implementation CPSquareBC
-(id)initCPSquareBC:(CPIntVar*)z equalSquare:(CPIntVar*)x
{
   self = [super initCPCoreConstraint:[x engine]];
   _x = x;
   _z = z;
   return self;
}
-(void) post
{
   [self propagate];
   if (!bound(_x))
      [_x whenChangeBoundsPropagate:self];
   if (!bound(_z))
      [_z whenChangeBoundsPropagate:self];
}
-(void)propagate
{
   do {
      _todo = CPChecked;
      if (bound(_x)) {
         ORInt v = minDom(_x);
         [_z bind:v*v];
         return;
      } else if (bound(_z)) {
         ORInt v = (ORInt)sqrt((double)minDom(_z));
         if (v*v == minDom(_z)) {
            if (minDom(_x) >= 0)
               bindDom(_x, v);
            else if (maxDom(_x) <= 0)
               bindDom(_x,-v);
            else
               [_x updateMin:-v andMax:v];
            return;
         } else failNow();
      } else { // nobody is bound yet.
         // first infer on y
         ORBounds xb = bounds(_x);
         ORBounds sb = {xb.min * xb.min,xb.max * xb.max};
         if (xb.min >= 0)
            [_z updateMin:sb.min andMax:sb.max];
         else if (xb.max <= 0)
            [_z updateMin:sb.max andMax:sb.min];
         else if (memberDom(_x, 0))
            [_z updateMin:0 andMax:max(sb.min, sb.max)];
         else {
            ORRange az = [_x around:0];    // ------+ ------------* --- 0 ----- * ----------------------- + --------
            ORInt lastNegative = az.low;   // pick up the two "stars" in line
            ORInt firstPositive = az.up;   // ditto
            ORInt sln = lastNegative  * lastNegative;
            ORInt sfp = firstPositive * firstPositive;
            [_z updateMin:min(sln, sfp) andMax:max(sb.min,sb.max)]; // smallest value is min of ^2 of *. largest is max of ^2 of +
         }
         // infer on x now.
         ORBounds zb = bounds(_z);
         ORBounds rz = {(ORInt)sqrt((double)zb.min),(ORInt)sqrt((double)zb.max)};
         if (xb.min >= 0)
            [_x updateMin:rz.min andMax:rz.max];
         else if (xb.max <= 0)
            [_x updateMin:- rz.max andMax:- rz.min];
         else {
            [_x updateMin:min(rz.min,-rz.max) andMax:rz.max];
         }
      }
   } while (_todo == CPTocheck);
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_z,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_z bound];
}
-(NSString*)description
{
   return [NSMutableString stringWithFormat:@"<CPSquareBC:%02d %@ == %@^2>",_name,_z,_x];
}
@end

@implementation CPSquareDC
-(id)initCPSquareDC:(id)z equalSquare:(id)x
{
   self = [super initCPSquareBC:z equalSquare:x];
   return self;
}
-(void) post
{
   [self propagate];
   ORBounds xb = bounds(_x);
   for(ORInt k=xb.min; k <= xb.max;k++) {
      ORInt ks = k * k;
      if (!memberBitDom(_x, k) && !memberBitDom(_x, -k) && memberDom(_z, ks))
         removeDom(_z, ks);
   }
   ORBounds zb = bounds(_z);
   for(ORInt k=zb.min; k <= zb.max;k++) {
      ORInt rk = (ORInt)sqrt((double)k);
      if (rk*rk == k) {
         if (!memberDom(_z, k)) {
            if (memberDom(_x, rk))
               removeDom(_x, rk);
            if (memberDom(_x,-rk))
               removeDom(_x, -rk);
         }
      } else
         removeDom(_z, k);
   }
   [_x whenLoseValue:self do:^(ORInt v) {
      ORInt vs = v * v;
      if (!memberDom(_x, v) && !memberDom(_x, -v))
         removeDom(_z, vs);
   }];
   [_z whenLoseValue:self do:^(ORInt v) {
      ORInt rv = (ORInt)sqrt((double)v);
      if (memberDom(_x, rv))
         removeDom(_x, rv);
      if (memberDom(_x, -rv))
         removeDom(_x,-rv);
   }];
}
-(NSString*)description
{
   return [NSMutableString stringWithFormat:@"<CPSquareDC:%02d %@ == %@^2>",_name,_z,_x];
}
@end


@implementation CPModcBC
-(id)initCPModcBC:(CPIntVar*)x mod:(ORInt)c equal:(CPIntVar*)y
{
   self = [super initCPCoreConstraint: [x engine]];
   _x = x;
   _y = y;
   _c = c;
   return self;
}
-(void) post
{
   [self propagate];
   if (!bound(_x))
      [_x whenChangeBoundsPropagate:self];
   if (!bound(_y))
      [_y whenChangeBoundsPropagate:self];
}
-(void)propagate
{
   if ([_x min] >= 0)
      [_y updateMin:0];
   if ([_x max] <= 0)
      [_y updateMax:0];
   if (bound(_x)) {
      [_y bind:[_x min] % _c];
   }
   else if (bound(_y)) {
      ORBounds xb = bounds(_x);
      bool outside = xb.min % _c < [_y min];
      while(outside && xb.min < xb.max) {
         if (!memberDom(_x, ++xb.min))
            continue;
         outside = xb.min % _c < [_y min];
      }
      if (xb.min  < xb.max)
         [_x updateMin:xb.min];
      outside = xb.max % _c > [_y max];
      while(outside && xb.min < xb.max) {
         if (!memberDom(_x, --xb.max))
            continue;
         outside = xb.max % _c > [_y max];
      }
      if (xb.min < xb.max)
         [_x updateMax:xb.max];
   }
   else {
      int rb = abs(_c)-1;
      [_y updateMin:-rb andMax:rb];
      ORBounds xb = bounds(_x);
      ORInt qxMax = xb.max / _c;
      ORInt qxMin = xb.min / _c;
      if (qxMin == qxMax) {
         int lr = xb.min % _c;
         int up = xb.max % _c;
         [_y updateMin:lr andMax:up];
      }
      bool outside = xb.min % _c < [_y min];
      while(outside && xb.min < xb.max) {
         if (!memberDom(_x, ++xb.min))
            continue;
         outside = xb.min % _c < [_y min];
      }
      if (xb.min < xb.max)
         [_x updateMin:xb.min];
      outside = xb.max % _c > [_y max];
      while(outside && xb.min < xb.max) {
         if (!memberDom(_x,--xb.max))
            continue;
         outside = xb.max % _c > [_y max];
      }
      if (xb.min < xb.max)
         [_x updateMax:xb.max];
   }
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_y bound] + ![_x bound];
}
-(NSString*)description
{
   return [NSMutableString stringWithFormat:@"<CPModcBC:%02d %@ == %@ MOD %d>",_name,_y,_x,_c];
}
@end

@implementation CPModcDC {
   id<ORTrailableIntArray> _r;
}
-(id)initCPModcDC:(CPIntVar*)x mod:(ORInt)c equal:(CPIntVar*)y
{
   self = [super initCPCoreConstraint: [x engine]];
   _x = x;
   _y = y;
   _c = c;
   return self;
}
-(void) post
{
   if (_x.min >= 0)
      [_y updateMin:0];
   if (_x.max <= 0)
      [_y updateMax:0];
   if (bound(_x))
      [_y bind:_x.min % _c];
   else if (bound(_y)) {
      ORBounds bx = bounds(_x);
      ORInt rem  = _y.min;
      for(int k=bx.min;k <= bx.max;k++) {
         if (!memberBitDom(_x, k)) continue;
         ORInt rk = k % _c;
         if (rk != rem)
            [_x remove:k];
      }
   }
   else {
      [_y updateMin: - _c + 1 andMax:_c - 1];
      ORInt qxMax = _x.max / _c;
      ORInt qxMin = _x.min / _c;
      if (qxMin == qxMax) {
         ORInt lr = _x.min % _c;
         ORInt up = _x.max % _c;
         [_y updateMin:lr andMax:up];
      }
      ORBounds xb = bounds(_x);
      BOOL outside = xb.min % _c < _y.min;
      while(outside && xb.min < xb.max) {
         if (!memberBitDom(_x, ++xb.min))
            continue;
         outside = xb.min % _c < _y.min;
      }
      [_x updateMin:xb.min];
      outside = xb.max % _c > _y.max;
      while(outside && xb.min < xb.max) {
         if (!memberBitDom(_x,--xb.max))
            continue;
         outside = xb.max % _c > _y.max;
      }
      [_x updateMax:xb.max];
      ORBounds yb = bounds(_y);
      _r = [ORFactory trailableIntArray:[_x engine] range:RANGE([_x engine],yb.min,yb.max) value:0];
      xb = bounds(_x);
      for(int k=xb.min ; k <= xb.max;k++) {
         if (!memberBitDom(_x, k)) continue;
         ORInt rk = k % _c;
         if (rk >= yb.min && rk <= yb.max)
            [_r[rk] incr];
         else
            [_x remove:k];
      }
      if (!bound(_x))
         [_x whenLoseValue:self do:^void(ORInt v) {
            ORInt valr = v % _c;
            if (valr >= _y.min && valr <= _y.max) {
               [_r[valr] decr];
               if (_r[valr].value == 0)
                  [_y remove:valr];
            }
         }];
      if (!bound(_y))
         [_y whenLoseValue:self do:^void(ORInt v) {
            ORBounds xb = bounds(_x);
            for(int k=xb.min;k<=xb.max;) {
               if (!memberBitDom(_x, k)) {
                  k++;
                  continue;
               }
               else {
                  ORInt rk = k % _c;
                  if (rk == v) {
                     [_x remove:k];
                     k += abs(_c);
                  }
                  else
                     k += 1;
               }
            }
         }];
   }
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_y bound] + ![_x bound];
}
-(NSString*)description
{
   return [NSMutableString stringWithFormat:@"<CPModcDC:%02d %@ == %@ MOD %d>",_name,_y,_x,_c];
}
@end

@implementation CPModBC
-(id)initCPModBC:(CPIntVar*)x mod:(CPIntVar*)y equal:(CPIntVar*)z
{
   self = [super initCPCoreConstraint: [x engine]];
   _x = x;
   _y = y;
   _z = z;
   return self;
}
-(void) post
{
   [self propagate];
   if (!bound(_x))
      [_x whenChangeBoundsPropagate:self];
   if (!bound(_y))
      [_y whenChangeBoundsPropagate:self];
   if (!bound(_z))
      [_z whenChangeBoundsPropagate:self];
}
-(void)propagate
{
   if ([_x min] >= 0)
      [_z updateMin:0];
   if ([_x max] <= 0)
      [_z updateMax:0];
   if (bound(_x)) {
      ORInt c = [_x value];
      ORBounds yb = bounds(_y);
      ORInt  ycur = yb.min;
      ORInt lowR = yb.max - 1;
      ORInt upR  = 0;
      
      while (ycur <= yb.max) {
         const ORInt m = c % ycur++;
         lowR = m < lowR ? m : lowR;
         upR  = m > upR ? m : upR;
      }
      [_z updateMin:lowR andMax:upR];
      
      yb = bounds(_y);
      ORBounds zb = bounds(_z);
      ORInt dcur = yb.min;
      while (dcur <= yb.max) {
         if (dcur!=0) {
            ORInt rem = c % dcur;
            if (rem >= zb.min && rem <= zb.max)
               break;
         }
         ++dcur;
      }
      [_y updateMin:dcur];
      dcur = yb.max;
      while(dcur >= yb.min) {
         if (dcur!=0) {
            ORInt rem = c % dcur;
            if (rem >= zb.min && rem <= zb.max)
               break;
         }
         --dcur;
      }
      [_y updateMax:dcur];
   }
   else if (bound(_y)) {
      ORInt c = [_y min];
      if (c==0) failNow();
      ORInt rb = abs(c) - 1;
      [_z updateMin:- rb andMax:rb];
      ORInt qxMax = [_x max] / c;
      ORInt qxMin = [_x min] / c;
      if (qxMin == qxMax) {
         ORInt lr = [_x min] % c;
         ORInt up = [_x max] % c;
         [_z updateMin:lr andMax:up];
      }
      ORBounds xb = bounds(_x);
      bool outside = xb.min % c < [_z min];
      while(outside && xb.min < xb.max) {
         if (!memberBitDom(_x,++xb.min))
            continue;
         outside = xb.min % c < [_z min];
      }
      [_x updateMin:xb.min];
      
      outside = xb.max % c > [_z max];
      while(outside && xb.min < xb.max) {
         if (!memberBitDom(_x, --xb.max))
            continue;
         outside = xb.max % c > [_z max];
      }
      [_x updateMax:xb.max];
   }
   else if (bound(_z)) {
      ORInt c = [_z value];
      ORBounds xb = bounds(_x);
      ORBounds yb = bounds(_y);
      bool ok = false;
      ORInt xv;
      for(xv=xb.min;xv <= xb.max && !ok;xv++) {
         ORInt cd = yb.min;
         ok = false;
         while (cd <= yb.max) {
            if (cd!=0) {
               ok = (xv % cd) == c;
               if (ok)
                  break;
            }
            ++cd;
         }
         if (ok) break;
      }
      [_x updateMin:xv];
      ok = false;
      for(xv=xb.max;xv >= xb.min && !ok;xv--) {
         ORInt cd = yb.max;
         ok = false;
         while (cd >= yb.min) {
            if (cd!=0) {
               ok = (xv % cd) == c;
               if (ok) break;
            }
            --cd;
         }
         if (ok) break;
      }
      [_x updateMax:xv];
      xb = bounds(_x);
      ORInt cd = yb.min;
      while(cd <= yb.max) {
         if (cd!=0) {
            ORInt xc = xb.min;
            while (xc % cd != c && xc <= xb.max) ++xc;
            if (xc <= xb.max)
               break;
            else ++cd;
         } else ++cd;
      }
      [_y updateMin:cd];
      cd = yb.max;
      while(cd >= yb.min) {
         if (cd!=0) {
            int xc = xb.max;
            while (xc % cd != c && xc >= xb.min) --xc;
            if (xc >= xb.min)
               break;
            else --cd;
         } else --cd;
      }
      [_y updateMax:cd];
   }
   else {
      ORBounds yb = bounds(_y);
      if (yb.min==0) {
         [_y updateMin:1];
         yb.min = 1;
      }
      if (yb.max==0) {
         [_y updateMax:-1];
         yb.max = -1;
      }
      int ld = abs(yb.min) > abs(yb.max) ? abs(yb.min) : abs(yb.max);
      [_z updateMin:-ld+1 andMax:ld-1];
   }
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,_z,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_y bound] + ![_x bound] + ![_z bound];
}
-(NSString*)description
{
   return [NSMutableString stringWithFormat:@"<CPModBC:%02d %@ == %@ MOD %@>",_name,_z,_x,_y];
}
@end

@implementation CPMinBC
-(id)initCPMin:(CPIntVar*)x and:(CPIntVar*)y equal:(CPIntVar*)z
{
   self = [super initCPCoreConstraint: [x engine]];
   _x = x;
   _y = y;
   _z = z;
   return self;
}
-(void) post
{
   [self propagate];
   if (!bound(_x)) [_x whenChangeBoundsPropagate:self];
   if (!bound(_y)) [_y whenChangeBoundsPropagate:self];
   if (!bound(_z)) [_z whenChangeBoundsPropagate:self];
}
-(void) propagate
{
   ORInt zmin = min(_x.min,_y.min);
   ORInt zmax = min(_x.max,_y.max);
   [_z updateMin:zmin andMax:zmax];
   [_x updateMin:_z.min];
   [_y updateMin:_z.min];
   zmax = _z.max;
   if (zmax < _x.min)
      [_y updateMax:zmax];
   else if (zmax < _y.min)
      [_x updateMax:zmax];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,_z,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_y bound] + ![_x bound] + ![_z bound];
}
-(NSString*)description
{
   return [NSMutableString stringWithFormat:@"<CPMinBC:%02d %@ == MIN(%@,%@)>",_name,_z,_x,_y];
}
@end


@implementation CPMaxBC
-(id)initCPMax:(CPIntVar*)x and:(CPIntVar*)y equal:(CPIntVar*)z
{
   self = [super initCPCoreConstraint: [x engine]];
   _x = x;
   _y = y;
   _z = z;
   return self;
}
-(void) post
{
   [self propagate];
   if (!bound(_x)) [_x whenChangeBoundsPropagate:self];
   if (!bound(_y)) [_y whenChangeBoundsPropagate:self];
   if (!bound(_z)) [_z whenChangeBoundsPropagate:self];
}
-(void) propagate
{
   ORInt zmin = max(_x.min,_y.min);
   ORInt zmax = max(_x.max,_y.max);
   [_z updateMin:zmin andMax:zmax];
   [_x updateMax:_z.max];
   [_y updateMax:_z.max];
   zmin = _z.min;
   if (zmin > _x.max)
      [_y updateMin:zmin];
   else if (zmin > _y.max)
      [_x updateMin:zmin];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,_z,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_y bound] + ![_x bound] + ![_z bound];
}
-(NSString*)description
{
   return [NSMutableString stringWithFormat:@"<CPMinBC:%02d %@ == MAX(%@,%@)>",_name,_z,_x,_y];
}
@end


@implementation CPAllDifferenceVC {
   CPIntVar**   _x;
   ORLong       _nb;
}
-(id) initCPAllDifferenceVC:(CPIntVar**)x nb:(ORInt) n
{
   self = [super init];
   _x = x;
   _nb = n;
   return self;
}
-(id) initCPAllDifferenceVC:(id) x
{
   if ([x isKindOfClass:[NSArray class]]) {
      id<CPEngine> fdm = (id<CPEngine>) [[x objectAtIndex:0] engine];
      self = [super initCPCoreConstraint:fdm];
      _nb = [x count];
      _x = malloc(sizeof(CPIntVar*)*_nb);
      for(ORInt k=0;k<_nb;k++)
         _x[k] = [x objectAtIndex:k];
   }
   else if ([[x class] conformsToProtocol:@protocol(ORIdArray)]) {
      id<ORIdArray> xa = x;
      id<CPEngine> fdm = (id<CPEngine>)[[xa at:[xa low]] engine];
      self = [super initCPCoreConstraint:fdm];
      _nb = [x count];
      _x  = malloc(sizeof(CPIntVar*)*_nb);
      int i =0;
      for(ORInt k=[xa low];k <= [xa up];k++)
         _x[i++] = [xa at:k];
   }
   return self;
}

-(id) initCPAllDifferenceVC: (id<CPEngine>) engine over: (id<CPIntVarArray>) x
{
   self = [super initCPCoreConstraint: engine];
   _nb = [x count];
   _x  = malloc(sizeof(CPIntVar*)*_nb);
   int i=0;
   for(ORInt k=[x low];k <= [x up];k++)
      _x[i++] = (CPIntVar*)x[k];
   return self;
}

-(void) dealloc
{
   free(_x);
   [super dealloc];
}

-(NSSet*)allVars
{
   NSSet* theSet = [[[NSSet alloc] initWithObjects:_x count:_nb] autorelease];
   return theSet;
}
-(ORUInt)nbUVars
{
   ORUInt nb=0;
   for(ORUInt k=0;k<_nb;k++)
      nb += ![_x[k] bound];
   return nb;
}

-(void) post
{
   bool ok = true;
   ORLong low  = 0,up = _nb - 1;
   ORInt minX = MAXINT,maxX = MININT;
   for(ORInt k=0;k<_nb;k++) {
      minX = min(minX,[_x[k] min]);
      maxX = max(maxX,[_x[k] max]);
   }
   ORInt* vCnt = alloca(sizeof(ORInt)*(maxX-minX+1));
   ORInt* vUse = alloca(sizeof(ORInt)*(maxX-minX+1));
   memset(vCnt,0,sizeof(ORInt)*(maxX-minX+1));
   vCnt -= minX;
   ORInt nbBoundVal = 0;
   for(ORLong k=low;k<=up;k++) {
      if ([_x[k] bound]) {
         ORInt to = [_x[k] min];
         vCnt[to]++;
         ok &= vCnt[to] < 2;
         vUse[nbBoundVal++] = to;
      }
   }
   if (!ok)
      failNow();
   
   for(ORLong k=low;k<=up && ok;k++) {
      if ([_x[k] bound])
         continue;
      for(ORInt j=0;j<nbBoundVal;j++) {
         [_x[k] remove: vUse[j]];
      }
      [self listenTo:k];
   }
}
-(void)listenTo:(ORLong)k
{
   [_x[k] whenBindDo: ^ {
      ORLong up = _nb - 1;
      ORInt vk = minDom(_x[k]);
      for(ORLong i=up;i;--i) {
         if (i == k)
            continue;
         removeDom(_x[i], vk);
      }
   } onBehalf:self];
}
@end

@implementation CPIntVarMinimize
{
   CPIntVar*  _x;
   ORInt       _primalBound;
   ORInt       _dualBound;
}
-(CPIntVarMinimize*) init: (CPIntVar*) x
{
   self = [super initCPCoreConstraint:[x engine]];
   _x = x;
   _primalBound = MAXINT;
   _dualBound   = MININT;
   return self;
}
-(id<CPIntVar>)var
{
   return _x;
}
-(void) post
{
   if (![_x bound])
      [_x whenChangeMinDo: ^ {
         [_x updateMax: _primalBound - 1];
      } onBehalf:self];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x, nil] autorelease];
}
-(ORUInt)nbUVars
{
   return [_x bound] ? 0 : 1;
}
-(ORBool)   isMinimization
{
   return YES;
}
-(void) updatePrimalBound
{
   ORInt bound = [_x min];
   @synchronized(self) {
      if (bound < _primalBound)
         _primalBound = bound;
   }
}
-(void) updateDualBound
{
   ORInt bound = [_x min];
   @synchronized (self) {
      if (bound > _dualBound)
         _dualBound = bound;
   }
}
-(void) tightenPrimalBound: (id<ORObjectiveValueInt>) newBound
{
   @synchronized(self) {
      //      if ([newBound isKindOfClass:[ORObjectiveValueIntI class]]) {
      if ([newBound conformsToProtocol:@protocol(ORObjectiveValueInt)]) {
         ORInt b = [newBound value];
         if (b < _primalBound)
            _primalBound = b;
      }
   }
}
-(ORStatus) tightenDualBound:(id<ORObjectiveValueInt>)newBound
{
   @synchronized (self) {
      if ([newBound conformsToProtocol:@protocol(ORObjectiveValueInt)]) {
         ORInt b = [newBound value];
         ORStatus ok = b > _primalBound ? ORFailure : ORSuspend;
         if (ok && b > _dualBound)
            _dualBound = b;
         return ok;
      } else if ([newBound conformsToProtocol:@protocol(ORObjectiveValueReal)]) {
         ORDouble b = [(id<ORObjectiveValueReal>)newBound doubleValue];
         ORInt ib = (ORInt)ceil(b);
         ORStatus ok = ib > _primalBound ? ORFailure : ORSuspend;
         if (ok && ib > _dualBound)
            _dualBound = ib;
         return ok;
      } else return ORFailure;
   }
}
-(void) tightenLocallyWithDualBound: (id) newBound
{
   @synchronized(self) {
      if ([newBound conformsToProtocol:@protocol(ORObjectiveValueInt)]) {
         ORInt b = [((id<ORObjectiveValueInt>) newBound) value];
         [_x updateMin: max(_dualBound, b)];
      }
      else if ([newBound conformsToProtocol:@protocol(ORObjectiveValueReal)]) {
         ORInt b = (ORInt) ceil([((id<ORObjectiveValueReal>) newBound) value]);
         [_x updateMin: max(_dualBound,b)];
      }
   }
}

-(id<ORObjectiveValue>) primalValue
{
   if (bound(_x))
      return [ORFactory objectiveValueInt:_x.value minimize:YES];
   else
      return [ORFactory objectiveValueInt:_x.max + 1  minimize:YES];
}
-(id<ORObjectiveValue>) dualValue
{
   return [ORFactory objectiveValueInt:_x.min minimize:NO];
   // dual bound ordering is opposite of primal bound. (if we minimize in primal, we maximize in dual).
}
-(id<ORObjectiveValue>) primalBound
{
   return [ORFactory objectiveValueInt:_primalBound minimize:YES];
}
-(id<ORObjectiveValue>) dualBound
{
   return [ORFactory objectiveValueInt:_dualBound minimize:YES];
}

-(ORStatus) check
{
   return tryfail(^ORStatus{
      [_x updateMin:_dualBound andMax:_primalBound - 1];
      return ORSuspend;
   }, ^ORStatus{
      return ORFailure;
   });
}
-(ORBool)   isBound
{
   return [_x bound];
}
-(NSString*)description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"MINIMIZE(%@) with f* = %d  (dual: %d)",[_x description],_primalBound,_dualBound];
   return buf;
}
@end

@implementation CPIntVarMaximize
{
   CPIntVar*  _x;
   ORInt    _primalBound;
   ORInt      _dualBound;
}

-(CPIntVarMaximize*) init: (CPIntVar*) x
{
   self = [super initCPCoreConstraint:[x engine]];
   _x = x;
   _primalBound = -MAXINT;
   _dualBound = MAXINT;
   return self;
}
-(id<CPIntVar>)var
{
   return _x;
}
-(ORBool)   isMinimization
{
   return NO;
}
-(void) post
{
   if (![_x bound])
      [_x whenChangeMaxDo: ^ {
         [_x updateMin: _primalBound + 1];
      } onBehalf:self];
}

-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x, nil] autorelease];
}
-(id<ORObjectiveValue>) primalValue
{
   if (bound(_x))
      return [ORFactory objectiveValueInt:_x.value minimize:NO];
   else
      return [ORFactory objectiveValueInt:_x.min - 1  minimize:NO];
}
-(id<ORObjectiveValue>) dualValue
{
   return [ORFactory objectiveValueInt:_x.max minimize:YES];
}

-(id<ORObjectiveValue>) primalBound
{
   return [ORFactory objectiveValueInt:_primalBound minimize:NO];
}
-(id<ORObjectiveValue>) dualBound
{
   return [ORFactory objectiveValueInt:_dualBound minimize:NO];
}

-(ORUInt)nbUVars
{
   return [_x bound] ? 0 : 1;
}

-(void) updatePrimalBound
{
   ORInt bound = [_x max];
   if (bound > _primalBound)
      _primalBound = bound;
   NSLog(@"primal bound: %d",_primalBound);
}
-(void) updateDualBound
{
   ORInt bound = [_x max];
   if (bound < _dualBound)
      _dualBound = bound;
   NSLog(@"dual bound: %d",_dualBound);
}

-(void) tightenPrimalBound: (id) newBound
{
   if ([newBound conformsToProtocol:@protocol(ORObjectiveValueInt)]) {
      ORInt b = [(id<ORObjectiveValueInt>)newBound value];
      if (b > _primalBound)
         _primalBound = b;
   }
}
-(ORStatus) tightenDualBound:(id<ORObjectiveValue>)newBound
{
   if ([newBound conformsToProtocol:@protocol(ORObjectiveValueInt)]) {
      ORInt b = [(id<ORObjectiveValueInt>)newBound value];
      ORStatus ok = b < _primalBound ? ORFailure : ORSuspend;
      if (ok && b < _dualBound)
         _dualBound = b;
      return ok;
   } else if ([newBound conformsToProtocol:@protocol(ORObjectiveValueReal)]) {
      ORDouble b = [(id<ORObjectiveValueReal>)newBound doubleValue];
      ORInt ib = (ORInt)floor(b);
      ORStatus ok = ib < _primalBound ? ORFailure : ORSuspend;
      if (ok && ib < _dualBound)
         _dualBound = b;
      return ok;
   }  else return ORFailure;
}

-(void) tightenLocallyWithDualBound: (id) newBound
{
   if ([newBound conformsToProtocol:@protocol(ORObjectiveValueInt)]) {
      ORInt b = [((id<ORObjectiveValueInt>) newBound) value];
      [_x updateMax: b];
   }
   else if ([newBound conformsToProtocol:@protocol(ORObjectiveValueReal)]) {
      ORInt b = (ORInt) floor([((id<ORObjectiveValueReal>) newBound) value]);
      [_x updateMax: b];
   }
}

-(ORStatus) check
{
   @try {
      if (_primalBound == _dualBound) return ORSuccess;
      [_x updateMin:_primalBound + 1 andMax:_dualBound];
      //[_x updateMin: _primalBound + 1];
   }
   @catch (ORFailException* e) {
      [e release];
      return ORFailure;
   }
   return ORSuspend;
}

-(ORBool)   isBound
{
   return [_x bound];
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"MAXIMIZE(%@) with f* = %d  (dual: %d) [thread: %d]",[_x description],_primalBound,_dualBound,[NSThread threadID]];
   return buf;
}
@end

@implementation CPRelaxation
{
   NSArray* _mv;
   NSArray* _cv;
   id<ORRelaxation> _relaxation;
   FXInt* _updated;
   FXInt  _solved;
   TRDouble* _min;
   TRDouble* _max;
   id<CPEngine> _engine;
}
-(CPRelaxation*) initCPRelaxation: (NSArray*) mv var: (NSArray*) cv relaxation: (id<ORRelaxation>) relaxation
{
   id<CPVar> v = cv[0];
   self = [super initCPCoreConstraint:[v engine]];
   _priority = HIGHEST_PRIO-4;
   _mv = mv;
   _cv = cv;
   _relaxation = relaxation;
   _engine = [(id<CPNumVar>)cv[0] engine];
   NSUInteger nb = [_cv count];
   _updated = malloc(nb * sizeof(FXInt));
   _min = malloc(nb * sizeof(TRDouble));
   _max = malloc(nb * sizeof(TRDouble));
   _solved = makeFXInt(_trail);
   incrFXInt(&_solved,_trail);
   for(NSUInteger i = 0; i < nb; i++) {
      _updated[i] = makeFXInt(_trail);
      _min[i] = makeTRDouble(_trail,[_cv[i] doubleMin]);
      _max[i] = makeTRDouble(_trail,[_cv[i] doubleMax]);
   }
   return self;
}
-(void) dealloc
{
   free(_updated);
   free(_min);
   free(_max);
   [super dealloc];
}
-(void) post
{
   [_relaxation close];
   // The relaxation could have triggered some variable fixing. Those should be lifted back up to the model
   // If a variable is fixed in the relaxation to a value, then in the full problem (fewer solutions) it should be
   // bound as well.
   NSUInteger nb = [_cv count];
   for(ORInt i = 0; i < nb; i++) {
      ORDouble lbi = [_relaxation lowerBound:_mv[i]];  // [LDM] This used to read _cv[i]. But that does not make any sense. Queries on relaxation should be in term of the model vars!
      ORDouble ubi = [_relaxation upperBound:_mv[i]];
      ORDouble nlb = lbi > [_cv[i] doubleMin] ? lbi : [_cv[i] doubleMin];
      ORDouble nub = ubi < [_cv[i] doubleMax] ? ubi : [_cv[i] doubleMax];
      if ([_cv[i] conformsToProtocol:@protocol(CPRealVar)]) {
         id<CPRealVar> cvi = _cv[i];
         [cvi updateInterval:createORI2(nlb,nub)];
      } else if ([_cv[i] conformsToProtocol:@protocol(CPIntVar)]) {
         id<CPIntVar> cvi = _cv[i];
         [cvi updateMin:rint(ceil(nlb)) andMax:rint(floor(nub))];
      }
   }
   // Now ready for the 'normal' process.
   for(ORInt i = 0; i < nb; i++) {
      assignTRDouble(&_min[i],[_cv[i] doubleMin],_trail);
      assignTRDouble(&_max[i],[_cv[i] doubleMax],_trail);
      [_relaxation updateBounds:_mv[i] lower:_min[i]._val upper:_max[i]._val];
      
      [_cv[i] whenChangeBoundsPropagate: self];
      
      [_cv[i] whenChangeBoundsDo: ^{
         //printf("whenChangedBound %d %d\n",i,_solved._mgc);
         if (getFXInt(&_solved,_trail) == 0) {
            incrFXInt(&_solved,_trail);
            id basis = [_relaxation basis];
            [_trail trailClosure: ^{
               OROutcome outcome = [_relaxation solveFrom:basis];
               [basis release];
               if (outcome == ORinfeasible)
                  failNow();
            }];
         }
         if (getFXInt(&_updated[i],_trail) == 0) {
            ORDouble omin = _min[i]._val;
            ORDouble omax = _max[i]._val;
            [_trail trailClosure: ^{
               [_relaxation updateBounds:_mv[i] lower:omin upper:omax];
            }];
            incrFXInt(&_updated[i],_trail);
         }
         ORDouble lb = [_cv[i] doubleMin];
         ORDouble ub = [_cv[i] doubleMax];
         assignTRDouble(&_min[i],lb,_trail);
         assignTRDouble(&_max[i],ub,_trail);
         [_relaxation updateBounds:_mv[i] lower:lb upper:ub];
      }
                        onBehalf: self];
   }
   [self propagate];
}

-(void) propagate
{
   OROutcome outcome = [_relaxation solve];
   if (outcome == ORinfeasible)
      failNow();
   else if (outcome == ORoptimal) {
      id<ORSearchObjectiveFunction> o = [_engine objective];
      [o tightenLocallyWithDualBound: [_relaxation objectiveValue]];
   }
}

-(NSSet*) allVars
{
   return [[NSSet alloc] initWithArray: _cv];
}
-(ORUInt) nbUVars
{
   return (ORUInt) [_cv count];
}
@end



// ---------------------------

@implementation CPGuardedGroup {
   CPIntVar*                _guard;
}
-(id)init:(CPEngineI*) engine guard:(CPIntVar*)guard
{
   self = [super init:engine];
   _guard  = guard;
   return self;
}
-(void) post
{
   if (bound(_guard)){
      if(minDom(_guard) == 1)
         [super post];
   } else {
      [_guard whenBindDo:^{
         if ([_guard min] == 1)
            [super post];
      } onBehalf:self];
   }
}
-(NSString*)description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<CPGuardedGroup(%p): guard = %@",self,_guard];
   [super enumerateWithBlock: ^(ORInt i,id<ORConstraint> c) {
      [buf appendFormat:@"\n\t\t%3d : %@",i,[c description]];
   }];
   [buf appendString:@"\n\t>"];
   return buf;
}
@end


@implementation CPCDisjunction {
   NSArray*                 _vm;
   id<CPVarArray>            _origs;
   CPEngineI*               _engine;
   id<CPGroup>*             _inGroup;
   ORInt                    _nbIn;
   ORInt                    _max;
   TRIntArray               _cStat;
}
-(id)   init: (id<CPEngine>) engine originals:(id<CPVarArray>)origs varMap:(NSArray*)vm;
{
   self = [super initCPCoreConstraint:engine];
   _engine = engine;
   _origs = origs;
   _vm = vm;
   _max  = 2;
   _nbIn = 0;
   _inGroup = malloc(sizeof(id<CPGroup>)*_max);
   return self;
}
-(void)dealloc
{
   free(_inGroup);
   [super dealloc];
}
-(id) trackMutable: (id) obj
{
   return [_engine trackMutable:obj];
}
-(id) trackImmutable: (id) obj
{
   return [_engine trackImmutable:obj];
}
-(id) trackVariable: (id) obj
{
   return [_engine trackVariable:obj];
}
-(id) trackObjective:(id) obj
{
   return [_engine trackObjective:obj];
}
-(id) trackConstraintInGroup:(id) cg
{
   return [_engine trackConstraintInGroup:cg];
}

-(ORStatus) add: (id<CPConstraint>) p
{
   [p setGroup:self];
   if (_nbIn >= _max) {
      _inGroup = realloc(_inGroup,sizeof(id<CPGroup>)* _max * 2);
      _max *= 2;
   }
   _inGroup[_nbIn++] = (id<CPGroup>)p;
   [_engine assignIdToConstraint:p];
   return ORSuspend;
}
-(void) assignIdToConstraint:(id<ORConstraint>)c
{
   [_engine assignIdToConstraint:c];
}
-(void) scheduleTrigger: (ORClosure) cb onBehalf: (id<CPConstraint>) c
{
   assert(NO);
}
-(void) scheduleClosure: (id<CPClosureList>) evt
{
   assert(NO);
}
-(void)incNbPropagation:(ORUInt)add
{
   [_engine incNbPropagation:add];
}
- (id<ORTrail>)trail
{
   return [_engine trail];
}
-(NSString*)description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<CPCDisjunction(%p): ",self];
   [buf appendFormat:@"\n\tVM=%@",_vm];
   for(ORInt i=0;i<_nbIn;i++) {
      [buf appendFormat:@"\n\t\t%3d : %@",i,[_inGroup[i] description]];
   }
   [buf appendString:@"\n\t>"];
   return buf;
}
-(void) scheduleValueClosure: (id<CPValueEvent>) evt
{
   assert(NO);
}
-(void) enumerateWithBlock:(void(^)(ORInt,id<ORConstraint>))block
{
   for(ORInt i = 0;i <_nbIn;i++)
      block(i,_inGroup[i]);
}
-(void) post
{
   _cStat = makeTRIntArray(_trail, _nbIn, 0);
   for(ORInt i=0;i<_nbIn;i++) {
      assignTRIntArray(_cStat, i, ORSuspend, _trail);
      [_inGroup[i] post];
   }
   for(int i=_origs.range.low;i <= _origs.range.up;i++) {
      if ([_origs[i] conformsToProtocol:@protocol(CPIntVar)]) {
         id<CPIntVar> oi = (id)_origs[i];
         [oi whenChangePropagate:self];
      }else  if ([_origs[i] conformsToProtocol:@protocol(CPFloatVar)]) {
         id<CPFloatVar> oi = (id)_origs[i];
         [oi whenChangePropagate:self];
      }
   }
   [self propagate];
}
-(void) propagate
{
   if (_active._val==0)
      return;
   ORBool allFailed = true;
   ORBool entailedAndMatching = false;
   ORInt entailedClauses[_nbIn];
   ORInt nbEntailed = 0;
   for(ORInt k=0;k < _nbIn;k++) {
      if (getTRIntArray(_cStat, k) == ORFailure)
         continue;
      id<CPVarArray> vc = _vm[k];
      ORStatus s = ORSuspend;
      for(ORInt i=_origs.range.low;i <= _origs.range.up && s != ORFailure;i++) {
         id<CPVar> oVar = _origs[i];
         if (vc.range.low <= oVar.getId && oVar.getId <= vc.range.up && vc[oVar.getId]!=nil) {
            id<CPVar> cVar = vc[oVar.getId];
            // cVar subseteq oVar
            s = tryfail(^ORStatus{
               [cVar subsumedBy:oVar];
               return ORSuspend;
            }, ^ORStatus{
               return ORFailure;
            });
         }
      }
      if (s != ORFailure) {
         s = tryfail(^ORStatus{
            [_inGroup[k] propagate];
            return _inGroup[k].entailed ? ORSuccess : ORSuspend;
         }, ^ORStatus{
            return ORFailure;
         });
      }
      if (s == ORSuccess)
         entailedClauses[nbEntailed++] = k;
      allFailed   = allFailed   && (s == ORFailure);
      assignTRIntArray(_cStat, k, s, _trail);
   }
   if (allFailed) {
      failNow();
   }
   for(ORInt i=0;i<nbEntailed;i++) {
      ORInt c = entailedClauses[i];
      id<CPVarArray> vmc = _vm[c];  // now we have the alpha-renamed variable for every original var in clause c.
      ORBool allSame = true;
      for(ORInt j=_origs.range.low;j <= _origs.range.up && allSame;j++) {
         id<CPVar> original = _origs[j];
         ORInt oid = original.getId;
         if (vmc.range.low <= oid && oid <= vmc.range.up && vmc[oid]!=nil) {
            id<CPVar> renamed = vmc[oid]; // ok, now we have the original and the renamed one. Check equality
            ORBool same = [original sameDomain:renamed];
            allSame = allSame && same;
         }
      }
      if (allSame) {
         assignTRInt(&_active,NO,_trail);
         entailedAndMatching = true;
      }
   }
   // Still go on to propagate the effect of the entailed clause back up to the original vars.
   for(ORInt j=_origs.range.low;j <= _origs.range.up;j++) {
      id<CPIntVar> oi = (id)_origs[j];
      ORInt oiId = oi.getId;
      id<CPDom> uDom = nil;
      for(ORInt c=0;c < _nbIn;c++) {
         if (getTRIntArray(_cStat, c) == ORFailure || (entailedAndMatching && getTRIntArray(_cStat, c)!=ORSuccess))
            continue;
         id<CPVarArray> varsOfClause = _vm[c];
         if (varsOfClause.range.low <= oiId && oiId <= varsOfClause.range.up && varsOfClause[oiId] != nil) {
            id<CPVar> ax = (id) varsOfClause[oiId];
            if (uDom == nil)
               uDom = [[ax domain] copyWithZone:NULL];
            else {
               id<CPADom> axd = [ax domain];
               [uDom unionWith:axd];
               [axd release];
            }
         } else {
            if (uDom == nil)
               uDom = [[oi domain] copyWithZone:NULL];
            else {
               id<CPADom> oxd = [oi domain];
               [uDom unionWith:oxd];
               [oxd release];
            }
         }
      }
      [oi subsumedByDomain:uDom];
      [uDom release];
   }
}
- (void)visit:(ORVisitor *)visitor
{}

- (void)close
{}
- (ORInt) size
{
   return _nbIn;
}
@end


@implementation CP3BGroup {
   id<ORTracer>             _tracer;
   id __unsafe_unretained* _gamma;
   ORDouble                 _percent;
   NSMutableSet*            _vars;
   NSSet*                  _avars; //abstract vars
}
-(id)   init: (id<CPEngine>) engine tracer:(id<ORTracer>) tracer percent:(ORDouble)p vars:(NSSet*) avars gamma:(id<ORGamma>) solver
{
   self = [self init:engine tracer:tracer];
   _gamma = [solver gamma];
   _avars = [avars retain];
   return self;
}

-(id)   init: (id<CPEngine>) engine tracer:(id<ORTracer>) tracer vars:(NSSet*) avars gamma:(id<ORGamma>) solver
{
   return [self init:engine tracer:tracer percent:5 vars:avars gamma:solver];
}
-(id)   init: (id<CPEngine>) engine tracer:(id<ORTracer>) tracer
{
   return [self init:engine tracer:tracer percent:5];
}
-(id)   init: (id<CPEngine>) engine tracer:(id<ORTracer>) tracer percent:(ORDouble)p
{
   self = [super init:engine];
   _tracer = tracer;
   _percent = p;
   _vars = [[NSMutableSet alloc] init];
   _avars = [[NSMutableSet alloc] init];
   return self;
}
-(void)dealloc
{
   [_avars release];
   [_vars release];
   [super dealloc];
}
-(NSString*)description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<CP3BGroup(%p): ",self];
   [self enumerateWithBlock:^(ORInt i , id<ORConstraint> c) {
      [buf appendFormat:@"\n\t\t%3d : %@",i,[c description]];
   }];
   [buf appendString:@"\n\t>"];
   return buf;
}
-(ORStatus) add: (id<CPConstraint>) p
{
   ORStatus s = [super add:p];
   @autoreleasepool{
      [self addVars:[p allVars]];
   }
   return s;
}
-(void) addVars:(NSSet *)vars
{
   for(id<CPVar> v in vars)
      if ([v isKindOfClass:[CPFloatVarI class]] && ![v bound])
         [_vars addObject:v];
}
-(void) post
{
   [super post];
//   hzi : Test on 3B vars we sould reduce the number of vars involved in filtering
//   uncomment to test new 3B
//   CPFloatVarI* cv = nil;
//   [_vars release];
//   _vars = [[NSMutableSet alloc] init];
//   @autoreleasepool{
//      //hzi : review this code to implicit call to allvars
//      for(id<ORFloatVar> v in _avars){
//         cv = _gamma[v.getId];
//         __block ORBool found = NO;
//         if(![cv bound]){
//            [self enumerateWithBlock:^(ORInt i, id<ORConstraint> c) {
//               if([c nbOccurences:v] > 1){
//                  found = YES;
//                  [_vars addObject:cv];
////                 [_vars unionSet:[c allvars]];
//               }
//            }];
//            if(!found && [cv degree] > 1){
//               [_vars addObject:cv];
//            }
//         }
//      }
//   }
   //hzi : remove vars already bound.
   NSMutableArray *discardedItems = [[NSMutableArray alloc] init];
   for (CPFloatVarI* cv in _vars) {
      if([cv bound])
         [discardedItems addObject:cv];
   }
   for(CPFloatVarI* cv in discardedItems){
      [_vars removeObject:cv];
   }
   [discardedItems release];
}
-(void) propagate
{
   [super propagate];
   [self propagateSplitting];
   self->_todo = CPChecked;
}
-(void) propagateShaving
{
   ORStatus s;
   ORLDouble size;
   ORDouble percent;
   __block ORFloat min,max,last,step;
   for(id<CPFloatVar> v in _vars){
      if([v bound]) continue;
      s = ORFailure;
      size = [v domwidth];
      percent = _percent;
      last = max = min = (v.min == -infinityf()) ? -maxnormalf() : v.min;
      while (s==ORFailure) {
         [_tracer pushNode];
         step = size * (percent/100.f);
         min = max;
         max = (min + step < v.max) ? min+step : v.max;
         s=tryfail(^ORStatus{
            [v updateInterval:min and:max];
            [super propagate];
            return ORSuccess;
         }, ^ORStatus{
            last=max;
            return ORFailure;
         });
         percent*=2;
         [_tracer popNode];
      }
      if(last != v.min){
         [v updateMin:last];
         [super propagate];
      }
      
      s=ORFailure;
      size = [v domwidth];
      percent = _percent;
      last = max = min = (v.max == infinityf()) ? maxnormalf() : v.max;
      while (s==ORFailure) {
         [_tracer pushNode];
         step = size * (percent/100.f);
         max = min;
         min = (max - step > v.min) ? max-step : v.min;
         s=tryfail(^ORStatus{
            [v updateInterval:min and:max];
            [super propagate];
            return ORSuccess;
         }, ^ORStatus{
            last = min;
            return ORFailure;
         });
         percent*=2;
        [_tracer popNode];
      }
      if(last != v.max){
         [v updateMax:last];
         [super propagate];
      }
   }
}

-(void) propagateSplitting
{
   ORStatus s;
   ORLDouble size;
   ORFloat epsilon;
   __block ORFloat min,max,mid;
   for(id<CPFloatVar> v in _vars){
      if([v bound]) continue;
      s = ORSuccess;
      size = [v domwidth];
      epsilon = size * (_percent/100.f);
      min = (v.min == -infinityf()) ? -maxnormalf() : v.min;
      mid = max = (v.max == infinityf()) ? maxnormalf() : v.max;
      while (s==ORSuccess) {
         mid = (fp_next_float(min) == max)? min : min/2 + max/2;
         if (mid <= min || (mid - min <= epsilon))
            break;
         [_tracer pushNode];
         s=tryfail(^ORStatus{
            [v updateMax:mid];
            [super propagate];
            return ORSuccess;
         }, ^ORStatus{
            min=fp_next_float(mid);
            return ORFailure;
         });
         max=mid;
         [_tracer popNode];
      }
      if(min != v.min){
         [v updateMin:min];
         [super propagate];
       }
      
      s = ORSuccess;
      size = [v domwidth];
      epsilon = size * (_percent/100.f);
      min = (v.min == -infinityf()) ? -maxnormalf() : v.min;
      max = (v.max == infinityf()) ? maxnormalf() : v.max;
      while (s==ORSuccess) {
         mid = (fp_next_float(min) == max) ? max : min/2 + max/2;
         if (mid >= max || (max - mid <= epsilon))
            break;
         [_tracer pushNode];
         s=tryfail(^ORStatus{
            [v updateMin:mid];
            [super propagate];
            return ORSuccess;
         }, ^ORStatus{
            max = fp_previous_float(mid);
            return ORFailure;
         });
         min=mid;
         [_tracer popNode];
      }
      if(max != v.max){
         [v updateMax:max];
         [super propagate];
       }
   }
}
- (void)visit:(ORVisitor *)visitor
{}
- (void)close
{}
@end

