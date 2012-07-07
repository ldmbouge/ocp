//
//  AppDelegate.h
//  SportDemo
//
//  Created by Pascal Van Hentenryck on 7/7/12.
//  Copyright (c) 2012 CSE. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SportView.h"
#import "objcp/NSBoardController.h"

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
