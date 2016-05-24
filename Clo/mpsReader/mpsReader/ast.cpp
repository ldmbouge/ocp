//
//  ast.cpp
//  mpsReader
//
//  Created by Laurent Michel on 5/23/16.
//  Copyright © 2016 Laurent Michel. All rights reserved.
//

#include "ast.hpp"
#include <map>
#include <assert.h>

namespace AST {
   using namespace std;
   Node::Node() {}
   Node::~Node() {}
 
   Program::Program(char* n,char* s,char* o,
                    std::list<AST::Row::Ptr>* rows,
                    std::list<AST::Col::Ptr>* cols,
                    std::list<AST::Rhs::Ptr>* r,
                    std::list<AST::Bound::Ptr>* b)
      : _name(n)
   {
      if (s == nullptr)
         _sense = Min;
      else if (std::string("MIN") == s)
         _sense = Min;
      else if (std::string("MAX") == s)
         _sense = Max;
      else {
         std::cout << "wrong sense [" << s << "]" << endl;
         exit(2);
      }
      if (o == nullptr)
         _obj = "N";
      else _obj = o;
      _rows = std::move(*rows);
      _cols = std::move(*cols);
      _rhs  = std::move(*r);
      _bounds = std::move(*b);
      delete rows;
      delete cols;
      delete r;
      delete b;
   }
   ostream& Program::print(ostream& os) const {
      cout << "NAME:" << _name << endl;
      switch(_sense) {
         case Min: cout << "MIN ROW:" << _obj << endl;
            break;
         case Max: cout << "MAX ROW:" << _obj << endl;
            break;
      }
      cout << "ROWS" << endl;
      for(auto& r : _rows)
         cout <<  '\t' << *r << endl;
      cout << "COLS" << endl;
      for(auto& c : _cols)
         cout << '\t' << *c << endl;
      cout << "RHS" << endl;
      for(auto& rhs : _rhs)
         cout << '\t' << *rhs << endl;
      cout << "BOUNDS" << endl;
      for(Bound::Ptr b : _bounds)
         cout << '\t' << *b << endl;
      
      return os;
   }
   ostream& Row::print(ostream& os) const  {
      switch(_type) {
         case Leq: os << _name << " ≤";break;
         case Geq: os << _name << " ≥";break;
         case Eq: os << _name << " =";break;
         case No: os << _name << " No restriction";break;
         case Objective: os << _name << " Objective";break;
      }
      return os;
   }
   ostream& Col::print(ostream& os) const  {
      os << _cName << " " << _rName << " : " << _coef;
      return os;
   }
   ostream& Rhs::print(ostream& os) const {
      os << _rhsName << " " << _cName << " : " << _rhs;
      return os;
   }

   ostream& Bound::print(ostream& os) const  {
      switch(_type) {
         case Ub: os << _bName << " : " << _vName << " ≤ " << _bnd;break;
         case Lb: os << _bName << " : " << _vName << " ≥ " << _bnd;break;
         case Fx: os << _bName << " : " << _vName << " = " << _bnd;break;
         case Fr: os << _bName << " : " << _vName << " FREE ";break;
         case By: os << _bName << " : " << _vName << " BINARY ";break;
         case Mi: os << _bName << " : " << _vName << " MI ";break;
         case Pl: os << _bName << " : " << _vName << " PL ";break;
         case Li: os << _bName << " : " << _vName << " LI ";break;
         case Ui: os << _bName << " : " << _vName << " UI ";break;
         case Sc: os << _bName << " : " << _vName << " SC ";break;
      }
      return os;
   }
   Model::Ptr Program::makeModel()
   {
      Model::Ptr m = make_shared<Model>();
      map<string,Var::Ptr> allVars;
      map<string,double> allRHS;
      map<string,Relation::Ptr> allRels;
      for(auto& c : _cols) {
         if (allVars.find(c->getName()) == allVars.end()) {
            Var::Ptr aVar =m->makeVar(c->getName());
            if (c->isForcedInt())
               aVar->setInteger();
            allVars[c->getName()] = aVar;
         }
      }
      for(auto& b : _bounds) {
         const auto& vn = b->getName();
         switch(b->getType()) {
            case Bound::Ub :  allVars[vn]->setUB(b->getBound());break;
            case Bound::Lb :  allVars[vn]->setLB(b->getBound());break;
            case Bound::Fx :  allVars[vn]->setLB(b->getBound())->setUB(b->getBound());break;
            case Bound::By :  allVars[vn]->setBinary();break;
            case Bound::Mi :  allVars[vn]->setUB(0);break;
            case Bound::Pl :  allVars[vn]->setLB(0);break;
            case Bound::Ui :  allVars[vn]->setInteger()->setUB(b->getBound());break;
            case Bound::Li :  allVars[vn]->setInteger()->setLB(b->getBound());break;
            case Bound::Sc : std::cout << "Don't know what semi-continuous means" << std::endl;
            case Bound::Fr : break;
         }
      }
      for(auto& rhs : _rhs)
         allRHS[rhs->getName()] = rhs->getRHS();
      Linear::Ptr obj;
      for(auto& r : _rows) {
         Relation::Operator rt;
         switch(r->getOperator()) {
            case Row::Leq :
               rt = Relation::Leq;
               allRels[r->getName()] = make_shared<Relation>(rt,-allRHS[r->getName()]);
               break;
            case Row::Geq :
               rt = Relation::Geq;
               allRels[r->getName()] = make_shared<Relation>(rt,-allRHS[r->getName()]);
               break;
            case Row::Eq  :
               rt = Relation::Eq;
               allRels[r->getName()] = make_shared<Relation>(rt,-allRHS[r->getName()]);
               break;
            case Row::No  :
               obj = allRels[r->getName()] = make_shared<Linear>(0);break;
               break;
            default:break;
         }
      }
      for(auto& c : _cols) {
         const auto& rn = c->getRowName();
         allRels[rn]->addTerm(c->getCoef(),allVars[c->getName()]);
      }
      for(auto& r : allRels)
         if (r.second != obj)
            m->addRelation(r.first, r.second);
      switch(_sense) {
         case Min: m->minimize(obj);break;
         case Max: m->maximize(obj);break;
      }
      return m;
   }

}