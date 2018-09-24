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

#import "rationalUtilities.h"

@interface CPRationalDomN : NSObject<CPRationalDomN,NSCopying> {
   id<ORTrail>           _trail;
   id<ORRational>           _imin;
   id<ORRational>           _imax;
   TRRationalInterval    _domain;
}
// Always gives to possiblity to use base type for precision (cpjm)
-(id)initCPRationalDom:(id<ORTrail>)trail low:(id<ORRational>)low up:(id<ORRational>)up;
// Not reason to use ORFloat here. Use ORDouble instead (cpjm)
-(id)initCPRationalDom:(id<ORTrail>)trail lowF:(ORDouble)low upF:(ORDouble)up;
-(id)initCPRationalDom:(id<ORTrail>)trail;
-(void) updateMin:(id<ORRational>)newMin for:(id<CPRationalVarNotifier>)x;
-(void) updateMax:(id<ORRational>)newMax for:(id<CPRationalVarNotifier>)x;
-(void) updateInterval:(id<ORRationalInterval>)v for:(id<CPRationalVarNotifier>)x;
-(void) bind:(id<ORRational>)val  for:(id<CPRationalVarNotifier>)x;
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
-(void) restoreValue:(id<ORRational>)toRestore for:(id<CPRationalVarNotifier>)x;
@end

#endif /* CPRationalDomN_h */
