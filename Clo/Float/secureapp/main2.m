#import "Datastruct.h"
#import "ORCmdLineArgs.h"


Network* makeInstance ()
{
   NSArray* device = @[@"h8",  @"h9",  @"h2",  @"h3",  @"h1",  @"h6",  @"h7",  @"h4",  @"h5",  @"sc1",  @"sa5",  @"sa20",  @"g2",  @"g1",  @"sa9",  @"sa8",  @"sc4",  @"sa7",  @"sa6",  @"sc3",  @"sc2",  @"h10",  @"h11",  @"h12",  @"h13",  @"h14",  @"h15",  @"h16",  @"sa19",  @"sa18",  @"sa17",  @"sa16",  @"sa15",  @"sa14",  @"sa13",  @"sa12",  @"sa11", @"sa10"];
   NSMutableArray* deviceMemory = [[[NSMutableArray alloc] init] autorelease];
   for(ORInt i = 0; i < [device count];i++){
      [deviceMemory addObject:@100];
   }
   NSArray* trafics = @[@"A",@"B"];
   NSArray* flowsA = @[@[@4,@13],@[@13,@4],@[@7,@13],@[@13,@7],@[@8,@13],@[@13,@8],@[@0,@13],@[@13,@0],@[@1,@12],@[@12,@1],@[@12,@23],@[@23,@12],@[@12,@24],@[@24,@12],@[@12,@27],@[@27,@12],@[@2,@4],@[@4,@2],@[@3,@7],@[@7,@3],@[@5,@8],@[@8,@5],@[@0,@6],@[@6,@0],@[@1,@21],@[@21,@1],@[@22,@23],@[@23,@22],@[@24,@25],@[@25,@24],@[@26,@27],@[@27,@26]];
   NSArray* flowsB = @[@[@2,@4],@[@4,@2],@[@3,@7],@[@7,@3],@[@5,@8],@[@8,@5],@[@0,@6],@[@6,@0],@[@1,@21],@[@21,@1],@[@22,@23],@[@23,@22],@[@24,@25],@[@25,@24],@[@26,@27],@[@27,@26],@[@2,@5],@[@5,@2],@[@2,@21],@[@21,@2],@[@2,@25],@[@25,@2],@[@3,@6],@[@6,@3],@[@3,@22],@[@22,@3],@[@3,@26],@[@26,@3]];
   NSArray* flows = @[ flowsA, flowsB];
   NSArray* demandA = @[@1,@1,@1,@1,@1,@1,@1,@1,@1,@1,@1,@1,@1,@1,@1,@1,@1,@1,@1,@1,@1,@1,@1,@1,@1,@1,@1,@1,@1,@1,@1,@1];
   NSArray* demandB = @[@1,@1,@1,@1,@1,@1,@1,@1,@1,@1,@1,@1,@1,@1,@1,@1,@1,@1,@1,@1,@1,@1,@1,@1,@1,@1,@1,@1];
   NSArray* demands = @[ demandA, demandB];
   NSArray* edges = @[
                      @[@35], //node 0 -> 35
                      @[@32], //node 1 -> 32
                      @[@17], //node 2 -> 17
                      @[@15], //node 3 -> 15
                      @[@17], //node 4 -> 17
                      @[@36], //node 5 -> 36
                      @[@35], //node 6 -> 35
                      @[@15], //node 7 -> 15
                      @[@36], //node 8 -> 36
                      @[@10,@30,@34,@14], //node 9 -> { 10 , 30 , 34 , 14 }
                      @[@9,@15,@20,@17], //node 10 -> { 9 , 15 , 20 , 17 }
                      @[@26,@27,@29,@30], //node 11 -> { 26 , 27 , 29 , 30 }
                      @[@19,@20], //node 12 ->  { 19 , 20 }
                      @[@19,@20], //node 13 ->  { 19 , 20 }
                      @[@9,@35,@20,@36], //node 14 ->  { 9, 35 , 20 , 36 }
                      @[@18,@3,@10,@7], //node 15 -> { 18 , 3 , 10 , 7}
                      @[@33,@18,@37,@29], //node 16 -> { 33 , 18 , 37 , 29 }
                      @[@10,@18,@4,@2], //node 17 -> { 10 , 18 , 4 , 2  }
                      @[@16,@17,@19,@15], //node 18 -> { 16 , 17 , 19 , 15 }
                      @[@33,@37,@12,@13,@18,@29], //node 19 -> { 33 , 37 , 12 , 13 , 18 , 29 }
                      @[@34,@10,@12,@13,@14,@30], //node 20 -> { 34 , 10 , 12 , 13 , 18 , 30 }
                      @[@32], //node 21 -> 32
                      @[@31], //node 22 -> 31
                      @[@31], //node 23 -> 31
                      @[@28], //node 24 -> 28
                      @[@28], //node 25 -> 28
                      @[@11], //node 26 -> 11
                      @[@11], //node 27 -> 11
                      @[@24,@25,@29,@30], //node 28 -> { 24 , 25 , 29 , 30 }
                      @[@11,@16,@19,@28], //node 29 -> { 11 , 16 , 19 , 28 }
                      @[@20,@11,@28,@9], //node 30 -> { 20 , 11 , 28 , 9 }
                      @[@33,@34,@22,@23], //node 31 -> { 33 , 34 , 22 , 23 }
                      @[@1,@34,@21,@33], //node 32 -> { 1 , 34 , 21 , 33 }
                      @[@32,@16,@19,@31], //node 33 -> { 32 , 16 , 19 , 31 }
                      @[@32,@9,@20,@31], //node 34 -> { 32 , 9 , 20 , 31 }
                      @[@0,@6,@37,@14], //node 35 ->  { 0 , 6 , 37 , 14 }
                      @[@8,@5,@14,@37], //node 36 ->  { 8 , 5 , 14 , 37 }
                      @[@16,@19,@35,@36]]; //node 37 ->  { 16 , 19 , 35 , 36}
   NSMutableArray* capacities = [[[NSMutableArray alloc] init] autorelease];
   for(ORInt i = 0; i < [edges count]; i++){
      [capacities addObject:[[[NSMutableArray alloc] init] autorelease]];
      for(id dst in edges[i]){
         [capacities[i] addObject:@(100)];
      }
   }
   NSArray* penality = @[ @[ @5, @5 ], @[ @5, @5 ], @[ @5, @5 ], @[ @5, @5 ], @[ @5, @5 ], @[ @5, @5 ], @[ @5, @5 ], @[ @5, @5 ], @[ @5, @5 ], @[ @5, @5 ], @[ @5, @5 ], @[ @5, @5 ], @[ @100, @5 ], @[ @100, @5 ], @[ @5, @5 ], @[ @5, @5 ], @[ @5, @5 ], @[ @5, @5 ], @[ @5, @5 ], @[ @5, @5 ], @[ @5, @5 ], @[ @5, @5 ], @[ @5, @5 ], @[ @5, @5 ], @[ @5, @5 ], @[ @5, @5 ], @[ @5, @5 ], @[ @5, @5 ], @[ @5, @5 ], @[ @5, @5 ], @[ @5, @5 ], @[ @5, @5 ], @[ @5, @5 ], @[ @5, @5 ], @[ @5, @5 ], @[ @5, @5 ], @[ @5, @5 ], @[ @5, @5 ]];
   NSArray* risk = @[ @[ @1, @1 ], @[ @1, @1 ], @[ @1, @1 ], @[ @1, @1 ], @[ @50, @1 ], @[ @1, @1 ], @[ @1, @1 ], @[ @1, @1 ], @[ @50, @1 ], @[ @1, @1 ], @[ @1, @1 ], @[ @1, @1 ], @[ @1, @1 ], @[ @1, @1 ], @[ @1, @1 ], @[ @1, @1 ], @[ @1, @1 ], @[ @1, @1 ], @[ @1, @1 ], @[ @1, @1 ], @[ @1, @1 ], @[ @1, @1 ], @[ @1, @1 ], @[ @1, @1 ], @[ @1, @1 ], @[ @1, @1 ], @[ @1, @1 ], @[ @1, @1 ], @[ @1, @1 ], @[ @1, @1 ], @[ @1, @1 ], @[ @1, @1 ], @[ @1, @1 ], @[ @1, @1 ], @[ @1, @1 ], @[ @1, @1 ], @[ @1, @1 ], @[ @1, @1 ]];
   return [[Network alloc] init:device memories:deviceMemory links:edges trafics:trafics flows:flows demands:demands penalities:penality risk:risk capacities:capacities];
}


