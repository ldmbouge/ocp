/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

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

int main(int argc, const char * argv[])
{
   NSAutoreleasePool* pool;// = [[NSAutoreleasePool alloc] init];

   pool = [[NSAutoreleasePool alloc] init];

//   MD4 *myMD4;
   MD5 *myMD5 = [MD5 initMD5];
   NSString *filename = @"lorem-mssg.txt";
//   NSString *filename = @"/Users/gregjohnson/research/code/bvArchive/bv/empty.txt";
   
   NSMutableString *str = [NSMutableString stringWithString:@"bit,choices,failures,propagations,search time (s),total time (s)\n"];
   
   uint32 *mask = malloc(16*sizeof(uint32));
   uint32 twobytemask;
   
   for(int i=0;i<16;i++)
      mask[i] = 0xFFFFFFFF;
   
   for(int i=0;i<16;i++){
      twobytemask = 0xFFFF0000;
      for(int j=0;j<4;j++){
//         pool = [[NSAutoreleasePool alloc] init];
         mask[i] = ~twobytemask;
         if ((j==3) && (i<15)) {
            mask[i+1] = 0x00FFFFFF;
         }
         myMD5 = [MD5 initMD5];
         [str appendString:[myMD5 preimage:filename withMask:mask]];
         [myMD5 dealloc];
         twobytemask >>= 8;
//         [pool drain];
      }
      mask[i] = 0xFFFFFFFF;
   }
//   mask[0] = 0xFFFFFF00;
//   myMD5 = [MD5 initMD5];
//   [str appendString:[myMD5 preimage:filename withMask:mask]];
//   [myMD5 dealloc];
   [str writeToFile:@"/Users/gregjohnson/research/code/Comet/sandbox/bv/ObjCP-MD5DataFirstFail.csv" atomically:YES encoding:NSUTF8StringEncoding error:NULL];

   [pool drain];
   return 0;
}

