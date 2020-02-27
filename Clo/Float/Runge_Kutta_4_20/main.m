
//
//  Runge Kutta Fourth order
//
//  Created by cpjm on 25/08/2019.
//  Copyright © 2019 Laurent Michel. All rights reserved.
//

#import <ORProgram/ORProgram.h>
#import "ORCmdLineArgs.h"

/*
 // Original
 
 yn = [−10.1,10.1]; t = 0.0; k = 1.2; c = 100.1; h=0.1;
 while(t < 1.0) do {
 k1 = (k * (c − yn)) * (c − yn);
 k2 = (k * (c − (yn + ((0.5 * h) * k1)))) * (c − (yn + ((0.5 * h) * k1)));
 k3 = (k * (c − (yn + ((0.5 * h) * k2)))) * (c − (yn + ((0.5 * h) * k2)));
 k4 = (k * (c − (yn + (h * k3)))) * (c − (yn + (h * k3)));
 yn+1 = yn + ((1/6 * h) * (((k1 + (2.0 * k2)) + (2.0 * k3)) + k4));
 t=(t+h);
 }
 
 // Optimized
 
 yn = [ −10.1 ,10.1]; t = 0.0;
 while(t < 1.0) do {
 TMP_7 = (1.2 * (100.099 − yn));
 TMP_8 = (100.099 − yn);
 TMP_13 = (1.2 * (100.099 − (yn + (0.05 * ((1.2 * (100.099 − (yn + (0.05 * (TMP_7 * TMP_8)))))
 * (100.099 − (yn + (0.05 * ((1.2 * TMP_8) * (100.099 − yn))))))))));
 TMP_14 = (100.099 − (yn + (0.05 * ((1.2 * (100.099 − (yn + (0.05 *(TMP_7 * TMP_8))))) * (100.099 − (yn + (0.05 * ((1.2 * TMP_8) * (100.099 − yn));
 TMP_18 = (yn + (0.05 * ((1.2 * (100.099 − (yn + (0.05 *(TMP_7 * TMP_8)))))
 * (100.099 − (yn + (0.05 * ((1.2 * TMP_8) * (100.099 −yn))))))));
 TMP_28 = ((1.2 * (100.099 − (yn + (0.05 * (TMP_7 * TMP_8))))) *(100.099 − (yn
 + (0.05 * ((1.2 * TMP_8) * (100.099 − yn ))))));
 TMP_38 = ((TMP_14 * TMP_13) * 0.1) + yn;
 TMP_40 = 0.1 * ((1.2 * TMP_14) * (100.099 − TMP_18));
 yn+1 = (yn + (0.016666667 * ((((TMP_7 * TMP_8) + (2.0 * TMP_28)) + (2.0 * (TMP_13 * TMP_14))) + ((1.2 * (100.099 − TMP_38)) *
 (100.099 - (yn + TMP_40))))));
 t=(t+0.1);
 }
 
 */

#define NBLOOPS 20

