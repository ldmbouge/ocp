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
    VOLT_S0 = 0, VOLT_S1, VOLT_S2, VOLT_S3, VOLT_S4, VOLT_S5, VOLT_S6, VOLT_S7, VOLT_S8, VOLT_S9, VOLT_S10
} VOLT_SENSOR;

typedef enum {
    CUR_S0 = 0, CUR_S1, CUR_S2, CUR_S3, CUR_S4, CUR_S5, CUR_S6, CUR_S7, CUR_S8, CUR_S9, CUR_S10
} CUR_SENSOR;

ORInt rawContSensBandwith[] = {
    85, 75, 85, 69, 81, 157, 108, 86, 92
};

ORInt rawVoltSensBandwith[] = {
    81, 82, 71, 71, 66, 158, 119, 127, 93
};

ORInt rawCurSensBandwith[] = {
    99, 68, 91, 71, 86, 99, 99, 91, 150
};

ORInt rawContDirectToPMUCost[] = {
    1315, 1315, 1210, 1312, 1216, 1212, 1317, 1319, 1219
};

ORInt rawContDirectToPMUWeight[] = {
    1620, 1520, 1580, 1780, 1600, 1770, 1800, 1860, 1400
};


ORInt rawVoltDirectToPMUCost[] = {
    1313, 1317, 1312, 1316, 1522, 1219, 1312, 1321, 1416
};

ORInt rawVoltDirectToPMUWeight[] = {
    1612, 1514, 1670, 1764, 1710, 1710, 1600, 1522, 1630
};

ORInt rawCurDirectToPMUCost[] = {
    1218, 1314, 1316, 1212, 1313, 1311, 1217, 1214, 1318
};

ORInt rawCurDirectToPMUWeight[] = {
    1613, 1613, 1760, 1774, 1700, 1690, 1665, 1632, 1740
};


ORInt rawContToBusCost[] = {
    20, 20, 40, 40, 35, 42, 52, 31, 43
};

ORInt rawContToBusWeight[] = {
    11, 11, 12, 12, 22, 22, 23, 22, 12
};

ORInt rawContToConCost[] = {
    11, 11, 13, 23, 23, 13, 14, 22, 32
};

ORInt rawContToConWeight[] = {
    21, 21, 13, 13, 23, 23, 14, 12, 12
};


ORInt rawVoltToBusCost[] = {
    20, 20, 40, 40, 35, 42, 52, 31, 43
};

ORInt rawVoltToBusWeight[] = {
    11, 11, 12, 12, 22, 22, 23, 22, 12
};

ORInt rawVoltToConCost[] = {
    11, 11, 13, 23, 23, 13, 14, 22, 32
};

ORInt rawVoltToConWeight[] = {
    21, 21, 13, 13, 23, 23, 14, 12, 12
};

ORInt rawCurToBusCost[] = {
    20, 20, 40, 40, 35, 42, 52, 31, 43
};

ORInt rawCurToBusWeight[] = {
    11, 11, 12, 12, 22, 22, 23, 22, 12
};

ORInt rawCurToConCost[] = {
    11, 11, 13, 23, 23, 13, 14, 22, 32
};

ORInt rawCurToConWeight[] = {
    21, 21, 13, 13, 23, 23, 14, 12, 12
};


