/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/


#import "ORInterval.h"
#include <string.h>
#include <float.h>
#include <stdio.h>
#include <math.h>
#include <fenv.h>
#include <limits>
//#include <immintrin.h>
//#include <smmintrin.h>
#include <assert.h>

#if !defined(__APPLE__)
#define FALSE 0
#define TRUE 1
#endif

@interface ORILib : NSObject
+(void)load;
@end

@implementation ORILib
+(void)load
{
   ORIInit();
   //NSLog(@"ORILib::load called...");
   @autoreleasepool {
      NSLog(@"Infinity: %@",ORIFormat(INF));
//      NSLog(@"Epsilon : %@",ORIFormat(EPSILON));
      NSLog(@"Zero    : %@",ORIFormat(ZERO));
//      NSLog(@"Flip    : %@",ORIFormat(FLIP));
   }
}
@end

static int bigendian;

ORInterval INF;
ORInterval FLIP;
ORInterval EPSILON;
ORInterval ZERO;
ORInterval OR_PI,OR_PI2,OR_PI4,OR_3PI2,OR_2PI,OR_5PI2,OR_7PI2,OR_9PI2;
ORInterval OR_PEXP,OR_PLN2,OR_PLN2i,OR_PLN10,OR_PLN10i;
ORInterval OR_EC1,OR_EC2,OR_EXPRANGE,OR_ERANGE,OR_LOGE; // internal

double pinf = 0;
double ninf = 0;
static double T_EPSL,T_EPSU;
static double sc0,sc1,sc2,sc3,sc4,sc5;
static double cc0,cc1,cc2,cc3,cc4,cc5,cc6;
static double P1,P2,P3;

static double LOG_p0,LOG_p1,LOG_p2,LOG_p3,LOG_p4,LOG_p5,LOG_p6;
static double LOG_q0,LOG_q1,LOG_q2,LOG_q3,LOG_q4,LOG_q5,LOG_q6;
static double LOG_r0,LOG_r1,LOG_r2;
static double LOG_s0,LOG_s1,LOG_s2;

#define   EXP_p2  1.26183092834458542160e-4
#define   EXP_p1  3.029968876584301292e-2
#define   EXP_p0  1.0
#define   EXP_q3  3.00227947279887615146e-6
#define   EXP_q2  2.52453653553222894311e-3
#define   EXP_q1  2.27266044198352679519e-1
#define   EXP_q0  2.00000000000000000005
#define   SQRTH 0.70710678118654752440


static double ErangeLow, ErangeUp;
static double N_MAXEXP_V;  /* largest exp result */
static double N_MINEXP_V;  /* smallest exp result */
static double N_MAXLOG;    /* maximum value for exp/1 */
static double N_MAXNUM;
static double N_MACHEP;
static double N_EC1L;
static double N_EC1U;
static double N_EC2L;
static double N_EC2U;
static double N_LOGEL;
static double N_LOGEU;
static double E_EPSL;      // Epsilon for lower approximation of functions 
static double E_EPSU;      // Epsilon for upper approximation of functions 
static double N_EL,N_EU;
static double N_LN2L,N_LN2U;
static double N_LN10L,N_LN10U;


#define PACKDBL(x,a,b,c,d) do { \
   unsigned short* ptr = (unsigned short*)&x; \
   ptr[0] = bigendian ? a : d; \
   ptr[1] = bigendian ? b : c; \
   ptr[2] = bigendian ? c : b; \
   ptr[3] = bigendian ? d : a; \
} while(0)


ORInterval ORIFloor(ORInterval a)
{
   return _mm_floor_pd(a);
}

// ===========================================================================================
// TRIGO
// ===========================================================================================

typedef enum {OR_BEFPI2,OR_ATPI2,OR_BETPI2_3PI2,
   OR_AT3PI2,OR_BET3PI2_5PI2,
   OR_AT5PI2,OR_BET5PI2_7PI2,
   OR_AT7PI2,OR_BET7PI2_9PI2,
   OR_AT9PI2,
   OR_NUTS
   } ORSinePhase;

static ORSinePhase detectSinePhase(double a)
{
   //ORInterval i0 = createORI2(- ORILow(OR_PI2), ORILow(OR_PI2));
   ORInterval i0 = ORIUnion(OR_PI2,ORIOpposite(OR_PI2));
   if (ORIContains(i0,a))
      return OR_BEFPI2;
   ORInterval i1 = OR_PI2;
   if (ORIContains(i1,a))
      return OR_ATPI2;
   ORInterval i2 = createORI2(ORIUp(OR_PI2),ORILow(OR_3PI2));
   if (ORIContains(i2,a))
      return OR_BETPI2_3PI2;
   ORInterval i3 = OR_3PI2;
   if (ORIContains(i3,a))
      return OR_AT3PI2;
   ORInterval i4 = createORI2(ORIUp(OR_3PI2),ORILow(OR_5PI2));
   if (ORIContains(i4,a))
      return OR_BET3PI2_5PI2;
   ORInterval i5 = OR_5PI2;
   if (ORIContains(i5,a))
      return OR_AT5PI2;
   ORInterval i6 = createORI2(ORIUp(OR_5PI2),ORILow(OR_7PI2));
   if (ORIContains(i6,a))
      return OR_BET5PI2_7PI2;
   ORInterval i7 = OR_7PI2;
   if (ORIContains(i7,a))
      return OR_AT7PI2;
   ORInterval i8 = createORI2(ORIUp(OR_7PI2),ORILow(OR_9PI2));
   if (ORIContains(i8,a))
      return OR_BET7PI2_9PI2;
   ORInterval i9 = OR_9PI2;
   if (ORIContains(i9,a))
      return OR_AT9PI2;
   return OR_NUTS;
}

static ORInterval translate(ORInterval a,BOOL* expand)
{
   *expand = FALSE;
   ORInterval ap = _mm_shuffle_pd(a,a,_MM_SHUFFLE2(1,1)); // (a.low,a.low)
   ap = _mm_xor_pd(ap,FLIP);                              // (-a.low,a.low)
   ORInterval aOver2pi = ORIMul(ap,ORInverse(OR_2PI));
   if (ORIWidth(aOver2pi) >= 1.0) {
      *expand = TRUE;
      return aOver2pi;
   } else {
      ORInterval i = ORIFloor(aOver2pi);
      i = _mm_xor_pd(_mm_shuffle_pd(i,i,_MM_SHUFFLE2(1,1)),FLIP);
      ORInterval rv = ORISub(a,ORIMul(i,OR_2PI));
      return rv;
   }
}

#define SC(x) ( (((((sc5*x + sc4)*x + sc3)*x + sc2)*x + sc1)*x + sc0) )
#define CC(x) (((((((cc6*x + cc5)*x + cc4)*x + cc3)*x + cc2)*x + cc1)*x + cc0)) 

static inline double fldexp(double x, const short i)
{
 return ( i < 0 ? x / ( 1 << -i ) : x * ( 1 << i ) );
}

static double NsinApp(double x,double y)
{
   long  pos = 1;
   double z = fldexp(y,-4);
   z = floor(z);
   z = y - fldexp(z,4);
   long j = z;
   if ( j & 1) {
      j += 1;
      y += 1.0;
   }
   j = j & 07;
   if (j > 3) {
      pos = 0;
      j -= 4;
   }
   z = ((x - y * P1) - y * P2) - y * P3;
   double zz = z * z;
   if ( ( j == 2 ) || ( j == 1 ) )
      y = 1.0 - zz * CC(zz);
   else {
      /**  Only on Haswell class processors. (Introduced 2013)
      ORInterval tx = _mm_set_sd(zz);
      ORInterval tz = _mm_set_sd(z);
      ORInterval t0 = _mm_fmadd_sd(_mm_set_sd(sc5),tx,_mm_set_sd(sc4));
      ORInterval t1 = _mm_fmadd_sd(t0,tx,_mm_set_sd(sc3));
      ORInterval t2 = _mm_fmadd_sd(t1,tx,_mm_set_sd(sc2));      
      ORInterval t3 = _mm_fmadd_sd(t2,tx,_mm_set_sd(sc1));
      ORInterval t4 = _mm_fmadd_sd(t3,tx,_mm_set_sd(sc0));
      ORInterval t5 = _mm_mul_sd(t4,tx);      
      ORInterval t6 = _mm_mul_sd(t4,tz);
      ORInterval t7 = _mm_add_sd(t6,tz);
      _mm_store_sd(&y,t7);
      **/
      y = z + z * (zz * SC(zz));
   }
   return pos ? y : -y; 
}


