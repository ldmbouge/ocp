/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/


#import <Foundation/Foundation.h>
#import "CPTypes.h"
#import "CPIntVarI.h"
#import "CPConstraintI.h"
#import "ORTrail.h"
#import "CPTable.h"
#import <objcp/CPArray.h>

@interface CPTableI : NSObject<CPTable,NSCoding> {
    @package
    id<CPSolver>  _cp;
    CPInt   _arity; 
    CPInt   _nb;
    CPInt   _size;
    CPInt** _column;
    bool    _closed;
    CPInt*  _min;          // _min[j] is the minimum value in column[j]
    CPInt*  _max;          // _max[j] is the maximun value in column[j]
    CPInt** _nextSupport;  // _nextSupport[j][i] is the next support of element j in tuple i
    CPInt** _support;      // _support[j][v] is the support (a row index) of value v in column j
}
-(CPTableI*) initCPTableI: (id<CPSolver>) cp arity: (CPInt) arity;
-(void) dealloc;
-(void) insert: (CPInt) i : (CPInt) j : (CPInt) k;
-(void) addEmptyTuple;
-(void) fill: (CPInt) j with: (CPInt) val;
-(void) close;
-(void) encodeWithCoder: (NSCoder*) aCoder;
-(id) initWithCoder: (NSCoder*) aDecoder;
-(void) print;
@end


@interface CPTableCstrI : CPActiveConstraint<CPConstraint,NSCoding> {
    CPIntVarI**     _var;
    CPInt           _arity;  
    CPTableI*       _table;
    TRIntArray*     _currentSupport;
    bool            _posted;
}
-(CPTableCstrI*) initCPTableCstrI: (id<CPIntVarArray>) x table: (CPTableI*) table;
-(CPTableCstrI*) initCPTableCstrI: (CPTableI*) table on: (CPIntVarI*) x : (CPIntVarI*) y : (CPIntVarI*) z;
-(void) dealloc;
-(ORStatus) post;
-(void) encodeWithCoder: (NSCoder*) aCoder;
-(id) initWithCoder: (NSCoder*) aDecoder;

@end
