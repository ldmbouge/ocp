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
                            @"minCan",@"absWDens", @"densWAbs", @"ref",@"lexico"};

static NSString* valHName[] = {@"split",@"split3Way",@"split5Way",@"split6Way",@"dynamicSplit",@"dynamic3Split",@"dynamic5Split",@"dynamic6Split"};

@synthesize size;
@synthesize restartRate;
@synthesize timeOut;
@synthesize randomized;
@synthesize heuristic;
@synthesize valordering;
@synthesize nbThreads;
@synthesize nArg;
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
   restartRate = 0;
   timeOut = 60;
   nbThreads = 0;
   fName = @"";
   randomized = NO;
   for(int k = 1;k< argc;k++) {
      if (strncmp(argv[k], "-q", 2) == 0)
         size = atoi(argv[k]+2);
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
      else if (strncmp(argv[k],"-p",2)==0)
          nbThreads = atoi(argv[k]+2);
      else if (strncmp(argv[k],"-f",2)==0)
          fName = [NSString stringWithCString:argv[k]+2 encoding:NSASCIIStringEncoding];
      else if (strncmp(argv[k],"-vh",3)==0)
          valordering = atoi(argv[k]+3);
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
   printf("FMT:heur,valHeur,rand,threads,size,found,restartRate,#f,#c,#p,cpu,wc,mUsed,mPeak\n");
   printf("OUT:%s,%s,%d,%d,%d,%d,%f,%d,%d,%d,%lld,%lld,%s\n",[[self heuristicName] cStringUsingEncoding:NSASCIIStringEncoding],
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
          endWC - startWC,[str cStringUsingEncoding:NSASCIIStringEncoding]);
}
-(id<CPProgram>)makeProgram:(id<ORModel>)model
{
   return [self makeProgram:model annotation:nil];
}
-(id<CPProgram>)makeProgram:(id<ORModel>)model annotation:(id<ORAnnotation>)notes
{
   switch(nbThreads) {
      case 0: return [ORFactory createCPProgram:model annotation:notes];
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
-(void)launchHeuristic:(id<CPProgram>)p restricted:(id<ORFloatVarArray>)vars
{
    switch (heuristic) {
        case maxWidth :
            switch (valordering) {
                case split:
                    [p maxWidthSearch:vars do:^(id<ORFloatVar> x) {
                        [p floatStaticSplit:x];
                    }];
                    break;
                case split3Way:
                    [p maxWidthSearch:vars do:^(id<ORFloatVar> x) {
                        [p floatStatic3WaySplit:x];
                    }];
                    break;
                case split5Way:
                    [p maxWidthSearch:vars do:^(id<ORFloatVar> x) {
                        [p floatStatic5WaySplit:x];
                    }];
                    break;
                case split6Way:
                    [p maxWidthSearch:vars do:^(id<ORFloatVar> x) {
                        [p floatStatic6WaySplit:x];
                    }];
                    break;
                case dynamicSplit:
                    [p maxWidthSearch:vars do:^(id<ORFloatVar> x) {
                        [p floatSplit:x];
                    }];
                    break;
                case dynamic3Split:
                    [p maxWidthSearch:vars do:^(id<ORFloatVar> x) {
                        [p float3WaySplit:x];
                    }];
                    break;
                case dynamic5Split:
                    [p maxWidthSearch:vars do:^(id<ORFloatVar> x) {
                        [p float5WaySplit:x];
                    }];
                    break;
                case dynamic6Split:
                    [p maxWidthSearch:vars do:^(id<ORFloatVar> x) {
                        [p float6WaySplit:x];
                    }];
                    break;
            }
            break;
        case minWidth :
            switch (valordering) {
                case split:
                    [p minWidthSearch:vars do:^(id<ORFloatVar> x) {
                        [p floatStaticSplit:x];
                    }];
                    break;
                case split3Way:
                    [p minWidthSearch:vars do:^(id<ORFloatVar> x) {
                        [p floatStatic3WaySplit:x];
                    }];
                    break;
                case split5Way:
                    [p minWidthSearch:vars do:^(id<ORFloatVar> x) {
                        [p floatStatic5WaySplit:x];
                    }];
                    break;
                case split6Way:
                    [p minWidthSearch:vars do:^(id<ORFloatVar> x) {
                        [p floatStatic6WaySplit:x];
                    }];
                    break;
                case dynamicSplit:
                    [p minWidthSearch:vars do:^(id<ORFloatVar> x) {
                        [p floatSplit:x];
                    }];
                    break;
                case dynamic3Split:
                    [p minWidthSearch:vars do:^(id<ORFloatVar> x) {
                        [p float3WaySplit:x];
                    }];
                    break;
                case dynamic5Split:
                    [p minWidthSearch:vars do:^(id<ORFloatVar> x) {
                        [p float5WaySplit:x];
                    }];
                    break;
                case dynamic6Split:
                    [p minWidthSearch:vars do:^(id<ORFloatVar> x) {
                        [p float6WaySplit:x];
                    }];
                    break;
            }
            break;
        case maxCard :
            switch (valordering) {
                case split:
                    [p maxCardinalitySearch:vars do:^(id<ORFloatVar> x) {
                        [p floatStaticSplit:x];
                    }];
                    break;
                case split3Way:
                    [p maxCardinalitySearch:vars do:^(id<ORFloatVar> x) {
                        [p floatStatic3WaySplit:x];
                    }];
                    break;
                case split5Way:
                    [p maxCardinalitySearch:vars do:^(id<ORFloatVar> x) {
                        [p floatStatic5WaySplit:x];
                    }];
                    break;
                case split6Way:
                    [p maxCardinalitySearch:vars do:^(id<ORFloatVar> x) {
                        [p floatStatic6WaySplit:x];
                    }];
                    break;
                case dynamicSplit:
                    [p maxCardinalitySearch:vars do:^(id<ORFloatVar> x) {
                        [p floatSplit:x];
                    }];
                    break;
                case dynamic3Split:
                    [p maxCardinalitySearch:vars do:^(id<ORFloatVar> x) {
                        [p float3WaySplit:x];
                    }];
                    break;
                case dynamic5Split:
                    [p maxCardinalitySearch:vars do:^(id<ORFloatVar> x) {
                        [p float5WaySplit:x];
                    }];
                    break;
                case dynamic6Split:
                    [p maxCardinalitySearch:vars do:^(id<ORFloatVar> x) {
                        [p float6WaySplit:x];
                    }];
                    break;
            }
            break;
        case minCard :
            switch (valordering) {
                case split:
                    [p minCardinalitySearch:vars do:^(id<ORFloatVar> x) {
                        [p floatStaticSplit:x];
                    }];
                    break;
                case split3Way:
                    [p minCardinalitySearch:vars do:^(id<ORFloatVar> x) {
                        [p floatStatic3WaySplit:x];
                    }];
                    break;
                case split5Way:
                    [p minCardinalitySearch:vars do:^(id<ORFloatVar> x) {
                        [p floatStatic5WaySplit:x];
                    }];
                    break;
                case split6Way:
                    [p minCardinalitySearch:vars do:^(id<ORFloatVar> x) {
                        [p floatStatic6WaySplit:x];
                    }];
                    break;
                case dynamicSplit:
                    [p minCardinalitySearch:vars do:^(id<ORFloatVar> x) {
                        [p floatSplit:x];
                    }];
                    break;
                case dynamic3Split:
                    [p minCardinalitySearch:vars do:^(id<ORFloatVar> x) {
                        [p float3WaySplit:x];
                    }];
                    break;
                case dynamic5Split:
                    [p minCardinalitySearch:vars do:^(id<ORFloatVar> x) {
                        [p float5WaySplit:x];
                    }];
                    break;
                case dynamic6Split:
                    [p minCardinalitySearch:vars do:^(id<ORFloatVar> x) {
                        [p float6WaySplit:x];
                    }];
                    break;
            }
            break;
        case maxDens :
            switch (valordering) {
                case split:
                    [p maxDensitySearch:vars do:^(id<ORFloatVar> x) {
                        [p floatStaticSplit:x];
                    }];
                    break;
                case split3Way:
                    [p maxDensitySearch:vars do:^(id<ORFloatVar> x) {
                        [p floatStatic3WaySplit:x];
                    }];
                    break;
                case split5Way:
                    [p maxDensitySearch:vars do:^(id<ORFloatVar> x) {
                        [p floatStatic5WaySplit:x];
                    }];
                    break;
                case split6Way:
                    [p maxDensitySearch:vars do:^(id<ORFloatVar> x) {
                        [p floatStatic6WaySplit:x];
                    }];
                    break;
                case dynamicSplit:
                    [p maxDensitySearch:vars do:^(id<ORFloatVar> x) {
                        [p floatSplit:x];
                    }];
                    break;
                case dynamic3Split:
                    [p maxDensitySearch:vars do:^(id<ORFloatVar> x) {
                        [p float3WaySplit:x];
                    }];
                    break;
                case dynamic5Split:
                    [p maxDensitySearch:vars do:^(id<ORFloatVar> x) {
                        [p float5WaySplit:x];
                    }];
                    break;
                case dynamic6Split:
                    [p maxDensitySearch:vars do:^(id<ORFloatVar> x) {
                        [p float6WaySplit:x];
                    }];
                    break;
            }
            break;
        case minDens :
            switch (valordering) {
                case split:
                    [p minDensitySearch:vars do:^(id<ORFloatVar> x) {
                        [p floatStaticSplit:x];
                    }];
                    break;
                case split3Way:
                    [p minDensitySearch:vars do:^(id<ORFloatVar> x) {
                        [p floatStatic3WaySplit:x];
                    }];
                    break;
                case split5Way:
                    [p minDensitySearch:vars do:^(id<ORFloatVar> x) {
                        [p floatStatic5WaySplit:x];
                    }];
                    break;
                case split6Way:
                    [p minDensitySearch:vars do:^(id<ORFloatVar> x) {
                        [p floatStatic6WaySplit:x];
                    }];
                    break;
                case dynamicSplit:
                    [p minDensitySearch:vars do:^(id<ORFloatVar> x) {
                        [p floatSplit:x];
                    }];
                    break;
                case dynamic3Split:
                    [p minDensitySearch:vars do:^(id<ORFloatVar> x) {
                        [p float3WaySplit:x];
                    }];
                    break;
                case dynamic5Split:
                    [p minDensitySearch:vars do:^(id<ORFloatVar> x) {
                        [p float5WaySplit:x];
                    }];
                    break;
                case dynamic6Split:
                    [p minDensitySearch:vars do:^(id<ORFloatVar> x) {
                        [p float6WaySplit:x];
                    }];
                    break;
            }
            break;
        case maxMagn :
            switch (valordering) {
                case split:
                    [p maxMagnitudeSearch:vars do:^(id<ORFloatVar> x) {
                        [p floatStaticSplit:x];
                    }];
                    break;
                case split3Way:
                    [p maxMagnitudeSearch:vars do:^(id<ORFloatVar> x) {
                        [p floatStatic3WaySplit:x];
                    }];
                    break;
                case split5Way:
                    [p maxMagnitudeSearch:vars do:^(id<ORFloatVar> x) {
                        [p floatStatic5WaySplit:x];
                    }];
                    break;
                case split6Way:
                    [p maxMagnitudeSearch:vars do:^(id<ORFloatVar> x) {
                        [p floatStatic6WaySplit:x];
                    }];
                    break;
                case dynamicSplit:
                    [p maxMagnitudeSearch:vars do:^(id<ORFloatVar> x) {
                        [p floatSplit:x];
                    }];
                    break;
                case dynamic3Split:
                    [p maxMagnitudeSearch:vars do:^(id<ORFloatVar> x) {
                        [p float3WaySplit:x];
                    }];
                    break;
                case dynamic5Split:
                    [p maxMagnitudeSearch:vars do:^(id<ORFloatVar> x) {
                        [p float5WaySplit:x];
                    }];
                    break;
                case dynamic6Split:
                    [p maxMagnitudeSearch:vars do:^(id<ORFloatVar> x) {
                        [p float6WaySplit:x];
                    }];
                    break;
            }
            break;
        case minMagn :
            switch (valordering) {
                case split:
                    [p minMagnitudeSearch:vars do:^(id<ORFloatVar> x) {
                        [p floatStaticSplit:x];
                    }];
                    break;
                case split3Way:
                    [p minMagnitudeSearch:vars do:^(id<ORFloatVar> x) {
                        [p floatStatic3WaySplit:x];
                    }];
                    break;
                case split5Way:
                    [p minMagnitudeSearch:vars do:^(id<ORFloatVar> x) {
                        [p floatStatic5WaySplit:x];
                    }];
                    break;
                case split6Way:
                    [p minMagnitudeSearch:vars do:^(id<ORFloatVar> x) {
                        [p floatStatic6WaySplit:x];
                    }];
                    break;
                case dynamicSplit:
                    [p minMagnitudeSearch:vars do:^(id<ORFloatVar> x) {
                        [p floatSplit:x];
                    }];
                    break;
                case dynamic3Split:
                    [p minMagnitudeSearch:vars do:^(id<ORFloatVar> x) {
                        [p float3WaySplit:x];
                    }];
                    break;
                case dynamic5Split:
                    [p minMagnitudeSearch:vars do:^(id<ORFloatVar> x) {
                        [p float5WaySplit:x];
                    }];
                    break;
                case dynamic6Split:
                    [p minMagnitudeSearch:vars do:^(id<ORFloatVar> x) {
                        [p float6WaySplit:x];
                    }];
                    break;
            }
            break;
        case maxDegree :
            switch (valordering) {
                case split:
                    [p maxDegreeSearch:vars do:^(id<ORFloatVar> x) {
                        [p floatStaticSplit:x];
                    }];
                    break;
                case split3Way:
                    [p maxDegreeSearch:vars do:^(id<ORFloatVar> x) {
                        [p floatStatic3WaySplit:x];
                    }];
                    break;
                case split5Way:
                    [p maxDegreeSearch:vars do:^(id<ORFloatVar> x) {
                        [p floatStatic5WaySplit:x];
                    }];
                    break;
                case split6Way:
                    [p maxDegreeSearch:vars do:^(id<ORFloatVar> x) {
                        [p floatStatic6WaySplit:x];
                    }];
                    break;
                case dynamicSplit:
                    [p maxDegreeSearch:vars do:^(id<ORFloatVar> x) {
                        [p floatSplit:x];
                    }];
                    break;
                case dynamic3Split:
                    [p maxDegreeSearch:vars do:^(id<ORFloatVar> x) {
                        [p float3WaySplit:x];
                    }];
                    break;
                case dynamic5Split:
                    [p maxDegreeSearch:vars do:^(id<ORFloatVar> x) {
                        [p float5WaySplit:x];
                    }];
                    break;
                case dynamic6Split:
                    [p maxDegreeSearch:vars do:^(id<ORFloatVar> x) {
                        [p float6WaySplit:x];
                    }];
                    break;
            }
            break;
        case minDegree :
            switch (valordering) {
                case split:
                    [p minDegreeSearch:vars do:^(id<ORFloatVar> x) {
                        [p floatStaticSplit:x];
                    }];
                    break;
                case split3Way:
                    [p minDegreeSearch:vars do:^(id<ORFloatVar> x) {
                        [p floatStatic3WaySplit:x];
                    }];
                    break;
                case split5Way:
                    [p minDegreeSearch:vars do:^(id<ORFloatVar> x) {
                        [p floatStatic5WaySplit:x];
                    }];
                    break;
                case split6Way:
                    [p minDegreeSearch:vars do:^(id<ORFloatVar> x) {
                        [p floatStatic6WaySplit:x];
                    }];
                    break;
                case dynamicSplit:
                    [p minDegreeSearch:vars do:^(id<ORFloatVar> x) {
                        [p floatSplit:x];
                    }];
                    break;
                case dynamic3Split:
                    [p minDegreeSearch:vars do:^(id<ORFloatVar> x) {
                        [p float3WaySplit:x];
                    }];
                    break;
                case dynamic5Split:
                    [p minDegreeSearch:vars do:^(id<ORFloatVar> x) {
                        [p float5WaySplit:x];
                    }];
                    break;
                case dynamic6Split:
                    [p minDegreeSearch:vars do:^(id<ORFloatVar> x) {
                        [p float6WaySplit:x];
                    }];
                    break;
            }
            break;
        case maxOcc :
            switch (valordering) {
                case split:
                    [p maxOccurencesSearch:vars do:^(id<ORFloatVar> x) {
                        [p floatStaticSplit:x];
                    }];
                    break;
                case split3Way:
                    [p maxOccurencesSearch:vars do:^(id<ORFloatVar> x) {
                        [p floatStatic3WaySplit:x];
                    }];
                    break;
                case split5Way:
                    [p maxOccurencesSearch:vars do:^(id<ORFloatVar> x) {
                        [p floatStatic5WaySplit:x];
                    }];
                    break;
                case split6Way:
                    [p maxOccurencesSearch:vars do:^(id<ORFloatVar> x) {
                        [p floatStatic6WaySplit:x];
                    }];
                    break;
                case dynamicSplit:
                    [p maxOccurencesSearch:vars do:^(id<ORFloatVar> x) {
                        [p floatSplit:x];
                    }];
                    break;
                case dynamic3Split:
                    [p maxOccurencesSearch:vars do:^(id<ORFloatVar> x) {
                        [p float3WaySplit:x];
                    }];
                    break;
                case dynamic5Split:
                    [p maxOccurencesSearch:vars do:^(id<ORFloatVar> x) {
                        [p float5WaySplit:x];
                    }];
                    break;
                case dynamic6Split:
                    [p maxOccurencesSearch:vars do:^(id<ORFloatVar> x) {
                        [p float6WaySplit:x];
                    }];
                    break;
            }
            break;
        case minOcc :
            switch (valordering) {
                case split:
                    [p minOccurencesSearch:vars do:^(id<ORFloatVar> x) {
                        [p floatStaticSplit:x];
                    }];
                    break;
                case split3Way:
                    [p minOccurencesSearch:vars do:^(id<ORFloatVar> x) {
                        [p floatStatic3WaySplit:x];
                    }];
                    break;
                case split5Way:
                    [p minOccurencesSearch:vars do:^(id<ORFloatVar> x) {
                        [p floatStatic5WaySplit:x];
                    }];
                    break;
                case split6Way:
                    [p minOccurencesSearch:vars do:^(id<ORFloatVar> x) {
                        [p floatStatic6WaySplit:x];
                    }];
                    break;
                case dynamicSplit:
                    [p minOccurencesSearch:vars do:^(id<ORFloatVar> x) {
                        [p floatSplit:x];
                    }];
                    break;
                case dynamic3Split:
                    [p minOccurencesSearch:vars do:^(id<ORFloatVar> x) {
                        [p float3WaySplit:x];
                    }];
                    break;
                case dynamic5Split:
                    [p minOccurencesSearch:vars do:^(id<ORFloatVar> x) {
                        [p float5WaySplit:x];
                    }];
                    break;
                case dynamic6Split:
                    [p minOccurencesSearch:vars do:^(id<ORFloatVar> x) {
                        [p float6WaySplit:x];
                    }];
                    break;
            }
            break;
        case maxAbs :
            switch (valordering) {
                case split:
                    [p maxAbsorptionSearch:vars do:^(id<ORFloatVar> x) {
                        [p floatStaticSplit:x];
                    }];
                    break;
                case split3Way:
                    [p maxAbsorptionSearch:vars do:^(id<ORFloatVar> x) {
                        [p floatStatic3WaySplit:x];
                    }];
                    break;
                case split5Way:
                    [p maxAbsorptionSearch:vars do:^(id<ORFloatVar> x) {
                        [p floatStatic5WaySplit:x];
                    }];
                    break;
                case split6Way:
                    [p maxAbsorptionSearch:vars do:^(id<ORFloatVar> x) {
                        [p floatStatic6WaySplit:x];
                    }];
                    break;
                case dynamicSplit:
                    [p maxAbsorptionSearch:vars do:^(id<ORFloatVar> x) {
                        [p floatSplit:x];
                    }];
                    break;
                case dynamic3Split:
                    [p maxAbsorptionSearch:vars do:^(id<ORFloatVar> x) {
                        [p float3WaySplit:x];
                    }];
                    break;
                case dynamic5Split:
                    [p maxAbsorptionSearch:vars do:^(id<ORFloatVar> x) {
                        [p float5WaySplit:x];
                    }];
                    break;
                case dynamic6Split:
                    [p maxAbsorptionSearch:vars do:^(id<ORFloatVar> x) {
                        [p float6WaySplit:x];
                    }];
                    break;
            }
            break;
        case minAbs :
            switch (valordering) {
                case split:
                    [p minAbsorptionSearch:vars do:^(id<ORFloatVar> x) {
                        [p floatStaticSplit:x];
                    }];
                    break;
                case split3Way:
                    [p minAbsorptionSearch:vars do:^(id<ORFloatVar> x) {
                        [p floatStatic3WaySplit:x];
                    }];
                    break;
                case split5Way:
                    [p minAbsorptionSearch:vars do:^(id<ORFloatVar> x) {
                        [p floatStatic5WaySplit:x];
                    }];
                    break;
                case split6Way:
                    [p minAbsorptionSearch:vars do:^(id<ORFloatVar> x) {
                        [p floatStatic6WaySplit:x];
                    }];
                    break;
                case dynamicSplit:
                    [p minAbsorptionSearch:vars do:^(id<ORFloatVar> x) {
                        [p floatSplit:x];
                    }];
                    break;
                case dynamic3Split:
                    [p minAbsorptionSearch:vars do:^(id<ORFloatVar> x) {
                        [p float3WaySplit:x];
                    }];
                    break;
                case dynamic5Split:
                    [p minAbsorptionSearch:vars do:^(id<ORFloatVar> x) {
                        [p float5WaySplit:x];
                    }];
                    break;
                case dynamic6Split:
                    [p minAbsorptionSearch:vars do:^(id<ORFloatVar> x) {
                        [p float6WaySplit:x];
                    }];
                    break;
            }
            break;
        case maxCan :
            switch (valordering) {
                case split:
                    [p maxCancellationSearch:vars do:^(id<ORFloatVar> x) {
                        [p floatStaticSplit:x];
                    }];
                    break;
                case split3Way:
                    [p maxCancellationSearch:vars do:^(id<ORFloatVar> x) {
                        [p floatStatic3WaySplit:x];
                    }];
                    break;
                case split5Way:
                    [p maxCancellationSearch:vars do:^(id<ORFloatVar> x) {
                        [p floatStatic5WaySplit:x];
                    }];
                    break;
                case split6Way:
                    [p maxCancellationSearch:vars do:^(id<ORFloatVar> x) {
                        [p floatStatic6WaySplit:x];
                    }];
                    break;
                case dynamicSplit:
                    [p maxCancellationSearch:vars do:^(id<ORFloatVar> x) {
                        [p floatSplit:x];
                    }];
                    break;
                case dynamic3Split:
                    [p maxCancellationSearch:vars do:^(id<ORFloatVar> x) {
                        [p float3WaySplit:x];
                    }];
                    break;
                case dynamic5Split:
                    [p maxCancellationSearch:vars do:^(id<ORFloatVar> x) {
                        [p float5WaySplit:x];
                    }];
                    break;
                case dynamic6Split:
                    [p maxCancellationSearch:vars do:^(id<ORFloatVar> x) {
                        [p float6WaySplit:x];
                    }];
                    break;
            }
            break;
        case minCan :
            switch (valordering) {
                case split:
                    [p minCancellationSearch:vars do:^(id<ORFloatVar> x) {
                        [p floatStaticSplit:x];
                    }];
                    break;
                case split3Way:
                    [p minCancellationSearch:vars do:^(id<ORFloatVar> x) {
                        [p floatStatic3WaySplit:x];
                    }];
                    break;
                case split5Way:
                    [p minCancellationSearch:vars do:^(id<ORFloatVar> x) {
                        [p floatStatic5WaySplit:x];
                    }];
                    break;
                case split6Way:
                    [p minCancellationSearch:vars do:^(id<ORFloatVar> x) {
                        [p floatStatic6WaySplit:x];
                    }];
                    break;
                case dynamicSplit:
                    [p minCancellationSearch:vars do:^(id<ORFloatVar> x) {
                        [p floatSplit:x];
                    }];
                    break;
                case dynamic3Split:
                    [p minCancellationSearch:vars do:^(id<ORFloatVar> x) {
                        [p float3WaySplit:x];
                    }];
                    break;
                case dynamic5Split:
                    [p minCancellationSearch:vars do:^(id<ORFloatVar> x) {
                        [p float5WaySplit:x];
                    }];
                    break;
                case dynamic6Split:
                    [p minCancellationSearch:vars do:^(id<ORFloatVar> x) {
                        [p float6WaySplit:x];
                    }];
                    break;
            }
            break;
        case absWDens :
            switch (valordering) {
                case split:
                    [p combinedAbsWithDensSearch:vars do:^(id<ORFloatVar> x) {
                        [p floatStaticSplit:x];
                    }];
                    break;
                case split3Way:
                    [p combinedAbsWithDensSearch:vars do:^(id<ORFloatVar> x) {
                        [p floatStatic3WaySplit:x];
                    }];
                    break;
                case split5Way:
                    [p combinedAbsWithDensSearch:vars do:^(id<ORFloatVar> x) {
                        [p floatStatic5WaySplit:x];
                    }];
                    break;
                case split6Way:
                    [p combinedAbsWithDensSearch:vars do:^(id<ORFloatVar> x) {
                        [p floatStatic6WaySplit:x];
                    }];
                    break;
                case dynamicSplit:
                    [p combinedAbsWithDensSearch:vars do:^(id<ORFloatVar> x) {
                        [p floatSplit:x];
                    }];
                    break;
                case dynamic3Split:
                    [p combinedAbsWithDensSearch:vars do:^(id<ORFloatVar> x) {
                        [p float3WaySplit:x];
                    }];
                    break;
                case dynamic5Split:
                    [p combinedAbsWithDensSearch:vars do:^(id<ORFloatVar> x) {
                        [p float5WaySplit:x];
                    }];
                    break;
                case dynamic6Split:
                    [p combinedAbsWithDensSearch:vars do:^(id<ORFloatVar> x) {
                        [p float6WaySplit:x];
                    }];
                    break;
            }
            break;
        case densWAbs :
            switch (valordering) {
                case split:
                    [p combinedDensWithAbsSearch:vars do:^(id<ORFloatVar> x) {
                        [p floatStaticSplit:x];
                    }];
                    break;
                case split3Way:
                    [p combinedDensWithAbsSearch:vars do:^(id<ORFloatVar> x) {
                        [p floatStatic3WaySplit:x];
                    }];
                    break;
                case split5Way:
                    [p combinedDensWithAbsSearch:vars do:^(id<ORFloatVar> x) {
                        [p floatStatic5WaySplit:x];
                    }];
                    break;
                case split6Way:
                    [p combinedDensWithAbsSearch:vars do:^(id<ORFloatVar> x) {
                        [p floatStatic6WaySplit:x];
                    }];
                    break;
                case dynamicSplit:
                    [p combinedDensWithAbsSearch:vars do:^(id<ORFloatVar> x) {
                        [p floatSplit:x];
                    }];
                    break;
                case dynamic3Split:
                    [p combinedDensWithAbsSearch:vars do:^(id<ORFloatVar> x) {
                        [p float3WaySplit:x];
                    }];
                    break;
                case dynamic5Split:
                    [p combinedDensWithAbsSearch:vars do:^(id<ORFloatVar> x) {
                        [p float5WaySplit:x];
                    }];
                    break;
                case dynamic6Split:
                    [p combinedDensWithAbsSearch:vars do:^(id<ORFloatVar> x) {
                        [p float6WaySplit:x];
                    }];
                    break;
            }
            break;
        default :
            heuristic = lexico;
            switch (valordering) {
                case split:
                    [p lexicalOrderedSearch:vars do:^(id<ORFloatVar> x) {
                        [p floatStaticSplit:x];
                    }];
                    break;
                case split3Way:
                    [p lexicalOrderedSearch:vars do:^(id<ORFloatVar> x) {
                        [p floatStatic3WaySplit:x];
                    }];
                    break;
                case split5Way:
                    [p lexicalOrderedSearch:vars do:^(id<ORFloatVar> x) {
                        [p floatStatic5WaySplit:x];
                    }];
                    break;
                case split6Way:
                    [p lexicalOrderedSearch:vars do:^(id<ORFloatVar> x) {
                        [p floatStatic6WaySplit:x];
                    }];
                    break;
                case dynamicSplit:
                    heuristic = ref;
                    [p lexicalOrderedSearch:vars do:^(id<ORFloatVar> x) {
                        [p floatSplit:x];
                    }];
                    break;
                case dynamic3Split:
                    [p lexicalOrderedSearch:vars do:^(id<ORFloatVar> x) {
                        [p float3WaySplit:x];
                    }];
                    break;
                case dynamic5Split:
                    [p lexicalOrderedSearch:vars do:^(id<ORFloatVar> x) {
                        [p float5WaySplit:x];
                    }];
                    break;
                case dynamic6Split:
                    [p lexicalOrderedSearch:vars do:^(id<ORFloatVar> x) {
                        [p float6WaySplit:x];
                    }];
                    break;
            }
            break;
    }
}


@end
