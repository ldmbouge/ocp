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
 // LeadLag (These Nasrine Damouche P96, L6.2 & L6.3
 // Original
 u = [ 1.11 , 2.22 ] ; a = 0.25 ; b = 5000.0 ; n = 25.0 ; r = 0.0 ; xa = 0.25 ; h = ( ( b − a ) / n ) ;
 while( xa < 5000 . 0 ) do {
   xb = ( xa + h ) ;
   if ( xb > 5000.0 ) {
      xb = 5000.0 ;
      gxa = ( u / ( ( ( ( ( ( 0.7 * xa ) * xa ) * xa ) − ( ( 0.6 * xa ) * xa ) ) + ( 0.9 * xa ) ) − 0.2 ) ) ;
      gxb = ( u / ( ( ( ( ( ( 0.7 * xb ) * xb ) * xb ) − ( ( 0.6 * xb ) * xb ) ) + ( 0.9 * xb ) ) − 0.2 ) ) ;
      r = ( r + ( ( ( gxb + gxa ) * 0 . 5 ) * h ) ) ;
      xa = ( xa + h ) ;
      gxa = gxb ;
   }
 }
 
 // Optimized
 u = [ 1.11, 2.22 ] ; xa = 0.25 ; r = 0.0 ;
 while ( xa < 5000.0 ) do {
   TMP_1 = ( 0.7 * ( xa + 199.99 ) ) ;
   TMP_2 = ( xa + 199.99 ) ;
   TMP_9 = ( ( ( ( 0.7 * xa ) * xa ) * xa ) − ( ( 0.6 * xa ) * xa ) ) + ( 0.9 * xa ) ;
   TMP_11= ( ( (199.99 + xa ) * (TMP_2 * TMP_1 ) ) − ( ( 199.99 + xa ) * (TMP_2 * 0.6 ) ) ) + ( 0.9 * TMP_2 ) ;
   r = ( r + ( ( ( ( u / ( TMP_11 − 0.2 ) ) + ( u / (TMP_9 − 0.2 ) ) ) * 0.5 ) * 199.99 ) ) ; xa = ( xa + 199.99 ) ;
 }
 l
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
      
      // Input var
      id<ORFloatVar> u = [ORFactory floatVar:model low:1.11f up:2.22f name:@"u"];
      
      // Constants
