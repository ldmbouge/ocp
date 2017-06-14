//
//  Cnode.h
//  Clo
//
//  Created by Sarah Peck on 3/6/17.
//
//

#import <Foundation/Foundation.h>
#import <ORFoundation/ORFoundation.h>
#import <ORFoundation/ORSemBDSController.h>
#import <ORFoundation/ORSemDFSController.h>
#import <ORModeling/ORModeling.h>
#import <ORModeling/ORModelTransformation.h>
#import <ORProgram/ORProgram.h>
#import <ORModeling/ORLinearize.h>

@interface Cnode : NSObject

// @property int cnodeIntId;
@property int cnodeExtId;
@property ORInt cnodeMemory; // in MB
@property int cnodeBandwidth; // in MB/s

- (id) initWithId: (int) cnodeExtId
         cnodeMemory: (ORInt) cnodeMemory
         cnodeBandwidth: (int) cnodeBandwidth;

@end
