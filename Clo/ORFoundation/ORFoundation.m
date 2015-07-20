/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>

__thread jmp_buf* ptr = 0;

ORStatus tryfail(ORStatus(^block)(),ORStatus(^handle)())
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

