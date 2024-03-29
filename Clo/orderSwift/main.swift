/************************************************************************
Mozilla Public License

Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.

***********************************************************************/

import ORProgram

autoreleasepool {
   let start = ORRuntimeMonitor.cputime()
   let model = ORFactory.createModel()
   let n : ORInt = 64
   let D = ORFactory.intRange(model, low: 0, up: n)
   let x = ORFactory.intVarArray(model, range: D, domain: D)
   for k : ORInt in 0...n-1 {
      model.add(x[k] < x[k+1])
   }
   let cp = ORFactory.createCPProgram(model)
   cp.search {
      Do(cp) {
         let xv = (0...n).map { i in cp.intValue(x[i]) }
         print("solution: \(xv)",terminator:"\n")
      }
   }
   let end = ORRuntimeMonitor.cputime()
   print("solving time: \(end - start)",terminator:"\n")
}
