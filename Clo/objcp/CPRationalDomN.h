//
//  CPRationalDomN.h
//  objcp
//
//  Created by Rémy Garcia on 04/07/2018.
//

#ifndef CPRationalDomN_h
#define CPRationalDomN_h

#import <ORFoundation/ORFoundation.h>
#import <CPUKernel/CPTypes.h>
#import <objcp/CPDom.h>

#include "rationalUtilities.h"

@interface CPRationalDomN : NSObject<CPRationalDomN,NSCopying> {
   id<ORTrail>           _trail;
   ORRational           _imin;
   ORRational           _imax;
   TRRationalInterval    _domain;
}
// Always gives to possiblity to use base type for precision (cpjm)
-(id)initCPRationalDom:(id<ORTrail>)trail low:(ORRational)low up:(ORRational)up;
// Not reason to use ORFloat here. Use ORDouble instead (cpjm)
-(id)initCPRationalDom:(id<ORTrail>)trail lowF:(ORDouble)low upF:(ORDouble)up;
-(id)initCPRationalDom:(id<ORTrail>)trail;
-(void) updateMin:(ORRational)newMin for:(id<CPRationalVarNotifier>)x;
-(void) updateMax:(ORRational)newMax for:(id<CPRationalVarNotifier>)x;
-(void) updateInterval:(ri)v for:(id<CPRationalVarNotifier>)x;
-(void) bind:(ORRational)val  for:(id<CPRationalVarNotifier>)x;
-(ORRational) min;
-(ORRational) max;
-(ORRational) imin;
-(ORRational) imax;
-(ORBool) bound;
-(ORInterval) bounds;
-(TRRationalInterval) domain;
-(ORBool) member:(ORRational)v;
-(id) copy;
-(void) restoreDomain:(id<CPRationalDom>)toRestore;
-(void) restoreValue:(ORRational)toRestore for:(id<CPRationalVarNotifier>)x;
@end

#endif /* CPRationalDomN_h */
