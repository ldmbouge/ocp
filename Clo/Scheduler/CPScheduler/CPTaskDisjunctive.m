/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2013-14 NICTA, Andreas Schutt and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <CPUKernel/CPConstraintI.h>
#import <objcp/CPIntVarI.h>
#import "CPTaskDisjunctive.h"
#import "CPMisc.h"
#import "CPTask.h"

// TODO Replacing ORUInts by ORInts

// Randomly set
#define MAXNBTASK ((MAXINT)/4)

@implementation CPTaskDisjunctive {
    // Attributs of tasks
    ORUInt   _size;         // Number of tasks in the array '_tasks'
    ORInt    _low;          // Lowest index in the array '_tasks'
    ORInt    _up;           // Highest index in the array '_tasks'

    ORInt  * _idx;          // Activities' ID sorted in [Present | Unknown | Absent]
    TRInt    _cIdx;         // Size of present activities
    TRInt    _uIdx;         // Size of present and non-present activities

    ORInt  * _bound;        // Activities' ID sorted in [Bound | Not Bound]
    TRInt    _boundSize;    // Size of bounded tasks

    
    // Variables needed for the propagation
    // NOTE: Memory is dynamically allocated by alloca/1 each time the propagator
    //      is called.
    ORInt  * _new_est;      // New earliest start times
    ORInt  * _new_lct;      // New latest completion times

    ORInt  * _est;          // Earliest start times
    ORInt  * _lct;          // Latest completion times
    ORInt  * _dur_min;      // Minimal durations
    ORInt  * _dur_max;      // Maximal durations
    ORBool * _present;      // Whether the task is present
    ORBool * _absent;       // Whether the task is absent
    
    ORInt    _begin;        // Start time of the horizon considered during propagation
    ORInt    _end;          // End time of the horizon considered during propagation
    ORInt    _beginIdx;
    ORInt    _endIdx;
    
    // Static allocation of following arrays
    ORInt * _task_id_est;   // Task's ID sorted according the earliest start times
    ORInt * _task_id_ect;   // Task's ID sorted according the earliest completion times
    ORInt * _task_id_lst;   // Task's ID sorted according the latest start times
    ORInt * _task_id_lct;   // Task's ID sorted according the latest completion times
    
    // Filtering options
    ORBool _idempotent;
    ORBool _dprec;          // Detectable precedences filtering
    ORBool _nfnl;           // Not-first/not-last filtering
    ORBool _ef;             // Edge-finding
    
    // Additional informations
    TRInt _global_slack; // Global slack of the disjunctive constraint
}
-(id) initCPTaskDisjunctive: (id<CPTaskVarArray>) tasks
{
    // Checking whether the number of activities is within the limit
    if (tasks.count > (NSUInteger) MAXNBTASK) {
        @throw [[ORExecutionError alloc] initORExecutionError: "CPTaskDisjunctive: Number of elements exceeds beyond the limit!"];
    }
    
    id<CPTaskVar> task0 = tasks[tasks.low];
    self = [super initCPCoreConstraint: [task0 engine]];
    // TODO Changing the priority
    _priority = LOWEST_PRIO + 2;
    _tasks  = tasks;
    
    
    _idempotent = false;
    _dprec = true;
    _nfnl  = true;
    _ef    = true;
    _idx   = NULL;
    _bound = NULL;
    
    _est         = NULL;
    _lct         = NULL;
    _dur_min     = NULL;
    _task_id_est = NULL;
    _task_id_ect = NULL;
    _task_id_lst = NULL;
    _task_id_lct = NULL;
    
    _dur_max     = NULL;
    _present     = NULL;
    _absent      = NULL;
    
    _size = (ORUInt) _tasks.count;
    _low  = _tasks.range.low;
    _up   = _tasks.range.up;
    
    return self;
}

-(void) dealloc
{
    if (_idx         != NULL) free(_idx        );
    if (_bound       != NULL) free(_bound      );
    if (_est         != NULL) free(_est        );
    if (_lct         != NULL) free(_lct        );
    if (_dur_min     != NULL) free(_dur_min    );
    if (_task_id_est != NULL) free(_task_id_est);
    if (_task_id_ect != NULL) free(_task_id_ect);
    if (_task_id_lst != NULL) free(_task_id_lst);
    if (_task_id_lct != NULL) free(_task_id_lct);
    
    if (_dur_max     != NULL) free(_dur_max    );
    if (_present     != NULL) free(_present    );
    if (_absent      != NULL) free(_absent     );
    
    [super dealloc];
}
-(ORStatus) post
{
    _cIdx         = makeTRInt(_trail, 0     );
    _uIdx         = makeTRInt(_trail, _size );
    _boundSize    = makeTRInt(_trail, 0     );
    _global_slack = makeTRInt(_trail, MAXINT);
    
    // Allocating memory
    _idx         = malloc(_size * sizeof(ORInt));
    _bound       = malloc(_size * sizeof(ORInt));
    _est         = malloc(_size * sizeof(ORInt));
    _lct         = malloc(_size * sizeof(ORInt));
    _dur_min     = malloc(_size * sizeof(ORInt));
    _task_id_est = malloc(_size * sizeof(ORInt));
    _task_id_ect = malloc(_size * sizeof(ORInt));
    _task_id_lst = malloc(_size * sizeof(ORInt));
    _task_id_lct = malloc(_size * sizeof(ORInt));

    _dur_max     = malloc(_size * sizeof(ORInt));
    _present     = malloc(_size * sizeof(ORBool));
    _absent      = malloc(_size * sizeof(ORBool));

    // Checking whether memory allocation was successful
    if (_idx == NULL || _task_id_est == NULL || _task_id_ect == NULL || _task_id_lst == NULL || _task_id_lct == NULL
        || _est == NULL || _lct == NULL || _dur_min == NULL
        || _dur_max == NULL || _present == NULL || _absent == NULL
    ) {
        @throw [[ORExecutionError alloc] initORExecutionError: "CPTaskDisjunctive: Out of memory!"];
    }
    
    for (ORInt i = 0; i < _size; i++) {
        const ORInt idx = i + _low;
        _idx  [i]       = idx;
        _bound[i]       = idx;
        _task_id_est[i] = idx;
        _task_id_ect[i] = idx;
        _task_id_lst[i] = idx;
        _task_id_lct[i] = idx;
    }
    
    // Subscription of variables to the constraint
    for (ORInt i = _low; i <= _up; i++) {
        if ([_tasks[i] maxDuration] > 0)
            [_tasks[i] whenChangePropagate: self];
        if ([_tasks[i] isOptional])
            [_tasks[i] whenPresentPropagate: self];
    }
    
    // Initial propagation
    [self propagate];
    
    return ORSuspend;
}
-(void) propagate
{
    doPropagation(self);
}

-(NSSet*) allVars
{
    NSUInteger nb = 2 * _size;
    NSMutableSet* rv = [[NSMutableSet alloc] initWithCapacity:nb];
    for(ORInt i = _low; i <= _up; i++)
        [rv addObject:_tasks[i]];
    [rv autorelease];
    return rv;
}
-(ORUInt) nbUVars
{
    ORUInt nb = 0;
    for(ORInt i = _low; i <= _up; i++)
        if (![_tasks[i] bound])
            nb++;
    return nb;
}
-(NSString*) description
{
    return [NSString stringWithFormat:@"CPTaskDisjunctive"];
}
-(ORInt) globalSlack
{
    return _global_slack._val;
}
-(ORInt) localSlack
{
    return getLocalSlack(self);
}



/*******************************************************************************
 Propagation implementation in C
 ******************************************************************************/

static inline ORBool isRelevant(CPTaskDisjunctive * disj, const ORInt idx0)
{
    return (disj->_present[idx0] && disj->_dur_min[idx0] > 0);
}

static inline ORBool isIrrelevant(CPTaskDisjunctive * disj, const ORInt idx0)
{
    return (disj->_absent[idx0] || disj->_dur_max[idx0] <= 0);
}

static inline BOOL isPresent(CPTaskDisjunctive * disj, const ORInt idx0)
{
    return disj->_present[idx0];
}

static inline BOOL isAbsent(CPTaskDisjunctive * disj, const ORInt idx0)
{
    return disj->_absent[idx0];
}

/*******************************************************************************
 * Theta Tree and Theta-Lambda Tree Implementations
 *
 * list:
 *  - Insert
 *  - Delete
 *  - Initialisation
 ******************************************************************************/

// Theta-(Lambda) Tree Operations
//
#define LEFTCHILD(I)  ((I << 1) + 1)
#define RIGHTCHILD(I) ((I << 1) + 2)
#define PARENT(I)     ((I -  1) / 2)

// Theta Tree
//
typedef struct {
    ORInt _length;
    ORInt _time;
} ThetaTree;

// Lambda Tree
//
// NOTE This tree can be emulated with two Theta trees. Consequently, it would
//      save memory and avoid code duplications.
typedef struct {
    ORInt _gLength;
    ORInt _gTime;
} LambdaTree;

// Initialisation of an empty Theta tree
//
static void initThetaTree(ThetaTree * theta, ORUInt tsize, ORInt time) {
    for (ORUInt i = 0; i < tsize; i++) {
        theta[i]._length = 0;
        theta[i]._time   = time;
    }
}

// Initialisation of an empty Lambda tree
//
static void initLambdaTree(LambdaTree * lambda, ORUInt tsize, ORInt time) {
    for (ORUInt i = 0; i < tsize; i++) {
        lambda[i]._gLength = 0;
        lambda[i]._gTime   = time;
    }
}


// Insertation of one task in a Theta tree
//
static void insertThetaNodeAtIdxEct(ThetaTree * theta, const ORUInt tsize, ORUInt idx, const ORInt length, const ORInt time) {
    assert(0 <= idx && idx < tsize);
    // Activition of the node
    theta[idx]._length = length;
    theta[idx]._time   = time;
    // Propagation of the changes
    do {
        idx = PARENT(idx);
        const ORUInt l = LEFTCHILD( idx);
        const ORUInt r = RIGHTCHILD(idx);
        theta[idx]._length = theta[l]._length + theta[r]._length;
        theta[idx]._time   = max(theta[r]._time, theta[l]._time + theta[r]._length);
    } while (idx > 0);
    assert(idx == 0);
}

// Insertation of one task in a Theta tree
//
static void insertThetaNodeAtIdxLst(ThetaTree * theta, const ORUInt tsize, ORUInt idx, const ORInt length, const ORInt time) {
    assert(0 <= idx && idx < tsize);
    // Activition of the node
    theta[idx]._length = length;
    theta[idx]._time   = time;
    // Propagation of the changes
    do {
        idx = PARENT(idx);
        const ORUInt l = LEFTCHILD( idx);
        const ORUInt r = RIGHTCHILD(idx);
        theta[idx]._length = theta[l]._length + theta[r]._length;
        theta[idx]._time   = min(theta[l]._time, theta[r]._time - theta[l]._length);
    } while (idx > 0);
    assert(idx == 0);
}


// Initialisation of an Theta-Lambda tree with (Theta, Lambda) = (T, {})
//
// NOTE (1) Task are ignored if their minimal duration is zero.
//      (2) A task 'i' has only three states:
//          (White or 'i in Theta') considered in theta tree and lambda tree
//          (Grey  or 'i in Lambda') only considered in lambda tree
//          (None  or 'i not in Theta union Lambda') not considered at all
static void initThetaLambdaTreeWithEct(CPTaskDisjunctive * disj, const ORInt size, const ORUInt * idx_map_est, ThetaTree * theta, LambdaTree * lambda, const ORUInt tsize) {
    // Inserting all tasks into the Theta tree
    for (ORUInt i = 0; i < size; i++) {
        const ORUInt idx = idx_map_est[i];
        theta[idx]._length = 0;
        theta[idx]._time   = MININT;
    }
    for (ORUInt ii = disj->_beginIdx; ii < disj->_endIdx; ii++) {
        const ORInt i0 = disj->_task_id_est[ii] - disj->_low;
        const ORInt idx = idx_map_est[i0];
        if (disj->_dur_min[i0] > 0) {
            theta[idx]._length = disj->_dur_min[i0];
            theta[idx]._time   = disj->_est[i0] + disj->_dur_min[i0];
        }
    }
//    for (ORUInt i = 0; i < size; i++) {
//        const ORUInt idx = idx_map_est[i];
//        if (disj->_dur_min[i] > 0) {
//            theta[idx]._length = disj->_dur_min[i];
//            theta[idx]._time   = disj->_est[i] + disj->_dur_min[i];
//        }
//        else {
//            theta[idx]._length = 0;
//            theta[idx]._time   = MININT;
//        }
//    }
    // Computation of the values for the interior nodes in the Theta tree
    for (ORInt p = tsize - size - 1; p >= 0; p--) {
        const ORInt l = LEFTCHILD( p);
        const ORInt r = RIGHTCHILD(p);
        theta[p]._length = theta[l]._length + theta[r]._length;
        theta[p]._time   = max(theta[r]._time, theta[l]._time + theta[r]._length);
    }
    // At the beginning, all tasks are white, thus the Lambda tree is only a copy
    // of the Theta tree
    for (ORInt i = 0; i < tsize; i++) {
        lambda[i]._gLength = theta[i]._length;
        lambda[i]._gTime   = theta[i]._time;
    }
}

