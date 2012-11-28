/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import "ORFoundation/ORFoundation.h"
#import "CPBasicConstraint.h"
#import "CPIntVarI.h"
#import "CPEngineI.h"

@implementation CPRestrictI
-(id) initRestrict:(id<CPIntVar>)x to:(id<ORIntSet>)r
{
   self = [super initCPActiveConstraint:[x engine]];
   _x = (CPIntVarI*)x;
   _r = r;
   return self;
}
-(ORStatus)post
{
   ORStatus s = [_x inside:_r];
   if (s==ORFailure)
      return s;
   return ORSkip;
}
-(NSSet*)allVars
{
   return [[NSSet alloc] initWithObjects:_x,nil];   
}
-(ORUInt)nbUVars
{
   return ![_x bound];
}
-(NSString*)description
{
   return [NSString stringWithFormat:@"<x[%d] IN %@>",[_x getId],_r];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
   [super encodeWithCoder:aCoder];
   [aCoder encodeObject:_x];
   [aCoder encodeObject:_r];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
   self = [super initWithCoder:aDecoder];
   _x = [aDecoder decodeObject];
   _r = [aDecoder decodeObject];
   return self;
}
@end

@implementation CPEqualc
-(id) initCPEqualc: (id<CPIntVar>) x and:(ORInt)c
{
   self = [super initCPActiveConstraint: [x engine]];
   _x = (CPIntVarI*)x;
   _c = c;
   return self;
}

-(void) dealloc
{
   //NSLog(@"@dealloc CPEqualc %@ == %d  (self=%p)\n",_x,_c,self);
   [super dealloc];
}

-(ORStatus)post
{
   return [_x bind: _c];
}
-(NSSet*)allVars
{
   return [[NSSet alloc] initWithObjects:_x,nil];
}
-(ORUInt)nbUVars
{
   return ![_x bound];
}

-(NSString*)description
{
   return [NSString stringWithFormat:@"<x[%d] == %d>",[_x getId],_c];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
   [super encodeWithCoder:aCoder];
   [aCoder encodeObject:_x];
   [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_c];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
   self = [super initWithCoder:aDecoder];
   _x = [aDecoder decodeObject];
   [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_c];
   return self;
}
@end

@implementation CPDiffc
-(id) initCPDiffc:(id<CPIntVar>) x and:(ORInt)c
{
   self = [super initCPActiveConstraint:[x engine]];
   _x = (CPIntVarI*) x;
   _c = c;
   return self;
}

-(void) dealloc
{
   //NSLog(@"@dealloc CPDiffc %@ != %d  (self=%p)\n",_x,_c,self);
   [super dealloc];
}

-(ORStatus)post
{
   return [_x remove:_c];
}

-(NSSet*)allVars
{
   return [[NSSet alloc] initWithObjects:_x,nil];
}
-(ORUInt)nbUVars
{
   return ![_x bound];
}

-(NSString*)description
{
   return [NSString stringWithFormat:@"<x[%d] != %d>",[_x getId],_c];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
   [super encodeWithCoder:aCoder];
   [aCoder encodeObject:_x];
   [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_c];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
   self = [super initWithCoder:aDecoder];
   _x = [aDecoder decodeObject];
   [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_c];
   return self;
}
@end

@implementation CPEqualBC

-(id) initCPEqualBC: (id) x and: (id) y  and: (ORInt) c
{
   self = [super initCPActiveConstraint: [x engine]];
   _x = x;
   _y = y;
   _c = c;
   return self;
}

- (void) dealloc
{
    [super dealloc];
}
-(NSSet*)allVars
{
   return [[NSSet alloc] initWithObjects:_x,_y,nil];
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_y bound];
}

-(ORStatus) post
{
   if (![_x bound] || ![_y bound]) {
       [_x whenChangeBoundsPropagate: self];
       [_y whenChangeBoundsPropagate: self];
   }
   [self propagate];
   return ORSuspend;
}

-(void) propagate
{
    if ([_x bound]) {
        [_y bind:[_x min] - _c];
    } 
    else if ([_y bound]) {
        [_x bind:[_y min] + _c];
    } 
    else {
       [_x updateMin:[_y min] + _c andMax:[_y max] + _c];
       [_y updateMin:[_x min] - _c andMax:[_x max] - _c];
    }
}
-(NSString*)description
{
   return [NSMutableString stringWithFormat:@"<CPEqualBC:%02d %@ == %@ + %d>",_name,_x,_y,_c];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
   [super encodeWithCoder:aCoder];
   [aCoder encodeObject:_x];
   [aCoder encodeObject:_y];
   [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_c];
}

- (id)initWithCoder:(NSCoder *)aDecoder;
{
   self = [super initWithCoder:aDecoder];
   _x = [aDecoder decodeObject];
   _y = [aDecoder decodeObject];
   [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_c];
   return self;
}
@end


