/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/


#import <ORFoundation/ORFactory.h>
#import <objcp/CPConstraint.h>
#import <objcp/CPFactory.h>
#import <ORModeling/ORModeling.h>
#import <ORProgram/ORConcretizer.h>

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
      int n = 15;
      id<ORModel> mdl = [ORFactory createModel];
      id<ORIntRange> R = RANGE(mdl,1,n);
      id<ORIntRange> D = RANGE(mdl,-n+1,n-1);
          
      id<ORIntVarArray> costas = [ORFactory intVarArray: mdl range:R domain: R];
      id<ORIntVarMatrix>  diff = [ORFactory intVarMatrix:mdl range:R : R domain:D];
      [mdl add:[ORFactory alldifferent:costas]];
      for(ORUInt i=R.low;i<=R.up;i++) {
         for(ORUInt j=R.low;j<=R.up;j++) {
            if (i < j)
               [mdl add:([diff at:i :j]) == H([costas at:j]) - H([costas at:j-i])];
            else [mdl add:[[diff at:i :j] eqi: 0]];
         }
      }
      for(ORInt i=1;i<=n-1;i++) {
         id<ORIntVarArray> slice = All(mdl,ORIntVar, j, RANGE(mdl,i+1,n), [diff at:i :j]);
         [mdl add:[ORFactory alldifferent:slice]];
      }
      [mdl add:[[costas at:1] leq:[costas at:n]]];
      for(ORUInt i=R.low;i<=R.up;i++) {
         for(ORUInt j=i+1;j<=R.up;j++) {
            [mdl add:[[diff at:i :j] neqi:0]];
         }
      }
      for (ORInt k=3; k<=n; k++) {
         for (ORInt l=k+1; l<=n; l++) {
            [mdl add:H([diff at:k-2 :l-1]) + H([diff at:k :l]) ==
             H([diff at:k-1 :l-1]) + H([diff at:k-1 :l])];
         }
      }
      
      //         NSData* archive = [NSKeyedArchiver archivedDataWithRootObject:cp];
      //         BOOL ok = [archive writeToFile:@"fdmul.CParchive" atomically:NO];
      //         NSLog(@"Writing ? %s",ok ? "OK" : "KO");

      id<CPProgram> cp = [ORFactory createCPProgram:mdl];
      id<CPHeuristic> h = [ORFactory createABS:cp];
      
      [cp solve: ^{
          NSLog(@"Search");
         [cp labelHeuristic:h];
         //[cp labelArray:costas];
         NSLog(@"Solution: %@",costas);
         NSLog(@"Solver: %@",cp);
      }];
      [cp release];
      [ORFactory shutdown];
   }
   return 0;
}

