//
//  ORInterval.m
//  Clo
//
//  Created by Laurent Michel on 7/5/13.
//
//

#import "ORInterval.h"
#include <float.h>


static double pinf = 0;
static double ninf = 0;

void ORIInit()
{
   double MZ   = 0;
#ifndef BYTE_ORDER
   sintx testInt = 0x12345678;
   char* ptestInt = (char*) &testInt;
   int bigendian = ptestInt[0]==0x78 ? 0 : 1;
#else
#if BYTE_ORDER == BIG_ENDIAN
   int bigendian = 1;
#else
   int bigendian = 0;
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
}
