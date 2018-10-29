/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORProgram/ORProgram.h>
#import "ORCmdLineArgs.h"
#import <objcp/CPConstraint.h>
#import <ORFoundation/ORFoundation.h>
#import <ORSchedulingProgram/ORSchedulingProgram.h>



int MINVARIABLE = 1;
int MAXVARIABLE = 5;
int MINVALUE = 0;
int MAXVALUE = 1;

bool** adjacencies;
int* bddWeights;
int* bddValues;
int maxWeight;
int maxWeightNumDigits;

@interface CustomState : NSObject {
@protected
    int _variableIndex;
    char* _stateChar;
}
-(id) initState:(int)variableIndex;
-(id) initState:(CustomState*)parentNodeState assigningVariable:(int)variableIndex withValue:(int)edgeValue;
-(char*) stateChar;
-(int) variableIndex;
-(void) mergeStateWith:(CustomState*)other;
-(int) numPathsForVariable:(int)variable;

+(int*) getObjectiveValuesForVariable:(int)variable;
+(int) maxPossibleObjectiveValueForVariable:(int)variable;
@end

@implementation CustomState
-(id) initState:(int)variableIndex {
    return self;
}
-(id) initState:(CustomState*)parentNodeState assigningVariable:(int)variableIndex withValue:(int)edgeValue {
    return self;
}

-(char*) stateChar { return _stateChar; }
-(int) variableIndex { return _variableIndex; }
-(void) mergeStateWith:(CustomState *)other {
    return;
}
-(int) numPathsForVariable:(int)variable {
    int count = 0;
    for (int value = MINVALUE; value <= MAXVALUE; value++) {
        if ([self canChooseValue:value forVariable:variable]) {
            count++;
        }
    }
    return count;
}

-(bool) canChooseValue:(int)value forVariable:(int)variable {
    return true;
}
+(int*) getObjectiveValuesForVariable:(int)variable {
    return NULL;
}
+(int) maxPossibleObjectiveValueForVariable:(int)variable {
    int* objectiveValues = [self getObjectiveValuesForVariable:variable];
    int maxObjectiveValue = objectiveValues[MINVALUE];
    for (int value = MINVALUE + 1; value <= MAXVALUE; value++) {
        if (maxObjectiveValue < objectiveValues[value]) {
            maxObjectiveValue = objectiveValues[value];
        }
    }
    return maxObjectiveValue;
}
@end

@interface MDDState : NSObject {
@protected
    bool* _state;
}
-(bool*) state;
-(void) writeStateFromParent:(MDDState*)parent assigningValue:(int)value;
-(int) numPathsWithNextVariable:(int)variable;
-(NSArray*) tempAlterStateAssigningVariable:(int)variable value:(int)value toTestVariable:(int)toVariable;

+(void) undoChangesTo:(bool*)state with:(NSArray*)savedChanges;
-(bool) canChooseValue:(int)value forVariable:(int)variable;
@end

@interface CustomBDDState : CustomState {   //A state with a list of booleans corresponding to whether or not each variable can be assigned 1
@protected
    bool* _state;
}
-(bool*) state;
-(void) writeStateFromParent:(CustomBDDState*)parent assigningValue:(int)value;
-(int) numPathsWithNextVariable:(int)variable;
-(NSArray*) tempAlterStateAssigningVariable:(int)variable value:(int)value toTestVariable:(int)toVariable;

+(void) undoChangesTo:(bool*)state with:(NSArray*)savedChanges;
-(bool) canChooseValue:(int)value forVariable:(int)variable;
@end

