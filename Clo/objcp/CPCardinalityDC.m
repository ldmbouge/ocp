/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import "CPCardinalityDC.h"
#import "CPBasicConstraint.h"
#import "CPEngineI.h"
#import "CPIntVarI.h"
#import "CPError.h"

@implementation CPCardinalityDC
{
   id<CPIntVarArray> _x;
   id<ORIntArray>    _lb;
   id<ORIntArray>    _ub;
   
   CPIntVar**     _var;
   ORInt           _varSize;
   
   ORInt           _valMin;        // smallest value
   ORInt           _valMax;        // largest value
   ORInt           _valSize;       // number of values
   ORInt*          _low;           // _low[i] = lower bound on value i
   ORInt*          _up;            // _up[i]  = upper bound on value i
   
   ORInt*          _flow;           // the flow for a value
   ORInt           _nbAssigned;     // number of variable assigned
   
   ORInt*          _varMatch;       // the value of a variable
   ORInt*          _valFirstMatch;  // The first variable matched to a value
   ORInt*          _valNextMatch;   // The next variable matched to a value; indexed by variable id
   ORInt*          _valPrevMatch;   // The previous variable matched to a value; indexed by variable id
   
   ORULong         _magic;
   ORULong*        _varMagic;
   ORULong*        _valMagic;
   
   ORInt           _dfs;
   ORInt           _component;
   
   ORInt*          _varComponent;
   ORInt*          _varDfs;
   ORInt*          _varHigh;
   
   ORInt*          _valComponent;
   ORInt*          _valDfs;
   ORInt*          _valHigh;
   
   ORInt           _sinkComponent;
   ORInt           _sinkDfs;
   ORInt           _sinkHigh;
   
   ORInt*          _stack;
   ORInt*          _nodeType;
   ORInt           _top;
   
   BOOL            _posted;
}

static void SCC(CPCardinalityDC* card);

-(void) initInstanceVariables 
{
    _priority = HIGHEST_PRIO-2;
    _posted = false;
}

-(CPCardinalityDC*) initCPCardinalityDC: (id<CPIntVarArray>) x low: (id<ORIntArray>) lb up: (id<ORIntArray>) ub
{
   self = [super initCPCoreConstraint: [[x at:[x low]] engine]];
   _x = x;
   _lb = lb;
   _ub = ub;
   [self initInstanceVariables];
   return self;
}

-(void) dealloc
{
//    NSLog(@"CPCardinalityDC dealloc called ...");
    if (_posted) {
       
       free(_var);
       free(_varMatch);
       free(_valNextMatch);
       free(_valPrevMatch);
       free(_varComponent);
       free(_varDfs);
       free(_varHigh);
       
       _low += _valMin;
       _up += _valMin;
       _flow += _valMin;
       _valFirstMatch += _valMin;
       _valComponent += _valMin;
       _valDfs += _valMin;
       _valHigh += _valMin;
       
       free(_low);
       free(_up);
       free(_flow);
       free(_valFirstMatch);
       free(_valComponent);
       free(_valDfs);
       free(_valHigh);
       free(_stack);
       free(_nodeType);
       
    }
    [super dealloc];
}

-(void) allocate
{
   ORInt low, up;
   
   low = [_x low];
   _varSize = ([_x up] - low + 1);
   _var = malloc(_varSize * sizeof(CPIntVar*));
   for(ORInt i = 0; i < _varSize; i++)
      _var[i] = (CPIntVar*) [_x at: low + i];
   
   _valMin = min([_lb low],[_ub low]);
   _valMax = max([_lb up],[_ub up]);
   
   ORInt l = [_x low];
   ORInt u = [_x up];
   for(ORInt i = l; i <= u; i++) {
      id<CPIntVar> v = [_x at: i];
      ORInt lb = [v min];
      if (lb < _valMin)
         _valMin = lb;
      ORInt ub = [v max];
      if (ub > _valMax)
         _valMax = ub;
   }
   _valSize = _valMax - _valMin + 1;
   
   _low = malloc(_valSize * sizeof(ORInt));
   _up = malloc(_valSize * sizeof(ORInt));
   _low -= _valMin;
   _up -= _valMin;
   
   for(ORInt i = _valMin; i <= _valMax; i++) {
      _low[i] = 0;
      _up[i] = _varSize;
   }
   
   low = [_lb low];
   up = [_lb up];
   for(ORInt i = low; i <= up; i++)
      _low[i] = [_lb at: i];
   
   low = [_ub low];
   up = [_ub up];
   for(ORInt i = low; i <= up; i++)
      _up[i] = [_ub at: i];
   
   _varComponent = malloc(sizeof(ORInt)*_varSize);
   _varDfs = malloc(sizeof(ORInt)*_varSize);
   _varHigh = malloc(sizeof(ORInt)*_varSize);
   
   _valComponent = malloc(sizeof(ORInt)*_valSize);
   _valDfs = malloc(sizeof(ORInt)*_valSize);
   _valHigh = malloc(sizeof(ORInt)*_valSize);
   
   _valComponent -= _valMin;
   _valDfs -= _valMin;
   _valHigh -= _valMin;
   
   _stack = malloc(sizeof(ORInt)*(_varSize + _valSize + 1));
   _nodeType = malloc(sizeof(ORInt)*(_varSize + _valSize + 1));
}


