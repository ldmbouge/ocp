/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "ORCmdLineArgs.h"
#include <fenv.h>



@implementation ORCmdLineArgs {
   int           _argc;
   const char**  _argv;
   int           _nbDMerged;
   int           _nbSMerged;
}
static NSString* hName[] = {@"FF",@"ABS",@"IBS",@"WDeg",@"DDeg",@"SDeg",//intSearch
   @"maxWidth",@"minWidth",@"maxCard",@"minCard",@"maxDens",@"minDens",@"minMagn",@"maxMagn",
   @"maxDegree",@"minDegree",@"maxOcc",@"minOcc",@"maxAbs",@"minAbs",@"maxCan",
   @"minCan",@"absWDens", @"densWAbs", @"ref",@"lexico",@"absDens",@"custom",@"customD",@"customWD",@"maxLOCC",@"occdens",@"occTBdens"};

static enum Heuristic hIndex[] = {FF, ABS, IBS, WDEG, DDEG, SDEG,
   maxWidth, minWidth, maxCard,  minCard,   maxDens,   minDens,   minMagn,   maxMagn,
   maxDegree, minDegree, maxOcc, minOcc, maxAbs, minAbs, maxCan, minCan, absWDens,
   densWAbs , ref ,lexico,absDens,custom,customD,customWD,maxLOcc,occdens,occTBdens};

static NSString* valHName[] = {@"split",@"split3Way",@"split5Way",@"split6Way",@"dynamicSplit",@"dynamic3Split",@"dynamic5Split",@"dynamic6Split",@"split3B",@"splitAbs",@"ESplit",@"DSplit"};

static enum ValHeuristic valIndex[] =
{split,split3Way,split5Way,split6Way,dynamicSplit,dynamic3Split,dynamic5Split,dynamic6Split,split3B,splitAbs,Esplit,Dsplit};
@synthesize size;
@synthesize restartRate;
@synthesize timeOut;
@synthesize randomized;
@synthesize heuristic;
@synthesize valordering;
@synthesize subcut;
@synthesize defaultAbsSplit;
@synthesize nbThreads;
@synthesize nArg;
@synthesize bds;
@synthesize withAux;
@synthesize withDRewriting;
@synthesize withSRewriting;
@synthesize ldfs;
@synthesize cycleDetection;
@synthesize level;
@synthesize uniqueNB;
@synthesize is3Bfiltering;
@synthesize kbpercent;
@synthesize search3Bpercent;
@synthesize searchNBFloats;
@synthesize fName;
@synthesize absRate;
@synthesize occRate;
@synthesize rateModel;
@synthesize grateModel;
@synthesize rateOther;
@synthesize grateOther;
@synthesize variationSearch;
@synthesize choicesLimit;
@synthesize splitTest;
@synthesize specialSearch;
@synthesize absFunComputation;
@synthesize occDetails;
@synthesize restricted;
@synthesize middle;
@synthesize printSolution;



+(void) defaultRunner:(ORCmdLineArgs*) args model:(id<ORModel>) model program:(id<CPProgram>) cp restrict:(id<ORVarArray>) vars
{
   fesetround(FE_TONEAREST);
//   NSLog(@"model : %@",model);
   [args measure:^struct ORResult(){
      ORBool hascycle = NO;
      if([args cycleDetection]){
         hascycle = [args isCycle:model];
         NSLog(@"%s",(hascycle)?"YES":"NO");
      }
      __block ORBool isSat = false;
      if(!hascycle){
         id<ORIntArray> locc = [VariableLocalOccCollector collect:[model constraints] with:[model variables] tracker:model];
         [(CPCoreSolver*)cp setLOcc:locc];
         if([args occDetails]){
            [args printOccurences:model with:cp restricted:vars];
            //               [_options printMaxGOccurences:_model with:cp n:5];
            //               [_options printMaxLOccurences:_model with:cp n:5];
         }
         [cp solveOn:^(id<CPCommonProgram> p) {
            [args launchHeuristic:cp restricted:vars];
            isSat = [args checkAllbound:model with:cp];
            NSLog(@"Depth : %d",[[cp tracer] level]);
            if([args printSolution])
               [args printSolution:model with:cp];
         } withTimeLimit:[args timeOut]];
      }
      
      struct ORResult r = FULLREPORT(isSat, [[cp engine] nbFailures],[[cp explorer] nbChoices], [[cp engine] nbPropagation],[[cp engine] nbStaticRewrites],[[cp engine] nbDynRewrites],[[model variables] count], [[model constraints] count]);
      printf("%s\n",(isSat)?"sat":"unsat");
      return r;
   }];
}

+(void) defaultRunner:(ORCmdLineArgs*) args model:(id<ORModel>) model program:(id<CPProgram>) cp
{
   id<ORVarArray> vars =  [args makeDisabledArray:cp from:[model FPVars]];
   [ORCmdLineArgs defaultRunner:args model:model program:cp restrict:vars];
}

+(void) defaultRunner:(ORCmdLineArgs*) args model:(id<ORModel>) model program:(id<CPProgram>) cp restricted:(NSArray*) vars
{
   id<ORVarArray> searchvars;
   if([args restricted]){
      searchvars =(id<ORVarArray>) [ORFactory idArray:model array:vars];
   }else{
      searchvars =  [model FPVars];
   }
   id<ORVarArray> vs =  [args makeDisabledArray:cp from:searchvars];
   [ORCmdLineArgs defaultRunner:args model:model program:cp restrict:vs];
}

