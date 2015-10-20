/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <Cocoa/Cocoa.h>
#import "SportView.h"
#import <objcp/NSBoardController.h>

@interface AppDelegate : NSObject <NSApplicationDelegate> {
      NSBoardController* _topBoard;
}
@property (assign) IBOutlet SportView *sportView;
@property (assign) IBOutlet NSWindow *window;
- (IBAction)run:(id)sender;
- (IBAction)stop:(id)sender;
- (IBAction)pause:(id)sender;
@property (assign) IBOutlet NSMatrix *mtxView;

@end
