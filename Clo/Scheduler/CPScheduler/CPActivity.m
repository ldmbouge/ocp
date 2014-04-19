/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2014 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <Foundation/Foundation.h>
#import <CPScheduler/CPActivity.h>
#import <objcp/CPVar.h>

@implementation CPActivity
{
   id<CPIntVar> _start;
   ORInt _duration;
}
-(id<CPActivity>) initCPActivity: (id<CPIntVar>) start duration: (ORInt) duration
{
   self = [super init];
   _start = start;
   _duration = duration;
   return self;
}
-(id<CPIntVar>) start
{
   return _start;
}
-(ORInt) duration
{
   return _duration;
}
@end