// TODO Check whether it is also correct for optional activities
static void initThetaLambdaTreeWithLst(CPTaskDisjunctive * disj, const ORInt size, const ORUInt * idx_map_lct, ThetaTree * theta, LambdaTree * lambda, const ORUInt tsize) {
    // Inserting all tasks into the Theta tree
    for (ORUInt i = 0; i < size; i++) {
        const ORUInt idx = idx_map_lct[i];
        theta[idx]._length = 0;
        theta[idx]._time   = MAXINT;
    }
    for (ORInt ii = disj->_beginIdx; ii < disj->_endIdx; ii++) {
        const ORInt i0  = disj->_task_id_est[ii] - disj->_low;
        const ORInt idx = idx_map_lct[i0];
        if (disj->_dur_min[i0] > 0) {
            theta[idx]._length = disj->_dur_min[i0];
            theta[idx]._time   = disj->_lct[i0] - disj->_dur_min[i0];
        }
    }
//    for (ORUInt i = 0; i < size; i++) {
//        const ORUInt idx = idx_map_lct[i];
//        if (disj->_dur_min[i] > 0) {
//            theta[idx]._length = disj->_dur_min[i];
//            theta[idx]._time   = disj->_lct[i] - disj->_dur_min[i];
//        }
//        else {
//            theta[idx]._length = 0;
//            theta[idx]._time   = MAXINT;
//        }
//    }
    // Computation of the values for the interior nodes in the Theta tree
    for (ORInt p = tsize - size - 1; p >= 0; p--) {
        const ORInt l = LEFTCHILD( p);
        const ORInt r = RIGHTCHILD(p);
        theta[p]._length = theta[l]._length + theta[r]._length;
        theta[p]._time   = min(theta[l]._time, theta[r]._time - theta[l]._length);
    }
    // At the beginning, all tasks are white , thus the Lambda tree is only a copy
    // of the Theta tree
    for (ORInt i = 0; i < tsize; i++) {
        lambda[i]._gLength = theta[i]._length;
        lambda[i]._gTime   = theta[i]._time;
    }
}


// Insertation of one task in a Theta-Lambda tree
//
static void insertLambdaNodeAtIdxEct(ThetaTree * theta, LambdaTree * lambda, const ORUInt tsize, ORUInt idx, const ORInt length, const ORInt time) {
    assert(0 <= idx && idx < tsize);
    // Activition of the node
    lambda[idx]._gLength = length;
    lambda[idx]._gTime   = time;
    // Propagation of the changes
    do {
        idx = PARENT(idx);
        const ORUInt l = LEFTCHILD( idx);
        const ORUInt r = RIGHTCHILD(idx);
        lambda[idx]._gLength = max(lambda[l]._gLength + theta[r]._length, theta[l]._length + lambda[r]._gLength);
        lambda[idx]._gTime   = max(lambda[r]._gTime, max(theta[l]._time + lambda[r]._gLength, lambda[l]._gTime + theta[r]._length));
    } while (idx > 0);
    assert(idx == 0);
}

// Insertation of one task in a Theta-Lambda tree
//
static void insertLambdaNodeAtIdxLst(ThetaTree * theta, LambdaTree * lambda, const ORUInt tsize, ORUInt idx, const ORInt length, const ORInt time) {
    assert(0 <= idx && idx < tsize);
    // Activition of the node
    lambda[idx]._gLength = length;
    lambda[idx]._gTime   = time;
    // Propagation of the changes
    do {
        idx = PARENT(idx);
        const ORUInt l = LEFTCHILD( idx);
        const ORUInt r = RIGHTCHILD(idx);
        lambda[idx]._gLength = max(lambda[l]._gLength + theta[r]._length, theta[l]._length + lambda[r]._gLength);
        lambda[idx]._gTime   = min(lambda[l]._gTime, min(theta[r]._time - lambda[l]._gLength, lambda[r]._gTime - theta[l]._length));
    } while (idx > 0);
    assert(idx == 0);
}

// Determining the leave (task) that is responsible for the ECT(Theta, Lambda)
//
static ORInt retrieveResponsibleLambdaNodeWithEct(ThetaTree * theta, LambdaTree * lambda, const ORUInt tsize)
{
    ORUInt p = 0;
    bool gLength = false;
    while (p < tsize) {
        const ORUInt l = LEFTCHILD( p);
        const ORUInt r = RIGHTCHILD(p);
        if (l >= tsize) {
            break;
        }
        if (gLength) {
            p = (lambda[p]._gLength == lambda[l]._gLength + theta[r]._length ? l : r);
        }
        else {
            if (lambda[p]._gTime == lambda[r]._gTime) {
                p = r;
            } else if (lambda[p]._gTime == theta[l]._time + lambda[r]._gLength) {
                p = r;
                gLength = true;
            } else {
                p = l;
            }
        }
    }
    assert(((tsize + 1) >> 1) - 1 <= p && p < tsize);
    return p;
}

static ORInt retrieveResponsibleLambdaNodeWithLst(ThetaTree * theta, LambdaTree * lambda, const ORUInt tsize)
{
    ORUInt p = 0;
    bool gLength = false;
    while (p < tsize) {
        const ORUInt l = LEFTCHILD( p);
        const ORUInt r = RIGHTCHILD(p);
        if (l >= tsize) {
            break;
        }
        if (gLength) {
            p = (lambda[p]._gLength == lambda[l]._gLength + theta[r]._length ? l : r);
        }
        else {
            if (lambda[p]._gTime == lambda[l]._gTime) {
                p = l;
            } else if (lambda[p]._gTime == theta[r]._time - lambda[l]._gLength) {
                p = l;
                gLength = true;
            } else {
                p = r;
            }
        }
    }
    assert(((tsize + 1) >> 1) - 1 <= p && p < tsize);
    return p;
}

// Determining the left-most bit which is not zero
//
static ORUInt getDepth(ORUInt x)
{
    ORUInt depth = 0;
    while (x >>= 1) depth++;
    return depth;
}

// Generation of the map from the task's ID to leaf's index
//
static void initIndexMap(CPTaskDisjunctive* disj, ORInt * array, ORUInt * idx_map, const ORUInt sizeArray, const ORUInt sizeTree, const ORUInt depth) {
    ORInt tt = 0;
    ORInt leaf = (1 << depth) - 1;
    // nbLeaves >= (nbLeaves in lowest level) + (nbLeaves in second lowest level)
    assert(sizeArray >= (sizeTree - leaf) + ((1 << (depth - 1)) - (sizeTree - leaf) / 2));
    for (tt = 0; leaf < sizeTree; tt++, leaf++) {
        const ORInt t0 = array[tt] - disj->_low;
        idx_map[t0] = leaf;
    }
    assert(leaf == sizeTree);
    leaf = PARENT(leaf);
    for (; tt < sizeArray; tt++, leaf++) {
        const ORInt t0 = array[tt] - disj->_low;
        idx_map[t0] = leaf;
    }
}


/*******************************************************************************
 Auxiliary Functions
 ******************************************************************************/

static void cleanUp(CPTaskDisjunctive* disj) {
//    disj->_est         = NULL;
//    disj->_lct         = NULL;
//    disj->_dur_min     = NULL;
//    disj->_task_id_est = NULL;
//    disj->_task_id_ect = NULL;
//    disj->_task_id_lst = NULL;
//    disj->_task_id_lct = NULL;
}


static void dumpTask(CPTaskDisjunctive * disj, ORInt t) {
    printf("task %d: est %d; ect %d; lst %d; lct %d; dur_min %d;\n", t, disj->_est[t], disj->_est[t] + disj->_dur_min[t], disj->_lct[t] - disj->_dur_min[t], disj->_lct[t], disj->_dur_min[t]);
}

// Printing the contain of the Theta tree to standard out
//
static void dumpThetaTree(ThetaTree * theta, const ORUInt tsize)
{
    printf("Theta:  ");
    for (ORInt i = 0; i < tsize; i++) {
        printf("(%d: len %d, time %d) ", i, theta[i]._length, theta[i]._time);
    }
    printf("\n");
}


// Printing the contain of the Theta tree to standard out
//
static void dumpLambdaTree(LambdaTree * lambda, const ORUInt tsize)
{
    printf("Lambda:  ");
    for (ORInt i = 0; i < tsize; i++) {
        printf("(%d: len %d, time %d) ", i, lambda[i]._gLength, lambda[i]._gTime);
    }
    printf("\n");
}

/*******************************************************************************
 Sorting Functions
 ******************************************************************************/

// Sorting tasks ID according to the earliest start times
//
int sortDisjEstAsc(CPTaskDisjunctive * disj, const ORInt * r1, const ORInt * r2)
{
    const ORInt i1 = *r1 - disj->_low;
    const ORInt i2 = *r2 - disj->_low;
    assert(0 <= i1 && i1 < disj->_size);
    assert(0 <= i2 && i2 < disj->_size);
    return disj->_est[i1] - disj->_est[i2];
}

int sortDisjEstAscOpt(CPTaskDisjunctive * disj, const ORInt * r1, const ORInt * r2)
{
    const ORInt i1 = *r1 - disj->_low;
    const ORInt i2 = *r2 - disj->_low;
    assert(0 <= i1 && i1 < disj->_size);
    assert(0 <= i2 && i2 < disj->_size);
    if (isIrrelevant(disj, i1)) {
        if (isIrrelevant(disj, i2))
            return 0;
        return 1;
    } else if (isIrrelevant(disj, i2)) {
        return -1;
    }
    return disj->_est[i1] - disj->_est[i2];
}

// Sorting tasks ID according to the earliest completion times
//
int sortDisjEctAsc(CPTaskDisjunctive * disj, const ORInt * r1, const ORInt * r2)
{
    const ORInt i1 = *r1 - disj->_low;
    const ORInt i2 = *r2 - disj->_low;
    assert(0 <= i1 && i1 < disj->_size);
    assert(0 <= i2 && i2 < disj->_size);
    return disj->_est[i1] - disj->_est[i2] + disj->_dur_min[i1] - disj->_dur_min[i2];
}

int sortDisjEctAscOpt(CPTaskDisjunctive * disj, const ORInt * r1, const ORInt * r2)
{
    const ORInt i1 = *r1 - disj->_low;
    const ORInt i2 = *r2 - disj->_low;
    assert(0 <= i1 && i1 < disj->_size);
    assert(0 <= i2 && i2 < disj->_size);
    if (isIrrelevant(disj, i1)) {
        if (isIrrelevant(disj, i2))
            return 0;
        return 1;
    } else if (isIrrelevant(disj, i2)) {
        return -1;
    }
    return disj->_est[i1] - disj->_est[i2] + disj->_dur_min[i1] - disj->_dur_min[i2];
}

// Sorting tasks ID according to the latest start times
//
int sortDisjLstAsc(CPTaskDisjunctive * disj, const ORInt * r1, const ORInt * r2)
{
    const ORInt i1 = *r1 - disj->_low;
    const ORInt i2 = *r2 - disj->_low;
    assert(0 <= i1 && i1 < disj->_size);
    assert(0 <= i2 && i2 < disj->_size);
    return disj->_lct[i1] - disj->_lct[i2] - disj->_dur_min[i1] + disj->_dur_min[i2];
}

