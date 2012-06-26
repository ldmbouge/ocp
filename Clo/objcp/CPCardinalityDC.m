#import "CPCardinalityDC.h"
#import "CPBasicConstraint.h"
#import "CPSolverI.h"
#import "CPIntVarI.h"
#import "CPArrayI.h"
#import "CPError.h"

@implementation CPCardinalityDC

static void initSCC(CPCardinalityDC* card);
static void findSCC(CPCardinalityDC* card);
static void findSCCvar(CPCardinalityDC* card,CPInt k);
static void findSCCval(CPCardinalityDC* card,CPInt k);
static void findSCCsink(CPCardinalityDC* card);

-(void) initInstanceVariables 
{
    _idempotent = YES;
    _priority = HIGHEST_PRIO-2;
    _posted = false;
}

-(CPCardinalityDC*) initCPCardinalityDC: (CPIntVarArrayI*) x low: (CPIntArrayI*) lb up: (CPIntArrayI*) ub
{
    self = [super initCPActiveConstraint: [[x cp] solver]];
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
        _low += _valMin;
        _up += _valMin;
        free(_low);
        free(_up);
        _flow += _valMin;
        free(_flow);
        free(_varMatch);
        _valFirstMatch += _valMin;
        free(_valFirstMatch);
        free(_nextMatch);
        free(_prevMatch);
        
        _valComponent += _valMin;
        free(_valComponent);
        _valDfs += _valMin;
        free(_valDfs);
        _valHigh += _valMin;
        free(_valHigh);
        free(_varComponent);
        free(_varDfs);
        free(_varHigh);
        free(_stack);
        free(_type);
    }
    [super dealloc]; 
}

-(void) createVariableArray
{
    CPInt low = [_x low];
    CPInt up = [_x up];
    _varSize = (up - low + 1);
    _var = malloc(_varSize * sizeof(CPIntVarI*));
    for(CPInt i = 0; i < _varSize; i++)
        _var[i] = (CPIntVarI*) [_x at: low + i];    
}

static void findValueRange(CPIntVarArrayI* x,CPInt* low,CPInt* up)
{
    CPInt l = [x low];
    CPInt u = [x up];
    for(CPInt i = l; i <= u; i++) {
        id<CPIntVar> v = [x at: i];
        CPInt lb = [v min]; 
        if (lb < *low)
            *low = lb;
        CPInt ub = [v max];
        if (ub > *up)
            *up = ub;
    }
}

-(void) initializeCardinalityArrays
{
    _valMin = min([_lb low],[_ub low]);
    _valMax = max([_lb up],[_ub up]);
    findValueRange(_x,&_valMin,&_valMax);
    _valSize = _valMax - _valMin + 1;
//    printf("_valSize: %d \n",_valSize);
    _low = malloc(_valSize * sizeof(CPInt));
    _up = malloc(_valSize * sizeof(CPInt));
    _low -= _valMin;
    _up -= _valMin;
    for(CPInt i = _valMin; i <= _valMax; i++) {
        _low[i] = 0;
        _up[i] = _varSize;
    }
    CPInt low = [_lb low];
    CPInt up = [_lb up];
    for(CPInt i = low; i <= up; i++) 
        _low[i] = [_lb at: i];
    low = [_ub low];
    up = [_ub up];
    for(CPInt i = low; i <= up; i++) 
        _up[i] = [_ub at: i];
//    for(CPInt i = _valMin; i <= _valMax; i++) 
//        printf(" %d -> [%d,%d] \n",i,_low[i],_up[i]);
}

