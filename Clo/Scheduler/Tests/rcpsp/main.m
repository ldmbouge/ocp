/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2013 NICTA, Andreas Schutt
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <ORModeling/ORModeling.h>
#import <ORProgram/ORProgram.h>
#import <ORScheduler/ORScheduler.h>
#import <ORSchedulingProgram/ORSchedulingProgram.h>



	// Maximal input length of the char vector for reading a line in the data file
#define INPUTLENGTH 50000

// RCPSP instacne data
//
ORInt n_res    = 0;		// (input) Number of resources
ORInt * rcap   = NULL;	// (input) Resource capacities

ORInt n_act    = 0;		// (input) Number of activities
ORInt * dur    = NULL;	// (input) Activities' durations
ORInt ** rr    = NULL;	// (input) Activities' resource requirements
ORInt * n_succ = NULL;	// (input) Activities' number of successors
ORInt ** succ  = NULL;	// (input) Activities' successors

// Freeing the allocated memory before exiting the program
//
void freeMemory() {
	ORInt i;

	if (rcap != NULL) free(rcap);
	if (dur != NULL) free(dur);
	if (rr != NULL) {
		for (i = 0; i < n_res; i++) {
			if (rr[i] != NULL) free(rr[i]);
		}
		free(rr);
	}
	if (n_succ != NULL) free(n_succ);
	if (succ != NULL) {
		for (i = 0; i < n_act; i++) {
			if (succ[i] != NULL) free(succ[i]);
		}
		free(succ);
	}
}

// Reading the data from a file. This data must be given in RCP format.
//
void readDataRCP(const char * filename) {
	ORInt check;
	char temp[INPUTLENGTH], * s;
	FILE* fp = NULL;

	//printf("Entering readDataRCP\n");

		// Open the file stream
	fp = fopen(filename, "r");
	assert(fp);

		// Reading the number of activities and resources
		//
	check = fscanf(fp, "%d %d\n", &n_act, &n_res);
	if (check != 2) {
		fprintf(stderr, "Error while parsing for the number of activities and resources!\n");
		fclose(fp);
		exit(1);
	}

		// Allocating memory
		//
	rcap        = (ORInt   * ) malloc(n_res * sizeof(ORInt    ));
	dur         = (ORInt   * ) malloc(n_act * sizeof(ORInt    ));
	n_succ      = (ORInt   * ) malloc(n_act * sizeof(ORInt    ));
	succ        = (ORInt   **) malloc(n_act * sizeof(ORInt   *));
	rr          = (ORInt   **) malloc(n_res * sizeof(ORInt   *));

	if (rcap == NULL || dur == NULL || rr == NULL ||
		succ == NULL || n_succ == NULL
	) {
		fprintf(stderr, "Error while allocating memory!\n");
		freeMemory();
		fclose(fp);
		exit(1);
	} else {
		// Initialise allocated memory
		//
		for (ORInt i = 0; i < n_res; i++) {
			rcap[i] = -1;
			rr[i]   = NULL;
		}
		for (ORInt i = 0; i < n_act; i++) {
			dur[i]    = -1;
			n_succ[i] = -1;
			succ[i]   = NULL;
		}
	}

	for (ORInt i = 0; i < n_res; i++) {
		rr[i] = (ORInt *) malloc(n_act * sizeof(ORInt));
		if (rr[i] == NULL) {
			fprintf(stderr, "Error while allocating memory!\n");
			freeMemory();
			fclose(fp);
			exit(1);
		} else {
			// Initialise allocated memory
			//
			for (ORInt j = 0; j < n_act; j++) rr[i][j] = -1;
		}
	}

		// Reading the resource capacities
		//
	if (fgets(temp, INPUTLENGTH, fp) == NULL) {
		fprintf(stderr, "Error while parsing for the resource capacities!\n");
		freeMemory();
		fclose(fp);
		exit(1);
	}
	s = strtok(temp, " \t\n");
	for (ORInt i = 0; i < n_res; i++) {
		rcap[i] = atoi(s);
		if (i != n_res - 1) s = strtok(NULL, " \t\n");
	}

	for (ORInt i = 0; i < n_act; i++) {

			// Reading the activities specifications
			//
		if (fgets(temp, INPUTLENGTH, fp) == NULL) {
			fprintf(stderr, "Error while parsing for the activity identificator!\n");
			freeMemory();
			fclose(fp);
			exit(1);
		}
			// Reading the activity durations
			//
		s = strtok(temp, " \t\n");
		dur[i] = atoi(s);

			// Reading the resource requirements
			//
		for (ORInt j = 0; j < n_res; j++) {
			s = strtok(NULL, " \t\n");
			rr[j][i] = atoi(s);
		}   
	
			// Reading the number of successors
			//
		s = strtok(NULL, " \t\n");
		n_succ[i] = atoi(s);
			// Allocating memory
			//
		if (n_succ[i] != 0) {
			succ[i] = (ORInt *) malloc(n_succ[i] * sizeof(ORInt));
			if (succ[i] == NULL) {
				fprintf(stderr, "Error while allocating memory!\n");
				freeMemory();
				fclose(fp);
				exit(1);
			} else {
				// Initialise allocated memory
				//
				for (ORInt j = 0; j < n_succ[i]; j++) succ[i][j] = -1;
			}
			for (ORInt j = 0; j < n_succ[i]; j++) {
				s = strtok(NULL, " \t\n");
				succ[i][j] = atoi(s) - 1;
			}
		} else {
			succ[i] = NULL;
		}
	}
		// Closing the file stream
	fclose(fp);
	
	//printf("Leaving readDataRCP\n");
}

