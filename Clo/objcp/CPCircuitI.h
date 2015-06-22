/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/


#import <Foundation/Foundation.h>
#import <CPUKernel/CPTypes.h>
#import <CPUKernel/CPConstraintI.h>
#import <objcp/CPVar.h>

@interface CPCircuitI : CPCoreConstraint<CPConstraint>
-(CPCircuitI*) initCPCircuitI: (id<CPIntVarArray>) x;
-(CPCircuitI*) initCPNoCycleI: (id<CPIntVarArray>) x;
-(void) dealloc;
-(void) post;
//static ORStatus assign(CPCircuitI* cstr,int i);
@end

@interface CPSubCircuit : CPCoreConstraint<CPConstraint>
-(CPCircuitI*) initCPSubCircuit: (id<CPIntVarArray>) x;
-(void) dealloc;
-(void) post;
//static ORStatus assignSubCircuit(CPSubCircuit* cstr,int i);
@end
