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
#import <ORModeling/ORLinearize.h>
#import <ORProgram/ORRunnable.h>


#define NONE @(0)

typedef enum {
    L_G0 = 0, L_G1, L_G2,
    L_CONT_S0, L_CONT_S1, L_CONT_S2, L_CONT_S3, L_CONT_S4, L_CONT_S5, L_CONT_S6, L_CONT_S7, L_CONT_S8,
    L_S0, S1, L_S2, L_S3, L_S4, L_S5, L_S6, L_S7, L_S8, L_S9, L_S10,
    L_CONC_0, L_CONC_1, L_CONC_2 , L_CONC_3,
    L_BUS_0, L_BUS_1, L_BUS_2 , L_BUS_3,
    L_PMU_0, L_PMU_1, L_PMU_2
} COMPONENT_ID;

typedef enum {
    CONT_S0 = 0, CONT_S1, CONT_S2, CONT_S3, CONT_S4, CONT_S5, CONT_S6, CONT_S7, CONT_S8
} CONT_SENSOR;

typedef enum {
    VOLT_S0 = 0, VOLT_S1, VOLT_S2, VOLT_S3, VOLT_S4, VOLT_S5, VOLT_S6, VOLT_S7, VOLT_S8, VOLT_S9, VOLT_S10
} VOLT_SENSOR;

typedef enum {
    CUR_S0 = 0, CUR_S1, CUR_S2, CUR_S3, CUR_S4, CUR_S5, CUR_S6, CUR_S7, CUR_S8, CUR_S9, CUR_S10
} CUR_SENSOR;

typedef struct {
    ORInt x;
    ORInt y;
} ComponentLocation;

ComponentLocation LOC[] = {
    {61, 9}, {6, 84}, {38, 69}, // Generators
    {48, 25}, {57, 45}, {12, 94}, {22, 96}, {37, 30}, {65, 14}, {42, 83}, {64, 13}, {32, 97}, // Contactor sensors
    {36, 48}, {7, 45}, {42, 24}, {53, 7}, {52, 65}, {61, 46}, {54, 69}, {59, 1}, {2, 99}, {17, 30}, {42, 29}, // Volt/Cur sensors
    {24, 90}, {35, 42}, {29, 73}, {36, 49}, // Contactors
    {65, 33}, {4, 9}, {22, 91}, {31, 15}, // Buses
    {7, 93}, {35, 37}, {14, 88}, // PMUs
};

const ORInt WGHT_PER_DIST = 25;
const ORInt COST_PER_DIST = 25;

id<ORExpr> cableWeight(id<ORExpr> x, ORInt c0, ORInt c1) {
    ComponentLocation l0 = LOC[c0];
    ComponentLocation l1 = LOC[c1];
    ORInt scale = WGHT_PER_DIST * (abs(l1.x - l0.x) + abs(l1.y - l0.y));
    return [x mul: @(scale)];
}

id<ORExpr> cableCost(id<ORExpr> x, ORInt c0, ORInt c1) {
    ComponentLocation l0 = LOC[c0];
    ComponentLocation l1 = LOC[c1];
    ORInt scale = COST_PER_DIST * (abs(l1.x - l0.x) + abs(l1.y - l0.y));
    return [x mul: @(scale)];
}

ORInt rawContSensBandwith[] = {
    85, 75, 85, 69, 81, 157, 108, 86, 92
};

ORInt rawVoltSensBandwith[] = {
    81, 82, 71, 71, 66, 158, 119, 127, 93, 88, 71
};

ORInt rawCurSensBandwith[] = {
    99, 68, 91, 71, 86, 99, 99, 91, 150, 55, 63
};

ORInt rawContDirectToPMUDelay[] = {
    8, 7, 12, 6, 4, 9, 3, 10, 4
};


ORInt rawVoltDirectToPMUDelay[] = {
    1612, 1514, 1670, 1764, 1710, 1710, 1600, 1522, 1630, 1188,8811
};

ORInt rawCurDirectToPMUDelay[] = {
    14, 27, 8, 16, 41, 19, 33, 20, 14, 19, 27
};


ORInt rawContToBusDelay[] = {
    24, 17, 8, 16, 31, 23, 12, 30, 18
};


ORInt rawContToConDelay[] = {
    31, 31, 33, 33, 23, 33, 34, 22, 32
};


ORInt rawVoltToBusDelay[] = {
    33, 22, 11, 18, 29, 24, 33, 32, 42, 14, 22
};

ORInt rawVoltToConDelay[] = {
    31, 31, 33, 33, 23, 33, 34, 22, 32, 27, 64
};

ORInt rawCurToBusDelay[] = {
    20, 20, 40, 40, 35, 42, 52, 31, 43, 32, 14
};

ORInt rawCurToConDelay[] = {
    31, 31, 33, 33, 23, 33, 34, 22, 32, 12, 22
};


ORInt numMainGen = 2;
ORInt numOptBuses = 4;
ORInt numOptConcentrators = 4;
ORInt numOptPMUs = 3;
ORInt numBackupGen = 1;
ORInt numBatteries = 1;
ORInt numContSensors = 9;
ORInt numVoltSensors = 11;
ORInt numCurSensors = 11;

ORInt BBF1_POW = 70;
ORInt BBF2_POW = 55;

ORInt maxDelay0 = 41;
ORInt maxDelay1 = 37;
ORInt maxDelay2 = 39;
ORInt maxDelay3 = 44;
ORInt maxDelay4 = 32;
ORInt maxDelay5 = 37;
ORInt maxDelay6 = 42;
ORInt maxDelay7 = 44;
ORInt maxDelay8 = 39;

//ORInt PROB_SCALE = 10000;

id<ORIntVarArray> joinVarArray(id<ORTracker> t,id<ORIntVarArray> a,id<ORIntVarArray> b)
{
   int sz = a.range.size + b.range.size;
   id<ORIntVarArray> nx = [ORFactory intVarArray:t range:RANGE(t,0,sz-1)];
   ORInt k = 0;
   for(ORInt i=a.range.low;i<=a.range.up;i++)
      nx[k++] = a[i];
   for(ORInt i=b.range.low;i<=b.range.up;i++)
      nx[k++] = b[i];
   return nx;
}

id<ORIntArray> joinIntArray(id<ORTracker> t,id<ORIntArray> a,id<ORIntArray> b)
{
   int sz = a.range.size + b.range.size;
   id<ORIntArray> nx = [ORFactory intArray:t range:RANGE(t,0,sz-1) value:0];
   ORInt k = 0;
   for(ORInt i=a.range.low;i<=a.range.up;i++)
      nx[k++] = a[i];
   for(ORInt i=b.range.low;i<=b.range.up;i++)
      nx[k++] = b[i];
   return nx;
}

