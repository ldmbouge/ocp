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

#import "CPFirstFail.h"
#import "CPSolverI.h"
#import "CPIntVarI.h"

@implementation CPFirstFail
-(CPFirstFail*)initCPFirstFail:(id<CP>)cp
{
   self = [super init];
   [cp addHeuristic:self];
   _cp = cp;
   _solver  = (CPSolverI*)[cp solver];
   _vars = [[NSMutableArray alloc] initWithCapacity:32];
   return self;
}
-(void)dealloc
{
   [_vars release];
   [super dealloc];
}
-(id<CPIntVarArray>)allIntVars
{
   id<CPIntVarArray> rv = [CPFactory intVarArray:_cp range:(CPRange){0,[_vars count]-1} with:^id<CPIntVar>(CPInt i) {
      return (id<CPIntVar>)[_vars objectAtIndex:i];
   }];
   return rv;
}

-(float)varOrdering:(id<CPIntVar>)x
{
   return - [x domsize];
}
-(float)valOrdering:(int)v forVar:(id<CPIntVar>)x
{
   return -v;   
}
-(void)initHeuristic:(id<CPIntVar>*)t length:(CPInt)len
{
   for(int k=0;k<len;k++) {
      [_vars addObject:t[k]];
   }
}
@end
