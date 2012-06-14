#import "CPCardinalityDC.h"
#import "CPBasicConstraint.h"
#import "CPSolverI.h"
#import "CPIntVarI.h"
#import "CPArrayI.h"
#import "CPError.h"

@implementation CPCardinalityDC
//static bool findMaximalMatching(CPAllDifferentDC* ad);
//static bool findAlternatingPath(CPAllDifferentDC* ad,CPInt i);
//static bool findAlternatingPathValue(CPAllDifferentDC* ad,CPInt v);
//static void initSCC(CPAllDifferentDC* ad);
//static void findSCC(CPAllDifferentDC* ad);
//static void findSCCvar(CPAllDifferentDC* ad,CPInt k);
//static void findSCCval(CPAllDifferentDC* ad,CPInt k);
//static void prune(CPAllDifferentDC* ad);

-(void) initInstanceVariables 
{
    _idempotent = YES;
    _priority = HIGHEST_PRIO-3;
    _posted = false;
}

-(CPCardinalityDC*) initCPCardinalityDC: (CPIntVarArrayI*) x low: (CPIntArrayI*) lb up: (CPIntArrayI*) ub
{
    self = [super initCPActiveConstraint: [[x cp] solver]];
    _x = [x retain];
    _lb = [lb retain];
    _ub = [ub retain];
    [self initInstanceVariables];
    return self;
}

-(void) dealloc
{
    NSLog(@"CPCardinalityDC dealloc called ...");
    [_x release];
    [_lb release];
    [_ub release];
    if (_posted) {
        free(_var);
        _low += _valMin;
        _up += _valMin;
        free(_low);
        free(_up);
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
    CPInt low = [_x low];
    CPInt up = [_x up];
    _varSize = (up - low + 1);
    _var = malloc(_varSize * sizeof(CPIntVarI*));
    for(CPInt i = 0; i < _varSize; i++)
        _var[i] = (CPIntVarI*) [_x at: low + i];    

    _valMin = min([_lb low],[_ub low]);
    _valMax = max([_lb up],[_ub up]);
    findValueRange(_x,&_valMin,&_valMax);
    _valSize = _valMax - _valMin + 1;
    printf("_valSize: %d \n",_valSize);
    _low = malloc(_valSize * sizeof(CPInt));
    _up = malloc(_valSize * sizeof(CPInt));
    _low -= _valMin;
    _up -= _valMin;
    for(CPInt i = _valMin; i <= _valMax; i++) {
        _low[i] = 0;
        _up[i] = _varSize;
    }
    low = [_lb low];
    up = [_lb up];
    for(CPInt i = low; i <= up; i++) 
        _low[i] = [_lb at: i];
    low = [_ub low];
    up = [_ub up];
    for(CPInt i = low; i <= up; i++) 
        _up[i] = [_ub at: i];
    for(CPInt i = _valMin; i <= _valMax; i++) 
        printf(" %d -> [%d,%d] \n",i,_low[i],_up[i]);
}

-(CPStatus) post
{
    [self createVariableArray];
    [self initializeCardinalityArrays];
    _posted = true;
    return CPSuspend;
}
-(CPStatus) propagate
{
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
