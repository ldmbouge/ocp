/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/


#import <Foundation/NSObject.h>
#import <ORFoundation/ORFoundation.h>
#import <objmp/LPType.h>

@interface LPGurobiSolver: NSObject

-(LPGurobiSolver*) init;
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
-(ORDouble) value: (LPVariableI*) var;
-(ORDouble) lowerBound: (LPVariableI*) var;
-(ORDouble) upperBound: (LPVariableI*) var;
-(ORDouble) objectiveValue;
-(ORDouble) reducedCost: (LPVariableI*) var;
-(ORDouble) dual: (LPConstraintI*) cstr;

-(void) setBounds: (LPVariableI*) var low: (ORDouble) low up: (ORDouble) up;
-(void) setUnboundUpperBound: (LPVariableI*) var;
-(void) setUnboundLowerBound: (LPVariableI*) var;

-(void) updateLowerBound: (LPVariableI*) var lb: (ORDouble) lb;
-(void) updateUpperBound: (LPVariableI*) var ub: (ORDouble) ub;

-(void) setIntParameter: (const char*) name val: (ORInt) val;
-(void) setDoubleParameter: (const char*) name val: (ORDouble) val;
-(void) setStringParameter: (const char*) name val: (char*) val;

-(ORDouble) paramValue: (LPParameterI*) param;
-(void) setParam: (LPParameterI*) param value: (ORDouble)val;

-(ORStatus) postConstraint: (LPConstraintI*) cstr;

-(void) printModelToFile: (char*) fileName;
-(void) print;
@end