static void unmatchVar(CPCardinalityDC* card,ORInt v)
{
   if (card->_varMatch[v] == MAXINT)
      return;
   ORInt w = card->_varMatch[v];
   card->_nbAssigned--;
   card->_flow[w]--;
   ORInt p = card->_valPrevMatch[v];
   ORInt n = card->_valNextMatch[v];
   card->_varMatch[v] = MAXINT;
   card->_valNextMatch[v] = MAXINT;
   card->_valPrevMatch[v] = MAXINT;
   if (p != MAXINT)
      card->_valNextMatch[p] = n;
   else
      card->_valFirstMatch[w] = n;
   if (n != MAXINT)
      card->_valPrevMatch[n] = p;
}

static void matchVar(CPCardinalityDC* card,ORInt v,ORInt w)
{
    card->_nbAssigned++;
    card->_flow[w]++;
    card->_varMatch[v] = w;
    ORInt cv = card->_valFirstMatch[w];
    card->_valFirstMatch[w] = v;
    card->_valNextMatch[v] = cv;
    card->_valPrevMatch[v] = MAXINT;
    if (cv != MAXINT)
        card->_valPrevMatch[cv] = v;
}

static void assign(CPCardinalityDC* card,ORInt v,ORInt w)
{
   unmatchVar(card,v);
   matchVar(card,v,w);
}

-(void) initializeFlow
{
   _magic = 0;
   
   _varMatch = malloc(_varSize * sizeof(ORInt));
   for(ORInt v = 0; v < _varSize; v++)
      _varMatch[v] = MAXINT;
   
   _valNextMatch = malloc(_varSize * sizeof(ORInt));
   for(ORInt v = 0; v < _varSize; v++)
      _valNextMatch[v] = MAXINT;
   
   _valPrevMatch = malloc(_varSize * sizeof(ORInt));
   for(ORInt v = 0; v < _varSize; v++)
      _valPrevMatch[v] = MAXINT;
   
   _varMagic = malloc(_varSize * sizeof(ORULong));
   for(ORInt v = 0; v < _varSize; v++)
      _varMagic[v] = 0;
   
   _flow = malloc(_valSize * sizeof(ORInt));
   _flow -= _valMin;
   for(ORInt w = _valMin; w <= _valMax; w++)
      _flow[w] = 0;
   
   _valFirstMatch = malloc(_valSize * sizeof(ORInt));
   _valFirstMatch -= _valMin;
   for(ORInt w = _valMin; w <= _valMax; w++)
      _valFirstMatch[w] = MAXINT;
   
   _valMagic = malloc(_valSize * sizeof(ORULong));
   _valMagic -= _valMin;
   for(ORInt w = _valMin; w <= _valMax; w++)
      _valMagic[w] = 0;
   
   _nbAssigned = 0;
   for(ORInt i = 0; i < _varSize; i++) {
      ORInt m = minDom(_var[i]);
      ORInt M = maxDom(_var[i]);
      for(ORInt v = m; v <= M; v++)
         if (_flow[v] < _up[v] && [_var[i] member: v]) {
            matchVar(self,i,v);
            break;
         }
   }
}

static BOOL augmentValPath(CPCardinalityDC* card,ORInt v);

static BOOL augmentVarPath(CPCardinalityDC* card,ORInt i)
{
    if (card->_varMagic[i] != card->_magic) {
        card->_varMagic[i] = card->_magic;
        ORBounds b = bounds(card->_var[i]);
        for(ORInt w = b.min; w <= b.max; w++)
            if (card->_varMatch[i] != w && memberDom(card->_var[i],w))
                if (augmentValPath(card,w)) {
                    assign(card,i,w);
                    return TRUE;
                }
    }
    return FALSE;
}

static BOOL augmentValPath(CPCardinalityDC* card,ORInt i)
{
    if (card->_valMagic[i] != card->_magic) {
        card->_valMagic[i] = card->_magic;
        if (card->_flow[i] < card->_up[i])  // forward
            return TRUE;
        if (card->_flow[i] == 0)            // cannot borrow
            return FALSE;
        ORInt v = card->_valFirstMatch[i];
        while (v != MAXINT) {
            if (augmentVarPath(card,v))
                return TRUE;
            v = card->_valNextMatch[v];
        }
    }
    return FALSE;
}

static BOOL findMaxFlow(CPCardinalityDC* card)
{
   if (card->_nbAssigned < card->_varSize) {
      for(ORInt v = 0; v < card->_varSize; v++)
         if (card->_varMatch[v] == MAXINT) {
            card->_magic++;
            if (!augmentVarPath(card,v))
               return FALSE;
         }
   }
   return TRUE;
}

static BOOL findFeasibleFlowToValueFromValue(CPCardinalityDC* card,ORInt val,ORInt w);

