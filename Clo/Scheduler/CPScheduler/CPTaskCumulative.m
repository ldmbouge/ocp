/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2013-14 NICTA, Andreas Schutt and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "CPTaskCumulative.h"
#import <objcp/CPIntVarI.h>
#import <CPUKernel/CPEngineI.h>
#import "CPTask.h"


// NOTE that the TTEF filtering is not adjusted for optional tasks yet, but the
// TT filtering.

// Randomly set
#define MAXNBTASK ((MAXINT)/4)

    // Whether skipping of dominated time intervals should be activated wrt.
    // TTEF propagation rule
    // 0 - deactivated ; 1 - activated
#define TTEFDOMRULESKIP 0
    // Whether the left or right shift of an activity should be considered
    // 0 - no ; 1 - yes
#define TTEFLEFTRIGHTSHIFT 0
    // Whether the opportunitic TTEEF rule that considers the minimal available
    // energy in a time interval should be executed
#define TTEEFABSOLUTEPROP 0
    // Whether the opportunitic TTEEF rule that considers the least densed time
    // interval regarding the available energy should be executed
#define TTEEFDENSITYPROP 0


typedef struct {
    ORInt _begin;
    ORInt _end;
    ORInt _level;
} ProfilePeak;


@implementation CPTaskCumulative {
    // Attributs of tasks
    ORInt * _est;       // Earliest starting time
    ORInt * _ect;       // Earliest completion time
    ORInt * _lst;       // Latest starting time
    ORInt * _lct;       // Latest completion time
    ORInt * _dur_min;   // Minimal duration
    ORInt * _usage_min; // Minimal usage

    ORInt        _size;     // Number of considered tasks
    ORInt*       _idx;      // Indices of activities
    TRInt        _cIdx;     // Size of present activities
    TRInt        _uIdx;     // Size of present and non-present activities

    // Array of identifiers of tasks whereas fixed (bound) tasks sitting at the
    // right end
    ORInt*       _fixed;
    TRInt        _first_fixed;  // Left-most index of a fixed task
    
    // Storage for the resource profile
    ProfilePeak* _profile;
    ORLong       _psize;    // Number of resource peaks
    
    // Filtering options
    ORBool _idempotent;
    ORBool _tt_filt;        // Time-tabling bounds propagation
    ORBool _ttef_check;     // Time-tabling-edge-finding consistency check
    ORBool _ttef_filt;      // Time-tabling-edge-finding bounds propagation
    
    // Counters
    ORULong _nb_tt_incons;      // Number of time-tabling inconsistencies
    ORULong _nb_tt_props;       // Number of time-tabling propagations
    ORULong _nb_ttef_incons;    // Number of time-tabling-edge-finding inconsistencies
    ORULong _nb_ttef_props;     // Number of time-tabling-edge-finding propagations
}

-(id) initCPTaskCumulative: (id<CPTaskVarArray>)tasks with:(id<CPIntVarArray>)usages and:(id<CPIntVar>)capacity
{
    // Checking whether the number of activities is within the limit
    if (tasks.count > (NSUInteger) MAXNBTASK) {
        @throw [[ORExecutionError alloc] initORExecutionError: "CPTaskCumulative: Number of elements exceeds beyond the limit!"];
    }

    // Checking whether the size and indices of the arrays tasks and usages are consistent
    if (tasks.count != usages.count || tasks.low != usages.low || tasks.up != usages.up) {
        @throw [[ORExecutionError alloc] initORExecutionError: "CPTaskCumulative: the arrays 'tasks' and 'usages' must have the same size and indices!"];
    }
    
    // Checking wether the domain of the capacity contains non-negative values
    if (capacity.max < 0) {
        @throw [[ORExecutionError alloc] initORExecutionError: "CPTaskCumulative: the domain of the variable 'capacity' must contain at least one non-negative value!"];
    }
    
    // Checking whether the domain ot the usage variables contain non-negative values
    for (ORInt i = usages.low; i <= usages.up; i++) {
        if (usages[i].max < 0) {
            @throw [[ORExecutionError alloc] initORExecutionError: "CPTaskCumulative: the domain of the 'usages' variables must contain at least one non-negative value!"];
        }
    }
    
    id<CPTaskVar> task0 = tasks[tasks.low];
    self = [super initCPCoreConstraint: [task0 engine]];
    
    _priority = LOWEST_PRIO;
    _tasks    = tasks;
    _usages   = usages;
    _capacity = capacity;

    // Setup for propagation
    _idempotent = false;
    _tt_filt    = true;
    _ttef_check = false;
    _ttef_filt  = false;

    // Initialisation of the counters
    _nb_tt_incons   = 0;
    _nb_tt_props    = 0;
    _nb_ttef_incons = 0;
    _nb_ttef_props  = 0;

    // Initialisation of other data structures
    _fixed   = NULL;
    _idx     = NULL;
    _profile = NULL;
    
    return self;
}

-(void) dealloc
{
    printf("%%%% #TT fails: %lld\n",   _nb_tt_incons  );
    printf("%%%% #TT props: %lld\n",   _nb_tt_props   );
    printf("%%%% #TTEF fails: %lld\n", _nb_ttef_incons);
    printf("%%%% #TTEF props: %lld\n", _nb_ttef_props );

    if (_fixed   != NULL) free(_fixed  );
    if (_idx     != NULL) free(_idx    );
    if (_profile != NULL) free(_profile);
    
    [super dealloc];
}

-(ORUInt) nbUVars {
    ORUInt nb = 0;
    for (ORInt ii = 0; ii <= _size; ii++) {
        if (!_tasks[_idx[ii]].bound) nb++;
    }
    return nb;
}

-(ORStatus) post
{
//    printf("CPTaskCumulative: post\n");
    assert(_tasks.count == _usages.count);
    assert(_tasks.low == _usages.low && _tasks.up == _usages.up);

    // Identifying of unnecessary tasks
    _size = 0;
    bool consider[_tasks.count];
 
    for (ORInt t = _tasks.low, i = 0; t <= _tasks.up; t++, i++) {
        if (_tasks[t].maxDuration <= 0 || _tasks[t].isAbsent || _usages[t].max <= 0) {
            consider[i] = false;
        }
        else {
            consider[i] = true;
            _size++;
        }
    }

    if (_size <= 0) {
        // No necessary tasks => constraint satisfied
        return ORSuccess;
    }
    
    _cIdx        = makeTRInt(_trail, 0    );
    _uIdx        = makeTRInt(_trail, _size);
    _first_fixed = makeTRInt(_trail, _size);
    
    // Allocating memory
    _fixed   = malloc(    _size * sizeof(ORInt      ));
    _idx     = malloc(    _size * sizeof(ORInt      ));
    _profile = malloc(2 * _size * sizeof(ProfilePeak));
    
    // Checking whether memory allocation was successful
    if (_fixed == NULL || _idx == NULL  || _profile == NULL) {

        @throw [[ORExecutionError alloc] initORExecutionError: "Cumulative: Out of memory!"];
    }
    
    // Copying elements to the new created C arrays
    ORInt idx = 0;

    for (ORInt t = _tasks.low, i = 0; t <= _tasks.up; t++, i++) {
        if (consider[i]) {
            _idx  [idx] = t;
            _fixed[idx] = t;
            idx++;
        }
    }
    
    assert(idx == _size);
    
    // Remove negative values from the domains
    if (_capacity.min < 0) {
        [_capacity updateMin:0];
    }
    for (ORInt ii = 0; ii < _size; ii++) {
        const ORInt i = _idx[ii];
        if (_usages[i].min < 0 && _tasks[i].isPresent) {
            [_usages[i] updateMin:0];
        }
    }
    
    // Call for initial propagation
    [self propagate];

    // Subscription of variables to the constraint
    // XXX Currently, no propagation is performed on non-present tasks
    for (ORInt ii = 0; ii < _size; ii++) {
        const ORInt i = _idx[ii];
        if (_tasks[i].isPresent) {
            if (!_tasks[i].bound)
                [_tasks[i] whenChangePropagate:self];
            if (!_usages[i].bound)
                [_usages[i] whenChangeMinPropagate:self];
        }
        else {
            assert(_tasks[i].isOptional && !_tasks[i].isAbsent);
            [_tasks[i] whenPresentPropagate:self];
        }
    }
    if (!_capacity.bound)
        [_capacity whenChangeMaxPropagate:self];

    // Return of the state
    return ORSuspend;
}

