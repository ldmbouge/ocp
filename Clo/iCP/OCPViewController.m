/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/


#import "OCPViewController.h"
#import <ORProgram/ORProgram.h>

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

- (ORBool)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
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
   id<ORModel> m = [ORFactory createModel];
   id<ORIntRange> R = RANGE(m,1,n);
   id<ORMutableInteger> nbSolutions = [ORFactory mutable:m value:0];
   id<ORIntVarArray> x = [ORFactory intVarArray:m range:R domain: R];
   id<ORIntVarArray> xp = [ORFactory intVarArray:m range: R with: ^id<ORIntVar>(int i) {
      return [ORFactory intVar:m var:x[i] shift:i];
   }];
   id<ORIntVarArray> xn = [ORFactory intVarArray:m range: R with: ^id<ORIntVar>(int i) {
      return [ORFactory intVar:m var:x[i] shift:-i];
   }];
   [m add: [ORFactory alldifferent: x]];
   [m add: [ORFactory alldifferent: xp]];
   [m add: [ORFactory alldifferent: xn]];
   
   id<CPProgram> cp = [ORFactory createCPProgram:m];
   
   [cp solveAll:^{
      [cp labelArrayFF:x];
      id<ORIntArray> s = [ORFactory intArray:cp range:R with:^ORInt(ORInt k) {
         return [cp intValue:x[k]];
      }];
      [log  insertText:[NSString stringWithFormat:@"sol [%d]: %@\n",[nbSolutions intValue:cp],s]];
      [nbSolutions incr:cp];
   }];
   [log insertText: [NSString stringWithFormat:@"GOT %d solutions\n",[nbSolutions intValue:cp]]];
   [log insertText: [NSString stringWithFormat:@"Solver status: %@\n",cp]];
   [ORFactory shutdown];
}

- (IBAction)clear:(id)sender {
   [log setText:@"Ready..."];
}
@end
