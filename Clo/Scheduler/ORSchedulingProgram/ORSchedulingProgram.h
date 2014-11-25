/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2014 NICTA, Andreas Schutt and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORScheduler/ORActivity.h>
#import <ORScheduler/ORSchedConstraint.h>
#import <ORScheduler/ORSchedFactory.h>
#import <ORProgram/ORProgram.h>
#import <ORScheduler/ORTask.h>

@protocol CPScheduler
-(void) labelActivity: (id<ORTaskVar>) act;
-(void) labelActivities: (id<ORTaskVarArray>) act;
-(void) setAlternatives: (id<ORAlternativeTaskArray>) act;
-(void) assignResources: (id<ORTaskVarArray>) act;
-(void) setTimes: (id<ORTaskVarArray>) act;
-(void) sequence: (id<ORIntVarArray>) succ by: (ORInt2Float) o;
-(void) sequence: (id<ORIntVarArray>) succ by: (ORInt2Float) o1 then: (ORInt2Float) o2;
//-(void) labelTimes: (id<ORActivityArray>) act;

-(ORInt) est: (id<ORTaskVar>) task;
-(ORInt) ect: (id<ORTaskVar>) task;
-(ORInt) lst: (id<ORTaskVar>) task;
-(ORInt) lct: (id<ORTaskVar>) task;
-(ORInt) isPresent: (id<ORTaskVar>) task;
-(ORInt) isAbsent: (id<ORTaskVar>) task;
-(id<ORTaskDisjunctive>) runsOn: (id<ORMachineTask>) task;
-(id<ORConstraint>) runsOnResource: (id<ORResourceTask>) task;
-(ORBool) boundActivity: (id<ORTaskVar>) task;
-(ORInt) minDuration: (id<ORTaskVar>) task;
-(ORInt) maxDuration: (id<ORTaskVar>) task;
-(void) updateStart: (id<ORTaskVar>) task with: (ORInt) newStart;
-(void) updateEnd: (id<ORTaskVar>) task with: (ORInt) newEnd;
-(void) updateMinDuration: (id<ORTaskVar>) task with: (ORInt) newMinDuration;
-(void) updateMaxDuration: (id<ORTaskVar>) task with: (ORInt) newMaxDuration;

-(void) labelStart: (id<ORTaskVar>) task;
-(void) labelStart: (id<ORTaskVar>) task with: (ORInt) start;
-(void) labelEnd: (id<ORTaskVar>) task;
-(void) labelEnd: (id<ORTaskVar>) task with: (ORInt) end;
-(void) labelDuration: (id<ORTaskVar>) task;
-(void) labelDuration: (id<ORTaskVar>) task with: (ORInt) duration;
-(void) labelPresent: (id<ORTaskVar>) task;
-(void) labelPresent: (id<ORTaskVar>) task with: (ORBool) present;
-(ORInt) globalSlack: (id<ORTaskDisjunctive>) d;
-(ORInt) localSlack: (id<ORTaskDisjunctive>) d;

-(NSString*) description: (id<ORObject>) o;
@end

@protocol CPSchedulerSolution
-(ORInt) est: (id<ORTaskVar>) task;
-(ORInt) ect: (id<ORTaskVar>) task;
-(ORInt) lst: (id<ORTaskVar>) task;
-(ORInt) lct: (id<ORTaskVar>) task;
-(ORInt) isPresent: (id<ORTaskVar>) task;
-(ORInt) isAbsent: (id<ORTaskVar>) task;
-(ORBool) boundActivity: (id<ORTaskVar>) task;
-(ORInt) minDuration: (id<ORTaskVar>) task;
-(ORInt) maxDuration: (id<ORTaskVar>) task;
@end