-(void) propagate
{
    doPropagation(self);
    
//    // XXX Just for testing the partial ordering stuff
//    // Remove it once completed
//    ORBool allBounded = true;
//    for (ORInt tt = 0; tt < _size; tt++) {
//        const ORInt t = _idx[tt];
//        if (!isBounded(self, t)) {
//            allBounded = false;
//            break;
//        }
//    }
//    if (allBounded) {
//        ORInt posize = 0;
//        CPTaskVarPrec * prec = [self getPartialOrder: &posize];
//        printf("posize %d;\n", posize);
//        free(prec);
//    }
}

-(CPTaskVarPrec *) getPartialOrder: (ORInt *) posize
{
    return cumuGetPartialOrder(self, posize);
}

static void propagationLoopPreamble(CPTaskCumulative* cumu, const ORInt cSize, ORInt* i_max_usage)
{
    // Building the resource profile
    *i_max_usage = tt_build_profile(cumu, cSize);
//    //    printf("i_max_usage: %d; level: %d\n", *i_max_usage, cumu->_profile[*i_max_usage]._level);
//    if (*i_max_usage > -1) {
//        
//        // Swapping newly fixed tasks to the end of the array
//        ORInt new = cumu->_first_fixed._val;
//        for (ORInt ii = new - 1; ii >= 0; ii--) {
//            ORInt i = cumu->_fixed[ii];
//            if (isBounded(cumu, i)) {
//                new--;
//                assert(new >= 0);
//                cumu->_fixed[ii] = cumu->_fixed[new];
//                cumu->_fixed[new] = i;
//            }
//        }
//        // Trailing of the 'first_fixed' index
//        assignTRInt(&(cumu->_first_fixed), new, cumu->_trail);
//    }
}

-(NSSet*)allVars
{
    NSMutableSet* rv = [[NSMutableSet alloc] initWithCapacity:2 * _size + 1];
    for(ORInt ii = 0; ii < _size; ii++) {
        const ORInt i = _idx[ii];
        [rv addObject: _tasks [i] ];
        [rv addObject: _usages[i] ];
    }
    [rv addObject: _capacity];
    [rv autorelease];
    return rv;
}

/*******************************************************************************
 * Short cuts for tasks
 ******************************************************************************/

static inline ORInt est(CPTaskCumulative* cumu, ORInt i);
static inline ORInt lst(CPTaskCumulative* cumu, ORInt i);
static inline ORInt ect(CPTaskCumulative* cumu, ORInt i);
static inline ORInt lct(CPTaskCumulative* cumu, ORInt i);

static inline ORInt est(CPTaskCumulative* cumu, ORInt i)
{
    assert(cumu->_tasks.low <= i && i <= cumu->_tasks.up);
    return cumu->_est[i];
}

static inline ORInt lst(CPTaskCumulative* cumu, ORInt i)
{
    assert(cumu->_tasks.low <= i && i <= cumu->_tasks.up);
    return cumu->_lst[i];
}

static inline ORInt ect(CPTaskCumulative* cumu, ORInt i)
{
    assert(cumu->_tasks.low <= i && i <= cumu->_tasks.up);
    return cumu->_ect[i];
}

static inline ORInt lct(CPTaskCumulative* cumu, ORInt i)
{
    assert(cumu->_tasks.low <= i && i <= cumu->_tasks.up);
    return cumu->_lct[i];
}

static inline ORInt dur_min(CPTaskCumulative* cumu, ORInt i)
{
    assert(cumu->_tasks.low <= i && i <= cumu->_tasks.up);
    return cumu->_dur_min[i];
}

static inline ORInt dur_max(CPTaskCumulative* cumu, ORInt i)
{
    assert(cumu->_tasks.low <= i && i <= cumu->_tasks.up);
    return cumu->_tasks[i].maxDuration;
}

static inline ORInt usage_min(CPTaskCumulative* cumu, ORInt i)
{
    assert(cumu->_tasks.low <= i && i <= cumu->_tasks.up);
    return cumu->_usage_min[i];
}

static inline ORInt usage_max(CPTaskCumulative* cumu, ORInt i)
{
    assert(cumu->_tasks.low <= i && i <= cumu->_tasks.up);
    return cumu->_usages[i].max;
}

static inline ORInt area_min(CPTaskCumulative* cumu, ORInt i)
{
    assert(cumu->_tasks.low <= i && i <= cumu->_tasks.up);
    return (usage_min(cumu, i) * dur_min(cumu, i));
}

static inline ORInt free_energy(CPTaskCumulative* cumu, ORInt i)
{
    assert(cumu->_tasks.low <= i && i <= cumu->_tasks.up);
    return  area_min(cumu, i) - usage_min(cumu, i) * max(0, ect(cumu, i) - lst(cumu, i));
}

static inline ORInt cap_min(CPTaskCumulative* cumu)
{
    return cumu->_capacity.min;
}

static inline ORInt cap_max(CPTaskCumulative* cumu)
{
    return cumu->_capacity.max;
}

static inline ORBool isCapBounded(CPTaskCumulative* cumu)
{
    return cumu->_capacity.bound;
}

static inline ORBool isBounded(CPTaskCumulative* cumu, ORInt i)
{
    assert(cumu->_tasks.low <= i && i <= cumu->_tasks.up);
    return cumu->_tasks[i].bound;
}


static inline ORBool isRelevant(CPTaskCumulative * cumu, const ORInt i)
{
    return (cumu->_tasks[i].isPresent && cumu->_usages[i].min > 0 && cumu->_tasks[i].minDuration > 0);
}

static inline ORBool isIrrelevant(CPTaskCumulative * cumu, const ORInt i)
{
    return (cumu->_tasks[i].isAbsent || cumu->_usages[i].max <= 0 || cumu->_tasks[i].maxDuration <= 0);
}


/****************************
 * Time-tabling propagation *
 *
 * TODO:
 *  - Propagation on durations, usages, and area
 ****************************/

typedef struct {
    ORInt _time;
    ORInt _change;
} ProfileChange;

static int compareProfileChange(const ProfileChange* r1, const ProfileChange* r2)
{
    if (r1->_time == r2->_time) return r1->_change - r2->_change;
    return r1->_time - r2->_time;
}

static int sortEstAsc(CPTaskCumulative* cumu, const ORInt* r1, const ORInt* r2)
{
    return est(cumu, *r1) - est(cumu, *r2);
}

static int sortEctAsc(CPTaskCumulative* cumu, const ORInt* r1, const ORInt* r2)
{
    return ect(cumu, *r1) - ect(cumu, *r2);
}

static int sortLctAsc(CPTaskCumulative* cumu, const ORInt* r1, const ORInt* r2)
{
    return lct(cumu, *r1) - lct(cumu, *r2);
}

