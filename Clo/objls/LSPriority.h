/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>

@protocol LSPriority
@end

@class LSPrioritySpace;

@interface LSPriority : ORObject<LSPriority> {
@public
   LSPriority* _next;
   LSPriority* _prev;
}
-(id)init:(LSPrioritySpace*)ps;

@end

@interface LSPrioritySpace : NSObject {
@package
   LSPriority* _first;
   LSPriority* _last;
   LSPriority* _nifty;
}
-(id)init;
-(void)dealloc;
-(id<LSPriority>) first;
-(id<LSPriority>) last;
-(id<LSPriority>) nifty;
-(id<LSPriority>) freshPriority:(ORUInt)lbl;
-(id<LSPriority>) freshPriorityAfter:(id<LSPriority>)p;
@end

static inline BOOL isFirst(LSPrioritySpace* ps,LSPriority* p) { return p == ps->_first;}
static inline BOOL isLast(LSPrioritySpace* ps,LSPriority* p)  { return p == ps->_last;}
static inline BOOL isNifty(LSPrioritySpace* ps,LSPriority* p) { return p == ps->_nifty;}
static inline LSPriority* nextPriority(LSPriority* p)         { return p->_next;}
static inline LSPriority* prevPriority(LSPriority* p)         { return p->_prev;}