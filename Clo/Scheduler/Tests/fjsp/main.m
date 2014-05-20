/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2014 NICTA, Andreas Schutt
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <ORModeling/ORModeling.h>
#import <ORProgram/ORProgram.h>
#import <ORScheduler/ORScheduler.h>


	// Maximal input length of the char vector for reading a line in the data file
#define INPUTLENGTH 50000

// FJSS instacne data
//
ORInt   n_mach = 0;		// (input) Number of machines
ORInt   n_job  = 0;		// (input) Number of jobs
ORInt   n_act  = 0;		//         Number of activities
ORInt   n_opt  = 0;     //         Number of optional activities
ORInt * dur    = NULL;	// (input) Optional activities' durations
ORInt * mach   = NULL;	// (input) Machines' ID

ORInt *  job_nact  = NULL;  // Number of activities per job
ORInt *  job_fact  = NULL;  // Index of first activity in job
ORInt *  act_nopt  = NULL;  // Number of optional activities in activity
ORInt *  act_fopt  = NULL;  // Index of first optional activity per activity
ORInt *  opt_act   = NULL;  // Mapping of optional activities to their activities
ORInt *  mach_nopt = NULL;  // Number of optional activities per machine
ORInt ** mach_opt  = NULL;  // Optional activities per machine

ORInt mach_id_min = MAXINT;
ORInt mach_id_max = MININT;

