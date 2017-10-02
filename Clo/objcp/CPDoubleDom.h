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

#include <fpi.h>

//TODO UPDATE ED_MAX
#define NB_DOUBLE_BY_E (4.5035996e+15)
#define ED_MAX (254)

/*useful struct to get exponent mantissa and sign*/
typedef union {
    double f;
    struct {
        unsigned long mantisa : 52;
        unsigned int exponent : 11;
        unsigned int sign : 1;
    } parts;
} double_cast;


@interface CPDoubleDom : NSObject<CPDoubleDom,NSCopying> {
    id<ORTrail>        _trail;
    ORDouble            _imin;
    ORDouble            _imax;
    TRDoubleInterval    _domain;
}
-(id)initCPDoubleDom:(id<ORTrail>)trail low:(ORDouble)low up:(ORDouble)up;
-(void) updateMin:(ORDouble)newMin for:(id<CPDoubleVarNotifier>)x;
-(void) updateMax:(ORDouble)newMax for:(id<CPDoubleVarNotifier>)x;
-(void) updateInterval:(double_interval)v for:(id<CPDoubleVarNotifier>)x;
-(void) bind:(ORDouble)val  for:(id<CPDoubleVarNotifier>)x;
-(ORDouble) min;
-(ORDouble) max;
-(ORDouble) imin;
-(ORDouble) imax;
-(ORBool) bound;
-(ORInterval) bounds;
-(ORLDouble) domwidth;
-(TRDoubleInterval) domain;
-(ORDouble) cardinality;
-(ORBool) member:(ORDouble)v;
-(id) copy;
-(void) restoreDomain:(id<CPDoubleDom>)toRestore;
-(void) restoreValue:(ORDouble)toRestore for:(id<CPDoubleVarNotifier>)x;
@end
