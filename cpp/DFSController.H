//
//  DFSController.h
//  Clo
//
//  Created by Laurent Michel on 5/22/11.
//  Copyright 2011 CSE. All rights reserved.
//

#ifndef __DFSCONTROLLER_H
#define __DFSCONTROLLER_H

#include "CPController.H"
#include <vector>
#include <functional>

class DFSController : public  CPController {
   std::vector<NSCont*>  _tab;
   std::vector<std::function<void(void)> > _clo;
   NSCont*        _start;
   NSCont*        _exit;
 public:
   DFSController();
   ~DFSController() {}
   void addChoice(NSCont* k);
   void addClosure(std::function<void(void)> clo);
   std::function<void(void)> popClosure();
   void fail();
   void searchWithRestart(NSCont* k,NSCont* ex);
};

void tryb(CPController& ctrl,std::function<void(void)> left,std::function<void(void)> right);
void solveall(CPController& ctrl,const std::function<void(void)>& start,const std::function<void(void)>& exit);

#endif
