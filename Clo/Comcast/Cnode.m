//
//  Cnode.m
//  Clo
//
//  Created by Sarah Peck on 3/6/17.
//
//

#import "Cnode.h"

@implementation Cnode

- (id) initWithId: (int) cnodeExtId
         cnodeMemory: (int) cnodeMemory
         cnodeBandwidth: (int) cnodeBandwidth
         cnodeCPU: (int) cnodeCPU{
    self = [super init];
    if (self){
        /* self.cnodeIntId = cnodeIntId; */
        self.cnodeExtId = cnodeExtId;
        self.cnodeMemory = cnodeMemory;
        self.cnodeBandwidth = cnodeBandwidth;
        self.cnodeCPU = cnodeCPU;
    }
    return self;
}
-(NSString*)description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"(%d : %d,%d,%d)",_cnodeExtId,_cnodeMemory,_cnodeBandwidth,_cnodeCPU];
   return buf;
}

@end
