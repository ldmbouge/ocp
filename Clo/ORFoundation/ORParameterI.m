//
//  ORParameterI.m
//  Clo
//
//  Created by Daniel Fontaine on 9/19/13.
//
//

#import "ORParameterI.h"

@implementation ORIntParamI {
@protected
    id<ORTracker>  _tracker;
    ORInt _val;
}
-(ORIntParamI*) initORIntParamI: (id<ORTracker>) track initialValue:(ORInt)val
{
    self = [super init];
    _tracker = track;
    _val = val;
    [track trackMutable: self];
    return self;
}
-(void) dealloc
{
    [super dealloc];
}
-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_tracker];
}
-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    _tracker = [aDecoder decodeObject];
    return self;
}
-(ORBool) isVariable
{
    return NO;
}
-(enum ORVType) vtype
{
    return ORTInt;
}
-(ORInt) initialValue
{
    return _val;
}
-(NSString*) description
{
    return [NSString stringWithFormat:@"param<OR>{int}:%03d",_name];
}
- (void)visit:(ORVisitor*)visitor
{
    [visitor visitIntParam: self];
}
@end

@implementation ORRealParamI {
@protected
    id<ORTracker>  _tracker;
    ORFloat _val;
}
-(ORRealParamI*) initORRealParamI: (id<ORTracker>) track initialValue:(ORDouble)val
{
    self = [super init];
    _tracker = track;
    _val = val;
    [track trackMutable: self];
    return self;
}
-(void) dealloc
{
    [super dealloc];
}
-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_tracker];
}
-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    _tracker = [aDecoder decodeObject];
    return self;
}
-(ORBool) isVariable
{
    return NO;
}
-(enum ORVType) vtype
{
    return ORTReal;
}
-(ORDouble) initialValue
{
    return _val;
}
-(NSString*) description
{
    return [NSString stringWithFormat:@"param<OR>{float}:%03d[iv=%f]",_name, _val];
}
- (void)visit:(ORVisitor*)visitor
{
    [visitor visitRealParam: self];
}
@end