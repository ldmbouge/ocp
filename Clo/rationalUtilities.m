//
//  rationalUtilities.m
//  Clo
//
//  Created by remy on 05/04/2018.
//
//

#include "rationalUtilities.h"

#define R_IS_ZERO(Q) ((((Q)->rational->_mp_num._mp_size) == 0)?1:0)
#define R_IS_NONZERO(Q) ((((Q)->rational->_mp_num._mp_size) == 0)?0:1)
#define R_IS_POSITIVE(Q) ((0 <= ((Q)->rational->_mp_num._mp_size))?1:0)
#define R_IS_NEGATIVE(Q) ((((Q)->rational->_mp_num._mp_size) <= 0)?1:0)
#define R_IS_STRICTLY_POSITIVE(Q) ((0 < ((Q)->rational->_mp_num._mp_size))?1:0)
#define R_IS_STRICTLY_NEGATIVE(Q) ((((Q)->rational->_mp_num._mp_size) < 0)?1:0)

#define R_SET_ZERO(Q) { mpq_set_ui(((Q)->rational),0UL,1UL); (Q)->type = 0; }
#define R_SET_POS_ONE(Q) { mpq_set_ui(((Q)->rational),1UL,1UL); Q->type = 1; }
#define R_SET_NEG_ONE(Q) { mpq_set_si(((Q)->rational),-1L,1UL); (Q)->type = -1; }
#define R_SET_NAN(Q) { mpz_set_ui(mpq_numref((Q)->rational),0UL); mpz_set_ui(mpq_denref((Q)->rational),0UL); (Q)->type = 3; }
#define R_SET_POS_INF(Q) { mpz_set_ui(mpq_numref((Q)->rational),1UL); mpz_set_ui(mpq_denref((Q)->rational),0UL); (Q)->type = 2; }
#define R_SET_NEG_INF(Q) { mpz_set_si(mpq_numref((Q)->rational),-1L); mpz_set_ui(mpq_denref((Q)->rational),0UL); (Q)->type = -2; }

#define RI_SET_ZERO(RIA) { R_SET_ZERO(&(RIA)->inf); R_SET_ZERO(&(RIA)->sup); }
#define RI_SET_NAN(RIA)  { R_SET_NAN(&(RIA)->inf); R_SET_NAN(&(RIA)->sup); }
#define RI_SET_POS_INF(RIA)  { R_SET_POS_INF(&(RIA)->inf); R_SET_POS_INF(&(RIA)->sup); }
#define RI_SET_NEG_INF(RIA)  { R_SET_NEG_INF(&(RIA)->inf); R_SET_NEG_INF(&(RIA)->sup); }

void rational_init(ORRational* r){
   mpq_init(r->rational);
   r->type = 0;
}

void rational_clear(ORRational* r){
   mpq_clear(r->rational);
}

void rational_print(const ORRational* r){
   switch (r->type) {
      case -2:
         NSLog(@"-INF");
         break;
      case 2:
         NSLog(@"+INF");
         break;
      case 3:
         NSLog(@"NaN");
         break;
      default:
         NSLog(@"%24.24e", rational_get_d(r));
         break;
   }
}

char * rational_get_str(const ORRational* r){
   switch (r->type) {
      case -2:
         return "-INF";
         break;
      case 2:
         return "+INF";
         break;
      case 3:
         return "NaN";
         break;
      default:
         return mpq_get_str(NULL, 10, r->rational);
         break;
   }
}

void rational_set_d(ORRational* r, const double d){
   if (d == -INFINITY) {
      R_SET_NEG_INF(r);
   } else if (d == +INFINITY) {
      R_SET_POS_INF(r);
   } else if (isnan(d)){
      R_SET_NAN(r);
   } else {
      mpq_set_d(r->rational, d);
      r->type = mpq_sgn(r->rational);
      mpq_canonicalize(r->rational);
   }
}

void rational_set(ORRational* r, const ORRational* x){
   mpq_set(r->rational, x->rational);
   r->type = x->type;
}

double rational_get_d(const ORRational* r){
   switch (r->type) {
      case -2:
         return -INFINITY;
         break;
      case 2:
         return INFINITY;
         break;
      case 3:
         return NAN;
         break;
      default:
         return mpq_get_d(r->rational);
         break;
   }
}