@implementation CustomBDDState
-(id) initState:(int)variableIndex {
    _variableIndex = variableIndex;
    _state = malloc((MAXVARIABLE - MINVARIABLE +1) * sizeof(bool));
    _state -= MINVARIABLE;
    _stateChar = malloc((MAXVARIABLE - MINVARIABLE +1) * sizeof(char));
    _stateChar -= MINVARIABLE;
    for (int stateValue = MINVARIABLE; stateValue <= MAXVARIABLE; stateValue++) {
        _state[stateValue] = true;
        _stateChar[stateValue] = '1';
    }
    
    return self;
}
-(id) initState:(CustomBDDState*)parentNodeState assigningVariable:(int)variableIndex withValue:(int)edgeValue {    //Bad naming I think.  Parent is actually the one assigned that value, not the variableIndex
    _variableIndex = variableIndex;
    _state = malloc((MAXVARIABLE - MINVARIABLE +1) * sizeof(bool));
    _state -= MINVARIABLE;
    
    [self writeStateFromParent:parentNodeState assigningValue:edgeValue];
    
    return self;
}

-(bool*) state {
    return _state;
}

-(void) writeStateFromParent:(CustomBDDState*)parent assigningValue:(int)value {
    int variable = [parent variableIndex];
    _state[variable] = false;
    _stateChar[variable] = '0';
}
-(int) numPathsWithNextVariable:(int)variable {
    int count = 0;
    for (int fromValue = MINVALUE; fromValue <= MAXVALUE; fromValue++) {
        if ([self canChooseValue:fromValue forVariable:_variableIndex]) {
            NSArray* savedChanges = [self tempAlterStateAssigningVariable:_variableIndex value:fromValue toTestVariable:variable];
            for (int toValue = MINVALUE; toValue <= MAXVALUE; toValue++) {
                if ([self canChooseValue:toValue forVariable:variable]) {
                    count++;
                }
            }
            [[self class] undoChangesTo:_state with:savedChanges];
        }
    }
    return count;
}
-(NSArray*) tempAlterStateAssigningVariable:(int)variable value:(int)value toTestVariable:(int)toVariable {
    return [self tempAlterStateAssigningVariable:variable value:value];
}
-(NSArray*) tempAlterStateAssigningVariable:(int)variable value:(int)value {
    if (_state[variable] != value) {
        _state[variable] = value;
        return [[NSArray alloc] initWithObjects:[NSNumber numberWithInt: variable], nil];
    } else {
        return [[NSArray alloc] init];
    }
}

-(bool) canChooseValue:(int)value forVariable:(int)variable {
    if (value == 0) return true;
    return _state[variable];
}
+(void) undoChangesTo:(bool*)state with:(NSArray*)savedChanges {
    for (int index = 0; index < [savedChanges count]; index++) {
        state[[savedChanges[index] intValue]] = !(state[[savedChanges[index] intValue]]);
    }
}
@end

@interface CustomMISPState : CustomBDDState
@end


@implementation CustomMISPState
-(id) initState:(CustomState *)parentNodeState assigningVariable:(int)variableIndex withValue:(int)edgeValue {
    _stateChar = malloc((MAXVARIABLE - MINVARIABLE +1) * sizeof(char));
    _stateChar -= MINVARIABLE;
    return [super initState:parentNodeState assigningVariable:variableIndex withValue:edgeValue];
}

-(void) mergeStateWith:(CustomMISPState *)other {
    for (int variable = MINVARIABLE; variable <= MAXVARIABLE; variable++) {
        bool combinedStateValue = [self canChooseValue: 1 forVariable:variable] || [other canChooseValue: 1 forVariable:variable];
        _state[variable] = [NSNumber numberWithBool: combinedStateValue];
        _stateChar[variable] = _state[variable] ? '1' : '0';
    }
}
-(void) writeStateFromParent:(CustomMISPState*)parent assigningValue:(int)value {
    int variable = [parent variableIndex];
    bool* variableAdjacencies = adjacencies[variable];
    bool* parentState = [parent state];
    if (value == 1) {
        for (int stateIndex = MINVARIABLE; stateIndex <= MAXVARIABLE; stateIndex++) {
            _state[stateIndex] = !variableAdjacencies[stateIndex] && parentState[stateIndex];
            _stateChar[stateIndex] = _state[stateIndex] ? '1':'0';
        }
    }
    else {
        for (int stateIndex = MINVARIABLE; stateIndex <= MAXVARIABLE; stateIndex++) {
            _state[stateIndex] = parentState[stateIndex];
            _stateChar[stateIndex] = _state[stateIndex] ? '1':'0';
        }
    }
    [super writeStateFromParent:parent assigningValue:value];
}
-(NSArray*) tempAlterStateAssigningVariable:(int)variable value:(int)value toTestVariable:(int)toVariable {
    if (value == 1 && adjacencies[variable][toVariable]) {
        return [[NSArray alloc] initWithArray: [super tempAlterStateAssigningVariable:toVariable value:false]];
    } else {
        return [[NSArray alloc] init];
    }
}

