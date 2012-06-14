//
//  queensACAppDelegate.h
//  queensAC
//
//  Created by Pascal Van Hentenryck on 6/29/11.
//  Copyright 2011 Brown University. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface queensACAppDelegate : NSObject <NSApplicationDelegate> {
@private
    NSWindow *window;
}

@property (assign) IBOutlet NSWindow *window;

@end
