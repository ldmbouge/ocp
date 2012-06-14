//
//  main.m
//  xxx
//
//  Created by Laurent Michel on 6/22/11.
//  Copyright 2011 CSE. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CPEventCenter : NSObject {
@private
   NSMutableDictionary* _table;
}
-(id)initCPEventCenter:(SEL)s0,...;
-(void)dealloc;
-(void)forwardInvocation:(NSInvocation*)i;
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector;
-(void) whenever:(SEL)selector notify:(id)obj;
-(void) whenever:(SEL)selector notify:(id)obj inScope:(void(^)())closure;
-(void) when:(SEL)selector notify:(id)obj;
@end

@interface CPForwardee : NSObject {
@private   
   id     receiver;
   bool       once;  // only dispatch once! [when]
}
-(id)initCPForwardee:(id)r once:(bool)b;
-(void)dealloc;
-(NSString*)description;
@property (readonly) id receiver;
@property (readonly) bool   once;
@end

@implementation CPForwardee
-(id)initCPForwardee:(id)r once:(bool)b
{
   [super init];
   receiver = [r retain];
   once = b;
   return self;
}
-(void)dealloc
{
   [receiver release];
   [super dealloc];
}
-(NSString*)description
{
   return [NSString stringWithFormat:@"forwardee(%p,%s)",receiver,once ? "YES" : "NO"];
}
@synthesize receiver;
@synthesize once;
@end

@implementation CPEventCenter
-(id)initCPEventCenter:(SEL)s0, ... 
{
   [super init];
   _table = [[NSMutableDictionary alloc] init];
   va_list ap;
   [_table setValue:[NSMutableArray arrayWithCapacity:1] forKey:NSStringFromSelector(s0)];
   va_start(ap, s0);
   SEL sk = nil;
   sk = va_arg(ap, SEL);
   while (sk!=nil) {
      [_table setValue:[NSMutableArray arrayWithCapacity:1] forKey:NSStringFromSelector(sk)];
      sk = va_arg(ap,SEL);
   }
   va_end(ap);
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
-(void)forwardInvocation:(NSInvocation*)anInvocation
{
   SEL theSel = [anInvocation selector];
   NSMutableArray* allForwardees = [_table objectForKey:NSStringFromSelector(theSel)];
   NSIndexSet* all =[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [allForwardees count])];  // auto-released
   NSIndexSet* tr = [all indexesPassingTest:^BOOL(NSUInteger idx, BOOL *stop) {                     // auto-released
      return [[allForwardees objectAtIndex:idx] once]==YES;
   }];
   for(id forwardee in allForwardees) {
      [anInvocation setTarget:[forwardee receiver]];
      [anInvocation invoke];    
   }
   [allForwardees removeObjectsAtIndexes:tr];
}
-(void) whenever:(SEL)selector notify:(id)obj
{
   NSMutableArray* array = [_table objectForKey:NSStringFromSelector(selector)];
   [array addObject:[[CPForwardee alloc] initCPForwardee:obj once:NO]];
}
-(void) when:(SEL)selector notify:(id)obj
{
   NSMutableArray* array = [_table objectForKey:NSStringFromSelector(selector)];
   [array addObject:[[CPForwardee alloc] initCPForwardee:obj once:YES]];
}
-(void) whenever:(SEL)selector notify:(id)obj inScope:(void(^)())closure
{
   NSMutableArray* array = [_table objectForKey:NSStringFromSelector(selector)];
   NSInteger idx = [array count];
   [array addObject:[[CPForwardee alloc] initCPForwardee:obj once:NO]];
   closure();
   [array removeObjectAtIndex:idx];
}
@end


// This is to give the API of the event (optional as the notifier won't implement it ever!
@protocol RepEvt <NSObject>
@optional -(void)newUB:(int)ub withSol:(id)sol;   
@optional -(void)newLB:(int)lb;
@end

@interface Repository : CPEventCenter<RepEvt> {
}
-(id)initRepository;
-(void) someInternalProcess:(int)x;
@end


@implementation Repository
-(id)initRepository
{
   [super initCPEventCenter:@selector(newUB:withSol:),
                            @selector(newLB:),
                            nil];
   return self;
}
-(void) someInternalProcess:(int)x
{
   id s = nil;
   [self newUB:x withSol:s];
}
@end


@interface User : NSObject {
   NSString* _name;
}
-(id)initUser:(NSString*)n;
-(void)doSomething:(Repository*)r;
@end

@implementation User
-(id)initUser:(NSString*)n;
{
   [super init];
   _name = [n retain];
   return self;
}
-(void)dealloc {
   [_name release];
   [super dealloc];
}
-(void)doSomething:(Repository*)r 
{
   [r when:@selector(newUB:withSol:) notify:self];
   [r someInternalProcess:0];
   [r whenever:@selector(newUB:withSol:) notify: self];
   [r whenever:@selector(newUB:withSol:) notify: self inScope: ^() {
      NSLog(@"A scoped block in a selector.... triggering....\n");
      [r someInternalProcess:1];
   }];
   [r someInternalProcess:2];
}
-(void)doSomethingElse:(Repository*)r 
{
   // simply registering an interest in those events
   [r when:@selector(newUB:withSol:) notify:self];
   [r whenever:@selector(newUB:withSol:) notify: self];
}
-(void)newUB:(int)ub withSol:(id)sol 
{
   NSLog(@"event called on %@ %d\n",_name,ub);
}
@end

int main (int argc, const char * argv[])
{

   NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];

   // insert code here...
   NSLog(@"Hello, World!");
   
   Repository* r = [[Repository alloc] initRepository];
   
   User* u1 = [[User alloc] initUser:@"U1:"];
   User* u2 = [[User alloc] initUser:@"U2:"];
   [u1 doSomething:r];
   [u2 doSomethingElse:r];
   [r someInternalProcess:3];
   [r someInternalProcess:4];

   [pool drain];
    return 0;
}

