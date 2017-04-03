//
//  SecurityTech.m
//  Clo
//
//  Created by Sarah Peck on 3/6/17.
//
//

#import "SecurityTech.h"

@implementation SecurityTech

- (id) initWithId: (int) secId
       secMemory: (int) secProp1
       secBandwidth: (int) secProp2 {
    self = [super init];
    if (self){
        self.secId = secId;
        self.secMemory = secProp1;
        self.secBandwidth = secProp2;
    }
    return self;
}

@end
