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

   error = GRBsetintparam(_env, GRB_INT_PAR_METHOD, GRB_METHOD_DUAL);
   
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
//   GRBupdatemodel(_model);
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
   GRBupdatemodel(_model);
   GRBoptimize(_model);
   //[self printModelToFile: "/Users/ldm/Desktop/linearRelax.lp"];
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
   ORDouble lb,ub,value;
   ORDouble feasTol = 0.0;
   int st = GRBgetdblparam(_env,"IntFeasTol",&feasTol);

   GRBgetdblattrelement(_model,"LB",[var idx],&lb);
   GRBgetdblattrelement(_model,"UB",[var idx],&ub);
   GRBgetdblattrelement(_model,"X",[var idx],&value);
//   if (value < lb)
//      value = lb;
//   else if (value > ub)
//      value = ub;

   if (fabs(value - lb) < feasTol)
      value = lb;
   else if (fabs(value - ub) < feasTol)
      value = ub;
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
-(ORBool) inBasis: (LPVariableI*) var
{
   int value = 0;
   int st = GRBgetintattrelement(_model, "VBasis",[var idx], &value);
   assert(st==0);
   return value==0;
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
}

-(void) setUnboundUpperBound: (LPVariableI*) var
{
   GRBsetdblattrelement(_model,"UB",[var idx],1e21);
}

-(void) setUnboundLowerBound: (LPVariableI*) var
{
   GRBsetdblattrelement(_model,"LB",[var idx],-1e21);
}

-(void) updateLowerBound: (LPVariableI*) var lb: (ORDouble) lb
{
//   if (lb > [self lowerBound: var])
   GRBsetdblattrelement(_model,"LB",[var idx],lb);
}

-(void) updateUpperBound: (LPVariableI*) var ub: (ORDouble) ub
{
//   if (ub < [self upperBound: var])

//   double oldLB = [self lowerBound:var];
//   double oldUB = [self upperBound:var];
//   if (ub < oldUB) {
//      NSLog(@"About to tighten UB var(%d) from [%f ,** %f] to %f",[var idx],oldLB,oldUB,ub);
//   }
   GRBsetdblattrelement(_model,"UB",[var idx],ub);
}

-(void) setIntParameter: (const char*) name val: (ORInt) val
{
   GRBsetintparam(_env,name,val);
}

-(void) setDoubleParameter: (const char*) name val: (ORDouble) val
{
   GRBsetdblparam(_env,name,val);
}

-(void) setStringParameter: (const char*) name val: (char*) val
{
   GRBsetstrparam(_env,name,val);
}

-(ORDouble) paramValue: (LPParameterI*) param
{
    ORDouble v;
    int err = GRBgetcoeff(_model, [param cstrIdx], [param coefIdx], &v);
    if(err != 0) return DBL_MAX;
    return v;
}

-(void) setParam: (LPParameterI*) param value: (ORDouble)val
{
    int cind[] = { [param cstrIdx] };
    int vind[] = { [param coefIdx] };
    double v[] = { val };
    int err = GRBchgcoeffs(_model, 1, cind, vind, v);
    //    GRBupdatemodel(_model);
    if(err != 0)
        NSLog(@"error setting gurobi parameter: %i", err);
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


