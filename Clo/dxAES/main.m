//
//  main.m
//  dxAES
//
//  Created by Waldemar Cruz on 10/26/16.
//  Copyright © 2016 Waldemar Cruz. All rights reserved.
//

#import <ORProgram/ORProgram.h>

void xor(id<ORIntVar>,id<ORIntVar>,id<ORIntVar>);
void xorequ(id<ORIntVar>,id<ORIntVar>,id<ORIntVar>,id<ORIntVar>,id<ORIntVar>,id<ORIntVar>);
void addKey();
void keyExpansion();
void initKS();
void mixColumns();
void shiftrows();
void equRelation();

const int obj = 5;
const int rounds = 3;
const int KC = 4;
const int BC = 4;
const int NBK = KC + rounds * BC / KC;

int i_dY[rounds-1][4][4] = {
   {{1,1,0,0} ,{1,1,0,0} ,{1,1,0,0} ,{1,1,0,0}},
   {{1,0,0,0} ,{1,0,0,0} ,{1,0,0,0} ,{1,0,0,0}}};

int i_dK[rounds][4][4] = {{{1,0,1,0} ,{1,0,1,0} ,{1,0,1,0} ,{1,0,1,0}},
   {{1,1,0,0} ,{1,1,0,0} ,{1,1,0,0} ,{1,1,0,0}},
   {{1,0,0,0} ,{1,0,0,0} ,{1,0,0,0} ,{1,0,0,0}}};

int i_dX[rounds][4][4] = {{
   {0,1,0,0} ,
   {0,1,0,0} ,
   {0,0,1,0} ,
   {0,0,0,1}},
                          {{1,0,0,0} ,{0,0,0,0} ,{0,0,0,0} ,{0,0,0,0}},
                          {{0,0,0,0} ,{0,0,0,0} ,{0,0,0,0} ,{0,0,0,0}}};

int i_dSR[rounds][4][4] = {{{1,1,0,0} ,{0,1,0,0} ,{0,1,0,0} ,{0,0,0,0}},
   {{1,0,0,0} ,{0,0,0,0} ,{0,0,0,0} ,{0,0,0,0}},
   {{0,0,0,0} ,{0,0,0,0} ,{0,0,0,0} ,{0,0,0,0}}};
//With MixColumns
/*
 [0, 0, 0, 0]   [1, 0, 1, 0]   [1, 1, 0, 0]   [1, 1, 0, 0]
 [0, 0, 0, 0]   [1, 0, 1, 0]   [0, 0, 1, 0]   [0, 1, 0, 0]
 [0, 0, 0, 0]   [1, 0, 1, 0]   [0, 0, 0, 1]   [0, 1, 0, 0]
 [0, 0, 0, 0]   [1, 0, 1, 0]   [0, 0, 0, 0]   [0, 0, 0, 0]
 
 [1, 1, 0, 0]   [1, 1, 0, 0]   [1, 0, 0, 0]   [1, 0, 0, 0]
 [1, 1, 0, 0]   [1, 1, 0, 0]   [0, 0, 0, 0]   [0, 0, 0, 0]
 [1, 1, 0, 0]   [1, 1, 0, 0]   [0, 0, 0, 0]   [0, 0, 0, 0]
 [1, 1, 0, 0]   [1, 1, 0, 0]   [0, 0, 0, 0]   [0, 0, 0, 0]
 
 [1, 0, 0, 0]   [1, 0, 0, 0]   [0, 0, 0, 0]   [0, 0, 0, 0]
 [1, 0, 0, 0]   [1, 0, 0, 0]   [0, 0, 0, 0]   [0, 0, 0, 0]
 [1, 0, 0, 0]   [1, 0, 0, 0]   [0, 0, 0, 0]   [0, 0, 0, 0]
 [1, 0, 0, 0]   [1, 0, 0, 0]   [0, 0, 0, 0]   [0, 0, 0, 0]
 */

