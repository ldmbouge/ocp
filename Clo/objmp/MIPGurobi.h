/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/


#import <Foundation/NSObject.h>
#import <ORFoundation/ORFoundation.h>
#import <objmp/MIPType.h>

@interface MIPGurobiSolver: NSObject

-(MIPGurobiSolver*) init;
-(void) dealloc;

-(void) addVariable: (MIPVariableI*) var;
-(MIPConstraintI*) addConstraint: (MIPConstraintI*) cstr;
-(void) delVariable: (MIPVariableI*) var;
-(void) delConstraint: (MIPConstraintI*) cstr;
-(void) addObjective: (MIPObjectiveI*) obj;
-(void) close;
-(MIPOutcome) solve;

-(MIPOutcome) status;
-(ORFloat) floatValue: (MIPVariableI*) var;
-(ORInt) intValue: (MIPIntVariableI*) var;
-(ORFloat) lowerBound: (MIPVariableI*) var;
-(ORFloat) upperBound: (MIPVariableI*) var;
-(ORFloat) objectiveValue;

-(void) setBounds: (MIPVariableI*) var low: (ORFloat) low up: (ORFloat) up;
-(void) setUnboundUpperBound: (MIPVariableI*) var;
-(void) setUnboundLowerBound: (MIPVariableI*) var;

-(void) updateLowerBound: (MIPVariableI*) var lb: (ORFloat) lb;
-(void) updateUpperBound: (MIPVariableI*) var ub: (ORFloat) ub;

-(void) setIntParameter: (const char*) name val: (ORInt) val;
-(void) setFloatParameter: (const char*) name val: (ORFloat) val;
-(void) setStringParameter: (const char*) name val: (char*) val;

-(ORStatus) postConstraint: (MIPConstraintI*) cstr;

-(void) printModelToFile: (char*) fileName;
-(void) print;
@end

