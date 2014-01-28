/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "LSIntVar.h"

@interface LSLink : NSObject {
@public
   id _src;
   id _trg;
   ORInt _k;
}
-(id)initLinkFrom:(id)src to:(id)trg for:(ORInt)k;
@end

@implementation LSLink
-(id)initLinkFrom:(id)src to:(id)trg for:(ORInt)k
{
   self = [super init];
   _src = src;
   _trg = trg;
   _k   = k;
   return self;
}
-(NSUInteger)hash
{
   return ((NSUInteger)_src ^ (NSUInteger)_trg) * _k;
}
- (BOOL)isEqual: (LSLink*)other
{
   return _src == other->_src && _trg == other->_trg && _k == other->_k;
}
@end

@implementation LSIntVar

-(id)initWithEngine:(LSEngineI*)engine andValue:(ORInt)v
{
   self = [super init];
   _engine = engine;
   _value = v;
   _status = LSFinal;
   _outbound = [[NSMutableSet alloc] initWithCapacity:2];
   [_engine trackVariable:self];
   return self;
}
-(void)dealloc
{
   [super dealloc];
}
-(NSString*)description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"var<LS>(%p,%d) = %d",self,_name,_value];
   return buf;
}
-(LSEngineI*)engine
{
   return _engine;
}
-(void)setValue:(ORInt)v
{
   _value = v;
}
-(ORInt)value
{
   return _value;
}
-(ORInt)incr
{
   return ++_value;
}
-(ORInt)decr
{
   return --_value;
}
-(id)addListener:(LSPropagator*)p term:(ORInt)k
{
   LSLink* obj = [[LSLink alloc] initLinkFrom:self to:p for:k];
   [_outbound addObject:obj];
   return obj;
}
@end
