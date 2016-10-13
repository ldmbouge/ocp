//
//  SetCoveringInstanceParser.h
//  Clo
//
//  Created by Daniel Fontaine on 8/28/13.
//
//

#import <Foundation/Foundation.h>
#import <ORFoundation/ORFoundation.h>
#import "ORTracer.h"

@interface SetCoveringInstance : NSObject {
    @private
    ORInt _universe;
    id<ORIntSetArray> _sets;
}

@property(readonly) ORInt universe;
@property(readonly, retain) id<ORIntSetArray> sets;

-(id) initWithUniverse: (ORInt)u sets: (id<ORIntSetArray>)sets;
@end

@interface SetCoveringInstanceParser : NSObject
-(SetCoveringInstance*) parseInstanceFile: (id<ORTracker>)tracker path: (NSString*)path;
@end
