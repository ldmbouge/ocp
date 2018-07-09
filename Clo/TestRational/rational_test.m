//
//  rational_test.m
//  Clo
//
//  Created by Remy Garcia on 24/05/2018.
//

#import <Foundation/Foundation.h>
#import <ORFoundation/ORFoundation.h>
#include "gmp.h"
#include "rationalUtilities.h"

void check_result(NSString* s, ORRational r, ORDouble x_){
   ORRational x;
   rational_init(x);
   rational_set_d(x, x_);
   
   if((rational_eq(r,x) && r->type == x->type) || (r->type == x->type && r->type == 3))
      NSLog(@"[TRUE]        %@      %f == %f      %i == %i", s, rational_get_d(r), rational_get_d(x), r->type, x->type);
   else if(!rational_eq(r, x) && r->type == x->type)
      NSLog(@"[FALSE][R]    %@      %f != %f      %i == %i", s, rational_get_d(r), rational_get_d(x), r->type, x->type);
   else if(rational_eq(r, x) && r->type != x->type)
      NSLog(@"[FALSE][T]    %@      %f != %f      %i == %i", s, rational_get_d(r), rational_get_d(x), r->type, x->type);
   else
      NSLog(@"[FALSE][R][T] %@      %f != %f      %i == %i", s, rational_get_d(r), rational_get_d(x), r->type, x->type);
   
   rational_clear(x);
}

void check_result_interval(NSString* s, ri r, ORDouble x_i, ORDouble x_s){
   ri x;
   ri_init(x);
   ri_set_d(x, x_i, x_s);
   
   if((ri_eq(r,x) && r->inf->type == x->inf->type && r->sup->type == x->sup->type) ||
      (r->inf->type == x->inf->type && r->inf->type == 3 && rational_eq(r->sup, x->sup) && r->sup->type == x->sup->type) ||
      (r->sup->type == x->sup->type && r->sup->type == 3 && rational_eq(r->inf, x->inf) && r->inf->type == x->inf->type) ||
      (r->inf->type == x->inf->type && r->inf->type == 3 && r->sup->type == x->sup->type && r->sup->type == 3))
      //NSLog(@"[TRUE]        %@ [%f,%f] == [%f,%f]      [%i,%i] == [%i,%i]", s, rational_get_d(r->inf), rational_get_d(r->sup), rational_get_d(x->inf), rational_get_d(x->sup), r->inf->type, r->sup->type, x->inf->type, x->sup->type);
      NSLog(@"");
   else if(!ri_eq(r, x) &&
           r->inf->type == x->inf->type &&
           r->sup->type == x->sup->type)
      NSLog(@"[FALSE][R]    %@ [%f,%f] == [%f,%f]      [%i,%i] == [%i,%i]", s, rational_get_d(r->inf), rational_get_d(r->sup), rational_get_d(x->inf), rational_get_d(x->sup), r->inf->type, r->sup->type, x->inf->type, x->sup->type);
   else if(ri_eq(r, x) &&
           r->inf->type != x->inf->type &&
           r->sup->type != x->sup->type)
      NSLog(@"[FALSE][T]    %@ [%f,%f] == [%f,%f]      [%i,%i] == [%i,%i]", s, rational_get_d(r->inf), rational_get_d(r->sup), rational_get_d(x->inf), rational_get_d(x->sup), r->inf->type, r->sup->type, x->inf->type, x->sup->type);
   else
      NSLog(@"[FALSE][R][T] %@ [%f,%f] == [%f,%f]      [%i,%i] == [%i,%i]", s, rational_get_d(r->inf), rational_get_d(r->sup), rational_get_d(x->inf), rational_get_d(x->sup), r->inf->type, r->sup->type, x->inf->type, x->sup->type);
   
   ri_clear(x);
}

void check_addition(){
   NSLog(@"ADDITION");
   ORRational neg_inf, neg_v, neg_v2, zero, pos_v, pos_v2, pos_inf, nan;
   ORRational result;
   rational_init(neg_inf);
   rational_init(neg_v);
   rational_init(neg_v2);
   rational_init(zero);
   rational_init(pos_v);
   rational_init(pos_v2);
   rational_init(pos_inf);
   rational_init(nan);
   rational_init(result);
   
   rational_set_d(neg_inf, -INFINITY);
   rational_set_d(neg_v, -123.4);
   rational_set_d(neg_v2, -0.21);
   rational_set_d(zero, 0.0);
   rational_set_d(pos_v, 43.23);
   rational_set_d(pos_v2, 185.6);
   rational_set_d(pos_inf, +INFINITY);
   rational_set_d(nan, NAN);
   
   /* Addition */
   /* -INF + -INF */
   rational_addition(result, neg_inf, neg_inf);
   check_result(@"-INF + -INF", result, -INFINITY);
   /* -INF + NR */
   rational_addition(result, neg_inf, neg_v);
   check_result(@"-INF + NR", result, -INFINITY);
   /* -INF + NR2 */
   rational_addition(result, neg_inf, neg_v2);
   check_result(@"-INF + NR2", result, -INFINITY);
   /* -INF + 0 */
   rational_addition(result, neg_inf, zero);
   check_result(@"-INF + 0", result, -INFINITY);
   /* -INF + PR */
   rational_addition(result, neg_inf, pos_v);
   check_result(@"-INF + PR", result, -INFINITY);
   /* -INF + PR2 */
   rational_addition(result, neg_inf, pos_v2);
   check_result(@"-INF + PR2", result, -INFINITY);
   /* -INF + +INF */
   rational_addition(result, neg_inf, pos_inf);
   check_result(@"-INF + +INF", result, NAN);
   /* NR + NR */
   rational_addition(result, neg_v, neg_v);
   check_result(@"NR + NR", result, -246.8);
   /* NR + NR2 */
   rational_addition(result, neg_v, neg_v2);
   check_result(@"NR + NR2", result, -123.61);
   /* NR2 + NR2 */
   rational_addition(result, neg_v2, neg_v2);
   check_result(@"NR2 + NR", result, -0.42);
   /* NR + 0 */
   rational_addition(result, neg_v, zero);
   check_result(@"NR + 0", result, -123.4);
   /* NR2 + 0 */
   rational_addition(result, neg_v2, zero);
   check_result(@"NR2 + 0", result, -0.21);
   /* NR + PR */
   rational_addition(result, neg_v, pos_v);
   check_result(@"NR + PR", result, -80.17);
   /* NR + PR2 */
   rational_addition(result, neg_v, pos_v2);
   check_result(@"NR + PR2", result, 62.2);
   /* NR2 + PR */
   rational_addition(result, neg_v2, pos_v);
   check_result(@"NR2 + PR", result, 43.02);
   /* NR2 + PR2 */
   rational_addition(result, neg_v2, pos_v2);
   check_result(@"NR2 + PR2", result, 185.39);
   /* NR + +INF */
   rational_addition(result, neg_v, pos_inf);
   check_result(@"NR + +INF", result, +INFINITY);
   /* NR2 + +INF */
   rational_addition(result, neg_v2, pos_inf);
   check_result(@"NR2 + +INF", result, +INFINITY);
   /* 0 + 0 */
   rational_addition(result, zero, zero);
   check_result(@"0 + 0", result, 0.0);
   /* 0 + PR */
   rational_addition(result, zero, pos_v);
   check_result(@"0 + PR", result, 43.23);
   /* 0 + PR2 */
   rational_addition(result, zero, pos_v2);
   check_result(@"0 + PR2", result, 185.6);
   /* 0 + +INF */
   rational_addition(result, zero, pos_inf);
   check_result(@"0 + +INF", result, +INFINITY);
   /* PR + PR */
   rational_addition(result, pos_v, pos_v);
   check_result(@"PR + PR", result, 86.46);
   /* PR + PR2 */
   rational_addition(result, pos_v, pos_v2);
   check_result(@"PR + PR2", result, 228.83);
   /* PR2 + PR2 */
   rational_addition(result, pos_v2, pos_v2);
   check_result(@"PR2 + PR2", result, 371.2);
   /* PR + +INF */
   rational_addition(result, pos_v, pos_inf);
   check_result(@"PR + +INF", result, +INFINITY);
   /* PR2 + +INF */
   rational_addition(result, pos_v2, pos_inf);
   check_result(@"PR2 + +INF", result, +INFINITY);
   /* +INF + +INF */
   rational_addition(result, pos_inf, pos_inf);
   check_result(@"+INF + +INF", result, +INFINITY);
   
   rational_clear(neg_inf);
   rational_clear(neg_v);
   rational_clear(neg_v2);
   rational_clear(zero);
   rational_clear(pos_v);
   rational_clear(pos_v2);
   rational_clear(pos_inf);
   rational_clear(nan);
}

