/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/


#import <objc/objc-auto.h>
#import <Foundation/NSObject.h>
#import <objlp/LPSolver.h>


@protocol LPMatrixSolver <NSObject>

-(void) addVariable: (id<LPVariable>) var;
-(void) addConstraint: (id<LPConstraint>) cstr;
-(void) delConstraint: (id<LPConstraint>) cstr;
-(void) delVariable: (id<LPVariable>) var;
-(void) addObjective: (id<LPObjective>) obj;
-(void) addColumn: (id<LPColumn>) col;

-(void) close;
-(LPOutcome) solve;

-(LPOutcome) status;
-(double) value: (id<LPVariable>) var;
-(double) lowerBound: (id<LPVariable>) var;
-(double) upperBound: (id<LPVariable>) var;
-(double) reducedCost: (id<LPVariable>) var;
-(double) dual: (id<LPConstraint>) cstr;
-(double) objectiveValue;

-(void) setBounds: (id<LPVariable>) var low: (double) low up: (double) up;
-(void) setUnboundUpperBound: (id<LPVariable>) var;
-(void) setUnboundLowerBound: (id<LPVariable>) var;

-(void) updateLowerBound: (id<LPVariable>) var lb: (double) lb;
-(void) updateUpperBound: (id<LPVariable>) var ub: (double) ub;
-(void) removeLastConstraint;
-(void) removeLastVariable;

-(void) setIntParameter: (const char*) name val: (ORInt) val;
-(void) setFloatParameter: (const char*) name val: (double) val;
-(void) setStringParameter: (const char*) name val: (char*) val;

-(void) print;
-(void) printModelToFile: (char*) fileName;

//-(CotLPAbstractBasis)* getBasis() ;
//-(void) setBasis(CotLPAbstractBasis* basis) ;

@end

@protocol LPMatrixSolverExecutionError <NSObject>
-(char*) getMsg;
@end

