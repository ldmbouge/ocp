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
#import "ExprSimplifier.h"

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
   lexico=29,
   absDens = 30,
   custom = 31,
   customD = 32,
   customWD = 33,
   maxLOcc  = 34,
   occdens  = 35
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
   splitAbs = 9,
   Esplit = 10,
   Dsplit = 11
};
struct ORResult {
   ORInt found;
   ORInt nbFailures;
   ORInt nbChoices;
   ORInt nbPropagations;
   ORInt nbSRewrites;
   ORInt nbDRewrites;
   NSUInteger nbVariables;
   NSUInteger nbConstraints;
};

#define REPORT(f,nbf,nbc,nbp) ((struct ORResult){(f),(nbf),(nbc),(nbp)})

#define FULLREPORT(f,nbf,nbc,nbp,nbs,nbd,nbv,nbcst) ((struct ORResult){(f),(nbf),(nbc),(nbp),(nbs),(nbd),(nbv),(nbcst)})

@interface ORCmdLineArgs : NSObject
@property (nonatomic,readonly) ORInt size;
@property (nonatomic,readonly) ORDouble restartRate;
@property (nonatomic,readonly) ORInt   timeOut;
@property (nonatomic,readonly) BOOL    randomized;
@property (nonatomic,readonly) enum Heuristic heuristic;
@property (nonatomic,readonly) enum ValHeuristic valordering;
@property (nonatomic,readonly) enum ValHeuristic subcut;
@property (nonatomic,readonly) enum ValHeuristic defaultAbsSplit;
@property (nonatomic,readonly) ORBool is3Bfiltering;
@property (nonatomic,readonly) ORDouble kbpercent;
@property (nonatomic,readonly) ORInt uniqueNB;
@property (nonatomic,readonly) ORFloat search3Bpercent;
@property (nonatomic,readonly) ORInt searchNBFloats;
@property (nonatomic,readonly) ORInt    nbThreads;
@property (nonatomic,readonly) ORInt    nArg;
@property (nonatomic,readonly) ORBool    bds;
@property (nonatomic,readonly) ORBool    cycleDetection;
@property (nonatomic,readonly) ORBool    ldfs;
@property (nonatomic,readonly) ORBool    withAux;
@property (nonatomic,readonly) ORBool    withRewriting;
@property (nonatomic,readonly) ORBool    withSRewriting;
@property (nonatomic,readonly) ORBool    withDRewriting;
@property (nonatomic,readonly) ORInt    level;
@property (nonatomic,readonly) ORInt    choicesLimit;
@property (nonatomic,readonly) NSString* fName;
@property (nonatomic,readonly) ORDouble absRate;
@property (nonatomic,readonly) ORDouble occRate;
@property (nonatomic,readonly) ORDouble rateModel;
@property (nonatomic,readonly) ORDouble grateModel;
@property (nonatomic,readonly) ORDouble rateOther;
@property (nonatomic,readonly) ORDouble grateOther;
@property (nonatomic,readonly) ORInt variationSearch;
@property (nonatomic,readonly) ORInt splitTest;
@property (nonatomic,readonly) ORBool specialSearch;
@property (nonatomic,readonly) ABS_FUN absFunComputation;
@property (nonatomic,readonly) ORBool occDetails;
+(id)newWith:(int)argc argv:(const char**)argv;
-(id)init:(int)argc argv:(const char**)argv;
-(NSString*)heuristicName;
-(void)measure:(struct ORResult(^)(void))block;
-(void)measureTime:(void(^)(void))block;
-(ORBool) checkAllbound:(id<ORModel>) model with:(id<CPProgram>) cp;
-(void) printSolution:(id<ORModel>) model with:(id<CPProgram>) cp;
-(id<ORGroup>)makeGroup:(id<ORModel>)model;
-(id<CPProgram>)makeProgram:(id<ORModel>)model;
-(id<CPProgram>)makeProgram:(id<ORModel>)model annotation:(id<ORAnnotation>)notes;
-(id<CPProgram>) makeProgramWithSimplification:(id<ORModel>)model constraints:(NSArray*) toadd;
-(id<ORDisabledVarArray>) makeDisabledArray:(id<CPProgram>)p from:(id<ORVarArray>)vs;
-(id<CPHeuristic>)makeHeuristic:(id<CPProgram>)cp restricted:(id<ORIntVarArray>)x;
-(void)launchHeuristic:(id<CPProgram>)cp restricted:(id<ORVarArray>)x;
-(ORBool) isCycle:(id<ORModel>) model;
-(void) printOccurences:(id<ORModel>) model with:(id<CPProgram>) cp restricted:(id<ORVarArray>) vars;
-(void) printMaxGOccurences:(id<ORModel>) model with:(id<CPProgram>) cp n:(ORInt) n;
-(void) printMaxLOccurences:(id<ORModel>) model with:(id<CPProgram>) cp n:(ORInt) n;
+(void) defaultRunner:(ORCmdLineArgs*) args model:(id<ORModel>) model program:(id<CPProgram>) cp;
+(void) defaultRunner:(ORCmdLineArgs*) args model:(id<ORModel>) model program:(id<CPProgram>) cp restrict:(id<ORVarArray>) vars;
@end
