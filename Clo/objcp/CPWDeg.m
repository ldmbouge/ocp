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

#import "CPWDeg.h"
#import "CPSolverI.h"
#import "CPIntVarI.h"

@implementation CPWDeg

-(CPWDeg*)initCPWDeg:(id<CP>)cp
{
   self = [super init];
   [cp addHeuristic:self];
   _cp = cp;
   _solver  = (CPSolverI*)[cp solver];
   _vars = [[NSMutableArray alloc] initWithCapacity:32];
   _w = 0;
   _cv = 0;
   return self;
}

-(void)dealloc
{
   if (_w) free(_w);
   if (_vOfC) {
      for(int k=0;k<_nbc;k++)
         [_vOfC[k] release];
      free(_vOfC);  
   }
   if (_cv) {
     for(int k=0;k<[_vars count];k++)
       [_cv[k] release];
     free(_cv);
   }
   [_vars release];
   free(_map);
   [super dealloc];
}

// pvh: not sure why this is needed
// pvh: why do we need vars and t and so on.
-(id<CPIntVarArray>)allIntVars
{
   id<CPIntVarArray> rv = [CPFactory intVarArray:_cp range:(CPRange){0,_nbv-1} with:^id<CPIntVar>(CPInt i) {
      return (id<CPIntVar>)[_vars objectAtIndex:i];
   }];
   return rv;
}

// pvh: see question below for the importance of _cv

-(float) varOrdering:(id<CPIntVar>)x
{
   __block float h = 0.0;
   NSSet* theConstraints = _cv[_map[[x getId]]];   
   for(id obj in theConstraints) {
      h += ([obj nbUVars] - 1 > 0) * _w[[obj getId]];
   }
   return h / [x domsize];
}

-(float) valOrdering:(int) v forVar:(id<CPIntVar>)x
{
   return -v;   
}

// pvh: we should really use our arrays for consistency in the interfaces
// pvh: why do we need _cv[k]: it seems that we should be able to get these directly from the variable

-(void)initHeuristic:(id<CPIntVar>*)t length:(CPInt)len
{
   _cv = malloc(sizeof(NSSet*)*len);
   CPUInt maxID = 0;
   for(int k=0;k<len;k++) 
      maxID = max(maxID,[t[k] getId]);   
   _map = malloc(sizeof(CPUInt)*(maxID+1));
   memset(_cv,sizeof(NSSet*)*len,0);
   for(int k=0;k<len;k++) {
      //NSLog(@"Adding var with id: %d to dico of size: %ld",[t[k] getId],[_vars count]);
      _map[[t[k] getId]] = k;
      [_vars addObject:t[k]];
      _cv[k] = [t[k] constraints];
   }
   _nbv = len;
   NSArray* allC = [_solver allConstraints];
   _nbc = [allC count];
   _w   = malloc(sizeof(CPUInt)*_nbc);
   _vOfC = malloc(sizeof(id)*_nbc);
   for(CPUInt k=0;k < _nbc;k++) {
      _w[k] = 1;
      _vOfC[k] = [[allC objectAtIndex:k] allVars];
   }
   [[_solver propagateFail] wheneverNotifiedDo:^(int cID) {
      _w[cID]++;
   }];
}

@end
