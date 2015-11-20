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
static NSString* hName[] = {@"FF",@"ABS",@"IBS",@"WDeg",@"DDeg"};
@synthesize size;
@synthesize restartRate;
@synthesize timeOut;
@synthesize randomized;
@synthesize heuristic;
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
   heuristic = FF;
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
   }
   return self;
}
-(NSString*)heuristicName
{
   return hName[heuristic];
}
-(void)measure:(struct ORResult(^)())block
{
   mallocWatch();
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
   printf("FMT:heur,rand,threads,size,found,restartRate,#f,#c,#p,cpu,wc,mUsed,mPeak\n");
   printf("OUT:%s,%d,%d,%d,%d,%f,%d,%d,%d,%lld,%lld,%s\n",[[self heuristicName] cStringUsingEncoding:NSASCIIStringEncoding],
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
   }
   return h;
}
@end
