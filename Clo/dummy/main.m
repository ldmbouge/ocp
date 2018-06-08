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



int MIN = 1;
int MAX = 200;
bool** adjacencies;

@interface CustomState : NSObject {
@protected
    int _variableIndex;
    int _minValue;
    int _maxValue;
    char* _stateChar;
}
-(id) initState:(int)variableIndex;
-(id) initState:(CustomState*)parentNodeState assigningVariable:(int)variableIndex withValue:(int)edgeValue;
-(id) state;
-(char*) stateChar;
-(int) variableIndex;
-(bool) canChooseValue:(int)value;
-(void) mergeStateWith:(CustomState*)other;
-(bool) stateAllows:(int)variable;

+(int*) getWeightsForVariable:(int)variable;
+(int) maxPossibleWeightForVariable:(int)variable;
@end

@implementation CustomState
-(id) initState:(int)variableIndex {
    _variableIndex = variableIndex;
    _minValue = MIN;
    _maxValue = MAX;
    _stateChar = malloc((_maxValue - _minValue +1) * sizeof(char));
    _stateChar -= _minValue;
    
    return self;
}
-(id) initState:(CustomState*)parentNodeState assigningVariable:(int)variableIndex withValue:(int)edgeValue {
    [self initState:variableIndex];

    return self;
}

-(id) state { return NULL; }
-(char*) stateChar { return _stateChar; }
-(int) variableIndex { return _variableIndex; }
-(bool) canChooseValue:(int)value {
    return true;
}
-(void) mergeStateWith:(CustomState *)other {
    return;
}
-(bool) stateAllows:(int)variable {
    return true;
}

+(int*) getWeightsForVariable:(int)variable {
    return NULL;
}
+(int) maxPossibleWeightForVariable:(int)variable {
    return 0;
}
@end




@interface CustomMISPState : CustomState {
 @private
 bool* _state;
 bool** _adjacencyMatrix;
 }
-(bool**) adjacencyMatrix;
 -(bool*) state;
 @end


@implementation CustomMISPState
-(id) initState:(int)variableIndex {
    [super initState:variableIndex];
    
    _adjacencyMatrix = adjacencies;
    _state = malloc((_maxValue - _minValue +1) * sizeof(bool));
    _state -= _minValue;
    for (int stateValue = _minValue; stateValue <= _maxValue; stateValue++) {
        _state[stateValue] = true;
        _stateChar[stateValue] = '1';
    }
    
    return self;
}
-(id) initState:(CustomMISPState*)parentNodeState assigningVariable:(int)variableIndex withValue:(int)edgeValue {
    [super initState:parentNodeState assigningVariable:variableIndex withValue:edgeValue];
    
    _adjacencyMatrix = adjacencies;
    _state = malloc((_maxValue - _minValue +1) * sizeof(bool));
    _state -= _minValue;
    bool* parentState = [parentNodeState state];
    int parentVariable = [parentNodeState variableIndex];
    bool* parentAdjacencies = _adjacencyMatrix[parentVariable];
    if (edgeValue == 1) {
        for (int stateIndex = _minValue; stateIndex <= _maxValue; stateIndex++) {
            _state[stateIndex] = !parentAdjacencies[stateIndex] && parentState[stateIndex];
            _stateChar[stateIndex] = _state[stateIndex] ? '1':'0';
        }
    }
    else {
        for (int stateIndex = _minValue; stateIndex <= _maxValue; stateIndex++) {
            _state[stateIndex] = parentState[stateIndex];
            _stateChar[stateIndex] = _state[stateIndex] ? '1':'0';
        }
    }
    _state[parentVariable] = false;
    _stateChar[parentVariable] = '0';
    
    return self;
}
-(bool**) adjacencyMatrix { return _adjacencyMatrix; }
-(bool*) state { return _state; }
-(bool) canChooseValue:(int)value {
    if (value == 0) return true;
    return _state[_variableIndex];
}
-(void) mergeStateWith:(CustomMISPState *)other {
    for (int value = _minValue; value <= _maxValue; value++) {
        bool combinedStateValue = [self canChooseValue: value] || [other canChooseValue:value];
        _state[value] = [NSNumber numberWithBool: combinedStateValue];
    }
}
-(bool) stateAllows:(int)variable {
    if (!_state[variable]) {
        return false;
    }
    return !_adjacencyMatrix[_variableIndex][variable];
}

