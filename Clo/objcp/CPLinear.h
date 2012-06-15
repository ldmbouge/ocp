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
#import <objcp/CPData.h>
#import "CPConstraintI.h"

@protocol CPIntVar;
@protocol CPIntVarArray;
typedef id<CPIntVar>(^CPRewriter)(id<CPExpr>);

@protocol CPLinear<NSObject>
-(void)setIndependent:(CPInt)idp;
-(void)addIndependent:(CPInt)idp;
-(void)addTerm:(id<CPIntVar>)x by:(CPInt)c;
@end

@interface CPLinear : NSObject<CPLinear> {
   struct CPTerm {
      id<CPIntVar>  _var;
      CPInt        _coef;
   };
   struct CPTerm* _terms;
   CPInt             _nb;
   CPInt            _max;
   CPInt          _indep;
}
+(CPLinear*)linearFrom:(id<CPExpr>)e  sub:(CPRewriter) sub;
-(CPLinear*)initCPLinear:(CPInt)mxs;
-(void)dealloc;
-(void)setIndependent:(CPInt)idp;
-(void)addIndependent:(CPInt)idp;
-(void)addTerm:(id<CPIntVar>)x by:(CPInt)c;
-(NSString*)description;
-(id<CPIntVarArray>)scaledViews;
-(id<CPIntVar>)oneView;
-(CPInt)size;
-(CPInt)min;
-(CPInt)max;
@end

@interface CPExprConstraintI : CPActiveConstraint {
   CPSolverI* _fdm;
   id<CPExpr> _expr;
}
-(id) initCPExprConstraintI:(id<CPExpr>)x;
-(void) dealloc;
-(CPStatus)post;
-(NSSet*)allVars;
-(CPUInt)nbUVars;
@end