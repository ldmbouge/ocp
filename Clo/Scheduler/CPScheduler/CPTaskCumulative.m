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
#define TTEFDOMRULESKIP 1
    // Whether the left or right shift of an activity should be considered
    // 0 - no ; 1 - yes
#define TTEFLEFTRIGHTSHIFT 1
    // Whether the opportunitic TTEEF rule that considers the minimal available
    // energy in a time interval should be executed
#define TTEEFABSOLUTEPROP 1
    // Whether the opportunitic TTEEF rule that considers the least densed time
    // interval regarding the available energy should be executed
#define TTEEFDENSITYPROP 1


typedef struct {
    ORInt _begin;
    ORInt _end;
    ORInt _level;
} ProfilePeak;


@implementation CPTaskCumulative {
    // General attributs
    ORInt _size;    // Number of tasks in the array '_tasks'
    ORInt _low;     // Lowest index in the array '_tasks'
    ORInt _up;      // Highest index in the array '_tasks'

    // Resource attributs
    ORInt _cap_min;     // Minimal resource capacity
    ORInt _cap_max;     // Maximal resource capacity
    
    // Attributs of tasks
    ORInt  * _est;       // Earliest starting time
    ORInt  * _lct;       // Latest completion time
    ORInt  * _dur_min;   // Minimal duration
    ORInt  * _dur_max;   // Maximal duration
    ORInt  * _usage_min; // Minimal resource usage
    ORInt  * _usage_max; // Maximal resource usage
    ORBool * _present;   // Whether the activity is present
    ORBool * _absent;    // Whether the activity is absent
    
    // Relevant time horizon
    ORInt    _begin;    // Start time of the horizon considered during propagation
    ORInt    _end;      // End time of the horizon considered during propagation

    ORInt * _index;                 // Normalised activities' ID in [Absent | Unknown | Present]
    TRInt   _indexFirstUnknown;     // Size of present activities
    TRInt   _indexFirstPresent;     // Size of present and non-present activities
    
    ORInt * _bound;                 // Activities' ID sorted in [Irrelevant | Unbound | Bound]
    TRInt   _boundFirstUnbound;     // Index of first unbound activity
    TRInt   _boundFirstBound;       // Index of first bound activity
    
    // Storage for the resource profile
    ProfilePeak * _profile;
    ORInt         _profileSize;     // Number of resource peaks
    
    // Filtering options
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
    _tt_filt    = true;
    _ttef_check = true;
    _ttef_filt  = true;

    // Initialisation of the counters
    _nb_tt_incons   = 0;
    _nb_tt_props    = 0;
    _nb_ttef_incons = 0;
    _nb_ttef_props  = 0;

    // Initialisation of other data structures
    _bound   = NULL;
    _index   = NULL;
    _profile = NULL;
    
    return self;
}

-(void) dealloc
{
    printf("%%%% #TT fails: %lld\n",   _nb_tt_incons  );
    printf("%%%% #TT props: %lld\n",   _nb_tt_props   );
    printf("%%%% #TTEF fails: %lld\n", _nb_ttef_incons);
    printf("%%%% #TTEF props: %lld\n", _nb_ttef_props );

    if (_est       != NULL) free(_est      );
    if (_lct       != NULL) free(_lct      );
    if (_dur_min   != NULL) free(_dur_min  );
    if (_dur_max   != NULL) free(_dur_max  );
    if (_usage_min != NULL) free(_usage_min);
    if (_usage_max != NULL) free(_usage_max);
    if (_present   != NULL) free(_present  );
    if (_absent    != NULL) free(_absent   );
    if (_bound     != NULL) free(_bound    );
    if (_index     != NULL) free(_index    );
    if (_profile   != NULL) free(_profile  );
    
    [super dealloc];
}

-(ORUInt) nbUVars {
    ORUInt nb = 0;
    for (ORInt ii = 0; ii <= _size; ii++) {
        if (!_tasks[_index[ii]].bound) nb++;
    }
    return nb;
}

