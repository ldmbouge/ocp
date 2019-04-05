//
//  SHA1.m
//  Clo
//
//  Created by Greg Johnson on 12/18/12.
//  Copyright (c) 2012 CSE. All rights reserved.
//

#import "SHA1.h"

@implementation SHA1
+(SHA1*) initSHA1{
   SHA1* x = [[SHA1 alloc]initExplicitSHA1];
   return x;
}


-(SHA1*) initExplicitSHA1
{
   self = [super init];
   _m = [ORFactory createModel];
   
   return self;
}

-(bool) getMessage:(NSString *)fname
{
   NSFileManager *fm;
   NSData *message;
   
   fm = [NSFileManager defaultManager];
   
   if( [fm fileExistsAtPath: fname] == NO){
      NSLog(@"File \"%@\" not found.\n",fname);
      return false;
   }
   message = [fm contentsAtPath:fname];
   _messageLength = [message length]*8;
   _buffer = malloc(((([message length]/4)+1)*4) *sizeof(uint)); //ensure buffer is on 32bit boundary
   [message getBytes:_buffer length:[message length]];
   NSLog(@"%s\n",(char*)_buffer);
   [fm dealloc];
   return true;
}

-(NSMutableArray*) getSHA1Digest:(NSString*)fname //retrieves SHA1 digest from system call to openssl
{
   NSTask *task = [[NSTask alloc] init];
   NSString *command = @"/usr/bin/openssl";
   NSString *param = [[NSMutableString alloc] initWithString:@"dgst"];
   NSMutableArray *params = [NSMutableArray arrayWithObject:param];
   param = @"-sha1";
   [params addObject:param];
   [params addObject:fname];
   [task setArguments:params];
   [task setLaunchPath:command];
   
   NSPipe *pipe = [NSPipe pipe];
   [task setStandardOutput:pipe];
   [task launch];
   NSData *data = [[pipe fileHandleForReading] readDataToEndOfFile];
   [task waitUntilExit];
   [task release];
   NSString *result = [[[NSString alloc] initWithData:data
                                             encoding:NSUTF8StringEncoding] autorelease];
   NSRange range = [result rangeOfString:@"=" options:NSBackwardsSearch];
   //   NSLog(@"The returned value is: %@", result);
   //   NSLog(@"%ld",range.location);
   range.location += 2;
   range.length = result.length - range.location;
   result = [result substringWithRange:range];
   //   NSLog(@"The returned value is: %@", result);
   NSMutableArray *digest = [[NSMutableArray alloc] initWithCapacity:5];
   NSScanner *scanner;
   unsigned int digestValue;
   for(int i=0; i<SHA1_DIGEST_LENGTH; i++){
      range.location = i * DIGEST_VAR_LENGTH;
      range.length = DIGEST_VAR_LENGTH;
      scanner = [NSScanner scannerWithString:[result substringWithRange:range]];
      [scanner scanHexInt:&digestValue];
      [digest addObject:[NSNumber numberWithUnsignedInt:digestValue]];
   }
   NSLog(@"%@\n",digest);
   _digest = digest;
   return digest;
}


-(void) createSHA1Blocks:(uint32*)mask
{
   uint64 blockLength;
   _numBlocks = floor((_messageLength+64)/512)+1;
   _messageBlocks = [[NSMutableArray alloc] initWithCapacity:_numBlocks];
   NSLog(@"%lld blocks\n",_numBlocks);
   for(int i=0;i<_numBlocks;i++)
   {
      blockLength = MIN(512, _messageLength - (i * 512));
      [self createSHA1Block:&(_buffer[i*16]) withCount:blockLength andMask:mask];
   }
}

