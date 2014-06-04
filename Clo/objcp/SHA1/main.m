//
//  main.m
//  SHA1
//
//  Created by Greg Johnson on 4/17/13.
//
//

#import <Foundation/Foundation.h>
#import "SHA1.h"

void twoByteSHA1(NSString* filename, BVSearchHeuristic heur)
{
   NSAutoreleasePool* pool; // = [[NSAutoreleasePool alloc] init];
   NSMutableString* outputFilename = [[NSMutableString alloc] initWithString:@"/Users/gregjohnson/research/code/Comet/sandbox/bv/ObjCP-SHA1Data-"];
   switch (heur) {
      case BVFF:  [outputFilename appendString:@"-FirstFail-2BYTE-"];
         break;
      case BVABS:  [outputFilename appendString:@"-IBS-2BYTE-"];
         break;
      case BVIBS:  [outputFilename appendString:@"-ABS-2BYTE-"];
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
   
   SHA1 *mySHA1;
   
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
         pool = [[NSAutoreleasePool alloc] init];
         mySHA1 = [[SHA1 alloc] initSHA1];
         [str appendFormat:@"%d ",num++];
         [str appendString:[mySHA1 preimage:filename withMask:mask andHeuristic:heur]];
         [mySHA1 dealloc];
         [pool drain];
         twobytemask >>= 8;
      }
      mask[i] = 0xFFFFFFFF;
   }
   [str writeToFile:outputFilename atomically:YES encoding:NSUTF8StringEncoding error:NULL];
   //      [pool drain];
}

int main(int argc, const char* argv[])
{
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
   
   //   twoByteMD5(@"rand0-mssg.txt", BVMIX);
   //   twoByteMD5(@"rand1-mssg.txt", BVMIX);
   //   twoByteMD5(@"rand2-mssg.txt", BVMIX);
   //   twoByteMD5(@"rand3-mssg.txt", BVMIX);
   //   twoByteMD5(@"rand4-mssg.txt", BVMIX);
   //   twoByteMD5(@"rand5-mssg.txt", BVMIX);
   //   twoByteMD5(@"rand6-mssg.txt", BVMIX);
   //   twoByteMD5(@"rand7-mssg.txt", BVMIX);
   
   twoByteSHA1(@"null-mssg.txt", BVLSB);
   
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