static ORInt tt_build_profile(CPTaskCumulative* cumu, const ORInt cSize)
{
    ORLong k = 0;   // Number of profile change points
    
    // Memory allocation
    ProfileChange* toSort = (ProfileChange*) alloca(2 * cSize * sizeof(ProfileChange));
    if (toSort == NULL) {
        @throw [[ORExecutionError alloc] initORExecutionError: "Cumulative: Out of memory!"];
    }
    
    for (ORInt ii = 0; ii < cSize; ii++) {
        const ORInt i = cumu->_idx[ii];
        assert(isRelevant(cumu, i));
        if (lst(cumu, i) < ect(cumu, i)) {
            // Tasks creates a compulsory part
            toSort[k++] = (ProfileChange){lst(cumu, i),  usage_min(cumu, i)};
            toSort[k++] = (ProfileChange){ect(cumu, i), -usage_min(cumu, i)};
        }
    }
    
//    // Adding the profile change points from fixed tasks
//    for (ORInt ii = cumu->_first_fixed._val; ii < cumu->_size; ii++) {
//        ORInt i = cumu->_fixed[ii];
//        toSort[k++] = (ProfileChange){lst(cumu, i),  usage_min(cumu, i)};
//        toSort[k++] = (ProfileChange){ect(cumu, i), -usage_min(cumu, i)};
//    }
//    
//    // Adding the profile change points from unfixed tasks with compulsory parts
//    // that require at least one resource unit
//    for (ORInt ii = 0; ii < cumu->_first_fixed._val; ii++) {
//        ORInt i = cumu->_fixed[ii];
//        if (usage_min(cumu, i) > 0 && dur_min(cumu, i) > 0 && lst(cumu, i) < ect(cumu, i)) {
//            // Tasks creates a compulsory part
//            toSort[k++] = (ProfileChange){lst(cumu, i),  usage_min(cumu, i)};
//            toSort[k++] = (ProfileChange){ect(cumu, i), -usage_min(cumu, i)};
//        }
//    }
    
    if (k == 0) return -1;
//    // XXX For debugging purpose
//    printf("Before sort:\n");
//    for (ORInt i = 0; i < k;i++) {
//        printf("%d: time %d; change %d\n", i, toSort[i]._time, toSort[i]._change);
//    }
    // Sorting the profile change points in ascending order with respect to the time unit
    // and the change as tie breaker
    qsort(toSort, k, sizeof(ProfileChange), (int(*)(const void*, const void*)) &compareProfileChange);
//    // XXX For debugging purpose
//    printf("After sort:\n");
//    for (ORInt i = 0; i < k;i++) {
//        printf("%d: time %d; change %d\n", i, toSort[i]._time, toSort[i]._change);
//    }
    // Building the resource profile
    assert(toSort[0]._change > 0);
    ORInt begin = toSort[0]._time;
    ORInt psize = 0;
    ORInt level = toSort[0]._change;
    ORInt max_peak = 0;
    for (ORInt i = 1; i < k; i++) {
        if (toSort[i]._time > begin) {
            if (level > 0) {
                // new profile peak (begin, _time, level)
//                if (psize > 0 && cumu->_profile[psize - 1]._level == level && cumu->_profile[psize - 1]._end == begin) {
//                    cumu->_profile[psize - 1]._end = toSort[i]._time;
//                } else {
                    cumu->_profile[psize]._begin = begin;
                    cumu->_profile[psize]._end   = toSort[i]._time;
                    cumu->_profile[psize]._level = level;
                    if (cumu->_profile[max_peak]._level < level) {
                        max_peak = psize;
                        if (level > cap_max(cumu)) {
                            cumu->_nb_tt_incons++;
                            //NSLog(@"Cumulative: propagate/0: TT Fail\n");
                            failNow();
                        }
                    }
                    psize++;
//                }
            }
            begin = toSort[i]._time;
        }
        level += toSort[i]._change;
    }
    assert(level == 0);
    cumu->_psize = psize;
//    for (ORInt i = 0; i < psize; i++) {
//        printf("%d: time window [%d, %d); level: %d\n", i, cumu->_profile[i]._begin,
//               cumu->_profile[i]._end, cumu->_profile[i]._level);
//    }
    return max_peak;
}

static inline void tt_filter_cap(CPTaskCumulative* cumu, const ORInt maxLevel)
{
    if (maxLevel > cap_min(cumu))
        [cumu->_capacity updateMin: maxLevel];
}

static void tt_filter_start_end_times(CPTaskCumulative* cumu, const ORInt uSize, const ORInt maxLevel, bool* update)
{
    ORInt maxCapacity = cap_max(cumu);
    ORInt index = 0;    // Profile index
//    for (ORInt ii = 0; ii < cumu->_first_fixed._val; ii++) {
//        ORInt i = cumu->_fixed[ii];
    for (ORInt ii = 0; ii < uSize; ii++) {
        const ORInt i = cumu->_idx[ii];
        if (isBounded(cumu, i))
            continue;
        // Check whether an update is possible
        if (maxLevel + usage_min(cumu, i) > maxCapacity && dur_min(cumu, i) > 0) {
            
            /* Determining a new earliest start time for the task i */
            
            ORInt new_est = est(cumu, i);

            // Binary search for index
            index = find_first_profile_peak_for_lb(cumu->_profile, new_est, 0, (ORInt)cumu->_psize - 1);
            // Determining the new earliest start time
            for (ORInt p = index; p < cumu->_psize; p++) {
                //printf("profile %d\n", p);
                // Check whether a better lower bound is still possible
                if (new_est + dur_min(cumu, i) <= cumu->_profile[p]._begin) {
                    break;
                }
                assert(new_est + dur_min(cumu, i) > cumu->_profile[p]._begin);
                // Check whether an earliest execution would overlap with the profile peak
                // and would cause an resource overload
                if (new_est < cumu->_profile[p]._end && usage_min(cumu, i) + cumu->_profile[p]._level > maxCapacity) {
                    // Check whether the task does not have a compulsory part in the profile peak
                    if (!(lst(cumu, i) < ect(cumu, i) && lst(cumu, i) <= cumu->_profile[p]._begin &&
                          cumu->_profile[p]._end <= ect(cumu, i))) {
                        // A new earliest start time
                        new_est = cumu->_profile[p]._end;
                        // TODO increment propagation counter
                    }
                }
            }
            // Imposing the new earliest start time
            if (new_est > est(cumu, i)) {
                cumu->_nb_tt_props++;
                [cumu->_tasks[i] updateStart:new_est];
                *update = true;
            }
            
            /* Determining a new lastest end time for the task i */
            
            ORInt new_lct = lct(cumu, i);

            // Binary search for the index
            index = find_first_profile_peak_for_ub(cumu->_profile, new_lct, 0, (ORInt)cumu->_psize - 1);
            
            // Determining the new latest completion time
            for (ORInt p = index; p >= 0; p--) {
                // Check whether a better upper bound is still possible
                if (cumu->_profile[p]._end <= new_lct - dur_min(cumu, i)) {
                    break;
                }
                assert(cumu->_profile[p]._end > new_lct - dur_min(cumu, i));
                // Check whether a latest execution would overlap with the profile peak
                // and would cause an resource overload
                if (cumu->_profile[p]._begin < new_lct && cumu->_profile[p]._level + usage_min(cumu, i) > maxCapacity) {
                    // Check whether the task does not have a compulsory part in the profile peak
                    if (!(lst(cumu, i) < ect(cumu, i) && lst(cumu, i) <= cumu->_profile[p]._begin &&
                          cumu->_profile[p]._end <= ect(cumu, i))) {
                        // A new latest completion time
                        new_lct = cumu->_profile[p]._begin;
                        // TODO increment propagation counter
                    }
                }
            }
            // Imposing the new latest completion time
            if (new_lct < lct(cumu, i)) {
                cumu->_nb_tt_props++;
                [cumu->_tasks[i] updateEnd:new_lct];
                *update = true;
            }
        }
    }
}

