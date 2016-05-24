//
//  main.cpp
//  mpsReader
//
//  Created by Laurent Michel on 5/23/16.
//  Copyright © 2016 Laurent Michel. All rights reserved.
//

#include <iostream>
#include <iomanip>
#include "parser.hpp"
#include "ast.hpp"

int main(int argc, const char * argv[]) {
   using namespace std;
   // insert code here...
   if (argc <= 1) {
      std::cout << "usage is: mpsReader <filename>" << std::endl;
      return 1;
   }
   Parser* p = new Parser();
   p->run(argv[1]);
   AST::Program* root = dynamic_cast<AST::Program*>(p->getRoot());
   if (root) {
      std::cout << *root << std::endl;
      auto model = root->makeModel();
      cout << *model << endl;
   }
   delete p;
   return 0;
}
