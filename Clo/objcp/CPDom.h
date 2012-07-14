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
-(CPStatus) updateMin:(CPInt)newMin for:(id<CPIntVarNotifier>)x;
-(CPStatus) updateMax:(CPInt)newMax for:(id<CPIntVarNotifier>)x;
-(CPStatus) bind:(CPInt)val  for:(id<CPIntVarNotifier>)x;
-(CPStatus) remove:(CPInt)val  for:(id<CPIntVarNotifier>)x;

-(CPInt)min;
-(CPInt)max;
-(CPInt)imin;
-(CPInt)imax;
-(bool)bound;
-(CPBounds)bounds;
-(CPInt)domsize;
-(CPInt)countFrom:(CPInt)from to:(CPInt)to;
-(bool)get:(CPInt)b;
-(bool)member:(CPInt)v;
-(CPInt)findMin:(CPInt)from;
-(CPInt)findMax:(CPInt)from;
-(id)copy;
-(void)restoreDomain:(id<CPDom>)toRestore;
-(void)restoreValue:(CPInt)toRestore;
@end
