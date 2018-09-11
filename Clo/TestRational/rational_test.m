//
//  rational_test.m
//  Clo
//
//  Created by Remy Garcia on 24/05/2018.
//

#import <Foundation/Foundation.h>
#import <ORFoundation/ORFoundation.h>
#include "gmp.h"
#import "rationalUtilities.h"

void check_result(NSString* s, ORRational* r, ORDouble x_){
   ORRational *x = [ORRational rationalWith_d:x_];
   
   if(([r eq: x] && r.type == x.type) || (r.type == x.type && r.type == 3))
      //NSLog(@"[TRUE]        %@      %@ == %@      %i == %i", s, r, x, r.type, x.type);
      NSLog(@"");
   else if([r neq: x] && r.type == x.type)
      NSLog(@"[FALSE][R]    %@      %@ != %@      %i == %i", s, r, x, r.type, x.type);
   else if([r eq: x] && r.type != x.type)
      NSLog(@"[FALSE][T]    %@      %@ != %@      %i == %i", s, r, x, r.type, x.type);
   else
      NSLog(@"[FALSE][R][T] %@      %@ != %@      %i == %i", s, r, x, r.type, x.type);
   
   [x release];
}

void check_result_interval(NSString* s, ORRationalInterval* r, ORDouble x_i, ORDouble x_s){
   ORRationalInterval* x = [[ORRationalInterval alloc] init];
   [x set_d:x_i and:x_s];
   
   if(([r eq: x] && r.low.type == x.low.type && r.up.type == x.up.type) ||
      (r.low.type == x.low.type && r.low.type == 3 && [r.up eq: x.up] && r.up.type == x.up.type) ||
      (r.up.type == x.up.type && r.up.type == 3 && [r.low eq: x.low] && r.low.type == x.low.type) ||
      (r.low.type == x.low.type && r.low.type == 3 && r.up.type == x.up.type && r.up.type == 3))
      //NSLog(@"[TRUE]        %@ [%@,%@] == [%@,%@]      [%i,%i] == [%i,%i]", s, r.low, r.up, x.low, x.up, r.low.type, r.up.type, x.low.type, x.up.type);
      NSLog(@"");
   else if([r neq: x] &&
           r.low.type == x.low.type &&
           r.up.type == x.up.type)
      NSLog(@"[FALSE][R]    %@ [%@,%@] == [%@,%@]      [%i,%i] == [%i,%i]", s, r.low, r.up, x.low, x.up, r.low.type, r.up.type, x.low.type, x.up.type);
   else if([r eq: x] &&
           r.low.type != x.low.type &&
           r.up.type != x.up.type)
      NSLog(@"[FALSE][T]    %@ [%@,%@] == [%@,%@]      [%i,%i] == [%i,%i]", s, r.low, r.up, x.low, x.up, r.low.type, r.up.type, x.low.type, x.up.type);
   else
      NSLog(@"[FALSE][R][T] %@ [%@,%@] == [%@,%@]      [%i,%i] == [%i,%i]", s, r.low, r.up, x.low, x.up, r.low.type, r.up.type, x.low.type, x.up.type);
   
   [x release];
}

void check_addition(){
   NSLog(@"ADDITION");
   ORRational* neg_inf = [ORRational rationalWith_d: -INFINITY];
   ORRational* neg_v = [ORRational rationalWith_d: -123.4];
   ORRational* neg_v2 = [ORRational rationalWith_d: -0.21];
   ORRational* zero = [ORRational rationalWith_d: 0.0];
   ORRational* pos_v = [ORRational rationalWith_d: 43.23];
   ORRational* pos_v2 = [ORRational rationalWith_d: 185.6];
   ORRational* pos_inf = [ORRational rationalWith_d: +INFINITY];
   ORRational* nan = [ORRational rationalWith_d: NAN];
   ORRational* result = [[ORRational alloc] init];
   
   /* Addition */
   /* -INF + -INF */
   result = [neg_inf add: neg_inf];
   check_result(@"-INF + -INF", result, -INFINITY);
   /* -INF + NR */
   result = [neg_inf add: neg_v];
   check_result(@"-INF + NR", result, -INFINITY);
   /* -INF + NR2 */
   result = [neg_inf add: neg_v2];
   check_result(@"-INF + NR2", result, -INFINITY);
   /* -INF + 0 */
   result = [neg_inf add: zero];
   check_result(@"-INF + 0", result, -INFINITY);
   /* -INF + PR */
   result = [neg_inf add: pos_v];
   check_result(@"-INF + PR", result, -INFINITY);
   /* -INF + PR2 */
   result = [neg_inf add: pos_v2];
   check_result(@"-INF + PR2", result, -INFINITY);
   /* -INF + +INF */
   result = [neg_inf add: pos_inf];
   check_result(@"-INF + +INF", result, NAN);
   /* NR + NR */
   result = [neg_v add: neg_v];
   check_result(@"NR + NR", result, -246.8);
   /* NR + NR2 */
   result = [neg_v add: neg_v2];
   check_result(@"NR + NR2", result, -123.61);
   /* NR2 + NR2 */
   result = [neg_v2 add: neg_v2];
   check_result(@"NR2 + NR", result, -0.42);
   /* NR + 0 */
   result = [neg_v add: zero];
   check_result(@"NR + 0", result, -123.4);
   /* NR2 + 0 */
   result = [neg_v2 add: zero];
   check_result(@"NR2 + 0", result, -0.21);
   /* NR + PR */
   result = [neg_v add: pos_v];
   check_result(@"NR + PR", result, -80.17);
   /* NR + PR2 */
   result = [neg_v add: pos_v2];
   check_result(@"NR + PR2", result, 62.2);
   /* NR2 + PR */
   result = [neg_v2 add: pos_v];
   check_result(@"NR2 + PR", result, 43.02);
   /* NR2 + PR2 */
   result = [neg_v2 add: pos_v2];
   check_result(@"NR2 + PR2", result, 185.39);
   /* NR + +INF */
   result = [neg_v add: pos_inf];
   check_result(@"NR + +INF", result, +INFINITY);
   /* NR2 + +INF */
   result = [neg_v2 add: pos_inf];
   check_result(@"NR2 + +INF", result, +INFINITY);
   /* 0 + 0 */
   result = [zero add: zero];
   check_result(@"0 + 0", result, 0.0);
   /* 0 + PR */
   result = [zero add: pos_v];
   check_result(@"0 + PR", result, 43.23);
   /* 0 + PR2 */
   result = [zero add: pos_v2];
   check_result(@"0 + PR2", result, 185.6);
   /* 0 + +INF */
   result = [zero add: pos_inf];
   check_result(@"0 + +INF", result, +INFINITY);
   /* PR + PR */
   result = [pos_v add: pos_v];
   check_result(@"PR + PR", result, 86.46);
   /* PR + PR2 */
   result = [pos_v add: pos_v2];
   check_result(@"PR + PR2", result, 228.83);
   /* PR2 + PR2 */
   result = [pos_v2 add: pos_v2];
   check_result(@"PR2 + PR2", result, 371.2);
   /* PR + +INF */
   result = [pos_v add: pos_inf];
   check_result(@"PR + +INF", result, +INFINITY);
   /* PR2 + +INF */
   result = [pos_v2 add: pos_inf];
   check_result(@"PR2 + +INF", result, +INFINITY);
   /* +INF + +INF */
   result = [pos_inf add: pos_inf];
   check_result(@"+INF + +INF", result, +INFINITY);
   
   [neg_inf release];
   [neg_v release];
   [neg_v2 release];
   [zero release];
   [pos_v release];
   [pos_v2 release];
   [pos_inf release];
   [nan release];
   [result release];
}

