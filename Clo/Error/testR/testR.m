//
//  main.m
//  testFloat
//
//  Created by Remy on 01/12/2017.
//
//
#import <ORProgram/ORProgram.h>
#include "gmp.h"
#include "fpi.h"
#import "ORCmdLineArgs.h"

int NB_FLOAT = 2;

#define LOO_MEASURE_TIME(__message) \
for (CFAbsoluteTime startTime##__LINE__ = CFAbsoluteTimeGetCurrent(), endTime##__LINE__ = 0.0; endTime##__LINE__ == 0.0; \
NSLog(@"'%@' took %.3fs", (__message), (endTime##__LINE__ = CFAbsoluteTimeGetCurrent()) - startTime##__LINE__))

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

void check_it_bb(float x, float y, float z, id<ORRational> ez) {
   mpq_t qz, qx, qy, tmp0, tmp1, tmp2;
   
   fesetround(FE_TONEAREST);
   float cz = x + y;
   //NSLog(@"%20.20e = %20.20e + %20.20e", cz, x, y);
   
   //   if (cz != z)
   //      NSLog(@"WRONG: cz = % 20.20e != z = % 20.20e\n", cz, z);
   
   mpq_inits(qz, qx, qy, tmp0, tmp1, tmp2, NULL);
   
   mpq_set_d(qx, x);
   mpq_set_d(qy, y);
   mpq_add(qz, qx, qy);
   
   mpq_set_d(tmp0, cz);
   mpq_sub(tmp1, qz, tmp0);
   //NSLog(@"Err: %s", mpq_get_str(NULL, 10, tmp1));
   NSLog(@"Err: %20.20e", mpq_get_d(tmp1));
   //NSLog(@"%s (%20.20e) | %20.20e (%20.20e)", mpq_get_str(NULL, 10, qz), mpq_get_d(qz), cz, mpq_get_d(tmp0));
   //   if (mpq_cmp(tmp1, ez.rational) != 0){
   //      NSLog(@"%s != %@", mpq_get_str(NULL, 10, tmp1), ez);
   //      NSLog(@"Err found: % 24.24e\n != % 24.24e\n", mpq_get_d(tmp1), [ez get_d]);
   //   }
   mpq_clears(qz, qx, qy, tmp0, tmp1, tmp2, NULL);
}

void testRational(int argc, const char * argv[]) {
   @autoreleasepool {
      id<ORRational> low = [[ORRational alloc] init];
      id<ORRational> up = [[ORRational alloc] init];
      [low set_d:0];
      [up set_d: 10];
      id<ORModel> mdl = [ORFactory createModel];
      id<ORRationalVar> x = [ORFactory rationalVar:mdl low:low up:up name:@"x"];
      id<ORRationalVar> y = [ORFactory rationalVar:mdl name:@"y"];
      id<ORRationalVar> z = [ORFactory rationalVar:mdl name:@"z"];
      //[mdl add:[z eq: [x plus: y]]];
      [low set_d: 2];
      [up set_d: 1];
      [mdl add:[y eq: low]];
      [mdl add:[z eq: [x plus: y]]];
      [mdl add:[z leq: up]];
      
      [low release];
      [up release];
      
      //[mdl maximize:z];
      
      NSLog(@"model: %@",mdl);
      id<CPProgram> cp = [ORFactory createCPProgram:mdl];
      //id<CPProgram> cp = [ORFactory createCPSemanticProgram:mdl with:[ORSemBBController proto]];
      
      [cp solve:^{
         [cp labelRational:x];
         NSLog(@"x : [%@;%@] (%s)",[cp minQ:x],[cp maxQ:x],[cp bound:x] ? "YES" : "NO");
         NSLog(@"y : [%@;%@] (%s)",[cp minQ:y],[cp maxQ:y],[cp bound:y] ? "YES" : "NO");
         NSLog(@"z : [%@;%@] (%s)",[cp minQ:z],[cp maxQ:z],[cp bound:z] ? "YES" : "NO");
      }];
      NSLog(@"%@",cp);
   }
}
float nb_float(float nb, int i)
{
   while(i)
   {
      nb = nextafterf(nb, +INFINITY);
      i--;
   }
   return nb;
}
void testR(int argc, const char * argv[]) {
   @autoreleasepool {
      ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
      [args measure:^struct ORResult(){
         //float up = nextafterf((2.0f + 2.5f)/2.0f,+INFINITY);
         // calculate difference between ymax and ymin
         //float high_bound = 2.0f;
         //float low_bound = 2.5f;
         // generate random number between 0 and (ymax-ymin)
         // add ymin to the random number
         //float randomNum = (((float)arc4random()/0x100000000)*(high_bound-low_bound)+low_bound);
         
         id<ORModel> mdl = [ORFactory createModel];
         id<ORRational> zero = [[[ORRational alloc] init] setZero];
         //id<ORRational> low = [[[ORRational alloc] init] set_d: 3.2f];
         //id<ORRational> up = [[[ORRational alloc] init] set_d: 100.0f];
         //ORRational * tmp = [ORRational rationalWith_d:nextafterf(7.15255737304687500000e-07, +INFINITY)];
         id<ORFloatVar> x = [ORFactory floatVar:mdl low:20.3f up:45.0f elow:zero eup:zero name:@"x"];
         id<ORRationalVar> yR = [ORFactory rationalVar:mdl name:@"yR"];
         id<ORRationalVar> xR = [ORFactory rationalVar:mdl name:@"xR"];
         id<ORRationalVar> zR = [ORFactory rationalVar:mdl name:@"zR"];
         id<ORRationalVar> zq = [ORFactory rationalVar:mdl name:@"zq"];
         // y:  3.2 ; 3.4
         id<ORFloatVar> y = [ORFactory floatVar:mdl low:3.2f up:100.0f elow:zero eup:zero name:@"y"];
         //id<ORFloatVar> y = [ORFactory floatVar:mdl low:randomNum up:randomNum elow:zero eup:zero name:@"y"];
         //id<ORFloatVar> o = [ORFactory floatVar:mdl name:@"o"];
         //id<ORFloatVar> k = [ORFactory floatVar:mdl low:2.0f up:3.0f elow:zero eup:zero name:@"k"];
         //id<ORFloatVar> w = [ORFactory floatVar:mdl name:@"w"];
         //id<ORFloatVar> u = [ORFactory floatVar:mdl name:@"u"];
         id<ORFloatVar> z = [ORFactory floatVar:mdl name:@"z"];
         id<ORRationalVar> ez = [ORFactory errorVar:mdl of:z];
         id<ORRationalVar> ezAbs = [ORFactory rationalVar:mdl name:@"|ez|"];
         [zero release];
         
         //[low set_d: 45.0f];
         [mdl add:[x set: @(45.0f)]];
         //[mdl add:[xR eq: low]];
         //[mdl add:[o set: @(2.43f)]];
         
         /*
          Search for input values such that the error on z is greater or equal than tmp
          tmp is the float next after the value found without this constraint
          Bounding the error help find a greater error! (Closer to the maximum)
          P.S. it doesn't change the output value of z (only k and u slightly change, on value and error)
          */
         //[mdl add:[[z error] geq: tmp]];
         
         //[mdl add:[w set: [x plus: y]]];
         //[mdl add:[u set: [o plus: k]]];
         //[mdl add:[z set: [w sub: u]]];
         //[mdl add:[o set: [x div: k]]];
         [mdl add:[z set: [x plus: y]]];
         [mdl add:[ORFactory channel:x with:xR]];
         [mdl add:[ORFactory channel:y with:yR]];

         [mdl add:[zR eq: [xR plus: yR]]];
         
         [mdl add:[ORFactory channel:z with:zq]];
         
         [mdl add:[ez eq:[zR sub: zq]]];
         
         [mdl add: [ezAbs eq: [ez abs]]];
         [mdl maximize:ezAbs];
         
         /*for (float yr = 3.2f; yr <= nb_float(3.2f, NB_FLOAT); yr = nextafterf(yr, +INFINITY)) {
            NSLog(@"@@@@@@@ %20.20e", yr);
         }*/
         
         NSLog(@"model: %@",mdl);
         id<CPProgram> cp = [ORFactory createCPSemanticProgram:mdl with:[ORSemBBController proto]];
         id<ORFloatVarArray> vs = [mdl floatVars];
         id<ORDisabledVarArray> vars = [ORFactory disabledFloatVarArray:vs engine:[cp engine]];
         
         [cp solve:^{
            [cp branchAndBoundSearch:vars out:ezAbs do:^(ORUInt i, id<ORDisabledVarArray> x) {
               [cp floatSplit:i withVars:x];
             }];
//            NSLog(@"concrete model: %@", [[cp engine] model]);
//            NSLog(@"x : [%20.20e;%20.20e] (%s)",[cp minF:x],[cp maxF:x],[cp bound:x] ? "YES" : "NO");
            //NSLog(@"ex: [%@;%@]",[cp minFQ:x],[cp maxFQ:x]);
//            NSLog(@"y : [%20.20e;%20.20e] (%s)",[cp minF:y],[cp maxF:y],[cp bound:y] ? "YES" : "NO");
            //NSLog(@"ey: [%@;%@]",[cp minFQ:y],[cp maxFQ:y]);
            //NSLog(@"o : [%20.20e;%20.20e] (%s)",[cp minF:o],[cp maxF:o],[cp bound:o] ? "YES" : "NO");
            //NSLog(@"eo: [%@;%@]",[cp minFQ:o],[cp maxFQ:o]);
            //NSLog(@"k : [%20.20e;%20.20e] (%s)",[cp minF:k],[cp maxF:k],[cp bound:k] ? "YES" : "NO");
            //NSLog(@"ek: [%@;%@]",[cp minFQ:k],[cp maxFQ:k]);
            /*NSLog(@"w : [%20.20e;%20.20e] (%s)",[cp minF:w],[cp maxF:w],[cp bound:w] ? "YES" : "NO");
             NSLog(@"ew: [%@;%@]",[cp minFQ:w],[cp maxFQ:w]);
             NSLog(@"u : [%20.20e;%20.20e] (%s)",[cp minF:u],[cp maxF:u],[cp bound:u] ? "YES" : "NO");
             NSLog(@"eu: [%@;%@]",[cp minFQ:u],[cp maxFQ:u]);*/
//            NSLog(@"z : [%20.20e;%20.20e] (%s)",[cp minF:z],[cp maxF:z],[cp bound:z] ? "YES" : "NO");
//            NSLog(@"ez: [%@;%@]",[cp minFQ:z],[cp  maxFQ:z]);
            //check_it_f(getFmin(x),getFmin(y),getFmin(o),getFmin(k),getFmin(w),getFmin(u),getFmin(z),[cp minErrorFQ:z]);
            //check_it_bb(getFmin(x),getFmin(y),getFmin(z),[cp minErrorFQ:z]);
         }];
         NSLog(@"%@",cp);
         struct ORResult r = REPORT(1, [[cp explorer] nbFailures],[[cp explorer] nbChoices], [[cp engine] nbPropagation]);
         return r;
      }];
      //[tmp release];
      /*NSLog(@"##################");
      for(int i = 0; i <= NB_FLOAT; i++){
         id<ORRational> tmp = [[ORRational alloc] init];
         [tmp set_d: 0.0f];
         NSLog(@"%20.20e - %d",nb_float(3.2f, i), i);
         check_it_bb(45.0f,nb_float(3.2f, i),48.0f,tmp);
         NSLog(@"------------------------------");
      }
      NSLog(@"##################");*/
   }
}

void testRF(int argc, const char * argv[]) {
   @autoreleasepool {
      ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
      [args measure:^struct ORResult(){
         id<ORModel> mdl = [ORFactory createModel];
         id<ORRational> zero = [[[ORRational alloc] init] setZero];
         id<ORRationalVar> yR = [ORFactory rationalVar:mdl name:@"yR"];
         id<ORRationalVar> xR = [ORFactory rationalVar:mdl name:@"xR"];
         id<ORRationalVar> zR = [ORFactory rationalVar:mdl name:@"zR"];
         //id<ORRationalVar> zq = [ORFactory rationalVar:mdl low:low up:up name:@"zq"];
         id<ORFloatVar> x = [ORFactory floatVar:mdl low:0.0 up:100.0 elow:zero eup:zero name:@"x"];
         id<ORFloatVar> y = [ORFactory floatVar:mdl low:3.20f up:20.0f elow:zero eup:zero name:@"y"];
         id<ORFloatVar> z = [ORFactory floatVar:mdl name:@"z"];
         //id<ORRationalVar> ez = [ORFactory errorVar:mdl of:z];
         //id<ORRationalVar> ezAbs = [ORFactory rationalVar:mdl name:@"|ez|"];
         
         [mdl add:[ORFactory channel:x with:xR]];
         [mdl add:[ORFactory channel:y with:yR]];
         //[mdl add:[ORFactory channel:z with:zq]];

         [mdl add:[x set: @(45.0f)]];

         //[mdl add:[z set: [x plus: y]]];
         [mdl add:[zR eq: [xR plus: yR]]];
         
         [zero set_d: 1];
         [mdl add:[zR leq: zero]];
         
         [zero release];

         NSLog(@"model: %@",mdl);
         //id<CPProgram> cp = [ORFactory createCPSemanticProgram:mdl with:[ORSemBBController proto]];
         id<CPProgram> cp = [ORFactory createCPProgram:mdl];
         id<ORFloatVarArray> vs = [mdl floatVars];
         id<ORDisabledVarArray> vars = [ORFactory disabledFloatVarArray:vs engine:[cp engine]];
         
         [cp solve:^{
//            [cp branchAndBoundSearch:vars out:ezAbs do:^(ORUInt i, id<ORDisabledVarArray> x) {
//               [cp floatSplit:i withVars:x];
//            }];
            [cp lexicalOrderedSearch:vars do:^(ORUInt i, id<ORDisabledVarArray> x) {
               [cp floatSplit:i withVars:x];
            }];
            NSLog(@"x : [%20.20e;%20.20e] (%s)",[cp minF:x],[cp maxF:x],[cp bound:x] ? "YES" : "NO");
            NSLog(@"ex: [%@;%@]",[cp minFQ:x],[cp maxFQ:x]);
            NSLog(@"y : [%20.20e;%20.20e] (%s)",[cp minF:y],[cp maxF:y],[cp bound:y] ? "YES" : "NO");
            NSLog(@"ey: [%@;%@]",[cp minFQ:y],[cp maxFQ:y]);
            NSLog(@"z : [%20.20e;%20.20e] (%s)",[cp minF:z],[cp maxF:z],[cp bound:z] ? "YES" : "NO");
            NSLog(@"ez: [%@;%@]",[cp minFQ:z],[cp maxFQ:z]);
         }];
         NSLog(@"%@",cp);
         struct ORResult r = REPORT(1, [[cp explorer] nbFailures],[[cp explorer] nbChoices], [[cp engine] nbPropagation]);
         return r;
      }];
   }
}


void testRAbs(int argc, const char * argv[]) {
   @autoreleasepool {
      ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
      [args measure:^struct ORResult(){
         
         id<ORModel> mdl = [ORFactory createModel];
         id<ORRational> zero = [[[ORRational alloc] init] setZero];
         //ORRational * tmp = [ORRational rationalWith_d:nextafterf(7.15255737304687500000e-07, +INFINITY)];
         id<ORFloatVar> x = [ORFactory floatVar:mdl low:40.2f up:48.4f elow:zero eup:zero name:@"x"];
         id<ORFloatVar> x1 = [ORFactory floatVar:mdl low:48.4f up:48.4f elow:zero eup:zero name:@"x1"];
         id<ORFloatVar> y = [ORFactory floatVar:mdl low:3.2f up:3.4f elow:zero eup:zero name:@"y"];
         id<ORFloatVar> z = [ORFactory floatVar:mdl name:@"z"];
         id<ORRationalVar> ez = [ORFactory errorVar:mdl of:z];
         id<ORRationalVar> ezAbs = [ORFactory rationalVar:mdl name:@"|ez|"];
         [zero release];
         
         //[mdl add:[x set: @(45.0f)]];
         //[mdl add:[o set: @(2.43f)]];
         
         /*
          Search for input values such that the error on z is greater or equal than tmp
          tmp is the float next after the value found without this constraint
          Bounding the error help find a greater error! (Closer to the maximum)
          P.S. it doesn't change the output value of z (only k and u slightly change, on value and error)
          */
         //[mdl add:[[z error] geq: tmp]];
         
         //[mdl add:[w set: [x plus: y]]];
         //[mdl add:[u set: [o plus: k]]];
         //[mdl add:[z set: [w sub: u]]];
         //[mdl add:[o set: [x div: k]]];
         [mdl add:[z set: [[x plus: x1] mul: y]]];
         //[mdl add:[z set: [x div: y]]];
         
         [mdl add: [ezAbs eq: [ez abs]]];
         [mdl maximize:ezAbs];
         
         /*for (float yr = 3.2f; yr <= nb_float(3.2f, NB_FLOAT); yr = nextafterf(yr, +INFINITY)) {
          NSLog(@"@@@@@@@ %20.20e", yr);
          }*/
         
         NSLog(@"model: %@",mdl);
         id<CPProgram> cp = [ORFactory createCPSemanticProgram:mdl with:[ORSemBBController proto]];
         id<ORFloatVarArray> vs = [mdl floatVars];
         id<ORDisabledVarArray> vars = [ORFactory disabledFloatVarArray:vs engine:[cp engine]];
         
         [cp solve:^{
            [cp branchAndBoundSearch:vars out:ezAbs do:^(ORUInt i, id<ORDisabledVarArray> x) {
               [cp floatSplit:i withVars:x];
            }];
         }];
         NSLog(@"%@",cp);
         struct ORResult r = REPORT(1, [[cp explorer] nbFailures],[[cp explorer] nbChoices], [[cp engine] nbPropagation]);
         return r;
      }];
   }
}

void testRD(int argc, const char * argv[]) {
   @autoreleasepool {
      ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
      [args measure:^struct ORResult(){
         id<ORModel> mdl = [ORFactory createModel];
         id<ORRational> zero = [[[ORRational alloc] init] setZero];
         id<ORDoubleVar> x = [ORFactory doubleVar:mdl low:3.2 up:3.4 elow:zero eup:zero name:@"x"];
         // y:  3.2 ; 3.4
         id<ORDoubleVar> y = [ORFactory doubleVar:mdl low:3.2 up:3.4 elow:zero eup:zero name:@"y"];
         id<ORDoubleVar> z = [ORFactory doubleVar:mdl name:@"z"];
         id<ORRationalVar> ez = [ORFactory errorVar:mdl of:z];
         id<ORRationalVar> ezAbs = [ORFactory rationalVar:mdl name:@"|ez|"];
         [zero release];
         
         //[mdl add:[x set: @(45.0)]];
         
         [mdl add:[z set: [x plus: y]]];
         
         [mdl add: [ezAbs eq: [ez abs]]];
         [mdl maximize:ezAbs];
         
         NSLog(@"model: %@",mdl);
         id<CPProgram> cp = [ORFactory createCPSemanticProgram:mdl with:[ORSemBBController proto]];
         id<ORDoubleVarArray> vs = [mdl doubleVars];
         id<ORDisabledVarArray> vars = [ORFactory disabledFloatVarArray:vs engine:[cp engine]];
         
         [cp solve:^{
            [cp branchAndBoundSearchD:vars out:ezAbs do:^(ORUInt i, id<ORDisabledVarArray> x) {
               [cp floatSplit:i withVars:x];
            }];
         }];
         NSLog(@"%@",cp);
         struct ORResult r = REPORT(1, [[cp explorer] nbFailures],[[cp explorer] nbChoices], [[cp engine] nbPropagation]);
         return r;
      }];
   }
}

void testDiscriminant(int argc, const char * argv[]) {
   @autoreleasepool {
      ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
      [args measure:^struct ORResult(){
         id<ORModel> mdl = [ORFactory createModel];
         id<ORRational> zero = [[[ORRational alloc] init] setZero];
         id<ORDoubleVar> a = [ORFactory doubleVar:mdl name:@"a"];
         id<ORDoubleVar> b = [ORFactory doubleVar:mdl low:3.24884062356828e+12 up:3.24884062357828e+12 elow:zero eup:zero name:@"b"];
         id<ORDoubleVar> c = [ORFactory doubleVar:mdl low:1.832918981126891e+16 up:1.832918981126892e+16 elow:zero eup:zero name:@"c"];
         id<ORDoubleVar> z = [ORFactory doubleVar:mdl name:@"z"];
         id<ORRationalVar> ez = [ORFactory errorVar:mdl of:z];
         id<ORRationalVar> ezAbs = [ORFactory rationalVar:mdl name:@"|ez|"];
         [zero release];
         
         [mdl add: [a set: @(1.43963872E+8)]];
         //[mdl add: [b set: @(7.0)]];
         [mdl add:[z set: [[b mul: b] sub: [[@(4.0) mul: a] mul: c] ]]];
         [mdl add:[z geq: @(0.0)]];
         
         [mdl add: [ezAbs eq: [ez abs]]];
         [mdl maximize:ezAbs];
         
         NSLog(@"model: %@",mdl);
         id<CPProgram> cp = [ORFactory createCPSemanticProgram:mdl with:[ORSemBBController proto]];
         id<ORDoubleVarArray> vs = [mdl doubleVars];
         id<ORDisabledVarArray> vars = [ORFactory disabledFloatVarArray:vs engine:[cp engine]];
         
         [cp solve:^{
//            [cp branchAndBoundSearchD:vars out:ezAbs do:^(ORUInt i, id<ORDisabledVarArray> x) {
//               [cp floatSplit:i withVars:x];
//            }];
            NSLog(@"a : %@",[cp concretize:a]);
            NSLog(@"b : %@",[cp concretize:b]);
            NSLog(@"c : %@",[cp concretize:c]);
            NSLog(@"z : %@",[cp concretize:z]);
         }];
         NSLog(@"%@",cp);
         struct ORResult r = REPORT(1, [[cp explorer] nbFailures],[[cp explorer] nbChoices], [[cp engine] nbPropagation]);
         return r;
      }];
   }
}


void testOptimize(int argc, const char * argv[]) {
   @autoreleasepool {
      id<ORModel> mdl = [ORFactory createModel];
      id<ORIntRange> r0 = RANGE(mdl, 0, 10);
      id<ORIntRange> r1 = RANGE(mdl, -100, +100);
      id<ORIntVar> x = [ORFactory intVar:mdl value:2];
      id<ORIntVar> y = [ORFactory intVar:mdl bounds:r0];
      id<ORIntVar> z = [ORFactory intVar:mdl bounds:r1];
      
      [mdl add:[z eq: [x plus: y]]];
      
      //[mdl maximize:z];
      
      NSLog(@"model: %@",mdl);
      //id<CPProgram> cp = [ORFactory createCPSemanticProgram:mdl with:[ORSemBBController proto]];
      id<CPProgram> cp = [ORFactory createCPProgram:mdl];
      
      [cp solve:^{
         [cp label:y];
         NSLog(@"x : %@",[cp concretize:x]);
         NSLog(@"y : %@",[cp concretize:y]);
         NSLog(@"z : %@",[cp concretize:z]);
      }];
      NSLog(@"%@",cp);
   }
}


int main(int argc, const char * argv[]) {
   LOO_MEASURE_TIME(@"testR"){
//   testIntBFS(argc, argv);
//   testR(argc, argv);
      testRF(argc, argv);
   //testRD(argc, argv);
   //testDiscriminant(argc, argv);
   //testRAbs(argc, argv);
   
//   float ye = nb_float(3.2f, NB_FLOAT);
//   float_interval z, x, y;
//   z = makeFloatInterval(4.82000007629394531250e+01f,4.82000045776367187500e+01f);
//   x = makeFloatInterval(4.50000000000000000000e+01f,4.50000000000000000000e+01f);
//   y = makeFloatInterval(3.2f,ye);
   
   //NSLog(@"[%20.20e,%20.20e] = [%20.20e,%20.20e] + [%20.20e,%20.20e]",z.inf, z.sup, x.inf, x.sup, y.inf, y.sup);
   //fpi_addf(0, FE_TONEAREST, &z, &x, &y);
   //NSLog(@"[%20.20e,%20.20e] = [%20.20e,%20.20e] + [%20.20e,%20.20e]",z.inf, z.sup, x.inf, x.sup, y.inf, y.sup);
//
//   float zr, xr , yr, uz;
//   xr = 4.50000000000000000000e+01f;
//   NSLog(@"#############################");
//   for (yr = 3.2f; yr <= ye; yr = nextafterf(yr, +INFINITY)) {
//      zr = xr + yr;
//      uz = nextafterf(zr, +INFINITY) - zr;
//      //NSLog(@"%20.20e = %20.20e + %20.20e   (%20.20e)",zr, xr, yr, uz);
//      check_it_bb(xr, yr, zr, NULL);
//   }
   
   //testRational(argc, argv);
   //testOptimize(argc, argv);
   }
   return 0;
}
