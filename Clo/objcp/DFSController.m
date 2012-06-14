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

#import "CPError.h"
#import "DFSController.h"
#import "CPTrail.h"


@implementation DFSController 

- (id) initDFSController:(id<CPTracer>)tracer;
{
   self = [super initCPDefaultController];
   _tracer = [tracer retain];
   _mx  = 100;
   _tab = malloc(sizeof(NSCont*)* _mx);
   _sz  = 0;
   _atRoot = 0;
   return self;
}

- (void) dealloc
{
   NSLog(@"DFSController dealloc called...\n");
   [_tracer release];
   free(_tab);
   [super dealloc];
}
-(void)setup
{
   if (_atRoot==0)
      _atRoot = [_tracer pushNode];   
}
-(void) cleanup
{
   while (_sz > 0)
      [_tab[--_sz] letgo];
   [_tracer popToNode:_atRoot];
}

-(CPInt) addChoice: (NSCont*)k 
{
   if (_sz >= _mx) {
      NSCont** nt = malloc(sizeof(NSCont*)*_mx*2);
      for(CPInt i=0;i<_mx;i++)
         nt[i] = _tab[i];
      free(_tab);
      _tab = nt;
      _mx <<= 1;      
   }
   _tab[_sz++] = k;
   return [_tracer pushNode];
}
-(void) fail
{
   CPInt ofs = _sz-1;
   if (ofs >= 0) {
      [_tracer popNode];
      NSCont* k = _tab[ofs];
      _tab[ofs] = 0;
      --_sz;
      if (k!=NULL) 
         [k call];      
      else {
      	@throw [[CPSearchError alloc] initCPSearchError: "Empty Continuation in backtracking"];
      }
   }
}
- (id)copyWithZone:(NSZone *)zone
{
   DFSController* ctrl = [[[self class] allocWithZone:zone] initDFSController:_tracer];
   [ctrl setController:[_controller copyWithZone:zone]];
   return ctrl;
}
@end

