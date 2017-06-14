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
   secFixedMemory: (int) secFixedMemory
secFixedBandwidth: (int) secFixedBandwidth
  secScaledMemory: (double) secScaledMemory
secScaledBandwidth: (double) secScaledBandwidth
          secZone: (int) secZone{
    self = [super init];
    if (self){
        self.secId = secId;
        self.secFixedMemory = secFixedMemory;
        self.secFixedBandwidth = secFixedBandwidth;
        self.secScaledMemory = secScaledMemory;
        self.secScaledBandwidth = secScaledBandwidth;
        self.secZone = secZone;
    }
    return self;
}

@end
