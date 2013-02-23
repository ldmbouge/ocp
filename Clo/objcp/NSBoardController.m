/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import "NSBoardController.h"
#import <ORProgram/CPProgram.h>
#import "CPWatch.h"

@interface CPGrid : NSObject {
   ORRange _rows;
   ORRange _cols;
   NSColor* _red;
   NSColor* _green;
   NSColor* _back;
   enum CPDomValue* _values;
}
-(CPGrid*)initGrid:(id<ORIntRange>)rows by:(id<ORIntRange>)cols;
-(void)toggleRow:(ORInt)r col:(ORInt)c to:(enum CPDomValue)dv;
-(void)drawRect:(NSRect)dirtyRect inView:(NSView*)view;
@end


@implementation CPGrid
-(CPGrid*)initGrid:(id<ORIntRange>)rows by:(id<ORIntRange>)cols
{
   self = [super init];
   _rows = (ORRange){[rows low],[rows up]};
   _cols = (ORRange){[cols low],[cols up]};;
   ORInt nbRows = _rows.up - _rows.low + 1;
   ORInt nbCols = _cols.up - _cols.low + 1;
   _values = malloc(sizeof(enum CPDomValue)*nbRows*nbCols);
   for(ORInt i=0;i<nbRows*nbCols;i++)
      _values[i] = Possible;
   _red = [NSColor redColor];
   _green  = [NSColor greenColor];
   _back = [NSColor grayColor];
   return self;
}
-(void)dealloc
{
   free(_values);
   [super dealloc];
}
-(void)toggleRow:(ORInt)r col:(ORInt)c to:(enum CPDomValue)dv
{
   ORInt nbCols = _cols.up - _cols.low + 1;
   _values[(r - _rows.low) * nbCols + c - _cols.low] = dv;
}
-(void)drawRect:(NSRect)dirtyRect inView:(NSView*)view
{
   NSRect bnds  = [view frame];
   ORInt nbRows = _rows.up - _rows.low + 1;
   ORInt nbCols = _cols.up - _cols.low + 1;
   float stripW = bnds.size.width / nbCols;
   float stripH = bnds.size.height/ nbRows;
   float colW = stripW - 6;
   float rowH = stripH - 6;
   for(ORInt i=_rows.low;i<=_rows.up;i++) {
      for(ORInt j=_cols.low; j <= _cols.up;j++) {
         enum CPDomValue dv = _values[(i - _rows.low) * nbCols + j - _cols.low];
         switch(dv) {
            case Possible: [_back setFill];break;
            case Required: [_green setFill];break;
            case Removed:  [_red setFill];break;
         }
         CGFloat x = (j-_cols.low)*stripW;
         CGFloat y = (i-_rows.low)*stripH;
         NSRectFill(NSMakeRect(x + 3 + bnds.origin.x, 
                               y + 3 + bnds.origin.y, 
                               colW, rowH));
      }
   }
         
}

@end

@implementation NSBoardController
-(NSBoardController*)initBoardController:(id)theView
{
   self = [super init];
   _drawOn = [theView retain];
   _toDraw = [[NSMutableArray alloc] initWithCapacity:32];
   [theView setDelegate:self];
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
-(void)drawRect:(NSRect)dirtyRect inView:(NSView*)view
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
-(void)toggleGrid:(CPGrid*)grid row:(ORInt)r col:(ORInt)c 
               to:(enum CPDomValue)dv
{
   @synchronized(self) {
      [grid toggleRow:r col:c to:dv];
   }
   [_drawOn performSelectorOnMainThread:@selector(refresh) withObject:nil waitUntilDone:NO];
}
-(void)watchSearch: (id<CPProgram>)cp onChoose:(ORClosure) onc onFail:(ORClosure) onf
{
  [[cp explorer] setController: [[CPViewController alloc] initCPViewController:[[cp explorer] controller]
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
