#import <ORProgram/ORProgram.h>
#import <objcp/CPFactory.h>
#import <objcp/CPConstraint.h>
#import <objcp/CPIntVarI.h>
#import <objcp/CPBitVar.h>
#import <objcp/CPBitVarI.h>
#import "ORCmdLineArgs.h"

#define EXPECTKEY

struct sboxprob {
    uint8 s1;
    uint8 s2;
    ORInt p;
};

struct ORPair{
    id<ORBitVar> s1;
    id<ORBitVar> s2;
    id<ORIntVar> p;
    id<ORIntVar> i1;
    id<ORIntVar> i2;
};

struct sboxprob sbAssignments[256][256];
struct ORPair branchVars[2000];
int branchVarsCount = 0;


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

const int Nb = 4; //Nb(4) = 128 bits
const int Nk = 4; //NK(4) = 128 bits, NK(6) = 192 bits, NK(8) = 256 bits
const int Nr = 3; //# of Rounds
const int BC = Nb;
const int KC = Nk;
const int NBK = Nk + Nr * Nb / Nk;
const int obj = 5;

/*
int i_dY[Nr-1][4][4] = {
    {{1,1,0,0} ,{1,1,0,0} ,{1,1,0,0} ,{1,1,0,0}},
    {{1,0,0,0} ,{1,0,0,0} ,{1,0,0,0} ,{1,0,0,0}}};

int i_dK[Nr][4][4] = {{{1,0,1,0} ,{1,0,1,0} ,{1,0,1,0} ,{1,0,1,0}},
    {{1,1,0,0} ,{1,1,0,0} ,{1,1,0,0} ,{1,1,0,0}},
    {{1,0,0,0} ,{1,0,0,0} ,{1,0,0,0} ,{1,0,0,0}}};

int i_dX[Nr][4][4] = {{{1,1,0,0} ,{0,0,1,0} ,{0,0,0,1} ,{0,0,0,0}},
    {{1,0,0,0} ,{0,0,0,0} ,{0,0,0,0} ,{0,0,0,0}},
    {{0,0,0,0} ,{0,0,0,0} ,{0,0,0,0} ,{0,0,0,0}}};

int i_dSR[Nr][4][4] = {{{1,1,0,0} ,{0,1,0,0} ,{0,1,0,0} ,{0,0,0,0}},
    {{1,0,0,0} ,{0,0,0,0} ,{0,0,0,0} ,{0,0,0,0}},
    {{0,0,0,0} ,{0,0,0,0} ,{0,0,0,0} ,{0,0,0,0}}};
*/