-(void) initializeFlow
{
    _magic = 0;
    
    _flow = malloc(_valSize * sizeof(CPInt));
    _flow -= _valMin;
    for(CPInt v = _valMin; v <= _valMax; v++)
        _flow[v] = 0;
    
    _valFirstMatch = malloc(_valSize * sizeof(CPInt));
    _valFirstMatch -= _valMin;
    for(CPInt v = _valMin; v <= _valMax; v++)
        _valFirstMatch[v] = MAXINT;

    _varMatch = malloc(_varSize * sizeof(CPInt));
    for(CPInt i = 0; i < _varSize; i++)
        _varMatch[i] = MAXINT;
    
    _nextMatch = malloc(_varSize * sizeof(CPInt));
    for(CPInt i = 0; i < _varSize; i++)
        _nextMatch[i] = MAXINT;
    
    _prevMatch = malloc(_varSize * sizeof(CPInt));
    for(CPInt i = 0; i < _varSize; i++)
        _prevMatch[i] = MAXINT;
    
    _varMagic = malloc(_varSize * sizeof(CPULong));
    for(CPInt i = 0; i < _varSize; i++)
        _varMagic[i] = 0;
    
    _valueMagic = malloc(_valSize * sizeof(CPULong));
    _valueMagic -= _valMin;
    for(CPInt v = _valMin; v <= _valMax; v++)
        _valueMagic[v] = 0;
}

// assumes that the variable is matched
static void unmatchVariable(CPCardinalityDC* card,CPInt i)
{
    CPInt v = card->_varMatch[i];
    card->_nbAssigned--;
    card->_flow[v]--;
    CPInt p = card->_prevMatch[i];
    CPInt n = card->_nextMatch[i];
    card->_varMatch[i] = MAXINT;
    card->_nextMatch[i] = MAXINT;
    card->_prevMatch[i] = MAXINT;
    if (p != MAXINT)
        card->_nextMatch[p] = n;
    else 
        card->_valFirstMatch[v] = n;
    if (n != MAXINT)
        card->_prevMatch[n] = p;
}
    
static void matchVariable(CPCardinalityDC* card,CPInt i,CPInt v)
{
    card->_nbAssigned++;
    card->_flow[v]++;
    card->_varMatch[i] = v;
    CPInt j = card->_valFirstMatch[v];
    card->_valFirstMatch[v] = i;
    card->_nextMatch[i] = j;
    card->_prevMatch[i] = MAXINT;
    if (j != MAXINT)
        card->_prevMatch[j] = i;
}

static void assign(CPCardinalityDC* card,CPInt i,CPInt v)
{
    if (card->_varMatch[i] != MAXINT)
        unmatchVariable(card,i);
    matchVariable(card,i,v);
}

-(void) greedyFlow
{
    _nbAssigned = 0;
    for(CPInt i = 0; i < _varSize; i++) {
        CPInt m = [_var[i] min];
        CPInt M = [_var[i] max];
        for(CPInt v = m; v <= M; v++)
            if (_flow[v] < _up[v] && [_var[i] member: v]) {
                matchVariable(self,i,v);
                break;
            }
    }
}
static BOOL augmentValuePath(CPCardinalityDC* card,CPInt v);

static BOOL augmentPath(CPCardinalityDC* card,CPInt i)
{
    if (card->_varMagic[i] != card->_magic) {
        card->_varMagic[i] = card->_magic;
        CPInt m = [card->_var[i] min];
        CPInt M = [card->_var[i] max];
        for(CPInt v = m; v <= M; v++)
            if (card->_varMatch[i] != v && [card->_var[i] member: v]) 
                if (augmentValuePath(card,v)) {
                    assign(card,i,v);
                    return TRUE;
                }
    }
    return FALSE;
}

static BOOL augmentValuePath(CPCardinalityDC* card,CPInt v)
{
    if (card->_valueMagic[v] != card->_magic) {  
        card->_valueMagic[v] = card->_magic;
        if (card->_flow[v] < card->_up[v])  // forward
            return TRUE;
        if (card->_flow[v] == 0)            // cannot borrow
            return FALSE;
        CPInt i = card->_valFirstMatch[v];
        while (i != MAXINT) {
            if (augmentPath(card,i))
                return TRUE;
            i = card->_nextMatch[i];    
        }
    }
    return FALSE;
}

