#ifndef __AST_H
#define __AST_H

#include <iostream>
#include <iomanip>
#include <string>
#include <list>
#include <memory>
#include <stdlib.h>
#include "model.hpp"

namespace AST {
   using namespace std;
   class Node {
   public:
      Node();
      virtual ~Node();
      virtual ostream& print(ostream& os) const = 0;
      virtual std::string getName() { return std::string();}
      typedef std::shared_ptr<Node> Ptr;
      friend std::ostream& operator<<(std::ostream& os,const Node& n) { return n.print(os);}
   };
   
   class Expr : public Node {
   public:
      Expr() : Node() {}
   };

   class Decl :public Node {
   public:
      Decl() {}
      ostream& print(ostream& os) const { return os;}
   };
   
   class Row : public Node {
   public:
      enum Type { Leq,Geq,Eq, No, Objective};
   private:
      enum Type   _type;
      std::string _name;
   public:
      typedef std::shared_ptr<Row> Ptr;
      Row(enum Type t,std::string&& name) : _type(t),_name(std::move(name)) {}
      ostream& print(ostream& os) const override;
      Type getOperator() const { return _type;}
      std::string getName() override    { return _name;}
   };
   
   class Col : public Node {
      std::string _cName,_rName;
      double              _coef;
      bool            _forceInt;
   public:
      typedef std::shared_ptr<Col> Ptr;
      Col(std::string&& rName,double v) : _rName(std::move(rName)),_coef(v),_forceInt(false) {}
      std::string getName()  override   { return _cName;}
      void setName(std::string&& n)     { _cName = std::move(n);}
      const std::string& getRowName() const { return _rName;}
      double getCoef() const { return _coef;}
      bool isForcedInt() const { return _forceInt;}
      void forceInt() { _forceInt = true;}
      ostream& print(ostream& os) const override;
   };
   
   class Rhs : public Node {
      std::string _rhsName,_cName;
      double _rhs;
   public:
      typedef std::shared_ptr<Rhs> Ptr;
      Rhs(std::string&& cName,double v) : _cName(std::move(cName)),_rhs(v) {}
      std::string getName() override    { return _cName;}
      std::string getRHSName()          { return _rhsName;}
      void setName(std::string&& n)     { _rhsName = std::move(n);}
      double getRHS() const             { return _rhs;}
      ostream& print(ostream& os) const override;
   };
   
   class Bound: public Node {
   public:
      enum Type { Ub,Lb,Fx,Fr,By,Mi,Pl,Li,Ui,Sc};
   private:
      enum Type _type;
      std::string _bName;
      std::string _vName;
      double _bnd;
   public:
      typedef std::shared_ptr<Bound> Ptr;
      Bound(enum Type t,std::string&& bn,std::string&& vn,double val) : _type(t),_bName(std::move(bn)),_vName(std::move(vn)),_bnd(val) {}
      std::string getName() override    { return _vName;}
      std::string getBoundName() { return _bName;}
      double getBound() const    { return _bnd;}
      Type getType() const       { return _type;}
      ostream& print(ostream& os) const  override;
   };
   
   class Program : public Decl {
      enum Sense { Min,Max};
      std::string _name;
      enum Sense _sense;
      std::string  _obj;
      std::list<AST::Row::Ptr> _rows;
      std::list<AST::Col::Ptr> _cols;
      std::list<AST::Rhs::Ptr> _rhs;
      std::list<AST::Bound::Ptr> _bounds;
   public:
      Program(char* n,char* s,char* o,
              std::list<AST::Row::Ptr>* rows,
              std::list<AST::Col::Ptr>* cols,
              std::list<AST::Rhs::Ptr>* r,
              std::list<AST::Bound::Ptr>* b);
      ~Program() {}
      ostream& print(ostream& os) const;
      Model::Ptr makeModel();
   };
};

#endif