static BOOL findFeasibleFlowToValueFromVariable(CPCardinalityDC* card,ORInt val,ORInt i)
{
   if (card->_varMagic[i] != card->_magic) { // forward
      card->_varMagic[i] = card->_magic;
      if (card->_varMatch[i] != val && memberDom(card->_var[i],val)) {
         assign(card,i,val);
         return TRUE;
      }
      ORBounds b = bounds(card->_var[i]);
      for(ORInt w = b.min; w <= b.max; w++)
         if (w != val && card->_varMatch[i] != w && memberDom(card->_var[i],w))
            if (findFeasibleFlowToValueFromValue(card,val,w)) {
               assign(card,i,w);
               return TRUE;
            }
   }
   return FALSE;
}


static BOOL findFeasibleFlowToValueFromValue(CPCardinalityDC* card,ORInt val,ORInt w)
{
   if (card->_valMagic[w] != card->_magic) {
      card->_valMagic[w] = card->_magic;
      ORInt v = card->_valFirstMatch[w];
      while (v != MAXINT) {
         if (findFeasibleFlowToValueFromVariable(card,val,v))
            return TRUE;
         v = card->_valNextMatch[v];
      }
   }
   return FALSE;
}

static BOOL findFeasibleFlowToValue(CPCardinalityDC* card,ORInt val)
{
   for(ORInt w = card->_valMin; w <= card->_valMax; w++) // borrowing
      if (card->_flow[w] > card->_low[w])
         if (findFeasibleFlowToValueFromValue(card,val,w))
         return TRUE;
    return FALSE;
}

static BOOL findFeasibleFlow(CPCardinalityDC* card)
{
    for(ORInt w = card->_valMin; w <= card->_valMax; w++)
        while (card->_flow[w] < card->_low[w]) {
            card->_magic++;
            if (!findFeasibleFlowToValue(card,w))
                return FALSE; 
        }
    return TRUE;
}

static void SCC(CPCardinalityDC* card)
{
   for(ORInt v = 0 ; v < card->_varSize; v++) {
      card->_varComponent[v] = 0;
      card->_varDfs[v] = 0;
   }
   for(ORInt w = card->_valMin; w <= card->_valMax; w++) {
      card->_valComponent[w] = 0;
      card->_valDfs[w] = 0;
   }
   card->_sinkComponent = 0;
   card->_sinkDfs = 0;
   
   card->_top = 0;
   card->_dfs = card->_varSize + card->_valSize + 1;
   card->_component = 0;
   
   for(ORInt v = 0; v < card->_varSize; v++)
      if (!card->_varDfs[v])
         SCCFromVariable(card,v);
}

static void SCCFromVariable(CPCardinalityDC* card,ORInt k)
{
   ORInt* varMatch = card->_varMatch;
   ORInt* varComponent = card->_varComponent;
   ORInt* varDfs = card->_varDfs;
   ORInt* varHigh = card->_varHigh;
 
   ORInt* valComponent = card->_valComponent;
   ORInt* valDfs = card->_valDfs;
   ORInt* valHigh = card->_valHigh;
   
   ORInt* stack = card->_stack;
   ORInt* nodeType = card->_nodeType;
   
   varDfs[k] = card->_dfs--;
   varHigh[k] = varDfs[k];
   stack[card->_top] = k;
   nodeType[card->_top] = 0;
   card->_top++;
   
   CPIntVar* x = card->_var[k];
   ORBounds bx = bounds(x);
   for(ORInt w = bx.min; w <= bx.max; w++) {
      if (varMatch[k] != w) {
         if (memberBitDom(x,w)) {
            if (!valDfs[w]) {
               SCCFromValue(card,w);
               if (valHigh[w] > varHigh[k])
                  varHigh[k] = valHigh[w];
            }
            else if (valDfs[w] > varDfs[k] && !valComponent[w]) {
               if (valDfs[w] > varHigh[k])
                  varHigh[k] = valDfs[w];
            }
         }
      }
   }
   
   if (varHigh[k] == varDfs[k]) {
      card->_component++;
      do {
         card->_top--;
         ORInt x = stack[card->_top];
         ORInt t = nodeType[card->_top];
         if (t == 0) {
            varComponent[x] = card->_component;
            if (x == k)
               break;
         }
         else if (t == 1)
            valComponent[x] = card->_component;
         else
            card->_sinkComponent = card->_component;
         
      }
      while (true);
   }
}

