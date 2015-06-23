/************************************************************************
Mozilla Public License

Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.

***********************************************************************/

import ORFoundation
import ORProgram

func !=(lhs : ORExpr,rhs : ORExpr) -> ORRelation {
   return lhs.neq(rhs)
}
func +(lhs: ORExpr,rhs : Int) -> ORExpr {
   return lhs.plus(rhs);
}
func +(lhs: ORExpr,rhs : AnyObject) -> ORExpr {
   return lhs.plus(rhs);
}
autoreleasepool {
   let n : ORInt = 8
   let model = ORFactory.createModel()
   let R     = ORFactory.intRange(model, low: 0, up: n - 1)
   let nbSol = ORFactory.mutable(model, value: 0)
   let x     = ORFactory.intVarArray(model, range: R, domain: R)
   for var i  = 0; i < Int(n) ; i++ {
      for var j = i+1; j < Int(n); j++ {
         model.add(x[i] != x[j])
         model.add(x[i] != x[j] + (i-j))
         model.add(x[i] != x[j] + (j-i))
      }
   }
   let cp = ORFactory.createCPProgram(model)
   cp.onSolution {
      nbSol.incr(cp)
      let s = ORFactory.intArray(cp,range:x.range()) {
         (k : ORInt) -> ORInt in cp.intValue(x[Int(k)])
      }
      println(s)
   }
   cp.defaultSearch()
   cp.clearOnSolution()
   println("Number of solutions \(cp!.solutionPool().count())")
   ORFactory.shutdown()
}