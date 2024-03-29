/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Andreas Schutt and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORScheduler/ORTask.h>

@interface ORTaskVar : ORObject<ORTaskVar>
-(id<ORTaskVar>) initORTaskVar: (id<ORModel>) model horizon: (id<ORIntRange>) horizon duration: (id<ORIntRange>) duration;
-(id<ORTaskVar>) initOROptionalTaskVar: (id<ORModel>) model horizon: (id<ORIntRange>) horizon duration: (id<ORIntRange>) duration;
-(id<ORIntVar>) startVar;
-(id<ORIntVar>) durationVar;
-(id<ORIntVar>) endVar;
-(id<ORIntVar>) presenceVar;
@end

@interface ORAlternativeTask : ORTaskVar<ORAlternativeTask>
-(id<ORAlternativeTask>) initORAlternativeTask: (id<ORModel>) model alternatives: (id<ORTaskVarArray>) alternatives;
-(id<ORAlternativeTask>) initOROptionalAlternativeTask: (id<ORModel>) model alternatives: (id<ORTaskVarArray>) alternatives;
@end

@interface ORSpanTask : ORTaskVar<ORSpanTask>
-(id<ORSpanTask>) initORSpanTask:(id<ORModel>)model horizon:(id<ORIntRange>)horizon compound:(id<ORTaskVarArray>)compound;
-(id<ORSpanTask>) initOROptionalSpanTask:(id<ORModel>)model horizon:(id<ORIntRange>)horizon compound:(id<ORTaskVarArray>)compound;
@end

@interface ORResourceTask : ORTaskVar<ORResourceTask>
-(id<ORResourceTask>) initORResourceTask:(id<ORModel>)model horizon:(id<ORIntRange>)horizon durationArray:(id<ORIntRangeArray>)duration runsOnOneOf:(id<ORResourceArray>)resources;
-(id<ORResourceTask>) initORResourceTask:(id<ORModel>)model horizon:(id<ORIntRange>)horizon durationArray:(id<ORIntRangeArray>)duration usageArray:(id<ORIntVarArray>)usage runsOnOneOf:(id<ORResourceArray>)resources;
-(id<ORResourceTask>) initORResourceTaskEmpty: (id<ORModel>) model horizon: (id<ORIntRange>) horizon duration: (id<ORIntRange>) duration;
-(id<ORResourceTask>) initOROptionalResourceTask:(id<ORModel>)model horizon:(id<ORIntRange>)horizon durationArray:(id<ORIntRangeArray>)duration runsOnOneOf:(id<ORResourceArray>)resources;
-(id<ORResourceTask>) initOROptionalResourceTask:(id<ORModel>)model horizon:(id<ORIntRange>)horizon durationArray:(id<ORIntRangeArray>)duration usageArray:(id<ORIntVarArray>)usage runsOnOneOf:(id<ORResourceArray>)resources;
-(id<ORResourceTask>) initOROptionalResourceTaskEmpty: (id<ORModel>) model horizon: (id<ORIntRange>) horizon duration: (id<ORIntRange>) duration;
-(id<ORResourceTask>) getTransitionTask;
-(id<ORResourceTask>) getTransitionSource;
-(id<ORIntVarArray>)  getTransitionTime;
-(void) addTransition: (id<ORConstraint>) resource with: (id<ORIntVar>) duration;
-(void) setTransitionSource: (id<ORResourceTask>)source;
-(void) finaliseTransitionTask;
-(void) updateTransitionTask:(id<ORIntRange>)horizon duration:(id<ORIntRange>)duration;
@end