+(int*) getObjectiveValuesForVariable:(int)variable {
    int* objectiveValue  = malloc(2 * sizeof(int));
    objectiveValue[0] = 0;
    objectiveValue[1] = 1;
    return objectiveValue;
}
@end


@interface WeightedCustomBDDState: CustomBDDState {
@protected
    int _objectiveValue;
}
-(int) objectiveValue;
@end

@implementation WeightedCustomBDDState
-(id) initState:(int)variableIndex {
    _state = malloc((MAXVARIABLE - MINVARIABLE +1) * sizeof(bool));
    _state -= MINVARIABLE;
    _stateChar = malloc((MAXVARIABLE - MINVARIABLE +1 + maxWeightNumDigits) * sizeof(char));
    _stateChar -= MINVARIABLE;
    for (int stateValue = MINVARIABLE; stateValue <= MAXVARIABLE; stateValue++) {
        _state[stateValue] = true;
        _stateChar[stateValue] = '1';
    }
    _objectiveValue = 0;
    for (int digit = 1; digit <= maxWeightNumDigits; digit++) {
        _stateChar[MAXVARIABLE + digit] = '0';
    }
    _variableIndex = variableIndex;
    return self;

}
-(id) initState:(WeightedCustomBDDState*)parentNodeState assigningVariable:(int)variableIndex withValue:(int)edgeValue {
    _variableIndex = variableIndex;
    _state = malloc((MAXVARIABLE - MINVARIABLE +1) * sizeof(bool));
    _state -= MINVARIABLE;
    _stateChar = malloc((MAXVARIABLE - MINVARIABLE+1 + maxWeightNumDigits) * sizeof(char));
    _stateChar -= MINVARIABLE;
    [self writeStateFromParent:parentNodeState assigningValue:edgeValue];
    
    return self;
}

-(int) objectiveValue {return _objectiveValue;}
+(int) getObjectiveValueForVariable:(int)variable {
    return bddValues[variable];
}
+(int*) getObjectiveValuesForVariable:(int)variable {
    int* objectiveValue = malloc(2 * sizeof(int));
    objectiveValue[0] = 0;
    objectiveValue[1] = [self getObjectiveValueForVariable:variable];
    return objectiveValue;
}
-(void) mergeStateWith:(WeightedCustomBDDState*)other {
    if (_objectiveValue < [other objectiveValue]) {
        _objectiveValue = [other objectiveValue];
        bool* otherState = [other state];
        for (int variable = MINVARIABLE; variable <= MAXVARIABLE; variable++) {
            _state[variable] = otherState[variable];
            _stateChar[variable] = _state[variable] ? '1' : '0';
        }
        for (int digit = 1; digit <= maxWeightNumDigits; digit++) {
            _stateChar[MAXVARIABLE + digit] = [other stateChar][MAXVARIABLE + digit];
        }
    }
}
-(NSArray*) tempAlterStateAssigningVariable:(int)variable value:(int)value toTestVariable:(int)toVariable {
    if (value == 1 && (_objectiveValue + [[self class] getObjectiveValueForVariable:variable] + [[self class] getObjectiveValueForVariable:toVariable]) > maxWeight ) {
        return [[NSArray alloc] initWithArray: [super tempAlterStateAssigningVariable:toVariable value:false]];
    } else {
        return [[NSArray alloc] init];
    }
}
@end

@interface CustomKnapsackState : WeightedCustomBDDState {
@protected
    int _weightValue;
}
-(int) weightValue;
@end

