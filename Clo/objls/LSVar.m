/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2014 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <objls/LSVar.h>
#import "LSPropagator.h"
#import "LSFactory.h"
#import "LSCount.h"
#import "LSIntVar.h"

@interface LSVarGradient : LSGradient<LSGradient> {
   id<LSIntVar>   _x;
}
-(ORBool)isConstant;
-(ORBool)isVar;
-(ORBool)isLinear;
-(ORInt)constant;
-(id<LSIntVar>)variable;
@end

@interface LSCstGradient : LSGradient<LSGradient> {
   int  _cst;
}
-(ORBool)isConstant;
-(ORBool)isVar;
-(ORBool)isLinear;
-(ORInt)constant;
-(id<LSIntVar>)variable;
@end

@interface LSLinGradient : LSGradient<LSGradient> {
   NSMutableArray* _terms;
   id<LSIntVar>    _final;
   ORInt               _b;
}
-(ORBool)isConstant;
-(ORBool)isVar;
-(ORBool)isLinear;
-(ORInt)constant;
-(id<LSIntVar>)variable;
@end

@interface LSLinTerm : NSObject {
   id<LSIntVar> _x;
   ORInt        _a;
}
-(id)init:(id<LSIntVar>)x coef:(ORInt)a;
-(void)updateCoefFor:(id<LSIntVar>)x coef:(ORInt)c;
-(ORInt)coef;
-(id<LSIntVar>)variable;
@end

@implementation LSLinTerm
-(id)init:(id<LSIntVar>)x coef:(ORInt)a
{
   self = [super init];
   _x = x;
   _a = a;
   return self;
}
-(void)updateCoefFor:(id<LSIntVar>)x coef:(ORInt)c
{
   if (getId(x) == getId(_x))
      _a += c;
}
-(ORInt)coef
{
   return _a;
}
-(id<LSIntVar>)variable
{
   return _x;
}
@end

@implementation LSLinGradient
-(id)init
{
   self = [super init];
   _terms = [[NSMutableArray alloc] initWithCapacity:2];
   _final = nil;
   _b     = 0;
   return self;
}
-(void)dealloc
{
   [_terms release];
   [super dealloc];
}
-(ORBool)isConstant
{
   return NO;
}
-(ORBool)isVar
{
   return NO;
}
-(ORBool)isLinear
{
   return YES;
}
-(ORInt)constant
{
   return 0;
}
-(id<LSIntVar>)variable
{
   return _final;
}
-(id<LSIntVar>)intVar:(id<LSEngine>)engine
{
   ORInt min=FDMAXINT,max=FDMININT;
   for(LSLinTerm* t in _terms) {
      min = MIN([t coef], min);
      max = MAX([t coef],max);
   }
   _final = [LSFactory intVar:engine domain:RANGE(engine,min,max)];
   ORInt cnt = (ORInt)[_terms count];
   id<ORIntRange> R = RANGE(engine,0,cnt-1);
   id<ORIntArray> coefs = [ORFactory intArray:engine range:R with:^ORInt(ORInt i) {
      return [(LSLinTerm*)_terms[i] coef];
   }];
   id<LSIntVarArray> vars = [LSFactory intVarArray:engine range:R with:^id<LSIntVar>(ORInt i) {
      return [(LSLinTerm*)_terms[i] variable];
   }];
   [engine add:[LSFactory sum:_final is:coefs times:vars]];
   assert(_b == 0);
   return _final;
}
-(id<LSGradient>)addConst:(ORInt)c
{
   _b += c;
   return self;
}
-(id<LSGradient>)addTerm:(id<LSIntVar>)x coef:(ORInt)a
{
   ORInt xid = getId(x);
   for(LSLinTerm* t in _terms) {
      if (getId([t variable]) == xid) {
         [t updateCoefFor:x coef:a];
         return self;
      }
   }
   [_terms addObject:[[LSLinTerm alloc] init:x coef:a]];
   return self;
}
-(id<LSGradient>)addLinear:(LSLinGradient*)g
{
   // [ldm] quadratic. Must improve.
   _b += g->_b;
   for(LSLinTerm* t in g->_terms)
      [self addTerm:[t variable] coef:[t coef]];
   return self;
}
-(NSString*)description
{
   return [[[NSString alloc] initWithFormat:@"<LinGradient: %p (%lu) %@>",self,[_terms count],_final] autorelease];
}
@end

