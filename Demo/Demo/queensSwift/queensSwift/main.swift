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
   let R     = ORFactory.intRange(model, low: 0, up: n - 1)
   let x     = ORFactory.intVarArray(model, range: R, domain: R)
   for  i : ORInt in 0..<n  {
      for j : ORInt in i+1..<n {
         model.add(x[i] ≠ x[j])
         model.add(x[i] ≠ x[j] + (i-j))
         model.add(x[i] ≠ x[j] + (j-i))
      }
   }
   let cp = ORFactory.createCPProgram(model)
   cp.search {
      firstFail(cp, x)
   }
   println("Number of solutions: \(cp.solutionPool().count())")
}