static void SCCFromValue(CPCardinalityDC* card,ORInt w)
{
   ORInt* varComponent = card->_varComponent;
   ORInt* varDfs = card->_varDfs;
   ORInt* varHigh = card->_varHigh;
   
   ORInt* valComponent = card->_valComponent;
   ORInt* valDfs = card->_valDfs;
   ORInt* valHigh = card->_valHigh;
   ORInt* valFirstMatch = card->_valFirstMatch;
   
   ORInt* stack = card->_stack;
   ORInt* nodeType = card->_nodeType;
   
   valDfs[w] = card->_dfs--;
   valHigh[w] = valDfs[w];
   stack[card->_top] = w;
   nodeType[card->_top] = 1;
   card->_top++;
   
   ORInt v = valFirstMatch[w];
   while (v != MAXINT) {
      if (!varDfs[v]) {
         SCCFromVariable(card,v);
         if (varHigh[v] > valHigh[w])
            valHigh[w] = varHigh[v];
      }
      else if ((varDfs[v] > valDfs[w]) && !varComponent[v]) {
         if (varDfs[v] > valHigh[w])
            valHigh[w] = varDfs[v];
      }
      v = card->_valNextMatch[v];
   }

   if (card->_flow[w] < card->_up[w]) {
      if (!card->_sinkDfs) {
         SCCFromSink(card);
         if (card->_sinkHigh > valHigh[w])
            valHigh[w] = card->_sinkHigh;
      }
      else if ((card->_sinkDfs > valDfs[w]) && !card->_sinkComponent) {
         if (card->_sinkDfs > valHigh[w])
            valHigh[w] = card->_sinkDfs;
      }
   }
   
   if (valHigh[w] == valDfs[w]) {
      card->_component++;
      do {
         card->_top--;
         ORInt x = stack[card->_top];
         ORInt t = nodeType[card->_top];
         if (t == 0)
            varComponent[x] = card->_component;
         else if (t == 1) {
            valComponent[x] = card->_component;
            if (w == x)
               break;
         }
         else
            card->_sinkComponent = card->_component;
         
      }
      while (true);
   }
}

static void SCCFromSink(CPCardinalityDC* card)
{
   ORInt* stack = card->_stack;
   ORInt* nodeType = card->_nodeType;
   ORInt* valDfs = card->_valDfs;
   ORInt* valHigh = card->_valHigh;
   ORInt* valComponent = card->_valComponent;
   ORInt* low = card->_low;
   ORInt* flow = card->_flow;
   
   card->_sinkDfs  = card->_dfs--;
   card->_sinkHigh = card->_sinkDfs;
   stack[card->_top] = MAXINT;
   nodeType[card->_top] = 2;
   card->_top++;
   
   for(ORInt w = card->_valMin; w <= card->_valMax; w++)
      if (flow[w] > low[w]) {
         if (!valDfs[w]) {
            SCCFromValue(card,w);
            if (valHigh[w] > card->_sinkHigh)
               card->_sinkHigh = valHigh[w];
         }
         else if ((valDfs[w] > card->_sinkDfs) && !valComponent[w]) {
            if (valDfs[w] > card->_sinkHigh)
               card->_sinkHigh = valDfs[w];
         }
      }
   
   if (card->_sinkHigh == card->_sinkDfs) {
      card->_component++;
      do {
         --card->_top;
         ORInt x = stack[card->_top];
         int t = nodeType[card->_top];
         if (t == 0)
            card->_varComponent[x] = card->_component;
         else if (t == 1)
            card->_valComponent[x] = card->_component;
         else {
            card->_sinkComponent = card->_component;
            break;
         }
      }
      while (true);
   }
}

-(void) post
{
    if (!_posted) {
       _posted = true;
       
       [self allocate];
       [self initializeFlow];
       
       [self propagate];
       
       for(ORInt i = 0; i < _varSize; i++)
          if (![_var[i] bound])
             [_var[i] whenChangePropagate: self];
    }
}


static BOOL isFeasible(CPCardinalityDC* card)
{
   ORInt* _varMatch = card->_varMatch;
   BOOL needFlow = FALSE;
   for(ORInt i = 0; i < card->_varSize; i++)
      if (_varMatch[i] != MAXINT) {
         if (!memberDom(card->_var[i],_varMatch[i])) {
            unmatchVar(card,i);
            needFlow = TRUE;
         }
      }
      else
         needFlow = TRUE;
   
   if (!findMaxFlow(card))
      return FALSE;
   if (!findFeasibleFlow(card))
      return FALSE;
   return TRUE;
}

static void prune(CPCardinalityDC* card)
{
   SCC(card);
   for(int v = 0; v < card->_varSize; v++) {
      CPIntVar* x = card->_var[v];
      ORBounds b = bounds(x);
      for(ORInt w = b.min; w <= b.max; w++)
         if (card->_varMatch[v] != w)
            if (card->_varComponent[v] != card->_valComponent[w])
               if (memberDom(x,w))
                  removeDom(x,w);
   }
}


-(void) propagate
{
   if (!isFeasible(self))
      failNow();
   prune(self);
}

-(NSSet*) allVars
{
    if (_posted)
        return [[[NSSet alloc] initWithObjects:_var count:_varSize] autorelease];
    else
        @throw [[ORExecutionError alloc] initORExecutionError: "Cardinality: allVars called before the constraints is posted"];
    return NULL;
}

-(ORUInt) nbUVars
{
    if (_posted) {
        ORUInt nb=0;
        for(ORUInt k=0;k<_varSize;k++)
            nb += ![_var[k] bound];
        return nb;
    }
    else 
        @throw [[ORExecutionError alloc] initORExecutionError: "Cardinality: nbUVars called before the constraints is posted"];
    return 0;
}
@end

// ============================================================================================