static ORInt find_first_profile_peak_for_lb(ProfilePeak* profile, const ORInt time, ORInt low, ORInt up)
{
    ORInt median;
    if (profile[low]._end > time || low == up) {
        return low;
    }
    if (profile[up]._begin <= time) {
        return up;
    }

     // ASSUMPTIONS:
    assert(profile[low]._end <= time);
    assert(profile[up]._begin > time);
    assert(low < up);
    
    while (!(profile[low]._end <= time && time <= profile[low + 1]._end)) {
        median = low + (up - low + 1) / 2;
        if (time < profile[median]._end) {
            up = median;
            low++;
        }
        else {
            low = median;
        }
    }
    return low;
}

static ORInt find_first_profile_peak_for_ub(ProfilePeak* profile, const ORInt time, ORInt low, ORInt up) {
    ORInt median;
    if (profile[up]._begin <= time || low == up) {
        return up;
    }
    if (time < profile[low]._end) {
        return low;
    }
    
    // ASSUMPTIONS:
    assert(profile[up]._begin > time);
    assert(profile[low]._end <= time);
    assert(low < up);

    while (!(profile[up - 1]._begin <= time && time < profile[up]._begin)) {
        median = low + (up - low + 1) / 2;
        if (time < profile[median]._begin) {
            up = median;
        }
        else {
            low = median;
            up--;
        }
    }
    return up;
}

/*****************************************
 * Time-tabling-edge-finding propagation *
 * 
 * TODO: 
 *  - Bounds propagator
 *  - Removing the arrays ttEnAfterEst, ttEnAfterLct
 *****************************************/


    // Shift functions for determining the required free energy in time intervals
    //
static inline ORInt
get_free_dur_right_shift(const ORInt begin, const ORInt end, const ORInt est, const ORInt ect,
                         const ORInt lst, const ORInt lct, const ORInt dur_fixed_in)
{
    return (begin <= est ? max(0, end - lst - dur_fixed_in) : 0);
}

static inline ORInt
get_free_dur_left_shift(const ORInt begin, const ORInt end, const ORInt est, const ORInt ect,
                         const ORInt lst, const ORInt lct, const ORInt dur_fixed_in)
{
    return (end >= lct ? max(0, ect - begin - dur_fixed_in) : 0);
}


static inline ORInt
get_no_shift(const ORInt begin, const ORInt end, const ORInt est, const ORInt ect,
                        const ORInt lst, const ORInt lct, const ORInt dur_fixed_in)
{
    return 0;
}


static void ttef_initialise_parameters(CPTaskCumulative* cumu, ORInt* task_id_est, ORInt* task_id_lct, ORInt* ttEnAfterEst, ORInt* ttEnAfterLct)
{
    const ORInt fsize = cumu->_first_fixed._val;
    
    assert(fsize > 0);
    
//    printf("fsize: %d; size: %lld\n", fsize, cumu->_size);
    
    // Initialisation
    for (ORInt ii = 0; ii < fsize; ii++) {
        task_id_est[ii] = cumu->_fixed[ii];
        task_id_lct[ii] = cumu->_fixed[ii];
    }
    
    // Sorting the tasks in non-decreasing order by the earliest start time
    qsort_r(task_id_est, fsize, sizeof(ORInt), cumu, (int(*)(void*, const void*, const void*)) &sortEstAsc);
    // Sorting the tasks in non-decreasing order by the latest completion time
    qsort_r(task_id_lct, fsize, sizeof(ORInt), cumu, (int(*)(void*, const void*, const void*)) &sortLctAsc);
    
    // Calculation of ttEnAfterEst and ttEnAfterLct
    if (cumu->_psize == 0) {
        for (ORInt ii = 0; ii < fsize; ii++) {
            ttEnAfterEst[ii] = 0;
            ttEnAfterLct[ii] = 0;
        }
    }
    else {
        ProfilePeak* profile = cumu->_profile;
        ORInt energy = 0;
        ORLong p = cumu->_psize - 1;
       
        // Calculation of ttEnAfterEst
        for (ORUInt ii = fsize; ii--; ) {
            ORInt i = task_id_est[ii];
            if (p < 0 || profile[p]._end <= est(cumu, i)) {
                ttEnAfterEst[ii] = energy;
            }
            else if (profile[p]._begin <= est(cumu, i)) {
                ttEnAfterEst[ii] = energy + profile[p]._level * (profile[p]._end - est(cumu, i));
            }
            else {
                assert(profile[p]._begin > est(cumu, i));
                energy += profile[p]._level * (profile[p]._end - profile[p]._begin);
                p--;
                ii++;
            }
        }
        
        // Calculation of ttEnAfterLct
        energy = 0;
        p = cumu->_psize - 1;
        
        for (ORUInt ii = fsize; ii--; ) {
            ORInt i = task_id_lct[ii];
            if (p < 0 || profile[p]._end <= lct(cumu, i)) {
                ttEnAfterLct[ii] = energy;
            }
            else if (profile[p]._begin <= lct(cumu, i)) {
                ttEnAfterLct[ii] = energy + profile[p]._level * (profile[p]._end - lct(cumu, i));
            }
            else {
                assert(profile[p]._begin > lct(cumu, i));
                energy += profile[p]._level * (profile[p]._end - profile[p]._begin);
                p--;
                ii++;
            }
        }
    }
    
//    // Printing
//    for (ORLong p = 0; p < cumu->_psize; p++) {
//        printf("{[%d, %d): %d}, ", cumu->_profile[p]._begin, cumu->_profile[p]._end, cumu->_profile[p]._level);
//    }
//    printf("\n");
//    for (ORInt ii = 0; ii < fsize; ii++) {
//        ORInt i = task_id_est[ii];
//        printf("{%d: %d}, ", est(cumu, i), ttEnAfterEst[ii]);
//        assert(0 <= ttEnAfterEst[ii] && ttEnAfterEst[ii] <= 100);
//    }
//    printf("\n");
//    for (ORInt ii = 0; ii < fsize; ii++) {
//        ORInt i = task_id_lct[ii];
//        printf("{%d: %d}, ", lct(cumu, i), ttEnAfterLct[ii]);
//        assert(0 <= ttEnAfterLct[ii] && ttEnAfterLct[ii] <= 100);
//    }
//    printf("\n");
}

    // Specialised TTEF consistency check which can detect dominated time intervals and
    // skip them
    // Time complexity: O(u^2) where u is the number of unfixed tasks
    // Space complexity: O(u)
