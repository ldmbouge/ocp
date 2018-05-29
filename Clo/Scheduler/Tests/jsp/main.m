/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2013-14 NICTA, Andreas Schutt
 
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

// JSS instacne data
//
ORInt   n_mach = 0;		// (input) Number of machines
ORInt   n_job  = 0;		// (input) Number of jobs
ORInt   n_task = 0;		//         Number of tasks
ORInt * dur    = NULL;	// (input) Tasks' durations
ORInt * mach   = NULL;	// (input) Machines' ID
ORInt   mach_id_min = MAXINT;
ORInt   mach_id_max = MININT;
ORInt ** mach_task  = NULL;


// Freeing the allocated memory before exiting the program
//
void freeMemory() {
	if (dur  != NULL) free(dur ); 
	if (mach != NULL) free(mach);
    if (mach_task != NULL) {
        for (ORInt m = 0; m < n_mach; m++) {
            if (mach_task[m] != NULL) free(mach_task[m]);
        }
        free(mach_task);
    }
}

// Functions for index manipulations
//
int get_index(int n_mach, int job, int task) { return job * n_mach + task; }

int get_job_from_index(int index) { return index / n_mach; }
int get_task_from_index(int index) { return index % n_mach; }

void get_job_and_task_from_index(int index, int * job, int * task) {
	*job  = get_job_from_index( index);
	*task = get_task_from_index(index);
}

// Reading the data from a file. This data must be given in RCP format.
//
void readDataJSS(const char * filename) {
	ORInt check;
	char temp[INPUTLENGTH], * s;
	FILE* fp = NULL;

	//printf("Entering readDataRCP\n");

		// Open the file stream
	fp = fopen(filename, "r");
	assert(fp);

		// Reading the number of activities and resources
		//
	check = fscanf(fp, "%d %d\n", &n_job, &n_mach);
	if (check != 2) {
		fprintf(stderr, "Error while parsing for the number of activities and resources!\n");
		fclose(fp);
		exit(1);
	}

	n_task = n_job * n_mach;
    
//    printf("n_job %d; n_mach %d; n_task %d;\n", n_job, n_mach, n_task);

		// Allocating memory
		//
	dur	        = (ORInt * ) malloc(n_task * sizeof(ORInt  ));
	mach        = (ORInt * ) malloc(n_task * sizeof(ORInt  ));
    mach_task   = (ORInt **) malloc(n_mach * sizeof(ORInt *));

	if (dur == NULL || mach == NULL || mach_task == NULL) {
		fprintf(stderr, "Error while allocating memory!\n");
		freeMemory();
		fclose(fp);
		exit(1);
	} else {
        // Allocating further memory
        //
        for (ORInt m = 0; m < n_mach; m++) {
            mach_task[m] = (ORInt *) malloc(n_job * sizeof(ORInt));
            if (mach_task[m] == NULL) {
                fprintf(stderr, "Error while allocating memory!\n");
                freeMemory();
                fclose(fp);
                exit(1);
            } else {
                // Initialising allocated memory
                for (ORInt j = 0; j < n_job; j++) {
                    mach_task[m][j] = -1;
                }
            }
        }
        
		// Initialise allocated memory
		//
		for (ORInt t = 0; t < n_task; t++) {
			dur [t] = -1;
			mach[t] = -1;
		}
	}

		// Reading the job specifications
		//
	for (ORInt j = 0; j < n_job; j++) {
        
		if (fgets(temp, INPUTLENGTH, fp) == NULL) {
			fprintf(stderr, "Error while parsing the specification of job %d!\n", j);
			freeMemory();
			fclose(fp);
			exit(1);
		}
        
//        printf("Reading job %d;\n", j);

			// Parsing the tasks' specifications
			//
		for (ORInt t = 0; t < n_mach; t++) {
			ORInt idx = get_index(n_mach, j, t);
				// Reading the machine ID
				//
			if (t == 0)
				s = strtok(temp, " \t\n");
			else
				s = strtok(NULL, " \t\n");
			mach[idx] = atoi(s);

				// Reading the duration
				//
			s = strtok(NULL, " \t\n");
			dur[idx] = atoi(s);
//            printf("\ttask %d; idx %d; mach %d; dur %d\n", t, idx, mach[idx], dur[idx]);
		}
	}
		// Closing the file stream
	fclose(fp);
}

