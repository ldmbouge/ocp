//
//  CPAppDelegate.h
//  iQueens
//
//  Created by Laurent Michel on 4/18/12.
//  Copyright (c) 2012 CSE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CPSolverController.h"

@interface CPAppDelegate : UIResponder <UIApplicationDelegate> {
   CPSolverController* _solver;
}

@property (strong, nonatomic) UIWindow *window;
-(id)bindControllerOne:(CPSecondViewController*)svc;
-(id)bindControllerTwo:(CPSecondViewController*)svc;
@end
