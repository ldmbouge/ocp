/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Andreas Schutt and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <CPUKernel/CPConstraintI.h>
#import <objcp/CPIntVarI.h>
#import "CPConstraint.h"
#import "CPTask.h"
#import "CPTaskI.h"

#define VERBOSE 0

    // Alternative propagator
    //
@implementation CPAlternative {
    ORInt * _idx;   // Array of alternative task's indices
    TRInt   _size;  // Pointer to the first absent alternative task in the array _idx
    
    TRInt   _watchStart;
    TRInt   _watchLst;
    TRInt   _watchEct;
    TRInt   _watchEnd;
    TRInt   _watchMinDur;
    TRInt   _watchMaxDur;
}
-(id) initCPAlternative: (id<CPTaskVar>) task alternatives: (id<CPTaskVarArray>) alt
{
    self = [super initCPCoreConstraint:task.engine];
    
    _task = task;
    _alt  = alt;
    _idx  = NULL;
    
    NSLog(@"Create constraint CPAlternative\n");
    
    return self;
}
-(void) dealloc
{
    if (_idx != NULL) free(_idx);
    [super dealloc];
}
-(ORStatus) post
{
    const ORInt size = (ORInt) [_alt count];
    const ORInt low  = [_alt low  ];
    const ORInt up   = [_alt up   ];
    
    // Initialise trailed parameters
    _size        = makeTRInt(_trail, size);
    _watchStart  = makeTRInt(_trail, size);
    _watchLst    = makeTRInt(_trail, size);
    _watchEct    = makeTRInt(_trail, size);
    _watchEnd    = makeTRInt(_trail, size);
    _watchMinDur = makeTRInt(_trail, size);
    _watchMaxDur = makeTRInt(_trail, size);
    
    // Allocate memory
    _idx = malloc(size * sizeof(ORInt));
    
    // Check whether memory allocation was successful
    if (_idx == NULL) {
        @throw [[ORExecutionError alloc] initORExecutionError: "CPAlternative: Out of memory!"];
    }
    
    // Initialise misc
    for (ORInt i = 0; i < size; i++) {
        _idx[i] = i + low;
    }
    
    // Initial propagation
    [self initPropagation];
    
    // Subscription of the alternative tasks
    for (ORInt i = low; i <= up; i++) {
        if (_alt[i].isPresent) {
            // Bound change on start
            [_alt[i] whenChangeStartDo:^{
                [_task updateStart:_alt[i].est];
                [_task updateLst  :_alt[i].lst];
            } onBehalf: self];
            // Bound change on end
            [_alt[i] whenChangeEndDo:^{
                [_task updateEnd:_alt[i].lct];
                [_task updateEct:_alt[i].ect];
            } onBehalf: self];
            // Bound change on duration
            if (_alt[i].minDuration < _alt[i].maxDuration) {
                [_alt[i] whenChangeDurationDo: ^{
                    [_task updateMinDuration: _alt[i].minDuration];
                    [_task updateMaxDuration: _alt[i].maxDuration];
                } onBehalf: self];
            }
        }
        else if (!_alt[i].isAbsent) {
            // Change to present
            [_alt[i] whenPresentDo: ^{
                [self propagateAlternativePresence: i];
            } onBehalf: self];
            // Change to absent
            [_alt[i] whenAbsentDo: ^{
                [self propagateAlternativeAbsence: i];
            } onBehalf: self];
            // Bound change on start
            [_alt[i] whenChangeStartDo: ^{
                if (_size._val == 1) {
                    assert(_idx[0] == i);
                    [_task updateStart: _alt[i].est];
                    [_task updateLst  : _alt[i].lst];
                }
                else {
                    if (_watchStart._val == i)
                        [self propagateAlternativeStart];
                    if (_watchLst._val == i)
                        [self propagateAlternativeLst];
                }
            } onBehalf: self];
            // Bound change on end
            [_alt[i] whenChangeEndDo: ^{
                if (_size._val == 1) {
                    assert(_idx[0] == i);
                    [_task updateEnd: _alt[i].lct];
                    [_task updateEct: _alt[i].ect];
                }
                else {
                    if (_watchEnd._val == i)
                        [self propagateAlternativeEnd];
                    if (_watchEct._val == i)
                        [self propagateAlternativeEct];
                }
            } onBehalf: self];
            // Bound change on duration
            [_alt[i] whenChangeDurationDo: ^{
                if (_size._val == 1) {
                    assert(_idx[0] == i);
                    [_task updateMinDuration: _alt[i].minDuration];
                    [_task updateMaxDuration: _alt[i].maxDuration];
                }
                else if (_watchMinDur._val == i || _watchMaxDur._val == i) {
                    [self propagateAlternativeDuration];
                }
            } onBehalf: self];
        }
    }
    
    if (!_task.isAbsent) {
        if (!_task.isPresent) {
            // Change to present
            [_task whenPresentDo: ^{
                if (VERBOSE) printf("*** propagateTaskPresence (Start) ***\n");
                if (_size._val == 1) [_alt[_idx[0]] labelPresent: true];
                if (VERBOSE) printf("*** propagateTaskPresence (End) ***\n");
            } onBehalf: self];
            // Change to absent
            [_task whenAbsentDo: ^{ [self propagateTaskAbsence]; } onBehalf: self];
        }
        // Bound change on start
        [_task whenChangeStartDo: ^{ [self propagateTaskStart]; } onBehalf: self];
        // Bound change on end
        [_task whenChangeEndDo: ^{ [self propagateTaskEnd]; } onBehalf: self];
        // Bound change on duration
        [_task whenChangeDurationDo: ^{ [self propagateTaskDuration]; } onBehalf: self];
    }
    
    return ORSuspend;
}
-(void) propagateTaskAbsence
{
    if (VERBOSE) printf("*** propagateTaskAbsence (Start) ***\n");
    assert(_task.isAbsent);
    for (ORInt ii = 0; ii < _size._val; ii++) {
        const ORInt i = _idx[ii];
        [_alt[i] labelPresent: false];
    }
    assignTRInt(&(_size), 0, _trail);
    if (VERBOSE) printf("*** propagateTaskAbsence (End) ***\n");
}
-(void) propagateTaskStart
{
    if (VERBOSE) printf("*** propagateTaskStart (Start) ***\n");
    for (ORInt ii = 0; ii < _size._val; ii++) {
        const ORInt i = _idx[ii];
        [_alt[i] updateStart: _task.est];
        [_alt[i] updateLst  : _task.lst];
    }
    if (VERBOSE) printf("*** propagateTaskStart (End) ***\n");
}
-(void) propagateTaskEnd
{
    if (VERBOSE) printf("*** propagateTaskEnd (Start) ***\n");
    for (ORInt ii = 0; ii < _size._val; ii++) {
        const ORInt i = _idx[ii];
        [_alt[i] updateEnd: _task.lct];
        [_alt[i] updateEct: _task.ect];
    }
    if (VERBOSE) printf("*** propagateTaskEnd (End) ***\n");
}
-(void) propagateTaskDuration
{
    if (VERBOSE) printf("*** propagateTaskDuration (Start) ***\n");
    for (ORInt ii = 0; ii < _size._val; ii++) {
        const ORInt i = _idx[ii];
        [_alt[i] updateMinDuration: _task.minDuration];
        [_alt[i] updateMaxDuration: _task.maxDuration];
    }
    if (VERBOSE) printf("*** propagateTaskDuration (End) ***\n");
}
-(void) propagateTaskAll
{
    if (VERBOSE) printf("*** propagateTaskAll (Start) ***\n");
    assert(!_task.isAbsent);
    const ORInt start  = _task.est;
    const ORInt lst    = _task.lst;
    const ORInt ect    = _task.ect;
    const ORInt end    = _task.lct;
    const ORInt minDur = _task.minDuration;
    const ORInt maxDur = _task.maxDuration;
    for (ORInt ii = 0; ii < _size._val; ii++) {
        const ORInt i = _idx[ii];
        [_alt[i] updateStart      : start ];
        [_alt[i] updateEnd        : end   ];
        [_alt[i] updateLst        : lst   ];
        [_alt[i] updateEct        : ect   ];
        [_alt[i] updateMinDuration: minDur];
        [_alt[i] updateMaxDuration: maxDur];
    }
    if (VERBOSE) printf("*** propagateTaskAll (End) ***\n");
}
-(void) propagateAlternativeStart
{
    if (VERBOSE) printf("*** propagateAlternativeStart (Start) ***\n");
    ORInt minStart = MAXINT;
    ORInt wStart   = MAXINT;
    for (ORInt ii = 0; ii < _size._val; ii++) {
        const ORInt i = _idx[ii];
        if (minStart > _alt[i].est) {
            minStart = _alt[i].est;
            wStart   = i;
        }
    }
    assert(_alt.low <= wStart  && wStart  <= _alt.up);
    [_task updateStart: minStart];
    if (wStart != _watchStart._val)
        assignTRInt(&(_watchStart), wStart, _trail);
    if (VERBOSE) printf("*** propagateAlternativeStart (End) ***\n");
}
-(void) propagateAlternativeLst
{
    if (VERBOSE) printf("*** propagateAlternativeLst (Start) ***\n");
    ORInt maxLst = MININT;
    ORInt wLst   = MAXINT;
    for (ORInt ii = 0; ii < _size._val; ii++) {
        const ORInt i = _idx[ii];
        if (maxLst < _alt[i].lst) {
            maxLst = _alt[i].lst;
            wLst   = i;
        }
    }
    assert(_alt.low <= wLst && wLst <= _alt.up);
    [_task updateLst: maxLst];
    if (wLst != _watchLst._val)
        assignTRInt(&(_watchLst), wLst, _trail);
    if (VERBOSE) printf("*** propagateAlternativeLst (End) ***\n");
}
-(void) propagateAlternativeEct
{
    if (VERBOSE) printf("*** propagateAlternativeEct (Start) ***\n");
    ORInt minEct = MAXINT;
    ORInt wEct   = MAXINT;
    for (ORInt ii = 0; ii < _size._val; ii++) {
        const ORInt i = _idx[ii];
        if (minEct > _alt[i].ect) {
            minEct = _alt[i].ect;
            wEct   = i;
        }
    }
    assert(_alt.low <= wEct  && wEct  <= _alt.up);
    [_task updateEct: minEct];
    if (wEct != _watchEct._val)
        assignTRInt(&(_watchEct), wEct, _trail);
    if (VERBOSE) printf("*** propagateAlternativeEct (End) ***\n");
}
-(void) propagateAlternativeEnd
{
    if (VERBOSE) printf("*** propagateAlternativeEnd (Start) ***\n");
    ORInt maxEnd = MININT;
    ORInt wEnd   = MAXINT;
    for (ORInt ii = 0; ii < _size._val; ii++) {
        const ORInt i = _idx[ii];
        if (maxEnd < _alt[i].lct) {
            maxEnd = _alt[i].lct;
            wEnd   = i;
        }
    }
    assert(_alt.low <= wEnd && wEnd <= _alt.up);
    [_task updateEnd: maxEnd];
    if (wEnd != _watchEnd._val)
        assignTRInt(&(_watchEnd), wEnd, _trail);
    if (VERBOSE) printf("*** propagateAlternativeEnd (End) ***\n");
}
-(void) propagateAlternativeDuration
{
    if (VERBOSE) printf("*** propagateAlternativeDuration (Start) ***\n");
    ORInt minDur  = MAXINT;
    ORInt maxDur  = MININT;
    ORInt wMinDur = MAXINT;
    ORInt wMaxDur = MAXINT;
    for (ORInt ii = 0; ii < _size._val; ii++) {
        const ORInt i = _idx[ii];
        if (minDur > _alt[i].minDuration) {
            minDur  = _alt[i].minDuration;
            wMinDur = i;
        }
        if (maxDur < _alt[i].maxDuration) {
            maxDur  = _alt[i].maxDuration;
            wMaxDur = i;
        }
    }
    assert(_alt.low <= wMinDur && wMinDur <= _alt.up);
    assert(_alt.low <= wMaxDur && wMaxDur <= _alt.up);
    [_task updateMinDuration: minDur];
    [_task updateMaxDuration: maxDur];
    if (wMinDur != _watchMinDur._val)
        assignTRInt(&(_watchMinDur), wMinDur, _trail);
    if (wMaxDur != _watchMaxDur._val)
        assignTRInt(&(_watchMaxDur), wMaxDur, _trail);
    if (VERBOSE) printf("*** propagateAlternativeDuration (End) ***\n");
}
-(void) propagateAlternativePresence: (ORInt) k
{
    if (VERBOSE) printf("*** propagateAlternativePresence(%d) (Start) ***\n", k);
    if (_size._val > 1) {
        for (ORInt ii = 0; ii < _size._val; ii++) {
            const ORInt i = _idx[ii];
            if (i == k) {
                _idx[ii] = _idx[0];
                _idx[0 ] = i;
            }
            else
                [_alt[i] labelPresent: false];
        }
        assignTRInt(&(_size), 1, _trail);
    }
    assert(_size._val == 1);
    assert(_idx[0] == k);
    assert(_alt[k].isPresent);
    [_task labelPresent: true];
    [self propagateAllEqualities];
    if (VERBOSE) printf("*** propagateAlternativePresence(%d) (End) ***\n", k);
}
-(void) propagateAlternativeAbsence: (ORInt) k
{
    if (VERBOSE) printf("*** propagateAlternativeAbsence(%d) (Start) ***\n", k);
    ORInt size = _size._val;
    for (ORInt ii = 0; ii < size; ii++) {
        const ORInt i = _idx[ii];
        if (i == k) {
            size--;
            _idx[ii]   = _idx[size];
            _idx[size] = i;
            break;
        }
    }
    if (size < _size._val)
        assignTRInt(&(_size), size, _trail);
    if (_size._val == 0) {
        [_task labelPresent: false];
    } else {
        if (_size._val == 1) {
            if (_task.isPresent)
                [_alt[_idx[0]] labelPresent: true];
            else if (_alt[_idx[0]].isPresent) {
                [_task labelPresent: true];
            }
            if (!_alt[_idx[0]].isAbsent)
                [self propagateAllEqualities];
        }
        if (_watchStart._val == k)
            [self propagateAlternativeStart];
        if (_watchEnd._val == k)
            [self propagateAlternativeEnd];
        if (_watchLst._val == k)
            [self propagateAlternativeLst];
        if (_watchEct._val == k)
            [self propagateAlternativeEct];
        if (_watchMinDur._val == k || _watchMaxDur._val == k)
            [self propagateAlternativeDuration];
    }
    if (VERBOSE) printf("*** propagateAlternativeAbsence(%d) (End) ***\n", k);
}
-(void) propagateAllEqualities
{
    if (VERBOSE) printf("*** propagateAllEqualities (Start) ***\n");
    const ORInt k = _idx[0];
    ORBool test = false;
    do {
        [_task   updateStart      : _alt[k].est        ];
        [_task   updateLst        : _alt[k].lst        ];
        [_task   updateEct        : _alt[k].ect        ];
        [_task   updateEnd        : _alt[k].lct        ];
        [_task   updateMinDuration: _alt[k].minDuration];
        [_task   updateMaxDuration: _alt[k].maxDuration];
        [_alt[k] updateStart      : _task.est        ];
        [_alt[k] updateLst        : _task.lst        ];
        [_alt[k] updateEct        : _task.ect        ];
        [_alt[k] updateEnd        : _task.lct        ];
        [_alt[k] updateMinDuration: _task.minDuration];
        [_alt[k] updateMaxDuration: _task.maxDuration];
        test = (_task.est != _alt[k].est || _task.lct != _alt[k].lct ||
                _task.lst != _alt[k].lst || _task.ect != _alt[k].ect ||
             _task.minDuration != _alt[k].minDuration ||
             _task.maxDuration != _alt[k].maxDuration);
    } while (test && !_task.isAbsent && !_alt[k].isAbsent);
    if (VERBOSE) printf("*** propagateAllEqualities (End) ***\n");
}
-(void) initPropagation
{
    ORInt size = _size._val;
    ORInt minStart = MAXINT;
    ORInt maxEnd   = MININT;
    ORInt minEct   = MAXINT;
    ORInt maxLst   = MININT;
    ORInt minDur   = MAXINT;
    ORInt maxDur   = MININT;
    ORInt wStart   = MAXINT;
    ORInt wEnd     = MAXINT;
    ORInt wLst     = MAXINT;
    ORInt wEct     = MAXINT;
    ORInt wMinDur  = MAXINT;
    ORInt wMaxDur  = MAXINT;
    ORBool update  = false;
    ORBool noAltPresent = true;
    
    do {
        if (_task.isAbsent)
            [self propagateTaskAbsence];
        else {
            // Retrieving information from the alternative tasks
            for (ORInt ii = 0; ii < size; ii++) {
                const ORInt i = _idx[ii];
                // Check whether alternative task is absent
                if (_alt[i].isAbsent) {
                    // Alternative task is absent, swap it to the end
                    if (ii < size - 1) {
                        size--;
                        _idx[ii  ] = _idx[size];
                        _idx[size] = i;
                        ii--;
                    }
                }
                else if (_alt[i].isPresent) {
                    // Alternative task is present
                    [self propagateAlternativePresence: i];
                    noAltPresent = false;
                    break;
                }
                else {
                    // Presence of alternative task is still unknown
                    if (_alt[i].est < minStart) {
                        minStart = _alt[i].est;
                        wStart   = i;
                    }
                    if (_alt[i].lct > maxEnd) {
                        maxEnd = _alt[i].lct;
                        wEnd   = i;
                    }
                    if (_alt[i].lst > maxLst) {
                        maxLst = _alt[i].lst;
                        wLst   = i;
                    }
                    if (_alt[i].ect < minEct) {
                        minEct = _alt[i].ect;
                        wEct   = i;
                    }
                    if (_alt[i].minDuration < minDur) {
                        minDur  = _alt[i].minDuration;
                        wMinDur = i;
                    }
                    if (_alt[i].maxDuration > maxDur) {
                        maxDur  = _alt[i].maxDuration;
                        wMaxDur = i;
                    }
                }
            }
            if (size == 1) {
                if (_task.isPresent) {
                    [_alt[_idx[0]] labelPresent: true];
                    noAltPresent = false;
                }
                [self propagateAllEqualities];
            }
            else {
                // Updating the task bounds
                [_task updateStart      : minStart];
                [_task updateEnd        : maxEnd  ];
                [_task updateLst        : maxLst  ];
                [_task updateEct        : minEct  ];
                [_task updateMinDuration: minDur  ];
                [_task updateMaxDuration: maxDur  ];
                // Updating the alternative task bounds
                if (_task.isAbsent)
                    update = true;
                else if (_task.est > minStart || _task.lct < maxEnd || _task.minDuration > minDur || _task.maxDuration < maxDur ||
                         _task.ect > minEct   || _task.lst < maxLst
                         ) {
                    [self propagateTaskAll];
                    update = true;
                }
            }
        }
    } while (update && noAltPresent);
    
    if (noAltPresent) {
        assert(_alt.low <= wStart  && wStart  <= _alt.up);
        assert(_alt.low <= wEnd    && wEnd    <= _alt.up);
        assert(_alt.low <= wLst    && wLst    <= _alt.up);
        assert(_alt.low <= wEct    && wEct    <= _alt.up);
        assert(_alt.low <= wMinDur && wMinDur <= _alt.up);
        assert(_alt.low <= wMaxDur && wMaxDur <= _alt.up);
        assignTRInt(&(_watchStart ), wStart , _trail);
        assignTRInt(&(_watchEnd   ), wEnd   , _trail);
        assignTRInt(&(_watchLst   ), wLst   , _trail);
        assignTRInt(&(_watchEct   ), wEct   , _trail);
        assignTRInt(&(_watchMinDur), wMinDur, _trail);
        assignTRInt(&(_watchMaxDur), wMaxDur, _trail);
        if (size < _size._val)
            assignTRInt(&(_size), size, _trail);
    } else {
        assert(_alt[_idx[0]].isPresent);
        assignTRInt(&(_watchStart ), _idx[0], _trail);
        assignTRInt(&(_watchEnd   ), _idx[0], _trail);
        assignTRInt(&(_watchLst   ), _idx[0], _trail);
        assignTRInt(&(_watchEct   ), _idx[0], _trail);
        assignTRInt(&(_watchMinDur), _idx[0], _trail);
        assignTRInt(&(_watchMaxDur), _idx[0], _trail);
        assignTRInt(&(_size), 1, _trail);
    }
}
-(NSSet*) allVars
{
    NSUInteger nb = [_alt count] + 1;
    NSMutableSet* rv = [[NSMutableSet alloc] initWithCapacity:nb];
    for(ORInt i = _alt.low; i <= _alt.up; i++)
        [rv addObject:_alt[i]];
    [rv addObject:_task];
    [rv autorelease];
    return rv;
}
-(ORUInt) nbUVars
{
    ORUInt nb = 0;
    for(ORInt ii = 0; ii < _size._val; ii++)
        if (![_alt[_idx[ii]] bound])
            nb++;
    if ([_task bound])
        nb++;
    return nb;
}
-(void) dumpState
{
    printf("-+-+- Alternative Dump -+-+-\n");
    printf("task: start [%d, %d]; end [%d, %d]; dur [%d, %d]; ", _task.est, _task.lst, _task.ect, _task.lct, _task.minDuration, _task.maxDuration);
    printf("present %d; absent %d\n", _task.isPresent, _task.isAbsent);
    printf("size %d;\n", _size._val);
    printf("wStart %d; wLst %d; wEct %d; wEnd %d; wMinDur %d; wMaxDur %d;\n", _watchStart._val, _watchLst._val, _watchEct._val, _watchEnd._val, _watchMinDur._val, _watchMaxDur._val);
    printf("_idx = ");
    for (ORInt ii = 0; ii < [_alt count]; ii++) {
        printf("%d:%d ", ii, _idx[ii]);
    }
    printf("\n");
    printf("alternative:\n");
    for (ORInt ii = 0; ii < [_alt count]; ii++) {
        id<CPTaskVar> t = _alt[_idx[ii]];
        printf("\ttask (%d): start [%d, %d]; end [%d, %d]; dur [%d, %d];  present %d; absent %d\n", _idx[ii], t.est, t.lst, t.ect, t.lct, t.minDuration, t.maxDuration, t.isPresent, t.isAbsent);
    }
    printf("-+-+-+-+-+-+-+-+-+-+-+--+-+-\n");
}
@end


