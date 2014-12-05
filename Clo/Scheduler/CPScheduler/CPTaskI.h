/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2014 NICTA, Andreas Schutt and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <Foundation/Foundation.h>
#import <ORModeling/ORModeling.h>
#import <objcp/CPVar.h>
#import <CPScheduler/CPTask.h>

@interface CPTaskVar : ORObject<CPTaskVar>
-(id<CPTaskVar>) initCPTaskVar: (id<CPEngine>) engine horizon: (id<ORIntRange>) horizon duration: (id<ORIntRange>) duration;
-(void) changeStartEvt;
-(void) changeEndEvt;
@end

@interface CPOptionalTaskVar : ORObject<CPTaskVar>
-(id<CPTaskVar>) initCPOptionalTaskVar: (id<CPEngine>) engine horizon: (id<ORIntRange>) horizon duration: (id<ORIntRange>) duration;
@end

@interface CPAlternativeTask : CPTaskVar<CPAlternativeTask>
-(id<CPAlternativeTask>) initCPAlternativeTask: (id<CPEngine>) engine horizon: (id<ORIntRange>) horizon duration: (id<ORIntRange>) duration alternatives: (id<CPTaskVarArray>) alternatives;
@end

@interface CPOptionalAlternativeTask : CPOptionalTaskVar<CPAlternativeTask>
-(id<CPAlternativeTask>) initCPOptionalAlternativeTask: (id<CPEngine>) engine horizon: (id<ORIntRange>) horizon duration: (id<ORIntRange>) duration alternatives: (id<CPTaskVarArray>) alternatives;
@end

@interface CPSpanTask : CPTaskVar<CPSpanTask>
-(id<CPSpanTask>) initCPSpanTask: (id<CPEngine>) engine horizon: (id<ORIntRange>) horizon duration: (id<ORIntRange>) duration compound: (id<CPTaskVarArray>) compound;
@end

@interface CPOptionalSpanTask : CPOptionalTaskVar<CPSpanTask>
-(id<CPSpanTask>) initCPOptionalSpanTask: (id<CPEngine>) engine horizon: (id<ORIntRange>) horizon duration: (id<ORIntRange>) duration compound: (id<CPTaskVarArray>) compound;
@end

@interface CPResourceTask : CPTaskVar<CPResourceTask>
-(id<CPResourceTask>) initCPResourceTask: (id<CPEngine>) engine horizon: (id<ORIntRange>) horizon duration: (id<ORIntRange>) duration durationArray:(id<ORIntRangeArray>) durationArray runsOnOneOf: (id<CPResourceArray>) resources;
@end

@interface CPOptionalResourceTask : CPOptionalTaskVar<CPResourceTask>
-(id<CPResourceTask>) initCPOptionalResourceTask: (id<CPEngine>) engine horizon: (id<ORIntRange>) horizon duration: (id<ORIntRange>) duration durationArray:(id<ORIntRangeArray>) durationArray runsOnOneOf: (id<CPResourceArray>) resources;
@end
