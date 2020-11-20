#import <ORProgram/ORProgram.h>
#import <objcp/CPFactory.h>
#import <objcp/CPConstraint.h>
#import <objcp/CPIntVarI.h>
#import <objcp/CPBitVar.h>
#import <objcp/CPBitVarI.h>
#import "ORCmdLineArgs.h"

ORInt tolerance;
const int BUCKETSIZE = 1;
const int NUMBUCKETS = 50;
enum Encryption {aes128 = 1, aes256 = 2};
int hitcount = 0;

ORUInt s[256] = {0x63 ,0x7c ,0x77 ,0x7b ,0xf2 ,0x6b ,0x6f ,0xc5 ,0x30 ,0x01 ,0x67 ,0x2b ,0xfe ,0xd7 ,0xab ,0x76
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

const uint8 hw[256] = {0, 1, 1, 2, 1, 2, 2, 3, 1, 2, 2, 3, 2, 3, 3, 4, 1, 2, 2, 3, 2, 3, 3, 4, 2, 3, 3, 4, 3, 4, 4, 5, 1, 2, 2, 3, 2, 3, 3, 4, 2, 3, 3, 4, 3, 4, 4, 5, 2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 6, 1, 2, 2, 3, 2, 3, 3, 4, 2, 3, 3, 4, 3, 4, 4, 5, 2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 6, 2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 6, 3, 4, 4, 5, 4, 5, 5, 6, 4, 5, 5, 6, 5, 6, 6, 7, 1, 2, 2, 3, 2, 3, 3, 4, 2, 3, 3, 4, 3, 4, 4, 5, 2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 6, 2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 6, 3, 4, 4, 5, 4, 5, 5, 6, 4, 5, 5, 6, 5, 6, 6, 7, 2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 6, 3, 4, 4, 5, 4, 5, 5, 6, 4, 5, 5, 6, 5, 6, 6, 7, 3, 4, 4, 5, 4, 5, 5, 6, 4, 5, 5, 6, 5, 6, 6, 7, 4, 5, 5, 6, 5, 6, 6, 7, 5, 6, 6, 7, 6, 7, 7, 8};

#define xtimes_i(X) (((X)<<1) ^ ((((X)>>7) & 1) * 0x11b))
#define scv(X,Y) (hw[(X)] <= (Y) + tolerance && hw[(X)] >= (Y) - tolerance)
#define scd(X,Y) (abs(hw[(X)] - (Y)))

struct SCInformation{
    uint8 plaintext[16];
    uint8 ciphertext[16];
    uint8 key[2][16];
    ORUInt obj_relax;
    ORUInt obj_complete;
    ORInt sc[140][16];
    ORInt s_SC[2][64];
};

struct StateVars{
    id<ORBitVar> states[58][16];
    id<ORBitVar> keys[15][16];
    id<ORBitVar> tm1[15][4][4];
    id<ORBitVar> tm2[15][4][4];
    id<ORBitVar> tm0[15][4];
    id<ORIdArray> sboxBV;
    id<ORIntVar> errorPtr[5000];
    id<ORIntVar> obj;
    id<ORIntVar> obj_relax;
    ORInt error_count;
    ORInt rounds;
    enum Encryption mode;
};


struct fval {
    uint8 val[4];
    uint8 pt[4];
    uint8 score;
};

struct pval {
    uint8 val;
    uint8 score;
};

struct vallist{
    struct pval list[256];
    int* offset;
    int size;
    int minscore;
    uint8 input;
};

struct fulllist{
    struct fval* list;
    int* offset;
    uint8 state[4];
    int size;
    int minscore;
    int maxsize;
};

//Function Prototypes
void XOR(id<ORModel> model, id<ORBitVar> a, id<ORBitVar> b, id<ORBitVar> outt);
void XORThree(id<ORModel> model, id<ORBitVar> a, id<ORBitVar> b, id<ORBitVar> c, id<ORBitVar> outt);
void XORFour(id<ORModel> model, id<ORBitVar> a, id<ORBitVar> b, id<ORBitVar> c, id<ORBitVar> d, id<ORBitVar> outt);
void sbox(id<ORModel> model, struct StateVars* vars, id<ORBitVar> b1, id<ORBitVar> b2);
void sideChannel(id<ORModel> model, struct StateVars* vars, id<ORBitVar> x, int sc);
void xtimes(id<ORBitVar> a, id<ORBitVar> b);
id<ORBitVar> i_xor(id<ORModel> model, id<ORBitVar> a, id<ORBitVar> b);
id<ORBitVar> i_sbox(id<ORModel> model, id<ORIdArray> sboxBV, id<ORBitVar> b1);

void keyExpansion(id<ORModel> model, struct StateVars* vars, int);
void addRoundKey(id<ORModel> model, struct StateVars* vars, int);
void subBytes(id<ORModel> model, struct StateVars* vars, int);
void mixColumns(id<ORModel> model, struct StateVars* vars, int);
void sideChannelCon(id<ORModel> model, struct StateVars* vars, struct SCInformation* scinfo);

struct SCInformation* readFile(FILE *f, enum Encryption);
id<ORModel> buildAESModel(struct StateVars* vars, struct SCInformation* scinfo, bool relaxation);

void findLeg(struct SCInformation* scinfo, uint8* plaintext, struct vallist vlist[16], int round, int col);
void filterPairs(struct SCInformation* scinfo, struct vallist vlist[16], struct fulllist flist[4], int round, int bucket, int cerrors, int currentobj);
bool findMin(struct SCInformation* scinfo, NSMutableDictionary* dict[4], uint8* Plaintext, struct vallist vlist[16], struct fulllist flist[4], int round, int ubound);

void sort_pvals(struct pval* a, size_t n);
void sort_bvals(struct fval *a, size_t n);
int compare_pvals(const void *p, const void *q);
int compare_bvals(const void *p, const void *q);

int main(int argc, const char * argv[]) {
    
    ORCmdLineArgs* cmd = [ORCmdLineArgs newWith:argc argv:argv];
    NSString* source = cmd.fName;
    tolerance = [cmd nbThreads];
    struct StateVars vars;
    vars.rounds = [cmd size];
    vars.mode = vars.rounds == 10 ? aes128 : aes256;
    struct SCInformation* scinfo = readFile(fopen([source UTF8String], "r"), vars.mode);
    id<ORModel> model = buildAESModel(&vars, scinfo, false);
    
    id<ORIntRange> R = [[ORIntRangeI alloc] initORIntRangeI:0 up:(vars.mode*16 - 1)];
    id<ORIntRange> COL = [[ORIntRangeI alloc] initORIntRangeI:0 up: vars.mode*4 - 1];
    id<ORIntRange> DEPTHS = [[ORIntRangeI alloc] initORIntRangeI:0 up: NUMBUCKETS];
    id<ORBitVarArray> o = (id)[CPFactory bitVarArray:model range: R];
    
    for(ORInt i = 0; i < vars.mode; i++){
        for(ORInt j = 0; j < 16; j++){
            [o set: vars.states[4*i + 2][j] at:(16*i + j)];
        }
    }
    
    id<ORIntVarArray> iv = [model intVars];
    
    id<ORIntVar> cond = [ORFactory intVar:model value:1];
    
    id<CPProgram,CPBV> cp = (id)[ORFactory createCPSemanticProgram:model with:[ORSemDFSController proto]];
    
    __block ORInt currentobj = [cp max:vars.obj_relax];
    __block ORInt optObjective = [cp max:vars.obj];
    __block id<ORTrailableInt> containsNewBucket = [ORFactory trailableInt:[cp engine] value:false];
    __block id<ORTrailableInt> nbFixed = [ORFactory trailableInt:[cp engine] value:0];
    
    __block uint8* ptext = malloc(sizeof(uint8)*16);
    __block struct vallist** vlist = malloc(sizeof(struct vallist*)*2);
    __block struct fulllist* flist = malloc(sizeof(struct fulllist)*8);
    __block NSMutableDictionary* dict[4];
    __block NSMutableDictionary** dict_ptr = dict;
    
    for(int i = 0 ; i < 4; i++)
        dict[i] = [[NSMutableDictionary alloc] initWithCapacity:1000];
    
    for(int i = 0; i < 8; i++){
        flist[i].minscore = INT_MAX;
        flist[i].size = 0;
        flist[i].list = malloc(sizeof(struct fval)*1000);
        flist[i].maxsize = 1000;
        flist[i].offset = malloc(sizeof(int) * (tolerance*25 + 2));
        for(int j = 0; j < 4; j++){
            flist[i].state[j] = ((4*(i%4) + j*5) % 16) + (i/4)*16;
        }
    }
    
    for(int i = 0; i < 2; i++){
        vlist[i] = malloc(sizeof(struct vallist)*16);
        for(int j = 0; j < 16; j++)
            vlist[i][j].offset = malloc(sizeof(int) * (tolerance*3 + 2));
    }
    
    for(int col = 0; col < 4; col++){
        findLeg(scinfo, scinfo->plaintext + 4*col, vlist[0], 0, col);
    }
    
    findMin(scinfo, dict_ptr, scinfo->plaintext, vlist[0], flist, 0, currentobj);
    __block id<ORTrailableInt> tcolScore = [ORFactory trailableInt:[cp engine] value:(flist[0].minscore + flist[1].minscore + flist[2].minscore + flist[3].minscore)];
    __block id<ORTrailableInt> legScore = [ORFactory trailableInt:[cp engine] value:0];
    
    void (^setCandidateValue)(int depth, int var, int idx, int currentobj, int currenterrors);
    
    void (^forceFailure)(void) = ^(){
        [cp diff:cond with:1];
    };
    
    if(vars.mode == aes128){
        setCandidateValue = ^void(int depth, int var, int idx, int currentobj, int currenterrors) {
            struct fval b = flist[var].list[idx];
            assert(flist[var].size > idx);
            
            int bkt = (b.score - flist[var].minscore) / BUCKETSIZE;
            
            [cp atomic:^{
                [containsNewBucket setValue:([containsNewBucket value] || bkt == depth)];
                [tcolScore setValue:([tcolScore value] - flist[var].minscore)];
                [nbFixed incr];
                
                for(int i = 0; i < 4; i++){
                    for(int nbit = 0; nbit < 8; nbit++){
                        [cp labelBV:o[flist[var].state[i]] at:nbit with:((b.val[i] >> nbit) & 1)];
                    }
                }
            }];
        };
    }
    else{
        setCandidateValue = ^void(int depth, int var, int idx, int currentobj, int currenterrors) {
            struct fval b = flist[var].list[idx];
            int bkt = (b.score - flist[var].minscore) / BUCKETSIZE;
            int summin = 0;
            if(var < 4){
                for(int i = 0; i < 4; i++) ptext[var*4 + i] = b.pt[i];
                findLeg(scinfo, b.pt, vlist[1], 1, var);
                [legScore setValue:([legScore value] + vlist[1][var*4].minscore + vlist[1][var*4 + 1].minscore + vlist[1][var*4 + 2].minscore + vlist[1][var*4 + 3].minscore)];
            }
            
            if([nbFixed value] == 3){
                for(int i = 4; i < 8; i++){
                    flist[i].size = 0;
                    for(int j = 0; j < 25*tolerance + 2; j++)
                        flist[i].offset[j] = 0;
                }
                if(!findMin(scinfo, dict_ptr, ptext, vlist[1], flist + 4, 1, currentobj - (currenterrors + b.score))){ forceFailure(); return;}
                summin = flist[4].minscore + flist[5].minscore + flist[6].minscore + flist[7].minscore;
                if((currenterrors + b.score + summin + depth*(![containsNewBucket value] && bkt < depth)) >= currentobj){ forceFailure(); return;}
            }
            
            
            [cp atomic:^{
                [containsNewBucket setValue:([containsNewBucket value] || bkt == depth)];
                [tcolScore setValue:([tcolScore value] - flist[var].minscore) + summin];
                [nbFixed incr];
                
                for(int i = 0; i < 4; i++){
                    for(int nbit = 0; nbit < 8; nbit++){
                        [cp labelBV:o[flist[var].state[i]] at:nbit with:((b.val[i] >> nbit) & 1)];
                    }
                }
            }];
            
            if([nbFixed value] == 4)
                filterPairs(scinfo, vlist[1], flist + 4, 1, depth, [cp min:vars.obj_relax], currentobj);
        };
    }
    
    NSLog(@"%d %d %d %d", flist[0].minscore, flist[1].minscore, flist[2].minscore, flist[3].minscore);
    ORLong searchStart = [ORRuntimeMonitor wctime];
    
    [cp solve:^(){
        [cp tryall:DEPTHS suchThat:^ORBool(ORInt d) {
            return ([cp min:vars.obj_relax] + flist[0].minscore + flist[1].minscore + flist[2].minscore + flist[3].minscore + BUCKETSIZE*d) < currentobj;
        } do:^(ORInt d) {
            NSLog(@"Search Depth %d",d);
            filterPairs(scinfo, vlist[0], flist, 0, d, 0, currentobj);
            [cp forall:COL suchThat:^ORBool(ORInt i) {
                return [cp domsize: o[i*4]] > 1;
            } orderedBy:^ORInt(ORInt i) {
                ORInt maxbucket = MAX(MIN((currentobj - [cp min: vars.obj_relax] - ([tcolScore value] - flist[i].minscore) - flist[i].minscore - ([legScore value]*(i < 4))) / BUCKETSIZE, d), -1);
                return ((i/4) << 30) + flist[i].offset[maxbucket+1];
            } do:^(ORInt i) {
                int currenterrors = [cp min: vars.obj_relax];
                
                id<ORIntRange> B = [ORFactory intRange:[cp engine] low:0 up:d];
                [cp tryall: B suchThat: ^ORBool(ORInt bkt) {
                    int ub = currentobj - currenterrors - ([tcolScore value] - flist[i].minscore) - flist[i].minscore - ([legScore value]*(i < 4));
                    if(bkt > ub) return false;
                    if(![containsNewBucket value] && bkt != d && bkt > (ub - d)) return false;
                    if(![containsNewBucket value] && bkt != d && [nbFixed value] == (vars.mode*4 - 1)) return false;
                    return true;
                } do:^(ORInt bkt) {
                    id<ORIntRange> S = [ORFactory intRange:[cp engine] low:flist[i].offset[bkt] up:(flist[i].offset[bkt+1] - 1)];
                    [cp tryall:S suchThat: ^ORBool(ORInt j) {
                        int ub = MAX(MIN((currentobj - currenterrors - ([tcolScore value] - flist[i].minscore) - flist[i].minscore - ([legScore value]*(i < 4)) - d*(bkt < d && ![containsNewBucket value])), d), -1);
                        return j < flist[i].offset[ub+1];
                    } do:^(ORInt j) { setCandidateValue(d, i, j, currentobj, currenterrors);}];
                }];
            }];
        }];
        
        [cp labelArrayFF:iv];
        
        @autoreleasepool {
            ORInt tid = [NSThread threadID];
            assert([cp ground]  == YES);
            NSLog(@"[thread:%d] Objective Function : %@",tid,[cp objectiveValue]);
            if([cp intValue: vars.obj] < optObjective)
                optObjective = [cp intValue: vars.obj];
            if(currentobj > [cp intValue:vars.obj_relax]){
                NSLog(@"Updated Objective: %d", [cp intValue:vars.obj_relax]);
                currentobj = [cp intValue:vars.obj_relax];
                ORLong searchStop = [ORRuntimeMonitor wctime];
                ORDouble elapsed = ((ORDouble)searchStop - searchStart) / 1000.0;
                
                bool ck = true;
                for(int i = 0; i < vars.mode; i++){
                    for(int j = 0; j < 16; j++){
                        id<CPBitVar> keybv = [cp concretize: vars.keys[i][j]];
                        ck = ck && ([keybv min] == scinfo->key[i][j]);
                    }
                }
                printf("+Tolerance: %d   Rounds: %d   FinishTime(s): %f Objective: %d ck:%d opt:%d\n", cmd.nbThreads, vars.rounds, elapsed, optObjective, ck, scinfo->obj_complete == optObjective);
                fflush(stdout);
                
            }
        }
    }];
    
    
    ORLong searchStop = [ORRuntimeMonitor wctime];
    ORDouble elapsed = ((ORDouble)searchStop - searchStart) / 1000.0;
    printf("*Tolerance: %d   Rounds: %d   FinishTime(s): %f Objective: %d\n", cmd.nbThreads, vars.rounds, elapsed, optObjective);
    
    for(int i = 0; i < 8; i++) free(flist[i].list);
    free(flist);
    free(vlist[0]);
    free(vlist[1]);
    free(vlist);
    free(ptext);
    free(scinfo);
    [cp release];
    return 0;
}

void XOR(id<ORModel> model, id<ORBitVar> a, id<ORBitVar> b, id<ORBitVar> c){
    [model add:[ORFactory bit: a bxor:b eq:c]];
}

id<ORBitVar> i_xor(id<ORModel> model, id<ORBitVar> a, id<ORBitVar> b){
    id<ORBitVar> r = [ORFactory bitVar: model withLength:[a bitLength]];
    [model add:[ORFactory bit: a bxor:b eq:r]];
    return r;
}

void XORThree(id<ORModel> model, id<ORBitVar> a, id<ORBitVar> b, id<ORBitVar> c, id<ORBitVar> d){
    id<ORBitVar> t = [ORFactory bitVar: model withLength:[a bitLength]];
    XOR(model,a,b,t);
    XOR(model,c,t,d);
}

void XORFour(id<ORModel> model, id<ORBitVar> a, id<ORBitVar> b, id<ORBitVar> c, id<ORBitVar> d, id<ORBitVar> e){
    id<ORBitVar> t1 = [ORFactory bitVar: model withLength:[a bitLength]];
    id<ORBitVar> t2 = [ORFactory bitVar: model withLength:[a bitLength]];
    XOR(model,a,b,t1);
    XOR(model,c,t1,t2);
    XOR(model,d,t2,e);
}

void sbox(id<ORModel> model, struct StateVars* vars, id<ORBitVar> b1, id<ORBitVar> b2){
    [model add:[ORFactory element:model var:b1 idxBitVarArray:vars->sboxBV equal:b2]];
}

id<ORBitVar> i_sbox(id<ORModel> model, id<ORIdArray> sboxBV, id<ORBitVar> b1){
    id<ORBitVar> r = [ORFactory bitVar: model withLength:[b1 bitLength]];
    [model add:[ORFactory element:model var:b1 idxBitVarArray:sboxBV equal:r]];
    return r;
}

void sideChannel(id<ORModel> model, struct StateVars* vars, id<ORBitVar> x, int sc){
    if(x == nil) return;
    vars->errorPtr[2 * vars->error_count]     = [ORFactory intVar:model bounds:[ORFactory intRange:model low:0 up:tolerance]];
    vars->errorPtr[2 * vars->error_count + 1] = [ORFactory intVar:model bounds:[ORFactory intRange:model low:0 up:tolerance]];
    
    id<ORIntVar> val = [ORFactory intVar:model bounds:[ORFactory intRange: model low: 0 up: 8]];
    id<ORIntVar> scval = [ORFactory intVar: model value:sc];
    
    [model add: [[vars->errorPtr[vars->error_count*2 + 1] mul: vars->errorPtr[vars->error_count*2]] eq: @(0)]];
    [model add: [[val eq: scval] eq: [[vars->errorPtr[vars->error_count*2 + 1] eq: @(0)] land: [vars->errorPtr[vars->error_count*2] eq: @(0)]]]];
    [model add: [ORFactory bit:x count:val]];
    [model add: [[[val plus: vars->errorPtr[vars->error_count*2]] sub: vars->errorPtr[vars->error_count*2+1]] eq:scval]];
    
    vars->error_count++;
}


void keyExpansion(id<ORModel> model, struct StateVars* vars, int k){
    uint32 rconstant[] = {1,2,4,8,16,32,64,128,27,54};
    int NK = vars->mode == aes128 ? 4 : 8;
    id<ORBitVar> rcon;
    if(NK == 4) rcon = [ORFactory bitVar:model low: &rconstant[k - 1] up:&rconstant[k - 1] bitLength:8];
    else rcon = [ORFactory bitVar:model low: &rconstant[k/2 - 1] up:&rconstant[k/2 - 1] bitLength:8];
    
    for(int b = 0; b < 16; b++){
        vars->keys[k][b] = [ORFactory bitVar: model withLength:8];
    }
    
    for(int i = 0; i < 4; i++){
        id<ORBitVar> temp[4];
        
        ORInt col = ((k*4) + i - 1);
        
        if(((k*4) + i) % NK == 0){
            temp[0] = i_xor(model, i_sbox(model, vars->sboxBV, vars->keys[col/4][(col*4 + 1) % 16]), rcon);
            temp[1] = i_sbox(model, vars->sboxBV, vars->keys[col/4][(col*4 + 2) % 16]);
            temp[2] = i_sbox(model, vars->sboxBV, vars->keys[col/4][(col*4 + 3) % 16]);
            temp[3] = i_sbox(model, vars->sboxBV, vars->keys[col/4][(col*4) % 16]);
        }
        else if (NK > 6 && ((k*4) + i) % NK == 4) {
            for(int j = 0; j < 4; j++)
                temp[j] = i_sbox(model, vars->sboxBV, vars->keys[col/4][(col*4 + j) % 16]);
        }
        else{
            for(int j = 0; j < 4; j++){
                temp[j] = vars->keys[col/4][(col*4 + j) % 16];
            }
        }
        
        for(ORInt z = 0; z < 4; z++){
            XOR(model,vars->keys[((col+1)-NK)/4][(((col+1)-NK)*4 + z) % 16],temp[z],vars->keys[(col+1)/4][((col+1)*4 + z) % 16]);
        }
    }
}

void addRoundKey(id<ORModel> model, struct StateVars* vars, int r){
    int k = r*4;
    for(ORInt b = 0; b < 16; b++){
        vars->states[k+1][b] = i_xor(model, vars->states[k][b], vars->keys[k / 4][b]);
    }
}

void subBytes(id<ORModel> model, struct StateVars* vars, int r){
    int k = r*4 + 1;
    for(ORInt b = 0; b < 16; b++){
        vars->states[k+1][b] = i_sbox(model, vars->sboxBV, vars->states[k][b]);
    }
}

void shiftRows(struct StateVars* vars){
    int offset[] = {0, 5, 10, 15, 4, 9, 14, 3, 8, 13, 2, 7, 12, 1, 6, 11};
    int k = (vars->rounds - 1)*4 + 2;
    
    for(int i = 0; i < 16; i++)
        vars->states[k + 2][i] = vars->states[k][offset[i]];
}

void mixColumns(id<ORModel> model, struct StateVars* vars, int ir){
    uint32 i_zero = 0x00000000, i_1b = 0x0000001B;
    id<ORBitVar> zero = [ORFactory bitVar:model low:&i_zero up:&i_zero bitLength:1];
    id<ORBitVar> xor1b = [ORFactory bitVar: model low :&i_1b up :&i_1b bitLength :8];
    int r = ir*4 + 2;
    
    for(int b = 0; b < 16; b++){
        vars->states[r+2][b] = [ORFactory bitVar: model withLength:8];
    }
    
    for(ORInt j = 0; j < 4; j++){
        vars->tm0[ir][j] = [ORFactory bitVar: model withLength:8];
        
        for(int i = 0; i < 4; i++){
            vars->tm1[ir][j][i] = [ORFactory bitVar: model withLength:8];
            vars->tm2[ir][j][i] = [ORFactory bitVar: model withLength:8];
        }
        
        //Calculating TMP
        
        XORFour(model, vars->states[r][j*4], vars->states[r][(j*4+5) % 16], vars->states[r][(j*4+10) % 16], vars->states[r][(j*4+15) % 16], vars->tm0[ir][j]);
        XOR(model, vars->states[r][j*4], vars->states[r][(j*4+5) % 16], vars->tm1[ir][j][0]);
        XOR(model, vars->states[r][(j*4+5) % 16], vars->states[r][(j*4+10) % 16], vars->tm1[ir][j][1]);
        XOR(model, vars->states[r][(j*4+10) % 16], vars->states[r][(j*4+15) % 16], vars->tm1[ir][j][2]);
        XOR(model, vars->states[r][(j*4+15) % 16], vars->states[r][j*4], vars->tm1[ir][j][3]);
        
        //Apply Circular Left Shift on tmp{1,2,3,4}a
        
        for(int z = 0; z < 4; z++){
            id<ORBitVar> temp = [ORFactory bitVar: model withLength:7];
            id<ORBitVar> judge = [ORFactory bitVar: model withLength:1];
            id<ORBitVar> shift = [ORFactory bitVar: model withLength:8];
            id<ORBitVar> shift2 = [ORFactory bitVar: model withLength:8];
            
            [model add: [ORFactory bit:vars->tm1[ir][j][z] from:0 to:6 eq:temp]];
            [model add: [ORFactory bit:vars->tm1[ir][j][z] from:7 to:7 eq:judge]];
            [model add: [ORFactory bit:temp concat:zero eq:shift]];
            [model add: [ORFactory bit:shift bxor:xor1b eq:shift2]];
            [model add: [ORFactory bit:judge then:shift2 else:shift result:vars->tm2[ir][j][z]]];
            
        }
        
        XORThree(model, vars->tm0[ir][j], vars->tm2[ir][j][0],vars->states[r][j*4],vars->states[r+2][((j*4) % 4) + j*4]);
        XORThree(model, vars->tm0[ir][j], vars->tm2[ir][j][1],vars->states[r][(j*4 + 5) % 16],vars->states[r+2][(((j*4 + 5) % 16) % 4) + j*4]);
        XORThree(model, vars->tm0[ir][j], vars->tm2[ir][j][2],vars->states[r][(j*4 + 10) % 16],vars->states[r+2][(((j*4 + 10) % 16)% 4) + j*4]);
        XORThree(model, vars->tm0[ir][j], vars->tm2[ir][j][3],vars->states[r][(j*4 + 15) % 16],vars->states[r+2][(((j*4 + 15) % 16)% 4) + j*4]);
    }
}

void sideChannelCon(id<ORModel> model, struct StateVars* vars, struct SCInformation* scinfo){
    
    for(int r = 0; r < vars->rounds - 1; r++){
        //First Rounds {Plaintext, Addkey, Subbyte, Shiftrows}
        for(ORInt subr = 0; subr < 3; subr++){
            for(ORInt b = 0; b < 16; b++){
                sideChannel(model, vars, vars->states[4*r + subr][b], scinfo->sc[r*9 + subr][b]);
                if(subr >= 1 && r < 2) scinfo->s_SC[r][b+(16*subr)] = scinfo->sc[r*9 + subr][b];
            }
        }
        
        for(ORInt col = 0; col < 4; col++){
            int count = 0;
            sideChannel(model, vars, vars->tm0[r][col]   , scinfo->sc[r*9 + 4 + col][count++]);
            for(int i = 0; i < 4; i++){
                sideChannel(model, vars, vars->tm1[r][col][i], scinfo->sc[r*9 + 4 + col][count++]);
                sideChannel(model, vars, vars->tm2[r][col][i], scinfo->sc[r*9 + 4 + col][count++]);
            }
        }
        
        for(ORInt b = 0; b < 16; b++){
            sideChannel(model, vars, vars->keys[r][b], scinfo->sc[r*9 + 8][b]);
            if(r < 2) scinfo->s_SC[r][b] = scinfo->sc[r*9 + 8][b];
        }
    }
    
    for(int i = 0; i < 16; i++){
        sideChannel(model, vars, vars->states[4*(vars->rounds - 1)][i], scinfo->sc[9*(vars->rounds - 1)][i]);
        sideChannel(model, vars, vars->states[4*(vars->rounds - 1) + 1][i], scinfo->sc[9*(vars->rounds - 1) + 1][i]);
        sideChannel(model, vars, vars->states[4*(vars->rounds - 1) + 2][i], scinfo->sc[9*(vars->rounds - 1) + 2][i]);
        sideChannel(model, vars, vars->states[4*(vars->rounds - 1) + 5][i], scinfo->sc[9*(vars->rounds - 1) + 3][i]);
        sideChannel(model, vars, vars->keys[vars->rounds - 1][i], scinfo->sc[9*(vars->rounds - 1) + 4][i]);
        sideChannel(model, vars, vars->keys[vars->rounds][i], scinfo->sc[9*(vars->rounds - 1) + 5][i]);
    }
}

void findLeg(struct SCInformation* scinfo, uint8 plaintext[4], struct vallist vlist[16], int round, int col){
    ORInt* sc = scinfo->s_SC[round];
    for (int var = 0; var < 4; var++){
        int v = 4*col + var;
        vlist[v].size = 0;
        vlist[v].minscore = 10000;
        for(int i = 0; i < tolerance*3 + 2; i++)
            vlist[v].offset[i] = 0;
        
        for(int key = 0; key < 256; key++){
            int ark = plaintext[var] ^ key, asb = s[plaintext[var] ^ key];
            if(scv(key, sc[v]) && scv(ark, sc[v+16]) && scv(asb, sc[v+32])){
                struct pval temp;
                temp.val = asb;
                temp.score = scd(key, sc[v]) + scd(ark, sc[v+16]) + scd(asb, sc[v+32]);
                vlist[v].offset[temp.score+1]++;
                vlist[v].list[vlist[v].size++] = temp;
                vlist[v].minscore = MIN(temp.score, vlist[v].minscore);
            }
        }
        
        sort_pvals(vlist[v].list, vlist[v].size);
        for(int i = 1; i < tolerance*3 + 2; i++)
            vlist[v].offset[i] += vlist[v].offset[i-1];
    }
}

bool findMin(struct SCInformation* scinfo, NSMutableDictionary* dict[4], uint8* plaintext, struct vallist vlist[16], struct fulllist flist[4], int round, int ubound){
    bool colCheck[4] = {false, false, false, false};
    int minsum = 0;
    
    if(round == 1){
        for(int col = 0; col < 4; col++){
            uint32 key = (plaintext[4*col] << 24) | (plaintext[(4*col + 5) % 16] << 16) | (plaintext[(4*col + 10) % 16] << 8) | (plaintext[(4*col + 15) % 16]);
            
            NSNumber* minContribution = [dict[col] objectForKey:@(key)];
            if (minContribution) {
                //NSLog(@"hit %d", hitcount++);
                flist[col].minscore = [minContribution charValue];
                minsum = minsum + [minContribution charValue];
                colCheck[col] = true;
            }
        }
    }
    
    for(int i = 0; i < 4; i++){
        if(!colCheck[i]){
            flist[i].minscore = ubound - 1;
        }
    }
    
    const int* nSC = scinfo->sc[9*(round+1)];
    for(int col = 0; col < 4; col++){
        if(colCheck[col]) continue;
        const int offset = 9 * round + 4 + col;
        const int t[] = {(col*4) % 16, (col*4 + 5) % 16, (col*4 + 10) % 16, (col*4 + 15) % 16};
        const int* cSC = scinfo->sc[offset];
        bool exists = false;
        
        int maxidx_a = MAX(MIN(flist[col].minscore, tolerance*3), -1);
        for(int a = 0; a < vlist[t[0]].offset[maxidx_a+1]; a++){
            int vala = vlist[t[0]].list[a].val;
            uint8 score = vlist[t[0]].list[a].score;
            int maxidx_b = MAX(MIN(flist[col].minscore - score, tolerance*3), -1);
            for(int b = 0; b < vlist[t[1]].offset[maxidx_b+1]; b++){
                int valb = vlist[t[1]].list[b].val;
                uint8 xab = vala ^ valb, xtab = xtimes_i(vala ^ valb);
                if(!(scv(xtab,cSC[2]) && scv(xab, cSC[1]))) continue;
                uint8 score2 = score + vlist[t[1]].list[b].score + scd(xtab, cSC[2]) + scd(xab, cSC[1]);
                if(score2 > flist[col].minscore) continue;
                int maxidx_c = MAX(MIN(flist[col].minscore - score2, tolerance*3), -1);
                for(int c = 0; c < vlist[t[2]].offset[maxidx_c+1]; c++){
                    int valc = vlist[t[2]].list[c].val;
                    uint8 xbc = valb ^ valc, xtbc = xtimes_i(valb ^ valc);
                    if(!(scv(xtbc, cSC[4]) && scv(xbc, cSC[3]))) continue;
                    uint8 score3 = score2 + vlist[t[2]].list[c].score + scd(xtbc, cSC[4]) + scd(xbc, cSC[3]);
                    if(score3 > flist[col].minscore) continue;
                    int maxidx_d = MAX(MIN(flist[col].minscore - score3, tolerance*3), -1);
                    for(int d = 0; d < vlist[t[3]].offset[maxidx_d+1]; d++){
                        uint8 vald = vlist[t[3]].list[d].val;
                        uint8 score4 = score3 + vlist[t[3]].list[d].score;
                        uint8 xcd = valc ^ vald, xtcd = xtimes_i(valc ^ vald), xad = vala ^ vald, xtad = xtimes_i(vala ^ vald);
                        uint8 sum = xab ^ xcd;
                        uint8 mxout[4] = {sum ^ xtab ^ vala, sum ^ xtbc ^ valb, sum ^ xtcd ^ valc, sum ^ xtad ^ vald};
                        
                        if(scv(sum, cSC[0]) && scv(xtcd, cSC[6]) && scv(xcd, cSC[5]) && scv(xtad, cSC[8]) && scv(xad, cSC[7]) && scv(mxout[0], nSC[0 + t[0]])
                           && scv(mxout[1], nSC[1 + t[0]]) && scv(mxout[2], nSC[2 + t[0]]) && scv(mxout[3], nSC[3 + t[0]])){
                            
                            int finalscore = score4 + scd(mxout[0], nSC[t[0]]) + scd(mxout[1], nSC[t[0] + 1]) + scd(mxout[2], nSC[t[0] + 2]) + scd(mxout[3], nSC[t[0] + 3])
                            + scd(sum, cSC[0]) + scd(xtcd, cSC[6]) + scd(xcd, cSC[5]) + scd(xtad, cSC[8]) + scd(xad, cSC[7]);
                            
                            if(flist[col].minscore > finalscore){
                                flist[col].minscore = finalscore;
                                maxidx_a = MAX(MIN(flist[col].minscore, maxidx_a), -1);
                                maxidx_b = MAX(MIN(flist[col].minscore - score, maxidx_b), -1);
                                maxidx_c = MAX(MIN(flist[col].minscore - score2, maxidx_c), -1);
                                maxidx_d = MAX(MIN(flist[col].minscore - score3, maxidx_d), -1);
                                exists = true;
                            }
                        }
                    }
                }
            }
        }
        if(!exists) return false;
        minsum = minsum + flist[col].minscore;
        if(round == 1){
            uint32 key = (plaintext[4*col] << 24) | (plaintext[(4*col + 5) % 16] << 16) | (plaintext[(4*col + 10) % 16] << 8) | (plaintext[(4*col + 15) % 16]);
            [dict[col] setObject:@(flist[col].minscore) forKey:@(key)];
        }
    }
    return true;
}

void filterPairs(struct SCInformation* scinfo, struct vallist vlist[16], struct fulllist flist[4], int round, int bucket, int cerrors, int currentobj){
    const int* nSC = scinfo->sc[9*(round+1)];
    for(int col = 0; col < 4; col++){
        const int offset = 9 * round + 4 + col;
        const int smallestScore = (flist[col].minscore + bucket * BUCKETSIZE);
        const int largestScore = smallestScore + BUCKETSIZE - 1;
        const int remcol = flist[(col + 1)%4].minscore + flist[(col + 2)%4].minscore + flist[(col + 3)%4].minscore;
        const int t[] = {(col*4) % 16, (col*4 + 5) % 16, (col*4 + 10) % 16, (col*4 + 15) % 16};
        const int* cSC = scinfo->sc[offset];
        const int minScore = MIN(currentobj - cerrors - remcol - 1, largestScore);
        const int minScore2 = MIN(currentobj - cerrors - remcol - 1, MIN(largestScore, tolerance*3));
        int* check = calloc((tolerance*25 + 2), sizeof(int));
        bool exists = false;
        
        int maxidx_a = minScore2;
        for(int a = 0; a < vlist[t[0]].offset[maxidx_a+1]; a++){
            int vala = vlist[t[0]].list[a].val;
            ORInt score = vlist[t[0]].list[a].score;
            int maxidx_b = MIN(minScore - score, tolerance*3);
            for(int b = 0; b < vlist[t[1]].offset[maxidx_b+1]; b++){
                int valb = vlist[t[1]].list[b].val;
                uint8 xab = vala ^ valb, xtab = xtimes_i(vala ^ valb);
                if(!(scv(xtab,cSC[2]) && scv(xab, cSC[1]))) continue;
                uint8 score2 = score + vlist[t[1]].list[b].score + scd(xtab, cSC[2]) + scd(xab, cSC[1]);
                if(score2 > largestScore || currentobj <= (score2 + cerrors + remcol)) continue;
                int maxidx_c = MIN(minScore - score2, MIN(largestScore - score2, tolerance*3));
                for(int c = 0; c < vlist[t[2]].offset[maxidx_c+1]; c++){
                    int valc = vlist[t[2]].list[c].val;
                    uint8 xbc = valb ^ valc, xtbc = xtimes_i(valb ^ valc);
                    if(!(scv(xtbc, cSC[4]) && scv(xbc, cSC[3]))) continue;
                    uint8 score3 = score2 + vlist[t[2]].list[c].score + scd(xtbc, cSC[4]) + scd(xbc, cSC[3]);
                    if(score3 > largestScore || currentobj <= (score3 + cerrors + remcol)) continue;
                    int maxidx_d = MIN(minScore - score3, MIN(largestScore - score3, tolerance*3));
                    for(int d = 0; d < vlist[t[3]].offset[maxidx_d+1]; d++){
                        uint8 vald = vlist[t[3]].list[d].val;
                        uint8 score4 = score3 + vlist[t[3]].list[d].score;
                        uint8 xcd = valc ^ vald, xtcd = xtimes_i(valc ^ vald), xad = vala ^ vald, xtad = xtimes_i(vala ^ vald);
                        uint8 sum = xab ^ xcd;
                        uint8 mxout[4] = {sum ^ xtab ^ vala, sum ^ xtbc ^ valb, sum ^ xtcd ^ valc, sum ^ xtad ^ vald};
                        
                        if(scv(sum, cSC[0]) && scv(xtcd, cSC[6]) && scv(xcd, cSC[5]) && scv(xtad, cSC[8]) && scv(xad, cSC[7]) && scv(mxout[0], nSC[0 + t[0]])
                           && scv(mxout[1], nSC[1 + t[0]]) && scv(mxout[2], nSC[2 + t[0]]) && scv(mxout[3], nSC[3 + t[0]])){
                            
                            int finalscore = score4 + scd(mxout[0], nSC[t[0]]) + scd(mxout[1], nSC[t[0] + 1]) + scd(mxout[2], nSC[t[0] + 2]) + scd(mxout[3], nSC[t[0] + 3])
                            + scd(sum, cSC[0]) + scd(xtcd, cSC[6]) + scd(xcd, cSC[5]) + scd(xtad, cSC[8]) + scd(xad, cSC[7]);
                            
                            if(finalscore <= largestScore && finalscore >= smallestScore*(round==0) && currentobj > (finalscore + cerrors + remcol)){
                                int newbucket = (finalscore - flist[col].minscore) / BUCKETSIZE;
                                exists = true;
                                flist[col].list[flist[col].size].val[0] = vala;
                                flist[col].list[flist[col].size].val[1] = valb;
                                flist[col].list[flist[col].size].val[2] = valc;
                                flist[col].list[flist[col].size].val[3] = vald;
                                flist[col].list[flist[col].size].pt[0] = mxout[0];
                                flist[col].list[flist[col].size].pt[1] = mxout[1];
                                flist[col].list[flist[col].size].pt[2] = mxout[2];
                                flist[col].list[flist[col].size].pt[3] = mxout[3];
                                flist[col].list[flist[col].size].score = finalscore;
                                check[newbucket+1]++;
                                flist[col].size++;
                                
                                if(flist[col].size == flist[col].maxsize){
                                    flist[col].list = realloc(flist[col].list, sizeof(struct fval)*flist[col].maxsize*2);
                                    flist[col].maxsize = flist[col].maxsize * 2;
                                }
                            }
                        }
                    }
                }
            }
        }
        sort_bvals(flist[col].list, flist[col].size);
        flist[col].offset[0] = 0;
        if(round == 1){
            for(int i = 1; i < tolerance*25 + 2; i++){
                check[i] += check[i-1];
                flist[col].offset[i] = check[i];
            }
        }
        else{
            flist[col].offset[bucket + 1] = flist[col].offset[bucket] + check[bucket + 1];
            for(int i = bucket + 2; i < tolerance*25 + 2; i++) flist[col].offset[i] = flist[col].offset[bucket + 1];
        }
        free(check);
        if(flist[col].size == 0) return;
    }
}

struct SCInformation* readFile(FILE *f, enum Encryption mode){
    int offset = mode == aes128 ? 16 : 32;
    int rounds = mode == aes128 ? 10 : 14;
    struct SCInformation* scinfo = malloc(sizeof(struct SCInformation));
    char x[4];
    int count = 0;
    int sc_count = 0;
    int ptcount = 0;
    int ctcount = 0;
    int kcount = 0;
    scinfo->obj_relax = 0;
    scinfo->obj_complete = 0;
    while (fscanf(f, " %3s", x) == 1) {
        if(count < rounds){
            if(mode > count) scinfo->obj_relax += atoi(x);
            scinfo->obj_complete += atoi(x);
        }
        else if(count < (rounds + 16)){
            scinfo->plaintext[ptcount++] = atoi(x);
        }
        else if(count < (rounds + offset + 16)){
            scinfo->key[kcount/16][kcount%16] = atoi(x);
            kcount++;
        }
        else if(count < (rounds + offset + 32)){
            scinfo->ciphertext[ctcount++] = atoi(x);
        }
        else{
            scinfo->sc[sc_count/16][sc_count%16] = atoi(x);
            sc_count++;
        }
        count++;
    }
    return scinfo;
}


int compare_bvals(const void *p, const void *q) {
    struct fval x = *(const struct fval *)p;
    struct fval y = *(const struct fval *)q;
    return (x.score > y.score) - (x.score < y.score);
}

int compare_pvals(const void *p, const void *q) {
    struct pval x = *(const struct pval *)p;
    struct pval y = *(const struct pval *)q;
    return (x.score > y.score) - (x.score < y.score);
}

void sort_bvals(struct fval *a, size_t n) {
    qsort(a, n, sizeof *a, &compare_bvals);
}

void sort_pvals(struct pval* a, size_t n){
    qsort(a, n, sizeof *a, &compare_pvals);
}

id<ORModel> buildAESModel(struct StateVars* vars, struct SCInformation* scinfo, bool relaxation){
    id<ORModel> model = [ORFactory createModel];
    
    vars->error_count = 0;
    
    vars->sboxBV = [ORFactory idArray:model range:[[ORIntRangeI alloc] initORIntRangeI:0 up:255]];
    
    for(ORInt k=0;k < 256;k++){
        [vars->sboxBV set:[ORFactory bitVar: model low: &s[k] up: &s[k] bitLength :8] at:k];
    }
    
    //Initial State variables set to plaintext values
    for(int w = 0; w < 16; w++){
        ORUInt pbyte = scinfo->plaintext[w];
        vars->states[0][w] = [ORFactory bitVar: model low :&pbyte up :&pbyte bitLength :8];
        vars->states[vars->rounds*4 + 1][w] = [ORFactory bitVar: model withLength:8];
    }
    
    for(int w = 0; w < 16; w++){
        vars->keys[0][w] = [ORFactory bitVar: model withLength:8];
        if(vars->rounds == 14)
            vars->keys[1][w] = [ORFactory bitVar: model withLength:8];
    }
    
    addRoundKey(model, vars, 0);
    int counter = 0;
    while (counter < vars->rounds - 1)
    {
        if(vars->mode == aes128 || counter >= 1) keyExpansion(model, vars, counter+1);
        subBytes(model, vars, counter);
        mixColumns(model, vars, counter);
        addRoundKey(model, vars, ++counter);
    }
    
    keyExpansion(model, vars, vars->rounds);
    subBytes(model, vars, vars->rounds - 1);
    shiftRows(vars);
    addRoundKey(model, vars, vars->rounds);
    
    sideChannelCon(model, vars, scinfo);
    
    vars->obj_relax = [ORFactory intVar:model bounds:[ORFactory intRange:model low:0 up:2*100*tolerance]];
    vars->obj = [ORFactory intVar:model bounds:[ORFactory intRange:model low:0 up:(vars->error_count-1)*tolerance]];
    
    [model add: [Sum(model,j,[ORFactory intRange:model low:0 up:(2*vars->error_count)-1],vars->errorPtr[j]) eq: vars->obj]];
    [model add: [Sum(model,j,[ORFactory intRange:model low:0 up:((vars->mode*100 + 16)*2)-1],vars->errorPtr[j]) eq: vars->obj_relax]];
    [model minimize: vars->obj];
    
    return model;
}


