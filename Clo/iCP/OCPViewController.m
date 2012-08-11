/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/


#import "OCPViewController.h"
#import "objcp/CPConstraint.h"
#import "objcp/DFSController.h"
#import "objcp/CPEngine.h"
#import "objcp/cp.h"
#import "objcp/CPFactory.h"
#import "objcp/CPLabel.h"

@interface OCPViewController ()

@end

@implementation OCPViewController
@synthesize log;

- (void)viewDidLoad
{
   [super viewDidLoad];
   [log setText:@"Ready...\n"];
}

- (void)viewDidUnload
{
    [self setLog:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
   if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
       return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
   } else {
       return YES;
   }
}

- (void)dealloc {
    [log release];
    [super dealloc];
}
- (IBAction)redo:(id)sender 
{
   int n = 8;
   CPRange R = (CPRange){1,n};
   id<CPSolver> cp = [CPFactory createSolver];
   id<CPInteger> nbSolutions = [CPFactory integer:cp value:0];
   [CPFactory intArray:cp range: R with: ^int(int i) { return i; }]; 
   id<ORIntVarArray> x = [CPFactory intVarArray:cp range:R domain: R];
   id<ORIntVarArray> xp = [CPFactory intVarArray:cp range: R with: ^id<ORIntVar>(int i) { return [CPFactory intVar: [x at: i] shift:i]; }]; 
   id<ORIntVarArray> xn = [CPFactory intVarArray:cp range: R with: ^id<ORIntVar>(int i) { return [CPFactory intVar: [x at: i] shift:-i]; }]; 
   [cp solveAll: 
    ^() {
       [cp add: [CPFactory alldifferent: x consistency:ValueConsistency]];
       [cp add: [CPFactory alldifferent: xp consistency:ValueConsistency]];
       [cp add: [CPFactory alldifferent: xn consistency:ValueConsistency]];
    }   
          using: 
    ^() {
       [CPLabel array: x orderedBy: ^int(int i) { return [[x at:i] domsize];}];
       [log  insertText:[NSString stringWithFormat:@"sol [%d]: %@\n",[nbSolutions value],[x description]]];
       [nbSolutions incr];
    }
    ];
   [log insertText: [NSString stringWithFormat:@"GOT %ld solutions\n",[nbSolutions value]]];
   
   [log insertText: [NSString stringWithFormat:@"Solver status: %@\n",cp]];
   [cp release];
   [CPFactory shutdown];
}

- (IBAction)clear:(id)sender {
   [log setText:@"Ready..."];
}
@end
