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
    G0, G1, G2
} MAIN_GEN;

ORInt rawMainGenCost[] = {
    1000, 1200, 1500
};

ORInt rawMainGenPow[] = {
    25, 35, 45
};

ORInt rawMainGenWeight[] = {
    100, 110, 115
};


typedef enum {
    S0 = 0, S1, S2, S3, S4, S5, S6, S7, S8
} SENSOR;

ORInt rawSensBandwith[] = {
  35, 35, 35, 40, 51, 47, 18, 66, 22
};

ORInt rawSensCost[] = {
    10, 30, 40
};

ORInt rawSensPowDraw[] = {
    1, 5, 15
};

ORInt rawSensPowWeight[] = {
    1, 5, 15
};

ORInt rawConCost[] = {
    0, 100
};

ORInt rawConPowDraw[] = {
    0, 45
};

ORInt rawConPowWeight[] = {
    0, 75
};

ORInt rawDirectToPMUCost[] = {
    5, 5, 10, 12, 16, 12, 17, 19, 19
};

ORInt rawDirectToPMUWeight[] = {
    2, 2, 8, 8, 10, 10, 10, 12, 12
};

ORInt rawSenToBusCost[] = {
    2, 2, 4, 4, 4, 4, 5, 3, 3
};

ORInt rawSenToBusWeight[] = {
    1, 1, 2, 2, 2, 2, 3, 2, 2
};

ORInt rawSenToConCost[] = {
    1, 1, 3, 3, 3, 3, 4, 2, 2
};

ORInt rawSenToConWeight[] = {
    1, 1, 3, 3, 3, 3, 4, 2, 2
};

ORInt numMainGen = 2;
ORInt numBackupGen = 1;
ORInt numBatteries = 1;
ORInt numSensors = 9;

ORInt SenWithConc = 2;

ORInt MAX_WEIGHT = 1200;
ORInt MAX_BAND = 125;

ORInt BUS_COST = 75;
ORInt BUS_WGHT = 15;
ORInt CON_COST = 60;
ORInt CON_WEIGHT = 6;

ORInt PMU_POW = 120;
ORInt BBF1_POW = 70;
ORInt BBF2_POW = 55;

//ORInt PROB_SCALE = 10000;

