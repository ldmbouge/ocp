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

typedef enum {
    S0 = 0, S1, S2, S3, S4, S5, S6, S7, S8
} SENSOR;

ORInt rawSensBandwith[] = {
  35, 35, 35, 40, 51, 47, 18, 66, 22
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
    20, 20, 80, 80, 100, 100, 100, 120, 120
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

ORInt CON_COST = 60;
ORInt CON_WEIGHT = 6;

ORInt PMU_POW = 120;
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
    NSArray* sensorTemplates = [xmlDoc nodesForXPath: @"/template_library/sensor_templates/sensor" error: &err];
    ORInt numSensorTemplates = (ORInt)[sensorTemplates count];
    NSArray* busTemplates = [xmlDoc nodesForXPath: @"/template_library/data_bus_templates/data_bus" error: &err];
    ORInt numBusTemplates = (ORInt)[sensorTemplates count];
    NSArray* concTemplates = [xmlDoc nodesForXPath: @"/template_library/concentrator_templates/concentrator" error: &err];
    ORInt numConcTemplates = (ORInt)[concTemplates count];
    NSArray* bbfTemplates = [xmlDoc nodesForXPath: @"/template_library/blackbox_templates/bbf" error: &err];

    id<ORIntRange> genBounds = RANGE(m, 0, numGeneratorTemplates-1);
    id<ORIntRange> genRange = RANGE(m, 0, numMainGen + numBackupGen - 1);
    id<ORIntRange> senBounds = RANGE(m, 0, numSensorTemplates-1);
    id<ORIntRange> senRange = RANGE(m, 0, numSensors-1);
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
    id<ORIntArray> sensWeight = [ORFactory intArray: m range: senBounds with: ^ORInt(ORInt i) {
        return [[[[sensorTemplates[i] elementsForName: @"weight"] lastObject] stringValue] intValue]; }];
    id<ORIntArray> sensCost = [ORFactory intArray: m range: senBounds with: ^ORInt(ORInt i) {
        return [[[[sensorTemplates[i] elementsForName: @"cost"] lastObject] stringValue] intValue]; }];
    id<ORIntArray> sensPowDraw = [ORFactory intArray: m range: senBounds with: ^ORInt(ORInt i) {
        return [[[[sensorTemplates[i] elementsForName: @"power"] lastObject] stringValue] intValue]; }];
    
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
    id<ORIntVarArray> sensors = [ORFactory intVarArray: m range: senRange bounds: senBounds];
    
    // Direct Connections
    id<ORIntVarArray> senDirectPMU = [ORFactory intVarArray: m range: senRange bounds: boolBounds];

    // Connected to concentrator
    id<ORIntVarArray> senToCon = [ORFactory intVarArray: m range: senRange bounds: boolBounds];

    // Connected to Bus
    id<ORIntVarArray> senToBus = [ORFactory intVarArray: m range: senRange bounds: boolBounds];

    // Concetrators
    id<ORIntVar> useConc0 = [ORFactory intVar: m bounds: boolBounds];
    id<ORIntVar> useConc1 = [ORFactory intVar: m bounds: boolBounds];

    // Bus
    id<ORIntVar> useBus0 = [ORFactory intVar: m bounds: boolBounds];

    id<ORIntVar> powUse = [ORFactory intVar: m bounds: RANGE(m, 0, 10000)];
    id<ORIntVar> bandUse = [ORFactory intVar: m bounds: RANGE(m, 0, 10000)];
    id<ORIntVar> cost = [ORFactory intVar: m bounds: RANGE(m, 0, 99999)];
    id<ORIntVar> weight = [ORFactory intVar: m bounds: RANGE(m, 0, 99999)];
    
    
    // Template Tables -----------------------------------------------------------------------
    
    
    id<ORIntArray> sensBandwith = [ORFactory intArray: m range: senRange values: rawSensBandwith];

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
              [[conCost elt: useConc0] plus: [conCost elt: useConc1]]] plus: // Concentrator cost
              [useBus0 mul: @(BUS_COST)]] // Bus Cost
             ]];
    
    // Weight /////////////////////////
    [m add: [weight eq:
             [[[[[[[[[mainGenWeight elt: g0] plus: [mainGenWeight elt: g1]] plus: [mainGenWeight elt: auxgen]] plus: // Gen weight
              Sum(m, i, senRange, [sensWeight elt: [sensors at: i]])] plus: // Cost of weight
              Sum(m, i, senRange, [@([directToPMUWeight at: i]) mul: [senDirectPMU at: i]])] plus: // Weight direct to PMU
              Sum(m, i, senRange, [@([senToBusWeight at: i]) mul: [senToBus at: i]])] plus: // Weight direct to bus
              Sum(m, i, senRange, [@([senToConWeight at: i]) mul: [senToCon at: i]])] plus: // Weight direct to Concentrator
              [[useConc0 mul:@(CON_WEIGHT)] plus: [useConc1 mul:@(CON_WEIGHT)]]] plus: // Concentrator weight
              [useBus0 mul: @(BUS_WGHT)] ]
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
    [m add: [[Sum(m, i, senRange, senToBus[i]) gt: @(0)] imply: [useBus0 eq: @(1)]]];
    
    for(ORInt i = [senRange low]; i <= [senRange up]; i++)
        [m add: [[senToBus[i] eq: @(1)] imply: [sensors[i] eq: @(SenWithConc)]]]; // If sens. connected to bus, must have its own concentrator
    
    // Concentrators //////////////////////
    [m add: [[[[[[senToCon[S0] plus: senToCon[S1]] plus: senToCon[S4]] plus: senToCon[S6]] plus: senToCon[S7]] gt: @(0)] imply: [useConc0 eq: @(1)]]];
    [m add: [[[[[senToCon[S2] plus: senToCon[S3]] plus: senToCon[S5]] plus: senToCon[S8]] gt: @(0)] imply: [useConc1 eq: @(1)]]];

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
    id<ORSolution> bestSolution = [sols best];
    
    NSLog(@"Sol count: %li", [sols count]);
    
    // Write Solution to XML ----------------------------------------------------------------------------------
    NSXMLElement* root = [[NSXMLElement alloc] initWithName: @"utc_architecture"];
    
    // Write Sensors
    NSXMLElement* sensorsRoot = [[NSXMLElement alloc] initWithName: @"sensors"];
    for(ORInt i = [senRange low]; i <= [senRange up]; i++) {
        ORInt template = [bestSolution intValue: sensors[i]];
        NSXMLElement* sensorNode = [[NSXMLElement alloc] initWithName: @"sensor"];
        [sensorNode addAttribute: [NSXMLNode attributeWithName:@"id" stringValue: [NSString stringWithFormat: @"%i", i]]];
        [sensorNode addChild: [[NSXMLElement alloc] initWithName: @"template" stringValue: [NSString stringWithFormat: @"%i", template]]];
        
        NSString* data_string = @"PMU";
        if([bestSolution intValue: senToBus[i]]) data_string = @"bus";
        else if([bestSolution intValue: senToCon[i]]) data_string = @"concentrator";
        [sensorNode addChild: [[NSXMLElement alloc] initWithName: @"data_connect" stringValue: data_string]];

        [sensorsRoot addChild: sensorNode];
    }
    [root addChild: sensorsRoot];
    
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
    if([bestSolution intValue: useBus0]) {
        ORInt template = 0;
        NSXMLElement* busNode = [[NSXMLElement alloc] initWithName: @"data_bus"];
        [busNode addAttribute: [NSXMLNode attributeWithName:@"id" stringValue: @"bus0"]];
        [busNode addChild: [[NSXMLElement alloc] initWithName: @"template" stringValue: [NSString stringWithFormat: @"%i", template]]];
        [busesRoot addChild: busNode];
    }
    [root addChild: busesRoot];
    
    // Write Concentrators
    NSXMLElement* concRoot = [[NSXMLElement alloc] initWithName: @"concentrators"];
    if([bestSolution intValue: useConc0]) {
        ORInt template = 0;
        NSXMLElement* concNode = [[NSXMLElement alloc] initWithName: @"concentrator"];
        [concNode addAttribute: [NSXMLNode attributeWithName:@"id" stringValue: @"conc0"]];
        [concNode addChild: [[NSXMLElement alloc] initWithName: @"template" stringValue: [NSString stringWithFormat: @"%i", template]]];
        [concRoot addChild: concNode];
    }
    if([bestSolution intValue: useConc1]) {
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
    
    return 0;
}
