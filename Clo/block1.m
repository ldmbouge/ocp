/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <Foundation/NSObject.h>

int foo(int (^b)(int)) {
   return b(5);
}

int main() {

   int y = 10;
   int z = foo(^(int x) {
	 return y + x; 
      });
   NSLog(@"result is %d\n",z);
}