void rational_addition(ORRational* z, const ORRational* x, const ORRational* y){
   /* x = NaN || y = NaN */
   if(x->type == 3 || y->type == 3){
      /* z = NaN */
      R_SET_NAN(z);
   }
   /* (x = -inf && y = inf) || (x = inf && y = -inf) */
   else if((x->type == -2 && y->type == 2) || (x->type == 2 && y->type == -2)){
      /* z = NaN */
      R_SET_NAN(z);
   }
   /* (x = -inf || y = -inf) */
   else if(x->type == -2 || y->type == -2){
      /* z = -inf */
      R_SET_NEG_INF(z);
   }
   /* (x = inf || y = inf) */
   else if((x->type == 2 || y->type == 2)){
      /* z = inf */
      R_SET_POS_INF(z);
   }
   /* x = Q && y = Q */
   else {
      mpq_add(z->rational, x->rational, y->rational);
      z->type = mpq_sgn(z->rational);
   }
}

void rational_subtraction(ORRational* z, const ORRational* x, const ORRational* y){
   /* x = NaN || y = NaN */
   if(x->type == 3 || y->type == 3){
      /* z = NaN */
      R_SET_NAN(z);
   }
   /* (x = -inf && y = -inf) || (x = inf && y = inf) */
   else if((x->type == -2 && y->type == -2) || (x->type == 2 && y->type == 2)){
      /* z = NaN */
      R_SET_NAN(z);
   }
   /* (x = -inf || y = inf) */
   else if((x->type == -2) || (y->type == 2)){
      /* z = -inf */
      R_SET_NEG_INF(z);
   }
   /* (x = inf || y = -inf) */
   else if((x->type == 2) || (y->type == -2)){
      /* z = inf */
      R_SET_POS_INF(z);
   }
   /* x = Q && y = Q */
   else {
      mpq_sub(z->rational, x->rational, y->rational);
      z->type = mpq_sgn(z->rational);
   }
}

void rational_multiplication(ORRational* z, const ORRational* x, const ORRational* y){
   /* x = NaN || y = NaN */
   if(x->type == 3 || y->type == 3){
      /* z = NaN */
      R_SET_NAN(z);
   }
   /*
    (x =  0    && y = -inf) ||
    (x = -inf  && y =  0)   ||
    (x =  inf  && y =  0)   ||
    (x =  0    && y =  inf)
    */
   else if((x->type == -2 && y->type == 0) || (x->type == 0 && y->type == -2) || (x->type == 2 && y->type == 0) || (x->type == 0 && y->type == 2)){
      /* z = NaN */
      R_SET_NAN(z);
   }
   /*
    (x = -inf && (y = PR || y =  inf)) ||
    (y = -inf && (x = PR || x =  inf)) ||
    (x = inf  && (y = NR || y = -inf)) ||
    (y = inf  && (x = NR || x = -inf))
    */
   else if((x->type == -2  && (y->type ==  1 || y->type ==  2)) ||
           (y->type == -2  && (x->type ==  1 || x->type ==  2)) ||
           (x->type ==  2  && (y->type == -1 || y->type == -2)) ||
           (y->type ==  2  && (x->type == -1 || x->type == -2))){
      /* z = -inf */
      R_SET_NEG_INF(z);
   }
   /*
    (x = -inf && (y = -inf || y = NR)) ||
    (y = -inf && (x = -inf || x = NR)) ||
    (x = inf  && (y =  inf || y = PR)) ||
    (y = inf  && (x =  inf || x = PR))
    */
   else if((x->type == -2  && (y->type == -2 || y->type == -1)) ||
           (y->type == -2  && (x->type == -2 || x->type == -1)) ||
           (x->type ==  2  && (y->type ==  2 || y->type ==  1)) ||
           (y->type ==  2  && (x->type ==  2 || x->type ==  1))){
      /* z = inf */
      R_SET_POS_INF(z);
   }
   /* x = Q && y = Q */
   else {
      mpq_mul(z->rational, x->rational, y->rational);
      z->type = mpq_sgn(z->rational);
   }
}

