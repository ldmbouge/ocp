/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>

#if TARGET_OS_IPHONE==0

__thread jmp_buf* ptr = 0;

ORStatus tryfail(ORStatus(^block)(void),ORStatus(^handle)(void))
{
   jmp_buf buf;
   jmp_buf* old = ptr;
   int st = _setjmp(buf);
   if (st==0) {
      ptr = &buf;
      ORStatus rv = block();
      ptr = old;
      return rv;
   } else {
      ptr = old;
      return handle();
   }
}

void failNow()
{
   _longjmp(*ptr, 1);
}
#else
ORStatus tryfail(ORStatus(^block)(),ORStatus(^handle)())
{
   jmp_buf buf;
   NSValue* tv = [NSThread.currentThread.threadDictionary objectForKey:@(2)];
   jmp_buf* old = tv.pointerValue;
   int st = _setjmp(buf);
   if (st==0) {
      [NSThread.currentThread.threadDictionary setObject:[NSValue valueWithPointer:&buf] forKey:@(2)];
      ORStatus rv = block();
      [NSThread.currentThread.threadDictionary setObject:[NSValue valueWithPointer:old] forKey:@(2)];
      return rv;
   } else {
      [NSThread.currentThread.threadDictionary setObject:[NSValue valueWithPointer:old] forKey:@(2)];
      return handle();
   }
}

void failNow(void)
{
   NSValue* tv = [NSThread.currentThread.threadDictionary objectForKey:@(2)];
   jmp_buf* old = tv.pointerValue;
   _longjmp(*old, 1);
}
#endif