void check_subtraction(){
   NSLog(@"SUBTRACTION");
   ORRational neg_inf, neg_v, neg_v2, zero, pos_v, pos_v2, pos_inf, nan;
   ORRational result;
   rational_init(neg_inf);
   rational_init(neg_v);
   rational_init(neg_v2);
   rational_init(zero);
   rational_init(pos_v);
   rational_init(pos_v2);
   rational_init(pos_inf);
   rational_init(nan);
   rational_init(result);
   
   rational_set_d(neg_inf, -INFINITY);
   rational_set_d(neg_v, -123.4);
   rational_set_d(neg_v2, -0.21);
   rational_set_d(zero, 0.0);
   rational_set_d(pos_v, 43.23);
   rational_set_d(pos_v2, 185.6);
   rational_set_d(pos_inf, +INFINITY);
   rational_set_d(nan, NAN);
   
   /* -INF - -INF */
   rational_subtraction(result, neg_inf, neg_inf);
   check_result(@"-INF - -INF", result, NAN);
   /* -INF - NR */
   rational_subtraction(result, neg_inf, neg_v);
   check_result(@"-INF - NR", result, -INFINITY);
   /* -INF - NR2 */
   rational_subtraction(result, neg_inf, neg_v2);
   check_result(@"-INF - NR2", result, -INFINITY);
   /* -INF - 0 */
   rational_subtraction(result, neg_inf, zero);
   check_result(@"-INF - 0", result, -INFINITY);
   /* -INF - PR */
   rational_subtraction(result, neg_inf, pos_v);
   check_result(@"-INF - PR", result, -INFINITY);
   /* -INF - PR2 */
   rational_subtraction(result, neg_inf, pos_v2);
   check_result(@"-INF - PR2", result, -INFINITY);
   /* -INF - +INF */
   rational_subtraction(result, neg_inf, pos_inf);
   check_result(@"-INF - +INF", result, -INFINITY);
   /* NR - -INF */
   rational_subtraction(result, neg_v, neg_inf);
   check_result(@"NR - -INF", result, +INFINITY);
   /* NR2 - -INF */
   rational_subtraction(result, neg_v2, neg_inf);
   check_result(@"NR2 - -INF", result, +INFINITY);
   /* NR - NR */
   rational_subtraction(result, neg_v, neg_v);
   check_result(@"NR - NR", result, 0.0);
   /* NR2 - NR */
   rational_subtraction(result, neg_v2, neg_v);
   check_result(@"NR2 - NR", result, 123.19);
   /* NR - NR2 */
   rational_subtraction(result, neg_v, neg_v2);
   check_result(@"NR - NR2", result, -123.19);
   /* NR2 - NR2 */
   rational_subtraction(result, neg_v2, neg_v2);
   check_result(@"NR2 - NR2", result, 0.0);
   /* NR - 0 */
   rational_subtraction(result, neg_v, zero);
   check_result(@"NR - 0", result, -123.4);
   /* NR2 - 0 */
   rational_subtraction(result, neg_v2, zero);
   check_result(@"NR2 - 0", result, -0.21);
   /* NR - PR */
   rational_subtraction(result, neg_v, pos_v);
   check_result(@"NR - PR", result, -166.63);
   /* NR2 - PR */
   rational_subtraction(result, neg_v2, pos_v);
   check_result(@"NR2 - PR", result, -43.44);
   /* NR - PR2 */
   rational_subtraction(result, neg_v, pos_v2);
   check_result(@"NR - PR2", result, -309.0);
   /* NR2 - PR2 */
   rational_subtraction(result, neg_v2, pos_v2);
   check_result(@"NR2 - PR2", result, -185.81);
   /* NR - +INF */
   rational_subtraction(result, neg_v, pos_inf);
   check_result(@"NR - +INF", result, -INFINITY);
   /* NR2 - +INF */
   rational_subtraction(result, neg_v2, pos_inf);
   check_result(@"NR2 - +INF", result, -INFINITY);
   /* 0 - -INF */
   rational_subtraction(result, zero, neg_inf);
   check_result(@"0 - -INF", result, +INFINITY);
   /* 0 - NR */
   rational_subtraction(result, zero, neg_v);
   check_result(@"0 - NR", result, 123.4);
   /* 0 - NR2 */
   rational_subtraction(result, zero, neg_v2);
   check_result(@"0 - NR2", result, 0.21);
   /* 0 - 0 */
   rational_subtraction(result, zero, zero);
   check_result(@"0 - 0", result, 0.0);
   /* 0 - PR */
   rational_subtraction(result, zero, pos_v);
   check_result(@"0 - PR", result, -43.23);
   /* 0 - PR2 */
   rational_subtraction(result, zero, pos_v2);
   check_result(@"0 - PR2", result, -185.6);
   /* 0 - +INF */
   rational_subtraction(result, zero, pos_inf);
   check_result(@"0 - +INF", result, -INFINITY);
   /* PR - -INF */
   rational_subtraction(result, pos_v, neg_inf);
   check_result(@"PR - -INF", result, +INFINITY);
   /* PR2 - -INF */
   rational_subtraction(result, pos_v2, neg_inf);
   check_result(@"PR2 - -INF", result, +INFINITY);
   /* PR - NR */
   rational_subtraction(result, pos_v, neg_v);
   check_result(@"PR - NR", result, 166.63);
   /* PR2 - NR */
   rational_subtraction(result, pos_v2, neg_v);
   check_result(@"PR2 - NR", result,  309.0);
   /* PR - NR2 */
   rational_subtraction(result, pos_v, neg_v2);
   check_result(@"PR - NR2", result, 43.44);
   /* PR2 - NR2 */
   rational_subtraction(result, pos_v2, neg_v2);
   check_result(@"PR2 - NR2", result, 185.81);
   /* PR - 0 */
   rational_subtraction(result, pos_v, zero);
   check_result(@"PR - 0", result, 43.23);
   /* PR2 - 0 */
   rational_subtraction(result, pos_v2, zero);
   check_result(@"PR2 - 0", result, 185.6);
   /* PR - PR */
   rational_subtraction(result, pos_v, pos_v);
   check_result(@"PR - PR", result, 0.0);
   /* PR2 - PR */
   rational_subtraction(result, pos_v2, pos_v);
   check_result(@"PR2 - PR", result, 142.37);
   /* PR - PR2 */
   rational_subtraction(result, pos_v, pos_v2);
   check_result(@"PR - PR2", result, -142.37);
   /* PR2 - PR2 */
   rational_subtraction(result, pos_v2, pos_v2);
   check_result(@"PR2 - PR2", result, 0.0);
   /* PR - +INF */
   rational_subtraction(result, pos_v, pos_inf);
   check_result(@"PR - +INF", result, -INFINITY);
   /* PR2 - +INF */
   rational_subtraction(result, pos_v2, pos_inf);
   check_result(@"PR2 - +INF", result, -INFINITY);
   /* +INF - -INF */
   rational_subtraction(result, pos_inf, neg_inf);
   check_result(@"+INF - -INF", result, +INFINITY);
   /* +INF - NR */
   rational_subtraction(result, pos_inf, neg_v);
   check_result(@"+INF - NR", result, +INFINITY);
   /* +INF - NR2 */
   rational_subtraction(result, pos_inf, neg_v2);
   check_result(@"+INF - NR2", result, +INFINITY);
   /* +INF - 0 */
   rational_subtraction(result, pos_inf, zero);
   check_result(@"+INF - 0", result, +INFINITY);
   /* +INF - PR */
   rational_subtraction(result, pos_inf, pos_v);
   check_result(@"+INF - PR", result, +INFINITY);
   /* +INF - PR2 */
   rational_subtraction(result, pos_inf, pos_v2);
   check_result(@"+INF - PR2", result, +INFINITY);
   /* +INF - +INF */
   rational_subtraction(result, pos_inf, pos_inf);
   check_result(@"+INF - +INF", result, NAN);
   
   rational_clear(neg_inf);
   rational_clear(neg_v);
   rational_clear(neg_v2);
   rational_clear(zero);
   rational_clear(pos_v);
   rational_clear(pos_v2);
   rational_clear(pos_inf);
   rational_clear(nan);
}

void check_multiplication(){
   NSLog(@"MULTIPLICATION");
   ORRational neg_inf, neg_v, neg_v2, zero, pos_v, pos_v2, pos_inf, nan;
   ORRational result;
   rational_init(neg_inf);
   rational_init(neg_v);
   rational_init(neg_v2);
   rational_init(zero);
   rational_init(pos_v);
   rational_init(pos_v2);
   rational_init(pos_inf);
   rational_init(nan);
   rational_init(result);
   
   rational_set_d(neg_inf, -INFINITY);
   rational_set_d(neg_v, -123.4);
   rational_set_d(neg_v2, -0.21);
   rational_set_d(zero, 0.0);
   rational_set_d(pos_v, 43.23);
   rational_set_d(pos_v2, 185.6);
   rational_set_d(pos_inf, +INFINITY);
   rational_set_d(nan, NAN);
   
   /* Addition */
   /* -INF * -INF */
   rational_multiplication(result, neg_inf, neg_inf);
   check_result(@"-INF * -INF", result, +INFINITY);
   /* -INF * NR */
   rational_multiplication(result, neg_inf, neg_v);
   check_result(@"-INF * NR", result, +INFINITY);
   /* -INF * NR2 */
   rational_multiplication(result, neg_inf, neg_v2);
   check_result(@"-INF * NR2", result, +INFINITY);
   /* -INF * 0 */
   rational_multiplication(result, neg_inf, zero);
   check_result(@"-INF * 0", result, NAN);
   /* -INF * PR */
   rational_multiplication(result, neg_inf, pos_v);
   check_result(@"-INF * PR", result, -INFINITY);
   /* -INF * PR2 */
   rational_multiplication(result, neg_inf, pos_v2);
   check_result(@"-INF * PR2", result, -INFINITY);
   /* -INF * +INF */
   rational_multiplication(result, neg_inf, pos_inf);
   check_result(@"-INF * +INF", result, -INFINITY);
   /* NR * NR */
   rational_multiplication(result, neg_v, neg_v);
   check_result(@"NR * NR", result, 15227.56);
   /* NR2 * NR */
   rational_multiplication(result, neg_v2, neg_v);
   check_result(@"NR2 * NR", result, 25.914);
   /* NR2 * NR2 */
   rational_multiplication(result, neg_v2, neg_v2);
   check_result(@"NR2 * NR2", result, 0.0441);
   /* NR * 0 */
   rational_multiplication(result, neg_v, zero);
   check_result(@"NR * 0", result, 0.0);
   /* NR2 * 0 */
   rational_multiplication(result, neg_v2, zero);
   check_result(@"NR2 * 0", result, 0.0);
   /* NR * PR */
   rational_multiplication(result, neg_v, pos_v);
   check_result(@"NR * PR", result, -5334.582);
   /* NR2 * PR */
   rational_multiplication(result, neg_v2, pos_v);
   check_result(@"NR2 * PR", result, -9.0783);
   /* NR * PR2 */
   rational_multiplication(result, neg_v, pos_v2);
   check_result(@"NR * PR2", result, -22903.04);
   /* NR2 * PR2 */
   rational_multiplication(result, neg_v2, pos_v2);
   check_result(@"NR2 * PR2", result, -38.976);
   /* NR * +INF */
   rational_multiplication(result, neg_v, pos_inf);
   check_result(@"NR * +INF", result, -INFINITY);
   /* NR2 * +INF */
   rational_multiplication(result, neg_v2, pos_inf);
   check_result(@"NR2 * +INF", result, -INFINITY);
   /* 0 * 0 */
   rational_multiplication(result, zero, zero);
   check_result(@"0 * 0", result, 0.0);
   /* 0 * PR */
   rational_multiplication(result, zero, pos_v);
   check_result(@"0 * PR", result, 0.0);
   /* 0 * PR2 */
   rational_multiplication(result, zero, pos_v2);
   check_result(@"0 * PR2", result, 0.0);
   /* 0 * +INF */
   rational_multiplication(result, zero, pos_inf);
   check_result(@"0 * +INF", result, NAN);
   /* PR * PR */
   rational_multiplication(result, pos_v, pos_v);
   check_result(@"PR * PR", result, 1868.8329);
   /* PR2 * PR */
   rational_multiplication(result, pos_v2, pos_v);
   check_result(@"PR2 * PR", result, 8023.488);
   /* PR2 * PR2 */
   rational_multiplication(result, pos_v2, pos_v2);
   check_result(@"PR2 * PR2", result, 34447.36);
   /* PR * +INF */
   rational_multiplication(result, pos_v, pos_inf);
   check_result(@"PR * +INF", result, +INFINITY);
   /* PR2 * +INF */
   rational_multiplication(result, pos_v2, pos_inf);
   check_result(@"PR2 * +INF", result, +INFINITY);
   /* +INF * +INF */
   rational_multiplication(result, pos_inf, pos_inf);
   check_result(@"+INF * +INF", result, +INFINITY);
   
   
   rational_clear(neg_inf);
   rational_clear(neg_v);
   rational_clear(neg_v2);
   rational_clear(zero);
   rational_clear(pos_v);
   rational_clear(pos_v2);
   rational_clear(pos_inf);
   rational_clear(nan);
}

