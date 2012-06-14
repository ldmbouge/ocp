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

#import "CPCommand.h"

@implementation CPCommandList
-(CPCommandList*)initCPCommandList
{
   self = [super init];
   _head = NULL;
   _ndId = -1; // undefined
   return self;
}
-(CPCommandList*)initCPCommandList:(CPInt)node
{
   self = [super init];
   _head = NULL;
   _ndId = node;
   return self;
}
-(void)dealloc
{
   //NSLog(@"dealloc on CPCommandList %ld\n",_ndId);
   while (_head) {
      struct CNode* nxt = _head->_next;
      [_head->_c release];
      free(_head);
      _head = nxt;
   }
   [super dealloc];
}
-(void)insert:(id<CPCommand>)c
{
   struct CNode* new = malloc(sizeof(struct CNode*));
   new->_c = c;
   new->_next = _head;
   _head = new;
}
-(id<CPCommand>)removeFirst
{
   struct CNode* leave = _head;
   _head = _head->_next;
   id<CPCommand> rv = leave->_c;
   free(leave);
   return rv;
}
-(NSString*)description
{
   NSMutableString* str = [NSMutableString stringWithCapacity:512];
   [str appendFormat:@" [%d]:{",_ndId];
   struct CNode* cur = _head;
   while (cur) {
      [str appendString:[cur->_c description]];
      cur = cur->_next;
      if (cur != NULL)
         [str appendString:@","];
   }
   [str appendString:@"}"];   
   return str;
}
-(bool)equalTo:(CPCommandList*)cList
{
   return _ndId == cList->_ndId;
}
-(CPInt)getNodeId
{
   return _ndId;
}
-(bool)apply:(bool(^)(id<CPCommand>))clo
{
   struct CNode* cur = _head;
   while (cur) {
      bool ok = clo(cur->_c);
      if (!ok) 
         return false;
      cur = cur->_next;
   }
   return true;
}
-(bool)empty
{
   return _head==0;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
   CPUInt cnt = 0;
   struct CNode* cur = _head;
   while (cur) {
      cur = cur->_next;
      ++cnt;
   }
   [aCoder encodeValueOfObjCType:@encode(CPUInt) at:&_ndId];
   [aCoder encodeValueOfObjCType:@encode(CPUInt) at:&cnt];   
   cur = _head;
   while (cur) {
      [aCoder encodeObject:cur->_c];   
      cur = cur->_next;
   }
}
-(id)initWithCoder:(NSCoder *)aDecoder
{
   self = [super init];
   CPUInt cnt = 0;
   _head = 0;
   [aDecoder decodeValueOfObjCType:@encode(CPUInt) at:&_ndId];
   [aDecoder decodeValueOfObjCType:@encode(CPUInt) at:&cnt];
   CPUInt i = 0;
   struct CNode* tail = 0;
   while (i < cnt) {
      id<CPCommand> com = [[aDecoder decodeObject] retain];
      struct CNode* nn = malloc(sizeof(struct CNode));
      nn->_next = 0;
      nn->_c = com;
      if (tail == 0) 
         _head = tail = nn;
      else tail->_next = nn;
      tail = nn;
      i++;
   }
   return self;
}

@end
