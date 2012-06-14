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


#import "CPEvents.h"
#import "CPObjectQueue.h"
#import <pthread.h>
#import <stdlib.h>

@interface CPForwardee : NSObject {
@private   
   id     receiver;
   bool       once;  // only dispatch once! [when]
   NSThread* recvt;
}
-(id)initCPForwardee:(id)r once:(bool)b;
-(void)dealloc;
-(NSString*)description;
@property (readonly) id receiver;
@property (readonly) bool   once;
@property (readonly) NSThread* recvt;
@end


@implementation CPForwardee
-(id)initCPForwardee:(id)r once:(bool)b
{
   self = [super init];
   receiver = [r retain];
   once = b;
   recvt = [[NSThread currentThread] retain];
   return self;
}
-(void)dealloc
{
   [receiver release];
   [recvt release];
   [super dealloc];
}
-(NSString*)description
{
   return [NSString stringWithFormat:@"forwardee(%p,%s)",receiver,once ? "YES" : "NO"];
}
@synthesize receiver;
@synthesize once;
@synthesize recvt;
@end

@implementation CPEventDispatch

-(id)initCPEventCenter:(SEL)s0, ... 
{
   self = [super init];   
   id arp = [[NSAutoreleasePool alloc] init];
   _table = [[NSMutableDictionary alloc] init];
   va_list ap;
   [_table setValue:[[NSMutableArray alloc] initWithCapacity:1] forKey:NSStringFromSelector(s0)];
   va_start(ap, s0);
   SEL sk = NULL;
   sk = va_arg(ap, SEL);
   while (sk!=NULL) {
      [_table setValue:[[NSMutableArray alloc] initWithCapacity:1] forKey:NSStringFromSelector(sk)];
      sk = va_arg(ap,SEL);
   }
   va_end(ap);
   [arp release];
   return self;
}
-(void)dealloc
{
   [_table release];
   [super dealloc];
}
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
   NSArray* a = [_table objectForKey:NSStringFromSelector(aSelector)];
   if (a==nil)
      return nil;
   else {
      if ([a count] > 0)
         return [[[[a objectAtIndex:0] receiver] class] instanceMethodSignatureForSelector:aSelector];
      else return [NSMethodSignature signatureWithObjCTypes:"@^v^c"]; // who cares, we won't forward anyway!
   }
} 
-(void)delayedForward:(NSInvocation*)anInvocation forThread:(NSThread*)theThread
{
   CPObjectQueue* oq = [[theThread threadDictionary] objectForKey:@"cptls"];
   if (oq == nil) {
      oq = [[CPObjectQueue alloc]initEvtQueue:32];
      [[theThread threadDictionary] setObject:oq forKey:@"cptls"];   
   }
   [oq enQueue:[anInvocation copy]];
}
-(void)forwardInvocation:(NSInvocation*)anInvocation
{
   SEL theSel = [anInvocation selector];
   NSMutableArray* allForwardees = [_table objectForKey:NSStringFromSelector(theSel)];
   NSIndexSet* all = [[NSIndexSet alloc] initWithIndexesInRange:NSMakeRange(0, [allForwardees count])]; 
   NSMutableIndexSet* tr = [[NSMutableIndexSet alloc] init];
   NSUInteger* ai = alloca(sizeof(CPUInt)*[all count]);
   NSRange copied = NSMakeRange(0, [allForwardees count]);
   CPUInt nbI = [all getIndexes:ai maxCount: [all count] inIndexRange:&copied];
   for(CPUInt k=0;k<nbI;k++)
     if ([[allForwardees objectAtIndex:ai[k]] once] == YES)
       [tr addIndex: ai[k]];   
   NSThread* ct = [NSThread currentThread];
   for(id forwardee in allForwardees) {
      [anInvocation setTarget:[forwardee receiver]];
      if ([forwardee recvt] == ct)
         [anInvocation invoke];  
      else
         [self delayedForward:anInvocation forThread:[forwardee recvt]];      
   }
   [allForwardees removeObjectsAtIndexes:tr];
   [all release];
   [tr release];
}
+(void) dispatchDelayedInvocations
{
   CPObjectQueue* oq = [[[NSThread currentThread] threadDictionary] objectForKey:@"cptls"];
   if (oq != nil) {
      NSInvocation* anInvocation = nil;
      while ((anInvocation = [oq deQueue]) != nil) {
         [anInvocation invoke];
         [anInvocation release];
      }
   }
}
-(void) whenever:(SEL)selector notify:(id)obj
{
   NSMutableArray* array = [_table objectForKey:NSStringFromSelector(selector)];
   id objf =[[CPForwardee alloc] initCPForwardee:obj once:NO];
   [array addObject:objf];
   [objf release];
}
-(void) when:(SEL)selector notify:(id)obj
{
   NSMutableArray* array = [_table objectForKey:NSStringFromSelector(selector)];
   id objf = [[CPForwardee alloc] initCPForwardee:obj once:YES];
   [array addObject:objf];
   [objf release];
}
-(void) whenever:(SEL)selector notify:(id)obj inScope:(void(^)())closure
{
   NSMutableArray* array = [_table objectForKey:NSStringFromSelector(selector)];
   CPInt idx = [array count];
   id objf = [[CPForwardee alloc] initCPForwardee:obj once:NO];
   [array addObject:objf];
   [objf release];
   closure();
   [array removeObjectAtIndex:idx];
}
@end
