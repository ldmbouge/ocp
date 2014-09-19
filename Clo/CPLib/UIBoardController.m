/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import "UIBoardController.h"
#import <objcp/CPConstraintI.h>
#import <objcp/CPIntVarI.h>
#import <objcp/CPWatch.h>


@interface CPGrid : NSObject {
   ORRange _rows;
   ORRange _cols;
   UIColor* _red;
   UIColor* _green;
   UIColor* _back;
   enum CPDomValue* _values;
}
-(CPGrid*)initGrid:(id<ORIntRange>)rows by:(id<ORIntRange>)cols;
-(void)toggleRow:(NSInteger)r col:(NSInteger)c to:(enum CPDomValue)dv;
-(void)drawRect:(CGRect)dirtyRect inView:(UIView*)view;
@end


@implementation CPGrid
-(CPGrid*)initGrid:(id<ORIntRange>)rows by:(id<ORIntRange>)cols
{
   self = [super init];
   _rows = (ORRange){[rows low],[rows up]};
   _cols = (ORRange){[cols low],[cols up]};;
   NSInteger nbRows = _rows.up - _rows.low + 1;
   NSInteger nbCols = _cols.up - _cols.low + 1;
   _values = malloc(sizeof(enum CPDomValue)*nbRows*nbCols);
   for(NSInteger i=0;i<nbRows*nbCols;i++)
      _values[i] = Possible;
   _red  = [UIColor redColor];
   _green= [UIColor greenColor];
   _back = [UIColor grayColor];
   return self;
}
-(void)dealloc
{
   free(_values);
   [super dealloc];
}
-(void)toggleRow:(NSInteger)r col:(NSInteger)c to:(enum CPDomValue)dv
{
   NSInteger nbCols = _cols.up - _cols.low + 1;
   _values[(r - _rows.low) * nbCols + c - _cols.low] = dv;
}
-(void)drawRect:(CGRect)dirtyRect inView:(UIView*)view
{
   CGRect bnds  = [view frame];
   NSInteger nbRows = _rows.up - _rows.low + 1;
   NSInteger nbCols = _cols.up - _cols.low + 1;
   float stripW = bnds.size.width / nbCols;
   float stripH = bnds.size.height/ nbRows;
   float colW = stripW - 6;
   float rowH = stripH - 6;
   for(NSInteger i=_rows.low;i<=_rows.up;i++) {
      for(NSInteger j=_cols.low; j <= _cols.up;j++) {      
         enum CPDomValue dv = _values[(i - _rows.low) * nbCols + j - _cols.low];
         switch(dv) {
            case Possible: [_back setFill];break;
            case Required: [_green setFill];break;
            case Removed:  [_red setFill];break;
         }
         CGFloat x = (j-_cols.low)*stripW;
         CGFloat y = (i-_rows.low)*stripH;
         CGRect nb = {x + 3 + bnds.origin.x,y + 3 + bnds.origin.y,colW, rowH};
         UIRectFill(nb);
      }
   }
   
}
@end

@implementation UIBoardController
-(UIBoardController*)initBoardController:(id)theView
{
   self = [super init];
   _drawOn = [theView retain];
   [theView setDelegate:self];
   _toDraw = [[NSMutableArray alloc] initWithCapacity:32];
   _pause = [[NSCondition alloc] init];
   _isPaused = NO;
   _canPause = YES;
   return self;
}
-(void)dealloc
{
   [_drawOn release];
   [_toDraw release];
   [_pause release];
   [super dealloc];
}
-(void)drawRect:(CGRect)dirtyRect inView:(UIView*)view
{
   [_toDraw enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
      [obj drawRect:dirtyRect inView:view];
   }];
}

-(id)makeGrid:(id<ORIntRange>) rows by:(id<ORIntRange>)cols
{
   CPGrid* g = nil;
   @synchronized(self) {
      g = [[CPGrid alloc] initGrid:rows by: cols];
      [_toDraw addObject:g];
      [g release];
   }
   return g;
}
-(void)toggleGrid:(CPGrid*)grid row:(NSInteger)r col:(NSInteger)c 
               to:(enum CPDomValue)dv
{
   @synchronized(self) {
      [grid toggleRow:r col:c to:dv];
   }
   [_drawOn performSelectorOnMainThread:@selector(setNeedsDisplay) withObject:0 waitUntilDone:NO];
}
-(void)watchSearch:(id<ORExplorer>)explorer onChoose:(ORClosure)onc onFail:(ORClosure)onf
{
   [explorer setController: [[CPViewController alloc] initCPViewController:[explorer controller]
                                                                  onChoose:onc
                                                                    onFail:onf]];
}

-(void)pause
{
   [_pause lock];
   _isPaused = _canPause;
   while (_isPaused)
      [_pause wait];
   [_pause unlock];
}
-(void)resume
{
   [_pause lock];
   _isPaused = NO;
   [_pause signal];
   [_pause unlock];
}
-(void)neverStop
{
   [_pause lock];
   _canPause = !_canPause;
   _isPaused = NO;
   [_pause signal];
   [_pause unlock];
}
@end
