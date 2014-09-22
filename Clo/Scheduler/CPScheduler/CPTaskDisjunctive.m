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

// Randomly set, but it should be less than MAXINT/2, because Vilim's algorithms
// need a tree of size 2 * (#tasks) - 1
#define MAXNBTASK ((MAXINT)/4)

@implementation CPTaskDisjunctive {
    // Attributs of tasks
    ORInt    _size;         // Number of tasks in the array '_tasks'
    ORInt    _low;          // Lowest index in the array '_tasks'
    ORInt    _up;           // Highest index in the array '_tasks'

    ORInt  * _idx;          // Activities' ID sorted in [Present | Unknown | Absent]
    TRInt    _cIdx;         // Size of present activities
    TRInt    _uIdx;         // Size of present and non-present activities

    ORInt  * _bound;        // Activities' ID sorted in [Bound | Not Bound]
    TRInt    _boundSize;    // Size of bounded tasks

    
    // Variables needed for the propagation
    ORInt  * _new_est;      // New earliest start times (dynamic memory allocation)
    ORInt  * _new_lct;      // New latest completion times (dynamic memory allocation)

    ORInt  * _est;          // Earliest start times
    ORInt  * _lct;          // Latest completion times
    ORInt  * _dur_min;      // Minimal durations
    ORInt  * _dur_max;      // Maximal durations
    ORBool * _present;      // Whether the task is present
    ORBool * _absent;       // Whether the task is absent
    
    ORInt    _begin;        // Start time of the horizon considered during propagation
    ORInt    _end;          // End time of the horizon considered during propagation
    ORInt    _beginIdx;     // Index pointing to the first task intersecting the horizon in sorting arrays
    ORInt    _endIdx;       // Index pointing to the successor task of the last task intersecting the horizon in sorting arrays
    
    // Static allocation of following "sorting" arrays
    // NOTE irrelevant tasks are sorted at the end of the array neglecting their times!
    ORInt * _task_id_est;   // Task's ID sorted according the earliest start times
    ORInt * _task_id_ect;   // Task's ID sorted according the earliest completion times
    ORInt * _task_id_lst;   // Task's ID sorted according the latest start times
    ORInt * _task_id_lct;   // Task's ID sorted according the latest completion times
    TRInt   _sortSize;      // Sorting size of the next call
    
    // Filtering options
    ORBool _dprec;          // Detectable precedences filtering
    ORBool _nfnl;           // Not-first/not-last filtering
    ORBool _ef;             // Edge-finding
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
    
    _size = (ORInt) _tasks.count;
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
    _cIdx        = makeTRInt(_trail, 0     );
    _uIdx        = makeTRInt(_trail, _size );
    _boundSize   = makeTRInt(_trail, 0     );
    _sortSize    = makeTRInt(_trail, _size );
    
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
    return getGlobalSlack(self);
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
static void initThetaTree(ThetaTree * theta, ORInt tsize, ORInt time) {
    for (ORInt i = 0; i < tsize; i++) {
        theta[i]._length = 0;
        theta[i]._time   = time;
    }
}

// Initialisation of an empty Lambda tree
//
static void initLambdaTree(LambdaTree * lambda, ORInt tsize, ORInt time) {
    for (ORInt i = 0; i < tsize; i++) {
        lambda[i]._gLength = 0;
        lambda[i]._gTime   = time;
    }
}


// Insertation of one task in a Theta tree
//
static void insertThetaNodeAtIdxEct(ThetaTree * theta, const ORInt tsize, ORInt idx, const ORInt length, const ORInt time) {
    assert(0 <= idx && idx < tsize);
    // Activition of the node
    theta[idx]._length = length;
    theta[idx]._time   = time;
    // Propagation of the changes
    do {
        idx = PARENT(idx);
        const ORInt l = LEFTCHILD( idx);
        const ORInt r = RIGHTCHILD(idx);
        theta[idx]._length = theta[l]._length + theta[r]._length;
        theta[idx]._time   = max(theta[r]._time, theta[l]._time + theta[r]._length);
    } while (idx > 0);
    assert(idx == 0);
}

// Insertation of one task in a Theta tree
//
static void insertThetaNodeAtIdxLst(ThetaTree * theta, const ORInt tsize, ORInt idx, const ORInt length, const ORInt time) {
    assert(0 <= idx && idx < tsize);
    // Activition of the node
    theta[idx]._length = length;
    theta[idx]._time   = time;
    // Propagation of the changes
    do {
        idx = PARENT(idx);
        const ORInt l = LEFTCHILD( idx);
        const ORInt r = RIGHTCHILD(idx);
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
static void initThetaLambdaTreeWithEct(CPTaskDisjunctive * disj, const ORInt size, const ORInt * idx_map_est, ThetaTree * theta, LambdaTree * lambda, const ORInt tsize) {
    // Inserting all tasks into the Theta tree
    for (ORInt ii = 0; ii < size; ii++) {
        const ORInt i0 = disj->_task_id_est[ii] - disj->_low;
        const ORInt idx = idx_map_est[i0];
        theta[idx]._length = 0;
        theta[idx]._time   = MININT;
    }
    for (ORInt ii = disj->_beginIdx; ii < disj->_endIdx; ii++) {
        const ORInt i0 = disj->_task_id_est[ii] - disj->_low;
        const ORInt idx = idx_map_est[i0];
        if (disj->_dur_min[i0] > 0) {
            theta[idx]._length = disj->_dur_min[i0];
            theta[idx]._time   = disj->_est[i0] + disj->_dur_min[i0];
        }
    }
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
static void initThetaLambdaTreeWithLst(CPTaskDisjunctive * disj, const ORInt size, const ORInt * idx_map_lct, ThetaTree * theta, LambdaTree * lambda, const ORInt tsize) {
    // Inserting all tasks into the Theta tree
    for (ORInt ii = 0; ii < size; ii++) {
        const ORInt i0  = disj->_task_id_est[ii] - disj->_low;
        const ORInt idx = idx_map_lct[i0];
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
static void insertLambdaNodeAtIdxEct(ThetaTree * theta, LambdaTree * lambda, const ORInt tsize, ORInt idx, const ORInt length, const ORInt time) {
    assert(0 <= idx && idx < tsize);
    // Activition of the node
    lambda[idx]._gLength = length;
    lambda[idx]._gTime   = time;
    // Propagation of the changes
    do {
        idx = PARENT(idx);
        const ORInt l = LEFTCHILD( idx);
        const ORInt r = RIGHTCHILD(idx);
        lambda[idx]._gLength = max(lambda[l]._gLength + theta[r]._length, theta[l]._length + lambda[r]._gLength);
        lambda[idx]._gTime   = max(lambda[r]._gTime, max(theta[l]._time + lambda[r]._gLength, lambda[l]._gTime + theta[r]._length));
    } while (idx > 0);
    assert(idx == 0);
}

// Insertation of one task in a Theta-Lambda tree
//
static void insertLambdaNodeAtIdxLst(ThetaTree * theta, LambdaTree * lambda, const ORInt tsize, ORInt idx, const ORInt length, const ORInt time) {
    assert(0 <= idx && idx < tsize);
    // Activition of the node
    lambda[idx]._gLength = length;
    lambda[idx]._gTime   = time;
    // Propagation of the changes
    do {
        idx = PARENT(idx);
        const ORInt l = LEFTCHILD( idx);
        const ORInt r = RIGHTCHILD(idx);
        lambda[idx]._gLength = max(lambda[l]._gLength + theta[r]._length, theta[l]._length + lambda[r]._gLength);
        lambda[idx]._gTime   = min(lambda[l]._gTime, min(theta[r]._time - lambda[l]._gLength, lambda[r]._gTime - theta[l]._length));
    } while (idx > 0);
    assert(idx == 0);
}

// Determining the leave (task) that is responsible for the ECT(Theta, Lambda)
//
static ORInt retrieveResponsibleLambdaNodeWithEct(ThetaTree * theta, LambdaTree * lambda, const ORInt tsize)
{
    ORInt p = 0;
    bool gLength = false;
    while (p < tsize) {
        const ORInt l = LEFTCHILD( p);
        const ORInt r = RIGHTCHILD(p);
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

static ORInt retrieveResponsibleLambdaNodeWithLst(ThetaTree * theta, LambdaTree * lambda, const ORInt tsize)
{
    ORInt p = 0;
    bool gLength = false;
    while (p < tsize) {
        const ORInt l = LEFTCHILD( p);
        const ORInt r = RIGHTCHILD(p);
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
static ORInt getDepth(ORInt x)
{
    ORInt depth = 0;
    while (x >>= 1) depth++;
    return depth;
}

// Generation of the map from the task's ID to leaf's index
//
static void initIndexMap(CPTaskDisjunctive* disj, ORInt * array, ORInt * idx_map, const ORInt sizeArray, const ORInt sizeTree, const ORInt depth) {
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


static void dumpTask(CPTaskDisjunctive * disj, ORInt t0) {
    printf("task %d: est %d; ect %d; lst %d; lct %d; dur_min %d;", t0, disj->_est[t0], disj->_est[t0] + disj->_dur_min[t0], disj->_lct[t0] - disj->_dur_min[t0], disj->_lct[t0], disj->_dur_min[t0]);
    printf(" present %d; absent %d;\n", disj->_present[t0], disj->_absent[t0]);
}

// Printing the contain of the Theta tree to standard out
//
static void dumpThetaTree(ThetaTree * theta, const ORInt tsize)
{
    printf("Theta:  ");
    for (ORInt i = 0; i < tsize; i++) {
        printf("(%d: len %d, time %d) ", i, theta[i]._length, theta[i]._time);
    }
    printf("\n");
}


// Printing the contain of the Theta tree to standard out
//
static void dumpLambdaTree(LambdaTree * lambda, const ORInt tsize)
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
        }
        if (disj->_new_lct[t0] < disj->_lct[t0]) {
            [disj->_tasks[t] updateEnd: disj->_new_lct[t0]];
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
static void ef_overload_check_vilim(CPTaskDisjunctive * disj, const ORInt size, const ORInt * idx_map_est, ThetaTree * theta, const ORInt tsize)
{
    initThetaTree(theta, tsize, MININT);
    // Iteration in non-decreasing order of the latest completion time
    for (ORInt tt = disj->_beginIdx; tt < disj->_endIdx; tt++) {
        const ORInt t0 = disj->_task_id_lct[tt] - disj->_low;
        assert(isPresent(disj, t0));
        // Retrieve task's position in task_id_est
        const ORInt tree_idx = idx_map_est[t0];
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
static void ef_overload_check_optional_vilim(CPTaskDisjunctive * disj, const ORInt size, const ORInt * idx_map_est, ThetaTree * theta, LambdaTree * lambda, const ORInt tsize, const ORInt tdepth)
{
    // Initialisation of Theta and Lambda tree
    initThetaTree( theta,  tsize, MININT);
    initLambdaTree(lambda, tsize, MININT);
    // 'offset' reflects the total of nodes in the trees except the nodes in the deepest level
    const ORInt offset = (1 << tdepth) - 1;
    // Iteration in non-descreasing order of the latest completion time
    for (ORInt tt = disj->_beginIdx; tt < disj->_endIdx; tt++) {
        const ORInt t0 = disj->_task_id_lct[tt] - disj->_low;
        if (isRelevant(disj, t0)) {
            // Relevant activity
            // Retrieve task's position in task_id_est
            const ORInt tree_idx = idx_map_est[t0];
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
            const ORInt leaf_idx = retrieveResponsibleLambdaNodeWithEct(theta, lambda, tsize);
            
            // The leaf must be a gray one
            assert(theta[leaf_idx]._time == MININT && lambda[leaf_idx]._gTime != MININT);
            
            // Map leaf index to task ID
            const ORInt array_idx = (offset <= leaf_idx ? leaf_idx - offset : (leaf_idx + size) - offset);
            const ORInt k = disj->_task_id_est[array_idx];
            const ORInt k0 = k - disj->_low;
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
static void dprec_filter_est_and_lct_vilim(CPTaskDisjunctive * disj, const ORInt size, const ORInt * idx_map_est, const ORInt * idx_map_lct, ThetaTree * theta, const ORInt tsize, bool * update)
{
    dprec_filter_est_vilim(disj, size, idx_map_est, theta, tsize, update);
    dprec_filter_lct_vilim(disj, size, idx_map_lct, theta, tsize, update);
    if (update) updateBounds(disj, size);
}

static void dprec_filter_est_vilim(CPTaskDisjunctive * disj, const ORInt size, const ORInt * idx_map_est, ThetaTree * theta, const ORInt tsize, bool * update)
{
    // Inititialise Theta tree
    initThetaTree(theta, tsize, MININT);
    ORInt jj = disj->_beginIdx;
    ORInt j0 = disj->_task_id_lst[jj] - disj->_low;
    // Outer loop:
    //  Iterating over the tasks in ascending order of their earliest completion time
    for (ORInt ii = disj->_beginIdx; ii < disj->_endIdx; ii++) {
        const ORInt i0 = disj->_task_id_ect[ii] - disj->_low;
        assert(isPresent(disj, i0));
        
        // Inner loop:
        // Iterating over the tasks in ascending order of their latest start time
        while (jj < disj->_endIdx && disj->_est[i0] + disj->_dur_min[i0] > disj->_lct[j0] - disj->_dur_min[j0]) {
            assert(isPresent(disj, j0));
            // Task 'j' precedes task 'i'
            const ORInt tree_idx = idx_map_est[j0];
            insertThetaNodeAtIdxEct(theta, tsize, tree_idx, disj->_dur_min[j0], disj->_est[j0] + disj->_dur_min[j0]);
            jj++;
            if (jj < disj->_endIdx)
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
        if (ect_t > disj->_new_est[i0]) {
            // New lower bound found
            disj->_new_est[i0] = ect_t;
            *update = true;
        }
    }
}

static void dprec_filter_lct_vilim(CPTaskDisjunctive * disj, const ORInt size, const ORInt * idx_map_lct, ThetaTree * theta, const ORInt tsize, bool * update)
{
    // Inititialise Theta tree
    initThetaTree(theta, tsize, MAXINT);
    ORInt jj = disj->_endIdx - 1;
    ORInt j0 = disj->_task_id_ect[jj] - disj->_low;
    // Outer loop:
    // Iterating over the tasks in descending order of their latest start time
    for (ORInt ii = disj->_endIdx - 1; ii >= 0; ii--) {
        const ORInt i0 = disj->_task_id_lst[ii] - disj->_low;
        assert(isPresent(disj, i0));

        // Inner loop:
        // Iterating over the tasks in descending order of their earliest completion time
        while (jj >= disj->_beginIdx && disj->_lct[i0] - disj->_dur_min[i0] < disj->_est[j0] + disj->_dur_min[j0]) {
            assert(isPresent(disj, j0));
            // Task 'i' precedes task 'j'
            insertThetaNodeAtIdxLst(theta, tsize, idx_map_lct[j0], disj->_dur_min[j0], disj->_lct[j0] - disj->_dur_min[j0]);
            jj--;
            if (jj >= disj->_beginIdx)
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
        if (lst_t < disj->_new_lct[i0]) {
            // New upper bound found
            disj->_new_lct[i0] = lst_t;
            *update = true;
        }
    }
}


static void dprec_filter_est_and_lct_optional_vilim(CPTaskDisjunctive * disj, const ORInt size, const ORInt * idx_map_est, const ORInt * idx_map_lct, ThetaTree * theta, LambdaTree * lambda, const ORInt tsize, const ORInt tdepth, bool * update)
{
    dprec_filter_est_optional_vilim(disj, size, idx_map_est, theta, lambda, tsize, tdepth, update);
    dprec_filter_lct_optional_vilim(disj, size, idx_map_lct, theta, lambda, tsize, tdepth, update);
    if (update) updateBounds(disj, size);
}

static void dprec_filter_est_optional_vilim(CPTaskDisjunctive * disj, const ORInt size, const ORInt * idx_map_est, ThetaTree * theta, LambdaTree * lambda, const ORInt tsize, const ORInt tdepth, bool * update)
{
    // Initialise Theta-Lambda tree
    initThetaTree( theta,  tsize, MININT);
    initLambdaTree(lambda, tsize, MININT);
    // 'offset' reflects the total of nodes in the trees except the nodes in the deepest level
    const ORInt offset = (1 << tdepth) - 1;
    // Initialisations for the inner while-loop
    ORInt jj = disj->_beginIdx;
    ORInt j0 = disj->_task_id_lst[jj] - disj->_low;
    // Outer loop:
    //  Iterating over the tasks in ascending order of their earliest completion time
    for (ORInt ii = disj->_beginIdx; ii < disj->_endIdx; ii++) {
        const ORInt i0 = disj->_task_id_ect[ii] - disj->_low;
        // Check for absent activities
        if (isIrrelevant(disj, i0)) continue;
        // Inner loop:
        // Iterating over the tasks in ascending order of their latest start time
        while (jj < disj->_endIdx && disj->_est[i0] + disj->_dur_min[i0] > disj->_lct[j0] - disj->_dur_min[j0]) {
            // Task 'j' precedes task 'i'
            const ORInt tree_idx = idx_map_est[j0];
            const ORInt dur_j    = disj->_dur_min[j0];
            const ORInt ect_j    = disj->_dur_min[j0] + disj->_est[j0];
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
            if (jj < disj->_endIdx)
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
                const ORInt leaf_idx = retrieveResponsibleLambdaNodeWithEct(theta, lambda, tsize);
                // The leaf must be a gray one
                if (theta[leaf_idx]._time != MININT || lambda[leaf_idx]._gTime == MININT) {
                    break;
                    dumpThetaTree(theta, tsize);
                    dumpLambdaTree(lambda, tsize);
                }
                assert(theta[leaf_idx]._time == MININT && lambda[leaf_idx]._gTime != MININT);
                // Map leaf index to task ID
                const ORInt array_idx = (offset <= leaf_idx ? leaf_idx - offset : (leaf_idx + size) - offset);
                const ORInt k  = disj->_task_id_est[array_idx];
                const ORInt k0 = k - disj->_low;
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
        if (ect_t > disj->_new_est[i0]) {
            // New lower bound found
            disj->_new_est[i0] = ect_t;
            *update = true;
        }
    }
}

static void dprec_filter_lct_optional_vilim(CPTaskDisjunctive * disj, const ORInt size, const ORInt * idx_map_lct, ThetaTree * theta, LambdaTree * lambda, const ORInt tsize, const ORInt tdepth, bool * update)
{
    // Inititialise Theta-Lambda tree
    initThetaTree( theta,  tsize, MAXINT);
    initLambdaTree(lambda, tsize, MAXINT);
    // 'offset' reflects the total of nodes in the trees except the nodes in the deepest level
    const ORInt offset = (1 << tdepth) - 1;
    ORInt jj = disj->_endIdx - 1;
    ORInt j0 = disj->_task_id_ect[jj] - disj->_low;
    // Outer loop:
    // Iterating over the tasks in descending order of their latest start time
    for (ORInt ii = disj->_endIdx - 1; ii >= disj->_beginIdx; ii--) {
        const ORInt i0 = disj->_task_id_lst[ii] - disj->_low;
        // Check for absent activities
        if (isIrrelevant(disj, i0)) continue;
        // Inner loop:
        // Iterating over the tasks in descending order of their earliest completion time
        while (jj >= disj->_beginIdx && disj->_lct[i0] - disj->_dur_min[i0] < disj->_est[j0] + disj->_dur_min[j0]) {
            // Task 'i' succeeds task 'j'
            const ORInt tree_idx = idx_map_lct[j0];
            const ORInt dur_j    = disj->_dur_min[j0];
            const ORInt lst_j    = disj->_lct[j0] - disj->_dur_min[j0];
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
            if (jj >= disj->_beginIdx)
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
                const ORInt array_idx = (offset <= leaf_idx ? leaf_idx - offset : (leaf_idx + size) - offset);
                const ORInt k  = disj->_task_id_lct[array_idx];
                const ORInt k0 = k - disj->_low;
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
        if (lst_t < disj->_new_lct[i0]) {
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
static void nfnl_filter_est_and_lct_vilim(CPTaskDisjunctive * disj, const ORInt size, const ORInt * idx_map_est, const ORInt * idx_map_lct, ThetaTree * theta, const ORInt tsize, bool * update)
{
    nfnl_filter_est_vilim(disj, size, idx_map_lct, theta, tsize, update);
    nfnl_filter_lct_vilim(disj, size, idx_map_est, theta, tsize, update);
    if (update) updateBounds(disj, size);
}

static void nfnl_filter_est_vilim(CPTaskDisjunctive * disj, const ORInt size, const ORInt * idx_map_lct, ThetaTree * theta, const ORInt tsize, bool * update)
{
    // Initialise Theta tree
    initThetaTree(theta, tsize, MAXINT);
    ORInt jj = disj->_endIdx - 1;
    ORInt j0 = disj->_task_id_ect[jj] - disj->_low;
    ORInt jLastInserted0 = MAXINT;
    // Outer loop:
    // Iterating over the tasks in descending order of their earliest start time
    for (ORInt ii = disj->_endIdx - 1; ii >= disj->_beginIdx; ii--) {
        const ORInt i0 = disj->_task_id_est[ii] - disj->_low;
        assert(isPresent(disj, j0));

        // No propagation on tasks with zero duration
        if (disj->_dur_min[i0] == 0) continue;
        // Inner loop:
        // Iterating over the tasks in descending order of their earliest completion time
        while (jj >= disj->_beginIdx && disj->_est[i0] < disj->_est[j0] + disj->_dur_min[j0]) {
            assert(isPresent(disj, j0));

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
            jj--;
            if (jj >= disj->_beginIdx)
                j0 = disj->_task_id_ect[jj] - disj->_low;
        }
        assert(disj->_est[i0] < disj->_est[i0] + disj->_dur_min[i0]);
        assert(jj < (ORInt) (size - 1));
        
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

static void nfnl_filter_lct_vilim(CPTaskDisjunctive * disj, const ORInt size, const ORInt * idx_map_est, ThetaTree * theta, const ORInt tsize, bool * update)
{
    // Inititialise Theta tree
    initThetaTree(theta, tsize, MININT);
    ORInt jj = disj->_beginIdx;
    ORInt j0 = disj->_task_id_lst[jj] - disj->_low;
    ORInt jLastInserted0 = MAXINT;
    // Outer loop:
    // Iterating over the tasks in ascending order of their latest completion time
    for (ORInt ii = disj->_beginIdx; ii < size; ii++) {
        const ORInt i0 = disj->_task_id_lct[ii] - disj->_low;
        assert(isPresent(disj, i0));
        // No propagation on tasks with zero duration
        if (disj->_dur_min[i0] == 0) continue;
        // Inner loop:
        // Iterating over the tasks in ascending order of their latest start time
        while (jj < disj->_endIdx && disj->_lct[i0] > disj->_lct[j0] - disj->_dur_min[j0]) {
            assert(isPresent(disj, j0));
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
            jj++;
            if (jj < disj->_endIdx)
                j0 = disj->_task_id_lst[jj] - disj->_low;
        }
        assert(disj->_lct[i0] > disj->_lct[i0] - disj->_dur_min[i0]);
        assert(jj > 0);
        
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


static void nfnl_filter_est_and_lct_optional_vilim(CPTaskDisjunctive * disj, const ORInt size, const ORInt * idx_map_est, const ORInt * idx_map_lct, ThetaTree * theta, LambdaTree * lambda,  const ORInt tsize, const ORInt tdepth, bool * update)
{
    nfnl_filter_est_optional_vilim(disj, size, idx_map_lct, theta, lambda, tsize, tdepth, update);
    nfnl_filter_lct_optional_vilim(disj, size, idx_map_est, theta, lambda, tsize, tdepth, update);
    if (update) updateBounds(disj, size);
}

static void nfnl_filter_est_optional_vilim(CPTaskDisjunctive * disj, const ORInt size, const ORInt * idx_map_lct, ThetaTree * theta, LambdaTree * lambda, const ORInt tsize, const ORInt tdepth, bool * update)
{
    // Initialise Theta-Lambda tree
    initThetaTree( theta,  tsize, MAXINT);
    initLambdaTree(lambda, tsize, MAXINT);
    // 'offset' reflects the total of nodes in the trees except the nodes in the deepest level
    const ORInt offset = (1 << tdepth) - 1;
    ORInt jj = disj->_endIdx - 1;
    ORInt j0 = disj->_task_id_ect[jj] - disj->_low;
    ORInt jLastInserted = MAXINT;
    ORInt jLastInserted2 = MAXINT;
    // Outer loop:
    // Iterating over the tasks in descending order of their earliest start time
    for (ORInt ii = disj->_endIdx - 1; ii >= disj->_beginIdx; ii--) {
        const ORInt i0 = disj->_task_id_est[ii] - disj->_low;
        // Check for absent activities
        if (isIrrelevant(disj, i0)) continue;
        // No propagation on tasks with zero duration
        if (disj->_dur_min[i0] == 0) continue;
        // Inner loop:
        // Iterating over the tasks in descending order of their earliest completion time
        while (jj >= disj->_beginIdx && disj->_est[i0] < disj->_est[j0] + disj->_dur_min[j0]) {
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
            jj--;
            if (jj >= disj->_beginIdx)
                j0 = disj->_task_id_ect[jj] - disj->_low;
        }
        // Check whether a present activity is in Theta tree
        if (jLastInserted == MAXINT) continue;
        assert(disj->_est[i0] < disj->_est[i0] + disj->_dur_min[i0]);
        assert(jj < (ORInt) (size - 1));
        
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
                const ORInt array_idx = (offset <= leaf_idx ? leaf_idx - offset : (leaf_idx + size) - offset);
                const ORInt k = disj->_task_id_lct[array_idx];
                const ORInt k0 = k - disj->_low;
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
    }
}


static void nfnl_filter_lct_optional_vilim(CPTaskDisjunctive * disj, const ORInt size, const ORInt * idx_map_est, ThetaTree * theta, LambdaTree * lambda, const ORInt tsize, const ORInt tdepth, bool * update)
{
    // Initialise Theta-Lambda tree
    initThetaTree( theta,  tsize, MININT);
    initLambdaTree(lambda, tsize, MININT);
    // 'offset' reflects the total of nodes in the trees except the nodes in the deepest level
    const ORInt offset = (1 << tdepth) - 1;
    ORInt jj = disj->_beginIdx;
    ORInt j0 = disj->_task_id_lst[jj] - disj->_low;
    ORInt jLastInserted  = MAXINT;
    ORInt jLastInserted2 = MAXINT;
    // Outer loop:
    // Iterating over the tasks in ascending order of their latest completion time
    for (ORInt ii = disj->_beginIdx; ii < disj->_endIdx; ii++) {
        const ORInt i0 = disj->_task_id_lct[ii] - disj->_low;
        // Check for absent activities
        if (isIrrelevant(disj, i0)) continue;
        // No propagation on tasks with zero duration
        if (disj->_dur_min[i0] == 0) continue;
        // Inner loop:
        // Iterating over the tasks in ascending order of their latest start time
        while (jj < disj->_endIdx && disj->_lct[i0] > disj->_lct[j0] - disj->_dur_min[j0]) {
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
            jj++;
            if (jj < disj->_endIdx)
                j0 = disj->_task_id_lst[jj] - disj->_low;
        }
        // Check whether a present activity is in Theta tree
        if (jLastInserted == MAXINT) continue;
        assert(disj->_lct[i0] > disj->_lct[i0] - disj->_dur_min[i0]);
        assert(jj > 0);

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
                const ORInt leaf_idx = retrieveResponsibleLambdaNodeWithEct(theta, lambda, tsize);
                // The leaf must be a gray one
                if (theta[leaf_idx]._time != MININT || lambda[leaf_idx]._gTime == MININT) {
                    break;
                }
                assert(theta[leaf_idx]._time == MININT && lambda[leaf_idx]._gTime != MININT);
                // Map leaf index to task ID
                const ORInt array_idx = (offset <= leaf_idx ? leaf_idx - offset : (leaf_idx + size) - offset);
                const ORInt k = disj->_task_id_est[array_idx];
                const ORInt k0 = k - disj->_low;
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
static void ef_filter_est_and_lct_vilim(CPTaskDisjunctive * disj, const ORInt size, const ORInt * idx_map_est, const ORInt * idx_map_lct, ThetaTree * theta, LambdaTree * lambda, const ORInt tsize, const ORInt tdepth, bool * update)
{
    ef_filter_est_vilim(disj, size, idx_map_est, theta, lambda, tsize, tdepth, update);
    ef_filter_lct_vilim(disj, size, idx_map_lct, theta, lambda, tsize, tdepth, update);
    if (update) updateBounds(disj, size);
}

static void ef_filter_est_vilim(CPTaskDisjunctive * disj, const ORInt size, const ORInt * idx_map_est, ThetaTree * theta, LambdaTree * lambda, const ORInt tsize, const ORInt tdepth, bool * update)
{
    // Initialise Theta-Lambda tree with (T, {})
    initThetaLambdaTreeWithEct(disj, size, idx_map_est, theta, lambda, tsize);
    ORInt jj = disj->_endIdx - 1;
    ORInt j0 = disj->_task_id_lct[jj] - disj->_low;
    // 'offset' reflects the total of nodes in the trees except the nodes in the deepest level
    const ORInt offset = (1 << tdepth) - 1;
    // Outer loop:
    // Iterating over the tasks in descending order of their latest completion time
    while (jj > disj->_beginIdx) {
        assert(isPresent(disj, j0));

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
            const ORInt leaf_idx = retrieveResponsibleLambdaNodeWithEct(theta, lambda, tsize);
            // The leaf must be a gray one
            assert(theta[leaf_idx]._time == MININT && lambda[leaf_idx]._gTime != MININT);
            // Map leaf index to task ID
            const ORInt array_idx = (offset <= leaf_idx ? leaf_idx - offset : (leaf_idx + size) - offset);
            const ORInt i0 = disj->_task_id_est[array_idx] - disj->_low;
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

static void ef_filter_lct_vilim(CPTaskDisjunctive * disj, const ORInt size, const ORInt * idx_map_lct, ThetaTree * theta, LambdaTree * lambda, const ORInt tsize, const ORInt tdepth, bool * update)
{
    // Initialise Theta-Lambda tree with (T, {})
    initThetaLambdaTreeWithLst(disj, size, idx_map_lct, theta, lambda, tsize);
    ORInt jj = disj->_beginIdx;
    ORInt j0 = disj->_task_id_est[jj] - disj->_low;
    // 'offset' reflects the total of nodes in the trees except the nodes in the deepest level
    const ORInt offset = (1 << tdepth) - 1;
    // Outer loop:
    // Iterating over the tasks in ascending order of their earliest start time
    while (jj < disj->_endIdx - 1) {
        assert(isPresent(disj, j0));

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
            const ORInt array_idx = (offset <= leaf_idx ? leaf_idx - offset : (leaf_idx + size) - offset);
            const ORInt i0 = disj->_task_id_lct[array_idx] - disj->_low;
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

// Edge-Finding algorithms from Nuijten
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
    for (ORInt kk = disj->_beginIdx; kk < disj->_endIdx; kk++) {
        const ORInt k0 = disj->_task_id_est[kk] - disj->_low;
        assert(isPresent(disj, k0));

        if (disj->_dur_min[k0] <= 0)
            continue;
        ORInt P = 0;
        ORInt C = MININT;
        ORInt H = MININT;
        for (ORInt ii = disj->_endIdx - 1; ii >= disj->_beginIdx; ii--) {
            const ORInt i0 = disj->_task_id_est[ii] - disj->_low;
            if (disj->_dur_min[i0] <= 0)
                continue;
            if (disj->_lct[i0] <= disj->_lct[k0]) {
                P += disj->_dur_min[i0];
                C  = max(C, disj->_est[i0] + P);
            }
            Ci[ii] = C;
        }
        for (ORInt ii = disj->_beginIdx; ii < disj->_endIdx; ii++) {
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
    for (ORInt kk = disj->_endIdx - 1; kk >= disj->_beginIdx; kk--) {
        const ORInt k0 = disj->_task_id_lct[kk] - disj->_low;
        assert(isPresent(disj, k0));

        if (disj->_dur_min[k0] <= 0)
            continue;
        ORInt P = 0;
        ORInt C = MAXINT;
        ORInt H = MAXINT;
        for (ORInt ii = disj->_beginIdx; ii < disj->_endIdx; ii++) {
            const ORInt i0 = disj->_task_id_lct[ii] - disj->_low;
            if (disj->_dur_min[i0] <= 0)
                continue;
            if (disj->_est[i0] >= disj->_est[k0]) {
                P += disj->_dur_min[i0];
                C  = min(C, disj->_lct[i0] - P);
            }
            Ci[ii] = C;
        }
        for (ORInt ii = disj->_endIdx - 1; ii >= disj->_beginIdx; ii--) {
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

static void ef_filter_est_and_lct_optional_nuijten(CPTaskDisjunctive * disj, const ORInt size, bool * update)
{
    ef_filter_est_optional_nuijten(disj, size, update);
    ef_filter_lct_optional_nuijten(disj, size, update);
    if (update) updateBounds(disj, size);
}

static void ef_filter_est_optional_nuijten(CPTaskDisjunctive * disj, const ORInt size, bool * update)
{
    ORInt Ci[size];
    for (ORInt kk = disj->_beginIdx; kk < disj->_endIdx; kk++) {
        const ORInt k0 = disj->_task_id_est[kk] - disj->_low;
        if (!isRelevant(disj, k0))
            continue;
        ORInt P = 0;
        ORInt C = MININT;
        ORInt H = MININT;
        for (ORInt ii = disj->_endIdx - 1; ii >= disj->_beginIdx; ii--) {
            const ORInt i0 = disj->_task_id_est[ii] - disj->_low;
            if (disj->_dur_min[i0] <= 0)
                continue;
            if (disj->_lct[i0] <= disj->_lct[k0] && isRelevant(disj, i0)) {
                P += disj->_dur_min[i0];
                C  = max(C, disj->_est[i0] + P);
            }
            Ci[ii] = C;
        }
        for (ORInt ii = disj->_beginIdx; ii < disj->_endIdx; ii++) {
            const ORInt i0 = disj->_task_id_est[ii] - disj->_low;
            if (disj->_dur_min[i0] <= 0)
                continue;
            if (disj->_lct[i0] <= disj->_lct[k0] && isRelevant(disj, i0)) {
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

static void ef_filter_lct_optional_nuijten(CPTaskDisjunctive * disj, const ORInt size, bool * update)
{
    ORInt Ci[size];
    for (ORInt kk = disj->_endIdx - 1; kk >= disj->_beginIdx; kk--) {
        const ORInt k0 = disj->_task_id_lct[kk] - disj->_low;
        if (!isRelevant(disj, k0))
            continue;
        ORInt P = 0;
        ORInt C = MAXINT;
        ORInt H = MAXINT;
        for (ORInt ii = disj->_beginIdx; ii < disj->_endIdx; ii++) {
            const ORInt i0 = disj->_task_id_lct[ii] - disj->_low;
            if (disj->_dur_min[i0] <= 0)
                continue;
            if (disj->_est[i0] >= disj->_est[k0] && isRelevant(disj, i0)) {
                P += disj->_dur_min[i0];
                C  = min(C, disj->_lct[i0] - P);
            }
            Ci[ii] = C;
        }
        for (ORInt ii = disj->_endIdx - 1; ii >= disj->_beginIdx; ii--) {
            const ORInt i0 = disj->_task_id_lct[ii] - disj->_low;
            if (disj->_dur_min[i0] <= 0)
                continue;
            if (disj->_est[i0] >= disj->_est[k0] && isRelevant(disj, i0)) {
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
static ORInt getGlobalSlack(CPTaskDisjunctive * disj)
{
    // Assumptions
    // - called outside the propagation loop =>
    // - the arrays '_est', '_lct', and '_dur_min' contain the current values from
    //   the present and non-absent tasks
    // - the parameters '_begin' and '_end' represent the tightest time window
    //   in that all unbounded tasks (present or non-absent) need to be scheduled
    // - the sorting arrays '_task_id_est' and '_task_id_lct' are sorted
    // - the indices '_beginIdx' and '_endIdx' pointing to the first task and the
    //   task immediately after the last task that fully or partially overlaps
    //   with the tightest time windows in the sorting arrays
    
    // Reading the data
    readData(disj);
    // Testing the data
    assert(^ORBool(){
        for (ORInt tt = 0; tt < disj->_uIdx._val; tt++) {
            const ORInt t  = disj->_idx[tt];
            const ORInt t0 = t - disj->_low;
            if (disj->_est[t0] != disj->_tasks[t].est || disj->_lct[t0] != disj->_tasks[t].lct || disj->_dur_min[t0] != disj->_tasks[t].minDuration)
                return false;
        }
        return true;
    }());
    
    // Sorting tasks regarding their earliest start times
    const ORInt sortSize    = disj->_sortSize._val;
    const ORInt presentSize = disj->_cIdx._val;
    if (presentSize >= sortSize) {
        isort_r(disj->_task_id_est, sortSize, disj, (ORInt(*)(void*, const ORInt*, const ORInt*)) &sortDisjEstAsc);
    }
    else {
        isort_r(disj->_task_id_est, sortSize, disj, (ORInt(*)(void*, const ORInt*, const ORInt*)) &sortDisjEstAscOpt);
    }
    // Testing the sorting of the sorting array '_task_id_est'
    assert(^ORBool() {
        for (ORInt ii = 0; ii < disj->_size - 1; ii++) {
            const ORInt i0 = disj->_task_id_est[ii    ] - disj->_low;
            const ORInt i1 = disj->_task_id_est[ii + 1] - disj->_low;
            if (isIrrelevant(disj, i0) && !isIrrelevant(disj, i1))
                return false;
            else if (!isIrrelevant(disj, i0) && !isIrrelevant(disj, i1) && disj->_est[i0] > disj->_est[i1])
                return false;
        }
        return true;
    }());

    ORInt est_min = MAXINT;
    ORInt lct_max = MININT;
    ORInt len_min = 0;
    // Computing the tightest time interval [est_min, lct_max) that enclosed all
    // unfixed present tasks.
    for (ORInt tt = disj->_beginIdx; tt < disj->_endIdx; tt++) {
        // XXX For the moment being only unfixed present activities are considered
        const ORInt t0 = disj->_task_id_est[tt] - disj->_low;
        if (isRelevant(disj, t0) && isUnfixed(disj, t0)) {
            est_min = min(est_min, disj->_est[t0]);
            lct_max = max(lct_max, disj->_lct[t0]);
        }
    }
    for (ORInt tt = disj->_beginIdx; tt < disj->_endIdx; tt++) {
        const ORInt t0 = disj->_task_id_est[tt] - disj->_low;
        if (isRelevant(disj, t0) && disj->_begin <= disj->_est[t0] && disj->_lct[t0] <= disj->_end)
            len_min += disj->_dur_min[t0];
    }
    
    return (lct_max - est_min - len_min);
}

static ORInt getLocalSlack(CPTaskDisjunctive * disj)
{
    // Assumptions
    // - called outside the propagation loop =>
    // - the arrays '_est', '_lct', and '_dur_min' contain the current values from
    //   the present and non-absent tasks
    // - the parameters '_begin' and '_end' represent the tightest time window
    //   in that all unbounded tasks (present or non-absent) need to be scheduled
    // - the sorting arrays '_task_id_est' and '_task_id_lct' are sorted
    // - the indices '_beginIdx' and '_endIdx' pointing to the first task and the
    //   task immediately after the last task that fully or partially overlaps
    //   with the tightest time windows in the sorting arrays

    // Reading the data
    readData(disj);
    // Testing the data
    assert(^ORBool(){
        for (ORInt tt = 0; tt < disj->_uIdx._val; tt++) {
            const ORInt t  = disj->_idx[tt];
            const ORInt t0 = t - disj->_low;
            if (disj->_est[t0] != disj->_tasks[t].est || disj->_lct[t0] != disj->_tasks[t].lct || disj->_dur_min[t0] != disj->_tasks[t].minDuration)
                return false;
        }
        return true;
    }());
    
    // Sorting tasks regarding their earliest start times
    const ORInt sortSize    = disj->_sortSize._val;
    const ORInt presentSize = disj->_cIdx._val;
    if (presentSize >= sortSize) {
        isort_r(disj->_task_id_est, sortSize, disj, (ORInt(*)(void*, const ORInt*, const ORInt*)) &sortDisjEstAsc);
        isort_r(disj->_task_id_lct, sortSize, disj, (ORInt(*)(void*, const ORInt*, const ORInt*)) &sortDisjLctAsc);
    }
    else {
        isort_r(disj->_task_id_est, sortSize, disj, (ORInt(*)(void*, const ORInt*, const ORInt*)) &sortDisjEstAscOpt);
        isort_r(disj->_task_id_lct, sortSize, disj, (ORInt(*)(void*, const ORInt*, const ORInt*)) &sortDisjLctAscOpt);
    }
    // Testing the sorting of the sorting array '_task_id_est'
    assert(^ORBool() {
        for (ORInt ii = 0; ii < disj->_size - 1; ii++) {
            const ORInt i0 = disj->_task_id_est[ii    ] - disj->_low;
            const ORInt i1 = disj->_task_id_est[ii + 1] - disj->_low;
            if (isIrrelevant(disj, i0) && !isIrrelevant(disj, i1))
                return false;
            else if (!isIrrelevant(disj, i0) && !isIrrelevant(disj, i1) && disj->_est[i0] > disj->_est[i1])
                return false;
        }
        return true;
    }());
    // Testing the sorting of the sorting array '_task_id_lct'
    assert(^ORBool() {
        for (ORInt ii = 0; ii < disj->_size - 1; ii++) {
            const ORInt i0 = disj->_task_id_lct[ii    ] - disj->_low;
            const ORInt i1 = disj->_task_id_lct[ii + 1] - disj->_low;
            if (isIrrelevant(disj, i0) && !isIrrelevant(disj, i1))
                return false;
            else if (!isIrrelevant(disj, i0) && !isIrrelevant(disj, i1) && disj->_lct[i0] > disj->_lct[i1])
                return false;
        }
        return true;
    }());
    
//    const ORInt presentSize = disj->_cIdx._val;
    ORInt localSlack = MAXINT;
    ORInt len_min = 0;
    ORInt jjPrev  = 0;
    ORInt jjLast  = presentSize - 1;
    
    for (ORInt jj = presentSize - 1; jj >= 0; jj--) {
        const ORInt j0 = disj->_task_id_lct[jj] - disj->_low;
        if (isUnfixed(disj, j0)) {
            jjLast = jj;
            break;
        }
    }
    
    for (ORInt ii = 0; ii < presentSize; ii++) {
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
                        assert(localSlack >= 0);
                    }
                    else if (est_min <= disj->_est[j0]) {
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
    const ORInt presentSize = disj->_cIdx._val;
    
    ORInt ect[presentSize];
    ORInt h[  presentSize];
    
    // Initialisation of the arrays
    for (ORInt tt = 0; tt < presentSize; tt++) {
        const ORInt t0 = disj->_idx[tt] - disj->_low;
        // XXX Only consider present activities for the moment
        assert(isRelevant(disj, t0));
        assert(isRelevant(disj, disj->_task_id_est[tt] - disj->_low));
        assert(isRelevant(disj, disj->_task_id_ect[tt] - disj->_low));
        ect[tt] = disj->_est[t0] + disj->_dur_min[t0];
        h[tt] = 1;
    }
    
    Profile prof = getEarliestContentionProfile(disj->_task_id_est, disj->_task_id_ect, disj->_est, ect, h, presentSize);
    
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

// Reading the tasks data and storing them in the data structure of the propagator
// - Data read: bound, est,  lct, minDuration, maxDuration,  present,  absent
// - Data stored:     _est, _lct,    _dur_min,    _dur_max, _present, _absent
static void readData(CPTaskDisjunctive * disj)
{
    ORInt boundSize = disj->_boundSize._val;

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
        
        // Swap bounded or irrelevant tasks to the beginning of the array
        if (bound || isIrrelevant(disj, t0))
            swapORInt(disj->_bound, boundSize++, tt);
        // Compute relevant time horizon
        if (!isIrrelevant(disj, t0)) {
            disj->_begin = min(disj->_begin, disj->_est[t0]);
            disj->_end   = max(disj->_end  , disj->_lct[t0]);
        }
    }
    // Trail the bound size
    if (boundSize > disj->_boundSize._val)
        assignTRInt(&(disj->_boundSize), boundSize, disj->_trail);
}

/*******************************************************************************
 Main Propagation Loop
 ******************************************************************************/

static void doPropagation(CPTaskDisjunctive * disj) {
    const ORInt sortSize = disj->_sortSize._val;
    
    cleanUp(disj);
    
    // Storing the change data in the disjunctive data structures
    readData(disj);
    
    // Updating indices stored in '_idx'. It will change '_uIdx' and '_cIdx' too.
    updateIndices(disj);
    
    const ORInt unknownSize = disj->_uIdx._val;
    const ORInt presentSize = disj->_cIdx._val;

    if (unknownSize <= 1 || presentSize < 1 || disj->_begin == MAXINT) {
        return ;
    }
    
    // Allocation of memory
    disj->_new_est      = alloca(disj->_size * sizeof(ORInt));
    disj->_new_lct      = alloca(disj->_size * sizeof(ORInt));
    ORInt * idx_map_est = alloca(disj->_size * sizeof(ORInt));
    ORInt * idx_map_lct = alloca(disj->_size * sizeof(ORInt));
    
    // Determing the size of the tree
    const ORInt tsize = 2 * unknownSize - 1;
    const ORInt tdepth = getDepth(tsize);
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
    for (ORInt tt = 0; tt < unknownSize; tt++) {
        const ORInt t  = disj->_idx[tt];
        const ORInt t0 = t - disj->_low;

        disj->_new_est[t0] = disj->_est[t0];
        disj->_new_lct[t0] = disj->_lct[t0];
    }
    //   for (ORInt tt = 0; tt < size; tt++)
    //      NSLog(@" Task[%d] = %@",tt,disj->_tasks[tt]);
    
    // Sorting tasks regarding their earliest start and latest completion times
    if (presentSize >= sortSize) {
        isort_r(disj->_task_id_est, sortSize, disj, (ORInt(*)(void*, const ORInt*, const ORInt*)) &sortDisjEstAsc);
        isort_r(disj->_task_id_lct, sortSize, disj, (ORInt(*)(void*, const ORInt*, const ORInt*)) &sortDisjLctAsc);
    }
    else {
        isort_r(disj->_task_id_est, sortSize, disj, (ORInt(*)(void*, const ORInt*, const ORInt*)) &sortDisjEstAscOpt);
        isort_r(disj->_task_id_lct, sortSize, disj, (ORInt(*)(void*, const ORInt*, const ORInt*)) &sortDisjLctAscOpt);
    }
    // Testing the sorting of the sorting array '_task_id_est'
    assert(^ORBool() {
        for (ORInt ii = 0; ii < disj->_size - 1; ii++) {
            const ORInt i0 = disj->_task_id_est[ii    ] - disj->_low;
            const ORInt i1 = disj->_task_id_est[ii + 1] - disj->_low;
            if (isIrrelevant(disj, i0) && !isIrrelevant(disj, i1))
                return false;
            else if (!isIrrelevant(disj, i0) && !isIrrelevant(disj, i1) && disj->_est[i0] > disj->_est[i1])
                return false;
        }
        return true;
    }());
    // Testing the sorting of the sorting array '_task_id_lct'
    assert(^ORBool() {
        for (ORInt ii = 0; ii < disj->_size - 1; ii++) {
            const ORInt i0 = disj->_task_id_lct[ii    ] - disj->_low;
            const ORInt i1 = disj->_task_id_lct[ii + 1] - disj->_low;
            if (isIrrelevant(disj, i0) && !isIrrelevant(disj, i1))
                return false;
            else if (!isIrrelevant(disj, i0) && !isIrrelevant(disj, i1) && disj->_lct[i0] > disj->_lct[i1])
                return false;
        }
        return true;
    }());
    
    // Computation of the sorting array indices determining which tasks need
    // to be considered during current propagation
    disj->_beginIdx = MININT;
    disj->_endIdx   = MININT;
    for (ORInt ii = 0; ii < sortSize; ii++) {
        const ORInt i0 = disj->_task_id_est[ii] - disj->_low;
        if (!isIrrelevant(disj, i0) && disj->_lct[i0] > disj->_begin) {
            disj->_beginIdx = ii;
            break;
        }
    }
    assert(0 <= disj->_beginIdx && disj->_beginIdx < sortSize);
    for (ORInt ii = sortSize - 1; ii >= disj->_beginIdx; ii--) {
        const ORInt i0 = disj->_task_id_est[ii] - disj->_low;
        if (!isIrrelevant(disj, i0) && disj->_est[i0] < disj->_end) {
            disj->_endIdx = ii + 1;
            break;
        }
    }
    assert(0 < disj->_endIdx && disj->_endIdx <= sortSize);
    assert(disj->_endIdx - disj->_beginIdx <= unknownSize);
    
    // Initialisation of the positions of the tasks
    initIndexMap(disj, disj->_task_id_est, idx_map_est, unknownSize, tsize, tdepth);

    // Consistency check
    if (presentSize >= unknownSize) {
        ef_overload_check_vilim(disj, unknownSize, idx_map_est, theta, tsize);
    }
    else {
        ef_overload_check_optional_vilim(disj, unknownSize, idx_map_est, theta, lambda, tsize, tdepth);
    }
    
    // Further initialisations needed for the filtering algorithm
    initIndexMap(disj, disj->_task_id_lct, idx_map_lct, unknownSize, tsize, tdepth);
    if (presentSize >= sortSize) {
        isort_r(disj->_task_id_ect, sortSize, disj, (ORInt(*)(void*, const ORInt*, const ORInt*)) &sortDisjEctAsc);
        isort_r(disj->_task_id_lst, sortSize, disj, (ORInt(*)(void*, const ORInt*, const ORInt*)) &sortDisjLstAsc);
    }
    else {
        isort_r(disj->_task_id_ect, sortSize, disj, (ORInt(*)(void*, const ORInt*, const ORInt*)) &sortDisjEctAscOpt);
        isort_r(disj->_task_id_lst, sortSize, disj, (ORInt(*)(void*, const ORInt*, const ORInt*)) &sortDisjLstAscOpt);
    }
    // Testing the sorting of the sorting array '_task_id_ect'
    assert(^ORBool() {
        for (ORInt ii = 0; ii < disj->_size - 1; ii++) {
            const ORInt i0 = disj->_task_id_ect[ii    ] - disj->_low;
            const ORInt i1 = disj->_task_id_ect[ii + 1] - disj->_low;
            if (isIrrelevant(disj, i0) && !isIrrelevant(disj, i1))
                return false;
            else if (!isIrrelevant(disj, i0) && !isIrrelevant(disj, i1) && disj->_est[i0] + disj->_dur_min[i0] > disj->_est[i1] + disj->_dur_min[i1])
                return false;
        }
        return true;
    }());
    // Testing the sorting of the sorting array '_task_id_lst'
    assert(^ORBool() {
        for (ORInt ii = 0; ii < disj->_size - 1; ii++) {
            const ORInt i0 = disj->_task_id_lst[ii    ] - disj->_low;
            const ORInt i1 = disj->_task_id_lst[ii + 1] - disj->_low;
            if (isIrrelevant(disj, i0) && !isIrrelevant(disj, i1))
                return false;
            else if (!isIrrelevant(disj, i0) && !isIrrelevant(disj, i1) && disj->_lct[i0] - disj->_dur_min[i0] > disj->_lct[i1] - disj->_dur_min[i1])
                return false;
        }
        return true;
    }());
    
    if (disj->_uIdx._val != disj->_sortSize._val)
        assignTRInt(&(disj->_sortSize), disj->_uIdx._val, disj->_trail);

    bool update = false;
    
    // Detectable precedences
    if (disj->_dprec) {
        if (presentSize >= unknownSize) {
            dprec_filter_est_and_lct_vilim(disj, unknownSize, idx_map_est, idx_map_lct, theta, tsize, & update);
        }
        else {
            dprec_filter_est_and_lct_optional_vilim(disj, unknownSize, idx_map_est, idx_map_lct, theta, lambda, tsize, tdepth, & update);
        }
    }
    // Not-first/not-last
    if (!update && disj->_nfnl) {
        if (presentSize >= unknownSize) {
            nfnl_filter_est_and_lct_vilim(disj, unknownSize, idx_map_est, idx_map_lct, theta, tsize, & update);
        }
        else {
            nfnl_filter_est_and_lct_optional_vilim(disj, unknownSize, idx_map_est, idx_map_lct, theta, lambda, tsize, tdepth, & update);
        }
    }
    // Edge-finding
    if (!update && disj->_ef) {
        if (presentSize >= unknownSize) {
            // NOTE: Nuijten's algorithm has a time complexity of O(n^2)
//            ef_filter_est_and_lct_nuijten(disj, size, & update);
            ef_filter_est_and_lct_vilim(disj, unknownSize, idx_map_est, idx_map_lct, theta, lambda, tsize, tdepth, & update);
        }
        else {
            // NOTE: This algorithms has a time-complexity of O(n^2)
            ef_filter_est_and_lct_optional_nuijten(disj, unknownSize, & update);
        }
    }
}

@end


