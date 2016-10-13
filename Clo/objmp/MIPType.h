/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

@class MIPConstraintI;
@class MIPObjectiveI;
@class MIPSolverI;
@class MIPVariableI;
@class MIPIntVariableI;
@class MIPLinearTermI;
@class MIPParameterI;

typedef enum { MIPinfeasible, MIPoptimal, MIPsuboptimal, MIPunbounded, MIPerror} MIPOutcome;
typedef enum { MIPgeq, MIPleq, MIPeq } MIPConstraintType;
typedef enum { MIPminimize, MIPmaximize } MIPObjectiveType;
