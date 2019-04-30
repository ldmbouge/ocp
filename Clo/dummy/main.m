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
        
        id<ORInteger> zero = [ORFactory integer:mdl value:0];
        
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
        
        id<ORInteger> firstVariableIndex = [ORFactory integer:mdl value:1];
        id<ORInteger> secondVariableIndex = [ORFactory integer:mdl value:2];
        
        //Equality constraint
        /*
        id<ORAltMDDSpecs> mddStateSpecs = [ORFactory AltMDDSpecs: mdl variables: variables];
        [mddStateSpecs setBottomUpInformationAsSet];
        [mddStateSpecs setTopDownInformationAsSet];
        

        
        //(e is not in Idown(s) and L(s) == j) OR (e is not in Iup(t) and L(s) == i)
        id<ORExpr> deleteEdgeWhen = [[[[[ORFactory parentInformation:mdl] contains:[ORFactory valueAssignment:mdl] track:mdl] negTrack:mdl] land:[[ORFactory layerVariable: mdl] eq: secondVariableIndex track:mdl] track:mdl] lor:
                                     [[[[ORFactory childInformation:mdl] contains:[ORFactory valueAssignment:mdl] track:mdl] negTrack:mdl] land:[[ORFactory layerVariable: mdl] eq: firstVariableIndex track:mdl] track:mdl] track:mdl];
        
        //If L(s) == i, Idown(s) x e = {e}
        id<ORExpr> addEdgeToTopDown = [[[ORFactory layerVariable: mdl] eq: firstVariableIndex track:mdl] ifthen:[ORFactory singletonSet:[ORFactory valueAssignment:mdl] track:mdl] elseReturn: [ORFactory parentInformation:mdl] track:mdl];
        //If L(s) == j, Iup(t) x e = {e}
        id<ORExpr> addEdgeToBottomUp = [[[ORFactory layerVariable: mdl] eq: secondVariableIndex track:mdl] ifthen:[ORFactory singletonSet:[ORFactory valueAssignment:mdl] track:mdl] elseReturn: [ORFactory parentInformation:mdl] track:mdl];
        //Possibly should rename parentInformation here.  In theory, can just use same function since when it makes the closures for these, it should just be passing it the 'source' node and an edge.  The source node in top-down is the parent of an edge.  The source node in bottom-up is the child of an edge.
        
        [mddStateSpecs setEdgeDeletionCondition: deleteEdgeWhen];
        [mddStateSpecs setTopDownInfoEdgeAddition: addEdgeToTopDown];
        [mddStateSpecs setBottomUpInfoEdgeAddition: addEdgeToBottomUp];
        [mddStateSpecs setInformationMergeToUnion:mdl];
        
        [mdl add: mddStateSpecs];*/
        
        
        //Among, all path lengths
        id<ORAltMDDSpecs> mddStateSpecs1 = [ORFactory AltMDDSpecs: mdl variables: variables];
        [mddStateSpecs1 setBottomUpInformationAsSet];
        [mddStateSpecs1 addToBottomUpInfoSet: 0];
        [mddStateSpecs1 setTopDownInformationAsSet];
        [mddStateSpecs1 addToTopDownInfoSet: 0];
        
        
        
        //if for each v in Idown(s), v' in Iup(t), v + e + v' not in [l,u], delete
        id<ORExpr> deleteEdgeWhen1 = [[[[[ORFactory parentInformation:mdl] toEachInSetPlus:[countedValues1 contains: [ORFactory valueAssignment:mdl]] track:mdl] toEachInSetPlusEachInSet: [ORFactory childInformation:mdl] track:mdl] eachInSetLT:lower1 track:mdl] lor:
                                      [[[[ORFactory parentInformation:mdl] toEachInSetPlus:[countedValues1 contains: [ORFactory valueAssignment:mdl]] track:mdl] toEachInSetPlusEachInSet: [ORFactory childInformation:mdl] track:mdl] eachInSetGT:upper1 track:mdl] track:mdl];
        
        //Add e to each v in Idown(s)
        id<ORExpr> addEdgeToTopDown1 = [[ORFactory parentInformation:mdl] toEachInSetPlus:[countedValues1 contains: [ORFactory valueAssignment:mdl]] track:mdl];
        //Add e to each v in Iup(t)
        id<ORExpr> addEdgeToBottomUp1 =[[ORFactory parentInformation:mdl] toEachInSetPlus:[countedValues1 contains: [ORFactory valueAssignment:mdl]] track:mdl];
        //Possibly should rename parentInformation here.  In theory, can just use same function since when it makes the closures for these, it should just be passing it the 'source' node and an edge.  The source node in top-down is the parent of an edge.  The source node in bottom-up is the child of an edge.
        
        [mddStateSpecs1 setEdgeDeletionCondition: deleteEdgeWhen1];
        [mddStateSpecs1 setTopDownInfoEdgeAddition: addEdgeToTopDown1];
        [mddStateSpecs1 setBottomUpInfoEdgeAddition: addEdgeToBottomUp1];
        [mddStateSpecs1 setInformationMergeToUnion:mdl];
        
        [mdl add: mddStateSpecs1];
        
        id<ORAltMDDSpecs> mddStateSpecs2 = [ORFactory AltMDDSpecs: mdl variables: variables];
        [mddStateSpecs2 setBottomUpInformationAsSet];
        [mddStateSpecs2 addToBottomUpInfoSet: 0];
        [mddStateSpecs2 setTopDownInformationAsSet];
        [mddStateSpecs2 addToTopDownInfoSet: 0];
        
        
        
        //if for each v in Idown(s), v' in Iup(t), v + e + v' not in [l,u], delete
        id<ORExpr> deleteEdgeWhen2 = [[[[[ORFactory parentInformation:mdl] toEachInSetPlus:[countedValues2 contains: [ORFactory valueAssignment:mdl]] track:mdl] toEachInSetPlusEachInSet: [ORFactory childInformation:mdl] track:mdl] eachInSetLT:lower2 track:mdl] lor:
                                      [[[[ORFactory parentInformation:mdl] toEachInSetPlus:[countedValues2 contains: [ORFactory valueAssignment:mdl]] track:mdl] toEachInSetPlusEachInSet: [ORFactory childInformation:mdl] track:mdl] eachInSetGT:upper2 track:mdl] track:mdl];
        
        //Add e to each v in Idown(s)
        id<ORExpr> addEdgeToTopDown2 = [[ORFactory parentInformation:mdl] toEachInSetPlus:[countedValues2 contains: [ORFactory valueAssignment:mdl]] track:mdl];
        //Add e to each v in Iup(t)
        id<ORExpr> addEdgeToBottomUp2 =[[ORFactory parentInformation:mdl] toEachInSetPlus:[countedValues2 contains: [ORFactory valueAssignment:mdl]] track:mdl];
        //Possibly should rename parentInformation here.  In theory, can just use same function since when it makes the closures for these, it should just be passing it the 'source' node and an edge.  The source node in top-down is the parent of an edge.  The source node in bottom-up is the child of an edge.
        
        [mddStateSpecs2 setEdgeDeletionCondition: deleteEdgeWhen2];
        [mddStateSpecs2 setTopDownInfoEdgeAddition: addEdgeToTopDown2];
        [mddStateSpecs2 setBottomUpInfoEdgeAddition: addEdgeToBottomUp2];
        [mddStateSpecs2 setInformationMergeToUnion:mdl];
        
        [mdl add: mddStateSpecs2];
        /*
        id<ORAltMDDSpecs> mddStateSpecs3 = [ORFactory AltMDDSpecs: mdl variables: variables];
        [mddStateSpecs3 setBottomUpInformationAsSet];
        [mddStateSpecs3 addToBottomUpInfoSet: 0];
        [mddStateSpecs3 setTopDownInformationAsSet];
        [mddStateSpecs3 addToTopDownInfoSet: 0];
        
        
        
        //if for each v in Idown(s), v' in Iup(t), v + e + v' not in [l,u], delete
        id<ORExpr> deleteEdgeWhen3 = [[[[[ORFactory parentInformation:mdl] toEachInSetPlus:[countedValues3 contains: [ORFactory valueAssignment:mdl]] track:mdl] toEachInSetPlusEachInSet: [ORFactory childInformation:mdl] track:mdl] eachInSetLT:lower3 track:mdl] lor:
                                      [[[[ORFactory parentInformation:mdl] toEachInSetPlus:[countedValues3 contains: [ORFactory valueAssignment:mdl]] track:mdl] toEachInSetPlusEachInSet: [ORFactory childInformation:mdl] track:mdl] eachInSetGT:upper3 track:mdl] track:mdl];
        
        //Add e to each v in Idown(s)
        id<ORExpr> addEdgeToTopDown3 = [[ORFactory parentInformation:mdl] toEachInSetPlus:[countedValues3 contains: [ORFactory valueAssignment:mdl]] track:mdl];
        //Add e to each v in Iup(t)
        id<ORExpr> addEdgeToBottomUp3 =[[ORFactory parentInformation:mdl] toEachInSetPlus:[countedValues3 contains: [ORFactory valueAssignment:mdl]] track:mdl];
        //Possibly should rename parentInformation here.  In theory, can just use same function since when it makes the closures for these, it should just be passing it the 'source' node and an edge.  The source node in top-down is the parent of an edge.  The source node in bottom-up is the child of an edge.
        
        [mddStateSpecs3 setEdgeDeletionCondition: deleteEdgeWhen3];
        [mddStateSpecs3 setTopDownInfoEdgeAddition: addEdgeToTopDown3];
        [mddStateSpecs3 setBottomUpInfoEdgeAddition: addEdgeToBottomUp3];
        [mddStateSpecs3 setInformationMergeToUnion:mdl];
        
        [mdl add: mddStateSpecs3];
        
        id<ORAltMDDSpecs> mddStateSpecs4 = [ORFactory AltMDDSpecs: mdl variables: variables];
        [mddStateSpecs4 setBottomUpInformationAsSet];
        [mddStateSpecs4 addToBottomUpInfoSet: 0];
        [mddStateSpecs4 setTopDownInformationAsSet];
        [mddStateSpecs4 addToTopDownInfoSet: 0];
        
        
        
        //if for each v in Idown(s), v' in Iup(t), v + e + v' not in [l,u], delete
        id<ORExpr> deleteEdgeWhen4 = [[[[[ORFactory parentInformation:mdl] toEachInSetPlus:[countedValues4 contains: [ORFactory valueAssignment:mdl]] track:mdl] toEachInSetPlusEachInSet: [ORFactory childInformation:mdl] track:mdl] eachInSetLT:lower4 track:mdl] lor:
                                      [[[[ORFactory parentInformation:mdl] toEachInSetPlus:[countedValues4 contains: [ORFactory valueAssignment:mdl]] track:mdl] toEachInSetPlusEachInSet: [ORFactory childInformation:mdl] track:mdl] eachInSetGT:upper4 track:mdl] track:mdl];
        
        //Add e to each v in Idown(s)
        id<ORExpr> addEdgeToTopDown4 = [[ORFactory parentInformation:mdl] toEachInSetPlus:[countedValues4 contains: [ORFactory valueAssignment:mdl]] track:mdl];
        //Add e to each v in Iup(t)
        id<ORExpr> addEdgeToBottomUp4 =[[ORFactory parentInformation:mdl] toEachInSetPlus:[countedValues4 contains: [ORFactory valueAssignment:mdl]] track:mdl];
        //Possibly should rename parentInformation here.  In theory, can just use same function since when it makes the closures for these, it should just be passing it the 'source' node and an edge.  The source node in top-down is the parent of an edge.  The source node in bottom-up is the child of an edge.
        
        [mddStateSpecs4 setEdgeDeletionCondition: deleteEdgeWhen4];
        [mddStateSpecs4 setTopDownInfoEdgeAddition: addEdgeToTopDown4];
        [mddStateSpecs4 setBottomUpInfoEdgeAddition: addEdgeToBottomUp4];
        [mddStateSpecs4 setInformationMergeToUnion:mdl];
        
        [mdl add: mddStateSpecs4];
        
        id<ORAltMDDSpecs> mddStateSpecs5 = [ORFactory AltMDDSpecs: mdl variables: variables];
        [mddStateSpecs5 setBottomUpInformationAsSet];
        [mddStateSpecs5 addToBottomUpInfoSet: 0];
        [mddStateSpecs5 setTopDownInformationAsSet];
        [mddStateSpecs5 addToTopDownInfoSet: 0];
        
        
        
        //if for each v in Idown(s), v' in Iup(t), v + e + v' not in [l,u], delete
        id<ORExpr> deleteEdgeWhen5 = [[[[[ORFactory parentInformation:mdl] toEachInSetPlus:[countedValues5 contains: [ORFactory valueAssignment:mdl]] track:mdl] toEachInSetPlusEachInSet: [ORFactory childInformation:mdl] track:mdl] eachInSetLT:lower5 track:mdl] lor:
                                      [[[[ORFactory parentInformation:mdl] toEachInSetPlus:[countedValues5 contains: [ORFactory valueAssignment:mdl]] track:mdl] toEachInSetPlusEachInSet: [ORFactory childInformation:mdl] track:mdl] eachInSetGT:upper5 track:mdl] track:mdl];
        
        //Add e to each v in Idown(s)
        id<ORExpr> addEdgeToTopDown5 = [[ORFactory parentInformation:mdl] toEachInSetPlus:[countedValues5 contains: [ORFactory valueAssignment:mdl]] track:mdl];
        //Add e to each v in Iup(t)
        id<ORExpr> addEdgeToBottomUp5 =[[ORFactory parentInformation:mdl] toEachInSetPlus:[countedValues5 contains: [ORFactory valueAssignment:mdl]] track:mdl];
        //Possibly should rename parentInformation here.  In theory, can just use same function since when it makes the closures for these, it should just be passing it the 'source' node and an edge.  The source node in top-down is the parent of an edge.  The source node in bottom-up is the child of an edge.
        
        [mddStateSpecs5 setEdgeDeletionCondition: deleteEdgeWhen5];
        [mddStateSpecs5 setTopDownInfoEdgeAddition: addEdgeToTopDown5];
        [mddStateSpecs5 setBottomUpInfoEdgeAddition: addEdgeToBottomUp5];
        [mddStateSpecs5 setInformationMergeToUnion:mdl];
        
        [mdl add: mddStateSpecs5];*/
        
        /*
        
        typedef enum {
            minCount,
            maxCount,
            remaining
        } AmongState;
        
        
        id<ORMDDSpecs> mddStateSpecs = [ORFactory MDDSpecs: mdl variables:variables stateSize: 3];
        [mddStateSpecs addStateInt: minCount withDefaultValue: 0];
        [mddStateSpecs addStateInt: maxCount withDefaultValue: 0];
        [mddStateSpecs addStateInt: remaining withDefaultValue: 50];
        
        id<ORExpr> arcExists = [[[ORFactory expr: [ORFactory getStateValue:mdl lookup:minCount] plus: [countedValues1 contains:[ORFactory valueAssignment:mdl]] track:mdl] leq: upper1 track:mdl]
                                land:
                                [[[ORFactory expr: [ORFactory getStateValue:mdl lookup:maxCount] plus: [countedValues1 contains:[ORFactory valueAssignment:mdl]] track:mdl] plus: [[ORFactory getStateValue:mdl lookup:remaining] sub: @1 track: mdl] track: mdl] geq: lower1 track: mdl] track: mdl];
        
        [mddStateSpecs setArcExistsFunction: arcExists];
        
        //self["count"] = parent["count"] + (parentValue in countedValues)
        id<ORExpr> minCountTransitionFunction = [[ORFactory getStateValue:mdl lookup:minCount] plus: [countedValues1 contains:[ORFactory valueAssignment:mdl]] track: mdl];
        id<ORExpr> maxCountTransitionFunction = [[ORFactory getStateValue:mdl lookup:maxCount] plus: [countedValues1 contains:[ORFactory valueAssignment:mdl]] track: mdl];
        //self["remaining"] = parent["remaining"] - 1
        id<ORExpr> remainingTransitionFunction = [[ORFactory getStateValue:mdl lookup:remaining] sub: @1 track: mdl];
        [mddStateSpecs addTransitionFunction: minCountTransitionFunction toStateValue: minCount];
        [mddStateSpecs addTransitionFunction: maxCountTransitionFunction toStateValue: maxCount];
        [mddStateSpecs addTransitionFunction: remainingTransitionFunction toStateValue: remaining];
        id<ORExpr> minCountRelaxationFunction = [ORFactory expr: [ORFactory getLeftStateValue:mdl lookup:minCount] min:[ORFactory getRightStateValue:mdl lookup:minCount] track:mdl];
        id<ORExpr> maxCountRelaxationFunction = [ORFactory expr: [ORFactory getLeftStateValue:mdl lookup:maxCount] max:[ORFactory getRightStateValue:mdl lookup:maxCount] track:mdl];
        id<ORExpr> remainingRelaxationFunction = [ORFactory getLeftStateValue:mdl lookup:remaining];
        [mddStateSpecs addRelaxationFunction: minCountRelaxationFunction toStateValue: minCount];
        [mddStateSpecs addRelaxationFunction: maxCountRelaxationFunction toStateValue: maxCount];
        [mddStateSpecs addRelaxationFunction: remainingRelaxationFunction toStateValue: remaining];
        
        //id<ORExpr> minCountStateDifferential = [[[ORFactory expr: [ORFactory getLeftStateValue:mdl lookup:minCount] max:[upper1 sub:[ORFactory getLeftStateValue:mdl lookup:remaining] track:mdl] track:mdl] sub: [ORFactory expr: [ORFactory getRightStateValue:mdl lookup:minCount] max:[upper1 sub:[ORFactory getRightStateValue:mdl lookup:remaining] track:mdl] track:mdl] track:mdl] absTrack:mdl];
        //id<ORExpr> maxCountStateDifferential = [[[ORFactory expr: [ORFactory getLeftStateValue:mdl lookup:maxCount] min:lower1 track:mdl] sub: [ORFactory expr: [ORFactory getRightStateValue:mdl lookup:maxCount] min: lower1 track:mdl] track:mdl] absTrack:mdl];
        id<ORExpr> minCountStateDifferential = [[[ORFactory getLeftStateValue:mdl lookup:minCount] sub:[ORFactory getRightStateValue:mdl lookup:minCount] track:mdl] absTrack:mdl];
        id<ORExpr> maxCountStateDifferential = [[[ORFactory getLeftStateValue:mdl lookup:maxCount] sub:[ORFactory getRightStateValue:mdl lookup:maxCount] track:mdl] absTrack:mdl];
        id<ORExpr> remainingStateDifferential = zero;
        
        [mddStateSpecs addStateDifferentialFunction: minCountStateDifferential toStateValue: minCount];
        [mddStateSpecs addStateDifferentialFunction: maxCountStateDifferential toStateValue: maxCount];
        [mddStateSpecs addStateDifferentialFunction: remainingStateDifferential toStateValue: remaining];
        
        [mdl add: mddStateSpecs];
        
        
        id<ORMDDSpecs> mddStateSpecs2 = [ORFactory MDDSpecs: mdl variables:variables stateSize: 3];
        [mddStateSpecs2 addStateInt: minCount withDefaultValue: 0];
        [mddStateSpecs2 addStateInt: maxCount withDefaultValue: 0];
        [mddStateSpecs2 addStateInt: remaining withDefaultValue: 50];
        
        id<ORExpr> arcExists2 = [[[ORFactory expr: [ORFactory getStateValue:mdl lookup:minCount] plus: [countedValues2 contains:[ORFactory valueAssignment:mdl]] track:mdl] leq: upper2 track:mdl]
                                land:
                                [[[ORFactory expr: [ORFactory getStateValue:mdl lookup:maxCount] plus: [countedValues2 contains:[ORFactory valueAssignment:mdl]] track:mdl] plus: [[ORFactory getStateValue:mdl lookup:remaining] sub: @1 track: mdl] track: mdl] geq: lower2 track: mdl] track: mdl];
        
        [mddStateSpecs2 setArcExistsFunction: arcExists2];
        
        id<ORExpr> minCountTransitionFunction2 = [[ORFactory getStateValue:mdl lookup:minCount] plus: [countedValues2 contains:[ORFactory valueAssignment:mdl]] track: mdl];
        id<ORExpr> maxCountTransitionFunction2 = [[ORFactory getStateValue:mdl lookup:maxCount] plus: [countedValues2 contains:[ORFactory valueAssignment:mdl]] track: mdl];
        id<ORExpr> remainingTransitionFunction2 = [[ORFactory getStateValue:mdl lookup:remaining] sub: @1 track: mdl];
        
        [mddStateSpecs2 addTransitionFunction: minCountTransitionFunction2 toStateValue: minCount];
        [mddStateSpecs2 addTransitionFunction: maxCountTransitionFunction2 toStateValue: maxCount];
        [mddStateSpecs2 addTransitionFunction: remainingTransitionFunction2 toStateValue: remaining];
        
        id<ORExpr> minCountRelaxationFunction2 = [ORFactory expr: [ORFactory getLeftStateValue:mdl lookup:minCount] min:[ORFactory getRightStateValue:mdl lookup:minCount] track:mdl];
        id<ORExpr> maxCountRelaxationFunction2 = [ORFactory expr: [ORFactory getLeftStateValue:mdl lookup:maxCount] max:[ORFactory getRightStateValue:mdl lookup:maxCount] track:mdl];
        id<ORExpr> remainingRelaxationFunction2 = [ORFactory getLeftStateValue:mdl lookup:remaining];
        [mddStateSpecs2 addRelaxationFunction: minCountRelaxationFunction2 toStateValue: minCount];
        [mddStateSpecs2 addRelaxationFunction: maxCountRelaxationFunction2 toStateValue: maxCount];
        [mddStateSpecs2 addRelaxationFunction: remainingRelaxationFunction2 toStateValue: remaining];
        
        //id<ORExpr> minCountStateDifferential2 = [[[ORFactory expr: [ORFactory getLeftStateValue:mdl lookup:minCount] max:[upper2 sub:[ORFactory getLeftStateValue:mdl lookup:remaining] track:mdl] track:mdl] sub: [ORFactory expr: [ORFactory getRightStateValue:mdl lookup:minCount] max:[upper2 sub:[ORFactory getRightStateValue:mdl lookup:remaining] track:mdl] track:mdl] track:mdl] absTrack:mdl];
        //id<ORExpr> maxCountStateDifferential2 = [[[ORFactory expr: [ORFactory getLeftStateValue:mdl lookup:maxCount] min:lower2 track:mdl] sub: [ORFactory expr: [ORFactory getRightStateValue:mdl lookup:maxCount] min: lower2 track:mdl] track:mdl] absTrack:mdl];
        id<ORExpr> minCountStateDifferential2 = [[[ORFactory getLeftStateValue:mdl lookup:minCount] sub:[ORFactory getRightStateValue:mdl lookup:minCount] track:mdl] absTrack:mdl];
        id<ORExpr> maxCountStateDifferential2 = [[[ORFactory getLeftStateValue:mdl lookup:maxCount] sub:[ORFactory getRightStateValue:mdl lookup:maxCount] track:mdl] absTrack:mdl];
        id<ORExpr> remainingStateDifferential2 = zero;
        
        [mddStateSpecs2 addStateDifferentialFunction: minCountStateDifferential2 toStateValue: minCount];
        [mddStateSpecs2 addStateDifferentialFunction: maxCountStateDifferential2 toStateValue: maxCount];
        [mddStateSpecs2 addStateDifferentialFunction: remainingStateDifferential2 toStateValue: remaining];
        
        [mdl add: mddStateSpecs2];
        

        
        id<ORMDDSpecs> mddStateSpecs3 = [ORFactory MDDSpecs: mdl variables:variables stateSize: 3];
        [mddStateSpecs3 addStateInt: minCount withDefaultValue: 0];
        [mddStateSpecs3 addStateInt: maxCount withDefaultValue: 0];
        [mddStateSpecs3 addStateInt: remaining withDefaultValue: 50];
        
        id<ORExpr> arcExists3 = [[[ORFactory expr: [ORFactory getStateValue:mdl lookup:minCount] plus: [countedValues3 contains:[ORFactory valueAssignment:mdl]] track:mdl] leq: upper3 track:mdl]
                                 land:
                                 [[[ORFactory expr: [ORFactory getStateValue:mdl lookup:maxCount] plus: [countedValues3 contains:[ORFactory valueAssignment:mdl]] track:mdl] plus: [[ORFactory getStateValue:mdl lookup:remaining] sub: @1 track: mdl] track: mdl] geq: lower3 track: mdl] track: mdl];
        
        [mddStateSpecs3 setArcExistsFunction: arcExists3];
        
        id<ORExpr> minCountTransitionFunction3 = [[ORFactory getStateValue:mdl lookup:minCount] plus: [countedValues3 contains:[ORFactory valueAssignment:mdl]] track: mdl];
        id<ORExpr> maxCountTransitionFunction3 = [[ORFactory getStateValue:mdl lookup:maxCount] plus: [countedValues3 contains:[ORFactory valueAssignment:mdl]] track: mdl];
        id<ORExpr> remainingTransitionFunction3 = [[ORFactory getStateValue:mdl lookup:remaining] sub: @1 track: mdl];
        
        [mddStateSpecs3 addTransitionFunction: minCountTransitionFunction3 toStateValue: minCount];
        [mddStateSpecs3 addTransitionFunction: maxCountTransitionFunction3 toStateValue: maxCount];
        [mddStateSpecs3 addTransitionFunction: remainingTransitionFunction3 toStateValue: remaining];
        
        id<ORExpr> minCountRelaxationFunction3 = [ORFactory expr: [ORFactory getLeftStateValue:mdl lookup:minCount] min:[ORFactory getRightStateValue:mdl lookup:minCount] track:mdl];
        id<ORExpr> maxCountRelaxationFunction3 = [ORFactory expr: [ORFactory getLeftStateValue:mdl lookup:maxCount] max:[ORFactory getRightStateValue:mdl lookup:maxCount] track:mdl];
        id<ORExpr> remainingRelaxationFunction3 = [ORFactory getLeftStateValue:mdl lookup:remaining];
        [mddStateSpecs3 addRelaxationFunction: minCountRelaxationFunction3 toStateValue: minCount];
        [mddStateSpecs3 addRelaxationFunction: maxCountRelaxationFunction3 toStateValue: maxCount];
        [mddStateSpecs3 addRelaxationFunction: remainingRelaxationFunction3 toStateValue: remaining];
        
        //id<ORExpr> minCountStateDifferential3 = [[[ORFactory expr: [ORFactory getLeftStateValue:mdl lookup:minCount] max:[upper3 sub:[ORFactory getLeftStateValue:mdl lookup:remaining] track:mdl] track:mdl] sub: [ORFactory expr: [ORFactory getRightStateValue:mdl lookup:minCount] max:[upper3 sub:[ORFactory getRightStateValue:mdl lookup:remaining] track:mdl] track:mdl] track:mdl] absTrack:mdl];
        //id<ORExpr> maxCountStateDifferential3 = [[[ORFactory expr: [ORFactory getLeftStateValue:mdl lookup:maxCount] min:lower3 track:mdl] sub: [ORFactory expr: [ORFactory getRightStateValue:mdl lookup:maxCount] min: lower3 track:mdl] track:mdl] absTrack:mdl];
        id<ORExpr> minCountStateDifferential3 = [[[ORFactory getLeftStateValue:mdl lookup:minCount] sub:[ORFactory getRightStateValue:mdl lookup:minCount] track:mdl] absTrack:mdl];
        id<ORExpr> maxCountStateDifferential3 = [[[ORFactory getLeftStateValue:mdl lookup:maxCount] sub:[ORFactory getRightStateValue:mdl lookup:maxCount] track:mdl] absTrack:mdl];
        id<ORExpr> remainingStateDifferential3 = zero;
        
        [mddStateSpecs3 addStateDifferentialFunction: minCountStateDifferential3 toStateValue: minCount];
        [mddStateSpecs3 addStateDifferentialFunction: maxCountStateDifferential3 toStateValue: maxCount];
        [mddStateSpecs3 addStateDifferentialFunction: remainingStateDifferential3 toStateValue: remaining];
        
        [mdl add: mddStateSpecs3];
        
        
        
        id<ORMDDSpecs> mddStateSpecs4 = [ORFactory MDDSpecs: mdl variables:variables stateSize: 3];
        [mddStateSpecs4 addStateInt: minCount withDefaultValue: 0];
        [mddStateSpecs4 addStateInt: maxCount withDefaultValue: 0];
        [mddStateSpecs4 addStateInt: remaining withDefaultValue: 50];
        
        id<ORExpr> arcExists4 = [[[ORFactory expr: [ORFactory getStateValue:mdl lookup:minCount] plus: [countedValues4 contains:[ORFactory valueAssignment:mdl]] track:mdl] leq: upper4 track:mdl]
                                 land:
                                 [[[ORFactory expr: [ORFactory getStateValue:mdl lookup:maxCount] plus: [countedValues4 contains:[ORFactory valueAssignment:mdl]] track:mdl] plus: [[ORFactory getStateValue:mdl lookup:remaining] sub: @1 track: mdl] track: mdl] geq: lower4 track: mdl] track: mdl];
        
        [mddStateSpecs4 setArcExistsFunction: arcExists4];
        
        id<ORExpr> minCountTransitionFunction4 = [[ORFactory getStateValue:mdl lookup:minCount] plus: [countedValues4 contains:[ORFactory valueAssignment:mdl]] track: mdl];
        id<ORExpr> maxCountTransitionFunction4 = [[ORFactory getStateValue:mdl lookup:maxCount] plus: [countedValues4 contains:[ORFactory valueAssignment:mdl]] track: mdl];
        id<ORExpr> remainingTransitionFunction4 = [[ORFactory getStateValue:mdl lookup:remaining] sub: @1 track: mdl];
        
        [mddStateSpecs4 addTransitionFunction: minCountTransitionFunction4 toStateValue: minCount];
        [mddStateSpecs4 addTransitionFunction: maxCountTransitionFunction4 toStateValue: maxCount];
        [mddStateSpecs4 addTransitionFunction: remainingTransitionFunction4 toStateValue: remaining];
        
        id<ORExpr> minCountRelaxationFunction4 = [ORFactory expr: [ORFactory getLeftStateValue:mdl lookup:minCount] min:[ORFactory getRightStateValue:mdl lookup:minCount] track:mdl];
        id<ORExpr> maxCountRelaxationFunction4 = [ORFactory expr: [ORFactory getLeftStateValue:mdl lookup:maxCount] max:[ORFactory getRightStateValue:mdl lookup:maxCount] track:mdl];
        id<ORExpr> remainingRelaxationFunction4 = [ORFactory getLeftStateValue:mdl lookup:remaining];
        [mddStateSpecs4 addRelaxationFunction: minCountRelaxationFunction4 toStateValue: minCount];
        [mddStateSpecs4 addRelaxationFunction: maxCountRelaxationFunction4 toStateValue: maxCount];
        [mddStateSpecs4 addRelaxationFunction: remainingRelaxationFunction4 toStateValue: remaining];
        
        //id<ORExpr> minCountStateDifferential4 = [[[ORFactory expr: [ORFactory getLeftStateValue:mdl lookup:minCount] max:[upper4 sub:[ORFactory getLeftStateValue:mdl lookup:remaining] track:mdl] track:mdl] sub: [ORFactory expr: [ORFactory getRightStateValue:mdl lookup:minCount] max:[upper4 sub:[ORFactory getRightStateValue:mdl lookup:remaining] track:mdl] track:mdl] track:mdl] absTrack:mdl];
        //id<ORExpr> maxCountStateDifferential4 = [[[ORFactory expr: [ORFactory getLeftStateValue:mdl lookup:maxCount] min:lower4 track:mdl] sub: [ORFactory expr: [ORFactory getRightStateValue:mdl lookup:maxCount] min: lower4 track:mdl] track:mdl] absTrack:mdl];
        id<ORExpr> minCountStateDifferential4 = [[[ORFactory getLeftStateValue:mdl lookup:minCount] sub:[ORFactory getRightStateValue:mdl lookup:minCount] track:mdl] absTrack:mdl];
        id<ORExpr> maxCountStateDifferential4 = [[[ORFactory getLeftStateValue:mdl lookup:maxCount] sub:[ORFactory getRightStateValue:mdl lookup:maxCount] track:mdl] absTrack:mdl];
        id<ORExpr> remainingStateDifferential4 = zero;
        
        [mddStateSpecs4 addStateDifferentialFunction: minCountStateDifferential4 toStateValue: minCount];
        [mddStateSpecs4 addStateDifferentialFunction: maxCountStateDifferential4 toStateValue: maxCount];
        [mddStateSpecs4 addStateDifferentialFunction: remainingStateDifferential4 toStateValue: remaining];
        
        [mdl add: mddStateSpecs4];
        
        
        id<ORMDDSpecs> mddStateSpecs5 = [ORFactory MDDSpecs: mdl variables:variables stateSize: 3];
        [mddStateSpecs5 addStateInt: minCount withDefaultValue: 0];
        [mddStateSpecs5 addStateInt: maxCount withDefaultValue: 0];
        [mddStateSpecs5 addStateInt: remaining withDefaultValue: 50];
        
        id<ORExpr> arcExists5 = [[[ORFactory expr: [ORFactory getStateValue:mdl lookup:minCount] plus: [countedValues5 contains:[ORFactory valueAssignment:mdl]] track:mdl] leq: upper5 track:mdl]
                                 land:
                                 [[[ORFactory expr: [ORFactory getStateValue:mdl lookup:maxCount] plus: [countedValues5 contains:[ORFactory valueAssignment:mdl]] track:mdl] plus: [[ORFactory getStateValue:mdl lookup:remaining] sub: @1 track: mdl] track: mdl] geq: lower5 track: mdl] track: mdl];
        
        [mddStateSpecs5 setArcExistsFunction: arcExists5];
        
        id<ORExpr> minCountTransitionFunction5 = [[ORFactory getStateValue:mdl lookup:minCount] plus: [countedValues5 contains:[ORFactory valueAssignment:mdl]] track: mdl];
        id<ORExpr> maxCountTransitionFunction5 = [[ORFactory getStateValue:mdl lookup:maxCount] plus: [countedValues5 contains:[ORFactory valueAssignment:mdl]] track: mdl];
        id<ORExpr> remainingTransitionFunction5 = [[ORFactory getStateValue:mdl lookup:remaining] sub: @1 track: mdl];
        
        [mddStateSpecs5 addTransitionFunction: minCountTransitionFunction5 toStateValue: minCount];
        [mddStateSpecs5 addTransitionFunction: maxCountTransitionFunction5 toStateValue: maxCount];
        [mddStateSpecs5 addTransitionFunction: remainingTransitionFunction5 toStateValue: remaining];
        
        id<ORExpr> minCountRelaxationFunction5 = [ORFactory expr: [ORFactory getLeftStateValue:mdl lookup:minCount] min:[ORFactory getRightStateValue:mdl lookup:minCount] track:mdl];
        id<ORExpr> maxCountRelaxationFunction5 = [ORFactory expr: [ORFactory getLeftStateValue:mdl lookup:maxCount] max:[ORFactory getRightStateValue:mdl lookup:maxCount] track:mdl];
        id<ORExpr> remainingRelaxationFunction5 = [ORFactory getLeftStateValue:mdl lookup:remaining];
        [mddStateSpecs5 addRelaxationFunction: minCountRelaxationFunction5 toStateValue: minCount];
        [mddStateSpecs5 addRelaxationFunction: maxCountRelaxationFunction5 toStateValue: maxCount];
        [mddStateSpecs5 addRelaxationFunction: remainingRelaxationFunction5 toStateValue: remaining];
        
        //id<ORExpr> minCountStateDifferential5 = [[[ORFactory expr: [ORFactory getLeftStateValue:mdl lookup:minCount] max:[upper5 sub:[ORFactory getLeftStateValue:mdl lookup:remaining] track:mdl] track:mdl] sub: [ORFactory expr: [ORFactory getRightStateValue:mdl lookup:minCount] max:[upper5 sub:[ORFactory getRightStateValue:mdl lookup:remaining] track:mdl] track:mdl] track:mdl] absTrack:mdl];
        //id<ORExpr> maxCountStateDifferential5 = [[[ORFactory expr: [ORFactory getLeftStateValue:mdl lookup:maxCount] min:lower5 track:mdl] sub: [ORFactory expr: [ORFactory getRightStateValue:mdl lookup:maxCount] min: lower5 track:mdl] track:mdl] absTrack:mdl];
        id<ORExpr> minCountStateDifferential5 = [[[ORFactory getLeftStateValue:mdl lookup:minCount] sub:[ORFactory getRightStateValue:mdl lookup:minCount] track:mdl] absTrack:mdl];
        id<ORExpr> maxCountStateDifferential5 = [[[ORFactory getLeftStateValue:mdl lookup:maxCount] sub:[ORFactory getRightStateValue:mdl lookup:maxCount] track:mdl] absTrack:mdl];
        id<ORExpr> remainingStateDifferential5 = zero;
        
        [mddStateSpecs5 addStateDifferentialFunction: minCountStateDifferential5 toStateValue: minCount];
        [mddStateSpecs5 addStateDifferentialFunction: maxCountStateDifferential5 toStateValue: maxCount];
        [mddStateSpecs5 addStateDifferentialFunction: remainingStateDifferential5 toStateValue: remaining];
        
        
        [mdl add: mddStateSpecs5];
        */
        /*
        
        id<ORMDDSpecs> mddStateSpecs = [ORFactory MDDSpecs: mdl variables:variables stateSize: 2];
        [mddStateSpecs addStateInt: count withDefaultValue: 0];
        [mddStateSpecs addStateInt: remaining withDefaultValue: 50];
        
        //(count + (assignedValue in countedValues)) <= upper && (count + (assignedValue in countedValues) + (remaining-1)) >= lower
        id<ORExpr> arcExists = [[[ORFactory expr: [ORFactory getStateValue:mdl lookup:count] plus: [countedValues1 contains:[ORFactory valueAssignment:mdl]] track:mdl] leq: upper1 track:mdl]
                                land:
                                [[[ORFactory expr: [ORFactory getStateValue:mdl lookup:count] plus: [countedValues1 contains:[ORFactory valueAssignment:mdl]] track:mdl] plus: [[ORFactory getStateValue:mdl lookup:remaining] sub: @1 track: mdl] track: mdl] geq: lower1 track: mdl] track: mdl];
        
        [mddStateSpecs setArcExistsFunction: arcExists];
        
        //self["count"] = parent["count"] + (parentValue in countedValues)
        id<ORExpr> countTransitionFunction = [[ORFactory getStateValue:mdl lookup:count] plus: [countedValues1 contains:[ORFactory valueAssignment:mdl]] track: mdl];
        //self["remaining"] = parent["remaining"] - 1
        id<ORExpr> remainingTransitionFunction = [[ORFactory getStateValue:mdl lookup:remaining] sub: @1 track: mdl];
        [mddStateSpecs addTransitionFunction: countTransitionFunction toStateValue: count];
        [mddStateSpecs addTransitionFunction: remainingTransitionFunction toStateValue: remaining];
        
        [mdl add: mddStateSpecs];
        
        
        id<ORMDDSpecs> mddStateSpecs2 = [ORFactory MDDSpecs: mdl variables:variables stateSize:2];
        [mddStateSpecs2 addStateInt: count withDefaultValue: 0];
        [mddStateSpecs2 addStateInt: remaining withDefaultValue: 50];
        id<ORExpr> arcExists2 = [[[ORFactory expr: [ORFactory getStateValue:mdl lookup:count] plus: [countedValues2 contains:[ORFactory valueAssignment:mdl]] track:mdl] leq: upper2 track:mdl]
                                land:
                                 [[[ORFactory expr: [ORFactory getStateValue:mdl lookup:count] plus: [countedValues2 contains:[ORFactory valueAssignment:mdl]] track:mdl] plus: [[ORFactory getStateValue:mdl lookup:remaining] sub: @1 track: mdl] track: mdl] geq: lower2 track: mdl] track: mdl];
        [mddStateSpecs2 setArcExistsFunction: arcExists2];
        id<ORExpr> countTransitionFunction2 = [[ORFactory getStateValue:mdl lookup:count] plus: [countedValues2 contains:[ORFactory valueAssignment:mdl]] track: mdl];
        id<ORExpr> remainingTransitionFunction2 = [[ORFactory getStateValue:mdl lookup:remaining] sub: @1 track: mdl];
        [mddStateSpecs2 addTransitionFunction: countTransitionFunction2 toStateValue: count];
        [mddStateSpecs2 addTransitionFunction: remainingTransitionFunction2 toStateValue: remaining];
        [mdl add: mddStateSpecs2];
        
        
        id<ORMDDSpecs> mddStateSpecs3 = [ORFactory MDDSpecs: mdl variables:variables stateSize:2];
        [mddStateSpecs3 addStateInt: count withDefaultValue: 0];
        [mddStateSpecs3 addStateInt: remaining withDefaultValue: 50];
        id<ORExpr> arcExists3 = [[[ORFactory expr: [ORFactory getStateValue:mdl lookup:count] plus: [countedValues3 contains:[ORFactory valueAssignment:mdl]] track:mdl] leq: upper3 track:mdl]
                                 land:
                                 [[[ORFactory expr: [ORFactory getStateValue:mdl lookup:count] plus: [countedValues3 contains:[ORFactory valueAssignment:mdl]] track:mdl] plus: [[ORFactory getStateValue:mdl lookup:remaining] sub: @1 track: mdl] track: mdl] geq: lower3 track: mdl] track: mdl];
        [mddStateSpecs3 setArcExistsFunction: arcExists3];
        id<ORExpr> countTransitionFunction3 = [[ORFactory getStateValue:mdl lookup:count] plus: [countedValues3 contains:[ORFactory valueAssignment:mdl]] track: mdl];
        id<ORExpr> remainingTransitionFunction3 = [[ORFactory getStateValue:mdl lookup:remaining] sub: @1 track: mdl];
        [mddStateSpecs3 addTransitionFunction: countTransitionFunction3 toStateValue: count];
        [mddStateSpecs3 addTransitionFunction: remainingTransitionFunction3 toStateValue: remaining];
        [mdl add: mddStateSpecs3];
        
        
        id<ORMDDSpecs> mddStateSpecs4 = [ORFactory MDDSpecs: mdl variables:variables stateSize:2];
        [mddStateSpecs4 addStateInt: count withDefaultValue: 0];
        [mddStateSpecs4 addStateInt: remaining withDefaultValue: 50];
        id<ORExpr> arcExists4 = [[[ORFactory expr: [ORFactory getStateValue:mdl lookup: count] plus: [countedValues4 contains:[ORFactory valueAssignment:mdl]] track:mdl] leq: upper4 track:mdl]
                                 land:
                                 [[[ORFactory expr: [ORFactory getStateValue:mdl lookup: count] plus: [countedValues4 contains:[ORFactory valueAssignment:mdl]] track:mdl] plus: [[ORFactory getStateValue:mdl lookup:remaining] sub: @1 track: mdl] track: mdl] geq: lower4 track: mdl] track: mdl];
        [mddStateSpecs4 setArcExistsFunction: arcExists4];
        id<ORExpr> countTransitionFunction4 = [[ORFactory getStateValue:mdl lookup:count] plus: [countedValues4 contains:[ORFactory valueAssignment:mdl]] track: mdl];
        id<ORExpr> remainingTransitionFunction4 = [[ORFactory getStateValue:mdl lookup:remaining] sub: @1 track: mdl];
        [mddStateSpecs4 addTransitionFunction: countTransitionFunction4 toStateValue: count];
        [mddStateSpecs4 addTransitionFunction: remainingTransitionFunction4 toStateValue: remaining];
        [mdl add: mddStateSpecs4];
        
        
        id<ORMDDSpecs> mddStateSpecs5 = [ORFactory MDDSpecs: mdl variables:variables stateSize:2];
        [mddStateSpecs5 addStateInt: count withDefaultValue: 0];
        [mddStateSpecs5 addStateInt: remaining withDefaultValue: 50];
        id<ORExpr> arcExists5 = [[[ORFactory expr: [ORFactory getStateValue:mdl lookup:count] plus: [countedValues5 contains:[ORFactory valueAssignment:mdl]] track:mdl] leq: upper5 track:mdl]
                                 land:
                                 [[[ORFactory expr: [ORFactory getStateValue:mdl lookup:count] plus: [countedValues5 contains:[ORFactory valueAssignment:mdl]] track:mdl] plus: [[ORFactory getStateValue:mdl lookup:remaining] sub: @1 track: mdl] track: mdl] geq: lower5 track: mdl] track: mdl];
        [mddStateSpecs5 setArcExistsFunction: arcExists5];
        id<ORExpr> countTransitionFunction5 = [[ORFactory getStateValue:mdl lookup:count] plus: [countedValues5 contains:[ORFactory valueAssignment:mdl]] track: mdl];
        id<ORExpr> remainingTransitionFunction5 = [[ORFactory getStateValue:mdl lookup:remaining] sub: @1 track: mdl];
        [mddStateSpecs5 addTransitionFunction: countTransitionFunction5 toStateValue: count];
        [mddStateSpecs5 addTransitionFunction: remainingTransitionFunction5 toStateValue: remaining];
        [mdl add: mddStateSpecs5];
        */
        ORLong startWC  = [ORRuntimeMonitor wctime];
        ORLong startCPU = [ORRuntimeMonitor cputime];
        
        [notes ddWidth: 2];
        [notes ddRelaxed: true];
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