void rational_division(ORRational* z, const ORRational* x, const ORRational* y){
   /* x = NaN || y = NaN */
   if(x->type == 3 || y->type == 3){
      /* z = NaN */
      R_SET_NAN(z);
   }
   /*
    (x = -inf  && y = -inf) ||
    (x = -inf  && y =  inf) ||
    (x =  inf  && y = -inf) ||
    (x =  inf  && y =  inf) ||
    (y =  0)
    */
   else if((x->type == -2 && y->type ==  2) ||
           (x->type == -2 && y->type == -2) ||
           (x->type ==  2 && y->type ==  2) ||
           (x->type ==  2 && y->type == -2) ||
           (y->type ==  0)){
      /* z = NaN */
      R_SET_NAN(z);
   }
   /*
    (x = -inf && y = PR) ||
    (x =  inf && y = NR)
    */
   else if((x->type == -2 && y->type == 1) ||
           (x->type == 2 && y->type == -1)){
      /* z = -inf */
      R_SET_NEG_INF(z);
   }
   /*
    (x = -inf && y = NR) ||
    (x =  inf && y = PR)
    */
   else if((x->type == -2 && y->type == -1) ||
           (x->type ==  2 && y->type ==  1)){
      /* z = inf */
      R_SET_POS_INF(z);
   } else if(y->type == -2 || y->type == 2) {
      /* z = 0 */
      R_SET_ZERO(z);
   }
   /* x = Q && y = Q */
   else {
      mpq_div(z->rational, x->rational, y->rational);
      z->type = mpq_sgn(z->rational);
   }
}

void rational_neg(ORRational* z, const ORRational* x){
   /* z = -x */
   switch (x->type) {
      case -2:
         R_SET_POS_INF(z);
         break;
      case 2:
         R_SET_NEG_INF(z);
         break;
      case 3:
         R_SET_NAN(z);
         break;
      default:
         mpq_neg(z->rational, x->rational);
         z->type = - x->type;
         break;
   }
}

void rational_abs(ORRational* z, const ORRational* x){
   if(x->type == 3){
      R_SET_NAN(z);
   } else if(x->type == -2){
      R_SET_POS_INF(z);
   } else if(x->type == 2){
      R_SET_NEG_INF(z);
   } else {
      mpq_abs(z->rational, x->rational);
      z->type = mpq_sgn(z->rational);
   }
}

int rational_cmp(const ORRational* x, const ORRational* y){
   if(rational_eq(x, y)){
      return 0;
   } else if(rational_gt(x, y)){
      return 1;
   } else {
      return -1;
   }
}

int rational_cmp_ui(const ORRational* x, const long int num2, const long int den2){
   return mpq_cmp_ui(x->rational, num2, den2);
}

int rational_lt(const ORRational* x, const ORRational* y){
   /* x < y */
   if(x->type == 3 || y->type == 3){
      return 0;
   } else if(x->type == 2 || y->type == -2){
      return 0;
   } else if(x->type == y->type && (x->type == -2)){
      return 0;
   } else if(x->type == -2){
      return 1;
   } else{
      return (mpq_cmp(x->rational, y->rational) < 0);
   }
}

int rational_gt(const ORRational* x, const ORRational* y){
   /* x > y */
   if(x->type == 3 || y->type == 3){
      return 0;
   } else if(x->type == -2 || y->type == 2){
      return 0;
   } else if(x->type == y->type && (x->type == 2)){
      return 0;
   } else if(x->type == 2){
      return 1;
   } else{
      return (mpq_cmp(x->rational, y->rational) > 0);
   }
}

int rational_leq(const ORRational* x, const ORRational* y){
   /* x <= y */
   if(x->type == 3 || y->type == 3){
      return 0;
   } else if((x->type == -2 || x->type == 2) && (x->type == y->type)){
      return 1;
   } else if(x->type == 2 || y->type == -2){
      return 0;
   } else if(x->type == -2){
      return 1;
   } else{
      return (mpq_cmp(x->rational, y->rational) <= 0);
   }
}

int rational_geq(const ORRational* x, const ORRational* y){
   /* x >= y */
   if(x->type == 3 || y->type == 3){
      return 0;
   } else if((x->type == -2 || x->type == 2) &&
             (x->type == y->type)){
      return 1;
   } else if(x->type == -2 || y->type == 2){
      return 0;
   } else if(x->type == 2){
      return 1;
   } else{
      return (mpq_cmp(x->rational, y->rational) >= 0);
   }
}

