//
//  Cnode.h
//  Clo
//
//  Created by Sarah Peck on 3/6/17.
//
//

#import <Foundation/Foundation.h>

@interface Cnode : NSObject

// @property int cnodeIntId;
@property int cnodeExtId;
@property int cnodeMemory; // in MB
@property int cnodeBandwidth; // in MB/s

- (id) initWithId: (int) cnodeExtId
         cnodeMemory: (int) cnodeMemory
         cnodeBandwidth: (int) cnodeBandwidth;

@end
