/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2014 NICTA, Andreas Schutt and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORScheduler/ORActivity.h>
#import <ORModeling/ORModeling.h>
#import <ORFoundation/ORFoundation.h>
#import <ORUtilities/ORUtilities.h>
#import <ORScheduler/ORVisit.h>
#import <ORScheduler/ORSchedFactory.h>

/*******************************************************************************
 Below is the definition of an optional activity object using a tripartite
 representation for "optional" variables
 ******************************************************************************/

//@implementation ORActivity
//{
//    id<ORIntVar>   _startLB;
//    id<ORIntVar>   _startUB;
//    id<ORIntVar>   _duration;
//    id<ORIntVar>   _top;
//    id<ORIntVar>   _altIdx;
//    BOOL           _optional;
//    id<ORIntRange> _startRange;
//    id<ORActivityArray> _composition;
//    ORInt          _type;
//}
//-(id<ORActivity>) initORActivity: (id<ORModel>) model horizon: (id<ORIntRange>) horizon duration: (id<ORIntRange>) duration
//{
//    self = [super init];
//    
//    _startRange  = horizon;
//    _startLB     = [ORFactory intVar: model domain: horizon ];
//    _startUB     = _startLB;
//    _duration    = [ORFactory intVar: model domain: duration];
//    _top         = NULL;
//    _optional    = FALSE;
//    _altIdx      = NULL;
//    _composition = NULL;
//    _type        = ORACTCOMP;
//    
//    return self;
//}
//-(id<ORActivity>) initOROptionalActivity: (id<ORModel>) model horizon: (id<ORIntRange>) horizon duration: (id<ORIntRange>) duration
//{
//    self = [super init];
//    
//    // Initialisation of all variables
//    _startRange  = horizon;
//    _startLB     = [ORFactory intVar : model domain: RANGE(model, horizon.low    , horizon.up + 1) ];
//    _startUB     = [ORFactory intVar : model domain: RANGE(model, horizon.low - 1, horizon.up    ) ];
//    _duration    = [ORFactory intVar : model domain: duration];
//    _top         = [ORFactory boolVar: model                 ];
//    _optional    = TRUE;
//    _altIdx      = NULL;
//    _composition = NULL;
//    _type        = ORACTOPT;
//    
//    return self;
//}
//-(id<ORActivity>) initORActivity:(id<ORModel>)model alternatives:(id<ORActivityArray>)act
//{
//    self = [super init];
//
//    // Determine the start and duration ranges
//    ORInt start_min = MAXINT;
//    ORInt start_max = MININT;
//    ORInt dur_min   = MAXINT;
//    ORInt dur_max   = MININT;
//    for (ORInt i = act.range.low; i <= act.range.up; i++) {
//        start_min = min(start_min, [act[i].startRange low]);
//        start_max = max(start_max, [act[i].startRange up ]);
//        dur_min   = min(dur_min,   [act[i].duration   low]);
//        dur_max   = max(dur_max,   [act[i].duration   up ]);
//    }
//    
//    // Setting and creating variables
//    _startRange  = RANGE(model, start_min, start_max);
//    _startLB     = [ORFactory intVar: model domain: _startRange];
//    _startUB     = _startLB;
//    _duration    = [ORFactory intVar: model domain: RANGE(model, dur_min, dur_max)];
//    _top         = NULL;
//    _optional    = FALSE;
//    _altIdx      = [ORFactory intVar:model domain:act.range];
//    _composition = act;
//    _type        = ORALTCOMP;
//
//    return self;
//}
//-(id<ORActivity>) initOROptionalActivity:(id<ORModel>)model alternatives:(id<ORActivityArray>)act
//{
//    assert(false);
//    
//    self = [super init];
//    
//    // Determine the start and duration ranges
//    ORInt start_min = MAXINT;
//    ORInt start_max = MININT;
//    ORInt dur_min   = MAXINT;
//    ORInt dur_max   = MININT;
//    for (ORInt i = act.range.low; i <= act.range.up; i++) {
//        start_min = min(start_min, [act[i].startRange low]);
//        start_max = max(start_max, [act[i].startRange up ]);
//        dur_min   = min(dur_min,   [act[i].duration   low]);
//        dur_max   = max(dur_max,   [act[i].duration   up ]);
//    }
//    
//    // Setting and creating variables
//    _startRange  = RANGE(model, start_min, start_max);
//    id<ORIntRange> idxR = RANGE(model, act.range.low - 1, act.range.up);
//    _startLB     = [ORFactory intVar : model domain: RANGE(model, start_min    , start_max + 1)];
//    _startUB     = [ORFactory intVar : model domain: RANGE(model, start_min - 1, start_max    )];
//    _duration    = [ORFactory intVar : model domain: RANGE(model, dur_min, dur_max)];
//    _top         = [ORFactory boolVar: model];
//    _optional    = TRUE;
//    _altIdx      = [ORFactory intVar : model domain: idxR];
//    _composition = act;
//    _type        = ORALTOPT;
//    
//    return self;
//}
//-(id<ORActivity>) initORActivity:(id<ORModel>)model span:(id<ORActivityArray>)act
//{
//    assert(false);
//    
//    self = [super init];
//    
//    // Determine the start and duration ranges
//    ORInt start_min = MAXINT;
//    ORInt start_max = MININT;
//    ORInt dur_max   = MININT;
//    for (ORInt i = act.range.low; i <= act.range.up; i++) {
//        start_min = min(start_min, [act[i].startRange low]);
//        start_max = max(start_max, [act[i].startRange up ]);
//        dur_max   = max(dur_max,   [act[i].startRange up ] + [act[i].duration up]);
//    }
//    
//    // Setting and creating variables
//    _startRange  = RANGE(model, start_min, start_max);
//    _startLB     = [ORFactory intVar: model domain: _startRange];
//    _startUB     = _startLB;
//    _duration    = [ORFactory intVar: model domain: RANGE(model, start_min, dur_max)];
//    _top         = NULL;
//    _optional    = FALSE;
//    _altIdx      = NULL;
//    _composition = act;
//    _type        = ORSPANCOMP;
//    
//    // TODO Constraints for representing the span
//    // XXX Should the constraints be adding here or to the "concrete" model?
//    
//    return self;
//}
//-(id<ORActivity>) initOROptionalActivity:(id<ORModel>)model span:(id<ORActivityArray>)act
//{
//    assert(false);
//    
//    self = [super init];
//    
//    // Determine the start and duration ranges
//    ORInt start_min = MAXINT;
//    ORInt start_max = MININT;
//    ORInt dur_max   = MININT;
//    for (ORInt i = act.range.low; i <= act.range.up; i++) {
//        start_min = min(start_min, [act[i].startRange low]);
//        start_max = max(start_max, [act[i].startRange up ]);
//        dur_max   = max(dur_max,   [act[i].startRange up ] + [act[i].duration up]);
//    }
//    
//    // Setting and creating variables
//    _startRange  = RANGE(model, start_min, start_max);
//    _startLB     = [ORFactory intVar : model domain: RANGE(model, start_min    , start_max + 1)];
//    _startUB     = [ORFactory intVar : model domain: RANGE(model, start_min - 1, start_max    )];
//    _duration    = [ORFactory intVar : model domain: RANGE(model, start_min, dur_max)];
//    _top         = [ORFactory boolVar: model];
//    _optional    = TRUE;
//    _altIdx      = NULL;
//    _composition = act;
//    _type        = ORSPANOPT;
//    
//    // TODO Constraints for representing the span
//    // XXX Should the constraints be adding here or to the "concrete" model?
//    
//    return self;
//}
//-(id<ORIntVar>) startLB
//{
//    return _startLB;
//}
//-(id<ORIntVar>) startUB
//{
//    return _startUB;
//}
//-(id<ORIntVar>) duration
//{
//    return _duration;
//}
//-(id<ORIntVar>) top
//{
//    return _top;
//}
//-(id<ORIntVar>) alterIdx
//{
//    return _altIdx;
//}
//-(BOOL) isOptional
//{
//    return _optional;
//}
//-(id<ORIntRange>) startRange
//{
//    return _startRange;
//}
//-(id<ORActivityArray>) composition
//{
//    return _composition;
//}
//-(ORInt) type
//{
//    return _type;
//}
//-(void)visit:(ORVisitor*) v
//{
//    [v visitActivity: self];
//}
//-(id<ORPrecedes>) precedes: (id<ORActivity>) after
//{
//    return [ORFactory precedence: self precedes: after];
//}
//@end
//
