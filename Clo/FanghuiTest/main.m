#import <ORProgram/ORProgram.h>
#import <objcp/CPFactory.h>
#import <objcp/CPConstraint.h>
#import <objcp/CPIntVarI.h>
#import <objcp/CPBitVar.h>
#import <objcp/CPBitVarI.h>
#import "ORCmdLineArgs.h"

#define EXPECTKEY

struct AESTuple {
    uint8 state1;
    uint8 state2;
    uint8 x;
    uint8 y;
    ORInt hits;
    uint8 cs1;
    uint8 cs2;
    uint8 score;
};

struct AESTuple labelvalues[16][9][2000];
struct AESTuple valuePair[16][18000];
uint32 valuePairCount[16];
uint32 labelcount[16][9];
int highestcount = 0;
int lowestcount = 1000;

ORInt Likelihood[9][3] = {
    {1,9,9},
    {1,2,9},
    {1,2,3},
    {2,1,3},
    {2,1,2},
    {3,1,2},
    {3,2,1},
    {9,2,1},
    {9,9,1}
};

ORInt currentobj = 1000000;

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


int hw[256] = {0, 1, 1, 2, 1, 2, 2, 3, 1, 2, 2, 3, 2, 3, 3, 4, 1, 2, 2, 3, 2, 3, 3, 4, 2, 3, 3, 4, 3, 4, 4, 5, 1, 2, 2, 3, 2, 3, 3, 4, 2, 3, 3, 4, 3, 4, 4, 5, 2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 6, 1, 2, 2, 3, 2, 3, 3, 4, 2, 3, 3, 4, 3, 4, 4, 5, 2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 6, 2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 6, 3, 4, 4, 5, 4, 5, 5, 6, 4, 5, 5, 6, 5, 6, 6, 7, 1, 2, 2, 3, 2, 3, 3, 4, 2, 3, 3, 4, 3, 4, 4, 5, 2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 6, 2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 6, 3, 4, 4, 5, 4, 5, 5, 6, 4, 5, 5, 6, 5, 6, 6, 7, 2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 6, 3, 4, 4, 5, 4, 5, 5, 6, 4, 5, 5, 6, 5, 6, 6, 7, 3, 4, 4, 5, 4, 5, 5, 6, 4, 5, 5, 6, 5, 6, 6, 7, 4, 5, 5, 6, 5, 6, 6, 7, 5, 6, 6, 7, 6, 7, 7, 8};


uint32 expect_key[16];


//Function Prototypes


void XOR(id<ORIdArray> ca, id<ORModel> model, id<ORBitVar> a, id<ORBitVar> b, id<ORBitVar> outt);
void XORThree(id<ORIdArray> ca, id<ORModel> model, id<ORBitVar> a, id<ORBitVar> b, id<ORBitVar> c, id<ORBitVar> outt);
void XORFour(id<ORIdArray> ca, id<ORModel> model, id<ORBitVar> a, id<ORBitVar> b, id<ORBitVar> c, id<ORBitVar> d, id<ORBitVar> outt);
void XORFour32(id<ORIdArray> ca, id<ORModel> model, id<ORBitVar> a, id<ORBitVar> b, id<ORBitVar> c, id<ORBitVar> d, id<ORBitVar> outt);
void sbox(id<ORIdArray> ca, id<ORModel> model, id<ORBitVar> b1, id<ORBitVar> b2);
void SideChannel(id<ORBitVar> x, int sc);
void xtimes(id<ORBitVar> a, id<ORBitVar> b);
bool isValid(ORInt a, ORInt b, ORInt sc1, ORInt sc2);

void keyExpansion(int);
void addRoundKey(int);
void shiftRows();
void mixColumns(int);
void subBytes(int);
void sideChannelCon();
void generateLists();
void printDebug();
void MCFilter();
uint32 xtimes_i(uint32 a);
void readFile(FILE *f);

//Constants
uint32 MIN8 = 0x00000000;
uint32 MAX8 = 0x000000FF;
uint32 MIN32 = 0x00000000;
uint32 MAX32 = 0xFFFFFFFF;
uint32 i_xor1b = 0x1B;
uint32 i_zero = 0x00;
const int rounds = 10;
int hwrounds = 1;
uint32 rconstant[] = {1,2,4,8,16,32,64,128,27,54};

//Global Variables
id<ORModel> model;
id<ORIdArray> ca;
id<ORRealVar> y;
int SC[100][16];
int* p_SC = SC;

//State Variables

id<ORBitVar> states [43][16];
id<ORBitVar> rcon[10];
id<ORBitVar> keys[11][16];
id<ORBitVar> tm1[11][4][4];
id<ORBitVar> tm2[11][4][4];
id<ORBitVar> tm0[11][4];
id<ORBitVar> sboxout[256];
id<ORIdArray> sboxBV;
id<ORIntVar> errorPtr[5000];

ORInt error_count;
id<ORBitVar> xor1b;
id<ORBitVar> zero;
int s_SC[64];
unsigned int Plaintext[16];// = {197,174,245,236,70,202,43,217,26,99,198,174,222,3,132,138};
unsigned int Ciphertext[16];
unsigned int p_list[48][256];
unsigned int p_count[48];

int hw_hits[48][256];
int p_hwcount[48][3];
int value[256];
//id<ORMutableInteger> currentobj;
id<ORTrailableInt> contribution[16];
id<ORTrailableInt> labeled[16];
id<ORTrailableInt> accumscore;
id<ORIntVar> pairs[16];


