/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/


#import "CPAppDelegate.h"
#import <ORFoundation/ORFoundation.h>
#import <ORFoundation/ORSemBDSController.h>
#import <ORFoundation/ORSemDFSController.h>
#import <ORModeling/ORModeling.h>
#import <ORProgram/ORProgram.h>
#import <objcp/CPConstraint.h>

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

-(void)visualize:(id<ORIntVarArray>)x on:(id<CPProgram>)cp
{
   ORBounds dom =  { [cp min:x[x.low]], [cp max:x[x.low]] };
   id<ORIntRange> cols = RANGE(cp,[x low],[x up]);
   id<ORIntRange> rows = RANGE(cp,dom.min,dom.max);
   id grid = [_board makeGrid:rows by: cols];
   for(ORInt i = [x low];i <= [x up];i++) {
      id<ORIntVar> xi = x[i];
      [cp addConstraintDuringSearch:[CPFactory solver:cp
                                        watchVariable:xi
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
                ]  annotation:Default];
   }
   [_board watchSearch:[cp explorer]
              onChoose: ^ { [_board pause];}
                onFail: ^ { [_board pause];}
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
   
   [cp solveAll:
    ^() {
       [self visualize:x on:cp];       
       [cp labelArray:x orderedBy: ^ORFloat(ORInt i) { return [cp domsize:x[i]];}];
       //[_board neverStop];
       [_board pause];
    }
    ];
   [cp release];
   [ORFactory shutdown];
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
