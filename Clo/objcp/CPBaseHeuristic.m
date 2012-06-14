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

#import "CPBaseHeuristic.h"
#import "CPSolverI.h"
#import "CPIntVarI.h"

@implementation CPBaseHeuristic
-(void)initHeuristic:(NSMutableArray*)array
{
   __block CPUInt nbViews = 0;
   [array enumerateObjectsUsingBlock:^void(id obj, NSUInteger idx, BOOL *stop) {
      nbViews += ([obj isKindOfClass:[CPIntShiftView class]] || [obj isKindOfClass:[CPIntView class]]);
   }];
   CPUInt l = [array count] - nbViews;
   __block CPUInt k = 0;
   id<CPIntVar>* t = alloca(sizeof(id<CPIntVar>)*l);
   [array enumerateObjectsUsingBlock:^void(id obj, NSUInteger idx, BOOL *stop) {
      if (!([obj isKindOfClass:[CPIntShiftView class]] || [obj isKindOfClass:[CPIntView class]]))
         t[k++] = obj;
   }];
   [self initHeuristic:t length:l];   
}
-(void)initHeuristic:(id<CPIntVar>*)t length:(CPInt)len
{
   
}
@end
