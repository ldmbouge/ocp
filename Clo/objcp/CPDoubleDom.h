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

@interface CPDoubleDom : NSObject<CPDoubleDom,NSCopying> {
    id<ORTrail>        _trail;
    ORDouble            _imin;
    ORDouble            _imax;
    TRDouble           _min;
    TRDouble           _max;
}
-(id)initCPDoubleDom:(id<ORTrail>)trail low:(ORDouble)low up:(ORDouble)up;
-(void) updateMin:(ORDouble)newMin for:(id<CPDoubleVarNotifier>)x;
-(void) updateMax:(ORDouble)newMax for:(id<CPDoubleVarNotifier>)x;
-(ORNarrowing) updateInterval:(ORInterval)v for:(id<CPDoubleVarNotifier>)x;
-(void) bind:(ORDouble)val  for:(id<CPDoubleVarNotifier>)x;
-(ORDouble) min;
-(ORDouble) max;
-(ORDouble) imin;
-(ORDouble) imax;
-(ORBool) bound;
-(ORInterval) bounds;
-(ORLDouble) domwidth;
-(ORBool) member:(ORDouble)v;
-(id) copy;
-(void) restoreDomain:(id<CPDoubleDom>)toRestore;
-(void) restoreValue:(ORDouble)toRestore for:(id<CPDoubleVarNotifier>)x;
@end
