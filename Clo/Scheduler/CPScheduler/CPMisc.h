/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Andreas Schutt and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <Foundation/Foundation.h>
#import <CPUKernel/CPUKernel.h>
#import <CPScheduler/CPTask.h>


// Resource profile

typedef struct {
    ORInt   _size;
    ORInt * _time;
    ORInt * _level;
} Profile;

Profile getEarliestContentionProfile(ORInt * sort_id_est, ORInt * sort_id_ect, ORInt * est, ORInt * ect, ORInt * level, ORInt size);
void dumpProfile(Profile prof);


// Precedence relation

typedef struct {
    ORInt _first;
    ORInt _second;
} Precedence;

typedef struct {
    id<CPTaskVar> _before;
    id<CPTaskVar> _after;
} CPTaskVarPrec;


// Sorting algorithms

    // Bubble sort
void bsort_r(ORInt * base, ORInt size, void * thunk, ORInt(* compare)(void*, const ORInt*, const ORInt*));
    // Insertion sort
void isort_r(ORInt * base, ORInt size, void * thunk, ORInt(* compare)(void*, const ORInt*, const ORInt*));
    // Quick sort
void qusort_r(ORInt * base, ORInt size, void * thunk, ORInt(* compare)(void*, const ORInt*, const ORInt*));
