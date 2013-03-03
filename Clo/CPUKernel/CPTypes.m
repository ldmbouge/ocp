/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <CPUKernel/CPUKernel.h>
#import <CPUKernel/CPEngine.h>

#if defined(__linux__)
void failNow()
{
   static ORFailException* fex = nil;
   if (fex==nil) fex = [ORFailException new];
   @throw  [fex retain];
}
#else
void failNow()
{
   static ORFailException* fex = nil;
   if (fex==nil) fex = [ORFailException new];
   @throw  CFRetain(fex);
}
#endif