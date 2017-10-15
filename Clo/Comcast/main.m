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

enum Mode {
   MIP,CP,Hybrid,LNS,Expe
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

   
   
   id<ORIntRange> vm = RANGE(model,1, maxVMs);
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
   id<ORIntVarArray> v = [ORFactory intVarArray: model range: vm domain: RANGE(model, 0, Ncnodes)];
   id<ORIntVarArray> vc = [ORFactory intVarArray: model range: vm domain: RANGE(model, 0, maxPerVM)];
   id<ORIntVarMatrix> vm_conn = [ORFactory intVarMatrix: model range: vm : services domain: RANGE(model, 0, maxPerVM * MAX_CONN)];
   
   id<ORIntVarArray> a = [ORFactory intVarArray: model range: Iservice domain: RANGE(model, 1, maxVMs)];
//   id<ORIntVarMatrix> conn = [ORFactory intVarMatrix: model range: Iservice : Iservice domain: RANGE(model, 0, MAX_CONN)];
   id<ORIntVarMatrix> chanSec = [ORFactory intVarMatrix: model range: Iservice : Iservice domain: sec];
   id<ORIntVarArray> nbConn = [ORFactory intVarArray:model range:Iservice domain:RANGE(model,1,Iservice.size)];
   
   id<ORIntVarArray>  s = [ORFactory intVarArray: model range: RANGE(model, 0, maxVMs) domain: sec]; // We really want the range to be 'vm' here, but 0 must be included for elt constraint.
   id<ORIntVarArray>  sSec = [ORFactory intVarArray: model range: Iservice  domain: sec]; // We really want the range to be 'vm' here, but 0 must be included for elt constraint.
   
   id<ORIntVarArray> u_mem = [ORFactory intVarArray: model range: vm domain: RANGE(model, 0, 1000)];
   id<ORIntVarArray> u_bw = [ORFactory intVarArray: model range: vm domain: RANGE(model, 0, 200)];
   
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
   [model minimize: [[Sum(model, i, vm, [u_mem[i] plus: u_bw[i]])  plus: Sum(model,i,Iservice, nbConn[i]) ] plus: sumConn]];
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
            id<ORIntVarArray> bvm = [ORFactory intVarArray:model range:vm domain:RANGE(model,0,1)];
            for(ORInt v = vm.low; v <= vm.up;v++) {
               [model add: [bvm[v] eq: [[a[k1] eq: @(v)] land: [a[k2] eq:@(v)]]]];
            }
            //[model add:[[same at:k1 :k2] leq: Or(model, v, vm, bvm[v])]];
            [model add:[[same at:k1 :k2] leq: Sum(model, v, vm, bvm[v])]];
            for(ORInt i = vm.low;i <= vm.up;i++)
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
      }
   }
//   ORInt nbUsed = 0;
//   for(ORInt k1 = [Iservice low]; k1 <= [Iservice up]; k1++) {
//      for(ORInt k2 = [Iservice low]; k2 <= [Iservice up]; k2++) {
//         ORInt tk1 = [alpha at: k1];
//         ORInt tk2 = [alpha at: k2];
//         if ([C at:tk1 :tk2] == 0) {
//            [model add: [[conn at:k1 :k2] eq: @(0)]];
//         } else nbUsed++;
//      }
//   }
//   NSLog(@"used: %d out of %d",nbUsed,[Iservice size] * [Iservice size]);

   
   // Count connections on each VM. A connection is not counted if the two services are both within the same VM.
   for(ORInt i = [vm low]; i <= [vm up]; i++) {
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
         [model add: [ce eq: [vm_conn at:i :j]]];
      }
   }
   
   // Constraint counting the number of services running in each VM.
   for(ORInt i = [vm low]; i <= [vm up]; i++) {
      [model add: [vc[i] eq: Sum(model, k, Iservice, [a[k] eq: @(i)])]];
   }
   
   // Constraint adding VM to node if it is in use.
   for(ORInt i = [vm low]; i <= [vm up]; i++) {
      [model add: [[vc[i] gt: @(0)] eq: [v[i] gt: @(0)]]];
      [model add: [[vc[i] eq: @(0)] eq: [v[i] eq: @(0)]]];
   }
   
   // Bounding the # of connections for a service
//   for(ORInt i= Iservice.low; i <= Iservice.up;i++) {
//       [model add: [nbConn[i] eq: Sum(model, j, Iservice, [conn at:i :j])]];
//   }
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
   for(ORInt i = [vm low]; i < [vm up]; i++) {
      [model add: [[vc[i] eq: @(0)] imply: [vc[i+1] eq: @(0)]]];
   }
   
   // Security Constraints
   for(ORInt k = [Iservice low]; k <= [Iservice up]; k++) {
      [model add: //[[a[k] gt: @(0)] eq:
                    [[s elt: a[k]] geq: @([serviceZone at: [alpha at: k]])]
                    //]
                   ];
   }
   
   // Limit total memory usage on each physical node
   for(ORInt c = [cnodes low]; c <= [cnodes up]; c++) {
      [model add: [Sum(model, i, vm, [[v[i] eq: @(c)] mul: u_mem[i]]) leq: cnodeMem[c]]];
   }
   // Limit total bandwidth usage on each physical node.
   for(ORInt c = [cnodes low]; c <= [cnodes up]; c++) {
      [model add: [Sum(model, i, vm, [[v[i] eq:@(c)] mul:u_bw[i]]) leq: cnodeBw[c]]];
   }
   
   //    // Memory usage = Fixed memory for deploying VM + per service memory usage scaled by security technology + fixed cost of sec. technology.
   for(ORInt i = [vm low]; i <= [vm up]; i++) {
      // CP
      [model add: [[u_mem[i] mul: @(100)] geq:
                   [[[vc[i] gt: @(0)] mul: @(VM_MEM * 100)] plus:
                    [[Sum(model, k, Iservice, [ [a[k] eq: @(i)] mul: @([serviceFixMem at: [alpha at: k]])] ) mul: [secScaledMem elt: s[i]] ] plus:
                     [[secFixMem elt: s[i]] mul: @(100)]]
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
               NSLog(@"\tVM: %i (security: %i, %i services  memory: %d bw:%d) {", i, [best intValue: [s at: i]], [best intValue: [vc at: i]],[best intValue:[u_mem at:i]],[best intValue:[u_bw at:i]]);
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
            }
         }
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
                  [cp labelHeuristic: h restricted:a];
                  [cp labelHeuristic: h restricted:v];
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
                           [cp labelHeuristic: h restricted:v];
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
               [cp labelHeuristic: h restricted:v];
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
               [cp labelHeuristic: h restricted:v];
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
   }
   
   //NSLog(@"Number of solutions found: %li", [[cp solutionPool] count]);
   ORTimeval el = [ORRuntimeMonitor elapsedSince:now];
   NSLog(@"#best objective: %@",[best objectiveValue]);
   NSLog(@"Total time: %f",el.tv_sec * 1000.0 + (double)el.tv_usec / 1000.0);
   return 0;
}
