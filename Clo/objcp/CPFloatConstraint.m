/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import "CPFloatConstraint.h"
#import "CPFloatVarI.h"
#import "ORConstraintI.h"
#include "gmp.h"

#define PERCENT 5.0

ORBool same_sign(ORFloat x, ORFloat y){
   return signbit(x) == signbit(y);
}

double_interval ulp_computation(float_interval f){
   double_interval ulp;
   ORDouble max_inf, max_sup;
   if(f.inf == -INFINITY || f.sup == INFINITY){
      max_inf = -FLT_MAX;
      max_sup = FLT_MAX;
   }else if(fabsf(f.inf) == FLT_MAX || fabsf(f.sup) == FLT_MAX){
      max_inf = (nextafterf(FLT_MAX, -INFINITY) - FLT_MAX)/2.0f;
      max_sup = -max_inf;
   } else{
      ORFloat inf_m, inf_p, sup_m, sup_p;
      inf_m = nextafterf(f.inf, -INFINITY) - f.inf;
      sup_m = nextafterf(f.sup, -INFINITY) - f.sup;
      inf_p = nextafterf(f.inf, +INFINITY) - f.inf;
      sup_p = nextafterf(f.sup, +INFINITY) - f.sup;
      
      max_inf = minFlt(inf_m, sup_m)/2.0f;
      max_sup = maxFlt(inf_p, sup_p)/2.0f;
   }
   ulp.inf = max_inf;
   ulp.sup = max_sup;
   return ulp;
}

void setR(rational_interval* result, rational_interval* value){
   mpq_set(result->inf, value->inf);
   mpq_set(result->sup, value->sup);
}

void addR(rational_interval* ez, rational_interval* ex, rational_interval* ey, rational_interval* eo){
   mpq_add(ez->inf, ex->inf, ey->inf);
   mpq_add(ez->inf, ez->inf, eo->inf);
   
   mpq_add(ez->sup, ex->sup, ey->sup);
   mpq_add(ez->sup, ez->sup, eo->sup);
}

void addR_inv_ex(rational_interval* ex, rational_interval* ez, rational_interval* ey, rational_interval* eo){
   mpq_sub(ex->inf, ez->inf, ey->sup);
   mpq_sub(ex->sup, ez->sup, ey->inf);
   
   mpq_sub(ex->inf, ex->inf, eo->sup);
   mpq_sub(ex->sup, ex->sup, eo->inf);
}

void addR_inv_ey(rational_interval* ey, rational_interval* ez, rational_interval* ex, rational_interval* eo){
   mpq_sub(ey->inf, ez->inf, ex->sup);
   mpq_sub(ey->sup, ez->sup, ex->inf);
   
   mpq_sub(ey->inf, ey->inf, eo->sup);
   mpq_sub(ey->sup, ey->sup, eo->inf);
}

void addR_inv_eo(rational_interval* eo, rational_interval* ez, rational_interval* ex, rational_interval* ey){
   mpq_sub(eo->inf, ez->inf, ex->sup);
   mpq_sub(eo->sup, ez->sup, ex->inf);
   
   mpq_sub(eo->inf, eo->inf, ey->sup);
   mpq_sub(eo->sup, eo->sup, ey->inf);
}

void subR(rational_interval* ez, rational_interval* ex, rational_interval* ey, rational_interval* eo){
   mpq_sub(ez->inf, ex->inf, ey->sup);
   mpq_sub(ez->sup, ex->sup, ey->inf);

   mpq_add(ez->inf, ez->inf, eo->inf);
   mpq_add(ez->sup, ez->sup, eo->sup);
}

void subR_inv_ex(rational_interval* ex, rational_interval* ez, rational_interval* ey, rational_interval* eo){
   mpq_add(ex->inf, ez->inf, ey->inf);
   mpq_add(ex->sup, ez->sup, ey->sup);

   mpq_sub(ex->inf, ex->inf, eo->sup);
   mpq_sub(ex->sup, ex->sup, eo->inf);
}

void subR_inv_ey(rational_interval* ey, rational_interval* ez, rational_interval* ex, rational_interval* eo){
   mpq_sub(ey->inf, ex->inf, ez->sup);
   mpq_sub(ey->sup, ex->sup, ez->inf);
   
   mpq_add(ey->inf, ey->inf, eo->inf);
   mpq_add(ey->sup, ey->sup, eo->sup);
}

void subR_inv_eo(rational_interval* eo, rational_interval* ez, rational_interval* ex, rational_interval* ey){
   mpq_sub(eo->inf, ez->inf, ex->sup);
   mpq_sub(eo->sup, ez->sup, ex->inf);

   mpq_add(eo->inf, eo->inf, ey->inf);
   mpq_add(eo->sup, eo->sup, ey->sup);
}

void mulR(rational_interval* ez, rational_interval* ex, rational_interval* ey, rational_interval* eo, float_interval* x, float_interval* y){
   rational_interval _x, _y;
   ORRational tmp1, tmp2, tmp3, tmp4, mulm1, mulm2, mulm3, mulM1, mulM2, mulM3;
   
   mpq_inits(_x.inf, _x.sup, _y.inf, _y.sup, tmp1, tmp2, tmp3, tmp4, mulm1, mulm2, mulm3, mulM1, mulM2, mulM3, NULL);
   
   if(x->inf == -INFINITY){
      mpq_set_d(_x.inf, -2*FLT_MAX);
   } else {
      mpq_set_d(_x.inf, x->inf);
   }
   if(x->sup == INFINITY){
      mpq_set_d(_x.sup, 2*FLT_MAX);
   } else {
      mpq_set_d(_x.sup, x->sup);
   }
   if(y->inf == -INFINITY){
      mpq_set_d(_y.inf, -2*FLT_MAX);
   } else {
      mpq_set_d(_y.inf, y->inf);
   }
   if(y->sup == INFINITY){
      mpq_set_d(_y.sup, 2*FLT_MAX);
   } else {
      mpq_set_d(_y.sup, y->sup);
   }
   
   /* y * ex */
   mpq_mul(tmp1, _y.inf, ex->inf);
   mpq_mul(tmp2, _y.inf, ex->sup);
   mpq_mul(tmp3, _y.sup, ex->inf);
   mpq_mul(tmp4, _y.sup, ex->sup);
   
   minError(&mulm1, &tmp1, &tmp2);
   minError(&mulm1, &mulm1, &tmp3);
   minError(&mulm1, &mulm1, &tmp4);
   
   maxError(&mulM1, &tmp1, &tmp2);
   maxError(&mulM1, &mulM1, &tmp3);
   maxError(&mulM1, &mulM1, &tmp4);
   
   /* x * ey */
   mpq_mul(tmp1, _x.inf, ey->inf);
   mpq_mul(tmp2, _x.inf, ey->sup);
   mpq_mul(tmp3, _x.sup, ey->inf);
   mpq_mul(tmp4, _x.sup, ey->sup);
   
   minError(&mulm2, &tmp1, &tmp2);
   minError(&mulm2, &mulm2, &tmp3);
   minError(&mulm2, &mulm2, &tmp4);
   
   maxError(&mulM2, &tmp1, &tmp2);
   maxError(&mulM2, &mulM2, &tmp3);
   maxError(&mulM2, &mulM2, &tmp4);
   
   /* ex * ey */
   mpq_mul(tmp1, ex->inf, ey->inf);
   mpq_mul(tmp2, ex->inf, ey->sup);
   mpq_mul(tmp3, ex->sup, ey->inf);
   mpq_mul(tmp4, ex->sup, ey->sup);
   
   minError(&mulm3, &tmp1, &tmp2);
   minError(&mulm3, &mulm3, &tmp3);
   minError(&mulm3, &mulm3, &tmp4);
   
   maxError(&mulM3, &tmp1, &tmp2);
   maxError(&mulM3, &mulM3, &tmp3);
   maxError(&mulM3, &mulM3, &tmp4);
   
   /* (y*ex) + (x*ey) */
   mpq_add(tmp1, mulm1, mulm2);
   mpq_add(tmp2, mulM1, mulM2);
   
   /* (y*ex)+(x*ey) + (ex*ey) */
   mpq_add(tmp1, tmp1, mulm3);
   mpq_add(tmp2, tmp2, mulM3);
   
   /* (y*ex)+(x*ey)+(ex*ey) + eo */
   mpq_add(tmp1, tmp1, eo->inf);
   mpq_add(tmp2, tmp2, eo->sup);
   
   /* update ez bounds */
   mpq_set(ez->inf, tmp1);
   mpq_set(ez->sup, tmp2);
   
   mpq_clears(_x.inf, _x.sup, _y.inf, _y.sup, tmp1, tmp2, tmp3, tmp4, mulm1, mulm2, mulm3, mulM1, mulM2, mulM3, NULL);
}

void mulR_inv_ex(rational_interval* ex, rational_interval* ez, rational_interval* ey, rational_interval* eo, float_interval* x, float_interval* y){
   rational_interval _x, _y;
   ORRational tmp1, tmp2, tmp3, tmp4, one, divm, divM, mulm, mulM;
   
   mpq_inits(_x.inf, _x.sup, _y.inf, _y.sup, tmp1, tmp2, tmp3, tmp4, one, divm, divM, mulm, mulM, NULL);
   
   if(x->inf == -INFINITY){
      mpq_set_d(_x.inf, -2*FLT_MAX);
   } else {
      mpq_set_d(_x.inf, x->inf);
   }
   if(x->sup == INFINITY){
      mpq_set_d(_x.sup, 2*FLT_MAX);
   } else {
      mpq_set_d(_x.sup, x->sup);
   }
   if(y->inf == -INFINITY){
      mpq_set_d(_y.inf, -2*FLT_MAX);
   } else {
      mpq_set_d(_y.inf, y->inf);
   }
   if(y->sup == INFINITY){
      mpq_set_d(_y.sup, 2*FLT_MAX);
   } else {
      mpq_set_d(_y.sup, y->sup);
   }
   mpq_set_d(one, 1.0f);
   
   /* y + ey */
   mpq_add(tmp1, _y.inf, ey->inf);
   mpq_add(tmp2, _y.sup, ey->sup);
   
   /* 1 / (y+ey) */
   mpq_div(divm, one, tmp2);
   mpq_div(divM, one, tmp1);
   
   /* x * ey */
   mpq_mul(tmp1, _x.inf, ey->inf);
   mpq_mul(tmp2, _x.inf, ey->sup);
   mpq_mul(tmp1, _x.sup, ey->inf);
   mpq_mul(tmp2, _x.sup, ey->sup);
   
   minError(&mulm, &tmp1, &tmp2);
   minError(&mulm, &mulm, &tmp1);
   minError(&mulm, &mulm, &tmp2);
   
   maxError(&mulM, &tmp1, &tmp2);
   maxError(&mulM, &mulM, &tmp1);
   maxError(&mulM, &mulM, &tmp2);
   
   /* ez - (x*ey) */
   mpq_sub(tmp1, ez->inf, mulM);
   mpq_sub(tmp2, ez->sup, mulm);
   
   /* ez-(x*ey) - eo */
   mpq_sub(tmp1, tmp1, eo->sup);
   mpq_sub(tmp2, tmp2, eo->inf);
   
   /* (1/(y+ey)) * (ez-(x*ey)-eo) */
   mpq_mul(tmp3, tmp1, divm);
   mpq_mul(tmp4, tmp2, divm);
   mpq_mul(tmp3, tmp1, divM);
   mpq_mul(tmp4, tmp2, divM);
   
   
   minError(&mulm, &tmp3, &tmp4);
   minError(&mulm, &mulm, &tmp3);
   minError(&mulm, &mulm, &tmp4);
   
   maxError(&mulM, &tmp3, &tmp4);
   maxError(&mulM, &mulM, &tmp3);
   maxError(&mulM, &mulM, &tmp4);
   
   /* update ex bounds */
   mpq_set(ex->inf, mulm);
   mpq_set(ex->sup, mulM);
   
   mpq_clears(_x.inf, _x.sup, _y.inf, _y.sup, tmp1, tmp2, tmp3, tmp4, one, divm, divM, mulm, mulM, NULL);
}

void mulR_inv_ey(rational_interval* ey, rational_interval* ez, rational_interval* ex, rational_interval* eo, float_interval* x, float_interval* y){
   rational_interval _x, _y;
   ORRational tmp1, tmp2, tmp3, tmp4, one, divm, divM, mulm, mulM;
   
   mpq_inits(_x.inf, _x.sup, _y.inf, _y.sup, tmp1, tmp2, tmp3, tmp4, one, divm, divM, mulm, mulM, NULL);
   
   if(x->inf == -INFINITY){
      mpq_set_d(_x.inf, -2*FLT_MAX);
   } else {
      mpq_set_d(_x.inf, x->inf);
   }
   if(x->sup == INFINITY){
      mpq_set_d(_x.sup, 2*FLT_MAX);
   } else {
      mpq_set_d(_x.sup, x->sup);
   }
   if(y->inf == -INFINITY){
      mpq_set_d(_y.inf, -2*FLT_MAX);
   } else {
      mpq_set_d(_y.inf, y->inf);
   }
   if(y->sup == INFINITY){
      mpq_set_d(_y.sup, 2*FLT_MAX);
   } else {
      mpq_set_d(_y.sup, y->sup);
   }
   mpq_set_d(one, 1.0f);
   
   /* x + ex */
   mpq_add(tmp1, _x.inf, ex->inf);
   mpq_add(tmp2, _x.sup, ex->sup);
   
   /* 1 / (x+ex) */
   mpq_div(divM, one, tmp1);
   mpq_div(divm, one, tmp2);
   
   /* y * ex */
   mpq_mul(tmp1, _y.inf, ex->inf);
   mpq_mul(tmp2, _y.inf, ex->sup);
   mpq_mul(tmp1, _y.sup, ex->inf);
   mpq_mul(tmp2, _y.sup, ex->sup);
   
   minError(&mulm, &tmp1, &tmp2);
   minError(&mulm, &mulm, &tmp1);
   minError(&mulm, &mulm, &tmp2);
   
   maxError(&mulM, &tmp1, &tmp2);
   maxError(&mulM, &mulM, &tmp1);
   maxError(&mulM, &mulM, &tmp2);
   
   /* ez - (y*ex) */
   mpq_sub(tmp1, ez->inf, mulM);
   mpq_sub(tmp2, ez->sup, mulm);
   
   /* ez-(y*ex) - eo */
   mpq_sub(tmp1, tmp1, eo->sup);
   mpq_sub(tmp2, tmp2, eo->inf);
   
   /* (1/(x+ex)) * (ez-(y*ex)-eo) */
   mpq_mul(tmp3, tmp1, divm);
   mpq_mul(tmp4, tmp2, divm);
   mpq_mul(tmp3, tmp1, divM);
   mpq_mul(tmp4, tmp2, divM);
   
   
   minError(&mulm, &tmp3, &tmp4);
   minError(&mulm, &mulm, &tmp3);
   minError(&mulm, &mulm, &tmp4);
   
   maxError(&mulM, &tmp3, &tmp4);
   maxError(&mulM, &mulM, &tmp3);
   maxError(&mulM, &mulM, &tmp4);
   
   /* update ey bounds */
   mpq_set(ey->inf, mulm);
   mpq_set(ey->sup, mulM);
   
   mpq_clears(_x.inf, _x.sup, _y.inf, _y.sup, tmp1, tmp2, tmp3, tmp4, one, divm, divM, mulm, mulM, NULL);
}

