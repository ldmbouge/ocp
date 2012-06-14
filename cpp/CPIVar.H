//
//  CPIVar.h
//  Clo
//
//  Created by Laurent Michel on 5/22/11.
//  Copyright 2011 CSE. All rights reserved.
//

#ifndef __CPIVAR_H
#define __CPIVAR_H

class CPIVar {
   int _imin;
   int _imax;
   int _min;
   int _max;
 public:
   CPIVar(int l,int u);
   ~CPIVar() {}
   int getMin() { return _min;}
   int getMax() { return _max;}
   int getIMin() { return _imin;}
   int getIMax() { return _imax;}
   void set(int v);
   void reset();
   int get();
   bool bound();
};

#endif
