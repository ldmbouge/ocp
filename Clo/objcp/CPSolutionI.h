/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <Foundation/Foundation.h>
#import <ORFoundation/ORFoundation.h>

@protocol CPEngine;

@interface CPSolutionI : NSObject<ORSolution,NSCoding> {
   NSArray* _shots;
}
-(CPSolutionI*) initCPSolution: (id<CPEngine>) solver;
-(void) dealloc;
-(int) intValue: (id) var;
-(BOOL)boolValue: (id) var;
-(ORULong) count;
-(void) restoreInto: (id<CPEngine>) engine;
@end
