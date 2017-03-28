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

@interface GurobiBasis  : ORObject<LPBasis> {
   @package
   int* _vb;
   int* _cb;
   int  _nbVars;
   int  _nbCons;
}
-(id<LPBasis>)init:(struct _GRBenv*)env withModel:(struct _GRBmodel*)model;
-(void)restore:(LPSolverI *)solver;
@end


@implementation GurobiBasis
-(id<LPBasis>)init:(struct _GRBenv*)env withModel:(struct _GRBmodel*)model;
{
   self = [super init];
   GRBgetintattr(model,"NumConstrs",&_nbCons);
   GRBgetintattr(model,"NumVars",&_nbVars);
   _vb = calloc(_nbVars, sizeof(int));
   _cb = calloc(_nbCons,sizeof(int));
   GRBgetintattrarray(model, "VBasis", 0, _nbVars, _vb);
   GRBgetintattrarray(model, "CBasis", 0, _nbCons, _cb);
   return self;
}
-(void)dealloc
{
   free(_vb);
   free(_cb);
   [super dealloc];
}
-(void)restore:(LPSolverI *)solver
{
   [solver restoreBasis:(id<LPBasis>)self];
}
@end

static int gurobi_callback(GRBmodel *model, void *cbdata, int where, void *usrdata);

@implementation LPGurobiSolver {
   struct _GRBenv*                _env;
   struct _GRBmodel*              _model;
   OROutcome                      _status;
   LPObjectiveType                _objectiveType;
   ORLong                         _statIter;
   ORLong                         _roundIter;
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
   error = GRBsetcallbackfunc(_model, gurobi_callback, (void *) self);
   _statIter = _roundIter = 0;
   return self;
}

-(void) dealloc
{
   NSLog(@"Iterations simplex: %lld",_statIter);
   GRBfreemodel(_model);
   GRBfreeenv(_env);
   [super dealloc];
}

-(id<LPBasis>)captureBasis
{
   id<LPBasis> theBasis = [[GurobiBasis alloc] init:_env withModel:_model];
   return theBasis;
}

-(void)restoreBasis:(GurobiBasis*)basis
{
   GRBsetintattrarray(_model, "VBasis", 0, basis->_nbVars, basis->_vb);
   GRBsetintattrarray(_model, "CBasis", 0, basis->_nbCons, basis->_cb);
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
-(OROutcome) solveFrom:(id<LPBasis>)basis
{
   GRBupdatemodel(_model);
   [self restoreBasis:basis];
   GRBoptimize(_model);
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
   //[self printModelToFile: "/Users/ldm/Desktop/linearRelax.lp"];
   GRBoptimize(_model);
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
   GRBgetdblparam(_env,"IntFeasTol",&feasTol);
   GRBgetdblattrelement(_model,"LB",[var idx],&lb);
   GRBgetdblattrelement(_model,"UB",[var idx],&ub);
   GRBgetdblattrelement(_model,"X",[var idx],&value);
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
   GRBgetintattrelement(_model, "VBasis",[var idx], &value);
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
   ORInt idx = var->_idx;
   GRBsetdblattrelement(_model,"LB",idx,low);
   GRBsetdblattrelement(_model,"UB",idx,up);
}

-(void) setUnboundUpperBound: (LPVariableI*) var
{
   GRBsetdblattrelement(_model,"UB",var->_idx,1e21);
}

-(void) setUnboundLowerBound: (LPVariableI*) var
{
   GRBsetdblattrelement(_model,"LB",var->_idx,-1e21);
}

-(void) updateLowerBound: (LPVariableI*) var lb: (ORDouble) lb
{
   GRBsetdblattrelement(_model,"LB",var->_idx,lb);
}

-(void) updateUpperBound: (LPVariableI*) var ub: (ORDouble) ub
{
   GRBsetdblattrelement(_model,"UB",var->_idx,ub);
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

-(void) simplex:(ORInt)it objective:(ORDouble)obj perturbed:(ORBool)isP primalInfeasible:(ORDouble)pInf dualInfeasible:(ORDouble)dInf
{
   if (it == 0)
      _statIter += _roundIter;
   //NSLog(@"simplex(%d) : %f",it,obj);
   _roundIter = it;
}

-(void)barrier:(ORInt)it primal:(ORDouble)obj dual:(ORDouble)dual primalInfeasible:(ORDouble)pInf dualInfeasible:(ORDouble)dInf
{
   NSLog(@"barrier(%d) : %f",it,obj);
}

int gurobi_callback(GRBmodel *model, void *cbdata, int where, void *usrdata)
{
   LPGurobiSolver* solver = (LPGurobiSolver*)usrdata;
   
   if (where == GRB_CB_POLLING) {
      /* Ignore polling callback */
   } else if (where == GRB_CB_PRESOLVE) {
      /* Presolve callback */
      int cdels, rdels;
      GRBcbget(cbdata, where, GRB_CB_PRE_COLDEL, &cdels);
      GRBcbget(cbdata, where, GRB_CB_PRE_ROWDEL, &rdels);
      if (cdels || rdels) {
//         printf("%7d columns and %7d rows are removed\n", cdels, rdels);
      }
   } else if (where == GRB_CB_SIMPLEX) {
      /* Simplex callback */
      double itcnt, obj, pinf, dinf;
      int    ispert;
      GRBcbget(cbdata, where, GRB_CB_SPX_ITRCNT, &itcnt);
      GRBcbget(cbdata, where, GRB_CB_SPX_OBJVAL, &obj);
      GRBcbget(cbdata, where, GRB_CB_SPX_ISPERT, &ispert);
      GRBcbget(cbdata, where, GRB_CB_SPX_PRIMINF, &pinf);
      GRBcbget(cbdata, where, GRB_CB_SPX_DUALINF, &dinf);
      [solver simplex:itcnt objective:obj perturbed:ispert primalInfeasible:pinf dualInfeasible:dinf ];
   } else if (where == GRB_CB_MIP) {
      /* General MIP callback */
   } else if (where == GRB_CB_MIPSOL) {
      /* MIP solution callback */
   } else if (where == GRB_CB_MIPNODE) {
      /* MIP node callback */
   } else if (where == GRB_CB_BARRIER) {
      /* Barrier callback */
      int    itcnt;
      double primobj, dualobj, priminf, dualinf, compl;
      GRBcbget(cbdata, where, GRB_CB_BARRIER_ITRCNT, &itcnt);
      GRBcbget(cbdata, where, GRB_CB_BARRIER_PRIMOBJ, &primobj);
      GRBcbget(cbdata, where, GRB_CB_BARRIER_DUALOBJ, &dualobj);
      GRBcbget(cbdata, where, GRB_CB_BARRIER_PRIMINF, &priminf);
      GRBcbget(cbdata, where, GRB_CB_BARRIER_DUALINF, &dualinf);
      GRBcbget(cbdata, where, GRB_CB_BARRIER_COMPL, &compl);
      [solver barrier:itcnt primal:primobj dual:dualobj primalInfeasible:priminf dualInfeasible:dualinf];
   } else if (where == GRB_CB_MESSAGE) {
      /* Message callback */
      
   }
   return 0;
}
@end