int i_dK[] = {1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
int i_dSR[] = {0, 1, 0, 0, 1, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
int i_dX[] = {0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
int i_dY[] = {1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};

int equkcheck[4][Nr][4][Nr][4] = {1, 0, 0, 0, 1, 1, 0, 0, 1, 0, 0, 0, 0, 1, 0, 1, 0, 0, 1, 1, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 1, 1, 0, 1, 1, 1, 1, 0, 0, 0, 1, 1, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 1, 0, 0, 1, 0, 0, 0, 0, 1, 0, 1, 0, 0, 1, 1, 0, 1, 1, 1, 0, 1, 0, 1, 0, 0, 1, 1, 0, 1, 1, 1, 1, 0, 0, 0, 1, 1, 0, 0, 1, 0, 0, 0, 0, 1, 0, 1, 0, 0, 1, 1, 0, 1, 1, 1, 0, 1, 0, 1, 0, 0, 1, 1, 0, 1, 1, 1, 0, 1, 0, 1, 0, 0, 1, 1, 0, 1, 1, 1, 1, 0, 0, 0, 1, 1, 0, 0, 1, 0, 0, 0, 0, 1, 0, 1, 0, 0, 1, 1, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 1, 1, 0, 1, 1, 1, 1, 0, 0, 0, 1, 1, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 1, 0, 0, 1, 0, 0, 0, 0, 1, 0, 1, 0, 0, 1, 1, 0, 1, 1, 1, 0, 1, 0, 1, 0, 0, 1, 1, 0, 1, 1, 1, 1, 0, 0, 0, 1, 1, 0, 0, 1, 0, 0, 0, 0, 1, 0, 1, 0, 0, 1, 1, 0, 1, 1, 1, 0, 1, 0, 1, 0, 0, 1, 1, 0, 1, 1, 1, 0, 1, 0, 1, 0, 0, 1, 1, 0, 1, 1, 1, 1, 0, 0, 0, 1, 1, 0, 0, 1, 0, 0, 0, 0, 1, 0, 1, 0, 0, 1, 1, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 1, 1, 0, 1, 1, 1, 1, 0, 0, 0, 1, 1, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 1, 0, 0, 1, 0, 0, 0, 0, 1, 0, 1, 0, 0, 1, 1, 0, 1, 1, 1, 0, 1, 0, 1, 0, 0, 1, 1, 0, 1, 1, 1, 1, 0, 0, 0, 1, 1, 0, 0, 1, 0, 0, 0, 0, 1, 0, 1, 0, 0, 1, 1, 0, 1, 1, 1, 0, 1, 0, 1, 0, 0, 1, 1, 0, 1, 1, 1, 0, 1, 0, 1, 0, 0, 1, 1, 0, 1, 1, 1, 1, 0, 0, 0, 1, 1, 0, 0, 1, 0, 0, 0, 0, 1, 0, 1, 0, 0, 1, 1, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 1, 1, 0, 1, 1, 1, 1, 0, 0, 0, 1, 1, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 1, 0, 0, 1, 0, 0, 0, 0, 1, 0, 1, 0, 0, 1, 1, 0, 1, 1, 1, 0, 1, 0, 1, 0, 0, 1, 1, 0, 1, 1, 1, 1, 0, 0, 0, 1, 1, 0, 0, 1, 0, 0, 0, 0, 1, 0, 1, 0, 0, 1, 1, 0, 1, 1, 1, 0, 1, 0, 1, 0, 0, 1, 1, 0, 1, 1, 1, 0, 1, 0, 1, 0, 0, 1, 1, 0, 1, 1, 1};

int Kcomp[Nr][4][4][NBK] = {1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};


uint32 expect_key[16];




//Function Prototypes
void XOR(id<ORIdArray> ca, id<ORModel> model, id<ORBitVar> a, id<ORBitVar> b, id<ORBitVar> outt);
void XORThree(id<ORIdArray> ca, id<ORModel> model, id<ORBitVar> a, id<ORBitVar> b, id<ORBitVar> c, id<ORBitVar> outt);
void XORFour(id<ORIdArray> ca, id<ORModel> model, id<ORBitVar> a, id<ORBitVar> b, id<ORBitVar> c, id<ORBitVar> d, id<ORBitVar> outt);
void XORFour32(id<ORIdArray> ca, id<ORModel> model, id<ORBitVar> a, id<ORBitVar> b, id<ORBitVar> c, id<ORBitVar> d, id<ORBitVar> outt);
void sbox(id<ORIdArray> ca, id<ORModel> model, id<ORBitVar> b1, id<ORBitVar> b2);
void sbox_0(id<ORIdArray> ca, id<ORModel> model, id<ORBitVar> b1, id<ORBitVar> b2);
void xtimes(id<ORBitVar> a, id<ORBitVar> b);
int checkKey(NSString* key);

void keyExpansion(id<ORBitVar>*);
void shiftRows(id<ORBitVar>* state, id<ORBitVar>* stateOut);
void addRoundKey(id<ORBitVar>* state, id<ORBitVar>* stateOut, id<ORBitVar>* keys);
void mixColumns(id<ORBitVar>* state, id<ORBitVar>* stateOut);
void subBytes(id<ORBitVar>* state, id<ORBitVar>* stateOut);
void subBytes_0(id<ORBitVar>* state, id<ORBitVar>* stateOut);
uint32 xtimes_i(uint32 a);
void readFile(FILE *f);

void connectBV(id<ORBitVar> bv, id<ORIntVar> iv);
void DxConstraints(void);

//Part One Function Prototypes
void p1_xor(id<ORIntVar> a, id<ORIntVar> b, id<ORIntVar> c);
void p1_xorequ(id<ORIntVar> a, id<ORIntVar> b, id<ORIntVar> c, id<ORIntVar> eab, id<ORIntVar> ebc, id<ORIntVar> eac);
void p1_addKey(void);
void p1_initKS(void);
void p1_keyExpansion(void);
void p1_shiftrows(void);
void p1_mixColumns(void);
void p1_equRelation(void);

//Part One Variables
id<ORIntVar> equRK[Nr][4][Nr][4][4];
id<ORIntVar> V[Nr][4][4][NBK];
id<ORIntVar> dX[Nr][4][4];
id<ORIntVar> dY[Nr][4][4];
id<ORIntVar> dK[Nr][4][4];
id<ORIntVar> DSR[Nr][4][4];
id<ORIntVar> colK[Nr][4];
id<ORIntVar> colX[Nr][4];
id<ORIntVar> colSRX[Nr][4];

//Part Two Variables
id<ORIntVar> DSK[Nr][4];
id<ORIntVar> p[Nr][4][4];
id<ORIntVar> pk[(Nr*Nb)/Nk][4];
id<ORIntVar> sumProb[Nk*4+Nr*BC*4];

id<ORIntVar> probs[1000];

id<ORTable> sboxTable;

ORInt probscount = 0;
ORInt pcount = 0;
ORInt pkcount = 0;

void postSB(void);
void postK(void);
id<ORTable> createRelationSbox(void);

//Constants
uint32 MIN8 = 0x00000000;
uint32 MAX8 = 0x000000FF;
uint32 MIN32 = 0x00000000;
uint32 MAX32 = 0xFFFFFFFF;
uint32 i_xor1b = 0x1B;
uint32 i_zero = 0x00;
const int rounds = 5;
int hwrounds;
//uint32 rconstant[] = {1,2,4,8,16,32,64,128,27,54};
uint32 rconstant[] = {0,0,0,0,0,0,0,0,0,0};


//uint32 Plaintext_1[] = {197,174,245,236,70,202,43,217,26,99,198,174,222,3,132,138};
//uint32 Plaintext_2[] = {197,174,245,236,70,202,43,217,26,99,198,174,222,3,132,138};
//uint32 EncKey[] = {143,194,34,208,145,203,230,143,177,246,97,206,145,92,255,84};
//uint32 EncKey[] = {143,194,34,208,145,203,230,143,177,246,97,206,145,92,255,84,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16};

ORInt EncKeyLength = 32;

//Global Variables
id<ORModel> model;
id<ORIdArray> ca;
id<ORRealVar> y;
int SC[100][16];
int* p_SC = (int*)SC;
//State Variables

id<ORBitVar> states [4 * (Nr + 1) + 1][16];

id<ORBitVar> statesX1[4 * (Nr + 1) + 1][16];
id<ORBitVar> statesX2[4 * (Nr + 1) + 1][16];
id<ORBitVar> statesDX[4 * (Nr + 1) + 1][16];


id<ORBitVar> rcon[10];
id<ORBitVar> keys1[11][16];
id<ORBitVar> keys2[11][16];
id<ORBitVar> keysDK[11][16];
//id<ORBitVar>* aliasKeys = keys;
id<ORBitVar> sboxout[256];
id<ORIdArray> sboxBV;

id<ORBitVar> xor1b;
id<ORBitVar> zero;
id<ORIntVar> p1_zero;
int s_SC[64];
unsigned int Plaintext[16];// = {197,174,245,236,70,202,43,217,26,99,198,174,222,3,132,138};
unsigned int Ciphertext[16];


uint32 solstates[11][16] = {  {75,114,57,146,57,70,0,0,75,114,57,57,0,0,89,0},
    {0,0,0,171,57,70,0,0,0,0,0,0,0,0,89,0},
    {0,0,0,1,113,57,0,0,0,0,0,0,0,0,168,0},
    {0,57,0,0,113,0,168,1,0,0,0,0,0,0,0,0},
    {75,114,57,57,75,147,57,57,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,225,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,57,0,0,0,0,0,0,0,0,0,0},
    {0,57,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {75,114,57,57,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
};

uint32 solkeys[3][16] = {
    {75,114,57,57,0,0,0,0,75,114,57,57,0,0,0,0},
    {75,114,57,57,75,114,57,57,0,0,0,0,0,0,0,0},
    {75,114,57,57,0,0,0,0,0,0,0,0,0,0,0,0},
};


id<ORMutableInteger> currentobj;

int main(int argc, const char * argv[]) {
    ORCmdLineArgs* cmd = [ORCmdLineArgs newWith:argc argv:argv];
    
    sboxTable = createRelationSbox();

    
    //ORInt kKeys = 0;
    //hwrounds = [cmd size];
    //NSString* source = cmd.fName;
    //FILE* instance = fopen([source UTF8String], "r");
    //readFile(instance);
    model = [ORFactory createModel];
    zero = [ORFactory bitVar:model low:&i_zero up:&i_zero bitLength:8];
    xor1b = [ORFactory bitVar:model low:&i_xor1b up:&i_xor1b bitLength:8];
    
    
    //Plaintext Inputs
    /*
     for(int b = 0; b < 16; b++){
     statesX1[0][b] = [ORFactory bitVar: model low :&Plaintext_1[b] up :&Plaintext_1[b] bitLength:8];
     statesX2[0][b] = [ORFactory bitVar: model low :&Plaintext_2[b] up :&Plaintext_2[b] bitLength:8];
     }
     */
    
    // Generate State Variables
    
    //ORUInt sf = 75;
    
    for(int sround = 0; sround < 4 * (Nr) + 1; sround++){
        for (int b = 0; b < 16; b++){
	  //if(sround < 11)
          //      statesDX[sround][b] = [ORFactory bitVar: model low :&solstates[sround][b] up :&solstates[sround][b] bitLength:8];
          //  else
                statesDX[sround][b] = [ORFactory bitVar: model low :&MIN8 up :&MAX8 bitLength:8];
            //[model add: [ORFactory bit: statesX1[sround][b] bxor:statesX2[sround][b] eq:statesDX[sround][b]]];
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
    
    // Generate Key Variables
    /*
     for(int w = 0; w < EncKeyLength; w++){
     keys1[w/16][w%16] = [ORFactory bitVar: model low :&EncKey[w] up :&EncKey[w] bitLength :8];
     keys2[w/16][w%16] = [ORFactory bitVar: model low :&EncKey[w] up :&EncKey[w] bitLength :8];
     
     keysDK[w/16][w%16] = [ORFactory bitVar: model low :&MIN8 up :&MAX8 bitLength:8];
     [model add: [ORFactory bit: keys1[w/16][w%16] bxor:keys2[w/16][w%16] eq:keysDK[w/16][w%16]]];
     }
     */
    for(int w = 0; w < 16; w++){
        for(int r = 0; r < Nr; r++){

            keysDK[r][w] = [ORFactory bitVar: model low :&MIN8 up :&MAX8 bitLength:8];
            //keysDK[r][w] = [ORFactory bitVar: model low :&solkeys[r][w] up :&solkeys[r][w] bitLength:8];

        }
    }
    
    for(int r = 0; r < 10; r++){
        rcon[r] = [ORFactory bitVar: model low :&rconstant[r] up :&rconstant[r] bitLength :8];
    }
    
    
    //id<ORIntVar> miniVar;
    
    
    //keyExpansion(keys1);
    //keyExpansion(keys2);
    keyExpansion((id<ORBitVar>*)keysDK);
    NSLog(@"Keys Branch Var Count: %d", branchVarsCount);
    int counter = 0;
    while (counter < Nr)
    {
        /*
         //StateX1
         addRoundKey(statesX1[4*counter], statesX1[4*counter + 1],keys1[counter]);
         subBytes(statesX1[4*counter + 1], statesX1[4*counter + 2]);
         shiftRows(statesX1[4*counter + 2], statesX1[4*counter + 3]);
         mixColumns(statesX1[4*counter + 3], statesX1[4*counter + 4]);
         
         //StateX2
         addRoundKey(statesX2[4*counter], statesX2[4*counter + 1], keys2[counter]);
         subBytes(statesX2[4*counter + 1], statesX2[4*counter + 2]);
         shiftRows(statesX2[4*counter + 2], statesX2[4*counter + 3]);
         mixColumns(statesX2[4*counter + 3], statesX2[4*counter + 4]);
         */
        
        //DX
        addRoundKey(statesDX[4*counter], statesDX[4*counter + 1], keysDK[counter]);
	if(counter == 0)
	  subBytes_0(statesDX[4*counter + 1], statesDX[4*counter + 2]);
	else
	  subBytes(statesDX[4*counter + 1], statesDX[4*counter + 2]);
        NSLog(@"statesDX[%d] <=sb=> statesDX[%d]", 4*counter + 1, 4*counter + 2);
        shiftRows(statesDX[4*counter + 2], statesDX[4*counter + 3]);
        mixColumns(statesDX[4*counter + 3], statesDX[4*counter + 4]);
        
        
        counter++;
        
    }
    
    
    for(int r = 0; r < Nr; r++){
        for(int i = 0; i < 4; i++){
            colK[r][i] = [ORFactory intVar:model bounds: [ORFactory intRange:model low:0 up:4]];
            colX[r][i] = [ORFactory intVar:model bounds: [ORFactory intRange:model low:0 up:4]];
            colSRX[r][i] = [ORFactory intVar:model bounds: [ORFactory intRange:model low:0 up:4]];
        }
    }
    
    p1_zero = [ORFactory intVar:model bounds: [ORFactory intRange:model low:0 up:0]];
    
    for(int r = 0; r < Nr; r++)
        for(int i = 0; i < 4; i++){
            for(int j = 0; j < 4; j++){
                for(int k = 0; k < NBK; k++){
                    //V[r][i][j][k] = zero;
                    V[r][i][j][k] = [ORFactory boolVar:model];
                    //V[r][i][j][k] = NULL;
                    
                }
            }
        }
    
    for(int r1 = 0; r1 < Nr; r1++)
        for(int r2 = 0; r2 < Nr; r2++)
            for(int i = 0; i < 4; i++)
                for(int j1 = 0; j1 < 4; j1++)
                    for(int j2 = 0; j2 < 4; j2++){
                        equRK[r1][j1][r2][j2][i] = NULL;
                    }
    
    
    for(int r1 = 0; r1 < Nr; r1++)
        for(int r2 = 0; r2 < Nr; r2++)
            for(int i = 0; i < 4; i++)
                for(int j1 = 0; j1 < 4; j1++)
                    for(int j2 = 0; j2 < 4; j2++){
                        //if(equRK[r2][j2][r1][j1][i] != NULL)
                        //   equRK[r1][j1][r2][j2][i] = equRK[r2][j2][r1][j1][i];
                        //else
                        equRK[r1][j1][r2][j2][i] = [ORFactory boolVar:model];
                    }
    
    
    for(int r = 0; r < Nr; r++){
        for(int i = 0; i < 4; i++){
            for(int j = 0; j < 4; j++){
	      if(r < Nr-1)
                   dY[r][i][j] = [ORFactory boolVar:model];
                dK[r][i][j] = [ORFactory boolVar:model];
                dX[r][i][j] = [ORFactory boolVar:model];
                DSR[r][i][j] = [ORFactory boolVar:model];
            }
        }
    }
    
    /*
    
    for(int r = 0; r < Nr; r++)
        for(int j = 0; j < 4; j++)
            for(int i = 0; i < 4; i++){
                [model add: [dX[r][j][i] eq: @(i_dX[r][i][j])]];
                [model add: [dK[r][j][i] eq: @(i_dK[r][i][j])]];
                [model add: [DSR[r][j][i] eq: @(i_dSR[r][i][j])]];
            }
    
    for(int r = 0; r < Nr-1; r++)
        for(int j = 0; j < 4; j++){
            for(int i = 0; i < 4; i++){
                [model add: [dY[r][j][i] eq: @(i_dY[r][i][j])]];
            }
        }
    
     */
    
    /*
    for(int r = 0; r < Nr; r++)
        for(int j = 0; j < 4; j++)
            for(int i = 0; i < 4; i++){
                [model add: [dX[r][j][i] eq: @(i_dX[16*r + i*4 + j])]];
                [model add: [dK[r][j][i] eq: @(i_dK[16*r + i*4 + j])]];
                [model add: [DSR[r][j][i] eq: @(i_dSR[16*r + i*4 + j])]];
            }
    
    for(int r = 0; r < Nr-1; r++)
        for(int j = 0; j < 4; j++){
            for(int i = 0; i < 4; i++){
                [model add: [dY[r][j][i] eq: @(i_dY[16*r + i*4 + j])]];
            }
        }
    */
    
    
    for(int r = 0; r < Nr; r++)
        for(int j = 0; j < 4; j++)
            for(int i = 0; i < 4; i++){
                [model add: [dX[r][j][i] eq: @(i_dX[16*r + j*4 + i])]];
                [model add: [dK[r][j][i] eq: @(i_dK[16*r + j*4 + i])]];
                [model add: [DSR[r][j][i] eq: @(i_dSR[16*r + j*4 + i])]];
            }
    
    for(int r = 0; r < Nr-1; r++)
        for(int j = 0; j < 4; j++){
            for(int i = 0; i < 4; i++){
                [model add: [dY[r][j][i] eq: @(i_dY[16*r + j*4 + i])]];
            }
        }
    
    
    for(int r=0; r<Nr-1; r++){
        for(int i = 0; i < 4; i++){
            //NSLog(@"%d %d %d %d",i_dY[r][i][0], i_dY[r][i][1], i_dY[r][i][2], i_dY[r][i][3]);
        }
    }
    
    
    id<ORExpr> e = [ORFactory intVar:model bounds: [ORFactory intRange:model low:0 up:0]];
    
    for(int r = 0; r < Nr; r++){
        for(int j = 0; j < 4; j++){
            e = [e plus: colSRX[r][j]];
        }
    }
    
    for(int J = 0; J < 4*Nr; J++){
        if((J % Nk) == (Nk-1)){
            e = [e plus: colK[J / 4][J % 4]];
        }
    }
    
    p1_initKS();
    p1_keyExpansion(); //Sets V Variables
    p1_addKey(); // XOR on dY, dK, and dX variables
    p1_equRelation();
    p1_shiftrows();
    p1_mixColumns();
    
    for(int r = 0; r < Nr; r++){
        for(int j = 0; j < 4; j++){
            [model add: [Sum(model,i,[ORFactory intRange:model low:0 up:3], dK[r][j][i]) eq: colK[r][j]]];
            [model add: [Sum(model,i,[ORFactory intRange:model low:0 up:3], dX[r][j][i]) eq: colX[r][j]]];
            [model add: [Sum(model,i,[ORFactory intRange:model low:0 up:3], DSR[r][j][i]) eq: colSRX[r][j]]];
        }
    }
    
    [model add: [e eq: @(obj)] ];
    
    //postSB();
    //postK();
    DxConstraints();
    
    /*
    ORInt cproba = 0;
    
    for(int r = 0; r < Nr; r++) {
        for(int i = 0; i < 4; i++) {
            for(int j = 0; j < BC; j++) {
                sumProb[cproba++]=p[r][i][j];
                NSLog(@"p index: %d %d %d", r, i, j);
                
                //cproba++;
                if ((BC*(r)+j)%KC==KC-1) {
                    //NSLog(@"pk index: %d", (BC*(r)+j)/KC);
                    if(pk[(BC*(r)+j)/KC][i] != NULL)
                        sumProb[cproba++]=pk[(BC*(r)+j)/KC][i];
                    //cproba++;
                }
            }
        }
    }
    */
    
    //id<ORIntRange> R = [ORFactory intRange:model low:0 up:(branchVarsCount-1)];
    id<ORIntRange> R = [[ORIntRangeI alloc] initORIntRangeI:0 up:(56*2)-1];
    id<ORBitVarArray> o = (id)[CPFactory bitVarArray:model range: R];

    int ocount = 0;
    for(ORInt k=0;k < (56-8);k++){
      [o set:branchVars[k+8].s1 at:(ocount++)];
    }

    for(ORInt k =0; k < 8; k++){
      [o set:branchVars[k].s1 at:(ocount++)];
    }

    for(ORInt k=0;k < (56-8);k++){
      [o set:branchVars[k+8].s2 at:(ocount++)];
    }

    for(ORInt k =0; k < 8; k++){
      [o set:branchVars[k].s2 at:(ocount++)];
   } 
    
    
    id<ORIntVar> maxObj = [ORFactory intVar:model bounds: [ORFactory intRange:model low:0 up:probscount*2]];
    
    [model add:[Sum(model, i, [ORFactory intRange:model low:0 up:probscount-1], probs[i]) eq: maxObj]];
    [model maximize:maxObj];
    
    
    NSLog(@"CPROB: %d", probscount);
    
    id<ORIntVarArray> iv = [model intVars];
    //id<ORBitVarArray> bv = [model bitVars];
    
    id<CPProgram,CPBV> cp = (id)[ORFactory createCPParProgram:model nb:[cmd nbThreads] with:[ORSemDFSController proto]];
    
    
    
    ORLong searchStart = [ORRuntimeMonitor wctime];
    NSLog(@"Pre-solving");
    NSLog(@"Branch Var Count: %d", branchVarsCount);
    [cp solve:^{
	//NSLog(@"%@",[[cp engine] model]);
	/*
        NSLog(@"XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX");
	
	NSLog(@"IV Count: %d", [iv count]);
	for(int i = 0; i < [iv count]; i++)
	  if(![cp bound:iv[i]])
	    NSLog(@"%d",[iv[i] getId]);

	NSLog(@"BV Count: %d", [bv count]);
	for(int i = 0; i < [bv count]; i++)
	  if([cp domsize:bv[i]] > 1)
	    NSLog(@"%d",[bv[i] getId]); 
	
        NSLog(@"---------KEYS-----------");
        //NSLog(@"%d <===> %d",[keysDK[i][c*4 + r] getId], [dK[i][c][r] getId]);
        
        for(int r = 0; r < 3; r++){
        NSLog(@"---------ROUND %d-----------", r);
        for(int i = 0; i < 16; i++){
            NSLog(@"%@ (%d:%d)  %d <===> %d", [cp stringValue:keysDK[r][i]], i_dK[r*16 + i/4 + i%4], [cp intValue:dK[r][i/4][i%4]] ,[keysDK[r][i] getId], [dK[r][i/4][i%4] getId]);
        }
        }
        
        NSLog(@"---------DX[0]-----------");
        
        
        for(int r = 0; r < 3; r++){
            NSLog(@"---------ROUND %d-----------", r);
            for(int i = 0; i < 16; i++){
                NSLog(@"%@ (%d:%d)  %d <===> %d", [cp stringValue:statesDX[4*r][i]], i_dX[r*16 + i/4 + i%4], [cp intValue:dX[r][i/4][i%4]] ,[statesDX[4*r][i] getId], [dX[r][i/4][i%4] getId]);
            }
        }
        
        NSLog(@"---------DX[1]-----------");

        
        for(int r = 0; r < 3; r++){
            NSLog(@"---------ROUND %d-----------", r);
            for(int i = 0; i < 16; i++){
                NSLog(@"%@ (%d:%d)  %d <===> %d", [cp stringValue:statesDX[4*r + 1][i]], i_dX[r*16 + i/4 + i%4], [cp intValue:dX[r][i/4][i%4]] ,[statesDX[4*r + 1][i] getId], [dX[r][i/4][i%4] getId]);
            }
        }
        
        NSLog(@"---------DX[2]-----------");
        
        
        for(int r = 0; r < 3; r++){
            NSLog(@"---------ROUND %d-----------", r);
            for(int i = 0; i < 16; i++){
                NSLog(@"%@ (%d:%d)  %d <===> %d", [cp stringValue:statesDX[4*r + 2][i]], i_dX[r*16 + i/4 + i%4], [cp intValue:dX[r][i/4][i%4]] ,[statesDX[4*r + 2][i] getId], [dX[r][i/4][i%4] getId]);
            }
        }

        
        NSLog(@"---------DX[3]-----------");
        
        
        for(int r = 0; r < 3; r++){
            NSLog(@"---------ROUND %d-----------", r);
            for(int i = 0; i < 16; i++){
                NSLog(@"%@ (%d:%d)  %d <===> %d", [cp stringValue:statesDX[4*r + 3][i]], i_dX[r*16 + i/4 + i%4], [cp intValue:dX[r][i/4][i%4]] ,[statesDX[4*r + 3][i] getId], [dX[r][i/4][i%4] getId]);
            }
        }

        
        NSLog(@"---------INTVARS-----------");
        
        for(int i = 0; i < 16; i++){
            NSLog(@"%@ (%d) %@ (%d) %@ (%d)",[cp stringValue:statesDX[0][i]], [cp intValue:dX[0][i%4][i/4]],[cp stringValue:statesDX[1][i]],[cp intValue:dX[1][i%4][i/4]], [cp stringValue:keysDK[0][i]], [cp intValue:dK[0][i%4][i/4]]);
        }

	
        for(int i = 0; i < branchVarsCount; i++){
	  int i1_i = -1;
	  int i2_i = -1;
	  int p_i = -1;
	  
	  if([cp bound:branchVars[i].i1])
	    i1_i = [cp intValue: branchVars[i].i1];
	  if([cp bound:branchVars[i].i2])
	    i2_i = [cp intValue: branchVars[i].i2];
	  if([cp bound:branchVars[i].p])
	    p_i = [cp intValue: branchVars[i].p];
	    
	  NSLog(@"v: %d b1: %d b2: %d i1: %d i2: %d p: %d", i, checkKey([cp stringValue: branchVars[i].s1]),checkKey([cp stringValue: branchVars[i].s2]),i1_i,i2_i,p_i);
        }
        */
        
        [cp forall:R suchThat:^ORBool(ORInt v) {
	   
	    return [cp domsize: o[v]] > 1;
	   
            //return [cp domsize: branchVars[v].s1] > 1 || [cp domsize: branchVars[v].s2] > 1;
        } orderedBy:^ORInt(ORInt v) {
	    //NSLog(@"%@", [cp stringValue: o[v]]);
	    // return  (([cp domsize: branchVars[v].s1] > 1) + ([cp domsize: branchVars[v].s2] > 1) << 10) - ([cp degree:branchVars[v].s1] + [cp degree:branchVars[v].s2]);
	    return -((([cp domsize: o[v]] == 1) + ([cp domsize: o[v - (v/56)*56 + (1 -(v/56))*56]] == 1)) << 10) - v;//[cp degree: o[v]];
	  } do:^(ORInt v) {
	      // NSLog(@"In");
	      //NSLog(@"s1 = %@   Domsize: %d",[cp stringValue:branchVars[v].s1], [cp domsize: branchVars[v].s1]);
	      //NSLog(@"s2 = %@   Domsize: %d",[cp stringValue:branchVars[v].s2], [cp domsize: branchVars[v].s2]);
            //id<ORIntRange> S = [ORFactory intRange:model low:0 up:(32385 - 1)];
            id<ORIntRange> S = [ORFactory intRange:model low:1 up:255];
	    ORInt fixedVal = ([cp domsize: o[v - (v/56)*56 + (1 -(v/56))*56]] == 1) ? checkKey([cp stringValue: o[v - (v/56)*56 + (1 -(v/56))*56]]) : -1;
	    
            [cp tryall:S suchThat:^ORBool(ORInt x) {
		if(v >= 56)
		  return (fixedVal == -1) || sbAssignments[fixedVal][x].p != 0;
		else  
		  return (fixedVal == -1) || sbAssignments[x][fixedVal].p != 0;

	      } orderedBy:^ORDouble(ORInt x) {
                //return - sbAssignments[x].p;
		if(fixedVal > -1 && v >= 56)
		  return - sbAssignments[fixedVal][x].p;
		else if(fixedVal > -1)
		  return - sbAssignments[x][fixedVal].p;
		else
		  return x;

	      } in:^(ORInt x) {
		/*
                 struct sboxprob candidate = sbAssignments[x];
                 [cp atomic:^{
                     uint32 count = 0;
                     for(int nbit = 0; nbit < 8; nbit++){
                        BOOL val = (candidate.s1 >> count) & 1;
                         [cp labelBV: branchVars[v].s1 at:nbit with:val]; // if the bit is already fixed, attempting to fix it to something else fails.
                         BOOL val2 = (candidate.s2 >> count) & 1;
                         [cp labelBV:branchVars[v].s2 at:nbit with:val2]; // if the bit is already fixed, attempting to fix it to something else fails.
                         count++;
                     }
                 }];
		*/ 
         
                //NSLog(@"Trying %d",x);
		 
                [cp atomic:^{
                    uint32 count = 0;
                    for(int nbit = 0; nbit < 8; nbit++){
                        BOOL val = (x >> count) & 1;
                        [cp labelBV: o[v] at:nbit with:val];
                        count++;
                    }
                }];
		 
            } onFailure:^(ORInt x) {
                //NSLog(@"Failure");
            }];
        }];
	/*
        [cp forall:R suchThat:^ORBool(ORInt v) {
            //return [cp domsize: o[v]] > 1;
            return [cp domsize: branchVars[v].s1] > 1 || [cp domsize: branchVars[v].s2] > 1;
        } orderedBy:^ORInt(ORInt v) {
            return  (([cp domsize: branchVars[v].s1] > 1) + ([cp domsize: branchVars[v].s2] > 1) << 10) - ([cp degree:branchVars[v].s1] + [cp degree:branchVars[v].s2]);
        } do:^(ORInt v) {
            NSLog(@"s1 = %@   Domsize: %d",[cp stringValue:branchVars[v].s1], [cp domsize: branchVars[v].s1]);
	    NSLog(@"s2 = %@   Domsize: %d",[cp stringValue:branchVars[v].s2], [cp domsize: branchVars[v].s2]);
            id<ORIntRange> S = [ORFactory intRange:model low:0 up:(32385 - 1)];
            //id<ORIntRange> S = [ORFactory intRange:model low:1 up:255];
            
            [cp tryall:S suchThat:^ORBool(ORInt x) {return true;} orderedBy:^ORDouble(ORInt x) {
                return - sbAssignments[x].p;
                //return x;
            } in:^(ORInt x) {
         
                 struct sboxprob candidate = sbAssignments[x];
                 [cp atomic:^{
                     uint32 count = 0;
                     for(int nbit = 0; nbit < 8; nbit++){
                        BOOL val = (candidate.s1 >> count) & 1;
                         [cp labelBV: branchVars[v].s1 at:nbit with:val]; // if the bit is already fixed, attempting to fix it to something else fails.
                         BOOL val2 = (candidate.s2 >> count) & 1;
                         [cp labelBV:branchVars[v].s2 at:nbit with:val2]; // if the bit is already fixed, attempting to fix it to something else fails.
                         count++;
                     }
                 }];
                 
         
                //NSLog(@"Trying %d",x);
		 
                [cp atomic:^{
                    uint32 count = 0;
                    for(int nbit = 0; nbit < 8; nbit++){
                        BOOL val = (x >> count) & 1;
                        [cp labelBV: o[v] at:nbit with:val];
                        count++;
                    }
                }];
		 
            } onFailure:^(ORInt x) {
                //NSLog(@"Failure");
            }];
        }];
	*/
        NSLog(@"Done!");
        [cp labelArrayFF:iv];
        //NSLog(@"states");
        /*
        for(int i = 0; i < 16; i++){
            NSLog(@"%@ %@ %@",[cp stringValue:statesDX[0][i]],[cp stringValue:statesDX[1][i]], [cp stringValue:keysDK[0][i]]);
        }
         */
        /*
        NSLog(@"Keys");
        for(int i = 0; i < 16; i++){
            NSLog(@"%@",[cp stringValue:keysDK[0][i]]);
        }
        */
        @autoreleasepool {
            /*
            NSLog(@"states");
            for(int i = 0; i < 16; i++){
                NSLog(@"%@",[cp stringValue:statesDX[0][i]]);
            }
            NSLog(@"Keys");
            for(int i = 0; i < 16; i++){
                NSLog(@"%@",[cp stringValue:keysDK[0][i]]);
            }
            */
            ORInt tid = [NSThread threadID];
            assert([cp ground]  == YES);
	    NSLog(@"Grounded");
            NSLog(@"[thread:%d] Objective Function : %@",tid,[cp objectiveValue]);

        }
    }];
    

    
    ORLong searchStop = [ORRuntimeMonitor wctime];
    
    
    ORDouble elapsed = ((ORDouble)searchStop - searchStart) / 1000.0;
    printf("Threads: %d   KnownKeys: %d   Choices: (%d / %d)   FinishTime(s): %\
           f\n",cmd.nbThreads, cmd.size, [cp nbChoices], [cp nbFailures], elapsed);
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
    
    
    //[model add:[ORFactory element:model var:b1 idxBitVarArray:sboxBV equal:b2]];
    id<ORIntVar> tempDX = [ORFactory intVar:model bounds:[ORFactory intRange:model low:0 up:255]];
    id<ORIntVar> tempDS = [ORFactory intVar:model bounds:[ORFactory intRange:model low:0 up:255]];
    probs[probscount] = [ORFactory intVar:model bounds:[ORFactory intRange:model low:0 up:2]];
    
    //[model add: [[tempDX eq: @(0)] imply:[[tempDS eq: @(0)] land: [p[r][i/4][i%4] eq: @(0)]]]];
    
    
    [model add: [ORFactory bit:b1 channel:tempDX]];
    [model add: [ORFactory bit:b2 channel:tempDS]];
    [model add: [ORFactory tableConstraint:model table:sboxTable on:tempDX :tempDS :probs[probscount++]]];
    
    struct ORPair temp;
    temp.s1 = b1;
    temp.s2 = b2;
    temp.p = probs[probscount - 1];
    temp.i1 = tempDX;
    temp.i2 = tempDS;
    branchVars[branchVarsCount++] = temp;
     
    
}

void sbox_0(id<ORIdArray> ca, id<ORModel> model, id<ORBitVar> b1, id<ORBitVar> b2){
    
    
    //[model add:[ORFactory element:model var:b1 idxBitVarArray:sboxBV equal:b2]];
    id<ORIntVar> tempDX = [ORFactory intVar:model bounds:[ORFactory intRange:model low:0 up:255]];
    id<ORIntVar> tempDS = [ORFactory intVar:model bounds:[ORFactory intRange:model low:0 up:255]];
    probs[probscount] = [ORFactory intVar:model bounds:[ORFactory intRange:model low:0 up:2]];
    
    //[model add: [[tempDX eq: @(0)] imply:[[tempDS eq: @(0)] land: [p[r][i/4][i%4] eq: @(0)]]]];

    [model add: [[tempDX neq: @(0)] eq: [probs[probscount] eq: @(2)]]];
    
    
    [model add: [ORFactory bit:b1 channel:tempDX]];
    [model add: [ORFactory bit:b2 channel:tempDS]];
    [model add: [ORFactory tableConstraint:model table:sboxTable on:tempDX :tempDS :probs[probscount++]]];
    
    struct ORPair temp;
    temp.s1 = b1;
    temp.s2 = b2;
    temp.p = probs[probscount - 1];
    temp.i1 = tempDX;
    temp.i2 = tempDS;
    branchVars[branchVarsCount++] = temp;
     
    
}

void keyExpansion(id<ORBitVar>* aliasKeys){
    
    int sbox_count = 0;
    //for(int i = Nk; i < Nb * (Nr + 1); i++) {
    
    for(int i = Nk; i < Nb * (Nr); i++) {
      NSLog(@"KeyExpansion: %d", i);
        if (i % Nk == 0){
            
            id<ORBitVar> sb0 = [ORFactory bitVar: model low :&MIN8 up :&MAX8 bitLength :8];
            id<ORBitVar> sb1 = [ORFactory bitVar: model low :&MIN8 up :&MAX8 bitLength :8];
            id<ORBitVar> sb2 = [ORFactory bitVar: model low :&MIN8 up :&MAX8 bitLength :8];
            id<ORBitVar> sb3 = [ORFactory bitVar: model low :&MIN8 up :&MAX8 bitLength :8];
            
            NSLog(@"aliasKeys[%d][%d][%d] <==> sb%d ID: %d",((4 * (i - 1)) + 1)/16,(((4 * (i - 1)) + 1)/4)%4,((4 * (i - 1)) + 1)%4,0,[aliasKeys[(4 * (i - 1)) + 1] getId]);
            NSLog(@"aliasKeys[%d][%d][%d] <==> sb%d ID: %d",((4 * (i - 1)) + 2)/16,(((4 * (i - 1)) + 2)/4)%4,((4 * (i - 1)) + 2)%4,1,[aliasKeys[(4 * (i - 1)) + 2] getId]);
            NSLog(@"aliasKeys[%d][%d][%d] <==> sb%d ID: %d",((4 * (i - 1)) + 3)/16,(((4 * (i - 1)) + 3)/4)%4,((4 * (i - 1)) + 3)%4,2, [aliasKeys[(4 * (i - 1)) + 3] getId]);
            NSLog(@"aliasKeys[%d][%d][%d] <==> sb%d ID: %d",((4 * (i - 1)))/16,(((4 * (i - 1)))/4)%4,((4 * (i - 1)))%4,3, [aliasKeys[(4 * (i - 1))] getId]);
            
            sbox(ca, model, aliasKeys[(4 * (i - 1)) + 1],sb0);
            sbox(ca, model, aliasKeys[(4 * (i - 1)) + 2],sb1);
            sbox(ca, model, aliasKeys[(4 * (i - 1)) + 3],sb2);
            sbox(ca, model, aliasKeys[4 * (i - 1)],sb3);
            
            /*
             struct ORPair temp1;
             temp1.s1 = aliasKeys[(4 * (i - 1)) + 1];
             temp1.s2 = sb0;
             
             struct ORPair temp2;
             temp2.s1 = aliasKeys[(4 * (i - 1)) + 2];
             temp2.s2 = sb1;
             
             struct ORPair temp3;
             temp3.s1 = aliasKeys[(4 * (i - 1)) + 3];
             temp3.s2 = sb2;
             
             struct ORPair temp4;
             temp4.s1 = aliasKeys[4 * (i - 1)];
             temp4.s2 = sb3;
             
             branchVars[branchVarsCount++] = temp1;
             branchVars[branchVarsCount++] = temp2;
             branchVars[branchVarsCount++] = temp3;
             branchVars[branchVarsCount++] = temp4;
            
            
            for(int j = 0; j < 4; j++){
                DSK[sbox_count][j] = [ORFactory intVar:model bounds:[ORFactory intRange:model low:0 up:255]];
            }
            
            [model add: [ORFactory bit:sb3 channel: DSK[sbox_count][0]]];
            [model add: [ORFactory bit:sb0 channel: DSK[sbox_count][1]]];
            [model add: [ORFactory bit:sb1 channel: DSK[sbox_count][2]]];
            [model add: [ORFactory bit:sb2 channel: DSK[sbox_count][3]]];
            
            sbox_count++;
            */
            
            
            
            XORThree(ca,model,sb0, rcon[(i / Nk) - 1], aliasKeys[4 * (i - Nk)], aliasKeys[4 * i]);
            XOR(ca, model, sb1, aliasKeys[4 * (i - Nk) + 1], aliasKeys[(4 * i) + 1]);
            XOR(ca, model, sb2, aliasKeys[4 * (i - Nk) + 2], aliasKeys[(4 * i) + 2]);
            XOR(ca, model, sb3, aliasKeys[4 * (i - Nk) + 3], aliasKeys[(4 * i) + 3]);
            
        }
        else if(Nk > 6 && i % Nk == 4){
            
            id<ORBitVar> sb0 = [ORFactory bitVar: model low :&MIN8 up :&MAX8 bitLength :8];
            id<ORBitVar> sb1 = [ORFactory bitVar: model low :&MIN8 up :&MAX8 bitLength :8];
            id<ORBitVar> sb2 = [ORFactory bitVar: model low :&MIN8 up :&MAX8 bitLength :8];
            id<ORBitVar> sb3 = [ORFactory bitVar: model low :&MIN8 up :&MAX8 bitLength :8];
            
            //sbox(ca, model, aliasKeys[(4 * (i - 1))],sb0);
            //sbox(ca, model, aliasKeys[(4 * (i - 1)) + 1],sb1);
            //sbox(ca, model, aliasKeys[(4 * (i - 1)) + 2],sb2);
            //sbox(ca, model, aliasKeys[4 * (i - 1) + 3],sb3);
            
            
             struct ORPair temp1;
             temp1.s1 = aliasKeys[(4 * (i - 1))];
             temp1.s2 = sb0;
             
             struct ORPair temp2;
             temp2.s1 = aliasKeys[(4 * (i - 1)) + 1];
             temp2.s2 = sb1;
             
             struct ORPair temp3;
             temp3.s1 = aliasKeys[(4 * (i - 1)) + 2];
             temp3.s2 = sb2;
             
             struct ORPair temp4;
             temp4.s1 = aliasKeys[(4 * (i - 1)) + 3];
             temp4.s2 = sb3;
             
             branchVars[branchVarsCount++] = temp1;
             branchVars[branchVarsCount++] = temp2;
             branchVars[branchVarsCount++] = temp3;
             branchVars[branchVarsCount++] = temp4;
            
            
            for(int j = 0; j < 4; j++){
                DSK[sbox_count][j] = [ORFactory intVar:model bounds:[ORFactory intRange:model low:0 up:255]];
            }
            
            [model add: [ORFactory bit:sb3 channel: DSK[sbox_count][0]]];
            [model add: [ORFactory bit:sb0 channel: DSK[sbox_count][1]]];
            [model add: [ORFactory bit:sb1 channel: DSK[sbox_count][2]]];
            [model add: [ORFactory bit:sb2 channel: DSK[sbox_count][3]]];
            
            sbox_count++;
            
            XOR(ca, model, sb0, aliasKeys[4 * (i - Nk)], aliasKeys[(4 * i)]);
            XOR(ca, model, sb1, aliasKeys[4 * (i - Nk) + 1], aliasKeys[(4 * i) + 1]);
            XOR(ca, model, sb2, aliasKeys[4 * (i - Nk) + 2], aliasKeys[(4 * i) + 2]);
            XOR(ca, model, sb3, aliasKeys[4 * (i - Nk) + 3], aliasKeys[(4 * i) + 3]);
            
        }
        else{
            XOR(ca, model, aliasKeys[4 * (i - 1)], aliasKeys[4 * (i - Nk)], aliasKeys[(4 * i)]);
            XOR(ca, model, aliasKeys[4 * (i - 1) + 1], aliasKeys[4 * (i - Nk) + 1], aliasKeys[(4 * i) + 1]);
            XOR(ca, model, aliasKeys[4 * (i - 1) + 2], aliasKeys[4 * (i - Nk) + 2], aliasKeys[(4 * i) + 2]);
            XOR(ca, model, aliasKeys[4 * (i - 1) + 3], aliasKeys[4 * (i - Nk) + 3], aliasKeys[(4 * i) + 3]);
            NSLog(@"Check Bounds: %d", (4 * i) + 3);
        }
    }
    
}

void addRoundKey(id<ORBitVar>* state, id<ORBitVar>* stateOut, id<ORBitVar>* keys){
    for(int b = 0; b < 16; b++){
        XOR(ca, model, state[b], keys[b], stateOut[b]);
    }
}

/*
 void addFinalKey(int r){
 //AddKey
 int k = r*4;
 for(ORInt b = 0; b < 16; b++){
 states[k+1][b] = [ORFactory bitVar: model low :&MIN8 up :&MAX8 bitLength :8];
 
 XOR(ca, model, states[k][b], keys[k / 4][b], states[k+1][b]);
 }
 }
 */

void subBytes(id<ORBitVar>* state, id<ORBitVar>* stateOut){
    //SubBytes
    for(ORInt b = 0; b < 16; b++){
        sbox(ca,model, state[b],stateOut[b]);
    }
}

void subBytes_0(id<ORBitVar>* state, id<ORBitVar>* stateOut){
    //SubBytes
    for(ORInt b = 0; b < 16; b++){
        sbox_0(ca,model, state[b],stateOut[b]);
    }
}

void shiftRows(id<ORBitVar>* state, id<ORBitVar>* stateOut){
    /*
     [model add: [ORFactory bit:state[0] eq: stateOut[0]]];
     [model add: [ORFactory bit:state[1] eq: stateOut[5]]];
     [model add: [ORFactory bit:state[2] eq: stateOut[10]]];
     [model add: [ORFactory bit:state[3] eq: stateOut[15]]];
     
     [model add: [ORFactory bit:state[4] eq: stateOut[4]]];
     [model add: [ORFactory bit:state[5] eq: stateOut[9]]];
     [model add: [ORFactory bit:state[6] eq: stateOut[14]]];
     [model add: [ORFactory bit:state[7] eq: stateOut[3]]];
     
     [model add: [ORFactory bit:state[8] eq: stateOut[8]]];
     [model add: [ORFactory bit:state[9] eq: stateOut[13]]];
     [model add: [ORFactory bit:state[10] eq: stateOut[2]]];
     [model add: [ORFactory bit:state[11] eq: stateOut[7]]];
     
     [model add: [ORFactory bit:state[12] eq: stateOut[12]]];
     [model add: [ORFactory bit:state[13] eq: stateOut[1]]];
     [model add: [ORFactory bit:state[14] eq: stateOut[6]]];
     [model add: [ORFactory bit:state[15] eq: stateOut[11]]];
     */
    
    
    //Next Two
    
    [model add: [ORFactory bit:stateOut[0] eq: state[0]]];
    [model add: [ORFactory bit:stateOut[1] eq: state[5]]];
    [model add: [ORFactory bit:stateOut[2] eq: state[10]]];
    [model add: [ORFactory bit:stateOut[3] eq: state[15]]];
    
    [model add: [ORFactory bit:stateOut[4] eq: state[4]]];
    [model add: [ORFactory bit:stateOut[5] eq: state[9]]];
    [model add: [ORFactory bit:stateOut[6] eq: state[14]]];
    [model add: [ORFactory bit:stateOut[7] eq: state[3]]];
    
    [model add: [ORFactory bit:stateOut[8] eq: state[8]]];
    [model add: [ORFactory bit:stateOut[9] eq: state[13]]];
    [model add: [ORFactory bit:stateOut[10] eq: state[2]]];
    [model add: [ORFactory bit:stateOut[11] eq: state[7]]];
    
    [model add: [ORFactory bit:stateOut[12] eq: state[12]]];
    [model add: [ORFactory bit:stateOut[13] eq: state[1]]];
    [model add: [ORFactory bit:stateOut[14] eq: state[6]]];
    [model add: [ORFactory bit:stateOut[15] eq: state[11]]];
    
    
    /*
     [model add: [ORFactory bit:stateOut[0] eq: state[0]]];
     [model add: [ORFactory bit:stateOut[1] eq: state[1]]];
     [model add: [ORFactory bit:stateOut[2] eq: state[2]]];
     [model add: [ORFactory bit:stateOut[3] eq: state[3]]];
     
     [model add: [ORFactory bit:stateOut[4] eq: state[5]]];
     [model add: [ORFactory bit:stateOut[5] eq: state[6]]];
     [model add: [ORFactory bit:stateOut[6] eq: state[7]]];
     [model add: [ORFactory bit:stateOut[7] eq: state[4]]];
     
     [model add: [ORFactory bit:stateOut[8] eq: state[10]]];
     [model add: [ORFactory bit:stateOut[9] eq: state[11]]];
     [model add: [ORFactory bit:stateOut[10] eq: state[8]]];
     [model add: [ORFactory bit:stateOut[11] eq: state[9]]];
     
     [model add: [ORFactory bit:stateOut[12] eq: state[15]]];
     [model add: [ORFactory bit:stateOut[13] eq: state[12]]];
     [model add: [ORFactory bit:stateOut[14] eq: state[13]]];
     [model add: [ORFactory bit:stateOut[15] eq: state[14]]];
     */
    
    /*
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
     */
}

void mixColumns(id<ORBitVar>* state, id<ORBitVar>* stateOut){
    uint32 i_zero = 0x00000000;
    id<ORBitVar> zero = [ORFactory bitVar:model low:&i_zero up:&i_zero bitLength:1];
    uint32 val2 = 0x0000001B;
    id<ORBitVar> xor1b = [ORFactory bitVar: model low :&val2 up :&val2 bitLength :8];
    id<ORBitVar> tm0[4];
    id<ORBitVar> tm1[4][4];
    id<ORBitVar> tm2[4][4];
    
    for(ORInt j = 0; j < 4; j++){
        id<ORBitVar> temp[4];
        tm0[j] = [ORFactory bitVar: model low :&MIN8 up :&MAX8 bitLength :8];
        
        for(int i = 0; i < 4; i++){
            temp[i] = [ORFactory bitVar: model low :&MIN8 up :&MAX8 bitLength :7];
            tm1[j][i] = [ORFactory bitVar: model low :&MIN8 up :&MAX8 bitLength :8];
            tm2[j][i] = [ORFactory bitVar: model low :&MIN8 up :&MAX8 bitLength :8];
        }
        
        //Calculating TMP
        
        XORFour(ca,model, state[j*4], state[(j*4+1) % 16], state[(j*4+2) % 16], state[(j*4+3) % 16], tm0[j]);
        XOR(ca,model, state[j*4], state[(j*4+1) % 16], tm1[j][0]);
        XOR(ca,model, state[(j*4+1) % 16], state[(j*4+2) % 16], tm1[j][1]);
        XOR(ca,model, state[(j*4+2) % 16], state[(j*4+3) % 16], tm1[j][2]);
        XOR(ca,model, state[(j*4+3) % 16], state[j*4], tm1[j][3]);
        
        //Apply Circular Left Shift on tmp{1,2,3,4}a
        
        for(int z = 0; z < 4; z++){
            
            id<ORBitVar> judge = [ORFactory bitVar: model withLength:1];
            id<ORBitVar> shift = [ORFactory bitVar: model withLength:8];
            id<ORBitVar> shift2 = [ORFactory bitVar: model withLength:8];
            
            [model add: [ORFactory bit:tm1[j][z] from:0 to:6 eq:temp[z]]];
            [model add: [ORFactory bit:tm1[j][z] from:7 to:7 eq:judge]];
            [model add: [ORFactory bit:temp[z] concat:zero eq:shift]];
            [model add: [ORFactory bit:shift bxor:xor1b eq:shift2]];
            [model add: [ORFactory bit:judge then:shift2 else:shift result:tm2[j][z]]];
            
        }
        
        XORThree(ca, model, tm0[j], tm2[j][0],state[j*4],stateOut[j*4]);
        XORThree(ca, model, tm0[j], tm2[j][1],state[(j*4 + 1) % 16],stateOut[(j*4 + 1) % 16]);
        XORThree(ca, model, tm0[j], tm2[j][2],state[(j*4 + 2) % 16],stateOut[(j*4 + 2) % 16]);
        XORThree(ca, model, tm0[j], tm2[j][3],state[(j*4 + 3) % 16],stateOut[(j*4 + 3) % 16]);
    }
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




/*
 
 */


//Correct
void p1_xor(id<ORIntVar> a, id<ORIntVar> b, id<ORIntVar> c){
    [model add: [[[a plus:b] plus: c] neq: @(1)]];
}

//Correct
void p1_xorequ(id<ORIntVar> a, id<ORIntVar> b, id<ORIntVar> c, id<ORIntVar> eab, id<ORIntVar> ebc, id<ORIntVar> eac){
    p1_xor(a,b,c);
    [model add: [[@(1) sub: c] eq: eab]];
    [model add: [[@(1) sub: a] eq: ebc]];
    [model add: [[@(1) sub: b] eq: eac]];
}

//AddRoundKey Implementation (Correct)
void p1_addKey(){
    for(int i = 1; i < Nr; i++){
        for(int c = 0; c < 4; c++){
            for(int r = 0; r < 4; r++){
                p1_xor(dY[i-1][c][r], dK[i][c][r], dX[i][c][r]);
                //NSLog(@"%d + %d + %d = %d",i_dY[i-1][c][r], i_dK[i][c][r], i_dX[i][c][r], (i_dY[i-1][c][r] + i_dK[i][c][r] + i_dX[i][c][r]));
                
            }
        }
    }
}

void p1_initKS(){
    //Correct - Part One
    for(int J = 0; J < 4 * Nr; J++){
        for(int i = 0; i < 4; i++){
            int r = J / BC;
            int j = J % BC;
            for(int k = 0; k < NBK; k++){
                if (J<KC){
                    if (k==J){
                        //V[r][j][i][k]=dK[r][j][i];
                        [model add: [V[r][j][i][k] eq: dK[r][j][i]]];
                    }
                    else {
                        //V[r][j][i][k]=zero;
                        [model add: [V[r][j][i][k] eq: @(0)]];
                    }
                }
                else if (J % KC == 0){
                    if(k == ((J / KC) + KC)){  //k == ((J / KC)*BC+j)){
                        //V[r][j][i][k] = dK[(J-1) / BC] [(J+BC-1) % BC ][(i+1) % 4];
                        [model add: [V[r][j][i][k] eq: dK[(J-1) / BC] [(J+BC-1) % BC ][(i+1) % 4]]];
                        
                    }
                    else{
                        [model add: [V[r][j][i][k] eq: V[(J-KC) / BC][(J-KC) % BC ][i][k]]];
                    }
                }
            }
            
        }
    }
}

void p1_keyExpansion(){
    //Part Two
    for(int J = KC; J < 4 * Nr; J++){
        for(int i = 0; i < 4; i++){
            int r = J / BC;
            int j = J % BC;
            if(J % KC == 0){
                p1_xor(dK[(J-KC) / BC] [(J-KC) % BC][i],
                       dK[(J-1) / BC ] [(J+BC-1) % BC ][(i+1) % 4],
                       dK[r][j][i]);
            }
            else{
                p1_xorequ(dK[(J-KC) / BC][(J-KC) % BC][i], //a
                          dK[(J-1) / BC ][(J+BC-1) % BC ][i], //b
                          dK[r][j][i], //c
                          equRK[(J-KC) / BC][(J-KC) % BC][(J-1) / BC ][(J+BC-1) % BC ][i], //equ(a,b)
                          equRK[(J-1) / BC ][(J+BC-1) % BC ][r][j][i], //equ(b,c)
                          equRK[(J-KC) / BC][(J-KC) % BC][r][j][i]); //equ(a,c)
                
                for(int k = 0; k < NBK; k++){
                    id<ORIntVar> temp1 = [ORFactory boolVar:model];
                    id<ORIntVar> temp2 = [ORFactory boolVar:model];
                    [model add: [[V[(J-KC) / BC][ (J-KC) % BC][i][k] mul: dK[(J-KC) / BC][(J-KC) % BC][i]] eq: temp1]];
                    [model add: [[V[(J-1) / BC][(J+BC-1) % BC][i][k] mul: dK[(J-1) / BC][(J+BC-1) % BC][i]] eq: temp2]];
                    [model add: [[temp1 neq: temp2] eq: V[r][j][i][k]]];
                }
                
            }
            
            [model add: [[Sum(model,k,[ORFactory intRange:model low:0 up:NBK-1], V[r][j][i][k]) plus: dK[r][j][i]] neq: @(1)]];
            
        }
    }
    
}

//Correct
void p1_shiftrows(){
    for(int r = 0; r < Nr; r++){
        for(int j = 0; j < BC; j++){
            for(int i = 0; i < 4; i++){
                //DSR[r][j][i]=dX[r][((j+i) % BC)][i];
                [model add: [DSR[r][j][i] eq: dX[r][((j+i) % BC)][i]]];
            }
        }
    }
}

//Correct
void p1_mixColumns(){
    for(int r = 0; r < Nr - 1; r++){
        for(int j = 0; j < BC; j++){
            id<ORIntVar> temp = [ORFactory intVar:model bounds:[ORFactory intRange:model low:0 up:8]];
            [model add: [[colSRX[r][j] plus: Sum(model,i,[ORFactory intRange:model low:0 up:3], dY[r][j][i])] eq: temp]];
            
            [model add: [ORFactory restrict:model var:temp to:[ORFactory intSet:model set:[NSSet setWithArray:@[@0, @5, @6, @7, @8]]]]];
        }
    }
    
}
//(Correct)
void p1_equRelation(){
    for(int J = 0; J < Nr*4; J++)
        for(int J2 = J+1; J2 < Nr*4; J2++){
            int r = J / BC;
            int j = J % BC;
            int r2 = J2 / BC;
            int j2 = J2 % BC;
            for(int i = 0; i < 4; i++){
                [model add: [equRK[r][j][r2][j2][i] imply: [dK[r][j][i] eq: dK[r2][j2][i]]]];
                [model add: [equRK[r][j][r2][j2][i] eq: equRK[r2][j2][r][j][i]]];
                
                /*
                 id<ORExpr> e = [V[r][j][i][0] eq: V[r2][j2][i][0]];
                 for(int k = 1; k < NBK; k++){
                 //(Kcomp[r,j,i,k]==Kcomp[r2,j2,i,k])) -> (EQ[i,r,j,r2,j2]=1))
                 [e land: [V[r][j][i][k] eq: V[r2][j2][i][k]]];
                 //[model add: [[V[r][j][i][k] eq: V[r2][j2][i][k]] imply: equRK[r][j][r2][j2][i]]];
                 }
                 [model add: [e imply: equRK[r][j][r2][j2][i]]];
                 */
                
                [model add:[And(model, k, [ORFactory intRange:model low:0 up:NBK-1], [V[r][j][i][k] eq: V[r2][j2][i][k]]) imply: equRK[r][j][r2][j2][i]]];
                
                //(DK[r,j,i]+DK[r2,j2,i] + EQ[i,r,j,r2,j2]) != 0 /\ % a+b+EQ(a,b) !=0
                
                [model add: [[[dK[r][j][i] plus: dK[r2][j2][i]] plus: equRK[r][j][r2][j2][i]] neq: @(0)]];
                
                for(int J3 = 0; J3 < Nr*BC; J3++){
                    int r3 = J3 / BC;
                    int j3 = J3 % BC;
                    
                    //EQ[i,r,j,r3,j3] + EQ[i,r,j,r2,j2] + EQ[i,r2,j2,r3,j3] != 2 %transitivity
                    
                    [model add: [[[equRK[r][j][r3][j3][i] plus: equRK[r][j][r2][j2][i]] plus: equRK[r2][j2][r3][j3][i]] neq: @(2)]];
                    
                }
                
            }
        }
}


void connectBV(id<ORBitVar> bv, id<ORIntVar> iv){
    id<ORIntVar> temp = [ORFactory intVar:model bounds:[ORFactory intRange:model low:0 up:8]];
    //id<ORIntVar> zero = [ORFactory intVar:model bounds:[ORFactory intRange:model low:0 up:0]];
    [model add: [ORFactory bit: bv count: temp]];
    [model add: [[iv eq: @(0)] eq: [temp eq: @(0)]]];
    [model add: [[iv eq: @(1)] eq: [temp geq: @(1)]]];

    //[model add: [temp imply: iv]];
    
    //[model add: [[iv eq: @(0)] imply:[bv eq: zero]]];
}

void DxConstraints(){
    
    
    for(int i = 0; i < Nr; i++){
        for(int c = 0; c < 4; c++){
            for(int r = 0; r < 4; r++){
                //States
                if(i > 0){
                    connectBV(statesDX[i*4][c*4 + r], dY[i-1][c][r]);
                    //NSLog(@"state[%d][%d] <==> dY[%d][%d][%d]", i*4, c*4 + r, i-1, c, r);
                }
                
                connectBV(statesDX[i*4 + 1][c*4 + r], dX[i][c][r]);
                connectBV(statesDX[i*4 + 3][c*4 + r], DSR[i][c][r]);
                
                //Keys
                connectBV(keysDK[i][c*4 + r], dK[i][c][r]);
                if(i == 0)
                NSLog(@"%d <===> %d",[keysDK[i][c*4 + r] getId], [dK[i][c][r] getId]);
                
            }
        }
    }
    
    
    /*
    for(int i = 0; i < Nr; i++){
        for(int c = 0; c < 4; c++){
            for(int r = 0; r < 4; r++){
                //States
                if(i > 0){
                    connectBV(statesDX[i*4][c*4 + r], dY[i-1][r][c]);
                    //NSLog(@"state[%d][%d] <==> dY[%d][%d][%d]", i*4, c*4 + r, i-1, c, r);
                }
                
                connectBV(statesDX[i*4 + 1][c*4 + r], dX[i][r][c]);
                connectBV(statesDX[i*4 + 3][c*4 + r], DSR[i][r][c]);
                
                //Keys
                connectBV(keysDK[i][c*4 + r], dK[i][r][c]);
                if(i == 0)
                    NSLog(@"%d <===> %d",[keysDK[i][c*4 + r] getId], [dK[i][c][r] getId]);
                
            }
        }
    }
    */
     
}

id<ORTable> createRelationSbox(){
    id<ORTable> sboxTable = [ORFactory table: model arity: 3];
    
    uint32 trans[256][127];
    uint32 probas[256][256];
    uint32 ctrans[256];
    
    //Init Arrays
    for (int i=0;i<256;i++) {
        ctrans[i]=0;
        for (int j=0;j<256;j++) {
            probas[i][j]=0;
            if(j<127)
                trans[i][j]=0;
	    
            struct sboxprob temp;
            temp.p = 0;
	    sbAssignments[i][j] = temp;
	    
        }
    }
    //
    for(int i=0;i<256;i++)
    {
        for(int j=0;j<256;j++)
        {
            probas[i][(s[j]^s[j^i])] ++;
            if(probas[i][(s[j]^s[j^i])]==1) {
                trans[i][ctrans[i]++]=(s[j]^s[i^j]);
            }
        }
    }
    //tuples.add(0,0,0);
    [sboxTable insert: 0 : 0 : 0];
    
    int p=0;
    int countc = 0;
    for (int i=1; i<256; i++){
        for (int j=0; j<127; j++) {
            p=probas[i][trans[i][j]]/2;
            [sboxTable insert: i : trans[i][j] : p];
            if(probas[i][trans[i][j]] == 4)
                NSLog(@"a:%d b:%d p:%d", i, trans[i][j], probas[i][trans[i][j]]);
            struct sboxprob temp;
            temp.s1 = i;
            temp.s2 = trans[i][j];
            temp.p = p;
            sbAssignments[i][trans[i][j]] = temp;
            countc++;
        }
    }
    NSLog(@"Countc: %d", countc);
    return sboxTable;
}

void postSB(){
    id<ORTable> sboxTable = createRelationSbox();
    
    for(int i = 0; i < 16; i++){
        id<ORIntVar> tempDX = [ORFactory intVar:model bounds:[ORFactory intRange:model low:0 up:255]];
        id<ORIntVar> tempDS = [ORFactory intVar:model bounds:[ORFactory intRange:model low:0 up:255]];
        p[0][i/4][i%4] = [ORFactory intVar:model bounds:[ORFactory intRange:model low:0 up:2]];
        pcount++;
        
        //[model add: [[tempDX eq: @(0)] imply:[[tempDS eq: @(0)] land: [p[0][i/4][i%4] eq: @(0)]]]];
        [model add: [[tempDX neq: @(0)] imply:[p[0][i/4][i%4] eq: @(2)]]];
        
        
        
        [model add: [ORFactory bit:statesDX[1][i] channel:tempDX]];
        [model add: [ORFactory bit:statesDX[2][i] channel:tempDS]];
        [model add: [ORFactory tableConstraint:model table:sboxTable on:tempDX :tempDS :p[0][i/4][i%4]]];
        
        struct ORPair temp;
        temp.s1 = statesDX[1][i];
        temp.s2 = statesDX[2][i];
        
        branchVars[branchVarsCount++] = temp;
    }
    NSLog(@"statesDX[%d] <=sb*=> statesDX[%d]", 1, 2);
    
    
    for(int r = 1; r < Nr; r++){
        NSLog(@"statesDX[%d] <=sb*=> statesDX[%d]", r*4 + 1, r*4 + 2);
        
        for(int i = 0; i < 16; i++){
            id<ORIntVar> tempDX = [ORFactory intVar:model bounds:[ORFactory intRange:model low:0 up:255]];
            id<ORIntVar> tempDS = [ORFactory intVar:model bounds:[ORFactory intRange:model low:0 up:255]];
            p[r][i/4][i%4] = [ORFactory intVar:model bounds:[ORFactory intRange:model low:0 up:2]];
            pcount++;
            
            //[model add: [[tempDX eq: @(0)] imply:[[tempDS eq: @(0)] land: [p[r][i/4][i%4] eq: @(0)]]]];
            
            
            [model add: [ORFactory bit:statesDX[r*4 + 1][i] channel:tempDX]];
            [model add: [ORFactory bit:statesDX[r*4 + 2][i] channel:tempDS]];
            [model add: [ORFactory tableConstraint:model table:sboxTable on:tempDX :tempDS :p[r][i/4][i%4]]];
            
             struct ORPair temp;
             temp.s1 = statesDX[r*4 + 1][i];
             temp.s2 = statesDX[r*4 + 2][i];
             
             branchVars[branchVarsCount++] = temp;
            
        }
    }
}

void postK(){
    id<ORTable> sboxTable = createRelationSbox();
    for (int J = 0;J < Nr*BC; J++) {
        ORInt r = J / BC;
        ORInt j = J % BC;
        ORInt indP=(J/KC);
        for(int i = 0; i < 4; i++) {
            if (J < BC*Nr-1) {
                if (J % KC == (KC-1)) {
                    /*
                     LCF.ifThenElse(
                     ICF.arithm(DK[r][(i+1)%4][j],"=",0),
                     LCF.and(
                     ICF.arithm(pk[indP][i], "=", 0),
                     ICF.arithm(DeltaSK[indP][i],"=",0)
                     ),
                     ICF.table(new IntVar[]{DK[r][(i+1)%4][j], DeltaSK[indP][i],pk[indP][i]},tupleSB, strategy)
                     );
                     */
                    
                    
                    id<ORIntVar> tempDK = [ORFactory intVar:model bounds:[ORFactory intRange:model low:0 up:255]];
                    pk[indP][i] = [ORFactory intVar:model bounds:[ORFactory intRange:model low:0 up:2]];
                    
                    //NSLog(@"J: %d,r: %d, j: %d",J,r,j);
                    [model add: [ORFactory bit:keysDK[r][j*4 + (i+1)%4] channel:tempDK]];
                    //[model add: [ORFactory bit:keysDK[r][j + ((i+1)%4)*4] channel:tempDK]];
                    
                    //[model add: [[tempDK eq: @(0)] imply:[[pk[indP][i] eq: @(0)] land: [DSK[indP][i] eq: @(0)]]]];
                    [model add: [ORFactory tableConstraint:model table:sboxTable on:tempDK :DSK[indP][i] :pk[indP][i]]];
                    
                    
                    
                    printf("Dk[%d][%d][%d]  xor  DeltaSK[%d][%d] ID: %d\n",r,(i+1)%4,j,indP,i, [keysDK[r][j*4 + (i+1)%4] getId]);
                    
                }
            }
            if (J%KC==0 && J/KC>0) {
                /*
                 postXorByte(DK[(J-KC)/BC][i][(J-KC)%BC],DeltaSK[J/KC-1][i],DK[r][i][j],solver);
                 */
                //printf("Dk[%d][%d][%d]  xor  DeltaSK[%d][%d]\n",r,(i+1)%4,j,indP,i);
                
            }
            
            if (J/KC>0 && J%KC>0) {
                /*
                 postXorByte(DK[(J-1)/BC][i][(J-1+BC)%BC],DK[(J-KC)/BC][i][(J-KC+BC)%BC],DK[r][i][j],solver);
                 */
                //printf("Dk[%d][%d][%d]  xor  DeltaSK[%d][%d]\n",r,(i+1)%4,j,indP,i);
                
            }
        }
        
    }
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
            NSLog(@"Ciphertext: %d", Ciphertext[count % 16]);
        }
        else{
            p_SC[sc_count++] = atoi(x);
        }
        count++;
    }
    
    NSLog(@"count is %d", count);
    NSLog(@"sccount is %d", sc_count);
    
    printf("Ciphertext: ");
    for(int i = 0; i < 16; i++){
        printf(" %d", Ciphertext[i]);
    }
    printf("\n");
}

int checkKey(NSString* key){
    //NSString *skey = [key substringFromIndex:14];
    const char* ckey = [[key substringFromIndex:[key length] - 8] UTF8String];
    //printf("%s\n",ckey);
    int value = 0;
    int mul = 1;
    int free = 0;
    for(int i = 7; i >= 0; i--){
        if(ckey[i] == '1'){
            value += mul;
        }
        mul = mul * 2;
        if(ckey[i] == '?'){
            free++;
        }
    }
    if(free == 8)
        return -1;
    
    return value;
}
