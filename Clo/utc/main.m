//
//  main.m
//  UTC
//
//  Created by Daniel Fontaine on 12/19/14.
//
//

#import <ORProgram/ORProgram.h>

typedef enum {
   None = 0, FPGA, SOFT, D_SOFT
} FFT_COMP;

typedef enum {
   CondNone = 0, CondRequired
} SIG_COND;

ORInt rawFFTCost[] = {
   0, 25, 75, 120
};

ORInt rawFFTWeight[] = {
   0, 4, 12, 16
};

ORInt rawFFTDelay[] = {
   0, 7000, 2000, 2000
};

ORInt rawFFTHeat[] = {
   0, 1000, 8500, 9000
};

ORDouble rawFFTFailRate[] = {
   0, .02, .05, .07
};

ORInt rawSignalCondCost[] = {
   0, 4
};

ORInt rawSignalCondDelay[] = {
   0, 200
};

NSString* fftNameTable[] = {
   @"FFT FPGA", @"FFT SOFTWARE"
};

ORInt MAX_WEIGHT = 20;
ORFloat FAIL_LIMIT = .07;
ORInt MIN_DELAY = 10000;
ORInt MAX_HEAT = 20000;
//ORInt PROB_SCALE = 10000;

int main(int argc, const char * argv[]) {
   id<ORModel> m = [ORFactory createModel];
   id<ORIntRange> fftRange = RANGE(m, 0, 1);
   id<ORIntRange> fftDomain = RANGE(m, 0, 3);
   id<ORIntRange> sigCondRange = RANGE(m, 0, 2);
   id<ORIntRange> sigCondDomain = RANGE(m, 0, 1);
   
   id<ORIntArray> fftCost = [ORFactory intArray: m range: fftDomain values: rawFFTCost];
   id<ORIntArray> fftWeight = [ORFactory intArray: m range: fftDomain values: rawFFTWeight];
   id<ORIntArray> fftDelay = [ORFactory intArray: m range: fftDomain values: rawFFTDelay];
   id<ORIntArray> fftHeat = [ORFactory intArray: m range: fftDomain values: rawFFTHeat];
   id<ORDoubleArray> fftFailRate = [ORFactory floatArray: m range: fftDomain values: rawFFTFailRate];
   
   id<ORIntArray> sigCondCost = [ORFactory intArray: m range: fftDomain values: rawSignalCondCost];
   id<ORIntArray> sigCondDelay = [ORFactory intArray: m range: fftDomain values: rawSignalCondDelay];
   
   id<ORIntVarArray> fft = [ORFactory intVarArray: m range: fftRange domain: fftDomain];
   id<ORIntVarArray> sigCond = [ORFactory intVarArray: m range: sigCondRange domain: sigCondDomain];
   id<ORIntVar> multiplex = [ORFactory intVar: m domain: RANGE(m, 1, 2)];
   id<ORIntVar> reps = [ORFactory intVar: m domain: RANGE(m, 1, 2)];
   
   id<ORIntVar> cpuSpeedup = [ORFactory intVar: m domain: RANGE(m, 0, 1000)];
   
   // Weight Limit
   [m add:
    [[[[ORFactory elt: m intArray: fftWeight index: fft[0]] plus: [ORFactory elt: m intArray: fftWeight index: fft[1]]] mul: reps]
     leq: @(MAX_WEIGHT)]];
   
   // Fail Limit
   [m add: [[reps eq: @(1)] imply:
            [[@(1.0) sub: Prod(m, i, fftRange,
                               [@(1.0) sub: [ORFactory elt: m floatArray: fftFailRate index: fft[i]]])]
             leq: @(FAIL_LIMIT)]]];
   [m add: [[reps eq: @(2)] imply:
            [[@(1.0) sub: Prod(m, i, fftRange,
                               [@(1.0) sub: [[ORFactory elt: m floatArray: fftFailRate index: fft[i]] square] ])]
             leq: @(FAIL_LIMIT)]]];
   
   // Throughput
   [m add: [[[[multiplex mul: Sum(m, i, fftRange,
                                  [ORFactory elt: m intArray: fftDelay index: fft[i]])]
              sub: cpuSpeedup]
             plus: Sum(m, i, sigCondRange, [ORFactory elt: m intArray: sigCondDelay index: sigCond[i]])]
            leq: @(MIN_DELAY)]];
   
   // Signal Conditioning
   [m add: [ORFactory expr: [fft[0] gt: @(FPGA)] imply: [sigCond[0] gt: @(CondNone)] track: m]];
   [m add: [ORFactory expr: [fft[0] neq: fft[1]] imply: [sigCond[1] gt: @(CondNone)] track: m]];
   [m add: [ORFactory expr: [fft[1] gt: @(FPGA)] imply: [sigCond[2] gt: @(CondNone)] track: m]];
   
   // Allow Software to run both tasks
   [m add: [fft[0] gt: @(None)]];
   
   // Multiplex constraints
   [m add: [ORFactory expr: [fft[1] eq: @(None)] imply: [multiplex gt: @(0)] track: m]];
   
   // Heat
   [m add: [[[[multiplex mul:
               Sum(m, i, fftRange, [ORFactory elt: m intArray: fftHeat index: fft[i]])] mul: reps]
             plus: cpuSpeedup]
            leq: @(MAX_HEAT)]];
   
   // Cost
   [m minimize: [[Sum(m, i, fftRange, [ORFactory elt: m intArray: fftCost index: fft[i]])
                  plus: Sum(m, i, sigCondRange, [ORFactory elt: m intArray: sigCondCost index: sigCond[i]])]
                 mul: reps]];
   
   // Dynamic CPU on FFT0
   [m add: [[fft[0] lt: @(D_SOFT)] imply: [cpuSpeedup eq: @(0)]]];
   
   
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