//     a  = 0.25 ;
//      b = 5000.0 ;
//      n = 25.0 ;
//      r = 0.0 ;
//      xa = 0.25 ;
      id<ORExpr> a   = [ORFactory float:model value:0.25f];
      id<ORExpr> b = [ORFactory float:model value:5000.0f];
      id<ORExpr> n  = [ORFactory float:model value:25.0f];
      id<ORExpr> r_0  = [ORFactory float:model value:0.0f];
      id<ORExpr> xa_0  = [ORFactory float:model value:0.25f];
      id<ORExpr> c1  = [ORFactory float:model value:0.7f];
      id<ORExpr> c2  = [ORFactory float:model value:0.6f];
      id<ORExpr> c3  = [ORFactory float:model value:0.9f];
      id<ORExpr> c4  = [ORFactory float:model value:0.2f];
      id<ORExpr> c6  = [ORFactory float:model value:199.99f];
      
      id<ORFloatVar> h = [ORFactory floatVar:model name:@"h"];
      
      // Local vars
      id<ORFloatVarArray> xa = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS) names:@"xa"];
      id<ORFloatVarArray> r = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS) names:@"r"];
      id<ORFloatVarArray> xb = [ORFactory floatVarArray:model range:RANGE(model, 1, NBLOOPS) names:@"xb"];
      id<ORFloatVarArray> gxa = [ORFactory floatVarArray:model range:RANGE(model, 1, NBLOOPS) names:@"gxa"];
      id<ORFloatVarArray> gxa2 = [ORFactory floatVarArray:model range:RANGE(model, 1, NBLOOPS) names:@"gxa2"];
      id<ORFloatVarArray> gxb = [ORFactory floatVarArray:model range:RANGE(model, 1, NBLOOPS) names:@"gxb"];
      
      id<ORFloatVarArray> xa_opt = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS) names:@"xa_opt"];
      id<ORFloatVarArray> r_opt = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS) names:@"r_opt"];
      id<ORFloatVarArray> TMP_1 = [ORFactory floatVarArray:model range:RANGE(model, 1, NBLOOPS) names:@"TMP_1"];
      id<ORFloatVarArray> TMP_2 = [ORFactory floatVarArray:model range:RANGE(model, 1, NBLOOPS) names:@"TMP_2"];
      id<ORFloatVarArray> TMP_9 = [ORFactory floatVarArray:model range:RANGE(model, 1, NBLOOPS) names:@"TMP_9"];
      id<ORFloatVarArray> TMP_11 = [ORFactory floatVarArray:model range:RANGE(model, 1, NBLOOPS) names:@"TMP_11"];
      
      id<ORFloatVar> diff = [ORFactory floatVar:model name:@"diff"];
      
      
      //       h = ( ( b − a ) / n ) ;
      [toadd addObject:[h set:[[b sub:a] div:n]]];
      
      [toadd addObject:[xa[0] set:xa_0]];
      [toadd addObject:[r[0] set:r_0]];
      
      
      [toadd addObject:[xa_opt[0] set:xa_0]];
      [toadd addObject:[r_opt[0] set:r_0]];
      
      for (ORUInt n = 1; n <= NBLOOPS; n++) {
         [toadd addObject:[xa[n] lt:b]];
         [toadd addObject:[xa_opt[n] lt:b]];
         
         [toadd addObject:[xb[n] set:[xa[n-1] plus:h]]];
         
         if(first_if == 1){
//            logic todo
         }else{
            { // Guarded
               id<ORExpr> ifCond_1  = [xb[n] lt: b];
               id<ORIntVar> thenGuard_1 = [ORFactory boolVar:model];
               [toadd addObject: [ifCond_1 eq: thenGuard_1]];
               
               id<ORGroup> thenGroup_1 = [ORFactory group:model guard:thenGuard_1];
//               xb = 5000.0 ;
//               gxa = ( u / ( ( ( ( ( ( 0.7 * xa ) * xa ) * xa ) − ( ( 0.6 * xa ) * xa ) ) + ( 0.9 * xa ) ) − 0.2 ) ) ;
//               gxb = ( u / ( ( ( ( ( ( 0.7 * xb ) * xb ) * xb ) − ( ( 0.6 * xb ) * xb ) ) + ( 0.9 * xb ) ) − 0.2 ) ) ;
//               r = ( r + ( ( ( gxb + gxa ) * 0 . 5 ) * h ) ) ;
//               xa = ( xa + h ) ;
//               gxa = gxb ;
               [thenGroup_1 add: [xb[n] set: b]];
               [thenGroup_1 add: [gxa[n] set: [u div: [[[[[[c1 mul: xa[n-1]] mul: xa[n-1]] mul: xa[n-1]] sub: [[c2 mul: xa[n-1]] mul: xa[n-1]]] plus: [c3 mul:xa[n-1]]] sub: c4 ]]]] ;
               [thenGroup_1 add: [gxb[n] set: [u div: [[[[[[c1 mul: xb[n]] mul: xb[n]] mul: xb[n]] sub: [[c2 mul: xb[n]] mul: xb[n]]] plus: [c3 mul: xb[n]]] sub: c4 ]]]];
               [thenGroup_1 add: [r[n] set: [ r[n-1] plus: [[[ gxb[n] plus: gxa[n]] mul: @(0.5f) ] mul: h]]]] ;
               [thenGroup_1 add: [xa[n] set: [xa[n-1] plus:h]]];
               [thenGroup_1 add: [gxa2[n] set:gxb[n]]];
               [toadd addObject:thenGroup_1];
            }
         }
         
//         TMP_1 = ( 0.7 * ( xa + 199.99 ) ) ;
//         TMP_2 = ( xa + 199.99 ) ;
//         TMP_9 = ( ( ( ( 0.7 * xa ) * xa ) * xa ) − ( ( 0.6 * xa ) * xa ) ) + ( 0.9 * xa ) ;
//         TMP_11= ( ( (199.99 + xa ) * (TMP_2 * TMP_1 ) ) − ( ( 199.99 + xa ) * (TMP_2 * 0.6 ) ) ) + ( 0.9 * TMP_2 ) ;
//         r = ( r + ( ( ( ( u / ( TMP_11 − 0.2 ) ) + ( u / (TMP_9 − 0.2 ) ) ) * 0.5 ) * 199.99 ) ) ; xa = ( xa + 199.99 ) ;
         [toadd addObject: [ TMP_1[n] set: [ c1 mul: [ xa_opt[n] plus: c6 ] ] ]];
         
         [toadd addObject: [ TMP_2[n] set: [ xa_opt[n] plus: c6 ] ]];
         
         [toadd addObject: [ TMP_9[n] set: [[[[[ c1 mul: xa_opt[n]] mul: xa_opt[n] ] mul: xa_opt[n] ] sub: [[ c2 mul: xa_opt[n] ] mul: xa_opt[n] ]] plus: [ c3 mul: xa_opt[n] ]]]];
         
         [toadd addObject: [ TMP_11[n] set: [[[[c6 plus: xa_opt[n] ] mul: [TMP_2[n] mul: TMP_1[n] ] ] sub: [ [ c6 plus: xa_opt[n] ] mul: [TMP_2[n] mul: c2 ]]] plus: [ c3 mul: TMP_2[n] ]]]];
         
         [toadd addObject: [ r[n] set: [ r[n-1] plus: [[[[ u div: [ TMP_11[n] sub: c4 ] ] plus: [ u div: [TMP_9[n] sub: c4 ] ] ] mul: @(0.5f)] mul: c6 ]]]] ;
          
         [toadd addObject: [xa_opt[n] set: [ xa_opt[n] plus: c6 ]]];
      }
         
      [toadd addObject:[diff set: [r_opt[NBLOOPS] sub: r[NBLOOPS]]]];
//      [toadd addObject:[diff set: [xa_opt[NBLOOPS] sub: xa[NBLOOPS]]]];
      [toadd addObject:[[diff mul: diff] geq:@(5.96e-8f)]];
      
      id<CPProgram> cp = [args makeProgramWithSimplification:model constraints:toadd];
      [ORCmdLineArgs defaultRunner:args model:model program:cp restricted:@[u]];
      
   }
   return 0;
}

