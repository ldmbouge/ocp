/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2014 NICTA, Andreas Schutt and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/


#import <ORFoundation/ORFoundation.h>
#import <ORModeling/ORModeling.h>

@protocol CPTaskVarSubscriber <NSObject>

// AC3 Closure Event
-(void) whenChangeDo: (ORClosure) todo priority: (ORInt) p onBehalf: (id<CPConstraint>) c;
-(void) whenChangeStartDo: (ORClosure) todo priority: (ORInt) p onBehalf: (id<CPConstraint>) c;
-(void) whenChangeEndDo: (ORClosure) todo priority: (ORInt) p onBehalf: (id<CPConstraint>) c;

-(void) whenChangeDo: (ORClosure) todo onBehalf: (id<CPConstraint>) c;
-(void) whenChangeStartDo: (ORClosure) todo onBehalf: (id<CPConstraint>) c;
-(void) whenChangeEndDo: (ORClosure) todo onBehalf: (id<CPConstraint>) c;

// AC3 Constraint Event
-(void) whenChangePropagate:  (id<CPConstraint>) c priority: (ORInt) p;
-(void) whenChangeStartPropagate: (id<CPConstraint>) c priority: (ORInt) p;
-(void) whenChangeEndPropagate: (id<CPConstraint>) c priority: (ORInt) p;

-(void) whenChangePropagate: (id<CPConstraint>) c;
-(void) whenChangeStartPropagate: (id<CPConstraint>) c;
-(void) whenChangeEndPropagate: (id<CPConstraint>) c;
@end

@protocol CPTaskVar <ORObject,CPTaskVarSubscriber>
-(ORInt) getId;
-(ORInt) est;
-(ORInt) ect;
-(ORInt) lst;
-(ORInt) lct;
-(ORBool) bound;
-(ORInt) minDuration;
-(ORInt) maxDuration;
-(void) updateStart: (ORInt) newStart;
-(void) updateEnd: (ORInt) newEnd;
-(void) updateMinDuration: (ORInt) newMinDuration;
-(void) updateMaxDuration: (ORInt) newMaxDuration;
@end


