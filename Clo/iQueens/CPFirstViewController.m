//
//  CPFirstViewController.m
//  iQueens
//
//  Created by Laurent Michel on 4/18/12.
//  Copyright (c) 2012 CSE. All rights reserved.
//

#import "CPFirstViewController.h"

@interface CPFirstViewController ()

@end

@implementation CPFirstViewController
@synthesize board;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
   _solver = [[[UIApplication sharedApplication] delegate] bindControllerOne:self];
   _boardController = [[UIBoardController alloc] initBoardController:board];
}

- (void)viewDidUnload
{
   [self setBoard:nil];
   [_solver release];
   _solver = nil;
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
    [board release];
    [super dealloc];
}

-(UIBoardController*)boardController
{
   return _boardController;
}

- (IBAction)run:(id)sender 
{
   [NSThread detachNewThreadSelector:@selector(runModel) toTarget:_solver withObject:nil];
}

- (IBAction)clear:(id)sender 
{
}

- (IBAction)resume:(id)sender 
{
   [_boardController resume];
}

- (IBAction)go:(id)sender 
{
   [_boardController neverStop];
}
@end
