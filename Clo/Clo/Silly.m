/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import "Silly.h"


@implementation Silly

- (id)init:(CPInt)x y:(CPInt)y;
{
    self = [super init];
    _x = x;
    _y = y;
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

-(long)callMe:(long) z 
{
   long r =  (long)_x * z + _y;
   return r;
}

@end
