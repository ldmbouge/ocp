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

-(ORStatus) add: (id<ORConstraint>) c;
-(ORStatus) post: (id<ORConstraint>) c;
-(id<ORConstraint>) wrapExpr: (id<ORSolver>) solver for: (id<ORRelation>) e  consistency: (CPConsistency) cons;
-(ORStatus) label: (id<ORIntVar>) var with: (ORInt) val;
-(ORStatus) diff:  (id<ORIntVar>) var with: (ORInt) val;
-(ORStatus) lthen: (id<ORIntVar>) var with: (ORInt) val;
-(ORStatus) gthen: (id<ORIntVar>) var with: (ORInt) val;
-(ORStatus) restrict: (id<ORIntVar>) var to: (id<ORIntSet>) S;
-(ORStatus) propagate;
-(CPUInt) nbPropagation;
-(id<ORSolution>) solution;
-(CPUInt) nbVars;
-(NSMutableArray*)allVars;
-(id) trail;
-(ORInt)virtualOffset:(id)obj;
-(id)virtual:(id)obj;
@end
