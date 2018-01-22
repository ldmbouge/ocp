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
   SDEG = 5,
   maxWidth = 10,
   minWidth = 11,
   maxCard  = 12,
   minCard  = 13,
   maxDens  = 14,
   minDens  = 15,
   minMagn  = 16,
   maxMagn  = 17,
   maxDegree  = 18,
   minDegree  = 19,
   maxOcc  = 20,
   minOcc  = 21,
   maxAbs  = 22,
   minAbs  = 23,
   maxCan  = 24,
   minCan  = 25,
   absWDens  = 26,
   densWAbs  = 27,
   ref = 28,
   lexico=29
};
enum ValHeuristic
{
   split = 0,
   split3Way = 1,
   split5Way = 2,
   split6Way = 3,
   dynamicSplit = 4,
   dynamic3Split = 5,
   dynamic5Split = 6,
   dynamic6Split = 7,
   split3B = 8,
   dedicatedSplit = 9
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
@property (nonatomic,readonly) enum ValHeuristic valordering;
@property (nonatomic,readonly) enum ValHeuristic defaultAbsSplit;
@property (nonatomic,readonly) ORBool is3Bfiltering;
@property (nonatomic,readonly) ORBool unique;
@property (nonatomic,readonly) ORInt    nbThreads;
@property (nonatomic,readonly) ORInt    nArg;
@property (nonatomic,readonly) ORInt    level;
@property (nonatomic,readonly) NSString* fName;
+(id)newWith:(int)argc argv:(const char**)argv;
-(id)init:(int)argc argv:(const char**)argv;
-(NSString*)heuristicName;
-(void)measure:(struct ORResult(^)(void))block;
-(id<ORGroup>)makeGroup:(id<ORModel>)model;
-(id<CPProgram>)makeProgram:(id<ORModel>)model;
-(id<CPProgram>)makeProgram:(id<ORModel>)model annotation:(id<ORAnnotation>)notes;
-(id<CPHeuristic>)makeHeuristic:(id<CPProgram>)cp restricted:(id<ORIntVarArray>)x;
-(void)launchHeuristic:(id<CPProgram>)cp restricted:(id<ORFloatVarArray>)x;
@end
