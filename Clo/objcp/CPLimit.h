/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <ORUtilities/ORUtilities.h>
#import <ORFoundation/ORFoundation.h>
#import <ORFoundation/ORTrail.h>
#import <objcp/CPController.h>


@interface CPLimitSolutions : ORDefaultController <NSCopying,ORSearchController> {
@private
   ORInt _maxSolutions;
   ORInt _nbSolutions;
}
-(id)   initCPLimitSolutions: (ORInt) maxSolutions;
-(void) dealloc;
-(ORInt) addChoice:(NSCont*)k;
-(void) fail;
-(void) succeeds;
@end

@interface CPLimitDiscrepancies : ORDefaultController <NSCopying,ORSearchController> 
{
  ORInt     _maxDiscrepancies;
  ORTrail*  _trail;
  TRInt     _nbDiscrepancies;
}
-(id)        initCPLimitDiscrepancies: (ORInt) maxDiscrepancies withTrail: (ORTrail*) trail;
-(void)      dealloc;
-(ORInt)     addChoice:(NSCont*) k;
-(void)      fail;
-(void)      startTryRight;
@end

@interface CPLimitFailures : ORDefaultController <NSCopying,ORSearchController>
{
   ORInt     _maxFailures;
   ORInt     _nbFailures;
}
-(id)        initCPLimitFailures: (ORInt) maxFailures;
-(void)      dealloc;
-(ORInt)     addChoice:(NSCont*) k;
-(void)      fail;
-(void)      startTryLeft;
-(void)      startTryRight;
@end

@interface CPLimitTime : ORDefaultController <NSCopying,ORSearchController>
{
   ORLong    _maxTime;
   ORLong    _startTime;
}
-(id)        initCPLimitTime: (ORLong) maxTime;
-(void)      dealloc;
-(ORInt)     addChoice:(NSCont*) k;
-(void)      fail;
-(void)      startTryLeft;
-(void)      startTryRight;
@end

@interface CPLimitCondition : ORDefaultController <NSCopying,ORSearchController>
{
   ORVoid2Bool _condition;
}
-(id)        initCPLimitCondition: (ORVoid2Bool) condition;
-(void)      dealloc;
-(ORInt)     addChoice:(NSCont*) k;
-(void)      fail;
-(void)      startTryLeft;
-(void)      startTryRight;
@end

@interface CPOptimizationController : ORDefaultController <NSCopying,ORSearchController> 
{
  Void2ORStatus _canImprove;
}
-(id)        initCPOptimizationController: (Void2ORStatus) canImprove;
-(void)      dealloc;
-(ORInt)     addChoice:(NSCont*) k;
-(void)      fail;
-(void)      startTryRight;
-(void)      startTryallOnFailure;
- (id)copyWithZone:(NSZone *)zone;
@end