+(ORCmdLineArgs*)newWith:(int)argc argv:(const char*[])argv
{
   ORCmdLineArgs* rv = [[ORCmdLineArgs alloc] init:argc argv:argv];
#if !__has_feature(objc_arc)
   [rv autorelease];
#endif
   return rv;
}
-(id)init:(int)argc argv:(const char*[])argv
{
   self = [super init];
   _argc = argc;
   _argv = argv;
   restricted = NO;
   size = 4;
   nArg = 0;
   heuristic = customD;
   valordering = dynamic5Split;
   subcut = dynamicSplit;
   defaultAbsSplit = dynamic6Split;
   restartRate = 0;
   timeOut = 60;
   nbThreads = 0;
   level = 0;
   bds = NO;
   withAux = NO;
   withSRewriting = NO;
   withDRewriting = NO;
   ldfs = NO;
   uniqueNB = 0;
   is3Bfiltering = NO;
   kbpercent=8;
   search3Bpercent=10;
   searchNBFloats=2;
   fName = @"";
   randomized = NO;
   cycleDetection = NO;
   variationSearch = 0;
   choicesLimit = -1;
   splitTest = 0;
   specialSearch = NO;
   absRate = -1;
   occRate = -1;
   rateOther = 1.1;
   grateOther = 1.1;
   rateModel = 0.85;
   grateModel = 0.85;
   absFunComputation = AMEAN;
   _nbSMerged = 0;
   _nbDMerged = 0;
   occDetails = NO;
   middle = YES;
   printSolution = NO;
   for(int k = 1;k< argc;k++) {
      if (strncmp(argv[k], "?", 1) == 0 || strncmp(argv[k], "-help", 5) == 0  ){
         printf("-var-order HEURISTIC : replace HEURISTIC by one of following FF, ABS, IBS, WDeg, DDeg, SDeg, maxWidth, minWidth, maxCard, minCard, maxDens, minDens, minMagn, maxMagn, maxDegree, minDegree, maxOcc, minOcc, maxAbs, minAbs, maxCan, minCan, absWDens, densWAbs, ref, lexico, absDens\n");
         printf("-val-order HEURISTIC : replace HEURISTIC by one of following split,split3Way,split5Way,split6Way,dynamicSplit,dynamic3Split,dynamic5Split,dynamic6Split,split3B,splitAbs,Esplit,Dsplit\n");
         printf("-rate-model-limit VALUE : replace VALUE by a concrete value\n");
         printf("-grate-model-limit VALUE : replace VALUE by a concrete value\n");
         printf("-rate-other-limit VALUE : replace VALUE by a concrete value\n");
         printf("-grate-other-limit VALUE : rmplace VALUE by a concrete value\n");
         exit(1);
      }
      else if (strncmp(argv[k], "-cycle-detection", 16) == 0)
         cycleDetection = YES;
      else if (strncmp(argv[k], "-with-aux", 9) == 0)
         withAux = YES;
      else if (strncmp(argv[k], "-with-rewriting-eq", 18) == 0){
         withSRewriting = YES;
         withDRewriting = YES;
      }else if (strncmp(argv[k], "-with-static-rewriting", 22) == 0)
         withSRewriting = YES;
      else if (strncmp(argv[k], "-with-dyn-rewriting", 19) == 0)
         withDRewriting = YES;
      else if (strncmp(argv[k], "-bds", 4) == 0)
         bds = YES;
      else if (strncmp(argv[k], "-ldfs", 5) == 0)
         ldfs = YES;
      else if (strncmp(argv[k], "-q", 2) == 0)
         size = atoi(argv[k]+2);
      else if (strncmp(argv[k],"-choices-limit",14)==0)
         choicesLimit = atoi(argv[k+1]);
      else if (strncmp(argv[k],"-split-test",11)==0)
         splitTest = atoi(argv[k+1]);
      else if (strncmp(argv[k],"-search3Bpercent",16)==0)
         search3Bpercent = atof(argv[k+1]);
      else if(strncmp(argv[k],"-abs-rate",9) == 0){
         absRate = atof(argv[k+1]);
      }else if(strncmp(argv[k],"-abs-function",13) == 0){
         NSString *tmp = [NSString stringWithCString:argv[k+1] encoding:NSASCIIStringEncoding];
         if ([[tmp lowercaseString] isEqualToString:@"min"]) {
            absFunComputation = MIN;
         }else if([[tmp lowercaseString] isEqualToString:@"max"]){
            absFunComputation = MAX;
         }else if([[tmp lowercaseString] isEqualToString:@"gmean"]){
            absFunComputation = GMEAN;
         }
      }else if(strncmp(argv[k],"-occ-rate",9) == 0){
         occRate = atof(argv[k+1]);
      }else if(strncmp(argv[k],"-occ-details",12) == 0){
         occDetails = YES;
      }else if(strncmp(argv[k],"-model-limits",13) == 0){
         rateModel = atof(argv[k+1]);
         grateModel = atof(argv[k+1]);
      }else if(strncmp(argv[k],"-other-limits",13) == 0){
         rateOther = atof(argv[k+1]);
         grateOther = atof(argv[k+1]);
      }else if (strncmp(argv[k],"-rate-model-limit",17)==0)
         rateModel = atof(argv[k+1]);
      else if (strncmp(argv[k],"-grate-model-limit",18)==0 || strncmp(argv[k],"-globalrate-model-limit",23)==0 )
         grateModel = atof(argv[k+1]);
      else if (strncmp(argv[k],"-rate-other-limit",17)==0)
         rateOther = atof(argv[k+1]);
      else if (strncmp(argv[k],"-grate-other-limit",18)==0 || strncmp(argv[k],"-globalrate-other-limit",23)==0)
         grateOther = atof(argv[k+1]);
      else if (strncmp(argv[k],"-restrict",9)==0)
         restricted = YES;
      else if (strncmp(argv[k],"-no-middle",9)==0)
         middle = NO;
      else if (strncmp(argv[k],"-print-solution",15)==0)
            printSolution = YES;
      else if (strncmp(argv[k],"-variation",10)==0){
         NSString *tmp = [NSString stringWithCString:argv[k+1] encoding:NSASCIIStringEncoding];
         int index = 24;
         for(int i = 0; i < 28;i++){
            if ([tmp isEqualToString:hName[i]] || [[tmp lowercaseString] isEqualToString:[hName[i] lowercaseString]]){
               index = i;
               break;
            }
         }
         variationSearch = hIndex[index];
      } else if (strncmp(argv[k],"-nb-floats",10)==0)
         searchNBFloats = atoi(argv[k+1]);
      else if (strncmp(argv[k], "-n", 2)==0)
         nArg = atoi(argv[k]+2);
      else if (strncmp(argv[k], "-h", 2)==0)
         heuristic = atoi(argv[k]+2);
      else if (strncmp(argv[k], "-var-order", 10)==0){
         NSString *tmp = [NSString stringWithCString:argv[k+1] encoding:NSASCIIStringEncoding];
         int index = 24;
         for(int i = 0; i < 33;i++){
            if ([tmp isEqualToString:hName[i]] || [[tmp lowercaseString] isEqualToString:[hName[i] lowercaseString]]){
               index = i;
               break;
            }
         }
         heuristic = hIndex[index];
      }
      else if (strncmp(argv[k],"-w",2)==0)
         restartRate = atof(argv[k]+2);
      else if (strncmp(argv[k],"-t",2)==0 && strlen(argv[k]) == 2)
         timeOut = atoi(argv[k+1]);
      else if (strncmp(argv[k],"-r",2)==0)
         randomized = atoi(argv[k]+2);
      else if (strncmp(argv[k],"-percent",8)==0)
         kbpercent=atof(argv[k+1]);
      else if (strncmp(argv[k],"-p",2)==0)
         nbThreads = atoi(argv[k]+2);
      else if (strncmp(argv[k],"-f",2)==0)
         fName = [NSString stringWithCString:argv[k]+2 encoding:NSASCIIStringEncoding];
      else if (strncmp(argv[k],"-vh",3)==0)
         valordering = atoi(argv[k]+3);
      else if (strncmp(argv[k], "-val-order", 10)==0){
         NSString *tmp = [NSString stringWithCString:argv[k+1] encoding:NSASCIIStringEncoding];
         int index = 4;
         for(int i = 0; i < 12;i++){
            if ([tmp isEqualToString:valHName[i]] || [[tmp lowercaseString] isEqualToString:[valHName[i] lowercaseString]]){
               index = i;
               break;
            }
         }
         valordering = valIndex[index];
      }
      else if (strncmp(argv[k],"-default",8)==0)
         defaultAbsSplit = atoi(argv[k+1]);
      else if (strncmp(argv[k],"-l",2)==0)
         level = atoi(argv[k]+2);
      else if (strncmp(argv[k],"-debug-level",12)==0)
         level = atoi(argv[k+1]);
      else if ((strlen(argv[k])==7 && strncmp(argv[k],"-unique",7)==0) || (strlen(argv[k])==2 && strncmp(argv[k],"-u",2)==0))
         uniqueNB=1;
      else if ((strlen(argv[k])==8 && strncmp(argv[k],"-uniques",8)==0))
         uniqueNB=atoi(argv[k+1]);
      else if (strncmp(argv[k],"-3B",3)==0)
         is3Bfiltering=YES;
      else if (strncmp(argv[k],"-subcut",7)==0)
         subcut = atoi(argv[k+1]);
      else if (strncmp(argv[k],"-special-search",15)==0){
         specialSearch = YES;
         uniqueNB=1;
      }
   }
   return self;
}
-(NSString*)heuristicName
{
   if(specialSearch) return @"special";
   return hName[heuristic-4];
}
-(NSString*)valueHeuristicName
{
   if(specialSearch) return @"special";
   return valHName[valordering];
}
-(NSString*)valueDefaultAbsSplitName
{
   return valHName[defaultAbsSplit];
}
-(NSString*)valueSubCutName
{
   if (valordering != split3B)
      return @"none";
   return valHName[subcut];
}
-(SEL) subCutSelector
{
   switch (subcut){
      case split : return @selector(floatStaticSplit:withVars:);
      case split3Way : return @selector(floatStatic3WaySplit:withVars:);
      case split5Way : return @selector(floatStatic5WaySplit:withVars:);
      case split6Way : return @selector(floatStatic6WaySplit:withVars:);
      case dynamicSplit : return @selector(floatSplit:withVars:);
      case dynamic3Split : return @selector(float3WaySplit:withVars:);
      case dynamic5Split : return @selector(float5WaySplit:withVars:);
      case dynamic6Split : return @selector(float6WaySplit:withVars:);
      case split3B : return @selector(float3BSplit:call:withVars:);
      default:
         return @selector(float3BSplit:call:withVars:);
   }
}
-(void)measureTime:(void(^)(void))block
{
   ORLong startWC  = [ORRuntimeMonitor wctime];
   ORLong startCPU = [ORRuntimeMonitor cputime];
   @autoreleasepool {
      @try {
         block();
      }@catch(ORExecutionError* execError) {
         NSLog(@"Execution ERROR: %@",execError);
#if !__has_feature(objc_arc)
         [execError release];
#endif
      }
   }
   ORLong endWC  = [ORRuntimeMonitor wctime];
   ORLong endCPU = [ORRuntimeMonitor cputime];
   printf("FMT:cpu,wcn\n");
   printf("OUT:%lld,%lld\n",endCPU - startCPU,endWC - startWC);
}
-(void)measure:(struct ORResult(^)(void))block
{
   //mallocWatch();
   if (randomized)
      [ORStreamManager setRandomized];
   ORLong startWC  = [ORRuntimeMonitor wctime];
   ORLong startCPU = [ORRuntimeMonitor cputime];
   struct ORResult run;
   @autoreleasepool {
      @try {
         run = block();
      }@catch(ORExecutionError* execError) {
         NSLog(@"Execution ERROR: %@",execError);
#if !__has_feature(objc_arc)
         [execError release];
#endif
         run.found = 0;
         run.nbFailures = run.nbChoices = run.nbPropagations = 0;
         run.nbSRewrites = run.nbDRewrites = 0;
      }
   }
   ORLong endWC  = [ORRuntimeMonitor wctime];
   ORLong endCPU = [ORRuntimeMonitor cputime];
   NSString* str = mallocReport();
   printf("FMT:heur,valHeur,rand,threads,size,found,restartRate,#f,#c,#p,cpu,wc,mUsed,mPeak,kb,kb%%, unique?,#uniquesubcut,split3Bpercent,#SRewrite,#DRewrite,#SMerged,#DMerged,#VAR,#CST\n");
   printf("OUT:%s,%s,%d,%d,%d,%d,%f,%d,%d,%d,%lld,%lld,%s,%s,%f,%s,%d,%s,%f,%d,%d,%d,%d,%d,%d\n",[[self heuristicName] cStringUsingEncoding:NSASCIIStringEncoding],
          [[self valueHeuristicName] cStringUsingEncoding:NSASCIIStringEncoding],
          randomized,
          nbThreads,
          size,
          run.found,
          restartRate,
          run.nbFailures,
          run.nbChoices,
          run.nbPropagations,
          endCPU - startCPU,
          endWC - startWC,
          [str cStringUsingEncoding:NSASCIIStringEncoding],
          (is3Bfiltering)?"3B":"2B",
          (kbpercent != -1)?kbpercent:5.0,
          (uniqueNB>0) ? "YES":"NO",
          uniqueNB,
          [[self valueSubCutName] cStringUsingEncoding:NSASCIIStringEncoding],
          search3Bpercent,
          run.nbSRewrites,
          run.nbDRewrites,
          _nbSMerged,
          _nbDMerged,
          (ORInt)(run.nbVariables),
          (ORInt)(run.nbConstraints));
}
-(void) updateNotes: (id<ORAnnotation>) notes model:(id<ORModel>) model
{
   if(kbpercent != -1)
      [notes kbpercent:kbpercent];
   if(withSRewriting)
      [notes staticRewrite:YES];
   if(withDRewriting)
      [notes dynRewrite:YES];
   [notes setKBEligebleVars:[model variables]];
}
-(id<ORGroup>)makeGroup:(id<ORModel>)model
{
   if(is3Bfiltering){
      return [ORFactory group:model type:Group3B];
   }
   return [ORFactory group:model];
}
-(id<CPProgram>)makeProgram:(id<ORModel>)model
{
   id<ORAnnotation> notes = [ORFactory annotation];
   [self updateNotes:notes model:model];
   return [self makeProgram:model annotation:notes];
}