// Span constraint
//
@implementation CPSpan {
    ORInt * _idx;   // Array of task's indices
    TRInt   _size;  // Pointer to the first absent compound task in the array _idx
    
    TRInt   _watchStart;
    TRInt   _watchEnd;
    TRInt   _watchLst;
    TRInt   _watchEct;
    
    TRInt   _comPresent;    // If there exist a present compound task
}
-(id) initCPSpan:(id<CPTaskVar>)task compound:(id<CPTaskVarArray>)compound
{
    self = [super initCPCoreConstraint:[task engine]];
    
    _task     = task;
    _compound = compound;
    _idx      = NULL;
    
    return self;
}
-(void) dealloc
{
    if (_idx != NULL) free(_idx);
    [super dealloc];
}
-(ORStatus) post
{
    const ORInt size = (ORInt) [_compound count];
    const ORInt low  = [_compound low  ];
    const ORInt up   = [_compound up   ];
    
    // Initialise trailed parameters
    _size        = makeTRInt(_trail, size);
    _watchStart  = makeTRInt(_trail, size);
    _watchEnd    = makeTRInt(_trail, size);
    _watchLst    = makeTRInt(_trail, size);
    _watchEct    = makeTRInt(_trail, size);
    _comPresent  = makeTRInt(_trail, 0);
    
    // Allocate memory
    _idx = malloc(size * sizeof(ORInt));
    
    // Check whether memory allocation was successful
    if (_idx == NULL) {
        @throw [[ORExecutionError alloc] initORExecutionError: "CPAlternative: Out of memory!"];
    }
    
    // Initialise misc
    for (ORInt i = 0; i < size; i++) {
        _idx[i] = i + low;
    }
    
    // Initial propagation
    [self initPropagation];
    
    // Subscription of the span tasks
    for (ORInt i = low; i <= up; i++) {
        if (!_compound[i].isAbsent) {
            // Change to present
            [_compound[i] whenPresentDo: ^{ [self propagateSpanPresence: i]; } onBehalf: self];
            // Change to absent
            [_compound[i] whenAbsentDo: ^{ [self propagateSpanAbsence: i]; } onBehalf: self];
            // Bound change on start
            [_compound[i] whenChangeStartDo: ^{
                if (_size._val == 1) {
                    assert(_idx[0] == i);
                    [_task updateStart: _compound[i].est];
                    [_task updateLst  : _compound[i].lst];
                }
                else {
                    if (_watchStart._val == i)
                        [self propagateSpanStart];
                    if ((_watchLst._val == i && _comPresent._val == 0) || (_compound[i].isPresent && _compound[i].lst < _task.lst))
                        [self propagateSpanLst];
                }
            } onBehalf: self];
            // Bound change on end
            [_compound[i] whenChangeEndDo: ^{
                if (_size._val == 1) {
                    assert(_idx[0] == i);
                    [_task updateEnd: _compound[i].lct];
                    [_task updateEct: _compound[i].ect];
                }
                else {
                    if (_watchEnd._val == i)
                        [self propagateSpanEnd];
                    if ((_watchEct._val == i && _comPresent._val == 0) || (_compound[i].isPresent && _compound[i].ect > _task.ect))
                        [self propagateSpanEct];
                }
            } onBehalf: self];
        }
    }
    
    // Subscription of the meta task
    if (!_task.isAbsent) {
        if (!_task.isPresent) {
            // Change to present
            [_task whenPresentDo: ^{ [self propagateTaskPresence]; } onBehalf: self];
            // Change to absent
            [_task whenAbsentDo: ^{ [self propagateTaskAbsence]; } onBehalf: self];
        }
        // Bound change on start
        [_task whenChangeStartDo: ^{ [self propagateTaskStart]; } onBehalf: self];
        // Bound change on end
        [_task whenChangeEndDo: ^{ [self propagateTaskEnd]; } onBehalf: self];
    }
    
    return ORSuspend;
}
-(void) propagateTaskPresence
{
    if (VERBOSE) printf("*** propagateTaskPresence (Start) ***\n");
    if (_size._val <= 1)
        [_compound[_idx[0]] labelPresent: true];
    if (VERBOSE) printf("*** propagateTaskPresence (End) ***\n");
}
-(void) propagateTaskAbsence
{
    if (VERBOSE) printf("*** propagateTaskAbsence (Start) ***\n");
    assert(_task.isAbsent);
    for (ORInt ii = 0; ii < _size._val; ii++) {
        const ORInt i = _idx[ii];
        [_compound[i] labelPresent: false];
    }
    assignTRInt(&(_size), 0, _trail);
    if (VERBOSE) printf("*** propagateTaskAbsence (End) ***\n");
}
-(void) propagateTaskStart
{
    if (VERBOSE) printf("*** propagateTaskStart (Start) ***\n");
    ORInt k = -1;
    ORInt c = 0;
    for (ORInt ii = 0; ii < _size._val; ii++) {
        const ORInt i = _idx[ii];
        [_compound[i] updateStart: _task.est];
        if (_compound[i].est <= _task.lst) {
            k = i;
            c++;
        }
    }
    if (c == 1) {
        assert(_compound.low <= k  && k  <= _compound.up);
        [_compound[k] updateLst:_task.lst];
        if (_task.isPresent)
            [_compound[k] labelPresent:true];
    }
    if (VERBOSE) printf("*** propagateTaskStart (End) ***\n");
}
-(void) propagateTaskEnd
{
    if (VERBOSE) printf("*** propagateTaskEnd (Start) ***\n");
    ORInt k = -1;
    ORInt c = 0;
    for (ORInt ii = 0; ii < _size._val; ii++) {
        const ORInt i = _idx[ii];
        [_compound[i] updateEnd: _task.lct];
        if (_task.ect <= _compound[i].lct) {
            k = i;
            c++;
        }
    }
    if (c == 1) {
        assert(_compound.low <= k  && k  <= _compound.up);
        [_compound[k] updateEct:_task.ect];
        if (_task.isPresent)
            [_compound[k] labelPresent:true];
    }
    if (VERBOSE) printf("*** propagateTaskEnd (End) ***\n");
}
-(void) propagateTaskAll
{
    if (VERBOSE) printf("*** propagateTaskAll (Start) ***\n");
    assert(!_task.isAbsent);
    const ORInt start  = _task.est;
    const ORInt end    = _task.lct;
    ORInt kLst = -1;
    ORInt cLst = 0;
    ORInt kEct = -1;
    ORInt cEct = 0;
    for (ORInt ii = 0; ii < _size._val; ii++) {
        const ORInt i = _idx[ii];
        [_compound[i] updateStart: start ];
        [_compound[i] updateEnd  : end   ];
        if (_task.ect <= _compound[i].lct) {
            kEct = i;
            cEct++;
        }
        if (_compound[i].est <= _task.lst) {
            kLst = i;
            cLst++;
        }
    }
    if (cLst == 1) {
        assert(_compound.low <= kLst  && kLst  <= _compound.up);
        [_compound[kLst] updateLst:_task.lst];
        if (_task.isPresent)
            [_compound[kLst] labelPresent:true];
    }
    if (cEct == 1) {
        assert(_compound.low <= kEct  && kEct  <= _compound.up);
        [_compound[kEct] updateEct:_task.ect];
        if (_task.isPresent)
            [_compound[kEct] labelPresent:true];
    }
    if (VERBOSE) printf("*** propagateTaskAll (End) ***\n");
}
-(void) propagateSpanStart
{
    if (VERBOSE) printf("*** propagateSpanStart (Start) ***\n");
    ORInt minStart = MAXINT;
    ORInt wStart   = MAXINT;
    for (ORInt ii = 0; ii < _size._val; ii++) {
        const ORInt i = _idx[ii];
        if (minStart > _compound[i].est) {
            minStart = _compound[i].est;
            wStart   = i;
        }
    }
    assert(_compound.low <= wStart  && wStart  <= _compound.up);
    [_task updateStart: minStart];
    if (wStart != _watchStart._val)
        assignTRInt(&(_watchStart), wStart, _trail);
    if (VERBOSE) printf("*** propagateSpanStart (End) ***\n");
}
-(void) propagateSpanLst
{
    if (VERBOSE) printf("*** propagateSpanLst (Start) ***\n");
    ORInt newLst = MAXINT;
    ORInt wLst   = MAXINT;
    if (_comPresent._val == 1) {
        for (ORInt ii = 0; ii < _size._val; ii++) {
            const ORInt i = _idx[ii];
            if (_compound[i].isPresent && newLst > _compound[i].lst) {
                newLst = _compound[i].lst;
                wLst   = i;
            }
        }
    }
    else {
        for (ORInt ii = 0; ii < _size._val; ii++) {
            const ORInt i = _idx[ii];
            if (newLst < _compound[i].lst) {
                newLst = _compound[i].lst;
                wLst   = i;
            }
        }
    }
    assert(_compound.low <= wLst  && wLst  <= _compound.up);
    [_task updateLst: newLst];
    if (wLst != _watchLst._val)
        assignTRInt(&(_watchLst), wLst, _trail);
    if (VERBOSE) printf("*** propagateSpanLst (End) ***\n");
}
-(void) propagateSpanEct
{
    if (VERBOSE) printf("*** propagateSpanEct (Start) ***\n");
    ORInt newEct = MAXINT;
    ORInt wEct   = MAXINT;
    if (_comPresent._val == 1) {
        for (ORInt ii = 0; ii < _size._val; ii++) {
            const ORInt i = _idx[ii];
            if (_compound[i].isPresent && newEct < _compound[i].ect) {
                newEct = _compound[i].ect;
                wEct   = i;
            }
        }
    }
    else {
        for (ORInt ii = 0; ii < _size._val; ii++) {
            const ORInt i = _idx[ii];
            if (newEct > _compound[i].ect) {
                newEct = _compound[i].ect;
                wEct   = i;
            }
        }
    }
    assert(_compound.low <= wEct  && wEct  <= _compound.up);
    [_task updateEct: newEct];
    if (wEct != _watchEct._val)
        assignTRInt(&(_watchLst), wEct, _trail);
    if (VERBOSE) printf("*** propagateSpanEct (End) ***\n");
}
-(void) propagateSpanEnd
{
    if (VERBOSE) printf("*** propagateSpanEnd (Start) ***\n");
    ORInt maxEnd = MININT;
    ORInt wEnd   = MAXINT;
    for (ORInt ii = 0; ii < _size._val; ii++) {
        const ORInt i = _idx[ii];
        if (maxEnd < _compound[i].lct) {
            maxEnd = _compound[i].lct;
            wEnd   = i;
        }
    }
    assert(_compound.low <= wEnd && wEnd <= _compound.up);
    [_task updateEnd: maxEnd];
    if (wEnd != _watchEnd._val)
        assignTRInt(&(_watchEnd), wEnd, _trail);
    if (VERBOSE) printf("*** propagateSpanEnd (End) ***\n");
}
-(void) propagateSpanPresence: (ORInt) k
{
    if (VERBOSE) printf("*** propagateSpanPresence(%d) (Start) ***\n", k);
    [_task labelPresent: true];
    if (_comPresent._val == 0)
        assignTRInt(&(_comPresent), 1, _trail);
    [self propagateSpanLst];
    [self propagateSpanEct];
    if (VERBOSE) printf("*** propagateSpanPresence(%d) (End) ***\n", k);
}
-(void) propagateSpanAbsence: (ORInt) k
{
    if (VERBOSE) printf("*** propagateSpanAbsence(%d) (Start) ***\n", k);
    ORInt size = _size._val;
    for (ORInt ii = 0; ii < size; ii++) {
        const ORInt i = _idx[ii];
        if (i == k) {
            size--;
            _idx[ii]   = _idx[size];
            _idx[size] = i;
            break;
        }
    }
    if (size < _size._val)
        assignTRInt(&(_size), size, _trail);
    if (_size._val == 0) {
        [_task labelPresent: false];
    }
    else {
        if (_size._val == 1 && _task.isPresent) {
            [_compound[_idx[0]] labelPresent: true];
            [self propagateAllEqualities];
        }
        if (_watchStart._val == k)
            [self propagateSpanStart];
        if (_watchEnd._val == k)
            [self propagateSpanEnd];
        if (_watchLst._val == k)
            [self propagateSpanLst];
        if (_watchEct._val == k)
            [self propagateSpanEct];
    }
    if (VERBOSE) printf("*** propagateSpanAbsence(%d) (End) ***\n", k);
}
-(void) propagateAllEqualities
{
    assert(_size._val == 1);
    if (VERBOSE) printf("*** propagateAllEqualities (Start) ***\n");
    const ORInt k = _idx[0];
    ORBool test = false;
    do {
        [_task        updateStart      : _compound[k].est ];
        [_task        updateEnd        : _compound[k].lct ];
        [_task        updateLst        : _compound[k].lst ];
        [_task        updateEct        : _compound[k].ect ];
        [_compound[k] updateStart      : _task.est        ];
        [_compound[k] updateEnd        : _task.lct        ];
        [_compound[k] updateLst        : _task.lst        ];
        [_compound[k] updateEct        : _task.ect        ];
        test = (_task.est != _compound[k].est || _task.lct != _compound[k].lct ||
                _task.lst != _compound[k].est || _task.ect != _compound[k].ect);
    } while (test && !_task.isAbsent && !_compound[k].isAbsent);
    if (VERBOSE) printf("*** propagateAllEqualities (End) ***\n");
}
-(void) initPropagation
{
    ORInt size = _size._val;
    ORInt minStart = MAXINT;
    ORInt maxEnd   = MININT;
    ORInt newLst   = MININT;
    ORInt newEct   = MAXINT;
    ORInt wStart   = MAXINT;
    ORInt wEnd     = MAXINT;
    ORInt wLst     = MAXINT;
    ORInt wEct     = MAXINT;
    ORBool update  = false;
    
    do {
        if (_task.isAbsent)
            [self propagateTaskAbsence];
        else {
            // Retrieving information from the compound tasks
            for (ORInt ii = 0; ii < size; ii++) {
                const ORInt i = _idx[ii];
                // Check whether alternative task is absent
                if (_compound[i].isAbsent) {
                    // Alternative task is absent, swap it to the end
                    if (ii < size - 1) {
                        size--;
                        _idx[ii  ] = _idx[size];
                        _idx[size] = i;
                        ii--;
                    }
                }
                else {
                    if (_compound[i].isPresent) {
                        if (!_task.isPresent)
                            [_task labelPresent: true];
                        if (_comPresent._val == 0) {
                            assignTRInt(&(_comPresent), 1, _trail);
                            if (newLst == MININT)
                                newLst = MAXINT;
                            if (newEct == MAXINT)
                                newEct = MININT;
                        }
                    }
                    // Presence of compound task is still unknown
                    if (_compound[i].est < minStart) {
                        minStart = _compound[i].est;
                        wStart   = i;
                    }
                    if (_compound[i].lct > maxEnd) {
                        maxEnd = _compound[i].lct;
                        wEnd   = i;
                    }
                    if ((_compound[i].isPresent && _compound[i].lst < newLst) ||
                        (_comPresent._val == 0 && _compound[i].lst > newLst)) {
                        newLst = _compound[i].lst;
                        wLst   = i;
                    }
                    if ((_compound[i].isPresent && _compound[i].ect > newEct) ||
                        (_comPresent._val == 0 && _compound[i].ect < newEct)) {
                        newEct = _compound[i].ect;
                        wEct   = i;
                    }
                }
            }
            if (size == 1) {
                if (_task.isPresent)
                    [_compound[_idx[0]] labelPresent: true];
                [self propagateAllEqualities];
            }
            else {
                // Updating the task bounds
                [_task updateStart      : minStart];
                [_task updateEnd        : maxEnd  ];
                [_task updateLst        : newLst  ];
                [_task updateEct        : newEct  ];
                // Updating the alternative task bounds
                if (_task.isAbsent)
                    update = true;
                else if (_task.est > minStart || _task.lct < maxEnd) {
                    [self propagateTaskAll];
                    update = true;
                }
            }
        }
    } while (update);
    
    assert(_compound.low <= wStart  && wStart  <= _compound.up);
    assert(_compound.low <= wEnd    && wEnd    <= _compound.up);
    assert(_compound.low <= wLst    && wLst    <= _compound.up);
    assert(_compound.low <= wEct    && wEct    <= _compound.up);
    assignTRInt(&(_watchStart ), wStart , _trail);
    assignTRInt(&(_watchEnd   ), wEnd   , _trail);
    assignTRInt(&(_watchLst   ), wLst   , _trail);
    assignTRInt(&(_watchEct   ), wEct   , _trail);
    if (size < _size._val)
        assignTRInt(&(_size), size, _trail);
}
-(NSSet*) allVars
{
    NSUInteger nb = [_compound count] + 1;
    NSMutableSet* rv = [[NSMutableSet alloc] initWithCapacity:nb];
    for(ORInt i = _compound.low; i <= _compound.up; i++)
        [rv addObject:_compound[i]];
    [rv addObject:_task];
    [rv autorelease];
    return rv;
}
-(ORUInt) nbUVars
{
    ORUInt nb = 0;
    for(ORInt ii = 0; ii < _size._val; ii++)
        if (![_compound[_idx[ii]] bound])
            nb++;
    if ([_task bound])
        nb++;
    return nb;
}
@end