void mulR_inv_eo(rational_interval* eo, rational_interval* ez, rational_interval* ex, rational_interval* ey, float_interval* x, float_interval* y){
   rational_interval _x, _y;
   ORRational tmp1, tmp2, tmp3, tmp4, mulm1, mulm2, mulm3, mulM1, mulM2, mulM3;
   
   mpq_inits(_x.inf, _x.sup, _y.inf, _y.sup, tmp1, tmp2, tmp3, tmp4, mulm1, mulm2, mulm3, mulM1, mulM2, mulM3, NULL);
   
   if(x->inf == -INFINITY){
      mpq_set_d(_x.inf, -2*FLT_MAX);
   } else {
      mpq_set_d(_x.inf, x->inf);
   }
   if(x->sup == INFINITY){
      mpq_set_d(_x.sup, 2*FLT_MAX);
   } else {
      mpq_set_d(_x.sup, x->sup);
   }
   if(y->inf == -INFINITY){
      mpq_set_d(_y.inf, -2*FLT_MAX);
   } else {
      mpq_set_d(_y.inf, y->inf);
   }
   if(y->sup == INFINITY){
      mpq_set_d(_y.sup, 2*FLT_MAX);
   } else {
      mpq_set_d(_y.sup, y->sup);
   }
   
   /* y * ex */
   mpq_mul(tmp1, _y.inf, ex->inf);
   mpq_mul(tmp2, _y.inf, ex->sup);
   mpq_mul(tmp3, _y.sup, ex->inf);
   mpq_mul(tmp4, _y.sup, ex->sup);
   
   minError(&mulm1, &tmp1, &tmp2);
   minError(&mulm1, &mulm1, &tmp3);
   minError(&mulm1, &mulm1, &tmp4);
   
   maxError(&mulM1, &tmp1, &tmp2);
   maxError(&mulM1, &mulM1, &tmp3);
   maxError(&mulM1, &mulM1, &tmp4);
   
   /* x * ey */
   mpq_mul(tmp1, _x.inf, ey->inf);
   mpq_mul(tmp2, _x.inf, ey->sup);
   mpq_mul(tmp3, _x.sup, ey->inf);
   mpq_mul(tmp4, _x.sup, ey->sup);
   
   minError(&mulm2, &tmp1, &tmp2);
   minError(&mulm2, &mulm2, &tmp3);
   minError(&mulm2, &mulm2, &tmp4);
   
   maxError(&mulM2, &tmp1, &tmp2);
   maxError(&mulM2, &mulM2, &tmp3);
   maxError(&mulM2, &mulM2, &tmp4);
   
   /* ex * ey */
   mpq_mul(tmp1, ey->inf, ex->inf);
   mpq_mul(tmp2, ey->inf, ex->sup);
   mpq_mul(tmp3, ey->sup, ex->inf);
   mpq_mul(tmp4, ey->sup, ex->sup);
   
   minError(&mulm3, &tmp1, &tmp2);
   minError(&mulm3, &mulm3, &tmp3);
   minError(&mulm3, &mulm3, &tmp4);
   
   maxError(&mulM3, &tmp1, &tmp2);
   maxError(&mulM3, &mulM3, &tmp3);
   maxError(&mulM3, &mulM3, &tmp4);
   
   /* ez - (y*ex) */
   mpq_sub(tmp1, ez->inf, mulM1);
   mpq_sub(tmp2, ez->sup, mulm1);
   
   /* ez-(y*ex) - (x*ey) */
   mpq_sub(tmp1, tmp1, mulM2);
   mpq_sub(tmp2, tmp2, mulm2);
   
   /* ez-(y*ex)-(x*ey) - (ex*ey) */
   mpq_sub(tmp1, tmp1, mulM3);
   mpq_sub(tmp2, tmp2, mulm3);
   
   /* update eo bounds */
   mpq_set(eo->inf, tmp1);
   mpq_set(eo->sup, tmp2);
   
   mpq_clears(_x.inf, _x.sup, _y.inf, _y.sup, tmp1, tmp2, tmp3, tmp4, mulm1, mulm2, mulm3, mulM1, mulM2, mulM3, NULL);
}

void divR(rational_interval* ez, rational_interval* ex, rational_interval* ey, rational_interval* eo, float_interval* x, float_interval* y){
   rational_interval _x, _y;
   ORRational one, tmp1, tmp2, tmp3, tmp4, tmp5, tmp6, mulm1, mulm2, mulm3, mulM1, mulM2, mulM3, divm, divM;
   
   mpq_inits(_x.inf, _x.sup, _y.inf, _y.sup, one, tmp1, tmp2, tmp3, tmp4, tmp5, tmp6, mulm1, mulm2, mulm3, mulM1, mulM2, mulM3, divm, divM, NULL);
   
   if(x->inf == -INFINITY){
      mpq_set_d(_x.inf, -2*FLT_MAX);
   } else {
      mpq_set_d(_x.inf, x->inf);
   }
   if(x->sup == INFINITY){
      mpq_set_d(_x.sup, 2*FLT_MAX);
   } else {
      mpq_set_d(_x.sup, x->sup);
   }
   if(y->inf == -INFINITY){
      mpq_set_d(_y.inf, -2*FLT_MAX);
   } else {
      mpq_set_d(_y.inf, y->inf);
   }
   if(y->sup == INFINITY){
      mpq_set_d(_y.sup, 2*FLT_MAX);
   } else {
      mpq_set_d(_y.sup, y->sup);
   }
   mpq_set_d(one, 1.0f);
   
   /* y * ex */
   mpq_mul(tmp1, _y.inf, ex->inf);
   mpq_mul(tmp2, _y.inf, ex->sup);
   mpq_mul(tmp3, _y.sup, ex->inf);
   mpq_mul(tmp4, _y.sup, ex->sup);
   
   minError(&mulm1, &tmp1, &tmp2);
   minError(&mulm1, &mulm1, &tmp3);
   minError(&mulm1, &mulm1, &tmp4);
   
   maxError(&mulM1, &tmp1, &tmp2);
   maxError(&mulM1, &mulM1, &tmp3);
   maxError(&mulM1, &mulM1, &tmp4);
   
   /* x * ey */
   mpq_mul(tmp1, _x.inf, ey->inf);
   mpq_mul(tmp2, _x.inf, ey->sup);
   mpq_mul(tmp3, _x.sup, ey->inf);
   mpq_mul(tmp4, _x.sup, ey->sup);
   
   minError(&mulm2, &tmp1, &tmp2);
   minError(&mulm2, &mulm2, &tmp3);
   minError(&mulm2, &mulm2, &tmp4);
   
   maxError(&mulM2, &tmp1, &tmp2);
   maxError(&mulM2, &mulM2, &tmp3);
   maxError(&mulM2, &mulM2, &tmp4);
   
   /* y + ey */
   mpq_add(tmp1, _y.inf, ey->inf);
   mpq_add(tmp2, _y.sup, ey->sup);
   
   /* y * (y+ey) */
   mpq_mul(tmp3, _y.inf, tmp1);
   mpq_mul(tmp4, _y.sup, tmp1);
   mpq_mul(tmp1, _y.inf, tmp2);
   mpq_mul(tmp2, _y.sup, tmp2);
   
   minError(&mulm3, &tmp1, &tmp2);
   minError(&mulm3, &mulm3, &tmp3);
   minError(&mulm3, &mulm3, &tmp4);
   
   maxError(&mulM3, &tmp1, &tmp2);
   maxError(&mulM3, &mulM3, &tmp3);
   maxError(&mulM3, &mulM3, &tmp4);
   
   /* 1 / (y*(y+ey)) */
   mpq_div(divM, one, mulm3);
   mpq_div(divm, one, mulM3);
   
   /* (y*ex) -  (x*ey) */
   mpq_sub(tmp1, mulm1, mulM2);
   mpq_sub(tmp2, mulM1, mulm2);
   
   /* ((y*ex)-(x*ey)) * (1/(y*(y+ey))) */
   mpq_mul(tmp5, tmp1, divm);
   mpq_mul(tmp6, tmp1, divM);
   mpq_mul(tmp3, tmp2, divm);
   mpq_mul(tmp4, tmp2, divM);
   
   minError(&mulm1, &tmp3, &tmp4);
   minError(&mulm1, &mulm1, &tmp5);
   minError(&mulm1, &mulm1, &tmp6);
   
   maxError(&mulM1, &tmp3, &tmp4);
   maxError(&mulM1, &mulM1, &tmp5);
   maxError(&mulM1, &mulM1, &tmp6);
   
   /* (((y*ex)-(x*ey))*(1/(y*(y+ey)))) + eo */
   mpq_add(tmp1, mulm1, eo->inf);
   mpq_add(tmp2, mulM1, eo->sup);
   
   /* update ez bounds */
   mpq_set(ez->inf, tmp1);
   mpq_set(ez->sup, tmp2);
   mpq_clears(_x.inf, _x.sup, _y.inf, _y.sup, one, tmp1, tmp2, tmp3, tmp4, tmp5, tmp6, mulm1, mulm2, mulm3, mulM1, mulM2, mulM3, divm, divM, NULL);
}

void divR_inv_ex(rational_interval* ex, rational_interval* ez, rational_interval* ey, rational_interval* eo, float_interval* x, float_interval* y){
   rational_interval _x, _y;
   ORRational one, tmp1, tmp2, tmp3, tmp4, tmp5, tmp6, mulm1, mulm2, mulM1, mulM2, divm, divM;
   
   mpq_inits(_x.inf, _x.sup, _y.inf, _y.sup, one, tmp1, tmp2, tmp3, tmp4, tmp5, tmp6, mulm1, mulm2, mulM1, mulM2, divm, divM, NULL);
   
   if(x->inf == -INFINITY){
      mpq_set_d(_x.inf, -2*FLT_MAX);
   } else {
      mpq_set_d(_x.inf, x->inf);
   }
   if(x->sup == INFINITY){
      mpq_set_d(_x.sup, 2*FLT_MAX);
   } else {
      mpq_set_d(_x.sup, x->sup);
   }
   if(y->inf == -INFINITY){
      mpq_set_d(_y.inf, -2*FLT_MAX);
   } else {
      mpq_set_d(_y.inf, y->inf);
   }
   if(y->sup == INFINITY){
      mpq_set_d(_y.sup, 2*FLT_MAX);
   } else {
      mpq_set_d(_y.sup, y->sup);
   }
   mpq_set_d(one, 1.0f);
   
   /* ez - eo */
   mpq_sub(tmp1, ez->inf, eo->sup);
   mpq_sub(tmp2, ez->sup, eo->inf);
   
   /* y + ey */
   mpq_add(tmp3, _y.inf, ey->inf);
   mpq_add(tmp4, _y.sup, ey->sup);
   
   /* (ez-eo) * (y+ey) */
   mpq_mul(tmp5, tmp1, tmp3);
   mpq_mul(tmp6, tmp1, tmp4);
   mpq_mul(tmp1, tmp2, tmp3);
   mpq_mul(tmp3, tmp2, tmp4);
   
   minError(&mulm1, &tmp5, &tmp6);
   minError(&mulm1, &mulm1, &tmp1);
   minError(&mulm1, &mulm1, &tmp3);
   
   maxError(&mulM1, &tmp5, &tmp6);
   maxError(&mulM1, &mulM1, &tmp1);
   maxError(&mulM1, &mulM1, &tmp3);
   
   /* x * ey */
   mpq_mul(tmp1, _x.inf, ey->inf);
   mpq_mul(tmp2, _x.inf, ey->sup);
   mpq_mul(tmp3, _x.sup, ey->inf);
   mpq_mul(tmp4, _x.sup, ey->sup);
   
   minError(&mulm2, &tmp1, &tmp2);
   minError(&mulm2, &mulm2, &tmp3);
   minError(&mulm2, &mulm2, &tmp4);
   
   maxError(&mulM2, &tmp1, &tmp2);
   maxError(&mulM2, &mulM2, &tmp3);
   maxError(&mulM2, &mulM2, &tmp4);
   
   /* 1 / y */
   mpq_div(divM, one, _y.inf);
   mpq_div(divm, one, _y.sup);
   
   /* (x*ey) * (1/y) */
   mpq_mul(tmp1, mulm2, divm);
   mpq_mul(tmp2, mulm2, divM);
   mpq_mul(tmp3, mulM2, divm);
   mpq_mul(tmp4, mulM2, divM);
   
   minError(&mulm2, &tmp1, &tmp2);
   minError(&mulm2, &mulm2, &tmp3);
   minError(&mulm2, &mulm2, &tmp4);
   
   maxError(&mulM2, &tmp1, &tmp2);
   maxError(&mulM2, &mulM2, &tmp3);
   maxError(&mulM2, &mulM2, &tmp4);
   
   /* (ez-eo)*(y+ey) + (x*ey)*(1/y) */
   mpq_add(tmp1, mulm1, mulm2);
   mpq_add(tmp2, mulM1, mulM2);
   
   /* update ex bounds */
   mpq_set(ex->inf, tmp1);
   mpq_set(ex->sup, tmp2);
   mpq_inits(_x.inf, _x.sup, _y.inf, _y.sup, one, tmp1, tmp2, tmp3, tmp4, tmp5, tmp6, mulm1, mulm2, mulM1, mulM2, divm, divM, NULL);
}

