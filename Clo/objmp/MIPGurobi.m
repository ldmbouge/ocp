/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "MIPGurobi.h"
#import <objmp/MIPType.h>
#import <objmp/MIPSolverI.h>

@implementation MIPGurobiSolver;

-(MIPGurobiSolver*) initMIPGurobiSolver
{
   self = [super init];
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

-(void) addVariable: (MIPVariableI*) var;
{
   if ([var isInteger]) {
      if ([var hasBounds])
        GRBaddvar(_model, 0,NULL, NULL, 0.0, [var low], [var up],GRB_INTEGER,NULL);
      else
         GRBaddvar(_model, 0,NULL, NULL, 0.0, 0.0, GRB_INFINITY,GRB_INTEGER,NULL);
   }
   else if ([var hasBounds])
      GRBaddvar(_model, 0,NULL, NULL, 0.0, [var low], [var up],GRB_CONTINUOUS,NULL);
   else
      GRBaddvar(_model, 0,NULL, NULL, 0.0, 0.0, GRB_INFINITY,GRB_CONTINUOUS,NULL);
   GRBupdatemodel(_model);
}

-(MIPConstraintI*) addConstraint: (MIPConstraintI*) cstr
{
   [self postConstraint: cstr];
   GRBupdatemodel(_model);
   return cstr;
}
-(void) delConstraint: (MIPConstraintI*) cstr
{
   int todel[] = { [cstr idx] };
   GRBdelconstrs(_model,1,todel);
   GRBupdatemodel(_model);
}
-(void) delVariable: (MIPVariableI*) var
{
   int todel[] = { [var idx] };
   GRBdelvars(_model,1,todel);
   GRBupdatemodel(_model);
}
-(void) addObjective: (MIPObjectiveI*) obj
{
   int s = [obj size];
   int* idx = [obj col];
   ORFloat* coef = [obj coef];
   _objectiveType = [obj type];
   for(ORInt i = 0; i < s; i++)
      if (_objectiveType == MIPminimize)
         GRBsetdblattrelement(_model,"Obj",idx[i],coef[i]);
      else
         GRBsetdblattrelement(_model,"Obj",idx[i],-coef[i]);
}

-(void) close
{
   
}
-(MIPOutcome) solve
{
   //int error = GRBsetintparam(GRBgetenv(_model), "PRESOLVE", 0);
    GRBupdatemodel(_model);
    [self printModelToFile: "/Users/dan/Desktop/lookatgurobi.lp"];
    GRBoptimize(_model);
   int status;
   GRBgetintattr(_model,"Status",&status);
   switch (status) {
      case GRB_OPTIMAL:
         _status = MIPoptimal;
         break;
      case GRB_INFEASIBLE:
         _status = MIPinfeasible;
         break;
      case GRB_SUBOPTIMAL:
         _status = MIPsuboptimal;
         break;
      case GRB_UNBOUNDED:
         _status = MIPunbounded;
         break;
      default:
         _status = MIPerror;
   }
   return _status;
}

-(void) setTimeLimit: (double)limit {
    struct _GRBenv* env = GRBgetenv(_model);
    GRBsetdblparam(env, GRB_DBL_PAR_TIMELIMIT, limit);
}

-(MIPOutcome) status
{
   return _status;
}

-(ORInt) intValue: (MIPIntVariableI*) var
{
   ORFloat value;
   GRBgetdblattrelement(_model,"X",[var idx],&value);
   return (ORInt) value;
}

-(void) setIntVar: (MIPIntVariableI*)var value: (ORInt)val {
    int error = GRBsetdblattrelement(_model, GRB_DBL_ATTR_LB, [var idx], val);
    error = GRBsetdblattrelement(_model, GRB_DBL_ATTR_UB, [var idx], val) || error ;
    GRBupdatemodel(_model);
    if(error != 0) NSLog(@"err: %i", error);
}

-(ORFloat) floatValue: (MIPVariableI*) var
{
   ORFloat value;
   GRBgetdblattrelement(_model,"X",[var idx],&value);
   return value;
}

-(void) setFloatVar: (MIPVariableI*)var value: (ORFloat)val {
}


-(ORFloat) lowerBound: (MIPVariableI*) var
{
   ORFloat value;
   GRBgetdblattrelement(_model,"LB",[var idx],&value);
   return value;
}

-(ORFloat) upperBound: (MIPVariableI*) var
{
   ORFloat value;
   GRBgetdblattrelement(_model,"UB",[var idx],&value);
   return value;
}
-(ORFloat) objectiveValue
{
   ORFloat objVal;
   GRBgetdblattr(_model,"ObjVal",&objVal);
   if (_objectiveType == MIPmaximize)
      return -objVal;
   else
      return objVal;
}
-(ORFloat) bestObjectiveBound {
    ORFloat bnd;
    GRBgetdblattr(_model, "ObjBound", &bnd);
    return bnd;
}
-(ORFloat) paramFloatValue: (MIPParameterI*) param
{
    ORFloat v;
    int err = GRBgetcoeff(_model, [param cstrIdx], [param coefIdx], &v);
    if(err != 0) return DBL_MAX;
    return v;
}
-(void) setParam: (MIPParameterI*) param value: (ORFloat)val
{
    int cind[] = { [param cstrIdx] };
    int vind[] = { [param coefIdx] };
    double v[] = { val };
    int err = GRBchgcoeffs(_model, 1, cind, vind, v);
    GRBupdatemodel(_model);
    if(err != 0)
        NSLog(@"error setting gurobi parameter: %i", err);
}
-(void) setBounds: (MIPVariableI*) var low: (ORFloat) low up: (ORFloat) up
{
   GRBsetdblattrelement(_model,"LB",[var idx],low);
   GRBsetdblattrelement(_model,"UB",[var idx],up);
}

-(void) setUnboundUpperBound: (MIPVariableI*) var
{
   GRBsetdblattrelement(_model,"UB",[var idx],1e21);
}

-(void) setUnboundLowerBound: (MIPVariableI*) var
{
   GRBsetdblattrelement(_model,"LB",[var idx],-1e21);
}

-(void) updateLowerBound: (MIPVariableI*) var lb: (ORFloat) lb
{
   if (lb > [self lowerBound: var])
      GRBsetdblattrelement(_model,"LB",[var idx],lb);
}

-(void) updateUpperBound: (MIPVariableI*) var ub: (ORFloat) ub
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

-(ORStatus) postConstraint: (MIPConstraintI*) cstr
{
   switch ([cstr type]) {
      case MIPleq:
         GRBaddconstr(_model,[cstr size],[cstr col],[cstr coef],GRB_LESS_EQUAL,[cstr rhs],NULL);
         break;
      case MIPgeq:
         GRBaddconstr(_model,[cstr size],[cstr col],[cstr coef],GRB_GREATER_EQUAL,[cstr rhs],NULL);
         break;
      case MIPeq:
         GRBaddconstr(_model,[cstr size],[cstr col],[cstr coef],GRB_EQUAL,[cstr rhs],NULL);
         break;
      default:
         break;
   }
   return ORSuspend;
}

-(void) print
{
   int nbConstraints;
   GRBgetintattr(_model,"NumConstrs",&nbConstraints);
   int nbVars;
   GRBgetintattr(_model,"NumVars",&nbVars);
   printf("MIPGurobiSolver with %d variables and %d constraints \n",nbVars,nbConstraints);
}

-(void) printModelToFile: (char*) fileName
{
   GRBwrite(_model,fileName);
}

@end