void check_subtraction(){
   NSLog(@"SUBTRACTION");
   ORRational* neg_inf = [ORRational rationalWith_d: -INFINITY];
   ORRational* neg_v = [ORRational rationalWith_d: -123.4];
   ORRational* neg_v2 = [ORRational rationalWith_d: -0.21];
   ORRational* zero = [ORRational rationalWith_d: 0.0];
   ORRational* pos_v = [ORRational rationalWith_d: 43.23];
   ORRational* pos_v2 = [ORRational rationalWith_d: 185.6];
   ORRational* pos_inf = [ORRational rationalWith_d: +INFINITY];
   ORRational* nan = [ORRational rationalWith_d: NAN];
   ORRational* result = [[ORRational alloc] init];
   
   /* -INF - -INF */
   result = [neg_inf sub: neg_inf];
   check_result(@"-INF - -INF", result, NAN);
   /* -INF - NR */
   result = [neg_inf sub: neg_v];
   check_result(@"-INF - NR", result, -INFINITY);
   /* -INF - NR2 */
   result = [neg_inf sub: neg_v2];
   check_result(@"-INF - NR2", result, -INFINITY);
   /* -INF - 0 */
   result = [neg_inf sub: zero];
   check_result(@"-INF - 0", result, -INFINITY);
   /* -INF - PR */
   result = [neg_inf sub: pos_v];
   check_result(@"-INF - PR", result, -INFINITY);
   /* -INF - PR2 */
   result = [neg_inf sub: pos_v2];
   check_result(@"-INF - PR2", result, -INFINITY);
   /* -INF - +INF */
   result = [neg_inf sub: pos_inf];
   check_result(@"-INF - +INF", result, -INFINITY);
   /* NR - -INF */
   result = [neg_v sub: neg_inf];
   check_result(@"NR - -INF", result, +INFINITY);
   /* NR2 - -INF */
   result = [neg_v2 sub: neg_inf];
   check_result(@"NR2 - -INF", result, +INFINITY);
   /* NR - NR */
   result = [neg_v sub: neg_v];
   check_result(@"NR - NR", result, 0.0);
   /* NR2 - NR */
   result = [neg_v2 sub: neg_v];
   check_result(@"NR2 - NR", result, 123.19);
   /* NR - NR2 */
   result = [neg_v sub: neg_v2];
   check_result(@"NR - NR2", result, -123.19);
   /* NR2 - NR2 */
   result = [neg_v2 sub: neg_v2];
   check_result(@"NR2 - NR2", result, 0.0);
   /* NR - 0 */
   result = [neg_v sub: zero];
   check_result(@"NR - 0", result, -123.4);
   /* NR2 - 0 */
   result = [neg_v2 sub: zero];
   check_result(@"NR2 - 0", result, -0.21);
   /* NR - PR */
   result = [neg_v sub: pos_v];
   check_result(@"NR - PR", result, -166.63);
   /* NR2 - PR */
   result = [neg_v2 sub: pos_v];
   check_result(@"NR2 - PR", result, -43.44);
   /* NR - PR2 */
   result = [neg_v sub: pos_v2];
   check_result(@"NR - PR2", result, -309.0);
   /* NR2 - PR2 */
   result = [neg_v2 sub: pos_v2];
   check_result(@"NR2 - PR2", result, -185.81);
   /* NR - +INF */
   result = [neg_v sub: pos_inf];
   check_result(@"NR - +INF", result, -INFINITY);
   /* NR2 - +INF */
   result = [neg_v2 sub: pos_inf];
   check_result(@"NR2 - +INF", result, -INFINITY);
   /* 0 - -INF */
   result = [zero sub: neg_inf];
   check_result(@"0 - -INF", result, +INFINITY);
   /* 0 - NR */
   result = [zero sub: neg_v];
   check_result(@"0 - NR", result, 123.4);
   /* 0 - NR2 */
   result = [zero sub: neg_v2];
   check_result(@"0 - NR2", result, 0.21);
   /* 0 - 0 */
   result = [zero sub: zero];
   check_result(@"0 - 0", result, 0.0);
   /* 0 - PR */
   result = [zero sub: pos_v];
   check_result(@"0 - PR", result, -43.23);
   /* 0 - PR2 */
   result = [zero sub: pos_v2];
   check_result(@"0 - PR2", result, -185.6);
   /* 0 - +INF */
   result = [zero sub: pos_inf];
   check_result(@"0 - +INF", result, -INFINITY);
   /* PR - -INF */
   result = [pos_v sub: neg_inf];
   check_result(@"PR - -INF", result, +INFINITY);
   /* PR2 - -INF */
   result = [pos_v2 sub: neg_inf];
   check_result(@"PR2 - -INF", result, +INFINITY);
   /* PR - NR */
   result = [pos_v sub: neg_v];
   check_result(@"PR - NR", result, 166.63);
   /* PR2 - NR */
   result = [pos_v2 sub: neg_v];
   check_result(@"PR2 - NR", result,  309.0);
   /* PR - NR2 */
   result = [pos_v sub: neg_v2];
   check_result(@"PR - NR2", result, 43.44);
   /* PR2 - NR2 */
   result = [pos_v2 sub: neg_v2];
   check_result(@"PR2 - NR2", result, 185.81);
   /* PR - 0 */
   result = [pos_v sub: zero];
   check_result(@"PR - 0", result, 43.23);
   /* PR2 - 0 */
   result = [pos_v2 sub: zero];
   check_result(@"PR2 - 0", result, 185.6);
   /* PR - PR */
   result = [pos_v sub: pos_v];
   check_result(@"PR - PR", result, 0.0);
   /* PR2 - PR */
   result = [pos_v2 sub: pos_v];
   check_result(@"PR2 - PR", result, 142.37);
   /* PR - PR2 */
   result = [pos_v sub: pos_v2];
   check_result(@"PR - PR2", result, -142.37);
   /* PR2 - PR2 */
   result = [pos_v2 sub: pos_v2];
   check_result(@"PR2 - PR2", result, 0.0);
   /* PR - +INF */
   result = [pos_v sub: pos_inf];
   check_result(@"PR - +INF", result, -INFINITY);
   /* PR2 - +INF */
   result = [pos_v2 sub: pos_inf];
   check_result(@"PR2 - +INF", result, -INFINITY);
   /* +INF - -INF */
   result = [pos_inf sub: neg_inf];
   check_result(@"+INF - -INF", result, +INFINITY);
   /* +INF - NR */
   result = [pos_inf sub: neg_v];
   check_result(@"+INF - NR", result, +INFINITY);
   /* +INF - NR2 */
   result = [pos_inf sub: neg_v2];
   check_result(@"+INF - NR2", result, +INFINITY);
   /* +INF - 0 */
   result = [pos_inf sub: zero];
   check_result(@"+INF - 0", result, +INFINITY);
   /* +INF - PR */
   result = [pos_inf sub: pos_v];
   check_result(@"+INF - PR", result, +INFINITY);
   /* +INF - PR2 */
   result = [pos_inf sub: pos_v2];
   check_result(@"+INF - PR2", result, +INFINITY);
   /* +INF - +INF */
   result = [pos_inf sub: pos_inf];
   check_result(@"+INF - +INF", result, NAN);
   
   [neg_inf release];
   [neg_v release];
   [neg_v2 release];
   [zero release];
   [pos_v release];
   [pos_v2 release];
   [pos_inf release];
   [nan release];
   [result release];
}

void check_multiplication(){
   NSLog(@"MULTIPLICATION");
   
   ORRational* neg_inf = [ORRational rationalWith_d: -INFINITY];
   ORRational* neg_v = [ORRational rationalWith_d: -123.4];
   ORRational* neg_v2 = [ORRational rationalWith_d: -0.21];
   ORRational* zero = [ORRational rationalWith_d: 0.0];
   ORRational* pos_v = [ORRational rationalWith_d: 43.23];
   ORRational* pos_v2 = [ORRational rationalWith_d: 185.6];
   ORRational* pos_inf = [ORRational rationalWith_d: +INFINITY];
   ORRational* nan = [ORRational rationalWith_d: NAN];
   ORRational* result = [[ORRational alloc] init];
   
   /* Addition */
   /* -INF * -INF */
   result = [neg_inf mul: neg_inf];
   check_result(@"-INF * -INF", result, +INFINITY);
   /* -INF * NR */
   result = [neg_inf mul: neg_v];
   check_result(@"-INF * NR", result, +INFINITY);
   /* -INF * NR2 */
   result = [neg_inf mul: neg_v2];
   check_result(@"-INF * NR2", result, +INFINITY);
   /* -INF * 0 */
   result = [neg_inf mul: zero];
   check_result(@"-INF * 0", result, NAN);
   /* -INF * PR */
   result = [neg_inf mul: pos_v];
   check_result(@"-INF * PR", result, -INFINITY);
   /* -INF * PR2 */
   result = [neg_inf mul: pos_v2];
   check_result(@"-INF * PR2", result, -INFINITY);
   /* -INF * +INF */
   result = [neg_inf mul: pos_inf];
   check_result(@"-INF * +INF", result, -INFINITY);
   /* NR * NR */
   result = [neg_v mul: neg_v];
   check_result(@"NR * NR", result, 15227.56);
   /* NR2 * NR */
   result = [neg_v2 mul: neg_v];
   check_result(@"NR2 * NR", result, 25.914);
   /* NR2 * NR2 */
   result = [neg_v2 mul: neg_v2];
   check_result(@"NR2 * NR2", result, 0.0441);
   /* NR * 0 */
   result = [neg_v mul: zero];
   check_result(@"NR * 0", result, 0.0);
   /* NR2 * 0 */
   result = [neg_v2 mul: zero];
   check_result(@"NR2 * 0", result, 0.0);
   /* NR * PR */
   result = [neg_v mul: pos_v];
   check_result(@"NR * PR", result, -5334.582);
   /* NR2 * PR */
   result = [neg_v2 mul: pos_v];
   check_result(@"NR2 * PR", result, -9.0783);
   /* NR * PR2 */
   result = [neg_v mul: pos_v2];
   check_result(@"NR * PR2", result, -22903.04);
   /* NR2 * PR2 */
   result = [neg_v2 mul: pos_v2];
   check_result(@"NR2 * PR2", result, -38.976);
   /* NR * +INF */
   result = [neg_v mul: pos_inf];
   check_result(@"NR * +INF", result, -INFINITY);
   /* NR2 * +INF */
   result = [neg_v2 mul: pos_inf];
   check_result(@"NR2 * +INF", result, -INFINITY);
   /* 0 * 0 */
   result = [zero mul: zero];
   check_result(@"0 * 0", result, 0.0);
   /* 0 * PR */
   result = [zero mul: pos_v];
   check_result(@"0 * PR", result, 0.0);
   /* 0 * PR2 */
   result = [zero mul: pos_v2];
   check_result(@"0 * PR2", result, 0.0);
   /* 0 * +INF */
   result = [zero mul: pos_inf];
   check_result(@"0 * +INF", result, NAN);
   /* PR * PR */
   result = [pos_v mul: pos_v];
   check_result(@"PR * PR", result, 1868.8329);
   /* PR2 * PR */
   result = [pos_v2 mul: pos_v];
   check_result(@"PR2 * PR", result, 8023.488);
   /* PR2 * PR2 */
   result = [pos_v2 mul: pos_v2];
   check_result(@"PR2 * PR2", result, 34447.36);
   /* PR * +INF */
   result = [pos_v mul: pos_inf];
   check_result(@"PR * +INF", result, +INFINITY);
   /* PR2 * +INF */
   result = [pos_v2 mul: pos_inf];
   check_result(@"PR2 * +INF", result, +INFINITY);
   /* +INF * +INF */
   result = [pos_inf mul: pos_inf];
   check_result(@"+INF * +INF", result, +INFINITY);
   
   [neg_inf release];
   [neg_v release];
   [neg_v2 release];
   [zero release];
   [pos_v release];
   [pos_v2 release];
   [pos_inf release];
   [nan release];
   [result release];
}

