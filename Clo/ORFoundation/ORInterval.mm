//
//  ORInterval.m
//  Clo
//
//  Created by Laurent Michel on 7/5/13.
//
//

#import "ORInterval.h"
#include <float.h>

@interface ORILib : NSObject
+(void)load;
@end

@implementation ORILib
+(void)load
{
   ORIInit();
   NSLog(@"ORILib::load called...");
   @autoreleasepool {
      NSLog(@"Infinity: %@",ORIFormat(INF));
      NSLog(@"Epsilon : %@",ORIFormat(EPSILON));
      NSLog(@"Zero    : %@",ORIFormat(ZERO));
      NSLog(@"Flip    : %@",ORIFormat(FLIP));
   }
}
@end

static int bigendian;

void ORIInit()
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
   // NOW DEFINE THE STATIC INTERVALS.
   FLIP = _mm_set_pd(0.0, MZ);
   EPSILON = _mm_set1_pd(-DBL_MIN);
   ZERO    = _mm_set_pd(0.0,MZ);
   INF     = _mm_set_pd(ninf,ninf);
   _MM_SET_ROUNDING_MODE(_MM_ROUND_DOWN);
}

// ===========================================================================================
// Printing ORIntervals faithfully.
// ===========================================================================================

static void printLow(double v,char* buf,int ndigs);
static void printUp(double v,char* buf,int ndigs);
static void sprint(double v,char* buf,int ndigs);

NSString* ORIFormat(ORInterval a)
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

class SECFloat;

class USRFloat {
   union {
      unsigned short w[5];
      USRalias al;
   };
   friend class SECFloat;
public:
   USRFloat(void);
   USRFloat(const SECFloat& f);
   USRFloat(const USRFloat& f);
   USRFloat(double d);
   USRFloat(unsigned short* ptr);
   USRFloat& operator=(const USRFloat& f);
   USRFloat& operator=(const SECFloat& f);
   USRFloat& operator=(unsigned short* f);
   int positive() { return (al.expSign & 0x8000) == 0;}
   int negative() { return (al.expSign & 0x8000) == 0x8000;}
   void setPositive() { al.expSign &= 0x7fff;}
   void setNegative() { al.expSign |= 0x8000;}
   unsigned short exponent() { return al.expSign;}
   void setExponent(unsigned short e) { al.expSign = e;}
   unsigned short& operator[](int i) { return w[i];}
   double getDouble();
   operator double() { return getDouble();}
   USRFloat operator+(const USRFloat& op2);
   USRFloat operator-(const USRFloat& op2);
   USRFloat operator*(const USRFloat& op2);
   USRFloat operator/(const USRFloat& op2);
   int operator==(const USRFloat& op2);
   int operator!=(const USRFloat& op2);
   int operator<=(const USRFloat& op2);
   int operator>=(const USRFloat& op2);
   int operator<(const USRFloat& op2);
   int operator>(const USRFloat& op2);
   int cmp(const USRFloat& op2);
   USRFloat floor();
   void clear();
};

class SECFloat {
   union {
      unsigned short w[8];
      SECalias al;
   };
   friend class USRFloat;
public:
   SECFloat(void);
   SECFloat(double d);
   SECFloat(const SECFloat& sf);
   SECFloat(const USRFloat& uf);
   SECFloat& operator=(const SECFloat& sf);
   SECFloat& operator=(const USRFloat& sf);
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
   SECFloat add(SECFloat op2,int subflg=0);
   int      cmp(SECFloat op2);
   SECFloat mul(SECFloat op2);
   SECFloat div(SECFloat op2);
   SECFloat rem(SECFloat op2);
   void clear();
   int shift(int sc);
   int normlz();
   void addm(SECFloat& s);
   void subm(SECFloat& s);
   int  cmpm(SECFloat& s);
   int  mulm(SECFloat& s);
   int  divm(SECFloat& s);
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

static __thread SECFloat equot;
static __thread SECFloat rbit;

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
   USRFloat y(v);
   USRFloat t(1);
   USRFloat ezero(0.0);
   USRFloat u;
   USRFloat r;
   USRFloat one(1);
   USRFloat ten = etens[NTEN];
   USRFloat p;
   USRFloat x;
   SECFloat ww;
   SECFloat z;
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
   SECFloat a(t);
   SECFloat b(y);
   b = b.rem(a);
   digit = equot[NI-1];
   while (digit==0 && b.cmp(0) != 0) {
      b.eshup1();
      SECFloat c(b);
      c.eshup1();
      c.eshup1();
      b.addm(c);
      b = b.rem(t);
      digit = equot[NI-1];
      expon -= 1;
   }
   s = buf;
   *s++ = (char)digit + '0';
   if (ndigs < 0)    ndigs = 0;
   if (ndigs > NDEC) ndigs = NDEC;
   
