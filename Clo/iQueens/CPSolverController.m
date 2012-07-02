/************************************************************************
 MIT License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 Permission is hereby granted, free of charge, to any person obtaining
 a copy of this software and associated documentation files (the
 "Software"), to deal in the Software without restriction, including
 without limitation the rights to use, copy, modify, merge, publish,
 distribute, sublicense, and/or sell copies of the Software, and to
 permit persons to whom the Software is furnished to do so, subject to
 the following conditions:
 
 The above copyright notice and this permission notice shall be
 included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 ***********************************************************************/

#import "CPSolverController.h"
#import "objcp/CPConstraint.h"
#import "objcp/DFSController.h"
#import "objcp/CPSolver.h"
#import "objcp/cp.h"
#import "objcp/CPFactory.h"
#import "objcp/CPLabel.h"

#import "CPSecondViewController.h"


@implementation CPSolverController

-(CPSolverController*)init 
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

-(void)visualize:(id<CPIntVarArray>)x on:(id<CP>)cp
{
   UIBoardController* board = [_view1 boardController];
   CPBounds dom;
   [[x at: [x low]] bounds:&dom];
   CPRange cols = {[x low],[x up]};
   CPRange rows = {dom.min,dom.max};
   id grid = [board makeGrid:rows by: cols];
   for(CPInt i = [x low];i <= [x up];i++) {
      id<CPIntVar> xi = [x at:i];
      [cp add: [CPFactory watchVariable:xi 
                            onValueLost:^void(CPInt val) {
                               [board toggleGrid:grid row:val col:i to:Removed];
                            } 
                            onValueBind:^void(CPInt val) {
                               [board toggleGrid:grid row:val col:i to:Required];
                            } 
                         onValueRecover:^void(CPInt val) {
                            [board toggleGrid:grid row:val col:i to:Possible];
                         }
                          onValueUnbind:^void(CPInt val) {
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
   CPRange R = (CPRange){1,n};
   id<CP> cp = [CPFactory createSolver];
   id<CPInteger> nbSolutions = [CPFactory integer:cp value:0];
   [CPFactory intArray:cp range: R with: ^int(int i) { return i; }]; 
   id<CPIntVarArray> x = [CPFactory intVarArray:cp range:R domain: R];
   id<CPIntVarArray> xp = [CPFactory intVarArray:cp range: R with: ^id<CPIntVar>(int i) { return [CPFactory intVar: [x at: i] shift:i]; }]; 
   id<CPIntVarArray> xn = [CPFactory intVarArray:cp range: R with: ^id<CPIntVar>(int i) { return [CPFactory intVar: [x at: i] shift:-i]; }]; 
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
