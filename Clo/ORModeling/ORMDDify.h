/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORVisit.h>
#import <ORModeling/ORModelTransformation.h>
#import "ORMDDVisitors.h"
#import "ORCustomMDDStates.h"

@interface ORMDDify : ORVisitor<ORModelTransformation>
-(id) initORMDDify: (id<ORAddToModel>) target isTopDown:(bool)isTopDown;
-(id<ORAddToModel>) target;
-(int) checkForStateEquivalences:(id<ORMDDSpecs>)mergeInto and:(id<ORMDDSpecs>)other returnedMapping:(int*)returnedMapping;
-(bool) areEquivalent:(id<ORMDDSpecs>)mergeInto atIndex:(int)index1 and:(id<ORMDDSpecs>)other atIndex:(int)index2 withDependentMapping:(NSMutableDictionary*)dependentMappings andConfirmedMapping:(NSMutableDictionary*)confirmedMappings equivalenceVisitor:(ORDDExpressionEquivalenceChecker*)equivalenceChecker candidates:(int**)candidates;
-(void) combineMDDSpecs:(id<ORModel>)m;
-(int*) findVariableMappingFrom:(id<ORIntVarArray>)fromArray to:(id<ORIntVarArray>)toArray;
@end
