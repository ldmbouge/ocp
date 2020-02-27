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
 // Original (corrected from damouche-martel-chapoutot-fmics15)
 u = [ 1.11 , 2.22 ] ; a = 0.25 ; b = 5000.0 ; n = 25.0 ; r = 0.0 ; xa = 0.25 ; h = ( ( b − a ) / n ) ;
 while( xa < 5000 . 0 ) do {
 xb = ( xa + h ) ;
 if ( xb > 5000.0 ) { xb = 5000.0 ; }
 gxa = ( u / ( ( ( ( ( ( 0.7 * xa ) * xa ) * xa ) − ( ( 0.6 * xa ) * xa ) ) + ( 0.9 * xa ) ) − 0.2 ) ) ;
 gxb = ( u / ( ( ( ( ( ( 0.7 * xb ) * xb ) * xb ) − ( ( 0.6 * xb ) * xb ) ) + ( 0.9 * xb ) ) − 0.2 ) ) ;
 r = ( r + ( ( ( gxb + gxa ) * 0.5 ) * h ) ) ;
 xa = ( xa + h ) ;
 }
 
 // Optimized
 u = [ 1.11, 2.22 ] ; xa = 0.25 ; r = 0.0 ;
 while ( xa < 5000.0 ) do {
 TMP_1 = ( 0.7 * ( xa + 199.99 ) ) ;
 TMP_2 = ( xa + 199.99 ) ;
 TMP_9 = ( ( ( ( 0.7 * xa ) * xa ) * xa ) − ( ( 0.6 * xa ) * xa ) ) + ( 0.9 * xa ) ;
 TMP_11= ( ( (199.99 + xa ) * (TMP_2 * TMP_1 ) ) − ( ( 199.99 + xa ) * (TMP_2 * 0.6 ) ) ) + ( 0.9 * TMP_2 ) ;
 r = ( r + ( ( ( ( u / ( TMP_11 − 0.2 ) ) + ( u / (TMP_9 − 0.2 ) ) ) * 0.5 ) * 199.99 ) ) ;
 xa = ( xa + 199.99 ) ;
 }
 
 */

#define NBLOOPS 25

void check(float u) {
   float xa = 0.25f;
   float r = 0.0f;
   float TMP_1 = 0.0, TMP_2 = 0.0, TMP_9 = 0.0, TMP_11 = 0.0, tmp = 0.0;
   for (ORUInt n = 1; n <= NBLOOPS; n++) {
      TMP_1 = ( 0.7f * ( xa + 199.99f ) ) ;
      TMP_2 = ( xa + 199.99f ) ;
      TMP_9 = ( ( ( ( 0.7f * xa ) * xa ) * xa ) - ( ( 0.6f * xa ) * xa ) ) + ( 0.9f * xa ) ;
      TMP_11= ( ( (199.99f + xa ) * (TMP_2 * TMP_1 ) ) - ( ( 199.99f + xa ) * (TMP_2 * 0.6f ) ) ) + ( 0.9f * TMP_2 ) ;
      tmp = ( ( u / ( TMP_11 - 0.2f ) ) + ( u / (TMP_9 - 0.2f ) ) );
      r = ( r + ( ( ( ( u / ( TMP_11 - 0.2f ) ) + ( u / (TMP_9 - 0.2f ) ) ) * 0.5f ) * 199.99f ) ) ;
      xa = ( xa + 199.99f ) ;
   }
   printf("N = %d, u = % 16.16E -> r = % 16.16e (TMP_1 = % 16.16e, TMP_2 = % 16.16e, TMP_9 = % 16.16e, TMP_11 = % 16.16e, tmp = % 16.16e)\n",
          NBLOOPS, u, r, TMP_1, TMP_2, TMP_9, TMP_11, tmp);
}

