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

#import "CPConstraintI.h"
#import "CPSolverI.h"

@implementation CPCoreConstraint
-(CPCoreConstraint*) initCPCoreConstraint 
{
    self = [super init];
    _todo = CPTocheck;
    _idempotent = NO; 
    _priority = HIGHEST_PRIO;
    _name = 0;
    return self;
}
// Tracer method
-(CPStatus) doIt
{
    return [self post];
}
// Constraint method
-(CPStatus) post 
{
    return CPSuspend;
}
-(CPStatus) propagate
{
    return CPSuspend;
}
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
-(id) initCPActiveConstraint:(id<CPSolver>) m
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

