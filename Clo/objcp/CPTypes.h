/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#ifndef __CPTYPES_H
#define __CPTYPES_H

#if !defined(__APPLE__) || defined(__IPHONE_NA)
typedef unsigned long long uint64;
typedef long long sint64;
typedef unsigned int uint32;
typedef int sint32;
typedef unsigned short uint16;
typedef signed short sint16;
typedef unsigned char uint8;
typedef signed char sint8;
#endif

typedef sint32 CPInt;
typedef uint32 CPUInt;
typedef sint64 CPLong;
typedef uint64 CPULong;

static inline CPInt minOf(CPInt a,CPInt b) { return a < b ? a : b;}
static inline CPInt maxOf(CPInt a,CPInt b) { return a > b ? a : b;}

static inline CPInt min(CPInt a,CPInt b) { return a < b ? a : b;}
static inline CPInt max(CPInt a,CPInt b) { return a > b ? a : b;}

#define MAXINT ((CPInt)0x7FFFFFFF)
#define MININT ((CPInt)0x80000000)

#define MAXUNSIGNED ((CPUInt)0xFFFFFFFF)
#define MINUNSIGNED ((CPUInt)0x0)

#endif
