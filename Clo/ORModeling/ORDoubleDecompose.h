/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import "ORDoubleLinear.h"

@interface ORDoubleLinearizer : ORVisitor<NSObject>
-(id) init: (id<ORDoubleLinear>) t model: (id<ORAddToModel>) model;
-(id) init: (id<ORDoubleLinear>) t model: (id<ORAddToModel>) model equalTo:(id<ORDoubleVar>)x;
@end

@interface ORDoubleSubst   : ORVisitor<NSObject> {
    id<ORDoubleVar>      _rv;
    id<ORAddToModel> _model;
    ORCLevel             _c;
}
-(id)initORDoubleSubst:(id<ORAddToModel>) model;
-(id)initORDoubleSubst:(id<ORAddToModel>) model by:(id<ORDoubleVar>)x;
-(id<ORDoubleVar>)result;
@end

