/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORProgram/ORProgram.h>
#import "ORCmdLineArgs.h"


int symbolToNum(char symbol) {
  switch (symbol) {
    case '~':
      return 0;
    case 'm':
      return 1;
    case 'o':
      return 2;
    case 't':
      return 3;
    case 'r':
      return 4;
    case 'b':
      return 5;
    case 'l':
      return 6;
    default:
      return 0;
  }
}

char numToSymbol(int num) {
  switch (num) {
    case 0:
      return '~';
    case 1:
      return 'm';
    case 2:
      return 'o';
    case 3:
      return 't';
    case 4:
      return 'r';
    case 5:
      return 'b';
    case 6:
      return 'l';
    default:
      return '~';
  }
}

void show(id<CPProgram> cp,id<ORIntVarMatrix> m,ORInt rows[11],ORInt cols[11])
{
   id<ORIntRange> R = [m range: 0];
   id<ORIntRange> C = [m range: 1];
   for(ORInt j = [R low]+2 ; j < [R up]-1; j++) {
      printf("%d ",rows[j]);
      for(ORInt i = C.low+2 ; i < C.up-1; i++) {
         printf("%c ",numToSymbol([cp intValue:[m at:i:j]]));
      }
      printf("\n");
   }
   printf("  ");
   for(ORInt j= 1;j < [R up]-1;j++) {
     printf("%d ",cols[j]); 
   }
   printf("\n");
}

