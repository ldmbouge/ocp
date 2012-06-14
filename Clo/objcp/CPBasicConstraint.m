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
   return [NSString stringWithFormat:@"%@ == %d",_x,_c];
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
   return [NSString stringWithFormat:@"%@ != %d",_x,_c];
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
         ok = [_x updateMin:[_y min] + _c];
         if (ok) 
             ok = [_x updateMax:[_y max] + _c];
         if (ok) 
             ok = [_y updateMax:[_x max] - _c];
         if (ok) 
             ok = [_y updateMin:[_x min] - _c];
    }
    return ok;
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
      return [_y remove:[_x min] - _c];
   else if ([_y bound])
      return [_x remove:[_y min] + _c];
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
   return [NSMutableString stringWithFormat:@"<%02ld> %@ != %@ + %d",_name,_x,_y,_c];
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
         return [_y remove:[_x min]];
      } priority:HIGHEST_PRIO onBehalf:self];
      [_y whenBindDo:^CPStatus{
         if (!_active._val) return CPSkip;
         assignTRInt(&_active, NO, _trail);
         return [_x remove:[_y min]];
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
   if (![_x bound] || ![_y bound]) {
      [_x whenChangeMinPropagate: self];
      [_y whenChangeMaxPropagate: self];
   }
   return [self propagate];   
}
-(CPStatus) propagate
{
   if (!_active._val) 
      return CPSkip;
   assignTRInt(&_active, NO, _trail);
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
