/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>


@interface ORLimitSolutions : ORDefaultController <NSCopying,ORSearchController> {
@private
   ORInt _maxSolutions;
   ORInt _nbSolutions;
}
-(id)   initORLimitSolutions: (ORInt) maxSolutions;
-(void) dealloc;
-(ORInt) addChoice:(NSCont*)k;
-(void) succeeds;
@end

@interface ORLimitDiscrepancies : ORDefaultController <NSCopying,ORSearchController>
{
   ORInt        _maxDiscrepancies;
   id<ORTrail>  _trail;
   TRInt        _nbDiscrepancies;
}
-(id)        initORLimitDiscrepancies: (ORInt) maxDiscrepancies withTrail: (id<ORTrail>) trail;
-(void)      dealloc;
-(ORInt)     addChoice:(NSCont*) k;
-(void)      startTryRight;
@end

@interface ORLimitFailures : ORDefaultController <NSCopying,ORSearchController>
{
   ORInt     _maxFailures;
   ORInt     _nbFailures;
}
-(id)        initORLimitFailures: (ORInt) maxFailures;
-(void)      dealloc;
-(ORInt)     addChoice:(NSCont*) k;
-(void)      startTryLeft;
-(void)      startTryRight;
@end

@interface ORLimitTime : ORDefaultController <NSCopying,ORSearchController>
{
   ORLong    _maxTime;
   ORLong    _startTime;
}
-(id)        initORLimitTime: (ORLong) maxTime;
-(void)      dealloc;
-(ORInt)     addChoice:(NSCont*) k;
-(void)      startTryLeft;
-(void)      startTryRight;
@end

@interface ORLimitCondition : ORDefaultController <NSCopying,ORSearchController>
{
   ORVoid2Bool _condition;
}
-(id)        initORLimitCondition: (ORVoid2Bool) condition;
-(void)      dealloc;
-(ORInt)     addChoice:(NSCont*) k;
-(void)      startTryLeft;
-(void)      startTryRight;
@end

@interface OROptimizationController : ORDefaultController <NSCopying,ORSearchController>
{
   Void2ORStatus _canImprove;
}
-(id)        initOROptimizationController: (Void2ORStatus) canImprove;
-(void)      dealloc;
-(ORInt)     addChoice:(NSCont*) k;
-(void)      startTryRight;
-(void)      startTryallOnFailure;
- (id)copyWithZone:(NSZone *)zone;
@end

@interface ORLimitMonitor : ORDefaultController <NSCopying,ORSearchController>
-(id)        initORLimitMonitor;
-(void)      dealloc;
-(void)      fail: (ORBool) pruned;
-(ORBool)    isPruned;
@end

@interface ORSwitchOnDepth : ORDefaultController <NSCopying,ORSearchController>
-(id)    initORSwitchOnDepth: (ORInt) limit next: (NSCont*) next withTrail: (id<ORTrail>) trail;
-(void)  dealloc;
-(void)  startTry;
@end

@interface ORTrackDepth : ORDefaultController <NSCopying,ORSearchController>
-(id)    initORTrackDepth: (id<ORTrail>) trail;
-(void)  dealloc;
-(void)  startTry;
-(void)  startTryall;
-(ORInt) maxDepth;
@end
