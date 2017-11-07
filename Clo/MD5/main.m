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
#import "../SHA1/SHA1/SHA1b.h"

void oneByteMD4(NSString* filename, BVSearchHeuristic heur)
{
//   NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
   NSMutableString* outputFilename = [[NSMutableString alloc] initWithString:@"ObjCP-MD4Data"];
   switch (heur) {
      case BVFF:  [outputFilename appendString:@"-FirstFail-2BYTE-"];
         break;
      case BVABS:  [outputFilename appendString:@"-ABS-2BYTE-"];
         break;
      case BVIBS:  [outputFilename appendString:@"-IBS-2BYTE-"];
         break;
      case BVLSB:  [outputFilename appendString:@"-LSB-2BYTE-"];
         break;
      case BVMSB:  [outputFilename appendString:@"-MSB-2BYTE-"];
         break;
      case BVMID:  [outputFilename appendString:@"-MID-OUT-2BYTE-"];
         break;
      case BVRAND:  [outputFilename appendString:@"-RAND-2BYTE-"];
         break;
      case BVMIX:  [outputFilename appendString:@"-MIXED-2BYTE-"];
         break;
      default:
         break;
   }
   
   [outputFilename appendString:filename];
   int num = 0;
   //      pool = [[NSAutoreleasePool alloc] init];
   [ORStreamManager setRandomized];
   
   MD4 *myMD4;
   
   NSMutableString *str = [NSMutableString stringWithString:@"bit,choices,failures,propagations,search time (s),total time (s)\n"];
   
   uint32 *mask = malloc(16*sizeof(uint32));
   uint32 onebytemask;
   
   for(int i=0;i<16;i++)
      mask[i] = 0xFFFFFFFF;
   for(int i=0;i<16;i++){
      onebytemask = 0xFF000000;
      for(int j=0;j<4;j++){
         mask[i] = ~onebytemask;
//         if ((j==7) && (i<15)) {
//            mask[i+1] = 0x0FFFFFFF;
//         }
         //         pool = [[NSAutoreleasePool alloc] init];
         myMD4 = [MD4 initMD4];
         [str appendFormat:@"%d ",num++];
         [str appendString:[myMD4 preimage:filename withMask:mask andHeuristic:heur]];
         [myMD4 release];
         //         [pool drain];
         onebytemask >>= 8;
      }
      mask[i] = 0xFFFFFFFF;
   }
   [str writeToFile:outputFilename atomically:YES encoding:NSUTF8StringEncoding error:NULL];
//   [pool drain];
}

void twoByteMD4(NSString* filename, BVSearchHeuristic heur)
{
   NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
   NSMutableString* outputFilename = [[NSMutableString alloc] initWithString:@"ObjCP-MD4Data"];
   switch (heur) {
      case BVFF:  [outputFilename appendString:@"-FirstFail-2BYTE-"];
         break;
      case BVABS:  [outputFilename appendString:@"-ABS-2BYTE-"];
         break;
      case BVIBS:  [outputFilename appendString:@"-IBS-2BYTE-"];
         break;
      case BVLSB:  [outputFilename appendString:@"-LSB-2BYTE-"];
         break;
      case BVMSB:  [outputFilename appendString:@"-MSB-2BYTE-"];
         break;
      case BVMID:  [outputFilename appendString:@"-MID-OUT-2BYTE-"];
         break;
      case BVRAND:  [outputFilename appendString:@"-RAND-2BYTE-"];
         break;
      case BVMIX:  [outputFilename appendString:@"-MIXED-2BYTE-"];
         break;
      default:
         break;
   }
   
   [outputFilename appendString:filename];
   int num = 0;
   //      pool = [[NSAutoreleasePool alloc] init];
   [ORStreamManager setRandomized];
   
   MD4 *myMD4;
   
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
//         pool = [[NSAutoreleasePool alloc] init];
         myMD4 = [MD4 initMD4];
         [str appendFormat:@"%d ",num++];
         [str appendString:[myMD4 preimage:filename withMask:mask andHeuristic:heur]];
         [myMD4 release];
//         [pool drain];
         twobytemask >>= 8;
      }
      mask[i] = 0xFFFFFFFF;
   }
   [str writeToFile:outputFilename atomically:YES encoding:NSUTF8StringEncoding error:NULL];
   [pool drain];
}

