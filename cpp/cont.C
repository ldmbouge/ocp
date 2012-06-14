//
//  cont.m
//  Clo
//
//  Created by Laurent Michel on 5/11/11.
//  Copyright 2011 CSE. All rights reserved.
//

#include "cont.H"
#include <iostream>
#include <iomanip>

NSCont::NSCont() 
{
   _used=0;
   _length = 0;
   _start = 0;
   _data  = 0;
   _ref=1;
}

void NSCont::saveStack(char* buf,size_t l,void*s) 
{
   _length = l;
   _start  = s;
   _data   = buf;
}
void NSCont::addRef() { ++_ref;}
int NSCont::nbCalls() { return _used;}

NSCont::~NSCont()
{
   free(_data);
}

using namespace std;
void NSCont::call()
{
#if defined(__x86_64__)
   //cout << "ABOUT to NSCont::call" << endl;
   register struct Ctx64* ctx = &_target;
   ctx->rax = (long)this;
   restoreCtx(ctx,(char*)_start,_data,_length);
#else
   _longjmp(_target,(long)this); // dot not save signal mask --> overhead   
#endif
}


NSCont* NSCont::takeContinuation() {
   NSCont* k = new NSCont;
#if defined(__x86_64__)
   struct Ctx64* ctx = &k->_target;
   register NSCont* resume = saveCtx(ctx,k);
   if (resume != 0) {
      resume->_used++;
      return resume;      
   } else return k;
#else
   int len = getContBase() - (char*)&k;
   char* buf = new char[len];
   memcpy(buf,&k,len);
   k->saveStack(buf,len,&k);
   register NSCont* jmpval = (NSCont*)_setjmp(k->_target);   
   if (jmpval != 0) {
      memcpy(jmpval->_start,jmpval->_data,jmpval->_length);
      jmpval->_used++;
      return jmpval;
   } else 
      return k;   
#endif
}

void NSCont::callContinuation(NSCont* c)
{
   c->call();
}

void NSCont::releaseContinuation(NSCont* c)
{
   if(--(c->_ref) == 0 )
      delete c;   
}

