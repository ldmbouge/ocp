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

int main(int argc, const char * argv[])
{
   NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];

   MD4 *myMD4 = [MD4 initMD4];
   NSString *filename = @"/Users/gregjohnson/research/code/bvArchive/bv/lorem-mssg.txt";
//   NSString *filename = @"/Users/gregjohnson/research/code/bvArchive/bv/empty.txt";
   
   uint32 *mask = malloc(16*sizeof(uint32));

   for(int i=0;i<16;i++)
      mask[i] = 0xFFFFFFFF;
   mask[7] = 0x0000FFFF;
   [myMD4 preimage:filename withMask:mask];
   
   [pool drain];
   return 0;
}