ORInt mc_pos[16][2];
ORInt mc_hw[16][2];

ORInt legpos[] = {0,5,10,15,4,9,14,3,8,13,2,7,12,1,6,11};

int numofsolutions = 0;

int main(int argc, const char * argv[]) {
    ORCmdLineArgs* cmd = [ORCmdLineArgs newWith:argc argv:argv];
    ORInt kKeys = 0;
    hwrounds = [cmd size];
    NSString* source = cmd.fName;
    FILE* instance = fopen([source UTF8String], "r");
    readFile(instance);   model = [ORFactory createModel];
    zero = [ORFactory bitVar:model low:&i_zero up:&i_zero bitLength:8];
    xor1b = [ORFactory bitVar:model low:&i_xor1b up:&i_xor1b bitLength:8];
    
    
    error_count = 0;
    
    for(int i = 0; i < 32; i++){
        p_count[i] = 0;
        for(int j = 0; j < 256; j++){
            p_list[i][j] = -1;
        }
    }
    
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
        states[0][w] = [ORFactory bitVar: model low :Plaintext + w up :Plaintext + w bitLength :8];
    
    //Final State variables set to ciphertext values
    for(int w = 0; w < 16; w++){
        states[41][w] = [ORFactory bitVar: model low :&Ciphertext[w] up :&Ciphertext[w] bitLength :8];
        // NSLog(@"1 - ID(%d) = %d",w,[states[41][w] getId]);
    }
    
    for(int w = 0; w < 16; w++){
        if(w < kKeys)
            keys[0][w] = [ORFactory bitVar: model low :&expect_key[w] up :&expect_key[w] bitLength :8];
        else
            keys[0][w] = [ORFactory bitVar: model low :&MIN8 up :&MAX8 bitLength :8];
    }
    
    for(int r = 0; r < 10; r++){
        rcon[r] = [ORFactory bitVar: model low :&rconstant[r] up :&rconstant[r] bitLength :8];
    }
    
    
    for(ORInt m = 0; m < 4; m++){
        tm0[0][m] = [ORFactory bitVar: model low :&MIN8 up :&MAX8 bitLength :8];
        for(ORInt l = 0; l < 4; l++){
            tm2[0][m][l] = [ORFactory bitVar: model low :&MIN8 up :&MAX8 bitLength :8];
            tm1[0][m][l] = [ORFactory bitVar: model low :&MIN8 up :&MAX8 bitLength :8];
            
        }
    }
    
    id<ORIntVar> miniVar;
    
    //keyExpansion();
    addRoundKey(0);
    int counter = 0;
    while (counter < rounds - 1)
    {
        keyExpansion(counter);
        subBytes(counter);
        mixColumns(counter);
        /*
         if(hwrounds == 1){
         sideChannelCon();
         miniVar = [ORFactory intVar:model bounds:[ORFactory intRange:model low:0 up:error_count*2]];
         [model add: [Sum(model,j,[ORFactory intRange:model low:0 up:error_count-1],[errorPtr[2*j] plus: errorPtr[2*j + 1]]) eq: miniVar]];
         }
         */
        addRoundKey(++counter);
        NSLog(@"COUNTER = %d", counter);
    }
    
    if(rounds == 10){
        keyExpansion(9);
        subBytes(9);
        shiftRows();
        addRoundKey(10);
    }
    
    
    
    sideChannelCon();
    id<ORIntVar> currentErrors = [ORFactory intVar:model bounds:[ORFactory intRange:model low:0 up:116*2]];
    NSLog(@"errorcount: %d", error_count);
    miniVar = [ORFactory intVar:model bounds:[ORFactory intRange:model low:0 up:(error_count-1)*2]];
    [model add: [Sum(model,j,[ORFactory intRange:model low:0 up:(error_count)-1],[errorPtr[2*j] plus: errorPtr[2*j + 1]]) eq: miniVar]];
    [model add: [Sum(model,j,[ORFactory intRange:model low:0 up:(116)-1],[errorPtr[2*j] plus: errorPtr[2*j + 1]]) eq: currentErrors]];
    
    //[model add: [miniVar eq: @(10)]];
    //The search enumerates 3 pairs to fixed all of the states for each column.
    //The idea is to keep track of the index of the array to avoid worker from
    //attempting to label the pairs once more.
    
    
    
    [model minimize: miniVar];
    //[model add: [miniVar eq: @(10)]];
    
    
    id<ORIntRange> R = [[ORIntRangeI alloc] initORIntRangeI:0 up:15];
    //id<ORIntRange> R2 = [[ORIntRangeI alloc] initORIntRangeI:0 up:47];
    id<ORBitVarArray> o = (id)[CPFactory bitVarArray:model range: R];
    id<ORBitVarArray> m = (id)[CPFactory bitVarArray:model range: R];
    /*
     for(ORInt k=0;k <= 15;k++)
     [o set:keys[0][k] at:k];
     
     for(ORInt k=0;k <= 15;k++)
     [o set:states[1][k] at:(k+16)];
     */
    
    for(ORInt k=0;k <= 15;k++){
        [o set:states[2][k] at:k];
    }
    
    for(int i = 0; i < 4; i++){
        for(int j = 0; j < 4; j++){
            [m set:tm1[0][i][j] at:(4*i + j)];
        }
    }
    
    //currentobj = [ORFactory mutable:model value:10]; //solve all when obj = 10
    //currentobj = [ORFactory mutable:model value:100];
    /*
     for(int i = 0; i < 16; i++){
     pairs[i] = [ORFactory intVar:model bounds:[ORFactory intRange:model low:0 up:10000]];
     .  }
     */
    id<ORIntVarArray> iv = [model intVars];
    generateLists();
    MCFilter();
    //  printDebug();
    
    
    id<ORIntVar> pairIndex[16] , *pairIndexPtr;
    pairIndexPtr = pairIndex;
    for(int i = 0; i < 16; i++){
        pairIndexPtr[i] = [ORFactory intVar:model bounds:[ORFactory intRange:model low:0 up:(valuePairCount[i] - 1)]];
    }
    
    //Channel Contraints on branching bit-vectors
    
    id<ORIntVar> branchVar[16] , *branchVarPtr;
    branchVarPtr = branchVar;
    for(int i = 0; i < 16; i++){
        branchVarPtr[i] = [ORFactory intVar:model bounds:[ORFactory intRange:model low:0 up:255]];
        [model add: [ORFactory bit: states[2][i] channel: branchVarPtr[i]]];
    }
    
    //id<CPProgram,CPBV> cp = (id)[ORFactory createCPProgram: model];
    //id<CPProgram,CPBV> cp = (id)[ORFactory createCPSemanticProgramDFS:model];
    id<CPProgram,CPBV> cp = (id)[ORFactory createCPParProgram:model nb:[cmd nbThreads] with:[ORSemDFSController proto]];
    
    //accumscore = [ORFactory trailableInt:[cp engine] value:0];
    for(int i = 0; i < 16; i++){
        contribution[i] = [ORFactory trailableInt:[cp engine] value:0];
        //labeled[i] = [ORFactory trailableInt:[cp engine] value:10000];
    }
    
    ORLong searchStart = [ORRuntimeMonitor wctime];
    
    [cp solve:^(){
        // NSLog(@"Search Start");
        /*
         for(int z = 0; z < 16; z++)
         if([cp bound: branchVarPtr[z]])
         NSLog(@"C[%d] = %d, o[%d] = %@, I[%d] = %d", z, [contribution[z] value], z, [cp stringValue: o[z]], z, [cp intValue: branchVarPtr[z]]);
         */
        //Attempt all values that results in no error
        [cp forall:R suchThat:^ORBool(ORInt i) {return [cp domsize: m[i]] > 0;/* && i % 2 == 0*/;} orderedBy:^ORInt(ORInt i) {
            
            return ((![cp bound: branchVarPtr[legpos[i]]]+ ![cp bound: branchVarPtr[mc_pos[legpos[i]][1]]]) << 10) + valuePairCount[i];
            //return ((([labeled[legpos[i]] value] == 10000) + ([labeled[mc_pos[legpos[i]][1]] value] == 10000)) << 10) + valuePairCount[i];
        }
                do:^(ORInt s) {
                    int left = legpos[s];
                    int right = mc_pos[left][1];
                    ORInt leftT = (s / 4)*4 + ((s + 3) % 4);
                    ORInt rightT = (s / 4)*4 + ((s + 1) % 4);
                    ORInt leftValue = -1;
                    ORInt rightValue = -1;
                    int totalContribution = 0;
                    id<ORIntRange> S = [ORFactory intRange:cp low:0 up:(valuePairCount[s] - 1)];
                    
                    if([cp bound: pairIndexPtr[s]]){
                        ORInt pairValue = [cp intValue: pairIndexPtr[s]];
                        S = [ORFactory intRange:cp low:pairValue up:pairValue];
                    }
                    
                    if([cp bound: pairIndexPtr[leftT]]){
                        leftValue = [cp intValue: branchVarPtr[left]];
                        int index = [cp intValue: pairIndexPtr[leftT]];
                        totalContribution += 3 - valuePair[leftT][index].cs2;
                    }
                    
                    if([cp bound: pairIndexPtr[rightT]]){
                        rightValue = [cp intValue: branchVarPtr[right]];
                        int index = [cp intValue: pairIndexPtr[rightT]];
                        totalContribution += 3 - valuePair[rightT][index].cs1;
                    }
                    
                    
                    
                    [cp tryall:S suchThat:^ORBool(ORInt k) {
                        
                        return [cp member:k in:pairIndexPtr[s]] &&
                        (leftValue == -1 || leftValue == valuePair[s][k].x)//[labeled[left] value] == valuePair[s][k].x)
                        && (rightValue == -1 || rightValue == valuePair[s][k].y)// [labeled[right] value] == valuePair[s][k].y)
                        && (currentobj > ([cp min:currentErrors] + valuePair[s][k].score - totalContribution)); //solve for optimal
                        
                        
                        //&& ([currentobj intValue:cp] >= ([accumscore value] + valuePair[s][k].score - totalContribution)); //solve all
                    } orderedBy:^ORDouble(ORInt k) {
                        //return valuePair[s][k].score;
                        return (valuePair[s][k].score << 10) +  valuePair[s][k].hits;
                    }
                            in:^(ORInt k) {
                                bool bound1 = ![cp bound: branchVarPtr[left]];
                                //bool bound1 = ([labeled[left] value] == 10000);
                                bool bound2 = ![cp bound: branchVarPtr[right]];
                                //bool bound2 = ([labeled[right] value] == 10000);
                                
                                struct AESTuple candidate = valuePair[s][k];
                                
                                [cp atomic:^{
                                    /*
                                     if(bound1){
                                     //[accumscore setValue:([accumscore value] + candidate.cs1)];
                                     //[labeled[candidate.state1] setValue:candidate.x];
                                     [contribution[candidate.state1] setValue:(candidate.cs1)];
                                     }
                                     if(bound2){
                                     //[accumscore setValue:([accumscore value] + candidate.cs2)];
                                     //[labeled[candidate.state2] setValue:candidate.y];
                                     [contribution[candidate.state2] setValue:(candidate.cs2)];
                                     }
                                     */
                                    if(bound1)
                                        [cp label:branchVarPtr[candidate.state1] with:candidate.x];
                                    if(bound2)
                                        [cp label:branchVarPtr[candidate.state2] with:candidate.y];
                                    [cp label:pairIndexPtr[s] with:k];
                                    uint32 count = 0;
                                    for(int nbit = 0; nbit < 8; nbit++){
                                        if(bound1){
                                            BOOL val = (candidate.x >> count) & 1;
                                            [cp labelBV:o[candidate.state1] at:nbit with:val]; // if the bit is already fixed, attempting to fix it to something else fails.
                                        }
                                        if(bound2){
                                            BOOL val2 = (candidate.y >> count) & 1;
                                            [cp labelBV:o[candidate.state2] at:nbit with:val2]; // if the bit is already fixed, attempting to fix it to something else fails.
                                        }
                                        count++;
                                    }
                                }];
                                
                                
                            } onFailure:^(ORInt i) {
                                //NSLog(@"Failed");
                                [cp diff:pairIndexPtr[s] with:i];
                            }];
                }];

	NSLog(@"ChoicesBefore: (%d / %d)\n",[cp nbChoices], [cp nbFailures]);
	[cp labelArrayFF:iv];
	NSLog(@"ChoicesAfter: (%d / %d)\n",[cp nbChoices], [cp nbFailures]);
        /*
         for(int j = 0; j < 16; j++){
         if(![cp bound:pairIndexPtr[j]]){
         NSLog(@"pairIndexPtr[%d] not bounded!", j);
         }
         else
         NSLog(@"pairIndexPtr[%d] bounded!", j);
         }
         */
        
        ORLong searchStop = [ORRuntimeMonitor wctime];
        ORDouble elapsed = ((ORDouble)searchStop - searchStart) / 1000.0;
        @autoreleasepool {
            ORInt tid = [NSThread threadID];
            assert([cp ground]  == YES);
            //NSLog(@"[thread:%d]     Search Time (s): %f",tid,elapsed);
            //    NSLog(@"[thread:%d] Objective Function : %@",tid,[cp objectiveValue]);
            //NSLog(@"[thread:%d]            Choices : %d / %d",tid,[cp nbChoices],[cp nbFailures]);
            NSLog(@"[thread:%d] Objective Function : %@",tid,[cp objectiveValue]);
            if(currentobj > [cp intValue:currentErrors]){
                NSLog(@"Updated Objective: %d", [cp intValue:currentErrors]);
                currentobj = [cp intValue:currentErrors];//[[cp objectiveValue] intValue];
            }
            //else
            //NSLog(@"FOUND OLD OBJECTIVE");
            
            //numofsolutions++;
            /*
             for(int i = 0; i < 16; i++){
             NSLog(@" %@", [cp stringValue:keys[0][i]]);
             }
             */
            /*
             NSLog(@"FINAL STATE:");
             for(int i = 0; i < 16; i++){
             NSLog(@" %@", [cp stringValue:states[41][i]]);
             }
             */
        }
    }];
    ORLong searchStop = [ORRuntimeMonitor wctime];
    ORDouble elapsed = ((ORDouble)searchStop - searchStart) / 1000.0;
    printf("Threads: %d   KnownKeys: %d   Choices: (%d / %d)   FinishTime(s): %f\n",cmd.nbThreads, cmd.size, [cp nbChoices], [cp nbFailures], elapsed);
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
    [model add: [[errorPtr[2 * error_count] plus: errorPtr[2 * error_count + 1]] neq: @(2)]];
    id<ORIntVar> val = [ORFactory intVar:model bounds:[ORFactory intRange: model low: 0 up: 8]];
    id<ORIntVar> scval = [ORFactory intVar: model value:sc];
    
    [model add: [[errorPtr[error_count*2 + 1] plus: errorPtr[error_count*2]] leq: @(1)]];
    
    [model add: [[val eq: scval] eq: [[errorPtr[error_count*2 + 1] eq: @(0)] land: [errorPtr[error_count*2] eq: @(0)]]]];
    
    [model add: [ORFactory bit:x count:val]];
    [model add: [[[val plus: errorPtr[error_count*2]] sub: errorPtr[error_count*2+1]] eq:scval]];
    
    error_count++;
}

