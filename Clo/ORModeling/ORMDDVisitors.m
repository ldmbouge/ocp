#import "ORMDDVisitors.h"
#import "ORModelI.h"
#import "ORVarI.h"
#import "ORDecompose.h"
#import "ORRealDecompose.h"

@implementation ORDDExpressionEquivalenceChecker
-(ORDDExpressionEquivalenceChecker*) initORDDExpressionEquivalenceChecker
{
    self = [super init];
    return self;
}
-(NSMutableArray*) checkEquivalence:(id<ORExpr>)first and:(id<ORExpr>)second
//If return is NULL, they are not equivalent
//If return is empty array, they are fully equivalent
//If return is non-empty array, they are equivalent on the condition the returned mappings are equivalent:
//Mappings is an array of arrays of size 2.  The first corresponds to a state value in first, the second to a state value in second.  If all of these are found to be equivalent from other checkEquivalence calls, then first and second are equivalent as well.
{
    _currentString = [[NSMutableString alloc] init];
    _currentGetStates = [[NSMutableArray alloc] init];
    [first visit:self];
    _firstString = [_currentString copy];
    _firstGetStates = [_currentGetStates copy];
    
    _currentString = [[NSMutableString alloc] init];
    _currentGetStates = [[NSMutableArray alloc] init];
    [second visit:self];
    _secondString = [_currentString copy];
    _secondGetStates = [_currentGetStates copy];
    
    if (![_firstString isEqualToString: _secondString]) {
        return NULL;
    }
    NSMutableArray* mappings = [[NSMutableArray alloc] init];
    for (int index = 0; index < [_firstGetStates count]; index++) {
        [mappings addObject:@[[_firstGetStates objectAtIndex:index],[_secondGetStates objectAtIndex:index]]];
    }
    return mappings;
}

-(void) visitExprStateValueI:(ORExprStateValueI*)e
{
    [_currentString appendString:[NSString stringWithFormat:@"StateValue%d",[e index]]];
    [_currentGetStates addObject:[[NSNumber alloc] initWithInt:[e lookup]]];
}

-(void) visitExprConjunctI:(ORExprBinaryI*)e
{
    [_currentString appendString:@"Conjunct("];
    [[e left] visit: self];
    [_currentString appendString:@","];
    [[e right] visit: self];
    [_currentString appendString:@")"];
}
-(void) visitExprDisjunctI:(ORExprBinaryI*)e
{
    [_currentString appendString:@"Disjunct("];
    [[e left] visit: self];
    [_currentString appendString:@","];
    [[e right] visit: self];
    [_currentString appendString:@")"];
}
-(void) visitExprImplyI:(ORExprBinaryI*)e
{
    [_currentString appendString:@"Imply("];
    [[e left] visit: self];
    [_currentString appendString:@","];
    [[e right] visit: self];
    [_currentString appendString:@")"];
}
-(void) visitExprPlusI:(ORExprBinaryI*)e
{
    [_currentString appendString:@"Plus("];
    [[e left] visit: self];
    [_currentString appendString:@","];
    [[e right] visit: self];
    [_currentString appendString:@")"];
}
-(void) visitExprMinusI:(ORExprBinaryI*)e
{
    [_currentString appendString:@"Minus("];
    [[e left] visit: self];
    [_currentString appendString:@","];
    [[e right] visit: self];
    [_currentString appendString:@")"];
}
-(void) visitExprMulI:(ORExprBinaryI*)e
{
    [_currentString appendString:@"Mul("];
    [[e left] visit: self];
    [_currentString appendString:@","];
    [[e right] visit: self];
    [_currentString appendString:@")"];
}
-(void) visitExprDivI:(ORExprBinaryI*)e
{
    [_currentString appendString:@"Div("];
    [[e left] visit: self];
    [_currentString appendString:@","];
    [[e right] visit: self];
    [_currentString appendString:@")"];
}
-(void) visitExprModI:(ORExprBinaryI*)e
{
    [_currentString appendString:@"Mod("];
    [[e left] visit: self];
    [_currentString appendString:@","];
    [[e right] visit: self];
    [_currentString appendString:@")"];
}
-(void) visitExprEqualI:(ORExprBinaryI*)e
{
    [_currentString appendString:@"Equal("];
    [[e left] visit: self];
    [_currentString appendString:@","];
    [[e right] visit: self];
    [_currentString appendString:@")"];
}
-(void) visitExprNEqualI:(ORExprBinaryI*)e
{
    [_currentString appendString:@"NEqual("];
    [[e left] visit: self];
    [_currentString appendString:@","];
    [[e right] visit: self];
    [_currentString appendString:@")"];
}
-(void) visitExprLEqualI:(ORExprBinaryI*)e
{
    [_currentString appendString:@"LEqual("];
    [[e left] visit: self];
    [_currentString appendString:@","];
    [[e right] visit: self];
    [_currentString appendString:@")"];
}
-(void) visitExprGEqualI:(ORExprBinaryI*)e
{
    [_currentString appendString:@"GEqual("];
    [[e left] visit: self];
    [_currentString appendString:@","];
    [[e right] visit: self];
    [_currentString appendString:@")"];
}
-(void) visitExprMinI:(ORExprBinaryI*)e
{
    [_currentString appendString:@"Min("];
    [[e left] visit: self];
    [_currentString appendString:@","];
    [[e right] visit: self];
    [_currentString appendString:@")"];
}
-(void) visitExprMaxI:(ORExprBinaryI*)e
{
    [_currentString appendString:@"Max("];
    [[e left] visit: self];
    [_currentString appendString:@","];
    [[e right] visit: self];
    [_currentString appendString:@")"];
}

-(void) visitExprSetContainsI:(ORExprSetContainsI*)e
{
    [_currentString appendString:@"SetContains("];
    id<IntEnumerator> setEnum = [[e set] enumerator];
    while ([setEnum more]) {
        [_currentString appendString:[NSString stringWithFormat:@"%d,",[setEnum next]]];
    }
    [_currentString appendString:@","];
    [[e value] visit: self];
    [_currentString appendString:@")"];
}

-(void) visitExprSetExprContainsI:(ORExprBinaryI*)e
{
    [_currentString appendString:@"ExprSetContains("];
    [[e left] visit: self];
    [_currentString appendString:@","];
    [[e right] visit: self];
    [_currentString appendString:@")"];
}
-(void) visitExprSetUnionI:(ORExprBinaryI*)e
{
    [_currentString appendString:@"SetUnion("];
    [[e left] visit: self];
    [_currentString appendString:@","];
    [[e right] visit: self];
    [_currentString appendString:@")"];
}
-(void) visitExprIfThenElseI:(ORExprIfThenElseI*)e
{
    [_currentString appendString:@"IfThenElse("];
    [[e ifExpr] visit: self];
    [_currentString appendString:@","];
    [[e thenReturn] visit: self];
    [_currentString appendString:@","];
    [[e elseReturn] visit: self];
    [_currentString appendString:@")"];
}
-(void) visitExprEachInSetPlusI:(ORExprBinaryI*)e
{
    [_currentString appendString:@"EachInSetPlus("];
    [[e left] visit: self];
    [_currentString appendString:@","];
    [[e right] visit: self];
    [_currentString appendString:@")"];
}
-(void) visitExprEachInSetPlusEachInSetI:(ORExprBinaryI*)e
{
    [_currentString appendString:@"EachInSetPlusEachInSet("];
    [[e left] visit: self];
    [_currentString appendString:@","];
    [[e right] visit: self];
    [_currentString appendString:@")"];
}
-(void) visitExprEachInSetLEQI:(ORExprBinaryI*)e
{
    [_currentString appendString:@"EachInSetLEQ("];
    [[e left] visit: self];
    [_currentString appendString:@","];
    [[e right] visit: self];
    [_currentString appendString:@")"];
}
-(void) visitExprEachInSetGEQI:(ORExprBinaryI*)e
{
    [_currentString appendString:@"EachInSetGEQ("];
    [[e left] visit: self];
    [_currentString appendString:@","];
    [[e right] visit: self];
    [_currentString appendString:@")"];
}

-(void) visitExprValueAssignmentI:(ORExprValueAssignmentI*)e
{
    [_currentString appendString:@"ValueAssignment"];
}
-(void) visitExprLayerVariable:(ORExprLayerVariableI*)e
{
    [_currentString appendString:@"LayerVariable"];
}

-(void) visitIntVar:(id<ORIntVar>)v {
    @throw [[ORExecutionError alloc] initORExecutionError: "IntVar: visit method not defined"];
}
-(void) visitIntegerI: (id<ORInteger>) e {
    [_currentString appendString:[NSString stringWithFormat:@"%d",[e value]]];
}
-(void) visitMutableIntegerI: (id<ORMutableInteger>) e {
    @throw [[ORExecutionError alloc] initORExecutionError: "MutableInteger: visit method not defined"];
}
-(void) visitMutableDouble: (id<ORMutableDouble>) e {
    @throw [[ORExecutionError alloc] initORExecutionError: "MutableDouble: visit method not defined"];
}
-(void) visitDouble: (id<ORDoubleNumber>) e {
    @throw [[ORExecutionError alloc] initORExecutionError: "Double: visit method not defined"];
}