@implementation CPEqualDC
-(id) initCPEqualDC: (id) x and: (id) y  and: (ORInt) c
{
   self = [super initCPActiveConstraint:[x engine]];
   _x = x;
   _y = y;
   _c = c;
   return self;
}
-(void) dealloc
{
   [super dealloc];   
}
-(NSSet*)allVars
{
   return [[NSSet alloc] initWithObjects:_x,_y,nil];
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_y bound];
}
-(ORStatus) post
{
   ORStatus ok = ORSuspend;
   if (bound(_x)) {
      ok = [_y bind:minDom(_x) - _c];
   } else if (bound(_y)) {
      ok = [_x bind:minDom(_y) + _c];
   } else {
      ok = [_x updateMin:[_y min]+_c andMax:[_y max] + _c];
      if (ok) [_y updateMin:[_x min] - _c andMax:[_x max] - _c];
      if (ok) {
         ORBounds bx = bounds(_x);
         ORBounds by = bounds(_y);
         for(ORInt i = bx.min; (i <= bx.max) && ok; i++)
            if (![_x member:i])
               ok = [_y remove:i - _c];
         for(ORInt i = by.min; (i <= by.max) && ok; i++)
            if (![_y member:i])
               ok = [_x remove:i + _c];
      }
      if (ok) {
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
            [_x bind:minDom(_x) + _c];
         } onBehalf:self];
      }
   }
   [self propagate];
   return ORSuspend;
}
-(void) propagate
{
   do {
      _todo = CPChecked;
      if (bound(_x)) {
         [_y bind:minDom(_x) - _c];
      } else if (bound(_y)) {
         [_x bind:minDom(_y) + _c];
      } else {
         [_x updateMin:[_y min]+_c andMax:[_y max] + _c];
         [_y updateMin:[_x min] - _c andMax:[_x max] - _c];
      }
   } while (_todo == CPTocheck);
}
-(NSString*)description
{
   return [NSMutableString stringWithFormat:@"<CPEqualDC:%02d %@ == %@ + %d>",_name,_x,_y,_c];
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
   [super encodeWithCoder:aCoder];
   [aCoder encodeObject:_x];
   [aCoder encodeObject:_y];
   [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_c];
}

- (id)initWithCoder:(NSCoder *)aDecoder;
{
   self = [super initWithCoder:aDecoder];
   _x = [aDecoder decodeObject];
   _y = [aDecoder decodeObject];
   [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_c];
   return self;
}
@end

@implementation CPEqual3DC
-(id) initCPEqual3DC: (id) x plus: (id) y  equal: (id) z
{
   self = [super initCPActiveConstraint:[x engine]];
   _x = x;
   _y = y;
   _z = z;
   _xs = _ys = _zs = (TRIntArray){nil,0,0,NULL};
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
   return [[NSSet alloc] initWithObjects:_x,_y,_z,nil];
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_y bound] + ![_z bound];
}
static inline TRIntArray createSupport(CPIntVarI* v)
{
   return makeTRIntArray([[v engine] trail], [v max] - [v min] + 1, [v min]);
}
static ORStatus constAddScanB(ORInt a,CPBitDom* bd,CPBitDom* cd,CPIntVarI* c,TRIntArray cs) // a + D(b) IN D(c)
{   
   ORInt min = minCPDom(bd),max = maxCPDom(bd);
   for(ORInt j=min;j<=max;++j) {
      if (!getCPDom(bd,j)) continue;
      ORInt t = a + j;
      if (memberCPDom(cd, t)) {
         ORInt cv = assignTRIntArray(cs, t, getTRIntArray(cs, t) - 1);
         if (cv == 0) {
            removeDom(c, t);            
         }         
      }
   }
   return ORSuspend;
}
static ORStatus constSubScanB(ORInt a,CPBitDom* bd,CPBitDom* cd,CPIntVarI* c,TRIntArray cs) // a - D(b) IN D(c)
{
   ORInt min = minCPDom(bd),max = maxCPDom(bd);
   for(ORInt j=min;j<=max;j++) {
      if (!getCPDom(bd,j)) continue;
      ORInt t = a - j;
      if (memberCPDom(cd, t)) {
         ORInt cv = assignTRIntArray(cs, t, getTRIntArray(cs, t) - 1);
         if (cv == 0) { 
            removeDom(c, t);
         }         
      }
   }
   return ORSuspend;
}
static ORStatus scanASubConstB(CPBitDom* ad,ORInt b,CPBitDom* cd,CPIntVarI* c,TRIntArray cs)  // D(a) - b IN D(c)
{
   ORInt min = minCPDom(ad),max = maxCPDom(ad);
   for(ORInt j=min;j<=max;j++) {
      if (!getCPDom(ad,j)) continue;
      ORInt t = j - b;
      if (memberCPDom(cd, t)) {
         ORInt cv = assignTRIntArray(cs, t, getTRIntArray(cs, t) - 1);
         if (cv == 0) {
            removeDom(c, t);
         }         
      }
   }
   return ORSuspend;
}

-(ORStatus)pruneVar:(CPIntVarI*) v flat:(CPBitDom*) vd support:(TRIntArray) vs
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
         assignTRIntArray(_xs, val, 0);            
         constAddScanB(val,_fy,_fz,_z,_zs);   // xc + D(y) in D(z)
         scanASubConstB(_fz,val,_fy,_y,_ys);   // D(z) - xc in D(y)
      }];      
   } else if (v == _y) {
      [_y whenLoseValue:self do:^(ORInt val) {
         setCPDom(_fy, val, NO);
         assignTRIntArray(_ys, val, 0);            
         constAddScanB(val,_fx,_fz,_z,_zs);  // yc + D(x) in D(z)
         scanASubConstB(_fz,val,_fx,_x,_xs);  // D(z) - yc in D(x)
      }];
   } else {
      [_z whenLoseValue:self do:^(ORInt val) {
         setCPDom(_fz, val, NO);
         assignTRIntArray(_zs, val, 0);            
         constSubScanB(val,_fx,_fy,_y,_ys);  // zc - D(x) in D(y)
         constSubScanB(val,_fy,_fx,_x,_xs);   // zc - D(y) in D(x)
      }];
   }
   return ORSuspend;
}

