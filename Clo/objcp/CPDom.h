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

@protocol CPFloatVarNotifier;
@protocol CPFDom
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
-(NSString*)description;
-(id) copy;
-(void) restoreDomain:(id<CPFDom>)toRestore;
-(void) restoreValue:(ORFloat)toRestore for:(id<CPFloatVarNotifier>)x;
@end
