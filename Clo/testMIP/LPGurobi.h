/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/


#import <Foundation/NSObject.h>
#import <ORFoundation/ORFoundation.h>
#import "gurobi_c.h"
#import "LPType.h"


@interface LPGurobiSolver: NSObject
{
@private
   struct _GRBenv*                _env;
   struct _GRBmodel*              _model;
   LPOutcome                      _status;
   LPObjectiveType                _objectiveType;
}

-(LPGurobiSolver*) initLPGurobiSolver;
-(void) dealloc;

-(void) addVariable: (LPVariableI*) var;
-(void) addConstraint: (LPConstraintI*) cstr;
-(void) delVariable: (LPVariableI*) var;
-(void) delConstraint: (LPConstraintI*) cstr;
-(void) addObjective: (LPObjectiveI*) obj;
-(void) addColumn: (LPColumnI*) col;
-(void) close;
-(LPOutcome) solve;

-(LPOutcome) status;
-(double) value: (LPVariableI*) var;
-(double) lowerBound: (LPVariableI*) var;
-(double) upperBound: (LPVariableI*) var;
-(double) objectiveValue;
-(double) reducedCost: (LPVariableI*) var;
-(double) dual: (LPConstraintI*) cstr;

-(void) setBounds: (LPVariableI*) var low: (double) low up: (double) up;
-(void) setUnboundUpperBound: (LPVariableI*) var;
-(void) setUnboundLowerBound: (LPVariableI*) var;

-(void) updateLowerBound: (LPVariableI*) var lb: (double) lb;
-(void) updateUpperBound: (LPVariableI*) var ub: (double) ub;

-(void) setIntParameter: (const char*) name val: (ORInt) val;
-(void) setFloatParameter: (const char*) name val: (double) val;
-(void) setStringParameter: (const char*) name val: (char*) val;

-(void) postConstraint: (LPConstraintI*) cstr;

-(void) printModelToFile: (char*) fileName;
-(void) print;
@end

