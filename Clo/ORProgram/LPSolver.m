/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

// LPSolver
#import <ORFoundation/ORFoundation.h>
#import "LPProgram.h"
#import "LPSolver.h"
#import <objmp/LPSolverI.h>

@interface LPColumn : ORObject<LPColumn>
-(id<LPColumn>) initLPColumn: (LPSolver*) lpsolver with: (LPColumnI*) col;
-(void) addObjCoef: (ORFloat) coef;
-(void) addConstraint: (id<ORConstraint>) cstr coef: (ORFloat) coef;
@end

@implementation LPColumn
{
   LPSolver* _lpsolver;
   LPColumnI* _lpcolumn;
}
-(id<LPColumn>) initLPColumn: (LPSolver*) lpsolver with: (LPColumnI*) col
{
   self = [super init];
   _lpcolumn = col;
   _lpsolver = lpsolver;
   return self;
}
-(void) dealloc
{
   [super dealloc];
}
-(LPColumnI*) column
{
   return _lpcolumn;
}
-(void) addObjCoef: (ORFloat) coef
{
   [_lpcolumn addObjCoef: coef];
}
-(void) addConstraint: (id<ORConstraint>) cstr coef: (ORFloat) coef
{
   [_lpcolumn addConstraint: [_lpsolver concretize: cstr] coef: coef];
}
@end

@implementation LPSolver
{
   LPSolverI*  _lpsolver;
   id<ORModel> _model;
   id<ORSolutionPool> _sPool;
}
-(id<LPProgram>) initLPSolver: (id<ORModel>) model
{
   self = [super init];
   _lpsolver = [LPFactory solver];
   _model = model;
   _sPool = (id<ORSolutionPool>) [ORFactory createSolutionPool];
   return self;
}
-(void) dealloc
{
   NSLog(@"dealloc LPSolver");
   [_lpsolver release];
   [_sPool release];
   [super dealloc];
}
-(id<ORTracker>)tracker
{
   return self;
}
-(void)close
{}
-(id<OREngine>) engine
{
   return _lpsolver;
}
-(LPSolverI*) solver
{
   return _lpsolver;
}
-(void) solve
{
   [_lpsolver solve];
   id<ORSolution> sol = [self captureSolution];
   [_sPool addSolution: sol];
   [sol release];
}
-(ORFloat) dual: (id<ORConstraint>) c
{
   return [_lpsolver dual: [self concretize: c]];
}
-(ORFloat) floatValue: (id<ORFloatVar>) v
{
   return [_lpsolver floatValue: _gamma[v.getId]];
}
-(ORFloat) reducedCost: (id<ORFloatVar>) v
{
   return [_lpsolver reducedCost: _gamma[v.getId]];
}
-(id<LPColumn>) createColumn
{
   LPColumnI* col = [_lpsolver createColumn];
   id<LPColumn> o = [[LPColumn alloc] initLPColumn: self with: col];
   [self trackMutable: o];
   return o;
}
-(id<LPColumn>) createColumn: (ORFloat) low up: (ORFloat) up
{
   LPColumnI* col = [_lpsolver createColumn: low up: up];
   id<LPColumn> o = [[LPColumn alloc] initLPColumn: self with: col];
   [self trackMutable: o];
   return o;
}

-(void) addColumn: (LPColumn*) column
{
   [_lpsolver postColumn: [column column]];
   id<ORSolution> sol = [self captureSolution];
   [_sPool addSolution: sol];
   [sol release];
}
-(id) trackObject: (id) obj
{
   return [_lpsolver trackObject:obj];
}
-(id) trackConstraintInGroup:(id)obj
{
   return [_lpsolver trackConstraintInGroup:obj];
}
-(id) trackObjective: (id) obj
{
   return [_lpsolver trackObjective:obj];
}
-(id) trackMutable: (id) obj
{
   return [_lpsolver trackMutable:obj];
}
-(id) trackVariable: (id) obj
{
   return [_lpsolver trackVariable:obj];
}
-(id) trackImmutable:(id)obj
{
   return [_lpsolver trackImmutable:obj];
}
-(id<ORSolutionPool>) solutionPool
{
   return _sPool;
}
-(id<ORObjectiveValue>) objectiveValue
{
   return [_lpsolver objectiveValue];
}
-(id<ORSolution>) captureSolution
{
   return [ORFactory solution: _model solver: self];
}
@end


