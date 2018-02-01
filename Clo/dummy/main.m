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

int MIN = 1;
int MAX = 5;

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

int main (int argc, const char * argv[])
{
    @autoreleasepool {
        //ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];

        id<ORModel> mdl = [ORFactory createModel];
        id<ORIntRange> R1 = RANGE(mdl, MIN, MAX);
        id<ORIntRange> R2 = RANGE(mdl, 0, 1);
        id<ORIntVarArray> a = [ORFactory intVarArray: mdl range: R1 domain: R2];
        id<ORMutableInteger> nbSolutions = [ORFactory mutable: mdl value: 0];
        ORInt layerSize = 8;
        bool reduced = true;
  
        //[mdl add: [ORFactory ExactMDDAllDifferent: mdl var: a reduced:reduced]];
        //[mdl add: [ORFactory RestrictedMDDAllDifferent:mdl var:a size:layerSize reduced:reduced]];
        //[mdl add: [ORFactory RelaxedMDDAllDifferent:mdl var:a size:layerSize reduced:reduced]];
        
        NSArray* emptyEdges = [[NSArray alloc] init];
        NSArray* oneEdge = @[@[[NSNumber numberWithInt:MIN], [NSNumber numberWithInt:MIN+1]]];
        NSArray* edges = @[@[[NSNumber numberWithInt:MIN], [NSNumber numberWithInt:MAX]],
                           @[[NSNumber numberWithInt:MIN+1], [NSNumber numberWithInt:MAX-1]]];
        
        bool** adjacencies = adjacencyMatrix(&oneEdge, false);
        
        
        [mdl add: [ORFactory ExactMDDMISP:mdl var:a reduced:reduced adjacencies:adjacencies]];
        
        id<CPProgram> cp = [ORFactory createCPProgram:mdl];
        
        [cp solveAll: ^{
            //[cp label: [a at: MIN+2] with: MIN];
            //[cp label: [a at: MIN] with: MIN+1];
            //[cp label: [a at: MIN+2] with: MIN+2];
            //[cp label: [a at: MIN+3] with: MIN+3];
            //[cp label: [a at: MIN+4] with: MIN+4];
            //[cp label: [a at: MIN+5] with: MIN+5];
            //[cp label: [a at: MIN+6] with: MIN+6];
            
            [cp labelArray: a];

            for (int i = MIN; i <= MAX; i++) {
              printf("%d  ",[cp intValue: [a at:i]]);
            }
            printf("\n");
            [nbSolutions incr: cp];
        }
         ];
        
        printf("GOT %d solutions\n",[nbSolutions intValue:cp]);
        NSLog(@"Solver status: %@\n",cp);
        NSLog(@"Quitting");
    }
    return 0;
}