int main(int argc, const char * argv[]) {
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
      id<ORExpr> a    = [ORFactory float:model value:0.25f];
      id<ORExpr> b    = [ORFactory float:model value:5000.0f];
      id<ORExpr> n    = [ORFactory float:model value:25.0f];
      id<ORExpr> r_0  = [ORFactory float:model value:0.0f];
      id<ORExpr> xa_0 = [ORFactory float:model value:0.25f];
      
      // Local vars
      id<ORFloatVar> h = [ORFactory floatVar:model name:@"h"];
      
      id<ORFloatVarArray> xa   = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS) names:@"xa"];
      id<ORFloatVarArray> r    = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS) names:@"r"];
      id<ORFloatVarArray> xb0  = [ORFactory floatVarArray:model range:RANGE(model, 1, NBLOOPS) names:@"xb0"];
      id<ORFloatVarArray> xb   = [ORFactory floatVarArray:model range:RANGE(model, 1, NBLOOPS) names:@"xb"];
      id<ORFloatVarArray> gxa  = [ORFactory floatVarArray:model range:RANGE(model, 1, NBLOOPS) names:@"gxa"];
      id<ORFloatVarArray> gxb  = [ORFactory floatVarArray:model range:RANGE(model, 1, NBLOOPS) names:@"gxb"];
      
      id<ORFloatVarArray> xa_opt = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS) names:@"xa_opt"];
      id<ORFloatVarArray> r_opt  = [ORFactory floatVarArray:model range:RANGE(model, 0, NBLOOPS) names:@"r_opt"];
      id<ORFloatVarArray> TMP_1  = [ORFactory floatVarArray:model range:RANGE(model, 1, NBLOOPS) names:@"TMP_1"];
      id<ORFloatVarArray> TMP_2  = [ORFactory floatVarArray:model range:RANGE(model, 1, NBLOOPS) names:@"TMP_2"];
      id<ORFloatVarArray> TMP_9  = [ORFactory floatVarArray:model range:RANGE(model, 1, NBLOOPS) names:@"TMP_9"];
      id<ORFloatVarArray> TMP_11 = [ORFactory floatVarArray:model range:RANGE(model, 1, NBLOOPS) names:@"TMP_11"];
      
      id<ORFloatVar> diff = [ORFactory floatVar:model name:@"diff"];
      
      
      //       h = ( ( b − a ) / n ) ;
      [toadd addObject:[h set:[[b sub:a] div:n]]];
      
      [toadd addObject:[xa[0] set:xa_0]];
      [toadd addObject:[r[0] set:r_0]];
      
      [toadd addObject:[xa_opt[0] set:xa_0]];
      [toadd addObject:[r_opt[0] set:r_0]];
      
      for (ORUInt n = 1; n <= NBLOOPS; n++) {
         [toadd addObject:[xa[n-1] lt:b]];
         
         [toadd addObject:[xb0[n] set:[xa[n-1] plus: h]]];
         
         // if ( xb > 5000.0 ) { xb = 5000.0 ; }
         { // Guarded
            id<ORExpr> ifCond = [xb0[n] gt: b];
            id<ORIntVar> thenGuard = [ORFactory boolVar:model];
            id<ORIntVar> elseGuard = [ORFactory boolVar:model];
            [toadd addObject: [ifCond eq: thenGuard]];
            [toadd addObject: [[ifCond neg] eq: elseGuard]];
            
            id<ORGroup> thenGroup = [ORFactory group:model guard:thenGuard];
            [thenGroup add: [xb[n] set: b]];
            [toadd addObject:thenGroup];
            
            id<ORGroup> elseGroup = [ORFactory group:model guard:elseGuard];
            [elseGroup add: [xb[n] set: xb0[n]]];
            [toadd addObject:elseGroup];
         }
         
         [toadd addObject: [gxa[n] set: [u div: [[[[[[@(0.7f) mul: xa[n-1]] mul: xa[n-1]] mul: xa[n-1]] sub: [[@(0.6f) mul: xa[n-1]] mul: xa[n-1]]] plus: [@(0.9f) mul:xa[n-1]]] sub: @(0.2f)]]]] ;
         [toadd addObject: [gxb[n] set: [u div: [[[[[[@(0.7f) mul: xb[n]] mul: xb[n]] mul: xb[n]] sub: [[@(0.6f) mul: xb[n]] mul: xb[n]]] plus: [@(0.9f) mul: xb[n]]] sub: @(0.2f)]]]];
         [toadd addObject: [r[n] set: [r[n-1] plus: [[[gxb[n] plus: gxa[n]] mul: @(0.5f)] mul: h]]]];
         [toadd addObject: [xa[n] set: [xa[n-1] plus: h]]];
         
         [toadd addObject: [xa_opt[n-1] lt:b]];
         [toadd addObject: [TMP_1[n] set: [@(0.7f) mul: [xa_opt[n-1] plus: @(199.99f)]]]];
         [toadd addObject: [TMP_2[n] set: [xa_opt[n-1] plus: @(199.99f)]]];
         [toadd addObject: [TMP_9[n] set: [[[[[@(0.7f) mul: xa_opt[n-1]] mul: xa_opt[n-1]] mul: xa_opt[n-1]] sub: [[@(0.6f) mul: xa_opt[n-1]] mul: xa_opt[n-1]]] plus: [@(0.9f) mul: xa_opt[n-1]]]]];
         [toadd addObject: [TMP_11[n] set: [[[[@(199.99f) plus: xa_opt[n-1]] mul: [TMP_2[n] mul: TMP_1[n]]] sub: [[@(199.99f) plus: xa_opt[n-1]] mul: [TMP_2[n] mul: @(0.6f)]]] plus: [@(0.9f) mul: TMP_2[n]]]]];
         [toadd addObject: [r_opt[n] set: [r_opt[n-1] plus: [[[[u div: [TMP_11[n] sub: @(0.2f)]] plus: [u div: [TMP_9[n] sub: @(0.2f)]]] mul: @(0.5f)] mul: @(199.99f)]]]];
         [toadd addObject: [xa_opt[n] set: [xa_opt[n-1] plus: @(199.99f)]]];
      }
      
      [toadd addObject:[diff set: [r_opt[NBLOOPS] sub: r[NBLOOPS]]]];
      [toadd addObject:[[diff mul: diff] geq:@(2.44e-4f)]];
      
      id<CPProgram> cp = [args makeProgramWithSimplification:model constraints:toadd];
      [ORCmdLineArgs defaultRunner:args model:model program:cp restricted:@[u]];
      
   }
   return 0;
}