-(void) visitExprSumI: (id<ORExpr>) e
{
    @throw [[ORExecutionError alloc] initORExecutionError: "ExprSumI: visit method not defined"];
}
-(void) visitExprProdI: (id<ORExpr>) e
{
    @throw [[ORExecutionError alloc] initORExecutionError: "ExprProdI: visit method not defined"];
}
-(void) visitExprAggMinI: (id<ORExpr>) e
{
    @throw [[ORExecutionError alloc] initORExecutionError: "ExprAggMinI: visit method not defined"];
}
-(void) visitExprAggMaxI: (id<ORExpr>) e
{
    @throw [[ORExecutionError alloc] initORExecutionError: "ExprAggMaxI: visit method not defined"];
}
-(void) visitExprAbsI:(ORExprAbsI*) e
{
    [_currentString appendString:@"Abs("];
    [[e operand] visit: self];
    [_currentString appendString:@")"];
}
-(void) visitExprSquareI:(id<ORExpr>)e
{
    @throw [[ORExecutionError alloc] initORExecutionError: "ExprSquareI: visit method not defined"];
}
-(void) visitExprNegateI:(id<ORExpr>)e
{
    @throw [[ORExecutionError alloc] initORExecutionError: "ExprNegateI: visit method not defined"];
}
-(void) visitExprCstSubI: (id<ORExpr>) e
{
    @throw [[ORExecutionError alloc] initORExecutionError: "ExprCstSubI: visit method not defined"];
}
-(void) visitExprCstDoubleSubI:(id<ORExpr>)e
{
    @throw [[ORExecutionError alloc] initORExecutionError: "ExprCstDoubleSubI: visit method not defined"];
}
-(void) visitExprAggOrI: (id<ORExpr>) e
{
    @throw [[ORExecutionError alloc] initORExecutionError: "ExprAggOrI: visit method not defined"];
}
-(void) visitExprAggAndI: (id<ORExpr>) e
{
    @throw [[ORExecutionError alloc] initORExecutionError: "ExprAggAndI: visit method not defined"];
}
-(void) visitExprVarSubI: (id<ORExpr>) e
{
    @throw [[ORExecutionError alloc] initORExecutionError: "ExprVarSubI: visit method not defined"];
}
-(void) visitExprMatrixVarSubI:(id<ORExpr>)e
{
    @throw [[ORExecutionError alloc] initORExecutionError: "ExprMatrixVarSubI: visit method not defined"];
}

@end

@implementation ORDDUpdateSpecs
-(ORDDUpdateSpecs*) initORDDUpdateSpecs:(NSDictionary*)mapping
{
    self = [super init];
    _mapping = mapping;
    return self;
}
-(void) updateSpecs:(id<ORExpr>)e
{
    [e visit: self];
}

-(void) visitExprStateValueI:(ORExprStateValueI*)e
{
    [e setLookup:[[_mapping objectForKey:[[NSNumber alloc] initWithInt: [e lookup]]] intValue]];
}

-(void) visitExprConjunctI:(ORExprBinaryI*)e
{
    [[e left] visit: self];
    [[e right] visit: self];
}
-(void) visitExprDisjunctI:(ORExprBinaryI*)e
{
    [[e left] visit: self];
    [[e right] visit: self];
}
-(void) visitExprImplyI:(ORExprBinaryI*)e
{
    [[e left] visit: self];
    [[e right] visit: self];
}
-(void) visitExprPlusI:(ORExprBinaryI*)e
{
    [[e left] visit: self];
    [[e right] visit: self];
}
-(void) visitExprMinusI:(ORExprBinaryI*)e
{
    [[e left] visit: self];
    [[e right] visit: self];
}
-(void) visitExprMulI:(ORExprBinaryI*)e
{
    [[e left] visit: self];
    [[e right] visit: self];
}
-(void) visitExprDivI:(ORExprBinaryI*)e
{
    [[e left] visit: self];
    [[e right] visit: self];
}
-(void) visitExprModI:(ORExprBinaryI*)e
{
    [[e left] visit: self];
    [[e right] visit: self];
}
-(void) visitExprEqualI:(ORExprBinaryI*)e
{
    [[e left] visit: self];
    [[e right] visit: self];
}
-(void) visitExprNEqualI:(ORExprBinaryI*)e
{
    [[e left] visit: self];
    [[e right] visit: self];
}
-(void) visitExprLEqualI:(ORExprBinaryI*)e
{
    [[e left] visit: self];
    [[e right] visit: self];
}
-(void) visitExprGEqualI:(ORExprBinaryI*)e
{
    [[e left] visit: self];
    [[e right] visit: self];
}
-(void) visitExprMinI:(ORExprBinaryI*)e
{
    [[e left] visit: self];
    [[e right] visit: self];
}
-(void) visitExprMaxI:(ORExprBinaryI*)e
{
    [[e left] visit: self];
    [[e right] visit: self];
}

-(void) visitExprSetContainsI:(ORExprSetContainsI*)e
{
    [[e value] visit: self];
}
-(void) visitExprSetExprContainsI:(ORExprBinaryI*)e
{
    [[e left] visit: self];
    [[e right] visit: self];
}
-(void) visitExprIfThenElseI:(ORExprIfThenElseI*)e
{
    [[e ifExpr] visit: self];
    [[e thenReturn] visit: self];
    [[e elseReturn] visit: self];
}
-(void) visitExprEachInSetPlusI:(ORExprBinaryI*)e
{
    [[e left] visit: self];
    [[e right] visit: self];
}
-(void) visitExprEachInSetPlusEachInSetI:(ORExprBinaryI*)e
{
    [[e left] visit: self];
    [[e right] visit: self];
}
-(void) visitExprEachInSetLEQI:(ORExprBinaryI*)e
{
    [[e left] visit: self];
    [[e right] visit: self];
}
-(void) visitExprEachInSetGEQI:(ORExprBinaryI*)e
{
    [[e left] visit: self];
    [[e right] visit: self];
}

-(void) visitIntVar:(id<ORIntVar>)v { return; }
-(void) visitIntegerI: (id<ORInteger>) e { return; }
-(void) visitMutableIntegerI: (id<ORMutableInteger>) e { return; }
-(void) visitMutableDouble: (id<ORMutableDouble>) e { return; }
-(void) visitDouble: (id<ORDoubleNumber>) e { return; }
-(void) visitExprValueAssignmentI:(id<ORExpr>)e { return; }
-(void) visitExprLayerVariableI:(id<ORExpr>)e { return; }
-(void) visitExprParentInformationI:(id<ORExpr>)e { return; }
-(void) visitExprChildInformationI:(id<ORExpr>)e { return; }
-(void) visitExprLeftInformationI:(id<ORExpr>)e { return; }
-(void) visitExprRightInformationI:(id<ORExpr>)e { return; }
-(void) visitExprSingletonSetI:(ORExprSingletonSetI*)e
{
    [[e value] visit: self];
}

-(void) visitExprSumI: (id<ORExpr>) e
{
    @throw [[ORExecutionError alloc] initORExecutionError: "ExprSumI: visit method not defined"];
}
-(void) visitExprProdI: (id<ORExpr>) e
{
    @throw [[ORExecutionError alloc] initORExecutionError: "ExprProdI: visit method not defined"];
}
-(void) visitExprAggMinI: (id<ORExpr>) e
{
    @throw [[ORExecutionError alloc] initORExecutionError: "ExprAggMinI: visit method not defined"];
}
-(void) visitExprAggMaxI: (id<ORExpr>) e
{
    @throw [[ORExecutionError alloc] initORExecutionError: "ExprAggMaxI: visit method not defined"];
}
-(void) visitExprAbsI:(id<ORExpr>) e
{
    return;
}
-(void) visitExprSquareI:(id<ORExpr>)e
{
    @throw [[ORExecutionError alloc] initORExecutionError: "ExprSquareI: visit method not defined"];
}
-(void) visitExprNegateI:(id<ORExpr>)e
{
    @throw [[ORExecutionError alloc] initORExecutionError: "ExprNegateI: visit method not defined"];
}
-(void) visitExprCstSubI: (id<ORExpr>) e
{
    @throw [[ORExecutionError alloc] initORExecutionError: "ExprCstSubI: visit method not defined"];
}
-(void) visitExprCstDoubleSubI:(id<ORExpr>)e
{
    @throw [[ORExecutionError alloc] initORExecutionError: "ExprCstDoubleSubI: visit method not defined"];
}
-(void) visitExprAggOrI: (id<ORExpr>) e
{
    @throw [[ORExecutionError alloc] initORExecutionError: "ExprAggOrI: visit method not defined"];
}
-(void) visitExprAggAndI: (id<ORExpr>) e
{
    @throw [[ORExecutionError alloc] initORExecutionError: "ExprAggAndI: visit method not defined"];
}
-(void) visitExprVarSubI: (id<ORExpr>) e
{
    @throw [[ORExecutionError alloc] initORExecutionError: "ExprVarSubI: visit method not defined"];
}
-(void) visitExprMatrixVarSubI:(id<ORExpr>)e
{
    @throw [[ORExecutionError alloc] initORExecutionError: "ExprMatrixVarSubI: visit method not defined"];
}


@end

@implementation ORDDClosureGenerator
-(ORDDClosureGenerator*) initORDDClosureGenerator {
    self = [super init];
    return self;
}

-(DDClosure) computeClosure:(id<ORExpr>)e
{
    [e visit: self];
    return current;
}

-(DDClosure) recursiveVisitor:(id<ORExpr>)e
{
    DDClosure old = current;
    current = nil;
    [e visit: self];
    DDClosure returnedValue = current;
    current = old;
    return returnedValue;
}

-(void) visitIntVar:(id<ORIntVar>)v
{
    @throw [[ORExecutionError alloc] initORExecutionError: "IntVar: visit method not defined"];
}

