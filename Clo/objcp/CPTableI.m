/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/


#import <ORFoundation/ORFoundation.h>
#import "CPBasicConstraint.h"
#import "CPEngineI.h"
#import "CPIntVarI.h"
#import "CPError.h"
#import "CPTableI.h"


@implementation CPTableCstrI

-(void) initInstanceVariables 
{
    _priority = HIGHEST_PRIO;
    _posted = false;
}

-(CPTableCstrI*) initCPTableCstrI: (id<CPIntVarArray>) x table: (ORTableI*) table
{
   [table close];
   
   self = [super initCPCoreConstraint: [[x at:[x low]]  engine]];
   [self initInstanceVariables];
   _table = table;
   assert(_table);
   ORInt low = [x low];
   ORInt up = [x up];
   _arity = (up - low + 1);
   _var = malloc(_arity * sizeof(CPIntVar*));
   for(ORInt i = 0; i < _arity; i++)
      _var[i] = (CPIntVar*) [x at: low + i];
   return self;
}
-(CPTableCstrI*) initCPTableCstrI: (ORTableI*) table on: (CPIntVar*) x : (CPIntVar*) y : (CPIntVar*) z
{
   [table close];
   
   self = [super initCPCoreConstraint: [x engine]];
   [self initInstanceVariables];
   _table = table;
   assert(_table);
   _arity = 3;
   _var = malloc(_arity * sizeof(CPIntVar*));
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
    ORTableI* table = cstr->_table;
    for(ORInt i = 0; i < arity; i++) 
        if (!memberDom(cstr->_var[i],table->_column[i][tuple]))
            return false;
    return true;
}

static void findNewSupport(CPTableCstrI* cstr,ORInt tuple,ORInt col)
{
    ORTableI* table = cstr->_table;
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
            assignTRIntArray(cstr->_currentSupport[col],v,tuple,cstr->_trail);
        }
    }
}

static void removeValue(CPTableCstrI* cstr,ORInt i,ORInt v)
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
}

-(void) initSupport: (ORInt) i
{
    int nb = _table->_max[i] - _table->_min[i] + 1;
    _currentSupport[i] = makeTRIntArray(_trail,nb,_table->_min[i]);
    for(ORInt v = _table->_min[i]; v <= _table->_max[i]; v++)
        assignTRIntArray(_currentSupport[i],v,-1,_trail);
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
            assignTRIntArray(_currentSupport[i],v,tuple,_trail);
    }
}

-(void) post
{
    if (_posted)
        return ;
    _posted = true;
    for(ORInt i = 0; i < _arity; i++) {
       [_var[i] updateMin: _table->_min[i]];
       [_var[i] updateMax: _table->_max[i]];
    }
    _currentSupport = (TRIntArray*) malloc(sizeof(TRIntArray) * _arity);
    for(ORInt i = 0; i < _arity; i++)
        [self initSupport: i];
    for(ORInt i = 0; i < _arity; i++) 
        if (![_var[i] bound])
            [_var[i] whenLoseValue: self do: ^(ORInt v) { removeValue(self,i,v); }];
}
@end