+(int*) getWeightsForVariable:(int)variable {
    int* weights = malloc(2 * sizeof(int));
    weights[0] = 0;
    weights[1] = 1;
    return weights;
}
+(int) maxPossibleWeightForVariable:(int)variable {
    return 1;
}
@end





double DENSITY = .5;

bool** adjacencyMatrix (NSArray* *edges, bool directed) {
    bool** adjacencyMatrix;
    adjacencyMatrix = malloc((MAX-MIN+1) * sizeof(bool*));
    adjacencyMatrix -= MIN;
    
    for (int i = MIN; i <= MAX; i++) {
        adjacencyMatrix[i] = malloc((MAX-MIN+1) * sizeof(bool));
        adjacencyMatrix[i] -= MIN;
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
    int bit = MAX;
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
    
    bool* solution = malloc((MAX-MIN+1) * sizeof(bool));
    solution -= MIN;
    
    for (int variable = MIN; variable <= MAX; variable++) {
        solution[variable] = true;
    }
    
    int maxNumSelected = 0;
    int numSelected = MAX-MIN+1;
    
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
    adjacencyMatrix = malloc((MAX-MIN+1) * sizeof(bool*));
    adjacencyMatrix -= MIN;
    
    for (int i = MIN; i <= MAX; i++) {
        adjacencyMatrix[i] = malloc((MAX-MIN+1) * sizeof(bool));
        adjacencyMatrix[i] -= MIN;
    }
    
    for (int node1 = MIN; node1 < MAX; node1++) {
        for (int node2 = node1 + 1; node2 <= MAX; node2++) {
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
        id<ORIntRange> R1 = RANGE(mdl, MIN, MAX);
        id<ORIntRange> R2 = RANGE(mdl, 0, 1);
        id<ORIntVarArray> a = [ORFactory intVarArray: mdl range: R1 domain: R2];
        id<ORMutableInteger> nbSolutions = [ORFactory mutable: mdl value: 0];
        ORInt layerSize = 100;
        bool reduced = true;
        
        adjacencies = malloc((MAX-MIN+1) * sizeof(bool*));
        adjacencies -= MIN;
        
        for (int i = MIN; i <= MAX; i++) {
            adjacencies[i] = malloc((MAX-MIN+1) * sizeof(bool));
            adjacencies[i] -= MIN;
            for (int j = MIN; j <= MAX; j++) {
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
        
        Class stateClass = [CustomMISPState class];
        
        
        int maxSum = 0;
        for(int vertex = MIN; vertex <= MAX; vertex++) {
            maxSum += [stateClass maxPossibleWeightForVariable: vertex];
        }
        
        id<ORIntVar> totalWeight = [ORFactory intVar: mdl domain: RANGE(mdl, 0, maxSum)];
        
        
        //id<ORConstraint> mddConstraint = [ORFactory RelaxedMDDMISP:mdl var:a size:layerSize reduced:reduced adjacencies:adjacencies weights:weights objective:totalWeight];
        id<ORConstraint> mddConstraint = [ORFactory RelaxedCustomMDD:mdl var:a size:layerSize reduced:reduced objective:totalWeight maximize:true stateClass:[CustomMISPState class]];
        
        
        [mdl add: mddConstraint];
        
        [mdl maximize: totalWeight];
        
        id<CPProgram> cp = [ORFactory createCPProgram:mdl];
        
        [cp solve: ^{
            
            for (int variableIndex = MIN; variableIndex <= MAX; variableIndex++) {
                [cp label: a[variableIndex] with: [cp recommendationBy: mddConstraint forVariableIndex: variableIndex]];
            }
            
            for (int i = MIN; i <= MAX; i++) {
              printf("%d  ",[cp intValue: [a at:i]]);
            }
            //printf("  |  Objective value: %d", [cp intValue: totalWeight]);
            printf("\n");
            [nbSolutions incr: cp];
         }
        ];
        
        //findMISP(adjacencies, edgeA, edgeB);
        
        /*for (int a = MIN; a < MAX; a++) {
            for (int b = MIN; b < a; b++) {
                if (adjacencies[b][a]) {
                    printf("e %d %d\n", a, b);
                }
            }
        }*/

        printf("GOT %d solutions\n",[nbSolutions intValue:cp]);
        NSLog(@"Solver status: %@\n",cp);
        NSLog(@"Quitting");
    }

    return 0;
}