void check_division(){
   NSLog(@"DIVISION");
   ORRational neg_inf, neg_v, neg_v2, zero, pos_v, pos_v2, pos_inf, nan;
   ORRational result;
   rational_init(neg_inf);
   rational_init(neg_v);
   rational_init(neg_v2);
   rational_init(zero);
   rational_init(pos_v);
   rational_init(pos_v2);
   rational_init(pos_inf);
   rational_init(nan);
   rational_init(result);
   
   rational_set_d(neg_inf, -INFINITY);
   rational_set_d(neg_v, -123.4);
   rational_set_d(neg_v2, -0.21);
   rational_set_d(zero, 0.0);
   rational_set_d(pos_v, 43.23);
   rational_set_d(pos_v2, 185.6);
   rational_set_d(pos_inf, +INFINITY);
   rational_set_d(nan, NAN);
   
   /* -INF / -INF */
   rational_division(result, neg_inf, neg_inf);
   check_result(@"-INF / -INF", result, NAN);
   /* -INF / NR */
   rational_division(result, neg_inf, neg_v);
   check_result(@"-INF / NR", result, +INFINITY);
   /* -INF / NR2 */
   rational_division(result, neg_inf, neg_v2);
   check_result(@"-INF / NR2", result, +INFINITY);
   /* -INF / 0 */
   rational_division(result, neg_inf, zero);
   check_result(@"-INF / 0", result, NAN);
   /* -INF / PR */
   rational_division(result, neg_inf, pos_v);
   check_result(@"-INF / PR", result, -INFINITY);
   /* -INF / PR2 */
   rational_division(result, neg_inf, pos_v2);
   check_result(@"-INF / PR2", result, -INFINITY);
   /* -INF / +INF */
   rational_division(result, neg_inf, pos_inf);
   check_result(@"-INF / +INF", result, NAN);
   /* NR / -INF */
   rational_division(result, neg_v, neg_inf);
   check_result(@"NR / -INF", result, 0.0);
   /* NR2 / -INF */
   rational_division(result, neg_v2, neg_inf);
   check_result(@"NR2 / -INF", result, 0.0);
   /* NR / NR */
   rational_division(result, neg_v, neg_v);
   check_result(@"NR / NR", result, 1.0);
   /* NR2 / NR */
   rational_division(result, neg_v2, neg_v);
   check_result(@"NR2 / NR", result, 0.00170178282);
   /* NR / NR2 */
   rational_division(result, neg_v, neg_v2);
   check_result(@"NR / NR2", result, 587.619047619);
   /* NR2 / NR2 */
   rational_division(result, neg_v2, neg_v2);
   check_result(@"NR2 / NR2", result, 1.0);
   /* NR / 0 */
   rational_division(result, neg_v, zero);
   check_result(@"NR / 0", result, NAN);
   /* NR2 / 0 */
   rational_division(result, neg_v2, zero);
   check_result(@"NR2 / 0", result, NAN);
   /* NR / PR */
   rational_division(result, neg_v, pos_v);
   check_result(@"NR / PR", result, -2.8544991904);
   /* NR2 / PR */
   rational_division(result, neg_v2, pos_v);
   check_result(@"NR2 / PR", result, -0.004857737682);
   /* NR / PR2 */
   rational_division(result, neg_v, pos_v2);
   check_result(@"NR / PR2", result, -0.6648706897);
   /* NR2 / PR2 */
   rational_division(result, neg_v2, pos_v2);
   check_result(@"NR2 / PR2", result, -0.001131465517);
   /* NR / +INF */
   rational_division(result, neg_v, pos_inf);
   check_result(@"NR / +INF", result, 0.0);
   /* NR2 / +INF */
   rational_division(result, neg_v2, pos_inf);
   check_result(@"NR2 / +INF", result, 0.0);
   /* 0 / -INF */
   rational_division(result, zero, neg_inf);
   check_result(@"0 / -INF", result, 0.0);
   /* 0 / NR */
   rational_division(result, zero, neg_v);
   check_result(@"0 / NR", result, 0.0);
   /* 0 / NR2 */
   rational_division(result, zero, neg_v2);
   check_result(@"0 / NR2", result, 0.0);
   /* 0 / 0 */
   rational_division(result, zero, zero);
   check_result(@"0 / 0", result, NAN);
   /* 0 / PR */
   rational_division(result, zero, pos_v);
   check_result(@"0 / PR", result, 0.0);
   /* 0 / PR2 */
   rational_division(result, zero, pos_v2);
   check_result(@"0 / PR2", result, 0.0);
   /* 0 / +INF */
   rational_division(result, zero, pos_inf);
   check_result(@"0 / +INF", result, 0.0);
   /* PR / -INF */
   rational_division(result, pos_v, neg_inf);
   check_result(@"PR / -INF", result, 0.0);
   /* PR2 / -INF */
   rational_division(result, pos_v2, neg_inf);
   check_result(@"PR2 / -INF", result, 0.0);
   /* PR / NR */
   rational_division(result, pos_v, neg_v);
   check_result(@"PR / NR", result, -0.3503241491);
   /* PR2 / NR */
   rational_division(result, pos_v2, neg_v);
   check_result(@"PR2 / NR", result, -1.5040518639);
   /* PR / NR2 */
   rational_division(result, pos_v, neg_v2);
   check_result(@"PR / NR2", result, -205.8571428571);
   /* PR2 / NR2 */
   rational_division(result, pos_v2, neg_v2);
   check_result(@"PR2 / NR2", result, -883.8095238095);
   /* PR / 0 */
   rational_division(result, pos_v, zero);
   check_result(@"PR / 0", result, NAN);
   /* PR2 / 0 */
   rational_division(result, pos_v2, zero);
   check_result(@"PR2 / 0", result, NAN);
   /* PR / PR */
   rational_division(result, pos_v, pos_v);
   check_result(@"PR / PR", result, 1.0);
   /* PR2 / PR */
   rational_division(result, pos_v2, pos_v);
   check_result(@"PR2 / PR", result, 4.2933148277);
   /* PR / PR2 */
   rational_division(result, pos_v, pos_v2);
   check_result(@"PR / PR2", result, 0.2329202586);
   /* PR2 / PR2 */
   rational_division(result, pos_v2, pos_v2);
   check_result(@"PR2 / PR2", result, 1.0);
   /* PR / +INF */
   rational_division(result, pos_v, pos_inf);
   check_result(@"PR / +INF", result, 0.0);
   /* PR2 / +INF */
   rational_division(result, pos_v2, pos_inf);
   check_result(@"PR2 / +INF", result, 0.0);
   /* +INF / -INF */
   rational_division(result, pos_inf, neg_inf);
   check_result(@"+INF / -INF", result, NAN);
   /* +INF / NR */
   rational_division(result, pos_inf, neg_v);
   check_result(@"+INF / NR", result, -INFINITY);
   /* +INF / NR2 */
   rational_division(result, pos_inf, neg_v2);
   check_result(@"+INF / NR2", result, -INFINITY);
   /* +INF / 0 */
   rational_division(result, pos_inf, zero);
   check_result(@"+INF / 0", result, NAN);
   /* +INF / PR */
   rational_division(result, pos_inf, pos_v);
   check_result(@"+INF / PR", result, +INFINITY);
   /* +INF / PR2 */
   rational_division(result, pos_inf, pos_v2);
   check_result(@"+INF / PR2", result, +INFINITY);
   /* +INF / +INF */
   rational_division(result, pos_inf, pos_inf);
   check_result(@"+INF / +INF", result, NAN);
   
   
   rational_clear(neg_inf);
   rational_clear(neg_v);
   rational_clear(neg_v2);
   rational_clear(zero);
   rational_clear(pos_v);
   rational_clear(pos_v2);
   rational_clear(pos_inf);
   rational_clear(nan);
}

