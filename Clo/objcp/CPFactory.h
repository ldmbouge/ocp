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
#import "CPSolver.h"
#import "CP.h"
#import "CPSet.h"
#import "CPTable.h"
#import "CPConcurrency.h"
#import "CPHeuristic.h"

@interface CPFactory : NSObject
+(id<CP>) createSolver;
+(id<CP>) createSemSolver;
+(id<CP>) createRandomizedSolver;
+(id<CP>) createDeterministicSolver;
+(id<CP>) createSemSolverFor:(id<CPSolver>)fdm;
+(void) shutdown;
+(id<CPHeuristic>) createDDeg:(id<CP>)cp;
+(id<CPHeuristic>) createWDeg:(id<CP>)cp;
+(id<CPHeuristic>) createIBS:(id<CP>)cp;
+(id<CPHeuristic>)createFF:(id<CP>)cp;
@end;

@interface CPFactory (DataStructure)
+(void) print: (id) x;

+(id<CPInteger>) integer: (id<CP>) cp value: (CPInt) value;
+(id<CPIntVar>) intVar: (id<CP>) cp domain: (CPRange) range;
+(id<CPIntVar>) intVar: (id<CPIntVar>) x shift: (CPInt) b;
+(id<CPIntVar>) intVar: (id<CPIntVar>) x scale: (CPInt) a;
+(id<CPIntVar>) intVar: (id<CPIntVar>) x scale: (CPInt) a shift:(CPInt) b;
+(id<CPIntVar>) negate:(id<CPIntVar>)x;


+(id<CPIntVarArray>) intVarArray: (id<CP>) cp range: (CPRange) range domain: (CPRange) domain;
+(id<CPIntVarArray>) intVarArray: (id<CP>) cp range: (CPRange) range with:(id<CPIntVar>(^)(CPInt)) clo;
+(id<CPIntVarArray>) intVarArray: (id<CP>) cp range: (CPRange) r1 range: (CPRange) r2 with:(id<CPIntVar>(^)(CPInt,CPInt)) clo;
+(id<CPIntVarArray>) pointwiseProduct:(id<CPIntVarArray>)x by:(int*)c;
+(id<CPIntVarMatrix>) intVarMatrix: (id<CP>) cp rows: (CPRange) rr columns: (CPRange) cr domain: (CPRange) domain;

+(id<CPIntArray>) intArray: (id<CP>) cp range: (CPRange) range value: (CPInt) value;
+(id<CPIntArray>) intArray: (id<CP>) cp range: (CPRange) range with:(CPInt(^)(CPInt)) clo;
+(id<CPIntArray>) intArray: (id<CP>) cp range: (CPRange) r1 range: (CPRange) r2 with:(CPInt(^)(CPInt,CPInt)) clo;
+(id<CPIntSet>) intSet: (id<CP>) cp;
+(id<CPInformer>) informer: (id<CP>) cp;
+(id<CPVoidInformer>) voidInformer: (id<CP>) cp;
+(id<CPIntInformer>) intInformer: (id<CP>) cp;
+(id<CPBarrier>)  barrier: (id<CP>) cp value: (CPInt) nb;

+(id<CPTable>) table: (id<CP>) cp arity: (int) arity;
@end

@interface CPFactory (expression)

+(id<CPExpr>) expr: (id<CPExpr>) left add: (id<CPExpr>) right;
+(id<CPExpr>) expr: (id<CPExpr>) left sub: (id<CPExpr>) right;
+(id<CPExpr>) expr: (id<CPExpr>) left mul: (id<CPExpr>) right;
+(id<CPExpr>) expr: (id<CPExpr>) left equal: (id<CPExpr>) right;
+(id<CPExpr>) exprAbs: (id<CPExpr>) op;
+(id<CPExpr>) dotProduct:(id<CPIntVar>[])vars by:(int[])coefs;
+(id<CPExpr>) sum: (id<CP>) cp range: (CPRange) r filteredBy: (CPInt2Bool) f of: (CPInt2Expr) e;

@end;


