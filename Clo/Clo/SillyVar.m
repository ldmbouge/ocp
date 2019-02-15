/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import "SillyVar.h"


@implementation SillyVar

-(SillyVar*)initWithLow:(ORInt)l up:(ORInt)u
{
   self = [super init];
   _imin = _min = l;
   _imax = _max = u;   
   return self;   
}
-(ORInt)imin
{
   return _imin;
}
-(ORInt)imax 
{
   return _imax;
}
-(ORInt)min
{
   return _min;
}
-(ORInt)max 
{
   return _max;
}
-(void)set:(ORInt)v
{
   _min = _max = v;
}
-(void)reset
{
   _min = _imin;
   _max = _imax;
}

-(ORInt)get 
{
   return _min;
}
-(ORBool)bound
{
   return _min == _max;
}

- (void)dealloc
{
    [super dealloc];
}
- (NSString *)description
{
   return [NSString stringWithFormat:@"%d,%d = %d,%d",_imin,_imax,_min,_max];
}
@end