void keyExpansion(int k){
    
    for(int b = 0; b < 16; b++){
        keys[k+1][b] = [ORFactory bitVar: model low :&MIN8 up :&MAX8 bitLength :8];
    }
    
    id<ORBitVar> sb0 = [ORFactory bitVar: model low :&MIN8 up :&MAX8 bitLength :8];
    id<ORBitVar> sb1 = [ORFactory bitVar: model low :&MIN8 up :&MAX8 bitLength :8];
    id<ORBitVar> sb2 = [ORFactory bitVar: model low :&MIN8 up :&MAX8 bitLength :8];
    id<ORBitVar> sb3 = [ORFactory bitVar: model low :&MIN8 up :&MAX8 bitLength :8];
    
    sbox(ca,model,keys[k][13],sb0);
    sbox(ca, model, keys[k][14],sb1);
    sbox(ca, model, keys[k][15],sb2);
    sbox(ca, model, keys[k][12],sb3);
    
    XORThree(ca,model,sb0, rcon[k], keys[k][0], keys[k+1][0]);
    XOR(ca, model, sb1, keys[k][1], keys[k+1][1]);
    XOR(ca, model, sb2, keys[k][2], keys[k+1][2]);
    XOR(ca, model, sb3, keys[k][3], keys[k+1][3]);
    
    for(ORInt z = 4; z < 16; z++){
        XOR(ca, model, keys[k+1][z-4], keys[k][z], keys[k+1][z]);
    }
}

