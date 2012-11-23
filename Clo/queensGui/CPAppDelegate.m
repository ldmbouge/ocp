/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/


#import "CPAppDelegate.h"
#import <ORFoundation/ORFoundation.h>
#import <CPUKernel/CPUKernel.h>
#import <objcp/NSBoardController.h>

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

-(void)visualize:(id<ORIntVarArray>)x on:(id<CPSolver>)cp
{
   ORBounds dom =  [[x at: [x low]] bounds];
   id<ORIntRange> cols = RANGE(cp,[x low],[x up]);
   id<ORIntRange> rows = RANGE(cp,dom.min,dom.max);
   id grid = [_board makeGrid:rows by: cols];
   for(ORInt i = [x low];i <= [x up];i++) {
      id<ORIntVar> xi = x[i];
      [cp add: [CPFactory watchVariable:xi 
                            onValueLost:^void(ORInt val) {
                               [_board toggleGrid:grid row:val col:i to:Removed];
                            } 
                            onValueBind:^void(ORInt val) {
                               [_board toggleGrid:grid row:val col:i to:Required];
                            } 
                         onValueRecover:^void(ORInt val) {
                            [_board toggleGrid:grid row:val col:i to:Possible];
                         }
                          onValueUnbind:^void(ORInt val) {
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
   id<CPSolver> cp = [CPFactory createSolver];
   id<ORIntRange> R = RANGE(cp,1,n);
   [CPFactory intArray:cp range: R with: ^ORInt(ORInt i) { return i; }];
   id<ORIntVarArray> x = [CPFactory intVarArray:cp range:R domain: R];
   id<ORIntVarArray> xp = [CPFactory intVarArray:cp range: R with: ^id<ORIntVar>(ORInt i) { return [CPFactory intVar: [x at: i] shift:i]; }]; 
   id<ORIntVarArray> xn = [CPFactory intVarArray:cp range: R with: ^id<ORIntVar>(ORInt i) { return [CPFactory intVar: [x at: i] shift:-i]; }]; 

   [cp add: [CPFactory alldifferent: x consistency:ValueConsistency]];
   [cp add: [CPFactory alldifferent: xp consistency:ValueConsistency]];
   [cp add: [CPFactory alldifferent: xn consistency:ValueConsistency]];
   
   [cp solveAll:
    ^() {
       [self visualize:x on:cp];
       
       [CPLabel array: x orderedBy: ^ORInt(ORInt i) { return [[x at:i] domsize];}];
       //[_board neverStop];
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
- (IBAction)smart:(id)sender {
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
