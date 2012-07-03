/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/


#import <Foundation/Foundation.h>
#import "objcp/CPConstraint.h"
#import "objcp/CPFactory.h"
#import "objcp/CPLabel.h"

class H {
   id<CPExpr> _h;
public:
   H(id<CPExpr> v) { _h = v;}
   operator id<CPExpr>() { return _h;}
   H operator+(H e2)
   {
      return [CPFactory expr:_h add:e2];
   }
   H operator-(H e2)
   {
      return [CPFactory expr:_h sub:e2];
   }
   H operator*(H e2)
   {
      return [CPFactory expr:_h mul:e2];
   }
   H operator==(id<CPExpr> e2)
   {
      return [CPFactory expr:_h equal:e2];
   }
   H operator==(H e2)
   {
      return [CPFactory expr:_h equal:e2];
   }
};

H operator-(id<CPIntVar> x,H y)
{
   return [CPFactory expr:x sub:y];
}
H operator==(id<CPIntVar> x,H y)
{
   return [CPFactory expr:x equal:y];
}

int main(int argc, const char * argv[])
{
   @autoreleasepool {
      int n = 10;
      CPRange R = (CPRange){1,n};
      CPRange D = (CPRange){-n+1,n-1};
      id<CP> cp = [CPFactory createSolver];      
      id<CPIntVarArray> costas = [CPFactory intVarArray: cp range:R domain: R];         
      id<CPIntVarMatrix>  diff = [CPFactory intVarMatrix:cp range:R : R domain:D];
      id<CPHeuristic> h = [CPFactory createFF:cp];
      [cp solve: ^{
         [cp add:[CPFactory alldifferent:costas]];
         for(CPUInt i=R.low;i<=R.up;i++) {
            for(CPUInt j=R.low;j<=R.up;j++) {
               if (i < j)
                  [cp add:[CPFactory expr:H([diff at:i :j]) == H([costas at:j]) - H([costas at:j-i])]];
               else [cp add:[CPFactory equalc:[diff at:i :j] to:0]];
            }            
         }
         for(CPUInt i=1;i<=n-1;i++) {
            id<CPIntVarArray> slice = [CPFactory intVarArray:cp range:(CPRange){i+1,n} with:^id<CPIntVar>(CPInt j) {
               return [diff at:i :j];
            }];
            [cp add:[CPFactory alldifferent:slice]];
         }
         [cp add:[CPFactory less:[costas at:1] to:[costas at:n]]];
         for(CPUInt i=R.low;i<=R.up;i++) {
            for(CPUInt j=i+1;j<=R.up;j++) {
               [cp add:[CPFactory notEqualc:[diff at:i :j] to:0]];
            }
         }
         for (CPInt k=3; k<=n; k++) {
            for (CPInt l=k+1; l<=n; l++) {
               [cp add:[CPFactory expr:H([diff at:k-2 :l-1]) + H([diff at:k :l]) ==
                                       H([diff at:k-1 :l-1]) + H([diff at:k-1 :l])]];
            }
         }
                  
         NSData* archive = [NSKeyedArchiver archivedDataWithRootObject:cp];
         BOOL ok = [archive writeToFile:@"fdmul.CParchive" atomically:NO];
         NSLog(@"Writing ? %s",ok ? "OK" : "KO");
         
      } using:^{
         [CPLabel heuristic:h];
         NSLog(@"Solution: %@",costas);
         NSLog(@"Solver: %@",cp);
      }];
      [cp release];
      [CPFactory shutdown];
   }
   return 0;
}

