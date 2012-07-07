//
//  SportView.h
//  Clo
//
//  Created by Pascal Van Hentenryck on 7/7/12.
//  Copyright (c) 2012 CSE. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SportView : NSView {
   id _delegate;
}
-(id)initWithFrame:(NSRect)frameRect;
-(void)dealloc;
-(void)drawRect:(NSRect)dirtyRect;
-(void)setDelegate:(id)delegate;

@end
