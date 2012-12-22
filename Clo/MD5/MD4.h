//
//  MD4.h
//  Clo
//
//  Created by Greg Johnson on 12/18/12.
//  Copyright (c) 2012 CSE. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <ORFoundation/ORModel.h>
#import <ORModeling/ORModeling.h>
#import <ORFoundation/ORFactory.h>

@interface MD4 : NSObject{
   @private
   id<ORModel> _m;

}
-(void) initMD4;

-(id<ORBitVar>) f:(id<ORBitVar>)x y:(id<ORBitVar>)y z:(id<ORBitVar>)z;
-(id<ORBitVar>) g:(id<ORBitVar>)x y:(id<ORBitVar>)y z:(id<ORBitVar>)z;
-(id<ORBitVar>) h:(id<ORBitVar>)x y:(id<ORBitVar>)y z:(id<ORBitVar>)z;
-(id<ORBitVar>(*)[]) round1:(id<ORBitVar>[])h x:(id<ORBitVar>[]) x;
-(id<ORBitVar>(*)[]) round2:(id<ORBitVar>[])h x:(id<ORBitVar>[]) x;
-(id<ORBitVar>(*)[]) round3:(id<ORBitVar>[])h x:(id<ORBitVar>[]) x;
-(id<ORBitVar>) shuffle1:(id<ORBitVar>)A b:(id<ORBitVar>)B c:(id<ORBitVar>)C d:(id<ORBitVar>) D index:(int)i shiftBy:(int) s x:(id<ORBitVar>[]) x;
-(id<ORBitVar>) shuffle2:(id<ORBitVar>)A b:(id<ORBitVar>)B c:(id<ORBitVar>)C d:(id<ORBitVar>) D index:(int)i shiftBy:(int) s x:(id<ORBitVar>[]) x;
-(id<ORBitVar>) shuffle3:(id<ORBitVar>)A b:(id<ORBitVar>)B c:(id<ORBitVar>)C d:(id<ORBitVar>) D index:(int)i shiftBy:(int) s x:(id<ORBitVar>[]) x;
-(void) preimage:(int[]) message;


//-(void) dealloc;

@end
