#import <ORProgram/ORProgram.h>
#import <objcp/CPFactory.h>
#import <objcp/CPConstraint.h>
#import <objcp/CPIntVarI.h>
#import <objcp/CPBitVar.h>
#import <objcp/CPBitVarI.h>
#define EXPECTKEY
#define KNOWNKEYS 11

uint32 s[256] = {0x63 ,0x7c ,0x77 ,0x7b ,0xf2 ,0x6b ,0x6f ,0xc5 ,0x30 ,0x01 ,0x67 ,0x2b ,0xfe ,0xd7 ,0xab ,0x76
   ,0xca ,0x82 ,0xc9 ,0x7d ,0xfa ,0x59 ,0x47 ,0xf0 ,0xad ,0xd4 ,0xa2 ,0xaf ,0x9c ,0xa4 ,0x72 ,0xc0
   ,0xb7 ,0xfd ,0x93 ,0x26 ,0x36 ,0x3f ,0xf7 ,0xcc ,0x34 ,0xa5 ,0xe5 ,0xf1 ,0x71 ,0xd8 ,0x31 ,0x15
   ,0x04 ,0xc7 ,0x23 ,0xc3 ,0x18 ,0x96 ,0x05 ,0x9a ,0x07 ,0x12 ,0x80 ,0xe2 ,0xeb ,0x27 ,0xb2 ,0x75
   ,0x09 ,0x83 ,0x2c ,0x1a ,0x1b ,0x6e ,0x5a ,0xa0 ,0x52 ,0x3b ,0xd6 ,0xb3 ,0x29 ,0xe3 ,0x2f ,0x84
   ,0x53 ,0xd1 ,0x00 ,0xed ,0x20 ,0xfc ,0xb1 ,0x5b ,0x6a ,0xcb ,0xbe ,0x39 ,0x4a ,0x4c ,0x58 ,0xcf
   ,0xd0 ,0xef ,0xaa ,0xfb ,0x43 ,0x4d ,0x33 ,0x85 ,0x45 ,0xf9 ,0x02 ,0x7f ,0x50 ,0x3c ,0x9f ,0xa8
   ,0x51 ,0xa3 ,0x40 ,0x8f ,0x92 ,0x9d ,0x38 ,0xf5 ,0xbc ,0xb6 ,0xda ,0x21 ,0x10 ,0xff ,0xf3 ,0xd2
   ,0xcd ,0x0c ,0x13 ,0xec ,0x5f ,0x97 ,0x44 ,0x17 ,0xc4 ,0xa7 ,0x7e ,0x3d ,0x64 ,0x5d ,0x19 ,0x73
   ,0x60 ,0x81 ,0x4f ,0xdc ,0x22 ,0x2a ,0x90 ,0x88 ,0x46 ,0xee ,0xb8 ,0x14 ,0xde ,0x5e ,0x0b ,0xdb
   ,0xe0 ,0x32 ,0x3a ,0x0a ,0x49 ,0x06 ,0x24 ,0x5c ,0xc2 ,0xd3 ,0xac ,0x62 ,0x91 ,0x95 ,0xe4 ,0x79
   ,0xe7 ,0xc8 ,0x37 ,0x6d ,0x8d ,0xd5 ,0x4e ,0xa9 ,0x6c ,0x56 ,0xf4 ,0xea ,0x65 ,0x7a ,0xae ,0x08
   ,0xba ,0x78 ,0x25 ,0x2e ,0x1c ,0xa6 ,0xb4 ,0xc6 ,0xe8 ,0xdd ,0x74 ,0x1f ,0x4b ,0xbd ,0x8b ,0x8a
   ,0x70 ,0x3e ,0xb5 ,0x66 ,0x48 ,0x03 ,0xf6 ,0x0e ,0x61 ,0x35 ,0x57 ,0xb9 ,0x86 ,0xc1 ,0x1d ,0x9e
   ,0xe1 ,0xf8 ,0x98 ,0x11 ,0x69 ,0xd9 ,0x8e ,0x94 ,0x9b ,0x1e ,0x87 ,0xe9 ,0xce ,0x55 ,0x28 ,0xdf
   ,0x8c ,0xa1 ,0x89 ,0x0d ,0xbf ,0xe6 ,0x42 ,0x68 ,0x41 ,0x99 ,0x2d ,0x0f ,0xb0 ,0x54 ,0xbb ,0x16};