void check_division(){
   NSLog(@"DIVISION");
   ORRational* neg_inf = [ORRational rationalWith_d: -INFINITY];
   ORRational* neg_v = [ORRational rationalWith_d: -123.4];
   ORRational* neg_v2 = [ORRational rationalWith_d: -0.21];
   ORRational* zero = [ORRational rationalWith_d: 0.0];
   ORRational* pos_v = [ORRational rationalWith_d: 43.23];
   ORRational* pos_v2 = [ORRational rationalWith_d: 185.6];
   ORRational* pos_inf = [ORRational rationalWith_d: +INFINITY];
   ORRational* nan = [ORRational rationalWith_d: NAN];
   ORRational* result = [[ORRational alloc] init];
   
   /* -INF / -INF */
   result = [neg_inf div: neg_inf];
   check_result(@"-INF / -INF", result, NAN);
   /* -INF / NR */
   result = [neg_inf div: neg_v];
   check_result(@"-INF / NR", result, +INFINITY);
   /* -INF / NR2 */
   result = [neg_inf div: neg_v2];
   check_result(@"-INF / NR2", result, +INFINITY);
   /* -INF / 0 */
   result = [neg_inf div: zero];
   check_result(@"-INF / 0", result, NAN);
   /* -INF / PR */
   result = [neg_inf div: pos_v];
   check_result(@"-INF / PR", result, -INFINITY);
   /* -INF / PR2 */
   result = [neg_inf div: pos_v2];
   check_result(@"-INF / PR2", result, -INFINITY);
   /* -INF / +INF */
   result = [neg_inf div: pos_inf];
   check_result(@"-INF / +INF", result, NAN);
   /* NR / -INF */
   result = [neg_v div: neg_inf];
   check_result(@"NR / -INF", result, 0.0);
   /* NR2 / -INF */
   result = [neg_v2 div: neg_inf];
   check_result(@"NR2 / -INF", result, 0.0);
   /* NR / NR */
   result = [neg_v div: neg_v];
   check_result(@"NR / NR", result, 1.0);
   /* NR2 / NR */
   result = [neg_v2 div: neg_v];
   check_result(@"NR2 / NR", result, 0.00170178282);
   /* NR / NR2 */
   result = [neg_v div: neg_v2];
   check_result(@"NR / NR2", result, 587.619047619);
   /* NR2 / NR2 */
   result = [neg_v2 div: neg_v2];
   check_result(@"NR2 / NR2", result, 1.0);
   /* NR / 0 */
   result = [neg_v div: zero];
   check_result(@"NR / 0", result, NAN);
   /* NR2 / 0 */
   result = [neg_v2 div: zero];
   check_result(@"NR2 / 0", result, NAN);
   /* NR / PR */
   result = [neg_v div: pos_v];
   check_result(@"NR / PR", result, -2.8544991904);
   /* NR2 / PR */
   result = [neg_v2 div: pos_v];
   check_result(@"NR2 / PR", result, -0.004857737682);
   /* NR / PR2 */
   result = [neg_v div: pos_v2];
   check_result(@"NR / PR2", result, -0.6648706897);
   /* NR2 / PR2 */
   result = [neg_v2 div: pos_v2];
   check_result(@"NR2 / PR2", result, -0.001131465517);
   /* NR / +INF */
   result = [neg_v div: pos_inf];
   check_result(@"NR / +INF", result, 0.0);
   /* NR2 / +INF */
   result = [neg_v2 div: pos_inf];
   check_result(@"NR2 / +INF", result, 0.0);
   /* 0 / -INF */
   result = [zero div: neg_inf];
   check_result(@"0 / -INF", result, 0.0);
   /* 0 / NR */
   result = [zero div: neg_v];
   check_result(@"0 / NR", result, 0.0);
   /* 0 / NR2 */
   result = [zero div: neg_v2];
   check_result(@"0 / NR2", result, 0.0);
   /* 0 / 0 */
   result = [zero div: zero];
   check_result(@"0 / 0", result, NAN);
   /* 0 / PR */
   result = [zero div: pos_v];
   check_result(@"0 / PR", result, 0.0);
   /* 0 / PR2 */
   result = [zero div: pos_v2];
   check_result(@"0 / PR2", result, 0.0);
   /* 0 / +INF */
   result = [zero div: pos_inf];
   check_result(@"0 / +INF", result, 0.0);
   /* PR / -INF */
   result = [pos_v div: neg_inf];
   check_result(@"PR / -INF", result, 0.0);
   /* PR2 / -INF */
   result = [pos_v2 div: neg_inf];
   check_result(@"PR2 / -INF", result, 0.0);
   /* PR / NR */
   result = [pos_v div: neg_v];
   check_result(@"PR / NR", result, -0.3503241491);
   /* PR2 / NR */
   result = [pos_v2 div: neg_v];
   check_result(@"PR2 / NR", result, -1.5040518639);
   /* PR / NR2 */
   result = [pos_v div: neg_v2];
   check_result(@"PR / NR2", result, -205.8571428571);
   /* PR2 / NR2 */
   result = [pos_v2 div: neg_v2];
   check_result(@"PR2 / NR2", result, -883.8095238095);
   /* PR / 0 */
   result = [pos_v div: zero];
   check_result(@"PR / 0", result, NAN);
   /* PR2 / 0 */
   result = [pos_v2 div: zero];
   check_result(@"PR2 / 0", result, NAN);
   /* PR / PR */
   result = [pos_v div: pos_v];
   check_result(@"PR / PR", result, 1.0);
   /* PR2 / PR */
   result = [pos_v2 div: pos_v];
   check_result(@"PR2 / PR", result, 4.2933148277);
   /* PR / PR2 */
   result = [pos_v div: pos_v2];
   check_result(@"PR / PR2", result, 0.2329202586);
   /* PR2 / PR2 */
   result = [pos_v2 div: pos_v2];
   check_result(@"PR2 / PR2", result, 1.0);
   /* PR / +INF */
   result = [pos_v div: pos_inf];
   check_result(@"PR / +INF", result, 0.0);
   /* PR2 / +INF */
   result = [pos_v2 div: pos_inf];
   check_result(@"PR2 / +INF", result, 0.0);
   /* +INF / -INF */
   result = [pos_inf div: neg_inf];
   check_result(@"+INF / -INF", result, NAN);
   /* +INF / NR */
   result = [pos_inf div: neg_v];
   check_result(@"+INF / NR", result, -INFINITY);
   /* +INF / NR2 */
   result = [pos_inf div: neg_v2];
   check_result(@"+INF / NR2", result, -INFINITY);
   /* +INF / 0 */
   result = [pos_inf div: zero];
   check_result(@"+INF / 0", result, NAN);
   /* +INF / PR */
   result = [pos_inf div: pos_v];
   check_result(@"+INF / PR", result, +INFINITY);
   /* +INF / PR2 */
   result = [pos_inf div: pos_v2];
   check_result(@"+INF / PR2", result, +INFINITY);
   /* +INF / +INF */
   result = [pos_inf div: pos_inf];
   check_result(@"+INF / +INF", result, NAN);
   
   [neg_inf release];
   [neg_v release];
   [neg_v2 release];
   [zero release];
   [pos_v release];
   [pos_v2 release];
   [pos_inf release];
   [nan release];
   [result release];
}

void check_addition_interval(){
   ORRationalInterval* ninf_a2 = [[ORRationalInterval alloc] init];
   ORRationalInterval* a1_a2 = [[ORRationalInterval alloc] init];
   ORRationalInterval* a1_pinf = [[ORRationalInterval alloc] init];
   ORRationalInterval* ninf_b2 = [[ORRationalInterval alloc] init];
   ORRationalInterval* b1_b2 = [[ORRationalInterval alloc] init];
   ORRationalInterval* b1_pinf = [[ORRationalInterval alloc] init];
   ORRationalInterval* ninf_pinf = [[ORRationalInterval alloc] init];
   ORRationalInterval* result = [[ORRationalInterval alloc] init];
   
   
   [ninf_a2 set_d:-INFINITY and:-0.21];
   [a1_a2 set_d:-123.4 and:-0.21];
   [a1_pinf set_d:-123.4 and:+INFINITY];
   [ninf_b2 set_d:-INFINITY and:185.6];
   [b1_b2 set_d:43.23 and:185.6];
   [b1_pinf set_d:43.23 and:+INFINITY];
   [ninf_pinf set_d:-INFINITY and:+INFINITY];
   
   /* (−∞, a2]  + (−∞, b2] */
   result = [ninf_a2 add: ninf_b2];
   check_result_interval(@"(−∞, a2]  + (−∞, b2]", result, -INFINITY, 185.39);
   /* (−∞, a2]  + [b1, b2] */
   result = [ninf_a2 add: b1_b2];
   check_result_interval(@"(−∞, a2]  + [b1, b2]", result, -INFINITY, 185.39);
   /* (−∞, a2]  + [b1, +∞) */
   result = [ninf_a2 add: b1_pinf];
   check_result_interval(@"(−∞, a2]  + [b1, +∞)", result, -INFINITY, +INFINITY);
   /* (−∞, a2]  + (−∞, +∞) */
   result = [ninf_a2 add: ninf_pinf];
   check_result_interval(@"(−∞, a2]  + (−∞, +∞)", result, -INFINITY, +INFINITY);

   /* [a1, a2]  + (−∞, b2] */
   result = [a1_a2 add: ninf_b2];
   check_result_interval(@"[a1, a2]  + (−∞, b2]", result, -INFINITY, 185.39);
   /* [a1, a2]  + [b1, b2] */
   result = [a1_a2 add: b1_b2];
   check_result_interval(@"[a1, a2]  + [b1, b2]", result, -80.17, 185.39);
   /* [a1, a2]  + [b1, +∞) */
   result = [a1_a2 add: b1_pinf];
   check_result_interval(@"[a1, a2]  + [b1, +∞)", result, -80.17, +INFINITY);
   /* [a1, a2]  + (−∞, +∞) */
   result = [a1_a2 add: ninf_pinf];
   check_result_interval(@"[a1, a2]  + (−∞, +∞)", result, -INFINITY, +INFINITY);
   
   /* [a1, +∞)  + (−∞, b2] */
   result = [a1_pinf add: ninf_b2];
   check_result_interval(@"[a1, +∞)  + (−∞, b2]", result, -INFINITY, +INFINITY);
   /* [a1, +∞)  + [b1, b2] */
   result = [a1_pinf add: b1_b2];
   check_result_interval(@"[a1, +∞)  + [b1, b2]", result, -80.17, +INFINITY);
   /* [a1, +∞)  + [b1, +∞) */
   result = [a1_pinf add: b1_pinf];
   check_result_interval(@"[a1, +∞)  + [b1, +∞)", result, -80.17, +INFINITY);
   /* [a1, +∞)  + (−∞, +∞) */
   result = [a1_pinf add: ninf_pinf];
   check_result_interval(@"[a1, +∞)  + (−∞, +∞)", result, -INFINITY, +INFINITY);

   /* (−∞, +∞)  + (−∞, b2] */
   result = [ninf_pinf add: ninf_b2];
   check_result_interval(@"(−∞, +∞)  + (−∞, b2]", result, -INFINITY, +INFINITY);
   /* (−∞, +∞)  + [b1, b2] */
   result = [ninf_pinf add: b1_b2];
   check_result_interval(@"(−∞, +∞)  + [b1, b2]", result, -INFINITY, +INFINITY);
   /* (−∞, +∞)  + [b1, +∞) */
   result = [ninf_pinf add: b1_pinf];
   check_result_interval(@"(−∞, +∞)  + [b1, +∞)", result, -INFINITY, +INFINITY);
   /* (−∞, +∞)  + (−∞, +∞) */
   result = [ninf_pinf add: ninf_pinf];
   check_result_interval(@"(−∞, +∞)  + (−∞, +∞)", result, -INFINITY, +INFINITY);
   
   [ninf_a2 release];
   [a1_a2 release];
   [a1_pinf release];
   [ninf_b2 release];
   [b1_b2 release];
   [b1_pinf release];
   [ninf_pinf release];
}

