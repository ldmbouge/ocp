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
void mixColumns();
void equRelation();
const int rounds = 3;

id<ORModel> model;

//int initialDx [4][4] = {{0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0}};
id<ORIntVar> dXI[4][4];
id<ORIntVar> equRK[rounds][4][4][rounds][4][4];

//16 + 4*(rounds+1) = 40 elements
id<ORIntVar> V[rounds][4][4][40];
id<ORIntVar> dX[rounds][4][4];
id<ORIntVar> dY[rounds][4][4];
id<ORIntVar> dK[rounds][4][4];
id<ORIntVar> zero;
int main(int argc, const char * argv[]) {
   model = [ORFactory createModel];
   
   id<ORIntVar> colK[rounds][4];
   id<ORIntVar> colX[rounds][4];
   
   for(int r = 0; r < rounds; r++)
      for(int i = 0; i < 4; i++){
         colK[r][i] = [ORFactory intVar:model bounds: [ORFactory intRange:model low:0 up:4]];
         colX[r][i] = [ORFactory intVar:model bounds: [ORFactory intRange:model low:0 up:4]];
      }
   zero = [ORFactory intVar:model bounds: [ORFactory intRange:model low:0 up:0]];
   
   for(int r = 0; r < rounds; r++)
      for(int i = 0; i < 4; i++){
         for(int j = 0; j < 4; j++){
            for(int k = 0; k < 40; k++){
               //V[r][i][j][k] = zero;
               V[r][i][j][k] = [ORFactory boolVar:model];
               
            }
         }
      }
   
   for(int r1 = 0; r1 < rounds; r1++)
      for(int r2 = 0; r2 < rounds; r2++)
         for(int i1 = 0; i1 < 4; i1++)
            for(int j1 = 0; j1 < 4; j1++)
               for(int i2 = 0; i2 < 4; i2++)
                  for(int j2 = 0; j2 < 4; j2++){
                     equRK[r1][i1][j1][r2][i2][j2] = NULL;
                  }
   
   for(int r1 = 0; r1 < rounds; r1++)
      for(int r2 = 0; r2 < rounds; r2++)
         for(int i1 = 0; i1 < 4; i1++)
            for(int j1 = 0; j1 < 4; j1++)
               for(int i2 = 0; i2 < 4; i2++)
                  for(int j2 = 0; j2 < 4; j2++){
                     if(equRK[r2][i2][j2][r1][i1][j1] != NULL)
                        equRK[r1][i1][j1][r2][i2][j2] = equRK[r2][i2][j2][r1][i1][j1];
                     else
                        equRK[r1][i1][j1][r2][i2][j2] = [ORFactory boolVar:model];
                     
                  }
   
   for(int r = 0; r < rounds; r++)
      for(int i = 0; i < 4; i++)
         for(int j = 0; j < 4; j++){
            dY[r][i][j] = [ORFactory boolVar:model];
            dK[r][i][j] = [ORFactory boolVar:model];
            dX[r][i][j] = [ORFactory boolVar:model];
         }
   
   /*
    for(int i = 0; i < 4; i++)
    for(int j = 0; j < 4; j++)
    dXI[i][j] = [ORFactory intVar:model value:initialDx[i][j]];
    */
   
   for(int i = 0; i < 4; i++)
      for(int j = 0; j < 4; j++)
         dXI[i][j] = [ORFactory boolVar:model];
   
   
   for(int r = 0; r < rounds; r++)
      for(int j = 0; j < 4; j++){
         [model add: [Sum(model,i,[ORFactory intRange:model low:0 up:3], dK[r][j][i]) eq: colK[r][j]]];
         [model add: [Sum(model,i,[ORFactory intRange:model low:0 up:3], dX[r][j][i]) eq: colX[r][j]]];
         
      }
   
   id<ORExpr> e = [ORFactory intVar:model bounds: [ORFactory intRange:model low:0 up:0]];
   
   for(int r = 0; r < rounds; r++){
      for(int j = 0; j < 4; j++){
         e = [e plus: dK[r][j][3]];
         for(int i = 0; i < 4; i++){
            e = [e plus: dX[r][j][i]];
         }
      }
   }
   
   addKey();
   keyExpansion();
   mixColumns();
   equRelation();
   
   
   id<ORIntVar> obj = [ORFactory intVar:model bounds: [ORFactory intRange:model low:0 up:200]];
   
   [model add: [e eq: obj] ];
   //[model add: [@(5) eq: obj] ];
   
   [model minimize:obj];
   
   
   id<CPProgram> cp = (id)[ORFactory createCPProgram: model];
   
   //id<ORIntVar> x[240];
   
   id<ORIntVarArray> x = [ORFactory intVarArray: model range: [ORFactory intRange: model low: 0 up: 279] domain: [ORFactory intRange: model low: 0 up: 1]];
   
   
   int count = 0;
   
   for(int r = 0; r < rounds; r++)
      for(int j = 0; j < 4; j++){
         x[count++] = colK[r][j];
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
      
      /*
       for(int j=0; j<16; j++){
       NSLog(@"%@",gamma[keys[0][j].getId]);
       }
       */
   }];
   
   return 0;
}

