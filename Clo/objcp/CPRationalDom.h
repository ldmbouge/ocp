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
#import <objcp/CPRationalVarI.h>

@interface CPRationalDom : NSObject<CPRationalDom,NSCopying> {
    id<ORTrail>           _trail;
    ORRational            _imin;
    ORRational            _imax;
    TRRationalInterval       _domain;
}
-(id)initCPRationalDom:(id<ORTrail>)trail low:(ORRational)low up:(ORRational)up;
-(void) updateMin:(ORRational)newMin for:(id<CPRationalVarNotifier>)x;
-(void) updateMax:(ORRational)newMax for:(id<CPRationalVarNotifier>)x;
-(void) updateInterval:(rational_interval)v for:(id<CPRationalVarNotifier>)x;
-(void) bind:(ORRational)val  for:(id<CPRationalVarNotifier>)x;
-(ORRational*) min;
-(ORRational*) max;
-(ORRational*) imin;
-(ORRational*) imax;
-(ORBool) bound;
-(ORInterval) bounds;
//-(ORLDouble) domwidth;
-(TRRationalInterval) domain;
-(ORBool) member:(ORRational)v;
-(id) copy;
-(void) restoreDomain:(id<CPRationalDom>)toRestore;
-(void) restoreValue:(ORRational)toRestore for:(id<CPRationalVarNotifier>)x;
@end

