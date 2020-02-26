//
//  himmilbeauBB.m
//  Clo
//
//  Created by Rémy Garcia on 06/02/2020.
//

#import <ORProgram/ORProgram.h>

void himmilbeau_d_c(int search, int argc, const char * argv[]) {
   @autoreleasepool {
      /* Creation of model */
      id<ORModel> mdl = [ORFactory createModel];
      
      /* Declaration of model variables */
      id<ORDoubleVar> x1 = [ORFactory doubleInputVar:mdl low:-5 up:5 name:@"x1"];
      id<ORDoubleVar> x2 = [ORFactory doubleInputVar:mdl low:-5 up:5 name:@"x2"];
      id<ORDoubleVar> z = [ORFactory doubleVar:mdl name:@"z"];
      id<ORRationalVar> ez = [ORFactory errorVar:mdl of:z];
      id<ORRationalVar> ezAbs = [ORFactory rationalVar:mdl name:@"ezAbs"];

      /* Declaration of constraints */
      //   res = (x1*x1 + x2 - 11)* (x1*x1 + x2 - 11) + (x1 + x2*x2 - 7)*(x1 + x2*x2 - 7);
      [mdl add:[z set:[[[[[x1 mul: x1] plus: x2] sub: @(11.0)] mul: [[[x1 mul: x1] plus: x2] sub: @(11.0)]] plus: [[[x1 plus: [x2 mul: x2]] sub: @(7.0)] mul:[[x1 plus: [x2 mul: x2]] sub: @(7.0)]]]]];

      /* Declaration of constraints over errors */
      [mdl add: [ezAbs eq: [ez abs]]];
      [mdl maximize:ezAbs];

      /* Display model */
      NSLog(@"model: %@",mdl);
      
      /* Construction of solver */
      id<CPProgram> cp = [ORFactory createCPSemanticProgram:mdl with:[ORSemBBController proto]];
      id<ORDoubleVarArray> vs = [mdl doubleVars];
      id<ORDisabledVarArray> vars = [ORFactory disabledFloatVarArray:vs engine:[cp engine]];
      
      /* Solving */
      [cp solve:^{
            /* Branch-and-bound search strategy to maximize ezAbs, the error in absolute value of z */
            [cp branchAndBoundSearchD:vars out:ezAbs do:^(ORUInt i, id<ORDisabledVarArray> x) {
               /* Split strategy */
               [cp floatSplit:i withVars:x];
            }];
      }];
   }
}


int main(int argc, const char * argv[]) {
   himmilbeau_d_c(1, argc, argv);
   return 0;
}
