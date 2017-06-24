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
#import "XMLReader.h"
#import "Cnode.h"
#import "SecurityTech.h"
#import "Service.h"


int main(int argc, const char * argv[])
{
    id<ORModel> model = [ORFactory createModel];
    //id<ORAnnotation> notes = [ORFactory annotation];
    NSMutableArray * serviceArray;
    NSMutableArray * secArray;
    NSMutableArray * cnodeArray;
    
    // Create count objects for arrays
    serviceArray = [[NSMutableArray alloc] init];
    secArray = [[NSMutableArray alloc] init];
    cnodeArray = [[NSMutableArray alloc] init];
        
    // create and init delegate
    XMLReader * dataIn = [[XMLReader alloc] initWithArrays: cnodeArray serviceArray: serviceArray secArray: secArray];
    NSString* path = [[NSBundle mainBundle] pathForResource: @"model" ofType: @"xml"];
    [dataIn parseXMLFile: path];
    
    ORInt Ncnodes = (ORInt)[cnodeArray count];
    ORInt Nservices = (ORInt)[serviceArray count];
    ORInt Nsec = (ORInt)[secArray count]-1;   //2  (in data file this is 3)
   ORInt MAX_CONN = 1;//2;   // 1    // must be read from data file  (inside serviceArray?)
   ORInt VM_MEM = 100;//50;    // 100  // must be read from data file
    
    id<ORIntRange> cnodes = RANGE(model,1, Ncnodes);
    id<ORIntRange> services = RANGE(model,1, Nservices);
    id<ORIntRange> sec = RANGE(model,0, Nsec);
    
    // Use info from XML instead of random values
    id<ORIntArray> cnodeMem = [ORFactory intArray: model range: cnodes with:^ORInt(ORInt i) {
        return [cnodeArray[i-1] cnodeMemory];
    } ];
    id<ORIntArray> cnodeBw = [ORFactory intArray: model range: cnodes with:^ORInt(ORInt i) {
        return [cnodeArray[i-1] cnodeBandwidth];
    } ];
    id<ORIntArray> serviceFixMem = [ORFactory intArray: model range: services with:^ORInt(ORInt i) {
        return [serviceArray[i-1] serviceFixMemory];
    } ];
    id<ORIntArray> serviceScaledMem = [ORFactory intArray: model range: services with:^ORInt(ORInt i) {
        return (ORInt)[serviceArray[i-1] serviceScaledMemory];
    } ];
    id<ORIntArray> serviceFixBw = [ORFactory intArray: model range: services with:^ORInt(ORInt i) {
        return [serviceArray[i-1] serviceFixBandwidth];
    } ];
    id<ORIntArray> serviceScaledBw = [ORFactory intArray: model range: services with:^ORInt(ORInt i) {
        return [serviceArray[i-1] serviceScaledBandwidth];
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
    id<ORIntArray> secScaledMem = [ORFactory intArray: model range: sec with:^ORInt(ORInt i) {
        return [secArray[i] secScaledMemory];
    } ];
    id<ORIntArray> secScaledBw = [ORFactory intArray: model range: sec with:^ORInt(ORInt i) {
        return [secArray[i] secScaledBandwidth];
    } ];
    id<ORIntArray> secZone = [ORFactory intArray: model range: sec with:^ORInt(ORInt i) {
        return [secArray[i] secZone];
    } ];
   NSDictionary* Ddict = dataIn.D;
    id<ORIntArray> D = [ORFactory intArray: model range: services with:^ORInt(ORInt i) {
       return [[Ddict objectForKey:@(i)] intValue];
    }];

    
   NSArray* Cmatrix = dataIn.C;
    id<ORIntMatrix> C = [ORFactory intMatrix: model range: services : services with:^int(ORInt i, ORInt j) {
       return [[[Cmatrix objectAtIndex:i - 1] objectAtIndex:j - 1] intValue];  // matrix in XML file is 0-based
    }];
   
    
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
    
//    // Memory usage = Fixed memory for deploying VM + per service memory usage scaled by security technology + fixed cost of sec. technology.
    for(ORInt i = [vm low]; i <= [vm up]; i++) {
        // CP
       [model add: [[[u_mem at: i] mul: @(100)] geq:
                             [[[[vc at: i] gt: @(0)] mul: @(VM_MEM * 100)] plus:
                              [[Sum(model, k, Iservice, [ [[a at: k] eq: @(i)] mul: @([serviceFixMem at: [alpha at: k]])] ) mul: [secScaledMem elt: [s at: i]] ] plus:
                               [[secFixMem elt: [s at: i]] mul: @(100)]]
                             ]]];
//       [model add: [[u_mem at: i] geq:
//                    [[[[vc at: i] gt: @(0)] mul: @(VM_MEM)] plus:
//                     [[[Sum(model, k, Iservice, [ [[a at: k] eq: @(i)] mul: @([serviceFixMem at: [alpha at: k]])] ) mul: [secScaledMem elt: [s at: i]] ] div: @(100)] plus:
//                      [secFixMem elt: [s at: i]]]
//                     ]]];
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
                     [[Sum(model, j, services, [[vm_conn at: i : j] mul: @([serviceFixBw at: j])]) mul: [secScaledBw elt: [s at: i]]] plus:
                      [secFixBw elt: [s at: i]]
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
   
        id<ORRunnable> r = [ORFactory CPRunnable: model willSolve:^CPRunnableSearch(id<CPCommonProgram> cp) {
            id<CPHeuristic> h = [cp createDDeg];
            return [^(id<CPCommonProgram> cp) {
                [cp labelHeuristic: h];
                id<ORSolution> sol = [cp captureSolution];
                writeOut(sol);
                NSLog(@"Found Solution: %i", [[sol objectiveValue] intValue]);
            } copy];
        }];
        [r start];
        id<ORSolution> best = [r bestSolution];
   
    
//        id<CPProgram> cp = [ORFactory createCPProgram: model];
//        //NSLog(@"Model %@",model);
//        id<CPHeuristic> h = [cp createDDeg];
//        [cp solve:^{
//            [cp labelHeuristic:h];
//            id<ORSolution> s = [cp captureSolution];
//            NSLog(@"Found Solution: %f", [[s objectiveValue] doubleValue]);
//            writeOut(s);
//        }];
//        id<ORSolution> best = [[cp solutionPool] best];
   
    //NSLog(@"Number of solutions found: %li", [[cp solutionPool] count]);
    ORTimeval el = [ORRuntimeMonitor elapsedSince:now];
    NSLog(@"#best objective: %i",[[best objectiveValue] intValue]);
    NSLog(@"Total time: %f",el.tv_sec * 1000.0 + (double)el.tv_usec / 1000.0);
    return 0;
}



