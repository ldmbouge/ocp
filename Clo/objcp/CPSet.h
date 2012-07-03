/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <Foundation/Foundation.h>

@protocol CPIntSet <NSObject> 
-(bool) member: (CPInt) v;
-(void) insert: (CPInt) v;
-(void) delete: (CPInt) v;
-(CPInt) size;
-(NSString*) description;
-(id<CP>) cp;
-(id<IntEnumerator>) enumerator;
@end
