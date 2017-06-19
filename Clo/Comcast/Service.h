//
//  Service.h
//  Clo
//
//  Created by Sarah Peck on 3/6/17.
/*
        Need to add security zone - Tapp; max connections
 
 */
//
//

#import <Foundation/Foundation.h>

@interface Service : NSObject

@property int serviceId;
@property int serviceFixMemory;
@property double serviceScaledMemory;
@property int serviceFixBandwidth;
@property double serviceScaledBandwidth;
@property int serviceZone;
@property int serviceMaxConn;

- (id) initWithId: (int) serviceId
    serviceFixMemory: (int) serviceFixMemory
serviceScaledMemory: (double) serviceScaledMemory
 serviceFixBandwidth: (int) serviceFixBandwidth
serviceScaledBandwidth: (double) serviceScaledBandwidth
      serviceZone: (int) serviceZone
   serviceMaxConn: (int) serviceMaxConn;

@end
