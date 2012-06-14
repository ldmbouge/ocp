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

#import <Foundation/Foundation.h>

#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include "context.h"
#include <objcp/CPTypes.h>

typedef struct  {
   Class poolClass;
   CPUInt low;
   CPUInt high;
   CPUInt sz;
   CPUInt nbCont;
   id*          pool;
} ContPool;

@interface NSCont : NSObject {
@private
#if defined(__x86_64__)
   struct Ctx64   _target __attribute__ ((aligned(16)));
#else
   jmp_buf _target;
#endif
   size_t _length;
   void* _start;   
   char* _data;
   int _used;
   CPInt field;  // a stored property
   id  fieldId;
   CPInt _cnt;
}
+(id)new;
-(void)saveStack:(size_t)len startAt:(void*)s;
-(void)call; 
-(CPInt)nbCalls;
-(void)dealloc;
-(void)letgo;
-(void)grab;
+(NSCont*) takeContinuation;
+(void)shutdown;
@property (readwrite,assign) CPInt field;
@property (readwrite,assign) id  fieldId;
@end 


