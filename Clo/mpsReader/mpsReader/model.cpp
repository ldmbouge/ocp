//
//  model.cpp
//  mpsReader
//
//  Created by Laurent Michel on 5/23/16.
//  Copyright © 2016 Laurent Michel. All rights reserved.
//

#include "model.hpp"

Var::Var(const std::string& name,int vid)
   : _name(name),_id(vid),_vt(Continuous),
      _lb(0),_ub(DBL_MAX)
{}

std::ostream& operator<<(std::ostream& os,const Var& m)
{
   return os << m._name;
}

std::ostream& Var::printFull(std::ostream& os) const
{
   os << "[";
   if (_lb == -DBL_MAX)
      os << "-inf";
   else os << _lb;
   os << ',';
   if (_ub == DBL_MAX)
      os << "+inf";
   else os << _ub;
   os << ',';
   switch(_vt) {
      case Var::Continuous: os << "cont";break;
      case Var::Integer: os << "int";break;
      case Var::Binary: os << "bin";break;
   }
   os << "]";
   return os << _name << '(' << _id << ')';
}

Linear::Linear(double ind)
   : _independent(ind)
{
}

Linear::~Linear()
{
}

void Linear::addTerm(double a,Var::Ptr x)
{
   _terms.emplace_back(a,x);
}

std::ostream& operator<<(std::ostream& os,const Linear& lin)
{
   return lin.print(os);
}

std::ostream& Linear::print(std::ostream& os) const
{
   for(auto& t : _terms) {
      os << t.first << " * " << *t.second << " + ";
   }
   return os << _independent;
}

std::ostream& Relation::print(std::ostream& os) const
{
   Linear::print(os);
   switch(_op) {
      case Relation::Leq: os << " ≤ " << 0;break;
      case Relation::Geq: os << " ≥ " << 0;break;
      case Relation::Eq: os << "  = " << 0;break;
   }
   return os;
}

Model::Model()
   : _lastVarID(0)
{}

Model::~Model()
{}

Var::Ptr Model::makeVar(const std::string& name)
{
   auto rv = std::make_shared<Var>(name,_lastVarID++);
   _allVars.push_back(rv);
   return rv;
}

void Model::minimize(Linear::Ptr obj)
{
   _obj = std::make_shared<Minimize>(obj);
}

void Model::maximize(Linear::Ptr obj)
{
   _obj = std::make_shared<Maximize>(obj);
}

std::ostream& Minimize::print(std::ostream& os) const
{
   os << "minimize " << std::endl << '\t';
   return Objective::print(os);
}

std::ostream& Maximize::print(std::ostream& os) const
{
   os << "maximize " << std::endl << '\t';
   return Objective::print(os);
}

void Model::addRelation(std::string name,Relation::Ptr lin)
{
   _eqns[name] = lin;
}

std::ostream& operator<<(std::ostream& os,const Model& m)
{
   os << "vars" << std::endl;
   for(auto& v : m._allVars) {
      os << "\t";
      v->printFull(os);
      os << std::endl;
   }
   os << *m._obj << std::endl;
   os << "relations" << std::endl;
   for(auto& e : m._eqns) {
      os << "\t" << e.first << " : " << *e.second << std::endl;
   }
   return os;
}