@implementation LPRelaxation
{
   LPSolverI*  _lpsolver;
   id<ORModel> _model;
}
-(id<LPRelaxation>) initLPRelaxation: (id<ORModel>) model
{
   self = [super init];
   _lpsolver = [LPFactory solver];
   _model = model;
   return self;
}
-(void) dealloc
{
   NSLog(@"dealloc LPSolver");
   [_lpsolver release];
   [super dealloc];
}
-(id<ORTracker>)tracker
{
   return self;
}
-(void)close
{}
-(id<OREngine>) engine
{
   return _lpsolver;
}
-(LPSolverI*) solver
{
   return _lpsolver;
}
-(OROutcome) solve
{
   return [_lpsolver solve];
}
-(ORFloat) dual: (id<ORConstraint>) c
{
   return [_lpsolver dual: [self concretize: c]];
}
-(ORFloat) floatValue: (id<ORFloatVar>) v
{
   return [_lpsolver floatValue: _gamma[v.getId]];
}
-(ORFloat) reducedCost: (id<ORFloatVar>) v
{
   return [_lpsolver reducedCost: _gamma[v.getId]];
}
-(ORFloat) objective
{
   return [_lpsolver lpValue];
}
-(id<ORObjectiveValue>) objectiveValue
{
   return [_lpsolver objectiveValue];
}
-(ORFloat) lowerBound: (id<ORVar>) v
{
   return [_lpsolver lowerBound: _gamma[v.getId]];
}
-(ORFloat) upperBound: (id<ORVar>) v
{
   return [_lpsolver upperBound: _gamma[v.getId]];
}
-(void) updateLowerBound: (id<ORVar>) v with: (ORFloat) lb
{
   [_lpsolver updateLowerBound: _gamma[v.getId] lb: lb];
}
-(void) updateUpperBound: (id<ORVar>) v with: (ORFloat) ub
{
   [_lpsolver updateUpperBound: _gamma[v.getId] ub: ub];
}
-(id) trackObject: (id) obj
{
   return [_lpsolver trackObject:obj];
}
-(id) trackConstraintInGroup:(id)obj
{
   return [_lpsolver trackConstraintInGroup:obj];
}
-(id) trackObjective: (id) obj
{
   return [_lpsolver trackObjective:obj];
}
-(id) trackMutable: (id) obj
{
   return [_lpsolver trackMutable:obj];
}
-(id) trackVariable: (id) obj
{
   return [_lpsolver trackVariable:obj];
}
-(id) trackImmutable:(id) obj
{
   return [_lpsolver trackImmutable:obj];
}
@end

@implementation ORSolution (LPSolver)
-(ORFloat) dual: (id<ORConstraint>) c
{
   NSUInteger idx = [_varShots indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
      return [obj getId] == [c getId];
   }];
   id snap = [_varShots objectAtIndex:idx];
   return [snap dual];
}
-(ORFloat) reducedCost: (id<ORFloatVar>) x
{
   NSUInteger idx = [_varShots indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
      return [obj getId] == [x getId];
   }];
   id snap = [_varShots objectAtIndex:idx];
   return [snap reducedCost];
}
@end



@implementation LPSolverFactory
+(id<LPProgram>) solver: (id<ORModel>) model
{
   return [[LPSolver alloc] initLPSolver: model];
}
+(id<LPRelaxation>) relaxation: (id<ORModel>) model
{
   return [[LPRelaxation alloc] initLPRelaxation: model];
}
@end

