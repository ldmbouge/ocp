//
//  SecurityTech.h
//  Clo
//
//  Created by Sarah Peck on 3/6/17.
/*
        Need to add zone (T), scaled memory, scaled bandwidth (Smem, Sbw)
*/
//
//

#import <Foundation/Foundation.h>

@interface SecurityTech : NSObject

@property int secId;
@property int secFixedMemory;
@property int secFixedBandwidth;
@property double secScaledMemory;
@property double secScaledBandwidth;
@property int secZone;

- (id) initWithId: (int) secId
   secFixedMemory: (int) secFixedMemory
secFixedBandwidth: (int) secFixedBandwidth
  secScaledMemory: (double) secScaledMemory
secScaledBandwidth: (double) secScaledBandwidth
          secZone: (int) secZone;

@end
