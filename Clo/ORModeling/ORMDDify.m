/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "ORMDDify.h"
#import "ORModelI.h"
#import "ORVarI.h"
#import "ORDecompose.h"
#import "ORRealDecompose.h"
#import "ORMDDVisitors.h"
#import "ORCustomMDDStates.h"

@implementation ORFactory(MDD)
+(void) sortIntVarArray:(NSMutableArray*)array first:(ORInt)first last:(ORInt)last {
    ORInt i, j, pivot;
    id<ORIntVar> temp;
    
    if(first<last){
        pivot=first;
        i=first;
        j=last;
        
        while(i<j){
            while([array objectAtIndex:i]<=[array objectAtIndex:pivot]&&i<last)
                i++;
            while([array objectAtIndex:j]>[array objectAtIndex:pivot])
                j--;
            if(i<j){
                temp=[array objectAtIndex:i];
                [array setObject: [array objectAtIndex:j] atIndexedSubscript:i];
                [array setObject:temp atIndexedSubscript:j];
            }
        }
        
        temp=[array objectAtIndex:pivot];
        [array setObject:[array objectAtIndex:j] atIndexedSubscript:pivot];
        [array setObject:temp atIndexedSubscript:j];
        [self sortIntVarArray: array first:first last:j-1];
        [self sortIntVarArray: array first:j+1 last:last];
    }
}

//This does end up creating sub-VarArrays and adding them to the model along the way.  Is this too costly?  Can it be avoided somehow?
+(id<ORIntVarArray>) mergeIntVarArray:(id<ORIntVarArray>)x with:(id<ORIntVarArray>)y tracker:(id<ORTracker>) t {
    NSMutableArray<id<ORIntVar>> *mergedTemp = [[NSMutableArray alloc] init];
    NSMutableArray<id<ORIntVar>> *sortedX = [[NSMutableArray alloc] init];
    NSMutableArray<id<ORIntVar>> *sortedY = [[NSMutableArray alloc] init];
    ORInt size = 0;
    
    if (x == NULL) {
        for (int i = 1; i <= [y count]; i++) {
            [sortedY addObject: y[i]];
        }
        [self sortIntVarArray:sortedY first:0 last:(ORInt)([y count] - 1)];
        size = (ORInt)[y count];
        id<ORIntRange> range = RANGE(t,1,size);
        id<ORIntVarArray> merged = [ORFactory intVarArray:t range:range];
        for (int i = 1; i <= size; i++) {
            [merged setObject:sortedY[i - 1] atIndexedSubscript:i];
        }
        return merged;
    }
    if (y == NULL) {
        for (int i = 1; i <= [x count]; i++) {
            [sortedX addObject: x[i]];
        }
        [self sortIntVarArray:sortedX first:0 last:(ORInt)([x count] - 1)];
        size = (ORInt)[x count];
        id<ORIntRange> range = RANGE(t,1,size);
        id<ORIntVarArray> merged = [ORFactory intVarArray:t range:range];
        for (int i = 1; i <= size; i++) {
            [merged setObject:sortedX[i - 1] atIndexedSubscript:i];
        }
        return merged;
    }
    
    for (int i = 1; i <= [x count]; i++) {
        [sortedX addObject: x[i]];
    }
    for (int i = 1; i <= [y count]; i++) {
        [sortedY addObject: y[i]];
    }
    [self sortIntVarArray:sortedX first:0 last:(ORInt)([x count] - 1)];
    [self sortIntVarArray:sortedY first:0 last:(ORInt)([y count] - 1)];
    
    ORInt xIndex = 0, yIndex = 0;
    
    while (xIndex < [x count] || yIndex < [y count]) {
        if (xIndex < [x count] && (yIndex >= [y count] || sortedX[xIndex] < sortedY[yIndex])) {
            [mergedTemp setObject:[sortedX objectAtIndex:xIndex] atIndexedSubscript:size];
            xIndex++;
            size++;
        } else if (xIndex >= [x count] || sortedX[xIndex] > sortedY[yIndex]) {
            [mergedTemp setObject:[sortedY objectAtIndex:yIndex] atIndexedSubscript:size];
            yIndex++;
            size++;
        } else {
            [mergedTemp setObject:[sortedX objectAtIndex:xIndex] atIndexedSubscript:size];
            xIndex++;
            yIndex++;
            size++;
        }
    }
    id<ORIntRange> range = RANGE(t,1,size);
    id<ORIntVarArray> merged = [ORFactory intVarArray:t range:range];
    for (int i = 1; i <= size; i++) {
        [merged setObject:mergedTemp[i - 1] atIndexedSubscript:i];
    }
    return merged;
}
@end

 
@implementation ORMDDify {
@protected
    id<ORAddToModel> _into;
    id<ORAnnotation> _notes;
    id<ORIntVarArray> _variables;
    
    NSMutableArray* _mddConstraints;
    bool _hasObjective;
    id<ORIntVar> _objectiveVar;
    bool _maximize;
    bool _relaxed;
    
    NSMutableArray* _mddSpecConstraints;
}

