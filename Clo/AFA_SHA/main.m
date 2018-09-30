//
//  main.m
//  AFA_SHA
//
//  Created by Fanghui Liu on 9/5/18.
//

#import <ORProgram/ORProgram.h>
#import <objcp/CPFactory.h>
#import <objcp/CPConstraint.h>
#import <objcp/CPIntVarI.h>
#import <objcp/CPBitVar.h>
#import <objcp/CPBitVarI.h>
#import "ORCmdLineArgs.h"

id<ORBitVarArray> SHA1_R(id<ORModel> m, id<ORBitVarArray> input, ORInt round );

id<ORBitVar> k;
id<ORBitVar> w[16];
id<ORModel> model;
id<ORIdArray> ca;

id<ORBitVar> testa = nil;
id<ORBitVar> testb = nil;
id<ORBitVar> testc = nil;
id<ORBitVar> testd = nil;
id<ORBitVar> teste = nil;
ORUInt initHash[] = {0,0,0,0,0};
ORUInt Deltas[100][5];
ORUInt outputHash[100][5];
ORInt numFaults = 0;
uint32 MIN32 = 0x00000000;
uint32 MAX32 = 0xFFFFFFFF;

void readFile(FILE *f);

int main(int argc, const char * argv[]) {
    ORCmdLineArgs* cmd = [ORCmdLineArgs newWith:argc argv:argv];
    NSString* source = cmd.fName;
    FILE* instance = fopen([source UTF8String], "r");
    readFile(instance);
    
    model = [ORFactory createModel];
    ORUInt k_const = 0xCA62C1D6;
    k = [ORFactory bitVar:model low:&k_const up:&k_const bitLength:32];
    
    for(int i = 0; i < 16; i++){
        //w[i] = [ORFactory bitVar:model withLength:32];
        w[i] = [ORFactory bitVar:model low:&MIN32 up:&MIN32 bitLength:32];
    }
    
    ORUInt testInput1 = 0xb4f9cb2e;
    ORUInt testInput2 = 0xe4dc4f33;
    ORUInt testInput3 = 0xb4e5c2ed;
    ORUInt testInput4 = 0xd82fa960;
    ORUInt testInput5 = 0x5cb8c5b8;
    
    id<ORBitVarArray> initInput = [ORFactory bitVarArray: model range:RANGE(model,0,4)];
    /*
     [initInput set:[ORFactory bitVar:model low:&testInput1 up:&testInput1 bitLength:32] at:0];
     [initInput set:[ORFactory bitVar:model low:&testInput2 up:&testInput2 bitLength:32] at:1];
     [initInput set:[ORFactory bitVar:model low:&testInput3 up:&testInput3 bitLength:32] at:2];
     [initInput set:[ORFactory bitVar:model low:&testInput4 up:&testInput4 bitLength:32] at:3];
     [initInput set:[ORFactory bitVar:model low:&testInput5 up:&testInput5 bitLength:32] at:4];
     */
    [initInput set:[ORFactory bitVar:model low:&MIN32 up:&MAX32 bitLength:32] at:0];
    [initInput set:[ORFactory bitVar:model low:&MIN32 up:&MAX32 bitLength:32] at:1];
    [initInput set:[ORFactory bitVar:model low:&MIN32 up:&MAX32 bitLength:32] at:2];
    [initInput set:[ORFactory bitVar:model low:&MIN32 up:&MAX32 bitLength:32] at:3];
    [initInput set:[ORFactory bitVar:model low:&MIN32 up:&MAX32 bitLength:32] at:4];
    
    
    //Create IntVarMatrix of Deltas
    
    id<ORBitVar> initBV[5];
    for (int i = 0; i < 5; i++){
        initBV[i] = [ORFactory bitVar:model low:&initHash[i] up:&initHash[i] bitLength:32];
    }
    
    id<ORBitVarArray> input = [ORFactory bitVarArray: model range:RANGE(model,0,4)];
    id<ORBitVarArray> output = [ORFactory bitVarArray: model range:RANGE(model,0,4)];
    
    [output set:initBV[0] at:0];
    [output set:initBV[1] at:1];
    [output set:initBV[2] at:2];
    [output set:initBV[3] at:3];
    [output set:initBV[4] at:4];
    
    for(int i = [input range].low; i <= [input range].up; i++){
        [input set:initInput[i] at:i];
    }
    
    id<ORBitVarArray> iinput[16];
    
    for(int i = 0; i < 16; i++){
        input = SHA1_R(model, input,i);
        iinput[i] = input;
    }
    
    for(int i = 0; i < 5; i++){
        [model add: [ORFactory bit:input[i] eq:output[i]]];
    }
    
    // id<ORIntRange> R = [[ORIntRangeI alloc] initORIntRangeI:0 up:31];
    // id<ORBitVarArray> o = (id)[CPFactory bitVarArray:model range: R];
    /*
     for(ORInt k = 0; k < 5; k++){
     [o set:initInput[k] at:k];
     }
     */
    id<ORIntVarArray> iv = [model intVars];
    id<ORBitVarArray> bv = [model bitVars];
    
    id<CPProgram,CPBV> cp = (id)[ORFactory createCPSemanticProgramDFS:model];
    
    ORLong searchStart = [ORRuntimeMonitor wctime];
    
    id<ORIdArray> bvall = [ORFactory idArray:[cp engine] range:bv.range];
    for(ORInt k = [bv range].low; k <= [bv range].up; k++){
        [bvall set:[bv at: k] at:k];
    }
    
    id<ORIdArray> iiputbvall = [ORFactory idArray:[cp engine] range:RANGE(cp,0,79)];
    ORInt icount = 0;
    for(int i = 0; i < 16; i++)
        for(int j = 0; j < 5; j++)
            [iiputbvall set:[iinput[i] at: j] at:icount++];
    
    
    id<CPBitVarHeuristic> h = [cp createBitVarFF:(id<CPBitVarArray>)bvall];
    
    [cp solve:^{
        [cp labelBitVarHeuristic:h];
        [cp labelArrayFF: iv];
        NSLog(@"A + B = C (Addition over BitVars)");
        NSLog(@"%@: A",[cp stringValue: testa]);
        NSLog(@"%@: B",[cp stringValue: testb]);
        NSLog(@"%@: Carry In",[cp stringValue: testc]);
        NSLog(@"%@: C (Result)",[cp stringValue: testd]);
        NSLog(@"%@: Carry Out",[cp stringValue: teste]);
        
        NSLog(@"print");
        
        for(int i = 0; i < 5; i++){
            NSLog(@" %@", [cp stringValue:initInput[i]]);
        }
        @autoreleasepool {
            
        }
    }];
    
    if([cp ground]){
        NSLog(@"GROUNDED");
    }
    /*
     
     id<ORSolution> sol = [[cp solutionPool] best];
     if([cp ground]){
     NSLog(@"GROUNDED");
     for(int i = 0; i < 5; i++){
     NSLog(@" %@", [initInput[1] stringValue]);
     NSLog(@" %@", [cp intValue:initInput[1]]);
     }
     }
     */
    /*
     @autoreleasepool {
     // insert code here...
     NSLog(@"Hello, World!");
     }
     return 0;
     
     */
}

