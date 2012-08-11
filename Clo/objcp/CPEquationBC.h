/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <Foundation/Foundation.h>
#import <objcp/CPConstraintI.h>

@class CPIntVarI;
@interface CPEquationBC : CPCoreConstraint<NSCoding> { // sum(i in S) x_i == c
@private
   CPIntVarI**        _x;  // array of vars
   CPLong            _nb;  // size
   CPInt              _c;  // constant c in:: sum(i in S) x_i == c
   UBType* _updateBounds;
}
-(CPEquationBC*)initCPEquationBC: (id) x equal:(ORInt) c;
-(ORStatus) post;
-(void) propagate;
-(NSSet*)allVars;
-(CPUInt)nbUVars;
@end

@interface CPINEquationBC : CPCoreConstraint<NSCoding> { // sum(i in S) x_i <= c
@private
   CPIntVarI**        _x;  // array of vars
   CPLong            _nb;  // size
   CPInt              _c;  // constant c in:: sum(i in S) x_i <= c
   UBType*    _updateMax;
}
-(CPINEquationBC*)initCPINEquationBC: (id) x lequal:(ORInt) c;
-(ORStatus) post;
-(void) propagate;
-(NSSet*)allVars;
-(CPUInt)nbUVars;
@end
