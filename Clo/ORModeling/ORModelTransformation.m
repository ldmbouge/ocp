/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "ORModelTransformation.h"
#import "ORTracker.h"
#import "ORSetI.h"

@implementation ORExprDomainEvaluatorI {
    id<ORTracker> _tracker;
    id<ORIntRange> _result;
}

-(id<ORIntRange>) evaluateExpr: (id<ORExpr>)e {
    [e visit: self];
    return _result;
}

-(id<ORIntRange>) domain: (id<ORTracker>) tracker ForExpr: (id<ORExpr>)expr {
    return [self evaluateExpr: expr];
}

-(void) visitRandomStream:(id) v { _result = [ORFactory undefinedIntRange]; }
-(void) visitZeroOneStream:(id) v { _result = [ORFactory undefinedIntRange]; }
-(void) visitUniformDistribution:(id) v{ _result = [ORFactory undefinedIntRange]; }
-(void) visitIntSet:(id<ORIntSet>)v{ _result = [ORFactory undefinedIntRange]; }
-(void) visitIntRange:(id<ORIntRange>)v{ _result = v; }
-(void) visitIntArray:(id<ORIntArray>)v  { _result = [ORFactory undefinedIntRange]; }
-(void) visitIntMatrix:(id<ORIntMatrix>)v  { _result = [ORFactory undefinedIntRange]; }
-(void) visitTrailableInt:(id<ORTrailableInt>)v  { _result = [ORFactory undefinedIntRange]; }
-(void) visitIntVar: (id<ORIntVar>) v  { _result = [v domain]; }
-(void) visitFloatVar: (id<ORFloatVar>) v  { _result = [ORFactory undefinedIntRange]; }
-(void) visitIntVarLitEQView:(id<ORIntVar>)v  { _result = [ORFactory undefinedIntRange]; }
-(void) visitAffineVar:(id<ORIntVar>) v  { _result = [ORFactory undefinedIntRange]; }
-(void) visitIdArray: (id<ORIdArray>) v  { _result = [ORFactory undefinedIntRange]; }
-(void) visitIdMatrix: (id<ORIdMatrix>) v  { _result = [ORFactory undefinedIntRange]; }
-(void) visitTable:(id<ORTable>) v  { _result = [ORFactory undefinedIntRange]; }
// micro-Constraints
-(void) visitConstraint:(id<ORConstraint>)c  { _result = [ORFactory undefinedIntRange]; }
-(void) visitObjectiveFunction:(id<ORObjectiveFunction>)f  { _result = [ORFactory undefinedIntRange]; }
-(void) visitFail:(id<ORFail>)cstr  { _result = [ORFactory undefinedIntRange]; }
-(void) visitRestrict:(id<ORRestrict>)cstr  { _result = [ORFactory undefinedIntRange]; }
-(void) visitAlldifferent: (id<ORAlldifferent>) cstr  { _result = [ORFactory undefinedIntRange]; }
-(void) visitCardinality: (id<ORCardinality>) cstr  { _result = [ORFactory undefinedIntRange]; }
-(void) visitAlgebraicConstraint: (id<ORAlgebraicConstraint>) cstr  { _result = [ORFactory undefinedIntRange]; }
-(void) visitTableConstraint: (id<ORTableConstraint>) cstr  { _result = [ORFactory undefinedIntRange]; }
-(void) visitLexLeq:(id<ORLexLeq>) cstr  { _result = [ORFactory undefinedIntRange]; }
-(void) visitCircuit:(id<ORCircuit>) cstr  { _result = [ORFactory undefinedIntRange]; }
-(void) visitNoCycle:(id<ORNoCycle>) cstr  { _result = [ORFactory undefinedIntRange]; }
-(void) visitPackOne:(id<ORPackOne>) cstr  { _result = [ORFactory undefinedIntRange]; }
-(void) visitPacking:(id<ORPacking>) cstr  { _result = [ORFactory undefinedIntRange]; }
-(void) visitKnapsack:(id<ORKnapsack>) cstr  { _result = [ORFactory undefinedIntRange]; }
-(void) visitAssignment:(id<ORAssignment>)cstr { _result = [ORFactory undefinedIntRange]; }
-(void) visitMinimize: (id<ORObjectiveFunction>) v  { _result = [ORFactory undefinedIntRange]; }
-(void) visitMaximize: (id<ORObjectiveFunction>) v  { _result = [ORFactory undefinedIntRange]; }
-(void) visitEqualc: (id<OREqualc>)c  { _result = [ORFactory undefinedIntRange]; }
-(void) visitNEqualc: (id<ORNEqualc>)c  { _result = [ORFactory undefinedIntRange]; }
-(void) visitLEqualc: (id<ORLEqualc>)c  { _result = [ORFactory undefinedIntRange]; }
-(void) visitEqual: (id<OREqual>)c  { _result = [ORFactory undefinedIntRange]; }
-(void) visitNEqual: (id<ORNEqual>)c  { _result = [ORFactory undefinedIntRange]; }
-(void) visitLEqual: (id<ORLEqual>)c  { _result = [ORFactory undefinedIntRange]; }
-(void) visitPlus: (id<ORPlus>)c  { _result = [ORFactory undefinedIntRange]; }
-(void) visitMult: (id<ORMult>)c  { _result = [ORFactory undefinedIntRange]; }
-(void) visitAbs: (id<ORAbs>)c  { _result = [ORFactory undefinedIntRange]; }
-(void) visitOr: (id<OROr>)c  { _result = [ORFactory undefinedIntRange]; }
-(void) visitAnd:( id<ORAnd>)c  { _result = [ORFactory undefinedIntRange]; }
-(void) visitImply: (id<ORImply>)c  { _result = [ORFactory undefinedIntRange]; }
-(void) visitElementCst: (id<ORElementCst>)c  { _result = [ORFactory undefinedIntRange]; }
-(void) visitElementVar: (id<ORElementVar>)c  { _result = [ORFactory undefinedIntRange]; }
-(void) visitReifyEqualc: (id<ORReifyEqualc>)c  { _result = [ORFactory undefinedIntRange]; }
-(void) visitReifyEqual: (id<ORReifyEqual>)c  { _result = [ORFactory undefinedIntRange]; }
-(void) visitReifyNEqualc: (id<ORReifyNEqualc>)c  { _result = [ORFactory undefinedIntRange]; }
-(void) visitReifyNEqual: (id<ORReifyNEqual>)c  { _result = [ORFactory undefinedIntRange]; }
-(void) visitReifyLEqualc: (id<ORReifyLEqualc>)c  { _result = [ORFactory undefinedIntRange]; }
-(void) visitReifyLEqual: (id<ORReifyLEqual>)c  { _result = [ORFactory undefinedIntRange]; }
-(void) visitReifyGEqualc: (id<ORReifyGEqualc>)c  { _result = [ORFactory undefinedIntRange]; }
-(void) visitReifyGEqual: (id<ORReifyGEqual>)c  { _result = [ORFactory undefinedIntRange]; }
-(void) visitSumBoolEqualc: (id<ORSumBoolEqc>) c  { _result = [ORFactory undefinedIntRange]; }
-(void) visitSumBoolLEqualc:(id<ORSumBoolLEqc>)c  { _result = [ORFactory undefinedIntRange]; }
-(void) visitSumBoolGEqualc:(id<ORSumBoolGEqc>)c  { _result = [ORFactory undefinedIntRange]; }
-(void) visitSumEqualc:(id<ORSumEqc>)c  { _result = [ORFactory undefinedIntRange]; }
-(void) visitSumLEqualc:(id<ORSumLEqc>)c  { _result = [ORFactory undefinedIntRange]; }
-(void) visitSumGEqualc:(id<ORSumGEqc>)c  { _result = [ORFactory undefinedIntRange]; }
// Expressions
-(void) visitIntegerI: (id<ORInteger>) e  {
    _result = [ORFactory  intRange: _tracker low: [e value] up: [e value]];
}
-(void) visitExprPlusI: (id<ORExpr>) e {
    ORExprBinaryI* binExpr = (ORExprBinaryI*)e;
    id<ORIntRange> lr = [self evaluateExpr: [binExpr left]];
    id<ORIntRange> rr = [self evaluateExpr: [binExpr right]];
    if(![lr isDefined] || ![rr isDefined]) _result = [ORFactory undefinedIntRange];
    else _result = [ORFactory  intRange: _tracker low: [lr low] + [rr low] up: [lr up] + [rr up]];
    [_result autorelease];
}

