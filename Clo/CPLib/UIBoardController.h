/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

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
-(void)watchSearch:(id<CPSolver>)cp onChoose:(ORClosure)onc onFail:(ORClosure)onf;
@end
