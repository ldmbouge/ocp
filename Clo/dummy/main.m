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
        id<ORAnnotation> notes= [ORFactory annotation];
        //id<ORIntRange> R1 = RANGE(mdl, MINVARIABLE, MAXVARIABLE);
        id<ORIntRange> R2 = RANGE(mdl, 0, 1);
        id<ORMutableInteger> nbSolutions = [ORFactory mutable: mdl value: 0];
        
        
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
        
        
        
        
        //ALLDIFFERENT
/*        id<ORIntVarArray> x  = [ORFactory intVarArray:mdl range:R1 domain: R1];
        id<ORIntVarArray> y  = [ORFactory intVarArray:mdl range:R1 domain: R1];
        id<ORIntVarArray> z  = [ORFactory intVarArray: mdl range: RANGE(mdl, 1, 5)
                                                 with: ^id<ORIntVar>(ORInt i) {
                                                     if (i < 4) { return [x at: i]; }
                                                     else { return [y at: i - 1]; }
                                                 }];
  */
        //[mdl add: [ORFactory alldifferent:x]];
        //[mdl add: [ORFactory alldifferent:y]];
        //[mdl add: [ORFactory alldifferent:z]];
        //[mdl maximize: [x at: 1]];

        //AMONG
        /*NSSet* s1 = [NSSet setWithObjects:@1,@2,@3, nil];
        id<ORIntSet> set1 = [ORFactory intSet: mdl set: s1];
        [mdl add: [ORFactory among: x values: set1 low: 3 up: 4]];
        NSSet* s2 = [NSSet setWithObjects:@1,@2, nil];
        id<ORIntSet> set2 = [ORFactory intSet: mdl set: s2];
        [mdl add: [ORFactory among: x values: set2 low: 2 up: 3]];
        */
        
        
        //Multiple Amongs
        /*int numConstraints = 10;
        
        NSSet* value1 = [NSSet setWithObjects:@1, nil];
        id<ORIntSet> setOne = [ORFactory intSet: mdl set: value1];
        
        id<ORIntVarArray> variables = [ORFactory intVarArray:mdl range: RANGE(mdl, 1, 50) domain: R2];
        
        NSString* fileContents = [NSString stringWithContentsOfFile:@"/Users/ben/objcp-private/Clo/dummy/AmongConstraintVariables.txt" encoding:NSUTF8StringEncoding error:nil];
        NSArray* allLines = [fileContents componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        NSMutableArray* lines = [[NSMutableArray alloc] init];
        
        for (int constraintNum = 0; constraintNum < numConstraints; constraintNum++) {
            NSString* line = [allLines objectAtIndex:constraintNum];
            NSArray* variableArray = [line componentsSeparatedByCharactersInSet:[NSCharacterSet
                                                                                 characterSetWithCharactersInString:@" "]];
            [lines setObject:variableArray atIndexedSubscript:constraintNum];
            
            id<ORIntVarArray> variableSubset = [ORFactory intVarArray:mdl range: RANGE(mdl, 1, 5) with: ^id<ORIntVar>(ORInt i) { return [variables at: ([[[lines objectAtIndex:constraintNum] objectAtIndex:i-1] intValue])];}];
            [mdl add: [ORFactory among: variableSubset values: setOne low: 2 up: 3]];
        }*/
        
        id<ORIntVarArray> variables = [ORFactory intVarArray:mdl range: RANGE(mdl, 1, 50) domain: RANGE(mdl, 1, 5)];
        NSSet* even = [NSSet setWithObjects:@2, @4, nil];
        NSSet* five = [NSSet setWithObjects:@5, nil];
        NSSet* middle = [NSSet setWithObjects:@2, @3, @4, nil];
        NSSet* ends = [NSSet setWithObjects:@1, @5, nil];
        NSSet* onetwo = [NSSet setWithObjects:@1, @2, nil];
        id<ORIntSet> countedValues1 = [ORFactory intSet: mdl set: even];
        id<ORIntSet> countedValues2 = [ORFactory intSet: mdl set: five];
        id<ORIntSet> countedValues3 = [ORFactory intSet: mdl set: middle];
        id<ORIntSet> countedValues4 = [ORFactory intSet: mdl set: ends];
        id<ORIntSet> countedValues5 = [ORFactory intSet: mdl set: onetwo];
        id<ORInteger> lower1 = [ORFactory integer:mdl value:5];
        id<ORInteger> upper1 = [ORFactory integer:mdl value:10];
        id<ORInteger> lower2 = [ORFactory integer:mdl value:2];
        id<ORInteger> upper2 = [ORFactory integer:mdl value:3];
        id<ORInteger> lower3 = [ORFactory integer:mdl value:30];
        id<ORInteger> upper3 = [ORFactory integer:mdl value:40];
        id<ORInteger> lower4 = [ORFactory integer:mdl value:5];
        id<ORInteger> upper4 = [ORFactory integer:mdl value:15];
        id<ORInteger> lower5 = [ORFactory integer:mdl value:11];
        id<ORInteger> upper5 = [ORFactory integer:mdl value:12];
        
        
        /*
        id<ORConstraint> among1 = [ORFactory among:variables values:countedValues1 low:[lower1 value] up:[upper1 value]];
        id<ORConstraint> among2 = [ORFactory among:variables values:countedValues2 low:[lower2 value] up:[upper2 value]];
        id<ORConstraint> among3 = [ORFactory among:variables values:countedValues3 low:[lower3 value] up:[upper3 value]];
        id<ORConstraint> among4 = [ORFactory among:variables values:countedValues4 low:[lower4 value] up:[upper4 value]];
        id<ORConstraint> among5 = [ORFactory among:variables values:countedValues5 low:[lower5 value] up:[upper5 value]];
        
        [mdl add: among1];
        [mdl add: among2];
        [mdl add: among3];
        [mdl add: among4];
        [mdl add: among5];
        */
        
        
        
        typedef enum {
            count,
            remaining
        } AmongState;
        
        id<ORMDDSpecs> mddStateSpecs = [ORFactory MDDSpecs: mdl variables:variables stateSize: 2];
        [mddStateSpecs addStateInt: count withDefaultValue: 0];
        [mddStateSpecs addStateInt: remaining withDefaultValue: 50];
        
        //(count + (assignedValue in countedValues)) <= upper && (count + (assignedValue in countedValues) + (remaining-1)) >= lower
        id<ORExpr> arcExists = [[[ORFactory expr: [ORFactory getStateValue: count] plus: [countedValues1 contains:[ORFactory valueAssignment]] track:mdl] leq: upper1 track:mdl]
                                land:
                                [[[ORFactory expr: [ORFactory getStateValue: count] plus: [countedValues1 contains:[ORFactory valueAssignment]] track:mdl] plus: [[ORFactory getStateValue: remaining] sub: @1 track: mdl] track: mdl] geq: lower1 track: mdl] track: mdl];
        
        [mddStateSpecs setArcExistsFunction: arcExists];
        
        //self["count"] = parent["count"] + (parentValue in countedValues)
        id<ORExpr> countTransitionFunction = [[ORFactory getStateValue: count] plus: [countedValues1 contains:[ORFactory valueAssignment]] track: mdl];
        //self["remaining"] = parent["remaining"] - 1
        id<ORExpr> remainingTransitionFunction = [[ORFactory getStateValue: remaining] sub: @1 track: mdl];
        [mddStateSpecs addTransitionFunction: countTransitionFunction toStateValue: count];
        [mddStateSpecs addTransitionFunction: remainingTransitionFunction toStateValue: remaining];
        
        [mdl add: mddStateSpecs];
        
        
        id<ORMDDSpecs> mddStateSpecs2 = [ORFactory MDDSpecs: mdl variables:variables stateSize:2];
        [mddStateSpecs2 addStateInt: count withDefaultValue: 0];
        [mddStateSpecs2 addStateInt: remaining withDefaultValue: 50];
        id<ORExpr> arcExists2 = [[[ORFactory expr: [ORFactory getStateValue: count] plus: [countedValues2 contains:[ORFactory valueAssignment]] track:mdl] leq: upper2 track:mdl]
                                land:
                                [[[ORFactory expr: [ORFactory getStateValue: count] plus: [countedValues2 contains:[ORFactory valueAssignment]] track:mdl] plus: [[ORFactory getStateValue: remaining] sub: @1 track: mdl] track: mdl] geq: lower2 track: mdl] track: mdl];
        [mddStateSpecs2 setArcExistsFunction: arcExists2];
        id<ORExpr> countTransitionFunction2 = [[ORFactory getStateValue: count] plus: [countedValues2 contains:[ORFactory valueAssignment]] track: mdl];
        id<ORExpr> remainingTransitionFunction2 = [[ORFactory getStateValue: remaining] sub: @1 track: mdl];
        [mddStateSpecs2 addTransitionFunction: countTransitionFunction2 toStateValue: count];
        [mddStateSpecs2 addTransitionFunction: remainingTransitionFunction2 toStateValue: remaining];
        [mdl add: mddStateSpecs2];
        
        
        id<ORMDDSpecs> mddStateSpecs3 = [ORFactory MDDSpecs: mdl variables:variables stateSize:2];
        [mddStateSpecs3 addStateInt: count withDefaultValue: 0];
        [mddStateSpecs3 addStateInt: remaining withDefaultValue: 50];
        id<ORExpr> arcExists3 = [[[ORFactory expr: [ORFactory getStateValue: count] plus: [countedValues3 contains:[ORFactory valueAssignment]] track:mdl] leq: upper3 track:mdl]
                                 land:
                                 [[[ORFactory expr: [ORFactory getStateValue: count] plus: [countedValues3 contains:[ORFactory valueAssignment]] track:mdl] plus: [[ORFactory getStateValue: remaining] sub: @1 track: mdl] track: mdl] geq: lower3 track: mdl] track: mdl];
        [mddStateSpecs3 setArcExistsFunction: arcExists3];
        id<ORExpr> countTransitionFunction3 = [[ORFactory getStateValue: count] plus: [countedValues3 contains:[ORFactory valueAssignment]] track: mdl];
        id<ORExpr> remainingTransitionFunction3 = [[ORFactory getStateValue: remaining] sub: @1 track: mdl];
        [mddStateSpecs3 addTransitionFunction: countTransitionFunction3 toStateValue: count];
        [mddStateSpecs3 addTransitionFunction: remainingTransitionFunction3 toStateValue: remaining];
        [mdl add: mddStateSpecs3];
        
        
        id<ORMDDSpecs> mddStateSpecs4 = [ORFactory MDDSpecs: mdl variables:variables stateSize:2];
        [mddStateSpecs4 addStateInt: count withDefaultValue: 0];
        [mddStateSpecs4 addStateInt: remaining withDefaultValue: 50];
        id<ORExpr> arcExists4 = [[[ORFactory expr: [ORFactory getStateValue: count] plus: [countedValues4 contains:[ORFactory valueAssignment]] track:mdl] leq: upper4 track:mdl]
                                 land:
                                 [[[ORFactory expr: [ORFactory getStateValue: count] plus: [countedValues4 contains:[ORFactory valueAssignment]] track:mdl] plus: [[ORFactory getStateValue: remaining] sub: @1 track: mdl] track: mdl] geq: lower4 track: mdl] track: mdl];
        [mddStateSpecs4 setArcExistsFunction: arcExists4];
        id<ORExpr> countTransitionFunction4 = [[ORFactory getStateValue: count] plus: [countedValues4 contains:[ORFactory valueAssignment]] track: mdl];
        id<ORExpr> remainingTransitionFunction4 = [[ORFactory getStateValue: remaining] sub: @1 track: mdl];
        [mddStateSpecs4 addTransitionFunction: countTransitionFunction4 toStateValue: count];
        [mddStateSpecs4 addTransitionFunction: remainingTransitionFunction4 toStateValue: remaining];
        [mdl add: mddStateSpecs4];
        
        
        id<ORMDDSpecs> mddStateSpecs5 = [ORFactory MDDSpecs: mdl variables:variables stateSize:2];
        [mddStateSpecs5 addStateInt: count withDefaultValue: 0];
        [mddStateSpecs5 addStateInt: remaining withDefaultValue: 50];
        id<ORExpr> arcExists5 = [[[ORFactory expr: [ORFactory getStateValue: count] plus: [countedValues5 contains:[ORFactory valueAssignment]] track:mdl] leq: upper5 track:mdl]
                                 land:
                                 [[[ORFactory expr: [ORFactory getStateValue: count] plus: [countedValues5 contains:[ORFactory valueAssignment]] track:mdl] plus: [[ORFactory getStateValue: remaining] sub: @1 track: mdl] track: mdl] geq: lower5 track: mdl] track: mdl];
        [mddStateSpecs5 setArcExistsFunction: arcExists5];
        id<ORExpr> countTransitionFunction5 = [[ORFactory getStateValue: count] plus: [countedValues5 contains:[ORFactory valueAssignment]] track: mdl];
        id<ORExpr> remainingTransitionFunction5 = [[ORFactory getStateValue: remaining] sub: @1 track: mdl];
        [mddStateSpecs5 addTransitionFunction: countTransitionFunction5 toStateValue: count];
        [mddStateSpecs5 addTransitionFunction: remainingTransitionFunction5 toStateValue: remaining];
        [mdl add: mddStateSpecs5];
        
        ORLong startWC  = [ORRuntimeMonitor wctime];
        ORLong startCPU = [ORRuntimeMonitor cputime];
        
        [notes ddWidth: 8];
        [notes ddRelaxed: false];
        id<CPProgram> cp = [ORFactory createCPMDDProgram:mdl annotation: notes];
        //id<CPProgram> cp = [ORFactory createCPProgram:mdl annotation: notes];
        
        [cp solve: ^{
            
            //[cp labelArray:x];
            //[cp labelArray:y];

            [cp labelArray: variables];
            
            /*int nb1 = 0,nb2 = 0;
            for (int i = MINVARIABLE; i <= MAXVARIABLE; i++) {
                int vi = [cp intValue: [x at:i]];
                nb1 += (vi == 1 || vi==2 || vi==3);
                nb2 += (vi == 1 || vi==2);
                printf("%d  ",vi);
                
            }
            assert(3 <= nb1 && nb1 <= 4);
            assert(2 <= nb2 && nb2 <= 3);
*/
//            printf("\n");
            for (int i = 1; i <= 50; i++) {
                printf("%d  ",[cp intValue: [variables at:i]]);
            }
            //printf("  |  Objective value: %d", [cp intValue: totalWeight]);
            //printf("\n");
            [nbSolutions incr: cp];
         }
        ];
        
        ORLong endWC  = [ORRuntimeMonitor wctime];
        ORLong endCPU = [ORRuntimeMonitor cputime];
        
        printf("\nTook %lld WC and %lld CPU\n\n",(endWC-startWC),(endCPU-startCPU));
        
        printf("GOT %d solutions\n",[nbSolutions intValue:cp]);
        NSLog(@"Solver status: %@\n",cp);
        NSLog(@"Quitting");
    }

    return 0;
}