void XOR(id<ORIdArray> ca, id<ORModel> model, id<ORBitVar> a, id<ORBitVar> b, id<ORBitVar> outt){
    [model add:[ORFactory bit: a bxor:b eq:outt]];
}

void XORThree(id<ORModel> model, id<ORBitVar> a, id<ORBitVar> b, id<ORBitVar> c, id<ORBitVar> outt){
    uint32 MIN8 = 0x00000000;
    uint32 MAX8 = 0xFFFFFFFF;
    id<ORBitVar> t = [ORFactory bitVar: model low :&MIN8 up :&MAX8 bitLength :32];
    XOR(ca,model,a,b,t);
    XOR(ca,model,c,t, outt);
}

void XORFour(id<ORIdArray> ca, id<ORModel> model, id<ORBitVar> a, id<ORBitVar> b, id<ORBitVar> c, id<ORBitVar> d, id<ORBitVar> outt){
    uint32 MIN8 = 0x00000000;
    uint32 MAX8 = 0xFFFFFFFF;
    
    id<ORBitVar> t1 = [ORFactory bitVar: model low :&MIN8 up :&MAX8 bitLength :32];
    id<ORBitVar> t2 = [ORFactory bitVar: model low :&MIN8 up :&MAX8 bitLength :32];
    XOR(ca,model,a,b,t1);
    XOR(ca,model,c,t1,t2);
    XOR(ca,model,d,t2,outt);
}

