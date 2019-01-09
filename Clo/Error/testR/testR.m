//
//  main.m
//  testFloat
//
//  Created by Remy on 01/12/2017.
//
//
#import <ORProgram/ORProgram.h>
#include "gmp.h"

#define printFvar(name, var) NSLog(@""name" : [%20.20e, %20.20e]f (%s)",[(id<CPFloatVar>)[cp concretize:var] min],[(id<CPFloatVar>)[cp concretize:var] max],[cp bound:var] ? "YES" : "NO"); NSLog(@"e"name": [%20.20e, %20.20e]q",[(id<CPFloatVar>)[cp concretize:var] minErrF],[(id<CPFloatVar>)[cp concretize:var] maxErrF]);
#define getFmin(var) [(id<CPFloatVar>)[cp concretize:var] min]
#define getFminErr(var) *[(id<CPFloatVar>)[cp concretize:var] minErr]

#define printDvar(name, var) NSLog(@""name" : [% 24.24e, % 24.24e]d (%s)",[(id<CPDoubleVar>)[cp concretize:var] min],[(id<CPDoubleVar>)[cp concretize:var] max],[cp bound:var] ? "YES" : "NO"); NSLog(@"e"name": [% 24.24e, % 24.24e]q",[(id<CPDoubleVar>)[cp concretize:var] minErrF],[(id<CPDoubleVar>)[cp concretize:var] maxErrF]);
#define getDmin(var) [(id<CPDoubleVar>)[cp concretize:var] min]
#define getDminErr(var) *[(id<CPDoubleVar>)[cp concretize:var] minErr]

void check_it_f(float x, float y, float o, float k, float w, float u, float z, id<ORRational> ez) {
   mpq_t qz, qx, qy, qo, qk, tmp0, tmp1, tmp2;
   float cw = x + y;
   float cu = o + k;
   float cz = w - u;
   
   if (cw != w)
      NSLog(@"WRONG: cw = % 20.20e != w = % 20.20e\n", cw, w);
   if (cu != u)
      NSLog(@"WRONG: cu = % 20.20e != u = % 20.20e\n", cu, u);
   if (cz != z)
      NSLog(@"WRONG: cz = % 20.20e != z = % 20.20e\n", cz, z);
   
   mpq_inits(qz, qx, qy, qo, qk, tmp0, tmp1, tmp2, NULL);
   
   mpq_set_d(qx, x);
   mpq_set_d(qy, y);
   mpq_set_d(qo, o);
   mpq_set_d(qk, k);
   mpq_add(qx, qx, qy);
   mpq_add(qo, qo, qk);
   mpq_sub(qz, qx, qo);
   
   mpq_set_d(tmp0, cz);
   mpq_sub(tmp1, qz, tmp0);
   if (mpq_cmp(tmp1, ez.rational) != 0){
      NSLog(@"%s != %@", mpq_get_str(NULL, 10, tmp1), ez);
      NSLog(@"WRONG: Err found = % 24.24e\n != % 24.24e\n", mpq_get_d(tmp1), [ez get_d]);
   }
   mpq_clears(qz, qx, qy, qo, qk, tmp0, tmp1, tmp2, NULL);
}

int main(int argc, const char * argv[]) {
   @autoreleasepool {
      id<ORModel> mdl = [ORFactory createModel];
      ORRational * zero = [[[ORRational alloc] init] setZero];
      ORRational * tmp = [ORRational rationalWith_d:nextafterf(7.15255737304687500000e-07, +INFINITY)];
      id<ORFloatVar> x = [ORFactory floatVar:mdl name:@"x"];
      id<ORFloatVar> y = [ORFactory floatVar:mdl low:1.3f up:3.4f elow:zero eup:zero name:@"y"];
      id<ORFloatVar> o = [ORFactory floatVar:mdl name:@"o"];
      id<ORFloatVar> k = [ORFactory floatVar:mdl low:2.0f up:3.0f elow:zero eup:zero name:@"k"];
      id<ORFloatVar> w = [ORFactory floatVar:mdl name:@"w"];
      id<ORFloatVar> u = [ORFactory floatVar:mdl name:@"u"];
      id<ORFloatVar> z = [ORFactory floatVar:mdl name:@"z"];
      [zero release];
      
      [mdl add:[x set: @(11.34f)]];
      [mdl add:[o set: @(2.43f)]];
      
      /*
       Search for input values such that the error on z is greater or equal than tmp
       tmp is the float next after the value found without this constraint
       Bounding the error help find a greater error! (Closer to the maximum)
       P.S. it doesn't change the output value of z (only k and u slightly change, on value and error)
       */
      [mdl add:[[z error] geq: tmp]];
      
      [mdl add:[w set: [x plus: y]]];
      [mdl add:[u set: [o plus: k]]];
      [mdl add:[z set: [w sub: u]]];
      
      NSLog(@"model: %@",mdl);
      id<CPProgram> cp = [ORFactory createCPProgram:mdl];
      id<ORFloatVarArray> vs = [mdl floatVars];
      id<ORDisabledFloatVarArray> vars = [ORFactory disabledFloatVarArray:vs engine:[cp engine]];
      
      [cp solve:^{
         [cp lexicalOrderedSearch:vars do:^(ORUInt i, SEL s, id<ORDisabledFloatVarArray> x) {
            [cp floatSplit:i call:s withVars:x];
         }];
         NSLog(@"x : [%20.20e;%20.20e] (%s)",[cp minF:x],[cp maxF:x],[cp bound:x] ? "YES" : "NO");
         NSLog(@"ex: [%@;%@]",[cp minFQ:x],[cp maxFQ:x]);
         NSLog(@"y : [%20.20e;%20.20e] (%s)",[cp minF:y],[cp maxF:y],[cp bound:y] ? "YES" : "NO");
         NSLog(@"ey: [%@;%@]",[cp minFQ:y],[cp maxFQ:y]);
         NSLog(@"o : [%20.20e;%20.20e] (%s)",[cp minF:o],[cp maxF:o],[cp bound:o] ? "YES" : "NO");
         NSLog(@"eo: [%@;%@]",[cp minFQ:o],[cp maxFQ:o]);
         NSLog(@"k : [%20.20e;%20.20e] (%s)",[cp minF:k],[cp maxF:k],[cp bound:k] ? "YES" : "NO");
         NSLog(@"ek: [%@;%@]",[cp minFQ:k],[cp maxFQ:k]);
         NSLog(@"w : [%20.20e;%20.20e] (%s)",[cp minF:w],[cp maxF:w],[cp bound:w] ? "YES" : "NO");
         NSLog(@"ew: [%@;%@]",[cp minFQ:w],[cp maxFQ:w]);
         NSLog(@"u : [%20.20e;%20.20e] (%s)",[cp minF:u],[cp maxF:u],[cp bound:u] ? "YES" : "NO");
         NSLog(@"eu: [%@;%@]",[cp minFQ:u],[cp maxFQ:u]);
         NSLog(@"z : [%20.20e;%20.20e] (%s)",[cp minF:z],[cp maxF:z],[cp bound:z] ? "YES" : "NO");
         NSLog(@"ez: [%@;%@]",[cp minFQ:z],[cp  maxFQ:z]);
         check_it_f(getFmin(x),getFmin(y),getFmin(o),getFmin(k),getFmin(w),getFmin(u),getFmin(z),[cp minErrorFQ:z]);
      }];
      NSLog(@"%@",cp);
      [tmp release];
   }
   return 0;
}
