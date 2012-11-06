/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORModeling/ORModeling.h>

@interface ORModelI : NSObject<ORModel>
-(ORModelI*)              initORModelI;
-(void)                   dealloc;
-(NSString*)              description;
-(void)                   setId: (ORUInt) name;
-(void)                  captureVariable:(id<ORVar>)x;
-(void)                   applyOnVar:(void(^)(id<ORObject>))doVar
                           onObjects:(void(^)(id<ORObject>))doObjs
                       onConstraints:(void(^)(id<ORObject>))doCons
                         onObjective:(void(^)(id<ORObject>))doObjective;
-(id<ORObjectiveFunction>)objective;
-(NSArray*) variables;
-(NSArray*) constraints;
-(id<ORSolution>)solution;
-(void) visit: (id<ORVisitor>) visitor;
-(void)encodeWithCoder:(NSCoder *)aCoder;
-(id)initWithCoder:(NSCoder *)aDecoder;
@end

@interface ORSolutionI : NSObject<ORSolution>
-(ORSolutionI*) initSolution: (id<ORModel>) model;
-(ORInt) intValue: (id) var;
-(BOOL) boolValue: (id) var;
-(NSUInteger) count;
@end