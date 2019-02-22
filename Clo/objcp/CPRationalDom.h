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

#import "rationalUtilities.h"

@interface CPRationalDom : NSObject<CPRationalDom,NSCopying> {
    id<ORTrail>           _trail;
    id<ORRational>            _imin;
    id<ORRational>            _imax;
    TRRationalInterval       _domain;
}
// Always gives to possiblity to use base type for precision (cpjm)
-(id)initCPRationalDom:(id<ORTrail>)trail low:(id<ORRational>)low up:(id<ORRational>)up;
// Not reason to use ORFloat here. Use ORDouble instead (cpjm)
-(id)initCPRationalDom:(id<ORTrail>)trail lowF:(ORDouble)low upF:(ORDouble)up;
-(id)initCPRationalDom:(id<ORTrail>)trail;
-(void) updateMin:(id<ORRational>)newMin for:(id<CPFloatVarRatNotifier>)x;
-(void) updateMax:(id<ORRational>)newMax for:(id<CPFloatVarRatNotifier>)x;
-(void) updateInterval:(id<ORRationalInterval>)v for:(id<CPFloatVarRatNotifier>)x;
-(void) bind:(id<ORRational>)val  for:(id<CPFloatVarRatNotifier>)x;
-(id<ORRational>) min;
-(id<ORRational>) max;
-(id<ORRational>) imin;
-(id<ORRational>) imax;
-(ORBool) bound;
-(ORInterval) bounds;
//-(ORLDouble) domwidth;
-(TRRationalInterval) domain;
-(ORBool) member:(id<ORRational>)v;
-(id) copy;
-(void) restoreDomain:(id<CPRationalDom>)toRestore;
-(void) restoreValue:(id<ORRational>)toRestore for:(id<CPFloatVarRatNotifier>)x;
@end