static void ttef_consistency_check(CPTaskCumulative* cumu, const ORInt* task_id_est, const ORInt* task_id_lct,
    const ORInt* ttEnAfterEst, const ORInt* ttEnAfterLct,
    ORInt shift_in(const ORInt, const ORInt, const ORInt, const ORInt, const ORInt, const ORInt, const ORInt))
{
    const ORInt fsize = cumu->_first_fixed._val;
    assert(fsize > 0);
    
    ORInt begin, end;   // Begin and end time of the interval [begin, end)
    ORInt est_idx_last = fsize - 1;
    ORUInt i, j;        // Task that determines the end time (i) and the start time (j)
                        // of the interval
    ORUInt en_req_free; // Accumulated required free energy for the intervals [., end)
    
    // TTEF dominance skipping rule
    // - bookkeeping variables
#if TTEFDOMRULESKIP
    ORInt minAvail = -1;    // Minimal available energy of an interval ending at end
    ORInt ii_min   = -1;    // Index of task_id_lct pointing to the task id determining that end
#endif
    
    end = lct(cumu, task_id_lct[fsize - 1]);
    
    // Outer loop: Iteration over the end times of the intervals
    //
    for (ORUInt ii = fsize; ii--;) {
        i = task_id_lct[ii];
        if (end == lct(cumu, i)) continue;
        
        // TTEF dominance skipping rule
        // - check whether the inner loop can be skipped
#if TTEFDOMRULESKIP
        if (ii_min >= 0 && minAvail > cap_max(cumu) * (end - lct(cumu, i)) - ttEnAfterLct[ii] + ttEnAfterLct[ii_min]) {
            continue;
        }
        ii_min = -1;
#endif
        
        // New end time for the intervals to be checked
        end = lct(cumu, i);
        // Computing the first index that leads to a non-empty interval, i.e., begin < end
        while (est(cumu, task_id_est[est_idx_last]) >= end) est_idx_last--;
        assert(est_idx_last >= 0);
        
        // Initialisations
        en_req_free = 0;
        
        // Inner loop: Iteration over the start times of the intervals
        //
        for (ORUInt jj = est_idx_last + 1; jj--; ) {
            j = task_id_est[jj];
            
            assert(est(cumu, j) < end);
            
            begin = est(cumu, j);
            
            // Adding the required energy of j in the intervals [begin', end)
            // where begin' <= est(cumu, j)
            if (lct(cumu, j) <= end) {
                // Task j fully lies in the interval [begin, end)
                en_req_free += free_energy(cumu, j);
            }
            else {
                // Calculation whether a free part of the task partially lies
                // in the interval
                ORInt dur_fixed = max(0, ect(cumu, j) - lst(cumu, j));
                ORInt dur_shift = shift_in(begin, end, est(cumu, j), ect(cumu, j), lst(cumu, j), lct(cumu, j), dur_fixed);
                en_req_free += usage_min(cumu, j) * dur_shift;
            }
            
            // Computing the total required energy in the interval [begin, end)
            assert(0 <= jj && jj < fsize);
            ORInt en_req = en_req_free + ttEnAfterEst[jj] - ttEnAfterLct[ii];
            ORInt en_avail = cap_max(cumu) * (end - begin) - en_req;
            
            // Checking for a rresource overload
            if (en_avail < 0) {
                // Increment conflict counter
                cumu->_nb_ttef_incons++;
                //NSLog(@"Cumulative: propagate/0: TTEF Fail\n");
                failNow();
            }
            
            // TTEF dominance skipping rule
            // - updating the minimal available energy
#if TTEFDOMRULESKIP
            if (ii_min == -1 || (ii_min >= 0 && minAvail > en_avail)) {
                minAvail = en_avail;
                ii_min = ii;
            }
#endif
        }
    }
}

static void ttef_filter_start_and_end_times(CPTaskCumulative* cumu, ORInt* task_id_est, ORInt* task_id_lct,
    ORInt* ttEnAfterEst, ORInt* ttEnAfterLct,
    ORInt shift_in1(const ORInt, const ORInt, const ORInt, const ORInt, const ORInt, const ORInt, const ORInt),
    ORInt shift_in2(const ORInt, const ORInt, const ORInt, const ORInt, const ORInt, const ORInt, const ORInt),
    bool* update)
{
    ORLong fsize = cumu->_first_fixed._val;
    if (fsize <= 0) return ;
    
    // Allocation of memory for recording the new bounds
    ORInt* new_est = alloca(cumu->_size * sizeof(ORInt));
    ORInt* new_lct = alloca(cumu->_size * sizeof(ORInt));
    
    if (new_est == NULL || new_lct == NULL) {
        @throw [[ORExecutionError alloc] initORExecutionError: "Cumulative: Out of memory!"];
    }

    // Initialisation of the arrays
    for (ORInt ii = 0; ii < fsize; ii++) {
        ORInt i = cumu->_fixed[ii];
        new_est[i] = est(cumu, i);
        new_lct[i] = lct(cumu, i);
        
    }

    // TTEF propagation of the start times
    ttef_filter_start_times(cumu, task_id_est, task_id_lct, ttEnAfterEst, ttEnAfterLct, new_est, new_lct, shift_in1, update);
    // TTEF propagaiton of the end times
    ttef_filter_end_times(cumu, task_id_est, task_id_lct, ttEnAfterEst, ttEnAfterLct, new_est, new_lct, shift_in2, update);
    
    // Updating the bounds
    for (ORInt ii = 0; ii < fsize; ii++) {
        ORInt i = cumu->_fixed[ii];
        if (new_est[i] > est(cumu, i)) {
            [cumu->_tasks[i] updateStart:new_est[i]];
        }
        if (new_lct[i] < lct(cumu, i)) {
            [cumu->_tasks[i] updateEnd:new_lct[i]];
        }
    }
}

static void ttef_filter_start_times(CPTaskCumulative* cumu, const ORInt* task_id_est, const ORInt* task_id_lct,
    const ORInt* ttEnAfterEst, const ORInt* ttEnAfterLct, ORInt* new_est, ORInt* new_lct,
    ORInt shift_in(const ORInt, const ORInt, const ORInt, const ORInt, const ORInt, const ORInt, const ORInt),
    bool* update)
{
    const ORInt fsize = cumu->_first_fixed._val;
    assert(fsize > 0);
    
    ORInt begin, end;   // Begin and end time of the interval [begin, end)
    ORInt est_idx_last = fsize - 1;
    ORUInt i, j;        // Task that determines the end time (i) and the start time (j) of the interval
    ORUInt en_req_free; // Accumulated required free energy for the intervals [., end)
    
    ORInt update_en_req_start;
    ORInt update_idx = 0;
    
#if (TTEEFABSOLUTEPROP || TTEEFDENSITYPROP)
    ORInt min_en_avail_init;
    min_en_avail_init = cap_max(cumu) * (lct(cumu, task_id_lct[fsize - 1]) - est(cumu, task_id_est[0]));
#endif
#if TTEEFABSOLUTEPROP
    ORInt min_begin;
#endif
#if TTEEFDENSITYPROP
    ORInt min_density_begin;
    ORInt min_density;
#endif

    end = lct(cumu, cumu->_fixed[est_idx_last]) + 1;
    
    // Outer loop: Iteration over the end times of the interval
    //
    for (ORUInt ii = fsize; ii--; ) {
        i = task_id_lct[ii];
        
        // Check whether time intervals with the same end time have already been checked
        if (end == lct(cumu, i))
            continue;
        
        // New end time of the time intervals
        end = lct(cumu, i);
        
        // Computing the first index to be consider wrt. the begin time of the time intervals
        while (est(cumu, task_id_est[est_idx_last]) >= end) {
            est_idx_last--;
        }
        
        // Initialisations for the inner loop
        en_req_free = 0;
        update_en_req_start = -1;
        update_idx = fsize;
        
#if TTEEFABSOLUTEPROP
        ORInt min_en_avail = min_en_avail_init;
        min_begin = MININT;
#endif
#if TTEEFDENSITYPROP
        ORInt min_density_en_avail = min_en_avail_init;
        min_density_begin = MININT;
        min_density = cap_max(cumu) + 1;
#endif
        
        // Inner loop: Iteration over the begin times of the interval [., end)
        //
        for (ORUInt jj = est_idx_last + 1; jj--; ) {
            j = task_id_est[jj];
            
            assert(est(cumu, j) < end);
            
#if TTEEFABSOLUTEPROP
            // TTEEF bounds propagation for task j with respect to the time interval [., end)
            // containing the minimal available energy
            tteef_filter_end_times_in_interval(cumu, new_lct, j, min_begin, end, min_en_avail, update);
#endif
#if TTEEFDENSITYPROP
            // TTEEF bounds propagation for task j with respect to the time interval [., end)
            // that is one of the most dense ones
            tteef_filter_end_times_in_interval(cumu, new_lct, j, min_density_begin, end, min_density_en_avail, update);
#endif
            
            // New begin time of the time interval [begin, end)
            begin = est(cumu, j);
            
            // Adding the required energy of j in the intervals [begin', end)
            // where begin' <= est(cumu, j)
            if (lct(cumu, j) <= end) {
                // TODO Task j fully lies in the interval [begin, end)
                en_req_free += free_energy(cumu, j);
            }
            else {
                // Calculation whether a free part of the task partially lies
                // in the interval
                ORInt dur_fixed = max(0, ect(cumu, j) - lst(cumu, j));
                ORInt dur_shift = shift_in(begin, end, est(cumu, j), ect(cumu, j), lst(cumu, j), lct(cumu, j), dur_fixed);
                en_req_free += usage_min(cumu, j) * dur_shift;
                // Calculation of the required energy for starting at est(j)
                ORInt en_req_start = min(free_energy(cumu, j), usage_min(cumu, j) * (end - est(cumu, j))) - usage_min(cumu, j) * dur_shift;
                if (en_req_start > update_en_req_start) {
                    update_en_req_start = en_req_start;
                    update_idx = jj;
                }
            }
            
            // Computing the total required energy in the interval [begin, end)
            ORInt en_req = en_req_free + ttEnAfterEst[jj] - ttEnAfterLct[ii];
            ORInt en_avail = cap_max(cumu) * (end - begin) - en_req;
            
            // Checking for a rresource overload
            if (en_avail < 0) {
                // Increment conflict counter
                cumu->_nb_ttef_incons++;
                //NSLog(@"Cumulative: propagate/0: TTEF Fail\n");
                failNow();
            }
  
#if TTEEFABSOLUTEPROP
            // Update the most-packed time interval [., end)
            if (en_avail < min_en_avail) {
                min_en_avail = en_avail;
                min_begin = begin;
            }
#endif
#if TTEEFDENSITYPROP
            // Update the most-dense time interval [., end)
            ORInt approx_density = en_avail / (end - begin);
            if (approx_density < min_density ||
                (approx_density == min_density && en_avail < min_density_en_avail)) {
                
                min_density = approx_density;
                min_density_en_avail = en_avail;
                min_density_begin = begin;
                // Check for a lower bound update on the capacity
                // TODO Moving that check out of the loops
                if (!isCapBounded(cumu) && cap_max(cumu) - approx_density > cap_min(cumu)) {
                    [cumu->_cap updateMin: cap_max(cumu) - approx_density];
                }
            }
#endif
            
            // Check for a start time update
            if (en_avail < update_en_req_start) {
                assert(update_en_req_start > 0);
                assert(0 <= update_idx && update_idx < fsize);
                
                // Reset 'j' to the task to be updated
                j = task_id_est[update_idx];
                // Calculation of the possible new lower bound wrt. the current
                // time interval [begin, end)
                int dur_cp_in = max(0, min(end, ect(cumu, j)) - lst(cumu, j));
                int dur_shift = shift_in(begin, end, est(cumu, j), ect(cumu, j), lst(cumu, j), lct(cumu, j), dur_cp_in);
                int dur_avail = (en_avail / usage_min(cumu, j)) + dur_cp_in + dur_shift;
                int start_new = end - dur_avail;
                
                // Check whether a new lower bound was found
                if (start_new > new_est[j]) {
                    cumu->_nb_ttef_props++;
                    *update = true;
                    new_est[j] = start_new;
                }
            }
            
        }
    }
}

