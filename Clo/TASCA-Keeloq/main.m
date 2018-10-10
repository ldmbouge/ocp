#import <ORProgram/ORProgram.h>
#import <objcp/CPFactory.h>
#import <objcp/CPConstraint.h>
#import <objcp/CPIntVarI.h>
#import <objcp/CPBitVar.h>
#import <objcp/CPBitVarI.h>
#import "ORCmdLineArgs.h"

ORInt currentobj = 1000000;
//Global Constant
ORUInt NLF[] = {0,1,1,1,0,1,0,0,0,0,1,0,1,1,1,0,0,0,1,1,1,0,1,0,0,1,0,1,1,1,0,0};

id<ORIdArray> NLF_BV;

ORUInt ciphertext = 0x589dee0a;
ORUInt keyvalueL =  0x5eed0094;
ORUInt keyvalueR =  0xbc4c6b7f;
/*
 ORUInt plaintext = 0xaaaaaaaa;
 ORUInt keyvalueL =  0x88793061;
 ORUInt keyvalueR =  0x00714420;
 */

ORUInt sc_info[] = {10, 10, 9, 9, 10, 11, 11, 12, 12, 12, 12, 12, 12,11 ,12 ,13 ,13 ,12 ,11 ,11 ,12 ,13
    ,13 ,12 ,13 ,13 ,14 ,13 ,14 ,15 ,15 ,16 ,17 ,17 ,18 ,18 ,16 ,15 ,16 ,16 ,16 ,15 ,15 ,14
    ,14 ,14 ,14 ,15 ,14 ,15 ,16 ,18 ,17 ,17 ,17 ,19 ,17 ,15 ,17 ,16 ,16 ,17 ,16 ,17 ,15 ,14
    ,14 ,14 ,15 ,16 ,14 ,15 ,15 ,15 ,14 ,15 ,16 ,17 ,17 ,16 ,17 ,16 ,16 ,16 ,15 ,14 ,15 ,14
    ,15 ,16 ,16};

id<ORIntVar> error[1000];
id<ORIntVar>* errorPtr = error;
ORInt error_count = 0;

// BitVector Constraint Prototypes

id<ORBitVar> xor_bv(id<ORModel> m, id<ORBitVar> b1, id<ORBitVar> b2);
id<ORBitVar> and_bv(id<ORModel> m, id<ORBitVar> b1, id<ORBitVar> b2);
id<ORBitVar> lshift_bv(id<ORModel> m, id<ORBitVar> b, ORInt s);
id<ORBitVar> rshift_bv(id<ORModel> m, id<ORBitVar> b, ORInt s);
id<ORBitVar> F_bv(id<ORModel> m, id<ORBitVar> b1);
id<ORBitVar> F2_bv(id<ORModel> m, id<ORBitVar> b1);
id<ORBitVar> F3_bv(id<ORModel> m, id<ORBitVar> b1);
int calcError(id<CPProgram,CPBV> cp, id<ORBitVar>* states, ORUInt pos, ORUInt candidate);
void SideChannel(id<ORModel> model, id<ORBitVar> x, int sc);

// Int Constraint Prototypes

id<ORIntVar> xor_iv(id<ORModel> m, id<ORIntVar> i1, id<ORIntVar> i2);
id<ORIntVar> and_iv(id<ORModel> m, id<ORIntVar> i1, id<ORIntVar> i2);
id<ORIntVar> lshift_iv(id<ORModel> m, id<ORIntVar> i, ORInt s);
id<ORIntVar> rshift_iv(id<ORModel> m, id<ORIntVar> i, ORInt s);
id<ORIntVar> F_iv(id<ORModel> m, id<ORIntVar> a, id<ORIntVar> b,id<ORIntVar> c,id<ORIntVar> d,id<ORIntVar> e);


