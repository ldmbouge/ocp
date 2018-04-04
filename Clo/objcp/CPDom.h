/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <Foundation/Foundation.h>
#import <objcp/CPData.h>

@protocol CPIntVarNotifier;

@protocol CPADom <NSObject,NSCopying>
-(void) unionWith:(id<CPADom>)d;
@end

@protocol CPDom <CPADom>
-(void)dealloc;
-(void) updateMin:(ORInt)newMin for:(id<CPIntVarNotifier>)x tle:(BOOL)tle;
-(void) updateMax:(ORInt)newMax for:(id<CPIntVarNotifier>)x tle:(BOOL)tle;
-(void) updateMin:(ORInt)newMin andMax:(ORInt)newMax for:(id<CPIntVarNotifier>)x tle:(BOOL)tle;
-(void) bind:(ORInt)val  for:(id<CPIntVarNotifier>)x tle:(BOOL)tle;
-(void) remove:(ORInt)val  for:(id<CPIntVarNotifier>)x;

-(ORInt) min;
-(ORInt) max;
-(ORInt) imin;
-(ORInt) imax;
-(ORBool) bound;
-(ORBounds) bounds;
-(ORInt) domsize;
-(ORInt) regret;
-(ORInt) countFrom:(ORInt)from to:(ORInt)to;
-(ORBool) get:(ORInt)b;
-(ORBool) member:(ORInt)v;
-(ORInt)findMin:(ORInt)from;
-(ORInt) findMax:(ORInt)from;
-(BOOL) isEqual:(id)object;
-(id) copy;
-(void) restoreDomain:(id<CPDom>)toRestore;
-(void) restoreValue:(ORInt)toRestore for:(id<CPIntVarNotifier>)x tle:(BOOL)tle;
-(void) enumerateWithBlock:(void(^)(ORInt))block;
-(void) enumerateBackwardWithBlock:(void(^)(ORInt))block;
@end

@protocol CPRealVarNotifier;
@protocol CPRealDom <CPADom>
-(void) updateMin:(ORDouble)newMin for:(id<CPRealVarNotifier>)x;
-(void) updateMax:(ORDouble)newMax for:(id<CPRealVarNotifier>)x;
-(ORNarrowing) updateInterval:(ORInterval)v for:(id<CPRealVarNotifier>)x;
-(void) bind:(ORDouble)val  for:(id<CPRealVarNotifier>)x;
-(ORDouble) min;
-(ORDouble) max;
-(ORDouble) imin;
-(ORDouble) imax;
-(ORBool) bound;
-(ORInterval) bounds;
-(ORDouble) domwidth;
-(ORBool) member:(ORDouble)v;
-(NSString*)description;
-(id) copy;
-(void) restoreDomain:(id<CPRealDom>)toRestore;
-(void) restoreValue:(ORDouble)toRestore for:(id<CPRealVarNotifier>)x;
@end


@protocol CPFloatVarNotifier;
@protocol CPFloatDom <CPADom>
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
-(ORDouble) domwidth;
-(ORFloat) magnitude;
-(ORBool) member:(ORFloat)v;
-(NSString*)description;
-(id) copy;
-(void) restoreDomain:(id<CPFloatDom>)toRestore;
-(void) restoreValue:(ORFloat)toRestore for:(id<CPFloatVarNotifier>)x;
@end

@protocol CPFloatVarNotifier;
@protocol CPRationalDom
-(void) updateMin:(ORRational)newMin for:(id<CPFloatVarNotifier>)x;
-(void) updateMax:(ORRational)newMax for:(id<CPFloatVarNotifier>)x;
-(ORNarrowing) updateInterval:(ORInterval)v for:(id<CPFloatVarNotifier>)x;
-(void) bind:(ORRational)val  for:(id<CPFloatVarNotifier>)x;
-(ORRational*) min;
-(ORRational*) max;
-(ORRational*) imin;
-(ORRational*) imax;
-(ORBool) bound;
-(ORInterval) bounds;
//-(ORLDouble) domwidth;
-(TRRationalInterval) domain;
-(ORBool) member:(ORRational)v;
-(NSString*)description;
-(id) copy;
-(void) restoreDomain:(id<CPRationalDom>)toRestore;
-(void) restoreValue:(ORRational)toRestore for:(id<CPFloatVarNotifier>)x;
@end

//@protocol CPDoubleVarNotifier;
@protocol CPDoubleDom <CPADom>
-(void) updateMin:(ORDouble)newMin for:(id<CPFloatVarNotifier>)x;
-(void) updateMax:(ORDouble)newMax for:(id<CPFloatVarNotifier>)x;
-(ORNarrowing) updateInterval:(ORInterval)v for:(id<CPFloatVarNotifier>)x;
-(void) bind:(ORDouble)val  for:(id<CPFloatVarNotifier>)x;
-(ORDouble) min;
-(ORDouble) max;
-(ORDouble) imin;
-(ORDouble) imax;
-(ORBool) bound;
-(ORInterval) bounds;
-(ORDouble) magnitude;
-(ORLDouble) domwidth;
-(ORBool) member:(ORDouble)v;
-(NSString*)description;
-(id) copy;
-(void) restoreDomain:(id<CPDoubleDom>)toRestore;
-(void) restoreValue:(ORDouble)toRestore for:(id<CPFloatVarNotifier>)x;
@end



@protocol CPLDoubleVarNotifier;
@protocol CPLDoubleDom <CPADom>
-(void) updateMin:(ORLDouble)newMin for:(id<CPLDoubleVarNotifier>)x;
-(void) updateMax:(ORLDouble)newMax for:(id<CPLDoubleVarNotifier>)x;
-(void) bind:(ORLDouble)val  for:(id<CPLDoubleVarNotifier>)x;
-(ORLDouble) min;
-(ORLDouble) max;
-(ORLDouble) imin;
-(ORLDouble) imax;
-(ORBool) bound;
-(ORInterval) bounds;
-(ORLDouble) domwidth;
-(ORBool) member:(ORLDouble)v;
-(NSString*)description;
-(id) copy;
-(void) restoreDomain:(id<CPLDoubleDom>)toRestore;
-(void) restoreValue:(ORLDouble)toRestore for:(id<CPLDoubleVarNotifier>)x;
@end
