//
//  rumps.m
//  Clo
//
//  Created by Remy Garcia on 11/03/2018.
//
#import <ORProgram/ORProgram.h>

int main(int argc, const char * argv[]) {
   @autoreleasepool {
      id<ORModel> mdl = [ORFactory createModel];
      id<ORFloatVar> y_0 = [ORFactory floatVar:mdl];
      id<ORFloatVar> r_0 = [ORFactory floatVar:mdl];
      id<ORFloatVar> x_0 = [ORFactory floatVar:mdl];
      
      
      [mdl add:[x_0 set: @(77617.f)]];
      [mdl add:[y_0 set: @(33096.f)]];
      [mdl add:[r_0 set: [[[[[[[[[y_0 mul: @(333.75f)] mul: y_0] mul: y_0] mul: y_0] mul: y_0] mul: y_0] plus: [[x_0 mul: x_0] mul: [[[[[[[x_0 mul: @(11.0f)] mul: x_0] mul: y_0] mul: y_0] sub: [[[[[y_0 mul: y_0] mul: y_0] mul: y_0] mul: y_0] mul: y_0]] sub: [[[[y_0 mul: @(121.0f)] mul: y_0] mul: y_0] mul: y_0]] sub: @(2.0f)]]] plus: [[[[[[[[y_0 mul: @(5.5f)] mul: y_0] mul: y_0] mul: y_0] mul: y_0] mul: y_0] mul: y_0] mul: y_0]] plus: [x_0 div: [y_0 mul: @(2.f)]]]]];
      //assert((r_0 >= 0));
      [mdl add:[r_0 set:[x_0 plus: y_0]]];
      [mdl add:[r_0 geq:@(0.0f)]];
      //[model add:[[r_0 lt:@(0.0f)] lor:[r_0 gt:@(0.0f)]]];
      
      NSLog(@"model: %@",mdl);
      //id<ORFloatVarArray> vs = [mdl floatVars];
      id<CPProgram> cp = [ORFactory createCPProgram:mdl];
      //id<ORDisabledFloatVarArray> vars = [ORFactory disabledFloatVarArray:vs engine:[cp engine]];
      
      [cp solve:^{
         /*[cp lexicalOrderedSearch:vars do:^(ORUInt i, SEL s, id<ORDisabledFloatVarArray> x) {
         [cp floatSplit:i call:s withVars:x];
         }];*/
         NSLog(@"TOTO");
         NSLog(@"%@",cp);
         /* format of 8.8e to have the same value displayed as in FLUCTUAT */
         /* Use printRational(ORRational r) to print a rational inside the solver */
         NSLog(@"x : %8.8e (%s)",[cp floatValue:x_0],[cp bound:x_0] ? "YES" : "NO");
         NSLog(@"ex: [%8.8e;%8.8e]",[cp minError:x_0],[cp maxError:x_0]);
         NSLog(@"y : %8.8e (%s)",[cp floatValue:y_0],[cp bound:y_0] ? "YES" : "NO");
         NSLog(@"ey: [%8.8e;%8.8e]",[cp minError:y_0],[cp maxError:y_0]);
         NSLog(@"z : %8.8e (%s)",[cp floatValue:r_0],[cp bound:r_0] ? "YES" : "NO");
         NSLog(@"ez: [%8.8e;%8.8e]",[cp minError:r_0],[cp maxError:r_0]);
      }];
   }
   return 0;
}

