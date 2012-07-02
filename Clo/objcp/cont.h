/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

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