int main(int argc, const char * argv[])
{
      int nbt = 1;
   if (argc==2)
      nbt = atoi(argv[1]);
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
    NSArray* pmuTemplates = [xmlDoc nodesForXPath: @"/template_library/pmu_templates/pmu" error: &err];
    ORInt numPMUTemplates = (ORInt)[pmuTemplates count];
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
    id<ORIntRange> pmuBounds = RANGE(m, 0, numPMUTemplates-1);
    id<ORIntRange> pmuRange = RANGE(m, 0, numOptPMUs); // Should have lower bound of 1 or 0?
    id<ORIntRange> genBounds = RANGE(m, 0, numGeneratorTemplates-1);
    id<ORIntRange> genRange = RANGE(m, 0, numMainGen + numBackupGen - 1);
    id<ORIntRange> contSenBounds = RANGE(m, 0, numContSensorTemplates-1);
    id<ORIntRange> contSenRange = RANGE(m, 0, numContSensors-1);
    id<ORIntRange> voltSenBounds = RANGE(m, 0, numVoltSensorTemplates-1);
    id<ORIntRange> voltSenRange = RANGE(m, 0, numVoltSensors-1);
    id<ORIntRange> curSenBounds = RANGE(m, 0, numCurSensorTemplates-1);
    id<ORIntRange> curSenRange = RANGE(m, 0, numCurSensors-1);
    id<ORIntRange> busBounds = RANGE(m, 0, numBusTemplates-1);
    id<ORIntRange> busRange = RANGE(m, 1, numOptBuses);
    id<ORIntRange> concRange = RANGE(m, 1, numOptConcentrators);
    id<ORIntRange> concBounds = RANGE(m, 0, numConcTemplates-1);
    
    id<ORIntRange> boolBounds = RANGE(m, 0, 1);
    
    // PMU Template Tables
    id<ORIntArray> PMUWeight = [ORFactory intArray: m range: pmuBounds with: ^ORInt(ORInt i) {
        return [[[[pmuTemplates[i] elementsForName: @"weight"] lastObject] stringValue] intValue]; }];
    id<ORIntArray> PMUCost = [ORFactory intArray: m range: pmuBounds with: ^ORInt(ORInt i) {
        return [[[[pmuTemplates[i] elementsForName: @"cost"] lastObject] stringValue] intValue]; }];
    id<ORIntArray> PMUPow = [ORFactory intArray: m range: pmuBounds with: ^ORInt(ORInt i) {
        return [[[[pmuTemplates[i] elementsForName: @"power"] lastObject] stringValue] intValue]; }];
    id<ORIntArray> PMUSpeedup = [ORFactory intArray: m range: pmuBounds with: ^ORInt(ORInt i) {
        return [[[[pmuTemplates[i] elementsForName: @"speedup"] lastObject] stringValue] intValue]; }];
    
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
    
    id<ORIntArray> busBandwidth = [ORFactory intArray: m range: busBounds with: ^ORInt(ORInt i) {
        return [[[[busTemplates[i] elementsForName: @"max_bandwidth"] lastObject] stringValue] intValue]; }];
    id<ORIntArray> busCost = [ORFactory intArray: m range: busBounds with: ^ORInt(ORInt i) {
        return [[[[busTemplates[i] elementsForName: @"cost"] lastObject] stringValue] intValue]; }];
    id<ORIntArray> busWeight = [ORFactory intArray: m range: busBounds with: ^ORInt(ORInt i) {
        return [[[[busTemplates[i] elementsForName: @"weight"] lastObject] stringValue] intValue]; }];
    
    // Bus Template Tables
//    ORInt MAX_BAND = [[[[busTemplates[0] elementsForName: @"max_bandwidth"] lastObject] stringValue] intValue];
//    ORInt BUS_COST = [[[[busTemplates[0] elementsForName: @"cost"] lastObject] stringValue] intValue];;
//    ORInt BUS_WGHT = [[[[busTemplates[0] elementsForName: @"weight"] lastObject] stringValue] intValue];;
    
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
    id<ORIntVarArray> pmu = [ORFactory intVarArray: m range: pmuRange bounds: pmuBounds];
    id<ORIntVar> g0 = [ORFactory intVar: m bounds: genBounds];
    id<ORIntVar> g1 = [ORFactory intVar: m bounds: genBounds];
    id<ORIntVar> auxgen = [ORFactory intVar: m bounds: genBounds];
    id<ORIntVarArray> contSensors = [ORFactory intVarArray: m range: contSenRange bounds: contSenBounds];
    id<ORIntVarArray> voltSensors = [ORFactory intVarArray: m range: voltSenRange bounds: voltSenBounds];
    id<ORIntVarArray> curSensors = [ORFactory intVarArray: m range: curSenRange bounds: curSenBounds];
    
    // Direct Connections
    id<ORIntVarArray> contSenDirectPMU = [ORFactory intVarArray: m range: contSenRange bounds: RANGE(m, 0, numOptPMUs)];
    id<ORIntVarArray> voltSenDirectPMU = [ORFactory intVarArray: m range: voltSenRange bounds: RANGE(m, 0, numOptPMUs)];
    id<ORIntVarArray> curSenDirectPMU = [ORFactory intVarArray: m range: curSenRange bounds: RANGE(m, 0, numOptPMUs)];
    id<ORIntVarMatrix> pmuDirectPMU = [ORFactory intVarMatrix: m range: pmuRange : pmuRange bounds: boolBounds];
    
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
    id<ORIntVarArray> useConc = [ORFactory intVarArray: m range: RANGE(m, 0, numOptConcentrators) bounds: boolBounds];
    id<ORIntVarArray> numConcConn = [ORFactory intVarArray: m range: concRange bounds: RANGE(m, 0, totalSensorCount)];
    id<ORIntVarArray> concToBus = [ORFactory intVarArray: m range: concRange bounds: RANGE(m, 0, numOptBuses)];
    
    // Endpoint Vars
    id<ORIntVarArray> contSensorEndpoints = [ORFactory intVarArray: m range: contSenRange bounds: RANGE(m, 0, numOptPMUs)];
    id<ORIntVarArray> voltSensorEndpoints = [ORFactory intVarArray: m range: voltSenRange bounds: RANGE(m, 0, numOptPMUs)];
    id<ORIntVarArray> curSensorEndpoints = [ORFactory intVarArray: m range: curSenRange bounds: RANGE(m, 0, numOptPMUs)];
    id<ORIntVarArray> busEndpoints = [ORFactory intVarArray: m range: RANGE(m, 0, numOptBuses) bounds: RANGE(m, 0, numOptPMUs)];
    id<ORIntVarArray> concEndpoints = [ORFactory intVarArray: m range: RANGE(m, 0, numOptConcentrators) bounds: RANGE(m, 0, numOptPMUs)];
    
    // Bus
    id<ORIntVarArray> bus = [ORFactory intVarArray: m range: busRange bounds: busBounds];
    id<ORIntVarArray> useBus = [ORFactory intVarArray: m range: busRange bounds: boolBounds];
    id<ORIntVarArray> numBusConn = [ORFactory intVarArray: m range: busRange bounds: RANGE(m, 0, totalSensorCount + numOptConcentrators)];

    
    id<ORIntVar> powUse = [ORFactory intVar: m bounds: RANGE(m, 0, 500000)];
    id<ORIntVarArray> bandUse = [ORFactory intVarArray: m range: busRange bounds: RANGE(m, 0, 500000)];
    id<ORIntVar> cost = [ORFactory intVar: m bounds: RANGE(m, 0, 1000000)];
    id<ORIntVar> weight = [ORFactory intVar: m bounds: RANGE(m, 0, 1000000)];
    id<ORIntVar> objective = [ORFactory intVar: m bounds: RANGE(m, 0, 1500000)];
    
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

    id<ORIntRange> delayRange = RANGE(m, 0, 120);
    //id<ORIntVarArray> delayPath0 = [ORFactory intVarArray: m range: pathRange5 bounds: delayRange];
    //id<ORIntVarArray> delayPath1 = [ORFactory intVarArray: m range: pathRange3 bounds: delayRange];
    //id<ORIntVarArray> delayPath2 = [ORFactory intVarArray: m range: pathRange3 bounds: delayRange];
    //id<ORIntVarArray> delayPath3 = [ORFactory intVarArray: m range: pathRange5 bounds: delayRange];
    //id<ORIntVarArray> delayPath4 = [ORFactory intVarArray: m range: pathRange5 bounds: delayRange];
    //id<ORIntVarArray> delayPath5 = [ORFactory intVarArray: m range: pathRange5 bounds: delayRange];
    //id<ORIntVarArray> delayPath6 = [ORFactory intVarArray: m range: pathRange5 bounds: delayRange];
    //id<ORIntVarArray> delayPath7 = [ORFactory intVarArray: m range: pathRange5 bounds: delayRange];
    //id<ORIntVarArray> delayPath8 = [ORFactory intVarArray: m range: pathRange5 bounds: delayRange];
    
    id<ORIntVar> actualDelayPath0 = [ORFactory intVar: m bounds: delayRange];
    id<ORIntVar> actualDelayPath1 = [ORFactory intVar: m bounds: delayRange];
    id<ORIntVar> actualDelayPath2 = [ORFactory intVar: m bounds: delayRange];
    id<ORIntVar> actualDelayPath3 = [ORFactory intVar: m bounds: delayRange];
    id<ORIntVar> actualDelayPath4 = [ORFactory intVar: m bounds: delayRange];
    id<ORIntVar> actualDelayPath5 = [ORFactory intVar: m bounds: delayRange];
    id<ORIntVar> actualDelayPath6 = [ORFactory intVar: m bounds: delayRange];
    id<ORIntVar> actualDelayPath7 = [ORFactory intVar: m bounds: delayRange];
    id<ORIntVar> actualDelayPath8 = [ORFactory intVar: m bounds: delayRange];


    // Template Tables -----------------------------------------------------------------------
    
    id<ORIntArray> contSensBandwith = [ORFactory intArray: m range: contSenRange values: rawVoltSensBandwith];
    id<ORIntArray> voltSensBandwith = [ORFactory intArray: m range: voltSenRange values: rawVoltSensBandwith];
    id<ORIntArray> curSensBandwith = [ORFactory intArray: m range: curSenRange values: rawCurSensBandwith];
    
    //id<ORIntArray> contDirectToPMUCost = [ORFactory intArray: m range: contSenRange values: rawContDirectToPMUCost];
    id<ORIntArray> contDirectToPMUDelay = [ORFactory intArray: m range: contSenRange values: rawContDirectToPMUDelay];
    id<ORIntArray> voltDirectToPMUDelay = [ORFactory intArray: m range: voltSenRange values: rawVoltDirectToPMUDelay];
    id<ORIntArray> curDirectToPMUDelay = [ORFactory intArray: m range: curSenRange values: rawCurDirectToPMUDelay];
    id<ORIntArray> contToBusDelay = [ORFactory intArray: m range: contSenRange values: rawContToBusDelay];
    id<ORIntArray> contToConDelay = [ORFactory intArray: m range: contSenRange values: rawContToConDelay];
    id<ORIntArray> voltToBusDelay = [ORFactory intArray: m range: voltSenRange values: rawVoltToBusDelay];
    id<ORIntArray> voltToConDelay = [ORFactory intArray: m range: voltSenRange values: rawVoltToConDelay];
    id<ORIntArray> curToBusDelay = [ORFactory intArray: m range: curSenRange values: rawCurToBusDelay];
    id<ORIntArray> curToConDelay = [ORFactory intArray: m range: curSenRange values: rawCurToConDelay];
    
    [m minimize:  objective];
    [m add: [objective eq: [cost plus: weight]]];
    
    // Cost ///////////////////////////
    id<ORConstraint> o1 = [m add: [cost eq:
        [[[[[[[[[[[[[[[[
                        [[[mainGenCost elt: g0] plus: [mainGenCost elt: g1]] plus: [mainGenCost elt: auxgen]] plus: // Gen cost
                       Sum(m, i, voltSenRange, [voltSensCost elt: [voltSensors at: i]])] plus: // Cost of contactor sensors
                      Sum(m, i, curSenRange, [curSensCost elt: [curSensors at: i]])] plus: // Cost of contactor sensors
                     Sum(m, i, contSenRange, [contSensCost elt: [contSensors at: i]])] plus: // Cost of contactor sensors
                    Sum2(m, i, pmuRange, j, contSenRange, cableCost([[contSenDirectPMU at: j] eq: @(i)], L_PMU_0 + i, L_CONT_S0 + j))] plus: // Cost direct to PMU
                   Sum2(m, i, pmuRange, j, voltSenRange, cableCost([[voltSenDirectPMU at: j] eq: @(i)], L_PMU_0 + i, L_S0 + j))] plus: // Cost direct to PMU
                  Sum2(m, i, pmuRange, j, curSenRange, cableCost([[curSenDirectPMU at: j] eq: @(i)], L_PMU_0 + i, L_S0 + j))] plus: // Cost direct to PMU
                 Sum2(m, i, busRange, j, contSenRange, cableCost([[contSenToBus at: j] eq: @(i)], L_BUS_0 + i, L_CONT_S0 + j))] plus: // Cost direct to PMU
                Sum2(m, i, busRange, j, voltSenRange, cableCost([[voltSenToBus at: j] eq: @(i)], L_BUS_0 + i, L_S0 + j))] plus: // Cost direct to PMU
               Sum2(m, i, busRange, j, curSenRange, cableCost([[curSenToBus at: j] eq: @(i)], L_BUS_0 + i, L_S0 + j))] plus: // Cost direct to PMU
              Sum2(m, i, concRange, j, contSenRange, cableCost([[contSenToCon at: j] eq: @(i)], L_CONC_0 + i, L_CONT_S0 + j))] plus: // Cost direct to PMU
             Sum2(m, i, concRange, j, voltSenRange, cableCost([[voltSenToCon at: j] eq: @(i)], L_CONC_0 + i, L_S0 + j))] plus: // Cost direct to PMU
            Sum2(m, i, concRange, j, curSenRange, cableCost([[curSenToCon at: j] eq: @(i)], L_CONC_0 + i, L_S0 + j))] plus: // Cost direct to PMU
            Sum(m, i, concRange, [concCost elt: [conc at: i]])] plus: // Concentrator cost
            Sum(m, i,busRange, [busCost elt: [bus at: i]])] plus: // Bus Cost
            Sum(m, i, pmuRange, [PMUCost elt: [pmu at: i]])] plus: // PMU cost
            Sum2(m, i, pmuRange, j, pmuRange, cableCost([[pmuDirectPMU at: i : j] mul: @(i > j)], L_PMU_0 + i, L_PMU_0 + j))                       ]
             ]];

    // Weight /////////////////////////
    id<ORConstraint> o2 = [m add: [weight eq:
        [[[[[[[[[[[[[[[[
                       [[[mainGenWeight elt: g0] plus: [mainGenWeight elt: g1]] plus: [mainGenWeight elt: auxgen]] plus: // Gen Weight
                       Sum(m, i, voltSenRange, [voltSensWeight elt: [voltSensors at: i]])] plus: // Weight of contactor sensors
                      Sum(m, i, curSenRange, [curSensWeight elt: [curSensors at: i]])] plus: // Weight of contactor sensors
                     Sum(m, i, contSenRange, [contSensWeight elt: [contSensors at: i]])] plus: // Weight of contactor sensors
                    Sum2(m, i, pmuRange, j, contSenRange, cableWeight([[contSenDirectPMU at: j] eq: @(i)], L_PMU_0 + i, L_CONT_S0 + j))] plus: // Weight direct to PMU
                   Sum2(m, i, pmuRange, j, voltSenRange, cableWeight([[voltSenDirectPMU at: j] eq: @(i)], L_PMU_0 + i, L_S0 + j))] plus: // Weight direct to PMU
                  Sum2(m, i, pmuRange, j, curSenRange, cableWeight([[curSenDirectPMU at: j] eq: @(i)], L_PMU_0 + i, L_S0 + j))] plus: // Weight direct to PMU
                 Sum2(m, i, busRange, j, contSenRange, cableWeight([[contSenToBus at: j] eq: @(i)], L_BUS_0 + i, L_CONT_S0 + j))] plus: // Weight direct to PMU
                Sum2(m, i, busRange, j, voltSenRange, cableWeight([[voltSenToBus at: j] eq: @(i)], L_BUS_0 + i, L_S0 + j))] plus: // Weight direct to PMU
               Sum2(m, i, busRange, j, curSenRange, cableWeight([[curSenToBus at: j] eq: @(i)], L_BUS_0 + i, L_S0 + j))] plus: // Weight direct to PMU
              Sum2(m, i, concRange, j, contSenRange, cableWeight([[contSenToCon at: j] eq: @(i)], L_CONC_0 + i, L_CONT_S0 + j))] plus: // Weight direct to PMU
             Sum2(m, i, concRange, j, voltSenRange, cableWeight([[voltSenToCon at: j] eq: @(i)], L_CONC_0 + i, L_S0 + j))] plus: // Weight direct to PMU
            Sum2(m, i, concRange, j, curSenRange, cableWeight([[curSenToCon at: j] eq: @(i)], L_CONC_0 + i, L_S0 + j))] plus: // Weight direct to PMU
           Sum(m, i, concRange, [concWeight elt: [conc at: i]])] plus: // Concentrator Weight
          Sum(m, i,busRange, [busWeight elt: [bus at: i]])] plus: // Bus Weight
         Sum(m, i, pmuRange, [PMUWeight elt: [pmu at: i]])] plus: // PMU Weight
         Sum2(m, i, pmuRange, j, pmuRange, cableWeight([[pmuDirectPMU at: i : j] mul: @(i > j)], L_PMU_0 + i, L_PMU_0 + j))]
                                   ]];
    //[m add: [weight leq: @(MAX_WEIGHT)]];
    
    // Power Draw /////////////////////////
    [m add: [powUse eq:
             [[[[[Sum(m, i, contSenRange, [contSensPowDraw elt: [contSensors at: i]]) plus: // Sensor Power
                  Sum(m, i, voltSenRange, [voltSensPowDraw elt: [voltSensors at: i]])] plus:
                 Sum(m, i, curSenRange, [curSensPowDraw elt: [curSensors at: i]])] plus:
                Sum(m, i, concRange, [concPowDraw elt: [conc at: i]])] plus:
               @(BBF1_POW + BBF2_POW)] plus: // Black Box power
              Sum(m, i, pmuRange, [PMUPow elt: [pmu at: i]])] // PMU power draw
             ]];
    
    // Power Gen //////////////////////////
    [m add: [powUse leq: [[mainGenPow elt: g0] plus: [mainGenPow elt: g1]]]];
    [m add: [powUse leq: [[mainGenPow elt: g1] plus: [mainGenPow elt: auxgen]]]];
    [m add: [powUse leq: [[mainGenPow elt: auxgen] plus: [mainGenPow elt: g1]]]];
    
    // Connectivity ///////////////////////
    for(ORInt i = [contSenRange low]; i <= [contSenRange up]; i++) {
        [m add: [[[[contSenDirectPMU[i] plus: contSenToCon[i]] plus: contSenToBus[i]] gt: @(0)] eq: [contSensors[i] gt: NONE]]]; // Connected to PMU, bus or concentrator
        // Endpoint tracking
        [m add: [[contSenDirectPMU[i] gt: @(0)] eq: [contSensorEndpoints[i] eq: contSenDirectPMU[i]]]];
        [m add: [[contSenToBus[i] gt: @(0)] eq: [contSensorEndpoints[i] eq: [busEndpoints elt: contSenToBus[i]]]]];
        [m add: [[contSenToCon[i] gt: @(0)] eq: [contSensorEndpoints[i] eq: [concEndpoints elt: contSenToCon[i]]]]];
        [m add: [[contSensors[i] gt: NONE] eq: [contSensorEndpoints[i] gt: NONE]]];
    }
    for(ORInt i = [voltSenRange low]; i <= [voltSenRange up]; i++) {
        [m add: [[[[voltSenDirectPMU[i] plus: voltSenToCon[i]] plus: voltSenToBus[i]] gt: @(0)] eq: [voltSensors[i] gt: NONE]]]; // Connected to PMU, bus or concentrator
        // Endpoint tracking
        [m add: [[voltSenDirectPMU[i] gt: @(0)] eq: [voltSensorEndpoints[i] eq: voltSenDirectPMU[i]]]];
        [m add: [[voltSenToBus[i] gt: @(0)] eq: [voltSensorEndpoints[i] eq: [busEndpoints elt: voltSenToBus[i]]]]];
        [m add: [[voltSenToCon[i] gt: @(0)] eq: [voltSensorEndpoints[i] eq: [concEndpoints elt: voltSenToCon[i]]]]];
        [m add: [[voltSensors[i] gt: NONE] eq: [voltSensorEndpoints[i] gt: NONE]]];
    }
    for(ORInt i = [curSenRange low]; i <= [curSenRange up]; i++) {
        [m add: [[[[curSenDirectPMU[i] plus: curSenToCon[i]] plus: curSenToBus[i]] gt: @(0)] eq: [curSensors[i] gt: NONE] ]]; // Connected to PMU, bus or concentrator
        // Endpoint tracking
        [m add: [[curSenDirectPMU[i] gt: @(0)] eq: [curSensorEndpoints[i] eq: curSenDirectPMU[i]]]];
        [m add: [[curSenToBus[i] gt: @(0)] eq: [curSensorEndpoints[i] eq: [busEndpoints elt: curSenToBus[i]]]]];
        [m add: [[curSenToCon[i] gt: @(0)] eq: [curSensorEndpoints[i] eq: [concEndpoints elt: curSenToCon[i]]]]];
        [m add: [[curSensors[i] gt: NONE] eq: [curSensorEndpoints[i] gt: NONE]]];
    }
    // If not connected to PMU directly, must have a sensor capable of digital conversion
    for(ORInt i = [contSenRange low]; i <= [contSenRange up]; i++)
        [m add: [[[contSensors[i] gt: NONE] land: [contSenDirectPMU[i] neq: @(1)]] eq: [@(1) leq: [contSensConverts elt: contSensors[i]]]]];
    for(ORInt i = [voltSenRange low]; i <= [voltSenRange up]; i++)
        [m add: [[[voltSensors[i] gt: NONE] land: [voltSenDirectPMU[i] neq: @(1)]] eq: [@(1) leq: [voltSensConverts elt: voltSensors[i]]]]];
    for(ORInt i = [curSenRange low]; i <= [curSenRange up]; i++)
        [m add: [[[curSensors[i] gt: NONE] land: [curSenDirectPMU[i] neq: @(1)]] eq: [@(1) leq: [curSensConverts elt: curSensors[i]]]]];
    
    // Symmetry for PMU connections
    for(ORInt i = [pmuRange low]; i < [pmuRange up]; i++) {
        for(ORInt j = i + 1; j <= [pmuRange up]; j++) {
            [m add: [[pmuDirectPMU at: i : j] eq: [pmuDirectPMU at: j : i]]];
        }
    }
    
    // If PMU is an endpoint, it can't be NONE
    for(ORInt i = [contSenRange low]; i <= [contSenRange up]; i++) {
        [m add: [[contSensorEndpoints[i] gt: NONE] eq: [[pmu elt: contSensorEndpoints[i]] gt: NONE]]];
    }
    for(ORInt i = [voltSenRange low]; i <= [voltSenRange up]; i++) {
        [m add: [[voltSensorEndpoints[i] gt: NONE] eq: [[pmu elt: voltSensorEndpoints[i]] gt: NONE]]];
    }
    for(ORInt i = [curSenRange low]; i <= [curSenRange up]; i++) {
        [m add: [[curSensorEndpoints[i] gt: NONE] eq: [[pmu elt: curSensorEndpoints[i]] gt: NONE]]];
    }
    
    // Bus ////////////////////////////////
    for(ORInt b = [busRange low]; b <= [busRange up]; b++) {
        [m add: [[[[Sum(m, i, contSenRange, [contSenToBus[i] eq: @(b)]) plus:
                   Sum(m, i, voltSenRange, [voltSenToBus[i] eq: @(b)])] plus:
                  Sum(m, i, concRange, [concToBus[i] eq: @(b)])] plus:
                  Sum(m, i, curSenRange, [curSenToBus[i] eq: @(b)])] eq: numBusConn[b]]];
        [m add: [[useBus[b] eq: @(1)] eq: [numBusConn[b] gt: NONE]]];
        [m add: [[useBus[b] eq: @(1)] eq: [bus[b] gt: NONE]]];
    }

    // Concentrators //////////////////////
    
    // Connection count for concentrators
    for(ORInt k = [concRange low]; k <= [concRange up]; k++) {
        [m add: [[[Sum(m, i, contSenRange, [contSenToCon[i] eq: @(k)]) plus:
                   Sum(m, i, voltSenRange, [voltSenToCon[i] eq: @(k)])] plus:
                  Sum(m, i, curSenRange, [curSenToCon[i] eq: @(k)])] eq: numConcConn[k]]];
    }
    
    // Use concentrators
    for(ORInt k = [concRange low]; k <= [concRange up]; k++) {
        [m add: [[useConc[k] eq: @(1)] eq: [numConcConn[k] gt: @(0)]]];
        [m add: [[useConc[k] eq: @(1)] eq: [conc[k] neq: NONE]]];
    }
    
    //    // Limit number of concentrator connections
    for(ORInt k = [concRange low]; k <= [concRange up]; k++) {
        [m add: [numConcConn[k] leq: [concMaxConn elt: conc[k]]]];
    }
    
    // Connect to a bus if concentrator in use
    for(ORInt k = [concRange low]; k <= [concRange up]; k++) {
        [m add: [[useConc[k] eq: @(1)] eq: [concToBus[k] neq: NONE]]];
        // Endpoint tracking
        [m add: [[useConc[k] eq: @(1)] eq: [concEndpoints[k] eq: [busEndpoints elt: concToBus[k]]]]];
    }
    
    // Bus Bandwidth
    for(ORInt b = [busRange low]; b <= [busRange up]; b++) {
        [m add: [bandUse[b] eq: [[[
                                   Sum(m, i, contSenRange, [[contSenToBus[i] eq: @(b)] mul: contSensBandwith[i]]) plus:
                                   Sum(m, i, voltSenRange, [[voltSenToBus[i] eq: @(b)] mul: voltSensBandwith[i]])] plus:
                                  Sum(m, i, curSenRange, [[curSenToBus[i] eq: @(b)] mul: curSensBandwith[i]])] plus:
                                 Sum(m, i, concRange, [[concToBus[i] eq: @(b)] mul: [concBand elt: conc[i]]])
                                 ]]];
        [m add: [bandUse[b] leq: [busBandwidth elt: [bus at: b]]]];
    }
    
    // Path Definitions
    [m add: [[usePath0[0] eq: @(1)] eq: [contSensors[CONT_S0] gt: NONE]]];
    [m add: [[usePath0[1] eq: @(1)] eq: [voltSensors[VOLT_S0] gt: NONE]]];
    [m add: [[usePath0[1] eq: @(1)] eq: [voltSensors[VOLT_S1] gt: NONE]]];
    [m add: [[usePath0[1] eq: @(1)] eq: [[pmuDirectPMU elt: voltSensorEndpoints[VOLT_S0] elt: voltSensorEndpoints[VOLT_S1]] eq: @(1)]]];
    [m add: [[usePath0[2] eq: @(1)] eq: [voltSensors[VOLT_S0] gt: NONE]]];
    [m add: [[usePath0[2] eq: @(1)] eq: [voltSensors[VOLT_S2] gt: NONE]]];
    [m add: [[usePath0[2] eq: @(1)] eq: [[pmuDirectPMU elt: voltSensorEndpoints[VOLT_S0] elt: voltSensorEndpoints[VOLT_S2]] eq: @(1)]]];
    [m add: [[usePath0[3] eq: @(1)] eq: [curSensors[CUR_S0] gt: NONE]]];
    [m add: [[usePath0[3] eq: @(1)] eq: [curSensors[CUR_S1] gt: NONE]]];
    [m add: [[usePath0[3] eq: @(1)] eq: [[pmuDirectPMU elt: curSensorEndpoints[CUR_S0] elt: voltSensorEndpoints[CUR_S1]] eq: @(1)]]];
    [m add: [[usePath0[4] eq: @(1)] eq: [curSensors[CUR_S0] gt: NONE]]];
    [m add: [[usePath0[4] eq: @(1)] eq: [curSensors[CUR_S2] gt: NONE]]];
    [m add: [[usePath0[4] eq: @(1)] eq: [[pmuDirectPMU elt: curSensorEndpoints[CUR_S0] elt: voltSensorEndpoints[CUR_S2]] eq: @(1)]]];

    // Delays on path 0
    [m add: [[[[voltSenToCon[VOLT_S0] gt: NONE] mul: voltToConDelay[VOLT_S0]] plus:
              [[@(1) sub: [voltSensorEndpoints[VOLT_S0] eq: voltSensorEndpoints[VOLT_S1]]] mul: @(20)]] leq: actualDelayPath0]];
    [m add: [[[[voltSenToCon[VOLT_S1] gt: NONE] mul: voltToConDelay[VOLT_S1]] plus:
              [[@(1) sub: [voltSensorEndpoints[VOLT_S0] eq: voltSensorEndpoints[VOLT_S1]]] mul: @(20)]] leq: actualDelayPath0]];
    
    [m add: [[[[voltSenToCon[VOLT_S0] gt: NONE] mul: voltToConDelay[VOLT_S0]] plus:
              [[@(1) sub: [voltSensorEndpoints[VOLT_S0] eq: voltSensorEndpoints[VOLT_S2]]] mul: @(20)]] leq: actualDelayPath0]];
    [m add: [[[[voltSenToCon[VOLT_S2] gt: NONE] mul: voltToConDelay[VOLT_S2]] plus:
              [[@(1) sub: [voltSensorEndpoints[VOLT_S0] eq: voltSensorEndpoints[VOLT_S2]]] mul: @(20)]] leq: actualDelayPath0]];
    
    [m add: [[[[curSenToCon[CUR_S0] gt: NONE] mul: curToConDelay[CUR_S0]] plus:
              [[@(1) sub: [curSensorEndpoints[CUR_S0] eq: curSensorEndpoints[CUR_S1]]] mul: @(20)]] leq: actualDelayPath0]];
    [m add: [[[[curSenToCon[CUR_S1] gt: NONE] mul: curToConDelay[CUR_S1]] plus:
              [[@(1) sub: [curSensorEndpoints[CUR_S0] eq: curSensorEndpoints[CUR_S1]]] mul: @(20)]] leq: actualDelayPath0]];
    
    [m add: [[[[curSenToCon[CUR_S0] gt: NONE] mul: curToConDelay[CUR_S0]] plus:
              [[@(1) sub: [curSensorEndpoints[CUR_S0] eq: curSensorEndpoints[CUR_S2]]] mul: @(20)]] leq: actualDelayPath0]];
    [m add: [[[[curSenToCon[CUR_S2] gt: NONE] mul: curToConDelay[CUR_S2]] plus:
              [[@(1) sub: [curSensorEndpoints[CUR_S0] eq: curSensorEndpoints[CUR_S2]]] mul: @(20)]] leq: actualDelayPath0]];
    
    // Use path 1
    [m add: [[usePath1[0] eq: @(1)] eq: [contSensors[CONT_S1] gt: NONE]]];
    [m add: [[usePath1[1] eq: @(1)] eq: [voltSensors[VOLT_S1] gt: NONE]]];
    [m add: [[usePath1[1] eq: @(1)] eq: [voltSensors[VOLT_S2] gt: NONE]]];
    [m add: [[usePath1[1] eq: @(1)] eq: [[pmuDirectPMU elt: voltSensorEndpoints[VOLT_S1] elt: voltSensorEndpoints[VOLT_S2]] eq: @(1)]]];
    [m add: [[usePath1[2] eq: @(1)] eq: [curSensors[CUR_S1] gt: NONE]]];
    [m add: [[usePath1[2] eq: @(1)] eq: [curSensors[CUR_S2] gt: NONE]]];
    [m add: [[usePath1[2] eq: @(1)] eq: [[pmuDirectPMU elt: curSensorEndpoints[CUR_S1] elt: curSensorEndpoints[CUR_S2]] eq: @(1)]]];

    // Delays on path 1
    [m add: [[[[voltSenToCon[VOLT_S2] gt: NONE] mul: voltToConDelay[VOLT_S2]] plus:
              [[@(1) sub: [voltSensorEndpoints[VOLT_S2] eq: voltSensorEndpoints[VOLT_S1]]] mul: @(20)]] leq: actualDelayPath1]];
    [m add: [[[[voltSenToCon[VOLT_S1] gt: NONE] mul: voltToConDelay[VOLT_S1]] plus:
              [[@(1) sub: [voltSensorEndpoints[VOLT_S2] eq: voltSensorEndpoints[VOLT_S1]]] mul: @(20)]] leq: actualDelayPath1]];
    
    [m add: [[[[curSenToCon[CUR_S1] gt: NONE] mul: curToConDelay[CUR_S1]] plus:
              [[@(1) sub: [curSensorEndpoints[CUR_S1] eq: curSensorEndpoints[CUR_S2]]] mul: @(20)]] leq: actualDelayPath1]];
    [m add: [[[[curSenToCon[CUR_S2] gt: NONE] mul: curToConDelay[CUR_S2]] plus:
              [[@(1) sub: [curSensorEndpoints[CUR_S1] eq: curSensorEndpoints[CUR_S2]]] mul: @(20)]] leq: actualDelayPath1]];
    
    // Use path 2
    [m add: [[usePath2[0] eq: @(1)] eq: [contSensors[CONT_S2] gt: NONE]]];
    [m add: [[usePath2[1] eq: @(1)] eq: [voltSensors[VOLT_S2] gt: NONE]]];
    [m add: [[usePath2[1] eq: @(1)] eq: [voltSensors[VOLT_S3] gt: NONE]]];
    [m add: [[usePath2[1] eq: @(1)] eq: [[pmuDirectPMU elt: voltSensorEndpoints[VOLT_S2] elt: voltSensorEndpoints[VOLT_S3]] eq: @(1)]]];
    [m add: [[usePath2[2] eq: @(1)] eq: [curSensors[CUR_S2] gt: NONE]]];
    [m add: [[usePath2[2] eq: @(1)] eq: [curSensors[CUR_S3] gt: NONE]]];
    [m add: [[usePath2[2] eq: @(1)] eq: [[pmuDirectPMU elt: curSensorEndpoints[CUR_S2] elt: curSensorEndpoints[CUR_S3]] eq: @(1)]]];
    
    // Delays on path 2
    [m add: [[[[voltSenToCon[VOLT_S2] gt: NONE] mul: voltToConDelay[VOLT_S2]] plus:
              [[@(1) sub: [voltSensorEndpoints[VOLT_S2] eq: voltSensorEndpoints[VOLT_S3]]] mul: @(20)]] leq: actualDelayPath2]];
    [m add: [[[[voltSenToCon[VOLT_S3] gt: NONE] mul: voltToConDelay[VOLT_S3]] plus:
              [[@(1) sub: [voltSensorEndpoints[VOLT_S2] eq: voltSensorEndpoints[VOLT_S3]]] mul: @(20)]] leq: actualDelayPath2]];
    
    [m add: [[[[curSenToCon[CUR_S3] gt: NONE] mul: curToConDelay[CUR_S3]] plus:
              [[@(1) sub: [curSensorEndpoints[CUR_S3] eq: curSensorEndpoints[CUR_S2]]] mul: @(20)]] leq: actualDelayPath2]];
    [m add: [[[[curSenToCon[CUR_S2] gt: NONE] mul: curToConDelay[CUR_S2]] plus:
              [[@(1) sub: [curSensorEndpoints[CUR_S3] eq: curSensorEndpoints[CUR_S2]]] mul: @(20)]] leq: actualDelayPath2]];
    
    // Use path 3
    [m add: [[usePath3[0] eq: @(1)] eq: [contSensors[CONT_S3] gt: NONE]]];
    [m add: [[usePath3[1] eq: @(1)] eq: [voltSensors[VOLT_S4] gt: NONE]]];
    [m add: [[usePath3[1] eq: @(1)] eq: [voltSensors[VOLT_S3] gt: NONE]]];
    [m add: [[usePath3[1] eq: @(1)] eq: [[pmuDirectPMU elt: voltSensorEndpoints[VOLT_S4] elt: voltSensorEndpoints[VOLT_S3]] eq: @(1)]]];
    [m add: [[usePath3[2] eq: @(1)] eq: [voltSensors[VOLT_S4] gt: NONE]]];
    [m add: [[usePath3[2] eq: @(1)] eq: [voltSensors[VOLT_S2] gt: NONE]]];
    [m add: [[usePath3[2] eq: @(1)] eq: [[pmuDirectPMU elt: voltSensorEndpoints[VOLT_S4] elt: voltSensorEndpoints[VOLT_S2]] eq: @(1)]]];
    [m add: [[usePath3[3] eq: @(1)] eq: [curSensors[CUR_S4] gt: NONE]]];
    [m add: [[usePath3[3] eq: @(1)] eq: [curSensors[CUR_S3] gt: NONE]]];
    [m add: [[usePath3[3] eq: @(1)] eq: [[pmuDirectPMU elt: curSensorEndpoints[CUR_S4] elt: curSensorEndpoints[CUR_S3]] eq: @(1)]]];
    [m add: [[usePath3[4] eq: @(1)] eq: [curSensors[CUR_S4] gt: NONE]]];
    [m add: [[usePath3[4] eq: @(1)] eq: [curSensors[CUR_S2] gt: NONE]]];
    [m add: [[usePath3[4] eq: @(1)] eq: [[pmuDirectPMU elt: curSensorEndpoints[CUR_S4] elt: curSensorEndpoints[CUR_S2]] eq: @(1)]]];

    // Delays on path 3
    [m add: [[[[voltSenToCon[VOLT_S3] gt: NONE] mul: voltToConDelay[VOLT_S3]] plus:
              [[@(1) sub: [voltSensorEndpoints[VOLT_S3] eq: voltSensorEndpoints[VOLT_S4]]] mul: @(20)]] leq: actualDelayPath3]];
    [m add: [[[[voltSenToCon[VOLT_S4] gt: NONE] mul: voltToConDelay[VOLT_S4]] plus:
              [[@(1) sub: [voltSensorEndpoints[VOLT_S3] eq: voltSensorEndpoints[VOLT_S4]]] mul: @(20)]] leq: actualDelayPath3]];
    
    [m add: [[[[voltSenToCon[VOLT_S4] gt: NONE] mul: voltToConDelay[VOLT_S4]] plus:
              [[@(1) sub: [voltSensorEndpoints[VOLT_S4] eq: voltSensorEndpoints[VOLT_S2]]] mul: @(20)]] leq: actualDelayPath3]];
    [m add: [[[[voltSenToCon[VOLT_S2] gt: NONE] mul: voltToConDelay[VOLT_S2]] plus:
              [[@(1) sub: [voltSensorEndpoints[VOLT_S4] eq: voltSensorEndpoints[VOLT_S2]]] mul: @(20)]] leq: actualDelayPath3]];
    
    [m add: [[[[curSenToCon[CUR_S3] gt: NONE] mul: curToConDelay[CUR_S3]] plus:
              [[@(1) sub: [curSensorEndpoints[CUR_S3] eq: curSensorEndpoints[CUR_S4]]] mul: @(20)]] leq: actualDelayPath3]];
    [m add: [[[[curSenToCon[CUR_S4] gt: NONE] mul: curToConDelay[CUR_S4]] plus:
              [[@(1) sub: [curSensorEndpoints[CUR_S3] eq: curSensorEndpoints[CUR_S4]]] mul: @(20)]] leq: actualDelayPath3]];
    
    [m add: [[[[curSenToCon[CUR_S4] gt: NONE] mul: curToConDelay[CUR_S4]] plus:
              [[@(1) sub: [curSensorEndpoints[CUR_S4] eq: curSensorEndpoints[CUR_S2]]] mul: @(20)]] leq: actualDelayPath3]];
    [m add: [[[[curSenToCon[CUR_S2] gt: NONE] mul: curToConDelay[CUR_S2]] plus:
              [[@(1) sub: [curSensorEndpoints[CUR_S4] eq: curSensorEndpoints[CUR_S2]]] mul: @(20)]] leq: actualDelayPath3]];
    
    // Use path 4
    [m add: [[usePath4[0] eq: @(1)] eq: [contSensors[CONT_S4] gt: NONE]]];
    [m add: [[usePath4[1] eq: @(1)] eq: [voltSensors[VOLT_S5] gt: NONE]]];
    [m add: [[usePath4[1] eq: @(1)] eq: [voltSensors[VOLT_S6] gt: NONE]]];
    [m add: [[usePath4[1] eq: @(1)] eq: [[pmuDirectPMU elt: voltSensorEndpoints[VOLT_S5] elt: voltSensorEndpoints[VOLT_S6]] eq: @(1)]]];
    [m add: [[usePath4[2] eq: @(1)] eq: [voltSensors[VOLT_S5] gt: NONE]]];
    [m add: [[usePath4[2] eq: @(1)] eq: [voltSensors[VOLT_S1] gt: NONE]]];
    [m add: [[usePath4[2] eq: @(1)] eq: [[pmuDirectPMU elt: voltSensorEndpoints[VOLT_S5] elt: voltSensorEndpoints[VOLT_S1]] eq: @(1)]]];
    [m add: [[usePath4[3] eq: @(1)] eq: [curSensors[CUR_S5] gt: NONE]]];
    [m add: [[usePath4[3] eq: @(1)] eq: [curSensors[CUR_S6] gt: NONE]]];
    [m add: [[usePath4[3] eq: @(1)] eq: [[pmuDirectPMU elt: curSensorEndpoints[CUR_S5] elt: curSensorEndpoints[CUR_S6]] eq: @(1)]]];
    [m add: [[usePath4[4] eq: @(1)] eq: [curSensors[CUR_S5] gt: NONE]]];
    [m add: [[usePath4[4] eq: @(1)] eq: [curSensors[CUR_S1] gt: NONE]]];
    [m add: [[usePath4[4] eq: @(1)] eq: [[pmuDirectPMU elt: curSensorEndpoints[CUR_S5] elt: curSensorEndpoints[CUR_S1]] eq: @(1)]]];
    
    // Delays on path 4
    [m add: [[[[voltSenToCon[VOLT_S5] gt: NONE] mul: voltToConDelay[VOLT_S5]] plus:
              [[@(1) sub: [voltSensorEndpoints[VOLT_S5] eq: voltSensorEndpoints[VOLT_S6]]] mul: @(20)]] leq: actualDelayPath4]];
    [m add: [[[[voltSenToCon[VOLT_S6] gt: NONE] mul: voltToConDelay[VOLT_S6]] plus:
              [[@(1) sub: [voltSensorEndpoints[VOLT_S5] eq: voltSensorEndpoints[VOLT_S6]]] mul: @(20)]] leq: actualDelayPath4]];
    
    [m add: [[[[voltSenToCon[VOLT_S5] gt: NONE] mul: voltToConDelay[VOLT_S5]] plus:
              [[@(1) sub: [voltSensorEndpoints[VOLT_S5] eq: voltSensorEndpoints[VOLT_S1]]] mul: @(20)]] leq: actualDelayPath4]];
    [m add: [[[[voltSenToCon[VOLT_S1] gt: NONE] mul: voltToConDelay[VOLT_S1]] plus:
              [[@(1) sub: [voltSensorEndpoints[VOLT_S5] eq: voltSensorEndpoints[VOLT_S1]]] mul: @(20)]] leq: actualDelayPath4]];
    
    [m add: [[[[curSenToCon[CUR_S5] gt: NONE] mul: curToConDelay[CUR_S5]] plus:
              [[@(1) sub: [curSensorEndpoints[CUR_S5] eq: curSensorEndpoints[CUR_S6]]] mul: @(20)]] leq: actualDelayPath4]];
    [m add: [[[[curSenToCon[CUR_S6] gt: NONE] mul: curToConDelay[CUR_S6]] plus:
              [[@(1) sub: [curSensorEndpoints[CUR_S5] eq: curSensorEndpoints[CUR_S6]]] mul: @(20)]] leq: actualDelayPath4]];
    
    [m add: [[[[curSenToCon[CUR_S5] gt: NONE] mul: curToConDelay[CUR_S5]] plus:
              [[@(1) sub: [curSensorEndpoints[CUR_S5] eq: curSensorEndpoints[CUR_S1]]] mul: @(20)]] leq: actualDelayPath4]];
    [m add: [[[[curSenToCon[CUR_S1] gt: NONE] mul: curToConDelay[CUR_S1]] plus:
              [[@(1) sub: [curSensorEndpoints[CUR_S5] eq: curSensorEndpoints[CUR_S1]]] mul: @(20)]] leq: actualDelayPath4]];
    
    
    // Use path 5
    [m add: [[usePath5[0] eq: @(1)] eq: [contSensors[CONT_S5] gt: NONE]]];
    [m add: [[usePath5[1] eq: @(1)] eq: [voltSensors[VOLT_S8] gt: NONE]]];
    [m add: [[usePath5[1] eq: @(1)] eq: [voltSensors[VOLT_S7] gt: NONE]]];
    [m add: [[usePath5[1] eq: @(1)] eq: [[pmuDirectPMU elt: voltSensorEndpoints[VOLT_S8] elt: voltSensorEndpoints[VOLT_S7]] eq: @(1)]]];
    [m add: [[usePath5[2] eq: @(1)] eq: [voltSensors[VOLT_S8] gt: NONE]]];
    [m add: [[usePath5[2] eq: @(1)] eq: [voltSensors[VOLT_S3] gt: NONE]]];
    [m add: [[usePath5[2] eq: @(1)] eq: [[pmuDirectPMU elt: voltSensorEndpoints[VOLT_S8] elt: voltSensorEndpoints[VOLT_S3]] eq: @(1)]]];
    [m add: [[usePath5[3] eq: @(1)] eq: [curSensors[CUR_S8] gt: NONE]]];
    [m add: [[usePath5[3] eq: @(1)] eq: [curSensors[CUR_S7] gt: NONE]]];
    [m add: [[usePath5[3] eq: @(1)] eq: [[pmuDirectPMU elt: curSensorEndpoints[CUR_S8] elt: curSensorEndpoints[CUR_S7]] eq: @(1)]]];
    [m add: [[usePath5[4] eq: @(1)] eq: [curSensors[CUR_S8] gt: NONE]]];
    [m add: [[usePath5[4] eq: @(1)] eq: [curSensors[CUR_S3] gt: NONE]]];
    [m add: [[usePath5[4] eq: @(1)] eq: [[pmuDirectPMU elt: curSensorEndpoints[CUR_S8] elt: curSensorEndpoints[CUR_S3]] eq: @(1)]]];

    // Delays on path 5
    [m add: [[[[voltSenToCon[VOLT_S8] gt: NONE] mul: voltToConDelay[VOLT_S8]] plus:
              [[@(1) sub: [voltSensorEndpoints[VOLT_S8] eq: voltSensorEndpoints[VOLT_S7]]] mul: @(20)]] leq: actualDelayPath5]];
    [m add: [[[[voltSenToCon[VOLT_S7] gt: NONE] mul: voltToConDelay[VOLT_S7]] plus:
              [[@(1) sub: [voltSensorEndpoints[VOLT_S8] eq: voltSensorEndpoints[VOLT_S7]]] mul: @(20)]] leq: actualDelayPath5]];
    
    [m add: [[[[voltSenToCon[VOLT_S8] gt: NONE] mul: voltToConDelay[VOLT_S8]] plus:
              [[@(1) sub: [voltSensorEndpoints[VOLT_S8] eq: voltSensorEndpoints[VOLT_S3]]] mul: @(20)]] leq: actualDelayPath5]];
    [m add: [[[[voltSenToCon[VOLT_S3] gt: NONE] mul: voltToConDelay[VOLT_S3]] plus:
              [[@(1) sub: [voltSensorEndpoints[VOLT_S8] eq: voltSensorEndpoints[VOLT_S3]]] mul: @(20)]] leq: actualDelayPath5]];
    
    [m add: [[[[curSenToCon[CUR_S8] gt: NONE] mul: curToConDelay[CUR_S8]] plus:
              [[@(1) sub: [curSensorEndpoints[CUR_S8] eq: curSensorEndpoints[CUR_S7]]] mul: @(20)]] leq: actualDelayPath5]];
    [m add: [[[[curSenToCon[CUR_S7] gt: NONE] mul: curToConDelay[CUR_S7]] plus:
              [[@(1) sub: [curSensorEndpoints[CUR_S8] eq: curSensorEndpoints[CUR_S7]]] mul: @(20)]] leq: actualDelayPath5]];
    
    [m add: [[[[curSenToCon[CUR_S8] gt: NONE] mul: curToConDelay[CUR_S8]] plus:
              [[@(1) sub: [curSensorEndpoints[CUR_S8] eq: curSensorEndpoints[CUR_S3]]] mul: @(20)]] leq: actualDelayPath5]];
    [m add: [[[[curSenToCon[CUR_S3] gt: NONE] mul: curToConDelay[CUR_S3]] plus:
              [[@(1) sub: [curSensorEndpoints[CUR_S8] eq: curSensorEndpoints[CUR_S3]]] mul: @(20)]] leq: actualDelayPath5]];
    
    
    // Use path 6
    [m add: [[usePath6[0] eq: @(1)] eq: [contSensors[CONT_S6] gt: NONE]]];
    [m add: [[usePath6[1] eq: @(1)] eq: [voltSensors[VOLT_S9] gt: NONE]]];
    [m add: [[usePath6[1] eq: @(1)] eq: [voltSensors[VOLT_S6] gt: NONE]]];
    [m add: [[usePath6[1] eq: @(1)] eq: [[pmuDirectPMU elt: voltSensorEndpoints[VOLT_S9] elt: voltSensorEndpoints[VOLT_S6]] eq: @(1)]]];
    [m add: [[usePath6[2] eq: @(1)] eq: [voltSensors[VOLT_S9] gt: NONE]]];
    [m add: [[usePath6[2] eq: @(1)] eq: [voltSensors[VOLT_S1] gt: NONE]]];
    [m add: [[usePath6[2] eq: @(1)] eq: [[pmuDirectPMU elt: voltSensorEndpoints[VOLT_S9] elt: voltSensorEndpoints[VOLT_S1]] eq: @(1)]]];
    [m add: [[usePath6[3] eq: @(1)] eq: [curSensors[CUR_S9] gt: NONE]]];
    [m add: [[usePath6[3] eq: @(1)] eq: [curSensors[CUR_S6] gt: NONE]]];
    [m add: [[usePath6[3] eq: @(1)] eq: [[pmuDirectPMU elt: curSensorEndpoints[CUR_S9] elt: curSensorEndpoints[CUR_S6]] eq: @(1)]]];
    [m add: [[usePath6[4] eq: @(1)] eq: [curSensors[CUR_S9] gt: NONE]]];
    [m add: [[usePath6[4] eq: @(1)] eq: [curSensors[CUR_S1] gt: NONE]]];
    [m add: [[usePath6[4] eq: @(1)] eq: [[pmuDirectPMU elt: curSensorEndpoints[CUR_S9] elt: curSensorEndpoints[CUR_S1]] eq: @(1)]]];

    // Delays on path 6
    [m add: [[[[voltSenToCon[VOLT_S9] gt: NONE] mul: voltToConDelay[VOLT_S9]] plus:
              [[@(1) sub: [voltSensorEndpoints[VOLT_S9] eq: voltSensorEndpoints[VOLT_S6]]] mul: @(20)]] leq: actualDelayPath6]];
    [m add: [[[[voltSenToCon[VOLT_S6] gt: NONE] mul: voltToConDelay[VOLT_S6]] plus:
              [[@(1) sub: [voltSensorEndpoints[VOLT_S9] eq: voltSensorEndpoints[VOLT_S6]]] mul: @(20)]] leq: actualDelayPath6]];
    
    [m add: [[[[voltSenToCon[VOLT_S9] gt: NONE] mul: voltToConDelay[VOLT_S9]] plus:
              [[@(1) sub: [voltSensorEndpoints[VOLT_S9] eq: voltSensorEndpoints[VOLT_S1]]] mul: @(20)]] leq: actualDelayPath6]];
    [m add: [[[[voltSenToCon[VOLT_S1] gt: NONE] mul: voltToConDelay[VOLT_S1]] plus:
              [[@(1) sub: [voltSensorEndpoints[VOLT_S9] eq: voltSensorEndpoints[VOLT_S1]]] mul: @(20)]] leq: actualDelayPath6]];
    
    [m add: [[[[curSenToCon[CUR_S9] gt: NONE] mul: curToConDelay[CUR_S9]] plus:
              [[@(1) sub: [curSensorEndpoints[CUR_S9] eq: curSensorEndpoints[CUR_S6]]] mul: @(20)]] leq: actualDelayPath6]];
    [m add: [[[[curSenToCon[CUR_S6] gt: NONE] mul: curToConDelay[CUR_S6]] plus:
              [[@(1) sub: [curSensorEndpoints[CUR_S9] eq: curSensorEndpoints[CUR_S6]]] mul: @(20)]] leq: actualDelayPath6]];
    
    [m add: [[[[curSenToCon[CUR_S9] gt: NONE] mul: curToConDelay[CUR_S9]] plus:
              [[@(1) sub: [curSensorEndpoints[CUR_S9] eq: curSensorEndpoints[CUR_S1]]] mul: @(20)]] leq: actualDelayPath6]];
    [m add: [[[[curSenToCon[CUR_S1] gt: NONE] mul: curToConDelay[CUR_S1]] plus:
              [[@(1) sub: [curSensorEndpoints[CUR_S9] eq: curSensorEndpoints[CUR_S1]]] mul: @(20)]] leq: actualDelayPath6]];
    
    // Use Path 7
    [m add: [[usePath7[0] eq: @(1)] eq: [contSensors[CONT_S7] gt: NONE]]];
    [m add: [[usePath7[1] eq: @(1)] eq: [voltSensors[VOLT_S10] gt: NONE]]];
    [m add: [[usePath7[1] eq: @(1)] eq: [voltSensors[VOLT_S6] gt: NONE]]];
    [m add: [[usePath7[1] eq: @(1)] eq: [[pmuDirectPMU elt: voltSensorEndpoints[VOLT_S10] elt: voltSensorEndpoints[VOLT_S6]] eq: @(1)]]];
    [m add: [[usePath7[2] eq: @(1)] eq: [voltSensors[VOLT_S10] gt: NONE]]];
    [m add: [[usePath7[2] eq: @(1)] eq: [voltSensors[VOLT_S1] gt: NONE]]];
    [m add: [[usePath7[2] eq: @(1)] eq: [[pmuDirectPMU elt: voltSensorEndpoints[VOLT_S10] elt: voltSensorEndpoints[VOLT_S1]] eq: @(1)]]];
    [m add: [[usePath7[3] eq: @(1)] eq: [curSensors[CUR_S10] gt: NONE]]];
    [m add: [[usePath7[3] eq: @(1)] eq: [curSensors[CUR_S6] gt: NONE]]];
    [m add: [[usePath7[3] eq: @(1)] eq: [[pmuDirectPMU elt: curSensorEndpoints[CUR_S10] elt: curSensorEndpoints[CUR_S6]] eq: @(1)]]];
    [m add: [[usePath7[4] eq: @(1)] eq: [curSensors[CUR_S10] gt: NONE]]];
    [m add: [[usePath7[4] eq: @(1)] eq: [curSensors[CUR_S1] gt: NONE]]];
    [m add: [[usePath7[4] eq: @(1)] eq: [[pmuDirectPMU elt: curSensorEndpoints[CUR_S10] elt: curSensorEndpoints[CUR_S1]] eq: @(1)]]];

    // Delays on path 7
    [m add: [[[[voltSenToCon[VOLT_S10] gt: NONE] mul: voltToConDelay[VOLT_S10]] plus:
              [[@(1) sub: [voltSensorEndpoints[VOLT_S10] eq: voltSensorEndpoints[VOLT_S6]]] mul: @(20)]] leq: actualDelayPath7]];
    [m add: [[[[voltSenToCon[VOLT_S6] gt: NONE] mul: voltToConDelay[VOLT_S6]] plus:
              [[@(1) sub: [voltSensorEndpoints[VOLT_S10] eq: voltSensorEndpoints[VOLT_S6]]] mul: @(20)]] leq: actualDelayPath7]];
    
    [m add: [[[[voltSenToCon[VOLT_S10] gt: NONE] mul: voltToConDelay[VOLT_S10]] plus:
              [[@(1) sub: [voltSensorEndpoints[VOLT_S10] eq: voltSensorEndpoints[VOLT_S1]]] mul: @(20)]] leq: actualDelayPath7]];
    [m add: [[[[voltSenToCon[VOLT_S1] gt: NONE] mul: voltToConDelay[VOLT_S1]] plus:
              [[@(1) sub: [voltSensorEndpoints[VOLT_S10] eq: voltSensorEndpoints[VOLT_S1]]] mul: @(20)]] leq: actualDelayPath7]];
    
    [m add: [[[[curSenToCon[CUR_S10] gt: NONE] mul: curToConDelay[CUR_S10]] plus:
              [[@(1) sub: [curSensorEndpoints[CUR_S10] eq: curSensorEndpoints[CUR_S6]]] mul: @(20)]] leq: actualDelayPath7]];
    [m add: [[[[curSenToCon[CUR_S6] gt: NONE] mul: curToConDelay[CUR_S6]] plus:
              [[@(1) sub: [curSensorEndpoints[CUR_S10] eq: curSensorEndpoints[CUR_S6]]] mul: @(20)]] leq: actualDelayPath7]];
    
    [m add: [[[[curSenToCon[CUR_S10] gt: NONE] mul: curToConDelay[CUR_S10]] plus:
              [[@(1) sub: [curSensorEndpoints[CUR_S10] eq: curSensorEndpoints[CUR_S1]]] mul: @(20)]] leq: actualDelayPath7]];
    [m add: [[[[curSenToCon[CUR_S1] gt: NONE] mul: curToConDelay[CUR_S1]] plus:
              [[@(1) sub: [curSensorEndpoints[CUR_S10] eq: curSensorEndpoints[CUR_S1]]] mul: @(20)]] leq: actualDelayPath7]];
    
    
    // Use path 8
    [m add: [[usePath8[0] eq: @(1)] eq: [contSensors[CONT_S8] gt: NONE]]];
    [m add: [[usePath8[1] eq: @(1)] eq: [voltSensors[VOLT_S10] gt: NONE]]];
    [m add: [[usePath8[1] eq: @(1)] eq: [voltSensors[VOLT_S7] gt: NONE]]];
    [m add: [[usePath8[1] eq: @(1)] eq: [[pmuDirectPMU elt: voltSensorEndpoints[VOLT_S10] elt: voltSensorEndpoints[VOLT_S7]] eq: @(1)]]];
    [m add: [[usePath8[2] eq: @(1)] eq: [voltSensors[VOLT_S10] gt: NONE]]];
    [m add: [[usePath8[2] eq: @(1)] eq: [voltSensors[VOLT_S3] gt: NONE]]];
    [m add: [[usePath8[2] eq: @(1)] eq: [[pmuDirectPMU elt: voltSensorEndpoints[VOLT_S10] elt: voltSensorEndpoints[VOLT_S3]] eq: @(1)]]];
    [m add: [[usePath8[3] eq: @(1)] eq: [curSensors[CUR_S10] gt: NONE]]];
    [m add: [[usePath8[3] eq: @(1)] eq: [curSensors[CUR_S7] gt: NONE]]];
    [m add: [[usePath8[3] eq: @(1)] eq: [[pmuDirectPMU elt: curSensorEndpoints[CUR_S10] elt: curSensorEndpoints[CUR_S7]] eq: @(1)]]];
    [m add: [[usePath8[4] eq: @(1)] eq: [curSensors[CUR_S10] gt: NONE]]];
    [m add: [[usePath8[4] eq: @(1)] eq: [curSensors[CUR_S3] gt: NONE]]];
    [m add: [[usePath8[4] eq: @(1)] eq: [[pmuDirectPMU elt: curSensorEndpoints[CUR_S10] elt: curSensorEndpoints[CUR_S3]] eq: @(1)]]];

    // Delays on path 8
    [m add: [[[[voltSenToCon[VOLT_S10] gt: NONE] mul: voltToConDelay[VOLT_S10]] plus:
              [[@(1) sub: [voltSensorEndpoints[VOLT_S10] eq: voltSensorEndpoints[VOLT_S7]]] mul: @(20)]] leq: actualDelayPath8]];
    [m add: [[[[voltSenToCon[VOLT_S7] gt: NONE] mul: voltToConDelay[VOLT_S7]] plus:
              [[@(1) sub: [voltSensorEndpoints[VOLT_S10] eq: voltSensorEndpoints[VOLT_S7]]] mul: @(20)]] leq: actualDelayPath8]];
    
    [m add: [[[[voltSenToCon[VOLT_S10] gt: NONE] mul: voltToConDelay[VOLT_S10]] plus:
              [[@(1) sub: [voltSensorEndpoints[VOLT_S10] eq: voltSensorEndpoints[VOLT_S3]]] mul: @(20)]] leq: actualDelayPath8]];
    [m add: [[[[voltSenToCon[VOLT_S3] gt: NONE] mul: voltToConDelay[VOLT_S3]] plus:
              [[@(1) sub: [voltSensorEndpoints[VOLT_S10] eq: voltSensorEndpoints[VOLT_S3]]] mul: @(20)]] leq: actualDelayPath8]];
    
    [m add: [[[[curSenToCon[CUR_S10] gt: NONE] mul: curToConDelay[CUR_S10]] plus:
              [[@(1) sub: [curSensorEndpoints[CUR_S10] eq: curSensorEndpoints[CUR_S7]]] mul: @(20)]] leq: actualDelayPath8]];
    [m add: [[[[curSenToCon[CUR_S7] gt: NONE] mul: curToConDelay[CUR_S7]] plus:
              [[@(1) sub: [curSensorEndpoints[CUR_S10] eq: curSensorEndpoints[CUR_S7]]] mul: @(20)]] leq: actualDelayPath8]];
    
    [m add: [[[[curSenToCon[CUR_S10] gt: NONE] mul: curToConDelay[CUR_S10]] plus:
              [[@(1) sub: [curSensorEndpoints[CUR_S10] eq: curSensorEndpoints[CUR_S3]]] mul: @(20)]] leq: actualDelayPath8]];
    [m add: [[[[curSenToCon[CUR_S3] gt: NONE] mul: curToConDelay[CUR_S3]] plus:
              [[@(1) sub: [curSensorEndpoints[CUR_S10] eq: curSensorEndpoints[CUR_S3]]] mul: @(20)]] leq: actualDelayPath8]];
    
    
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
        
        // Write PMU
        NSXMLElement* pmuRoot = [[NSXMLElement alloc] initWithName: @"pmus"];
        if([bestSolution intValue: pmu[1]]) {
            ORInt template = 0;
            NSXMLElement* pmuNode = [[NSXMLElement alloc] initWithName: @"pmu"];
            [pmuNode addAttribute: [NSXMLNode attributeWithName:@"id" stringValue: @"pmu1"]];
            [pmuNode addChild: [[NSXMLElement alloc] initWithName: @"template" stringValue: [NSString stringWithFormat: @"%i", template]]];
            [pmuRoot addChild: pmuNode];
        }
        if([bestSolution intValue: pmu[2]]) {
            ORInt template = 0;
            NSXMLElement* pmuNode = [[NSXMLElement alloc] initWithName: @"pmu"];
            [pmuNode addAttribute: [NSXMLNode attributeWithName:@"id" stringValue: @"pmu2"]];
            [pmuNode addChild: [[NSXMLElement alloc] initWithName: @"template" stringValue: [NSString stringWithFormat: @"%i", template]]];
            [pmuRoot addChild: pmuNode];
        }
        if([bestSolution intValue: pmu[3]]) {
            ORInt template = 0;
            NSXMLElement* pmuNode = [[NSXMLElement alloc] initWithName: @"pmu"];
            [pmuNode addAttribute: [NSXMLNode attributeWithName:@"id" stringValue: @"pmu3"]];
            [pmuNode addChild: [[NSXMLElement alloc] initWithName: @"template" stringValue: [NSString stringWithFormat: @"%i", template]]];
            [pmuRoot addChild: pmuNode];
        }
        [root addChild: pmuRoot];
        
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
        if([bestSolution intValue: useBus[3]]) {
            ORInt template = 0;
            NSXMLElement* busNode = [[NSXMLElement alloc] initWithName: @"data_bus"];
            [busNode addAttribute: [NSXMLNode attributeWithName:@"id" stringValue: @"bus3"]];
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
        [xmlData release];
        NSLog(@"Wrote Solution File: %@", outPath);
    };

   id<ORModel> lm = [ORFactory linearizeModel: m];

   
   id<ORRelaxation> relax = nil;
   __block id<ORSolution> bestSolution = nil;
   //relax = [ORFactory createLinearRelaxation:lm];
   id<ORIntVarArray> aiv = m.intVars;
   __block ORInt fLim = 1000;
   __block ORInt best = FDMAXINT;
   
   id<ORRunnable> r0 = [ORFactory CPRunnable:m
                              withRelaxation: relax
                                  controller: [ORDFSController proto]
                                       solve:^(id<CPProgram> p)
   {
         id<ORTau> t = p.modelMappings.tau;
      id<ORIntVarArray> x = [[t get:o1] vars]; //joinVarArray(p, [[t get:o1] vars], [[t get:o2] vars]);
      id<ORIntArray>    c = [[t get:o1] coefs]; //joinIntArray(p, [[t get:o1] coefs], [[t get:o2] coefs]);
      id<ORUniformDistribution> d = [ORFactory uniformDistribution:m range:RANGE(m,1,100)];

//         PCBranching* pcb = [[PCBranching alloc] init:relax over:aiv program:p];
//         [pcb branchOn:aiv];
      [p repeat:^{
         [p limitFailures:fLim in:^{
            while (![p allBound:x]) {
               [p select:x minimizing:^ORDouble(ORInt i) { return  (( - [c at:i] * [p regret:x[i]]) << 16)  + [p domsize:x[i]];} in:^(ORInt i) {
                  [p try:^{
                     [p label:x[i] with:[p min:x[i]]];
                  } alt:^{
                     [p diff:x[i] with:[p min:x[i]]];
                  }];
               }];
            }
            [p labelArray:aiv];
            [p splitArray:aiv];
            NSLog(@"Solution cost: %i", [[[p captureSolution] objectiveValue] intValue]);
            id<ORSolution> s = [p captureSolution];
            writeOut(s);
            for(ORInt k = [busRange low]; k <= [busRange up]; k++)
               NSLog(@"numBus %i: %i, use: %i", k, [s intValue: numBusConn[k]], [s intValue: useBus[k]]);
            for(ORInt k = [concRange low]; k <= [concRange up]; k++)
               NSLog(@"numConn %i: %i, use: %i", k, [s intValue: numConcConn[k]], [s intValue: useConc[k]]);
            NSLog(@"path0: %i %i %i %i %i", [s intValue: usePath0[0]], [s intValue: usePath0[1]],
                  [s intValue: usePath0[2]], [s intValue: usePath0[3]], [s intValue: usePath0[4]]);
         }];
      } onRepeat:^{
         id<ORSolution> s = [[p solutionPool] best];
         if (s!=nil) {
            bool improve = [[s objectiveValue] intValue] < best;
            for(ORInt i=x.range.low;i <= x.range.up;i+=1) {
               if ([d next] <= 90) {
                  [p add: [x[i]  eq: @([s intValue:x[i]])]];
               }
            }
            if (improve)
               best = [[s objectiveValue] intValue];
            else fLim *= 2;
            NSLog(@"LNS move... Next Limit = %d",fLim);
         } else fLim *= 2;
      }];
      
//         [p labelArrayFF: voltSensorEndpoints];
//         [p labelArrayFF: curSensorEndpoints];
//         [p labelArrayFF: contSensorEndpoints];
//         [p labelArrayFF: busEndpoints];
//         [p labelArrayFF: concEndpoints];

      }];
   
   id<ORRunnable> r1 = [ORFactory MIPRunnable: lm];
   id<ORRunnable> rp = [ORFactory composeCompleteParallel:r0 with:r1];
   
   id<ORRunnable> r  = r0;
   ORLong cpu0 = [ORRuntimeMonitor wctime];
   [r run];
   bestSolution = [r bestSolution];
   writeOut(bestSolution);
   ORLong cpu1 = [ORRuntimeMonitor wctime];
   NSLog(@"Time to solution: %lld",cpu1 - cpu0);
   
//   NSLog(@"POW USE: %i", [bestSolution intValue: powUse]);
//   
//   for(ORInt k = [concRange low]; k <= [concRange up]; k++)
//      NSLog(@"concToBus %i: %i", k, [bestSolution intValue: concToBus[k]]);
//   
//   for(ORInt k = [busRange low]; k <= [busRange up]; k++)
//      NSLog(@"useBus %i: %i", k, [bestSolution intValue: bus[k]]);
   
   return 0;
}