int main (int argc, const char * argv[])
{
   @autoreleasepool {
      FILE* f = fopen("battleshipFile1.txt","r");
      int nb;
      int r, c, num;
      char v;
      id<ORModel> mdl = [ORFactory createModel];
      id<ORIntRange> R = RANGE(mdl,1,10);
      id<ORIntRange> RX = RANGE(mdl,-1,12);
      id<ORIntRange> RV = RANGE(mdl,0,6);
      id<ORIntRange> RF = RANGE(mdl,0,1);
      ORInt rows[11] = {0,0,0,0,0,0,0,0,0,0,0};
      ORInt *rowsPtr = rows;
      ORInt cols[11] = {0,0,0,0,0,0,0,0,0,0,0};
      ORInt *colsPtr = cols;
      for(ORInt i = [R low] ; i <= [R up]; i++) {
        fscanf(f,"%d",&num);
        rows[i] = num;
      }
      for(ORInt i = [R low] ; i <= [R up]; i++) {
        fscanf(f,"%d",&num);
        cols[i] = num;
      }
      fscanf(f,"%d \n",&nb);
      printf("number of initial hits %d \n",nb);
      id<ORIntVarMatrix> b = [ORFactory intVarMatrix: mdl range: RX : RX domain: RV];
      id<ORIntVarMatrix> fill = [ORFactory intVarMatrix: mdl range: RX : RX domain: RF];
      id<ORIntVarArray> a  = [ORFactory intVarArray: mdl range: RX : RX with: ^id<ORIntVar>(ORInt i,ORInt j) { return [b at: i : j]; }];
      for(ORInt i = 0; i < nb; i++) {
         fscanf(f,"%d %d %c",&r,&c,&v);
         [mdl  add: [[b at: r : c] eq: @(symbolToNum(v))]];
      }

      //Make extended rows and cols empty
      for(ORInt i=[RX low];i<=[RX up];i++) {
        [mdl add:[[b at:i:[RX low]] eq: @(0)]];
        [mdl add:[[b at:i:[RX low]+1] eq: @(0)]];
        [mdl add:[[b at:i:[RX up]] eq: @(0)]];
        [mdl add:[[b at:i:[RX up]-1] eq: @(0)]];
        [mdl add:[[b at:[RX low]:i] eq: @(0)]];
        [mdl add:[[b at:[RX low]+1:i] eq: @(0)]];
        [mdl add:[[b at:[RX up]:i] eq: @(0)]];
        [mdl add:[[b at:[RX up]-1:i] eq: @(0)]];
      }

      for(ORInt j=[RX low];j<=[RX up];j++) {
        for(ORInt i=[RX low];i <=[RX up];i++) {
          //Fill array matches board array
          [mdl add:[[[b at:i:j] eq: @(0)] imply: [[fill at:i:j] eq: @(0)]]];
          [mdl add:[[[b at:i:j] neq: @(0)] imply: [[fill at:i:j] eq: @(1)]]];
        }
      }

      for(ORInt j=1;j<=[R up];j++) {
        for(ORInt i=1;i <=[R up];i++) {

          //Spacing constraints:  Gaps between ships
          [mdl add:[[[b at:i:j] gt: @(0)] imply: [[b at:i+1:j+1] eq: @(0)]]];
          [mdl add:[[[b at:i:j] gt: @(0)] imply: [[b at:i+1:j-1] eq: @(0)]]]; //diagonal constraints
          [mdl add:[[[[b at:i:j] gt: @(1)] land: [[b at:i:j] neq: @(3)]] imply: [[b at:i:j+1] eq: @(0)]]];
          [mdl add:[[[[b at:i:j] gt: @(1)] land: [[b at:i:j] neq: @(4)]] imply: [[b at:i-1:j] eq: @(0)]]];
          [mdl add:[[[[b at:i:j] gt: @(1)] land: [[b at:i:j] neq: @(5)]] imply: [[b at:i:j-1] eq: @(0)]]];
          [mdl add:[[[[b at:i:j] gt: @(1)] land: [[b at:i:j] neq: @(6)]] imply: [[b at:i+1:j] eq: @(0)]]];

          //Ship shape constraints
          [mdl add:[[[b at:i:j] eq: @(3)] imply: [[[b at:i:j+1] eq: @(5)] lor: [[b at:i:j+1] eq: @(1)]]]];
          [mdl add:[[[b at:i:j] eq: @(4)] imply: [[[b at:i-1:j] eq: @(6)] lor: [[b at:i-1:j] eq: @(1)]]]];
          [mdl add:[[[b at:i:j] eq: @(5)] imply: [[[b at:i:j-1] eq: @(3)] lor: [[b at:i:j-1] eq: @(1)]]]];
          [mdl add:[[[b at:i:j] eq: @(6)] imply: [[[b at:i+1:j] eq: @(4)] lor: [[b at:i+1:j] eq: @(1)]]]];
          [mdl add:[[[b at:i:j] eq: @(1)] imply: [[[[fill at:i-1:j] eq: [fill at:i+1:j]] land: [[fill at:i:j-1] eq: [fill at:i:j+1]]] land: [[[fill at:i+1:j] plus: [fill at:i:j+1]] eq: @(1)]]]];
        }
      }

      for(ORInt i=1;i<=[R up];i++) {
        id<ORExpr> srow = [ORFactory sum:mdl over:R
                                suchThat:^BOOL(ORInt a)       { return true;}
                                      of:^id<ORExpr>(ORInt a) { return [fill at:a:i];}];
        [mdl add:[srow eq:@(rows[i])]];
        id<ORExpr> scol = [ORFactory sum:mdl over:R
                                suchThat:^BOOL(ORInt a)       { return true;}
                                      of:^id<ORExpr>(ORInt a) { return [fill at:i:a];}];
        [mdl add:[scol eq:@(cols[i])]];
      }

      id<ORExpr> ssub = [ORFactory sum:mdl over:R over:R
                              suchThat:^BOOL(ORInt x, ORInt y)       { return true; }
                                    of:^id<ORExpr>(ORInt x, ORInt y) { return [@(1) mul: [[b at:x:y] eq: @(2)]]; }];
      [mdl add:[ssub eq:@(4)]];

      id<ORExpr> sdes = [ORFactory sum:mdl over:R over:R
                              suchThat:^BOOL(ORInt x, ORInt y)       { return true; }
                                    of:^id<ORExpr>(ORInt x, ORInt y) { return [@(1) mul: 
                                           [[[[b at:x:y] eq: @(6)] land: [[b at:x+1:y] eq: @(4)]] lor:
                                            [[[b at:x:y] eq: @(3)] land: [[b at:x:y+1] eq: @(5)]] ]]; }];
      [mdl add:[sdes eq:@(3)]];

      id<ORExpr> scru = [ORFactory sum:mdl over:R over:R
                              suchThat:^BOOL(ORInt x, ORInt y)       { return true; }
                                    of:^id<ORExpr>(ORInt x, ORInt y) { return [@(1) mul: 
                                           [[[[[b at:x:y] eq: @(6)] land: [[b at:x+1:y] eq: @(1)]] land: [[b at:x+2:y] eq: @(4)]] lor:
                                            [[[[b at:x:y] eq: @(3)] land: [[b at:x:y+1] eq: @(1)]] land: [[b at:x:y+2] eq: @(5)]] ]]; }];
      [mdl add:[scru eq:@(2)]];
      NSLog(@"%@",mdl);

      id<CPProgram> cp = [ORFactory createCPProgram:mdl];
      [cp solve:
       ^() {
          [cp labelArray: a orderedBy: ^ORDouble(ORInt i) { return [cp domsize:a[i]];}];


          NSLog(@"%@",mdl);
          show(cp,b,rowsPtr,colsPtr);
       }
       ];
      
      NSLog(@"Solver status: %@\n",cp);
      NSLog(@"Quitting");
   }
   return 0;
}
