/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Andreas Schutt and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "CPTaskCumulative.h"
#import <objcp/CPIntVarI.h>
#import <CPUKernel/CPEngineI.h>
#import "CPTask.h"
#import "CPTaskI.h"
#import "CPMisc.h"


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
#define TTEFMAXAREAPROP 1


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
    ORInt  * _lst;       // Latest starting time
    ORInt  * _ect;       // Earliest completion time
    ORInt  * _lct;       // Latest completion time
    ORInt  * _dur_min;   // Minimal duration
    ORInt  * _dur_max;   // Maximal duration
    ORInt  * _usage_min; // Minimal resource usage
    ORInt  * _usage_max; // Maximal resource usage
    ORInt  * _area_min;  // Minimal resource usage
    ORInt  * _area_max;  // Maximal resource usage
    ORBool * _present;   // Whether the activity is present
    ORBool * _absent;    // Whether the activity is absent
    
    ORBool * _resourceTask; // Resource task
    ORBool   _resourceTaskAsOptional;
    
    // Relevant time horizon
    ORInt    _begin;    // Start time of the horizon considered during propagation
    ORInt    _end;      // End time of the horizon considered during propagation

    ORInt * _index;                 // Normalised activities' ID in [Irrelevant | Unknown | Present | PresentRT | UnknownRT | IrrelevantRT]
    TRInt   _indexFirstUnknown;     // Size of present activities
    TRInt   _indexFirstPresent;     // Size of present and non-present activities
    TRInt   _indexFirstUnknownRT;   // Index of first unknown resource activity
    TRInt   _indexFirstIrrelevantRT;// Index of first irrelevant resource activity
    
    ORInt * _bound;                 // Activities' ID sorted in [Irrelevant | Unbound | Bound | BoundRT | UnboundRT | IrrelevantRT]
    TRInt   _boundFirstUnbound;     // Index of first unbound activity
    TRInt   _boundFirstBound;       // Index of first bound activity
    TRInt   _boundFirstUnboundRT;   // Index of first unbound resource activity
    TRInt   _boundFirstIrrelevantRT;// Index of first irrelevant resource activity
    
    ORInt   _firstRT;
    
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
    ORULong _nb_ttef_area_props;

}

