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


#import "CPAppDelegate.h"
#import "objcp/CPConstraint.h"
#import "objcp/DFSController.h"
#import "objcp/CPSolver.h"
#import "objcp/cp.h"
#import "objcp/CPFactory.h"
#import "objcp/CPLabel.h"
#import "objcp/NSBoardController.h"

@implementation CPAppDelegate

@synthesize theView = _theView;
@synthesize window = _window;

- (void)dealloc
{
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
   // Insert code here to initialize your application
   _board = [[NSBoardController alloc] initBoardController:_theView];
}

-(void)visualize:(id<CPIntVarArray>)x on:(id<CP>)cp
{
   CPBounds dom;
   [[x at: [x low]] bounds:&dom];
   CPRange cols = {[x low],[x up]};
   CPRange rows = {dom.min,dom.max};
   id grid = [_board makeGrid:rows by: cols];
   for(CPInt i = [x low];i <= [x up];i++) {
      id<CPIntVar> xi = [x at:i];
      [cp add: [CPFactory watchVariable:xi 
                            onValueLost:^void(CPInt val) {
                               [_board toggleGrid:grid row:val col:i to:Removed];
                            } 
                            onValueBind:^void(CPInt val) {
                               [_board toggleGrid:grid row:val col:i to:Required];
                            } 
                         onValueRecover:^void(CPInt val) {
                            [_board toggleGrid:grid row:val col:i to:Possible];
                         }
                          onValueUnbind:^void(CPInt val) {
                             [_board toggleGrid:grid row:val col:i to:Possible];
                          }
                ]];
   }
   [_board watchSearch:cp 
              onChoose: ^void() { [_board pause];}  
                onFail: ^void() { [_board pause];}
    ];
}

-(void)runModel
{
   int n = 8;
   CPRange R = (CPRange){1,n};
   id<CP> cp = [CPFactory createSolver];
   [CPFactory intArray:cp range: R with: ^CPInt(CPInt i) { return i; }]; 
   id<CPIntVarArray> x = [CPFactory intVarArray:cp range:R domain: R];
   id<CPIntVarArray> xp = [CPFactory intVarArray:cp range: R with: ^id<CPIntVar>(CPInt i) { return [CPFactory intVar: [x at: i] shift:i]; }]; 
   id<CPIntVarArray> xn = [CPFactory intVarArray:cp range: R with: ^id<CPIntVar>(CPInt i) { return [CPFactory intVar: [x at: i] shift:-i]; }]; 
   
   [cp solveAll: 
    ^() {
       [cp add: [CPFactory alldifferent: x consistency:ValueConsistency]];
       [cp add: [CPFactory alldifferent: xp consistency:ValueConsistency]];
       [cp add: [CPFactory alldifferent: xn consistency:ValueConsistency]];

       [self visualize:x on:cp];
    }   
          using: 
    ^() {
       [CPLabel array: x orderedBy: ^CPInt(CPInt i) { return [[x at:i] domsize];}];
       [_board neverStop];
       [_board pause];
    }
    ];
   [cp release];
   [CPFactory shutdown];
}

- (IBAction)run:(id)sender 
{
   [NSThread detachNewThreadSelector:@selector(runModel) toTarget:self withObject:nil];
}

- (IBAction)resume:(id)sender 
{
   [_board resume];
}

- (IBAction)go:(id)sender 
{
   [_board neverStop];
}
@end
