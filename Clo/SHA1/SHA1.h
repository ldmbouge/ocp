//
//  SHA1.h
//  Clo
//
//  Created by Greg Johnson on 2/11/13.
//  Copyright (c) 2013 CSE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Foundation/NSData.h>
#import <Foundation/NSString.h>

#import <ORFoundation/ORAVLTree.h>
#import <ORFoundation/ORFactory.h>
#import <ORFoundation/ORSetI.h>
#import <ORModeling/ORModeling.h>
#import <ORProgram/ORProgram.h>
#import <objcp/CPObjectQueue.h>
#import <objcp/CPFactory.h>

#import <objcp/CPConstraint.h>
#import <objcp/CPBitMacros.h>
#import <objcp/CPBitArray.h>
#import <objcp/CPBitArrayDom.h>
#import <objcp/CPBitConstraint.h>

#define SHA1_DIGEST_LENGTH 5
#define DIGEST_VAR_LENGTH 8

#define K0 0x5A827999
#define K1 0x6ED9EBA1
#define K2 0x8F1BBCDC
#define K3 0xCA62C1D6

#ifndef BV_SEARCH_HEUR
#define BV_SEARCH_HEUR
typedef enum {BVFF, BVABS, BVIBS, BVLSB, BVMSB, BVMID, BVRAND, BVMIX} BVSearchHeuristic;
#endif

@interface SHA1 : NSObject{
@private
   id<ORModel>    _m;
   NSFileManager  *_fm;
   NSMutableArray *_digest;
   NSMutableArray *_temps;
   id<ORBitVar>   _kVars[4];
   id<ORBitVar>   _W[80];
   uint64         _messageLength; //in bits
   uint32         *_buffer;
   uint64         _numBlocks;
   NSMutableArray *_messageBlocks;
   
}

+(SHA1*) initSHA1;
-(SHA1*) initExplicitSHA1;

-(bool) getMessage:(NSString*) fname;
-(NSMutableArray*) getSHA1Digest:(NSString*)fname;
-(void) createSHA1Blocks:(uint32*)mask;
-(void) createSHA1Block:(uint32*)data withCount:(uint64)count andMask:(uint32*)messageMask;
-(id<ORBitVar>) getK:(int) t;
-(id<ORBitVar>) f:(id<ORBitVar>)x y:(id<ORBitVar>)y z:(id<ORBitVar>)z;
-(id<ORBitVar>) g:(id<ORBitVar>)x y:(id<ORBitVar>)y z:(id<ORBitVar>)z;
-(id<ORBitVar>) h:(id<ORBitVar>)x y:(id<ORBitVar>)y z:(id<ORBitVar>)z;
-(id<ORBitVar>*) roundSHA1:(id<ORBitVar>[])h x:(id<ORBitVar>[]) x;
-(id<ORBitVar>) shuffle:(id<ORBitVar>)A b:(id<ORBitVar>)B c:(id<ORBitVar>)C d:(id<ORBitVar>) D e:(id<ORBitVar>) E t:(uint32)t;
-(NSString*) preimage:(NSString*)filename withMask:(uint32*) mask andHeuristic:(BVSearchHeuristic)heur;
-(id<ORBitVar>*) stateModel;
@end

@interface SHA1Block : NSObject
{
@private
   id<ORModel>    _m;
   uint32         _data[16];
   id<ORBitVar>   *_bitVars;
}
+(SHA1Block*) initSHA1Block:(id<ORModel>)m;
-(SHA1Block*) initExplicitSHA1Block:(id<ORModel>)m;
-(void) setData:(ORUInt*)data;
-(void) setData:(ORUInt*)data withMask:(uint32*)mask;
-(ORUInt*) getData;
-(id<ORBitVar>*) getORVars;

@end