@implementation CPGeneralizedCardinalityDC {
    id<CPIntVarArray> _x;
    id<CPIntVarArray> _count;
    
    id<CPIntVar>* _var;
    int         _nb;
    int     _varSize;
    id<CPIntVar>* _vcount;
    int            _lc;
    int            _uc;
    int            _sc;
    int            _nc;
    // value
    int            _min;
    int            _max;
    int            _valSize;
    int*           _low;
    int*           _up;
    int*           _flow;
    // flow
    int            _sizeFlow;
    int*           _varMatch;
    int*           _next;
    int*           _prev;
    int*           _valMatch;
    int*           _varSeen;
    int*           _valSeen;
    int            _magic;
    
    int            _dfs;
    int            _component;
    
    int*           _varComponent;
    int*           _varDfs;
    int*           _varHigh;
    
    int*           _valComponent;
    int*           _valDfs;
    int*           _valHigh;
    
    int            _sinkComponent;
    int            _sinkDfs;
    int            _sinkHigh;
    
    int*           _stack;
    int*           _type;
    int            _top;
    BOOL        _posted;
}
-(CPGeneralizedCardinalityDC*) initCPGeneralizedCardinalityDC:(id<CPIntVarArray>)x
                                                          occ:(id<CPIntVarArray>)occ
{
    self = [super initCPCoreConstraint:[[x at:x.low] engine]];
    _x = x;
    _count = occ;
    _low = _up = _flow = 0;
    _varMatch = _next = _prev = 0;
    _valMatch = _varSeen = _valSeen = 0;
    _varComponent = _varDfs = _varHigh = 0;
    _valComponent = _valDfs = _valHigh = 0;
    _sinkComponent = _sinkDfs = _sinkHigh = 0;
    _stack = _type = 0;
    return self;
}
-(void) dealloc
{
    if (_posted) {
        free(_var);
        free(_vcount);
        free(_varMatch);
        free(_next);
        free(_prev);
        free(_varComponent);
        free(_varDfs);
        free(_varHigh);
        
        _low += _min;
        _up += _min;
        _flow += _min;
        _valComponent += _min;
        _valDfs += _min;
        _valHigh += _min;
        
        free(_low);
        free(_up);
        free(_flow);
        free(_valComponent);
        free(_valDfs);
        free(_valHigh);
        free(_stack);
        free(_type);
        
    }
    [super dealloc];

}
-(void) post
{
    int low = _x.range.low;
    int up  = _x.range.up;
    _varSize = up - low + 1;
    _var  = malloc(sizeof(id)*_varSize);
    _nb = 0;
    for(int k=low ; k<=up; k++)
        _var[_nb++] = [_x at:k];
    
    _lc = _count.range.low;
    _uc  = _count.range.up;
    _sc = _uc - _lc + 1;
    _vcount  = malloc(sizeof(id)*_sc);
    _vcount -= _lc;
    for(int k=_lc ; k<=_uc; k++)
        _vcount[k] = [_count at:k];
    
    if (![self findValueRange])
        failNow();
    [self allocateFlow];
    [self findInitialFlow];
    if (![self findMaximalFlow])
        failNow();
    if (![self findFeasibleFlow])
        failNow();
    [self allocateSCC];
    [self prune];
    if (![self pruneBounds])
        failNow();
    for(int k = 0 ; k < _nb; k++)
        if (!_var[k].bound)
            [_var[k] whenChangeBoundsPropagate:self];
    for(int k = _lc ; k <= _uc; k++)
        if (!_vcount[k].bound)
            [_vcount[k] whenChangeBoundsPropagate:self];
}
-(void) propagate
{
    [self updateBounds];
    for(int k = 0; k < _nb; k++) {
        if (_varMatch[k] != -MAXINT) {
            if (![_var[k] member:_varMatch[k]]) {
                [self unassign:k];
            }
        }
    }
    for(int k = _min; k <= _max; k++)
        while (_flow[k] > _up[k])
            [self unassign:_valMatch[k]];
    if (![self findMaximalFlow]) {
        failNow();
    }
    if (![self findFeasibleFlow]) {
        failNow();
    }
    [self prune];
    if (![self pruneBounds])
        failNow();
}

-(void)prune
{
    [self findSCC];
    for(int k = 0; k < _nb; k++) {
        id<CPIntVar> x = _var[k];
        int mx = x.min;
        int Mx = x.max;
        for(int w = mx; w <= Mx; w++) {
            if (_varMatch[k] != w) {
                if (_varComponent[k] != _valComponent[w]) {
                    if ([x member:w])
                        [x remove:w];
                }
            }
        }
    }
}