void addRoundKey(int r){
    //AddKey
    int k = r*4;
    for(ORInt b = 0; b < 16; b++){
        //if(k+1 < 41)
        states[k+1][b] = [ORFactory bitVar: model low :&MIN8 up :&MAX8 bitLength :8];
        //else{
        // NSLog(@"2 - ID(%d) = %d",b,[states[41][b] getId]);
        //    }
        
        XOR(ca, model, states[k][b], keys[k / 4][b], states[k+1][b]);
    }
}

void addFinalKey(int r){
    //AddKey
    int k = r*4;
    for(ORInt b = 0; b < 16; b++){
        states[k+1][b] = [ORFactory bitVar: model low :&MIN8 up :&MAX8 bitLength :8];
        
        XOR(ca, model, states[k][b], keys[k / 4][b], states[k+1][b]);
    }
}

void subBytes(int r){
    int k = r*4 +1;
    //SubBytes
    for(ORInt b = 0; b < 16; b++){
        states[k+1][b] = [ORFactory bitVar: model low :&MIN8 up :&MAX8 bitLength :8];
        sbox(ca,model, states[k][b],states[k+1][b]);
    }
}

void shiftRows(){
    states[40][0] = states[38][0];
    states[40][1] = states[38][5];
    states[40][2] = states[38][10];
    states[40][3] = states[38][15];
    
    states[40][4] = states[38][4];
    states[40][5] = states[38][9];
    states[40][6] = states[38][14];
    states[40][7] = states[38][3];
    
    states[40][8] = states[38][8];
    states[40][9] = states[38][13];
    states[40][10] = states[38][2];
    states[40][11] = states[38][7];
    
    states[40][12] = states[38][12];
    states[40][13] = states[38][1];
    states[40][14] = states[38][6];
    states[40][15] = states[38][11];
    
}
void mixColumns(int ir){
    uint32 i_zero = 0x00000000;
    id<ORBitVar> zero = [ORFactory bitVar:model low:&i_zero up:&i_zero bitLength:1];
    uint32 val2 = 0x0000001B;
    id<ORBitVar> xor1b = [ORFactory bitVar: model low :&val2 up :&val2 bitLength :8];
    int r = ir *4 + 2;
    
    for(int b = 0; b < 16; b++){
        states[r+2][b] = [ORFactory bitVar: model low :&MIN8 up :&MAX8 bitLength :8];
        
    }
    
    for(ORInt j = 0; j < 4; j++){
        id<ORBitVar> temp[4];
        tm0[ir][j] = [ORFactory bitVar: model low :&MIN8 up :&MAX8 bitLength :8];
        
        for(int i = 0; i < 4; i++){
            temp[i] = [ORFactory bitVar: model low :&MIN8 up :&MAX8 bitLength :7];
            tm1[ir][j][i] = [ORFactory bitVar: model low :&MIN8 up :&MAX8 bitLength :8];
            tm2[ir][j][i] = [ORFactory bitVar: model low :&MIN8 up :&MAX8 bitLength :8];
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
            
        }
        
        XORThree(ca, model, tm0[ir][j], tm2[ir][j][0],states[r][j*4],states[r+2][((j*4) % 4) + j*4]);
        XORThree(ca, model, tm0[ir][j], tm2[ir][j][1],states[r][(j*4 + 5) % 16],states[r+2][(((j*4 + 5) % 16) % 4) + j*4]);
        XORThree(ca, model, tm0[ir][j], tm2[ir][j][2],states[r][(j*4 + 10) % 16],states[r+2][(((j*4 + 10) % 16)% 4) + j*4]);
        XORThree(ca, model, tm0[ir][j], tm2[ir][j][3],states[r][(j*4 + 15) % 16],states[r+2][(((j*4 + 15) % 16)% 4) + j*4]);
    }
}

