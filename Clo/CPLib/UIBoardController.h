//
//  UIBoardController.h
//  Clo
//
//  Created by Laurent Michel on 4/18/12.
//  Copyright (c) 2012 CSE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "objcp/CPFactory.h"
#import "objcp/CPWatch.h"

@interface UIBoardController : NSObject {
   UIView* _drawOn;
   NSMutableArray* _toDraw;
   NSCondition*    _pause;
   BOOL            _isPaused;
   BOOL            _canPause;   
}
-(UIBoardController*)initBoardController:(UIView*)theView;
-(void)dealloc;
-(id)makeGrid:(CPRange) rows by:(CPRange)cols;
-(void)pause;
-(void)resume;
-(void)neverStop;
-(void)toggleGrid:(id)grid row:(NSInteger)r col:(NSInteger)c to:(enum CPDomValue)dv;
-(void)drawRect:(CGRect)dirtyRect inView:(id)view;
-(void)watchSearch:(id<CP>)cp onChoose:(CPClosure)onc onFail:(CPClosure)onf;
@end
