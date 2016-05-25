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

#define DLL_PUBLIC __attribute__ ((visibility ("default")))

class Var;
class Linear;
class Relation;
class Objective;
class Minimize;
class Maximize;
class Model;

class DLL_PUBLIC MDLVisit {
public:
   MDLVisit() {}
   virtual ~MDLVisit() {}
   virtual void visitModel(Model*) {}
   virtual void visitVar(Var*) {}
   virtual void visitLinear(Linear*) {}
   virtual void visitRelation(Relation*) {}
   virtual void visitObjective(Objective*) {}
   virtual void visitMinimize(Minimize*) {}
   virtual void visitMaximize(Maximize*) {}
};

class DLL_PUBLIC Var {
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
   void visit(MDLVisit* mv) { mv->visitVar(this);}
   Type getType() const { return _vt;}
   double getLB() const { return _lb;}
   double getUB() const { return _ub;}
   const std::string& getName() const { return _name;}
   int getID() const { return _id;}
};

class DLL_PUBLIC Linear {
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
   virtual void visit(MDLVisit* mv) { mv->visitLinear(this);}
   double getIndependent() const { return _independent;}
   auto cbegin() const { return _terms.cbegin();}
   auto cend()   const { return _terms.cend();}
};

class DLL_PUBLIC Relation: public Linear {
public:
   enum Operator { Leq,Geq,Eq };
private:
   Operator   _op;
public:
   Relation(Operator op,double indep) : Linear(indep),_op(op) {}
   std::ostream& print(std::ostream& os) const override;
   void visit(MDLVisit* mv) override { mv->visitRelation(this);}
   Operator getOperator() const { return _op;}
};

class DLL_PUBLIC Objective : public Linear {
public:
   typedef std::shared_ptr<Objective> Ptr;
   Objective(Linear::Ptr lin) : Linear(lin) {}
   Objective(double indep) : Linear(indep) {}
   void visit(MDLVisit* mv) override { mv->visitObjective(this);}
};

class DLL_PUBLIC Minimize :public Objective {
public:
   Minimize(Linear::Ptr lin) : Objective(lin) {}
   Minimize(double indep) : Objective(indep)  {}
   std::ostream& print(std::ostream& os) const override;
   void visit(MDLVisit* mv) override { mv->visitMinimize(this);}
};

class DLL_PUBLIC Maximize :public Objective {
public:
   Maximize(Linear::Ptr lin) : Objective(lin) {}
   Maximize(double indep) : Objective(indep)  {}
   std::ostream& print(std::ostream& os) const override;
   void visit(MDLVisit* mv) override { mv->visitMaximize(this);}
};

class DLL_PUBLIC Model {
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
   void visit(MDLVisit* mv) { mv->visitModel(this);}
   const auto& allVars() const   { return _allVars;}
   const auto& objective() const { return _obj;}
   const auto& relations() const { return _eqns;}
   friend DLL_PUBLIC std::ostream& operator<<(std::ostream& os,const Model& m);
};

#endif /* model_hpp */
