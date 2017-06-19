/************************************************************************
Mozilla Public License

Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.

***********************************************************************/

import ORProgram

autoreleasepool {
   print("magicSerie in swift!")
   let n = 50
   let m = ORFactory.createModel()
   let an = ORFactory.annotation()
   let R = range(m,0...n)
   let x = ORFactory.intVarArray(m, range: R, domain: R)
   for i in 0..<n {
      an.dc(m.add(sum(m, R: R) {k in x[k] == i} == x[i]))
   }
   m.add(Σ(m,R: R) {i in x[i] * i    } == n)
   m.add(Σ(m,R: R) {i in x[i] * (i-1)} == 0)

   //let cp = ORFactory.createCPParProgram(m, nb: 2, with: ORSemDFSController.proto())
   let cp = ORFactory.createCPProgram(m, annotation: an)
   //let cp = ORFactory.createMIPProgram(m)
   cp.search {
      firstFail(cp, x)
   }
   print("Number of solutions: \(cp.solutionPool().count())")
   if let sol = cp.solutionPool().best() {
      let z = [Int](0..<n).map { k in sol.intValue(x[k])}
      print("Solution is: \(z)")
   }
}
