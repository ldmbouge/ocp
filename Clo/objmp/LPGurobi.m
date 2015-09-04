/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <objmp/LPGurobi.h>
#import <objmp/LPType.h>
#import <objmp/LPSolverI.h>
#import "gurobi_c.h"


@implementation LPGurobiSolver {
   struct _GRBenv*                _env;
   struct _GRBmodel*              _model;
   OROutcome                      _status;
   LPObjectiveType                _objectiveType;
}

-(LPGurobiSolver*) init
{
   self = [super init];
   int error = GRBloadenv(&_env, "");
   GRBsetintparam(_env,GRB_INT_PAR_OUTPUTFLAG,0);
   GRBsetintparam(_env,GRB_INT_PAR_LOGTOCONSOLE,0);
   if (error) {
      @throw [[NSException alloc] initWithName:@"Gurobi Solver Error"
                                        reason:@"Gurobi cannot create its environment"
                                      userInfo:nil];
   }
   GRBnewmodel(_env, &_model, "", 0, NULL, NULL, NULL, NULL, NULL);
//   GRBsetintparam(_env,"OutputFlag",0);

   
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

-(LPConstraintI*) addConstraint: (LPConstraintI*) cstr
{
   [self postConstraint: cstr];
   GRBupdatemodel(_model);
   return cstr;
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
   ORDouble* coef = [obj coef];
   _objectiveType = [obj type];
   for(ORInt i = 0; i < s; i++)
      GRBsetdblattrelement(_model,"Obj",idx[i],coef[i]);
   if (_objectiveType == LPminimize)
      GRBsetintattr(_model, "ModelSense", 1);
   else
      GRBsetintattr(_model, "ModelSense", -1);
}

-(void) addColumn: (LPColumnI*) col
{
   ORDouble o = [col objCoef];
   if (_objectiveType == LPmaximize)
      o = -o;
   if ([col hasBounds])
      GRBaddvar(_model,[col size],[col cstrIdx],[col coef],o,[col low],[col up],GRB_CONTINUOUS,NULL);
   else
      GRBaddvar(_model,[col size],[col cstrIdx],[col coef],o,0.0,GRB_INFINITY,GRB_CONTINUOUS,NULL);
   GRBupdatemodel(_model);
}

-(void) close
{
   
}
-(OROutcome) solve
{
   //int error = GRBsetintparam(GRBgetenv(_model), "PRESOLVE", 0);
//   for(ORInt i = 0; i < 12; i++) {
//      ORDouble lb;
//      GRBgetdblattrelement(_model,"LB",i,&lb);
//      ORDouble ub;
//      GRBgetdblattrelement(_model,"UB",i,&ub);
//      printf("Variable %i has bounds in lp: [%f,%f] \n",i,lb,ub);
//   }
//   printf("\n");
   GRBoptimize(_model);
//   [self printModelToFile: "/Users/pvh/lookatgurobi.lp"];
   int status;
   GRBgetintattr(_model,"Status",&status);
   switch (status) {
      case GRB_OPTIMAL:
         _status = ORoptimal;
         break;
      case GRB_INFEASIBLE:
         _status = ORinfeasible;
         break;
      case GRB_SUBOPTIMAL:
         _status = ORsuboptimal;
         break;
      case GRB_UNBOUNDED:
         _status = ORunbounded;
         break;
      default:
         _status = ORerror;
   }
   return _status;
}

-(OROutcome) status
{
   return _status;
}

-(ORDouble) value: (LPVariableI*) var
{
   ORDouble value;
   GRBgetdblattrelement(_model,"X",[var idx],&value);
   return value;
}

-(ORDouble) lowerBound: (LPVariableI*) var
{
   ORDouble value;
   GRBgetdblattrelement(_model,"LB",[var idx],&value);
   return value;
}

-(ORDouble) upperBound: (LPVariableI*) var
{
   ORDouble value;
   GRBgetdblattrelement(_model,"UB",[var idx],&value);
   return value;
}

-(ORDouble) objectiveValue
{
   ORDouble objVal;
   GRBgetdblattr(_model,"ObjVal",&objVal);
   return objVal;
}

-(ORDouble) reducedCost: (LPVariableI*) var
{
   ORDouble value;
   GRBgetdblattrelement(_model,"RC",[var idx],&value);
   return value;
}

-(ORDouble) dual: (LPConstraintI*) cstr
{
   ORDouble value;
   GRBgetdblattrelement(_model,"PI",[cstr idx],&value);
   return value;
}

-(void) setBounds: (LPVariableI*) var low: (ORDouble) low up: (ORDouble) up
{
   GRBsetdblattrelement(_model,"LB",[var idx],low);
   GRBsetdblattrelement(_model,"UB",[var idx],low);
   GRBupdatemodel(_model);
}

-(void) setUnboundUpperBound: (LPVariableI*) var
{
   GRBsetdblattrelement(_model,"UB",[var idx],1e21);
   GRBupdatemodel(_model);
}

-(void) setUnboundLowerBound: (LPVariableI*) var
{
   GRBsetdblattrelement(_model,"LB",[var idx],-1e21);
   GRBupdatemodel(_model);
}

-(void) updateLowerBound: (LPVariableI*) var lb: (ORDouble) lb
{
//   if (lb > [self lowerBound: var])
   GRBsetdblattrelement(_model,"LB",[var idx],lb);
   GRBupdatemodel(_model);
}

-(void) updateUpperBound: (LPVariableI*) var ub: (ORDouble) ub
{
//   if (ub < [self upperBound: var])
   GRBsetdblattrelement(_model,"UB",[var idx],ub);
   GRBupdatemodel(_model);
}

-(void) setIntParameter: (const char*) name val: (ORInt) val
{
   GRBsetintparam(_env,name,val);
}

-(void) setFloatParameter: (const char*) name val: (ORDouble) val
{
   GRBsetdblparam(_env,name,val);
}

-(void) setStringParameter: (const char*) name val: (char*) val
{
   GRBsetstrparam(_env,name,val);
}

-(ORStatus) postConstraint: (LPConstraintI*) cstr
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
   return ORSuspend;
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


