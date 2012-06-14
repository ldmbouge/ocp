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

#import "objcp/CPFactory.h"
#import "objcp/CPController.h"

@class CPIntVarI;

enum CPDomValue {
   Required = 0,
   Possible = 1,
   Removed  = 2
};

@interface CPWatch : CPActiveConstraint {
   CPIntVarI* _theVar;
   CPInt2Void _lost;
   CPInt2Void _bind;
   CPInt2Void _rec;
   CPInt2Void _unb;   
}
-(CPWatch*)initCPWatch:(id<CPIntVar>)x onValueLost:(CPInt2Void)lost onValueBind:(CPInt2Void)bind onValueRecover:(CPInt2Void)rec onValueUnbind:(CPInt2Void)unb;
-(CPStatus) post;
-(NSSet*)allVars;
-(CPUInt)nbUVars;
@end

@interface CPViewController : CPDefaultController {
   CPClosure _onChoose;
   CPClosure _onFail;
}
-(CPViewController*)initCPViewController:(id<CPSearchController>)chain onChoose:(CPClosure)onc onFail:(CPClosure)onf;
-(CPInt)  addChoice: (NSCont*) k;
-(void)       fail;
@end

@interface CPFactory (Visualize)
+(id<CPConstraint>)watchVariable:(id<CPIntVar>)x 
                     onValueLost:(CPInt2Void)lost 
                     onValueBind:(CPInt2Void)bind 
                  onValueRecover:(CPInt2Void)rec 
                   onValueUnbind:(CPInt2Void)unb;
@end

