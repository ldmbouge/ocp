//
//  cont.h
//  Clo
//
//  Created by Laurent Michel on 5/11/11.
//  Copyright 2011 CSE. All rights reserved.
//

#ifndef __CONT_H
#define __CONT_H

#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include "context.H"

class NSCont {
#if defined(__x86_64__)
   long _pad;
   struct Ctx64 _target __attribute__ ((aligned(16))) ;
#else
   jmp_buf _target;
#endif
   size_t _length;
   void* _start;   
   char* _data;
   int _used;
   int _ref; // reference count
 public:
   NSCont();
   ~NSCont();
   void saveStack(char* buf,size_t l,void* s);
   void call(); 
   int nbCalls();
   void addRef();
   static NSCont* takeContinuation();
   static void callContinuation(NSCont* c);
   static void releaseContinuation(NSCont* c);
};
   
#endif