-(ORStatus) post
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
                  assignTRIntArray(_zs, v, getTRIntArray(_zs, v) + 1);
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
                  assignTRIntArray(_ys, v, getTRIntArray(_ys, v) + 1);
            }
         }
         for(ORInt j=minY;j <= maxY;j++) {
            if (memberCPDom(_fy, j)) {
               ORInt v = i - j;
               if (memberCPDom(_fx, v)) 
                  assignTRIntArray(_xs, v, getTRIntArray(_xs, v) + 1);
            }
         }
      }
   }
   [self pruneVar:_x flat:_fx support:_xs];  
   [self pruneVar:_y flat:_fy support:_ys];
   [self pruneVar:_z flat:_fz support:_zs];
   return ORSuspend;   
}

-(void) propagate
{
   do {
      if (bound(_x)) {
         if (bound(_y)) {
            assignTRInt(&_active, NO, _trail);
            [_z bind:minDom(_x) + minDom(_y)];
         } else if (bound(_z)) {
            assignTRInt(&_active, NO, _trail);
            [_y bind:minDom(_z) - minDom(_x)];
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
- (void)encodeWithCoder:(NSCoder *)aCoder
{
   [super encodeWithCoder:aCoder];
   [aCoder encodeObject:_x];
   [aCoder encodeObject:_y];
   [aCoder encodeObject:_z];
}

- (id)initWithCoder:(NSCoder *)aDecoder;
{
   self = [super initWithCoder:aDecoder];
   _x = [aDecoder decodeObject];
   _y = [aDecoder decodeObject];
   _z = [aDecoder decodeObject];
   return self;
}
@end

@implementation CPNotEqual

-(id)initCPNotEqual:(id) x and:(id) y  and: (ORInt) c
{
   self = [super initCPActiveConstraint:[x engine]];
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
   return [[NSSet alloc] initWithObjects:_x,_y,nil];
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_y bound];
}

-(ORStatus) post // x != y + c
{
   if ([_x bound])
      return [_y remove:minDom(_x) - _c];
   else if ([_y bound])
      return [_x remove:minDom(_y) + _c];
   else {
       [_x whenBindPropagate: self]; 
       [_y whenBindPropagate: self];
   }
   return ORSuspend;
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
- (void)encodeWithCoder:(NSCoder *)aCoder
{
   [super encodeWithCoder:aCoder];
   [aCoder encodeObject:_x];
   [aCoder encodeObject:_y];
   [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_c];
}

- (id)initWithCoder:(NSCoder *)aDecoder;
{
   self = [super initWithCoder:aDecoder];
   _x = [aDecoder decodeObject];
   _y = [aDecoder decodeObject];
   [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_c];
   return self;
}
@end

@implementation CPBasicNotEqual
-(id) initCPBasicNotEqual:(id<CPIntVar>) x and: (id<ORIntVar>) y
{
   self = [super initCPActiveConstraint:[x engine]];
   _x = (CPIntVarI*) x;
   _y = (CPIntVarI*) y;
   return self;
}
-(void)dealloc
{ 
   [super dealloc];
}
-(ORStatus) post
{
   if ([_x bound])
      return [_y remove:[_x min]];
   else if ([_y bound])
      return [_x remove:[_y min]];
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
      return ORSuspend;
   }
}
-(NSSet*)allVars
{
   return [[NSSet alloc] initWithObjects:_x,_y,nil];
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_y bound];
}
-(NSString*)description
{
   return [NSMutableString stringWithFormat:@"<CPBasicNotEqual: %02d %@ != %@>",_name,_x,_y];
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
   [super encodeWithCoder:aCoder];
   [aCoder encodeObject:_x];
   [aCoder encodeObject:_y];
}

- (id)initWithCoder:(NSCoder *)aDecoder;
{
   self = [super initWithCoder:aDecoder];
   _x = [aDecoder decodeObject];
   _y = [aDecoder decodeObject];
   return self;
}
@end

@implementation CPLEqualBC
-(id) initCPLEqualBC:(id)x and:(id) y plus:(ORInt) c
{
   self = [super initCPActiveConstraint:[x engine]];
   _x = x;
   _y = y;
   _c = c;
   return self;   
}
-(void)dealloc
{
   [super dealloc];
}
-(ORStatus) post  // x <= y + c
{
   [self propagate];
   if (!bound(_x))
      [_x whenChangeMinPropagate: self];
   if (!bound(_y))
      [_y whenChangeMaxPropagate: self];
   [self propagate];   
   return ORSuspend;
}
-(void) propagate
{
   [_x updateMax:[_y max] + _c];
   [_y updateMin:[_x min] - _c];
}
-(NSSet*)allVars
{
   return [[NSSet alloc] initWithObjects:_x,_y,nil];
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_y bound];   
}
-(NSString*)description
{
   return [NSMutableString stringWithFormat:@"<CPLEqualBC: %02d %@ <= %@ + %d>",_name,_x,_y,_c];
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
   [super encodeWithCoder:aCoder];
   [aCoder encodeObject:_x];
   [aCoder encodeObject:_y];
   [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_c];
}

- (id)initWithCoder:(NSCoder *)aDecoder;
{
   self = [super initWithCoder:aDecoder];
   _x = [aDecoder decodeObject];
   _y = [aDecoder decodeObject];
   [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_c];
   return self;
}
@end

@implementation CPAbsDC
-(id)initCPAbsDC:(id<CPIntVar>)x equal:(id<CPIntVar>)y
{
   self = [super initCPActiveConstraint: [x engine]];
   _x = (CPIntVarI*) x;
   _y = (CPIntVarI*) y;
   return self;
}
-(ORStatus) post
{
   if (bound(_x)) {
      return [_y bind:abs(minDom(_x))];
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
   return ORSuspend;
}
-(NSSet*)allVars
{
   return [[NSSet alloc] initWithObjects:_x,_y,nil];
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_y bound];   
}
-(NSString*)description
{
   return [NSMutableString stringWithFormat:@"<CPAbsDC: %02d %@ = abs(%@)>",_name,_y,_x];
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
   [super encodeWithCoder:aCoder];
   [aCoder encodeObject:_x];
   [aCoder encodeObject:_y];
}

- (id)initWithCoder:(NSCoder *)aDecoder;
{
   self = [super initWithCoder:aDecoder];
   _x = [aDecoder decodeObject];
   _y = [aDecoder decodeObject];
   return self;
}
@end

@implementation CPAbsBC
-(id)initCPAbsBC:(id<CPIntVar>)x equal:(id<CPIntVar>)y
{
   self = [super initCPActiveConstraint:[x engine]];
   _x =  (CPIntVarI*) x;
   _y =  (CPIntVarI*) y;
   _idempotent = YES;
   return self;
}
-(ORStatus) post
{
   [self propagate];
   if (!bound(_x)) [_x whenChangeBoundsPropagate:self];
   if (!bound(_y)) [_y whenChangeBoundsPropagate:self];
   return ORSuspend;
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
   return [[NSSet alloc] initWithObjects:_x,_y, nil];
}
-(ORUInt)nbUVars
{
   return !bound(_x) + !bound(_y);
}
-(NSString*)description
{
   return [NSMutableString stringWithFormat:@"<CPAbsBC: %02d %@ == abs(%@)>",_name,_y,_x];
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
   [super encodeWithCoder:aCoder];
   [aCoder encodeObject:_x];
   [aCoder encodeObject:_y];
}

- (id)initWithCoder:(NSCoder *)aDecoder;
{
   self = [super initWithCoder:aDecoder];
   _x = [aDecoder decodeObject];
   _y = [aDecoder decodeObject];
   return self;
}
@end

@implementation CPOrDC
-(id)initCPOrDC:(id<CPIntVar>) b equal:(id<CPIntVar>) x or:(id<CPIntVar>) y
{
   self = [super initCPActiveConstraint:[b engine]];
   _b = (CPIntVarI*) b;
   _x = (CPIntVarI*) x;
   _y = (CPIntVarI*) y;
   _idempotent = YES;
   return self;
}
-(ORStatus)post
{
   [self propagate];
   if (!bound(_b)) [_b whenBindPropagate:self];
   if (!bound(_x)) [_x whenBindPropagate:self];
   if (!bound(_y)) [_y whenBindPropagate:self];
   return ORSuspend;
}
-(void)propagate
{
   if (bound(_b)) {
      BOOL bVal = minDom(_b);
      if (bVal) {
         if (maxDom(_x)==0)      [_y bind:TRUE];
         else if (maxDom(_y)==0) [_x bind:TRUE];
      } else {
         [_x bind:NO];
         [_y bind:NO];
      }
   } else {
      if (bound(_x) && bound(_y))
         [_b bind:minDom(_x) || minDom(_y)];
      else if (minDom(_x)>0 || minDom(_y)>0)
         [_b bind:TRUE];
   }
}
-(NSSet*)allVars
{
   return [[NSSet alloc] initWithObjects:_b,_x,_y, nil];
}
-(ORUInt)nbUVars
{
   return !bound(_b) + !bound(_x) + !bound(_y);
}
-(NSString*)description
{
   return [NSMutableString stringWithFormat:@"<CPOrDC: %02d %@ == (%@ || %@)>",_name,_b,_x,_y];
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
   [super encodeWithCoder:aCoder];
   [aCoder encodeObject:_b];
   [aCoder encodeObject:_x];
   [aCoder encodeObject:_y];
}
- (id)initWithCoder:(NSCoder *)aDecoder;
{
   self = [super initWithCoder:aDecoder];
   _b = [aDecoder decodeObject];
   _x = [aDecoder decodeObject];
   _y = [aDecoder decodeObject];
   return self;
}
@end

@implementation CPAndDC
-(id)initCPAndDC:(id)b equal:(id<CPIntVar>) x and: (id<CPIntVar>) y
{
   self = [super initCPActiveConstraint:[b engine]];
   _b = (CPIntVarI*) b;
   _x = (CPIntVarI*) x;
   _y = (CPIntVarI*) y;
   _idempotent = YES;
   return self;
}
-(ORStatus)post
{
   [self propagate];
   if (!bound(_b)) [_b whenBindPropagate:self];
   if (!bound(_x)) [_x whenBindPropagate:self];
   if (!bound(_y)) [_y whenBindPropagate:self];
   return ORSuspend;
}
-(void)propagate
{
   ORBounds bb = bounds(_b);
   if (bb.min == bb.max) {
      if (bb.min) {
         [_x bind:TRUE];
         [_y bind:TRUE];
      } else {
         if (minDom(_x)==1)      [_y bind:FALSE];
         else if (minDom(_y)==1) [_x bind:FALSE];
      }
   } else {
      ORBounds bx = bounds(_x),by = bounds(_y);
      if (bx.min==bx.max && by.min==by.max)
         [_b bind:bx.min && by.min];
      else if (bx.max==0 || by.max==0)
         [_b bind:FALSE];
   }
}
-(NSSet*)allVars
{
   return [[NSSet alloc] initWithObjects:_b,_x,_y, nil];
}
-(ORUInt)nbUVars
{
   return !bound(_b) + !bound(_x) + !bound(_y);
}
-(NSString*)description
{
   return [NSMutableString stringWithFormat:@"<CPAndDC: %02d %@ == (%@ && %@)>",_name,_b,_x,_y];
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
   [super encodeWithCoder:aCoder];
   [aCoder encodeObject:_b];
   [aCoder encodeObject:_x];
   [aCoder encodeObject:_y];
}
- (id)initWithCoder:(NSCoder *)aDecoder;
{
   self = [super initWithCoder:aDecoder];
   _b = [aDecoder decodeObject];
   _x = [aDecoder decodeObject];
   _y = [aDecoder decodeObject];
   return self;
}
@end

@implementation CPImplyDC
-(id)initCPImplyDC:(id<CPIntVar>)b equal:(id<CPIntVar>)x imply:(id<CPIntVar>)y
{
   self = [super initCPActiveConstraint:[b  engine]];
   _b = (CPIntVarI*) b;
   _x = (CPIntVarI*) x;
   _y = (CPIntVarI*) y;
   _idempotent = YES;
   return self;
}
-(ORStatus)post
{
   [self propagate];
   if (!bound(_b)) [_b whenBindPropagate:self];
   if (!bound(_x)) [_x whenBindPropagate:self];
   if (!bound(_y)) [_y whenBindPropagate:self];
   return ORSuspend;
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
   return [[NSSet alloc] initWithObjects:_b,_x,_y, nil];
}
-(ORUInt)nbUVars
{
   return !bound(_b) + !bound(_x) + !bound(_y);
}
-(NSString*)description
{
   return [NSMutableString stringWithFormat:@"<CPImplyDC: %02d %@ == (%@ => %@)>",_name,_b,_x,_y];
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
   [super encodeWithCoder:aCoder];
   [aCoder encodeObject:_b];
   [aCoder encodeObject:_x];
   [aCoder encodeObject:_y];
}
- (id)initWithCoder:(NSCoder *)aDecoder;
{
   self = [super initWithCoder:aDecoder];
   _b = [aDecoder decodeObject];
   _x = [aDecoder decodeObject];
   _y = [aDecoder decodeObject];
   return self;
}
@end


@implementation CPLEqualc
-(id) initCPLEqualc:(id<CPIntVar>)x and:(ORInt) c
{
   self = [super initCPActiveConstraint: [x engine]];
   _x = (CPIntVarI*) x;
   _c = c;
   return self;
}
-(ORStatus) post
{
   return [_x updateMax:_c];
}
-(NSSet*)allVars
{
   return [[NSSet alloc] initWithObjects:_x,nil];   
}
-(ORUInt)nbUVars
{
   return ![_x bound];
}
-(NSString*)description
{
   return [NSMutableString stringWithFormat:@"<CPLEqualc: %02d %@ <= %d>",_name,_x,_c];
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
   [super encodeWithCoder:aCoder];
   [aCoder encodeObject:_x];
   [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_c];
}

- (id)initWithCoder:(NSCoder *)aDecoder;
{
   self = [super initWithCoder:aDecoder];
   _x = [aDecoder decodeObject];
   [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_c];
   return self;
}
@end


@implementation CPMultBC
-(id) initCPMultBC:(id<CPIntVar>)x times:(id<CPIntVar>)y equal:(id<CPIntVar>)z
{
   self = [super initCPActiveConstraint:[x engine]];
   _x = (CPIntVarI*) x;
   _y = (CPIntVarI*) y;
   _z = (CPIntVarI*) z;
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
static ORStatus propagateRXC(CPMultBC* mc,ORBounds r,CPIntVarI* x,ORInt c)
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
   return ORSuspend;
}
-(void) propagateCXZ:(ORLong)c mult:(CPIntVarI*)x equal:(ORBounds)zb
{
   int nz = ![_z member:0];
   int newMin = zb.min/c + (nz && zb.min >= 0 && zb.min % c);
   int newMax = zb.max/c - (nz && zb.max <  0 && zb.max % c);
   [x updateMin:newMin andMax:newMax];
}
-(ORStatus) postCX:(ORLong)c mult:(CPIntVarI*)x equal:(CPIntVarI*)z 
{
   if ([x bound])
      return [z bind:bindDown(c * [x min])];
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
      return ORSuspend;
   }
}
static ORStatus propagateCX(CPMultBC* mc,ORLong c,CPIntVarI* x,CPIntVarI* z)
{
   if ([x bound]) {
      return [z bind:bindDown(c * [x min])];
   } else {
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
      return ORSuspend;
   }
}

