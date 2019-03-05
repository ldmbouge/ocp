/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <CPUKernel/CPTypes.h>
#import <objcp/CPDom.h>
#import <objcp/CPFloatVarI.h>


@interface CPFloatDom : NSObject<CPFloatDom,NSCopying> {
    id<ORTrail>        _trail;
    ORFloat            _imin;
    ORFloat            _imax;
    TRFloatInterval    _domain;
}
-(id)initCPFloatDom:(id<ORTrail>)trail low:(ORFloat)low up:(ORFloat)up;
-(void) updateMin:(ORFloat)newMin for:(id<CPFloatVarNotifier>)x propagate:(ORBool) p;
-(void) updateMax:(ORFloat)newMax for:(id<CPFloatVarNotifier>)x propagate:(ORBool) p;
-(void) updateMin:(ORFloat)newMin for:(id<CPFloatVarNotifier>)x;
-(void) updateMax:(ORFloat)newMax for:(id<CPFloatVarNotifier>)x;
-(void) updateInterval:(float_interval)v for:(id<CPFloatVarNotifier>)x;
-(void) bind:(ORFloat)val  for:(id<CPFloatVarNotifier>)x;
-(ORFloat) min;
-(ORFloat) max;
-(ORFloat) imin;
-(ORFloat) imax;
-(ORBool) bound;
-(ORInterval) bounds;
-(ORDouble) domwidth;
-(TRFloatInterval) domain;
-(ORBool) member:(ORFloat)v;
-(id) copy;
-(void) restoreDomain:(id<CPFloatDom>)toRestore;
-(void) restoreValue:(ORFloat)toRestore for:(id<CPFloatVarNotifier>)x;
@end