@implementation CPTaskPrecedence

-(id) initCPTaskPrecedence: (id<CPTaskVar>) before after: (id<CPTaskVar>) after
{
   self = [super initCPCoreConstraint: [before engine]];

   _before = before;
   _after  = after;
//    NSLog(@"Create constraint CPTaskPrecedence\n");
   return self;
}
-(void) dealloc
{
   [super dealloc];
}
-(ORStatus) post
{
   [self propagate];
   if (![_before bound] && ![_after bound]) {
      [_before whenChangeStartPropagate: self];
       [_before whenChangeDurationPropagate: self];
      [_after whenChangeEndPropagate: self];
   }
   return ORSuspend;
}
-(void) propagate
{
   [_after updateStart: [_before ect]];
   [_before updateEnd: [_after lst]];
}
-(NSSet*) allVars
{
   ORInt size = 2;
   NSMutableSet* rv = [[NSMutableSet alloc] initWithCapacity:size];
   [rv addObject:_before];
   [rv addObject:_after];
   [rv autorelease];
   return rv;
}
-(ORUInt) nbUVars
{
   return 2;
}
@end

@implementation CPOptionalTaskPrecedence

-(id) initCPOptionalTaskPrecedence: (id<CPTaskVar>) before after: (id<CPTaskVar>) after
{
   self = [super initCPCoreConstraint: [before engine]];
   
   _before = before;
   _after  = after;
    NSLog(@"Create constraint CPOptionalTaskPrecedence\n");
   return self;
}
-(void) dealloc
{
   [super dealloc];
}
-(ORStatus) post
{
   [self propagate];
   if (![_before bound] && ![_after bound]) {
      [_before whenChangeStartPropagate: self];
       [_before whenChangeDurationPropagate: self];
      [_after whenChangeEndPropagate: self];
      if ([_before isOptional])
         [_before whenPresentPropagate: self];
      if ([_after isOptional])
         [_after whenPresentPropagate: self];
   }
   return ORSuspend;
}
-(void) propagate
{
   if ([_before isPresent])
      [_after updateStart: [_before ect]];
   if ([_after isPresent])
      [_before updateEnd: [_after lst]];
}
-(NSSet*) allVars
{
   ORInt size = 2;
   NSMutableSet* rv = [[NSMutableSet alloc] initWithCapacity:size];
   [rv addObject:_before];
   [rv addObject:_after];
   [rv autorelease];
   return rv;
}
-(ORUInt) nbUVars
{
   return 2;
}
@end

