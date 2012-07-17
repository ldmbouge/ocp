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
   TRId        _up;  // "vertical" up link
   TRId      _down;  // "vertical" down link
   TRId   _succ[2];  // "successors" for {0,1}
   TRId   _pred[2];  // "predecessors" for {0,1}
   ORTrail* _trail;
}
-(KSNode*)initKSNode:(CPInt)cid weight:(CPInt)w trail:(ORTrail*)trail;
-(void)dealloc;
-(void)setSucc:(CPInt)v as:(KSNode*)n;
-(void)pushKSNode:(KSNode*)top;
@end

@interface KSColumn : NSObject {
   @package
   CPInt      _col;
   TRId     _first;
   TRId      _last;
   ORTrail* _trail;
}
-(KSColumn*)initKSColumn:(CPInt)cid trail:(ORTrail*)trail;
-(void)makeSource;
-(void)pushOnColumn:(KSNode*)c;
-(void)insert:(KSNode*)n below:(KSNode*)spot;
-(void)cloneInto:(KSColumn*)into dense:(BOOL**)f support:(id<CPTRIntMatrix>)support;
-(void)  addInto:(KSColumn*)into dense:(BOOL**)f support:(id<CPTRIntMatrix>)support addWeight:(CPInt)w bound:(CPInt)U;
@end

@implementation KSNode
-(KSNode*)initKSNode:(CPInt)cid weight:(CPInt)w trail:(ORTrail*)trail
{
   self = [super init];
   _col = cid;
   _w   = w;
   _trail = trail;
   _up   = makeTRId(trail, nil);
   _down = makeTRId(trail, nil);
   _succ[0] = _succ[1] = makeTRId(trail,nil);
   _pred[0] = _pred[1] = makeTRId(trail,nil);
   [_trail trailRelease:self];
   return self;
}
-(void)dealloc
{
   [super dealloc];
}
-(void)setSucc:(CPInt)v as:(KSNode*)n
{
   assignTRId(&_succ[0],n,_trail);
   assignTRId(&n->_pred[0],self,_trail);
}
-(void)pushKSNode:(KSNode*)top
{
   assignTRId(&top->_down,_up._val,_trail);
   assignTRId(&_up,top,_trail);
}
-(KSNode*)findSpot:(CPInt)w
{
   KSNode* cur = self;
   while (cur && cur->_w < w)
      cur = cur->_up._val;
   return cur;
}
@end

@implementation KSColumn
-(KSColumn*)initKSColumn:(CPInt)cid trail:(ORTrail*)trail
{
   self = [super init];
   _trail = trail;
   _col   = 0;
   _first = _last = makeTRId(_trail, nil);
   return self;
}
-(void)makeSource
{
   KSNode* source = [[KSNode alloc] initKSNode:_col weight:0 trail:_trail];
   assignTRId(&_first,source,_trail);
   assignTRId(&_last,source,_trail);
}
-(void)pushOnColumn:(KSNode*)c
{
   if (_first._val == nil) {            // we do not have a content yet. Create one with c.
      assignTRId(&_first,c,_trail);
      assignTRId(&_last,c,_trail);
   } else {                             // we do have a column. Add on top.
      [_last._val pushKSNode:c];
      assignTRId(&_last,c,_trail);
   }
}
-(void)insert:(KSNode*)n below:(KSNode*)spot
{
   KSNode* below = spot->_down._val;
   assignTRId(&n->_up, spot, _trail);
   assignTRId(&n->_down,below,_trail);
   assignTRId(&below->_up,n,_trail);
   assignTRId(&spot->_down,n,_trail);
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
@end

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
      
   return CPSuspend;
}

-(BOOL**)denseMatrices
{
   CPInt low = [_x low],up = [_x up];
   CPInt L = [_c min],U = [_c max];
   BOOL** f = malloc(sizeof(BOOL)*(_nb+1)); // allocate an extra column "in front" (reframing below)
   BOOL** g = malloc(sizeof(BOOL)*(_nb+1)); // allocate an extra column "in front" (reframing below)
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
