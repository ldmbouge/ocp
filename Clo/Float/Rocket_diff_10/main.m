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
   @autoreleasepool {
      ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
      
      id<ORModel> model = [ORFactory createModel];
      
      NSMutableArray* toadd = [[NSMutableArray alloc] init];
      
      // Input variable
      id<ORFloatVar> Mf = [ORFactory floatVar:model low:1000.0f up:1e6f name:@"Mf"]; // Example: 150000.f
      id<ORFloatVar> A  = [ORFactory floatVar:model low:5.0f up:200.0f name:@"A"];  // Example: 140.0f
      
      // Constants
      id<ORExpr> dt   = [ORFactory float:model value:0.1f];
      //id<ORExpr> R = [ORFactory float:model value:6.4e6f];
      id<ORExpr> G  = [ORFactory float:model value:6.67428e-11f];
      id<ORExpr> Mt  = [ORFactory float:model value:5.9736e24f];
      //id<ORExpr> D  = [ORFactory float:model value:([R floatValue] + 4.0e5f)];
      //id<ORExpr> v_l  = [ORFactory float:model value:(0.7f * sqrtf(([G floatValue] * [Mt floatValue]) / [D floatValue]))];
      
      
      
      // Local vars
      //      --------
      // original var
      id<ORFloatVarArray> c = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS) names:@"c"];
      id<ORFloatVarArray> s = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS) names:@"s"];
      id<ORFloatVarArray> x = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS) names:@"x"];
      id<ORFloatVarArray> y = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS) names:@"y"];
      id<ORFloatVarArray> t = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS) names:@"t"];
      
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
      id<ORFloatVarArray> c_opt = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS) names:@"c_opt"];
      id<ORFloatVarArray> s_opt = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS) names:@"s_opt"];
      id<ORFloatVarArray> x_opt = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS) names:@"x_opt"];
      id<ORFloatVarArray> y_opt = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS) names:@"y_opt"];
      id<ORFloatVarArray> t_opt = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS) names:@"t_opt"];
      
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
      [toadd addObject:[t[0] set:@(0.0f)]];
      
      [toadd addObject:[u1_opt[0] set:@(0.0f)]];
      [toadd addObject:[u2_opt[0] set:@(0.0f)]];
      [toadd addObject:[u3_opt[0] set:@(0.0f)]];
      [toadd addObject:[u4_opt[0] set:@(0.0f)]];
      [toadd addObject:[w1_opt[0] set:@(0.0f)]];
      [toadd addObject:[w2_opt[0] set:@(0.0f)]];
      [toadd addObject:[w3_opt[0] set:@(0.0f)]];
      [toadd addObject:[w4_opt[0] set:@(0.0f)]];
      [toadd addObject:[mf_opt[0] set:@(0.0f)]];
      [toadd addObject:[t_opt[0] set:@(0.0f)]];
      
      for (ORUInt n = 1; n <= NBLOOPS; n++) {
         { // Guarded
            id<ORExpr> ifCond = [mf[n-1] gt: @(0.0f)];
            id<ORIntVar> thenGuard = [ORFactory boolVar:model];
            id<ORIntVar> elseGuard = [ORFactory boolVar:model];
            [toadd addObject: [ifCond eq: thenGuard]];
            [toadd addObject: [[ifCond neg] eq: elseGuard]];
            
            id<ORGroup> thenGroup = [ORFactory group:model guard:thenGuard];
            [thenGroup add: [u2_1[n] set: [[u2[n-1] mul: dt] plus: u1[n-1]]]];
            [thenGroup add: [u2_3[n] set: [[u4[n-1] mul: dt] plus: u3[n-1]]]];
            [thenGroup add: [w2_1[n] set: [[w2[n-1] mul: dt] plus: w1[n-1]]]];
            [thenGroup add: [w2_3[n] set: [[w4[n-1] mul: dt] plus: w3[n-1]]]];
            [thenGroup add: [u2_2[n] set: [[[[[[G minus] mul: Mt] div: [u1[n-1] mul: u1[n-1]]] mul: dt] plus: [[[u1[n-1] mul: u4[n-1]] mul: u4[n-1]] mul: dt]] plus: u2[n-1]]]];
            [thenGroup add: [u2_4[n] set: [[[[[@(-2.0f) mul: u2[n-1]] mul: u4[n-1]] div: u1[n-1]] mul: dt] plus: u4[n-1]]]];
            [thenGroup add: [w2_2[n] set: [[[[[[[G minus] mul: Mt] div: [w1[n-1] mul: w1[n-1]]] mul: dt] plus: [[[w1[n-1] mul: w4[n-1]] mul: w4[n-1]] mul: dt]] plus: [[[A mul: w2[n-1]] div: [Mf sub: [A mul: t[n-1]]]] mul: dt]] plus: w2[n-1]]]];
            [thenGroup add: [w2_4[n] set: [[[[[[@(-2.0f) mul: w2[n-1]] mul: w4[n-1]] div: w1[n-1]] mul: dt] plus: [[[A mul: w4[n-1]] div: [Mf sub: [A mul: t[n-1]]]] mul: dt]] plus: w4[n-1]]]];
            [thenGroup add: [m2_f[n] set: [mf[n-1] sub: [A mul: t[n-1]]]]];
            [thenGroup add: [t[n] set: [t[n-1] plus: dt]]];
            [toadd addObject:thenGroup];
            
            id<ORGroup> elseGroup = [ORFactory group:model guard:elseGuard];
            [elseGroup add: [u2_1[n] set: [[u2[n-1] mul: dt] plus: u1[n-1]]]];
            [elseGroup add: [u2_3[n] set: [[u4[n-1] mul: dt] plus: u3[n-1]]]];
            [elseGroup add: [w2_1[n] set: [[w2[n-1] mul: dt] plus: w1[n-1]]]];
            [elseGroup add: [w2_3[n] set: [[w4[n-1] mul: dt] plus: w3[n-1]]]];
            [elseGroup add: [u2_2[n] set: [[[[[[G minus] mul: Mt] div: [u1[n-1] mul: u1[n-1]]] mul: dt] plus: [[[u1[n-1] mul: u4[n-1]] mul: u4[n-1]] mul: dt]] plus: u2[n-1]]]];
            [elseGroup add: [u2_4[n] set: [[[[[@(-2.0f) mul: u2[n-1]] mul: u4[n-1]] div: u1[n-1]] mul: dt] plus: u4[n-1]]]];
            [elseGroup add: [w2_2[n] set: [[[[[[G minus] mul: Mt] div: [w1[n-1] mul: w1[n-1]]] mul: dt] plus: [[[w1[n-1] mul: w4[n-1]] mul: w4[n-1]] mul: dt]] plus: w2[n-1]]]];
            [elseGroup add: [w2_4[n] set: [[[[[@(-2.0f) mul: w2[n-1]] mul: w4[n-1]] div: w1[n-1]] mul: dt] plus: w4[n-1]]]];
            [elseGroup add: [m2_f[n] set: mf[n-1]]];
            [elseGroup add: [t[n] set: [t[n-1] plus: dt]]];
            [toadd addObject:elseGroup];
         }
         
         [toadd addObject:[c[n] set: [@(1.0f) sub: [[w2_3[n] mul: u2_3[n]] mul: @(0.5f)]]]] ;
         [toadd addObject:[s[n] set: [u2_3[n] sub: [[[u2_3[n] mul: u2_3[n]] mul: u2_3[n]] div: @(0.166666667f)]]]];
         [toadd addObject:[x[n] set: [w2_1[n] mul: c[n]]]];
         [toadd addObject:[y[n] set: [w2_1[n] mul: s[n]]]];
         [toadd addObject:[u1[n] set: u2_1[n]]];
         [toadd addObject:[u2[n] set: u2_2[n]]];
         [toadd addObject:[u3[n] set: u2_3[n]]];
         [toadd addObject:[u4[n] set: u2_4[n]]];
         [toadd addObject:[w1[n] set: w2_1[n]]];
         [toadd addObject:[w2[n] set: w2_2[n]]];
         [toadd addObject:[w3[n] set: w2_3[n]]];
         [toadd addObject:[w4[n] set: w2_4[n]]];
         [toadd addObject:[mf[n] set: m2_f[n]]];
         
         { // Guarded
            id<ORExpr> ifCond = [mf_opt[n-1] gt: @(0.0f)];
            id<ORIntVar> thenGuard = [ORFactory boolVar:model];
            id<ORIntVar> elseGuard = [ORFactory boolVar:model];
            [toadd addObject: [ifCond eq: thenGuard]];
            [toadd addObject: [[ifCond neg] eq: elseGuard]];
            
            id<ORGroup> thenGroup = [ORFactory group:model guard:thenGuard];
            [thenGroup add: [TMP_2[n] set: [u1_opt[n-1] mul: u1_opt[n-1]]]];
            [thenGroup add: [TMP_4[n] set: [@(59735.99e20f) div: [w1_opt[n-1] mul: w1_opt[n-1]]]]];
            [thenGroup add: [TMP_10[n] set: [@(140.0f) mul: t_opt[n-1]]]];
            [thenGroup add: [m2_f_opt[n] set: [mf_opt[n-1] plus: [t_opt[n-1] mul: @(-140.0f)]]]];
            [thenGroup add: [u2_1_opt[n] set: [u1_opt[n-1] plus: [u2_opt[n-1] mul: @(0.1f)]]]];
            [thenGroup add: [u2_3_opt[n] set: [u3_opt[n-1] plus: [u4_opt[n-1] mul: @(0.1f)]]]];
            [thenGroup add: [w2_1_opt[n] set: [w1_opt[n-1] plus: [w2_opt[n-1] mul: @(0.1f)]]]];
            [thenGroup add: [w2_3_opt[n] set: [w3_opt[n-1] plus: [w4_opt[n-1] mul: @(0.1f)]]]];
            [thenGroup add: [u2_2_opt[n] set: [[[[[@(0.66743e-10f) mul: [@(59735.99e20f) div: TMP_2[n]]] mul: @(0.1f)] minus] plus: [[[u1_opt[n-1] mul: u4_opt[n-1]] mul: u4_opt[n-1]] mul: @(0.1f)]] plus: u2_opt[n-1]]]];
            [thenGroup add: [u2_4_opt[n] set: [[[@(-2.0f) mul: [u2_opt[n-1] mul: [u4_opt[n-1] div: u1_opt[n-1]]]] mul: @(0.1f)] plus: u4_opt[n-1]]]];
            [thenGroup add: [w2_2_opt[n] set: [[[[[[@(0.66743e-10f) mul: TMP_4[n]] mul: @(0.1f)] minus] plus: [[[w1_opt[n-1] mul: w4_opt[n-1]] mul: w4_opt[n-1]] mul: @(0.1f)]] plus: [[[@(140.0f) mul: w2_opt[n-1]] div: [@(150000.0f) sub: [@(140.0f) mul: t_opt[n-1]]]] mul: @(0.1f)]] plus: w2_opt[n-1]]]];
            [thenGroup add: [w2_4_opt[n] set: [[[[@(-2.0f) mul: [w2_opt[n-1] mul: [w4_opt[n-1] div: w1_opt[n-1]]]] mul: @(0.1f)] plus: [[@(140.0f) mul: [w4_opt[n-1] div: [@(150000.0f) sub: TMP_10[n]]]] mul: @(0.1f)]] plus: w4_opt[n-1]]]];
            [thenGroup add: [t_opt[n] set: [t_opt[n-1] plus: @(0.1f)]]];
            [toadd addObject:thenGroup];
            
            id<ORGroup> elseGroup = [ORFactory group:model guard:elseGuard];
            [elseGroup add: [TMP_2[n] set: [u1_opt[n-1] mul: u1_opt[n-1]]]];
            [elseGroup add: [TMP_14[n] set: [w1_opt[n-1] mul: w1_opt[n-1]]]];
            [elseGroup add: [u2_1_opt[n] set: [u1_opt[n-1] plus: [u2_opt[n-1] mul: @(0.1f)]]]];
            [elseGroup add: [u2_3_opt[n] set: [u3_opt[n-1] plus: [u4_opt[n-1] mul: @(0.1f)]]]];
            [elseGroup add: [w2_1_opt[n] set: [w1_opt[n-1] plus: [w2_opt[n-1] mul: @(0.1f)]]]];
            [elseGroup add: [w2_3_opt[n] set: [w3_opt[n-1] plus: [w4_opt[n-1] mul: @(0.1f)]]]];
            [elseGroup add: [u2_2_opt[n] set: [[[[[@(0.66743e-10f) mul: [@(59735.99e20f) div: TMP_2[n]]] mul: @(0.1f)] minus] plus: [[[u1_opt[n-1] mul: u4_opt[n-1]] mul: u4_opt[n-1]] mul: @(0.1f)]] plus: u2_opt[n-1]]]] ;
            [elseGroup add: [u2_4_opt[n] set: [[[@(-2.0f) mul: [u2_opt[n-1] mul: [u4_opt[n-1] div: u1_opt[n-1]]]] mul: @(0.1f)] plus: u4_opt[n-1]]]];
            [elseGroup add: [w2_2_opt[n] set: [[[[[@(0.66743e-10f) mul: [@(59735.99e20f) div: TMP_14[n]]] mul: @(0.1f)] minus] plus: [[[w1_opt[n-1] mul: w4_opt[n-1]] mul: w4_opt[n-1]] mul: @(0.1f)]] plus: w2_opt[n-1]]]];
            [elseGroup add: [w2_4_opt[n] set: [[[@(-2.0f) mul: [w2_opt[n-1] mul: [w4_opt[n-1] div: w1_opt[n-1]]]] mul: @(0.1f)] plus: w4_opt[n-1]]]] ;
            [elseGroup add: [t_opt[n] set: [t_opt[n-1] plus: @(0.1f)]]];
            [toadd addObject:elseGroup];
         }
         
         [toadd addObject:[c_opt[n] set: [@(1.0f) sub: [[u2_3_opt[n] plus: [u2_4_opt[n] mul: @(0.1f)]] mul: [@(0.5f) mul: [u2_3_opt[n] plus: [u2_4_opt[n] mul: @(0.1f)]]]]]]];
         [toadd addObject:[s_opt[n] set: [[u2_3_opt[n] plus: [u2_4_opt[n] mul: @(0.1f)]] sub: [[[u2_3_opt[n] plus: [u2_4_opt[n] mul: @(0.1f)]] mul: [[u2_3_opt[n] plus: [u2_4_opt[n] mul: @(0.1f)]] mul: [u2_3_opt[n] plus: [u2_4_opt[n] mul: @(0.1f)]]]] div: @(0.166666667f)]]]];
         [toadd addObject:[x_opt[n] set: [c_opt[n] mul: [u2_1_opt[n] plus: [u2_2_opt[n] mul: @(0.1f)]]]]] ;
         [toadd addObject:[y_opt[n] set: [s_opt[n] mul: [u2_1_opt[n] plus: [u2_2_opt[n] mul: @(0.1f)]]]]] ;
         [toadd addObject:[u1_opt[n] set: u2_1_opt[n]]];
         [toadd addObject:[u2_opt[n] set: u2_2_opt[n]]];
         [toadd addObject:[u3_opt[n] set: u2_3_opt[n]]];
         [toadd addObject:[u4_opt[n] set: u2_4_opt[n]]];
         [toadd addObject:[w1_opt[n] set: w2_1_opt[n]]];
         [toadd addObject:[w2_opt[n] set: w2_2_opt[n]]];
         [toadd addObject:[w3_opt[n] set: w2_3_opt[n]]];
         [toadd addObject:[w4_opt[n] set: w2_4_opt[n]]];
         [toadd addObject:[mf_opt[n] set: m2_f_opt[n]]] ;
         
      }
      
      [toadd addObject:[diff set: [x_opt[NBLOOPS] sub: x[NBLOOPS]]]];
      
      //[toadd addObject:[[diff mul: diff] geq:@(5.96e-8f)]];
      
      id<CPProgram> cp = [args makeProgramWithSimplification:model constraints:toadd];
      [ORCmdLineArgs defaultRunner:args model:model program:cp restricted:@[Mf,A]];
      
   }
   return 0;
}

