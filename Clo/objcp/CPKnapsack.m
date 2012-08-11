/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "CPKnapsack.h"
#import "CPIntVarI.h"
#import "CPArray.h"
#import "CPEngineI.h"

@interface KSNode : NSObject {
   @package
   CPInt      _col;  // column identifier
   CPInt        _w;  // total weight of node
   TRIdNC      _up;  // "vertical" up link
   TRIdNC    _down;  // "vertical" down link
   TRIdNC _succ[2];  // "successors" for {0,1}
   TRIdNC _pred[2];  // "predecessors" for {0,1}
   ORTrail* _trail;
}
-(KSNode*)initKSNode:(CPInt)cid weight:(CPInt)w trail:(ORTrail*)trail;
-(void)dealloc;
-(void)setSucc:(CPInt)v as:(KSNode*)n;
-(void)pushKSNode:(KSNode*)top;
-(CPInt)weight;
@end

@interface KSColumn : NSObject {
   @package
   CPInt      _col;
   TRIdNC   _first;
   TRIdNC    _last;
   ORTrail* _trail;
}
-(KSColumn*)initKSColumn:(CPInt)cid trail:(ORTrail*)trail;
-(void)makeSource;
-(void)pushOnColumn:(KSNode*)c;
-(void)insert:(KSNode*)n below:(KSNode*)spot;
-(void)cloneInto:(KSColumn*)into dense:(BOOL**)f support:(TRInt*)support  nbCol:(CPInt)nb;
-(void)  addInto:(KSColumn*)into dense:(BOOL**)f support:(TRInt*)support  nbCol:(CPInt)nb addWeight:(CPInt)w bound:(CPInt)U;
-(void)lostCapacity:(CPInt)v knapsack:(CPKnapsack*)ks;
-(NSString*)description;
-(void)pruneCapacity:(CPIntVarI*)capVar;
@end

typedef struct CPKSPair {
   BOOL     changed;
   KSNode*     pred;
} CPKSPair;

static void forwardPropagateLoss(CPKnapsack* ks,KSNode* n,KSColumn* col);
static void backwardPropagateLoss(CPKnapsack* ks,KSNode* n);
static inline void pullValue(KSColumn* k,CPInt v,CPKnapsack* ks);

static inline void pullNode(KSColumn* col,KSNode* node)
{
   KSNode* below = node->_down._val;
   KSNode* above = node->_up._val;
   ORTrail* trail = col->_trail;
   if (col->_first._val == node) {
      assert(below == nil);
      assignTRIdNC(&col->_first,above,trail);
   } else {
      assert(below != nil);
      assignTRIdNC(&below->_up,above,trail);
   }
   if (col->_last._val == node) {
      assert(above == nil);
      assignTRIdNC(&col->_last,below,trail);
   } else {
      assert(above != nil);
      assignTRIdNC(&above->_down,below,trail);
   }
}

@implementation CPKnapsack {
   id<CPEngine>          _fdm;
   CPIntVarI**            _xb;
   TRInt*            _support;
   CPLong                 _nb;
   CPInt                 _low;
   CPInt                  _up;
   KSColumn**         _column;
}

#define SUPP(r,c) ((r)*2 + (c))