int main(){
    id<ORModel> model = [ORFactory createModel];
    
    NLF_BV = [ORFactory idArray:model range:[[ORIntRangeI alloc] initORIntRangeI:0 up:31]];
    
    for(ORInt k=0;k < 32;k++){
        [NLF_BV set:[ORFactory bitVar:model low:NLF + k up:NLF + k bitLength:1] at:k];
    }
    
    id<ORBitVar> states[91];
    id<ORBitVar> *states_p = states;
    id<ORBitVar> keybits[64];
    id<ORBitVar> *keybits_p = keybits;
    //id<ORBitVar> keyL = [ORFactory bitVar: model low: &keyvalueL up: &keyvalueL bitLength:32];
    //id<ORBitVar> keyR = [ORFactory bitVar: model low: &keyvalueR up: &keyvalueR bitLength:32];
    
    //id<ORBitVar> key = [ORFactory bitVar: model withLength:64];
    //[model add: [ORFactory bit: keyL concat: keyR eq:key]];
    
    //states[0] = [ORFactory bitVar:model low:&plaintext up:&plaintext bitLength:32];
    
    for(int i = 0; i < 90; i++)
        states[i] = [ORFactory bitVar:model withLength:32];
    
    states[90] = [ORFactory bitVar:model low:&ciphertext up:&ciphertext bitLength:32];
    
    id<ORBitVar> prevState = [ORFactory bitVar:model withLength:32];
    id<ORBitVar> strayBit = [ORFactory bitVar:model withLength:1];
    id<ORBitVar> LHS = [ORFactory bitVar: model withLength:31];
    id<ORBitVar> diffI = [ORFactory bitVar: model withLength:32];
    
    [model add: [ORFactory bit: states[0] from:0 to: 30 eq:LHS]];
    [model add: [ORFactory bit: LHS concat: strayBit eq:prevState]];
    [model add: [ORFactory bit: prevState bxor: states[0] eq:diffI]];
    
    SideChannel(model, diffI, sc_info[0]);
    int count = 54;
    for(int i = 0; i < 64; i++){
        keybits[i] = [ORFactory bitVar:model withLength:1];
    }
    for(int i = 0; i < 90; i++){
        //Extract Bits
        id<ORBitVar> x0 = [ORFactory bitVar:model withLength:1];
        id<ORBitVar> x16 = [ORFactory bitVar:model withLength:1];
        
        [model add:[ORFactory bit: states[i] from: 0 to: 0 eq: x0]];
        [model add:[ORFactory bit: states[i] from: 16 to: 16 eq: x16]];
        
        //[model add:[ORFactory bit: key from:(count % 64) to:(count % 64) eq:x[(count % 64)]]];
        id<ORBitVar> ir = xor_bv(model, xor_bv(model, x0, x16), keybits[(count % 64)]);
        ir = xor_bv(model, ir ,F3_bv(model, states[i]));
        
        id<ORBitVar> e = [ORFactory bitVar:model withLength:31];
        [model add:[ORFactory bit: states[i] from: 1 to: 31 eq: e]];
        [model add:[ORFactory bit: ir concat:e eq:states[i+1]]];
        id<ORBitVar> diff = [ORFactory bitVar:model withLength:32];
        [model add: [ORFactory bit:states[i] bxor:states[i+1] eq:diff]];
        SideChannel(model, diff, sc_info[i+1]);
        count = count + 1;
    }
    
    id<ORIntVar> miniVar = [ORFactory intVar:model bounds:[ORFactory intRange:model low:0 up:(error_count-1)*2]];
    [model add: [Sum(model,j,[ORFactory intRange:model low:0 up:(error_count)-1],[errorPtr[2*j] plus: errorPtr[2*j + 1]]) eq: miniVar]];
    [model minimize:miniVar];
    //[model add: [miniVar eq: @(15)]];
    id<ORIntVarArray> iv = [model intVars];
    //id<ORBitVarArray> bv = [model bitVars];
    
    ORUInt MAX = 0xFF;
    ORUInt MIN = 0x00;
    
    id<ORIntRange> R = [[ORIntRangeI alloc] initORIntRangeI:0 up:10];
    id<ORBitVarArray> o = (id)[CPFactory bitVarArray:model range: R];
    
    for(int i = 0; i < 11; i++){
        id<ORBitVar> temp = [ORFactory bitVar:model low:&MIN up:&MAX bitLength:8];
        [model add: [ORFactory bit:states[82 - 8*i] from:0 to:7 eq:temp]];
        [o set:temp at:i];
        
    }
    
    /*
     id<ORIntRange> R = [[ORIntRangeI alloc] initORIntRangeI:0 up:7];
     //id<ORIdArray> bvall = [ORFactory idArray:[cp engine] range:R];
     id<ORBitVarArray> o = (id)[CPFactory bitVarArray:model range: R];
     
     for(int i = 0; i < 8; i++){
     id<ORBitVar> temp = [ORFactory bitVar:model low:&MIN up:&MAX bitLength:8];
     [model add: [ORFactory bit:key from:(15+64-8*i)%64 to:(8+64-8*i)%64 eq:temp]];
     NSLog(@"low: %d up: %d", (15+64-8*i)%64, (8+64-8*i)%64);
     [o set:temp at:i];
     
     }
     */
    id<CPProgram,CPBV> cp = (id)[ORFactory createCPSemanticProgram:model with:[ORSemDFSController proto]];
    
    ORLong searchStart = [ORRuntimeMonitor wctime];
    
    
    [cp solve:^{
        [cp forall:R suchThat:^ORBool(ORInt i) {
            return [cp domsize:[o at:i]] > 1;
        } orderedBy:^ORInt(ORInt i) {
            return i;
            //return true;
        } do:^(ORInt i) {
            [cp tryall: RANGE(cp,0,255) suchThat:^ORBool(ORInt j) {
                id<CPBitVar> cbv = [cp concretize:[o at: i]];
                ORULong min = [cbv min];
                ORULong max = [cbv max];
                int score = calcError(cp,states_p,82 - 8*i + 8,j);
                return j >= min && j <= max && score > -1 && (currentobj > ([cp min:miniVar] + score));
            } orderedBy:^ORDouble(ORInt j) {
                return calcError(cp,states_p,82 - 8*i + 8,j);
            } in:^(ORInt j) {
                
                [cp atomic:^{
                    uint32 count = 0;
                    for(int nbit = 0; nbit < 8; nbit++){
                        BOOL val = (j >> count) & 1;
                        [cp labelBV:o[i] at:nbit with:val];
                        count++;
                    }
                }];
            } onFailure:^(ORInt j) {
            }];
        }];
        
        for(int i = 0; i < 64; i++){
            NSLog(@"[  %d  ]: %@",i,[cp stringValue:keybits_p[i]]);
        }
        
        [cp labelArrayFF:iv];
        
        @autoreleasepool {
            ORInt tid = [NSThread threadID];
            assert([cp ground]  == YES);
            NSLog(@"[thread:%d] Objective Function : %@",tid,[cp objectiveValue]);
            
            if(currentobj > [cp intValue:miniVar]){
                NSLog(@"Updated Objective: %d", [cp intValue:miniVar]);
                currentobj = [cp intValue:miniVar];
            }
        }
    }];
    
    if([cp ground])
        printf("GROUNDED\n");
    
    ORLong searchStop = [ORRuntimeMonitor wctime];
    ORDouble elapsed = ((ORDouble)searchStop - searchStart) / 1000.0;
    printf("Choices: (%d / %d) FinishTime(s): %f  Objective: %d",[cp nbChoices], [cp nbFailures], elapsed, [[[[cp solutionPool] best] objectiveValue] intValue]);
    [cp release];
    
    return 0;
}