void divR_inv_ey(rational_interval* ey, rational_interval* ez, rational_interval* ex, rational_interval* eo, float_interval* x, float_interval* y){
   rational_interval _x, _y;
   ORRational one, tmp1, tmp2, tmp3, tmp4, tmp5, tmp6, mulm1, mulm2, mulM1, mulM2, divm, divM;
   
   mpq_inits(_x.inf, _x.sup, _y.inf, _y.sup, one, tmp1, tmp2, tmp3, tmp4, tmp5, tmp6, mulm1, mulm2, mulM1, mulM2, divm, divM, NULL);

   if(x->inf == -INFINITY){
      mpq_set_d(_x.inf, -2*FLT_MAX);
   } else {
      mpq_set_d(_x.inf, x->inf);
   }
   if(x->sup == INFINITY){
      mpq_set_d(_x.sup, 2*FLT_MAX);
   } else {
      mpq_set_d(_x.sup, x->sup);
   }
   if(y->inf == -INFINITY){
      mpq_set_d(_y.inf, -2*FLT_MAX);
   } else {
      mpq_set_d(_y.inf, y->inf);
   }
   if(y->sup == INFINITY){
      mpq_set_d(_y.sup, 2*FLT_MAX);
   } else {
      mpq_set_d(_y.sup, y->sup);
   }
   mpq_set_d(one, 1.0f);
   
   /* ez * y */
   mpq_mul(tmp1, ez->inf, _y.inf);
   mpq_mul(tmp2, ez->inf, _y.sup);
   mpq_mul(tmp3, ez->sup, _y.inf);
   mpq_mul(tmp4, ez->sup, _y.sup);
   
   minError(&mulm1, &tmp1, &tmp2);
   minError(&mulm1, &mulm1, &tmp3);
   minError(&mulm1, &mulm1, &tmp4);
   
   maxError(&mulM1, &tmp1, &tmp2);
   maxError(&mulM1, &mulM1, &tmp3);
   maxError(&mulM1, &mulM1, &tmp4);
   
   /* eo * y */
   mpq_mul(tmp1, eo->inf, _y.inf);
   mpq_mul(tmp2, eo->inf, _y.sup);
   mpq_mul(tmp3, eo->sup, _y.inf);
   mpq_mul(tmp4, eo->sup, _y.sup);
   
   minError(&mulm2, &tmp1, &tmp2);
   minError(&mulm2, &mulm2, &tmp3);
   minError(&mulm2, &mulm2, &tmp4);
   
   maxError(&mulM2, &tmp1, &tmp2);
   maxError(&mulM2, &mulM2, &tmp3);
   maxError(&mulM2, &mulM2, &tmp4);
   
   /* ex - ez*y */
   mpq_sub(tmp1, ex->inf, mulM1);
   mpq_sub(tmp2, ex->sup, mulm1);
   
   /* ex-(ez*y) + eo*y */
   mpq_add(tmp1, tmp1, mulm2);
   mpq_add(tmp2, tmp2, mulM2);
   
   /* 1 / y */
   mpq_div(divM, one, _y.inf);
   mpq_div(divm, one, _y.sup);
   
   /* x * (1/y) */
   mpq_mul(tmp3, _x.inf, divm);
   mpq_mul(tmp4, _x.inf, divM);
   mpq_mul(tmp5, _x.sup, divm);
   mpq_mul(tmp6, _x.sup, divM);
   
   minError(&mulm1, &tmp3, &tmp4);
   minError(&mulm1, &mulm1, &tmp5);
   minError(&mulm1, &mulm1, &tmp6);
   
   maxError(&mulM1, &tmp3, &tmp4);
   maxError(&mulM1, &mulM1, &tmp5);
   maxError(&mulM1, &mulM1, &tmp6);
   
   /* ez - eo */
   mpq_sub(tmp3, ez->inf, eo->sup);
   mpq_sub(tmp4, ez->sup, eo->inf);
   
   /* ez-eo - x*(1/y) */
   mpq_sub(tmp3, tmp3, mulM1);
   mpq_sub(tmp4, tmp4, mulm1);
   
   /* 1 / (ez-eo-(x*(1/y))) */
   mpq_div(divM, one, tmp3);
   mpq_div(divm, one, tmp4);
   
   /* (ex-(ez*y)+eo*y) * (1/(ez-eo-(x*(1/y)))) */
   mpq_mul(tmp5, tmp1, tmp3);
   mpq_mul(tmp6, tmp1, tmp4);
   mpq_mul(tmp3, tmp2, tmp3);
   mpq_mul(tmp4, tmp2, tmp4);
   
   minError(&mulm1, &tmp3, &tmp4);
   minError(&mulm1, &mulm1, &tmp5);
   minError(&mulm1, &mulm1, &tmp6);
   
   maxError(&mulM1, &tmp3, &tmp4);
   maxError(&mulM1, &mulM1, &tmp5);
   maxError(&mulM1, &mulM1, &tmp6);
   
   /* update ey bounds */
   mpq_set(ey->inf, mulm1);
   mpq_set(ey->sup, mulM1);
   mpq_clears(_x.inf, _x.sup, _y.inf, _y.sup, one, tmp1, tmp2, tmp3, tmp4, tmp5, tmp6, mulm1, mulm2, mulM1, mulM2, divm, divM, NULL);
}

void divR_inv_eo(rational_interval* eo, rational_interval* ez, rational_interval* ex, rational_interval* ey, float_interval* x, float_interval* y){
   rational_interval _x, _y;
   ORRational one, tmp1, tmp2, tmp3, tmp4, tmp5, tmp6, mulm1, mulm2, mulm3, mulM1, mulM2, mulM3, divm, divM;
   
   mpq_inits(_x.inf, _x.sup, _y.inf, _y.sup, one, tmp1, tmp2, tmp3, tmp4, tmp5, tmp6, mulm1, mulm2, mulm3, mulM1, mulM2, mulM3, divm, divM, NULL);
   
   if(x->inf == -INFINITY){
      mpq_set_d(_x.inf, -2*FLT_MAX);
   } else {
      mpq_set_d(_x.inf, x->inf);
   }
   if(x->sup == INFINITY){
      mpq_set_d(_x.sup, 2*FLT_MAX);
   } else {
      mpq_set_d(_x.sup, x->sup);
   }
   if(y->inf == -INFINITY){
      mpq_set_d(_y.inf, -2*FLT_MAX);
   } else {
      mpq_set_d(_y.inf, y->inf);
   }
   if(y->sup == INFINITY){
      mpq_set_d(_y.sup, 2*FLT_MAX);
   } else {
      mpq_set_d(_y.sup, y->sup);
   }
   mpq_set_d(one, 1.0f);
   
   /* y * ex */
   mpq_mul(tmp1, _y.inf, ex->inf);
   mpq_mul(tmp2, _y.inf, ex->sup);
   mpq_mul(tmp3, _y.sup, ex->inf);
   mpq_mul(tmp4, _y.sup, ex->sup);
   
   minError(&mulm1, &tmp1, &tmp2);
   minError(&mulm1, &mulm1, &tmp3);
   minError(&mulm1, &mulm1, &tmp4);
   
   maxError(&mulM1, &tmp1, &tmp2);
   maxError(&mulM1, &mulM1, &tmp3);
   maxError(&mulM1, &mulM1, &tmp4);
   
   /* x * ey */
   mpq_mul(tmp1, _x.inf, ey->inf);
   mpq_mul(tmp2, _x.inf, ey->sup);
   mpq_mul(tmp3, _x.sup, ey->inf);
   mpq_mul(tmp4, _x.sup, ey->sup);
   
   minError(&mulm2, &tmp1, &tmp2);
   minError(&mulm2, &mulm2, &tmp3);
   minError(&mulm2, &mulm2, &tmp4);
   
   maxError(&mulM2, &tmp1, &tmp2);
   maxError(&mulM2, &mulM2, &tmp3);
   maxError(&mulM2, &mulM2, &tmp4);
   
   /* y + ey */
   mpq_add(tmp1, _y.inf, ey->inf);
   mpq_add(tmp2, _y.sup, ey->sup);
   
   /* y * (y+ey) */
   mpq_mul(tmp3, _y.inf, tmp1);
   mpq_mul(tmp4, _y.sup, tmp1);
   mpq_mul(tmp1, _y.inf, tmp2);
   mpq_mul(tmp2, _y.sup, tmp2);
   
   minError(&mulm3, &tmp1, &tmp2);
   minError(&mulm3, &mulm3, &tmp3);
   minError(&mulm3, &mulm3, &tmp4);
   
   maxError(&mulM3, &tmp1, &tmp2);
   maxError(&mulM3, &mulM3, &tmp3);
   maxError(&mulM3, &mulM3, &tmp4);
   
   /* 1 / (y*(y+ey)) */
   mpq_div(divM, one, mulm3);
   mpq_div(divm, one, mulM3);
   
   /* (y*ex) -  (x*ey) */
   mpq_sub(tmp1, mulm1, mulM2);
   mpq_sub(tmp2, mulM1, mulm2);
   
   /* ((y*ex)-(x*ey)) * (1/(y*(y+ey))) */
   mpq_mul(tmp5, tmp1, divm);
   mpq_mul(tmp6, tmp1, divM);
   mpq_mul(tmp3, tmp2, divm);
   mpq_mul(tmp4, tmp2, divM);
   
   minError(&mulm1, &tmp3, &tmp4);
   minError(&mulm1, &mulm1, &tmp5);
   minError(&mulm1, &mulm1, &tmp6);
   
   maxError(&mulM1, &tmp3, &tmp4);
   maxError(&mulM1, &mulM1, &tmp5);
   maxError(&mulM1, &mulM1, &tmp6);
   
   /* ez - (((y*ex)-(x*ey))*(1/(y*(y+ey)))) */
   mpq_sub(tmp1, ez->inf, mulM1);
   mpq_sub(tmp2, ez->sup, mulm1);
   
   /* update eo bounds */
   mpq_set(eo->inf, tmp1);
   mpq_set(eo->sup, tmp2);
   
   mpq_clears(_x.inf, _x.sup, _y.inf, _y.sup, one, tmp1, tmp2, tmp3, tmp4, tmp5, tmp6, mulm1, mulm2, mulm3, mulM1, mulM2, mulM3, divm, divM, NULL);
}

void compute_eo_add(rational_interval* eo, rational_interval* eoTemp, float_interval x, float_interval y, float_interval z){
   intersectionIntervalError interError;
   mpq_inits(interError.result.inf,interError.result.sup,interError.interval.inf,interError.interval.sup,NULL);
   if((!same_sign(x.inf, y.inf) && !same_sign(x.sup, y.sup)) &&
      ((y.inf/2.0f <= x.inf) && (y.sup/2.0f <= x.sup)) &&
      ((x.inf <= y.inf*2.0f) && (x.sup <= y.sup*2.0f))){
      ORRational zero;
      mpq_init(zero);
      mpq_set_d(zero, 0.0f);
      makeRationalInterval(eoTemp, zero, zero);
      mpq_clear(zero);
   } else if((x.inf == x.sup) && (y.inf == y.sup)){
      ORRational tmp_eo_r, tmp_eo_fi_r;
      ORFloat tmp_eo_fi;
      
      mpq_inits(tmp_eo_r,tmp_eo_fi_r,NULL);
      
      tmp_eo_fi = x.inf + y.inf;
      
      mpq_set_d(tmp_eo_r, x.inf);
      mpq_set_d(tmp_eo_fi_r, y.inf);
      mpq_add(tmp_eo_r,  tmp_eo_r, tmp_eo_fi_r);
      
      mpq_set_d(tmp_eo_fi_r, tmp_eo_fi);
      mpq_sub(tmp_eo_r, tmp_eo_r, tmp_eo_fi_r);
      
      makeRationalInterval(eoTemp, tmp_eo_r, tmp_eo_r);
      
      mpq_clears(tmp_eo_r, tmp_eo_fi_r, NULL);
      
   }
   else {
      double_interval ulp_f;
      ORRational ulp, ulp_neg;
      mpq_inits(ulp, ulp_neg,  NULL);
      ulp_f = ulp_computation(z);
      mpq_set_d(ulp, ulp_f.sup);
      mpq_set_d(ulp_neg, ulp_f.inf);
      makeRationalInterval(eoTemp, ulp_neg, ulp);
      mpq_clears(ulp, ulp_neg, NULL);
   }
   intersectionError(&interError, *eo, *eoTemp);
   if(interError.changed)
      makeRationalInterval(eo, interError.result.inf, interError.result.sup);
   mpq_clears(interError.result.inf,interError.result.sup,interError.interval.inf,interError.interval.sup,NULL);
}

