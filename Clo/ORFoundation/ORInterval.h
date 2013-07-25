//
//  ORInterval.h
//  Clo
//
//  Created by Laurent Michel on 7/5/13.
//
//

#import <Foundation/Foundation.h>

#include "emmintrin.h"
#include "smmintrin.h"
#include <float.h>

#pragma clang diagnostic push 
#pragma clang diagnostic ignored "-Wunused-variable"

typedef __m128d ORInterval;
extern ORInterval INF;
extern ORInterval FLIP;
extern ORInterval EPSILON;
extern ORInterval ZERO;

extern ORInterval OR_PI,OR_PI2,OR_PI4,OR_3PI2,OR_2PI,OR_5PI2,OR_7PI2,OR_9PI2;

extern double pinf;
extern double ninf;

#pragma clang diagnostic pop

void ORIInit();

#if __cplusplus
extern "C" {
#endif
NSString* ORIFormat(ORInterval a);
#if __cplusplus
}
#endif

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
static inline bool ORIBoundsNEQ(ORInterval x)
{
   return _mm_comineq_sd(x,_mm_shuffle_pd(x,x,1));
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
static inline bool ORIContains(ORInterval a,double v)
{
   // a = [x,y]   (-y , x)
   // v = [z,z]   (-z , z)
   // x <= z && z <= y
   // -y <= -z --> y >= z
   // x <= z               ==?  x <= z && z <= y
   ORInterval vi = _mm_xor_pd(_mm_set1_pd(v),FLIP);
   __m128d result = _mm_cmple_pd(a,vi);
   double b[2];
   _mm_storeu_pd(b,result);
   return b[0]!=0 && b[1]!=0;
}
static inline bool ORIBound(ORInterval a,double epsilon)
{
   ORInterval ne = _mm_xor_pd(_mm_set1_pd(epsilon),_mm_set_pd(-1.0 * 0.0,-1.0 * 0.0));
   ORInterval s  = _mm_shuffle_pd(a, a, 1); // [l , -u ] --> [ -u , l ]
   ORInterval d  = _mm_add_pd(a,s);         // [l , -u ] + [-u , l] = [l - u , -u + l ] ~>  (l - u , u - l)
   return _mm_comigt_sd(d,ne);
}
static inline double ORIWidth(ORInterval a)
{
   ORInterval s  = _mm_shuffle_pd(a, a, 1); // [l , -u ] --> [ -u , l ]
   ORInterval d  = _mm_add_pd(a,s);         // [l , -u ] + [-u , l] = [l - u , -u + l ] ~>  (l - u , u - l)
   double b[2];
   _mm_storeu_pd(b, _mm_xor_pd(d,FLIP));    // fetch the bounds
   return b[0];                             // return up
}
static inline ORInterval ORIFloor(ORInterval a)
{
   return _mm_floor_pd(a);
}
static inline bool ORIEqual(ORInterval a,ORInterval b)
{
   ORInterval c = _mm_cmpeq_pd(a, b);
   double s[2];
   _mm_storeu_pd(s, c);
   return s[0]!=0 && s[1]!=0;
}
static inline bool ORIWider(ORInterval a,ORInterval b)
{
   ORInterval s0  = _mm_shuffle_pd(a, a, 1); // [l,u](-u,l) -> (l,-u)
   ORInterval d0  = _mm_add_pd(a,s0);        // (-u,l)+(l,-u) -> (-u+l,l-u)[l-u,u-l]
   ORInterval s1  = _mm_shuffle_pd(b, b, 1); 
   ORInterval d1  = _mm_add_pd(b,s1);        
   ORInterval c   = _mm_cmple_pd(d0,d1);
   double r[2];
   _mm_storeu_pd(r, c);
   return r[0]!=0;
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
static inline ORInterval ORISubPointwise(ORInterval a,ORInterval b)
{
   return _mm_sub_pd(a,b);
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
   // [a,b](-b,a)  ~>  (a,-b) ~> (-a,b)[b,a]
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
         rv = _mm_xor_pd(ra, FLIP);
      else {
         ORInterval ne = _mm_set_sd(-DBL_MIN);
         ORInterval su = _mm_sub_sd(ne,ra);
         rv = _mm_shuffle_pd(su, ra, _MM_SHUFFLE2(1, 0));
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
         rv = _mm_xor_pd(ra, FLIP);
      else {
         ORInterval ne = _mm_set_sd(-DBL_MIN);
         ORInterval su = _mm_sub_sd(ne,ra);
         rv = _mm_shuffle_pd(su, ra, _MM_SHUFFLE2(1, 0));
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
enum ORNarrowing {
   ORNone = 0,
   ORLow = 1,
   ORUp  = 2,
   ORBoth = 3
};
static inline enum ORNarrowing ORINarrow(ORInterval src,ORInterval by)
{
   ORInterval i = ORIInter(src, by);
   ORInterval t = _mm_cmpneq_pd(src,i);
   double f[2];
   _mm_storeu_pd(f,t);
   if (f[0] && f[1])
      return ORBoth;
   else if (f[0])
      return ORUp;
   else if (f[1])
      return ORLow;
   else return ORNone;
}

ORInterval ORISine(ORInterval a);
ORInterval ORICosine(ORInterval a);
static inline ORInterval ORITan(ORInterval a)
{
   return ORIMul(ORISine(a),ORInverse(ORICosine(a)));
}
static inline ORInterval ORICosec(ORInterval a)
{
   return ORInverse(ORISine(a));
}
static inline ORInterval ORISec(ORInterval a)
{
   return ORInverse(ORICosine(a));
}
static inline ORInterval ORICotan(ORInterval a)
{
   return ORInverse(ORITan(a));
}
ORInterval ORIExp(ORInterval a);

