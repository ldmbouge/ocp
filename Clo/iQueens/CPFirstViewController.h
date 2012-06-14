//
//  CPFirstViewController.h
//  iQueens
//
//  Created by Laurent Michel on 4/18/12.
//  Copyright (c) 2012 CSE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIBoardController.h"

@interface CPFirstViewController : UIViewController {
   id _solver;
   UIBoardController* _boardController;
}
@property (retain, nonatomic) IBOutlet UIView *board;
- (IBAction)run:(id)sender;
- (IBAction)clear:(id)sender;
- (IBAction)resume:(id)sender;
- (IBAction)go:(id)sender;
-(UIBoardController*)boardController;
@end
