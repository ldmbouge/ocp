/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <CPUKernel/CPTypes.h>
#import <objcp/CPDom.h>

@interface CPFloatDom : NSObject<CPFDom,NSCoding,NSCopying> {
   id<ORTrail>        _trail;
   ORFloat            _imin;
   ORFloat            _imax;
   TRDouble           _min;
   TRDouble           _max;
}
-(id)initCPFloatDom:(id<ORTrail>)trail low:(ORFloat)low up:(ORFloat)up;
-(void) updateMin:(ORFloat)newMin for:(id<CPFloatVarNotifier>)x;
-(void) updateMax:(ORFloat)newMax for:(id<CPFloatVarNotifier>)x;
-(ORNarrowing) updateInterval:(ORInterval)v for:(id<CPFloatVarNotifier>)x;
-(void) bind:(ORFloat)val  for:(id<CPFloatVarNotifier>)x;
-(ORFloat) min;
-(ORFloat) max;
-(ORFloat) imin;
-(ORFloat) imax;
-(ORBool) bound;
-(ORInterval) bounds;
-(ORFloat) domwidth;
-(ORBool) member:(ORFloat)v;
-(id) copy;
-(void) restoreDomain:(id<CPFDom>)toRestore;
-(void) restoreValue:(ORFloat)toRestore for:(id<CPFloatVarNotifier>)x;
@end