static void ttef_filter_end_times(CPTaskCumulative* cumu, const ORInt* task_id_est, const ORInt* task_id_lct,
    const ORInt* ttEnAfterEst, const ORInt* ttEnAfterLct, ORInt* new_est, ORInt* new_lct,
    ORInt shift_in(const ORInt, const ORInt, const ORInt, const ORInt, const ORInt, const ORInt, const ORInt),
    bool* update)
{
    ORInt fsize = cumu->_first_fixed._val;
    ORUInt i, j;
    ORInt begin, end;
    ORUInt en_req_free;
    ORInt update_en_req_end;
    ORInt lct_idx_last = 0;
    ORInt update_idx;
    
    begin = MININT;
    
#if (TTEEFABSOLUTEPROP || TTEEFDENSITYPROP)
    ORInt min_en_avail_init;
    min_en_avail_init = cap_max(cumu) * (lct(cumu, task_id_lct[fsize - 1]) - est(cumu, task_id_est[0]));
#endif
#if TTEEFABSOLUTEPROP
    ORInt min_end;
#endif
#if TTEEFDENSITYPROP
    ORInt min_density_end;
    ORInt min_density;
#endif
    
    // Outer loop: iterating over est in non-decreasing order
    //
    for (unsigned ii = 0; ii < fsize; ii++) {
        i = task_id_est[ii];
        if (begin == est(cumu, i)) continue;
        
        begin = est(cumu, i);
        
        // Finding the first index for the inner loop
        while (lct(cumu, task_id_lct[lct_idx_last]) <= begin) lct_idx_last++;
        
        // Initialisation for the inner loop
        en_req_free = 0;
        update_idx = fsize;
        update_en_req_end = -1;
        
#if TTEEFABSOLUTEPROP
        ORInt min_en_avail = min_en_avail_init;
        min_end = MAXINT;
#endif
#if TTEEFDENSITYPROP
        ORInt min_density_en_avail = min_en_avail_init;
        min_density_end = MAXINT;
        min_density = cap_max(cumu) + 1;
#endif
        
        // Inner loop: iterating over lct in non-decreasing order
        //
        for (ORUInt jj = lct_idx_last; jj < fsize; jj++) {
            j = task_id_lct[jj];
            
            assert(begin < lct(cumu, j));
            end = lct(cumu, j);
            
#if TTEEFABSOLUTEPROP
            // TTEEF bounds propagation for task j with respect to the time interval [begin, .)
            // containing the minimal available energy
            tteef_filter_start_times_in_interval(cumu, new_est, j, begin, min_end, min_en_avail, update);
#endif
#if TTEEFDENSITYPROP
            // TTEEF bounds propagation for task j with respect to the time interval [begin, .)
            // that is one of the most dense ones
            tteef_filter_start_times_in_interval(cumu, new_est, j, begin, min_density_end, min_density_en_avail, update);
#endif
            
            // Calculation of the required free energy of j in [begin, end)
            //
            if (begin <= est(cumu, j)) {
                // Task j is contained in the time interval [begin, end)
                en_req_free += free_energy(cumu, j);
            } else {
                // Task j might be partially contained in [begin, end)
                ORInt dur_fixed = max(0, ect(cumu, j) - lst(cumu, j));
                ORInt dur_shift = shift_in(begin, end, est(cumu, j), ect(cumu, j), lst(cumu, j), lct(cumu, j), dur_fixed);
                en_req_free += usage_min(cumu, j) * dur_shift;
                // Calculation of the required energy for completing j at 'lct(j)'
                ORInt en_req_end = min(free_energy(cumu, j), usage_min(cumu, j) * (lct(cumu, j) - begin)) - usage_min(cumu, j) * dur_shift;
                if (en_req_end > update_en_req_end) {
                    update_en_req_end = en_req_end;
                    update_idx = jj;
                }
            }
            
            // Computing the total required energy in the interval [begin, end)
            ORInt en_req = en_req_free + ttEnAfterEst[ii] - ttEnAfterLct[jj];
            ORInt en_avail = cap_max(cumu) * (end - begin) - en_req;
            
            // Checking for a rresource overload
            if (en_avail < 0) {
                // Increment conflict counter
                cumu->_nb_ttef_incons++;
                //NSLog(@"Cumulative: propagate/0: TTEF Fail\n");
                failNow();
            }
            
#if TTEEFABSOLUTEPROP
            // Update the most-packed time interval [begin, .)
            if (en_avail < min_en_avail) {
                min_en_avail = en_avail;
                min_end = end;
            }
#endif
#if TTEEFDENSITYPROP
            // Update the most-dense time interval [begin, .)
            ORInt approx_density = en_avail / (end - begin);
            if (approx_density < min_density ||
                (approx_density == min_density && en_avail < min_density_en_avail)) {
                
                min_density = approx_density;
                min_density_en_avail = en_avail;
                min_density_end = end;
                // Check for a lower bound update on the capacity
                // TODO Moving that check out of the loops
                if (!isCapBounded(cumu) && cap_max(cumu) - approx_density > cap_min(cumu)) {
                    [cumu->_cap updateMin: cap_max(cumu) - approx_density];
                }
            }
#endif
            
            // Check for a start time update
            //
            if (en_avail < update_en_req_end) {
                assert(update_en_req_end > 0);
                assert(0 <= update_idx && update_idx < fsize);
                
                // Reset 'j' to the task to be updated
                j = task_id_lct[update_idx];
                
                // Calculation of the possible upper bound wrt.
                // the current time interval [begin, end)
                ORInt dur_cp_in = max(0, ect(cumu, j) - max(begin, lst(cumu, j)));
                ORInt dur_shift = shift_in(begin, end, est(cumu, j), ect(cumu, j), lst(cumu, j), lct(cumu, j), dur_cp_in);
                ORInt dur_avail = (en_avail / usage_min(cumu, j)) + dur_cp_in + dur_shift;
                ORInt end_new   = begin + dur_avail;
                
                // Check whether a new upper bound was found
                if (end_new < new_lct[j]) {
                    cumu->_nb_ttef_props++;
                    *update = true;
                    new_lct[j] = end_new;
                }
            }
        }
    }
}

