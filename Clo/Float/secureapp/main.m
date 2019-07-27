#import "Datastruct.h"

//[hzi] for now I just decompose the different traffic as separate structure,
//I should aggregate those structure

int main(int argc, const char * argv[]) {
   @autoreleasepool {
      //-----------DEFINITION OF THE INSTANCE----------//
      NSArray* device = @[@"h8",  @"h9",  @"h2",  @"h3",  @"h1",  @"h6",  @"h7",  @"h4",  @"h5",  @"sc1",  @"sa5",  @"sa20",  @"g2",  @"g1",  @"sa9",  @"sa8",  @"sc4",  @"sa7",  @"sa6",  @"sc3",  @"sc2",  @"h10",  @"h11",  @"h12",  @"h13",  @"h14",  @"h15",  @"h16",  @"sa19",  @"sa18",  @"sa17",  @"sa16",  @"sa15",  @"sa14",  @"sa13",  @"sa12",  @"sa11", @"sa10"];
      NSMutableDictionary* device2ID = [[NSMutableDictionary alloc] init];
      NSMutableArray* deviceMemory = [[NSMutableArray alloc] init];
      for(ORInt i = 0; i < [device count];i++){
         [device2ID setObject:@(i) forKey:device[i]];
         [deviceMemory addObject:@100];
      }
      NSArray* flowWithA = @[@[@21,@1],@[@7,@3],@[@12,@27],@[@2,@4],@[@3,@7],@[@13,@7],@[@6,@0],@[@13,@4],@[@4,@13],@[@7,@13],@[@23,@22],@[@22,@23],@[@23,@12],@[@13,@0],@[@1,@21],@[@27,@12],@[@13,@8],@[@8,@13],@[@4,@2],@[@0,@13],@[@8,@5],@[@24,@12],@[@5,@8],@[@0,@6],@[@27,@26],@[@12,@23],@[@1,@12],@[@26,@27],@[@24,@25],@[@12,@1],@[@25,@24],@[@12,@24]];
      NSArray* flowWithB = @[@[@7,@3],@[@24,@25],@[@8,@5],@[@2,@4],@[@25,@2],@[@2,@21],@[@6,@3],@[@27,@26],@[@22,@23],@[@26,@27],@[@2,@5],@[@23,@22],@[@1,@21],@[@22,@3],@[@3,@7],@[@26,@3],@[@0,@6],@[@3,@6],@[@2,@25],@[@5,@8],@[@6,@0],@[@4,@2],@[@3,@22],@[@5,@2],@[@3,@26],@[@25,@24],@[@21,@1],@[@21,@2]];
      NSMutableDictionary* demandA = [[NSMutableDictionary alloc] initWithCapacity:[flowWithA count]];
      NSMutableDictionary* demandB = [[NSMutableDictionary alloc] initWithCapacity:[flowWithB count]];
      for(NSArray* flow in flowWithA){
         [demandA setObject:@(1) forKey:flow];
      }
      for(NSArray* flow in flowWithB){
         [demandB setObject:@(1) forKey:flow];
      }
      Graph *g = [[Graph alloc] initGraph];
      [toadd addObjectAdjacency:@[@35]]; //node 0 -> 35
      [toadd addObjectAdjacency:@[@32]]; //node 1 -> 32
      [toadd addObjectAdjacency:@[@17]]; //node 2 -> 17
      [toadd addObjectAdjacency:@[@15]]; //node 3 -> 15
      [toadd addObjectAdjacency:@[@17]]; //node 4 -> 17
      [toadd addObjectAdjacency:@[@36]]; //node 5 -> 36
      [toadd addObjectAdjacency:@[@35]]; //node 6 -> 35
      [toadd addObjectAdjacency:@[@15]]; //node 7 -> 15
      [toadd addObjectAdjacency:@[@36]]; //node 8 -> 36
      [toadd addObjectAdjacency:@[@10,@30,@34,@14]]; //node 9 -> { 10 , 30 , 34 , 14 }
      [toadd addObjectAdjacency:@[@9,@15,@20,@17]]; //node 10 -> { 9 , 15 , 20 , 17 }
      [toadd addObjectAdjacency:@[@26,@27,@29,@30]]; //node 11 -> { 26 , 27 , 29 , 30 }
      [toadd addObjectAdjacency:@[@19,@20]]; //node 12 ->  { 19 , 20 }
      [toadd addObjectAdjacency:@[@19,@20]]; //node 13 ->  { 19 , 20 }
      [toadd addObjectAdjacency:@[@9,@35,@20,@36]]; //node 14 ->  { 9, 35 , 20 , 36 }
      [toadd addObjectAdjacency:@[@18,@3,@10,@7]]; //node 15 -> { 18 , 3 , 10 , 7}
      [toadd addObjectAdjacency:@[@33,@18,@37,@29]]; //node 16 -> { 33 , 18 , 37 , 29 }
      [toadd addObjectAdjacency:@[@10,@18,@4,@2]]; //node 17 -> { 10 , 18 , 4 , 2  }
      [toadd addObjectAdjacency:@[@16,@17,@19,@15]]; //node 18 -> { 16 , 17 , 19 , 15 }
      [toadd addObjectAdjacency:@[@33,@37,@12,@13,@18,@29]]; //node 19 -> { 33 , 37 , 12 , 13 , 18 , 29 }
      [toadd addObjectAdjacency:@[@34,@10,@12,@13,@14,@30]]; //node 20 -> { 34 , 10 , 12 , 13 , 18 , 30 }
      [toadd addObjectAdjacency:@[@32]]; //node 21 -> 32
      [toadd addObjectAdjacency:@[@31]]; //node 22 -> 31
      [toadd addObjectAdjacency:@[@31]]; //node 23 -> 31
      [toadd addObjectAdjacency:@[@28]]; //node 24 -> 28
      [toadd addObjectAdjacency:@[@28]]; //node 25 -> 28
      [toadd addObjectAdjacency:@[@11]]; //node 26 -> 11
      [toadd addObjectAdjacency:@[@11]]; //node 27 -> 11
      [toadd addObjectAdjacency:@[@24,@25,@29,@30]]; //node 28 -> { 24 , 25 , 29 , 30 }
      [toadd addObjectAdjacency:@[@11,@16,@19,@28]]; //node 29 -> { 11 , 16 , 19 , 28 }
      [toadd addObjectAdjacency:@[@20,@11,@28,@9]]; //node 30 -> { 20 , 11 , 28 , 9 }
      [toadd addObjectAdjacency:@[@33,@34,@22,@23]]; //node 31 -> { 33 , 34 , 22 , 23 }
      [toadd addObjectAdjacency:@[@1,@34,@21,@33]]; //node 32 -> { 1 , 34 , 21 , 33 }
      [toadd addObjectAdjacency:@[@32,@16,@19,@31]]; //node 33 -> { 32 , 16 , 19 , 31 }
      [toadd addObjectAdjacency:@[@32,@9,@20,@31]]; //node 34 -> { 32 , 9 , 20 , 31 }
      [toadd addObjectAdjacency:@[@0,@6,@37,@14]]; //node 35 ->  { 0 , 6 , 37 , 14 }
      [toadd addObjectAdjacency:@[@8,@5,@14,@37]]; //node 36 ->  { 8 , 5 , 14 , 37 }
      [toadd addObjectAdjacency:@[@16,@19,@35,@36]]; //node 37 ->  { 16 , 19 , 35 , 36}
      //        allpath should be computed for each pair in the desiredFlows
      //        if we compute 4-13, it's easy to get 13-4 because the graph is without direction just reverse the 4-13 it's enought
      NSArray* desiredFlowsOfA = @[@4,@13,@13,@4,@7,@13,@13,@7,@8,@13,@13,@8,@0,@13,@13,@0,@1,@12,@12,@1,@12,@23,@23,@12,@12,@24,@24,@12,@12,@27,@27,@12,@2,@4,@4,@2,@3,@7,@7,@3,@5,@8,@8,@5,@0,@6,@6,@0,@1,@21,@21,@1,@22,@23,@23,@22,@24,@25,@25,@24,@26,@27,@27,@26];
      NSArray* desiredFlowsOfB = @[@2,@4,@4,@2,@3,@7,@7,@3,@5,@8,@8,@5,@0,@6,@6,@0,@1,@21,@21,@1,@22,@23,@23,@22,@24,@25,@25,@24,@26,@27,@27,@26,@2,@5,@5,@2,@2,@21,@21,@2,@2,@25,@25,@2,@3,@6,@6,@3,@3,@22,@22,@3,@3,@26,@26,@3];
      
        NSArray* penality = @[ @[ @5, @5 ], @[ @5, @5 ], @[ @5, @5 ], @[ @5, @5 ], @[ @5, @5 ], @[ @5, @5 ], @[ @5, @5 ], @[ @5, @5 ], @[ @5, @5 ], @[ @5, @5 ], @[ @5, @5 ], @[ @5, @5 ], @[ @100, @5 ], @[ @100, @5 ], @[ @5, @5 ], @[ @5, @5 ], @[ @5, @5 ], @[ @5, @5 ], @[ @5, @5 ], @[ @5, @5 ], @[ @5, @5 ], @[ @5, @5 ], @[ @5, @5 ], @[ @5, @5 ], @[ @5, @5 ], @[ @5, @5 ], @[ @5, @5 ], @[ @5, @5 ], @[ @5, @5 ], @[ @5, @5 ], @[ @5, @5 ], @[ @5, @5 ], @[ @5, @5 ], @[ @5, @5 ], @[ @5, @5 ], @[ @5, @5 ], @[ @5, @5 ], @[ @5, @5 ] ];
      
      NSArray* risk = @[ @[ @1, @1 ], @[ @1, @1 ], @[ @1, @1 ], @[ @1, @1 ], @[ @50, @1 ], @[ @1, @1 ], @[ @1, @1 ], @[ @1, @1 ], @[ @50, @1 ], @[ @1, @1 ], @[ @1, @1 ], @[ @1, @1 ], @[ @1, @1 ], @[ @1, @1 ], @[ @1, @1 ], @[ @1, @1 ], @[ @1, @1 ], @[ @1, @1 ], @[ @1, @1 ], @[ @1, @1 ], @[ @1, @1 ], @[ @1, @1 ], @[ @1, @1 ], @[ @1, @1 ], @[ @1, @1 ], @[ @1, @1 ], @[ @1, @1 ], @[ @1, @1 ], @[ @1, @1 ], @[ @1, @1 ], @[ @1, @1 ], @[ @1, @1 ], @[ @1, @1 ], @[ @1, @1 ], @[ @1, @1 ], @[ @1, @1 ], @[ @1, @1 ], @[ @1, @1 ] ];
      //----------END OF THE INSTANCE-----------//
      NSMutableArray* allpathA = [[NSMutableArray alloc] init];
      NSMutableArray* allpathB = [[NSMutableArray alloc] init];
      NSArray* ec = [Graph getEC:device with:device2ID];
      NSArray* network = [Graph getNetworkDevice:device with:device2ID];
      
      
      ORInt src;
      ORInt dst;
      NSMutableArray* tmp;
      id<ORModel> model = [ORFactory createModel];
      ORInt i = 0;
      //Still need to deal with inverse path D-S
      id<ORIdArray> isflowA = [ORFactory idArray:model range:RANGE(model, 0, ((ORInt)[desiredFlowsOfA count]/2) - 1 )];
      id<ORIdArray> flowA = [ORFactory idArray:model range:RANGE(model, 0, ((ORInt)[desiredFlowsOfA count]/2) - 1)];
      for(ORInt s = 0,d = s + 1; d < [desiredFlowsOfA count]; s+=2, d+=2){
         src = [desiredFlowsOfA[s] intValue];
         dst = [desiredFlowsOfA[d] intValue];
         tmp = [Graph bfs:g source:src dest:dst maxpaths:MAX_PATH];
         [allpathA addObject:tmp];
         isflowA[i] = [ORFactory intVarArray:model range:RANGE(model, 0, (ORInt)[tmp count]- 1) domain:RANGE(model, 0, 1) names:[NSString stringWithFormat:@"isflowA[%d]",i]];
         flowA[i] = [ORFactory realVarArray:model range:RANGE(model, 0, (ORInt)[tmp count]- 1) low:0.0 up:100.0 names:[NSString stringWithFormat:@"flow[0][%d]",i]];
         i++;
      }
      
      i = 0;
      ORInt nbPathB = 0;
      id<ORIdArray> isflowB = [ORFactory idArray:model range:RANGE(model, 0, ((ORInt)[desiredFlowsOfB count]/2) - 1)];
      id<ORIdArray> flowB = [ORFactory idArray:model range:RANGE(model, 0, ((ORInt)[desiredFlowsOfB count]/2) - 1)];
      for(ORInt s = 0,d = s + 1; d < [desiredFlowsOfB count]; s+=2, d+=2){
         src = [desiredFlowsOfB[s] intValue];
         dst = [desiredFlowsOfB[d] intValue];
         tmp = [Graph bfs:g source:src dest:dst maxpaths:MAX_PATH];
         nbPathB += [tmp count] * 2;
         [allpathB addObject:tmp];
         isflowB[i] = [ORFactory intVarArray:model range:RANGE(model, 0, (ORInt)[tmp count]- 1) domain:RANGE(model, 0, 1) names:[NSString stringWithFormat:@"isflowB[%d]",i]];
         flowB[i] = [ORFactory realVarArray:model range:RANGE(model, 0, (ORInt)[tmp count]- 1) low:0.0 up:100.0 names:[NSString stringWithFormat:@"flow[1][%d]",i]];
         i++;
      }
      
      
      for(ORInt i = 0; i < [isflowA count]; i++){
         for(ORInt j = 0; j < [isflowA[i] count]; j++){
            [model add:[isflowA[i][j] geq:flowA[i][j]]];
         }
         [model add:[ORFactory sumbool:model array:isflowA[i] eqi:1]];
      }
      
      for(ORInt i = 0; i < [isflowB count]; i++){
         for(ORInt j = 0; j < [isflowB[i] count]; j++){
            [model add:[isflowB[i][j] geq:flowB[i][j]]];
         }
         [model add:[ORFactory sumbool:model array:isflowB[i] eqi:1]];
      }
      
      
      id<ORIdArray> equiv = [ORFactory idArray:model range:RANGE(model, 0, (ORInt)([ec count])-1)];
   
      for(ORInt i = 0; i < [ec count]; i++){
         equiv[i] = [ORFactory intVarArray:model range:RANGE(model, 0, (ORInt)([network count])-1)];
         for(ORInt j = 0; j < [network count];j++){
            //equiv should be a boolean variable and constraint related should be the max (OR)
            equiv[i][j] = [ORFactory intVar:model domain:RANGE(model, 0, 1) name:[NSString stringWithFormat:@"equiv[%@,%@]",device[[ec[i] intValue]],device[[network[j] intValue]]]];
         }
      }
      id<ORRealVarArray> load = [ORFactory realVarArray:model range:RANGE(model, 0, (ORInt) [network count]- 1)];
      for(ORInt i = 0; i < [network count];i++){
         printf("%s\n",[device[[network[i] intValue]] UTF8String]);
         load[i] = [ORFactory realVar:model name:[NSString stringWithFormat:@"load[%@]",device[[network[i] intValue]]]];
      }
      id<ORRealVar> loadSquareSum = [ORFactory realVar:model name:@"loadSquaresSum"];
      
      //demand constraints
      //trafic A
      for(ORInt s = 0, d = s + 1; d < [desiredFlowsOfA count]; s+=2,d+=2){
         ORInt demand = [[demandA objectForKey:@[desiredFlowsOfA[s],desiredFlowsOfA[d]]] intValue];
         [model add:[ORFactory sum:model array:flowA[s/2] geqi:demand]];
      }
      //demand constraints
      //trafic B
      for(ORInt s = 0, d = s + 1; d < [desiredFlowsOfB count]; s+=2,d+=2){
         ORInt demand = [[demandB objectForKey:@[desiredFlowsOfB[s],desiredFlowsOfB[d]]] intValue];
         [model add:[ORFactory sum:model array:flowB[s/2] geqi:demand]];
      }
      
      NSMutableDictionary* P_edgesA = [[NSMutableDictionary alloc] init];
      NSMutableDictionary* P_edgesB = [[NSMutableDictionary alloc] init];
      
      mappingEP(P_edgesA, allpathA);
      mappingEP(P_edgesB, allpathB);
      
      //        Just an array to get all paths where a node belong Ex: P_nodesA[0] -> [[ind0,ind1],[],[]] will return an array of array of indices each array of indices correspond to a path in allPath[ind0][ind1]
      NSMutableArray* P_nodesA = [[NSMutableArray alloc] initWithCapacity:[g size]];
      NSMutableArray* P_nodesB = [[NSMutableArray alloc] initWithCapacity:[g size]];
      mappingNP(P_nodesA, allpathA, [g size]);
      mappingNP(P_nodesB, allpathB, [g size]);
      
      //capacity flow
      NSMutableArray* adj = nil;
      id<ORIntVarArray> arcFlow;
      ORInt sz = 0;
      for(ORInt n = 0; n < [g size]; n++){
         adj = [g edges:n];
         for(ORInt i = 0; i < [adj count]; i++){
            NSArray* key = @[@(n), adj[i]];
            NSArray* af = [P_edgesA objectForKey:key];
            NSArray* bf = [P_edgesB objectForKey:key];
            ORInt index = 0;
            sz = (ORInt)([af count]+[bf count] - 1);
            if(sz > 0){
               arcFlow = [ORFactory intVarArray:model range:RANGE(model, 0,sz)];
               for(NSArray* indexFlow in af){
                  ORInt ind0 = [indexFlow[0] intValue];
                  ORInt ind1 = [indexFlow[1] intValue];
                  arcFlow[index++] = flowA[ind0][ind1];
               }
               for(NSArray* indexFlow in bf){
                  ORInt ind0 = [indexFlow[0] intValue];
                  ORInt ind1 = [indexFlow[1] intValue];
                  arcFlow[index++] = flowB[ind0][ind1];
               }
               [model add:[ORFactory sum:model array:arcFlow leqi:100]];
            }
         }
      }
      
      NSMutableArray* l;
      id<ORDoubleArray> coefs;
      for (ORInt i = 0; i < [network count]; i++){
         ORInt n = [network[i] intValue];
         l = [[NSMutableArray alloc] init];
         for (ORInt path = 0; path < [P_nodesA[n] count]; path++){
            ORInt r = [P_nodesA[n][path][0] intValue];
            ORInt c = [P_nodesA[n][path][1] intValue];
            [l addObject:flowA[r][c]];
         }
         for (ORInt path = 0; path < [P_nodesB[n] count]; path++){
            ORInt r = [P_nodesB[n][path][0] intValue];
            ORInt c = [P_nodesB[n][path][1] intValue];
            [l addObject:flowB[r][c]];
         }
         coefs = [ORFactory doubleArray:model range:RANGE(model, 0, (ORInt)[l count]) value:-1];
         // little trick to get the sum equals to load[index] rewrite the sum by passing the result in the other side
         [coefs set:1.0 at:(ORInt)[l count]];
         [l addObject:load[i]];
         [model add:[ORFactory realSum:model array:(id<ORRealVarArray>)[ORFactory idArray:model array:l] coef:coefs eq:0.0]];
         [l release];
      }
      
      NSMutableArray* equivlist;
      for(ORInt i = 0; i < [ec count]; i++){
         ORInt node = [ec[i] intValue];
         for(ORInt j = 0; j < [network count]; j++){
            equivlist = [[NSMutableArray alloc] init];
            for(NSMutableArray* path in P_nodesA[node]){
               ORInt ind0 = [path[0] intValue];
               ORInt ind1 = [path[1] intValue];
               if([allpathA[ind0][ind1] containsObject:network[j]]){
                  [equivlist addObject:isflowA[ind0][ind1]];
               }
            }
            for(NSMutableArray* path in P_nodesB[node]){
               ORInt ind0 = [path[0] intValue];
               ORInt ind1 = [path[1] intValue];
               if([allpathB[ind0][ind1] containsObject:network[j]])
                  [equivlist addObject:isflowB[ind0][ind1]];
            }
            if([equivlist count] >= 1){
               id<ORIntVarArray> equivArray = (id<ORIntVarArray>)[ORFactory idArray:model array:equivlist];
               [model add:[ORFactory clause:model over:equivArray equal:equiv[i][j]]];
            }
            [equivlist release];
         }
      }
      
      [model add:[ORFactory sumSquare:model array:load eq:loadSquareSum]];
      
      id<ORExpr> e = Sum(model, p, RANGE(model, 0, (ORInt)[flowA[0] count]-1),[flowA[0][p] mul:@([allpathA[0][p] count] - 1)]);
      for(ORInt i = 1; i < [flowA count]; i++){
         e = [e plus:Sum(model, p, RANGE(model, 0, (ORInt)[flowA[i] count]-1),[flowA[i][p] mul:@([allpathA[i][p] count] - 1)])];
      }
      for(ORInt i = 0; i < [flowB count]; i++){
         e = [e plus:Sum(model, p, RANGE(model, 0, (ORInt)[flowB[i] count]-1),[flowB[i][p] mul:@([allpathB[i][p] count] - 1)])];
      }

      [model minimize: [[e mul:@(alpha0)] plus:[loadSquareSum mul:@(alpha2)]]];
      
      id<MIPProgram> mip = [ORFactory createMIPProgram: model];
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
         mip = [ORFactory createMIPProgram: model];
         status = [mip solve];
      }
      
      if(gone){
         printf("Functional layer is infeasible.\n");
      }else{
         printf("-----Functional layer-----\n");
         for (ORInt i = 0; i < [isflowB count]; i++) {
            for (ORInt j = 0; j < [isflowB[i] count]; j++) {
               if([mip doubleValue:flowB[i][j]])
                  printf("[functional add:[%s eq:%f]];\n",[[flowB[i][j] prettyname] UTF8String],[mip doubleValue:flowB[i][j]]);
            }
         }
         id<ORObjectiveValue> obj = [mip objectiveValue];
         ORDouble objv = [obj doubleValue];
         printf("Objective value is :%f\n",objv);
         printf("---------------------------\n");
         
         id<ORModel> security = [ORFactory createModel];
         
         ORInt piCost = 10;
         NSArray* fwCost = @[@5,@5,@5,@5,@1];
         
         NSMutableArray* flowPathsA = [[NSMutableArray alloc] init];
         NSMutableArray* flowPathsB = [[NSMutableArray alloc] init];
         NSMutableArray* penalityPathA = [[NSMutableArray alloc] init];
         NSMutableArray* penalityPathB = [[NSMutableArray alloc] init];
         NSMutableArray* flow2AllA = [[NSMutableArray alloc] init];
         NSMutableArray* flow2AllB = [[NSMutableArray alloc] init];
         for (ORInt i = 0; i < [isflowA count]; i++) {
            for (ORInt j = 0; j < [isflowA[i] count]; j++) {
               ORInt v = [mip intValue:isflowA[i][j]];
               if(v){
                  [flow2AllA addObject:@[@(i),@(j)]];
                  [flowPathsA addObject:allpathA[i][j]];
                  ORInt n0 = [allpathA[i][j][0] intValue];
                  ORInt n1 = [[allpathA[i][j] lastObject] intValue];
                  [penalityPathA addObject:@(max([penality[n0][0] intValue], [penality[n1][0] intValue]))];
               }
            }
         }
         for (ORInt i = 0; i < [isflowB count]; i++) {
            for (ORInt j = 0; j < [isflowB[i] count]; j++) {
               ORInt v = [mip intValue:isflowB[i][j]];
               if(v){
                  [flow2AllB addObject:@[@(i),@(j)]];
                  [flowPathsB addObject:allpathB[i][j]];
                  ORInt n0 = [allpathB[i][j][0] intValue];
                  ORInt n1 = [[allpathB[i][j] lastObject] intValue];
                  [penalityPathB addObject:@(max([penality[n0][1] intValue], [penality[n1][1] intValue]))];
               }
            }
         }
         NSMutableArray* flowRiskA = [[NSMutableArray alloc] initWithCapacity:[flowPathsA count]];
         NSMutableArray* flowRiskB = [[NSMutableArray alloc] initWithCapacity:[flowPathsB count]];
         
         riskCacl(flowRiskA, flowPathsA, risk, 0, [g size]);
         riskCacl(flowRiskB, flowPathsB, risk, 1, [g size]);
         
         ORInt initRisk = 0;
         for(NSNumber* n in flowRiskA)
            initRisk += [n intValue];
         
         for(NSNumber* n in flowRiskB)
            initRisk += [n intValue];
         
         id<ORIntRange> BINARY = RANGE(security, 0, 1);
         id<ORIntRange> NODES_R = RANGE(security, 0, (ORInt)[device count] - 1);
         id<ORIntRange> PATHSA_R = RANGE(security, 0, (ORInt)[flowPathsA count] - 1);
         id<ORIntRange> PATHSB_R = RANGE(security, 0, (ORInt)[flowPathsB count] - 1);
         id<ORIdArray> pi = [ORFactory idArray:security range:NODES_R];
         id<ORIdArray> firewallA = [ORFactory idArray:security range:NODES_R];
         id<ORIdArray> firewallB = [ORFactory idArray:security range:NODES_R];
         id<ORIdArray> firewallOther = [ORFactory idArray:security range:NODES_R];
         id<ORIdArray> fwORA = [ORFactory idArray:security range:NODES_R];
         id<ORIdArray> fwORB = [ORFactory idArray:security range:NODES_R];
         for(ORInt j = 0; j < [device count];j++){
            pi[j] = [ORFactory intVar:security domain:BINARY name:[NSString stringWithFormat:@"pi[%@]",device[j]]];
            firewallA[j] = [ORFactory intVar:security domain:BINARY name:[NSString stringWithFormat:@"firewallA[%@]",device[j]]];
            firewallB[j] = [ORFactory intVar:security domain:BINARY name:[NSString stringWithFormat:@"firewallB[%@]",device[j]]];
            firewallOther[j] = [ORFactory intVar:security domain:BINARY name:[NSString stringWithFormat:@"firewall*[%@]",device[j]]];
            fwORA[j] = [ORFactory intVar:security domain:BINARY name:[NSString stringWithFormat:@"fwORA[%@]",device[j]]];
            fwORB[j] = [ORFactory intVar:security domain:BINARY name:[NSString stringWithFormat:@"fwORB[%@]",device[j]]];
         }
         
         id<ORIntVarArray> fwOnPathA = [ORFactory intVarArray:security range:PATHSA_R domain:BINARY names:@"fwOnPathA"];
         id<ORRealVarArray> riskFactorA = [ORFactory realVarArray:security range:PATHSA_R low:0. up:1. names:@"riskFactorA"];
         id<ORIdArray> riskMINfwA = [ORFactory idArray:security range:PATHSA_R];
         id<ORIdArray> riskMINpiA = [ORFactory idArray:security range:PATHSA_R];
         
         id<ORIntVarArray> fwOnPathB = [ORFactory intVarArray:security range:PATHSB_R domain:BINARY names:@"fwOnPathB"];
         id<ORRealVarArray> riskFactorB = [ORFactory realVarArray:security range:PATHSB_R low:0. up:1. names:@"riskFactorB"];
         id<ORIdArray> riskMINfwB = [ORFactory idArray:security range:PATHSB_R];
         id<ORIdArray> riskMINpiB = [ORFactory idArray:security range:PATHSB_R];
         
         for(ORInt i = 0; i < [flowPathsA count]; i++){
            riskMINfwA[i] = [ORFactory idArray:security range:PATHSA_R];
            riskMINpiA[i] = [ORFactory idArray:security range:PATHSA_R];
             for(ORInt j = 0; j < [flowPathsA[i] count]; j++){
                ORInt n = [flowPathsA[i][j] intValue];
                riskMINfwA[i][j] = [ORFactory realVar:security low:0. up:1. name:[NSString stringWithFormat:@"riskMINfwA[%d][%@]",i,device[n]]];
                riskMINpiA[i][j] = [ORFactory realVar:security low:0. up:1. name:[NSString stringWithFormat:@"riskMINpiA[%d][%@]",i,device[n]]];
             }
         }
         
         for(ORInt i = 0; i < [flowPathsB count]; i++){
            riskMINfwB[i] = [ORFactory idArray:security range:PATHSB_R];
            riskMINpiB[i] = [ORFactory idArray:security range:PATHSB_R];
            for(ORInt j = 0; j < [flowPathsB[i] count]; j++){
               ORInt n = [flowPathsB[i][j] intValue];
               riskMINfwB[i][j] = [ORFactory realVar:security low:0. up:1. name:[NSString stringWithFormat:@"riskMINfwB[%d][%@]",i,device[n]]];
               riskMINpiB[i][j] = [ORFactory realVar:security low:0. up:1. name:[NSString stringWithFormat:@"riskMINpiB[%d][%@]",i,device[n]]];
            }
         }
         //respect device memory capacity
         for(ORInt i = 0; i < [network count]; i++){
            ORInt n = [network[i] intValue];
            id<ORExpr> fe = [[[[firewallA[n] mul:fwCost[0]] plus:[firewallOther[n] mul:fwCost[4]]] plus:[firewallB[n] mul:fwCost[1]]] plus:[pi[n] mul:@(piCost)]];
            [security add:[fe leq:deviceMemory[n]]];
         }
         
         //fwOnPath constraints
         for (ORInt p = 0; p < [flowPathsA count]; p++){
            NSMutableArray* arr = [[NSMutableArray alloc] init];
            for(ORInt i = 0; i < [flowPathsA[p] count]; i++){
               ORInt n = [flowPathsA[p][i] intValue];
               if([Graph isNetWorkDevice:device[n]]){
                  [arr addObject: firewallOther[n]];
                  [arr addObject: firewallA[n]];
               }
            }
            id<ORIntVarArray> ar = (id<ORIntVarArray>)[ORFactory idArray:security array:arr];
            [arr release];
            [security add:[ORFactory clause:security over:ar equal:fwOnPathA[p]]];
         }
         
         for (ORInt p = 0; p < [flowPathsB count]; p++){
            NSMutableArray* arr = [[NSMutableArray alloc] init];
            for(ORInt i = 0; i < [flowPathsB[p] count]; i++){
               ORInt n = [flowPathsB[p][i] intValue];
               if([Graph isNetWorkDevice:device[n]]){
                  [arr addObject: firewallOther[n]];
                  [arr addObject: firewallB[n]];
               }
            }
            id<ORIntVarArray> ar = (id<ORIntVarArray>)[ORFactory idArray:security array:arr];
            [arr release];
            [security add:[ORFactory clause:security over:ar equal:fwOnPathB[p]]];
         }
         
//         riskMIN
         id<ORExpr> c = [ORFactory double:security value:1.0];
         for(ORInt p = 0; p < [flowPathsA count];p++){
            ORInt pos = 1;
            for(ORInt i = 0; i < [flowPathsA[p] count]; i++){
               ORInt n = [flowPathsA[p][i] intValue];
               if([Graph isNetWorkDevice:device[n]]){
                  ORDouble f = pow(0.5, pos++);
                  [security add:[[c sub:[fwORA[n] mul:@(f)]] eq:riskMINfwA[p][i]]];
                  [security add:[[c sub:[[fwORA[n] mul:@(f)] mul:@(0.1)]] eq:riskMINpiA[p][i]]];
               }
            }
         }
         for(ORInt p = 0; p < [flowPathsB count];p++){
            ORInt pos = 1;
            for(ORInt i = 0; i < [flowPathsB[p] count]; i++){
               ORInt n = [flowPathsB[p][i] intValue];
               if([Graph isNetWorkDevice:device[n]]){
                  ORDouble f = pow(0.5, pos++);
                  [security add:[[c sub:[fwORB[n] mul:@(f)]] eq:riskMINfwB[p][i]]];
                  [security add:[[c sub:[[fwORB[n] mul:@(f)] mul:@(0.1)]] eq:riskMINpiB[p][i]]];
               }
            }
         }
         
//         riskFactor
         for(ORInt p = 0; p < [flowPathsA count]; p++){
            NSMutableArray* arr = [[NSMutableArray alloc] init];
            for(ORInt i = 0; i < [flowPathsA[p] count]; i++){
               ORInt n = [flowPathsA[p][i] intValue];
               if([Graph isNetWorkDevice:device[n]]){
                  [arr addObject: riskMINfwA[p][i]];
                  [arr addObject: riskMINpiA[p][i]];
               }
            }
            id<ORRealVarArray> ar = (id<ORRealVarArray>)[ORFactory idArray:security array:arr];
            [arr release];
            [security add:[ORFactory realMin:security array:ar eq:riskFactorA[p]]];
         }
         
         for(ORInt p = 0; p < [flowPathsB count]; p++){
            NSMutableArray* arr = [[NSMutableArray alloc] init];
            for(ORInt i = 0; i < [flowPathsB[p] count]; i++){
               ORInt n = [flowPathsB[p][i] intValue];
               if([Graph isNetWorkDevice:device[n]]){
                  [arr addObject: riskMINfwB[p][i]];
                  [arr addObject: riskMINpiB[p][i]];
               }
            }
            id<ORRealVarArray> ar = (id<ORRealVarArray>)[ORFactory idArray:security array:arr];
            [arr release];
            [security add:[ORFactory realMin:security array:ar eq:riskFactorB[p]]];
         }
         
         for (ORInt n = 0; n < [fwORA count]; n++) {
            id<ORIntVarArray> arr = [ORFactory intVarArray:security range:BINARY];
            arr[0] = firewallA[n];
            arr[1] = firewallOther[n];
            [security add:[ORFactory clause:security over:arr equal:fwORA[n]]];
         }
         for (ORInt n = 0; n < [fwORB count]; n++) {
            id<ORIntVarArray> arr = [ORFactory intVarArray:security range:BINARY];
            arr[0] = firewallB[n];
            arr[1] = firewallOther[n];
            [security add:[ORFactory clause:security over:arr equal:fwORB[n]]];
         }
         
         //objective
         id<ORExpr> piNum = Sum(security,n,pi.range,([Graph isNetWorkDevice:device[n]])?pi[n]:@(0));
         id<ORExpr> fwNum = [Sum(security,n,firewallA.range,([Graph isNetWorkDevice:device[n]])?firewallA[n]:@(0)) plus:Sum(security,n,firewallB.range,([Graph isNetWorkDevice:device[n]])?firewallB[n]:@(0))];
         id<ORExpr> simplicityMetric = [piNum plus:[fwNum mul:@(10)]];
         id<ORExpr> flowReduction = Sum(security,n,load.range,[pi[[network[n] intValue]] mul:@([mip doubleValue:load[n]])]);
         id<ORExpr> goodTrafficBlocked = [[ORFactory sum:security over:fwOnPathA.range suchThat:nil of:^id<ORExpr>(ORInt p){
            ORInt ind0 = [flow2AllA[p][0] intValue];
            ORInt ind1 = [flow2AllA[p][1] intValue];
            return (id<ORExpr>)([[fwOnPathA[p] mul:@([mip doubleValue:flowA[ind0][ind1]])] mul:penalityPathA[p]]);
         }] plus:[ORFactory sum:security over:fwOnPathB.range suchThat:nil of:^id<ORExpr>(ORInt p){
            ORInt ind0 = [flow2AllB[p][0] intValue];
            ORInt ind1 = [flow2AllB[p][1] intValue];
            return (id<ORExpr>)([[fwOnPathB[p] mul:@([mip doubleValue:flowB[ind0][ind1]])] mul:penalityPathB[p]]);
         }]];
         id<ORExpr> networkRisk = [Sum(security,p,riskFactorA.range,[riskFactorA[p] mul:flowRiskA[p]]) plus:Sum(security,p,riskFactorB.range,[riskFactorB[p] mul:flowRiskB[p]])];
         [security minimize: [[[[simplicityMetric mul:@(beta0)] plus:[flowReduction mul:@(beta1)]] plus:[goodTrafficBlocked mul:@(beta2)]]                               plus:[networkRisk mul:@(beta3)]]];
         id<MIPProgram> mipSecurity = [ORFactory createMIPProgram: security];
         status = [mipSecurity solve];
         [mipSecurity printModelToFile:"/Users/zitoun/Desktop/security.lp"];
         if(status == ORerror)
            printf("error in mip model\n");
         
         
         [flowPathsA release];
         [flowPathsB release];
         [flowRiskA release];
         [flowRiskB release];
         [penalityPathA release];
         [penalityPathB release];
         [flow2AllA release];
         [flow2AllB release];
   
      }
      [allpathA release];
      [allpathB release];
      [P_edgesA release];
      [P_edgesB release];
      [P_nodesA release];
      [P_nodesB release];
      [demandB release];
      [demandA release];
      [device2ID release];
      [deviceMemory release];
   }
   return 0;
}
