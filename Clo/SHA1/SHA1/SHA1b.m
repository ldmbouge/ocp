//
//  SHA1b.m
//  Clo
//
//  Created by Greg Johnson on 12/18/12.
//  Copyright (c) 2012 CSE. All rights reserved.
//

#import "SHA1b.h"

@implementation SHA1b : NSObject 
+(SHA1b*) initSHA1b{
   SHA1b* x = [[SHA1b alloc]initExplicitSHA1b];
   return x;
}


-(SHA1b*) initExplicitSHA1b
{
   self = [super init];
   _m = [ORFactory createModel];
   return self;
}

-(bool) getMessage:(NSString *)fname
{
   NSFileManager *fm;
   NSData *message;
   
   //NSString* str = @"abc";
   

   fm = [NSFileManager defaultManager];
   
   if( [fm fileExistsAtPath: fname] == NO){
      NSLog(@"File \"%@\" not found.\n",fname);
      return false;
   }
   message = [fm contentsAtPath:fname];

   //message = [str dataUsingEncoding:NSUTF8StringEncoding];
   _messageLength = [message length]*8;
   _buffer = malloc(((([message length]/4)+1)*4) *sizeof(uint)); //ensure buffer is on 32bit boundary
   [message getBytes:_buffer length:[message length]];
   NSLog(@"%s\n",(char*)_buffer);
   [fm dealloc];
   return true;
}

