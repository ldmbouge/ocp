/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

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

#endif


