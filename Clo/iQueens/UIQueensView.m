//
//  UIQueensView.m
//  Clo
//
//  Created by Laurent Michel on 4/18/12.
//  Copyright (c) 2012 CSE. All rights reserved.
//

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