-(id)initORMDDify: (id<ORAddToModel>) into
{
    self = [super init];
    _into = into;
    _mddConstraints = [[NSMutableArray alloc] init];
    _mddSpecConstraints = [[NSMutableArray alloc] init];
    _variables = NULL;
    _maximize = false;
    _hasObjective = false;
    return self;
}

-(void) apply:(id<ORModel>) m with:(id<ORAnnotation>)notes {
    _notes = notes;
    ORInt width = [_notes findGeneric: DDWidth];
    _relaxed = [_notes findGeneric: DDRelaxed];
    [JointState stateClassesInit];
    [m applyOnVar: ^(id<ORVar> x) {
        [_into addVariable:x];
    }
       onMutables: ^(id<ORObject> x) {
           [_into addMutable: x];
       }
     onImmutables: ^(id<ORObject> x) {
         [_into addImmutable:x];
     }
     onConstraints: ^(id<ORConstraint> c) {
        [_into setCurrent:c];
        if (true) { //Should check if c is MDDifiable.  aka if it has a visit function down below
        [c visit: self];
        }
        [_into setCurrent:nil];
    }
      onObjective: ^(id<ORObjectiveFunction> o) {
          [o visit: self];
      }];
    
    if ([_mddSpecConstraints count] > 0) {
        [self combineMDDSpecs];
    }
    
    id<ORConstraint> mddConstraint;
    
    if ([AltJointState numStates] > 0) {
        [AltJointState setVariables:_variables];
        //if ([AltJointState numStates] > 1) {
            mddConstraint = [ORFactory CustomMDD:m var:_variables relaxed:_relaxed size:width stateClass:[AltJointState class]];
        //} else {
        //    CustomState* onlyState = [JointState firstState];
        //    [[onlyState class] setAsOnlyMDDWithClassState: onlyState];
        //    mddConstraint = [ORFactory CustomMDD:m var:_variables relaxed:_relaxed size:width stateClass:[onlyState class]];
        //}
    } else {
        [JointState setVariables:_variables];
        
        if (_hasObjective) {
            mddConstraint = [ORFactory CustomMDDWithObjective:m var:_variables relaxed:_relaxed size:width objective: _objectiveVar maximize:_maximize stateClass:[JointState class]];
        } else {
            if ([JointState numStates] > 1) {
                mddConstraint = [ORFactory CustomMDD:m var:_variables relaxed:_relaxed size:width stateClass:[JointState class]];
            } else {
                CustomState* onlyState = [JointState firstState];
                [[onlyState class] setAsOnlyMDDWithClassState: onlyState];
                mddConstraint = [ORFactory CustomMDD:m var:_variables relaxed:_relaxed size:width stateClass:[onlyState class]];
            }
        }
    }
    
    [_into trackConstraintInGroup: mddConstraint];
    [_into addConstraint: mddConstraint];
    
    //if ([_mddConstraints count] == 1) {
    //    id<ORConstraint> preMDDConstraint = _mddConstraints[0];
    //
    //    id<ORConstraint> mddConstraint = [ORFactory RelaxedCustomMDD:m var:_variables size: 15 stateClass:[AllDifferentMDDState class]];
    //    [_into addConstraint: mddConstraint];
    //}
}