int sortDisjLstAscOpt(CPTaskDisjunctive * disj, const ORInt * r1, const ORInt * r2)
{
    const ORInt i1 = *r1 - disj->_low;
    const ORInt i2 = *r2 - disj->_low;
    assert(0 <= i1 && i1 < disj->_size);
    assert(0 <= i2 && i2 < disj->_size);
    if (isIrrelevant(disj, i1)) {
        if (isIrrelevant(disj, i2))
            return 0;
        return 1;
    } else if (isIrrelevant(disj, i2)) {
        return -1;
    }
    return disj->_lct[i1] - disj->_lct[i2] - disj->_dur_min[i1] + disj->_dur_min[i2];
}

// Sorting tasks ID according to the latest completion times
//
int sortDisjLctAsc(CPTaskDisjunctive * disj, const ORInt * r1, const ORInt * r2)
{
    const ORInt i1 = *r1 - disj->_low;
    const ORInt i2 = *r2 - disj->_low;
    assert(0 <= i1 && i1 < disj->_size);
    assert(0 <= i2 && i2 < disj->_size);
    return disj->_lct[i1] - disj->_lct[i2];
}

int sortDisjLctAscOpt(CPTaskDisjunctive * disj, const ORInt * r1, const ORInt * r2)
{
    const ORInt i1 = *r1 - disj->_low;
    const ORInt i2 = *r2 - disj->_low;
    assert(0 <= i1 && i1 < disj->_size);
    assert(0 <= i2 && i2 < disj->_size);
    if (isIrrelevant(disj, i1)) {
        if (isIrrelevant(disj, i2))
            return 0;
        return 1;
    } else if (isIrrelevant(disj, i2)) {
        return -1;
    }
    return disj->_lct[i1] - disj->_lct[i2];
}


/*******************************************************************************
 Functions for Updating the Bounds
 ******************************************************************************/

static void updateBounds(CPTaskDisjunctive * disj, const ORInt size)
{
    for (ORInt tt = 0; tt < size; tt++) {
        const ORInt t  = disj->_idx[tt];
        const ORInt t0 = t - disj->_low;
        if (disj->_new_est[t0] > disj->_est[t0]) {
            [disj->_tasks[t] updateStart: disj->_new_est[t0]];
            if (disj->_idempotent)
                disj->_est[t0] = disj->_new_est[t0];
        }
        if (disj->_new_lct[t0] < disj->_lct[t0]) {
            [disj->_tasks[t] updateEnd: disj->_new_lct[t0]];
            if (disj->_idempotent)
                disj->_lct[t0] = disj->_new_lct[t0];
        }
    }
    //   NSLog(@" results of the propagation ");
    //   for (ORInt tt = 0; tt < size; tt++)
    //      NSLog(@" Task[%d] = %@",tt,disj->_tasks[tt]);
    //   NSLog(@" ---------------------------- ");
    
}


/*******************************************************************************
 Resource Overload Consistency Checks
 ******************************************************************************/

// Resource overload check from Vilim
//  Time: O(n log n)
//  Space: O(n)
//
static void ef_overload_check_vilim(CPTaskDisjunctive * disj, const ORInt size, const ORUInt * idx_map_est, ThetaTree * theta, const ORUInt tsize)
{
    initThetaTree(theta, tsize, MININT);
    // Iteration in non-decreasing order of the latest completion time
    for (ORInt tt = disj->_beginIdx; tt < disj->_endIdx; tt++) {
//    for (ORInt tt = 0; tt < size; tt++) {
        const ORInt t0 = disj->_task_id_lct[tt] - disj->_low;
        // Retrieve task's position in task_id_est
        const ORUInt tree_idx = idx_map_est[t0];
        const ORInt ect_t = disj->_est[t0] + disj->_dur_min[t0];
        // Insert task into theta tree
        insertThetaNodeAtIdxEct(theta, tsize, tree_idx, disj->_dur_min[t0], ect_t);
        // Check for resource overload
        if (theta[0]._time > disj->_lct[t0]) {
            failNow();
        }
    }
}

// Resource overload check with optional activities from Vilim
//  Time: O(n log n)
//  Space: O(n)
//  NOTE: Vilim's algorithm contains a minor mistake. A potential overload caused
//      by an optional activity also needs to be check after insertion of optional
//      activities.
//
static void ef_overload_check_optional_vilim(CPTaskDisjunctive * disj, const ORInt size, const ORUInt * idx_map_est, ThetaTree * theta, LambdaTree * lambda, const ORUInt tsize, const ORUInt tdepth)
{
    // Initialisation of Theta and Lambda tree
    initThetaTree( theta,  tsize, MININT);
    initLambdaTree(lambda, tsize, MININT);
    // 'offset' reflects the total of nodes in the trees except the nodes in the deepest level
    const ORUInt offset = (1 << tdepth) - 1;
    // Iteration in non-descreasing order of the latest completion time
    for (ORInt tt = 0; tt < size; tt++) {
        const ORInt t0 = disj->_task_id_lct[tt] - disj->_low;
        if (isRelevant(disj, t0)) {
            // Relevant activity
            // Retrieve task's position in task_id_est
            const ORUInt tree_idx = idx_map_est[t0];
            const ORInt ect_t = disj->_est[t0] + disj->_dur_min[t0];
            // Insert activity into theta tree
            insertThetaNodeAtIdxEct(theta, tsize, tree_idx, disj->_dur_min[t0], ect_t);
            // Update lambda tree
            insertLambdaNodeAtIdxEct(theta, lambda, tsize, tree_idx, 0, MININT);
            // Check for resource overload
            if (theta[0]._time > disj->_lct[t0]) {
                failNow();
            }
        }
        else if (!isIrrelevant(disj, t0)) {
            // Optional activity
            insertLambdaNodeAtIdxEct(theta, lambda, tsize, idx_map_est[t0], disj->_dur_min[t0], disj->_est[t0] + disj->_dur_min[t0]);
        }
        // Dectection of potential overloads
        while (lambda[0]._gTime > disj->_lct[t0]) {
            // Retrieve responsible leaf
            const ORUInt leaf_idx = retrieveResponsibleLambdaNodeWithEct(theta, lambda, tsize);
            
            // The leaf must be a gray one
            assert(theta[leaf_idx]._time == MININT && lambda[leaf_idx]._gTime != MININT);
            
            // Map leaf index to task ID
            const ORUInt array_idx = (offset <= leaf_idx ? leaf_idx - offset : (leaf_idx + size) - offset);
            const ORUInt k = disj->_task_id_est[array_idx];
            const ORUInt k0 = k - disj->_low;
            assert(leaf_idx == idx_map_est[k0]);
            
            // Set to absent
            [disj->_tasks[k] labelPresent: FALSE];
            
            // Remove from Lambda tree
            insertLambdaNodeAtIdxEct(theta, lambda, tsize, idx_map_est[k0], 0, MININT);
        }
    }
}

/*******************************************************************************
 Detectable Precedences Filtering Algorithms
 ******************************************************************************/

// Detectable Precedences from Vilim
//  Time: O(n log n)
//  Space: O(n)
//
// TODO Check whether the algorithm is sound when a task has a minimal duration
//      of zero!
//
static void dprec_filter_est_and_lct_vilim(CPTaskDisjunctive * disj, const ORInt size, const ORUInt * idx_map_est, const ORUInt * idx_map_lct, ThetaTree * theta, const ORUInt tsize, bool * update)
{
    dprec_filter_est_vilim(disj, size, idx_map_est, theta, tsize, update);
    dprec_filter_lct_vilim(disj, size, idx_map_lct, theta, tsize, update);
    if (update) updateBounds(disj, size);
}

static void dprec_filter_est_vilim(CPTaskDisjunctive * disj, const ORInt size, const ORUInt * idx_map_est, ThetaTree * theta, const ORUInt tsize, bool * update)
{
    // Inititialise Theta tree
    initThetaTree(theta, tsize, MININT);
    ORInt jj = disj->_beginIdx;
//    ORInt jj = 0;
    ORUInt j0 = disj->_task_id_lst[jj] - disj->_low;
    // Outer loop:
    //  Iterating over the tasks in ascending order of their earliest completion time
    for (ORInt ii = disj->_beginIdx; ii < disj->_endIdx; ii++) {
//    for (ORInt ii = 0; ii < size; ii++) {
        const ORInt i0 = disj->_task_id_ect[ii] - disj->_low;
        // Inner loop:
        // Iterating over the tasks in ascending order of their latest start time
        while (jj < disj->_endIdx && disj->_est[i0] + disj->_dur_min[i0] > disj->_lct[j0] - disj->_dur_min[j0]) {
//        while (jj < size && disj->_est[i0] + disj->_dur_min[i0] > disj->_lct[j0] - disj->_dur_min[j0]) {
            // Task 'j' precedes task 'i'
            const ORUInt tree_idx = idx_map_est[j0];
            insertThetaNodeAtIdxEct(theta, tsize, tree_idx, disj->_dur_min[j0], disj->_est[j0] + disj->_dur_min[j0]);
            jj++;
            j0 = disj->_task_id_lst[jj] - disj->_low;
        };
        // Computing the maximal earliest completion time of the tasks in the tree
        // excluding the task 'i'
        ORInt ect_t;
        if (disj->_est[i0] + disj->_dur_min[i0] > disj->_lct[i0] - disj->_dur_min[i0]) {
            // Task 'i' is in the tree
            insertThetaNodeAtIdxEct(theta, tsize, idx_map_est[i0], 0, MININT);
            ect_t = theta[0]._time;
            insertThetaNodeAtIdxEct(theta, tsize, idx_map_est[i0], disj->_dur_min[i0], disj->_est[i0] + disj->_dur_min[i0]);
        }
        else {
            // Task 'i' is not in the tree
            ect_t = theta[0]._time;
        }
        // Checking for a new bound update
        if (ect_t > disj->_est[i0]) {
            // New lower bound found
            disj->_new_est[i0] = ect_t;
            *update = true;
        }
    }
}

static void dprec_filter_lct_vilim(CPTaskDisjunctive * disj, const ORInt size, const ORUInt * idx_map_lct, ThetaTree * theta, const ORUInt tsize, bool * update)
{
    // Inititialise Theta tree
    initThetaTree(theta, tsize, MAXINT);
    ORInt jj = disj->_endIdx - 1;
//    ORInt jj = size - 1;
    ORUInt j0 = disj->_task_id_ect[jj] - disj->_low;
    // Outer loop:
    // Iterating over the tasks in descending order of their latest start time
    for (ORInt ii = disj->_endIdx - 1; ii >= 0; ii--) {
//    for (ORInt ii = size - 1; ii >= 0; ii--) {
        const ORUInt i0 = disj->_task_id_lst[ii] - disj->_low;
        // Inner loop:
        // Iterating over the tasks in descending order of their earliest completion time
        while (jj >= disj->_beginIdx && disj->_lct[i0] - disj->_dur_min[i0] < disj->_est[j0] + disj->_dur_min[j0]) {
//        while (jj >= 0 && disj->_lct[i0] - disj->_dur_min[i0] < disj->_est[j0] + disj->_dur_min[j0]) {
            // Task 'i' precedes task 'j'
            insertThetaNodeAtIdxLst(theta, tsize, idx_map_lct[j0], disj->_dur_min[j0], disj->_lct[j0] - disj->_dur_min[j0]);
            jj--;
            j0 = disj->_task_id_ect[jj] - disj->_low;
        }
        // Computing the minimal latest start time of the tasks in the tree
        // excluding the task 'i'
        ORInt lst_t;
        if (disj->_lct[i0] - disj->_dur_min[i0] < disj->_est[i0] + disj->_dur_min[i0]) {
            // Task 'i' is in the tree
            insertThetaNodeAtIdxLst(theta, tsize, idx_map_lct[i0], 0, MAXINT);
            lst_t = theta[0]._time;
            insertThetaNodeAtIdxLst(theta, tsize, idx_map_lct[i0], disj->_dur_min[i0], disj->_lct[i0] - disj->_dur_min[i0]);
        }
        else {
            lst_t = theta[0]._time;
        }
        // Checking for a new bound update
        if (lst_t < disj->_lct[i0]) {
            // New upper bound found
            //            printf("New upper bound for task %d (idx %d): %d -> %d\n", i, idx_map_lct[i], disj->_new_lct[i], lst_t);
            //            dumpThetaTree(theta, tsize);
            disj->_new_lct[i0] = lst_t;
            *update = true;
        }
    }
}


