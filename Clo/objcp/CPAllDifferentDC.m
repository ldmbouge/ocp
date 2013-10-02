/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import "CPAllDifferentDC.h"
#import "CPBasicConstraint.h"
#import "CPEngineI.h"
#import "CPIntVarI.h"
#import "CPError.h"

@implementation CPAllDifferentDC
{
   id<CPIntVarArray> _x;
   CPIntVar**       _var;
   ORInt             _varSize;
   ORInt*            _varMatch;
   ORInt*            _varMagic;
   
   ORInt             _min;
   ORInt             _max;
   ORInt             _valSize;
   ORInt*            _valMatch;
   ORInt*            _valMagic;
   ORInt             _magic;
   
   ORInt             _dfs;
   ORInt             _component;
     
   ORInt*            _varComponent;
   ORInt*            _varDfs;
   ORInt*            _varHigh;
   
   ORInt*            _valComponent;
   ORInt*            _valDfs;
   ORInt*            _valHigh;
   
   ORInt*            _stack;
   ORInt*            _isVal;
   ORInt             _top;
   
   bool              _posted;
}

static bool maximalMatching(CPAllDifferentDC* ad);
static void prune(CPAllDifferentDC* ad);

-(void) initInstanceVariables 
{
    _idempotent = YES;
    _priority = HIGHEST_PRIO-2;
    _posted = false;
}

-(CPAllDifferentDC*) initCPAllDifferentDC: (id<CPEngine>) engine over: (id<CPIntVarArray>) x
{
   self = [super initCPCoreConstraint: engine];
   _x = x;
   [self initInstanceVariables];
   return self;
}

-(void) dealloc
{
//   NSLog(@"AllDifferent dealloc called ...");
   if (_posted) {
      free(_var);
      free(_varMatch);
      free(_varMagic);
      free(_varComponent);
      free(_varDfs);
      free(_varHigh);

      _valMatch += _min;
      _valMagic += _min;
      _valComponent += _min;
      _valDfs += _min;
      _valHigh += _min;
 
      free(_valMatch);
      free(_valMagic);
      free(_valComponent);
      free(_valDfs);
      free(_valHigh);
      
      free(_stack);
      free(_isVal);
   }
   [super dealloc];
}

-(NSSet*) allVars
{
    if (_posted)
        return [[[NSSet alloc] initWithObjects:_var count:_varSize] autorelease];
    else
        @throw [[ORExecutionError alloc] initORExecutionError: "Alldifferent: allVars called before the constraints is posted"];
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
        @throw [[ORExecutionError alloc] initORExecutionError: "Alldifferent: nbUVars called before the constraints is posted"];
    return 0;
}

- (void) encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:_x];
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    _x = [aDecoder decodeObject];
    [self initInstanceVariables];
   return self;
}

static ORStatus removeOnBind(CPAllDifferentDC* ad,ORInt k)
{
   CPIntVar** var = ad->_var;
   ORInt nb = ad->_varSize;
   ORInt val = minDom(var[k]);
   for(ORInt i = 0; i < nb; i++)
      if (i != k) 
         removeDom(var[i], val);
   return ORSuspend;
}

-(ORStatus) post
{
   if (_posted)
      return ORSkip;
   _posted = true;
   
   [self allocate];
   
   for(ORInt k = 0; k < _varSize; k++)
      if ([_var[k] bound])
         removeOnBind(self,k);
   [self initMatching];

   [self propagate];
   for(ORInt k = 0 ; k < _varSize; k++)
      if (![_var[k] bound]) {
         [_var[k] whenBindDo: ^{ removeOnBind(self,k);} onBehalf:self];
         [_var[k] whenChangePropagate: self];
      }
   return ORSuspend;
}

