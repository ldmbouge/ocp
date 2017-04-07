#import <ORProgram/ORProgram.h>
#import <objcp/CPFactory.h>
#import <objcp/CPConstraint.h>
#import <objcp/CPIntVarI.h>
#import <objcp/CPBitVar.h>
#import <objcp/CPBitVarI.h>
#import "ORCmdLineArgs.h"

#define EXPECTKEY
#define KNOWNKEYS 1

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


uint32 sb[256] = {0x63 ,0x7c ,0x77 ,0x7b ,0xf2 ,0x6b ,0x6f ,0xc5 ,0x30 ,0x01 ,0x67 ,0x2b ,0xfe ,0xd7 ,0xab ,0x76
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

uint32 inv_s[256] =
{0x52 ,0x09 ,0x6a ,0xd5 ,0x30 ,0x36 ,0xa5 ,0x38 ,0xbf ,0x40 ,0xa3 ,0x9e ,0x81 ,0xf3 ,0xd7 ,0xfb
   ,0x7c ,0xe3 ,0x39 ,0x82 ,0x9b ,0x2f ,0xff ,0x87 ,0x34 ,0x8e ,0x43 ,0x44 ,0xc4 ,0xde ,0xe9 ,0xcb
   ,0x54 ,0x7b ,0x94 ,0x32 ,0xa6 ,0xc2 ,0x23 ,0x3d ,0xee ,0x4c ,0x95 ,0x0b ,0x42 ,0xfa ,0xc3 ,0x4e
   ,0x08 ,0x2e ,0xa1 ,0x66 ,0x28 ,0xd9 ,0x24 ,0xb2 ,0x76 ,0x5b ,0xa2 ,0x49 ,0x6d ,0x8b ,0xd1 ,0x25
   ,0x72 ,0xf8 ,0xf6 ,0x64 ,0x86 ,0x68 ,0x98 ,0x16 ,0xd4 ,0xa4 ,0x5c ,0xcc ,0x5d ,0x65 ,0xb6 ,0x92
   ,0x6c ,0x70 ,0x48 ,0x50 ,0xfd ,0xed ,0xb9 ,0xda ,0x5e ,0x15 ,0x46 ,0x57 ,0xa7 ,0x8d ,0x9d ,0x84
   ,0x90 ,0xd8 ,0xab ,0x00 ,0x8c ,0xbc ,0xd3 ,0x0a ,0xf7 ,0xe4 ,0x58 ,0x05 ,0xb8 ,0xb3 ,0x45 ,0x06
   ,0xd0 ,0x2c ,0x1e ,0x8f ,0xca ,0x3f ,0x0f ,0x02 ,0xc1 ,0xaf ,0xbd ,0x03 ,0x01 ,0x13 ,0x8a ,0x6b
   ,0x3a ,0x91 ,0x11 ,0x41 ,0x4f ,0x67 ,0xdc ,0xea ,0x97 ,0xf2 ,0xcf ,0xce ,0xf0 ,0xb4 ,0xe6 ,0x73
   ,0x96 ,0xac ,0x74 ,0x22 ,0xe7 ,0xad ,0x35 ,0x85 ,0xe2 ,0xf9 ,0x37 ,0xe8 ,0x1c ,0x75 ,0xdf ,0x6e
   ,0x47 ,0xf1 ,0x1a ,0x71 ,0x1d ,0x29 ,0xc5 ,0x89 ,0x6f ,0xb7 ,0x62 ,0x0e ,0xaa ,0x18 ,0xbe ,0x1b
   ,0xfc ,0x56 ,0x3e ,0x4b ,0xc6 ,0xd2 ,0x79 ,0x20 ,0x9a ,0xdb ,0xc0 ,0xfe ,0x78 ,0xcd ,0x5a ,0xf4
   ,0x1f ,0xdd ,0xa8 ,0x33 ,0x88 ,0x07 ,0xc7 ,0x31 ,0xb1 ,0x12 ,0x10 ,0x59 ,0x27 ,0x80 ,0xec ,0x5f
   ,0x60 ,0x51 ,0x7f ,0xa9 ,0x19 ,0xb5 ,0x4a ,0x0d ,0x2d ,0xe5 ,0x7a ,0x9f ,0x93 ,0xc9 ,0x9c ,0xef
   ,0xa0 ,0xe0 ,0x3b ,0x4d ,0xae ,0x2a ,0xf5 ,0xb0 ,0xc8 ,0xeb ,0xbb ,0x3c ,0x83 ,0x53 ,0x99 ,0x61
   ,0x17 ,0x2b ,0x04 ,0x7e ,0xba ,0x77 ,0xd6 ,0x26 ,0xe1 ,0x69 ,0x14 ,0x63 ,0x55 ,0x21 ,0x0c ,0x7d};



int elevatorc[] = {254, 252, 250, 248, 246, 244, 242, 240, 238, 236, 234, 232, 230, 228, 226, 224, 222, 220, 218, 216, 214, 212, 210, 208, 206, 204, 202, 200, 198, 196, 194, 192, 190, 188, 186, 184, 182, 180, 178, 176, 174, 172, 170, 168, 166, 164, 162, 160, 158, 156, 154, 152, 150, 148, 146, 144, 142, 140, 138, 136, 134, 132, 130, 128, 126, 124, 122, 120, 118, 116, 114, 112, 110, 108, 106, 104, 102, 100, 98, 96, 94, 92, 90, 88, 86, 84, 82, 80, 78, 76, 74, 72, 70, 68, 66, 64, 62, 60, 58, 56, 54, 52, 50, 48, 46, 44, 42, 40, 38, 36, 34, 32, 30, 28, 26, 24, 22, 20, 18, 16, 14, 12, 10, 8, 6, 4, 2, 0, 1, 3, 5, 7, 9, 11, 13, 15, 17, 19, 21, 23, 25, 27, 29, 31, 33, 35, 37, 39, 41, 43, 45, 47, 49, 51, 53, 55, 57, 59, 61, 63, 65, 67, 69, 71, 73, 75, 77, 79, 81, 83, 85, 87, 89, 91, 93, 95, 97, 99, 101, 103, 105, 107, 109, 111, 113, 115, 117, 119, 121, 123, 125, 127, 129, 131, 133, 135, 137, 139, 141, 143, 145, 147, 149, 151, 153, 155, 157, 159, 161, 163, 165, 167, 169, 171, 173, 175, 177, 179, 181, 183, 185, 187, 189, 191, 193, 195, 197, 199, 201, 203, 205, 207, 209, 211, 213, 215, 217, 219, 221, 223, 225, 227, 229, 231, 233, 235, 237, 239, 241, 243, 245, 247, 249, 251, 253, 255};


int elevatori[] = {5, 72, 191, 223, 255, 8, 18, 36, 65, 68, 80, 126, 127, 129, 136, 239, 254, 12, 34, 66, 83, 95, 123, 130, 145, 166, 208, 17, 44, 58, 82, 159, 187, 192, 247, 251, 14, 22, 57, 84, 124, 125, 147, 156, 165, 219, 222, 224, 243, 245, 253, 48, 89, 105, 111, 188, 194, 215, 237, 250, 252, 29, 56, 175, 176, 183, 190, 235, 63, 170, 189, 242, 28, 46, 135, 201, 210, 37, 60, 199, 221, 167, 40, 153, 20, 64, 160, 134, 32, 4, 3, 96, 144, 6, 196, 16, 33, 9, 24, 2, 128, 0, 43, 249, 151, 1, 246, 204, 75, 238, 119, 197, 198, 164, 76, 163, 26, 106, 118, 169, 35, 104, 216, 209, 110, 15, 154, 217, 7, 100, 212, 143, 93, 13, 226, 234, 120, 229, 77, 205, 59, 133, 173, 213, 206, 73, 142, 79, 155, 137, 207, 45, 228, 121, 49, 85, 148, 21, 180, 131, 23, 172, 141, 54, 162, 241, 231, 52, 150, 195, 117, 113, 71, 214, 168, 248, 181, 138, 115, 103, 232, 218, 51, 185, 107, 90, 200, 39, 94, 184, 67, 236, 174, 109, 114, 171, 149, 220, 102, 92, 50, 186, 182, 88, 41, 177, 230, 47, 240, 152, 202, 179, 158, 140, 74, 193, 146, 87, 161, 98, 30, 91, 112, 101, 233, 31, 227, 62, 225, 81, 78, 122, 157, 61, 42, 203, 53, 69, 108, 139, 70, 244, 86, 132, 116, 211, 25, 178, 11, 19, 55, 99, 97, 27, 10, 38};


int hw[256] = {0, 1, 1, 2, 1, 2, 2, 3, 1, 2, 2, 3, 2, 3, 3, 4, 1, 2, 2, 3, 2, 3, 3, 4, 2, 3, 3, 4, 3, 4, 4, 5, 1, 2, 2, 3, 2, 3, 3, 4, 2, 3, 3, 4, 3, 4, 4, 5, 2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 6, 1, 2, 2, 3, 2, 3, 3, 4, 2, 3, 3, 4, 3, 4, 4, 5, 2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 6, 2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 6, 3, 4, 4, 5, 4, 5, 5, 6, 4, 5, 5, 6, 5, 6, 6, 7, 1, 2, 2, 3, 2, 3, 3, 4, 2, 3, 3, 4, 3, 4, 4, 5, 2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 6, 2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 6, 3, 4, 4, 5, 4, 5, 5, 6, 4, 5, 5, 6, 5, 6, 6, 7, 2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 6, 3, 4, 4, 5, 4, 5, 5, 6, 4, 5, 5, 6, 5, 6, 6, 7, 3, 4, 4, 5, 4, 5, 5, 6, 4, 5, 5, 6, 5, 6, 6, 7, 4, 5, 5, 6, 5, 6, 6, 7, 5, 6, 6, 7, 6, 7, 7, 8};


uint32 expect_key[16];// = {65, 239, 40, 131, 86, 120, 56, 228, 157, 240, 16, 193, 242, 72, 22, 139};


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
void generateLists();
void printDebug();
void MCFilter();
uint32 xtimes_i(uint32 a);
void readFile(FILE *f);

//Global Variables
id<ORModel> model;
id<ORIdArray> ca;
id<ORRealVar> y;
int SC[9][16];
int* p_SC = SC;

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
uint32 i_zero = 0x00;
id<ORBitVar> zero;
int s_SC[64];
UInt32 num_checks = 0;
unsigned int Plaintext[16];// = {197,174,245,236,70,202,43,217,26,99,198,174,222,3,132,138};
int elevator[8][256];
int elevator_1[] = {0,1};
int elevator_2[] = {1,2,0,3};
int elevator_3[] = {3, 4, 2, 5, 1, 6, 0, 7};
int elevator_4[] = {7, 8, 6, 9, 5, 10, 4, 11, 3, 12, 2, 13, 1, 14, 0, 15};
int elevator_5[] = {15, 16, 14, 17, 13, 18, 12, 19, 11, 20, 10, 21, 9, 22, 8, 23, 7, 24, 6, 25, 5, 26, 4, 27, 3, 28, 2, 29, 1, 30, 0, 31};
int elevator_6[] = {31, 32, 30, 33, 29, 34, 28, 35, 27, 36, 26, 37, 25, 38, 24, 39, 23, 40, 22, 41, 21, 42, 20, 43, 19, 44, 18, 45, 17, 46, 16, 47, 15, 48, 14, 49, 13, 50, 12, 51, 11, 52, 10, 53, 9, 54, 8, 55, 7, 56, 6, 57, 5, 58, 4, 59, 3, 60, 2, 61, 1, 62, 0, 63};
int elevator_7[] = {63, 64, 62, 65, 61, 66, 60, 67, 59, 68, 58, 69, 57, 70, 56, 71, 55, 72, 54, 73, 53, 74, 52, 75, 51, 76, 50, 77, 49, 78, 48, 79, 47, 80, 46, 81, 45, 82, 44, 83, 43, 84, 42, 85, 41, 86, 40, 87, 39, 88, 38, 89, 37, 90, 36, 91, 35, 92, 34, 93, 33, 94, 32, 95, 31, 96, 30, 97, 29, 98, 28, 99, 27, 100, 26, 101, 25, 102, 24, 103, 23, 104, 22, 105, 21, 106, 20, 107, 19, 108, 18, 109, 17, 110, 16, 111, 15, 112, 14, 113, 13, 114, 12, 115, 11, 116, 10, 117, 9, 118, 8, 119, 7, 120, 6, 121, 5, 122, 4, 123, 3, 124, 2, 125, 1, 126, 0, 127};
int elevator_8[] = {127, 128, 126, 129, 125, 130, 124, 131, 123, 132, 122, 133, 121, 134, 120, 135, 119, 136, 118, 137, 117, 138, 116, 139, 115, 140, 114, 141, 113, 142, 112, 143, 111, 144, 110, 145, 109, 146, 108, 147, 107, 148, 106, 149, 105, 150, 104, 151, 103, 152, 102, 153, 101, 154, 100, 155, 99, 156, 98, 157, 97, 158, 96, 159, 95, 160, 94, 161, 93, 162, 92, 163, 91, 164, 90, 165, 89, 166, 88, 167, 87, 168, 86, 169, 85, 170, 84, 171, 83, 172, 82, 173, 81, 174, 80, 175, 79, 176, 78, 177, 77, 178, 76, 179, 75, 180, 74, 181, 73, 182, 72, 183, 71, 184, 70, 185, 69, 186, 68, 187, 67, 188, 66, 189, 65, 190, 64, 191, 63, 192, 62, 193, 61, 194, 60, 195, 59, 196, 58, 197, 57, 198, 56, 199, 55, 200, 54, 201, 53, 202, 52, 203, 51, 204, 50, 205, 49, 206, 48, 207, 47, 208, 46, 209, 45, 210, 44, 211, 43, 212, 42, 213, 41, 214, 40, 215, 39, 216, 38, 217, 37, 218, 36, 219, 35, 220, 34, 221, 33, 222, 32, 223, 31, 224, 30, 225, 29, 226, 28, 227, 27, 228, 26, 229, 25, 230, 24, 231, 23, 232, 22, 233, 21, 234, 20, 235, 19, 236, 18, 237, 17, 238, 16, 239, 15, 240, 14, 241, 13, 242, 12, 243, 11, 244, 10, 245, 9, 246, 8, 247, 7, 248, 6, 249, 5, 250, 4, 251, 3, 252, 2, 253, 1, 254, 0, 255};

int prob[] = {7, 11, 13, 14, 19, 21, 22, 25, 26, 28, 31, 35, 37, 38, 41, 42, 44, 47, 49, 50, 52, 55, 56, 59, 61, 62, 67, 69, 70, 73, 74, 76, 79, 81, 82, 84, 87, 88, 91, 93, 94, 97, 98, 100, 103, 104, 107, 109, 110, 112, 115, 117, 118, 121, 122, 124, 131, 133, 134, 137, 138, 140, 143, 145, 146, 148, 151, 152, 155, 157, 158, 161, 162, 164, 167, 168, 171, 173, 174, 176, 179, 181, 182, 185, 186, 188, 193, 194, 196, 199, 200, 203, 205, 206, 208, 211, 213, 214, 217, 218, 220, 224, 227, 229, 230, 233, 234, 236, 241, 242, 244, 248, 15, 23, 27, 29, 30, 39, 43, 45, 46, 51, 53, 54, 57, 58, 60, 71, 75, 77, 78, 83, 85, 86, 89, 90, 92, 99, 101, 102, 105, 106, 108, 113, 114, 116, 120, 135, 139, 141, 142, 147, 149, 150, 153, 154, 156, 163, 165, 166, 169, 170, 172, 177, 178, 180, 184, 195, 197, 198, 201, 202, 204, 209, 210, 212, 216, 225, 226, 228, 232, 240, 3, 5, 6, 9, 10, 12, 17, 18, 20, 24, 33, 34, 36, 40, 48, 63, 65, 66, 68, 72, 80, 95, 96, 111, 119, 123, 125, 126, 129, 130, 132, 136, 144, 159, 160, 175, 183, 187, 189, 190, 192, 207, 215, 219, 221, 222, 231, 235, 237, 238, 243, 245, 246, 249, 250, 252, 1, 2, 4, 8, 16, 32, 64, 127, 128, 191, 223, 239, 247, 251, 253, 254, 0, 255};

unsigned int p_list[48][256];
unsigned int p_count[48];
int p_min[48];
int p_max[48];

int hw_hits[48][256];
int hw_hits_sum[48];
int p_hwcount[48][3];
int value[256];
int sum_value[48];
bool attempted[48];
//id<ORMutableInteger> phase[48];
id<ORMutableInteger> phase;
int hw_mode[48];

int main(int argc, const char * argv[]) {
   FILE* instance = fopen("/Users/ldm/work/objcppriv/Clo/FanghuiTest/origInstance", "r");
   readFile(instance);
   ORCmdLineArgs* cmd = [ORCmdLineArgs newWith:argc argv:argv];
   ORInt kKeys = [cmd size];
   model = [ORFactory createModel];
   ca = NULL;
   zero = [ORFactory bitVar:model low:&i_zero up:&i_zero bitLength:8];
   
   xor1b = [ORFactory bitVar:model low:&i_xor1b up:&i_xor1b bitLength:8];
   
   
   uint32 rconstant[] = {1,2,4,8,16,32,64,128,27,54};
   
   uint32 cipher[] = {176,88,179,224,18,226,231,218,39,76,161,2,20,119,14,183};
   
   //uint32 cipher2[] = {4,79,253,149,226,60,238,192,17,123,136,192,248,95,102,123};
   
   int totalstates = 0;
   
   error_count = 0;
   
   for(int i = 0; i < 32; i++){
      p_count[i] = 0;
      p_min[i] = 1000;
      p_max[i] = -1;
      for(int j = 0; j < 256; j++){
         p_list[i][j] = -1;
      }
   }
   
   for(int i = 0; i < 8; i++)
      for(int j = 0; j < 256; j++)
         elevator[i][j] = 0;
   
   for(int j = 0; j < 2; j++)
      elevator[0][j] = elevator_1[j];
   
   for(int j = 0; j < 4; j++)
      elevator[1][j] = elevator_2[j];
   
   for(int j = 0; j < 8; j++)
      elevator[2][j] = elevator_3[j];
   
   for(int j = 0; j < 16; j++)
      elevator[3][j] = elevator_4[j];
   
   for(int j = 0; j < 32; j++)
      elevator[4][j] = elevator_5[j];
   
   for(int j = 0; j < 64; j++)
      elevator[5][j] = elevator_6[j];
   
   for(int j = 0; j < 128; j++)
      elevator[6][j] = elevator_7[j];
   
   for(int j = 0; j < 256; j++)
      elevator[7][j] = elevator_8[j];
   
   
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
         if(w < kKeys)
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
   
   
   id<ORIntRange> R = [[ORIntRangeI alloc] initORIntRangeI:0 up:47];
   
   id<ORBitVarArray> o = (id)[CPFactory bitVarArray:model range: R];
   
   for(ORInt k=0;k <= 15;k++)
      [o set:keys[0][k] at:k];
   
   for(ORInt k=0;k <= 15;k++)
      [o set:states[1][k] at:(k+16)];
   
   for(ORInt k=0;k <= 15;k++)
      [o set:states[2][k] at:(k+32)];
   
   
   /*
    for(ORInt k=0;k <= 15;k++)
    [o set:keys[0][k] at:(k+48)];
    
    for(ORInt k=0;k <= 15;k++)
    [o set:states[1][k] at:(k+64)];
    
    for(ORInt k=0;k <= 15;k++)
    [o set:states[2][k] at:(k+80)];
    */
   
   //    for(int i = 0; i < 48; i++)
   //        phase[i] = [ORFactory mutable:model value:3];
   phase = [ORFactory mutable:model value:3];
   
   id<ORIntVarArray> iv = [model intVars];
   id<ORBitVarArray> av = [model bitVars];
   
   //id<CPProgram,CPBV> cp = (id)[ORFactory createCPProgram: model];
   //id<CPProgram,CPBV> cp = (id)[ORFactory createCPSemanticProgramDFS:model];
   id<CPProgram,CPBV> cp = (id)[ORFactory createCPParProgram:model nb:[cmd nbThreads] with:[ORSemDFSController proto]];
   generateLists();
   MCFilter();
   printDebug();
   ORLong searchStart = [ORRuntimeMonitor wctime];
   id<ORIntSet> phaseNames = [ORFactory intSet:cp];
   [phaseNames insert:3];
   [phaseNames insert:2];
   [phaseNames insert:1];
   [phaseNames insert:0];
   
   
   
   [cp solve:^(){
      NSLog(@"Search Started: ;-)");
      
      //Attempt all values that results in no error
      [cp forall:R suchThat:^ORBool(ORInt i) {return [cp domsize: o[i]] > 0;} orderedBy:^ORInt(ORInt i) {
         //NSLog(@"pcount %d", p_hwcount[i][1]);
         int isphase = [phase intValue:cp];
         return (-isphase << 20) + (-1 * abs(4 - s_SC[i]) << 10) + p_count[i];
      }
              do:^(ORInt s) {
                 id<ORIntRange> S = [ORFactory intRange:cp low:0 up:(p_count[s] - 1)];
                 
                 [cp tryall:phaseNames suchThat:nil orderedBy:^ORDouble(ORInt pn) { return -pn;}
                         in: ^void(ORInt pn) {
                            int evalue = pn;
                            [phase setValue:pn in:cp];
                            [cp tryall:S suchThat:^ORBool(ORInt k) { return hw_hits[s][p_list[s][k]] == evalue;} orderedBy:^ORDouble(ORInt k) {
                                 return -(hw_hits[s][p_list[s][k]] << 10) + elevatori[s];
                            }
                                    in:^(ORInt k) {
                                       //assert(s >= 0  && s <= 47);
                                       ORInt i = p_list[s][k]; //elevator[size-1][k];
                                       [cp atomic:^{
                                          ORUInt count = 0;
                                          for(int nbit = 0; nbit < 8; nbit++){
                                             BOOL val = (i >> count++) & 1;
                                             [cp labelBV:o[s] at:nbit with:val]; // if the bit is already fixed, attempting to fix it to something else fails.
                                          }
                                       }];
                                    } onFailure:^(ORInt i) {}];
                         }
                  onFailure: ^void(ORInt pn) {
                  
                  }];

              }];
      
      //id<ORMutableInteger> test = phase[s];
      
      //NSLog(@"Testing BV(%d): Phase:%d",s,[test intValue:cp]);
      /*
       [cp try:^{
       id<ORIntRange> S = [ORFactory intRange:cp low:0 up:(p_count[s] - 1)];
       
       [cp tryall:S suchThat:^ORBool(ORInt k) { return hw[p_list[s][k]] == s_SC[s];} orderedBy:^ORDouble(ORInt z) {
       //return elevatori[z];
       //return -value[z];
       //return value[z];
       return -(hw_hits[s][p_list[s][z]] << 10) + elevatori[s];
       return -hw_hits[s][p_list[s][z]];
       //return hw_hits[p_list[s][z]];//elevatori[z];
       }
       in:^(ORInt k) {
       
       //assert(s >= 0  && s <= 47);
       ORInt i = p_list[s][k]; //elevator[size-1][k];
       [cp atomic:^{
       
       int aux1, aux2;
       uint32 val1, val2;
       if(s < 16){
       aux1 = s+16;
       val1 = (i ^ Plaintext[s%16]);
       aux2 = s+32;
       val2 = sb[val1];
       }
       else if(s < 32){
       aux1 = s-16;
       val1 = (i ^ Plaintext[s%16]);
       aux2 = s+16;
       val2 = sb[i];
       }
       else{
       aux1 = s-16;
       val1 = inv_s[i];
       aux2 = s-32;
       val2 = (val1 ^ Plaintext[s%16]);
       }
       
       uint32 count = 0;
       for(int nbit = 0; nbit < 8; nbit++){
       BOOL val = (i >> count) & 1;
       BOOL vala = (val1 >> count) & 1;
       BOOL valb = (val2 >> count++) & 1;
       [cp labelBV:o[s] at:nbit with:val]; // if the bit is already fixed, attempting to fix it to something else fails.
       [cp labelBV:o[aux1] at:nbit with:vala];
       [cp labelBV:o[aux2] at:nbit with:valb];
       }
       }];
       } onFailure:^(ORInt i) {
       //NSLog(@"Failed");
       //Do Nothing
       }];
       
       
       } alt:^{
       
       id<ORMutableInteger> test = phase[s];
       
       [test setValue:1 in:cp];
       
       id<ORIntRange> S = [ORFactory intRange:cp low:0 up:(p_count[s] - 1)];
       
       [cp tryall:S suchThat:^ORBool(ORInt k) { return hw[p_list[s][k]] != s_SC[s];} orderedBy:^ORDouble(ORInt z) {
       //return -value[z];
       return -(hw_hits[s][p_list[s][z]] << 10) - z;// elevatori[s];
       //return value[z];
       //return -elevatori[s];
       //return -value[z];
       //return hw_hits[s][p_list[s][z]];
       
       }
       in:^(ORInt k) {
       
       //assert(s >= 0  && s <= 47);
       ORInt i = p_list[s][k]; //elevator[size-1][k];
       [cp atomic:^{
       
       int aux1, aux2;
       uint32 val1, val2;
       if(s < 16){
       aux1 = s+16;
       val1 = (i ^ Plaintext[s%16]);
       aux2 = s+32;
       val2 = sb[val1];
       }
       else if(s < 32){
       aux1 = s-16;
       val1 = (i ^ Plaintext[s%16]);
       aux2 = s+16;
       val2 = sb[i];
       }
       else{
       aux1 = s-16;
       val1 = inv_s[i];
       aux2 = s-32;
       val2 = (val1 ^ Plaintext[s%16]);
       }
       
       uint32 count = 0;
       for(int nbit = 0; nbit < 8; nbit++){
       BOOL val = (i >> count) & 1;
       BOOL vala = (val1 >> count) & 1;
       BOOL valb = (val2 >> count++) & 1;
       [cp labelBV:o[s] at:nbit with:val]; // if the bit is already fixed, attempting to fix it to something else fails.
       [cp labelBV:o[aux1] at:nbit with:vala];
       [cp labelBV:o[aux2] at:nbit with:valb];
       }
       }];
       } onFailure:^(ORInt i) {
       //NSLog(@"Failed");
       //Do Nothing
       }];
       }];
       
       }];
       */
      
      [cp labelArrayFF:iv];
      
      ORLong searchStop = [ORRuntimeMonitor wctime];
      ORDouble elapsed = ((ORDouble)searchStop - searchStart) / 1000.0;
      @autoreleasepool {
         ORInt tid = [NSThread threadID];
         assert([cp ground]  == YES);
         NSLog(@"[thread:%d]     Search Time (s): %f",tid,elapsed);
         NSLog(@"[thread:%d] Objective Function : %@",tid,[cp objectiveValue]);
         NSLog(@"[thread:%d]            Choices : %d / %d",tid,[cp nbChoices],[cp nbFailures]);
         
         for(int i = 0; i < 16; i++){
            NSLog(@" %@", [cp stringValue:keys[0][i]]);
            
         }
      }
   }];
   /*
    [cp solveAll:^(){
    NSLog(@"Search Started: ;-)");
    //NSLog(@"Minivar: %@", miniVar);
    
    //Attempt all values that results in no error
    [cp forall:R suchThat:^ORBool(ORInt i) {return [cp domsize: o[i]] > 0;} orderedBy:^ORInt(ORInt i) {
    //NSLog(@"pcount %d", p_hwcount[i][1]);
    return p_hwcount[i][1]; // number of values that results in no error
    }
    do:^(ORInt s) {
    id<ORIntRange> S = [ORFactory intRange:cp low:0 up:(p_count[s] - 1)];
    
    [cp tryall:S suchThat:^ORBool(ORInt k) { return hw[p_list[s][k]] == s_SC[s];} orderedBy:^ORDouble(ORInt z) {
    //return -value[z];
    //return -hw_hits[s][p_list[s][z]];
    return -elevatori[z];
    }
    in:^(ORInt k) {
    
    //assert(s >= 0  && s <= 47);
    ORInt i = p_list[s][k]; //elevator[size-1][k];
    [cp atomic:^{
    
    int aux1, aux2;
    uint32 val1, val2;
    if(s < 16){
    aux1 = s+16;
    val1 = (i ^ Plaintext[s%16]);
    aux2 = s+32;
    val2 = sb[val1];
    }
    else if(s < 32){
    aux1 = s-16;
    val1 = (i ^ Plaintext[s%16]);
    aux2 = s+16;
    val2 = sb[i];
    }
    else{
    aux1 = s-16;
    val1 = inv_s[i];
    aux2 = s-32;
    val2 = (val1 ^ Plaintext[s%16]);
    }
    
    uint32 count = 0;
    for(int nbit = 0; nbit < 8; nbit++){
    BOOL val = (i >> count) & 1;
    BOOL vala = (val1 >> count) & 1;
    BOOL valb = (val2 >> count++) & 1;
    [cp labelBV:o[s] at:nbit with:val]; // if the bit is already fixed, attempting to fix it to something else fails.
    [cp labelBV:o[aux1] at:nbit with:vala];
    [cp labelBV:o[aux2] at:nbit with:valb];
    }
    }];
    } onFailure:^(ORInt i) {
    //NSLog(@"Failed");
    //Do Nothing
    }];
    }];
    
    [cp forall:R suchThat:^ORBool(ORInt i) {return [cp domsize: o[i]] > 0;} orderedBy:^ORInt(ORInt i) {
    return p_hwcount[i][0] + p_hwcount[i][2]; // number of values that results in error
    }
    do:^(ORInt s) {
    // assert(size != 0);
    id<ORIntRange> S = [ORFactory intRange:cp low:0 up:(p_count[s] - 1)];
    [cp tryall:S suchThat:^ORBool(ORInt k) { return hw[p_list[s][k]] != s_SC[s];} orderedBy:^ORDouble(ORInt z) {
    return elevatori[z];
    }
    in:^(ORInt k) {
    //assert(s >= 0  && s <= 47);
    ORInt i = p_list[s][k]; //elevator[size-1][k];
    [cp atomic:^{
    int aux1, aux2;
    uint32 val1, val2;
    if(s < 16){
    aux1 = s+16;
    val1 = (i ^ Plaintext[s%16]);
    aux2 = s+32;
    val2 = sb[val1];
    }
    else if(s < 32){
    aux1 = s-16;
    val1 = (i ^ Plaintext[s%16]);
    aux2 = s+16;
    val2 = sb[i];
    }
    else{
    aux1 = s-16;
    val1 = inv_s[i];
    aux2 = s-32;
    val2 = (val1 ^ Plaintext[s%16]);
    }
    
    uint32 count = 0;
    for(int nbit = 0; nbit < 8; nbit++){
    BOOL val = (i >> count) & 1;
    BOOL vala = (val1 >> count) & 1;
    BOOL valb = (val2 >> count++) & 1;
    [cp labelBV:o[s] at:nbit with:val]; // if the bit is already fixed, attempting to fix it to something else fails.
    [cp labelBV:o[aux1] at:nbit with:vala];
    [cp labelBV:o[aux2] at:nbit with:valb];
    }
    }];
    } onFailure:^(ORInt i) {
    //NSLog(@"Failed");
    //Do Nothing
    }];
    }];
    
    
    
    
    [cp labelArrayFF:iv];
    
    ORLong searchStop = [ORRuntimeMonitor wctime];
    ORDouble elapsed = ((ORDouble)searchStop - searchStart) / 1000.0;
    @autoreleasepool {
    ORInt tid = [NSThread threadID];
    assert([cp ground]  == YES);
    NSLog(@"[thread:%d]     Search Time (s): %f",tid,elapsed);
    NSLog(@"[thread:%d] Objective Function : %@",tid,[cp objectiveValue]);
    NSLog(@"[thread:%d]            Choices : %d / %d",tid,[cp nbChoices],[cp nbFailures]);
    
    for(int i = 0; i < 16; i++){
    NSLog(@" %@", [cp stringValue:keys[0][i]]);
    
    }
    }
    }];
    */
   
   id<ORSolutionPool> solutions = [cp solutionPool];
   ORInt numberSol = [solutions count];
   ORLong searchStop = [ORRuntimeMonitor wctime];
   ORDouble elapsed = ((ORDouble)searchStop - searchStart) / 1000.0;
   NSLog(@"FinishTime (s): %f",elapsed);
   NSLog(@"Choices: %d / %d",[cp nbChoices],[cp nbFailures]);
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
   //[model add:[ORFactory bit:b1 equalb:b2 eval:zero]];
}

void SideChannel(id<ORBitVar> x, int sc){
   
   errorPtr[2 * error_count]     = [ORFactory boolVar:model];
   errorPtr[2 * error_count + 1] = [ORFactory boolVar:model];
   [model add: [[errorPtr[2 * error_count] plus: errorPtr[2 * error_count + 1]] neq: @(2)]];
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
   /*
    int SC[9][16] =
    {
    {4, 5, 6, 5, 3, 4, 4, 5, 4, 4, 4, 5, 6, 2, 2, 3}, //(0) Plaintext
    {2, 2, 6, 6, 1, 4, 3, 5, 4, 4, 5, 5, 3, 4, 3, 1}, //
    {6, 3, 3, 3, 4, 5, 6, 4, 3, 5, 6, 3, 4, 6, 5, 5}, //
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}, //3
    {4, 3, 3, 3, 4, 3, 4, 3, 2,-1,-1,-1,-1,-1,-1,-1},
    {5, 3, 2, 4, 5, 6, 5, 3, 3,-1,-1,-1,-1,-1,-1,-1},
    {1, 3, 4, 4, 4, 5, 6, 2, 2,-1,-1,-1,-1,-1,-1,-1},
    {4, 5, 8, 7, 6, 5, 4, 5, 4,-1,-1,-1,-1,-1,-1,-1},
    {2, 7, 2, 4, 4, 4, 3, 4, 5, 4, 1, 3, 6, 2, 3, 5}
    };
    */
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
            if(k > p_max[v])
               p_max[v] = k;
            if(k < p_min[v])
               p_min[v] = k;
         }
         
         if( k == 174 && v == 1){
            if(testb)
               //NSLog(@"testb Passed!");
               if(testc)
                  //NSLog(@"testb Passed!");
                  if((count) <= (s_SC[v] + 1) && (count) >= (s_SC[v] - 1)){
                     //NSLog(@"Origin Hamming-Weight Passed!");
                  }
                  else{
                     //NSLog(@"Origin Hamming-Weight Failed! should be: %d is: %d", s_SC[v], count);
                  }
            
            if(count2 <= (s_SC[var] + 1) && count2 >= (s_SC[var] - 1)){
               //NSLog(@"Remote Hamming-Weight Passed!");
            }
            else{
               //NSLog(@"Remote Hamming-Weight Failed! var: %d should be: %d is: %d", var, s_SC[var], count2);
            }
         }
      }
   }
   /*
    for(int i = 16; i < 32; i++){
    for(int j = 0; j < p_count[i]; j++){
    p_list[i-16][j] = (p_list[i][j] ^ Plaintext[i-16]);
    }
    p_count[i-16] = p_count[i];
    }
    */
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
         
         //NSLog(@"count1: %d", p_count[tempc[0]]);
         //NSLog(@"count2: %d", p_count[tempc[1]]);
         //NSLog(@"count3: %d", p_count[tempc[2]]);
         //NSLog(@"count4: %d", p_count[tempc[0]]);
         
         
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
         int state2 = (col*4+(5*eq)+5)%16 + 16;
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
            if(!toggle){
               //NSLog(@"REDUCTION!");
               count++;
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
            if(!toggle){
               //NSLog(@"REDUCTION!");
               count++;
            }
            
         }
         //NSLog(@"tc1: %d",tcount1);
         //NSLog(@"tc2: %d",tcount2);
         
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
   
   for(int i = 0; i < 48; i++){
      for(int j = 0; j < 3; j++){
         p_hwcount[i][j] = 0;
      }
   }
   
   for(int i = 0; i < 16; i++){
      for(int j = 0; j < p_count[i]; j++){
         if(hw[p_list[i][j]] == s_SC[i])
            p_hwcount[i][1]++;
         if(hw[p_list[i][j]] == s_SC[i] - 1)
            p_hwcount[i][0]++;
         if(hw[p_list[i][j]] == s_SC[i] + 1)
            p_hwcount[i][2]++;
      }
   }
   
   for(int i = 16; i < 32; i++){
      for(int j = 0; j < p_count[i]; j++){
         if(hw[p_list[i][j]] == s_SC[i])
            p_hwcount[i][1]++;
         if(hw[p_list[i][j]] == s_SC[i] - 1)
            p_hwcount[i][0]++;
         if(hw[p_list[i][j]] == s_SC[i] + 1)
            p_hwcount[i][2]++;
      }
   }
   
   for(int i = 32; i < 48; i++){
      for(int j = 0; j < p_count[i]; j++){
         if(hw[p_list[i][j]] == s_SC[i])
            p_hwcount[i][1]++;
         if(hw[p_list[i][j]] == s_SC[i] - 1)
            p_hwcount[i][0]++;
         if(hw[p_list[i][j]] == s_SC[i] + 1)
            p_hwcount[i][2]++;
      }
   }
   
   
   NSLog(@"count is %d!", count);
   
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
            NSLog(@"INCRE");
         }
         if(hw[(p_list[i][j] ^ Plaintext[i])] == s_SC[i+16]){
            hw_hits[i][p_list[i][j]] += 1;
            NSLog(@"INCRE");
            
         }
         if(hw[s[(p_list[i][j] ^ Plaintext[i])]] == s_SC[i+32]){
            hw_hits[i][p_list[i][j]] += 1;
            NSLog(@"INCRE");
            
         }
      }
   }
   
   //tm0 Filtering
   /*
    for(int col = 0; col < 4; col++){
    tmpcomp[0] = (col*4)%16 + 16;
    tmpcomp[1] = (col*4 + 5)%16 + 16;
    tmpcomp[2] = (col*4 + 10)%16 + 16;
    tmpcomp[3] = (col*4 + 15)%16 + 16;
    
    for(int j = 0; j < 4; j++){
    tempc[(j + 0) % 4] = tmpcomp[0];
    tempc[(j + 1) % 4] = tmpcomp[1];
    tempc[(j + 2) % 4] = tmpcomp[2];
    tempc[(j + 3) % 4] = tmpcomp[3];
    
    for(int a = 0; a < p_count[tempc[0]]; a++){
    int vala = s[p_list[tempc[0]][a]];
    bool toggle = false;
    for(int b = 0; b < p_count[tempc[1]]; b++){
    int valb = s[p_list[tempc[1]][b]];
    for(int c = 0; c < p_count[tempc[2]]; c++){
    int valc = s[p_list[tempc[2]][c]];
    for(int d = 0; d < p_count[tempc[3]]; d++){
    int vald = s[p_list[tempc[3]][d]];
    int sum = vala ^ valb ^ valc ^ vald;
    if(hw[sum] == SC[4 + col][0]){
    toggle = true;
    //NSLog(@"NEW");
    
    hw_hits[tempc[0]][p_list[tempc[0]][a]]++;
    break;
    }
    }
    if(toggle)
    break;
    }
    if(toggle)
    break;
    }
    }
    }
    }
    
    //tmp1 & tmp2 Filtering
    for(int col = 0; col < 4; col++){
    for(int eq = 0; eq < 4; eq++){
    
    int state1 = (col*4+(5*eq))%16 + 16;
    int state2 = (col*4+(5*eq)+5)%16 + 16;
    for(int j = 0; j < p_count[state1]; j++){
    bool toggle = false;
    for(int k = 0; k < p_count[state2]; k++){
    uint32 tm1 = s[p_list[state1][j]] ^ s[p_list[state2][k]];
    int tm1hw = hw[tm1];
    if(!toggle && (tm1hw == SC[4 + col][2*eq + 1] + 1) && (hw[xtimes_i(tm1)] == SC[4 + col][2*eq + 2] - 1) ){
    toggle = true;
    //NSLog(@"NEW");
    hw_hits[state1][p_list[state1][j]]++;
    }
    }
    }
    
    for(int j = 0; j < p_count[state2]; j++){
    bool toggle = false;
    for(int k = 0; k < p_count[state1]; k++){
    uint32 tm1 = s[p_list[state2][j]] ^ s[p_list[state1][k]];
    int tm1hw = hw[tm1];
    if(!toggle && (tm1hw == SC[4 + col][2*eq + 1] + 1) && (hw[xtimes_i(tm1)] == SC[4 + col][2*eq + 2] - 1) ){
    //NSLog(@"NEW");
    toggle = true;
    hw_hits[state2][p_list[state2][j]]++;
    }
    }
    }
    }
    }
    */
   /*
    for(int i = 16; i < 32; i++){
    for(int j = 0; j < p_count[i]; j++){
    hw_hits[i+16][s[p_list[i][j]]] = hw_hits[i][p_list[i][j]];
    hw_hits[i-16][p_list[i][j] ^ Plaintext[i % 16]] = hw_hits[i][p_list[i][j]];
    }
    }
    */
   
   
   
   for(int i = 0; i < 16; i++){
      for(int j = 0; j < p_count[i]; j++){
         hw_hits[i+32][s[p_list[i][j] ^ Plaintext[i % 16]]] = hw_hits[i][p_list[i][j]];
         hw_hits[i+16][p_list[i][j] ^ Plaintext[i % 16]] = hw_hits[i][p_list[i][j]];
      }
   }
   
   
   int modetest[4] = {0,0,0,0};
   
   for(int i = 0; i < 48; i++){
      for(int j = 0; j < p_count[i]; j++){
         modetest[hw_hits[i][p_list[i][j]]]++;
      }
      /*
       int a = max(modetest[2],modetest[1]);
       int b = max(modetest[3],modetest[2]);
       int r = max(a,b);
       
       //if(modetest[0] == r) hw_mode[i] = 0;
       if(modetest[1] == r) hw_mode[i] = 1;
       if(modetest[2] == r) hw_mode[i] = 2;
       if(modetest[3] == r) hw_mode[i] = 3;
       */
      hw_mode[i] = modetest[3];
      
      modetest[0] = 0;
      modetest[1] = 0;
      modetest[2] = 0;
      modetest[3] = 0;
      
   }
   
   
   /*
    for(int i = 32; i < 48; i++){
    for(int j = 0; j < p_count[i]; j++){
    if(hw[p_list[i][j]] == s_SC[i])
    hw_hits[i][p_list[i][j]]++;
    if(hw[inv_s[p_list[i][j]]] == s_SC[i-16])
    hw_hits[i][p_list[i][j]]++;
    if(hw[(inv_s[p_list[i][j]] ^ Plaintext[i])] == s_SC[i-32])
    hw_hits[i][p_list[i][j]]++;
    }
    }
    */
   
   
   int hcount[8];
   hcount[0] = 0;
   hcount[1] = 0;
   hcount[2] = 0;
   hcount[3] = 0;
   hcount[4] = 0;
   hcount[5] = 0;
   hcount[6] = 0;
   hcount[7] = 0;
   
   
   
   for(int i = 0; i < 48; i++){
      for(int j = 0; j < p_count[i]; j++){
         if(hw_hits[i][j] != -1)
            hcount[hw_hits[i][j]]++;
      }
   }
   
   
   for(int i=0; i<256; i++) value[i] = 0;
   for(int i=0; i<48; i++) sum_value[i] = 0;
   
   
   for(int i = 0; i < 48; i++){
      for(int j = 0; j < p_count[i]; j++){
         //if(s_SC[i] == hw[p_list[i][j]])
         //value[p_list[i][j]] += 4;//= hw_hits[i][j] + 1;
         //else
         if(s_SC[i] == hw[p_list[i][j]])
            value[p_list[i][j]]++;//= hw_hits[i][j] + 1;
         
      }
   }
   
   for(int i = 0; i < 48; i++){
      for(int j = 0; j < p_count[i]; j++){
         sum_value[i] += value[p_list[i][j]];
      }
   }
   
   printf("Value of num: ");
   for(int c = 0; c < 256; c++){
      printf("%d ", value[c]);
   }
   printf("\n");
   
   NSLog(@"Error: (7): %d | (6): %d | (5): %d | (4): %d (3): %d | (2): %d | (1): %d | (0): %d",hcount[0],hcount[1],hcount[2],hcount[3], hcount[4],hcount[5],hcount[6],hcount[7]);
   
   for(int i = 0; i < 48; i++){
      hw_hits_sum[i] = 0;
      for(int j = 0; j < p_count[i]; j++){
         if(hw[p_list[i][j]] == s_SC[i]){
            if(hw_hits[i][j] > 0 && hw_hits[i][j] < 4)
               hw_hits_sum[i] += (1 << ((hw_hits[i][j] - 1) * 4));
         }
      }
   }
   
}