void compute_eo_sub(rational_interval* eo, rational_interval* eoTemp, float_interval x, float_interval y, float_interval z){
   intersectionIntervalError interError;
   mpq_inits(interError.result.inf,interError.result.sup,interError.interval.inf,interError.interval.sup,NULL);
   if((same_sign(x.inf, y.inf) && same_sign(x.sup, y.sup)) &&
      ((y.sup/2.0f <= x.inf) && (y.sup/2.0f <= x.sup)) &&
      ((x.inf <= y.inf*2.0f) && (x.sup <= y.inf*2.0f))){
      ORRational zero;
      mpq_init(zero);
      mpq_set_d(zero, 0.0f);
      makeRationalInterval(eoTemp, zero, zero);
      mpq_clear(zero);
   } else if(x.inf == x.sup && y.inf == y.sup){
      /* compute eo interval with substraction from op on rational and op on float */
      ORRational tmp_eo_r, tmp_eo_fi_r;
      ORFloat tmp_eo_fi;
      mpq_inits(tmp_eo_r,tmp_eo_fi_r,NULL);
      
      tmp_eo_fi = x.inf - y.sup;
      
      mpq_set_d(tmp_eo_r, x.inf);
      mpq_set_d(tmp_eo_fi_r, y.sup);
      mpq_sub(tmp_eo_r,  tmp_eo_r, tmp_eo_fi_r);
      
      mpq_set_d(tmp_eo_fi_r, tmp_eo_fi);
      mpq_sub(tmp_eo_r, tmp_eo_r, tmp_eo_fi_r);
      
      makeRationalInterval(eoTemp, tmp_eo_r, tmp_eo_r);
      
      mpq_clears(tmp_eo_r, tmp_eo_fi_r, NULL);
   } else {
      double_interval ulp_f;
      ORRational ulp, ulp_neg;
      mpq_inits(ulp, ulp_neg,  NULL);
      ulp_f = ulp_computation(z);
      mpq_set_d(ulp, ulp_f.sup);
      mpq_set_d(ulp_neg, ulp_f.inf);
      makeRationalInterval(eoTemp, ulp_neg, ulp);
      mpq_clears(ulp, ulp_neg, NULL);
   }
   intersectionError(&interError, *eo, *eoTemp);
   if(interError.changed)
      makeRationalInterval(eo, interError.result.inf, interError.result.sup);
   mpq_clears(interError.result.inf,interError.result.sup,interError.interval.inf,interError.interval.sup,NULL);
}

void compute_eo_mul(rational_interval* eo, rational_interval* eoTemp, float_interval x, float_interval y, float_interval z){
   intersectionIntervalError interError;
   mpq_inits(interError.result.inf,interError.result.sup,interError.interval.inf,interError.interval.sup,NULL);
   if(x.inf == x.sup && y.inf == y.sup){
      ORRational tmp_eo_r, tmp_eo_fi_r, tmp_eo_r_s, tmp_eo_fi_r_s, tmp1, tmp2, tmp3, tmp4;
      ORFloat tmp_eo_fi;
      mpq_inits(tmp_eo_r,tmp_eo_fi_r,tmp_eo_r_s, tmp_eo_fi_r_s,tmp1, tmp2, tmp3, tmp4, NULL);
      
      tmp_eo_fi = minFlt(minFlt(x.inf * y.inf, x.inf * y.sup),minFlt(x.sup * y.inf, x.sup * y.sup));
      mpq_set_d(tmp_eo_r, x.inf);
      mpq_set_d(tmp_eo_fi_r, y.inf);
      mpq_set_d(tmp_eo_r_s, x.sup);
      mpq_set_d(tmp_eo_fi_r_s, y.sup);
      mpq_mul(tmp1, tmp_eo_r, tmp_eo_fi_r);
      mpq_mul(tmp2, tmp_eo_r, tmp_eo_fi_r_s);
      mpq_mul(tmp3, tmp_eo_r_s, tmp_eo_fi_r);
      mpq_mul(tmp4, tmp_eo_r_s, tmp_eo_fi_r_s);
      
      minError(&tmp_eo_r, &tmp1, &tmp2);
      minError(&tmp_eo_r, &tmp_eo_r, &tmp3);
      minError(&tmp_eo_r, &tmp_eo_r, &tmp4);
      
      mpq_set_d(tmp_eo_fi_r, tmp_eo_fi);
      mpq_sub(tmp_eo_r, tmp_eo_r, tmp_eo_fi_r);
      
      makeRationalInterval(eoTemp, tmp_eo_r, tmp_eo_r);
      mpq_clears(tmp_eo_r, tmp_eo_fi_r,tmp_eo_r_s, tmp_eo_fi_r_s, tmp1, tmp2, tmp3, tmp4, NULL);
   }
   else {
      double_interval ulp_f;
      ORRational ulp, ulp_neg;
      mpq_inits(ulp, ulp_neg,  NULL);
      ulp_f = ulp_computation(z);
      mpq_set_d(ulp, ulp_f.sup);
      mpq_set_d(ulp_neg, ulp_f.inf);
      makeRationalInterval(eoTemp, ulp_neg, ulp);
      mpq_clears(ulp, ulp_neg, NULL);
   }
   intersectionError(&interError, *eo, *eoTemp);
   if(interError.changed)
      makeRationalInterval(eo, interError.result.inf, interError.result.sup);
   mpq_clears(interError.result.inf,interError.result.sup,interError.interval.inf,interError.interval.sup,NULL);
}

void compute_eo_div(rational_interval* eo, rational_interval* eoTemp, float_interval x, float_interval y, float_interval z){
   intersectionIntervalError interError;
   mpq_inits(interError.result.inf,interError.result.sup,interError.interval.inf,interError.interval.sup,NULL);
   if(x.inf == x.sup && y.inf == y.sup){
      ORRational tmp_eo_r, tmp_eo_fi_r,tmp_eo_r_s, tmp_eo_fi_r_s, tmp1, tmp2, tmp3, tmp4;
      ORFloat tmp_eo_fi;
      mpq_inits(tmp_eo_r,tmp_eo_fi_r, tmp_eo_r_s, tmp_eo_fi_r_s, tmp1, tmp2, tmp3, tmp4, NULL);
      
      tmp_eo_fi = minFlt(minFlt(x.inf / y.inf, x.inf / y.sup),minFlt(x.sup / y.inf, x.sup / y.sup));
      mpq_set_d(tmp_eo_r, x.inf);
      mpq_set_d(tmp_eo_fi_r, y.inf);
      mpq_set_d(tmp_eo_r_s, x.sup);
      mpq_set_d(tmp_eo_fi_r_s, y.sup);
      mpq_div(tmp1, tmp_eo_r, tmp_eo_fi_r);
      mpq_div(tmp2, tmp_eo_r, tmp_eo_fi_r_s);
      mpq_div(tmp3, tmp_eo_r_s, tmp_eo_fi_r);
      mpq_div(tmp4, tmp_eo_r_s, tmp_eo_fi_r_s);
      
      minError(&tmp_eo_r, &tmp1, &tmp2);
      minError(&tmp_eo_r, &tmp_eo_r, &tmp3);
      minError(&tmp_eo_r, &tmp_eo_r, &tmp4);
      
      mpq_set_d(tmp_eo_fi_r, tmp_eo_fi);
      mpq_sub(tmp_eo_r, tmp_eo_r, tmp_eo_fi_r);
      
      makeRationalInterval(eoTemp, tmp_eo_r, tmp_eo_r);
      
      mpq_clears(tmp_eo_r, tmp_eo_fi_r,tmp_eo_r_s, tmp_eo_fi_r_s, tmp1, tmp2, tmp3, tmp4, NULL);
   }
   else {
      double_interval ulp_f;
      ORRational ulp, ulp_neg;
      mpq_inits(ulp, ulp_neg,  NULL);
      ulp_f = ulp_computation(z);
      mpq_set_d(ulp, ulp_f.sup);
      mpq_set_d(ulp_neg, ulp_f.inf);
      makeRationalInterval(eoTemp, ulp_neg, ulp);
      mpq_clears(ulp, ulp_neg, NULL);
   }
   intersectionError(&interError, *eo, *eoTemp);
   if(interError.changed)
      makeRationalInterval(eo, interError.result.inf, interError.result.sup);
   mpq_clears(interError.result.inf,interError.result.sup,interError.interval.inf,interError.interval.sup,NULL);
}

@implementation CPFloatEqual
-(id) init:(CPFloatVarI*)x equals:(CPFloatVarI*)y
{
   self = [super initCPCoreConstraint: [x engine]];
   _x = x;
   _y = y;
   return self;
}
-(void) post
{
   [self propagate];
   if(![_x bound])  [_x whenChangeBoundsPropagate:self];
   if(![_y bound])  [_y whenChangeBoundsPropagate:self];
}
-(void) propagate
{
   if([_x bound]){
      //hzi : if x in [-0.0,0.0]f : x is bound, but value return x.min
      //the domain of y must stay  [-0.0,0.0]f and not just -0.0f
      if(is_eqf([_x min],-0.0f) && is_eqf([_x max],+0.0f))
         [_y updateInterval:[_x min] and:[_x max]];
      else
         [_y bind:[_x value]];
      assignTRInt(&_active, NO, _trail);
      return;
   }else if([_y bound]){
      if(is_eqf([_y min],-0.0f) && is_eqf([_y max],+0.0f))
         [_x updateInterval:[_y min] and:[_y max]];
      else
         [_x bind:[_y value]];
      assignTRInt(&_active, NO, _trail);
      return;
   }
   if(isDisjointWith(_x,_y)){
      failNow();
   }else{
      ORFloat min = maxFlt([_x min], [_y min]);
      ORFloat max = minFlt([_x max], [_y max]);
      [_x updateInterval:min and:max];
      [_y updateInterval:min and:max];
   }
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_y,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_y bound];
}
-(NSString*)description
{
   return [NSString stringWithFormat:@"<%@ == %@>",_x,_y];
}
@end

@implementation CPFloatEqualc
-(id) init:(CPFloatVarI*)x and:(ORFloat)c
{
   self = [super initCPCoreConstraint: [x engine]];
   _x = x;
   _c = c;
   return self;
   
}
-(void) post
{
   //hzi : equality constraint is different from assignment constraint for 0.0
   //in case when check equality -0.0f == 0.0f
   //in case of assignement x = -0.0f != from x = 0.0f
   if(is_eqf(_c,0.f))
      [_x updateInterval:-0.0f and:+0.0f];
   else
      [_x bind:_c];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_x bound];
}
-(NSString*)description
{
   return [NSString stringWithFormat:@"<%@ == %16.16e>",_x,_c];
}
@end

@implementation CPFloatAssign{
   int _precision;
   int _rounding;
   float_interval _xi;
   float_interval _yi;
   rational_interval _exi;
   rational_interval _eyi;
}
-(id) init:(CPFloatVarI*)x set:(CPFloatVarI*)y
{
   self = [super initCPCoreConstraint: [x engine]];
   _x = x;
   _y = y;
   _xi = makeFloatInterval(x.min, x.max);
   _yi = makeFloatInterval(y.min, y.max);
   mpq_inits(_exi.inf, _exi.sup, _eyi.inf, _eyi.sup, NULL);
   makeRationalInterval(&_exi, *x.minErr, *x.maxErr);
   makeRationalInterval(&_eyi, *y.minErr, *y.maxErr);
   _precision = 1;
   _rounding = FE_TONEAREST;
   return self;
}
-(void) post
{
   [self propagate];
   if(![_x bound] || ![_x boundError])  [_x whenChangeBoundsPropagate:self];
   if(![_y bound] || ![_y boundError])  [_y whenChangeBoundsPropagate:self];
}
-(void) propagate
{
   updateFloatInterval(&_xi,_x);
   updateFloatInterval(&_yi,_y);
   updateRationalInterval(&_exi,_x);
   updateRationalInterval(&_eyi,_y);
   intersectionInterval inter;
   intersectionIntervalError interError;
   mpq_inits(interError.interval.inf, interError.result.sup, interError.interval.sup, interError.result.inf, NULL);
   
   if(isDisjointWith(_x,_y)){
      failNow();
   }else if(isDisjointWithR(_x,_y)){
      failNow();
   }else{
      float_interval xTmp = makeFloatInterval(_xi.inf, _xi.sup);
      fpi_setf(_precision, _rounding, &xTmp, &_yi);
      
      inter = intersection(_xi, xTmp, 0.0f);
      intersectionError(&interError, _exi, _eyi);
      if(inter.changed)
         [_x updateInterval:inter.result.inf and:inter.result.sup];
      if(interError.changed)
         [_x updateIntervalError:interError.result.inf and:interError.result.sup];
      if ((_yi.inf != inter.result.inf) || (_yi.sup != inter.result.sup))
         [_y updateInterval:inter.result.inf and:inter.result.sup];
      if ((mpq_cmp(_eyi.inf, interError.result.inf) != 0) || (mpq_cmp(_eyi.sup, interError.result.sup) != 0))
         [_y updateIntervalError:interError.result.inf and:interError.result.sup];
   }
   mpq_clears(interError.interval.inf, interError.result.sup, interError.interval.sup, interError.result.inf, NULL);
   
}
- (void)dealloc {
   freeRationalInterval(&_exi);
   freeRationalInterval(&_eyi);
   [super dealloc];
}

-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_y bound];
}
-(NSString*)description
{
   return [NSString stringWithFormat:@"<%@ = %@>",_x,_y];
}
@end

@implementation CPFloatAssignC
-(id) init:(CPFloatVarI*)x set:(ORFloat)c
{
   self = [super initCPCoreConstraint: [x engine]];
   _x = x;
   _c = c;
   return self;
   
}
-(void) post
{
   [_x bind:_c];
   ORRational _zero;
   mpq_init(_zero);
   mpq_set_d(_zero, 0.0f);
   [_x bindError:_zero];
   mpq_clear(_zero);
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_x bound];
}
-(NSString*)description
{
   return [NSString stringWithFormat:@"<%@ = %16.16e>",_x,_c];
}
@end


@implementation CPFloatNEqual
-(id) init:(CPFloatVarI*)x nequals:(CPFloatVarI*)y
{
   self = [super initCPCoreConstraint: [x engine]];
   _x = x;
   _y = y;
   return self;
   
}
-(void) post
{
   [self propagate];
   [_x whenBindPropagate:self];
   [_y whenBindPropagate:self];
}
-(void) propagate
{
   if ([_x bound]) {
      if([_y bound]){
         if (is_eqf([_x min],[_y min]))
            failNow();
         else{
            if([_x min] == [_y min]){
               [_y updateMin:fp_next_float([_y min])];
               assignTRInt(&_active, NO, _trail);
            }
            if([_x min] == [_y max]) {
               [_y updateMax:fp_previous_float([_y max])];
               assignTRInt(&_active, NO, _trail);
            }
            if([_x max] == [_y min]){
               [_y updateMin:fp_next_float([_y max])];
               assignTRInt(&_active, NO, _trail);
            }
            if([_x max] == [_y max]) {
               [_y updateMax:fp_previous_float([_y max])];
               assignTRInt(&_active, NO, _trail);
            }
         }
         return;
      }
   }else  if([_y bound]){
      if([_x min] == [_y min]){
         [_x updateMin:fp_next_float([_x min])];
         assignTRInt(&_active, NO, _trail);
      }
      if([_x min] == [_y max]) {
         [_x updateMin:fp_next_float([_x min])];
         assignTRInt(&_active, NO, _trail);
      }
      if([_x max] == [_y min]){
         [_x updateMax:fp_previous_float([_x max])];
         assignTRInt(&_active, NO, _trail);
      }
      if([_x max] == [_y max]) {
         [_x updateMax:fp_previous_float([_x max])];
         assignTRInt(&_active, NO, _trail);
      }
   }
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_y,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_y bound];
}
-(NSString*)description
{
   return [NSString stringWithFormat:@"<%@ != %@>",_x,_y];
}
@end