-(id) initCPKnapsackDC:(id<ORIntVarArray>)x weights:(id<CPIntArray>)w capacity:(CPIntVarI*)cap
{
   self = [super initCPActiveConstraint:[[x cp] solver]];
   _priority = HIGHEST_PRIO - 2;
   _fdm = [[x cp] solver];
   _x = x;
   _w = w;
   _c = cap;
   _column = NULL;
   return self;
}
-(void) dealloc
{
   _column += (_low - 1);
   for(CPInt k=0;k<_nb+1;k++)
      [_column[k] release];
   free(_column);
   free(_xb);
   [super dealloc];
}
-(ORStatus)post
{
   _nb  = [_x count];
   _low = [_x low];
   _up  = [_x up];
   _xb  = malloc(sizeof(CPIntVarI*)*_nb);
   for(CPInt k=_low;k<= _up;k++)
      _xb[k - _low] = (CPIntVarI*)_x[k];
   _support = malloc(sizeof(TRInt)*_nb*2);
   for(CPInt k=0;k<_nb*2;k++)
      _support[k] = makeTRInt(_trail, 0);
   [self makeSparse: [self denseMatrices]];  // after this, supports will be initialized.
   for(CPInt i = 0;i < _nb;i++)
      for(CPInt v=0;v <= 1;v++)
         if (_support[SUPP(i,v)]._val ==0)
            removeDom(_xb[i],v);
   [_column[_nb-1] pruneCapacity:_c];
   for(CPInt i = 0;i < _nb;i++) {
      if (!bound(_xb[i])) {
         [_xb[i] whenLoseValue:self do:^(CPInt v) {
            pullValue(_column[i],v,self);
         }];
      }
   }
   [_c whenLoseValue:self do:^(CPInt v) {
      [_column[_nb-1] lostCapacity:v knapsack:self];
   }];
   return ORSuspend;
}
static inline void outboundLossOn(CPKnapsack* ks,KSNode* n,CPInt v)
{
   CPInt colID = n->_col + 1;
   CPInt ofs = SUPP(colID,v);
   CPInt ns  = ks->_support[ofs]._val - 1;
   assignTRInt(ks->_support + ofs,ns,ks->_trail);
   if (ns==0)
      removeDom(ks->_xb[colID], v);
   assignTRIdNC(&n->_succ[v],nil,ks->_trail);
   if (n->_succ[!v]._val == nil)
      backwardPropagateLoss(ks,n);
}
static inline void inboundLossOn(CPKnapsack* ks,KSNode* n,CPInt v)
{
   CPInt ofs = SUPP(n->_col,v);
   CPInt ns  = ks->_support[ofs]._val - 1;
   assignTRInt(ks->_support + ofs,ns,ks->_trail);
   if (ns==0)
      removeDom(ks->_xb[n->_col],v);
   assignTRIdNC(&n->_pred[v],nil,ks->_trail);
   if (n->_pred[!v]._val ==nil)
      forwardPropagateLoss(ks,n,ks->_column[n->_col]);
}
static inline void forwardPropagateLoss(CPKnapsack* ks,KSNode* n,KSColumn* col)
{
   pullNode(col,n);
   if (col->_col == ks->_nb-1)
      removeDom(ks->_c,n->_w);
   KSNode* succ[2] = { n->_succ[0]._val,n->_succ[1]._val};
   if (succ[0]) inboundLossOn(ks,succ[0],0);
   if (succ[1]) inboundLossOn(ks,succ[1],1);
}
static inline void backwardPropagateLoss(CPKnapsack* ks,KSNode* n)
{
   KSColumn* col = ks->_column[n->_col];
   pullNode(col,n);
   KSNode* pred[2] = {n->_pred[0]._val,n->_pred[1]._val};
   if (pred[0]) outboundLossOn(ks,pred[0],0);
   if (pred[1]) outboundLossOn(ks,pred[1],1);
}
-(BOOL**)denseMatrices
{
   CPInt L = [_c min],U = [_c max];
   BOOL** f = malloc(sizeof(BOOL*)*(_nb+1)); // allocate an extra column "in front" (reframing below)
   BOOL** g = malloc(sizeof(BOOL*)*(_nb+1)); // allocate an extra column "in front" (reframing below)
   for(CPInt k=0;k<_nb+1;k++) {
      f[k] = malloc(sizeof(BOOL)*(U+1));
      g[k] = malloc(sizeof(BOOL)*(U+1));
      memset(f[k],0,sizeof(BOOL)*(U+1));
      memset(g[k],0,sizeof(BOOL)*(U+1));
   }
   f += 1;  // make sure that column -1 exist (seed column) via reframing.
   g += 1;  // make sure that column -1 exist (seed column) via reframing.
   @try {
      f[-1][0] = YES;
      for(CPInt i=0;i< _nb;i++) {
         for(CPInt c=0;c<=U;c++) {
            if (f[i-1][c]) {
               CPInt xiMin = [_xb[i] min],xiMax = [_xb[i] max];
               for(CPInt d=xiMin;d <= xiMax;d++) {
                  if ([_xb[i] member:d]) {
                     CPInt w = c + d * [_w at: i + _low];
                     if (w <= U)
                        f[i][w] = YES;
                  }
               }
            }
         }
      }
      CPInt nbReached = 0;
      for(CPInt i=L;i <= U;i++)
         nbReached += f[_nb-1][i];
      if (nbReached==0)
         failNow();
      for(CPInt i=L;i <= U;i++)
         if ([_c member:i])
            g[_nb-1][i] = YES;   // [ldm] Why aren't we skipping values _NOT_ in D(_c) ?
         else g[_nb-1][i] = NO;
      for(CPInt i = (CPInt)_nb - 2; i >= 0; i--) {
         for(CPInt b = 0; b <= U; b++) {
            if (g[i+1][b]) {
               CPInt xMin = [_xb[i+1] min],xMax = [_xb[i+1] max];
               for(CPInt d = xMin; d <= xMax; d++) {
                  if ([_xb[i+1] member:d]) {
                     CPInt w = b - d * [_w at:i+1 + _low];
                     if (w >= 0)
                        g[i][w] = YES;
                  }
               }
            }
         }
      }
      for(CPInt i = 0; i < _nb; i++)
         for(CPInt b = 0; b <= U; b++)
            f[i][b] = f[i][b] && g[i][b];
      // We can now let go of G.
      g -= 1;
      for(CPInt k=0;k<_nb+1;k++)
         free(g[k]);
      free(g);
      // F[i][j] is true if it sits on a path from f[-1][0] to one of the F[up][L .. U]
      // with D(_c) = {L..U}
      return f;
   } @catch(CPFailException* x) {
      f -= 1;
      g -= 1;
      for(CPInt k=0;k<_nb+1;k++) {
         free(f[k]);
         free(g[k]);
      }
      free(f);
      free(g);
      @throw;
   }
}
-(void)makeSparse:(BOOL**)f
{
   _column  = malloc(sizeof(KSColumn*)*(_nb+1));
   _column += 1;
   for(CPInt i=-1; i < _nb;i++)
      _column[i] = [[KSColumn alloc] initKSColumn:i trail:_trail];
   [_column[-1] makeSource];
   
   for(CPInt i = 0;i < _nb;i++) {
      if ([_xb[i] member: 0])
         [_column[i-1] cloneInto:_column[i] dense:f support:_support nbCol:(CPInt)_nb];
      if ([_xb[i] member: 1])
         [_column[i-1] addInto:_column[i] dense:f support:_support nbCol:(CPInt)_nb addWeight:[_w at:i + _low] bound:[_c max]];
   }
   // Wrap up with the deallocation of this f that we no longer need.
   f -= 1;
   for(CPInt k=0;k<_nb+1;k++)
      free(f[k]);
   free(f);
}