-(id<ORAddToModel>)target { return _into; }

-(NSDictionary*) checkForStateEquivalences:(id<ORMDDSpecs>)mergeInto and:(id<ORMDDSpecs>)other {
    NSMutableDictionary* mappings = [[NSMutableDictionary alloc] init];
    int stateSize1 = [mergeInto stateSize];
    int stateSize2 = [other stateSize];
    ORDDExpressionEquivalenceChecker* equivalenceChecker = [[ORDDExpressionEquivalenceChecker alloc] init];
    
    int** candidates = malloc(stateSize1 * sizeof(int*));
    for (int i = 0; i < stateSize1; i++) {
        candidates[i] = malloc(stateSize2 * sizeof(int));
        for (int j = 0; j < stateSize2; j++) {
            candidates[i][j] = true;
        }
    }
    
    for (int i = 0; i < stateSize1; i++) {
        for (int j = 0; j < stateSize2; j++) {
            if (candidates[i][j]) {
                NSMutableDictionary* dependentMappings = [[NSMutableDictionary alloc] init];
                if ([self areEquivalent:mergeInto atIndex:i and:other atIndex:j withDependentMapping:dependentMappings andConfirmedMapping:mappings equivalenceVisitor:equivalenceChecker candidates:candidates]) {
                    [mappings addEntriesFromDictionary:dependentMappings];
                    NSArray* keys = [dependentMappings allKeys];
                    for (NSNumber* key in keys) {
                        int otherIndex = [key intValue];
                        int mergeIntoIndex = [[dependentMappings objectForKey:key] intValue];
                        for (int index = i; index < stateSize1; index++) {
                            candidates[index][otherIndex] = false;
                        }
                        for (int index = j; index < stateSize2; index++) {
                            candidates[mergeIntoIndex][index] = false;
                        }
                    }
                } else {
                    candidates[i][j] = false;
                }
            }
        }
    }
    
    return mappings;
}

-(bool) areEquivalent:(id<ORMDDSpecs>)mergeInto atIndex:(int)index1 and:(id<ORMDDSpecs>)other atIndex:(int)index2 withDependentMapping:(NSMutableDictionary*)dependentMappings andConfirmedMapping:(NSMutableDictionary*)confirmedMappings equivalenceVisitor:(ORDDExpressionEquivalenceChecker*)equivalenceChecker candidates:(int**)candidates
{
    if ([mergeInto stateValues][index1] != [other stateValues][index2]) {   //Different initial value
        candidates[index1][index2] = false;
        return false;
    }
    
    id<ORExpr> mergeIntoTransitionFunction = [mergeInto transitionFunctions][index1];
    id<ORExpr> otherTransitionFunction = [other transitionFunctions][index2];
    NSMutableArray* dependencies = [equivalenceChecker checkEquivalence: mergeIntoTransitionFunction and:otherTransitionFunction];
    id<ORExpr> mergeIntoRelaxationFunction = [mergeInto relaxationFunctions][index1];
    id<ORExpr> otherRelaxationFunction = [other relaxationFunctions][index2];
    NSArray* relaxationDependencies = [equivalenceChecker checkEquivalence:mergeIntoRelaxationFunction and:otherRelaxationFunction];
    id<ORExpr> mergeIntoDifferentialFunction = [mergeInto differentialFunctions][index1];
    id<ORExpr> otherDifferentialFunction = [other differentialFunctions][index2];
    NSArray* differentialDependencies = [equivalenceChecker checkEquivalence:mergeIntoDifferentialFunction and:otherDifferentialFunction];
    [dependencies addObjectsFromArray:relaxationDependencies];
    [dependencies addObjectsFromArray:differentialDependencies];
    if (dependencies == NULL) { //Transition, relaxation, or differential function is different
        candidates[index1][index2] = false;
        return false;
    }
    [dependentMappings setObject:[[NSNumber alloc] initWithInt:index1] forKey:[[NSNumber alloc] initWithInt:index2]];
    for (id dependency in dependencies) {
        int mergeIntoDependency = [dependency[0] intValue];
        NSNumber* mergeIntoDependencyObj = [[NSNumber alloc] initWithInt: mergeIntoDependency];
        int otherDependency = [dependency[1] intValue];
        NSNumber* otherDependencyObj = [[NSNumber alloc] initWithInt: otherDependency];
        if (!([confirmedMappings objectForKey:otherDependencyObj] == mergeIntoDependencyObj ||
              [dependentMappings objectForKey:otherDependencyObj] == mergeIntoDependencyObj)) {
            //Not already a found mapping
            if (!candidates[mergeIntoDependency][otherDependency]) {
                //If already confirmed to not be a mapping
                return false;
            }
            
            if (![self areEquivalent:mergeInto atIndex:mergeIntoDependency and:other atIndex:otherDependency withDependentMapping:dependentMappings andConfirmedMapping:confirmedMappings equivalenceVisitor:equivalenceChecker candidates:candidates]) {
                return false;
            }
        }
    }
    return true;
}