-(void) propagateXCR:(CPIntVarI*)x mult:(CPIntVarI*)y equal:(ORBounds)r
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
   ORLong t[4] = {xb.min*yb.min,xb.min*yb.max,xb.max*yb.min,xb.max*yb.max};
   [_z updateMin:bindDown(minSeq(t)) andMax:bindUp(maxSeq(t))];
   zb = [_z bounds];
   [self propagateXCR:_x mult:_y equal:zb];
   [self propagateXCR:_y mult:_x equal:zb];
}
-(ORStatus) post
{   
   if ([_x bound])
      return [self postCX:[_x min] mult:_y equal:_z];
   else if ([_y bound])
      return [self postCX:[_y min] mult:_x equal:_z];
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
      return ORSuspend;
   } else { 
      [self propagateXYZ];
      [_x whenChangeBoundsPropagate:self];
      [_y whenChangeBoundsPropagate:self];
      [_z whenChangeBoundsPropagate:self];
      return ORSuspend;
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
   return [[NSSet alloc] initWithObjects:_x,_y,_z,nil];      
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_y bound] + ![_z bound];   
}
-(NSString*)description
{
   return [NSMutableString stringWithFormat:@"<CPMultBC:%02d %@ == %@ * %@>",_name,_z,_x,_y];
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
   [super encodeWithCoder:aCoder];
   [aCoder encodeObject:_x];
   [aCoder encodeObject:_y];
   [aCoder encodeObject:_z];
}

