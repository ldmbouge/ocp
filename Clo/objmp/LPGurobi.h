/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/


#import <Foundation/NSObject.h>
#import <ORFoundation/ORFoundation.h>
#import <objmp/LPType.h>
#import "gurobi_c.h"


@interface LPGurobiSolver: NSObject
{
@private
   struct _GRBenv*                _env;
   struct _GRBmodel*              _model;
   OROutcome                      _status;
   LPObjectiveType                _objectiveType;
}

-(LPGurobiSolver*) initLPGurobiSolver;
-(void) dealloc;

-(void) addVariable: (LPVariableI*) var;
-(LPConstraintI*) addConstraint: (LPConstraintI*) cstr;
-(void) delVariable: (LPVariableI*) var;
-(void) delConstraint: (LPConstraintI*) cstr;
-(void) addObjective: (LPObjectiveI*) obj;
-(void) addColumn: (LPColumnI*) col;
-(void) close;
-(OROutcome) solve;

-(OROutcome) status;
-(ORFloat) value: (LPVariableI*) var;
-(ORFloat) lowerBound: (LPVariableI*) var;
-(ORFloat) upperBound: (LPVariableI*) var;
-(ORFloat) objectiveValue;
-(ORFloat) reducedCost: (LPVariableI*) var;
-(ORFloat) dual: (LPConstraintI*) cstr;

-(void) setBounds: (LPVariableI*) var low: (ORFloat) low up: (ORFloat) up;
-(void) setUnboundUpperBound: (LPVariableI*) var;
-(void) setUnboundLowerBound: (LPVariableI*) var;

-(void) updateLowerBound: (LPVariableI*) var lb: (ORFloat) lb;
-(void) updateUpperBound: (LPVariableI*) var ub: (ORFloat) ub;

-(void) setIntParameter: (const char*) name val: (ORInt) val;
-(void) setFloatParameter: (const char*) name val: (ORFloat) val;
-(void) setStringParameter: (const char*) name val: (char*) val;

-(void) postConstraint: (LPConstraintI*) cstr;

-(void) printModelToFile: (char*) fileName;
-(void) print;
@end

