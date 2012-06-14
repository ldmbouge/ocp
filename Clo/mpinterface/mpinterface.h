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


#import <objc/objc-auto.h>
#import <Foundation/NSObject.h>

typedef enum { LPinfeasible, LPoptimal, LPsuboptimal, LPunbounded, LPerror} LPOutcome;
typedef enum { LPgeq, LPleq, LPeq } LPConstraintType;
typedef enum { LPminimize, LPmaximize } LPObjectiveType;

@protocol LPConstraint;
@protocol LPVariable;

typedef double (^LPInt2Double)(CPInt);
typedef id<LPVariable> (^LPInt2Var)(CPInt);

typedef struct IRange {
    int low;
    int up;
} IRange;

@protocol LPVariable <NSObject>
-(CPInt)    idx;
-(double) low;
-(double) up;
-(bool) hasBounds;
-(double) value;
-(double) reducedCost;
@end

@protocol LPConstraint <NSObject>
-(LPConstraintType)    type;
-(CPInt)                 size;
-(id<LPVariable>*)     var;
-(CPInt*)                col;
-(double*)             coef;
-(double)              rhs;
-(CPInt)                 idx;
-(double)              dual;
@end

@protocol LPObjective  <NSObject>
-(LPObjectiveType)     type;
-(CPInt)                 size;
-(CPInt*)                col;
-(double*)             coef;
-(double)              value;
@end


@protocol LPColumn <NSObject>
-(CPInt)    idx;
-(double) low;
-(double) up;
-(double) objCoef;
-(CPInt) size;
-(CPInt*) cstrIdx;
-(double*) coef;
@end

@protocol LPLinearTerm <NSObject>
-(CPInt) size;
-(double) cst;
-(void) add: (double) cst;
-(void) add: (double) coef times: (id<LPVariable>) var;
@end

@protocol LPSolver <NSObject> 
-(id<LPVariable>)   createVariable;
-(id<LPVariable>)   createVariable: (double) low up: (double) up;
-(id<LPColumn>)     createColumn: (double) low up: (double) up size: (CPInt) size obj: (double) obj cstr: (id<LPConstraint>*) idx coef: (double*) coef;
-(id<LPColumn>)     createColumn: (double) low up: (double) up;

-(id<LPLinearTerm>) createLinearTerm;
-(id<LPLinearTerm>) createLinearTerm:(IRange) R coef: (LPInt2Double) c var: (LPInt2Var) v;

-(id<LPConstraint>) createLEQ: (CPInt) size var: (id<LPVariable>*) var coef: (double*) coef rhs: (double) rhs;
-(id<LPConstraint>) createGEQ: (CPInt) size var: (id<LPVariable>*) var coef: (double*) coef rhs: (double) rhs;
-(id<LPConstraint>) createEQ: (CPInt) size var: (id<LPVariable>*) var coef: (double*) coef rhs: (double) rhs;
-(id<LPObjective>)  createMinimize: (CPInt) size var: (id<LPVariable>*) var coef: (double*) coef;
-(id<LPObjective>)  createMaximize: (CPInt) size var: (id<LPVariable>*) var coef: (double*) coef;

-(id<LPConstraint>) createLEQ: (id<LPLinearTerm>) t rhs: (double) rhs;
-(id<LPConstraint>) createGEQ: (id<LPLinearTerm>) t rhs: (double) rhs;
-(id<LPConstraint>) createEQ:  (id<LPLinearTerm>) t  rhs: (double) rhs;
-(id<LPObjective>)  createMinimize: (id<LPLinearTerm>) t;
-(id<LPObjective>)  createMaximize: (id<LPLinearTerm>) t;

-(id<LPConstraint>) postConstraint: (id<LPConstraint>) cstr;
-(void) removeConstraint: (id<LPConstraint>) cstr;
-(void) removeVariable: (id<LPVariable>) var;
-(id<LPObjective>) postObjective: (id<LPObjective>) obj;
-(id<LPVariable>) postColumn: (id<LPColumn>) col;

-(void) close;
-(bool) isClosed;
-(LPOutcome) solve;
-(LPOutcome) status;

-(void) setIntParameter: (const char*) name val: (CPInt) val;
-(void) setFloatParameter: (const char*) name val: (double) val;
-(void) setStringParameter: (const char*) name val: (char*) val;

-(void) print;
-(void) printModelToFile: (char*) fileName;

//-(CotLPAbstractBasis)* getBasis() ;
//-(void) setBasis(CotLPAbstractBasis* basis) ;

@end