- (id)initWithCoder:(NSCoder *)aDecoder;
{
   self = [super initWithCoder:aDecoder];
   _x = [aDecoder decodeObject];
   _y = [aDecoder decodeObject];
   _z = [aDecoder decodeObject];
   return self;
}
@end

@implementation CPModcBC
-(id)initCPModcBC:(CPIntVarI*)x mod:(ORInt)c equal:(CPIntVarI*)y
{
   self = [super initCPActiveConstraint: [x engine]];
   _x = x;
   _y = y;
   _c = c;
   return self;
}
-(ORStatus) post
{
   [self propagate];
   if (!bound(_x))
      [_x whenChangeBoundsPropagate:self];
   if (!bound(_y))
      [_x whenChangeBoundsPropagate:self];
   return ORSuspend;
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
   return [[NSSet alloc] initWithObjects:_x,_y,nil];   
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

@implementation CPModBC
-(id)initCPModBC:(CPIntVarI*)x mod:(CPIntVarI*)y equal:(CPIntVarI*)z
{
   self = [super initCPActiveConstraint: [x engine]];
   _x = x;
   _y = y;
   _z = z;
   return self;
}
-(ORStatus) post
{
   [self propagate];
   if (!bound(_x))
      [_x whenChangeBoundsPropagate:self];
   if (!bound(_y))
      [_x whenChangeBoundsPropagate:self];
   if (!bound(_z))
      [_z whenChangeBoundsPropagate:self];
   return ORSuspend;
}
-(void)propagate
{
   /*
    if (_x->getMin() >= 0)
   if (_r->updateMin(0) == Failure)
      return Failure;
   if (_x->getMax() <= 0)
      if (_r->updateMax(0) == Failure)
         return Failure;
   if (_x->isBound()) {
      int c = _x->getMin();
      int dlow = _d->getMin(),dup = _d->getMax();
      int rlow = _r->getMin(),rup = _r->getMax();
      while (rlow <= rup) {
         int cp = c - rlow;
         int dcur = dlow;
         while (dcur <= dup) {
            if (dcur<0) {
               int rem = cp % dcur;
               if (rem==0) break;
               else ++dcur;
            } else if (dcur==0) ++dcur;
            else {
               int rem  = cp % dcur;
               if (rem == 0)
                  break;
               int q   = cp / dcur;
               if (q==0) {dcur = dup+1;break;}
               int inc = rem / q,rp  = rem % q;
               if (rp == 0) {
                  dcur += inc;
                  COMETASSERT(cp % dcur == 0);
                  break;
               } else
                  dcur += inc + 1;
            }
         }
         if (dcur > dup) ++rlow;
         else break;
      }
      Outcome ok = _r->updateMin(rlow);
      if (ok==Failure) return ok;
      while (rlow <= rup) {
         int cp = c - rup;
         int dcur = dlow;
         while (dcur <= dup) {
            if (dcur<0) {
               int rem = cp % dcur;
               if (rem==0) break;
               else ++dcur;
            } else if (dcur==0) ++dcur;
            else {
               int rem  = cp % dcur;
               if (rem == 0)
                  break;
               int q   = cp / dcur;
               if (q==0) {dcur = dup+1;break;}
               int inc = rem / q,rp  = rem % q;
               if (rp == 0) {
                  dcur += inc;
                  COMETASSERT(cp % dcur == 0);
                  break;
               } else
                  dcur += inc + 1;
            }
         }
         if (dcur > dup) --rup;
         else break;
      }
      ok = _r->updateMax(rup);
      if (ok ==Failure) return ok;
      dlow = _d->getMin();
      dup = _d->getMax();
      rlow = _r->getMin();
      rup = _r->getMax();
      int dcur = dlow;
      while (dcur <= dup) {
         if (dcur!=0) {
            int rem = c % dcur;
            if (rem >= rlow && rem <= rup)
               break;
         }
         ++dcur;
      }
      ok = _d->updateMin(dcur);
      if (ok ==Failure) return ok;
      dcur = dup;
      while(dcur >= dlow) {
         if (dcur!=0) {
            int rem = c % dcur;
            if (rem >= rlow && rem <= rup)
               break;
         }
         --dcur;
      }
      ok = _d->updateMax(dup);
      return ok;
   }
   else if (_d->isBound()) {
      int c = _d->getMin();
      if (c==0) return Failure;
      int rb = abs(c) - 1;
      Outcome ok = _r->updateMin(- rb);
      if (ok) ok = _r->updateMax(rb);
      if (ok == Failure) return ok;
      int qxMax = _x->getMax() / c;
      int qxMin = _x->getMin() / c;
      if (qxMin == qxMax) {
         int lr = _x->getMin() % c;
         int up = _x->getMax() % c;
         ok = _r->updateMin(lr);
         if (ok) ok = _r->updateMax(up);
      }
      if (ok==Failure) return ok;
      int lowx = _x->getMin(),upx  = _x->getMax();
      bool outside = lowx % c < _r->getMin();
      while(outside && lowx < upx) {
         if (!_x->member(++lowx))
            continue;
         outside = lowx % c < _r->getMin();
      }
      if (lowx < upx) ok = _x->updateMin(lowx);
      if (ok==Failure) return Failure;
      outside = upx % c > _r->getMax();
      while(outside && lowx < upx) {
         if (!_x->member(--upx))
            continue;
         outside = upx % c > _r->getMax();
      }
      if (lowx < upx) ok = _x->updateMax(upx);
      return ok;
   }
   else if (_r->isBound()) {
      int c = _r->getMin();
      Outcome oc = Suspend;
      int xv;
      int xpl = _x->getMin();
      int xpu = _x->getMax();
      int dlow = _d->getMin(),dup = _d->getMax();
      bool ok = false;
      for( xv=xpl;xv <= xpu && !ok;xv++) {
         int cd = dlow;
         ok = false;
         while (cd <= dup) {
            if (cd!=0) {
               ok = (xv % cd) == c;
               if (ok) break;
            }
            ++cd;
         }
         if (ok) break;
      }
      if (ok)
         oc = _x->updateMin(xv);
      else oc = Failure;
      if (oc ==Failure) return Failure;
      ok = false;
      for(xv=xpu;xv >= xpl && !ok;xv--) {
         int cd = dup;
         ok = false;
         while (cd >= dlow) {
            if (cd!=0) {
               ok = (xv % cd) == c;
               if (ok) break;
            }
            --cd;
         }
         if (ok) break;
      }
      if (ok)
         oc = _x->updateMax(xv);
      else oc = Failure;
      if (oc ==Failure) return Failure;
      xpl = _x->getMin();
      xpu = _x->getMax();
      int cd = dlow;
      while(cd <= dup) {
         if (cd!=0) {
            int xc = xpl;
            while (xc % cd != c && xc <= xpu) ++xc;
            if (xc <= xpu)
               break;
            else ++cd;
         } else ++cd;
      }
      oc = _d->updateMin(cd);
      if (oc==Failure) return Failure;
      
      cd = dup;
      while(cd >= dlow) {
         if (cd!=0) {
            int xc = xpu;
            while (xc % cd != c && xc >= xpl) --xc;
            if (xc >= xpl)
               break;
            else --cd;
         } else --cd;
      }
      oc = _d->updateMax(cd);
      return oc;
      
   }
   else {
      Outcome oc = Suspend;
      int dmin = _d->getMin(),dmax = _d->getMax();
      if (dmin==0) {
         oc = _d->updateMin(1);
         dmin = 1;
         if (oc == Failure) return oc;
      }
      if (dmax==0) {
         oc = _d->updateMax(-1);
         dmax = -1;
         if (oc==Failure) return oc;
      }
      int ld = abs(dmin) > abs(dmax) ? abs(dmin) : abs(dmax);
      oc = _r->updateMin(-ld+1);
      if (oc) oc = _r->updateMax(ld-1);
      if (oc==Failure) return oc;
      
      return Suspend;
   }
*/

}
-(NSSet*)allVars
{
   return [[NSSet alloc] initWithObjects:_x,_y,_z,nil];
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

@implementation CPAllDifferenceVC
-(id) initCPAllDifferenceVC:(CPIntVarI**)x nb:(ORInt) n
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
      self = [super initCPActiveConstraint:fdm];
      _nb = [x count];
      _x = malloc(sizeof(CPIntVarI*)*_nb);
      for(ORInt k=0;k<_nb;k++)
         _x[k] = [x objectAtIndex:k];
   }
   else if ([[x class] conformsToProtocol:@protocol(ORIdArray)]) {
      id<ORIdArray> xa = x;
      id<CPEngine> fdm = (id<CPEngine>)[[xa at:[xa low]] engine];
      self = [super initCPActiveConstraint:fdm];
      _nb = [x count];
      _x  = malloc(sizeof(CPIntVarI*)*_nb);
      int i =0;
      for(ORInt k=[xa low];k <= [xa up];k++)
         _x[i++] = [xa at:k];
   }      
   return self;
}

