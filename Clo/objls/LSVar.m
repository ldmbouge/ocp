/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <objls/LSVar.h>
#import "LSPropagator.h"
#import "LSFactory.h"

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
ORInt findRankByName(id<LSIntVarArray> array,ORInt name)
{
   ORInt l = array.range.low;
   ORInt u = array.range.up;
   while (l <= u) {
      ORInt m = l + (u - l)/2;
      ORInt idm = getId(array[m]);
      if (name == idm)
         return m;
      else if (name < idm)
         u = m - 1;
      else
         l = m + 1;
   }
   return l-1;
}


ORBool containsVar(id<LSIntVarArray> array,ORInt name)
{
   return findByName(array,name) != nil;
}

ORBounds idRange(id<NSFastEnumeration> array,ORBounds ib)
{
   for(id<LSIntVar> x in array) {
      ORInt xid = getId(x);
      ib.min = xid < ib.min ? xid : ib.min;
      ib.max = xid > ib.max ? xid : ib.max;
   }
   return ib;
}

void collectSources(id<LSIntVarArray> x,NSArray** asv)
{
   ORInt k = 0;
   for(id<LSIntVar> xk in x) {
      if ([xk isKindOfClass:[LSCoreView class]])
         asv[k] = [(LSCoreView*)xk sourceVars];
      else asv[k] = @[xk];
      assert([asv[k] count] <= 1);
      ++k;
   }
}

id<LSIntVarArray> sourceVariables(LSEngineI* engine,NSArray** asv,ORInt nb,ORBool* multiple)
{
   ORBounds idb = {FDMAXINT,0};
   ORInt k=0;
   for(k=0;k < nb;k++)
      idb = idRange(asv[k],idb);
   
   ORInt tsz = idb.max - idb.min + 1;
   id<LSIntVar>* t = malloc(sizeof(id)*tsz);  // t is indexed by variable ids
   t -= idb.min;
   *multiple = NO;
   for(k=0;k < nb;k++) {
      for(id<LSIntVar> vi in asv[k]) {
         *multiple |= t[getId(vi)] != NULL;
         t[getId(vi)] = vi;
      }
   }
   ORInt nba = 0;                             // count the number of non-nil entries
   for(k=idb.min;k <= idb.max;k++)
      nba += t[k] != nil;
   id<LSIntVarArray> xp = [LSFactory intVarArray:engine range:RANGE(engine,0,nba-1)];
   ORInt i=0;
   for(k=idb.min;k <= idb.max;k++)
      if (t[k] != nil)
         xp[i++] = t[k];
   t += idb.min;
   free(t);
   return xp;
}

id<LSIntVar>* makeVar2ViewMap(id<LSIntVarArray> x,id<LSIntVarArray> views,
                              NSArray**  asv,ORInt sz,ORBounds* b)
{
   *b = idRange(x,(ORBounds){FDMAXINT,0});
   id<LSIntVar>* map = malloc(sizeof(id<LSIntVar>)*(b->max - b->min + 1));
   map -= b->min;
   ORInt vlow = views.low;
   for(ORInt j=0;j<sz;++j)
      for(id<LSIntVar> s in asv[j])
         map[getId(s)] = views[j+vlow]; // each source var is mapped to the view that uses it.
#if !defined(_NDEBUG)
   for(id<LSIntVar> xk in x)
      assert(map[getId(xk)]!=nil);
#endif
   return map;
}
