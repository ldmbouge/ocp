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
        
        //id<ORIntVarArray> variables = [ORFactory intVarArray:mdl range: RANGE(mdl, 1, 50) domain: RANGE(mdl, 1, 5)];
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
        id<ORInteger> upper1 = [ORFactory integer:mdl value:5];
        id<ORInteger> lower2 = [ORFactory integer:mdl value:2];
        id<ORInteger> upper2 = [ORFactory integer:mdl value:3];
        id<ORInteger> lower3 = [ORFactory integer:mdl value:30];
        id<ORInteger> upper3 = [ORFactory integer:mdl value:40];
        id<ORInteger> lower4 = [ORFactory integer:mdl value:5];
        id<ORInteger> upper4 = [ORFactory integer:mdl value:15];
        id<ORInteger> lower5 = [ORFactory integer:mdl value:11];
        id<ORInteger> upper5 = [ORFactory integer:mdl value:12];
        
        id<ORInteger> zero = [ORFactory integer:mdl value:0];
        id<ORInteger> one = [ORFactory integer:mdl value:1];
        
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
        
        
        
        /*
        //Equality constraint
        id<ORInteger> firstVariableIndex = [ORFactory integer:mdl value:1];
        id<ORInteger> secondVariableIndex = [ORFactory integer:mdl value:2];
        
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
        /*
        id<ORAltMDDSpecs> mddObjectiveSpecs = [ORFactory AltMDDSpecs: mdl variables: variables];
        [mddObjectiveSpecs setAsMaximize];
        [mddObjectiveSpecs setBottomUpInformationAsInt];
        [mddObjectiveSpecs setTopDownInformationAsInt];
        
        id<ORExpr> addEdgeToTopDown = [[ORFactory parentInformation:mdl] plus:[ORFactory valueAssignment:mdl] track:mdl];
        id<ORExpr> addEdgeToBottomUp = [[ORFactory parentInformation:mdl] plus:[ORFactory valueAssignment:mdl] track:mdl];
        
        [mddObjectiveSpecs setTopDownInfoEdgeAddition: addEdgeToTopDown];
        [mddObjectiveSpecs setBottomUpInfoEdgeAddition: addEdgeToBottomUp];
        [mddObjectiveSpecs setInformationMergeToMax:mdl];
        
        //[mdl add: mddObjectiveSpecs];
        
        
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
        //[mddStateSpecs1 setInformationMergeToMinMaxSet:mdl];
        
        //[mdl add: mddStateSpecs1];
        
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
        //[mddStateSpecs2 setInformationMergeToMinMaxSet:mdl];
        
        //[mdl add: mddStateSpecs2];
        
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
        //[mddStateSpecs3 setInformationMergeToMinMaxSet:mdl];
        
        //[mdl add: mddStateSpecs3];
        
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
        //[mddStateSpecs4 setInformationMergeToMinMaxSet:mdl];
        
        //[mdl add: mddStateSpecs4];
        
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
        //[mddStateSpecs5 setInformationMergeToMinMaxSet:mdl];
        
        //[mdl add: mddStateSpecs5];
        
        */
        
        //Sequence Constraint, MDD
        /*id<ORIntVarArray> variables = [ORFactory intVarArray:mdl range: RANGE(mdl, 1, 20) domain: RANGE(mdl, 0, 20)];
        
        struct SequenceInfo {
            int length;
            int lastIndex;
            int lower;
            int upper;
            id<ORIntSet> countedValues;
        };
        
        struct SequenceInfo sequenceConstraints[7];
        
        sequenceConstraints[0].length = 7;
        sequenceConstraints[0].lower = 1;
        sequenceConstraints[0].upper = 5;
        sequenceConstraints[0].countedValues = [ORFactory intSet:mdl set:[NSSet setWithObjects:@0, @2, @9, @11, @13, nil]];
        
        sequenceConstraints[1].length = 7;
        sequenceConstraints[1].lower = 4;
        sequenceConstraints[1].upper = 5;
        sequenceConstraints[1].countedValues = [ORFactory intSet:mdl set:[NSSet setWithObjects:@0, @1, @2, @4, @5, @6, @10, @11, @12, @14, @16, @18, @19, nil]];
        
        sequenceConstraints[2].length = 8;
        sequenceConstraints[2].lower = 1;
        sequenceConstraints[2].upper = 6;
        sequenceConstraints[2].countedValues = [ORFactory intSet:mdl set:[NSSet setWithObjects:@0, @1, @2, @3, @4, @5, @6, @7, @8, @9, @10, @11, @12, @13, @15, @16, @17, @18, @19, nil]];
        
        sequenceConstraints[3].length = 5;
        sequenceConstraints[3].lower = 1;
        sequenceConstraints[3].upper = 1;
        sequenceConstraints[3].countedValues = [ORFactory intSet:mdl set:[NSSet setWithObjects:@1, nil]];
        
        sequenceConstraints[4].length = 9;
        sequenceConstraints[4].lower = 1;
        sequenceConstraints[4].upper = 6;
        sequenceConstraints[4].countedValues = [ORFactory intSet:mdl set:[NSSet setWithObjects:@1, @3, @5, @8, @10, @11, @12, @15, @16, @19, nil]];
        
        sequenceConstraints[5].length = 5;
        sequenceConstraints[5].lower = 1;
        sequenceConstraints[5].upper = 2;
        sequenceConstraints[5].countedValues = [ORFactory intSet:mdl set:[NSSet setWithObjects:@2, @4, @5, @6, @8, @12, @18, nil]];
        
        sequenceConstraints[6].length = 2;
        sequenceConstraints[6].lower = 0;
        sequenceConstraints[6].upper = 1;
        sequenceConstraints[6].countedValues = [ORFactory intSet:mdl set:[NSSet setWithObjects:@0, @3, @5, @6, @7, @8, @9, @10, @11, @12, @13, @15, @16, @17, @18, nil]];
        
        
        
        
        for (int sequenceConstraintIndex = 0; sequenceConstraintIndex < 7; sequenceConstraintIndex++) {
            struct SequenceInfo sequenceConstraint = sequenceConstraints[sequenceConstraintIndex];
            
            int minFirstIndex = 0;
            int minLastIndex = sequenceConstraint.length-1;
            int maxFirstIndex = sequenceConstraint.length;
            int maxLastIndex = sequenceConstraint.length*2-1;
            
            //Sequence using dynamically built state size of 'length' variables
            id<ORMDDSpecs> mddStateSpecs = [ORFactory MDDSpecs: mdl variables:variables stateSize: sequenceConstraint.length*2];
            for (int index = minFirstIndex; index < minLastIndex; index++) {
                [mddStateSpecs addStateInt:index withDefaultValue:-1];
            }
            [mddStateSpecs addStateInt:minLastIndex withDefaultValue:0];
            for (int index = sequenceConstraint.length; index < maxLastIndex; index++) {
                [mddStateSpecs addStateInt:index withDefaultValue:-1];
            }
            [mddStateSpecs addStateInt:maxLastIndex withDefaultValue:0];
        
            id<ORExpr> arcExists = [[[ORFactory getStateValue:mdl lookup:1] eq:@(-1) track:mdl]
                                    lor: [[ORFactory expr: [[[ORFactory getStateValue:mdl lookup:maxLastIndex] sub: [ORFactory getStateValue:mdl lookup:minFirstIndex]] plus:[sequenceConstraint.countedValues contains:[ORFactory valueAssignment:mdl]] track:mdl] geq:[ORFactory integer:mdl value:sequenceConstraint.lower] track:mdl]
                                          land:
                                          [ORFactory expr: [[[ORFactory getStateValue:mdl lookup:minLastIndex] sub: [ORFactory getStateValue:mdl lookup:maxFirstIndex]] plus:[sequenceConstraint.countedValues contains:[ORFactory valueAssignment:mdl]] track:mdl] leq:[ORFactory integer:mdl value:sequenceConstraint.upper] track:mdl] track:mdl] track:mdl];
            
            
            [mddStateSpecs setArcExistsFunction: arcExists];
        
            for (int index = minFirstIndex; index < minLastIndex; index++) {
                id<ORExpr> transitionFunction = [ORFactory getStateValue:mdl lookup:(index+1)];
                [mddStateSpecs addTransitionFunction: transitionFunction toStateValue:index];   //Slide all to the left one
            }
            id<ORExpr> minLastIndexTransitionFunction = [[ORFactory getStateValue:mdl lookup:minLastIndex] plus:[sequenceConstraint.countedValues contains:[ORFactory valueAssignment:mdl]] track:mdl];
            [mddStateSpecs addTransitionFunction:minLastIndexTransitionFunction toStateValue:minLastIndex];
            
            for (int index = maxFirstIndex; index < maxLastIndex; index++) {
                id<ORExpr> transitionFunction = [ORFactory getStateValue:mdl lookup:(index+1)];
                [mddStateSpecs addTransitionFunction: transitionFunction toStateValue:index];
            }
            id<ORExpr> maxLastIndexTransitionFunction = [[ORFactory getStateValue:mdl lookup:maxLastIndex] plus:[sequenceConstraint.countedValues contains:[ORFactory valueAssignment:mdl]] track:mdl];
            [mddStateSpecs addTransitionFunction:maxLastIndexTransitionFunction toStateValue:maxLastIndex];
        
            for (int index = 0; index < sequenceConstraint.length; index++) {
                id<ORExpr> minRelaxationFunction = [ORFactory expr:[ORFactory getLeftStateValue:mdl lookup:minFirstIndex+index] min:[ORFactory getRightStateValue:mdl lookup:minFirstIndex+index] track:mdl];
                id<ORExpr> maxRelaxationFunction = [ORFactory expr:[ORFactory getLeftStateValue:mdl lookup:maxFirstIndex+index] max:[ORFactory getRightStateValue:mdl lookup:maxFirstIndex+index] track:mdl];
                [mddStateSpecs addRelaxationFunction: minRelaxationFunction toStateValue: (minFirstIndex + index)];
                [mddStateSpecs addRelaxationFunction: maxRelaxationFunction toStateValue: (maxFirstIndex + index)];
            }
                
            for (int index = minFirstIndex; index <= maxLastIndex; index++) {
                id<ORExpr> stateDifferential = [[[ORFactory getLeftStateValue:mdl lookup:index] sub:[ORFactory getRightStateValue:mdl lookup:index] track:mdl] absTrack:mdl];;
                [mddStateSpecs addStateDifferentialFunction:stateDifferential toStateValue:index];
            }
        
            [mdl add: mddStateSpecs];
        }*/
        
        /*//Sequence using an NSMutableArray
        typedef enum {
            countArray
        } SequenceState;
        
        
        id<ORMDDSpecs> mddStateSpecs = [ORFactory MDDSpecs: mdl variables:variables stateSize: 3];
        [mddStateSpecs addStateIntArray: countArray withDefaultValues: 0];
        
        id<ORExpr> arcExists = [[ORFactory expr: [[ORFactory getStateValue:mdl lookup:countArray arrayIndex:sequenceLastIndex1] sub: [ORFactory getStateValue:mdl lookup:countArray arrayIndex:zero]] geq:sequenceLower1 track:mdl]
                                land:
                                 [ORFactory expr: [[ORFactory getStateValue:mdl lookup:countArray arrayIndex:sequenceLastIndex1] sub: [ORFactory getStateValue:mdl lookup:countArray arrayIndex:zero]] leq:sequenceUpper1 track: mdl]];
        
        [mddStateSpecs setArcExistsFunction: arcExists];
        
        id<ORExpr> countArrayTransitionFunction = [[ORFactory copyIntArrayShiftedToLeft: [ORFactory getStateValue:mdl lookup:countArray] track:mdl] editIntArrayIndex:[sequenceLength1 sub:1 track:mdl] setTo:[[ORFactory getStateValue:mdl lookup:countArray] getIndexFromIntArray:[sequenceLength1 sub:1 track:mdl] track:mdl] track:mdl];
        [mddStateSpecs addTransitionFunction: countArrayTransitionFunction toStateValue: countArray];
        
        
        id<ORExpr> countArrayRelaxationFunction;
        [mddStateSpecs addRelaxationFunction: countArrayRelaxationFunction toStateValue: countArray];
        
        id<ORExpr> countArrayStateDifferential = zero;
        
        [mddStateSpecs addStateDifferentialFunction: countArrayStateDifferential toStateValue: countArray];
        
        [mdl add: mddStateSpecs];*/
        
        
        
        
        
        //AltMDD Sequence (that is, creating the sequence constraint via topdown and bottomup info
        
        
        
        id<ORIntVarArray> variables = [ORFactory intVarArray:mdl range: RANGE(mdl, 1, 10) domain: RANGE(mdl, 1, 5)];
        id<ORAltMDDSpecs> mddStateSpecs = [ORFactory AltMDDSpecs: mdl variables: variables];
        id<ORInteger> sequenceSize = [ORFactory integer:mdl value:5];
        [mddStateSpecs setBottomUpInformationAsMinMaxArrayWithSize:1 andDefaultValue:0];
        [mddStateSpecs setTopDownInformationAsMinMaxArrayWithSize:1 andDefaultValue:0];
        
        id<ORExpr> sizeOfTopDownArray = [ORFactory sizeOfArray:[ORFactory minParentInformation:mdl] track:mdl];
        id<ORExpr> sizeOfBottomUpArray = [ORFactory sizeOfArray:[ORFactory minChildInformation:mdl] track:mdl];
        id<ORExpr> lastIndexOfTopDownArray = [sizeOfTopDownArray sub:one track:mdl];
        id<ORExpr> lastIndexOfBottomUpArray = [sizeOfBottomUpArray sub:one track:mdl];
        
        
        id<ORExpr> edgeIsUsed;
        
        id<ORExpr> lastValueInMaxTopDown = [[ORFactory maxParentInformation:mdl] arrayIndex:lastIndexOfTopDownArray track:mdl];
        id<ORExpr> lastValueInMinTopDown = [[ORFactory minParentInformation:mdl] arrayIndex:lastIndexOfTopDownArray track:mdl];
        id<ORExpr> lastValueInMaxBottomUp = [[ORFactory maxChildInformation:mdl] arrayIndex:lastIndexOfBottomUpArray track:mdl];
        id<ORExpr> lastValueInMinBottomUp = [[ORFactory minChildInformation:mdl] arrayIndex:lastIndexOfBottomUpArray track:mdl];
        
        id<ORExpr> valueIsCounted = [countedValues1 contains:[ORFactory valueAssignment:mdl]];
        id<ORExpr> lowerMinusEdge = [lower1 sub:valueIsCounted track:mdl];
        id<ORExpr> upperMinusEdge = [upper1 sub:valueIsCounted track:mdl];
        
        
        //This is overkill.  Only need to check at 'end' of each sequence
        for (int amountOfSequenceInTopDown = [sequenceSize value] -1; amountOfSequenceInTopDown < [sequenceSize value]; amountOfSequenceInTopDown++) {
            id<ORExpr> amountOfSequenceInTopDownExpr = [ORFactory integer:mdl value:amountOfSequenceInTopDown];
            id<ORExpr> a = [[sizeOfTopDownArray sub:amountOfSequenceInTopDownExpr track:mdl] sub:one];
            id<ORExpr> c = [[sizeOfBottomUpArray sub:sequenceSize track:mdl] plus:amountOfSequenceInTopDownExpr track:mdl];
            //The top-down information is an array of min and max counts of counted values.  To find the used expressions
            
            id<ORExpr> aValueInMaxTopDown = [[ORFactory maxParentInformation:mdl] arrayIndex:a track:mdl];
            id<ORExpr> aValueInMinTopDown = [[ORFactory minParentInformation:mdl] arrayIndex:a track:mdl];
            id<ORExpr> cValueInMaxBottomUp = [[ORFactory maxChildInformation:mdl] arrayIndex:c track:mdl];
            id<ORExpr> cValueInMinBottomUp = [[ORFactory minChildInformation:mdl] arrayIndex:c track:mdl];
            
            //Edge Is Used when  a and c are in the scope of array AND the size of the highest possible seuqence count using this edge and those a,b values is greater than lower bound AND the size of the lowest possible sequence count using this edge and those a,b values is less then upper bound
            if (amountOfSequenceInTopDown == 0) {
                edgeIsUsed = [[[a geq:zero track:mdl] land: [c geq:zero track:mdl] track:mdl] land:
                                              [[[[lastValueInMaxTopDown sub:aValueInMinTopDown track:mdl] plus: [lastValueInMaxBottomUp sub:cValueInMinBottomUp track:mdl] track:mdl] geq:lowerMinusEdge track:mdl] land:
                                               [[[lastValueInMinTopDown sub:aValueInMaxTopDown track:mdl] plus: [lastValueInMinBottomUp sub:cValueInMaxBottomUp track:mdl] track:mdl] leq:upperMinusEdge track:mdl]                                                                                                                                                                                                               track:mdl] track:mdl];
            } else {
                edgeIsUsed = [edgeIsUsed lor:[[[a geq:zero track:mdl] land: [c geq:zero track:mdl] track:mdl] land:
                                              [[[[lastValueInMaxTopDown sub:aValueInMinTopDown track:mdl] plus: [lastValueInMaxBottomUp sub:cValueInMinBottomUp track:mdl] track:mdl] geq:lowerMinusEdge track:mdl] land:
                                               [[[lastValueInMinTopDown sub:aValueInMaxTopDown track:mdl] plus: [lastValueInMinBottomUp sub:cValueInMaxBottomUp track:mdl] track:mdl] leq:upperMinusEdge track:mdl]                                                                                                                                                                                                               track:mdl] track:mdl] track:mdl];
            }
        }
        
        id<ORExpr> deleteEdgeWhen = [edgeIsUsed negTrack:mdl];
        
        id<ORExpr> addEdgeToArray = [[ORFactory parentInformation:mdl] appendToArray:[[[ORFactory parentInformation:mdl] arrayIndex:[[ORFactory sizeOfArray:[ORFactory parentInformation:mdl] track:mdl] sub:@1 track:mdl] track:mdl] plus:[countedValues1 contains: [ORFactory valueAssignment:mdl]] track:mdl] track:mdl];
        
        [mddStateSpecs setEdgeDeletionCondition: deleteEdgeWhen];
        [mddStateSpecs setTopDownInfoEdgeAdditionMin:addEdgeToArray max:addEdgeToArray];
        [mddStateSpecs setBottomUpInfoEdgeAdditionMin:addEdgeToArray max:addEdgeToArray];
        [mddStateSpecs setInformationMergeToMinAndMaxArrays:mdl];
        
        [mdl add: mddStateSpecs];
        
        /*
         This was a different attempt of how to write deleteEdgeWhen.  Definitely worse than what's above.
         
         id<ORExpr> c_value_plus_a = [ORFactory expr:[ORFactory integer:mdl value:(int)[variables count]] sub:sequenceSize track:mdl];         //Could replace [variables count] with sizeOfTopDownArray + sizeOfBottomUpArray +1, but that seems too verbose --Actually this might not be right.  Need to check this.
         
        id<ORExpr> deleteEdgeWhen = [[ORFactory iterateOverRangeCombineWithOr:[ORFactory expr:zero min:[[sizeOfTopDownArray sub:sequenceSize track:mdl] plus:one track:mdl] track:mdl] to:sizeOfTopDownArray expression:
                                     [ORFactory ifExpr:[[[c_value_plus_a sub: ITERATOR track:mdl] geq: zero track:mdl] lor:[[c_value_plus_a sub:ITERATOR track:mdl] leq:d track:mdl] track:mdl] then:
                                      [[[[[ORFactory maxParentInformation] arrayIndex:lastIndexOfTopDownArray track:mdl] sub: [ORFactory minParentInformation] arrayIndex:ITERATOR track:mdl] plus: [[[ORFactory maxChildInformation] arrayIndex:lastIndexOfBottomUpArray track:mdl] sub:[[ORFactory minChildInformation] arrayIndex:[c_value_plus_a sub:ITERATOR track:mdl] track:mdl] track:mdl] geq:[lower1 sub:[countedValues1 contains:[ORFactory valueAssignment:mdl] track:mdl] track:mdl] track:mdl] land:
                                       [[[[[ORFactory minParentInformation] arrayIndex:lastIndexOfTopDownArray track:mdl] sub: [ORFactory maxParentInformation] arrayIndex:ITERATOR track:mdl] max:zero track:mdl] plus: [[[[ORFactory minChildInformation] arrayIndex:lastIndexOfBottomUpArray track:mdl] sub:[[ORFactory maxChildInformation] arrayIndex:[c_value_plus_a sub:ITERATOR track:mdl] track:mdl] track:mdl] max:zero track:mdl] leq:[upper1 sub:[countedValues1 contains:[ORFactory valueAssignment:mdl] track:mdl] track:mdl] track:mdl]]
                                            elseReturn:false] track:mdl] negate:mdl];*/
        /*TODO:  So logically, that deleteEdgeWhen "should" work.  It basically iterates over all ranges that use that edge and if it finds one that is able to use this edge, then it cannot delete the edge.  Still have the following stuff to do to make this functional though:
            1. Implement this "iterateOverRangeCombineWithOr" function.
            2. Extension of 1, but figure out how to represent this ITERATOR within iterateOverRangeCombineWithOr visitor functions.  Really not sure how this will work.
            3. Implement arrayIndex: track:. (should be easy)
            4. Implement maxParentInformation, minParentInformation, maxChildInformation, and minChildInformation.  Not clear how this will actually work?  Does the deleteEdge need to be a special one that is able to handle these min and max informations?  Current one just has a single parent and a single child.  Alternatively, make it so that parentInformation is an array of size 2, index 0 is min, index 1 is max (same with childInformation).  Make sure existing parentInformation and childInformation do not break because of this change.
          I think "that's it".  Last two should be fairly doable. The first one should be fine with the exception that I may need to re-evaluate that function depending on how #2 works.  That is my biggest concern right now.  How do we do an iterator within an ORExpr s.t. we can use the iterator value in the visitor AND do an OR expression over the results.  My first consideration was to do the iterating outside of the ORExpr and merely "build" a large ORExpr in main that would be a series of OR statements across all 'sequenceSize' checks.  The problem that keeps this from working is that this iterator itself needs to use a variable value that isn't known yet (changes on each layer of the MDD).  It's possible that there's a way we can specify how to BUILD the deleteEdgeWhen expression s.t. whenever it needs to use deleteEdgeWhen, it first calls deleteEdgeWhenBuilder which builds out this expression as specified, and THEN it can use deleteEdgeWhen.  This may prove to be more costly however and I'm not sure if this will simplify or just further complicate things.
         Oh, I'm also not positive b+d+1 is numVariables after all.  May be off by 1 or 2.  Should double-check this if we end up ever using this method of deleteEdgeWhen
        */
        
        
        ORLong startWC  = [ORRuntimeMonitor wctime];
        ORLong startCPU = [ORRuntimeMonitor cputime];
        
        [notes ddWidth:4];
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
            for (int i = 1; i <= [variables count]; i++) {
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