void sideChannelCon(){
    
    for(int r = 0; r < hwrounds; r++){
        if(r < 9){
            //First Rounds {Plaintext, Addkey, Subbyte, Shiftrows}
            
            for(ORInt subr = 0; subr < 4; subr++){
                for(ORInt b = 0; b < 16; b++){
                    SideChannel(states[4*r + subr][b], SC[r*9 + subr][b]);
                    if(subr >= 1 && r == 0){
                        s_SC[b+(16*subr)] = SC[subr][b];
                    }
                }
            }
            
            // ShiftRows + MixColumns Side-Channel Constraints
            
            for(ORInt col = 0; col < 4; col++){
                
                SideChannel(tm0[r][col], SC[r*9 + 4 + col][0]);
                SideChannel(tm1[r][col][0], SC[r*9 + 4 + col][1]);
                SideChannel(tm2[r][col][0], SC[r*9 + 4 + col][2]);
                
                SideChannel(tm1[r][col][1], SC[r*9 + 4 + col][3]);
                SideChannel(tm2[r][col][1], SC[r*9 + 4 + col][4]);
                
                SideChannel(tm1[r][col][2], SC[r*9 + 4 + col][5]);
                SideChannel(tm2[r][col][2], SC[r*9 + 4 + col][6]);
                
                SideChannel(tm1[r][col][3], SC[r*9 + 4 + col][7]);
                SideChannel(tm2[r][col][3], SC[r*9 + 4 + col][8]);
                
            }
            
            // NSLog(@"--------------------");
            for(ORInt b = 0; b < 16; b++){
                SideChannel(keys[r][b], SC[r*9 + 8][b]);
               // NSLog(@"%d", SC[r*9 + 8][b]);
               // NSLog(@"CURRENT: %d", (r*9 + 8)*16 + b);
                
                if(r == 0)
                    s_SC[b] = SC[8][b];
            }
            //      NSLog(@"ROUND %d COUNT: %d", r, error_count);
        }
        
        else{
            int offset = 1296;
            //After MC
            
            for(int i = 0; i < 16; i++){
                SideChannel(states[36][i], p_SC[offset+i]);
                //NSLog(@"states: %d", p_SC[offset+i]);
                SideChannel(states[37][i], p_SC[offset+16+i]);
                SideChannel(states[38][i], p_SC[offset+32+i]);
                SideChannel(states[41][i], p_SC[offset+48+i]);
            }
            
            for(int i = 0; i < 16; i++){
                SideChannel(keys[9][i], p_SC[offset+64+i]);
                SideChannel(keys[10][i], p_SC[offset+80+i]);
            }
            
        }
    }
    
}