-(NSSet*)allVars
{
   NSMutableSet* rv = [[NSMutableSet alloc] initWithCapacity:_nb + 1];
   for(CPInt i=0;i< _nb;i++)
      [rv addObject:_xb[i]];
   [rv addObject:_c];
   return rv;
}
-(CPUInt)nbUVars
{
   CPUInt nb = 0;
   for(CPInt i=0;i< _nb;i++)
      nb += !bound(_xb[i]);
   nb += !bound(_c);
   return nb;
}
-(NSString*)description
{
   return [NSMutableString stringWithFormat:@"<CPKnapsackDC: %02d (%@ * %@ IN %@)>",_name,_x,_w,_c];
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
   [super encodeWithCoder:aCoder];
   [aCoder encodeObject:_x];
   [aCoder encodeObject:_w];
   [aCoder encodeObject:_c];
}
- (id)initWithCoder:(NSCoder *)aDecoder;
{
   self = [super initWithCoder:aDecoder];
   _x = [aDecoder decodeObject];
   _w = [aDecoder decodeObject];
   _c = [aDecoder decodeObject];   
   return self;
}
@end

@implementation KSNode
-(KSNode*)initKSNode:(CPInt)cid weight:(CPInt)w trail:(ORTrail*)trail
{
   self = [super init];
   _col = cid;
   _w   = w;
   _trail = trail;
   _up   = makeTRIdNC(trail, nil);
   _down = makeTRIdNC(trail, nil);
   _succ[0] = _succ[1] = makeTRIdNC(trail,nil);
   _pred[0] = _pred[1] = makeTRIdNC(trail,nil);
   [_trail trailRelease:self];
   return self;
}
-(void)dealloc
{
   [super dealloc];
}
-(CPInt)weight
{
   return _w;
}
-(void)setSucc:(CPInt)v as:(KSNode*)n
{
   assignTRIdNC(&_succ[v],n,_trail);
   assignTRIdNC(&n->_pred[v],self,_trail);
}
-(void)pushKSNode:(KSNode*)top
{
   assignTRIdNC(&top->_down,self,_trail);
   assignTRIdNC(&_up,top,_trail);
}
-(KSNode*)findSpot:(CPInt)w
{
   KSNode* cur = self;
   while (cur && cur->_w < w)
      cur = cur->_up._val;
   return cur;
}
static inline CPKSPair looseValue(KSNode* n,CPInt v)
{
   KSNode* pv = n->_pred[v]._val;
   if (pv) {
      assignTRIdNC(&n->_pred[v],nil,n->_trail);
      assignTRIdNC(&pv->_succ[v],nil,n->_trail);
      return (CPKSPair){YES,pv};
   } else
      return (CPKSPair){NO,pv};
}
static inline BOOL unreachableFromRight(KSNode* n)
{
   return n->_succ[0]._val == nil && n->_succ[1]._val == nil;
}
-(NSString*)description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%p,%d,%d,p:[%p,%p],s:[%p,%p]>",self,_col,_w,_pred[0]._val,_pred[1]._val,_succ[0]._val,_succ[1]._val];
   return buf;
}
@end

