/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "ORCmdLineArgs.h"


@implementation ORCmdLineArgs {
   int           _argc;
   const char**  _argv;
}
static NSString* hName[] = {@"FF",@"ABS",@"IBS",@"WDeg",@"DDeg",@"SDeg",//intSearch
   @"maxWidth",@"minWidth",@"maxCard",@"minCard",@"maxDens",@"minDens",@"minMagn",@"maxMagn",
   @"maxDegree",@"minDegree",@"maxOcc",@"minOcc",@"maxAbs",@"minAbs",@"maxCan",
   @"minCan",@"absWDens", @"densWAbs", @"ref",@"lexico",@"absDens",@"custom",@"customD",@"customWD",@"maxLOCC"};

static enum Heuristic hIndex[] = {FF, ABS, IBS, WDEG, DDEG, SDEG,
   maxWidth, minWidth, maxCard,  minCard,   maxDens,   minDens,   minMagn,   maxMagn,
   maxDegree, minDegree, maxOcc, minOcc, maxAbs, minAbs, maxCan, minCan, absWDens,
   densWAbs , ref ,lexico,absDens,custom,customD,customWD,maxLOcc};

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
   ldfs = NO;
   uniqueNB = 2;
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
         for(int i = 0; i < 31;i++){
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
      }
   }
   ORLong endWC  = [ORRuntimeMonitor wctime];
   ORLong endCPU = [ORRuntimeMonitor cputime];
   NSString* str = mallocReport();
   printf("FMT:heur,valHeur,rand,threads,size,found,restartRate,#f,#c,#p,cpu,wc,mUsed,mPeak,kb,kb%%, unique?,#uniquesubcut,split3Bpercent\n");
   printf("OUT:%s,%s,%d,%d,%d,%d,%f,%d,%d,%d,%lld,%lld,%s,%s,%f,%s,%d,%s,%f\n",[[self heuristicName] cStringUsingEncoding:NSASCIIStringEncoding],
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
          search3Bpercent);
}
-(void) updateNotes: (id<ORAnnotation>) notes model:(id<ORModel>) model
{
   if(kbpercent != -1)
      [notes kbpercent:kbpercent];
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
-(id<CPProgram>)makeProgram:(id<ORModel>)model annotation:(id<ORAnnotation>)notes
{
   id<CPProgram> p = nil;
   ORInt nb = (ORInt)[[model FPVars] count];
   id<ORSearchController> cont = nil;
   if(bds) cont = [ORSemBDSController protoWithDisc:nb times:5];
//   if(ldfs) cont = [ORDFSController proto];
   switch(nbThreads) {
      case 0:
         if(cont != nil)
            p = [ORFactory createCPSemanticProgram:model annotation:notes with:cont];
         else
            p = [ORFactory createCPProgram:model annotation:notes];
         [(CPCoreSolver*)p setLevel:level];
         [(CPCoreSolver*)p setAbsComputationFunction:absFunComputation];
         if(absRate >= 0) [(CPCoreSolver*)p setAbsRate:absRate];
         if(occRate >= 0) [(CPCoreSolver*)p setOccRate:occRate];
         [(CPCoreSolver*)p setUnique:uniqueNB];
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
-(void)launchHeuristic:(id<CPProgram>)p restricted:(id<ORVarArray>)vs
{
   id<ORDisabledVarArray> vars;
   if(rateOther < 1){
      NSArray* absvar = [p collectAllVarWithAbs:vs withLimit:rateOther];
      vars = [ORFactory disabledFloatVarArray:vs varabs:absvar solver:[p engine] nbFixed:uniqueNB];
      [absvar release];
   }else{
      vars = [ORFactory disabledFloatVarArray:vs engine:[p engine] nbFixed:uniqueNB];
   }
   if(ldfs){
//      ORInt v = (ORInt)[vars count];
//      NSLog(@"initial depth %d",v);
      
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
         switch(defaultAbsSplit){
            case split:
               [p maxAbsorptionSearch:vars default:^(ORUInt i, id<ORDisabledVarArray> x) {
                  [p floatStaticSplit:i  withVars:x];
               }];
               break;
            case split3Way:
               [p maxAbsorptionSearch:vars default:^(ORUInt i, id<ORDisabledVarArray> x) {
                  [p floatStatic3WaySplit:i  withVars:x];
               }];
               break;
            case split5Way:
               [p maxAbsorptionSearch:vars default:^(ORUInt i, id<ORDisabledVarArray> x) {
                  [p floatStatic5WaySplit:i  withVars:x];
               }];
               break;
            case split6Way:
               [p maxAbsorptionSearch:vars default:^(ORUInt i, id<ORDisabledVarArray> x) {
                  [p floatStatic6WaySplit:i  withVars:x];
               }];
               break;
            case dynamicSplit:
               [p maxAbsorptionSearch:vars default:^(ORUInt i, id<ORDisabledVarArray> x) {
                  [p floatSplit:i  withVars:x];
               }];
               break;
            case dynamic3Split:
               [p maxAbsorptionSearch:vars default:^(ORUInt i, id<ORDisabledVarArray> x) {
                  [p float3WaySplit:i  withVars:x];
               }];
               break;
            case dynamic5Split:
               [p maxAbsorptionSearchAll:vars default:^(ORUInt i, id<ORDisabledVarArray> x) {
                  [p float5WaySplit:i  withVars:x];
               }];break;
            case dynamic6Split:
               [p maxAbsorptionSearchAll:vars default:^(ORUInt i, id<ORDisabledVarArray> x) {
                  [p float6WaySplit:i  withVars:x];
               }];
            case split3B:
               [p maxAbsorptionSearch:vars default:^(ORUInt i, id<ORDisabledVarArray> x) {
                  [p float3BSplit:i call:@selector(maxAbsorptionSearch:default:) withVars:x];
               }];
               break;
            case Esplit:
               [p maxAbsorptionSearch:vars  default:^(ORUInt i, id<ORDisabledVarArray> x) {
                  [p floatEWaySplit:i  withVars:x];
               }];
               break;
            case Dsplit:
               [p maxAbsorptionSearch:vars  default:^(ORUInt i, id<ORDisabledVarArray> x) {
                  [p floatDeltaSplit:i  withVars:x];
               }];
               break;
            default:
               [p maxAbsorptionSearch:vars default:^(ORUInt i, id<ORDisabledVarArray> x) {
                  [p float6WaySplit:i  withVars:x];
               }];
         }
         break;
         
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
   [p maxAbsDensSearch:vars default:^(ORUInt i, id<ORDisabledVarArray> x) {
      [p float6WaySplit:i  withVars:x];
   }];
   break;
case custom :
   [vars setMaxFixed:(ORInt)[vars count]];
   [p customSearch:vars];
   break;
case customD :
   [vars setMaxFixed:uniqueNB];
   [p customSearchD:vars];
   break;
case customWD :
   [vars setMaxFixed:uniqueNB];
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