uint32 expect_key[] = {197,79,167,90,39,16,175,2,233,69,53,43,101,2,108,155};


//Function Prototypes


void XOR(id<ORIdArray> ca, id<ORModel> model, id<ORBitVar> a, id<ORBitVar> b, id<ORBitVar> outt);
void XORThree(id<ORIdArray> ca, id<ORModel> model, id<ORBitVar> a, id<ORBitVar> b, id<ORBitVar> c, id<ORBitVar> outt);
void XORFour(id<ORIdArray> ca, id<ORModel> model, id<ORBitVar> a, id<ORBitVar> b, id<ORBitVar> c, id<ORBitVar> d, id<ORBitVar> outt);
void XORFour32(id<ORIdArray> ca, id<ORModel> model, id<ORBitVar> a, id<ORBitVar> b, id<ORBitVar> c, id<ORBitVar> d, id<ORBitVar> outt);
void sbox(id<ORIdArray> ca, id<ORModel> model, id<ORBitVar> b1, id<ORBitVar> b2);
void SideChannel(id<ORBitVar> x, int sc);
void xtimes(id<ORBitVar> a, id<ORBitVar> b);
void keyExpansion();
void addRoundKey();
void shiftRows();
void mixColumns();
void subBytes();
void sideChannelCon();

//Global Variables
id<ORModel> model;
id<ORIdArray> ca;
id<ORRealVar> y;
id<ORBitVar> states [5][16];
//id<ORIntVar> error[10][16][2];
id<ORBitVar> rcon[10];
id<ORBitVar> keys[11][16];
id<ORBitVar> tm1[1][4][4];
id<ORBitVar> tm2[1][4][4];
id<ORBitVar> tm0[1][4];
id<ORBitVar> sboxout[256];
id<ORIdArray> sboxBV;

id<ORIntVar> errorPtr[320];
uint32 MIN8 = 0x00000000;
uint32 MAX8 = 0x000000FF;
uint32 MIN32 = 0x00000000;
uint32 MAX32 = 0xFFFFFFFF;
ORInt error_count;
uint32 i_xor1b = 0x1B;
id<ORBitVar> xor1b;
int s_SC[64];
UInt32 num_checks = 0;

