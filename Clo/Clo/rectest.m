/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <Foundation/Foundation.h>
#import "SillyVar.h"


void recTraverse(NSMutableArray* tab,int at,int n,int *cnt) {
   if (at >= n) {
      (*cnt)++;
      return;
   } else {
      SillyVar* cv = [tab objectAtIndex:at];      
      for(int i=0;i < [cv max];i++) {
	 [cv set:i];
	 recTraverse(tab,at+1,n,cnt);
	 [cv reset];
      }
   }
}

int main()
{
   int cnt =0;
   const int nbv = 8;
   NSMutableArray* vars = [[NSMutableArray alloc] initWithCapacity:nbv];
   for(int i=0;i< nbv;i++)
      [vars addObject: [[SillyVar alloc] initWithLow:0 up:10]];
   NSLog(@"Array before starting: %@\n",vars);
   recTraverse(vars,0,nbv,&cnt);
   NSLog(@"Finished with %d sols\n",cnt);
   return 0;
}