@implementation CustomKnapsackState
-(id) initState:(int)variableIndex {
    _weightValue = 0;
    return [super initState: variableIndex];
}
-(id) initState:(WeightedCustomBDDState*)parentNodeState assigningVariable:(int)variableIndex withValue:(int)edgeValue {
    _weightValue = 0;
    return [super initState: parentNodeState assigningVariable:variableIndex withValue:edgeValue];
}
-(int) weightValue { return _weightValue; }
-(void) writeStateFromParent:(CustomKnapsackState*)parent assigningValue:(int)value {
    int variable = [parent variableIndex];
    bool* parentState = [parent state];
    if (value == 1) {
        _objectiveValue = [parent objectiveValue] + [[self class] getObjectiveValueForVariable:variable];
        _weightValue = [parent weightValue] + [[self class] getWeightForVariable:variable];
        for (int stateIndex = MINVARIABLE; stateIndex <= MAXVARIABLE; stateIndex++) {
            _state[stateIndex] = parentState[stateIndex] && ((_weightValue + [[self class] getWeightForVariable:stateIndex]) <= maxWeight);
            _stateChar[stateIndex] = _state[stateIndex] ? '1':'0';
        }
        for (int digit = 1; digit <= maxWeightNumDigits; digit++) {
            _stateChar[MAXVARIABLE+ 1 + (maxWeightNumDigits - digit)] = (char)((int)(_objectiveValue/pow(10,digit-1)) % 10 + (int)'0');
            
        }
    }
    else {
        _objectiveValue = [parent objectiveValue];
        _weightValue = [parent weightValue];
        for (int stateIndex = MINVARIABLE; stateIndex <= MAXVARIABLE; stateIndex++) {
            _state[stateIndex] = parentState[stateIndex];
            _stateChar[stateIndex] = _state[stateIndex] ? '1':'0';
        }
        for (int digit = 1; digit <= maxWeightNumDigits; digit++) {
            _stateChar[MAXVARIABLE + digit] = [parent stateChar][MAXVARIABLE + digit];
        }
    }
    _state[variable] = false;
    _stateChar[variable] = '0';
}
-(NSArray*) tempAlterStateAssigningVariable:(int)variable value:(int)value toTestVariable:(int)toVariable {
    if (value == 1 && (_weightValue + [[self class] getWeightForVariable:variable] + [[self class] getWeightForVariable:toVariable]) > maxWeight ) {
        return [[NSArray alloc] initWithArray: [super tempAlterStateAssigningVariable:toVariable value:false]];
    } else {
        return [[NSArray alloc] init];
    }
}
-(void) mergeStateWith:(CustomKnapsackState*)other {
    if (_weightValue < [other weightValue]) {
        _objectiveValue = [other objectiveValue];
        _weightValue = [other weightValue];
        bool* otherState = [other state];
        for (int variable = MINVARIABLE; variable <= MAXVARIABLE; variable++) {
            _state[variable] = otherState[variable];
            _stateChar[variable] = _state[variable] ? '1' : '0';
        }
        for (int digit = 1; digit <= maxWeightNumDigits; digit++) {
            _stateChar[MAXVARIABLE + digit] = [other stateChar][MAXVARIABLE + digit];
        }
    }
}
+(int) getWeightForVariable:(int)variable {
    return bddWeights[variable];
}
+(int*) getWeightsForVariable:(int)variable {
    int* values = malloc(2 * sizeof(int));
    values[0] = 0;
    values[1] = [self getWeightForVariable:variable];
    return values;
}
@end

@interface CustomStateConjunction : CustomState {
@protected
    CustomKnapsackState* _state1;
    CustomMISPState* _state2;
}
-(id) state1;
-(id) state2;
@end

@implementation CustomStateConjunction
-(id) initState:(int)variableIndex {
    [_state1 initState:variableIndex];
    [_state2 initState:variableIndex];
        
    return self;
}
-(id) initState:(CustomState*)parentNodeState assigningVariable:(int)variableIndex withValue:(int)edgeValue {
    [_state1 initState:parentNodeState assigningVariable:variableIndex withValue:edgeValue];
    [_state2 initState:parentNodeState assigningVariable:variableIndex withValue:edgeValue];
    
    return self;
}

