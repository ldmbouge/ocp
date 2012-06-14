/************************************************************************
 MIT License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 Permission is hereby granted, free of charge, to any person obtaining
 a copy of this software and associated documentation files (the
 "Software"), to deal in the Software without restriction, including
 without limitation the rights to use, copy, modify, merge, publish,
 distribute, sublicense, and/or sell copies of the Software, and to
 permit persons to whom the Software is furnished to do so, subject to
 the following conditions:
 
 The above copyright notice and this permission notice shall be
 included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
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