-(void) combineMDDSpecs
{
    NSMutableArray* mainMDDSpecList = [[NSMutableArray alloc] initWithObjects:[_mddSpecConstraints objectAtIndex:0],nil];

    
    for (int mddSpecIndex = 1; mddSpecIndex < [_mddSpecConstraints count]; mddSpecIndex++) {
        id<ORMDDSpecs> mddSpec = [_mddSpecConstraints objectAtIndex:mddSpecIndex];
        
        bool sharedVarList = false;
        for (id<ORMDDSpecs> mainMDDSpec in mainMDDSpecList) {
            if ([mainMDDSpec vars] == [mddSpec vars]) {
                sharedVarList = true;
                int mainStateSize = [mainMDDSpec stateSize];
                
                int* stateValues = [mddSpec stateValues];
                int stateSize = [mddSpec stateSize];
                id<ORExpr>* transitionFunctions = [mddSpec transitionFunctions];
                id<ORExpr>* relaxationFunctions = [mddSpec relaxationFunctions];
                id<ORExpr>* differentialFunctions = [mddSpec differentialFunctions];
                
                NSDictionary* mergeMappings = [self checkForStateEquivalences:mainMDDSpec and:mddSpec];
                
                int numShared = (int)[mergeMappings count];
                int numToAdd = stateSize - numShared;
                int* separateStatesToAdd = malloc(numToAdd * sizeof(int));
                int* indicesToAdd = malloc(numToAdd * sizeof(int));
                
                NSMutableDictionary* totalMapping = [[NSMutableDictionary alloc] init];
                int newStateCount = 0;
                for (int index = 0; index < stateSize; index++) {
                    NSNumber* mergeMappingValue =[mergeMappings objectForKey:[[NSNumber alloc] initWithInt:index]];
                    if (mergeMappingValue == nil) {
                        [totalMapping setObject:[[NSNumber alloc] initWithInt: (newStateCount+mainStateSize)] forKey:[[NSNumber alloc] initWithInt: index]];
                        separateStatesToAdd[newStateCount] = stateValues[index];
                        indicesToAdd[newStateCount] = index;
                        newStateCount++;
                    }
                }
                [totalMapping addEntriesFromDictionary:mergeMappings];
                
                [mainMDDSpec addStates:separateStatesToAdd size:numToAdd];
                
                ORDDUpdateSpecs* updateFunctions = [[ORDDUpdateSpecs alloc] initORDDUpdateSpecs:totalMapping];
                
                for (int i = 0; i < numToAdd; i++) {
                    int index = indicesToAdd[i];
                    
                    [updateFunctions updateSpecs:transitionFunctions[index]];
                    [mainMDDSpec addTransitionFunction:transitionFunctions[index] toStateValue:(mainStateSize+i)];
                    
                    [updateFunctions updateSpecs:differentialFunctions[index]];
                    [mainMDDSpec addStateDifferentialFunction:differentialFunctions[index] toStateValue:(mainStateSize+i)];
                }
                if (_relaxed) {
                    for  (int i = 0; i < numToAdd; i++) {
                        int index = indicesToAdd[i];
                    
                        [updateFunctions updateSpecs:relaxationFunctions[index]];
                        [mainMDDSpec addRelaxationFunction:relaxationFunctions[index] toStateValue:(mainStateSize+i)];
                    }
                }
                id<ORExpr> oldArcExists = [mainMDDSpec arcExists];
                id<ORExpr> arcExists = [mddSpec arcExists];
                [updateFunctions updateSpecs:arcExists];
                id<ORExpr> newArcExists = [oldArcExists land:arcExists];
                [mainMDDSpec setArcExistsFunction:newArcExists];
                
                break;
                /*
                NSMutableDictionary* mergeMapping = [[NSMutableDictionary alloc] init];
                for (int mainStateIndex = 0; mainStateIndex < mainStateSize; mainStateIndex++) {
                    for (int stateIndex = 0; stateIndex < stateSize; stateIndex++) {
                        if (mainStateValues[mainStateIndex] == stateValues[stateIndex]) {   //Same initial value
                            NSArray* dependencies = [equivalenceChecker checkEquivalence: mainTransitionFunctions[mainStateIndex] and:transitionFunctions[stateIndex]];
                            if (dependencies != NULL) {
                                if ([dependencies count] == 0) {
                                    [mergeMapping setObject:[[NSNumber alloc] initWithInt:mainStateIndex] forKey:[[NSNumber alloc] initWithInt:stateIndex]];
                                } else {
                                    bool dependenciesAreValid = true;
                                    for (id dependency in dependencies) {
                                        int mainStateValue = [dependency[0] intValue];
                                        int stateValue = [dependency[1] intValue];
                                        if (mainStateValue < mainStateIndex || (mainStateValue == mainStateIndex && stateValue < stateIndex)) {
                                            //If we've already checked this potential mapping
                                            if ([mergeMapping objectForKey:dependency[1]] != dependency[0]) {
                                                //Mapping has been found to not hold
                                                dependenciesAreValid = false;
                                                break;
                                            }
                                        } else if (mainStateValue != mainStateIndex || stateValue != stateIndex) {
                                            //Is not one already checked and isn't just itself
                                            
                                            
                                        }
                                    }
                                    if (dependenciesAreValid) {
                                        [mergeMapping setObject:[[NSNumber alloc] initWithInt:mainStateIndex] forKey:[[NSNumber alloc] initWithInt: stateIndex]];
                                    }
                                }
                            }
                        }
                    }
                }*/
            }
        }
        if (!sharedVarList) {
            [mainMDDSpecList addObject:mddSpec];
        }
    }
    
    ORDDClosureGenerator *closureVisitor = [[ORDDClosureGenerator alloc] init];
    ORDDMergeClosureGenerator *mergeClosureVisitor = [[ORDDMergeClosureGenerator alloc] init];
    for (id<ORMDDSpecs> mddSpec in mainMDDSpecList) {
        id<ORIntVarArray> vars = [mddSpec vars];
        id<ORExpr> arcExists = [mddSpec arcExists];
        DDClosure arcExistsClosure = [closureVisitor computeClosure:arcExists];
        int* stateValues = [mddSpec stateValues];
        id<ORExpr>* transitionFunctions = [mddSpec transitionFunctions];
        id<ORExpr>* relaxationFunctions = [mddSpec relaxationFunctions];
        id<ORExpr>* differentialFunctions = [mddSpec differentialFunctions];
        int stateSize = [mddSpec stateSize];
        DDClosure* transitionFunctionClosures = malloc(stateSize * sizeof(DDClosure));
        DDMergeClosure* differentialFunctionClosures = malloc(stateSize * sizeof(DDMergeClosure));
        for (int transitionFunctionIndex = 0; transitionFunctionIndex < stateSize; transitionFunctionIndex++) {
            transitionFunctionClosures[transitionFunctionIndex] = [closureVisitor computeClosure: transitionFunctions[transitionFunctionIndex]];
            differentialFunctionClosures[transitionFunctionIndex] = [mergeClosureVisitor computeClosure: differentialFunctions[transitionFunctionIndex]];
        }
        
        if (_relaxed) {
            DDMergeClosure* relaxationFunctionClosures = malloc(stateSize * sizeof(DDMergeClosure));
            for (int relaxationFunctionIndex = 0; relaxationFunctionIndex < stateSize; relaxationFunctionIndex++) {
                relaxationFunctionClosures[relaxationFunctionIndex] = [mergeClosureVisitor computeClosure: relaxationFunctions[relaxationFunctionIndex]];
            }
            [JointState addStateClass: [[MDDStateSpecification alloc] initClassState:[vars low] domainMax:[vars up] state:stateValues arcExists:arcExistsClosure transitionFunctions:transitionFunctionClosures relaxationFunctions:relaxationFunctionClosures differentialFunctions:differentialFunctionClosures stateSize:stateSize] withVariables:vars];
        } else {
            [JointState addStateClass:[[MDDStateSpecification alloc] initClassState:[vars low] domainMax:[vars up] state:stateValues arcExists:arcExistsClosure transitionFunctions:transitionFunctionClosures stateSize:stateSize] withVariables:vars];
        }
        if ([_variables count] == 0) {
            _variables = vars;
        } else {
            _variables = [ORFactory mergeIntVarArray:_variables with:vars tracker:_into];
        }
    }
}

