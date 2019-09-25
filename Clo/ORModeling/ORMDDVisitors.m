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
-(void) visitExprArrayIndexI:(ORExprArrayIndexI*)e
{
    [_currentString appendString:@"ArrayIndex("];
    [[e array] visit: self];
    [_currentString appendString:@","];
    [[e index] visit: self];
    [_currentString appendString:@")"];
}
-(void) visitExprAppendToArrayI:(ORExprBinaryI*)e
{
    [_currentString appendString:@"AppendToArray("];
    [[e left] visit: self];
    [_currentString appendString:@","];
    [[e right] visit: self];
    [_currentString appendString:@")"];
}
-(void) visitExprMinBetweenArraysI:(ORExprBinaryI*)e
{
    [_currentString appendString:@"MinBetweenArrays("];
    [[e left] visit: self];
    [_currentString appendString:@","];
    [[e right] visit: self];
    [_currentString appendString:@")"];
}
-(void) visitExprMaxBetweenArraysI:(ORExprBinaryI*)e
{
    [_currentString appendString:@"MaxBetweenArrays("];
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
-(void) visitExprParentInformationI:(id<ORExpr>)e
{
    [_currentString appendString:@"ParentInformation"];
}
-(void) visitExprMinParentInformationI:(id<ORExpr>)e
{
    [_currentString appendString:@"MinParentInformation"];
}
-(void) visitExprMaxParentInformationI:(id<ORExpr>)e
{
    [_currentString appendString:@"MaxParentInformation"];
}
-(void) visitExprChildInformationI:(id<ORExpr>)e
{
    [_currentString appendString:@"ChildInformation"];
}
-(void) visitExprMinChildInformationI:(id<ORExpr>)e
{
    [_currentString appendString:@"MinChildInformation"];
}
-(void) visitExprMaxChildInformationI:(id<ORExpr>)e
{
    [_currentString appendString:@"MaxChildInformation"];
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
-(void) visitExprArrayIndexI:(ORExprArrayIndexI*)e
{
    [[e array] visit: self];
    [[e index] visit: self];
}
-(void) visitExprAppendToArrayI:(ORExprBinaryI*)e
{
    [[e left] visit: self];
    [[e right] visit: self];
}
-(void) visitExprMinBetweenArraysI:(ORExprBinaryI*)e
{
    [[e left] visit: self];
    [[e right] visit: self];
}
-(void) visitExprMaxBetweenArraysI:(ORExprBinaryI*)e
{
    [[e left] visit: self];
    [[e right] visit: self];
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
-(void) visitExprSizeOfArrayI:(ORExprSizeOfArrayI*)e { [[e array] visit: self]; }
-(void) visitExprParentInformationI:(id<ORExpr>)e { return; }
-(void) visitExprMinParentInformationI:(id<ORExpr>)e { return; }
-(void) visitExprMaxParentInformationI:(id<ORExpr>)e { return; }
-(void) visitExprChildInformationI:(id<ORExpr>)e { return; }
-(void) visitExprMinChildInformationI:(id<ORExpr>)e { return; }
-(void) visitExprMaxChildInformationI:(id<ORExpr>)e { return; }
-(void) visitExprLeftInformationI:(id<ORExpr>)e { return; }
-(void) visitExprRightInformationI:(id<ORExpr>)e { return; }
-(void) visitExprSingletonSetI:(ORExprSingletonSetI*)e
{
    [[e value] visit: self];
}
-(void) visitExprMinMaxSetFromI:(ORExprMinMaxSetFromI*)e
{
    [[e left] visit: self];
    [[e right] visit: self];
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
        return [NSNumber numberWithInt: [e value]];
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
    current = [(id)^(id* state, ORInt variable, ORInt value) {
        return [NSNumber numberWithInt: ([left(state, variable, value) intValue] + [right(state, variable, value) intValue])];  //Only works for ints
    } copy];
}
-(void) visitExprMinusI: (ORExprBinaryI*) e
{
    DDClosure left = [self recursiveVisitor:[e left]];
    DDClosure right = [self recursiveVisitor:[e right]];
    current = [(id)^(id* state, ORInt variable, ORInt value) {
        return [NSNumber numberWithInt: [left(state, variable, value) intValue] - [right(state, variable, value) intValue]];  //Only works for ints
    } copy];
}
-(void) visitExprMulI: (ORExprBinaryI*) e
{
    DDClosure left = [self recursiveVisitor:[e left]];
    DDClosure right = [self recursiveVisitor:[e right]];
    current = [(id)^(id* state, ORInt variable, ORInt value) {
        return [NSNumber numberWithInt: ([left(state, variable, value) intValue] * [right(state, variable, value) intValue])];  //Only works for ints
    } copy];
}
-(void) visitExprDivI: (ORExprBinaryI*) e
{
    DDClosure left = [self recursiveVisitor:[e left]];
    DDClosure right = [self recursiveVisitor:[e right]];
    current = [(id)^(id* state, ORInt variable, ORInt value) {
        return [NSNumber numberWithInt: ([left(state, variable, value) intValue] / [right(state, variable, value) intValue])];  //Only works for ints
    } copy];
}
-(void) visitExprModI: (ORExprBinaryI*) e
{
    DDClosure left = [self recursiveVisitor:[e left]];
    DDClosure right = [self recursiveVisitor:[e right]];
    current = [(id)^(id* state, ORInt variable, ORInt value) {
        return [NSNumber numberWithInt: ([left(state, variable, value) intValue] % [right(state, variable, value) intValue])];  //Only works for ints
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
    current = [(id)^(id* state, ORInt variable, ORInt value) {
        return [NSNumber numberWithBool: ([left(state, variable, value) intValue] == [right(state, variable, value) intValue])];  //Only works for ints
    } copy];
}
-(void) visitExprNEqualI: (ORExprBinaryI*) e
{
    DDClosure left = [self recursiveVisitor:[e left]];
    DDClosure right = [self recursiveVisitor:[e right]];
    current = [(id)^(id* state, ORInt variable, ORInt value) {
        return [NSNumber numberWithBool: ([left(state, variable, value) intValue] != [right(state, variable, value) intValue])];  //Only works for ints
    } copy];
}
-(void) visitExprLEqualI: (ORExprBinaryI*) e
{
    DDClosure left = [self recursiveVisitor:[e left]];
    DDClosure right = [self recursiveVisitor:[e right]];
    current = [(id)^(id* state, ORInt variable, ORInt value) {
        return [NSNumber numberWithBool: ([left(state, variable, value) intValue] <= [right(state, variable, value) intValue])];  //Only works for ints
    } copy];
}
-(void) visitExprGEqualI: (ORExprBinaryI*) e
{
    DDClosure left = [self recursiveVisitor:[e left]];
    DDClosure right = [self recursiveVisitor:[e right]];
    current = [(id)^(id* state, ORInt variable, ORInt value) {
        return [NSNumber numberWithBool: ([left(state, variable, value) intValue] >= [right(state, variable, value) intValue])];  //Only works for ints
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
    current = [(id)^(id* state, ORInt variable, ORInt value) {
        return [NSNumber numberWithBool: ([left(state, variable, value) boolValue] || [right(state, variable, value) boolValue])];
    } copy];
}
-(void) visitExprConjunctI: (ORExprBinaryI*) e
{
    DDClosure left = [self recursiveVisitor:[e left]];
    DDClosure right = [self recursiveVisitor:[e right]];
    current = [(id)^(id* state, ORInt variable, ORInt value) {
        return [NSNumber numberWithBool: ([left(state, variable, value) boolValue] && [right(state, variable, value) boolValue])];
    } copy];
}
-(void) visitExprImplyI: (ORExprBinaryI*) e
{
    DDClosure left = [self recursiveVisitor:[e left]];
    DDClosure right = [self recursiveVisitor:[e right]];
    current = [(id)^(id* state, ORInt variable, ORInt value) {
        return [NSNumber numberWithBool: ((![left(state, variable, value) boolValue]) || [right(state, variable, value) boolValue])];
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
    current = [^(id* state, ORInt variable, ORInt value) {
        if ([e isArray]) {
            return state[[e lookup]][[e arrayIndex]];
        }
        return state[[e lookup]];
    } copy];
}
-(void) visitExprValueAssignmentI:(id<ORExpr>)e
{
    current = [^(id* state, ORInt variable, ORInt value) {
        return [NSNumber numberWithInt: value];
    } copy];
}
-(void) visitExprLayerVariableI:(id<ORExpr>)e
{
    current = [^(id* state, ORInt variable, ORInt value) {
        return variable;
    } copy];
}
-(void) visitExprSizeOfArrayI:(ORExprSizeOfArrayI*)e
{
    DDClosure array = [self recursiveVisitor:[e array]];
    current = [^(id* state, ORInt variable, ORInt value) {
        return [array(state, variable, value) count];
    } copy];
}
-(void) visitExprSetContainsI:(ORExprSetContainsI*)e
{
    DDClosure right = [self recursiveVisitor:[e value]];
    current = [^(id* state, ORInt variable, ORInt value) {
        return [NSNumber numberWithBool:[[e set] member: [right(state, variable, value) intValue]]];
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
        return [NSNumber numberWithInt: [e value]];
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
    current = [(id)^(id* state1, id* state2) {
        return [NSNumber numberWithInt: ([left(state1, state2) intValue] + [right(state1, state2) intValue])];  //Only works for ints
    } copy];
}
-(void) visitExprMinusI: (ORExprBinaryI*) e
{
    DDMergeClosure left = [self recursiveVisitor:[e left]];
    DDMergeClosure right = [self recursiveVisitor:[e right]];
    current = [(id)^(id* state1, id* state2) {
        return [NSNumber numberWithInt: ([left(state1, state2) intValue] - [right(state1, state2) intValue])];  //Only works for ints
    } copy];
}
-(void) visitExprMulI: (ORExprBinaryI*) e
{
    DDMergeClosure left = [self recursiveVisitor:[e left]];
    DDMergeClosure right = [self recursiveVisitor:[e right]];
    current = [(id)^(id* state1, id* state2) {
        return [NSNumber numberWithInt: ([left(state1, state2) intValue] * [right(state1, state2) intValue])];  //Only works for ints
    } copy];
}
-(void) visitExprDivI: (ORExprBinaryI*) e
{
    DDMergeClosure left = [self recursiveVisitor:[e left]];
    DDMergeClosure right = [self recursiveVisitor:[e right]];
    current = [(id)^(id* state1, id* state2) {
        return [NSNumber numberWithInt: ([left(state1, state2) intValue] / [right(state1, state2) intValue])];  //Only works for ints
    } copy];
}
-(void) visitExprModI: (ORExprBinaryI*) e
{
    DDMergeClosure left = [self recursiveVisitor:[e left]];
    DDMergeClosure right = [self recursiveVisitor:[e right]];
    current = [(id)^(id* state1, id* state2) {
        return [NSNumber numberWithInt: ([left(state1, state2) intValue] % [right(state1, state2) intValue])];  //Only works for ints
    } copy];
}
-(void) visitExprMinI: (ORExprMinI*) e
{
    DDMergeClosure left = [self recursiveVisitor:[e left]];
    DDMergeClosure right = [self recursiveVisitor:[e right]];
    current = [(id)^(id* state1, id* state2) {
        return [NSNumber numberWithInt: min([left(state1, state2) intValue], [right(state1, state2) intValue])];  //Only works for ints
    } copy];
}
-(void) visitExprMaxI: (ORExprMaxI*) e
{
    DDMergeClosure left = [self recursiveVisitor:[e left]];
    DDMergeClosure right = [self recursiveVisitor:[e right]];
    current = [(id)^(id* state1, id* state2) {
        return [NSNumber numberWithInt: max([left(state1, state2) intValue], [right(state1, state2) intValue])];  //Only works for ints
    } copy];
}
-(void) visitExprEqualI: (ORExprBinaryI*) e
{
    DDMergeClosure left = [self recursiveVisitor:[e left]];
    DDMergeClosure right = [self recursiveVisitor:[e right]];
    current = [(id)^(id* state1, id* state2) {
        return [NSNumber numberWithBool: ([left(state1, state2) intValue] == [right(state1, state2) intValue])];  //Only works for ints
    } copy];
}
-(void) visitExprNEqualI: (ORExprBinaryI*) e
{
    DDMergeClosure left = [self recursiveVisitor:[e left]];
    DDMergeClosure right = [self recursiveVisitor:[e right]];
    current = [(id)^(id* state1, id* state2) {
        return [NSNumber numberWithBool: ([left(state1, state2) intValue] != [right(state1, state2) intValue])];  //Only works for ints
    } copy];
}
-(void) visitExprLEqualI: (ORExprBinaryI*) e
{
    DDMergeClosure left = [self recursiveVisitor:[e left]];
    DDMergeClosure right = [self recursiveVisitor:[e right]];
    current = [(id)^(id* state1, id* state2) {
        return [NSNumber numberWithBool: ([left(state1, state2) intValue] <= [right(state1, state2) intValue])];  //Only works for ints
    } copy];
}
-(void) visitExprGEqualI: (ORExprBinaryI*) e
{
    DDMergeClosure left = [self recursiveVisitor:[e left]];
    DDMergeClosure right = [self recursiveVisitor:[e right]];
    current = [(id)^(id* state1, id* state2) {
        return [NSNumber numberWithBool: ([left(state1, state2) intValue] >= [right(state1, state2) intValue])];  //Only works for ints
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
    current = [(id)^(id* state1, id* state2) {
        return [NSNumber numberWithInt: abs([inner(state1, state2) intValue])];
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
    current = [(id)^(id* state1, id* state2) {
        return [NSNumber numberWithBool: ([left(state1, state2) boolValue] || [right(state1, state2) boolValue])];
    } copy];
}
-(void) visitExprConjunctI: (ORExprBinaryI*) e
{
    DDMergeClosure left = [self recursiveVisitor:[e left]];
    DDMergeClosure right = [self recursiveVisitor:[e right]];
    current = [(id)^(id* state1, id* state2) {
        return [NSNumber numberWithBool: ([left(state1, state2) boolValue] && [right(state1, state2) boolValue])];
    } copy];
}
-(void) visitExprImplyI: (ORExprBinaryI*) e
{
    DDMergeClosure left = [self recursiveVisitor:[e left]];
    DDMergeClosure right = [self recursiveVisitor:[e right]];
    current = [(id)^(id* state1, id* state2) {
        return [NSNumber numberWithBool: (!([left(state1, state2) boolValue]) || [right(state1, state2) boolValue])];
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
    current = [^(id* state1, id* state2) {
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
-(void) visitExprSizeOfArrayI:(ORExprSizeOfArrayI*)e
{
    DDMergeClosure array = [self recursiveVisitor:[e array]];
    current = [^(id* state1, id* state2) {
        return [array(state1, state2) count];
    } copy];
}
-(void) visitExprSetContainsI:(ORExprSetContainsI*)e
{
    DDMergeClosure right = [self recursiveVisitor:[e value]];
    current = [^(id* state1, id* state2) {
        return [NSNumber numberWithBool:[[e set] member: [right(state1, state2) intValue]]];
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
        return [NSNumber numberWithInt:[e value]];
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
        return [NSNumber numberWithInt:[left(parent, child, variable, value) intValue] + [right(parent, child, variable, value) intValue]];  //Only works for ints
    } copy];
}
-(void) visitExprMinusI: (ORExprBinaryI*) e
{
    AltMDDDeleteEdgeCheckClosure left = [self recursiveVisitor:[e left]];
    AltMDDDeleteEdgeCheckClosure right = [self recursiveVisitor:[e right]];
    current = [^(id parent,id child,ORInt variable,ORInt value) {
        return [NSNumber numberWithInt:[left(parent, child, variable, value) intValue] - [right(parent, child, variable, value) intValue]];  //Only works for ints
    } copy];
}
-(void) visitExprMulI: (ORExprBinaryI*) e
{
    AltMDDDeleteEdgeCheckClosure left = [self recursiveVisitor:[e left]];
    AltMDDDeleteEdgeCheckClosure right = [self recursiveVisitor:[e right]];
    current = [^(id parent,id child,ORInt variable,ORInt value) {
        return [NSNumber numberWithInt:[left(parent, child, variable, value) intValue] * [right(parent, child, variable, value) intValue]];  //Only works for ints
    } copy];
}
-(void) visitExprDivI: (ORExprBinaryI*) e
{
    AltMDDDeleteEdgeCheckClosure left = [self recursiveVisitor:[e left]];
    AltMDDDeleteEdgeCheckClosure right = [self recursiveVisitor:[e right]];
    current = [^(id parent,id child,ORInt variable,ORInt value) {
        return [NSNumber numberWithInt:[left(parent, child, variable, value) intValue] / [right(parent, child, variable, value) intValue]];  //Only works for ints
    } copy];
}
-(void) visitExprModI: (ORExprBinaryI*) e
{
    AltMDDDeleteEdgeCheckClosure left = [self recursiveVisitor:[e left]];
    AltMDDDeleteEdgeCheckClosure right = [self recursiveVisitor:[e right]];
    current = [^(id parent,id child,ORInt variable,ORInt value) {
        return [NSNumber numberWithInt:[left(parent, child, variable, value) intValue] % [right(parent, child, variable, value) intValue]];  //Only works for ints
    } copy];
}
-(void) visitExprMinI: (ORExprMinI*) e
{
    AltMDDDeleteEdgeCheckClosure left = [self recursiveVisitor:[e left]];
    AltMDDDeleteEdgeCheckClosure right = [self recursiveVisitor:[e right]];
    current = [^(id parent,id child,ORInt variable,ORInt value) {
        return [NSNumber numberWithInt:min([left(parent, child, variable, value) intValue], [right(parent, child, variable, value) intValue])];  //Only works for ints
    } copy];
}
-(void) visitExprMaxI: (ORExprMaxI*) e
{
    AltMDDDeleteEdgeCheckClosure left = [self recursiveVisitor:[e left]];
    AltMDDDeleteEdgeCheckClosure right = [self recursiveVisitor:[e right]];
    current = [^(id parent,id child,ORInt variable,ORInt value) {
        return [NSNumber numberWithInt:max([left(parent, child, variable, value) intValue], [right(parent, child, variable, value) intValue])];  //Only works for ints
    } copy];
}
-(void) visitExprEqualI: (ORExprBinaryI*) e
{
    AltMDDDeleteEdgeCheckClosure left = [self recursiveVisitor:[e left]];
    AltMDDDeleteEdgeCheckClosure right = [self recursiveVisitor:[e right]];
    current = [^(id parent,id child,ORInt variable,ORInt value) {
        return [NSNumber numberWithBool:[left(parent, child, variable, value) boolValue] == [right(parent, child, variable, value) boolValue]];
    } copy];
}
-(void) visitExprNEqualI: (ORExprBinaryI*) e
{
    AltMDDDeleteEdgeCheckClosure left = [self recursiveVisitor:[e left]];
    AltMDDDeleteEdgeCheckClosure right = [self recursiveVisitor:[e right]];
    current = [^(id parent,id child,ORInt variable,ORInt value) {
        return [NSNumber numberWithBool:[left(parent, child, variable, value) boolValue] != [right(parent, child, variable, value) boolValue]];
    } copy];
}
-(void) visitExprLEqualI: (ORExprBinaryI*) e
{
    AltMDDDeleteEdgeCheckClosure left = [self recursiveVisitor:[e left]];
    AltMDDDeleteEdgeCheckClosure right = [self recursiveVisitor:[e right]];
    current = [^(id parent,id child,ORInt variable,ORInt value) {
        return [NSNumber numberWithBool:[left(parent, child, variable, value) intValue] <= [right(parent, child, variable, value) intValue]];  //Only works for ints
    } copy];
}
-(void) visitExprGEqualI: (ORExprBinaryI*) e
{
    AltMDDDeleteEdgeCheckClosure left = [self recursiveVisitor:[e left]];
    AltMDDDeleteEdgeCheckClosure right = [self recursiveVisitor:[e right]];
    current = [^(id parent,id child,ORInt variable,ORInt value) {
        return [NSNumber numberWithBool:[left(parent, child, variable, value) intValue] >= [right(parent, child, variable, value) intValue]];  //Only works for ints
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
        return [NSNumber numberWithInt:abs([inner(parent, child, variable, value) intValue])];
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
        return [NSNumber numberWithBool:!([inner(parent, child, variable, value) boolValue])];
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
        return [NSNumber numberWithBool:[left(parent, child, variable, value) boolValue] || [right(parent, child, variable, value) boolValue]];
    } copy];
}
-(void) visitExprConjunctI: (ORExprBinaryI*) e
{
    AltMDDDeleteEdgeCheckClosure left = [self recursiveVisitor:[e left]];
    AltMDDDeleteEdgeCheckClosure right = [self recursiveVisitor:[e right]];
    current = [^(id parent,id child,ORInt variable,ORInt value) {
        return [NSNumber numberWithBool:[left(parent, child, variable, value) boolValue] && [right(parent, child, variable, value) boolValue]];
    } copy];
}
-(void) visitExprImplyI: (ORExprBinaryI*) e
{
    AltMDDDeleteEdgeCheckClosure left = [self recursiveVisitor:[e left]];
    AltMDDDeleteEdgeCheckClosure right = [self recursiveVisitor:[e right]];
    current = [^(id parent,id child,ORInt variable,ORInt value) {
        return [NSNumber numberWithBool:![left(parent, child, variable, value) boolValue] || [right(parent, child, variable, value) boolValue]];
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
        return [NSNumber numberWithInt:value];
    } copy];
}
-(void) visitExprLayerVariableI:(id<ORExpr>)e
{
    current = [^(id parent,id child,ORInt variable,ORInt value) {
        return [NSNumber numberWithInt:variable];
    } copy];
}
-(void) visitExprArrayIndexI:(ORExprArrayIndexI*)e
{
    AltMDDDeleteEdgeCheckClosure array = [self recursiveVisitor:[e array]];
    AltMDDDeleteEdgeCheckClosure index = [self recursiveVisitor:[e index]];
    current = [^(id parent, id child, ORInt variable, ORInt value) {
        return [array(parent, child, variable, value) objectAtIndex:[index(parent,child,variable,value) intValue]];
    } copy];
}
-(void) visitExprSizeOfArrayI:(ORExprSizeOfArrayI*)e
{
    AltMDDDeleteEdgeCheckClosure array = [self recursiveVisitor:[e array]];
    current = [^(id parent, id child, ORInt variable, ORInt value) {
        return [NSNumber numberWithInt:(int)[array(parent, child, variable, value) count]];
    } copy];
}
-(void) visitExprSetContainsI:(ORExprSetContainsI*)e
{
    AltMDDDeleteEdgeCheckClosure right = [self recursiveVisitor:[e value]];
    current = [^(id parent,id child,ORInt variable,ORInt value) {
        return [NSNumber numberWithBool:[[e set] member: [right(parent, child, variable, value) intValue]]];
    } copy];
}
-(void) visitExprSetExprContainsI:(ORExprBinaryI*)e
{
    AltMDDDeleteEdgeCheckClosure left = [self recursiveVisitor:[e left]];
    AltMDDDeleteEdgeCheckClosure right = [self recursiveVisitor:[e right]];
    current = [^(id parent,id child,ORInt variable,ORInt value) {
        return [NSNumber numberWithBool:[(ORIntSetI*)left(parent,child,variable,value) member:[right(parent, child, variable, value) intValue]]];
    } copy];
}
//I think the problem is everything is expected to return ints.  Try chaning everything to id and using NSBool or something when needed?
-(void) visitExprParentInformationI:(id<ORExpr>)e
{
    current = [(id)^(id parent,id child,ORInt variable,ORInt value) {
        return parent;
    } copy];
}
-(void) visitExprMinParentInformationI:(id<ORExpr>)e
{
    current = [(id)^(id parent,id child,ORInt variable,ORInt value) {
        return [parent objectAtIndex:0];
    } copy];
}
-(void) visitExprMaxParentInformationI:(id<ORExpr>)e
{
    current = [(id)^(id parent,id child,ORInt variable,ORInt value) {
        return [parent objectAtIndex:1];
    } copy];
}
-(void) visitExprChildInformationI:(id<ORExpr>)e
{
    current = [(id)^(id parent,id child,ORInt variable,ORInt value) {
        return child;
    } copy];
}
-(void) visitExprMinChildInformationI:(id<ORExpr>)e
{
    current = [(id)^(id parent,id child,ORInt variable,ORInt value) {
        return [child objectAtIndex:0];
    } copy];
}
-(void) visitExprMaxChildInformationI:(id<ORExpr>)e
{
    current = [(id)^(id parent,id child,ORInt variable,ORInt value) {
        return [child objectAtIndex:1];
    } copy];
}
-(void) visitExprAppendToArrayI:(ORExprBinaryI*)e
{
    AltMDDDeleteEdgeCheckClosure left = [self recursiveVisitor:[e left]];
    AltMDDDeleteEdgeCheckClosure right = [self recursiveVisitor:[e right]];
    current = [(id)^(id parent,id child,ORInt variable,ORInt value) {
        NSArray* leftArray = (NSArray*)left(parent,child,variable,value);
        NSMutableArray* newArray = [[NSMutableArray alloc] initWithArray:leftArray];
        id objectToAppend = right(parent,child,variable,value);
        [newArray addObject:objectToAppend];
        return newArray;
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
                return [NSNumber numberWithBool:false];
            }
        }
        return [NSNumber numberWithBool:true];
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
                return [NSNumber numberWithBool:false];
            }
        }
        return [NSNumber numberWithBool:true];
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
-(void) visitExprMinBetweenArraysI:(ORExprBinaryI*)e
{
    AltMDDMergeInfoClosure left = [self recursiveVisitor:[e left]];
    AltMDDMergeInfoClosure right = [self recursiveVisitor:[e right]];
    current = [^(id leftParent,id rightParent,ORInt variable) {
        NSArray* leftArray = left(leftParent, rightParent, variable);
        NSArray* rightArray = right(leftParent, rightParent, variable);
        int leftArrayCount = (int)[leftArray count];
        int rightArrayCount = (int)[rightArray count];
        NSMutableArray* minArray = [[NSMutableArray alloc] initWithArray:leftArray];
        for (int index = 0; index < leftArrayCount; index++) {
            id rightObject = [rightArray objectAtIndex:index];
            if ([[minArray objectAtIndex:index] intValue] > [rightObject intValue]) {
                [minArray setObject:rightObject atIndexedSubscript:index];
            }
        }
        if (rightArrayCount > leftArrayCount) {
            for (int index = leftArrayCount; index < rightArrayCount; index++) {
                [minArray addObject:[rightArray objectAtIndex:index]];
            }
        }
        return minArray;
    } copy];
}
-(void) visitExprMaxBetweenArraysI:(ORExprBinaryI*)e
{
    AltMDDMergeInfoClosure left = [self recursiveVisitor:[e left]];
    AltMDDMergeInfoClosure right = [self recursiveVisitor:[e right]];
    current = [^(id leftParent,id rightParent,ORInt variable) {
        NSArray* leftArray = left(leftParent, rightParent, variable);
        NSArray* rightArray = right(leftParent, rightParent, variable);
        int leftArrayCount = (int)[leftArray count];
        int rightArrayCount = (int)[rightArray count];
        NSMutableArray* maxArray = [[NSMutableArray alloc] initWithArray:leftArray];
        for (int index = 0; index < leftArrayCount; index++) {
            id rightObject = [rightArray objectAtIndex:index];
            if ([[maxArray objectAtIndex:index] intValue] < [rightObject intValue]) {
                [maxArray setObject:rightObject atIndexedSubscript:index];
            }
        }
        if (rightArrayCount > leftArrayCount) {
            for (int index = leftArrayCount; index < rightArrayCount; index++) {
                [maxArray addObject:[rightArray objectAtIndex:index]];
            }
        }
        return maxArray;
    } copy];
}
-(void) visitExprSetExprContainsI:(ORExprBinaryI*)e
{
    AltMDDMergeInfoClosure left = [self recursiveVisitor:[e left]];
    AltMDDMergeInfoClosure right = [self recursiveVisitor:[e right]];
    current = [^(id leftParent,id rightParent,ORInt variable) {
        return [NSNumber numberWithBool:[(ORIntSetI*)left(leftParent, rightParent, variable) member:[right(leftParent, rightParent, variable) intValue]]];
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
-(void) visitExprArrayIndexI:(ORExprArrayIndexI*)e
{
    AltMDDMergeInfoClosure array = [self recursiveVisitor:[e array]];
    AltMDDMergeInfoClosure index = [self recursiveVisitor:[e index]];
    current = [^(id leftParent, id rightParent, ORInt variable) {
        return [array(leftParent, rightParent, variable) objectAtIndex:[index(leftParent,rightParent,variable) intValue]];
    } copy];
}
-(void) visitExprSizeOfArrayI:(ORExprSizeOfArrayI*)e
{
    AltMDDMergeInfoClosure array = [self recursiveVisitor:[e array]];
    current = [^(id leftParent, id rightParent, ORInt variable) {
        return [array(leftParent, rightParent, variable) count];
    } copy];
}
-(void) visitExprSetContainsI:(ORExprSetContainsI*)e
{
    AltMDDMergeInfoClosure right = [self recursiveVisitor:[e value]];
    current = [(id)^(id leftParent,id rightParent,ORInt variable) {
        return [NSNumber numberWithBool:[[e set] member: [right(leftParent, rightParent, variable) intValue]]];
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
-(void) visitExprMinMaxSetFromI:(ORExprMinMaxSetFromI*)e
{
    AltMDDMergeInfoClosure left = [self recursiveVisitor:[e left]];
    AltMDDMergeInfoClosure right = [self recursiveVisitor:[e right]];
    current = [^(id leftParent,id rightParent,ORInt variable) {
        NSSet* leftSet = (NSSet*)left(leftParent, rightParent, variable);
        NSSet* rightSet = (NSSet*)right(leftParent, rightParent, variable);
        int min = MAXINT;
        int max = MININT;
        for (NSNumber* num in leftSet) {
            int value = [num intValue];
            if (min > value) {
                min = value;
            }
            if (max < value) {
                max = value;
            }
        }
        for (NSNumber* num in rightSet) {
            int value = [num intValue];
            if (min > value) {
                min = value;
            }
            if (max < value) {
                max = value;
            }
        }
        return [[NSSet alloc] initWithObjects:[[NSNumber alloc] initWithInt:min],[[NSNumber alloc] initWithInt:max], nil];    //Only works for ints for now
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
        return [NSNumber numberWithInt:[left(parent, variable, value) intValue] + [right(parent, variable, value) intValue]];  //Only works for ints
    } copy];
}
-(void) visitExprMinusI: (ORExprBinaryI*) e
{
    AltMDDAddEdgeClosure left = [self recursiveVisitor:[e left]];
    AltMDDAddEdgeClosure right = [self recursiveVisitor:[e right]];
    current = [(id)^(id parent,ORInt variable,ORInt value) {
        return [NSNumber numberWithInt:[left(parent, variable, value) intValue] - [right(parent, variable, value) intValue]];  //Only works for ints
    } copy];
}
-(void) visitExprMulI: (ORExprBinaryI*) e
{
    AltMDDAddEdgeClosure left = [self recursiveVisitor:[e left]];
    AltMDDAddEdgeClosure right = [self recursiveVisitor:[e right]];
    current = [(id)^(id parent,ORInt variable,ORInt value) {
        return [NSNumber numberWithInt:[left(parent, variable, value) intValue] * [right(parent, variable, value) intValue]];  //Only works for ints
    } copy];
}
-(void) visitExprDivI: (ORExprBinaryI*) e
{
    AltMDDAddEdgeClosure left = [self recursiveVisitor:[e left]];
    AltMDDAddEdgeClosure right = [self recursiveVisitor:[e right]];
    current = [(id)^(id parent,ORInt variable,ORInt value) {
        return [NSNumber numberWithInt:[left(parent, variable, value) intValue] / [right(parent, variable, value) intValue]];  //Only works for ints
    } copy];
}
-(void) visitExprModI: (ORExprBinaryI*) e
{
    AltMDDAddEdgeClosure left = [self recursiveVisitor:[e left]];
    AltMDDAddEdgeClosure right = [self recursiveVisitor:[e right]];
    current = [(id)^(id parent,ORInt variable,ORInt value) {
        return [NSNumber numberWithInt:[left(parent, variable, value) intValue] % [right(parent, variable, value) intValue]];  //Only works for ints
    } copy];
}
-(void) visitExprMinI: (ORExprMinI*) e
{
    AltMDDAddEdgeClosure left = [self recursiveVisitor:[e left]];
    AltMDDAddEdgeClosure right = [self recursiveVisitor:[e right]];
    current = [(id)^(id parent,ORInt variable,ORInt value) {
        return [NSNumber numberWithInt:min([left(parent, variable, value) intValue], [right(parent, variable, value) intValue])];  //Only works for ints
    } copy];
}
-(void) visitExprMaxI: (ORExprMaxI*) e
{
    AltMDDAddEdgeClosure left = [self recursiveVisitor:[e left]];
    AltMDDAddEdgeClosure right = [self recursiveVisitor:[e right]];
    current = [(id)^(id parent,ORInt variable,ORInt value) {
        return [NSNumber numberWithInt:max([left(parent, variable, value) intValue], [right(parent, variable, value) intValue])];  //Only works for ints
    } copy];
}
-(void) visitExprEqualI: (ORExprBinaryI*) e
{
    AltMDDAddEdgeClosure left = [self recursiveVisitor:[e left]];
    AltMDDAddEdgeClosure right = [self recursiveVisitor:[e right]];
    current = [(id)^(id parent,ORInt variable,ORInt value) {
        return [NSNumber numberWithInt:[left(parent, variable, value) intValue] == [right(parent, variable, value) intValue]];  //Only works for ints
    } copy];
}
-(void) visitExprNEqualI: (ORExprBinaryI*) e
{
    AltMDDAddEdgeClosure left = [self recursiveVisitor:[e left]];
    AltMDDAddEdgeClosure right = [self recursiveVisitor:[e right]];
    current = [(id)^(id parent,ORInt variable,ORInt value) {
        return [NSNumber numberWithInt:[left(parent, variable, value) intValue] != [right(parent, variable, value) intValue]];  //Only works for ints
    } copy];
}
-(void) visitExprLEqualI: (ORExprBinaryI*) e
{
    AltMDDAddEdgeClosure left = [self recursiveVisitor:[e left]];
    AltMDDAddEdgeClosure right = [self recursiveVisitor:[e right]];
    current = [(id)^(id parent,ORInt variable,ORInt value) {
        return [NSNumber numberWithInt:[left(parent, variable, value) intValue] <= [right(parent, variable, value) intValue]];  //Only works for ints
    } copy];
}
-(void) visitExprGEqualI: (ORExprBinaryI*) e
{
    AltMDDAddEdgeClosure left = [self recursiveVisitor:[e left]];
    AltMDDAddEdgeClosure right = [self recursiveVisitor:[e right]];
    current = [(id)^(id parent,ORInt variable,ORInt value) {
        return [NSNumber numberWithInt:[left(parent, variable, value) intValue] >= [right(parent, variable, value) intValue]];  //Only works for ints
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
        return [NSNumber numberWithInt:abs([inner(parent, variable, value) intValue])];
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
        return [NSNumber numberWithBool:[left(parent, variable, value) boolValue] || [right(parent, variable, value) boolValue]];
    } copy];
}
-(void) visitExprConjunctI: (ORExprBinaryI*) e
{
    AltMDDAddEdgeClosure left = [self recursiveVisitor:[e left]];
    AltMDDAddEdgeClosure right = [self recursiveVisitor:[e right]];
    current = [(id)^(id parent,ORInt variable,ORInt value) {
        return [NSNumber numberWithBool:[left(parent, variable, value) boolValue] && [right(parent, variable, value) boolValue]];
    } copy];
}
-(void) visitExprImplyI: (ORExprBinaryI*) e
{
    AltMDDAddEdgeClosure left = [self recursiveVisitor:[e left]];
    AltMDDAddEdgeClosure right = [self recursiveVisitor:[e right]];
    current = [(id)^(id parent,ORInt variable,ORInt value) {
        return [NSNumber numberWithBool:![left(parent, variable, value) boolValue] || [right(parent, variable, value) boolValue]];
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
        return [NSNumber numberWithBool:[(ORIntSetI*)left(parent,variable,value) member:[right(parent, variable, value) intValue]]];
    } copy];
}
-(void) visitExprValueAssignmentI:(id<ORExpr>)e
{
    current = [^(id parent,ORInt variable,ORInt value) {
        return [NSNumber numberWithInt: value];
    } copy];
}
-(void) visitExprLayerVariableI:(id<ORExpr>)e
{
    current = [^(id parent,ORInt variable,ORInt value) {
        return [NSNumber numberWithInt: variable];
    } copy];
}
-(void) visitExprArrayIndexI:(ORExprArrayIndexI*)e
{
    AltMDDAddEdgeClosure array = [self recursiveVisitor:[e array]];
    AltMDDAddEdgeClosure index = [self recursiveVisitor:[e index]];
    current = [^(id parent, ORInt variable, ORInt value) {
        return [array(parent, variable, value) objectAtIndex:[index(parent,variable,value) intValue]];
    } copy];
}
-(void) visitExprSizeOfArrayI:(ORExprSizeOfArrayI*)e
{
    AltMDDAddEdgeClosure array = [self recursiveVisitor:[e array]];
    current = [^(id parent, ORInt variable, ORInt value) {
        return [NSNumber numberWithInt:(int)[array(parent, variable, value) count]];
    } copy];
}
-(void) visitExprSetContainsI:(ORExprSetContainsI*)e
{
    AltMDDAddEdgeClosure right = [self recursiveVisitor:[e value]];
    current = [(id)^(id parent,ORInt variable,ORInt value) {
        return [NSNumber numberWithBool:[[e set] member: (int)[right(parent, variable, value) intValue]]];
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
-(void) visitExprAppendToArrayI:(ORExprBinaryI*)e
{
    AltMDDAddEdgeClosure left = [self recursiveVisitor:[e left]];
    AltMDDAddEdgeClosure right = [self recursiveVisitor:[e right]];
    current = [(id)^(id parent,ORInt variable,ORInt value) {
        NSArray* leftArray = (NSArray*)left(parent,variable,value);
        NSMutableArray* newArray = [[NSMutableArray alloc] initWithArray:leftArray];
        id objectToAppend = right(parent,variable,value);
        [newArray addObject:objectToAppend];
        return newArray;
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
                return [NSNumber numberWithBool:false];
            }
        }
        return [NSNumber numberWithBool:true];
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
                return [NSNumber numberWithBool:false];
            }
        }
        return [NSNumber numberWithBool:true];
    } copy];
}
@end