void generateLists(){
    for (int v = 0; v < 32; v++){
        for(int k = 0; k < 256; k++){
            ORInt i = k;
            ORInt test = Plaintext[v % 16] ^ i;
            
            int count2 = hw[test];
            int count = hw[i];
            ORInt var = (v % 16) + (1 - (v / 16)) * 16;
            
            bool testb = true;
            bool testc = true;
            
            if(v >= 16){
                int sbstate = hw[s[i]];
                testb = (sbstate <= (s_SC[v + 16] + 1) && sbstate >= (s_SC[v + 16] - 1));
            }
            
            if(v < 16){
                int sbstate2 = hw[s[test]];
                testc = (sbstate2 <= (s_SC[var + 16] + 1) && sbstate2 >= (s_SC[var + 16] - 1));
            }
            
            if ((count) <= (s_SC[v] + 1) && (count) >= (s_SC[v] - 1) &&  count2 <= (s_SC[var] + 1) && count2 >= (s_SC[var] - 1) && testb && testc){
                p_list[v][p_count[v]] = i;
                p_count[v]++;
            }
        }
    }
}

void MCFilter(){
    int count = 0;
    
    //tm0 Filtering
    
    int tmpcomp[4];
    int tempc[4];
    int rcount = 0;
    
    for(int col = 0; col < 4; col++){
        tmpcomp[0] = (col*4)%16 + 16;
        tmpcomp[1] = (col*4 + 5)%16 + 16;
        tmpcomp[2] = (col*4 + 10)%16 + 16;
        tmpcomp[3] = (col*4 + 15)%16 + 16;
        
        for(int j = 0; j < 4; j++){
            int temp[256];
            int temp_count = 0;
            tempc[(j + 0) % 4] = tmpcomp[0];
            tempc[(j + 1) % 4] = tmpcomp[1];
            tempc[(j + 2) % 4] = tmpcomp[2];
            tempc[(j + 3) % 4] = tmpcomp[3];
            
            
            for(int a = 0; a < p_count[tempc[0]]; a++){
                int vala = s[p_list[tempc[0]][a]];
                bool toggle = false;
                for(int b = 0; b < p_count[tempc[1]]; b++){
                    int valb = s[p_list[tempc[1]][b]];
                    //sum = sum ^ b;
                    for(int c = 0; c < p_count[tempc[2]]; c++){
                        int valc = s[p_list[tempc[2]][c]];
                        //sum = sum ^ c;
                        for(int d = 0; d < p_count[tempc[3]]; d++){
                            int vald = s[p_list[tempc[3]][d]];
                            int sum = vala ^ valb ^ valc ^ vald;
                            //NSLog(@"val %d", sum);
                            if(hw[sum] <= SC[4 + col][0] + 1 && hw[sum] >= SC[4 + col][0] - 1){
                                //NSLog(@"val %d", sum);
                                toggle = true;
                                temp[temp_count++] = p_list[tempc[0]][a];
                                break;
                            }
                        }
                        if(toggle)
                            break;
                    }
                    if(toggle)
                        break;
                }
                if(!toggle)
                    rcount++;
                
            }
            for(int c = 0; c < count; c++){
                p_list[tempc[0]][c] = temp[c];
            }
            p_count[tempc[0]] = temp_count;
        }
        
    }
    
    
    //tmp1 & tmp2 Filtering
    for(int col = 0; col < 4; col++){
        for(int eq = 0; eq < 4; eq++){
            
            int state1 = (col*4+(5*eq))%16 + 16;
            int state2 = (col*4+(5*((eq+1) % 4)))%16 + 16;
            mc_pos[state1%16][1] = state2 % 16;
            mc_pos[state2%16][0] = state1 % 16;
            mc_hw[state1%16][0] = SC[4 + col][2*eq + 1];
            mc_hw[state1%16][1] = SC[4 + col][2*eq + 2];
            int temp1[256];
            int temp2[256];
            int tcount1 = 0;
            int tcount2 = 0;
            for(int j = 0; j < p_count[state1]; j++){
                bool toggle = false;
                for(int k = 0; k < p_count[state2]; k++){
                    
                    uint32 tm1 = s[p_list[state1][j]] ^ s[p_list[state2][k]];
                    int tm1hw = hw[tm1];
                    
                    if(!toggle && (tm1hw <= SC[4 + col][2*eq + 1] + 1) && (tm1hw >= SC[4 + col][2*eq + 1] - 1)
                       && (hw[xtimes_i(tm1)] <= SC[4 + col][2*eq + 2] + 1) && (hw[xtimes_i(tm1)] >= SC[4 + col][2*eq + 2] - 1) ){
                        toggle = true;
                        temp1[tcount1++] = p_list[state1][j];
                    }
                }
            }
            
            for(int j = 0; j < p_count[state2]; j++){
                bool toggle = false;
                for(int k = 0; k < p_count[state1]; k++){
                    uint32 tm1 = s[p_list[state2][j]] ^ s[p_list[state1][k]];
                    int tm1hw = hw[tm1];
                    if(!toggle && (tm1hw <= SC[4 + col][2*eq + 1] + 1) && (tm1hw >= SC[4 + col][2*eq + 1] - 1)
                       && (hw[xtimes_i(tm1)] <= SC[4 + col][2*eq + 2] + 1) && (hw[xtimes_i(tm1)] >= SC[4 + col][2*eq + 2] - 1) ){
                        toggle = true;
                        temp2[tcount2++] = p_list[state2][j];
                        
                    }
                }
            }
            
            
            for(int c = 0; c < tcount1; c++){
                p_list[state1][c] = temp1[c];
            }
            p_count[state1] = tcount1;
            
            for(int c = 0; c < tcount2; c++){
                p_list[state2][c] = temp2[c];
            }
            p_count[state2] = tcount2;
            
        }
    }
    
    
    
    for(int i = 16; i < 32; i++){
        for(int j = 0; j < p_count[i]; j++){
            p_list[i+16][j] = s[p_list[i][j]];
        }
        p_count[i+16] = p_count[i];
    }
    
    
    
    for(int i = 16; i < 32; i++){
        for(int j = 0; j < p_count[i]; j++){
            p_list[i-16][j] = (p_list[i][j] ^ Plaintext[i-16]);
        }
        p_count[i-16] = p_count[i];
    }
    
    //Generate HW Hits
    //Init
    for(int i = 0; i < 48; i++){
        for(int j = 0; j < 256; j++){
            hw_hits[i][j] = 0;
        }
    }
    
    
    
    for(int i = 0; i < 16; i++){
        for(int j = 0; j < p_count[i]; j++){
            if(hw[p_list[i][j]] == s_SC[i]){
                hw_hits[i][p_list[i][j]] += 1;
            }
            if(hw[(p_list[i][j] ^ Plaintext[i])] == s_SC[i+16]){
                hw_hits[i][p_list[i][j]] += 1;
            }
            if(hw[s[(p_list[i][j] ^ Plaintext[i])]] == s_SC[i+32]){
                hw_hits[i][p_list[i][j]] += 1;
            }
        }
    }
    
    
    
    
    for(int i = 0; i < 16; i++){
        for(int j = 0; j < p_count[i]; j++){
            hw_hits[i+32][s[p_list[i][j] ^ Plaintext[i % 16]]] = hw_hits[i][p_list[i][j]];
            hw_hits[i+16][p_list[i][j] ^ Plaintext[i % 16]] = hw_hits[i][p_list[i][j]];
        }
    }
    
    for(int i = 0; i < 16; i++)
        valuePairCount[i] = 0;
    
    //Count Valid Pairs
    for(int col = 0; col < 4; col++){
        for(int eq = 0; eq < 4; eq++){
            ORInt testcount[] = {0,0,0,0,0,0,0,0,0};
            uint32 ValidPairs = 0;
            int state1 = (col*4+(5*eq))%16 + 16;
            int state2 = (col*4+(5*((eq+1) % 4)))%16 + 16;
            mc_pos[state1%16][1] = state2 % 16;
            mc_pos[state2%16][0] = state1 % 16;
            mc_hw[state1%16][0] = SC[4 + col][2*eq + 1];
            mc_hw[state1%16][1] = SC[4 + col][2*eq + 2];
            for(int j = 0; j < p_count[state1]; j++){
                for(int k = 0; k < p_count[state2]; k++){
                    uint32 tm1 = s[p_list[state1][j]] ^ s[p_list[state2][k]];
                    int tm1hw = hw[tm1];
                    
                    if((tm1hw <= SC[4 + col][2*eq + 1] + 1) && (tm1hw >= SC[4 + col][2*eq + 1] - 1)
                       && (hw[xtimes_i(tm1)] <= SC[4 + col][2*eq + 2] + 1) && (hw[xtimes_i(tm1)] >= SC[4 + col][2*eq + 2] - 1) ){
                        
                        
                        ORInt sumhw = hw_hits[state1+16][s[p_list[state1][j]]] + hw_hits[state2+16][s[p_list[state2][k]]];
                        if(hw[xtimes_i(tm1)] == SC[4 + col][2*eq + 2]){
                            sumhw++;
                        }
                        if(tm1hw == SC[4 + col][2*eq + 1]){
                            sumhw++;
                        }
                        
                        ValidPairs++;
                        struct AESTuple test;
                        test.cs1 = hw_hits[state1+16][s[p_list[state1][j]]];
                        test.cs2 = hw_hits[state2+16][s[p_list[state2][k]]];
                        
                        test.x = s[p_list[state1][j]];
                        test.y = s[p_list[state2][k]];
                        test.state1 = state1 % 16;
                        test.state2 = state2 % 16;
                        test.hits = 2;
                        if(hw[test.x] == s_SC[(state1%16)+32]) test.hits--;
                        if(hw[test.y] == s_SC[(state2%16)+32]) test.hits--;
                        
                        test.score = 8 - sumhw;
                        labelvalues[col*4 + eq][sumhw][testcount[sumhw]] = test;
                        testcount[sumhw]++;
                        
                        
                        
                        
                        if(lowestcount > sumhw)
                            lowestcount = sumhw;
                        if(highestcount < sumhw)
                            highestcount = sumhw;
                        
                        
                        
                    }
                }
            }
            
            for(int i = 0; i < 9; i++){
                labelcount[col*4 + eq][i] = testcount[i];
                valuePairCount[col*4 + eq] += testcount[i];
            }
        }
    }
    
    for(int i = 0; i < 16; i++){
        int paircount = 0;
        for(int s = 0; s < 9; s++){
            for(int j = 0; j < labelcount[i][s]; j++){
                valuePair[i][paircount++] = labelvalues[i][s][j];
            }
        }
    }
    
}


