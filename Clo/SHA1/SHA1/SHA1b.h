//
//  SHA1b.h
//  Clo
//
//  Created by Greg Johnson on 2/11/13.
//  Copyright (c) 2013 CSE. All rights reserved.
//

#import <Foundation/Foundation.h>

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

#define SHA1b_DIGEST_LENGTH 5
#define DIGEST_VAR_LENGTH 8

#define K0 0x5A827999
#define K1 0x6ED9EBA1
#define K2 0x8F1BBCDC
#define K3 0xCA62C1D6

#ifndef BV_SEARCH_HEUR
#define BV_SEARCH_HEUR
typedef enum {BVFF, BVABS, BVIBS, BVLSB, BVMSB, BVMID, BVRAND, BVMIX} BVSearchHeuristic;
#endif

@interface SHA1b : NSObject{
@private
   id<ORModel>    _m;
   NSFileManager  *_fm;
   NSMutableArray *_digest;
   NSMutableArray *_temps;
   id<ORBitVar>   _kVars[4];
   volatile id<ORBitVar>  _W[80];
   uint64         _messageLength; //in bits
   uint32         *_buffer;
   uint64         _numBlocks;
   NSMutableArray *_messageBlocks;
   
}

+(SHA1b*) initSHA1b;
-(SHA1b*) initExplicitSHA1b;

-(bool) getMessage:(NSString*) fname;
-(NSMutableArray*) getSHA1bDigest:(NSString*)fname;
-(void) createSHA1bBlocks:(uint32*)mask;
-(void) createSHA1bBlock:(uint32*)data withCount:(uint64)count andMask:(uint32*)messageMask;
-(id<ORBitVar>) getK:(int) t;
-(void) getW:(id<ORBitVar>*) x;
-(id<ORBitVar>) f:(id<ORBitVar>)x y:(id<ORBitVar>)y z:(id<ORBitVar>)z;
-(id<ORBitVar>) g:(id<ORBitVar>)x y:(id<ORBitVar>)y z:(id<ORBitVar>)z;
-(id<ORBitVar>) h:(id<ORBitVar>)x y:(id<ORBitVar>)y z:(id<ORBitVar>)z;
-(id<ORBitVar>*) round1:(id<ORBitVar>*)h x:(id<ORBitVar>*) x;
-(id<ORBitVar>*) round2:(id<ORBitVar>*)h x:(id<ORBitVar>*) x;
-(id<ORBitVar>*) round3:(id<ORBitVar>*)h x:(id<ORBitVar>*) x;
-(id<ORBitVar>*) round4:(id<ORBitVar>*)h x:(id<ORBitVar>*) x;
-(id<ORBitVar>) shuffle1:(id<ORBitVar>)A b:(id<ORBitVar>)B c:(id<ORBitVar>)C d:(id<ORBitVar>) D e:(id<ORBitVar>)E t:(uint32)t x:(id<ORBitVar>*) x;
-(id<ORBitVar>) shuffle2:(id<ORBitVar>)A b:(id<ORBitVar>)B c:(id<ORBitVar>)C d:(id<ORBitVar>) D e:(id<ORBitVar>)E t:(uint32)t x:(id<ORBitVar>*) x;
-(id<ORBitVar>) shuffle3:(id<ORBitVar>)A b:(id<ORBitVar>)B c:(id<ORBitVar>)C d:(id<ORBitVar>) D e:(id<ORBitVar>)E t:(uint32)t x:(id<ORBitVar>*) x;
-(NSString*) preimage:(NSString*)filename withMask:(uint32*) mask andHeuristic:(BVSearchHeuristic)heur;
-(id<ORBitVar>*) stateModel;
@end

@interface SHA1bBlock : NSObject
{
@private
   id<ORModel>    _m;
   uint32         _data[16];
   id<ORBitVar>   *_bitVars;
}
+(SHA1bBlock*) initSHA1bBlock:(id<ORModel>)m;
-(SHA1bBlock*) initExplicitSHA1bBlock:(id<ORModel>)m;
-(void) setData:(ORUInt*)data;
-(void) setData:(ORUInt*)data withMask:(uint32*)mask;
-(ORUInt*) getData;
-(id<ORBitVar>*) getORVars;

@end