void check_addition_interval(){
   ri ninf_a2, a1_a2, a1_pinf, ninf_b2, b1_b2, b1_pinf, ninf_pinf;
   ri result;
   
   ri_init(ninf_a2);
   ri_init(a1_a2);
   ri_init(a1_pinf);
   ri_init(ninf_b2);
   ri_init(b1_b2);
   ri_init(b1_pinf);
   ri_init(ninf_pinf);
   ri_init(result);
   
   ri_set_d(ninf_a2, -INFINITY, -0.21);
   ri_set_d(a1_a2, -123.4, -0.21);
   ri_set_d(a1_pinf, -123.4, +INFINITY);
   ri_set_d(ninf_b2, -INFINITY, 185.6);
   ri_set_d(b1_b2, 43.23, 185.6);
   ri_set_d(b1_pinf, 43.23, +INFINITY);
   ri_set_d(ninf_pinf, -INFINITY, +INFINITY);
   
   /* (−∞, a2]  + (−∞, b2] */
   ri_add(result,ninf_a2,ninf_b2);
   check_result_interval(@"(−∞, a2]  + (−∞, b2]", result, -INFINITY, 185.39);
   /* (−∞, a2]  + [b1, b2] */
   ri_add(result,ninf_a2,b1_b2);
   check_result_interval(@"(−∞, a2]  + [b1, b2]", result, -INFINITY, 185.39);
   /* (−∞, a2]  + [b1, +∞) */
   ri_add(result,ninf_a2,b1_pinf);
   check_result_interval(@"(−∞, a2]  + [b1, +∞)", result, -INFINITY, +INFINITY);
   /* (−∞, a2]  + (−∞, +∞) */
   ri_add(result,ninf_a2,ninf_pinf);
   check_result_interval(@"(−∞, a2]  + (−∞, +∞)", result, -INFINITY, +INFINITY);

   /* [a1, a2]  + (−∞, b2] */
   ri_add(result,a1_a2,ninf_b2);
   check_result_interval(@"[a1, a2]  + (−∞, b2]", result, -INFINITY, 185.39);
   /* [a1, a2]  + [b1, b2] */
   ri_add(result,a1_a2,b1_b2);
   check_result_interval(@"[a1, a2]  + [b1, b2]", result, -80.17, 185.39);
   /* [a1, a2]  + [b1, +∞) */
   ri_add(result,a1_a2,b1_pinf);
   check_result_interval(@"[a1, a2]  + [b1, +∞)", result, -80.17, +INFINITY);
   /* [a1, a2]  + (−∞, +∞) */
   ri_add(result,a1_a2,ninf_pinf);
   check_result_interval(@"[a1, a2]  + (−∞, +∞)", result, -INFINITY, +INFINITY);
   
   /* [a1, +∞)  + (−∞, b2] */
   ri_add(result,a1_pinf,ninf_b2);
   check_result_interval(@"[a1, +∞)  + (−∞, b2]", result, -INFINITY, +INFINITY);
   /* [a1, +∞)  + [b1, b2] */
   ri_add(result,a1_pinf,b1_b2);
   check_result_interval(@"[a1, +∞)  + [b1, b2]", result, -80.17, +INFINITY);
   /* [a1, +∞)  + [b1, +∞) */
   ri_add(result,a1_pinf,b1_pinf);
   check_result_interval(@"[a1, +∞)  + [b1, +∞)", result, -80.17, +INFINITY);
   /* [a1, +∞)  + (−∞, +∞) */
   ri_add(result,a1_pinf,ninf_pinf);
   check_result_interval(@"[a1, +∞)  + (−∞, +∞)", result, -INFINITY, +INFINITY);

   /* (−∞, +∞)  + (−∞, b2] */
   ri_add(result,ninf_pinf,ninf_b2);
   check_result_interval(@"(−∞, +∞)  + (−∞, b2]", result, -INFINITY, +INFINITY);
   /* (−∞, +∞)  + [b1, b2] */
   ri_add(result,ninf_pinf,b1_b2);
   check_result_interval(@"(−∞, +∞)  + [b1, b2]", result, -INFINITY, +INFINITY);
   /* (−∞, +∞)  + [b1, +∞) */
   ri_add(result,ninf_pinf,b1_pinf);
   check_result_interval(@"(−∞, +∞)  + [b1, +∞)", result, -INFINITY, +INFINITY);
   /* (−∞, +∞)  + (−∞, +∞) */
   ri_add(result,ninf_pinf,ninf_pinf);
   check_result_interval(@"(−∞, +∞)  + (−∞, +∞)", result, -INFINITY, +INFINITY);
}

void check_subtraction_interval(){
   ri ninf_a2, a1_a2, a1_pinf, ninf_b2, b1_b2, b1_pinf, ninf_pinf;
   ri result;
   
   ri_init(ninf_a2);
   ri_init(a1_a2);
   ri_init(a1_pinf);
   ri_init(ninf_b2);
   ri_init(b1_b2);
   ri_init(b1_pinf);
   ri_init(ninf_pinf);
   ri_init(result);
   
   ri_set_d(ninf_a2, -INFINITY, -0.21);
   ri_set_d(a1_a2, -123.4, -0.21);
   ri_set_d(a1_pinf, -123.4, +INFINITY);
   ri_set_d(ninf_b2, -INFINITY, 185.6);
   ri_set_d(b1_b2, 43.23, 185.6);
   ri_set_d(b1_pinf, 43.23, +INFINITY);
   ri_set_d(ninf_pinf, -INFINITY, +INFINITY);
   
   /* (−∞, a2]  - (−∞, b2] */
   ri_sub(result,ninf_a2,ninf_b2);
   check_result_interval(@"(−∞, a2]  - (−∞, b2]", result, -INFINITY, +INFINITY);
   /* (−∞, a2]  - [b1, b2] */
   ri_sub(result,ninf_a2,b1_b2);
   check_result_interval(@"(−∞, a2]  - [b1, b2]", result, -INFINITY, -43.44);
   /* (−∞, a2]  - [b1, +∞) */
   ri_sub(result,ninf_a2,b1_pinf);
   check_result_interval(@"(−∞, a2]  - [b1, +∞)", result, -INFINITY, -43.44);
   /* (−∞, a2]  - (−∞, +∞) */
   ri_sub(result,ninf_a2,ninf_pinf);
   check_result_interval(@"(−∞, a2]  - (−∞, +∞)", result, -INFINITY, +INFINITY);
   
   /* [a1, a2]  - (−∞, b2] */
   ri_sub(result,a1_a2,ninf_b2);
   check_result_interval(@"[a1, a2]  - (−∞, b2]", result, -309.0, +INFINITY);
   /* [a1, a2]  - [b1, b2] */
   ri_sub(result,a1_a2,b1_b2);
   check_result_interval(@"[a1, a2]  - [b1, b2]", result, -309.0, -43.44);
   /* [a1, a2]  - [b1, +∞) */
   ri_sub(result,a1_a2,b1_pinf);
   check_result_interval(@"[a1, a2]  - [b1, +∞)", result, -INFINITY, -43.44);
   /* [a1, a2]  - (−∞, +∞) */
   ri_sub(result,a1_a2,ninf_pinf);
   check_result_interval(@"[a1, a2]  - (−∞, +∞)", result, -INFINITY, +INFINITY);
   
   /* [a1, +∞)  - (−∞, b2] */
   ri_sub(result,a1_pinf,ninf_b2);
   check_result_interval(@"[a1, +∞)  - (−∞, b2]", result, -309.0, +INFINITY);
   /* [a1, +∞)  - [b1, b2] */
   ri_sub(result,a1_pinf,b1_b2);
   check_result_interval(@"[a1, +∞)  - [b1, b2]", result, -309.0, +INFINITY);
   /* [a1, +∞)  - [b1, +∞) */
   ri_sub(result,a1_pinf,b1_pinf);
   check_result_interval(@"[a1, +∞)  - [b1, +∞)", result, -INFINITY, +INFINITY);
   /* [a1, +∞)  - (−∞, +∞) */
   ri_sub(result,a1_pinf,ninf_pinf);
   check_result_interval(@"[a1, +∞)  - (−∞, +∞)", result, -INFINITY, +INFINITY);
   
   /* (−∞, +∞)  - (−∞, b2] */
   ri_sub(result,ninf_pinf,ninf_b2);
   check_result_interval(@"(−∞, +∞)  - (−∞, b2]", result, -INFINITY, +INFINITY);
   /* (−∞, +∞)  - [b1, b2] */
   ri_sub(result,ninf_pinf,b1_b2);
   check_result_interval(@"(−∞, +∞)  - [b1, b2]", result, -INFINITY, +INFINITY);
   /* (−∞, +∞)  - [b1, +∞) */
   ri_sub(result,ninf_pinf,b1_pinf);
   check_result_interval(@"(−∞, +∞)  - [b1, +∞)", result, -INFINITY, +INFINITY);
   /* (−∞, +∞)  - (−∞, +∞) */
   ri_sub(result,ninf_pinf,ninf_pinf);
   check_result_interval(@"(−∞, +∞)  - (−∞, +∞)", result, -INFINITY, +INFINITY);
}

