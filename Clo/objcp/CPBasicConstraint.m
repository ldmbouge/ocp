/************************************************************************
 MIT License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 Permission is hereby granted, free of charge, to any person obtaining
 a copy of this software and associated documentation files (the
 "Software"), to deal in the Software without restriction, including
 without limitation the rights to use, copy, modify, merge, publish,
 distribute, sublicense, and/or sell copies of the Software, and to
 permit persons to whom the Software is furnished to do so, subject to
 the following conditions:
 
 The above copyright notice and this permission notice shall be
 included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 ***********************************************************************/

#import "CPBasicConstraint.h"
#import "CPIntVarI.h"
#import "CPArrayI.h"
#import "CPSolverI.h"

static inline CPBounds bounds(CPIntVarI* x)
{
   CPBounds b;
   [x bounds:&b];
   return b;
}
static inline CPBounds negBounds(CPIntVarI* x)
{
   CPBounds b;
   [x bounds:&b];
   return (CPBounds){- b.max, -b.min};
}

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
   return [self propagate];
}

-(CPStatus) propagate
{
    CPStatus ok;
    if ([_x bound]) {
        return [_y bind:[_x min] - _c];
    } 
    else if ([_y bound]) {
        return [_x bind:[_y min] + _c];
    } 
    else {
       ok = [_x updateMin:[_y min] + _c andMax:[_y max] + _c];
       if (ok) 
          ok = [_y updateMin:[_x min] - _c andMax:[_x max] - _c];
    }
    return ok;
}
-(NSString*)description
{
   return [NSMutableString stringWithFormat:@"<CPEqualBC:%02ld %@ == %@ + %d>",_name,_x,_y,_c];
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
         [_x whenLoseValue:self do:^CPStatus(CPInt val) {
            return [_y remove: val - _c];
         }];
         [_y whenLoseValue:self do:^CPStatus(CPInt val) {
            return [_x remove: val + _c];
         }];
         [_x whenBindDo:^CPStatus{
            return [_y bind:minDom(_x) - _c];
         } onBehalf:self];
         [_y whenBindDo:^CPStatus{
            return [_x bind:minDom(_x) + _c];
         } onBehalf:self];
      }
   }
   return [self propagate];
}
-(CPStatus) propagate
{
   CPStatus ok = CPSuspend;
   do {
      if (bound(_x)) {
         ok = [_y bind:minDom(_x) - _c];
      } else if (bound(_y)) {
         ok = [_x bind:minDom(_y) + _c];
      } else {
         _todo = CPChecked;
         ok = [_x updateMin:[_y min]+_c andMax:[_y max] + _c];
         if (ok) [_y updateMin:[_x min] - _c andMax:[_x max] - _c];
      }
   } while (ok && _todo == CPTocheck);
   return ok;   
}
-(NSString*)description
{
   return [NSMutableString stringWithFormat:@"<CPEqualDC:%02ld %@ == %@ + %d>",_name,_x,_y,_c];
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
   _fx = _fy = _fz = nil;
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
static TRIntArray createSupport(CPIntVarI* v)
{
   int vsz = [v max] - [v min] + 1;
   TRIntArray rv = makeTRIntArray([[[v cp] solver] trail], vsz, [v min]);
   return rv;
}
static CPStatus pruneVar(CPIntVarI* v,CPDomain* vd,TRIntArray vs)
{
   CPStatus ok = [vd scanWith:^CPStatus(CPInt i) {
      CPStatus ok = CPSuspend;
      if (getTRIntArray(vs, i) ==0) {
         [vd set:i at:NO];
         ok = [v remove:i];
      }
      return ok;
   }];
   if (ok) {
      //v->addAC5(      
   }
   return ok;
}

-(CPStatus) post
{
   CPStatus ok = [self propagate];
   if (!ok) return ok;  
   _fx = [_x flatDomain];
   _fy = [_y flatDomain];
   _fz = [_z flatDomain];
   _xs = createSupport(_x);
   _ys = createSupport(_y);
   _zs = createSupport(_z);
   [_fx scanWith:^CPStatus(CPInt i) {
      [_fy scanWith:^CPStatus(CPInt j) {
         CPInt v = i + j;
         if ([_fz member:v])
            assignTRIntArray(_zs, v, getTRIntArray(_zs, v) + 1);
         return  CPSuspend;
      }];
      return CPSuspend;
   }];
   [_fz scanWith:^CPStatus(CPInt i) {
      [_fx scanWith:^CPStatus(CPInt j) {
         CPInt v = i - j;
         if ([_fy member:v])
            assignTRIntArray(_ys, v, getTRIntArray(_ys, v) + 1);
         return CPSuspend;
      }];
      return CPSuspend;
   }];
   [_fz scanWith:^CPStatus(CPInt i) {
      [_fy scanWith:^CPStatus(CPInt j) {
         CPInt v = i - j;
         if ([_fx member:v])
            assignTRIntArray(_xs, v, getTRIntArray(_xs, v) + 1);
         return CPSuspend;
      }];
      return CPSuspend;
   }];
   if (ok) ok = pruneVar(_x,_fx,_xs);
   if (ok) ok = pruneVar(_y,_fy,_ys);
   if (ok) ok = pruneVar(_z,_fz,_zs);
   return ok;   
}
-(CPStatus) propagate
{
   CPStatus ok = CPSuspend;
   do {
      if (bound(_x)) {
         if (bound(_y)) {
            return [_z bind:minDom(_x) + minDom(_y)];
         } else if (bound(_z)) {
            return [_y bind:minDom(_z) - minDom(_x)];
         } else { 
            _todo = CPChecked;
            int c = minDom(_x);
            ok = [_y updateMin:minDom(_z) - c andMax:[_z max] - c];
            if (ok) ok = [_z updateMin:minDom(_y)+c andMax:maxDom(_y)+c];
         }
      } else if (bound(_y)) { // _x is NOT bound
         if (bound(_z)) {
            return [_x bind:minDom(_z) - minDom(_y)];
         } else { 
            _todo = CPChecked;
            int c = minDom(_y);
            ok = [_x updateMin:minDom(_z) - c andMax:[_z max] - c];
            if (ok) ok = [_z updateMin:minDom(_x)+c andMax:maxDom(_x)+c];
         }
      } else if (bound(_z)) {  // neither _x NOR _y are bound.
         _todo = CPChecked;
         int c = minDom(_z);
         ok = [_x updateMin:c - maxDom(_y) andMax:c - minDom(_y)];
         if (ok) ok = [_y updateMin:c - maxDom(_x) andMax:c - minDom(_x)];
      } else { 
         _todo = CPChecked;
         CPBounds xb = bounds(_x),yb = bounds(_y),zb = bounds(_z);      
         CPInt t = xb.min + yb.min;
         if (t > zb.min)
            if ([_z updateMin:t] == CPFailure)
               return CPFailure;
         t = xb.max + yb.max;
         if (t < zb.max)
            if ([_z updateMax:t] == CPFailure)
               return CPFailure;
         t = zb.min - yb.max;
         if (t > xb.min)
            if ([_x updateMin:t] == CPFailure)
               return CPFailure;
         t = zb.max - yb.min;
         if (t < xb.max)
            if ([_x updateMax:t] == CPFailure)
               return CPFailure;
         t = zb.min - xb.max;
         if (t > yb.min)
            if ([_y updateMin:t] == CPFailure)
               return CPFailure;
         t = zb.max - xb.min;
         if (t < yb.max)
            if ([_y updateMax:t] == CPFailure)
               return CPFailure;
      }
   } while (_todo == CPTocheck);
   return ok;
}
-(NSString*)description
{
   return [NSMutableString stringWithFormat:@"<CPEqual3DC:%02ld %@ + %@ == %@>",_name,_x,_y,_z];
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

-(CPStatus) propagate
{
   if (!_active._val) 
       return CPSkip;
   assignTRInt(&_active, NO, _trail);
   if ([_x bound])
      return [_y remove:[_x min] - _c] ? CPSuspend : CPFailure;
   else 
      return [_x remove:[_y min] + _c] ? CPSuspend : CPFailure;
}
-(NSString*)description
{
   return [NSMutableString stringWithFormat:@"<CPNotEqual: %02ld %@ != %@ + %d>",_name,_x,_y,_c];
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
      [_x whenBindDo:^CPStatus{
         if (!_active._val) return CPSkip;
         assignTRInt(&_active, NO, _trail);
         return [_y remove:minDom(_x)];
      } priority:HIGHEST_PRIO onBehalf:self];
      [_y whenBindDo:^CPStatus{
         if (!_active._val) return CPSkip;
         assignTRInt(&_active, NO, _trail);
         return [_x remove:minDom(_y)];
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
   return [NSMutableString stringWithFormat:@"<CPBasicNotEqual: %02ld %@ != %@>",_name,_x,_y];
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
   CPStatus ok = [self propagate];
   if (ok) {
      if (!bound(_x))
         [_x whenChangeMinPropagate: self];
      if (!bound(_y))
         [_y whenChangeMaxPropagate: self];
   }
   return [self propagate];   
}
-(CPStatus) propagate
{
   CPStatus s = [_x updateMax:[_y max]];
   if (s != CPFailure)
      s = [_y updateMin:[_x min]];
   return s;
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
   return [NSMutableString stringWithFormat:@"<CPLEqualBC: %02ld %@ <= %@>",_name,_x,_y];
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
   int mxy = maxOf( - xb.min,xb.max);
   CPStatus ok = [_y updateMin:0 andMax:mxy];
   if (ok)  ok = [_x updateMin:-mxy andMax:mxy];
   if (ok) {
      CPBounds yb = bounds(_y);
      for(int k=yb.min;ok && k<=yb.max;k++) {
         if ([_y member:k]) {
            if (![_x member:k] && ![_y member:k]) 
               if (ok) ok = [_y remove:k];
         } else {
            if (ok) ok = [_x remove:k];
            if (ok) ok = [_x remove:-k];
         }
      }
      yb = bounds(_y);
      for(int k=0;ok && k<yb.min;k++) {  // ----0----y_min-------------y_max----  kill values between 0..y_min
         if ([_x member:k])
            ok = [_x remove:k];
         if ([_x member:-k])
            ok = [_x remove:-k];
      }
      if (ok) {
         if (!bound(_x)) {
            [_x whenLoseValue:self do:^CPStatus(CPInt val) {
               if (![_x member:-val]) {
                  return [_y remove:abs(val)];
               } else return CPSuspend;
            }];
            [_x whenBindDo:^CPStatus{
               return [_y bind:abs(minDom(_x))];
            } onBehalf:self];
         }
         if (!bound(_y)) {
            [_y whenLoseValue:self do:^CPStatus(CPInt val) {
               CPStatus ok = [_x remove:val];
               if (ok)  ok = [_x remove:-val];
               return ok;
            }];
            [_y whenBindDo:^CPStatus{
               CPInt val = minDom(_y);
               if (![_x member:val] && ![_x member:-val])
                  return CPFailure;
               else if ([_x member:val] ^ [_x member:-val]) {
                  return [_x bind:[_x member:val] ? val : -val];
               } else {
                  CPStatus ok = CPSuspend;
                  CPBounds xb = bounds(_x);
                  for(int k=xb.min;ok && k <= xb.max;k++)
                     if (k != val && k != - val)
                        ok = [_x remove:k];
                  return ok ? CPSuccess : CPFailure;
               }
            }  onBehalf:self];
         }
      }
      return ok;
   } else return CPFailure;
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
   return [NSMutableString stringWithFormat:@"<CPAbsDC: %02ld %@ = abs(%@)>",_name,_y,_x];
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
   CPStatus ok = [self propagate];
   if (ok && !bound(_x)) [_x whenChangeBoundsPropagate:self];
   if (ok && !bound(_y)) [_y whenChangeBoundsPropagate:self];
   return ok;
}
-(CPStatus) propagate
{
   CPStatus ok = CPSuspend;
   do {
      _todo = CPChecked;
      CPBounds xb = bounds(_x);
      CPInt  ub = - xb.min > xb.max ? -xb.min  : xb.max;
      BOOL  cZ = xb.min < 0 && xb.max > 0;
      if (cZ) {
         CPRange aZ = [_x around:0];
         CPInt lb = minOf(-aZ.low,aZ.up);
         ok = [_y updateMin:lb andMax:ub];
      } else if (xb.min >= 0) {
         ok = [_y updateMin:xb.min andMax:xb.max];
         if (ok) ok = [_x updateMin:minDom(_y)];
      } else {
         ok = [_y updateMin:-xb.max andMax:-xb.min];
         if (ok) ok = [_x updateMax:-minDom(_y)];
      }
      if (ok) {
         CPBounds yb = bounds(_y);
         ok = [_x updateMin:-yb.max andMax:yb.max];
      }
   } while(ok && _todo == CPTocheck);
   return ok;
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
   return [NSMutableString stringWithFormat:@"<CPAbsBC: %02ld %@ == abs(%@)>",_name,_y,_x];
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
   return [NSMutableString stringWithFormat:@"<CPLEqualc: %02ld %@ <= %d>",_name,_x,_c];
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
static inline CPInt bindUp(CPLong a)   { return (a < (CPLong)MAXINT) ? (CPInt)a : MAXINT;}
static inline CPInt bindDown(CPLong a) { return (a > (CPLong)MININT) ? (CPInt)a : MININT;}
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
   CPStatus suc = CPSuspend;
   if (a > 0 || b < 0) {
      if (suc) suc = [x updateMin:minDiv(c,a,b) andMax:maxDiv(c,a,b)];
   } else if (a==0 || b == 0) {
      CPRange az = [x around:0];
      int s = a==0 ? az.up  : az.low;
      int l = a==0 ? b : a;
      if (suc) suc = [x updateMin:minDiv(c,s,l) andMax:maxDiv(c,s,l)];
   } else {
      CPRange az = [x around:0];
      CPInt xm1 = minDiv(c,az.low,az.up);
      CPInt xM1 = maxDiv(c,az.low,az.up);
      CPInt xm2 = minDiv(c,a,b);
      CPInt xM2 = maxDiv(c,a,b);
      CPInt xm = xm1 < xm2 ? xm1 : xm2;
      CPInt xM = xM1 > xM2 ? xM1 : xM2;
      if (suc) suc = [x updateMin:xm andMax:xM];
   }
   return suc ? CPSuspend : CPFailure;
}
-(CPStatus)propagateCXZ:(CPLong)c mult:(CPIntVarI*)x equal:(CPBounds)zb
{
   CPStatus suc = CPSuspend;
   int nz = ![_z member:0];
   int newMin = zb.min/c + (nz && zb.min >= 0 && zb.min % c);
   int newMax = zb.max/c - (nz && zb.max <  0 && zb.max % c);
   if (suc) suc = [x updateMin:newMin andMax:newMax];
   return suc ? CPSuspend : CPFailure;
}
-(CPStatus) postCX:(CPLong)c mult:(CPIntVarI*)x equal:(CPIntVarI*)z 
{
   if ([x bound])
      return [z bind:bindDown(c * [x min])];
   else {
      CPStatus suc = CPSuspend;
      if (c > 0) {
         CPInt newMax  = bindUp(c * [x max]);
         CPInt newMin  = bindDown(c * [x min]);
         if (suc) suc = [z updateMin:newMin andMax:newMax];
         if (suc) suc = [self propagateCXZ:c mult:x equal:bounds(z)];
         if (suc) {
            [z whenChangeBoundsPropagate:self];
            [x whenChangeBoundsPropagate:self];
         }
      } else if (c == 0) {
         if (suc) suc = [z bind:0];
      } else {
         int newMin = bindDown(c * [x max]);
         int newMax = bindUp(c * [x min]);
         if (suc) suc = [z updateMin:newMin andMax:newMax];
         if (suc) suc = [self propagateCXZ:-c mult:x equal:negBounds(z)];
         if (suc) {
            [z whenChangeBoundsPropagate:self];
            [x whenChangeBoundsPropagate:self];
         }
      }
      return suc;
   }
}
static CPStatus propagateCX(CPMultBC* mc,CPLong c,CPIntVarI* x,CPIntVarI* z)
{
   if ([x bound]) {
      return [z bind:c * [x min]];
   } else {
      CPStatus suc = CPSuspend;
      if (c > 0) {
         CPInt newMax  = bindUp(c * [x max]);
         CPInt newMin  = bindDown(c * [x min]);
         if (suc) suc = [z updateMin:newMin andMax:newMax];
         if (suc) suc = [mc propagateCXZ:c mult:x equal:bounds(z)];
         return suc;
      } else if (c == 0) {
         return [z bind:0];
      } else {
         if (suc) suc = [z updateMin:c * [x max] andMax: c * [x min]];
         if (suc) suc = [mc propagateCXZ:-c mult:x equal:negBounds(z)]; 
         return suc;
      }
   }
}

-(CPStatus)propagateXCR:(CPIntVarI*)x mult:(CPIntVarI*)y equal:(CPBounds)r
{
   CPInt a = r.min,b=r.max;
   CPInt c = [y min],d = [y max];
   CPStatus suc = CPSuspend;
   if (c==0 && d==0)  {
      return [_z bind:0];
   } else if (c>0) {
      if (suc) suc = [x updateMin:minDiv4(a,b,c,d) andMax:maxDiv4(a,b,c,d)];
   } else if (d<0) {
      if (suc) suc = [x updateMin:minDiv4(a,b,c,d) andMax:maxDiv4(a,b,c,d)];
   } else {
      if (a <= 0 && b >= 0)
         return CPSuspend;
      else {
         if (c==0 || d == 0) {
            if (a <= 0 && b >= 0) return CPSuspend;
            CPRange az = [y around:0]; // around zero            
            int s = c==0 ? az.up : az.low;
            int l = c==0 ? d : c;
            if (suc) suc = [x updateMin:minDiv4(a,b,s,l) andMax:maxDiv4(a,b,s,l)];
         } else {
            CPRange az = [y around:0]; // around zero
            CPInt xm1 = minDiv4(a,b,az.low,az.up);
            CPInt xM1 = maxDiv4(a,b,az.low,az.up);
            CPInt xm2 = minDiv4(a,b,c,d);
            CPInt xM2 = maxDiv4(a,b,c,d);
            CPInt xm = xm1 < xm2 ? xm1 : xm2;
            CPInt xM = xM1 > xM2 ? xM1 : xM2;
            if (suc) suc = [x updateMin:xm andMax:xM];
         }
      }
   }
   return suc ? CPSuspend : CPFailure;
}
-(CPStatus)propagateXYZ
{
   CPStatus suc = CPSuspend;
   if (![_z member:0]) {
      if (suc) suc = [_x remove:0];
      if (suc) suc = [_y remove:0];
   }
   CPBounds xb,yb,zb;
   [_x bounds:&xb];
   [_y bounds:&yb];
   CPLong t[4] = {xb.min*yb.min,xb.min*yb.max,xb.max*yb.min,xb.max*yb.max};
   if (suc) suc = [_z updateMin:bindDown(minSeq(t)) andMax:bindUp(maxSeq(t))];
   [_z bounds:&zb];
   if (suc) suc = [self propagateXCR:_x mult:_y equal:zb];
   if (suc) suc = [self propagateXCR:_y mult:_x equal:zb];
   return suc ? CPSuspend : CPFailure;
}
-(CPStatus) post
{   
   if ([_x bound])
      return [self postCX:[_x min] mult:_y equal:_z];
   else if ([_y bound])
      return [self postCX:[_y min] mult:_x equal:_z];
   else if ([_z bound]) {
      CPStatus suc = CPSuspend;
      if ([_z min] == 0) {
         BOOL xZero = [_x member:0];
         BOOL yZero = [_y member:0];
         if (xZero || yZero) {   
            if (xZero ^ yZero) { 
               if (xZero) suc = [_x bind:0];
               if (yZero) suc = [_y bind:0];
            } else {  
               [_x whenChangePropagate:self];
               [_y whenChangePropagate:self];
            }
         } else return CPFailure;
      } else { 
         CPStatus suc = propagateRXC(self,bounds(_x),_y,[_z min]);
         if (suc) suc = propagateRXC(self,bounds(_y),_x,[_z min]);
         if (suc) {
            if (![_x bound]) [_x whenChangeBoundsPropagate:self];
            if (![_y bound]) [_y whenChangeBoundsPropagate:self];
         }
      }
      return suc;
   } else { 
      CPStatus suc = [self propagateXYZ];
      if (suc) {
         [_x whenChangeBoundsPropagate:self];
         [_y whenChangeBoundsPropagate:self];
         [_z whenChangeBoundsPropagate:self];
      }
      return suc;
   }   
}
-(CPStatus)propagate
{
   if ([_x bound]) {
      CPStatus oc =  propagateCX(self,[_x min],_y,_z);
      if (oc && [_y bound] && [_z  bound])
         return CPSuccess;
      else return oc;
   } else if ([_y bound]) {
      CPStatus oc = propagateCX(self,[_y min],_x,_z);
      if (oc && [_x bound] && [_z bound])
         return CPSuccess;
      else return oc;      
   } else if ([_z bound]) {
      CPStatus suc = CPSuspend;
      if ([_z min] == 0) {
         BOOL xZero = [_x member:0],yZero = [_y member:0];
         if (xZero || yZero) {   
            if (xZero ^ yZero) { 
               if (xZero)
                  suc = [_x bind:0];
               else suc = [_y bind:0];
            } else suc = CPSuspend;
         } else suc = CPFailure;
      } else { 
         CPStatus suc = propagateRXC(self,bounds(_x),_y,[_z min]);
         if (suc) suc = propagateRXC(self,bounds(_y),_x,[_z min]);
      }
      if (suc && [_x bound] && [_y bound])
         return CPSuccess; 
      else return suc ? CPSuspend : CPFailure;
   } else { 
      return [self propagateXYZ];
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
   return [NSMutableString stringWithFormat:@"<CPMultBC:%02ld %@ == %@ * %@>",_name,_z,_x,_y];
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
   else if ([x isKindOfClass:[CPIntVarArrayI class]]) {
      CPIntVarArrayI* xa = x;
      id<CPSolver> fdm = [xa solver];
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
   CPInt low  = 0,up = _nb - 1;
   CPInt minX = MAXINT,maxX = MININT;
   for(CPInt k=0;k<_nb;k++) {
      minX = minOf(minX,[_x[k] min]);
      maxX = maxOf(maxX,[_x[k] max]);
   }
   CPInt* vCnt = alloca(sizeof(CPInt)*(maxX-minX+1));
   CPInt* vUse = alloca(sizeof(CPInt)*(maxX-minX+1));
   memset(vCnt,0,sizeof(CPInt)*(maxX-minX+1));
   vCnt -= minX;
   CPInt nbBoundVal = 0;
   for(CPInt k=low;k<=up;k++) {
      if ([_x[k] bound]) {
         CPInt to = [_x[k] min];
         vCnt[to]++;
         ok &= vCnt[to] < 2;
         vUse[nbBoundVal++] = to;
      }
   }
   if (ok) {
      for(CPInt k=low;k<=up && ok;k++) {
         if ([_x[k] bound])
             continue;
         for(CPInt j=0;j<nbBoundVal;j++) {
            ok = [_x[k] remove: vUse[j]] != CPFailure;
         }
         if (ok) {
            SEL minSEL = @selector(min);
            IMP minIMP = [_x[k] methodForSelector:minSEL];
            [_x[k] whenBindDo: ^CPStatus() {
               //int vk = [_x[k] min];
               CPInt vk = (CPInt) minIMP(_x[k],minSEL);
               CPStatus s = CPSuspend;
               for(CPInt i=up;i;--i) {
                  if (i == k) 
                      continue;
                  s = [_x[i] remove:vk];
                  if (!s) 
                      return s;
               }
               return s;
            } onBehalf:self];
         }
      }
      return ok ? CPSuspend : CPFailure;
   } 
   else 
       return CPFailure;   
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
   [super encodeWithCoder:aCoder];   
   [aCoder encodeValueOfObjCType:@encode(CPInt) at:&_nb];
   for(CPInt k=0;k<_nb;k++) 
      [aCoder encodeObject:_x[k]];
}

- (id)initWithCoder:(NSCoder *)aDecoder;
{
   self = [super initWithCoder:aDecoder];
   [aDecoder decodeValueOfObjCType:@encode(CPInt) at:&_nb];
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
    [_x whenChangeMinDo: ^CPStatus() { return [_x updateMax: _primalBound]; } onBehalf:self];
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
    [_x whenChangeMaxDo: ^CPStatus() { return [_x updateMin: _primalBound]; } onBehalf:self];
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