int main(int argc, const char * argv[]) {
   
   @autoreleasepool {
      ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
      
      id<ORModel> model = [ORFactory createModel];
      
      NSMutableArray* toadd = [[NSMutableArray alloc] init];
      
      // Input var
      id<ORFloatVar> yn = [ORFactory floatVar:model low:-100.1f up:100.1f name:@"yn"];
      
      // Constants
      // k = 1.2; c = 100.1; h=0.1;
      id<ORExpr> k = [ORFactory float:model value:1.2f];
      id<ORExpr> c = [ORFactory float:model value:100.1f];
      id<ORExpr> h = [ORFactory float:model value:0.1f];
      
      // Local vars
      id<ORFloatVarArray> k1     = [ORFactory floatVarArray:model range:RANGE(model, 1, NBLOOPS) names:@"k1"];
      id<ORFloatVarArray> k2     = [ORFactory floatVarArray:model range:RANGE(model, 1, NBLOOPS) names:@"k2"];
      id<ORFloatVarArray> k3     = [ORFactory floatVarArray:model range:RANGE(model, 1, NBLOOPS) names:@"k3"];
      id<ORFloatVarArray> k4     = [ORFactory floatVarArray:model range:RANGE(model, 1, NBLOOPS) names:@"k4"];
      id<ORFloatVarArray> yn1    = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS) names:@"yn1"];
      
      id<ORFloatVarArray> TMP_7   = [ORFactory floatVarArray:model range:RANGE(model, 1, NBLOOPS) names:@"TMP_7"];
      id<ORFloatVarArray> TMP_8   = [ORFactory floatVarArray:model range:RANGE(model, 1, NBLOOPS) names:@"TMP_8"];
      id<ORFloatVarArray> TMP_13  = [ORFactory floatVarArray:model range:RANGE(model, 1, NBLOOPS) names:@"TMP_13"];
      id<ORFloatVarArray> TMP_14  = [ORFactory floatVarArray:model range:RANGE(model, 1, NBLOOPS) names:@"TMP_14"];
      id<ORFloatVarArray> TMP_18  = [ORFactory floatVarArray:model range:RANGE(model, 1, NBLOOPS) names:@"TMP_18"];
      id<ORFloatVarArray> TMP_28  = [ORFactory floatVarArray:model range:RANGE(model, 1, NBLOOPS) names:@"TMP_28"];
      id<ORFloatVarArray> TMP_38  = [ORFactory floatVarArray:model range:RANGE(model, 1, NBLOOPS) names:@"TMP_38"];
      id<ORFloatVarArray> TMP_40  = [ORFactory floatVarArray:model range:RANGE(model, 1, NBLOOPS) names:@"TMP_40"];
      id<ORFloatVarArray> yn1_opt = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS) names:@"yn1_opt"];
      
      id<ORFloatVar> diff = [ORFactory floatVar:model name:@"diff"];
      
      //[toadd addObject:[yn set: @(111.1f)]];
      
      
      [toadd addObject:[yn1[0] set: yn]];
      [toadd addObject:[yn1_opt[0] set: yn]];
      
      for (ORUInt n = 1; n <= NBLOOPS; n++) {
         [toadd addObject:[yn1[n] geq: @(-10e8f)]];
         [toadd addObject:[yn1[n] leq: @(10e8f)]];
         [toadd addObject:[k1[n] set: [[k mul: [c sub: yn1[n-1]]] mul: [c sub: yn1[n-1]]]]];
         [toadd addObject:[k2[n] set: [[k mul: [c sub: [yn1[n-1] plus: [[h mul: @(0.5f)] mul: k1[n]]]]] mul: [c sub: [yn1[n-1] plus: [[h mul: @(0.5f)] mul: k1[n]]]]]]];
         [toadd addObject:[k3[n] set: [[k mul: [c sub: [yn1[n-1] plus: [[h mul: @(0.5f)] mul: k2[n]]]]] mul: [c sub: [yn1[n-1] plus: [[h mul: @(0.5f)] mul: k2[n]]]]]]];
         [toadd addObject:[k4[n] set: [[k mul: [c sub: [yn1[n-1] plus: [h mul: k3[n]]]]] mul: [c sub: [yn1[n-1] plus: [h mul: k3[n]]]]]]];
         //      [toadd addObject:[yn1[n] set: [yn1[n-1] plus: [[h div: @(6.0f)] mul: [[[k1[n] plus: [k2[n] mul: @(2.0f)]] plus: [k3[n] mul: @(2.0f)]] plus: k4[n]]]]]];
         [toadd addObject:[yn1[n] set: [yn1[n-1] plus: [[h mul: @(0.1666666666f)] mul: [[[k1[n] plus: [k2[n] mul: @(2.0f)]] plus: [k3[n] mul: @(2.0f)]] plus: k4[n]]]]]];
         
         [toadd addObject:[TMP_7[n] set: [@(1.2f) mul: [@(100.099f) sub: yn1_opt[n-1]]]]];
         [toadd addObject:[TMP_8[n] set: [@(100.099f) sub: yn1_opt[n-1]]]];
         [toadd addObject:[TMP_13[n] set: [@(1.2f) mul: [@(100.099f) sub: [yn1_opt[n-1] plus: [@(0.05f) mul: [[@(1.2f) mul: [@(100.099f) sub: [yn1_opt[n-1] plus: [@(0.05f) mul: [TMP_7[n] mul: TMP_8[n]]]]]]
                                                                                                              mul: [@(100.099f) sub: [yn1_opt[n-1] plus: [@(0.05f) mul: [[@(1.2f) mul: TMP_8[n]] mul: [@(100.099f) sub: yn1_opt[n-1]]]]]]]]]]]]];
         [toadd addObject:[TMP_14[n] set: [@(100.099f) sub: [yn1_opt[n-1] plus: [@(0.05f) mul: [[@(1.2f) mul: [@(100.099f) sub: [yn1_opt[n-1] plus: [@(0.05f) mul: [TMP_7[n] mul: TMP_8[n]]]]]]
                                                                                                mul: [@(100.099f) sub: [yn1_opt[n-1] plus: [@(0.05f) mul: [[@(1.2f) mul: TMP_8[n]] mul: [@(100.099f) sub: yn1_opt[n-1]]]]]]]]]]]];
         [toadd addObject:[TMP_18[n] set: [yn1_opt[n-1] plus: [@(0.05f) mul: [[@(1.2f) mul: [@(100.099f) sub: [yn1_opt[n-1] plus: [@(0.05f) mul: [TMP_7[n] mul: TMP_8[n]]]]]]
                                                                              mul: [@(100.099f) sub: [yn1_opt[n-1] plus: [@(0.05f) mul: [[@(1.2f) mul: TMP_8[n]] mul: [@(100.099f) sub: yn1_opt[n-1]]]]]]]]]]];
         [toadd addObject:[TMP_28[n] set: [[@(1.2f) mul: [@(100.099f) sub: [yn1_opt[n-1] plus: [@(0.05f) mul: [TMP_7[n] mul: TMP_8[n]]]]]] mul: [@(100.099f) sub: [yn1_opt[n-1]
                                                                                                                                                                   plus: [@(0.05f) mul: [[@(1.2f) mul: TMP_8[n]] mul: [@(100.099f) sub: yn1_opt[n-1] ]]]]]]]];
         [toadd addObject:[TMP_38[n] set: [[[TMP_14[n] mul: TMP_13[n]] mul: @(0.1f)] plus: yn1_opt[n-1]]]];
         [toadd addObject:[TMP_40[n] set: [@(0.1f) mul: [[@(1.2f) mul: TMP_14[n]] mul: [@(100.099f) sub: TMP_18[n]]]]]];
         [toadd addObject:[yn1_opt[n] set:
                           [yn1_opt[n-1] plus: [@(0.016666667f) mul: [[[[TMP_7[n] mul: TMP_8[n]] plus: [@(2.0f) mul: TMP_28[n]]] plus: [@(2.0f) mul: [TMP_13[n] mul: TMP_14[n]]]]
                                                                      plus: [[@(1.2f) mul: [@(100.099f) sub: TMP_38[n]]] mul: [@(100.099f) sub: [yn1_opt[n-1] plus: TMP_40[n]]]]]]]]];
         
      }
      
      [toadd addObject:[diff set: [yn1[NBLOOPS] sub: yn1_opt[NBLOOPS]]]];
      [toadd addObject:[[diff mul: diff] geq:@(1.0e-6f)]];
      
      id<CPProgram> cp = [args makeProgramWithSimplification:model constraints:toadd];
      [ORCmdLineArgs defaultRunner:args model:model program:cp restricted:@[yn]];
      
   }
   return 0;
}