-(id) initCPAllDifferenceVC: (id<CPEngine>) engine over: (id<CPIntVarArray>) x
{
   self = [super initCPActiveConstraint: engine];
   _nb = [x count];
   _x  = malloc(sizeof(CPIntVarI*)*_nb);
   int i=0;
   for(ORInt k=[x low];k <= [x up];k++)
      _x[i++] = (CPIntVarI*)x[k];
   return self;
}

-(void) dealloc
{
   free(_x);
   [super dealloc];
}

-(NSSet*)allVars
{
   NSSet* theSet = [[NSSet alloc] initWithObjects:_x count:_nb];
   return theSet;
}
-(ORUInt)nbUVars
{
   ORUInt nb=0;
   for(ORUInt k=0;k<_nb;k++)
      nb += ![_x[k] bound];
   return nb;
}

-(ORStatus) post 
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
      SEL minSEL = @selector(min);
      IMP minIMP = [_x[k] methodForSelector:minSEL];
      [_x[k] whenBindDo: ^ {
         //int vk = [_x[k] min];
         ORInt vk = (ORInt) minIMP(_x[k],minSEL);
         for(ORLong i=up;i;--i) {
            if (i == k) 
               continue;
            [_x[i] remove:vk];
         }
      } onBehalf:self];
   }
   return ORSuspend;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
   [super encodeWithCoder:aCoder];   
   [aCoder encodeValueOfObjCType:@encode(ORLong) at:&_nb];
   for(ORInt k=0;k<_nb;k++) 
      [aCoder encodeObject:_x[k]];
}

