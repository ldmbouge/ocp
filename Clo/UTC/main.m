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
    None = 0, G0, G1, G2
} MAIN_GEN;

ORInt rawMainGenCost[] = {
    0, 1000, 1200, 1500
};

ORInt rawMainGenPow[] = {
    0, 25, 35, 45
};

ORInt rawMainGenWeight[] = {
    0, 100, 110, 115
};


typedef enum {
    S0 = 0, S1, S2
} SENSOR;

ORInt rawSensCost[] = {
    0, 10, 30, 40
};

ORInt rawSensPowDraw[] = {
    0, 1, 5, 15
};

ORInt rawSensPowWeight[] = {
    0, 1, 5, 15
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
    ORInt nbComponent = 5;
    ORInt COMP = nbComponent;
    
    id<ORModel> m = [ORFactory createModel];
    id<ORIntRange> genBounds = RANGE(m, 0, 3);
    id<ORIntRange> genRange = RANGE(m, 0, 3);
    id<ORIntRange> senBounds = RANGE(m, 0, 3);
    id<ORIntRange> senRange = RANGE(m, 0, 6);
    id<ORIntRange> boolBounds = RANGE(m, 0, 1);
    
    id<ORIntVar> g0 = [ORFactory intVar: m bounds: genBounds];
    id<ORIntVar> g1 = [ORFactory intVar: m bounds: genBounds];
    id<ORIntVar> auxgen = [ORFactory intVar: m bounds: genBounds];
    id<ORIntVarArray> sensors = [ORFactory intVarArray: m range: senRange bounds: senBounds];
    id<ORIntVarArray> cd = [ORFactory intVarArray: m range: senRange bounds: boolBounds];
    id<ORIntVarArray> cb0 = [ORFactory intVarArray: m range: senRange bounds: boolBounds];
    id<ORIntVarArray> cb1 = [ORFactory intVarArray: m range: senRange bounds: boolBounds];
    id<ORIntVar> bus0 = [ORFactory intVar: m bounds: boolBounds];
    id<ORIntVar> bus1 = [ORFactory intVar: m bounds: boolBounds];
    id<ORIntVar> pow = [ORFactory intVar: m bounds: RANGE(m, 0, 10000)];
    id<ORIntVar> cost = [ORFactory intVar: m bounds: RANGE(m, 0, 99999)];
    id<ORIntVar> genCost = [ORFactory intVar: m bounds: RANGE(m, 0, 9999)];
    id<ORIntVar> senCost = [ORFactory intVar: m bounds: RANGE(m, 0, 9999)];
    id<ORIntVar> connCost = [ORFactory intVar: m bounds: RANGE(m, 0, 9999)];

    
    id<ORIntVar> weight = [ORFactory intVar: m bounds: RANGE(m, 0, 99999)];
    
    id<ORIntArray> mainGenWeight = [ORFactory intArray: m range: genRange values: rawMainGenWeight];
    id<ORIntArray> mainGenCost = [ORFactory intArray: m range: genRange values: rawMainGenCost];
    id<ORIntArray> mainGenPow = [ORFactory intArray: m range: genRange values: rawMainGenPow];
    
    id<ORIntArray> sensWeight = [ORFactory intArray: m range: senRange values: rawSensPowWeight];
    id<ORIntArray> sensCost = [ORFactory intArray: m range: senRange values: rawSensCost];
    id<ORIntArray> sensPow = [ORFactory intArray: m range: senRange values: rawSensPowDraw];
    
    [m add: [senCost eq: Sum(m, i, senRange, [sensors at: i])]];
    [m add: [genCost eq: [[[mainGenCost elt: g0] plus: [mainGenCost elt: g1]] plus: [mainGenCost elt: auxgen]]]];
    [m add: [cost eq: [senCost plus: genCost]]];

    
    
    
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
