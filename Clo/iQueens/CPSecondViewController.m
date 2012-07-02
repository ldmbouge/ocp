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

#import "CPSecondViewController.h"
#import "CPSolverController.h"

@interface CPSecondViewController ()

@end

@implementation CPSecondViewController
@synthesize log;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
   _solver = [[[UIApplication sharedApplication] delegate] bindControllerTwo:self];
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

-(void)insertText:(NSString*)txt
{
   [log insertText:txt];
}

- (IBAction)run:(id)sender 
{
   [NSThread detachNewThreadSelector:@selector(runModel) toTarget:_solver withObject:nil];
}
- (IBAction)clear:(id)sender 
{
   [log setText:@""];
}

- (void)dealloc {
   [log release];
   [super dealloc];
}
@end
