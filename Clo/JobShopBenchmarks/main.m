//
//  main.m
//  JobShopBenchmarks
//
//  Created by Daniel Fontaine on 11/14/15.
//
//

#import <Foundation/Foundation.h>
#import <ORFoundation/ORFoundation.h>
#import <ORUtilities/ORUtilities.h>
#import <ORModeling/ORModeling.h>
#import <ORProgram/ORProgram.h>
#import <ORScheduler/ORScheduler.h>
#import <ORSchedulingProgram/ORSchedulingProgram.h>
#import <ORProgram/ORRunnable.h>
#import <ORModeling/ORLinearize.h>

 #include <unistd.h>


void fill(FILE* data,id<ORIntRange> Jobs,id<ORIntRange> Machines,id<ORIntMatrix> duration,id<ORIntMatrix> resource)
{
    ORInt tmp;
    for(ORInt i = Jobs.low; i <= Jobs.up; i++) {
        for(ORInt j = Machines.low; j <= Machines.up; j++) {
            fscanf(data, "%d",&tmp);
            [resource set: tmp at: i : j];
            fscanf(data, "%d",&tmp);
            [duration set: tmp at: i : j];
        }
    }
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
//        if(argc < 2) {
//            NSLog(@"jspbenchmarks [technology] filepath");
//            return -1;
//        }
        NSMutableArray* args = [[NSMutableArray alloc] initWithCapacity: argc];
        for(int i = 0; i < argc; i++) [args addObject: [NSString stringWithCString: argv[i] encoding: NSASCIIStringEncoding]];
        
        BOOL doCP = NO;
        BOOL doMIP = NO;
        BOOL doHybrid = NO;
        BOOL doHybridLNS = NO;
        BOOL doHybridLNS_CP = NO;
        BOOL doBDS = NO;
        BOOL doCPSCP = NO;
        BOOL doLNS = NO;
        ORInt numThreads = 2;
	ORInt tL = 300;
        
        if([args containsObject: @"-cp"]) doCP = YES;
        if([args containsObject: @"-mip"]) doMIP = YES;
        if([args containsObject: @"-cp-mip"]) doHybrid = YES;
        if([args containsObject: @"-lns-mip"]) doHybridLNS = YES;
        if([args containsObject: @"-lns-cp"]) doHybridLNS_CP = YES;
        if([args containsObject: @"-bds"]) doBDS = YES;
        if([args containsObject: @"-cps-cp"]) doCPSCP = YES;
        if([args containsObject: @"-lns"]) doLNS = YES;
	if([args containsObject: @"-t0"]) numThreads = 0;
        if([args containsObject: @"-t1"]) numThreads = 1;
        if([args containsObject: @"-t2"]) numThreads = 2;
        if([args containsObject: @"-t4"]) numThreads = 4;
        if([args containsObject: @"-t5"]) numThreads = 5;
        if([args containsObject: @"-t6"]) numThreads = 6;
        if([args containsObject: @"-t8"]) numThreads = 8;
	if([args containsObject: @"-t16"]) numThreads = 16;
	if([args containsObject: @"-t32"]) numThreads = 32;
	if([args containsObject: @"-b30"]) tL = 30;
	if([args containsObject: @"-b60"]) tL = 60;
	if([args containsObject: @"-b300"]) tL = 300;
	if([args containsObject: @"-b600"]) tL = 600;
	if([args containsObject: @"-b3600"]) tL = 3600;
	if([args containsObject: @"-b36000"]) tL = 36000;
       
        char home[512];
	strcpy(home,getenv("HOME"));
	char  fNameBuf[1024];
       
       
        
        NSString* path = [args lastObject];

        FILE* data = fopen([path cStringUsingEncoding: NSASCIIStringEncoding], "r");
        //FILE* data = fopen("orb10.jss","r");
        
        ORInt nbJobs, nbMachines;
        fscanf(data, "%d",&nbJobs);
        fscanf(data, "%d",&nbMachines);
        
        NSLog(@" nbJobs: %d nbMachines: %d",nbJobs,nbMachines);
        [ORStreamManager setRandomized];
        id<ORModel> model = [ORFactory createModel];
        
        // data
        
        id<ORIntRange> Jobs = [ORFactory intRange: model low: 0 up: nbJobs-1];
        id<ORIntRange> Machines = [ORFactory intRange: model low: 0 up: nbMachines-1];
        id<ORIntMatrix> duration = [ORFactory intMatrix: model range: Jobs : Machines];
        id<ORIntMatrix> resource = [ORFactory intMatrix: model range: Jobs : Machines];
        fill(data,Jobs,Machines,duration,resource);
        fclose(data);
        
        ORInt totalDuration = 0;
        for(ORInt i = Jobs.low; i <= Jobs.up; i++)
            for(ORInt j = Machines.low; j <= Machines.up; j++)
                totalDuration += [duration at: i : j];
        id<ORIntRange> Horizon = RANGE(model,0,totalDuration);
        
        // variables
        
        id<ORTaskVarMatrix> task = [ORFactory taskVarMatrix: model range: Jobs : Machines horizon: Horizon duration: duration];
        id<ORIntVar> makespan = [ORFactory intVar: model domain: RANGE(model,0,totalDuration)];
        id<ORTaskDisjunctiveArray> disjunctive = [ORFactory disjunctiveArray: model range: Machines];
        
        // model
        
        [model minimize: makespan];
        
        for(ORInt i = Jobs.low; i <= Jobs.up; i++)
            for(ORInt j = Machines.low; j < Machines.up; j++)
                [model add: [[task at: i : j] precedes: [ task at: i : j+1]]];
        
        for(ORInt i = Jobs.low; i <= Jobs.up; i++)
            [model add: [[task at: i : Machines.up] isFinishedBy: makespan]];
        
        for(ORInt i = Jobs.low; i <= Jobs.up; i++)
            for(ORInt j = Machines.low; j <= Machines.up; j++)
                [disjunctive[[resource at: i : j]] add: [ task at: i : j]];
        
        for(ORInt i =Machines.low; i <= Machines.up; i++)
            [model add: disjunctive[i]];
        
        // Solve CP
        if(doCP) {
           *fNameBuf = 0;
           strcat(strcpy(fNameBuf, home),"/Desktop/cpout.txt");
            FILE* outFile = fopen(fNameBuf, "w+");
            id<ORAnnotation> notes = [ORFactory annotation];
            id<CPProgram,CPScheduler> cp = nil;
            
            if(numThreads > 0)
                cp = (id)[ORFactory createCPParProgram:model nb: numThreads annotation: notes with:[ORSemDFSController proto]];
            else cp = (id)[ORFactory createCPProgram: model];
            
            ORLong timeStart = [ORRuntimeMonitor wctime];
            [cp solve: ^{
		[cp limitTime:1000L * tL in:^{
                  [cp forall: Machines orderedBy: ^ORInt(ORInt i) {
                        return [cp globalSlack: disjunctive[i]] +
                               ([cp localSlack: disjunctive[i]] << 16);} do: ^(ORInt i) {
                     id<ORTaskVarArray> t = disjunctive[i].taskVars;
                     [cp sequence: disjunctive[i].successors
                               by: ^ORDouble(ORInt i) { return [cp est: t[i]]; }
                             then: ^ORDouble(ORInt i) { return [cp ect: t[i]];}];
                  }];
                  [cp label: makespan];
                  NSLog(@"(%d) makespan = [%d,%d] \n",[NSThread threadID],[cp min: makespan],[cp max: makespan]);
                  fprintf(outFile, "%f %i\n", ([ORRuntimeMonitor wctime] - timeStart) / 1000.0, [cp min: makespan]);
                  fflush(outFile);
               }];
            }];
            
            fclose(outFile);
            
            ORLong timeEnd = [ORRuntimeMonitor wctime];
            NSLog(@"Time: %lld",timeEnd - timeStart);
            id<ORSolutionPool> pool = [cp solutionPool];
            id<ORSolution> optimum = [pool best];
            NSLog(@"!! CP makespan: %d \n",[optimum intValue: makespan]);
        }
        
        if(doMIP) {
            // Linearize
            id<ORModel> lm = [ORFactory linearizeSchedulingModel: model encoding: MIPSchedDisjunctive];
            id<ORRunnable> r = nil;
            if(numThreads > 0)
               r = [ORFactory MIPRunnable: lm numThreads: numThreads];
            else r = [ORFactory MIPRunnable: lm];
            ORLong timeStart = [ORRuntimeMonitor wctime];
            [r run];
            ORLong timeEnd = [ORRuntimeMonitor wctime];
            NSLog(@"Time: %lld",timeEnd - timeStart);
            id<ORSolution> optimum = [r bestSolution];
            NSLog(@"!! MIP makespan: %d \n",[optimum intValue: makespan]);
        }
        
        if(doHybrid) {
            id<ORModel> lm = [ORFactory linearizeSchedulingModel: model encoding: MIPSchedDisjunctive];
            id<ORRunnable> r0 = [ORFactory CPRunnable: model numThreads:numThreads/2 solve: ^(id<CPCommonProgram> program){
                id<CPProgram,CPScheduler> cp = (id<CPProgram,CPScheduler>)program;
                NSLog(@"MKS: %@n\n",[cp concretize:makespan]);
                [cp forall: Machines orderedBy: ^ORInt(ORInt i) { return
		      [cp globalSlack: disjunctive[i]] + ([cp localSlack: disjunctive[i]] << 16);
		  } do: ^(ORInt i) {
                    id<ORTaskVarArray> t = disjunctive[i].taskVars;
                    [cp sequence: disjunctive[i].successors
                              by: ^ORDouble(ORInt i) { return [cp est: t[i]]; }
                            then: ^ORDouble(ORInt i) { return [cp ect: t[i]];}];
                }];
                [cp label: makespan];
                NSLog(@"makespan = [%d,%d] \n",[cp min: makespan],[cp max: makespan]);
            }];
            id<ORRunnable> r1 = [ORFactory MIPRunnable: lm numThreads:numThreads/2];
            id<ORRunnable> r =  [ORFactory composeCompleteParallel: r0 with: r1];
            ORLong timeStart = [ORRuntimeMonitor wctime];
            [r run];
            ORLong timeEnd = [ORRuntimeMonitor wctime];
            NSLog(@"Time: %lld",timeEnd - timeStart);
            id<ORSolution> optimum = [r bestSolution];
            NSLog(@"!! CP/MIP makespan: %d \n",[optimum intValue: makespan]);
        }
        
        if(doHybridLNS) {
            id<ORModel> lm = [ORFactory linearizeSchedulingModel: model encoding: MIPSchedDisjunctive];
            ORLong timeStart = [ORRuntimeMonitor wctime];
            id<ORRunnable> r0 = [ORFactory CPRunnable: model numThreads:numThreads/2 solve: ^(id<CPCommonProgram> program){
                id<CPProgram,CPScheduler> cp = (id<CPProgram,CPScheduler>)program;
                id<ORUniformDistribution> sM = [ORFactory uniformDistribution:model range: Machines];
                id<ORUniformDistribution> sD = [ORFactory uniformDistribution:model range: Jobs];
                id<ORUniformDistribution> lD = [ORFactory uniformDistribution:model range:RANGE(model,2,nbMachines/5)];
                [cp repeat: ^{
                    [cp limitFailures: 3 *nbJobs * nbMachines in: ^{
                        [cp forall: Machines orderedBy: ^ORInt(ORInt i) { return 1000 * [cp globalSlack: disjunctive[i]] + [cp localSlack: disjunctive[i]]; } do: ^(ORInt i) {
                            id<ORTaskVarArray> t = disjunctive[i].taskVars;
                            [cp sequence: disjunctive[i].successors by: ^ORDouble(ORInt i) { return [cp ect: t[i]]; } then: ^ORDouble(ORInt i) { return [cp est: t[i]];}];
                        }];
                        [cp label: makespan];
                        NSLog(@"\nLNSLNSLNSLNSLNS ******************* ----> makespan = [%d,%d] \n",[cp min: makespan],[cp max: makespan]);
                        ORLong timeEnd = [ORRuntimeMonitor wctime];
                        NSLog(@"Time: %lld:",timeEnd - timeStart);
                    }];
                }
                  onRepeat: ^{
                      id<ORSolution,ORSchedulerSolution> sol = (id) [[cp solutionPool] best];
                      for(ORInt k = 1; k <= 2; k++) {
                          ORInt i = [sM next];
                          id<ORIntVarArray> succ = disjunctive[i].successors;
                          id<ORTaskVarArray> t = disjunctive[i].taskVars;
                          ORInt st = [sD next];
                          ORInt d = [lD next];
                          ORInt en = st + d;
                          // need to fix everything outside the bounds but the tight constraints
                          ORInt j = 0;
                          ORInt curr = 0;
                          while (curr <= succ.up) {
                              if ((j < st || j >= en)) {
                                  ORInt n = [sol intValue: succ[curr]];
                                  if (n != nbJobs + 1) {
                                      ORInt est = [sol ect: t[n]];
                                      ORInt ect = [sol ect: t[n]];
                                      ORInt duration = [sol minDuration: t[n]];
                                      if (est + duration != ect)
                                          [cp label: succ[curr] with: [sol intValue: succ[curr]]];
                                  }
                              }
                              j++;
                              curr = [sol intValue: succ[curr]];
                          }
                      }
                      //NSLog(@"R");
                  }];
            }];
            id<ORRunnable> r1 = [ORFactory MIPRunnable: lm numThreads:numThreads/2];
            id<ORRunnable> r = [ORFactory composeCompleteParallel: r0 with: r1];
            [r run];
            ORLong timeEnd = [ORRuntimeMonitor wctime];
            NSLog(@"Time: %lld",timeEnd - timeStart);
            id<ORSolution> optimum = [r bestSolution];
            NSLog(@"!! LNS/MIP makespan: %d \n",[optimum intValue: makespan]);
        }
        
        if(doHybridLNS_CP) {
           id<ORRunnable> r0 = [ORFactory CPRunnable: model numThreads:numThreads/2 solve: ^(id<CPCommonProgram> program){
                id<CPProgram,CPScheduler> cp = (id<CPProgram,CPScheduler>)program;
                id<ORUniformDistribution> sM = [ORFactory uniformDistribution:model range: Machines];
                id<ORUniformDistribution> sD = [ORFactory uniformDistribution:model range: Jobs];
                id<ORUniformDistribution> lD = [ORFactory uniformDistribution:model range:RANGE(model,2,max(2,nbMachines/5))];
                [cp repeat: ^{
                    [cp limitFailures: 3 *nbJobs * nbMachines in: ^{
                        [cp forall: Machines orderedBy: ^ORInt(ORInt i) { return 100 * [cp globalSlack: disjunctive[i]] + ([cp localSlack: disjunctive[i]]); }
                                do: ^(ORInt i) {
                            id<ORTaskVarArray> t = disjunctive[i].taskVars;
                            [cp sequence: disjunctive[i].successors by: ^ORDouble(ORInt i) { return [cp ect: t[i]]; } then: ^ORDouble(ORInt i) { return [cp est: t[i]];}];
                        }];
                        [cp label: makespan];
                        NSLog(@"---------------------------------------------(%p) LNS makespan = [%d,%d] (THREAD:%d)  %p\n",cp, [cp min: makespan],[cp max: makespan],[NSThread threadID],[NSThread currentThread]);
                    }];
                }
                  onRepeat: ^{
                      id<ORSolution,ORSchedulerSolution> sol = (id) [[cp solutionPool] best];
                      if (sol==nil) return;
                      for(ORInt k = 1; k <= 2; k++) {
                          ORInt i = [sM next];
                          id<ORIntVarArray> succ = disjunctive[i].successors;
                          id<ORTaskVarArray> t = disjunctive[i].taskVars;
                          ORInt st = [sD next];
                          ORInt d = [lD next];
                          ORInt en = st + d;
                          // need to fix everything outside the bounds but the tight constraints
                          ORInt j = 0;
                          ORInt curr = 0;
                          while (curr <= succ.up) {
                              if ((j < st || j >= en)) {
                                  ORInt n = [sol intValue: succ[curr]];
                                  if (n != nbJobs + 1) {
                                      ORInt est = [sol ect: t[n]];
                                      ORInt ect = [sol ect: t[n]];
                                      ORInt duration = [sol minDuration: t[n]];
                                      if (est + duration != ect)
                                          [cp label: succ[curr] with: [sol intValue: succ[curr]]];
                                  }
                              }
                              j++;
                              curr = [sol intValue: succ[curr]];
                          }
                      }
                     printf("R(%d)",[NSThread threadID]);fflush(stdout);
                  }];
            }];
            strcat(strcpy(fNameBuf, home),"/Desktop/cpout.txt");
            FILE* outFile = fopen(fNameBuf, "w+");
            ORLong timeStart = [ORRuntimeMonitor wctime];
            id<ORRunnable> r1 = [ORFactory CPRunnable: model numThreads:numThreads/2 solve: ^(id<CPCommonProgram> program){
                id<CPProgram,CPScheduler> cp = (id<CPProgram,CPScheduler>)program;
                //NSLog(@"MKS: %@\n",[cp concretize:makespan]);
                [cp forall: Machines orderedBy: ^ORInt(ORInt i) { return [cp globalSlack: disjunctive[i]] + 1000 * [cp localSlack: disjunctive[i]];} do: ^(ORInt i) {
                    id<ORTaskVarArray> t = disjunctive[i].taskVars;
                    [cp sequence: disjunctive[i].successors
                              by: ^ORDouble(ORInt i) { return [cp est: t[i]]; }
                            then: ^ORDouble(ORInt i) { return [cp ect: t[i]];}];
                }];
                [cp label: makespan];
                NSLog(@"---------------------------------------------(%p) PURE makespan = [%d,%d] (THREAD:%d) %p \n",cp, [cp min: makespan],[cp max: makespan],[NSThread threadID],[NSThread currentThread]);
                fprintf(outFile, "%f %i\n", ([ORRuntimeMonitor wctime] - timeStart) / 1000.0, [cp min: makespan]);
                fflush(outFile);
            }];
            
            id<ORRunnable> r = [ORFactory composeCompleteParallel: r0 with: r1];
            [r run];
            fclose(outFile);
            ORLong timeEnd = [ORRuntimeMonitor wctime];
            NSLog(@"Time: %lld",timeEnd - timeStart);
            id<ORSolution> optimum = [r bestSolution];
            NSLog(@"!! LNS/CP makespan: %d \n",[optimum intValue: makespan]);
        }
        
        
        if(doBDS) {
            *fNameBuf = 0;
            strcat(strcpy(fNameBuf, home),"/Desktop/cpout.txt");
            FILE* outFile = fopen(fNameBuf, "w+");
            id<ORAnnotation> notes = [ORFactory annotation];
            id<CPProgram,CPScheduler> cp = nil;
            cp = //(id)[ORFactory createCPParProgram:model nb: numThreads annotation: notes with:[ORSemBDSController class]];
            (id)[ORFactory  createCPSemanticProgram:model
                                         annotation:notes
                                               with:[ORSemBDSController proto]];
            ORLong timeStart = [ORRuntimeMonitor wctime];
            [cp solve: ^{
                NSLog(@"MKS: %@\n",[cp concretize:makespan]);
                //id<ORIntVarArray> av = [model intVars];
                //[cp labelArrayFF:av];
                //[cp splitArray:av];
                
                [cp forall: Machines orderedBy: ^ORInt(ORInt i) {
                    ORInt gs = [cp globalSlack: disjunctive[i]];
                    ORInt ls = [cp localSlack: disjunctive[i]];
                    return  gs + (ls << 16);
                } do: ^(ORInt i) {
                    id<ORTaskVarArray> t = disjunctive[i].taskVars;
                    [cp sequence: disjunctive[i].successors
                              by: ^ORDouble(ORInt i) { return i <= t.up ? [cp est: t[i]] : MAXDBL;}
                            then: ^ORDouble(ORInt i) { return i <= t.up ? [cp ect: t[i]] : MAXDBL;}];
                }];
                [cp label: makespan];
                printf("(%d)\tmakespan = [%d,%d] \n",[NSThread threadID],[cp min: makespan],[cp max: makespan]);
                fprintf(outFile, "%f %i\n", ([ORRuntimeMonitor wctime] - timeStart) / 1000.0, [cp min: makespan]);
                fflush(outFile);
            }];
            
            fclose(outFile);
            
            ORLong timeEnd = [ORRuntimeMonitor wctime];
            NSLog(@"Time: %lld",timeEnd - timeStart);
            id<ORSolutionPool> pool = [cp solutionPool];
            id<ORSolution> optimum = [pool best];
            NSLog(@"!! BDS makespan: %d \n",[optimum intValue: makespan]);
        }
       if (doCPSCP) {
         id<ORRunnable> r0 = [ORFactory CPRunnable: model solve: ^(id<CPCommonProgram> program) {
            id<CPProgram,CPScheduler> cp = (id<CPProgram,CPScheduler>)program;
            [cp forall: Machines orderedBy: ^ORInt(ORInt i) { return [cp globalSlack: disjunctive[i]] + 1000 * [cp localSlack: disjunctive[i]]; } do: ^(ORInt i) {
               id<ORTaskVarArray> t = disjunctive[i].taskVars;
               [cp sequence: disjunctive[i].successors
                         by: ^ORDouble(ORInt i) { return i <= t.up ? [cp est: t[i]] : MAXDBL;}
                       then: ^ORDouble(ORInt i) { return i <= t.up ? [cp ect: t[i]] : MAXDBL;}];
            }];
            [cp label: makespan];
            NSLog(@"(SEQ   )makespan = [%d,%d] \n",[cp min: makespan],[cp max: makespan]);
         }];
          *fNameBuf = 0;
          strcat(strcpy(fNameBuf, home),"/Desktop/cpout.txt");
         FILE* outFile = fopen(fNameBuf, "w+");
          ORLong timeStart = [ORRuntimeMonitor wctime];
          id<ORRunnable> r1 = [ORFactory CPRunnable: model  numThreads:numThreads solve: ^(id<CPCommonProgram> program){
             id<CPProgram,CPScheduler> cp = (id<CPProgram,CPScheduler>)program;
             [cp forall: Machines orderedBy: ^ORInt(ORInt i) { return [cp globalSlack: disjunctive[i]] + 1000 * [cp localSlack: disjunctive[i]];} do: ^(ORInt i) {
                id<ORTaskVarArray> t = disjunctive[i].taskVars;
                [cp sequence: disjunctive[i].successors
                          by: ^ORDouble(ORInt i) { return i <= t.up ? [cp est: t[i]] : MAXDBL;}
                        then: ^ORDouble(ORInt i) { return i <= t.up ? [cp ect: t[i]] : MAXDBL;}];
             }];
             [cp label: makespan];
             NSLog(@"(PAR:%2d)makespan = [%d,%d] \n",[NSThread threadID],[cp min: makespan],[cp max: makespan]);
             fprintf(outFile, "%f %i\n", ([ORRuntimeMonitor wctime] - timeStart) / 1000.0, [cp min: makespan]);
             fflush(outFile);
          }];
          
          id<ORRunnable> r = [ORFactory composeCompleteParallel: r0 with: r1];
          [r run];
          fclose(outFile);
          ORLong timeEnd = [ORRuntimeMonitor wctime];
          NSLog(@"Time: %lld",timeEnd - timeStart);
          id<ORSolution> optimum = [r bestSolution];
          NSLog(@"!! CPS/CP makespan: %d \n",[optimum intValue: makespan]);
       }
       
        if(doLNS){
            id<ORAnnotation> notes = [ORFactory annotation];
            id<CPProgram,CPScheduler> cp = nil;
            
            if(numThreads > 0)
                cp = (id)[ORFactory createCPParProgram:model nb: numThreads annotation: notes with:[ORSemDFSController proto]];
            else cp = (id)[ORFactory createCPProgram: model];
            
           *fNameBuf = 0;
           strcat(strcpy(fNameBuf, home),"/Desktop/cpout.txt");

           FILE* outFile = fopen(fNameBuf, "w+");
            ORLong timeStart = [ORRuntimeMonitor wctime];
            [cp solve: ^{
                id<ORUniformDistribution> sM = [ORFactory uniformDistribution:model range: Machines];
                id<ORUniformDistribution> sD = [ORFactory uniformDistribution:model range: Jobs];
                id<ORUniformDistribution> lD = [ORFactory uniformDistribution:model range:RANGE(model,2,nbMachines/5)];
                [cp repeat: ^{
                    [cp limitFailures: 3 *nbJobs * nbMachines in: ^{
                        [cp forall: Machines orderedBy: ^ORInt(ORInt i) { return 10 * [cp globalSlack: disjunctive[i]] + [cp localSlack: disjunctive[i]]; } do: ^(ORInt i) {
                            id<ORTaskVarArray> t = disjunctive[i].taskVars;
                            [cp sequence: disjunctive[i].successors by: ^ORDouble(ORInt i) { return [cp ect: t[i]]; } then: ^ORDouble(ORInt i) { return [cp est: t[i]];}];
                        }];
                        [cp label: makespan];
                        NSLog(@"\nmakespan = [%d,%d] \n",[cp min: makespan],[cp max: makespan]);
                        ORLong timeEnd = [ORRuntimeMonitor wctime];
                        NSLog(@"Time: %lld:",timeEnd - timeStart);
                    }];
                }
                  onRepeat: ^{
                      id<ORSolution,ORSchedulerSolution> sol = (id) [[cp solutionPool] best];
                      for(ORInt k = 1; k <= 2; k++) {
                          ORInt i = [sM next];
                          id<ORIntVarArray> succ = disjunctive[i].successors;
                          id<ORTaskVarArray> t = disjunctive[i].taskVars;
                          ORInt st = [sD next];
                          ORInt d = [lD next];
                          ORInt en = st + d;
                          // need to fix everything outside the bounds but the tight constraints
                          ORInt j = 0;
                          ORInt curr = 0;
                          while (curr <= succ.up) {
                              if ((j < st || j >= en)) {
                                  ORInt n = [sol intValue: succ[curr]];
                                  if (n != nbJobs + 1) {
                                      ORInt est = [sol ect: t[n]];
                                      ORInt ect = [sol ect: t[n]];
                                      ORInt duration = [sol minDuration: t[n]];
                                      if (est + duration != ect)
                                          [cp label: succ[curr] with: [sol intValue: succ[curr]]];
                                  }
                              }
                              j++;
                              curr = [sol intValue: succ[curr]];
                          }
                      }
                      //NSLog(@"R");
                  }];
                NSLog(@"makespan = [%d,%d] \n",[cp min: makespan],[cp max: makespan]);
                fprintf(outFile, "%f %i\n", ([ORRuntimeMonitor wctime] - timeStart) / 1000.0, [cp min: makespan]);
                fflush(outFile);
            }];
            fclose(outFile);
            
            ORLong timeEnd = [ORRuntimeMonitor wctime];
            NSLog(@"Time: %lld",timeEnd - timeStart);
            id<ORSolutionPool> pool = [cp solutionPool];
            id<ORSolution> optimum = [pool best];
            NSLog(@"!! LNS makespan: %d \n",[optimum intValue: makespan]);
        }

        
    }
    return 0;
}