@implementation CPOptionalResourceTaskPrecedence {
    id<CPConstraint> _beforeRes;
    id<CPConstraint> _afterRes;
}
-(id) initCPOptionalResourceTaskPrecedence:(id<CPTaskVar>)before res:(id<CPConstraint>)bRes after:(id<CPTaskVar>)after res:(id<CPConstraint>)aRes
{
    self = [super initCPCoreConstraint: [before engine]];
    
    _before    = before;
    _after     = after;
    _beforeRes = bRes;
    _afterRes  = aRes;
    NSLog(@"Create constraint CPOptionalResourceTaskPrecedence\n");
    return self;
}
-(void) dealloc
{
    [super dealloc];
}
-(ORStatus) post
{
    if (_beforeRes != NULL && _afterRes != NULL) {
        CPResourceTask * before = (CPResourceTask *)_before;
        CPResourceTask * after  = (CPResourceTask *)_after;
        [self propagateResTaskBeforeResTask];
        if (![_before bound] && ![_after bound] && ![before isAbsentOn:_beforeRes] && ![after isAbsentOn:_afterRes]) {
            [_before whenChangeStartDo:^(){[self propagateResTaskBeforeResTask];} onBehalf:self];
            [_before whenChangeDurationDo:^(){[self propagateResTaskBeforeResTask];} onBehalf:self];
            [_after whenChangeEndDo:^(){[self propagateResTaskBeforeResTask];} onBehalf:self];
            if ([_before isOptional])
                [_before whenPresentDo:^(){[self propagateResTaskBeforeResTask];} onBehalf:self];
            if ([_after isOptional])
                [_after whenPresentDo:^(){[self propagateResTaskBeforeResTask];} onBehalf:self];
        }
    }
    else if (_beforeRes != NULL) {
        CPResourceTask * before = (CPResourceTask *)_before;
        [self propagateResTaskBeforeTask];
        if (![_before bound] && ![_after bound] && ![before isAbsentOn:_beforeRes]) {
            [_before whenChangeStartDo:^(){[self propagateResTaskBeforeTask];} onBehalf:self];
            [_before whenChangeDurationDo:^(){[self propagateResTaskBeforeTask];} onBehalf:self];
            [_after whenChangeEndDo:^(){[self propagateResTaskBeforeTask];} onBehalf:self];
            if ([_before isOptional])
                [_before whenPresentDo:^(){[self propagateResTaskBeforeTask];} onBehalf:self];
            if ([_after isOptional])
                [_after whenPresentDo:^(){[self propagateResTaskBeforeTask];} onBehalf:self];
        }
    }
    else if (_afterRes != NULL) {
        CPResourceTask * after  = (CPResourceTask *)_after;
        [self propagateTaskBeforeResTask];
        if (![_before bound] && ![_after bound] && ![after isAbsentOn:_afterRes]) {
            [_before whenChangeStartDo:^(){[self propagateTaskBeforeResTask];} onBehalf:self];
            [_before whenChangeDurationDo:^(){[self propagateTaskBeforeResTask];} onBehalf:self];
            [_after whenChangeEndDo:^(){[self propagateTaskBeforeResTask];} onBehalf:self];
            if ([_before isOptional])
                [_before whenPresentDo:^(){[self propagateTaskBeforeResTask];} onBehalf:self];
            if ([_after isOptional])
                [_after whenPresentDo:^(){[self propagateTaskBeforeResTask];} onBehalf:self];
        }
    }
    else {
        assert(_beforeRes == NULL && _afterRes == NULL);
        [self propagate];
        if (![_before bound] && ![_after bound]) {
            [_before whenChangeStartPropagate: self];
            [_before whenChangeDurationPropagate: self];
            [_after whenChangeEndPropagate: self];
            if ([_before isOptional])
                [_before whenPresentPropagate: self];
            if ([_after isOptional])
                [_after whenPresentPropagate: self];
        }
    }
    return ORSuspend;
}
-(void) propagateResTaskBeforeTask
{
    assert(_beforeRes != NULL && _afterRes == NULL);
    CPResourceTask * before = (CPResourceTask *)_before;
    if ([before isPresentOn:_beforeRes]) {
        [_after updateStart: [_before ect]];
        if ([_after isPresent])
            [_before updateEnd: [_after lst]];
    }
}
-(void) propagateTaskBeforeResTask
{
    assert(_beforeRes == NULL && _afterRes != NULL);
    CPResourceTask * after = (CPResourceTask *)_after;
    if ([after isPresentOn:_afterRes]) {
        if ([_before isPresent])
            [_after updateStart: [_before ect]];
        [_before updateEnd: [_after lst]];
    }
}
-(void) propagateResTaskBeforeResTask
{
    assert(_beforeRes != NULL && _afterRes != NULL);
    CPResourceTask * before = (CPResourceTask *)_before;
    CPResourceTask * after  = (CPResourceTask *)_after;
    if ([before isPresentOn:_beforeRes] && [after isPresentOn:_afterRes]) {
        if ([_before isPresent])
            [_after updateStart: [_before ect]];
        [_before updateEnd: [_after lst]];
    }
}
-(void) propagate
{
    assert(_beforeRes == NULL && _afterRes == NULL);
    if ([_before isPresent])
        [_after updateStart: [_before ect]];
    if ([_after isPresent])
        [_before updateEnd: [_after lst]];
}
-(NSSet*) allVars
{
    ORInt size = 2;
    NSMutableSet* rv = [[NSMutableSet alloc] initWithCapacity:size];
    [rv addObject:_before];
    [rv addObject:_after];
    [rv autorelease];
    return rv;
}
-(ORUInt) nbUVars
{
    return 2;
}
@end