void printDebug(){
   printf("SUM VALUES:");
   
   for (int v = 0; v < 48; v++){
      printf("%d ",sum_value[v]);
   }
   
   printf("\n");
   
   
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
   
   printf("Sum Dist Key:");
   
   for(int v = 0; v < 16; v++){
      for(int z = 0; z < p_count[v]; z++){
         if(p_list[v][z] == expect_key[v]){
            printf(" %d ", sum_value[v]);
         }
      }
   }
   
   printf("\n");
   
   printf("Sum Dist State:");
   
   
   for(int v = 16; v < 32; v++){
      for(int z = 0; z < p_count[v]; z++){
         if(p_list[v][z] == (expect_key[v%16] ^ Plaintext[v%16])){
            printf(" %d ", sum_value[v]);
         }
      }
   }
   
   printf("\n");
   
   printf("Sum Dist State:");
   
   
   for(int v = 32; v < 48; v++){
      for(int z = 0; z < p_count[v]; z++){
         if(p_list[v][z] == s[(expect_key[v%16] ^ Plaintext[v%16])]){
            printf(" %d ", sum_value[v]);
         }
      }
   }
   
   printf("\n");
   
   
   printf("Mode Dist Key:");
   
   for(int v = 0; v < 16; v++){
      for(int z = 0; z < p_count[v]; z++){
         if(p_list[v][z] == expect_key[v]){
            printf(" %d ", hw_mode[v]);
         }
      }
   }
   
   printf("\n");
   
   printf("Mode Dist State:");
   
   
   for(int v = 16; v < 32; v++){
      for(int z = 0; z < p_count[v]; z++){
         if(p_list[v][z] == (expect_key[v%16] ^ Plaintext[v%16])){
            printf(" %d ", hw_mode[v]);
         }
      }
   }
   
   printf("\n");
   
   printf("Mode Dist State:");
   
   
   for(int v = 32; v < 48; v++){
      for(int z = 0; z < p_count[v]; z++){
         if(p_list[v][z] == s[(expect_key[v%16] ^ Plaintext[v%16])]){
            printf(" %d ", hw_mode[v]);
         }
      }
   }
   
   printf("\n");
}

uint32 xtimes_i(uint32 a){
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
      else{
         p_SC[sc_count++] = atoi(x);
      }
      count++;
   }
   
   NSLog(@"count is %d", count);
}