int main(int argc, const char * argv[]) {
    id<ORModel> m = [ORFactory createModel];
    id<ORIntRange> genBounds = RANGE(m, 0, 2);
    id<ORIntRange> genRange = RANGE(m, 0, numMainGen + numBackupGen - 1);
    id<ORIntRange> senBounds = RANGE(m, 0, 2);
    id<ORIntRange> senRange = RANGE(m, 0, numSensors-1);
    id<ORIntRange> boolBounds = RANGE(m, 0, 1);
    
    // Variables ------------------------------------------------------------------------------------------
    
    // Components
    id<ORIntVar> g0 = [ORFactory intVar: m bounds: genBounds];
    id<ORIntVar> g1 = [ORFactory intVar: m bounds: genBounds];
    id<ORIntVar> auxgen = [ORFactory intVar: m bounds: genBounds];
    id<ORIntVarArray> sensors = [ORFactory intVarArray: m range: senRange bounds: senBounds];
    
    // Direct Connections
    id<ORIntVarArray> senDirectPMU = [ORFactory intVarArray: m range: senRange bounds: boolBounds];

    // Connected to concentrator
    id<ORIntVarArray> senToCon = [ORFactory intVarArray: m range: senRange bounds: boolBounds];

    // Connected to Bus
    id<ORIntVarArray> senToBus = [ORFactory intVarArray: m range: senRange bounds: boolBounds];

    // Concetrators
    id<ORIntVar> useCon1 = [ORFactory intVar: m bounds: boolBounds];
    id<ORIntVar> useCon2 = [ORFactory intVar: m bounds: boolBounds];

    // Bus
    id<ORIntVar> useBus1 = [ORFactory intVar: m bounds: boolBounds];

    id<ORIntVar> powUse = [ORFactory intVar: m bounds: RANGE(m, 0, 10000)];
    id<ORIntVar> bandUse = [ORFactory intVar: m bounds: RANGE(m, 0, 10000)];
    id<ORIntVar> cost = [ORFactory intVar: m bounds: RANGE(m, 0, 99999)];
    id<ORIntVar> weight = [ORFactory intVar: m bounds: RANGE(m, 0, 99999)];
    
    
    // Template Tables -----------------------------------------------------------------------
    
    id<ORIntArray> mainGenWeight = [ORFactory intArray: m range: genBounds values: rawMainGenWeight];
    id<ORIntArray> mainGenCost = [ORFactory intArray: m range: genBounds values: rawMainGenCost];
    id<ORIntArray> mainGenPow = [ORFactory intArray: m range: genBounds values: rawMainGenPow];
    
    id<ORIntArray> sensWeight = [ORFactory intArray: m range: senBounds values: rawSensPowWeight];
    id<ORIntArray> sensCost = [ORFactory intArray: m range: senBounds values: rawSensCost];
    id<ORIntArray> sensPowDraw = [ORFactory intArray: m range: senBounds values: rawSensPowDraw];
    id<ORIntArray> sensBandwith = [ORFactory intArray: m range: senRange values: rawSensBandwith];

    id<ORIntArray> conCost = [ORFactory intArray: m range: boolBounds values: rawConCost];

    id<ORIntArray> directToPMUCost = [ORFactory intArray: m range: senRange values: rawDirectToPMUCost];
    id<ORIntArray> directToPMUWeight = [ORFactory intArray: m range: senRange values: rawDirectToPMUWeight];

    id<ORIntArray> senToBusCost = [ORFactory intArray: m range: senRange values: rawSenToBusCost];
    id<ORIntArray> senToBusWeight = [ORFactory intArray: m range: senRange values: rawSenToBusWeight];

    id<ORIntArray> senToConCost = [ORFactory intArray: m range: senRange values: rawSenToConCost];
    id<ORIntArray> senToConWeight = [ORFactory intArray: m range: senRange values: rawSenToConWeight];

    
    [m minimize: [cost plus: weight]];
    
    // Cost ///////////////////////////
    [m add: [cost eq:
             [[[[[[[[[mainGenCost elt: g0] plus: [mainGenCost elt: g1]] plus: [mainGenCost elt: auxgen]] plus: // Gen cost
              Sum(m, i, senRange, [sensCost elt: [sensors at: i]])] plus: // Cost of sensors
              Sum(m, i, senRange, [@([directToPMUCost at: i]) mul: [senDirectPMU at: i]])] plus: // Cost direct to PMU
              Sum(m, i, senRange, [@([senToBusCost at: i]) mul: [senToBus at: i]])] plus: // Cost direct to bus
              Sum(m, i, senRange, [@([senToConCost at: i]) mul: [senToCon at: i]])] plus: // Cost direct to Concentrator
              [[conCost elt: useCon1] plus: [conCost elt: useCon2]]] plus: // Concentrator cost
              [useBus1 mul: @(BUS_COST)]] // Bus Cost
             ]];
    
    // Weight /////////////////////////
    [m add: [weight eq:
             [[[[[[[[[mainGenWeight elt: g0] plus: [mainGenWeight elt: g1]] plus: [mainGenWeight elt: auxgen]] plus: // Gen weight
              Sum(m, i, senRange, [sensWeight elt: [sensors at: i]])] plus: // Cost of weight
              Sum(m, i, senRange, [@([directToPMUWeight at: i]) mul: [senDirectPMU at: i]])] plus: // Weight direct to PMU
              Sum(m, i, senRange, [@([senToBusWeight at: i]) mul: [senToBus at: i]])] plus: // Weight direct to bus
              Sum(m, i, senRange, [@([senToConWeight at: i]) mul: [senToCon at: i]])] plus: // Weight direct to Concentrator
              [[useCon1 mul:@(CON_WEIGHT)] plus: [useCon2 mul:@(CON_WEIGHT)]]] plus: // Concentrator weight
              [useBus1 mul: @(BUS_WGHT)] ]
             ]];

    [m add: [weight leq: @(MAX_WEIGHT)]];
    
    // Power Draw /////////////////////////
    [m add: [[[powUse eq: Sum(m, i, senRange, [sensPowDraw elt: [sensors at: i]])] plus: // Sensor Power
             @(BBF1_POW + BBF2_POW)] plus: // Black Box power
             @(PMU_POW)] // PMU power draw
     ];
    
    // Power Gen //////////////////////////
    [m add: [[[mainGenPow elt: g0] plus: [mainGenPow elt: g1]] gt: powUse]];
    [m add: [[[mainGenPow elt: g0] plus: [mainGenPow elt: auxgen]] gt: powUse]];
    [m add: [[[mainGenPow elt: auxgen] plus: [mainGenPow elt: g1]] gt: powUse]];

    // Connectivity ///////////////////////
    for(ORInt i = [senRange low]; i <= [senRange up]; i++)
        [m add: [[senDirectPMU[i] plus: [senToCon[i] plus: senToBus[i]]] eq: @(1)]]; // Connected to PMU, bus or concentrator
    
    // Bus ////////////////////////////////
    [m add: [useBus1 geq: Sum(m, i, senRange, senToBus[i])]];
    
    for(ORInt i = [senRange low]; i <= [senRange up]; i++)
        [m add: [senToBus[i] eq: [sensors[i] eq: @(SenWithConc)]]]; // If sens. connected to bus, must have its own concentrator
//
    // Concentrators //////////////////////
    [m add: [useCon1 geq: [[[[sensors[S0] plus: sensors[S1]] plus: sensors[S4]] plus: sensors[S6]] plus: sensors[S7]] ]];
    [m add: [useCon1 geq: [[[sensors[S2] plus: sensors[S3]] plus: sensors[S5]] plus: sensors[S8]] ]];

    // Bus Bandwidth
    [m add: [bandUse eq: Sum(m, i, senRange, [[senToBus[i] plus: senToCon[1]] mul: sensBandwith[i]] )]];
    [m add: [bandUse leq: @(MAX_BAND)]];
    
    id<CPProgram> p = [ORFactory createCPProgram: m];
    id<CPHeuristic> h = [p createFF];
    [p solve: ^{
        [p labelHeuristic: h];
        NSLog(@"Solution cost: %i", [[[p captureSolution] objectiveValue] intValue]);
    }];
    //    [p solve];
    id<ORSolutionPool> sols = [p solutionPool];
    //id<ORSolution> bestSolution = [sols best];
    
    NSLog(@"Sol count: %li", [sols count]);  // this only prints the number of solutions on the way to the global optimum.
    
    return 0;
}
