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

int findMISP(bool** adjacencies, id<ORIntArray> weights, int variable, bool* solution) {
    if (variable <= MAX) {
        int valueWithoutVariable = findMISP(adjacencies, weights, variable+1, solution);
        
        bool canChooseVariable = true;
        for (int index = MIN; index <= variable; index++) {
            if (adjacencies[index][variable] && solution[index]) {
                canChooseVariable = false;
                break;
            }
        }
        if (canChooseVariable) {
            solution[variable] = true;
            int valueWithVariable = findMISP(adjacencies, weights, variable+1, solution);
            solution[variable] = false;
            if (valueWithVariable > valueWithoutVariable) {
                return valueWithVariable;
            }
        }
        return valueWithoutVariable;
    } else {
        int value = 0;
        for (int index = MIN; index <= MAX; index++) {
            if (solution[index]) {
                value += [weights at: index];
            }
        }
        return value;
    }
}

void verifyMISP(bool** adjacencies, id<ORIntArray> weights) {
    bool* solution = malloc((MAX-MIN+1) * sizeof(bool));
    solution -= MIN;
    
    for (int variable = MIN; variable <= MAX; variable++) {
        solution[variable] = false;
    }
    
    printf("Actual best value: %d\n", findMISP(adjacencies, weights, MIN, solution));
    
    return;
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
        ORInt layerSize = 1000;
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

        NSString *filepath = @"/Users/ben/Downloads/DIMACS_cliques/brock200_4.clq";
        
        FILE *file = fopen([filepath UTF8String], "r");
        char buffer[256];
        while(fgets(buffer, sizeof(char)*256,file) != NULL) {
            NSString* line = [NSString stringWithUTF8String:buffer];
            if([line characterAtIndex:0] == 'e') {
                line = [line substringFromIndex:2];
                NSInteger first = [[line substringToIndex: [line rangeOfString:@" "].location] integerValue];
                line = [line substringFromIndex:[line rangeOfString:@" "].location];
                NSInteger second = [line integerValue];
                
                adjacencies[first][second] = true;
                adjacencies[second][first] = true;
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
        
        printf("Verifying answer...\n");
        
        //verifyMISP(adjacencies, weights);

        printf("GOT %d solutions\n",[nbSolutions intValue:cp]);
        NSLog(@"Solver status: %@\n",cp);
        NSLog(@"Quitting");
    }
    
    return 0;
}
