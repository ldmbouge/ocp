/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "MD5.h"

@implementation MD5
+(MD5*) initMD5{
   MD5* x = [[MD5 alloc]initExplicitMD5];
   return x;
}


-(MD5*) initExplicitMD5
{
   self = [super init];
   _m = [ORFactory createModel];
   return self;
}

-(ORBool) getMessage:(NSString *)fname
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
   NSLog(@"Message:[%s]\n",(char*)_buffer);
   [fm dealloc];
   return true;
}

-(NSMutableArray*) getMD5Digest:(NSString*)fname //retrieves MD5 digest from system call to openssl
{
   NSTask *task = [[NSTask alloc] init];
   NSString *command = @"/usr/bin/openssl";
   NSString *param = [[NSMutableString alloc] initWithString:@"dgst"];
   NSMutableArray *params = [NSMutableArray arrayWithObject:param];
   param = @"-md5";
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
   NSMutableArray *digest = [[NSMutableArray alloc] initWithCapacity:4];
   NSScanner *scanner;
   unsigned int digestValue;
   for(int i=0; i<DIGEST_LENGTH; i++){
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


-(void) createMD5Blocks:(uint32*)mask
{
   uint64 blockLength;
   _numBlocks = floor((_messageLength+64)/512)+1;
   _messageBlocks = [[NSMutableArray alloc] initWithCapacity:_numBlocks];
   NSLog(@"%lld blocks\n",_numBlocks);
   for(int i=0;i<_numBlocks;i++)
   {
      blockLength = MIN(512, _messageLength - (i * 512));
      [self createMD5Block:&(_buffer[i*16]) withCount:blockLength andMask:mask];
   }
}

-(void) createMD5Block:(ORUInt*)data withCount:(uint64)count andMask:(uint32*)messageMask{
   uint64 numBits, numBytes;
   uint32 mask;
   ORUInt      paddedData[16];
   MD5Block* newBlock;
   
   if (count == 512) { //first or intermediate message block
      newBlock = [[MD5Block alloc] initExplicitMD5Block:_m];
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
         newBlock = [[MD5Block alloc] initExplicitMD5Block:_m];
         //         NSLog(@"Padded Data: %s",(char*)XX);
         //         NSLog(@"Padded Data: ");
         //         for(int i = 0; i<64;i++) NSLog(@"%02x",((unsigned char*)XX)[i]);
         [newBlock setData:(uint32*)XX withMask:messageMask];
         [_messageBlocks addObject:newBlock];
      }
      else /* need to do two blocks to finish up */
      { newBlock = [[MD5Block alloc] initExplicitMD5Block:_m];
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
   id<ORBitVar>* digestVars = malloc(4*sizeof(id<ORBitVar>));

   start = clock();
   
   [self getMessage:filename];
   [self getMD5Digest:filename];
   //get MD5 Blocks
//   _temps = [[NSMutableArray alloc] initWithCapacity:128];
   [self createMD5Blocks:mask];
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
   
   [_m add:[ORFactory bit:digest[0] eq:digestVars[0]]];
   [_m add:[ORFactory bit:digest[1] eq:digestVars[1]]];
   [_m add:[ORFactory bit:digest[2] eq:digestVars[2]]];
   [_m add:[ORFactory bit:digest[3] eq:digestVars[3]]];
   
   
   id<CPProgram,CPBV> cp = (id)[ORFactory createCPProgramBackjumpingDFS: _m];
   id<CPEngine> engine = [cp engine];
   id<ORExplorer> explorer = [cp explorer];

   NSLog(@"MD5 Message Blocks (Original)");
   id<ORBitVar>* bitVars;
   for(int i=0; i<_numBlocks;i++){
      bitVars = [[_messageBlocks objectAtIndex:i] getORVars];
      for(int j=0;j<16;j++)
         NSLog(@"%@\n",[cp stringValue: bitVars[j]]);
   }
   
   id<ORIdArray> o = [ORFactory idArray:[cp engine] range:[[ORIntRangeI alloc] initORIntRangeI:0 up:15]];
   for(ORInt k=0;k <= 15;k++)
      [o set:bitVars[k] at:k];


   id<CPBitVarHeuristic> h;
   switch (heur) {
      case BVABS: h = [cp createBitVarABS:(id<CPBitVarArray>)o];
                  break;
      case BVIBS: h = [cp createBitVarIBS:(id<CPBitVarArray>)o];
         break;
       case BVFF: //h =[cp createBitVarFF];
                  //break;
      default:    h =[cp createBitVarVSIDS];
                  break;
   }
   
   [cp solve: ^{
      NSLog(@"Search");
      for(int i=0;i<4;i++)
      {
         NSLog(@"%@",[cp stringValue:digest[i]]);
         NSLog(@"%@\n\n",[cp stringValue:digestVars[i]]);
      }
      clock_t searchStart = clock();
      [cp labelBitVarHeuristicVSIDS:h];
      clock_t searchFinish = clock();

      for(int j=0;j<16;j++){
         NSLog(@"%@\n",[cp stringValue:bitVars[j]]);
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
-(id<ORBitVar>*) stateModel
{
   uint32 *I0 = malloc(sizeof(uint32));
   uint32 *I1 = malloc(sizeof(uint32));
   uint32 *I2 = malloc(sizeof(uint32));
   uint32 *I3 = malloc(sizeof(uint32));
   
   *I0 = 0x67452301;
   *I1 = 0xefcdab89;
   *I2 = 0x98badcfe;
   *I3 = 0x10325476;
   
   
   id<ORBitVar> *h0 = malloc(4*sizeof(id<ORBitVar>));
   id<ORBitVar> *h5 = malloc(4*sizeof(id<ORBitVar>));
   
   h0[0] = [ORFactory bitVar:_m low:I0 up:I0 bitLength:32];
   h0[1] = [ORFactory bitVar:_m low:I1 up:I1 bitLength:32];
   h0[2] = [ORFactory bitVar:_m low:I2 up:I2 bitLength:32];
   h0[3] = [ORFactory bitVar:_m low:I3 up:I3 bitLength:32];
   
   for(int i=0; i<_numBlocks;i++) {
      MD5Block* b = [_messageBlocks objectAtIndex:i];
      
      id<ORBitVar> *msg = [b getORVars];
      id<ORBitVar> *h1 = [self round1:h0 x:msg];
      id<ORBitVar> *h2 = [self round2:h1 x:msg];
      id<ORBitVar> *h3 = [self round3:h2 x:msg];
      id<ORBitVar> *h4 = [self round4:h3 x:msg];
      
      uint32 min = 0;
      uint32 max = 0xFFFFFFFF;
      uint32 cinmax = 0xFFFFFFFE;
      
      id<ORBitVar> cin;
      id<ORBitVar> cout;
      h5[0] = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
      h5[1] = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
      h5[2] = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
      h5[3] = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
      
      //forall(i in 0..3) _m.post(h4[i] == h0[i] + h3[i]);
      for (int i=0; i<4; i++)
      {
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
//   F(X,Y,Z) = XY v not(X) Z
   uint32 min = 0;
   uint32 max = 0xFFFFFFFF;
   
   id<ORBitVar> t0 = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   id<ORBitVar> t1 = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   id<ORBitVar> t2 = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   id<ORBitVar> t3 = [ORFactory bitVar:_m low:&min up:&max bitLength:32];

   [_m add:[ORFactory bit:x band:y eq:t0]];
   [_m add:[ORFactory bit:x bnot:t1]];
   [_m add:[ORFactory bit:t1 band:z eq:t2]];
   [_m add:[ORFactory bit:t0 bor:t2 eq:t3]];

   return t3;
}
-(id<ORBitVar>) g:(id<ORBitVar>)x y:(id<ORBitVar>)y z:(id<ORBitVar>)z
{
//   G(X,Y,Z) = XZ v Y not(Z)
   uint32 min = 0;
   uint32 max = 0xFFFFFFFF;
   
   id<ORBitVar> t0 = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   id<ORBitVar> t1 = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   id<ORBitVar> t2 = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   id<ORBitVar> t3 = [ORFactory bitVar:_m low:&min up:&max bitLength:32];

   [_m add:[ORFactory bit:x band:z eq:t0]];
   [_m add:[ORFactory bit:z bnot:t1]];
   [_m add:[ORFactory bit:y band:t1 eq:t2]];
   [_m add:[ORFactory bit:t0 bor:t2 eq:t3]];

   return t3;
}
-(id<ORBitVar>) h:(id<ORBitVar>)x y:(id<ORBitVar>)y z:(id<ORBitVar>)z
{
//   H(X,Y,Z) = X xor Y xor Z
   uint32 min = 0;
   uint32 max = 0xFFFFFFFF;
   
   id<ORBitVar> t0 = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   id<ORBitVar> t1 = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   [_m add:[ORFactory bit:x bxor:y eq:t0]];
   [_m add:[ORFactory bit:t0 bxor:z eq:t1]];
   return t1;
}
-(id<ORBitVar>) i:(id<ORBitVar>)x y:(id<ORBitVar>)y z:(id<ORBitVar>)z
{
//   I(X,Y,Z) = Y xor (X v not(Z))
   uint32 min = 0;
   uint32 max = 0xFFFFFFFF;
   
   id<ORBitVar> t0 = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   id<ORBitVar> t1 = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   id<ORBitVar> t2 = [ORFactory bitVar:_m low:&min up:&max bitLength:32];

   [_m add:[ORFactory bit:z bnot:t0]];
   [_m add:[ORFactory bit:x bor:t0 eq:t1]];
   [_m add:[ORFactory bit:y bxor:t1 eq:t2]];
   
   return t2;
}


-(id<ORBitVar>*) round1:(id<ORBitVar>*)h x:(id<ORBitVar>*) x
{
//   FF (a, b, c, d, x[ 0], S11, 0xd76aa478); /* 1 */
//   FF (d, a, b, c, x[ 1], S12, 0xe8c7b756); /* 2 */
//   FF (c, d, a, b, x[ 2], S13, 0x242070db); /* 3 */
//   FF (b, c, d, a, x[ 3], S14, 0xc1bdceee); /* 4 */
   
//   FF (a, b, c, d, x[ 4], S11, 0xf57c0faf); /* 5 */
//   FF (d, a, b, c, x[ 5], S12, 0x4787c62a); /* 6 */
//   FF (c, d, a, b, x[ 6], S13, 0xa8304613); /* 7 */
//   FF (b, c, d, a, x[ 7], S14, 0xfd469501); /* 8 */
   
//   FF (a, b, c, d, x[ 8], S11, 0x698098d8); /* 9 */
//   FF (d, a, b, c, x[ 9], S12, 0x8b44f7af); /* 10 */
//   FF (c, d, a, b, x[10], S13, 0xffff5bb1); /* 11 */
//   FF (b, c, d, a, x[11], S14, 0x895cd7be); /* 12 */
   
//   FF (a, b, c, d, x[12], S11, 0x6b901122); /* 13 */
//   FF (d, a, b, c, x[13], S12, 0xfd987193); /* 14 */
//   FF (c, d, a, b, x[14], S13, 0xa679438e); /* 15 */
//   FF (b, c, d, a, x[15], S14, 0x49b40821); /* 16 */

   id<ORBitVar> A = h[0];
   id<ORBitVar> B = h[1];
   id<ORBitVar> C = h[2];
   id<ORBitVar> D = h[3];
   
   //[self shuffle1: b: c: d: index: shiftBy: x:x];
   A = [self shuffle1:A b:B c:C d:D index:0 shiftBy:7 x:x t:0xd76aa478];
   D = [self shuffle1:D b:A c:B d:C index:1 shiftBy:12 x:x t:0xe8c7b756];
   C = [self shuffle1:C b:D c:A d:B index:2 shiftBy:17 x:x t:0x242070db];
   B = [self shuffle1:B b:C c:D d:A index:3 shiftBy:22 x:x t:0xc1bdceee];
   
   A = [self shuffle1:A b:B c:C d:D index:4 shiftBy:7 x:x t:0xf57c0faf];
   D = [self shuffle1:D b:A c:B d:C index:5 shiftBy:12 x:x t:0x4787c62a];
   C = [self shuffle1:C b:D c:A d:B index:6 shiftBy:17 x:x t:0xa8304613];
   B = [self shuffle1:B b:C c:D d:A index:7 shiftBy:22 x:x t:0xfd469501];
   
   A = [self shuffle1:A b:B c:C d:D index:8 shiftBy:7 x:x t:0x698098d8];
   D = [self shuffle1:D b:A c:B d:C index:9 shiftBy:12 x:x t:0x8b44f7af];
   C = [self shuffle1:C b:D c:A d:B index:10 shiftBy:17 x:x t:0xffff5bb1];
   B = [self shuffle1:B b:C c:D d:A index:11 shiftBy:22 x:x t:0x895cd7be];
   
   A = [self shuffle1:A b:B c:C d:D index:12 shiftBy:7 x:x t:0x6b901122];
   D = [self shuffle1:D b:A c:B d:C index:13 shiftBy:12 x:x t:0xfd987193];
   C = [self shuffle1:C b:D c:A d:B index:14 shiftBy:17 x:x t:0xa679438e];
   B = [self shuffle1:B b:C c:D d:A index:15 shiftBy:22 x:x t:0x49b40821];

   id<ORBitVar> *nh = malloc(4*sizeof(id<ORBitVar>));
   nh[0] = A;
   nh[1] = B;
   nh[2] = C;
   nh[3] = D;
   return(nh);
}

-(id<ORBitVar>*)round2:(id<ORBitVar>*)h x:(id<ORBitVar>*) x
{
//   GG (a, b, c, d, x[ 1], S21, 0xf61e2562); /* 17 */
//   GG (d, a, b, c, x[ 6], S22, 0xc040b340); /* 18 */
//   GG (c, d, a, b, x[11], S23, 0x265e5a51); /* 19 */
//   GG (b, c, d, a, x[ 0], S24, 0xe9b6c7aa); /* 20 */
   
//   GG (a, b, c, d, x[ 5], S21, 0xd62f105d); /* 21 */
//   GG (d, a, b, c, x[10], S22, 0x2441453); /* 22 */
//   GG (c, d, a, b, x[15], S23, 0xd8a1e681); /* 23 */
//   GG (b, c, d, a, x[ 4], S24, 0xe7d3fbc8); /* 24 */
   
//   GG (a, b, c, d, x[ 9], S21, 0x21e1cde6); /* 25 */
//   GG (d, a, b, c, x[14], S22, 0xc33707d6); /* 26 */
//   GG (c, d, a, b, x[ 3], S23, 0xf4d50d87); /* 27 */
//   GG (b, c, d, a, x[ 8], S24, 0x455a14ed); /* 28 */
   
//   GG (a, b, c, d, x[13], S21, 0xa9e3e905); /* 29 */
//   GG (d, a, b, c, x[ 2], S22, 0xfcefa3f8); /* 30 */
//   GG (c, d, a, b, x[ 7], S23, 0x676f02d9); /* 31 */
//   GG (b, c, d, a, x[12], S24, 0x8d2a4c8a); /* 32 */
   
   
   id<ORBitVar> A = h[0];
   id<ORBitVar> B = h[1];
   id<ORBitVar> C = h[2];
   id<ORBitVar> D = h[3];
   A = [self shuffle2:A b:B c:C d:D index:1 shiftBy:5 x:x t:0xf61e2562];
   D = [self shuffle2:D b:A c:B d:C index:6 shiftBy:9 x:x t:0xc040b340];
   C = [self shuffle2:C b:D c:A d:B index:11 shiftBy:14 x:x t:0x265e5a51];
   B = [self shuffle2:B b:C c:D d:A index:0 shiftBy:20 x:x t:0xe9b6c7aa];
   
   A = [self shuffle2:A b:B c:C d:D index:5 shiftBy:5 x:x t:0xd62f105d];
   D = [self shuffle2:D b:A c:B d:C index:10 shiftBy:9 x:x t:0x2441453];
   C = [self shuffle2:C b:D c:A d:B index:15 shiftBy:14 x:x t:0xd8a1e681];
   B = [self shuffle2:B b:C c:D d:A index:4 shiftBy:20 x:x t:0xe7d3fbc8];
   
   A = [self shuffle2:A b:B c:C d:D index:9 shiftBy:5 x:x t:0x21e1cde6];
   D = [self shuffle2:D b:A c:B d:C index:14 shiftBy:9 x:x t:0xc33707d6];
   C = [self shuffle2:C b:D c:A d:B index:3 shiftBy:14 x:x t:0xf4d50d87];
   B = [self shuffle2:B b:C c:D d:A index:8 shiftBy:20 x:x t:0x455a14ed];
   
   A = [self shuffle2:A b:B c:C d:D index:13 shiftBy:5 x:x t:0xa9e3e905];
   D = [self shuffle2:D b:A c:B d:C index:2 shiftBy:9 x:x t:0xfcefa3f8];
   C = [self shuffle2:C b:D c:A d:B index:7 shiftBy:14 x:x t:0x676f02d9];
   B = [self shuffle2:B b:C c:D d:A index:12 shiftBy:20 x:x t:0x8d2a4c8a];
      
   id<ORBitVar> *nh = malloc(4*sizeof(id<ORBitVar>));
   nh[0] = A;
   nh[1] = B;
   nh[2] = C;
   nh[3] = D;
   return(nh);
}
-(id<ORBitVar>*) round3:(id<ORBitVar>*)h x:(id<ORBitVar>*) x
{
//   /* Round 3 */
//   HH (a, b, c, d, x[ 5], S31, 0xfffa3942); /* 33 */
//   HH (d, a, b, c, x[ 8], S32, 0x8771f681); /* 34 */
//   HH (c, d, a, b, x[11], S33, 0x6d9d6122); /* 35 */
//   HH (b, c, d, a, x[14], S34, 0xfde5380c); /* 36 */
   
//   HH (a, b, c, d, x[ 1], S31, 0xa4beea44); /* 37 */
//   HH (d, a, b, c, x[ 4], S32, 0x4bdecfa9); /* 38 */
//   HH (c, d, a, b, x[ 7], S33, 0xf6bb4b60); /* 39 */
//   HH (b, c, d, a, x[10], S34, 0xbebfbc70); /* 40 */
   
//   HH (a, b, c, d, x[13], S31, 0x289b7ec6); /* 41 */
//   HH (d, a, b, c, x[ 0], S32, 0xeaa127fa); /* 42 */
//   HH (c, d, a, b, x[ 3], S33, 0xd4ef3085); /* 43 */
//   HH (b, c, d, a, x[ 6], S34, 0x4881d05); /* 44 */
   
//   HH (a, b, c, d, x[ 9], S31, 0xd9d4d039); /* 45 */
//   HH (d, a, b, c, x[12], S32, 0xe6db99e5); /* 46 */
//   HH (c, d, a, b, x[15], S33, 0x1fa27cf8); /* 47 */
//   HH (b, c, d, a, x[ 2], S34, 0xc4ac5665); /* 48 */
   
   id<ORBitVar> A = h[0];
   id<ORBitVar> B = h[1];
   id<ORBitVar> C = h[2];
   id<ORBitVar> D = h[3];
   
   
   A = [self shuffle3:A b:B c:C d:D index:5 shiftBy:4 x:x t:0xfffa3942];
   D = [self shuffle3:D b:A c:B d:C index:8 shiftBy:11 x:x t:0x8771f681];
   C = [self shuffle3:C b:D c:A d:B index:11 shiftBy:16 x:x t:0x6d9d6122];
   B = [self shuffle3:B b:C c:D d:A index:14 shiftBy:23 x:x t:0xfde5380c];
   
   A = [self shuffle3:A b:B c:C d:D index:1 shiftBy:4 x:x t:0xa4beea44];
   D = [self shuffle3:D b:A c:B d:C index:4 shiftBy:11 x:x t:0x4bdecfa9];
   C = [self shuffle3:C b:D c:A d:B index:7 shiftBy:16 x:x t:0xf6bb4b60];
   B = [self shuffle3:B b:C c:D d:A index:10 shiftBy:23 x:x t:0xbebfbc70];
   
   A = [self shuffle3:A b:B c:C d:D index:13 shiftBy:4 x:x t:0x289b7ec6];
   D = [self shuffle3:D b:A c:B d:C index:0 shiftBy:11 x:x t:0xeaa127fa];
   C = [self shuffle3:C b:D c:A d:B index:3 shiftBy:16 x:x t:0xd4ef3085];
   B = [self shuffle3:B b:C c:D d:A index:6 shiftBy:23 x:x t:0x4881d05];
   
   A = [self shuffle3:A b:B c:C d:D index:9 shiftBy:4 x:x t:0xd9d4d039];
   D = [self shuffle3:D b:A c:B d:C index:12 shiftBy:11 x:x t:0xe6db99e5];
   C = [self shuffle3:C b:D c:A d:B index:15 shiftBy:16 x:x t:0x1fa27cf8];
   B = [self shuffle3:B b:C c:D d:A index:2 shiftBy:23 x:x t:0xc4ac5665];

   id<ORBitVar> *nh = malloc(4*sizeof(id<ORBitVar>));
   nh[0] = A;
   nh[1] = B;
   nh[2] = C;
   nh[3] = D;
   return(nh);
}

-(id<ORBitVar>*) round4:(id<ORBitVar>*)h x:(id<ORBitVar>*) x
{
//   II (a, b, c, d, x[ 0], S41, 0xf4292244); /* 49 */
//   II (d, a, b, c, x[ 7], S42, 0x432aff97); /* 50 */
//   II (c, d, a, b, x[14], S43, 0xab9423a7); /* 51 */
//   II (b, c, d, a, x[ 5], S44, 0xfc93a039); /* 52 */
   
//   II (a, b, c, d, x[12], S41, 0x655b59c3); /* 53 */
//   II (d, a, b, c, x[ 3], S42, 0x8f0ccc92); /* 54 */
//   II (c, d, a, b, x[10], S43, 0xffeff47d); /* 55 */
//   II (b, c, d, a, x[ 1], S44, 0x85845dd1); /* 56 */
   
//   II (a, b, c, d, x[ 8], S41, 0x6fa87e4f); /* 57 */
//   II (d, a, b, c, x[15], S42, 0xfe2ce6e0); /* 58 */
//   II (c, d, a, b, x[ 6], S43, 0xa3014314); /* 59 */
//   II (b, c, d, a, x[13], S44, 0x4e0811a1); /* 60 */
   
//   II (a, b, c, d, x[ 4], S41, 0xf7537e82); /* 61 */
//   II (d, a, b, c, x[11], S42, 0xbd3af235); /* 62 */
//   II (c, d, a, b, x[ 2], S43, 0x2ad7d2bb); /* 63 */
//   II (b, c, d, a, x[ 9], S44, 0xeb86d391); /* 64 */
   
   id<ORBitVar> A = h[0];
   id<ORBitVar> B = h[1];
   id<ORBitVar> C = h[2];
   id<ORBitVar> D = h[3];
   
   A = [self shuffle4:A b:B c:C d:D index:0 shiftBy:6 x:x t:0xf4292244];
   D = [self shuffle4:D b:A c:B d:C index:7 shiftBy:10 x:x t:0x432aff97];
   C = [self shuffle4:C b:D c:A d:B index:14 shiftBy:15 x:x t:0xab9423a7];
   B = [self shuffle4:B b:C c:D d:A index:5 shiftBy:21 x:x t:0xfc93a039];
   
   A = [self shuffle4:A b:B c:C d:D index:12 shiftBy:6 x:x t:0x655b59c3];
   D = [self shuffle4:D b:A c:B d:C index:3 shiftBy:10 x:x t:0x8f0ccc92];
   C = [self shuffle4:C b:D c:A d:B index:10 shiftBy:15 x:x t:0xffeff47d];
   B = [self shuffle4:B b:C c:D d:A index:1 shiftBy:21 x:x t:0x85845dd1];
   
   A = [self shuffle4:A b:B c:C d:D index:8 shiftBy:6 x:x t:0x6fa87e4f];
   D = [self shuffle4:D b:A c:B d:C index:15 shiftBy:10 x:x t:0xfe2ce6e0];
   C = [self shuffle4:C b:D c:A d:B index:6 shiftBy:15 x:x t:0xa3014314];
   B = [self shuffle4:B b:C c:D d:A index:13 shiftBy:21 x:x t:0x4e0811a1];
   
   A = [self shuffle4:A b:B c:C d:D index:4 shiftBy:6 x:x t:0xf7537e82];
   D = [self shuffle4:D b:A c:B d:C index:11 shiftBy:10 x:x t:0xbd3af235];
   C = [self shuffle4:C b:D c:A d:B index:2 shiftBy:15 x:x t:0x2ad7d2bb];
   B = [self shuffle4:B b:C c:D d:A index:9 shiftBy:21 x:x t:0xeb86d391];

   id<ORBitVar> *nh = malloc(4*sizeof(id<ORBitVar>));
   nh[0] = A;
   nh[1] = B;
   nh[2] = C;
   nh[3] = D;
   return(nh);
}

-(id<ORBitVar>) shuffle1:(id<ORBitVar>)A b:(id<ORBitVar>)B c:(id<ORBitVar>)C d:(id<ORBitVar>) D index:(int)i shiftBy:(int) s x:(id<ORBitVar>*) x t:(uint32)t
{
//#define FF(a, b, c, d, x, s, ac) { \
//(a) += F ((b), (c), (d)) + (x) + (UINT4)(ac); \
//(a) = ROTATE_LEFT ((a), (s)); \
//(a) += (b); \
//}
   
   uint32 min = 0;
   uint32 max = 0xFFFFFFFF;
   uint32 cinmax = 0xFFFFFFFE;
   
   id<ORBitVar> T = [ORFactory bitVar:_m low:&t up:&t bitLength:32];
   
   id<ORBitVar> fo = [self f:B y:C z:D];
   
   id<ORBitVar> t0a = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   id<ORBitVar> ci =  [ORFactory bitVar:_m low:&min up:&cinmax bitLength:32];
   id<ORBitVar> co =  [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   [_m add:[ORFactory bit:A plus:fo withCarryIn:ci eq:t0a withCarryOut:co]];

   id<ORBitVar> t0 = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   ci =  [ORFactory bitVar:_m low:&min up:&cinmax bitLength:32];
   co =  [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   [_m add:[ORFactory bit:t0a plus:x[i] withCarryIn:ci eq:t0 withCarryOut:co]];
   
   id<ORBitVar> t1 = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   ci =  [ORFactory bitVar:_m low:&min up:&cinmax bitLength:32];
   co =  [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   [_m add:[ORFactory bit:t0 plus:T withCarryIn:ci eq:t1 withCarryOut:co]];
   
   id<ORBitVar> t2 = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   [_m add:[ORFactory bit:t1 rotateLBy:s eq:t2]];
   
   id<ORBitVar> t3 = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   ci =  [ORFactory bitVar:_m low:&min up:&cinmax bitLength:32];
   co =  [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   [_m add:[ORFactory bit:t2 plus:B withCarryIn:ci eq:t3 withCarryOut:co]];
   
   
   return t3;
}

-(id<ORBitVar>) shuffle2:(id<ORBitVar>)A b:(id<ORBitVar>)B c:(id<ORBitVar>)C d:(id<ORBitVar>) D index:(int)i shiftBy:(int) s x:(id<ORBitVar>*) x t:(uint32)t
{
//#define GG(a, b, c, d, x, s, ac) { \
//(a) += G ((b), (c), (d)) + (x) + (UINT4)(ac); \
//(a) = ROTATE_LEFT ((a), (s)); \
//(a) += (b); \
//}
   
   uint32 min = 0;
   uint32 max = 0xFFFFFFFF;
   uint32 cinmax = 0xFFFFFFFE;
   
   id<ORBitVar> T = [ORFactory bitVar:_m low:&t up:&t bitLength:32];
   
   id<ORBitVar> go = [self g:B y:C z:D];
   
   id<ORBitVar> t0a = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   id<ORBitVar> ci =  [ORFactory bitVar:_m low:&min up:&cinmax bitLength:32];
   id<ORBitVar> co =  [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   [_m add:[ORFactory bit:A plus:go withCarryIn:ci eq:t0a withCarryOut:co]];
   
   id<ORBitVar> t0 = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   ci =  [ORFactory bitVar:_m low:&min up:&cinmax bitLength:32];
   co =  [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   [_m add:[ORFactory bit:t0a plus:x[i] withCarryIn:ci eq:t0 withCarryOut:co]];
   
   id<ORBitVar> t1 = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   ci =  [ORFactory bitVar:_m low:&min up:&cinmax bitLength:32];
   co =  [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   [_m add:[ORFactory bit:t0 plus:T withCarryIn:ci eq:t1 withCarryOut:co]];
   
   id<ORBitVar> t2 = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   [_m add:[ORFactory bit:t1 rotateLBy:s eq:t2]];
   
   id<ORBitVar> t3 = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   ci =  [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   co =  [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   [_m add:[ORFactory bit:t2 plus:B withCarryIn:ci eq:t3 withCarryOut:co]];
   
   return t3;
}

-(id<ORBitVar>) shuffle3:(id<ORBitVar>)A b:(id<ORBitVar>)B c:(id<ORBitVar>)C d:(id<ORBitVar>) D index:(int)i shiftBy:(int) s x:(id<ORBitVar>*) x t:(uint32)t
{
//#define HH(a, b, c, d, x, s, ac) { \
//(a) += H ((b), (c), (d)) + (x) + (UINT4)(ac); \
//(a) = ROTATE_LEFT ((a), (s)); \
//(a) += (b); \
//}
   
   uint32 min = 0;
   uint32 max = 0xFFFFFFFF;
   uint32 cinmax = 0xFFFFFFFE;
   
   id<ORBitVar> T = [ORFactory bitVar:_m low:&t up:&t bitLength:32];
   
   id<ORBitVar> ho = [self h:B y:C z:D];
   
   id<ORBitVar> t0a = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   id<ORBitVar> ci =  [ORFactory bitVar:_m low:&min up:&cinmax bitLength:32];
   id<ORBitVar> co =  [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   [_m add:[ORFactory bit:A plus:ho withCarryIn:ci eq:t0a withCarryOut:co]];
   
   id<ORBitVar> t0 = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   ci =  [ORFactory bitVar:_m low:&min up:&cinmax bitLength:32];
   co =  [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   [_m add:[ORFactory bit:t0a plus:x[i] withCarryIn:ci eq:t0 withCarryOut:co]];
   
   id<ORBitVar> t1 = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   ci =  [ORFactory bitVar:_m low:&min up:&cinmax bitLength:32];
   co =  [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   [_m add:[ORFactory bit:t0 plus:T withCarryIn:ci eq:t1 withCarryOut:co]];
   
   id<ORBitVar> t2 = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   [_m add:[ORFactory bit:t1 rotateLBy:s eq:t2]];
   
   id<ORBitVar> t3 = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   ci =  [ORFactory bitVar:_m low:&min up:&cinmax bitLength:32];
   co =  [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   [_m add:[ORFactory bit:t2 plus:B withCarryIn:ci eq:t3 withCarryOut:co]];
   
   
   return t3;
}


-(id<ORBitVar>) shuffle4:(id<ORBitVar>)A b:(id<ORBitVar>)B c:(id<ORBitVar>)C d:(id<ORBitVar>) D index:(int)i shiftBy:(int) s x:(id<ORBitVar>*) x t:(uint32)t
{
//#define II(a, b, c, d, x, s, ac) { \
//(a) += I ((b), (c), (d)) + (x) + (UINT4)(ac); \
//(a) = ROTATE_LEFT ((a), (s)); \
//(a) += (b); \
//}
   
   uint32 min = 0;
   uint32 max = 0xFFFFFFFF;
   uint32 cinmax = 0xFFFFFFFE;
   
   id<ORBitVar> T = [ORFactory bitVar:_m low:&t up:&t bitLength:32];
   
   id<ORBitVar> io = [self i:B y:C z:D];
   
   id<ORBitVar> t0a = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   id<ORBitVar> ci =  [ORFactory bitVar:_m low:&min up:&cinmax bitLength:32];
   id<ORBitVar> co =  [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   [_m add:[ORFactory bit:A plus:io withCarryIn:ci eq:t0a withCarryOut:co]];
   
   id<ORBitVar> t0 = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   ci =  [ORFactory bitVar:_m low:&min up:&cinmax bitLength:32];
   co =  [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   [_m add:[ORFactory bit:t0a plus:x[i] withCarryIn:ci eq:t0 withCarryOut:co]];
   
   id<ORBitVar> t1 = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   ci =  [ORFactory bitVar:_m low:&min up:&cinmax bitLength:32];
   co =  [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   [_m add:[ORFactory bit:t0 plus:T withCarryIn:ci eq:t1 withCarryOut:co]];
   
   id<ORBitVar> t2 = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   [_m add:[ORFactory bit:t1 rotateLBy:s eq:t2]];
   
   id<ORBitVar> t3 = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   ci =  [ORFactory bitVar:_m low:&min up:&cinmax bitLength:32];
   co =  [ORFactory bitVar:_m low:&min up:&max bitLength:32];
   [_m add:[ORFactory bit:t2 plus:B withCarryIn:ci eq:t3 withCarryOut:co]];
   
   
   return t3;
}


@end

@implementation MD5Block
+(MD5Block*) initMD5Block:(id<ORModel>)m
{
   MD5Block* b = [[MD5Block alloc] initExplicitMD5Block:m];
   return b;
}
-(MD5Block*) initExplicitMD5Block:(id<ORModel>)m
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
      //      maskedUp = __builtin_bswap32(data[i] | ~ mask[i]);
      //      maskedLow = __builtin_bswap32(data[i] &  mask[i]);
      
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