static void dprec_filter_est_and_lct_optional_vilim(CPTaskDisjunctive * disj, const ORInt size, const ORUInt * idx_map_est, const ORUInt * idx_map_lct, ThetaTree * theta, LambdaTree * lambda, const ORUInt tsize, const ORUInt tdepth, bool * update)
{
    dprec_filter_est_optional_vilim(disj, size, idx_map_est, theta, lambda, tsize, tdepth, update);
    dprec_filter_lct_optional_vilim(disj, size, idx_map_lct, theta, lambda, tsize, tdepth, update);
    if (update) updateBounds(disj, size);
}

static void dprec_filter_est_optional_vilim(CPTaskDisjunctive * disj, const ORInt size, const ORUInt * idx_map_est, ThetaTree * theta, LambdaTree * lambda, const ORUInt tsize, const ORUInt tdepth, bool * update)
{
    // Initialise Theta-Lambda tree
    initThetaTree( theta,  tsize, MININT);
    initLambdaTree(lambda, tsize, MININT);
    // 'offset' reflects the total of nodes in the trees except the nodes in the deepest level
    const ORUInt offset = (1 << tdepth) - 1;
    // Initialisations for the inner while-loop
    ORInt jj = 0;
    ORInt j0 = disj->_task_id_lst[jj] - disj->_low;
    // Outer loop:
    //  Iterating over the tasks in ascending order of their earliest completion time
    for (ORInt ii = 0; ii < size; ii++) {
        const ORInt i0 = disj->_task_id_ect[ii] - disj->_low;
        // Check for absent activities
        if (isIrrelevant(disj, i0)) continue;
        // Inner loop:
        // Iterating over the tasks in ascending order of their latest start time
        while (jj < size && disj->_est[i0] + disj->_dur_min[i0] > disj->_lct[j0] - disj->_dur_min[j0]) {
            // Task 'j' precedes task 'i'
            const ORUInt tree_idx = idx_map_est[j0];
            const ORInt  dur_j    = disj->_dur_min[j0];
            const ORInt  ect_j    = disj->_dur_min[j0] + disj->_est[j0];
            // Insert activity in Theta-Lambda tree
            if (isRelevant(disj, j0)) {
                // Compulsory activity or present optional activity
                insertThetaNodeAtIdxEct(theta, tsize, tree_idx, dur_j, ect_j);
                // Update Lambda tree
                insertLambdaNodeAtIdxEct(theta, lambda, tsize, tree_idx, 0, MININT);
            }
            else if (!isIrrelevant(disj, j0)) {
                // Optional activity
                insertLambdaNodeAtIdxEct(theta, lambda, tsize, tree_idx, dur_j, ect_j);
                //                printf("Optional: ");
            }
            jj++;
            j0 = disj->_task_id_lst[jj] - disj->_low;
        };
        // Computing the maximal earliest completion time of the tasks in the tree
        // excluding the task 'i'
        const ORBool inTheta_i = (isRelevant(disj, i0) && disj->_est[i0] + disj->_dur_min[i0] > disj->_lct[i0] - disj->_dur_min[i0]);
        ORInt ect_t = theta[0]._time;
        if (inTheta_i) {
            // Task 'i' is in the Theta tree
            insertThetaNodeAtIdxEct(theta, tsize, idx_map_est[i0], 0, MININT);
            // Update Lambda tree
            insertLambdaNodeAtIdxEct(theta, lambda, tsize, idx_map_est[i0], 0, MININT);
            ect_t = theta[0]._time;
        }
        if (isRelevant(disj, i0)) {
            // Detection of potential overloads
            //
            while (lambda[0]._gTime > disj->_lct[i0] - disj->_dur_min[i0]) {
                // Retrieve responsible leaf
                const ORUInt leaf_idx = retrieveResponsibleLambdaNodeWithEct(theta, lambda, tsize);
                // The leaf must be a gray one
                if (theta[leaf_idx]._time != MININT || lambda[leaf_idx]._gTime == MININT) {
                    break;
                    dumpThetaTree(theta, tsize);
                    dumpLambdaTree(lambda, tsize);
                }
                assert(theta[leaf_idx]._time == MININT && lambda[leaf_idx]._gTime != MININT);
                // Map leaf index to task ID
                const ORUInt array_idx = (offset <= leaf_idx ? leaf_idx - offset : (leaf_idx + size) - offset);
                const ORUInt k  = disj->_task_id_est[array_idx];
                const ORUInt k0 = k - disj->_low;
                assert(leaf_idx == idx_map_est[k0]);
                
                // Set to absent
                [disj->_tasks[k] labelPresent: FALSE];
                // Remove from Lambda tree
                insertLambdaNodeAtIdxEct(theta, lambda, tsize, idx_map_est[k0], 0, MININT);
            }
        }
        if (inTheta_i) {
            // Insert activity 'i' in Theta tree
            insertThetaNodeAtIdxEct(theta, tsize, idx_map_est[i0], disj->_dur_min[i0], disj->_est[i0] + disj->_dur_min[i0]);
            // Update Lambda tree
            insertLambdaNodeAtIdxEct(theta, lambda, tsize, idx_map_est[i0], 0, MININT);
        }
        // Checking for a new bound update
        if (ect_t > disj->_est[i0]) {
            if (ect_t > disj->_lct[i0] - disj->_dur_min[i0])
                failNow();
            // New lower bound found
            disj->_new_est[i0] = ect_t;
            *update = true;
        }
    }
}

static void dprec_filter_lct_optional_vilim(CPTaskDisjunctive * disj, const ORInt size, const ORUInt * idx_map_lct, ThetaTree * theta, LambdaTree * lambda, const ORUInt tsize, const ORUInt tdepth, bool * update)
{
    // Inititialise Theta-Lambda tree
    initThetaTree( theta,  tsize, MAXINT);
    initLambdaTree(lambda, tsize, MAXINT);
    // 'offset' reflects the total of nodes in the trees except the nodes in the deepest level
    const ORUInt offset = (1 << tdepth) - 1;
    ORInt jj = size - 1;
    ORUInt j0 = disj->_task_id_ect[jj] - disj->_low;
    // Outer loop:
    // Iterating over the tasks in descending order of their latest start time
    for (ORInt ii = size - 1; ii >= 0; ii--) {
        const ORUInt i0 = disj->_task_id_lst[ii] - disj->_low;
        // Check for absent activities
        if (isIrrelevant(disj, i0)) continue;
        // Inner loop:
        // Iterating over the tasks in descending order of their earliest completion time
        while (jj >= 0 && disj->_lct[i0] - disj->_dur_min[i0] < disj->_est[j0] + disj->_dur_min[j0]) {
            // Task 'i' succeeds task 'j'
            const ORUInt tree_idx = idx_map_lct[j0];
            const ORInt  dur_j    = disj->_dur_min[j0];
            const ORInt  lst_j    = disj->_lct[j0] - disj->_dur_min[j0];
            // Insert activity in Theta-Lambda tree
            if (isRelevant(disj, j0)) {
                // Compulsory or present optional activity
                insertThetaNodeAtIdxLst(theta, tsize, tree_idx, dur_j, lst_j);
                // Update Lambda tree
                insertLambdaNodeAtIdxLst(theta, lambda, tsize, tree_idx, dur_j, lst_j);
            }
            else if (!isIrrelevant(disj, j0)) {
                // Optional activity
                insertLambdaNodeAtIdxLst(theta, lambda, tsize, tree_idx, dur_j, lst_j);
            }
            jj--;
            j0 = disj->_task_id_ect[jj] - disj->_low;
        }
        // Computing the minimal latest start time of the tasks in the tree
        // excluding the task 'i'
        const ORBool inTheta_i = (isRelevant(disj, i0) && disj->_lct[i0] - disj->_dur_min[i0] < disj->_est[i0] + disj->_dur_min[i0]);
        ORInt lst_t = theta[0]._time;
        if (inTheta_i) {
            // Task 'i' is in Theta tree
            insertThetaNodeAtIdxLst(theta, tsize, idx_map_lct[i0], 0, MAXINT);
            // Update Lambda tree
            insertLambdaNodeAtIdxLst(theta, lambda, tsize, idx_map_lct[i0], 0, MAXINT);
            lst_t = theta[0]._time;
        }
        // Detection of potential overloads
        if (isRelevant(disj, i0)) {
            while (lambda[0]._gTime < disj->_est[i0] + disj->_dur_min[i0]) {
                // Retrieve responsible leaf
                const ORInt leaf_idx = retrieveResponsibleLambdaNodeWithLst(theta, lambda, tsize);
                // The leaf must be a gray one
                if (theta[leaf_idx]._time != MAXINT || lambda[leaf_idx]._gTime == MAXINT) {
                    break;
                }
                assert(theta[leaf_idx]._time == MAXINT && lambda[leaf_idx]._gTime != MAXINT);
                // Map leaf index to task ID
                const ORUInt array_idx = (offset <= leaf_idx ? leaf_idx - offset : (leaf_idx + size) - offset);
                const ORUInt k  = disj->_task_id_lct[array_idx];
                const ORUInt k0 = k - disj->_low;
                assert(leaf_idx == idx_map_lct[k0]);
                // Set to absent
                [disj->_tasks[k] labelPresent: FALSE];
                // Remove task 'k' from the Lambda tree
                insertLambdaNodeAtIdxLst(theta, lambda, tsize, idx_map_lct[k0], 0, MAXINT);
            }
        }
        if (inTheta_i) {
            // Insert activity 'i' in Theta tree
            insertThetaNodeAtIdxLst(theta, tsize, idx_map_lct[i0], disj->_dur_min[i0], disj->_lct[i0] - disj->_dur_min[i0]);
            // Update Lambda tree
            insertLambdaNodeAtIdxLst(theta, lambda, tsize, idx_map_lct[i0], 0, MAXINT);
        }
        // Checking for a new bound update
        if (lst_t < disj->_lct[i0]) {
            // New upper bound found
            disj->_new_lct[i0] = lst_t;
            *update = true;
        }
    }
}


/*******************************************************************************
 Not-First/Not-Last Filtering Algorithms
 ******************************************************************************/

// Not-first/not-last algorithms from Vilim
//  Time: O(n log n)
//  Space: O(n)
//
//  NOTE: Tasks with a minimal duration of zero will be ignored.
//
static void nfnl_filter_est_and_lct_vilim(CPTaskDisjunctive * disj, const ORInt size, const ORUInt * idx_map_est, const ORUInt * idx_map_lct, ThetaTree * theta, const ORUInt tsize, bool * update)
{
    nfnl_filter_est_vilim(disj, size, idx_map_lct, theta, tsize, update);
    nfnl_filter_lct_vilim(disj, size, idx_map_est, theta, tsize, update);
    if (update) updateBounds(disj, size);
}

static void nfnl_filter_est_vilim(CPTaskDisjunctive * disj, const ORInt size, const ORUInt * idx_map_lct, ThetaTree * theta, const ORUInt tsize, bool * update)
{
    // Initialise Theta tree
    initThetaTree(theta, tsize, MAXINT);
    ORInt jj = disj->_endIdx - 1;
//    ORInt jj = size - 1;
    ORUInt j0 = disj->_task_id_ect[jj] - disj->_low;
    ORUInt jLastInserted0 = MAXINT;
    // Outer loop:
    // Iterating over the tasks in descending order of their earliest start time
    for (ORInt ii = disj->_endIdx - 1; ii >= disj->_beginIdx; ii--) {
//    for (ORInt ii = size - 1; ii >= 0; ii--) {
        const ORUInt i0 = disj->_task_id_est[ii] - disj->_low;
        // No propagation on tasks with zero duration
        if (disj->_dur_min[i0] == 0) continue;
        // Inner loop:
        // Iterating over the tasks in descending order of their earliest completion time
        while (jj >= disj->_beginIdx && disj->_est[i0] < disj->_est[j0] + disj->_dur_min[j0]) {
//        while (jj >= 0 && disj->_est[i0] < disj->_est[j0] + disj->_dur_min[j0]) {
            if (disj->_dur_min[j0] > 0) {
                // Checking for a new bound update of task 'j'
                if (theta[0]._time < disj->_est[j0] + disj->_dur_min[j0]) {
                    disj->_new_est[j0] = disj->_est[jLastInserted0] + disj->_dur_min[jLastInserted0];
                    *update = true;
                }
                // Inserting task 'j' into the tree
                insertThetaNodeAtIdxLst(theta, tsize, idx_map_lct[j0], disj->_dur_min[j0], disj->_lct[j0] - disj->_dur_min[j0]);
                jLastInserted0 = j0;
            }
            j0 = disj->_task_id_ect[--jj] - disj->_low;
        }
        assert(disj->_est[i0] < disj->_est[i0] + disj->_dur_min[i0]);
        assert(jj < (ORInt) (size - 1));
        assert(0 <= jLastInserted0 && jLastInserted0 < size);
        // Task 'i' is in the tree
        insertThetaNodeAtIdxLst(theta, tsize, idx_map_lct[i0], 0, MAXINT);
        const ORInt lst_t = theta[0]._time;
        insertThetaNodeAtIdxLst(theta, tsize, idx_map_lct[i0], disj->_dur_min[i0], disj->_lct[i0] - disj->_dur_min[i0]);
        // Checking for a new bound update
        if (lst_t < disj->_est[i0] + disj->_dur_min[i0] && disj->_new_est[i0] < disj->_est[jLastInserted0] + disj->_dur_min[jLastInserted0]) {
            // New lower bound found
            disj->_new_est[i0] = disj->_est[jLastInserted0] + disj->_dur_min[jLastInserted0];
            *update = true;
        }
    }
}