@implementation LSVarGradient
-(id)init:(id<LSIntVar>)x
{
   self = [super init];
   _x = x;
   return self;
}
-(ORBool)isConstant
{
   return NO;
}
-(ORBool)isVar
{
   return YES;
}
-(ORBool)isLinear
{
   return NO;
}
-(ORInt)constant
{
   return 0;
}
-(id<LSIntVar>)variable
{
   return _x;
}
-(id<LSIntVar>)intVar:(id<LSEngine>)engine
{
   return _x;
}
-(id<LSGradient>)addConst:(ORInt)c
{
   return [[[LSGradient linGradient] addTerm:_x coef:1] addConst:c];
}
-(id<LSGradient>)addTerm:(id<LSIntVar>)x coef:(ORInt)a
{
   return [[[LSGradient linGradient] addTerm:_x coef:1] addTerm:x coef:a];
}
-(id<LSGradient>)addLinear:(LSLinGradient*)g
{
   return [g addTerm:_x coef:1];
}
-(NSString*)description
{
   return [[[NSString alloc] initWithFormat:@"<VarGradient: %p : %@>",self,_x] autorelease];
}
@end

@implementation LSCstGradient
-(id)init:(ORInt)c
{
   self = [super init];
   _cst = c;
   return self;
}
-(ORBool)isConstant
{
   return YES;
}
-(ORBool)isVar
{
   return NO;
}
-(ORBool)isLinear
{
   return NO;
}
-(ORInt)constant
{
   return _cst;
}
-(id<LSIntVar>)variable
{
   return nil;
}
-(id<LSIntVar>)intVar:(id<LSEngine>)engine
{
   return [LSFactory intVar:engine domain:RANGE(engine,_cst,_cst)];
}
-(id<LSGradient>)addConst:(ORInt)c
{
   _cst += c;
   return self;
}
-(id<LSGradient>)addTerm:(id<LSIntVar>)x coef:(ORInt)a
{
   return [[[LSGradient linGradient] addConst:_cst] addTerm:x coef:a];
}
-(id<LSGradient>)addLinear:(LSLinGradient*)g
{
   return [g addConst:_cst];
}
-(NSString*)description
{
   return [[[NSString alloc] initWithFormat:@"<CstGradient: %p : %d>",self,_cst] autorelease];
}
@end

@implementation LSGradient
+(LSGradient*)varGradient:(id<LSIntVar>)x
{
   return [[LSVarGradient alloc] init:x];
}
+(LSGradient*)cstGradient:(ORInt)c
{
   return [[LSCstGradient alloc] init:c];
}
+(LSGradient*)linGradient
{
   return [[LSLinGradient alloc] init];
}

+(id<LSGradient>)maxOf:(id<LSGradient>)g1 and:(id<LSGradient>)g2
{
   if ([g1 isConstant] && [g2 isConstant])
      return [LSGradient cstGradient:max([g1 constant],[g2 constant])];
   else if ([g1 isConstant]) {
      id<LSIntVar> v = [g2 variable];
      id<ORIntRange> d = v.domain;
      ORInt g1c = [g1 constant];
      if (g1c >= d.up)
         return g1;
      else if (g1c <= d.low)
         return g2;
      else {
         id<LSIntVar> ng = [LSFactory intVarView:[v engine] domain:d fun:^ORInt{
            return max(getLSIntValue(v),g1c);
         } src:@[v]];
         return [LSGradient varGradient:ng];
      }
   } else if ([g2 isConstant]) {
      return [self maxOf:g2 and:g1];
   } else {
      id<LSIntVar> v1 = [g1 variable];
      id<LSIntVar> v2 = [g2 variable];
      id<LSEngine> e = [v1 engine];
      id<LSIntVar> rv = [LSFactory intVar:e domain:v1.domain];
      [e add:[LSFactory inv:rv equal:^ORInt{
         return max(getLSIntValue(v1),getLSIntValue(v2));
      } vars:@[v1,v2]]];
      return [LSGradient varGradient:rv];
   }
}
+(id<LSGradient>)sumOf:(id<LSGradient>)g1 and:(id<LSGradient>)g2
{
   if ([g2 isConstant])
      return [g1 addConst:g2.constant];
   else if ([g2 isVar])
      return [g1 addTerm:g2.variable coef:1];
   else
      return [g1 addLinear:g2];
}
@end

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
      else
         asv[k] = @[xk];
      assert([asv[k] count] <= 1);
      ++k;
   }
}
int varComparator(const ORObject** a, const ORObject** b) {
   return getId(*a) - getId(*b);
}
id<LSIntVarArray> sortById(id<LSIntVarArray> array)
{
   id* b = (id*)[(id)array base];
   qsort(b, [array count], sizeof(id),(int(*)(const void*,const void*))&varComparator );
   return array;
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