static ORInterval NsinLow(double x)
{
   if (x==0)
      return createORI1(0.0);
   else {
      const int pos = x < 0 ? 0 : 1;
      x = x < 0 ? -x : x;
      ORInterval xi = createORI1(x);               // x is guaranteed positive
      ORInterval den = _mm_xor_pd(OR_PI4,FLIP);    // den <- (pi+/4,pi-/4)
      den = _mm_shuffle_pd(den,den,1);             // den <- (pi-/4,pi+/4)
      ORInterval y = ORIFloor(_mm_xor_pd(_mm_div_pd(xi,den),FLIP)); // FL (-xi,xi)/(pi-/4,pi+/4)
      ORInterval eps = _mm_set1_pd(1e-16);
      while (ORIBoundsNEQ(y)) {
         ORInterval fxi = _mm_xor_pd(xi,FLIP);
         ORInterval sub = _mm_sub_pd(fxi,eps);
         xi             = _mm_xor_pd(sub,FLIP);
         y = ORIFloor(_mm_xor_pd(_mm_div_pd(xi,den),FLIP));
      }
      double u = NsinApp(ORILow(xi),ORILow(y));
      u = pos ? u : -u;
      ORInterval p = _mm_mul_pd(createORI2(T_EPSL,T_EPSU),_mm_set1_pd(u));
      if (u>0)
         return p;
      else if (u<0)
         return ORISwap(p);
      else return createORI2(-1e-16,1e-16);
   }
}
static ORInterval NsinUp(double x)
{
   if (x==0)
      return createORI1(0.0);
   else {
      const int pos = x < 0 ? 0 : 1;
      x = x < 0 ? -x : x;
      ORInterval xi = createORI1(x);
      ORInterval den = _mm_xor_pd(OR_PI4,FLIP);    // den <- (pi+/4,pi-/4)
      den = _mm_shuffle_pd(den,den,1);             // den <- (pi-/4,pi+/4)
      ORInterval y = ORIFloor(_mm_xor_pd(_mm_div_pd(xi,den),FLIP)); // flip sign to go back positive
      while (ORIBoundsNEQ(y)) {
         xi = _mm_xor_pd(_mm_add_pd(xi,createORI1(1e-16)),FLIP);
         xi = _mm_shuffle_pd(xi,xi,3);
         xi = _mm_xor_pd(xi,FLIP);
         y = ORIFloor(_mm_xor_pd(_mm_div_pd(xi,den),FLIP));
      }
      double u = NsinApp(ORILow(xi),ORILow(y));
      u = pos ? u : -u;
      ORInterval p = _mm_mul_pd(createORI2(T_EPSL,T_EPSU),_mm_set1_pd(u));
      if (u>0)
         return p;
      else if (u<0)
         return ORISwap(p);
      else return createORI2(-1e-16,1e-16);
   }
}
static ORSinePhase sineLow(double a,ORInterval* out)
{
   ORSinePhase phase = detectSinePhase(a);
   switch(phase) {
      case OR_BEFPI2:case OR_BET3PI2_5PI2:case OR_BET7PI2_9PI2:
      case OR_BETPI2_3PI2: case OR_BET5PI2_7PI2:
         *out = NsinLow(a);
         break;
      case OR_ATPI2:case OR_AT5PI2:case OR_AT9PI2: {
         ORInterval rv = NsinLow(a);
         *out = ORIUnion(rv,createORI1(1.0));
      }break;
      case OR_AT3PI2:case OR_AT7PI2: {
         ORInterval rv = NsinLow(a);
         *out = ORIUnion(rv,createORI1(-1.0));
      }break;
      default: abort();
   }
   return phase;
}
static ORSinePhase sineUp(double a,ORInterval* out)
{
   ORSinePhase phase = detectSinePhase(a);
   switch(phase) {
      case OR_BEFPI2:case OR_BET3PI2_5PI2:case OR_BET7PI2_9PI2:
      case OR_BETPI2_3PI2: case OR_BET5PI2_7PI2:
         *out = NsinUp(a);
         break;
      case OR_ATPI2:case OR_AT5PI2:case OR_AT9PI2: {
         ORInterval rv = NsinUp(a);
         *out = ORIUnion(rv,createORI1(1.0));
      }break;
      case OR_AT3PI2:case OR_AT7PI2: {
         ORInterval rv = NsinUp(a);
         *out = ORIUnion(rv,createORI1(-1.0));
      }break;
      default: abort();      
   }
   return phase;
}
ORInterval ORISine(ORInterval a)
{
   ORIReady();
   if (ORIWider(a,ORIUnion(OR_2PI,ZERO))) 
      return createORI2(-1.0,1.0);    
   BOOL expand = FALSE;
   ORInterval ta = translate(a,&expand);
   if (expand || ORIWider(ta,ORIUnion(OR_2PI,ZERO))) 
      return createORI2(-1.0,1.0);
   ORInterval lta,uta;
   ORSinePhase p1 = sineLow(ORILow(ta),&lta);
   ORSinePhase p2 = sineUp(ORIUp(ta),&uta);
   if (p1 == p2 || p2 == p1 + 1) 
      return ORIUnion(lta,uta);
   assert(p2 > p1);
   switch(p1) {
      case OR_BEFPI2: {
         if (p2 == 2 || p2 == 3) 
            return ORIUnion(ORIUnion(lta,uta),createORI1(1.0));
         else return createORI2(-1.0,1.0);
      }break;
      case OR_BET3PI2_5PI2: {
         if (p2 == 6 || p2 == 7)
            return ORIUnion(ORIUnion(lta,uta),createORI1(1.0));
         else return createORI2(-1.0,1.0);
      }break;
      case OR_ATPI2: case OR_AT3PI2: case OR_AT5PI2: case OR_AT7PI2: {
         return createORI2(-1.0,1.0);
      }break;
      case OR_BETPI2_3PI2: {
         if (p2 == 4 || p2 == 5)
            return ORIUnion(createORI1(-1.0),ORIUnion(lta,uta));
         else return createORI2(-1.0,1.0);
      }break;
      case OR_BET5PI2_7PI2: {
         assert(p2 == 8 || p2 == 9);
         return ORIUnion(createORI1(-1.0),ORIUnion(lta,uta));
      }break;
      default: abort();
   }
}
ORInterval ORICosine(ORInterval a)
{
   ORIReady();
   if (ORIWider(a,ORIUnion(OR_2PI,ZERO))) 
      return createORI2(-1.0,1.0);    
   BOOL expand = FALSE;
   ORInterval ta = translate(a,&expand);
   if (expand || ORIWider(ta,ORIUnion(OR_2PI,ZERO))) 
      return createORI2(-1.0,1.0);
   a = ORIAdd(a,OR_PI2);
   ORInterval lta,uta;
   ORSinePhase p1 = sineLow(ORILow(ta),&lta);
   ORSinePhase p2 = sineUp(ORIUp(ta),&uta);
   if (p1 == p2 || p2 == p1 + 1) 
      return ORIUnion(lta,uta);
   assert(p2 > p1);
   switch(p1) {
      case OR_BEFPI2: {
         if (p2 == 2 || p2 == 3) 
            return ORIUnion(ORIUnion(lta,uta),createORI1(1.0));
         else return createORI2(-1.0,1.0);
      }break;
      case OR_BET3PI2_5PI2: {
         if (p2 == 6 || p2 == 7)
            return ORIUnion(ORIUnion(lta,uta),createORI1(1.0));
         else return createORI2(-1.0,1.0);
      }break;
      case OR_ATPI2: case OR_AT3PI2: case OR_AT5PI2: case OR_AT7PI2: {
         return createORI2(-1.0,1.0);
      }break;
      case OR_BETPI2_3PI2: {
         if (p2 == 4 || p2 == 5)
            return ORIUnion(createORI1(-1.0),ORIUnion(lta,uta));
         else return createORI2(-1.0,1.0);
      }break;
      case OR_BET5PI2_7PI2: {
         assert(p2 == 8 || p2 == 9);
         return ORIUnion(createORI1(-1.0),ORIUnion(lta,uta));
      }break;
      default: abort();
   }
}

// ===========================================================================================
// Transcendental Exponential
// ===========================================================================================

static inline double N_ExpApp(double x)
{
   //nearmode;
   // ldm. Unclear how critical the rounding to nearest is for the correction of the routine. 
   //_MM_SET_ROUNDING_MODE(_MM_ROUND_NEAREST);
   double xx = x*x;
   double px = x * ( EXP_p0 + xx * ( EXP_p1 + xx * EXP_p2));
   x  = px / ( (EXP_q0 + xx * (EXP_q1 + xx * ( EXP_q2 + xx * EXP_q3 ))) - px );
   x = fldexp(x,1);
   x = x + 1.0;
   //_MM_SET_ROUNDING_MODE(_MM_ROUND_DOWN);
   return x;
}

static inline double N_ExpF_Low(double x, double k)
{
   ORInterval p  = ORIMul(OR_EC1,createORI1(k));
   ORInterval s1 = ORISub(createORI1(x),p);
   ORInterval s2 = ORIMul(OR_EC2,createORI1(k));
   ORInterval f  = ORIAdd(s1,s2);
   return ORILow(f);
}

static inline double N_ExpF_Up(double x, double k)
{
   ORInterval p  = ORIMul(OR_EC1,createORI1(k));
   ORInterval s1 = ORISub(createORI1(x),p);
   ORInterval s2 = ORIMul(OR_EC2,createORI1(k));
   ORInterval f  = ORIAdd(s1,s2);
   return ORIUp(f);
}