static void nfnl_filter_lct_vilim(CPTaskDisjunctive * disj, const ORInt size, const ORUInt * idx_map_est, ThetaTree * theta, const ORUInt tsize, bool * update)
{
    // Inititialise Theta tree
    initThetaTree(theta, tsize, MININT);
    ORInt jj = disj->_beginIdx;
//    ORInt jj = 0;
    ORUInt j0 = disj->_task_id_lst[jj] - disj->_low;
    ORUInt jLastInserted0 = MAXINT;
    // Outer loop:
    // Iterating over the tasks in ascending order of their latest completion time
    for (ORInt ii = disj->_beginIdx; ii < size; ii++) {
//    for (ORInt ii = 0; ii < size; ii++) {
        const ORUInt i0 = disj->_task_id_lct[ii] - disj->_low;
        // No propagation on tasks with zero duration
        if (disj->_dur_min[i0] == 0) continue;
        // Inner loop:
        // Iterating over the tasks in ascending order of their latest start time
        while (jj < disj->_endIdx && disj->_lct[i0] > disj->_lct[j0] - disj->_dur_min[j0]) {
//        while (jj < size && disj->_lct[i0] > disj->_lct[j0] - disj->_dur_min[j0]) {
            if (disj->_dur_min > 0) {
                // Checking for a new bound update of task 'j'
                if (theta[0]._time > disj->_lct[j0] - disj->_dur_min[j0]) {
                    assert(disj->_new_lct[j0] > disj->_lct[jLastInserted0] - disj->_dur_min[jLastInserted0]);
                    disj->_new_lct[j0] = disj->_lct[jLastInserted0] - disj->_dur_min[jLastInserted0];
                    *update = true;
                }
                // Inserting task 'j' into the tree
                insertThetaNodeAtIdxEct(theta, tsize, idx_map_est[j0], disj->_dur_min[j0], disj->_est[j0] + disj->_dur_min[j0]);
                jLastInserted0 = j0;
            }
            j0 = disj->_task_id_lst[++jj] - disj->_low;
        }
        assert(disj->_lct[i0] > disj->_lct[i0] - disj->_dur_min[i0]);
        assert(jj > 0);
        assert(0 <= jLastInserted0 && jLastInserted0 < (ORInt) size);
        // Task 'i' is in the tree
        insertThetaNodeAtIdxEct(theta, tsize, idx_map_est[i0], 0, MININT);
        const ORInt ect_t = theta[0]._time;
        insertThetaNodeAtIdxEct(theta, tsize, idx_map_est[i0], disj->_dur_min[i0], disj->_est[i0] + disj->_dur_min[i0]);
        // Checking for a new bound update
        if (ect_t > disj->_lct[i0] - disj->_dur_min[i0] && disj->_new_lct[i0] > disj->_lct[jLastInserted0] - disj->_dur_min[jLastInserted0]) {
            // New upper bound found
            disj->_new_lct[i0] = disj->_lct[jLastInserted0] - disj->_dur_min[jLastInserted0];
            *update = true;
        }
    }
}


static void nfnl_filter_est_and_lct_optional_vilim(CPTaskDisjunctive * disj, const ORInt size, const ORUInt * idx_map_est, const ORUInt * idx_map_lct, ThetaTree * theta, LambdaTree * lambda,  const ORUInt tsize, const ORUInt tdepth, bool * update)
{
    nfnl_filter_est_optional_vilim(disj, size, idx_map_lct, theta, lambda, tsize, tdepth, update);
    nfnl_filter_lct_optional_vilim(disj, size, idx_map_est, theta, lambda, tsize, tdepth, update);
    if (update) updateBounds(disj, size);
}

static void nfnl_filter_est_optional_vilim(CPTaskDisjunctive * disj, const ORInt size, const ORUInt * idx_map_lct, ThetaTree * theta, LambdaTree * lambda, const ORUInt tsize, const ORUInt tdepth, bool * update)
{
    // Initialise Theta-Lambda tree
    initThetaTree( theta,  tsize, MAXINT);
    initLambdaTree(lambda, tsize, MAXINT);
    // 'offset' reflects the total of nodes in the trees except the nodes in the deepest level
    const ORUInt offset = (1 << tdepth) - 1;
    ORInt jj = size - 1;
    ORUInt j0 = disj->_task_id_ect[jj] - disj->_low;
    ORUInt jLastInserted = MAXINT;
    ORUInt jLastInserted2 = MAXINT;
    // Outer loop:
    // Iterating over the tasks in descending order of their earliest start time
    for (ORInt ii = size - 1; ii >= 0; ii--) {
        const ORUInt i0 = disj->_task_id_est[ii] - disj->_low;
        // Check for absent activities
        if (isIrrelevant(disj, i0)) continue;
        // No propagation on tasks with zero duration
        if (disj->_dur_min[i0] == 0) continue;
        // Inner loop:
        // Iterating over the tasks in descending order of their earliest completion time
        while (jj >= 0 && disj->_est[i0] < disj->_est[j0] + disj->_dur_min[j0]) {
            if (disj->_dur_min[j0] > 0 && !isIrrelevant(disj, j0)) {
                const ORInt tree_idx = idx_map_lct[j0];
                const ORInt dur_j    = disj->_dur_min[j0];
                const ORInt lst_j    = disj->_lct[j0] - disj->_dur_min[j0];
                if (isRelevant(disj, j0)) {
                    // Checking for a new bound update of task 'j'
                    if (theta[0]._time < disj->_est[j0] + disj->_dur_min[j0]) {
                        disj->_new_est[j0] = disj->_est[jLastInserted] + disj->_dur_min[jLastInserted];
                        *update = true;
                    }
                    jLastInserted = j0;
                    // Insert activity 'j' in Theta tree
                    insertThetaNodeAtIdxLst(theta, tsize, tree_idx, dur_j, lst_j);
                    // Update Lambda tree
                    insertLambdaNodeAtIdxLst(theta, lambda, tsize, tree_idx, 0, MAXINT);
                }
                else {
                    // Insert activity 'j' in Lambda tree
                    insertLambdaNodeAtIdxLst(theta, lambda, tsize, tree_idx, dur_j, lst_j);
                }
                jLastInserted2 = j0;
            }
            j0 = disj->_task_id_ect[--jj] - disj->_low;
        }
        // Check whether a present activity is in Theta tree
        if (jLastInserted == MAXINT) continue;
        assert(disj->_est[i0] < disj->_est[i0] + disj->_dur_min[i0]);
        assert(jj < (ORInt) (size - 1));
        assert(0 <= jLastInserted && jLastInserted < size);
        
        const ORBool inTheta_i = isRelevant(disj, i0);
        ORInt lst_t = theta[0]._time;
        if (inTheta_i) {
            // Activity 'i' is in Theta tree
            insertThetaNodeAtIdxLst(theta, tsize, idx_map_lct[i0], 0, MAXINT);
            // Update Lambda tree
            insertLambdaNodeAtIdxLst(theta, lambda, tsize, idx_map_lct[i0], 0, MAXINT);
            lst_t = theta[0]._time;
        }
        // Checking for a new bound
        if (lst_t < disj->_est[i0] + disj->_dur_min[i0] && disj->_new_est[i0] < disj->_est[jLastInserted] + disj->_dur_min[jLastInserted]) {
            // New lower bound found
            disj->_new_est[i0] = disj->_est[jLastInserted] + disj->_dur_min[jLastInserted];
            *update = true;
        }
        // Detection of possible overloads
        if (jLastInserted2 < MAXINT && isRelevant(disj, i0) && disj->_lct[i0] - disj->_dur_min[i0] < disj->_est[jLastInserted2] + disj->_dur_min[jLastInserted2]) {
            while (lambda[0]._gTime < disj->_est[i0] + disj->_dur_min[i0]) {
                // Retrieve responsible leaf
                const ORInt leaf_idx = retrieveResponsibleLambdaNodeWithLst(theta, lambda, tsize);
                // The leaf must be a gray one
                if (theta[leaf_idx]._time != MAXINT || lambda[leaf_idx]._gTime == MAXINT) {
                    break;
                }
                assert(theta[leaf_idx]._time == MAXINT && lambda[leaf_idx]._gTime != MAXINT);
                // Map leaf index to task ID
                const ORUInt array_idx = (offset <= leaf_idx ? leaf_idx - offset : (leaf_idx + size) - offset);
                const ORUInt k = disj->_task_id_lct[array_idx];
                const ORUInt k0 = k - disj->_low;
                assert(leaf_idx == idx_map_lct[k0]);
                // Set to absent
                [disj->_tasks[disj->_idx[k]] labelPresent: FALSE];
                // Remove task 'k' from the Lambda tree
                insertLambdaNodeAtIdxLst(theta, lambda, tsize, idx_map_lct[k0], 0, MAXINT);
            }
        }
        if (inTheta_i) {
            // Insert activity 'i' in Theta tree
            insertThetaNodeAtIdxLst(theta, tsize, idx_map_lct[i0], disj->_dur_min[i0], disj->_lct[i0] - disj->_dur_min[i0]);
            // Update Lambda tree
            insertLambdaNodeAtIdxLst(theta, lambda, tsize, idx_map_lct[i0], 0, MAXINT);
        }
    }
}