void xor(id<ORIntVar> a, id<ORIntVar> b, id<ORIntVar> c){
   [model add: [[[a plus:b] plus: c] neq: @(1)]];
}

void xorequ(id<ORIntVar> a, id<ORIntVar> b, id<ORIntVar> c, id<ORIntVar> eab, id<ORIntVar> ebc, id<ORIntVar> eac){
   [model add: [[[a plus:b] plus: c] neq: @(1)]];
   [model add: [[@(1) sub: c] eq: eab]];
   [model add: [[@(1) sub: a] eq: ebc]];
   [model add: [[@(1) sub: b] eq: eac]];
}

//AddRoundKey Implementation
void addKey(){
   
   for(int c = 0; c < 4; c++)
      for(int r = 0; r < 4; r++)
         xor(dXI[c][r], dK[0][c][r], dX[0][c][r]);
   
   for(int i = 1; i < rounds; i++){
      for(int c = 0; c < 4; c++)
         for(int r = 0; r < 4; r++)
            xor(dY[i-1][c][r], dK[i][c][r], dX[i][c][r]);
   }
}

//Key Expansion Implemenation
void keyExpansion(){
   for(int i = 1; i < rounds; i++){
      for(int r = 0; r < 4; r++)
         xor(dK[i-1][0][r], dK[i-1][3][(r+1)%4], dK[i][0][r]);
   }
   
   for(int i = 1; i < rounds; i++){
      for(int c = 1; c < 4; c++)
         for(int r = 0; r < 4; r++)
            xorequ(dK[i][c-1][r], dK[i-1][c][r], dK[i][c][r], equRK[i][c-1][r][i-1][c][r], equRK[i-1][c][r][i][c][r], equRK[i][c-1][r][i][c][r]);
   }
   
   //Initial KeyComponents
   for(int j = 0; j < 4; j++)
      for(int k = 0; k < 4; k++)
         for(int j2 = 0; j2 < 4; j2++)
            for(int k2 = 0; k2 < 4; k2++){
               if(j2*4+k2 == j*4+k){
                  [model add: [V[0][j][k][j2*4+k2] eq: dK[0][j][k]]];
                  //V[0][j][k][j2*4+k2] = dK[0][j][k];
               }
               else{
                  [model add: [V[0][j][k][j2*4+k2] eq: @(0)]];
                  //V[0][j][k][j2*4+k2] = zero;
                  
               }
            }
   
   //SubByte KeyComponents
   for(int r = 1; r < rounds; r++){
      for(int i = 16; i < 40; i++){
         for(int k = 0; k < 4; k++){
            for(int j = 0; j < 4; j++){
               if(j == 0 && i >=16){
                  [model add: [V[r][j][k][i] eq: dK[r-1][j][(k + 5) % 4]]];
                  //V[r][j][k][i] = dK[r-1][j][(k + 5) % 4];
                  
               }
               else{
                  if(j > 0){
                     [model add: [V[r][j][k][i] eq: V[r-1][j-1][k][i]]];
                     //V[r][j][k][i] = V[r-1][j-1][k][i];
                     
                  }
               }
            }
         }
      }
   }
   
   for(int r = 1; r < rounds; r++)
      for(int j = 0; j < 4; j++)
         for(int k = 0; k < 4; k++)
            [model add: [[Sum(model,i,[ORFactory intRange:model low:0 up:39],V[r][j][k][i]) plus: dK[r][j][k]] neq: @(-1)]];
   
   
   for(int i = 0; i < 4; i++){
      for(int j=4; j<(rounds*4); j++){
         for(int k = 0; k < 40; k++){
            id<ORIntVar> temp1 = [ORFactory boolVar:model];
            id<ORIntVar> temp2 = [ORFactory boolVar:model];
            [model add: [[V[(j-4)/4][(j-4)%4][i][k] mul: dK[(j-4)/4][(j-4)%4][i]] eq: temp1]];
            [model add: [[V[(j-1)/4][(j+3)%4][i][k] mul: dK[(j-1)/4][(j+3)%4][i]] eq: temp2]];
            [model add: [[temp1 neq: temp2] eq: V[j/4][j % 4][i][k]]];
         }
      }
   }
   
   
}