static double N_ExpLow(double x)
{
   ORInterval xi = createORI1(x);
   ORInterval xp  = _mm_add_pd(_mm_mul_pd(xi,_mm_xor_pd(OR_LOGE,FLIP)),createORI1(0.5)); // remove sign bit on constant
   ORInterval k   = ORIFloor(_mm_xor_pd(xp,FLIP));  // flip sign bit on positive.
   ORInterval eps = createORI1(1e-16);
   while(ORIBoundsNEQ(k)) {
      ORInterval fxi = _mm_xor_pd(xi,FLIP);   // remove sign bit
      ORInterval sub = _mm_sub_pd(fxi,eps);   // substract 1e-16 
      xi             = _mm_xor_pd(sub,FLIP);  // set the sign bit back
      if (ORIUp(xi) < - N_MAXLOG)
         return 0.0;
      xp = _mm_add_pd(_mm_mul_pd(xi,OR_LOGE),createORI1(0.5)); // xp <- xi * (LOG(e)) + 0.5
      k  = ORIFloor(_mm_xor_pd(xp,FLIP));
   }
   double f0 = N_ExpF_Low(ORILow(xi),ORILow(k));
   ORInterval f1 = ORIInter(createORI1(f0),OR_ERANGE);
   double f2     = N_ExpApp(ORILow(f1));
   ORInterval f3 = _mm_set_sd(f2);
   ORInterval f4 = _mm_mul_sd(f3,_mm_set_sd(E_EPSL));
   double r;
   _mm_store_sd(&r,f4);
   double e = ORILow(k);
   if (-30 < e && e < 30)
      return fldexp(r,e);
   else 
      return ldexp(r,e);
}

static double N_ExpUp(double x)
{
   ORInterval xi = createORI1(x);
   ORInterval xp = _mm_add_pd(_mm_mul_pd(createORI1(x),_mm_xor_pd(OR_LOGE,FLIP)),createORI1(0.5)); // remove sign bit on constant
   ORInterval k  = ORIFloor(_mm_xor_pd(xp,FLIP));  // flip sign bit on positive.
   ORInterval eps = createORI1(1e-16);
   while(ORIBoundsNEQ(k)) {
      xi = _mm_xor_pd(_mm_add_pd(xi,eps),FLIP);                // add, then remove sign bit.
      xi = _mm_shuffle_pd(xi,xi,3);                            // copy value in both slots.
      xi = _mm_xor_pd(xi,FLIP);                                // set the sign bit again on up.
      if (ORILow(xi) > N_MAXLOG)
         return ORIUp(INF);
      xp = _mm_add_pd(_mm_mul_pd(xi,OR_LOGE),createORI1(0.5));
      k  = ORIFloor(_mm_xor_pd(xp,FLIP));      
   }
   double f0 = N_ExpF_Up(ORILow(xi),ORILow(k));
   ORInterval f1 = ORIInter(createORI1(f0),OR_ERANGE);
   double     f2 = N_ExpApp(ORILow(f1));
   ORInterval f3 = _mm_set_sd(f2);
   ORInterval f4 = _mm_mul_sd(f3,_mm_set_sd(- E_EPSU));  // flip sign bit to get correct rounding direction
   double r;
   _mm_store_sd(&r,f4);
   double e = ORILow(k);
   if (-30 < e && e < 30)
      return fldexp(- r,e);  // flip sign bit again.
   else 
      return ldexp(- r,e);

   return ldexp(- r,ORILow(k));  // flip sign bit again.
}

ORInterval ORIExp(ORInterval a)
{
   ORIReady();
   ORInterval cr1 = _mm_cmpge_pd(_mm_xor_pd(a,FLIP),_mm_set1_pd(N_MAXLOG));
   ORInterval cr2 = _mm_cmple_pd(_mm_xor_pd(a,FLIP),_mm_set1_pd(-N_MAXLOG));
   double s1[2],s2[2];
   _mm_storeu_pd(s1, cr1);
   _mm_storeu_pd(s2, cr2);
   double lb = s1[1] ? N_MAXEXP_V : (s2[1] ? 0.0 : N_ExpLow(ORILow(a)));      // x[1] --> Lower Bound
   double ub = s1[0] ? ORIUp(INF) : (s2[1] ? N_MINEXP_V : N_ExpUp(ORIUp(a))); // x[2] --> Upper Bound
   return createORI2(lb,ub);
}

// ===========================================================================================
// Transcendental Logarithm
// ===========================================================================================

#define LOG_P(x) ( ((((((LOG_p6*x+LOG_p5)*x+LOG_p4)*x+LOG_p3)*x+LOG_p2)*x+LOG_p1)*x+LOG_p0) )
#define LOG_Q(x) ( ((((((LOG_q6*x+LOG_q5)*x+LOG_q4)*x+LOG_q3)*x+LOG_q2)*x+LOG_q1)*x+LOG_q0) )
#define LOG_R(x) ( ((((  LOG_r2)*x+LOG_r1)*x)+LOG_r0) )
#define LOG_S(x) ( ((((x+LOG_s2)*x+LOG_s1)*x)+LOG_s0) )

// faster version of standard frexp (extract exponent and mantissa)
static inline double ffrexp(double value, int* exponent) 
{ 
    long& ivalue = (long&) value; 
    *exponent = (int) ((ivalue & 0x7FF0000000000000L)>> 52) - 1022; 
    ivalue &= 0x800FFFFFFFFFFFFFL; 
    ivalue |= 0x3FE0000000000000L; 
    return value; 
}

static double NlogApp(double x, int &e)
{
   double y, z;
   if ( (e>2) || (e<-2) ) {
      if ( x < SQRTH ) {
         e -= 1;
         z = x - 0.5;
         y = 0.5 * z + 0.5;
      } else {
         z = x - 0.5;
         z -= 0.5;
         y = 0.5 * x + 0.5;
      }
      x = z / y;
      z = x*x;
      z = x + x * (z * LOG_R(z)/LOG_S(z));
   } else {
      if ( x < SQRTH ) {
         e -= 1;
         x = fldexp(x,1) - 1.0;
      } else {
         x = x - 1.0;
      }
      z = x*x;
      y = x * ( z * LOG_P(x)/LOG_Q(x));
      y = y - fldexp(z,-1);
      z = x + y;
   }
   return z;
}

// [ldm] Oddly, the vector code below is not any faster. 
// static double NlogApp(double x, int &e)
// {
//    double y, z;
//    //_MM_SET_ROUNDING_MODE(_MM_ROUND_NEAREST);
//    if ( (e>2) || (e<-2) ) {
//       if ( x < SQRTH ) {
//          e -= 1;
//          z = x - 0.5;
//          y = 0.5 * z + 0.5;
//       } else {
//          z = x - 0.5;
//          z -= 0.5;
//          y = 0.5 * x + 0.5;
//       }
//       x = z / y;
//       z = x*x;
//       ORInterval zi = _mm_set1_pd(z);
//       ORInterval s0 = _mm_set_pd(0.0,z);
//       ORInterval s1 = _mm_add_pd(s0,_mm_set_pd(LOG_r2,LOG_s2));
//       ORInterval s2 = _mm_mul_pd(s1,zi);
//       ORInterval s3 = _mm_add_pd(s2,_mm_set_pd(LOG_r1,LOG_s1));
//       ORInterval s4 = _mm_mul_pd(s3,zi);
//       ORInterval s5 = _mm_add_pd(s4,_mm_set_pd(LOG_r0,LOG_s0));
//       double b[2];
//       _mm_store_pd(b,s5);
//       z = x + x * (z * b[1]/b[0]);
//    } else {
//       if ( x < SQRTH ) {
//          e -= 1;
//          x = fldexp(x,1) - 1.0;
//       } else {
//          x = x - 1.0;
//       }
//       z = x*x;
//       ORInterval xi = _mm_set1_pd(x);
//       ORInterval s0 = _mm_mul_pd(xi,_mm_set_pd(LOG_p6,LOG_q6));
//       ORInterval s1 = _mm_add_pd(s0,_mm_set_pd(LOG_p5,LOG_q5));
//       ORInterval s2 = _mm_mul_pd(s1,xi);
//       ORInterval s3 = _mm_add_pd(s2,_mm_set_pd(LOG_p4,LOG_q4));
//       ORInterval s4 = _mm_mul_pd(s3,xi);
//       ORInterval s5 = _mm_add_pd(s4,_mm_set_pd(LOG_p3,LOG_q3));
//       ORInterval s6 = _mm_mul_pd(s5,xi);
//       ORInterval s7 = _mm_add_pd(s6,_mm_set_pd(LOG_p2,LOG_q2));
//       ORInterval s8 = _mm_mul_pd(s7,xi);
//       ORInterval s9 = _mm_add_pd(s8,_mm_set_pd(LOG_p1,LOG_q1));
//       ORInterval s10= _mm_mul_pd(s9,xi);
//       ORInterval s11= _mm_add_pd(s10,_mm_set_pd(LOG_p0,LOG_q0));
//       double b[2];
//       _mm_store_pd(b,s11);
//       y = x * (z * b[1]/b[0]);
//       y = y - fldexp(z,-1);
//       z = x + y;
//    }
//    //_MM_SET_ROUNDING_MODE(_MM_ROUND_DOWN);
//    return z;
// }

