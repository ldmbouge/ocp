//
//  sine.m
//  ORUtilities
//
//  Created by Remy Garcia on 11/04/2018.
//

#import <ORProgram/ORProgram.h>
#include "gmp.h"

#define LOO_MEASURE_TIME(__message) \
for (CFAbsoluteTime startTime##__LINE__ = CFAbsoluteTimeGetCurrent(), endTime##__LINE__ = 0.0; endTime##__LINE__ == 0.0; \
NSLog(@"'%@' took %.3fs", (__message), (endTime##__LINE__ = CFAbsoluteTimeGetCurrent()) - startTime##__LINE__))

void check_it_sine_f(float x, float z, id<ORRational> ez) {
   double cz = (((x - (((x * x) * x) / 6.0f)) + (((((x * x) * x) * x) * x) / 120.0f)) - (((((((x * x) * x) * x) * x) * x) * x) / 5040.0f));
   
   if (cz != z)
      NSLog(@"WRONG: z  = % 24.24e while cz  = % 24.24e\n", z, cz);
   
   {
      mpq_t xq, zq, tmp0, tmp1, tmp2, tmp3, tmp4, tmp5, tmp6, tmp7, tmp8, tmp9, tmp10, tmp11, tmp12, tmp13, tmp14, tmp15, tmp16, tmp17, tmp18, tmp19, tmp20, tmp21;
      
      mpq_inits(xq, zq, tmp0, tmp1, tmp2, tmp3, tmp4, tmp5, tmp6, tmp7, tmp8, tmp9, tmp10, tmp11, tmp12, tmp13, tmp14, tmp15, tmp16, tmp17, tmp18, tmp19, tmp20, tmp21, NULL);
      mpq_set_d(xq, x);
      
      mpq_mul(tmp1, xq, xq);
      mpq_mul(tmp2, tmp1, xq);
      mpq_set_d(tmp3, 6.0f);
      mpq_div(tmp4, tmp2, tmp3);
      mpq_sub(tmp5, xq, tmp4);
      mpq_mul(tmp6, xq, xq);
      mpq_mul(tmp7, tmp6, xq);
      mpq_mul(tmp8, tmp7, xq);
      mpq_mul(tmp9, tmp8, xq);
      mpq_set_d(tmp10, 120.0f);
      mpq_div(tmp11, tmp9, tmp10);
      mpq_add(tmp12, tmp5, tmp11);
      mpq_mul(tmp13, xq, xq);
      mpq_mul(tmp14, tmp13, xq);
      mpq_mul(tmp15, tmp14, xq);
      mpq_mul(tmp16, tmp15, xq);
      mpq_mul(tmp17, tmp16, xq);
      mpq_mul(tmp18, tmp17, xq);
      mpq_set_d(tmp19, 5040.0f);
      mpq_div(tmp20, tmp18, tmp19);
      mpq_sub(tmp21, tmp12, tmp20);
      mpq_set(zq, tmp21);
      
      mpq_set_d(tmp0, z);
      mpq_sub(tmp1, zq, tmp0);
      if (mpq_cmp(tmp1, [ez rational]) != 0){
         NSLog(@"%s != %@", mpq_get_str(NULL, 10, tmp1), ez);
         NSLog(@"WRONG: Err found = % 24.24e\n != % 24.24e\n", mpq_get_d(tmp1), [ez get_d]);
      }
      mpq_clears(xq, zq, tmp0, tmp1, tmp2, tmp3, tmp4, tmp5, tmp6, tmp7, tmp8, tmp9, tmp10, tmp11, tmp12, tmp13, tmp14, tmp15, tmp16, tmp17, tmp18, tmp19, tmp20, tmp21, NULL);
   }
   
}

void check_it_sine_d(double x, double z, id<ORRational> ez) {
   double cz = (((x - (((x * x) * x) / 6.0)) + (((((x * x) * x) * x) * x) / 120.0)) - (((((((x * x) * x) * x) * x) * x) * x) / 5040.0));
   
   if (cz != z)
      printf("WRONG: z  = % 24.24e while cz  = % 24.24e\n", z, cz);
   
   {
      mpq_t xq, zq, tmp0, tmp1, tmp2, tmp3, tmp4, tmp5, tmp6, tmp7, tmp8, tmp9, tmp10, tmp11, tmp12, tmp13, tmp14, tmp15, tmp16, tmp17, tmp18, tmp19, tmp20, tmp21;
      
      mpq_inits(xq, zq, tmp0, tmp1, tmp2, tmp3, tmp4, tmp5, tmp6, tmp7, tmp8, tmp9, tmp10, tmp11, tmp12, tmp13, tmp14, tmp15, tmp16, tmp17, tmp18, tmp19, tmp20, tmp21, NULL);
      mpq_set_d(xq, x);
      
      mpq_mul(tmp1, xq, xq);
      mpq_mul(tmp2, tmp1, xq);
      mpq_set_d(tmp3, 6.0);
      mpq_div(tmp4, tmp2, tmp3);
      mpq_sub(tmp5, xq, tmp4);
      mpq_mul(tmp6, xq, xq);
      mpq_mul(tmp7, tmp6, xq);
      mpq_mul(tmp8, tmp7, xq);
      mpq_mul(tmp9, tmp8, xq);
      mpq_set_d(tmp10, 120.0);
      mpq_div(tmp11, tmp9, tmp10);
      mpq_add(tmp12, tmp5, tmp11);
      mpq_mul(tmp13, xq, xq);
      mpq_mul(tmp14, tmp13, xq);
      mpq_mul(tmp15, tmp14, xq);
      mpq_mul(tmp16, tmp15, xq);
      mpq_mul(tmp17, tmp16, xq);
      mpq_mul(tmp18, tmp17, xq);
      mpq_set_d(tmp19, 5040.0);
      mpq_div(tmp20, tmp18, tmp19);
      mpq_sub(tmp21, tmp12, tmp20);
      mpq_set(zq, tmp21);
      
      mpq_set_d(tmp0, z);
      mpq_sub(tmp1, zq, tmp0);
      if (mpq_cmp(tmp1, ez.rational) != 0){
         NSLog(@"%s != %@", mpq_get_str(NULL, 10, tmp1), ez);
         NSLog(@"WRONG: Err found = % 24.24e\n != % 24.24e\n", mpq_get_d(tmp1), [ez get_d]);
      }
      mpq_clears(xq, zq, tmp0, tmp1, tmp2, tmp3, tmp4, tmp5, tmp6, tmp7, tmp8, tmp9, tmp10, tmp11, tmp12, tmp13, tmp14, tmp15, tmp16, tmp17, tmp18, tmp19, tmp20, tmp21, NULL);
   }
   
}

void check_it_sine_d_tmp(double x, double z, id<ORRational> ez) {
   double cz = (x - (((x * x) * x) / 6.0)) + x;
   
   if (cz != z)
      printf("WRONG: z  = % 24.24e while cz  = % 24.24e\n", z, cz);
   
   {
      mpq_t xq, zq, tmp0, tmp1, tmp2, tmp3, tmp4, tmp5, tmp6, tmp7, tmp8, tmp9, tmp10, tmp11, tmp12, tmp13, tmp14, tmp15, tmp16, tmp17, tmp18, tmp19, tmp20, tmp21;
      
      mpq_inits(xq, zq, tmp0, tmp1, tmp2, tmp3, tmp4, tmp5, tmp6, tmp7, tmp8, tmp9, tmp10, tmp11, tmp12, tmp13, tmp14, tmp15, tmp16, tmp17, tmp18, tmp19, tmp20, tmp21, NULL);      mpq_set_d(xq, x);
      
      mpq_mul(tmp1, xq, xq);
      mpq_mul(tmp2, tmp1, xq);
      mpq_set_d(tmp3, 6.0);
      mpq_div(tmp4, tmp2, tmp3);
      mpq_sub(tmp5, xq, tmp4);
      mpq_add(tmp5, tmp5, xq);
      mpq_set(zq, tmp5);
      
      mpq_set_d(tmp0, z);
      mpq_sub(tmp1, zq, tmp0);
      if (mpq_cmp(tmp1, ez.rational) != 0){
         NSLog(@"%s != %@", mpq_get_str(NULL, 10, tmp1), ez);
         NSLog(@"WRONG: Err found = % 24.24e\n != % 24.24e\n", mpq_get_d(tmp1), [ez get_d]);
      }
      mpq_clears(xq, zq, tmp0, tmp1, tmp2, tmp3, tmp4, tmp5, tmp6, tmp7, tmp8, tmp9, tmp10, tmp11, tmp12, tmp13, tmp14, tmp15, tmp16, tmp17, tmp18, tmp19, tmp20, tmp21, NULL);
   }
   
}

void sine_d(int search, int argc, const char * argv[]) {
   @autoreleasepool {
      id<ORModel> mdl = [ORFactory createModel];
      id<ORRational> zero = [ORRational rationalWith_d:0.0];
      id<ORDoubleVar> x = [ORFactory doubleVar:mdl low:-1.57079632679 up:1.57079632679 elow:zero eup:zero name:@"x"];
      id<ORDoubleVar> z = [ORFactory doubleVar:mdl name:@"z"];
      
      [mdl add:[z set: [[[x sub: [ [[x mul: x] mul: x] div: @(6.0)]] plus: [[[[[x mul: x] mul: x] mul: x] mul: x] div: @(120.0)]] sub: [[[[[[[x mul: x] mul: x] mul: x] mul: x] mul: x] mul: x] div: @(5040.0)]]]];
      
      [mdl add:[z lt: @(1.0)]];
      [mdl add:[z gt: @(-1.0)]];
      
      NSLog(@"model: %@",mdl);
      id<ORDoubleVarArray> vs = [mdl doubleVars];
      id<CPProgram> cp = [ORFactory createCPProgram:mdl];
      id<ORDisabledFloatVarArray> vars = [ORFactory disabledFloatVarArray:vs engine:[cp engine]];
      
      [cp solve:^{
         if (search)
            [cp lexicalOrderedSearch:vars do:^(ORUInt i, SEL s, id<ORDisabledFloatVarArray> x) {
               [cp floatSplitD:i call:s withVars:x];
            }];
         NSLog(@"%@",cp);
         NSLog(@"x : [%20.20e;%20.20e]±[%@;%@] (%s)",[cp minD:x],[cp maxD:x],[cp minDQ:x],[cp maxDQ:x],[cp bound:x] ? "YES" : "NO");
         NSLog(@"z : [%20.20e;%20.20e]±[%@;%@] (%s)",[cp minD:z],[cp maxD:z],[cp minDQ:z],[cp maxDQ:z],[cp bound:z] ? "YES" : "NO");
         if (search) check_it_sine_d([cp minD:x], [cp minD:z], [cp minErrorDQ:z]);
      }];
   }
}

void sine_f(int search, int argc, const char * argv[]) {
   @autoreleasepool {
      id<ORModel> mdl = [ORFactory createModel];
      id<ORRational> zero = [ORRational rationalWith_d:0.0f];
      id<ORFloatVar> x = [ORFactory floatVar:mdl low:-1.57079632679f up:1.57079632679f elow:zero eup:zero name:@"x"];
      id<ORFloatVar> z = [ORFactory floatVar:mdl name:@"z"];
      id<ORFloatVar> mul1 = [ORFactory floatVar:mdl name:@"mul1"];
      
      //[mdl add:[x set:  @(1.57079632679000003037) ]];
      [mdl add:[mul1 set: x]];
      [mdl add:[z set: [[[x sub: [ [[x mul: x] mul: x] div: @(6.0f)]] plus: [[[[[x mul: x] mul: x] mul: x] mul: x] div: @(120.0f)]] sub: [[[[[[[x mul: x] mul: x] mul: x] mul: x] mul: x] mul: x] div: @(5040.0f)]]]];
      //[mdl add: [z set: [[x sub: [ [[x mul: x] mul: x] div: @(6.0)]] plus: [[[[[x mul: x] mul: x] mul: x] mul: x] div: @(120.0)]]]];
      
      [mdl add:[z lt: @(1.0f)]];
      [mdl add:[z gt: @(-1.0f)]];
      
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
         NSLog(@"mul1 : [%20.20e;%20.20e]±[%@;%@] (%s)",[cp minF:mul1],[cp maxF:mul1],[cp minFQ:mul1],[cp maxFQ:mul1],[cp bound:mul1] ? "YES" : "NO");
         NSLog(@"z : [%20.20e;%20.20e]±[%@;%@] (%s)",[cp minF:z],[cp maxF:z],[cp minFQ:z],[cp maxFQ:z],[cp bound:z] ? "YES" : "NO");
         if (search) check_it_sine_f([cp minF:x], [cp minF:z], [cp minErrorFQ:z]);
      }];
   }
}
int main(int argc, const char * argv[]) {
   LOO_MEASURE_TIME(@"p"){
      sine_d(1, argc, argv);
   }
   return 0;
}