static BOOL findMaxFlow(CPCardinalityDC* card)
{
    if (card->_nbAssigned < card->_varSize) {
        for(CPInt i = 0; i < card->_varSize; i++)
            if (card->_varMatch[i] == MAXINT) {
                card->_magic++;
                if (!augmentPath(card,i))
                    return FALSE;
            }
    }
    return TRUE;
}

static BOOL findFeasibleFlowFromValue(CPCardinalityDC* card,CPInt v,CPInt w);

static BOOL findFeasibleFlowFromVariable(CPCardinalityDC* card,CPInt v,CPInt i)
{
    if (card->_varMagic[i] != card->_magic) { // forward
       card->_varMagic[i] = card->_magic;
       if (card->_varMatch[i] != v && [card->_var[i] member: v]) { 
           assign(card,i,v);
           return TRUE;
       }
       CPInt m = [card->_var[i] min];
       CPInt M = [card->_var[i] max];
       for(CPInt w = m; w <= M; w++)
           if (w != v && card->_varMatch[i] != w && [card->_var[i] member: w]) 
               if (findFeasibleFlowFromValue(card,v,w)) {
                   assign(card,i,w);
                   return TRUE;
               }
    }
    return FALSE;
}
       
    
static BOOL findFeasibleFlowFromValue(CPCardinalityDC* card,CPInt v,CPInt w)
{
    if (card->_valueMagic[w] != card->_magic) {
        card->_valueMagic[w] = card->_magic;
        CPInt i = card->_valFirstMatch[w];
        while (i != MAXINT) {
            if (findFeasibleFlowFromVariable(card,v,i))
                return TRUE;
            i = card->_nextMatch[i];
        }
    }
    return FALSE;
}

static BOOL findFeasibleFlowTo(CPCardinalityDC* card,CPInt v)
{
    for(CPInt w = card->_valMin; w <= card->_valMax; w++) // borrowing
        if (card->_flow[w] > card->_low[w] && findFeasibleFlowFromValue(card,v,w))
            return TRUE;
    return FALSE;
}
static BOOL findFeasibleFlow(CPCardinalityDC* card)
{
    for(CPInt v = card->_valMin; v <= card->_valMax; v++)
        while (card->_flow[v] < card->_low[v]) {
            card->_magic++;
            if (!findFeasibleFlowTo(card,v))
                return FALSE; 
        }
    return TRUE;
}

-(void) initializeSCCArrays
{
    _varComponent = malloc(sizeof(CPInt)*_varSize*2);
    _varDfs = malloc(sizeof(CPInt)*_varSize*2);
    _varHigh = malloc(sizeof(CPInt)*_varSize*2);    
    _valComponent = malloc(sizeof(CPInt)*_valSize*2);
    _valComponent -= _valMin;
    _valDfs = malloc(sizeof(CPInt)*_valSize*2);
    _valDfs -= _valMin;
    _valHigh = malloc(sizeof(CPInt)*_valSize*2);
    _valHigh -= _valMin;
        
    _stack = malloc(sizeof(CPInt)*(_varSize + _valSize + 1)*2);
    _type = malloc(sizeof(CPInt)*(_varSize + _valSize + 1)*2);   
}
    