id<ORBitVarArray> SHA1_R(id<ORModel> m, id<ORBitVarArray> input, ORInt round){
    id<ORBitVarArray> result = [ORFactory bitVarArray:m range:RANGE(m,0,4)];
    for(int i = [result range].low; i <= [result range].up; i++)
        [result set:[ORFactory bitVar:m withLength:32] at:i];
    
    ORUInt MIN = 0x00000000;
    ORUInt MAX = 0xFFFFFFFF;
    ORUInt CINMAX = 0xFFFFFFFE;
    
    id<ORBitVar> shifta = [ORFactory bitVar:m withLength:32];
    id<ORBitVar> shiftb = [ORFactory bitVar:m withLength:32];
    
    id<ORBitVar> shiftatemp = [ORFactory bitVar:m withLength:27];
    id<ORBitVar> shiftatemp2 = [ORFactory bitVar:m withLength:5];
    id<ORBitVar> shiftbtemp = [ORFactory bitVar:m withLength:2];
    id<ORBitVar> shiftbtemp2 = [ORFactory bitVar:m withLength:30];
    /*
     [m add: [ORFactory bit:input[0] from:0 to:26 eq:shiftatemp]];
     [m add: [ORFactory bit:input[0] from:27 to:31 eq:shiftatemp2]];
     [m add: [ORFactory bit:input[1] from:0 to:1 eq:shiftbtemp]];
     [m add: [ORFactory bit:input[1] from:2 to:31 eq:shiftbtemp2]];
     [m add: [ORFactory bit:shiftatemp concat:shiftatemp2 eq:shifta]];
     [m add: [ORFactory bit:shiftbtemp concat:shiftbtemp2 eq:shiftb]];
    */
    
    [m add: [ORFactory bit:input[0] rotateLBy:5 eq:shifta]];
    [m add: [ORFactory bit:input[1] rotateLBy:30 eq:shiftb]];
    
    
    //[m add: [ORFactory bit: input[0] shiftLBy:5 eq:shifta]];
    //[m add: [ORFactory bit: input[1] shiftLBy:30 eq:shiftb]];
    [m add: [ORFactory bit: shiftb eq: result[2]]];
    
    [m add: [ORFactory bit: input[0] eq: result[1]]];
    [m add: [ORFactory bit: input[2] eq: result[3]]];
    [m add: [ORFactory bit: input[3] eq: result[4]]];
    
    id<ORBitVar> f = [ORFactory bitVar:m withLength:32];
    XORThree(m,input[1],input[2],input[3],f);
    
    id<ORBitVar> r0 = [ORFactory bitVar:m withLength:32];
    id<ORBitVar> r1 = [ORFactory bitVar:m withLength:32];
    id<ORBitVar> r2 = [ORFactory bitVar:m withLength:32];
    
    id<ORBitVar> ci = [ORFactory bitVar:m low:&MIN up:&CINMAX bitLength:32];
    id<ORBitVar> co = [ORFactory bitVar:m low:&MIN up:&MAX bitLength:32];
    
    [ORFactory bit: f plus:input[4] withCarryIn:ci eq:r0 withCarryOut:co];
    if(round == 15){
        testa = f; testb = input[4]; testc = ci; testd = r0; teste = co;
    }
    
    ci = [ORFactory bitVar:m low:&MIN up:&CINMAX bitLength:32];
    co = [ORFactory bitVar:m low:&MIN up:&MAX bitLength:32];
    [ORFactory bit: r0 plus:shifta withCarryIn:ci eq:r1 withCarryOut:co];
    ci = [ORFactory bitVar:m low:&MIN up:&CINMAX bitLength:32];
    co = [ORFactory bitVar:m low:&MIN up:&MAX bitLength:32];
    [ORFactory bit: r1 plus:w[round] withCarryIn:ci eq:r2 withCarryOut:co];
    ci = [ORFactory bitVar:m low:&MIN up:&CINMAX bitLength:32];
    co = [ORFactory bitVar:m low:&MIN up:&MAX bitLength:32];
    [ORFactory bit: r2 plus:k withCarryIn:ci eq:result[0] withCarryOut:co];
    
    return result;
    
}