void preprocessData(void) {
    for (ORInt t = 0; t < n_task; t++) {
        mach_id_min = min(mach_id_min, mach[t]);
        mach_id_max = max(mach_id_max, mach[t]);
    }
//    printf("min %d; max %d; no %d;\n", mach_id_min, mach_id_max, n_mach);

    if (mach_id_max - mach_id_min + 1 != n_mach) {
        printf("Range of machines' ids is not equal to the number of machines!");
        freeMemory();
        exit(2);
    }
    
    ORInt * n_mach_task = (ORInt *) alloca(n_mach * sizeof(ORInt));
    for (ORInt m = 0; m < n_mach; m++) n_mach_task[m] = 0;
    for (ORInt j = 0; j < n_job; j++) {
        for (ORInt t = 0; t < n_mach; t++) {
            const ORInt idx = get_index(n_mach, j, t);
            const ORInt m = mach[idx] - mach_id_min;
            const ORInt c = n_mach_task[m];
            mach_task[m][c] = idx;
            n_mach_task[m]++;
        }
        // Check whether the job has exactly one task per machine
        for (ORInt m = 0; m < n_mach; m++) {
            if (j + 1 != n_mach_task[m]) {
                printf("Job %d has not exactly one task on machine %d!\n", j, m + mach_id_min);
                freeMemory();
                exit(2);
            }
        }
    }
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
	readDataJSS(argv[1]);
    
    preprocessData();

    // Global difference logic propagator for the precedence constraints
    // NOTE: The implementation of the global difference propagator is not
    // finished yet.
    ORBool globalDiff = TRUE;
    globalDiff = FALSE;
    
	ORInt ms_max = 0;
    for (ORInt t = 0; t < n_task; t++) {
        ms_max += dur[t];
    }

//	printf("n_job  = %d;\n", n_job);
//	printf("n_mach = %d;\n", n_mach);
//	printf("n_task = %d;\n", n_task);

	@autoreleasepool {
      
    	id<ORModel> model = [ORFactory createModel];
      	id<ORIntRange> dom   = [ORFactory intRange: model low: 0 up: ms_max    ];
      	id<ORIntRange> Tasks = [ORFactory intRange: model low: 0 up: n_task - 1];
//      	id<ORIntRange> Jobs  = [ORFactory intRange: model low: 0 up: n_job  - 1];
      	id<ORIntRange> Mach  = [ORFactory intRange: model low: 0 up: n_mach  - 1];
        
        id<ORTaskVarArray> TaskVar = [ORFactory taskVarArray: model range: Tasks with: ^id<ORTaskVar>(ORInt k) {
            return [ORFactory task: model horizon:dom duration:dur[k]];
        }];
        id<ORTaskDisjunctiveArray> disjunctive = [ORFactory disjunctiveArray: model range: Mach];
        
//      	id<ORIntVarArray> start = [ORFactory intVarArray: model range: Tasks domain: dom];
//		id<ORIntVarArray> dura  = [ORFactory intVarArray: model range: Tasks with: ^id<ORIntVar>(ORInt k) {
//            id<ORIntRange> singleton = [ORFactory intRange: model low: dur[k] up: dur[k]];
//            return [ORFactory intVar: model domain: singleton];
//        }];
		id<ORIntVar> MS = [ORFactory intVar: model domain: dom];
        ORInt nbDiff = (globalDiff == TRUE ? n_job * n_mach * (n_mach - 1) / 2 : 0);
        id<ORDifference> diff = (globalDiff == TRUE ? [ORFactory difference:model initWithCapacity:nbDiff] : NULL);
        
        if (globalDiff == TRUE) {
            [model add:diff];
        }
        
	  	// Adding precedence constraints
		for (ORInt j = 0; j < n_job; j++) {
			for (ORInt t1 = 0, t2 = 1; t2 < n_mach; t1++, t2++) {
				ORInt idx1 = get_index(n_mach, j, t1);
				ORInt idx2 = get_index(n_mach, j, t2);
                if (globalDiff == TRUE) {
//                    [model add: [ORFactory diffLEqual: diff var: start[idx1] to: start[idx2] plus: -dur[idx1]]];
                }
                else {
                    [model add: [TaskVar[idx1] precedes: TaskVar[idx2]]];
//                    [model add: [ORFactory lEqual: model var: start[idx1] to: start[idx2] plus: -dur[idx1]]];
                }
			}
		}

        // Adding resource constraints
        for (ORInt m = 0; m < n_mach; m++) {
            for (ORInt j = 0; j < n_job; j++) {
                [disjunctive[m] add: TaskVar[mach_task[m][j]]];
            }
            [model add: disjunctive[m]];
//            id<ORIntVarArray> m_start = [ORFactory intVarArray: model range: Jobs with: ^id<ORIntVar>(ORInt k) {
//                return start[mach_task[m][k]];
//            }];
//            id<ORIntVarArray> m_dura = [ORFactory intVarArray: model range: Jobs with: ^id<ORIntVar>(ORInt k) {
//                return dura[mach_task[m][k]];
//            }];
//            [model add: [ORFactory disjunctive: m_start duration: m_dura]];
        }
        
		// Adding objective constraints
		for (ORInt j = 0; j < n_job; j++) {
			ORInt idx = get_index(n_mach, j, n_mach - 1);
            if (globalDiff == TRUE) {
//                [model add: [ORFactory diffLEqual: diff var: start[idx] to: MS plus: -dur[idx]]];
            }
            else {
                [model add: [TaskVar[idx] isFinishedBy: MS]];
//                [model add: [ORFactory lEqual: model var: start[idx] to: MS plus: -dur[idx]]];
            }
		}
        
//        id<ORIntRange> RAllVars = [ORFactory intRange: model low: 0 up: n_task];
//        id<ORIntVarArray> allVars = [ORFactory intVarArray: model range: RAllVars with: ^id<ORIntVar>(ORInt k) {
//            if (k < n_task)
//                return start[k];
//            else
//                return MS;
//        }];

        // Adding objective
        [model minimize: MS];

		// Solving
		id<CPProgram,CPScheduler> cp = (id)[ORFactory createCPProgram: model];
		[cp solve:
			^() {
				// Search strategy
				[cp setTimes: TaskVar];
                [cp label: MS];
				// Output of solution
				printf("start = [|\n\t");
				for (ORInt t = 0; t < n_task; t++) {
                    if (t > 0 && t % n_mach == 0) printf("\n\t");
					if (t % n_mach > 0) printf(", ");
					printf("%2d", [cp est: TaskVar[t]]);
				}
				printf("];\n");
                for (ORInt m = 0; m < n_mach; m++) {
                    printf("%%%% mach %d: ", m + mach_id_min);
                    for (ORInt k = 0; k < n_job; k++) {
                        const ORInt t = mach_task[m][k];
                        printf("[%2d, %2d) ", [cp est: TaskVar[t]], [cp lct: TaskVar[t]]);
                    }
                    printf("\n");
                }
                printf("objective = %d;\n", [cp intValue: MS]);
                printf("----------\n");
			}
		];
     
        printf("==========\n");
        NSString* str = [cp description];
        printf("%%%% Solver status: %s\n", [str UTF8String]);
//     	NSLog(@"Solver status: %@\n",cp);
     	NSLog(@"Quitting");
   	}
  
	freeMemory();
    
   	return 0;
}