int main(int argc, const char * argv[]) {
   
   model = [ORFactory createModel];
   ca = NULL;
   
   xor1b = [ORFactory bitVar:model low:&i_xor1b up:&i_xor1b bitLength:8];
   
   
   uint32 rconstant[] = {1,2,4,8,16,32,64,128,27,54};
   
   uint32 Plaintext[] = {197,174,245,236,70,202,43,217,26,99,198,174,222,3,132,138};
   
   uint32 cipher[] = {176,88,179,224,18,226,231,218,39,76,161,2,20,119,14,183};
   
   //uint32 cipher2[] = {4,79,253,149,226,60,238,192,17,123,136,192,248,95,102,123};
   
   int totalstates = 0;
   
   error_count = 0;
   
   //Initial Sbox variables
   for(ORInt w = 0; w < 256; w++){
      sboxout[w] = [ORFactory bitVar: model low: &s[w] up: &s[w] bitLength :8];
   }
   
   sboxBV = [ORFactory idArray:model range:[[ORIntRangeI alloc] initORIntRangeI:0 up:255]];
   
   for(ORInt k=0;k < 256;k++){
      [sboxBV set:sboxout[k] at:k];
      
      
   }
   
   //Initial State variables set to plaintext values
   for(int w = 0; w < 16; w++)
      states[0][w] = [ORFactory bitVar: model low :&Plaintext[w] up :&Plaintext[w] bitLength :8];
   
   //Initialize the remaining State variables
   
   for(int i = 1; i < 5; i++){
      for(int w = 0; w < 16; w++)
         states[i][w] = [ORFactory bitVar: model low :&MIN8 up :&MAX8 bitLength :8];
   }
   /*
    for(int i = 4; i < 5; i++){
    for(int w = 0; w < 16; w++)
    states[i][w] = [ORFactory bitVar: model low :&cipher[w] up :&cipher[w] bitLength :8];
    }
    */
   printf("States Variables: %d\n",totalstates);
   
   //    totalstates=0;
   //    for(int i = 0; i < 10; i++)
   //        for(int j = 0; j < 16; j++)
   //            for(int z = 0; z < 2; z++){
   //                error[i][j][z] = [ORFactory intVar: model bounds: [ORFactory intRange: model low: 0 up: 1]];
   //                totalstates++;
   //            }
   
   totalstates = 0;
   
#ifdef EXPECTKEY
   for(int i = 0; i < 1; i++){ //i < 10
      for(int w = 0; w < 16; w++)
         if(w < KNOWNKEYS)
            keys[i][w] = [ORFactory bitVar: model low :&expect_key[w] up :&expect_key[w] bitLength :8];
         else
            keys[i][w] = [ORFactory bitVar: model low :&MIN8 up :&MAX8 bitLength :8];
   }
#endif
   
   /*
    for(int i = 0; i < 1; i++){ //i < 10
    for(int w = 0; w < 16; w++)
    keys[i][w] = [ORFactory bitVar: model low :&expect_key[w] up :&expect_key[w] bitLength :8];
    
    }
    */
   for(int i = 1; i < 2; i++){ //i < 10
      for(int w = 0; w < 16; w++)
         keys[i][w] = [ORFactory bitVar: model low :&MIN8 up :&MAX8 bitLength :8];
      
   }
   
   printf("Keys Variables: %d\n",totalstates);
   
   totalstates = 0;
   for(int r = 0; r < 10; r++){
      rcon[r] = [ORFactory bitVar: model low :&rconstant[r] up :&rconstant[r] bitLength :8];
      totalstates++;
   }
   
   printf("RCon Variables: %d\n",totalstates);
   
   totalstates = 0;
   for(ORInt r = 0; r < 1; r++){
      for(ORInt m = 0; m < 4; m++){
         for(ORInt l = 0; l < 4; l++){
            tm1[r][m][l] = [ORFactory bitVar: model low :&MIN8 up :&MAX8 bitLength :8];
            totalstates++;
         }
      }
   }
   
   printf("Tm1 Variables: %d\n",totalstates);
   totalstates = 0;
   for(ORInt r = 0; r < 1; r++){
      for(ORInt m = 0; m < 4; m++){
         for(ORInt l = 0; l < 4; l++){
            tm2[r][m][l] = [ORFactory bitVar: model low :&MIN8 up :&MAX8 bitLength :8];
            totalstates++;
            
         }
      }
   }
   printf("Tm2 Variables: %d\n",totalstates);
   totalstates = 0;
   for(ORInt r = 0; r < 1; r++){
      for(ORInt m = 0; m < 4; m++){
         tm0[r][m] = [ORFactory bitVar: model low :&MIN8 up :&MAX8 bitLength :8];
         totalstates++;
      }
   }
   printf("Tm0 Variables: %d\n",totalstates);
   
   //keyExpansion();
   addRoundKey();
   subBytes();
   shiftRows();
   mixColumns();
   sideChannelCon();
   
   id<ORIntVar> miniVar = [ORFactory intVar:model bounds:[ORFactory intRange:model low:0 up:error_count*2]];
   [model add: [Sum(model,j,[ORFactory intRange:model low:0 up:error_count-1],[errorPtr[2*j] plus: errorPtr[2*j + 1]]) eq: miniVar]];
   
   [model minimize: miniVar];
   //[model add: [miniVar eq: @(10)]];
   
   
   id<ORIdArray> iv = [ORFactory intVarArray:model range:RANGE(model,0,error_count*2 - 1)];
   for(ORUInt i = 0;i< error_count*2;i++)
      iv[i] = errorPtr[i];
   
   // id<ORIdArray> o = [ORFactory idArray:model range:[[ORIntRangeI alloc] initORIntRangeI:0 up:31]];
   
   
   id<ORIntRange> R = [[ORIntRangeI alloc] initORIntRangeI:0 up:47];
   //  id<ORIntRange> testR = [[ORIntRangeI alloc] initORIntRangeI:0 up:(32*8)-1];
   
   id<ORBitVarArray> o = [CPFactory bitVarArray:model range: R];
   for(ORInt k=0;k <= 15;k++)
      [o set:keys[0][k] at:k];
   
   for(ORInt k=0;k <= 15;k++)
      [o set:states[1][k] at:(k+16)];
   
   for(ORInt k=0;k <= 15;k++)
      [o set:states[2][k] at:(k+32)];
   
   /*
    for(ORInt k=0;k <= 255;k++)
    [o set:sboxout[k] at:(k+48)];
    */
   
   id<ORIdArray> oc = [ORFactory idArray:model range:R];
   
   
   
   
   
   
   id<CPProgram,CPBV> cp = (id)[ORFactory createCPProgram: model];
   __block id* gamma = [cp gamma];
   //  id<CPBitVar> test = gamma[o[0].getId];
   
   // [test lsFreeBit];
   
   for(int i = 0; i < 47; i++){
      oc[i] = gamma[o[i].getId];
   }
   
   
   [cp solve:^(){
      NSLog(@"Search Started: ;-)");
      clock_t searchStart = clock();
      [cp forall:R suchThat:^ORBool(ORInt i) {
         return [oc[i] domsize] > 0;
      } orderedBy:^ORInt(ORInt i) {
         return [oc[i] domsize];
         //return -(([gamma[o[i].getId] domsize] << 20) + s_SC[i]);
      } do:^(ORInt s) {
         ORUInt size = [oc[s] domsize];
         id<ORIntRange> S = [ORFactory intRange:cp low:0 up:((1 << size) - 1)];
         ORUInt fixedHW = 8 - size;
         
         [cp tryall:S suchThat:^ORBool(ORInt i) {
            //Calculate hamming weight
            i = i - ((i>>1) & 0x55555555);
            i = (i & 0x33333333) + ((i>>2) & 0x33333333);
            int count = ((i + (i>>4) & 0xF0F0F0F) * 0x1010101) >> 24;
            //NSLog(@"integer: %d count: %d", i, count);
            
            return (fixedHW + count) <= (s_SC[s] + 1) && (fixedHW + count) >= (s_SC[s] - 1);
            
            //return true;
         } in:^(ORInt i) {
            //num_checks++;
            [cp atomic:^{
               uint32 count = 0;
               for(int nbit = 0; nbit < 8; nbit++){
                  if([oc[s] isFree: nbit]){
                     if((i >> count++) & 1){
                        [[oc[s] domain] setBit:nbit to:true for:oc[s]];
                     }
                     else{
                        [[oc[s] domain] setBit:nbit to:false for:oc[s]];
                     }
                  }
               }
            }];
         } onFailure:^(ORInt i) {
            //Do Nothing
         }];
      }];
      //id<ORSolution> sol = [[cp solutionPool] best];
      [cp labelArrayFF:iv];
      clock_t searchStop = clock();
      double searchTime = ((double)(searchStop - searchStart))/CLOCKS_PER_SEC;
      for(int i = 0; i < 16; i++)
         NSLog(@"%@",[cp stringValue:keys[0][i]]);
      NSLog(@"    Search Time (s): %f",searchTime);
      NSLog(@"Objective Function : %@",[cp objectiveValue]);
      // NSLog(@"    Number of check: %d",num_checks);
   }];
   
   
   NSLog(@"Choices: %d / %d",[cp nbChoices],[cp nbFailures]);
   //id<ORSolution> sol = [[mip solutionPool] best];
   // NSLog(@"SOL is: %@",sol);
   
   // NSLog(@"Objective     : %@",[mip objectiveValue]);
   [cp release];
   return 0;
}

