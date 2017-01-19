//: Playground - The Queens Model.

import ORProgram

let n : UInt = 8
let model = ORFactory.createModel()
let R     = range(model,0..<Int(n))
let nbSol = ORFactory.mutable(model, value: 0)
let x     = ORFactory.intVarArray(model, range: R, domain: R)
for i : UInt in 0 ..< n  {
   for j : UInt in i+1 ..< n {
      model.add(x[i] != x[j])
      model.add(x[i] != x[j] + (Int(i)-Int(j)))
      model.add(x[i] != x[j] + (Int(j)-Int(i)))
   }
}

print(model)

let cp = ORFactory.createCPProgram(model)
cp.onSolution {
   nbSol.incr(cp)
   print(ORFactory.intArray(cp,range:x.range()) {
      k in cp.intValue(x[UInt(k)])
   })
}

cp.searchAll {
   forallDo(cp,R) { k in
      let y = x[UInt(k)]
      return whileDo(cp,{ !cp.bound(y)}) {
         let v = cp.min(y)
         return equal(cp,y,v) ◊ diff(cp,y,v)
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

doit(t: a0)

doit(t: [4,5,6,7])

func sumOf(tracker : ORTracker,R : ORIntRange,b : ((ORInt) -> ORExpr)) -> ORExpr {
   var rv : ORExpr = ORFactory.integer(tracker, value: 0)
   for i : ORInt in R.low() ... R.up() {
      rv = rv.plus(b(i))
   }
   return rv
}

let e = sumOf(tracker: model,R: R) { k in x[UInt(k)] }
print(e)