   for(k=0;k<=ndigs;k++) {
      b.eshup1();
      SECFloat a(b);
      a.eshup1();
      a.eshup1();
      b.addm(a);
      b = b.rem(t);
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

SECFloat::SECFloat(void)

{
   clear();
}

SECFloat::SECFloat(double d)

{
   unsigned short* e = (unsigned short*)&d;
   
   register unsigned short r;
   register unsigned short *p;
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

SECFloat::SECFloat(const SECFloat& sf)

{
   for(int i=0;i<NI;i++)
      w[i] = sf.w[i];
}

SECFloat& SECFloat::operator=(const SECFloat& sf)

{
   for(int i=0;i<NI;i++)
      w[i] = sf.w[i];
   return *this;
}

SECFloat& SECFloat::operator=(const USRFloat& sf)

{
   register unsigned short *q;
   register unsigned short k;
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

SECFloat::SECFloat(const USRFloat& uf)

{
   register unsigned short *p,*q;
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

double SECFloat::getDouble()

{
   double res;
   unsigned short *e = (unsigned short*)&res;
   SECFloat xi(*this);
   int i,k;
   register unsigned short *p;
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
      SECFloat ri;
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


void SECFloat::clear()

{
   register unsigned short *xi = w;
   register int i;
   for(i=0;i<NI;i++)
      *xi++ = 0x0000;
}

int SECFloat::isZero()

{
   for(int i=0;i<NI;i++)
      if (w[i]) return 0;
   return 1;
}

int SECFloat::isOne()

{
   SECFloat onef(1);
   return cmp(onef);
}

int SECFloat::shift(int sc)

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

int SECFloat::normlz()

{
   unsigned short *x = w;
   register unsigned short *p;
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

void SECFloat::addm(SECFloat& s)

{
   unsigned short* x = &s[0];
   unsigned short* y = w;
   register unsigned int a;
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

void SECFloat::subm(SECFloat& s)

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

int  SECFloat::cmpm(SECFloat& s)

{
   register unsigned short *a = w;
   register unsigned short *b = &s[0];
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

int  SECFloat::mulm(SECFloat& s)

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

int  SECFloat::divm(SECFloat& s)

{
   unsigned short *den = &s[0];
   unsigned short *num = w;
   int i,j;
   register unsigned short *p,*q;
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

void SECFloat::eshdn1()

{
   register unsigned short *x = w;
   register unsigned short bits;
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

void SECFloat::eshup1()

{
   register unsigned short *x = w;
   register unsigned short bits;
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

void SECFloat::eshdn8()

{
   register unsigned short *x = w;
   register unsigned short newbyt,oldbyt;
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

void SECFloat::eshup8()

{
   int i;
   register unsigned short *x = w;
   register unsigned short newbyt,oldbyt;
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

void SECFloat::eshup16()

{
   int i;
   register unsigned short *x = w;
   register unsigned short *p;
   p = x + M;
   x += M + 1;
   for(i=M;i<NI-1;i++)
      *p++ = *x++;
   *p = 0;
}

void SECFloat::eshdn16()

{
   int i;
   register unsigned short *x = w;
   register unsigned short *p;
   x += NI-1;
   p = x + 1;
   for(i=M;i<NI-1;i++)
      *--p = *--x;
   *--p = 0;
}

void SECFloat::makeInf()

{
   register unsigned short *x = w;
   register int i;
   for(i=0;i<NE-1;i++)
      *x++ = 0xffff;
   *x |= 0x7fff;
}

SECFloat SECFloat::add(SECFloat op2,int subflg)

{
   if (subflg) negate();
   int k,lost,i;
   int lta = exponent();
   int ltb = op2.exponent();
   int lt  = lta - ltb;
   if (lt > 0) {
      SECFloat tmp = *this;
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
            SECFloat tmp;
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
                  SECFloat res;
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
         SECFloat tmp = *this;
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

int SECFloat::cmp(SECFloat op2)

{
   register unsigned short *p,*q;
   register int i;
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

SECFloat SECFloat::mul(SECFloat op2)

{
   SECFloat res;
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
   j = res.mulm(op2);
   lt = lta + ltb - (IEEEBIAS-1);
   res.rnorm(j,0,lt,64);
   if (sign() == op2.sign())
      res.setPositive();
   else res.setNegative();
   return res;
}

SECFloat SECFloat::div(SECFloat op2)

{
   SECFloat res;
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
   i = res.divm(op2);
   lt = lta - ltb + IEEEBIAS;
   res.rnorm(i,0,lt,64);
   if (sign() == op2.sign())
      res.setPositive();
   else res.setNegative();
   return res;
}

SECFloat SECFloat::rem(SECFloat op2)

{
   SECFloat res;
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

void SECFloat::rnorm(int lost,int subflg,int exp,int rcntrl)

{
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

USRFloat::USRFloat(void)

{
   for(int i=0;i<NE;i++)
      w[i] = 0x0000;
}

USRFloat::USRFloat(double d)

{
   SECFloat dd(d);
   *this = dd;
}

USRFloat::USRFloat(const SECFloat& f)

{
   register unsigned short *p,*q;
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

USRFloat::USRFloat(const USRFloat& f)

{
   for(int i=0;i<NE;i++)
      w[i] = f.w[i];
}

USRFloat::USRFloat(unsigned short* ptr)

{
   for(int i=0;i<NE;i++)
      w[i] = *ptr++;
}

double USRFloat::getDouble()

{
   SECFloat tmp(*this);
   return tmp.getDouble();
}

USRFloat& USRFloat::operator=(const USRFloat& f)

{
   for(int i=0;i<NE;i++)
      w[i] = f.w[i];
   return *this;
}

USRFloat& USRFloat::operator=(const SECFloat& f)

{
   register unsigned short *q;
   register unsigned short i,j;
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

USRFloat& USRFloat::operator=(unsigned short* f)

{
   for(int i=0;i<NE;i++)
      w[i] = f[i];
   return *this;
}

void USRFloat::clear()

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


USRFloat USRFloat::floor()

{
   USRFloat one(1);
   USRFloat cpy(*this);
   USRFloat res;
   register unsigned short *p;
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

USRFloat USRFloat::operator+(const USRFloat& op2) { SECFloat o1(*this);return o1.add(op2,0);}
USRFloat USRFloat::operator-(const USRFloat& op2) { SECFloat o1(op2);return o1.add(*this,1);}
USRFloat USRFloat::operator*(const USRFloat& op2) { SECFloat o1(*this);return o1.mul(op2);}
USRFloat USRFloat::operator/(const USRFloat& op2) { SECFloat o1(*this);return o1.div(op2);}

int USRFloat::operator==(const USRFloat& op2)     { SECFloat o1(*this); return o1.cmp(op2) == 0;}
int USRFloat::operator<=(const USRFloat& op2)     { SECFloat o1(*this); return o1.cmp(op2) <= 0;}
int USRFloat::operator>=(const USRFloat& op2)     { SECFloat o1(*this); return o1.cmp(op2) >= 0;}
int USRFloat::operator<(const USRFloat& op2)      { SECFloat o1(*this); return o1.cmp(op2) < 0;}
int USRFloat::operator>(const USRFloat& op2)      { SECFloat o1(*this); return o1.cmp(op2) > 0;}
int USRFloat::cmp(const USRFloat& op2)            { SECFloat o1(*this); return o1.cmp(op2);}

