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
    ORInt _value;
}
-(ORIntParamI*) initORIntParamI: (id<ORTracker>) track value: (ORInt)x
{
    self = [super init];
    _tracker = track;
    _value = x;
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
    [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_value];
}
-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    _tracker = [aDecoder decodeObject];
    [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_value];
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
-(NSString*) description
{
    return [NSString stringWithFormat:@"param<OR>{int}:%03d(%d)",_name, _value];
}
-(ORInt) value
{
    return [self intValue];
}
-(void) set:(ORInt)x {
    _value = x;
}
-(ORInt) intValue {
    return _value;
}
-(ORFloat) floatValue {
    return _value;
}
@end

@implementation ORFloatParamI {
@protected
    id<ORTracker>  _tracker;
    ORFloat _value;
}
-(ORFloatParamI*) initORFloatParamI: (id<ORTracker>) track value: (ORFloat)x
{
    self = [super init];
    _tracker = track;
    _value = x;
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
    [aCoder encodeValueOfObjCType:@encode(ORFloat) at:&_value];
}
-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    _tracker = [aDecoder decodeObject];
    [aDecoder decodeValueOfObjCType:@encode(ORFloat) at:&_value];
    return self;
}
-(ORBool) isVariable
{
    return NO;
}
-(enum ORVType) vtype
{
    return ORTFloat;
}
-(NSString*) description
{
    return [NSString stringWithFormat:@"param<OR>{float}:%03d(%f)",_name, _value];
}
-(ORFloat) value
{
    return [self floatValue];
}
-(void) set:(ORFloat)x {
    _value = x;
}
-(ORInt) intValue {
    return _value;
}
-(ORFloat) floatValue {
    return _value;
}
@end