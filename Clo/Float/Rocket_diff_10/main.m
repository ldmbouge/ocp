//
//  Trapeze_diff_10.m
//  rumps
//
//  Created by cpjm on 25/08/2019.
//  Copyright © 2019 Laurent Michel. All rights reserved.
//

#import <ORProgram/ORProgram.h>
#import "ORCmdLineArgs.h"

/*
 Constants are: The radius of the Earth R = 6.4 · 106 m, the gravity
 G = 6.67428 · 10−11 m3·kg−1.s−2, the mass of the Earth Mt =
 5.9736 · 1024 kg, the mass of the rocket Mf = 150000 kg and the
 gas mass ejected by seconde A = 140 kg·s−1. The release rate of
 the rocket vl is 0.7· sqrt((G·Mt) /D) with D = R + 4.0 · 105 m the distance
 between the rocket and the Earth. Other variables are set to 0.
 // Rocket (These Nasrine Damouche P96, L6.2 & L6.3 and paper
 Optimizing the Accuracy of a Rocket Trajectory Simulation
 by Program Transformation
 // Original
 Mf = 150000; R = 6.4 * 10e6 ; A = 140;
 G = 6.67428 * 10e−11;
 M_t = 5.9736 * 10e24;
 D = R + 4.0 * 10e5 ;
 v_l = 0.7 * sqrt ((G * M_t) / (D)) ;
 while ( i < nbsteps ) do {
 if ( m_f > 0.0 ) {
 u2_1 = u2 * dt + u1 ;
 u2_3 = u4 * dt + u3 ;
 w2_1 = w2 * dt + w1 ;
 w2_3 = w4 * dt + w3 ;
 u2_2 = −G * Mt / ( u1 * u1 ) * dt + u1 * u4 * u4 * dt + u2 ;
 u2_4 = −2.0 * u2 * u4 / u1 * dt + u4 ;
 w2_2 = −G * Mt / (w1 * w1 ) * dt + w1 * w4 * w4 * dt + (A * w2 ) / (Mf − A * t ) * dt + w2 ;
 w2_4 = −2.0 * w2 * w4 / w1 * dt + A * w4 / (Mf − A * t ) * dt + w4 ;
 m2_f = mf − A * t ;
 t = t + dt ;
 }else {
 u2_1 = u2 * dt + u1 ;
 u2_3 = u4 * dt + u3 ;
 w2_1 = w2 * dt + w1 ;
 w2_3 = w4 * dt + w3 ;
 u2_2 = −G * Mt / ( u1 * u1 ) * dt + u1 * u4 * u4 * dt + u2 ;
 u2_4 = −2.0 * u2 * u4 / u1 * dt + u4 ;
 w2_2 = −G * Mt / (w1 * w1 ) * dt + w1 * w4 * w4 * dt + w2 ;
 w2_4 = −2.0 * w2 * w4 / w1 * dt + w4 ;
 m2_f = mf
 t = t + dt;
 }
 c = 1.0 − (w2_3*u2_3 * 0.5 ) ;
 s = u2_3 − (u2_3*u2_3*u2_3) / 0.166666667;
 x = w2_1 * c ;
 y = w2_1 * s ;
 i= i +1.0;
 u1=u2_1;
 u2=u2_2;
 u3=u2_3;
 u4=u2_4;
 w1=w2_1;
 w2=w2_2;
 w3=w2_3;
 w4=w2_4;
 mf=m2_f ;
 }
 
 // Optimized
 while ( i < nbsteps ) do {
 if ( m_f > 0.0 ) {
 TMP_2 = ( u1 * u1 ) ;
 TMP_4 = ( 59735.99e20 / (w1 * w1 )) ;
 TMP_10 = ( 140.0 * t ) ;
 m2_f = ( mf + ( t * ( −140.0 ))) ;
 u2_1 = ( u1 + ( u2 * 0.1 )) ;
 u2_3 = ( u3 + ( u4 * 0.1 )) ;
 w2_1 = (w1 + (w2 * 0.1 )) ;
 w2_3 = (w3 + (w4 * 0.1 )) ;
 u2_2 = (( − (( 0.66743e−10 * ( 59735.99e20 / TMP_2 )) * 0.1 ) + ((( u1 * u4 ) * u4 ) * 0.1 )) + u2);
 u2_4 = (((−2.0 * ( u2 * ( u4 / u1 ))) * 0.1 ) + u4 ) ;
 w2_2 = (((−((0.66743e(−10) * TMP_4) * 0.1)+ ((( w1 * w4 ) * w4 ) * 0.1)) + ((( 140.0 * w2 ) / ( 150000.0 − ( 140.0 * t ))) * 0.1 )) + w2 ) ;
 w2_4 = ((( −2.0 * (w2 * (w4 / w1 ))) * 0.1) + ((140.0 * (( w4 / ( 150000.0 − TMP_10)) * 0.1 )) + w4 ));
 t = t + 0 . 1 ;
 }else {
 TMP_2 = ( u1 * u1 ) ;
 TMP_14 = (w1 * w1 ) ;
 u2_1 = ( u1 + ( u2 * 0.1 )) ;
 u2_3 = ( u3 + ( u4 * 0.1 )) ;
 w2_1 = (w1 + (w2 * 0.1 )) ;
 w2_3 = (w3 + (w4 * 0.1 )) ;
 u2_2 = (( − (( 0.66743e−10 * ( 59735.99e20 / TMP_2)) * 0.1 ) + ((( u1 * u4 ) * u4 ) * 0.1 )) + u2 ) ;
 u2_4 = ((( −2.0 * ( u2 * ( u4 / u1 ))) * 0.1 ) + u4 );
 w2_i = (( − (( 0.66743e−10 * (59735.99e20 / TMP_14 )) * 0.1 ) + ((( w1 * w4 ) * w4 ) * 0.1 )) + w2 ) ;
 w4_i = ((( −2.0 * (w2 * (w4 / w1 ))) * 0.1 ) + w4 ) ;
 t = t + 0 . 1 ;
 }
 c = ( 1.0 − (( u3 + ( u4 * 0.1 )) * ( 0.5 * ( u3 + ( u4 * 0.1 ))))) ; s = (( u3 + ( u4 * 0.1 )) − ((( u3 + ( u4 * 0.1 )) * (( u3 + ( u4 * 0.1 )) * ( u3 + ( u4 * 0.1 )))) / 0.166666667)) ;
 x = ( c * ( u1 + ( u2 * 0.1 ))) ; y = ( s * ( u1 + ( u2 * 0.1 ))) ;
 i = i + 1.0 ;
 u1=u2_1;
 u2=u2_2;
 u3=u2_3;
 u4=u2_4;
 w1=w2_1;
 w2=w2_2;
 w3=w2_3;
 w4=w2_4;
 mf=m2_f ;
 }
 */