static void nfnl_filter_lct_optional_vilim(CPTaskDisjunctive * disj, const ORInt size, const ORUInt * idx_map_est, ThetaTree * theta, LambdaTree * lambda, const ORUInt tsize, const ORUInt tdepth, bool * update)
{
    // Initialise Theta-Lambda tree
    initThetaTree( theta,  tsize, MININT);
    initLambdaTree(lambda, tsize, MININT);
    // 'offset' reflects the total of nodes in the trees except the nodes in the deepest level
    const ORUInt offset = (1 << tdepth) - 1;
    ORInt jj = 0;
    ORUInt j0 = disj->_task_id_lst[jj] - disj->_low;
    ORUInt jLastInserted  = MAXINT;
    ORUInt jLastInserted2 = MAXINT;
    // Outer loop:
    // Iterating over the tasks in ascending order of their latest completion time
    for (ORInt ii = 0; ii < size; ii++) {
        const ORUInt i0 = disj->_task_id_lct[ii] - disj->_low;
        // Check for absent activities
        if (isIrrelevant(disj, i0)) continue;
        // No propagation on tasks with zero duration
        if (disj->_dur_min[i0] == 0) continue;
        // Inner loop:
        // Iterating over the tasks in ascending order of their latest start time
        while (jj < size && disj->_lct[i0] > disj->_lct[j0] - disj->_dur_min[j0]) {
            if (disj->_dur_min > 0 && !isIrrelevant(disj, j0)) {
                const ORInt tree_idx = idx_map_est[j0];
                const ORInt dur_j    = disj->_dur_min[j0];
                const ORInt ect_j    = disj->_est[j0] + disj->_dur_min[j0];
                if (isRelevant(disj, j0)) {
                    // Checking for a new bound update of task 'j'
                    if (theta[0]._time > disj->_lct[j0] - disj->_dur_min[j0]) {
                        assert(disj->_new_lct[j0] > disj->_lct[jLastInserted] - disj->_dur_min[jLastInserted]);
                        disj->_new_lct[j0] = disj->_lct[jLastInserted] - disj->_dur_min[jLastInserted];
                        *update = true;
                    }
                    // Inserting task 'j' into Theta tree
                    insertThetaNodeAtIdxEct(theta, tsize, tree_idx, dur_j, ect_j);
                    // Update Lambda tree
                    insertLambdaNodeAtIdxEct(theta, lambda, tsize, tree_idx, 0, MININT);
                    jLastInserted = j0;
                }
                else {
                    // Insert activity 'j' into Lambda tree
                    insertLambdaNodeAtIdxEct(theta, lambda, tsize, tree_idx, dur_j, ect_j);
                }
                jLastInserted2 = j0;
            }
            j0 = disj->_task_id_lst[++jj] - disj->_low;
        }
        // Check whether a present activity is in Theta tree
        if (jLastInserted == MAXINT) continue;
        assert(disj->_lct[i0] > disj->_lct[i0] - disj->_dur_min[i0]);
        assert(jj > 0);
        assert(0 <= jLastInserted && jLastInserted < (ORInt) size);
        // Task 'i' is in Theta-Lambda tree
        const ORBool inTheta_i = isRelevant(disj, i0);
        ORInt ect_t = theta[0]._time;
        if (inTheta_i) {
            // Activity 'i' in Theta tree
            insertThetaNodeAtIdxEct(theta, tsize, idx_map_est[i0], 0, MININT);
            // Update Lambda tree
            insertLambdaNodeAtIdxEct(theta, lambda, tsize, idx_map_est[i0], 0, MININT);
            ect_t = theta[0]._time;
        }
        // Checking for a new bound update
        if (ect_t > disj->_lct[i0] - disj->_dur_min[i0] && disj->_new_lct[i0] > disj->_lct[jLastInserted] - disj->_dur_min[jLastInserted]) {
            // New upper bound found
            disj->_new_lct[i0] = disj->_lct[jLastInserted] - disj->_dur_min[jLastInserted];
            *update = true;
        }
        if (jLastInserted2 < MAXINT && isRelevant(disj, i0) && disj->_lct[jLastInserted2] - disj->_dur_min[jLastInserted2] < disj->_est[i0] + disj->_dur_min[i0]) {
            // Detection of potential overloads
            while (lambda[0]._gTime > disj->_lct[i0] - disj->_dur_min[i0]) {
                // Retrieve responsible leaf
                const ORUInt leaf_idx = retrieveResponsibleLambdaNodeWithEct(theta, lambda, tsize);
                // The leaf must be a gray one
                if (theta[leaf_idx]._time != MININT || lambda[leaf_idx]._gTime == MININT) {
                    break;
                }
                assert(theta[leaf_idx]._time == MININT && lambda[leaf_idx]._gTime != MININT);
                // Map leaf index to task ID
                const ORUInt array_idx = (offset <= leaf_idx ? leaf_idx - offset : (leaf_idx + size) - offset);
                const ORUInt k = disj->_task_id_est[array_idx];
                const ORUInt k0 = k - disj->_low;
                assert(leaf_idx == idx_map_est[k0]);
                // Set to absent
                [disj->_tasks[k] labelPresent: FALSE];
                // Remove from Lambda tree
                insertLambdaNodeAtIdxEct(theta, lambda, tsize, idx_map_est[k0], 0, MININT);
            }
        }
        if (inTheta_i) {
            // Insert activity 'i' in Theta tree
            insertThetaNodeAtIdxEct(theta, tsize, idx_map_est[i0], disj->_dur_min[i0], disj->_est[i0] + disj->_dur_min[i0]);
            // Updating Lambda tree
            insertLambdaNodeAtIdxEct(theta, lambda, tsize, idx_map_est[i0], 0, MININT);
        }
    }
}


/*******************************************************************************
 Edge-Finding Filtering Algorithms
 ******************************************************************************/

// Edge-Finding algorithms from Vilim
//  Time: O(n log n)
//  Space: O(n)
//
//  NOTE: Tasks with a minimal duration of zero will be ignored.
//
static void ef_filter_est_and_lct_vilim(CPTaskDisjunctive * disj, const ORInt size, const ORUInt * idx_map_est, const ORUInt * idx_map_lct, ThetaTree * theta, LambdaTree * lambda, const ORUInt tsize, const ORUInt tdepth, bool * update)
{
    ef_filter_est_vilim(disj, size, idx_map_est, theta, lambda, tsize, tdepth, update);
    ef_filter_lct_vilim(disj, size, idx_map_lct, theta, lambda, tsize, tdepth, update);
    if (update) updateBounds(disj, size);
}

static void ef_filter_est_vilim(CPTaskDisjunctive * disj, const ORInt size, const ORUInt * idx_map_est, ThetaTree * theta, LambdaTree * lambda, const ORUInt tsize, const ORUInt tdepth, bool * update)
{
    // Initialise Theta-Lambda tree with (T, {})
    initThetaLambdaTreeWithEct(disj, size, idx_map_est, theta, lambda, tsize);
    ORInt jj = disj->_endIdx - 1;
//    ORInt jj = size - 1;
    ORUInt j0 = disj->_task_id_lct[jj] - disj->_low;
    // 'offset' reflects the total of nodes in the trees except the nodes in the deepest level
    const ORUInt offset = (1 << tdepth) - 1;
    // Outer loop:
    // Iterating over the tasks in descending order of their latest completion time
    while (jj > disj->_beginIdx) {
//    while (jj > 0) {
        if (disj->_dur_min[j0] == 0) {
            j0 = disj->_task_id_lct[--jj] - disj->_low;
            continue;
        }
        // Remove task 'j' from Theta tree and insert task 'j' into Lambda tree
        insertThetaNodeAtIdxEct(theta, tsize, idx_map_est[j0], 0, MININT);
        insertLambdaNodeAtIdxEct(theta, lambda, tsize, idx_map_est[j0], disj->_dur_min[j0], disj->_est[j0] + disj->_dur_min[j0]);
        assert(jj - 1 >= 0);
        j0 = disj->_task_id_lct[--jj] - disj->_low;
        // Inner loop:
        // Iterating over the "responsible" tasks
        while (lambda[0]._gTime > disj->_lct[j0]) {
            // Retrieve responsible leaf
            const ORUInt leaf_idx = retrieveResponsibleLambdaNodeWithEct(theta, lambda, tsize);
            // The leaf must be a gray one
            assert(theta[leaf_idx]._time == MININT && lambda[leaf_idx]._gTime != MININT);
            // Map leaf index to task ID
            const ORUInt array_idx = (offset <= leaf_idx ? leaf_idx - offset : (leaf_idx + size) - offset);
            const ORUInt i0 = disj->_task_id_est[array_idx] - disj->_low;
            assert(leaf_idx == idx_map_est[i0]);
            // Check for a new bound update
            if (theta[0]._time > disj->_new_est[i0]) {
                // New lower bound was found
                disj->_new_est[i0] = theta[0]._time;
                *update = true;
            }
            // Remove task 'i' from Lambda tree
            insertLambdaNodeAtIdxEct(theta, lambda, tsize, idx_map_est[i0], 0, MININT);
        }
    }
}

static void ef_filter_lct_vilim(CPTaskDisjunctive * disj, const ORInt size, const ORUInt * idx_map_lct, ThetaTree * theta, LambdaTree * lambda, const ORUInt tsize, const ORUInt tdepth, bool * update)
{
    // Initialise Theta-Lambda tree with (T, {})
    initThetaLambdaTreeWithLst(disj, size, idx_map_lct, theta, lambda, tsize);
    ORInt jj = disj->_beginIdx;
//    ORInt jj = 0;
    ORUInt j0 = disj->_task_id_est[jj] - disj->_low;
    // 'offset' reflects the total of nodes in the trees except the nodes in the deepest level
    const ORUInt offset = (1 << tdepth) - 1;
    // Outer loop:
    // Iterating over the tasks in ascending order of their earliest start time
    while (jj < disj->_endIdx - 1) {
//    while (jj < size - 1) {
        if (disj->_dur_min[j0] == 0) {
            j0 = disj->_task_id_est[++jj] - disj->_low;
            continue;
        }
        // Remove task 'j' from Theta tree and insert task 'j' into Lambda tree
        insertThetaNodeAtIdxLst(theta, tsize, idx_map_lct[j0], 0, MAXINT);
        insertLambdaNodeAtIdxLst(theta, lambda, tsize, idx_map_lct[j0], disj->_dur_min[j0], disj->_lct[j0] - disj->_dur_min[j0]);
        
        j0 = disj->_task_id_est[++jj] - disj->_low;
        // Inner loop:
        // Iterating over the "responsible" tasks
        while (lambda[0]._gTime < disj->_est[j0]) {
            // Retrieve responsible leaf
            const ORInt leaf_idx = retrieveResponsibleLambdaNodeWithLst(theta, lambda, tsize);
            // The leaf must be a gray one
            assert(theta[leaf_idx]._time == MAXINT && lambda[leaf_idx]._gTime != MAXINT);
            // Map leaf index to task ID
            const ORUInt array_idx = (offset <= leaf_idx ? leaf_idx - offset : (leaf_idx + size) - offset);
            const ORUInt i0 = disj->_task_id_lct[array_idx] - disj->_low;
            assert(leaf_idx == idx_map_lct[i0]);
            // Check for a new bound update
            if (theta[0]._time < disj->_new_lct[i0]) {
                // New upper bound was found
                disj->_new_lct[i0] = theta[0]._time;
                *update = true;
            }
            // Remove task 'i' from the Lambda tree
            insertLambdaNodeAtIdxLst(theta, lambda, tsize, idx_map_lct[i0], 0, MAXINT);
        }
    }
}

// Edge-Finding algorithm
//  Time: O(n^2)
//  Space: O(n)
//
//  NOTE: Tasks with a minimal duration of zero will be ignored.
//
static void ef_filter_est_and_lct_nuijten(CPTaskDisjunctive * disj, const ORInt size, bool * update)
{
    ef_filter_est_nuijten(disj, size, update);
    ef_filter_lct_nuijten(disj, size, update);
    if (update) updateBounds(disj, size);
}

static void ef_filter_est_nuijten(CPTaskDisjunctive * disj, const ORInt size, bool * update)
{
    ORInt Ci[size];
    for (ORInt kk = 0; kk < size; kk++) {
        const ORInt k0 = disj->_task_id_est[kk] - disj->_low;
        if (disj->_dur_min[k0] <= 0)
            continue;
        ORInt P = 0;
        ORInt C = MININT;
        ORInt H = MININT;
        for (ORInt ii = size - 1; ii >= 0; ii--) {
            const ORInt i0 = disj->_task_id_est[ii] - disj->_low;
            if (disj->_dur_min[i0] <= 0)
                continue;
            if (disj->_lct[i0] <= disj->_lct[k0]) {
                P += disj->_dur_min[i0];
                C  = max(C, disj->_est[i0] + P);
            }
            Ci[ii] = C;
        }
        for (ORInt ii = 0; ii < size; ii++) {
            const ORInt i0 = disj->_task_id_est[ii] - disj->_low;
            if (disj->_dur_min[i0] <= 0)
                continue;
            if (disj->_lct[i0] <= disj->_lct[k0]) {
                H  = max(H, disj->_est[i0] + P);
                P -= disj->_dur_min[i0];
            }
            else {
                if (disj->_est[i0] + P + disj->_dur_min[i0] > disj->_lct[k0]) {
                    if (Ci[ii] > disj->_new_est[i0]) {
                        disj->_new_est[i0] = Ci[ii];
                        *update = true;
                    }
                }
                if (H + disj->_dur_min[i0] > disj->_lct[k0]) {
                    if (C > disj->_new_est[i0]) {
                        disj->_new_est[i0] = C;
                        *update = true;
                    }
                }
            }
        }
    }
}

