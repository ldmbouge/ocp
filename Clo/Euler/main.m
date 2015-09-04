/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <ORProgram/ORProgram.h>


//1->11->26->9->3->13->23->8->14->4->10->20->5->15->30->40->46->36->53->63->48->31->16->6->21->27->37->52->58->41->51->57->42->25->19->29->35->50->33->43->49->59->44->61->55->45->60->54->64->47->62->56->39->24->7->22->32->38->28->34->17->2->12->18->1
//39 choices
//3 fails
//199 propagations

id<ORIntSet> knightMoves(id<ORModel> mdl,int i)
{
    id<ORIntSet> S = [ORFactory intSet: mdl];
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
void printCircuit(id<CPProgram> cp,id<ORIntVarArray> jump)
{
    int curr = 1;
    printf("1");
    do {
       curr = [cp min:[jump at: curr]];
       printf("->%d",curr);
    } while (curr != 1);
    printf("\n");
}
int main (int argc, const char * argv[])
{
   @autoreleasepool {
      id<ORModel> mdl = [ORFactory createModel];
      id<ORAnnotation> notes = [ORFactory annotation];
      id<ORIntRange> R = RANGE(mdl,1,64);
      id<ORIntRange> D = RANGE(mdl,1,64);
      id<ORIntVarArray> jump = [ORFactory intVarArray:mdl range: R domain: D];
           
      for(int i = 1; i <= 64; i++)
         [mdl add:[ORFactory restrict:mdl var:jump[i] to: knightMoves(mdl,i)]];
      [notes dc:[mdl add: [ORFactory alldifferent: jump]]];
      [mdl add: [ORFactory circuit: jump]];
      
      id<CPProgram> cp = [ORFactory createCPProgram:mdl annotation:notes];
      [cp solve:
       ^() {
          [cp labelArray: jump orderedBy: ^ORDouble(ORInt i) { return [cp domsize:[jump at:i]];}];
          printCircuit(cp,jump);
       }
       ];
      
      NSLog(@"Solver status: %@\n",cp);
      NSLog(@"Quitting");
      [cp release];
      [ORFactory shutdown];
   }
   return 0;
}



