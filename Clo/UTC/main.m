//
//  main.m
//  UTC
//
//  Created by Daniel Fontaine on 12/19/14.
//
//

#import <Foundation/Foundation.h>
#import <ORFoundation/ORFoundation.h>
#import <ORModeling/ORModeling.h>
#import <ORProgram/ORProgram.h>

typedef enum {
    None = 0, FPGA, SOFT, D_SOFT
} FFT_COMP;

typedef enum {
    CondNone = 0, CondRequired
} SIG_COND;

ORInt rawFFTACost[] = {
    0, 25, 75, 120
};

ORInt rawFFTAWeight[] = {
    0, 4, 12, 16
};

ORInt rawFFTADelay[] = {
    0, 7000, 2000, 2000
};

ORInt rawFFTAHeat[] = {
    0, 1000, 8500, 9000
};

ORInt rawFFTBCost[] = {
    0, 15, 65, 120
};

ORInt rawFFTBWeight[] = {
    0, 2, 9, 14
};

ORInt rawFFTBDelay[] = {
    0, 9000, 3000, 3000
};

ORInt rawFFTBHeat[] = {
    0, 800, 500, 900
};


NSString* fftNameTable[] = {
    @"FFT FPGA", @"FFT SOFTWARE"
};

ORInt MAX_WEIGHT = 20;
ORDouble FAIL_LIMIT = .07;
ORInt MIN_DELAY = 10000;
ORInt MAX_HEAT = 20000;

ORInt BUS_COST = 75;
ORInt CON_COST = 10;
ORInt BUS_WGHT = 15;
ORInt CON_WGHT = 1;

//ORInt PROB_SCALE = 10000;

int main(int argc, const char * argv[]) {
    id<ORModel> m = [ORFactory createModel];
    id<ORIntRange> fftARange = RANGE(m, 0, 1);
    id<ORIntRange> fftADomain = RANGE(m, 0, 3);
    id<ORIntRange> fftBRange = RANGE(m, 0, 2);
    id<ORIntRange> fftBDomain = RANGE(m, 0, 3);
    id<ORIntRange> sigConnRange = RANGE(m, 0, 10);
    id<ORIntRange> sigConnDomain = RANGE(m, 0, 1);
    
    id<ORIntArray> fftACost = [ORFactory intArray: m range: fftADomain values: rawFFTACost];
    id<ORIntArray> fftBCost = [ORFactory intArray: m range: fftBDomain values: rawFFTBCost];
    id<ORIntArray> fftAWeight = [ORFactory intArray: m range: fftADomain values: rawFFTAWeight];
    id<ORIntArray> fftBWeight = [ORFactory intArray: m range: fftBDomain values: rawFFTBWeight];

    id<ORIntArray> fftADelay = [ORFactory intArray: m range: fftADomain values: rawFFTADelay];
    id<ORIntArray> fftBDelay = [ORFactory intArray: m range: fftBDomain values: rawFFTBDelay];

    id<ORIntArray> fftAHeat = [ORFactory intArray: m range: fftADomain values: rawFFTAHeat];
    id<ORIntArray> fftBHeat = [ORFactory intArray: m range: fftBDomain values: rawFFTBHeat];

    
    id<ORIntVarArray> fftA = [ORFactory intVarArray: m range: fftARange domain: fftADomain];
    id<ORIntVarArray> fftB = [ORFactory intVarArray: m range: fftBRange domain: fftBDomain];
    id<ORIntVarArray> conn = [ORFactory intVarArray: m range: sigConnRange domain: sigConnDomain];
    id<ORIntVarArray> isConnA = [ORFactory intVarArray: m range: fftARange domain: RANGE(m, 0, 1)];
    id<ORIntVarArray> isConnB = [ORFactory intVarArray: m range: fftBRange domain: RANGE(m, 0, 1)];
    id<ORIntVar> useBus = [ORFactory intVar: m domain: RANGE(m, 0, 1)];

    // Connectivity
    [m add: [[[conn at: 4] eq: @(1)] imply: [[isConnA at: 0] eq: @(1)]]];
    [m add: [[[conn at: 10] eq: @(1)] imply: [[isConnA at: 1] eq: @(1)]]];
    [m add: [[[conn at: 1] eq: @(1)] imply: [[isConnB at: 0] eq: @(1)]]];
    [m add: [[[conn at: 0] eq: @(1)] imply: [[isConnB at: 1] eq: @(1)]]];
    [m add: [[[conn at: 5] eq: @(1)] imply: [[isConnB at: 2] eq: @(1)]]];

    
    // Weight Limit
    [m add:
     [[[[ORFactory elt: m intArray: fftWeight index: fft[0]] plus: [ORFactory elt: m intArray: fftWeight index: fft[1]]] mul: reps]
      leq: @(MAX_WEIGHT)]];
    
    // Throughput
    [m add: [[[[multiplex mul: Sum(m, i, fftRange,
                                   [ORFactory elt: m intArray: fftDelay index: fft[i]])]
               sub: cpuSpeedup]
              plus: Sum(m, i, sigCondRange, [ORFactory elt: m intArray: sigCondDelay index: sigCond[i]])]
             leq: @(MIN_DELAY)]];
    
    // Heat
    [m add: [[[[multiplex mul:
                Sum(m, i, fftRange, [ORFactory elt: m intArray: fftHeat index: fft[i]])] mul: reps]
              plus: cpuSpeedup]
             leq: @(MAX_HEAT)]];
    
    // Cost
    [m minimize: [[Sum(m, i, fftRange, [ORFactory elt: m intArray: fftCost index: fft[i]])
                   plus: Sum(m, i, sigCondRange, [ORFactory elt: m intArray: sigCondCost index: sigCond[i]])]
                  mul: reps]];
    
    
    id<CPProgram> p = [ORFactory createCPProgram: m];
    id<CPHeuristic> h = [p createFF];
    [p solve: ^{
        [p labelHeuristic: h];
        NSLog(@"Solution cost: %i", [[[p captureSolution] objectiveValue] intValue]);
    }];
    //    [p solve];
    id<ORSolutionPool> sols = [p solutionPool];
    id<ORSolution> bestSolution = [sols best];
    
    NSLog(@"Sol count: %li", [sols count]);
    NSLog(@"Solution: FFT: %i ==> %i COND: %i, %i, %i",
          [bestSolution intValue: fft[0]], [bestSolution intValue: fft[1]],
          [bestSolution intValue: sigCond[0]], [bestSolution intValue: sigCond[1]], [bestSolution intValue: sigCond[2]]);
    
    
    return 0;
}