void check_subtraction_interval(){
   ORRationalInterval* ninf_a2 = [[ORRationalInterval alloc] init];
   ORRationalInterval* a1_a2 = [[ORRationalInterval alloc] init];
   ORRationalInterval* a1_pinf = [[ORRationalInterval alloc] init];
   ORRationalInterval* ninf_b2 = [[ORRationalInterval alloc] init];
   ORRationalInterval* b1_b2 = [[ORRationalInterval alloc] init];
   ORRationalInterval* b1_pinf = [[ORRationalInterval alloc] init];
   ORRationalInterval* ninf_pinf = [[ORRationalInterval alloc] init];
   ORRationalInterval* result = [[ORRationalInterval alloc] init];
   
   
   [ninf_a2 set_d:-INFINITY and:-0.21];
   [a1_a2 set_d:-123.4 and:-0.21];
   [a1_pinf set_d:-123.4 and:+INFINITY];
   [ninf_b2 set_d:-INFINITY and:185.6];
   [b1_b2 set_d:43.23 and:185.6];
   [b1_pinf set_d:43.23 and:+INFINITY];
   [ninf_pinf set_d:-INFINITY and:+INFINITY];
   
   /* (−∞, a2]  - (−∞, b2] */
   result = [ninf_a2 sub: ninf_b2];
   check_result_interval(@"(−∞, a2]  - (−∞, b2]", result, -INFINITY, +INFINITY);
   /* (−∞, a2]  - [b1, b2] */
   result = [ninf_a2 sub: b1_b2];
   check_result_interval(@"(−∞, a2]  - [b1, b2]", result, -INFINITY, -43.44);
   /* (−∞, a2]  - [b1, +∞) */
   result = [ninf_a2 sub: b1_pinf];
   check_result_interval(@"(−∞, a2]  - [b1, +∞)", result, -INFINITY, -43.44);
   /* (−∞, a2]  - (−∞, +∞) */
   result = [ninf_a2 sub: ninf_pinf];
   check_result_interval(@"(−∞, a2]  - (−∞, +∞)", result, -INFINITY, +INFINITY);
   
   /* [a1, a2]  - (−∞, b2] */
   result = [a1_a2 sub: ninf_b2];
   check_result_interval(@"[a1, a2]  - (−∞, b2]", result, -309.0, +INFINITY);
   /* [a1, a2]  - [b1, b2] */
   result = [a1_a2 sub: b1_b2];
   check_result_interval(@"[a1, a2]  - [b1, b2]", result, -309.0, -43.44);
   /* [a1, a2]  - [b1, +∞) */
   result = [a1_a2 sub: b1_pinf];
   check_result_interval(@"[a1, a2]  - [b1, +∞)", result, -INFINITY, -43.44);
   /* [a1, a2]  - (−∞, +∞) */
   result = [a1_a2 sub: ninf_pinf];
   check_result_interval(@"[a1, a2]  - (−∞, +∞)", result, -INFINITY, +INFINITY);
   
   /* [a1, +∞)  - (−∞, b2] */
   result = [a1_pinf sub: ninf_b2];
   check_result_interval(@"[a1, +∞)  - (−∞, b2]", result, -309.0, +INFINITY);
   /* [a1, +∞)  - [b1, b2] */
   result = [a1_pinf sub: b1_b2];
   check_result_interval(@"[a1, +∞)  - [b1, b2]", result, -309.0, +INFINITY);
   /* [a1, +∞)  - [b1, +∞) */
   result = [a1_pinf sub: b1_pinf];
   check_result_interval(@"[a1, +∞)  - [b1, +∞)", result, -INFINITY, +INFINITY);
   /* [a1, +∞)  - (−∞, +∞) */
   result = [a1_pinf sub: ninf_pinf];
   check_result_interval(@"[a1, +∞)  - (−∞, +∞)", result, -INFINITY, +INFINITY);
   
   /* (−∞, +∞)  - (−∞, b2] */
   result = [ninf_pinf sub: ninf_b2];
   check_result_interval(@"(−∞, +∞)  - (−∞, b2]", result, -INFINITY, +INFINITY);
   /* (−∞, +∞)  - [b1, b2] */
   result = [ninf_pinf sub: b1_b2];
   check_result_interval(@"(−∞, +∞)  - [b1, b2]", result, -INFINITY, +INFINITY);
   /* (−∞, +∞)  - [b1, +∞) */
   result = [ninf_pinf sub: b1_pinf];
   check_result_interval(@"(−∞, +∞)  - [b1, +∞)", result, -INFINITY, +INFINITY);
   /* (−∞, +∞)  - (−∞, +∞) */
   result = [ninf_pinf sub: ninf_pinf];
   check_result_interval(@"(−∞, +∞)  - (−∞, +∞)", result, -INFINITY, +INFINITY);
   
   [ninf_a2 release];
   [a1_a2 release];
   [a1_pinf release];
   [ninf_b2 release];
   [b1_b2 release];
   [b1_pinf release];
   [ninf_pinf release];
}