-(void) allocate
{
   ORInt low = [_x low];
   _varSize = ([_x up] - low + 1);
   _var = malloc(_varSize * sizeof(CPIntVar*));
   for(ORInt k = 0; k < _varSize; k++)
      _var[k] = (CPIntVar*) [_x at: low + k];
   
   _min = MAXINT;
   _max = -MAXINT;
   for(ORInt k = 0; k < _varSize; k++) {
      ORBounds b = bounds(_var[k]);
      if (b.min < _min)
         _min = b.min;
      if (b.max > _max)
         _max = b.max;
   }
   _valSize = _max - _min + 1;
   if (_max == MAXINT)
      @throw [[ORExecutionError alloc] initORExecutionError: "AllDifferent constraint posted on variable with no or very large domain"];

   _varMatch = (ORInt*) malloc(sizeof(ORInt) * _varSize);
   _varMagic = (ORInt*) malloc(sizeof(ORInt) * _varSize);
   _varComponent = malloc(sizeof(ORInt)*_varSize);
   _varDfs = malloc(sizeof(ORInt)*_varSize);
   _varHigh = malloc(sizeof(ORInt)*_varSize);
   
   _valMatch = (ORInt*) malloc(sizeof(ORInt)*_valSize);
   _valMagic = (ORInt*) malloc(sizeof(ORInt) * _valSize);
   _valComponent = malloc(sizeof(ORInt)*_valSize);
   _valDfs = malloc(sizeof(ORInt)*_valSize);
   _valHigh = malloc(sizeof(ORInt)*_valSize);
   
   _valMatch -= _min;
   _valMagic -= _min;
   _valComponent -= _min;
   _valDfs -= _min;
   _valHigh -= _min;
   
   _stack = malloc(sizeof(ORInt)*(_varSize + _valSize));
   _isVal = malloc(sizeof(ORInt)*(_varSize + _valSize));
}

-(void) initMatching
{
   _magic = 0;
   for(ORInt k = 0 ; k < _varSize; k++) {
      _varMatch[k] = MAXINT;
      _varMagic[k] = 0;
   }
   for(ORInt k = _min; k <= _max; k++) {
      _valMatch[k] = MAXINT;
      _valMagic[k] = 0;
   }
   
   for(ORInt k = 0; k < _varSize; k++) {
      ORBounds b = bounds(_var[k]);
      for(ORInt i = b.min; i <= b.max; i++)
         if (_valMatch[i] == MAXINT)
            if ([_var[k] member: i]) {
               _varMatch[k] = i;
               _valMatch[i] = k;
               break;
            }
   }
}

static bool alternatingPath(CPAllDifferentDC* ad,ORInt i)
{
   ORInt* _varMagic = ad->_varMagic;
   ORInt* _valMagic = ad->_valMagic;
   ORInt* _valMatch = ad->_valMatch;
   ORInt* _varMatch = ad->_varMatch;
   CPIntVar** _var = ad->_var;
   
   if (_varMagic[i] != ad->_magic) {
      _varMagic[i] = ad->_magic;
      CPIntVar* x = _var[i];
      ORBounds b = bounds(x);
      ORInt _magic = ad->_magic;
      for(ORInt w = b.min; w <= b.max; w++)
         if (_varMatch[i] != w && _valMagic[w] != _magic && memberBitDom(x,w)) {
            _valMagic[w] = _magic;
            if (_valMatch[w] == MAXINT || alternatingPath(ad,_valMatch[w])) {
               _varMatch[i] = w;
               _valMatch[w] = i;
               return true;
            }
         }
   }
   return false;
}

static bool maximalMatching(CPAllDifferentDC* ad)
{
   ORInt* _varMatch = ad->_varMatch;
   ORInt _varSize = ad->_varSize;
   for(ORInt k = 0; k < _varSize; k++) {
      if (_varMatch[k] == MAXINT) {
         ad->_magic++;
         if (!alternatingPath(ad,k))
            return false;
      }
   }
   return true;
}

static BOOL isFeasible(CPAllDifferentDC* ad)
{
   // I may not have a matching due to earlier failures; the data structures are not trailed
   ORInt* varMatch = ad->_varMatch;
   ORInt* valMatch = ad->_valMatch;
   BOOL needMatching = false;
   for(ORInt k = 0; k < ad->_varSize; k++) {
      if (varMatch[k] != MAXINT) {
         if (!memberDom(ad->_var[k], varMatch[k])) {
            valMatch[varMatch[k]] = MAXINT;
            varMatch[k] = MAXINT;
            needMatching = true;
         }
      }
      else
         needMatching = true;
   }
   if (needMatching)
      return maximalMatching(ad);
   else
      return TRUE;
}

static void SCC(CPAllDifferentDC* ad)
{
   for(ORInt v = 0 ; v < ad->_varSize; v++) {
      ad->_varComponent[v] = 0;
      ad->_varDfs[v] = 0;
   }
   for(ORInt w = ad->_min; w <= ad->_max; w++) {
      ad->_valComponent[w] = 0;
      ad->_valDfs[w] = 0;
   }
   ad->_top = 0;
   ad->_dfs = ad->_varSize + ad->_valSize;
   ad->_component = 0;
   
   for(ORInt v = 0; v < ad->_varSize; v++)
      if (!ad->_varDfs[v])
         SCCFromVariable(ad,v);
}