-(void) visitMDDSpecs:(id<ORMDDSpecs>)cstr
{
    [_mddSpecConstraints addObject:cstr];
    
    /*
    ORDDClosureGenerator *closureVisitor = [[ORDDClosureGenerator alloc] init];
    id<ORIntVarArray> cstrVars = [cstr vars];
    id<ORExpr> arcExists = [cstr arcExists];
    DDClosure arcExistsClosure = [closureVisitor computeClosure:arcExists];
    int* stateValues = [cstr stateValues];
    id<ORExpr>* transitionFunctions = [cstr transitionFunctions];
    int stateSize = [cstr stateSize];
    DDClosure* transitionFunctionClosures = malloc(stateSize * sizeof(DDClosure));
    for (int transitionFunctionIndex = 0; transitionFunctionIndex < stateSize; transitionFunctionIndex++) {
        transitionFunctionClosures[transitionFunctionIndex] = [closureVisitor computeClosure: transitionFunctions[transitionFunctionIndex]];
    }
    [JointState addStateClass: [[MDDStateSpecification alloc] initClassState:[cstrVars low] domainMax:[cstrVars up] state:stateValues arcExists:arcExistsClosure transitionFunctions:transitionFunctionClosures stateSize:stateSize] withVariables:cstrVars];
     _variables = [ORFactory mergeIntVarArray:_variables with:cstrVars tracker:_into];
     */
}
-(void) visitAltMDDSpecs:(id<ORAltMDDSpecs>)cstr
{
    id<ORIntVarArray> cstrVars = [cstr vars];
    id topDownInfo = [cstr topDownInfo];
    id bottomUpInfo = [cstr bottomUpInfo];
    id<ORExpr> edgeDeletionCondition = [cstr edgeDeletionCondition];
    id<ORExpr> topDownInfoEdgeAddition = [cstr topDownInfoEdgeAddition];
    id<ORExpr> bottomUpInfoEdgeAddition = [cstr bottomUpInfoEdgeAddition];
    id<ORExpr> topDownInfoMerge = [cstr topDownInfoMerge];
    id<ORExpr> bottomUpInfoMerge = [cstr bottomUpInfoMerge];
    
    ORAltMDDParentChildEdgeClosureGenerator* parentChildEdgeClosureVisitor = [[ORAltMDDParentChildEdgeClosureGenerator alloc] init];
    ORAltMDDLeftRightClosureGenerator* leftRightClosureVisitor = [[ORAltMDDLeftRightClosureGenerator alloc] init];
    ORAltMDDParentEdgeClosureGenerator* parentEdgeClosureVisitor = [[ORAltMDDParentEdgeClosureGenerator alloc] init];
    
    AltMDDDeleteEdgeCheckClosure edgeDeletionClosure = [parentChildEdgeClosureVisitor computeClosure: edgeDeletionCondition];
    AltMDDAddEdgeClosure topDownInfoEdgeAdditionClosure = [parentEdgeClosureVisitor computeClosure: topDownInfoEdgeAddition];
    AltMDDAddEdgeClosure bottomUpInfoEdgeAdditionClosure = [parentEdgeClosureVisitor computeClosure: bottomUpInfoEdgeAddition];
    AltMDDMergeInfoClosure topDownMergeClosure = [leftRightClosureVisitor computeClosure: topDownInfoMerge];
    AltMDDMergeInfoClosure bottomUpMergeClosure = [leftRightClosureVisitor computeClosure: bottomUpInfoMerge];
    [AltJointState addStateClass: [[AltMDDStateSpecification alloc] initClassState:[cstrVars low] domainMax:[cstrVars up] topDownInfo:topDownInfo bottomUpInfo:bottomUpInfo topDownEdgeAddition:topDownInfoEdgeAdditionClosure bottomUpEdgeAddition:bottomUpInfoEdgeAdditionClosure topDownMerge:topDownMergeClosure bottomUpMerge:bottomUpMergeClosure edgeDeletion:edgeDeletionClosure] withVariables:cstrVars];
    if ([_variables count] == 0) {
        _variables= cstrVars;
    } else {
        //_variables = [ORFactory mergeIntVarArray:_variables with:cstrVars tracker:_into];
    }
}