void printDebug(){
    for (int v = 0; v < 48; v++){
        printf("BV: %d ", v);
        for(int c = 0; c < p_count[v]; c++){
            printf("%d ",p_list[v][c]);
        }
        printf("\n");
    }
    
    for(int i = 0; i < 2; i++){
        for(int v = 0; v < 16; v++){
            printf("%d ", p_count[v + i * 16]);
        }
        printf("\n");
        
    }
    
    
    printf("Value of Keys:");
    
    for(int v = 0; v < 16; v++){
        for(int z = 0; z < p_count[v]; z++){
            if(p_list[v][z] == expect_key[v]){
                printf(" %d ", value[p_list[v][z]]);
            }
        }
    }
    
    printf("\n");
    
    printf("Value of State 1:");
    
    for(int v = 16; v < 32; v++){
        for(int z = 0; z < p_count[v]; z++){
            if(p_list[v][z] == (expect_key[v%16] ^ Plaintext[v%16])){
                printf(" %d ", value[p_list[v][z]]);
            }
        }
    }
    
    printf("\n");
    
    printf("Value of State 2:");
    
    for(int v = 32; v < 48; v++){
        for(int z = 0; z < p_count[v]; z++){
            if(p_list[v][z] == s[(expect_key[v%16] ^ Plaintext[v%16])]){
                printf(" %d ", value[p_list[v][z]]);
            }
        }
    }
    
    printf("\n");
    
    printf("Error Dist Key:");
    
    for(int v = 0; v < 16; v++){
        for(int z = 0; z < p_count[v]; z++){
            if(p_list[v][z] == expect_key[v]){
                printf(" %d ", hw_hits[v][p_list[v][z]]);
            }
        }
    }
    
    printf("\n");
    
    printf("Error Dist State:");
    
    
    for(int v = 16; v < 32; v++){
        for(int z = 0; z < p_count[v]; z++){
            if(p_list[v][z] == (expect_key[v%16] ^ Plaintext[v%16])){
                printf(" %d ", hw_hits[v][p_list[v][z]]);
            }
        }
    }
    
    printf("\n");
    
    printf("Error Dist State:");
    
    
    for(int v = 32; v < 48; v++){
        for(int z = 0; z < p_count[v]; z++){
            if(p_list[v][z] == s[(expect_key[v%16] ^ Plaintext[v%16])]){
                printf(" %d ", hw_hits[v][p_list[v][z]]);
            }
        }
    }
    
    printf("\n");
}

