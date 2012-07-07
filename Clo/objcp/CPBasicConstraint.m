/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import "CPBasicConstraint.h"
#import "ORFoundation/ORArrayI.h"
#import "CPIntVarI.h"
#import "CPArrayI.h"
#import "CPSolverI.h"

@implementation CPEqualc
-(id) initCPEqualc:(id)x and:(CPInt)c
{
   self = [super initCPActiveConstraint:[x solver]];
   _x = x;
   _c = c;
   return self;
}

-(void) dealloc
{
   //NSLog(@"@dealloc CPEqualc %@ == %d  (self=%p)\n",_x,_c,self);
   [super dealloc];
}

-(CPStatus)post
{
   return [_x bind: _c];
}
-(NSSet*)allVars
{
   return [[NSSet alloc] initWithObjects:_x,nil];
}
-(CPUInt)nbUVars
{
   return ![_x bound];
}

-(NSString*)description
{
   return [NSString stringWithFormat:@"<CPEqualc: %@ == %d>",_x,_c];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
   [super encodeWithCoder:aCoder];
   [aCoder encodeObject:_x];
   [aCoder encodeValueOfObjCType:@encode(CPInt) at:&_c];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
   self = [super initWithCoder:aDecoder];
   _x = [[aDecoder decodeObject] retain];
   [aDecoder decodeValueOfObjCType:@encode(CPInt) at:&_c];
   return self;
}
@end

@implementation CPDiffc
-(id) initCPDiffc:(id)x and:(CPInt)c
{
   self = [super initCPActiveConstraint:[x solver]];
   _x = x;
   _c = c;
   return self;
}

-(void) dealloc
{
   //NSLog(@"@dealloc CPDiffc %@ != %d  (self=%p)\n",_x,_c,self);
   [super dealloc];
}

-(CPStatus)post
{
   return [_x remove:_c];
}

-(NSSet*)allVars
{
   return [[NSSet alloc] initWithObjects:_x,nil];
}
-(CPUInt)nbUVars
{
   return ![_x bound];
}

-(NSString*)description
{
   return [NSString stringWithFormat:@"<CPDiffc: %@ != %d>",_x,_c];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
   [super encodeWithCoder:aCoder];
   [aCoder encodeObject:_x];
   [aCoder encodeValueOfObjCType:@encode(CPInt) at:&_c];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
   self = [super initWithCoder:aDecoder];
   _x = [aDecoder decodeObject];
   [aDecoder decodeValueOfObjCType:@encode(CPInt) at:&_c];
   return self;
}
@end

@implementation CPEqualBC

