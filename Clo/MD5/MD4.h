/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

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

#define DIGEST_LENGTH 4
#define DIGEST_VAR_LENGTH 8
#define BLOCK_LENGTH 4

#ifndef BV_SEARCH_HEUR
#define BV_SEARCH_HEUR
typedef enum {BVFF, BVABS, BVIBS, BVLSB, BVMSB, BVMID, BVRAND, BVMIX} BVSearchHeuristic;
#endif

@interface MD4 : NSObject{
   @private
   id<ORModel>    _m;
//   id<ORExplorer> _explorer;
//   id<ORSearchEngine>   _engine;
   
   NSFileManager  *_fm;
   NSMutableArray *_digest;
   NSMutableArray *_temps;
   id<ORBitVar>   *hVars[4];
   uint64         _messageLength; //in bits
   uint32         *_buffer;
   uint64         _numBlocks;
   NSMutableArray *_messageBlocks;

   
}

+(MD4*) initMD4;
//+(MD4*) initMD4:(id<ORModel>)m;
-(MD4*) initExplicitMD4;
//-(MD4*) initExplicitMD4:(id<ORModel>)m;
-(void) dealloc;

-(ORBool) getMessage:(NSString*) fname;
-(NSMutableArray*) getMD4Digest:(NSString*)fname;
-(void) createMD4Blocks:(uint32*)mask;
//-(void) createMD4Block:(uint32*)data withCount:(uint64)count;
-(void) createMD4Block:(uint32*)data withCount:(uint64)count andMask:(uint32*)messageMask;

-(id<ORBitVar>) f:(id<ORBitVar>)x y:(id<ORBitVar>)y z:(id<ORBitVar>)z;
-(id<ORBitVar>) g:(id<ORBitVar>)x y:(id<ORBitVar>)y z:(id<ORBitVar>)z;
-(id<ORBitVar>) h:(id<ORBitVar>)x y:(id<ORBitVar>)y z:(id<ORBitVar>)z;
-(id<ORBitVar>*) round1:(id<ORBitVar>[])h x:(id<ORBitVar>[]) x;
-(id<ORBitVar>*) round2:(id<ORBitVar>[])h x:(id<ORBitVar>[]) x;
-(id<ORBitVar>*) round3:(id<ORBitVar>[])h x:(id<ORBitVar>[]) x;
-(id<ORBitVar>) shuffle1:(id<ORBitVar>)A b:(id<ORBitVar>)B c:(id<ORBitVar>)C d:(id<ORBitVar>) D index:(int)i shiftBy:(int) s x:(id<ORBitVar>[]) x;
-(id<ORBitVar>) shuffle2:(id<ORBitVar>)A b:(id<ORBitVar>)B c:(id<ORBitVar>)C d:(id<ORBitVar>) D index:(int)i shiftBy:(int) s x:(id<ORBitVar>[]) x;
-(id<ORBitVar>) shuffle3:(id<ORBitVar>)A b:(id<ORBitVar>)B c:(id<ORBitVar>)C d:(id<ORBitVar>) D index:(int)i shiftBy:(int) s x:(id<ORBitVar>[]) x;
-(NSString*) preimage:(NSString*) filename withMask:(uint32*)mask andHeuristic:(BVSearchHeuristic)heur;
-(id<ORBitVar>*) stateModel;


//-(void) dealloc;

@end

@interface MD4Block : NSObject
{
   @private
   id<ORModel>    _m;
   uint32         _data[16];
   id<ORBitVar>   *_bitVars;
}
+(MD4Block*) initMD4Block:(id<ORModel>)m;
-(MD4Block*) initExplicitMD4Block:(id<ORModel>)m;

-(void) setData:(ORUInt*)data;
-(void) setData:(ORUInt*)data withMask:(uint32*)mask;
-(ORUInt*) getData;
-(id<ORBitVar>*) getORVars;

@end