-(bool) pruneBounds
{
    for(int i = _lc ; i <= _uc; i++) {
        if (i >= _min && i <= _max) {
            int m = _vcount[i].min;
            int M = _vcount[i].max;
            if (m != M) {
                // update the lower bounds
                _up[i] = m;
                while (![self decreaseMax:i]) {
                    _up[i]++;
                }
                ORStatus st = tryfail(^ORStatus{
                    [_vcount[i] updateMin:_up[i]];
                    return ORSuspend;
                }, ^ORStatus{
                    return ORFailure;
                });
                if (st == ORFailure)
                    return false;
                _up[i] = M;
            }
        }
    }
    for(int i = _lc ; i <= _uc; i++) {
        if (i >= _min && i <= _max) {
            int m = _vcount[i].min;
            int M = _vcount[i].max;
            if (m != M) {
                // update the upper bounds
                _low[i] = M;
                while (![self increaseMin:i]) {
                    _low[i]--;
                }
                ORStatus st = tryfail(^ORStatus{
                    [_vcount[i] updateMax:_low[i]];
                    return ORSuspend;
                }, ^ORStatus{
                    return ORFailure;
                });
                if (st == ORFailure)
                    return false;
                _low[i] = m;
            }
        }
        else {
            ORStatus st = tryfail(^ORStatus{
                [_vcount[i] updateMax:0];
                return ORSuspend;
            }, ^ORStatus{
                return ORFailure;
            });
            if (st == ORFailure)
                return false;
        }
    }
    return true;
}


-(void)allocateSCC
{
    _varComponent = malloc(sizeof(int)*_varSize);
    _varDfs       = malloc(sizeof(int)*_varSize);
    _varHigh      = malloc(sizeof(int)*_varSize);
    
    _valComponent = malloc(sizeof(int)*_valSize);
    _valDfs       = malloc(sizeof(int)*_valSize);
    _valHigh      = malloc(sizeof(int)*_valSize);
    _valComponent -= _min;
    _valDfs       -= _min;
    _valHigh      -= _min;
    
    _stack        = malloc(sizeof(int)*(_varSize+_valSize+1));
    _type         = malloc(sizeof(int)*(_varSize+_valSize+1));
}

-(void)assign:(int)k to:(int) v
{
    [self unassign:k];
    // k is now first on the list of v
    _varMatch[k] = v;
    _flow[v]++;
    int nk = _valMatch[v];
    _next[k] = nk;
    _prev[k] = -MAXINT;
    if (nk != -MAXINT)
        _prev[nk] = k;
    _valMatch[v] = k;
    _sizeFlow++;
}


-(void)unassign:(int) k
{
    if (_varMatch[k] != -MAXINT) { // this guy is assigned; must be removed
        _sizeFlow--;
        int w = _varMatch[k];
        _flow[w]--;
        if (_valMatch[w] == k) { // first in the list
            int nk = _next[k];
            _valMatch[w] = nk;
            if (nk != -MAXINT)
                _prev[nk] = -MAXINT; // nk is now first
        }
        else { // not first
            int pk = _prev[k];
            int nk = _next[k];
            _next[pk] = nk;
            if (nk != -MAXINT)
                _prev[nk] = pk;
        }
        _varMatch[k] = -MAXINT;
    }
}

-(void)initSCC
{
    for(int k = 0 ; k < _nb; k++) {
        _varComponent[k] = 0;
        _varDfs[k] = 0;
        _varHigh[k] = 0;
    }
    for(int k = _min; k <= _max; k++) {
        _valComponent[k] = 0;
        _valDfs[k] = 0;
        _valHigh[k] = 0;
    }
    _sinkComponent = 0;
    _sinkDfs = 0;
    _sinkHigh = 0;
    
    _top = 0;
    _dfs = _nb + _valSize + 1;
    _component = 0;
}


-(void)findSCC
{
    [self initSCC];
    for(int k = 0; k < _nb; k++) {
        if (!_varDfs[k])
            [self findSCCvar:k];
    }
}

-(void)findSCCvar:(int) k
{
    _varDfs[k] = _dfs--;
    _varHigh[k] = _varDfs[k];
    _stack[_top] = k;
    _type[_top] = 0;
    _top++;
    assert(_top <= _varSize + _valSize + 1);
    
    id<CPIntVar> x = _var[k];
    int mx = x.min,Mx = x.max;
    for(int w = mx; w <= Mx; w++) {
        if (_varMatch[k] != w) {
            if ([x member:w]) {
                if (!_valDfs[w]) {
                    [self findSCCval:w];
                    if (_valHigh[w] > _varHigh[k])
                        _varHigh[k] = _valHigh[w];
                }
                else if ( (_valDfs[w] > _varDfs[k]) && (!_valComponent[w])) {
                    if (_valDfs[w] > _varHigh[k])
                        _varHigh[k] = _valDfs[w];
                }
            }
        }
    }
    if (_varHigh[k] == _varDfs[k]) {
        _component++;
        do {
            assert(_top > 0);
            int v = _stack[--_top];
            int t = _type[_top];
            if (t == 0)
                _varComponent[v] = _component;
            else if (t == 1)
                _valComponent[v] = _component;
            else
                _sinkComponent = _component;
            if (t == 0 && v == k)
                break;
        } while (true);
    }
}

