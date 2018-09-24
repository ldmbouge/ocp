//
//  range_add_mult.m
//  Clo
//
//  Created by Rémy Garcia on 05/09/2018.
//
#import <ORProgram/ORProgram.h>
#include "gmp.h"

#define LOO_MEASURE_TIME(__message) \
for (CFAbsoluteTime startTime##__LINE__ = CFAbsoluteTimeGetCurrent(), endTime##__LINE__ = 0.0; endTime##__LINE__ == 0.0; \
NSLog(@"'%@' took %.3fs", (__message), (endTime##__LINE__ = CFAbsoluteTimeGetCurrent()) - startTime##__LINE__))

void check_it_f(float x, float y, float z, float r, id<ORRational> er) {
   mpq_t qx, qy, qz, tmp0, tmp1;
   float cr = x + y * z;
   
   if (cr != r)
      printf("WRONG: cr = %20.20e != r = %20.20e\n", cr, r);
   
   mpq_inits(qx, qy, qz, tmp0, tmp1, NULL);
   
   // x+y*z
   mpq_set_d(qx, x);
   mpq_set_d(qy, y);
   mpq_set_d(qz, z);
   mpq_mul(tmp0, qy, qz);
   mpq_add(tmp1, qx, tmp0);
   
   mpq_set_d(tmp0, cr);
   mpq_sub(tmp1, tmp1, tmp0);
   // La différence vient de ce que minError retourne un flottant au lieu d'un double !
   if (mpq_cmp(tmp1, er.rational) != 0){
      NSLog(@"%s != %@", mpq_get_str(NULL, 10, tmp1), er);
      NSLog(@"WRONG: Err found = % 24.24e\n != % 24.24e\n", mpq_get_d(tmp1), [er get_d]);
   }
   mpq_clears(qx, qy, qz, tmp0, tmp1, NULL);
}

void range_add_mult_f(int search, int argc, const char * argv[]) {
   @autoreleasepool {
      id<ORModel> mdl = [ORFactory createModel];
      id<ORRational> zero = [ORRational rationalWith_d:0.0f];
      id<ORFloatVar> x = [ORFactory floatVar:mdl low:0.0f up:180.0f elow:zero eup:zero name:@"x"];
      id<ORFloatVar> y = [ORFactory floatVar:mdl low:-180.0f up:0.0f elow:zero eup:zero name:@"y"];
      id<ORFloatVar> z = [ORFactory floatVar:mdl low:0.0f up:1.0f elow:zero eup:zero name:@"z"];
      id<ORFloatVar> r = [ORFactory floatVar:mdl name:@"r"];
      [zero release];
      
      [mdl add:[[x plus: y] geq: @(0.0f)]];
      
      [mdl add:[r set: [x plus: [y mul: z]]]];
      
      [mdl add:[[r lt: @(0.0f)] lor: [r gt: @(360.0f)]]];
      
      NSLog(@"model: %@",mdl);
      id<ORFloatVarArray> vs = [mdl floatVars];
      id<CPProgram> cp = [ORFactory createCPProgram:mdl];
      id<ORDisabledFloatVarArray> vars = [ORFactory disabledFloatVarArray:vs engine:[cp engine]];
      
      [cp solve:^{
         if (search)
            [cp lexicalOrderedSearch:vars do:^(ORUInt i, SEL s, id<ORDisabledFloatVarArray> x) {
               [cp floatSplit:i call:s withVars:x];
            }];
         NSLog(@"%@",cp);
         NSLog(@"x : [%20.20e;%20.20e]±[%@;%@] (%s)",[cp minF:x],[cp maxF:x],[cp minFQ:x],[cp maxFQ:x],[cp bound:x] ? "YES" : "NO");
         NSLog(@"y : [%20.20e;%20.20e]±[%@;%@] (%s)",[cp minF:y],[cp maxF:y],[cp minFQ:y],[cp maxFQ:y],[cp bound:y] ? "YES" : "NO");
         NSLog(@"z : [%20.20e;%20.20e]±[%@;%@] (%s)",[cp minF:z],[cp maxF:z],[cp minFQ:z],[cp maxFQ:z],[cp bound:z] ? "YES" : "NO");
         NSLog(@"r : [%20.20e;%20.20e]±[%@;%@] (%s)",[cp minF:r],[cp maxF:r],[cp minFQ:r],[cp maxFQ:r],[cp bound:r] ? "YES" : "NO");

         if (search) check_it_f([cp minF:x],[cp minF:y],[cp minF:z],[cp minF:r],[cp minErrorFQ:r]);
      }];
   }
}

int main(int argc, const char * argv[]) {
   LOO_MEASURE_TIME(@"d"){
      range_add_mult_f(1, argc, argv);
   }
   return 0;
}
