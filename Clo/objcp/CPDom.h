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

@protocol CPDom <NSObject,NSCopying>
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
-(ORInt) countFrom:(ORInt)from to:(ORInt)to;
-(ORBool) get:(ORInt)b;
-(ORBool) member:(ORInt)v;
-(ORInt)findMin:(ORInt)from;
-(ORInt) findMax:(ORInt)from;
-(id) copy;
-(void) restoreDomain:(id<CPDom>)toRestore;
-(void) restoreValue:(ORInt)toRestore for:(id<CPIntVarNotifier>)x tle:(BOOL)tle;
-(void) enumerateWithBlock:(void(^)(ORInt))block;
-(void) enumerateBackwardWithBlock:(void(^)(ORInt))block;
@end

@protocol CPRealVarNotifier;
@protocol CPFDom
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
-(void) restoreDomain:(id<CPFDom>)toRestore;
-(void) restoreValue:(ORDouble)toRestore for:(id<CPRealVarNotifier>)x;
@end