int main(int argc, const char * argv[]) {
   @autoreleasepool {
      ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
      [args measureTime:^void(){
         Network* n = makeInstance();
         id<ORModel> functional = [ORFactory createModel];
         id<ORModel> security = [ORFactory createModel];
         ORInt piCost = 10;
         NSArray* fwCost = @[@5,@5,@5,@5,@1];
         id<ORIntRange> BINARIES = RANGE(functional, 0, 1);
         NSArray* trafics = [n trafics];
         NSMutableDictionary* allpath = [[NSMutableDictionary alloc] init];
         NSArray* tmp, *desiredFlows;
         id<ORIdArray> isflow = [ORFactory idArray:functional range:RANGE(functional,0,(ORInt)[trafics count] -1)];
         id<ORIdArray> flow = [ORFactory idArray:functional range:RANGE(functional,0,(ORInt)[trafics count] -1)];
         for(ORInt T = 0; T < [trafics count]; T++){
            desiredFlows = [n desiredFlows:T];
            isflow[T] = [ORFactory idArray:functional range:RANGE(functional, 0, ((ORInt)[desiredFlows count]) - 1 )];
            flow[T] = [ORFactory idArray:functional range:RANGE(functional, 0, ((ORInt)[desiredFlows count]) - 1 )];
            for(ORInt pair = 0; pair < [desiredFlows count]; pair++){
               ORInt src = [desiredFlows[pair][0] intValue];
               ORInt  dst = [desiredFlows[pair][1] intValue];
               tmp = [Network computePaths:n source:src dest:dst maxpaths:MAX_PATH];
               [allpath setObject:tmp forKey:desiredFlows[pair]];
               isflow[T][pair] = [ORFactory intVarArray:functional range:RANGE(functional, 0, (ORInt)[tmp count]- 1) domain:BINARIES names:[NSString stringWithFormat:@"isflow%@[%d]",trafics[T],pair]];
               flow[T][pair] = [ORFactory realVarArray:functional range:RANGE(functional, 0, (ORInt)[tmp count]- 1) low:0.0 up:100.0 names:[NSString stringWithFormat:@"flow%@[%d]",trafics[T],pair]];
            }
         }
         
         for(ORInt T = 0; T < [trafics count]; T++){
            for(ORInt i = 0; i < [isflow[T] count]; i++){
               for(ORInt j = 0; j < [isflow[T][i] count]; j++){
                  [functional add:[isflow[T][i][j] geq:flow[T][i][j]]];
               }
               [functional add:[ORFactory sumbool:functional array:isflow[T][i] eqi:1]];
            }
         }
         
         NSArray* ec = [n ec];
         NSArray* network = [n networkDevices];
         id<ORIdArray> equiv = [ORFactory idArray:functional range:RANGE(functional, 0, (ORInt)[ec count]-1)];
         for(ORInt i = 0; i < [ec count]; i++){
            equiv[i] = [ORFactory intVarArray:functional range:RANGE(functional, 0, (ORInt)([network count])-1)];
            for(ORInt j = 0; j < [network count];j++){
               //equiv should be a boolean variable and constraint related should be the max (OR)
               equiv[i][j] = [ORFactory intVar:functional domain:BINARIES name:[NSString stringWithFormat:@"equiv[%@,%@]",[n name:[ec[i] intValue]],[n name:[network[j] intValue]]]];
            }
         }
         
         id<ORRealVarArray> load = [ORFactory realVarArray:functional range:RANGE(functional, 0, (ORInt) [network count]- 1)];
         for(ORInt i = 0; i < [network count];i++){
            load[i] = [ORFactory realVar:functional name:[NSString stringWithFormat:@"load[%@]",[n name:[network[i] intValue]]]];
         }
         id<ORRealVar> loadSquareSum = [ORFactory realVar:functional name:@"loadSquaresSum"];
         
         //demand constraints
         NSArray* demand;
         for(ORInt T = 0; T < [trafics count]; T++){
            desiredFlows = [n desiredFlows:T];
            demand = [n demands:T];
            for(ORInt pair = 0; pair < [desiredFlows count]; pair++){
               ORInt d = [demand[pair] intValue];
               [functional add:[ORFactory sum:functional array:flow[T][pair] geqi:d]];
            }
         }
         
         NSMutableDictionary* P_edges = [[NSMutableDictionary alloc] init];
         mappingEP2(P_edges, allpath);
         
         NSMutableArray* P_nodes = [[NSMutableArray alloc] initWithCapacity:[n size]];
         mappingNP2(P_nodes, allpath, [n size]);
         
         //capacity flow
         NSArray* adj = nil;
         NSMutableArray* arcArr;
         for(ORInt nd = 0; nd < [n size]; nd++){
            adj = [n edges:nd];
            for(ORInt i = 0; i < [adj count]; i++){
               NSArray* key = @[@(nd), adj[i]];
               NSArray* af = [P_edges objectForKey:key];
               if([af count] > 0){
                  arcArr = [[NSMutableArray alloc] init];//ORFactory intVarArray:functional range:RANGE(functional, 0,sz)];
                  for(ORInt T = 0; T < [trafics count]; T++){
                     for(NSArray* indexFlow in af){
                        ORInt pair = (ORInt)[[n desiredFlows:T] indexOfObject:indexFlow[0]];
                        if(pair >= 0){
                           ORInt ind1 = [indexFlow[1] intValue];
                           [arcArr addObject: flow[T][pair][ind1]];
                        }
                     }
                  }
                  id<ORIntVarArray> arcFlow = (id<ORIntVarArray>)[ORFactory idArray:functional array:arcArr];
                  [functional add:[ORFactory sum:functional array:arcFlow leqi:[n capacity:nd to:[adj[i] intValue]]]];
                  [arcArr release];
               }
            }
         }
         
         NSMutableArray* l;
         id<ORDoubleArray> coefs;
         for (ORInt i = 0; i < [network count]; i++){
            ORInt nd = [network[i] intValue];
            l = [[NSMutableArray alloc] init];
            for(ORInt T = 0; T < [trafics count]; T++){
               for (ORInt path = 0; path < [P_nodes[nd] count]; path++){
                  ORInt pair = (ORInt)[[n desiredFlows:T] indexOfObject:P_nodes[nd][path][0]];
                  if(pair >= 0){
                     ORInt c = [P_nodes[nd][path][1] intValue];
                     [l addObject:flow[T][pair][c]];
                  }
               }
            }
            coefs = [ORFactory doubleArray:functional range:RANGE(functional, 0, (ORInt)[l count]) value:-1];
            // little trick to get the sum equals to load[index] rewrite the sum by passing the result in the other side
            [coefs set:1.0 at:(ORInt)[l count]];
            [l addObject:load[i]];
            [functional add:[ORFactory realSum:functional array:(id<ORRealVarArray>)[ORFactory idArray:functional array:l] coef:coefs eq:0.0]];
            [l release];
         }
         
         NSMutableArray* equivlist;
         for(ORInt i = 0; i < [ec count]; i++){
            ORInt node = [ec[i] intValue];
            for(ORInt j = 0; j < [network count]; j++){
               equivlist = [[NSMutableArray alloc] init];
               for(ORInt T = 0; T < [trafics count]; T++){
                  for(NSMutableArray* path in P_nodes[node]){
                     ORInt ind1 = [path[1] intValue];
                     if([[allpath objectForKey:path[0]][ind1] containsObject:network[j]]){
                        ORInt ind0 = (ORInt)[[n desiredFlows:T] indexOfObject:path[0]];
                        if(ind0 >= 0)
                           [equivlist addObject:isflow[T][ind0][ind1]];
                     }
                  }
               }
               if([equivlist count] >= 1){
                  id<ORIntVarArray> equivArray = (id<ORIntVarArray>)[ORFactory idArray:functional array:equivlist];
                  [functional add:[ORFactory clause:functional over:equivArray equal:equiv[i][j]]];
               }
               [equivlist release];
            }
         }
         
         [functional add:[ORFactory sumSquare:functional array:load eq:loadSquareSum]];
         
         //sum flow(t)(p) * len(p)
         id<ORExpr> e = nil;
         id<ORExpr> e_aux = nil;
         for(ORInt T = 0; T < [trafics count]; T++){
            desiredFlows = [n desiredFlows:T];
            for(ORInt pair = 0; pair < [desiredFlows count]; pair++){
               e_aux = Sum(functional, p, RANGE(functional, 0,(ORInt)[flow[T][pair] count]-1),[flow[T][pair][p] mul:@([[allpath objectForKey:desiredFlows[pair]][p] count] - 1)]);
               e = (e == nil) ? e_aux : [e plus:e_aux];
            }
         }
         [functional minimize: [[e mul:@(alpha0)] plus:[loadSquareSum mul:@(alpha2)]]];
         
         id<MIPProgram> mip = [ORFactory createMIPProgram: functional];
         OROutcome status = [mip solve];
         [mip printModelToFile:"/Users/zitoun/Desktop/functional.lp"];
         [mip printModelToFile:"/Users/zitoun/Desktop/functional.sol"];
         ORInt overlapLimit = 0;
         ORInt overlapCurrent = 0;
         ORInt nbBadCuts = 0;
         ORBool gone = NO;
         
         if(status == ORerror)  @throw [[ORExecutionError alloc] initORExecutionError:"Error in the model"];
         
         while(status == ORinfeasible && !gone){
            printf("FUNCTIONAL LAYER WAS INFEASIBLE AFTER CUT\n");
            printf("overlapLimit = %d\n", overlapLimit);
            printf("overlapCurrent = %d\n", overlapCurrent);
            overlapLimit++;
            if(overlapLimit < overlapCurrent){
               
            }else if (overlapLimit == overlapCurrent){
               printf("Removing currentcut as a cut b/c infeasible.");
               nbBadCuts++;
               gone = YES;
            }
            mip = [ORFactory createMIPProgram: functional];
            status = [mip solve];
         }
         
         if(gone){
            printf("Functional layer is infeasible.\n");
         }else{
            printf("-----Functional layer-----\n");
            
            id<ORObjectiveValue> obj = [mip objectiveValue];
            ORDouble objv = [obj doubleValue];
            printf("Objective value is :%f\n",objv);
            printf("---------------------------\n");
            
            NSMutableArray* flowPaths = [[NSMutableArray alloc] init];
            NSMutableArray* penalityPath = [[NSMutableArray alloc] init];
            NSMutableArray* flow2All = [[NSMutableArray alloc] init];
            for(ORInt T = 0; T < [trafics count]; T++){
               desiredFlows = [n desiredFlows:T];
               [penalityPath addObject:[[NSMutableArray alloc] init]];
               [flowPaths addObject:[[NSMutableArray alloc] init]];
               [flow2All addObject:[[NSMutableArray alloc] init]];
               for (ORInt pair = 0; pair < [isflow[T] count]; pair++) {
                  for (ORInt j = 0; j < [isflow[T][pair] count]; j++) {
                     ORInt v = [mip intValue:isflow[T][pair][j]];
                     if(v){
                        [flow2All[T] addObject:@[@(pair),@(j)]];
                        [flowPaths[T] addObject:[allpath objectForKey:desiredFlows[pair]][j]];
                        ORInt n0 = [desiredFlows[pair][0] intValue];
                        ORInt n1 = [desiredFlows[pair][1] intValue];
                        [penalityPath[T] addObject:@(max([n penality:T for:n0], [n penality:T for:n1]))];
                     }
                  }
               }
            }
            
            NSMutableArray* flowRisk = [[NSMutableArray alloc] initWithCapacity:[trafics count]];
            for(ORInt T = 0; T < [trafics count]; T++){
               [flowRisk addObject: [[NSMutableArray alloc] init]];
               riskCacl(flowRisk[T], flowPaths[T], [n risk], T, [n size]);
            }
            
            id<ORIntRange> BINARY = RANGE(security, 0, 1);
            id<ORIntRange> NODES_R = RANGE(security, 0, (ORInt)[n size] - 1);
            id<ORIntRange> TRAFIC_R = RANGE(security, 0, (ORInt)[[n trafics] count]);
            id<ORIdArray> PATHS_R = [ORFactory idArray:security range:TRAFIC_R];
            id<ORIdArray> firewall = [ORFactory idArray:security range:TRAFIC_R];
            id<ORIdArray> fwOR = [ORFactory idArray:security range:TRAFIC_R];
            id<ORIdArray> fwOnPath = [ORFactory idArray:security range:TRAFIC_R];
            id<ORIdArray> riskFactor = [ORFactory idArray:security range:TRAFIC_R];
            id<ORIdArray> riskMINfw = [ORFactory idArray:security range:TRAFIC_R];
            id<ORIdArray> riskMINpi = [ORFactory idArray:security range:TRAFIC_R];
            id<ORIdArray> firewallOther = [ORFactory idArray:security range:NODES_R];
            id<ORIdArray> pi = [ORFactory idArray:security range:NODES_R];
            id<ORExpr> c = [ORFactory double:security value:1.0];
            
            for(ORInt T = 0; T < [trafics count]; T++){
               PATHS_R[T] = RANGE(security, 0, (ORInt)[flowPaths[T] count] - 1);
               firewall[T] = [ORFactory idArray:security range:NODES_R];
               fwOR[T] = [ORFactory idArray:security range:NODES_R];
               fwOnPath[T] = [ORFactory intVarArray:security range:PATHS_R[T] domain:BINARY names:[NSString stringWithFormat:@"fwOnPath%@",trafics[T]]];
               riskFactor[T] = [ORFactory realVarArray:security range:PATHS_R[T] low:0. up:1. names:[NSString stringWithFormat:@"riskFactor%@",trafics[T]]];
               riskMINfw[T] = [ORFactory idArray:security range:PATHS_R[T]];
               riskMINpi[T] = [ORFactory idArray:security range:PATHS_R[T]];
               for(ORInt j = 0; j < [n size];j++){
                  firewall[T][j] = [ORFactory intVar:security domain:BINARY name:[NSString stringWithFormat:@"firewall%@[%@]",trafics[T],[n name:j]]];
                  fwOR[T][j] = [ORFactory intVar:security domain:BINARY name:[NSString stringWithFormat:@"fwOR%@[%@]",trafics[T],[n name:j]]];
               }
            }
            
            for(ORInt j = 0; j < [n size];j++){
               pi[j] = [ORFactory intVar:security domain:BINARY name:[NSString stringWithFormat:@"pi[%@]",[n name:j]]];
               firewallOther[j] = [ORFactory intVar:security domain:BINARY name:[NSString stringWithFormat:@"firewall*[%@]",[n name:j]]];
            }
            
            for(ORInt T = 0; T < [trafics count]; T++){
               for(ORInt i = 0; i < [flowPaths[T] count]; i++){
                  riskMINfw[T][i] = [ORFactory idArray:security range:RANGE(security, 0, (ORInt)[flowPaths[T] count])];
                  riskMINpi[T][i] = [ORFactory idArray:security range:RANGE(security, 0, (ORInt)[flowPaths[T] count])];
                  for(ORInt j = 0; j < [flowPaths[T][i] count]; j++){
                     ORInt nd = [flowPaths[T][i][j] intValue];
                     riskMINfw[T][i][j] = [ORFactory realVar:security low:0. up:1. name:[NSString stringWithFormat:@"riskMINfw%@[%d][%@]",trafics[T],i,[n name:nd]]];
                     riskMINpi[T][i][j] = [ORFactory realVar:security low:0. up:1. name:[NSString stringWithFormat:@"riskMINpi%@[%d][%@]",trafics[T],i,[n name:nd]]];
                  }
               }
               
               for (ORInt p = 0; p < [flowPaths[T] count]; p++){
                  ORInt pos = 1;
                  NSMutableArray* fwOnPathArr = [[NSMutableArray alloc] init];
                  NSMutableArray* riskFactorArr = [[NSMutableArray alloc] init];
                  for(ORInt i = 0; i < [flowPaths[T][p] count]; i++){
                     ORInt nd = [flowPaths[T][p][i] intValue];
                     if([n isNetworkDevice:nd]){
                        [fwOnPathArr addObject: firewallOther[nd]];
                        [fwOnPathArr addObject: firewall[T][nd]];
                        [riskFactorArr addObject: riskMINfw[T][p][i]];
                        [riskFactorArr addObject: riskMINpi[T][p][i]];
                        ORDouble f = pow(0.5, pos++);
                        [security add:[[c sub:[fwOR[T][nd] mul:@(f)]] eq:riskMINfw[T][p][i]]];
                        [security add:[[c sub:[[fwOR[T][nd] mul:@(f)] mul:@(0.1)]] eq:riskMINpi[T][p][i]]];
                     }
                  }
                  id<ORIntVarArray> fwOnPathAr = (id<ORIntVarArray>)[ORFactory idArray:security array:fwOnPathArr];
                  id<ORRealVarArray> riskFactorAr = (id<ORRealVarArray>)[ORFactory idArray:security array:riskFactorArr];
                  [fwOnPathArr release];
                  [riskFactorArr release];
                  [security add:[ORFactory clause:security over:fwOnPathAr equal:fwOnPath[T][p]]];
                  [security add:[ORFactory realMin:security array:riskFactorAr eq:riskFactor[T][p]]];
               }
               
               for (ORInt nd = 0; nd < [fwOR[T] count]; nd++) {
                  id<ORIntVarArray> arr = [ORFactory intVarArray:security range:BINARY];
                  arr[0] = firewall[T][nd];
                  arr[1] = firewallOther[nd];
                  [security add:[ORFactory clause:security over:arr equal:fwOR[T][nd]]];
               }
               
            }
            
            //respect device memory capacity
            for(ORInt i = 0; i < [network count]; i++){
               ORInt nd = [network[i] intValue];
               id<ORExpr> fe = [firewallOther[nd] mul:[fwCost lastObject]];
               for(ORInt T = 0; T < [trafics count]; T++)
                  fe = [fe plus:[firewall[T][nd] mul:fwCost[T]]];
               fe = [fe plus:[pi[nd] mul:@(piCost)]];
               [security add:[fe leq:@([n memory:nd])]];
            }
            
            //objective
            id<ORExpr> piNum = Sum(security,nd,pi.range,([n isNetworkDevice:nd])?pi[nd]:@(0));
            id<ORExpr> fwNum = nil;
            id<ORExpr> goodTrafficBlocked = nil;
            id<ORExpr> networkRisk = nil;
            id<ORExpr> aux;
            for(ORInt T = 0; T < [trafics count]; T++){
               aux = Sum(security,nd, NODES_R, ([n isNetworkDevice:nd])?firewall[T][nd]:@(0));
               fwNum = (fwNum == nil) ? aux : [fwNum plus:aux];
               aux = [ORFactory sum:security over:PATHS_R[T] suchThat:nil of:^id<ORExpr>(ORInt p){
                  ORInt ind0 = [flow2All[T][p][0] intValue];
                  ORInt ind1 = [flow2All[T][p][1] intValue];
                  return (id<ORExpr>)([[fwOnPath[T][p] mul:@([mip doubleValue:flow[T][ind0][ind1]])] mul:penalityPath[T][p]]);
               }];
               goodTrafficBlocked = (goodTrafficBlocked == nil) ? aux : [goodTrafficBlocked plus:aux];
               aux = Sum(security,p,PATHS_R[T],[riskFactor[T][p] mul:flowRisk[T][p]]);
               networkRisk = (networkRisk == nil) ? aux : [networkRisk plus:aux];
            }
            id<ORExpr> simplicityMetric = [piNum plus:[fwNum mul:@(10)]];
            id<ORExpr> flowReduction = Sum(security,n,load.range,[pi[[network[n] intValue]] mul:@([mip doubleValue:load[n]])]);
            [security minimize: [[[[simplicityMetric mul:@(beta0)] plus:[flowReduction mul:@(beta1)]] plus:[goodTrafficBlocked mul:@(beta2)]]                               plus:[networkRisk mul:@(beta3)]]];
            id<MIPProgram> mipSecurity = [ORFactory createMIPProgram: security];
            status = [mipSecurity solve];
            [mipSecurity printModelToFile:"/Users/zitoun/Desktop/security.lp"];
            if(status == ORerror)
               printf("error in mip model\n");
            
            [n release];
            
         }
      }];
      
   }
   return 0;
}