void XOR(id<ORIdArray> ca, id<ORModel> model, id<ORBitVar> a, id<ORBitVar> b, id<ORBitVar> outt){
   [model add:[ORFactory bit: a bxor:b eq:outt]];
}

void XORThree(id<ORIdArray> ca, id<ORModel> model, id<ORBitVar> a, id<ORBitVar> b, id<ORBitVar> c, id<ORBitVar> outt){
   uint32 MIN8 = 0x00000000;
   uint32 MAX8 = 0x000000FF;
   id<ORBitVar> t = [ORFactory bitVar: model low :&MIN8 up :&MAX8 bitLength :8];
   XOR(ca,model,a,b,t);
   XOR(ca,model,c,t, outt);
}

void XORFour(id<ORIdArray> ca, id<ORModel> model, id<ORBitVar> a, id<ORBitVar> b, id<ORBitVar> c, id<ORBitVar> d, id<ORBitVar> outt){
   uint32 MIN8 = 0x00000000;
   uint32 MAX8 = 0x000000FF;
   
   id<ORBitVar> t1 = [ORFactory bitVar: model low :&MIN8 up :&MAX8 bitLength :8];
   id<ORBitVar> t2 = [ORFactory bitVar: model low :&MIN8 up :&MAX8 bitLength :8];
   XOR(ca,model,a,b,t1);
   XOR(ca,model,c,t1,t2);
   XOR(ca,model,d,t2,outt);
}