-(void) visitIntegerI: (id<ORInteger>) e
{
    current = [^(int* state, ORInt variable, ORInt value) {
        return [e value];
    } copy];
}
-(void) visitMutableIntegerI: (id<ORMutableInteger>) e
{
    @throw [[ORExecutionError alloc] initORExecutionError: "MutableInteger: visit method not defined"];
}
-(void) visitMutableDouble: (id<ORMutableDouble>) e
{
    @throw [[ORExecutionError alloc] initORExecutionError: "MutableDouble: visit method not defined"];
}
-(void) visitDouble: (id<ORDoubleNumber>) e
{
    @throw [[ORExecutionError alloc] initORExecutionError: "DoubleNumber: visit method not defined"];
}
-(void) visitExprPlusI: (ORExprBinaryI*) e
{
    DDClosure left = [self recursiveVisitor:[e left]];
    DDClosure right = [self recursiveVisitor:[e right]];
    current = [(id)^(int* state, ORInt variable, ORInt value) {
        return (int)left(state, variable, value) + (int)right(state, variable, value);  //Only works for ints
    } copy];
}
-(void) visitExprMinusI: (ORExprBinaryI*) e
{
    DDClosure left = [self recursiveVisitor:[e left]];
    DDClosure right = [self recursiveVisitor:[e right]];
    current = [(id)^(int* state, ORInt variable, ORInt value) {
        return (int)left(state, variable, value) - (int)right(state, variable, value);  //Only works for ints
    } copy];
}
-(void) visitExprMulI: (ORExprBinaryI*) e
{
    DDClosure left = [self recursiveVisitor:[e left]];
    DDClosure right = [self recursiveVisitor:[e right]];
    current = [(id)^(int* state, ORInt variable, ORInt value) {
        return (int)left(state, variable, value) * (int)right(state, variable, value);  //Only works for ints
    } copy];
}
-(void) visitExprDivI: (ORExprBinaryI*) e
{
    DDClosure left = [self recursiveVisitor:[e left]];
    DDClosure right = [self recursiveVisitor:[e right]];
    current = [(id)^(int* state, ORInt variable, ORInt value) {
        return (int)left(state, variable, value) / (int)right(state, variable, value);  //Only works for ints
    } copy];
}
-(void) visitExprModI: (ORExprBinaryI*) e
{
    DDClosure left = [self recursiveVisitor:[e left]];
    DDClosure right = [self recursiveVisitor:[e right]];
    current = [(id)^(int* state, ORInt variable, ORInt value) {
        return (int)left(state, variable, value) % (int)right(state, variable, value);  //Only works for ints
    } copy];
}
-(void) visitExprMinI: (id<ORExpr>) e
{
    @throw [[ORExecutionError alloc] initORExecutionError: "ExprMinI: visit method not defined"];
}
-(void) visitExprMaxI: (id<ORExpr>) e
{
    @throw [[ORExecutionError alloc] initORExecutionError: "ExprMaxI: visit method not defined"];
}
-(void) visitExprEqualI: (ORExprBinaryI*) e
{
    DDClosure left = [self recursiveVisitor:[e left]];
    DDClosure right = [self recursiveVisitor:[e right]];
    current = [(id)^(int* state, ORInt variable, ORInt value) {
        return left(state, variable, value) == right(state, variable, value);
    } copy];
}
-(void) visitExprNEqualI: (ORExprBinaryI*) e
{
    DDClosure left = [self recursiveVisitor:[e left]];
    DDClosure right = [self recursiveVisitor:[e right]];
    current = [(id)^(int* state, ORInt variable, ORInt value) {
        return left(state, variable, value) != right(state, variable, value);
    } copy];
}
-(void) visitExprLEqualI: (ORExprBinaryI*) e
{
    DDClosure left = [self recursiveVisitor:[e left]];
    DDClosure right = [self recursiveVisitor:[e right]];
    current = [(id)^(int* state, ORInt variable, ORInt value) {
        return (int)left(state, variable, value) <= (int)right(state, variable, value);  //Only works for ints
    } copy];
}
-(void) visitExprGEqualI: (ORExprBinaryI*) e
{
    DDClosure left = [self recursiveVisitor:[e left]];
    DDClosure right = [self recursiveVisitor:[e right]];
    current = [(id)^(int* state, ORInt variable, ORInt value) {
        return (int)left(state, variable, value) >= (int)right(state, variable, value);  //Only works for ints
    } copy];
}
-(void) visitExprSumI: (id<ORExpr>) e
{
    @throw [[ORExecutionError alloc] initORExecutionError: "ExprSumI: visit method not defined"];
}
-(void) visitExprProdI: (id<ORExpr>) e
{
    @throw [[ORExecutionError alloc] initORExecutionError: "ExprProdI: visit method not defined"];
}
-(void) visitExprAggMinI: (id<ORExpr>) e
{
    @throw [[ORExecutionError alloc] initORExecutionError: "ExprAggMinI: visit method not defined"];
}
-(void) visitExprAggMaxI: (id<ORExpr>) e
{
    @throw [[ORExecutionError alloc] initORExecutionError: "ExprAggMaxI: visit method not defined"];
}
-(void) visitExprAbsI:(id<ORExpr>) e
{
    @throw [[ORExecutionError alloc] initORExecutionError: "ExprAbsI: visit method not defined"];
}
-(void) visitExprSquareI:(id<ORExpr>)e
{
    @throw [[ORExecutionError alloc] initORExecutionError: "ExprSquareI: visit method not defined"];
}
-(void) visitExprNegateI:(id<ORExpr>)e
{
    @throw [[ORExecutionError alloc] initORExecutionError: "ExprNegateI: visit method not defined"];
}
-(void) visitExprCstSubI: (id<ORExpr>) e
{
    @throw [[ORExecutionError alloc] initORExecutionError: "ExprCstSubI: visit method not defined"];
}
-(void) visitExprCstDoubleSubI:(id<ORExpr>)e
{
    @throw [[ORExecutionError alloc] initORExecutionError: "ExprCstDoubleSubI: visit method not defined"];
}
-(void) visitExprDisjunctI:(ORExprBinaryI*) e
{
    DDClosure left = [self recursiveVisitor:[e left]];
    DDClosure right = [self recursiveVisitor:[e right]];
    current = [(id)^(int* state, ORInt variable, ORInt value) {
        return left(state, variable, value) || right(state, variable, value);
    } copy];
}
-(void) visitExprConjunctI: (ORExprBinaryI*) e
{
    DDClosure left = [self recursiveVisitor:[e left]];
    DDClosure right = [self recursiveVisitor:[e right]];
    current = [(id)^(int* state, ORInt variable, ORInt value) {
        return left(state, variable, value) && right(state, variable, value);
    } copy];
}
-(void) visitExprImplyI: (ORExprBinaryI*) e
{
    DDClosure left = [self recursiveVisitor:[e left]];
    DDClosure right = [self recursiveVisitor:[e right]];
    current = [(id)^(int* state, ORInt variable, ORInt value) {
        return !left(state, variable, value) || right(state, variable, value);
    } copy];
}
-(void) visitExprAggOrI: (id<ORExpr>) e
{
    @throw [[ORExecutionError alloc] initORExecutionError: "ExprAggOrI: visit method not defined"];
}
-(void) visitExprAggAndI: (id<ORExpr>) e
{
    @throw [[ORExecutionError alloc] initORExecutionError: "ExprAggAndI: visit method not defined"];
}
-(void) visitExprVarSubI: (id<ORExpr>) e
{
    @throw [[ORExecutionError alloc] initORExecutionError: "ExprVarSubI: visit method not defined"];
}
-(void) visitExprMatrixVarSubI:(id<ORExpr>)e
{
    @throw [[ORExecutionError alloc] initORExecutionError: "ExprMatrixVarSubI: visit method not defined"];
}
-(void) visitExprStateValueI:(ORExprStateValueI*)e
{
    current = [^(int* state, ORInt variable, ORInt value) {
        return state[[e lookup]];
    } copy];
}
-(void) visitExprValueAssignmentI:(id<ORExpr>)e
{
    current = [^(int* state, ORInt variable, ORInt value) {
        return value;
    } copy];
}
-(void) visitExprLayerVariableI:(id<ORExpr>)e
{
    current = [^(int* state, ORInt variable, ORInt value) {
        return variable;
    } copy];
}
-(void) visitExprSetContainsI:(ORExprSetContainsI*)e
{
    DDClosure right = [self recursiveVisitor:[e value]];
    current = [^(int* state, ORInt variable, ORInt value) {
        return [[e set] member: (int)right(state, variable, value)];
    } copy];
}
-(void) visitExprSetExprContainsI:(ORExprSetExprContainsI*)e
{
    @throw [[ORExecutionError alloc] initORExecutionError: "ExprSetExprContainsI: visit method not defined"];
}
@end

@implementation ORDDMergeClosureGenerator
-(ORDDMergeClosureGenerator*) initORDDMergeClosureGenerator {
    self = [super init];
    return self;
}

-(DDMergeClosure) computeClosure:(id<ORExpr>)e
{
    [e visit: self];
    return current;
}

-(DDMergeClosure) recursiveVisitor:(id<ORExpr>)e
{
    DDMergeClosure old = current;
    current = nil;
    [e visit: self];
    DDMergeClosure returnedValue = current;
    current = old;
    return returnedValue;
}

-(void) visitIntVar:(id<ORIntVar>)v
{
    @throw [[ORExecutionError alloc] initORExecutionError: "IntVar: visit method not defined"];
}

