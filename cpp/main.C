#include <iostream>
#include <iomanip>
#include "DFSController.H"
#include "CPIVar.H"
#include "cont.H"
using namespace std;

void traverseTree() {
   int x;
   initContinuationLibrary(&x);
   DFSController* cp = new DFSController();
   int* cnt = new int;
   *cnt = 0;
   const int nbv = 8;
   CPIVar* vars[nbv];
   for(int i=0;i< nbv;i++)
      vars[i] = new CPIVar(0,10);
   int c = 0;
   for(int c =0;c<nbv;c++) {
      cout << "vars[" << c << "] = " << vars[c]->get() << endl;
   }
   solveall(*cp, [vars,nbv,cp,cnt] {
      int i;
      for(i=0;i<nbv;i++) {
         CPIVar* cv = vars[i];
         int v = 0;
         while (!cv->bound() && v < cv->getIMax()) {
            tryb(*cp, [=] {
                  cv->set(v);
               }, [cv,&v] {                  
                  cv->reset();
                  v = v+1;
                  //cout << "WE DID IT!" << endl;
            });
        } 
         if (v>=cv->getIMax()) cp->fail();
      }
      /*
      cout << "GOT SOL:" << endl;
      for(int c =0;c<nbv;c++) {
         cout << "vars[" << c << "] = " << vars[c]->get() << endl;
         }*/
      //cout << "COUNTER i = " << *cnt << endl;
      (*cnt)++;   
   }, [&] {
         cout << "Finally exiting... " << *cnt << endl;
      });   
}


int main()
{
   traverseTree();
   return 0;
}
