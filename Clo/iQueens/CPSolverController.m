/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import "CPEngineController.h"
#import "objcp/CPConstraint.h"
#import "objcp/DFSController.h"
#import "objcp/CPEngine.h"
#import "objcp/CPSolver.h"
#import "objcp/CPFactory.h"

#import "CPSecondViewController.h"


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

-(void)visualize:(id<ORIntVarArray>)x on:(id<CPSolver>)cp
{
   UIBoardController* board = [_view1 boardController];
   ORBounds dom = [[x at: [x low]] bounds];
   ORRange cols = {[x low],[x up]};
   ORRange rows = {dom.min,dom.max};
   id grid = [board makeGrid:rows by: cols];
   for(ORInt i = [x low];i <= [x up];i++) {
      id<ORIntVar> xi = [x at:i];
      [cp add: [CPFactory watchVariable:xi 
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
                ]];
   }
   [board watchSearch:cp 
              onChoose: ^void() { [board pause];}  
                onFail: ^void() { [board pause];}
    ];
}

-(void)runModel 
{
   int n = 8;
   ORRange R = (ORRange){1,n};
   id<CPSolver> cp = [CPFactory createSolver];
   id<ORInteger> nbSolutions = [CPFactory integer:cp value:0];
   [CPFactory intArray:cp range: R with: ^int(int i) { return i; }]; 
   id<ORIntVarArray> x = [CPFactory intVarArray:cp range:R domain: R];
   id<ORIntVarArray> xp = [CPFactory intVarArray:cp range: R with: ^id<ORIntVar>(int i) { return [CPFactory intVar: [x at: i] shift:i]; }]; 
   id<ORIntVarArray> xn = [CPFactory intVarArray:cp range: R with: ^id<ORIntVar>(int i) { return [CPFactory intVar: [x at: i] shift:-i]; }]; 
   [cp solveAll: 
    ^() {
       [cp add: [CPFactory alldifferent: x consistency:ValueConsistency]];
       [cp add: [CPFactory alldifferent: xp consistency:ValueConsistency]];
       [cp add: [CPFactory alldifferent: xn consistency:ValueConsistency]];
       [self visualize:x on:cp];
    }   
          using: 
    ^() {
       [CPLabel array: x orderedBy: ^int(int i) { return [[x at:i] domsize];}];
       [_view2 performSelectorOnMainThread:@selector(insertText:) 
                                withObject:[NSString stringWithFormat:@"sol [%d]: %@\n",[nbSolutions value],[x description]] 
                             waitUntilDone:YES];
       [nbSolutions incr];
    }
    ];
   [_view2 performSelectorOnMainThread:@selector(insertText:) 
                            withObject:[NSString stringWithFormat:@"GOT %ld solutions\nSolver status %@",[nbSolutions value],cp] 
                         waitUntilDone:NO];
   [cp release];
   [CPFactory shutdown];
}

@end
