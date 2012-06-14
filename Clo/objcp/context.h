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

#if !defined(__CONTCONTEXT_H)
#define __CONTCONTEXT_H

#import <Foundation/Foundation.h>

@class  NSCont;

#if defined(__x86_64__)
struct Ctx64 {
   long rax;
   long rbx;
   long rcx;
   long rdx;
   long rdi;
   long rsi;
   long rbp;
   long rsp;
   long r8;
   long r9;
   long r10;
   long r11;
   long r12;
   long r13;
   long r14;
   long r15;
   long   rip;
   long   pad; // alignment padding.
   double xmm0[2];
   double xmm1[2];
};
__attribute__((noinline)) NSCont* saveCtx(struct Ctx64* ctx,NSCont* k);
__attribute__((noinline)) NSCont* restoreCtx(struct Ctx64* ctx,char* start,char* data,size_t length);
#else
#include <setjmp.h>
#endif

void initContinuationLibrary(int *base);
char* getContBase();

#endif


