/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "ORControl.h"

@implementation ORControl
+(void) forall: (id<ORIntIterator>) S suchThat: (ORInt2Bool) suchThat orderedBy: (ORInt2Int) order do: (ORInt2Void) body
{
   ORInt sz = [S size];
   ORInt* value = alloca(sizeof(ORInt)*sz);
   bool* used = alloca(sizeof(bool)*sz);
   memset(used,0,sizeof(bool)*sz);
   id<IntEnumerator> ite = [S enumerator];
   ORInt nb = 0;
   while ([ite more]) {
      value[nb] = [ite next];
      if (!suchThat || suchThat(value[nb]))
         nb++;
   }
   bool done = false;
   while (!done) {
      float best = MAXFLOAT;
      ORInt chosen = -1;
      ORInt i = 0;
      while (i < nb) {
         if (!used[i] && (!suchThat || suchThat(value[i]))) {
            ORInt efi = order? order(value[i]) : i;
            if (efi < best) {
               chosen = i;
               best = efi;
            }
         }
         ++i;
      }
      done = (chosen == -1);
      if (!done) {
         used[chosen] = true;
         body(value[chosen]);
      }
   }
}
@end