@implementation CPTaskIsFinishedBy

-(id) initCPTaskIsFinishedBy: (id<CPTaskVar>) task : (id<CPIntVar>) date
{
   self = [super initCPCoreConstraint: [task engine]];
   
   _task = task;
   _date  = date;
   //NSLog(@"Create constraint CPTaskIsFinishedBy\n");
   return self;
}
-(void) dealloc
{
   [super dealloc];
}
-(ORStatus) post
{
   [self propagate];
   if (![_task bound] && ![_date bound]) {
      [_task whenChangeStartPropagate: self];
      [_date whenChangeMaxPropagate: self];
   }
   return ORSuspend;
}
-(void) propagate
{
   if ([_task isPresent])
      [_date updateMin: [_task ect]];
   [_task updateEnd: [_date max]];
}
-(NSSet*) allVars
{
   ORInt size = 2;
   NSMutableSet* rv = [[NSMutableSet alloc] initWithCapacity:size];
   [rv addObject:_task];
   [rv addObject:_date];
   [rv autorelease];
   return rv;
}
-(ORUInt) nbUVars
{
   return 2;
}
@end


@implementation CPTaskPresence

-(id) initCPTaskPresence: (id<CPTaskVar>) task : (id<CPIntVar>) presence
{
    self = [super initCPCoreConstraint: [task engine]];
    
    _task = task;
    _bool = presence;
    NSLog(@"Create constraint CPTaskPresence\n");
    return self;
}
-(void) dealloc
{
    [super dealloc];
}
-(ORStatus) post
{
    [self propagate];
    if (![_task bound] && ![_bool bound]) {
        [_task whenAbsentDo:^(){[_bool updateMax:0];} onBehalf:self];
        [_task whenPresentDo:^(){[_bool updateMin:1];} onBehalf:self];
        [_bool whenChangeBoundsPropagate: self];
        [_bool whenChangeBoundsDo:^(){
            assert([_bool bound] && (_bool.value == 0 || _bool.value == 1));
            [_task labelPresent:_bool.value];
        } onBehalf:self];
    }
    return ORSuspend;
}
-(NSSet*) allVars
{
    ORInt size = 2;
    NSMutableSet* rv = [[NSMutableSet alloc] initWithCapacity:size];
    [rv addObject:_task];
    [rv addObject:_bool];
    [rv autorelease];
    return rv;
}
-(ORUInt) nbUVars
{
    return 2;
}
@end

