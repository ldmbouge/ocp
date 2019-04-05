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
#import <ORSchedulingProgram/ORSchedulingProgram.h>



	// Maximal input length of the char vector for reading a line in the data file
#define INPUTLENGTH 50000

// MRCPSP instacne data
//
ORInt    n_res   = 0;       // (input) Number of resources
ORInt *  rcap    = NULL;    // (input) Resource capacities
ORInt *  rtype   = NULL;    // (input) Resource type
ORInt *  rno     = NULL;    // (input) Resource number

ORInt    n_act   = 0;       // (input) Number of activities
ORInt    min_id  = MININT;  // Minimal ID of an activity
ORInt *  n_amode = NULL;    // (input) Number of modes of an activity
ORInt *  mfirst  = NULL;    // Index of the first mode in the array 'mdur' and 'mrr'
ORInt *  n_succ  = NULL;	// (input) Activities' number of successors
ORInt ** succ    = NULL;	// (input) Activities' successors

ORInt    n_mode  = 0;       // (input) Total number of modes
ORInt *  mdur    = NULL;	// (input) Activities' duration for each mode
ORInt ** mrr     = NULL;	// (input) Activities' resource requirements for each mode
ORInt *  m2act   = NULL;    // Mapping of mode index to its activity index

// Freeing the allocated memory before exiting the program
//
void freeMemory() {
	ORInt i;

	if (rcap    != NULL) free(rcap   );
    if (rtype   != NULL) free(rtype  );
    if (rno     != NULL) free(rno    );
    if (n_amode != NULL) free(n_amode);
    if (mfirst  != NULL) free(mfirst );
	if (mdur    != NULL) free(mdur   );
    if (m2act   != NULL) free(m2act  );
	if (mrr     != NULL) {
		for (i = 0; i < n_res; i++) {
			if (mrr[i] != NULL) free(mrr[i]);
		}
		free(mrr);
	}
	if (n_succ != NULL) free(n_succ);
	if (succ != NULL) {
		for (i = 0; i < n_act; i++) {
			if (succ[i] != NULL) free(succ[i]);
		}
		free(succ);
	}
}

void dumpInstance() {
    printf("n_act %d; n_res %d\n", n_act, n_res);
    if (n_amode != NULL && n_succ != NULL) {
        for (ORInt t = 0; t < n_act; t++) {
            printf("%d  %d  %d ", t + min_id, n_amode[t], n_succ[t]);
            for (ORInt kk = 0; kk < n_succ[t]; kk++) {
                printf(" %d", succ[t][kk] + min_id);
            }
            printf("\n");
        }
    }
    if (rcap != NULL && rtype != NULL && rno != NULL) {
        for (ORInt r = 0; r < n_res; r++)
            printf("%s%d %d\n", (rtype[r] ? "N" : "R"), rno[r], rcap[r]);
    }
    if (mdur != NULL) {
        for (ORInt t = 0; t < n_act; t++) {
            for (ORInt mm = 0; mm < n_amode[t]; mm++) {
                const ORInt m = mfirst[t] + mm;
                printf("%d  %d  %d ", t + min_id, mm, mdur[m]);
                for (ORInt r = 0; r < n_res; r++) {
                    assert(mrr[r] != NULL);
                    printf(" %d", mrr[r][m]);
                }
                printf("\n");
            }
        }
    }
}

