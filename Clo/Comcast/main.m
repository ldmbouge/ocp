//
//  main.m
//  Comcast
//
//  Created by Daniel Fontaine on 2/3/17.
//  Modified by Waldemar Cruz and Fanghui Liu
//

#import <ORFoundation/ORFoundation.h>
#import <ORFoundation/ORSemBDSController.h>
#import <ORFoundation/ORSemDFSController.h>
#import <ORModeling/ORModeling.h>
#import <ORModeling/ORModelTransformation.h>
#import <ORProgram/ORProgram.h>
#import <ORModeling/ORLinearize.h>
#import "XMLReader.h"
#import "Cnode.h"
#import "SecurityTech.h"
#import "Service.h"

struct Connection{
  ORInt demandService;
  ORInt supplyService;
  ORInt security;
  ORInt LB;
  ORInt LS;
  ORInt HS;
};


enum Mode {
  MIP,CP,Hybrid,xHybrid,LNS,Expe,Waldy,Waldy2,Waldy3,NewWaldy
};

int main(int argc, const char * argv[])
{
    enum Mode mode;
    ORInt tLim = 0;
    ORInt scale = 1;
    if (strncmp(argv[2],"MIP",3)==0)
        mode = MIP;
    else if (strncmp(argv[2],"CP",2) == 0)
        mode = CP;
    else if (strncmp(argv[2],"LNS",2) == 0)
        mode = LNS;
    else if (strncmp(argv[2],"Hybrid",6)==0)
        mode = Hybrid;
    else if (strncmp(argv[2],"xHybrid",7)==0)
        mode = xHybrid;
    else if (strncmp(argv[2],"Waldy",5)==0)
        mode = NewWaldy;
    else if (strncmp(argv[2],"2Waldy",6)==0)
        mode = Waldy2;
    else if (strncmp(argv[2],"3Waldy",6)==0)
        mode = Waldy3;
    else mode= Expe;
    BOOL printSol = NO;
    if (argc >= 4) {
        int ak = 3;
        while (ak < argc) {
            if (strncmp(argv[ak],"-print",6)==0)
                printSol = YES;
            else if (strncmp(argv[ak],"-time",5)==0){
                tLim = atoi(argv[ak]+5);
		NSLog(@"TIME = %d", tLim);
	    }
	    else if (strncmp(argv[ak],"-scale",6) == 0){
	      scale = atoi(argv[ak]+6);
	      NSLog(@"SCALE = %d", scale);
	    }
            ak += 1;
        }
    }
    

    id<ORModel> model = [ORFactory createModel];
    //id<ORAnnotation> notes = [ORFactory annotation];
    NSMutableArray * serviceArray = [[NSMutableArray alloc] init];
    NSMutableArray * secArray  = [[NSMutableArray alloc] init];
    NSMutableArray * cnodeArray = [[NSMutableArray alloc] init];
    
    // create and init delegate
    NSString* fName = [NSString stringWithUTF8String:argv[1]];
    XMLReader * dataIn = [[XMLReader alloc] initWithArrays: cnodeArray serviceArray: serviceArray secArray: secArray];
    [dataIn parseXMLFile: fName];
    
    ORInt Ncnodes = (ORInt)[cnodeArray count] * scale;
    ORInt Nservices = (ORInt)[serviceArray count];
    ORInt Nsec = (ORInt)[secArray count]-1;
    //ORInt MAX_CONN = dataIn.maxCONN;
    ORInt VM_MEM = dataIn.vmMEM;
    ORInt maxPerVM = dataIn.maxPerVM;
    //ORInt maxVMs = dataIn.maxVMs;
    
    ORInt Scaler = 1;
    
    id<ORIntRange> cnodes = RANGE(model,1, Ncnodes*Scaler);
    id<ORIntRange> services = RANGE(model,1, Nservices);
    id<ORIntRange> sec = RANGE(model,0, Nsec);
    
    
    // Use info from XML instead of random values
    id<ORIntArray> cnodeMem = [ORFactory intArray: model range: cnodes with:^ORInt(ORInt i) {
        if(Scaler > 1)
            return [cnodeArray[0] cnodeMemory];
        return [cnodeArray[(i-1)/scale] cnodeMemory];
    } ];
    id<ORIntArray> cnodeBw = [ORFactory intArray: model range: cnodes with:^ORInt(ORInt i) {
        if(Scaler > 1)
            return [cnodeArray[0] cnodeBandwidth];
        return [cnodeArray[(i-1)/scale] cnodeBandwidth];
    } ];
    id<ORIntArray> cnodeCpu = [ORFactory intArray: model range: cnodes with:^ORInt(ORInt i) {
        if(Scaler > 1)
            return [cnodeArray[0] cnodeCPU];
        return [cnodeArray[(i-1)/scale] cnodeCPU];
    } ];
    
    id<ORIntArray> serviceFixMem = [ORFactory intArray: model range: services with:^ORInt(ORInt i) {
        return [serviceArray[i-1] serviceFixMemory];
    } ];

    id<ORIntArray> serviceFixBw = [ORFactory intArray: model range: services with:^ORInt(ORInt i) {
        return [serviceArray[i-1] serviceFixBandwidth];
    } ];

    id<ORIntArray> serviceZone = [ORFactory intArray: model range: services with:^ORInt(ORInt i) {
        return [serviceArray[i-1] serviceZone];
    } ];
    id<ORIntArray> secFixMem = [ORFactory intArray: model range: sec with:^ORInt(ORInt i) {
        return [secArray[i] secFixedMemory];
    } ];
    id<ORIntArray> secFixBw = [ORFactory intArray: model range: sec with:^ORInt(ORInt i) {
        return [secArray[i] secFixedBandwidth];
    } ];
    id<ORIntArray> serviceCPU = [ORFactory intArray: model range: services with:^ORInt(ORInt i) {
        return [serviceArray[i-1] serviceFixCPU];
    } ];
    id<ORIntArray> secScaledMem = [ORFactory intArray: model range: sec with:^ORInt(ORInt i) {
        return [secArray[i] secScaledMemory];
    } ];
    id<ORIntArray> secScaledBw = [ORFactory intArray: model range: sec with:^ORInt(ORInt i) {
        return [secArray[i] secScaledBandwidth];
    } ];

    
    
    
    
    NSDictionary* Ddict = dataIn.D;
    id<ORIntArray> D = [ORFactory intArray: model range: services with:^ORInt(ORInt i) {
        return [[Ddict objectForKey:@(i)] intValue] * Scaler;
    }];
    
    NSLog(@"Scaled D = {");
    for(int i = [D range].low; i <= [D range].up; i++)
        NSLog(@"%d ", [D at: i]);
    
    
    
    NSArray* Cmatrix = dataIn.C;
    id<ORIntMatrix> C = [ORFactory intMatrix: model range: services : services with:^int(ORInt i, ORInt j) {
        return [[[Cmatrix objectAtIndex:i - 1] objectAtIndex:j - 1] intValue];  // matrix in XML file is 0-based
    }];
    
    id<ORIntArray> Uservice = [ORFactory intArray: model range: services with:^ORInt(ORInt i) { return [D at: i]; }]; // same as D!
    id<ORIntRange> Iservice = RANGE(model,0, [Uservice sumWith:^ORInt(ORInt value, int idx) { return value; }]-1);
    id<ORIdArray> omega = [ORFactory idArray: model range: services with:^id _Nonnull(ORInt a) {
        ORInt offset = [Uservice sumWith:^ORInt(ORInt value, int idx) { return idx < a ? value : 0; }];
        return RANGE(model, offset, offset + [Uservice at: a] - 1);
    }];
    
    id<ORIntArray> alpha = [ORFactory intArray: model range: Iservice with:^ORInt(ORInt a) {
        for(ORInt i = [omega low]; i <= [omega up]; i++) {
            id<ORIntRange> r = [omega at: i];
            if([r inRange: a]) return i;
        }
        return -1;
    }];

    struct Connection conns[100];

    ORInt numConn = 0;
    for(int i = services.low; i <= services.up; i++){
        for(int j = i+1; j <= services.up; j++){
            if([C at: i :j] > 0){
                struct Connection temp;
                if([D at: i] > [D at: j]){
                    temp.demandService = i;
                    temp.supplyService = j;
                    temp.LB = [D at: i] / [D at: j];
                    temp.HS = [D at: i] % [D at: j];
                    temp.LS = [D at: j] - temp.HS;
                }
                else if([D at: j] > [D at: i]){
                    temp.demandService = j;
                    temp.supplyService = i;
                    temp.LB = [D at: j] / [D at: i];
                    temp.HS = [D at: j] % [D at: i];
                    temp.LS = [D at: i] - temp.HS;
                }
                else{
                    //same
                    temp.demandService = j;
                    temp.supplyService = i;
                    temp.LB = 1;
                    temp.HS = 0;
                    temp.LS = [D at: j];
                }
                temp.security = MAX([serviceZone at: i], [serviceZone at: j]);
                conns[numConn++] = temp;
            }
        }
    }
    
    //u_mem[i]: is the memory usage for machine i
    id<ORIntVarArray> u_mem = [ORFactory intVarArray:model range:cnodes with:^id<ORIntVar> _Nonnull(ORInt x) {
        return [ORFactory intVar: model domain:[ORFactory intRange:model low:0 up:([cnodeMem at: x])]];
    }];
    
    //u_bw[i]: is the bandwidth usage for machine i
    id<ORIntVarArray> u_bw =[ORFactory intVarArray:model range:cnodes with:^id<ORIntVar> _Nonnull(ORInt x) {
        return [ORFactory intVar: model domain:[ORFactory intRange:model low:0 up:([cnodeBw at: x])]];
    }];
    
    id<ORIntVarMatrix> Q = [ORFactory intVarMatrix:model range:cnodes :services];
    for(int i = cnodes.low; i <= cnodes.up; i++){
        for(int j = services.low; j <= services.up; j++){
            [Q set:[ORFactory intVar:model bounds:RANGE(model, 0, [D at: j])] at:i :j];
        }
    }
    
    for(int j = services.low; j <= services.up; j++){
        [model add: [Sum(model, i, cnodes, [Q at: i : j]) eq: @([D at: j])]];
    }
    
    id<ORIntVarMatrix> EQ[Ncnodes*Scaler+1+1];
    
    for(int i = cnodes.low; i <= cnodes.up; i++){
        EQ[i] = [ORFactory intVarMatrix:model range:services :sec];
        for(int j = services.low; j <= services.up; j++){
            for(int k = sec.low; k <= sec.up; k++){
                id<ORIntVarMatrix> temp = EQ[i];
                [temp set:[ORFactory intVar:model bounds:RANGE(model, 0, [D at: j])] at:j :k];
                [model add: [[temp at: j :k] leq: [Q at:i :j]]];
            }
        }
    }
    
    

    
    id<ORIntVarMatrix> ls = [ORFactory intVarMatrix:model range:cnodes :RANGE(model, 0, numConn-1)];
    id<ORIntVarMatrix> extraPorts = [ORFactory intVarMatrix:model range:cnodes :RANGE(model, 0, numConn-1)];
    id<ORIntVarMatrix> els = [ORFactory intVarMatrix:model range:cnodes :RANGE(model, 0, numConn-1)];
    //id<ORIntVarMatrix> ehs = [ORFactory intVarMatrix:model range:cnodes :RANGE(model, 0, numConn-1)];
    id<ORIntVarMatrix> ed = [ORFactory intVarMatrix:model range:cnodes :RANGE(model, 0, numConn-1)];
    id<ORIntVarMatrix> ops = [ORFactory intVarMatrix:model range:cnodes :RANGE(model, 0, numConn-1)];
    id<ORIntVarMatrix> opd = [ORFactory intVarMatrix:model range:cnodes :RANGE(model, 0, numConn-1)];

    id<ORIntVarMatrix> ports = [ORFactory intVarMatrix:model range:cnodes :RANGE(model, 0, numConn-1)];
    id<ORIntVarMatrix> s[numConn];
    
    for(int i = 0; i < numConn; i++){
        s[i] = [ORFactory intVarMatrix:model range:cnodes :cnodes];
        for(int j = cnodes.low; j <= cnodes.up; j++){
            for(int k = cnodes.low; k <= cnodes.up; k++){
                if(j == k)
                    [s[i] set:[ORFactory intVar:model bounds:RANGE(model, 0, 0)] at: j :k];
                else
                    [s[i] set:[ORFactory intVar:model bounds:RANGE(model, 0, [D at: conns[i].demandService])] at:j :k];
            }
        }
    }
    
    for(int m = cnodes.low; m <= cnodes.up; m++){
        for(int c = 0; c < numConn; c++){
            [ed set:[ORFactory intVar:model bounds:RANGE(model, 0, [D at: conns[c].demandService])] at:m :c];
            [ops set:[ORFactory intVar:model bounds:RANGE(model, 0, [D at: conns[c].demandService])] at:m :c];
            [opd set:[ORFactory intVar:model bounds:RANGE(model, 0, [D at: conns[c].demandService])] at:m :c];
            [ports set:[ORFactory intVar:model bounds:RANGE(model, 0, [D at: conns[c].demandService])] at:m :c];
            //[ls set:[ORFactory intVar:model bounds:RANGE(model, 0, conns[c].LS)] at:m :c];
            [ls set:[ORFactory intVar:model bounds:RANGE(model, 0, [D at: conns[c].demandService])] at:m :c];
            //NSLog(@"conn[%d].LS = %d",c,conns[c].LS);
            //NSLog(@"conn[%d].HS = %d",c,conns[c].HS);
            //NSLog(@"conn[%d].LB = %d",c,conns[c].LB);

            //NSLog(@"supply = %d",[D at: conns[c].supplyService]);
            //NSLog(@"demand = %d",[D at: conns[c].demandService]);

            [extraPorts set:[ORFactory intVar:model bounds:RANGE(model, 0, [D at: conns[c].demandService])] at:m :c];
            [els set:[ORFactory intVar:model bounds:RANGE(model, 0, [D at: conns[c].demandService])] at:m :c];

            //[els set:[ORFactory intVar:model bounds:RANGE(model, 0, conns[c].LS)] at:m :c];
            //[ehs set:[ORFactory intVar:model bounds:RANGE(model, 0, conns[c].HS)] at:m :c];
        }
    }
    for(int i = 0; i < numConn; i++){
        ORInt LB = conns[i].LB;
        [model add: [Sum(model, j, cnodes, [[@(LB) mul: [ls at: j : i]] plus: [extraPorts at:j : i]]) eq: @([D at: conns[i].demandService])]];
        //[model add: [Sum(model, j, cnodes, [hs at:j : i]) eq: @(conns[i].HS)]];
        
        for(int j = cnodes.low; j <= cnodes.up; j++){
            //[model add: [[[ls at: j : i] plus: [hs at: j : i]] eq: [Q at: j : conns[i].supplyService]]];
            [model add: [[ls at: j : i] eq: [Q at: j : conns[i].supplyService]]];

            [model add: [[ports at: j: i] eq: [[@(conns[i].LB) mul: [ls at: j : i]] plus: [extraPorts at:j :i]]]];

            //[model add: [[ports at: j: i] eq: [[@(conns[i].LB) mul: [ls at: j : i]] plus: [@(conns[i].LB + 1) mul: [hs at: j : i]]]]];
            [model add: [[[ports at: j: i] plus: [ops at: j: i]] eq: [[Q at: j : conns[i].demandService] plus: [opd at: j: i]]]];
        }
    }
    
    for(int i = 0; i < numConn; i++){
        for(int j = cnodes.low; j <= cnodes.up; j++){
            id<ORIntVarMatrix> temp = s[i];
            [model add: [[ops at:j :i] eq: Sum(model, k, cnodes, [temp at:k :j])]];
            [model add: [[opd at:j :i] eq: Sum(model, k, cnodes, [temp at:j :k])]];
        }
    }
    
    //Memory Consumption Constraints --
    
    for(int i = 0; i < numConn; i++){
        for(int j = cnodes.low; j <= cnodes.up; j++){
            [model add: [[els at: j : i] leq: [ls at: j : i]]];
            [model add: [[ls at:j :i] geq: [[extraPorts at:j :i] geq: @(1)]]];
            
            id<ORIntVar> exPorts = [ORFactory intVar:model bounds:RANGE(model, 0, [D at: conns[i].demandService])];
            [model add: [[els at:j :i] geq: [exPorts geq: @(1)]]];
            [model add: [exPorts leq: [extraPorts at:j :i]]];
            
            //[model add: [[ehs at: j : i] leq: [hs at: j : i]]];
            //[model add: [[ed at: j: i] leq: [Q at: j : conns[i].demandService]]];
            
            //[model add: [[opd at: j : i] leq: [[@(conns[i].LB) mul: [els at: j : i]] plus: [extraPorts at:j :i]]]];
            [model add: [[opd at: j : i] leq: [[@(conns[i].LB) mul: [els at: j : i]] plus: exPorts]]];

            [model add: [[ops at: j : i] eq: [ed at: j: i]]];
            //[model add: [[ops at: j : i] geq: [ed at: j: i]]];

            //test
            //[model add: [[opd at: j : i] eq: @(0)]];
            //[model add: [[ops at: j : i] eq: @(0)]];

        }
    }
    
    for(int i = cnodes.low; i <= cnodes.up; i++){
        for(int j = 0; j < numConn; j++){
            id<ORIntVarMatrix> eq = EQ[i];
            id<ORIntVar> e = [eq at: conns[j].supplyService : conns[j].security];
            //NSLog(@"supplyService = %d sec = %d", conns[j].supplyService, conns[j].security);
            //NSLog(@"ID: %d",[e getId]);
            
            [model add: [[eq at: conns[j].supplyService : conns[j].security] geq: [els at: i: j]]];
            [model add: [[eq at: conns[j].demandService : conns[j].security] geq: [ed at: i: j]]];
        }
    }
    
    for(int m = cnodes.low; m <= cnodes.up; m++){
        id<ORIntVarMatrix> eq = EQ[m];
        [model add:
         [[u_mem[m] mul: @(10)] geq:
          Sum(model, t, services,
                                   [[@(([serviceFixMem at: t] + VM_MEM)*10) mul: [Q at: m : t]] plus:
                                    Sum(model, z, sec, [@([serviceFixMem at: t]*[secScaledMem at: z]+([secFixMem at: z]*10)) mul: [eq at: t: z]])
              
              ])]];
    }
    
    //Bandwidth Consumption Constraints
    
    for(int m = cnodes.low; m <= cnodes.up; m++){
        id<ORExpr> parta = nil;

        for(int c = 0; c < numConn; c++){
            id<ORExpr> term1 = [@([secScaledBw at: conns[c].security]*[serviceFixBw at: conns[c].supplyService] + [serviceFixBw at: conns[c].supplyService]) mul: [ops at:m :c]];
            id<ORExpr> term2 = [@([secScaledBw at: conns[c].security]*[serviceFixBw at: conns[c].demandService] + [serviceFixBw at: conns[c].demandService]) mul: [opd at:m :c]];
            parta = parta == nil ? [term1 plus: term2] : [parta plus: [term1 plus: term2]];
        }
        
        id<ORExpr> partb = nil;
        
        for(int z = sec.low; z <= sec.up; z++){
            id<ORExpr> secpart = nil;
            for(int c = 0; c < numConn; c++){
                if(conns[c].security == z){
                    secpart = secpart == nil ? [[ops at:m : c] plus: [opd at:m :c]]: [secpart plus: [[ops at:m : c] plus: [opd at:m :c]]];
                }
            }
            if(secpart != nil){
                secpart = [secpart geq: @(1)];
                partb = partb == nil ? [secpart mul: @([secFixBw at:z])] : [partb plus: [secpart mul: @([secFixBw at:z])]];
            }
        }
        
        
        [model add: [u_bw[m] geq: [parta plus: partb]]];
    }

    // Variables
    //id<ORIntVarArray> v = [ORFactory intVarArray: model range: vm domain: RANGE(model, 0, Ncnodes)];
    
    //mc[i] is the number of instances deployed on machine i.
    id<ORIntVarArray> mc = [ORFactory intVarArray: model range: cnodes domain: RANGE(model, 0, maxPerVM*10)];

    [model minimize: Sum(model, i, cnodes, [u_mem[i] plus: u_bw[i]])];
    

    // Constraint counting the number of services running in each Machine.
    for(ORInt i = [cnodes low]; i <= [cnodes up]; i++) {
        [model add: [mc[i] eq: Sum(model, k, services, [Q at: i: k])]];
    }

    // VM symmetry breaking
    for(ORInt i = [cnodes low]; i < [cnodes up]; i++) {
        [model add: [[mc[i] eq: @(0)] imply: [mc[i+1] eq: @(0)]]];
    }
    
    id<ORSolution> best = nil;
    ORTimeval now = [ORRuntimeMonitor now];
    switch(mode) {
        case MIP: {
            id<ORModel> lm = [ORFactory linearizeModel: model];
            id<ORRunnable> r = [ORFactory MIPRunnable: lm];
            //id<MIPProgram> mp = [ORFactory create];
            [r start];
            best = [r bestSolution];
            /*
            for(int m = cnodes.low; m <= cnodes.up; m++){
                //NSLog(@"Machine Usage: u_mem[%d] = %d, u_bw[%d] = %d",m,[best intValue:u_mem[m]], m, [best intValue:u_bw[m]]);
                
                for(int c = 0; c < numConn; c++){
                    //NSLog(@"ls(%d,%d) = %d service: %d",m,c,[best intValue:[ls at:m :c]], conns[c].supplyService);
                    //NSLog(@"els(%d,%d) = %d service: %d",m,c,[best intValue:[els at:m :c]], conns[c].supplyService);

                    //NSLog(@"extraPorts(%d,%d) = %d service: %d",m,c,[best intValue:[extraPorts at:m :c]], conns[c].supplyService);

                    //NSLog(@"hs(%d,%d) = %d service: %d",m,c,[best intValue:[hs at:m :c]], conns[c].supplyService);
                }
                
                for(int s = services.low; s <= services.up; s++){
                    NSLog(@"Q(%d,%d) = %d",m,s,[best intValue:[Q at: m :s]]);
                }
                
                for(int c = 0; c < numConn; c++){
                    NSLog(@"opd(%d,%d) = %d",m,c, [best intValue:[opd at:m :c]]);
                    NSLog(@"ops(%d,%d) = %d",m,c, [best intValue:[ops at:m :c]]);
                }
            }
            
            for(int m = cnodes.low; m <= cnodes.up; m++){
                id<ORIntVarMatrix> eq = EQ[m];
                for(int t = services.low; t <= services.up; t++){
                    for(int z = sec.low; z <= sec.up; z++){
                        if([best intValue:[eq at: t: z]] > 0)
                            NSLog(@"EQ(%d,%d,%d) = %d",m,t,z,[best intValue:[eq at: t: z]]);
                    }
                }
            }
            NSLog(@"BUILDING MODEL 2......");
             */
            id<ORAnnotation> notes= [ORFactory annotation];
            id<ORModel> m2 = [ORFactory createModel];
            ORInt ivcount = 0;
            id<ORIntVarMatrix> allLinks[500];
            //Setup Internal Links
            
            id<ORIntArray> LQ = [ORFactory intArray:m2 range:services with:^ORInt(ORInt i) {
                if(i == 1)
                    return 0;
                else{
                    ORInt count = 0;
                    for(int j = 1; j < i; j++){
                        count += [D at: j];
                    }
                    return count;
                }
            }];
            
            ORInt numInstances = 0;
            for(int i = services.low; i <= services.up; i++){
                numInstances += [D at: i];
            }
            ORInt a[numInstances];
            
            id<ORIdMatrix> iNodes = [ORFactory idMatrix:m2 range:cnodes :services];
            for(int i = [iNodes range:0].low; i <= [iNodes range:0].up; i++){
                for(int j = [iNodes range:1].low; j <= [iNodes range:1].up; j++){
                    id<ORIntRange> temp = RANGE(m2,[LQ at:j],[LQ at:j] + [best intValue: [Q at: i :j]]-1);
                    NSLog(@"cnode: %d | service: %d | range low: %d up: %d", i, j, [LQ at:j],[LQ at:j] + [best intValue: [Q at: i :j]]-1);
                    [iNodes set:temp at:i :j];
                    [LQ set:([LQ at:j] + [best intValue: [Q at: i :j]]) at:j];
                    
                    for(ORInt t = temp.low; t <= temp.up; t++){
                        a[t] = i;
                    }
                }
            }
            

            
            printf("a = {");
            for(int i = 0; i < numInstances; i++){
                //NSLog(@"a[%d] = %d", i, a[i]);
                if(i == numInstances - 1)
                    printf(" %d", a[i]);
                else
                    printf(" %d,", a[i]);

            }
            printf("}\n");
 
            
            
            for(int c = 0; c < numConn; c++){
                id<ORIntVarMatrix> li = [ORFactory intVarMatrix:m2 range:[omega at: conns[c].supplyService] :[omega at: conns[c].demandService] ];
                //id<ORIntMatrix> liv = [ORFactory intMatrix:m2 range:[omega at: conns[c].supplyService] :[omega at: conns[c].demandService]];
                allLinks[ivcount++] = li;
                
                for(int i = [li range:0].low; i <= [li range:0].up; i++){
                    for(int j = [li range:1].low; j <= [li range:1].up; j++){
                        [li set:[ORFactory boolVar:m2] at:i :j];
                    }
                }
                
                

                for(int m = cnodes.low; m <= cnodes.up; m++){
                    for(int n = cnodes.low; n <= cnodes.up; n++){
                        id<ORIntRange> tr = [iNodes at: m : conns[c].supplyService];
                        id<ORIntRange> td = [iNodes at: n : conns[c].demandService];
                        if(tr.low > tr.up || td.low > td.up) continue;
                        
                        if(m == n){
                            //                [ORFactory cardinality:<#(nonnull id<ORIntVarArray>)#> low:<#(nonnull id<ORIntArray>)#> up:<#(nonnull id<ORIntArray>)#>]
                            ORInt min = MIN([best intValue:[ports at: m: c]],[best intValue:[Q at: m: conns[c].demandService]]);
                            
                            id<ORIntArray> l = [ORFactory intArray:m2 range:RANGE(m2,0,1) with:^ORInt(ORInt i) {
                                NSLog(@"low(%d) %d", i, min*i + ((tr.up - tr.low + 1)*(td.up - td.low + 1)-min)*(1-i));

                                return min*i + ((tr.up - tr.low + 1)*(td.up - td.low + 1)-min)*(1-i); }];
                            /*
                            id<ORIntArray> u = [ORFactory intArray:m2 range:RANGE(m2,0,1) with:^ORInt(ORInt i) {
                                NSLog(@"up(%d) %d", i, min*i + ((tr.up - tr.low + 1)*(td.up - td.low + 1)-min)*(1-i));
                                return min*i + ((tr.up - tr.low + 1)*(td.up - td.low + 1)-min)*(1-i);
                                
                            }];
                             */
                            NSLog(@"------------");

                            //id<ORIntArray> low = [ORFactory intArray:m2 array:[[NSArray alloc] initWithObjects:@(0), @(min), nil]];
                            //id<ORIntArray> up = [ORFactory intArray:m2 array:[[NSArray alloc] initWithObjects:@((tr.up - tr.low)*(td.up - td.low)), @(min), nil]];
                            
                            id<ORIntVarMatrix> subMatrix = [ORFactory intVarMatrix:m2 range:tr :td];
                            for(int i = tr.low; i <= tr.up; i++){
                                for(int j = td.low; j <= td.up; j++){
                                    [subMatrix set:[li at:i :j] at:i :j];
                                }
                            }
                            
                            /*
                            NSLog(@"maxIdx = %d", (tr.up - tr.low + 1)*(td.up - td.low + 1));
                            id<ORIntVarArray> subMatrix = [ORFactory intVarArray:m2 range:RANGE(m2,0,((tr.up - tr.low + 1)*(td.up - td.low + 1))-1)];
                            ORInt count = 0;
                            for(int i = tr.low; i <= tr.up; i++){
                                for(int j = td.low; j <= td.up; j++){
                                    //[subMatrix set:[li at:i :j] at:i :j];
                                    [subMatrix set:[li at:i :j] at:count++];
                                }
                            }
                            NSLog(@"count = %d",count);
                            */
                            //id<ORIntArray> low = [ORFactory intArray:m2 array:@[0,1]];
                            //id<ORIntArray> up = [ORFactory intArray:m2 array:@(MIN([best intValue:[ports at: m: c]],[best intValue:[Q at: m: conns[c].demandService]]),
                            //                     MIN([best intValue:[ports at: m: c]],[best intValue:[Q at: m: conns[c].demandService]]))];
                            id<ORIntVarArray> temp = [subMatrix flatten];
                            [m2 add: [ORFactory cardinality:temp low:l up:l]];
                            //[m2 add: [ORFactory cardinality:(id<ORIntVarArray>)[subMatrix flatten] low:l up:l]];
                            //[m2 add: [ORFactory cardinality:subMatrix low:l up:u]];


                            //[m2 add: [Sum2(m2, i, tr, j, td, [li at: i : j]) eq: @(MIN([best intValue:[ports at: m: c]],[best intValue:[Q at: m: conns[c].demandService]]))]];
                        }
                        else if([best intValue: [s[c] at:m :n]] > 0){
                            ORInt nELS = [best intValue:[els at:m :c]];
                            ORInt nED = [best intValue: [ed at: n :c]];
                            //NSLog(@"machine = %d | s = %d | NELS = %d | NED = %d", m, [best intValue: [s[c] at:m :n]], nELS, nED);
                            id<ORIntRange> temprrange = RANGE(m2, tr.low, tr.low + nELS - 1);
                            id<ORIntRange> tempdrange = RANGE(m2, td.low, td.low + nED - 1);
                            
                            [m2 add: [Sum2(m2, i, temprrange, j, tempdrange, [li at: i : j]) eq: @([best intValue: [s[c] at:m :n]])]];
                            [m2 add: [Sum2(m2, i, tr, j, td, [li at: i : j]) eq: @([best intValue: [s[c] at:m :n]])]];
                            
                        }
                        else{
                            [m2 add: [Sum2(m2, i, tr, j, td, [li at: i : j]) eq: @(0)]];
                        }
                        
                        for(int i = tr.low; i <= tr.up; i++){
                            [m2 add: [Sum(m2,j, [li range: 1], [li at: i: j]) geq: @(conns[c].LB)]];
                            [m2 add: [Sum(m2,j, [li range: 1], [li at: i: j]) leq: @(conns[c].LB + [best intValue:[extraPorts at:m :c]])]];
                        }
                    }
                }
                
            
                //Each demanding service instance must be connected to only one other service instance.
                for(int i = [li range:1].low; i <= [li range:1].up; i++)
                    [m2 add: [Sum(m2,j,[li range:0],[li at: j: i]) eq: @(1)]];
            }
            
            
            void(^writeOut)(id<ORSolution>,id<ORSolution>,id<ORIntVarMatrix>*,struct Connection*) = ^(id<ORSolution> best_m1, id<ORSolution> best_m2, id<ORIntVarMatrix>* links, struct Connection* conns){
                for(ORInt m = [cnodes low]; m <= [cnodes up]; m++) {
                    //NSLog(@"Node: %i {", c);
                    ORInt i = m;
                    NSLog(@"\tNode: %i (%i services  memory: %d bw:%d) {", i, [best_m1 intValue: [mc at: i]],[best_m1 intValue:[u_mem at:i]],[best_m1 intValue:[u_bw at:i]]);
                    
                    for(ORInt s = Iservice.low; s <= Iservice.up; s++){
                        ORBool isIn = false;
                        for(ORInt c = 0; c < numConn; c++){
                            id<ORIntVarMatrix> li = links[c];
                            id<ORIntRange> tr = [iNodes at: m : conns[c].supplyService];
                            id<ORIntRange> td = [iNodes at: m : conns[c].demandService];
                            
                            if(tr.low > tr.up && td.low > td.up) continue;

                            if(s >= tr.low && s <= tr.up){
                                if(!isIn){
                                    isIn = true;
                                    NSLog(@"\t\tservice: %i  <Type=%d:Mem=%d> {", s, [alpha at: s], [serviceFixMem at:[alpha at: s]]);
                                }
                                for(ORInt k = [li range:1].low; k <= [li range:1].up; k++){
                                    if([best_m2 intValue: [li at: s: k]] == 1){
                                        if(k >= td.low && k <= td.up)
                                            NSLog(@"\t\t\t[service %i <%d>] <==> [service %i <Type:%d,Sec=%d> cnode=]", s, [alpha at: s], k, [alpha at: k], conns[c].security);
                                        else
                                            NSLog(@"\t\t\t[service %i <%d>] <==> [service %i <Type:%d,Sec=%d> cnode=] (*)", s, [alpha at: s], k, [alpha at: k], conns[c].security);

                                    }
                                }
                            }
                            if(s >= td.low && s <= td.up){
                                if(!isIn){
                                    isIn = true;
                                    NSLog(@"\t\tservice: %i  <Type=%d:Mem=%d> {", s, [alpha at: s], [serviceFixMem at:[alpha at: s]]);
                                }
                                for(ORInt k = [li range:0].low; k <= [li range:0].up; k++){
                                    if([best_m2 intValue: [li at: k: s]] == 1){
                                        
                                        if(k >= tr.low && k <= tr.up)
                                            NSLog(@"\t\t\t[service %i <%d>] <==> [service %i <Type:%d,Sec=%d> cnode=]", s, [alpha at: s], k, [alpha at: k], conns[c].security);
                                        else
                                            NSLog(@"\t\t\t[service %i <%d>] <==> [service %i <Type:%d,Sec=%d> cnode=] (*)", s, [alpha at: s], k, [alpha at: k], conns[c].security);
                                        
                                    }
                                }
                            }
                        }
                        if(isIn)
                            NSLog(@"\t\t}");
                    }
                    NSLog(@"\t}");
                    //NSLog(@"}");
                }
                NSLog(@"");
            };
            
            id<ORIntVarArray> iv = [m2 intVars];
            
            id<CPProgram> cp = (id)[ORFactory createCPProgram:m2];
            
            id<ORIntVarMatrix> *p_allLinks = allLinks;
            [cp solve:^{
                //id<ORIntVarArray> iv = [m2 intVars];
                NSLog(@"Enter Search");

                [cp labelArrayFF:iv];

                
                NSLog(@"ivcount = %d", ivcount);
                for(int i = 0; i < ivcount; i++){
                    id<ORIntVarMatrix> t = p_allLinks[i];
                    
                    for(int j = [t range: 0].low; j <= [t range: 0].up; j++){
                        for(int k = [t range: 1].low; k <= [t range: 1].up; k++){
                            //NSLog(@"Link Matrix = %d", i);
                            if([cp intValue:[t at: j: k]] > 0){
                                NSLog(@"(%d,%d)", j, k);
                            }
                        }
                    }
                }
                
            }];
            writeOut(best, [[cp solutionPool]best], p_allLinks, conns);
            NSLog(@"solved... [c=%d,f=%d]",[cp nbChoices],[cp nbFailures]);

            
        }break;
    }
}
