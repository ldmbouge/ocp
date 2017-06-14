//
//  Service.m
//  Clo
//
//  Created by Sarah Peck on 3/6/17.
//
//

#import "Service.h"

@implementation Service

- (id) initWithId: (int) serviceId
    serviceFixMemory: (int) serviceFixMemory
serviceScaledMemory: (double) serviceScaledMemory
 serviceFixBandwidth: (int) serviceFixBandwidth
serviceScaledBandwidth: (double) serviceScaledBandwidth
      serviceZone: (int) serviceZone
   serviceMaxConn: (int) serviceMaxConn{
    self = [super init];
    if (self){
        self.serviceId = serviceId;
        self.serviceFixMemory = serviceFixMemory;
        self.serviceScaledMemory = serviceScaledMemory;
        self.serviceFixBandwidth = serviceFixBandwidth;
        self.serviceScaledBandwidth = serviceScaledBandwidth;
        self.serviceZone = serviceZone;
        self.serviceMaxConn = serviceMaxConn;
    }
    return self;
}

@end
