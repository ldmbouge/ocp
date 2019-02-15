/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <ORUtilities/context.h>
#import <ORUtilities/cont.h>
#import "pthread.h"

#if TARGET_OS_IPHONE==0
static __thread char* baseStack = 0;
#else
static char* baseStack = 0;
#endif

#if defined(__x86_64__)

__attribute__((noinline)) NSCont* saveCtx(struct Ctx64* ctx,NSCont* k)
{
   NSCont* var = 0;
   char* sp;
   asm volatile("movq %%rsp , %%rax;" // load rax with SP
                :"=a"(sp)
                );
   size_t len = baseStack - sp;
   [k saveStack:len startAt:sp];
   asm volatile("movq %%rbx,8(%%rax);\n\t"
                "movq %%rcx,16(%%rax);\n\t"
                "movq %%rdx,24(%%rax);\n\t"
                "movq %%rdi,32(%%rax);\n\t"
                "movq %%rsi,40(%%rax);\n\t"
                "movq %%rbp,48(%%rax);\n\t"
                "movq %%rsp,56(%%rax);\n\t"
                "movq %%r8,64(%%rax);\n\t"
                "movq %%r9,72(%%rax);\n\t"
                "movq %%r10,80(%%rax);\n\t"
                "movq %%r11,88(%%rax);\n\t"
                "movq %%r12,96(%%rax);\n\t"
                "movq %%r13,104(%%rax);\n\t"
                "movq %%r14,112(%%rax);\n\t"
                "movq %%r15,120(%%rax);\n\t"
                "stmxcsr 140(%%rax);\n\t"
                "movdqa %%xmm0, 144(%%rax);\n\t"
                "movdqa %%xmm1, 160(%%rax);\n\t"
                "movdqa %%xmm2, 176(%%rax);\n\t"
                "movdqa %%xmm3, 192(%%rax);\n\t"
                "movdqa %%xmm4, 208(%%rax);\n\t"
                "movdqa %%xmm5, 224(%%rax);\n\t"
                "movdqa %%xmm6, 240(%%rax);\n\t"
                "movdqa %%xmm7, 256(%%rax);\n\t"
                "movdqa %%xmm8, 272(%%rax);\n\t"
                "movdqa %%xmm9, 288(%%rax);\n\t"
                "movdqa %%xmm10, 304(%%rax);\n\t"
                "movdqa %%xmm11, 320(%%rax);\n\t"
                "movdqa %%xmm12, 336(%%rax);\n\t"
                "movdqa %%xmm13, 352(%%rax);\n\t"
                "movdqa %%xmm14, 368(%%rax);\n\t"
                "movdqa %%xmm15, 384(%%rax);\n\t"
                "fsave 400(%%rax);\n\t"
                "jmp   resume;\n\t"
                "goon: popq %%rbx;\n\t"
                "      movq %%rbx, 128(%%rax);\n\t"
                "      xor %%rax,%%rax;\n\t"
                "      jmp end;\n\t"
                "resume: call goon;\n\t"
                "end: nop;\n\t"
                :"=a"(var)
                :"a"(ctx)
                );   
   return var;
}

__attribute__((noinline)) NSCont* restoreCtx(struct Ctx64* ctx,char* start,char* data,size_t length) 
{
   NSCont* rv = 0;
   // ctx in rdi, start in rsi, data in rdx, length in ecx   
   asm volatile("copystack: cmp $0x0,%%ecx         ; \n\t" //test length to 0
                "           jle donecopy           ; \n\t" //if length <= 0 break loop
                "           movq (%%rdx),%%rax     ; \n\t" //read 8 bytes (quad)
                "           add $0x8,%%rdx         ; \n\t" //data+=8
                "           movq %%rax,(%%rsi)     ; \n\t" // *start = data
                "           add $0x8,%%rsi         ; \n\t" //start+=8                
                "           add $0xfffffff8,%%ecx  ; \n\t" //substract 8 to length
                "           jmp copystack          ; \n\t" //go to top
                "donecopy:  mov %%rdi,%%rax        ; \n\t" // place address of context in rax
                "movq 8(%%rax),%%rbx               ; \n\t" // restore state (context is in rax)
                "movq 16(%%rax),%%rcx;\n\t"
                "movq 24(%%rax),%%rdx;\n\t"
                "movq 32(%%rax),%%rdi;\n\t"
                "movq 40(%%rax),%%rsi;\n\t"
                "movq 48(%%rax),%%rbp;\n\t"
                "movq 56(%%rax),%%rsp;\n\t"
                "movq 64(%%rax),%%r8;\n\t"
                "movq 72(%%rax),%%r9;\n\t"
                "movq 80(%%rax),%%r10;\n\t"
                "movq 88(%%rax),%%r11;\n\t"
                "movq 96(%%rax),%%r12;\n\t"
                "movq 104(%%rax),%%r13;\n\t"
                "movq 112(%%rax),%%r14;\n\t"
                "movq 120(%%rax),%%r15;\n\t"
                "ldmxcsr 140(%%rax);\n\t"
                "movdqa 144(%%rax),%%xmm0;\n\t"
                "movdqa 160(%%rax),%%xmm1;\n\t"               
                "movdqa 176(%%rax),%%xmm2;\n\t"
                "movdqa 192(%%rax),%%xmm3;\n\t"
                "movdqa 208(%%rax),%%xmm4;\n\t"
                "movdqa 224(%%rax),%%xmm5;\n\t"
                "movdqa 240(%%rax),%%xmm6;\n\t"
                "movdqa 256(%%rax),%%xmm7;\n\t"
                "movdqa 272(%%rax),%%xmm8;\n\t"
                "movdqa 288(%%rax),%%xmm9;\n\t"
                "movdqa 304(%%rax),%%xmm10;\n\t"
                "movdqa 320(%%rax),%%xmm11;\n\t"
                "movdqa 336(%%rax),%%xmm12;\n\t"
                "movdqa 352(%%rax),%%xmm13;\n\t"
                "movdqa 368(%%rax),%%xmm14;\n\t"
                "movdqa 384(%%rax),%%xmm15;\n\t"
                "frstor 400(%%rax);\n\t"
                "movq 128(%%rax),%%rdi;\n\t"
                "movq (%%rax),%%rax;\n\t"
                "jmp *%%rdi;\n\t"
                :"=a"(rv) 
                :"D"(ctx));  
   return rv;
}
#endif

char* getContBase(void)
{
   return baseStack;
}

__attribute__((noinline)) void initContinuationLibrary(int *base)
{
   int x;
   while ((long)base & 0x7)
      ++base;  // widen & align
   baseStack = (char*)base;
   NSLog(@"local adr is: %p\n" ,&x);
   NSLog(@"base  adr is: %p\n",(void*)base);
   NSLog(@"distance    : %ld\n", (long)(((char*)base) - ((char*)&x)));
}