-(id) initCPTaskCumulative: (id<CPTaskVarArray>)tasks with:(id<CPIntVarArray>)usages area:(id<CPIntVarArray>)area capacity:(id<CPIntVar>)capacity
{
    // Checking whether the number of activities is within the limit
    if (tasks.count > (NSUInteger) MAXNBTASK) {
        @throw [[ORExecutionError alloc] initORExecutionError: "CPTaskCumulative: Number of elements exceeds beyond the limit!"];
    }

    // Checking whether the size and indices of the arrays tasks and usages are consistent
    if (tasks.count != usages.count || tasks.low != usages.low || tasks.up != usages.up) {
        @throw [[ORExecutionError alloc] initORExecutionError: "CPTaskCumulative: the arrays 'tasks' and 'usages' must have the same size and indices!"];
    }

    // Checking whether the size and indices of the arrays tasks and area are consistent
    if (area != NULL && (tasks.count != area.count || tasks.low != area.low || tasks.up != area.up)) {
        @throw [[ORExecutionError alloc] initORExecutionError: "CPTaskCumulative: the arrays 'tasks' and 'area' must have the same size and indices!"];
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
    
    // Priority in the propagation queue
    _priority = LOWEST_PRIO;
    
    // Input data structures
    _tasks    = tasks;
    _resTasks = NULL;
    _usages   = usages;
    _area     = area;
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
    _nb_ttef_area_props  = 0;

    // Initialisation of other data structures
    _bound   = NULL;
    _index   = NULL;
    _profile = NULL;

    // Resource tasks
    _resourceTask = NULL;
    _resourceTaskAsOptional = false;

    return self;
}
-(id) initCPTaskCumulative:(id<CPTaskVarArray>)tasks resourceTasks:(id<ORIntArray>)resTasks with:(id<CPIntVarArray>)usages area:(id<CPIntVarArray>)area capacity:(id<CPIntVar>)capacity
{
    // Checking whether the number of activities is within the limit
    if (tasks.count > (NSUInteger) MAXNBTASK) {
        @throw [[ORExecutionError alloc] initORExecutionError: "CPTaskCumulative: Number of elements exceeds beyond the limit!"];
    }
    
    // Checking whether the size and indices of the arrays tasks and usages are consistent
    if (tasks.count != usages.count || tasks.low != usages.low || tasks.up != usages.up) {
        @throw [[ORExecutionError alloc] initORExecutionError: "CPTaskCumulative: the arrays 'tasks' and 'usages' must have the same size and indices!"];
    }
    
    // Checking whether the size and indices of the arrays tasks and area are consistent
    if (area != NULL && (tasks.count != area.count || tasks.low != area.low || tasks.up != area.up)) {
        @throw [[ORExecutionError alloc] initORExecutionError: "CPTaskCumulative: the arrays 'tasks' and 'area' must have the same size and indices!"];
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
    _resTasks = resTasks;
    _usages   = usages;
    _area     = area;
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
    _nb_ttef_area_props  = 0;
    
    // Initialisation of other data structures
    _bound   = NULL;
    _index   = NULL;
    _profile = NULL;
    
    // Resource tasks
    _resourceTask = NULL;
    _resourceTaskAsOptional = false;
    
    return self;
}

-(void) dealloc
{
    printf("%%%% #TT fails: %lld\n",   _nb_tt_incons  );
    printf("%%%% #TT props: %lld\n",   _nb_tt_props   );
    printf("%%%% #TTEF fails: %lld\n", _nb_ttef_incons);
    printf("%%%% #TTEF props: %lld\n", _nb_ttef_props );
    printf("%%%% #TTEF area props: %lld\n", _nb_ttef_area_props);
    printf("\n");

    if (_est          != NULL) free(_est         );
    if (_lst          != NULL) free(_lst         );
    if (_ect          != NULL) free(_ect         );
    if (_lct          != NULL) free(_lct         );
    if (_dur_min      != NULL) free(_dur_min     );
    if (_dur_max      != NULL) free(_dur_max     );
    if (_usage_min    != NULL) free(_usage_min   );
    if (_usage_max    != NULL) free(_usage_max   );
    if (_area_min     != NULL) free(_area_min    );
    if (_area_max     != NULL) free(_area_max    );
    if (_present      != NULL) free(_present     );
    if (_absent       != NULL) free(_absent      );
    if (_bound        != NULL) free(_bound       );
    if (_index        != NULL) free(_index       );
    if (_profile      != NULL) free(_profile     );
    if (_resourceTask != NULL) free(_resourceTask);
    
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
    
    // Allocating memory
    _est          = malloc(_size * sizeof(ORInt ));
    _lst          = malloc(_size * sizeof(ORInt ));
    _ect          = malloc(_size * sizeof(ORInt ));
    _lct          = malloc(_size * sizeof(ORInt ));
    _dur_min      = malloc(_size * sizeof(ORInt ));
    _dur_max      = malloc(_size * sizeof(ORInt ));
    _usage_min    = malloc(_size * sizeof(ORInt ));
    _usage_max    = malloc(_size * sizeof(ORInt ));
    _area_min     = malloc(_size * sizeof(ORInt ));
    _area_max     = malloc(_size * sizeof(ORInt ));
    _present      = malloc(_size * sizeof(ORBool));
    _absent       = malloc(_size * sizeof(ORBool));
    _resourceTask = malloc(_size * sizeof(ORBool));
    
    if (_est == NULL || _lct == NULL || _dur_min == NULL || _dur_max == NULL
        || _usage_min == NULL || _usage_max == NULL || _area_min == NULL || _area_max == NULL
        || _present == NULL || _absent == NULL || _resourceTask == NULL
        || _lst == NULL || _ect == NULL)
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
    ORInt idx_normal = 0;
    _firstRT         = _size;
    for (ORInt t0 = 0; t0 < _size; t0++) {
        const ORInt t = t0 +  _low;
        _resourceTask[t0] = (_resTasks != NULL && [_resTasks at:t] == 1);
        if (!_resourceTaskAsOptional && _resourceTask[t0]) {
            _firstRT--;
            _bound[_firstRT] = t0;
            _index[_firstRT] = t0;
        }
        else {
            _bound[idx_normal] = t0;
            _index[idx_normal] = t0;
            idx_normal++;
        }
    }
    assert(idx_normal == _firstRT);
    assert(!_resourceTaskAsOptional || _firstRT == _size);
    
    // Initialising trailed variables
    _boundFirstUnbound      = makeTRInt(_trail, 0       );
    _boundFirstBound        = makeTRInt(_trail, _firstRT);
    _boundFirstUnboundRT    = makeTRInt(_trail, _firstRT);
    _boundFirstIrrelevantRT = makeTRInt(_trail, _size   );
    _indexFirstUnknown      = makeTRInt(_trail, 0       );
    _indexFirstPresent      = makeTRInt(_trail, _firstRT);
    _indexFirstUnknownRT    = makeTRInt(_trail, _firstRT);
    _indexFirstIrrelevantRT = makeTRInt(_trail, _size   );
    
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
    for (ORInt tt = 0; tt < _size; tt++) {
        const ORInt t = _index[tt] + _low;
        if (!_tasks[t].isAbsent) {
            if (!_tasks[t].isPresent) {
                [_tasks[t] whenPresentPropagate:self];
            }
            if (!_tasks[t].bound)
                [_tasks[t] whenChangePropagate:self];
            if (!_usages[t].bound)
                [_usages[t] whenChangeMinPropagate:self];
#warning Check whether first test is necessary
            if (_area != NULL && _area[t] != NULL && !_area[t].bound)
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
    return cumu->_lst[t0];
}

static inline ORInt ect(CPTaskCumulative * cumu, const ORInt t0)
{
    assert(0 <= t0 && t0 < cumu->_size);
    return cumu->_ect[t0];
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
    return cumu->_usage_max[t0];
}

static inline ORInt area_min(CPTaskCumulative * cumu, const ORInt t0)
{
#warning Changed for taking an area variable into account
    assert(0 <= t0 && t0 < cumu->_size);
    return  cumu->_area_min[t0];
}

static inline ORInt area_max(CPTaskCumulative * cumu, const ORInt t0)
{
#warning Changed for taking an area variable into account
    assert(0 <= t0 && t0 < cumu->_size);
    return  cumu->_area_max[t0];
}

static inline ORInt free_energy(CPTaskCumulative * cumu, const ORInt t0)
{
    assert(0 <= t0 && t0 < cumu->_size);
    assert(0 <= area_min(cumu, t0) - usage_min(cumu, t0) * max(0, ect(cumu, t0) - lst(cumu, t0)));
    return  area_min(cumu, t0) - usage_min(cumu, t0) * max(0, ect(cumu, t0) - lst(cumu, t0));
}


/*!
 *  @brief Computing the minimal required energy of a task after a specific point in time,
 *      i.e., in the right-open time interval [time, inf[.
 *
 *  @param t0 A normalised index of a task.
 *  @param begin A point in time specifying the time interval [begin, inf[.
 *  @param tt_before_begin Cumulative energy from the compulsory parts in the time interval [est(cumu, t0), begin).
 *  @return Minimal required energy of a task t0 in the time interval [begin, inf[.
 */
static inline ORInt energy_left_shift(CPTaskCumulative * cumu, const ORInt t0, const ORInt begin, const ORInt tt_before_begin)
{
    // Considering only the usage and duration variables
    const ORInt energy_1 = usage_min(cumu, t0) * min(dur_min(cumu, t0), max(0, ect(cumu, t0) - begin));
    assert(0 <= energy_1 && energy_1 <= usage_min(cumu, t0) * dur_min(cumu, t0));
    if (cumu->_area == NULL || cumu->_area[t0 + cumu->_low])
        return energy_1;
    // Considering the area variable
    const ORInt en_avail_before_begin = (begin <= est(cumu, t0) ? 0 : cap_max(cumu) * (begin - est(cumu, t0)) - tt_before_begin + comp_part_interval(cumu, t0, est(cumu, t0), begin));
    const ORInt energy_2 = area_min(cumu, t0) - min(usage_max(cumu, t0) * max(0, begin - est(cumu, t0)), en_avail_before_begin);
    assert(energy_2 <= area_min(cumu, t0));
    assert(est(cumu, t0) < begin || max(energy_1, energy_2) == area_min(cumu, t0));
    return max(energy_1, energy_2);
}

/*!
 *  @brief Computing the minimal required energy of a task after a specific point in time,
 *      i.e., in the left-open time interval [time, inf[, excluding the energy for the
 *      compulsory part.
 *
 *  @param t0 A normalised index of a task.
 *  @param begin A point in time specifying the time interval [begin, inf[.
 *  @param tt_before_begin Cumulative energy from the compulsory parts in the time interval [est(cumu, t0), begin).
 *  @return Minimal required energy of a task t0 in the time interval [begin, inf[
 *      excluding the energy of the compulsory part.
 */
static inline ORInt free_energy_left_shift(CPTaskCumulative * cumu, const ORInt t0, const ORInt begin, const ORInt tt_before_begin)
{
    assert(0 <= t0 && t0 < cumu->_size);
    if (begin <= est(cumu, t0))
        return free_energy(cumu, t0);
    return energy_left_shift(cumu, t0, begin, tt_before_begin) - comp_part_left_shift(cumu, t0, begin);
}

/*!
 *  @brief Computing the energy/area of the compulsory part intersecting a right-open
 *      time interval.
 *
 *  @param t0 A normalised index of a task
 *  @param begin A point in time specifying the time interval [begin, inf[.
 *  @return Energy of the compulsory part intersecting the time interval ]begin, inf[.
 */
static inline ORInt comp_part_left_shift(CPTaskCumulative * cumu, const ORInt t0, const ORInt begin)
{
    assert(0 <= t0 && t0 < cumu->_size);
    if (lst(cumu, t0) < ect(cumu, t0) && begin < ect(cumu, t0)) {
        return usage_min(cumu, t0) * (ect(cumu, t0) - max(begin, lst(cumu, t0)));
    }
    return 0;
}

/*!
 *  @brief Computing the minimal required energy of a task before a specific point in time,
 *      i.e., in the left-open time interval ]-inf, time].
 *
 *  @param t0 A normalised index of a task.
 *  @param end A point in time specifying the time interval ]-inf, end].
 *  @param tt_after_end Cumulative energy from the compulsory parts in the time interval [end, lct(cumu, t0)).
 *  @return Minimal required energy of a task t0 in the time interval ]-inf, end].
 */
static inline ORInt energy_right_shift(CPTaskCumulative * cumu, const ORInt t0, const ORInt end, const ORInt tt_after_end)
{
    // Considering only the usage and duration variables
    const ORInt energy_1 = usage_min(cumu, t0) * min(dur_min(cumu, t0), max(0, end - lst(cumu, t0)));
    assert(0 <= energy_1 && energy_1 <= usage_min(cumu, t0) * dur_min(cumu, t0));
    if (cumu->_area == NULL || cumu->_area[t0 + cumu->_low] == NULL)
        return energy_1;
    // Considering the area variable
    const ORInt en_avail_after_end = (lct(cumu, t0) <= end ? 0 : cap_max(cumu) * (lct(cumu, t0) - end) - tt_after_end + comp_part_interval(cumu, t0, end, lct(cumu, t0)));
    const ORInt energy_2 = area_min(cumu, t0) - min(usage_max(cumu, t0) * max(0, lct(cumu, t0) - end), en_avail_after_end);
    if (energy_2 > area_min(cumu, t0)) {
        dumpTask(cumu, t0);
        printf("end: %d; blah %d\n", end, cap_max(cumu) * (lct(cumu, t0) - end));
    }
    assert(energy_2 <= area_min(cumu, t0));
    assert(end < lct(cumu, t0) || max(energy_1, energy_2) == area_min(cumu, t0));
    return max(energy_1, energy_2);
}

/*!
 *  @brief Computing the minimal required energy of a task before a specific point in time,
 *      i.e., in the left-open time interval ]-inf, time], excluding the energy for the
 *      compulsory part.
 *
 *  @param t0 A normalised index of a task.
 *  @param end A point in time specifying the time interval ]-inf, end].
 *  @param tt_after_end Cumulative energy from the compulsory parts in the time interval [end, lct(cumu, t0)).
 *  @return Minimal required energy of a task t0 in the time interval ]-inf, end]
 *      excluding the energy of the compulsory part.
 */
static inline ORInt free_energy_right_shift(CPTaskCumulative * cumu, const ORInt t0, const ORInt end, const ORInt tt_after_end)
{
    assert(0 <= t0 && t0 < cumu->_size);
    if (lct(cumu, t0) <= end)
        return free_energy(cumu, t0);
    assert(0 <= tt_after_end);
    return energy_right_shift(cumu, t0, end, tt_after_end) - comp_part_right_shift(cumu, t0, end);
}

/*!
 *  @brief Computing the energy/area of the compulsory part intersecting a left-open
 *      time interval.
 *
 *  @param t0 A normalised index of a task
 *  @param end A point in time specifying the time interval ]-inf, end].
 *  @return Energy of the compulsory part intersecting the time interval ]-inf, end].
 */
static inline ORInt comp_part_right_shift(CPTaskCumulative * cumu, const ORInt t0, const ORInt end)
{
    assert(0 <= t0 && t0 < cumu->_size);
    if (lst(cumu, t0) < ect(cumu, t0) && lst(cumu, t0) < end) {
        return usage_min(cumu, t0) * (min(end, ect(cumu, t0)) - lst(cumu, t0));
    }
    return 0;
}

/*!
 *  @brief Computing the energy/area of the compulsory part intersecting an
 *      time interval.
 *
 *  @param t0 A normalised index of a task
 *  @param begin A point in time specifying the time interval [begin, end].
 *  @param end A point in time specifying the time interval [begin, end].
 *  @return Energy of the compulsory part intersecting the time interval [begin, end].
 */
static inline ORInt comp_part_interval(CPTaskCumulative * cumu, const ORInt t0, const ORInt begin, const ORInt end)
{
    assert(0 <= t0 && t0 < cumu->_size);
    if (lst(cumu, t0) < ect(cumu, t0) && lst(cumu, t0) < end && begin < ect(cumu, t0)) {
        return usage_min(cumu, t0) * (min(end, ect(cumu, t0)) - max(begin, lst(cumu, t0)));
    }
    return 0;
}

/*!
 *  @brief Computing the minimal required energy for a task in a left-open time interval to
 *      be run at its earliest start time.
 *
 *  @param t0 A normalised index of a task.
 *  @param time A point in time specifying the time interval ]-inf, time]
 *  @return The minimal required energy of the task in the time interval for its execution at its earliest start time.
 */
static inline ORInt req_energy_start_est_right_shift(CPTaskCumulative * cumu, const ORInt t0, const ORInt time)
{
    assert(0 <= t0 && t0 < cumu->_size);
    if (time <= est(cumu, t0))
        return 0;
    if (est(cumu, t0) + dur_max(cumu, t0) <= time)
        return area_min(cumu, t0);
    return min(area_min(cumu, t0), usage_min(cumu, t0) * (time - est(cumu, t0)));
}

/*!
 *  @brief Computing the minimal required energy for a task in a right-open time interval [time, inf[ to
 *      be run at latest as possible.
 *
 *  @param t0 A normalised index of a task.
 *  @param begin A point in time specifying the time interval [begin, inf[
 *  @return The minimal required energy of the task in the time interval for its execution at latest as possible.
 */
static inline ORInt req_energy_end_lct_left_shift(CPTaskCumulative * cumu, const ORInt t0, const ORInt begin)
{
    assert(0 <= t0 && t0 < cumu->_size);
    if (lct(cumu, t0) <= begin)
        return 0;
    if (begin <= lct(cumu, t0) - dur_max(cumu, t0))
        return area_min(cumu, t0);
    return min(area_min(cumu, t0), usage_min(cumu, t0) * (lct(cumu, t0) - begin));
}

/*!
 *  @brief Computing the minimal required energy for a task in a time interval [begin, end) to
 *      be run at latest as possible.
 *
 *  @param t0 A normalised index of a task.
 *  @param begin A point in time specifying the beginning of the time interval [begin, end[
 *  @param end A point in time specifying the end of the time interval [begin, end[
 *  @param tt_after_end Cumulative energy from the compulsory parts in the time interval [end, lct(cumu, t0)).
 *  @return The minimal required energy of the task in the time interval for its execution ending at the latest completion time.
 */
static inline ORInt req_energy_end_lct_interval(CPTaskCumulative * cumu, const ORInt t0, const ORInt begin, const ORInt end, const ORInt tt_after_end)
{
    assert(0 <= t0 && t0 < cumu->_size);
    if (end <= est(cumu, t0) || lct(cumu, t0) <= begin)
        return 0;
    if (lct(cumu, t0) <= end)
        return req_energy_end_lct_left_shift(cumu, t0, begin);
    // Minimal required energy before end when the task is run at latest as possible
    const ORInt en_rs = energy_right_shift(cumu, t0, end, tt_after_end);
    return min(usage_min(cumu, t0) * (end - begin), en_rs);
}

/*!
 *  @brief Computing the minimal required energy for a task in a time interval [begin, end) to
 *      be run at earliest as possible.
 *
 *  @param t0 A normalised index of a task.
 *  @param begin A point in time specifying the beginning of the time interval [begin, end[
 *  @param end A point in time specifying the end of the time interval [begin, end[
 *  @param tt_before_begin Cumulative energy from the compulsory parts in the time interval [est(cumu, t0), begin).
 *  @return The minimal required energy of the task in the time interval for its execution at its earliest start time.
 */
static inline ORInt req_energy_start_est_interval(CPTaskCumulative * cumu, const ORInt t0, const ORInt begin, const ORInt end, const ORInt tt_before_begin)
{
    assert(0 <= t0 && t0 < cumu->_size);
    if (end <= est(cumu, t0) || lct(cumu, t0) <= begin)
        return 0;
    if (begin <= est(cumu, t0))
        return req_energy_start_est_right_shift(cumu, t0, end);
    // Minimal required energy after begin when the task is run at eaerliest as possible
    const ORInt en_rs = energy_left_shift(cumu, t0, begin, tt_before_begin);
    return min(usage_min(cumu, t0) * (end - begin), en_rs);
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
    return (cumu->_tasks[i].bound && cumu->_usages[i].bound);
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
 *  - area
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
    const ORInt firstPresent   = cumu->_indexFirstPresent._val;
    const ORInt firstUnknownRT = cumu->_indexFirstUnknownRT._val;
    ORInt nbCompParts = 0;
    cumu->_profileSize = 0;
    
    // Determine the number of activities with compulsory parts to be considered
    for (ORInt tt = firstPresent; tt < firstUnknownRT; tt++) {
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
    
    for (ORInt tt = firstPresent; tt < firstUnknownRT; tt++) {
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

static void tt_filter_start_end_times(CPTaskCumulative* cumu, ORInt * unbound, const ORInt unboundSize, const ORInt maxLevel, bool* update)
{
    ORInt maxCapacity = cap_max(cumu);
    ORInt index = 0;    // Profile index
    for (ORInt tt = 0; tt < unboundSize; tt++) {
        const ORInt t0 = unbound[tt];
        
#warning TODO Cross-check for propagation in the case of zero duration and usage
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
            
            // Propagating absence
            if (new_est + dur_min(cumu, t0) > new_lct) {
                const ORInt t = t0 + cumu->_low;
                cumu->_nb_tt_props++;
                if (cumu->_resourceTask[t0]) {
                    assert([cumu->_tasks[t] isMemberOfClass:[CPResourceTask class]]);
                    [(id<CPResourceTask>)cumu->_tasks[t] remove:cumu];
                }
                else
                    [cumu->_tasks[t] labelPresent: FALSE];
            }
            
            // Do not propagate bounds of non-relevant resource tasks
            if (cumu->_resourceTask[t0] && !isRelevant(cumu, t0))
                continue;
            
            // Imposing the new earliest start time
            if (new_est > est(cumu, t0)) {
                const ORInt t = t0 + cumu->_low;
                cumu->_nb_tt_props++;
                [cumu->_tasks[t] updateStart:new_est];
                *update = true;
            }
            
            // Imposing the new latest completion time
            if (new_lct < lct(cumu, t0)) {
                const ORInt t = t0 + cumu->_low;
                cumu->_nb_tt_props++;
                [cumu->_tasks[t] updateEnd:new_lct];
                *update = true;
            }
            
            // Update duration
            if (dur_min(cumu, t0) < dur_max(cumu, t0)) {
                tt_filter_duration_ub_i(cumu, t0, update);
            }
            
            // Update usages
            if (usage_min(cumu, t0) < usage_max(cumu, t0))
                tt_filter_usage_ub_i(cumu, t0, update);
        }
    }
}

static void tt_filter_duration_ub_i(CPTaskCumulative * cumu, const ORInt t0, bool * update)
{
    assert(!(cumu->_resourceTask[t0] && !isRelevant(cumu, t0)));
    assert(dur_min(cumu, t0) < dur_max(cumu, t0));
    
    const ORInt maxCapacity = cap_max(cumu);

    const ORInt low = find_first_profile_peak_for_lb(cumu->_profile, est(cumu, t0), 0, cumu->_profileSize - 1);
    const ORInt up  = find_first_profile_peak_for_ub(cumu->_profile, lct(cumu, t0), 0, cumu->_profileSize - 1);

    // Update the duration
    ORInt begin = est(cumu, t0);
    ORInt maxDur = dur_min(cumu, t0);
    // Find the maximal duration with the minimal resource usage
    if (cumu->_profile[low]._end <= begin)
        maxDur = lct(cumu, t0) - begin;
    else {
        for (ORInt p = low; p <= up; p++) {
            assert(begin < cumu->_profile[p]._end);
            maxDur = max(maxDur, min(lct(cumu, t0), cumu->_profile[p]._begin) - begin);
            if (maxDur >= dur_max(cumu, t0))
                break;
            if (cumu->_profile[p]._level + usage_min(cumu, t0) > maxCapacity) {
                // Check whether the task does not have a compulsory part in the profile peak
                if (!(lst(cumu, t0) < ect(cumu, t0) && lst(cumu, t0) <= cumu->_profile[p]._begin &&
                      cumu->_profile[p]._end <= ect(cumu, t0))) {
                    // A new latest completion time
                    begin = cumu->_profile[p]._end;
                }
            }
            
        }
    }
    assert(maxDur >= dur_min(cumu, t0));
    // Update the upper bound on the duration
    if (maxDur < dur_max(cumu, t0)) {
        const ORInt t = t0 + cumu->_low;
        cumu->_nb_tt_props++;
        [cumu->_tasks[t] updateMaxDuration:maxDur];
        *update = true;
    }
}

static void tt_filter_usage_ub_i(CPTaskCumulative * cumu, const ORInt t0, bool * update)
{
    assert(!(cumu->_resourceTask[t0] && !isRelevant(cumu, t0)));
    assert(usage_min(cumu, t0) < usage_max(cumu, t0));
    
    const ORInt maxCapacity = cap_max(cumu);
    
    const ORInt low = find_first_profile_peak_for_lb(cumu->_profile, est(cumu, t0), 0, cumu->_profileSize - 1);
    const ORInt up  = find_first_profile_peak_for_ub(cumu->_profile, lct(cumu, t0), 0, cumu->_profileSize - 1);
    
    ORInt begin = est(cumu, t0);
    ORInt maxUsage = usage_min(cumu, t0);
    // Find the maximal resource usage with the minimal duration
    if (cumu->_profile[low]._end <= begin)
        maxUsage = maxCapacity;
    else {
        for (ORInt p = low; p <= up && maxUsage < usage_max(cumu, t0); p++) {
            assert(begin < cumu->_profile[p]._end);
            // Check whether the task does not have a compulsory part in the profile peak
            ORInt comp_p = 0;
            if (lst(cumu, t0) < ect(cumu, t0) && lst(cumu, t0) <= cumu->_profile[p]._begin &&
                cumu->_profile[p]._end <= ect(cumu, t0)) {
                comp_p = usage_min(cumu, t0);
            }
            const ORInt peak_p = cumu->_profile[p]._level - comp_p;
            if (begin + dur_min(cumu, t0) <= cumu->_profile[p]._begin) {
                maxUsage = maxCapacity;
            }
            else if (begin + dur_min(cumu, t0) <= cumu->_profile[p]._end) {
                maxUsage = max(maxUsage, maxCapacity - peak_p);
                begin = cumu->_profile[p]._end;
            }
            else if (maxUsage + peak_p >= maxCapacity) {
                begin = cumu->_profile[p]._end;
            }
            else {
                ORInt q;
                for (q = p + 1; q <= up; q++) {
                    if (begin + dur_min(cumu, t0) <= cumu->_profile[q]._begin) {
                        maxUsage = max(maxUsage, maxCapacity - peak_p);
                        begin = cumu->_profile[p]._end;
                        break;
                    }
                    assert(begin + dur_min(cumu, t0) > cumu->_profile[q]._begin);
                    // Check whether the task does not have a compulsory part in the profile peak
                    ORInt comp_q = 0;
                    if (lst(cumu, t0) < ect(cumu, t0) && lst(cumu, t0) <= cumu->_profile[q]._begin &&
                        cumu->_profile[q]._end <= ect(cumu, t0)) {
                        comp_q = usage_min(cumu, t0);
                    }
                    const ORInt peak_q = cumu->_profile[q]._level - comp_q;
                    if (peak_p < peak_q) {
                        p = q - 1;
                        break;
                    }
                    assert(peak_p >= peak_q);
                    if (begin + dur_min(cumu, t0) <= cumu->_profile[q]._end) {
                        maxUsage = max(maxUsage, maxCapacity - peak_p);
                        begin = cumu->_profile[p]._end;
                        break;
                    }
                }
                if (q > up && begin + dur_min(cumu, t0) <= lct(cumu, t0)) {
                    maxUsage = max(maxUsage, maxCapacity - peak_p);
                    begin = cumu->_profile[p]._end;
                }
            }
        }
    }
    assert(maxUsage >= usage_min(cumu, t0));
    // Update the upper bound on the duration
    if (maxUsage < usage_max(cumu, t0)) {
        const ORInt t = t0 + cumu->_low;
        cumu->_nb_tt_props++;
        [cumu->_usages[t] updateMax:maxUsage];
        *update = true;
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


static void ttef_initialise_parameters(CPTaskCumulative* cumu, ORInt* unbound, ORInt* task_id_est, ORInt* task_id_lct, ORInt* ttEnAfterEst, ORInt* ttEnAfterLct, ORInt* mapEnAfterEst, ORInt* mapEnAfterLct, const ORInt unboundSize)
{
    assert(unboundSize > 0);
    
    // Initialisation
    for (ORInt tt = 0; tt < unboundSize; tt++) {
        task_id_est[tt] = unbound[tt];
        task_id_lct[tt] = unbound[tt];
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
            mapEnAfterEst[task_id_est[tt]] = 0;
            mapEnAfterLct[task_id_lct[tt]] = 0;
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
                mapEnAfterEst[t0] = tt;
            }
            else if (profile[p]._begin <= est(cumu, t0)) {
                ttEnAfterEst[tt] = energy + profile[p]._level * (profile[p]._end - est(cumu, t0));
                mapEnAfterEst[t0] = tt;
            }
            else {
                assert(profile[p]._begin > est(cumu, t0));
                energy += profile[p]._level * (profile[p]._end - profile[p]._begin);
                p--;
                tt++;
            }
        }
        assert(^ORBool(){
            for (ORInt tt = unboundSize - 1; tt >= 1; tt--) {
                const ORInt i = task_id_est[tt];
                const ORInt j = task_id_est[tt - 1];
                if (ttEnAfterEst[mapEnAfterEst[j]] < ttEnAfterEst[mapEnAfterEst[i]]) {
                    return false;
                }
            }
            return true;
        }());
        
        // Calculation of ttEnAfterLct
        energy = 0;
        p = cumu->_profileSize - 1;
        
        for (ORInt tt = unboundSize - 1; tt >= 0; tt--) {
            const ORInt t0 = task_id_lct[tt];
            if (p < 0 || profile[p]._end <= lct(cumu, t0)) {
                ttEnAfterLct[tt] = energy;
                mapEnAfterLct[t0] = tt;
            }
            else if (profile[p]._begin <= lct(cumu, t0)) {
                ttEnAfterLct[tt] = energy + profile[p]._level * (profile[p]._end - lct(cumu, t0));
                mapEnAfterLct[t0] = tt;
            }
            else {
                assert(profile[p]._begin > lct(cumu, t0));
                energy += profile[p]._level * (profile[p]._end - profile[p]._begin);
                p--;
                tt++;
            }
        }
        assert(^ORBool(){
            for (ORInt tt = unboundSize - 1; tt >= 1; tt--) {
                const ORInt i = task_id_lct[tt];
                const ORInt j = task_id_lct[tt - 1];
                if (ttEnAfterLct[mapEnAfterLct[j]] < ttEnAfterLct[mapEnAfterLct[i]])
                    return false;
            }
            return true;
        }());
    }
}

    // Specialised TTEF consistency check which can detect dominated time intervals and
    // skip them
    // Time complexity: O(u^2) where u is the number of unfixed tasks
    // Space complexity: O(u)
static void ttef_consistency_check(CPTaskCumulative * cumu, const ORInt * task_id_est, const ORInt * task_id_lct,
    const ORInt * ttEnAfterEst, const ORInt * ttEnAfterLct, const ORInt * mapEnAfterLct,
    const ORInt unboundSize,
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
            const ORInt tt_after_end = max(0, ttEnAfterLct[ii] - ttEnAfterLct[mapEnAfterLct[j]]);
            assert(0 <= free_energy_right_shift(cumu, j, end, tt_after_end));
            en_req_free += free_energy_right_shift(cumu, j, end, tt_after_end);
#warning TODO Propagation on the upper bound of area variables
#warning XXX Old code before considering area variables
//            if (lct(cumu, j) <= end) {
//                // Task j fully lies in the interval [begin, end)
//                en_req_free += free_energy(cumu, j);
//            }
//            else {
//                // Calculation whether a free part of the task partially lies
//                // in the interval
//                ORInt dur_fixed = max(0, ect(cumu, j) - lst(cumu, j));
//                ORInt dur_shift = shift_in(begin, end, est(cumu, j), ect(cumu, j), lst(cumu, j), lct(cumu, j), dur_fixed);
//                en_req_free += usage_min(cumu, j) * dur_shift;
//            }
            
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
    ORInt* ttEnAfterEst, ORInt* ttEnAfterLct, ORInt* mapEnAfterEst, ORInt* mapEnAfterLct, const ORInt unboundSize,
    ORInt shift_in1(const ORInt, const ORInt, const ORInt, const ORInt, const ORInt, const ORInt, const ORInt),
    ORInt shift_in2(const ORInt, const ORInt, const ORInt, const ORInt, const ORInt, const ORInt, const ORInt),
    bool* update)
{
    assert(unboundSize > 0);
    
    // Allocation of memory for recording the new bounds
    ORInt new_cap_min = cap_min(cumu);
    ORInt new_est[cumu->_size];
    ORInt new_lct[cumu->_size];

    // Initialisation of the arrays
    for (ORInt tt = 0; tt < unboundSize; tt++) {
        const ORInt t0 = task_id_est[tt];
        new_est[t0] = est(cumu, t0);
        new_lct[t0] = lct(cumu, t0);
    }

    // TTEF propagation of the start times
    ttef_filter_start_times(cumu, task_id_est, task_id_lct, ttEnAfterEst, ttEnAfterLct, mapEnAfterEst, mapEnAfterLct, unboundSize, new_est, new_lct, &new_cap_min, shift_in1, update);
    // TTEF propagaiton of the end times
    ttef_filter_end_times(cumu, task_id_est, task_id_lct, ttEnAfterEst, ttEnAfterLct, mapEnAfterEst, mapEnAfterLct, unboundSize, new_est, new_lct, &new_cap_min, shift_in2, update);

    // Propagation of absence and bounds
    for (ORInt tt = 0; tt < unboundSize; tt++) {
        const ORInt t0 = task_id_est[tt];
        const ORInt t  = t0 + cumu->_low;
        // Propagation of absence
        if (new_est[t0] + dur_min(cumu, t0) > new_lct[t0]) {
            if (cumu->_resourceTask[t0]) {
                [(id<CPResourceTask>)cumu->_tasks[t] remove:cumu];
            }
            else
                [cumu->_tasks[t] labelPresent:FALSE];
        }
        // Do not propagate bounds for non-relevant resource tasks
        if (cumu->_resourceTask[t0] && !isRelevant(cumu, t0))
            continue;
        // Update of bounds
        if (new_est[t0] > est(cumu, t0))
            [cumu->_tasks[t] updateStart:new_est[t0]];
        if (new_lct[t0] < lct(cumu, t0))
            [cumu->_tasks[t] updateEnd:new_lct[t0]];
    }
    if (new_cap_min > cap_min(cumu))
        [cumu->_capacity updateMin:new_cap_min];
}

static void ttef_filter_start_times(CPTaskCumulative* cumu, const ORInt* task_id_est, const ORInt* task_id_lct,
    const ORInt* ttEnAfterEst, const ORInt* ttEnAfterLct, ORInt* mapEnAfterEst, ORInt* mapEnAfterLct,
    const ORInt unboundSize, ORInt* new_est, ORInt* new_lct, ORInt * new_cap_min,
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
#if TTEFMAXAREAPROP
        ORInt max_req = 0;
        ORInt max_req_j = MININT;
#endif
        
        // Inner loop: Iteration over the begin times of the interval [., end)
        //
        for (ORUInt jj = est_idx_last + 1; jj--; ) {
            j = task_id_est[jj];
            
            assert(est(cumu, j) < end);
            
            // Skip activities without area
            if (area_min(cumu, j) <= 0)
                continue;

#if TTEEFABSOLUTEPROP || TTEEFDENSITYPROP
            const ORInt tt_after_end = max(0, ttEnAfterLct[ii] - ttEnAfterLct[mapEnAfterLct[j]]);
            assert(end >= lct(cumu, j) || (0 <= tt_after_end && tt_after_end <= cap_max(cumu) * (lct(cumu, j) - end)));
#endif
#if TTEEFABSOLUTEPROP
            // TTEEF bounds propagation for task j with respect to the time interval [., end)
            // containing the minimal available energy
            tteef_filter_end_times_in_interval(cumu, new_lct, j, min_begin, end, min_en_avail, tt_after_end, update);
#endif
#if TTEEFDENSITYPROP
            // TTEEF bounds propagation for task j with respect to the time interval [., end)
            // that is one of the most dense ones
            tteef_filter_end_times_in_interval(cumu, new_lct, j, min_density_begin, end, min_density_en_avail, tt_after_end, update);
#endif
            
            // New begin time of the time interval [begin, end)
            begin = est(cumu, j);
            
            if (!isPresent(cumu, j)) {
                const ORInt en_req = en_req_free + ttEnAfterEst[jj] - ttEnAfterLct[ii];
                const ORInt en_avail = cap_max(cumu) * (end - begin) - en_req;
                tteef_filter_start_times_in_interval(cumu, new_est, j, begin, end, en_avail, 0, update);
                continue;
            }
            
            // Adding the required energy of j in the intervals [begin', end)
            // where begin' <= est(cumu, j)
            if (lct(cumu, j) <= end) {
                // Task j fully lies in the interval [begin, end)
                en_req_free += free_energy(cumu, j);
#if TTEFMAXAREAPROP
                if (cumu->_area != NULL && cumu->_area[j + cumu->_low] != NULL && max_req < area_max(cumu, j) - area_min(cumu, j)) {
                    max_req = area_max(cumu, j) - area_min(cumu, j);
                    max_req_j = j;
                }
#endif
            }
            else {
                // Calculation whether a free part of the task partially lies
                // in the interval
#if !TTEEFABSOLUTEPROP || !TTEEFDENSITYPROP
                const ORInt tt_after_end = max(0, ttEnAfterLct[ii] - ttEnAfterLct[mapEnAfterLct[j]]);
#endif
                const ORInt en_rs = energy_right_shift(cumu, j, end, tt_after_end);
                const ORInt en_comp_part = comp_part_right_shift(cumu, j, end);
                en_req_free += en_rs - en_comp_part;
#warning XXX Old code before considering area variables
//                const ORInt dur_fixed = max(0, ect(cumu, j) - lst(cumu, j));
//                const ORInt dur_shift = shift_in(begin, end, est(cumu, j), ect(cumu, j), lst(cumu, j), lct(cumu, j), dur_fixed);
//                en_req_free += usage_min(cumu, j) * dur_shift;
                // Calculation of the required energy for starting at est(j)
                const ORInt en_req_start = req_energy_start_est_right_shift(cumu, j, end) - en_rs;
                assert(0 <= en_req_start);
#warning XXX Old code before considering area variables
//                const ORInt en_req_start = min(free_energy(cumu, j), usage_min(cumu, j) * (end - est(cumu, j))) - usage_min(cumu, j) * dur_shift;
                if (en_req_start > update_en_req_start) {
                    update_en_req_start = en_req_start;
                    update_idx = jj;
                }
            }
            
            // Computing the total required energy in the interval [begin, end)
            const ORInt en_req = en_req_free + ttEnAfterEst[jj] - ttEnAfterLct[ii];
            const ORInt en_avail = cap_max(cumu) * (end - begin) - en_req;
            
            // Checking for a resource overload
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
#if TTEFMAXAREAPROP
            // Check for an area update
            if (max_req > 0 && en_avail < area_max(cumu, max_req_j) - area_min(cumu, max_req_j)) {
                cumu->_nb_ttef_area_props++;
                *update = true;
                [cumu->_area[max_req_j + cumu->_low] updateMax:en_avail + area_min(cumu, max_req_j)];
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
                const ORInt tt_after_end = max(0, ttEnAfterLct[ii] - ttEnAfterLct[mapEnAfterLct[j]]);
                const ORInt en_avail_j = en_avail + energy_right_shift(cumu, j, end, tt_after_end);
                const ORInt start_new  = end - (en_avail_j / usage_min(cumu, j));
#warning XXX Old code before considering area variables
//                int dur_cp_in = max(0, min(end, ect(cumu, j)) - lst(cumu, j));
//                int dur_shift = shift_in(begin, end, est(cumu, j), ect(cumu, j), lst(cumu, j), lct(cumu, j), dur_cp_in);
//                int dur_avail = (en_avail / usage_min(cumu, j)) + dur_cp_in + dur_shift;
//                int start_new = end - dur_avail;
                
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
    const ORInt* ttEnAfterEst, const ORInt* ttEnAfterLct, const ORInt* mapEnAfterEst, const ORInt* mapEnAfterLct,
    const ORInt unboundSize, ORInt* new_est, ORInt* new_lct, ORInt * new_cap_min,
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
#if TTEFMAXAREAPROP
        ORInt max_req = 0;
        ORInt max_req_j = MININT;
#endif
        // Inner loop: iterating over lct in non-decreasing order
        //
        for (ORUInt jj = lct_idx_last; jj < unboundSize; jj++) {
            j = task_id_lct[jj];
            if (area_min(cumu, j) <= 0) continue;
            assert(begin < lct(cumu, j));

#if TTEEFABSOLUTEPROP || TTEEFDENSITYPROP
            const ORInt tt_before_begin = max(0, ttEnAfterEst[mapEnAfterEst[j]] - ttEnAfterEst[ii]);
            assert(est(cumu, j) >= begin || (0 <= tt_before_begin && tt_before_begin <= cap_max(cumu) * (begin - est(cumu, j))));
#endif
#if TTEEFABSOLUTEPROP
            // TTEEF bounds propagation for task j with respect to the time interval [begin, .)
            // containing the minimal available energy
            tteef_filter_start_times_in_interval(cumu, new_est, j, begin, min_end, min_en_avail, tt_before_begin, update);
#endif
#if TTEEFDENSITYPROP
            // TTEEF bounds propagation for task j with respect to the time interval [begin, .)
            // that is one of the most dense ones
            tteef_filter_start_times_in_interval(cumu, new_est, j, begin, min_density_end, min_density_en_avail, tt_before_begin, update);
#endif

            end = lct(cumu, j);
            
            if (!isPresent(cumu, j)) {
                const ORInt en_req = en_req_free + ttEnAfterEst[ii] - ttEnAfterLct[jj];
                const ORInt en_avail = cap_max(cumu) * (end - begin) - en_req;
                tteef_filter_end_times_in_interval(cumu, new_lct, j, begin, end, en_avail, 0, update);
                continue;
            }
            
            // Calculation of the required free energy of j in [begin, end)
            //
            if (begin <= est(cumu, j)) {
                // Task j is contained in the time interval [begin, end)
                en_req_free += free_energy(cumu, j);
#if TTEFMAXAREAPROP
                if (cumu->_area != NULL && cumu->_area[j + cumu->_low] != NULL && max_req < area_max(cumu, j) - area_min(cumu, j)) {
                    max_req = area_max(cumu, j) - area_min(cumu, j);
                    max_req_j = j;
                }
#endif
            } else {
                // Task j might be partially contained in [begin, end)
#if !TTEEFABSOLUTEPROP || !TTEEFDENSITYPROP
                const ORInt tt_before_begin = max(0, ttEnAfterEst[mapEnAfterEst[j]] - ttEnAfterEst[ii]);
#endif
                const ORInt en_ls = energy_left_shift(cumu, j, begin, tt_before_begin);
                const ORInt en_comp_part = comp_part_left_shift(cumu, j, begin);
                en_req_free += en_ls - en_comp_part;
#warning XXX Old code before considering area variables
//                ORInt dur_fixed = max(0, ect(cumu, j) - lst(cumu, j));
//                ORInt dur_shift = shift_in(begin, end, est(cumu, j), ect(cumu, j), lst(cumu, j), lct(cumu, j), dur_fixed);
//                en_req_free += usage_min(cumu, j) * dur_shift;
                // Calculation of the required energy for completing j at 'lct(j)'
                const ORInt en_req_end = req_energy_end_lct_left_shift(cumu, j, begin) - en_ls;
                assert(0 <= en_req_end);
#warning XXX Old code before considering area variables
//                ORInt en_req_end = min(free_energy(cumu, j), usage_min(cumu, j) * (lct(cumu, j) - begin)) - usage_min(cumu, j) * dur_shift;
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
#if TTEFMAXAREAPROP
            // Check for an area update
            if (max_req > 0 && en_avail < area_max(cumu, max_req_j) - area_min(cumu, max_req_j)) {
                cumu->_nb_ttef_area_props++;
                *update = true;
                [cumu->_area[max_req_j + cumu->_low] updateMax:en_avail + area_min(cumu, max_req_j)];
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
                const ORInt tt_before_begin = max(0, ttEnAfterEst[mapEnAfterEst[j]] - ttEnAfterEst[ii]);
                const ORInt en_avail_j = en_avail + energy_left_shift(cumu, j, begin, tt_before_begin);
                const ORInt end_new = begin + (en_avail_j / usage_min(cumu, j));
#warning XXX Old code before considering area variables
//                ORInt dur_cp_in = max(0, ect(cumu, j) - max(begin, lst(cumu, j)));
//                ORInt dur_shift = shift_in(begin, end, est(cumu, j), ect(cumu, j), lst(cumu, j), lct(cumu, j), dur_cp_in);
//                ORInt dur_avail = (en_avail / usage_min(cumu, j)) + dur_cp_in + dur_shift;
//                ORInt end_new   = begin + dur_avail;
                
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

static void tteef_filter_start_times_in_interval(CPTaskCumulative* cumu, ORInt* new_est, const ORInt j, const ORInt tw_begin, const ORInt tw_end, const ORInt en_avail, const ORInt tt_before_begin, bool* update)
{
    assert(area_min(cumu, j) > 0);
    if (lct(cumu, j) <= tw_end || area_min(cumu, j) <= en_avail)
        return;
    // Compute the minimal required energy in the interval for executing the task as earliest as possible
    const ORInt en_comp_part = (isRelevant(cumu, j) ? comp_part_interval(cumu, j, tw_begin, tw_end) : 0);
    const ORInt en_req_ls = req_energy_start_est_interval(cumu, j, tw_begin, tw_end, tt_before_begin);
    const ORInt min_req_en = en_req_ls - en_comp_part;
    assert(0 <= min_req_en);
    // Check for TTEEF propagation
    if (en_avail < min_req_en) {
        // Calculate the new lower bound
        const ORInt est_new = tw_end - ((en_avail + en_comp_part) / usage_min(cumu, j));
        // Check whether a new lower bound was found
        if (est_new > new_est[j]) {
            cumu->_nb_ttef_props++;
            *update = true;
            new_est[j] = est_new;
        }
    }
#warning XXX Old code before considering area variables
//    if (isPresent(cumu, j)) {
//        const ORInt free_ect = (lst(cumu, j) < ect(cumu, j) ? lst(cumu, j) : ect(cumu, j));
//        
//        // TTEEF bounds propagation for task j with respect to the time interval [begin, .)
//        const ORInt min_en_req = usage_min(cumu, j) * (min(tw_end, free_ect) - max(tw_begin, est(cumu, j)));
//        
//        if (tw_end < MAXINT && en_avail < min_en_req) {
//            assert(free_ect > tw_begin);
//            // Calculate the new lower bound
//            const ORInt dur_cp_in = max(0, min(tw_end, ect(cumu, j)) - max(tw_begin, lst(cumu, j)));
//            const ORInt dur_avail = (en_avail / usage_min(cumu, j)) + dur_cp_in;
//            const ORInt est_new = tw_end - dur_avail;
//            // Check whether a new lower bound was found
//            if (est_new > new_est[j]) {
//                cumu->_nb_ttef_props++;
//                *update = true;
//                new_est[j] = est_new;
//            }
//        }
//    }
//    else {
//        assert(!isAbsent(cumu, j));
//        const ORInt min_en_req = usage_min(cumu, j) * (min(tw_end, ect(cumu, j)) - max(tw_begin, est(cumu, j)));
//        
//        if (tw_end < MAXINT && en_avail < min_en_req) {
//            assert(ect(cumu, j) > tw_begin);
//            // Calculate the new lower bound
//            const ORInt dur_avail = en_avail / usage_min(cumu, j);
//            const ORInt est_new = tw_end - dur_avail;
//            // Check whether a new lower bound was found
//            if (est_new > new_est[j]) {
//                cumu->_nb_ttef_props++;
//                *update = true;
//                new_est[j] = est_new;
//            }
//        }
//    }
}

static void tteef_filter_end_times_in_interval(CPTaskCumulative* cumu, ORInt* new_lct, const ORInt j, const ORInt tw_begin, const ORInt tw_end, const ORInt en_avail, const ORInt tt_after_end, bool* update) {
    assert(area_min(cumu, j) > 0);
    if (tw_begin <= est(cumu, j) || area_min(cumu, j) <= en_avail)
        return;
    // Compute the minimal required energy in the interval for executing the task at latest as possible
    const ORInt en_comp_part = (isRelevant(cumu, j) ? comp_part_interval(cumu, j, tw_begin, tw_end) : 0);
    const ORInt en_req_rs = req_energy_end_lct_interval(cumu, j, tw_begin, tw_end, tt_after_end);
    const ORInt min_en_req = en_req_rs - en_comp_part;
    assert(0 <= min_en_req);
    // Check for TTEEF propagation
    if (en_avail < min_en_req) {
        // Calculate the new upper bound
        const ORInt lct_new = tw_begin + ((en_avail + en_comp_part) / usage_min(cumu, j));
        // Check whether a new upper bound was found
        if (lct_new < new_lct[j]) {
            cumu->_nb_ttef_props++;
            *update = true;
            // Push possible update into queue
            new_lct[j] = lct_new;
        }
    }
#warning XXX Old code before considering area variables
//    if (isPresent(cumu, j)) {
//        const ORInt free_lst = (lst(cumu, j) < ect(cumu, j) ? ect(cumu, j) : lst(cumu, j));
//        // TTEEF bounds propagation for task j with respect to the time interval [., end)
//        const ORInt min_en_req = usage_min(cumu, j) * (min(tw_end, lct(cumu, j)) - max(tw_begin, free_lst));
//        
//        if (tw_begin > MININT && en_avail < min_en_req) {
//            assert(free_lst < tw_end);
//            // Calculate the new upper bound
//            const ORInt dur_cp_in = max(0, min(tw_end, ect(cumu, j)) - max(tw_begin, lst(cumu, j)));
//            const ORInt dur_avail = (en_avail / usage_min(cumu, j)) + dur_cp_in;
//            const ORInt lct_new = tw_begin + dur_avail;
//            // Check whether a new upper bound was found
//            if (lct_new < new_lct[j]) {
//                cumu->_nb_ttef_props++;
//                *update = true;
//                // Push possible update into queue
//                new_lct[j] = lct_new;
//            }
//        }
//    }
//    else {
//        assert(!isAbsent(cumu, j));
//        const ORInt min_en_req = usage_min(cumu, j) * (min(tw_end, lct(cumu, j)) - max(tw_begin, lst(cumu, j)));
//        
//        if (tw_begin > MININT && en_avail < min_en_req) {
//            // Calculate the new upper bound
//            const ORInt dur_avail = en_avail / usage_min(cumu, j);
//            const ORInt lct_new   = tw_begin + dur_avail;
//            // Check whether a new upper bound was found
//            if (lct_new < new_lct[j]) {
//                cumu->_nb_ttef_props++;
//                *update = true;
//                // Push possible update into queue
//                new_lct[j] = lct_new;
//            }
//        }
//    }
}


    // Main method for the time-tabling-edge-finding (TTEF) propagation
    //
static void ttef_bounds_propagation(CPTaskCumulative* cumu, ORInt * unbound, const ORInt unboundSize, bool* update)
{
    assert(cumu->_ttef_check || cumu->_ttef_filt);
    
    if (unboundSize <= 0)
        return ;
    
    ORInt task_id_est [unboundSize];     // Unbound activities order wrt. their est
    ORInt task_id_lct [unboundSize];     // Unbound activities order wrt. their lct
    ORInt ttEnAfterEst[unboundSize];
    ORInt ttEnAfterLct[unboundSize];
    ORInt mapEnAfterEst[cumu->_size];
    ORInt mapEnAfterLct[cumu->_size];
    
    // Initialise all the parameters
    ttef_initialise_parameters(cumu, unbound, task_id_est, task_id_lct, ttEnAfterEst, ttEnAfterLct, mapEnAfterEst, mapEnAfterLct,  unboundSize);
    
    if (cumu->_ttef_filt) {
        // TTEF bounds filtering incl. consistency check
#if TTEFLEFTRIGHTSHIFT
        ttef_filter_start_and_end_times(cumu, task_id_est, task_id_lct, ttEnAfterEst, ttEnAfterLct, mapEnAfterEst, mapEnAfterLct, unboundSize,get_free_dur_right_shift, get_free_dur_left_shift, update);
#else
        ttef_filter_start_and_end_times(cumu, task_id_est, task_id_lct, ttEnAfterEst, ttEnAfterLct, mapEnAfterEst, mapEnAfterLct, unboundSize, get_no_shift, get_no_shift, update);
#endif
    } else {
        assert(cumu->_ttef_check);
        // TTEF consistency check
#if TTEFLEFTRIGHTSHIFT
        ttef_consistency_check(cumu, task_id_est, task_id_lct, ttEnAfterEst, ttEnAfterLct, mapEnAfterLct, unboundSize, get_free_dur_right_shift);
#else
        ttef_consistency_check(cumu, task_id_est, task_id_lct, ttEnAfterEst, ttEnAfterLct, mapEnAfterLct, unboundSize, get_no_shift);
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
    const ORInt firstUnknownRT = cumu->_indexFirstUnknownRT._val;
    const ORInt size = firstUnknownRT - firstPresent;

    ORInt id_est[size];
    ORInt id_ect[size];
    
    // Initialisation of the arrays
    for (ORInt tt = firstPresent; tt < firstUnknownRT; tt++) {
        const ORInt i = tt - firstPresent;
        const ORInt t0 = cumu->_index[tt];
        id_est[i] = t0;
        id_ect[i] = t0;
    }
    
    // Sorting the tasks in non-decreasing order by the earliest start time
    qusort_r(id_est, size, cumu, (ORInt (*)(void *, const ORInt *, const ORInt *)) &sortEstAsc);
    // Sorting the tasks in non-decreasing order by the latest completion time
    qusort_r(id_ect, size, cumu, (ORInt (*)(void *, const ORInt *, const ORInt *)) &sortEctAsc);

    Profile prof = getEarliestContentionProfile(id_est, id_ect, cumu->_est, cumu->_ect, cumu->_usage_min, size);
    
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
    assert(cumu->_indexFirstUnknown._val == cumu->_indexFirstIrrelevantRT._val);
    
    const ORInt firstPresent   = cumu->_indexFirstPresent._val;
    const ORInt firstUnknownRT = cumu->_indexFirstUnknownRT._val;
    const ORInt presentSize    = firstUnknownRT - firstPresent;
    
    ORInt id_est[presentSize];
    ORInt id_ect[presentSize];
    
    CPTaskVarPrec * prec = NULL;

    ORInt cap  = 0;
    ORInt size = 0;

    // Initialisation of the arrays
    for (ORInt tt = firstPresent; tt < firstUnknownRT; tt++) {
        const ORInt i  = tt - firstPresent;
        const ORInt t0 = cumu->_index[tt];
        id_est[i] = t0;
        id_ect[i] = t0;
    }
    
    // Sorting the tasks in non-decreasing order by the earliest start time
    qusort_r(id_est, presentSize, cumu, (ORInt (*)(void *, const ORInt *, const ORInt *)) &sortEstAsc);
    // Sorting the tasks in non-decreasing order by the latest completion time
    qusort_r(id_ect, presentSize, cumu, (ORInt (*)(void *, const ORInt *, const ORInt *)) &sortEctAsc);
    
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
    printf("task %d:", t0);
    printf(" start [%d, %d];", cumu->_est      [t0], cumu->_lst      [t0]);
    printf(" end [%d, %d];"  , cumu->_ect      [t0], cumu->_lct      [t0]);
    printf(" dur [%d, %d];"  , cumu->_dur_min  [t0], cumu->_dur_max  [t0]);
    printf(" usage [%d, %d];", cumu->_usage_min[t0], cumu->_usage_max[t0]);
    printf(" area [%d, %d];" , cumu->_area_min [t0], cumu->_area_max [t0]);
    printf(" present %d; absent %d;\n", cumu->_present[t0], cumu->_absent[t0]);
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
    // array '_index' is partitioned in [Irrelevant | Unknown | Present | PresentRT | UnknownRT | IrrelevantRT]
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

static ORBool updateIndicesRT(CPTaskCumulative * cumu)
{
    // array '_index' is partitioned in [Irrelevant | Unknown | Present | PresentRT | UnknownRT | IrrelevantRT]
    ORInt firstUnknownRT    = cumu->_indexFirstUnknownRT._val;
    ORInt firstIrrelevantRT = cumu->_indexFirstIrrelevantRT._val;
    
    // Update indices array
    for (ORInt tt = firstUnknownRT; tt < firstIrrelevantRT; tt++) {
        const ORInt t0 = cumu->_index[tt];
        if (isIrrelevant(cumu, t0))
            swapORInt(cumu->_index, --firstIrrelevantRT, tt--);
        else if (isRelevant(cumu, t0))
            swapORInt(cumu->_index, firstUnknownRT++, tt);
    }
    
    ORBool newRelevant = false;
    // Trail indices pointers
    if (firstUnknownRT > cumu->_indexFirstUnknownRT._val) {
        assignTRInt(&(cumu->_indexFirstUnknownRT), firstUnknownRT, cumu->_trail);
        newRelevant = true;
    }
    if (firstIrrelevantRT < cumu->_indexFirstIrrelevantRT._val)
        assignTRInt(&(cumu->_indexFirstIrrelevantRT), firstIrrelevantRT, cumu->_trail);
    
    return newRelevant;
}

// Reading the activities data and storing them in the data structure of the propagator
// - Data read: bound, est,  lst,  ect,  lct, minDuration, maxDuration,   minUsage,   maxUsage,  present,  absent
// - Data stored:     _est, _lst, _ect, _lct,    _dur_min,    _dur_max, _usage_min, _usage_max, _present, _absent
static void readData(CPTaskCumulative * cumu)
{
    // array '_bound' is partition in [ Irrelevant | Unbound | Bound | BoundRT | UnboundRT | IrrelevantRT ]
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
        
        if (cumu->_resourceTask[t0])
            bound = [(id<CPResourceTask>)cumu->_tasks[t] readEst:&(cumu->_est[t0]) lst:&(cumu->_lst[t0]) ect:&(cumu->_ect[t0]) lct:&(cumu->_lct[t0]) minDuration:&(cumu->_dur_min[t0]) maxDuration:&(cumu->_dur_max[t0]) present:&(cumu->_present[t0]) absent:&(cumu->_absent[t0]) forResource:cumu];
        else
            bound = [cumu->_tasks[t] readEst:&(cumu->_est[t0]) lst:&(cumu->_lst[t0]) ect:&(cumu->_ect[t0]) lct:&(cumu->_lct[t0]) minDuration:&(cumu->_dur_min[t0]) maxDuration:&(cumu->_dur_max[t0]) present:&(cumu->_present[t0]) absent:&(cumu->_absent[t0]) forResource:cumu];
        cumu->_usage_min[t0] = cumu->_usages[t].min;
        cumu->_usage_max[t0] = cumu->_usages[t].max;
        
        if (cumu->_area != NULL && cumu->_area[t] != NULL) {
            cumu->_area_min[t0] = cumu->_area[t].min;
            cumu->_area_max[t0] = cumu->_area[t].max;
        }
        else {
            cumu->_area_min[t0] = cumu->_usage_min[t0] * cumu->_dur_min[t0];
            cumu->_area_max[t0] = cumu->_usage_max[t0] * cumu->_dur_max[t0];
        }
        
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
    
    // Retrieve all necessary data from resource activities
    const ORInt firstPresentRT = cumu->_firstRT;
    const ORInt firstUnknownRT = cumu->_indexFirstUnknownRT._val;
    for (ORInt tt = firstPresentRT; tt < firstUnknownRT; tt++) {
        const ORInt t0 = cumu->_index[tt];
        const ORInt t  = t0 + cumu->_low;
        ORBool bound;
        const ORInt est_t       = cumu->_est      [t0];
        const ORInt lct_t       = cumu->_lct      [t0];
        const ORInt dur_min_t   = cumu->_dur_min  [t0];
        const ORInt dur_max_t   = cumu->_dur_max  [t0];
        const ORInt usage_min_t = cumu->_usage_min[t0];
        const ORInt usage_max_t = cumu->_usage_max[t0];
        
        assert(cumu->_resourceTask[t0]);
        bound = [(id<CPResourceTask>)cumu->_tasks[t] readEst:&(cumu->_est[t0]) lst:&(cumu->_lst[t0]) ect:&(cumu->_ect[t0]) lct:&(cumu->_lct[t0]) minDuration:&(cumu->_dur_min[t0]) maxDuration:&(cumu->_dur_max[t0]) present:&(cumu->_present[t0]) absent:&(cumu->_absent[t0]) forResource:cumu];
        cumu->_usage_min[t0] = cumu->_usages[t].min;
        cumu->_usage_max[t0] = cumu->_usages[t].max;

        if (cumu->_area != NULL && cumu->_area[t] != NULL) {
            cumu->_area_min[t0] = cumu->_area[t].min;
            cumu->_area_max[t0] = cumu->_area[t].max;
        }
        else {
            cumu->_area_min[t0] = cumu->_usage_min[t0] * cumu->_dur_min[t0];
            cumu->_area_max[t0] = cumu->_usage_max[t0] * cumu->_dur_max[t0];
        }
        
        if (est_t != cumu->_est[t0] || lct_t != cumu->_lct[t0] || dur_min_t != cumu->_dur_min[t0] || dur_max_t != cumu->_dur_max[t0] || usage_min_t != cumu->_usage_min[t0] || usage_max_t != cumu->_usage_max[t0]) {
            // Update the relevant time horizon
            cumu->_begin = min(cumu->_begin, est(cumu, t0));
            cumu->_end   = max(cumu->_end  , lct(cumu, t0));
        }
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

static void readDataRT(CPTaskCumulative * cumu)
{
    // array '_bound' is partition in [ Irrelevant | Unbound | Bound | BoundRT | UnboundRT | IrrelevantRT ]
    ORInt firstUnboundRT    = cumu->_boundFirstUnboundRT._val;
    ORInt firstIrrelevantRT = cumu->_boundFirstIrrelevantRT._val;
    
    // Relevant time horizon for propagation and consistency check
    cumu->_begin = MAXINT;
    cumu->_end   = MAXINT;
    
    // Retrieve all necessary data from the activities
    for (ORInt tt = firstUnboundRT; tt < firstIrrelevantRT; tt++) {
        const ORInt t0 = cumu->_bound[tt];
        const ORInt t  = t0 + cumu->_low;
        ORBool bound;
        
        assert(cumu->_resourceTask[t0]);
        bound = [(id<CPResourceTask>)cumu->_tasks[t] readEst:&(cumu->_est[t0]) lst:&(cumu->_lst[t0]) ect:&(cumu->_ect[t0]) lct:&(cumu->_lct[t0]) minDuration:&(cumu->_dur_min[t0]) maxDuration:&(cumu->_dur_max[t0]) present:&(cumu->_present[t0]) absent:&(cumu->_absent[t0]) forResource:cumu];
        cumu->_usage_min[t0] = cumu->_usages[t].min;
        cumu->_usage_max[t0] = cumu->_usages[t].max;
        
        // Swap bounded or irrelevant tasks to the beginning of the array
        if (isIrrelevant(cumu, t0)) {
            swapORInt(cumu->_bound, --firstIrrelevantRT, tt--);
            continue;
        }
        if (bound && cumu->_usage_max[t0] - cumu->_usage_min[t0] == 0)
            swapORInt(cumu->_bound, firstUnboundRT++, tt);
        
        // Update the relevant time horizon
        cumu->_begin = min(cumu->_begin, est(cumu, t0));
        cumu->_end   = max(cumu->_end  , lct(cumu, t0));
    }
    
    // Trail indices pointers
    if (firstUnboundRT > cumu->_boundFirstUnboundRT._val)
        assignTRInt(&(cumu->_boundFirstUnboundRT), firstUnboundRT, cumu->_trail);
    if (firstIrrelevantRT < cumu->_boundFirstIrrelevantRT._val)
        assignTRInt(&(cumu->_boundFirstIrrelevantRT), firstIrrelevantRT, cumu->_trail);
    
    // Update resource capacity
    cumu->_cap_min = cumu->_capacity.min;
    cumu->_cap_max = cumu->_capacity.max;
}

void getUnboundTasks(CPTaskCumulative * cumu, ORInt * unbound, ORInt * size)
{
    const ORInt firstUnbound = cumu->_boundFirstUnbound._val;
    const ORInt firstBound   = cumu->_boundFirstBound._val;
    
    ORInt idx = 0;
    
    for (ORInt tt = firstUnbound; tt < firstBound; tt++)
        unbound[idx++] = cumu->_bound[tt];
    
    const ORInt firstUnknownRT = cumu->_indexFirstUnknownRT._val;
    
    for (ORInt tt = cumu->_firstRT; tt < firstUnknownRT; tt++) {
        const ORInt t0 = cumu->_index[tt];
        const ORInt t  = t0 + cumu->_low;
        
        if (!isBounded(cumu, t))
            unbound[idx++] = t0;
    }
    assert(idx <= *size);
    *size = idx;
}

void getUnboundTasksRT(CPTaskCumulative * cumu, ORInt * unbound, ORInt * size)
{
    const ORInt firstUnboundRT    = cumu->_boundFirstUnboundRT._val;
    const ORInt firstIrrelevantRT = cumu->_boundFirstIrrelevantRT._val;
    
    ORInt idx = 0;
    
    for (ORInt tt = firstUnboundRT; tt < firstIrrelevantRT; tt++)
        unbound[idx++] = cumu->_bound[tt];
    
    assert(idx <= *size);
    *size = idx;
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
    assert(i_max_usage < cumu->_profileSize);

    // TT filtering on resource capacity variable
    if (i_max_usage >= 0)
        tt_filter_cap(cumu, cumu->_profile[i_max_usage]._level);

    if ((cumu->_tt_filt && i_max_usage >= 0) || cumu->_ttef_check || cumu->_ttef_filt) {
        // Retrieving all unbounded activities
        ORInt unboundSize = cumu->_boundFirstBound._val - cumu->_boundFirstUnbound._val + cumu->_boundFirstIrrelevantRT._val - cumu->_boundFirstUnboundRT._val;
        ORInt unbound[unboundSize];
        getUnboundTasks(cumu, unbound, &unboundSize);
        
        // TT filtering on start and end times variables
        if (cumu->_tt_filt && i_max_usage >= 0)
            tt_filter_start_end_times(cumu, unbound, unboundSize, cumu->_profile[i_max_usage]._level, & update);
        // TTEF propagation and consistency check
        if (!update && (cumu->_ttef_check || cumu->_ttef_filt)) {
            ttef_bounds_propagation(cumu, unbound, unboundSize, & update);
        }
    }
    const ORInt firstUnboundRT = cumu->_boundFirstUnboundRT._val;
    const ORInt firstIrrelevantRT = cumu->_boundFirstIrrelevantRT._val;
    if (!update && !cumu->_resourceTaskAsOptional && firstUnboundRT < firstIrrelevantRT)
        doPropagationRT(cumu);
//    NSLog(@"Cumulative: propagate/0: End\n");
}

static void doPropagationRT(CPTaskCumulative * cumu)
{
    bool update = false;
    
    // Read/update data from resource activities
    readDataRT(cumu);

    // Update the indices
    if (updateIndicesRT(cumu))
        doPropagation(cumu);
    else {
        // Generation of the resource profile and TT consistency check
        const ORInt i_max_usage = tt_build_profile(cumu);
        assert(i_max_usage < cumu->_profileSize);
        
        if ((cumu->_tt_filt && i_max_usage >= 0) || cumu->_ttef_check || cumu->_ttef_filt) {
            // Retrieving all unbounded activities
            ORInt unboundSize = cumu->_boundFirstIrrelevantRT._val - cumu->_boundFirstUnboundRT._val;
            ORInt unbound[unboundSize];
            getUnboundTasksRT(cumu, unbound, &unboundSize);
            
            // TT filtering on start and end times variables
            if (cumu->_tt_filt && i_max_usage >= 0)
                tt_filter_start_end_times(cumu, unbound, unboundSize, cumu->_profile[i_max_usage]._level, & update);
            // TTEF propagation and consistency check
            if (!update && (cumu->_ttef_check || cumu->_ttef_filt)) {
                ttef_bounds_propagation(cumu, unbound, unboundSize, & update);
            }
        }
    }
}

@end
