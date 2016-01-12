/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <ORFoundation/ORSetI.h>
#import <CPUKernel/CPTrigger.h>
//#import <CPUKernel/CPConstraintI.h>
#import <CPUKernel/CPTrigger.h>
#import <objcp/CPData.h>
#import <objcp/CPVar.h>
#import <objcp/CPDom.h>
#import <objcp/CPTrailIntSet.h>
#import <objcp/CPConstraint.h>


@interface CPIntSetVarI : ORObject<CPIntSetVar> {
   CPEngineI*  _engine;
   CPTrailIntSet* _pos;
   CPTrailIntSet* _req;
   CPTrailIntSet* _exc;
   TRInt          _isb;
   id<CPIntVar>  _card;
}
-(id)initWith:(id<CPEngine>)engine set:(id<ORIntSet>)s;
@end
