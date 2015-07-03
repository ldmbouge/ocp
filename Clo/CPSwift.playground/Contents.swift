//: Playground - The Queens Model.

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

var str = "Hello, playground"
let n : ORInt = 8
let model = ORFactory.createModel()
let R     = ORFactory.intRange(model, low: 0, up: n - 1)
let nbSol = ORFactory.mutable(model, value: 0)
let x     = ORFactory.intVarArray(model, range: R, domain: R)
for var i : ORInt = 0; i < n ; i++ {
   for var j : ORInt = i+1; j < n; j++ {
      model.add(x[i] != x[j])
      model.add(x[i] != x[j] + (i-j))
      model.add(x[i] != x[j] + (j-i))
   }
}

println(model)
let cp = ORFactory.createCPProgram(model)
cp.onSolution {
   nbSol.incr(cp)
   println(ORFactory.intArray(cp,range:x.range()) {
      k in cp.intValue(x[k])
   })
}

cp.search {
   forallDo(cp,R) { k in
      let y = x[k]
      return whileDo(cp,{ !cp.bound(y)}) {
         let v = cp.min(y)
         return alts(cp,[equal(cp,y,v),diff(cp,y,v)])
      }
   }
}

let ns = cp.intValue(nbSol)

func doit(t : [Int]) -> Int {
   var ttl = 0
   for e in t {
      ttl += e
   }
   return ttl
}

let a0 = [1,2,3,4]

doit(a0)

doit([4,5,6,7])




