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
       secProp1: (int) secProp1
       secProp2: (int) secProp2 {
    self = [super init];
    if (self){
        self.secId = secId;
        self.secProp1 = secProp1;
        self.secProp2 = secProp2;
    }
    return self;
}

@end
