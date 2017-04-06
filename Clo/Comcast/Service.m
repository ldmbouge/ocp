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
    serviceMemory: (int) serviceMemory
 serviceBandwidth: (int) serviceBandwidth
      serviceZone: (int) serviceZone
   serviceMaxConn: (int) serviceMaxConn{
    self = [super init];
    if (self){
        self.serviceId = serviceId;
        self.serviceMemory = serviceMemory;
        self.serviceBandwidth = serviceBandwidth;
        self.serviceZone = serviceZone;
        self.serviceMaxConn = serviceMaxConn;
    }
    return self;
}

@end