- (id)initWithCoder:(NSCoder *)aDecoder;
{
   self = [super initWithCoder:aDecoder];
   [aDecoder decodeValueOfObjCType:@encode(ORLong) at:&_nb];
   _x = malloc(sizeof(CPIntVarI*)*_nb);   
   for(ORInt k=0;k<_nb;k++) 
      _x[k] = [aDecoder decodeObject];
   return self;
}
@end


@implementation CPIntVarMinimize
{
   CPIntVarI*  _x;
   ORInt        _primalBound;
}
-(CPIntVarMinimize*) initCPIntVarMinimize: (CPIntVarI*) x
{
   self = [super initCPCoreConstraint];
   _x = x;
   _primalBound = MAXINT;
   return self;
}
-(id<CPIntVar>)var
{
   return _x;
}
- (void) dealloc
{
    [super dealloc];
}

-(ORStatus) post
{
  if (![_x bound]) 
    [_x whenChangeMinDo: ^ {
       [_x updateMax: _primalBound - 1];
    } onBehalf:self];
  return ORSuspend;
}
-(NSSet*)allVars
{
   return [[NSSet alloc] initWithObjects:_x, nil];
}
-(ORUInt)nbUVars
{
   return [_x bound] ? 0 : 1;
}

-(void) updatePrimalBound
{
   ORInt bound = [_x min];
   @synchronized(self) {
      if (bound < _primalBound)
         _primalBound = bound;
   }
}
-(void) tightenPrimalBound:(ORInt)newBound
{
   @synchronized(self) {
      if (newBound < _primalBound)
         _primalBound = newBound;
   }
}

