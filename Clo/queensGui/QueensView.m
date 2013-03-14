/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/


#import "QueensView.h"

@implementation QueensView
-(id)initWithFrame:(NSRect)frameRect
{
   self = [super initWithFrame:frameRect];
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


- (void)drawRect:(NSRect)dirtyRect
{
   //NSLog(@"drawRect: ");
   [[NSColor whiteColor] setFill];
   NSRectFill(dirtyRect);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-method-access"
   [_delegate drawRect:dirtyRect inView:self];
#pragma clang diagnostic pop
}

-(void)refresh
{
   [self setNeedsDisplay:YES];
}

@end