-(id<CPProgram>) makeProgramWithSimplification:(id<ORModel>)model constraints:(NSArray*) toadd
{
   if([self is3Bfiltering]){
      NSArray* arr = toadd;
      id<ORGroup> g = [ORFactory group:model type:Group3B];
      if([self variationSearch]){
         arr = [ExprSimplifier simplifyAll:toadd group:g];
      }
      for(id<ORExpr> e in arr){
         [g add:e];
      }
      [model add:g];
   }else{
      NSArray* arr = toadd;
      if([self variationSearch]){
         arr = [ExprSimplifier simplifyAll:toadd];
      }
      for(id<ORExpr> e in arr){
         [model add:e];
      }
   }
   return [self makeProgram:model];
}


-(id<CPProgram>)makeProgram:(id<ORModel>)model annotation:(id<ORAnnotation>)notes
{
   id<CPProgram> p = nil;
   ORInt nb = (ORInt)[[model FPVars] count];
   id<ORSearchController> cont = nil;
   if(bds) cont = [ORSemBDSController protoWithDisc:nb times:5];
   switch(nbThreads) {
      case 0:
         if(cont != nil)
            p = [ORFactory createCPSemanticProgram:model annotation:notes with:cont];
         else
            p = [ORFactory createCPProgram:model annotation:notes];
         [(CPCoreSolver*)p setWithRewriting:(withSRewriting || withDRewriting)];
         [(CPCoreSolver*)p setLevel:level];
         [(CPCoreSolver*)p setMiddle:middle];
         [(CPCoreSolver*)p setAbsComputationFunction:absFunComputation];
         if(absRate >= 0) [(CPCoreSolver*)p setAbsRate:absRate];
         if(occRate >= 0) [(CPCoreSolver*)p setOccRate:occRate];
         if(uniqueNB > 0) [(CPCoreSolver*)p setUnique:uniqueNB];
         [(CPCoreSolver*)p setSearchNBFloats:searchNBFloats];
         [(CPCoreSolver*)p set3BSplitPercent:search3Bpercent];
         [(CPCoreSolver*)p setSubcut:[self subCutSelector]];
         [(CPCoreSolver*)p setAbsLimitModelVars:rateModel total:grateModel];
         [(CPCoreSolver*)p setAbsLimitAdditionalVars:rateOther total:grateModel];
         [(CPCoreSolver*)p setVariation:variationSearch];
         return p;
      case 1: return [ORFactory createCPSemanticProgram:model annotation:notes with:[ORSemDFSController proto]];
      default: return [ORFactory createCPParProgram:model nb:nbThreads annotation:notes with:[ORSemDFSController proto]];
   }
}

-(ORBool) checkAllbound:(id<ORModel>) model with:(id<CPProgram>) cp
{
   ORBool res = YES;
   NSArray* vars = [model variables];
   for(id<ORVar> v in vars)
      if(![cp bound:v]){
         res = NO;
         NSLog(@"la variable %@ n'est pas bound : %@",v,[cp concretize:v]);
      }
   return res;
}

-(void) printSolution:(id<ORModel>) model with:(id<CPProgram>) cp
{
   NSArray* vars = [model variables];
   for(id<ORVar> v in vars){
      NSLog(@"%@ : (%s) %@",v,[cp bound:v] ? "YES" : "NO",[cp concretize:v]);
   }
}
-(void) printOccurences:(id<ORModel>) model with:(id<CPProgram>) cp restricted:(id<ORVarArray>) vars
{
   id<ORIntArray> occ = [[cp source] occurences];
   id<ORIntArray> locc = [[cp source] loccurences];
   NSLog(@"------------------");
   NSLog(@"Local and global occurences :");
   for(id<ORVar> v in vars){
      ORInt index = [v getId];
      NSLog(@"%@ : g %@ l %@",v,occ[index],locc[index]);
   }
   ORInt occsum = [occ sum];
   ORInt loccsum = [locc sum];
   NSLog(@"gsum : %d lsum:%d",occsum,loccsum);
   NSLog(@"------------------\n");
}

