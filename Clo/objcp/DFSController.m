/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

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