void readFile(FILE *f){
    
    char x[102400];
    char y[102400];
    int sc_count = 0;
    int count = 0;
    long unsigned test = 0;
    char sub1[102400];
    char sub2[102400];
    char sub3[102400];
    char sub4[102400];
    char sub5[102400];
    
    while (fscanf(f, " %4000s", x) == 1) {
        if(count < 1){
            //initHash
            strncpy(sub1, x, 8);
            strncpy(sub2, x+8, 8);
            strncpy(sub3, x+16, 8);
            strncpy(sub4, x+24, 8);
            strncpy(sub5, x+32, 8);
            
            initHash[0] = (uint)strtoul(sub1,0,16);
            initHash[1] = (uint)strtoul(sub2,0,16);
            initHash[2] = (uint)strtoul(sub3,0,16);
            initHash[3] = (uint)strtoul(sub4,0,16);
            initHash[4] = (uint)strtoul(sub5,0,16);
        }
        else if(count%2==1){
            strncpy(sub1, x, 8);
            strncpy(sub2, x+8, 8);
            strncpy(sub3, x+16, 8);
            strncpy(sub4, x+24, 8);
            strncpy(sub5, x+32, 8);
            
            //NSLog(@"Delta");
            Deltas[numFaults][0] = (uint)strtoul(sub1,0,16);
            //NSLog(@"%s: %x", sub1, Deltas[numFaults][0]);
            Deltas[numFaults][1] = (uint)strtoul(sub2,0,16);
            //NSLog(@"%s: %x", sub2, Deltas[numFaults][1]);
            Deltas[numFaults][2] = (uint)strtoul(sub3,0,16);
            //NSLog(@"%s: %x", sub3, Deltas[numFaults][2]);
            Deltas[numFaults][3] = (uint)strtoul(sub4,0,16);
            //NSLog(@"%s: %x", sub4, Deltas[numFaults][3]);
            Deltas[numFaults][4] = (uint)strtoul(sub5,0,16);
            //NSLog(@"%s: %x", sub5, Deltas[numFaults][4]);
            
            
        }
        else if(count%2==0){
            strncpy(sub1, x, 8);
            strncpy(sub2, x+8, 8);
            strncpy(sub3, x+16, 8);
            strncpy(sub4, x+24, 8);
            strncpy(sub5, x+32, 8);
            
            //NSLog(@"Output Hash");
            
            //NSLog(@"sub5 is %s", sub5);
            outputHash[numFaults][0] = (uint)strtoul(sub1,0,16);
            //NSLog(@"%s: %x", sub1, outputHash[numFaults][0]);
            outputHash[numFaults][1] = (uint)strtoul(sub2,0,16);
            // NSLog(@"%s: %x", sub2, outputHash[numFaults][1]);
            outputHash[numFaults][2] = (uint)strtoul(sub3,0,16);
            //NSLog(@"%s: %x", sub3, outputHash[numFaults][2]);
            outputHash[numFaults][3] = (uint)strtoul(sub4,0,16);
            // NSLog(@"%s: %x", sub4, outputHash[numFaults][3]);
            outputHash[numFaults][4] = (uint)strtoul(sub5,0,16);
            // NSLog(@"%s: %x", sub5, outputHash[numFaults][4]);
            
        }
        //Delta and Output Hash
        //NSLog(@"Test x is %s", x);
        
        numFaults++;
        count ++;
    }
    
}


