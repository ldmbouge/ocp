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
#import <ORFoundation/ORFoundation.h>

@implementation ORFactory(MDD)
+(void) sortIntVarArray:(NSMutableArray*)array first:(ORInt)first last:(ORInt)last {
    ORInt i, j, pivot;
    id<ORIntVar> temp;
    
    if(first<last){
        pivot=first;
        i=first;
        j=last;
        
        while(i<j){
            while([[array objectAtIndex:i] getId]<=[[array objectAtIndex:pivot] getId]&&i<last)
                i++;
            while([[array objectAtIndex:j] getId]>[[array objectAtIndex:pivot] getId])
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
    
    for (int i = [x low]; i <= [x up]; i++) {
        [sortedX addObject: x[i]];
    }
    for (int i = [y low]; i <= [y up]; i++) {
        [sortedY addObject: y[i]];
    }
    [self sortIntVarArray:sortedX first:0 last:(ORInt)([x count] - 1)];
    [self sortIntVarArray:sortedY first:0 last:(ORInt)([y count] - 1)];
    
    ORInt xIndex = 0, yIndex = 0;
    
    while (xIndex < [x count] || yIndex < [y count]) {
        if (xIndex < [x count] && (yIndex >= [y count] || [sortedX[xIndex] getId] < [sortedY[yIndex] getId])) {
            [mergedTemp setObject:[sortedX objectAtIndex:xIndex] atIndexedSubscript:size];
            xIndex++;
            size++;
        } else if (xIndex >= [x count] || [sortedX[xIndex] getId] > [sortedY[yIndex] getId]) {
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
    [mergedTemp release];
    [sortedX release];
    [sortedY release];
    return merged;
}
@end

 
@implementation ORMDDify {
@protected
    id<ORAddToModel> _into;
    id<ORAnnotation> _notes;
    id<ORIntVarArray> _variables;
    
    bool _hasObjective;
    id<ORIntVar> _objectiveVar;
    bool _maximize;
    int _width;
    MDDRecommendationStyle _recommendationStyle;
    bool _splitAllLayersBeforeFiltering;
    int _maxSplitIter;
    int _maxRebootDistance;
    ORInt _variableOverlap;
    bool _useStateExistence;
    int _numNodesSplitAtATime;
    bool _numNodesDefinedAsPercent;
    int _splittingStyle;
    ORInt _numSpecs;
    
    NSMutableArray* _mddSpecConstraints;
    MDDStateSpecification* _mddSpecification;
}

-(id)initORMDDify: (id<ORAddToModel>) into
{
    self = [super init];
    _into = into;
    _mddSpecConstraints = [[NSMutableArray alloc] init];
    _variables = NULL;
    _maximize = false;
    _hasObjective = false;
    return self;
}
-(void) dealloc {
    [_mddSpecConstraints release];
    [_mddSpecification release];
    [super dealloc];
}

-(void) apply:(id<ORModel>) m with:(id<ORAnnotation>)notes {
    _notes = notes;
    _width = [_notes findGeneric: DDWidth];
    _recommendationStyle = [_notes findGeneric: DDRecommendationStyle];
    _splitAllLayersBeforeFiltering = [_notes findGeneric: DDSplitAllLayersBeforeFiltering];
    _maxSplitIter = [_notes findGeneric:DDMaxSplitIter];
    _maxRebootDistance = [_notes findGeneric:DDMaxRebootDistance];
    _variableOverlap = [_notes findGeneric: DDComposition];
    _useStateExistence = [_notes findGeneric: DDUseStateExistence];
    _numNodesSplitAtATime = [_notes findGeneric: DDNumNodesSplitAtATime];
    _numNodesDefinedAsPercent = [_notes findGeneric: DDNumNodesDefinedAsPercent];
    _splittingStyle = [_notes findGeneric: DDSplittingStyle];
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
        if ([c conformsToProtocol:@protocol(ORMDDSpecs)]) { //Should check if c is MDDifiable.  aka if it has a visit function down below
            [c visit: self];
        } else {
            [_into addConstraint:c];
        }
        [_into setCurrent:nil];
    }
      onObjective: ^(id<ORObjectiveFunction> o) {
          [o visit: self];
      }];
    
    if ([_mddSpecConstraints count] > 0) {
        if (_variableOverlap == 0) {
            [self combineMDDSpecs:m];
            id<ORConstraint> mddConstraint = [ORFactory MDDStateSpecification:m var:_variables size:_width specs:_mddSpecification recommendationStyle:_recommendationStyle splitAllLayersBeforeFiltering:_splitAllLayersBeforeFiltering maxSplitIter:_maxSplitIter maxRebootDistance:_maxRebootDistance useStateExistence:_useStateExistence numNodesSplitAtATime:_numNodesSplitAtATime numNodesDefinedAsPercent:_numNodesDefinedAsPercent splittingStyle:_splittingStyle];
            [_into trackConstraintInGroup: mddConstraint];
            [_into addConstraint: mddConstraint];
        } else {
            MDDStateSpecification** specs = [self createMDDSpecs:m];
            for (int i = 0; i < _numSpecs; i++) {
                MDDStateSpecification* spec = specs[i];
                id<ORConstraint> mddConstraint = [ORFactory MDDStateSpecification:m var:[spec vars] size:_width specs:spec recommendationStyle:_recommendationStyle splitAllLayersBeforeFiltering:_splitAllLayersBeforeFiltering maxSplitIter:_maxSplitIter maxRebootDistance:_maxRebootDistance useStateExistence:_useStateExistence numNodesSplitAtATime:_numNodesSplitAtATime numNodesDefinedAsPercent:_numNodesDefinedAsPercent splittingStyle:_splittingStyle];
                [_into trackConstraintInGroup: mddConstraint];
                [_into addConstraint: mddConstraint];
            }
        }
    }
}

-(id<ORAddToModel>)target { return _into; }

-(void) combineMDDSpecs:(id<ORModel>)m {
    id<ORMDDSpecs> firstSpec = [_mddSpecConstraints firstObject];
    NSMutableArray* MDDSpecsByVariableSet = [[NSMutableArray alloc] initWithObjects:firstSpec,nil];
    _variables = [firstSpec vars];
    int totalNumForwardProperties = [firstSpec numForwardProperties];
    int totalNumReverseProperties = [firstSpec numReverseProperties];
    int totalNumCombinedProperties = [firstSpec numCombinedProperties];

    //Combine specs with shared variable lists, obtain total variable list, and count total number of properties
    for (int mddSpecIndex = 1; mddSpecIndex < [_mddSpecConstraints count]; mddSpecIndex++) {
        id<ORMDDSpecs> mddSpec = [_mddSpecConstraints objectAtIndex:mddSpecIndex];
        id<ORIntVarArray> vars = [mddSpec vars];
        bool sharedVarList = false;
        for (id<ORMDDSpecs> existingMDDSpec in MDDSpecsByVariableSet) {
            if ([existingMDDSpec vars] == vars) {
                sharedVarList = true;
                [MDDSpecsByVariableSet addObject:mddSpec];;
                totalNumForwardProperties += [mddSpec numForwardProperties];
                totalNumReverseProperties += [mddSpec numReverseProperties];
                totalNumCombinedProperties += [mddSpec numCombinedProperties];
                break;
            }
        }
        if (!sharedVarList) {
            [MDDSpecsByVariableSet addObject:mddSpec];
            _variables = [ORFactory mergeIntVarArray:_variables with:vars tracker:_into];
            totalNumForwardProperties += [mddSpec numForwardProperties];
            totalNumReverseProperties += [mddSpec numReverseProperties];
            totalNumCombinedProperties += [mddSpec numCombinedProperties];
        } else {
            [mddSpec release];
        }
    }
    
    MDDStateSpecification* finalMDDSpec = [[MDDStateSpecification alloc] initMDDStateSpecification:(int)[MDDSpecsByVariableSet count] numForwardProperties:totalNumForwardProperties numReverseProperties:totalNumReverseProperties numCombinedProperties:totalNumCombinedProperties vars:_variables];
    for (id<ORMDDSpecs> mddSpec in MDDSpecsByVariableSet) {
        id<ORIntVarArray> vars = [mddSpec vars];
        int* variableMapping = [self findVariableMappingFrom:vars to:_variables];
        [finalMDDSpec addMDDSpec:mddSpec mapping:variableMapping];
        [mddSpec release];
    }
    [MDDSpecsByVariableSet release];
    _mddSpecification = finalMDDSpec;
    return;
}

-(MDDStateSpecification**) createMDDSpecs:(id<ORModel>)m {
    int numSpecs = (int)[_mddSpecConstraints count];
    MDDStateSpecification** stateSpecs = malloc(numSpecs * sizeof(MDDStateSpecification*));
    int mddSpecIndex = 0;
    bool* specUsed = calloc(numSpecs, sizeof(bool));
    for (int i = 0; i < numSpecs; i++) {
        if (specUsed[i]) continue;
        specUsed[i] = true;
        id<ORMDDSpecs> mddSpec = [_mddSpecConstraints objectAtIndex:i];
        id<ORIntVarArray> initialVars = [mddSpec vars];
        id<ORIntVarArray> totalVariables = initialVars;
        int minInitialVarIndex = [initialVars low];
        int maxInitialVarIndex = [initialVars up];
        int numInitialVars = (int)[initialVars count];
        int largestVarCount = numInitialVars;
        int totalNumForwardProperties = [mddSpec numForwardProperties];
        int totalNumReverseProperties = [mddSpec numReverseProperties];
        int totalNumCombinedProperties = [mddSpec numCombinedProperties];
        bool* notInIntersection = calloc(numInitialVars, sizeof(bool));
        NSMutableArray* specsToCombine = [[NSMutableArray alloc] initWithObjects:mddSpec, nil];
        for (int j = i+1; j < numSpecs; j++) {
            if (specUsed[j]) continue;
            id<ORMDDSpecs> otherMDDSpec = [_mddSpecConstraints objectAtIndex:j];
            id<ORIntVarArray> otherVars = [otherMDDSpec vars];
            int intersectionSize = 0;
            for (int varIndex = minInitialVarIndex; varIndex <= maxInitialVarIndex; varIndex++) {
                //If was already in the intersection
                if (!notInIntersection[varIndex]) {
                    //If still is, then increment intersectionSize.  Otherwise set it to not be in intersection
                    if ([otherVars contains:initialVars[varIndex]]) {
                        intersectionSize++;
                    } else {
                        //notInIntersection[varIndex] = true;
                    }
                }
            }
            //If at least composition% of variables are in the interesection, this spec should be merged.
            if (intersectionSize * 100 /largestVarCount >=  _variableOverlap) {
                specUsed[j] = true;
                [specsToCombine addObject:otherMDDSpec];
                totalNumForwardProperties += [otherMDDSpec numForwardProperties];
                totalNumReverseProperties += [otherMDDSpec numReverseProperties];
                totalNumCombinedProperties += [otherMDDSpec numCombinedProperties];
                totalVariables = [ORFactory mergeIntVarArray:totalVariables with:otherVars tracker:_into];
                largestVarCount = max(largestVarCount,(int)[otherVars count]);
            }
        }
        free(notInIntersection);
        MDDStateSpecification* combinedMDDSpec = [[MDDStateSpecification alloc] initMDDStateSpecification:(int)[specsToCombine count] numForwardProperties:totalNumForwardProperties numReverseProperties:totalNumReverseProperties numCombinedProperties:totalNumCombinedProperties vars:totalVariables];
        for (id<ORMDDSpecs> newMDDSpec in specsToCombine) {
            id<ORIntVarArray> vars = [newMDDSpec vars];
            int* variableMapping = [self findVariableMappingFrom:vars to:totalVariables];
            [combinedMDDSpec addMDDSpec:newMDDSpec mapping:variableMapping];
            [newMDDSpec release];
        }
        stateSpecs[mddSpecIndex++] = combinedMDDSpec;
        [specsToCombine release];
    }
    free(specUsed);
    _numSpecs = mddSpecIndex;
    return stateSpecs;
}

//Probably a better way to get this mapping (could keep track of mappings when the merged variable array is made and update them as you go - not sure if that'd be better or worse), but this should work fine for now
-(int*) findVariableMappingFrom:(id<ORIntVarArray>)fromArray to:(id<ORIntVarArray>)toArray {
    int* mapping = calloc([fromArray count], sizeof(int));
    mapping -= [fromArray low];
    for (int fromIndex = [fromArray low]; fromIndex <= [fromArray up]; fromIndex++) {
        id<ORIntVar> fromVar = [fromArray at:fromIndex];
        for (int toIndex = [toArray low]; toIndex <= [toArray up]; toIndex++) {
            if (fromVar == [toArray at:toIndex]) {
                mapping[fromIndex] = toIndex;
                break;
            }
        }
    }
    return mapping;
}

-(void) visitMDDSpecs:(id<ORMDDSpecs>)cstr {
    [_mddSpecConstraints addObject:[cstr retain]];
}
-(void) visitMinimizeVar: (id<ORObjectiveFunctionVar>) v {
    [_into minimizeVar:[v var]];
    _objectiveVar = [v var];
    _maximize = false;
    _hasObjective = true;
}
-(void) visitMaximizeVar: (id<ORObjectiveFunctionVar>) v {
    [_into maximizeVar:[v var]];
    _objectiveVar = [v var];
    _maximize = true;
    _hasObjective = true;
}
@end
