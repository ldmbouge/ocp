/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <objcp/CPTypes.h>
#import <objcp/CPData.h>

@protocol CPEngine <OREngine,ORSolutionProtocol>
-(ORStatus) add: (id<CPConstraint>) c;
-(ORStatus) post: (id<CPConstraint>) c;
-(id<CPConstraint>) wrapExpr:(id<CPRelation>) e  consistency: (CPConsistency) cons;
-(ORStatus) label: (id) var with: (CPInt) val;
-(ORStatus) diff:  (id) var with: (CPInt) val;
-(ORStatus) lthen: (id<CPIntVar>) var with: (CPInt) val;
-(ORStatus) gthen: (id<CPIntVar>) var with: (CPInt) val;
-(ORStatus) restrict: (id<CPIntVar>) var to: (id<ORIntSet>) S;
//-(ORStatus) propagate;
-(CPUInt) nbPropagation;
-(id<ORSolution>) solution;
-(CPUInt) nbVars;
-(NSMutableArray*)allVars;
-(id) trail;
-(CPInt)virtualOffset:(id)obj;
-(id)virtual:(id)obj;
@end
