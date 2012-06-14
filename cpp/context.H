//
//  context.h
//  Clo
//
//  Created by Laurent Michel on 5/22/11.
//  Copyright 2011 CSE. All rights reserved.
//
#if !defined(__CONTCONTEXT_H)
#define __CONTCONTEXT_H

#include <string.h>

class  NSCont;

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
   int cs;
   int ss;
   int ds;
   int fs;
   int es;
   int gs;
   long   rip;
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


