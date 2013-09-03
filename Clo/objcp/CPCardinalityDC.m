/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

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
static void SCCvar(CPCardinalityDC* card,ORInt k);
static void SCCval(CPCardinalityDC* card,ORInt k);
static void SCCsink(CPCardinalityDC* card);

-(void) initInstanceVariables 
{
    _idempotent = YES;
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

-(ORStatus) post
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
    return ORSuspend;
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

-(void) encodeWithCoder: (NSCoder*) aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:_x];
    [aCoder encodeObject:_lb];
    [aCoder encodeObject:_ub];
}

-(id) initWithCoder: (NSCoder*) aDecoder
{
    self = [super initWithCoder:aDecoder];
    _x = [[aDecoder decodeObject] retain];
    _lb = [[aDecoder decodeObject] retain];
    _ub = [[aDecoder decodeObject] retain];
    [self initInstanceVariables];
    return self;
}

@end