ORInterval ORILogn(ORInterval a)
{
   ORIReady();
   if (ORINegative(a))
      return INF;
   else {
      double lm,rm;
      int le,re;
      lm = ffrexp(ORILow(a),&le);
      rm = ffrexp(ORIUp(a),&re);

      double la = NlogApp(lm,le);
      double ra = NlogApp(rm,re);

      ORInterval pl = _mm_mul_pd(createORI2(T_EPSL,T_EPSU),_mm_set1_pd(la));
      if (la < 0)
         pl = ORISwap(pl);
      else if (la==0)
         pl = createORI2(-1e-16,1e-16);

      ORInterval pr = _mm_mul_pd(createORI2(T_EPSL,T_EPSU),_mm_set1_pd(ra));
      if (ra < 0)
         pr = ORISwap(pr);
      else if (ra == 0)
         pr = createORI2(-1e-16,1e-16);
      ORInterval delta = _mm_shuffle_pd(pr,pl,_MM_SHUFFLE2(1,0));
      ORInterval low = pl,up = pr;
      if (le) {
         ORInterval se  = _mm_mul_pd(createORI1((double)le),_mm_set1_pd(2.121944400546905827679e-4));
         se = _mm_xor_pd(se,FLIP);                      // remove sign bit. 
         se = _mm_shuffle_pd(se,se,_MM_SHUFFLE2(0,1));  // swap up/low
         low = _mm_sub_pd(delta,se);         // low <- delta.low - se.up  (se.up now in se.low)
         ORInterval se2 = _mm_mul_pd(createORI1((double)le),_mm_set1_pd(0.693359375));
         low = _mm_add_pd(low,se2);
      }
      if (re) {
         ORInterval se  = _mm_mul_pd(createORI1((double)re),_mm_set1_pd(2.121944400546905827679e-4));
         up = ORISub(delta,se);
         ORInterval se2 = _mm_mul_pd(createORI1((double)le),_mm_set1_pd(0.693359375));
         up = _mm_add_pd(up,se2);         
      }
      ORInterval res = _mm_shuffle_pd(up,low,_MM_SHUFFLE2(1,0));
      return res;
   }
}

// ===========================================================================================

void ORIInit(void)
{
   double MZ   = 0;
#ifndef BYTE_ORDER
   sintx testInt = 0x12345678;
   char* ptestInt = (char*) &testInt;
   bigendian = ptestInt[0]==0x78 ? 0 : 1;
#else
#if BYTE_ORDER == BIG_ENDIAN
   bigendian = 1;
#else
   bigendian = 0;
#endif
#endif
   unsigned char *pinfPtr = (unsigned char*)&pinf;
   pinfPtr[bigendian ? 0 : 7] =  0x7f;
   pinfPtr[bigendian ? 1 : 6] =  0xf0;
   unsigned char *ninfPtr = (unsigned char*)&ninf;
   ninfPtr[bigendian ? 0 : 7] = 0xff;
   ninfPtr[bigendian ? 1 : 6] = 0xf0;
   unsigned char *mzPtr = (unsigned char*)&MZ;
   mzPtr[bigendian ? 0 : 7] = 0x80;
   mzPtr[bigendian ? 1 : 6] = 0x0;
   // These are the constants for trigonometric functions
   double N_PIL,N_PIU;
   double N_PI2L,N_PI2U;
   double N_PI4L,N_PI4U;
   PACKDBL(T_EPSL,0x3fef,0xffff,0xffff,0xfffe);
   PACKDBL(T_EPSU,0x3ff0,0x0000,0x0000,0x0001);
   PACKDBL(N_PIL,0x4009,0x21fb,0x5444,0x2d17);
   PACKDBL(N_PIU,0x4009,0x21fb,0x5444,0x2d19);
   PACKDBL(N_PI2L,0x3ff9,0x21fb,0x5444,0x2d17);
   PACKDBL(N_PI2U,0x3ff9,0x21fb,0x5444,0x2d19);
   PACKDBL(N_PI4L,0x3fe9,0x21fb,0x5444,0x2d17);
   PACKDBL(N_PI4U,0x3fe9,0x21fb,0x5444,0x2d19);
   PACKDBL(sc5,0x3de5,0xd8fd,0x1fd1,0x9ccd);
   PACKDBL(sc4,0xbe5a,0xe5e5,0xa929,0x1f5d);
   PACKDBL(sc3,0x3ec7,0x1de3,0x567d,0x48a1);
   PACKDBL(sc2,0xbf2a,0x01a0,0x19bf,0xdf03);
   PACKDBL(sc1,0x3f81,0x1111,0x1110,0xf7d0);
   PACKDBL(sc0,0xbfc5,0x5555,0x5555,0x5548);
   PACKDBL(cc6,0x3da8,0xff83,0x1ad7,0xc64c);
   PACKDBL(cc5,0xbe21,0xeea7,0xc1e5,0x1159);
   PACKDBL(cc4,0x3e92,0x7e4f,0x8e06,0xd9a0);
   PACKDBL(cc3,0xbefa,0x01a0,0x19dd,0xbcd9);
   PACKDBL(cc2,0x3f56,0xc16c,0x16c1,0x5d47);
   PACKDBL(cc1,0xbfa5,0x5555,0x5555,0x5551);
   PACKDBL(cc0,0x3fe0,0x0000,0x0000,0x0000);
   PACKDBL(P1,0x3fe9,0x21fb,0x4000,0x0000);
   PACKDBL(P2,0x3e64,0x442d,0x0000,0x0000);
   PACKDBL(P3,0x3ce8,0x4698,0x98cc,0x5170);

   PACKDBL(N_EL,0x4005,0xbf0a,0x8b14,0x5768);
   PACKDBL(N_EU,0x4005,0xbf0a,0x8b14,0x576a);
   PACKDBL(N_MAXNUM,0x7fef,0xffff,0xffff,0xffff);
   PACKDBL(N_MACHEP,0x3ca0,0x0000,0x0000,0x0000);
   PACKDBL(N_LN2L,0x3fe6,0x2e42,0xfefa,0x39ee);
   PACKDBL(N_LN2U,0x3fe6,0x2e42,0xfefa,0x39f0);
   PACKDBL(N_LN10L,0x4002,0x6bb1,0xbbb5,0x5515);
   PACKDBL(N_LN10U,0x4002,0x6bb1,0xbbb5,0x5517);

   PACKDBL(E_EPSL,0x3fef,0xffff,0xffff,0xfffe);
   PACKDBL(E_EPSU,0x3ff0,0x0000,0x0000,0x0001);
   PACKDBL(N_LOGEL,0x3ff7,0x1547,0x652b,0x82fd);
   PACKDBL(N_LOGEU,0x3ff7,0x1547,0x652b,0x82ff);
   PACKDBL(N_EC1L,0x3fe6,0x2fff,0xffff,0xffff);
   PACKDBL(N_EC1U,0x3fe6,0x3000,0x0000,0x0001);
   PACKDBL(N_EC2L,0x3f2b,0xd010,0x5c60,0xfe3e);
   PACKDBL(N_EC2U,0x3f2b,0xd010,0x5c61,0x1b12);
   PACKDBL(N_MAXLOG,0x4086,0x2e42,0xfefa,0x39ee);
   PACKDBL(ErangeUp,0x3fd6,0x2e42,0xfefa,0x39f0);

   PACKDBL(LOG_p6,0x3f08,0x09a7,0x6a5f,0x974f);
   PACKDBL(LOG_p5,0x3fdf,0xe7ee,0xd979,0x5a1a);
   PACKDBL(LOG_p4,0x401a,0x40a2,0xc66c,0x74c9);
   PACKDBL(LOG_p3,0x403d,0xc9a9,0x7e3d,0x411d);
   PACKDBL(LOG_p2,0x404e,0x4e6d,0x64eb,0xdcdc);
   PACKDBL(LOG_p1,0x404c,0x5e12,0x2519,0xd312);
   PACKDBL(LOG_p0,0x4033,0xe3a5,0x89b1,0x3130);
   PACKDBL(LOG_q5,0x402e,0x1016,0x0dfb,0xd0a2);
   PACKDBL(LOG_q4,0x4054,0xaf6d,0x47ae,0x79c7);
   PACKDBL(LOG_q3,0x406b,0x9542,0xa44b,0x455a);
   PACKDBL(LOG_q2,0x4073,0x3411,0x2983,0x10d7);
   PACKDBL(LOG_q1,0x406a,0xde94,0x2a8d,0x3423);
   PACKDBL(LOG_q0,0x404d,0xd578,0x4e89,0xc9c8);
   LOG_q6 = 1.0;
   PACKDBL(LOG_r2,0xbfe9,0x443d,0xdc6c,0x0e84);
   PACKDBL(LOG_r1,0x4030,0x62fc,0x7302,0x7b6b);
   PACKDBL(LOG_r0,0xc050,0x0906,0x1122,0x2a20);
   PACKDBL(LOG_s2,0xc041,0xd60d,0x43ec,0x6d0a);
   PACKDBL(LOG_s1,0x4073,0x8180,0x112a,0xe40e);
   PACKDBL(LOG_s0,0xc088,0x0d89,0x19b3,0x3f3b);

   ErangeLow = - ErangeUp;

   // NOW DEFINE THE STATIC INTERVALS.
   _MM_SET_ROUNDING_MODE(_MM_ROUND_DOWN);
   FLIP = _mm_set_pd(0.0, MZ);
   EPSILON = _mm_set1_pd(-DBL_MIN);
   ZERO    = _mm_set_pd(0.0,MZ);
   INF     = _mm_set_pd(ninf,ninf);
   OR_PI   = createORI2(N_PIL,N_PIU);
   OR_PI2  = createORI2(N_PI2L,N_PI2U);
   OR_PI4  = createORI2(N_PI4L,N_PI4U);
   OR_3PI2 = ORIAdd(OR_PI,OR_PI2);
   OR_2PI  = ORIAdd(OR_PI,OR_PI);
   OR_5PI2 = ORIAdd(OR_2PI,OR_PI2);
   OR_7PI2 = ORIAdd(OR_2PI,OR_3PI2);
   OR_9PI2 = ORIAdd(OR_2PI,OR_5PI2);
   // Exponential intervals
   OR_PEXP  = createORI2(N_EL,N_EU);
   OR_PLN2  = createORI2(N_LN2L,N_LN2U);
   OR_PLN2i = ORInverse(OR_PLN2);
   OR_PLN10 = createORI2(N_LN10L,N_LN10U);
   OR_PLN10i= ORInverse(OR_PLN10);
   OR_EC1   = createORI2(N_EC1L,N_EC1U);
   OR_EC2   = createORI2(N_EC2L,N_EC2U);
   OR_ERANGE = createORI2(ErangeLow,ErangeUp);
   OR_EXPRANGE = createORI2(N_ExpLow(N_MAXLOG),N_ExpUp(-N_MAXLOG));
   OR_LOGE  = createORI2(N_LOGEL,N_LOGEU);
}