-(void) visitAlldifferent:(id<ORAlldifferent>)cstr
{
    id<ORIntVarArray> cstrVars = (id<ORIntVarArray>)[cstr array];
    [_mddConstraints addObject: cstr];
    [JointState addStateClass: [[AllDifferentMDDState alloc] initClassState:[cstrVars low] domainMax:[cstrVars up]] withVariables:cstrVars];
    _variables = [ORFactory mergeIntVarArray:_variables with:cstrVars tracker: _into];
    [_into addConstraint: cstr];
    //for (int variableIndex = 1; variableIndex <= [variables count]; variableIndex++) {
    //    id<ORIntVar> variable = (id<ORIntVar>)[variables at: variableIndex];
    //    if (![_variables contains: variable]) {
    //        [_variables setObject:variable atIndexedSubscript:[_variables count]];
    //    }
    //}
}
-(void) visitKnapsack:(id<ORKnapsack>)cstr
{
    id<ORIntVarArray> cstrVars = (id<ORIntVarArray>)[cstr allVars];
    [_mddConstraints addObject: cstr];
    [JointState addStateClass: [[KnapsackBDDState alloc] initClassState:[cstrVars low]
                                                              domainMax: [cstrVars up]
                                                               capacity:[cstr capacity]
                                                                weights:[cstr weight]]
                withVariables:cstrVars]; //minDomain and maxDomain are poor names as shown here
    //why is capacity a variable for ORKnapsack?
    
    _variables = [ORFactory mergeIntVarArray:_variables with:cstrVars tracker: _into];
    [_into addConstraint: cstr];
}
-(void) visitAmong:(id<ORAmong>)cstr
{
    id<ORIntVarArray> cstrVars = (id<ORIntVarArray>)[cstr array];
    [_mddConstraints addObject:cstr];
    [JointState addStateClass: [[AmongMDDState alloc] initClassState:[cstrVars low]
                                                           domainMax: [cstrVars up]
                                                           setValues:[cstr values]
                                                          lowerBound:[cstr low]
                                                          upperBound:[cstr up]
                                                             numVars:(ORInt)[cstrVars count]]
                withVariables:cstrVars];
    _variables = [ORFactory mergeIntVarArray:_variables with:cstrVars tracker: _into];
    [_into addConstraint: cstr];
}
-(void) visitMinimizeVar: (id<ORObjectiveFunctionVar>) v
{
    [_into minimizeVar:[v var]];
    _objectiveVar = [v var];
    _maximize = false;
    _hasObjective = true;
}
-(void) visitMaximizeVar: (id<ORObjectiveFunctionVar>) v
{
    [_into maximizeVar:[v var]];
    _objectiveVar = [v var];
    _maximize = true;
    _hasObjective = true;
}
@end