-(id) state1 { return _state1; }
-(id) state2 { return _state2; }

-(char*) stateChar {
    char* state1Char = [_state1 stateChar];
    char* state2Char = [_state2 stateChar];
    char* newStateChar = (char *) malloc(1 + strlen(state1Char) + strlen(state2Char));
    strcpy(newStateChar, state1Char);
    strcat(newStateChar, state2Char);
    return newStateChar;
}
-(int) variableIndex { return [_state1 variableIndex]; }
-(void) mergeStateWith:(CustomStateConjunction *)other {
    [_state1 mergeStateWith: [other state1]];
    [_state2 mergeStateWith: [other state2]];
}
-(int) numPathsForVariable:(int)variable {
    int count = 0;
    for (int value = MINVALUE; value <= MAXVALUE; value++) {
        if ([self canChooseValue:value forVariable:variable]) {
            count++;
        }
    }
    return count;
}

-(bool) canChooseValue:(int)value forVariable:(int)variable {
    return [_state1 canChooseValue:value forVariable:variable] && [_state2 canChooseValue:value forVariable:variable];
}

//Unsure what to do for this.  Two objective values
+(int*) getObjectiveValuesForVariable:(int)variable {
    return [CustomKnapsackState getObjectiveValuesForVariable:variable];
}
+(int) maxPossibleObjectiveValueForVariable:(int)variable {
    return max([CustomKnapsackState maxPossibleObjectiveValueForVariable:variable], [CustomMISPState maxPossibleObjectiveValueForVariable:variable]);
}
@end

double DENSITY = .5;

bool** adjacencyMatrix (NSArray* *edges, bool directed) {
    bool** adjacencyMatrix;
    adjacencyMatrix = malloc((MAXVARIABLE-MINVARIABLE+1) * sizeof(bool*));
    adjacencyMatrix -= MINVARIABLE;
    
    for (int i = MINVARIABLE; i <= MAXVARIABLE; i++) {
        adjacencyMatrix[i] = malloc((MAXVARIABLE-MINVARIABLE+1) * sizeof(bool));
        adjacencyMatrix[i] -= MINVARIABLE;
    }
    
    for (NSArray* edge in *edges) {
        adjacencyMatrix[[[edge objectAtIndex:0] integerValue]][[[edge objectAtIndex:1] integerValue]] = true;
        if (!directed) {
            adjacencyMatrix[[[edge objectAtIndex:1] integerValue]][[[edge objectAtIndex:0] integerValue]] = true;
        }
    }
    return adjacencyMatrix;
}

void decrementSolution(bool* solution, int* numSelected) {
    int bit = MAXVARIABLE;
    if (*numSelected == 0) {
        return;
    }
    while (true) {
        if (solution[bit]) {
            solution[bit] = false;
            numSelected[0] = numSelected[0]-1;
            return;
        } else {
            solution[bit] = true;
            numSelected[0] = numSelected[0]+1;
            bit--;
        }
    }
}

void findMISP(bool** adjacencies, NSMutableArray* edgeA, NSMutableArray* edgeB) {
    printf("Verifying answer...\n");
    
    bool* solution = malloc((MAXVARIABLE-MINVARIABLE+1) * sizeof(bool));
    solution -= MINVARIABLE;
    
    for (int variable = MINVARIABLE; variable <= MAXVARIABLE; variable++) {
        solution[variable] = true;
    }
    
    int maxNumSelected = 0;
    int numSelected = MAXVARIABLE-MINVARIABLE+1;
    
    while (numSelected != 0) {
        decrementSolution(solution, &numSelected);
        if (numSelected > maxNumSelected) {
            bool quit = false;
            for (int edgeIndex = 0; edgeIndex < [edgeA count]; edgeIndex++) {
                int pointA = [[edgeA objectAtIndex: edgeIndex] intValue];
                int pointB = [[edgeB objectAtIndex: edgeIndex] intValue];
                if (solution[pointA] && solution[pointB]) {
                    if (pointA > pointB) {
                        solution[pointA] = false;
                        numSelected--;
                    } else {
                        solution[pointB] = false;
                        numSelected--;
                    }
                    
                    if (numSelected <= maxNumSelected) {
                        quit = true;
                    }
                }
            }
            if (!quit) {
                maxNumSelected = numSelected;
                printf("Possible solution: %d\n", maxNumSelected);
            }
        }
    }
    printf("Actual best value: %d\n", maxNumSelected);
}

