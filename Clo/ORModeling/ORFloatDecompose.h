/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
//#import <CPUKernel/CPTypes.h>
//#import <CPUKernel/CPConstraintI.h>
#import "ORFloatLinear.h"

@interface ORFloatLinearizer : ORVisitor<NSObject>
-(id) init: (id<ORFloatLinear>) t model: (id<ORAddToModel>) model;
-(id) init: (id<ORFloatLinear>) t model: (id<ORAddToModel>) model equalTo:(id<ORFloatVar>)x;
@end

@interface ORFloatSubst   : ORVisitor<NSObject> {
   id<ORFloatVar>      _rv;
   id<ORAddToModel> _model;
   ORCLevel             _c;
}
-(id)initORSubst:(id<ORAddToModel>) model;
-(id)initORSubst:(id<ORAddToModel>) model by:(id<ORFloatVar>)x;
-(id<ORFloatVar>)result;
@end