-(void) createSHA1Block:(ORUInt*)data withCount:(uint64)count andMask:(uint32*)messageMask{
   uint64 numBits, numBytes;
   uint32 mask;
   ORUInt      paddedData[16];
   SHA1Block* newBlock;
   
   if (count == 512) { //first or intermediate message block
      newBlock = [[SHA1Block alloc] initExplicitSHA1Block:_m];
      for(int i=0;i<16;i++)
         paddedData[i] = data[i];
      [newBlock setData:paddedData withMask:messageMask];
      [_messageBlocks addObject:newBlock];
   }
   else /* partial block -- must be last block so finish up */
   { /* Find out how many bytes and residual bits there are */
      numBytes = (unsigned int)count >> 3;
      numBits =  count & 7;
      unsigned char *X = (unsigned char*)data;
      unsigned char *XX = (unsigned char*)paddedData;
      /* Copy X into XX since we need to modify it */
      for (int i=0;i<=numBytes;i++)   XX[i] = X[i];
      for (uint64 i=numBytes+1;i<64;i++) XX[i] = 0;
      /* Add padding '1' bit and low-order zeros in last byte */
      mask = 1 << (7 - numBits);
      XX[numBytes] = (XX[numBytes] | mask) & ~( mask - 1);
      /* If room for bit count, finish up with this block */
      if (numBytes <= 55)
      {
         for (int i=0;i<8;i++) XX[56+i] = ((unsigned char*)(&_messageLength))[i];
         XX[56] = _messageLength;
         newBlock = [[SHA1Block alloc] initExplicitSHA1Block:_m];
         //         NSLog(@"Padded Data: %s",(char*)XX);
         //         NSLog(@"Padded Data: ");
         //         for(int i = 0; i<64;i++) NSLog(@"%02x",((unsigned char*)XX)[i]);
         [newBlock setData:(uint32*)XX withMask:messageMask];
         [_messageBlocks addObject:newBlock];
      }
      else /* need to do two blocks to finish up */
      { newBlock = [[SHA1Block alloc] initExplicitSHA1Block:_m];
         for (int i=0;i<56;i++) XX[i] = 0;
         for (int i=0;i<8;i++) XX[56+i] = ((unsigned char*)(&_messageLength))[i];
         //         NSLog(@"Padded Data: %s",(char*)XX);
         [newBlock setData:(uint32*)XX withMask:messageMask];
         [_messageBlocks addObject:newBlock];
      }
   }
   
}