@implementation CPTaskStart

-(id) initCPTaskStart:(id<CPTaskVar>)task :(id<CPIntVar>)start
{
    self = [super initCPCoreConstraint:[task engine]];
    
    _task  = task;
    _start = start;
//    NSLog(@"Create constraint CPTaskStart\n");
    return self;
}
-(void) dealloc
{
    [super dealloc];
}
-(ORStatus) post
{
    [self propagate];
    if (![_task bound] && ![_start bound]) {
        [_task  whenChangeStartPropagate   : self];
        [_task  whenChangeEndPropagate     : self];
        [_task  whenChangeDurationPropagate: self];
        [_start whenChangeBoundsPropagate  : self];
    }
    return ORSuspend;
}
-(void) propagate
{
    [_start updateMin  : [_task  est]];
    [_start updateMax  : [_task  lst]];
    [_task  updateStart: [_start min]];
    [_task  updateLst  : [_start max]];
}
-(NSSet*) allVars
{
    ORInt size = 2;
    NSMutableSet* rv = [[NSMutableSet alloc] initWithCapacity:size];
    [rv addObject:_task];
    [rv addObject:_start];
    [rv autorelease];
    return rv;
}
-(ORUInt) nbUVars
{
    return 2;
}
@end


@implementation CPTaskDuration

