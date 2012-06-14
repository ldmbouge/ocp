//
//  CPController.h
//  Clo
//
//  Created by Laurent Michel on 5/22/11.
//  Copyright 2011 CSE. All rights reserved.
//

#ifndef __CP_CONTROLLER_H
#define __CP_CONTROLLER_H

#include "cont.H"
#include <functional>

class CPController {
 public:
   CPController() {}
   virtual ~CPController() = 0;
   virtual void addChoice(NSCont* k) = 0;
   virtual void fail() = 0;
   virtual void searchWithRestart(NSCont* k,NSCont* ex) = 0;
   virtual void addClosure(std::function<void(void)> clo) = 0;
   virtual std::function<void(void)> popClosure() = 0;
};

#endif
