/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <Foundation/Foundation.h>


@interface SillyVar : NSObject {
@private
   int _imin;
   int _imax;
   int _min;
   int _max;
}
-(SillyVar*)initWithLow:(CPInt)l up:(CPInt)u;
- (void)dealloc;
-(CPInt)min;
-(CPInt)max;
-(CPInt)imin;
-(CPInt)imax;
-(void)set:(CPInt)v;
-(void)reset;
-(CPInt)get;
-(bool)bound;
- (NSString *)description;
@end
