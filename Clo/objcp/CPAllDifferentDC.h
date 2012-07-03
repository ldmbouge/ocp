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

@interface CPAllDifferentDC : CPActiveConstraint<CPConstraint,NSCoding> {
    CPIntVarArrayI* _x;
    CPIntVarI**     _var;
    UBType*         _member;
    CPInt           _varSize;
    CPInt*          _match;
    CPInt*          _varSeen;
    
    CPInt           _min;
    CPInt           _max;
    CPInt           _valSize;
    CPInt*          _valMatch;
    CPInt           _sizeMatching;
    CPInt*          _valSeen;
    CPInt           _magic;
    
    CPInt          _dfs;
    CPInt          _component;
    
    CPInt*         _varComponent;
    CPInt*         _varDfs;
    CPInt*         _varHigh;
    
    CPInt*         _valComponent;
    CPInt*         _valDfs;
    CPInt*         _valHigh;
    
    CPInt*         _stack;
    CPInt*         _type;
    CPInt          _top;
    
    bool           _posted;
}
-(CPAllDifferentDC*) initCPAllDifferentDC: (CPIntVarArrayI*) x;
-(void) dealloc;
-(CPStatus) post;
-(void) propagate;
-(NSSet*)allVars;
-(CPUInt)nbUVars;
@end