static void ef_filter_lct_nuijten(CPTaskDisjunctive * disj, const ORInt size, bool * update)
{
    ORInt Ci[size];
    for (ORInt kk = size - 1; kk >= 0; kk--) {
        const ORInt k0 = disj->_task_id_lct[kk] - disj->_low;
        if (disj->_dur_min[k0] <= 0)
            continue;
        ORInt P = 0;
        ORInt C = MAXINT;
        ORInt H = MAXINT;
        for (ORInt ii = 0; ii < size; ii++) {
            const ORInt i0 = disj->_task_id_lct[ii] - disj->_low;
            if (disj->_dur_min[i0] <= 0)
                continue;
            if (disj->_est[i0] >= disj->_est[k0]) {
                P += disj->_dur_min[i0];
                C  = min(C, disj->_lct[i0] - P);
            }
            Ci[ii] = C;
        }
        for (ORInt ii = size - 1; ii >= 0; ii--) {
            const ORInt i0 = disj->_task_id_lct[ii] - disj->_low;
            if (disj->_dur_min[i0] <= 0)
                continue;
            if (disj->_est[i0] >= disj->_est[k0]) {
                H  = min(H, disj->_lct[i0] - P);
                P -= disj->_dur_min[i0];
            }
            else {
                if (disj->_lct[i0] - P - disj->_dur_min[i0] < disj->_est[k0]) {
                    if (Ci[ii] < disj->_new_lct[i0]) {
                        disj->_new_lct[i0] = Ci[ii];
                        *update = true;
                    }
                }
                if (H - disj->_dur_min[i0] < disj->_est[k0]) {
                    if (C < disj->_new_lct[i0]) {
                        disj->_new_lct[i0] = C;
                        *update = true;
                    }
                }
            }
        }
    }
}

// Edge-Finding algorithm
//  Time: O(n^2)
//  Space: O(n)
//
//  NOTE: Tasks with a minimal duration of zero will be ignored.
//
static void ef_filter_est_and_lct_optional(CPTaskDisjunctive * disj, const ORInt size, bool * update)
{
    ef_filter_est_optional(disj, size, update);
    ef_filter_lct_optional(disj, size, update);
    if (update) updateBounds(disj, size);
}

static void ef_filter_est_optional(CPTaskDisjunctive * disj, const ORInt size, bool * update)
{
    ORInt length = 0;
    // Outer loop:
    // Iterating over activities in ascending order of their latest completion time
    for (ORInt ii = 0; ii < size; ii++) {
        const ORInt i0 = disj->_task_id_lct[ii] - disj->_low;
        // Skip activities with no duration or non-present activities
        if (disj->_dur_min[i0] == 0 || !isRelevant(disj, i0)) continue;
        const ORInt end = disj->_lct[i0];
        // Determine the length of all present activities with latest completion
        // time less than or equal to 'end'
        length += disj->_dur_min[i0];
        // Initialisation for inner loop
        ORInt length_end  = length;
        ORInt ect_omega   = MININT;
//        ORInt begin_omega = MININT;
        
        // Inner loop:
        // Iterating over activities in ascending order of their earliest start time
        for (ORInt jj = 0; jj < size; jj++) {
            const ORInt j0 = disj->_task_id_est[jj] - disj->_low;
            // Skip activities with no duration or absent activities
            if (disj->_dur_min[j0] == 0 || isIrrelevant(disj, j0)) continue;
            
            if (disj->_lct[j0] <= end && isRelevant(disj, j0)) {
                // Activity 'j' is in the activity interval
                const ORInt ect_i = disj->_est[j0] + length_end;
                if (ect_i > ect_omega) {
                    ect_omega   = ect_i;
//                    begin_omega = disj->_est[j0];
                }
                length_end -= disj->_dur_min[j0];
            }
            else {
                // Activity 'j' is not in the activity interval
                // Bounds check for time interval [est(j), end)
                if (disj->_est[j0] + disj->_dur_min[j0] + length_end > end && disj->_est[j0] + length_end > disj->_new_est[j0]) {
                    // New lower bound was found
                    disj->_new_est[j0] = disj->_est[j0] + length_end;
                    *update = true;
                }
                // Bounds check for time interval [begin_omega, end)
                if (ect_omega + disj->_dur_min[j0] > end && ect_omega > disj->_new_est[j0]) {
                    // New lower bound was found
                    disj->_new_est[j0] = ect_omega;
                    *update = true;
                }
            }
        }
    }
}

static void ef_filter_lct_optional(CPTaskDisjunctive * disj, const ORInt size, bool * update)
{
    ORInt length = 0;
    // Outer loop:
    // Iterating over activities in descending order of their earliest start time
    for (ORInt ii = 0; ii < size; ii++) {
        const ORInt i0 = disj->_task_id_est[ii] - disj->_low;
        // Skip activities with no duration or non-present activities
        if (disj->_dur_min[i0] == 0 || !isRelevant(disj, i0)) continue;
        const ORInt begin = disj->_est[i0];
        // Determine the length of all present activities with an earliest start
        // time greater than or equal to 'end'
        length += disj->_dur_min[i0];
        // Initialisation for inner loop
        ORInt length_begin = length;
        ORInt lst_omega    = MAXINT;
//        ORInt end_omega    = MAXINT;
        
        // Inner loop:
        // Iterating over activities in descending order of their latest completion time
        for (ORInt jj = 0; jj < size; jj++) {
            const ORInt j0 = disj->_task_id_lct[jj] - disj->_low;
            // Skip activities with no duration or absent activities
            if (disj->_dur_min[j0] == 0 || isIrrelevant(disj, j0)) continue;
            
            if (begin <= disj->_est[j0] && isRelevant(disj, j0)) {
                // Activity 'j' is in time interval [begin, lct(j))
                const ORInt lst_j = disj->_lct[j0] - length_begin;
                if (lst_j < lst_omega) {
                    lst_omega = lst_j;
//                    end_omega = disj->_lct[j0];
                }
                length_begin -= disj->_dur_min[j0];
            }
            else {
                // Activity is not in the activity interval
                // Bounds check for time interval [begin, lct(j))
                if (disj->_lct[j0] - disj->_dur_min[j0] - length_begin < begin && disj->_lct[j0] - length_begin < disj->_new_lct[j0]) {
                    // New upper bound was found
                    disj->_new_lct[j0] = disj->_lct[j0] - length_begin;
                    *update = true;
                }
                // Bounds check for time interval [begin, end_omega)
                if (lst_omega - disj->_dur_min[j0] < begin && lst_omega < disj->_new_lct[j0]) {
                    // New upper bound was found
                    disj->_new_lct[j0] = lst_omega;
                    *update = true;
                }
            }
        }
    }
}

/*******************************************************************************
 Computation of the local and global slack
 ******************************************************************************/

static inline ORBool isUnfixed(CPTaskDisjunctive * disj, const ORInt i)
{
    return (disj->_lct[i] - disj->_est[i] - disj->_dur_min[i] > 0);
}

// The global slack measures the tightness of the resource for unfixed
// tasks. It only considers the time interval in that those tasks must be
// scheduled.
static ORInt getGlobalSlack(CPTaskDisjunctive * disj, const ORInt size)
{
    ORInt est_min = MAXINT;
    ORInt lct_max = MININT;
    ORInt len_min = 0;
    // Computing the tightest time interval [est_min, lct_max) that enclosed all
    // unfixed present tasks.
    for (ORInt i = 0; i < size; i++) {
        // XXX For the moment being only unfixed present activities are considered
        const ORInt t0 = disj->_idx[i] - disj->_low;
        if (isPresent(disj, t0) && isUnfixed(disj, t0)) {
            est_min = min(est_min, disj->_est[t0]);
            lct_max = max(lct_max, disj->_lct[t0]);
        }
    }
    // Suming up the length of present tasks that must be run in the pre-computed
    // time interval
    for (ORInt i = 0; i < size; i++) {
        // XXX For the moment being only unfixed present activities are considered
        const ORInt t0 = disj->_idx[i] - disj->_low;
        if (isPresent(disj, t0) && est_min <= disj->_est[t0] && disj->_lct[t0] <= lct_max) {
            len_min += disj->_dur_min[i];
        }
    }
    return (lct_max - est_min - len_min);
}

static ORInt getLocalSlack(CPTaskDisjunctive * disj)
{
    cleanUp(disj);
    
    // XXX Temporary assignment (it should be '_cIdx' or '_uIdx')
    const ORInt size = disj->_cIdx._val;
    const ORInt sortSize = disj->_uIdx._val;
    
    // Allocation of memory
//    disj->_est           = alloca(disj->_size * sizeof(ORInt ));
//    disj->_lct           = alloca(disj->_size * sizeof(ORInt ));
//    disj->_dur_min       = alloca(disj->_size * sizeof(ORInt ));
//    disj->_task_id_est   = alloca(size * sizeof(ORInt ));
//    disj->_task_id_lct   = alloca(size * sizeof(ORInt ));
    
    // Check whether memory allocation was successful
    if (disj->_est == NULL || disj->_lct == NULL || disj->_dur_min == NULL ||
        disj->_task_id_est == NULL || disj->_task_id_lct == NULL) {
        @throw [[ORExecutionError alloc] initORExecutionError: "CPTaskDisjunctive: Out of memory!"];
    }
    
    // Initialisation of the arrays
    for (ORInt tt = 0; tt < size; tt++) {
        const ORInt t  = disj->_idx[tt];
        const ORInt t0 = t - disj->_low;
        // XXX Only consider present activities for the moment
        assert(isRelevant(disj, t0));
        disj->_est    [t0] = [disj->_tasks[t] est        ];
        disj->_lct    [t0] = [disj->_tasks[t] lct        ];
        disj->_dur_min[t0] = [disj->_tasks[t] minDuration];
//        disj->_task_id_est[tt] = tt;
//        disj->_task_id_lct[tt] = tt;
    }
    
    // Sorting of the tasks
    // NOTE: qsort_r the 3rd argument of qsort_r is at the last position in glibc (GNU/Linux)
    // instead of the second last
    if (sortSize >= size) {
        isort_r(disj->_task_id_est, size, disj, (ORInt(*)(void*, const ORInt*, const ORInt*)) &sortDisjEstAsc);
        isort_r(disj->_task_id_lct, size, disj, (ORInt(*)(void*, const ORInt*, const ORInt*)) &sortDisjLctAsc);
    }
    else {
        isort_r(disj->_task_id_est, size, disj, (ORInt(*)(void*, const ORInt*, const ORInt*)) &sortDisjEstAscOpt);
        isort_r(disj->_task_id_lct, size, disj, (ORInt(*)(void*, const ORInt*, const ORInt*)) &sortDisjLctAscOpt);
    }
    
    ORInt localSlack = MAXINT;
    ORInt len_min = 0;
    ORInt jjPrev  = 0;
    ORInt jjLast  = size - 1;
    
    for (ORInt jj = size - 1; jj >= 0; jj--) {
        const ORInt j0 = disj->_task_id_lct[jj] - disj->_low;
        if (isUnfixed(disj, j0)) {
            jjLast = jj;
            break;
        }
    }
    
    for (ORInt ii = 0; ii < size; ii++) {
        const ORInt i0 = disj->_task_id_est[ii] - disj->_low;
        if (isUnfixed(disj, i0)) {
            const ORInt est_min = disj->_est[i0];
            ORBool first = true;
            len_min = 0;
            for (ORInt jj = jjPrev; jj <= jjLast; jj++) {
                const ORInt j0 = disj->_task_id_lct[jj] - disj->_low;
                if (est_min < disj->_lct[j0]) {
                    if (first) {
                        jjPrev = jj;
                        first = false;
                    }
                    if (isUnfixed(disj, j0)) {
                        if (est_min <= disj->_est[j0]) len_min += disj->_dur_min[j0];
                        localSlack = min(localSlack, disj->_lct[j0] - est_min - len_min);
                    }
                    else {
                        len_min += disj->_dur_min[j0];
                    }
                }
            }
        }
    }
    
    return localSlack;
}

/*******************************************************************************
 Computation of the contention profile
 ******************************************************************************/

