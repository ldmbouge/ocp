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
   @"minCan",@"absWDens", @"densWAbs", @"ref",@"lexico",@"absDens"};

static NSString* valHName[] = {@"split",@"split3Way",@"split5Way",@"split6Way",@"dynamicSplit",@"dynamic3Split",@"dynamic5Split",@"dynamic6Split",@"split3B",@"splitAbs",@"ESplit",@"DSplit"};

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
@synthesize level;
@synthesize unique;
@synthesize is3Bfiltering;
@synthesize kbpercent;
@synthesize search3Bpercent;
@synthesize searchNBFloats;
@synthesize fName;
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
   heuristic = ref;
   valordering = dynamicSplit;
   subcut = dynamicSplit;
   defaultAbsSplit = dynamicSplit;
   restartRate = 0;
   timeOut = 60;
   nbThreads = 0;
   level = 0;
   unique = NO;
   is3Bfiltering = NO;
   kbpercent=-1;
   search3Bpercent=10;
   searchNBFloats=2;
   fName = @"";
   randomized = NO;
   for(int k = 1;k< argc;k++) {
      if (strncmp(argv[k], "-q", 2) == 0)
         size = atoi(argv[k]+2);
      else if (strncmp(argv[k],"-nb-floats",10)==0)
         searchNBFloats = atoi(argv[k+1]);
      else if (strncmp(argv[k], "-n", 2)==0)
         nArg = atoi(argv[k]+2);
      else if (strncmp(argv[k], "-h", 2)==0)
         heuristic = atoi(argv[k]+2);
      else if (strncmp(argv[k],"-w",2)==0)
         restartRate = atof(argv[k]+2);
      else if (strncmp(argv[k],"-t",2)==0)
         timeOut = atoi(argv[k]+2);
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
      else if (strncmp(argv[k],"-default",8)==0)
         defaultAbsSplit = atoi(argv[k+1]);
      else if (strncmp(argv[k],"-l",2)==0)
         level = atoi(argv[k]+2);
      else if (strncmp(argv[k],"-debug-level",12)==0)
         level = atoi(argv[k+1]);
      else if (strncmp(argv[k],"-u",2)==0)
         unique=YES;
      else if (strncmp(argv[k],"-3B",3)==0)
         is3Bfiltering=YES;
      else if (strncmp(argv[k],"-subcut",7)==0)
         subcut = atoi(argv[k+1]);
      else if (strncmp(argv[k],"-search3Bpercent",16)==0)
         search3Bpercent = atof(argv[k+1]);
   }
   return self;
}
-(NSString*)heuristicName
{
   return hName[heuristic-4];
}
-(NSString*)valueHeuristicName
{
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
      case split : return @selector(floatStaticSplit:call:withVars:);
      case split3Way : return @selector(floatStatic3WaySplit:call:withVars:);
      case split5Way : return @selector(floatStatic5WaySplit:call:withVars:);
      case split6Way : return @selector(floatStatic6WaySplit:call:withVars:);
      case dynamicSplit : return @selector(floatSplit:call:withVars:);
      case dynamic3Split : return @selector(float3WaySplit:call:withVars:);
      case dynamic5Split : return @selector(float5WaySplit:call:withVars:);
      case dynamic6Split : return @selector(float6WaySplit:call:withVars:);
      case split3B : return @selector(float3BSplit:call:withVars:);
      default:
         return @selector(float3BSplit:call:withVars:);
   }
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
   printf("FMT:heur,valHeur,rand,threads,size,found,restartRate,#f,#c,#p,cpu,wc,mUsed,mPeak,kb,kb%%, unique?,subcut,split3Bpercent\n");
   printf("OUT:%s,%s,%d,%d,%d,%d,%f,%d,%d,%d,%lld,%lld,%s,%s,%f,%s,%s,%f\n",[[self heuristicName] cStringUsingEncoding:NSASCIIStringEncoding],
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
          (unique) ? "YES":"NO",
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
   switch(nbThreads) {
      case 0:
         p = [ORFactory createCPProgram:model annotation:notes];
         [(CPCoreSolver*)p setLevel:level];
         [(CPCoreSolver*)p setUnique:unique];
         [(CPCoreSolver*)p setSearchNBFloats:searchNBFloats];
         [(CPCoreSolver*)p set3BSplitPercent:search3Bpercent];
         [(CPCoreSolver*)p setSubcut:[self subCutSelector]];
         return p;
      case 1: return [ORFactory createCPSemanticProgram:model annotation:notes with:[ORSemDFSController proto]];
      default: return [ORFactory createCPParProgram:model nb:nbThreads annotation:notes with:[ORSemDFSController proto]];
   }
}
-(void) printStats:(id<ORGroup>) g model:(id<ORModel>)m program:(id<CPProgram>)p
{
#define debug 0
#if debug
   @autoreleasepool{
      id<CPGroup> cg = [p concretize:g];
      id<ORFloatVarArray> vars = [m floatVars];
      id<ORDisabledFloatVarArray> x = [ORFactory disabledFloatVarArray:vars engine:[p engine]];
      ORInt nbNotBound = 0;
      for (id<ORFloatVar> v in x){
         id<CPFloatVar> cv = [p concretize:v];
         nbNotBound += (![cv bound]);
      }
      id<ORIntRange> r = RANGE(m,0,nbNotBound-1);
      id<ORIntArray> occs = [ORFactory intArray:m range:r value:0] ;
      __block id<ORIntArray> nbDistinctVarByConstraints = [ORFactory intArray:m range:RANGE(m,0,[g size]-1) value:0] ;
      __block id<ORIntArray> nbVarByConstraints = [ORFactory intArray:m range:RANGE(m,0,[g size]-1) value:0] ;
      id<ORIntArray> degree = [ORFactory intArray:m range:r value:0] ;
      id<ORIdArray> abs = [p computeAbsorptionsQuantities:x];
      id<ORDoubleArray> width = [ORFactory doubleArray:m range:r];
      id<ORDoubleArray> cardinality = [ORFactory doubleArray:m range:r];
      id<ORDoubleArray> cancellation = [ORFactory doubleArray:m range:r];
      id<ORLDoubleArray> density = [ORFactory ldoubleArray:m range:r];
      ORDouble minabs = MAXDBL;
      ORDouble maxabs = 0.0;
      ORDouble somme = 0.0;
      __block ORInt i = 0;
      ORInt nbInfini = 0;
      ORInt nbInfinic = 0;
      ORInt nbocc = 0;
      ORInt nbcanc = 0;
      ORInt occ = 0;
      ORDouble canc = 0.0;
      ORInt nbABound = 0;
      for(id<ORFloatVar> v in vars){
         id<CPFloatVar> cv = [p concretize:v];
         if([cv bound]) {
            nbABound++;
            continue;
         }
         if([v fmin] == -INFINITY && [v fmax] == +INFINITY) nbInfini++;
         if([cv min] == -INFINITY && [cv max] == +INFINITY) nbInfinic++;
         occ = [p maxOccurences:v];
         canc = [p cancellationQuantity:v];
         occs[i] = @(occ);
         degree[i] = @([p countMemberedConstraints:v]);
         width[i] = @([p fdomwidth:v]);
         cardinality[i] = @([p cardinality:v]);
         cancellation[i] = @(canc);
         [density set:[p density:v] at:i];
         i++;
         if(canc > 0)
            nbcanc++;
         if(occ > 1)
            nbocc++;
      }
      int nbabs = 0;
      for(ORUInt index = [abs low];index <= [abs up]; index++){
         id<CPFloatVar> cv = [p concretize:x[index]];
         if([cv bound]) continue;
         minabs = minDbl(minabs,[abs[index] quantity]);
         maxabs = maxDbl(maxabs,[abs[index] quantity]);
         if([abs[index] quantity] > 0) nbabs++;
         somme += [abs[index] quantity];
      }
      i=0;
      [g enumerateObjectWithBlock:^(id<ORConstraint> c) {
         nbVarByConstraints[i] = @((ORInt)[[c allVarsArray] count]);
         nbDistinctVarByConstraints[i] = @((ORInt)[[c allVars] count]);
         i++;
      }];
      printf("FM_STAT : #V_ALL,#V_INF,V_ABOUNDS;#V_CONCRETE,#V_CBOUNDS,#V_CINF,#CSTS,#C_CONCRETE,#MIN_MOCC,#MAX_MOCC,#AVG_MOCC,#SUP1_OCC,#MIN_WIDTH,#MAX_WIDTH,#AVG_WIDTH,#MIN_CARD,#MAX_CARD,#AVG_CARD,#MIN_DEGREE,#MAX_DEGREE,#AVG_DEGREE,#MIN_DNS,#MAX_DNS,#AVG_DNS,#MIN_ABS,#MAX_ABS,#AVG_ABS,#SUP0_ABS,#MAX_CANC,#AVG_CANC,#AVG_CANC,#SUP0_CANC;#MIN_VAR/CST;#MAX_VAR/CST;#AVERAGE_VAR/CST;#MIN_DVAR/CST;#MAX_DVAR/CST;#AVERAGE_DVAR/CST;\n");
      printf("OUT_STAT : %d;%d;%d;%d;%d;%d;%d;%d;%d;%d;%d;%d;%16.16e;%16.16e;%16.16e;%16.16e;%16.16e;%16.16e;%d;%d;%d;%16.16Le;%16.16Le;%16.16Le;%16.16e;%16.16e;%16.16e;%d;%16.16e;%16.16e;%16.16e;%d;%d;%d;%d;%d;%d;%d\n",(ORInt)[[g variables] count],nbInfini,nbABound,[[p engine] nbVars],[[p engine] nbVars]-nbNotBound,nbInfinic,[g size],[cg size],[occs min],[occs max],[occs average],nbocc,[width min],[width max],[width average],[cardinality min],[cardinality max],[cardinality average],[degree min],[degree max],[degree average],[density min],[density max],[density average],minabs,maxabs,(nbabs != 0)?(somme/nbabs):0,nbabs,[cancellation min],[cancellation max],[cancellation average],nbcanc,[nbVarByConstraints min],[nbVarByConstraints max],[nbVarByConstraints average],[nbDistinctVarByConstraints min],[nbDistinctVarByConstraints max],[nbDistinctVarByConstraints average]);
      
   }
#endif
}
-(void) checkAbsorption:(id<ORFloatVarArray>)vars solver:(id<CPProgram>)cp
{
#define abs 1
#if abs
   ORInt cpt = 0;
   for(id<ORFloatVar> x in vars){
      ORDouble v = [cp computeAbsorptionRate:x];
      if(v > 0.0){
         NSLog(@"%@ is involved in abs %f",x,v);
         cpt++;
      }
   }
   NSLog(@"Il y a %d variables impliquees dans une absorption", cpt);
#endif
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
   id<ORDisabledFloatVarArray> vars = [ORFactory disabledFloatVarArray:vs engine:[p engine]];
   switch (heuristic) {
      case maxWidth :
         switch (valordering) {
            case dedicatedSplit:
            case split:
               [p maxWidthSearch:vars do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p floatStaticSplit:i call:s withVars:x];
               }];
               break;
            case split3Way:
               [p maxWidthSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p floatStatic3WaySplit:i call:s withVars:x];
               }];
               break;
            case split5Way:
               [p maxWidthSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p floatStatic5WaySplit:i call:s withVars:x];
               }];
               break;
            case split6Way:
               [p maxWidthSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p floatStatic6WaySplit:i call:s withVars:x];
               }];
               break;
            case dynamicSplit:
               [p maxWidthSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p floatSplit:i call:s withVars:x];
               }];
               break;
            case dynamic3Split:
               [p maxWidthSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p float3WaySplit:i call:s withVars:x];
               }];
               break;
            case dynamic5Split:
               [p maxWidthSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p float5WaySplit:i call:s withVars:x];
               }];
               break;
            case dynamic6Split:
               [p maxWidthSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p float6WaySplit:i call:s withVars:x];
               }];
               break;
            case split3B:
               [p maxWidthSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p float3BSplit:i call:s withVars:x];
               }];
               break;
            case Esplit:
               [p maxWidthSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p floatEWaySplit:i call:s withVars:x];
               }];
               break;
            case Dsplit:
               [p maxWidthSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p floatDeltaSplit:i call:s withVars:x];
               }];
               break;
         }
         break;
      case minWidth :
         switch (valordering) {
            case dedicatedSplit:
            case split:
               [p minWidthSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p floatStaticSplit:i call:s withVars:x];
               }];
               break;
            case split3Way:
               [p minWidthSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p floatStatic3WaySplit:i call:s withVars:x];
               }];
               break;
            case split5Way:
               [p minWidthSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p floatStatic5WaySplit:i call:s withVars:x];
               }];
               break;
            case split6Way:
               [p minWidthSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p floatStatic6WaySplit:i call:s withVars:x];
               }];
               break;
            case dynamicSplit:
               [p minWidthSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p floatSplit:i call:s withVars:x];
               }];
               break;
            case dynamic3Split:
               [p minWidthSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p float3WaySplit:i call:s withVars:x];
               }];
               break;
            case dynamic5Split:
               [p minWidthSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p float5WaySplit:i call:s withVars:x];
               }];
               break;
            case dynamic6Split:
               [p minWidthSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p float6WaySplit:i call:s withVars:x];
               }];
               break;
            case split3B:
               [p minWidthSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p float3BSplit:i call:s withVars:x];
               }];
               break;
            case Esplit:
               [p minWidthSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p floatEWaySplit:i call:s withVars:x];
               }];
               break;
            case Dsplit:
               [p minWidthSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p floatDeltaSplit:i call:s withVars:x];
               }];
               break;
         }
         break;
      case maxCard :
         switch (valordering) {
                case dedicatedSplit:
            case split:
               [p maxCardinalitySearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p floatStaticSplit:i call:s withVars:x];
               }];
               break;
            case split3Way:
               [p maxCardinalitySearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p floatStatic3WaySplit:i call:s withVars:x];
               }];
               break;
            case split5Way:
               [p maxCardinalitySearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p floatStatic5WaySplit:i call:s withVars:x];
               }];
               break;
            case split6Way:
               [p maxCardinalitySearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p floatStatic6WaySplit:i call:s withVars:x];
               }];
               break;
            case dynamicSplit:
               [p maxCardinalitySearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p floatSplit:i call:s withVars:x];
               }];
               break;
            case dynamic3Split:
               [p maxCardinalitySearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p float3WaySplit:i call:s withVars:x];
               }];
               break;
            case dynamic5Split:
               [p maxCardinalitySearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p float5WaySplit:i call:s withVars:x];
               }];
               break;
            case dynamic6Split:
               [p maxCardinalitySearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p float6WaySplit:i call:s withVars:x];
               }];
               break;
            case split3B:
               [p maxCardinalitySearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p float3BSplit:i call:s withVars:x];
               }];
               break;
            case Esplit:
               [p maxCardinalitySearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p floatEWaySplit:i call:s withVars:x];
               }];
               break;
            case Dsplit:
               [p maxCardinalitySearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p floatDeltaSplit:i call:s withVars:x];
               }];
               break;
         }
         break;
      case minCard :
         switch (valordering) {
                case dedicatedSplit:
            case split:
               [p minCardinalitySearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p floatStaticSplit:i call:s withVars:x];
               }];
               break;
            case split3Way:
               [p minCardinalitySearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p floatStatic3WaySplit:i call:s withVars:x];
               }];
               break;
            case split5Way:
               [p minCardinalitySearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p floatStatic5WaySplit:i call:s withVars:x];
               }];
               break;
            case split6Way:
               [p minCardinalitySearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p floatStatic6WaySplit:i call:s withVars:x];
               }];
               break;
            case dynamicSplit:
               [p minCardinalitySearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p floatSplit:i call:s withVars:x];
               }];
               break;
            case dynamic3Split:
               [p minCardinalitySearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p float3WaySplit:i call:s withVars:x];
               }];
               break;
            case dynamic5Split:
               [p minCardinalitySearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p float5WaySplit:i call:s withVars:x];
               }];
               break;
            case dynamic6Split:
               [p minCardinalitySearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p float6WaySplit:i call:s withVars:x];
               }];
               break;
            case split3B:
               [p minCardinalitySearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p float3BSplit:i call:s withVars:x];
               }];
               break;
            case Esplit:
               [p minCardinalitySearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p floatEWaySplit:i call:s withVars:x];
               }];
               break;
            case Dsplit:
               [p minCardinalitySearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p floatDeltaSplit:i call:s withVars:x];
               }];
               break;
         }
         break;
      case maxDens :
         switch (valordering) {
                case dedicatedSplit:
            case split:
               [p maxDensitySearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p floatStaticSplit:i call:s withVars:x];
               }];
               break;
            case split3Way:
               [p maxDensitySearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p floatStatic3WaySplit:i call:s withVars:x];
               }];
               break;
            case split5Way:
               [p maxDensitySearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p floatStatic5WaySplit:i call:s withVars:x];
               }];
               break;
            case split6Way:
               [p maxDensitySearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p floatStatic6WaySplit:i call:s withVars:x];
               }];
               break;
            case dynamicSplit:
               [p maxDensitySearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p floatSplit:i call:s withVars:x];
               }];
               break;
            case dynamic3Split:
               [p maxDensitySearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p float3WaySplit:i call:s withVars:x];
               }];
               break;
            case dynamic5Split:
               [p maxDensitySearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p float5WaySplit:i call:s withVars:x];
               }];
               break;
            case dynamic6Split:
               [p maxDensitySearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p float6WaySplit:i call:s withVars:x];
               }];
               break;
            case split3B:
               [p maxDensitySearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p float3BSplit:i call:s withVars:x];
               }];
               break;
            case Esplit:
               [p maxDensitySearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p floatEWaySplit:i call:s withVars:x];
               }];
               break;
            case Dsplit:
               [p maxDensitySearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p floatDeltaSplit:i call:s withVars:x];
               }];
               break;
         }
         break;
      case minDens :
         switch (valordering) {
                case dedicatedSplit:
            case split:
               [p minDensitySearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p floatStaticSplit:i call:s withVars:x];
               }];
               break;
            case split3Way:
               [p minDensitySearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p floatStatic3WaySplit:i call:s withVars:x];
               }];
               break;
            case split5Way:
               [p minDensitySearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p floatStatic5WaySplit:i call:s withVars:x];
               }];
               break;
            case split6Way:
               [p minDensitySearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p floatStatic6WaySplit:i call:s withVars:x];
               }];
               break;
            case dynamicSplit:
               [p minDensitySearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p floatSplit:i call:s withVars:x];
               }];
               break;
            case dynamic3Split:
               [p minDensitySearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p float3WaySplit:i call:s withVars:x];
               }];
               break;
            case dynamic5Split:
               [p minDensitySearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p float5WaySplit:i call:s withVars:x];
               }];
               break;
            case dynamic6Split:
               [p minDensitySearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p float6WaySplit:i call:s withVars:x];
               }];
               break;
            case split3B:
               [p minDensitySearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p float3BSplit:i call:s withVars:x];
               }];
               break;
            case Esplit:
               [p minDensitySearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p floatEWaySplit:i call:s withVars:x];
               }];
               break;
            case Dsplit:
               [p minDensitySearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p floatDeltaSplit:i call:s withVars:x];
               }];
               break;
         }
         break;
      case maxMagn :
         switch (valordering) {
                case dedicatedSplit:
            case split:
               [p maxMagnitudeSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p floatStaticSplit:i call:s withVars:x];
               }];
               break;
            case split3Way:
               [p maxMagnitudeSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p floatStatic3WaySplit:i call:s withVars:x];
               }];
               break;
            case split5Way:
               [p maxMagnitudeSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p floatStatic5WaySplit:i call:s withVars:x];
               }];
               break;
            case split6Way:
               [p maxMagnitudeSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p floatStatic6WaySplit:i call:s withVars:x];
               }];
               break;
            case dynamicSplit:
               [p maxMagnitudeSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p floatSplit:i call:s withVars:x];
               }];
               break;
            case dynamic3Split:
               [p maxMagnitudeSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p float3WaySplit:i call:s withVars:x];
               }];
               break;
            case dynamic5Split:
               [p maxMagnitudeSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p float5WaySplit:i call:s withVars:x];
               }];
               break;
            case dynamic6Split:
               [p maxMagnitudeSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p float6WaySplit:i call:s withVars:x];
               }];
               break;
            case split3B:
               [p maxMagnitudeSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p float3BSplit:i call:s withVars:x];
               }];
               break;
            case Esplit:
               [p maxMagnitudeSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p floatEWaySplit:i call:s withVars:x];
               }];
               break;
            case Dsplit:
               [p maxMagnitudeSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p floatDeltaSplit:i call:s withVars:x];
               }];
               break;
         }
         break;
      case minMagn :
         switch (valordering) {
                case dedicatedSplit:
            case split:
               [p minMagnitudeSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p floatStaticSplit:i call:s withVars:x];
               }];
               break;
            case split3Way:
               [p minMagnitudeSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p floatStatic3WaySplit:i call:s withVars:x];
               }];
               break;
            case split5Way:
               [p minMagnitudeSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p floatStatic5WaySplit:i call:s withVars:x];
               }];
               break;
            case split6Way:
               [p minMagnitudeSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p floatStatic6WaySplit:i call:s withVars:x];
               }];
               break;
            case dynamicSplit:
               [p minMagnitudeSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p floatSplit:i call:s withVars:x];
               }];
               break;
            case dynamic3Split:
               [p minMagnitudeSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p float3WaySplit:i call:s withVars:x];
               }];
               break;
            case dynamic5Split:
               [p minMagnitudeSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p float5WaySplit:i call:s withVars:x];
               }];
               break;
            case dynamic6Split:
               [p minMagnitudeSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p float6WaySplit:i call:s withVars:x];
               }];
               break;
            case split3B:
               [p minMagnitudeSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p float3BSplit:i call:s withVars:x];
               }];
               break;
            case Esplit:
               [p minMagnitudeSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p floatEWaySplit:i call:s withVars:x];
               }];
               break;
            case Dsplit:
               [p minMagnitudeSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p floatDeltaSplit:i call:s withVars:x];
               }];
               break;
         }
         break;
      case maxDegree :
         switch (valordering) {
                case dedicatedSplit:
            case split:
               [p maxDegreeSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p floatStaticSplit:i call:s withVars:x];
               }];
               break;
            case split3Way:
               [p maxDegreeSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p floatStatic3WaySplit:i call:s withVars:x];
               }];
               break;
            case split5Way:
               [p maxDegreeSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p floatStatic5WaySplit:i call:s withVars:x];
               }];
               break;
            case split6Way:
               [p maxDegreeSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p floatStatic6WaySplit:i call:s withVars:x];
               }];
               break;
            case dynamicSplit:
               [p maxDegreeSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p floatSplit:i call:s withVars:x];
               }];
               break;
            case dynamic3Split:
               [p maxDegreeSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p float3WaySplit:i call:s withVars:x];
               }];
               break;
            case dynamic5Split:
               [p maxDegreeSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p float5WaySplit:i call:s withVars:x];
               }];
               break;
            case dynamic6Split:
               [p maxDegreeSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p float6WaySplit:i call:s withVars:x];
               }];
               break;
            case split3B:
               [p maxDegreeSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p float3BSplit:i call:s withVars:x];
               }];
               break;
            case Esplit:
               [p maxDegreeSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p floatEWaySplit:i call:s withVars:x];
               }];
               break;
            case Dsplit:
               [p maxDegreeSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p floatDeltaSplit:i call:s withVars:x];
               }];
               break;
         }
         break;
      case minDegree :
         switch (valordering) {
                case dedicatedSplit:
            case split:
               [p minDegreeSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p floatStaticSplit:i call:s withVars:x];
               }];
               break;
            case split3Way:
               [p minDegreeSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p floatStatic3WaySplit:i call:s withVars:x];
               }];
               break;
            case split5Way:
               [p minDegreeSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p floatStatic5WaySplit:i call:s withVars:x];
               }];
               break;
            case split6Way:
               [p minDegreeSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p floatStatic6WaySplit:i call:s withVars:x];
               }];
               break;
            case dynamicSplit:
               [p minDegreeSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p floatSplit:i call:s withVars:x];
               }];
               break;
            case dynamic3Split:
               [p minDegreeSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p float3WaySplit:i call:s withVars:x];
               }];
               break;
            case dynamic5Split:
               [p minDegreeSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p float5WaySplit:i call:s withVars:x];
               }];
               break;
            case dynamic6Split:
               [p minDegreeSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p float6WaySplit:i call:s withVars:x];
               }];
               break;
            case split3B:
               [p minDegreeSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p float3BSplit:i call:s withVars:x];
               }];
               break;
            case Esplit:
               [p minDegreeSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p floatEWaySplit:i call:s withVars:x];
               }];
               break;
            case Dsplit:
               [p minDegreeSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p floatDeltaSplit:i call:s withVars:x];
               }];
               break;
         }
         break;
      case maxOcc :
         switch (valordering) {
                case dedicatedSplit:
            case split:
               [p maxOccurencesSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p floatStaticSplit:i call:s withVars:x];
               }];
               break;
            case split3Way:
               [p maxOccurencesSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p floatStatic3WaySplit:i call:s withVars:x];
               }];
               break;
            case split5Way:
               [p maxOccurencesSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p floatStatic5WaySplit:i call:s withVars:x];
               }];
               break;
            case split6Way:
               [p maxOccurencesSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p floatStatic6WaySplit:i call:s withVars:x];
               }];
               break;
            case dynamicSplit:
               [p maxOccurencesSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p floatSplit:i call:s withVars:x];
               }];
               break;
            case dynamic3Split:
               [p maxOccurencesSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p float3WaySplit:i call:s withVars:x];
               }];
               break;
            case dynamic5Split:
               [p maxOccurencesSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p float5WaySplit:i call:s withVars:x];
               }];
               break;
            case dynamic6Split:
               [p maxOccurencesSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p float6WaySplit:i call:s withVars:x];
               }];
               break;
            case split3B:
               [p maxOccurencesSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p float3BSplit:i call:s withVars:x];
               }];
               break;
            case Esplit:
               [p maxOccurencesSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p floatEWaySplit:i call:s withVars:x];
               }];
               break;
            case Dsplit:
               [p maxOccurencesSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p floatDeltaSplit:i call:s withVars:x];
               }];
               break;
         }
         break;
      case minOcc :
         switch (valordering) {
                case dedicatedSplit:
            case split:
               [p minOccurencesSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p floatStaticSplit:i call:s withVars:x];
               }];
               break;
            case split3Way:
               [p minOccurencesSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p floatStatic3WaySplit:i call:s withVars:x];
               }];
               break;
            case split5Way:
               [p minOccurencesSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p floatStatic5WaySplit:i call:s withVars:x];
               }];
               break;
            case split6Way:
               [p minOccurencesSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p floatStatic6WaySplit:i call:s withVars:x];
               }];
               break;
            case dynamicSplit:
               [p minOccurencesSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p floatSplit:i call:s withVars:x];
               }];
               break;
            case dynamic3Split:
               [p minOccurencesSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p float3WaySplit:i call:s withVars:x];
               }];
               break;
            case dynamic5Split:
               [p minOccurencesSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p float5WaySplit:i call:s withVars:x];
               }];
               break;
            case dynamic6Split:
               [p minOccurencesSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p float6WaySplit:i call:s withVars:x];
               }];
               break;
            case split3B:
               [p minOccurencesSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p float3BSplit:i call:s withVars:x];
               }];
               break;
            case Esplit:
               [p minOccurencesSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p floatEWaySplit:i call:s withVars:x];
               }];
               break;
            case Dsplit:
               [p minOccurencesSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p floatDeltaSplit:i call:s withVars:x];
               }];
               break;
         }
         break;
      case maxAbs :
         switch (valordering) {
            case split:
               [p maxAbsorptionSearch:vars do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p floatStaticSplit:i call:s withVars:x];
               }];
               break;
            case split3Way:
               [p maxAbsorptionSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p floatStatic3WaySplit:i call:s withVars:x];
               }];
               break;
            case split5Way:
               [p maxAbsorptionSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p floatStatic5WaySplit:i call:s withVars:x];
               }];
               break;
            case split6Way:
               [p maxAbsorptionSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p floatStatic6WaySplit:i call:s withVars:x];
               }];
               break;
            case dynamicSplit:
               [p maxAbsorptionSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p floatSplit:i call:s withVars:x];
               }];
               break;
            case dynamic3Split:
               [p maxAbsorptionSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p float3WaySplit:i call:s withVars:x];
               }];
               break;
            case dynamic5Split:
               [p maxAbsorptionSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p float5WaySplit:i call:s withVars:x];
               }];
               break;
            case dynamic6Split:
               [p maxAbsorptionSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p float6WaySplit:i call:s withVars:x];
               }];
               break;
            case split3B:
               [p maxAbsorptionSearch:vars do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p float3BSplit:i call:s withVars:x];
               }];
               break;
            case Esplit:
               [p maxAbsorptionSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p floatEWaySplit:i call:s withVars:x];
               }];
               break;
            case Dsplit:
               [p maxAbsorptionSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p floatDeltaSplit:i call:s withVars:x];
               }];
               break;
            case dedicatedSplit:
               switch(defaultAbsSplit){
                  case split:
                     [p maxAbsorptionSearch:vars default:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                        [p floatStaticSplit:i call:s withVars:x];
                     }];
                     break;
                  case split3Way:
                     [p maxAbsorptionSearch:vars default:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                        [p floatStatic3WaySplit:i call:s withVars:x];
                     }];
                     break;
                  case split5Way:
                     [p maxAbsorptionSearch:vars default:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                        [p floatStatic5WaySplit:i call:s withVars:x];
                     }];
                     break;
                  case split6Way:
                     [p maxAbsorptionSearch:vars default:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                        [p floatStatic6WaySplit:i call:s withVars:x];
                         }];
                     break;
                  case dynamicSplit:
                     [p maxAbsorptionSearch:vars default:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                        [p floatSplit:i call:s withVars:x];
                     }];
                     break;
                  case dynamic3Split:
                     [p maxAbsorptionSearch:vars default:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                        [p float3WaySplit:i call:s withVars:x];
                     }];
                     break;
                  case dynamic5Split:
                     [p maxAbsorptionSearch:vars default:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                        [p float5WaySplit:i call:s withVars:x];
                     }];break;
                  case dynamic6Split:
                     [p maxAbsorptionSearch:vars default:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                     [p float6WaySplit:i call:s withVars:x];
                     }];
                  case split3B:
                     [p maxAbsorptionSearch:vars default:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                        [p float3BSplit:i call:s withVars:x];
                     }];
                     break;
                  case Esplit:
                     [p maxAbsorptionSearch:vars  default:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                        [p floatEWaySplit:i call:s withVars:x];
                     }];
                     break;
                  case Dsplit:
                     [p maxAbsorptionSearch:vars  default:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                        [p floatDeltaSplit:i call:s withVars:x];
                     }];
                     break;
                  default:
                     [p maxAbsorptionSearch:vars default:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                        [p float6WaySplit:i call:s withVars:x];
                     }];
               }
               break;
               
            default:
               [p maxAbsorptionSearch:vars do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p floatEWaySplit:i call:s withVars:x];
               }];
               break;
         }
         break;
     
      case minAbs :
         switch (valordering) {
            case split:
               [p minAbsorptionSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p floatStaticSplit:i call:s withVars:x];
               }];
               break;
            case split3Way:
               [p minAbsorptionSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p floatStatic3WaySplit:i call:s withVars:x];
               }];
               break;
            case split5Way:
               [p minAbsorptionSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p floatStatic5WaySplit:i call:s withVars:x];
               }];
               break;
            case split6Way:
               [p minAbsorptionSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p floatStatic6WaySplit:i call:s withVars:x];
               }];
               break;
            case dynamicSplit:
               [p minAbsorptionSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p floatSplit:i call:s withVars:x];
               }];
               break;
            case dynamic3Split:
               [p minAbsorptionSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p float3WaySplit:i call:s withVars:x];
               }];
               break;
            case dynamic5Split:
               [p minAbsorptionSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p float5WaySplit:i call:s withVars:x];
               }];
               break;
            case dynamic6Split:
               [p minAbsorptionSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p float6WaySplit:i call:s withVars:x];
               }];
               break;
            case split3B:
               [p minAbsorptionSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p float3BSplit:i call:s withVars:x];
               }];
               break;
            case dedicatedSplit:
               [p minAbsorptionSearch:vars default:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p float6WaySplit:i call:s withVars:x];
               }];
               break;
            case Esplit:
               [p minAbsorptionSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p floatEWaySplit:i call:s withVars:x];
               }];
               break;
            case Dsplit:
               [p minAbsorptionSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p floatDeltaSplit:i call:s withVars:x];
               }];
               break;
               
         }
         break;
      case maxCan :
         switch (valordering) {
                case dedicatedSplit:
            case split:
               [p maxCancellationSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p floatStaticSplit:i call:s withVars:x];
               }];
               break;
            case split3Way:
               [p maxCancellationSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p floatStatic3WaySplit:i call:s withVars:x];
               }];
               break;
            case split5Way:
               [p maxCancellationSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p floatStatic5WaySplit:i call:s withVars:x];
               }];
               break;
            case split6Way:
               [p maxCancellationSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p floatStatic6WaySplit:i call:s withVars:x];
               }];
               break;
            case dynamicSplit:
               [p maxCancellationSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p floatSplit:i call:s withVars:x];
               }];
               break;
            case dynamic3Split:
               [p maxCancellationSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p float3WaySplit:i call:s withVars:x];
               }];
               break;
            case dynamic5Split:
               [p maxCancellationSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p float5WaySplit:i call:s withVars:x];
               }];
               break;
            case dynamic6Split:
               [p maxCancellationSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p float6WaySplit:i call:s withVars:x];
               }];
               break;
            case split3B:
               [p maxCancellationSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p float3BSplit:i call:s withVars:x];
               }];
               break;
            case Esplit:
               [p maxCancellationSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p floatEWaySplit:i call:s withVars:x];
               }];
               break;
            case Dsplit:
               [p maxCancellationSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p floatDeltaSplit:i call:s withVars:x];
               }];
               break;
         }
         break;
      case minCan :
         switch (valordering) {
                case dedicatedSplit:
            case split:
               [p minCancellationSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p floatStaticSplit:i call:s withVars:x];
               }];
               break;
            case split3Way:
               [p minCancellationSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p floatStatic3WaySplit:i call:s withVars:x];
               }];
               break;
            case split5Way:
               [p minCancellationSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p floatStatic5WaySplit:i call:s withVars:x];
               }];
               break;
            case split6Way:
               [p minCancellationSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p floatStatic6WaySplit:i call:s withVars:x];
               }];
               break;
            case dynamicSplit:
               [p minCancellationSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p floatSplit:i call:s withVars:x];
               }];
               break;
            case dynamic3Split:
               [p minCancellationSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p float3WaySplit:i call:s withVars:x];
               }];
               break;
            case dynamic5Split:
               [p minCancellationSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p float5WaySplit:i call:s withVars:x];
               }];
               break;
            case dynamic6Split:
               [p minCancellationSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p float6WaySplit:i call:s withVars:x];
               }];
               break;
            case split3B:
               [p minCancellationSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p float3BSplit:i call:s withVars:x];
               }];
               break;
            case Esplit:
               [p minCancellationSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p floatEWaySplit:i call:s withVars:x];
               }];
               break;
            case Dsplit:
               [p minCancellationSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p floatDeltaSplit:i call:s withVars:x];
               }];
               break;
         }
         break;
      case absWDens :
         switch (valordering) {
             case dedicatedSplit:
            case split:
               [p combinedAbsWithDensSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p floatStaticSplit:i call:s withVars:x];
               }];
               break;
            case split3Way:
               [p combinedAbsWithDensSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p floatStatic3WaySplit:i call:s withVars:x];
               }];
               break;
            case split5Way:
               [p combinedAbsWithDensSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p floatStatic5WaySplit:i call:s withVars:x];
               }];
               break;
            case split6Way:
               [p combinedAbsWithDensSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p floatStatic6WaySplit:i call:s withVars:x];
               }];
               break;
            case dynamicSplit:
               [p combinedAbsWithDensSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p floatSplit:i call:s withVars:x];
               }];
               break;
            case dynamic3Split:
               [p combinedAbsWithDensSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p float3WaySplit:i call:s withVars:x];
               }];
               break;
            case dynamic5Split:
               [p combinedAbsWithDensSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p float5WaySplit:i call:s withVars:x];
               }];
               break;
            case dynamic6Split:
               [p combinedAbsWithDensSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p float6WaySplit:i call:s withVars:x];
               }];
               break;
            case split3B:
               [p combinedAbsWithDensSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p float3BSplit:i call:s withVars:x];
               }];
               break;
            case Esplit:
               [p combinedAbsWithDensSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p floatEWaySplit:i call:s withVars:x];
               }];
               break;
            case Dsplit:
               [p combinedAbsWithDensSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p floatDeltaSplit:i call:s withVars:x];
               }];
               break;
         }
         break;
      case densWAbs :
         switch (valordering) {
            case dedicatedSplit:
            case split:
               [p combinedDensWithAbsSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p floatStaticSplit:i call:s withVars:x];
               }];
               break;
            case split3Way:
               [p combinedDensWithAbsSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p floatStatic3WaySplit:i call:s withVars:x];
               }];
               break;
            case split5Way:
               [p combinedDensWithAbsSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p floatStatic5WaySplit:i call:s withVars:x];
               }];
               break;
            case split6Way:
               [p combinedDensWithAbsSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p floatStatic6WaySplit:i call:s withVars:x];
               }];
               break;
            case dynamicSplit:
               [p combinedDensWithAbsSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p floatSplit:i call:s withVars:x];
               }];
               break;
            case dynamic3Split:
               [p combinedDensWithAbsSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p float3WaySplit:i call:s withVars:x];
               }];
               break;
            case dynamic5Split:
               [p combinedDensWithAbsSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p float5WaySplit:i call:s withVars:x];
               }];
               break;
            case dynamic6Split:
               [p combinedDensWithAbsSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p float6WaySplit:i call:s withVars:x];
               }];
               break;
            case split3B:
               [p combinedDensWithAbsSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p float3BSplit:i call:s withVars:x];
               }];
               break;
            case Esplit:
               [p combinedDensWithAbsSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p floatEWaySplit:i call:s withVars:x];
               }];
               break;
            case Dsplit:
               [p combinedDensWithAbsSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p floatDeltaSplit:i call:s withVars:x];
               }];
               break;
         }
         break;
      
      case absDens :
         [p maxAbsDensSearch:vars default:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
            [p float6WaySplit:i call:s withVars:x];
         }];
         break;
      default :
         heuristic = lexico;
         switch (valordering) {
            case dedicatedSplit:
            case split:
               [p lexicalOrderedSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p floatStaticSplit:i call:s withVars:x];
               }];
               break;
            case split3Way:
               [p lexicalOrderedSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p floatStatic3WaySplit:i call:s withVars:x];
               }];
               break;
            case split5Way:
               [p lexicalOrderedSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p floatStatic5WaySplit:i call:s withVars:x];
               }];
               break;
            case split6Way:
               [p lexicalOrderedSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p floatStatic6WaySplit:i call:s withVars:x];
               }];
               break;
            case dynamicSplit:
               heuristic = ref;
               [p lexicalOrderedSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p floatSplit:i call:s withVars:x];
               }];
               break;
            case dynamic3Split:
               [p lexicalOrderedSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p float3WaySplit:i call:s withVars:x];
               }];
               break;
            case dynamic5Split:
               [p lexicalOrderedSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p float5WaySplit:i call:s withVars:x];
               }];
               break;
            case dynamic6Split:
               [p lexicalOrderedSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p float6WaySplit:i call:s withVars:x];
               }];
               break;
            case split3B:
               [p lexicalOrderedSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p float3BSplit:i call:s withVars:x];
               }];
               break;
            case Esplit:
               [p lexicalOrderedSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p floatEWaySplit:i call:s withVars:x];
               }];
               break;
            case Dsplit:
               [p lexicalOrderedSearch:vars  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  [p floatDeltaSplit:i call:s withVars:x];
               }];
               break;
               
         }
         break;
   }
}


@end