-(NSMutableArray*) getSHA1bDigest:(NSString*)fname //retrieves SHA1b digest from system call to openssl
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
   
   
//   NSString* str = @"(stdin)= da39a3ee5e6b4b0d3255bfef95601890afd80709";
//   data = [str dataUsingEncoding:NSUTF8StringEncoding];

   
   
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
   for(int i=0; i<SHA1b_DIGEST_LENGTH; i++){
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

-(void) createSHA1bBlocks:(uint32*)mask
{
   uint64 blockLength;
   _numBlocks = floor((_messageLength+64)/512)+1;
   _messageBlocks = [[NSMutableArray alloc] initWithCapacity:_numBlocks];
   NSLog(@"%lld blocks\n",_numBlocks);
   for(int i=0;i<_numBlocks;i++)
   {
      blockLength = MIN(512, _messageLength - (i * 512));
      [self createSHA1bBlock:&(_buffer[i*16]) withCount:blockLength andMask:mask];
   }
}

-(void) createSHA1bBlock:(ORUInt*)data withCount:(uint64)count andMask:(uint32*)messageMask{
   uint64 numBits, numBytes;
   uint32 mask;
   ORUInt      paddedData[16];
   SHA1bBlock* newBlock;
   
   if (count == 512) { //first or intermediate message block
      newBlock = [[SHA1bBlock alloc] initExplicitSHA1bBlock:_m];
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
         for (int i=0;i<8;i++)
            XX[56+i] = ((unsigned char*)(&_messageLength))[i];
//         XX[56] = _messageLength;

//         newBlock = [[SHA1bBlock alloc] initExplicitSHA1bBlock:_m];
         //         NSLog(@"Padded Data: %s",(char*)XX);
         //         NSLog(@"Padded Data: ");
         //         for(int i = 0; i<64;i++) NSLog(@"%02x",((unsigned char*)XX)[i]);
//         [newBlock setData:(uint32*)XX withMask:messageMask];
//         [_messageBlocks addObject:newBlock];
      }
      else /* need to do two blocks to finish up */
      { //newBlock = [[SHA1bBlock alloc] initExplicitSHA1bBlock:_m];
         for (int i=0;i<56;i++) XX[i] = 0;
         for (int i=0;i<8;i++) XX[56+i] = ((unsigned char*)(&_messageLength))[i];
         //         NSLog(@"Padded Data: %s",(char*)XX);
         //[newBlock setData:(uint32*)XX withMask:messageMask];
         //[_messageBlocks addObject:newBlock];
      }
      XX[56] = (_messageLength >> 56) & 0xFF;
      XX[57] = (_messageLength >> 48) & 0xFF;
      XX[58] = (_messageLength >> 40) & 0xFF;
      XX[59] = (_messageLength >> 32) & 0xFF;
      XX[60] = (_messageLength >> 24) & 0xFF;
      XX[61] = (_messageLength >> 16) & 0xFF;
      XX[62] = (_messageLength >> 8) & 0xFF;
      XX[63] = (_messageLength) & 0xFF;
      newBlock = [[SHA1bBlock alloc] initExplicitSHA1bBlock:_m];
      //         NSLog(@"Padded Data: %s",(char*)XX);
      //         NSLog(@"Padded Data: ");
      //         for(int i = 0; i<64;i++) NSLog(@"%02x",((unsigned char*)XX)[i]);
      [newBlock setData:(uint32*)XX withMask:messageMask];
      [_messageBlocks addObject:newBlock];
      
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
   
   [self getSHA1bDigest:filename];
   //get SHA1b Blocks
   _temps = [[NSMutableArray alloc] initWithCapacity:256];
   [self createSHA1bBlocks:mask];
   digest = [self stateModel];
   uint32 *value = malloc(sizeof(uint32));
   //*value = __builtin_bswap32([[_digest objectAtIndex:0] unsignedIntValue]);
      *value = [[_digest objectAtIndex:0] unsignedIntValue];
   digestVars[0] = [ORFactory bitVar:_m low:value up:value bitLength:32];
   value = malloc(sizeof(uint32));
   //*value = __builtin_bswap32([[_digest objectAtIndex:1] unsignedIntValue]);
      *value = [[_digest objectAtIndex:1] unsignedIntValue];
   digestVars[1] = [ORFactory bitVar:_m low:value up:value bitLength:32];
   value = malloc(sizeof(uint32));
   //*value = __builtin_bswap32([[_digest objectAtIndex:2] unsignedIntValue]);
      *value = [[_digest objectAtIndex:2] unsignedIntValue];
   digestVars[2] = [ORFactory bitVar:_m low:value up:value bitLength:32];
   value = malloc(sizeof(uint32));
   //*value = __builtin_bswap32([[_digest objectAtIndex:3] unsignedIntValue]);
      *value = [[_digest objectAtIndex:3] unsignedIntValue];
   digestVars[3] = [ORFactory bitVar:_m low:value up:value bitLength:32];
   value = malloc(sizeof(uint32));
   //*value = __builtin_bswap32([[_digest objectAtIndex:4] unsignedIntValue]);
      *value = [[_digest objectAtIndex:4] unsignedIntValue];
   digestVars[4] = [ORFactory bitVar:_m low:value up:value bitLength:32];
   
      [_m add:[ORFactory bit:digest[0] eq:digestVars[0]]];
      [_m add:[ORFactory bit:digest[1] eq:digestVars[1]]];
      [_m add:[ORFactory bit:digest[2] eq:digestVars[2]]];
      [_m add:[ORFactory bit:digest[3] eq:digestVars[3]]];
      [_m add:[ORFactory bit:digest[4] eq:digestVars[4]]];
   
   
   id<CPProgram,CPBV> cp = (id)[ORFactory createCPProgramBackjumpingDFS: _m];
   id<CPEngine> engine = [cp engine];
   id<ORExplorer> explorer = [cp explorer];
   
   NSLog(@"SHA-1 Message Blocks (Original)");
   id<ORBitVar>* bitVars;
   for(int i=0; i<_numBlocks;i++){
      bitVars = [[_messageBlocks objectAtIndex:i] getORVars];
      for(int j=0;j<16;j++)
         NSLog(@"%@\n",[cp stringValue:bitVars[j]]);
   }

//   NSArray* allvars = [model variables];

   id<ORIdArray> o = [ORFactory idArray:[cp engine] range:[[ORIntRangeI alloc] initORIntRangeI:0 up:15]];
   for(ORInt k=0;k <= 15;k++)
      [o set:bitVars[k] at:k];
   
   
   
   id<CPBitVarHeuristic> h;
   switch (heur) {
      case BVABS: h = [cp createBitVarABS:(id<CPBitVarArray>)o];
         break;
      case BVIBS: h = [cp createBitVarIBS:(id<CPBitVarArray>)o];
         break;
      //case BVFF:   h =[cp createBitVarFF:(id<CPBitVarArray>)o];
       default:    h =[cp createBitVarVSIDS:o];

         break;
   }

   [cp solve: ^{
      NSLog(@"Search");
      for(int i=0;i<5;i++)
      {
         NSLog(@"%@",[cp stringValue:digest[i]]);
         NSLog(@"%@\n\n",[cp stringValue:digestVars[i]]);
      }
      //      NSLog(@"Message Blocks (With Data Recovered)");
      clock_t searchStart = clock();
      [cp labelBitVarHeuristic:h];
      clock_t searchFinish = clock();
      
      for(int j=0;j<16;j++){
         NSLog(@"%@\n",[cp stringValue:bitVars[j]]);
      }
      
//      
//      NSLog(@"All variables:");
//      for (int i=0; i< [allvars count]; i++) {
//         NSLog(@"Model Variable[%i]: %x",i,[allvars[i] getLow]->_val);
//      }
//      NSLog(@"End all variables:");
      NSLog(@"Final digest variables");
      for(int j=0;j<5;j++)
      {
         NSLog(@"%@",[cp stringValue:digest[j]]);
         NSLog(@"%@\n\n",[cp stringValue:digestVars[j]]);
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
//   [cp release];
   return results;
   
}
-(void) getW:(id<ORBitVar>*) x
{
   ORUInt min = 0x00000000;
   ORUInt max = 0xFFFFFFFF;

   for(int t=0;t<80;t++)
      if (t < 16)
         _W[t] = x[t];
      else {
         volatile id<ORBitVar> tempBV = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
         volatile id<ORBitVar> tempBV2 = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
         volatile id<ORBitVar> tempBV3 = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
         volatile id<ORBitVar> newW = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
      
         [_m add:[ORFactory bit:_W[t-3] bxor:_W[t-8] eq:tempBV]];
         [_m add:[ORFactory bit:tempBV bxor:_W[t-14] eq:tempBV2]];
         [_m add:[ORFactory bit:tempBV2 bxor:_W[t-16] eq:tempBV3]];
         [_m add:[ORFactory bit:tempBV3 rotateLBy:1 eq:newW]];
         _W[t] = newW;
      }
}

-(id<ORBitVar>) getK:(int)t {
   ORUInt kValue;
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
   id<ORBitVar> *h5 = malloc(5*sizeof(id<ORBitVar>));
   
   h0[0] = [ORFactory bitVar:_m low:I0 up:I0 bitLength:32];
   h0[1] = [ORFactory bitVar:_m low:I1 up:I1 bitLength:32];
   h0[2] = [ORFactory bitVar:_m low:I2 up:I2 bitLength:32];
   h0[3] = [ORFactory bitVar:_m low:I3 up:I3 bitLength:32];
   h0[4] = [ORFactory bitVar:_m low:I4 up:I4 bitLength:32];
   
   //   _kVars[0] = [ORFactory bitVar:_m low:KV0 up:KV0 bitLength:32];
   //   _kVars[1] = [ORFactory bitVar:_m low:KV1 up:KV1 bitLength:32];
   //   _kVars[2] = [ORFactory bitVar:_m low:KV2 up:KV2 bitLength:32];
   //   _kVars[3] = [ORFactory bitVar:_m low:KV3 up:KV3 bitLength:32];
   
   ORUInt min = 0x00000000;
   uint32 max = 0xFFFFFFFF;
   uint32 cinmax = 0xFFFFFFFE;

   id<ORBitVar> cin;
   id<ORBitVar> cout;
   
   for(int i=0; i<_numBlocks;i++) {
      
      SHA1bBlock* b = [_messageBlocks objectAtIndex:i];
      id<ORBitVar> *msg = [b getORVars];
      [self getW:msg];
      id<ORBitVar> *h1 = [self round1:h0 x:msg];
      id<ORBitVar> *h2 = [self round2:h1 x:msg];
      id<ORBitVar> *h3 = [self round3:h2 x:msg];
      id<ORBitVar> *h4 = [self round4:h3 x:msg];
      
      h5[0] = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
      h5[1] = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
      h5[2] = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
      h5[3] = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
      h5[4] = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
      
      //forall(i in 0..3) _m.post(h4[i] == h0[i] + h3[i]);
      for (int i=0; i<5; i++)
      {
         //h5[i] = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
         cin = [ORFactory bitVar:_m low:&min up:&cinmax bitLength:32];
         cout = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
         [_m add:[ORFactory bit:h0[i] plus:h4[i] withCarryIn:cin eq:h5[i] withCarryOut:cout]];
      }
      h0 = h5;
   }
   
   return h0;
}

-(id<ORBitVar>) f:(id<ORBitVar>)x y:(id<ORBitVar>)y z:(id<ORBitVar>)z
{
   ORUInt min = 0x00000000;
   ORUInt max = 0xFFFFFFFF;
   
   id<ORBitVar> t0 = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   id<ORBitVar> t1 = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   id<ORBitVar> t2 = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   
   [_m add:[ORFactory bit:y bxor:z eq:t0]];
   [_m add:[ORFactory bit:x band:t0 eq:t1]];
   [_m add:[ORFactory bit:z bxor:t1 eq:t2]];
   
   return t2;
}
-(id<ORBitVar>) g:(id<ORBitVar>)x y:(id<ORBitVar>)y z:(id<ORBitVar>)z
{
   ORUInt min = 0x00000000;
   ORUInt max = 0xFFFFFFFF;
   
   id<ORBitVar> t0 = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   id<ORBitVar> t1 = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   
   [_m add:[ORFactory bit:x bxor:y eq:t0]];
   [_m add:[ORFactory bit:t0 bxor:z eq:t1]];
   
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
   [_m add:[ORFactory bit:x band:y eq:t0]];
   [_m add:[ORFactory bit:x band:z eq:t1]];
   [_m add:[ORFactory bit:y band:z eq:t2]];
   [_m add:[ORFactory bit:t0 bxor:t1 eq:t3]];
   [_m add:[ORFactory bit:t3 bxor:t2 eq:t4]];
   return t4;
}

-(id<ORBitVar>*) round1:(id<ORBitVar>*)h x:(id<ORBitVar>*) x
{
//   P( A, B, C, D, E, W[0]  );
//   P( E, A, B, C, D, W[1]  );
//   P( D, E, A, B, C, W[2]  );
//   P( C, D, E, A, B, W[3]  );
//   P( B, C, D, E, A, W[4]  );

//   P( A, B, C, D, E, W[5]  );
//   P( E, A, B, C, D, W[6]  );
//   P( D, E, A, B, C, W[7]  );
//   P( C, D, E, A, B, W[8]  );
//   P( B, C, D, E, A, W[9]  );

//   P( A, B, C, D, E, W[10] );
//   P( E, A, B, C, D, W[11] );
//   P( D, E, A, B, C, W[12] );
//   P( C, D, E, A, B, W[13] );
//   P( B, C, D, E, A, W[14] );

//   P( A, B, C, D, E, W[15] );
//   P( E, A, B, C, D, R(16) );
//   P( D, E, A, B, C, R(17) );
//   P( C, D, E, A, B, R(18) );
//   P( B, C, D, E, A, R(19) );
   
   id<ORBitVar> A = h[0];
   id<ORBitVar> B = h[1];
   id<ORBitVar> C = h[2];
   id<ORBitVar> D = h[3];
   id<ORBitVar> E = h[4];

   ORUInt min = 0x00000000;
   ORUInt max = 0xFFFFFFFF;
   id<ORBitVar> temp;
   
   E = [self shuffle1:A b:B c:C d:D e:E t:0 x:x];
   temp = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   [_m add:[ORFactory bit:B rotateLBy:30 eq:temp]];
   B=temp;
   
   D = [self shuffle1:E b:A c:B d:C e:D t:1 x:x];
   temp = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   [_m add:[ORFactory bit:A rotateLBy:30 eq:temp]];
   A=temp;
   
   C = [self shuffle1:D b:E c:A d:B e:C t:2 x:x];
   temp = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   [_m add:[ORFactory bit:E rotateLBy:30 eq:temp]];
   E=temp;
   
   B = [self shuffle1:C b:D c:E d:A e:B t:3 x:x];
   temp = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   [_m add:[ORFactory bit:D rotateLBy:30 eq:temp]];
   D=temp;
   
   A = [self shuffle1:B b:C c:D d:E e:A t:4 x:x];
   temp = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   [_m add:[ORFactory bit:C rotateLBy:30 eq:temp]];
   C=temp;
   
   
   E = [self shuffle1:A b:B c:C d:D e:E t:5 x:x];
   temp = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   [_m add:[ORFactory bit:B rotateLBy:30 eq:temp]];
   B=temp;
   
   D = [self shuffle1:E b:A c:B d:C e:D t:6 x:x];
   temp = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   [_m add:[ORFactory bit:A rotateLBy:30 eq:temp]];
   A=temp;
   
   C = [self shuffle1:D b:E c:A d:B e:C t:7 x:x];
   temp = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   [_m add:[ORFactory bit:E rotateLBy:30 eq:temp]];
   E=temp;
   
   B = [self shuffle1:C b:D c:E d:A e:B t:8 x:x];
   temp = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   [_m add:[ORFactory bit:D rotateLBy:30 eq:temp]];
   D=temp;
   
   A = [self shuffle1:B b:C c:D d:E e:A t:9 x:x];
   temp = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   [_m add:[ORFactory bit:C rotateLBy:30 eq:temp]];
   C=temp;
   
   E = [self shuffle1:A b:B c:C d:D e:E t:10 x:x];
   temp = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   [_m add:[ORFactory bit:B rotateLBy:30 eq:temp]];
   B=temp;
   
   D = [self shuffle1:E b:A c:B d:C e:D t:11 x:x];
   temp = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   [_m add:[ORFactory bit:A rotateLBy:30 eq:temp]];
   A=temp;
   
   C = [self shuffle1:D b:E c:A d:B e:C t:12 x:x];
   temp = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   [_m add:[ORFactory bit:E rotateLBy:30 eq:temp]];
   E=temp;
   
   B = [self shuffle1:C b:D c:E d:A e:B t:13 x:x];
   temp = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   [_m add:[ORFactory bit:D rotateLBy:30 eq:temp]];
   D=temp;
   
   A = [self shuffle1:B b:C c:D d:E e:A t:14 x:x];
   temp = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   [_m add:[ORFactory bit:C rotateLBy:30 eq:temp]];
   C=temp;
   
   E = [self shuffle1:A b:B c:C d:D e:E t:15 x:x];
   temp = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   [_m add:[ORFactory bit:B rotateLBy:30 eq:temp]];
   B=temp;
   
   D = [self shuffle1:E b:A c:B d:C e:D t:16 x:x];
   temp = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   [_m add:[ORFactory bit:A rotateLBy:30 eq:temp]];
   A=temp;
   
   C = [self shuffle1:D b:E c:A d:B e:C t:17 x:x];
   temp = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   [_m add:[ORFactory bit:E rotateLBy:30 eq:temp]];
   E=temp;
   
   B = [self shuffle1:C b:D c:E d:A e:B t:18 x:x];
   temp = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   [_m add:[ORFactory bit:D rotateLBy:30 eq:temp]];
   D=temp;
   
   A = [self shuffle1:B b:C c:D d:E e:A t:19 x:x];
   temp = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   [_m add:[ORFactory bit:C rotateLBy:30 eq:temp]];
   C=temp;
   
   id<ORBitVar> *nh = malloc(5*sizeof(id<ORBitVar>));
   nh[0] = A;
   nh[1] = B;
   nh[2] = C;
   nh[3] = D;
   nh[4] = E;
   
   return(nh);
}

-(id<ORBitVar>*)round2:(id<ORBitVar>*)h x:(id<ORBitVar>*) x
{
//   P( A, B, C, D, E, R(20) );
//   P( E, A, B, C, D, R(21) );
//   P( D, E, A, B, C, R(22) );
//   P( C, D, E, A, B, R(23) );
//   P( B, C, D, E, A, R(24) );
//   P( A, B, C, D, E, R(25) );
//   P( E, A, B, C, D, R(26) );
//   P( D, E, A, B, C, R(27) );
//   P( C, D, E, A, B, R(28) );
//   P( B, C, D, E, A, R(29) );
//   P( A, B, C, D, E, R(30) );
//   P( E, A, B, C, D, R(31) );
//   P( D, E, A, B, C, R(32) );
//   P( C, D, E, A, B, R(33) );
//   P( B, C, D, E, A, R(34) );
//   P( A, B, C, D, E, R(35) );
//   P( E, A, B, C, D, R(36) );
//   P( D, E, A, B, C, R(37) );
//   P( C, D, E, A, B, R(38) );
//   P( B, C, D, E, A, R(39) );
   
   id<ORBitVar> A = h[0];
   id<ORBitVar> B = h[1];
   id<ORBitVar> C = h[2];
   id<ORBitVar> D = h[3];
   id<ORBitVar> E = h[4];
   
   ORUInt min = 0x00000000;
   ORUInt max = 0xFFFFFFFF;
   id<ORBitVar> temp;

   E = [self shuffle2:A b:B c:C d:D e:E t:20 x:x];
   temp = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   [_m add:[ORFactory bit:B rotateLBy:30 eq:temp]];
   B=temp;

   D = [self shuffle2:E b:A c:B d:C e:D t:21 x:x];
   temp = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   [_m add:[ORFactory bit:A rotateLBy:30 eq:temp]];
   A=temp;

   C = [self shuffle2:D b:E c:A d:B e:C t:22 x:x];
   temp = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   [_m add:[ORFactory bit:E rotateLBy:30 eq:temp]];
   E=temp;
   
   B = [self shuffle2:C b:D c:E d:A e:B t:23 x:x];
   temp = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   [_m add:[ORFactory bit:D rotateLBy:30 eq:temp]];
   D=temp;
   
   A = [self shuffle2:B b:C c:D d:E e:A t:24 x:x];
   temp = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   [_m add:[ORFactory bit:C rotateLBy:30 eq:temp]];
   C=temp;
   
   
   E = [self shuffle2:A b:B c:C d:D e:E t:25 x:x];
   temp = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   [_m add:[ORFactory bit:B rotateLBy:30 eq:temp]];
   B=temp;
   
   D = [self shuffle2:E b:A c:B d:C e:D t:26 x:x];
   temp = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   [_m add:[ORFactory bit:A rotateLBy:30 eq:temp]];
   A=temp;
   
   C = [self shuffle2:D b:E c:A d:B e:C t:27 x:x];
   temp = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   [_m add:[ORFactory bit:E rotateLBy:30 eq:temp]];
   E=temp;
   
   B = [self shuffle2:C b:D c:E d:A e:B t:28 x:x];
   temp = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   [_m add:[ORFactory bit:D rotateLBy:30 eq:temp]];
   D=temp;
   
   A = [self shuffle2:B b:C c:D d:E e:A t:29 x:x];
   temp = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   [_m add:[ORFactory bit:C rotateLBy:30 eq:temp]];
   C=temp;
   
   E = [self shuffle2:A b:B c:C d:D e:E t:30 x:x];
   temp = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   [_m add:[ORFactory bit:B rotateLBy:30 eq:temp]];
   B=temp;
   
   D = [self shuffle2:E b:A c:B d:C e:D t:31 x:x];
   temp = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   [_m add:[ORFactory bit:A rotateLBy:30 eq:temp]];
   A=temp;
   
   C = [self shuffle2:D b:E c:A d:B e:C t:32 x:x];
   temp = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   [_m add:[ORFactory bit:E rotateLBy:30 eq:temp]];
   E=temp;
   
   B = [self shuffle2:C b:D c:E d:A e:B t:33 x:x];
   temp = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   [_m add:[ORFactory bit:D rotateLBy:30 eq:temp]];
   D=temp;
   
   A = [self shuffle2:B b:C c:D d:E e:A t:34 x:x];
   temp = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   [_m add:[ORFactory bit:C rotateLBy:30 eq:temp]];
   C=temp;
   
   E = [self shuffle2:A b:B c:C d:D e:E t:35 x:x];
   temp = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   [_m add:[ORFactory bit:B rotateLBy:30 eq:temp]];
   B=temp;
   
   D = [self shuffle2:E b:A c:B d:C e:D t:36 x:x];
   temp = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   [_m add:[ORFactory bit:A rotateLBy:30 eq:temp]];
   A=temp;
   
   C = [self shuffle2:D b:E c:A d:B e:C t:37 x:x];
   temp = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   [_m add:[ORFactory bit:E rotateLBy:30 eq:temp]];
   E=temp;
   
   B = [self shuffle2:C b:D c:E d:A e:B t:38 x:x];
   temp = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   [_m add:[ORFactory bit:D rotateLBy:30 eq:temp]];
   D=temp;
   
   A = [self shuffle2:B b:C c:D d:E e:A t:39 x:x];
   temp = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   [_m add:[ORFactory bit:C rotateLBy:30 eq:temp]];
   C=temp;
   
   id<ORBitVar> *nh = malloc(5*sizeof(id<ORBitVar>));
   nh[0] = A;
   nh[1] = B;
   nh[2] = C;
   nh[3] = D;
   nh[4] = E;
   
   return(nh);
}
-(id<ORBitVar>*) round3:(id<ORBitVar>*)h x:(id<ORBitVar>*) x
{
//   P( A, B, C, D, E, R(40) );
//   P( E, A, B, C, D, R(41) );
//   P( D, E, A, B, C, R(42) );
//   P( C, D, E, A, B, R(43) );
//   P( B, C, D, E, A, R(44) );
//   P( A, B, C, D, E, R(45) );
//   P( E, A, B, C, D, R(46) );
//   P( D, E, A, B, C, R(47) );
//   P( C, D, E, A, B, R(48) );
//   P( B, C, D, E, A, R(49) );
//   P( A, B, C, D, E, R(50) );
//   P( E, A, B, C, D, R(51) );
//   P( D, E, A, B, C, R(52) );
//   P( C, D, E, A, B, R(53) );
//   P( B, C, D, E, A, R(54) );
//   P( A, B, C, D, E, R(55) );
//   P( E, A, B, C, D, R(56) );
//   P( D, E, A, B, C, R(57) );
//   P( C, D, E, A, B, R(58) );
//   P( B, C, D, E, A, R(59) );
   
   id<ORBitVar> A = h[0];
   id<ORBitVar> B = h[1];
   id<ORBitVar> C = h[2];
   id<ORBitVar> D = h[3];
   id<ORBitVar> E = h[4];
   
   
   ORUInt min = 0x00000000;
   ORUInt max = 0xFFFFFFFF;
   id<ORBitVar> temp;
   
   E = [self shuffle3:A b:B c:C d:D e:E t:40 x:x];
   temp = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   [_m add:[ORFactory bit:B rotateLBy:30 eq:temp]];
   B=temp;
   
   D = [self shuffle3:E b:A c:B d:C e:D t:41 x:x];
   temp = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   [_m add:[ORFactory bit:A rotateLBy:30 eq:temp]];
   A=temp;
   
   C = [self shuffle3:D b:E c:A d:B e:C t:42 x:x];
   temp = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   [_m add:[ORFactory bit:E rotateLBy:30 eq:temp]];
   E=temp;
   
   B = [self shuffle3:C b:D c:E d:A e:B t:43 x:x];
   temp = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   [_m add:[ORFactory bit:D rotateLBy:30 eq:temp]];
   D=temp;
   
   A = [self shuffle3:B b:C c:D d:E e:A t:44 x:x];
   temp = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   [_m add:[ORFactory bit:C rotateLBy:30 eq:temp]];
   C=temp;
   
   
   E = [self shuffle3:A b:B c:C d:D e:E t:45 x:x];
   temp = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   [_m add:[ORFactory bit:B rotateLBy:30 eq:temp]];
   B=temp;
   
   D = [self shuffle3:E b:A c:B d:C e:D t:46 x:x];
   temp = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   [_m add:[ORFactory bit:A rotateLBy:30 eq:temp]];
   A=temp;
   
   C = [self shuffle3:D b:E c:A d:B e:C t:47 x:x];
   temp = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   [_m add:[ORFactory bit:E rotateLBy:30 eq:temp]];
   E=temp;
   
   B = [self shuffle3:C b:D c:E d:A e:B t:48 x:x];
   temp = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   [_m add:[ORFactory bit:D rotateLBy:30 eq:temp]];
   D=temp;
   
   A = [self shuffle3:B b:C c:D d:E e:A t:49 x:x];
   temp = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   [_m add:[ORFactory bit:C rotateLBy:30 eq:temp]];
   C=temp;
   
   E = [self shuffle3:A b:B c:C d:D e:E t:50 x:x];
   temp = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   [_m add:[ORFactory bit:B rotateLBy:30 eq:temp]];
   B=temp;
   
   D = [self shuffle3:E b:A c:B d:C e:D t:51 x:x];
   temp = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   [_m add:[ORFactory bit:A rotateLBy:30 eq:temp]];
   A=temp;
   
   C = [self shuffle3:D b:E c:A d:B e:C t:52 x:x];
   temp = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   [_m add:[ORFactory bit:E rotateLBy:30 eq:temp]];
   E=temp;
   
   B = [self shuffle3:C b:D c:E d:A e:B t:53 x:x];
   temp = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   [_m add:[ORFactory bit:D rotateLBy:30 eq:temp]];
   D=temp;
   
   A = [self shuffle3:B b:C c:D d:E e:A t:54 x:x];
   temp = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   [_m add:[ORFactory bit:C rotateLBy:30 eq:temp]];
   C=temp;
   
   E = [self shuffle3:A b:B c:C d:D e:E t:55 x:x];
   temp = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   [_m add:[ORFactory bit:B rotateLBy:30 eq:temp]];
   B=temp;
   
   D = [self shuffle3:E b:A c:B d:C e:D t:56 x:x];
   temp = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   [_m add:[ORFactory bit:A rotateLBy:30 eq:temp]];
   A=temp;
   
   C = [self shuffle3:D b:E c:A d:B e:C t:57 x:x];
   temp = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   [_m add:[ORFactory bit:E rotateLBy:30 eq:temp]];
   E=temp;
   
   B = [self shuffle3:C b:D c:E d:A e:B t:58 x:x];
   temp = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   [_m add:[ORFactory bit:D rotateLBy:30 eq:temp]];
   D=temp;
   
   A = [self shuffle3:B b:C c:D d:E e:A t:59 x:x];
   temp = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   [_m add:[ORFactory bit:C rotateLBy:30 eq:temp]];
   C=temp;
   
   id<ORBitVar> *nh = malloc(5*sizeof(id<ORBitVar>));
   nh[0] = A;
   nh[1] = B;
   nh[2] = C;
   nh[3] = D;
   nh[4] = E;
   
   return(nh);
}

-(id<ORBitVar>*) round4:(id<ORBitVar>*)h x:(id<ORBitVar>*) x
{
//   P( A, B, C, D, E, R(60) );
//   P( E, A, B, C, D, R(61) );
//   P( D, E, A, B, C, R(62) );
//   P( C, D, E, A, B, R(63) );
//   P( B, C, D, E, A, R(64) );
//   P( A, B, C, D, E, R(65) );
//   P( E, A, B, C, D, R(66) );
//   P( D, E, A, B, C, R(67) );
//   P( C, D, E, A, B, R(68) );
//   P( B, C, D, E, A, R(69) );
//   P( A, B, C, D, E, R(70) );
//   P( E, A, B, C, D, R(71) );
//   P( D, E, A, B, C, R(72) );
//   P( C, D, E, A, B, R(73) );
//   P( B, C, D, E, A, R(74) );
//   P( A, B, C, D, E, R(75) );
//   P( E, A, B, C, D, R(76) );
//   P( D, E, A, B, C, R(77) );
//   P( C, D, E, A, B, R(78) );
//   P( B, C, D, E, A, R(79) );

   id<ORBitVar> A = h[0];
   id<ORBitVar> B = h[1];
   id<ORBitVar> C = h[2];
   id<ORBitVar> D = h[3];
   id<ORBitVar> E = h[4];
   
   
   ORUInt min = 0x00000000;
   ORUInt max = 0xFFFFFFFF;
   id<ORBitVar> temp;
   
   E = [self shuffle2:A b:B c:C d:D e:E t:60 x:x];
   temp = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   [_m add:[ORFactory bit:B rotateLBy:30 eq:temp]];
   B=temp;
   
   D = [self shuffle2:E b:A c:B d:C e:D t:61 x:x];
   temp = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   [_m add:[ORFactory bit:A rotateLBy:30 eq:temp]];
   A=temp;
   
   C = [self shuffle2:D b:E c:A d:B e:C t:62 x:x];
   temp = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   [_m add:[ORFactory bit:E rotateLBy:30 eq:temp]];
   E=temp;
   
   B = [self shuffle2:C b:D c:E d:A e:B t:63 x:x];
   temp = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   [_m add:[ORFactory bit:D rotateLBy:30 eq:temp]];
   D=temp;
   
   A = [self shuffle2:B b:C c:D d:E e:A t:64 x:x];
   temp = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   [_m add:[ORFactory bit:C rotateLBy:30 eq:temp]];
   C=temp;
   
   
   E = [self shuffle2:A b:B c:C d:D e:E t:65 x:x];
   temp = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   [_m add:[ORFactory bit:B rotateLBy:30 eq:temp]];
   B=temp;
   
   D = [self shuffle2:E b:A c:B d:C e:D t:66 x:x];
   temp = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   [_m add:[ORFactory bit:A rotateLBy:30 eq:temp]];
   A=temp;
   
   C = [self shuffle2:D b:E c:A d:B e:C t:67 x:x];
   temp = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   [_m add:[ORFactory bit:E rotateLBy:30 eq:temp]];
   E=temp;
   
   B = [self shuffle2:C b:D c:E d:A e:B t:68 x:x];
   temp = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   [_m add:[ORFactory bit:D rotateLBy:30 eq:temp]];
   D=temp;
   
   A = [self shuffle2:B b:C c:D d:E e:A t:69 x:x];
   temp = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   [_m add:[ORFactory bit:C rotateLBy:30 eq:temp]];
   C=temp;
   
   E = [self shuffle2:A b:B c:C d:D e:E t:70 x:x];
   temp = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   [_m add:[ORFactory bit:B rotateLBy:30 eq:temp]];
   B=temp;
   
   D = [self shuffle2:E b:A c:B d:C e:D t:71 x:x];
   temp = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   [_m add:[ORFactory bit:A rotateLBy:30 eq:temp]];
   A=temp;
   
   C = [self shuffle2:D b:E c:A d:B e:C t:72 x:x];
   temp = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   [_m add:[ORFactory bit:E rotateLBy:30 eq:temp]];
   E=temp;
   
   B = [self shuffle2:C b:D c:E d:A e:B t:73 x:x];
   temp = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   [_m add:[ORFactory bit:D rotateLBy:30 eq:temp]];
   D=temp;
   
   A = [self shuffle2:B b:C c:D d:E e:A t:74 x:x];
   temp = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   [_m add:[ORFactory bit:C rotateLBy:30 eq:temp]];
   C=temp;
   
   E = [self shuffle2:A b:B c:C d:D e:E t:75 x:x];
   temp = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   [_m add:[ORFactory bit:B rotateLBy:30 eq:temp]];
   B=temp;
   
   D = [self shuffle2:E b:A c:B d:C e:D t:76 x:x];
   temp = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   [_m add:[ORFactory bit:A rotateLBy:30 eq:temp]];
   A=temp;
   
   C = [self shuffle2:D b:E c:A d:B e:C t:77 x:x];
   temp = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   [_m add:[ORFactory bit:E rotateLBy:30 eq:temp]];
   E=temp;
   
   B = [self shuffle2:C b:D c:E d:A e:B t:78 x:x];
   temp = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   [_m add:[ORFactory bit:D rotateLBy:30 eq:temp]];
   D=temp;
   
   A = [self shuffle2:B b:C c:D d:E e:A t:79 x:x];
   temp = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   [_m add:[ORFactory bit:C rotateLBy:30 eq:temp]];
   C=temp;
   
   id<ORBitVar> *nh = malloc(5*sizeof(id<ORBitVar>));
   nh[0] = A;
   nh[1] = B;
   nh[2] = C;
   nh[3] = D;
   nh[4] = E;
   
   return(nh);
}

-(id<ORBitVar>) shuffle1:(id<ORBitVar>)A b:(id<ORBitVar>)B c:(id<ORBitVar>)C d:(id<ORBitVar>) D e:(id<ORBitVar>)E t:(uint32)t x:(id<ORBitVar>*) x
{
   ORUInt min = 0x00000000;
   ORUInt max = 0xFFFFFFFF;
   ORUInt cinmax = 0xFFFFFFFE;

   
   id<ORBitVar> fo = [self f:B y:C z:D];
   
//   [self getW:t x:x];
   
   id<ORBitVar> rotatedA = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   [_m add:[ORFactory bit:A rotateLBy:5 eq:rotatedA]];
   
   id<ORBitVar> t0a = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   id<ORBitVar> ci =  [ORFactory bitVar:_m low:&min up:&cinmax bitLength:32];
   id<ORBitVar> co =  [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   [_m add:[ORFactory bit:rotatedA plus:fo withCarryIn:ci eq:t0a withCarryOut:co]];
   
   id<ORBitVar> t0 = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   ci =  [ORFactory bitVar:_m low:&min up:&cinmax bitLength:32];
   co =  [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   [_m add:[ORFactory bit:t0a plus:E withCarryIn:ci eq:t0 withCarryOut:co]];
   
   id<ORBitVar> t1 = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   ci =  [ORFactory bitVar:_m low:&min up:&cinmax bitLength:32];
   co =  [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   [_m add:[ORFactory bit:t0 plus:[self getK:t] withCarryIn:ci eq:t1 withCarryOut:co]];
   
   id<ORBitVar> t2 = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   ci =  [ORFactory bitVar:_m low:&min up:&cinmax bitLength:32];
   co =  [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   [_m add:[ORFactory bit:t1 plus:_W[t] withCarryIn:ci eq:t2 withCarryOut:co]];
   
   return t2;
}

-(id<ORBitVar>) shuffle2:(id<ORBitVar>)A b:(id<ORBitVar>)B c:(id<ORBitVar>)C d:(id<ORBitVar>) D e:(id<ORBitVar>)E t:(uint32)t x:(id<ORBitVar>*) x
{
   ORUInt min = 0x00000000;
   ORUInt max = 0xFFFFFFFF;
   ORUInt cinmax = 0xFFFFFFFE;
   
   id<ORBitVar> go = [self g:B y:C z:D];
   
//   [self getW:t x:x];
   
   id<ORBitVar> rotatedA = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   [_m add:[ORFactory bit:A rotateLBy:5 eq:rotatedA]];
   
   id<ORBitVar> t0a = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   id<ORBitVar> ci =  [ORFactory bitVar:_m low:&min up:&cinmax bitLength:32];
   id<ORBitVar> co =  [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   [_m add:[ORFactory bit:rotatedA plus:go withCarryIn:ci eq:t0a withCarryOut:co]];
   
   id<ORBitVar> t0 = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   ci =  [ORFactory bitVar:_m low:&min up:&cinmax bitLength:32];
   co =  [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   [_m add:[ORFactory bit:t0a plus:E withCarryIn:ci eq:t0 withCarryOut:co]];
   
   id<ORBitVar> t1 = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   ci =  [ORFactory bitVar:_m low:&min up:&cinmax bitLength:32];
   co =  [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   [_m add:[ORFactory bit:t0 plus:[self getK:t] withCarryIn:ci eq:t1 withCarryOut:co]];
   
   id<ORBitVar> t2 = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   ci =  [ORFactory bitVar:_m low:&min up:&cinmax bitLength:32];
   co =  [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   [_m add:[ORFactory bit:t1 plus:_W[t] withCarryIn:ci eq:t2 withCarryOut:co]];
   
   return t2;
}

-(id<ORBitVar>) shuffle3:(id<ORBitVar>)A b:(id<ORBitVar>)B c:(id<ORBitVar>)C d:(id<ORBitVar>) D e:(id<ORBitVar>)E t:(uint32)t x:(id<ORBitVar>*) x
{
   ORUInt min = 0x00000000;
   ORUInt max = 0xFFFFFFFF;
   ORUInt cinmax = 0xFFFFFFFE;

   id<ORBitVar> ho = [self h:B y:C z:D];
   
//   [self getW:t x:x];
   
   id<ORBitVar> rotatedA = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   [_m add:[ORFactory bit:A rotateLBy:5 eq:rotatedA]];
   
   id<ORBitVar> t0a = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   id<ORBitVar> ci =  [ORFactory bitVar:_m low:&min up:&cinmax bitLength:32];
   id<ORBitVar> co =  [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   [_m add:[ORFactory bit:rotatedA plus:ho withCarryIn:ci eq:t0a withCarryOut:co]];
   
   id<ORBitVar> t0 = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   ci =  [ORFactory bitVar:_m low:&min up:&cinmax bitLength:32];
   co =  [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   [_m add:[ORFactory bit:t0a plus:E withCarryIn:ci eq:t0 withCarryOut:co]];
   
   id<ORBitVar> t1 = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   ci =  [ORFactory bitVar:_m low:&min up:&cinmax bitLength:32];
   co =  [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   [_m add:[ORFactory bit:t0 plus:[self getK:t] withCarryIn:ci eq:t1 withCarryOut:co]];
   
   id<ORBitVar> t2 = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   ci =  [ORFactory bitVar:_m low:&min up:&cinmax bitLength:32];
   co =  [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   [_m add:[ORFactory bit:t1 plus:_W[t] withCarryIn:ci eq:t2 withCarryOut:co]];
   
   return t2;
}


@end

@implementation SHA1bBlock
+(SHA1bBlock*) initSHA1bBlock:(id<ORModel>)m
{
   SHA1bBlock* b = [[SHA1bBlock alloc] initExplicitSHA1bBlock:m];
   return b;
}
-(SHA1bBlock*) initExplicitSHA1bBlock:(id<ORModel>)m
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
   ORUInt maskedUp;
   ORUInt maskedLow;
   for(int i=0;i<16;i++)
   {
                  maskedUp = __builtin_bswap32(data[i] | ~ mask[i]);
                 maskedLow = __builtin_bswap32(data[i] &  mask[i]);
      
      //      data[i] = __builtin_bswap32(data[i]);
//      maskedUp = data[i] | (~ mask[i]);
//      maskedLow = data[i] &  mask[i];
      
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
