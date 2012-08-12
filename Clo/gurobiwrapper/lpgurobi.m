/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import "lpgurobi.h"

@implementation LPGurobiSolver;


-(id<LPSolverWrapper>) initLPGurobiSolver
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

-(void) addVariable: (id<LPVariable>) var;
{
    if ([var hasBounds])
        GRBaddvar(_model, 0,NULL, NULL, 0.0, [var low], [var up],GRB_CONTINUOUS,NULL);  
    else
        GRBaddvar(_model, 0,NULL, NULL, 0.0, 0.0, GRB_INFINITY,GRB_CONTINUOUS,NULL);  
    GRBupdatemodel(_model);    
}

-(void) addConstraint: (id<LPConstraint>) cstr
{
    [self postConstraint: cstr];
    GRBupdatemodel(_model);    
}
-(void) delConstraint: (id<LPConstraint>) cstr
{
    int todel[] = { [cstr idx] };
    GRBdelconstrs(_model,1,todel);  
    GRBupdatemodel(_model);    
}
-(void) delVariable: (id<LPVariable>) var
{
    int todel[] = { [var idx] };
    GRBdelvars(_model,1,todel);
    GRBupdatemodel(_model);  
}
-(void) addObjective: (id<LPObjective>) obj
{
    int s = [obj size];
    int* idx = [obj col];
    double* coef = [obj coef];
    _objectiveType = [obj type];
    for(ORInt i = 0; i < s; i++) 
        if (_objectiveType == LPminimize)
            GRBsetdblattrelement(_model,"Obj",idx[i],coef[i]);
        else
            GRBsetdblattrelement(_model,"Obj",idx[i],-coef[i]);
}

-(void) addColumn: (id<LPColumn>) col
{
    double o = [col objCoef];
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
    GRBoptimize(_model);  
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

-(double) value: (id<LPVariable>) var
{
  double value;
  GRBgetdblattrelement(_model,"X",[var idx],&value);
  return value;
}

-(double) lowerBound: (id<LPVariable>) var
{
  double value;
  GRBgetdblattrelement(_model,"LB",[var idx],&value);
  return value;
}

-(double) upperBound: (id<LPVariable>) var
{
  double value;
  GRBgetdblattrelement(_model,"UB",[var idx],&value);
  return value;
}

-(double) objectiveValue
{
  double objVal;
  GRBgetdblattr(_model,"ObjVal",&objVal);  
  if (_objectiveType == LPmaximize)
    return -objVal;
  else
    return objVal;    
}

-(double) reducedCost: (id<LPVariable>) var
{
    double value;
    GRBgetdblattrelement(_model,"RC",[var idx],&value);
    return value;  
}

-(double) dual: (id<LPConstraint>) cstr
{
    double value;
    GRBgetdblattrelement(_model,"Pi",[cstr idx],&value);
    return value;  
}

-(void) setBounds: (id<LPVariable>) var low: (double) low up: (double) up
{
  GRBsetdblattrelement(_model,"LB",[var idx],low);
  GRBsetdblattrelement(_model,"UB",[var idx],low);
}

-(void) setUnboundUpperBound: (id<LPVariable>) var
{
  GRBsetdblattrelement(_model,"UB",[var idx],1e21);
}

-(void) setUnboundLowerBound: (id<LPVariable>) var
{
  GRBsetdblattrelement(_model,"LB",[var idx],-1e21);
}

-(void) updateLowerBound: (id<LPVariable>) var lb: (double) lb
{
  if (lb > [self lowerBound: var])
    GRBsetdblattrelement(_model,"LB",[var idx],lb);    
}

-(void) updateUpperBound: (id<LPVariable>) var ub: (double) ub
{
  if (ub < [self upperBound: var])
    GRBsetdblattrelement(_model,"UB",[var idx],ub);    
}

// This will change; completely bogus now
-(void) removeLastConstraint
{
    int nb;
    GRBgetintattr(_model,"NumConstrs",&nb);
    printf("Before removing: %d \n",nb);
    int todel[] = { 0 };
    GRBdelconstrs(_model,1,todel);  
    [self solve];
    GRBgetintattr(_model,"NumConstrs",&nb);
    printf("after removing: %d \n",nb);
}

// This will change completely bogus now
-(void) removeLastVariable
{
  int todel[] = { 0 };
  GRBdelvars(_model,1,todel);  
}

-(void) setIntParameter: (const char*) name val: (ORInt) val
{
  GRBsetintparam(_env,name,val);
}

-(void) setFloatParameter: (const char*) name val: (double) val
{
  GRBsetdblparam(_env,name,val);
}

-(void) setStringParameter: (const char*) name val: (char*) val
{
  GRBsetstrparam(_env,name,val);
}

-(void) postConstraint: (id<LPConstraint>) cstr
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