-(NSString*) preimage:(NSString*)filename withMask:(uint32*) mask andHeuristic:(BVSearchHeuristic)heur
{
   clock_t start;
   NSMutableString *results = [NSMutableString stringWithString:@""];
   
   id<ORBitVar>* digest;
   id<ORBitVar>* digestVars = malloc(5*sizeof(id<ORBitVar>));
   
   start = clock();
   
   [self getMessage:filename];
   [self getSHA1Digest:filename];
   //get SHA1 Blocks
   _temps = [[NSMutableArray alloc] initWithCapacity:128];
   [self createSHA1Blocks:mask];
   digest = [self stateModel];
   uint32 *value = malloc(sizeof(uint32));
   *value = __builtin_bswap32([[_digest objectAtIndex:0] unsignedIntValue]);
   //   *value = [[_digest objectAtIndex:0] unsignedIntValue];
   digestVars[0] = [ORFactory bitVar:_m low:value up:value bitLength:32];
   value = malloc(sizeof(uint32));
   *value = __builtin_bswap32([[_digest objectAtIndex:1] unsignedIntValue]);
   //   *value = [[_digest objectAtIndex:1] unsignedIntValue];
   digestVars[1] = [ORFactory bitVar:_m low:value up:value bitLength:32];
   value = malloc(sizeof(uint32));
   *value = __builtin_bswap32([[_digest objectAtIndex:2] unsignedIntValue]);
   //   *value = [[_digest objectAtIndex:2] unsignedIntValue];
   digestVars[2] = [ORFactory bitVar:_m low:value up:value bitLength:32];
   value = malloc(sizeof(uint32));
   *value = __builtin_bswap32([[_digest objectAtIndex:3] unsignedIntValue]);
   //   *value = [[_digest objectAtIndex:3] unsignedIntValue];
   digestVars[3] = [ORFactory bitVar:_m low:value up:value bitLength:32];
   value = malloc(sizeof(uint32));
   *value = __builtin_bswap32([[_digest objectAtIndex:4] unsignedIntValue]);
   //   *value = [[_digest objectAtIndex:4] unsignedIntValue];
   digestVars[4] = [ORFactory bitVar:_m low:value up:value bitLength:32];
   
//   [_m add:[ORFactory bit:digest[0] eq:digestVars[0]]];
//   [_m add:[ORFactory bit:digest[1] eq:digestVars[1]]];
//   [_m add:[ORFactory bit:digest[2] eq:digestVars[2]]];
//   [_m add:[ORFactory bit:digest[3] eq:digestVars[3]]];
//   [_m add:[ORFactory bit:digest[4] eq:digestVars[4]]];
   
   
   id<CPProgram,CPBV> cp = (id)[ORFactory createCPProgram: _m];
   id<CPEngine> engine = [cp engine];
   id<ORExplorer> explorer = [cp explorer];
   id<ORBasicModel> model = [engine model];
   //<<<<<<< HEAD
   //CPBitVarFF
   __block id* gamma = [cp gamma];
   
   NSLog(@"SHA-1 Message Blocks (Original)");
   id<ORBitVar>* bitVars;
   for(int i=0; i<_numBlocks;i++){
      bitVars = [[_messageBlocks objectAtIndex:i] getORVars];
      for(int j=0;j<16;j++)
         NSLog(@"%@\n",gamma[bitVars[j].getId]);
   }
   
   id<ORIdArray> o = [ORFactory idArray:[cp engine] range:[[ORIntRangeI alloc] initORIntRangeI:0 up:32]];
   for(ORInt k=0;k <= 32;k++)
      [o set:gamma[bitVars[k].getId] at:k];
   
   NSArray* allvars = [model variables];

   
   id<CPBitVarHeuristic> h;
   switch (heur) {
      case BVABS: h = [cp createBitVarABS:(id<CPBitVarArray>)o];
         break;
      case BVFF:
      default:  h =[cp createBitVarFF:(id<CPBitVarArray>)o];
         break;
         //      default:
         //         break;
   }
   //      __block ORUInt maxFail = 0x0000000000004000;
   
   [cp solve: ^{
      NSLog(@"All variables before search:");
      for (int i=0; i< [allvars count]; i++) {
         NSLog(@"Model Variable[%i]: %@",i,allvars[i]);
      }
      NSLog(@"End all variables before search:");
      NSLog(@"Search");
      for(int i=0;i<5;i++)
      {
         NSLog(@"%@",gamma[digest[i].getId]);
         NSLog(@"%@\n\n",gamma[digestVars[i].getId]);
      }
      NSLog(@"Message Blocks (With Data Recovered)");
      __block ORUInt maxFail = 0x0000000000004000;
      clock_t searchStart = clock();
      //      [cp repeat:^{
      //         [cp limitFailures:maxFail
      //                        in:^{[cp labelBitVarHeuristic:h];}];}
      //        onRepeat:^{maxFail<<=1;NSLog(@"Restart");}];
      switch (heur) {
         case BVLSB:
            for (int i=0;i<16;i++)
               if (![gamma [bitVars[i].getId] bound]) {
                  [cp labelUpFromLSB:gamma[bitVars[i].getId]];
               }
            break;
         case BVRAND:
            for (int i=0;i<16;i++)
               if (![gamma [bitVars[i].getId] bound]) {
                  [cp labelRandomFreeBit:gamma[bitVars[i].getId]];
               }
            break;
         case BVMID:
            for (int i=0;i<16;i++)
               if (![gamma [bitVars[i].getId] bound]) {
                  [cp labelOutFromMidFreeBit:gamma[bitVars[i].getId]];
               }
            break;
         case BVMIX:
            for (int i=0;i<16;i++)
               if (![gamma [bitVars[i].getId] bound]) {
                  [cp labelBitsMixedStrategy:gamma[bitVars[i].getId]];
               }
            break;
            
         default:
      [cp repeat:^{
         [cp limitFailures:maxFail
                        in:^{[cp labelBitVarHeuristic:h];}];}
        onRepeat:^{maxFail<<=1;NSLog(@"Restart");}];
            break;
      }
      //      for (int i=0;i<16;i++)
      //         if (![gamma [bitVars[i].getId] bound]) {
      //            [cp labelOutFromMidFreeBit:gamma[bitVars[i].getId]];
      //         }
      clock_t searchFinish = clock();
      
      for(int j=0;j<16;j++){
         NSLog(@"%@\n",gamma[bitVars[j].getId]);
      }
      
      
      NSLog(@"All variables:");
      for (int i=0; i< [allvars count]; i++) {
         NSLog(@"Model Variable[%i]: %@",i,allvars[i]);
      }
      NSLog(@"End all variables:");
      NSLog(@"Final digest variables");
      for(int j=0;j<5;j++)
      {
         NSLog(@"%@",gamma[digest[j].getId]);
         NSLog(@"%@\n\n",gamma[digestVars[j].getId]);
      }

      
      double totalTime, searchTime;
      totalTime =((double)(searchFinish - start))/CLOCKS_PER_SEC;
      searchTime = ((double)(searchFinish - searchStart))/CLOCKS_PER_SEC;
      
      NSString *str = [NSString stringWithFormat:@",%d,%d,%d,%f,%f\n",[explorer nbChoices],[explorer nbFailures],[engine nbPropagation],searchTime,totalTime];
      [results appendString:str];
      NSLog(@"Number propagations: %d",[engine nbPropagation]);
      NSLog(@"     Number choices: %d",[explorer nbChoices]);
      NSLog(@"    Number Failures: %d", [explorer nbFailures]);
      NSLog(@"    Search Time (s): %f",searchTime);
      NSLog(@"     Total Time (s): %f\n\n",totalTime);
      
   }];
   [cp release];
   return results;

}

