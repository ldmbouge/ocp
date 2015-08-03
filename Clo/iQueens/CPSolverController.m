/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import "CPSolverController.h"
#import "CPSecondViewController.h"

#import <ORModeling/ORModeling.h>
#import <ORProgram/ORProgram.h>


@implementation CPEngineController

-(CPEngineController*)init 
{
   self = [super init];
   _view1 = nil;
   _view2 = nil;
   return self;
}

-(id)bindControllerOne:(CPFirstViewController*)svc
{
   _view1 = svc;
   return self;
}

-(id)bindControllerTwo:(CPSecondViewController*)svc
{
   _view2 = svc;
   return self;
}

-(void)visualize:(id<ORIntVarArray>)x on:(id<CPProgram>)cp
{
   UIBoardController* board = [_view1 boardController];
   id grid = [board makeGrid:[[x at:[x  low]] domain] by: [x range]];
   for(ORInt i = [x low];i <= [x up];i++) {
      id<ORIntVar> xi = [x at:i];
      [cp addConstraintDuringSearch: [CPFactory solver:cp
                                         watchVariable:xi
                            onValueLost:^void(ORInt val) {
                               [board toggleGrid:grid row:val col:i to:Removed];
                            } 
                            onValueBind:^void(ORInt val) {
                               [board toggleGrid:grid row:val col:i to:Required];
                            } 
                         onValueRecover:^void(ORInt val) {
                            [board toggleGrid:grid row:val col:i to:Possible];
                         }
                          onValueUnbind:^void(ORInt val) {
                             [board toggleGrid:grid row:val col:i to:Possible];
                          }
                ]
       ];
   }
   [board watchSearch:[cp explorer]
              onChoose: ^void() { [board pause];}  
                onFail: ^void() { [board pause];}
    ];
}

-(void)runModel 
{
   int n = 8;
   id<ORModel> model = [ORFactory createModel];
   id<ORIntRange> R = [ORFactory intRange: model low: 0 up: n-1];
   id<ORIntVarArray> x  = [ORFactory intVarArray:model range:R domain: R];
   id<ORIntVarArray> xp = [ORFactory intVarArray:model range:R with: ^id<ORIntVar>(ORInt i) { return [ORFactory intVar:model var:[x at: i] shift:i]; }];
   id<ORIntVarArray> xn = [ORFactory intVarArray:model range:R with: ^id<ORIntVar>(ORInt i) { return [ORFactory intVar:model var:[x at: i] shift:-i]; }];
   [model add: [ORFactory alldifferent: x]];
   [model add: [ORFactory alldifferent: xp]];
   [model add: [ORFactory alldifferent: xn]];
   id<CPProgram> cp = [ORFactory createCPProgram:model];
   __block ORInt nbSolutions = 0;
   [cp solveAll: ^{
      [self visualize:x on:cp];
      [cp labelArray: x orderedBy: ^ORFloat(int i) { return [cp domsize:x[i]];}];
      @autoreleasepool {
         id<ORIntArray> xs = [ORFactory intArray:cp range:[x range] with:^ORInt(ORInt i) {
            return [cp intValue:x[i]];
         }];
         NSString* buf = [NSString stringWithFormat:@"sol [%d]: %@\n",nbSolutions,xs];
         [_view2 performSelectorOnMainThread:@selector(insertText:)
                                  withObject:buf
                               waitUntilDone:YES];
      }
      nbSolutions++;
    }
    ];
   [_view2 performSelectorOnMainThread:@selector(insertText:) 
                            withObject:[NSString stringWithFormat:@"GOT %d solutions\nSolver status %@",nbSolutions,cp]
                         waitUntilDone:NO];
   [ORFactory shutdown];
}

@end