-(void) printMaxLOccurences:(id<ORModel>) model with:(id<CPProgram>) cp n:(ORInt) n
{
   NSArray* vars = [model variables];
   id<ORIntArray> occ = [[cp source] loccurences];
   NSMutableArray* sortedArray = [[NSMutableArray alloc] initWithCapacity:[occ count]];
   for(id<ORVar> v in vars){
      ORInt index = [v getId];
      [sortedArray addObject:occ[index]];
   }
   [sortedArray sortUsingComparator:^NSComparisonResult(NSNumber* obj1, NSNumber* obj2) {
      return [obj1 intValue] < [obj2 intValue];
   }];
   NSLog(@"------------------");
   NSLog(@"%d max local occurences :",n);
   for(ORInt i = 0; i < [sortedArray count] && i < n; i++)
      NSLog(@"%d MAX_LOCC : %d",i,[sortedArray[i] intValue]);
   NSLog(@"------------------\n");
   [sortedArray release];
}


-(void) printMaxGOccurences:(id<ORModel>) model with:(id<CPProgram>) cp n:(ORInt) n
{
   NSArray* vars = [model variables];
   id<ORIntArray> occ = [[cp source] occurences];
   NSMutableArray* sortedArray = [[NSMutableArray alloc] initWithCapacity:[occ count]];
   for(id<ORVar> v in vars){
      ORInt index = [v getId];
      [sortedArray addObject:occ[index]];
   }
   [sortedArray sortUsingComparator:^NSComparisonResult(NSNumber* obj1, NSNumber* obj2) {
      return [obj1 intValue] < [obj2 intValue];
   }];
   NSLog(@"------------------");
   NSLog(@"%d max global occurences :",n);
   for(ORInt i = 0; i < [sortedArray count] && i < n; i++)
      NSLog(@"%d MAX_OCC : %d",i,[sortedArray[i] intValue]);
   NSLog(@"------------------\n");
   [sortedArray release];
}

-(id<CPHeuristic>)makeHeuristic:(id<CPProgram>)cp restricted:(id<ORIntVarArray>)x
{
   id<CPHeuristic> h = nil;
   switch(heuristic) {
      case FF: h = [cp createFF:x];break;
      case IBS: h = [cp createIBS:x];break;
      case ABS: h = [cp createABS:x];break;
      case WDEG: h = [cp createWDeg:x];break;
      case DDEG: h = [cp createDDeg:x];break;
      case SDEG: h = [cp createSDeg:x];break;
      default:h = [cp createFF:x];break;
   }
   return h;
}
-(id<ORDisabledVarArray>) makeDisabledArray:(id<CPProgram>)p from:(id<ORVarArray>)vs
{
   id<ORDisabledVarArray> vars;
   if(rateOther < 1){
      NSArray* absvar = [p collectAllVarWithAbs:vs withLimit:rateOther];
      vars = [ORFactory disabledFloatVarArray:vs varabs:absvar solver:[p engine] nbFixed:uniqueNB];
      [absvar release];
   }else{
      vars = [ORFactory disabledFloatVarArray:vs engine:[p engine] nbFixed:uniqueNB];
   }
   if(withDRewriting || withSRewriting){
      //computation of max Id of concrete var
      ORInt maxId = 0;
      id<CPVar> cv = nil;
      for(id<ORVar> v in vars){
         cv = [p concretize:v];
         maxId = max(maxId, cv.getId);
      }
      //create InvGamma
      __block id<ORIntArray> invGamma = [ORFactory intArray:[p tracker] range:RANGE([p tracker], 0, maxId) value:-1];
      for(ORInt i = 0; i < [vars count]; i++){
         cv = [p concretize:vars[i]];
         invGamma[cv.getId] = @(i);
      }
      
      [[[p engine] mergedVar] wheneverNotifiedDo:^(id<CPVar> v0,  id<CPVar> v1,ORBool isStatic){
         ORInt idA0 = (v0.getId < [invGamma count]) ? [invGamma[v0.getId] intValue] : -1;
         ORInt idA1 = (v1.getId < [invGamma count]) ? [invGamma[v1.getId] intValue] : -1;
         if (idA0 > -1){
            if(isStatic)
               _nbSMerged++;
            else
               _nbDMerged++;
            if(idA1 > -1)
               [vars unionSet:idA0 and:idA1];
            else
               [vars unionSet:idA0 withConcrete:v1];
         }else if(idA1 > -1){
            if(isStatic)
               _nbSMerged++;
            else
               _nbDMerged++;
            [vars unionSet:idA1 withConcrete:v0];
         }
      }];
   }
   
   return vars;
}
-(void) makeLDSSearch:(id<CPProgram>)p restricted:(id<ORDisabledVarArray>)vars
{
   id<ORMutableInteger> l = [ORFactory mutable:p value:16];
   id<ORMutableInteger> STOP = [ORFactory mutable:p value:NO];
   [p repeat:^{
      [STOP setValue:YES];
      [p limitCondition:^ORBool{
         bool r = ([[p tracer] level] > [l intValue]);
         [STOP setValue:[STOP intValue] && !r];
         LOG(level,2,@"depth %d limit %d %s",[[p tracer] level],[l intValue],([STOP intValue])?"YES":"NO");
         return r;
      } in:^{
         [self launchHeuristicImpl:p restricted:vars];
      }];
   } onRepeat:^{
      [l setValue:([l intValue] * 2)];
      LOG(level,0,@"increase depth %d",[l intValue]);
   } until:^ORBool{
      LOG(level,2,@"STOP = %s",([STOP intValue])?"YES":"NO");
      return [STOP intValue];
   }];
}
-(ORBool) isCycle:(id<ORModel>) model
{
   NSDictionary* dict = [InequalityConstraintsCollector collect:[model constraints]];
   __block int maxId = -1;
   __block int first;
   NSMutableArray* idarr = [[NSMutableArray alloc] init];
   [dict enumerateKeysAndObjectsUsingBlock:^(id  key, NSArray* obj, BOOL* stop) {
      first = [key intValue];
      maxId = max(first,maxId);
      [idarr addObject:key];
      for(ORExprBinaryI* o in obj){
         if([o getId] == -1)
            [model trackMutable:o];
         maxId = max([o getId],maxId);
         maxId = max([[o left] getId],maxId);
         maxId = max([[o right] getId],maxId);
      }
   }];
   id<ORIntArray> visited = [ORFactory intArray:model range:RANGE(model,0,maxId) value:0];
   id<ORIntArray> recStack = [ORFactory intArray:model range:RANGE(model,0,maxId) value:0];
   NSMutableDictionary* exprVisited = [[NSMutableDictionary alloc] init];
   for(id v in idarr){
      if([self isCycleRec:v parent:v graph:dict expr:exprVisited visited:visited recStack:recStack hasStrict:NO depth:1])
         return YES;
   }
   [idarr release];
   [exprVisited release];
   return NO;
}