-(void) visitIntegerI: (id<ORInteger>) e
{
    current = [^(int* state1, int* state2) {
        return [e value];
    } copy];
}
-(void) visitMutableIntegerI: (id<ORMutableInteger>) e
{
    @throw [[ORExecutionError alloc] initORExecutionError: "MutableInteger: visit method not defined"];
}
-(void) visitMutableDouble: (id<ORMutableDouble>) e
{
    @throw [[ORExecutionError alloc] initORExecutionError: "MutableDouble: visit method not defined"];
}
-(void) visitDouble: (id<ORDoubleNumber>) e
{
    @throw [[ORExecutionError alloc] initORExecutionError: "DoubleNumber: visit method not defined"];
}
-(void) visitExprPlusI: (ORExprBinaryI*) e
{
    DDMergeClosure left = [self recursiveVisitor:[e left]];
    DDMergeClosure right = [self recursiveVisitor:[e right]];
    current = [(id)^(int* state1, int* state2) {
        return (int)left(state1, state2) + (int)right(state1, state2);  //Only works for ints
    } copy];
}
-(void) visitExprMinusI: (ORExprBinaryI*) e
{
    DDMergeClosure left = [self recursiveVisitor:[e left]];
    DDMergeClosure right = [self recursiveVisitor:[e right]];
    current = [(id)^(int* state1, int* state2) {
        return (int)left(state1, state2) - (int)right(state1, state2);  //Only works for ints
    } copy];
}
-(void) visitExprMulI: (ORExprBinaryI*) e
{
    DDMergeClosure left = [self recursiveVisitor:[e left]];
    DDMergeClosure right = [self recursiveVisitor:[e right]];
    current = [(id)^(int* state1, int* state2) {
        return (int)left(state1, state2) * (int)right(state1, state2);  //Only works for ints
    } copy];
}
-(void) visitExprDivI: (ORExprBinaryI*) e
{
    DDMergeClosure left = [self recursiveVisitor:[e left]];
    DDMergeClosure right = [self recursiveVisitor:[e right]];
    current = [(id)^(int* state1, int* state2) {
        return (int)left(state1, state2) / (int)right(state1, state2);  //Only works for ints
    } copy];
}
-(void) visitExprModI: (ORExprBinaryI*) e
{
    DDMergeClosure left = [self recursiveVisitor:[e left]];
    DDMergeClosure right = [self recursiveVisitor:[e right]];
    current = [(id)^(int* state1, int* state2) {
        return (int)left(state1, state2) % (int)right(state1, state2);  //Only works for ints
    } copy];
}
-(void) visitExprMinI: (ORExprMinI*) e
{
    DDMergeClosure left = [self recursiveVisitor:[e left]];
    DDMergeClosure right = [self recursiveVisitor:[e right]];
    current = [^(int* state1, int* state2) {
        return min((int)left(state1, state2), (int)right(state1, state2));  //Only works for ints
    } copy];
}
-(void) visitExprMaxI: (ORExprMaxI*) e
{
    DDMergeClosure left = [self recursiveVisitor:[e left]];
    DDMergeClosure right = [self recursiveVisitor:[e right]];
    current = [^(int* state1, int* state2) {
        return max((int)left(state1, state2), (int)right(state1, state2));  //Only works for ints
    } copy];
}
-(void) visitExprEqualI: (ORExprBinaryI*) e
{
    DDMergeClosure left = [self recursiveVisitor:[e left]];
    DDMergeClosure right = [self recursiveVisitor:[e right]];
    current = [(id)^(int* state1, int* state2) {
        return left(state1, state2) == right(state1, state2);
    } copy];
}
-(void) visitExprNEqualI: (ORExprBinaryI*) e
{
    DDMergeClosure left = [self recursiveVisitor:[e left]];
    DDMergeClosure right = [self recursiveVisitor:[e right]];
    current = [(id)^(int* state1, int* state2) {
        return left(state1, state2) != right(state1, state2);
    } copy];
}
-(void) visitExprLEqualI: (ORExprBinaryI*) e
{
    DDMergeClosure left = [self recursiveVisitor:[e left]];
    DDMergeClosure right = [self recursiveVisitor:[e right]];
    current = [(id)^(int* state1, int* state2) {
        return (int)left(state1, state2) <= (int)right(state1, state2);  //Only works for ints
    } copy];
}
-(void) visitExprGEqualI: (ORExprBinaryI*) e
{
    DDMergeClosure left = [self recursiveVisitor:[e left]];
    DDMergeClosure right = [self recursiveVisitor:[e right]];
    current = [(id)^(int* state1, int* state2) {
        return (int)left(state1, state2) >= (int)right(state1, state2);  //Only works for ints
    } copy];
}
-(void) visitExprSumI: (id<ORExpr>) e
{
    @throw [[ORExecutionError alloc] initORExecutionError: "ExprSumI: visit method not defined"];
}
-(void) visitExprProdI: (id<ORExpr>) e
{
    @throw [[ORExecutionError alloc] initORExecutionError: "ExprProdI: visit method not defined"];
}
-(void) visitExprAggMinI: (id<ORExpr>) e
{
    @throw [[ORExecutionError alloc] initORExecutionError: "ExprAggMinI: visit method not defined"];
}
-(void) visitExprAggMaxI: (id<ORExpr>) e
{
    @throw [[ORExecutionError alloc] initORExecutionError: "ExprAggMaxI: visit method not defined"];
}
-(void) visitExprAbsI:(ORExprAbsI*) e
{
    DDMergeClosure inner = [self recursiveVisitor:[e operand]];
    current = [^(int* state1, int* state2) {
        return abs((int)inner(state1,state2));
    } copy];
}
-(void) visitExprSquareI:(id<ORExpr>)e
{
    @throw [[ORExecutionError alloc] initORExecutionError: "ExprSquareI: visit method not defined"];
}
-(void) visitExprNegateI:(id<ORExpr>)e
{
    @throw [[ORExecutionError alloc] initORExecutionError: "ExprNegateI: visit method not defined"];
}
-(void) visitExprCstSubI: (id<ORExpr>) e
{
    @throw [[ORExecutionError alloc] initORExecutionError: "ExprCstSubI: visit method not defined"];
}
-(void) visitExprCstDoubleSubI:(id<ORExpr>)e
{
    @throw [[ORExecutionError alloc] initORExecutionError: "ExprCstDoubleSubI: visit method not defined"];
}
-(void) visitExprDisjunctI:(ORExprBinaryI*) e
{
    DDMergeClosure left = [self recursiveVisitor:[e left]];
    DDMergeClosure right = [self recursiveVisitor:[e right]];
    current = [(id)^(int* state1, int* state2) {
        return left(state1, state2) || right(state1, state2);
    } copy];
}
-(void) visitExprConjunctI: (ORExprBinaryI*) e
{
    DDMergeClosure left = [self recursiveVisitor:[e left]];
    DDMergeClosure right = [self recursiveVisitor:[e right]];
    current = [(id)^(int* state1, int* state2) {
        return left(state1, state2) && right(state1, state2);
    } copy];
}
-(void) visitExprImplyI: (ORExprBinaryI*) e
{
    DDMergeClosure left = [self recursiveVisitor:[e left]];
    DDMergeClosure right = [self recursiveVisitor:[e right]];
    current = [(id)^(int* state1, int* state2) {
        return !left(state1, state2) || right(state1, state2);
    } copy];
}
-(void) visitExprAggOrI: (id<ORExpr>) e
{
    @throw [[ORExecutionError alloc] initORExecutionError: "ExprAggOrI: visit method not defined"];
}
-(void) visitExprAggAndI: (id<ORExpr>) e
{
    @throw [[ORExecutionError alloc] initORExecutionError: "ExprAggAndI: visit method not defined"];
}
-(void) visitExprVarSubI: (id<ORExpr>) e
{
    @throw [[ORExecutionError alloc] initORExecutionError: "ExprVarSubI: visit method not defined"];
}
-(void) visitExprMatrixVarSubI:(id<ORExpr>)e
{
    @throw [[ORExecutionError alloc] initORExecutionError: "ExprMatrixVarSubI: visit method not defined"];
}
-(void) visitExprStateValueI:(ORExprStateValueI*)e
{
    current = [^(int* state1, int* state2) {
        if ([e index] == 0) {
            return state1[[e lookup]];
        }
        return state2[[e lookup]];
    } copy];
}
-(void) visitExprValueAssignmentI:(id<ORExpr>)e
{
    @throw [[ORExecutionError alloc] initORExecutionError: "ExprValueAssignmentI: visit method not defined"];
}
-(void) visitExprLayerVariableI:(id<ORExpr>)e
{
    @throw [[ORExecutionError alloc] initORExecutionError: "ExprLayerVariableI: visit method not defined"];
}
-(void) visitExprSetContainsI:(ORExprSetContainsI*)e
{
    DDMergeClosure right = [self recursiveVisitor:[e value]];
    current = [^(int* state1, int* state2) {
        return [[e set] member: (int)right(state1, state2)];
    } copy];
}
-(void) visitExprSetExprContainsI:(id<ORExpr>)e
{
    @throw [[ORExecutionError alloc] initORExecutionError: "ExprSetExprContainsI: visit method not defined"];
}
@end


@implementation ORAltMDDParentChildEdgeClosureGenerator
-(ORAltMDDParentChildEdgeClosureGenerator*) initORAltMDDParentChildEdgeClosureGenerator
{
    self = [super init];
    return self;
}
-(AltMDDDeleteEdgeCheckClosure) computeClosure:(id<ORExpr>)e
{
    [e visit: self];
    return current;
}
-(AltMDDDeleteEdgeCheckClosure) recursiveVisitor:(id<ORExpr>)e
{
    AltMDDDeleteEdgeCheckClosure old = current;
    current = nil;
    [e visit: self];
    AltMDDDeleteEdgeCheckClosure returnedValue = current;
    current = old;
    return returnedValue;
}

-(void) visitIntVar:(id<ORIntVar>)v
{
    @throw [[ORExecutionError alloc] initORExecutionError: "IntVar: visit method not defined"];
}

