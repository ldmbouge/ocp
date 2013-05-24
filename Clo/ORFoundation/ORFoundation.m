/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "ORFoundation.h"

#if defined(__linux__)
void failNow()
{
   static ORFailException* fex = nil;
   if (fex==nil) fex = [ORFailException new];
   @throw  [fex retain];
}
#else

static __thread jmp_buf* ptr = 0;

static inline void failTo(jmp_buf* jb)
{
   ptr = jb;
}

static inline void restoreFail(jmp_buf* old)
{
   ptr = old;
}

ORStatus tryfail(ORStatus(^block)(),ORStatus(^handle)())
{
   jmp_buf buf;
   jmp_buf* old = ptr;
   int st = _setjmp(buf);
   if (st==0) {
      failTo(&buf);
      ORStatus rv = block();
      restoreFail(old);
      return rv;
   } else {
      restoreFail(old);
      return handle();
   }
}

void failNow()
{
   /*
    static ORFailException* fex = nil;
    if (fex==nil) fex = [ORFailException new];
    @throw  CFRetain(fex);
    */
   _longjmp(*ptr, 1);
}
#endif

