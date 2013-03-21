/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "LPGurobi.h"
#import <objmp/LPType.h>
#import <objmp/LPSolverI.h>



@implementation LPGurobiSolver;

-(LPGurobiSolver*) initLPGurobiSolver
{
   [super init];
   int error = GRBloadenv(&_env, "");
   if (error) {
      @throw [[NSException alloc] initWithName:@"Gurobi Solver Error"
                                        reason:@"Gurobi cannot create its environment"
                                      userInfo:nil];
   }
   GRBnewmodel(_env, &_model, "", 0, NULL, NULL, NULL, NULL, NULL);
   return self;
}

-(void) dealloc
{
   GRBfreemodel(_model);
   GRBfreeenv(_env);
   [super dealloc];
}

-(void) addVariable: (LPVariableI*) var;
{
   if ([var hasBounds])
      GRBaddvar(_model, 0,NULL, NULL, 0.0, [var low], [var up],GRB_CONTINUOUS,NULL);
   else
      GRBaddvar(_model, 0,NULL, NULL, 0.0, 0.0, GRB_INFINITY,GRB_CONTINUOUS,NULL);
   GRBupdatemodel(_model);
}

-(void) addConstraint: (LPConstraintI*) cstr
{
   [self postConstraint: cstr];
   GRBupdatemodel(_model);
}
-(void) delConstraint: (LPConstraintI*) cstr
{
   int todel[] = { [cstr idx] };
   GRBdelconstrs(_model,1,todel);
   GRBupdatemodel(_model);
}
-(void) delVariable: (LPVariableI*) var
{
   int todel[] = { [var idx] };
   GRBdelvars(_model,1,todel);
   GRBupdatemodel(_model);
}
-(void) addObjective: (LPObjectiveI*) obj
{
   int s = [obj size];
   int* idx = [obj col];
   ORFloat* coef = [obj coef];
   _objectiveType = [obj type];
   for(ORInt i = 0; i < s; i++)
      if (_objectiveType == LPminimize)
         GRBsetdblattrelement(_model,"Obj",idx[i],coef[i]);
      else
         GRBsetdblattrelement(_model,"Obj",idx[i],-coef[i]);
}

-(void) addColumn: (LPColumnI*) col
{
   ORFloat o = [col objCoef];
   if (_objectiveType == LPmaximize)
      o = -o;
   GRBaddvar(_model,[col size],[col cstrIdx],[col coef],o,[col low],[col up],GRB_CONTINUOUS,NULL);
   GRBupdatemodel(_model);
}

-(void) close
{
   
}
-(LPOutcome) solve
{
   //int error = GRBsetintparam(GRBgetenv(_model), "PRESOLVE", 0);
   GRBoptimize(_model);
   [self printModelToFile: "/Users/ldm/lookatgurobi.lp"];
   int status;
   GRBgetintattr(_model,"Status",&status);
   switch (status) {
      case GRB_OPTIMAL:
         _status = LPoptimal;
         break;
      case GRB_INFEASIBLE:
         _status = LPinfeasible;
         break;
      case GRB_SUBOPTIMAL:
         _status = LPsuboptimal;
         break;
      case GRB_UNBOUNDED:
         _status = LPunbounded;
         break;
      default:
         _status = LPerror;
   }
   return _status;
}

-(LPOutcome) status
{
   return _status;
}

-(ORFloat) value: (LPVariableI*) var
{
   ORFloat value;
   GRBgetdblattrelement(_model,"X",[var idx],&value);
   return value;
}

-(ORFloat) lowerBound: (LPVariableI*) var
{
   ORFloat value;
   GRBgetdblattrelement(_model,"LB",[var idx],&value);
   return value;
}

-(ORFloat) upperBound: (LPVariableI*) var
{
   ORFloat value;
   GRBgetdblattrelement(_model,"UB",[var idx],&value);
   return value;
}

-(ORFloat) objectiveValue
{
   ORFloat objVal;
   GRBgetdblattr(_model,"ObjVal",&objVal);
   if (_objectiveType == LPmaximize)
      return -objVal;
   else
      return objVal;
}

-(ORFloat) reducedCost: (LPVariableI*) var
{
   ORFloat value;
   GRBgetdblattrelement(_model,"RC",[var idx],&value);
   return value;
}

-(ORFloat) dual: (LPConstraintI*) cstr
{
   ORFloat value;
   GRBgetdblattrelement(_model,"Pi",[cstr idx],&value);
   return value;
}

-(void) setBounds: (LPVariableI*) var low: (ORFloat) low up: (ORFloat) up
{
   GRBsetdblattrelement(_model,"LB",[var idx],low);
   GRBsetdblattrelement(_model,"UB",[var idx],low);
}

-(void) setUnboundUpperBound: (LPVariableI*) var
{
   GRBsetdblattrelement(_model,"UB",[var idx],1e21);
}

-(void) setUnboundLowerBound: (LPVariableI*) var
{
   GRBsetdblattrelement(_model,"LB",[var idx],-1e21);
}

-(void) updateLowerBound: (LPVariableI*) var lb: (ORFloat) lb
{
   if (lb > [self lowerBound: var])
      GRBsetdblattrelement(_model,"LB",[var idx],lb);
}

-(void) updateUpperBound: (LPVariableI*) var ub: (ORFloat) ub
{
   if (ub < [self upperBound: var])
      GRBsetdblattrelement(_model,"UB",[var idx],ub);
}

-(void) setIntParameter: (const char*) name val: (ORInt) val
{
   GRBsetintparam(_env,name,val);
}

-(void) setFloatParameter: (const char*) name val: (ORFloat) val
{
   GRBsetdblparam(_env,name,val);
}

-(void) setStringParameter: (const char*) name val: (char*) val
{
   GRBsetstrparam(_env,name,val);
}

-(void) postConstraint: (LPConstraintI*) cstr
{
   switch ([cstr type]) {
      case LPleq:
         GRBaddconstr(_model,[cstr size],[cstr col],[cstr coef],GRB_LESS_EQUAL,[cstr rhs],NULL);
         break;
      case LPgeq:
         GRBaddconstr(_model,[cstr size],[cstr col],[cstr coef],GRB_GREATER_EQUAL,[cstr rhs],NULL);
         break;
      case LPeq:
         GRBaddconstr(_model,[cstr size],[cstr col],[cstr coef],GRB_EQUAL,[cstr rhs],NULL);
         break;
      default:
         break;
   }
}

-(void) print
{
   int nbConstraints;
   GRBgetintattr(_model,"NumConstrs",&nbConstraints);
   int nbVars;
   GRBgetintattr(_model,"NumVars",&nbVars);
   printf("LPGurobiSolver with %d variables and %d constraints \n",nbVars,nbConstraints);
}

-(void) printModelToFile: (char*) fileName
{
   GRBwrite(_model,fileName);
}

@end


