/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORVisit.h>
#import <ORModeling/ORModelTransformation.h>

@interface ORMDDify : ORVisitor<ORModelTransformation>
-(id) initORMDDify: (id<ORAddToModel>) target;
-(id<ORAddToModel>) target;
-(void) combineMDDSpecs:(id<ORModel>)m;
-(int*) findVariableMappingFrom:(id<ORIntVarArray>)fromArray to:(id<ORIntVarArray>)toArray;
@end