bool** randomAdjacencyMatrix() {
    bool** adjacencyMatrix;
    adjacencyMatrix = malloc((MAXVARIABLE-MINVARIABLE+1) * sizeof(bool*));
    adjacencyMatrix -= MINVARIABLE;
    
    for (int i = MINVARIABLE; i <= MAXVARIABLE; i++) {
        adjacencyMatrix[i] = malloc((MAXVARIABLE-MINVARIABLE+1) * sizeof(bool));
        adjacencyMatrix[i] -= MINVARIABLE;
    }
    
    for (int node1 = MINVARIABLE; node1 < MAXVARIABLE; node1++) {
        for (int node2 = node1 + 1; node2 <= MAXVARIABLE; node2++) {
            if (arc4random_uniform(10) < DENSITY*10) {
                adjacencyMatrix[node1][node2] = true;
                adjacencyMatrix[node2][node1] = true;
            }
        }
    }
    return adjacencyMatrix;
}

int main (int argc, const char * argv[])
{
    @autoreleasepool {
        
        id<ORModel> mdl = [ORFactory createModel];
        id<ORIntRange> R1 = RANGE(mdl, MINVARIABLE, MAXVARIABLE);
        id<ORIntRange> R2 = RANGE(mdl, 0, 1);
        id<ORIntVarArray> a = [ORFactory intVarArray: mdl range: R1 domain: R2];
        id<ORMutableInteger> nbSolutions = [ORFactory mutable: mdl value: 0];
        ORInt layerSize = 1000;
        bool reduced = true;
        
        
        //MISP
        /*Class stateClass1 = [CustomMISPState class];
        adjacencies = malloc((MAXVARIABLE-MINVARIABLE+1) * sizeof(bool*));
        adjacencies -= MINVARIABLE;
        
        for (int i = MINVARIABLE; i <= MAXVARIABLE; i++) {
            adjacencies[i] = malloc((MAXVARIABLE-MINVARIABLE+1) * sizeof(bool));
            adjacencies[i] -= MINVARIABLE;
            for (int j = MINVARIABLE; j <= MAXVARIABLE; j++) {
                adjacencies[i][j] = false;
            }
        }
        
        NSMutableArray *edgeA = [[NSMutableArray alloc] init];
        NSMutableArray *edgeB = [[NSMutableArray alloc] init];
        
        NSString *filepath = @"/Users/ben/Downloads/DIMACS_cliques/brock200_1.clq";
        
        FILE *file = fopen([filepath UTF8String], "r");
        char buffer[256];
        while(fgets(buffer, sizeof(char)*256,file) != NULL) {
            NSString* line = [NSString stringWithUTF8String:buffer];
            if([line characterAtIndex:0] == 'e') {
                line = [line substringFromIndex:2];
                NSNumber *first = [NSNumber numberWithLong: [[line substringToIndex: [line rangeOfString:@" "].location] integerValue]];
                line = [line substringFromIndex:[line rangeOfString:@" "].location];
                NSNumber *second = [NSNumber numberWithLong: [line integerValue]];
                
                adjacencies[[first intValue]][[second intValue]] = true;
                adjacencies[[second intValue]][[first intValue]] = true;
                [edgeA addObject: first];
                [edgeB addObject: second];
            }
        }
        int MISPmaxSum = 0;
        for(int vertex = MINVARIABLE; vertex <= MAXVARIABLE; vertex++) {
            MISPmaxSum += [stateClass1 maxPossibleObjectiveValueForVariable: vertex];
        }
        id<ORIntVar> MISPObjective = [ORFactory intVar: mdl domain: RANGE(mdl, 0, MISPmaxSum)];*/
        //END MISP
        
        
        
        //KNAPSACK
        /*Class stateClass2 = [CustomKnapsackState class];
        maxWeight = 100;
        bddWeights = malloc((MAXVARIABLE-MINVARIABLE+1) * sizeof(int));
        bddWeights -= MINVARIABLE;
        for (int variableIndex = MINVARIABLE; variableIndex <= MAXVARIABLE; variableIndex++) {
            bddWeights[variableIndex] = 1 + arc4random() % 40;
        }
        bddValues = malloc((MAXVARIABLE-MINVARIABLE+1) * sizeof(int));
        bddValues -= MINVARIABLE;
        for (int variableIndex = MINVARIABLE; variableIndex <= MAXVARIABLE; variableIndex++) {
            bddValues[variableIndex] = 1 + arc4random() % 40;
        }
        
        maxWeightNumDigits = 0;
        int tempMaxWeight = maxWeight;
        while (tempMaxWeight > 0) {
            maxWeightNumDigits++;
            tempMaxWeight/=10;
        }
        int knapsackMaxSum = 0;
        for(int vertex = MINVARIABLE; vertex <= MAXVARIABLE; vertex++) {
            knapsackMaxSum += [stateClass2 maxPossibleObjectiveValueForVariable: vertex];
        }
        id<ORIntVar> knapsackObjective = [ORFactory intVar: mdl domain: RANGE(mdl, 0, knapsackMaxSum)];*/
        //END KNAPSACK
        
        
        //Class stateClassConjunction = [CustomStateConjunction class];
        
        
        //id<ORConstraint> mddConstraint = [ORFactory RelaxedCustomMDD:mdl var:a size:layerSize reduced:reduced objective:knapsackObjective maximize:true stateClass:stateClassConjunction];
        
        //id<ORConstraint> mddConstraint = [ORFactory RelaxedMDDMISP:mdl var:a size:layerSize reduced:reduced adjacencies:adjacencies weights:weights objective:totalWeight];
        
        //[mdl add: mddConstraint];
        //[mdl maximize: knapsackObjective];
        //[mdl maximize: MISPObjective];
        
        id<ORIntVarArray> x  = [ORFactory intVarArray:mdl range:R1 domain: R1];
        
        [mdl add: [ORFactory alldifferent:x]];
        [mdl maximize: [x at: 1]];
        
        id<CPProgram> cp = [ORFactory createCPMDDProgram:mdl];
        
        [cp solve: ^{
            
            [cp labelArray:x];
            //for (int variableIndex = MINVARIABLE; variableIndex <= MAXVARIABLE; variableIndex++) {
            //    [cp label: a[variableIndex] with: [cp recommendationBy: mddConstraint forVariableIndex: variableIndex]];
            //}
            
            for (int i = MINVARIABLE; i <= MAXVARIABLE; i++) {
                printf("%d  ",[cp intValue: [x at:i]]);
            }
            //printf("  |  Objective value: %d", [cp intValue: totalWeight]);
            printf("\n");
            [nbSolutions incr: cp];
         }
        ];
        
        //findMISP(adjacencies, edgeA, edgeB);
        
        /*for (int a = MINVARIABLE; a < MAXVARIABLE; a++) {
            for (int b = MINVARIABLE; b < a; b++) {
                if (adjacencies[b][a]) {
                    printf("e %d %d\n", a, b);
                }
            }
        }*/
        
        /*for (int a = MINVARIABLE; a <= MAXVARIABLE; a++) {
            printf("%d\n", bddWeights[a]);
        }*/

        printf("GOT %d solutions\n",[nbSolutions intValue:cp]);
        NSLog(@"Solver status: %@\n",cp);
        NSLog(@"Quitting");
    }

    return 0;
}
