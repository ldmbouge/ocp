//
//  guarded_div.m
//  Clo
//
//  Created by Rémy Garcia on 06/09/2018.
//
#import <ORProgram/ORProgram.h>
#include "gmp.h"

#define LOO_MEASURE_TIME(__message) \
for (CFAbsoluteTime startTime##__LINE__ = CFAbsoluteTimeGetCurrent(), endTime##__LINE__ = 0.0; endTime##__LINE__ == 0.0; \
NSLog(@"'%@' took %.3fs", (__message), (endTime##__LINE__ = CFAbsoluteTimeGetCurrent()) - startTime##__LINE__))

void check_it_f(float x, float y, float r, id<ORRational> er) {
   mpq_t qx, qy, tmp0, tmp1;
   float cr = x / y;
   
   if (cr != r)
      NSLog(@"WRONG: cr = %20.20e != r = %20.20e\n", cr, r);
   if (x < 0.0f)
      NSLog(@"WRONG: x (%20.20e) <= 0.0f",x);
   if(y <= 0.1f)
      NSLog(@"WRONG: y (%20.20e) <= 0.1f",y);
   if(y >= 1.0f)
      NSLog(@"WRONG: y (%20.20e) >= 1.0f",y);
   if(x/1000.0f > y)
      NSLog(@"WRONG: x (%20.20e) / 1000.0f > y (%20.20e)",x,y);
   
   mpq_inits(qx, qy, tmp0, tmp1, NULL);
   
   mpq_set_d(qx, x);
   mpq_set_d(qy, y);
   mpq_div(tmp1, qx, qy);
   
   mpq_set_d(tmp0, cr);
   mpq_sub(tmp1, tmp1, tmp0);
   // La différence vient de ce que minError retourne un flottant au lieu d'un double !
   if (mpq_cmp(tmp1, er.rational) != 0){
      NSLog(@"%s != %@", mpq_get_str(NULL, 10, tmp1), er);
      NSLog(@"WRONG: Err found = % 24.24e\n != % 24.24e\n", mpq_get_d(tmp1), [er get_d]);
   }
   mpq_clears(qx, qy, tmp0, tmp1, NULL);
}

void guarded_div_f(int search, int argc, const char * argv[]) {
   @autoreleasepool {
      id<ORModel> mdl = [ORFactory createModel];
      id<ORRational> zero = [ORRational rationalWith_d:0.0f];
      id<ORFloatVar> x = [ORFactory floatVar:mdl low:-INFINITY up:+INFINITY elow:zero eup:zero name:@"x"];
      id<ORFloatVar> y = [ORFactory floatVar:mdl low:-INFINITY up:+INFINITY elow:zero eup:zero name:@"x"];
      id<ORFloatVar> t = [ORFactory floatVar:mdl name:@"t"];
      id<ORFloatVar> r = [ORFactory floatVar:mdl name:@"r"];
      [zero release];
      
      [mdl add:[t set: @(1000.0f)]];
      [mdl add:[x geq: @(0.0f)]];
      [mdl add:[y gt: @(0.1f)]];
      [mdl add:[y lt: @(1.0f)]];
      [mdl add:[y geq: [x div: t]]];
      
      [mdl add:[r set: [x div: y]]];
      
      [mdl add:[r geq: t]];
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
         NSLog(@"t : [%20.20e;%20.20e]±[%@;%@] (%s)",[cp minF:t],[cp maxF:t],[cp minFQ:t],[cp maxFQ:t],[cp bound:t] ? "YES" : "NO");
         NSLog(@"r : [%20.20e;%20.20e]±[%@;%@] (%s)",[cp minF:r],[cp maxF:r],[cp minFQ:r],[cp maxFQ:r],[cp bound:r] ? "YES" : "NO");
         
         if (search) check_it_f([cp minF:x],[cp minF:y],[cp minF:r],[cp minErrorFQ:r]);
      }];
   }
}

int main(int argc, const char * argv[]) {
   LOO_MEASURE_TIME(@"d"){
      guarded_div_f(1, argc, argv);
   }
   return 0;
}
