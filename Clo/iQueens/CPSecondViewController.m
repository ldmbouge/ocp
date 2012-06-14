//
//  CPSecondViewController.m
//  iQueens
//
//  Created by Laurent Michel on 4/18/12.
//  Copyright (c) 2012 CSE. All rights reserved.
//

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
