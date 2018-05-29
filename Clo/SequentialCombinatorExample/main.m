//
//  main.m
//  SequentialCombinatorExample
//
//  Created by Daniel Fontaine on 12/4/16.
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
        FILE* data = fopen("orb10.jss","r");
        
        ORInt nbJobs, nbMachines;
        fscanf(data, "%d",&nbJobs);
        fscanf(data, "%d",&nbMachines);
        
        NSLog(@" nbJobs: %d nbMachines: %d",nbJobs,nbMachines);
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
        
        id<ORRunnable> r0 = [ORFactory CPRunnable: model solve:^(id<CPProgram,CPScheduler> lns) {
            [lns solve: ^{
                [lns limitTime: 1000L * 5 in:^{
                    id<ORUniformDistribution> sM = [ORFactory uniformDistribution:model range: Machines];
                    id<ORUniformDistribution> sD = [ORFactory uniformDistribution:model range: Jobs];
                    id<ORUniformDistribution> lD = [ORFactory uniformDistribution:model range:RANGE(model,2,nbMachines/5)];
                    [lns repeat: ^{
                        [lns limitFailures: 3 *nbJobs * nbMachines in: ^{
                            [lns forall: Machines orderedBy: ^ORInt(ORInt i) { return 10 * [lns globalSlack: disjunctive[i]] + [lns localSlack: disjunctive[i]]; } do: ^(ORInt i) {
                                id<ORTaskVarArray> t = disjunctive[i].taskVars;
                                [lns sequence: disjunctive[i].successors by: ^ORDouble(ORInt i) { return [lns ect: t[i]]; } then: ^ORDouble(ORInt i) { return [lns est: t[i]];}];
                            }];
                            [lns label: makespan];
                            NSLog(@"\nmakespan = [%d,%d] \n",[lns min: makespan],[lns max: makespan]);
                        }];
                    }
                       onRepeat: ^{
                           id<ORSolution,ORSchedulerSolution> sol = (id) [[lns solutionPool] best];
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
                                               [lns label: succ[curr] with: [sol intValue: succ[curr]]];
                                       }
                                   }
                                   j++;
                                   curr = [sol intValue: succ[curr]];
                               }
                           }
                           //NSLog(@"R");
                       }];
                    NSLog(@"makespan = [%d,%d] \n",[lns min: makespan],[lns max: makespan]);
                }];
            }];
        }];
        
        id<ORRunnable> r1 = [ORFactory CPRunnable: model solve:^(id<CPProgram,CPScheduler> cp) {
            [cp solve: ^{
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
            }];
        }];
        
        id<ORRunnable> r = [ORFactory composeSequnetial: r0 with: r1];
        [r run];
        
        NSLog(@"best makespan: %d \n",[[r bestSolution] intValue: makespan]);
    }
    return 0;
}
