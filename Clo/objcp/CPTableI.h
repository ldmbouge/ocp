/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/


#import <Foundation/Foundation.h>
#import <ORFoundation/ORData.h>
#import <ORFoundation/ORDataI.h>
#import <CPUKernel/CPTypes.h>
#import <CPUKernel/CPConstraintI.h>
#import "CPIntVarI.h"

@interface CPTableCstrI : CPCoreConstraint<CPConstraint> {
    CPIntVar**     _var;
    ORInt           _arity;  
    ORTableI*       _table;
    TRIntArray*     _currentSupport;
    bool            _posted;
}
-(CPTableCstrI*) initCPTableCstrI: (id<CPIntVarArray>) x table: (ORTableI*) table;
-(CPTableCstrI*) initCPTableCstrI: (ORTableI*) table on: (CPIntVar*) x : (CPIntVar*) y : (CPIntVar*) z;
-(void) dealloc;
-(ORStatus) post;
@end
