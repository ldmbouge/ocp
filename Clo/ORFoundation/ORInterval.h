//
//  ORInterval.h
//  Clo
//
//  Created by Laurent Michel on 7/5/13.
//
//

#import <Foundation/Foundation.h>

#include "emmintrin.h"

typedef __m128d ORInterval;
static ORInterval INF;
static ORInterval FLIP;
static ORInterval EPSILON;
static ORInterval ZERO;
static double pinf = 0;
static double ninf = 0;

void ORIInit();

NSString* ORIFormat(ORInterval a);

static inline bool ORINegative(ORInterval x)
{
   return _mm_comile_sd(_mm_shuffle_pd(x, x, 1),_mm_setzero_pd());
}
static inline bool ORIPositive(ORInterval x)
{
   return _mm_comige_sd(_mm_xor_pd(x, FLIP), _mm_setzero_pd());
}
static inline bool ORISureNegative(ORInterval x)
{
   return _mm_comigt_sd(x,_mm_setzero_pd());
}
static inline bool ORISurePositive(ORInterval x)
{
   return _mm_comigt_sd(_mm_shuffle_pd(x, x, 1),_mm_setzero_pd());
}
static inline bool ORIContainsZero(ORInterval x)
{
   __m128d result = _mm_cmple_pd(x,_mm_setzero_pd());
   double b[2];
   _mm_storeu_pd(b,result);
   return b[0]!=0 && b[1]!=0;
}
static inline bool ORIEmpty(ORInterval x)
{
   ORInterval n = _mm_xor_pd(x,FLIP);
   ORInterval s = _mm_shuffle_pd(n,n,1);
   return _mm_comilt_sd(n,s);
}
static inline bool ORIBound(ORInterval a,double epsilon)
{
   ORInterval ne = _mm_xor_pd(_mm_set1_pd(epsilon),_mm_set_pd(-1.0 * 0.0,-1.0 * 0.0));
   ORInterval s  = _mm_shuffle_pd(a, a, 1);
   ORInterval d  = _mm_add_pd(a,s);
   return _mm_comigt_sd(d,ne);
}
static inline bool ORIEqual(ORInterval a,ORInterval b)
{
   ORInterval c = _mm_cmpeq_pd(a, b);
   double s[2];
   _mm_storeu_pd(s, c);
   return s[0]!=0 && s[1]!=0;
}
static inline ORInterval createORI1(double v)
{
   return _mm_xor_pd(_mm_set1_pd(v),FLIP);
}
static inline ORInterval createORI2(double a,double b)
{
   return _mm_xor_pd(_mm_set_pd(a,b),FLIP);
}
static inline void ORIBounds(ORInterval a,double* low,double *up)
{
   double b[2];
   _mm_storeu_pd(b, _mm_xor_pd(a,FLIP));
   *low = b[1];
   *up  = b[0];
}
static inline double ORILow(ORInterval a)
{
   double b[2];
   _mm_storeu_pd(b, _mm_xor_pd(a,FLIP));
   return b[1];
}
static inline double ORIUp(ORInterval a)
{
   double b[2];
   _mm_storeu_pd(b, _mm_xor_pd(a,FLIP));
   return b[0];
}
static inline ORInterval ORIOpposite(ORInterval x)
{
   return _mm_shuffle_pd(x,x,1);
}
static inline ORInterval ORIAdd(ORInterval a,ORInterval b)
{
   return _mm_add_pd(a,b);
}
static inline ORInterval ORISub(ORInterval a,ORInterval b)
{
   return _mm_add_pd(a,ORIOpposite(b));
}
static inline ORInterval ORIMul(ORInterval a,ORInterval b)
{
   __m128d ma = _mm_shuffle_pd(a,a,1);
   __m128d mb = _mm_sub_pd(_mm_setzero_pd(),b);
   __m128d pp2= _mm_mul_pd(ma,b);
   __m128d pp3= _mm_mul_pd(a,mb);
   __m128d pp4= _mm_mul_pd(ma,mb);
   __m128d pp1= _mm_mul_pd(a,b);
   __m128d min1 = _mm_min_pd(pp2,pp3);
   __m128d min2 = _mm_min_pd(pp1,pp4);
   __m128d xch1 = _mm_unpackhi_pd(min1,min2);
   __m128d xch2 = _mm_unpacklo_pd(min1,min2);
   __m128d finl = _mm_min_pd(xch1,xch2);
   return finl;
}
static inline ORInterval ORInverse(ORInterval a)
{
   if (ORIContainsZero(a))
      return INF;
   else {
      __m128d rv = _mm_div_pd(_mm_set1_pd(-1.0),a);
      return _mm_shuffle_pd(rv,rv,1);
   }
}
static inline ORInterval ORIDiv(ORInterval a,ORInterval b)
{
   return ORIMul(a,ORInverse(b));
}
static inline ORInterval ORIInter(ORInterval a,ORInterval b)
{
   return _mm_max_pd(a, b);
}
static inline ORInterval ORIUnion(ORInterval a,ORInterval b)
{
   return _mm_min_pd(a, b);
}
static inline ORInterval ORISwap(ORInterval a)
{
   return _mm_xor_pd(_mm_shuffle_pd(a, a, 1),_mm_set_pd(-1.0 * 0.0,-1.0 * 0.0));
}
static inline ORInterval ORISquare(ORInterval a)
{
   ORInterval sa = _mm_shuffle_pd(a,a,1);
   ORInterval mn = _mm_min_sd(a,sa);
   ORInterval mx = _mm_max_sd(a,sa);
   ORInterval mx0= _mm_max_sd(mx,_mm_setzero_pd());
   ORInterval rv = _mm_unpacklo_pd(mn,mx0);
   ORInterval nx  = _mm_xor_pd(rv, FLIP);
   return _mm_mul_pd(rv,nx);
}
static inline ORInterval ORIAbs(ORInterval a)
{
   ORInterval sa = _mm_shuffle_pd(a,a,1);
   ORInterval mn = _mm_min_sd(a,sa);
   ORInterval mx = _mm_max_sd(a,sa);
   ORInterval mx0= _mm_max_sd(mx,_mm_setzero_pd());
   return _mm_unpacklo_pd(mn,mx0);
}
static inline ORInterval ORISqrt(ORInterval a)
{
   if (ORISureNegative(a))
      return INF;
   else {
      ORInterval na = _mm_xor_pd(a, FLIP);
      ORInterval ra = _mm_sqrt_pd(na);
      ORInterval sq = _mm_mul_pd(ra, ra);
      ra = _mm_max_pd(ra,_mm_set_pd(0.0,ninf));
      ORInterval rv;
      if (_mm_comieq_sd(sq, na))
         rv = _mm_xor_pd(sq, FLIP);
      else {
         ORInterval ne = _mm_set_sd(-DBL_MIN);
         ORInterval su = _mm_sub_sd(ne,sq);
         rv = _mm_shuffle_pd(su, sq, _MM_SHUFFLE2(1, 0));
      }
      ORInterval orv = _mm_shuffle_pd(rv,rv,1);
      ORInterval u   = _mm_min_pd(rv,orv);
      return u;
   }
}
static inline ORInterval ORIPSqrt(ORInterval a)
{
   if (ORISureNegative(a))
      return INF;
   else {
      ORInterval na = _mm_xor_pd(a, FLIP);
      ORInterval ra = _mm_sqrt_pd(na);
      ORInterval sq = _mm_mul_pd(ra, ra);
      ra = _mm_max_pd(ra,_mm_set_pd(0.0,ninf));
      ORInterval rv;
      if (_mm_comieq_sd(sq, na))
         rv = _mm_xor_pd(sq, FLIP);
      else {
         ORInterval ne = _mm_set_sd(-DBL_MIN);
         ORInterval su = _mm_sub_sd(ne,sq);
         rv = _mm_shuffle_pd(su, sq, _MM_SHUFFLE2(1, 0));
      }
      return rv;
   }
}
static inline BOOL ORIReady()
{
   BOOL ready =  _MM_GET_ROUNDING_MODE() == _MM_ROUND_DOWN;
   if (!ready)
      _MM_SET_ROUNDING_MODE(_MM_ROUND_DOWN);
   return ready;
}