-(void) visitIntegerI: (id<ORInteger>) e
{
    current = [(id)^(id parent,id child,ORInt variable,ORInt value) {
        return [e value];
    } copy];
}
-(void) visitMutableIntegerI: (id<ORMutableInteger>) e
{
    @throw [[ORExecutionError alloc] initORExecutionError: "MutableInteger: visit method not defined"];
}
-(void) visitMutableDouble: (id<ORMutableDouble>) e
{
    @throw [[ORExecutionError alloc] initORExecutionError: "MutableDouble: visit method not defined"];
}
-(void) visitDouble: (id<ORDoubleNumber>) e
{
    @throw [[ORExecutionError alloc] initORExecutionError: "DoubleNumber: visit method not defined"];
}
-(void) visitExprPlusI: (ORExprBinaryI*) e
{
    AltMDDDeleteEdgeCheckClosure left = [self recursiveVisitor:[e left]];
    AltMDDDeleteEdgeCheckClosure right = [self recursiveVisitor:[e right]];
    current = [^(id parent,id child,ORInt variable,ORInt value) {
        return (int)left(parent, child, variable, value) + (int)right(parent, child, variable, value);  //Only works for ints
    } copy];
}
-(void) visitExprMinusI: (ORExprBinaryI*) e
{
    AltMDDDeleteEdgeCheckClosure left = [self recursiveVisitor:[e left]];
    AltMDDDeleteEdgeCheckClosure right = [self recursiveVisitor:[e right]];
    current = [^(id parent,id child,ORInt variable,ORInt value) {
        return (int)left(parent, child, variable, value) - (int)right(parent, child, variable, value);  //Only works for ints
    } copy];
}
-(void) visitExprMulI: (ORExprBinaryI*) e
{
    AltMDDDeleteEdgeCheckClosure left = [self recursiveVisitor:[e left]];
    AltMDDDeleteEdgeCheckClosure right = [self recursiveVisitor:[e right]];
    current = [^(id parent,id child,ORInt variable,ORInt value) {
        return (int)left(parent, child, variable, value) * (int)right(parent, child, variable, value);  //Only works for ints
    } copy];
}
-(void) visitExprDivI: (ORExprBinaryI*) e
{
    AltMDDDeleteEdgeCheckClosure left = [self recursiveVisitor:[e left]];
    AltMDDDeleteEdgeCheckClosure right = [self recursiveVisitor:[e right]];
    current = [^(id parent,id child,ORInt variable,ORInt value) {
        return (int)left(parent, child, variable, value) / (int)right(parent, child, variable, value);  //Only works for ints
    } copy];
}
-(void) visitExprModI: (ORExprBinaryI*) e
{
    AltMDDDeleteEdgeCheckClosure left = [self recursiveVisitor:[e left]];
    AltMDDDeleteEdgeCheckClosure right = [self recursiveVisitor:[e right]];
    current = [^(id parent,id child,ORInt variable,ORInt value) {
        return (int)left(parent, child, variable, value) % (int)right(parent, child, variable, value);  //Only works for ints
    } copy];
}
-(void) visitExprMinI: (ORExprMinI*) e
{
    AltMDDDeleteEdgeCheckClosure left = [self recursiveVisitor:[e left]];
    AltMDDDeleteEdgeCheckClosure right = [self recursiveVisitor:[e right]];
    current = [^(id parent,id child,ORInt variable,ORInt value) {
        return min((int)left(parent, child, variable, value), (int)right(parent, child, variable, value));  //Only works for ints
    } copy];
}
-(void) visitExprMaxI: (ORExprMaxI*) e
{
    AltMDDDeleteEdgeCheckClosure left = [self recursiveVisitor:[e left]];
    AltMDDDeleteEdgeCheckClosure right = [self recursiveVisitor:[e right]];
    current = [^(id parent,id child,ORInt variable,ORInt value) {
        return max((int)left(parent, child, variable, value), (int)right(parent, child, variable, value));  //Only works for ints
    } copy];
}
-(void) visitExprEqualI: (ORExprBinaryI*) e
{
    AltMDDDeleteEdgeCheckClosure left = [self recursiveVisitor:[e left]];
    AltMDDDeleteEdgeCheckClosure right = [self recursiveVisitor:[e right]];
    current = [^(id parent,id child,ORInt variable,ORInt value) {
        return left(parent, child, variable, value) == right(parent, child, variable, value);
    } copy];
}
-(void) visitExprNEqualI: (ORExprBinaryI*) e
{
    AltMDDDeleteEdgeCheckClosure left = [self recursiveVisitor:[e left]];
    AltMDDDeleteEdgeCheckClosure right = [self recursiveVisitor:[e right]];
    current = [^(id parent,id child,ORInt variable,ORInt value) {
        return left(parent, child, variable, value) != right(parent, child, variable, value);
    } copy];
}
-(void) visitExprLEqualI: (ORExprBinaryI*) e
{
    AltMDDDeleteEdgeCheckClosure left = [self recursiveVisitor:[e left]];
    AltMDDDeleteEdgeCheckClosure right = [self recursiveVisitor:[e right]];
    current = [^(id parent,id child,ORInt variable,ORInt value) {
        return (int)left(parent, child, variable, value) <= (int)right(parent, child, variable, value);  //Only works for ints
    } copy];
}
-(void) visitExprGEqualI: (ORExprBinaryI*) e
{
    AltMDDDeleteEdgeCheckClosure left = [self recursiveVisitor:[e left]];
    AltMDDDeleteEdgeCheckClosure right = [self recursiveVisitor:[e right]];
    current = [^(id parent,id child,ORInt variable,ORInt value) {
        return (int)left(parent, child, variable, value) >= (int)right(parent, child, variable, value);  //Only works for ints
    } copy];
}
-(void) visitExprSumI: (id<ORExpr>) e
{
    @throw [[ORExecutionError alloc] initORExecutionError: "ExprSumI: visit method not defined"];
}
-(void) visitExprProdI: (id<ORExpr>) e
{
    @throw [[ORExecutionError alloc] initORExecutionError: "ExprProdI: visit method not defined"];
}
-(void) visitExprAggMinI: (id<ORExpr>) e
{
    @throw [[ORExecutionError alloc] initORExecutionError: "ExprAggMinI: visit method not defined"];
}
-(void) visitExprAggMaxI: (id<ORExpr>) e
{
    @throw [[ORExecutionError alloc] initORExecutionError: "ExprAggMaxI: visit method not defined"];
}
-(void) visitExprAbsI:(ORExprAbsI*) e
{
    AltMDDDeleteEdgeCheckClosure inner = [self recursiveVisitor:[e operand]];
    current = [^(id parent,id child,ORInt variable,ORInt value) {
        return abs((int)inner(parent, child, variable, value));
    } copy];
}
-(void) visitExprSquareI:(id<ORExpr>)e
{
    @throw [[ORExecutionError alloc] initORExecutionError: "ExprSquareI: visit method not defined"];
}
-(void) visitExprNegateI:(ORExprNegateI*)e
{
    AltMDDDeleteEdgeCheckClosure inner = [self recursiveVisitor:[e operand]];
    current = [^(id parent,id child,ORInt variable,ORInt value) {
        return !((bool)inner(parent, child, variable, value));
    } copy];
}
-(void) visitExprCstSubI: (id<ORExpr>) e
{
    @throw [[ORExecutionError alloc] initORExecutionError: "ExprCstSubI: visit method not defined"];
}
-(void) visitExprCstDoubleSubI:(id<ORExpr>)e
{
    @throw [[ORExecutionError alloc] initORExecutionError: "ExprCstDoubleSubI: visit method not defined"];
}
-(void) visitExprDisjunctI:(ORExprBinaryI*) e
{
    AltMDDDeleteEdgeCheckClosure left = [self recursiveVisitor:[e left]];
    AltMDDDeleteEdgeCheckClosure right = [self recursiveVisitor:[e right]];
    current = [^(id parent,id child,ORInt variable,ORInt value) {
        return left(parent, child, variable, value) || right(parent, child, variable, value);
    } copy];
}
-(void) visitExprConjunctI: (ORExprBinaryI*) e
{
    AltMDDDeleteEdgeCheckClosure left = [self recursiveVisitor:[e left]];
    AltMDDDeleteEdgeCheckClosure right = [self recursiveVisitor:[e right]];
    current = [^(id parent,id child,ORInt variable,ORInt value) {
        return left(parent, child, variable, value) && right(parent, child, variable, value);
    } copy];
}
-(void) visitExprImplyI: (ORExprBinaryI*) e
{
    AltMDDDeleteEdgeCheckClosure left = [self recursiveVisitor:[e left]];
    AltMDDDeleteEdgeCheckClosure right = [self recursiveVisitor:[e right]];
    current = [^(id parent,id child,ORInt variable,ORInt value) {
        return !left(parent, child, variable, value) || right(parent, child, variable, value);
    } copy];
}
-(void) visitExprAggOrI: (id<ORExpr>) e
{
    @throw [[ORExecutionError alloc] initORExecutionError: "ExprAggOrI: visit method not defined"];
}
-(void) visitExprAggAndI: (id<ORExpr>) e
{
    @throw [[ORExecutionError alloc] initORExecutionError: "ExprAggAndI: visit method not defined"];
}
-(void) visitExprVarSubI: (id<ORExpr>) e
{
    @throw [[ORExecutionError alloc] initORExecutionError: "ExprVarSubI: visit method not defined"];
}
-(void) visitExprMatrixVarSubI:(id<ORExpr>)e
{
    @throw [[ORExecutionError alloc] initORExecutionError: "ExprMatrixVarSubI: visit method not defined"];
}
-(void) visitExprStateValueI:(ORExprStateValueI*)e
{
    @throw [[ORExecutionError alloc] initORExecutionError: "ExprStateValueI: visit method not defined"];
}
-(void) visitExprValueAssignmentI:(id<ORExpr>)e
{
    current = [^(id parent,id child,ORInt variable,ORInt value) {
        return value;
    } copy];
}
-(void) visitExprLayerVariableI:(id<ORExpr>)e
{
    current = [^(id parent,id child,ORInt variable,ORInt value) {
        return variable;
    } copy];
}
-(void) visitExprSetContainsI:(ORExprSetContainsI*)e
{
    AltMDDDeleteEdgeCheckClosure right = [self recursiveVisitor:[e value]];
    current = [^(id parent,id child,ORInt variable,ORInt value) {
        return [[e set] member: (int)right(parent, child, variable, value)];
    } copy];
}
-(void) visitExprSetExprContainsI:(ORExprBinaryI*)e
{
    AltMDDDeleteEdgeCheckClosure left = [self recursiveVisitor:[e left]];
    AltMDDDeleteEdgeCheckClosure right = [self recursiveVisitor:[e right]];
    current = [^(id parent,id child,ORInt variable,ORInt value) {
        return [(NSSet*)left(parent,child,variable,value) member: [[NSNumber alloc] initWithInt: (int)right(parent, child, variable, value)]];
    } copy];
}
//I think the problem is everything is expected to return ints.  Try chaning everything to id and using NSBool or something when needed?
-(void) visitExprParentInformationI:(id<ORExpr>)e
{
    current = [(id)^(id parent,id child,ORInt variable,ORInt value) {
        return parent;
    } copy];
}
-(void) visitExprChildInformationI:(id<ORExpr>)e
{
    current = [(id)^(id parent,id child,ORInt variable,ORInt value) {
        return child;
    } copy];
}
-(void) visitExprEachInSetPlusI:(ORExprBinaryI*)e
{
    AltMDDDeleteEdgeCheckClosure left = [self recursiveVisitor:[e left]];
    AltMDDDeleteEdgeCheckClosure right = [self recursiveVisitor:[e right]];
    current = [(id)^(id parent,id child,ORInt variable,ORInt value) {
        NSSet* set = (NSSet*)left(parent,child,variable,value);
        NSMutableSet* newSet = [[NSMutableSet alloc] init];
        int addition = (int)right(parent,child,variable,value);
        for (NSNumber* item in set) {
            [newSet addObject:[[NSNumber alloc] initWithInt:[item intValue]+addition]];
        }
        return newSet;
    } copy];
}
-(void) visitExprEachInSetPlusEachInSetI:(ORExprBinaryI*)e
{
    AltMDDDeleteEdgeCheckClosure left = [self recursiveVisitor:[e left]];
    AltMDDDeleteEdgeCheckClosure right = [self recursiveVisitor:[e right]];
    current = [(id)^(id parent,id child,ORInt variable,ORInt value) {
        NSSet* set1 = (NSSet*)left(parent,child,variable,value);
        NSSet* set2 = (NSSet*)right(parent,child,variable,value);
        NSMutableSet* newSet = [[NSMutableSet alloc] init];
        for (NSNumber* item1 in set1) {
            int num1 = [item1 intValue];
            for (NSNumber* item2 in set2) {
                [newSet addObject:[[NSNumber alloc] initWithInt:(num1+[item2 intValue])]];
            }
        }
        return newSet;
    } copy];
}
-(void) visitExprEachInSetLEQI:(ORExprBinaryI*)e
{
    AltMDDDeleteEdgeCheckClosure left = [self recursiveVisitor:[e left]];
    AltMDDDeleteEdgeCheckClosure right = [self recursiveVisitor:[e right]];
    current = [^(id parent,id child,ORInt variable,ORInt value) {
        NSSet* set = (NSSet*)left(parent,child,variable,value);
        int upper = (int)right(parent,child,variable,value);
        for (NSNumber* item in set) {
            if ([item intValue] > upper) {
                return false;
            }
        }
        return true;
    } copy];
}
-(void) visitExprEachInSetGEQI:(ORExprBinaryI*)e
{
    AltMDDDeleteEdgeCheckClosure left = [self recursiveVisitor:[e left]];
    AltMDDDeleteEdgeCheckClosure right = [self recursiveVisitor:[e right]];
    current = [^(id parent,id child,ORInt variable,ORInt value) {
        NSSet* set = (NSSet*)left(parent,child,variable,value);
        int lower = (int)right(parent,child,variable,value);
        for (NSNumber* item in set) {
            if ([item intValue] < lower) {
                return false;
            }
        }
        return true;
    } copy];
}
@end
@implementation ORAltMDDLeftRightClosureGenerator
-(ORAltMDDLeftRightClosureGenerator*) initORAltMDDLeftRightClosureGenerator
{
    self = [super init];
    return self;
}
-(AltMDDMergeInfoClosure) computeClosure:(id<ORExpr>)e
{
    [e visit: self];
    return current;
}
-(AltMDDMergeInfoClosure) recursiveVisitor:(id<ORExpr>)e
{
    AltMDDMergeInfoClosure old = current;
    current = nil;
    [e visit: self];
    AltMDDMergeInfoClosure returnedValue = current;
    current = old;
    return returnedValue;
}