#define NBLOOPS 1

int main(int argc, const char * argv[]) {
   /*
    1: Logic
    2: Guarded
    */
   int first_if = 2;
   
   @autoreleasepool {
      ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
      
      id<ORModel> model = [ORFactory createModel];
      
      NSMutableArray* toadd = [[NSMutableArray alloc] init];
      
      // Constants
      id<ORExpr> Mf   = [ORFactory float:model value:150000.f];
      id<ORExpr> R = [ORFactory float:model value:6.4e6f];
      id<ORExpr> A  = [ORFactory float:model value:140.0f];
      id<ORExpr> G  = [ORFactory float:model value:6.67428e-11f];
      id<ORExpr> M_t  = [ORFactory float:model value:5.9736e24f];
      id<ORExpr> D  = [ORFactory float:model value:([D floatValue] + 4.0e5f)];
      id<ORExpr> v_l  = [ORFactory float:model value:(0.7f * sqrtf(([G floatValue] * [M_t floatValue]) / [D floatValue]))];
      
//      other constants
       id<ORExpr> c1   = [ORFactory float:model value:-2.0f];
       id<ORExpr> c2   = [ORFactory float:model value:0.166666667f];
       id<ORExpr> c3   = [ORFactory float:model value:0.66743e-10f];
       id<ORExpr> c4   = [ORFactory float:model value:59735.99e20f];
   
      
      // Local vars
      //      --------
      // original var
      id<ORFloatVarArray> u1 = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS) names:@"u1"];
      id<ORFloatVarArray> u2 = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS) names:@"u2"];
      id<ORFloatVarArray> u3 = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS) names:@"u3"];
      id<ORFloatVarArray> u4 = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS) names:@"u4"];
      
      id<ORFloatVarArray> w1 = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS) names:@"w1"];
      id<ORFloatVarArray> w2 = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS) names:@"w2"];
      id<ORFloatVarArray> w3 = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS) names:@"w3"];
      id<ORFloatVarArray> w4 = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS) names:@"w4"];
      
      
      id<ORFloatVarArray> mf = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS) names:@"mf"];
      
      id<ORFloatVarArray> u2_1 = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS) names:@"u2_1"];
      id<ORFloatVarArray> u2_2 = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS) names:@"u2_2"];
      id<ORFloatVarArray> u2_3 = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS) names:@"u2_3"];
      id<ORFloatVarArray> u2_4 = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS) names:@"u2_4"];
      
      id<ORFloatVarArray> w2_1 = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS) names:@"w2_1"];
      id<ORFloatVarArray> w2_2 = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS) names:@"w2_2"];
      id<ORFloatVarArray> w2_3 = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS) names:@"w2_3"];
      id<ORFloatVarArray> w2_4 = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS) names:@"w2_4"];
      
      
      id<ORFloatVarArray> m2_f = [ORFactory floatVarArray:model range:RANGE(model, 1, NBLOOPS) names:@"m2_f"];
      //      --------
      //      --------
      // optimized var
      id<ORFloatVarArray> u1_opt = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS) names:@"u1_opt"];
      id<ORFloatVarArray> u2_opt = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS) names:@"u2_opt"];
      id<ORFloatVarArray> u3_opt = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS) names:@"u3_opt"];
      id<ORFloatVarArray> u4_opt = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS) names:@"u4_opt"];
      
      id<ORFloatVarArray> w1_opt = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS) names:@"w1_opt"];
      id<ORFloatVarArray> w2_opt = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS) names:@"w2_opt"];
      id<ORFloatVarArray> w3_opt = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS) names:@"w3_opt"];
      id<ORFloatVarArray> w4_opt = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS) names:@"w4_opt"];
      
      
      id<ORFloatVarArray> mf_opt = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS) names:@"mf_opt"];
      
      id<ORFloatVarArray> u2_1_opt = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS) names:@"u2_1_opt"];
      id<ORFloatVarArray> u2_2_opt = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS) names:@"u2_2_opt"];
      id<ORFloatVarArray> u2_3_opt = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS) names:@"u2_3_opt"];
      id<ORFloatVarArray> u2_4_opt = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS) names:@"u2_4_opt"];
      
      id<ORFloatVarArray> w2_1_opt = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS) names:@"w2_1_opt"];
      id<ORFloatVarArray> w2_2_opt = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS) names:@"w2_2_opt"];
      id<ORFloatVarArray> w2_3_opt = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS) names:@"w2_3_opt"];
      id<ORFloatVarArray> w2_4_opt = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS) names:@"w2_4_opt"];
      
      
      id<ORFloatVarArray> m2_f_opt = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS) names:@"m2_f_opt"];
      
      id<ORFloatVarArray> TMP_2 = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS) names:@"TMP_2"];
      id<ORFloatVarArray> TMP_4 = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS) names:@"TMP_4"];
      id<ORFloatVarArray> TMP_10 = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS) names:@"TMP_10"];
      id<ORFloatVarArray> TMP_14 = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS) names:@"TMP_14"];
      //      --------
      
      id<ORFloatVar> diff = [ORFactory floatVar:model name:@"diff"];
      
      
      [toadd addObject:[u1[0] set:@(0.0f)]];
      [toadd addObject:[u2[0] set:@(0.0f)]];
      [toadd addObject:[u3[0] set:@(0.0f)]];
      [toadd addObject:[u4[0] set:@(0.0f)]];
      [toadd addObject:[w1[0] set:@(0.0f)]];
      [toadd addObject:[w2[0] set:@(0.0f)]];
      [toadd addObject:[w3[0] set:@(0.0f)]];
      [toadd addObject:[w4[0] set:@(0.0f)]];
      [toadd addObject:[mf[0] set:@(0.0f)]];
      
      [toadd addObject:[u1_opt[0] set:@(0.0f)]];
      [toadd addObject:[u2_opt[0] set:@(0.0f)]];
      [toadd addObject:[u3_opt[0] set:@(0.0f)]];
      [toadd addObject:[u4_opt[0] set:@(0.0f)]];
      [toadd addObject:[w1_opt[0] set:@(0.0f)]];
      [toadd addObject:[w2_opt[0] set:@(0.0f)]];
      [toadd addObject:[w3_opt[0] set:@(0.0f)]];
      [toadd addObject:[w4_opt[0] set:@(0.0f)]];
      [toadd addObject:[mf_opt[0] set:@(0.0f)]];
      
      for (ORUInt n = 1; n <= NBLOOPS; n++) {
         
      }
      
      [toadd addObject:[diff set: [mf_opt[NBLOOPS] sub: mf[NBLOOPS]]]];
      
      [toadd addObject:[[diff mul: diff] geq:@(5.96e-8f)]];
      
      id<CPProgram> cp = [args makeProgramWithSimplification:model constraints:toadd];
      [ORCmdLineArgs defaultRunner:args model:model program:cp restricted:@[u]];
      
   }
   return 0;
}