-(void)findSCCval:(int) v
{
    _valDfs[v] = _dfs--;
    _valHigh[v] = _valDfs[v];
    _stack[_top] = v;
    _type[_top] = 1;
    _top++;
    assert(_top <= _varSize + _valSize + 1);
    
    // first go to the variables assigned to this value
    
    int k = _valMatch[v];
    while (k != -MAXINT) {
        if (!_varDfs[k]) {
            [self findSCCvar:k];
            if (_varHigh[k] > _valHigh[v])
                _valHigh[v] = _varHigh[k];
        }
        else if ( (_varDfs[k] > _valDfs[v]) && (!_varComponent[k])) {
            if (_varDfs[k] > _valHigh[v])
                _valHigh[v] = _varDfs[k];
        }
        k = _next[k];
    }
    // next try to see if you can go to the sink
    if (_flow[v] < _up[v]) {
        // go to the sink
        if (!_sinkDfs) {
            [self findSCCsink];
            if (_sinkHigh > _valHigh[v])
                _valHigh[v] = _sinkHigh;
        }
        else if ( (_sinkDfs > _valDfs[v]) && (!_sinkComponent)) {
            if (_sinkDfs > _valHigh[v])
                _valHigh[v] = _sinkDfs;
        }
    }
    if (_valHigh[v] == _valDfs[v]) {
        _component++;
        do {
            assert(_top > 0);
            int i = _stack[--_top];
            int t = _type[_top];
            if (t == 0)
                _varComponent[i] = _component;
            else if (t == 1)
                _valComponent[i] = _component;
            else
                _sinkComponent = _component;
            if (t == 1 && i == v)
                break;
        } while (true);
    }
}

-(void) findSCCsink
{
    _sinkDfs  = _dfs--;
    _sinkHigh = _sinkDfs;
    _stack[_top] = -MAXINT;
    _type[_top] = 2;
    _top++;
    assert(_top <= _varSize + _valSize + 1);
    for(int i = 0; i < _nb; i++) {
        int w = _varMatch[i];
        if (_flow[w] > _low[w]) {
            if (!_valDfs[w]) {
                [self findSCCval:w];
                if (_valHigh[w] > _sinkHigh)
                    _sinkHigh = _valHigh[w];
            }
            else if ( (_valDfs[w] > _sinkDfs) && (!_valComponent[w])) {
                if (_valDfs[w] > _sinkHigh)
                    _sinkHigh = _valDfs[w];
            }
        }
    }
    if (_sinkHigh == _sinkDfs) {
        _component++;
        do {
            assert(_top > 0);
            int i = _stack[--_top];
            int t = _type[_top];
            if (t == 0)
                _varComponent[i] = _component;
            else if (t == 1)
                _valComponent[i] = _component;
            else
                _sinkComponent = _component;
            if (t == 2)
                break;
        } while (true);
    }
}

-(bool)findValueRange
{
    _min = _lc;
    _max = _uc;
    for(int i = 0; i < _nb; i++) {
        int m = _var[i].min;
        int M = _var[i].max;
        if (m < _min) _min = m;
        if (M > _max) _max = M;
    }
    _valSize = _max - _min + 1;
    
    // low
    _low = malloc(sizeof(int)*_valSize);
    _low -= _min;
    for(int k = _min; k <= _max; k++)
        _low[k] = 0;
    
    // up
    _up = malloc(sizeof(int)*_valSize);
    _up -= _min;
    for(int k = _min; k <= _max; k++)
        _up[k] = _nb;
    
    for(int i = _lc ; i <= _uc; i++) {
        int v = _vcount[i].min;
        if (v > 0)
            _low[i] = v;
        else {
            ORStatus s = tryfail(^ORStatus{
                [_vcount[i] updateMin:0];
                return ORSuspend;
            }, ^ORStatus{ return ORFailure;});
            if (s == ORFailure) return false;
        }
    }

    for(int i = _lc ; i <= _uc; i++) {
        int v = _vcount[i].max;
        if (v < _nb)
            _up[i] = v;
        else {
            ORStatus s = tryfail(^ORStatus{
                [_vcount[i] updateMax:_nb];
                return ORSuspend;
            }, ^ORStatus{ return ORFailure;});
            if (s == ORFailure) return false;
        }
    }
    return true;
}

-(void)updateBounds
{
    for(int i = _lc ; i <= _uc; i++) {
        if (i >= _min && i <= _max) {
            int v = _vcount[i].min;
            if (v > 0)
                _low[i] = v;
            else
                _low[i] = 0;
        }
    }
    for(int i = _lc ; i <= _uc; i++) {
        if (i >= _min && i <= _max) {
            int v = _vcount[i].max;
            if (v < _nb)
                _up[i] = v;
            else
                _up[i] = _nb;
        }
    }
}

-(void)allocateFlow
{
    // flow
    _flow = malloc(sizeof(int)*_valSize);
    _flow -= _min;
    for(int k = _min; k <= _max; k++)
        _flow[k] = 0;
    
    // first variable matched
    _valMatch = malloc(sizeof(int)*_valSize);
    _valMatch -= _min;
    for(int k = _min; k <= _max; k++)
        _valMatch[k] = -MAXINT;  // unmatched
    
    // next variable matched
    _next = malloc(sizeof(int)*_varSize);
    for(int k = 0; k < _nb; k++)
        _next[k] = -MAXINT;  // no next
    
    // previous variable matched
    _prev = malloc(sizeof(int)*_varSize);
    for(int k = 0; k < _nb; k++)
        _prev[k] = -MAXINT;  // no prev
    
    // variable assignment
    _varMatch = malloc(sizeof(int)*_varSize);
    for(int k = 0 ; k < _nb; k++)
        _varMatch[k] = -MAXINT; // unmatched
    
    // flag
    _varSeen = malloc(sizeof(int)*_varSize);
    for(int k = 0; k < _nb; k++)
        _varSeen[k] = 0;
    // flag
    _valSeen = malloc(sizeof(int)*_valSize);
    _valSeen -= _min;
    for(int k = _min; k <= _max; k++)
        _valSeen[k] = 0;
    _magic = 0;
}

