/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Andreas Schutt and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "CPMisc.h"

/*******************************************************************************
 Computation of the contention profile
 ******************************************************************************/

// Computation of the contention profile for the earliest-start-time schedule
//
Profile getEarliestContentionProfile(ORInt * sort_id_est, ORInt * sort_id_ect, ORInt * est, ORInt * ect, ORInt * height, ORInt size)
{
    assert(sort_id_est != NULL);
    assert(sort_id_ect != NULL);
    assert(est         != NULL);
    assert(ect         != NULL);
    assert(height      != NULL);

    // Counting the number of profile parts needed
    ORInt nbTime = 0;
    ORInt tt1    = 0;
    ORInt tt2    = 0;
    ORInt time   = MININT;
    const ORInt lastT   = sort_id_ect[size - 1];
    const ORInt lastEct = ect[lastT];
    while (time < lastEct) {
        const ORInt t1 = (tt1 < size ? sort_id_est[tt1] : -1);
        const ORInt t2 = sort_id_ect[tt2];
        const ORInt time1 = (t1 >= 0 ? est[t1] : MAXINT);
        const ORInt time2 = ect[t2];
        
        assert(time < min(time1, time2));
        time = min(time1, time2);
        nbTime++;
        
        while (tt1 < size && est[sort_id_est[tt1]] <= time) tt1++;
        while (tt2 < size && ect[sort_id_ect[tt2]] <= time) tt2++;
    }
    
    assert(nbTime > 0);
    
    // Allocating memory for the resource profile
    Profile prof;
    prof._size = nbTime;
    prof._level = (ORInt *) malloc(prof._size * sizeof(ORInt));
    prof._time  = (ORInt *) malloc(prof._size * sizeof(ORInt));
    
    // Check whether memory allocation was successful
    if (prof._level == NULL || prof._time == NULL) {
        @throw [[ORExecutionError alloc] initORExecutionError: "ContentionProfile: Out of memory!"];
    }
    
    // Creating resource profile
    ORInt level = 0;
    tt1 = 0;
    tt2 = 0;
    time = MININT;
    for (ORInt i = 0; i < prof._size; i++) {
        const ORInt t1 = (tt1 < size ? sort_id_est[tt1] : -1);
        const ORInt t2 = sort_id_ect[tt2];
        const ORInt time1 = (t1 >= 0 ? est[t1] : MAXINT);
        const ORInt time2 = ect[t2];
        
        assert(time < min(time1, time2));
        time = min(time1, time2);
        
        while (tt1 < size && est[sort_id_est[tt1]] <= time) {
            assert(est[sort_id_est[tt1]] == time);
            level += height[sort_id_est[tt1]];
            tt1++;
        }
        while (tt2 < size && ect[sort_id_ect[tt2]] <= time) {
            assert(ect[sort_id_ect[tt2]] == time);
            level -= height[sort_id_ect[tt2]];
            tt2++;
        }
        // Store in i-th position (time, level)
        prof._level[i] = level;
        prof._time [i] = time;
    }
    
    return prof;
}

void dumpProfile(Profile prof)
{
    printf("Profile: \n");
    printf("\tlevel: ");
    for (ORInt i = 0; i < prof._size; i++) {
        printf("%3d ", prof._level[i]);
    }
    printf("\n");
    printf("\ttime : ");
    for (ORInt i = 0; i < prof._size; i++) {
        printf("%3d ", prof._time[i]);
    }
    printf("\n");
}

/*******************************************************************************
 * Sorting Algorithms
 ******************************************************************************/

// Bubble sort
//
void bsort_r(ORInt * base, ORInt size, void * thunk, ORInt(* compare)(void*, const ORInt*, const ORInt*)) {
    for (ORInt i = 0; i < size; i++) {
        ORBool swapped = false;
        for (ORInt j = size - 1; j > i; j--) {
            if (compare(thunk, &base[j-1], &base[j]) > 0) {
                ORInt tmp = base[j-1];
                base[j-1] = base[j];
                base[j] = tmp;
                swapped = true;
            }
        }
        if (!swapped)
            break;
    }
}

// Insertion sort
//
void isort_r(ORInt * base, ORInt size, void * thunk, ORInt(* compare)(void*, const ORInt*, const ORInt*)) {
    for (ORInt i = 1; i < size; i++) {
        for (ORInt j = i; j > 0 && compare(thunk, &base[j-1], &base[j]) > 0; j--) {
            ORInt tmp   = base[j - 1];
            base[j - 1] = base[j    ];
            base[j    ] = tmp;
        }
    }
}

// Quick sort
//
void qusort_r(ORInt * base, ORInt size, void * thunk, ORInt(* compare)(void*, const ORInt*, const ORInt*)) {
    // NOTE: qsort_r the 4th argument of qsort_r is at the last position in glibc (GNU/Linux)
#if (defined __APPLE__)
    qsort_r(base, size, sizeof(ORInt), thunk, (int(*)(void*, const void*, const void*)) compare);
#elif (defined __linux__)
    qsort_r(base, size, sizeof(ORInt), (int(*)(void*, const void*, const void*)) compare, thunk);
#else
    #error Cannot detect operation system
#endif
}


ORBool test_sorted_array(ORInt * base, ORInt size, void * thunk, ORInt(* compare)(void*, const ORInt*, const ORInt*)) {
    for (ORInt i = 0, j = 1; j < size; i++, j++) {
        if (compare(thunk, &base[j-1], &base[j]) > 0)
            return false;
    }
    return true;
}