void check_multiplication_interval(){
   ri ninf_na2,ninf_pa2, a1_na2, a1_a2_0, pa1_a2, na1_pinf, pa1_pinf, ninf_nb2, ninf_pb2, b1_nb2, b1_b2_0, pb1_b2, z_z, nb1_pinf, pb1_pinf, ninf_pinf;
   ri result;
   
   ri_init(ninf_na2);
   ri_init(ninf_pa2);
   ri_init(a1_na2);
   ri_init(a1_a2_0);
   ri_init(pa1_a2);
   ri_init(na1_pinf);
   ri_init(pa1_pinf);
   ri_init(ninf_nb2);
   ri_init(ninf_pb2);
   ri_init(b1_nb2);
   ri_init(b1_b2_0);
   ri_init(pb1_b2);
   ri_init(z_z);
   ri_init(nb1_pinf);
   ri_init(pb1_pinf);
   ri_init(ninf_pinf);
   ri_init(result);
   
   ri_set_d(ninf_na2, -INFINITY, -2.0);
   ri_set_d(ninf_pa2, -INFINITY, 2.0);
   ri_set_d(a1_na2, -6.0, -2.0);
   ri_set_d(a1_a2_0, -6.0, 2.0);
   ri_set_d(pa1_a2, 6.0, 12.0);
   ri_set_d(na1_pinf, -6.0, +INFINITY);
   ri_set_d(pa1_pinf, 6.0, +INFINITY);
   ri_set_d(ninf_nb2, -INFINITY, -4.0);
   ri_set_d(ninf_pb2, -INFINITY, 4.0);
   ri_set_d(b1_nb2, -8.0, -4.0);
   ri_set_d(b1_b2_0, -8.0, 4.0);
   ri_set_d(pb1_b2, 8.0, 16.0);
   ri_set_d(z_z, 0.0, 0.0);
   ri_set_d(nb1_pinf, -8.0, +INFINITY);
   ri_set_d(pb1_pinf, 8.0, +INFINITY);
   ri_set_d(ninf_pinf, -INFINITY, +INFINITY);
   
   /* [-6.0, -2.0], a2 ≤ 0  * [-8.0, -4.0] b2 ≤ 0 */
   ri_mul(result,a1_na2,b1_nb2);
   check_result_interval(@"[-6.0, -2.0], a2 ≤ 0  * [-8.0, -4.0] b2 ≤ 0", result, 8.0, 48.0);
   /* [-6.0, -2.0], a2 ≤ 0  * [-8.0, 4.0] b1 < 0 < b2 */
   ri_mul(result,a1_na2,b1_b2_0);
   check_result_interval(@"[-6.0, -2.0], a2 ≤ 0  * [-8.0, 4.0] b1 < 0 < b2", result, -24.0, 48.0);
   /* [-6.0, -2.0], a2 ≤ 0  * [8.0, 16.0] b1 ≥ 0 */
   ri_mul(result,a1_na2,pb1_b2);
   check_result_interval(@"[-6.0, -2.0], a2 ≤ 0  * [8.0, 16.0] b1 ≥ 0", result, -96.0, -16.0);
   /* [-6.0, -2.0], a2 ≤ 0  * [0, 0] */
   ri_mul(result,a1_na2,z_z);
   check_result_interval(@"[-6.0, -2.0], a2 ≤ 0  * [0, 0]", result, 0.0, 0.0);
   /* [-6.0, -2.0], a2 ≤ 0  * (−∞, -4.0] b2 ≤ 0 */
   ri_mul(result,a1_na2,ninf_nb2);
   check_result_interval(@"[-6.0, -2.0], a2 ≤ 0  * (−∞, -4.0] b2 ≤ 0", result, 8.0, +INFINITY);
   /* [-6.0, -2.0], a2 ≤ 0  * (−∞, 4.0] b2 ≥ 0 */
   ri_mul(result,a1_na2,ninf_pb2);
   check_result_interval(@"[-6.0, -2.0], a2 ≤ 0  * (−∞, 4.0] b2 ≥ 0", result, -24.0, +INFINITY);
   /* [-6.0, -2.0], a2 ≤ 0  * [-8.0, +∞) b1 ≤ 0 */
   ri_mul(result,a1_na2,nb1_pinf);
   check_result_interval(@"[-6.0, -2.0], a2 ≤ 0  * [-8.0, +∞) b1 ≤ 0", result, -INFINITY, 48.0);
   /* [-6.0, -2.0], a2 ≤ 0  * [8.0, +∞) b1 ≥ 0 */
   ri_mul(result,a1_na2,pb1_pinf);
   check_result_interval(@"[-6.0, -2.0], a2 ≤ 0  * [8.0, +∞) b1 ≥ 0", result, -INFINITY, -16.0);
   /* [-6.0, -2.0], a2 ≤ 0  *  (−∞, +∞) */
   ri_mul(result,a1_na2,ninf_pinf);
   check_result_interval(@"[-6.0, -2.0], a2 ≤ 0  *  (−∞, +∞)", result, -INFINITY, +INFINITY);
   
   /* */
   
   /* [-6.0, 2.0], a1 ≤ 0 ≤ a2  * [-8.0, -4.0] b2 ≤ 0 */
   ri_mul(result,a1_a2_0,b1_nb2);
   check_result_interval(@"[-6.0, 2.0], a1 ≤ 0 ≤ a2  * [-8.0, -4.0] b2 ≤ 0", result, -16.0, 48.0);
   /* [-6.0, 2.0], a1 ≤ 0 ≤ a2  * [-8.0, 4.0] b1 < 0 < b2 */
   ri_mul(result,a1_a2_0,b1_b2_0);
   check_result_interval(@"[-6.0, 2.0], a1 ≤ 0 ≤ a2  * [-8.0, 4.0] b1 < 0 < b2", result, -24.0, 48.0);
   /* [-6.0, 2.0], a1 ≤ 0 ≤ a2  * [8.0, 16.0] b1 ≥ 0 */
   ri_mul(result,a1_a2_0,pb1_b2);
   check_result_interval(@"[-6.0, 2.0], a1 ≤ 0 ≤ a2  * [8.0, 16.0] b1 ≥ 0", result, -96.0, 32.0);
   /* [-6.0, 2.0], a1 ≤ 0 ≤ a2  * [0, 0] */
   ri_mul(result,a1_a2_0,z_z);
   check_result_interval(@"[-6.0, 2.0], a1 ≤ 0 ≤ a2  * [0, 0]", result, 0.0, 0.0);
   /* [-6.0, 2.0], a1 ≤ 0 ≤ a2  * (−∞, -4.0] b2 ≤ 0 */
   ri_mul(result,a1_a2_0,ninf_nb2);
   check_result_interval(@"[-6.0, 2.0], a1 ≤ 0 ≤ a2  * (−∞, -4.0] b2 ≤ 0", result, -INFINITY, +INFINITY);
   /* [-6.0, 2.0], a1 ≤ 0 ≤ a2  * (−∞, 4.0] b2 ≥ 0 */
   ri_mul(result,a1_a2_0,ninf_pb2);
   check_result_interval(@"[-6.0, 2.0], a1 ≤ 0 ≤ a2  * (−∞, 4.0] b2 ≥ 0", result, -INFINITY, +INFINITY);
   /* [-6.0, 2.0], a1 ≤ 0 ≤ a2  * [-8.0, +∞) b1 ≤ 0 */
   ri_mul(result,a1_a2_0,nb1_pinf);
   check_result_interval(@"[-6.0, 2.0], a1 ≤ 0 ≤ a2  * [-8.0, +∞) b1 ≤ 0", result, -INFINITY, +INFINITY);
   /* [-6.0, 2.0], a1 ≤ 0 ≤ a2  * [8.0, +∞) b1 ≥ 0 */
   ri_mul(result,a1_a2_0,pb1_pinf);
   check_result_interval(@"[-6.0, 2.0], a1 ≤ 0 ≤ a2  * [8.0, +∞) b1 ≥ 0", result, -INFINITY, +INFINITY);
   /* [-6.0, 2.0], a1 ≤ 0 ≤ a2  *  (−∞, +∞) */
   ri_mul(result,a1_a2_0,ninf_pinf);
   check_result_interval(@"[-6.0, 2.0], a1 ≤ 0 ≤ a2  *  (−∞, +∞)", result, -INFINITY, +INFINITY);
   
   /* */
   
   /* [6.0, 12.0], a1 ≥ 0  * [-8.0, -4.0] b2 ≤ 0 */
   ri_mul(result,pa1_a2,b1_nb2);
   check_result_interval(@"[6.0, 12.0], a1 ≥ 0  * [-8.0, -4.0] b2 ≤ 0", result, -96.0, -24.0);
   /* [6.0, 12.0], a1 ≥ 0  * [-8.0, 4.0] b1 < 0 < b2 */
   ri_mul(result,pa1_a2,b1_b2_0);
   check_result_interval(@"[6.0, 12.0], a1 ≥ 0  * [-8.0, 4.0] b1 < 0 < b2", result, -96.0, 48.0);
   /* [6.0, 12.0], a1 ≥ 0  * [8.0, 16.0] b1 ≥ 0 */
   ri_mul(result,pa1_a2,pb1_b2);
   check_result_interval(@"[6.0, 12.0], a1 ≥ 0  * [8.0, 16.0] b1 ≥ 0", result, 48.0, 192.0);
   /* [6.0, 12.0], a1 ≥ 0  * [0, 0] */
   ri_mul(result,pa1_a2,z_z);
   check_result_interval(@"[6.0, 12.0], a1 ≥ 0  * [0, 0]", result, 0.0, 0.0   );
   /* [6.0, 12.0], a1 ≥ 0  * (−∞, -4.0] b2 ≤ 0 */
   ri_mul(result,pa1_a2,ninf_nb2);
   check_result_interval(@"[6.0, 12.0], a1 ≥ 0  * (−∞, -4.0] b2 ≤ 0", result, -INFINITY, -24.0);
   /* [6.0, 12.0], a1 ≥ 0  * (−∞, 4.0] b2 ≥ 0 */
   ri_mul(result,pa1_a2,ninf_pb2);
   check_result_interval(@"[6.0, 12.0], a1 ≥ 0  * (−∞, 4.0] b2 ≥ 0", result, -INFINITY, 48.0);
   /* [6.0, 12.0], a1 ≥ 0  * [-8.0, +∞) b1 ≤ 0 */
   ri_mul(result,pa1_a2,nb1_pinf);
   check_result_interval(@"[6.0, 12.0], a1 ≥ 0  * [-8.0, +∞) b1 ≤ 0", result, -96.0, +INFINITY);
   /* [6.0, 12.0], a1 ≥ 0  * [8.0, +∞) b1 ≥ 0 */
   ri_mul(result,pa1_a2,pb1_pinf);
   check_result_interval(@"[6.0, 12.0], a1 ≥ 0  * [8.0, +∞) b1 ≥ 0", result, 48.0, +INFINITY);
   /* [6.0, 12.0], a1 ≥ 0  *  (−∞, +∞) */
   ri_mul(result,pa1_a2,ninf_pinf);
   check_result_interval(@"[6.0, 12.0], a1 ≥ 0  *  (−∞, +∞)", result, -INFINITY, +INFINITY);

   
   /* */
   
   /* [0, 0]  * [-8.0, -4.0] b2 ≤ 0 */
   ri_mul(result,z_z,b1_nb2);
   check_result_interval(@"[0, 0]  * [-8.0, -4.0] b2 ≤ 0", result, 0.0, 0.0);
   /* [0, 0]  * [-8.0, 4.0] b1 < 0 < b2 */
   ri_mul(result,z_z,b1_b2_0);
   check_result_interval(@"[0, 0]  * [-8.0, 4.0] b1 < 0 < b2", result, 0.0, 0.0);
   /* [0, 0]  * [8.0, 16.0] b1 ≥ 0 */
   ri_mul(result,z_z,pb1_b2);
   check_result_interval(@"[0, 0]  * [8.0, 16.0] b1 ≥ 0", result, 0.0, 0.0);
   /* [0, 0]  * [0, 0] */
   ri_mul(result,z_z,z_z);
   check_result_interval(@"[0, 0]  * [0, 0]", result, 0.0, 0.0);
   /* [0, 0]  * (−∞, -4.0] b2 ≤ 0 */
   ri_mul(result,z_z,ninf_nb2);
   check_result_interval(@"[0, 0]  * (−∞, -4.0] b2 ≤ 0", result, NAN, 0.0);
   /* [0, 0]  * (−∞, 4.0] b2 ≥ 0 */
   ri_mul(result,z_z,ninf_pb2);
   check_result_interval(@"[0, 0]  * (−∞, 4.0] b2 ≥ 0", result, NAN, 0.0);
   /* [0, 0]  * [-8.0, +∞) b1 ≤ 0 */
   ri_mul(result,z_z,nb1_pinf);
   check_result_interval(@"[0, 0]  * [-8.0, +∞) b1 ≤ 0", result, 0.0, NAN);
   /* [0, 0]  * [8.0, +∞) b1 ≥ 0 */
   ri_mul(result,z_z,pb1_pinf);
   check_result_interval(@"[0, 0] * [8.0, +∞) b1 ≥ 0", result, 0.0, NAN);
   /* [0, 0]  *  (−∞, +∞) */
   ri_mul(result,z_z,ninf_pinf);
   check_result_interval(@"[0, 0]  *  (−∞, +∞)", result, NAN, NAN);
   
   /* */
   
   /* (−∞, -2.0] a2 ≤ 0  * [-8.0, -4.0] b2 ≤ 0 */
   ri_mul(result,ninf_na2,b1_nb2);
   check_result_interval(@"(−∞, -2.0] a2 ≤ 0  * [-8.0, -4.0] b2 ≤ 0", result, 8.0, +INFINITY);
   /* (−∞, -2.0] a2 ≤ 0  * [-8.0, 4.0] b1 < 0 < b2 */
   ri_mul(result,ninf_na2,b1_b2_0);
   check_result_interval(@"(−∞, -2.0] a2 ≤ 0  * [-8.0, 4.0] b1 < 0 < b2", result, -INFINITY, +INFINITY);
   /* (−∞, -2.0] a2 ≤ 0  * [8.0, 16.0] b1 ≥ 0 */
   ri_mul(result,ninf_na2,pb1_b2);
   check_result_interval(@"(−∞, -2.0] a2 ≤ 0  * [8.0, 16.0] b1 ≥ 0", result, -INFINITY, -16.0);
   /* (−∞, -2.0] a2 ≤ 0  * [0, 0] */
   ri_mul(result,ninf_na2,z_z);
   check_result_interval(@"(−∞, -2.0] a2 ≤ 0  * [0, 0]", result, NAN, 0.0);
   /* (−∞, -2.0] a2 ≤ 0  * (−∞, -4.0] b2 ≤ 0 */
   ri_mul(result,ninf_na2,ninf_nb2);
   check_result_interval(@"(−∞, -2.0] a2 ≤ 0  * (−∞, -4.0] b2 ≤ 0", result, 8.0, +INFINITY);
   /* (−∞, -2.0] a2 ≤ 0  * (−∞, 4.0] b2 ≥ 0 */
   ri_mul(result,ninf_na2,ninf_pb2);
   check_result_interval(@"(−∞, -2.0] a2 ≤ 0  * (−∞, 4.0] b2 ≥ 0", result, -INFINITY, +INFINITY);
   /* (−∞, -2.0] a2 ≤ 0  * [-8.0, +∞) b1 ≤ 0 */
   ri_mul(result,ninf_na2,nb1_pinf);
   check_result_interval(@"(−∞, -2.0] a2 ≤ 0  * [-8.0, +∞) b1 ≤ 0", result, -INFINITY, +INFINITY);
   /* (−∞, -2.0] a2 ≤ 0  * [8.0, +∞) b1 ≥ 0 */
   ri_mul(result,ninf_na2,pb1_pinf);
   check_result_interval(@"(−∞, -2.0] a2 ≤ 0 * [8.0, +∞) b1 ≥ 0", result, -INFINITY, -16.0);
   /* (−∞, -2.0] a2 ≤ 0  *  (−∞, +∞) */
   ri_mul(result,ninf_na2,ninf_pinf);
   check_result_interval(@"(−∞, -2.0] a2 ≤ 0  *  (−∞, +∞)", result, -INFINITY, +INFINITY);
   
   /* */
   
   /* (−∞, 2.0] a2 ≥ 0  * [-8.0, -4.0] b2 ≤ 0 */
   ri_mul(result,ninf_pa2,b1_nb2);
   check_result_interval(@"(−∞, 2.0] a2 ≥ 0  * [-8.0, -4.0] b2 ≤ 0", result, -16.0, +INFINITY);
   /* (−∞, 2.0] a2 ≥ 0  * [-8.0, 4.0] b1 < 0 < b2 */
   ri_mul(result,ninf_pa2,b1_b2_0);
   check_result_interval(@"(−∞, 2.0] a2 ≥ 0  * [-8.0, 4.0] b1 < 0 < b2", result, -INFINITY, +INFINITY);
   /* (−∞, 2.0] a2 ≥ 0  * [8.0, 16.0] b1 ≥ 0 */
   ri_mul(result,ninf_pa2,pb1_b2);
   check_result_interval(@"(−∞, 2.0] a2 ≥ 0  * [8.0, 16.0] b1 ≥ 0", result, -INFINITY, 32.0);
   /* (−∞, 2.0] a2 ≥ 0  * [0, 0] */
   ri_mul(result,ninf_pa2,z_z);
   check_result_interval(@"(−∞, 2.0] a2 ≥ 0  * [0, 0]", result, NAN, 0.0);
   /* (−∞, 2.0] a2 ≥ 0  * (−∞, -4.0] b2 ≤ 0 */
   ri_mul(result,ninf_pa2,ninf_nb2);
   check_result_interval(@"(−∞, 2.0] a2 ≥ 0  * (−∞, -4.0] b2 ≤ 0", result, -INFINITY, +INFINITY);
   /* (−∞, 2.0] a2 ≥ 0  * (−∞, 4.0] b2 ≥ 0 */
   ri_mul(result,ninf_pa2,ninf_pb2);
   check_result_interval(@"(−∞, 2.0] a2 ≥ 0  * (−∞, 4.0] b2 ≥ 0", result, -INFINITY, +INFINITY);
   /* (−∞, 2.0] a2 ≥ 0  * [-8.0, +∞) b1 ≤ 0 */
   ri_mul(result,ninf_pa2,nb1_pinf);
   check_result_interval(@"(−∞, 2.0] a2 ≥ 0  * [-8.0, +∞) b1 ≤ 0", result, -INFINITY, +INFINITY);
   /* (−∞, 2.0] a2 ≥ 0  * [8.0, +∞) b1 ≥ 0 */
   ri_mul(result,ninf_pa2,pb1_pinf);
   check_result_interval(@"(−∞, 2.0] a2 ≥ 0 * [8.0, +∞) b1 ≥ 0", result, -INFINITY, +INFINITY);
   /* (−∞, 2.0] a2 ≥ 0  *  (−∞, +∞) */
   ri_mul(result,ninf_pa2,ninf_pinf);
   check_result_interval(@"(−∞, 2.0] a2 ≥ 0  *  (−∞, +∞)", result, -INFINITY, +INFINITY);
   
   /* */
   
   /* [-6.0, +∞), a1 ≤ 0  * [-8.0, -4.0] b2 ≤ 0 */
   ri_mul(result,na1_pinf,b1_nb2);
   check_result_interval(@"[-6.0, +∞), a1 ≤ 0  * [-8.0, -4.0] b2 ≤ 0", result, -INFINITY, 48.0);
   /* [-6.0, +∞), a1 ≤ 0  * [-8.0, 4.0] b1 < 0 < b2 */
   ri_mul(result,na1_pinf,b1_b2_0);
   check_result_interval(@"[-6.0, +∞), a1 ≤ 0  * [-8.0, 4.0] b1 < 0 < b2", result, -INFINITY, +INFINITY);
   /* [-6.0, +∞), a1 ≤ 0  * [8.0, 16.0] b1 ≥ 0 */
   ri_mul(result,na1_pinf,pb1_b2);
   check_result_interval(@"[-6.0, +∞), a1 ≤ 0  * [8.0, 16.0] b1 ≥ 0", result, -96.0, +INFINITY);
   /* [-6.0, +∞), a1 ≤ 0  * [0, 0] */
   ri_mul(result,na1_pinf,z_z);
   check_result_interval(@"[-6.0, +∞), a1 ≤ 0  * [0, 0]", result, 0.0, NAN);
   /* [-6.0, +∞), a1 ≤ 0  * (−∞, -4.0] b2 ≤ 0 */
   ri_mul(result,na1_pinf,ninf_nb2);
   check_result_interval(@"[-6.0, +∞), a1 ≤ 0  * (−∞, -4.0] b2 ≤ 0", result, -INFINITY, +INFINITY);
   /* [-6.0, +∞), a1 ≤ 0  * (−∞, 4.0] b2 ≥ 0 */
   ri_mul(result,na1_pinf,ninf_pb2);
   check_result_interval(@"[-6.0, +∞), a1 ≤ 0  * (−∞, 4.0] b2 ≥ 0", result, -INFINITY, +INFINITY);
   /* [-6.0, +∞), a1 ≤ 0  * [-8.0, +∞) b1 ≤ 0 */
   ri_mul(result,na1_pinf,nb1_pinf);
   check_result_interval(@"[-6.0, +∞), a1 ≤ 0  * [-8.0, +∞) b1 ≤ 0", result, -INFINITY, +INFINITY);
   /* [-6.0, +∞), a1 ≤ 0  * [8.0, +∞) b1 ≥ 0 */
   ri_mul(result,na1_pinf,pb1_pinf);
   check_result_interval(@"[-6.0, +∞), a1 ≤ 0 * [8.0, +∞) b1 ≥ 0", result, -INFINITY, +INFINITY);
   /* [-6.0, +∞), a1 ≤ 0  *  (−∞, +∞) */
   ri_mul(result,na1_pinf,ninf_pinf);
   check_result_interval(@"[-6.0, +∞), a1 ≤ 0  *  (−∞, +∞)", result, -INFINITY, +INFINITY);
   
   /* */
   
   /* [6.0, +∞), a1 ≥ 0  * [-8.0, -4.0] b2 ≤ 0 */
   ri_mul(result,pa1_pinf,b1_nb2);
   check_result_interval(@"[6.0, +∞), a1 ≥ 0  * [-8.0, -4.0] b2 ≤ 0", result, -INFINITY, -24.0);
   /* [6.0, +∞), a1 ≥ 0  * [-8.0, 4.0] b1 < 0 < b2 */
   ri_mul(result,pa1_pinf,b1_b2_0);
   check_result_interval(@"[6.0, +∞), a1 ≥ 0  * [-8.0, 4.0] b1 < 0 < b2", result, -INFINITY, +INFINITY);
   /* [6.0, +∞), a1 ≥ 0  * [8.0, 16.0] b1 ≥ 0 */
   ri_mul(result,pa1_pinf,pb1_b2);
   check_result_interval(@"[6.0, +∞), a1 ≥ 0  * [8.0, 16.0] b1 ≥ 0", result, 48.0, +INFINITY);
   /* [6.0, +∞), a1 ≥ 0  * [0, 0] */
   ri_mul(result,pa1_pinf,z_z);
   check_result_interval(@"[6.0, +∞), a1 ≥ 0  * [0, 0]", result, 0.0, NAN);
   /* [6.0, +∞), a1 ≥ 0  * (−∞, -4.0] b2 ≤ 0 */
   ri_mul(result,pa1_pinf,ninf_nb2);
   check_result_interval(@"[6.0, +∞), a1 ≥ 0  * (−∞, -4.0] b2 ≤ 0", result, -INFINITY, -24.0);
   /* [6.0, +∞), a1 ≥ 0  * (−∞, 4.0] b2 ≥ 0 */
   ri_mul(result,pa1_pinf,ninf_pb2);
   check_result_interval(@"[6.0, +∞), a1 ≥ 0  * (−∞, 4.0] b2 ≥ 0", result, -INFINITY, +INFINITY);
   /* [6.0, +∞), a1 ≥ 0  * [-8.0, +∞) b1 ≤ 0 */
   ri_mul(result,pa1_pinf,nb1_pinf);
   check_result_interval(@"[6.0, +∞), a1 ≥ 0  * [-8.0, +∞) b1 ≤ 0", result, -INFINITY, +INFINITY);
   /* [6.0, +∞), a1 ≥ 0  * [8.0, +∞) b1 ≥ 0 */
   ri_mul(result,pa1_pinf,pb1_pinf);
   check_result_interval(@"[6.0, +∞), a1 ≥ 0 * [8.0, +∞) b1 ≥ 0", result, 48.0, +INFINITY);
   /* [6.0, +∞), a1 ≥ 0  *  (−∞, +∞) */
   ri_mul(result,pa1_pinf,ninf_pinf);
   check_result_interval(@"[6.0, +∞), a1 ≥ 0  *  (−∞, +∞)", result, -INFINITY, +INFINITY);
   
   /* */
   
   /* (−∞, +∞)  * [-8.0, -4.0] b2 ≤ 0 */
   ri_mul(result,ninf_pinf,b1_nb2);
   check_result_interval(@"(−∞, +∞)  * [-8.0, -4.0] b2 ≤ 0", result, -INFINITY, +INFINITY);
   /* (−∞, +∞)  * [-8.0, 4.0] b1 < 0 < b2 */
   ri_mul(result,ninf_pinf,b1_b2_0);
   check_result_interval(@"(−∞, +∞)  * [-8.0, 4.0] b1 < 0 < b2", result, -INFINITY, +INFINITY);
   /* (−∞, +∞)  * [8.0, 16.0] b1 ≥ 0 */
   ri_mul(result,ninf_pinf,pb1_b2);
   check_result_interval(@"(−∞, +∞)  * [8.0, 16.0] b1 ≥ 0", result, -INFINITY, +INFINITY);
   /* (−∞, +∞)  * [0, 0] */
   ri_mul(result,ninf_pinf,z_z);
   check_result_interval(@"(−∞, +∞)  * [0, 0]", result, NAN, NAN);
   /* (−∞, +∞)  * (−∞, -4.0] b2 ≤ 0 */
   ri_mul(result,ninf_pinf,ninf_nb2);
   check_result_interval(@"(−∞, +∞)  * (−∞, -4.0] b2 ≤ 0", result, -INFINITY, +INFINITY);
   /* (−∞, +∞)  * (−∞, 4.0] b2 ≥ 0 */
   ri_mul(result,ninf_pinf,ninf_pb2);
   check_result_interval(@"(−∞, +∞)  * (−∞, 4.0] b2 ≥ 0", result, -INFINITY, +INFINITY);
   /* (−∞, +∞)  * [-8.0, +∞) b1 ≤ 0 */
   ri_mul(result,ninf_pinf,nb1_pinf);
   check_result_interval(@"(−∞, +∞)  * [-8.0, +∞) b1 ≤ 0", result, -INFINITY, +INFINITY);
   /* (−∞, +∞)  * [8.0, +∞) b1 ≥ 0 */
   ri_mul(result,ninf_pinf,pb1_pinf);
   check_result_interval(@"(−∞, +∞) * [8.0, +∞) b1 ≥ 0", result, -INFINITY, +INFINITY);
   /* (−∞, +∞)  *  (−∞, +∞) */
   ri_mul(result,ninf_pinf,ninf_pinf);
   check_result_interval(@"(−∞, +∞)  *  (−∞, +∞)", result, -INFINITY, +INFINITY);
   
   ri_clear(ninf_na2);
   ri_clear(ninf_pa2);
   ri_clear(a1_na2);
   ri_clear(a1_a2_0);
   ri_clear(pa1_a2);
   ri_clear(na1_pinf);
   ri_clear(pa1_pinf);
   ri_clear(ninf_nb2);
   ri_clear(ninf_pb2);
   ri_clear(b1_nb2);
   ri_clear(b1_b2_0);
   ri_clear(pb1_b2);
   ri_clear(z_z);
   ri_clear(nb1_pinf);
   ri_clear(pb1_pinf);
   ri_clear(ninf_pinf);
   ri_clear(result);
}

