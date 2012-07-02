/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <Foundation/Foundation.h>
#import "CPTypes.h"
#import "CPDataI.h"
#import "CPConstraintI.h"
#import "CPTrail.h"
#import "CPBasicConstraint.h"
#import "CPArrayI.h"

@interface CPAssignment : CPActiveConstraint<CPConstraint,NSCoding> {
    id<CPIntVarArray>  _x;
    id<CPIntMatrix>    _matrix;
    CPIntVarI**        _var;
    CPInt              _varSize;
    CPInt              _low;
    CPInt              _up;
    
    CPInt              _lowr;
    CPInt              _upr;
    CPInt              _lowc;
    CPInt              _upc;
    id<CPTRIntMatrix>  _cost;
    
    CPInt              _bigM;
    
    id<CPTRIntArray>   _lc;
    id<CPTRIntArray>   _lr;
    
    id<CPTRIntArray>   _rowOfColumn;
    id<CPTRIntArray>   _columnOfRow;
    
    CPInt*             _columnIsMarked;
    CPInt*             _rowIsMarked;
    CPInt*             _pi;
    CPInt*             _pathRowOfColumn;
    
    bool               _posted;
}
-(CPAssignment*) initCPAssignment: (id<CPIntVarArray>) x matrix: (id<CPIntMatrix>) matrix;
-(void) dealloc;
-(CPStatus) post;
-(CPStatus) propagate;
-(NSSet*)allVars;
-(CPUInt)nbUVars;
@end
