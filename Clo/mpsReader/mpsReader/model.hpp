//
//  model.hpp
//  mpsReader
//
//  Created by Laurent Michel on 5/23/16.
//  Copyright © 2016 Laurent Michel. All rights reserved.
//

#ifndef model_hpp
#define model_hpp

#include <stdio.h>
#include <map>
#include <list>
#include <memory>
#include <string>
#include <iostream>
#include <iomanip>
#include <cfloat>

class Var {
public:
   enum Type { Continuous,Integer,Binary };
private:
   std::string _name;
   int _id;
   double _lb,_ub;
   Type   _vt;
public:
   typedef std::shared_ptr<Var> Ptr;
   Var(const std::string& name,int vid) : _name(name),_id(vid),_vt(Continuous),_lb(-DBL_MAX),_ub(DBL_MAX) {}
   friend std::ostream& operator<<(std::ostream& os,const Var& m);
   std::ostream& printFull(std::ostream& os) const;
   Var* setUB(double ub) { _ub = ub;return this;}
   Var* setLB(double lb) { _lb = lb;return this;}
   Var* setBinary()  { _vt = Binary;_lb = 0.0;_ub = 1.0;return this;}
   Var* setInteger() { _vt = Integer;return this;}
};

class Linear {
public:
   typedef std::pair<double,Var::Ptr> Term;
protected:
   std::list<Term> _terms;
   double    _independent;
public:
   typedef std::shared_ptr<Linear> Ptr;
   Linear(Linear::Ptr lin) : _terms(std::move(lin->_terms)),_independent(lin->_independent) {}
   Linear(double indep);
   virtual ~Linear();
   virtual std::ostream& print(std::ostream& os) const;
   void addTerm(double a,Var::Ptr x);
   friend std::ostream& operator<<(std::ostream& os,const Linear& lin);
};

class Relation: public Linear {
public:
   enum Operator { Leq,Geq,Eq };
private:
   Operator   _op;
public:
   Relation(Operator op,double indep) : Linear(indep),_op(op) {}
   std::ostream& print(std::ostream& os) const;
};

class Objective : public Linear {
public:
   typedef std::shared_ptr<Objective> Ptr;
   Objective(Linear::Ptr lin) : Linear(lin) {}
   Objective(double indep) : Linear(indep) {}
};

class Minimize :public Objective {
public:
   Minimize(Linear::Ptr lin) : Objective(lin) {}
   Minimize(double indep) : Objective(indep)  {}
   std::ostream& print(std::ostream& os) const;
};

class Maximize :public Objective {
public:
   Maximize(Linear::Ptr lin) : Objective(lin) {}
   Maximize(double indep) : Objective(indep)  {}
   std::ostream& print(std::ostream& os) const;
};

class Model {
   int _lastVarID;
   std::list<Var::Ptr> _allVars;
   std::map<std::string,Relation::Ptr> _eqns;
   Objective::Ptr                       _obj;
public:
   typedef std::shared_ptr<Model> Ptr;
   Model();
   virtual ~Model();
   Var::Ptr makeVar(const std::string& name);
   void minimize(Linear::Ptr obj);
   void maximize(Linear::Ptr obj);
   void addRelation(std::string name,Relation::Ptr lin);
   friend std::ostream& operator<<(std::ostream& os,const Model& m);
};

#endif /* model_hpp */
