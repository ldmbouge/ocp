/************************************************************************
Mozilla Public License

Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.

***********************************************************************/

import ORProgram

func show(cp : CPProgram,x : ORIntVarMatrix)
{
   let r0 = x.range(0)
   let r1 = x.range(1)
   for i in r0.low()...r0.up() {
      for j in r1.low()...r1.up() {
         print("\(cp.intValue(x.at(i, j))) ")
      }
      print("\n")
   }
}

autoreleasepool {
   let buf = String(contentsOfFile: "sudokuFile3.txt", encoding: NSASCIIStringEncoding, error: nil)!
   println(buf)
   let scan = NSScanner(string: buf)
   var nb : Int = 0
   scan.scanInteger(&nb)
   print("#entries \(nb)\n")
   
   let model = ORFactory.createModel()
   let R     = range(model, 1...9)
   let x     = ORFactory.intVarMatrix(model, range: R, R, domain:R)
   
   // Read the sudoku model
   for i in 0..<nb {
      var r : ORInt = 0,c : ORInt = 0,v : ORInt = 0
      scan.scanInt(&r)
      scan.scanInt(&c)
      scan.scanInt(&v)
      model.add(x.at(r,c) == v)
   }

   for i : ORInt in 1...9 {
      model.add(ORFactory.alldifferent(all(model,R) { j in x.at(i, j) }))
      model.add(ORFactory.alldifferent(all(model,R) { j in x.at(j, i) }))
   }
   for i in 0...2 {
      for j in 0...2 {
         let t0 = range(model,i*3+1...i*3+3)
         let t1 = range(model,j*3+1...j*3+3)
         model.add(ORFactory.alldifferent(all(model, t0,t1) { (r,c) in x.at(r, c) }))
      }
   }
   
   let cp = ORFactory.createCPProgram(model)
   cp.search {
      firstFail(cp, model.intVars()) » Do(cp) {
         show(cp,x)
      }
   }
   print("Solver status: \(cp)\n")
   print("Quitting\n")
   ORFactory.shutdown()
}
