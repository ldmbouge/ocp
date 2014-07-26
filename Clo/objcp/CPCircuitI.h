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

@interface CPCircuit : CPCoreConstraint<CPConstraint>
-(CPCircuit*) initCPCircuit: (id<CPIntVarArray>) x;
-(void) dealloc;
-(void) post;
static void assignCircuit(CPCircuit* cstr,int i);
@end

@interface CPPath : CPCoreConstraint<CPConstraint>
-(CPPath*) initCPPath: (id<CPIntVarArray>) x;
-(void) dealloc;
-(void) post;
static void assignPath(CPPath* cstr,int i);
@end