static void tteef_filter_start_times_in_interval(CPTaskCumulative* cumu, ORInt* new_est, const ORInt j, const ORInt tw_begin, const ORInt tw_end, const ORInt en_avail, bool* update)
{
    ORInt free_ect = (lst(cumu, j) < ect(cumu, j) ? lst(cumu, j) : ect(cumu, j));
    
    // TTEEF bounds propagation for task j with respect to the time interval [begin, .)
    int min_en_req = usage_min(cumu, j) * (min(tw_end, free_ect) - max(tw_begin, est(cumu, j)));
    
    if (tw_end < MAXINT && en_avail < min_en_req) {
        assert(free_ect > tw_begin);
        // Calculate the new lower bound
        ORInt dur_cp_in = max(0, min(tw_end, ect(cumu, j)) - max(tw_begin, lst(cumu, j)));
        ORInt dur_avail = (en_avail / usage_min(cumu, j)) + dur_cp_in;
        ORInt est_new = tw_end - dur_avail;
        // Check whether a new lower bound was found
        if (est_new > new_est[j]) {
            cumu->_nb_ttef_props++;
            *update = true;
            new_est[j] = est_new;
        }
    }
}

static void tteef_filter_end_times_in_interval(CPTaskCumulative* cumu, ORInt* new_lct, const ORInt j, const ORInt tw_begin, const ORInt tw_end, const ORInt en_avail, bool* update) {
    ORInt free_lst = (lst(cumu, j) < ect(cumu, j) ? ect(cumu, j) : lst(cumu, j));
    // TTEEF bounds propagation for task j with respect to the time interval [., end)
    ORInt min_en_req = usage_min(cumu, j) * (min(tw_end, lct(cumu, j)) - max(tw_begin, free_lst));
    
    if (tw_begin > MININT && en_avail < min_en_req) {
        assert(free_lst < tw_end);
        // Calculate the new upper bound
        ORInt dur_cp_in = max(0, min(tw_end, ect(cumu, j)) - max(tw_begin, lst(cumu, j)));
        ORInt dur_avail = (en_avail / usage_min(cumu, j)) + dur_cp_in;
        int lct_new = tw_begin + dur_avail;
        // Check whether a new upper bound was found
        if (lct_new < new_lct[j]) {
            cumu->_nb_ttef_props++;
            *update = true;
            // Push possible update into queue
            new_lct[j] = lct_new;
        }
    }
}


    // Main method for the time-tabling-edge-finding (TTEF) propagation
    //
static void ttef_bounds_propagation(CPTaskCumulative* cumu, bool* update)
{
    assert(cumu->_ttef_check || cumu->_ttef_filt);
    
    const ORInt fsize = cumu->_first_fixed._val;
    if (fsize <= 0) return ;
    
    // Fixed tasks are order wrt. their est
    ORInt* task_id_est  = alloca(fsize * sizeof(ORInt));
    // Fixed tasks are order wrt. their lct
    ORInt* task_id_lct  = alloca(fsize * sizeof(ORInt));
    // XXX ttEnAfterEst and ttEnAfterLct do not need to be pre-computed
    ORInt* ttEnAfterEst = alloca(fsize * sizeof(ORInt));
    ORInt* ttEnAfterLct = alloca(fsize * sizeof(ORInt));
    
    if (task_id_est == NULL || task_id_lct == NULL || ttEnAfterEst == NULL || ttEnAfterLct == NULL) {
        @throw [[ORExecutionError alloc] initORExecutionError: "Cumulative: Out of memory!"];
    }
    
    // Initialise all the parameters
    ttef_initialise_parameters(cumu, task_id_est, task_id_lct, ttEnAfterEst, ttEnAfterLct);
    
    if (cumu->_ttef_filt) {
        // TTEF bounds filtering incl. consistency check
#if TTEFLEFTRIGHTSHIFT
        ttef_filter_start_and_end_times(cumu, task_id_est, task_id_lct, ttEnAfterEst, ttEnAfterLct, get_free_dur_right_shift, get_free_dur_left_shift, update);
#else
        ttef_filter_start_and_end_times(cumu, task_id_est, task_id_lct, ttEnAfterEst, ttEnAfterLct, get_no_shift, get_no_shift, update);
#endif
    } else {
        assert(cumu->_ttef_check);
        // TTEF consistency check
#if TTEFLEFTRIGHTSHIFT
        ttef_consistency_check(cumu, task_id_est, task_id_lct, ttEnAfterEst, ttEnAfterLct, get_free_dur_right_shift);
#else
        ttef_consistency_check(cumu, task_id_est, task_id_lct, ttEnAfterEst, ttEnAfterLct, get_no_shift);
#endif
    }
}

/*******************************************************************************
 Computation of the contention profile
 ******************************************************************************/

// Computation of the contention profile for the earliest-start-time schedule
//
static Profile cumuGetEarliestContentionProfile(CPTaskCumulative * cumu)
{
    ORInt estA  [cumu->_size];
    ORInt ectA  [cumu->_size];
    ORInt h     [cumu->_size];
    ORInt id_est[cumu->_size];
    ORInt id_ect[cumu->_size];
    
    // Initialisation of the arrays
    for (ORInt t = 0; t < cumu->_size; t++) {
        estA  [t] = est(cumu, t);
        ectA  [t] = ect(cumu, t);
        h     [t] = usage_min(cumu, t);
        id_est[t] = t;
        id_ect[t] = t;
    }
    
    // NOTE: qsort_r the 3rd argument of qsort_r is at the last position in glibc (GNU/Linux)
    // instead of the second last
    // Sorting the tasks in non-decreasing order by the earliest start time
    qsort_r(id_est, cumu->_size, sizeof(ORInt), cumu, (int(*)(void*, const void*, const void*)) &sortEstAsc);
    // Sorting the tasks in non-decreasing order by the latest completion time
    qsort_r(id_ect, cumu->_size, sizeof(ORInt), cumu, (int(*)(void*, const void*, const void*)) &sortEctAsc);

    Profile prof = getEarliestContentionProfile(id_est, id_ect, estA, ectA, h, (ORInt) cumu->_size);
    
    return prof;
}

/*******************************************************************************
 Computation of the partial order
 ******************************************************************************/

