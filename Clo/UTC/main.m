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

#define NONE @(0)

typedef enum {
    G0, G1, G2
} MAIN_GEN;

typedef enum {
    CONT_S0 = 0, CONT_S1, CONT_S2, CONT_S3, CONT_S4, CONT_S5, CONT_S6, CONT_S7, CONT_S8
} CONT_SENSOR;

typedef enum {
    VOLT_S0 = 0, VOLT_S1, VOLT_S2, VOLT_S3, VOLT_S4, VOLT_S5, VOLT_S6, VOLT_S7, VOLT_S8
} VOLT_SENSOR;

typedef enum {
    CUR_S0 = 0, CUR_S1, CUR_S2, CUR_S3, CUR_S4, CUR_S5, CUR_S6, CUR_S7, CUR_S8
} CUR_SENSOR;

ORInt rawContSensBandwith[] = {
  35, 35, 35, 40, 51, 47, 18, 66, 22
};

ORInt rawVoltSensBandwith[] = {
    41, 52, 31, 31, 56, 58, 19, 27, 33
};

ORInt rawCurSensBandwith[] = {
    39, 48, 41, 51, 36, 39, 29, 21, 30
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

ORInt rawContDirectToPMUCost[] = {
    1115, 1115, 1110, 1112, 1116, 1112, 1117, 1119, 11119
};

ORInt rawContDirectToPMUWeight[] = {
    11120, 11120, 11180, 11180, 11100, 11100, 11100, 11120, 11120
};


ORInt rawVoltDirectToPMUCost[] = {
    113, 117, 112, 116, 122, 19, 112, 121, 116
};

ORInt rawVoltDirectToPMUWeight[] = {
    112, 114, 170, 164, 110, 110, 90, 122, 130
};

ORInt rawCurDirectToPMUCost[] = {
    118, 114, 116, 112, 113, 111, 117, 114, 118
};

ORInt rawCurDirectToPMUWeight[] = {
    113, 113, 160, 174, 100, 190, 165, 132, 140
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
ORInt numBuses = 3;
ORInt numBackupGen = 1;
ORInt numBatteries = 1;
ORInt numContSensors = 9;
ORInt numVoltSensors = 11;
ORInt numCurSensors = 11;

ORInt SenWithConc = 2;

ORInt MAX_WEIGHT = 2200;

ORInt CON_COST = 60;
ORInt CON_WEIGHT = 6;

ORInt PMU_POW = 20;
ORInt BBF1_POW = 70;
ORInt BBF2_POW = 55;

//ORInt PROB_SCALE = 10000;

int main(int argc, const char * argv[]) {
    
    id<ORModel> m = [ORFactory createModel];
    
    // Load Templates and model parameters -----------------------------------------------------------------
    NSXMLDocument *xmlDoc;
    NSError *err=nil;
    NSString* xmlPath = [[NSBundle mainBundle] pathForResource:@"UTCTemplates" ofType:@"xml"];
    NSURL *furl = [NSURL fileURLWithPath: xmlPath];
    if (!furl) {
        NSLog(@"Can't create an URL from file %@.", xmlPath);
        return -1;
    }
    xmlDoc = [[NSXMLDocument alloc] initWithContentsOfURL: furl options: NSXMLDocumentTidyXML error: &err];
    NSArray* generatorTemplates = [xmlDoc nodesForXPath: @"/template_library/generator_templates/generator" error: &err];
    ORInt numGeneratorTemplates = (ORInt)[generatorTemplates count];
    NSArray* contSensorTemplates = [xmlDoc nodesForXPath: @"/template_library/contactor_sensor_templates/sensor" error: &err];
    ORInt numContSensorTemplates = (ORInt)[contSensorTemplates count];
    NSArray* voltSensorTemplates = [xmlDoc nodesForXPath: @"/template_library/voltage_sensor_templates/sensor" error: &err];
    ORInt numVoltSensorTemplates = (ORInt)[voltSensorTemplates count];
    NSArray* curSensorTemplates = [xmlDoc nodesForXPath: @"/template_library/current_sensor_templates/sensor" error: &err];
    ORInt numCurSensorTemplates = (ORInt)[curSensorTemplates count];
    NSArray* busTemplates = [xmlDoc nodesForXPath: @"/template_library/data_bus_templates/data_bus" error: &err];
    ORInt numBusTemplates = (ORInt)[busTemplates count];
    NSArray* concTemplates = [xmlDoc nodesForXPath: @"/template_library/concentrator_templates/concentrator" error: &err];
    ORInt numConcTemplates = (ORInt)[concTemplates count];
    NSArray* bbfTemplates = [xmlDoc nodesForXPath: @"/template_library/blackbox_templates/bbf" error: &err];

    id<ORIntRange> genBounds = RANGE(m, 0, numGeneratorTemplates-1);
    id<ORIntRange> genRange = RANGE(m, 0, numMainGen + numBackupGen - 1);
    id<ORIntRange> contSenBounds = RANGE(m, 0, numContSensorTemplates-1);
    id<ORIntRange> contSenRange = RANGE(m, 0, numContSensors-1);
    id<ORIntRange> voltSenBounds = RANGE(m, 0, numVoltSensorTemplates-1);
    id<ORIntRange> voltSenRange = RANGE(m, 0, numVoltSensors-1);
    id<ORIntRange> curSenBounds = RANGE(m, 0, numCurSensorTemplates-1);
    id<ORIntRange> curSenRange = RANGE(m, 0, numCurSensors-1);
    
    id<ORIntRange> concBounds = RANGE(m, 0, numConcTemplates-1);

    id<ORIntRange> boolBounds = RANGE(m, 0, 1);
    
    // Generator Template Tables
    id<ORIntArray> mainGenWeight = [ORFactory intArray: m range: genBounds with: ^ORInt(ORInt i) {
        return [[[[generatorTemplates[i] elementsForName: @"weight"] lastObject] stringValue] intValue]; }];
    id<ORIntArray> mainGenCost = [ORFactory intArray: m range: genBounds with: ^ORInt(ORInt i) {
        return [[[[generatorTemplates[i] elementsForName: @"cost"] lastObject] stringValue] intValue]; }];
    id<ORIntArray> mainGenPow = [ORFactory intArray: m range: genBounds with: ^ORInt(ORInt i) {
        return [[[[generatorTemplates[i] elementsForName: @"power"] lastObject] stringValue] intValue]; }];
    
    // Sensor Template Tables
    id<ORIntArray> contSensWeight = [ORFactory intArray: m range: contSenBounds with: ^ORInt(ORInt i) {
        return [[[[contSensorTemplates[i] elementsForName: @"weight"] lastObject] stringValue] intValue]; }];
    id<ORIntArray> contSensCost = [ORFactory intArray: m range: contSenBounds with: ^ORInt(ORInt i) {
        return [[[[contSensorTemplates[i] elementsForName: @"cost"] lastObject] stringValue] intValue]; }];
    id<ORIntArray> contSensPowDraw = [ORFactory intArray: m range: contSenBounds with: ^ORInt(ORInt i) {
        return [[[[contSensorTemplates[i] elementsForName: @"power"] lastObject] stringValue] intValue]; }];
    
    id<ORIntArray> voltSensWeight = [ORFactory intArray: m range: voltSenBounds with: ^ORInt(ORInt i) {
        return [[[[voltSensorTemplates[i] elementsForName: @"weight"] lastObject] stringValue] intValue]; }];
    id<ORIntArray> voltSensCost = [ORFactory intArray: m range: voltSenBounds with: ^ORInt(ORInt i) {
        return [[[[voltSensorTemplates[i] elementsForName: @"cost"] lastObject] stringValue] intValue]; }];
    id<ORIntArray> voltSensPowDraw = [ORFactory intArray: m range: voltSenBounds with: ^ORInt(ORInt i) {
        return [[[[voltSensorTemplates[i] elementsForName: @"power"] lastObject] stringValue] intValue]; }];
    
    id<ORIntArray> curSensWeight = [ORFactory intArray: m range: curSenBounds with: ^ORInt(ORInt i) {
        return [[[[curSensorTemplates[i] elementsForName: @"weight"] lastObject] stringValue] intValue]; }];
    id<ORIntArray> curSensCost = [ORFactory intArray: m range: curSenBounds with: ^ORInt(ORInt i) {
        return [[[[curSensorTemplates[i] elementsForName: @"cost"] lastObject] stringValue] intValue]; }];
    id<ORIntArray> curSensPowDraw = [ORFactory intArray: m range: curSenBounds with: ^ORInt(ORInt i) {
        return [[[[curSensorTemplates[i] elementsForName: @"power"] lastObject] stringValue] intValue]; }];
    
    // Bus Template Tables
    ORInt MAX_BAND = [[[[busTemplates[0] elementsForName: @"bandwidth"] lastObject] stringValue] intValue];
    ORInt BUS_COST = [[[[busTemplates[0] elementsForName: @"cost"] lastObject] stringValue] intValue];;
    ORInt BUS_WGHT = [[[[busTemplates[0] elementsForName: @"weight"] lastObject] stringValue] intValue];;
    
    // Concentrator Template Table
    
    id<ORIntArray> conCost = [ORFactory intArray: m range: concBounds with: ^ORInt(ORInt i) {
        return [[[[concTemplates[i] elementsForName: @"cost"] lastObject] stringValue] intValue]; }];

    
    // Variables ------------------------------------------------------------------------------------------
    
    // Components
    id<ORIntVar> g0 = [ORFactory intVar: m bounds: genBounds];
    id<ORIntVar> g1 = [ORFactory intVar: m bounds: genBounds];
    id<ORIntVar> auxgen = [ORFactory intVar: m bounds: genBounds];
    id<ORIntVarArray> contSensors = [ORFactory intVarArray: m range: contSenRange bounds: contSenBounds];
    id<ORIntVarArray> voltSensors = [ORFactory intVarArray: m range: voltSenRange bounds: voltSenBounds];
    id<ORIntVarArray> curSensors = [ORFactory intVarArray: m range: curSenRange bounds: curSenBounds];

    // Direct Connections
    id<ORIntVarArray> contSenDirectPMU = [ORFactory intVarArray: m range: contSenRange bounds: boolBounds];
    id<ORIntVarArray> voltSenDirectPMU = [ORFactory intVarArray: m range: voltSenRange bounds: boolBounds];
    id<ORIntVarArray> curSenDirectPMU = [ORFactory intVarArray: m range: curSenRange bounds: boolBounds];

    // Connected to concentrator
    id<ORIntVarArray> contSenToCon = [ORFactory intVarArray: m range: contSenRange bounds: boolBounds];
    id<ORIntVarArray> voltSenToCon = [ORFactory intVarArray: m range: voltSenRange bounds: boolBounds];
    id<ORIntVarArray> curSenToCon = [ORFactory intVarArray: m range: curSenRange bounds: boolBounds];

    // Connected to Bus
    id<ORIntVarArray> contSenToBus = [ORFactory intVarArray: m range: contSenRange bounds: RANGE(m, 0, numBuses)];
    id<ORIntVarArray> voltSenToBus = [ORFactory intVarArray: m range: voltSenRange bounds: RANGE(m, 0, numBuses)];
    id<ORIntVarArray> curSenToBus = [ORFactory intVarArray: m range: curSenRange bounds: RANGE(m, 0, numBuses)];

    // Concetrators
    id<ORIntVarArray> useConc = [ORFactory intVarArray: m range: RANGE(m, 1, 2) bounds: boolBounds];

    // Bus
    id<ORIntVarArray> useBus = [ORFactory intVarArray: m range: RANGE(m, 1, 3) bounds: boolBounds];

    id<ORIntVar> powUse = [ORFactory intVar: m bounds: RANGE(m, 0, 10000)];
    id<ORIntVarArray> bandUse = [ORFactory intVarArray: m range: RANGE(m, 0, 2) bounds: RANGE(m, 0, 100000)];
    id<ORIntVar> cost = [ORFactory intVar: m bounds: RANGE(m, 0, 99999)];
    id<ORIntVar> weight = [ORFactory intVar: m bounds: RANGE(m, 0, 99999)];
    
    // data paths
    id<ORIntRange> pathRange = RANGE(m, 0, 16);
    id<ORIntVarArray> usePath = [ORFactory intVarArray: m range: pathRange bounds: boolBounds];

    
    // Template Tables -----------------------------------------------------------------------
    
    
    id<ORIntArray> contSensBandwith = [ORFactory intArray: m range: contSenRange values: rawContSensBandwith];
    id<ORIntArray> voltSensBandwith = [ORFactory intArray: m range: voltSenRange values: rawVoltSensBandwith];
    id<ORIntArray> curSensBandwith = [ORFactory intArray: m range: curSenRange values: rawCurSensBandwith];

    id<ORIntArray> contDirectToPMUCost = [ORFactory intArray: m range: contSenRange values: rawContDirectToPMUCost];
    id<ORIntArray> contDirectToPMUWeight = [ORFactory intArray: m range: contSenRange values: rawContDirectToPMUWeight];
    
    id<ORIntArray> voltDirectToPMUCost = [ORFactory intArray: m range: voltSenRange values: rawVoltDirectToPMUCost];
    id<ORIntArray> voltDirectToPMUWeight = [ORFactory intArray: m range: voltSenRange values: rawVoltDirectToPMUWeight];
    
    id<ORIntArray> curDirectToPMUCost = [ORFactory intArray: m range: curSenRange values: rawCurDirectToPMUCost];
    id<ORIntArray> curDirectToPMUWeight = [ORFactory intArray: m range: curSenRange values: rawCurDirectToPMUWeight];

    id<ORIntArray> senToBusCost = [ORFactory intArray: m range: contSenRange values: rawSenToBusCost];
    id<ORIntArray> senToBusWeight = [ORFactory intArray: m range: contSenRange values: rawSenToBusWeight];

    id<ORIntArray> senToConCost = [ORFactory intArray: m range: contSenRange values: rawSenToConCost];
    id<ORIntArray> senToConWeight = [ORFactory intArray: m range: contSenRange values: rawSenToConWeight];

    
    [m minimize: [cost plus: weight]];
    
    // Cost ///////////////////////////
    [m add: [cost eq:
             [[[[[[[[[[[[[mainGenCost elt: g0] plus: [mainGenCost elt: g1]] plus: [mainGenCost elt: auxgen]] plus: // Gen cost
              Sum(m, i, voltSenRange, [voltSensCost elt: [voltSensors at: i]])] plus: // Cost of contactor sensors
              Sum(m, i, curSenRange, [curSensCost elt: [curSensors at: i]])] plus: // Cost of contactor sensors
              Sum(m, i, contSenRange, [contSensCost elt: [contSensors at: i]])] plus: // Cost of contactor sensors
              Sum(m, i, contSenRange, [@([contDirectToPMUCost at: i]) mul: [contSenDirectPMU at: i]])] plus: // Cost direct to PMU
              Sum(m, i, voltSenRange, [@([voltDirectToPMUCost at: i]) mul: [voltSenDirectPMU at: i]])] plus: // Cost direct to PMU
              Sum(m, i, curSenRange, [@([curDirectToPMUCost at: i]) mul: [curSenDirectPMU at: i]])] plus: // Cost direct to PMU
              Sum(m, i, contSenRange, [@([senToBusCost at: i]) mul: [[contSenToBus at: i] gt: @(0)]])] plus: // Cost direct to bus
              Sum(m, i, contSenRange, [@([senToConCost at: i]) mul: [[contSenToCon at: i] gt: @(0)]])] plus: // Cost direct to Concentrator
              [[conCost elt: useConc[1]] plus: [conCost elt: useConc[2]]]] plus: // Concentrator cost
              [Sum(m, i, RANGE(m, 1, 3), useBus[i]) mul: @(BUS_COST)]] // Bus Cost
             ]];
    
    // Weight /////////////////////////
    [m add: [weight eq:
             [[[[[[[[[[[[[mainGenWeight elt: g0] plus: [mainGenWeight elt: g1]] plus: [mainGenWeight elt: auxgen]] plus: // Gen weight
              Sum(m, i, contSenRange, [contSensWeight elt: [contSensors at: i]])] plus: // Contactor sensor weight
              Sum(m, i, voltSenRange, [voltSensWeight elt: [voltSensors at: i]])] plus: // Contactor sensor weight
              Sum(m, i, curSenRange, [curSensWeight elt: [curSensors at: i]])] plus: // Contactor sensor weight
              Sum(m, i, voltSenRange, [@([voltDirectToPMUWeight at: i]) mul: [voltSenDirectPMU at: i]])] plus: // Weight direct to PMU
              Sum(m, i, curSenRange, [@([curDirectToPMUWeight at: i]) mul: [curSenDirectPMU at: i]])] plus: // Weight direct to PMU
              Sum(m, i, contSenRange, [@([contDirectToPMUWeight at: i]) mul: [contSenDirectPMU at: i]])] plus: // Weight direct to PMU
              Sum(m, i, contSenRange, [@([senToBusWeight at: i]) mul: [contSenToBus at: i]])] plus: // Weight direct to bus
              Sum(m, i, contSenRange, [@([senToConWeight at: i]) mul: [contSenToCon at: i]])] plus: // Weight direct to Concentrator
              [[useConc[1] mul:@(CON_WEIGHT)] plus: [useConc[2] mul:@(CON_WEIGHT)]]] plus: // Concentrator weight
              [Sum(m, i, RANGE(m, 1, 3), useBus[i]) mul: @(BUS_WGHT)] ]
             ]];

    //[m add: [weight leq: @(MAX_WEIGHT)]];
    
    // Power Draw /////////////////////////
//    [m add: [powUse eq:
//             [[[[Sum(m, i, contSenRange, [contSensPowDraw elt: [contSensors at: i]]) plus: // Sensor Power
//              Sum(m, i, voltSenRange, [voltSensPowDraw elt: [voltSensors at: i]])] plus:
//              Sum(m, i, curSenRange, [curSensPowDraw elt: [curSensors at: i]])] plus:
//             @(BBF1_POW + BBF2_POW)] plus: // Black Box power
//             @(PMU_POW)] // PMU power draw
//     ]];
    
    [m add: [
             [[[[Sum(m, i, contSenRange, [contSensPowDraw elt: [contSensors at: i]]) plus: // Sensor Power
                 Sum(m, i, voltSenRange, [voltSensPowDraw elt: [voltSensors at: i]])] plus:
                Sum(m, i, curSenRange, [curSensPowDraw elt: [curSensors at: i]])] plus:
               @(BBF1_POW + BBF2_POW)] plus: // Black Box power
              @(PMU_POW)] // PMU power draw
              lt: [[mainGenPow elt: g0] plus: [mainGenPow elt: g1]]]];
    
    // Power Gen //////////////////////////
    //[m add: [powUse leq: [[mainGenPow elt: g0] plus: [mainGenPow elt: g1]]]];
    //[m add: [[[mainGenPow elt: g0] plus: [mainGenPow elt: auxgen]] geq: powUse]];
    //[m add: [[[mainGenPow elt: auxgen] plus: [mainGenPow elt: g1]] geq: powUse]];

    // Connectivity ///////////////////////
    for(ORInt i = [contSenRange low]; i <= [contSenRange up]; i++)
        [m add: [[[contSenDirectPMU[i] plus: contSenToCon[i]] plus: contSenToBus[i]] leq: [contSensors[i] gt: NONE]]]; // Connected to PMU, bus or concentrator
    for(ORInt i = [voltSenRange low]; i <= [voltSenRange up]; i++)
        [m add: [[[voltSenDirectPMU[i] plus: voltSenToCon[i]] plus: voltSenToBus[i]] leq: [voltSensors[i] gt: NONE]]]; // Connected to PMU, bus or concentrator
    for(ORInt i = [contSenRange low]; i <= [contSenRange up]; i++)
        [m add: [[[curSenDirectPMU[i] plus: curSenToCon[i]] plus: curSenToBus[i]] leq: [curSensors[i] gt: NONE]]]; // Connected to PMU, bus or concentrator
    
    // Bus ////////////////////////////////
    [m add: [[Sum(m, i, contSenRange, [contSenToBus[i] eq: @(1)]) gt: @(0)] imply: [useBus[1] eq: @(1)]]];
    [m add: [[Sum(m, i, contSenRange, [contSenToBus[i] eq: @(2)]) gt: @(0)] imply: [useBus[2] eq: @(1)]]];
    [m add: [[Sum(m, i, contSenRange, [contSenToBus[i] eq: @(3)]) gt: @(0)] imply: [useBus[3] eq: @(1)]]];
    
    [m add: [[Sum(m, i, voltSenRange, [voltSenToBus[i] eq: @(1)]) gt: @(0)] imply: [useBus[1] eq: @(1)]]];
    [m add: [[Sum(m, i, voltSenRange, [voltSenToBus[i] eq: @(2)]) gt: @(0)] imply: [useBus[2] eq: @(1)]]];
    [m add: [[Sum(m, i, voltSenRange, [voltSenToBus[i] eq: @(3)]) gt: @(0)] imply: [useBus[3] eq: @(1)]]];
    
    [m add: [[Sum(m, i, curSenRange, [curSenToBus[i] eq: @(1)]) gt: @(0)] imply: [useBus[1] eq: @(1)]]];
    [m add: [[Sum(m, i, curSenRange, [curSenToBus[i] eq: @(2)]) gt: @(0)] imply: [useBus[2] eq: @(1)]]];
    [m add: [[Sum(m, i, curSenRange, [curSenToBus[i] eq: @(3)]) gt: @(0)] imply: [useBus[3] eq: @(1)]]];
    
    for(ORInt i = [contSenRange low]; i <= [contSenRange up]; i++)
        [m add: [[contSenToBus[i] eq: @(1)] imply: [contSensors[i] eq: @(SenWithConc)]]]; // If sens. connected to bus, must have its own concentrator
    for(ORInt i = [voltSenRange low]; i <= [voltSenRange up]; i++)
        [m add: [[voltSenToBus[i] eq: @(1)] imply: [voltSensors[i] eq: @(SenWithConc)]]]; // If sens. connected to bus, must have its own concentrator
    for(ORInt i = [curSenRange low]; i <= [curSenRange up]; i++)
        [m add: [[curSenToBus[i] eq: @(1)] imply: [curSensors[i] eq: @(SenWithConc)]]]; // If sens. connected to bus, must have its own concentrator
    
    // Concentrators //////////////////////
    [m add: [[[[[[contSenToCon[CONT_S0] plus: contSenToCon[CONT_S1]] plus: contSenToCon[CONT_S4]] plus: contSenToCon[CONT_S6]] plus: contSenToCon[CONT_S7]] gt: @(0)] imply: [useConc[1] eq: @(1)]]];
    [m add: [[[[[contSenToCon[CONT_S2] plus: contSenToCon[CONT_S3]] plus: contSenToCon[CONT_S5]] plus: contSenToCon[CONT_S8]] gt: @(0)] imply: [useConc[1] eq: @(1)]]];

    // Bus Bandwidth
//    [m add: [bandUse[0] eq: [[Sum(m, i, contSenRange, [[ [contSenToBus[i] eq: @(0)] plus: [contSenToCon[i] eq: @(0)]] mul: contSensBandwith[i]]) plus:
//                          Sum(m, i, voltSenRange, [[[voltSenToBus[i] eq: @(0)] plus: [voltSenToCon[i] eq: @(0)]] mul: voltSensBandwith[i]])] plus:
//                          Sum(m, i, curSenRange, [[[curSenToBus[i] eq: @(0)] plus: [curSenToCon[i] eq: @(0)]] mul: curSensBandwith[i]])]
//                          ]];
    [m add: [bandUse[0] eq: [[Sum(m, i, contSenRange, [[ [contSenToBus[i] eq: @(1)] plus: [contSenToCon[i] eq: @(1)]] mul: contSensBandwith[i]]) plus:
                              Sum(m, i, voltSenRange, [[[voltSenToBus[i] eq: @(1)] plus: [voltSenToCon[i] eq: @(1)]] mul: voltSensBandwith[i]])] plus:
                             Sum(m, i, curSenRange, [[[curSenToBus[i] eq: @(1)] plus: [curSenToCon[i] eq: @(1)]] mul: curSensBandwith[i]])]
             ]];
//    [m add: [bandUse[1] eq: [[Sum(m, i, contSenRange, [[ [contSenToBus[i] eq: @(2)] plus: [contSenToCon[i] eq: @(2)]] mul: contSensBandwith[i]]) plus:
//                              Sum(m, i, voltSenRange, [[[voltSenToBus[i] eq: @(2)] plus: [voltSenToCon[i] eq: @(2)]] mul: voltSensBandwith[i]])] plus:
//                             Sum(m, i, curSenRange, [[[curSenToBus[i] eq: @(2)] plus: [curSenToCon[i] eq: @(2)]] mul: curSensBandwith[i]])]
//             ]];
    [m add: [bandUse[0] leq: @(MAX_BAND)]];
    //[m add: [bandUse[1] leq: @(MAX_BAND)]];
//    [m add: [bandUse[2] leq: @(MAX_BAND)]];
    
    // Path Definitions
    for(ORInt i = [contSenRange low]; i <= [contSenRange up]; i++)
        [m add: [usePath[i] eq: [contSensors[i] gt: NONE]]];
    
    [m add: [usePath[9] imply: [voltSensors[VOLT_S0] gt: NONE]]];
    [m add: [usePath[9] imply: [voltSensors[VOLT_S1] gt: NONE]]];
    [m add: [usePath[10] imply: [voltSensors[VOLT_S0] gt: NONE]]];
    [m add: [usePath[10] imply: [voltSensors[VOLT_S2] gt: NONE]]];
    [m add: [usePath[11] imply: [curSensors[CUR_S0] gt: NONE]]];
    [m add: [usePath[11] imply: [curSensors[CUR_S1] gt: NONE]]];
    [m add: [usePath[12] imply: [curSensors[CUR_S0] gt: NONE]]];
    [m add: [usePath[12] imply: [curSensors[CUR_S2] gt: NONE]]];

    [m add: [usePath[13] imply: [voltSensors[VOLT_S3] gt: NONE]]];
    [m add: [usePath[13] imply: [voltSensors[VOLT_S4] gt: NONE]]];
    [m add: [usePath[14] imply: [voltSensors[VOLT_S4] gt: NONE]]];
    [m add: [usePath[14] imply: [voltSensors[VOLT_S2] gt: NONE]]];
    [m add: [usePath[15] imply: [curSensors[CUR_S3] gt: NONE]]];
    [m add: [usePath[15] imply: [curSensors[CUR_S4] gt: NONE]]];
    [m add: [usePath[16] imply: [curSensors[CUR_S4] gt: NONE]]];
    [m add: [usePath[16] imply: [curSensors[CUR_S2] gt: NONE]]];

    // Path requirements
    [m add: [[[[[usePath[0] plus: usePath[9]] plus: usePath[10]] plus: usePath[11]] plus: usePath[12]] eq: @(2)]]; // CONT 0
    [m add: [usePath[1] eq: @(1)]];
    [m add: [usePath[2] eq: @(1)]];
    [m add: [[[[[usePath[3] plus: usePath[13]] plus: usePath[14]] plus: usePath[15]] plus: usePath[16]] eq: @(2)]]; // CONT 3
    [m add: [usePath[4] eq: @(1)]];
    [m add: [usePath[5] eq: @(1)]];
    [m add: [usePath[6] eq: @(1)]];
    [m add: [usePath[7] eq: @(1)]];
    [m add: [usePath[8] eq: @(1)]];
    
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
    
    // Write Solution to XML ----------------------------------------------------------------------------------
    NSXMLElement* root = [[NSXMLElement alloc] initWithName: @"utc_architecture"];
    
    // Write contSensors
    NSXMLElement* contSensorsRoot = [[NSXMLElement alloc] initWithName: @"contactor_sensors"];
    for(ORInt i = [contSenRange low]; i <= [contSenRange up]; i++) {
        ORInt template = [bestSolution intValue: contSensors[i]];
        NSXMLElement* sensorNode = [[NSXMLElement alloc] initWithName: @"sensor"];
        [sensorNode addAttribute: [NSXMLNode attributeWithName:@"id" stringValue: [NSString stringWithFormat: @"%i", i]]];
        [sensorNode addChild: [[NSXMLElement alloc] initWithName: @"template" stringValue: [NSString stringWithFormat: @"%i", template]]];
        
        NSString* data_string = @"PMU";
        if([bestSolution intValue: contSenToBus[i]]) data_string = @"bus";
        else if([bestSolution intValue: contSenToCon[i]]) data_string = @"concentrator";
        [sensorNode addChild: [[NSXMLElement alloc] initWithName: @"data_connect" stringValue: data_string]];

        [contSensorsRoot addChild: sensorNode];
    }
    [root addChild: contSensorsRoot];
    
    // Write voltSensors
    NSXMLElement* voltSensorsRoot = [[NSXMLElement alloc] initWithName: @"voltage_sensors"];
    for(ORInt i = [voltSenRange low]; i <= [voltSenRange up]; i++) {
        ORInt template = [bestSolution intValue: voltSensors[i]];
        NSXMLElement* sensorNode = [[NSXMLElement alloc] initWithName: @"sensor"];
        [sensorNode addAttribute: [NSXMLNode attributeWithName:@"id" stringValue: [NSString stringWithFormat: @"%i", i]]];
        [sensorNode addChild: [[NSXMLElement alloc] initWithName: @"template" stringValue: [NSString stringWithFormat: @"%i", template]]];
        
        NSString* data_string = @"PMU";
        if([bestSolution intValue: voltSenToBus[i]]) data_string = @"bus";
        else if([bestSolution intValue: voltSenToCon[i]]) data_string = @"concentrator";
        [sensorNode addChild: [[NSXMLElement alloc] initWithName: @"data_connect" stringValue: data_string]];
        
        [voltSensorsRoot addChild: sensorNode];
    }
    [root addChild: voltSensorsRoot];

    // Write curSensors
    NSXMLElement* curSensorsRoot = [[NSXMLElement alloc] initWithName: @"current_sensors"];
    for(ORInt i = [curSenRange low]; i <= [curSenRange up]; i++) {
        ORInt template = [bestSolution intValue: curSensors[i]];
        NSXMLElement* sensorNode = [[NSXMLElement alloc] initWithName: @"sensor"];
        [sensorNode addAttribute: [NSXMLNode attributeWithName:@"id" stringValue: [NSString stringWithFormat: @"%i", i]]];
        [sensorNode addChild: [[NSXMLElement alloc] initWithName: @"template" stringValue: [NSString stringWithFormat: @"%i", template]]];
        
        NSString* data_string = @"PMU";
        if([bestSolution intValue: curSenToBus[i]]) data_string = @"bus";
        else if([bestSolution intValue: curSenToCon[i]]) data_string = @"concentrator";
        [sensorNode addChild: [[NSXMLElement alloc] initWithName: @"data_connect" stringValue: data_string]];
        
        [curSensorsRoot addChild: sensorNode];
    }
    [root addChild: curSensorsRoot];
    
    // Write Generators
    NSXMLElement* generatorRoot = [[NSXMLElement alloc] initWithName: @"generators"];
    ORInt template = [bestSolution intValue: g0];
    NSXMLElement* generatorNode = [[NSXMLElement alloc] initWithName: @"generator"];
    [generatorNode addAttribute: [NSXMLNode attributeWithName:@"id" stringValue: @"Gen0"]];
    [generatorNode addChild: [[NSXMLElement alloc] initWithName: @"template" stringValue: [NSString stringWithFormat: @"%i", template]]];
    [generatorRoot addChild: generatorNode];
    
    template = [bestSolution intValue: g1];
    generatorNode = [[NSXMLElement alloc] initWithName: @"generator"];
    [generatorNode addAttribute: [NSXMLNode attributeWithName:@"id" stringValue: @"Gen1"]];
    [generatorNode addChild: [[NSXMLElement alloc] initWithName: @"template" stringValue: [NSString stringWithFormat: @"%i", template]]];
    [generatorRoot addChild: generatorNode];

    template = [bestSolution intValue: auxgen];
    generatorNode = [[NSXMLElement alloc] initWithName: @"generator"];
    [generatorNode addAttribute: [NSXMLNode attributeWithName:@"id" stringValue: @"APU"]];
    [generatorNode addChild: [[NSXMLElement alloc] initWithName: @"template" stringValue: [NSString stringWithFormat: @"%i", template]]];
    [generatorRoot addChild: generatorNode];
    
    [root addChild: generatorRoot];
    
    // Write Buses
    NSXMLElement* busesRoot = [[NSXMLElement alloc] initWithName: @"data_buses"];
    if([bestSolution intValue: useBus[1]]) {
        ORInt template = 0;
        NSXMLElement* busNode = [[NSXMLElement alloc] initWithName: @"data_bus"];
        [busNode addAttribute: [NSXMLNode attributeWithName:@"id" stringValue: @"bus1"]];
        [busNode addChild: [[NSXMLElement alloc] initWithName: @"template" stringValue: [NSString stringWithFormat: @"%i", template]]];
        [busesRoot addChild: busNode];
    }
    [root addChild: busesRoot];
    
    // Write Concentrators
    NSXMLElement* concRoot = [[NSXMLElement alloc] initWithName: @"concentrators"];
    if([bestSolution intValue: useConc[1]]) {
        ORInt template = 0;
        NSXMLElement* concNode = [[NSXMLElement alloc] initWithName: @"concentrator"];
        [concNode addAttribute: [NSXMLNode attributeWithName:@"id" stringValue: @"conc0"]];
        [concNode addChild: [[NSXMLElement alloc] initWithName: @"template" stringValue: [NSString stringWithFormat: @"%i", template]]];
        [concRoot addChild: concNode];
    }
    if([bestSolution intValue: useConc[2]]) {
        ORInt template = 0;
        NSXMLElement* concNode = [[NSXMLElement alloc] initWithName: @"concentrator"];
        [concNode addAttribute: [NSXMLNode attributeWithName:@"id" stringValue: @"conc1"]];
        [concNode addChild: [[NSXMLElement alloc] initWithName: @"template" stringValue: [NSString stringWithFormat: @"%i", template]]];
        [concRoot addChild: concNode];
    }
    [root addChild: concRoot];
    
    NSXMLDocument* solDoc = [[NSXMLDocument alloc] initWithRootElement: root];
    NSData *xmlData = [solDoc XMLDataWithOptions:NSXMLNodePrettyPrint];
    NSString* outPath = [NSHomeDirectory() stringByAppendingPathComponent:@"UTCSolution.xml"];
    [xmlData writeToFile: outPath atomically:YES];
    NSLog(@"Wrote Solution File: %@", outPath);
    
    for(ORInt i = 0; i <=16; i++)
        NSLog(@"%i, %i", i, [bestSolution intValue: usePath[i]]);
    
    NSLog(@"POW USE: %i", [bestSolution intValue: powUse]);
    
    return 0;
}
