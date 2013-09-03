//
//  SetCoveringInstanceParser.m
//  Clo
//
//  Created by Daniel Fontaine on 8/28/13.
//
//

#import "SetCoveringInstanceParser.h"

@implementation SetCoveringInstance
@synthesize universe = _universe;
@synthesize sets = _sets;
-(id) initWithUniverse:(ORInt)u sets:(id<ORIntSetArray>)sets
{
    self = [super init];
    if(self) {
        _universe = u;
        _sets = sets;
    }
    return self;
}
@end

@implementation SetCoveringInstanceParser
-(SetCoveringInstance*) parseInstanceFile: (id<ORTracker>)tracker path: (NSString*)path {
    NSString* data = [NSString stringWithContentsOfFile: path encoding: NSASCIIStringEncoding error:nil];
    NSArray* lines = [data componentsSeparatedByCharactersInSet: [NSCharacterSet newlineCharacterSet]];
    ORInt u = 0;
    id<ORIntSetArray> sets = [ORFactory intSetArray: tracker range: RANGE(tracker, 0, 449)];
    ORInt k = 0;
    for(ORInt i = 0; i < lines.count; i++) {
        NSString* line = [lines objectAtIndex: i];
        NSArray* components = [line componentsSeparatedByCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
        NSArray* values = [components filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF != ''"]];        
        if(values.count == 0) continue;
        if([values[0] isEqualToString: @"p"]) {
            u = [values[2] intValue];
        }
        else if([values[0] isEqualToString: @"s"]) {
            NSMutableSet* s = [[NSMutableSet alloc] initWithCapacity: values.count];
            [values enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL* stop) {
                if(idx > 0) [s addObject: [NSNumber numberWithInteger: [obj integerValue]]];
            }];
            [sets set: [ORFactory intSet: tracker set: s] at: k++];
        }
        [components release];
        [values release];
    }
    [lines release];
    SetCoveringInstance* instance = [[SetCoveringInstance alloc] initWithUniverse: u sets: sets];
    return instance;
}
@end
