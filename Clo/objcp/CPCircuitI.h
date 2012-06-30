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
#import "CPTypes.h"
#import "CPDataI.h"
#import "CPArray.h"
#import "CPConstraintI.h"
#import "CPTrail.h"
#import "CPBasicConstraint.h"

@interface CPCircuitI : CPActiveConstraint<CPConstraint,NSCoding> {
    CPIntVarArrayI*  _x;
    CPIntVarI**      _var;
    CPInt            _varSize;  
    CPInt            _low;
    CPInt            _up;
//    id<CPTRIntArray> _pred;
    TRIntArray       _pred;
    TRIntArray       _succ;
    TRIntArray       _length;
    bool             _noCycle;
    bool             _posted;
}
-(CPCircuitI*) initCPCircuitI: (CPIntVarArrayI*) x;
-(CPCircuitI*) initCPNoCycleI: (CPIntVarArrayI*) x;
-(void) dealloc;
-(CPStatus) post;
-(void) encodeWithCoder: (NSCoder*) aCoder;
-(id) initWithCoder: (NSCoder*) aDecoder;

static CPStatus assign(CPCircuitI* cstr,int i);
@end

