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

#import "context.h"
#import "cont.h"
#import "pthread.h"

static char* baseStack = 0;
static pthread_key_t pkeyBase;

#if defined(__x86_64__)

__attribute__((noinline)) NSCont* saveCtx(struct Ctx64* ctx,NSCont* k)
{
   NSCont* var = 0;
   char* sp;
   asm volatile("movq %%rsp , %%rax;" // load rax with SP
                :"=a"(sp)
                );
   size_t len;
   if ([NSThread isMainThread])
      len = baseStack - sp;   
   else {
      char* base = pthread_getspecific(pkeyBase);
      len = base - sp;
   }
   //objc_clear_stack(OBJC_CLEAR_RESIDENT_STACK);
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
                "movdqa %%xmm0, 144(%%rax);\n\t"
                "movdqa %%xmm1, 160(%%rax);\n\t"
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
   NSCont* rv;
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
                "movdqa 144(%%rax),%%xmm0;\n\t"
                "movdqa 160(%%rax),%%xmm1;\n\t"               
                "movq 128(%%rax),%%rdi;\n\t"
                "movq (%%rax),%%rax;\n\t"
                "jmp *%%rdi;\n\t"
                :"=a"(rv) 
                :"D"(ctx));  
   return rv;
}
#endif

char* getContBase()
{
   if ([NSThread isMainThread])
      return baseStack;   
   else {
      char* base = pthread_getspecific(pkeyBase);
      return base;
   }
}

static void init_pthreads() 
{
   pthread_key_create(&pkeyBase,NULL);   
}

void initContinuationLibrary(int *base)
{
   int x;
   while ((long)base & 0x7)
      ++base;  // widen & align
   if ([NSThread isMainThread])   
      baseStack = (char*)base;
   else {
      static pthread_once_t block = PTHREAD_ONCE_INIT;
      pthread_once(&block,init_pthreads);
      pthread_setspecific(pkeyBase,(char*)base);
   }
   NSLog(@"local adr is: %p\n" ,&x);
   NSLog(@"base  adr is: %p\n",(void*)base);
   NSLog(@"distance    : %ld\n", (long)(((char*)base) - ((char*)&x)));
}
