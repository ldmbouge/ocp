/************************************************************************
Mozilla Public License

Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.

***********************************************************************/

import ORProgram

autoreleasepool {
   let m  = ORFactory.createModel()
   let x  = ORFactory.intVarArray(m, range: range(m, 1..<10), domain: range(m, 1..<10))
   m.add(ORFactory.alldifferent(x))
   let t2 = (x[2]*13)/x[3]
   let t3 = x[7]*(x[8]/x[9])
   let t4 = (x[5]*12)
   m.add(x[1] + t2 + x[4] + t4 - x[6] - 11 + t3 - 10 == 66)
   
   var nbs = 0
   let cp = ORFactory.createCPProgram(m)
   
   cp.searchAll {
      firstFail(cp, x) » Do(cp) { nbs = nbs + 1; }
   }
   print("Number of sols \(nbs)")
}
