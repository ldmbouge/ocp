/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

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
