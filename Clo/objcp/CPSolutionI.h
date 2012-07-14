/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <Foundation/Foundation.h>
#import <objcp/CPSolution.h>

@protocol CPSolver;

@interface CPSolutionI : NSObject<CPSolution,NSCoding> {
   NSArray* _shots;
}
-(CPSolutionI*)initCPSolution:(id<CPSolver>)solver;
-(void)dealloc;
-(int)intValue:(id)var;
-(BOOL)boolValue:(id)var;
-(CPULong)count;
-(void)restoreInto:(id<CPSolver>)solver;
@end
