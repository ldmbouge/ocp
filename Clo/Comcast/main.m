//
//  main.m
//  Comcast
//
//  Created by Daniel Fontaine on 2/3/17.
//
//

#import <ORFoundation/ORFoundation.h>
#import <ORFoundation/ORSemBDSController.h>
#import <ORFoundation/ORSemDFSController.h>
#import <ORModeling/ORModeling.h>
#import <ORModeling/ORModelTransformation.h>
#import <ORProgram/ORProgram.h>
#import <ORModeling/ORLinearize.h>


int main(int argc, const char * argv[])
{
    id<ORModel> model = [ORFactory createModel];
    //id<ORAnnotation> notes = [ORFactory annotation];
    
    srand(5000);//(unsigned int)time(NULL));
    
    ORInt Ncnodes = 30;
    ORInt Napps = 3;
    ORInt Nsec = 2;
    
    id<ORIntRange> cnodes = RANGE(model,1, Ncnodes);
    id<ORIntRange> apps = RANGE(model,1, Napps);
    id<ORIntRange> sec = RANGE(model,0, Nsec);

    id<ORIntArray> D = [ORFactory intArray: model range: apps with:^ORInt(ORInt i) { return rand() % 10; }];
    id<ORIntArray> M = [ORFactory intArray: model range: cnodes with:^ORInt(ORInt i) { return rand() % 1000; }];
    id<ORIntArray> Mapp = [ORFactory intArray: model range: apps with:^ORInt(ORInt i) { return rand() % 10; }];
    id<ORIntArray> B = [ORFactory intArray: model range: cnodes with:^ORInt(ORInt i) { return rand() % 1000; }];
    id<ORIntArray> Bapp = [ORFactory intArray: model range: apps with:^ORInt(ORInt i) { return rand() % 10; }];
    
    ORInt t[3] = {0,1,2};
    id<ORIntArray> T = [ORFactory intArray: model range: sec values: (ORInt*)&t];
    id<ORIntArray> Tapp = [ORFactory intArray: model range: apps with:^ORInt(ORInt i) { return rand() % 3; }];
    
    id<ORIntArray> Fmem = [ORFactory intArray: model range: sec with:^ORInt(ORInt i) { return rand() % 10; }];
    id<ORIntArray> Fbw = [ORFactory intArray: model range: sec with:^ORInt(ORInt i) { return rand() % 10; }];
    
    id<ORIntArray> Smem = [ORFactory intArray: model range: sec with:^ORInt(ORInt i) { return rand() % 3 + 1; }];
    id<ORIntArray> Sbw = [ORFactory intArray: model range: sec with:^ORInt(ORInt i) { return rand() % 3 + 1; }];

    
    id<ORIntVarArray>  s = [ORFactory intVarArray: model range: cnodes domain: sec];
    id<ORIntVarMatrix> a = [ORFactory intVarMatrix:model range: cnodes : apps domain: RANGE(model, 0, 1000)];
    id<ORIntVarArray> u_mem = [ORFactory intVarArray: model range: cnodes domain: RANGE(model, 0, 100*100)];
    id<ORIntVarArray> u_bw = [ORFactory intVarArray: model range: cnodes domain: RANGE(model, 0, 100*100)];
    
    [model minimize: Sum(model, i, cnodes, [[u_mem at: i] plus: [u_bw at: i]])];
    
    // Demand Constraints
    for(ORInt j = [apps low]; j <= [apps up]; j++) {
        [model add: [Sum(model, i, cnodes, [a at: i : j]) geq: @([D at: j])]];
    }
    
    // Security Constraints
    for(ORInt i = [cnodes low]; i <= [cnodes up]; i++) {
        for(ORInt j = [apps low]; j <= [apps up]; j++) {
            [model add: [[[a at: i : j] gt: @(0)] eq:
                         [[T elt: [s at: i]] geq: @([Tapp at: j])]]];
        }
    }
    
    // Memory Constraints
    for(ORInt i = [cnodes low]; i <= [cnodes up]; i++) {
        [model add: [[u_mem at: i] geq: Sum(model, j, apps, [[a at: i : j] mul: @([Mapp at: j])])]];
        [model add: [[[u_mem at: i] mul: [Smem elt: [s at: i]]] leq: [@([M at: i]) sub: [Fmem elt: [s at: i]]]]];
    }
    
    // Bandwidth Constraints
    for(ORInt i = [cnodes low]; i <= [cnodes up]; i++) {
        [model add: [[u_bw at: i] geq: Sum(model, j, apps, [[a at: i : j] mul: @([Bapp at: j])])]];
        [model add: [[[u_bw at: i] mul: [Sbw elt: [s at: i]]] leq: [@([B at: i]) sub: [Fbw elt: [s at: i]]]]];
    }

//    id<ORModel> lm = [ORFactory linearizeModel: model];
//    id<ORRunnable> r = [ORFactory MIPRunnable: lm];
//    [r start];

   /*
    id<ORRunnable> r = [ORFactory CPDualRunnable: model solve:^(id<CPCommonProgram> cp) {
        [cp labelArray: s];
        [cp labelArray: u_mem];
        [cp labelArray: u_bw];
        [cp labelArray: [a flatten]];
    }];
    [r start];
    id<ORSolution> best = [r bestSolution];
    */
    id<CPProgram> cp = [ORFactory createCPProgram: model];
    //NSLog(@"Model %@",model);
    ORTimeval now = [ORRuntimeMonitor now];
    id<CPHeuristic> h = [cp createABS];
    [cp solve:^{
        [cp labelHeuristic:h];
        id<ORSolution> s = [cp captureSolution];
        NSLog(@"Found Solution: %i", [[s objectiveValue] intValue]);
    }];
    id<ORSolution> best = [[cp solutionPool] best];
    //NSLog(@"Number of solutions found: %li", [[cp solutionPool] count]);
   ORTimeval el = [ORRuntimeMonitor elapsedSince:now];
    NSLog(@"#best objective: %i",[[best objectiveValue] intValue]);
   NSLog(@"Total time: %f",el.tv_sec * 1000.0 + (double)el.tv_usec / 1000.0);
    return 0;
}

