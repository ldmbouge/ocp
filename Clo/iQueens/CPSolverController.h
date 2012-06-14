//
//  CPSolverController.h
//  Clo
//
//  Created by Laurent Michel on 4/18/12.
//  Copyright (c) 2012 CSE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CPFirstViewController.h"
#import "CPSecondViewController.h"

@interface CPSolverController : NSObject {
   CPFirstViewController* _view1;
   CPSecondViewController* _view2;
}
-(id)bindControllerOne:(CPSecondViewController*)svc;
-(id)bindControllerTwo:(CPSecondViewController*)svc;
@end
