//
//  UIQueensView.h
//  Clo
//
//  Created by Laurent Michel on 4/18/12.
//  Copyright (c) 2012 CSE. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIQueensView : UIView {
   id _delegate;
}
-(id)initWithFrame:(CGRect)frameRect;
-(void)dealloc;
-(void)drawRect:(CGRect)dirtyRect;
-(void)setDelegate:(id)delegate;
@end
