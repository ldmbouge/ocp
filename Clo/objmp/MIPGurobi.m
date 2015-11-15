/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <objmp/MIPGurobi.h>
#import <objmp/MIPType.h>
#import <objmp/MIPSolverI.h>
#import <ORProgram/ORSolution.h>
#import <ORFoundation/ORConstraint.h>
#import "gurobi_c.h"

int gurobi_callback(GRBmodel *model, void *cbdata, int where, void *usrdata);

@implementation MIPGurobiSolver {
   struct _GRBenv*                _env;
   struct _GRBmodel*              _model;
   MIPOutcome                      _status;
   MIPObjectiveI*                 _objective;
   id<ORDoubleInformer>           _informer;
@public
   NSArray*                       _newSolVars;
   NSArray*                       _newSolVals;
   ORDouble                       _newBnd;
   ORDouble                       _bnd;
}

-(MIPGurobiSolver*) init
{
   self = [super init];
   int error = GRBloadenv(&_env, "");
   if (error) {
      @throw [[NSException alloc] initWithName:@"Gurobi Solver Error"
                                        reason:@"Gurobi cannot create its environment"
                                      userInfo:nil];
   }
   GRBnewmodel(_env, &_model, "", 0, NULL, NULL, NULL, NULL, NULL);
   _informer = [ORConcurrency doubleInformer];
   _bnd = MAXDBL;
   _newBnd = MAXDBL;
   _newSolVars = nil;
   _newSolVals = nil;
   return self;
}

-(void) dealloc
{
   GRBfreemodel(_model);
   GRBfreeenv(_env);
   [super dealloc];
}

-(void) updateModel
{
   GRBupdatemodel(_model);
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
   //GRBupdatemodel(_model);
}

-(MIPConstraintI*) addConstraint: (MIPConstraintI*) cstr
{
   [self postConstraint: cstr];
   //GRBupdatemodel(_model);
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
   _objective = obj;
   int s = [obj size];
   int* idx = [obj col];
   ORDouble* coef = [obj coef];
   for(ORInt i = 0; i < s; i++)
      if ([_objective type] == MIPminimize)
         GRBsetdblattrelement(_model,"Obj",idx[i],coef[i]);
      else
         GRBsetdblattrelement(_model,"Obj",idx[i],-coef[i]);
}

