/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2013-14 NICTA, Andreas Schutt and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <CPUKernel/CPConstraintI.h>
#import <objcp/CPIntVarI.h>
#import "CPDisjunctive.h"
#import "CPMisc.h"

// TODO Replacing ORUInts by ORInts

// Randomly set
#define MAXNBTASK ((MAXINT)/4)

@implementation CPDisjunctive {
    // Attributs of tasks
    CPIntVar **  _start0;   // Start times
    CPIntVar **  _dur0;     // Durations
    ORInt    *   _idx;      // Indices of activities
    
    ORUInt       _size;     // Number of considered tasks
    TRInt        _cIdx;     // Size of present activities
    TRInt        _uIdx;     // Size of present and non-present activities
    
    // Variables needed for the propagation
    // NOTE: Memory is dynamically allocated by alloca/1 each time the propagator
    //      is called.
    ORInt * _est;           // Earliest start times
    ORInt * _lct;           // Latest completion times
    ORInt * _dur_min;       // Minimal durations
    ORInt * _new_est;       // New earliest start times
    ORInt * _new_lct;       // New latest completion times
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
-(id) initCPDisjunctive: (id<CPIntVarArray>) s duration: (id<CPIntVarArray>) d
{
    // Checking whether the arrays have the same size
    if (s.count != d.count) {
        @throw [[ORExecutionError alloc] initORExecutionError: "CPDisjunctive: Number of elements in the input arrays differ!"];
    }

    // Checking whether the number of activities is within the limit
    if (s.count > (NSUInteger) MAXNBTASK) {
        @throw [[ORExecutionError alloc] initORExecutionError: "CPDisjunctive: Number of elements exceeds beyond the limit!"];
    }
    
    self = [super initCPCoreConstraint: [[s at: s.low] engine]];
    NSLog(@"Create disjunctive constraint\n");
    // TODO Changing the priority
    _priority = LOWEST_PRIO + 3;
    _act   = NULL;
    _start = s;
    _dur   = d;
    _idx   = NULL;

    _idempotent = true;
    _dprec = true;
    _nfnl  = true;
    _ef    = true;
    
    _start0 = NULL;
    _dur0   = NULL;
    
    _est         = NULL;
    _lct         = NULL;
    _dur_min     = NULL;
    _task_id_est = NULL;
    _task_id_ect = NULL;
    _task_id_lst = NULL;
    _task_id_lct = NULL;
    
    _size = (ORUInt) _start.count;
    
    return self;
}
-(id) initCPDisjunctive: (id<CPActivityArray>) act
{
    // Checking whether the number of activities is within the limit
    if (act.count > (NSUInteger) MAXNBTASK) {
        @throw [[ORExecutionError alloc] initORExecutionError: "CPDisjunctive: Number of elements exceeds beyond the limit!"];
    }

    id<CPActivity> act0 = [act at: act.low];
    self = [super initCPCoreConstraint: [act0.startLB engine]];
    NSLog(@"Create disjunctive constraint\n");
    // TODO Changing the priority
    _priority = LOWEST_PRIO + 3;
    _act   = act;
    _start = NULL;
    _dur   = NULL;
    _idx   = NULL;
    
    _idempotent = true;
    _dprec = true;
    _nfnl  = true;
    _ef    = false;
    
    _start0 = NULL;
    _dur0   = NULL;
    
    _est         = NULL;
    _lct         = NULL;
    _dur_min     = NULL;
    _task_id_est = NULL;
    _task_id_ect = NULL;
    _task_id_lst = NULL;
    _task_id_lct = NULL;
    
    _size = (ORUInt) _act.count;
    
    return self;
}
-(void) dealloc
{
    if (_start0  != NULL) free(_start0 );
    if (_dur0    != NULL) free(_dur0   );
    if (_idx     != NULL) free(_idx    );
    
    [super dealloc];
}
-(ORStatus) post
{
    _cIdx         = makeTRInt(_trail, 0     );
    _uIdx         = makeTRInt(_trail, _size );
    _global_slack = makeTRInt(_trail, MAXINT);
    
    // Allocating memory
    _start0 = malloc(_size * sizeof(CPIntVar*));
    _dur0   = malloc(_size * sizeof(CPIntVar*));
    _idx    = malloc(_size * sizeof(ORInt    ));
    
    // Checking whether memory allocation was successful
    if (_start0 == NULL || _dur0 == NULL || _idx == NULL) {
        @throw [[ORExecutionError alloc] initORExecutionError: "CPDisjunctive: Out of memory!"];
    }
    
    if (_act == NULL) {
        // Copying elements to the C arrays
        ORInt iSt = _start.low;
        ORInt iDu = _dur  .low;
    
        for (ORInt i = 0; i < _size; i++, iSt++, iDu++) {
            _start0[i] = (CPIntVar*) _start[iSt];
            _dur0  [i] = (CPIntVar*) _dur  [iDu];
        }
        for (ORInt i = 0; i < _size; i++) {
            _idx[i] = i;
        }
    }
    else {
        for (ORInt i = 0; i < _size; i++) {
            _idx[i] = i + _act.low;
        }
    }
    
    // Initial propagation
    [self propagate];
    
    // Subscription of variables to the constraint
    for (ORInt i = 0; i < _size; i++) {
        if (_act == NULL) {
            if (!_start0[i].bound)
                [_start0[i] whenChangeBoundsPropagate: self];
            if (!_dur0[i].bound)
                [_dur0[i]   whenChangeMinPropagate:    self];
        }
        else {
            const ORInt iOff = i + _act.low;
            if (_act[iOff].isOptional && _act[iOff].top.max == 0) continue;
            if (!_act[iOff].startLB.bound)
                [_act[iOff].startLB whenChangeMinPropagate: self];
            if (!_act[iOff].startUB.bound)
                [_act[iOff].startUB whenChangeMaxPropagate: self];
            if (!_act[iOff].duration.bound)
                [_act[iOff].duration whenChangeMinPropagate: self];
            if (_act[iOff].isOptional)
                [_act[iOff].top whenChangeMinPropagate: self];
        }
    }
    
    // Return the state
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
    for(ORInt i = 0; i < _size; i++) {
        if (_act == NULL) {
            [rv addObject: _start0[i] ];
            [rv addObject: _dur0  [i] ];
        }
        else {
            [rv addObject:_act[i + _act.range.low].startLB ];
            [rv addObject:_act[i + _act.range.low].duration];
        }
    }
    [rv autorelease];
    return rv;
}
-(ORUInt) nbUVars
{
    ORUInt nb = 0;
    if (_act == NULL) {
        for (ORInt i = 0; i < _size; i++) {
            if (!_start0[i].bound) nb++;
            if (!_dur0  [i].bound) nb++;
        }
    }
    else {
        for (ORInt ii = 0; ii < _uIdx._val; ii++) {
            const ORInt i = _idx[ii];
            if (_act[i].isOptional && !_act[i].top.bound) nb++;
            if (!_act[i].isOptional || _act[i].top.bound) {
                if (_act[i].startLB .bound) nb++;
                if (_act[i].duration.bound) nb++;
            }
        }
    }
    return nb;
}
-(NSString*)description
{
    return [NSString stringWithFormat:@"CPDisjunctive"];
}
-(ORInt) globalSlack
{
    return _global_slack._val;
}
-(ORInt) localSlack
{
    return getLocalSlack(self);
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    assert(false);
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
    assert(false);
}


/*******************************************************************************
 Propagation implementation in C
 ******************************************************************************/

static inline
BOOL isPresent(CPDisjunctive * disj, const ORInt idx)
{
    if (disj->_act == NULL || !disj->_act[idx].isOptional) return TRUE;
    if (disj->_act[idx].top.min == 1) return TRUE;
    return FALSE;
}

static inline
BOOL isAbsent(CPDisjunctive * disj, const ORInt idx)
{
    if (disj->_act != NULL && disj->_act[idx].isOptional && disj->_act[idx].top.max == 0) return TRUE;
    return FALSE;
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
static void initThetaLambdaTreeWithEct(CPDisjunctive * disj, const ORInt size, const ORUInt * idx_map_est, ThetaTree * theta, LambdaTree * lambda, const ORUInt tsize) {
    // Inserting all tasks into the Theta tree
    for (ORUInt i = 0; i < size; i++) {
        const ORUInt idx = idx_map_est[i];
        if (disj->_dur_min[i] > 0) {
            theta[idx]._length = disj->_dur_min[i];
            theta[idx]._time   = disj->_est[i] + disj->_dur_min[i];
        }
        else {
            theta[idx]._length = 0;
            theta[idx]._time   = MININT;
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
static void initThetaLambdaTreeWithLst(CPDisjunctive * disj, const ORInt size, const ORUInt * idx_map_lct, ThetaTree * theta, LambdaTree * lambda, const ORUInt tsize) {
    // Inserting all tasks into the Theta tree
    for (ORUInt i = 0; i < size; i++) {
        const ORUInt idx = idx_map_lct[i];
        if (disj->_dur_min[i] > 0) {
            theta[idx]._length = disj->_dur_min[i];
            theta[idx]._time   = disj->_lct[i] - disj->_dur_min[i];
        }
        else {
            theta[idx]._length = 0;
            theta[idx]._time   = MAXINT;
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
static void initIndexMap(ORInt * array, ORUInt * idx_map, const ORUInt sizeArray, const ORUInt sizeTree, const ORUInt depth) {
    ORInt tt = 0;
    ORInt leaf = (1 << depth) - 1;
    // nbLeaves >= (nbLeaves in lowest level) + (nbLeaves in second lowest level)
    assert(sizeArray >= (sizeTree - leaf) + ((1 << (depth - 1)) - (sizeTree - leaf) / 2));
    for (tt = 0; leaf < sizeTree; tt++, leaf++) {
        idx_map[array[tt]] = leaf;
    }
    assert(leaf == sizeTree);
    leaf = PARENT(leaf);
    for (; tt < sizeArray; tt++, leaf++) {
        idx_map[array[tt]] = leaf;
    }
}


/*******************************************************************************
 Auxiliary Functions
 ******************************************************************************/

static void cleanUp(CPDisjunctive* disj) {
    disj->_est         = NULL;
    disj->_lct         = NULL;
    disj->_dur_min     = NULL;
    disj->_task_id_est = NULL;
    disj->_task_id_ect = NULL;
    disj->_task_id_lst = NULL;
    disj->_task_id_lct = NULL;

}


static void dumpTask(CPDisjunctive * disj, ORInt t) {
    printf("task %d: est %d; ect %d; lst %d; lct %d\n", t, disj->_est[t], disj->_est[t] + disj->_dur_min[t], disj->_lct[t] - disj->_dur_min[t], disj->_lct[t]);
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
int sortDisjEstAsc(CPDisjunctive * disj, const ORInt * r1, const ORInt * r2)
{
    return disj->_est[*r1] - disj->_est[*r2];
}

// Sorting tasks ID according to the earliest completion times
//
int sortDisjEctAsc(CPDisjunctive * disj, const ORInt * r1, const ORInt * r2)
{
    return disj->_est[*r1] - disj->_est[*r2] + disj->_dur_min[*r1] - disj->_dur_min[*r2];
}

// Sorting tasks ID according to the latest start times
//
int sortDisjLstAsc(CPDisjunctive * disj, const ORInt * r1, const ORInt * r2)
{
    return disj->_lct[*r1] - disj->_lct[*r2] - disj->_dur_min[*r1] + disj->_dur_min[*r2];
}

// Sorting tasks ID according to the latest completion times
//
int sortDisjLctAsc(CPDisjunctive * disj, const ORInt * r1, const ORInt * r2)
{
    return disj->_lct[*r1] - disj->_lct[*r2];
}


/*******************************************************************************
 Functions for Updating the Bounds
 ******************************************************************************/

static void updateBounds(CPDisjunctive * disj, const ORInt size)
{
    for (ORInt i = 0; i < size; i++) {
        if (disj->_new_est[i] > disj->_est[i]) {
            const ORInt t = disj->_idx[i];
            if (disj->_act == NULL) {
                [disj->_start0[t] updateMin: disj->_new_est[i]];
            }
            else {
                [disj->_act[t] updateStartMin:disj->_new_est[i]];
            }
            if (disj->_idempotent) disj->_est[i] = disj->_new_est[i];
        }
        if (disj->_new_lct[i] < disj->_lct[i]) {
            const ORInt t = disj->_idx[i];
            if (disj->_act == NULL) {
                [disj->_start0[t] updateMax: disj->_new_lct[i] - disj->_dur_min[i]];
            }
            else {
                [disj->_act[t] updateStartMax: disj->_new_lct[i] - disj->_dur_min[i]];
            }
            if (disj->_idempotent) disj->_lct[i] = disj->_new_lct[i];
        }
    }
}


/*******************************************************************************
 Resource Overload Consistency Checks
 ******************************************************************************/

// Resource overload check from Vilim
//  Time: O(n log n)
//  Space: O(n)
//
static void ef_overload_check_vilim(CPDisjunctive * disj, const ORInt size, const ORUInt * idx_map_est, ThetaTree * theta, const ORUInt tsize)
{
    initThetaTree(theta, tsize, MININT);
    // Iteration in non-decreasing order of the latest completion time
    for (ORInt tt = 0; tt < size; tt++) {
        const ORInt t = disj->_task_id_lct[tt];
        // Retrieve task's position in task_id_est
        const ORUInt tree_idx = idx_map_est[t];
        const ORInt ect_t = disj->_est[t] + disj->_dur_min[t];
        // Insert task into theta tree
        insertThetaNodeAtIdxEct(theta, tsize, tree_idx, disj->_dur_min[t], ect_t);
        // Check for resource overload
        if (theta[0]._time > disj->_lct[t]) {
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
static void ef_overload_check_optional_vilim(CPDisjunctive * disj, const ORInt size, const ORUInt * idx_map_est, ThetaTree * theta, LambdaTree * lambda, const ORUInt tsize, const ORUInt tdepth)
{
    // Initialisation of Theta and Lambda tree
    initThetaTree( theta,  tsize, MININT);
    initLambdaTree(lambda, tsize, MININT);
    // 'offset' reflects the total of nodes in the trees except the nodes in the deepest level
    const ORUInt offset = (1 << tdepth) - 1;
    // Iteration in non-descreasing order of the latest completion time
    for (ORInt tt = 0; tt < size; tt++) {
        const ORInt t = disj->_task_id_lct[tt];
        if (isPresent(disj, disj->_idx[t])) {
            // Compulsory activity
            // Retrieve task's position in task_id_est
            const ORUInt tree_idx = idx_map_est[t];
            const ORInt ect_t = disj->_est[t] + disj->_dur_min[t];
            // Insert activity into theta tree
            insertThetaNodeAtIdxEct(theta, tsize, tree_idx, disj->_dur_min[t], ect_t);
            // Update lambda tree
            insertLambdaNodeAtIdxEct(theta, lambda, tsize, tree_idx, 0, MININT);
            // Check for resource overload
            if (theta[0]._time > disj->_lct[t]) {
                failNow();
            }
        }
        else if (!isAbsent(disj, disj->_idx[t])) {
            // Optional activity
            insertLambdaNodeAtIdxEct(theta, lambda, tsize, idx_map_est[t], disj->_dur_min[t], disj->_est[t] + disj->_dur_min[t]);
        }
        // Dectection of potential overloads
        while (lambda[0]._gTime > disj->_lct[t]) {
            // Retrieve responsible leaf
            const ORUInt leaf_idx = retrieveResponsibleLambdaNodeWithEct(theta, lambda, tsize);
            // The leaf must be a gray one
            assert(theta[leaf_idx]._time == MININT && lambda[leaf_idx]._gTime != MININT);
            // Map leaf index to task ID
            const ORUInt array_idx = (offset <= leaf_idx ? leaf_idx - offset : (leaf_idx + size) - offset);
            const ORUInt k = disj->_task_id_est[array_idx];
            assert(leaf_idx == idx_map_est[k]);
            // Set to absent
            [disj->_act[disj->_idx[k]].top updateMax: 0];
            // Remove from Lambda tree
            insertLambdaNodeAtIdxEct(theta, lambda, tsize, idx_map_est[k], 0, MININT);
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
static void dprec_filter_est_and_lct_vilim(CPDisjunctive * disj, const ORInt size, const ORUInt * idx_map_est, const ORUInt * idx_map_lct, ThetaTree * theta, const ORUInt tsize, bool * update)
{
    dprec_filter_est_vilim(disj, size, idx_map_est, theta, tsize, update);
    dprec_filter_lct_vilim(disj, size, idx_map_lct, theta, tsize, update);
    if (update) updateBounds(disj, size);
}

static void dprec_filter_est_vilim(CPDisjunctive * disj, const ORInt size, const ORUInt * idx_map_est, ThetaTree * theta, const ORUInt tsize, bool * update)
{
    // Inititialise Theta tree
    initThetaTree(theta, tsize, MININT);
    ORInt jj = 0;
    ORUInt j = disj->_task_id_lst[jj];
    // Outer loop:
    //  Iterating over the tasks in ascending order of their earliest completion time
    for (ORInt ii = 0; ii < size; ii++) {
        const ORInt i = disj->_task_id_ect[ii];
        // Inner loop:
        // Iterating over the tasks in ascending order of their latest start time
        while (jj < size && disj->_est[i] + disj->_dur_min[i] > disj->_lct[j] - disj->_dur_min[j]) {
            // Task 'j' precedes task 'i'
            const ORUInt tree_idx = idx_map_est[j];
            insertThetaNodeAtIdxEct(theta, tsize, tree_idx, disj->_dur_min[j], disj->_est[j] + disj->_dur_min[j]);
            jj++;
            j = disj->_task_id_lst[jj];
        };
        // Computing the maximal earliest completion time of the tasks in the tree
        // excluding the task 'i'
        ORInt ect_t;
        if (disj->_est[i] + disj->_dur_min[i] > disj->_lct[i] - disj->_dur_min[i]) {
            // Task 'i' is in the tree
            insertThetaNodeAtIdxEct(theta, tsize, idx_map_est[i], 0, MININT);
            ect_t = theta[0]._time;
            insertThetaNodeAtIdxEct(theta, tsize, idx_map_est[i], disj->_dur_min[i], disj->_est[i] + disj->_dur_min[i]);
        }
        else {
            // Task 'i' is not in the tree
            ect_t = theta[0]._time;
        }
        // Checking for a new bound update
        if (ect_t > disj->_est[i]) {
            // New lower bound found
            disj->_new_est[i] = ect_t;
            *update = true;
        }
    }
}

static void dprec_filter_lct_vilim(CPDisjunctive * disj, const ORInt size, const ORUInt * idx_map_lct, ThetaTree * theta, const ORUInt tsize, bool * update)
{
    // Inititialise Theta tree
    initThetaTree(theta, tsize, MAXINT);
    ORInt jj = size - 1;
    ORUInt j = disj->_task_id_ect[jj];
//    printf("+++++++\n");
    // Outer loop:
    // Iterating over the tasks in descending order of their latest start time
    for (ORInt ii = size - 1; ii >= 0; ii--) {
        const ORUInt i = disj->_task_id_lst[ii];
//        printf("Outer loop: ii %d\n", ii);
//        dumpTask(disj, i);
        // Inner loop:
        // Iterating over the tasks in descending order of their earliest completion time
//        printf("\tBefore Inner loop: jj %d\n\t", jj);
//        dumpTask(disj, j);
        while (jj >= 0 && disj->_lct[i] - disj->_dur_min[i] < disj->_est[j] + disj->_dur_min[j]) {
            // Task 'i' precedes task 'j'
            insertThetaNodeAtIdxLst(theta, tsize, idx_map_lct[j], disj->_dur_min[j], disj->_lct[j] - disj->_dur_min[j]);
            jj--;
            j = disj->_task_id_ect[jj];
//            printf("\tBefore Inner loop: jj %d\n\t", jj);
//            dumpTask(disj, j);
        }
        // Computing the minimal latest start time of the tasks in the tree
        // excluding the task 'i'
        ORInt lst_t;
        if (disj->_lct[i] - disj->_dur_min[i] < disj->_est[i] + disj->_dur_min[i]) {
            // Task 'i' is in the tree
            insertThetaNodeAtIdxLst(theta, tsize, idx_map_lct[i], 0, MAXINT);
            lst_t = theta[0]._time;
            insertThetaNodeAtIdxLst(theta, tsize, idx_map_lct[i], disj->_dur_min[i], disj->_lct[i] - disj->_dur_min[i]);
        }
        else {
            lst_t = theta[0]._time;
        }
        // Checking for a new bound update
        if (lst_t < disj->_lct[i]) {
            // New upper bound found
//            printf("New upper bound for task %d (idx %d): %d -> %d\n", i, idx_map_lct[i], disj->_new_lct[i], lst_t);
//            dumpThetaTree(theta, tsize);
            disj->_new_lct[i] = lst_t;
            *update = true;
        }
    }
}


static void dprec_filter_est_and_lct_optional_vilim(CPDisjunctive * disj, const ORInt size, const ORUInt * idx_map_est, const ORUInt * idx_map_lct, ThetaTree * theta, LambdaTree * lambda, const ORUInt tsize, const ORUInt tdepth, bool * update)
{
    dprec_filter_est_optional_vilim(disj, size, idx_map_est, theta, lambda, tsize, tdepth, update);
    dprec_filter_lct_optional_vilim(disj, size, idx_map_lct, theta, lambda, tsize, tdepth, update);
    if (update) updateBounds(disj, size);
}

static void dprec_filter_est_optional_vilim(CPDisjunctive * disj, const ORInt size, const ORUInt * idx_map_est, ThetaTree * theta, LambdaTree * lambda, const ORUInt tsize, const ORUInt tdepth, bool * update)
{
    // Initialise Theta-Lambda tree
    initThetaTree( theta,  tsize, MININT);
    initLambdaTree(lambda, tsize, MININT);
    // 'offset' reflects the total of nodes in the trees except the nodes in the deepest level
    const ORUInt offset = (1 << tdepth) - 1;
    // Initialisations for the inner while-loop
    ORInt jj = 0;
    ORUInt j = disj->_task_id_lst[jj];
    // Outer loop:
    //  Iterating over the tasks in ascending order of their earliest completion time
    for (ORInt ii = 0; ii < size; ii++) {
        const ORInt i = disj->_task_id_ect[ii];
        // Check for absent activities
        if (isAbsent(disj, disj->_idx[i])) continue;
        // Inner loop:
        // Iterating over the tasks in ascending order of their latest start time
        while (jj < size && disj->_est[i] + disj->_dur_min[i] > disj->_lct[j] - disj->_dur_min[j]) {
            // Task 'j' precedes task 'i'
            const ORUInt tree_idx = idx_map_est[j];
            const ORInt  dur_j    = disj->_dur_min[j];
            const ORInt  ect_j    = disj->_dur_min[j] + disj->_est[j];
            // Insert activity in Theta-Lambda tree
            if (isPresent(disj, disj->_idx[j])) {
                // Compulsory activity or present optional activity
                insertThetaNodeAtIdxEct(theta, tsize, tree_idx, dur_j, ect_j);
                // Update Lambda tree
                insertLambdaNodeAtIdxEct(theta, lambda, tsize, tree_idx, 0, MININT);
//                printf("Present: ");
//                dumpTask(disj, j);
            }
            else if (!isAbsent(disj, disj->_idx[j])) {
                // Optional activity
                insertLambdaNodeAtIdxEct(theta, lambda, tsize, tree_idx, dur_j, ect_j);
//                printf("Optional: ");
            }
            jj++;
            j = disj->_task_id_lst[jj];
        };
        // Computing the maximal earliest completion time of the tasks in the tree
        // excluding the task 'i'
        const ORBool inTheta_i = (isPresent(disj, disj->_idx[i]) && disj->_est[i] + disj->_dur_min[i] > disj->_lct[i] - disj->_dur_min[i]);
        ORInt ect_t = theta[0]._time;
        if (inTheta_i) {
            // Task 'i' is in the Theta tree
            insertThetaNodeAtIdxEct(theta, tsize, idx_map_est[i], 0, MININT);
            // Update Lambda tree
            insertLambdaNodeAtIdxEct(theta, lambda, tsize, idx_map_est[i], 0, MININT);
            ect_t = theta[0]._time;
        }
        if (isPresent(disj, disj->_idx[i])) {
            // Detection of potential overloads
            //
            while (lambda[0]._gTime > disj->_lct[i] - disj->_dur_min[i]) {
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
                const ORUInt k = disj->_task_id_est[array_idx];
                assert(leaf_idx == idx_map_est[k]);
                // Set to absent
                [disj->_act[disj->_idx[k]].top updateMax: 0];
                // Remove from Lambda tree
                insertLambdaNodeAtIdxEct(theta, lambda, tsize, idx_map_est[k], 0, MININT);
            }
        }
        if (inTheta_i) {
            // Insert activity 'i' in Theta tree
            insertThetaNodeAtIdxEct(theta, tsize, idx_map_est[i], disj->_dur_min[i], disj->_est[i] + disj->_dur_min[i]);
            // Update Lambda tree
            insertLambdaNodeAtIdxEct(theta, lambda, tsize, idx_map_est[i], 0, MININT);
        }
        // Checking for a new bound update
        if (ect_t > disj->_est[i]) {
            if (ect_t > disj->_lct[i] - disj->_dur_min[i])
                failNow();
            // New lower bound found
            disj->_new_est[i] = ect_t;
            *update = true;
        }
    }
}

static void dprec_filter_lct_optional_vilim(CPDisjunctive * disj, const ORInt size, const ORUInt * idx_map_lct, ThetaTree * theta, LambdaTree * lambda, const ORUInt tsize, const ORUInt tdepth, bool * update)
{
    // Inititialise Theta-Lambda tree
    initThetaTree( theta,  tsize, MAXINT);
    initLambdaTree(lambda, tsize, MAXINT);
    // 'offset' reflects the total of nodes in the trees except the nodes in the deepest level
    const ORUInt offset = (1 << tdepth) - 1;
    ORInt jj = size - 1;
    ORUInt j = disj->_task_id_ect[jj];
    // Outer loop:
    // Iterating over the tasks in descending order of their latest start time
    for (ORInt ii = size - 1; ii >= 0; ii--) {
        const ORUInt i = disj->_task_id_lst[ii];
        // Check for absent activities
        if (isAbsent(disj, disj->_idx[i])) continue;
        // Inner loop:
        // Iterating over the tasks in descending order of their earliest completion time
        while (jj >= 0 && disj->_lct[i] - disj->_dur_min[i] < disj->_est[j] + disj->_dur_min[j]) {
            // Task 'i' succeeds task 'j'
            const ORUInt tree_idx = idx_map_lct[j];
            const ORInt  dur_j    = disj->_dur_min[j];
            const ORInt  lst_j    = disj->_lct[j] - disj->_dur_min[j];
            // Insert activity in Theta-Lambda tree
            if (isPresent(disj, disj->_idx[j])) {
                // Compulsory or present optional activity
                insertThetaNodeAtIdxLst(theta, tsize, tree_idx, dur_j, lst_j);
                // Update Lambda tree
                insertLambdaNodeAtIdxLst(theta, lambda, tsize, tree_idx, dur_j, lst_j);
            }
            else if (!isAbsent(disj, disj->_idx[j])) {
                // Optional activity
                insertLambdaNodeAtIdxLst(theta, lambda, tsize, tree_idx, dur_j, lst_j);
            }
            jj--;
            j = disj->_task_id_ect[jj];
        }
        // Computing the minimal latest start time of the tasks in the tree
        // excluding the task 'i'
        const ORBool inTheta_i = (isPresent(disj, disj->_idx[i]) && disj->_lct[i] - disj->_dur_min[i] < disj->_est[i] + disj->_dur_min[i]);
        ORInt lst_t = theta[0]._time;
        if (inTheta_i) {
            // Task 'i' is in Theta tree
            insertThetaNodeAtIdxLst(theta, tsize, idx_map_lct[i], 0, MAXINT);
            // Update Lambda tree
            insertLambdaNodeAtIdxLst(theta, lambda, tsize, idx_map_lct[i], 0, MAXINT);
            lst_t = theta[0]._time;
        }
        // Detection of potential overloads
        if (isPresent(disj, disj->_idx[i])) {
            while (lambda[0]._gTime < disj->_est[i] + disj->_dur_min[i]) {
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
                assert(leaf_idx == idx_map_lct[k]);
                // Set to absent
                [disj->_act[disj->_idx[k]].top updateMax: 0];
                // Remove task 'k' from the Lambda tree
                insertLambdaNodeAtIdxLst(theta, lambda, tsize, idx_map_lct[k], 0, MAXINT);
            }
        }
        if (inTheta_i) {
            // Insert activity 'i' in Theta tree
            insertThetaNodeAtIdxLst(theta, tsize, idx_map_lct[i], disj->_dur_min[i], disj->_lct[i] - disj->_dur_min[i]);
            // Update Lambda tree
            insertLambdaNodeAtIdxLst(theta, lambda, tsize, idx_map_lct[i], 0, MAXINT);
        }
        // Checking for a new bound update
        if (lst_t < disj->_lct[i]) {
            // New upper bound found
            disj->_new_lct[i] = lst_t;
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
static void nfnl_filter_est_and_lct_vilim(CPDisjunctive * disj, const ORInt size, const ORUInt * idx_map_est, const ORUInt * idx_map_lct, ThetaTree * theta, const ORUInt tsize, bool * update)
{
    nfnl_filter_est_vilim(disj, size, idx_map_lct, theta, tsize, update);
    nfnl_filter_lct_vilim(disj, size, idx_map_est, theta, tsize, update);
    if (update) updateBounds(disj, size);
}

static void nfnl_filter_est_vilim(CPDisjunctive * disj, const ORInt size, const ORUInt * idx_map_lct, ThetaTree * theta, const ORUInt tsize, bool * update)
{
    // Initialise Theta tree
    initThetaTree(theta, tsize, MAXINT);
    ORInt jj = size - 1;
    ORUInt j = disj->_task_id_ect[jj];
    ORUInt jLastInserted = MAXINT;
    // Outer loop:
    // Iterating over the tasks in descending order of their earliest start time
    for (ORInt ii = size - 1; ii >= 0; ii--) {
        const ORUInt i = disj->_task_id_est[ii];
        // No propagation on tasks with zero duration
        if (disj->_dur_min[i] == 0) continue;
        // Inner loop:
        // Iterating over the tasks in descending order of their earliest completion time
        while (jj >= 0 && disj->_est[i] < disj->_est[j] + disj->_dur_min[j]) {
            if (disj->_dur_min[j] > 0) {
                // Checking for a new bound update of task 'j'
                if (theta[0]._time < disj->_est[j] + disj->_dur_min[j]) {
                    disj->_new_est[j] = disj->_est[jLastInserted] + disj->_dur_min[jLastInserted];
                    *update = true;
                }
                // Inserting task 'j' into the tree
                insertThetaNodeAtIdxLst(theta, tsize, idx_map_lct[j], disj->_dur_min[j], disj->_lct[j] - disj->_dur_min[j]);
                jLastInserted = j;
            }
            j = disj->_task_id_ect[--jj];
        }
        assert(disj->_est[i] < disj->_est[i] + disj->_dur_min[i]);
        assert(jj < (ORInt) (size - 1));
        assert(0 <= jLastInserted && jLastInserted < size);
        // Task 'i' is in the tree
        insertThetaNodeAtIdxLst(theta, tsize, idx_map_lct[i], 0, MAXINT);
        const ORInt lst_t = theta[0]._time;
        insertThetaNodeAtIdxLst(theta, tsize, idx_map_lct[i], disj->_dur_min[i], disj->_lct[i] - disj->_dur_min[i]);
        // Checking for a new bound update
        if (lst_t < disj->_est[i] + disj->_dur_min[i] && disj->_new_est[i] < disj->_est[jLastInserted] + disj->_dur_min[jLastInserted]) {
            // New lower bound found
            disj->_new_est[i] = disj->_est[jLastInserted] + disj->_dur_min[jLastInserted];
            *update = true;
        }
    }
}

static void nfnl_filter_lct_vilim(CPDisjunctive * disj, const ORInt size, const ORUInt * idx_map_est, ThetaTree * theta, const ORUInt tsize, bool * update)
{
    // Inititialise Theta tree
    initThetaTree(theta, tsize, MININT);
    ORInt jj = 0;
    ORUInt j = disj->_task_id_lst[jj];
    ORUInt jLastInserted = MAXINT;
    // Outer loop:
    // Iterating over the tasks in ascending order of their latest completion time
    for (ORInt ii = 0; ii < size; ii++) {
        const ORUInt i = disj->_task_id_lct[ii];
        // No propagation on tasks with zero duration
        if (disj->_dur_min[i] == 0) continue;
        // Inner loop:
        // Iterating over the tasks in ascending order of their latest start time
        while (jj < size && disj->_lct[i] > disj->_lct[j] - disj->_dur_min[j]) {
            if (disj->_dur_min > 0) {
                // Checking for a new bound update of task 'j'
                if (theta[0]._time > disj->_lct[j] - disj->_dur_min[j]) {
                    assert(disj->_new_lct[j] > disj->_lct[jLastInserted] - disj->_dur_min[jLastInserted]);
                    disj->_new_lct[j] = disj->_lct[jLastInserted] - disj->_dur_min[jLastInserted];
                    *update = true;
                }
                // Inserting task 'j' into the tree
                insertThetaNodeAtIdxEct(theta, tsize, idx_map_est[j], disj->_dur_min[j], disj->_est[j] + disj->_dur_min[j]);
                jLastInserted = j;
            }
            j = disj->_task_id_lst[++jj];
        }
        assert(disj->_lct[i] > disj->_lct[i] - disj->_dur_min[i]);
        assert(jj > 0);
        assert(0 <= jLastInserted && jLastInserted < (ORInt) size);
        // Task 'i' is in the tree
        insertThetaNodeAtIdxEct(theta, tsize, idx_map_est[i], 0, MININT);
        const ORInt ect_t = theta[0]._time;
        insertThetaNodeAtIdxEct(theta, tsize, idx_map_est[i], disj->_dur_min[i], disj->_est[i] + disj->_dur_min[i]);
        // Checking for a new bound update
        if (ect_t > disj->_lct[i] - disj->_dur_min[i] && disj->_new_lct[i] > disj->_lct[jLastInserted] - disj->_dur_min[jLastInserted]) {
            // New upper bound found
            disj->_new_lct[i] = disj->_lct[jLastInserted] - disj->_dur_min[jLastInserted];
            *update = true;
        }
    }
}


static void nfnl_filter_est_and_lct_optional_vilim(CPDisjunctive * disj, const ORInt size, const ORUInt * idx_map_est, const ORUInt * idx_map_lct, ThetaTree * theta, LambdaTree * lambda,  const ORUInt tsize, const ORUInt tdepth, bool * update)
{
    nfnl_filter_est_optional_vilim(disj, size, idx_map_lct, theta, lambda, tsize, tdepth, update);
    nfnl_filter_lct_optional_vilim(disj, size, idx_map_est, theta, lambda, tsize, tdepth, update);
    if (update) updateBounds(disj, size);
}

static void nfnl_filter_est_optional_vilim(CPDisjunctive * disj, const ORInt size, const ORUInt * idx_map_lct, ThetaTree * theta, LambdaTree * lambda, const ORUInt tsize, const ORUInt tdepth, bool * update)
{
    // Initialise Theta-Lambda tree
    initThetaTree( theta,  tsize, MAXINT);
    initLambdaTree(lambda, tsize, MAXINT);
    // 'offset' reflects the total of nodes in the trees except the nodes in the deepest level
    const ORUInt offset = (1 << tdepth) - 1;
    ORInt jj = size - 1;
    ORUInt j = disj->_task_id_ect[jj];
    ORUInt jLastInserted = MAXINT;
    ORUInt jLastInserted2 = MAXINT;
    // Outer loop:
    // Iterating over the tasks in descending order of their earliest start time
    for (ORInt ii = size - 1; ii >= 0; ii--) {
        const ORUInt i = disj->_task_id_est[ii];
        // Check for absent activities
        if (isAbsent(disj, disj->_idx[i])) continue;
        // No propagation on tasks with zero duration
        if (disj->_dur_min[i] == 0) continue;
        // Inner loop:
        // Iterating over the tasks in descending order of their earliest completion time
        while (jj >= 0 && disj->_est[i] < disj->_est[j] + disj->_dur_min[j]) {
            if (disj->_dur_min[j] > 0 && !isAbsent(disj, disj->_idx[j])) {
                const ORInt tree_idx = idx_map_lct[j];
                const ORInt dur_j    = disj->_dur_min[j];
                const ORInt lst_j    = disj->_lct[j] - disj->_dur_min[j];
                if (isPresent(disj, disj->_idx[j])) {
                    // Checking for a new bound update of task 'j'
                    if (theta[0]._time < disj->_est[j] + disj->_dur_min[j]) {
                        disj->_new_est[j] = disj->_est[jLastInserted] + disj->_dur_min[jLastInserted];
                        *update = true;
                    }
                    jLastInserted = j;
                    // Insert activity 'j' in Theta tree
                    insertThetaNodeAtIdxLst(theta, tsize, tree_idx, dur_j, lst_j);
                    // Update Lambda tree
                    insertLambdaNodeAtIdxLst(theta, lambda, tsize, tree_idx, 0, MAXINT);
                }
                else {
                    // Insert activity 'j' in Lambda tree
                    insertLambdaNodeAtIdxLst(theta, lambda, tsize, tree_idx, dur_j, lst_j);
                }
                jLastInserted2 = j;
            }
            j = disj->_task_id_ect[--jj];
        }
        // Check whether a present activity is in Theta tree
        if (jLastInserted == MAXINT) continue;
        assert(disj->_est[i] < disj->_est[i] + disj->_dur_min[i]);
        assert(jj < (ORInt) (size - 1));
        assert(0 <= jLastInserted && jLastInserted < size);

        const ORBool inTheta_i = isPresent(disj, disj->_idx[i]);
        ORInt lst_t = theta[0]._time;
        if (inTheta_i) {
            // Activity 'i' is in Theta tree
            insertThetaNodeAtIdxLst(theta, tsize, idx_map_lct[i], 0, MAXINT);
            // Update Lambda tree
            insertLambdaNodeAtIdxLst(theta, lambda, tsize, idx_map_lct[i], 0, MAXINT);
            lst_t = theta[0]._time;
        }
        // Checking for a new bound
        if (lst_t < disj->_est[i] + disj->_dur_min[i] && disj->_new_est[i] < disj->_est[jLastInserted] + disj->_dur_min[jLastInserted]) {
            // New lower bound found
            disj->_new_est[i] = disj->_est[jLastInserted] + disj->_dur_min[jLastInserted];
            *update = true;
        }
        // Detection of possible overloads
        if (jLastInserted2 < MAXINT && isPresent(disj, disj->_idx[i]) && disj->_lct[i] - disj->_dur_min[i] < disj->_est[jLastInserted2] + disj->_dur_min[jLastInserted2]) {
            while (lambda[0]._gTime < disj->_est[i] + disj->_dur_min[i]) {
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
                assert(leaf_idx == idx_map_lct[k]);
                // Set to absent
                [disj->_act[disj->_idx[k]].top updateMax: 0];
                // Remove task 'k' from the Lambda tree
                insertLambdaNodeAtIdxLst(theta, lambda, tsize, idx_map_lct[k], 0, MAXINT);
            }
        }
        if (inTheta_i) {
            // Insert activity 'i' in Theta tree
            insertThetaNodeAtIdxLst(theta, tsize, idx_map_lct[i], disj->_dur_min[i], disj->_lct[i] - disj->_dur_min[i]);
            // Update Lambda tree
            insertLambdaNodeAtIdxLst(theta, lambda, tsize, idx_map_lct[i], 0, MAXINT);
        }
    }
}


static void nfnl_filter_lct_optional_vilim(CPDisjunctive * disj, const ORInt size, const ORUInt * idx_map_est, ThetaTree * theta, LambdaTree * lambda, const ORUInt tsize, const ORUInt tdepth, bool * update)
{
    // Initialise Theta-Lambda tree
    initThetaTree( theta,  tsize, MININT);
    initLambdaTree(lambda, tsize, MININT);
    // 'offset' reflects the total of nodes in the trees except the nodes in the deepest level
    const ORUInt offset = (1 << tdepth) - 1;
    ORInt jj = 0;
    ORUInt j = disj->_task_id_lst[jj];
    ORUInt jLastInserted  = MAXINT;
    ORUInt jLastInserted2 = MAXINT;
    // Outer loop:
    // Iterating over the tasks in ascending order of their latest completion time
    for (ORInt ii = 0; ii < size; ii++) {
        const ORUInt i = disj->_task_id_lct[ii];
        // Check for absent activities
        if (isAbsent(disj, disj->_idx[i])) continue;
        // No propagation on tasks with zero duration
        if (disj->_dur_min[i] == 0) continue;
        // Inner loop:
        // Iterating over the tasks in ascending order of their latest start time
        while (jj < size && disj->_lct[i] > disj->_lct[j] - disj->_dur_min[j]) {
            if (disj->_dur_min > 0 && !isAbsent(disj, disj->_idx[j])) {
                const ORInt tree_idx = idx_map_est[j];
                const ORInt dur_j    = disj->_dur_min[j];
                const ORInt ect_j    = disj->_est[j] + disj->_dur_min[j];
                if (isPresent(disj, disj->_idx[j])) {
                    // Checking for a new bound update of task 'j'
                    if (theta[0]._time > disj->_lct[j] - disj->_dur_min[j]) {
                        assert(disj->_new_lct[j] > disj->_lct[jLastInserted] - disj->_dur_min[jLastInserted]);
                        disj->_new_lct[j] = disj->_lct[jLastInserted] - disj->_dur_min[jLastInserted];
                        *update = true;
                    }
                    // Inserting task 'j' into Theta tree
                    insertThetaNodeAtIdxEct(theta, tsize, tree_idx, dur_j, ect_j);
                    // Update Lambda tree
                    insertLambdaNodeAtIdxEct(theta, lambda, tsize, tree_idx, 0, MININT);
                    jLastInserted = j;
                }
                else {
                    // Insert activity 'j' into Lambda tree
                    insertLambdaNodeAtIdxEct(theta, lambda, tsize, tree_idx, dur_j, ect_j);
                }
                jLastInserted2 = j;
            }
            j = disj->_task_id_lst[++jj];
        }
        // Check whether a present activity is in Theta tree
        if (jLastInserted == MAXINT) continue;
        assert(disj->_lct[i] > disj->_lct[i] - disj->_dur_min[i]);
        assert(jj > 0);
        assert(0 <= jLastInserted && jLastInserted < (ORInt) size);
        // Task 'i' is in Theta-Lambda tree
        const ORBool inTheta_i = isPresent(disj, disj->_idx[i]);
        ORInt ect_t = theta[0]._time;
        if (inTheta_i) {
            // Activity 'i' in Theta tree
            insertThetaNodeAtIdxEct(theta, tsize, idx_map_est[i], 0, MININT);
            // Update Lambda tree
            insertLambdaNodeAtIdxEct(theta, lambda, tsize, idx_map_est[i], 0, MININT);
            ect_t = theta[0]._time;
        }
        // Checking for a new bound update
        if (ect_t > disj->_lct[i] - disj->_dur_min[i] && disj->_new_lct[i] > disj->_lct[jLastInserted] - disj->_dur_min[jLastInserted]) {
            // New upper bound found
            disj->_new_lct[i] = disj->_lct[jLastInserted] - disj->_dur_min[jLastInserted];
            *update = true;
        }
        if (jLastInserted2 < MAXINT && isPresent(disj, disj->_idx[i]) && disj->_lct[jLastInserted2] - disj->_dur_min[jLastInserted2] < disj->_est[i] + disj->_dur_min[i]) {
            // Detection of potential overloads
            while (lambda[0]._gTime > disj->_lct[i] - disj->_dur_min[i]) {
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
                assert(leaf_idx == idx_map_est[k]);
                // Set to absent
                [disj->_act[disj->_idx[k]].top updateMax: 0];
                // Remove from Lambda tree
                insertLambdaNodeAtIdxEct(theta, lambda, tsize, idx_map_est[k], 0, MININT);
            }
        }
        if (inTheta_i) {
            // Insert activity 'i' in Theta tree
            insertThetaNodeAtIdxEct(theta, tsize, idx_map_est[i], disj->_dur_min[i], disj->_est[i] + disj->_dur_min[i]);
            // Updating Lambda tree
            insertLambdaNodeAtIdxEct(theta, lambda, tsize, idx_map_est[i], 0, MININT);
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
static void ef_filter_est_and_lct_vilim(CPDisjunctive * disj, const ORInt size, const ORUInt * idx_map_est, const ORUInt * idx_map_lct, ThetaTree * theta, LambdaTree * lambda, const ORUInt tsize, const ORUInt tdepth, bool * update)
{
    ef_filter_est_vilim(disj, size, idx_map_est, theta, lambda, tsize, tdepth, update);
    ef_filter_lct_vilim(disj, size, idx_map_lct, theta, lambda, tsize, tdepth, update);
    if (update) updateBounds(disj, size);
}

static void ef_filter_est_vilim(CPDisjunctive * disj, const ORInt size, const ORUInt * idx_map_est, ThetaTree * theta, LambdaTree * lambda, const ORUInt tsize, const ORUInt tdepth, bool * update)
{
    // Initialise Theta-Lambda tree with (T, {})
    initThetaLambdaTreeWithEct(disj, size, idx_map_est, theta, lambda, tsize);
    ORInt jj = size - 1;
    ORUInt j = disj->_task_id_lct[jj];
    // 'offset' reflects the total of nodes in the trees except the nodes in the deepest level
    const ORUInt offset = (1 << tdepth) - 1;
    // Outer loop:
    // Iterating over the tasks in descending order of their latest completion time
    while (jj > 0) {
        if (disj->_dur_min[j] == 0) {
            j = disj->_task_id_lct[--jj];
            continue;
        }
        // Remove task 'j' from Theta tree and insert task 'j' into Lambda tree
        insertThetaNodeAtIdxEct(theta, tsize, idx_map_est[j], 0, MININT);
        insertLambdaNodeAtIdxEct(theta, lambda, tsize, idx_map_est[j], disj->_dur_min[j], disj->_est[j] + disj->_dur_min[j]);
        assert(jj - 1 >= 0);
        j = disj->_task_id_lct[--jj];
        // Inner loop:
        // Iterating over the "responsible" tasks
        while (lambda[0]._gTime > disj->_lct[j]) {
            // Retrieve responsible leaf
            const ORUInt leaf_idx = retrieveResponsibleLambdaNodeWithEct(theta, lambda, tsize);
            // The leaf must be a gray one
            assert(theta[leaf_idx]._time == MININT && lambda[leaf_idx]._gTime != MININT);
            // Map leaf index to task ID
            const ORUInt array_idx = (offset <= leaf_idx ? leaf_idx - offset : (leaf_idx + size) - offset);
            const ORUInt i = disj->_task_id_est[array_idx];
            assert(leaf_idx == idx_map_est[i]);
            // Check for a new bound update
            if (theta[0]._time > disj->_new_est[i]) {
                // New lower bound was found
                disj->_new_est[i] = theta[0]._time;
                *update = true;
            }
            // Remove task 'i' from Lambda tree
            insertLambdaNodeAtIdxEct(theta, lambda, tsize, idx_map_est[i], 0, MININT);
        }
    }
}

static void ef_filter_lct_vilim(CPDisjunctive * disj, const ORInt size, const ORUInt * idx_map_lct, ThetaTree * theta, LambdaTree * lambda, const ORUInt tsize, const ORUInt tdepth, bool * update)
{
    // Initialise Theta-Lambda tree with (T, {})
    initThetaLambdaTreeWithLst(disj, size, idx_map_lct, theta, lambda, tsize);
    ORInt jj = 0;
    ORUInt j = disj->_task_id_est[jj];
    // 'offset' reflects the total of nodes in the trees except the nodes in the deepest level
    const ORUInt offset = (1 << tdepth) - 1;
    // Outer loop:
    // Iterating over the tasks in ascending order of their earliest start time
    while (jj < size - 1) {
        if (disj->_dur_min[j] == 0) {
            j = disj->_task_id_est[++jj];
            continue;
        }
        // Remove task 'j' from Theta tree and insert task 'j' into Lambda tree
        insertThetaNodeAtIdxLst(theta, tsize, idx_map_lct[j], 0, MAXINT);
        insertLambdaNodeAtIdxLst(theta, lambda, tsize, idx_map_lct[j], disj->_dur_min[j], disj->_lct[j] - disj->_dur_min[j]);
        
        j = disj->_task_id_est[++jj];
        // Inner loop:
        // Iterating over the "responsible" tasks
        while (lambda[0]._gTime < disj->_est[j]) {
            // Retrieve responsible leaf
            const ORInt leaf_idx = retrieveResponsibleLambdaNodeWithLst(theta, lambda, tsize);
            // The leaf must be a gray one
            assert(theta[leaf_idx]._time == MAXINT && lambda[leaf_idx]._gTime != MAXINT);
            // Map leaf index to task ID
            const ORUInt array_idx = (offset <= leaf_idx ? leaf_idx - offset : (leaf_idx + size) - offset);
            const ORUInt i = disj->_task_id_lct[array_idx];
            assert(leaf_idx == idx_map_lct[i]);
            // Check for a new bound update
            if (theta[0]._time < disj->_new_lct[i]) {
                // New upper bound was found
                disj->_new_lct[i] = theta[0]._time;
                *update = true;
            }
            // Remove task 'i' from the Lambda tree
            insertLambdaNodeAtIdxLst(theta, lambda, tsize, idx_map_lct[i], 0, MAXINT);
        }
    }
}


// Edge-Finding algorithm
//  Time: O(n^2)
//  Space: O(n)
//
//  NOTE: Tasks with a minimal duration of zero will be ignored.
//
static void ef_filter_est_and_lct_optional(CPDisjunctive * disj, const ORInt size, bool * update)
{
    ef_filter_est_optional(disj, size, update);
    ef_filter_lct_optional(disj, size, update);
    if (update) updateBounds(disj, size);
}

static void ef_filter_est_optional(CPDisjunctive * disj, const ORInt size, bool * update)
{
    ORInt length = 0;
    // Outer loop:
    // Iterating over activities in ascending order of their latest completion time
    for (ORInt ii = 0; ii < size; ii++) {
        const ORInt i = disj->_task_id_lct[ii];
        // Skip activities with no duration or non-present activities
        if (disj->_dur_min[i] == 0 || !isPresent(disj, disj->_idx[i])) continue;
        const ORInt end = disj->_lct[i];
        // Determine the length of all present activities with latest completion
        // time less than or equal to 'end'
        length += disj->_dur_min[i];
        // Initialisation for inner loop
        ORInt length_end  = length;
        ORInt ect_omega   = MININT;
        ORInt begin_omega = MININT;
        
        // Inner loop:
        // Iterating over activities in ascending order of their earliest start time
        for (ORInt jj = 0; jj < size; jj++) {
            const ORInt j = disj->_task_id_est[jj];
            // Skip activities with no duration or absent activities
            if (disj->_dur_min[j] == 0 || isAbsent(disj, disj->_idx[j])) continue;
            
            if (disj->_lct[j] <= end && isPresent(disj, disj->_idx[j])) {
                // Activity 'j' is in the activity interval
                const ORInt ect_i = disj->_est[j] + length_end;
                if (ect_i > ect_omega) {
                    ect_omega   = ect_i;
                    begin_omega = disj->_est[j];
                }
                length_end -= disj->_dur_min[j];
            }
            else {
                // Activity 'j' is not in the activity interval
                // Bounds check for time interval [est(j), end)
                if (disj->_est[j] + disj->_dur_min[j] + length_end > end && disj->_est[j] + length_end > disj->_new_est[j]) {
                    // New lower bound was found
                    disj->_new_est[j] = disj->_est[j] + length_end;
                    *update = true;
                }
                // Bounds check for time interval [begin_omega, end)
                if (ect_omega + disj->_dur_min[j] > end && ect_omega > disj->_new_est[j]) {
                    // New lower bound was found
                    disj->_new_est[j] = ect_omega;
                    *update = true;
                }
            }
        }
    }
}

static void ef_filter_lct_optional(CPDisjunctive * disj, const ORInt size, bool * update)
{
    ORInt length = 0;
    // Outer loop:
    // Iterating over activities in descending order of their earliest start time
    for (ORInt ii = 0; ii < size; ii++) {
        const ORInt i = disj->_task_id_est[ii];
        // Skip activities with no duration or non-present activities
        if (disj->_dur_min[i] == 0 || !isPresent(disj, disj->_idx[i])) continue;
        const ORInt begin = disj->_est[i];
        // Determine the length of all present activities with an earliest start
        // time greater than or equal to 'end'
        length += disj->_dur_min[i];
        // Initialisation for inner loop
        ORInt length_begin = length;
        ORInt lst_omega    = MAXINT;
        ORInt end_omega    = MAXINT;
        
        // Inner loop:
        // Iterating over activities in descending order of their latest completion time
        for (ORInt jj = 0; jj < size; jj++) {
            const ORInt j = disj->_task_id_lct[jj];
            // Skip activities with no duration or absent activities
            if (disj->_dur_min[j] == 0 || isAbsent(disj, disj->_idx[j])) continue;
            
            if (begin <= disj->_est[j] && isPresent(disj, disj->_idx[j])) {
                // Activity 'j' is in time interval [begin, lct(j))
                const ORInt lst_j = disj->_lct[j] - length_begin;
                if (lst_j < lst_omega) {
                    lst_omega = lst_j;
                    end_omega = disj->_lct[j];
                }
                length_begin -= disj->_dur_min[j];
            }
            else {
                // Activity is not in the activity interval
                // Bounds check for time interval [begin, lct(j))
                if (disj->_lct[j] - disj->_dur_min[j] - length_begin < begin && disj->_lct[j] - length_begin < disj->_new_lct[j]) {
                    // New upper bound was found
                    disj->_new_lct[j] = disj->_lct[j] - length_begin;
                    *update = true;
                }
                // Bounds check for time interval [begin, end_omega)
                if (lst_omega - disj->_dur_min[j] < begin && lst_omega < disj->_new_lct[j]) {
                    // New upper bound was found
                    disj->_new_lct[j] = lst_omega;
                    *update = true;
                }
            }
        }
    }
}

/*******************************************************************************
 Computation of the local and global slack
 ******************************************************************************/

static inline ORBool isUnfixed(CPDisjunctive * disj, const ORInt i)
{
    return (disj->_lct[i] - disj->_est[i] - disj->_dur_min[i] > 0);
}

    // The global slack measures the tightness of the resource for unfixed
    // tasks. It only considers the time interval in that those tasks must be
    // scheduled.
static ORInt getGlobalSlack(CPDisjunctive * disj, const ORInt size)
{
    ORInt est_min = MAXINT;
    ORInt lct_max = MININT;
    ORInt len_min = 0;
    for (ORInt i = 0; i < size; i++) {
        // XXX For the moment being only unfixed present activities are considered
        const ORInt t = disj->_idx[i];
        if (disj->_act != NULL && disj->_act[t].top.min == 0) continue;
        if (isUnfixed(disj, i)) {
            est_min = min(est_min, disj->_est[i]);
            lct_max = max(lct_max, disj->_lct[i]);
        }
    }
    for (ORInt i = 0; i < size; i++) {
        // XXX For the moment being only unfixed present activities are considered
        const ORInt t = disj->_idx[i];
        if (disj->_act != NULL && disj->_act[t].top.min == 0) continue;
        if (est_min <= disj->_est[i] && disj->_lct[i] <= lct_max) {
            len_min += disj->_dur_min[i];
        }
    }
    
    return (lct_max - est_min - len_min);
}

static ORInt getLocalSlack(CPDisjunctive * disj)
{
    cleanUp(disj);
    
    // XXX Temporary assignment (it should be '_cIdx' or '_uIdx')
    const ORInt size = disj->_cIdx._val;
    
    // Allocation of memory
    disj->_est           = alloca(size * sizeof(ORInt ));
    disj->_lct           = alloca(size * sizeof(ORInt ));
    disj->_dur_min       = alloca(size * sizeof(ORInt ));
    disj->_task_id_est   = alloca(size * sizeof(ORInt ));
    disj->_task_id_lct   = alloca(size * sizeof(ORInt ));

    // Check whether memory allocation was successful
    if (disj->_est == NULL || disj->_lct == NULL || disj->_dur_min == NULL ||
        disj->_task_id_est == NULL || disj->_task_id_lct == NULL) {
        @throw [[ORExecutionError alloc] initORExecutionError: "CPDisjunctive: Out of memory!"];
    }
    
    // Initialisation of the arrays
    for (ORInt tt = 0; tt < size; tt++) {
        const ORInt t = disj->_idx[tt];
        if (disj->_act == NULL) {
            disj->_est    [tt] = disj->_start0[t].min;
            disj->_lct    [tt] = disj->_start0[t].max + disj->_dur0[t].max;
            disj->_dur_min[tt] = disj->_dur0  [t].min;
        } else {
            // XXX Only consider present activities for the moment
            assert(!disj->_act[t].isOptional || disj->_act[t].top.min == 1);
            disj->_est    [tt] = disj->_act[t].startLB.min;
            disj->_lct    [tt] = disj->_act[t].startUB.max + disj->_act[t].duration.min;
            disj->_dur_min[tt] = disj->_act[t].duration.min;
        }
        disj->_task_id_est[tt] = tt;
        disj->_task_id_lct[tt] = tt;
    }

    // Sorting of the tasks
    // NOTE: qsort_r the 3rd argument of qsort_r is at the last position in glibc (GNU/Linux)
    // instead of the second last
    qsort_r(disj->_task_id_est, size, sizeof(ORInt), disj, (int(*)(void*, const void*, const void*)) &sortDisjEstAsc);
    qsort_r(disj->_task_id_lct, size, sizeof(ORInt), disj, (int(*)(void*, const void*, const void*)) &sortDisjLctAsc);

    ORInt localSlack = MAXINT;
    ORInt len_min = 0;
    ORInt jjPrev = 0;
    ORInt jjLast = size - 1;
    
    for (ORInt jj = size - 1; jj >= 0; jj--) {
        const ORInt j = disj->_task_id_lct[jj];
        if (isUnfixed(disj, j)) {
            jjLast = jj;
            break;
        }
    }
    
    for (ORInt ii = 0; ii < size; ii++) {
        const ORInt i = disj->_task_id_est[ii];
        if (isUnfixed(disj, i)) {
            const ORInt est_min = disj->_est[i];
            ORBool first = true;
            len_min = 0;
            for (ORInt jj = jjPrev; jj <= jjLast; jj++) {
                const ORInt j = disj->_task_id_lct[jj];
                if (est_min < disj->_lct[j]) {
                    if (first) {
                        jjPrev = jj;
                        first = false;
                    }
                    if (isUnfixed(disj, j)) {
                        if (est_min <= disj->_est[j]) len_min += disj->_dur_min[j];
                        localSlack = min(localSlack, disj->_lct[j] - est_min - len_min);
                    }
                    else {
                        len_min += disj->_dur_min[j];
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
static Profile disjGetEarliestContentionProfile(CPDisjunctive * disj)
{
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
        @throw [[ORExecutionError alloc] initORExecutionError: "CPDisjunctive: Out of memory!"];
    }
    
    ORInt ect[size];
    ORInt h[  size];
    
    // Initialisation of the arrays
    for (ORInt tt = 0; tt < size; tt++) {
        const ORInt t = disj->_idx[tt];
        if (disj->_act == NULL) {
            disj->_est    [tt] = disj->_start0[t].min;
            disj->_dur_min[tt] = disj->_dur0  [t].min;
            ect[tt] = disj->_start0[t].min + disj->_dur0[t].min;
        } else {
            // XXX Only consider present activities for the moment
            assert(!disj->_act[t].isOptional || disj->_act[t].top.min == 1);
            disj->_est    [tt] = disj->_act[t].startLB.min;
            disj->_dur_min[tt] = disj->_act[t].duration.min;
            ect[tt] = disj->_act[t].startLB.min + disj->_act[t].duration.min;
        }
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

static inline
void swapORInt(ORInt * arr, const ORInt i, const ORInt j)
{
    if (i != j) {
        const ORInt temp = arr[i];
        arr[i] = arr[j];
        arr[j] = temp;
    }
}

static void updateIndices(CPDisjunctive * disj)
{
    if (disj->_cIdx._val < disj->_uIdx._val) {
        ORInt cIdx = disj->_cIdx._val;
        ORInt uIdx = disj->_uIdx._val;
        for (ORInt i = cIdx; i < uIdx; i++) {
            if (isPresent(disj, disj->_idx[i])) {
                // Swap elements in 'i' and 'cIdx'
                swapORInt(disj->_idx, i, cIdx++);
            } else if (isAbsent(disj, disj->_idx[i])) {
                // Swap elements in 'i' and 'uIdx'
                swapORInt(disj->_idx, i, --uIdx);
                i--;
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

static void doPropagation(CPDisjunctive * disj) {
    bool update;
    
    cleanUp(disj);
    
    // Updating indices
    updateIndices(disj);
    
    const ORInt size  = disj->_uIdx._val;
    const ORInt cSize = disj->_cIdx._val;
    
    if (size <= 1) {
//        assignTRInt(&(disj->_active), NO, (disj->_trail));
        return ;
    }
    
    // Allocation of memory
    disj->_est           = alloca(size * sizeof(ORInt ));
    disj->_lct           = alloca(size * sizeof(ORInt ));
    disj->_dur_min       = alloca(size * sizeof(ORInt ));
    disj->_new_est       = alloca(size * sizeof(ORInt ));
    disj->_new_lct       = alloca(size * sizeof(ORInt ));
    disj->_task_id_est   = alloca(size * sizeof(ORInt ));
    disj->_task_id_ect   = alloca(size * sizeof(ORInt ));
    disj->_task_id_lst   = alloca(size * sizeof(ORInt ));
    disj->_task_id_lct   = alloca(size * sizeof(ORInt ));
    ORUInt * idx_map_est = alloca(size * sizeof(ORUInt));
    ORUInt * idx_map_lct = alloca(size * sizeof(ORUInt));
    
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
        @throw [[ORExecutionError alloc] initORExecutionError: "CPDisjunctive: Out of memory!"];
    }
    
    // Initialisation of the arrays
    for (ORInt tt = 0; tt < size; tt++) {
        const ORInt t = disj->_idx[tt];
        if (disj->_act == NULL) {
            disj->_est    [tt] = disj->_start0[t].min;
            disj->_lct    [tt] = disj->_start0[t].max + disj->_dur0[t].max;
            disj->_dur_min[tt] = disj->_dur0  [t].min;
        } else {
            disj->_est    [tt] = disj->_act[t].startLB.min;
            disj->_lct    [tt] = disj->_act[t].startUB.max + disj->_act[t].duration.min;
            disj->_dur_min[tt] = disj->_act[t].duration.min;
        }
        disj->_new_est[tt] = disj->_est[tt];
        disj->_new_lct[tt] = disj->_lct[tt];
        disj->_task_id_est[tt] = tt;
        disj->_task_id_ect[tt] = tt;
        disj->_task_id_lst[tt] = tt;
        disj->_task_id_lct[tt] = tt;
        idx_map_est[tt] = tt;
        idx_map_lct[tt] = tt;
    }
    
    // Propagation loop
    do {
        update = false;
        // Sorting tasks regarding their earliest start and latest completion times
        qsort_r(disj->_task_id_est, size, sizeof(ORInt), disj, (int(*)(void*, const void*, const void*)) &sortDisjEstAsc);
        qsort_r(disj->_task_id_lct, size, sizeof(ORInt), disj, (int(*)(void*, const void*, const void*)) &sortDisjLctAsc);
        // Initialisation of the positions of the tasks
        initIndexMap(disj->_task_id_est, idx_map_est, size, tsize, tdepth);
        
        // Consistency check
        if (cSize >= size) {
            ef_overload_check_vilim(disj, size, idx_map_est, theta, tsize);
        }
        else {
            ef_overload_check_optional_vilim(disj, size, idx_map_est, theta, lambda, tsize, tdepth);
        }

        // Further initialisations needed for the filtering algorithm
        initIndexMap(disj->_task_id_lct, idx_map_lct, size, tsize, tdepth);
        qsort_r(disj->_task_id_ect, size, sizeof(ORInt), disj, (int(*)(void*, const void*, const void*)) &sortDisjEctAsc);
        qsort_r(disj->_task_id_lst, size, sizeof(ORInt), disj, (int(*)(void*, const void*, const void*)) &sortDisjLstAsc);
        
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
                ef_filter_est_and_lct_vilim(disj, size, idx_map_est, idx_map_lct, theta, lambda, tsize, tdepth, & update);
            }
            else {
                // NOTE: This algorithms has a time-complexity of O(n^2)
                ef_filter_lct_optional(disj, size, & update);
            }
        }
    } while (disj->_idempotent && update);
    
    // Updating the global slack
    const ORInt globalSlack = getGlobalSlack(disj, size);
    assignTRInt(&(disj->_global_slack), globalSlack, disj->_trail);
}

@end