-(ORBool) isCycleRec:(id) v parent:(id)p graph:(NSDictionary*) graph expr:(NSMutableDictionary*) expr visited:(id<ORIntArray>) visited recStack:(id<ORIntArray>) recStack hasStrict:(ORBool) strict depth:(ORInt) depth
{
   ORInt vi = [v intValue];
   ORInt pi = [p intValue];
   ORExprBinaryI* se;
   if(![visited[vi] intValue]){
      visited[vi] = @(1);
      recStack[vi] = @(depth);
      se = [expr objectForKey:v];
      //     case we are node expression
      if(se != nil){
         ORInt other = [[se right] getId];
         ORInt next = (other == pi) ? [[se left] getId] : other;
         ORBool isStrict = ([se isKindOfClass:ORExprGThenI.class] || [se isKindOfClass:ORExprLThenI.class]);
         if(![visited[next] intValue]){
            if ([self isCycleRec:@(next) parent:@(next) graph:graph expr:expr visited:visited recStack:recStack hasStrict:(strict || isStrict) depth:depth+1])
               return YES;
         }else if([recStack[next] intValue] && [recStack[next] intValue] != depth-1 && (strict || isStrict))
            return YES;
      }else{
         //      case we are var node
         NSArray* idarr = [graph objectForKey:@(vi)];
         ORInt si;
         for(id e in idarr){
            se = e;
            si = [se getId];
            [expr setObject:e forKey:@(si)];
            if(![visited[si] intValue]){
               if([self isCycleRec:@(si) parent:@(vi) graph:graph expr:expr visited:visited recStack:recStack hasStrict:strict depth:depth+1])
                  return YES;
            }else if([recStack[si] intValue] && [recStack[si] intValue] != depth-1  && strict)
               return YES;
         }
      }
   }
   recStack[vi] = @(0);
   return NO;
}







-(void)launchHeuristic:(id<CPProgram>)p restricted:(id<ORDisabledVarArray>)vars
{
   if(ldfs){
      [self makeLDSSearch:p restricted:vars];
   }else{
      [p limitCondition:^ORBool{
         return (choicesLimit >= 0) ? [p nbChoices] == choicesLimit : false;
      } in:^{
         [self launchHeuristicImpl:p restricted:vars];
      }];
   }
}

-(void)launchHeuristicImpl:(id<CPProgram>)p restricted:(id<ORDisabledVarArray>)vars
{
switch (heuristic) {
case maxWidth :
   switch (valordering) {
      case splitAbs:
      case split:
         [p maxWidthSearch:vars do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p floatStaticSplit:i withVars:x];
         }];
         break;
      case split3Way:
         [p maxWidthSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p floatStatic3WaySplit:i withVars:x];
         }];
         break;
      case split5Way:
         [p maxWidthSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p floatStatic5WaySplit:i  withVars:x];
         }];
         break;
      case split6Way:
         [p maxWidthSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p floatStatic6WaySplit:i  withVars:x];
         }];
         break;
      case dynamicSplit:
         [p maxWidthSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p floatSplit:i  withVars:x];
         }];
         break;
      case dynamic3Split:
         [p maxWidthSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p float3WaySplit:i  withVars:x];
         }];
         break;
      case dynamic5Split:
         [p maxWidthSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p float5WaySplit:i  withVars:x];
         }];
         break;
      case dynamic6Split:
         [p maxWidthSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p float6WaySplit:i  withVars:x];
         }];
         break;
      case split3B:
         [p maxWidthSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p float3BSplit:i  call:@selector(maxWidthSearch:do:)  withVars:x];
         }];
         break;
      case Esplit:
         [p maxWidthSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p floatEWaySplit:i  withVars:x];
         }];
         break;
      case Dsplit:
         [p maxWidthSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p floatDeltaSplit:i  withVars:x];
         }];
         break;
   }
   break;
case minWidth :
   switch (valordering) {
      case splitAbs:
      case split:
         [p minWidthSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p floatStaticSplit:i  withVars:x];
         }];
         break;
      case split3Way:
         [p minWidthSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p floatStatic3WaySplit:i  withVars:x];
         }];
         break;
      case split5Way:
         [p minWidthSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p floatStatic5WaySplit:i  withVars:x];
         }];
         break;
      case split6Way:
         [p minWidthSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p floatStatic6WaySplit:i  withVars:x];
         }];
         break;
      case dynamicSplit:
         [p minWidthSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p floatSplit:i  withVars:x];
         }];
         break;
      case dynamic3Split:
         [p minWidthSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p float3WaySplit:i  withVars:x];
         }];
         break;
      case dynamic5Split:
         [p minWidthSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p float5WaySplit:i  withVars:x];
         }];
         break;
      case dynamic6Split:
         [p minWidthSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p float6WaySplit:i  withVars:x];
         }];
         break;
      case split3B:
         [p minWidthSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p float3BSplit:i call:@selector(minWidthSearch:do:)   withVars:x];
         }];
         break;
      case Esplit:
         [p minWidthSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p floatEWaySplit:i  withVars:x];
         }];
         break;
      case Dsplit:
         [p minWidthSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p floatDeltaSplit:i  withVars:x];
         }];
         break;
   }
   break;
case maxCard :
   switch (valordering) {
      case splitAbs:
      case split:
         [p maxCardinalitySearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p floatStaticSplit:i  withVars:x];
         }];
         break;
      case split3Way:
         [p maxCardinalitySearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p floatStatic3WaySplit:i  withVars:x];
         }];
         break;
      case split5Way:
         [p maxCardinalitySearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p floatStatic5WaySplit:i  withVars:x];
         }];
         break;
      case split6Way:
         [p maxCardinalitySearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p floatStatic6WaySplit:i  withVars:x];
         }];
         break;
      case dynamicSplit:
         [p maxCardinalitySearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p floatSplit:i  withVars:x];
         }];
         break;
      case dynamic3Split:
         [p maxCardinalitySearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p float3WaySplit:i  withVars:x];
         }];
         break;
      case dynamic5Split:
         [p maxCardinalitySearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p float5WaySplit:i  withVars:x];
         }];
         break;
      case dynamic6Split:
         [p maxCardinalitySearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p float6WaySplit:i  withVars:x];
         }];
         break;
      case split3B:
         [p maxCardinalitySearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p float3BSplit:i  call:@selector(maxCardinalitySearch:do:)  withVars:x];
         }];
         break;
      case Esplit:
         [p maxCardinalitySearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p floatEWaySplit:i  withVars:x];
         }];
         break;
      case Dsplit:
         [p maxCardinalitySearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p floatDeltaSplit:i  withVars:x];
         }];
         break;
   }
   break;
case minCard :
   switch (valordering) {
      case splitAbs:
      case split:
         [p minCardinalitySearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p floatStaticSplit:i  withVars:x];
         }];
         break;
      case split3Way:
         [p minCardinalitySearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p floatStatic3WaySplit:i  withVars:x];
         }];
         break;
      case split5Way:
         [p minCardinalitySearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p floatStatic5WaySplit:i  withVars:x];
         }];
         break;
      case split6Way:
         [p minCardinalitySearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p floatStatic6WaySplit:i  withVars:x];
         }];
         break;
      case dynamicSplit:
         [p minCardinalitySearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p floatSplit:i  withVars:x];
         }];
         break;
      case dynamic3Split:
         [p minCardinalitySearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p float3WaySplit:i  withVars:x];
         }];
         break;
      case dynamic5Split:
         [p minCardinalitySearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p float5WaySplit:i  withVars:x];
         }];
         break;
      case dynamic6Split:
         [p minCardinalitySearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p float6WaySplit:i  withVars:x];
         }];
         break;
      case split3B:
         [p minCardinalitySearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p float3BSplit:i  call:@selector(minCardinalitySearch:do:) withVars:x];
         }];
         break;
      case Esplit:
         [p minCardinalitySearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p floatEWaySplit:i  withVars:x];
         }];
         break;
      case Dsplit:
         [p minCardinalitySearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p floatDeltaSplit:i  withVars:x];
         }];
         break;
   }
   break;
