/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/


#import "CPTableI.h"
#import "CPBasicConstraint.h"
#import "CPEngineI.h"
#import "CPIntVarI.h"
#import "CPArrayI.h"
#import "CPError.h"

@implementation CPTableI

-(CPTableI*) initCPTableI: (id<CPSolver>) cp arity: (ORInt) arity
{
    self = [super init];    
    _cp = cp;
    _arity = arity;
    _nb = 0;
    _size = 2;
    _column = malloc(sizeof(ORInt*)*_arity);
    for(ORInt i = 0; i < _arity; i++) 
        _column[i] = malloc(sizeof(ORInt)*_size);
    _closed = false;
    return self;
}

-(void) dealloc
{
//    NSLog(@"CPTableI dealloc called ...");
    for(ORInt i = 0; i < _arity; i++) 
        free(_column[i]);
    free(_column);
    if (_closed) {
        for(ORInt i = 0; i < _arity; i++) {
            free(_nextSupport[i]);
            _support[i] += _min[i];
            free(_support[i]);
        }
        free(_nextSupport);
        free(_support);
        free(_min);
        free(_max);
    }
    [super dealloc];
}

-(void) resize
{
    for(ORInt j = 0; j < _arity; j++) {
        ORInt* nc = malloc(sizeof(ORInt)*2*_size);    
        for(ORInt i = 0; i < _nb; i++) 
            nc[i] = _column[j][i];
        free(_column[j]);
        _column[j] = nc;
    }
    _size *= 2;
}

-(void) addEmptyTuple
{
    if (_closed) 
        @throw [[ORExecutionError alloc] initORExecutionError: "The table is already closed"]; 
    if (_nb == _size) 
       [self resize]; 
    _nb++;
}

-(void) fill: (ORInt) j with: (ORInt) val
{
    if (_closed) 
        @throw [[ORExecutionError alloc] initORExecutionError: "The table is already closed"];
    if (j < 0 || j >= _arity)
        @throw [[ORExecutionError alloc] initORExecutionError: "No such index in the table tuples"];
    if (_nb == _size) 
        [self resize];
    _column[j][_nb-1] = val;
}

-(void) insert: (ORInt) i : (ORInt) j : (ORInt) k
{
    if (_closed) 
        @throw [[ORExecutionError alloc] initORExecutionError: "The table is already closed"];
    if (_nb == _size) 
        [self resize];
    _column[0][_nb] = i;
    _column[1][_nb] = j;
    _column[2][_nb] = k;
    _nb++;
}

-(void) index: (ORInt) j
{
    ORInt m = MAXINT;
    ORInt M = -MAXINT;
    for(ORInt i = 0; i < _nb; i++) {
        if (_column[j][i] < m)
            m = _column[j][i];
        if (_column[j][i] > M)
            M = _column[j][i];
    }
    _min[j] = m;
    _max[j] = M;
    ORInt nbValues = M - m + 1;
    _nextSupport[j] = malloc(sizeof(ORInt)*_nb);
    _support[j] = malloc(sizeof(ORInt)*nbValues);
    _support[j] -= m;
    for(ORInt i = 0; i < _nb; i++)
        _nextSupport[j][i] = -1;
    for(ORInt v = m; v <= M; v++)
        _support[j][v] = -1;
    for(ORInt i = 0; i < _nb; i++) {
        int v = _column[j][i];
        _nextSupport[j][i] = _support[j][v];
        _support[j][v] = i;
    }
}

-(void) close
{
    if (!_closed) {
        _closed = true;
        _min = malloc(sizeof(ORInt)*_arity);
        _max = malloc(sizeof(ORInt)*_arity);
        _nextSupport = malloc(sizeof(ORInt*)*_arity);
        _support = malloc(sizeof(ORInt*)*_arity);
        for(ORInt j = 0; j < _arity; j++)
            [self index: j];
    }
}

-(void) print
{
    for(ORInt i = 0; i < _nb; i++) {
        printf("%d = < ",i);
        for(ORInt j = 0; j < _arity; j++)
            printf("%d ",_column[j][i]);
        printf("> \n");
    }
    for(ORInt j = 0; j < _arity; j++)
        for(ORInt v = _min[j]; v <= _max[j]; v++)
            printf("support[%d,%d] = %d\n",j,v,_support[j][v]);
    printf("\n");
    for(ORInt j = 0; j < _arity; j++)
        for(ORInt i = 0; i < _nb; i++)
            printf("_nextSupport[%d,%d]=%d\n",j,i,_nextSupport[j][i]);
}

-(void) encodeWithCoder: (NSCoder*) aCoder
{
    [aCoder encodeObject:_cp];
    [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_arity];
    [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_nb];
    for(ORInt i = 0; i < _nb; i++) 
        for(ORInt j = 0; j < _arity; j++)
            [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_column[j][i]]; 
}

-(id) initWithCoder: (NSCoder*) aDecoder
{
    id<CPSolver> cp = [[aDecoder decodeObject] retain];
    ORInt arity;
    [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&arity];
    [self initCPTableI: cp arity: arity];
    ORInt size;
    [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&size]; 
    for(ORInt i = 0; i < size; i++) {
        [self addEmptyTuple];
        for(ORInt j = 0; j < _arity; j++) 
            [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_column[j][i]]; 
    }
    return self;
}
@end



@implementation CPTableCstrI