void twoByteMD5(NSString* filename, BVSearchHeuristic heur)
   {
      NSAutoreleasePool* pool; // = [[NSAutoreleasePool alloc] init];
      NSMutableString* outputFilename = [[NSMutableString alloc] initWithString:@"ObjCP-MD5Data"];
      switch (heur) {
         case BVFF:  [outputFilename appendString:@"-FirstFail-2BYTE-"];
                     break;
         case BVABS:  [outputFilename appendString:@"-ABS-2BYTE-"];
                     break;
         case BVIBS:  [outputFilename appendString:@"-IBS-2BYTE-"];
            break;
         case BVLSB:  [outputFilename appendString:@"-LSB-2BYTE-"];
                     break;
         case BVMSB:  [outputFilename appendString:@"-MSB-2BYTE-"];
                     break;
         case BVMID:  [outputFilename appendString:@"-MID-OUT-2BYTE-"];
                     break;
         case BVRAND: [outputFilename appendString:@"-RAND-2BYTE-"];
                     break;
         case BVMIX:  [outputFilename appendString:@"-MIXED-2BYTE-"];
                     break;
         default:
            break;
      }

      [outputFilename appendString:filename];
      int num = 0;
//      pool = [[NSAutoreleasePool alloc] init];
      [ORStreamManager setRandomized];
      
      MD5 *myMD5;
      
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
//            pool = [[NSAutoreleasePool alloc] init];
            myMD5 = [MD5 initMD5];
            [str appendFormat:@"%d ",num++];
            [str appendString:[myMD5 preimage:filename withMask:mask andHeuristic:heur]];
            [myMD5 dealloc];
//            [pool drain];
            twobytemask >>= 8;
         }
         mask[i] = 0xFFFFFFFF;
      }
      [str writeToFile:outputFilename atomically:YES encoding:NSUTF8StringEncoding error:NULL];
//      [pool drain];
   }
void twoByteSHA1(NSString* filename, BVSearchHeuristic heur)
{
   NSAutoreleasePool* pool; // = [[NSAutoreleasePool alloc] init];
   NSMutableString* outputFilename = [[NSMutableString alloc] initWithString:@"ObjCP-SHA1Data"];
   switch (heur) {
      case BVFF:  [outputFilename appendString:@"-FirstFail-2BYTE-"];
         break;
      case BVABS:  [outputFilename appendString:@"-ABS-2BYTE-"];
         break;
      case BVIBS:  [outputFilename appendString:@"-IBS-2BYTE-FULLSEARCH-"];
         break;
      case BVLSB:  [outputFilename appendString:@"-LSB-2BYTE-"];
         break;
      case BVMSB:  [outputFilename appendString:@"-MSB-2BYTE-"];
         break;
      case BVMID:  [outputFilename appendString:@"-MID-OUT-2BYTE-"];
         break;
      case BVRAND:  [outputFilename appendString:@"-RAND-2BYTE-"];
         break;
      case BVMIX:  [outputFilename appendString:@"-MIXED-2BYTE-"];
         break;
      default:
         break;
   }
   
   [outputFilename appendString:filename];
   int num = 0;
   //      pool = [[NSAutoreleasePool alloc] init];
   [ORStreamManager setRandomized];
   
   SHA1b *mySHA1;
   
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
//         pool = [[NSAutoreleasePool alloc] init];
         mySHA1 = [SHA1b initSHA1b];
         [str appendFormat:@"%d ",num++];
         [str appendString:[mySHA1 preimage:filename withMask:mask andHeuristic:heur]];
         [mySHA1 dealloc];
//         [pool drain];
         twobytemask >>= 8;
      }
      mask[i] = 0xFFFFFFFF;
   }
   [str writeToFile:outputFilename atomically:YES encoding:NSUTF8StringEncoding error:NULL];
   [pool drain];
}
void zeroByteSHA1(NSString* filename, BVSearchHeuristic heur)
{
   NSAutoreleasePool* pool; // = [[NSAutoreleasePool alloc] init];
   NSMutableString* outputFilename = [[NSMutableString alloc] initWithString:@"ObjCP-SHA1Data"];
   switch (heur) {
      case BVFF:  [outputFilename appendString:@"-FirstFail-0BYTE-"];
         break;
      case BVABS:  [outputFilename appendString:@"-ABS-0BYTE-"];
         break;
      case BVIBS:  [outputFilename appendString:@"-IBS-0BYTE-"];
         break;
      case BVLSB:  [outputFilename appendString:@"-LSB-0BYTE-"];
         break;
      case BVMSB:  [outputFilename appendString:@"-MSB-0BYTE-"];
         break;
      case BVMID:  [outputFilename appendString:@"-MID-OUT-0BYTE-"];
         break;
      case BVRAND:  [outputFilename appendString:@"-RAND-0BYTE-"];
         break;
      case BVMIX:  [outputFilename appendString:@"-MIXED-0BYTE-"];
         break;
      default:
         break;
   }
   
   [outputFilename appendString:filename];
   int num = 0;
//         pool = [[NSAutoreleasePool alloc] init];
   [ORStreamManager setRandomized];
   
   SHA1b *mySHA1;
   
   NSMutableString *str = [NSMutableString stringWithString:@"bit,choices,failures,propagations,search time (s),total time (s)\n"];
   
   uint32 *mask = malloc(16*sizeof(uint32));
   
   for(int i=0;i<16;i++)
      mask[i] = 0xFFFFFFFF;
         pool = [[NSAutoreleasePool alloc] init];
         mySHA1 = [SHA1b initSHA1b];
         [str appendFormat:@"%d ",num++];
         [str appendString:[mySHA1 preimage:filename withMask:mask andHeuristic:heur]];
         [mySHA1 dealloc];
//         [pool drain];
   [str writeToFile:outputFilename atomically:YES encoding:NSUTF8StringEncoding error:NULL];
//   [pool drain];
}