void check_division_interval(){
   ri ninf_na2,ninf_pa2, a1_na2, a1_a2_0, pa1_a2, na1_pinf, pa1_pinf, ninf_z, b1_z, z_b2, z_z, z_pinf, ninf_pinf;
   ri result;
   
   ri_init(a1_na2);
   ri_init(a1_a2_0);
   ri_init(pa1_a2);
   ri_init(ninf_na2);
   ri_init(ninf_pa2);
   ri_init(na1_pinf);
   ri_init(pa1_pinf);
   ri_init(z_z);
   ri_init(b1_z);
   ri_init(z_b2);
   ri_init(ninf_z);
   ri_init(z_pinf);
   ri_init(ninf_pinf);
   ri_init(result);
   
   ri_set_d(a1_na2, -6.0, -2.0);
   ri_set_d(a1_a2_0, -6.0, 2.0);
   ri_set_d(pa1_a2, 6.0, 12.0);
   ri_set_d(ninf_na2, -INFINITY, -2.0);
   ri_set_d(ninf_pa2, -INFINITY, 2.0);
   ri_set_d(na1_pinf, -2.0, +INFINITY);
   ri_set_d(pa1_pinf, 2.0, +INFINITY);
   
   ri_set_d(z_z, 0.0, 0.0);
   ri_set_d(b1_z, -8.0, 0.0);
   ri_set_d(z_b2, 0.0, 4.0);
   ri_set_d(ninf_z, -INFINITY, 0.0);
   ri_set_d(z_pinf, 0.0, +INFINITY);
   
   ri_set_d(ninf_pinf, -INFINITY, +INFINITY);
   
   /* [-6.0, -2.0], a2 ≤ 0  / [0.0, 0.0] */
   ri_div(result,a1_na2,z_z);
   check_result_interval(@"[-6.0, -2.0], a2 ≤ 0  / [0.0, 0.0]", result, NAN, NAN);
   /* [-6.0, -2.0], a2 ≤ 0  / [-8.0, 0.0] */
   ri_div(result,a1_na2,b1_z);
   check_result_interval(@"[-6.0, -2.0], a2 ≤ 0  / [-8.0, 0.0]", result, 0.25, +INFINITY);
   /* [-6.0, -2.0], a2 ≤ 0  / [0.0, 4.0] */
   ri_div(result,a1_na2,z_b2);
   check_result_interval(@"[-6.0, -2.0], a2 ≤ 0  / [0.0, 4.0]", result, -INFINITY, -0.5);
   /* [-6.0, -2.0], a2 ≤ 0  / (−∞, 0.0] */
   ri_div(result,a1_na2,ninf_z);
   check_result_interval(@"[-6.0, -2.0], a2 ≤ 0  / (−∞, 0.0]", result, 0.0, +INFINITY);
   /* [-6.0, -2.0], a2 ≤ 0  / [0.0, +∞) */
   ri_div(result,a1_na2,z_pinf);
   check_result_interval(@"[-6.0, -2.0], a2 ≤ 0  / [0.0, +∞)", result, -INFINITY, 0.0);
   /* [-6.0, -2.0], a2 ≤ 0  /  (−∞, +∞) */
   ri_div(result,a1_na2,ninf_pinf);
   check_result_interval(@"[-6.0, -2.0], a2 ≤ 0  *  (−∞, +∞)", result, -INFINITY, +INFINITY);
   
   /* [-6.0, 2.0], a1 ≤ 0 ≤ a2  / [0.0, 0.0] */
   ri_div(result,a1_a2_0,z_z);
   check_result_interval(@"[-6.0, 2.0], a1 ≤ 0 ≤ a2  / [0.0, 0.0]", result, -INFINITY, +INFINITY);
   /* [-6.0, 2.0], a1 ≤ 0 ≤ a2  / [-8.0, 0.0] */
   ri_div(result,a1_a2_0,b1_z);
   check_result_interval(@"[-6.0, 2.0], a1 ≤ 0 ≤ a2  / [-8.0, 0.0]", result, -INFINITY, +INFINITY);
   /* [-6.0, 2.0], a1 ≤ 0 ≤ a2  / [0.0, 4.0] */
   ri_div(result,a1_a2_0,z_b2);
   check_result_interval(@"[-6.0, 2.0], a1 ≤ 0 ≤ a2  / [0.0, 4.0]", result, -INFINITY, +INFINITY);
   /* [-6.0, 2.0], a1 ≤ 0 ≤ a2  / (−∞, 0.0] */
   ri_div(result,a1_a2_0,ninf_z);
   check_result_interval(@"[-6.0, 2.0], a1 ≤ 0 ≤ a2  / (−∞, 0.0]", result, -INFINITY, +INFINITY);
   /* [-6.0, 2.0], a1 ≤ 0 ≤ a2  / [0.0, +∞) */
   ri_div(result,a1_a2_0,z_pinf);
   check_result_interval(@"[-6.0, 2.0], a1 ≤ 0 ≤ a2  / [0.0, +∞)", result, -INFINITY, +INFINITY);
   /* [-6.0, 2.0], a1 ≤ 0 ≤ a2  /  (−∞, +∞) */
   ri_div(result,a1_a2_0,ninf_pinf);
   check_result_interval(@"[-6.0, 2.0], a1 ≤ 0 ≤ a2  *  (−∞, +∞)", result, -INFINITY, +INFINITY);
   
   /* [6.0, 12.0], a1 ≥ 0  / [0.0, 0.0] */
   ri_div(result,pa1_a2,z_z);
   check_result_interval(@"[-6.0, 2.0], a1 ≤ 0 ≤ a2  / [0.0, 0.0]", result, NAN, NAN);
   /* [6.0, 12.0], a1 ≥ 0  / [-8.0, 0.0] */
   ri_div(result,pa1_a2,b1_z);
   check_result_interval(@"[-6.0, 2.0], a1 ≤ 0 ≤ a2  / [-8.0, 0.0]", result, -INFINITY, 0.75);
   /* [6.0, 12.0], a1 ≥ 0  / [0.0, 4.0] */
   ri_div(result,pa1_a2,z_b2);
   check_result_interval(@"[-6.0, 2.0], a1 ≤ 0 ≤ a2  / [0.0, 4.0]", result, -1.5, +INFINITY);
   /* [6.0, 12.0], a1 ≥ 0  / (−∞, 0.0] */
   ri_div(result,pa1_a2,ninf_z);
   check_result_interval(@"[-6.0, 2.0], a1 ≤ 0 ≤ a2  / (−∞, 0.0]", result, -INFINITY, 0.0);
   /* [6.0, 12.0], a1 ≥ 0  / [0.0, +∞) */
   ri_div(result,pa1_a2,z_pinf);
   check_result_interval(@"[-6.0, 2.0], a1 ≤ 0 ≤ a2  / [0.0, +∞)", result, 0.0, +INFINITY);
   /* [6.0, 12.0], a1 ≥ 0  /  (−∞, +∞) */
   ri_div(result,pa1_a2,ninf_pinf);
   check_result_interval(@"[-6.0, 2.0], a1 ≤ 0 ≤ a2  *  (−∞, +∞)", result, -INFINITY, +INFINITY);
   
   /* (−∞, -2.0] a2 ≤ 0  / [0.0, 0.0] */
   ri_div(result,ninf_na2,z_z);
   check_result_interval(@"(−∞, -2.0] a2 ≤ 0  / [0.0, 0.0]", result, NAN, NAN);
   /* (−∞, -2.0] a2 ≤ 0  / [-8.0, 0.0] */
   ri_div(result,ninf_na2,b1_z);
   check_result_interval(@"(−∞, -2.0] a2 ≤ 0  / [-8.0, 0.0]", result, 0.25, +INFINITY);
   /* (−∞, -2.0] a2 ≤ 0  / [0.0, 4.0] */
   ri_div(result,ninf_na2,z_b2);
   check_result_interval(@"(−∞, -2.0] a2 ≤ 0  / [0.0, 4.0]", result, -INFINITY, -0.5);
   /* (−∞, -2.0] a2 ≤ 0  / (−∞, 0.0] */
   ri_div(result,ninf_na2,ninf_z);
   check_result_interval(@"(−∞, -2.0] a2 ≤ 0  / (−∞, 0.0]", result, 0.0, +INFINITY);
   /* (−∞, -2.0] a2 ≤ 0  / [0.0, +∞) */
   ri_div(result,ninf_na2,z_pinf);
   check_result_interval(@"(−∞, -2.0] a2 ≤ 0  / [0.0, +∞)", result, -INFINITY, 0.0);
   /* (−∞, -2.0] a2 ≤ 0  /  (−∞, +∞) */
   ri_div(result,ninf_na2,ninf_pinf);
   check_result_interval(@"(−∞, -2.0] a2 ≤ 0  /  (−∞, +∞)", result, -INFINITY, +INFINITY);
   
   /* (−∞, 2.0] a2 ≥ 0  / [0.0, 0.0] */
   ri_div(result,ninf_pa2,z_z);
   check_result_interval(@"(−∞, 2.0] a2 ≥ 0  / [0.0, 0.0]", result,-INFINITY, INFINITY);
   /* (−∞, 2.0] a2 ≥ 0  / [-8.0, 0.0] */
   ri_div(result,ninf_pa2,b1_z);
   check_result_interval(@"(−∞, 2.0] a2 ≥ 0  / [-8.0, 0.0]", result,-INFINITY, INFINITY);
   /* (−∞, 2.0] a2 ≥ 0  / [0.0, 4.0] */
   ri_div(result,ninf_pa2,z_b2);
   check_result_interval(@"(−∞, 2.0] a2 ≥ 0  / [0.0, 4.0]", result, -INFINITY, INFINITY);
   /* (−∞, 2.0] a2 ≥ 0  / (−∞, 0.0] */
   ri_div(result,ninf_pa2,ninf_z);
   check_result_interval(@"(−∞, 2.0] a2 ≥ 0  / (−∞, 0.0]", result, -INFINITY, INFINITY);
   /* (−∞, 2.0] a2 ≥ 0  / [0.0, +∞) */
   ri_div(result,ninf_pa2,z_pinf);
   check_result_interval(@"(−∞, 2.0] a2 ≥ 0  / [0.0, +∞)", result, -INFINITY, INFINITY);
   /* (−∞, 2.0] a2 ≥ 0  /  (−∞, +∞) */
   ri_div(result,ninf_pa2,ninf_pinf);
   check_result_interval(@"(−∞, 2.0] a2 ≥ 0  /  (−∞, +∞)", result, -INFINITY, +INFINITY);
   
   /* [-6.0, +∞), a1 ≤ 0  / [0.0, 0.0] */
   ri_div(result,na1_pinf,z_z);
   check_result_interval(@"[-6.0, +∞), a1 ≤ 0  / [0.0, 0.0]", result,-INFINITY, INFINITY);
   /* [-6.0, +∞), a1 ≤ 0  / [-8.0, 0.0] */
   ri_div(result,na1_pinf,b1_z);
   check_result_interval(@"[-6.0, +∞), a1 ≤ 0  / [-8.0, 0.0]", result,-INFINITY, INFINITY);
   /* [-6.0, +∞), a1 ≤ 0  / [0.0, 4.0] */
   ri_div(result,na1_pinf,z_b2);
   check_result_interval(@"[-6.0, +∞), a1 ≤ 0  / [0.0, 4.0]", result, -INFINITY, INFINITY);
   /* [-6.0, +∞), a1 ≤ 0  / (−∞, 0.0] */
   ri_div(result,na1_pinf,ninf_z);
   check_result_interval(@"[-6.0, +∞), a1 ≤ 0  / (−∞, 0.0]", result, -INFINITY, INFINITY);
   /* [-6.0, +∞), a1 ≤ 0  / [0.0, +∞) */
   ri_div(result,na1_pinf,z_pinf);
   check_result_interval(@"[-6.0, +∞), a1 ≤ 0  / [0.0, +∞)", result, -INFINITY, INFINITY);
   /* [-6.0, +∞), a1 ≤ 0  /  (−∞, +∞) */
   ri_div(result,na1_pinf,ninf_pinf);
   check_result_interval(@"[-6.0, +∞), a1 ≤ 0  /  (−∞, +∞)", result, -INFINITY, +INFINITY);
   
   /* [6.0, +∞), a1 ≥ 0  / [0.0, 0.0] */
   ri_div(result,pa1_pinf,z_z);
   check_result_interval(@"[6.0, +∞), a1 ≥ 0  / [0.0, 0.0]", result,NAN,NAN);
   /* [6.0, +∞), a1 ≥ 0  / [-8.0, 0.0] */
   ri_div(result,pa1_pinf,b1_z);
   check_result_interval(@"[6.0, +∞), a1 ≥ 0  / [-8.0, 0.0]", result,-INFINITY,-0.75);
   /* [6.0, +∞), a1 ≥ 0  / [0.0, 4.0] */
   ri_div(result,pa1_pinf,z_b2);
   check_result_interval(@"[6.0, +∞), a1 ≥ 0  / [0.0, 4.0]", result,1.5,+INFINITY);
   /* [6.0, +∞), a1 ≥ 0  / (−∞, 0.0] */
   ri_div(result,pa1_pinf,ninf_z);
   check_result_interval(@"[6.0, +∞), a1 ≥ 0  / (−∞, 0.0]", result,-INFINITY,0.0);
   /* [6.0, +∞), a1 ≥ 0  / [0.0, +∞) */
   ri_div(result,pa1_pinf,z_pinf);
   check_result_interval(@"[6.0, +∞), a1 ≥ 0  / [0.0, +∞)", result,0.0, +INFINITY);
   /* [6.0, +∞), a1 ≥ 0  /  (−∞, +∞) */
   ri_div(result,pa1_pinf,ninf_pinf);
   check_result_interval(@"[6.0, +∞), a1 ≥ 0  /  (−∞, +∞)", result, -INFINITY, +INFINITY);
   
   /* (−∞, +∞)  / [0.0, 0.0] */
   ri_div(result,ninf_pinf,z_z);
   check_result_interval(@"(−∞, +∞)  / [0.0, 0.0]", result,-INFINITY, INFINITY);
   /* (−∞, +∞)  / [-8.0, 0.0] */
   ri_div(result,ninf_pinf,b1_z);
   check_result_interval(@"(−∞, +∞)  / [-8.0, 0.0]", result,-INFINITY, INFINITY);
   /* (−∞, +∞)  / [0.0, 4.0] */
   ri_div(result,ninf_pinf,z_b2);
   check_result_interval(@"(−∞, +∞)  / [0.0, 4.0]", result, -INFINITY, INFINITY);
   /* (−∞, +∞)  / (−∞, 0.0] */
   ri_div(result,ninf_pinf,ninf_z);
   check_result_interval(@"(−∞, +∞)  / (−∞, 0.0]", result, -INFINITY, INFINITY);
   /* (−∞, +∞)  / [0.0, +∞) */
   ri_div(result,ninf_pinf,z_pinf);
   check_result_interval(@"(−∞, +∞)  / [0.0, +∞)", result, -INFINITY, INFINITY);
   /* (−∞, +∞)  /  (−∞, +∞) */
   ri_div(result,ninf_pinf,ninf_pinf);
   check_result_interval(@"(−∞, +∞)  /  (−∞, +∞)", result, -INFINITY, +INFINITY);

   
   ri_clear(a1_na2);
   ri_clear(a1_a2_0);
   ri_clear(pa1_a2);
   ri_clear(ninf_na2);
   ri_clear(ninf_pa2);
   ri_clear(na1_pinf);
   ri_clear(pa1_pinf);
   ri_clear(z_z);
   ri_clear(b1_z);
   ri_clear(z_b2);
   ri_clear(ninf_z);
   ri_clear(z_pinf);
   ri_clear(ninf_pinf);
   ri_clear(result);
}

int main(int argc, const char * argv[]) {
   
   //check_addition();
   //check_subtraction();
   //check_multiplication();
   //check_division();
   
   //check_addition_interval();
   //check_subtraction_interval();
   //check_multiplication_interval();
   check_division_interval();

   return 0;
}