@implementation CPFloatNEqualc
-(id) init:(CPFloatVarI*)x and:(ORFloat)c
{
   self = [super initCPCoreConstraint: [x engine]];
   _x = x;
   _c = c;
   return self;
}
-(void) post
{
   [self propagate];
   [_x whenBindPropagate:self];
   [_x whenChangeBoundsPropagate:self];
}
-(void) propagate
{
   if ([_x bound]) {
      if([_x min] == _c)
         failNow();
   }else{
      if([_x min] == _c){
         [_x updateMin:fp_next_float(_c)];
         assignTRInt(&_active, NO, _trail);
      }
      if([_x max] == _c){
         [_x updateMax:fp_previous_float(_c)];
         assignTRInt(&_active, NO, _trail);
      }
   }
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_x bound];
}
-(NSString*)description
{
   return [NSString stringWithFormat:@"<%@ != %f>",_x,_c];
}
@end

@implementation CPFloatLT
-(id) init:(CPFloatVarI*)x lt:(CPFloatVarI*)y
{
   self = [super initCPCoreConstraint: [x engine]];
   _x = x;
   _y = y;
   return self;
}
-(void) post
{
   [self propagate];
   [_y whenChangeBoundsPropagate:self];
   [_x whenChangeBoundsPropagate:self];
}
-(void) propagate
{
   if(canFollow(_x,_y))
      failNow();
   if(isIntersectingWith(_x,_y)){
      if([_x min] >= [_y min]){
         ORFloat nmin = fp_next_float([_x min]);
         [_y updateMin:nmin];
      }
      if([_x max] >= [_y max]){
         ORFloat pmax = fp_previous_float([_y max]);
         [_x updateMax:pmax];
      }
   }
   if([_x bound] || [_y bound]){
      assignTRInt(&_active, NO, _trail);
      return;
   }
   
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_y,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_y bound];
}
-(NSString*)description
{
   return [NSString stringWithFormat:@"<%@ < %@>",_x,_y];
}
@end

@implementation CPFloatGT
-(id) init:(CPFloatVarI*)x gt:(CPFloatVarI*)y
{
   self = [super initCPCoreConstraint: [x engine]];
   _x = x;
   _y = y;
   return self;
}
-(void) post
{
   [self propagate];
   [_y whenChangeBoundsPropagate:self];
   [_x whenChangeBoundsPropagate:self];
}
-(void) propagate
{
   if(canPrecede(_x,_y))
      failNow();
   if(isIntersectingWith(_x,_y)){
      if([_x min] <= [_y min]){
         ORFloat pmin = fp_next_float([_y min]);
         [_x updateMin:pmin];
      }
      if([_x max] <= [_y max]){
         ORFloat nmax = fp_previous_float([_x max]);
         [_y updateMax:nmax];
      }
   }
   if([_x bound] || [_y bound]){
      assignTRInt(&_active, NO, _trail);
      return;
   }
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_y,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_y bound];
}

-(NSString*)description
{
   return [NSString stringWithFormat:@"<%@ > %@>",_x,_y];
}
@end


@implementation CPFloatLEQ
-(id) init:(CPFloatVarI*)x leq:(CPFloatVarI*)y
{
   self = [super initCPCoreConstraint: [x engine]];
   _x = x;
   _y = y;
   return self;
}
-(void) post
{
   [self propagate];
   [_y whenChangeBoundsPropagate:self];
   [_x whenChangeBoundsPropagate:self];
}
-(void) propagate
{
   if(canFollow(_x,_y))
      failNow();
   if(isIntersectingWith(_x,_y)){
      if([_x min] > [_y min]){
         ORFloat nmin = [_x min];
         [_y updateMin:nmin];
      }
      if([_x max] > [_y max]){
         ORFloat pmax = [_y max];
         [_x updateMax:pmax];
      }
   }
   if([_x bound] || [_y bound]){
      assignTRInt(&_active, NO, _trail);
      return;
   }
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_y,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_y bound];
}
-(NSString*)description
{
   return [NSString stringWithFormat:@"<%@ <= %@>",_x,_y];
}
@end

@implementation CPFloatGEQ
-(id) init:(CPFloatVarI*)x geq:(CPFloatVarI*)y
{
   self = [super initCPCoreConstraint: [x engine]];
   _x = x;
   _y = y;
   return self;
}
-(void) post
{
   [self propagate];
   [_y whenChangeBoundsPropagate:self];
   [_x whenChangeBoundsPropagate:self];
}
-(void) propagate
{
   if(canPrecede(_x,_y))
      failNow();
   if(isIntersectingWith(_x,_y)){
      if([_x min] < [_y min]){
         ORFloat pmin = [_y min];
         [_x updateMin:pmin];
      }
      if([_x max] < [_y max]){
         ORFloat nmax = [_x max];
         [_y updateMax:nmax];
      }
   }
   if([_x bound] || [_y bound]){
      assignTRInt(&_active, NO, _trail);
      return;
   }
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_y,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_y bound];
}
-(NSString*)description
{
   return [NSString stringWithFormat:@"<%@ >= %@>",_x,_y];
}
@end


@implementation CPFloatTernaryAdd{
   rational_interval ezTemp, eyTemp, exTemp, ez, ex, ey;
   rational_interval eoTemp, eo;
}
-(id) init:(CPFloatVarI*)z equals:(CPFloatVarI*)x plus:(CPFloatVarI*)y
{
   return [self init:z equals:x plus:y kbpercent:PERCENT];
}
-(id) init:(CPFloatVarI*)z equals:(CPFloatVarI*)x plus:(CPFloatVarI*)y kbpercent:(ORDouble)p
{
   self = [super initCPCoreConstraint: [x engine]];
   _z = z;
   _x = x;
   _y = y;
   _precision = 1;
   _percent = p;
   _rounding = FE_TONEAREST;
   mpq_inits(ez.sup, ez.inf, ex.sup, ex.inf, ey.sup, ey.inf, eo.sup, eo.inf, ezTemp.sup, ezTemp.inf, exTemp.sup, exTemp.inf, eyTemp.sup, eyTemp.inf, eoTemp.sup, eoTemp.inf, NULL);
   //cpjm
   mpq_set_d(eo.inf, -MAXFLOAT);
   mpq_set_d(eo.sup,  MAXFLOAT);
   return self;
}
-(void) post
{
   [self propagate];
   if(![_x bound] || ![_x boundError])  [_x whenChangeBoundsPropagate:self];
   if(![_y bound] || ![_y boundError])  [_y whenChangeBoundsPropagate:self];
   if (![_z bound] || ![_z boundError]) [_z whenChangeBoundsPropagate:self];
}
-(void) propagate
{
   int gchanged,changed;
   changed = gchanged = false;
   float_interval zTemp,yTemp,xTemp,z,x,y;
   intersectionInterval inter;
   intersectionIntervalError interError;
   mpq_inits(interError.interval.inf, interError.result.sup, interError.interval.sup, interError.result.inf, NULL);
   z = makeFloatInterval([_z min],[_z max]);
   x = makeFloatInterval([_x min],[_x max]);
   y = makeFloatInterval([_y min],[_y max]);
   makeRationalInterval(&ez, *[_z minErr], *[_z maxErr]);
   makeRationalInterval(&ex, *[_x minErr], *[_x maxErr]);
   makeRationalInterval(&ey, *[_y minErr], *[_y maxErr]);
   //  makeRationalInterval(&eo, *[_z minErr], *[_z maxErr]);
   do {
      changed = false;
      zTemp = z;
      fpi_addf(_precision, _rounding, &zTemp, &x, &y);
      inter = intersection(z, zTemp,_percent);
      z = inter.result;
      changed |= inter.changed;
      
      xTemp = x;
      yTemp = y;
      fpi_add_invsub_boundsf(_precision, _rounding, &xTemp, &yTemp, &z);
      inter = intersection(x , xTemp,_percent);
      x = inter.result;
      changed |= inter.changed;
      
      inter = intersection(y, yTemp,_percent);
      y = inter.result;
      changed |= inter.changed;
      
      xTemp = x;
      fpi_addxf_inv(_precision, _rounding, &xTemp, &z, &y);
      inter = intersection(x , xTemp,_percent);
      x = inter.result;
      changed |= inter.changed;
      
      yTemp = y;
      fpi_addyf_inv(_precision, _rounding, &yTemp, &z, &x);
      inter = intersection(y, yTemp,_percent);
      y = inter.result;
      changed |= inter.changed;
      
      /* ERROR PROPAG */
      compute_eo_add(&eo, &eoTemp, x, y, z);
      
      setRationalInterval(&ezTemp,&ez);
      addR(&ezTemp, &ex, &ey, &eo);
      intersectionError(&interError, ez, ezTemp);
      if(interError.changed)
         setRationalInterval(&ez, &interError.result);
      changed |= interError.changed;
      
      setRationalInterval(&exTemp,&ex);
      addR_inv_ex(&exTemp, &ez, &ey, &eo);
      intersectionError(&interError, ex, exTemp);
      if(interError.changed)
         setRationalInterval(&ex, &interError.result);
      changed |= interError.changed;
      
      setRationalInterval(&eyTemp,&ey);
      addR_inv_ey(&eyTemp, &ez, &ex, &eo);
      intersectionError(&interError, ey, eyTemp);
      if(interError.changed)
         setRationalInterval(&ey, &interError.result);
      changed |= interError.changed;
      
      setRationalInterval(&eoTemp,&eo);
      addR_inv_eo(&eoTemp, &ez, &ex, &ey);
      intersectionError(&interError, eo, eoTemp);
      if(interError.changed)
         setRationalInterval(&eo, &interError.result);
      changed |= interError.changed;
      
      /* END ERROR PROPAG */
      
      gchanged |= changed;
   } while(changed);
   if(gchanged){
      [_x updateInterval:x.inf and:x.sup];
      [_y updateInterval:y.inf and:y.sup];
      [_z updateInterval:z.inf and:z.sup];
      [_x updateIntervalError:ex.inf and:ex.sup];
      [_y updateIntervalError:ey.inf and:ey.sup];
      [_z updateIntervalError:ez.inf and:ez.sup];
      if([_x bound] && [_y bound] && [_z bound] && [_x boundError] && [_y boundError] && [_z boundError])
         assignTRInt(&_active, NO, _trail);
   }
   fesetround(FE_TONEAREST);
   
   mpq_clears(interError.interval.inf, interError.result.sup, interError.interval.sup, interError.result.inf, NULL);
}
- (void)dealloc {
   freeRationalInterval(&ez);
   freeRationalInterval(&ex);
   freeRationalInterval(&ey);
   freeRationalInterval(&eo);
   freeRationalInterval(&ezTemp);
   freeRationalInterval(&exTemp);
   freeRationalInterval(&eyTemp);
   freeRationalInterval(&eoTemp);
   [super dealloc];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_z,_x,_y,nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_y,_z,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_y bound] + ![_z bound] + ![_x boundError] + ![_y boundError] + ![_z boundError];
}
-(id<CPFloatVar>) varSubjectToAbsorption:(id<CPFloatVar>)x
{
   if([x getId] == [_x getId])
      return _y;
   else if([x getId] == [_y getId])
      return _x;
   return nil;
}
-(ORBool) canLeadToAnAbsorption
{
   return true;
}
//hzi : todo check cancellation for odometrie_10
-(ORDouble) leadToACancellation:(id<ORVar>)x
{
   ORInt exmin, exmax, eymin,eymax,ezmin,ezmax,gmax,zmin;
   frexpf(fabs([_x min]),&exmin);
   frexpf(fabs([_x max]),&exmax);
   frexpf(fabs([_y min]),&eymin);
   frexpf(fabs([_y max]),&eymax);
   frexpf(fabs([_z min]),&ezmin);
   frexpf(fabs([_z max]),&ezmax);
   gmax = max(exmin, exmax);
   gmax = max(gmax,eymin);
   gmax = max(gmax,eymax);
   zmin = (([_z min] <= 0 && [_z max] >= 0) || ([_x min] == 0.f && [_x max] == 0.f) ||([_y min] == 0.0f && [_y max] == 0.0f)) ? 0.0 : min(ezmin,ezmax);
   return gmax-zmin;
}
-(NSString*)description
{
   return [NSString stringWithFormat:@"<%@ = %@ + %@>",_z, _x, _y];
}
@end


