//
//  main.swift
//  Clo
//
//  Created by Laurent Michel on 7/27/14.
//
//

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
//cp.onSolution  {
//   nbSol.incr(cp)
//   let s = ORFactory.intArray(cp,range:x.range()) {
//      (k : ORInt) -> ORInt in cp.intValue(x[Int(k)])
//   }
//   println(s)
//}

let a1 = ORFactory.intVarArray(cp, range: ORFactory.intRange(cp, low: 0, up: (n-1)/2)) { (k : ORInt) -> ORIntVar! in x[Int(k)]}!
let a2 = ORFactory.intVarArray(cp, range: ORFactory.intRange(cp, low: (n-1)/2+1, up: n-1)) { (k : ORInt) -> ORIntVar! in x[Int(k)]}!

cp.solveAll { [weak cp,weak a1,weak a2] in
   cp!.labelArray(a1)
   cp!.labelArray(a2)
   
//   cp.forall(R, suchThat: { (k : ORInt) -> Bool in !cp.bound(x[Int(k)]) },
//      orderedBy: { (k : ORInt) -> ORInt in cp.domsize(x[Int(k)]) }, `do`: { (k : ORInt) -> Void in
//         cp.tryall(R, suchThat: { (v : ORInt) -> Bool in Int(cp.member(v,`in`: x[Int(k)])) != 0}, `do`: { (v : ORInt) -> Void in
//               cp.label(x[Int(k)],with:v)
//            })
//      })

   
//   cp.labelArray(x)
   nbSol.incr(cp)
   let s = ORFactory.intArray(cp,range:x.range()) {
      (k : ORInt) -> ORInt in cp!.intValue(x[Int(k)])
   }
   println(s)
}
//cp.defaultSearch()
println(cp.solutionPool())
println("Number of solutions \(cp.solutionPool().count())")