-(void)findInitialFlow
{
    _sizeFlow = 0;
    for(int k = 0; k < _nb; k++) {
        int mx = _var[k].min;
        int Mx = _var[k].max;
        for(int i = mx; i <= Mx; i++)
            if (_flow[i] < _up[i])
                if ([_var[k] member:i]) {
                    [self assign:k to:i];
                    break;
                }
    }
}
-(bool)findMaximalFlow
{
    if (_sizeFlow < _nb) {
        for(int k = 0; k < _nb; k++) {
            if (_varMatch[k] == -MAXINT) {
                _magic++;
                if (![self findAugmentingPath:k])
                    return false;
            }
        }
    }
    return true;
}

-(bool)findAugmentingPath:(int)k
{
    if (_varSeen[k] != _magic) {
        _varSeen[k] = _magic;
        id<CPIntVar> x = _var[k];
        int mx = x.min;
        int Mx = x.max;
        for(int v = mx; v <= Mx; v++) {
            if (_varMatch[k] != v) {
                if ([x member:v]) {
                    if ([self findAugmentingPathValue:v]) {
                        [self assign:k to:v];
                        return true;
                    }
                }
            }
        }
    }
    return false;
}

-(bool)findAugmentingPathValue:(int) v
{
    if (_valSeen[v] != _magic) {
        _valSeen[v] = _magic;
        if (_flow[v] < _up[v])
            return true;
        else if (_flow[v] > 0) {
            int i = _valMatch[v];
            while (i != -MAXINT) {
                if ([self findAugmentingPath:i])
                    return true;
                i = _next[i];
            }
        }
    }
    return false;
}

-(bool) findFeasibleFlow
{
    for(int v = _min; v <= _max; v++) {
        while (_flow[v] < _low[v])
            if (![self findFeasibleFlowTo:v])
                return false;
    }
    return true;
}

-(bool) findFeasibleFlowTo:(int) q
{
    _magic++;
    for(int v = _min; v <= _max; v++) {
        if (_flow[v] > _low[v])
            if ([self findFeasibleFlowValue:v to:q])
                return true;
    }
    return false;
}

-(bool) findFeasibleFlowValue:(int) v to:(int) q
{
    if (_valSeen[v] != _magic) {
        _valSeen[v] = _magic;
        int i = _valMatch[v];
        while (i != -MAXINT) {
            if (_varMatch[i] != q && [_var[i] member:q]) {
                [self assign:i to:q];
                return true;
            }
            i = _next[i];
        }
        i = _valMatch[v];
        while (i != -MAXINT) {
            if ([self findFeasibleFlowVar: i to:q])
                return true;
            i = _next[i];
        }
    }
    return false;
}

-(bool) findFeasibleFlowVar:(int)k to:(int) q
{
    if (_varSeen[k] != _magic) {
        _varSeen[k] = _magic;
        id<CPIntVar> x = _var[k];
        int mx = x.min;
        int Mx = x.max;
        for(int v = mx; v <= Mx; v++) {
            if (q != v &&_varMatch[k] != v) {
                if ([x member:v]) {
                    if ([self findFeasibleFlowValue:v to:q]) {
                        [self assign:k to:v];
                        return true;
                    }
                }
            }
        }
    }
    return false;
}

-(bool) decreaseMax:(int) w
{
    while (_flow[w] > _up[w])
        [self unassign:_valMatch[w]];
    if (![self findMaximalFlow])
        return false;
    if (![self findFeasibleFlow])
        return false;
    return true;
}

-(bool) increaseMin:(int) w
{
    while (_flow[w] < _low[w])
        if (![self findFeasibleFlowTo:w])
            return false;
    return true;
}

-(NSSet*) allVars
{
    unsigned long nbv = _x.count + _count.count;
    NSMutableSet* av = [[[NSMutableSet alloc] initWithCapacity:nbv] autorelease];
    for(id<CPIntVar> xi in _x)
        [av addObject:xi];
    for(id<CPIntVar> oi in _count)
        [av addObject:oi];
    return av;
}
-(ORUInt) nbUVars
{
    if (_posted) {
        ORUInt nb=0;
        for(ORUInt k=0;k<_varSize;k++)
            nb += ![_var[k] bound];
        for(ORUInt k=_lc;k<=_uc;k++) {
            id<CPIntVar> vc = _vcount[k];
            ORBool b = ![vc bound];
            nb += b;
        }
        return nb;
    }
    else
        @throw [[ORExecutionError alloc] initORExecutionError: "GenCardinality: nbUVars called before the constraints is posted"];
    return 0;
}
@end
