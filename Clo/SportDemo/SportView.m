/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

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