-(void) visitIntVar:(id<ORIntVar>)v
{
    @throw [[ORExecutionError alloc] initORExecutionError: "IntVar: visit method not defined"];
}

-(void) visitIntegerI: (id<ORInteger>) e
{
    current = [(id)^(id left,id right,ORInt variable) {
        return [e value];
    } copy];
}
-(void) visitMutableIntegerI: (id<ORMutableInteger>) e
{
    @throw [[ORExecutionError alloc] initORExecutionError: "MutableInteger: visit method not defined"];
}
-(void) visitMutableDouble: (id<ORMutableDouble>) e
{
    @throw [[ORExecutionError alloc] initORExecutionError: "MutableDouble: visit method not defined"];
}
-(void) visitDouble: (id<ORDoubleNumber>) e
{
    @throw [[ORExecutionError alloc] initORExecutionError: "DoubleNumber: visit method not defined"];
}
-(void) visitExprPlusI: (ORExprBinaryI*) e
{
    AltMDDMergeInfoClosure left = [self recursiveVisitor:[e left]];
    AltMDDMergeInfoClosure right = [self recursiveVisitor:[e right]];
    current = [(id)^(id leftParent,id rightParent,ORInt variable) {
        return (int)left(leftParent, rightParent, variable) + (int)right(leftParent, rightParent, variable);  //Only works for ints
    } copy];
}
-(void) visitExprMinusI: (ORExprBinaryI*) e
{
    AltMDDMergeInfoClosure left = [self recursiveVisitor:[e left]];
    AltMDDMergeInfoClosure right = [self recursiveVisitor:[e right]];
    current = [(id)^(id leftParent,id rightParent,ORInt variable) {
        return (int)left(leftParent, rightParent, variable) - (int)right(leftParent, rightParent, variable);  //Only works for ints
    } copy];
}
-(void) visitExprMulI: (ORExprBinaryI*) e
{
    AltMDDMergeInfoClosure left = [self recursiveVisitor:[e left]];
    AltMDDMergeInfoClosure right = [self recursiveVisitor:[e right]];
    current = [(id)^(id leftParent,id rightParent,ORInt variable) {
        return (int)left(leftParent, rightParent, variable) * (int)right(leftParent, rightParent, variable);  //Only works for ints
    } copy];
}
-(void) visitExprDivI: (ORExprBinaryI*) e
{
    AltMDDMergeInfoClosure left = [self recursiveVisitor:[e left]];
    AltMDDMergeInfoClosure right = [self recursiveVisitor:[e right]];
    current = [(id)^(id leftParent,id rightParent,ORInt variable) {
        return (int)left(leftParent, rightParent, variable) / (int)right(leftParent, rightParent, variable);  //Only works for ints
    } copy];
}
-(void) visitExprModI: (ORExprBinaryI*) e
{
    AltMDDMergeInfoClosure left = [self recursiveVisitor:[e left]];
    AltMDDMergeInfoClosure right = [self recursiveVisitor:[e right]];
    current = [(id)^(id leftParent,id rightParent,ORInt variable) {
        return (int)left(leftParent, rightParent, variable) % (int)right(leftParent, rightParent, variable);  //Only works for ints
    } copy];
}
-(void) visitExprMinI: (ORExprMinI*) e
{
    AltMDDMergeInfoClosure left = [self recursiveVisitor:[e left]];
    AltMDDMergeInfoClosure right = [self recursiveVisitor:[e right]];
    current = [(id)^(id leftParent,id rightParent,ORInt variable) {
        return min((int)left(leftParent, rightParent, variable), (int)right(leftParent, rightParent, variable));  //Only works for ints
    } copy];
}
-(void) visitExprMaxI: (ORExprMaxI*) e
{
    AltMDDMergeInfoClosure left = [self recursiveVisitor:[e left]];
    AltMDDMergeInfoClosure right = [self recursiveVisitor:[e right]];
    current = [(id)^(id leftParent,id rightParent,ORInt variable) {
        return max((int)left(leftParent, rightParent, variable), (int)right(leftParent, rightParent, variable));  //Only works for ints
    } copy];
}
-(void) visitExprEqualI: (ORExprBinaryI*) e
{
    AltMDDMergeInfoClosure left = [self recursiveVisitor:[e left]];
    AltMDDMergeInfoClosure right = [self recursiveVisitor:[e right]];
    current = [(id)^(id leftParent,id rightParent,ORInt variable) {
        return left(leftParent, rightParent, variable) == right(leftParent, rightParent, variable);
    } copy];
}
-(void) visitExprNEqualI: (ORExprBinaryI*) e
{
    AltMDDMergeInfoClosure left = [self recursiveVisitor:[e left]];
    AltMDDMergeInfoClosure right = [self recursiveVisitor:[e right]];
    current = [(id)^(id leftParent,id rightParent,ORInt variable) {
        return left(leftParent, rightParent, variable) != right(leftParent, rightParent, variable);
    } copy];
}
-(void) visitExprLEqualI: (ORExprBinaryI*) e
{
    AltMDDMergeInfoClosure left = [self recursiveVisitor:[e left]];
    AltMDDMergeInfoClosure right = [self recursiveVisitor:[e right]];
    current = [(id)^(id leftParent,id rightParent,ORInt variable) {
        return (int)left(leftParent, rightParent, variable) <= (int)right(leftParent, rightParent, variable);  //Only works for ints
    } copy];
}
-(void) visitExprGEqualI: (ORExprBinaryI*) e
{
    AltMDDMergeInfoClosure left = [self recursiveVisitor:[e left]];
    AltMDDMergeInfoClosure right = [self recursiveVisitor:[e right]];
    current = [(id)^(id leftParent,id rightParent,ORInt variable) {
        return (int)left(leftParent, rightParent, variable) >= (int)right(leftParent, rightParent, variable);  //Only works for ints
    } copy];
}
-(void) visitExprSumI: (id<ORExpr>) e
{
    @throw [[ORExecutionError alloc] initORExecutionError: "ExprSumI: visit method not defined"];
}
-(void) visitExprProdI: (id<ORExpr>) e
{
    @throw [[ORExecutionError alloc] initORExecutionError: "ExprProdI: visit method not defined"];
}
-(void) visitExprAggMinI: (id<ORExpr>) e
{
    @throw [[ORExecutionError alloc] initORExecutionError: "ExprAggMinI: visit method not defined"];
}
-(void) visitExprAggMaxI: (id<ORExpr>) e
{
    @throw [[ORExecutionError alloc] initORExecutionError: "ExprAggMaxI: visit method not defined"];
}
-(void) visitExprAbsI:(ORExprAbsI*) e
{
    AltMDDMergeInfoClosure inner = [self recursiveVisitor:[e operand]];
    current = [(id)^(id leftParent,id rightParent,ORInt variable) {
        return abs((int)inner(leftParent, rightParent, variable));
    } copy];
}
-(void) visitExprSquareI:(id<ORExpr>)e
{
    @throw [[ORExecutionError alloc] initORExecutionError: "ExprSquareI: visit method not defined"];
}
-(void) visitExprNegateI:(id<ORExpr>)e
{
    @throw [[ORExecutionError alloc] initORExecutionError: "ExprNegateI: visit method not defined"];
}
-(void) visitExprCstSubI: (id<ORExpr>) e
{
    @throw [[ORExecutionError alloc] initORExecutionError: "ExprCstSubI: visit method not defined"];
}
-(void) visitExprCstDoubleSubI:(id<ORExpr>)e
{
    @throw [[ORExecutionError alloc] initORExecutionError: "ExprCstDoubleSubI: visit method not defined"];
}
-(void) visitExprDisjunctI:(ORExprBinaryI*) e
{
    AltMDDMergeInfoClosure left = [self recursiveVisitor:[e left]];
    AltMDDMergeInfoClosure right = [self recursiveVisitor:[e right]];
    current = [(id)^(id leftParent,id rightParent,ORInt variable) {
        return left(leftParent, rightParent, variable) || right(leftParent, rightParent, variable);
    } copy];
}
-(void) visitExprConjunctI: (ORExprBinaryI*) e
{
    AltMDDMergeInfoClosure left = [self recursiveVisitor:[e left]];
    AltMDDMergeInfoClosure right = [self recursiveVisitor:[e right]];
    current = [(id)^(id leftParent,id rightParent,ORInt variable) {
        return left(leftParent, rightParent, variable) && right(leftParent, rightParent, variable);
    } copy];
}
-(void) visitExprImplyI: (ORExprBinaryI*) e
{
    AltMDDMergeInfoClosure left = [self recursiveVisitor:[e left]];
    AltMDDMergeInfoClosure right = [self recursiveVisitor:[e right]];
    current = [(id)^(id leftParent,id rightParent,ORInt variable) {
        return !left(leftParent, rightParent, variable) || right(leftParent, rightParent, variable);
    } copy];
}
-(void) visitExprAggOrI: (id<ORExpr>) e
{
    @throw [[ORExecutionError alloc] initORExecutionError: "ExprAggOrI: visit method not defined"];
}
-(void) visitExprAggAndI: (id<ORExpr>) e
{
    @throw [[ORExecutionError alloc] initORExecutionError: "ExprAggAndI: visit method not defined"];
}
-(void) visitExprVarSubI: (id<ORExpr>) e
{
    @throw [[ORExecutionError alloc] initORExecutionError: "ExprVarSubI: visit method not defined"];
}
-(void) visitExprMatrixVarSubI:(id<ORExpr>)e
{
    @throw [[ORExecutionError alloc] initORExecutionError: "ExprMatrixVarSubI: visit method not defined"];
}
-(void) visitExprStateValueI:(ORExprStateValueI*)e
{
    @throw [[ORExecutionError alloc] initORExecutionError: "ExprStateValueI: visit method not defined"];
}
-(void) visitExprSetExprContainsI:(ORExprBinaryI*)e
{
    AltMDDMergeInfoClosure left = [self recursiveVisitor:[e left]];
    AltMDDMergeInfoClosure right = [self recursiveVisitor:[e right]];
    current = [^(id leftParent,id rightParent,ORInt variable) {
        return [(NSSet*)left(leftParent, rightParent, variable) member: [[NSNumber alloc] initWithInt: (int)right(leftParent, rightParent, variable)]];
    } copy];
}
-(void) visitExprSetUnionI:(ORExprBinaryI*)e
{
    AltMDDMergeInfoClosure left = [self recursiveVisitor:[e left]];
    AltMDDMergeInfoClosure right = [self recursiveVisitor:[e right]];
    current = [^(id leftParent,id rightParent,ORInt variable) {
        return [[[NSSet alloc] initWithSet:(NSSet*)left(leftParent, rightParent, variable)] setByAddingObjectsFromSet:(NSSet*)right(leftParent, rightParent, variable)];
    } copy];
}
-(void) visitExprValueAssignmentI:(id<ORExpr>)e
{
    @throw [[ORExecutionError alloc] initORExecutionError: "ExprValueAssignmentI: visit method not defined"];
}
-(void) visitExprLayerVariableI:(id<ORExpr>)e
{
    current = [^(id leftParent,id rightParent,ORInt variable) {
        return variable;
    } copy];
}
-(void) visitExprSetContainsI:(ORExprSetContainsI*)e
{
    AltMDDMergeInfoClosure right = [self recursiveVisitor:[e value]];
    current = [(id)^(id leftParent,id rightParent,ORInt variable) {
        return [[e set] member: (int)right(leftParent, rightParent, variable)];
    } copy];
}
-(void) visitExprParentInformationI:(id<ORExpr>)e
{
    @throw [[ORExecutionError alloc] initORExecutionError: "ExprParentInformationI: visit method not defined"];
}
-(void) visitExprChildInformationI:(id<ORExpr>)e
{
    @throw [[ORExecutionError alloc] initORExecutionError: "ExprChildInformationI: visit method not defined"];
}
-(void) visitExprLeftInformationI:(id<ORExpr>)e
{
    current = [(id)^(id leftParent,id rightParent,ORInt variable) {
        return leftParent;
    } copy];
}
-(void) visitExprRightInformationI:(id<ORExpr>)e
{
    current = [(id)^(id leftParent,id rightParent,ORInt variable) {
        return rightParent;
    } copy];
}
-(void) visitExprSingletonSetI:(ORExprSingletonSetI*)e
{
    AltMDDMergeInfoClosure inner = [self recursiveVisitor:[e value]];
    current = [^(id leftParent,id rightParent,ORInt variable) {
        return [[NSSet alloc] initWithObjects:[[NSNumber alloc] initWithInt:(ORInt)inner(leftParent,rightParent,variable)], nil];    //Only works for ints for now
    } copy];
}
@end
@implementation ORAltMDDParentEdgeClosureGenerator
-(ORAltMDDParentEdgeClosureGenerator*) initORAltMDDParentEdgeClosureGenerator
{
    self = [super init];
    return self;
}
-(AltMDDAddEdgeClosure) computeClosure:(id<ORExpr>)e
{
    [e visit: self];
    return current;
}
-(AltMDDAddEdgeClosure) recursiveVisitor:(id<ORExpr>)e
{
    AltMDDAddEdgeClosure old = current;
    current = nil;
    [e visit: self];
    AltMDDAddEdgeClosure returnedValue = current;
    current = old;
    return returnedValue;
}