static void initSCC(CPCardinalityDC* card)
{
    for(CPInt i = 0 ; i < card->_varSize; i++) {
        card->_varComponent[i] = 0;
        card->_varDfs[i] = 0;
        card->_varHigh[i] = 0;
    }
    
    for(CPInt v = card->_valMin; v <= card->_valMax; v++) {
        card->_valComponent[v] = 0;
        card->_valDfs[v] = 0;
        card->_valHigh[v] = 0;
    }
    
    card->_sinkComponent = 0;
    card->_sinkDfs = 0;
    card->_sinkHigh = 0;
    
    card->_top = 0;
    card->_dfs = card->_varSize + card->_valSize + 1;
    card->_component = 0; 
    
}
static void findSCC(CPCardinalityDC* card)
{
    initSCC(card);
    for(CPInt i = 0; i < card->_varSize; i++) 
        if (!card->_varDfs[i])
            findSCCvar(card,i);
}
static void findSCCvar(CPCardinalityDC* card,CPInt k)
{
    CPInt* _varDfs = card->_varDfs;
    CPInt* _varHigh = card->_varHigh;
    CPInt* _stack = card->_stack;
    CPInt* _type = card->_type;
    CPInt* _varMatch = card->_varMatch;
    CPInt* _valDfs = card->_valDfs;
    CPInt* _valHigh = card->_valHigh;
    CPInt* _valComponent = card->_valComponent;
    CPInt* _varComponent = card->_varComponent;
    
    _varDfs[k] = card->_dfs--;
    _varHigh[k] = _varDfs[k];
    _stack[card->_top] = k;
    _type[card->_top] = 0;
    card->_top++;
    
    CPIntVarI* x = card->_var[k];
    CPBounds bx;
    [x bounds:&bx];
    for(CPInt w = bx.min; w <= bx.max; w++) {
        if (_varMatch[k] != w) {
            if ([x member:w]) {
                CPInt valDfs = _valDfs[w];
                if (!valDfs) {
                    findSCCval(card,w);
                    if (_valHigh[w] > _varHigh[k])
                        _varHigh[k] = _valHigh[w];
                }
                else if (valDfs > _varDfs[k] && !_valComponent[w]) {
                    if (valDfs > _varHigh[k])
                        _varHigh[k] = valDfs;
                }
            }
        }
    }
    
    if (_varHigh[k] == _varDfs[k]) {
        card->_component++;
        do {
            card->_top--;
            CPInt v = _stack[card->_top];
            CPInt t = _type[card->_top];
            if (t == 0)
                _varComponent[v] = card->_component;
            else if (t == 1)
                _valComponent[v] = card->_component;
            else 
                card->_sinkComponent = card->_component;
            if (t == 0 && v == k)
                break;
        } while (true);
    }    
}

static void findSCCval(CPCardinalityDC* card,CPInt v)
{
    CPInt* _varDfs = card->_varDfs;
    CPInt* _varHigh = card->_varHigh;
    CPInt* _stack = card->_stack;
    CPInt* _type = card->_type;
    CPInt* _valDfs = card->_valDfs;
    CPInt* _valHigh = card->_valHigh;
    CPInt* _valComponent = card->_valComponent;
    CPInt* _varComponent = card->_varComponent;
    CPInt* _valFirstMatch = card->_valFirstMatch;
    
    _valDfs[v] = card->_dfs--;
    _valHigh[v] = _valDfs[v];
    _stack[card->_top] = v;
    _type[card->_top] = 1;
    card->_top++;
    
    // borrowing
    CPInt w = _valFirstMatch[v];
    while (w != MAXINT) {
        if (!_varDfs[w]) {
            findSCCvar(card,w);
            if (_varHigh[w] > _valHigh[v])
                _valHigh[v] = _varHigh[w];
        }
        else if ((_varDfs[w] > _valDfs[v]) && (!_varComponent[w])) {
            if (_varDfs[w] > _valHigh[v])
                _valHigh[v] = _varDfs[w];
        }
        w = card->_nextMatch[w];
    }
    // forward 
    if (card->_flow[v] < card->_up[v]) {
        if (!card->_sinkDfs) {
            findSCCsink(card);
            if (card->_sinkHigh > _valHigh[v])
                _valHigh[v] = card->_sinkHigh;
        }
        else if ((card->_sinkDfs > _valDfs[v]) && (!card->_sinkComponent)) {
            if (card->_sinkDfs > _valHigh[v])
                _valHigh[v] = card->_sinkDfs;
        }
    }
    
    if (_valHigh[v] == _valDfs[v]) {
        card->_component++;
        do {
            card->_top--;
            CPInt i = _stack[card->_top];
            CPInt t = _type[card->_top];
            if (t == 0)
                _varComponent[i] = card->_component;
            else if (t == 1)
                _valComponent[i] = card->_component;
            else 
               card->_sinkComponent = card->_component; 
            if (t == 1 && v == i)
                break;
        } while (true);
    }    
}
static void findSCCsink(CPCardinalityDC* card)
{
    CPInt* _stack = card->_stack;
    CPInt* _type = card->_type;
    CPInt* _valDfs = card->_valDfs;
    CPInt* _valHigh = card->_valHigh;
    CPInt* _valComponent = card->_valComponent;
    
    card->_sinkDfs  = card->_dfs--;
    card->_sinkHigh = card->_sinkDfs;
    _stack[card->_top] = MAXINT;
    _type[card->_top] = 2;
    card->_top++;
    // should really iterate over the value
    for(CPInt i = 0; i < card->_varSize; i++) {
        CPInt v = card->_varMatch[i];
        // borrow
        if (card->_flow[v] > card->_low[v]) {
            if (!card->_valDfs[v]) {
                findSCCval(card,v);
                if (_valHigh[v] > card->_sinkHigh)
                    card->_sinkHigh = _valHigh[v];
            }
            else if ((_valDfs[v] > card->_sinkDfs) && !_valComponent[v]) {
                if (_valDfs[v] > card->_sinkHigh)
                    card->_sinkHigh = _valDfs[v];
            }
        }
    }
    
    if (card->_sinkHigh == card->_sinkDfs) {
        card->_component++;
        do {
            CPInt i = _stack[--(card->_top)];
            int t = _type[card->_top];
            if (t == 0)
                card->_varComponent[i] = card->_component;
            else if (t == 1)
                card->_valComponent[i] = card->_component;
            else
                card->_sinkComponent = card->_component;
            if (t == 2)
                break;
        } while (true);
    }    
}

