/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <objls/LSVar.h>

ORBool isIdMapped(id<LSIntVarArray> array)
{
   id<ORIntRange> r = array.range;
   ORBool ok = YES;
   for(ORInt k=r.low; k <= r.up && ok;k++)
      ok = getId(array[k]) == k;
   return ok;
}

id<LSIntVar> findByName(id<LSIntVarArray> array,ORInt name)
{
   ORInt l = array.range.low;
   ORInt u = array.range.up;
   while (l <= u) {
      ORInt m = l + (u - l)/2;
      ORInt idm = getId(array[m]);
      if (name == idm)
         return array[m];
      else if (name < idm)
         u = m - 1;
      else
         l = m + 1;
   }
   return nil;
}

ORBool containsVar(id<LSIntVarArray> array,ORInt name)
{
   return findByName(array,name) != nil;
}

ORBounds idRange(id<LSIntVarArray> array)
{
   ORInt lb = FDMAXINT,ub = 0;
   for(id<LSIntVar> x in array) {
      lb = getId(x) < lb ? getId(x) : lb;
      ub = getId(x) > ub ? getId(x) : ub;
   }
   return (ORBounds){lb,ub};
}