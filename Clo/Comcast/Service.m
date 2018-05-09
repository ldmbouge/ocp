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
   serviceMaxConn: (int) serviceMaxConn
    serviceFixCPU: (int) serviceFixCPU{
    self = [super init];
    if (self){
        self.serviceId = serviceId;
        self.serviceFixMemory = serviceFixMemory;
        self.serviceScaledMemory = serviceScaledMemory;
        self.serviceFixBandwidth = serviceFixBandwidth;
        self.serviceScaledBandwidth = serviceScaledBandwidth;
        self.serviceZone = serviceZone;
        self.serviceMaxConn = serviceMaxConn;
        self.serviceFixCPU = serviceFixCPU;
    }
    return self;
}
-(NSString*)description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
    [buf appendFormat:@"(%d : %d,%.2f,%d,%.2f,z:%d,MC:%d,CPU:%d)",_serviceId,_serviceFixMemory,_serviceScaledMemory,
    _serviceFixBandwidth,_serviceScaledBandwidth,_serviceZone,_serviceMaxConn,_serviceFixCPU];
   return buf;
}
@end
