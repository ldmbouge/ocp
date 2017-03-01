/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORUtilities/ORUtilities.h>

#if defined(__linux__)
 #define TRUE 1
 #define FALSE 0
#endif

@protocol CPSolver;

typedef ORStatus(*UBType)(id,SEL,...);
typedef void (^ORIntClosure)(ORInt);


typedef enum {
   CPChecked,
   CPTocheck,
   CPOff
} CPTodo;
