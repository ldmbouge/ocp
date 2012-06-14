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


#import <Foundation/Foundation.h>
#import "cont.h"
#import "CPExplorerI.h"
#import "CPController.h"
#import "CPTypes.h"
#import "CPTrail.h"
#import "CPTracer.h"
#import "CPSolver.h"
#import "CPController.h"


@interface BDSStack : NSObject {
   struct BDSNode {
      NSCont*     _cont;
      Checkpoint*   _cp;
      CPInt         _disc;
   }; 
@private   
   struct BDSNode* _tab;
   CPInt        _mx;
   CPInt        _sz;
}
-(id)initBDSStack:(CPInt)mx;
-(void)pushCont:(NSCont*)k cp:(Checkpoint*)cp discrepancies:(CPInt)d;
-(struct BDSNode)pop;
-(CPInt)size;
-(bool)empty;
@end

@interface SemBDSController : CPDefaultController<NSCopying,CPSearchController> {
@private
   BDSStack*        _tab;
   BDSStack*       _next;
   CPInt          _maxDisc;
   CPInt           _nbDisc;
   SemTracer*    _tracer;
   Checkpoint*   _atRoot;
   id<CPSolver> _solver;   
}
-(id)   initSemBDSController:(id<CPTracer>)tracer andSolver:(id<CPSolver>)solver;
-(void) dealloc;
-(void)       setup;
-(void)       cleanup;
-(CPInt) addChoice:(NSCont*)k;
-(void) fail;
@end
