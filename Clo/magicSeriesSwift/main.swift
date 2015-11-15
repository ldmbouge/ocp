/************************************************************************
Mozilla Public License

Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.

***********************************************************************/

import ORProgram

autoreleasepool {
   println("magicSerie in swift!")
   let n : ORInt = 14
   let m = ORFactory.createModel()
   let R = range(m,0...n-1)
   let x = ORFactory.intVarArray(m, range: R, domain: R)
   for i in 0..<n {
      m.add(Σ(m, R) {k in x[k] == i} == x[i])
   }
   m.add(Σ(m,R) {i in x[i] * i    } == n)
   m.add(Σ(m,R) {i in x[i] * (i-1)} == 0)

   let cp = ORFactory.createCPProgram(m)
   cp.search { firstFail(cp, x) }
   println("Number of solutions: \(cp.solutionPool().count())")
   if let sol = cp.solutionPool().best() {
      let z = [ORInt](0..<n).map { k in sol.intValue(x[k])}
      println("Solution is: " + z.description)
   }
}