// ===========================================================================================
// Printing ORIntervals faithfully.
// ===========================================================================================

static void printLow(double v,char* buf,int ndigs);
static void printUp(double v,char* buf,int ndigs);
static void sprint(double v,char* buf,int ndigs);

extern "C" NSString* ORIFormat(ORInterval a)
{
   double low,up;
   ORIBounds(a, &low, &up);
   NSMutableString* str = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   if (low == ninf)
      [str appendString:@"[-inf.."];
   else {
      char buf[512];
      *buf = 0;
      printLow(low,buf,14);
      [str appendFormat:@"[%s .. ",buf];
   }
   if (up == pinf)
      [str appendFormat:@"+inf]"];
   else {
      char buf[512];
      *buf = 0;
      printUp(up, buf, 14);
      [str appendFormat:@"%s]",buf];
   }
   return str;
}

static void printLow(double v,char* buf,int ndigs)
{
   int mode = _MM_GET_ROUNDING_MODE();
   _MM_SET_ROUNDING_MODE(_MM_ROUND_DOWN);
   sprint(v,buf,ndigs);
   _MM_SET_ROUNDING_MODE(mode);
}
static void printUp(double v,char* buf,int ndigs)
{
   int mode = _MM_GET_ROUNDING_MODE();
   _MM_SET_ROUNDING_MODE(_MM_ROUND_UP);
   sprint(v,buf,ndigs);
   _MM_SET_ROUNDING_MODE(mode);
}

struct SECalias {
   unsigned short sign;
   unsigned short exponent;
   unsigned short m[6];
};

struct USRalias {
   unsigned short m[4];
   unsigned short expSign;
};

class SECDouble;

class USRDouble {
   union {
      unsigned short w[5];
      USRalias al;
   };
   friend class SECDouble;
public:
   USRDouble(void);
   USRDouble(const SECDouble& f);
   USRDouble(const USRDouble& f);
   USRDouble(double d);
   USRDouble(unsigned short* ptr);
   USRDouble& operator=(const USRDouble& f);
   USRDouble& operator=(const SECDouble& f);
   USRDouble& operator=(unsigned short* f);
   int positive() { return (al.expSign & 0x8000) == 0;}
   int negative() { return (al.expSign & 0x8000) == 0x8000;}
   void setPositive() { al.expSign &= 0x7fff;}
   void setNegative() { al.expSign |= 0x8000;}
   unsigned short exponent() { return al.expSign;}
   void setExponent(unsigned short e) { al.expSign = e;}
   unsigned short& operator[](int i) { return w[i];}
   double getDouble();
   operator double() { return getDouble();}
   USRDouble operator+(const USRDouble& op2);
   USRDouble operator-(const USRDouble& op2);
   USRDouble operator*(const USRDouble& op2);
   USRDouble operator/(const USRDouble& op2);
   int operator==(const USRDouble& op2);
   int operator!=(const USRDouble& op2);
   int operator<=(const USRDouble& op2);
   int operator>=(const USRDouble& op2);
   int operator<(const USRDouble& op2);
   int operator>(const USRDouble& op2);
   int cmp(const USRDouble& op2);
   USRDouble floor();
   void clear();
};

class SECDouble {
   union {
      unsigned short w[8];
      SECalias al;
   };
   friend class USRDouble;
public:
   SECDouble(void);
   SECDouble(double d);
   SECDouble(const SECDouble& sf);
   SECDouble(const USRDouble& uf);
   SECDouble& operator=(const SECDouble& sf);
   SECDouble& operator=(const USRDouble& sf);
   unsigned short& operator[](int i) { return w[i];}
   double getDouble();
   operator double() { return getDouble();}
   int positive() { return al.sign == 0x0000;}
   int negative() { return al.sign == 0xffff;}
   void setPositive() { al.sign = 0x0000;}
   void setNegative() { al.sign = 0xffff;}
   int  isZero();
   int  isOne();
   int sign()     { return al.sign;}
   int exponent() { return al.exponent;}
   void exponent(unsigned short e) { al.exponent = e;}
   void negate()  { al.sign = ~al.sign;}
   void makeInf();
   SECDouble add(SECDouble op2,int subflg=0);
   int      cmp(SECDouble op2);
   SECDouble mul(SECDouble op2);
   SECDouble div(SECDouble op2);
   SECDouble rem(SECDouble op2,SECDouble& equot);
   void clear();
   int shift(int sc);
   int normlz();
   void addm(SECDouble& s);
   void subm(SECDouble& s);
   int  cmpm(SECDouble& s);
   int  mulm(SECDouble& s,SECDouble& equot);
   int  divm(SECDouble& s,SECDouble& equot);
   void eshdn1();
   void eshdn8();
   void eshdn16();
   void eshup1();
   void eshup8();
   void eshup16();
   void rnorm(int lost,int subflg,int exp,int rcntrl);
};


#define SFS  8
#define SFMS 6

#define NE 5
#define NI (NE+3)
#define E 1
#define M 2
#define NBITS ((NI-4)*16)
#define NDEC  (NBITS*8/27)

#define SEC_UNDERFLOW 0
#define SEC_OVERFLOW  1
#define SEC_SING      2

#define NTEN 12
#define MAXP 4096

const unsigned short IEEEBIAS = 0x3fff;

static unsigned short etens[NTEN+1][NE] = {
   {0x979b,0x8a20,0x5202,0xc460,0x7525},
   {0x5de5,0xc53d,0x3b5d,0x9e8b,0x5a92},
   {0x0c17,0x8175,0x7586,0xc976,0x4d48},
   {0x91c7,0xa60e,0xa0ae,0xe319,0x46a3},
   {0xde8e,0x9df9,0xebfb,0xaa7e,0x4351},
   {0x8ce0,0x80e9,0x47c9,0x93ba,0x41a8},
   {0xa6d5,0xffcf,0x1f49,0xc278,0x40d3},
   {0xb59e,0x2b70,0xada8,0x9dc5,0x4069},
   {0x0000,0x0400,0xc9bf,0x8e1b,0x4034},
   {0x0000,0x0000,0x2000,0xbebc,0x4019},
   {0x0000,0x0000,0x0000,0x9c40,0x400c},
   {0x0000,0x0000,0x0000,0xc800,0x4005},
   {0x0000,0x0000,0x0000,0xa000,0x4002}
};

static unsigned short emtens[NTEN+1][NE] = {
   {0x9fde,0xd2ce,0x04c8,0xa6dd,0x0ad8},
   {0x2de4,0x3436,0x534f,0xceae,0x256b},
   {0xc0be,0xda57,0x82a5,0xa2a6,0x32b5},
   {0xd21c,0xdb23,0xee32,0x9049,0x395a},
   {0x193a,0x637a,0x4325,0xc031,0x3cac},
   {0xe4a1,0x64bc,0x467c,0xddd0,0x3e55},
   {0xe9a5,0xa539,0xea27,0xa87f,0x3f2a},
   {0x94ba,0x4539,0x1ead,0xcfb1,0x3f94},
   {0xe15b,0xc44d,0x94be,0xe695,0x3fc9},
   {0xcefd,0x8461,0x7711,0xabcc,0x3fe4},
   {0x652c,0xe219,0x1758,0xd1b7,0x3ff1},
   {0xd70a,0x70a3,0x0a3d,0xa3d7,0x3ff8},
   {0xcccd,0xcccc,0xcccc,0xcccc,0x3ffb}
};