// Reading the data from a file. This data must be given in RCP format.
//
void readDataMM(const char * filename) {
//	ORInt check;
	char temp[INPUTLENGTH], * s = NULL;
	FILE* fp = NULL;

	//printf("Entering readDataMM\n");

		// Open the file stream
	fp = fopen(filename, "r");
	assert(fp);


    // Reading the number of activities
    //
    while (fgets(temp, INPUTLENGTH, fp) != NULL) {
        s = strtok(temp, " \t\n");
        if (!strcmp(s, "jobs"))
            break;
    }
    if (strcmp(s, "jobs")) {
        fprintf(stderr, "Error while parsing for the number of activities!\n");
        fclose(fp);
        exit(1);
    }
    while (s != NULL) {
        s = strtok(NULL, " \t\n");
        if (isdigit(*s)) {
            n_act = atoi(s);
            break;
        }
    }
    if (n_act <= 0) {
        fprintf(stderr, "Error while parsing for the number of activities!\n");
        fclose(fp);
        exit(1);
    }
    
    // Reading the number of resources
    //
    while (fgets(temp, INPUTLENGTH, fp) != NULL) {
        s = strtok(temp, " -:\t\n");
        if (!strcmp(s, "renewable")) {
            s = strtok(NULL, " :\t\n");
            assert(isdigit(*s));
            n_res += atoi(s);
        }
        else if (!strcmp(s, "nonrenewable")) {
            s = strtok(NULL, " :\t\n");
            assert(isdigit(*s));
            n_res += atoi(s);
        }
        else if (!strcmp(s, "doubly")) {
            s = strtok(NULL, " :\t\n");
            s = strtok(NULL, " :\t\n");
            assert(isdigit(*s));
            if (atoi(s) > 0) {
                fprintf(stderr, "Error no doubly constrained resources allowed!\n");
                fclose(fp);
                exit(1);
            }
            break;
        }
    }

	// Allocating memory
	//
	rcap        = (ORInt   * ) malloc(n_res * sizeof(ORInt    ));
    rtype       = (ORInt   * ) malloc(n_res * sizeof(ORInt    ));
    rno         = (ORInt   * ) malloc(n_res * sizeof(ORInt    ));
	n_amode     = (ORInt   * ) malloc(n_act * sizeof(ORInt    ));
    mfirst      = (ORInt   * ) malloc(n_act * sizeof(ORInt    ));
	n_succ      = (ORInt   * ) malloc(n_act * sizeof(ORInt    ));
	succ        = (ORInt   **) malloc(n_act * sizeof(ORInt   *));
    mrr         = (ORInt   **) malloc(n_res * sizeof(ORInt   *));

	if (rcap == NULL || rtype == NULL || n_amode == NULL || mfirst == NULL ||
		succ == NULL || n_succ == NULL || rno == NULL || mrr == NULL
	) {
		fprintf(stderr, "Error while allocating memory!\n");
		freeMemory();
		fclose(fp);
		exit(1);
	} else {
		// Initialise allocated memory
		//
		for (ORInt r = 0; r < n_res; r++) {
			rcap [r] = -1;
			rtype[r] = -1;
            rno  [r] = -1;
            mrr  [r] = NULL;
		}
		for (ORInt t = 0; t < n_act; t++) {
            n_amode[t] = 0;
            mfirst [t] = -1;
			n_succ [t] = -1;
			succ   [t] = NULL;
		}
	}
    
    // Reading the number of activities modes and successors
    //
    while (fgets(temp, INPUTLENGTH, fp) != NULL) {
        s = strtok(temp, " \t\n");
        if (!strcmp(s, "PRECEDENCE")) {
            fgets(temp, INPUTLENGTH, fp);
            break;
        }
    }
    ORInt id_prev = MININT;
    for (ORInt t = 0; t < n_act; t++) {
        if (fgets(temp, INPUTLENGTH, fp) == NULL) {
            fprintf(stderr, "Error while parsing the number of activities modes and successors!\n");
            fclose(fp);
            freeMemory();
            exit(1);
        }
        // Reading the activity's ID
        s = strtok(temp, " \t\n");
        assert(isdigit(*s));
        if (t == 0) {
            min_id = atoi(s);
            id_prev = min_id - 1;
        }
        assert(atoi(s) == id_prev + 1);
        id_prev = atoi(s);
        // Reading the number of modes
        s = strtok(NULL, " \t\n");
        assert(isdigit(*s));
        n_amode[t] = atoi(s);
        n_mode += n_amode[t];
        // Reading the number of successors
        s = strtok(NULL, " \t\n");
        assert(isdigit(*s));
        n_succ[t] = atoi(s);
        // Allocating space for the successors
        if (n_succ[t] > 0) {
            succ[t] = malloc(n_succ[t] * sizeof(ORInt));
            if (succ[t] == NULL) {
                fprintf(stderr, "Error: Run out of memory!\n");
                fclose(fp);
                freeMemory();
                exit(1);
            }
        }
        else
            succ[t] = NULL;
        // Reading the successors
        for (ORInt kk = 0; kk < n_succ[t]; kk++) {
            s = strtok(NULL, " \t\n");
            assert(isdigit(*s));
            succ[t][kk] = atoi(s) - min_id;
        }
    }
    
    // Reading the resource types
    //
    while (fgets(temp, INPUTLENGTH, fp) != NULL) {
        s = strtok(temp, " /\t\n");
        if (!strcmp(s, "REQUESTS")) {
            fgets(temp, INPUTLENGTH, fp);
            s = strtok(temp, " \t\n");
            s = strtok(NULL, " \t\n");
            s = strtok(NULL, " \t\n");
            for (ORInt r = 0; r < n_res; r++) {
                s = strtok(NULL, " \t\n");
                assert(!strcmp(s, "R") || !strcmp(s, "N"));
                if (!strcmp(s, "R"))
                    rtype[r] = 0;
                else {
                    assert(!strcmp(s, "N"));
                    rtype[r] = 1;
                }
                s = strtok(NULL, " \t\n");
                assert(isdigit(*s));
                rno[r] = atoi(s);
            }
            fgets(temp, INPUTLENGTH, fp);
            break;
        }
    }
    
    // Memory allocation
    mdur  = (ORInt *) malloc(n_mode * sizeof(ORInt));
    m2act = (ORInt *) malloc(n_mode * sizeof(ORInt));
    if (mdur == NULL || m2act == NULL) {
        fprintf(stderr, "Error: Run out of memory!\n");
        fclose(fp);
        freeMemory();
        exit(1);
    }
    for (ORInt r = 0; r < n_res; r++) {
        mrr[r] = (ORInt *) malloc(n_mode * sizeof(ORInt));
        if (mrr[r] == NULL) {
            fprintf(stderr, "Error: Run out of memory!\n");
            fclose(fp);
            freeMemory();
            exit(1);
        }
    }
    
    // Reading the activities characteristics
    //
    ORInt m = 0;
    for (ORInt t = 0; t < n_act; t++) {
        for (ORInt mm = 0; mm < n_amode[t]; mm++, m++) {
            fgets(temp, INPUTLENGTH, fp);
            s = strtok(temp, " \t\n");
            assert(isdigit(*s));
            if (mm == 0) {
                mfirst[t] = m;
                assert(atoi(s) == t + min_id);
                s = strtok(NULL, " \t\n");
            }
            // Reading the duration
            s = strtok(NULL, " \t\n");
            assert(isdigit(*s));
            mdur[m] = atoi(s);
            // Storing mapping
            m2act[m] = t;
            // Reading the resource requirements
            for (ORInt r = 0; r < n_res; r++) {
                s = strtok(NULL, " \t\n");
                assert(isdigit(*s));
                mrr[r][m] = atoi(s);
            }
        }
    }
    
    // Reading the resource capacities
    //
    while (fgets(temp, INPUTLENGTH, fp) != NULL) {
        s = strtok(temp, " :\t\n");
        if (!strcmp(s, "RESOURCEAVAILABILITIES")) {
            fgets(temp, INPUTLENGTH, fp);
            for (ORInt r = 0; r < n_res; r++) {
                if (r == 0)
                    s = strtok(temp, " \t\n");
                else
                    s = strtok(NULL, " \t\n");
                assert((!rtype[r] && !strcmp(s, "R")) || (rtype[r] == 1 && !strcmp(s, "N")));
                s = strtok(NULL, " \t\n");
                assert(isdigit(*s));
                assert(rno[r] == atoi(s));
            }
            fgets(temp, INPUTLENGTH, fp);
            for (ORInt r = 0; r < n_res; r++) {
                if (r == 0)
                    s = strtok(temp, " \t\n");
                else
                    s = strtok(NULL, " \t\n");
                assert(isdigit(*s));
                rcap[r] = atoi(s);
            }
            break;
        }
    }

//    dumpInstance();
    
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

    // Start timer
    ORLong timeStart = [ORRuntimeMonitor cputime];
    
	// Read input
	readDataMM(argv[1]);

    // Computing a trivial upper bound on the nakespan
	ORInt ms_max = 0;
    for (ORInt t = 0; t < n_act; t++) {
        for (ORInt mm = 0; mm < n_amode[t]; mm++) {
            const ORInt m = mfirst[t] + mm;
            ms_max += mdur[m];
        }
    }

	@autoreleasepool {

    	id<ORModel>    model   = [ORFactory createModel];
        id<ORIntRange> horizon = [ORFactory intRange:model low:0 up:ms_max    ];
        id<ORIntRange> ActR    = [ORFactory intRange:model low:0 up:n_act  - 1];
        id<ORIntRange> MActR   = [ORFactory intRange:model low:0 up:n_mode - 1];
        id<ORIntRange> ResR    = [ORFactory intRange:model low:0 up:n_res  - 1];
        id<ORIntVar>   MS      = [ORFactory intVar:model bounds:horizon];
        
        id<ORTaskVarArray> Act;
        id<ORTaskVarArray> MAct;
        
        // Creating activities for each mode
        MAct = [ORFactory taskVarArray:model range:MActR with:^id<ORTaskVar>(ORInt m) {
            const ORInt t = m2act[m];
            if (n_amode[t] == 1)
                return [ORFactory task:model horizon:horizon duration:mdur[m]];
            else
                return [ORFactory optionalTask:model horizon:horizon duration:mdur[m]];
        }];
        
        // Creating meta activities
        Act = [ORFactory taskVarArray:model range:ActR with:^id<ORTaskVar>(ORInt t) {
            if (n_amode[t] == 1)
                return MAct[mfirst[t]];
            else
                return [ORFactory task:model range:RANGE(model, 0, n_amode[t] - 1) withAlternatives:^id<ORTaskVar>(ORInt mm) {
                    return MAct[mfirst[t] + mm];
                }];
        }];

        // Adding precedence constraints
		for (ORInt t = ActR.low; t <= ActR.up; t++) {
			for (ORInt kk = 0; kk < n_succ[t]; kk++) {
				const ORInt k = succ[t][kk];
				//printf("Add constraint: s[%d] <= s[%d] - %d\n", i, j, dur[i]);
                [model add: [Act[t] precedes:Act[k]]];
			}
            if (n_succ[t] == 0)
                [model add: [Act[t] isFinishedBy:MS]];
		}

		// Adding resource constraints
        id<ORIntVarArray> bools = [ORFactory intVarArray:model range:MActR with:^id<ORIntVar>(ORInt m) {
            return [MAct[m] getPresenceVar];
        }];
        for (ORInt r = ResR.low; r <= ResR.up; r++) {
            if (rtype[r]) {
                // Non-renewable resource
                id<ORIntArray> coef = [ORFactory intArray:model range:MActR values:mrr[r]];
                for (ORInt k = MActR.low; k <= MActR.up; k++)
                    printf("%d*b_%d + ", [coef at:k], k);
                printf(" 0 <= %d\n", rcap[r]);
                [model add: [ORFactory sum:model array:bools coef:coef leq:rcap[r]]];
            }
            else {
                // Renewable resource
                id<ORIntVar> RCap = [ORFactory intVar:model value:rcap[r]];
                id<ORTaskCumulative> cumu = [ORFactory cumulativeConstraint:RCap];
                for (ORInt m = MActR.low; m <= MActR.up; m++) {
                    if (mrr[r][m] > 0) {
                        id<ORIntVar> rr_var = [ORFactory intVar:model value:mrr[r][m]];
                        [cumu add:MAct[m] with:rr_var];
                    }
                }
                [model add:cumu];
            }
        }
        
        // Adding objective
        [model minimize: MS];

		// Solving
		id<CPProgram,CPScheduler> cp = (id)[ORFactory createCPProgram: model];
		[cp solve:
			^() {
				// Search strategy
                [cp assignAlternatives:Act];
				[cp setTimes: Act];
                [cp label: MS];
				// Output of solution
                ORLong timeInter = [ORRuntimeMonitor cputime];
                printf("%%%% Intermediate runtime: %lld ms\n", timeInter - timeStart);
				printf("start = [");
				for (ORInt t = ActR.low; t <= ActR.up; t++) {
                    if (t > 0) printf(", ");
					printf("%d", [cp est: Act[t]]);
				}
				printf("];\n");
				printf("dur = [");
                for (ORInt t = ActR.low; t <= ActR.up; t++) {
                    if (t > 0) printf(", ");
					printf("%d", [cp minDuration:Act[t]]);
				}
				printf("];\n");
                printf("mode = [");
                for (ORInt t = ActR.low; t <= ActR.up; t++) {
                    if (t > 0) printf(", ");
                    for (ORInt mm = 0; mm < n_amode[t]; mm++)
                        if ([cp isPresent:MAct[mfirst[t] + mm]]) {
                            printf("%d", mm);
                            assert([cp  intValue:[bools at:mfirst[t] + mm]] == 1);
                        }
                }
                printf("];\n");
                printf("objective = %d;\n", [cp intValue: MS]);
                printf("----------\n");
			}
		];
     
        printf("==========\n");
        
        // End timer
        ORLong timeEnd = [ORRuntimeMonitor cputime];
        printf("%%%% Runtime: %lld ms\n", timeEnd - timeStart);

        NSString* str = [cp description];
        printf("%%%% Solver status: %s\n", [str UTF8String]);
//     	NSLog(@"Solver status: %@\n",cp);
     	NSLog(@"Quitting");
   	}
  
	freeMemory();
    
   	return 0;
}