case maxDens :
   switch (valordering) {
      case splitAbs:
      case split:
         [p maxDensitySearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p floatStaticSplit:i  withVars:x];
         }];
         break;
      case split3Way:
         [p maxDensitySearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p floatStatic3WaySplit:i  withVars:x];
         }];
         break;
      case split5Way:
         [p maxDensitySearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p floatStatic5WaySplit:i  withVars:x];
         }];
         break;
      case split6Way:
         [p maxDensitySearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p floatStatic6WaySplit:i  withVars:x];
         }];
         break;
      case dynamicSplit:
         [p maxDensitySearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p floatSplit:i  withVars:x];
         }];
         break;
      case dynamic3Split:
         [p maxDensitySearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p float3WaySplit:i  withVars:x];
         }];
         break;
      case dynamic5Split:
         [p maxDensitySearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p float5WaySplit:i  withVars:x];
         }];
         break;
      case dynamic6Split:
         [p maxDensitySearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p float6WaySplit:i  withVars:x];
         }];
         break;
      case split3B:
         [p maxDensitySearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p float3BSplit:i call:@selector(maxDensitySearch:do:) withVars:x];
         }];
         break;
      case Esplit:
         [p maxDensitySearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p floatEWaySplit:i  withVars:x];
         }];
         break;
      case Dsplit:
         [p maxDensitySearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p floatDeltaSplit:i  withVars:x];
         }];
         break;
   }
   break;
case minDens :
   switch (valordering) {
      case splitAbs:
      case split:
         [p minDensitySearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p floatStaticSplit:i  withVars:x];
         }];
         break;
      case split3Way:
         [p minDensitySearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p floatStatic3WaySplit:i  withVars:x];
         }];
         break;
      case split5Way:
         [p minDensitySearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p floatStatic5WaySplit:i  withVars:x];
         }];
         break;
      case split6Way:
         [p minDensitySearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p floatStatic6WaySplit:i  withVars:x];
         }];
         break;
      case dynamicSplit:
         [p minDensitySearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p floatSplit:i  withVars:x];
         }];
         break;
      case dynamic3Split:
         [p minDensitySearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p float3WaySplit:i  withVars:x];
         }];
         break;
      case dynamic5Split:
         [p minDensitySearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p float5WaySplit:i  withVars:x];
         }];
         break;
      case dynamic6Split:
         [p minDensitySearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p float6WaySplit:i  withVars:x];
         }];
         break;
      case split3B:
         [p minDensitySearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p float3BSplit:i  call:@selector(minDensitySearch:do:) withVars:x];
         }];
         break;
      case Esplit:
         [p minDensitySearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p floatEWaySplit:i  withVars:x];
         }];
         break;
      case Dsplit:
         [p minDensitySearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p floatDeltaSplit:i  withVars:x];
         }];
         break;
   }
   break;
case maxMagn :
   switch (valordering) {
      case splitAbs:
      case split:
         [p maxMagnitudeSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p floatStaticSplit:i  withVars:x];
         }];
         break;
      case split3Way:
         [p maxMagnitudeSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p floatStatic3WaySplit:i  withVars:x];
         }];
         break;
      case split5Way:
         [p maxMagnitudeSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p floatStatic5WaySplit:i  withVars:x];
         }];
         break;
      case split6Way:
         [p maxMagnitudeSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p floatStatic6WaySplit:i  withVars:x];
         }];
         break;
      case dynamicSplit:
         [p maxMagnitudeSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p floatSplit:i  withVars:x];
         }];
         break;
      case dynamic3Split:
         [p maxMagnitudeSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p float3WaySplit:i  withVars:x];
         }];
         break;
      case dynamic5Split:
         [p maxMagnitudeSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p float5WaySplit:i  withVars:x];
         }];
         break;
      case dynamic6Split:
         [p maxMagnitudeSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p float6WaySplit:i  withVars:x];
         }];
         break;
      case split3B:
         [p maxMagnitudeSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p float3BSplit:i  call:@selector(maxMagnitudeSearch:do:) withVars:x];
         }];
         break;
      case Esplit:
         [p maxMagnitudeSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p floatEWaySplit:i  withVars:x];
         }];
         break;
      case Dsplit:
         [p maxMagnitudeSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p floatDeltaSplit:i  withVars:x];
         }];
         break;
   }
   break;
case minMagn :
   switch (valordering) {
      case splitAbs:
      case split:
         [p minMagnitudeSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p floatStaticSplit:i  withVars:x];
         }];
         break;
      case split3Way:
         [p minMagnitudeSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p floatStatic3WaySplit:i  withVars:x];
         }];
         break;
      case split5Way:
         [p minMagnitudeSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p floatStatic5WaySplit:i  withVars:x];
         }];
         break;
      case split6Way:
         [p minMagnitudeSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p floatStatic6WaySplit:i  withVars:x];
         }];
         break;
      case dynamicSplit:
         [p minMagnitudeSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p floatSplit:i  withVars:x];
         }];
         break;
      case dynamic3Split:
         [p minMagnitudeSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p float3WaySplit:i  withVars:x];
         }];
         break;
      case dynamic5Split:
         [p minMagnitudeSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p float5WaySplit:i  withVars:x];
         }];
         break;
      case dynamic6Split:
         [p minMagnitudeSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p float6WaySplit:i  withVars:x];
         }];
         break;
      case split3B:
         [p minMagnitudeSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p float3BSplit:i   call:@selector(minMagnitudeSearch:do:) withVars:x];
         }];
         break;
      case Esplit:
         [p minMagnitudeSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p floatEWaySplit:i  withVars:x];
         }];
         break;
      case Dsplit:
         [p minMagnitudeSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p floatDeltaSplit:i  withVars:x];
         }];
         break;
   }
   break;
case maxDegree :
   switch (valordering) {
      case splitAbs:
      case split:
         [p maxDegreeSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p floatStaticSplit:i  withVars:x];
         }];
         break;
      case split3Way:
         [p maxDegreeSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p floatStatic3WaySplit:i  withVars:x];
         }];
         break;
      case split5Way:
         [p maxDegreeSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p floatStatic5WaySplit:i  withVars:x];
         }];
         break;
      case split6Way:
         [p maxDegreeSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p floatStatic6WaySplit:i  withVars:x];
         }];
         break;
      case dynamicSplit:
         [p maxDegreeSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p floatSplit:i  withVars:x];
         }];
         break;
      case dynamic3Split:
         [p maxDegreeSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p float3WaySplit:i  withVars:x];
         }];
         break;
      case dynamic5Split:
         [p maxDegreeSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p float5WaySplit:i  withVars:x];
         }];
         break;
      case dynamic6Split:
         [p maxDegreeSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p float6WaySplit:i  withVars:x];
         }];
         break;
      case split3B:
         [p maxDegreeSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p float3BSplit:i   call:@selector(maxDegreeSearch:do:) withVars:x];
         }];
         break;
      case Esplit:
         [p maxDegreeSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p floatEWaySplit:i  withVars:x];
         }];
         break;
      case Dsplit:
         [p maxDegreeSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p floatDeltaSplit:i  withVars:x];
         }];
         break;
   }
   break;
case minDegree :
   switch (valordering) {
      case splitAbs:
      case split:
         [p minDegreeSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p floatStaticSplit:i  withVars:x];
         }];
         break;
      case split3Way:
         [p minDegreeSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p floatStatic3WaySplit:i  withVars:x];
         }];
         break;
      case split5Way:
         [p minDegreeSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p floatStatic5WaySplit:i  withVars:x];
         }];
         break;
      case split6Way:
         [p minDegreeSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p floatStatic6WaySplit:i  withVars:x];
         }];
         break;
      case dynamicSplit:
         [p minDegreeSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p floatSplit:i  withVars:x];
         }];
         break;
      case dynamic3Split:
         [p minDegreeSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p float3WaySplit:i  withVars:x];
         }];
         break;
      case dynamic5Split:
         [p minDegreeSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p float5WaySplit:i  withVars:x];
         }];
         break;
      case dynamic6Split:
         [p minDegreeSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p float6WaySplit:i  withVars:x];
         }];
         break;
      case split3B:
         [p minDegreeSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p float3BSplit:i  call:@selector(minDegreeSearch:do:) withVars:x];
         }];
         break;
      case Esplit:
         [p minDegreeSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p floatEWaySplit:i  withVars:x];
         }];
         break;
      case Dsplit:
         [p minDegreeSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p floatDeltaSplit:i  withVars:x];
         }];
         break;
   }
   break;
