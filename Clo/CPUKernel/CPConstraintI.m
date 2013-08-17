/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <CPUKernel/CPConstraintI.h>
#import <CPUKernel/CPEngineI.h>

@implementation CPCoreConstraint
-(CPCoreConstraint*) initCPCoreConstraint:(id<ORSearchEngine>)m
{
   self = [super init];
   _todo = CPTocheck;
   _idempotent = NO;
   _priority = HIGHEST_PRIO;
   _propagate = [self methodForSelector:@selector(propagate)];
   _trail = [[m trail] retain];
   _active  = makeTRInt(_trail,true);
   _group = nil;
   return self;
}
-(void)dealloc
{
   [_trail release];
   [super dealloc];
}
// Tracer method
-(ORStatus) doIt
{
    return [self post];
}
// Constraint method
-(ORStatus) post 
{
    return ORSuspend;
}
-(void) propagate
{}
-(NSSet*)allVars
{
   return [[[NSSet alloc] init] autorelease];
}
-(ORUInt)nbUVars
{
   ORUInt nbu = 0;
   @autoreleasepool {
      NSSet* av = [self allVars];
      for(id aVar in av) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-method-access"
         nbu += ![aVar bound];
#pragma clang diagnostic pop
      }
   }
   return nbu;
}
-(void)setGroup:(id<CPGroup>)g
{
   _group = g;
}
-(id<CPGroup>)group
{
   return _group;
}

-(void) visit: (ORVisitor*) visitor
{
   [visitor visitConstraint:self];
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeValueOfObjCType:@encode(ORUInt) at:&_name];
    [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_todo];
    [aCoder encodeValueOfObjCType:@encode(ORBool) at:&_idempotent];
    [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_priority];    
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    [aDecoder decodeValueOfObjCType:@encode(ORUInt) at:&_name];
    [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_todo];
    [aDecoder decodeValueOfObjCType:@encode(ORBool) at:&_idempotent];
    [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_priority]; 
    return self;
}
@end