int main(int argc, const char* argv[])
{
   
//   [ORStreamManager setRandomized];

   
   
   
//   char A[128];
//
//   for(int i=0;i<128;i++)
//      A[i] = arc4random_uniform(255);
//
////   NSMutableString *AString = [[NSMutableString alloc] initWithBytes:A length:5 encoding:NSASCIIStringEncoding];
////   [AString writeToFile:@"/Users/gregjohnson/research/code/Comet/sandbox/bv/F-mssg.txt" atomically:YES encoding:NSASCIIStringEncoding error:NULL];
//
//   NSFileHandle *file;
//   NSMutableData *data;
//   
//   data = [NSMutableData dataWithBytes:A length:55];
//   file = [NSFileHandle fileHandleForWritingAtPath:@"/Users/gregjohnson/research/code/Comet/sandbox/bv/rand7-mssg.txt"];
//   
//   if (file == nil)
//      NSLog(@"Failed to open file");
//   [file writeData: data];
//   [file closeFile];
   
//   twoByteMD4(@"rand0-mssg.txt", BVFF);
//   twoByteMD4(@"rand0-mssg.txt", BVABS);
//   twoByteMD5(@"rand0-mssg.txt", BVFF);
//   twoByteMD5(@"rand0-mssg.txt", BVABS);
//
//   twoByteMD4(@"rand1-mssg.txt", BVFF);
//   twoByteMD4(@"rand1-mssg.txt", BVABS);
//   twoByteMD5(@"rand1-mssg.txt", BVFF);
//   twoByteMD5(@"rand1-mssg.txt", BVABS);
//   
//   twoByteMD4(@"rand2-mssg.txt", BVFF);
//   twoByteMD4(@"rand2-mssg.txt", BVABS);
//   twoByteMD5(@"rand2-mssg.txt", BVFF);
//   twoByteMD5(@"rand2-mssg.txt", BVABS);
//   
//   twoByteMD4(@"rand3-mssg.txt", BVFF);
//   twoByteMD4(@"rand3-mssg.txt", BVABS);
//   twoByteMD5(@"rand3-mssg.txt", BVFF);
//   twoByteMD5(@"rand3-mssg.txt", BVABS);
//   
//   twoByteMD4(@"rand4-mssg.txt", BVFF);
//   twoByteMD4(@"rand4-mssg.txt", BVABS);
//   twoByteMD5(@"rand4-mssg.txt", BVFF);
//   twoByteMD5(@"rand4-mssg.txt", BVABS);
//   
//   twoByteMD4(@"rand5-mssg.txt", BVFF);
//   twoByteMD4(@"rand5-mssg.txt", BVABS);
//   twoByteMD5(@"rand5-mssg.txt", BVFF);
//   twoByteMD5(@"rand5-mssg.txt", BVABS);
//   
//   twoByteMD4(@"rand6-mssg.txt", BVFF);
//   twoByteMD4(@"rand6-mssg.txt", BVABS);
//   twoByteMD5(@"rand6-mssg.txt", BVFF);
//   twoByteMD5(@"rand6-mssg.txt", BVABS);
//   
//   twoByteMD4(@"rand7-mssg.txt", BVFF);
//   twoByteMD4(@"rand7-mssg.txt", BVABS);
//   twoByteMD5(@"rand7-mssg.txt", BVFF);
//   twoByteMD5(@"rand7-mssg.txt", BVABS);

//   twoByteMD4(@"rand0-mssg.txt", BVRAND);
//   twoByteMD4(@"rand1-mssg.txt", BVRAND);
//   twoByteMD4(@"rand2-mssg.txt", BVRAND);
//   twoByteMD4(@"rand3-mssg.txt", BVRAND);
//   twoByteMD4(@"rand4-mssg.txt", BVRAND);
//   twoByteMD4(@"rand5-mssg.txt", BVRAND);
//   twoByteMD4(@"rand6-mssg.txt", BVRAND);
//   twoByteMD4(@"rand7-mssg.txt", BVRAND);
   
//   twoByteMD4(@"U-mssg.txt", BVABS);
//   twoByteMD5(@"U-mssg.txt", BVABS);
//   twoByteSHA1(@"U-mssg.txt", BVABS);
//   twoByteMD4(@"3-mssg.txt", BVABS);
//   twoByteMD5(@"3-mssg.txt", BVABS);
//   twoByteSHA1(@"3-mssg.txt", BVABS);

//twoByteMD4(@"U-mssg.txt", BVABS);
//twoByteMD5(@"rand0-mssg.txt", BVFF);
//twoByteSHA1(@"rand0-mssg.txt", BVFF);
//twoByteMD4(@"rand0-mssg.txt", BVFF);
//twoByteMD5(@"3-mssg.txt", BVFF);
//twoByteSHA1(@"3-mssg.txt", BVFF);

   
//   twoByteMD4(@"rand0-mssg.txt", BVIBS);
//   twoByteMD4(@"rand1-mssg.txt", BVIBS);
//   twoByteMD4(@"rand2-mssg.txt", BVIBS);
//   twoByteMD4(@"rand3-mssg.txt", BVIBS);
//   twoByteMD4(@"rand4-mssg.txt", BVIBS);
//   twoByteMD4(@"rand5-mssg.txt", BVIBS);
//   twoByteMD4(@"rand6-mssg.txt", BVIBS);
//   twoByteMD4(@"rand7-mssg.txt", BVIBS);
//
//   twoByteMD5(@"rand0-mssg.txt", BVIBS);
//   twoByteMD5(@"rand1-mssg.txt", BVIBS);
//   twoByteMD5(@"rand2-mssg.txt", BVIBS);
//   twoByteMD5(@"rand3-mssg.txt", BVIBS);
//   twoByteMD5(@"rand4-mssg.txt", BVIBS);
//   twoByteMD5(@"rand5-mssg.txt", BVIBS);
//   twoByteMD5(@"rand6-mssg.txt", BVIBS);
//   twoByteMD5(@"rand7-mssg.txt", BVIBS);
//   
//   twoByteSHA1(@"rand0-mssg.txt", BVIBS);
//   twoByteSHA1(@"rand1-mssg.txt", BVIBS);
//   twoByteSHA1(@"rand2-mssg.txt", BVIBS);
//   twoByteSHA1(@"rand3-mssg.txt", BVIBS);
//   twoByteSHA1(@"rand4-mssg.txt", BVIBS);
//   twoByteSHA1(@"rand5-mssg.txt", BVIBS);
//   twoByteSHA1(@"rand6-mssg.txt", BVIBS);
//   twoByteSHA1(@"rand7-mssg.txt", BVIBS);
   

   
   
//   twoByteSHA1(@"rand0-mssg.txt", BVABS);
//   twoByteSHA1(@"rand1-mssg.txt", BVABS);
//   twoByteSHA1(@"rand2-mssg.txt", BVABS);
//   twoByteSHA1(@"rand3-mssg.txt", BVABS);
//   twoByteSHA1(@"rand4-mssg.txt", BVABS);
//   twoByteSHA1(@"rand5-mssg.txt", BVABS);
//   twoByteSHA1(@"rand6-mssg.txt", BVABS);
//   twoByteSHA1(@"rand7-mssg.txt", BVABS);
//   
//   twoByteMD4(@"rand0-mssg.txt", BVABS);
//   twoByteMD4(@"rand1-mssg.txt", BVABS);
//   twoByteMD4(@"rand2-mssg.txt", BVABS);
//   twoByteMD4(@"rand3-mssg.txt", BVABS);
//   twoByteMD4(@"rand4-mssg.txt", BVABS);
//   twoByteMD4(@"rand5-mssg.txt", BVABS);
//   twoByteMD4(@"rand6-mssg.txt", BVABS);
//   twoByteMD4(@"rand7-mssg.txt", BVABS);
//
//   twoByteMD5(@"rand0-mssg.txt", BVIBS);
//   twoByteMD5(@"rand0-mssg.txt", BVABS);
//   twoByteMD5(@"rand0-mssg.txt", BVFF);
//   twoByteMD5(@"rand1-mssg.txt", BVFF);
//   twoByteMD5(@"rand2-mssg.txt", BVFF);
//   twoByteMD5(@"rand3-mssg.txt", BVFF);
//   twoByteMD5(@"rand4-mssg.txt", BVFF);
//   twoByteMD5(@"rand5-mssg.txt", BVFF);
//   twoByteMD5(@"rand6-mssg.txt", BVFF);
//   twoByteMD5(@"rand7-mssg.txt", BVFF);

//   twoByteMD4(@"fifteen.txt", BVABS);
//   twoByteMD4(@"fifteen.txt", BVIBS);
//   twoByteMD5(@"fifteen.txt", BVABS);
//   twoByteMD5(@"fifteen.txt", BVIBS);
//   twoByteSHA1(@"fifteen.txt", BVABS);
//   twoByteSHA1(@"fifteen.txt", BVIBS);

//   twoByteMD4(@"lorem-mssg.txt", BVFF);
   
   twoByteMD5(@"lorem-mssg.txt", BVFF);
   
//   twoByteSHA1(@"lorem-mssg.txt", BVFF);
//   twoByteSHA1(@"lorem-mssg.txt", BVABS);
//   twoByteSHA1(@"lorem-mssg.txt", BVIBS);


//   twoByteSHA1(@"null-mssg.txt", BVLSB);
//   twoByteSHA1(@"lorem-mssg.txt", BVFF);


}
//int main(int argc, const char * argv[])
//{
//   NSAutoreleasePool* pool;// = [[NSAutoreleasePool alloc] init];
//   int num = 0;
//   pool = [[NSAutoreleasePool alloc] init];
//   [ORStreamManager setRandomized];
//
////   MD4 *myMD4;
//   MD5 *myMD5;// = [MD5 initMD5];
//   NSString *filename = @"lorem-mssg.txt";
////   NSString *filename = @"/Users/gregjohnson/research/code/bvArchive/bv/empty.txt";
//   
//   NSMutableString *str = [NSMutableString stringWithString:@"bit,choices,failures,propagations,search time (s),total time (s)\n"];
//   
//   uint32 *mask = malloc(16*sizeof(uint32));
//   uint32 twobytemask;
//   
//   for(int i=0;i<16;i++)
//      mask[i] = 0xFFFFFFFF;
////   mask[11] = 0xFFFFFF00;
////   mask[12] = 0x00FFFFFF;
//   for(int i=0;i<16;i++){
//      twobytemask = 0xFFFF0000;
//      for(int j=0;j<4;j++){
//         mask[i] = ~twobytemask;
//         if ((j==3) && (i<15)) {
//            mask[i+1] = 0x00FFFFFF;
//         }
//   
////   for (int i=0; i<50; i++) {
//         myMD5 = [MD5 initMD5];
//         [str appendFormat:@"%d ",num++];
//         [str appendString:[myMD5 preimage:filename withMask:mask]];
//         [myMD5 dealloc];
////   }
//         twobytemask >>= 8;
//      }
//      mask[i] = 0xFFFFFFFF;
//   }
////   mask[0] = 0xFFFFFF00;
////   myMD5 = [MD5 initMD5];
////   [str appendString:[myMD5 preimage:filename withMask:mask]];
////   [myMD5 dealloc];
//   [str writeToFile:@"/Users/gregjohnson/research/code/Comet/sandbox/bv/ObjCP-MD5Data-LMSSG-ABS-twobyte-norestart-unrestricted-midfree.csv" atomically:YES encoding:NSUTF8StringEncoding error:NULL];
//
//   [pool drain];
//   return 0;
//}

