//
//  main.cpp
//  mpsReader
//
//  Created by Laurent Michel on 5/23/16.
//  Copyright © 2016 Laurent Michel. All rights reserved.
//

#include <iostream>
#include <iomanip>
#include "mps.hpp"
#include <ORProgram/ORProgram.h>

using namespace std;
class ORModelMaker :public MDLVisit {
   id<ORModel> _mdl;
   map<int,id<ORExprVar> >  _vMap;
   void visitModelVars(Model* mdl);
   void visitModel(Model* mdl);
   void visitMinimize(Minimize* of);
   void visitMaximize(Maximize* of);
   void visitRelation(Relation* rel);
public:
   ORModelMaker() {}
   id<ORModel> operator()(Model* mdl) {
      _mdl = [ORFactory createModel];
      visitModel(mdl);
      return _mdl;
   }
   id<ORModel> makeVariables(Model* mdl) {
      _mdl = [ORFactory createModel];
      visitModelVars(mdl);
      return _mdl;
   }
   id<ORModel> addToModel(id<ORModel> into,Model* mdl) {
      _mdl = into;
      for(auto& r : mdl->relations())
         r.second->visit(this);
      return _mdl;
   }
};

int main(int argc, const char * argv[]) {
   using namespace std;
   // insert code here...
   if (argc <= 1) {
      std::cout << "usage is: mpsReader <filename>" << std::endl;
      return 1;
   }
   @autoreleasepool {
      auto model = MPSReader::readMPSFile(argv[1]);
      ORModelMaker maker;
      id<ORModel> mdl0 = maker.makeVariables(model.get());
      id<ORModel> mdl  = [mdl0 copy];
      maker.addToModel(mdl, model.get());
      //cout << *model << endl;
      
      NSLog(@"Objective-C model: %@",mdl);

//      id<MIPProgram> mip = [ORFactory createMIPProgram: mdl];
//      [mip solve];
      
      
      id<ORRelaxation> relax = [ORFactory createLinearRelaxation:mdl];
      id<ORAnnotation> notes = [ORFactory annotation];
      id<CPProgram> cps = [ORFactory createCPProgram:mdl
                                      withRelaxation:relax
                                          annotation:notes
                                                with:[ORSemDFSController proto]];
      id<ORIntVarArray> aiv = mdl.intVars;
//      id<ORIntVarArray> bv = [ORFactory slice:mdl0 range:aiv.range suchThat:^ORBool(ORInt k) { return aiv[k].isBool;} of:^id(ORInt k) { return aiv[k];}];
//      id<ORIntVarArray> dv = [ORFactory slice:mdl0 range:aiv.range suchThat:^ORBool(ORInt k) { return !aiv[k].isBool;} of:^id(ORInt k) { return aiv[k];}];

      [cps solve:^{
         PCBranching* pcb = [[PCBranching alloc] init:relax over:aiv program:cps];
         //PCBranching* pcb = [[FSBranching alloc] init:relax over:aiv program:cps];
         [pcb branchOn:aiv];
//         [pcb branchOn:bv];
//         [pcb branchOn:dv];
         double oval = [relax objective];
      }];
   }
   return 0;
}

void ORModelMaker::visitModelVars(Model* mdl)
{
   for(Var::Ptr x : mdl->allVars()) {
      switch(x->getType()) {
         case Var::Continuous: {
            id<ORRealVar> mx = [ORFactory realVar:_mdl low:x->getLB() up:x->getUB()];
            _vMap[x->getID()] = mx;
         }break;
         case Var::Integer: {
            double lb = x->getLB(),ub = x->getUB();
            ORInt ilb = lb < FDMININT ? FDMININT : lb;
            ORInt iub = ub > FDMAXINT ? FDMAXINT : ub;
            id<ORIntVar> mx = [ORFactory intVar:_mdl bounds:RANGE(_mdl,ilb,iub)];
            _vMap[x->getID()] = mx;
         }break;
         case Var::Binary: {
            id<ORIntVar> mx = [ORFactory boolVar:_mdl];
            _vMap[x->getID()] = mx;
         }break;
      }
   }
   mdl->objective()->visit(this);
}

void ORModelMaker::visitModel(Model* mdl)
{
   visitModelVars(mdl);
   for(auto& r : mdl->relations())
      r.second->visit(this);
}

void ORModelMaker::visitMinimize(Minimize * of)
{
   id<ORExpr> e = [ORFactory integer:_mdl value:of->getIndependent()];
   for(auto i = of->cbegin(); i != of->cend();i++) {
      double coef = i->first;
      double ic;
      double fc = modf(coef,&ic);
      if (fc == 0) {
         Var::Ptr t  = i->second;
         id<ORExprVar> theVar = _vMap[t->getID()];
         e = [e plus:[ORFactory expr:theVar mul:[ORFactory integer:_mdl value:rint(ic)] track:_mdl]];
      } else {
         Var::Ptr t  = i->second;
         id<ORExprVar> theVar = _vMap[t->getID()];
         e = [e plus:[ORFactory expr:theVar mul:[ORFactory double:_mdl value:coef] track:_mdl]];
      }
   }
   [_mdl minimize:e];
}

void ORModelMaker::visitMaximize(Maximize * of)
{
   id<ORExpr> e = [ORFactory integer:_mdl value:of->getIndependent()];
   for(auto i = of->cbegin(); i != of->cend();i++) {
      double coef = i->first;
      Var::Ptr t  = i->second;
      id<ORExprVar> theVar = _vMap[t->getID()];
      e = [e plus:[ORFactory expr:theVar mul:[ORFactory double:_mdl value:coef] track:_mdl]];
   }
   [_mdl maximize:e];
}

void ORModelMaker::visitRelation(Relation* rel)
{
   id<ORExpr> e = [ORFactory integer:_mdl value:rel->getIndependent()];
   for(auto i = rel->cbegin(); i != rel->cend();i++) {
      double coef = i->first;
      Var::Ptr t  = i->second;
      id<ORExprVar> theVar = _vMap[t->getID()];
      e = [e plus:[ORFactory expr:theVar mul:[ORFactory double:_mdl value:coef] track:_mdl]];
   }
   id<ORExpr> zero = [ORFactory integer:_mdl value:0];
   switch(rel->getOperator()) {
      case Relation::Leq: {
         [_mdl add:[ORFactory expr:e leq:zero track:_mdl]];
      }break;
      case Relation::Geq:{
         [_mdl add:[ORFactory expr:e geq:zero track:_mdl]];
      }break;
      case Relation::Eq:{
         [_mdl add:[ORFactory expr:e equal:zero track:_mdl]];
      }break;
   }
}