@implementation KSColumn
-(KSColumn*)initKSColumn:(CPInt)cid trail:(ORTrail*)trail
{
   self = [super init];
   _trail = trail;
   _col   = cid;
   _first = _last = makeTRIdNC(_trail, nil);
   return self;
}
-(void)makeSource
{
   KSNode* source = [[KSNode alloc] initKSNode:_col weight:0 trail:_trail];
   assignTRIdNC(&_first,source,_trail);
   assignTRIdNC(&_last,source,_trail);
}
-(void)pushOnColumn:(KSNode*)c
{
   if (_first._val == nil) {            // we do not have a content yet. Create one with c.
      assignTRIdNC(&_first,c,_trail);
      assignTRIdNC(&_last,c,_trail);
   } else {                             // we do have a column. Add on top.
      [_last._val pushKSNode:c];
      assignTRIdNC(&_last,c,_trail);
   }
}
-(void)insert:(KSNode*)n below:(KSNode*)spot
{
   KSNode* below = spot->_down._val;
   assert(below != nil);
   assignTRIdNC(&n->_up, spot, _trail);
   assignTRIdNC(&n->_down,below,_trail);
   assignTRIdNC(&below->_up,n,_trail);
   assignTRIdNC(&spot->_down,n,_trail);
}

static inline void pullValue(KSColumn* k,CPInt v,CPKnapsack* ks)
{
   KSNode* cur = k->_first._val;
   while (cur) {
      KSNode* next = cur->_up._val;
      CPKSPair status = looseValue(cur,v);
      if (status.changed) {
         inboundLossOn(ks, cur, v);
         if (unreachableFromRight(status.pred))
            backwardPropagateLoss(ks, status.pred);
      }
      cur = next;
   }
}
-(void)lostCapacity:(CPInt)v knapsack:(CPKnapsack*)ks
{
   KSNode* cur = _first._val;
   while (cur) {
      if (cur->_w == v) {     // we found a sparse node. This guy is a goner.
         backwardPropagateLoss(ks,cur);
      } else if (cur->_w > v) // we didn't even have a sparse node for v. stop.
         return;
      cur = cur->_up._val;
   }
}
-(void)pruneCapacity:(CPIntVarI*)capVar
{
   KSNode* cur = _first._val;
   for (CPInt v=[capVar min]; v<= [capVar max];++v) {
      while (cur && cur->_w < v)
         cur = cur->_up._val;
      if (cur && cur->_w == v) continue;
      assert(!cur || v < cur->_w);
      [capVar remove:v];
   }
}
-(void)cloneInto:(KSColumn*)into dense:(BOOL**)f support:(TRInt*)support nbCol:(CPInt)nb
{
   CPInt idx = into->_col;
   KSNode* src = _first._val;
   while(src) {
      if (f[idx][src->_w]) {
         CPInt ofs = SUPP(idx,0);
         CPInt ns  = support[ofs]._val + 1;
         assignTRInt(support + ofs, ns, _trail);
         KSNode* new = [[KSNode alloc] initKSNode:idx weight:src->_w trail:_trail];
         [src setSucc:0 as:new];
         [into pushOnColumn:new];
      }
      src = src->_up._val;
   }
}
-(void)addInto:(KSColumn*)into dense:(BOOL**)f support:(TRInt*)support nbCol:(CPInt)nb addWeight:(CPInt)w bound:(CPInt)U
{
   KSNode* dst = into->_first._val;
   KSNode* src = _first._val;
   CPInt   idx = into->_col;
   while (src) {
      CPInt fw = src->_w + w;
      if (fw <= U && f[idx][fw]) {
         CPInt ofs = SUPP(idx,1);
         CPInt ns  = support[ofs]._val + 1;
         assignTRInt(support + ofs,ns,_trail);
         KSNode* at = [dst findSpot:fw];
         if (at) {
            if (at->_w == fw)
               [src setSucc:1 as:at];
            else {
               assert(at->_w > fw);
               KSNode* new = [[KSNode alloc] initKSNode:idx weight:fw trail:_trail];
               [into insert:new below:at];
               [src setSucc:1 as:new];
               dst = at;
            }
         } else {
            KSNode* new = [[KSNode alloc] initKSNode:idx weight:fw trail:_trail];
            [src setSucc:1 as:new];
            [into pushOnColumn:new];
            dst = new;
         }
      }
      src = src->_up._val;
   }
}
-(NSString*)description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   KSNode* cur = _first._val;
   [buf appendFormat:@"COL: %d [",_col];
   while (cur) {
      KSNode* next = cur->_up._val;
      [buf appendFormat:@" %@ %c",[cur description],next==nil ? ' ' : ','];
      cur = next;
   }
   [buf appendFormat:@"]"];
   return buf;
}
@end