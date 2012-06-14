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
#import "CPIntVarI.h"
#import "CPDataI.h"
#import "CPConstraintI.h"
#import "CPTrail.h"

@class CPIntVarI;
@class CPSolverI;
@class CPIntVarArrayI;

@interface CPReifyNotEqualDC : CPCoreConstraint<NSCoding> {
@private
    CPIntVarI* _b;
    CPIntVarI* _x;
    CPInt       _c;
}
-(id) initCPReifyNotEqualDC:(id<CPIntVar>)b when:(id<CPIntVar>)x neq:(CPInt)c;
-(CPStatus) post;
-(NSSet*)allVars;
-(CPUInt)nbUVars;
@end

@interface CPReifyEqualDC : CPCoreConstraint<NSCoding> {
@private
    CPIntVarI* _b;
    CPIntVarI* _x;
    CPInt       _c;
}
-(id) initCPReifyEqualDC:(id<CPIntVar>)b when:(id<CPIntVar>)x eq:(CPInt)c;
-(CPStatus) post;
-(NSSet*)allVars;
-(CPUInt)nbUVars;
@end

@interface CPSumBoolGeq : CPCoreConstraint<NSCoding> {
    CPIntVarI**            _x;
    CPInt            _nb;
    CPInt             _c;
    CPTrigger**          _at; // the c+1 triggers.
    CPInt* _notTriggered;
    CPInt          _last;
}
-(id) initCPSumBoolGeq:(id)x geq:(CPInt)c;
-(void) dealloc;
-(CPStatus) post;
-(NSSet*)allVars;
-(CPUInt)nbUVars;
@end