void printMatrix(id<CPProgram> p,int nbr,id<ORIntVar> m[nbr][4][4])
{
   id* g = [p gamma];
   @autoreleasepool {
      for(int i=0;i < 4;i++) {
         for(int r=0;r < nbr;r++) {
            for(int j=0;j < 4;j++) {
               //NSString* buf = [g[m[r][i][j].getId] description];
               //printf("%s ",[buf UTF8String]);
               int v = [p intValue:m[r][i][j]];
               printf("%d ",v);
            }
            printf("\t ");
         }
         printf("\n");
      }
   }
}


id<ORModel> model;
id<ORIntVar> equRK[rounds][4][rounds][4][4];

//16 + 4*(rounds+1) = 40 elements
id<ORIntVar> V[rounds][4][4][NBK];
id<ORIntVar> dX[rounds][4][4];
id<ORIntVar> dY[rounds-1][4][4];
id<ORIntVar> dK[rounds][4][4];
id<ORIntVar> DSR[rounds][4][4];
id<ORIntVar> colK[rounds][4];
id<ORIntVar> colX[rounds][4];
id<ORIntVar> colSRX[rounds][4];
id<ORIntVar> zero;
int main(int argc, const char * argv[]) {
   NSLog(@"NBK = %d",NBK);
   model = [ORFactory createModel];
   
   for(int r = 0; r < rounds; r++)
      for(int i = 0; i < 4; i++){
         colK[r][i] = [ORFactory intVar:model bounds: [ORFactory intRange:model low:0 up:4]];
         colX[r][i] = [ORFactory intVar:model bounds: [ORFactory intRange:model low:0 up:4]];
         colSRX[r][i] = [ORFactory intVar:model bounds: [ORFactory intRange:model low:0 up:4]];
      }
   
   zero = [ORFactory intVar:model bounds: [ORFactory intRange:model low:0 up:0]];
   
   for(int r = 0; r < rounds; r++)
      for(int i = 0; i < 4; i++){
         for(int j = 0; j < 4; j++){
            for(int k = 0; k < NBK; k++){
               //V[r][i][j][k] = zero;
               V[r][i][j][k] = [ORFactory boolVar:model];
               //V[r][i][j][k] = NULL;
               
            }
         }
      }
   
   for(int r1 = 0; r1 < rounds; r1++)
      for(int r2 = 0; r2 < rounds; r2++)
         for(int i = 0; i < 4; i++)
            for(int j1 = 0; j1 < 4; j1++)
               for(int j2 = 0; j2 < 4; j2++){
                  equRK[r1][j1][r2][j2][i] = NULL;
               }
   
   
   for(int r1 = 0; r1 < rounds; r1++)
      for(int r2 = 0; r2 < rounds; r2++)
         for(int i = 0; i < 4; i++)
            for(int j1 = 0; j1 < 4; j1++)
               for(int j2 = 0; j2 < 4; j2++){
                  //if(equRK[r2][j2][r1][j1][i] != NULL)
                  //   equRK[r1][j1][r2][j2][i] = equRK[r2][j2][r1][j1][i];
                  //else
                  equRK[r1][j1][r2][j2][i] = [ORFactory boolVar:model];
               }
   
   
   for(int r = 0; r < rounds; r++){
      for(int i = 0; i < 4; i++){
         for(int j = 0; j < 4; j++){
            dY[r][i][j] = [ORFactory boolVar:model];
            dK[r][i][j] = [ORFactory boolVar:model];
            dX[r][i][j] = [ORFactory boolVar:model];
            DSR[r][i][j] = [ORFactory boolVar:model];
         }
      }
   }
   
   
   
   for(int r=0; r<rounds-1; r++){
      for(int i = 0; i < 4; i++){
         NSLog(@"%d %d %d %d",i_dY[r][i][0], i_dY[r][i][1], i_dY[r][i][2], i_dY[r][i][3]);
      }
   }
   
   
   id<ORExpr> e = [ORFactory intVar:model bounds: [ORFactory intRange:model low:0 up:0]];
   
   for(int r = 0; r < rounds; r++){
      for(int j = 0; j < 4; j++){
         e = [e plus: colSRX[r][j]];
      }
   }
   
   for(int J = 0; J < 4*rounds; J++){
      if((J % KC) == (KC-1)){
         e = [e plus: colK[J / 4][J % 4]];
      }
   }
   
   /*
    for(int r = 0; r < rounds; r++){
    e = [e plus: colK[r][3]];
    }
    */
   
   //Set Variables to Solution (Testing)
   
   for(int r = 0; r < rounds; r++)
      for(int j = 0; j < 4; j++)
         for(int i = 0; i < 4; i++){
            [model add: [dX[r][j][i] eq: @(i_dX[r][i][j])]];
            [model add: [dK[r][j][i] eq: @(i_dK[r][i][j])]];
            [model add: [DSR[r][j][i] eq: @(i_dSR[r][i][j])]];
         }
   
   for(int r = 0; r < rounds-1; r++)
      for(int j = 0; j < 4; j++){
         for(int i = 0; i < 4; i++){
            [model add: [dY[r][j][i] eq: @(i_dY[r][i][j])]];
         }
      }
   

   initKS();
   keyExpansion(); //Sets V Variables
   
   addKey(); // XOR on dY, dK, and dX variables
   shiftrows();
   mixColumns();
   equRelation();
   
   for(int r = 0; r < rounds; r++){
      for(int j = 0; j < 4; j++){
         [model add: [Sum(model,i,[ORFactory intRange:model low:0 up:3], dK[r][j][i]) eq: colK[r][j]]];
         [model add: [Sum(model,i,[ORFactory intRange:model low:0 up:3], dX[r][j][i]) eq: colX[r][j]]];
         [model add: [Sum(model,i,[ORFactory intRange:model low:0 up:3], DSR[r][j][i]) eq: colSRX[r][j]]];
      }
   }
   
   [model add: [e eq: @(obj)] ];
   
   
   id<CPProgram> cp = (id)[ORFactory createCPProgram: model];
   
   //id<ORIntVar> x[240];
   
   id<ORIntVarArray> x = [ORFactory intVarArray: model range: RANGE(model,0,281)]; // no need to create the vars. You are overwriting below.
   
   int count = 0;
   // The static ordering below does not match the one from minizinc at all.
   for(int r = 0; r < rounds; r++)
      for(int j = 0; j < 4; j++){
         x[count++] = colK[r][j]; // 3 * 4
         x[count++] = colSRX[r][j];
         
         x[count++] = colX[r][j];
      }
   
   for(int r = 0; r < rounds; r++)
      for(int j = 0; j < 4; j++)
         for(int i = 0; i < 4; i++){
            x[count++] = dY[r][j][i];
         }
   
   for(int r = 0; r < rounds; r++)
      for(int j = 0; j < 4; j++)
         for(int i = 0; i < 4; i++){
            x[count++] = dX[r][j][i];
         }
   
   for(int r = 0; r < rounds; r++)
      for(int j = 0; j < 4; j++)
         for(int i = 0; i < 4; i++){
            x[count++] = dK[r][j][i];
         }
   
   
   
   [cp solve:^(){
      NSLog(@"Searching...");
      
      printMatrix(cp,2,dY);
      printMatrix(cp,3,dX);
      printMatrix(cp,3,dK);
      
      
      clock_t searchStart = clock();
      for(int i = 0; i < count; i++){
         if(![cp bound:x[i]]){
            ORInt val = [cp min:x[i]];
            [cp try: ^{
               [cp label:x[i] with:val];
            }
                alt:^{
                   [cp diff:x[i] with:val];
                }];
         }
      }
      NSLog(@"    Objective: %@",[[cp objective] primalValue]);
      //clock_t searchStop = clock();
      //double searchTime = ((double)(searchStop - searchStart))/CLOCKS_PER_SEC;
      //NSLog(@"    Search Time (s): %f",searchTime);
      
      
      for(int r=0; r<rounds; r++){
         for(int j=0; j<4; j++){
            NSLog(@"%d",[cp intValue:colK[r][j]]);
         }
      }
      
      for(int r=0; r<rounds; r++){
         for(int k = 0; k < 4; k++){
            NSLog(@"%d %d %d %d\n",[cp intValue:dK[r][0][k]],[cp intValue:dK[r][1][k]],[cp intValue:dK[r][2][k]],[cp intValue:dK[r][3][k]]);
         }
      }
      
      NSLog(@"   \n");
   }];
   
   return 0;
}

