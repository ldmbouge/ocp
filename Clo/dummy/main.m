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
double DENSITY = .5;

//.1 ~ 260 CPU
//.2 ~ 240 CPU
//.3 ~ 215 CPU
//.4 ~ 200 CPU
//.5 ~ 190 CPU
//.6 ~ 180 CPU
//.7 ~ 170 CPU
//.8 ~ 160 CPU
//.9 ~ 150 CPU


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

int findMISP(bool** adjacencies, NSMutableArray* edgeA, NSMutableArray* edgeB) {
    printf("Verifying answer...\n");
    
    bool* solution = malloc((MAX-MIN+1) * sizeof(bool));
    solution -= MIN;
    
    for (int variable = MIN; variable <= MAX; variable++) {
        solution[variable] = true;
    }
    
    int maxNumSelected = 0;
    int numSelected = MAX-MIN+1;
    int legal;
    
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
    
    /*if (variable <= MAX) {
        int valueWithoutVariable = findMISP(adjacencies, weights, variable+1, solution);
        
        bool canChooseVariable = true;
        for (int index = MIN; index < variable; index++) {
            if (adjacencies[index][variable] && solution[index]) {
                canChooseVariable = false;
                break;
            }
        }
        if (canChooseVariable) {
            solution[variable] = true;
            int valueWithVariable = findMISP(adjacencies, weights, variable+1, solution) + [weights at: variable];
            if (valueWithVariable > valueWithoutVariable) {
                return valueWithVariable;
            }
            solution[variable] = false;
        }
        return valueWithoutVariable;
    } else {
        return 0;
    }*/
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
        /*NSArray* emptyEdges = [[NSArray alloc] init];
         NSArray* oneEdge = @[@[[NSNumber numberWithInt:MIN], [NSNumber numberWithInt:MIN+2]]];
         NSArray* edges = @[@[[NSNumber numberWithInt:MIN], [NSNumber numberWithInt:MAX]],
         @[[NSNumber numberWithInt:MIN+1], [NSNumber numberWithInt:MAX-1]]];*/
        
        id<ORModel> mdl = [ORFactory createModel];
        id<ORIntRange> R1 = RANGE(mdl, MIN, MAX);
        id<ORIntRange> R2 = RANGE(mdl, 0, 1);
        id<ORIntVarArray> a = [ORFactory intVarArray: mdl range: R1 domain: R2];
        id<ORMutableInteger> nbSolutions = [ORFactory mutable: mdl value: 0];
        ORInt layerSize = 100000;
        bool reduced = true;
        
        
        //bool** adjacencies = randomAdjacencyMatrix();
        bool** adjacencies;
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
        
        NSString *filepath = @"/Users/ben/Downloads/DIMACS_cliques/brock200_2.clq";
        
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
                //NSLog(@"%d to %d\n",first, second);
            }
        }
        
        
        
        
        
        
        id<ORIntArray> weights = [ORFactory intArray: mdl range: R1 value: 0];
        int maxSum = 0;
        for(ORInt vertex = MIN; vertex <= MAX; vertex++) {
            ORInt weight;
            //weight = arc4random_uniform(5)+1;
            weight = 1;
            [weights set: weight at: vertex];
            
            maxSum += weight;
        }
        
        id<ORIntVar> totalWeight = [ORFactory intVar: mdl domain: RANGE(mdl, 0, maxSum)];
        
        [mdl add: [ORFactory RelaxedMDDMISP:mdl var:a size:layerSize reduced:reduced adjacencies:adjacencies weights:weights objective:totalWeight]];
        //[mdl add: [ORFactory ExactMDDMISP:mdl var:a reduced:reduced adjacencies:adjacencies weights:weights objective:totalWeight]];
        
        [mdl maximize: totalWeight];
        
        id<CPProgram> cp = [ORFactory createCPProgram:mdl];
        ORLong startWC  = [ORRuntimeMonitor wctime];
        ORLong startCPU = [ORRuntimeMonitor cputime];
        
        [cp solve: ^{
            
            [cp labelArray: a];
            
            for (int i = MIN; i <= MAX; i++) {
              printf("%d  ",[cp intValue: [a at:i]]);
            }
            //printf("  |  Objective value: %d", [cp intValue: totalWeight]);
            printf("\n");
            [nbSolutions incr: cp];
            
        }
         ];
        
        ORLong endWC  = [ORRuntimeMonitor wctime];
        ORLong endCPU = [ORRuntimeMonitor cputime];
        
        printf("CPU: %d\n", endCPU - startCPU);
        printf("WC: %d\n", endWC - startWC);
        
        //findMISP(adjacencies, edgeA, edgeB);

        printf("GOT %d solutions\n",[nbSolutions intValue:cp]);
        NSLog(@"Solver status: %@\n",cp);
        NSLog(@"Quitting");
    }

    return 0;
}
