/*
 *  MPSReader.cpp
 *  MPSReader
 *
 *  Created by Laurent Michel on 5/24/16.
 *  Copyright © 2016 Laurent Michel. All rights reserved.
 *
 */

#include <iostream>
#include "MPSReader.hpp"
#include "MPSReaderPriv.hpp"
#include "parser.hpp"
#include "ast.hpp"

namespace MPSReader {
   
   Model::Ptr readMPSFile(const std::string& fname) {
      Parser p;
      p.run(fname.c_str());
      AST::Program* root = dynamic_cast<AST::Program*>(p.getRoot());
      Model::Ptr model;
      if (root) {
         //std::cout << *root << std::endl;
         model = root->makeModel();
      }
      delete root;
      return model;
   }
   
};