// Freeing the allocated memory before exiting the program
//
void freeMemory() {
	if (dur       != NULL) free(dur      );
	if (mach      != NULL) free(mach     );
    if (mach_nopt != NULL) free(mach_nopt);
    if (job_nact  != NULL) free(job_nact );
    if (job_fact  != NULL) free(job_fact );
    if (act_nopt  != NULL) free(act_nopt );
    if (act_fopt  != NULL) free(act_fopt );
    if (opt_act   != NULL) free(opt_act  );
    
    if (mach_opt != NULL) {
        for (ORInt m = 0; m < n_mach; m++) {
            if (mach_opt[m] != NULL) free(mach_opt[m]);
        }
        free(mach_opt);
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
void readDataFJSS(const char * filename) {
	char temp[INPUTLENGTH], * s;
	FILE* fp = NULL;

		// Open the file stream
	fp = fopen(filename, "r");
	assert(fp);

		// Reading the number of jobs and resources
		//
    if (fgets(temp, INPUTLENGTH, fp) == NULL) {
        fprintf(stderr, "Error while parsing the number of jobs and resources!\n");
        freeMemory();
        fclose(fp);
        exit(1);
    }
    s = strtok(temp, " \t\n");
    n_job = atoi(s);
    s = strtok(NULL, " \t\n");
    n_mach = atoi(s);
    

        // Calculating the number of optional activities
        //
    for (ORInt j = 0; j < n_job; j++) {
        if (fgets(temp, INPUTLENGTH, fp) == NULL) {
            fprintf(stderr, "Error while parsing the number of jobs and resources!\n");
            freeMemory();
            fclose(fp);
            exit(1);
        }
        s = strtok(temp, " \t\n");
        const ORInt n_act_j = atoi(s);
        n_act += n_act_j;
        ORInt n_opt_j = 0;
        for (ORInt t = 0; t < n_act_j; t++) {
            s = strtok(NULL, " \t\n");
            const ORInt k = atoi(s);
            n_opt_j += k;
            for (ORInt i = 0; i < 2 * k; i++) s = strtok(NULL, " \t\n");
        }
        n_opt += n_opt_j;
    }

//    printf("#mach %d; #job %d; #act %d; #opt %d\n", n_mach, n_job, n_act, n_opt);
    
        // Allocating memory
        //
    dur      = (ORInt *) malloc(n_opt * sizeof(ORInt));
    mach     = (ORInt *) malloc(n_opt * sizeof(ORInt));
    opt_act  = (ORInt *) malloc(n_opt * sizeof(ORInt));
    act_nopt = (ORInt *) malloc(n_act * sizeof(ORInt));
    act_fopt = (ORInt *) malloc(n_act * sizeof(ORInt));
    job_nact = (ORInt *) malloc(n_job * sizeof(ORInt));
    job_fact = (ORInt *) malloc(n_job * sizeof(ORInt));

    if (dur == NULL || mach == NULL || opt_act == NULL || act_nopt == NULL || act_fopt == NULL || job_nact == NULL || job_fact == NULL) {
		fprintf(stderr, "Error while allocating memory!\n");
		freeMemory();
		fclose(fp);
		exit(1);
	}
    
        // Set the file pointer to the beginning
        //
    rewind(fp);
    
    if (fgets(temp, INPUTLENGTH, fp) == NULL) {
        fprintf(stderr, "Error while parsing the number of jobs and resources!\n");
        freeMemory();
        fclose(fp);
        exit(1);
    }

    ORInt o = 0;
    ORInt t = 0;
    for (ORInt j = 0; j < n_job; j++) {
        if (fgets(temp, INPUTLENGTH, fp) == NULL) {
            fprintf(stderr, "Error while parsing the number of jobs and resources!\n");
            freeMemory();
            fclose(fp);
            exit(1);
        }
        s = strtok(temp, " \t\n");
        job_nact[j] = atoi(s);
        job_fact[j] = t;
        for (ORInt i = 0; i < job_nact[j]; i++) {
            s = strtok(NULL, " \t\n");
            act_nopt[t] = atoi(s);
            act_fopt[t] = o;
            for (ORInt k = 0; k < act_nopt[t]; k++) {
                s = strtok(NULL, " \t\n");
                mach[o] = atoi(s);
                s = strtok(NULL, " \t\n");
                dur [o] = atoi(s);
                opt_act[o] = t;
                o++;
            }
            t++;
        }
    }

		// Closing the file stream
	fclose(fp);
}

void preprocessData(void) {
    for (ORInt o = 0; o < n_opt; o++) {
        mach_id_min = min(mach_id_min, mach[o]);
        mach_id_max = max(mach_id_max, mach[o]);
    }

    if (mach_id_max - mach_id_min + 1 != n_mach) {
        printf("Range of machines' ids is not equal to the number of machines!");
        freeMemory();
        exit(2);
    }

    ORInt mach_copt[n_mach];
    mach_nopt = (ORInt * ) malloc(n_mach * sizeof(ORInt  ));
    mach_opt  = (ORInt **) malloc(n_mach * sizeof(ORInt *));
    
    if (mach_nopt == NULL || mach_opt == NULL) {
		fprintf(stderr, "Error while allocating memory!\n");
		freeMemory();
		exit(1);
    }
    
    for (ORInt m = 0; m < n_mach; m++) {
        mach_nopt[m] = 0;
        mach_copt[m] = 0;
    }
    for (ORInt o = 0; o < n_opt; o++) {
        const ORInt m = mach[o] - mach_id_min;
        mach_nopt[m]++;
    }
    
    for (ORInt m = 0; m < n_mach; m++) {
        mach_opt[m] = (ORInt *) malloc(mach_nopt[m] * sizeof(ORInt));
        if (mach_opt[m] == NULL) {
            fprintf(stderr, "Error while allocating memory!\n");
            freeMemory();
            exit(1);
        }
    }
    
    for (ORInt o = 0; o < n_opt; o++) {
        const ORInt m = mach[o] - mach_id_min;
        const ORInt c = mach_copt[m];
        mach_opt[m][c] = o;
        mach_copt[m]++;
    }
    
    for (ORInt m = 0; m < n_mach; m++) {
        if (mach_copt[m] != mach_nopt[m]) {
            printf("Machine %d has too few optional activities %d != %d!\n", m + mach_id_min, mach_copt[m], mach_nopt[m]);
            freeMemory();
            exit(2);
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
	readDataFJSS(argv[1]);
    
    // Some pre-processing
    preprocessData();

    // Determine an initial upper bound on the project duration
	ORInt ms_max = 0;
    for (ORInt t = 0; t < n_act; t++) {
        ORInt dur_max = 0;
        for (ORInt o = act_fopt[t]; o < act_fopt[t] + act_nopt[t]; o++) dur_max = max(dur_max, dur[o]);
        ms_max += dur_max;
    }

	@autoreleasepool {
      
    	id<ORModel> model = [ORFactory createModel];
        
            // Creating of some ranges
            //
      	id<ORIntRange> dom      = [ORFactory intRange:model low:0 up:ms_max   ];
        id<ORIntRange> ActsR    = [ORFactory intRange:model low:0 up:n_act - 1];
        id<ORIntRange> OptActsR = [ORFactory intRange:model low:0 up:n_opt - 1];
        
            // Creating optional activities
            //
        id<ORActivityArray> OptActs = [ORFactory activityArray:model range:OptActsR with: ^id<ORActivity>(ORInt k) {
            if (act_nopt[opt_act[k]] == 1) {
                return [ORFactory activity:model horizon:dom duration:RANGE(model, dur[k], dur[k])];
            }
            return [ORFactory optionalActivity:model horizon:dom duration:RANGE(model, dur[k], dur[k])];
        }];
        
            // Creating of "alternative" activities
            //
        id<ORActivityArray> Acts = [ORFactory activityArray:model range:ActsR with:^id<ORActivity>(ORInt k) {
            if (act_nopt[k] == 1) {
                return OptActs[act_fopt[k]];
            }
            return [ORFactory alternativeActivity:model range:RANGE(model, act_fopt[k], act_fopt[k] + act_nopt[k] - 1) with:^id<ORActivity>(ORInt o) {
                return OptActs[o];
            }];
        }];
        
            // Creating the sink activity (representing the end of the project)
            //
        id<ORActivity> end = [ORFactory activity:model horizon:dom duration:RANGE(model, 0, 0)];
        
            // Adding precedence constraints
            //
		for (ORInt j = 0; j < n_job; j++) {
			for (ORInt t1 = 0; t1 + 1 < job_nact[j]; t1++) {
				const ORInt idx1 = t1 + job_fact[j];
				const ORInt idx2 = idx1 + 1;
                [model add: [Acts[idx1] precedes:Acts[idx2]]];
			}
		}

            // Adding resource constraints
            //
        for (ORInt m = 0; m < n_mach; m++) {
            id<ORActivityArray> m_acts = [ORFactory activityArray:model range:RANGE(model, 0, mach_nopt[m] - 1) with:^id<ORActivity>(ORInt k) {
                return OptActs[mach_opt[m][k]];
            }];
            [model add: [ORFactory disjunctive:m_acts]];
        }
        
            // Adding objective constraints
            //
		for (ORInt j = 0; j < n_job; j++) {
            const ORInt last = job_fact[j] + job_nact[j] - 1;
            [model add: [Acts[last] precedes:end]];
		}
        
            // Adding objective
            //
        [model minimizeVar: end.startLB];

            // Creating the CPScheduleProgram
            //
		id<CPSchedulingProgram> cp = [ORFactory createCPSchedulingProgram: model];
		[cp solve:
			^() {
				// Search strategy
                [cp labelActivities: OptActs];
                [cp labelActivity:   end ];
				// TODO Output of solution
//				printf("start = [|\n\t");
//				for (ORInt t = 0; t < n_task; t++) {
//                    if (t > 0 && t % n_mach == 0) printf("\n\t");
//					if (t % n_mach > 0) printf(", ");
//					printf("%2d", [cp intValue: start[t]]);
//				}
//				printf("];\n");
//                for (ORInt m = 0; m < n_mach; m++) {
//                    printf("%%%% mach %d: ", m + mach_id_min);
//                    for (ORInt k = 0; k < n_job; k++) {
//                        const ORInt t = mach_task[m][k];
//                        printf("[%2d, %2d) ", [cp intValue: start[t]], [cp intValue: start[t]] + dur[t]);
//                    }
//                    printf("\n");
//                }
                printf("objective = %d;\n", [cp intValue: end.startLB]);
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


