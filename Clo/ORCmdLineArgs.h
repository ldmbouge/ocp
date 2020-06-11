/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <Foundation/Foundation.h>
#import <ORFoundation/ORFoundation.h>
#import <ORModeling/ORModeling.h>
#import <ORProgram/ORProgram.h>

enum Heuristic {
   FF = 0,
   ABS = 1,
   IBS = 2,
   WDEG = 3,
   DDEG = 4,
   SDEG = 5
};

struct ORResult {
   ORInt found;
   ORInt nbFailures;
   ORInt nbChoices;
   ORInt nbPropagations;
};

#define REPORT(f,nbf,nbc,nbp) ((struct ORResult){(f),(nbf),(nbc),(nbp)})

@interface ORCmdLineArgs : NSObject
@property (nonatomic,readonly) ORInt size;
@property (nonatomic,readonly) ORDouble restartRate;
@property (nonatomic,readonly) ORInt   timeOut;
@property (nonatomic,readonly) BOOL    randomized;
@property (nonatomic,readonly) enum Heuristic heuristic;
@property (nonatomic,readonly) ORInt    nbThreads;
@property (nonatomic,readonly) ORInt    nArg;
@property (nonatomic,readonly) NSString* fName;
+(id)newWith:(int)argc argv:(const char**)argv;
-(id)init:(int)argc argv:(const char**)argv;
-(NSString*)heuristicName;
-(void)measure:(struct ORResult(^)(void))block;
-(id<CPProgram>)makeProgram:(id<ORModel>)model;
-(id<CPProgram>)makeProgram:(id<ORModel>)model annotation:(id<ORAnnotation>)notes;
-(id<CPHeuristic>)makeHeuristic:(id<CPProgram>)cp restricted:(id<ORIntVarArray>)x;
@end
