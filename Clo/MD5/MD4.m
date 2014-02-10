//
//  MD4.m
//  Clo
//
//  Created by Greg Johnson on 12/18/12.
//  Copyright (c) 2012 CSE. All rights reserved.
//

#import "MD4.h"
#import <time.h>

@implementation MD4
+(MD4*) initMD4{
   MD4* x = [[MD4 alloc]initExplicitMD4];
   return x;
}
//+(MD4*) initMD4:(id<ORModel>)m
//{
//   MD4* x = [[MD4 alloc] initExplicitMD4:m];
//   return x;
//}
//-(MD4*) initExplicitMD4:(id<ORModel>)m
//{
//   self = [super init];
//   _m = m;
//   return self;
//}

-(MD4*) initExplicitMD4
{
   self = [super init];
   _m = [ORFactory createModel];
//   _explorer = [_m ];
   return self;
}

-(void) dealloc
{
   [ORFactory shutdown];
   [super dealloc];
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
   NSLog(@"%s\n",(char*)_buffer);
   [fm dealloc];
   return true;
}

-(NSMutableArray*) getMD4Digest:(NSString*)fname //retrieves MD4 digest from system call to openssl
{
   NSTask *task = [[NSTask alloc] init];
   NSString *command = @"/usr/bin/openssl";
   NSString *param = [[NSMutableString alloc] initWithString:@"dgst"];
   NSMutableArray *params = [NSMutableArray arrayWithObject:param];
   param = @"-md4";
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


-(void) createMD4Blocks:(uint32*)mask
{
   uint64 blockLength;
   _numBlocks = floor((_messageLength+64)/512)+1;
   _messageBlocks = [[NSMutableArray alloc] initWithCapacity:_numBlocks];
   NSLog(@"%lld blocks\n",_numBlocks);
   for(int i=0;i<_numBlocks;i++)
   {
      blockLength = MIN(512, _messageLength - (i * 512));
      [self createMD4Block:&(_buffer[i*16]) withCount:blockLength andMask:mask];
   }
}

-(void) createMD4Block:(ORUInt*)data withCount:(uint64)count andMask:(uint32*)messageMask{
   uint64 numBits, numBytes;
   uint64 mask;
   ORUInt      paddedData[16];
   MD4Block* newBlock;
   
   if (count == 512) { //first or intermediate message block
      newBlock = [[MD4Block alloc] initExplicitMD4Block:_m];
      for(int i=0;i<16;i++)
         paddedData[i] = data[i];
      [newBlock setData:paddedData withMask:messageMask];
      [_messageBlocks addObject:newBlock];
   }
   else /* partial block -- must be last block so finish up */
   { /* Find out how many bytes and residual bits there are */
      numBytes = count >> 3;
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
         newBlock = [[MD4Block alloc] initExplicitMD4Block:_m];
//         NSLog(@"Padded Data: %s",(char*)XX);
//         NSLog(@"Padded Data: ");
//         for(int i = 0; i<64;i++) NSLog(@"%02x",((unsigned char*)XX)[i]);
         [newBlock setData:(uint32*)XX withMask:messageMask];
         [_messageBlocks addObject:newBlock];
      }
      else /* need to do two blocks to finish up */
      { newBlock = [[MD4Block alloc] initExplicitMD4Block:_m];
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
   [self getMD4Digest:filename];
   //get MD5 Blocks
   _temps = [[NSMutableArray alloc] initWithCapacity:128];
   [self createMD4Blocks:mask];
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
   
   
   id<CPProgram,CPBV> cp = (id)[ORFactory createCPProgram: _m];
   id<CPEngine> engine = [cp engine];
   id<ORExplorer> explorer = [cp explorer];
//   id<ORBasicModel> model = [engine model];
   
   //<<<<<<< HEAD
   //CPBitVarFF
   __block id* gamma = [cp gamma];
   
   NSLog(@"Message Blocks (Original)");
   id<ORBitVar>* bitVars;
   for(int i=0; i<_numBlocks;i++){
      bitVars = [[_messageBlocks objectAtIndex:i] getORVars];
      for(int j=0;j<16;j++)
         NSLog(@"%@\n",gamma[bitVars[j].getId]);
   }
   
//   NSArray* allvars = [model variables];
   
//   id<ORIdArray> o = [ORFactory idArray:[cp engine] range:[[ORIntRangeI alloc] initORIntRangeI:0 up:32]];
//   for(ORInt k=0;k <= 32;k++)
//      [o set:allvars[k] at:k];
   id<ORIdArray> o = [ORFactory idArray:[cp engine] range:[[ORIntRangeI alloc] initORIntRangeI:0 up:15]];
   for(ORInt k=0;k <= 15;k++)
      [o set:gamma[bitVars[k].getId] at:k];

//   __block ORUInt maxFail = 0x0000000000001000;

   id<CPBitVarHeuristic> h;
   switch (heur) {
      case BVABS: h = [cp createBitVarABS:(id<CPBitVarArray>)o];
         break;
      case BVIBS: h = [cp createBitVarIBS:(id<CPBitVarArray>)o];
         break;
      case BVFF:  h =[cp createBitVarFF:(id<CPBitVarArray>)o];
                  break;
   }
   
   [cp solve: ^{
//      NSLog(@"All variables before search:");
//      for (int i=0; i< [allvars count]; i++) {
//         NSLog(@"Model Variable[%i]: %@",i,allvars[i]);
//      }
//      NSLog(@"End all variables before search:");
      NSLog(@"Search");
      for(int i=0;i<4;i++)
      {
         NSLog(@"%@",gamma[digest[i].getId]);
         NSLog(@"%@\n\n",gamma[digestVars[i].getId]);
      }
      //      NSLog(@"Message Blocks (With Data Recovered)");
      clock_t searchStart = clock();
      //      [cp repeat:^{
      //         [cp limitFailures:maxFail
      //                        in:^{[cp labelBitVarHeuristic:h];}];}
      //        onRepeat:^{maxFail<<=1;NSLog(@"Restart");}];
      //[cp labelBitVarHeuristic:h];
      //      for (int i=0;i<16;i++)
      //         if (![gamma [bitVars[i].getId] bound]) {
      //            [cp labelOutFromMidFreeBit:gamma[bitVars[i].getId]];
      //         }
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
         case BVFF:
            [cp labelBitVarHeuristic:h];
            break;
            

         default: [cp labelBitVarHeuristic:h];
//               [cp repeat:^{
//                  [cp limitFailures:maxFail
//                                 in:^{[cp labelBitVarHeuristic:h];}];}
//                  onRepeat:^{maxFail= maxFail + (maxFail>>6);NSLog(@"Restart, %u",maxFail);}];
            break;
      }

      clock_t searchFinish = clock();
      
      for(int j=0;j<16;j++){
         NSLog(@"%@\n",gamma[bitVars[j].getId]);
         
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

//-(NSString*) preimage:(NSString*)filename withMask:(uint32*) mask andHeuristic:(BVSearchHeuristic)heur
//{
//   clock_t start;
//   NSMutableString *results = [NSMutableString stringWithString:@""];
//
//   id<ORBitVar>* digest;
//   id<ORBitVar>* digestVars = malloc(4*sizeof(id<ORBitVar>));
//   
//   [self getMessage:filename];
//   
//   start = clock();
//   
//   [self getMD4Digest:filename];
//   //get MD4 Blocks
//   _temps = [[NSMutableArray alloc] initWithCapacity:128];
//   [self createMD4Blocks:mask];
//   digest = [self stateModel];
//   uint32 *value = malloc(sizeof(uint32));
//   *value = __builtin_bswap32([[_digest objectAtIndex:0] unsignedIntValue]);
////   *value = [[_digest objectAtIndex:0] unsignedIntValue];
//   digestVars[0] = [ORFactory bitVar:_m low:value up:value bitLength:32];
//   value = malloc(sizeof(uint32));
//   *value = __builtin_bswap32([[_digest objectAtIndex:1] unsignedIntValue]);
////   *value = [[_digest objectAtIndex:1] unsignedIntValue];
//   digestVars[1] = [ORFactory bitVar:_m low:value up:value bitLength:32];
//   value = malloc(sizeof(uint32));
//   *value = __builtin_bswap32([[_digest objectAtIndex:2] unsignedIntValue]);
////   *value = [[_digest objectAtIndex:2] unsignedIntValue];
//   digestVars[2] = [ORFactory bitVar:_m low:value up:value bitLength:32];
//   value = malloc(sizeof(uint32));
//   *value = __builtin_bswap32([[_digest objectAtIndex:3] unsignedIntValue]);
////   *value = [[_digest objectAtIndex:3] unsignedIntValue];
//   digestVars[3] = [ORFactory bitVar:_m low:value up:value bitLength:32];
//   
//   [_m add:[ORFactory bit:digest[0] eq:digestVars[0]]];
//   [_m add:[ORFactory bit:digest[1] eq:digestVars[1]]];
//   [_m add:[ORFactory bit:digest[2] eq:digestVars[2]]];
//   [_m add:[ORFactory bit:digest[3] eq:digestVars[3]]];
//   
//   
//   id<CPProgram,CPBV> cp = (id)[ORFactory createCPProgram: _m];
//   id<CPEngine> engine = [cp engine];
//   id<ORExplorer> explorer = [cp explorer];
//   
//   [cp solve: ^() {
//      @try {
////         NSLog(@"Digest Variables:\n");
////         for(int i=0;i<4;i++)
////         {
////            NSLog(@"%@",digest[i]);
////            NSLog(@"%@\n\n",digestVars[i]);
////         }
////         NSLog(@"Message Blocks (Original)");
////         id<ORBitVar>* bitVars;
////         for(int i=0; i<_numBlocks;i++){
////            bitVars = [[_messageBlocks objectAtIndex:i] getORVars];
////            for(int j=0;j<16;j++)
////               NSLog(@"%@\n",bitVars[j]);
////         }
////         NSLog(@"Message Blocks (With Data Recovered)");
//         id<ORBitVar>* bitVars;
//         clock_t searchStart = clock();
//         for(int i=0; i<_numBlocks;i++){
//            bitVars = [[_messageBlocks objectAtIndex:i] getORVars];
//            for(int j=0;j<16;j++){
//               NSLog(@"%@\n",bitVars[j]);
//            }
//            for(int j=0;j<16;j++){
//               [cp labelUpFromLSB:bitVars[j]];
////               NSLog(@"%@\n",bitVars[j]);
//            }
//         }
//         clock_t searchFinish = clock();
//         
////         NSLog(@"\n\n\n\n\n\n\n\n\n\nDigest Variables:\n");
////         NSDate *searchStart = [NSDate date];
////         for(int i=0;i<4;i++)
////         {
////            [cp labelUpFromLSB:digest[i]];
////         }
////         for(int i=0;i<4;i++)
////         {
////            NSLog(@"%@",digest[i]);
////            NSLog(@"%@\n\n",digestVars[i]);
////         }
//         double totalTime, searchTime;
//         totalTime =((double)(searchFinish - start))/CLOCKS_PER_SEC;
//         searchTime = ((double)(searchFinish - searchStart))/CLOCKS_PER_SEC;
//         
//         NSString *str = [NSString stringWithFormat:@",%d,%d,%d,%f,%f\n",[explorer nbChoices],[explorer nbFailures],[engine nbPropagation],searchTime,totalTime];
//         [results appendString:str];
//         
//         NSLog(@"Number propagations: %d",[engine nbPropagation]);
//         NSLog(@"     Number choices: %d",[explorer nbChoices]);
//         NSLog(@"    Number Failures: %d", [explorer nbFailures]);
//         NSLog(@"    Search Time (s): %f",searchTime);
//         NSLog(@"     Total Time (s): %f\n\n",totalTime);
//         
//      }
//      @catch (NSException *exception) {
//         
//         NSLog(@"[MD4 preimage] Caught %@: %@", [exception name], [exception reason]);
//         
//      }
//   }];
//   return results;
//}
-(id<ORBitVar>*) stateModel
{
   uint32 *I0 = alloca(sizeof(uint32));
   uint32 *I1 = alloca(sizeof(uint32));
   uint32 *I2 = alloca(sizeof(uint32));
   uint32 *I3 = alloca(sizeof(uint32));
   
   *I0 = 0x67452301;
   *I1 = 0xefcdab89;
   *I2 = 0x98badcfe;
   *I3 = 0x10325476;
   

   id<ORBitVar> *h0 = malloc(4*sizeof(id<ORBitVar>));
   id<ORBitVar> *h4 = malloc(4*sizeof(id<ORBitVar>));

   h0[0] = [ORFactory bitVar:_m low:I0 up:I0 bitLength:32];
   h0[1] = [ORFactory bitVar:_m low:I1 up:I1 bitLength:32];
   h0[2] = [ORFactory bitVar:_m low:I2 up:I2 bitLength:32];
   h0[3] = [ORFactory bitVar:_m low:I3 up:I3 bitLength:32];
   
   for(int i=0; i<_numBlocks;i++) {
      MD4Block* b = [_messageBlocks objectAtIndex:i];

      id<ORBitVar> *msg = [b getORVars];
      id<ORBitVar> *h1 = [self round1:h0 x:msg];
      id<ORBitVar> *h2 = [self round2:h1 x:msg];
      id<ORBitVar> *h3 = [self round3:h2 x:msg];
      
      uint32 min = 0;
      uint32 max = 0xFFFFFFFF;
      uint32 cinmax = 0xFFFFFFFE;

      id<ORBitVar> cin;
      id<ORBitVar> cout;
      h4[0] = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
      h4[1] = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
      h4[2] = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
      h4[3] = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
      
      //forall(i in 0..3) _m.post(h4[i] == h0[i] + h3[i]);
      for (int i=0; i<4; i++)
      {
         cin = [ORFactory bitVar:_m low:&min up:&cinmax bitLength:32];
         cout = [ORFactory bitVar:_m low:&min up:&max bitLength:32];
         [_m add:[ORFactory bit:h0[i] plus:h3[i] withCarryIn:cin eq:h4[i] withCarryOut:cout]];
      }
      h0 = h4;
    }
      
   return h0;
}

-(id<ORBitVar>) f:(id<ORBitVar>)x y:(id<ORBitVar>)y z:(id<ORBitVar>)z
{
   uint32 *min = alloca(sizeof(uint32));
   uint32 *max = alloca(sizeof(uint32));
   
   *min = 0;
   *max = 0xFFFFFFFF;
   
   id<ORBitVar> t0 = [ORFactory bitVar:_m low:min up:max bitLength:32];
   id<ORBitVar> t1 = [ORFactory bitVar:_m low:min up:max bitLength:32];
   id<ORBitVar> t2 = [ORFactory bitVar:_m low:min up:max bitLength:32];
   id<ORBitVar> t3 = [ORFactory bitVar:_m low:min up:max bitLength:32];
   //_m.post(BitAnd<CP>(x,y,t0));
   [_m add:[ORFactory bit:x and:y eq:t0]];
   //_m.post(BitNegate<CP>(x,t1));
   [_m add:[ORFactory bit:x not:t1]];
   //_m.post(BitAnd<CP>(t1,z,t2));
   [_m add:[ORFactory bit:t1 and:z eq:t2]];
   //_m.post(BitOr<CP>(t0,t2,t3));
   [_m add:[ORFactory bit:t0 or:t2 eq:t3]];
   //[_temps addObject:t3];
   return t3;
}
-(id<ORBitVar>) g:(id<ORBitVar>)x y:(id<ORBitVar>)y z:(id<ORBitVar>)z
{
   uint32 *min = alloca(sizeof(uint32));
   uint32 *max = alloca(sizeof(uint32));
   
   *min = 0;
   *max = 0xFFFFFFFF;
   
   id<ORBitVar> t0 = [ORFactory bitVar:_m low:min up:max bitLength:32];
   id<ORBitVar> t1 = [ORFactory bitVar:_m low:min up:max bitLength:32];
   id<ORBitVar> t2 = [ORFactory bitVar:_m low:min up:max bitLength:32];
   id<ORBitVar> t3 = [ORFactory bitVar:_m low:min up:max bitLength:32];
   id<ORBitVar> t4 = [ORFactory bitVar:_m low:min up:max bitLength:32];
//   _m.post(BitAnd<CP>(x,y,t0));
   [_m add:[ORFactory bit:x and:y eq:t0]];
//   _m.post(BitAnd<CP>(x,z,t1));
   [_m add:[ORFactory bit:x and:z eq:t1]];
//   _m.post(BitAnd<CP>(y,z,t2));
   [_m add:[ORFactory bit:y and:z eq:t2]];
//   _m.post(BitOr<CP>(t0,t1,t3));
   [_m add:[ORFactory bit:t0 or:t1 eq:t3]];
//   _m.post(BitOr<CP>(t2,t3,t4));
   [_m add:[ORFactory bit:t2 or:t3 eq:t4]];
   //[_temps addObject:t4];
   return t4;
}
-(id<ORBitVar>) h:(id<ORBitVar>)x y:(id<ORBitVar>)y z:(id<ORBitVar>)z
{
   uint32 *min = alloca(sizeof(uint32));
   uint32 *max = alloca(sizeof(uint32));
   
   *min = 0;
   *max = 0xFFFFFFFF;
   
id<ORBitVar> t0 = [ORFactory bitVar:_m low:min up:max bitLength:32];
id<ORBitVar> t1 = [ORFactory bitVar:_m low:min up:max bitLength:32];
   //_m.post(BitXor<CP>(x,y,t0));
   [_m add:[ORFactory bit:x xor:y eq:t0]];
   //_m.post(BitXor<CP>(t0,z,t1));
   [_m add:[ORFactory bit:t0 xor:z eq:t1]];
   //[_temps addObject:t1];
   return t1;
}

-(id<ORBitVar>*) round1:(id<ORBitVar>*)h x:(id<ORBitVar>*) x
   {
      // [A B C D 0 3]
      // [D A B C 1 7]
      // [C D A B 2 11]
      // [B C D A 3 19]
      // [A B C D 4 3]
      // [D A B C 5 7]
      // [C D A B 6 11]
      // [B C D A 7 19]
      // [A B C D 8 3]
      // [D A B C 9 7]
      // [C D A B 10 11]
      // [B C D A 11 19]
      // [A B C D 12 3]
      // [D A B C 13 7]
      // [C D A B 14 11]
      // [B C D A 15 19]
      id<ORBitVar> A = h[0];
      id<ORBitVar> B = h[1];
      id<ORBitVar> C = h[2];
      id<ORBitVar> D = h[3];
      
      //[self shuffle1: b: c: d: index: shiftBy: x:x];
      A = [self shuffle1:A b:B c:C d:D index:0 shiftBy:3 x:x];   // [A B C D 0 3]
      D = [self shuffle1:D b:A c:B d:C index:1 shiftBy:7 x:x];  // [D A B C 1 7]
      C = [self shuffle1:C b:D c:A d:B index:2 shiftBy:11 x:x];  // [C D A B 2 11]
      B = [self shuffle1:B b:C c:D d:A index:3 shiftBy:19 x:x];  // [B C D A 3 19]
      
      A = [self shuffle1:A b:B c:C d:D index:4 shiftBy:3 x:x];  // [A B C D 4 3]
      D = [self shuffle1:D b:A c:B d:C index:5 shiftBy:7 x:x];  // [D A B C 5 7]
      C = [self shuffle1:C b:D c:A d:B index:6 shiftBy:11 x:x];  // [C D A B 6 11]
      B = [self shuffle1:B b:C c:D d:A index:7 shiftBy:19 x:x];  // [B C D A 7 19]
      
      A = [self shuffle1:A b:B c:C d:D index:8 shiftBy:3 x:x];  // [A B C D 8 3]
      D = [self shuffle1:D b:A c:B d:C index:9 shiftBy:7 x:x];  // [D A B C 9 7]
      C = [self shuffle1:C b:D c:A d:B index:10 shiftBy:11 x:x];  // [C D A B 10 11]
      B = [self shuffle1:B b:C c:D d:A index:11 shiftBy:19 x:x];  // [B C D A 11 19]
      
      A = [self shuffle1:A b:B c:C d:D index:12 shiftBy:3 x:x];  // [A B C D 12 3]
      D = [self shuffle1:D b:A c:B d:C index:13 shiftBy:7 x:x];  // [D A B C 13 7]
      C = [self shuffle1:C b:D c:A d:B index:14 shiftBy:11 x:x];  // [C D A B 14 11]
      B = [self shuffle1:B b:C c:D d:A index:15 shiftBy:19 x:x];  // [B C D A 15 19]
      id<ORBitVar> *nh = malloc(4*sizeof(id<ORBitVar>));
      nh[0] = A;
      nh[1] = B;
      nh[2] = C;
      nh[3] = D;
      return(nh);
   }
   
-(id<ORBitVar>*)round2:(id<ORBitVar>*)h x:(id<ORBitVar>*) x
   {
      //[A B C D 0  3]
      //[D A B C 4  5]
      //[C D A B 8  9]
      //[B C D A 12 13]
      //[A B C D 1  3]
      //[D A B C 5  5]
      //[C D A B 9  9]
      //[B C D A 13 13]
      //[A B C D 2  3]
      //[D A B C 6  5]
      //[C D A B 10 9]
      //[B C D A 14 13]
      //[A B C D 3  3]
      //[D A B C 7  5]
      //[C D A B 11 9]
      //[B C D A 15 13]
      id<ORBitVar> A = h[0];
      id<ORBitVar> B = h[1];
      id<ORBitVar> C = h[2];
      id<ORBitVar> D = h[3];
      A = [self shuffle2:A b:B c:C d:D index:0 shiftBy:3 x:x];//[A B C D 0  3]
      D = [self shuffle2:D b:A c:B d:C index:4 shiftBy:5 x:x];//[D A B C 4  5]
      C = [self shuffle2:C b:D c:A d:B index:8 shiftBy:9 x:x];//[C D A B 8  9]
      B = [self shuffle2:B b:C c:D d:A index:12 shiftBy:13 x:x];//[B C D A 12 13]
      
      A = [self shuffle2:A b:B c:C d:D index:1 shiftBy:3 x:x];//[A B C D 1  3]
      D = [self shuffle2:D b:A c:B d:C index:5 shiftBy:5 x:x];//[D A B C 5  5]
      C = [self shuffle2:C b:D c:A d:B index:9 shiftBy:9 x:x];//[C D A B 9  9]
      B = [self shuffle2:B b:C c:D d:A index:13 shiftBy:13 x:x];//[B C D A 13 13]
      
      A = [self shuffle2:A b:B c:C d:D index:2 shiftBy:3 x:x];//[A B C D 2  3]
      D = [self shuffle2:D b:A c:B d:C index:6 shiftBy:5 x:x];//[D A B C 6  5]
      C = [self shuffle2:C b:D c:A d:B index:10 shiftBy:9 x:x];//[C D A B 10 9]
      B = [self shuffle2:B b:C c:D d:A index:14 shiftBy:13 x:x];//[B C D A 14 13]
      
      A = [self shuffle2:A b:B c:C d:D index:3 shiftBy:3 x:x];//[A B C D 3  3]
      D = [self shuffle2:D b:A c:B d:C index:7 shiftBy:5 x:x];//[D A B C 7  5]
      C = [self shuffle2:C b:D c:A d:B index:11 shiftBy:9 x:x];//[C D A B 11 9]
      B = [self shuffle2:B b:C c:D d:A index:15 shiftBy:13 x:x];//[B C D A 15 13]
       
//      cout << "end of round 2:" << endl;
//      cout << "\t:" << A.getId() << endl;
//      cout << "\t:" << B.getId() << endl;
//      cout << "\t:" << C.getId() << endl;
//      cout << "\t:" << D.getId() << endl;
      
      id<ORBitVar> *nh = malloc(4*sizeof(id<ORBitVar>));
      nh[0] = A;
      nh[1] = B;
      nh[2] = C;
      nh[3] = D;
      return(nh);
   }
-(id<ORBitVar>*) round3:(id<ORBitVar>*)h x:(id<ORBitVar>*) x
   {
//      return h;
      //[A B C D 0  3]
      //[D A B C 8  9]
      //[C D A B 4  11]
      //[B C D A 12 15]
      //[A B C D 2  3]
      //[D A B C 10 9]
      //[C D A B 6  11]
      //[B C D A 14 15]
      //[A B C D 1  3]
      //[D A B C 9  9]
      //[C D A B 5  11]
      //[B C D A 13 15]
      //[A B C D 3  3]
      //[D A B C 11 9]
      //[C D A B 7  11]
      //[B C D A 15 15]
      id<ORBitVar> A = h[0];
      id<ORBitVar> B = h[1];
      id<ORBitVar> C = h[2];
      id<ORBitVar> D = h[3];
      A = [self shuffle3:A b:B c:C d:D index:0 shiftBy:3 x:x];//[A B C D 0  3]  //33
      D = [self shuffle3:D b:A c:B d:C index:8 shiftBy:9 x:x];//[D A B C 8  9]
      C = [self shuffle3:C b:D c:A d:B index:4 shiftBy:11 x:x];//[C D A B 4  11]
      B = [self shuffle3:B b:C c:D d:A index:12 shiftBy:15 x:x];//[B C D A 12 15]

      A = [self shuffle3:A b:B c:C d:D index:2 shiftBy:3 x:x];//[A B C D 2  3]
      D = [self shuffle3:D b:A c:B d:C index:10 shiftBy:9 x:x];//[D A B C 10 9]
      C = [self shuffle3:C b:D c:A d:B index:6 shiftBy:11 x:x];//[C D A B 6  11]
      B = [self shuffle3:B b:C c:D d:A index:14 shiftBy:15 x:x];//[B C D A 14 15]
      
      A = [self shuffle3:A b:B c:C d:D index:1 shiftBy:3 x:x];//[A B C D 1  3]
      D = [self shuffle3:D b:A c:B d:C index:9 shiftBy:9 x:x];//[D A B C 9  9]
      C = [self shuffle3:C b:D c:A d:B index:5 shiftBy:11 x:x];//[C D A B 5  11]
      B = [self shuffle3:B b:C c:D d:A index:13 shiftBy:15 x:x];//[B C D A 13 15]
      
      A = [self shuffle3:A b:B c:C d:D index:3 shiftBy:3 x:x];//[A B C D 3  3]
      D = [self shuffle3:D b:A c:B d:C index:11 shiftBy:9 x:x];//[D A B C 11 9]
      C = [self shuffle3:C b:D c:A d:B index:7 shiftBy:11 x:x];//[C D A B 7  11]
      B = [self shuffle3:B b:C c:D d:A index:15 shiftBy:15 x:x];//[B C D A 15 15]
      //     [self shuffle3: b: c: d: index: shiftBy: x:];
      id<ORBitVar> *nh = malloc(4*sizeof(id<ORBitVar>));
      nh[0] = A;
      nh[1] = B;
      nh[2] = C;
      nh[3] = D;
      return(nh);
   }


-(id<ORBitVar>) shuffle1:(id<ORBitVar>)A b:(id<ORBitVar>)B c:(id<ORBitVar>)C d:(id<ORBitVar>) D index:(int)i shiftBy:(int) s x:(id<ORBitVar>*) x
{
   uint32 *min = alloca(sizeof(uint32));
   uint32 *max = alloca(sizeof(uint32));
   uint32 *cinmax = alloca(sizeof(uint32));
   
   *min = 0;
   *max = 0xFFFFFFFF;
   *cinmax = 0xFFFFFFFE;
   
//   NSLog(@"Shuffle1\n");
   // A = (A + f(B,C,D) + X[i]) <<< s
   id<ORBitVar> fo = [self f:B y:C z:D];
   [_temps addObject:A];
   [_temps addObject:fo];
   [_temps addObject:x[i]];

   
// t0 = A + fo + x[i];
   id<ORBitVar> t0a = [ORFactory bitVar:_m low:min up:max bitLength:32];
//      *max = 0xFFFFFFFF;
   id<ORBitVar> ci =  [ORFactory bitVar:_m low:min up:cinmax bitLength:32];
//      *max = 0xFFFFFFFF;
   id<ORBitVar> co =  [ORFactory bitVar:_m low:min up:max bitLength:32];
   [_m add:[ORFactory bit:A plus:fo withCarryIn:ci eq:t0a withCarryOut:co]];
   id<ORBitVar> t0 = [ORFactory bitVar:_m low:min up:max bitLength:32];
//      *max = 0xFFFFFFFF;
   id<ORBitVar> ci0 =  [ORFactory bitVar:_m low:min up:max bitLength:32];
//      *max = 0xFFFFFFFF;
   id<ORBitVar> co0 =  [ORFactory bitVar:_m low:min up:max bitLength:32];
   [_m add:[ORFactory bit:t0a plus:x[i] withCarryIn:ci0 eq:t0 withCarryOut:co0]];

   id<ORBitVar> t1 = [ORFactory bitVar:_m low:min up:max bitLength:32];
   //_m.post(BitRotateLeft<CP>(t0,s,t1));
   [_m add:[ORFactory bit:t0 rotateLBy:s eq:t1]];
   return t1;
}

-(id<ORBitVar>) shuffle2:(id<ORBitVar>)A b:(id<ORBitVar>)B c:(id<ORBitVar>)C d:(id<ORBitVar>) D index:(int)i shiftBy:(int) s x:(id<ORBitVar>*) x
{
   uint32 *min = alloca(sizeof(uint32));
   uint32 *max = alloca(sizeof(uint32));
   uint32 *cinmax = alloca(sizeof(uint32));
   
//   NSLog(@"Shuffle2\n");
   // A = (A + g(B,C,D) + X[i] + 5A827999) <<< s
   id<ORBitVar> go = [self g:B y:C z:D];
   *min = *max = 0x5A827999;
   id<ORBitVar> t0 = [ORFactory bitVar:_m low:min up:max bitLength:32];
   *min = 0;
   *max = 0xFFFFFFFF;
   *cinmax = 0xFFFFFFFE;
   
//id<ORBitVar> t1 = A + go + x[i] + t0;
   id<ORBitVar> t1a = [ORFactory bitVar:_m low:min up:max bitLength:32];
      *max = 0xFFFFFFFE;
   id<ORBitVar> ci =  [ORFactory bitVar:_m low:min up:cinmax bitLength:32];
      *max = 0xFFFFFFFF;
   id<ORBitVar> co =  [ORFactory bitVar:_m low:min up:max bitLength:32];
   [_m add:[ORFactory bit:A plus:go withCarryIn:ci eq:t1a withCarryOut:co]];
   id<ORBitVar> t1b = [ORFactory bitVar:_m low:min up:max bitLength:32];
      *max = 0xFFFFFFFE;
   ci =  [ORFactory bitVar:_m low:min up:cinmax bitLength:32];
      *max = 0xFFFFFFFF;
   co =  [ORFactory bitVar:_m low:min up:max bitLength:32];
   [_m add:[ORFactory bit:t1a plus:x[i] withCarryIn:ci eq:t1b withCarryOut:co]];
   id<ORBitVar> t1 = [ORFactory bitVar:_m low:min up:max bitLength:32];
      *max = 0xFFFFFFFE;
   ci =  [ORFactory bitVar:_m low:min up:cinmax bitLength:32];
      *max = 0xFFFFFFFF;
   co =  [ORFactory bitVar:_m low:min up:max bitLength:32];
   [_m add:[ORFactory bit:t1b plus:t0 withCarryIn:ci eq:t1 withCarryOut:co]];
   id<ORBitVar> t2=[ORFactory bitVar:_m low:min up:max bitLength:32];
   //_m.post(BitRotateLeft<CP>(t1,s,t2));
   [_m add:[ORFactory bit:t1 rotateLBy:s eq:t2]];
   return t2;
}

-(id<ORBitVar>) shuffle3:(id<ORBitVar>)A b:(id<ORBitVar>)B c:(id<ORBitVar>)C d:(id<ORBitVar>) D index:(int)i shiftBy:(int) s x:(id<ORBitVar>*) x
{
   uint32 *min = alloca(sizeof(uint32));
   uint32 *max = alloca(sizeof(uint32));
   uint32 *cinmax = alloca(sizeof(uint32));
   
//   NSLog(@"Shuffle3\n");
   //A = (A + h(B,C,D) + X[i] + 6ED9EBA1) <<< s
   id<ORBitVar> ho = [self h:B y:C z:D];
   *min = *max = 0x6ED9EBA1;
   id<ORBitVar> t0 = [ORFactory bitVar:_m low:min up:max bitLength:32];
   *min = 0;
   *max = 0xFFFFFFFF;
   *cinmax = 0xFFFFFFFE;
   //   t1 = A + ho + x[i] + t0;
   id<ORBitVar> t1a = [ORFactory bitVar:_m low:min up:max bitLength:32];
      *max = 0xFFFFFFFE;
   id<ORBitVar> ci =  [ORFactory bitVar:_m low:min up:cinmax bitLength:32];
      *max = 0xFFFFFFFF;
   id<ORBitVar> co =  [ORFactory bitVar:_m low:min up:max bitLength:32];
   [_m add:[ORFactory bit:A plus:ho withCarryIn:ci eq:t1a withCarryOut:co]];
   id<ORBitVar> t1b = [ORFactory bitVar:_m low:min up:max bitLength:32];
      *max = 0xFFFFFFFE;
   ci =  [ORFactory bitVar:_m low:min up:cinmax bitLength:32];
      *max = 0xFFFFFFFF;
   co =  [ORFactory bitVar:_m low:min up:max bitLength:32];
   [_m add:[ORFactory bit:t1a plus:x[i] withCarryIn:ci eq:t1b withCarryOut:co]];
   id<ORBitVar> t1 = [ORFactory bitVar:_m low:min up:max bitLength:32];
//      *max = 0xFFFFFFFE;
   ci =  [ORFactory bitVar:_m low:min up:cinmax bitLength:32];
//      *max = 0xFFFFFFFF;
   co =  [ORFactory bitVar:_m low:min up:max bitLength:32];
   [_m add:[ORFactory bit:t1b plus:t0 withCarryIn:ci eq:t1 withCarryOut:co]];
   
   id<ORBitVar> t2 = [ORFactory bitVar:_m low:min up:max bitLength:32];
   //_m.post(BitRotateLeft<CP>(t1,s,t2));
   [_m add:[ORFactory bit:t1 rotateLBy:s eq:t2]];

   return t2;
}
@end
   
@implementation MD4Block
+(MD4Block*) initMD4Block:(id<ORModel>)m
{
   MD4Block* b = [[MD4Block alloc] initExplicitMD4Block:m];
   return b;
}
-(MD4Block*) initExplicitMD4Block:(id<ORModel>)m
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
      
//      maskedUp = data[i];
//      maskedLow = data[i];
//      _data[i] = maskedData;
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
