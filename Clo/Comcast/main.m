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

int links_i[100][100];
id<ORIntVar> links_v[100][100];

int linkCount[100];

ORInt GlobalMin = 2000000;
//ORInt GlobalMin = 2230;

enum Mode {
    MIP,CP,Hybrid,LNS,Expe,Waldy
};

id<ORIntVarMatrix> transpose(id<ORIntVarMatrix> m)
{
    id<ORIntRange> row = [m range:0];
    id<ORIntRange> col = [m range:1];
    id<ORIntVarMatrix> t = [ORFactory intVarMatrix: m.tracker range:col :row];
    for(ORInt i=row.low;i <= row.up;i++)
        for(ORInt j=col.low;j<=col.up;j++)
            [t set:[m at:i :j] at:j :i];
    return t;
}

int main(int argc, const char * argv[])
{
    enum Mode mode;
    ORInt tLim = 0;
    if (strncmp(argv[2],"MIP",3)==0)
        mode = MIP;
    else if (strncmp(argv[2],"CP",2) == 0)
        mode = CP;
    else if (strncmp(argv[2],"LNS",2) == 0)
        mode = LNS;
    else if (strncmp(argv[2],"Hybrid",6)==0)
        mode = Hybrid;
    else if (strncmp(argv[2],"Waldy",6)==0)
        mode = Waldy;
    else mode= Expe;
    BOOL printSol = NO;
    if (argc >= 4) {
        int ak = 3;
        while (ak < argc) {
            if (strncmp(argv[ak],"-print",6)==0)
                printSol = YES;
            else if (strncmp(argv[ak],"-time",5)==0)
                tLim = atoi(argv[ak]+5);
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
    
    ORInt Ncnodes = (ORInt)[cnodeArray count];
    ORInt Nservices = (ORInt)[serviceArray count];
    ORInt Nsec = (ORInt)[secArray count]-1;
    ORInt MAX_CONN = dataIn.maxCONN;
    ORInt VM_MEM = dataIn.vmMEM;
    ORInt maxPerVM = dataIn.maxPerVM;
    ORInt maxVMs = dataIn.maxVMs;
    
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
    //   id<ORIntArray> serviceScaledMem = [ORFactory intArray: model range: services with:^ORInt(ORInt i) {
    //      return (ORInt)[serviceArray[i-1] serviceScaledMemory];
    //   } ];
    id<ORIntArray> serviceFixBw = [ORFactory intArray: model range: services with:^ORInt(ORInt i) {
        return [serviceArray[i-1] serviceFixBandwidth];
    } ];
    //   id<ORIntArray> serviceScaledBw = [ORFactory intArray: model range: services with:^ORInt(ORInt i) {
    //      return [serviceArray[i-1] serviceScaledBandwidth];
    //   } ];
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
    //   id<ORIntArray> secZone = [ORFactory intArray: model range: sec with:^ORInt(ORInt i) {
    //      return [secArray[i] secZone];
    //   } ];
    NSDictionary* Ddict = dataIn.D;
    id<ORIntArray> D = [ORFactory intArray: model range: services with:^ORInt(ORInt i) {
        return [[Ddict objectForKey:@(i)] intValue];
    }];
    
    
    NSArray* Cmatrix = dataIn.C;
    id<ORIntMatrix> C = [ORFactory intMatrix: model range: services : services with:^int(ORInt i, ORInt j) {
        return [[[Cmatrix objectAtIndex:i - 1] objectAtIndex:j - 1] intValue];  // matrix in XML file is 0-based
    }];
    
    
    
    //id<ORIntRange> vm = RANGE(model,1, maxVMs);
    //   id<ORIntArray> Uservice = [ORFactory intArray: model range: services with:^ORInt(ORInt i) { return (ORInt)([D at: i] * 1.3); }];
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
    
    NSMutableDictionary* links  = [[NSMutableDictionary alloc] init];
    NSMutableDictionary* serLnk = [[NSMutableDictionary alloc] init];
    for(ORInt i = services.low; i <= services.up;i++)
        serLnk[@(i)] = [[NSMutableSet alloc] init];
    for(ORInt i = services.low; i <= services.up;i++) {
        for(ORInt j=i+1; j <= services.up;j++) {
            if ([C at:i :j] > 0) {
                NSArray* key = @[@(i),@(j)];
                //ORInt d1 = [D at:i], d2 = [D at:j];
                id<ORIntVarMatrix> mtx = [ORFactory intVarMatrix:model range:[omega at:i] :[omega at:j] domain:RANGE(model,0,MAX_CONN)];
                links[key] = mtx;
                NSMutableSet* ms1 = serLnk[@(i)];
                NSMutableSet* ms2 = serLnk[@(j)];
                [ms1 addObject:mtx];
                [ms2 addObject:transpose(mtx)];
            }
        }
    }
    
    // Variables
    //id<ORIntVarArray> v = [ORFactory intVarArray: model range: vm domain: RANGE(model, 0, Ncnodes)];
    id<ORIntVarArray> mc = [ORFactory intVarArray: model range: cnodes domain: RANGE(model, 0, maxPerVM*10)];
    id<ORIntVarMatrix> mc_conn = [ORFactory intVarMatrix: model range: cnodes : services domain: RANGE(model, 0, maxPerVM * 10 * MAX_CONN)];
    
    id<ORIntVarArray> a = [ORFactory intVarArray: model range: Iservice domain: RANGE(model, 1, Ncnodes)];
    //   id<ORIntVarMatrix> conn = [ORFactory intVarMatrix: model range: Iservice : Iservice domain: RANGE(model, 0, MAX_CONN)];
    id<ORIntVarMatrix> chanSec = [ORFactory intVarMatrix: model range: Iservice : Iservice domain: sec];
    id<ORIntVarArray> nbConn = [ORFactory intVarArray:model range:Iservice domain:RANGE(model,1,Iservice.size)];
    
    id<ORIntVarArray>  s = [ORFactory intVarArray: model range: RANGE(model, 0, Iservice.up) domain: sec]; // We really want the range to be 'vm' here, but 0 must be included for elt constraint.
    id<ORIntVarArray>  sSec = [ORFactory intVarArray: model range: Iservice  domain: sec]; // We really want the range to be 'vm' here, but 0 must be included for elt constraint.
    //NEW VARIABLES
    //id<ORIntVarArray>  sSecImpl = [ORFactory intVarArray: model range: Iservice  domain: sec]; // We really want the range to be 'vm' here, but 0 must be included for elt constraint.

    
    
    id<ORIntVarArray> u_mem = [ORFactory intVarArray: model range: cnodes domain: RANGE(model, 0, 100000)];
    id<ORIntVarArray> u_bw = [ORFactory intVarArray: model range: cnodes domain: RANGE(model, 0, 200)];
    id<ORIntVarMatrix> secAdapter = [ORFactory intVarMatrix:model range:Iservice :sec domain:RANGE(model,0,1)];

    //id<ORIntVarArray> sConnOut = [ORFactory intVarArray: model range: Iservice domain: RANGE(model, 0, Iservice.size)];
    //id<ORIntVarArray> sConnIn = [ORFactory intVarArray: model range: Iservice domain: RANGE(model, 0, Iservice.size)];
    
    id<ORExpr> sumConn = nil;
    for(NSArray* lnk in links) {
        id<ORIntVarMatrix> lc = links[lnk];
        id<ORIntRange> r = [lc range:0];
        id<ORIntRange> c = [lc range:1];
        id<ORExpr> term = Sum2(model, i, r, j, c, [lc at:i :j]);
        if (sumConn == nil)
            sumConn = term;
        else sumConn = [sumConn plus: term];
    }
    [model minimize: [[Sum(model, i, cnodes, [u_mem[i] plus: u_bw[i]])  plus: Sum(model,i,Iservice, nbConn[i]) ] plus: sumConn]];
    //[model minimize: [Sum(model, i, vm, [[u_mem at: i] plus: [u_bw at: i]]) lt: @(300)]];
    
    // Demand Constraints
    //   for(ORInt j = [services low]; j <= [services up]; j++) {
    //      [model add: [Sum(model, i, [omega at: j], [a[i] gt: @(0)]) geq: @([D at: j])]];
    //   }
    
    // App Symmetry breaking
    //   for(ORInt j = [services low]; j <= [services up]; j++) {
    //      id<ORIntRange> r = [omega at: j];
    //      for(ORInt i = [r low]; i < [r up]; i++) {
    //         [model add: [[[a at: i] leq: @(0)] imply: [[a at: i+1] leq: @(0)]]];
    //      }
    //   }
    
    ORInt numLinks = 0;
    for(NSArray* lnk in links) {
        ORInt t1 = (ORInt)[lnk[0] integerValue],t2 = (ORInt)[lnk[1] integerValue];
        id<ORIntVarMatrix> lc = links[lnk];
        id<ORIntRange> r = [lc range:0];
        id<ORIntRange> c = [lc range:1];
        for(ORInt s = r.low;s <= r.up;s++) {
            [model add:[Sum(model, k, c, [lc at:s :k]) geq: @([C at:t1 :t2])]];
            [model add:[Sum(model, k, c, [lc at:s :k]) leq: @([D at:t2])]];
            if (r.size <= c.size) {
                ORInt lb = c.size / r.size;
                ORInt md = c.size % r.size;
                ORInt ub = lb + md;
                [model add:[Sum(model, k, c, [lc at:s :k]) geq: @(lb)]];
                [model add:[Sum(model, k, c, [lc at:s :k]) leq: @(ub)]];
            }
            numLinks += (c.up - c.low) + 1;
        }
        for(ORInt k = c.low;k <= c.up; k++) {
            [model add:[Sum(model, j, r, [lc at:j :k]) geq: @([C at:t2 :t1])]];  // C is symmetric anyhow
            [model add:[Sum(model, j, r, [lc at:j :k]) leq: @([D at:t1])]];
            if (c.size <= r.size) {
                ORInt lb = r.size / c.size;
                ORInt md = r.size % c.size;
                ORInt ub = lb + md;
                [model add:[Sum(model, j, r, [lc at:j :k]) geq: @(lb)]];
                [model add:[Sum(model, j, r, [lc at:j :k]) leq: @(ub)]];
            }
        }
        ORInt toServe = max([D at:t1],[D at:t2]) * [C at:t1 :t2];
        [model add:[Sum2(model, i, r, j, c, [lc at:i :j]) eq: @(toServe)]];
    }
    
    
    // Connection Constraints
    //   for(ORInt k = [Iservice low]; k <= [Iservice up]; k++) {
    //      for(ORInt j = [services low]; j <= [services up]; j++) {
    //         [model add: [Sum(model, i, [omega at: j], [conn at: k : i]) geq: @([C at: [alpha at: k] : j])]];
    //      }
    //   }
    
    // Connection symmetry constraints
    //   for(ORInt k = [Iservice low]; k <= [Iservice up]; k++) {
    //      for(ORInt k2 = [Iservice low]; k2 <= [Iservice up]; k2++) {
    //         [model add: [[conn at: k : k2] eq: [conn at: k2 : k]]];
    //      }
    //   }
    
    // Define a matrix of booleans indicating whether two services are on the same VM (or not).
    id<ORIntVarMatrix> same = [ORFactory intVarMatrix:model range:Iservice :Iservice bounds:RANGE(model,0,1)];
    for(ORInt k1 = [Iservice low]; k1 <= [Iservice up]; k1++) {
        for(ORInt k2 = [Iservice low]; k2 <= [Iservice up]; k2++) {
            if (k2 == k1)
                [model add: [[same at:k1 :k2] eq: @(1)]];
            else {
                id<ORIntVarArray> bvm = [ORFactory intVarArray:model range:cnodes domain:RANGE(model,0,1)];
                for(ORInt v = cnodes.low; v <= cnodes.up; v++) {
                    [model add: [bvm[v] eq: [[a[k1] eq: @(v)] land: [a[k2] eq:@(v)]]]];
                }
                //[model add:[[same at:k1 :k2] leq: Or(model, v, vm, bvm[v])]];
                [model add:[[same at:k1 :k2] leq: Sum(model, v, cnodes, bvm[v])]];
                for(ORInt i = cnodes.low;i <= cnodes.up;i++)
                    [model add: [bvm[i]  leq: [same at:k1 :k2]]];
                //[model add: [[a[k1] eq: a[k2]] eq: [same at:k1 :k2]]];
            }
        }
    }
    
    for(ORInt k1 = [Iservice low]; k1 <= [Iservice up]; k1++) {
        [model add: [sSec[k1] eq: @([serviceZone at:[alpha at:k1]])]];
    }
    id<ORIntVarMatrix> maxSec = [ORFactory intVarMatrix:model range:Iservice :Iservice bounds:sec];
    for(ORInt k1 = [Iservice low]; k1 <= [Iservice up]; k1++) {
        for(ORInt k2 = [Iservice low]; k2 <= [Iservice up]; k2++) {
            if (k2 == k1) continue;
            [model add:[[maxSec at:k1 :k2] eq: [sSec[k1] max: sSec[k2]]]];
            [model add:[[chanSec at:k1 :k2] eq: [[[same at:k1 :k2] neg] mul: [maxSec at:k1 :k2]]]];
            [model add:[s[k1] geq: [chanSec at: k1 : k2]]];
            for(int s = sec.low; s <= sec.up; s++)
                [model add: [[secAdapter at:k1 :s] geq: [[chanSec at:k1 :k2] eq: @(s)]]];
        }
    }
    
    // Count connections on each VM. A connection is not counted if the two services are both within the same VM.
    for(ORInt i = [cnodes low]; i <= [cnodes up]; i++) {
        for(ORInt j = services.low; j <= services.up; j++) {
            //         [model add: [[vm_conn at: i : j] eq: Sum2(model, k, [omega at: j], k2, Iservice, [[conn at: k : k2] mul: [[a[k] eq: @(i)] land: [a[k2] neq: @(i)]] ])] ];
            //         [model add: [[vm_conn at: i : j] eq: Sum2(model, k, [omega at: j], k2, Iservice, [[conn at: k : k2] mul: [[[same at:k :k2] neg] land: [a[k] eq:@(i)]]] )] ];
            id<ORExpr> ce = nil;
            for(NSArray* lnk in links) {
                ORInt t1 = (ORInt)[lnk[0] integerValue],t2 = (ORInt)[lnk[1] integerValue];
                if (t1 != j && t2 != j) continue;
                id<ORIntVarMatrix> lc = links[lnk];
                id<ORIntRange> r = [lc range:0];
                id<ORIntRange> c = [lc range:1];
                if (j == t1) {
                    id<ORExpr> term = Sum2(model, k1, r, k2, c,[[lc at: k1 : k2] mul: [[[same at:k1 :k2] neg] land: [a[k1] eq:@(i)]]]);
                    ce = ce == nil ? term : [ce plus: term];
                } else {
                    assert(j == t2);
                    id<ORExpr> term = Sum2(model, k1, r, k2, c,[[lc at: k1 : k2] mul: [[[same at:k1 :k2] neg] land: [a[k2] eq:@(i)]]]);
                    ce = ce == nil ? term : [ce plus: term];
                }
                
            }
            [model add: [ce eq: [mc_conn at:i :j]]];
        }
    }
    
    // Constraint counting the number of services running in each Machine.
    for(ORInt i = [cnodes low]; i <= [cnodes up]; i++) {
        [model add: [mc[i] eq: Sum(model, k, Iservice, [a[k] eq: @(i)])]];
    }
    
    for(NSNumber* sid in serLnk) {
        NSSet* cList = serLnk[sid];
        id<ORIntRange> instances = [omega at:(ORInt)[sid integerValue]];
        for(ORInt i= instances.low ;i <= instances.up;i++) {
            id<ORExpr> e = nil;
            for(id<ORIntVarMatrix> m in cList) {
                id<ORExpr> term = Sum(model,j,[m range:1],[m at:i :j]);
                e = e ? [e plus:term] : term;
            }
            [model add: [nbConn[i] eq: e]];
        }
    }
    
    
    // VM symmetry breaking
    for(ORInt i = [cnodes low]; i < [cnodes up]; i++) {
        [model add: [[mc[i] eq: @(0)] imply: [mc[i+1] eq: @(0)]]];
    }
    
    // Security Constraints
    for(ORInt k = [Iservice low]; k <= [Iservice up]; k++) {
        [model add: //[[a[k] gt: @(0)] eq:
         [s[k] geq: @([serviceZone at: [alpha at: k]])]
         //]
         ];
    }
    
    // Limit total memory usage on each physical node
    for(ORInt c = [cnodes low]; c <= [cnodes up]; c++) {
        //[model add: [Sum(model, i, vm, [[v[i] eq: @(c)] mul: u_mem[i]]) leq: cnodeMem[c]]];
        [model add: [u_mem[c] leq: cnodeMem[c]]];
        
    }
    // Limit total bandwidth usage on each physical node.
    for(ORInt c = [cnodes low]; c <= [cnodes up]; c++) {
        //[model add: [Sum(model, i, vm, [[v[i] eq:@(c)] mul:u_bw[i]]) leq: cnodeBw[c]]];
        [model add: [u_bw[c] leq: cnodeBw[c]]];
        
    }
    
    // Memory usage = Fixed memory for deploying VM + per service memory usage scaled by security technology + fixed cost of sec. technology.
    for(ORInt i = [cnodes low]; i <= [cnodes up]; i++) {

        //Waldy: Old code that works
        
        /*
        [model add: [[u_mem[i] mul: @(10)] geq:
                     [[mc[i] mul: @(VM_MEM * 10)] plus:
                      [Sum(model, k, Iservice, [[[a[k] eq: @(i)] mul: @([serviceFixMem at: [alpha at: k]])] mul: [secScaledMem elt: s[k]]]) plus:
                       Sum(model,j, Iservice, [ [a[j] eq: @(i)] mul: [[secFixMem elt: s[j]] mul: @(10)]])
                       ]]]];
        */
        
        //Waldy: This code is infeasible and does not appear to be a problem regarding the u_mem bounds.
        
        [model add: [[u_mem[i] mul: @(10)] geq:
                     [[mc[i] mul: @(VM_MEM * 10)] plus:
                      [Sum(model, k, Iservice, [[[a[k] eq: @(i)] mul: @([serviceFixMem at: [alpha at: k]])] mul: [Sum(model, x, sec, [secScaledMem elt: [secAdapter at: k: x]]) plus: @(10)]]) plus:
                       Sum(model,j, Iservice, [ [a[j] eq: @(i)] mul: [Sum(model, x, sec, [secFixMem elt: [secAdapter at: j: x]]) mul: @(10)]])
                       ]]]];
        
    
    for(int i = 0; i < 100; i++)
        for(int j = 0; j < 100; j++){
            links_i[i][j] = -1;
            linkCount[i] = 0;
        }
    
    
    id<ORIntRange> R = [[ORIntRangeI alloc] initORIntRangeI:0 up:numLinks-1];
    NSLog(@"numLinks = %d", numLinks);
    id<ORIntVarArray> l = [ORFactory intVarArray:model range:R];
    
    ORInt count = 0;
    for(NSArray* lnk in links) {
        id<ORIntVarMatrix> lc = links[lnk];
        id<ORIntRange> r = [lc range:0];
        id<ORIntRange> c = [lc range:1];
        for(ORInt s = r.low;s <= r.up;s++) {
            for(ORInt k = c.low; k <= c.up; k++){
                [l set:[lc at:s :k] at:count++];
                links_i[s][linkCount[s]] = k;
                links_i[k][linkCount[k]] = s;
                links_v[s][linkCount[s]++] = [lc at:s :k];
                links_v[k][linkCount[k]++] = [lc at:s :k];
            }
        }
    }
    
    for(ORInt i = [cnodes low]; i <= [cnodes up]; i++) {
        id<ORExpr> ce = nil;

        for(ORInt j = Iservice.low; j <= Iservice.up; j++){
            for(ORInt k = 0; k < linkCount[j]; k++){
                id<ORExpr> term = [[
                                     [[a[j] eq: @(i)] mul: [a[links_i[j][k]] neq: @(i)]]
                                    //[[same at:j :links_i[j][k]] neg]
                                    mul: [links_v[j][links_i[j][k]] mul: @([serviceFixBw at: [alpha at: j]])]]
                                   //mul: [secScaledBw elt: [chanSec at: j : links_i[j][k]]]];
                                   mul: [secScaledBw elt: s[j]]];

                ce = ce == nil ? term : [ce plus: term];
            }
            id<ORExpr> term = [secFixBw elt: [s at: j]];
            ce = ce == nil ? term : [ce plus: term];
        }
        [model add: [[u_bw at: i] geq: ce]];
    }
    /*
    for(ORInt i = [cnodes low]; i <= [cnodes up]; i++) {
        [model add:
    [[u_bw at: i] geq:
     Sum(model, j, Iservice,
         [Sum(model, k, RANGE(model,0,linkCount[j]),
                    [[[[a[j] eq: @(i)] mul: [a[links_i[j][k]] neq: @(i)]]
                    mul: [links_v[j][links_i[j][k]] mul: @([serviceFixBw at: j])]]
                    mul: [secScaledBw elt: [chanSec at: j : links_i[j][k]]]]) plus: [secFixBw elt: [s at: j]]]
        )
     ]];
    }
    */
    /*
    id<ORExpr> ce = [Sum(model, k, Iservice, [@([serviceFixMem at: [alpha at: k]]) mul: [secScaledMem elt: s[k]]]) plus:
                                           Sum(model,j, Iservice, [[secFixMem elt: s[j]] mul: @(10)])
                      ];
     */
    int TotalMem = 0;
    for(int i = cnodes.low; i <= cnodes.up; i++)
        TotalMem += [cnodeMem at: i];
    
    //ce = [ce plus: @((Iservice.up -1) * 10 * VM_MEM)];
    
    
    //[model add:[Sum(model, j, cnodes, [u_mem[j] mul: @(10)]) geq: ce]];

    [model add:[Sum(model, j, cnodes, u_mem[j]) leq: @(TotalMem)]];
    
    [model add: [Sum(model, j, cnodes, mc[j]) eq: @(Iservice.up + 1)]];
    
    //KNAPSACK CONSTRAINTS
    /*
     id<ORIntVarArray> x = All(mdl,ORIntVar, i, N, [ORFactory intVar:mdl domain:RANGE(mdl,0,1)]);
     for(int i=0;i<m;i++) {
     id<ORIntArray> w = [ORFactory intArray:mdl range:N with:^ORInt(ORInt j) {return r[i][j];}];
     id<ORIntVar>   c = [ORFactory intVar:mdl domain:RANGE(mdl,0,b[i])];
     [mdl add:[ORFactory knapsack:x weight:w capacity:c]];
     }
    */
    
    id<ORIntArray> w = [ORFactory intArray:model range:Iservice with:^ORInt(ORInt j) {
        return ([serviceFixMem at: [alpha at: j]] * [secScaledMem at: [serviceZone at: [alpha at: j]]]) + [secFixMem at: [serviceZone at: [alpha at: j]]] * 10 + 10 * VM_MEM;
    }];
    /*
    for(int z = cnodes.low ; z <= cnodes.up; z++){
        id<ORIntVarArray> x = All(model,ORIntVar, i, Iservice, [ORFactory intVar:model domain:RANGE(model,0,1)]);
        for(int i = Iservice.low; i <= Iservice.up; i++){
            [model add: [x[i] eq: [a[i] eq: @(z)]]];
        }
        //for(int k = Iservice.low; k <= Iservice.up; k++)
        //    printf("%d ", [w at: k]);
        id<ORIntVar> c = [ORFactory intVar:model domain:RANGE(model,0,1000*10)];
        //[model add:[c eq: [u_mem[z] mul: @(10)]]];
        [model add:[ORFactory knapsack:x weight:w capacity:c]];

    }
     */
    NSLog(@"Iservice %d", Iservice.up +1);
    id<ORIntArray> w2 = [ORFactory intArray:model range:RANGE(model,0,((Iservice.up+1)*(sec.up + 1))-1) with:^ORInt(ORInt j) {
        
        ORInt Security = j % (sec.up + 1);
        ORInt minScaledMem = 10000000;
        ORInt minFixedMem = 10000000;
        for(int i = Security; i <= sec.up; i++){
            minScaledMem = minScaledMem > [secScaledMem at:Security] ? [secScaledMem at:Security] : minScaledMem;
            minFixedMem = minFixedMem > [secFixMem at: Security] ? [secFixMem at: Security] : minFixedMem;
        }
        NSLog(@"AIndex: %d", j);

        return ([serviceFixMem at: [alpha at: (j/(sec.up + 1))]] * minScaledMem) + minFixedMem * 10 + 10 * VM_MEM;
    }];
/*
    for(int z = cnodes.low ; z <= cnodes.up; z++){
        id<ORIntVarArray> x = All(model,ORIntVar, i, RANGE(model,0,((Iservice.up+1)*(sec.up + 1))-1), [ORFactory intVar:model domain:RANGE(model,0,1)]);
        for(int i = 0; i <= ((Iservice.up+1)*(sec.up + 1))-1; i++){
                NSLog(@"BIndex: %d", i);
                [model add: [x[i] eq: [[a[i/(sec.up + 1)] eq: @(z)] eq: [s[i/(sec.up + 1)] eq: @(i%(sec.up + 1))]]]];
        }
        //for(int k = Iservice.low; k <= Iservice.up; k++)
        //    printf("%d ", [w at: k]);
        id<ORIntVar> c = [ORFactory intVar:model domain:RANGE(model,0,1000*10)];
        //[model add:[c eq: [u_mem[z] mul: @(10)]]];
        [model add:[ORFactory knapsack:x weight:w2 capacity:c]];
        
    }
  */
    
    
    // Function to write solution.
    // Print solution
    void(^writeOut)(id<ORSolution>) = ^(id<ORSolution> best){
        for(ORInt c = [cnodes low]; c <= [cnodes up]; c++) {
            NSLog(@"Node: %i {", c);
            ORInt i = c;
            NSLog(@"\tNode: %i (security: %i, %i services  memory: %d bw:%d) {", i, [best intValue: [s at: i]], [best intValue: [mc at: i]],[best intValue:[u_mem at:i]],[best intValue:[u_bw at:i]]);
            for(ORInt tk = services.low; tk <= services.up; tk++) {
                id<ORIntRange> tr = omega[tk];
                for(ORInt k1 = tr.low; k1 <= tr.up;k1++) {
                    ORInt mk1 = [best intValue: [a at: k1]];  // VM on which instance k1 of service tk is running.
                    if (mk1 == i) {
                        NSLog(@"\t\tservice: %i  <Type=%d:Mem=%d:Sec=%d> {", k1,tk,[serviceFixMem at:tk],[best intValue:[sSec at:k1]]);
                        for(id<ORIntVarMatrix> cm in serLnk[@(tk)]) {
                            for(ORInt k2 = [cm range:1].low;k2 <= [cm range:1].up; k2++) {
                                ORInt cl = [best intValue:[cm at:k1 :k2]];
                                if(cl > 0) {
                                    NSLog(@"\t\t\t[service %i <%d>] <=(%d,%d,NEG %d,%d)=> [service %i <Type:%d,Sec=%d> vm=%d] (x%i)", k1, tk,
                                          [best intValue:[chanSec at:k1 :k2]],
                                          [best intValue:[same at:k1 :k2]],1 - [best intValue:[same at:k1 :k2]],
                                          [best intValue:[maxSec at:k1 :k2]],
                                          k2,[alpha at:k2], [best intValue:[sSec at:k2]],[best intValue:a[k2]],cl);
                                }
                            }
                        }
                        NSLog(@"\t\t}");
                    }
                }
            }
            NSLog(@"\t}");
            
            
            NSLog(@"}");
        }
        NSLog(@"");
    };
    
    id<ORSolution> best = nil;
    ORTimeval now = [ORRuntimeMonitor now];
    switch(mode) {
        case MIP: {
            id<ORModel> lm = [ORFactory linearizeModel: model];
            id<ORRunnable> r = [ORFactory MIPRunnable: lm];
            [r start];
            best = [r bestSolution];
            writeOut(best);
        }break;
        case CP: {
            id<ORRunnable> r = [ORFactory CPRunnable: model willSolve:^CPRunnableSearch(id<CPCommonProgram> cp) {
                id<CPHeuristic> h = [cp createDDeg];
                return [^(id<CPCommonProgram> cp) {
                    [cp limitTime:tLim in:^{
                        //NSLog(@"CMem = %d", [cp intValue:totalCMem]);
                        //NSLog(@"VMMem = %d", [cp intValue:totalVMMem]);
                        [cp labelHeuristic: h restricted:a];
                        //[cp labelHeuristic: h restricted:v];
                        //                  [cp labelHeuristic: h restricted:(id<ORIntVarArray>)conn.flatten];
                        [cp labelHeuristic: h];
                        NSLog(@"+++++++ ALL done...");
                        id<ORSolution> sol = [cp captureSolution];
                        if (printSol) writeOut(sol);
                        ORTimeval ts = [ORRuntimeMonitor elapsedSince:now];
                        NSLog(@"Found Solution: %i   at: %f", [[sol objectiveValue] intValue],((double)ts.tv_sec) * 1000 + ts.tv_usec / 1000);
                    }];
                } copy];
            }];
            [r start];
            best = [r bestSolution];
            if (printSol) writeOut(best);
        }break;
        case LNS: {
            id<ORRunnable> r = [ORFactory CPRunnable: model willSolve:^CPRunnableSearch(id<CPProgram> cp) {
                [ORStreamManager setRandomized];
                id<ORUniformDistribution> d = [ORFactory uniformDistribution:model range:RANGE(model,1,100)];
                id<ORIntVarArray> av = [model intVars];
                id<CPHeuristic> h = [cp createDDeg];
                __block ORInt lim = 1000;
                __block BOOL improved = NO;
                __block BOOL firstTime = YES;
                __block ORInt per = 80;
                __block ORInt nbRestart = 0;
                id<ORObjectiveFunction> obj = [cp objective];
                
                return [^(id<CPProgram> cp) {
                    [cp limitTime:tLim in:^{
                        [cp repeat:^{
                            improved = NO;
                            [cp limitFailures:lim in:^{
                                if (firstTime) {
                                    [cp labelHeuristic: h restricted:a];
                                    //[cp labelHeuristic: h restricted:v];
                                    //                           [cp labelHeuristic: h restricted:(id<ORIntVarArray>)conn.flatten];
                                    [cp labelHeuristic: h];
                                } else {
                                    [cp labelHeuristic:h];
                                }
                                NSLog(@"+++++++ ALL done...");
                                id<ORSolution> sol = [cp captureSolution];
                                if (printSol) writeOut(sol);
                                ORTimeval ts = [ORRuntimeMonitor elapsedSince:now];
                                NSLog(@"Found Solution: %i   at: %f", [[sol objectiveValue] intValue],((double)ts.tv_sec) * 1000 + ts.tv_usec / 1000);
                            }];
                        } onRepeat:^{
                            nbRestart++;
                            id<ORSolution> s = [[cp solutionPool] best];
                            if (s!=nil) {
                                if (nbRestart < 10) {
                                    per = 0;
                                    return;
                                } else if (nbRestart == 10) {
                                    per = 100;
                                }
                                if (nbRestart % 10 == 0) {
                                    per = per * 0.5;
                                    lim = 1000;
                                }
                                NSLog(@"Restart [%d] with per = %d",nbRestart,per);
                                [cp atomic:^{
                                    [cp once:^{
                                        for(id<ORIntVar> avk in av) {
                                            if ([d next]  <= per) {
                                                [cp add:[avk eq:@([s intValue:avk])]];
                                            }
                                        }
                                    }];
                                }];
                                lim = min(20000,lim * 1.05);
                                NSLog(@"New limit: %d",lim);
                            } else {
                                NSLog(@"No solution yet. Restart [%d]",nbRestart);
                            }
                        }];
                        //firstTime = NO;
                        improved = YES;
                        per = 80;
                        NSLog(@"Objective value: %@  --improved = %d",[obj primalValue],improved);
                    }];
                } copy];
            }];
            [r start];
            best = [r bestSolution];
            if (printSol) writeOut(best);
        }break;
        case Hybrid: {
            id<ORRunnable> r1 = [ORFactory CPRunnable: model willSolve:^CPRunnableSearch(id<CPCommonProgram> cp) {
                id<CPHeuristic> h = [cp createWDeg];
                return [^(id<CPCommonProgram> cp) {
                    [cp labelHeuristic: h restricted:a];
                    //[cp labelHeuristic: h restricted:v];
                    //               [cp labelHeuristic: h restricted:(id<ORIntVarArray>)conn.flatten];
                    [cp labelHeuristic: h restricted:s];
                    [cp labelHeuristic: h];
                    NSLog(@"+++++++ ALL done...");
                    id<ORSolution> sol = [cp captureSolution];
                    if (printSol) writeOut(sol);
                    ORTimeval ts = [ORRuntimeMonitor elapsedSince:now];
                    NSLog(@"Found Solution: %i   at: %f", [[sol objectiveValue] intValue],((double)ts.tv_sec) * 1000 + ts.tv_usec / 1000);
                } copy];
            }];
            id<ORModel> lm = [ORFactory linearizeModel: model];
            id<ORRunnable> r0 = [ORFactory MIPRunnable: lm];
            id<ORRunnable> r = [ORFactory composeCompleteParallel:r0 with:r1];
            [r start];
            best = [r bestSolution];
        }break;
        case Expe: {
            id<ORRunnable> r = [ORFactory CPRunnable: model /*numThreads:1 */ willSolve:^CPRunnableSearch(id<CPCommonProgram> cp) {
                id<CPHeuristic> h = [cp createFF];
                //id<ORIntVarArray> av = [model intVars];
                
                return [^(id<CPCommonProgram> cp) {
                    
                    for(NSNumber* sLinkID in serLnk) {
                        NSSet* sLink = serLnk[sLinkID];
                        for(id<ORIntVarMatrix> m0 in sLink) {
                            id<ORIntVarMatrix> m;
                            if ([m0 range:0].size < [m0 range:1].size)
                                m = transpose(m0);
                            else m = m0;
                            id<ORIntRange> r = [m range:0];
                            id<ORIntRange> c = [m range:1];
                            assert(r.size > c.size);
                            {
                                for(ORInt i = r.low;i <= r.up;i++) {
                                    ORInt last = c.low - 1;
                                    for(ORInt s=r.low;s <= i;s++)
                                        for(ORInt k=c.low;k <= c.up;k++)
                                            if ([cp bound: [m at:s :k]] && [cp min:[m at:s :k]] != 0)
                                                last = k;
                                    last = last < c.up ? (last + 1) : c.up;
                                    [cp forall: RANGE(cp,c.low,last) suchThat:^ORBool(ORInt j) { return ![cp bound: [m at:i :j]];}
                                     orderedBy: ^ORInt(ORInt j) { return -j;}
                                            do: ^(ORInt j) {
                                                [cp tryall:[[m at:i :j] domain]
                                                  suchThat:^ORBool(ORInt v) { return [cp member:v in:[m at:i :j]];}
                                                 orderedBy:^ORDouble(ORInt v) { return -v;}
                                                        in:^(ORInt v) {
                                                            [cp label:[m at:i :j] with:v];
                                                        } onFailure:^(ORInt v) {
                                                            [cp diff:[m at:i :j] with:v];
                                                        }];
                                            }];
                                    //NSLog(@"Wipe rest of the row...");
                                    [cp forall:RANGE(cp,last+1,c.up) suchThat:^ORBool(ORInt j) { return ![cp bound:[m at:i :j]];} orderedBy:nil do:^(ORInt j) {
                                        [cp label:[m at:i :j] with:0];
                                    }];
                                }
                                //NSLog(@"Done with first matrix\n");
                            }
                        }
                    }
                    NSLog(@"+++++++ connectivity done... ");
                    
                    [cp labelHeuristic: h restricted:a];
                    NSLog(@"+++++++ a done... ");
                    //[cp labelHeuristic: h restricted:v];
                    NSLog(@"+++++++ a/v done... ");
                    
                    //               [cp labelHeuristic: h restricted:s];
                    //               NSLog(@"+++++++ a/v/s done... ");
                    
                    //               ORInt nbf = 0;
                    //               for(ORInt i = av.low;i <= av.up;i++) {
                    //                  nbf += [cp domsize:av[i]] > 1;
                    //                  if ([cp domsize:av[i]] > 1)
                    //                     NSLog(@"UNBOUND VAR: %@",av[i]);
                    //               }
                    //               NSLog(@"#Free vars : %d",nbf);
                    //               static int count = 0;
                    //               NSLog(@"+++++++ ALL done... %d",count++);
                    [cp labelHeuristic: h];
                    id<ORSolution> sol = [cp captureSolution];
                    if (printSol) writeOut(sol);
                    ORTimeval ts = [ORRuntimeMonitor elapsedSince:now];
                    NSLog(@"Found Solution: %i   at: %f", [[sol objectiveValue] intValue],((double)ts.tv_sec) * 1000 + ts.tv_usec / 1000);
                    [sol release];
                } copy];
            }];
            [r start];
            best = [r bestSolution];
        }break;
        case Waldy: {
            
            
            //int links_i[100][100];
            //int linkCount[100];

            
            for(int i = Iservice.low; i <= Iservice.up; i++){
                NSLog(@"linkCount[%d] = %d",i,linkCount[i]);
            }
            
            NSLog(@"count = %d", count);
            
            
            id<ORRunnable> r = [ORFactory CPRunnable: model willSolve:^CPRunnableSearch(id<CPCommonProgram> cp) {
                return [^(id<CPCommonProgram> cp) {
                    [cp limitTime:tLim in:^{
                        printf("Entering Waldys Search");
                        //id<CPHeuristic> h = [cp createDDeg];
                        id<ORIntVarArray> iv = [model intVars];
                        //Fix all Connections
                        [cp labelArrayFF:l];
                        
                        //Assign Each VM to a Cnode (Machine)
                        [cp forall:Iservice suchThat:^ORBool(ORInt i) {
                            //if(![cp bound: a[i]]) NSLog(@"i = %d",i);
                            return ![cp bound: a[i]];
                        } orderedBy:^ORInt(ORInt i) {
                            ORInt ConnectionOut = 0;
                            for(int k = 0; k < linkCount[i]; k++)
                                if([cp bound: a[links_i[i][k]]])
                                ConnectionOut += [cp intValue: links_v[i][k]];
                            //Choose the hardest to accomodate first (Encourage Fail Early)
                            /*
                             int minsec = sec.up + 1;
                             for(int c = cnodes.low; c <= cnodes.up; c++)
                             if(minsec > [cp min: s[c]]) minsec = [cp min: s[c]];
                             return ([serviceFixMem at: [alpha at: i]] * [secScaledMem at:minsec]);
                             */
                            //return -linkCount[i];
                            
                            //return -(ConnectionOut << 10) - [cp min: nbConn[i]];
                            return -(ConnectionOut << 10) -([serviceZone at: [alpha at: i]]);
                            //return abs([cp min: nbConn[i]] - ConnectionOut);
                            //return ConnectionOut - [cp min: nbConn[i]];

                            
                            //return -([serviceZone at: [alpha at: i]] << 10) -ConnectionOut;

                            //return -([serviceZone at: [alpha at: i]] << 10) - [cp min: nbConn[i]];
                            
                            
                            //return ([serviceFixMem at: [alpha at :i]] << 10) - linkCount[i];
                            //return - [serviceZone at: [alpha at :i]];
                            //return ([serviceZone at: [alpha at :i]] << 10) - linkCount[i];
                            //return -(([serviceZone at: [alpha at :i]] << 10) + [cp min: nbConn[i]]);
                            
                            //return i;
                            
                            //return - ([cp intValue:nbConn[i]] << 10) - [serviceFixMem at: [alpha at: i]] * [secScaledMem at:[serviceZone at: [alpha at: i]]];
                            //return - [cp intValue:nbConn[i]] - ([serviceFixMem at: [alpha at: i]] * [secScaledMem at:[serviceZone at: [alpha at: i]]] << 10);

                            
                        } do:^(ORInt i) {
                            /*
                             ORInt sum = 0;
                             ORInt sumvm = 0;
                             for(int z = Iservice.low; z <= Iservice.up; z++){
                             if([cp bound:a[z]] && [cp intValue: a[z]] == j){
                             sum += [serviceFixMem at: [alpha at: i]];
                             sumvm += 100 * VM_MEM;
                             }
                             }
                             */
                            
                            [cp tryall:cnodes suchThat:^ORBool(ORInt j) {
                                //Adding Instance does not exceed the memory and bw of cnode j
                                
                                //NSLog(@"Trying %d", j);
                                ORInt SumMem = [cp min: u_mem[4]] + [cp min: u_mem[1]] + [cp min: u_mem[2]] + [cp min: u_mem[3]];
                                ORInt SumBW = [cp min: u_bw[4]] + [cp min: u_bw[1]] + [cp min: u_bw[2]] + [cp min: u_bw[3]];
                                ORInt ConnCount = 0;
                                ORInt SumBest = 0;
                                for(int z = Iservice.low; z <= Iservice.up; z++){
                                    if(![cp bound: a[z]])
                                        SumBest += [w at: z];
                                    else{
                                        ConnCount += [cp intValue:[nbConn at: z]];
                                    }
                                }
                                ORInt lbObj = SumMem + SumBW + (SumBest/10) + ConnCount + ConnCount/2;
                                //NSLog(@"SumMem: %d   SumBest: %d   SumALL: %d", SumMem, SumBest/10, SumMem + SumBW + (SumBest/10) + ConnCount + ConnCount/2);
                                
                                return lbObj < GlobalMin && [cp member:j in:a[i]];
                                
                                id<ORIntMatrix> sOut_i = [ORFactory intMatrix:cp range: cnodes :services with:^ORInt(ORInt x, ORInt k) {
                                    ORInt sum = 0;
                                    for(NSArray* lnk in links) {
                                        ORInt t1 = (ORInt)[lnk[0] integerValue],t2 = (ORInt)[lnk[1] integerValue];
                                        if (t1 != k && t2 != k) continue;
                                        id<ORIntVarMatrix> lc = links[lnk];
                                        id<ORIntRange> r = [lc range:0];
                                        id<ORIntRange> c = [lc range:1];
                                        if (k == t1) {
                                            for(int m = r.low; m <= r.up; m++){
                                                for(int n = c.low; n <= c.up; n++){
                                                    if(m == i && ([cp bound: a[n]]) && [cp intValue:a[n]] != j && (j == x || [cp intValue:a[n]] == x)){
                                                        sum += [cp intValue:[lc at: m : n]];
                                                    }
                                                }
                                            }
                                        } else {
                                            for(int m = r.low; m <= r.up; m++){
                                                for(int n = c.low; n <= c.up; n++){
                                                    if(n == i && ([cp bound: a[m]]) && j != [cp intValue:a[m]] && (j == x || [cp intValue:a[m]] == x)){
                                                        sum += [cp intValue:[lc at: m : n]];
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    return sum;
                                }];
                                
                                id<ORIntMatrix> sOut = [ORFactory intMatrix:cp range: cnodes :services with:^ORInt(ORInt j, ORInt k) {
                                    ORInt sum = 0;
                                    for(NSArray* lnk in links) {
                                        ORInt t1 = (ORInt)[lnk[0] integerValue],t2 = (ORInt)[lnk[1] integerValue];
                                        if (t1 != k && t2 != k) continue;
                                        id<ORIntVarMatrix> lc = links[lnk];
                                        id<ORIntRange> r = [lc range:0];
                                        id<ORIntRange> c = [lc range:1];
                                        if (k == t1) {
                                            for(int m = r.low; m <= r.up; m++){
                                                for(int n = c.low; n <= c.up; n++){
                                                    if(([cp bound: a[m]] && [cp bound: a[n]]) && [cp intValue:a[m]] != [cp intValue:a[n]] && [cp intValue:a[m]] == j){
                                                        sum += [cp intValue:[lc at: m : n]];
                                                    }
                                                }
                                            }
                                        } else {
                                            for(int m = r.low; m <= r.up; m++){
                                                for(int n = c.low; n <= c.up; n++){
                                                    if(([cp bound: a[m]] && [cp bound: a[n]]) && [cp intValue:a[m]] != [cp intValue:a[n]] && [cp intValue:a[n]] == j){
                                                        sum += [cp intValue:[lc at: m : n]];
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    return sum;
                                }];
                                
                                /*
                                 id<ORIntArray> sOut = [ORFactory intArray:model range:services with:^ORInt(ORInt k) {
                                 for(ORInt j = services.low; j <= services.up; j++) {
                                 id<ORExpr> ce = nil;
                                 for(NSArray* lnk in links) {
                                 ORInt t1 = (ORInt)[lnk[0] integerValue],t2 = (ORInt)[lnk[1] integerValue];
                                 if (t1 != j && t2 != j) continue;
                                 id<ORIntVarMatrix> lc = links[lnk];
                                 id<ORIntRange> r = [lc range:0];
                                 id<ORIntRange> c = [lc range:1];
                                 if (j == t1) {
                                 
                                 id<ORExpr> term = Sum2(model, k1, r, k2, c,[[lc at: k1 : k2] mul: [[[same at:k1 :k2] neg] land: [a[k1] eq:@(i)]]]);
                                 ce = ce == nil ? term : [ce plus: term];
                                 } else {
                                 assert(j == t2);
                                 id<ORExpr> term = Sum2(model, k1, r, k2, c,[[lc at: k1 : k2] mul: [[[same at:k1 :k2] neg] land: [a[k2] eq:@(i)]]]);
                                 ce = ce == nil ? term : [ce plus: term];
                                 }
                                 
                                 }
                                 [model add: [ce eq: [mc_conn at:i :j]]];
                                 }
                                 }];
                                 */
                                /*
                                 id<ORIntMatrix> sOut = [ORFactory intMatrix:model range: cnodes :services with:^ORInt(ORInt j, ORInt k) {
                                 ORInt sum = 0;
                                 for(int r = Iservice.low; r <= Iservice.up; r++){ // For each service instance
                                 if([cp bound: a[r]] && [cp intValue: a[r]] == j){ // Check to see if it is currently on machine j, if is continue
                                 for(int c = 0; c < linkCount[r]; c++){ // Run through all possible connections from r -> c
                                 if([cp bound: a[links_i[r][c]]] && [alpha at: links_i[r][c]] == k && [cp intValue: a[links_i[r][c]]] != j){
                                 //NSLog(@"[%d ==> links_i[%d][%d]] = %d",r,r,c, links_i[r][c]);
                                 //NSLog(@"Num of Links: %d", [cp intValue:links_v[r][links_i[r][c]]]);
                                 sum = sum + [cp intValue:links_v[r][links_i[r][c]]];
                                 }
                                 }
                                 }
                                 }
                                 //NSLog(@"s = %d",sum);
                                 
                                 return sum;
                                 
                                 }];
                                 */
                                /*
                                 id<ORIntArray> newSec = [ORFactory intArray:model range:cnodes with:^ORInt(ORInt k) {
                                 //[cp intValue: links_v[0][0]];
                                 for(int c = 0; c < linkCount[i]; c++){
                                 if([cp bound: a[links_i[i][c]]] && [cp intValue: a[links_i[i][c]]] == k && [cp intValue: links_v[i][c]] > 0){
                                 if([cp min: s[k]] < [serviceZone at: [alpha at: i]])
                                 return [serviceZone at: [alpha at: i]];
                                 }
                                 }
                                 return [serviceZone at: [alpha at: i]];
                                 //return [cp min: s[k]];
                                 }];
                                 */
                                id<ORIntArray> memAll = [ORFactory intArray: cp range:cnodes with:^ORInt(ORInt k) {
                                    
                                    int minScaledMem = 1000000;
                                    int minFixedMem = 1000000;
                                    ORInt secStart = [serviceZone at: [alpha at: i]] > [cp min: s[k]] && j == k ? [serviceZone at: [alpha at: i]] : [cp min: s[k]];
                                    
                                    for(int s = secStart; s <= sec.up; s++){
                                        //NSLog(@"s %d", s);
                                        minScaledMem = minScaledMem > [secScaledMem at:s] ? [secScaledMem at:s] : minScaledMem;
                                        minFixedMem = minFixedMem > [secFixMem at: s] ? [secFixMem at: s] : minFixedMem;
                                    }
                                    
                                    ORInt serviceCount = 0;
                                    ORInt memCost = (k == j) * [serviceFixMem at: [alpha at: i]] * minScaledMem;
                                    for(int h = Iservice.low; h <= Iservice.up; h++){
                                        if([cp bound: a[h]] && [cp intValue:a[h]] == k){
                                            memCost += [serviceFixMem at: [alpha at: h]] * minScaledMem;
                                            serviceCount++;
                                        }
                                    }
                                    memCost += (minFixedMem * 100) + 100 * VM_MEM * (serviceCount+(k == j));
                                    return memCost / 100;
                                }];
                                
                                
                                id<ORIntArray> bwAll = [ORFactory intArray: cp range:cnodes with:^ORInt(ORInt k) {
                                    ORInt existConn = 0;
                                    for(int z = services.low; z <= services.up; z++){
                                        //NSLog(@"sout %d = %d", z, [sOut at: z]);
                                        //existConn += ([cp min:[mc_conn at: k : z]] + [sOut_i at:z]) * [serviceFixBw at: z];
                                        //NSLog(@"sOut[%d]: %d   mc_conn[%d,%d]: %d", z, [sOut at: k : z] , k, z, [cp min: [mc_conn at: k:z]]);
                                        //if(k == j){
                                        //NSLog(@"sOuti[%d]: %d   mc_conn[%d,%d]: %d", z, [sOut_i at: z] , k, z, [cp min: [mc_conn at: k:z]]);
                                        //                                      }
                                        existConn += ([sOut at: k: z] + [sOut_i at: k :z]) * [serviceFixBw at: z];
                                        //existConn += ([cp min:[mc_conn at: k : z]] + [sOut_i at:z]) * [serviceFixBw at: z];
                                        
                                    }
                                    //NSLog(@"n = %d",  [secFixBw at: [newSec at: k]]);
                                    
                                    int minScaledBW = 1000000;
                                    int minFixedBW = 1000000;
                                    ORInt secStart = [serviceZone at: [alpha at: i]] > [cp min: s[k]] && j == k ? [serviceZone at: [alpha at: i]] : [cp min: s[k]];
                                    
                                    //for(int s = [newSec at: k]; s <= sec.up; s++){
                                    for(int s = secStart; s <= sec.up; s++){
                                        
                                        //NSLog(@"s %d", s);
                                        minScaledBW = minScaledBW > [secScaledBw at:s] ? [secScaledBw at:s] : minScaledBW;
                                        minFixedBW = minFixedBW > [secFixBw at: s] ? [secFixBw at: s] : minFixedBW;
                                    }
                                    return (existConn * minScaledBW) + minFixedBW;
                                    
                                    //return (existConn * [secScaledBw at:[newSec at: k]]) + [secFixBw at: [newSec at: k]];
                                }];
                                
                                
                                /*
                                 NSLog(@"==========");
                                 NSLog(@"Current %d", i);
                                 for(int y = cnodes.low; y <= cnodes.up; y++){
                                 NSLog(@"u_mem[%d] = %d",y,[cp min: u_mem[y]]);
                                 }
                                 NSLog(@"memcost[%d] = %d",j,[memAll at: j]);
                                 for(int y = cnodes.low; y <= cnodes.up; y++){
                                 NSLog(@"u_bw[%d] = %d",y,[cp min: u_bw[y]]);
                                 }
                                 NSLog(@"bwcost[%d] = %d",j,[bwAll at: j]);
                                 for(int y = cnodes.low; y <= cnodes.up; y++){
                                 NSLog(@"s[%d] = %d",y,[cp min: s[y]]);
                                 }
                                 NSLog(@"==========");
                                 */
                                
                                ORInt bwCostSum = 0;
                                ORInt memCostSum = 0;
                                ORInt nbConnCount = 0;
                                for(int b = cnodes.low; b <= cnodes.up; b++){
                                    bwCostSum += [bwAll at: b];
                                    memCostSum += [memAll at: b];
                                }
                                for(int b = Iservice.low; b <= Iservice.up; b++){
                                    nbConnCount += [cp intValue: [nbConn at: b]];
                                }
                                ORBool OptPrune = ((bwCostSum + memCostSum) + nbConnCount + nbConnCount/2) < GlobalMin;
                                //NSLog(@"Cnode: %d BwCostSum: %d memCostSum: %d nbConn %d TotalSum: %d",j, bwCostSum, memCostSum, nbConnCount, (bwCostSum + memCostSum) + nbConnCount + nbConnCount/2);
                                return [cp member:j in:a[i]] && [memAll at: j] <= [cnodeArray[j-1] cnodeMemory] && [bwAll at: j] <= [cnodeArray[j-1] cnodeBandwidth] && OptPrune;
                                
                                
                                //return memCost <= [cnodeArray[j-1] cnodeMemory] && bwCost <= [cnodeArray[j-1] cnodeBandwidth];
                            } orderedBy:^ORDouble(ORInt j) {
                                /*
                                 id<ORIntArray> sOut = [ORFactory intArray:model range:services with:^ORInt(ORInt k) {
                                 ORInt sum = 0;
                                 for(int c = 0; c < linkCount[i]; c++){
                                 if([cp bound: a[links_i[i][c]]] && [alpha at: links_i[i][c]] == k && [cp intValue: a[links_i[i][c]]] != j){
                                 sum++;
                                 }
                                 }
                                 return sum;
                                 }];
                                 
                                 ORInt numSameService = 0;
                                 for(int k = Iservice.low; k <= Iservice.up; k++){
                                 if([cp bound:a[k]] && [cp intValue:a[k]] == j && [alpha at: k] == [alpha at: i]){
                                 numSameService++;;
                                 }
                                 }
                                 
                                 ORInt sec = [serviceZone at: [alpha at: i]] > [cp min: s[j]] ? [serviceZone at: [alpha at: i]] : [cp min: s[j]];
                                 //sec = [cp min: s[j]];
                                 
                                 ORInt memCost = ([cp min: mc[j]] * [serviceFixMem at: [alpha at: i]]) * [secScaledMem at:sec];
                                 memCost += ([secFixMem at:sec] * 100);
                                 memCost += 100 * VM_MEM * [cp min: mc[j]];//sumvm;
                                 memCost = (memCost / 100);
                                 
                                 //ORInt bwCost = [cp min: u_bw[j]] + (linkout[j] * [serviceFixBw at: [alpha at: i]] );
                                 ORInt existConn = 0;
                                 for(int z = services.low; z <= services.up; z++)
                                 existConn += ([cp min:[mc_conn at: j : z]] + [sOut at:z]) * [serviceFixBw at: z];
                                 ORInt bwCost = (existConn * [secScaledBw at:sec]) + [secFixBw at: sec];
                                 
                                 
                                 //NSLog(@"memCost = %d", memCost);
                                 //return bwCost;
                                 return (bwCost << 10) + numSameService;
                                 */
                                //return -[cp min:mc[j]];
                                
                                
                                id<ORIntMatrix> sOut_i = [ORFactory intMatrix:cp range: cnodes :services with:^ORInt(ORInt x, ORInt k) {
                                    ORInt sum = 0;
                                    for(NSArray* lnk in links) {
                                        ORInt t1 = (ORInt)[lnk[0] integerValue],t2 = (ORInt)[lnk[1] integerValue];
                                        if (t1 != k && t2 != k) continue;
                                        id<ORIntVarMatrix> lc = links[lnk];
                                        id<ORIntRange> r = [lc range:0];
                                        id<ORIntRange> c = [lc range:1];
                                        if (k == t1) {
                                            for(int m = r.low; m <= r.up; m++){
                                                for(int n = c.low; n <= c.up; n++){
                                                    if(m == i && ([cp bound: a[n]]) && [cp intValue:a[n]] != j && (j == x || [cp intValue:a[n]] == x)){
                                                        sum += [cp intValue:[lc at: m : n]];
                                                    }
                                                }
                                            }
                                        } else {
                                            for(int m = r.low; m <= r.up; m++){
                                                for(int n = c.low; n <= c.up; n++){
                                                    if(n == i && ([cp bound: a[m]]) && j != [cp intValue:a[m]] && (j == x || [cp intValue:a[m]] == x)){
                                                        sum += [cp intValue:[lc at: m : n]];
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    return sum;
                                }];
                                
                                id<ORIntMatrix> sOut = [ORFactory intMatrix:cp range: cnodes :services with:^ORInt(ORInt j, ORInt k) {
                                    ORInt sum = 0;
                                    for(NSArray* lnk in links) {
                                        ORInt t1 = (ORInt)[lnk[0] integerValue],t2 = (ORInt)[lnk[1] integerValue];
                                        if (t1 != k && t2 != k) continue;
                                        id<ORIntVarMatrix> lc = links[lnk];
                                        id<ORIntRange> r = [lc range:0];
                                        id<ORIntRange> c = [lc range:1];
                                        if (k == t1) {
                                            for(int m = r.low; m <= r.up; m++){
                                                for(int n = c.low; n <= c.up; n++){
                                                    if(([cp bound: a[m]] && [cp bound: a[n]]) && [cp intValue:a[m]] != [cp intValue:a[n]] && [cp intValue:a[m]] == j){
                                                        sum += [cp intValue:[lc at: m : n]];
                                                    }
                                                }
                                            }
                                        } else {
                                            for(int m = r.low; m <= r.up; m++){
                                                for(int n = c.low; n <= c.up; n++){
                                                    if(([cp bound: a[m]] && [cp bound: a[n]]) && [cp intValue:a[m]] != [cp intValue:a[n]] && [cp intValue:a[n]] == j){
                                                        sum += [cp intValue:[lc at: m : n]];
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    return sum;
                                }];
                                
                                id<ORIntArray> memAll = [ORFactory intArray: cp range:cnodes with:^ORInt(ORInt k) {
                                    
                                    int minScaledMem = 1000000;
                                    int minFixedMem = 1000000;
                                    ORInt secStart = [serviceZone at: [alpha at: i]] > [cp min: s[k]] && j == k ? [serviceZone at: [alpha at: i]] : [cp min: s[k]];
                                    
                                    for(int s = secStart; s <= sec.up; s++){
                                        minScaledMem = minScaledMem > [secScaledMem at:s] ? [secScaledMem at:s] : minScaledMem;
                                        minFixedMem = minFixedMem > [secFixMem at: s] ? [secFixMem at: s] : minFixedMem;
                                    }
                                    
                                    ORInt serviceCount = 0;
                                    ORInt memCost = (k == j) * [serviceFixMem at: [alpha at: i]] * minScaledMem;
                                    for(int h = Iservice.low; h <= Iservice.up; h++){
                                        if([cp bound: a[h]] && [cp intValue:a[h]] == k){
                                            memCost += [serviceFixMem at: [alpha at: h]] * minScaledMem;
                                            serviceCount++;
                                        }
                                    }
                                    memCost += (minFixedMem * 100) + 100 * VM_MEM * (serviceCount+(k == j));
                                    return memCost / 100;
                                }];
                                
                                
                                id<ORIntArray> bwAll = [ORFactory intArray: cp range:cnodes with:^ORInt(ORInt k) {
                                    ORInt existConn = 0;
                                    for(int z = services.low; z <= services.up; z++){
                                        existConn += ([sOut at: k: z] + [sOut_i at: k :z]) * [serviceFixBw at: z];
                                    }
                                    
                                    int minScaledBW = 1000000;
                                    int minFixedBW = 1000000;
                                    ORInt secStart = [serviceZone at: [alpha at: i]] > [cp min: s[k]] && j == k ? [serviceZone at: [alpha at: i]] : [cp min: s[k]];
                                    
                                    for(int s = secStart; s <= sec.up; s++){
                                        minScaledBW = minScaledBW > [secScaledBw at:s] ? [secScaledBw at:s] : minScaledBW;
                                        minFixedBW = minFixedBW > [secFixBw at: s] ? [secFixBw at: s] : minFixedBW;
                                    }
                                    return (existConn * minScaledBW) + minFixedBW;
                                }];
                                
                                ORInt numSameService = 0;
                                for(int k = Iservice.low; k <= Iservice.up; k++){
                                    if([cp bound:a[k]] && [cp intValue:a[k]] == j && [alpha at: k] == [alpha at: i]){
                                        numSameService++;
                                    }
                                }
                                
                                ORInt bwCostSum = 0;
                                ORInt memCostSum = 0;
                                ORInt totalConnOut = 0;
                                //ORInt nbConnCount = 0;
                                for(int b = cnodes.low; b <= cnodes.up; b++){
                                    bwCostSum += [bwAll at: b];
                                    memCostSum += [memAll at: b];
                                }
                                for(int b = services.low; b <= services.up; b++){
                                    totalConnOut += [sOut at: j : b] + [sOut_i at: j : b];
                                }
                                //return (([cp min: s[j]] - [serviceZone at: [alpha at: i]]) << 10) + (numSameService << 3) + j;
                                //return totalConnOut;
                                return memCostSum;
                                
                                //return ((bwCostSum + memCostSum) << 10) + j;
                                //return (abs([serviceZone at: [alpha at: i]] - [cp min: s[j]]) << 10) - totalConnOut;
                                //return (([serviceZone at: [alpha at: i]] - [cp min: s[j]]) << 10) + (numSameService << 3) + j;


                                //return (abs([serviceZone at: [alpha at: i]] - [cp min: s[j]]) << 10) + (totalConnOut << 3) + j;
                                
                                //return (abs([serviceZone at: [alpha at: i]] - [cp min: s[j]]) << 10) + (numSameService << 3) + j;
                                //return ((bwCostSum) << 10) - numSameService;
                                
                                
                            } in:^(ORInt j) {
                                //NSLog(@"a[%d] = %d",i,j);
                                [cp label:a[i] with:j];
                            } onFailure:^(ORInt j) {
                                [cp diff:a[i] with:j];
                                //NSLog(@"a[%d] = %d",i,j);

                            }];
                            
                        }];
                        
                        [cp labelArrayFF:iv];
                        
                        
                        if(![cp ground]){
                            NSLog(@"CP IS NOT BOUNDED");
                            NSLog(@"%@", [[cp engine] model]);
                        }
                        
                        id<ORSolution> sol = [cp captureSolution];
                        //if (printSol) writeOut(sol);
                        ORTimeval ts = [ORRuntimeMonitor elapsedSince:now];
                        ORInt bwCostSum = 0;
                        ORInt memCostSum = 0;
                        for(int b = cnodes.low; b <= cnodes.up; b++){
                            bwCostSum += [cp intValue: u_bw[b]];
                            memCostSum += [cp intValue: u_mem[b]];
                        }
                        NSLog(@"MemTCost: %d   bwCostSum: %d", memCostSum, bwCostSum);
                        NSLog(@"Found Solution: %i   at: %f", [[sol objectiveValue] intValue],((double)ts.tv_sec) * 1000 + ts.tv_usec / 1000);
                        
                        if([[sol objectiveValue] intValue] < GlobalMin)
                            GlobalMin = [[sol objectiveValue] intValue];
                        
                        /*
                         [model add: [[u_mem[i] mul: @(100)] geq:
                         [[mc[i] mul: @(VM_MEM * 100)] plus:
                         [[Sum(model, k, Iservice, [ [a[k] eq: @(i)] mul: @([serviceFixMem at: [alpha at: k]])] ) mul: [secScaledMem elt: s[i]] ] plus:
                         [[secFixMem elt: s[i]] mul: @(100)]]
                         ]]];
                         */
                        /*
                         for(ORInt i = [cnodes low]; i <= [cnodes up]; i++) {
                         [model add: [[u_bw at: i] geq:
                         [[Sum(model, j, services, [[mc_conn at: i : j] mul: @([serviceFixBw at: j])]) mul: [secScaledBw elt: [s at: i]]] plus:
                         [secFixBw elt: [s at: i]]
                         ]]];
                         }
                         */
                    }];
                } copy];
            }];
            [r start];
            best = [r bestSolution];
            if (printSol) writeOut(best);
        }break;
    }
    
    //NSLog(@"Number of solutions found: %li", [[cp solutionPool] count]);
    ORTimeval el = [ORRuntimeMonitor elapsedSince:now];
    NSLog(@"#best objective: %@",[best objectiveValue]);
    NSLog(@"Total time: %f",el.tv_sec * 1000.0 + (double)el.tv_usec / 1000.0);
    return 0;
}



















