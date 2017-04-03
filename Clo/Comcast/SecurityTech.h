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
@property int secMemory;
@property int secBandwidth;

- (id) initWithId: (int) secId
       secMemory: (int) secProp1
       secBandwidth: (int) secProp2;

@end
