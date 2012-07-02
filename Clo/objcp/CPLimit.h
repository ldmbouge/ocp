/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

@interface CPLimitSolutions : CPDefaultController <NSCopying,CPSearchController> {
@private
   CPInt _maxSolutions;
   CPInt _nbSolutions;
}
-(id)   initCPLimitSolutions: (CPInt) maxSolutions;
-(void) dealloc;
-(CPInt) addChoice:(NSCont*)k;
-(void) fail;
-(void) succeeds;
@end

@interface CPLimitDiscrepancies : CPDefaultController <NSCopying,CPSearchController> 
{
  CPInt _maxDiscrepancies;
  CPTrail*  _trail;
  TRInt     _nbDiscrepancies;
}
-(id)        initCPLimitDiscrepancies: (CPInt) maxDiscrepancies withTrail: (CPTrail*) trail;
-(void)      dealloc;
-(CPInt) addChoice:(NSCont*) k;
-(void)      fail;
-(void)      startTryRight;
@end

@interface CPOptimizationController : CPDefaultController <NSCopying,CPSearchController> 
{
  CPVoid2CPStatus _canImprove;
}
-(id)        initCPOptimizationController: (CPVoid2CPStatus) canImprove;
-(void)      dealloc;
-(CPInt) addChoice:(NSCont*) k;
-(void)      fail;
-(void)      startTryRight;
-(void)      startTryallOnFailure;
- (id)copyWithZone:(NSZone *)zone;
@end
