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
#import "CPSolverI.h"

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
-(void)cloneInto:(KSColumn*)into dense:(BOOL**)f support:(id<CPTRIntMatrix>)support;
-(void)  addInto:(KSColumn*)into dense:(BOOL**)f support:(id<CPTRIntMatrix>)support addWeight:(CPInt)w bound:(CPInt)U;
-(void)pullNode:(KSNode*)node;
-(void)pullValue:(CPInt)v knapsack:(CPKnapsack*)ks;
-(void)lostCapacity:(CPInt)v knapsack:(CPKnapsack*)ks;
-(NSString*)description;
-(void)pruneCapacity:(CPIntVarI*)capVar;
@end

typedef struct CPKSPair {
   BOOL unreachable;
   KSNode*     pred;
} CPKSPair;

static void forwardPropagateLoss(CPKnapsack* ks,KSNode* n,KSColumn* col);
static void backwardPropagateLoss(CPKnapsack* ks,KSNode* n);

@implementation CPKnapsack {
   id<CPSolver>          _fdm;
   id<CPTRIntMatrix> _support;
   CPLong                 _nb;
   CPInt                 _low;
   CPInt                  _up;
   KSColumn**         _column;
}

-(id) initCPKnapsackDC:(id<CPIntVarArray>)x weights:(id<CPIntArray>)w capacity:(CPIntVarI*)cap
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
   [super dealloc];
}
-(CPStatus)post
{
   _nb  = [_x count];
   _low = [_x low];
   _up  = [_x up];
   _support = [CPFactory TRIntMatrix:(id<CP>)_fdm range:RANGE(_low,_up) :RANGE(0,1)]; // ugly cast.
   [self makeSparse: [self denseMatrices]];  // after this, supports will be initialized.
   for(CPInt i = _low;i <= _up;i++)
      for(CPInt v=0;v <= 1;v++)
         if ([_support at:i :v]==0)
            [(CPIntVarI*)(_x[i]) remove:v];
   [_column[_up] pruneCapacity:_c];
   for(CPInt i = _low;i <= _up;i++) {
      CPIntVarI* xi = (CPIntVarI*)(_x[i]);
      if (!bound(xi)) {
         [xi whenLoseValue:self do:^(CPInt v) {
            [_column[i] pullValue:v knapsack:self];
         }];
      }
   }
   [_c whenLoseValue:self do:^(CPInt v) {
      [_column[_up] lostCapacity:v knapsack:self];
   }];
   return CPSuspend;
}
static void outboundLossOn(CPKnapsack* ks,KSNode* n,CPInt v)
{
   CPInt colID = n->_col + 1;
   CPInt ns = [ks->_support add: -1 at:colID :v];
   CPIntVarI* xi = (CPIntVarI*)ks->_x[colID];
   if (ns==0)
      [xi remove:v];
   assignTRIdNC(&n->_succ[v],nil,ks->_trail);
   if (n->_succ[!v]._val == nil)
      backwardPropagateLoss(ks,n);
}
static void inboundLossOn(CPKnapsack* ks,KSNode* n,CPInt v)
{
   CPInt ns = [ks->_support add: -1 at:n->_col :v];
   CPIntVarI* xi = (CPIntVarI*)ks->_x[n->_col];
   if (ns==0)
      [xi remove:v];
   assignTRIdNC(&n->_pred[v],nil,ks->_trail);
   if (n->_pred[!v]._val ==nil)
      forwardPropagateLoss(ks,n,ks->_column[n->_col]);
}
static void forwardPropagateLoss(CPKnapsack* ks,KSNode* n,KSColumn* col)
{
   [col pullNode:n];
   if (col->_col == ks->_up)
      [ks->_c remove:[n weight]];
   KSNode* succ[2] = { n->_succ[0]._val,n->_succ[1]._val};
   for(CPInt k=0;k<=1;k++)
      if (succ[k])
         inboundLossOn(ks,succ[k],k);
}
static void backwardPropagateLoss(CPKnapsack* ks,KSNode* n)
{
   KSColumn* col = ks->_column[n->_col];
   [col pullNode:n];
   KSNode* pred[2] = {n->_pred[0]._val,n->_pred[1]._val};
   for(CPInt k=0;k<=1;k++)
      if (pred[k])
         outboundLossOn(ks,pred[k],k);
}
-(BOOL**)denseMatrices
{
   CPInt low = [_x low],up = [_x up];
   CPInt L = [_c min],U = [_c max];
   BOOL** f = malloc(sizeof(BOOL*)*(_nb+1)); // allocate an extra column "in front" (reframing below)
   BOOL** g = malloc(sizeof(BOOL*)*(_nb+1)); // allocate an extra column "in front" (reframing below)
   for(CPInt k=0;k<_nb+1;k++) {
      f[k] = malloc(sizeof(BOOL)*(U+1));
      g[k] = malloc(sizeof(BOOL)*(U+1));
      memset(f[k],0,sizeof(BOOL)*(U+1));
      memset(g[k],0,sizeof(BOOL)*(U+1));
   }
   f -= (low - 1);  // make sure that column low-1 exist (seed column) via reframing.
   g -= (low - 1);  // make sure that column low-1 exist (seed column) via reframing.
   @try {
      f[low-1][0] = YES;
      for(CPInt i=low;i<=up;i++) {
         for(CPInt c=0;c<=U;c++) {
            if (f[i-1][c]) {
               CPInt xiMin = [_x[i] min],xiMax = [_x[i] max];
               for(CPInt d=xiMin;d <= xiMax;d++) {
                  if ([_x[i] member:d]) {
                     CPInt w = c + d * [_w at: i];
                     if (w <= U)
                        f[i][w] = YES;
                  }
               }
            }
         }
      }
      CPInt nbReached = 0;
      for(CPInt i=L;i <= U;i++)
         nbReached += f[up][i];
      if (nbReached==0)
         failNow();
      for(CPInt i=L;i <= U;i++)
         g[up][i] = YES;   // [ldm] Why aren't we skipping values _NOT_ in D(_c) ? 
      for(CPInt i = up - 1; i >= low; i--) {
         for(CPInt b = 0; b <= U; b++) {
            if (g[i+1][b]) {
               CPInt xMin = [_x[i+1] min],xMax = [_x[i+1] max];
               for(CPInt d = xMin; d <= xMax; d++) {
                  if ([_x[i+1] member:d]) {
                     CPInt w = b - d * [_w at:i+1];
                     if (w >= 0)
                        g[i][w] = YES;
                  }
               }
            }
         }
      }
      for(CPInt i = low; i <= up; i++)
         for(CPInt b = 0; b <= U; b++)
            f[i][b] = f[i][b] && g[i][b];
      // We can now let go of G.
      g += (low - 1);
      for(CPInt k=0;k<_nb+1;k++)
         free(g[k]);
      free(g);
      // F[i][j] is true if it sits on a path from f[-1][0] to one of the F[up][L .. U]
      // with D(_c) = {L..U}
      return f;
   } @catch(CPFailException* x) {
      f += (low - 1);
      g += (low - 1);
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
   _column -= (_low - 1);
   for(CPInt i=_low-1; i <= _up;i++)
      _column[i] = [[KSColumn alloc] initKSColumn:i trail:_trail];
   [_column[_low-1] makeSource];
   
   for(CPInt i = _low;i <= _up;i++) {
      if ([_x[i] member: 0])
         [_column[i-1] cloneInto:_column[i] dense:f support:_support];
      if ([_x[i] member: 1])
         [_column[i-1] addInto:_column[i] dense:f support:_support addWeight:[_w at:i] bound:[_c max]];
   }
   
   // Wrap up with the deallocation of this f that we no longer need.
   f += (_low - 1);
   for(CPInt k=0;k<_nb+1;k++)
      free(f[k]);
   free(f);
}

-(NSSet*)allVars
{
   NSMutableSet* rv = [[NSMutableSet alloc] initWithCapacity:[_x count] + 1];
   for(CPInt i=[_x low];i<=[_x up];i++)
      [rv addObject:_x[i]];
   [rv addObject:_c];
   return rv;
}
-(CPUInt)nbUVars
{
   CPUInt nb = 0;
   for(CPInt i=[_x low];i<=[_x up];i++)
      nb += !bound((CPIntVarI*)_x[i]);
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
-(CPKSPair)looseValue:(CPInt)v
{
   KSNode* pv = _pred[v]._val;
   if (pv) {
      assignTRIdNC(&_pred[v],nil,_trail);
      return (CPKSPair){_pred[!v]._val == nil,pv};
   } else
      return (CPKSPair){NO,pv};
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
-(void)pullNode:(KSNode*)node
{
   KSNode* below = node->_down._val;
   KSNode* above = node->_up._val;
   if (_first._val == node) {
      assert(below == nil);
      assignTRIdNC(&_first,above,_trail);
   } else {
      assert(below != nil);
      assignTRIdNC(&below->_up,above,_trail);
   }
   if (_last._val == node) {
      assert(above == nil);
      assignTRIdNC(&_last,below,_trail);
   } else {
      assert(above != nil);
      assignTRIdNC(&above->_down,below,_trail);
   }
}
-(void)pullValue:(CPInt)v knapsack:(CPKnapsack*)ks
{
   KSNode* cur = _first._val;
   while (cur) {
      KSNode* next = cur->_up._val;
      CPKSPair status = [cur looseValue:v];
      if (status.unreachable) {
         forwardPropagateLoss(ks,cur,self);
         outboundLossOn(ks,status.pred,v);
      }
      else if (status.pred)
         assignTRIdNC(&status.pred->_succ[v],nil,_trail);
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
-(void)cloneInto:(KSColumn*)into dense:(BOOL**)f support:(id<CPTRIntMatrix>)support
{
   CPInt idx = into->_col;
   KSNode* src = _first._val;
   while(src) {
      if (f[idx][src->_w]) {
         [support set:[support at:idx :0]+1 at:idx :0];
         KSNode* new = [[KSNode alloc] initKSNode:idx weight:src->_w trail:_trail];
         [src setSucc:0 as:new];
         [into pushOnColumn:new];
      }
      src = src->_up._val;
   }
}
-(void)addInto:(KSColumn*)into dense:(BOOL**)f support:(id<CPTRIntMatrix>)support addWeight:(CPInt)w bound:(CPInt)U
{
   KSNode* dst = into->_first._val;
   KSNode* src = _first._val;
   CPInt   idx = into->_col;
   while (src) {
      CPInt fw = src->_w + w;
      if (fw <= U && f[idx][fw]) {
         [support set:[support at:idx :1]+1 at:idx :1];
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