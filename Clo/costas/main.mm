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
   id<ORExpr> _h;
public:
   H(id<ORExpr> v) { _h = v;}
   operator id<ORExpr>() { return _h;}
   H operator+(H e2)
   {
      return [_h plus:e2];
   }
   H operator-(H e2)
   {
      return [_h sub:e2];
   }
   H operator*(H e2)
   {
      return [_h mul:e2];
   }
   H operator==(id<ORExpr> e2)
   {
      return [_h eq:e2];
   }
   H operator==(H e2)
   {
      return [_h eq:e2];
   }
};

H operator-(id<ORIntVar> x,H y)
{
   return [x sub:y];
}
H operator==(id<ORIntVar> x,H y)
{
   return [x eq:y];
}

int main(int argc, const char * argv[])
{
   @autoreleasepool {
      int n = 10;
      id<CPSolver> cp = [CPFactory createSolver];
      id<ORIntRange> R = RANGE(cp,1,n);
      id<ORIntRange> D = RANGE(cp,-n+1,n-1);
          
      id<ORIntVarArray> costas = [CPFactory intVarArray: cp range:R domain: R];         
      id<ORIntVarMatrix>  diff = [CPFactory intVarMatrix:cp range:R : R domain:D];
      id<CPHeuristic> h = [CPFactory createFF:cp];
      
      [cp add:[CPFactory alldifferent:costas]];
      for(ORUInt i=R.low;i<=R.up;i++) {
         for(ORUInt j=R.low;j<=R.up;j++) {
            if (i < j)
               [cp add:([diff at:i :j]) == H([costas at:j]) - H([costas at:j-i])];
            else [cp add:[CPFactory equalc:[diff at:i :j] to:0]];
         }
      }
      for(ORInt i=1;i<=n-1;i++) {
         id<ORIntVarArray> slice = ALL(ORIntVar, j, RANGE(cp,i+1,n), [diff at:i :j]);
         [cp add:[CPFactory alldifferent:slice]];
      }
      [cp add:[CPFactory less:[costas at:1] to:[costas at:n]]];
      for(ORUInt i=R.low;i<=R.up;i++) {
         for(ORUInt j=i+1;j<=R.up;j++) {
            [cp add:[CPFactory notEqualc:[diff at:i :j] to:0]];
         }
      }
      for (ORInt k=3; k<=n; k++) {
         for (ORInt l=k+1; l<=n; l++) {
            [cp add:H([diff at:k-2 :l-1]) + H([diff at:k :l]) ==
             H([diff at:k-1 :l-1]) + H([diff at:k-1 :l])];
         }
      }
      
      //         NSData* archive = [NSKeyedArchiver archivedDataWithRootObject:cp];
      //         BOOL ok = [archive writeToFile:@"fdmul.CParchive" atomically:NO];
      //         NSLog(@"Writing ? %s",ok ? "OK" : "KO");

      [cp solve: ^{
          NSLog(@"Search");
         [CPLabel heuristic:h];
         NSLog(@"Solution: %@",costas);
         NSLog(@"Solver: %@",cp);
      }];
      [cp release];
      [CPFactory shutdown];
   }
   return 0;
}

