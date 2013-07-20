//
//  SportView.m
//  Clo
//
//  Created by Pascal Van Hentenryck on 7/7/12.
//  Copyright (c) 2012 CSE. All rights reserved.
//

#import "SportView.h"

@implementation SportView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}
-(void)dealloc
{
   [super dealloc];
}
-(void)setDelegate:(id)delegate
{
   _delegate = delegate;
}
-(void)refresh
{
   [self setNeedsDisplay:YES];
}
- (void)drawRect:(NSRect)theRect
{
   //NSLog(@"drawRect: ");
   [[NSColor grayColor] setFill];
   NSRectFill(theRect);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-method-access"
   [_delegate drawRect:theRect inView:self];
#pragma clang pop
}

@end

