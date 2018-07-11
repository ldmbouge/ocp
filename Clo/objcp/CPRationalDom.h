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
    ORRational*            _imin;
    ORRational*            _imax;
    TRRationalInterval       _domain;
}
// Always gives to possiblity to use base type for precision (cpjm)
-(id)initCPRationalDom:(id<ORTrail>)trail low:(ORRational*)low up:(ORRational*)up;
// Not reason to use ORFloat here. Use ORDouble instead (cpjm)
-(id)initCPRationalDom:(id<ORTrail>)trail lowF:(ORDouble)low upF:(ORDouble)up;
-(id)initCPRationalDom:(id<ORTrail>)trail;
-(void) updateMin:(ORRational*)newMin for:(id<CPFloatVarRatNotifier>)x;
-(void) updateMax:(ORRational*)newMax for:(id<CPFloatVarRatNotifier>)x;
-(void) updateInterval:(ORRationalInterval*)v for:(id<CPFloatVarRatNotifier>)x;
-(void) bind:(ORRational*)val  for:(id<CPFloatVarRatNotifier>)x;
-(ORRational*) min;
-(ORRational*) max;
-(ORRational*) imin;
-(ORRational*) imax;
-(ORBool) bound;
-(ORInterval) bounds;
//-(ORLDouble) domwidth;
-(TRRationalInterval) domain;
-(ORBool) member:(ORRational*)v;
-(id) copy;
-(void) restoreDomain:(id<CPRationalDom>)toRestore;
-(void) restoreValue:(ORRational*)toRestore for:(id<CPFloatVarRatNotifier>)x;
@end