static void sprint(double v,char* string,int ndigs)
{
   USRDouble y(v);
   USRDouble t(1);
   USRDouble ezero(0.0);
   USRDouble u;
   USRDouble r;
   USRDouble one(1);
   USRDouble ten = etens[NTEN];
   USRDouble p;
   USRDouble x;
   SECDouble ww;
   SECDouble z;
   int pos;
   int digit;
   unsigned short sign;
   int i,j,k,expon;
   char *s,*ss;
   
   char buf[1024];
   
   if (y.negative()) {
      sign = 0xffff;
      y.setPositive();
   } else sign = 0;
   
   expon = 0;
   
   if (y.exponent() == 0) {
      for(k=0;k<NE-1;k++) {
         if (y[k] != 0)
            goto tnzro;
      }
      goto isone;
   }
tnzro:
   if ((y.exponent() != 0) && ((y[NE-2] & 0x8000) == 0)) {
      strcpy(string,"NaN ");
      return ;
   }
   i = one.cmp(y);
   if (i==0)
      goto isone;
   if (i<0) {
      u = y;
      u.setExponent(IEEEBIAS + NBITS - 1);
      pos = NTEN-4;
      p = etens[pos];
      k = 16;
      do {
         t = u / p;
         ww = t.floor();
         for(j=0;j<NE-1;j++) {
            if (t[j] != ww[j])
               goto noint;
         }
         u = t;
         expon += k;
      noint:
         pos++;
         p = etens[pos];
         k >>=1;
      } while (k > 0);
      k = (IEEEBIAS + NBITS -1) - u.exponent();
      k = y.exponent() - k;
      u.setExponent(k);
      y = u;
      pos = 0;
      t   = one;
      k   = MAXP;
      p   = etens[pos];
      while (ten <= u) {
         if (p <= u) {
            u = u / p;
            t = t * p;
            expon += k;
         }
         k >>= 1;
         if (k==0) break;
         p = etens[++pos];
      }
   } else {
      if (y.exponent() == 0) {
         while ((y[NE-2] & 0x8000)==0) {
            y = y * ten;
            expon -= 1;
         }
      } else {
         ww = y;
         for(i=0;i<NDEC+1;i++) {
            if ((ww[NI-1] & 0x7) != 0)
               break;
            z = ww;
            z.eshdn1();
            z.eshdn1();
            z.addm(ww);
            z[1] += 3;
            while (z[2] != 0) {
               z.eshdn1();
               z[1] += 1;
            }
            if (z[NI-1] != 0)
               break;
            if (one.exponent() <= z.exponent())
               break;
            ww = z;
            expon -= 1;
         }
         y = ww;
      }
      
      k   = -MAXP;
      pos = 0;
      p   = emtens[pos];
      r   = etens[pos];
      x   = y;
      t   = one;
      while (one > x) {
         if (p >= x) {
            x = x * r;
            t = t * r;
            expon += k;
         }
         k /= 2;
         if (k==0) break;
         pos++;
         p = emtens[pos];
         r = etens[pos];
      }
      t = one / t;
   }
isone:
   SECDouble a(t);
   SECDouble b(y);
   SECDouble equot;
   b = b.rem(a,equot);
   digit = equot[NI-1];
   while (digit==0 && b.cmp(0) != 0) {
      b.eshup1();
      SECDouble c(b);
      c.eshup1();
      c.eshup1();
      b.addm(c);
      b = b.rem(t,equot);
      digit = equot[NI-1];
      expon -= 1;
   }
   s = buf;
   *s++ = (char)digit + '0';
   if (ndigs < 0)    ndigs = 0;
   if (ndigs > NDEC) ndigs = NDEC;
   
   for(k=0;k<=ndigs;k++) {
      b.eshup1();
      SECDouble a(b);
      a.eshup1();
      a.eshup1();
      b.addm(a);
      b = b.rem(t,equot);
      *s++ = (char) equot[NI-1] + '0';
   }
   digit = equot[NI-1];
   --s;
   ss = s;
   if (!b.isZero()) {
      
      if (_MM_GET_ROUNDING_MODE() == _MM_ROUND_NEAREST) {
         if (digit > 4) {
            if (digit == 5) {
               t = b;
               if (!(t == ezero))
                  goto roun;
               if ((*(s-1) & 1) == 0)
                  goto doexp;
            }
         }
      } else if (sign) {
         if (_MM_GET_ROUNDING_MODE() == _MM_ROUND_UP) {
            goto doexp;
         } else {
            goto roun;
         }
      } else {
         if (_MM_GET_ROUNDING_MODE() == _MM_ROUND_DOWN) {
            goto doexp;
         } else {
            goto roun;
         }
      }
   roun:
      --s;
      k = *s & 0x7f;
      if (s== buf) {
         k += 1;
         *s =(char)k;
         if (k > '9') {
            expon += 1;
            *s = '1';
         }
         goto doexp;
      }
      if (k== '.') {
         --s;
         k = *s;
         k += 1;
         *s = (char)k;
         if (k > '9') {
            expon += 1;
            *s = '1';
         }
         goto doexp;
      }
      k += 1;
      *s = (char)k;
      if (k > '9') {
         *s = '0';
         goto roun;
      }
   }
doexp:
   expon += 1;
   *ss = 0;
   if (sign) *string++ = '-';
   if (expon > 0) {
      char* ptr = buf;
      int i;
      for(i=0;i<expon && ptr < ss;i++,ptr++)
         *string++ = *ptr;
      if (i == expon) {
         *string++ = '.';
         for(char* ptr =buf+i;ptr < ss;ptr++)
            *string++ = *ptr;
         *string = 0;
      } else {
         for(;i<expon;i++)
            *string++ = '0';
         *string = 0;
      }
   } else {
      *string++ = '0';
      *string++ = '.';
      int i;
      char* ptr;
      for(i =expon;i<0;i++)
         *string++ = '0';
      for(ptr=buf;ptr < ss;ptr++)
         *string++ = *ptr;
      *string++ = 0;
   }
   
}

// ------------


static void reorder(unsigned short* p)
{
   unsigned short x;
   x = p[0];
   p[0] = p[3];
   p[3] = x;
   x = p[1];
   p[1] = p[2];
   p[2] = x;
}

static void mtherr(const char* name,int t)
{
   NSLog(@"Function: [%s] reported error: %d",name,t);
   exit(t);
}

SECDouble::SECDouble(void)
{
   clear();
}

SECDouble::SECDouble(double d)

{
   unsigned short* e = (unsigned short*)&d;
   
    unsigned short r;
    unsigned short *p;
   int denorm,k;
   
   if (bigendian)
      reorder(e);
   denorm=0;
   clear();
   e += 3;
   r = *e;
   w[0] = 0;
   if (r & 0x8000)
      al.sign = 0xffff;
   w[M] = ( r & 0xf ) | 0x10;
   
   r &= ~0x800f;
   r >>= 4;
   if (r==0) {
      denorm = 1;
      w[M] &= ~0x10;
   }
   r += IEEEBIAS - 01777;
   al.exponent = r;
   p = &w[M+1];
   *p++ = *(--e);
   *p++ = *(--e);
   *p++ = *(--e);
   shift(-5);
   if (denorm) {
      if ((k = normlz()) > NBITS)
         clear();
      else al.exponent -= k - 1;
   }
}

SECDouble::SECDouble(const SECDouble& sf)

{
   for(int i=0;i<NI;i++)
      w[i] = sf.w[i];
}

SECDouble& SECDouble::operator=(const SECDouble& sf)

{
   for(int i=0;i<NI;i++)
      w[i] = sf.w[i];
   return *this;
}

SECDouble& SECDouble::operator=(const USRDouble& sf)

{
    unsigned short *q;
    unsigned short k;
   k = NE-1;
   q = w;
   if (sf.w[k] & 0x8000)
      *q++ = 0xffff;
   else *q++ = 0;
   *q = sf.w[k--];
   *q++ &= 0x7fff;
   *q++ = 0;
   *q++ = sf.w[k--];
   *q++ = sf.w[k--];
   *q++ = sf.w[k--];
   *q++ = sf.w[k--];
   *q = 0;
   return *this;
}

SECDouble::SECDouble(const USRDouble& uf)

{
    unsigned short *p,*q;
   q = w;
   p = (unsigned short*) (uf.w +(NE-1));
   if (*p & 0x8000)
      *q++ = 0xffff;
   else *q++ = 0;
   *q = *p--;
   *q++ &= 0x7fff;
   *q++ = 0;
   *q++ = *p--;
   *q++ = *p--;
   *q++ = *p--;
   *q++ = *p--;
   *q = 0;
}

double SECDouble::getDouble()

{
   double res;
   unsigned short *e = (unsigned short*)&res;
   SECDouble xi(*this);
   int i,k;
    unsigned short *p;
   e += 3;
   *e = 0;
   p = &xi[0] + 1;
   
   if (xi.negative())
      *e = 0x8000;
   
   i = xi[M+4];
   if ((i & 0x400) != 0) {
      if ((i & 0x07ff) == 0x400) {
         if ((i & 0x800) == 0)
            goto nornd;
      }
      SECDouble ri;
      ri[2+4] = 0x400;
      xi.addm(ri);
      k = xi.normlz();
      *p -= k;
   }
nornd:
   if (*p < (IEEEBIAS - 1081))
      goto ozero;
   if (*p > (IEEEBIAS + 1023)) {
      *e |= 0x7fef;
      *(--e) = 0xffff;
      *(--e) = 0xffff;
      *(--e) = 0xffff;
      if (bigendian) reorder(e);
      return res;
   }
   i = (int)*p++ - (IEEEBIAS - 01777);
   if (i <= 0) {
      if (i > -53) {
         xi.shift(i-1);
         i = 0;
      } else {
      ozero:
         *(--e) = 0;
         *(--e) = 0;
         *(--e) = 0;
         if (bigendian) reorder(e);
         return res;
      }
   }
   i <<= 4;
   xi.shift(5);
   i  |= *p++ & 0x0f;
   *e |= (unsigned short)i;
   *(--e) = *p++;
   *(--e) = *p++;
   *(--e) = *p;
   if (bigendian) reorder(e);
   return res;
}


void SECDouble::clear()

{
    unsigned short *xi = w;
    int i;
   for(i=0;i<NI;i++)
      *xi++ = 0x0000;
}

int SECDouble::isZero()

{
   for(int i=0;i<NI;i++)
      if (w[i]) return 0;
   return 1;
}

int SECDouble::isOne()

