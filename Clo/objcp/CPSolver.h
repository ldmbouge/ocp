/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <Foundation/Foundation.h>
#import <objcp/CPTypes.h>
#import <objcp/CPData.h>
#import <ORFoundation/ORSet.h>
#import "CPConstraintI.h"

@protocol AbstractSolver <NSObject,ORTracker>
-(void) saveSolution;
-(void) restoreSolution;
-(CPStatus) close;
-(bool) closed;
-(void) trackObject:(id)obj;
-(NSMutableArray*)allVars;
@end

@protocol CPSolver <AbstractSolver>
-(CPStatus) add:(id<CPExpr>)lhs equal:(id<CPExpr>)rhs consistency:(CPConsistency)cons;
-(CPStatus) add:(id<CPExpr>)lhs leq:(id<CPExpr>)rhs consistency:(CPConsistency)cons;
-(CPStatus) add: (id<CPConstraint>) c;
-(CPStatus) post: (id<CPConstraint>) c;
-(CPStatus) label: (id) var with: (CPInt) val;
-(CPStatus) diff:  (id) var with: (CPInt) val;
-(CPStatus) lthen: (id<CPIntVar>) var with: (CPInt) val;
-(CPStatus) gthen: (id<CPIntVar>) var with: (CPInt) val;
-(CPStatus) restrict: (id<CPIntVar>) var to: (id<ORIntSet>) S;
-(CPStatus) propagate;
-(CPUInt) nbPropagation;
-(id<CPSolution>) solution;
-(CPUInt) nbVars;
-(NSMutableArray*)allVars;
-(id) trail;
-(CPInt)virtualOffset:(id)obj;
-(id)virtual:(id)obj;
@end