// Computation of the contention profile for the earliest-start-time schedule
//
static Profile disjGetEarliestContentionProfile(CPTaskDisjunctive * disj)
{
    // FIXME
    assert(false);
    cleanUp(disj);
    
    // XXX Temporary assignment (it should be '_cIdx' or '_uIdx')
    const ORInt size = disj->_cIdx._val;
    
    // Allocation of memory
    disj->_est           = alloca(size * sizeof(ORInt));
    disj->_dur_min       = alloca(size * sizeof(ORInt));
    disj->_task_id_est   = alloca(size * sizeof(ORInt));
    disj->_task_id_ect   = alloca(size * sizeof(ORInt));
    
    // Check whether memory allocation was successful
    if (disj->_est == NULL || disj->_dur_min == NULL || disj->_task_id_est == NULL ||
        disj->_task_id_ect == NULL) {
        @throw [[ORExecutionError alloc] initORExecutionError: "CPTaskDisjunctive: Out of memory!"];
    }
    
    ORInt ect[size];
    ORInt h[  size];
    
    // Initialisation of the arrays
    for (ORInt tt = 0; tt < size; tt++) {
        const ORInt t = disj->_idx[tt];
        // XXX Only consider present activities for the moment
        assert(isRelevant(disj, disj->_idx[tt] - disj->_low));
        disj->_est[tt] = [disj->_tasks[t] est];
        disj->_dur_min[tt] = [disj->_tasks[t] minDuration];
        ect[tt] = [disj->_tasks[t] ect];
        disj->_task_id_est[tt] = tt;
        disj->_task_id_ect[tt] = tt;
        h[tt] = 1;
    }
    // Sorting of the tasks
    // NOTE: qsort_r the 3rd argument of qsort_r is at the last position in glibc (GNU/Linux)
    // instead of the second last
    qsort_r(disj->_task_id_est, size, sizeof(ORInt), disj, (int(*)(void*, const void*, const void*)) &sortDisjEstAsc);
    qsort_r(disj->_task_id_ect, size, sizeof(ORInt), disj, (int(*)(void*, const void*, const void*)) &sortDisjEctAsc);
    
    Profile prof = getEarliestContentionProfile(disj->_task_id_est, disj->_task_id_ect, disj->_est, ect, h, size);
    
    return prof;
}

/*******************************************************************************
 Functions regarding optional activities
 ******************************************************************************/

static inline void swapORInt(ORInt * arr, const ORInt i, const ORInt j)
{
    if (i != j) {
        const ORInt temp = arr[i];
        arr[i] = arr[j];
        arr[j] = temp;
    }
}

static void updateIndices(CPTaskDisjunctive * disj)
{
    if (disj->_cIdx._val < disj->_uIdx._val) {
        ORInt cIdx = disj->_cIdx._val;
        ORInt uIdx = disj->_uIdx._val;
        for (ORInt ii = cIdx; ii < uIdx; ii++) {
            const ORInt i0 = disj->_idx[ii] - disj->_low;
            if (isRelevant(disj, i0)) {
                // Swap elements in 'ii' and 'cIdx'
                swapORInt(disj->_idx, ii, cIdx++);
            } else if (isIrrelevant(disj, i0)) {
                // Swap elements in 'ii' and 'uIdx'
                swapORInt(disj->_idx, ii, --uIdx);
                ii--;
            }
        }
        // Update counters
        if (disj->_cIdx._val < cIdx) assignTRInt(&(disj->_cIdx), cIdx, disj->_trail);
        if (disj->_uIdx._val > uIdx) assignTRInt(&(disj->_uIdx), uIdx, disj->_trail);
    }
}

/*******************************************************************************
 Main Propagation Loop
 ******************************************************************************/

static void doPropagation(CPTaskDisjunctive * disj) {
    bool update;
    const ORInt sortSize = disj->_uIdx._val;
    ORInt boundSize = disj->_boundSize._val;
    
    cleanUp(disj);
    
    disj->_begin = MAXINT;
    disj->_end   = MININT;

    // Retrieve all necessary data from the tasks
    for (ORInt tt = boundSize; tt < disj->_size; tt++) {
        const ORInt t  = disj->_bound[tt];
        const ORInt t0 = t - disj->_low;
        ORBool bound;
        [disj->_tasks[t] readEssentials:&bound est:&(disj->_est[t0]) lct:&(disj->_lct[t0]) minDuration:&(disj->_dur_min[t0]) maxDuration:&(disj->_dur_max[t0]) present:&(disj->_present[t0]) absent:&(disj->_absent[t0])];
        
        assert(disj->_dur_min[t0] >= 0);
        assert(disj->_est[t0] + disj->_dur_min[t0] <= disj->_lct[t0]);
        
        if (bound || isIrrelevant(disj, t0))
            swapORInt(disj->_bound, boundSize++, tt);
        if (!isIrrelevant(disj, t0)) {
            disj->_begin = min(disj->_begin, disj->_est[t0]);
            disj->_end   = max(disj->_end  , disj->_lct[t0]);
        }
    }
    // Trail the bound size
    if (boundSize > disj->_boundSize._val)
        assignTRInt(&(disj->_boundSize), boundSize, disj->_trail);
    
    // Updating indices
    updateIndices(disj);
    
    const ORInt size  = disj->_uIdx._val;
    const ORInt cSize = disj->_cIdx._val;
    
    if (size <= 1) {
        //        assignTRInt(&(disj->_active), NO, (disj->_trail));
        return ;
    }
    
    // Allocation of memory
//    disj->_est           = alloca(disj->_size * sizeof(ORInt ));
//    disj->_lct           = alloca(disj->_size * sizeof(ORInt ));
//    disj->_dur_min       = alloca(disj->_size * sizeof(ORInt ));
    disj->_new_est       = alloca(disj->_size * sizeof(ORInt ));
    disj->_new_lct       = alloca(disj->_size * sizeof(ORInt ));
//    disj->_task_id_est   = alloca(size * sizeof(ORInt ));
//    disj->_task_id_ect   = alloca(size * sizeof(ORInt ));
//    disj->_task_id_lst   = alloca(size * sizeof(ORInt ));
//    disj->_task_id_lct   = alloca(size * sizeof(ORInt ));
    ORUInt * idx_map_est = alloca(disj->_size * sizeof(ORUInt));
    ORUInt * idx_map_lct = alloca(disj->_size * sizeof(ORUInt));
    
    // Determing the size of the tree
    const ORUInt tsize = 2 * size - 1;
    const ORUInt tdepth = getDepth(tsize);
    ThetaTree  * theta  = alloca(tsize * sizeof(ThetaTree ));
    LambdaTree * lambda = alloca(tsize * sizeof(LambdaTree));
    
    // Check whether memory allocation was successful
    if (disj->_est == NULL || disj->_lct == NULL || disj->_dur_min == NULL ||
        disj->_new_est == NULL || disj->_new_lct == NULL ||
        disj->_task_id_est == NULL || disj->_task_id_lct == NULL ||
        idx_map_est == NULL || idx_map_lct == NULL || theta == NULL || lambda == NULL) {
        @throw [[ORExecutionError alloc] initORExecutionError: "CPTaskDisjunctive: Out of memory!"];
    }
    
    // Initialisation of the arrays
    for (ORInt tt = 0; tt < size; tt++) {
        const ORInt t  = disj->_idx[tt];
        const ORInt t0 = t - disj->_low;
//        disj->_est    [t0] = [disj->_tasks[t] est        ];
//        disj->_lct    [t0] = [disj->_tasks[t] lct        ];
//        disj->_dur_min[t0] = [disj->_tasks[t] minDuration];
//        disj->_dur_max[t0] = [disj->_tasks[t] maxDuration];
//        disj->_present[t0] = [disj->_tasks[t] isPresent  ];
//        disj->_absent [t0] = [disj->_tasks[t] isAbsent   ];
//
//        assert(disj->_dur_min[t0] >= 0);
//        assert(disj->_est[t0] + disj->_dur_min[t0] <= disj->_lct[t0]);
        
        disj->_new_est[t0] = disj->_est[t0];
        disj->_new_lct[t0] = disj->_lct[t0];
//        disj->_task_id_est[tt] = tt;
//        disj->_task_id_ect[tt] = tt;
//        disj->_task_id_lst[tt] = tt;
//        disj->_task_id_lct[tt] = tt;
//        idx_map_est[tt] = tt;
//        idx_map_lct[tt] = tt;
    }
    //   for (ORInt tt = 0; tt < size; tt++)
    //      NSLog(@" Task[%d] = %@",tt,disj->_tasks[tt]);
    
    disj->_beginIdx = -1;
    
    // Propagation loop
    do {
        update = false;
        // Sorting tasks regarding their earliest start and latest completion times
        if (cSize >= sortSize) {
            isort_r(disj->_task_id_est, sortSize, disj, (ORInt(*)(void*, const ORInt*, const ORInt*)) &sortDisjEstAsc);
            isort_r(disj->_task_id_lct, sortSize, disj, (ORInt(*)(void*, const ORInt*, const ORInt*)) &sortDisjLctAsc);
        }
        else {
            isort_r(disj->_task_id_est, sortSize, disj, (ORInt(*)(void*, const ORInt*, const ORInt*)) &sortDisjEstAscOpt);
            isort_r(disj->_task_id_lct, sortSize, disj, (ORInt(*)(void*, const ORInt*, const ORInt*)) &sortDisjLctAscOpt);
        }
        if (disj->_beginIdx < 0) {
            disj->_endIdx   = disj->_size;
            for (ORInt ii = 0; ii < sortSize; ii++) {
                const ORInt i0 = disj->_task_id_est[ii] - disj->_low;
                if (isIrrelevant(disj, i0))
                    continue;
                if (disj->_lct[i0] <= disj->_begin)
                    disj->_beginIdx = ii;
                else if (disj->_est[i0] >= disj->_end) {
                    disj->_endIdx   = ii;
                    break;
                }
            }
            disj->_beginIdx++;
        }

        // Initialisation of the positions of the tasks
        initIndexMap(disj, disj->_task_id_est, idx_map_est, size, tsize, tdepth);
        
        // Consistency check
        if (cSize >= size) {
            ef_overload_check_vilim(disj, size, idx_map_est, theta, tsize);
        }
        else {
            ef_overload_check_optional_vilim(disj, size, idx_map_est, theta, lambda, tsize, tdepth);
        }
        
        // Further initialisations needed for the filtering algorithm
        initIndexMap(disj, disj->_task_id_lct, idx_map_lct, size, tsize, tdepth);
        if (cSize >= sortSize) {
            isort_r(disj->_task_id_ect, sortSize, disj, (ORInt(*)(void*, const ORInt*, const ORInt*)) &sortDisjEctAsc);
            isort_r(disj->_task_id_lst, sortSize, disj, (ORInt(*)(void*, const ORInt*, const ORInt*)) &sortDisjLstAsc);
        }
        else {
            isort_r(disj->_task_id_ect, sortSize, disj, (ORInt(*)(void*, const ORInt*, const ORInt*)) &sortDisjEctAscOpt);
            isort_r(disj->_task_id_lst, sortSize, disj, (ORInt(*)(void*, const ORInt*, const ORInt*)) &sortDisjLstAscOpt);
        }
        
        // Detectable precedences
        if (disj->_dprec) {
            if (cSize >= size) {
                dprec_filter_est_and_lct_vilim(disj, size, idx_map_est, idx_map_lct, theta, tsize, & update);
            }
            else {
                dprec_filter_est_and_lct_optional_vilim(disj, size, idx_map_est, idx_map_lct, theta, lambda, tsize, tdepth, & update);
            }
        }
        // Not-first/not-last
        if (!update && disj->_nfnl) {
            if (cSize >= size) {
                nfnl_filter_est_and_lct_vilim(disj, size, idx_map_est, idx_map_lct, theta, tsize, & update);
            }
            else {
                nfnl_filter_est_and_lct_optional_vilim(disj, size, idx_map_est, idx_map_lct, theta, lambda, tsize, tdepth, & update);
            }
        }
        // Edge-finding
        if (!update && disj->_ef) {
            if (cSize >= size) {
//                ef_filter_est_and_lct_nuijten(disj, size, & update);
                ef_filter_est_and_lct_vilim(disj, size, idx_map_est, idx_map_lct, theta, lambda, tsize, tdepth, & update);
            }
            else {
                // NOTE: This algorithms has a time-complexity of O(n^2)
                ef_filter_est_and_lct_optional(disj, size, & update);
            }
        }
    } while (disj->_idempotent && update);
    
    // Updating the global slack
    const ORInt globalSlack = getGlobalSlack(disj, size);
    assignTRInt(&(disj->_global_slack), globalSlack, disj->_trail);
}

@end


