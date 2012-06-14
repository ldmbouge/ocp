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

#include <Foundation/Foundation.h>
#import "CPTypes.h"
#include "CPDataI.h"

@interface OPTSelect : NSObject {
    CPRandomStream* _stream;
    CPRange         _range;
    CPInt2Bool      _filter;
    CPInt2Int       _order;
    CPInt       _direction;
}
-(OPTSelect*) initOPTSelectWithRange: (CPRange) range filteredBy: (CPInt2Bool) filter orderedBy: (CPInt2Int) order;
-(void)         dealloc;
-(CPInt)              min;
-(CPInt)              max;
-(CPInt)              any;
-(CPInt)           choose;
@end

@interface CPSelect : NSObject {
    OPTSelect* _select;
}
-(CPSelect*) initCPSelect: (CoreCPI*) cp withRange: (CPRange) range filteredBy: (CPInt2Bool) filter orderedBy: (CPInt2Int) order;
-(void)         dealloc;
-(CPInt)              min;
-(CPInt)              max;
-(CPInt)              any;
@end

@interface CPSelectMinRandomized : NSObject {
  CPRandomStream* _stream;
  CPRange         _range;
  CPInt2Bool      _filter;
  CPInt2Int       _order;
}
-(CPSelectMinRandomized*) initWithRange: (CPRange) range filteredBy: (CPInt2Bool) filter orderedBy: (CPInt2Int) order;
-(void)         dealloc;
-(CPInt)           choose;
@end



@interface CPSelectMax : NSObject {
   CPRange         _range;
   bool*           _used;
   CPInt2Bool      _filter;
   CPInt2Int       _order;
}
-(CPSelectMax*) initSelectMin:(id<CP>)cp range: (CPRange) range filteredBy: (CPInt2Bool) filter orderedBy: (CPInt2Int) order;
-(void)         dealloc;
-(CPInt)    min;
-(CPInt)    max;
-(CPInt)    choose;
@end
