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
        if(argc < 2) {
            NSLog(@"jspbenchmarks [technology] filepath");
            return -1;
        }
        NSMutableArray* args = [[NSMutableArray alloc] initWithCapacity: argc];
        for(int i = 0; i < argc; i++) [args addObject: [NSString stringWithCString: argv[i] encoding: NSASCIIStringEncoding]];
        
        BOOL doCP = NO;
        BOOL doMIP = NO;
        BOOL doHybrid = NO;
        
        if([args containsObject: @"-cp"]) doCP = YES;
        if([args containsObject: @"-mip"]) doMIP = YES;
        if([args containsObject: @"-cp-mip"]) doHybrid = YES;
        
        NSString* path = [args lastObject];//@"/Users/dan/Work/platform/Clo/Scheduler/BenchmarkData/jsp/la19.jss"
        
        FILE* data = fopen([path cStringUsingEncoding: NSASCIIStringEncoding], "r");
        
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
            id<CPProgram,CPScheduler> cp  = (id)[ORFactory createCPProgram: model];
            ORLong timeStart = [ORRuntimeMonitor cputime];
            [cp solve: ^{
                [cp forall: Machines orderedBy: ^ORInt(ORInt i) { return [cp globalSlack: disjunctive[i]] + 1000 * [cp localSlack: disjunctive[i]];} do: ^(ORInt i) {
                    id<ORTaskVarArray> t = disjunctive[i].taskVars;
                    [cp sequence: disjunctive[i].successors
                              by: ^ORDouble(ORInt i) { return [cp est: t[i]]; }
                            then: ^ORDouble(ORInt i) { return [cp ect: t[i]];}];
                }];
                [cp label: makespan];
                printf("makespan = [%d,%d] \n",[cp min: makespan],[cp max: makespan]);
            }];
            ORLong timeEnd = [ORRuntimeMonitor cputime];
            NSLog(@"Time: %lld",timeEnd - timeStart);
            id<ORSolutionPool> pool = [cp solutionPool];
            id<ORSolution> optimum = [pool best];
            printf("!! CP makespan: %d \n",[optimum intValue: makespan]);
        }
        
        if(doMIP) {
            // Linearize
            id<ORModel> lm = [ORFactory linearizeSchedulingModel: model encoding: MIPSchedDisjunctive];
            id<ORRunnable> r = [ORFactory MIPRunnable: lm];
            ORLong timeStart = [ORRuntimeMonitor cputime];
            [r run];
            ORLong timeEnd = [ORRuntimeMonitor cputime];
            NSLog(@"Time: %lld",timeEnd - timeStart);
            id<ORSolution> optimum = [r bestSolution];
            printf("!! MIP makespan: %d \n",[optimum intValue: makespan]);
        }
        
        if(doHybrid) {
            id<ORModel> lm = [ORFactory linearizeSchedulingModel: model encoding: MIPSchedDisjunctive];
            id<ORRunnable> r0 = [ORFactory CPRunnable: model solve: ^(id<CPCommonProgram> program){
                id<CPProgram,CPScheduler> cp = (id<CPProgram,CPScheduler>)program;
                NSLog(@"MKS: %@n\n",[cp concretize:makespan]);
                [cp forall: Machines orderedBy: ^ORInt(ORInt i) { return [cp globalSlack: disjunctive[i]] + 1000 * [cp localSlack: disjunctive[i]];} do: ^(ORInt i) {
                    id<ORTaskVarArray> t = disjunctive[i].taskVars;
                    [cp sequence: disjunctive[i].successors
                              by: ^ORDouble(ORInt i) { return [cp est: t[i]]; }
                            then: ^ORDouble(ORInt i) { return [cp ect: t[i]];}];
                }];
                [cp label: makespan];
                printf("makespan = [%d,%d] \n",[cp min: makespan],[cp max: makespan]);
            }];
            id<ORRunnable> r1 = [ORFactory MIPRunnable: lm];
            id<ORRunnable> r = [ORFactory composeCompleteParallel: r0 with: r1];
            ORLong timeStart = [ORRuntimeMonitor cputime];
            [r run];
            ORLong timeEnd = [ORRuntimeMonitor cputime];
            NSLog(@"Time: %lld",timeEnd - timeStart);
            id<ORSolution> optimum = [r bestSolution];
            printf("!! CP/MIP makespan: %d \n",[optimum intValue: makespan]);
        }
    }
    return 0;
}