-(id) initCPEqualBC: (id) x and: (id) y  and: (CPInt) c
{
   self = [super initCPActiveConstraint:[x solver]];
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
-(CPUInt)nbUVars
{
   return ![_x bound] + ![_y bound];
}

-(CPStatus) post
{
   if (![_x bound] || ![_y bound]) {
       [_x whenChangeBoundsPropagate: self];
       [_y whenChangeBoundsPropagate: self];
   }
   [self propagate];
   return CPSuspend;
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
   [aCoder encodeValueOfObjCType:@encode(CPInt) at:&_c];
}

- (id)initWithCoder:(NSCoder *)aDecoder;
{
   self = [super initWithCoder:aDecoder];
   _x = [aDecoder decodeObject];
   _y = [aDecoder decodeObject];
   [aDecoder decodeValueOfObjCType:@encode(CPInt) at:&_c];
   return self;
}
@end


@implementation CPEqualDC
-(id) initCPEqualDC: (id) x and: (id) y  and: (CPInt) c
{
   self = [super initCPActiveConstraint:[x solver]];
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
-(CPUInt)nbUVars
{
   return ![_x bound] + ![_y bound];
}
-(CPStatus) post
{
   CPStatus ok = CPSuspend;
   if (bound(_x)) {
      ok = [_y bind:minDom(_x) - _c];
   } else if (bound(_y)) {
      ok = [_x bind:minDom(_y) + _c];
   } else {
      ok = [_x updateMin:[_y min]+_c andMax:[_y max] + _c];
      if (ok) [_y updateMin:[_x min] - _c andMax:[_x max] - _c];
      if (ok) {
         CPBounds bx = bounds(_x);
         CPBounds by = bounds(_y);
         for(CPInt i = bx.min; (i <= bx.max) && ok; i++)
            if (![_x member:i])
               ok = [_y remove:i - _c];
         for(CPInt i = by.min; (i <= by.max) && ok; i++)
            if (![_y member:i])
               ok = [_x remove:i + _c];
      }
      if (ok) {
         [_x whenLoseValue:self do:^(CPInt val) {
            [_y remove: val - _c];
         }];
         [_y whenLoseValue:self do:^(CPInt val) {
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
   return CPSuspend;
}
-(void) propagate
{
   do {
      if (bound(_x)) {
         [_y bind:minDom(_x) - _c];
      } else if (bound(_y)) {
         [_x bind:minDom(_y) + _c];
      } else {
         _todo = CPChecked;
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
   [aCoder encodeValueOfObjCType:@encode(CPInt) at:&_c];
}

- (id)initWithCoder:(NSCoder *)aDecoder;
{
   self = [super initWithCoder:aDecoder];
   _x = [aDecoder decodeObject];
   _y = [aDecoder decodeObject];
   [aDecoder decodeValueOfObjCType:@encode(CPInt) at:&_c];
   return self;
}
@end

@implementation CPEqual3DC
-(id) initCPEqual3DC: (id) x plus: (id) y  equal: (id) z
{
   self = [super initCPActiveConstraint:[x solver]];
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
-(CPUInt)nbUVars
{
   return ![_x bound] + ![_y bound] + ![_z bound];
}
static inline TRIntArray createSupport(CPIntVarI* v)
{
   return makeTRIntArray([[[v cp] solver] trail], [v max] - [v min] + 1, [v min]);
}
static CPStatus constAddScanB(CPInt a,CPBitDom* bd,CPBitDom* cd,CPIntVarI* c,TRIntArray cs) // a + D(b) IN D(c)
{   
   CPInt min = minCPDom(bd),max = maxCPDom(bd);
   for(CPInt j=min;j<=max;j++) {
      if (!getCPDom(bd,j)) continue;
      CPInt t = a + j;
      if (memberCPDom(cd, t)) {
         CPInt cv = assignTRIntArray(cs, t, getTRIntArray(cs, t) - 1);
         if (cv == 0) {
            removeDom(c, t);            
         }         
      }
   }
   return CPSuspend;
}
static CPStatus constSubScanB(CPInt a,CPBitDom* bd,CPBitDom* cd,CPIntVarI* c,TRIntArray cs) // a - D(b) IN D(c)
{
   CPInt min = minCPDom(bd),max = maxCPDom(bd);
   for(CPInt j=min;j<=max;j++) {
      if (!getCPDom(bd,j)) continue;
      CPInt t = a - j;
      if (memberCPDom(cd, t)) {
         CPInt cv = assignTRIntArray(cs, t, getTRIntArray(cs, t) - 1);
         if (cv == 0) { 
            removeDom(c, t);
         }         
      }
   }
   return CPSuspend;
}
static CPStatus scanASubConstB(CPBitDom* ad,CPInt b,CPBitDom* cd,CPIntVarI* c,TRIntArray cs)  // D(a) - b IN D(c)
{
   CPInt min = minCPDom(ad),max = maxCPDom(ad);
   for(CPInt j=min;j<=max;j++) {
      if (!getCPDom(ad,j)) continue;
      CPInt t = j - b;
      if (memberCPDom(cd, t)) {
         CPInt cv = assignTRIntArray(cs, t, getTRIntArray(cs, t) - 1);
         if (cv == 0) {
            removeDom(c, t);
         }         
      }
   }
   return CPSuspend;
}

-(CPStatus)pruneVar:(CPIntVarI*) v flat:(CPBitDom*) vd support:(TRIntArray) vs
{
   CPInt min = minCPDom(vd),max = maxCPDom(vd);
   for(CPInt i = min;i <= max;i++) {
      if (memberCPDom(vd, i) && getTRIntArray(vs, i) == 0) {
         setCPDom(vd, i, NO);
         [v remove:i];
      }
   }
   if (v == _x) {
      [_x whenLoseValue:self do:^(CPInt val) {
         setCPDom(_fx, val, NO);
         assignTRIntArray(_xs, val, 0);            
         constAddScanB(val,_fy,_fz,_z,_zs);   // xc + D(y) in D(z)
         scanASubConstB(_fz,val,_fy,_y,_ys);   // D(z) - xc in D(y)
      }];      
   } else if (v == _y) {
      [_y whenLoseValue:self do:^(CPInt val) {
         setCPDom(_fy, val, NO);
         assignTRIntArray(_ys, val, 0);            
         constAddScanB(val,_fx,_fz,_z,_zs);  // yc + D(x) in D(z)
         scanASubConstB(_fz,val,_fx,_x,_xs);  // D(z) - yc in D(x)
      }];
   } else {
      [_z whenLoseValue:self do:^(CPInt val) {
         setCPDom(_fz, val, NO);
         assignTRIntArray(_zs, val, 0);            
         constSubScanB(val,_fx,_fy,_y,_ys);  // zc - D(x) in D(y)
         constSubScanB(val,_fy,_fx,_x,_xs);   // zc - D(y) in D(x)
      }];
   }
   return CPSuspend;
}

-(CPStatus) post
{
   [self propagate];
   _fx = [_x flatDomain];
   _fy = [_y flatDomain];
   _fz = [_z flatDomain];
   _xs = createSupport(_x);
   _ys = createSupport(_y);
   _zs = createSupport(_z);
   CPInt minX = minCPDom(_fx),maxX = maxCPDom(_fx);
   CPInt minY = minCPDom(_fy),maxY = maxCPDom(_fy);
   CPInt minZ = minCPDom(_fz),maxZ = maxCPDom(_fz);
   for(CPInt i = minX;i <= maxX;i++) {
      if (memberCPDom(_fx, i)) {
         for(CPInt j=minY;j <= maxY;j++) {
            if (memberCPDom(_fy, j)) {
               CPInt v = i + j;
               if (memberCPDom(_fz, v)) 
                  assignTRIntArray(_zs, v, getTRIntArray(_zs, v) + 1);
            }
         }
      }
   }   
   for(CPInt i = minZ;i <= maxZ;i++) {
      if (memberCPDom(_fz, i)) {
         for(CPInt j=minX;j <= maxX;j++) {
            if (memberCPDom(_fx, j)) {
               CPInt v = i - j;
               if (memberCPDom(_fy, v)) 
                  assignTRIntArray(_ys, v, getTRIntArray(_ys, v) + 1);
            }
         }
         for(CPInt j=minY;j <= maxY;j++) {
            if (memberCPDom(_fy, j)) {
               CPInt v = i - j;
               if (memberCPDom(_fx, v)) 
                  assignTRIntArray(_xs, v, getTRIntArray(_xs, v) + 1);
            }
         }
      }
   }
   [self pruneVar:_x flat:_fx support:_xs];  
   [self pruneVar:_y flat:_fy support:_ys];
   [self pruneVar:_z flat:_fz support:_zs];
   return CPSuspend;   
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
         CPBounds xb = bounds(_x),yb = bounds(_y),zb = bounds(_z);      
         CPInt lb = xb.min + yb.min;
         CPInt ub = xb.max + yb.max;
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

-(id)initCPNotEqual:(id) x and:(id) y  and: (CPInt) c
{
   self = [super initCPActiveConstraint:[x solver]];
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
-(CPUInt)nbUVars
{
   return ![_x bound] + ![_y bound];
}

-(CPStatus) post // x != y + c
{
   if ([_x bound])
      return [_y remove:minDom(_x) - _c];
   else if ([_y bound])
      return [_x remove:minDom(_y) + _c];
   else {
       [_x whenBindPropagate: self]; 
       [_y whenBindPropagate: self];
   }
   return CPSuspend;
}

-(void) propagate
{
   if (!_active._val) return;
   assignTRInt(&_active, NO, _trail);
   if ([_x bound])
      [_y remove:[_x min] - _c];
   else 
      [_x remove:[_y min] + _c];
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
   [aCoder encodeValueOfObjCType:@encode(CPInt) at:&_c];
}

- (id)initWithCoder:(NSCoder *)aDecoder;
{
   self = [super initWithCoder:aDecoder];
   _x = [aDecoder decodeObject];
   _y = [aDecoder decodeObject];
   [aDecoder decodeValueOfObjCType:@encode(CPInt) at:&_c];
   return self;
}
@end

@implementation CPBasicNotEqual
-(id) initCPBasicNotEqual:(id)x and:(id) y
{
   self = [super initCPActiveConstraint:[x solver]];
   _x = x;
   _y = y;
   return self;
}
-(void)dealloc
{ 
   [super dealloc];
}
-(CPStatus) post
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
      return CPSuspend;
   }
}
-(NSSet*)allVars
{
   return [[NSSet alloc] initWithObjects:_x,_y,nil];
}
-(CPUInt)nbUVars
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
-(id) initCPLEqualBC:(id)x and:(id) y
{
   self = [super initCPActiveConstraint:[x solver]];
   _x = x;
   _y = y;
   return self;   
}
-(CPStatus) post  // x <= y
{
   [self propagate];
   if (!bound(_x))
      [_x whenChangeMinPropagate: self];
   if (!bound(_y))
      [_y whenChangeMaxPropagate: self];
   [self propagate];   
   return CPSuspend;
}
-(void) propagate
{
   [_x updateMax:[_y max]];
   [_y updateMin:[_x min]];
}
-(NSSet*)allVars
{
   return [[NSSet alloc] initWithObjects:_x,_y,nil];
}
-(CPUInt)nbUVars
{
   return ![_x bound] + ![_y bound];   
}
-(NSString*)description
{
   return [NSMutableString stringWithFormat:@"<CPLEqualBC: %02d %@ <= %@>",_name,_x,_y];
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

@implementation CPAbsDC
-(id)initCPAbsDC:(id)x equal:(id)y
{
   self = [super initCPActiveConstraint:[x solver]];
   _x = x;
   _y = y;
   return self;
}
-(CPStatus) post
{
   if (bound(_x)) {
      return [_y bind:abs(minDom(_x))];
   }
   CPBounds xb = bounds(_x);
   int mxy = max( - xb.min,xb.max);
   [_y updateMin:0 andMax:mxy];
   [_x updateMin:-mxy andMax:mxy];
   CPBounds yb = bounds(_y);
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
      [_x whenLoseValue:self do:^(CPInt val) {
         if (!memberDom(_x, -val)) { 
            [_y remove:abs(val)];
         } 
      }];
      [_x whenBindDo:^{
         [_y bind:abs(minDom(_x))];
      } onBehalf:self];
   }
   if (!bound(_y)) {
      [_y whenLoseValue:self do:^(CPInt val) {
         [_x remove:val];
         [_x remove:-val];
      }];
      [_y whenBindDo:^{
         CPInt val = minDom(_y);
         if (!memberDom(_x, val) && !memberDom(_x, -val)) {
            failNow();
         }
         else if (memberDom(_x, val) ^ memberDom(_x, -val)) {
            [_x bind:memberDom(_x, val) ? val : -val];
         } else {
            CPBounds xb = bounds(_x);
            for(int k=xb.min; k <= xb.max;k++)
               if (k != val && k != - val)
                  [_x remove:k];
         }
      }  onBehalf:self];
   }
   return CPSuspend;
}
-(NSSet*)allVars
{
   return [[NSSet alloc] initWithObjects:_x,_y,nil];
}
-(CPUInt)nbUVars
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
-(id)initCPAbsBC:(id)x equal:(id)y
{
   self = [super initCPActiveConstraint:[x solver]];
   _x = x;
   _y = y;
   _idempotent = YES;
   return self;
}
-(CPStatus) post
{
   [self propagate];
   if (!bound(_x)) [_x whenChangeBoundsPropagate:self];
   if (!bound(_y)) [_y whenChangeBoundsPropagate:self];
   return CPSuspend;
}
-(void) propagate
{
   do {
      _todo = CPChecked;
      CPBounds xb = bounds(_x);
      CPInt  ub = - xb.min > xb.max ? -xb.min  : xb.max;
      BOOL  cZ = xb.min < 0 && xb.max > 0;
      if (cZ) {
         CPRange aZ = [_x around:0];
         CPInt lb = min(-aZ.low,aZ.up);
         [_y updateMin:lb andMax:ub];
      } else if (xb.min >= 0) {
         [_y updateMin:xb.min andMax:xb.max];
         [_x updateMin:minDom(_y)];
      } else {
         [_y updateMin:-xb.max andMax:-xb.min];
         [_x updateMax:-minDom(_y)];
      }
      CPBounds yb = bounds(_y);
      [_x updateMin:-yb.max andMax:yb.max];
   } while(_todo == CPTocheck);
}
-(NSSet*)allVars
{
   return [[NSSet alloc] initWithObjects:_x,_y, nil];
}
-(CPUInt)nbUVars
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

@implementation CPLEqualc
-(id) initCPLEqualc:(id)x and:(CPInt) c
{
   self = [super initCPActiveConstraint: [x solver]];
   _x = x;
   _c = c;
   return self;
}
-(CPStatus) post
{
   return [_x updateMax:_c];
}
-(NSSet*)allVars
{
   return [[NSSet alloc] initWithObjects:_x,nil];   
}
-(CPUInt)nbUVars
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
   [aCoder encodeValueOfObjCType:@encode(CPInt) at:&_c];
}

- (id)initWithCoder:(NSCoder *)aDecoder;
{
   self = [super initWithCoder:aDecoder];
   _x = [aDecoder decodeObject];
   [aDecoder decodeValueOfObjCType:@encode(CPInt) at:&_c];
   return self;
}
@end


@implementation CPMultBC
-(id) initCPMultBC:(id)x times:(id)y equal:(id)z
{
   self = [super initCPActiveConstraint:[x solver]];
   _x = x;
   _y = y;
   _z = z;
   return self;
}
-(void)dealloc
{
   [super dealloc];
}
static inline CPInt minDiv(CPLong c,CPLong d1,CPLong d2)  {
   const CPLong rd1 = c % d1,rd2 = c % d2;
   const CPLong q1 = c / d1 + (rd1 && d1*c>0); 
   const CPLong q2 = c / d2 + (rd2 && d2*c>0);
   return bindDown(q1 < q2 ? q1 : q2);
}
static inline CPInt maxDiv(CPLong c,CPLong d1,CPLong d2)  { 
   const CPLong rd1 = c % d1,rd2 = c % d2;
   const CPLong q1 = c / d1 - (rd1 && d1*c<0); 
   const CPLong q2 = c / d2 - (rd2 && d2*c<0); 
   return bindUp(q1 > q2 ? q1 : q2);
}
static inline CPLong minSeq(CPLong v[4])  {
   CPLong min = MAXINT;
   for(int i=0;i<4;i++)
      min = min > v[i] ? v[i] : min;
   return min;
}
static inline CPLong maxSeq(CPLong v[4])  {
   CPLong mx = MININT;
   for(int i=0;i<4;i++)
      mx = mx < v[i] ? v[i] : mx;
   return mx;
}
static inline int minDiv4(CPLong a,CPLong b,CPLong c,CPLong d) { 
   const CPLong acr = a%c && a*c>0;
   const CPLong adr = a%d && a*d>0;
   const CPLong bcr = b%c && b*c>0;
   const CPLong bdr = b%d && b*d>0;
   return bindDown(minSeq((CPLong[4]){a/c+acr,a/d+adr,b/c+bcr,b/d+bdr}));
}
static inline int maxDiv4(CPLong a,CPLong b,CPLong c,CPLong d) { 
   const CPLong acr = a%c && a*c<0;
   const CPLong adr = a%d && a*d<0;
   const CPLong bcr = b%c && b*c<0;
   const CPLong bdr = b%d && b*d<0;
   return bindUp(maxSeq((CPLong[4]){a/c-acr,a/d-adr,b/c-bcr,b/d-bdr}));
}
// RXC:  Range | Variable | Constant
static CPStatus propagateRXC(CPMultBC* mc,CPBounds r,CPIntVarI* x,CPInt c)
{
   CPInt a = r.min,b = r.max;
   if (a > 0 || b < 0) {
      [x updateMin:minDiv(c,a,b) andMax:maxDiv(c,a,b)];
   } else if (a==0 || b == 0) {
      CPRange az = [x around:0];
      int s = a==0 ? az.up  : az.low;
      int l = a==0 ? b : a;
      [x updateMin:minDiv(c,s,l) andMax:maxDiv(c,s,l)];
   } else {
      CPRange az = [x around:0];
      CPInt xm1 = minDiv(c,az.low,az.up);
      CPInt xM1 = maxDiv(c,az.low,az.up);
      CPInt xm2 = minDiv(c,a,b);
      CPInt xM2 = maxDiv(c,a,b);
      CPInt xm = xm1 < xm2 ? xm1 : xm2;
      CPInt xM = xM1 > xM2 ? xM1 : xM2;
      [x updateMin:xm andMax:xM];
   }
   return CPSuspend;
}
-(void) propagateCXZ:(CPLong)c mult:(CPIntVarI*)x equal:(CPBounds)zb
{
   int nz = ![_z member:0];
   int newMin = zb.min/c + (nz && zb.min >= 0 && zb.min % c);
   int newMax = zb.max/c - (nz && zb.max <  0 && zb.max % c);
   [x updateMin:newMin andMax:newMax];
}
-(CPStatus) postCX:(CPLong)c mult:(CPIntVarI*)x equal:(CPIntVarI*)z 
{
   if ([x bound])
      return [z bind:bindDown(c * [x min])];
   else {
      if (c > 0) {
         CPInt newMax  = bindUp(c * [x max]);
         CPInt newMin  = bindDown(c * [x min]);
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
      return CPSuspend;
   }
}
static CPStatus propagateCX(CPMultBC* mc,CPLong c,CPIntVarI* x,CPIntVarI* z)
{
   if ([x bound]) {
      return [z bind:bindDown(c * [x min])];
   } else {
      if (c > 0) {
         CPInt newMax  = bindUp(c * [x max]);
         CPInt newMin  = bindDown(c * [x min]);
         [z updateMin:newMin andMax:newMax];
         [mc propagateCXZ:c mult:x equal:bounds(z)];
      } else if (c == 0) {
         [z bind:0];
      } else {
         [z updateMin:bindDown(c * [x max]) andMax:bindDown(c * [x min])];
         [mc propagateCXZ:-c mult:x equal:negBounds(z)]; 
      }
      return CPSuspend;
   }
}

-(void) propagateXCR:(CPIntVarI*)x mult:(CPIntVarI*)y equal:(CPBounds)r
{
   CPInt a = r.min,b=r.max;
   CPInt c = [y min],d = [y max];
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
            CPRange az = [y around:0]; // around zero            
            int s = c==0 ? az.up : az.low;
            int l = c==0 ? d : c;
            [x updateMin:minDiv4(a,b,s,l) andMax:maxDiv4(a,b,s,l)];
         } else {
            CPRange az = [y around:0]; // around zero
            CPInt xm1 = minDiv4(a,b,az.low,az.up);
            CPInt xM1 = maxDiv4(a,b,az.low,az.up);
            CPInt xm2 = minDiv4(a,b,c,d);
            CPInt xM2 = maxDiv4(a,b,c,d);
            CPInt xm = xm1 < xm2 ? xm1 : xm2;
            CPInt xM = xM1 > xM2 ? xM1 : xM2;
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
   CPBounds xb,yb,zb;
   [_x bounds:&xb];
   [_y bounds:&yb];
   CPLong t[4] = {xb.min*yb.min,xb.min*yb.max,xb.max*yb.min,xb.max*yb.max};
   [_z updateMin:bindDown(minSeq(t)) andMax:bindUp(maxSeq(t))];
   [_z bounds:&zb];
   [self propagateXCR:_x mult:_y equal:zb];
   [self propagateXCR:_y mult:_x equal:zb];
}
-(CPStatus) post
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
         } else failNow();
      } else { 
         propagateRXC(self,bounds(_x),_y,[_z min]);
         propagateRXC(self,bounds(_y),_x,[_z min]);
         if (![_x bound]) [_x whenChangeBoundsPropagate:self];
         if (![_y bound]) [_y whenChangeBoundsPropagate:self];
      }
      return CPSuspend;
   } else { 
      [self propagateXYZ];
      [_x whenChangeBoundsPropagate:self];
      [_y whenChangeBoundsPropagate:self];
      [_z whenChangeBoundsPropagate:self];
      return CPSuspend;
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
         } else failNow();
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
-(CPUInt)nbUVars
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


@implementation CPAllDifferenceVC
-(id) initCPAllDifferenceVC:(CPIntVarI**)x nb:(CPInt) n
{
   self = [super init];
   _x = x;
   _nb = n;
   return self;
}
-(id) initCPAllDifferenceVC:(id) x
{
   if ([x isKindOfClass:[NSArray class]]) {
      id<CPSolver> fdm = [[x objectAtIndex:0] solver];
      self = [super initCPActiveConstraint:fdm];
      _nb = [x count];
      _x = malloc(sizeof(CPIntVarI*)*_nb);
      for(CPInt k=0;k<_nb;k++)
         _x[k] = [x objectAtIndex:k];
   } 
   else if ([x isKindOfClass:[ORIdArrayI class]]) {
      id<CPIntVarArray> xa = x;
      id<CPSolver> fdm = [[xa cp] solver];
      self = [super initCPActiveConstraint:fdm];
      _nb = [x count];
      _x  = malloc(sizeof(CPIntVarI*)*_nb);
      int i =0;
      for(CPInt k=[x low];k <= [x up];k++)
         _x[i++] = (CPIntVarI*) [xa at:k];
   }      
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
-(CPUInt)nbUVars
{
   CPUInt nb=0;
   for(CPUInt k=0;k<_nb;k++)
      nb += ![_x[k] bound];
   return nb;
}

-(CPStatus) post 
{
   bool ok = true;
   CPLong low  = 0,up = _nb - 1;
   CPInt minX = MAXINT,maxX = MININT;
   for(CPInt k=0;k<_nb;k++) {
      minX = min(minX,[_x[k] min]);
      maxX = max(maxX,[_x[k] max]);
   }
   CPInt* vCnt = alloca(sizeof(CPInt)*(maxX-minX+1));
   CPInt* vUse = alloca(sizeof(CPInt)*(maxX-minX+1));
   memset(vCnt,0,sizeof(CPInt)*(maxX-minX+1));
   vCnt -= minX;
   CPInt nbBoundVal = 0;
   for(CPLong k=low;k<=up;k++) {
      if ([_x[k] bound]) {
         CPInt to = [_x[k] min];
         vCnt[to]++;
         ok &= vCnt[to] < 2;
         vUse[nbBoundVal++] = to;
      }
   }
   if (!ok) failNow();
   
   for(CPLong k=low;k<=up && ok;k++) {
      if ([_x[k] bound])
         continue;
      for(CPInt j=0;j<nbBoundVal;j++) {
         [_x[k] remove: vUse[j]];
      }
      SEL minSEL = @selector(min);
      IMP minIMP = [_x[k] methodForSelector:minSEL];
      [_x[k] whenBindDo: ^ {
         //int vk = [_x[k] min];
         CPInt vk = (CPInt) minIMP(_x[k],minSEL);
         for(CPLong i=up;i;--i) {
            if (i == k) 
               continue;
            [_x[i] remove:vk];
         }
      } onBehalf:self];
   }
   return CPSuspend;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
   [super encodeWithCoder:aCoder];   
   [aCoder encodeValueOfObjCType:@encode(CPLong) at:&_nb];
   for(CPInt k=0;k<_nb;k++) 
      [aCoder encodeObject:_x[k]];
}

- (id)initWithCoder:(NSCoder *)aDecoder;
{
   self = [super initWithCoder:aDecoder];
   [aDecoder decodeValueOfObjCType:@encode(CPLong) at:&_nb];
   _x = malloc(sizeof(CPIntVarI*)*_nb);   
   for(CPInt k=0;k<_nb;k++) 
      _x[k] = [aDecoder decodeObject];
   return self;
}
@end


@implementation CPIntVarMinimize

-(CPIntVarMinimize*) initCPIntVarMinimize: (CPIntVarI*) x
{
   self = [super initCPCoreConstraint];
   _x = x;
   _primalBound = MAXINT;
   return self;
}

- (void) dealloc
{
    [super dealloc];
}

-(CPStatus) post
{
  if (![_x bound]) 
    [_x whenChangeMinDo: ^ { [_x updateMax: _primalBound]; } onBehalf:self];
  return CPSuspend;
}
-(NSSet*)allVars
{
   return [[NSSet alloc] initWithObjects:_x, nil];
}
-(CPUInt)nbUVars
{
   return [_x bound] ? 0 : 1;
}

-(void) updatePrimalBound
{
  CPInt bound = [_x min];
  if (bound < _primalBound) 
    _primalBound = bound;

}
-(CPStatus) check 
{
  return [_x updateMax: _primalBound - 1];    
}
-(CPInt) primalBound
{
  return _primalBound;
}
@end


@implementation CPIntVarMaximize

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

-(CPStatus) post
{
  if (![_x bound]) 
    [_x whenChangeMaxDo: ^ {  [_x updateMin: _primalBound]; } onBehalf:self];
  return CPSuspend;
}

-(NSSet*)allVars
{
   return [[NSSet alloc] initWithObjects:_x, nil];
}
-(CPUInt)nbUVars
{
   return [_x bound] ? 0 : 1;
}

-(void) updatePrimalBound
{
  CPInt bound = [_x max];
  if (bound > _primalBound) 
    _primalBound = bound;
}

-(CPStatus) check 
{
  return [_x updateMin: _primalBound + 1];    
}

-(CPInt) primalBound
{
  return _primalBound;
}
@end
