/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import "SillyVar.h"


@implementation SillyVar

-(SillyVar*)initWithLow:(CPInt)l up:(CPInt)u
{
   self = [super init];
   _imin = _min = l;
   _imax = _max = u;   
   return self;   
}
-(CPInt)imin
{
   return _imin;
}
-(CPInt)imax 
{
   return _imax;
}
-(CPInt)min
{
   return _min;
}
-(CPInt)max 
{
   return _max;
}
-(void)set:(CPInt)v
{
   _min = _max = v;
}
-(void)reset
{
   _min = _imin;
   _max = _imax;
}

-(CPInt)get 
{
   return _min;
}
-(bool)bound
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
