/************************************************************************
Mozilla Public License

Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.

***********************************************************************/

import ORProgram

autoreleasepool {
   println("magicSerie in swift!")
   let n : ORInt = 12
   let m = ORFactory.createModel()
   let R = ORFactory.intRange(m, low: 0, up: n-1)
   let x = ORFactory.intVarArray(m, range: R, domain: R)
   for i in 0..<n {
      m.add(sum(m, R) {k in x[k] == i} == x[i])
   }
   m.add(sum(m,R) {i in x[i] * i    } == n)
   m.add(sum(m,R) {i in x[i] * (i-1)} == 0)

   var ns    = 0
   let cp = ORFactory.createCPProgram(m)
   cp.onSolution {
      ns++
   println(ORFactory.intArray(cp,range:R) {
         k in cp.intValue(x[k])
      })
   }
   cp.search { firstFail(cp, x) }
   cp.clearOnSolution()
   println("Number of solutions: \(ns)")
   ORFactory.shutdown()
}
