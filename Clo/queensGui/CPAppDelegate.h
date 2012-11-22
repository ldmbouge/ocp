/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/


#import <Cocoa/Cocoa.h>
#import <objcp/NSBoardController.h>
#import "QueensView.h"

@interface CPAppDelegate : NSObject <NSApplicationDelegate> {
   NSBoardController* _board;
}
@property (assign) IBOutlet QueensView *theView;
@property (assign) IBOutlet NSWindow *window;
- (IBAction)run:(id)sender;
- (IBAction)resume:(id)sender;
- (IBAction)go:(id)sender;

@end