ORInt numMainGen = 2;
ORInt numOptBuses = 2;
ORInt numOptConcentrators = 3;
ORInt numBackupGen = 1;
ORInt numBatteries = 1;
ORInt numContSensors = 9;
ORInt numVoltSensors = 11;
ORInt numCurSensors = 11;

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
    
    ORInt totalSensorCount = numContSensors + numVoltSensors + numCurSensors;
    id<ORIntRange> genBounds = RANGE(m, 0, numGeneratorTemplates-1);
    id<ORIntRange> genRange = RANGE(m, 0, numMainGen + numBackupGen - 1);
    id<ORIntRange> contSenBounds = RANGE(m, 0, numContSensorTemplates-1);
    id<ORIntRange> contSenRange = RANGE(m, 0, numContSensors-1);
    id<ORIntRange> voltSenBounds = RANGE(m, 0, numVoltSensorTemplates-1);
    id<ORIntRange> voltSenRange = RANGE(m, 0, numVoltSensors-1);
    id<ORIntRange> curSenBounds = RANGE(m, 0, numCurSensorTemplates-1);
    id<ORIntRange> curSenRange = RANGE(m, 0, numCurSensors-1);
    
    id<ORIntRange> concRange = RANGE(m, 1, numOptConcentrators);
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
    id<ORIntArray> contSensConverts = [ORFactory intArray: m range: contSenBounds with: ^ORInt(ORInt i) {
        return [[[[contSensorTemplates[i] elementsForName: @"conversion"] lastObject] stringValue] intValue]; }];
    
    id<ORIntArray> voltSensWeight = [ORFactory intArray: m range: voltSenBounds with: ^ORInt(ORInt i) {
        return [[[[voltSensorTemplates[i] elementsForName: @"weight"] lastObject] stringValue] intValue]; }];
    id<ORIntArray> voltSensCost = [ORFactory intArray: m range: voltSenBounds with: ^ORInt(ORInt i) {
        return [[[[voltSensorTemplates[i] elementsForName: @"cost"] lastObject] stringValue] intValue]; }];
    id<ORIntArray> voltSensPowDraw = [ORFactory intArray: m range: voltSenBounds with: ^ORInt(ORInt i) {
        return [[[[voltSensorTemplates[i] elementsForName: @"power"] lastObject] stringValue] intValue]; }];
    id<ORIntArray> voltSensConverts = [ORFactory intArray: m range: voltSenBounds with: ^ORInt(ORInt i) {
        return [[[[voltSensorTemplates[i] elementsForName: @"conversion"] lastObject] stringValue] intValue]; }];
    
    id<ORIntArray> curSensWeight = [ORFactory intArray: m range: curSenBounds with: ^ORInt(ORInt i) {
        return [[[[curSensorTemplates[i] elementsForName: @"weight"] lastObject] stringValue] intValue]; }];
    id<ORIntArray> curSensCost = [ORFactory intArray: m range: curSenBounds with: ^ORInt(ORInt i) {
        return [[[[curSensorTemplates[i] elementsForName: @"cost"] lastObject] stringValue] intValue]; }];
    id<ORIntArray> curSensPowDraw = [ORFactory intArray: m range: curSenBounds with: ^ORInt(ORInt i) {
        return [[[[curSensorTemplates[i] elementsForName: @"power"] lastObject] stringValue] intValue]; }];
    id<ORIntArray> curSensConverts = [ORFactory intArray: m range: contSenBounds with: ^ORInt(ORInt i) {
        return [[[[contSensorTemplates[i] elementsForName: @"conversion"] lastObject] stringValue] intValue]; }];
    
    // Bus Template Tables
    ORInt MAX_BAND = [[[[busTemplates[0] elementsForName: @"max_bandwidth"] lastObject] stringValue] intValue];
    ORInt BUS_COST = [[[[busTemplates[0] elementsForName: @"cost"] lastObject] stringValue] intValue];;
    ORInt BUS_WGHT = [[[[busTemplates[0] elementsForName: @"weight"] lastObject] stringValue] intValue];;
    
    // Concentrator Template Table
    
    id<ORIntArray> concWeight = [ORFactory intArray: m range: concBounds with: ^ORInt(ORInt i) {
        return [[[[concTemplates[i] elementsForName: @"weight"] lastObject] stringValue] intValue]; }];
    id<ORIntArray> concCost = [ORFactory intArray: m range: concBounds with: ^ORInt(ORInt i) {
        return [[[[concTemplates[i] elementsForName: @"cost"] lastObject] stringValue] intValue]; }];
    id<ORIntArray> concPowDraw = [ORFactory intArray: m range: concBounds with: ^ORInt(ORInt i) {
        return [[[[concTemplates[i] elementsForName: @"power"] lastObject] stringValue] intValue]; }];
    id<ORIntArray> concMaxConn = [ORFactory intArray: m range: concBounds with: ^ORInt(ORInt i) {
        return [[[[concTemplates[i] elementsForName: @"max_connections"] lastObject] stringValue] intValue]; }];
    id<ORIntArray> concBand = [ORFactory intArray: m range: concBounds with: ^ORInt(ORInt i) {
        return [[[[concTemplates[i] elementsForName: @"bandwidth"] lastObject] stringValue] intValue]; }];
    
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
    id<ORIntVarArray> contSenToCon = [ORFactory intVarArray: m range: contSenRange bounds: RANGE(m, 0, numOptConcentrators)];
    id<ORIntVarArray> voltSenToCon = [ORFactory intVarArray: m range: voltSenRange bounds: RANGE(m, 0, numOptConcentrators)];
    id<ORIntVarArray> curSenToCon = [ORFactory intVarArray: m range: curSenRange bounds: RANGE(m, 0, numOptConcentrators)];
    
    // Connected to Bus
    id<ORIntVarArray> contSenToBus = [ORFactory intVarArray: m range: contSenRange bounds: RANGE(m, 0, numOptBuses)];
    id<ORIntVarArray> voltSenToBus = [ORFactory intVarArray: m range: voltSenRange bounds: RANGE(m, 0, numOptBuses)];
    id<ORIntVarArray> curSenToBus = [ORFactory intVarArray: m range: curSenRange bounds: RANGE(m, 0, numOptBuses)];
    
    // Concetrators
    id<ORIntVarArray> conc = [ORFactory intVarArray: m range: concRange bounds: RANGE(m, 0, numConcTemplates-1)];
    id<ORIntVarArray> useConc = [ORFactory intVarArray: m range: concRange bounds: boolBounds];
    id<ORIntVarArray> numConcConn = [ORFactory intVarArray: m range: concRange bounds: RANGE(m, 0, totalSensorCount)];
    id<ORIntVarArray> concToBus = [ORFactory intVarArray: m range: concRange bounds: RANGE(m, 0, numOptBuses)];
    
    
    // Bus
    id<ORIntVarArray> useBus = [ORFactory intVarArray: m range: RANGE(m, 1, numOptBuses) bounds: boolBounds];
    id<ORIntVarArray> numBusConn = [ORFactory intVarArray: m range: RANGE(m, 1, numOptBuses) bounds: RANGE(m, 0, totalSensorCount + numOptConcentrators)];

    
    id<ORIntVar> powUse = [ORFactory intVar: m bounds: RANGE(m, 0, 10000)];
    id<ORIntVarArray> bandUse = [ORFactory intVarArray: m range: RANGE(m, 1, numOptBuses) bounds: RANGE(m, 0, MAX_BAND)];
    id<ORIntVar> cost = [ORFactory intVar: m bounds: RANGE(m, 0, 25000)];
    id<ORIntVar> weight = [ORFactory intVar: m bounds: RANGE(m, 0, 25000)];
    
    // data paths
    id<ORIntRange> pathRange5 = RANGE(m, 0, 4);
    id<ORIntRange> pathRange3 = RANGE(m, 0, 2);
    id<ORIntVarArray> usePath0 = [ORFactory intVarArray: m range: pathRange5 bounds: boolBounds];
    id<ORIntVarArray> usePath1 = [ORFactory intVarArray: m range: pathRange3 bounds: boolBounds];
    id<ORIntVarArray> usePath2 = [ORFactory intVarArray: m range: pathRange3 bounds: boolBounds];
    id<ORIntVarArray> usePath3 = [ORFactory intVarArray: m range: pathRange5 bounds: boolBounds];
    id<ORIntVarArray> usePath4 = [ORFactory intVarArray: m range: pathRange5 bounds: boolBounds];
    id<ORIntVarArray> usePath5 = [ORFactory intVarArray: m range: pathRange5 bounds: boolBounds];
    id<ORIntVarArray> usePath6 = [ORFactory intVarArray: m range: pathRange5 bounds: boolBounds];
    id<ORIntVarArray> usePath7 = [ORFactory intVarArray: m range: pathRange5 bounds: boolBounds];
    id<ORIntVarArray> usePath8 = [ORFactory intVarArray: m range: pathRange5 bounds: boolBounds];

    
    
    // Template Tables -----------------------------------------------------------------------
    
    id<ORIntArray> contSensBandwith = [ORFactory intArray: m range: contSenRange values: rawVoltSensBandwith];
    id<ORIntArray> voltSensBandwith = [ORFactory intArray: m range: voltSenRange values: rawVoltSensBandwith];
    id<ORIntArray> curSensBandwith = [ORFactory intArray: m range: curSenRange values: rawCurSensBandwith];
    
    id<ORIntArray> contDirectToPMUCost = [ORFactory intArray: m range: contSenRange values: rawContDirectToPMUCost];
    id<ORIntArray> contDirectToPMUWeight = [ORFactory intArray: m range: contSenRange values: rawContDirectToPMUWeight];
    
    id<ORIntArray> voltDirectToPMUCost = [ORFactory intArray: m range: voltSenRange values: rawVoltDirectToPMUCost];
    id<ORIntArray> voltDirectToPMUWeight = [ORFactory intArray: m range: voltSenRange values: rawVoltDirectToPMUWeight];
    
    id<ORIntArray> curDirectToPMUCost = [ORFactory intArray: m range: curSenRange values: rawCurDirectToPMUCost];
    id<ORIntArray> curDirectToPMUWeight = [ORFactory intArray: m range: curSenRange values: rawCurDirectToPMUWeight];
    
    id<ORIntArray> contToBusCost = [ORFactory intArray: m range: contSenRange values: rawContToBusCost];
    id<ORIntArray> contToBusWeight = [ORFactory intArray: m range: contSenRange values: rawContToBusWeight];
    
    id<ORIntArray> contToConCost = [ORFactory intArray: m range: contSenRange values: rawContToConCost];
    id<ORIntArray> contToConWeight = [ORFactory intArray: m range: contSenRange values: rawContToConWeight];
    
    id<ORIntArray> voltToBusCost = [ORFactory intArray: m range: voltSenRange values: rawVoltToBusCost];
    id<ORIntArray> voltToBusWeight = [ORFactory intArray: m range: voltSenRange values: rawVoltToBusWeight];
    
    id<ORIntArray> voltToConCost = [ORFactory intArray: m range: voltSenRange values: rawVoltToConCost];
    id<ORIntArray> voltToConWeight = [ORFactory intArray: m range: voltSenRange values: rawVoltToConWeight];
    
    id<ORIntArray> curToBusCost = [ORFactory intArray: m range: curSenRange values: rawCurToBusCost];
    id<ORIntArray> curToBusWeight = [ORFactory intArray: m range: curSenRange values: rawCurToBusWeight];
    
    id<ORIntArray> curToConCost = [ORFactory intArray: m range: curSenRange values: rawCurToConCost];
    id<ORIntArray> curToConWeight = [ORFactory intArray: m range: curSenRange values: rawCurToConWeight];
    
    [m minimize: [cost plus: weight]];
    
    // Cost ///////////////////////////
    [m add: [cost eq:
             [[[[[[[[[[[[[[[[[mainGenCost elt: g0] plus: [mainGenCost elt: g1]] plus: [mainGenCost elt: auxgen]] plus: // Gen cost
                       Sum(m, i, voltSenRange, [voltSensCost elt: [voltSensors at: i]])] plus: // Cost of contactor sensors
                      Sum(m, i, curSenRange, [curSensCost elt: [curSensors at: i]])] plus: // Cost of contactor sensors
                     Sum(m, i, contSenRange, [contSensCost elt: [contSensors at: i]])] plus: // Cost of contactor sensors
                    Sum(m, i, contSenRange, [@([contDirectToPMUCost at: i]) mul: [contSenDirectPMU at: i]])] plus: // Cost direct to PMU
                   Sum(m, i, voltSenRange, [@([voltDirectToPMUCost at: i]) mul: [voltSenDirectPMU at: i]])] plus: // Cost direct to PMU
                  Sum(m, i, curSenRange, [@([curDirectToPMUCost at: i]) mul: [curSenDirectPMU at: i]])] plus: // Cost direct to PMU
                 Sum(m, i, contSenRange, [@([contToBusCost at: i]) mul: [[contSenToBus at: i] gt: @(0)]])] plus: // Cost direct to bus
                Sum(m, i, contSenRange, [@([contToConCost at: i]) mul: [[contSenToCon at: i] gt: @(0)]])] plus: // Cost direct to Concentrator
               Sum(m, i, voltSenRange, [@([voltToBusCost at: i]) mul: [[voltSenToBus at: i] gt: @(0)]])] plus: // Cost direct to bus
              Sum(m, i, voltSenRange, [@([voltToConCost at: i]) mul: [[voltSenToCon at: i] gt: @(0)]])] plus: // Cost direct to Concentrator
            Sum(m, i, concRange, [concCost elt: [conc at: i]])] plus: // Concentrator cost
                Sum(m, i, curSenRange, [@([curToBusCost at: i]) mul: [[curSenToBus at: i] gt: @(0)]])] plus: // Cost direct to bus
             Sum(m, i, curSenRange, [@([curToConCost at: i]) mul: [[curSenToCon at: i] gt: @(0)]])] plus: // Cost direct to Concentrator
              [Sum(m, i, RANGE(m, 1, numOptBuses), useBus[i]) mul: @(BUS_COST)]] // Bus Cost
             ]];
    
    // Weight /////////////////////////
    [m add: [weight eq:
             [[[[[[[[[[[[[[[[[mainGenWeight elt: g0] plus: [mainGenWeight elt: g1]] plus: [mainGenWeight elt: auxgen]] plus: // Gen weight
                       Sum(m, i, contSenRange, [contSensWeight elt: [contSensors at: i]])] plus: // Contactor sensor weight
                      Sum(m, i, voltSenRange, [voltSensWeight elt: [voltSensors at: i]])] plus: // Contactor sensor weight
                     Sum(m, i, curSenRange, [curSensWeight elt: [curSensors at: i]])] plus: // Contactor sensor weight
                    Sum(m, i, voltSenRange, [@([voltDirectToPMUWeight at: i]) mul: [voltSenDirectPMU at: i]])] plus: // Weight direct to PMU
                   Sum(m, i, curSenRange, [@([curDirectToPMUWeight at: i]) mul: [curSenDirectPMU at: i]])] plus: // Weight direct to PMU
                  Sum(m, i, contSenRange, [@([contDirectToPMUWeight at: i]) mul: [contSenDirectPMU at: i]])] plus: // Weight direct to PMU
                 Sum(m, i, contSenRange, [@([contToBusWeight at: i]) mul: [contSenToBus at: i]])] plus: // Weight direct to bus
                Sum(m, i, contSenRange, [@([contToConWeight at: i]) mul: [contSenToCon at: i]])] plus: // Weight direct to Concentrator
               Sum(m, i, voltSenRange, [@([voltToBusWeight at: i]) mul: [voltSenToBus at: i]])] plus: // Weight direct to bus
              Sum(m, i, voltSenRange, [@([voltToConWeight at: i]) mul: [voltSenToCon at: i]])] plus: // Weight direct to Concentrator
               Sum(m, i, curSenRange, [@([curToBusWeight at: i]) mul: [curSenToBus at: i]])] plus: // Weight direct to bus
              Sum(m, i, curSenRange, [@([curToConWeight at: i]) mul: [curSenToCon at: i]])] plus: // Weight direct to Concentrator
               Sum(m, i, concRange, [concWeight elt: [conc at: i]])] plus: // Concentrator weight
              [Sum(m, i, RANGE(m, 1, numOptBuses), useBus[i]) mul: @(BUS_WGHT)] ]
             ]];
    
    //[m add: [weight leq: @(MAX_WEIGHT)]];
    
    // Power Draw /////////////////////////
    [m add: [powUse eq:
             [[[[[Sum(m, i, contSenRange, [contSensPowDraw elt: [contSensors at: i]]) plus: // Sensor Power
                  Sum(m, i, voltSenRange, [voltSensPowDraw elt: [voltSensors at: i]])] plus:
                 Sum(m, i, curSenRange, [curSensPowDraw elt: [curSensors at: i]])] plus:
                Sum(m, i, concRange, [concPowDraw elt: [conc at: i]])] plus:
               @(BBF1_POW + BBF2_POW)] plus: // Black Box power
              @(PMU_POW)] // PMU power draw
             ]];
    
    // Power Gen //////////////////////////
    [m add: [powUse leq: [[mainGenPow elt: g0] plus: [mainGenPow elt: g1]]]];
    [m add: [powUse leq: [[mainGenPow elt: g0] plus: [mainGenPow elt: auxgen]]]];
    [m add: [powUse leq: [[mainGenPow elt: auxgen] plus: [mainGenPow elt: g1]]]];
    
    // Connectivity ///////////////////////
    for(ORInt i = [contSenRange low]; i <= [contSenRange up]; i++)
        [m add: [[[[contSenDirectPMU[i] plus: contSenToCon[i]] plus: contSenToBus[i]] gt: @(0)] eq: [contSensors[i] gt: NONE]]]; // Connected to PMU, bus or concentrator
    for(ORInt i = [voltSenRange low]; i <= [voltSenRange up]; i++)
        [m add: [[[[voltSenDirectPMU[i] plus: voltSenToCon[i]] plus: voltSenToBus[i]] gt: @(0)] eq: [voltSensors[i] gt: NONE]]]; // Connected to PMU, bus or concentrator
    for(ORInt i = [curSenRange low]; i <= [curSenRange up]; i++)
        [m add: [[[[curSenDirectPMU[i] plus: curSenToCon[i]] plus: curSenToBus[i]] gt: @(0)] eq: [curSensors[i] gt: NONE] ]]; // Connected to PMU, bus or concentrator
    
    // If not connected to PMU directly, must have a sensor capable of digital conversion
    for(ORInt i = [contSenRange low]; i <= [contSenRange up]; i++)
        [m add: [[[contSensors[i] gt: NONE] land: [contSenDirectPMU[i] neq: @(1)]] eq: [@(1) leq: [contSensConverts elt: contSensors[i]]]]];
    for(ORInt i = [voltSenRange low]; i <= [voltSenRange up]; i++)
        [m add: [[[voltSensors[i] gt: NONE] land: [voltSenDirectPMU[i] neq: @(1)]] eq: [@(1) leq: [voltSensConverts elt: voltSensors[i]]]]];
    for(ORInt i = [curSenRange low]; i <= [curSenRange up]; i++)
        [m add: [[[curSensors[i] gt: NONE] land: [curSenDirectPMU[i] neq: @(1)]] eq: [@(1) leq: [curSensConverts elt: curSensors[i]]]]];
    
    // Bus ////////////////////////////////
    for(ORInt b = 1; b <= numOptBuses; b++) {
        [m add: [[[[Sum(m, i, contSenRange, [contSenToBus[i] eq: @(b)]) plus:
                   Sum(m, i, voltSenRange, [voltSenToBus[i] eq: @(b)])] plus:
                  Sum(m, i, concRange, [concToBus[i] eq: @(b)])] plus:
                  Sum(m, i, curSenRange, [curSenToBus[i] eq: @(b)])] eq: numBusConn[b]]];
        [m add: [[useBus[b] eq: @(1)] eq: [numBusConn[b] gt: @(0)]]];
    }
    
    // Concentrators //////////////////////
    
    // Connection count for concentrators
    for(ORInt k = 1; k <= numOptConcentrators; k++) {
        [m add: [[[Sum(m, i, contSenRange, [contSenToCon[i] eq: @(k)]) plus:
                   Sum(m, i, voltSenRange, [voltSenToCon[i] eq: @(k)])] plus:
                  Sum(m, i, curSenRange, [curSenToCon[i] eq: @(k)])] eq: numConcConn[k]]];
    }
    
    // Use concentrators
    for(ORInt k = 1; k <= numOptConcentrators; k++) {
        [m add: [[useConc[k] eq: @(1)] eq: [numConcConn[k] gt: @(0)]]];
        [m add: [[useConc[k] eq: @(1)] eq: [conc[k] neq: NONE]]];
    }
    
    // Limit number of concentrator connections
    for(ORInt k = 1; k <= numOptConcentrators; k++) {
        [m add: [numConcConn[k] leq: [concMaxConn elt: conc[k]]]];
    }
    
    // Connect to a bus if concentrator in use
    for(ORInt k = 1; k <= numOptConcentrators; k++) {
        [m add: [[useConc[k] eq: @(1)] eq: [concToBus[k] neq: NONE]]];
    }
    
    // Bus Bandwidth
    for(ORInt b = 1; b <= numOptBuses; b++) {
        [m add: [bandUse[b] eq: [[[
                                   Sum(m, i, contSenRange, [[contSenToBus[i] eq: @(b)] mul: contSensBandwith[i]]) plus:
                                   Sum(m, i, voltSenRange, [[voltSenToBus[i] eq: @(b)] mul: voltSensBandwith[i]])] plus:
                                  Sum(m, i, curSenRange, [[curSenToBus[i] eq: @(b)] mul: curSensBandwith[i]])] plus:
                                 Sum(m, i, concRange, [[concToBus[i] eq: @(b)] mul: [concBand elt: conc[i]]])
                                 ]]];
        [m add: [bandUse[b] leq: @(MAX_BAND)]];
    }
    
    
    
    // Path Definitions
    [m add: [[usePath0[0] eq: @(1)] eq: [contSensors[CONT_S0] gt: NONE]]];
    [m add: [[usePath0[1] eq: @(1)] eq: [voltSensors[VOLT_S0] gt: NONE]]];
    [m add: [[usePath0[1] eq: @(1)] eq: [voltSensors[VOLT_S1] gt: NONE]]];
    [m add: [[usePath0[2] eq: @(1)] eq: [voltSensors[VOLT_S0] gt: NONE]]];
    [m add: [[usePath0[2] eq: @(1)] eq: [voltSensors[VOLT_S2] gt: NONE]]];
    [m add: [[usePath0[3] eq: @(1)] eq: [curSensors[CUR_S0] gt: NONE]]];
    [m add: [[usePath0[3] eq: @(1)] eq: [curSensors[CUR_S1] gt: NONE]]];
    [m add: [[usePath0[4] eq: @(1)] eq: [curSensors[CUR_S0] gt: NONE]]];
    [m add: [[usePath0[4] eq: @(1)] eq: [curSensors[CUR_S2] gt: NONE]]];
    
    [m add: [[usePath1[0] eq: @(1)] eq: [contSensors[CONT_S1] gt: NONE]]];
    [m add: [[usePath1[1] eq: @(1)] eq: [voltSensors[VOLT_S1] gt: NONE]]];
    [m add: [[usePath1[1] eq: @(1)] eq: [voltSensors[VOLT_S2] gt: NONE]]];
    [m add: [[usePath1[2] eq: @(1)] eq: [curSensors[CUR_S1] gt: NONE]]];
    [m add: [[usePath1[2] eq: @(1)] eq: [curSensors[CUR_S2] gt: NONE]]];
    
    [m add: [[usePath2[0] eq: @(1)] eq: [contSensors[CONT_S2] gt: NONE]]];
    [m add: [[usePath2[1] eq: @(1)] eq: [voltSensors[VOLT_S2] gt: NONE]]];
    [m add: [[usePath2[1] eq: @(1)] eq: [voltSensors[VOLT_S3] gt: NONE]]];
    [m add: [[usePath2[2] eq: @(1)] eq: [curSensors[CUR_S2] gt: NONE]]];
    [m add: [[usePath2[2] eq: @(1)] eq: [curSensors[CUR_S3] gt: NONE]]];

    [m add: [[usePath3[0] eq: @(1)] eq: [contSensors[CONT_S3] gt: NONE]]];
    [m add: [[usePath3[1] eq: @(1)] eq: [voltSensors[VOLT_S4] gt: NONE]]];
    [m add: [[usePath3[1] eq: @(1)] eq: [voltSensors[VOLT_S3] gt: NONE]]];
    [m add: [[usePath3[2] eq: @(1)] eq: [voltSensors[VOLT_S4] gt: NONE]]];
    [m add: [[usePath3[2] eq: @(1)] eq: [voltSensors[VOLT_S2] gt: NONE]]];
    [m add: [[usePath3[3] eq: @(1)] eq: [curSensors[CUR_S4] gt: NONE]]];
    [m add: [[usePath3[3] eq: @(1)] eq: [curSensors[CUR_S3] gt: NONE]]];
    [m add: [[usePath3[4] eq: @(1)] eq: [curSensors[CUR_S4] gt: NONE]]];
    [m add: [[usePath3[4] eq: @(1)] eq: [curSensors[CUR_S2] gt: NONE]]];
    
    [m add: [[usePath4[0] eq: @(1)] eq: [contSensors[CONT_S4] gt: NONE]]];
    [m add: [[usePath4[1] eq: @(1)] eq: [voltSensors[VOLT_S5] gt: NONE]]];
    [m add: [[usePath4[1] eq: @(1)] eq: [voltSensors[VOLT_S6] gt: NONE]]];
    [m add: [[usePath4[2] eq: @(1)] eq: [voltSensors[VOLT_S5] gt: NONE]]];
    [m add: [[usePath4[2] eq: @(1)] eq: [voltSensors[VOLT_S1] gt: NONE]]];
    [m add: [[usePath4[3] eq: @(1)] eq: [curSensors[CUR_S5] gt: NONE]]];
    [m add: [[usePath4[3] eq: @(1)] eq: [curSensors[CUR_S6] gt: NONE]]];
    [m add: [[usePath4[4] eq: @(1)] eq: [curSensors[CUR_S5] gt: NONE]]];
    [m add: [[usePath4[4] eq: @(1)] eq: [curSensors[CUR_S1] gt: NONE]]];
    
    [m add: [[usePath5[0] eq: @(1)] eq: [contSensors[CONT_S5] gt: NONE]]];
    [m add: [[usePath5[1] eq: @(1)] eq: [voltSensors[VOLT_S8] gt: NONE]]];
    [m add: [[usePath5[1] eq: @(1)] eq: [voltSensors[VOLT_S7] gt: NONE]]];
    [m add: [[usePath5[2] eq: @(1)] eq: [voltSensors[VOLT_S8] gt: NONE]]];
    [m add: [[usePath5[2] eq: @(1)] eq: [voltSensors[VOLT_S3] gt: NONE]]];
    [m add: [[usePath5[3] eq: @(1)] eq: [curSensors[CUR_S8] gt: NONE]]];
    [m add: [[usePath5[3] eq: @(1)] eq: [curSensors[CUR_S7] gt: NONE]]];
    [m add: [[usePath5[4] eq: @(1)] eq: [curSensors[CUR_S8] gt: NONE]]];
    [m add: [[usePath5[4] eq: @(1)] eq: [curSensors[CUR_S3] gt: NONE]]];
    
    [m add: [[usePath6[0] eq: @(1)] eq: [contSensors[CONT_S6] gt: NONE]]];
    [m add: [[usePath6[1] eq: @(1)] eq: [voltSensors[VOLT_S9] gt: NONE]]];
    [m add: [[usePath6[1] eq: @(1)] eq: [voltSensors[VOLT_S6] gt: NONE]]];
    [m add: [[usePath6[2] eq: @(1)] eq: [voltSensors[VOLT_S9] gt: NONE]]];
    [m add: [[usePath6[2] eq: @(1)] eq: [voltSensors[VOLT_S1] gt: NONE]]];
    [m add: [[usePath6[3] eq: @(1)] eq: [curSensors[CUR_S9] gt: NONE]]];
    [m add: [[usePath6[3] eq: @(1)] eq: [curSensors[CUR_S6] gt: NONE]]];
    [m add: [[usePath6[4] eq: @(1)] eq: [curSensors[CUR_S9] gt: NONE]]];
    [m add: [[usePath6[4] eq: @(1)] eq: [curSensors[CUR_S1] gt: NONE]]];
    
    [m add: [[usePath7[0] eq: @(1)] eq: [contSensors[CONT_S7] gt: NONE]]];
    [m add: [[usePath7[1] eq: @(1)] eq: [voltSensors[VOLT_S10] gt: NONE]]];
    [m add: [[usePath7[1] eq: @(1)] eq: [voltSensors[VOLT_S6] gt: NONE]]];
    [m add: [[usePath7[2] eq: @(1)] eq: [voltSensors[VOLT_S10] gt: NONE]]];
    [m add: [[usePath7[2] eq: @(1)] eq: [voltSensors[VOLT_S1] gt: NONE]]];
    [m add: [[usePath7[3] eq: @(1)] eq: [curSensors[CUR_S10] gt: NONE]]];
    [m add: [[usePath7[3] eq: @(1)] eq: [curSensors[CUR_S6] gt: NONE]]];
    [m add: [[usePath7[4] eq: @(1)] eq: [curSensors[CUR_S10] gt: NONE]]];
    [m add: [[usePath7[4] eq: @(1)] eq: [curSensors[CUR_S1] gt: NONE]]];
    
    [m add: [[usePath8[0] eq: @(1)] eq: [contSensors[CONT_S8] gt: NONE]]];
    [m add: [[usePath8[1] eq: @(1)] eq: [voltSensors[VOLT_S10] gt: NONE]]];
    [m add: [[usePath8[1] eq: @(1)] eq: [voltSensors[VOLT_S7] gt: NONE]]];
    [m add: [[usePath8[2] eq: @(1)] eq: [voltSensors[VOLT_S10] gt: NONE]]];
    [m add: [[usePath8[2] eq: @(1)] eq: [voltSensors[VOLT_S3] gt: NONE]]];
    [m add: [[usePath8[3] eq: @(1)] eq: [curSensors[CUR_S10] gt: NONE]]];
    [m add: [[usePath8[3] eq: @(1)] eq: [curSensors[CUR_S7] gt: NONE]]];
    [m add: [[usePath8[4] eq: @(1)] eq: [curSensors[CUR_S10] gt: NONE]]];
    [m add: [[usePath8[4] eq: @(1)] eq: [curSensors[CUR_S3] gt: NONE]]];
    
    // Path requirements
    [m add: [@(3) leq: Sum(m, i, pathRange5, usePath0[i])]];
    [m add: [@(1) leq: Sum(m, i, pathRange3, usePath1[i])]];
    [m add: [@(1) leq: Sum(m, i, pathRange3, usePath2[i])]];
    [m add: [@(3) leq: Sum(m, i, pathRange5, usePath3[i])]];
    [m add: [@(2) leq: Sum(m, i, pathRange5, usePath4[i])]];
    [m add: [@(2) leq: Sum(m, i, pathRange5, usePath5[i])]];
    [m add: [@(1) leq: Sum(m, i, pathRange5, usePath6[i])]];
    [m add: [@(1) leq: Sum(m, i, pathRange5, usePath7[i])]];
    [m add: [@(1) leq: Sum(m, i, pathRange5, usePath8[i])]];
    
    //NSLog(@"Sol count: %li", [sols count]);  // this only prints the number of solutions on the way to the global optimum.
    
    // Write Solution to XML ----------------------------------------------------------------------------------
    void(^writeOut)(id<ORSolution>) = ^(id<ORSolution> bestSolution){
    NSXMLElement* root = [[NSXMLElement alloc] initWithName: @"utc_architecture"];
    
    // Write contSensors
    NSXMLElement* contSensorsRoot = [[NSXMLElement alloc] initWithName: @"contactor_sensors"];
    for(ORInt i = [contSenRange low]; i <= [contSenRange up]; i++) {
        ORInt template = [bestSolution intValue: contSensors[i]];
        NSXMLElement* sensorNode = [[NSXMLElement alloc] initWithName: @"sensor"];
        [sensorNode addAttribute: [NSXMLNode attributeWithName:@"id" stringValue: [NSString stringWithFormat: @"%i", i]]];
        [sensorNode addChild: [[NSXMLElement alloc] initWithName: @"template" stringValue: [NSString stringWithFormat: @"%i", template]]];
        
        NSString* data_string = @"none";
        if([bestSolution intValue: contSenDirectPMU[i]]) data_string = @"PMU";
        else if([bestSolution intValue: contSenToBus[i]]) data_string = [NSString stringWithFormat: @"bus %i", [bestSolution intValue: contSenToBus[i]]];
        else if([bestSolution intValue: contSenToCon[i]]) data_string = [NSString stringWithFormat: @"concentrator %i", [bestSolution intValue: contSenToCon[i]]];
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
        
        NSString* data_string = @"none";
        if([bestSolution intValue: voltSenDirectPMU[i]]) data_string = @"PMU";
        else if([bestSolution intValue: voltSenToBus[i]]) data_string = [NSString stringWithFormat: @"bus %i", [bestSolution intValue: voltSenToBus[i]]];
        else if([bestSolution intValue: voltSenToCon[i]]) data_string = [NSString stringWithFormat: @"concentrator %i", [bestSolution intValue: voltSenToCon[i]]];
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
        
        NSString* data_string = @"none";
        if([bestSolution intValue: curSenDirectPMU[i]]) data_string = @"PMU";
        else if([bestSolution intValue: curSenToBus[i]]) data_string = [NSString stringWithFormat: @"bus %i", [bestSolution intValue: curSenToBus[i]]];
        else if([bestSolution intValue: curSenToCon[i]]) data_string = [NSString stringWithFormat: @"concentrator %i", [bestSolution intValue: curSenToCon[i]]];
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
    if([bestSolution intValue: useBus[2]]) {
        ORInt template = 0;
        NSXMLElement* busNode = [[NSXMLElement alloc] initWithName: @"data_bus"];
        [busNode addAttribute: [NSXMLNode attributeWithName:@"id" stringValue: @"bus2"]];
        [busNode addChild: [[NSXMLElement alloc] initWithName: @"template" stringValue: [NSString stringWithFormat: @"%i", template]]];
        [busesRoot addChild: busNode];
    }
    [root addChild: busesRoot];
    
    // Write Concentrators
    NSXMLElement* concRoot = [[NSXMLElement alloc] initWithName: @"concentrators"];
    if([bestSolution intValue: useConc[1]]) {
        ORInt template = [bestSolution intValue: conc[1]];
        NSXMLElement* concNode = [[NSXMLElement alloc] initWithName: @"concentrator"];
        [concNode addAttribute: [NSXMLNode attributeWithName:@"id" stringValue: @"conc1"]];
        [concNode addChild: [[NSXMLElement alloc] initWithName: @"template" stringValue: [NSString stringWithFormat: @"%i", template]]];
        [concRoot addChild: concNode];
    }
    if([bestSolution intValue: useConc[2]]) {
        ORInt template = [bestSolution intValue: conc[2]];
        NSXMLElement* concNode = [[NSXMLElement alloc] initWithName: @"concentrator"];
        [concNode addAttribute: [NSXMLNode attributeWithName:@"id" stringValue: @"conc2"]];
        [concNode addChild: [[NSXMLElement alloc] initWithName: @"template" stringValue: [NSString stringWithFormat: @"%i", template]]];
        [concRoot addChild: concNode];
    }
    if([bestSolution intValue: useConc[3]]) {
        ORInt template = [bestSolution intValue: conc[3]];
        NSXMLElement* concNode = [[NSXMLElement alloc] initWithName: @"concentrator"];
        [concNode addAttribute: [NSXMLNode attributeWithName:@"id" stringValue: @"conc3"]];
        [concNode addChild: [[NSXMLElement alloc] initWithName: @"template" stringValue: [NSString stringWithFormat: @"%i", template]]];
        [concRoot addChild: concNode];
    }
    [root addChild: concRoot];
    
    NSXMLDocument* solDoc = [[NSXMLDocument alloc] initWithRootElement: root];
    NSData *xmlData = [solDoc XMLDataWithOptions:NSXMLNodePrettyPrint];
    NSString* outPath = [NSHomeDirectory() stringByAppendingPathComponent:@"UTCSolution.xml"];
    [xmlData writeToFile: outPath atomically:YES];
    NSLog(@"Wrote Solution File: %@", outPath);
    };
    
    
    id<CPProgram> p = [ORFactory createCPProgram: m];
    //id<CPHeuristic> h = [p createIBS];
    ORTimeval cpu0 = [ORRuntimeMonitor now];
    id<CPHeuristic> h = [p createIBS];
    [p solve: ^{
        //[p limitTime: 30 * 1000 in: ^{
        [p labelHeuristic: h];
        NSLog(@"Solution cost: %i", [[[p captureSolution] objectiveValue] intValue]);
        //}];
        id<ORSolution> s = [p captureSolution];
        writeOut(s);
        for(ORInt k = 1; k <= numOptConcentrators; k++)
            NSLog(@"numConn %i: %i, use: %i", k, [s intValue: numConcConn[k]], [s intValue: useConc[k]]);
        NSLog(@"path0: %i %i %i %i %i", [s intValue: usePath0[0]], [s intValue: usePath0[1]], [s intValue: usePath0[2]], [s intValue: usePath0[3]], [s intValue: usePath0[4]]);
    }];
    //    [p solve];
    //id<ORSolutionPool> sols = [p solutionPool];
    //id<ORSolution> bestSolution = [sols best];
    ORTimeval cpu1 = [ORRuntimeMonitor elapsedSince:cpu0];
    NSLog(@"Time to solution: %ld",cpu1.tv_sec * 1000 + cpu1.tv_usec/1000);
    
//    for(ORInt i = 0; i <=16; i++)
//        NSLog(@"%i, %i", i, [bestSolution intValue: usePath[i]]);
//    
//    NSLog(@"POW USE: %i", [bestSolution intValue: powUse]);
//    
//    for(ORInt k = 1; k <= numOptConcentrators; k++)
//        NSLog(@"concToBus %i: %i", k, [bestSolution intValue: concToBus[k]]);
//    
//    for(ORInt k = 1; k <= numOptBuses; k++)
//        NSLog(@"useBus %i: %i", k, [bestSolution intValue: useBus[k]]);
    
    return 0;
}
