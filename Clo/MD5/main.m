//
//  main.m
//  MD5
//
//  Created by Greg Johnson on 12/17/12.
//  Copyright (c) 2012 CSE. All rights reserved.
//

#import <ORFoundation/ORFoundation.h>
#import <ORFoundation/ORAVLTree.h>
#import <ORModeling/ORModeling.h>
#import <ORProgram/ORProgram.h>
#import <objcp/CPObjectQueue.h>
#import <objcp/CPFactory.h>

#import <objcp/CPConstraint.h>
#import <objcp/CPBitMacros.h>
#import <objcp/CPBitArray.h>
#import <objcp/CPBitArrayDom.h>
#import <objcp/CPBitConstraint.h>
#import "MD4.h"
#import "MD5.h"

void twoByteAllMD4(){
   NSAutoreleasePool* pool;// = [[NSAutoreleasePool alloc] init];
   int num = 0;
   pool = [[NSAutoreleasePool alloc] init];
   
   MD4 *myMD4 = [MD4 initMD4];;
   //MD5 *myMD5 = [MD5 initMD5];
   NSString *filename = @"/Users/gregjohnson/research/code/bvArchive/bv/lorem-mssg.txt";
//      NSString *filename = @"/Users/gregjohnson/research/code/bvArchive/bv/empty.txt";
   
   NSMutableString *str = [NSMutableString stringWithString:@"bit,choices,failures,propagations,search time (s),total time (s)\n"];
   
   uint32 *mask = malloc(16*sizeof(uint32));
   uint32 twobytemask;
   
   for(int i=0;i<16;i++)
      mask[i] = 0xFFFFFFFF;
   
   for(int i=0;i<16;i++){
      twobytemask = 0xFFFF0000;
      for(int j=0;j<4;j++){
         mask[i] = ~twobytemask;
         if ((j==3) && (i<15)) {
            mask[i+1] = 0x00FFFFFF;
         }
         myMD4 = [MD4 initMD4];
         [str appendFormat:@"%d ",num++];
         [str appendString:[myMD4 preimage:filename withMask:mask]];
         [myMD4 dealloc];
         twobytemask >>= 8;
      }
      mask[i] = 0xFFFFFFFF;
   }
   [str writeToFile:@"/Users/gregjohnson/research/code/Comet/sandbox/bv/ObjCP-MD4DataABS-twobyte-norestart-allvar-lsb.csv" atomically:YES encoding:NSUTF8StringEncoding error:NULL];
   
   [pool drain];

}

void twoByteMD5FF(){
   NSAutoreleasePool* pool;// = [[NSAutoreleasePool alloc] init];
   int num = 0;
   pool = [[NSAutoreleasePool alloc] init];
   [ORStreamManager setRandomized];

   //   MD4 *myMD4;
   MD5 *myMD5 = [MD5 initMD5];
   NSString *filename = @"lorem-mssg.txt";
   //   NSString *filename = @"/Users/gregjohnson/research/code/bvArchive/bv/empty.txt";
   
   NSMutableString *str = [NSMutableString stringWithString:@"bit,choices,failures,propagations,search time (s),total time (s)\n"];
   
   uint32 *mask = malloc(16*sizeof(uint32));
      uint32 twobytemask;
   
   for(int i=0;i<16;i++)
      mask[i] = 0xFFFFFFFF;
//   mask[7] = 0xFF0000FF;
      for(int i=0;i<16;i++){
         twobytemask = 0xFFFF0000;
         for(int j=0;j<4;j++){
            mask[i] = ~twobytemask;
            if ((j==3) && (i<15)) {
               mask[i+1] = 0x00FFFFFF;
            }
//   for (int i=0; i<50; i++) {
      myMD5 = [MD5 initMD5];
      [str appendFormat:@"%d ",num++];
      [str appendString:[myMD5 preimage:filename withMask:mask]];
      [myMD5 dealloc];
//   }
            twobytemask >>= 8;
         }
         mask[i] = 0xFFFFFFFF;
      }
   //   mask[0] = 0xFFFFFF00;
   //   myMD5 = [MD5 initMD5];
   //   [str appendString:[myMD5 preimage:filename withMask:mask]];
   //   [myMD5 dealloc];
   [str writeToFile:@"/Users/gregjohnson/research/code/Comet/sandbox/bv/ObjCP-MD5DataFF-twobyte-restart7.csv" atomically:YES encoding:NSUTF8StringEncoding error:NULL];
   
   [pool drain];

}
int main(int argc, const char * argv[])
{
   NSAutoreleasePool* pool;// = [[NSAutoreleasePool alloc] init];
   int num = 0;
   pool = [[NSAutoreleasePool alloc] init];
   [ORStreamManager setRandomized];

//   MD4 *myMD4;
   MD5 *myMD5;// = [MD5 initMD5];
   NSString *filename = @"lorem-mssg.txt";
//   NSString *filename = @"/Users/gregjohnson/research/code/bvArchive/bv/empty.txt";
   
   NSMutableString *str = [NSMutableString stringWithString:@"bit,choices,failures,propagations,search time (s),total time (s)\n"];
   
   uint32 *mask = malloc(16*sizeof(uint32));
   uint32 twobytemask;
   
   for(int i=0;i<16;i++)
      mask[i] = 0xFFFFFFFF;
//   mask[11] = 0xFFFFFF00;
//   mask[12] = 0x00FFFFFF;
   for(int i=0;i<16;i++){
      twobytemask = 0xFFFF0000;
      for(int j=0;j<4;j++){
         mask[i] = ~twobytemask;
         if ((j==3) && (i<15)) {
            mask[i+1] = 0x00FFFFFF;
         }
   
//   for (int i=0; i<50; i++) {
         myMD5 = [MD5 initMD5];
         [str appendFormat:@"%d ",num++];
         [str appendString:[myMD5 preimage:filename withMask:mask]];
         [myMD5 dealloc];
//   }
         twobytemask >>= 8;
      }
      mask[i] = 0xFFFFFFFF;
   }
//   mask[0] = 0xFFFFFF00;
//   myMD5 = [MD5 initMD5];
//   [str appendString:[myMD5 preimage:filename withMask:mask]];
//   [myMD5 dealloc];
   [str writeToFile:@"/Users/gregjohnson/research/code/Comet/sandbox/bv/ObjCP-MD5Data-LMSSG-ABS-twobyte-norestart-unrestricted-midfree.csv" atomically:YES encoding:NSUTF8StringEncoding error:NULL];

   [pool drain];
   return 0;
}

