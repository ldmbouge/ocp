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
-(void) setId:(CPUInt)name
{
   _name = name;
}
-(CPUInt)getId
{ 
   return _name;
}
-(NSSet*)allVars
{
   return [[NSSet alloc] init];
}
-(CPUInt)nbUVars
{
   NSSet* av = [self allVars];
   CPUInt nbu = 0;
   for(id aVar in av) {
      nbu += ![aVar bound];
   }
   [av release];
   return nbu;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeValueOfObjCType:@encode(CPUInt) at:&_name];
    [aCoder encodeValueOfObjCType:@encode(CPInt) at:&_todo];
    [aCoder encodeValueOfObjCType:@encode(BOOL) at:&_idempotent];
    [aCoder encodeValueOfObjCType:@encode(CPInt) at:&_priority];    
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    [aDecoder decodeValueOfObjCType:@encode(CPUInt) at:&_name];
    [aDecoder decodeValueOfObjCType:@encode(CPInt) at:&_todo];
    [aDecoder decodeValueOfObjCType:@encode(BOOL) at:&_idempotent];
    [aDecoder decodeValueOfObjCType:@encode(CPInt) at:&_priority]; 
    return self;
}
@end

@implementation CPActiveConstraint
-(id) initCPActiveConstraint:(id<CPEngine>) m
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
    [aCoder encodeValueOfObjCType:@encode(CPInt) at:&_active._val];
    [aCoder encodeValueOfObjCType:@encode(CPInt) at:&_active._mgc];
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    _trail = [[aDecoder decodeObject] retain];
    [aDecoder decodeValueOfObjCType:@encode(CPInt) at:&_active._val];
    [aDecoder decodeValueOfObjCType:@encode(CPInt) at:&_active._mgc];
    return self;
}
@end

