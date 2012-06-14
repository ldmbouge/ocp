/************************************************************************
 MIT License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 Permission is hereby granted, free of charge, to any person obtaining
 a copy of this software and associated documentation files (the
 "Software"), to deal in the Software without restriction, including
 without limitation the rights to use, copy, modify, merge, publish,
 distribute, sublicense, and/or sell copies of the Software, and to
 permit persons to whom the Software is furnished to do so, subject to
 the following conditions:
 
 The above copyright notice and this permission notice shall be
 included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 ***********************************************************************/

#import <objc/objc-auto.h>
#import <Foundation/NSGarbageCollector.h>
#import <Foundation/NSObject.h>
#import <mpwrapper/mpwrapper.h>
#import "gurobi_c.h"

@interface LPGurobiSolver: NSObject<LPSolverWrapper>
{
@private
    struct _GRBenv*                _env;
    struct _GRBmodel*              _model;
    LPOutcome                      _status;
    LPObjectiveType                _objectiveType;
}

-(id<LPSolverWrapper>) initLPGurobiSolver;
-(void) dealloc;

-(void) addVariable: (id<LPVariable>) var;
-(void) addConstraint: (id<LPConstraint>) cstr;
-(void) delVariable: (id<LPVariable>) var;
-(void) delConstraint: (id<LPConstraint>) cstr;
-(void) addObjective: (id<LPObjective>) obj;
-(void) addColumn: (id<LPColumn>) col;
-(void) close;
-(LPOutcome) solve;

-(LPOutcome) status;
-(double) value: (id<LPVariable>) var;
-(double) lowerBound: (id<LPVariable>) var;
-(double) upperBound: (id<LPVariable>) var;
-(double) objectiveValue;
-(double) reducedCost: (id<LPVariable>) var;
-(double) dual: (id<LPConstraint>) cstr;

-(void) setBounds: (id<LPVariable>) var low: (double) low up: (double) up;
-(void) setUnboundUpperBound: (id<LPVariable>) var;
-(void) setUnboundLowerBound: (id<LPVariable>) var;

-(void) updateLowerBound: (id<LPVariable>) var lb: (double) lb;
-(void) updateUpperBound: (id<LPVariable>) var ub: (double) ub;
-(void) removeLastConstraint;
-(void) removeLastVariable;

-(void) setIntParameter: (const char*) name val: (CPInt) val;
-(void) setFloatParameter: (const char*) name val: (double) val;
-(void) setStringParameter: (const char*) name val: (char*) val;

-(void) postConstraint: (id<LPConstraint>) cstr;

-(void) printModelToFile: (char*) fileName;
-(void) print;
@end