-(void) initInstanceVariables 
{
    _idempotent = YES;
    _priority = HIGHEST_PRIO;
    _posted = false;
}

-(CPTableCstrI*) initCPTableCstrI: (id<ORIntVarArray>) x table: (CPTableI*) table
{
    [table close];
    
    self = [super initCPActiveConstraint: [[x solver] engine]];
    [self initInstanceVariables];
    _table = table;
    
    ORInt low = [x low];
    ORInt up = [x up];
    _arity = (up - low + 1);
    _var = malloc(_arity * sizeof(CPIntVarI*));
    for(ORInt i = 0; i < _arity; i++)
        _var[i] = (CPIntVarI*) [x at: low + i];
    return self;    
}
-(CPTableCstrI*) initCPTableCstrI: (CPTableI*) table on: (CPIntVarI*) x : (CPIntVarI*) y : (CPIntVarI*) z
{
    [table close];
    
    self = [super initCPActiveConstraint: [[x solver] engine]];
    [self initInstanceVariables];    
    _table = table;

    _arity = 3;
    _var = malloc(_arity * sizeof(CPIntVarI*));
    _var[0] = x;
    _var[1] = y;
    _var[2] = z;
    return self;        
}
-(void) dealloc
{
//    NSLog(@"TableCstr dealloc called ...");
    free(_var);
    if (_posted) {
        for(ORInt i = 0; i < _arity; i++)
            freeTRIntArray(_currentSupport[i]);
        free(_currentSupport);
    }
    [super dealloc];
}

static bool isValidTuple(CPTableCstrI* cstr,ORInt tuple)
{
    int arity = cstr->_arity;
    CPTableI* table = cstr->_table;
    for(ORInt i = 0; i < arity; i++) 
        if (!memberDom(cstr->_var[i],table->_column[i][tuple]))
            return false;
    return true;
}

static ORStatus findNewSupport(CPTableCstrI* cstr,ORInt tuple,ORInt col)
{
    CPTableI* table = cstr->_table;
    ORInt v = table->_column[col][tuple];
    if (getTRIntArray(cstr->_currentSupport[col],v) == tuple) {
        tuple = table->_nextSupport[col][tuple];
        while (tuple != -1) 
            if (isValidTuple(cstr,tuple))
                break;
            else 
                tuple = table->_nextSupport[col][tuple];
        if (tuple == -1) {
           removeDom(cstr->_var[col],v);
        }
        else {
            assignTRIntArray(cstr->_currentSupport[col],v,tuple);
        }
    }
    return ORSuspend;
}

static ORStatus removeValue(CPTableCstrI* cstr,ORInt i,ORInt v)
{
    ORInt arity = cstr->_arity;
    TRIntArray currentSupport = cstr->_currentSupport[i];
    ORInt tuple = getTRIntArray(currentSupport,v);
    do {
        for(ORInt j = 0; j < arity; j++) 
            if (i != j)
               findNewSupport(cstr,tuple,j);
        tuple = cstr->_table->_nextSupport[i][tuple];
    } while (tuple != -1);
    return ORSuspend;
}

-(ORStatus) initSupport: (ORInt) i
{
    int nb = _table->_max[i] - _table->_min[i] + 1;
    _currentSupport[i] = makeTRIntArray(_trail,nb,_table->_min[i]);
    for(ORInt v = _table->_min[i]; v <= _table->_max[i]; v++)
        assignTRIntArray(_currentSupport[i],v,-1);
    for(ORInt v = _table->_min[i]; v <= _table->_max[i]; v++) {
        ORInt tuple = _table->_support[i][v];
        while (tuple != -1) {
            if (isValidTuple(self,tuple))
                break;
            else 
                tuple = _table->_nextSupport[i][tuple];
        }
        if (tuple == -1) {
           [_var[i] remove: v];
        }
        else 
            assignTRIntArray(_currentSupport[i],v,tuple);
//        printf("Support of value %d for column %d is %d \n",v,i,getTRIntArray(_currentSupport[i],v));
    }
    return ORSuspend;
}

-(ORStatus) post
{
    if (_posted)
        return ORSuspend;
    _posted = true;
    for(ORInt i = 0; i < _arity; i++) {
       [_var[i] updateMin: _table->_min[i]];
       [_var[i] updateMax: _table->_max[i]];
    }
    _currentSupport = (TRIntArray*) malloc(sizeof(TRIntArray) * _arity);
    for(ORInt i = 0; i < _arity; i++) {
        [self initSupport: i];
    }
    for(ORInt i = 0; i < _arity; i++) 
        if (![_var[i] bound])
            [_var[i] whenLoseValue: self do: ^(ORInt v) { removeValue(self,i,v); }];
    return ORSuspend;        
}

-(void) encodeWithCoder: (NSCoder*) aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:_table];
    [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_arity];
    for(ORInt i=0;i<_arity;i++)
        [aCoder encodeObject:_var[i]];
}

-(id) initWithCoder: (NSCoder*) aDecoder
{
    self = [super initWithCoder:aDecoder];
    _table = [aDecoder decodeObject];
    [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_arity];
    _var = malloc(_arity * sizeof(CPIntVarI*));
    for(ORInt i=0;i<_arity;i++)
        _var[i] = [aDecoder decodeObject];
    [self initInstanceVariables];
    return self;
}

@end

