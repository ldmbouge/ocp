/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import "UIQueensView.h"

@implementation UIQueensView
-(id)initWithFrame:(CGRect)frameRect
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

- (void)drawRect:(CGRect)dirtyRect
{
   [[UIColor whiteColor] setFill];
   UIRectFill(dirtyRect);
   [_delegate drawRect:dirtyRect inView:self];
}

@end