-(CPStatus) post
{
    if (!_posted) {
        _posted = true;
        [self createVariableArray];
        [self initializeCardinalityArrays];
        [self initializeFlow];
        [self initializeSCCArrays];
        [self greedyFlow];
        if ([self propagate] == CPFailure)
            return CPFailure;
        for(CPInt i = 0; i < _varSize; i++)
            if (![_var[i] bound])
                [_var[i] whenChangePropagate: self];
    }
    return CPSuspend;
}

-(void) printFlows
{

    for(CPInt v = _valMin; v <= _valMax; v++)
        printf("Flow[%d] = %d \n",v,_flow[v]);
    for(CPInt v = _valMin; v <= _valMax; v++)
        printf("valFirstMatch[%d] = %d \n",v,_valFirstMatch[v]);
    for(CPInt i = 0; i < _varSize; i++)
        printf("varMatch[%d] = %d \n",i,_varMatch[i]);    
    for(CPInt i = 0; i < _varSize; i++)
        printf("nextMatch[%d] = %d \n",i,_nextMatch[i]); 
    for(CPInt i = 0; i < _varSize; i++)
        printf("prevMatch[%d] = %d \n",i,_prevMatch[i]);
    printf("\n"); 
}

-(void) prune
{
    findSCC(self);
    for(int i = 0; i < _varSize; i++) {
        CPIntVarI* x = _var[i];
        CPInt m = [x min];
        CPInt M = [x max];
        for(CPInt v = m; v <= M; v++) 
            if (_varMatch[i] != v) 
                if (_varComponent[i] != _valComponent[v]) 
                    if ([x member: v])
                        [x remove: v];
    }
}
    
-(CPStatus) propagate
{
    for(CPInt i = 0; i < _varSize; i++)
        if (_varMatch[i] != MAXINT && ![_var[i] member: _varMatch[i]])
            unmatchVariable(self,i);
//    [self printFlows];
    if (!findMaxFlow(self))
        return CPFailure;
//    [self printFlows];
    if (!findFeasibleFlow(self))
        return CPFailure;
    [self prune];
//    [self printFlows];
    return CPSuspend;
}
-(NSSet*) allVars
{
    return NULL;
}
-(CPUInt) nbUVars
{
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