-(void) visitExprMinusI: (id<ORExpr>) e  {
    ORExprBinaryI* binExpr = (ORExprBinaryI*)e;
    id<ORIntRange> lr = [self evaluateExpr: [binExpr left]];
    id<ORIntRange> rr = [self evaluateExpr: [binExpr right]];
    if(![lr isDefined] || ![rr isDefined]) _result = [ORFactory undefinedIntRange];
    else _result = [ORFactory  intRange: _tracker low: [lr low] - [rr up] up: [lr up] - [rr low]];
    [_result autorelease];
}
-(void) visitExprMulI: (id<ORExpr>) e  {
    ORExprBinaryI* binExpr = (ORExprBinaryI*)e;
    id<ORIntRange> lr = [self evaluateExpr: [binExpr left]];
    id<ORIntRange> rr = [self evaluateExpr: [binExpr right]];
    if(![lr isDefined] || ![rr isDefined]) _result = [ORFactory undefinedIntRange];
    else {
        ORInt extremums[] = { [lr low] * [rr low], [lr low] * [rr up],
                              [lr up] * [rr low], [lr up] * [rr up]};
        ORInt low = min(min(extremums[0], extremums[1]), min(extremums[2], extremums[3]));
        ORInt up = max(max(extremums[0], extremums[1]), max(extremums[2], extremums[3]));
        _result = [ORFactory  intRange: _tracker low: low up: up];
    }
    [_result autorelease];
}
-(void) visitExprEqualI: (id<ORExpr>) e  { _result = [ORFactory undefinedIntRange]; }
-(void) visitExprNEqualI: (id<ORExpr>) e  { _result = [ORFactory undefinedIntRange]; }
-(void) visitExprLEqualI: (id<ORExpr>) e  { _result = [ORFactory undefinedIntRange]; }
-(void) visitExprSumI: (id<ORExpr>) e  {
    ORExprSumI* exprSum = (ORExprSumI*)e;
    [self evaluateExpr: [exprSum expr]];
}
-(void) visitExprAbsI:(id<ORExpr>) e  { _result = [ORFactory undefinedIntRange]; }
-(void) visitExprCstSubI: (id<ORExpr>) e  { _result = [ORFactory undefinedIntRange]; }
-(void) visitExprDisjunctI:(id<ORExpr>) e  { _result = [ORFactory undefinedIntRange]; }
-(void) visitExprConjunctI: (id<ORExpr>) e  { _result = [ORFactory undefinedIntRange]; }
-(void) visitExprImplyI: (id<ORExpr>) e  { _result = [ORFactory undefinedIntRange]; }
-(void) visitExprAggOrI: (id<ORExpr>) e  { _result = [ORFactory undefinedIntRange]; }
-(void) visitExprVarSubI: (id<ORExpr>) e  { _result = [ORFactory undefinedIntRange]; }
@end