void XORFour32(id<ORIdArray> ca, id<ORModel> model, id<ORBitVar> a, id<ORBitVar> b, id<ORBitVar> c, id<ORBitVar> d, id<ORBitVar> outt){
   uint32 MIN8 = 0x00000000;
   uint32 MAX8 = 0xFFFFFFFF;
   
   id<ORBitVar> t1 = [ORFactory bitVar: model low :&MIN8 up :&MAX8 bitLength :32];
   id<ORBitVar> t2 = [ORFactory bitVar: model low :&MIN8 up :&MAX8 bitLength :32];
   XOR(ca,model,a,b,t1);
   XOR(ca,model,c,t1,t2);
   XOR(ca,model,d,t2,outt);
}

void sbox(id<ORIdArray> ca, id<ORModel> model, id<ORBitVar> b1, id<ORBitVar> b2){
   [model add:[ORFactory element:model var:b1 idxBitVarArray:sboxBV equal:b2]];
}

void SideChannel(id<ORBitVar> x, int sc){
   errorPtr[2 * error_count]     = [ORFactory boolVar:model];
   errorPtr[2 * error_count + 1] = [ORFactory boolVar:model];
   id<ORIntVar> val = [ORFactory intVar:model bounds:[ORFactory intRange: model low: 0 up: 8]];
   id<ORIntVar> scval = [ORFactory intVar: model value:sc];
   
   [model add: [[errorPtr[error_count*2 + 1] plus: errorPtr[error_count*2]] leq: @(1)]];
   
   [model add: [ORFactory bit:x count:val]];
   [model add: [[[val plus: errorPtr[error_count*2]] sub: errorPtr[error_count*2+1]] eq:scval]];
   
   error_count++;
}

void keyExpansion(){
   //Key Expansion
   for(ORInt k = 0; k < 1; k++){ //k < 10
      id<ORBitVar> sb0 = [ORFactory bitVar: model low :&MIN8 up :&MAX8 bitLength :8];
      sbox(ca,model,keys[k][13],sb0);
      
      XORThree(ca,model,sb0, rcon[k], keys[k][0], keys[k+1][0]);
      
      id<ORBitVar> sb1 = [ORFactory bitVar: model low :&MIN8 up :&MAX8 bitLength :8];
      
      sbox(ca, model, keys[k][14],sb1);
      
      XOR(ca, model, sb1, keys[k][1], keys[k+1][1]);
      
      id<ORBitVar> sb2 = [ORFactory bitVar: model low :&MIN8 up :&MAX8 bitLength :8];
      sbox(ca, model, keys[k][15],sb2);
      
      XOR(ca, model, sb2, keys[k][2], keys[k+1][2]);
      
      id<ORBitVar> sb3 = [ORFactory bitVar: model low :&MIN8 up :&MAX8 bitLength :8];
      
      sbox(ca, model, keys[k][12],sb3);
      
      XOR(ca, model, sb3, keys[k][3], keys[k+1][3]);
      
      for(ORInt z = 4; z < 16; z++){
         XOR(ca, model, keys[k+1][z-4], keys[k][z], keys[k+1][z]);
      }
   }
}
void addRoundKey(){
   //AddKey
   for(ORInt k = 0 ; k < 4; k+=4){ // k < 40
      for(ORInt b = 0; b < 16; b++){
         XOR(ca, model, states[k][b], keys[k / 4][b], states[k+1][b]);
         
      }
   }
   
}