case maxOcc :
   switch (valordering) {
      case splitAbs:
      case split:
         [p maxOccurencesSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p floatStaticSplit:i  withVars:x];
         }];
         break;
      case split3Way:
         [p maxOccurencesSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p floatStatic3WaySplit:i  withVars:x];
         }];
         break;
      case split5Way:
         [p maxOccurencesSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p floatStatic5WaySplit:i  withVars:x];
         }];
         break;
      case split6Way:
         [p maxOccurencesSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p floatStatic6WaySplit:i  withVars:x];
         }];
         break;
      case dynamicSplit:
         [p maxOccurencesSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p floatSplit:i  withVars:x];
         }];
         break;
      case dynamic3Split:
         [p maxOccurencesSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p float3WaySplit:i  withVars:x];
         }];
         break;
      case dynamic5Split:
         [p maxOccurencesRatesSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p float5WaySplit:i  withVars:x];
         }];
         break;
      case dynamic6Split:
         [p maxOccurencesRatesSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p float6WaySplit:i  withVars:x];
         }];
         break;
      case split3B:
         [p maxOccurencesSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p float3BSplit:i  call:@selector(maxOccurencesSearch:do:) withVars:x];
         }];
         break;
      case Esplit:
         [p maxOccurencesSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p floatEWaySplit:i  withVars:x];
         }];
         break;
      case Dsplit:
         [p maxOccurencesSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p floatDeltaSplit:i  withVars:x];
         }];
         break;
   }
   break;
   case maxLOcc :
      switch (valordering) {
         case splitAbs:
         case split:
            [p maxLOccurencesSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
               [p floatStaticSplit:i  withVars:x];
            }];
            break;
         case split3Way:
            [p maxLOccurencesSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
               [p floatStatic3WaySplit:i  withVars:x];
            }];
            break;
         case split5Way:
            [p maxLOccurencesSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
               [p floatStatic5WaySplit:i  withVars:x];
            }];
            break;
         case split6Way:
            [p maxLOccurencesSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
               [p floatStatic6WaySplit:i  withVars:x];
            }];
            break;
         case dynamicSplit:
            [p maxLOccurencesSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
               [p floatSplit:i  withVars:x];
            }];
            break;
         case dynamic3Split:
            [p maxLOccurencesSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
               [p float3WaySplit:i  withVars:x];
            }];
            break;
         case dynamic5Split:
            [p maxLOccurencesSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
               [p float5WaySplit:i  withVars:x];
            }];
            break;
         case dynamic6Split:
            [p maxLOccurencesSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
               [p float6WaySplit:i  withVars:x];
            }];
            break;
         case split3B:
            [p maxLOccurencesSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
               [p float3BSplit:i  call:@selector(maxOccurencesSearch:do:) withVars:x];
            }];
            break;
         case Esplit:
            [p maxLOccurencesSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
               [p floatEWaySplit:i  withVars:x];
            }];
            break;
         case Dsplit:
            [p maxLOccurencesSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
               [p floatDeltaSplit:i  withVars:x];
            }];
            break;
      }
      break;
   case occdens :
      switch (valordering) {
         case splitAbs:
         case split:
            [p maxOccDensSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
               [p floatStaticSplit:i  withVars:x];
            }];
            break;
         case split3Way:
            [p maxOccDensSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
               [p floatStatic3WaySplit:i  withVars:x];
            }];
            break;
         case split5Way:
            [p maxOccDensSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
               [p floatStatic5WaySplit:i  withVars:x];
            }];
            break;
         case split6Way:
            [p maxOccDensSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
               [p floatStatic6WaySplit:i  withVars:x];
            }];
            break;
         case dynamicSplit:
            [p maxOccDensSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
               [p floatSplit:i  withVars:x];
            }];
            break;
         case dynamic3Split:
            [p maxOccDensSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
               [p float3WaySplit:i  withVars:x];
            }];
            break;
         case dynamic5Split:
            [p maxOccDensSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
               [p float5WaySplit:i  withVars:x];
            }];
            break;
         case dynamic6Split:
            [p maxOccDensSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
               [p float6WaySplit:i  withVars:x];
            }];
            break;
         case split3B:
            [p maxOccDensSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
               [p float3BSplit:i  call:@selector(maxOccurencesSearch:do:) withVars:x];
            }];
            break;
         case Esplit:
            [p maxOccDensSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
               [p floatEWaySplit:i  withVars:x];
            }];
            break;
         case Dsplit:
            [p maxOccDensSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
               [p floatDeltaSplit:i  withVars:x];
            }];
            break;
      }
      break;
   case occTBdens :
      switch (valordering) {
         case splitAbs:
         case split:
            [p maxOccTBDensSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
               [p floatStaticSplit:i  withVars:x];
            }];
            break;
         case split3Way:
            [p maxOccTBDensSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
               [p floatStatic3WaySplit:i  withVars:x];
            }];
            break;
         case split5Way:
            [p maxOccTBDensSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
               [p floatStatic5WaySplit:i  withVars:x];
            }];
            break;
         case split6Way:
            [p maxOccTBDensSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
               [p floatStatic6WaySplit:i  withVars:x];
            }];
            break;
         case dynamicSplit:
            [p maxOccTBDensSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
               [p floatSplit:i  withVars:x];
            }];
            break;
         case dynamic3Split:
            [p maxOccTBDensSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
               [p float3WaySplit:i  withVars:x];
            }];
            break;
         case dynamic5Split:
            [p maxOccTBDensSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
               [p float5WaySplit:i  withVars:x];
            }];
            break;
         case dynamic6Split:
            [p maxOccTBDensSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
               [p float6WaySplit:i  withVars:x];
            }];
            break;
         case split3B:
            [p maxOccTBDensSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
               [p float3BSplit:i  call:@selector(maxOccurencesSearch:do:) withVars:x];
            }];
            break;
         case Esplit:
            [p maxOccTBDensSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
               [p floatEWaySplit:i  withVars:x];
            }];
            break;
         case Dsplit:
            [p maxOccTBDensSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
               [p floatDeltaSplit:i  withVars:x];
            }];
            break;
      }
      break;
case minOcc :
   switch (valordering) {
      case splitAbs:
      case split:
         [p minOccurencesSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p floatStaticSplit:i  withVars:x];
         }];
         break;
      case split3Way:
         [p minOccurencesSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p floatStatic3WaySplit:i  withVars:x];
         }];
         break;
      case split5Way:
         [p minOccurencesSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p floatStatic5WaySplit:i  withVars:x];
         }];
         break;
      case split6Way:
         [p minOccurencesSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p floatStatic6WaySplit:i  withVars:x];
         }];
         break;
      case dynamicSplit:
         [p minOccurencesSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p floatSplit:i  withVars:x];
         }];
         break;
      case dynamic3Split:
         [p minOccurencesSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p float3WaySplit:i  withVars:x];
         }];
         break;
      case dynamic5Split:
         [p minOccurencesSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p float5WaySplit:i  withVars:x];
         }];
         break;
      case dynamic6Split:
         [p minOccurencesSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p float6WaySplit:i  withVars:x];
         }];
         break;
      case split3B:
         [p minOccurencesSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p float3BSplit:i  call:@selector(minOccurencesSearch:do:) withVars:x];
         }];
         break;
      case Esplit:
         [p minOccurencesSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p floatEWaySplit:i  withVars:x];
         }];
         break;
      case Dsplit:
         [p minOccurencesSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p floatDeltaSplit:i  withVars:x];
         }];
         break;
   }
   break;
