/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import "ORRealLinear.h"

@interface ORRealLinearizer : ORVisitor<NSObject>
-(id) init: (id<ORRealLinear>) t model: (id<ORAddToModel>) model;
-(id) init: (id<ORRealLinear>) t model: (id<ORAddToModel>) model equalTo:(id<ORRealVar>)x;
@end

@interface ORRealSubst   : ORVisitor<NSObject> {
   id<ORRealVar>      _rv;
   id<ORAddToModel> _model;
   ORCLevel             _c;
}
-(id)initORSubst:(id<ORAddToModel>) model;
-(id)initORSubst:(id<ORAddToModel>) model by:(id<ORRealVar>)x;
-(id<ORRealVar>)result;
@end

