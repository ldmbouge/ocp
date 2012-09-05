/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <Foundation/Foundation.h>
#import <ORFoundation/ORFoundation.h>
#import <lpwrapper/LPWrapper.h>

@protocol LPSolver <NSObject>
-(id<LPVariable>)   createVariable;
-(id<LPVariable>)   createVariable: (ORFloat) low up: (ORFloat) up;
-(id<LPColumn>)     createColumn: (ORFloat) low up: (ORFloat) up size: (ORInt) size obj: (ORFloat) obj cstr: (id<LPConstraint>*) idx coef: (ORFloat*) coef;
-(id<LPColumn>)     createColumn: (ORFloat) low up: (ORFloat) up;

-(id<LPLinearTerm>) createLinearTerm;
-(id<LPLinearTerm>) createLinearTerm:(IRange) R coef: (LPInt2Float) c var: (LPInt2Var) v;

-(id<LPConstraint>) createLEQ: (ORInt) size var: (id<LPVariable>*) var coef: (ORFloat*) coef rhs: (ORFloat) rhs;
-(id<LPConstraint>) createGEQ: (ORInt) size var: (id<LPVariable>*) var coef: (ORFloat*) coef rhs: (ORFloat) rhs;
-(id<LPConstraint>) createEQ: (ORInt) size var: (id<LPVariable>*) var coef: (ORFloat*) coef rhs: (ORFloat) rhs;
-(id<LPObjective>)  createMinimize: (ORInt) size var: (id<LPVariable>*) var coef: (ORFloat*) coef;
-(id<LPObjective>)  createMaximize: (ORInt) size var: (id<LPVariable>*) var coef: (ORFloat*) coef;

-(id<LPConstraint>) createLEQ: (id<LPLinearTerm>) t rhs: (ORFloat) rhs;
-(id<LPConstraint>) createGEQ: (id<LPLinearTerm>) t rhs: (ORFloat) rhs;
-(id<LPConstraint>) createEQ:  (id<LPLinearTerm>) t  rhs: (ORFloat) rhs;
-(id<LPObjective>)  createMinimize: (id<LPLinearTerm>) t;
-(id<LPObjective>)  createMaximize: (id<LPLinearTerm>) t;

-(id<LPConstraint>) postConstraint: (id<LPConstraint>) cstr;
-(void) removeConstraint: (id<LPConstraint>) cstr;
-(void) removeVariable: (id<LPVariable>) var;
-(id<LPObjective>) postObjective: (id<LPObjective>) obj;
-(id<LPVariable>) postColumn: (id<LPColumn>) col;

-(void) close;
-(bool) isClosed;
-(LPOutcome) solve;
-(LPOutcome) status;

-(void) setIntParameter: (const char*) name val: (ORInt) val;
-(void) setFloatParameter: (const char*) name val: (ORFloat) val;
-(void) setStringParameter: (const char*) name val: (char*) val;

-(void) print;
-(void) printModelToFile: (char*) fileName;

//-(CotLPAbstractBasis)* getBasis() ;
//-(void) setBasis(CotLPAbstractBasis* basis) ;

@end