-(ORStatus) post
{
//    printf("CPTaskCumulative: post\n");
    assert(_tasks.count == _usages.count);
    assert(_tasks.low == _usages.low && _tasks.up == _usages.up);

    // Identifying of unnecessary tasks
    _size = (ORInt) _tasks.count;
    _low  = _tasks.low;
    _up   = _tasks.up;

    
    _boundFirstUnbound = makeTRInt(_trail, 0    );
    _boundFirstBound   = makeTRInt(_trail, _size);
    _indexFirstPresent = makeTRInt(_trail, _size);
    _indexFirstUnknown = makeTRInt(_trail, 0    );
    
    // Allocating memory
    _est       = malloc(_size * sizeof(ORInt ));
    _lct       = malloc(_size * sizeof(ORInt ));
    _dur_min   = malloc(_size * sizeof(ORInt ));
    _dur_max   = malloc(_size * sizeof(ORInt ));
    _usage_min = malloc(_size * sizeof(ORInt ));
    _usage_max = malloc(_size * sizeof(ORInt ));
    _present   = malloc(_size * sizeof(ORBool));
    _absent    = malloc(_size * sizeof(ORBool));
    
    if (_est == NULL || _lct == NULL || _dur_min == NULL || _dur_max == NULL
        || _usage_min == NULL || _usage_max == NULL || _present == NULL || _absent == NULL)
        @throw [[ORExecutionError alloc] initORExecutionError: "Cumulative: Out of memory!"];
    
    // Allocating memory
    _bound   = malloc(    _size * sizeof(ORInt      ));
    _index   = malloc(    _size * sizeof(ORInt      ));
    _profile = malloc(2 * _size * sizeof(ProfilePeak));
    
    // Checking whether memory allocation was successful
    if (_bound == NULL || _index == NULL  || _profile == NULL) {
        @throw [[ORExecutionError alloc] initORExecutionError: "Cumulative: Out of memory!"];
    }

    // Initialising the arrays
    for (ORInt t0 = 0; t0 < _size; t0++) {
        _bound[t0] = t0;
        _index[t0] = t0;
    }
    
    // Remove negative values from the domains
    if (_capacity.min < 0) {
        [_capacity updateMin:0];
    }
    for (ORInt tt = 0; tt < _size; tt++) {
        const ORInt t = _index[tt] + _low;
        if (_usages[t].min < 0 && _tasks[t].isPresent) {
            [_usages[t] updateMin:0];
        }
    }
    
    // Call for initial propagation
    [self propagate];

    // Subscription of variables to the constraint
    // XXX Currently, no propagation is performed on non-present tasks
    for (ORInt tt = 0; tt < _size; tt++) {
        const ORInt t = _index[tt] + _low;
        if (!_tasks[t].isAbsent) {
            if (!_tasks[t].isPresent)
                [_tasks[t] whenPresentPropagate:self];
            if (!_tasks[t].bound)
                [_tasks[t] whenChangePropagate:self];
            if (!_usages[t].bound)
                [_usages[t] whenChangeMinPropagate:self];
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
//        const ORInt t = _index[tt];
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

static void propagationLoopPreamble(CPTaskCumulative* cumu, ORInt* i_max_usage)
{
    // Building the resource profile
    *i_max_usage = tt_build_profile(cumu);
}

-(NSSet*)allVars
{
    NSMutableSet* rv = [[NSMutableSet alloc] initWithCapacity:2 * _size + 1];
    for(ORInt ii = 0; ii < _size; ii++) {
        const ORInt i = _index[ii];
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

// Some declarations
static inline ORInt est        (CPTaskCumulative * cumu, const ORInt t0);
static inline ORInt lst        (CPTaskCumulative * cumu, const ORInt t0);
static inline ORInt ect        (CPTaskCumulative * cumu, const ORInt t0);
static inline ORInt lct        (CPTaskCumulative * cumu, const ORInt t0);
static inline ORInt dur_min    (CPTaskCumulative * cumu, const ORInt t0);
static inline ORInt dur_max    (CPTaskCumulative * cumu, const ORInt t0);
static inline ORInt usage_min  (CPTaskCumulative * cumu, const ORInt t0);
static inline ORInt usage_max  (CPTaskCumulative * cumu, const ORInt t0);
static inline ORInt free_energy(CPTaskCumulative * cumu, const ORInt t0);

static inline ORBool isRelevant(  CPTaskCumulative * cumu, const ORInt t0);
static inline ORBool isIrrelevant(CPTaskCumulative * cumu, const ORInt t0);

static inline ORInt cap_min(CPTaskCumulative * cumu);
static inline ORInt cap_max(CPTaskCumulative * cumu);


// Implementations
static inline ORInt est(CPTaskCumulative * cumu, const ORInt t0)
{
    assert(0 <= t0 && t0 < cumu->_size);
    return cumu->_est[t0];
}

static inline ORInt lst(CPTaskCumulative * cumu, const ORInt t0)
{
    assert(0 <= t0 && t0 < cumu->_size);
    return cumu->_lct[t0] - cumu->_dur_min[t0];
}

static inline ORInt ect(CPTaskCumulative * cumu, const ORInt t0)
{
    assert(0 <= t0 && t0 < cumu->_size);
    return cumu->_est[t0] + cumu->_dur_min[t0];
}

static inline ORInt lct(CPTaskCumulative * cumu, const ORInt t0)
{
    assert(0 <= t0 && t0 < cumu->_size);
    return cumu->_lct[t0];
}

static inline ORInt dur_min(CPTaskCumulative * cumu, const ORInt t0)
{
    assert(0 <= t0 && t0 < cumu->_size);
    return cumu->_dur_min[t0];
}

static inline ORInt dur_max(CPTaskCumulative * cumu, const ORInt t0)
{
    assert(0 <= t0 && t0 < cumu->_size);
    return cumu->_dur_max[t0];
}

static inline ORInt usage_min(CPTaskCumulative * cumu, const ORInt t0)
{
    assert(0 <= t0 && t0 < cumu->_size);
    return cumu->_usage_min[t0];
}

static inline ORInt usage_max(CPTaskCumulative * cumu, const ORInt t0)
{
    assert(0 <= t0 && t0 < cumu->_size);
    return cumu->_usages[t0].max;
}

static inline ORInt area_min(CPTaskCumulative * cumu, const ORInt t0)
{
    assert(0 <= t0 && t0 < cumu->_size);
    return (cumu->_usage_min[t0] * cumu->_dur_min[t0]);
}

static inline ORInt free_energy(CPTaskCumulative * cumu, const ORInt t0)
{
    assert(0 <= t0 && t0 < cumu->_size);
    return  area_min(cumu, t0) - usage_min(cumu, t0) * max(0, ect(cumu, t0) - lst(cumu, t0));
}

static inline ORInt cap_min(CPTaskCumulative * cumu)
{
    return cumu->_cap_min;
}

static inline ORInt cap_max(CPTaskCumulative * cumu)
{
    return cumu->_cap_max;
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


static inline ORBool isPresent(CPTaskCumulative * cumu, const ORInt t0)
{
    assert(0 <= t0 && t0 < cumu->_size);
    return cumu->_present[t0];
}

static inline ORBool isAbsent(CPTaskCumulative * cumu, const ORInt t0)
{
    assert(0 <= t0 && t0 < cumu->_size);
    return cumu->_absent[t0];
}

static inline ORBool isRelevant(CPTaskCumulative * cumu, const ORInt t0)
{
    assert(0 <= t0 && t0 < cumu->_size);
    return (cumu->_present[t0] && cumu->_usage_min[t0] > 0 && cumu->_dur_min[t0] > 0);
}

static inline ORBool isIrrelevant(CPTaskCumulative * cumu, const ORInt t0)
{
    assert(0 <= t0 && t0 < cumu->_size);
    return (cumu->_absent[t0] || cumu->_usage_max[t0] <= 0 || cumu->_dur_max[t0] <= 0);
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

static ORInt tt_build_profile(CPTaskCumulative* cumu)
{
    const ORInt firstPresent = cumu->_indexFirstPresent._val;
    ORInt nbCompParts = 0;
    
    // Determine the number of activities with compulsory parts to be considered
    for (ORInt tt = firstPresent; tt < cumu->_size; tt++) {
        const ORInt t0 = cumu->_index[tt];
        assert(isRelevant(cumu, t0));
        if (lst(cumu, t0) < ect(cumu, t0) && cumu->_begin < ect(cumu, t0) && lst(cumu, t0) < cumu->_end)
            nbCompParts++;
    }
    
    // Check for compulsory parts
    if (nbCompParts == 0)
        return -1;
    
    // Memory allocation
    ProfileChange toSort[2 * nbCompParts];
    ORInt k = 0;   // Number of profile change points
    
    for (ORInt tt = firstPresent; tt < cumu->_size; tt++) {
        const ORInt t0 = cumu->_index[tt];
        assert(isRelevant(cumu, t0));
        if (lst(cumu, t0) < ect(cumu, t0) && cumu->_begin < ect(cumu, t0) && lst(cumu, t0) < cumu->_end) {
            assert(k + 1 < 2 * nbCompParts);
            // Tasks creates a compulsory part
            toSort[k++] = (ProfileChange){lst(cumu, t0),  usage_min(cumu, t0)};
            toSort[k++] = (ProfileChange){ect(cumu, t0), -usage_min(cumu, t0)};
        }
    }
    assert(k == 2 * nbCompParts);
    
    // Sorting the profile change points in ascending order with respect to the time unit
    // and the change as tie breaker
    qsort(toSort, k, sizeof(ProfileChange), (int(*)(const void*, const void*)) &compareProfileChange);

    
    // Building the resource profile
    assert(toSort[0]._change > 0);
    ORInt begin = toSort[0]._time;
    ORInt psize = 0;
    ORInt level = toSort[0]._change;
    ORInt max_peak = 0;
    ORInt max_peak_idx = 0;
    for (ORInt i = 1; i < k; i++) {
        if (toSort[i]._time > begin) {
            if (level > 0) {
                // new profile peak (begin, _time, level)
                cumu->_profile[psize]._begin = begin;
                cumu->_profile[psize]._end   = toSort[i]._time;
                cumu->_profile[psize]._level = level;
                if (max_peak < level) {
                    assert(max_peak = cumu->_profile[max_peak_idx]._level);
                    max_peak_idx = psize;
                    max_peak     = level;
                    if (level > cap_max(cumu)) {
                        cumu->_nb_tt_incons++;
                        //NSLog(@"Cumulative: propagate/0: TT Fail\n");
                        failNow();
                    }
                }
                psize++;
            }
            begin = toSort[i]._time;
        }
        level += toSort[i]._change;
    }
    assert(level == 0);
    assert(cumu->_profile[max_peak_idx]._level == max_peak);
    assert(cumu->_profile[max_peak_idx]._level <= cap_max(cumu));
    cumu->_profileSize = psize;
    
    return max_peak_idx;
}

static inline void tt_filter_cap(CPTaskCumulative* cumu, const ORInt maxLevel)
{
    if (maxLevel > cap_min(cumu))
        [cumu->_capacity updateMin: maxLevel];
}

static void tt_filter_start_end_times(CPTaskCumulative* cumu, const ORInt maxLevel, bool* update)
{
    const ORInt firstUnbound = cumu->_boundFirstUnbound._val;
    const ORInt firstBound   = cumu->_boundFirstBound._val;
    
    ORInt maxCapacity = cap_max(cumu);
    ORInt index = 0;    // Profile index
    for (ORInt tt = firstUnbound; tt < firstBound; tt++) {
        const ORInt t0 = cumu->_bound[tt];
        
        // Check whether an update is possible
        if (maxLevel + usage_min(cumu, t0) > maxCapacity && dur_min(cumu, t0) > 0) {
            
            /* Determining a new earliest start time for the task i */

            ORInt new_est = est(cumu, t0);

            // Binary search for index
            index = find_first_profile_peak_for_lb(cumu->_profile, new_est, 0, cumu->_profileSize - 1);
            // Determining the new earliest start time
            for (ORInt p = index; p < cumu->_profileSize; p++) {
                //printf("profile %d\n", p);
                // Check whether a better lower bound is still possible
                if (new_est + dur_min(cumu, t0) <= cumu->_profile[p]._begin) {
                    break;
                }
                assert(new_est + dur_min(cumu, t0) > cumu->_profile[p]._begin);
                // Check whether an earliest execution would overlap with the profile peak
                // and would cause an resource overload
                if (new_est < cumu->_profile[p]._end && usage_min(cumu, t0) + cumu->_profile[p]._level > maxCapacity) {
                    // Check whether the task does not have a compulsory part in the profile peak
                    if (!(lst(cumu, t0) < ect(cumu, t0) && lst(cumu, t0) <= cumu->_profile[p]._begin &&
                          cumu->_profile[p]._end <= ect(cumu, t0))) {
                        // A new earliest start time
                        new_est = cumu->_profile[p]._end;
                    }
                }
            }
            // Imposing the new earliest start time
            if (new_est > est(cumu, t0)) {
                const ORInt t = t0 + cumu->_low;
                cumu->_nb_tt_props++;
                [cumu->_tasks[t] updateStart:new_est];
                *update = true;
            }
            
            
            /* Determining a new lastest end time for the task i */
            
            ORInt new_lct = lct(cumu, t0);

            // Binary search for the index
            index = find_first_profile_peak_for_ub(cumu->_profile, new_lct, 0, cumu->_profileSize - 1);
            
            // Determining the new latest completion time
            for (ORInt p = index; p >= 0; p--) {
                // Check whether a better upper bound is still possible
                if (cumu->_profile[p]._end <= new_lct - dur_min(cumu, t0)) {
                    break;
                }
                assert(cumu->_profile[p]._end > new_lct - dur_min(cumu, t0));
                // Check whether a latest execution would overlap with the profile peak
                // and would cause an resource overload
                if (cumu->_profile[p]._begin < new_lct && cumu->_profile[p]._level + usage_min(cumu, t0) > maxCapacity) {
                    // Check whether the task does not have a compulsory part in the profile peak
                    if (!(lst(cumu, t0) < ect(cumu, t0) && lst(cumu, t0) <= cumu->_profile[p]._begin &&
                          cumu->_profile[p]._end <= ect(cumu, t0))) {
                        // A new latest completion time
                        new_lct = cumu->_profile[p]._begin;
                    }
                }
            }
            // Imposing the new latest completion time
            if (new_lct < lct(cumu, t0)) {
                const ORInt t = t0 + cumu->_low;
                cumu->_nb_tt_props++;
                [cumu->_tasks[t] updateEnd:new_lct];
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


static void ttef_initialise_parameters(CPTaskCumulative* cumu, ORInt* task_id_est, ORInt* task_id_lct, ORInt* ttEnAfterEst, ORInt* ttEnAfterLct, const ORInt unboundSize)
{
    assert(unboundSize > 0);
    
    // Initialisation
    for (ORInt tt = 0, ii = cumu->_boundFirstUnbound._val; tt < unboundSize; tt++, ii++) {
        task_id_est[tt] = cumu->_bound[ii];
        task_id_lct[tt] = cumu->_bound[ii];
    }
    
    // Sorting the tasks in non-decreasing order by the earliest start time
    qusort_r(task_id_est, unboundSize, cumu, (ORInt(*)(void *, const ORInt *, const ORInt *)) &sortEstAsc);
    // Sorting the tasks in non-decreasing order by the latest completion time
    qusort_r(task_id_lct, unboundSize, cumu, (ORInt(*)(void *, const ORInt *, const ORInt *)) &sortLctAsc);

    // Calculation of ttEnAfterEst and ttEnAfterLct
    if (cumu->_profileSize == 0) {
        for (ORInt tt = 0; tt < unboundSize; tt++) {
            ttEnAfterEst[tt] = 0;
            ttEnAfterLct[tt] = 0;
        }
    }
    else {
        ProfilePeak * profile = cumu->_profile;
        ORInt energy = 0;
        ORInt p = cumu->_profileSize - 1;
       
        // Calculation of ttEnAfterEst
        for (ORInt tt = unboundSize - 1; tt >= 0; tt--) {
            const ORInt t0 = task_id_est[tt];
            if (p < 0 || profile[p]._end <= est(cumu, t0)) {
                ttEnAfterEst[tt] = energy;
            }
            else if (profile[p]._begin <= est(cumu, t0)) {
                ttEnAfterEst[tt] = energy + profile[p]._level * (profile[p]._end - est(cumu, t0));
            }
            else {
                assert(profile[p]._begin > est(cumu, t0));
                energy += profile[p]._level * (profile[p]._end - profile[p]._begin);
                p--;
                tt++;
            }
        }
        
        // Calculation of ttEnAfterLct
        energy = 0;
        p = cumu->_profileSize - 1;
        
        for (ORInt tt = unboundSize - 1; tt >= 0; tt--) {
            const ORInt t0 = task_id_lct[tt];
            if (p < 0 || profile[p]._end <= lct(cumu, t0)) {
                ttEnAfterLct[tt] = energy;
            }
            else if (profile[p]._begin <= lct(cumu, t0)) {
                ttEnAfterLct[tt] = energy + profile[p]._level * (profile[p]._end - lct(cumu, t0));
            }
            else {
                assert(profile[p]._begin > lct(cumu, t0));
                energy += profile[p]._level * (profile[p]._end - profile[p]._begin);
                p--;
                tt++;
            }
        }
    }
}

    // Specialised TTEF consistency check which can detect dominated time intervals and
    // skip them
    // Time complexity: O(u^2) where u is the number of unfixed tasks
    // Space complexity: O(u)
static void ttef_consistency_check(CPTaskCumulative * cumu, const ORInt * task_id_est, const ORInt * task_id_lct,
    const ORInt * ttEnAfterEst, const ORInt * ttEnAfterLct, const ORInt unboundSize,
    ORInt shift_in(const ORInt, const ORInt, const ORInt, const ORInt, const ORInt, const ORInt, const ORInt))
{
    assert(unboundSize >= 0);
    
    ORInt begin, end;   // Begin and end time of the interval [begin, end)
    ORInt est_idx_last = unboundSize - 1;
    ORUInt i, j;        // Task that determines the end time (i) and the start time (j)
                        // of the interval
    ORUInt en_req_free; // Accumulated required free energy for the intervals [., end)
    
    // TTEF dominance skipping rule
    // - bookkeeping variables
#if TTEFDOMRULESKIP
    ORInt minAvail = -1;    // Minimal available energy of an interval ending at end
    ORInt ii_min   = -1;    // Index of task_id_lct pointing to the task id determining that end
#endif
    
    end = MAXINT;
    
    // Outer loop: Iteration over the end times of the intervals
    //
    for (ORUInt ii = unboundSize; ii--;) {
        i = task_id_lct[ii];
        if (!isRelevant(cumu, i) || end == lct(cumu, i)) continue;
        
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
            
            if (!isRelevant(cumu, j)) continue;
            
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
            assert(0 <= jj && jj < unboundSize);
            ORInt en_req = en_req_free + ttEnAfterEst[jj] - ttEnAfterLct[ii];
            ORInt en_avail = cap_max(cumu) * (end - begin) - en_req;
            
            // Checking for a rresource overload
            if (en_avail < 0) {
//                printf("Resource overload in [%d, %d)\n", begin, end);
//                printf("\tcap %d; en_req_free %d; ttBegin %d; ttEnd %d;\n", cap_max(cumu), en_req_free, ttEnAfterEst[jj], ttEnAfterLct[ii]);
//                for (ORInt kk = 0; kk < cumu->_size; kk++) {
//                    dumpTask(cumu, kk);
//                }
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
    ORInt* ttEnAfterEst, ORInt* ttEnAfterLct, const ORInt unboundSize,
    ORInt shift_in1(const ORInt, const ORInt, const ORInt, const ORInt, const ORInt, const ORInt, const ORInt),
    ORInt shift_in2(const ORInt, const ORInt, const ORInt, const ORInt, const ORInt, const ORInt, const ORInt),
    bool* update)
{
    assert(unboundSize > 0);
    
    const ORInt firstUnbound = cumu->_boundFirstUnbound._val;
    const ORInt firstBound   = cumu->_boundFirstBound._val;

    // Allocation of memory for recording the new bounds
    ORInt new_cap_min = cap_min(cumu);
    ORInt new_est[cumu->_size];
    ORInt new_lct[cumu->_size];

    // Initialisation of the arrays
    for (ORInt tt = firstUnbound; tt < firstBound; tt++) {
        const ORInt t0 = cumu->_bound[tt];
        new_est[t0] = est(cumu, t0);
        new_lct[t0] = lct(cumu, t0);
    }

    // TTEF propagation of the start times
    ttef_filter_start_times(cumu, task_id_est, task_id_lct, ttEnAfterEst, ttEnAfterLct, unboundSize, new_est, new_lct, &new_cap_min, shift_in1, update);
    // TTEF propagaiton of the end times
    ttef_filter_end_times(cumu, task_id_est, task_id_lct, ttEnAfterEst, ttEnAfterLct, unboundSize, new_est, new_lct, &new_cap_min, shift_in2, update);

    // Updating the bounds
    for (ORInt tt = firstUnbound; tt < firstBound; tt++) {
        const ORInt t0 = cumu->_bound[tt];
        const ORInt t  = t0 + cumu->_low;
        if (new_est[t0] > est(cumu, t0))
            [cumu->_tasks[t] updateStart:new_est[t0]];
        if (new_lct[t0] < lct(cumu, t0))
            [cumu->_tasks[t] updateEnd:new_lct[t0]];
    }
    if (new_cap_min > cap_min(cumu))
        [cumu->_capacity updateMin:new_cap_min];
}

static void ttef_filter_start_times(CPTaskCumulative* cumu, const ORInt* task_id_est, const ORInt* task_id_lct,
    const ORInt* ttEnAfterEst, const ORInt* ttEnAfterLct, const ORInt unboundSize, ORInt* new_est, ORInt* new_lct, ORInt * new_cap_min,
    ORInt shift_in(const ORInt, const ORInt, const ORInt, const ORInt, const ORInt, const ORInt, const ORInt),
    bool* update)
{
    assert(unboundSize > 0);
    
    ORInt begin, end;   // Begin and end time of the interval [begin, end)
    ORInt est_idx_last = unboundSize - 1;
    ORUInt i, j;        // Task that determines the end time (i) and the start time (j) of the interval
    ORUInt en_req_free; // Accumulated required free energy for the intervals [., end)
    
    ORInt update_en_req_start;
    ORInt update_idx = 0;
    
#if (TTEEFABSOLUTEPROP || TTEEFDENSITYPROP)
    ORInt min_en_avail_init;
    min_en_avail_init = cap_max(cumu) * (lct(cumu, task_id_lct[unboundSize - 1]) - est(cumu, task_id_est[0]));
#endif
#if TTEEFABSOLUTEPROP
    ORInt min_begin;
#endif
#if TTEEFDENSITYPROP
    ORInt min_density_begin;
    ORInt min_density;
#endif

    end = MAXINT;
    
    // Outer loop: Iteration over the end times of the interval
    //
    for (ORUInt ii = unboundSize; ii--; ) {
        i = task_id_lct[ii];
        
        // Check whether time intervals with the same end time have already been checked
        if (!isRelevant(cumu, i) || end == lct(cumu, i))
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
        update_idx = unboundSize;
        
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
            
            // Skip activities without area
            if (area_min(cumu, j) <= 0)
                continue;
            
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
            
            if (!isPresent(cumu, j)) {
                const ORInt en_req = en_req_free + ttEnAfterEst[jj] - ttEnAfterLct[ii];
                const ORInt en_avail = cap_max(cumu) * (end - begin) - en_req;
                tteef_filter_start_times_in_interval(cumu, new_est, j, begin, end, en_avail, update);
                continue;
            }
            
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
                // Calculation of the required energy for starting at est(j)
                ORInt en_req_start = min(free_energy(cumu, j), usage_min(cumu, j) * (end - est(cumu, j))) - usage_min(cumu, j) * dur_shift;
                if (en_req_start > update_en_req_start) {
                    update_en_req_start = en_req_start;
                    update_idx = jj;
                }
            }
            
            // Computing the total required energy in the interval [begin, end)
            const ORInt en_req = en_req_free + ttEnAfterEst[jj] - ttEnAfterLct[ii];
            const ORInt en_avail = cap_max(cumu) * (end - begin) - en_req;
            
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
                *new_cap_min = max(*new_cap_min, cap_max(cumu) - approx_density);
            }
#endif
            
            // Check for a start time update
            if (en_avail < update_en_req_start) {
                assert(update_en_req_start > 0);
                assert(0 <= update_idx && update_idx < unboundSize);
                
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
    const ORInt* ttEnAfterEst, const ORInt* ttEnAfterLct, const ORInt unboundSize, ORInt* new_est, ORInt* new_lct, ORInt * new_cap_min,
    ORInt shift_in(const ORInt, const ORInt, const ORInt, const ORInt, const ORInt, const ORInt, const ORInt),
    bool* update)
{
    ORUInt i, j;
    ORInt begin, end;
    ORUInt en_req_free;
    ORInt update_en_req_end;
    ORInt lct_idx_last = 0;
    ORInt update_idx;
    
    begin = MININT;
    
#if (TTEEFABSOLUTEPROP || TTEEFDENSITYPROP)
    ORInt min_en_avail_init;
    min_en_avail_init = cap_max(cumu) * (lct(cumu, task_id_lct[unboundSize - 1]) - est(cumu, task_id_est[0]));
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
    for (ORUInt ii = 0; ii < unboundSize; ii++) {
        i = task_id_est[ii];
        if (!isRelevant(cumu, i) || begin == est(cumu, i)) continue;
        
        begin = est(cumu, i);
        
        // Finding the first index for the inner loop
        while (lct(cumu, task_id_lct[lct_idx_last]) <= begin) lct_idx_last++;
        
        // Initialisation for the inner loop
        en_req_free = 0;
        update_idx = unboundSize;
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
        for (ORUInt jj = lct_idx_last; jj < unboundSize; jj++) {
            j = task_id_lct[jj];
            if (area_min(cumu, j) <= 0) continue;
            assert(begin < lct(cumu, j));
            
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

            end = lct(cumu, j);
            
            if (!isPresent(cumu, j)) {
                const ORInt en_req = en_req_free + ttEnAfterEst[ii] - ttEnAfterLct[jj];
                const ORInt en_avail = cap_max(cumu) * (end - begin) - en_req;
                tteef_filter_end_times_in_interval(cumu, new_lct, j, begin, end, en_avail, update);
                continue;
            }
            
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
                *new_cap_min = max(*new_cap_min, cap_max(cumu) - approx_density);
            }
#endif
            
            // Check for a start time update
            //
            if (en_avail < update_en_req_end) {
                assert(update_en_req_end > 0);
                assert(0 <= update_idx && update_idx < unboundSize);
                
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
    assert(area_min(cumu, j) > 0);
    if (isPresent(cumu, j)) {
        const ORInt free_ect = (lst(cumu, j) < ect(cumu, j) ? lst(cumu, j) : ect(cumu, j));
        
        // TTEEF bounds propagation for task j with respect to the time interval [begin, .)
        const ORInt min_en_req = usage_min(cumu, j) * (min(tw_end, free_ect) - max(tw_begin, est(cumu, j)));
        
        if (tw_end < MAXINT && en_avail < min_en_req) {
            assert(free_ect > tw_begin);
            // Calculate the new lower bound
            const ORInt dur_cp_in = max(0, min(tw_end, ect(cumu, j)) - max(tw_begin, lst(cumu, j)));
            const ORInt dur_avail = (en_avail / usage_min(cumu, j)) + dur_cp_in;
            const ORInt est_new = tw_end - dur_avail;
            // Check whether a new lower bound was found
            if (est_new > new_est[j]) {
                cumu->_nb_ttef_props++;
                *update = true;
                new_est[j] = est_new;
            }
        }
    }
    else {
        assert(!isAbsent(cumu, j));
        const ORInt min_en_req = usage_min(cumu, j) * (min(tw_end, ect(cumu, j)) - max(tw_begin, est(cumu, j)));
        
        if (tw_end < MAXINT && en_avail < min_en_req) {
            assert(ect(cumu, j) > tw_begin);
            // Calculate the new lower bound
            const ORInt dur_avail = en_avail / usage_min(cumu, j);
            const ORInt est_new = tw_end - dur_avail;
            // Check whether a new lower bound was found
            if (est_new > new_est[j]) {
                cumu->_nb_ttef_props++;
                *update = true;
                new_est[j] = est_new;
            }
        }
    }
}

static void tteef_filter_end_times_in_interval(CPTaskCumulative* cumu, ORInt* new_lct, const ORInt j, const ORInt tw_begin, const ORInt tw_end, const ORInt en_avail, bool* update) {
    assert(area_min(cumu, j) > 0);
    if (isPresent(cumu, j)) {
        const ORInt free_lst = (lst(cumu, j) < ect(cumu, j) ? ect(cumu, j) : lst(cumu, j));
        // TTEEF bounds propagation for task j with respect to the time interval [., end)
        const ORInt min_en_req = usage_min(cumu, j) * (min(tw_end, lct(cumu, j)) - max(tw_begin, free_lst));
        
        if (tw_begin > MININT && en_avail < min_en_req) {
            assert(free_lst < tw_end);
            // Calculate the new upper bound
            const ORInt dur_cp_in = max(0, min(tw_end, ect(cumu, j)) - max(tw_begin, lst(cumu, j)));
            const ORInt dur_avail = (en_avail / usage_min(cumu, j)) + dur_cp_in;
            const ORInt lct_new = tw_begin + dur_avail;
            // Check whether a new upper bound was found
            if (lct_new < new_lct[j]) {
                cumu->_nb_ttef_props++;
                *update = true;
                // Push possible update into queue
                new_lct[j] = lct_new;
            }
        }
    }
    else {
        assert(!isAbsent(cumu, j));
        const ORInt min_en_req = usage_min(cumu, j) * (min(tw_end, lct(cumu, j)) - max(tw_begin, lst(cumu, j)));
        
        if (tw_begin > MININT && en_avail < min_en_req) {
            // Calculate the new upper bound
            const ORInt dur_avail = en_avail / usage_min(cumu, j);
            const ORInt lct_new   = tw_begin + dur_avail;
            // Check whether a new upper bound was found
            if (lct_new < new_lct[j]) {
                cumu->_nb_ttef_props++;
                *update = true;
                // Push possible update into queue
                new_lct[j] = lct_new;
            }
        }
    }
}


    // Main method for the time-tabling-edge-finding (TTEF) propagation
    //
static void ttef_bounds_propagation(CPTaskCumulative* cumu, bool* update)
{
    assert(cumu->_ttef_check || cumu->_ttef_filt);
    
    const ORInt unboundSize = cumu->_boundFirstBound._val - cumu->_boundFirstUnbound._val;
    if (unboundSize <= 0)
        return ;
    
    ORInt task_id_est[unboundSize];     // Unbound activities order wrt. their est
    ORInt task_id_lct[unboundSize];     // Unbound activities order wrt. their lct
    ORInt ttEnAfterEst[unboundSize];
    ORInt ttEnAfterLct[unboundSize];
    
    // Initialise all the parameters
    ttef_initialise_parameters(cumu, task_id_est, task_id_lct, ttEnAfterEst, ttEnAfterLct, unboundSize);
    
    if (cumu->_ttef_filt) {
        // TTEF bounds filtering incl. consistency check
#if TTEFLEFTRIGHTSHIFT
        ttef_filter_start_and_end_times(cumu, task_id_est, task_id_lct, ttEnAfterEst, ttEnAfterLct, unboundSize,get_free_dur_right_shift, get_free_dur_left_shift, update);
#else
        ttef_filter_start_and_end_times(cumu, task_id_est, task_id_lct, ttEnAfterEst, ttEnAfterLct, unboundSize, get_no_shift, get_no_shift, update);
#endif
    } else {
        assert(cumu->_ttef_check);
        // TTEF consistency check
#if TTEFLEFTRIGHTSHIFT
        ttef_consistency_check(cumu, task_id_est, task_id_lct, ttEnAfterEst, ttEnAfterLct, unboundSize, get_free_dur_right_shift);
#else
        ttef_consistency_check(cumu, task_id_est, task_id_lct, ttEnAfterEst, ttEnAfterLct, unboundSize, get_no_shift);
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
    // Reading the data
    readData(cumu);
    // Update indices
    updateIndices(cumu);
    
    const ORInt firstPresent = cumu->_indexFirstPresent._val;
    const ORInt size = cumu->_size - firstPresent;

    ORInt ectA  [size];
    ORInt id_est[size];
    ORInt id_ect[size];
    
    // Initialisation of the arrays
    for (ORInt tt = firstPresent; tt < cumu->_size; tt++) {
        const ORInt i = tt - firstPresent;
        const ORInt t0 = cumu->_index[tt];
        id_est[i ] = t0;
        id_ect[i ] = t0;
        ectA  [t0] = ect(cumu, t0);
    }
    
    // Sorting the tasks in non-decreasing order by the earliest start time
    qusort_r(id_est, size, cumu, (ORInt (*)(void *, const ORInt *, const ORInt *)) &sortEstAsc);
    // Sorting the tasks in non-decreasing order by the latest completion time
    qusort_r(id_ect, size, cumu, (ORInt (*)(void *, const ORInt *, const ORInt *)) &sortEctAsc);

    Profile prof = getEarliestContentionProfile(id_est, id_ect, cumu->_est, ectA, cumu->_usage_min, size);
    
    return prof;
}

/*******************************************************************************
 Computation of the partial order
 ******************************************************************************/

static CPTaskVarPrec * cumuGetPartialOrder(CPTaskCumulative * cumu, ORInt * psize)
{
    // Assumptions:
    // - No unbounded activity
    // - activities are either present or absent
    assert(cumu->_boundFirstBound._val == cumu->_boundFirstBound._val);
    assert(cumu->_indexFirstPresent._val == cumu->_indexFirstUnknown._val);
    
    const ORInt firstPresent = cumu->_indexFirstPresent._val;
    const ORInt presentSize = cumu->_size - firstPresent;
    
    ORInt id_est[presentSize];
    ORInt id_ect[presentSize];
    
    CPTaskVarPrec * prec = NULL;

    ORInt cap  = 0;
    ORInt size = 0;

    // Initialisation of the arrays
    for (ORInt tt = firstPresent; tt < cumu->_size; tt++) {
        const ORInt i  = tt - firstPresent;
        const ORInt t0 = cumu->_index[tt];
        id_est[i] = t0;
        id_ect[i] = t0;
    }
    
    // Sorting the tasks in non-decreasing order by the earliest start time
    qusort_r(id_est, size, cumu, (ORInt (*)(void *, const ORInt *, const ORInt *)) &sortEstAsc);
    // Sorting the tasks in non-decreasing order by the latest completion time
    qusort_r(id_ect, size, cumu, (ORInt (*)(void *, const ORInt *, const ORInt *)) &sortEctAsc);
    
    ORInt tt1  = 0;
    ORInt tt2  = 0;
    ORInt time = MININT;
    NSMutableSet * prevAct = [[NSMutableSet alloc] init];
    
    while (tt1 < presentSize) {
        assert(tt1 < presentSize);
        assert(tt2 < presentSize);
        
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
                prec[size]._before = cumu->_tasks[t1 + cumu->_low];
                prec[size]._after  = cumu->_tasks[(ORInt) [num intValue]];
                size++;
            }
            tt1++;
        } else {
            // time1 >= time2
            // Clearing the set
            if (time < time2) [prevAct removeAllObjects];
            // Adding 't2' to the set
            NSNumber * n2 = [NSNumber numberWithInt:t2 + cumu->_low];
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

static void dumpTask(CPTaskCumulative * cumu, ORInt t0) {
    printf("task %d: est %d; ect %d; lst %d; lct %d; dur_min %d; usage_min %d;", t0, cumu->_est[t0], cumu->_est[t0] + cumu->_dur_min[t0], cumu->_lct[t0] - cumu->_dur_min[t0], cumu->_lct[t0], cumu->_dur_min[t0], cumu->_usage_min[t0]);
    printf(" present %d; absent %d;\n", cumu->_present[t0], cumu->_absent[t0]);
//    printf(" MT %d\n", cumu->_machineTask[t0]);
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
    // array '_index' is partitioned in [Absent | Unknown | Present]
    ORInt firstUnknown = cumu->_indexFirstUnknown._val;
    ORInt firstPresent = cumu->_indexFirstPresent._val;
    
    // Update indices array
    for (ORInt tt = firstUnknown; tt < firstPresent; tt++) {
        const ORInt t0 = cumu->_index[tt];
        if (isIrrelevant(cumu, t0))
            swapORInt(cumu->_index, firstUnknown++, tt);
        else if (isRelevant(cumu, t0))
            swapORInt(cumu->_index, --firstPresent, tt--);
    }
    
    // Trail indices pointers
    if (firstUnknown > cumu->_indexFirstUnknown._val)
        assignTRInt(&(cumu->_indexFirstUnknown), firstUnknown, cumu->_trail);
    if (firstPresent < cumu->_indexFirstPresent._val)
        assignTRInt(&(cumu->_indexFirstPresent), firstPresent, cumu->_trail);
}

// Reading the activities data and storing them in the data structure of the propagator
// - Data read: bound, est,  lct, minDuration, maxDuration,   minUsage,   maxUsage, present,  absent
// - Data stored:     _est, _lct,    _dur_min,    _dur_max, _usage_min, _usage_max, _present, _absent
static void readData(CPTaskCumulative * cumu)
{
    // array '_bound' is partition in [ Irrelevant | Unbound | Bound ]
    ORInt firstUnbound = cumu->_boundFirstUnbound._val;
    ORInt firstBound   = cumu->_boundFirstBound._val;
    
    // Relevant time horizon for propagation and consistency check
    cumu->_begin = MAXINT;
    cumu->_end   = MAXINT;
    
    // Retrieve all necessary data from the activities
    for (ORInt tt = firstUnbound; tt < firstBound; tt++) {
        const ORInt t0 = cumu->_bound[tt];
        const ORInt t  = t0 + cumu->_low;
        ORBool bound;
        
        [cumu->_tasks[t] readEssentials:&bound est:&(cumu->_est[t0]) lct:&(cumu->_lct[t0]) minDuration:&(cumu->_dur_min[t0]) maxDuration:&(cumu->_dur_max[t0]) present:&(cumu->_present[t0]) absent:&(cumu->_absent[t0])];
        cumu->_usage_min[t0] = cumu->_usages[t].min;
        cumu->_usage_max[t0] = cumu->_usages[t].max;
        
        // Swap bounded or irrelevant tasks to the beginning of the array
        if (isIrrelevant(cumu, t0)) {
            swapORInt(cumu->_bound, firstUnbound++, tt);
            continue;
        }
        if (bound && cumu->_usage_max[t0] - cumu->_usage_min[t0] == 0)
            swapORInt(cumu->_bound, --firstBound, tt--);
        
        // Update the relevant time horizon
        cumu->_begin = min(cumu->_begin, est(cumu, t0));
        cumu->_end   = max(cumu->_end  , lct(cumu, t0));
    }
    
    // Trail indices pointers
    if (firstUnbound > cumu->_boundFirstUnbound._val)
        assignTRInt(&(cumu->_boundFirstUnbound), firstUnbound, cumu->_trail);
    if (firstBound < cumu->_boundFirstBound._val)
        assignTRInt(&(cumu->_boundFirstBound), firstBound, cumu->_trail);
    
    // Update resource capacity
    cumu->_cap_min = cumu->_capacity.min;
    cumu->_cap_max = cumu->_capacity.max;
}

/*******************************************************************************
 Main Propagation Loop
 ******************************************************************************/

static void doPropagation(CPTaskCumulative * cumu)
{
//    NSLog(@"Cumulative: propagate/0: Start\n");
    bool update = false;
    
    // Read/update data
    readData(cumu);
    
    // Update the indices
    updateIndices(cumu);
    
    // Generation of the resource profile and TT consistency check
    const ORInt i_max_usage = tt_build_profile(cumu);
    
    if (i_max_usage >= 0) {
        assert(i_max_usage < cumu->_profileSize);

        const ORInt maxLevel = cumu->_profile[i_max_usage]._level;
        // TT filtering on resource capacity variable
        tt_filter_cap(cumu, maxLevel);
        // TT filtering on start and end times variables
        if (cumu->_tt_filt)
            tt_filter_start_end_times(cumu, maxLevel, & update);
        // TTEF propagation
        if (!update && (cumu->_ttef_check || cumu->_ttef_filt)) {
            ttef_bounds_propagation(cumu, & update);
        }
    }
//    NSLog(@"Cumulative: propagate/0: End\n");
}

@end