@implementation CPFloatTernarySub{
   rational_interval ezTemp, eyTemp, exTemp, ez, ex, ey;
   rational_interval eoTemp, eo;
}
-(id) init:(CPFloatVarI*)z equals:(CPFloatVarI*)x minus:(CPFloatVarI*)y
{
   return [self init:z equals:x minus:y kbpercent:PERCENT];
}
-(id) init:(CPFloatVarI*)z equals:(CPFloatVarI*)x minus:(CPFloatVarI*)y kbpercent:(ORDouble)p
{
   self = [super initCPCoreConstraint: [x engine]];
   _z = z;
   _x = x;
   _y = y;
   _precision = 1;
   _percent = p;
   _rounding = FE_TONEAREST;
   mpq_inits(ez.sup, ez.inf, ex.sup, ex.inf, ey.sup, ey.inf, eo.sup, eo.inf, ezTemp.sup, ezTemp.inf, exTemp.sup, exTemp.inf, eyTemp.sup, eyTemp.inf, eoTemp.sup, eoTemp.inf, NULL);
   //cpjm
   mpq_set_d(eo.inf, -MAXFLOAT);
   mpq_set_d(eo.sup,  MAXFLOAT);
   return self;
}
-(void) post
{
   [self propagate];
   if(![_x bound] || ![_x boundError])  [_x whenChangeBoundsPropagate:self];
   if(![_y bound] || ![_y boundError])  [_y whenChangeBoundsPropagate:self];
   if (![_z bound] || ![_z boundError]) [_z whenChangeBoundsPropagate:self];
}
-(void) propagate
{
   int gchanged,changed;
   changed = gchanged = false;
   float_interval zTemp,yTemp,xTemp,z,x,y;
   intersectionInterval inter;
   intersectionIntervalError interError;
   mpq_inits(interError.interval.inf, interError.result.sup, interError.interval.sup, interError.result.inf, NULL);
   z = makeFloatInterval([_z min],[_z max]);
   x = makeFloatInterval([_x min],[_x max]);
   y = makeFloatInterval([_y min],[_y max]);
   makeRationalInterval(&ez, *[_z minErr], *[_z maxErr]);
   makeRationalInterval(&ex, *[_x minErr], *[_x maxErr]);
   makeRationalInterval(&ey, *[_y minErr], *[_y maxErr]);
   //makeRationalInterval(&eo, *[_z minErr], *[_z maxErr]); // Why should eo be initialized with ez ??
   do {
      changed = false;
      zTemp = z;
      fpi_subf(_precision, _rounding, &zTemp, &x, &y);
      inter = intersection(z, zTemp,_percent);
      z = inter.result;
      changed |= inter.changed;
      
      xTemp = x;
      yTemp = y;
      fpi_sub_invsub_boundsf(_precision, _rounding, &xTemp, &yTemp, &z);
      inter = intersection(x , xTemp,_percent);
      x = inter.result;
      changed |= inter.changed;
      
      inter = intersection(y, yTemp,_percent);
      y = inter.result;
      changed |= inter.changed;
      
      xTemp = x;
      fpi_subxf_inv(_precision, _rounding, &xTemp, &z, &y);
      inter = intersection(x , xTemp,_percent);
      x = inter.result;
      changed |= inter.changed;
      
      yTemp = y;
      fpi_subyf_inv(_precision, _rounding, &yTemp, &z, &x);
      inter = intersection(y, yTemp,_percent);
      y = inter.result;
      changed |= inter.changed;
      
      /* ERROR PROPAG */
      compute_eo_sub(&eo, &eoTemp, x, y, z);
      
      setRationalInterval(&ezTemp,&ez);
      subR(&ezTemp, &ex, &ey, &eo);
      intersectionError(&interError, ez, ezTemp);
      if(interError.changed)
         setRationalInterval(&ez, &interError.result);
      changed |= interError.changed;
      
      setRationalInterval(&exTemp,&ex);
      subR_inv_ex(&exTemp, &ez, &ey, &eo);
      intersectionError(&interError, ex, exTemp);
      if(interError.changed)
         setRationalInterval(&ex, &interError.result);
      changed |= interError.changed;
      
      setRationalInterval(&eyTemp,&ey);
      subR_inv_ey(&eyTemp, &ez, &ex, &eo);
      intersectionError(&interError, ey, eyTemp);
      if(interError.changed)
         setRationalInterval(&ey, &interError.result);
      changed |= interError.changed;
      
      setRationalInterval(&eoTemp,&eo);
      subR_inv_eo(&eoTemp, &ez, &ex, &ey);
      intersectionError(&interError, eo, eoTemp);
      if(interError.changed)
         setRationalInterval(&eo, &interError.result);
      changed |= interError.changed;
      /* END ERROR PROPAG */
      
      gchanged |= changed;
   } while(changed);
   if(gchanged){
      [_x updateInterval:x.inf and:x.sup];
      [_y updateInterval:y.inf and:y.sup];
      [_z updateInterval:z.inf and:z.sup];
      [_x updateIntervalError:ex.inf and:ex.sup];
      [_y updateIntervalError:ey.inf and:ey.sup];
      [_z updateIntervalError:ez.inf and:ez.sup];
      if([_x bound] && [_y bound] && [_z bound] && [_x boundError] && [_y boundError] && [_z boundError])
         assignTRInt(&_active, NO, _trail);
   }
   fesetround(FE_TONEAREST);
   mpq_clears(interError.interval.inf, interError.result.sup, interError.interval.sup, interError.result.inf, NULL);
}
- (void)dealloc {
   freeRationalInterval(&ez);
   freeRationalInterval(&ex);
   freeRationalInterval(&ey);
   freeRationalInterval(&eo);
   freeRationalInterval(&ezTemp);
   freeRationalInterval(&exTemp);
   freeRationalInterval(&eyTemp);
   freeRationalInterval(&eoTemp);
   [super dealloc];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_z,_x,_y,nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_y,_z,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_y bound] + ![_z bound];
}
-(id<CPFloatVar>) varSubjectToAbsorption:(id<CPFloatVar>)x
{
   if([x getId] == [_x getId])
      return _y;
   else if([x getId] == [_y getId])
      return _x;
   return nil;
}
-(ORBool) canLeadToAnAbsorption
{
   return true;
}
-(ORDouble) leadToACancellation:(id<ORVar>)x
{
   ORInt exmin, exmax, eymin,eymax,ezmin,ezmax,gmax,zmin;
   frexpf([_x min],&exmin);
   frexpf([_x max],&exmax);
   frexpf([_y min],&eymin);
   frexpf([_y max],&eymax);
   frexpf([_z min],&ezmin);
   frexpf([_z max],&ezmax);
   gmax = max(exmin, exmax);
   gmax = max(gmax,eymin);
   gmax = max(gmax,eymax);
   zmin = (([_z min] <= 0 && [_z max] >= 0) || ([_x min] == 0.f && [_x max] == 0.f) ||([_y min] == 0.0f && [_y max] == 0.0f)) ? 0.0 : min(ezmin,ezmax);
   return gmax-zmin;
}
-(NSString*)description
{
   return [NSString stringWithFormat:@"<%@ = %@ - %@>",_z, _x, _y];
}
@end

@implementation CPFloatTernaryMult{
   rational_interval ezTemp, eyTemp, exTemp, ez, ex, ey;
   rational_interval eoTemp, eo;
}
-(id) init:(CPFloatVarI*)z equals:(CPFloatVarI*)x mult:(CPFloatVarI*)y
{
   return [self init:z equals:x mult:y kbpercent:PERCENT];
}
-(id) init:(CPFloatVarI*)z equals:(CPFloatVarI*)x mult:(CPFloatVarI*)y kbpercent:(ORDouble)p
{
   self = [super initCPCoreConstraint: [x engine]];
   _z = z;
   _x = x;
   _y = y;
   _precision = 1;
   _percent = p;
   _rounding = FE_TONEAREST;
   mpq_inits(ez.sup, ez.inf, ex.sup, ex.inf, ey.sup, ey.inf, eo.sup, eo.inf, ezTemp.sup, ezTemp.inf, exTemp.sup, exTemp.inf, eyTemp.sup, eyTemp.inf, eoTemp.sup, eoTemp.inf, NULL);
   mpq_set_d(eo.inf, -MAXFLOAT);
   mpq_set_d(eo.sup,  MAXFLOAT);
   return self;
}
-(void) post
{
   [self propagate];
   if(![_x bound] || ![_x boundError])  [_x whenChangeBoundsPropagate:self];
   if(![_y bound] || ![_y boundError])  [_y whenChangeBoundsPropagate:self];
   if (![_z bound] || ![_z boundError]) [_z whenChangeBoundsPropagate:self];
}
-(void) propagate
{
   int gchanged,changed;
   changed = gchanged = false;
   float_interval zTemp,yTemp,xTemp,z,x,y;
   intersectionInterval inter;
   intersectionIntervalError interError;
   mpq_inits(interError.interval.inf, interError.result.sup, interError.interval.sup, interError.result.inf, NULL);
   z = makeFloatInterval([_z min],[_z max]);
   x = makeFloatInterval([_x min],[_x max]);
   y = makeFloatInterval([_y min],[_y max]);
   makeRationalInterval(&ez, *[_z minErr], *[_z maxErr]);
   makeRationalInterval(&ex, *[_x minErr], *[_x maxErr]);
   makeRationalInterval(&ey, *[_y minErr], *[_y maxErr]);
   //makeRationalInterval(&eo, *[_z minErr], *[_z maxErr]);
   do {
      changed = false;
      zTemp = z;
      fpi_multf(_precision, _rounding, &zTemp, &x, &y);
      inter = intersection(z, zTemp,_percent);
      z = inter.result;
      changed |= inter.changed;
      
      xTemp = x;
      fpi_multxf_inv(_precision, _rounding, &xTemp, &z, &y);
      inter = intersection(x , xTemp,_percent);
      x = inter.result;
      changed |= inter.changed;
      
      yTemp = y;
      fpi_multyf_inv(_precision, _rounding, &yTemp, &z, &x);
      inter = intersection(y, yTemp,_percent);
      y = inter.result;
      changed |= inter.changed;
      
      /* ERROR PROPAG */
      compute_eo_mul(&eo, &eoTemp, x, y, z);
      
      setRationalInterval(&ezTemp,&ez);
      mulR(&ezTemp, &ex, &ey, &eo, &x, &y);
      intersectionError(&interError, ez, ezTemp);
      if(interError.changed)
         setRationalInterval(&ez, &interError.result);
      changed |= interError.changed;
      
      setRationalInterval(&exTemp,&ex);
      mulR_inv_ex(&exTemp, &ez, &ey, &eo, &x, &y);
      intersectionError(&interError, ex , exTemp);
      if(interError.changed)
         setRationalInterval(&ex, &interError.result);
      changed |= interError.changed;
      
      setRationalInterval(&eyTemp,&ey);
      mulR_inv_ey(&eyTemp, &ez, &ex, &eo, &x, &y);
      intersectionError(&interError, ey, eyTemp);
      if(interError.changed)
         setRationalInterval(&ey, &interError.result);
      changed |= interError.changed;
      
      setRationalInterval(&eoTemp,&eo);
      mulR_inv_eo(&eoTemp, &ez, &ex, &ey, &x, &y);
      intersectionError(&interError, eo, eoTemp);
      if(interError.changed)
         setRationalInterval(&eo, &interError.result);
      changed |= interError.changed;
      /* END ERROR PROPAG */
      
      gchanged |= changed;
   } while(changed);
   if(gchanged){
      [_x updateInterval:x.inf and:x.sup];
      [_y updateInterval:y.inf and:y.sup];
      [_z updateInterval:z.inf and:z.sup];
      [_x updateIntervalError:ex.inf and:ex.sup];
      [_y updateIntervalError:ey.inf and:ey.sup];
      [_z updateIntervalError:ez.inf and:ez.sup];
      if([_x bound] && [_y bound] && [_z bound] && [_x boundError] && [_y boundError] && [_z boundError])
         assignTRInt(&_active, NO, _trail);
      
   }
   fesetround(FE_TONEAREST);
   mpq_clears(interError.interval.inf, interError.result.sup, interError.interval.sup, interError.result.inf, NULL);
}
- (void)dealloc {
   freeRationalInterval(&ez);
   freeRationalInterval(&ex);
   freeRationalInterval(&ey);
   freeRationalInterval(&eo);
   freeRationalInterval(&ezTemp);
   freeRationalInterval(&exTemp);
   freeRationalInterval(&eyTemp);
   freeRationalInterval(&eoTemp);
   [super dealloc];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_z,_x,_y,nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_y,_z,nil] autorelease];
}
-(id<CPFloatVar>) result
{
   return _z;
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_y bound] + ![_z bound];
}
-(NSString*)description
{
   return [NSString stringWithFormat:@"<%@ = %@ * %@>",_z, _x, _y];
}
@end

