//
//  CPIVar.m
//  Clo
//
//  Created by Laurent Michel on 5/22/11.
//  Copyright 2011 CSE. All rights reserved.
//

#include "CPIVar.H"

CPIVar::CPIVar(int l,int u)
{
   _imin = _min = l;
   _imax = _max = u;   
}

void CPIVar::set(int v)
{
   _min = _max = v;
}

void CPIVar::reset()
{
   _min = _imin;
   _max = _imax;
}

int CPIVar::get()
{
   return _min;
}

bool CPIVar::bound()
{
   return _min == _max;
}