//Correct
void xor(id<ORIntVar> a, id<ORIntVar> b, id<ORIntVar> c){
   [model add: [[[a plus:b] plus: c] neq: @(1)]];
}

//Correct
void xorequ(id<ORIntVar> a, id<ORIntVar> b, id<ORIntVar> c, id<ORIntVar> eab, id<ORIntVar> ebc, id<ORIntVar> eac){
   xor(a,b,c);
   [model add: [[@(1) sub: c] eq: eab]];
   [model add: [[@(1) sub: a] eq: ebc]];
   [model add: [[@(1) sub: b] eq: eac]];
}

//AddRoundKey Implementation (Correct)
void addKey(){
   for(int i = 1; i < rounds; i++){
      for(int c = 0; c < 4; c++){
         for(int r = 0; r < 4; r++){
            xor(dY[i-1][c][r], dK[i][c][r], dX[i][c][r]);
            NSLog(@"%d + %d + %d = %d",i_dY[i-1][c][r], i_dK[i][c][r], i_dX[i][c][r], (i_dY[i-1][c][r] + i_dK[i][c][r] + i_dX[i][c][r]));
            
         }
      }
   }
}

void initKS(){
   //Correct - Part One
   for(int J = 0; J < 4 * rounds; J++){
      for(int i = 0; i < 4; i++){
         int r = J / 4;
         int j = J % 4;
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
               if(k == ((J / KC)*BC+j)){
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

void keyExpansion(){
   //Part Two
   for(int J = 4; J < 4 * rounds; J++){
      for(int i = 0; i < 4; i++){
         int r = J / 4;
         int j = J % 4;
         if(J % KC == 0){
            xor(dK[(J-KC) / BC] [(J-KC) % BC][i],
                dK[(J-1) / BC ] [(J+BC-1) % BC ][(i+1) % 4],
                dK[r][j][i]);
         }
         else{
            
            xorequ(dK[(J-KC) / BC][(J-KC) % BC][i],
                   dK[(J-1) / BC ][(J+BC-1) % BC ][i],
                   dK[r][j][i],
                   equRK[(J-1) / BC ][(J+BC-1) % BC ][(J-KC) / BC][(J-KC) % BC][i],
                   equRK[r][j][(J-KC) / BC][(J-KC) % BC][i],
                   equRK[r][j][(J-1) / BC][(J+BC-1) % BC][i]);
            
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
void shiftrows(){
   for(int r = 0; r < rounds; r++){
      for(int j = 0; j < BC; j++){
         for(int i = 0; i < 4; i++){
            //DSR[r][j][i]=dX[r][((j+i) % BC)][i];
            [model add: [DSR[r][j][i] eq: dX[r][((j+i) % BC)][i]]];
         }
      }
   }
}

//Correct
void mixColumns(){
   for(int r = 0; r < rounds - 1; r++){
      for(int j = 0; j < BC; j++){
         id<ORIntVar> temp = [ORFactory intVar:model bounds:[ORFactory intRange:model low:0 up:8]];
         [model add: [[colSRX[r][j] plus: Sum(model,i,[ORFactory intRange:model low:0 up:3], dY[r][j][i])] eq: temp]];
         
         [model add: [ORFactory restrict:model var:temp to:[ORFactory intSet:model set:[NSSet setWithArray:@[@0, @5, @6, @7, @8]]]]];
      }
   }
   
}
//(Correct)
void equRelation(){
   for(int J = 0; J < rounds*4; J++)
      for(int J2 = J+1; J2 < rounds*4; J2++){
         int r = J / 4;
         int j = J % 4;
         int r2 = J2 / 4;
         int j2 = J2 % 4;
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
            
            for(int J3 = 0; J3 < rounds*4; J3++){
               int r3 = J3 / 4;
               int j3 = J3 % 4;
               
               //EQ[i,r,j,r3,j3] + EQ[i,r,j,r2,j2] + EQ[i,r2,j2,r3,j3] != 2 %transitivity
               
               [model add: [[[equRK[r][j][r3][j3][i] plus: equRK[r][j][r2][j2][i]] plus: equRK[r2][j2][r3][j3][i]] neq: @(2)]];
               
            }
            
         }
      }
}