void check_multiplication_interval(){   
   ORRationalInterval* ninf_na2 = [[ORRationalInterval alloc] init];
   ORRationalInterval* ninf_pa2 = [[ORRationalInterval alloc] init];
   ORRationalInterval* a1_na2 = [[ORRationalInterval alloc] init];
   ORRationalInterval* a1_a2_0 = [[ORRationalInterval alloc] init];
   ORRationalInterval* pa1_a2 = [[ORRationalInterval alloc] init];
   ORRationalInterval* na1_pinf = [[ORRationalInterval alloc] init];
   ORRationalInterval* pa1_pinf = [[ORRationalInterval alloc] init];
   ORRationalInterval* ninf_nb2 = [[ORRationalInterval alloc] init];
   ORRationalInterval* ninf_pb2 = [[ORRationalInterval alloc] init];
   ORRationalInterval* b1_nb2 = [[ORRationalInterval alloc] init];
   ORRationalInterval* b1_b2_0 = [[ORRationalInterval alloc] init];
   ORRationalInterval* pb1_b2 = [[ORRationalInterval alloc] init];
   ORRationalInterval* z_z = [[ORRationalInterval alloc] init];
   ORRationalInterval* nb1_pinf = [[ORRationalInterval alloc] init];
   ORRationalInterval* pb1_pinf = [[ORRationalInterval alloc] init];
   ORRationalInterval* ninf_pinf = [[ORRationalInterval alloc] init];
   ORRationalInterval* result = [[ORRationalInterval alloc] init];
   
   [ninf_na2 set_d:-INFINITY and:-2.0];
   [ninf_pa2 set_d:-INFINITY and:2.0];
   [a1_na2 set_d:-6.0 and:-2.0];
   [a1_a2_0 set_d:-6.0 and:2.0];
   [pa1_a2 set_d:6.0 and:12.0];
   [na1_pinf set_d:-6.0 and:+INFINITY];
   [pa1_pinf set_d:6.0 and:+INFINITY];
   [ninf_nb2 set_d:-INFINITY and:-4.0];
   [ninf_pb2 set_d:-INFINITY and:4.0];
   [b1_nb2 set_d:-8.0 and:-4.0];
   [b1_b2_0 set_d:-8.0 and:4.0];
   [pb1_b2 set_d:8.0 and:16.0];
   [z_z set_d:0.0 and:0.0];
   [nb1_pinf set_d:-8.0 and:+INFINITY];
   [pb1_pinf set_d:8.0 and:+INFINITY];
   [ninf_pinf set_d:-INFINITY and:+INFINITY];
   
   /* [-6.0, -2.0], a2 ≤ 0  * [-8.0, -4.0] b2 ≤ 0 */
   result = [a1_na2 mul: b1_nb2];
   check_result_interval(@"[-6.0, -2.0], a2 ≤ 0  * [-8.0, -4.0] b2 ≤ 0", result, 8.0, 48.0);
   /* [-6.0, -2.0], a2 ≤ 0  * [-8.0, 4.0] b1 < 0 < b2 */
   result = [a1_na2 mul: b1_b2_0];
   check_result_interval(@"[-6.0, -2.0], a2 ≤ 0  * [-8.0, 4.0] b1 < 0 < b2", result, -24.0, 48.0);
   /* [-6.0, -2.0], a2 ≤ 0  * [8.0, 16.0] b1 ≥ 0 */
   result = [a1_na2 mul: pb1_b2];
   check_result_interval(@"[-6.0, -2.0], a2 ≤ 0  * [8.0, 16.0] b1 ≥ 0", result, -96.0, -16.0);
   /* [-6.0, -2.0], a2 ≤ 0  * [0, 0] */
   result = [a1_na2 mul: z_z];
   check_result_interval(@"[-6.0, -2.0], a2 ≤ 0  * [0, 0]", result, 0.0, 0.0);
   /* [-6.0, -2.0], a2 ≤ 0  * (−∞, -4.0] b2 ≤ 0 */
   result = [a1_na2 mul: ninf_nb2];
   check_result_interval(@"[-6.0, -2.0], a2 ≤ 0  * (−∞, -4.0] b2 ≤ 0", result, 8.0, +INFINITY);
   /* [-6.0, -2.0], a2 ≤ 0  * (−∞, 4.0] b2 ≥ 0 */
   result = [a1_na2 mul: ninf_pb2];
   check_result_interval(@"[-6.0, -2.0], a2 ≤ 0  * (−∞, 4.0] b2 ≥ 0", result, -24.0, +INFINITY);
   /* [-6.0, -2.0], a2 ≤ 0  * [-8.0, +∞) b1 ≤ 0 */
   result = [a1_na2 mul: nb1_pinf];
   check_result_interval(@"[-6.0, -2.0], a2 ≤ 0  * [-8.0, +∞) b1 ≤ 0", result, -INFINITY, 48.0);
   /* [-6.0, -2.0], a2 ≤ 0  * [8.0, +∞) b1 ≥ 0 */
   result = [a1_na2 mul: pb1_pinf];
   check_result_interval(@"[-6.0, -2.0], a2 ≤ 0  * [8.0, +∞) b1 ≥ 0", result, -INFINITY, -16.0);
   /* [-6.0, -2.0], a2 ≤ 0  *  (−∞, +∞) */
   result = [a1_na2 mul: ninf_pinf];
   check_result_interval(@"[-6.0, -2.0], a2 ≤ 0  *  (−∞, +∞)", result, -INFINITY, +INFINITY);
   
   /* */
   
   /* [-6.0, 2.0], a1 ≤ 0 ≤ a2  * [-8.0, -4.0] b2 ≤ 0 */
   result = [a1_a2_0 mul: b1_nb2];
   check_result_interval(@"[-6.0, 2.0], a1 ≤ 0 ≤ a2  * [-8.0, -4.0] b2 ≤ 0", result, -16.0, 48.0);
   /* [-6.0, 2.0], a1 ≤ 0 ≤ a2  * [-8.0, 4.0] b1 < 0 < b2 */
   result = [a1_a2_0 mul: b1_b2_0];
   check_result_interval(@"[-6.0, 2.0], a1 ≤ 0 ≤ a2  * [-8.0, 4.0] b1 < 0 < b2", result, -24.0, 48.0);
   /* [-6.0, 2.0], a1 ≤ 0 ≤ a2  * [8.0, 16.0] b1 ≥ 0 */
   result = [a1_a2_0 mul: pb1_b2];
   check_result_interval(@"[-6.0, 2.0], a1 ≤ 0 ≤ a2  * [8.0, 16.0] b1 ≥ 0", result, -96.0, 32.0);
   /* [-6.0, 2.0], a1 ≤ 0 ≤ a2  * [0, 0] */
   result = [a1_a2_0 mul: z_z];
   check_result_interval(@"[-6.0, 2.0], a1 ≤ 0 ≤ a2  * [0, 0]", result, 0.0, 0.0);
   /* [-6.0, 2.0], a1 ≤ 0 ≤ a2  * (−∞, -4.0] b2 ≤ 0 */
   result = [a1_a2_0 mul: ninf_nb2];
   check_result_interval(@"[-6.0, 2.0], a1 ≤ 0 ≤ a2  * (−∞, -4.0] b2 ≤ 0", result, -INFINITY, +INFINITY);
   /* [-6.0, 2.0], a1 ≤ 0 ≤ a2  * (−∞, 4.0] b2 ≥ 0 */
   result = [a1_a2_0 mul: ninf_pb2];
   check_result_interval(@"[-6.0, 2.0], a1 ≤ 0 ≤ a2  * (−∞, 4.0] b2 ≥ 0", result, -INFINITY, +INFINITY);
   /* [-6.0, 2.0], a1 ≤ 0 ≤ a2  * [-8.0, +∞) b1 ≤ 0 */
   result = [a1_a2_0 mul: nb1_pinf];
   check_result_interval(@"[-6.0, 2.0], a1 ≤ 0 ≤ a2  * [-8.0, +∞) b1 ≤ 0", result, -INFINITY, +INFINITY);
   /* [-6.0, 2.0], a1 ≤ 0 ≤ a2  * [8.0, +∞) b1 ≥ 0 */
   result = [a1_a2_0 mul: pb1_pinf];
   check_result_interval(@"[-6.0, 2.0], a1 ≤ 0 ≤ a2  * [8.0, +∞) b1 ≥ 0", result, -INFINITY, +INFINITY);
   /* [-6.0, 2.0], a1 ≤ 0 ≤ a2  *  (−∞, +∞) */
   result = [a1_a2_0 mul: ninf_pinf];
   check_result_interval(@"[-6.0, 2.0], a1 ≤ 0 ≤ a2  *  (−∞, +∞)", result, -INFINITY, +INFINITY);
   
   /* */
   
   /* [6.0, 12.0], a1 ≥ 0  * [-8.0, -4.0] b2 ≤ 0 */
   result = [pa1_a2 mul: b1_nb2];
   check_result_interval(@"[6.0, 12.0], a1 ≥ 0  * [-8.0, -4.0] b2 ≤ 0", result, -96.0, -24.0);
   /* [6.0, 12.0], a1 ≥ 0  * [-8.0, 4.0] b1 < 0 < b2 */
   result = [pa1_a2 mul: b1_b2_0];
   check_result_interval(@"[6.0, 12.0], a1 ≥ 0  * [-8.0, 4.0] b1 < 0 < b2", result, -96.0, 48.0);
   /* [6.0, 12.0], a1 ≥ 0  * [8.0, 16.0] b1 ≥ 0 */
   result = [pa1_a2 mul: pb1_b2];
   check_result_interval(@"[6.0, 12.0], a1 ≥ 0  * [8.0, 16.0] b1 ≥ 0", result, 48.0, 192.0);
   /* [6.0, 12.0], a1 ≥ 0  * [0, 0] */
   result = [pa1_a2 mul: z_z];
   check_result_interval(@"[6.0, 12.0], a1 ≥ 0  * [0, 0]", result, 0.0, 0.0   );
   /* [6.0, 12.0], a1 ≥ 0  * (−∞, -4.0] b2 ≤ 0 */
   result = [pa1_a2 mul: ninf_nb2];
   check_result_interval(@"[6.0, 12.0], a1 ≥ 0  * (−∞, -4.0] b2 ≤ 0", result, -INFINITY, -24.0);
   /* [6.0, 12.0], a1 ≥ 0  * (−∞, 4.0] b2 ≥ 0 */
   result = [pa1_a2 mul: ninf_pb2];
   check_result_interval(@"[6.0, 12.0], a1 ≥ 0  * (−∞, 4.0] b2 ≥ 0", result, -INFINITY, 48.0);
   /* [6.0, 12.0], a1 ≥ 0  * [-8.0, +∞) b1 ≤ 0 */
   result = [pa1_a2 mul: nb1_pinf];
   check_result_interval(@"[6.0, 12.0], a1 ≥ 0  * [-8.0, +∞) b1 ≤ 0", result, -96.0, +INFINITY);
   /* [6.0, 12.0], a1 ≥ 0  * [8.0, +∞) b1 ≥ 0 */
   result = [pa1_a2 mul: pb1_pinf];
   check_result_interval(@"[6.0, 12.0], a1 ≥ 0  * [8.0, +∞) b1 ≥ 0", result, 48.0, +INFINITY);
   /* [6.0, 12.0], a1 ≥ 0  *  (−∞, +∞) */
   result = [pa1_a2 mul: ninf_pinf];
   check_result_interval(@"[6.0, 12.0], a1 ≥ 0  *  (−∞, +∞)", result, -INFINITY, +INFINITY);

   
   /* */
   
   /* [0, 0]  * [-8.0, -4.0] b2 ≤ 0 */
   result = [z_z mul: b1_nb2];
   check_result_interval(@"[0, 0]  * [-8.0, -4.0] b2 ≤ 0", result, 0.0, 0.0);
   /* [0, 0]  * [-8.0, 4.0] b1 < 0 < b2 */
   result = [z_z mul: b1_b2_0];
   check_result_interval(@"[0, 0]  * [-8.0, 4.0] b1 < 0 < b2", result, 0.0, 0.0);
   /* [0, 0]  * [8.0, 16.0] b1 ≥ 0 */
   result = [z_z mul: pb1_b2];
   check_result_interval(@"[0, 0]  * [8.0, 16.0] b1 ≥ 0", result, 0.0, 0.0);
   /* [0, 0]  * [0, 0] */
   result = [z_z mul: z_z];
   check_result_interval(@"[0, 0]  * [0, 0]", result, 0.0, 0.0);
   /* [0, 0]  * (−∞, -4.0] b2 ≤ 0 */
   result = [z_z mul: ninf_nb2];
   check_result_interval(@"[0, 0]  * (−∞, -4.0] b2 ≤ 0", result, NAN, 0.0);
   /* [0, 0]  * (−∞, 4.0] b2 ≥ 0 */
   result = [z_z mul: ninf_pb2];
   check_result_interval(@"[0, 0]  * (−∞, 4.0] b2 ≥ 0", result, NAN, 0.0);
   /* [0, 0]  * [-8.0, +∞) b1 ≤ 0 */
   result = [z_z mul: nb1_pinf];
   check_result_interval(@"[0, 0]  * [-8.0, +∞) b1 ≤ 0", result, 0.0, NAN);
   /* [0, 0]  * [8.0, +∞) b1 ≥ 0 */
   result = [z_z mul: pb1_pinf];
   check_result_interval(@"[0, 0] * [8.0, +∞) b1 ≥ 0", result, 0.0, NAN);
   /* [0, 0]  *  (−∞, +∞) */
   result = [z_z mul: ninf_pinf];
   check_result_interval(@"[0, 0]  *  (−∞, +∞)", result, NAN, NAN);
   
   /* */
   
   /* (−∞, -2.0] a2 ≤ 0  * [-8.0, -4.0] b2 ≤ 0 */
   result = [ninf_na2 mul: b1_nb2];
   check_result_interval(@"(−∞, -2.0] a2 ≤ 0  * [-8.0, -4.0] b2 ≤ 0", result, 8.0, +INFINITY);
   /* (−∞, -2.0] a2 ≤ 0  * [-8.0, 4.0] b1 < 0 < b2 */
   result = [ninf_na2 mul: b1_b2_0];
   check_result_interval(@"(−∞, -2.0] a2 ≤ 0  * [-8.0, 4.0] b1 < 0 < b2", result, -INFINITY, +INFINITY);
   /* (−∞, -2.0] a2 ≤ 0  * [8.0, 16.0] b1 ≥ 0 */
   result = [ninf_na2 mul: pb1_b2];
   check_result_interval(@"(−∞, -2.0] a2 ≤ 0  * [8.0, 16.0] b1 ≥ 0", result, -INFINITY, -16.0);
   /* (−∞, -2.0] a2 ≤ 0  * [0, 0] */
   result = [ninf_na2 mul: z_z];
   check_result_interval(@"(−∞, -2.0] a2 ≤ 0  * [0, 0]", result, NAN, 0.0);
   /* (−∞, -2.0] a2 ≤ 0  * (−∞, -4.0] b2 ≤ 0 */
   result = [ninf_na2 mul: ninf_nb2];
   check_result_interval(@"(−∞, -2.0] a2 ≤ 0  * (−∞, -4.0] b2 ≤ 0", result, 8.0, +INFINITY);
   /* (−∞, -2.0] a2 ≤ 0  * (−∞, 4.0] b2 ≥ 0 */
   result = [ninf_na2 mul: ninf_pb2];
   check_result_interval(@"(−∞, -2.0] a2 ≤ 0  * (−∞, 4.0] b2 ≥ 0", result, -INFINITY, +INFINITY);
   /* (−∞, -2.0] a2 ≤ 0  * [-8.0, +∞) b1 ≤ 0 */
   result = [ninf_na2 mul: nb1_pinf];
   check_result_interval(@"(−∞, -2.0] a2 ≤ 0  * [-8.0, +∞) b1 ≤ 0", result, -INFINITY, +INFINITY);
   /* (−∞, -2.0] a2 ≤ 0  * [8.0, +∞) b1 ≥ 0 */
   result = [ninf_na2 mul: pb1_pinf];
   check_result_interval(@"(−∞, -2.0] a2 ≤ 0 * [8.0, +∞) b1 ≥ 0", result, -INFINITY, -16.0);
   /* (−∞, -2.0] a2 ≤ 0  *  (−∞, +∞) */
   result = [ninf_na2 mul: ninf_pinf];
   check_result_interval(@"(−∞, -2.0] a2 ≤ 0  *  (−∞, +∞)", result, -INFINITY, +INFINITY);
   
   /* */
   
   /* (−∞, 2.0] a2 ≥ 0  * [-8.0, -4.0] b2 ≤ 0 */
   result = [ninf_pa2 mul: b1_nb2];
   check_result_interval(@"(−∞, 2.0] a2 ≥ 0  * [-8.0, -4.0] b2 ≤ 0", result, -16.0, +INFINITY);
   /* (−∞, 2.0] a2 ≥ 0  * [-8.0, 4.0] b1 < 0 < b2 */
   result = [ninf_pa2 mul: b1_b2_0];
   check_result_interval(@"(−∞, 2.0] a2 ≥ 0  * [-8.0, 4.0] b1 < 0 < b2", result, -INFINITY, +INFINITY);
   /* (−∞, 2.0] a2 ≥ 0  * [8.0, 16.0] b1 ≥ 0 */
   result = [ninf_pa2 mul: pb1_b2];
   check_result_interval(@"(−∞, 2.0] a2 ≥ 0  * [8.0, 16.0] b1 ≥ 0", result, -INFINITY, 32.0);
   /* (−∞, 2.0] a2 ≥ 0  * [0, 0] */
   result = [ninf_pa2 mul: z_z];
   check_result_interval(@"(−∞, 2.0] a2 ≥ 0  * [0, 0]", result, NAN, 0.0);
   /* (−∞, 2.0] a2 ≥ 0  * (−∞, -4.0] b2 ≤ 0 */
   result = [ninf_pa2 mul: ninf_nb2];
   check_result_interval(@"(−∞, 2.0] a2 ≥ 0  * (−∞, -4.0] b2 ≤ 0", result, -INFINITY, +INFINITY);
   /* (−∞, 2.0] a2 ≥ 0  * (−∞, 4.0] b2 ≥ 0 */
   result = [ninf_pa2 mul: ninf_pb2];
   check_result_interval(@"(−∞, 2.0] a2 ≥ 0  * (−∞, 4.0] b2 ≥ 0", result, -INFINITY, +INFINITY);
   /* (−∞, 2.0] a2 ≥ 0  * [-8.0, +∞) b1 ≤ 0 */
   result = [ninf_pa2 mul: nb1_pinf];
   check_result_interval(@"(−∞, 2.0] a2 ≥ 0  * [-8.0, +∞) b1 ≤ 0", result, -INFINITY, +INFINITY);
   /* (−∞, 2.0] a2 ≥ 0  * [8.0, +∞) b1 ≥ 0 */
   result = [ninf_pa2 mul: pb1_pinf];
   check_result_interval(@"(−∞, 2.0] a2 ≥ 0 * [8.0, +∞) b1 ≥ 0", result, -INFINITY, +INFINITY);
   /* (−∞, 2.0] a2 ≥ 0  *  (−∞, +∞) */
   result = [ninf_pa2 mul: ninf_pinf];
   check_result_interval(@"(−∞, 2.0] a2 ≥ 0  *  (−∞, +∞)", result, -INFINITY, +INFINITY);
   
   /* */
   
   /* [-6.0, +∞), a1 ≤ 0  * [-8.0, -4.0] b2 ≤ 0 */
   result = [na1_pinf mul: b1_nb2];
   check_result_interval(@"[-6.0, +∞), a1 ≤ 0  * [-8.0, -4.0] b2 ≤ 0", result, -INFINITY, 48.0);
   /* [-6.0, +∞), a1 ≤ 0  * [-8.0, 4.0] b1 < 0 < b2 */
   result = [na1_pinf mul: b1_b2_0];
   check_result_interval(@"[-6.0, +∞), a1 ≤ 0  * [-8.0, 4.0] b1 < 0 < b2", result, -INFINITY, +INFINITY);
   /* [-6.0, +∞), a1 ≤ 0  * [8.0, 16.0] b1 ≥ 0 */
   result = [na1_pinf mul: pb1_b2];
   check_result_interval(@"[-6.0, +∞), a1 ≤ 0  * [8.0, 16.0] b1 ≥ 0", result, -96.0, +INFINITY);
   /* [-6.0, +∞), a1 ≤ 0  * [0, 0] */
   result = [na1_pinf mul: z_z];
   check_result_interval(@"[-6.0, +∞), a1 ≤ 0  * [0, 0]", result, 0.0, NAN);
   /* [-6.0, +∞), a1 ≤ 0  * (−∞, -4.0] b2 ≤ 0 */
   result = [na1_pinf mul: ninf_nb2];
   check_result_interval(@"[-6.0, +∞), a1 ≤ 0  * (−∞, -4.0] b2 ≤ 0", result, -INFINITY, +INFINITY);
   /* [-6.0, +∞), a1 ≤ 0  * (−∞, 4.0] b2 ≥ 0 */
   result = [na1_pinf mul: ninf_pb2];
   check_result_interval(@"[-6.0, +∞), a1 ≤ 0  * (−∞, 4.0] b2 ≥ 0", result, -INFINITY, +INFINITY);
   /* [-6.0, +∞), a1 ≤ 0  * [-8.0, +∞) b1 ≤ 0 */
   result = [na1_pinf mul: nb1_pinf];
   check_result_interval(@"[-6.0, +∞), a1 ≤ 0  * [-8.0, +∞) b1 ≤ 0", result, -INFINITY, +INFINITY);
   /* [-6.0, +∞), a1 ≤ 0  * [8.0, +∞) b1 ≥ 0 */
   result = [na1_pinf mul: pb1_pinf];
   check_result_interval(@"[-6.0, +∞), a1 ≤ 0 * [8.0, +∞) b1 ≥ 0", result, -INFINITY, +INFINITY);
   /* [-6.0, +∞), a1 ≤ 0  *  (−∞, +∞) */
   result = [na1_pinf mul: ninf_pinf];
   check_result_interval(@"[-6.0, +∞), a1 ≤ 0  *  (−∞, +∞)", result, -INFINITY, +INFINITY);
   
   /* */
   
   /* [6.0, +∞), a1 ≥ 0  * [-8.0, -4.0] b2 ≤ 0 */
   result = [pa1_pinf mul: b1_nb2];
   check_result_interval(@"[6.0, +∞), a1 ≥ 0  * [-8.0, -4.0] b2 ≤ 0", result, -INFINITY, -24.0);
   /* [6.0, +∞), a1 ≥ 0  * [-8.0, 4.0] b1 < 0 < b2 */
   result = [pa1_pinf mul: b1_b2_0];
   check_result_interval(@"[6.0, +∞), a1 ≥ 0  * [-8.0, 4.0] b1 < 0 < b2", result, -INFINITY, +INFINITY);
   /* [6.0, +∞), a1 ≥ 0  * [8.0, 16.0] b1 ≥ 0 */
   result = [pa1_pinf mul: pb1_b2];
   check_result_interval(@"[6.0, +∞), a1 ≥ 0  * [8.0, 16.0] b1 ≥ 0", result, 48.0, +INFINITY);
   /* [6.0, +∞), a1 ≥ 0  * [0, 0] */
   result = [pa1_pinf mul: z_z];
   check_result_interval(@"[6.0, +∞), a1 ≥ 0  * [0, 0]", result, 0.0, NAN);
   /* [6.0, +∞), a1 ≥ 0  * (−∞, -4.0] b2 ≤ 0 */
   result = [pa1_pinf mul: ninf_nb2];
   check_result_interval(@"[6.0, +∞), a1 ≥ 0  * (−∞, -4.0] b2 ≤ 0", result, -INFINITY, -24.0);
   /* [6.0, +∞), a1 ≥ 0  * (−∞, 4.0] b2 ≥ 0 */
   result = [pa1_pinf mul: ninf_pb2];
   check_result_interval(@"[6.0, +∞), a1 ≥ 0  * (−∞, 4.0] b2 ≥ 0", result, -INFINITY, +INFINITY);
   /* [6.0, +∞), a1 ≥ 0  * [-8.0, +∞) b1 ≤ 0 */
   result = [pa1_pinf mul: nb1_pinf];
   check_result_interval(@"[6.0, +∞), a1 ≥ 0  * [-8.0, +∞) b1 ≤ 0", result, -INFINITY, +INFINITY);
   /* [6.0, +∞), a1 ≥ 0  * [8.0, +∞) b1 ≥ 0 */
   result = [pa1_pinf mul: pb1_pinf];
   check_result_interval(@"[6.0, +∞), a1 ≥ 0 * [8.0, +∞) b1 ≥ 0", result, 48.0, +INFINITY);
   /* [6.0, +∞), a1 ≥ 0  *  (−∞, +∞) */
   result = [pa1_pinf mul: ninf_pinf];
   check_result_interval(@"[6.0, +∞), a1 ≥ 0  *  (−∞, +∞)", result, -INFINITY, +INFINITY);
   
   /* */
   
   /* (−∞, +∞)  * [-8.0, -4.0] b2 ≤ 0 */
   result = [ninf_pinf mul: b1_nb2];
   check_result_interval(@"(−∞, +∞)  * [-8.0, -4.0] b2 ≤ 0", result, -INFINITY, +INFINITY);
   /* (−∞, +∞)  * [-8.0, 4.0] b1 < 0 < b2 */
   result = [ninf_pinf mul: b1_b2_0];
   check_result_interval(@"(−∞, +∞)  * [-8.0, 4.0] b1 < 0 < b2", result, -INFINITY, +INFINITY);
   /* (−∞, +∞)  * [8.0, 16.0] b1 ≥ 0 */
   result = [ninf_pinf mul: pb1_b2];
   check_result_interval(@"(−∞, +∞)  * [8.0, 16.0] b1 ≥ 0", result, -INFINITY, +INFINITY);
   /* (−∞, +∞)  * [0, 0] */
   result = [ninf_pinf mul: z_z];
   check_result_interval(@"(−∞, +∞)  * [0, 0]", result, NAN, NAN);
   /* (−∞, +∞)  * (−∞, -4.0] b2 ≤ 0 */
   result = [ninf_pinf mul: ninf_nb2];
   check_result_interval(@"(−∞, +∞)  * (−∞, -4.0] b2 ≤ 0", result, -INFINITY, +INFINITY);
   /* (−∞, +∞)  * (−∞, 4.0] b2 ≥ 0 */
   result = [ninf_pinf mul: ninf_pb2];
   check_result_interval(@"(−∞, +∞)  * (−∞, 4.0] b2 ≥ 0", result, -INFINITY, +INFINITY);
   /* (−∞, +∞)  * [-8.0, +∞) b1 ≤ 0 */
   result = [ninf_pinf mul: nb1_pinf];
   check_result_interval(@"(−∞, +∞)  * [-8.0, +∞) b1 ≤ 0", result, -INFINITY, +INFINITY);
   /* (−∞, +∞)  * [8.0, +∞) b1 ≥ 0 */
   result = [ninf_pinf mul: pb1_pinf];
   check_result_interval(@"(−∞, +∞) * [8.0, +∞) b1 ≥ 0", result, -INFINITY, +INFINITY);
   /* (−∞, +∞)  *  (−∞, +∞) */
   result = [ninf_pinf mul: ninf_pinf];
   check_result_interval(@"(−∞, +∞)  *  (−∞, +∞)", result, -INFINITY, +INFINITY);
   
   [ninf_na2 release];
   [ninf_pa2 release];
   [a1_na2 release];
   [a1_a2_0 release];
   [pa1_a2 release];
   [na1_pinf release];
   [pa1_pinf release];
   [ninf_nb2 release];
   [ninf_pb2 release];
   [b1_nb2 release];
   [b1_b2_0 release];
   [pb1_b2 release];
   [z_z release];
   [nb1_pinf release];
   [pb1_pinf release];
   [ninf_pinf release];
   [result release];
}

