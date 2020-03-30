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
-(id)initCPRationalDom:(id<ORTrail>)trail low:(id<ORRational>)low up:(id<ORRational>)up;
-(id)initCPRationalDom:(id<ORTrail>)trail lowF:(ORDouble)low upF:(ORDouble)up;
-(id)initCPRationalDom:(id<ORTrail>)trail;
-(void) updateMin:(id<ORRational>)newMin for:(id<CPErrorVarNotifier>)x;
-(void) updateMax:(id<ORRational>)newMax for:(id<CPErrorVarNotifier>)x;
-(void) updateInterval:(id<ORRationalInterval>)v for:(id<CPErrorVarNotifier>)x;
-(void) bind:(id<ORRational>)val  for:(id<CPErrorVarNotifier>)x;
-(void) updateMin:(id<ORRational>)newMin forQ:(id<CPRationalVarNotifier>)x;
-(void) updateMax:(id<ORRational>)newMax forQ:(id<CPRationalVarNotifier>)x;
-(void) updateInterval:(id<ORRationalInterval>)v forQ:(id<CPRationalVarNotifier>)x;
-(void) bind:(id<ORRational>)val  forQ:(id<CPRationalVarNotifier>)x;
-(id<ORRational>) min;
-(id<ORRational>) max;
-(id<ORRational>) imin;
-(id<ORRational>) imax;
-(ORBool) bound;
-(ORInterval) bounds;
-(TRRationalInterval) domain;
-(ORBool) member:(id<ORRational>)v;
-(id) copy;
-(void) restoreDomain:(id<CPRationalDom>)toRestore;
-(void) restoreValue:(id<ORRational>)toRestore for:(id<CPErrorVarNotifier>)x;
-(void) restoreValue:(id<ORRational>)toRestore forQ:(id<CPRationalVarNotifier>)x;
@end

