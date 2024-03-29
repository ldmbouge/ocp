/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

@class LPConstraintI;
@class LPObjectiveI;
@class LPColumnI;
@class LPSolverI;
@class LPVariableI;
@class LPLinearTermI;
@class LPParameterI;

typedef enum { LPgeq, LPleq, LPeq } LPConstraintType;
typedef enum { LPminimize, LPmaximize } LPObjectiveType;

@protocol LPBasis<NSObject>
-(void)restore:(LPSolverI*)solver;
@end