static CPTaskVarPrec * cumuGetPartialOrder(CPTaskCumulative * cumu, ORInt * psize)
{
    const ORInt aSize  = (ORInt) cumu->_tasks.count;
    const ORInt cSize = cumu->_cIdx._val;

    // Assumption all activities are fixed
    for (ORInt tt = 0; tt < cumu->_size; tt++) {
        const ORInt t = cumu->_idx[tt];
        assert(isBounded(cumu, t));
    }

    // XXX Assumption all activities are fixed
    ORInt id_est[cSize];
    ORInt id_ect[cSize];
    CPTaskVarPrec * prec = NULL;

    ORInt cap  = 0;
    ORInt size = 0;

    // Clean up
    cleanUp(cumu);
    
    // Allocating memory
    // XXX Should be permanently and maybe even trailed
    cumu->_est = alloca(aSize * sizeof(ORInt));
    cumu->_ect = alloca(aSize * sizeof(ORInt));
    
    // Check whether memory allocation was successful
    if (cumu->_est == NULL || cumu->_ect == NULL) {
        @throw [[ORExecutionError alloc] initORExecutionError: "CPTaskCumulative: Out of memory!"];
    }

    // Initialisation of the arrays
    for (ORInt tt = 0; tt < cSize; tt++) {
        const ORInt t = cumu->_idx[tt];
        cumu->_est[t] = cumu->_tasks[t].est;
        cumu->_ect[t] = cumu->_tasks[t].ect;
        id_est[tt] = t;
        id_ect[tt] = t;
    }
    
    // NOTE: qsort_r the 3rd argument of qsort_r is at the last position in glibc (GNU/Linux)
    // instead of the second last
    // Sorting the tasks in non-decreasing order by the earliest start time
    qsort_r(id_est, cSize, sizeof(ORInt), cumu, (int(*)(void*, const void*, const void*)) &sortEstAsc);
    // Sorting the tasks in non-decreasing order by the latest completion time
    qsort_r(id_ect, cSize, sizeof(ORInt), cumu, (int(*)(void*, const void*, const void*)) &sortEctAsc);
    
    ORInt tt1  = 0;
    ORInt tt2  = 0;
    ORInt time = MININT;
    NSMutableSet * prevAct = [[NSMutableSet alloc] init];
    
    while (tt1 < cSize) {
        assert(tt1 < cSize);
        assert(tt2 < cSize);
        
        const ORInt t1 = id_est[tt1];
        const ORInt t2 = id_ect[tt2];
        const ORInt time1 = est(cumu, t1);
        const ORInt time2 = ect(cumu, t2);
        
        if (time1 < time2) {
            // Memory allocation
            if (size + prevAct.count >= cap) {
                cap = (cap > 0 ? cap << 1 : 16);
                cap = (size + prevAct.count >= cap ? size + (ORInt) (prevAct.count) + 1 : cap);
                if (prec == NULL) {
                    prec = (CPTaskVarPrec *) malloc(cap * sizeof(CPTaskVarPrec));
                } else {
                    prec = (CPTaskVarPrec *) realloc(prec, cap * sizeof(CPTaskVarPrec));
                }
                if (prec == NULL) {
                    @throw [[ORExecutionError alloc] initORExecutionError: "CPTaskCumulative: Out of memory!"];
                }
            }
            // Adding precedence relations
            NSEnumerator * myEnum = [prevAct objectEnumerator];
            NSNumber * num;
            while ((num = [myEnum nextObject])) {
                prec[size]._before = cumu->_tasks[t1];
                prec[size]._after  = cumu->_tasks[(ORInt) [num intValue]];
                size++;
            }
            tt1++;
        } else {
            // time1 >= time2
            // Clearing the set
            if (time < time2) [prevAct removeAllObjects];
            // Adding 't2' to the set
            NSNumber * n2 = [NSNumber numberWithInt:t2];
            [prevAct addObject:n2];
            time = time2;
            tt2++;
        }
    }
    
    [prevAct release];
    
    *psize = size;
    
    return prec;
}
/*******************************************************************************
 Auxiliary Functions
 ******************************************************************************/

static void cleanUp(CPTaskCumulative * cumu) {
    cumu->_est         = NULL;
    cumu->_ect         = NULL;
    cumu->_lst         = NULL;
    cumu->_lct         = NULL;
    cumu->_dur_min     = NULL;
    cumu->_usage_min   = NULL;
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

static void updateIndices(CPTaskCumulative * cumu)
{
    if (cumu->_cIdx._val < cumu->_uIdx._val) {
        ORInt cIdx = cumu->_cIdx._val;
        ORInt uIdx = cumu->_uIdx._val;
        for (ORInt ii = cIdx; ii < uIdx; ii++) {
            const ORInt i = cumu->_idx[ii];
            if (isRelevant(cumu, i)) {
                // Swap elements in 'ii' and 'cIdx'
                swapORInt(cumu->_idx, ii, cIdx++);
            }
            else if (isIrrelevant(cumu, i)) {
                // Swap elements in 'ii' and 'uIdx'
                swapORInt(cumu->_idx, ii, --uIdx);
                ii--;
            }
        }
        // Update counters
        if (cumu->_cIdx._val < cIdx) assignTRInt(&(cumu->_cIdx), cIdx, cumu->_trail);
        if (cumu->_uIdx._val > uIdx) assignTRInt(&(cumu->_uIdx), uIdx, cumu->_trail);
    }
}

/*******************************************************************************
 Main Propagation Loop
 ******************************************************************************/

static void doPropagation(CPTaskCumulative * cumu) {
    //NSLog(@"Cumulative: propagate/0: Start\n");
    bool update;
    ORInt i_max_usage = -1;
    
    // Clean up
    cleanUp(cumu);
    
    // Update the indices
    updateIndices(cumu);
    
    // XXX size should only depend on the considered tasks
    const ORInt size  = (ORInt) cumu->_tasks.count;
    const ORInt uSize = cumu->_uIdx._val;
    const ORInt cSize = cumu->_cIdx._val;
    
    // Allocating memory
    // XXX Should be permanently and maybe even trailed
    cumu->_est       = alloca(size * sizeof(ORInt));
    cumu->_ect       = alloca(size * sizeof(ORInt));
    cumu->_lst       = alloca(size * sizeof(ORInt));
    cumu->_lct       = alloca(size * sizeof(ORInt));
    cumu->_dur_min   = alloca(size * sizeof(ORInt));
    cumu->_usage_min = alloca(size * sizeof(ORInt));
    
    // Check whether memory allocation was successful
    if (cumu->_est == NULL || cumu->_ect == NULL || cumu->_lst == NULL || cumu->_lct == NULL ||
        cumu->_dur_min == NULL || cumu->_usage_min == NULL) {
        @throw [[ORExecutionError alloc] initORExecutionError: "CPTaskCumulative: Out of memory!"];
    }
    
    for (ORInt tt = 0; tt < uSize; tt++) {
        const ORInt t = cumu->_idx[tt];
        cumu->_est      [t] = cumu->_tasks [t].est;
        cumu->_ect      [t] = cumu->_tasks [t].ect;
        cumu->_lst      [t] = cumu->_tasks [t].lst;
        cumu->_lct      [t] = cumu->_tasks [t].lct;
        cumu->_dur_min  [t] = cumu->_tasks [t].minDuration;
        cumu->_usage_min[t] = cumu->_usages[t].min;
    }
    
    do {
        update = false;
        // Generation of the resource profile and TT consistency check
        propagationLoopPreamble(cumu, cSize, & i_max_usage);
        
        if (i_max_usage >= 0) {
            ORInt maxLevel = cumu->_profile[i_max_usage]._level;
            // TT filtering on resource capacity variable
            tt_filter_cap(cumu, maxLevel);
            // TT filtering on start and end times variables
            if (cumu->_tt_filt)
                tt_filter_start_end_times(cumu, uSize, maxLevel, & update);
            // TTEF propagation
            // TODO Adjustment for optional tasks
//            if (!update && (cumu->_ttef_check || cumu->_ttef_filt)) {
//                ttef_bounds_propagation(cumu, & update);
//            }
        }
    } while (cumu->_idempotent && update);
    //NSLog(@"Cumulative: propagate/0: End\n");
}

@end
