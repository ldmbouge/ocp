/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import "CPConstraintI.h"
#import "CPEngineI.h"

@implementation CPCoreConstraint
-(CPCoreConstraint*) initCPCoreConstraint 
{
   self = [super init];
   _todo = CPTocheck;
   _idempotent = NO;
   _priority = HIGHEST_PRIO;
   _name = 0;
   _propagate = [self methodForSelector:@selector(propagate)];
   return self;
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
-(void) setId:(ORUInt)name
{
   _name = name;
}
-(ORUInt)getId
{ 
   return _name;
}
-(NSSet*)allVars
{
   return [[NSSet alloc] init];
}
-(ORUInt)nbUVars
{
   NSSet* av = [self allVars];
   ORUInt nbu = 0;
   for(id aVar in av) {
      nbu += ![aVar bound];
   }
   [av release];
   return nbu;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeValueOfObjCType:@encode(ORUInt) at:&_name];
    [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_todo];
    [aCoder encodeValueOfObjCType:@encode(BOOL) at:&_idempotent];
    [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_priority];    
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    [aDecoder decodeValueOfObjCType:@encode(ORUInt) at:&_name];
    [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_todo];
    [aDecoder decodeValueOfObjCType:@encode(BOOL) at:&_idempotent];
    [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_priority]; 
    return self;
}
@end

@implementation CPActiveConstraint
-(id) initCPActiveConstraint: (CPEngineI*) m
{
    self = [super initCPCoreConstraint];
    _trail = [[m trail] retain];
    _active  = makeTRInt(_trail,true);
    return self;
}
-(void)dealloc
{
   [super dealloc];
   [_trail release];
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:_trail];
    [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_active._val];
    [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_active._mgc];
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
   self = [super initWithCoder:aDecoder];
   _trail = [[aDecoder decodeObject] retain];
   [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_active._val];
   [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_active._mgc];
   return self;
}
@end

