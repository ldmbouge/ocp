/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/


#import <CPUKernel/CPUKernel.h>
#import <objcp/objcp.h>

@interface CPCircuit : CPCoreConstraint<CPConstraint>
-(CPCircuit*) initCPCircuit: (id<CPIntVarArray>) x;
-(void) dealloc;
-(void) post;
void assignCircuit(CPCircuit* cstr,int i);
@end

@interface CPPath : CPCoreConstraint<CPConstraint>
-(CPPath*) initCPPath: (id<CPIntVarArray>) x;
-(void) dealloc;
-(void) post;
void assignPath(CPPath* cstr,int i);
@end

@interface CPSubCircuit : CPCoreConstraint<CPConstraint>
-(CPSubCircuit*) initCPSubCircuit: (id<CPIntVarArray>) x;
-(void) dealloc;
-(void) post;
ORStatus assignSubCircuit(CPSubCircuit* cstr,int i);
@end
