//
//  DFSController.m
//  Clo
//
//  Created by Laurent Michel on 5/22/11.
//  Copyright 2011 CSE. All rights reserved.
//

#include "DFSController.H"
#include <iostream>
#include <iomanip>
using namespace std;

CPController::~CPController()
{}

DFSController::DFSController() 
{
   _start = _exit = 0;
}

void DFSController::addChoice(NSCont* k) 
{
   _tab.push_back(k);
}

void DFSController::addClosure(std::function<void(void)> clo)
{
   _clo.push_back(clo);
}

std::function<void(void)> DFSController::popClosure()
{
   std::function<void(void)> last = _clo.back();
   _clo.pop_back();
   return last;
}

void DFSController::fail()
{   
   long ofs = _tab.size()-1;
   if (ofs >= 0) {
      NSCont* k = _tab.back();
      _tab.pop_back();
      if (k!=NULL) {
         k->call();
      }
      else
         _exit->call();
   } else
      _exit->call();
}
void DFSController::searchWithRestart(NSCont* k,NSCont* ex)
{
   _start  = k;
   _exit   = ex;
}

void tryb(CPController& ctrl,std::function<void(void)> left,std::function<void(void)> right)
{
   bool goLeft=false;  
   ctrl.addClosure(right);
   ctrl.addClosure(left);
   right = 0;
   left = 0;
   NSCont* k = NSCont::takeContinuation();
   //cout << "Got back from takeCont:" << k << " : " << k->nbCalls() << endl;
   //cout << "Passed assign..." << endl;
   if (k->nbCalls() == 0)
      goLeft = true;
   if (goLeft) {
      ctrl.addChoice(k);
      ctrl.popClosure()();
   } else {
      //cout << "About to release! " << endl;
      NSCont::releaseContinuation(k);
      //cout << "We released it!" << endl; 
      ctrl.popClosure()();
   }
   right = 0;
   left = 0;
}

void solveall(CPController& ctrl,const std::function<void(void)>& start,const std::function<void(void)>& exit)
{
   NSCont* k = NSCont::takeContinuation();
   if (k->nbCalls()==0) {
      NSCont* x = NSCont::takeContinuation();
      if (x->nbCalls()==0) {
         ctrl.searchWithRestart(k,x);
         start();
         ctrl.fail();
      } else {
         exit();
      }
   } else {
      start();
   }
}