@implementation CPFloatTernaryDiv{
   rational_interval ezTemp, eyTemp, exTemp, ez, ex, ey;
   rational_interval eoTemp, eo;
}
-(id) init:(CPFloatVarI*)z equals:(CPFloatVarI*)x div:(CPFloatVarI*)y
{
   return [self init:z equals:x div:y kbpercent:PERCENT];
}
-(id) init:(CPFloatVarI*)z equals:(CPFloatVarI*)x div:(CPFloatVarI*)y kbpercent:(ORDouble)p
{
   self = [super initCPCoreConstraint: [x engine]];
   _z = z;
   _x = x;
   _y = y;
   _precision = 1;
   _percent = p;
   _rounding = FE_TONEAREST;
   mpq_inits(ez.sup, ez.inf, ex.sup, ex.inf, ey.sup, ey.inf, eo.sup, eo.inf, ezTemp.sup, ezTemp.inf, exTemp.sup, exTemp.inf, eyTemp.sup, eyTemp.inf, eoTemp.sup, eoTemp.inf, NULL);
   mpq_set_d(eo.inf, -MAXFLOAT);
   mpq_set_d(eo.sup,  MAXFLOAT);
   return self;
}
-(void) post
{
   [self propagate];
   if(![_x bound] || ![_x boundError])  [_x whenChangeBoundsPropagate:self];
   if(![_y bound] || ![_y boundError])  [_y whenChangeBoundsPropagate:self];
   if (![_z bound] || ![_z boundError]) [_z whenChangeBoundsPropagate:self];
}
-(void) propagate
{
   int gchanged,changed;
   changed = gchanged = false;
   float_interval zTemp,yTemp,xTemp,z,x,y;
   intersectionInterval inter;
   intersectionIntervalError interError;
   mpq_inits(interError.interval.inf, interError.result.sup, interError.interval.sup, interError.result.inf, NULL);
   z = makeFloatInterval([_z min],[_z max]);
   x = makeFloatInterval([_x min],[_x max]);
   y = makeFloatInterval([_y min],[_y max]);
   makeRationalInterval(&ez, *[_z minErr], *[_z maxErr]);
   makeRationalInterval(&ex, *[_x minErr], *[_x maxErr]);
   makeRationalInterval(&ey, *[_y minErr], *[_y maxErr]);
   //makeRationalInterval(&eo, *[_z minErr], *[_z maxErr]);
   do {
      changed = false;
      zTemp = z;
      fpi_divf(_precision, _rounding, &zTemp, &x, &y);
      inter = intersection(z, zTemp,_percent);
      z = inter.result;
      changed |= inter.changed;
      
      xTemp = x;
      fpi_divxf_inv(_precision, _rounding, &xTemp, &z, &y);
      inter = intersection(x , xTemp,_percent);
      x = inter.result;
      changed |= inter.changed;
      
      yTemp = y;
      fpi_divyf_inv(_precision, _rounding, &yTemp, &z, &x);
      inter = intersection(y, yTemp,_percent);
      y = inter.result;
      changed |= inter.changed;
      
      /* ERROR PROPAG */
      compute_eo_div(&eo, &eoTemp, x, y, z);
      
      setRationalInterval(&ezTemp,&ez);
      divR(&ezTemp, &ex, &ey, &eo, &x, &y);
      intersectionError(&interError, ez, ezTemp);
      if(interError.changed)
         setRationalInterval(&ez, &interError.result);
      changed |= interError.changed;
      
      setRationalInterval(&exTemp,&ex);
      divR_inv_ex(&exTemp, &ez, &ey, &eo, &x, &y);
      intersectionError(&interError, ex , exTemp);
      if(interError.changed)
         setRationalInterval(&ex, &interError.result);
      changed |= interError.changed;
      
      setRationalInterval(&eyTemp,&ey);
      divR_inv_ey(&eyTemp, &ez, &ex, &eo, &x, &y);
      intersectionError(&interError, ey, eyTemp);
      if(interError.changed)
         setRationalInterval(&ey, &interError.result);
      changed |= interError.changed;
      
      setRationalInterval(&eoTemp,&eo);
      divR_inv_eo(&eoTemp, &ez, &ex, &ey, &x, &y);
      intersectionError(&interError, eo, eoTemp);
      if(interError.changed)
         setRationalInterval(&eo, &interError.result);
      changed |= interError.changed;
      /* END ERROR PROPAG */
      
      gchanged |= changed;
   } while(changed);
   if(gchanged){
      [_x updateInterval:x.inf and:x.sup];
      [_y updateInterval:y.inf and:y.sup];
      [_z updateInterval:z.inf and:z.sup];
      [_x updateIntervalError:ex.inf and:ex.sup];
      [_y updateIntervalError:ey.inf and:ey.sup];
      [_z updateIntervalError:ez.inf and:ez.sup];
      if([_x bound] && [_y bound] && [_z bound] && [_x boundError] && [_y boundError] && [_z boundError])
         assignTRInt(&_active, NO, _trail);
   }
   fesetround(FE_TONEAREST);
   mpq_clears(interError.interval.inf, interError.result.sup, interError.interval.sup, interError.result.inf, NULL);
}
- (void)dealloc {
   freeRationalInterval(&ez);
   freeRationalInterval(&ex);
   freeRationalInterval(&ey);
   freeRationalInterval(&eo);
   freeRationalInterval(&ezTemp);
   freeRationalInterval(&exTemp);
   freeRationalInterval(&eyTemp);
   freeRationalInterval(&eoTemp);
   [super dealloc];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_z,_x,_y,nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_y,_z,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_y bound] + ![_z bound];
}
-(NSString*)description
{
   return [NSString stringWithFormat:@"<%@ = %@ / %@>",_z, _x, _y];
}
@end

@implementation CPFloatReifyNEqual
-(id) initCPReify:(CPIntVar*)b when:(CPFloatVarI*)x neq:(CPFloatVarI*)y
{
   self = [super initCPCoreConstraint:[x engine]];
   _b = b;
   _x = x;
   _y = y;
   return self;
}

-(void) post
{
   if (bound(_b)) {
      if (minDom(_b)) {
         [[_b engine] addInternal: [CPFactory floatNEqual:_x to:_y]];         // Rewrite as x==y  (addInternal can throw)
         assignTRInt(&_active, NO, _trail);
         return ;
      } else {
         [[_b engine] addInternal: [CPFactory floatEqual:_x to:_y]];     // Rewrite as x==y  (addInternal can throw)
         assignTRInt(&_active, NO, _trail);
         return ;
      }
   }
   else if ([_x bound] && [_y bound]) {       //  b <=> c == d =>  b <- c==d
      [_b bind:[_x min] != [_y min]];
      assignTRInt(&_active, NO, _trail);
      return;
   }else if ([_x bound]) {
      [[_b engine] addInternal: [CPFactory floatReify:_b with:_y neqi:[_x min]]];
      return ;
   }
   else if ([_y bound]) {
      [[_b engine] addInternal: [CPFactory floatReify:_b with:_x neqi:[_y min]]];
      return ;
   } else {      // nobody is bound. D(x) INTER D(y) = EMPTY => b = YES
      if ([_x max] < [_y min] || [_y max] < [_x min])
         [_b bind:YES];
      else {   // nobody bound and domains of (x,y) overlap
         [_b whenBindPropagate:self];
         [_x whenChangeBoundsPropagate:self];
         [_y whenChangeBoundsPropagate:self];
      }
   }
}

-(void)propagate
{
   if (minDom(_b)) {            // b is TRUE
      if ([_x bound]){            // TRUE <=> (y != c)
         [[_b engine] addInternal: [CPFactory floatNEqualc:_y to:[_x min]]];         // Rewrite as x==y  (addInternal can throw)
         assignTRInt(&_active, NO, _trail);
         return;
      }else  if ([_y bound]) {     // TRUE <=> (x != c)
         [[_b engine] addInternal: [CPFactory floatNEqualc:_x to:[_y min]]];         // Rewrite as x==y  (addInternal can throw)
         assignTRInt(&_active, NO, _trail);
         return;
      }
   }
   else if (maxDom(_b)==0) {     // b is FALSE
      if ([_x bound]){
         if(is_eqf([_x min],-0.0f) && is_eqf([_x max],+0.0f))
            [_y updateInterval:[_x min] and:[_x max]];
         else
            [_y bind:[_x min]];
         assignTRInt(&_active, NO, _trail);
         return;
      } else if ([_y bound]){
         if(is_eqf([_y min],-0.0f) && is_eqf([_y max],+0.0f))
            [_x updateInterval:[_y min] and:[_y max]];
         else
            [_x bind:[_y min]];
         assignTRInt(&_active, NO, _trail);
         return;
      }else {                    // FALSE <=> (x == y)
         [_x updateInterval:[_y min] and:[_y max]];
         [_y updateInterval:[_x min] and:[_x max]];
      }
   }
   else {                        // b is unknown
      if ([_x bound] && [_y bound]){
         [_b bind: [_x min] != [_y min]];
         assignTRInt(&_active, NO, _trail);
      } else if ([_x max] < [_y min] || [_y max] < [_x min]){
         [_b bind:YES];
         assignTRInt(&_active, NO, _trail);
         
      }
   }
}
-(NSString*)description
{
   return [NSMutableString stringWithFormat:@"<CPFloatReifyNEqual:%02d %@ <=> (%@ != %@)>",_name,_b,_x,_y];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,_b, nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_y,_b,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_x bound] +  ![_y bound] + ![_b bound];
}
@end

@implementation CPFloatReifyEqual
-(id) initCPReifyEqual:(CPIntVar*)b when:(CPFloatVarI*)x eqi:(CPFloatVarI*)y
{
   self = [super initCPCoreConstraint:[x engine]];
   _b = b;
   _x = x;
   _y = y;
   return self;
}
-(void) post
{
   if (bound(_b)) {
      if (minDom(_b)) {
         [[_b engine] addInternal: [CPFactory floatEqual:_x to:_y]]; // Rewrite as x==y  (addInternal can throw)
         return;
      } else {
         [[_b engine] addInternal: [CPFactory floatNEqual:_x to:_y]];     // Rewrite as x!=y  (addInternal can throw)
         return;
      }
   }
   else if ([_x bound] && [_y bound])        //  b <=> c == d =>  b <- c==d
      [_b bind:[_x min] == [_y min]];
   else if ([_x bound]) {
      [[_b engine] add: [CPFactory floatReify:_b with:_y eqi:[_x min]]];
      assignTRInt(&_active, 0, _trail);
      return;
   }
   else if ([_y bound]) {
      [[_b engine] add: [CPFactory floatReify:_b with:_x eqi:[_y min]]];
      assignTRInt(&_active, 0, _trail);
      return;
   } else {      // nobody is bound. D(x) INTER D(y) = EMPTY => b = NO
      if ([_x max] < [_y min] || [_y max] < [_x min])
         [_b bind:NO];
      else {   // nobody bound and domains of (x,y) overlap
         [_b whenBindPropagate:self];
         [_x whenChangeBoundsPropagate:self];
         [_y whenChangeBoundsPropagate:self];
      }
   }
}

-(void)propagate
{
   if (minDom(_b)) {            // b is TRUE
      if ([_x bound]) {           // TRUE <=> (y == c)
         assignTRInt(&_active, 0, _trail);
         if(is_eqf([_x min],-0.0f) && is_eqf([_x max],+0.0f))
            [_y updateInterval:[_x min] and:[_x max]];
         else
            [_y bind:[_x min]];
      }else  if ([_y bound]) {     // TRUE <=> (x == c)
         assignTRInt(&_active, 0, _trail);
         if(is_eqf([_y min],-0.0f) && is_eqf([_y max],+0.0f))
            [_x updateInterval:[_y min] and:[_y max]];
         else
            [_x bind:[_y min]];
      } else {                    // TRUE <=> (x == y)
         [_x updateInterval:[_y min] and:[_y max]];
         [_y updateInterval:[_x min] and:[_x max]];
      }
   }
   else if (maxDom(_b)==0) {     // b is FALSE
      if ([_y bound])
         [[_b engine] addInternal: [CPFactory floatNEqualc:_y to:[_x min]]]; // Rewrite as min(x)!=y  (addInternal can throw)
      else if ([_y bound])
         [[_b engine] addInternal: [CPFactory floatNEqualc:_x to:[_y min]]]; // Rewrite as min(y)!=x  (addInternal can throw)
   }
   else {                        // b is unknown
      if ([_x bound] && [_y bound])
         [_b bind: [_x min] == [_y min]];
      else if ([_x max] < [_y min] || [_y max] < [_x min])
         [_b bind:NO];
   }
}
-(NSString*)description
{
   return [NSMutableString stringWithFormat:@"<CPFloatReifyEqual:%02d %@ <=> (%@ == %@)>",_name,_b,_x,_y];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,_b, nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_y,_b,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_x bound] +  ![_y bound] + ![_b bound];
}
@end

@implementation CPFloatReifyGThen
-(id) initCPReifyGThen:(CPIntVar*)b when:(CPFloatVarI*)x gti:(CPFloatVarI*)y
{
   self = [super initCPCoreConstraint:[x engine]];
   _b = b;
   _x = x;
   _y = y;
   return self;
}
-(void) post
{
   if (bound(_b)) {
      if (minDom(_b)) {  // YES <=>  x > y
         [_y updateMax:fp_previous_float([_x max])];
         [_x updateMin:fp_next_float([_y min])];
      } else {            // NO <=> x <= y   ==>  YES <=> x < y
         if ([_x bound]) { // c <= y
            [_y updateMin:[_x min]];
         } else {         // x <= y
            [_y updateMin:[_x min]];
            [_x updateMax:[_y max]];
         }
      }
      if (![_x bound])
         [_x whenChangeBoundsPropagate:self];
      if (![_y bound])
         [_y whenChangeBoundsPropagate:self];
   } else {
      if ([_y max] < [_x min])
         [_b bind:YES];
      else if ([_x max] <= [_y min])
         [_b bind:NO];
      else {
         [_x whenChangeBoundsPropagate:self];
         [_y whenChangeBoundsPropagate:self];
         [_b whenBindPropagate:self];
      }
   }
}
-(void)propagate
{
   if (bound(_b)) {
      if (minDom(_b)) {
         [_y updateMax:fp_previous_float([_x max])];
         [_x updateMin:fp_next_float([_y min])];
      } else {
         if ([_x bound]) { // c <= y
            [_y updateMin:[_x min]];
         } else {         // x <= y
            [_y updateMin:[_x min]];
            [_x updateMax:[_y max]];
         }
      }
   } else {
      if ([_y max] < [_x min]) {
         assignTRInt(&_active, NO, _trail);
         bindDom(_b,YES);
      } else if ([_x max] <= [_y min]){
         assignTRInt(&_active, NO, _trail);
         bindDom(_b,NO);
      }
   }
}
-(NSString*)description
{
   return [NSMutableString stringWithFormat:@"<CPFloatReifyGEqual:%02d %@ <=> (%@ > %@)>",_name,_b,_x,_y];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,_b, nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_y,_b,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_x bound] + ![_b bound];
}
@end


@implementation CPFloatReifyGEqual
-(id) initCPReifyGEqual:(CPIntVar*)b when:(CPFloatVarI*)x geqi:(CPFloatVarI*)y
{
   self = [super initCPCoreConstraint:[x engine]];
   _b = b;
   _x = x;
   _y = y;
   return self;
}
-(void) post
{
   if (bound(_b)) {
      if (minDom(_b)) {  // YES <=>  x >= y
         [_y updateMax:[_x max]];
         [_x updateMin:[_y min]];
      } else {            // NO <=> x <= y   ==>  YES <=> x < y
         if ([_x bound]) { // c < y
            [_y updateMax:fp_next_float([_x min])];
         } else {         // x < y
            [_y updateMax:fp_next_float([_x max])];
            [_x updateMin:fp_previous_float([_y min])];
         }
      }
      if (![_x bound])
         [_x whenChangeBoundsPropagate:self];
      if (![_y bound])
         [_y whenChangeBoundsPropagate:self];
   } else {
      if ([_y max] <= [_x min])
         [_b bind:YES];
      else if ([_x min] < [_y max])
         [_b bind:NO];
      else {
         [_x whenChangeBoundsPropagate:self];
         [_y whenChangeBoundsPropagate:self];
         [_b whenBindPropagate:self];
      }
   }
}
-(void)propagate
{
   if (bound(_b)) {
      if (minDom(_b)) {
         [_y updateMax:[_x max]];
         [_x updateMin:[_y min]];
      } else {
         [_y updateMax:fp_next_float([_x max])];
         [_x updateMin:fp_previous_float([_y min])];
      }
   } else {
      if ([_y max] <= [_x min]) {
         assignTRInt(&_active, NO, _trail);
         bindDom(_b,YES);
      } else if ([_x min] < [_y max]) {
         assignTRInt(&_active, NO, _trail);
         bindDom(_b,NO);
      }
   }
}
-(NSString*)description
{
   return [NSMutableString stringWithFormat:@"<CPFloatReifyGEqual:%02d %@ <=> (%@ >= %@)>",_name,_b,_x,_y];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,_b, nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_y,_b,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_x bound] + ![_b bound];
}
@end


