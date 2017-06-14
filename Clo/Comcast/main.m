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
@class XMLReader;
#import "XMLReader.h"
@class Cnode;
#import "Cnode.h"
@class SecurityTech;
#import "SecurityTech.h"
@class Service;
#import "Service.h"

int main(int argc, const char * argv[])
{
    id<ORModel> model = [ORFactory createModel];
    //id<ORAnnotation> notes = [ORFactory annotation];
    
    srand(4);//(unsigned int)time(NULL));
    
    ORInt Ncnodes = 3;
    ORInt Nservices = 4;
    ORInt Nsec = 2;
    ORInt MAX_CONN = 1; //2;
    ORInt VM_MEM = 100; // 120 MB base requirement for VM.
    
    id<ORIntRange> cnodes = RANGE(model,1, Ncnodes);
    id<ORIntRange> services = RANGE(model,1, Nservices);
    id<ORIntRange> sec = RANGE(model,0, Nsec);
    
    id<ORIntArray> D = [ORFactory intArray: model range: services with:^ORInt(ORInt i) { return rand() % 20 + 1; }];
    id<ORIntArray> cnodeMem = [ORFactory intArray: model range: cnodes with:^ORInt(ORInt i) { return rand() % 4*1000 + 4*1000; }]; // Available memory on nodes in range 4 GB - 8 GB.
    id<ORIntArray> serviceFixMem = [ORFactory intArray: model range: services with:^ORInt(ORInt i) { return rand() % 50 + 50; }]; // Applications memory requirements in range 50 MB - 500 GB.
    id<ORIntArray> B = [ORFactory intArray: model range: cnodes with:^ORInt(ORInt i) { return rand() % 1000 + 1; }];
    id<ORIntArray> serviceBw = [ORFactory intArray: model range: services with:^ORInt(ORInt i) { return rand() % 10 + 1; }];
    
    id<ORIntMatrix> C = [ORFactory intMatrix: model range: services : services with:^int(ORInt i, ORInt j) {
        if (i < j) {
            return rand() % MAX_CONN + 1;
        }
        else if (i == j) return 0;
        return -1;
    }];
    // Hack to make C symmetric.
    for(ORInt i = [services low]; i <= [services up]; i++) {
        for(ORInt j = [services low]; j <= [services up]; j++) {
            if([C at: i : j] == -1) [C set: [C at: j : i] at: i : j];
        }
    }
    
    
    ORInt Vmax = 6;//[D sumWith:^ORInt(ORInt value, int idx) { return value; }];
    id<ORIntRange> vm = RANGE(model,1, Vmax);
    id<ORIntArray> Uservice = [ORFactory intArray: model range: services with:^ORInt(ORInt i) { return (ORInt)([D at: i] * 1.3); }];
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
    
    ORInt t[3] = {0,1,2};
    id<ORIntArray> secZone = [ORFactory intArray: model range: sec values: (ORInt*)&t];
    id<ORIntArray> serviceZone = [ORFactory intArray: model range: services with:^ORInt(ORInt i) { return rand() % 3; }];
    
    id<ORIntArray> secFixMem = [ORFactory intArray: model range: sec with:^ORInt(ORInt i) { return rand() % 10; }];
    id<ORIntArray> SecFixBw = [ORFactory intArray: model range: sec with:^ORInt(ORInt i) { return rand() % 10; }];
    
    id<ORIntArray> secScaledMem = [ORFactory intArray: model range: sec with:^ORInt(ORInt i) { return rand() % 5 + 2; }];
    id<ORIntArray> secScaledBw = [ORFactory intArray: model range: sec with:^ORInt(ORInt i) { return rand() % 3 + 1; }];
    
    // Variables
    id<ORIntVarArray> v = [ORFactory intVarArray: model range: vm domain: RANGE(model, 0, Ncnodes)];
    id<ORIntVarArray> vc = [ORFactory intVarArray: model range: vm domain: RANGE(model, 0, [Iservice size])];
    id<ORIntVarMatrix> vm_conn = [ORFactory intVarMatrix: model range: vm : services domain: RANGE(model, 0, [Iservice size] * MAX_CONN)];
    
    id<ORIntVarArray> a = [ORFactory intVarArray: model range: Iservice domain: RANGE(model, 0, Vmax)];
    id<ORIntVarMatrix> conn = [ORFactory intVarMatrix: model range: Iservice : Iservice domain: RANGE(model, 0, MAX_CONN)];
    
    id<ORIntVarArray>  s = [ORFactory intVarArray: model range: RANGE(model, 0, Vmax) domain: sec]; // We really want the range to be 'vm' here, but 0 must be included for elt constraint.
    
    id<ORIntVarArray> u_mem = [ORFactory intVarArray: model range: vm domain: RANGE(model, 0, 189)];
    id<ORIntVarArray> u_bw = [ORFactory intVarArray: model range: vm domain: RANGE(model, 0, 50)];
    
    [model minimize: Sum(model, i, vm, [[u_mem at: i] plus: [u_bw at: i]])];
    //[model minimize: [Sum(model, i, vm, [[u_mem at: i] plus: [u_bw at: i]]) lt: @(300)]];
    
    // Demand Constraints
    for(ORInt j = [services low]; j <= [services up]; j++) {
        [model add: [Sum(model, i, [omega at: j], [[a at: i] gt: @(0)]) geq: @([D at: j])]];
    }
    
    // App Symmetry breaking
    for(ORInt j = [services low]; j <= [services up]; j++) {
        id<ORIntRange> r = [omega at: j];
        for(ORInt i = [r low]; i < [r up]; i++) {
            [model add: [[[a at: i] leq: @(0)] imply: [[a at: i+1] leq: @(0)]]];
        }
    }
    
    // Connection Constraints
    for(ORInt k = [Iservice low]; k <= [Iservice up]; k++) {
        for(ORInt j = [services low]; j <= [services up]; j++) {
            [model add: [[[a at: k] gt: @(0)] eq:
                         [Sum(model, i, [omega at: j], [conn at: k : i]) geq: @([C at: [alpha at: k] : j])]
                         ]];
        }
    }
    
    // Connection symmetry constraints
    for(ORInt k = [Iservice low]; k <= [Iservice up]; k++) {
        for(ORInt k2 = [Iservice low]; k2 <= [Iservice up]; k2++) {
            [model add: [[conn at: k : k2] eq: [conn at: k2 : k]]];
        }
    }
    
    // Count connections on each VM. A connection is not counted if the two services are both within the same VM.
    for(ORInt i = [vm low]; i <= [vm up]; i++) {
        for(ORInt j = [services low]; j <= [services up]; j++) {
            [model add: [[vm_conn at: i : j] eq: Sum2(model, k, [omega at: j], k2, Iservice, [[conn at: k : k2] mul: [[[a at: k] eq: @(i)] land: [[a at: k2] neq: @(i)]] ])] ];
        }
    }
    
    // Constraint counting the number of services running in each VM.
    for(ORInt i = [vm low]; i <= [vm up]; i++) {
        [model add: [[vc at: i] eq: Sum(model, k, Iservice, [[a at: k] eq: @(i)])]];
    }
    
    // Constraint adding VM to node if it is in use.
    for(ORInt i = [vm low]; i <= [vm up]; i++) {
        [model add: [[[vc at: i] gt: @(0)] eq: [[v at: i] gt: @(0)]]];
    }
    
    // VM symmetry breaking
    for(ORInt i = [vm low]; i < [vm up]; i++) {
        [model add: [[[vc at: i] eq: @(0)] imply: [[vc at: i+1] eq: @(0)]]];
    }
    
    // Security Constraints
    for(ORInt k = [Iservice low]; k <= [Iservice up]; k++) {
        [model add: [[[a at: k] gt: @(0)] eq: [[s elt: [a at: k]] geq: @([serviceZone at: [alpha at: k]])] ]];
    }
    
    // Limit total memory usage on each node
    for(ORInt c = [cnodes low]; c <= [cnodes up]; c++) {
        [model add: [Sum(model, i, vm, [[[v at: i] eq: @(c)] mul: [u_mem at: i]]) leq: @([cnodeMem at: c])]];
    }
    
    // Memory usage = Fixed memory for deploying VM + per service memory usage scaled by security technology + fixed cost of sec. technology.
    for(ORInt i = [vm low]; i <= [vm up]; i++) {
        // CP
                [model add: [[u_mem at: i] geq:
                             [[[[vc at: i] gt: @(0)] mul: @(VM_MEM)] plus:
                              [[[Sum(model, k, Iservice, [ [[a at: k] eq: @(i)] mul: @([serviceFixMem at: [alpha at: k]])] ) mul: [secScaledMem elt: [s at: i]] ] div: @(100)] plus:
                              [secFixMem elt: [s at: i]]]
                             ]]];
        // MIP
//        [model add: [[u_mem at: i] geq:
//                     [[[[vc at: i] gt: @(0)] mul: @(VM_MEM)] plus:
//                      [[[Sum(model, k, Iservice, [ [[a at: k] eq: @(i)] mul: @([serviceFixMem at: [alpha at: k]])] ) mul: [secScaledMem elt: [s at: i]] ] mul: @(.01)] plus:
//                       [secFixMem elt: [s at: i]]]
//                      ]]];
        
    }
    
    //    // Bandwidth usage:
    for(ORInt i = [vm low]; i <= [vm up]; i++) {
        [model add: [[u_bw at: i] geq:
                     [[Sum(model, j, services, [[vm_conn at: i : j] mul: @([serviceBw at: j])]) mul: [secScaledBw elt: [s at: i]]] plus:
                      [SecFixBw elt: [s at: i]]
                      ]]];
    }
    
    
    
    // Function to write solution.
    // Print solution
    void(^writeOut)(id<ORSolution>) = ^(id<ORSolution> best){
        for(ORInt c = [cnodes low]; c <= [cnodes up]; c++) {
            NSLog(@"Node: %i {", c);
            for(ORInt i = [vm low]; i <= [vm up]; i++) {
                if([best intValue: [v at: i]] == c) {
                    NSLog(@"\tVM: %i (security: %i, %i services) {", i, [best intValue: [s at: i]], [best intValue: [vc at: i]]);
                    for(ORInt k = [Iservice low]; k <= [Iservice up]; k++) {
                        if([best intValue: [a at: k]] == i) {
                            NSLog(@"\t\t service: %i {", k);
                            for(ORInt k2 = [Iservice low]; k2 <= [Iservice up]; k2++) {
                                ORInt connections = [best intValue: [conn at: k : k2]];
                                if(connections > 0) {
                                    NSLog(@"\t\t\t[service %i] <=> [service %i] (x%i)", k, k2, connections);
                                }
                            }
                            NSLog(@"\t\t}");
                        }
                    }
                    NSLog(@"\t}");
                }
            }
            NSLog(@"}");
        }
    };
    
    
    ORTimeval now = [ORRuntimeMonitor now];
    
//    id<ORModel> lm = [ORFactory linearizeModel: model];
//    id<ORRunnable> r = [ORFactory MIPRunnable: lm];
//    [r start];
//    id<ORSolution> best = [r bestSolution];
//    writeOut(best);
    
//        id<ORRunnable> r = [ORFactory CPRunnable: model willSolve:^CPRunnableSearch(id<CPCommonProgram> cp) {
//            id<CPHeuristic> h = [cp createDDeg];
//            return [^(id<CPCommonProgram> cp) {
//                [cp labelHeuristic: h];
//                id<ORSolution> sol = [cp captureSolution];
//                writeOut(sol);
//                NSLog(@"Found Solution: %i", [[sol objectiveValue] intValue]);
//            } copy];
//        }];
//        [r start];
//        id<ORSolution> best = [r bestSolution];
    
    
        id<CPProgram> cp = [ORFactory createCPProgram: model];
        //NSLog(@"Model %@",model);
        id<CPHeuristic> h = [cp createDDeg];
        [cp solve:^{
            [cp labelHeuristic:h];
            id<ORSolution> s = [cp captureSolution];
            NSLog(@"Found Solution: %f", [[s objectiveValue] doubleValue]);
            writeOut(s);
        }];
        id<ORSolution> best = [[cp solutionPool] best];
    
    //NSLog(@"Number of solutions found: %li", [[cp solutionPool] count]);
    ORTimeval el = [ORRuntimeMonitor elapsedSince:now];
    NSLog(@"#best objective: %i",[[best objectiveValue] intValue]);
    NSLog(@"Total time: %f",el.tv_sec * 1000.0 + (double)el.tv_usec / 1000.0);
    return 0;
}
//    id<ORModel> model = [ORFactory createModel];
//    //id<ORAnnotation> notes = [ORFactory annotation];
//    
//    srand(4);//(unsigned int)time(NULL));
//    
//    ORInt Ncnodes = 3;
//    ORInt Napps = 4;
//    ORInt Nsec = 2;
//    ORInt MAX_CONN = 1; //2;
//    ORInt VM_MEM = 100; // 120 MB base requirement for VM.
//    
//    id<ORIntRange> cnodes = RANGE(model,1, Ncnodes);
//    id<ORIntRange> apps = RANGE(model,1, Napps);
//    id<ORIntRange> sec = RANGE(model,0, Nsec);
//
//    id<ORIntArray> D = [ORFactory intArray: model range: apps with:^ORInt(ORInt i) { return rand() % 20 + 1; }];
//    id<ORIntArray> M = [ORFactory intArray: model range: cnodes with:^ORInt(ORInt i) { return rand() % 4*1000 + 4*1000; }]; // Available memory on nodes in range 4 GB - 8 GB.
//    id<ORIntArray> Mapp = [ORFactory intArray: model range: apps with:^ORInt(ORInt i) { return rand() % 50 + 50; }]; // Applications memory requirements in range 50 MB - 500 GB.
//    id<ORIntArray> B = [ORFactory intArray: model range: cnodes with:^ORInt(ORInt i) { return rand() % 1000 + 1; }];
//    id<ORIntArray> Bapp = [ORFactory intArray: model range: apps with:^ORInt(ORInt i) { return rand() % 10 + 1; }];
//
////    // Get info from XML
////    NSMutableArray * serviceArray;
////    NSMutableArray * secArray;
////    NSMutableArray * cnodeArray;
////    
////    // Create count objects for arrays
////    serviceArray = [[NSMutableArray alloc] init];
////    secArray = [[NSMutableArray alloc] init];
////    cnodeArray = [[NSMutableArray alloc] init];
////    
////    Cnode *thisCnode = [[Cnode alloc] initWithId:0
////                                     cnodeMemory:0
////                                  cnodeBandwidth:0];
////    [cnodeArray addObject:thisCnode];
////    
////    Service *thisService = [[Service alloc] initWithId:0
////                                      serviceFixMemory:0
////                                   serviceScaledMemory:0
////                                   serviceFixBandwidth:0
////                                serviceScaledBandwidth:0
////                                           serviceZone:0
////                                        serviceMaxConn:0];
////    [serviceArray addObject:thisService];
////    
////    SecurityTech *thisSecurityTech = [[SecurityTech alloc] initWithId:0
////                                                       secFixedMemory:0
////                                                    secFixedBandwidth:0
////                                                      secScaledMemory:0
////                                                   secScaledBandwidth:0
////                                                              secZone:0];
////    [secArray addObject:thisSecurityTech];
////    
////    // create and init delegate
////    XMLReader * dataIn = [[XMLReader alloc] initWithArrays: cnodeArray serviceArray: serviceArray secArray: secArray];
////    
////    ORInt Ncnodes = [cnodeArray[0] cnodeExtId];
////    ORInt Nservice = [serviceArray[0] serviceId];
////    ORInt Nsec = [secArray[0] secId];
////    ORInt MAX_CONN = 2;
////    ORInt VM_MEM = 50;
////    
////    // Get ranges from XML
////    id<ORIntRange> cnodes = RANGE(model,1, Ncnodes);    // [0] holds number of nodes
////    id<ORIntRange> service = RANGE(model,1, Nservice);  // [0] holds number of services
////    id<ORIntRange> sec = RANGE(model,1, Nsec);          // [0] holds number of security technologies
////    
////    // Use info from XML instead of random values
////    id<ORIntArray> cnodeMem = [ORFactory intArray: model range: cnodes with:^ORInt(ORInt i) {
////        return [cnodeArray[i] cnodeMemory];
////    } ];
////    id<ORIntArray> cnodeBw = [ORFactory intArray: model range: cnodes with:^ORInt(ORInt i) {
////        return [cnodeArray[i] cnodeBandwidth];
////    } ];
////    id<ORIntArray> serviceFixMem = [ORFactory intArray: model range: service with:^ORInt(ORInt i) {
////        return [serviceArray[i] serviceFixMemory];
////    } ];
////    id<ORDoubleArray> serviceScaledMem = [ORFactory doubleArray: model range: service with:^ORDouble(ORInt i) {
////        return [serviceArray[i] serviceScaledMemory];
////    } ];
////    id<ORIntArray> serviceFixBw = [ORFactory intArray: model range: service with:^ORInt(ORInt i) {
////        return [serviceArray[i] serviceFixBandwidth];
////    } ];
////    id<ORDoubleArray> serviceScaledBw = [ORFactory doubleArray: model range: service with:^ORDouble(ORInt i) {
////        return [serviceArray[i] serviceScaledBandwidth];
////    } ];
////    id<ORIntArray> serviceZone = [ORFactory intArray: model range: service with:^ORInt(ORInt i) {
////        return [serviceArray[i] serviceZone];
////    } ];
////    id<ORIntArray> secFixMem = [ORFactory intArray: model range: sec with:^ORInt(ORInt i) {
////        return [secArray[i] secFixedMemory];
////    } ];
////    id<ORIntArray> secFixBw = [ORFactory intArray: model range: sec with:^ORInt(ORInt i) {
////        return [secArray[i] secFixedBandwidth];
////    } ];
////    id<ORDoubleArray> secScaledMem = [ORFactory doubleArray: model range: sec with:^ORDouble(ORInt i) {
////        return [secArray[i] secScaledMemory];
////    } ];
////    id<ORDoubleArray> secScaledBw = [ORFactory doubleArray: model range: sec with:^ORDouble(ORInt i) {
////        return [secArray[i] secScaledBandwidth];
////    } ];
////    id<ORIntArray> secZone = [ORFactory intArray: model range: sec with:^ORInt(ORInt i) {
////        return [secArray[i] secZone];
////    } ];
////    id<ORIntArray> D = [ORFactory intArray: model range: service with:^ORInt(ORInt i) {
////        return rand() % 8 + 1;
////    }];
//    
//    // Random values
//    //id<ORIntArray> M = [ORFactory intArray: model range: cnodes with:^ORInt(ORInt i) { return rand() % 400 + 1; }];
//    //id<ORIntArray> Mapp = [ORFactory intArray: model range: service with:^ORInt(ORInt i) { return  rand() % 28 + 1; }]; //{ return service.[i].serviceId; }];
//    //id<ORIntArray> B = [ORFactory intArray: model range: cnodes with:^ORInt(ORInt i) { return rand() % 1000 + 1; }];
//    //id<ORIntArray> Bapp = [ORFactory intArray: model range: service with:^ORInt(ORInt i) { return rand() % 10 + 1; }];
//    
//    id<ORIntMatrix> C = [ORFactory intMatrix: model range: service : service with:^int(ORInt i, ORInt j) {
//        if (i < j) {
//            return rand() % MAX_CONN + 1;
//        }
//        else if (i == j) return 0;
//        return -1;
//    }];
//    // Hack to make C symmetric.
//    for(ORInt i = [service low]; i <= [service up]; i++) {
//        for(ORInt j = [service low]; j <= [service up]; j++) {
//            if([C at: i : j] == -1) [C set: [C at: j : i] at: i : j];
//        }
//    }
// 
//    
//<<<<<<< HEAD
//    ORInt Vmax = 6;//[D sumWith:^ORInt(ORInt value, int idx) { return value; }];
//=======
//    ORInt Vmax = 3;// [D sumWith:^ORInt(ORInt value, int idx) { return value; }];
//>>>>>>> 83462e340296f8ea13c43313906c3e223580a16b
//    id<ORIntRange> vm = RANGE(model,1, Vmax);
//    id<ORIntArray> Uapp = [ORFactory intArray: model range: service with:^ORInt(ORInt i) { return (ORInt)([D at: i] * 1.3); }];
//    id<ORIntRange> Iapp = RANGE(model,0, [Uapp sumWith:^ORInt(ORInt value, int idx) { return value; }]-1);
//    id<ORIdArray> omega = [ORFactory idArray: model range: service with:^id _Nonnull(ORInt a) {
//        ORInt offset = [Uapp sumWith:^ORInt(ORInt value, int idx) { return idx < a ? value : 0; }];
//        return RANGE(model, offset, offset + [Uapp at: a] - 1);
//    }];
//    id<ORIntArray> alpha = [ORFactory intArray: model range: Iapp with:^ORInt(ORInt a) {
//        for(ORInt i = [omega low]; i <= [omega up]; i++) {
//            id<ORIntRange> r = [omega at: i];
//            if([r inRange: a]) return i;
//        }
//        return -1;
//    }];
//    
//    ORInt t[3] = {0,1,2}; // zones
//     
//    
//    // Replace T with secZone
//    //id<ORIntArray> T = [ORFactory intArray: model range: sec values: (ORInt*)&t];
//    
//    // Replace Tapp with serviceZone
//    //id<ORIntArray> Tapp = [ORFactory intArray: model range: service with:^ORInt(ORInt i) { return rand() % 3; }];
//    
//    // Replace Fmem with secFixMem and SecFixBw with SecFixBw
//    //id<ORIntArray> Fmem = [ORFactory intArray: model range: sec with:^ORInt(ORInt i) { return rand() % 10; }];
//    //id<ORIntArray> Fbw = [ORFactory intArray: model range: sec with:^ORInt(ORInt i) { return rand() % 10; }];
//    
//    
//    // Replace Smem with secScaledMem and Sbw with secScaledBw
//    //id<ORDoubleArray> Smem = [ORFactory doubleArray: model range: sec with:^ORDouble(ORInt i) { return rand() % 3 + 1; }];
//    //id<ORDoubleArray> Sbw = [ORFactory doubleArray: model range: sec with:^ORDouble(ORInt i) { return rand() % 3 + 1; }];
//    
//<<<<<<< HEAD
//    id<ORIntArray> Smem = [ORFactory intArray: model range: sec with:^ORInt(ORInt i) { return rand() % 5 + 2; }];
//    id<ORIntArray> Sbw = [ORFactory intArray: model range: sec with:^ORInt(ORInt i) { return rand() % 3 + 1; }];
//
//=======
//>>>>>>> 83462e340296f8ea13c43313906c3e223580a16b
//    // Variables
//    id<ORIntVarArray> v = [ORFactory intVarArray: model range: vm domain: RANGE(model, 0, Ncnodes)];
//    id<ORIntVarArray> vc = [ORFactory intVarArray: model range: vm domain: RANGE(model, 0, [Iapp size])];
//    id<ORIntVarMatrix> vm_conn = [ORFactory intVarMatrix: model range: vm : service domain: RANGE(model, 0, [Iapp size] * MAX_CONN)];
//    
//    id<ORIntVarArray> a = [ORFactory intVarArray: model range: Iapp domain: RANGE(model, 0, Vmax)];
//    id<ORIntVarMatrix> conn = [ORFactory intVarMatrix: model range: Iapp : Iapp domain: RANGE(model, 0, MAX_CONN)];
//    
//    id<ORIntVarArray>  s = [ORFactory intVarArray: model range: RANGE(model, 0, Vmax) domain: sec]; // We really want the range to be 'vm' here, but 0 must be included for elt constraint.
//    
//    id<ORIntVarArray> u_mem = [ORFactory intVarArray: model range: vm domain: RANGE(model, 0, 189)];
//    id<ORIntVarArray> u_bw = [ORFactory intVarArray: model range: vm domain: RANGE(model, 0, 50)];
//    
//    [model minimize: Sum(model, i, vm, [[u_mem at: i] plus: [u_bw at: i]])];
//    
//    // Demand Constraints
//    for(ORInt j = [service low]; j <= [service up]; j++) {
//        [model add: [Sum(model, i, [omega at: j], [[a at: i] gt: @(0)]) geq: @([D at: j])]];
//    }
//    
//    // App Symmetry breaking
//    for(ORInt j = [service low]; j <= [service up]; j++) {
//        id<ORIntRange> r = [omega at: j];
//        for(ORInt i = [r low]; i < [r up]; i++) {
//            [model add: [[[a at: i] leq: @(0)] imply: [[a at: i+1] leq: @(0)]]];
//        }
//    }
//    
//    // Connection Constraints - replace apps with service
//    for(ORInt k = [Iapp low]; k <= [Iapp up]; k++) {
//        for(ORInt j = [service low]; j <= [service up]; j++) {
//            [model add: [[[a at: k] gt: @(0)] eq:
//                         [Sum(model, i, [omega at: j], [conn at: k : i]) geq: @([C at: [alpha at: k] : j])]
//                         ]];
//        }
//    }
//    
//    // Connection symmetry constraints
//    for(ORInt k = [Iapp low]; k <= [Iapp up]; k++) {
//        for(ORInt k2 = [Iapp low]; k2 <= [Iapp up]; k2++) {
//            [model add: [[conn at: k : k2] eq: [conn at: k2 : k]]];
//        }
//    }
//    
//    // Count connections on each VM. A connection is not counted if the two apps are both within the same VM.
//    for(ORInt i = [vm low]; i <= [vm up]; i++) {
//        for(ORInt j = [service low]; j <= [service up]; j++) {
//            [model add: [[vm_conn at: i : j] eq: Sum2(model, k, [omega at: j], k2, Iapp, [[conn at: k : k2] mul: [[[a at: k] eq: @(i)] land: [[a at: k2] neq: @(i)]] ])] ];
//        }
//    }
//    
//    // Constraint counting the number of apps running in each VM.
//    for(ORInt i = [vm low]; i <= [vm up]; i++) {
//        [model add: [[vc at: i] eq: Sum(model, k, Iapp, [[a at: k] eq: @(i)])]];
//    }
//    
//    // Constraint adding VM to node if it is in use.
//    for(ORInt i = [vm low]; i <= [vm up]; i++) {
//        [model add: [[[vc at: i] gt: @(0)] eq: [[v at: i] gt: @(0)]]];
//    }
//    
//    // VM symmetry breaking
//    for(ORInt i = [vm low]; i < [vm up]; i++) {
//        [model add: [[[vc at: i] eq: @(0)] imply: [[vc at: i+1] eq: @(0)]]];
//    }
//    
//    // Security Constraints
//    // ====== Replace Tapp with serviceZone
//    for(ORInt k = [Iapp low]; k <= [Iapp up]; k++) {
//        [model add: [[[a at: k] gt: @(0)] eq: [[s elt: [a at: k]] geq: @([serviceZone at: [alpha at: k]])] ]];
//    }
//    
//    // Limit total memory usage on each node
//    // ===== Replace M with cnodeMem =====
//    for(ORInt c = [cnodes low]; c <= [cnodes up]; c++) {
//        [model add: [Sum(model, i, vm, [[[v at: i] eq: @(c)] mul: [u_mem at: i]]) leq: @([cnodeMem at: c])]];
//    }
//
//    // Memory usage = Fixed memory for deploying VM + per app memory usage scaled by security technology + fixed cost of sec. technology.
//    // ===== Replace Mapp with serviceFixMem ======
//    // ===== Replace Smem with serviceScaledMem =====
//    for(ORInt i = [vm low]; i <= [vm up]; i++) {
//        // CP
////        [model add: [[u_mem at: i] geq:
////                     [[[[vc at: i] gt: @(0)] mul: @(VM_MEM)] plus:
////                      [[[Sum(model, k, Iapp, [ [[a at: k] eq: @(i)] mul: @([Mapp at: [alpha at: k]])] ) mul: [Smem elt: [s at: i]] ] div: @(100)] plus:
////                      [Fmem elt: [s at: i]]]
////                     ]]];
//        // MIP
//        [model add: [[u_mem at: i] geq:
//                     [[[[vc at: i] gt: @(0)] mul: @(VM_MEM)] plus:
//<<<<<<< HEAD
//                      [[[Sum(model, k, Iapp, [ [[a at: k] eq: @(i)] mul: @([Mapp at: [alpha at: k]])] ) mul: [Smem elt: [s at: i]] ] mul: @(.01)] plus:
//                       [Fmem elt: [s at: i]]]
//                      ]]];
//        
//        // MIP with Term moved
////        [model add: [[u_mem at: i] geq:
////                     [[[[vc at: i] gt: @(0)] mul: @(VM_MEM)] plus:
////                      [[Sum(model, k, Iapp, [ [[a at: k] eq: @(i)] mul: [[Smem elt: [s at: i]] mul: @([Mapp at: [alpha at: k]])]] ) mul: @(.01)] plus:
////                       [Fmem elt: [s at: i]]]
////                      ]]];
//
//    }
//    
////    // Bandwidth usage:
////    for(ORInt i = [vm low]; i <= [vm up]; i++) {
////        [model add: [[u_bw at: i] geq:
////                     [[Sum(model, j, apps, [[vm_conn at: i : j] mul: @([Bapp at: j])]) mul: [Sbw elt: [s at: i]]] plus:
////                      [Fbw elt: [s at: i]]
////                     ]]];
////    }
//=======
//                      [[Sum(model, k, Iapp, [ [[a at: k] eq: @(i)] mul: @([serviceFixMem at: [alpha at: k]])] ) mul: [serviceScaledMem elt: [s at: i]] ] plus:
//                      [secFixMem elt: [s at: i]]]
//                     ]]];
//    }
//    
//    // Bandwidth usage:
//    // ===== replace Bapp with serviceBw =====
//    // ===== replace Sbw with secScaledBw =====
//    for(ORInt i = [vm low]; i <= [vm up]; i++) {
//        [model add: [[u_bw at: i] geq:
//                     [[Sum(model, j, service, [[vm_conn at: i : j] mul: @([serviceFixBw at: j])]) mul: [secScaledBw elt: [s at: i]]] plus:
//                      [secFixBw elt: [s at: i]]
//                     ]]];
//    }
//>>>>>>> 83462e340296f8ea13c43313906c3e223580a16b
//
//    // Function to write solution.
//    // Print solution
//    void(^writeOut)(id<ORSolution>) = ^(id<ORSolution> best){
//        for(ORInt c = [cnodes low]; c <= [cnodes up]; c++) {
//            NSLog(@"Node: %i {", c);
//            for(ORInt i = [vm low]; i <= [vm up]; i++) {
//                if([best intValue: [v at: i]] == c) {
//                    NSLog(@"\tVM: %i (security: %i, %i services) {", i, [best intValue: [s at: i]], [best intValue: [vc at: i]]);
//                    for(ORInt k = [Iapp low]; k <= [Iapp up]; k++) {
//                        if([best intValue: [a at: k]] == i) {
//                            NSLog(@"\t\t app: %i {", k);
//                            for(ORInt k2 = [Iapp low]; k2 <= [Iapp up]; k2++) {
//                                ORInt connections = [best intValue: [conn at: k : k2]];
//                                if(connections > 0) {
//                                    NSLog(@"\t\t\t[service %i] <=> [service %i] (x%i)", k, k2, connections);
//                                }
//                            }
//                            NSLog(@"\t\t}");
//                        }
//                    }
//                    NSLog(@"\t}");
//                }
//            }
//            NSLog(@"}");
//        }
//    };
//
//    
//    ORTimeval now = [ORRuntimeMonitor now];
//    
//    id<ORModel> lm = [ORFactory linearizeModel: model];
//    id<ORRunnable> r = [ORFactory MIPRunnable: lm];
//    [r start];
//    id<ORSolution> best = [r bestSolution];
//    writeOut(best);
//
////    id<ORRunnable> r = [ORFactory CPRunnable: model willSolve:^CPRunnableSearch(id<CPCommonProgram> cp) {
////        id<CPHeuristic> h = [cp createDDeg];
////        return [^(id<CPCommonProgram> cp) {
////            [cp labelHeuristic: h];
////            id<ORSolution> sol = [cp captureSolution];
////            writeOut(sol);
////            NSLog(@"Found Solution: %i", [[sol objectiveValue] intValue]);
////        } copy];
////    }];
////    [r start];
////    id<ORSolution> best = [r bestSolution];
//    
//    
////    id<CPProgram> cp = [ORFactory createCPProgram: model];
////    //NSLog(@"Model %@",model);
////    id<CPHeuristic> h = [cp createDDeg];
////    [cp solve:^{
////        [cp labelHeuristic:h];
////        id<ORSolution> s = [cp captureSolution];
////        NSLog(@"Found Solution: %f", [[s objectiveValue] doubleValue]);
////        writeOut(s);
////    }];
////    id<ORSolution> best = [[cp solutionPool] best];
//
//    //NSLog(@"Number of solutions found: %li", [[cp solutionPool] count]);
//   ORTimeval el = [ORRuntimeMonitor elapsedSince:now];
//    NSLog(@"#best objective: %i",[[best objectiveValue] intValue]);
//   NSLog(@"Total time: %f",el.tv_sec * 1000.0 + (double)el.tv_usec / 1000.0);
//    
//    return 0;