bool file_exists(const char * filename)
{
    FILE * file = fopen(filename, "r");
    if (file != NULL) {
        fclose(file);
        return true;
    }
    return false;
}

int main(int argc, const char * argv[])
{
    // Check whether the number of input arguments is correct
	if (argc < 2) {
		printf("Usage: <exe> <file>\n");
		exit(1);
	}
    
    // Check whether the second input argument is an existing file
    if (!file_exists(argv[1])) {
        printf("File '%s' does not exist!\n", argv[1]);
        exit(2);
    }

	// Read input
	readDataRCP(argv[1]);

	ORInt ms_max = 0;
	for (ORInt i = 0; i < n_act; i++)
		ms_max += dur[i];

	printf("n_act = %d;\n", n_act);
	printf("n_res = %d;\n", n_res);

	@autoreleasepool {
      
    	id<ORModel> model = [ORFactory createModel];
      	id<ORIntRange> dom = [ORFactory intRange: model low: 0 up: ms_max];
      	id<ORIntRange> R = [ORFactory intRange: model low: 0 up: n_act - 1];
        id<ORIntVar> makespan = [ORFactory intVar: model domain: dom];
        
        id<ORTaskVarArray> Tasks = [ORFactory taskVarArray: model range: R with: ^id<ORTaskVar>(ORInt k) {
            return [ORFactory task: model horizon: dom duration: dur[k]];
        }];
      
	  	// Adding precedence constraints
		for (ORInt i = 0; i < n_act; i++) {
			for (ORInt jj = 0; jj < n_succ[i]; jj++) {
				const ORInt j = succ[i][jj];
				//printf("Add constraint: s[%d] <= s[%d] - %d\n", i, j, dur[i]);
                [model add: [Tasks[i] precedes:Tasks[j]]];
			}
            if (n_succ[i] == 0) {
                [model add: [Tasks[i] isFinishedBy: makespan]];
            }
		}

		// Adding resource constraints
        for (ORInt r = 0; r < n_res; r++) {
            id<ORIntVar> RCap = [ORFactory intVar: model value: rcap[r]];
            id<ORTaskCumulative> cumulative = [ORFactory cumulativeConstraint: RCap];
            //printf("Add constraint: cumulative(start, dur, rr, %d)\n", rcap[r]);
            for (ORInt i = 0; i < n_act; i++) {
                if (rr[r][i] > 0) {
                    id<ORIntVar> rr_i = [ORFactory intVar: model value: rr[r][i]];
                    [cumulative add:Tasks[i] with:rr_i];
                }
            }
            [model add: cumulative];
        }
        
        // Adding objective
        [model minimize: makespan];

		// Solving
		id<CPProgram,CPScheduler> cp = [ORFactory createCPProgram: model];
		[cp solve:
			^() {
				// Search strategy
				[cp setTimes: Tasks];
                [cp label: makespan];
				// Output of solution
				printf("start = [");
				for (ORInt i = 0; i < n_act; i++) {
                    if (i > 0) printf(", ");
					printf("%d", [cp est: Tasks[i]]);
				}
				printf("];\n");
				printf("dur = [");
				for (ORInt i = 0; i < n_act; i++) {
                    if (i > 0) printf(", ");
					printf("%d", dur[i]);
				}
				printf("];\n");
                printf("objective = %d;\n", [cp intValue: makespan]);
                printf("----------\n");
			}
		];
     
        printf("==========\n");
        NSString* str = [cp description];
        printf("%%%% Solver status: %s\n", [str UTF8String]);
//     	NSLog(@"Solver status: %@\n",cp);
     	NSLog(@"Quitting");
     	[cp release];
	 	[ORFactory shutdown];
   	}
  
	freeMemory();
    
   	return 0;
}