@implementation CPFloatReifyLEqual
-(id) initCPReifyLEqual:(CPIntVar*)b when:(CPFloatVarI*)x leqi:(CPFloatVarI*)y
{
   self = [super initCPCoreConstraint:[x engine]];
   _b = b;
   _x = x;
   _y = y;
   return self;
}
-(void) post
{
   if (bound(_b)) {
      if (minDom(_b)) {  // YES <=>  x <= y
         [_x updateMax:[_y max]];
         [_y updateMin:[_x min]];
      } else {            // NO <=> x <= y   ==>  YES <=> x > y
         if ([_x bound]) { // c > y
            [_y updateMax:fp_previous_float([_x min])];
         } else {         // x > y
            [_y updateMax:fp_previous_float([_x max])];
            [_x updateMin:fp_next_float([_y min])];
         }
      }
      if (![_x bound])
         [_x whenChangeBoundsPropagate:self];
      if (![_y bound])
         [_y whenChangeBoundsPropagate:self];
   } else {
      if ([_x max] <= [_y min])
         [_b bind:YES];
      else if ([_x min] > [_y max])
         [_b bind:NO];
      else {
         [_x whenChangeBoundsPropagate:self];
         [_y whenChangeBoundsPropagate:self];
         [_b whenBindPropagate:self];
      }
   }
}
-(void)propagate
{
   if (bound(_b)) {
      if (minDom(_b)) {
         [_x updateMax:[_y max]];
         [_y updateMin:[_x min]];
      } else {
         [_x updateMin:fp_next_float([_y min])];
         [_y updateMax:fp_previous_float([_x max])];
      }
   } else {
      if ([_x max] <= [_y min]) {
         assignTRInt(&_active, NO, _trail);
         bindDom(_b,YES);
      } else if ([_x min] > [_y max]) {
         assignTRInt(&_active, NO, _trail);
         bindDom(_b,NO);
      }
   }
}
-(NSString*)description
{
   return [NSMutableString stringWithFormat:@"<CPFloatReifyLEqual:%02d %@ <=> (%@ <= %@)>",_name,_b,_x,_y];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,_b, nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_y,_b,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_y bound] + ![_b bound];
}
@end


@implementation CPFloatReifyLThen
-(id) initCPReifyLThen:(CPIntVar*)b when:(CPFloatVarI*)x lti:(CPFloatVarI*)y
{
   self = [super initCPCoreConstraint:[x engine]];
   _b = b;
   _x = x;
   _y = y;
   return self;
}
-(void) post
{
   if (bound(_b)) {
      if (minDom(_b)) {  // YES <=>  x < y
         [_x updateMax:fp_previous_float([_y max])];
         [_y updateMin:fp_next_float([_x min])];
      } else {            // NO <=> x <= y   ==>  YES <=> x > y
         if ([_x bound]) { // c >= y
            [_y updateMax:[_x min]];
         } else {         // x >= y
            [_y updateMax:[_x max]];
            [_x updateMin:[_y min]];
         }
      }
      if (![_x bound])
         [_x whenChangeBoundsPropagate:self];
      if (![_y bound])
         [_y whenChangeBoundsPropagate:self];
   } else {
      if ([_x max] <= [_y min])
         [_b bind:YES];
      else if ([_x min] > [_y max])
         [_b bind:NO];
      else {
         [_x whenChangeBoundsPropagate:self];
         [_y whenChangeBoundsPropagate:self];
         [_b whenBindPropagate:self];
      }
   }
}
-(void)propagate
{
   if (bound(_b)) {
      if (minDom(_b)) {
         [_x updateMax:fp_previous_float([_y max])];
         [_y updateMin:fp_next_float([_x min])];
      } else {
         [_y updateMax:[_x max]];
         [_x updateMin:[_y min]];
      }
   } else {
      if ([_x max] <= [_y min]) {
         assignTRInt(&_active, NO, _trail);
         bindDom(_b,YES);
      } else if ([_x min] > [_y max]) {
         assignTRInt(&_active, NO, _trail);
         bindDom(_b,NO);
      }
   }
}
-(NSString*)description
{
   return [NSMutableString stringWithFormat:@"<CPFloatReifyLThen:%02d %@ <=> (%@ < %@)>",_name,_b,_x,_y];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,_b, nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_y,_b,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_y bound] + ![_b bound];
}
@end




@implementation CPFloatReifyEqualc
-(id) initCPReifyEqualc:(CPIntVar*)b when:(CPFloatVarI*)x eqi:(ORFloat)c
{
   self = [super initCPCoreConstraint:[x engine]];
   _b = b;
   _x = x;
   _c = c;
   return self;
}
-(void) post
{
   if ([_b bound]) {
      if ([_b min] == true)
         [_x bind:_c];
      else
         [[_b engine] addInternal: [CPFactory floatNEqualc:_x to:_c]];     // Rewrite as x!=c  (addInternal can throw)
   }
   else if ([_x bound])
      [_b bind:[_x min] == _c];
   else if (![_x member:_c])
      [_b bind:false];
   else {
      [_b setBindTrigger: ^ {
         if ([_b min] == true) {
            [_x bind:_c];
         } else {
            [[_b engine] addInternal: [CPFactory floatNEqualc:_x to:_c]];     // Rewrite as x!=c  (addInternal can throw)
         }
      } onBehalf:self];
      [_x whenChangeBoundsDo: ^ {
         if ([_x bound])
            [_b bind:[_x min] == _c];
         else if (![_x member:_c])
            [_b remove:true];
      } onBehalf:self];
      [_x whenBindDo: ^ {
         [_b bind:[_x min] == _c];
      } onBehalf:self];
   }
}
-(NSString*)description
{
   return [NSMutableString stringWithFormat:@"<CPFloatReifyEqual:%02d %@ <=> (%@ == %16.16e)>",_name,_b,_x,_c];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_b, nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_b,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_b bound];
}
@end

@implementation CPFloatReifyLEqualc
-(id) initCPReifyLEqualc:(CPIntVar*)b when:(CPFloatVarI*)x leqi:(ORFloat)c
{
   self = [super initCPCoreConstraint:[x engine]];
   _b = b;
   _x = x;
   _c = c;
   return self;
}
-(void) post
{
   if ([_b bound]) {
      if ([_b min])
         [_x updateMax:_c];
      else
         [_x updateMin:fp_next_float(_c)];
   }
   else if ([_x max] <= _c)
      [_b bind:YES];
   else if ([_x min] > _c)
      [_b bind:NO];
   else {
      [_b whenBindPropagate:self];
      [_x whenChangeBoundsPropagate:self];
   }
}
-(void) propagate
{
   if (bound(_b)) {
      assignTRInt(&_active, NO, _trail);
      if (minDom(_b))
         [_x updateMax:_c];
      else
         [_x updateMin:fp_next_float(_c)];
   } else {
      if ([_x min] > _c) {
         assignTRInt(&_active, NO, _trail);
         bindDom(_b, NO);
      } else if ([_x max] <= _c) {
         assignTRInt(&_active, NO, _trail);
         bindDom(_b, YES);
      }
   }
}
-(NSString*)description
{
   return [NSMutableString stringWithFormat:@"<CPFloatReifyLThen:%02d %@ <=> (%@ <= %16.16e)>",_name,_b,_x,_c];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_b, nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_b,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_b bound];
}
@end


@implementation CPFloatReifyLThenc
-(id) initCPReifyLThenc:(CPIntVar*)b when:(CPFloatVarI*)x lti:(ORFloat)c
{
   self = [super initCPCoreConstraint:[x engine]];
   _b = b;
   _x = x;
   _c = c;
   return self;
}
-(void) post
{
   if ([_b bound]) {
      if ([_b min]) // x < c
         [_x updateMax:fp_previous_float(_c)];
      else // x >= c
         [_x updateMin:_c];
   }
   else if ([_x max] < _c)
      [_b bind:YES];
   else if ([_x min] >= _c)
      [_b bind:NO];
   else {
      [_b whenBindPropagate:self];
      [_x whenChangeBoundsPropagate:self];
   }
}
-(void) propagate
{
   if (bound(_b)) {
      if (minDom(_b))
         [_x updateMax:fp_previous_float(_c)];
      else
         [_x updateMin:_c];
      assignTRInt(&_active, NO, _trail);
   } else {
      if ([_x min] >= _c) {
         assignTRInt(&_active, NO, _trail);
         bindDom(_b, NO);
      } else if ([_x max] < _c) {
         assignTRInt(&_active, NO, _trail);
         bindDom(_b, YES);
      }
   }
}
-(NSString*)description
{
   return [NSMutableString stringWithFormat:@"<CPFloatReifyLThenc:%02d %@ <=> (%@ < %16.16e)>",_name,_b,_x,_c];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_b, nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_b,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_b bound];
}
@end


@implementation CPFloatReifyNotEqualc
-(id) initCPReifyNotEqualc:(CPIntVar*)b when:(CPFloatVarI*)x neqi:(ORFloat)c
{
   self = [super initCPCoreConstraint:[x engine]];
   _b = b;
   _x = x;
   _c = c;
   return self;
}
-(void) post
{
   if ([_b bound]) {
      if ([_b min] == true)
         [[_b engine] addInternal: [CPFactory floatNEqualc:_x to:_c]];     // Rewrite as x!=c  (addInternal can throw)
      else
         [_x bind:_c];
   }
   else if ([_x bound])
      [_b bind:[_x min] != _c];
   else if (![_x member:_c])
      [_b remove:false];
   else {
      [_b whenBindDo: ^void {
         if ([_b min]==true)
            [[_b engine] addInternal: [CPFactory floatNEqualc:_x to:_c]];     // Rewrite as x!=c  (addInternal can throw)
         else
            [_x bind:_c];
      } onBehalf:self];
      [_x whenChangeBoundsDo:^{
         if ([_x bound])
            [_b bind:[_x min] != _c];
         else if (![_x member:_c])
            [_b remove:false];
      } onBehalf:self];
      [_x whenBindDo: ^(void) { [_b bind:[_x min] != _c];} onBehalf:self];
   }
}
-(NSString*)description
{
   return [NSMutableString stringWithFormat:@"<CPFloatReifyNotEqualc:%02d %@ <=> (%@ != %16.16e)>",_name,_b,_x,_c];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_b, nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_b,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_b bound];
}
@end

@implementation CPFloatReifyGEqualc
-(id) initCPReifyGEqualc:(CPIntVar*)b when:(CPFloatVarI*)x geqi:(ORFloat)c
{
   self = [super initCPCoreConstraint:[x engine]];
   _b = b;
   _x = x;
   _c = c;
   return self;
}
-(void) post  // b <=>  x >= c
{
   if ([_b bound]) {
      if ([_b min])
         [_x updateMin:_c];
      else
         [_x updateMax:fp_previous_float(_c)];
   }
   else if ([_x min] >= _c)
      [_b bind:YES];
   else if ([_x max] < _c)
      [_b bind:NO];
   else {
      [_b whenBindPropagate:self];
      [_x whenChangeBoundsPropagate:self];
   }
}
-(void) propagate
{
   if (bound(_b)) {
      assignTRInt(&_active, NO, _trail);
      if (minDom(_b))
         [_x updateMin:_c];
      else
         [_x updateMax:fp_previous_float(_c)];
   } else {
      if ([_x min] >= _c) {
         assignTRInt(&_active, NO, _trail);
         bindDom(_b,YES);
      } else if ([_x max] < _c) {
         assignTRInt(&_active, NO, _trail);
         bindDom(_b,NO);
      }
   }
}
-(NSString*)description
{
   return [NSMutableString stringWithFormat:@"<CPFloatReifyGEqualc:%02d %@ <=> (%@ >= %16.16e)>",_name,_b,_x,_c];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_b, nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_b,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_b bound];
}
@end


@implementation CPFloatReifyGThenc
-(id) initCPReifyGThenc:(CPIntVar*)b when:(CPFloatVarI*)x gti:(ORFloat)c
{
   self = [super initCPCoreConstraint:[x engine]];
   _b = b;
   _x = x;
   _c = c;
   return self;
}
-(void) post  // b <=>  x > c
{
   if ([_b bound]) {
      if ([_b min])
         [_x updateMin:fp_next_float(_c)];
      else // x <= c
         [_x updateMax:_c];
   }
   else if ([_x min] > _c)
      [_b bind:YES];
   else if ([_x max] <= _c)
      [_b bind:NO];
   else {
      [_b whenBindPropagate:self];
      [_x whenChangeBoundsPropagate:self];
   }
}
-(void) propagate
{
   if (bound(_b)) {
      assignTRInt(&_active, NO, _trail);
      if (minDom(_b))
         [_x updateMin:fp_next_float(_c)];
      else
         [_x updateMax:_c];
   } else {
      if ([_x min] > _c) {
         assignTRInt(&_active, NO, _trail);
         bindDom(_b,YES);
      } else if ([_x max] <= _c) {
         assignTRInt(&_active, NO, _trail);
         bindDom(_b,NO);
      }
   }
}
-(NSString*)description
{
   return [NSMutableString stringWithFormat:@"<CPFloatReifyGEqualc:%02d %@ <=> (%@ > %16.16e)>",_name,_b,_x,_c];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_b, nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_b,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_b bound];
}
@end
