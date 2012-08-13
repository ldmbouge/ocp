/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import "CPError.h"
#import "CPController.h"
#import "ORTrailI.h"

@implementation CPHeist
-(CPHeist*)initCPProblem:(NSCont*)c from:(Checkpoint*)cp
{
   self = [super init];
   _cont = [c retain];
   _theCP = [cp retain];
   return self;
}
-(void)dealloc
{
   [_cont letgo];
   [_theCP release];
   [super dealloc];
}
-(NSCont*)cont
{
   return _cont;
}
-(Checkpoint*)theCP
{
   return _theCP;
}
@end

