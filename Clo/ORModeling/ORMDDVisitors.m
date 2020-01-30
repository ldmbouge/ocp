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
    if (first != NULL) {
        [first visit:self];
    }
    _firstString = [_currentString copy];
    _firstGetStates = [_currentGetStates copy];
    
    _currentString = [[NSMutableString alloc] init];
    _currentGetStates = [[NSMutableArray alloc] init];
    if (second != NULL) {
        [second visit:self];
    }
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

-(void) visitExprStateValueExprI:(ORExprStateValueExprI*)e
{
    [_currentString appendString:[NSString stringWithFormat:@"StateValueExpr%d(",[e index]]];
    [[e lookup] visit: self];
    [_currentString appendString:@")"];
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
-(void) visitExprIntArrayIndexI:(ORExprIntArrayIndexI*)e
{
    [_currentString appendString:@"IntArrayIndex("];
    [_currentString appendString:[[e array] description]];
    [_currentString appendString:@","];
    [[e index] visit: self];
    [_currentString appendString:@")"];
}
-(void) visitExprDictionaryValueI:(ORExprDictionaryValueI*)e
{
    [_currentString appendString:@"DictionaryValue("];
    [_currentString appendString:[[e dict] description]];
    [_currentString appendString:@","];
    [[e key] visit: self];
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
-(void) visitExprVariableIndexI:(ORExprVariableIndexI*)e
{
    [_currentString appendFormat:@"VariableIndex(%d)",[e index]];
}
-(void) visitExprLayerVariableI:(ORExprLayerVariableI*)e
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

@implementation ORDDUpdatedSpecs
-(ORDDUpdatedSpecs*) initORDDUpdatedSpecs:(int*)stateMapping {
    self = [super init];
    _stateMapping = stateMapping;
    return self;
}
-(ORDDUpdatedSpecs*) initORDDUpdatedSpecs:(int*)stateMapping stateSize:(int)stateSize variableMapping:(int*)variableMapping {
    self = [super init];
    _stateMapping = stateMapping;
    _stateSize = stateSize;
    _variableMapping = variableMapping;
    return self;
}
-(id<ORExpr>) updatedSpecs:(id<ORExpr>)e
{
    if (e != NULL) {
        [e visit: self];
        return current;
    }
    return NULL;
}
-(id<ORExpr>) recursiveVisitor:(id<ORExpr>)e
{
    id<ORExpr> old = current;
    current = nil;
    [e visit: self];
    id<ORExpr> returnedValue = current;
    current = old;
    return returnedValue;
}

-(void) visitExprStateValueI:(ORExprStateValueI*)e
{
    int index = [e index];
    int arrayIndex = [e arrayIndex];
    int lookup = [e lookup];
    if (_stateMapping != NULL) {
        lookup = _stateMapping[lookup];
    }
    current = [[ORExprStateValueI alloc] initORExprStateValueI:[e tracker] lookup:lookup index:index arrayIndex:arrayIndex];
}
-(void) visitExprStateValueExprI:(ORExprStateValueExprI*)e
{
    id<ORExpr> lookup = [self recursiveVisitor:[e lookup]];
    if (_stateMapping == NULL) {
        current = [[ORExprStateValueExprI alloc] initORExprStateValueExprI:[e tracker] lookup:lookup index:[e index] arrayIndex:[e arrayIndex] mapping:[e mapping]];
    } else if ([e mapping] == NULL) {
        current = [[ORExprStateValueExprI alloc] initORExprStateValueExprI:[e tracker] lookup:lookup index:[e index] arrayIndex:[e arrayIndex] mapping:_stateMapping];
    } else {
        //If there was already a mapping for the states and there's a new one, need to combine the two mappings
        int* sumOfMappings = calloc(_stateSize, sizeof(int));
        int* oldMapping = [e mapping];
        for (int i = 0; i < _stateSize; i++) {
            sumOfMappings[i] = _stateMapping[oldMapping[i]];
        }
        current = [[ORExprStateValueExprI alloc] initORExprStateValueExprI:[e tracker] lookup:lookup index:[e index] arrayIndex:[e arrayIndex] mapping:sumOfMappings];
    }
}

-(void) visitExprConjunctI:(ORExprBinaryI*)e
{
    id<ORExpr> left = [self recursiveVisitor:[e left]];
    id<ORExpr> right = [self recursiveVisitor:[e right]];
    current = [left land:right track:[e tracker]];
}
-(void) visitExprDisjunctI:(ORExprBinaryI*)e
{
    id<ORExpr> left = [self recursiveVisitor:[e left]];
    id<ORExpr> right = [self recursiveVisitor:[e right]];
    current = [left lor:right track:[e tracker]];
}
-(void) visitExprImplyI:(ORExprBinaryI*)e
{
    id<ORExpr> left = [self recursiveVisitor:[e left]];
    id<ORExpr> right = [self recursiveVisitor:[e right]];
    current = [left imply:right track:[e tracker]];
}
-(void) visitExprPlusI:(ORExprBinaryI*)e
{
    id<ORExpr> left = [self recursiveVisitor:[e left]];
    id<ORExpr> right = [self recursiveVisitor:[e right]];
    current = [left plus:right track:[e tracker]];
}
-(void) visitExprMinusI:(ORExprBinaryI*)e
{
    id<ORExpr> left = [self recursiveVisitor:[e left]];
    id<ORExpr> right = [self recursiveVisitor:[e right]];
    current = [left sub:right track:[e tracker]];
}
-(void) visitExprMulI:(ORExprBinaryI*)e
{
    id<ORExpr> left = [self recursiveVisitor:[e left]];
    id<ORExpr> right = [self recursiveVisitor:[e right]];
    current = [left mul:right track:[e tracker]];
}
-(void) visitExprDivI:(ORExprBinaryI*)e
{
    id<ORExpr> left = [self recursiveVisitor:[e left]];
    id<ORExpr> right = [self recursiveVisitor:[e right]];
    current = [left div:right track:[e tracker]];
}
-(void) visitExprModI:(ORExprBinaryI*)e
{
    id<ORExpr> left = [self recursiveVisitor:[e left]];
    id<ORExpr> right = [self recursiveVisitor:[e right]];
    current = [left mod:right track:[e tracker]];
}
-(void) visitExprEqualI:(ORExprBinaryI*)e
{
    id<ORExpr> left = [self recursiveVisitor:[e left]];
    id<ORExpr> right = [self recursiveVisitor:[e right]];
    current = [left eq:right track:[e tracker]];
}
-(void) visitExprNEqualI:(ORExprBinaryI*)e
{
    id<ORExpr> left = [self recursiveVisitor:[e left]];
    id<ORExpr> right = [self recursiveVisitor:[e right]];
    current = [left neq:right track:[e tracker]];
}
-(void) visitExprLEqualI:(ORExprBinaryI*)e
{
    id<ORExpr> left = [self recursiveVisitor:[e left]];
    id<ORExpr> right = [self recursiveVisitor:[e right]];
    current = [left leq:right track:[e tracker]];
}
-(void) visitExprGEqualI:(ORExprBinaryI*)e
{
    id<ORExpr> left = [self recursiveVisitor:[e left]];
    id<ORExpr> right = [self recursiveVisitor:[e right]];
    current = [left geq:right track:[e tracker]];
}
-(void) visitExprMinI:(ORExprBinaryI*)e
{
    id<ORExpr> left = [self recursiveVisitor:[e left]];
    id<ORExpr> right = [self recursiveVisitor:[e right]];
    current = [left min:right track:[e tracker]];
}
-(void) visitExprMaxI:(ORExprBinaryI*)e
{
    id<ORExpr> left = [self recursiveVisitor:[e left]];
    id<ORExpr> right = [self recursiveVisitor:[e right]];
    current = [left max:right track:[e tracker]];
}

-(void) visitExprSetContainsI:(ORExprSetContainsI*)e
{
    id<ORExpr> value = [self recursiveVisitor:[e value]];
    id<ORIntSet> set = [e set];
    current = [set contains:value];
}
-(void) visitExprSetExprContainsI:(ORExprBinaryI*)e
{
    id<ORExpr> left = [self recursiveVisitor:[e left]];
    id<ORExpr> right = [self recursiveVisitor:[e right]];
    current = [left contains:right track:[e tracker]];
}
-(void) visitExprIfThenElseI:(ORExprIfThenElseI*)e
{
    id<ORExpr> ifExpr = [self recursiveVisitor:[e ifExpr]];
    id<ORExpr> thenExpr = [self recursiveVisitor:[e thenReturn]];
    id<ORExpr> elseExpr = [self recursiveVisitor:[e elseReturn]];
    current = [ORFactory ifExpr:ifExpr then:thenExpr elseReturn:elseExpr track:[e tracker]];
}
-(void) visitExprArrayIndexI:(ORExprArrayIndexI*)e
{
    id<ORExpr> array = [self recursiveVisitor:[e array]];
    id<ORExpr> index = [self recursiveVisitor:[e index]];
    current = [array arrayIndex:index track:[e tracker]];
}
-(void) visitExprIntArrayIndexI:(ORExprIntArrayIndexI*)e
{
    id<ORIntArray> array = [e array];
    id<ORExpr> index = [self recursiveVisitor:[e index]];
    current = [array atIndex:index];
}
-(void) visitExprDictionaryValueI:(ORExprDictionaryValueI*)e
{
    NSDictionary* dict = [e dict];
    id<ORExpr> key = [self recursiveVisitor:[e key]];
    current = [ORFactory dictionaryValue:[e tracker] dictionary:dict key:key];
}
-(void) visitExprAppendToArrayI:(ORExprBinaryI*)e
{
    id<ORExpr> left = [self recursiveVisitor:[e left]];
    id<ORExpr> right = [self recursiveVisitor:[e right]];
    current = [left appendToArray:right track:[e tracker]];
}
-(void) visitExprMinBetweenArraysI:(ORExprBinaryI*)e
{
    id<ORExpr> left = [self recursiveVisitor:[e left]];
    id<ORExpr> right = [self recursiveVisitor:[e right]];
    current = [left minBetweenArrays:right track:[e tracker]];
}
-(void) visitExprMaxBetweenArraysI:(ORExprBinaryI*)e
{
    id<ORExpr> left = [self recursiveVisitor:[e left]];
    id<ORExpr> right = [self recursiveVisitor:[e right]];
    current = [left maxBetweenArrays:right track:[e tracker]];
}
-(void) visitExprEachInSetPlusI:(ORExprBinaryI*)e
{
    id<ORExpr> left = [self recursiveVisitor:[e left]];
    id<ORExpr> right = [self recursiveVisitor:[e right]];
    current = [left toEachInSetPlus:right track:[e tracker]];
}
-(void) visitExprEachInSetPlusEachInSetI:(ORExprBinaryI*)e
{
    id<ORExpr> left = [self recursiveVisitor:[e left]];
    id<ORExpr> right = [self recursiveVisitor:[e right]];
    current = [left toEachInSetPlusEachInSet:right track:[e tracker]];
}
-(void) visitExprEachInSetLEQI:(ORExprBinaryI*)e
{
    id<ORExpr> left = [self recursiveVisitor:[e left]];
    id<ORExpr> right = [self recursiveVisitor:[e right]];
    current = [left eachInSetLT:right track:[e tracker]];
}
-(void) visitExprEachInSetGEQI:(ORExprBinaryI*)e
{
    id<ORExpr> left = [self recursiveVisitor:[e left]];
    id<ORExpr> right = [self recursiveVisitor:[e right]];
    current = [left eachInSetGT:right track:[e tracker]];
}

-(void) visitIntVar:(id<ORIntVar>)v { current = v; }
-(void) visitIntegerI: (id<ORInteger>) e { current = [ORFactory integer:[e tracker] value:[e value]]; }
-(void) visitMutableIntegerI: (id<ORMutableInteger>) e { current = [ORFactory integer:[e tracker] value:[e intValue]]; }
-(void) visitMutableDouble: (id<ORMutableDouble>) e { current = [ORFactory integer:[e tracker] value:[e doubleValue]]; }
-(void) visitDouble: (id<ORDoubleNumber>) e { current = [ORFactory double:[e tracker] value:[e value]]; }
-(void) visitExprValueAssignmentI:(id<ORExpr>)e
{
    current = [ORFactory valueAssignment:[e tracker]];
}
-(void) visitExprVariableIndexI:(ORExprVariableIndexI*)e
{
    if (_variableMapping == NULL) {
        current = [ORFactory variableIndex:[e tracker] index:[e index]];
    } else {
        current = [ORFactory variableIndex:[e tracker] index:_variableMapping[[e index]]];
    }
}
-(void) visitExprLayerVariableI:(ORExprLayerVariableI*)e
{
    if (_variableMapping == NULL) {
        current = [ORFactory layerVariable:[e tracker]];
    } else {
        current = [[ORExprLayerVariableI alloc] initORExprLayerVariableI:[e tracker] mapping:_variableMapping];
    }
}
-(void) visitExprSizeOfArrayI:(ORExprSizeOfArrayI*)e
{
    id<ORExpr> array = [self recursiveVisitor:[e array]];
    current = [ORFactory sizeOfArray:array track:[e tracker]];
}
-(void) visitExprParentInformationI:(id<ORExpr>)e
{
    current = [ORFactory parentInformation:[e tracker]];
}
-(void) visitExprMinParentInformationI:(id<ORExpr>)e {
    current = [ORFactory minParentInformation:[e tracker]];
}
-(void) visitExprMaxParentInformationI:(id<ORExpr>)e {
    current = [ORFactory maxParentInformation:[e tracker]];
}
-(void) visitExprChildInformationI:(id<ORExpr>)e {
    current = [ORFactory childInformation:[e tracker]];
}
-(void) visitExprMinChildInformationI:(id<ORExpr>)e {
    current = [ORFactory minChildInformation:[e tracker]];
}
-(void) visitExprMaxChildInformationI:(id<ORExpr>)e {
    current = [ORFactory maxChildInformation:[e tracker]];
}
-(void) visitExprLeftInformationI:(id<ORExpr>)e {
    current = [ORFactory leftInformation:[e tracker]];
}
-(void) visitExprRightInformationI:(id<ORExpr>)e {
    current = [ORFactory rightInformation:[e tracker]];
}
-(void) visitExprSingletonSetI:(ORExprSingletonSetI*)e
{
    id<ORExpr> value = [self recursiveVisitor:[e value]];
    
    current = [ORFactory singletonSet:value track:[e tracker]];
}
-(void) visitExprMinMaxSetFromI:(ORExprBinaryI*)e
{
    id<ORExpr> left = [self recursiveVisitor:[e left]];
    id<ORExpr> right = [self recursiveVisitor:[e right]];
    current = [ORFactory generateMinMaxSetFrom:left and:right track:[e tracker]];
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
    id<ORExpr> op = [self recursiveVisitor:[e operand]];
    
    current = [op absTrack:[e tracker]];
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
-(DDClosure) computeClosureAsInteger:(id<ORExpr>)e
{
    [e visit: self];
    DDClosure innerFunction = current;
    current = nil;
    return [(id)^(id* state, ORInt variable, ORInt value) {
        return [NSNumber numberWithInt:(int)innerFunction(state, variable, value)];
    } copy];
    //DDClosure innerFunction = [self recursiveVisitor: e];
    //return [(id)^(id* state, ORInt variable, ORInt value) {
    //    return [NSNumber numberWithInt:(int)innerFunction(state, variable, value)];
    //} copy];
}
-(DDClosure) computeClosureAsBoolean:(id<ORExpr>)e
{
    [e visit: self];
    DDClosure innerFunction = current;
    current = nil;
    return [(id)^(id* state, ORInt variable, ORInt value) {
        return [NSNumber numberWithBool:(bool)innerFunction(state, variable, value)];
    } copy];
    /*DDClosure innerFunction = [self recursiveVisitor: e];
    return [(id)^(id* state, ORInt variable, ORInt value) {
        return [NSNumber numberWithBool:(bool)innerFunction(state, variable, value)];
    } copy];*/
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
    current = [(id)^(id* state, ORInt variable, ORInt value) {
        return left(state, variable, value) + right(state, variable, value);
    } copy];
}
-(void) visitExprMinusI: (ORExprBinaryI*) e
{
    DDClosure left = [self recursiveVisitor:[e left]];
    DDClosure right = [self recursiveVisitor:[e right]];
    current = [(id)^(id* state, ORInt variable, ORInt value) {
        return left(state, variable, value) - right(state, variable, value);
    } copy];
}
-(void) visitExprMulI: (ORExprBinaryI*) e
{
    DDClosure left = [self recursiveVisitor:[e left]];
    DDClosure right = [self recursiveVisitor:[e right]];
    current = [(id)^(id* state, ORInt variable, ORInt value) {
        return left(state, variable, value) * right(state, variable, value);
    } copy];
}
-(void) visitExprDivI: (ORExprBinaryI*) e
{
    DDClosure left = [self recursiveVisitor:[e left]];
    DDClosure right = [self recursiveVisitor:[e right]];
    current = [(id)^(id* state, ORInt variable, ORInt value) {
        return left(state, variable, value) / right(state, variable, value);
    } copy];
}
-(void) visitExprModI: (ORExprBinaryI*) e
{
    DDClosure left = [self recursiveVisitor:[e left]];
    DDClosure right = [self recursiveVisitor:[e right]];
    current = [(id)^(id* state, ORInt variable, ORInt value) {
        return left(state, variable, value) % right(state, variable, value);
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
        return left(state, variable, value) == right(state, variable, value);
    } copy];
}
-(void) visitExprNEqualI: (ORExprBinaryI*) e
{
    DDClosure left = [self recursiveVisitor:[e left]];
    DDClosure right = [self recursiveVisitor:[e right]];
    current = [(id)^(id* state, ORInt variable, ORInt value) {
        return left(state, variable, value) != right(state, variable, value);
    } copy];
}
-(void) visitExprLEqualI: (ORExprBinaryI*) e
{
    DDClosure left = [self recursiveVisitor:[e left]];
    DDClosure right = [self recursiveVisitor:[e right]];
    current = [(id)^(id* state, ORInt variable, ORInt value) {
        return left(state, variable, value) <= right(state, variable, value);
    } copy];
}
-(void) visitExprGEqualI: (ORExprBinaryI*) e
{
    DDClosure left = [self recursiveVisitor:[e left]];
    DDClosure right = [self recursiveVisitor:[e right]];
    current = [(id)^(id* state, ORInt variable, ORInt value) {
        return left(state, variable, value) >= right(state, variable, value);
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
-(void) visitExprNegateI:(ORExprNegateI*)e
{
    DDClosure op = [self recursiveVisitor:[e operand]];
    current = [(id)^(id* state, ORInt variable, ORInt value) {
        return !op(state, variable, value);
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
    DDClosure left = [self recursiveVisitor:[e left]];
    DDClosure right = [self recursiveVisitor:[e right]];
    current = [(id)^(id* state, ORInt variable, ORInt value) {
        return left(state, variable, value) || right(state, variable, value);
    } copy];
}
-(void) visitExprConjunctI: (ORExprBinaryI*) e
{
    DDClosure left = [self recursiveVisitor:[e left]];
    DDClosure right = [self recursiveVisitor:[e right]];
    current = [(id)^(id* state, ORInt variable, ORInt value) {
        return left(state, variable, value) && right(state, variable, value);
    } copy];
}
-(void) visitExprImplyI: (ORExprBinaryI*) e
{
    DDClosure left = [self recursiveVisitor:[e left]];
    DDClosure right = [self recursiveVisitor:[e right]];
    current = [(id)^(id* state, ORInt variable, ORInt value) {
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
    const int look = e->_lookup;
    const int arrayIndex = [e->_arrayIndex value];
    if ([e isArray]) {
        current = [^(id* state, ORInt variable, ORInt value) {
            return (long)[state[look][arrayIndex] intValue];
        } copy];
    } else {
        current = [^(id* state, ORInt variable, ORInt value) {
            return (long)[state[look] intValue];
        } copy];
    }
}
-(void) visitExprStateValueExprI:(ORExprStateValueExprI*)e
{
    DDClosure lookup = [self recursiveVisitor:[e lookup]];
    const int arrayIndex = [e->_arrayIndex value];
    const int* stateMapping = [e mapping];
    
    if ([e isArray] && stateMapping != nil) {
        current = [^(id* state, ORInt variable, ORInt value) {
            long lookupValue = lookup(state, variable, value);
            int mappedLookupValue = stateMapping[lookupValue];
            return (long)[state[mappedLookupValue][arrayIndex] intValue];
        } copy];
    } else if ([e isArray]) {
        current = [^(id* state, ORInt variable, ORInt value) {
            long lookupValue = lookup(state, variable, value);
            return (long)[state[lookupValue][arrayIndex] intValue];
        } copy];
    } else if (stateMapping != nil) {
        current = [^(id* state, ORInt variable, ORInt value) {
            long lookupValue = lookup(state, variable, value);
            int mappedLookupValue = stateMapping[lookupValue];
            return (long)[state[mappedLookupValue] intValue];
        } copy];
    } else {
        current = [^(id* state, ORInt variable, ORInt value) {
            long lookupValue = lookup(state, variable, value);
            return (long)[state[lookupValue] intValue];
        } copy];
    }
}
-(void) visitExprValueAssignmentI:(id<ORExpr>)e
{
    current = [^(id* state, ORInt variable, ORInt value) {
        return (long)value;
    } copy];
}
-(void) visitExprVariableIndexI:(ORExprVariableIndexI*)e
{
    current = [^(id* state, ORInt variable, ORInt value) {
        return (long)[e index];
    } copy];
}
-(void) visitExprLayerVariableI:(ORExprLayerVariableI*)e
{
    current = [^(id* state, ORInt variable, ORInt value) {
        if ([e mapping] != nil) {
            return (long)variable;
        }
        return (long)[e mapping][variable];
    } copy];
}
-(void) visitExprSizeOfArrayI:(ORExprSizeOfArrayI*)e
{
    DDClosure array = [self recursiveVisitor:[e array]];
    current = [^(id* state, ORInt variable, ORInt value) {
        return (long)[(id)array(state, variable, value) count];
    } copy];
}
-(void) visitExprSetContainsI:(ORExprSetContainsI*)e
{
    DDClosure right = [self recursiveVisitor:[e value]];
    current = [^(id* state, ORInt variable, ORInt value) {
        return (long)[[e set] member: (ORInt)right(state, variable, value)];
    } copy];
}
-(void) visitExprSetExprContainsI:(ORExprSetExprContainsI*)e
{
    @throw [[ORExecutionError alloc] initORExecutionError: "ExprSetExprContainsI: visit method not defined"];
}
-(void) visitExprDictionaryValueI:(ORExprDictionaryValueI*)e
{
    NSDictionary* dict = [e dict];
    DDClosure key = [self recursiveVisitor:[e key]];
    current = [^(id* state, ORInt variable, ORInt value) {
        return [[dict objectForKey:[NSNumber numberWithLong: key(state,variable,value)]] longValue];
    } copy];
}
@end

@implementation ORDDMergeClosureGenerator
-(ORDDMergeClosureGenerator*) initORDDMergeClosureGenerator {
    self = [super init];
    return self;
}

-(DDMergeClosure) computeClosure:(id<ORExpr>)e
{
    if (e != NULL) {
        [e visit: self];
        return current;
    }
    return NULL;
}
-(DDMergeClosure) computeClosureAsInteger:(id<ORExpr>)e
{
    [e visit: self];
    DDMergeClosure innerFunction = current;
    current = nil;
    return [(id)^(id* state1, id* state2) {
        return [NSNumber numberWithInt:(int)innerFunction(state1, state2)];
    } copy];
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
    current = [(id)^(id* state1, id* state2) {
        return left(state1, state2) + right(state1, state2);
    } copy];
}
-(void) visitExprMinusI: (ORExprBinaryI*) e
{
    DDMergeClosure left = [self recursiveVisitor:[e left]];
    DDMergeClosure right = [self recursiveVisitor:[e right]];
    current = [(id)^(id* state1, id* state2) {
        return left(state1, state2) - right(state1, state2);
    } copy];
}
-(void) visitExprMulI: (ORExprBinaryI*) e
{
    DDMergeClosure left = [self recursiveVisitor:[e left]];
    DDMergeClosure right = [self recursiveVisitor:[e right]];
    current = [(id)^(id* state1, id* state2) {
        return left(state1, state2) * right(state1, state2);
    } copy];
}
-(void) visitExprDivI: (ORExprBinaryI*) e
{
    DDMergeClosure left = [self recursiveVisitor:[e left]];
    DDMergeClosure right = [self recursiveVisitor:[e right]];
    current = [(id)^(id* state1, id* state2) {
        return left(state1, state2) / right(state1, state2);
    } copy];
}
-(void) visitExprModI: (ORExprBinaryI*) e
{
    DDMergeClosure left = [self recursiveVisitor:[e left]];
    DDMergeClosure right = [self recursiveVisitor:[e right]];
    current = [(id)^(id* state1, id* state2) {
        return left(state1, state2) % right(state1, state2);
    } copy];
}
-(void) visitExprMinI: (ORExprMinI*) e
{
    DDMergeClosure left = [self recursiveVisitor:[e left]];
    DDMergeClosure right = [self recursiveVisitor:[e right]];
    current = [(id)^(id* state1, id* state2) {
        return min((ORInt)left(state1, state2), (ORInt)right(state1, state2));
    } copy];
}
-(void) visitExprMaxI: (ORExprMaxI*) e
{
    DDMergeClosure left = [self recursiveVisitor:[e left]];
    DDMergeClosure right = [self recursiveVisitor:[e right]];
    current = [(id)^(id* state1, id* state2) {
        return max((ORInt)left(state1, state2), (ORInt)right(state1, state2));
    } copy];
}
-(void) visitExprEqualI: (ORExprBinaryI*) e
{
    DDMergeClosure left = [self recursiveVisitor:[e left]];
    DDMergeClosure right = [self recursiveVisitor:[e right]];
    current = [(id)^(id* state1, id* state2) {
        return left(state1, state2) == right(state1, state2);
    } copy];
}
-(void) visitExprNEqualI: (ORExprBinaryI*) e
{
    DDMergeClosure left = [self recursiveVisitor:[e left]];
    DDMergeClosure right = [self recursiveVisitor:[e right]];
    current = [(id)^(id* state1, id* state2) {
        return left(state1, state2) != right(state1, state2);
    } copy];
}
-(void) visitExprLEqualI: (ORExprBinaryI*) e
{
    DDMergeClosure left = [self recursiveVisitor:[e left]];
    DDMergeClosure right = [self recursiveVisitor:[e right]];
    current = [(id)^(id* state1, id* state2) {
        return left(state1, state2) <= right(state1, state2);
    } copy];
}
-(void) visitExprGEqualI: (ORExprBinaryI*) e
{
    DDMergeClosure left = [self recursiveVisitor:[e left]];
    DDMergeClosure right = [self recursiveVisitor:[e right]];
    current = [(id)^(id* state1, id* state2) {
        return left(state1, state2) >= right(state1, state2);
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
        return abs((ORInt)inner(state1, state2));
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
        return left(state1, state2) || right(state1, state2);
    } copy];
}
-(void) visitExprConjunctI: (ORExprBinaryI*) e
{
    DDMergeClosure left = [self recursiveVisitor:[e left]];
    DDMergeClosure right = [self recursiveVisitor:[e right]];
    current = [(id)^(id* state1, id* state2) {
        return left(state1, state2) && right(state1, state2);
    } copy];
}
-(void) visitExprImplyI: (ORExprBinaryI*) e
{
    DDMergeClosure left = [self recursiveVisitor:[e left]];
    DDMergeClosure right = [self recursiveVisitor:[e right]];
    current = [(id)^(id* state1, id* state2) {
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
    const int idx = e->_stateIndex;
    const int look = e->_lookup;
    if (idx == 0)
        current = [^(id* state1, id* state2) {
                return (long)[state1[look] intValue];
        } copy];
    else {
        current = [^(id* state1, id* state2) {
            return (long)[state2[look] intValue];
        } copy];
    }
}
-(void) visitExprStateValueExprI:(ORExprStateValueExprI*)e
{
    DDMergeClosure lookup = [self recursiveVisitor:[e lookup]];
    const int idx = e->_stateIndex;
    
    if (idx == 0)
        current = [^(id* state1, id* state2) {
            long lookupValue = lookup(state1, state2);
            if ([e mapping] != nil) {
                int mappedLookupValue = [e mapping][lookupValue];
                return (long)[state1[mappedLookupValue][[e arrayIndex]] intValue];
            }
            return (long)[state1[lookupValue][[e arrayIndex]] intValue];
        } copy];
    else {
        current = [^(id* state1, id* state2) {
            long lookupValue = lookup(state1, state2);
            if ([e mapping] != nil) {
                int mappedLookupValue = [e mapping][lookupValue];
                return (long)[state2[mappedLookupValue] intValue];
            }
            return (long)[state2[lookupValue] intValue];
        } copy];
    }
}
-(void) visitExprValueAssignmentI:(id<ORExpr>)e
{
    @throw [[ORExecutionError alloc] initORExecutionError: "ExprValueAssignmentI: visit method not defined"];
}
-(void) visitExprVariableIndexI:(id<ORExpr>)e
{
    @throw [[ORExecutionError alloc] initORExecutionError: "ExprVariableIndexI: visit method not defined"];
}
-(void) visitExprLayerVariableI:(id<ORExpr>)e
{
    @throw [[ORExecutionError alloc] initORExecutionError: "ExprLayerVariableI: visit method not defined"];
}
-(void) visitExprSizeOfArrayI:(ORExprSizeOfArrayI*)e
{
    DDMergeClosure array = [self recursiveVisitor:[e array]];
    current = [^(id* state1, id* state2) {
        return [(id)array(state1, state2) count];
    } copy];
}
-(void) visitExprSetContainsI:(ORExprSetContainsI*)e
{
    DDMergeClosure right = [self recursiveVisitor:[e value]];
    current = [^(id* state1, id* state2) {
        return [[e set] member: (ORInt)right(state1, state2)];
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
-(void) visitExprStateValueExprI:(ORExprStateValueExprI*)e
{
    @throw [[ORExecutionError alloc] initORExecutionError: "ExprStateValueExprI: visit method not defined"];
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
        return [parent retain];
    } copy];
}
-(void) visitExprMinParentInformationI:(id<ORExpr>)e
{
    current = [(id)^(id parent,id child,ORInt variable,ORInt value) {
        return [[parent objectAtIndex:0] retain];
    } copy];
}
-(void) visitExprMaxParentInformationI:(id<ORExpr>)e
{
    current = [(id)^(id parent,id child,ORInt variable,ORInt value) {
        return [[parent objectAtIndex:1] retain];
    } copy];
}
-(void) visitExprChildInformationI:(id<ORExpr>)e
{
    current = [(id)^(id parent,id child,ORInt variable,ORInt value) {
        return [child retain];
    } copy];
}
-(void) visitExprMinChildInformationI:(id<ORExpr>)e
{
    current = [(id)^(id parent,id child,ORInt variable,ORInt value) {
        return [[child objectAtIndex:0] retain];
    } copy];
}
-(void) visitExprMaxChildInformationI:(id<ORExpr>)e
{
    current = [(id)^(id parent,id child,ORInt variable,ORInt value) {
        return [[child objectAtIndex:1] retain];
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
        int addition = [right(parent,child,variable,value) intValue];
        for (NSNumber* item in set) {
            [newSet addObject:[[NSNumber alloc] initWithInt:[item intValue]+addition]];
        }
        [set release];
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
        [set1 release];
        [set2 release];
        return newSet;
    } copy];
}
-(void) visitExprEachInSetLEQI:(ORExprBinaryI*)e
{
    AltMDDDeleteEdgeCheckClosure left = [self recursiveVisitor:[e left]];
    AltMDDDeleteEdgeCheckClosure right = [self recursiveVisitor:[e right]];
    current = [^(id parent,id child,ORInt variable,ORInt value) {
        NSSet* set = (NSSet*)left(parent,child,variable,value);
        int upper = [right(parent,child,variable,value) intValue];
        for (NSNumber* item in set) {
            if ([item intValue] > upper) {
                [set release];
                return [NSNumber numberWithBool:false];
            }
        }
        [set release];
        return [NSNumber numberWithBool:true];
    } copy];
}
-(void) visitExprEachInSetGEQI:(ORExprBinaryI*)e
{
    AltMDDDeleteEdgeCheckClosure left = [self recursiveVisitor:[e left]];
    AltMDDDeleteEdgeCheckClosure right = [self recursiveVisitor:[e right]];
    current = [^(id parent,id child,ORInt variable,ORInt value) {
        NSSet* set = (NSSet*)left(parent,child,variable,value);
        int lower = [right(parent,child,variable,value) intValue];
        for (NSNumber* item in set) {
            if ([item intValue] < lower) {
                [set release];
                return [NSNumber numberWithBool:false];
            }
        }
        [set release];
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
        return [NSNumber numberWithInt: ([left(leftParent, rightParent, variable) intValue] + [right(leftParent, rightParent, variable) intValue])];  //Only works for ints
    } copy];
}
-(void) visitExprMinusI: (ORExprBinaryI*) e
{
    AltMDDMergeInfoClosure left = [self recursiveVisitor:[e left]];
    AltMDDMergeInfoClosure right = [self recursiveVisitor:[e right]];
    current = [(id)^(id leftParent,id rightParent,ORInt variable) {
        return [NSNumber numberWithInt: ([left(leftParent, rightParent, variable) intValue] - [right(leftParent, rightParent, variable) intValue])];  //Only works for ints
    } copy];
}
-(void) visitExprMulI: (ORExprBinaryI*) e
{
    AltMDDMergeInfoClosure left = [self recursiveVisitor:[e left]];
    AltMDDMergeInfoClosure right = [self recursiveVisitor:[e right]];
    current = [(id)^(id leftParent,id rightParent,ORInt variable) {
        return [NSNumber numberWithInt: ([left(leftParent, rightParent, variable) intValue] * [right(leftParent, rightParent, variable) intValue])];  //Only works for ints
    } copy];
}
-(void) visitExprDivI: (ORExprBinaryI*) e
{
    AltMDDMergeInfoClosure left = [self recursiveVisitor:[e left]];
    AltMDDMergeInfoClosure right = [self recursiveVisitor:[e right]];
    current = [(id)^(id leftParent,id rightParent,ORInt variable) {
        return [NSNumber numberWithInt: ([left(leftParent, rightParent, variable) intValue] / [right(leftParent, rightParent, variable) intValue])];  //Only works for ints
    } copy];
}
-(void) visitExprModI: (ORExprBinaryI*) e
{
    AltMDDMergeInfoClosure left = [self recursiveVisitor:[e left]];
    AltMDDMergeInfoClosure right = [self recursiveVisitor:[e right]];
    current = [(id)^(id leftParent,id rightParent,ORInt variable) {
        return [NSNumber numberWithInt: ([left(leftParent, rightParent, variable) intValue] % [right(leftParent, rightParent, variable) intValue])];  //Only works for ints
    } copy];
}
-(void) visitExprMinI: (ORExprMinI*) e
{
    AltMDDMergeInfoClosure left = [self recursiveVisitor:[e left]];
    AltMDDMergeInfoClosure right = [self recursiveVisitor:[e right]];
    current = [(id)^(id leftParent,id rightParent,ORInt variable) {
        return [NSNumber numberWithInt: min([left(leftParent, rightParent, variable) intValue], [right(leftParent, rightParent, variable) intValue])];  //Only works for ints
    } copy];
}
-(void) visitExprMaxI: (ORExprMaxI*) e
{
    AltMDDMergeInfoClosure left = [self recursiveVisitor:[e left]];
    AltMDDMergeInfoClosure right = [self recursiveVisitor:[e right]];
    current = [(id)^(id leftParent,id rightParent,ORInt variable) {
        return [NSNumber numberWithInt: max([left(leftParent, rightParent, variable) intValue], [right(leftParent, rightParent, variable) intValue])];  //Only works for ints
    } copy];
}
-(void) visitExprEqualI: (ORExprBinaryI*) e
{
    AltMDDMergeInfoClosure left = [self recursiveVisitor:[e left]];
    AltMDDMergeInfoClosure right = [self recursiveVisitor:[e right]];
    current = [(id)^(id leftParent,id rightParent,ORInt variable) {
        return [NSNumber numberWithBool: ([left(leftParent, rightParent, variable) intValue] == [right(leftParent, rightParent, variable) intValue])];  //Only works for ints
    } copy];
}
-(void) visitExprNEqualI: (ORExprBinaryI*) e
{
    AltMDDMergeInfoClosure left = [self recursiveVisitor:[e left]];
    AltMDDMergeInfoClosure right = [self recursiveVisitor:[e right]];
    current = [(id)^(id leftParent,id rightParent,ORInt variable) {
        return [NSNumber numberWithBool: ([left(leftParent, rightParent, variable) intValue] != [right(leftParent, rightParent, variable) intValue])];  //Only works for ints
    } copy];
}
-(void) visitExprLEqualI: (ORExprBinaryI*) e
{
    AltMDDMergeInfoClosure left = [self recursiveVisitor:[e left]];
    AltMDDMergeInfoClosure right = [self recursiveVisitor:[e right]];
    current = [(id)^(id leftParent,id rightParent,ORInt variable) {
        return [NSNumber numberWithBool: ([left(leftParent, rightParent, variable) intValue] <= [right(leftParent, rightParent, variable) intValue])];  //Only works for ints
    } copy];
}
-(void) visitExprGEqualI: (ORExprBinaryI*) e
{
    AltMDDMergeInfoClosure left = [self recursiveVisitor:[e left]];
    AltMDDMergeInfoClosure right = [self recursiveVisitor:[e right]];
    current = [(id)^(id leftParent,id rightParent,ORInt variable) {
        return [NSNumber numberWithBool: ([left(leftParent, rightParent, variable) intValue] >= [right(leftParent, rightParent, variable) intValue])];  //Only works for ints
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
        return [NSNumber numberWithInt: abs([inner(leftParent, rightParent, variable) intValue])];
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
-(void) visitExprStateValueExprI:(ORExprStateValueI*)e
{
    @throw [[ORExecutionError alloc] initORExecutionError: "ExprStateValueExprI: visit method not defined"];
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
        NSSet* l = (NSSet*)left(leftParent, rightParent, variable);
        NSSet* r = (NSSet*)right(leftParent, rightParent, variable);
        NSSet* retVal = [[[NSSet alloc] initWithSet:l] setByAddingObjectsFromSet:r];
        [l release];
        [r release];
        return retVal;
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
-(void) visitExprStateValueExprI:(ORExprStateValueI*)e
{
    @throw [[ORExecutionError alloc] initORExecutionError: "ExprStateValueExprI: visit method not defined"];
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
        return [parent retain];
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
        int addition = [right(parent,variable,value) intValue];
        for (NSNumber* item in set) {
            [newSet addObject:[[NSNumber alloc] initWithInt:[item intValue]+addition]];
        }
        [set release];
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
        [set1 release];
        [set2 release];
        return newSet;
    } copy];
}
-(void) visitExprEachInSetLEQI:(ORExprBinaryI*)e
{
    AltMDDAddEdgeClosure left = [self recursiveVisitor:[e left]];
    AltMDDAddEdgeClosure right = [self recursiveVisitor:[e right]];
    current = [^(id parent,ORInt variable,ORInt value) {
        NSSet* set = (NSSet*)left(parent,variable,value);
        int upper = [right(parent,variable,value) intValue];
        for (NSNumber* item in set) {
            if ([item intValue] > upper) {
                return [NSNumber numberWithBool:false];
            }
        }
        [set release];
        return [NSNumber numberWithBool:true];
    } copy];
}
-(void) visitExprEachInSetGEQI:(ORExprBinaryI*)e
{
    AltMDDAddEdgeClosure left = [self recursiveVisitor:[e left]];
    AltMDDAddEdgeClosure right = [self recursiveVisitor:[e right]];
    current = [^(id parent,ORInt variable,ORInt value) {
        NSSet* set = (NSSet*)left(parent,variable,value);
        int lower = [right(parent,variable,value) intValue];
        for (NSNumber* item in set) {
            if ([item intValue] < lower) {
                return [NSNumber numberWithBool:false];
            }
        }
        [set release];
        return [NSNumber numberWithBool:true];
    } copy];
}
@end
