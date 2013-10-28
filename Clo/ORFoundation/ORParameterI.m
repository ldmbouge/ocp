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
}
-(ORIntParamI*) initORIntParamI: (id<ORTracker>) track
{
    self = [super init];
    _tracker = track;
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
-(NSString*) description
{
    return [NSString stringWithFormat:@"param<OR>{int}:%03d",_name];
}
- (void)visit:(ORVisitor*)visitor
{
    [visitor visitIntParam: self];
}
@end

@implementation ORFloatParamI {
@protected
    id<ORTracker>  _tracker;
}
-(ORFloatParamI*) initORFloatParamI: (id<ORTracker>) track
{
    self = [super init];
    _tracker = track;
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
    return ORTFloat;
}
-(NSString*) description
{
    return [NSString stringWithFormat:@"param<OR>{float}:%03d",_name];
}
- (void)visit:(ORVisitor*)visitor
{
    [visitor visitFloatParam: self];
}
@end