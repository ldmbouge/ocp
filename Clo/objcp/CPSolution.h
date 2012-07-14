/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <objcp/CPTypes.h>

@protocol CPSolver;

@protocol CPSnapshot
-(void)restoreInto:(NSArray*)av;
-(int)intValue;
-(BOOL)boolValue;
@end

@protocol CPSavable<NSObject>
-(id)snapshot;
@end

@protocol CPSolution <NSObject>
-(CPInt)intValue:(id)var;
-(BOOL)boolValue:(id)var;
-(NSUInteger)count;
-(void)restoreInto:(id<CPSolver>)solver;
@end
