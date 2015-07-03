/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <ORFoundation/ORConstraint.h>
#import <ORFoundation/ORVar.h>
#import <ORModeling/ORModeling.h>


@protocol ORSolution <NSObject>
-(id) value: (id) var;
-(ORInt) intValue: (id<ORIntVar>) var;
-(ORBool) boolValue: (id<ORIntVar>) var;
-(ORFloat) floatValue: (id<ORFloatVar>) var;
-(id<ORObjectiveValue>) objectiveValue;
@end

@protocol ORSolutionPool <NSObject>
-(void) addSolution: (id<ORSolution>) s;
-(void) enumerateWith: (void(^)(id<ORSolution>)) block;
-(id) objectAtIndexedSubscript: (NSUInteger) key;
-(id<ORInformer>) solutionAdded;
-(id) best;
-(NSUInteger) count;
@end

@interface ORSolution : NSObject<ORSolution>
{
   NSArray*             _varShots;
   NSArray*             _cstrShots;
   id<ORObjectiveValue> _objValue;
}
-(ORSolution*) initORSolution: (id<ORModel>) model with: (id<ORASolver>) solver;
-(id) value: (id) var;
-(id<ORObjectiveValue>) objectiveValue;
@end

@interface ORSolutionPool : NSObject<ORSolutionPool> {
   NSMutableArray* _all;
   id<ORSolutionInformer> _solutionAddedInformer;
}
-(id)init;
-(void)addSolution:(id<ORSolution>)s;
-(void)enumerateWith:(void(^)(id<ORSolution>))block;
-(id<ORInformer>)solutionAdded;
-(id<ORSolution>)best;
-(id<ORSolution>) objectAtIndexedSubscript: (NSUInteger) key;
-(NSUInteger) count;
@end