int rational_eq(const ORRational* x, const ORRational* y){
   /* x == y */
   if(x->type == 3 || y->type == 3){
      return 0;
   } else if(x->type != y->type){
      return 0;
   } else if((x->type == -2 || x->type == -2) &&
             (x->type == y->type)){
      return 1;
   } else {
      return mpq_equal(x->rational, y->rational);
   }
}

int rational_neq(const ORRational* x, const ORRational* y){
   /* x != y */
   return !rational_eq(x, y);
}


/* RATIONAL INTERVAL FUNCTIONS */
void ri_set_d(ri* z, double inf, double sup) {
   rational_set_d(&z->inf, inf);
   rational_set_d(&z->sup, sup);
}

void ri_set_q(ri* z, const ORRational* inf, const ORRational* sup) {
   rational_set(&z->inf, inf);
   rational_set(&z->sup, sup);
}

void ri_set(ri* z, ri* x){
   ri_set_q(z, &x->inf, &x->sup);
}

void ri_print(NSString *s, ri* x){
   NSLog(@"%@ : [% 24.24e, % 24.24e]", s, rational_get_d(&x->inf), rational_get_d(&x->sup));
}

int ri_is_empty(const ri* x){
   return   (x->inf.type == 3 || x->sup.type == 3)  ||
            (x->inf.type == 2 && x->sup.type < 2)   ||
            (x->sup.type == -2 && x->inf.type > -2) ||
            rational_gt(&x->inf, &x->sup);
}

void ri_union(ri* z, const ri* x, const ri* y){
   
   if(x->inf.type == 3 || x->sup.type == 3 || y->inf.type == 3 || y->sup.type == 3){
      RI_SET_NAN(z);
   } else {
      /* lower bound */
      if(x->inf.type == -2 || y->inf.type == -2){
         R_SET_NEG_INF(&z->inf);
      } else if(x->inf.type == 2 || y->inf.type == 2){
         R_SET_POS_INF(&z->inf);
      } else if(rational_leq(&x->inf, &y->inf)){
         rational_set(&z->inf, &x->inf);
      } else {
         rational_set(&z->inf, &y->inf);
      }
      /* upper bound */
      if(x->sup.type == -2 || y->sup.type == -2){
         R_SET_NEG_INF(&z->inf);
      } else if(x->sup.type == 2 || y->sup.type == 2){
         R_SET_POS_INF(&z->sup);
      } else if(rational_geq(&x->sup, &y->sup)){
         rational_set(&z->sup, &x->sup);
      } else {
         rational_set(&z->sup, &y->sup);
      }
      
      if(ri_is_empty(z))
         RI_SET_NAN(z);
   }
}

void ri_intersection(ri* z, const ri* x, const ri* y){
   if(x->inf.type == 3 || x->sup.type == 3 || y->inf.type == 3 || y->sup.type == 3){
      RI_SET_NAN(z);
   } else {
      /* lower bound */
      if(x->inf.type == -2 || y->inf.type == -2){
         R_SET_NEG_INF(&z->inf);
      } else if(x->inf.type == 2 || y->inf.type == 2){
         R_SET_POS_INF(&z->inf);
      } else if(rational_leq(&x->inf, &y->inf)){
         rational_set(&z->inf, &y->inf);
      } else {
         rational_set(&z->inf, &x->inf);
      }
      /* upper bound */
      if(x->sup.type == -2 || y->sup.type == -2){
         R_SET_NEG_INF(&z->inf);
      } else if(x->sup.type == 2 || y->sup.type == 2){
         R_SET_POS_INF(&z->sup);
      } else if(rational_geq(&x->sup, &y->sup)){
         rational_set(&z->sup, &y->sup);
      } else {
         rational_set(&z->sup, &x->sup);
      }
      
      if(ri_is_empty(z))
         RI_SET_NAN(z);
   }
}