void check_division_interval(){

   ORRationalInterval* a1_na2 = [[ORRationalInterval alloc] init];
   ORRationalInterval* a1_a2_0 = [[ORRationalInterval alloc] init];
   ORRationalInterval* pa1_a2 = [[ORRationalInterval alloc] init];
   ORRationalInterval* ninf_na2 = [[ORRationalInterval alloc] init];
   ORRationalInterval* ninf_pa2 = [[ORRationalInterval alloc] init];
   ORRationalInterval* na1_pinf = [[ORRationalInterval alloc] init];
   ORRationalInterval* pa1_pinf = [[ORRationalInterval alloc] init];
   ORRationalInterval* z_z = [[ORRationalInterval alloc] init];
   ORRationalInterval* b1_z = [[ORRationalInterval alloc] init];
   ORRationalInterval* z_b2 = [[ORRationalInterval alloc] init];
   ORRationalInterval* ninf_z = [[ORRationalInterval alloc] init];
   ORRationalInterval* z_pinf = [[ORRationalInterval alloc] init];
   ORRationalInterval* ninf_pinf = [[ORRationalInterval alloc] init];
   ORRationalInterval* result = [[ORRationalInterval alloc] init];
   
   
   [a1_na2 set_d:-6.0 and:-2.0];
   [a1_a2_0 set_d:-6.0 and:2.0];
   [pa1_a2 set_d:6.0 and:12.0];
   [ninf_na2 set_d:-INFINITY  and:-2.0];
   [ninf_pa2 set_d:-INFINITY and:2.0];
   [na1_pinf set_d:-2.0 and:+INFINITY];
   [pa1_pinf set_d:2.0 and:+INFINITY];
   
   [z_z set_d:0.0 and:0.0];
   [b1_z set_d:-8.0 and:0.0];
   [z_b2 set_d:0.0 and:4.0];
   [ninf_z set_d:-INFINITY and:0.0];
   [z_pinf set_d:0.0 and:+INFINITY];
   
   [ninf_pinf set_d:-INFINITY and:+INFINITY];
   
   /* [-6.0, -2.0], a2 ≤ 0  / [0.0, 0.0] */
   result = [a1_na2 div: z_z];
   check_result_interval(@"[-6.0, -2.0], a2 ≤ 0  / [0.0, 0.0]", result, -INFINITY, +INFINITY);
   /* [-6.0, -2.0], a2 ≤ 0  / [-8.0, 0.0] */
   result = [a1_na2 div: b1_z];
   check_result_interval(@"[-6.0, -2.0], a2 ≤ 0  / [-8.0, 0.0]", result, 0.25, +INFINITY);
   /* [-6.0, -2.0], a2 ≤ 0  / [0.0, 4.0] */
   result = [a1_na2 div: z_b2];
   check_result_interval(@"[-6.0, -2.0], a2 ≤ 0  / [0.0, 4.0]", result, -INFINITY, -0.5);
   /* [-6.0, -2.0], a2 ≤ 0  / (−∞, 0.0] */
   result = [a1_na2 div: ninf_z];
   check_result_interval(@"[-6.0, -2.0], a2 ≤ 0  / (−∞, 0.0]", result, 0.0, +INFINITY);
   /* [-6.0, -2.0], a2 ≤ 0  / [0.0, +∞) */
   result = [a1_na2 div: z_pinf];
   check_result_interval(@"[-6.0, -2.0], a2 ≤ 0  / [0.0, +∞)", result, -INFINITY, 0.0);
   /* [-6.0, -2.0], a2 ≤ 0  /  (−∞, +∞) */
   result = [a1_na2 div: ninf_pinf];
   check_result_interval(@"[-6.0, -2.0], a2 ≤ 0  /  (−∞, +∞)", result, -INFINITY, +INFINITY);
   
   /* [-6.0, 2.0], a1 ≤ 0 ≤ a2  / [0.0, 0.0] */
   result = [a1_a2_0 div: z_z];
   check_result_interval(@"[-6.0, 2.0], a1 ≤ 0 ≤ a2  / [0.0, 0.0]", result, -INFINITY, +INFINITY);
   /* [-6.0, 2.0], a1 ≤ 0 ≤ a2  / [-8.0, 0.0] */
   result = [a1_a2_0 div: b1_z];
   check_result_interval(@"[-6.0, 2.0], a1 ≤ 0 ≤ a2  / [-8.0, 0.0]", result, -INFINITY, +INFINITY);
   /* [-6.0, 2.0], a1 ≤ 0 ≤ a2  / [0.0, 4.0] */
   result = [a1_a2_0 div: z_b2];
   check_result_interval(@"[-6.0, 2.0], a1 ≤ 0 ≤ a2  / [0.0, 4.0]", result, -INFINITY, +INFINITY);
   /* [-6.0, 2.0], a1 ≤ 0 ≤ a2  / (−∞, 0.0] */
   result = [a1_a2_0 div: ninf_z];
   check_result_interval(@"[-6.0, 2.0], a1 ≤ 0 ≤ a2  / (−∞, 0.0]", result, -INFINITY, +INFINITY);
   /* [-6.0, 2.0], a1 ≤ 0 ≤ a2  / [0.0, +∞) */
   result = [a1_a2_0 div: z_pinf];
   check_result_interval(@"[-6.0, 2.0], a1 ≤ 0 ≤ a2  / [0.0, +∞)", result, -INFINITY, +INFINITY);
   /* [-6.0, 2.0], a1 ≤ 0 ≤ a2  /  (−∞, +∞) */
   result = [a1_a2_0 div: ninf_pinf];
   check_result_interval(@"[-6.0, 2.0], a1 ≤ 0 ≤ a2  /  (−∞, +∞)", result, -INFINITY, +INFINITY);
   
   /* [6.0, 12.0], a1 ≥ 0  / [0.0, 0.0] */
   result = [pa1_a2 div: z_z];
   check_result_interval(@"[6.0, 12.0], a1 ≥ 0  / [0.0, 0.0]", result, -INFINITY, +INFINITY);
   /* [6.0, 12.0], a1 ≥ 0  / [-8.0, 0.0] */
   result = [pa1_a2 div: b1_z];
   check_result_interval(@"[6.0, 12.0], a1 ≥ 0  / [-8.0, 0.0]", result, -INFINITY, -0.75);
   /* [6.0, 12.0], a1 ≥ 0  / [0.0, 4.0] */
   result = [pa1_a2 div: z_b2];
   check_result_interval(@"[6.0, 12.0], a1 ≥ 0  / [0.0, 4.0]", result, 1.5, +INFINITY);
   /* [6.0, 12.0], a1 ≥ 0  / (−∞, 0.0] */
   result = [pa1_a2 div: ninf_z];
   check_result_interval(@"[6.0, 12.0], a1 ≥ 0  / (−∞, 0.0]", result, -INFINITY, 0.0);
   /* [6.0, 12.0], a1 ≥ 0  / [0.0, +∞) */
   result = [pa1_a2 div: z_pinf];
   check_result_interval(@"[6.0, 12.0], a1 ≥ 0  / [0.0, +∞)", result, 0.0, +INFINITY);
   /* [6.0, 12.0], a1 ≥ 0  /  (−∞, +∞) */
   result = [pa1_a2 div: ninf_pinf];
   check_result_interval(@"[6.0, 12.0], a1 ≥ 0  /  (−∞, +∞)", result, -INFINITY, +INFINITY);
   
   /* (−∞, -2.0] a2 ≤ 0  / [0.0, 0.0] */
   result = [ninf_na2 div: z_z];
   check_result_interval(@"(−∞, -2.0] a2 ≤ 0  / [0.0, 0.0]", result, -INFINITY, +INFINITY);
   /* (−∞, -2.0] a2 ≤ 0  / [-8.0, 0.0] */
   result = [ninf_na2 div: b1_z];
   check_result_interval(@"(−∞, -2.0] a2 ≤ 0  / [-8.0, 0.0]", result, 0.25, +INFINITY);
   /* (−∞, -2.0] a2 ≤ 0  / [0.0, 4.0] */
   result = [ninf_na2 div: z_b2];
   check_result_interval(@"(−∞, -2.0] a2 ≤ 0  / [0.0, 4.0]", result, -INFINITY, -0.5);
   /* (−∞, -2.0] a2 ≤ 0  / (−∞, 0.0] */
   result = [ninf_na2 div: ninf_z];
   check_result_interval(@"(−∞, -2.0] a2 ≤ 0  / (−∞, 0.0]", result, 0.0, +INFINITY);
   /* (−∞, -2.0] a2 ≤ 0  / [0.0, +∞) */
   result = [ninf_na2 div: z_pinf];
   check_result_interval(@"(−∞, -2.0] a2 ≤ 0  / [0.0, +∞)", result, -INFINITY, 0.0);
   /* (−∞, -2.0] a2 ≤ 0  /  (−∞, +∞) */
   result = [ninf_na2 div: ninf_pinf];
   check_result_interval(@"(−∞, -2.0] a2 ≤ 0  /  (−∞, +∞)", result, -INFINITY, +INFINITY);
   
   /* (−∞, 2.0] a2 ≥ 0  / [0.0, 0.0] */
   result = [ninf_pa2 div: z_z];
   check_result_interval(@"(−∞, 2.0] a2 ≥ 0  / [0.0, 0.0]", result,-INFINITY, INFINITY);
   /* (−∞, 2.0] a2 ≥ 0  / [-8.0, 0.0] */
   result = [ninf_pa2 div: b1_z];
   check_result_interval(@"(−∞, 2.0] a2 ≥ 0  / [-8.0, 0.0]", result,-INFINITY, INFINITY);
   /* (−∞, 2.0] a2 ≥ 0  / [0.0, 4.0] */
   result = [ninf_pa2 div: z_b2];
   check_result_interval(@"(−∞, 2.0] a2 ≥ 0  / [0.0, 4.0]", result, -INFINITY, INFINITY);
   /* (−∞, 2.0] a2 ≥ 0  / (−∞, 0.0] */
   result = [ninf_pa2 div: ninf_z];
   check_result_interval(@"(−∞, 2.0] a2 ≥ 0  / (−∞, 0.0]", result, -INFINITY, INFINITY);
   /* (−∞, 2.0] a2 ≥ 0  / [0.0, +∞) */
   result = [ninf_pa2 div: z_pinf];
   check_result_interval(@"(−∞, 2.0] a2 ≥ 0  / [0.0, +∞)", result, -INFINITY, INFINITY);
   /* (−∞, 2.0] a2 ≥ 0  /  (−∞, +∞) */
   result = [ninf_pa2 div: ninf_pinf];
   check_result_interval(@"(−∞, 2.0] a2 ≥ 0  /  (−∞, +∞)", result, -INFINITY, +INFINITY);
   
   /* [-2.0, +∞), a1 ≤ 0  / [0.0, 0.0] */
   result = [na1_pinf div: z_z];
   check_result_interval(@"[-2.0, +∞), a1 ≤ 0  / [0.0, 0.0]", result,-INFINITY, INFINITY);
   /* [-2.0, +∞), a1 ≤ 0  / [-8.0, 0.0] */
   result = [na1_pinf div: b1_z];
   check_result_interval(@"[-2.0, +∞), a1 ≤ 0  / [-8.0, 0.0]", result,-INFINITY, INFINITY);
   /* [-2.0, +∞), a1 ≤ 0  / [0.0, 4.0] */
   result = [na1_pinf div: z_b2];
   check_result_interval(@"[-2.0, +∞), a1 ≤ 0  / [0.0, 4.0]", result, -INFINITY, INFINITY);
   /* [-2.0, +∞), a1 ≤ 0  / (−∞, 0.0] */
   result = [na1_pinf div: ninf_z];
   check_result_interval(@"[-2.0, +∞), a1 ≤ 0  / (−∞, 0.0]", result, -INFINITY, INFINITY);
   /* [-2.0, +∞), a1 ≤ 0  / [0.0, +∞) */
   result = [na1_pinf div: z_pinf];
   check_result_interval(@"[-2.0, +∞), a1 ≤ 0  / [0.0, +∞)", result, -INFINITY, INFINITY);
   /* [-2.0, +∞), a1 ≤ 0  /  (−∞, +∞) */
   result = [na1_pinf div: ninf_pinf];
   check_result_interval(@"[-2.0, +∞), a1 ≤ 0  /  (−∞, +∞)", result, -INFINITY, +INFINITY);
   
   /* [2.0, +∞), a1 ≥ 0  / [0.0, 0.0] */
   result = [pa1_pinf div: z_z];
   check_result_interval(@"[2.0, +∞), a1 ≥ 0  / [0.0, 0.0]", result, -INFINITY, +INFINITY);
   /* [2.0, +∞), a1 ≥ 0  / [-8.0, 0.0] */
   result = [pa1_pinf div: b1_z];
   check_result_interval(@"[2.0, +∞), a1 ≥ 0  / [-8.0, 0.0]", result,-INFINITY,-0.25);
   /* [2.0, +∞), a1 ≥ 0  / [0.0, 4.0] */
   result = [pa1_pinf div: z_b2];
   check_result_interval(@"[2.0, +∞), a1 ≥ 0  / [0.0, 4.0]", result,0.5,+INFINITY);
   /* [2.0, +∞), a1 ≥ 0  / (−∞, 0.0] */
   result = [pa1_pinf div: ninf_z];
   check_result_interval(@"[2.0, +∞), a1 ≥ 0  / (−∞, 0.0]", result,-INFINITY,0.0);
   /* [2.0, +∞), a1 ≥ 0  / [0.0, +∞) */
   result = [pa1_pinf div: z_pinf];
   check_result_interval(@"[2.0, +∞), a1 ≥ 0  / [0.0, +∞)", result,0.0, +INFINITY);
   /* [2.0, +∞), a1 ≥ 0  /  (−∞, +∞) */
   result = [pa1_pinf div: ninf_pinf];
   check_result_interval(@"[2.0, +∞), a1 ≥ 0 /  (−∞, +∞)", result, -INFINITY, +INFINITY);
   
   /* (−∞, +∞)  / [0.0, 0.0] */
   result = [ninf_pinf div: z_z];
   check_result_interval(@"(−∞, +∞)  / [0.0, 0.0]", result,-INFINITY, INFINITY);
   /* (−∞, +∞)  / [-8.0, 0.0] */
   result = [ninf_pinf div: b1_z];
   check_result_interval(@"(−∞, +∞)  / [-8.0, 0.0]", result,-INFINITY, INFINITY);
   /* (−∞, +∞)  / [0.0, 4.0] */
   result = [ninf_pinf div: z_b2];
   check_result_interval(@"(−∞, +∞)  / [0.0, 4.0]", result, -INFINITY, INFINITY);
   /* (−∞, +∞)  / (−∞, 0.0] */
   result = [ninf_pinf div: ninf_z];
   check_result_interval(@"(−∞, +∞)  / (−∞, 0.0]", result, -INFINITY, INFINITY);
   /* (−∞, +∞)  / [0.0, +∞) */
   result = [ninf_pinf div: z_pinf];
   check_result_interval(@"(−∞, +∞)  / [0.0, +∞)", result, -INFINITY, INFINITY);
   /* (−∞, +∞)  /  (−∞, +∞) */
   result = [ninf_pinf div: ninf_pinf];
   check_result_interval(@"(−∞, +∞)  /  (−∞, +∞)", result, -INFINITY, +INFINITY);

   
   [a1_na2 release];
   [a1_a2_0 release];
   [pa1_a2 release];
   [ninf_na2 release];
   [ninf_pa2 release];
   [na1_pinf release];
   [pa1_pinf release];
   [z_z release];
   [b1_z release];
   [z_b2 release];
   [ninf_z release];
   [z_pinf release];
   [ninf_pinf release];
   [result release];
}

int main(int argc, const char * argv[]) {
   
   check_addition();
   check_subtraction();
   check_multiplication();
   check_division();
   
   check_addition_interval();
   check_subtraction_interval();
   check_multiplication_interval();
   check_division_interval();

   return 0;
}