// Bitvector Constraint Implementation

id<ORBitVar> xor_bv(id<ORModel> m, id<ORBitVar> b1, id<ORBitVar> b2){
    ORUInt UP = 1;
    ORUInt LOW = 0;
    id<ORBitVar> r = [ORFactory bitVar:m low:&LOW up:&UP bitLength:1];
    [m add:[ORFactory bit:b1 bxor:b2 eq:r]];
    return r;
}

id<ORBitVar> and_bv(id<ORModel> m, id<ORBitVar> b1, id<ORBitVar> b2){
    ORUInt UP = 1;
    ORUInt LOW = 0;
    id<ORBitVar> r = [ORFactory bitVar:m low:&LOW up:&UP bitLength:1];
    [m add:[ORFactory bit:b1 band:b2 eq:r]];
    return r;
}

id<ORBitVar> lshift_bv(id<ORModel> m, id<ORBitVar> b, ORInt s){
    ORUInt LOW = 0;
    ORUInt UP = 0xFFFFFFFF;
    id<ORBitVar> r = [ORFactory bitVar:m low:&LOW up:&UP bitLength:[b bitLength]];
    [m add:[ORFactory bit:b shiftLBy:s eq:r]];
    return r;
}

id<ORBitVar> rshift_bv(id<ORModel> m, id<ORBitVar> b, ORInt s){
    ORUInt LOW = 0;
    ORUInt UP = 0xFFFFFFFF;
    id<ORBitVar> r = [ORFactory bitVar:m low:&LOW up:&UP bitLength:[b bitLength]];
    [m add:[ORFactory bit:b shiftRBy:s eq:r]];
    return r;
}

