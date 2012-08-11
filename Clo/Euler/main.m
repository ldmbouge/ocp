/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <Foundation/Foundation.h>
#import <Foundation/Foundation.h>
#import "objcp/CPConstraint.h"
#import "objcp/CP.h"
#import "objcp/CPFactory.h"
#import "objcp/CPlabel.h"
#import "ORFoundation/ORFactory.h"


//1->11->26->9->3->13->23->8->14->4->10->20->5->15->30->40->46->36->53->63->48->31->16->6->21->27->37->52->58->41->51->57->42->25->19->29->35->50->33->43->49->59->44->61->55->45->60->54->64->47->62->56->39->24->7->22->32->38->28->34->17->2->12->18->1
//39 choices
//3 fails
//199 propagations

id<ORIntSet> knightMoves(id<CPSolver> cp,int i) 
{
    id<ORIntSet> S = [CPFactory intSet: cp];
    if (i % 8 == 1) {
      [S insert: i-15]; [S insert: i-6]; [S insert: i+10]; [S insert: i+17];
    }
    else if (i % 8 == 2) {
      [S insert: i-17]; [S insert: i-15]; [S insert: i-6]; [S insert: i+10]; [S insert: i+15]; [S insert: i+17];
    }     
    else if (i % 8 == 7) {
      [S insert: i-17];[S insert: i-15];[S insert: i-10];[S insert: i+6];[S insert: i+15];[S insert: i+17];
    }
    else if (i % 8 == 0) {
      [S insert: i-17];[S insert: i-10];[S insert: i+6];[S insert: i+15];
    }           
    else {
      [S insert: i-17];[S insert: i-15];[S insert: i-10];[S insert: i-6];[S insert: i+6];[S insert: i+10];[S insert: i+15];[S insert: i+17];
    }
    return S;
}
void printCircuit(id<ORIntVarArray> jump)
{
    int curr = 1;
    printf("1");
    do {
        curr = [[jump at: curr] min];
        printf("->%d",curr);
    } while (curr != 1);
    printf("\n");
}
int main (int argc, const char * argv[])
{
    id<CPSolver> cp = [CPFactory createSolver];
    id<ORIntRange> R = RANGE(cp,1,64);
   id<ORIntRange> D = RANGE(cp,1,64);
    id<ORIntVarArray> jump = [CPFactory intVarArray:cp range: R domain: D];
   
    NSLog(@"%@",jump[1]);
   printf("min %d \n",[jump[1] min]);
   printf("max %d \n",[jump[1] max]);
   printf("size %d \n",[jump[1] domsize]);
   
   for(int i = 1; i <= 64; i++)
      [cp restrict: [jump at: i] to: knightMoves(cp,i)];
   [cp add: [CPFactory alldifferent: jump consistency: DomainConsistency]];
   [cp add: [CPFactory circuit: jump]];

    [cp solve:
     ^() {
         [CPLabel array: jump orderedBy: ^CPInt(CPInt i) { return [[jump at:i] domsize];}];
         printCircuit(jump);
     }
     ];

    NSLog(@"Solver status: %@\n",cp);
    NSLog(@"Quitting");
    [cp release];
    [CPFactory shutdown];
    return 0;
}



