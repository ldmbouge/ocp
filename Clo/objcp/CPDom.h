/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <Foundation/Foundation.h>
#import <objcp/CPData.h>

@protocol CPIntVarNotifier;

@protocol CPDom <NSObject,NSCopying>
-(void)dealloc;
-(ORStatus) updateMin:(ORInt)newMin for:(id<CPIntVarNotifier>)x;
-(ORStatus) updateMax:(ORInt)newMax for:(id<CPIntVarNotifier>)x;
-(ORStatus) bind:(ORInt)val  for:(id<CPIntVarNotifier>)x;
-(ORStatus) remove:(ORInt)val  for:(id<CPIntVarNotifier>)x;

-(ORInt) min;
-(ORInt) max;
-(ORInt) imin;
-(ORInt) imax;
-(bool) bound;
-(ORBounds) bounds;
-(ORInt) domsize;
-(ORInt) countFrom:(ORInt)from to:(ORInt)to;
-(bool) get:(ORInt)b;
-(bool) member:(ORInt)v;
-(ORInt)findMin:(ORInt)from;
-(ORInt) findMax:(ORInt)from;
-(id) copy;
-(void) restoreDomain:(id<CPDom>)toRestore;
-(void) restoreValue:(ORInt)toRestore;
@end
