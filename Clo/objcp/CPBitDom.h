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

#import <Foundation/Foundation.h>
#import "CPDom.h"
#import "CPTrail.h"
@class CPSolverI;

@interface CPBoundsDom : NSObject<CPDom,NSCoding,NSCopying> {
@package
   CPTrail* _trail;
   TRInt      _min;
   TRInt      _max;
   TRInt       _sz;
   CPInt       _imin;
   CPInt       _imax;
}
-(CPBoundsDom*)initBoundsDomFor:(CPTrail*)trail low:(CPInt)low up:(CPInt)up;
-(CPStatus)updateMin:(CPInt)newMin for:(id<CPIntVarNotifier>)x;
-(CPStatus)updateMax:(CPInt)newMax for:(id<CPIntVarNotifier>)x;
-(CPStatus)bind:(CPInt)val for:(id<CPIntVarNotifier>)x;
-(CPStatus)remove:(CPInt)val for:(id<CPIntVarNotifier>)x;
-(CPInt)min;
-(CPInt)max;
-(CPInt)imin;
-(CPInt)imax;
-(CPBounds)bounds;
-(bool)bound;
-(CPInt)domsize;
-(bool)member:(CPInt)v;
-(CPInt)findMin:(CPInt)from;
-(CPInt)findMax:(CPInt)from;
-(int(^)())getMin;
-(NSString*)description;
-(id)copyWithZone:(NSZone *)zone;
-(void)restoreDomain:(id<CPDom>)toRestore;
-(void)restoreValue:(CPInt)toRestore;
@end

static inline CPBounds domBounds(CPBoundsDom* dom)
{
   return (CPBounds){dom->_min._val,dom->_max._val};
}

@interface CPBitDom : CPBoundsDom {
@protected
   unsigned*   _bits;
   CPInt* _magic;
}
-(CPBitDom*)initBitDomFor:(CPTrail*)trail low:(CPInt)low up:(CPInt)up;
-(void)dealloc;
-(bool)get:(CPInt)b;
-(bool)member:(CPInt)b;
-(void)set:(CPInt)b at:(bool)v;
-(CPInt)setAllZeroFrom:(CPInt)from to:(CPInt)to;
-(CPInt)countFrom:(CPInt)from to:(CPInt)to;
-(CPInt)findMin:(CPInt)from;
-(CPInt)findMax:(CPInt)from;
-(CPInt)regret;
-(NSString*)description;
-(CPStatus)updateMin:(CPInt)newMin for:(id<CPIntVarNotifier>)x;
-(CPStatus)updateMax:(CPInt)newMax for:(id<CPIntVarNotifier>)x;
-(CPStatus)bind:(CPInt)val for:(id<CPIntVarNotifier>)x;
-(CPStatus)remove:(CPInt)val for:(id<CPIntVarNotifier>)x;
-(id)copyWithZone:(NSZone *)zone;
-(void)restoreDomain:(id<CPDom>)toRestore;
-(void)restoreValue:(CPInt)toRestore;
@end

@interface CPDomain : NSObject {
   CPBitDom*    _dom;
   CPInt      _scale;
   CPInt      _shift;
}
-(CPDomain*)initCPDomain:(CPBitDom*)bd scaleBy:(CPInt)a shift:(CPInt)b;
-(BOOL)member:(CPInt)v;
-(CPInt)min;
-(CPInt)max;
-(BOOL)get:(CPInt)b;
-(void)set:(CPInt)b at:(BOOL)v;
-(CPInt)domsize;
-(CPStatus)scanWith:(CPStatus(^)(CPInt))block;
@end