-(id) initCPTaskDuration: (id<CPTaskVar>) task : (id<CPIntVar>) duration
{
   self = [super initCPCoreConstraint: [task engine]];
   
   _task = task;
   _duration  = duration;
//    NSLog(@"Create constraint CPTaskDuration\n");
   return self;
}
-(void) dealloc
{
   [super dealloc];
}
-(ORStatus) post
{
   [self propagate];
   if (![_task bound] && ![_duration bound]) {
      [_task whenChangeDurationPropagate: self];
      [_duration whenChangeBoundsPropagate: self];
   }
   return ORSuspend;
}
-(void) propagate
{
   [_duration updateMin: [_task minDuration]];
   [_duration updateMax: [_task maxDuration]];
   [_task updateMinDuration: [_duration min]];
   [_task updateMaxDuration: [_duration max]];
}
-(NSSet*) allVars
{
   ORInt size = 2;
   NSMutableSet* rv = [[NSMutableSet alloc] initWithCapacity:size];
   [rv addObject:_task];
   [rv addObject:_duration];
   [rv autorelease];
   return rv;
}
-(ORUInt) nbUVars
{
   return 2;
}
@end

@implementation CPTaskEnd

-(id) initCPTaskEnd:(id<CPTaskVar>)task :(id<CPIntVar>)end
{
    self = [super initCPCoreConstraint:[task engine]];
    
    _task  = task;
    _end = end;
//    NSLog(@"Create constraint CPTaskEnd\n");
    return self;
}
-(void) dealloc
{
    [super dealloc];
}
-(ORStatus) post
{
    [self propagate];
    if (![_task bound] && ![_end bound]) {
        [_task  whenChangeStartPropagate   : self];
        [_task  whenChangeEndPropagate     : self];
        [_task  whenChangeDurationPropagate: self];
        [_end   whenChangeBoundsPropagate  : self];
    }
    return ORSuspend;
}
-(void) propagate
{
    [_end  updateMin: [_task ect]];
    [_end  updateMax: [_task lct]];
    [_task updateEct: [_end  min]];
    [_task updateEnd: [_end  max]];
}
-(NSSet*) allVars
{
    ORInt size = 2;
    NSMutableSet* rv = [[NSMutableSet alloc] initWithCapacity:size];
    [rv addObject:_task];
    [rv addObject:_end];
    [rv autorelease];
    return rv;
}
-(ORUInt) nbUVars
{
    return 2;
}
@end


@implementation CPTaskAddTransitionTime

-(id) initCPTaskAddTransitionTime:(id<CPTaskVar>) normal extended:(id<CPTaskVar>)extended time:(id<CPIntVar>)time
{
    self = [super initCPCoreConstraint: [normal engine]];
    
    _normal   = normal;
    _extended = extended;
    _time     = time;
    NSLog(@"Create constraint CPTaskAddTransitionTime\n");
    return self;
}
-(void) dealloc
{
    [super dealloc];
}
-(ORStatus) post
{
    [self propagate];
    if (![_normal bound] && ![_extended bound] && ![_time bound]) {
        [_normal   whenChangeStartPropagate: self];
        [_normal   whenChangeEndPropagate  : self];
        [_extended whenChangeStartPropagate: self];
        [_extended whenChangeEndPropagate  : self];
        [_time     whenChangePropagate     : self];
        // Presence and absence propagation
        [_normal   whenAbsentDo :^(){[_extended labelPresent:false];} onBehalf:self];
        [_normal   whenPresentDo:^(){[_extended labelPresent:true ];} onBehalf:self];
        [_extended whenAbsentDo :^(){[_normal   labelPresent:false];} onBehalf:self];
        [_extended whenPresentDo:^(){[_normal   labelPresent:true ];} onBehalf:self];
    }
    return ORSuspend;
}
-(void) propagate
{
    if (_normal.isAbsent)
        return ;
    
    // Updating the duration
    [_normal   updateMinDuration:[_extended minDuration] - [_time min]];
    [_normal   updateMaxDuration:[_extended maxDuration] - [_time max]];
    [_extended updateMinDuration:[_normal   minDuration] + [_time min]];
    [_extended updateMaxDuration:[_normal   maxDuration] + [_time max]];
    [_time     updateMin:[_extended minDuration] - [_normal minDuration]];
    [_time     updateMax:[_extended maxDuration] - [_normal maxDuration]];
    
    // Updating the start and end time
    [_normal   updateStart: [_extended est]];
    [_extended updateStart: [_normal   est]];
    [_normal   updateEnd  : [_extended lct] - [_time min]];
    [_extended updateEnd  : [_normal   lct] + [_time max]];
    [_normal   updateLst  : [_extended lst]];
    [_extended updateLst  : [_normal   lst]];
    [_normal   updateEct  : [_extended ect] - [_time max]];
    [_extended updateEct  : [_normal   ect] + [_time min]];
}
-(NSSet*) allVars
{
    ORInt size = 2;
    NSMutableSet* rv = [[NSMutableSet alloc] initWithCapacity:size];
    [rv addObject:_normal];
    [rv addObject:_extended];
    [rv addObject:_time];
    [rv autorelease];
    return rv;
}
-(ORUInt) nbUVars
{
    return 2;
}
@end

@implementation CPTaskMultDur

