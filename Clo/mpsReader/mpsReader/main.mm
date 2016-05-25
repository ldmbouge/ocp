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
public:
   ORModelMaker(id<ORModel> mdl) : _mdl(mdl) {}
   void visitModel(Model* mdl);
   void visitMinimize(Minimize* of);
   void visitRelation(Relation* rel);
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
      id<ORModel> mdl = [ORFactory createModel];
      ORModelMaker maker(mdl);
      maker.visitModel(model.get());
      cout << *model << endl;
      NSLog(@"Objective-C model: %@",mdl);
      id<MIPProgram> mip = [ORFactory createMIPProgram: mdl];
      [mip solve];
   }
   return 0;
}

void ORModelMaker::visitModel(Model* mdl)
{
   for(Var::Ptr x : mdl->allVars()) {
      switch(x->getType()) {
         case Var::Continuous: {
            id<ORRealVar> mx = [ORFactory realVar:_mdl low:x->getLB() up:x->getUB()];
            _vMap[x->getID()] = mx;
         }break;
         case Var::Integer: {
            id<ORIntVar> mx = [ORFactory intVar:_mdl bounds:RANGE(_mdl,x->getLB(),x->getUB())];
            _vMap[x->getID()] = mx;
         }break;
         case Var::Binary: {
            id<ORIntVar> mx = [ORFactory boolVar:_mdl];
            _vMap[x->getID()] = mx;
         }break;
      }
   }
   mdl->objective()->visit(this);
   for(auto& r : mdl->relations())
      r.second->visit(this);
}

void ORModelMaker::visitMinimize(Minimize * of)
{
   id<ORExpr> e = [ORFactory integer:_mdl value:of->getIndependent()];
   for(auto i = of->cbegin(); i != of->cend();i++) {
      double coef = i->first;
      Var::Ptr t  = i->second;
      id<ORExprVar> theVar = _vMap[t->getID()];
      e = [e plus:[ORFactory expr:theVar mul:[ORFactory double:_mdl value:coef] track:_mdl]];
   }
   [_mdl minimize:e];
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
