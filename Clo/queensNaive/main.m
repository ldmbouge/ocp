/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <ORModeling/ORModeling.h>
#import <ORModeling/ORModelTransformation.h>
#import <ORProgram/ORProgramFactory.h>
#import <ORProgram/ORProgramFactory.h>


NSString* indent(int t)
{
   NSMutableString* tab = [NSMutableString stringWithCapacity:64];
   for(int i=0;i<t;i++)
      [tab appendString:@"   "];
   return tab;
}
int main (int argc, const char * argv[])
{
   int n = 8;
   id<ORModel> model = [ORFactory createModel];
   id<ORIntRange> R = RANGE(model,0,n-1);
   id<ORInteger> nbSolutions = [ORFactory integer: model value:0];
   id<ORIntVarArray> x = [ORFactory intVarArray:model range:R domain: R];
   for(ORUInt i =0;i < n; i++) {
      for(ORUInt j=i+1;j< n;j++) {
         [model add: [x[i] neq: x[j]]];
         [model add: [x[i] neq: [x[j] plus: @(i-j)]]];
         [model add: [x[i] neq: [x[j] plus: @(j-i)]]];
      }
   }
//   NSLog(@"initial model: %@",model);
//   NSLog(@"flat    model: %@",fm);
   id<CPProgram> cp = [ORFactory createCPProgram: model];
   
   [cp solveAll:
    ^() {
      [cp labelArray: x ];
/*       NSLog(@"LEVEL START: %d",[[cp tracer] level]);
       for(ORInt i=0;i<n;i++) {
          while (![x[i] bound]) {
             ORInt min = [x[i] min];
             [cp try:^{
                NSLog(@"%@x[%d]==%d -- | %d |",indent(i),i,min,[[cp tracer] level]);
                [cp label:x[i] with:min];
             } or:^{
                NSLog(@"%@x[%d]!=%d -- | %d |",indent(i),i,min,[[cp tracer] level]);
                [cp diff:x[i] with:min];
                //[cp add:[x[i] neqi: min]];
             }];
          }
       }*/
       @autoreleasepool {
          NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
          for(int i = 0; i < n; i++)
             [buf appendFormat:@"%d ",[x[i] value]];
          NSLog(@"sol [%d]: %@\n",[nbSolutions value],buf);
       }
      [nbSolutions incr];
    }
    ];
   printf("GOT %d solutions\n",[nbSolutions value]);
   
   
   NSLog(@"Solver status: %@\n",cp);
   NSLog(@"Quitting");
   //[h release];
   [cp release];   
   [ORFactory shutdown];
   return 0;
}