-(void) visitIntVar:(id<ORIntVar>)v
{
    @throw [[ORExecutionError alloc] initORExecutionError: "IntVar: visit method not defined"];
}

-(void) visitIntegerI: (id<ORInteger>) e
{
    current = [(id)^(id parent,ORInt variable,ORInt value) {
        return [e value];
    } copy];
}
-(void) visitMutableIntegerI: (id<ORMutableInteger>) e
{
    @throw [[ORExecutionError alloc] initORExecutionError: "MutableInteger: visit method not defined"];
}
-(void) visitMutableDouble: (id<ORMutableDouble>) e
{
    @throw [[ORExecutionError alloc] initORExecutionError: "MutableDouble: visit method not defined"];
}
-(void) visitDouble: (id<ORDoubleNumber>) e
{
    @throw [[ORExecutionError alloc] initORExecutionError: "DoubleNumber: visit method not defined"];
}
-(void) visitExprPlusI: (ORExprBinaryI*) e
{
    AltMDDAddEdgeClosure left = [self recursiveVisitor:[e left]];
    AltMDDAddEdgeClosure right = [self recursiveVisitor:[e right]];
    current = [(id)^(id parent,ORInt variable,ORInt value) {
        return (int)left(parent, variable, value) + (int)right(parent, variable, value);  //Only works for ints
    } copy];
}
-(void) visitExprMinusI: (ORExprBinaryI*) e
{
    AltMDDAddEdgeClosure left = [self recursiveVisitor:[e left]];
    AltMDDAddEdgeClosure right = [self recursiveVisitor:[e right]];
    current = [(id)^(id parent,ORInt variable,ORInt value) {
        return (int)left(parent, variable, value) - (int)right(parent, variable, value);  //Only works for ints
    } copy];
}
-(void) visitExprMulI: (ORExprBinaryI*) e
{
    AltMDDAddEdgeClosure left = [self recursiveVisitor:[e left]];
    AltMDDAddEdgeClosure right = [self recursiveVisitor:[e right]];
    current = [(id)^(id parent,ORInt variable,ORInt value) {
        return (int)left(parent, variable, value) * (int)right(parent, variable, value);  //Only works for ints
    } copy];
}
-(void) visitExprDivI: (ORExprBinaryI*) e
{
    AltMDDAddEdgeClosure left = [self recursiveVisitor:[e left]];
    AltMDDAddEdgeClosure right = [self recursiveVisitor:[e right]];
    current = [(id)^(id parent,ORInt variable,ORInt value) {
        return (int)left(parent, variable, value) / (int)right(parent, variable, value);  //Only works for ints
    } copy];
}
-(void) visitExprModI: (ORExprBinaryI*) e
{
    AltMDDAddEdgeClosure left = [self recursiveVisitor:[e left]];
    AltMDDAddEdgeClosure right = [self recursiveVisitor:[e right]];
    current = [(id)^(id parent,ORInt variable,ORInt value) {
        return (int)left(parent, variable, value) % (int)right(parent, variable, value);  //Only works for ints
    } copy];
}
-(void) visitExprMinI: (ORExprMinI*) e
{
    AltMDDAddEdgeClosure left = [self recursiveVisitor:[e left]];
    AltMDDAddEdgeClosure right = [self recursiveVisitor:[e right]];
    current = [(id)^(id parent,ORInt variable,ORInt value) {
        return min((int)left(parent, variable, value), (int)right(parent, variable, value));  //Only works for ints
    } copy];
}
-(void) visitExprMaxI: (ORExprMaxI*) e
{
    AltMDDAddEdgeClosure left = [self recursiveVisitor:[e left]];
    AltMDDAddEdgeClosure right = [self recursiveVisitor:[e right]];
    current = [(id)^(id parent,ORInt variable,ORInt value) {
        return max((int)left(parent, variable, value), (int)right(parent, variable, value));  //Only works for ints
    } copy];
}
-(void) visitExprEqualI: (ORExprBinaryI*) e
{
    AltMDDAddEdgeClosure left = [self recursiveVisitor:[e left]];
    AltMDDAddEdgeClosure right = [self recursiveVisitor:[e right]];
    current = [(id)^(id parent,ORInt variable,ORInt value) {
        return left(parent, variable, value) == right(parent, variable, value);
    } copy];
}
-(void) visitExprNEqualI: (ORExprBinaryI*) e
{
    AltMDDAddEdgeClosure left = [self recursiveVisitor:[e left]];
    AltMDDAddEdgeClosure right = [self recursiveVisitor:[e right]];
    current = [(id)^(id parent,ORInt variable,ORInt value) {
        return left(parent, variable, value) != right(parent, variable, value);
    } copy];
}
-(void) visitExprLEqualI: (ORExprBinaryI*) e
{
    AltMDDAddEdgeClosure left = [self recursiveVisitor:[e left]];
    AltMDDAddEdgeClosure right = [self recursiveVisitor:[e right]];
    current = [(id)^(id parent,ORInt variable,ORInt value) {
        return (int)left(parent, variable, value) <= (int)right(parent, variable, value);  //Only works for ints
    } copy];
}
-(void) visitExprGEqualI: (ORExprBinaryI*) e
{
    AltMDDAddEdgeClosure left = [self recursiveVisitor:[e left]];
    AltMDDAddEdgeClosure right = [self recursiveVisitor:[e right]];
    current = [(id)^(id parent,ORInt variable,ORInt value) {
        return (int)left(parent, variable, value) >= (int)right(parent, variable, value);  //Only works for ints
    } copy];
}
-(void) visitExprSumI: (id<ORExpr>) e
{
    @throw [[ORExecutionError alloc] initORExecutionError: "ExprSumI: visit method not defined"];
}
-(void) visitExprProdI: (id<ORExpr>) e
{
    @throw [[ORExecutionError alloc] initORExecutionError: "ExprProdI: visit method not defined"];
}
-(void) visitExprAggMinI: (id<ORExpr>) e
{
    @throw [[ORExecutionError alloc] initORExecutionError: "ExprAggMinI: visit method not defined"];
}
-(void) visitExprAggMaxI: (id<ORExpr>) e
{
    @throw [[ORExecutionError alloc] initORExecutionError: "ExprAggMaxI: visit method not defined"];
}
-(void) visitExprAbsI:(ORExprAbsI*) e
{
    AltMDDAddEdgeClosure inner = [self recursiveVisitor:[e operand]];
    current = [(id)^(id parent,ORInt variable,ORInt value) {
        return abs((int)inner(parent, variable, value));
    } copy];
}
-(void) visitExprSquareI:(id<ORExpr>)e
{
    @throw [[ORExecutionError alloc] initORExecutionError: "ExprSquareI: visit method not defined"];
}
-(void) visitExprNegateI:(id<ORExpr>)e
{
    @throw [[ORExecutionError alloc] initORExecutionError: "ExprNegateI: visit method not defined"];
}
-(void) visitExprCstSubI: (id<ORExpr>) e
{
    @throw [[ORExecutionError alloc] initORExecutionError: "ExprCstSubI: visit method not defined"];
}
-(void) visitExprCstDoubleSubI:(id<ORExpr>)e
{
    @throw [[ORExecutionError alloc] initORExecutionError: "ExprCstDoubleSubI: visit method not defined"];
}
-(void) visitExprDisjunctI:(ORExprBinaryI*) e
{
    AltMDDAddEdgeClosure left = [self recursiveVisitor:[e left]];
    AltMDDAddEdgeClosure right = [self recursiveVisitor:[e right]];
    current = [(id)^(id parent,ORInt variable,ORInt value) {
        return left(parent, variable, value) || right(parent, variable, value);
    } copy];
}
-(void) visitExprConjunctI: (ORExprBinaryI*) e
{
    AltMDDAddEdgeClosure left = [self recursiveVisitor:[e left]];
    AltMDDAddEdgeClosure right = [self recursiveVisitor:[e right]];
    current = [(id)^(id parent,ORInt variable,ORInt value) {
        return left(parent, variable, value) && right(parent, variable, value);
    } copy];
}
-(void) visitExprImplyI: (ORExprBinaryI*) e
{
    AltMDDAddEdgeClosure left = [self recursiveVisitor:[e left]];
    AltMDDAddEdgeClosure right = [self recursiveVisitor:[e right]];
    current = [(id)^(id parent,ORInt variable,ORInt value) {
        return !left(parent, variable, value) || right(parent, variable, value);
    } copy];
}
-(void) visitExprAggOrI: (id<ORExpr>) e
{
    @throw [[ORExecutionError alloc] initORExecutionError: "ExprAggOrI: visit method not defined"];
}
-(void) visitExprAggAndI: (id<ORExpr>) e
{
    @throw [[ORExecutionError alloc] initORExecutionError: "ExprAggAndI: visit method not defined"];
}
-(void) visitExprVarSubI: (id<ORExpr>) e
{
    @throw [[ORExecutionError alloc] initORExecutionError: "ExprVarSubI: visit method not defined"];
}
-(void) visitExprMatrixVarSubI:(id<ORExpr>)e
{
    @throw [[ORExecutionError alloc] initORExecutionError: "ExprMatrixVarSubI: visit method not defined"];
}
-(void) visitExprStateValueI:(ORExprStateValueI*)e
{
    @throw [[ORExecutionError alloc] initORExecutionError: "ExprStateValueI: visit method not defined"];
}
-(void) visitExprSetExprContainsI:(ORExprBinaryI*)e
{
    AltMDDAddEdgeClosure left = [self recursiveVisitor:[e left]];
    AltMDDAddEdgeClosure right = [self recursiveVisitor:[e right]];
    current = [^(id parent,ORInt variable,ORInt value) {
        return [(NSSet*)left(parent,variable,value) member: [[NSNumber alloc] initWithInt: (int)right(parent, variable, value)]];
    } copy];
}
-(void) visitExprValueAssignmentI:(id<ORExpr>)e
{
    current = [^(id parent,ORInt variable,ORInt value) {
        return value;
    } copy];
}
-(void) visitExprLayerVariableI:(id<ORExpr>)e
{
    current = [^(id parent,ORInt variable,ORInt value) {
        return variable;
    } copy];
}
-(void) visitExprSetContainsI:(ORExprSetContainsI*)e
{
    AltMDDAddEdgeClosure right = [self recursiveVisitor:[e value]];
    current = [(id)^(id parent,ORInt variable,ORInt value) {
        return [[e set] member: (int)right(parent, variable, value)];
    } copy];
}
-(void) visitExprParentInformationI:(id<ORExpr>)e
{
    current = [(id)^(id parent,ORInt variable,ORInt value) {
        return parent;
    } copy];
}
-(void) visitExprChildInformationI:(id<ORExpr>)e
{
    @throw [[ORExecutionError alloc] initORExecutionError: "ExprChildInformationI: visit method not defined"];
}
-(void) visitExprSingletonSetI:(ORExprSingletonSetI*)e
{
    AltMDDAddEdgeClosure inner = [self recursiveVisitor:[e value]];
    current = [(id)^(id parent, ORInt variable, ORInt value) {
        return [[NSSet alloc] initWithObjects:[[NSNumber alloc] initWithInt:(ORInt)inner(parent,variable,value)], nil];    //Only works for ints for now
    } copy];
}
-(void) visitExprIfThenElseI:(ORExprIfThenElseI*)e
{
    AltMDDAddEdgeClosure ifClosure = [self recursiveVisitor:[e ifExpr]];
    AltMDDAddEdgeClosure thenClosure = [self recursiveVisitor:[e thenReturn]];
    AltMDDAddEdgeClosure elseClosure = [self recursiveVisitor:[e elseReturn]];

    current = [(id)^(id parent, ORInt variable, ORInt value) {
        if ((bool)ifClosure(parent,variable,value)) {
            return thenClosure(parent,variable,value);
        } else {
            return elseClosure(parent,variable,value);
        }
    } copy];
}
-(void) visitExprEachInSetPlusI:(ORExprBinaryI*)e
{
    AltMDDAddEdgeClosure left = [self recursiveVisitor:[e left]];
    AltMDDAddEdgeClosure right = [self recursiveVisitor:[e right]];
    current = [(id)^(id parent,ORInt variable,ORInt value) {
        NSSet* set = (NSSet*)left(parent,variable,value);
        NSMutableSet* newSet = [[NSMutableSet alloc] init];
        int addition = (int)right(parent,variable,value);
        for (NSNumber* item in set) {
            [newSet addObject:[[NSNumber alloc] initWithInt:[item intValue]+addition]];
        }
        return newSet;
    } copy];
}
-(void) visitExprEachInSetPlusEachInSetI:(ORExprBinaryI*)e
{
    AltMDDAddEdgeClosure left = [self recursiveVisitor:[e left]];
    AltMDDAddEdgeClosure right = [self recursiveVisitor:[e right]];
    current = [(id)^(id parent,ORInt variable,ORInt value) {
        NSSet* set1 = (NSSet*)left(parent,variable,value);
        NSSet* set2 = (NSSet*)right(parent,variable,value);
        NSMutableSet* newSet = [[NSMutableSet alloc] init];
        for (NSNumber* item1 in set1) {
            int num1 = [item1 intValue];
            for (NSNumber* item2 in set2) {
                [newSet addObject:[[NSNumber alloc] initWithInt:(num1+[item2 intValue])]];
            }
        }
        return newSet;
    } copy];
}
-(void) visitExprEachInSetLEQI:(ORExprBinaryI*)e
{
    AltMDDAddEdgeClosure left = [self recursiveVisitor:[e left]];
    AltMDDAddEdgeClosure right = [self recursiveVisitor:[e right]];
    current = [^(id parent,ORInt variable,ORInt value) {
        NSSet* set = (NSSet*)left(parent,variable,value);
        int upper = (int)right(parent,variable,value);
        for (NSNumber* item in set) {
            if ([item intValue] > upper) {
                return false;
            }
        }
        return true;
    } copy];
}
-(void) visitExprEachInSetGEQI:(ORExprBinaryI*)e
{
    AltMDDAddEdgeClosure left = [self recursiveVisitor:[e left]];
    AltMDDAddEdgeClosure right = [self recursiveVisitor:[e right]];
    current = [^(id parent,ORInt variable,ORInt value) {
        NSSet* set = (NSSet*)left(parent,variable,value);
        int lower = (int)right(parent,variable,value);
        for (NSNumber* item in set) {
            if ([item intValue] < lower) {
                return false;
            }
        }
        return true;
    } copy];
}
@end