{
   SECDouble onef(1);
   return cmp(onef);
}

int SECDouble::shift(int sc)

{
   unsigned short *x = w;
   int lost;
   unsigned short *p;
   if (sc==0)
      return 0;
   lost = 0;
   p = x + NI - 1;
   if (sc <0) {
      sc = -sc;
      while(sc>=16) {
         lost |= *p;
         eshdn16();
         sc -= 16;
      }
      while(sc>=8) {
         lost |= *p & 0xff;
         eshdn8();
         sc -= 8;
      }
      while(sc>0) {
         lost |= *p & 1;
         eshdn1();
         sc -= 1;
      }
   } else {
      while(sc>=16) {
         eshup16();
         sc -= 16;
      }
      while(sc>=8) {
         eshup8();
         sc -= 8;
      }
      while(sc>0) {
         eshup1();
         sc -= 1;
      }
   }
   if (lost)
      lost = 1;
   return lost;
}

int SECDouble::normlz()

{
   unsigned short *x = w;
    unsigned short *p;
   int sc;
   sc  = 0;
   p = &x[M];
   if (*p != 0)
      goto normdn;
   ++p;
   if (*p & 0x8000)
      return 0;
   while(*p==0) {
      eshup16();
      sc += 16;
      if (sc > NBITS)
         return sc;
   }
   while ((*p & 0xff00) == 0) {
      eshup8();
      sc += 8;
   }
   while ((*p & 0x8000) == 0) {
      eshup1();
      sc += 1;
      if (sc > NBITS) {
         mtherr("enormlz",SEC_UNDERFLOW);
         return sc;
      }
   }
   return sc;
normdn:
   if (*p & 0xff00) {
      eshdn8();
      sc -= 8;
   }
   while (*p != 0) {
      eshdn1();
      sc -= 1;
      if (sc < -NBITS) {
         mtherr("enormlz",SEC_OVERFLOW);
         return sc;
      }
   }
   return sc;
}

void SECDouble::addm(SECDouble& s)

{
   unsigned short* x = &s[0];
   unsigned short* y = w;
    unsigned int a;
   int i;
   unsigned int carry;
   x += NI-1;
   y += NI-1;
   carry = 0;
   for(i=M;i<NI;i++) {
      a = (unsigned int)(*x) + (unsigned int)(*y) + carry;
      if (a & 0x10000)
         carry = 1;
      else carry = 0;
      *y = (unsigned short)a;
      --x;
      --y;
   }
}

void SECDouble::subm(SECDouble& s)

{
   unsigned short* x = &s[0];
   unsigned short* y = w;
   unsigned int a;
   int i;
   unsigned int carry;
   x += NI-1;
   y += NI-1;
   carry = 0;
   for(i=M;i<NI;i++) {
      a = (unsigned int)(*y) - (unsigned int)(*x) - carry;
      if (a & 0x10000)
         carry = 1;
      else carry = 0;
      *y = (unsigned short)a;
      --x;
      --y;
   }
}

int  SECDouble::cmpm(SECDouble& s)

{
    unsigned short *a = w;
    unsigned short *b = &s[0];
   int i;
   a += M;
   b += M;
   for(i=M;i<NI;i++) {
      if (*a++ != *b++) {
         if (*--a > *--b)
            return 1;
         else return -1;
      }
   }
   return 0;
}

int  SECDouble::mulm(SECDouble& s,SECDouble& equot)

{
   unsigned short *p,*q;
   int i,j,k;
   equot[0] = s[0];
   equot[1] = s[1];
   for(i=M;i<NI;i++)
      equot[i] = 0;
   p = &w[NI-2];
   k = NBITS;
   while (*p == 0) {
      eshdn16();
      k -= 16;
   }
   if (( *p & 0xff) == 0) {
      eshdn8();
      k -= 8;
   }
   q = &equot[NI-1];
   j = 0;
   for(i=0;i<k;i++) {
      if (*p & 1)
         equot.addm(s);
      if (*q & 1)
         j |= 1;
      eshdn1();
      equot.eshdn1();
   }
   for(i=0;i<NI;i++)
      w[i] = equot[i];
   return j;
   
}

int  SECDouble::divm(SECDouble& s,SECDouble& equot)

{
   unsigned short *den = &s[0];
   unsigned short *num = w;
   int i,j;
    unsigned short *p,*q;
   p = &equot[0];
   *p++ = num[0];
   *p++ = num[1];
   for(i=M;i<NI;i++)
      *p++ = 0;
   p = &den[M+2];
   if (*p++ == 0) {
      for(i=M+3;i<NI;i++) {
         if (*p++ != 0)
            goto fulldiv;
      }
      if ((den[M+1] & 1) != 0)
         goto fulldiv;
      eshdn1();
      s.eshdn1();
      p = &den[M+1];
      q = &num[M+1];
      for(i=0;i<NBITS+2;i++) {
         if (*p <= *q) {
            *q -= *p;
            j = 1;
         } else j = 0;
         equot.eshup1();
         equot[NI-2] |= j;
         eshup1();
      }
      goto divdon;
   }
fulldiv:
   p = &equot[NI-2];
   for(i=0;i<NBITS+2;i++) {
      if (s.cmpm(*this) <= 0) {
         subm(s);
         j = 1;
      } else j = 0;
      equot.eshup1();
      *p |= j;
      eshup1();
   }
divdon:
   equot.eshdn1();
   equot.eshdn1();
   p = &w[M];
   j = 0;
   for(i=M;i<NI;i++)
      j |= *p++;
   if (j)
      j = 1;
   for(i=0;i<NI;i++)
      w[i] = equot[i];
   return j;
}

void SECDouble::eshdn1()

{
    unsigned short *x = w;
    unsigned short bits;
   int i;
   x += M;
   bits = 0;
   for(i=M;i<NI;i++) {
      if (*x & 1)
         bits |= 1;
      *x >>= 1;
      if (bits & 2)
         *x |= 0x8000;
      bits <<= 1;
      ++x;
   }
}

void SECDouble::eshup1()

{
    unsigned short *x = w;
    unsigned short bits;
   int i;
   x += NI-1;
   bits = 0;
   for(i=M;i<NI;i++) {
      if (*x & 0x8000)
         bits |= 1;
      *x <<= 1;
      if (bits & 2)
         *x |= 1;
      bits <<= 1;
      --x;
   }
}

void SECDouble::eshdn8()

{
    unsigned short *x = w;
    unsigned short newbyt,oldbyt;
   int i;
   x += M;
   oldbyt = 0;
   for(i=M;i<NI;i++) {
      newbyt = *x << 8;
      *x >>= 8;
      *x |= oldbyt;
      oldbyt = newbyt;
      ++x;
   }
}

void SECDouble::eshup8()

{
   int i;
    unsigned short *x = w;
    unsigned short newbyt,oldbyt;
   x += NI - 1;
   oldbyt = 0;
   for(i=M;i<NI;i++) {
      newbyt = *x >> 8;
      *x <<= 8;
      *x |= oldbyt;
      oldbyt = newbyt;
      --x;
   }
}

void SECDouble::eshup16()

{
   int i;
    unsigned short *x = w;
    unsigned short *p;
   p = x + M;
   x += M + 1;
   for(i=M;i<NI-1;i++)
      *p++ = *x++;
   *p = 0;
}

void SECDouble::eshdn16()

{
   int i;
    unsigned short *x = w;
    unsigned short *p;
   x += NI-1;
   p = x + 1;
   for(i=M;i<NI-1;i++)
      *--p = *--x;
   *--p = 0;
}

void SECDouble::makeInf()

{
    unsigned short *x = w;
    int i;
   for(i=0;i<NE-1;i++)
      *x++ = 0xffff;
   *x |= 0x7fff;
}

SECDouble SECDouble::add(SECDouble op2,int subflg)

{
   if (subflg) negate();
   int k,lost,i;
   int lta = exponent();
   int ltb = op2.exponent();
   int lt  = lta - ltb;
   if (lt > 0) {
      SECDouble tmp = *this;
      *this = op2;
      op2 = tmp;
      ltb = op2.exponent();
      lt = -lt;
   }
   lost = 0;
   if (lt != 0) {
      if (lt < (int)(-NBITS-1))
         goto done;
      k = lt;
      lost = shift(k);
   } else {
      i = cmpm(op2);
      if (i==0) {
         if (sign() != op2.sign()) {
            SECDouble tmp;
            return   tmp;
         }
         if ((op2.exponent() ==0) && (op2[3] & 0x8000) == 0) {
            op2.eshup1();
            goto done;
         }
         for(int j=1;j<NI-1;j++) {
            if (op2[j] != 0) {
               ltb += 1;
               if (ltb > 32767) {
                  SECDouble res;
                  res.makeInf();
                  return res;
               }
               break;
            }
         }
         op2.exponent((unsigned short)ltb);
         goto done;
      }
      if (i>0) {
         SECDouble tmp = *this;
         *this = op2;
         op2 = tmp;
      }
   }
   if (sign() == op2.sign()) {
      op2.addm(*this);
      subflg = 0;
   } else {
      op2.subm(*this);
      subflg = 1;
   }
   op2.rnorm(lost,subflg,ltb,64);
done:
   return op2;
}

int SECDouble::cmp(SECDouble op2)

