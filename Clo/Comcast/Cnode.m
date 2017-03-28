//
//  Cnode.m
//  Clo
//
//  Created by Sarah Peck on 3/6/17.
//
//

#import "Cnode.h"

@implementation Cnode

- (id) initWithId: (int) cnodeId
         cnodeMemory: (int) cnodeMemory
         cnodeBandwidth: (int) cnodeBandwidth {
    self = [super init];
    if (self){
        self.cnodeId = cnodeId;
        self.cnodeMemory = cnodeMemory;
        self.cnodeBandwidth = cnodeBandwidth;
    }
    return self;
}

@end