case maxAbs :
   switch (valordering) {
      case split:
         [p maxAbsorptionSearch:vars do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p floatStaticSplit:i  withVars:x];
         }];
         break;
      case split3Way:
         [p maxAbsorptionSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p floatStatic3WaySplit:i  withVars:x];
         }];
         break;
      case split5Way:
         [p maxAbsorptionSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p floatStatic5WaySplit:i  withVars:x];
         }];
         break;
      case split6Way:
         [p maxAbsorptionSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p floatStatic6WaySplit:i  withVars:x];
         }];
         break;
      case dynamicSplit:
         [p maxAbsorptionSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p floatSplit:i  withVars:x];
         }];
         break;
      case dynamic3Split:
         [p maxAbsorptionSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p float3WaySplit:i  withVars:x];
         }];
         break;
      case dynamic5Split:
         [p maxAbsorptionSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p float5WaySplit:i  withVars:x];
         }];
         break;
      case dynamic6Split:
         [p maxAbsorptionSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p float6WaySplit:i  withVars:x];
         }];
         break;
      case split3B:
         [p maxAbsorptionSearch:vars do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p float3BSplit:i call:@selector(maxAbsorptionSearch:do:)  withVars:x];
         }];
         break;
      case Esplit:
         [p maxAbsorptionSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p floatEWaySplit:i  withVars:x];
         }];
         break;
      case Dsplit:
         [p maxAbsorptionSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p floatDeltaSplit:i  withVars:x];
         }];
         break;
      case splitAbs:
         [p maxFullAbsorptionSearch:vars];
      default:
         [p maxAbsorptionSearch:vars do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p floatEWaySplit:i  withVars:x];
         }];
         break;
   }
   break;
   
case minAbs :
   switch (valordering) {
      case split:
         [p minAbsorptionSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p floatStaticSplit:i  withVars:x];
         }];
         break;
      case split3Way:
         [p minAbsorptionSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p floatStatic3WaySplit:i  withVars:x];
         }];
         break;
      case split5Way:
         [p minAbsorptionSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p floatStatic5WaySplit:i  withVars:x];
         }];
         break;
      case split6Way:
         [p minAbsorptionSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p floatStatic6WaySplit:i  withVars:x];
         }];
         break;
      case dynamicSplit:
         [p minAbsorptionSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p floatSplit:i  withVars:x];
         }];
         break;
      case dynamic3Split:
         [p minAbsorptionSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p float3WaySplit:i  withVars:x];
         }];
         break;
      case dynamic5Split:
         [p minAbsorptionSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p float5WaySplit:i  withVars:x];
         }];
         break;
      case dynamic6Split:
         [p minAbsorptionSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p float6WaySplit:i  withVars:x];
         }];
         break;
      case split3B:
         [p minAbsorptionSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p float3BSplit:i call:@selector(minAbsorptionSearch:do:) withVars:x];
         }];
         break;
      case Esplit:
         [p minAbsorptionSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p floatEWaySplit:i  withVars:x];
         }];
         break;
      case Dsplit:
      default:
         [p minAbsorptionSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p floatDeltaSplit:i  withVars:x];
         }];
         break;
         
   }
   break;
case absWDens :
   switch (valordering) {
      case splitAbs:
      case split:
         [p combinedAbsWithDensSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p floatStaticSplit:i  withVars:x];
         }];
         break;
      case split3Way:
         [p combinedAbsWithDensSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p floatStatic3WaySplit:i  withVars:x];
         }];
         break;
      case split5Way:
         [p combinedAbsWithDensSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p floatStatic5WaySplit:i  withVars:x];
         }];
         break;
      case split6Way:
         [p combinedAbsWithDensSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p floatStatic6WaySplit:i  withVars:x];
         }];
         break;
      case dynamicSplit:
         [p combinedAbsWithDensSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p floatSplit:i  withVars:x];
         }];
         break;
      case dynamic3Split:
         [p combinedAbsWithDensSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p float3WaySplit:i  withVars:x];
         }];
         break;
      case dynamic5Split:
         [p combinedAbsWithDensSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p float5WaySplit:i  withVars:x];
         }];
         break;
      case dynamic6Split:
         [p combinedAbsWithDensSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p float6WaySplit:i  withVars:x];
         }];
         break;
      case split3B:
         [p combinedAbsWithDensSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p float3BSplit:i  call:@selector(combinedAbsWithDensSearch:do:)  withVars:x];
         }];
         break;
      case Esplit:
         [p combinedAbsWithDensSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p floatEWaySplit:i  withVars:x];
         }];
         break;
      case Dsplit:
         [p combinedAbsWithDensSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p floatDeltaSplit:i  withVars:x];
         }];
         break;
   }
   break;
case densWAbs :
   switch (valordering) {
      case splitAbs:
      case split:
         [p combinedDensWithAbsSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p floatStaticSplit:i  withVars:x];
         }];
         break;
      case split3Way:
         [p combinedDensWithAbsSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p floatStatic3WaySplit:i  withVars:x];
         }];
         break;
      case split5Way:
         [p combinedDensWithAbsSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p floatStatic5WaySplit:i  withVars:x];
         }];
         break;
      case split6Way:
         [p combinedDensWithAbsSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p floatStatic6WaySplit:i  withVars:x];
         }];
         break;
      case dynamicSplit:
         [p combinedDensWithAbsSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p floatSplit:i  withVars:x];
         }];
         break;
      case dynamic3Split:
         [p combinedDensWithAbsSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p float3WaySplit:i  withVars:x];
         }];
         break;
      case dynamic5Split:
         [p combinedDensWithAbsSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p float5WaySplit:i  withVars:x];
         }];
         break;
      case dynamic6Split:
         [p combinedDensWithAbsSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p float6WaySplit:i  withVars:x];
         }];
         break;
      case split3B:
         [p combinedDensWithAbsSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p float3BSplit:i  call:@selector(combinedDensWithAbsSearch:do:) withVars:x];
         }];
         break;
      case Esplit:
         [p combinedDensWithAbsSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p floatEWaySplit:i  withVars:x];
         }];
         break;
      case Dsplit:
         [p combinedDensWithAbsSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p floatDeltaSplit:i  withVars:x];
         }];
         break;
   }
   break;
   
case absDens :
case custom :
      [vars setMaxFixed:(ORInt)[vars count] engine:[p engine]];
   [p customSearch:vars];
   break;
case customD :
   [vars setMaxFixed:uniqueNB  engine:[p engine]];
   [p customSearchD:vars];
   break;
case customWD :
   [vars setMaxFixed:uniqueNB  engine:[p engine]];
   [p customSearchWeightedD:vars];
   break;
      
default :
   heuristic = lexico;
   switch (valordering) {
      case splitAbs:
      case split:
         [p lexicalOrderedSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p floatStaticSplit:i  withVars:x];
         }];
         break;
      case split3Way:
         [p lexicalOrderedSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p floatStatic3WaySplit:i  withVars:x];
         }];
         break;
      case split5Way:
         [p lexicalOrderedSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p floatStatic5WaySplit:i  withVars:x];
         }];
         break;
      case split6Way:
         [p lexicalOrderedSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p floatStatic6WaySplit:i  withVars:x];
         }];
         break;
      case dynamicSplit:
         heuristic = ref;
         [p lexicalOrderedSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p floatSplit:i  withVars:x];
         }];
         break;
      case dynamic3Split:
         [p lexicalOrderedSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p float3WaySplit:i  withVars:x];
         }];
         break;
      case dynamic5Split:
         [p lexicalOrderedSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p float5WaySplit:i  withVars:x];
         }];
         break;
      case dynamic6Split:
         [p lexicalOrderedSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p float6WaySplit:i  withVars:x];
         }];
         break;
      case split3B:
         [p lexicalOrderedSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p float3BSplit:i call:@selector(lexicalOrderedSearch:do:) withVars:x];
         }];
         break;
      case Esplit:
         [p lexicalOrderedSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p floatEWaySplit:i  withVars:x];
         }];
         break;
      case Dsplit:
         [p lexicalOrderedSearch:vars  do:^(ORUInt i, id<ORDisabledVarArray> x) {
            [p floatDeltaSplit:i  withVars:x];
         }];
         break;
         
   }
   break;
}
}

@end

