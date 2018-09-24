//
//  infinite_propagation.m
//  Clo
//
//  Created by Rémy Garcia on 07/09/2018.
//

#import <ORProgram/ORProgram.h>
#import "ORCmdLineArgs.h"

void check_it_f(float x, float y, float z, id<ORRational> ez) {
   mpq_t qy, qx, tmp0, tmp1;
   float cz = x + y;
   
   //NSLog(@"x:% 20.20e\ny:% 20.20e\nz:% 20.20e",x,y,z);
   if (cz != z)
      printf("WRONG: cz = % 20.20e != z = % 20.20e\n", cz, z);
   
   mpq_inits(qy, qx, tmp0, tmp1, NULL);
   
   //NSLog(@"%f",x);
   mpq_set_d(qx, x);
   mpq_set_d(qy, y);
   mpq_add(tmp1, qx, qy);
   
   mpq_set_d(tmp0, cz);
   mpq_sub(tmp1, tmp1, tmp0);
   // La différence vient de ce que minError retourne un flottant au lieu d'un double !
   if (mpq_cmp(tmp1, ez.rational) != 0){
      NSLog(@"%s != %@", mpq_get_str(NULL, 10, tmp1), ez);
      NSLog(@"WRONG: Err found = % 24.24e\n != % 24.24e\n", mpq_get_d(tmp1), [ez get_d]);
   }
   mpq_clears(qy, qx, tmp0, tmp1, NULL);
}

int main(int argc, const char * argv[]) {
   @autoreleasepool {
      id<ORModel> mdl = [ORFactory createModel];
      ORRational * zero = [[[ORRational alloc] init] setZero];
      ORRational * infinity = [[[ORRational alloc] init] setPosInf];
      ORRational * v = [ORRational rationalWith_d:0.00000000746];
      id<ORFloatVar> x = [ORFactory floatVar:mdl name:@"x"];
      id<ORFloatVar> y = [ORFactory floatVar:mdl low:0.2f up:0.4f elow:zero eup:zero name:@"y"];
      id<ORFloatVar> z = [ORFactory floatVar:mdl low:-INFINITY up:+INFINITY elow:v eup:infinity name:@"z"];
      [zero release];
      [v release];
      [infinity release];

      [mdl add:[x set: @(0.1f)]];
      
      //[mdl add:[[z error] geq: v]];
      
      [mdl add:[z set: [x plus: y]]];
      
      NSLog(@"model: %@",mdl);
      id<CPProgram> cp = [ORFactory createCPProgram:mdl];
      id<ORFloatVarArray> vs = [mdl floatVars];
      id<ORDisabledFloatVarArray> vars = [ORFactory disabledFloatVarArray:vs engine:[cp engine]];
      
      //[cp setMinErrorFD:z minErrorF:0.00000000746];
      [cp solve:^{
         [cp lexicalOrderedSearch:vars do:^(ORUInt i, SEL s, id<ORDisabledFloatVarArray> x) {
            [cp floatSplit:i call:s withVars:x];
         }];
         NSLog(@"x : [%16.16e;%16.16e] (%s)",[cp minF:x],[cp maxF:x],[cp bound:x] ? "YES" : "NO");
         NSLog(@"ex: [%@;%@]",[cp minFQ:x],[cp maxFQ:x]);
         NSLog(@"y : [%16.16e;%16.16e] (%s)",[cp minF:y],[cp maxF:y],[cp bound:y] ? "YES" : "NO");
         NSLog(@"ey: [%@;%@]",[cp minFQ:y],[cp maxFQ:y]);
         NSLog(@"z : [%16.16e;%16.16e] (%s)",[cp minF:z],[cp maxF:z],[cp bound:z] ? "YES" : "NO");
         NSLog(@"ez: [%@;%@]",[cp minFQ:z],[cp  maxFQ:z]);
         check_it_f([cp minF:x],[cp minF:y],[cp minF:z],[cp minErrorFQ:z]);
      }];
      NSLog(@"%@",cp);
   }
   return 0;
}
