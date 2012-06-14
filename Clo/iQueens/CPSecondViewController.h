//
//  CPSecondViewController.h
//  iQueens
//
//  Created by Laurent Michel on 4/18/12.
//  Copyright (c) 2012 CSE. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CPSecondViewController : UIViewController {
   id _solver;
}
@property (retain, nonatomic) IBOutlet UITextView *log;
-(void)insertText:(NSString*)txt;
@end