uint32 xtimes_i(uint32 a){
    
    //return ((a << 1) ^ (((a >> 7) & 1) * 0x1B)) % 256;
    
    uint32 res = 0;
    if((a >> 7) & 1){
        res = (a << 1) ^ 0x1B;
    }
    else{
        res = (a << 1);
    }
    if(res >= 256){
        res = res - 256;
    }
    return res;
}

void readFile(FILE *f){
    char x[1024];
    int sc_count = 0;
    int count = 0;
    /* assumes no word exceeds length of 1023 */
    while (fscanf(f, " %1023s", x) == 1) {
        if(count < 16){
            Plaintext[count] = atoi(x);
        }
        else if(count < 32){
            expect_key[count % 16] = atoi(x);
        }
        else if(count < 48){
            Ciphertext[count % 16] = atoi(x);
            //  NSLog(@"Ciphertext: %d", Ciphertext[count % 16]);
        }
        else{
            p_SC[sc_count++] = atoi(x);
        }
        count++;
    }
    
    // NSLog(@"count is %d", count);
    //NSLog(@"sccount is %d", sc_count);
    
    //printf("Ciphertext: ");
    //for(int i = 0; i < 16; i++){
    //  printf(" %d", Ciphertext[i]);
    //}
    //printf("\n");
}

bool isValid(ORInt a, ORInt b, ORInt sc1, ORInt sc2){
    ORInt x = a ^ b;
    ORInt y = xtimes_i(x);
    bool cond1 = a == 500 || ((hw[x] <= sc1 + 1) && (hw[x] >= sc1 - 1));
    bool cond2 = a == 500 || ((hw[y] <= sc2 + 1) && (hw[y] >= sc2 - 1));
    return cond1 && cond2;
}