{
    unsigned short *p,*q;
    int i;
   int msign;
   p = w;
   q = &op2[0];
   if (sign() != op2.sign()) {
      for(i=1;i<NI-1;i++) {
         if (w[i] != 0) {
            if (positive())
               return 1;
            else return -1;
         }
         if (op2[i] != 0) {
            if (positive())
               return 1;
            else return -1;
         }
      }
      return 0;
   }
   if (positive())
      msign = 1;
   else msign = -1;
   i = NI-1;
   do {
      if (*p++ != *q++)
         goto diff;
   } while (--i > 0);
   return 0;
diff:
   if (*--p > *--q)
      return msign;
   else return -msign;
}

SECDouble SECDouble::mul(SECDouble op2)

{
   SECDouble res,equot;
   int i,j;
   int lt,lta,ltb;
   lta = exponent();
   ltb = op2.exponent();
   if (exponent() == 0) {
      for(i=1;i<NI-1;i++) {
         if (w[i] != 0) {
            lta -= normlz();
            goto mnzer1;
         }
      }
      return res;
   }
mnzer1:
   if (op2.exponent() == 0) {
      for(i=1;i<NI-1;i++) {
         if (op2[i] != 0) {
            ltb -= op2.normlz();
            goto mnzer2;
         }
      }
      return res;
   }
mnzer2:
   res = *this;
   j = res.mulm(op2,equot);
   lt = lta + ltb - (IEEEBIAS-1);
   res.rnorm(j,0,lt,64);
   if (sign() == op2.sign())
      res.setPositive();
   else res.setNegative();
   return res;
}

SECDouble SECDouble::div(SECDouble op2)

{
   SECDouble res,equot;
   int i;
   int lt,lta,ltb;
   lta = exponent();
   ltb = op2.exponent();
   if (exponent() == 0) {
      for(i=1;i<NI-1;i++) {
         if (w[i] != 0) {
            lta -= normlz();
            goto dnzro1;
         }
      }
      return res;
   }
dnzro1:
   if (op2.exponent() == 0) {
      for(i=1;i<NI-1;i++) {
         if (op2[i] != 0) {
            ltb -= op2.normlz();
            goto dnzro2;
         }
      }
      res.makeInf();
      mtherr("edir",SEC_SING);
      return res;
   }
dnzro2:
   res = *this;
   i = res.divm(op2,equot);
   lt = lta - ltb + IEEEBIAS;
   res.rnorm(i,0,lt,64);
   if (sign() == op2.sign())
      res.setPositive();
   else res.setNegative();
   return res;
}

SECDouble SECDouble::rem(SECDouble op2,SECDouble& equot)

{
   SECDouble res;
   equot.clear();
   if (isZero()) {
      return res;
   }
   int ld,ln;
   int j;
   ld = op2.exponent();
   ld -= op2.normlz();
   ln = exponent();
   ln -= normlz();
   res = *this;
   while (ln >= ld) {
      if (op2.cmpm(res) <= 0) {
         res.subm(op2);
         j = 1;
      } else j = 0;
      equot.eshup1();
      equot[NI-1] |= j;
      res.eshup1();
      ln -= 1;
   }
   res.rnorm(0,0,ln,0);
   if (sign() == op2.sign())
      res.setPositive();
   else res.setNegative();
   return res;
}

void SECDouble::rnorm(int lost,int subflg,int exp,int rcntrl)

{
   SECDouble rbit;
   unsigned short* s = w;
   int i,j;
   j = normlz();
   if (j > NBITS) {
      clear();
      return ;
   }
   exp -= j;
   if (exp > 32767L)
      goto overf;
   if (exp < 0L) {
      if (exp > (int) (-NBITS-1)) {
         j = (int) exp;
         i = shift(j);
         if (i)
            lost = 1;
      } else {
         clear();
         return ;
      }
   }
   if (((s[NI-1] & 0x8000) != 0) && (rcntrl != 0)) {
      if (s[NI-1] == 0x8000) {
         if (lost == 0) {
            if ((s[NI-2] & 1) == 0)
               goto mddone;
         } else {
            if (subflg != 0)
               goto mddone;
         }
      }
      if (positive()) {
         if (_MM_GET_ROUNDING_MODE() == _MM_ROUND_UP) {
            rbit[NI-2] = 1;
            addm(rbit);
            if (s[2] != 0) {
               eshdn1();
               exp += 1;
            }
         } else {
            rbit[NI-2] = 1;
            subm(rbit);
            if (s[2] != 0) {
               eshdn1();
               exp += 1;
            }
         }
      } else {
         if (_MM_GET_ROUNDING_MODE() == _MM_ROUND_DOWN) {
            rbit[NI-2] = 1;
            addm(rbit);
            if (s[2] != 0) {
               eshdn1();
               exp += 1;
            }
         } else {
            rbit[NI-2] = 1;
            subm(rbit);
            if (s[2] != 0) {
               eshdn1();
               exp += 1;
            }
         }
      }
   }
mddone:
   if (exp > 32767) {
   overf:
      s[1] = 32767;
      s[2] = 0;
      for(i=M+1;i<NI-1;i++)
         s[i] = 0xffff;
      s[NI-1] = 0;
      return ;
   }
   if (exp < 0)
      s[1] = 0;
   else s[1] = (unsigned short)exp;
   s[NI-1] = 0;
}

USRDouble::USRDouble(void)

{
   for(int i=0;i<NE;i++)
      w[i] = 0x0000;
}

USRDouble::USRDouble(double d)

{
   SECDouble dd(d);
   *this = dd;
}

USRDouble::USRDouble(const SECDouble& f)

{
    unsigned short *p,*q;
   unsigned short i;
   p = (unsigned short*) f.w;
   q = w + (NE-1);
   i = *p++;
   if (i)
      *q-- = *p++ | 0x8000;
   else *q-- = *p++;
   ++p;
   *q-- = *p++;
   *q-- = *p++;
   *q-- = *p++;
   *q-- = *p++;
}

USRDouble::USRDouble(const USRDouble& f)

{
   for(int i=0;i<NE;i++)
      w[i] = f.w[i];
}

USRDouble::USRDouble(unsigned short* ptr)

{
   for(int i=0;i<NE;i++)
      w[i] = *ptr++;
}

double USRDouble::getDouble()

{
   SECDouble tmp(*this);
   return tmp.getDouble();
}

USRDouble& USRDouble::operator=(const USRDouble& f)

{
   for(int i=0;i<NE;i++)
      w[i] = f.w[i];
   return *this;
}

USRDouble& USRDouble::operator=(const SECDouble& f)

{
    unsigned short *q;
    unsigned short i,j;
   j = 0;
   q = w + (NE-1);
   i = f.w[j++];
   if (i)
      *q-- = f.w[j++] | 0x8000;
   else *q-- = f.w[j++];
   ++j;
   *q-- = f.w[j++];
   *q-- = f.w[j++];
   *q-- = f.w[j++];
   *q-- = f.w[j++];
   return *this;
}

USRDouble& USRDouble::operator=(unsigned short* f)

{
   for(int i=0;i<NE;i++)
      w[i] = f[i];
   return *this;
}

void USRDouble::clear()

{
   for(int i=0;i<NE;i++)
      w[i] = 0x0000;
}

static unsigned short bmask[] = {
   0xffff,
   0xfffe,
   0xfffc,
   0xfff8,
   0xfff0,
   0xffe0,
   0xffc0,
   0xff80,
   0xff00,
   0xfe00,
   0xfc00,
   0xf800,
   0xf000,
   0xe000,
   0xc000,
   0x8000,
   0x0000};


USRDouble USRDouble::floor()

{
   USRDouble one(1);
   USRDouble cpy(*this);
   USRDouble res;
    unsigned short *p;
   int e,expon,i;
   expon = exponent();
   e = (expon & 0x7fff) - (IEEEBIAS -1);
   if (e <= 0)
      goto isitneg;
   e = NBITS - e;
   res = cpy;
   if (e<=0)
      return res;
   p = &res[0];
   while (e>= 16) {
      *p++ = 0;
      e -=16;
   }
   *p &= bmask[e];
isitneg:
   if (expon & 0x8000) {
      for(i=0;i<NE-1;i++) {
         if (cpy[i] != res[i]) {
            res = res - one;
            break;
         }
      }
   }
   return res;
}

USRDouble USRDouble::operator+(const USRDouble& op2) { SECDouble o1(*this);return o1.add(op2,0);}
USRDouble USRDouble::operator-(const USRDouble& op2) { SECDouble o1(op2);return o1.add(*this,1);}
USRDouble USRDouble::operator*(const USRDouble& op2) { SECDouble o1(*this);return o1.mul(op2);}
USRDouble USRDouble::operator/(const USRDouble& op2) { SECDouble o1(*this);return o1.div(op2);}

int USRDouble::operator==(const USRDouble& op2)     { SECDouble o1(*this); return o1.cmp(op2) == 0;}
int USRDouble::operator<=(const USRDouble& op2)     { SECDouble o1(*this); return o1.cmp(op2) <= 0;}
int USRDouble::operator>=(const USRDouble& op2)     { SECDouble o1(*this); return o1.cmp(op2) >= 0;}
int USRDouble::operator<(const USRDouble& op2)      { SECDouble o1(*this); return o1.cmp(op2) < 0;}
int USRDouble::operator>(const USRDouble& op2)      { SECDouble o1(*this); return o1.cmp(op2) > 0;}
int USRDouble::cmp(const USRDouble& op2)            { SECDouble o1(*this); return o1.cmp(op2);}