-(id<ORBitVar>) getK:(int)t {
   uint32 kValue;
   id<ORBitVar> k;
   if (t >= 0 && t <= 19) {
      kValue= 0x5A827999;
   } else if (t >= 20 && t <= 39) {
      kValue=0x6ED9EBA1;
   } else if (t >= 40 && t <= 59) {
      kValue=0x8F1BBCDC;
   } else {
      kValue=0xCA62C1D6;
   }
   k = [ORFactory bitVar:_m low:&kValue up:&kValue bitLength:32];
   return k;
}
-(id<ORBitVar>*) stateModel
{
   uint32 *I0 = malloc(sizeof(uint32));
   uint32 *I1 = malloc(sizeof(uint32));
   uint32 *I2 = malloc(sizeof(uint32));
   uint32 *I3 = malloc(sizeof(uint32));
   uint32 *I4 = malloc(sizeof(uint32));
   
//   H0 = 0x67452301
//   H1 = 0xEFCDAB89
//   H2 = 0x98BADCFE
//   H3 = 0x10325476
//   H4 = 0xC3D2E1F0
//
   
   *I0 = 0x67452301;
   *I1 = 0xEFCDAB89;
   *I2 = 0x98BADCFE;
   *I3 = 0x10325476;
   *I4 = 0xC3D2E1F0;
   
//   uint32 *KV0 = malloc(sizeof(uint32));
//   uint32 *KV1 = malloc(sizeof(uint32));
//   uint32 *KV2 = malloc(sizeof(uint32));
//   uint32 *KV3 = malloc(sizeof(uint32));
//   
//   *KV0 = 0x5A827999;
//   *KV1 = 0x6ED9EBA1;
//   *KV2 = 0x8F1BBCDC;
//   *KV3 = 0xCA62C1D6;

   id<ORBitVar> *h0 = malloc(5*sizeof(id<ORBitVar>));
   id<ORBitVar> *h1 = malloc(5*sizeof(id<ORBitVar>));
   id<ORBitVar> *h = malloc(5*sizeof(id<ORBitVar>));
   
   h0[0] = [ORFactory bitVar:_m low:I0 up:I0 bitLength:32];
   h0[1] = [ORFactory bitVar:_m low:I1 up:I1 bitLength:32];
   h0[2] = [ORFactory bitVar:_m low:I2 up:I2 bitLength:32];
   h0[3] = [ORFactory bitVar:_m low:I3 up:I3 bitLength:32];
   h0[4] = [ORFactory bitVar:_m low:I4 up:I4 bitLength:32];

//   _kVars[0] = [ORFactory bitVar:_m low:KV0 up:KV0 bitLength:32];
//   _kVars[1] = [ORFactory bitVar:_m low:KV1 up:KV1 bitLength:32];
//   _kVars[2] = [ORFactory bitVar:_m low:KV2 up:KV2 bitLength:32];
//   _kVars[3] = [ORFactory bitVar:_m low:KV3 up:KV3 bitLength:32];
   
   uint32 min = 0x00000000;
   uint32 max = 0xFFFFFFFF;
   id<ORBitVar> cin;
   id<ORBitVar> cout;

   for(int i=0; i<_numBlocks;i++) {
      
      SHA1Block* b = [_messageBlocks objectAtIndex:i];
      id<ORBitVar> *msg = [b getORVars];
//      h0 = [self roundSHA1:h0 x:msg];
      h1 = [self roundSHA1:h0 x:msg];

      h[0] = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
      h[1] = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
      h[2] = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
      h[3] = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
      h[4] = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   
      for (int i=0; i<5; i++)
      {
         cin = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
         cout = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
         [_m add:[ORFactory bit:h0[i] plus:h1[i] withCarryIn:cin eq:h[i] withCarryOut:cout]];
      }
      h0 = h;
   }

   return h0;
}