id<ORBitVar> F3_bv(id<ORModel> m, id<ORBitVar> b1){
    int p[] = {1, 9, 20, 26, 31};
    id<ORBitVar> idx = [ORFactory bitVar:m withLength:5];
    for(int i = 0; i < 5; i++){
        id<ORBitVar> bit = [ORFactory bitVar:m withLength:1];
        [m add: [ORFactory bit: idx from: i to: i eq: bit]];
        [m add: [ORFactory bit: b1 from:p[i] to:p[i] eq:bit]];
    }
    id<ORBitVar> result = [ORFactory bitVar:m withLength:1];
    [m add:[ORFactory element:m var:idx idxBitVarArray:NLF_BV equal:result]];
    return result;
}

void SideChannel(id<ORModel> model, id<ORBitVar> x, int sc){
    errorPtr[2 * error_count]     = [ORFactory boolVar:model];
    errorPtr[2 * error_count + 1] = [ORFactory boolVar:model];
    [model add: [[errorPtr[2 * error_count] plus: errorPtr[2 * error_count + 1]] neq: @(2)]];
    id<ORIntVar> val = [ORFactory intVar:model bounds:[ORFactory intRange: model low: 0 up: 32]];
    //    id<ORIntVar> scval = [ORFactory intVar: model value:sc];
    [model add: [[errorPtr[error_count*2 + 1] plus: errorPtr[error_count*2]] leq: @(1)]];
    
    [model add: [[val eq: @(sc)] eq: [[errorPtr[error_count*2 + 1] eq: @(0)] land: [errorPtr[error_count*2] eq: @(0)]]]];
    
    [model add: [ORFactory bit:x count:val]];
    [model add: [[[val plus: errorPtr[error_count*2]] sub: errorPtr[error_count*2+1]] eq: @(sc)]];
    error_count++;
}

int calcError(id<CPProgram,CPBV> cp, id<ORBitVar>* states, ORUInt pos, ORUInt candidate){
    int deviations = 0;
    ORULong cStates[9];
    
    //Compute states
    for(int i = 0; i < 9; i++){
        id<CPBitVar> cbv = [cp concretize:states[pos-i]];
        cStates[i] = ([cbv min]) | (candidate >> (8-i));
    }
    
    ORULong diff[8];
    
    //Compute differences
    for(int i = 0; i < 8; i++){
        diff[i] = cStates[i] ^ cStates[i+1];
    }
    
    //Compute Hamming Distance
    for(int i = 0; i < 8; i++){
        int errors = 0;
        for(int j = 0 ; j < 32; j++){
            if((diff[i] >> j) & 1)
                errors++;
        }
        if(errors != sc_info[pos-i])
            deviations = deviations + 1;
        if(errors > sc_info[pos-i] + 1 ||  errors < sc_info[pos-i] - 1) return -1;
        //if(abs(errors - sc_info[pos-i]) > 1) return -1;
    }
    return deviations;
}
