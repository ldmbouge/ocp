/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2014 NICTA, Andreas Schutt and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <ORUtilities/ORUtilities.h>
#import <ORModeling/ORModeling.h>
#import "ORTaskI.h"
#import <ORScheduler/ORSchedFactory.h>
#import <ORScheduler/ORVisit.h>
#import <ORProgram/CPSolver.h>


@implementation ORTaskVar {
   id<ORModel> _model;
   id<ORIntRange>  _horizon;
   id<ORIntRange>  _duration;
   ORBool _isOptional;
}
-(id<ORTaskVar>) initORTaskVar: (id<ORModel>) model horizon: (id<ORIntRange>) horizon duration: (id<ORIntRange>) duration
{
   self = [super init];
   _model = model;
   _duration = duration;
   _horizon = horizon;
   _isOptional = FALSE;
   return self;
}
-(id<ORTaskVar>) initOROptionalTaskVar: (id<ORModel>) model horizon: (id<ORIntRange>) horizon duration: (id<ORIntRange>) duration
{
   self = [super init];
   _model = model;
   _duration = duration;
   _horizon = horizon;
   _isOptional = TRUE;
   return self;
}
-(id<ORTracker>) tracker
{
   return _model;
}
-(id<ORIntRange>)   horizon
{
   return _horizon;
}
-(id<ORIntRange>)   duration
{
   return _duration;
}
-(ORBool) isOptional
{
   return _isOptional;
}
-(void)visit:(ORVisitor*) v
{
   [v visitTask: self];
}
-(id<ORTaskPrecedes>) precedes: (id<ORTaskVar>) after
{
   return [ORFactory constraint: self precedes: after];
}
-(id<ORTaskIsFinishedBy>) isFinishedBy: (id<ORIntVar>) date
{
   return [ORFactory constraint: self isFinishedBy: date];
}
-(ORInt) est: (id) store
{
   return [((id<ORTaskVarQuery>) [store concretize: self]) est];
}
-(ORInt) ect: (id) store
{
   return [((id<ORTaskVarQuery>) [store concretize: self]) ect];
}
-(ORInt) lst: (id) store;
{
   return [((id<ORTaskVarQuery>) [store concretize: self]) lst];
}
-(ORInt) lct: (id) store
{
   return [((id<ORTaskVarQuery>) [store concretize: self]) lct];
}
-(ORInt) minDuration: (id) store
{
   return [((id<ORTaskVarQuery>) [store concretize: self]) minDuration];
}
-(ORInt) maxDuration: (id) store
{
   return [((id<ORTaskVarQuery>) [store concretize: self]) maxDuration];
}
-(ORBool) isPresent: (id) store
{
   return [((id<ORTaskVarQuery>) [store concretize: self]) isPresent];
}
-(ORBool) isAbsent: (id) store
{
   return [((id<ORTaskVarQuery>) [store concretize: self]) isAbsent];
}
@end
