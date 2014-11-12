/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2014 NICTA, Andreas Schutt and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORScheduler/ORTask.h>

@interface ORTaskVar : ORObject<ORTaskVar>
-(id<ORTaskVar>) initORTaskVar: (id<ORModel>) model horizon: (id<ORIntRange>) horizon duration: (id<ORIntRange>) duration;
-(id<ORTaskVar>) initOROptionalTaskVar: (id<ORModel>) model horizon: (id<ORIntRange>) horizon duration: (id<ORIntRange>) duration;
@end

@interface ORAlternativeTask : ORTaskVar<ORAlternativeTask>
-(id<ORAlternativeTask>) initORAlternativeTask: (id<ORModel>) model alternatives: (id<ORTaskVarArray>) alternatives;
-(id<ORAlternativeTask>) initOROptionalAlternativeTask: (id<ORModel>) model alternatives: (id<ORTaskVarArray>) alternatives;
@end

@interface ORMachineTask : ORTaskVar<ORMachineTask>
-(id<ORMachineTask>) initORMachineTask: (id<ORModel>) model horizon: (id<ORIntRange>) horizon durationArray: (id<ORIntArray>) duration runsOnOneOf: (id<ORTaskDisjunctiveArray>) disjunctives;
-(id<ORMachineTask>) initORMachineTaskEmpty: (id<ORModel>) model horizon: (id<ORIntRange>) horizon;
@end

@interface ORResourceTask : ORTaskVar<ORResourceTask>
-(id<ORResourceTask>) initORResourceTask:(id<ORModel>)model horizon:(id<ORIntRange>)horizon durationArray:(id<ORIntArray>)duration runsOnOneOf:(id<ORResourceArray>)resources;
-(id<ORResourceTask>) initORResourceTaskEmpty: (id<ORModel>) model horizon: (id<ORIntRange>) horizon;
@end
