/************************************************************************
Mozilla Public License

Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.

***********************************************************************/

import ORProgram

func show(_ cp : CPProgram,_ x : ORIntVarMatrix)
{
   let r0 = x.range(0)
   let r1 = x.range(1)
   for i in r0.low()...r0.up() {
      for j in r1.low()...r1.up() {
         print("\(cp.intValue(x[i, j])) ",terminator: "")
      }
      print("")
   }
}

autoreleasepool {
   do {
      let buf = try String(contentsOfFile: "sudokuFile3.txt", encoding: String.Encoding.ascii)
      print(buf)
      let scan = Scanner(string: buf)
      var nb : Int = 0
      scan.scanInt(&nb)
      print("#entries \(nb)\n")
      
      let model = ORFactory.createModel()
      let R     = range(model, 1...9)
      let x     = ORFactory.intVarMatrix(model, range: R, R, domain:R)
      
      // Read the sudoku model
      for _ in 0..<nb {
         var r : ORInt = 0,c : ORInt = 0,v : ORInt = 0
         scan.scanInt32(&r)
         scan.scanInt32(&c)
         scan.scanInt32(&v)
         model.add(x[r,c] == v)
      }
      
      for i : ORInt in 1...9 {
         model.add(ORFactory.alldifferent(all(model,R) { j in x[i,j] }))
         model.add(ORFactory.alldifferent(all(model,R) { j in x[j,i] }))
      }
      for i in 0...2 {
         for j in 0...2 {
            let t0 = range(model,i*3+1...i*3+3)
            let t1 = range(model,j*3+1...j*3+3)
            model.add(ORFactory.alldifferent(all(model, t0,t1) { (r,c) in x[r,c] }))
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
   } catch {
      print("Couldn't read the input file")
      return
   }
}
