/************************************************************************
Mozilla Public License

Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.

***********************************************************************/

import ORProgram

autoreleasepool {
   let m  = ORFactory.createModel()
   let x  = ORFactory.intVarArray(m, range: range(m,1..<10), domain: range(m,1..<10))
   m.add(ORFactory.alldifferent(x))
   m.add(x[1] + (x[2]*13)/x[3] + x[4] + x[5]*12 - x[6] - 11 + x[7]*(x[8]/x[9]) - 10 == 66)
   
   var nbs = 0
   let cp = ORFactory.createCPProgram(m)
   
   cp.search {
      firstFail(cp, x) » Do(cp) { nbs++ }
   }
   println("Number of sols \(nbs)")
   ORFactory.shutdown()
}