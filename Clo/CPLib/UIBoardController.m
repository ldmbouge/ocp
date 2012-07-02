/************************************************************************
 MIT License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 Permission is hereby granted, free of charge, to any person obtaining
 a copy of this software and associated documentation files (the
 "Software"), to deal in the Software without restriction, including
 without limitation the rights to use, copy, modify, merge, publish,
 distribute, sublicense, and/or sell copies of the Software, and to
 permit persons to whom the Software is furnished to do so, subject to
 the following conditions:
 
 The above copyright notice and this permission notice shall be
 included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 ***********************************************************************/

#import "UIBoardController.h"
#import "CPConstraintI.h"
#import "CPIntVarI.h"
#import "CPSolverI.h"
#import "CPI.h"
#import "CPWatch.h"


@interface CPGrid : NSObject {
   CPRange _rows;
   CPRange _cols;
   UIColor* _red;
   UIColor* _green;
   UIColor* _back;
   enum CPDomValue* _values;
}
-(CPGrid*)initGrid:(CPRange)rows by:(CPRange)cols;
-(void)toggleRow:(NSInteger)r col:(NSInteger)c to:(enum CPDomValue)dv;
-(void)drawRect:(CGRect)dirtyRect inView:(UIView*)view;
@end


@implementation CPGrid
-(CPGrid*)initGrid:(CPRange)rows by:(CPRange)cols
{
   self = [super init];
   _rows = rows;
   _cols = cols;
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

-(id)makeGrid:(CPRange) rows by:(CPRange)cols
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
-(void)watchSearch:(CoreCPI*)cp onChoose:(CPClosure)onc onFail:(CPClosure)onf
{
   [cp setController: [[CPViewController alloc] initCPViewController:[cp controller] onChoose:onc onFail:onf]];
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