-(id<ORBitVar>) f:(id<ORBitVar>)x y:(id<ORBitVar>)y z:(id<ORBitVar>)z
{
   uint32 min = 0x00000000;
   uint32 max = 0xFFFFFFFF;
   
   id<ORBitVar> t0 = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   id<ORBitVar> t1 = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   id<ORBitVar> t2 = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   
   [_m add:[ORFactory bit:x and:y eq:t0]];
   [_m add:[ORFactory bit:x and:z eq:t1]];
   [_m add:[ORFactory bit:t0 xor:t1 eq:t2]];
   
   return t2;
}
-(id<ORBitVar>) g:(id<ORBitVar>)x y:(id<ORBitVar>)y z:(id<ORBitVar>)z
{
   uint32 min = 0x00000000;
   uint32 max = 0xFFFFFFFF;
   
   id<ORBitVar> t0 = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   id<ORBitVar> t1 = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   
   [_m add:[ORFactory bit:x xor:y eq:t0]];
   [_m add:[ORFactory bit:t0 xor:z eq:t1]];
   
   return t1;
}
-(id<ORBitVar>) h:(id<ORBitVar>)x y:(id<ORBitVar>)y z:(id<ORBitVar>)z
{
   //   H(X,Y,Z) = X xor Y xor Z
   uint32 min = 0x00000000;
   uint32 max = 0xFFFFFFFF;
   
   id<ORBitVar> t0 = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   id<ORBitVar> t1 = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   id<ORBitVar> t2 = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   id<ORBitVar> t3 = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   id<ORBitVar> t4 = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   [_m add:[ORFactory bit:x and:y eq:t0]];
   [_m add:[ORFactory bit:x and:z eq:t1]];
   [_m add:[ORFactory bit:y and:z eq:t2]];
   [_m add:[ORFactory bit:t0 xor:t1 eq:t3]];
   [_m add:[ORFactory bit:t3 xor:t2 eq:t4]];
   return t4;
}

-(id<ORBitVar>*) roundSHA1:(id<ORBitVar>*)h x:(id<ORBitVar>*) x
{
   uint32 min = 0x00000000;
   uint32 max = 0xFFFFFFFF;
   
   id<ORBitVar> A = h[0];
   id<ORBitVar> B = h[1];
   id<ORBitVar> C = h[2];
   id<ORBitVar> D = h[3];
   id<ORBitVar> E = h[4];

   
   for (int j=0; j<16; j++) {
      _W[j] = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
      [_m add:[ORFactory bit:_W[j] eq:x[j]]];
   }
   for (int j=16; j<80; j++) {
      id<ORBitVar> tempBV = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
      id<ORBitVar> tempBV2 = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
      id<ORBitVar> tempBV3 = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
      id<ORBitVar> newW = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
      
      [_m add:[ORFactory bit:_W[j-3] xor:_W[j-8] eq:tempBV]];
      [_m add:[ORFactory bit:tempBV xor:_W[j-14] eq:tempBV2]];
      [_m add:[ORFactory bit:tempBV2 xor:_W[j-16] eq:tempBV3]];
      [_m add:[ORFactory bit:tempBV3 rotateLBy:1 eq:newW]];
      _W[j] = newW;
   }
   
   for (int t=0; t<80; t++) {
      id<ORBitVar> temp = [self shuffle:A b:B c:C d:D e:E t:t];
      E = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
      [_m add:[ORFactory bit:E eq:D]];
      D = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
      [_m add:[ORFactory bit:D eq:C]];
      C = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
      [_m add:[ORFactory bit:B rotateLBy:30 eq:C]];
      B=[ORFactory bitVar:_m low:&min up:&max bitLength:32];
      [_m add:[ORFactory bit:B eq:A]];
      A=[ORFactory bitVar:_m low:&min up:&max bitLength:32];
      [_m add:[ORFactory bit:A eq:temp]];
   }

   id<ORBitVar> *nh = malloc(5*sizeof(id<ORBitVar>));
   nh[0] = A;
   nh[1] = B;
   nh[2] = C;
   nh[3] = D;
   nh[4] = E;
   
//   nh[0] = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
//   nh[1] = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
//   nh[2] = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
//   nh[3] = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
//   nh[4] = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
//
//   id<ORBitVar> ci0 = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
//   id<ORBitVar> co0 = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
//   [_m add:[ORFactory bit:A plus:h[0] withCarryIn:ci0 eq:nh[0] withCarryOut:co0]];
//
//   id<ORBitVar> ci1 = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
//   id<ORBitVar> co1 = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
//   [_m add:[ORFactory bit:B plus:h[1] withCarryIn:ci1 eq:nh[1] withCarryOut:co1]];
//
//   id<ORBitVar> ci2 = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
//   id<ORBitVar> co2 = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
//   [_m add:[ORFactory bit:C plus:h[2] withCarryIn:ci2 eq:nh[2] withCarryOut:co2]];
//
//   id<ORBitVar> ci3 = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
//   id<ORBitVar> co3 = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
//   [_m add:[ORFactory bit:D plus:h[3] withCarryIn:ci3 eq:nh[3] withCarryOut:co3]];
//
//   id<ORBitVar> ci4 = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
//   id<ORBitVar> co4 = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
//   [_m add:[ORFactory bit:E plus:h[4] withCarryIn:ci4 eq:nh[4] withCarryOut:co4]];

   return(nh);
}

