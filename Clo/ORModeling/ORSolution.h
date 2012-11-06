/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>

@protocol ORSnapshot
-(void) restoreInto: (NSArray*) av;
-(int)  intValue;
-(BOOL) boolValue;
@end

@protocol ORSavable<NSObject>
-(id) snapshot;
@end

@protocol ORSolution <ORObject>
-(ORInt) intValue: (id) var;
-(BOOL) boolValue: (id) var;
-(NSUInteger) count;
//-(void) restoreInto: (id<OREngine>) engine;
@end

@protocol ORSolutionProtocol <NSObject>
-(void)        saveSolution;
-(void)     restoreSolution;
-(id<ORSolution>) solution;
@end