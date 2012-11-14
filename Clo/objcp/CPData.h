/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>

@protocol CP;
@protocol CPExprVisitor;

typedef ORStatus(*UBType)(id,SEL,...);
typedef void (^ConstraintCallback)(void);
typedef void (^ConstraintIntCallBack)(ORInt);

@protocol CPConstraint <ORConstraint,ORCommand>
-(ORUInt)getId;
@end

@protocol CPZeroOneStream <ORZeroOneStream>
@end

@protocol CPUniformDistribution <ORUniformDistribution>
@end
