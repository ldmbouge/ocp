/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <Foundation/Foundation.h>
#import <CPUKernel/CPConstraintI.h>
#import <ORFoundation/ORTrailI.h>

@class CPIntVar;
typedef struct CPEQTerm {
   UBType  update;
   CPIntVar* var;
   ORLong     low;
   ORLong      up;
   BOOL   updated;
} CPEQTerm;


MAKETRPointer(TRCPEQTerm,CPEQTerm);

@class CPIntVarI;
@interface CPEquationBC : CPCoreConstraint { // sum(i in S) x_i == c
@private
   CPIntVar**               _x;  // array of vars
   ORLong                   _nb;  // size
   ORInt                     _c;  // constant c in:: sum(i in S) x_i == c
   UBType*        _updateBounds;
   CPEQTerm*          _allTerms;
   TRCPEQTerm*           _inUse;
   TRInt                  _used;
   TRLong                   _ec; // expanded constant c (including the bound terms)
}
-(CPEquationBC*)initCPEquationBC: (id) x equal:(ORInt) c;
-(ORStatus) post;
-(void) propagate;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPINEquationBC : CPCoreConstraint { // sum(i in S) x_i <= c
@private
   CPIntVar**        _x;  // array of vars
   ORLong            _nb;  // size
   ORInt              _c;  // constant c in:: sum(i in S) x_i <= c
   UBType*    _updateMax;
}
-(CPINEquationBC*)initCPINEquationBC: (id) x lequal:(ORInt) c;
-(ORStatus) post;
-(void) propagate;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end