void subBytes(){
   //SubBytes
   for(ORInt k = 1; k < 5; k+=4){ // k < 41
      for(ORInt b = 0; b < 16; b++){
         sbox(ca,model, states[k][b],states[k+1][b]);
      }
   }
}

void shiftRows(){}
void mixColumns(){
   uint32 i_zero = 0x00000000;
   id<ORBitVar> zero = [ORFactory bitVar:model low:&i_zero up:&i_zero bitLength:1];
   uint32 val2 = 0x0000001B;
   id<ORBitVar> xor1b = [ORFactory bitVar: model low :&val2 up :&val2 bitLength :8];
   
   //   int r = 2;
   for(ORInt r=2; r<6; r+=4){
      int ir = (r - 2) / 4;
      for(ORInt j = 0; j < 4; j++){
         id<ORBitVar> temp[4];
         id<ORBitVar> temp1[4];
         id<ORBitVar> temp2[4];
         
         for(int i = 0; i < 4; i++){
            temp[i] = [ORFactory bitVar: model low :&MIN8 up :&MAX8 bitLength :7];
            //            temp1[i] = [ORFactory bitVar: model low :&MIN8 up :&MAX8 bitLength :8];
            //            temp2[i] = [ORFactory bitVar: model low :&MIN8 up :&MAX8 bitLength :8];
         }
         
         //Calculating TMP
         
         XORFour(ca,model, states[r][j*4], states[r][(j*4+5) % 16], states[r][(j*4+10) % 16], states[r][(j*4+15) % 16], tm0[ir][j]);
         
         XOR(ca,model, states[r][j*4], states[r][(j*4+5) % 16], tm1[ir][j][0]);
         
         XOR(ca,model, states[r][(j*4+5) % 16], states[r][(j*4+10) % 16], tm1[ir][j][1]);
         
         XOR(ca,model, states[r][(j*4+10) % 16], states[r][(j*4+15) % 16], tm1[ir][j][2]);
         
         XOR(ca,model, states[r][(j*4+15) % 16], states[r][j*4], tm1[ir][j][3]);
         
         //Apply Circular Left Shift on tmp{1,2,3,4}a
         
         for(int z = 0; z < 4; z++){
            
            id<ORBitVar> judge = [ORFactory bitVar: model withLength:1];
            id<ORBitVar> shift = [ORFactory bitVar: model withLength:8];
            id<ORBitVar> shift2 = [ORFactory bitVar: model withLength:8];
            
            
            [model add: [ORFactory bit:tm1[ir][j][z] from:0 to:6 eq:temp[z]]];
            [model add: [ORFactory bit:tm1[ir][j][z] from:7 to:7 eq:judge]];
            [model add: [ORFactory bit:temp[z] concat:zero eq:shift]];
            [model add: [ORFactory bit:shift bxor:xor1b eq:shift2]];
            [model add: [ORFactory bit:judge then:shift2 else:shift result:tm2[ir][j][z]]];
            
            //xtimes(tm1[ir][j][z],tm2[ir][j][z]);
            
            /*
             [model add: [ORFactory bit:tm1[ir][j][z] shiftLBy:1 eq:temp[z] ]]; //T0b
             uint32 val = 0x00000080;
             id<ORBitVar> judge = [ORFactory bitVar: model low :&val up :&val bitLength :8];
             uint32 val2 = 0x0000001B;
             id<ORBitVar> xor1b = [ORFactory bitVar: model low :&val2 up :&val2 bitLength :8];
             
             [model add: [ORFactory bit:tm1[ir][j][z] band:judge eq:temp1[z] ]]; //T1
             [model add: [ORFactory bit:temp[z] bxor:xor1b eq:temp2[z]]];
             [model add: [ORFactory bit:temp1[z] then:temp2[z] else:temp[z] result:tm2[ir][j][z]]];
             //[model add: [ORFactory bit:temp1[z] trueIf:tm2[ir][j][z] equals:temp2[z] zeroIfXEquals:temp[z]]];
             */
            
         }
         
         XORThree(ca, model, tm0[ir][j], tm2[ir][j][0],states[r][j*4],states[r+2][((j*4) % 4) + j*4]);
         XORThree(ca, model, tm0[ir][j], tm2[ir][j][1],states[r][(j*4 + 5) % 16],states[r+2][(((j*4 + 5) % 16) % 4) + j*4]);
         XORThree(ca, model, tm0[ir][j], tm2[ir][j][2],states[r][(j*4 + 10) % 16],states[r+2][(((j*4 + 10) % 16)% 4) + j*4]);
         XORThree(ca, model, tm0[ir][j], tm2[ir][j][3],states[r][(j*4 + 15) % 16],states[r+2][(((j*4 + 15) % 16)% 4) + j*4]);
      }
      
   }
   
}
void sideChannelCon(){
   int SC[9][16] =
   {
      {4,5,6,5,3,4,4,5,3,4,4,5,6,2,2,3}, //(0) Plaintext
      {0,4,3,5,3,5,2,5,6,3,6,3,6,0,4,2}, //
      {4,5,0,4,7,5,6,5,3,7,3,5,5,5,4,2}, //
      {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}, //3
      {6,3,4,4,4,5,2,4,4,-1,-1,-1,-1,-1,-1,-1},
      {5,2,2,4,4,5,4,2,4,-1,-1,-1,-1,-1,-1,-1},
      {3,4,4,5,5,5,4,4,5,-1,-1,-1,-1,-1,-1,-1},
      {5,1,1,5,4,3,4,7,6,-1,-1,-1,-1,-1,-1,-1},
      {4,5,5,4,4,1,6,1,6,3,4,4,4,1,4,5}
   };
   //First Rounds {Plaintext, Addkey, Subbyte, Shiftrows}
   
   for(ORInt subr = 0; subr < 4; subr++){
      for(ORInt b = 0; b < 16; b++){
         SideChannel(states[subr][b], SC[subr][b]);
         if(subr >= 1){
            s_SC[b+(16*subr)] = SC[subr][b];
         }
      }
   }
   
   // ShiftRows + MixColumns Side-Channel Constraints
   
   for(ORInt col = 0; col < 4; col++){
      
      SideChannel(tm0[0][col], SC[4 + col][0]);
      SideChannel(tm1[0][col][0], SC[4 + col][1]);
      SideChannel(tm2[0][col][0], SC[4 + col][2]);
      
      SideChannel(tm1[0][col][1], SC[4 + col][3]);
      SideChannel(tm2[0][col][1], SC[4 + col][4]);
      
      SideChannel(tm1[0][col][2], SC[4 + col][5]);
      SideChannel(tm2[0][col][2], SC[4 + col][6]);
      
      SideChannel(tm1[0][col][3], SC[4 + col][7]);
      SideChannel(tm2[0][col][3], SC[4 + col][8]);
      
   }
   
   
   for(ORInt b = 0; b < 16; b++){
      SideChannel(keys[0][b], SC[8][b]);
      s_SC[b] = SC[8][b];
   }
   
}

void xtimes(id<ORBitVar> a, id<ORBitVar> b){
   id<ORBitVar> temp = [ORFactory bitVar:model withLength:7];
   id<ORBitVar> shift = [ORFactory bitVar:model withLength:8];
   id<ORBitVar> result = [ORFactory bitVar:model withLength:8];
   id<ORBitVar> judge = [ORFactory bitVar:model withLength:8];
   
   [model add: [ORFactory bit:a from:7 to:7 eq:judge]];
   [model add: [ORFactory bit:a from:0 to:6 eq:temp]];
   [model add: [ORFactory bit:temp shiftLBy:1 eq:shift]];
   [model add: [ORFactory bit:judge times:xor1b eq:result]];
   [model add: [ORFactory bit:result bxor:shift eq:b]];
}
