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

@interface LPColumn : ORModelingObjectI<LPColumn>
-(id<LPColumn>) initLPColumn: (LPSolver*) lpsolver with: (LPColumnI*) col;
-(void) addObjCoef: (ORFloat) coef;
-(void) addConstraint: (id<ORConstraint>) cstr coef: (ORFloat) coef;
@end

@implementation LPColumn
{
   LPSolver* _lpsolver;
}
-(id<LPColumn>) initLPColumn: (LPSolver*) lpsolver with: (LPColumnI*) col
{
   self = [super init];
   _impl = col;
   _lpsolver = lpsolver;
   return self;
}
-(void) addObjCoef: (ORFloat) coef
{
   [(LPColumnI*)_impl addObjCoef: coef];
}
// pvh to fix: will need more interesting dereference once we have multiple clones
-(void) addConstraint: (id<ORConstraint>) cstr coef: (ORFloat) coef
{
   [(LPColumnI*) _impl addConstraint: [cstr dereference] coef: coef];
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
#if defined(__linux__)
   _lpsolver = NULL;
#else
   _lpsolver = [LPFactory solver];
   _model = model;
#endif
   _sPool = [ORFactory createSolutionPool];
   return self;
}
-(void) dealloc
{
   NSLog(@"LPSolver dealloc");
   [_lpsolver release];
   [_sPool release];
   [super dealloc];
}
-(LPSolverI*) solver
{
   return _lpsolver;
}
-(void) solve
{
   [_lpsolver solve];
   id<ORSolution> s = [_model captureSolution];
   [_sPool addSolution: s];
//   NSLog(@"Solution = %@",s);
}
-(ORFloat) dual: (id<ORConstraint>) c
{
   return [_lpsolver dual: [c dereference]];
}
-(ORFloat) reducedCost: (id<ORFloatVar>) v
{
   return [_lpsolver reducedCost: [v dereference]];
}
-(id<LPColumn>) createColumn
{
   LPColumnI* col = [_lpsolver createColumn];
   id<LPColumn> o = [[LPColumn alloc] initLPColumn: self with: col];
   [self trackObject: o];
   return o;
}
-(id<LPColumn>) createColumn: (ORFloat) low up: (ORFloat) up
{
   LPColumnI* col = [_lpsolver createColumn: low up: up];
   id<LPColumn> o = [[LPColumn alloc] initLPColumn: self with: col];
   [self trackObject: o];
   return o;
}

-(void) addColumn: (LPColumn*) column
{
   [_lpsolver postColumn: [column impl]];
   id<ORSolution> s = [_model captureSolution];
   [_sPool addSolution: s];
}
-(void) trackObject: (id) obj
{
   [_lpsolver trackObject:obj];
}
-(void) trackVariable: (id) obj
{
   [_lpsolver trackVariable:obj];
}
-(void) trackConstraint:(id) obj
{
   [_lpsolver trackConstraint:obj];
}
-(id<ORSolutionPool>) solutionPool
{
   return _sPool;
}
-(id<ORSolutionPool>) globalSolutionPool
{
   return _sPool;
}

@end


@implementation LPSolverFactory
+(id<LPProgram>) solver: (id<ORModel>) model
{
   return [[LPSolver alloc] initLPSolver: model];
}
@end
