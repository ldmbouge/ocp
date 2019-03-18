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
-(void) updateModel;
-(void) setTimeLimit: (double)limit;
-(ORDouble) bestObjectiveBound;
-(ORFloat) dualityGap;

-(ORDouble) dual: (MIPConstraintI*) cstr;

-(MIPOutcome) status;
-(ORDouble) doubleValue: (MIPVariableI*) var;
-(ORInt) intValue: (MIPIntVariableI*) var;
-(void) setIntVar: (MIPIntVariableI*)var value: (ORInt)val;
-(ORDouble) lowerBound: (MIPVariableI*) var;
-(ORDouble) upperBound: (MIPVariableI*) var;
-(ORDouble) objectiveValue;

-(void) setBounds: (MIPVariableI*) var low: (ORDouble) low up: (ORDouble) up;
-(void) setUnboundUpperBound: (MIPVariableI*) var;
-(void) setUnboundLowerBound: (MIPVariableI*) var;

-(void) updateLowerBound: (MIPVariableI*) var lb: (ORDouble) lb;
-(void) updateUpperBound: (MIPVariableI*) var ub: (ORDouble) ub;

-(void) setIntParameter: (const char*) name val: (ORInt) val;
-(void) setDoubleParameter: (const char*) name val: (ORDouble) val;
-(void) setStringParameter: (const char*) name val: (char*) val;

-(ORDouble) paramValue: (MIPParameterI*) param;
-(void) setParam: (MIPParameterI*) param value: (ORDouble)val;

-(ORStatus) postConstraint: (MIPConstraintI*) cstr;

-(id<ORDoubleInformer>) boundInformer;
-(void) tightenBound: (ORDouble)bnd;
-(void) injectSolution: (NSArray*)vars values: (NSArray*)vals size: (ORInt)size;
-(void) printModelToFile: (char*) fileName;
-(void) cancel;
-(void) print;
@end

