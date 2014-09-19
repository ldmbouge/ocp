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


@class CPIntVarI;
@interface CPEquationBC : CPCoreConstraint 
-(CPEquationBC*)initCPEquationBC: (id) x equal:(ORInt) c;
-(void) post;
-(void) propagate;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPINEquationBC : CPCoreConstraint 
-(CPINEquationBC*)initCPINEquationBC: (id) x lequal:(ORInt) c;
-(void) post;
-(void) propagate;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end