static void SCCFromVariable(CPAllDifferentDC* ad,ORInt k)
{
   ORInt* varDfs = ad->_varDfs;
   ORInt* varHigh = ad->_varHigh;
   ORInt* varComponent = ad->_varComponent;
   ORInt* varMatch = ad->_varMatch;
   
   ORInt* valHigh = ad->_valHigh;
   ORInt* valDfs = ad->_valDfs;
   ORInt* valComponent = ad->_valComponent;
   
   ORInt* stack = ad->_stack;
   ORInt* isVal = ad->_isVal;

   varDfs[k] = ad->_dfs--;
   varHigh[k] = varDfs[k];
   stack[ad->_top] = k;
   isVal[ad->_top] = 0;
   ++ad->_top;
   
   CPIntVar* x = ad->_var[k];
   ORBounds b = bounds(x);
   for(ORInt w = b.min; w <= b.max; w++) 
      if (varMatch[k] != w && memberBitDom(x, w)) {
         if (!valDfs[w]) {
            SCCFromValue(ad,w);
            if (valHigh[w] > varHigh[k])
               varHigh[k] = valHigh[w];
         }
         else if (valDfs[w] > varDfs[k] && !valComponent[w]) {
            if (valDfs[w] > varHigh[k])
               varHigh[k] = valDfs[w];
         }
      }

   if (varHigh[k] == varDfs[k]) {
      ad->_component++;
      do {
         --ad->_top;
         ORInt x = stack[ad->_top];
         ORInt isTopVal = isVal[ad->_top];
         if (isTopVal == 0) {
            varComponent[x] = ad->_component;
            if (x == k)
               break;
         }
         else
            valComponent[x] = ad->_component;
      }
      while (true);
   }
}


static void SCCFromValue(CPAllDifferentDC* ad,ORInt k)
{
   ORInt* varDfs = ad->_varDfs;
   ORInt* varHigh = ad->_varHigh;
   ORInt* stack = ad->_stack;
   ORInt* isVal = ad->_isVal;
   ORInt* varMatch = ad->_varMatch;
   ORInt* valDfs = ad->_valDfs;
   ORInt* valHigh = ad->_valHigh;
   ORInt* valComponent = ad->_valComponent;
   ORInt* varComponent = ad->_varComponent;
   ORInt* valMatch = ad->_valMatch;
   
   valDfs[k] = ad->_dfs--;
   valHigh[k] = valDfs[k];
   stack[ad->_top] = k;
   isVal[ad->_top] = 1;
   ad->_top++;
   
   if (valMatch[k] != MAXINT) {
      ORInt v = valMatch[k];
      if (!varDfs[v]) {
         SCCFromVariable(ad,v);
         if (varHigh[v] > valHigh[k])
            valHigh[k] = varHigh[v];
      }
      else if ((varDfs[v] > valDfs[k]) && !varComponent[v]) {
         if (varDfs[v] > valHigh[k])
            valHigh[k] = varDfs[v];
      }
   }
   else {
      for(ORInt i = 0; i < ad->_varSize; i++) {
         ORInt w = varMatch[i];
         if (valDfs[w]==0) {
            SCCFromValue(ad,w);
            if (valHigh[w] > valHigh[k])
               valHigh[k] = valHigh[w];
         }
         else if ((valDfs[w] > valDfs[k]) && !valComponent[w]) {
            if (valDfs[w] > valHigh[k])
               valHigh[k] = valDfs[w];
         }
      }
   }
   
   if (valHigh[k] == valDfs[k]) {
      ad->_component++;
      do {
         --ad->_top;
         ORInt x = stack[ad->_top];
         ORInt isTopVal = isVal[ad->_top];
         if (isTopVal == 0)
            varComponent[x] = ad->_component;
         else {
            valComponent[x] = ad->_component;
            if (x == k)
               break;
         }
      }
      while (true);
   }
}

static void prune(CPAllDifferentDC* ad)
{
   ORInt* varMatch = ad->_varMatch;
   ORInt* valComponent = ad->_valComponent;
   ORInt* varComponent = ad->_varComponent;
   SCC(ad);
   for(ORInt k = 0; k < ad->_varSize; k++) {
      CPIntVar* x = ad->_var[k];
      ORBounds bx = bounds(x);
      for(ORInt w = bx.min; w <= bx.max; w++) 
         if (varMatch[k] != w && varComponent[k] != valComponent[w]) 
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

@end
