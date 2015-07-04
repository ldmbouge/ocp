/************************************************************************
Mozilla Public License

Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.

***********************************************************************/

import ORProgram

autoreleasepool {
   let n : ORInt = 8
   let model = ORFactory.createModel()
   let R     = ORFactory.intRange(model, low: 0, up: n - 1)
   let x     = ORFactory.intVarArray(model, range: R, domain: R)
   let e     = sum(model, R) { k in x[k] }
   for var i : ORInt = 0; i < n ; i++ {
      for var j : ORInt = i+1; j < n; j++ {
         model.add(x[i] ≠ x[j])
         model.add(x[i] ≠ x[j] + (i-j))
         model.add(x[i] ≠ x[j] + (j-i))
      }
   }
   let cp = ORFactory.createCPProgram(model)
   let R1 = ORFactory.intRange(model, low: 0, up: n/2)
   let R2 = ORFactory.intRange(model, low: n/2+1, up: n - 1)
   let y1 = ORFactory.intVarArray(model, range: R1) { k in x[k] }
   let y2 = ORFactory.intVarArray(model, range: R2) { k in x[k] }
   //cp.search { firstFail(cp, x) }
   //cp.search { sequence(cp,[firstFail(cp, y1),firstFail(cp, y2)])}
//   cp.search {
//      whileDo(cp, { !cp.allBound(x) }) {
//         let y : ORIntVar = cp.smallestDom(x),
//             v : ORInt    = cp.min(y)
//         return alts(cp,[equal(cp,y,v),diff(cp,y,v)])
//      }
//   }
   cp.search {
      forallDo(cp,R) { k in
         let y = x[k]
         return whileDo(cp,{ !cp.bound(y)}) {
            let v = cp.min(y)
            return equal(cp,y,v) | diff(cp,y,v)
         }
      } »
      Do(cp) {
         print("Solution: " + ORFactory.intArray(cp,range:R) {
            k in cp.intValue(x[k])
         }.description)
      } »
      Do(cp) {
         println("\tAnother message...")
      }
   }
   cp.clearOnSolution()
   println("Number of solutions: \(cp.solutionPool().count())")
   ORFactory.shutdown()
}