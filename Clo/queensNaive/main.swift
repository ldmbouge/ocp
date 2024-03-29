/************************************************************************
Mozilla Public License

Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.

***********************************************************************/

import ORProgram

autoreleasepool {
   let n : ORInt = 8
   let model = ORFactory.createModel()
   let R     = ORFactory.intRange(model, low: 0, up: ORInt(n) - 1)
   let x     = ORFactory.intVarArray(model, range: R, domain: R)
   //let e     = sum(model, R : R) { k in x[k] }
   for i in 0..<n  {
      for j : ORInt in i+1..<n {
         model.add(x[i] ≠ x[j])
         model.add(x[i] ≠ x[j] + (i-j))
         model.add(x[i] ≠ x[j] + (j-i))
      }
   }
   let cp = ORFactory.createCPProgram(model)
   let R1 = ORFactory.intRange(model, low: 0, up: n/2)
   let R2 = ORFactory.intRange(model, low: n/2+1, up: n - 1)
   //let y1 = ORFactory.intVarArray(model, range: R1) { k in x[k] }
   //let y2 = ORFactory.intVarArray(model, range: R2) { k in x[k] }
   //cp.search { firstFail(cp, x) }
   //cp.search { sequence(cp,[firstFail(cp, y1),firstFail(cp, y2)])}
//   cp.search {
//      whileDo(cp, { !cp.allBound(x) }) {
//         let y : ORIntVar = cp.smallestDom(x),
//             v : ORInt    = cp.min(y)
//         return alts(cp,[equal(cp,y,v),diff(cp,y,v)])
//      }
//   }
   //let nbF = ORFactory.mutable(cp, value: 0)
   cp.searchAll {
//      repeatDo(cp, {
//            limitSolutionsDo(cp, nbF.intValue()) { firstFail(cp, x) }
//         }, { nbF *= 2 }
//      )
//      
      limitSolutionsDo(cp,4) {
         forallDo(cp,R) { k in
            whileDo(cp,{ !cp.bound(x[ORInt(k)])}) {
               let v = cp.min(x[ORInt(k)])
               return equal(cp,x[ORInt(k)],v) | diff(cp,x[ORInt(k)],v)
            }
         }
      }
         »
      Do(cp) {
         print("Solution: " + ORFactory.intArray(cp,range:R) {
            k in cp.intValue(x[k])
         }.description)
      } »
      Do(cp) {
         print("\tAnother message...",terminator:"\n")
      }
   }
   cp.clearOnSolution()
   print("Number of solutions: \(cp.solutionPool().count())\n")
}
