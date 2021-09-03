/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2014 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "LSPriority.h"

@implementation LSPriority
-(id)init:(LSPrioritySpace*)ps
{
   self = [super init];
   _next = _prev = nil;
   return self;
}
-(NSString*)description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<P=%d>",_name];
   return buf;
}
@end

@implementation LSPrioritySpace {
   NSMutableArray* _ap;
}
-(id)init
{
   self = [super init];
   _ap = [[NSMutableArray alloc] initWithCapacity:64];
   _first = _last = (id)[self freshPriority:0];
   _nifty = (id)[self freshPriority:-1];
   _first->_prev = _nifty;
   _nifty->_next = _first;
   return self;
}
-(void)dealloc
{
   [_ap release];
   [super dealloc];
}
-(id<LSPriority>) first
{
   return _first;
}
-(id<LSPriority>) last
{
   return _last;
}
-(id<LSPriority>) nifty
{
   return _nifty;
}
-(id) freshPriority:(ORUInt)lbl
{
   LSPriority* np = [[LSPriority alloc] init];
   [_ap addObject:np];
   [np release];
   [np setId:lbl];
   return np;
}
-(id<LSPriority>) freshPriorityAfter:(LSPriority*)p
{
   LSPriority* rv = nil;
   if (isLast(self,p)) {
      LSPriority* np =  (id)[self freshPriority:p.getId + 1];
      _last->_next = np;
      np->_prev = _last;
      _last = np;
      rv = np;
   }
   else {
      ORInt sc = p.getId + 1;
      LSPriority* np =  (id)[self freshPriority:sc];
      np->_next = p->_next;
      p->_next->_prev = np;
      np->_prev = p;
      p->_next = np;
      LSPriority* cur = np->_next;
      while (cur) {
         cur->_name = sc++;
         cur = cur->_next;
      }
      rv = np;
   }
   if (isNifty(self, p))
      _first = rv;
   return rv;
}

@end
