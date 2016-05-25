#ifndef __PARSER_H
#define __PARSER_H

namespace AST {
   class Node;
}

class Parser {
   AST::Node* _root;
   bool       _integral;
public: 
   Parser();
   ~Parser();
   void startIntegral() { _integral = true;}
   void stopIntegral()  { _integral = false;}
   bool isIntegral()    { return _integral;}
   void run(const char* fn = 0);
   void saveRoot(AST::Node* root) { _root = root;}
   AST::Node* getRoot() { return _root;}
};

#endif