-(id<ORBitVar>) shuffle:(id<ORBitVar>)A b:(id<ORBitVar>)B c:(id<ORBitVar>)C d:(id<ORBitVar>) D e:(id<ORBitVar>)E t:(uint32)t
{
   uint32 min = 0x00000000;
   uint32 max = 0xFFFFFFFF;
   
   id<ORBitVar> fo;

//   if (t<20)
//      fo= [self f:B y:C z:D];
//   else if (t<40)
//      fo= [self g:B y:C z:D];
//   else if (t<60)
//      fo= [self h:B y:C z:D];
//   else
//      fo= [self g:B y:C z:D];
   
   if (t <= 19) {
      fo= [self f:B y:C z:D];
   } else if (t >= 20 && t <= 39) {
      fo= [self g:B y:C z:D];
   } else if (t >= 40 && t <= 59) {
      fo= [self h:B y:C z:D];
   } else {
      fo= [self g:B y:C z:D];
   }
   
   id<ORBitVar> rotatedA = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   [_m add:[ORFactory bit:A rotateLBy:5 eq:rotatedA]];
   
   id<ORBitVar> t0a = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   id<ORBitVar> ci =  [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   id<ORBitVar> co =  [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   [_m add:[ORFactory bit:rotatedA plus:fo withCarryIn:ci eq:t0a withCarryOut:co]];
   
   id<ORBitVar> t0 = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   ci =  [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   co =  [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   [_m add:[ORFactory bit:t0a plus:E withCarryIn:ci eq:t0 withCarryOut:co]];
   
   id<ORBitVar> t1 = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   ci =  [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   co =  [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   [_m add:[ORFactory bit:t0 plus:[self getK:t] withCarryIn:ci eq:t1 withCarryOut:co]];
   
   id<ORBitVar> t2 = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   ci =  [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   co =  [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   [_m add:[ORFactory bit:t1 plus:_W[t] withCarryIn:ci eq:t2 withCarryOut:co]];
   
   return t2;
}
@end

@implementation SHA1Block
+(SHA1Block*) initSHA1Block:(id<ORModel>)m
{
   SHA1Block* b = [[SHA1Block alloc] initExplicitSHA1Block:m];
   return b;
}
-(SHA1Block*) initExplicitSHA1Block:(id<ORModel>)m
{
   self = [super init];
   _m = m;
   _bitVars = malloc(16*sizeof(id<ORBitVar>));
   return self;
}
-(void) setData:(uint32*)data
{
   for(int i=0;i<16;i++)
   {
      //_data[i] = __builtin_bswap32(data[i]);
      _bitVars[i] = [ORFactory bitVar:_m low:&(data[i]) up:&(data[i]) bitLength:32];
      NSLog(@"%x",data[i]);
   }
}
-(void) setData:(uint32*)data withMask:(uint32*)mask
{
   uint32 maskedUp;
   uint32 maskedLow;
   for(int i=0;i<16;i++)
   {
//            maskedUp = __builtin_bswap32(data[i] | ~ mask[i]);
//            maskedLow = __builtin_bswap32(data[i] &  mask[i]);
      
//      data[i] = __builtin_bswap32(data[i]);
      maskedUp = data[i] | (~ mask[i]);
      maskedLow = data[i] &  mask[i];
      
      _bitVars[i] = [ORFactory bitVar:_m low:&maskedLow up:&maskedUp bitLength:32];
      //      NSLog(@"Message:    %x",data[i]);
      //      NSLog(@"Masked Up:  %x",maskedUp);
      //      NSLog(@"Masked Low: %x\n\n",maskedLow);
   }
}

-(ORUInt*) getData
{
   return _data;
}
-(id<ORBitVar>*) getORVars
{
   return _bitVars;
}
@end