int ri_proj_inter(ri* x, const ri* y){
   if(ri_is_empty(x) || ri_is_empty(y))
      failNow();
   
   int changed = 0;
   ORRational o_size, n_size;
   rational_init(&o_size);
   rational_init(&n_size);
   rational_subtraction(&o_size, &x->sup, &x->inf);
   
   if(rational_lt(&x->inf, &y->inf)){
      rational_set(&x->inf, &y->inf);
      changed = 1;
   }
   
   if(rational_gt(&x->sup, &y->sup)){
      rational_set(&x->sup, &y->sup);
      changed |= 2;
   }
   
   if(ri_is_empty(x))
      failNow();
   
   if(changed){
      rational_subtraction(&n_size, &x->sup, &x->inf);
      rational_subtraction(&n_size, &o_size, &n_size);
      rational_division(&o_size, &n_size, &o_size);
      
      if(rational_get_d(&o_size) <= 0.05)
         changed = 0;
   }
   
   return changed;
}

int ri_proj_inter_infsup(ri* x, const ORRational* inf, const ORRational* sup){
   if(x->inf.type == 3 || x->sup.type == 3 || inf->type == 3 || sup->type == 3 || ri_is_empty(x))
      failNow();
   
   int changed = 0;
   ORRational o_size, n_size;
   rational_init(&o_size);
   rational_init(&n_size);
   rational_subtraction(&o_size, &x->sup, &x->inf);
   
   if(rational_lt(&x->inf, inf)){
      rational_set(&x->inf, inf);
      changed = 1;
   }
   
   if(rational_gt(&x->sup, sup)){
      rational_set(&x->sup, sup);
      changed |= 2;
   }
   
   if(ri_is_empty(x))
      failNow();
   
   if(changed){
      rational_subtraction(&n_size, &x->sup, &x->inf);
      rational_subtraction(&n_size, &o_size, &n_size);
      rational_division(&o_size, &n_size, &o_size);
      
      if(rational_get_d(&o_size) <= 0.05)
         changed = 0;
   }

   return changed;
}

void ri_init(ri* a){
   rational_init(&a->inf);
   rational_init(&a->sup);
}

void ri_clear(ri* a){
   rational_clear(&a->inf);
   rational_clear(&a->sup);
}

void ri_add(ri* a, const ri* b, const ri* c){
   rational_addition(&a->inf, &b->inf, &c->inf);
   rational_addition(&a->sup, &b->sup, &c->sup);
}

void ri_sub(ri* a, const ri* b, const ri* c){
   rational_subtraction(&a->inf, &b->inf, &c->sup);
   rational_subtraction(&a->sup, &b->sup, &c->inf);
}

void ri_mul(ri* r, const ri* a, const ri* b){
   if(a->inf.type >= 0 ) {                            /* A >= 0 */
      if (b->inf.type >= 0) {                          /* B >= 0 */
         rational_multiplication(&r->inf, &a->inf, &b->inf);
         rational_multiplication(&r->sup, &a->sup, &b->sup);
      }
      else if (b->sup.type <= 0) {                          /* B <= 0 */
         rational_multiplication(&r->inf, &a->sup, &b->inf);
         rational_multiplication(&r->sup, &a->inf, &b->sup);
      }
      else {                                              /* 0 in B */
         rational_multiplication(&r->inf, &a->sup, &b->inf);
         rational_multiplication(&r->sup, &a->sup, &b->sup);
      }
   }
   else if (&a->sup.type <= 0) {                            /* A <= 0 */
      if (&b->inf.type >= 0) {                          /* B >= 0 */
         rational_multiplication(&r->inf, &a->inf, &b->sup);
         rational_multiplication(&r->sup, &a->sup, &b->inf);
      }
      else if (b->sup.type <= 0) {                          /* B <= 0 */
         rational_multiplication(&r->inf, &a->sup, &b->sup);
         rational_multiplication(&r->sup, &a->inf, &b->inf);
      }
      else {                                              /* 0 in B */
         rational_multiplication(&r->inf, &a->inf, &b->sup);
         rational_multiplication(&r->sup, &a->inf, &b->inf);
      }
   }
   else {                                                /* 0 in A */
      if (b->inf.type >= 0) {                          /* B >= 0 */
         rational_multiplication(&r->inf, &a->inf, &b->sup);
         rational_multiplication(&r->sup, &a->sup, &b->sup);
      }
      else if (b->sup.type <= 0) {                          /* B <= 0 */
         rational_multiplication(&r->inf, &a->sup, &b->inf);
         rational_multiplication(&r->sup, &a->inf, &b->inf);
      }
      else {                                              /* 0 in B */
         ri tmp;
         ri_init(&tmp);
         
         rational_multiplication(&tmp.inf, &a->inf, &b->sup);
         rational_multiplication(&tmp.sup, &a->sup, &b->inf);

         if(rational_lt(&tmp.inf, &tmp.sup)){
            rational_set(&r->inf, &tmp.inf);
         } else {
            rational_set(&r->inf, &tmp.sup);
         }
         
         rational_multiplication(&tmp.inf, &a->inf, &b->inf);
         rational_multiplication(&tmp.sup, &a->sup, &b->sup);

         if(rational_gt(&tmp.inf, &tmp.sup)){
            rational_set(&r->sup, &tmp.inf);
         } else {
            rational_set(&r->sup, &tmp.sup);
         }
         ri_clear(&tmp);
      }
   }
}