-(void) close
{
   
}
-(MIPOutcome) solve
{
   //int error = GRBsetintparam(GRBgetenv(_model), "LazyConstraints", 1); // Enable lazy constraints for bounds update
   //if(error != 0) assert(YES);
   GRBupdatemodel(_model);
   //[self printModelToFile: "/Users/dan/Desktop/lookatgurobi.lp"];
   GRBsetcallbackfunc(_model, &gurobi_callback, self);
   
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

-(ORDouble) bestObjectiveBound {
    ORDouble bnd;
    GRBgetdblattr(_model, "ObjBound", &bnd);
    return bnd;
}

-(ORFloat) dualityGap {
    ORDouble gap;
    GRBgetdblattr(_model, "MIPGap", &gap);
    return gap;
}

-(MIPOutcome) status
{
   return _status;
}

-(ORInt) intValue: (MIPIntVariableI*) var
{
   ORDouble value;
   GRBgetdblattrelement(_model,"X",[var idx],&value);
   return (ORInt) value;
}

-(void) setIntVar: (MIPIntVariableI*)var value: (ORInt)val
{
    int error = GRBsetdblattrelement(_model, GRB_DBL_ATTR_LB, [var idx], val);
    error = GRBsetdblattrelement(_model, GRB_DBL_ATTR_UB, [var idx], val) || error ;
    GRBupdatemodel(_model);
    if(error != 0) NSLog(@"err: %i", error);
}

-(ORDouble) doubleValue: (MIPVariableI*) var
{
   ORDouble value;
   GRBgetdblattrelement(_model,"X",[var idx],&value);
   return value;
}

-(ORDouble) lowerBound: (MIPVariableI*) var
{
   ORDouble value;
   GRBgetdblattrelement(_model,"LB",[var idx],&value);
   return value;
}

-(ORDouble) upperBound: (MIPVariableI*) var
{
   ORDouble value;
   GRBgetdblattrelement(_model,"UB",[var idx],&value);
   return value;
}

-(ORDouble) objectiveValue
{
   ORDouble objVal;
   GRBgetdblattr(_model,"ObjVal",&objVal);
   if ([_objective type] == MIPmaximize)
      return -objVal;
   else
      return objVal;
}

-(void) setBounds: (MIPVariableI*) var low: (ORDouble) low up: (ORDouble) up
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

-(void) updateLowerBound: (MIPVariableI*) var lb: (ORDouble) lb
{
   if (lb > [self lowerBound: var])
      GRBsetdblattrelement(_model,"LB",[var idx],lb);
}

-(void) updateUpperBound: (MIPVariableI*) var ub: (ORDouble) ub
{
   if (ub < [self upperBound: var])
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

-(ORDouble) paramValue: (MIPParameterI*) param
{
    ORDouble v;
    int err = GRBgetcoeff(_model, [param cstrIdx], [param coefIdx], &v);
    if(err != 0) return DBL_MAX;
    return v;
}

-(void) setParam: (MIPParameterI*) param value: (ORDouble)val
{
    int cind[] = { [param cstrIdx] };
    int vind[] = { [param coefIdx] };
    double v[] = { val };
    int err = GRBchgcoeffs(_model, 1, cind, vind, v);
    //    GRBupdatemodel(_model);
    if(err != 0)
        NSLog(@"error setting gurobi parameter: %i", err);
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

-(id<ORDoubleInformer>) boundInformer
{
   return _informer;
}

-(void) tightenBound: (ORDouble)bnd
{
   if(bnd < _newBnd) _newBnd = bnd;
}

-(void) injectSolution: (NSArray*)vars values: (NSArray*)vals size: (ORInt)size;
{
   if(_newSolVars) [_newSolVars release];
   _newSolVars = vars;
   if(_newSolVals) [_newSolVals release];
   _newSolVals = vals;
}

-(void) pumpEvents
{
   [ORConcurrency pumpEvents];
}

// Called from Gurobi callback function
-(void) lazyBoundTighten: (void*)cbdata
{
   if(_newBnd < _bnd && _objective) {
      _bnd = _newBnd;
      int s = [_objective size];
      int* idx = [_objective col];
      ORDouble* coef = [_objective coef];
      char sense = ([_objective type] == MIPminimize) ? GRB_LESS_EQUAL : GRB_GREATER_EQUAL;
      int error = GRBcblazy(cbdata, s, idx, coef, sense, _newBnd);
      if (error != 0) assert(NO);
   }
}

-(void) lazySolutionInject: (void*)cbdata
{
   if(_newSolVars && _newSolVals) {
      int numVars;
      GRBgetintattr(_model, "NumVars", &numVars);
      double* solution = malloc(numVars * sizeof(double));
      for(ORInt i = 0; i < numVars; i++) {
         solution[i] = GRB_UNDEFINED;
      }
      for(ORInt k = 0; k < [_newSolVars count]; k++) {
         ORInt idx = [(MIPVariableI*)_newSolVars[k] idx];
         ORDouble val = [_newSolVals[k] doubleValue];
         //NSLog(@"idx: %i => %f", idx, val);
         solution[idx] = val;
      }
      
      int error = GRBcbsolution(cbdata, solution);
      if (error != 0) assert(NO);
      
      free(solution);
      free(_newSolVars);
      free(_newSolVals);
      _newSolVars = nil;
      _newSolVals = nil;
   }
}

@end

int gurobi_callback(GRBmodel *model, void *cbdata, int where, void *usrdata) {
    MIPGurobiSolver* solver = (MIPGurobiSolver*)usrdata;
    if(where == GRB_CB_MIPSOL) {
       ORDouble bnd;
       GRBcbget(cbdata, where, GRB_CB_MIPSOL_OBJ, (void *) &bnd);
       solver->_bnd = bnd;
       [[solver boundInformer] notifyWithFloat: bnd];
    }
    else if(where == GRB_CB_MIPNODE) {
       [solver lazySolutionInject: cbdata];
       //[solver lazyBoundTighten: cbdata];
    }
    else if (where == GRB_CB_POLLING) [solver pumpEvents];
    return 0;
}