void mixColumns(){
   for(int i = 0; i < (rounds - 1); i++){
      for(int j = 0; j < 4; j++){
         id<ORExpr> expr = [ORFactory intVar:model value:0];
         for(int k = 0; k < 4; k++){
            expr = [[expr plus: dX[i][(k+j)%4][k]] plus: dY[i][j][k]];
         }
         id<ORIntVar> temp = [ORFactory intVar:model bounds:[ORFactory intRange:model low:0 up:8]];
         [model add: [expr eq: temp]];
         [model add: [ORFactory restrict:model var:temp to:[ORFactory intSet:model set:[NSSet setWithArray:@[@0, @5, @6, @7, @8]]]]];
      }
   }
   
}

void equRelation(){
   for(int r1 = 0; r1 < rounds; r1++)
      for(int r2 = 0; r2 < rounds; r2++)
         for(int i1 = 0; i1 < 4; i1++)
            for(int j1 = 0; j1 < 4; j1++)
               for(int i2 = 0; i2 < 4; i2++)
                  for(int j2 = 0; j2 < 4; j2++){
                     //Symmetry Constraints
                     //[model add: [equRK[r1][i1][j1][r2][i2][j2] eq: equRK[r2][i2][j2][r1][i1][j1]]];
                     
                     //Relate to Binary Variables
                     //[model add: [[equRK[r1][i1][j1][r2][i2][j2] eq: @(1)] imply: [dK[r1][i1][j1] eq: dK[r2][i2][j2]]]];
                     [model add: [equRK[r1][i1][j1][r2][i2][j2] imply: [dK[r1][i1][j1] eq: dK[r2][i2][j2]]]];
                     [model add: [[[equRK[r1][i1][j1][r2][i2][j2] plus: dK[r1][i1][j1]] plus: dK[r2][i2][j2]] neq: @(0)]];
                  }
   
   for(int r1 = 0; r1 < rounds; r1++)
      for(int r2 = 0; r2 < rounds; r2++)
         for(int r3 = 0; r3 < rounds; r3++)
            for(int i1 = 0; i1 < 4; i1++)
               for(int j1 = 0; j1 < 4; j1++)
                  for(int i2 = 0; i2 < 4; i2++)
                     for(int j2 = 0; j2 < 4; j2++)
                        for(int i3 = 0; i3 < 4; i3++)
                           for(int j3 = 0; j3 < 4; j3++){
                              //Transistive Property
                              if(equRK[r1][i1][j1][r2][i2][j2] != equRK[r2][i2][j2][r3][i3][j3]){
                                 //[model add: [[equRK[r1][i1][j1][r2][i2][j2] eq: [equRK[r2][i2][j2][r3][i3][j3] eq: @(1)]] imply: [equRK[r1][i1][j1][r3][i3][j3] eq: @(1)]]];
                                 [model add: [[equRK[r1][i1][j1][r2][i2][j2] eq: equRK[r2][i2][j2][r3][i3][j3]] imply: [equRK[r1][i1][j1][r3][i3][j3] eq: @(1)]]];
                              }
                              else{
                                 [model add: [equRK[r1][i1][j1][r3][i3][j3] eq: @(1)]];
                              }
                              
                           }
}