void ri_div(ri* r, const ri* a, const ri* b){
   if (a->inf.type >= 0) {                            /* A >= 0 */
      if (b->inf.type > 0) {     /* B >  0 */
         rational_division(&r->inf, &a->inf, &b->sup);
         rational_division(&r->sup, &a->sup, &b->inf);
      }
      else if (b->sup.type < 0) {       /* B <  0 */
         rational_division(&r->inf, &a->sup, &b->sup);
         rational_division(&r->sup, &a->inf, &b->inf);
      }
      else                                                /* 0 in B */
         if(a->inf.type == 0){
            RI_SET_NAN(r);
         } else{
            R_SET_NEG_INF(&r->inf);
            R_SET_POS_INF(&r->sup);
         }
      
   }
   else if (a->sup.type <= 0) {                            /* A <= 0 */
      if (b->inf.type > 0) {     /* B >  0 */
         rational_division(&r->inf, &a->inf, &b->inf);
         rational_division(&r->sup, &a->sup, &b->sup);
      }
      else if (b->sup.type < 0) {       /* B <  0 */
         rational_division(&r->inf, &a->sup, &b->inf);
         rational_division(&r->sup, &a->inf, &b->sup);
      }
      else                                                /* 0 in B */
         if(a->sup.type == 0){
            RI_SET_NAN(r);
         } else{
            R_SET_NEG_INF(&r->inf);
            R_SET_POS_INF(&r->sup);
         }
   }
   else {                                                /* 0 in A */
      if (b->inf.type > 0) {     /* B >  0 */
         rational_division(&r->inf, &a->inf, &b->inf);
         rational_division(&r->sup, &a->sup, &b->inf);
      }
      else if (b->sup.type < 0) {       /* B <  0 */
         rational_division(&r->inf, &a->sup, &b->sup);
         rational_division(&r->sup, &a->inf, &b->inf);
      }
      else                                                /* 0 in B */
         RI_SET_NAN(r);
   }
}

void ri_neg(ri* z, const ri* x){
   rational_neg(&z->inf, &x->sup);
   rational_neg(&z->sup, &x->inf);
}

void ri_abs(ri* z, const ri* x){
   rational_abs(&z->inf, &x->inf);
   rational_abs(&z->sup, &x->sup);
}

int ri_cmp(const ri* x, const ri* y){
   if(ri_eq(x, y)){
      return 0;
   } else if(ri_gt(x, y)){
      return 1;
   } else {
      return -1;
   }
}

int ri_lt(const ri* x, const ri* y){
   return rational_lt(&x->inf, &y->inf) && rational_lt(&x->sup, &y->sup);
}

int ri_gt(const ri* x, const ri* y){
   return rational_gt(&x->inf, &y->inf) && rational_gt(&x->sup, &y->sup);
}

int ri_leq(const ri* x, const ri* y){
   return rational_leq(&x->inf, &y->inf) && rational_leq(&x->sup, &y->sup);
}

int ri_geq(const ri* x, const ri* y){
   return rational_geq(&x->inf, &y->inf) && rational_geq(&x->sup, &y->sup);
}

int ri_eq(const ri* x, const ri* y){
   return rational_eq(&x->inf, &y->inf) && rational_eq(&x->sup, &y->sup);
}

int ri_neq(const ri* x, const ri* y){
      return !rational_eq(&x->inf, &y->inf) && !rational_eq(&x->sup, &y->sup);
}
