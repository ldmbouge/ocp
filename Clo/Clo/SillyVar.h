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
-(SillyVar*)initWithLow:(ORInt)l up:(ORInt)u;
- (void)dealloc;
-(ORInt)min;
-(ORInt)max;
-(ORInt)imin;
-(ORInt)imax;
-(void)set:(ORInt)v;
-(void)reset;
-(ORInt)get;
-(bool)bound;
- (NSString *)description;
@end