-(ORStatus) check 
{
   @try {
      [_x updateMax: _primalBound - 1];
   }
   @catch (ORFailException* e) {
      [e release];
      return ORFailure;
   }
   return ORSuspend;
}
-(ORInt) primalBound
{
  return _primalBound;
}
@end


@implementation CPIntVarMaximize
{
   CPIntVarI*  _x;
   ORInt        _primalBound;
}

-(CPIntVarMaximize*) initCPIntVarMaximize: (CPIntVarI*) x
{
   self = [super initCPCoreConstraint];
   _x = x;
   _primalBound = -MAXINT;
   return self;
}

- (void) dealloc
{
    [super dealloc];
}
-(id<CPIntVar>)var
{
   return _x;
}
-(ORStatus) post
{
  if (![_x bound]) 
    [_x whenChangeMaxDo: ^ {  [_x updateMin: _primalBound]; } onBehalf:self];
  return ORSuspend;
}

-(NSSet*)allVars
{
   return [[NSSet alloc] initWithObjects:_x, nil];
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
}

-(void) tightenPrimalBound:(ORInt)newBound
{
   if (newBound > _primalBound)
      _primalBound = newBound;
}

-(ORStatus) check 
{
   @try {
      [_x updateMin: _primalBound + 1];   
   }
   @catch (ORFailException* e) {
      [e release];
      return ORFailure;
   }
   return ORSuspend;  
}

-(ORInt) primalBound
{
  return _primalBound;
}
@end
