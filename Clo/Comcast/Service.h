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
@property int serviceMemory;
@property int serviceBandwidth;

- (id) initWithId: (int) serviceId
    serviceMemory: (int) serviceMemory
 serviceBandwidth: (int) serviceBandwidth;

@end