-(id) initCPTaskMultDur:(id<CPTaskVar>)x by:(id<CPIntVar>)y equal:(id<CPIntVar>)z
{
    if ([y min] < 0 || [z min] < 0) {
        @throw [[ORExecutionError alloc] initORExecutionError: "CPTaskMultDur: Non-negative values for y and z expected!"];
    }
    
    self = [super initCPCoreConstraint:[x engine]];
    
    _priority = HIGHEST_PRIO - 1;
    _x = x;
    _y = (CPIntVar*)y;
    _z = (CPIntVar*)z;
//    NSLog(@"Create constraint CPTaskMultDur\n");
    return self;
}
-(void) dealloc
{
    [super dealloc];
}
-(ORStatus) post
{
    [self propagate];
    
    // Subscribe variables to the propagators
    if ([_x isPresent]) {
        [_x whenChangeDurationDo:^{[self propagateWhenXPresent];} onBehalf:self];
        [_y whenChangeDo:^{[self propagateWhenXPresent];} onBehalf:self];
        [_z whenChangeDo:^{[self propagateWhenXPresent];} onBehalf:self];
    }
    else if (![_x isAbsent]) {
        [_x whenChangePropagate:self];
        [_x whenPresentPropagate:self];
        [_y whenChangePropagate:self];
        [_z whenChangePropagate:self];
    }
    return ORSuspend;
}
-(void) propagate
{
    if ([_x isPresent])
        [self propagateWhenXPresent];
    else if (![_x isAbsent])
        [self propagateWhenXNotAbsent];
}
-(void) propagateWhenXNotAbsent
{
    assert(![_x isAbsent] && ![_x isPresent]);
    // Only propagation on x can be performed
    const ORInt y_min = [_y min];
    const ORInt y_max = [_y max];
    const ORInt z_min = [_z min];
    const ORInt z_max = [_z max];
    
    if (z_max <= 0) {
        if (0 < y_min && 0 < [_x minDuration])
            [_x labelPresent:FALSE];
    }
    else if (y_max <= 0) {
        if (0 < z_min)
            [_x labelPresent:FALSE];
    }
    else {
        // Updating the multiplicator x
        [_x updateMinDuration:roundUpDiv(z_min, y_max)];
        if (0 < [_y min])
            [_x updateMaxDuration:roundUpDiv(z_max, y_min)];
    }
}
-(void) propagateWhenXPresent
{
    assert([_x isPresent]);
    const ORInt x_min = [_x minDuration];
    const ORInt x_max = [_x maxDuration];
    const ORInt y_min = [_y min];
    const ORInt y_max = [_y max];
    // Updating the product
    [_z updateMin:(x_min * y_min) andMax:(x_max * y_max)];

    const ORInt z_min = [_z min];
    const ORInt z_max = [_z max];
    if (z_max <= 0) {
        if (0 < y_min)
            [_x updateMaxDuration:0];
        else
            [_y updateMax:0];
    }
    else {
        assert(0 < x_max && 0 < y_max);
        // Updating the multiplicator y
        [_y updateMin:roundUpDiv(z_min, x_max)];
        if (0 < x_min)
            [_y updateMax:roundUpDiv(z_max, x_min)];
        // Updating the multiplicator x
        [_x updateMinDuration:roundUpDiv(z_min, [_y max])];
        if (0 < [_y min])
            [_x updateMaxDuration:roundUpDiv(z_max, [_y min])];
    }
}
static inline ORInt roundUpDiv(const ORInt a, const ORInt b)
{
    assert(0 <= a && 0 < b);
    return (a < b ? 0 : (a / b + (a % b > 0)));
}
-(NSSet*) allVars
{
    ORInt size = 3;
    NSMutableSet* rv = [[NSMutableSet alloc] initWithCapacity:size];
    [rv addObject:_x];
    [rv addObject:_y];
    [rv addObject:_z];
    [rv autorelease];
    return rv;
}
-(ORUInt) nbUVars
{
    return 3;
}
@end

@implementation CPResourceTaskAddTransitionTime
{
    TRInt   _normalSize;
    TRInt   _extendedSize;
}
-(id) initCPResourceTaskAddTransitionTime:(id<CPResourceTask>) normal extended:(id<CPResourceTask>)extended time:(id<CPIntVarArray>)time
{
    self = [super initCPCoreConstraint: [normal engine]];
    
    _normal   = normal;
    _extended = extended;
    _time     = time;
    NSLog(@"Create constraint CPResourceTaskAddTransitionTime\n");
    return self;
}
-(void) dealloc
{
    [super dealloc];
}
-(ORStatus) post
{
    _normalSize   = makeTRInt(_trail, (ORInt)[_time count]);
    _extendedSize = makeTRInt(_trail, (ORInt)[_time count]);
    
    [self propagate];
    
    [_normal   whenChangeStartPropagate: self];
    [_normal   whenChangeEndPropagate  : self];
    [_extended whenChangeStartPropagate: self];
    [_extended whenChangeEndPropagate  : self];
    
    for (ORInt i = _time.low; i <= _time.up; i++) {
        [_time[i] whenChangeMinPropagate: self];
    }
    
    // Presence and absence propagation
    [_normal   whenAbsentDo :^(){[_extended labelPresent:false];} onBehalf:self];
    [_normal   whenPresentDo:^(){[_extended labelPresent:true ];} onBehalf:self];
    [_extended whenAbsentDo :^(){[_normal   labelPresent:false];} onBehalf:self];
    [_extended whenPresentDo:^(){[_normal   labelPresent:true ];} onBehalf:self];

    return ORSuspend;
}
-(void) propagate
{
    if ([_normal isAbsent])
        return ;

    ORInt normalAbsent   = 0;
    ORInt extendedAbsent = 0;
    // NOTE Do not modify the following arrays, which are internal data structures
    // of resource tasks
    const ORInt * normalIndex   = [(CPResourceTask *)_normal   getInternalIndexArray: & normalAbsent  ];
    const ORInt * extendedIndex = [(CPResourceTask *)_extended getInternalIndexArray: & extendedAbsent];
    
    for (ORInt ii = normalAbsent; ii < _normalSize._val; ii++)
        [(CPResourceTask *)_extended removeWithIndex:normalIndex[ii]];
    for (ORInt ii = extendedAbsent; ii < _extendedSize._val; ii++)
        [(CPResourceTask *)_extended removeWithIndex:extendedIndex[ii]];

    const ORInt * normalIndex0 = [(CPResourceTask *)_normal   getInternalIndexArray: & normalAbsent  ];
    [(CPResourceTask *)_extended getInternalIndexArray: & extendedAbsent];
    
    assert(normalAbsent == extendedAbsent);
    
    if (normalAbsent < _normalSize._val)
        assignTRInt(&(_normalSize), normalAbsent, _trail);
    if (extendedAbsent < _extendedSize._val)
        assignTRInt(&(_extendedSize), extendedAbsent, _trail);
    
    // Compute minimal and maximal time
    ORInt tmin = MAXINT;
    ORInt tmax = MININT;
    // Iterate over relevant resource constraint
    for (ORInt ii = 0; ii < normalAbsent; ii++) {
        const ORInt i = normalIndex0[ii];
        tmin = min(tmin, [_time[i] min]);
        tmax = max(tmax, [_time[i] max]);
    }

    // Updating the duration
    [_normal   updateMinDuration:[_extended minDuration] - tmin];
    [_normal   updateMaxDuration:[_extended maxDuration] - tmax];
    [_extended updateMinDuration:[_normal   minDuration] + tmin];
    [_extended updateMaxDuration:[_normal   maxDuration] + tmax];
    if (normalAbsent == 1 && [_normal isPresent]) {
        const ORInt i = normalIndex0[0];
        [_time[i] updateMin:[_extended minDuration] - [_normal minDuration]];
        [_time[i] updateMax:[_extended maxDuration] - [_normal maxDuration]];
    }
    
    // Updating the start and end
    [_normal   updateStart: [_extended est]];
    [_extended updateStart: [_normal   est]];
    [_normal   updateEnd  : [_extended lct] - tmin];
    [_extended updateEnd  : [_normal   lct] + tmax];
    [_normal   updateLst  : [_extended lst]];
    [_extended updateLst  : [_normal   lst]];
    [_normal   updateEct  : [_extended ect] - tmax];
    [_extended updateEct  : [_normal   ect] + tmin];
}
-(NSSet*) allVars
{
    ORInt size = 2;
    NSMutableSet* rv = [[NSMutableSet alloc] initWithCapacity:size];
    [rv addObject:_normal];
    [rv addObject:_extended];
    [rv addObject:_time];
    [rv autorelease];
    return rv;
}
-(ORUInt) nbUVars
{
    return 2;
}
@end
