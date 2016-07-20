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

@interface CPLDoubleDom : NSObject<CPDoubleDom,NSCopying> {
    id<ORTrail>        _trail;
    ORLDouble            _imin;
    ORLDouble            _imax;
    TRLDouble           _min;
    TRLDouble           _max;
}
-(id)initCPLDoubleDom:(id<ORTrail>)trail low:(ORLDouble)low up:(ORLDouble)up;
-(void) updateMin:(ORLDouble)newMin for:(id<CPLDoubleVarNotifier>)x;
-(void) updateMax:(ORLDouble)newMax for:(id<CPLDoubleVarNotifier>)x;
-(ORNarrowing) updateInterval:(ORInterval)v for:(id<CPLDoubleVarNotifier>)x;
-(void) bind:(ORLDouble)val  for:(id<CPLDoubleVarNotifier>)x;
-(ORLDouble) min;
-(ORLDouble) max;
-(ORLDouble) imin;
-(ORLDouble) imax;
-(ORBool) bound;
-(ORInterval) bounds;
-(ORLDouble) domwidth;
-(ORBool) member:(ORLDouble)v;
-(id) copy;
-(void) restoreDomain:(id<CPDoubleDom>)toRestore;
-(void) restoreValue:(ORLDouble)toRestore for:(id<CPLDoubleVarNotifier>)x;
@end
