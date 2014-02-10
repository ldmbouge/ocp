/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "LSFactory.h"
#import "LSIntVar.h"

@implementation LSFactory
+(id<LSVar>)intVar:(id<LSEngine>)engine value:(ORInt)v
{
   return [[LSIntVar alloc] initWithEngine:engine andValue:v];
}

@end
