//: Playground - The Queens Model.

import ORFoundation
import ORProgram

public func ==(lhs : ORExpr,rhs : ORExpr) -> ORRelation {
   return lhs.eq(rhs)
}
public func ==(lhs : ORExpr,rhs : Int) -> ORRelation {
   return lhs.eq(ORFactory.integer(lhs.tracker(), value: ORInt(rhs)))
}
public func ==(lhs : ORExpr,rhs : Int32) -> ORRelation {
   return lhs.eq(ORFactory.integer(lhs.tracker(), value: ORInt(rhs)))
}
public func ==(lhs : ORExpr,rhs : ORIntVar!) -> ORRelation {
   return lhs.eq(rhs)
}
public func !=(lhs : ORExpr,rhs : ORExpr) -> ORRelation {
   return lhs.neq(rhs)
}
infix operator ≠ { associativity left precedence 130 }
public func ≠(lhs : ORExpr,rhs : ORExpr) -> ORRelation {
   return lhs.neq(rhs)
}
public func +(lhs: ORExpr,rhs : Int) -> ORExpr {
   return lhs.plus(rhs);
}
public func +(lhs: ORExpr,rhs : AnyObject) -> ORExpr {
   return lhs.plus(rhs);
}
public func *(lhs: ORExpr, rhs : Int) -> ORExpr {
   return lhs.mul(rhs)
}
public func *(lhs: ORExpr, rhs : ORInt) -> ORExpr {
   return lhs.mul(ORFactory.integer(lhs.tracker(), value: ORInt(rhs)))
}

func convertArray(s : [UnsafeMutablePointer<Void>]) -> [AnyObject] {
   return s.map({v  in Unmanaged<AnyObject>.fromOpaque(COpaquePointer(v)).takeUnretainedValue() })
}

func wrap<T>(x : T) -> UnsafeMutablePointer<Void> {
   return unsafeBitCast(x, UnsafeMutablePointer<Void>.self)
}
func unwrap<T>(x : UnsafeMutablePointer<Void>) -> T {
   return unsafeBitCast(x, T.self)
}

typealias VoidPtr = UnsafeMutablePointer<Void>
typealias VoidBuf = UnsafeMutableBufferPointer<VoidPtr>

infix operator » { associativity left precedence 70 }
infix operator | { associativity left precedence 80 }

func getSolver(a : VoidPtr) -> CPCommonProgram
{
   var at : AnyObject = Unmanaged<AnyObject>.fromOpaque(COpaquePointer(a)).takeUnretainedValue()
   var tracker =  at.tracker() as! CPCommonProgram
   return tracker
}

func packageVoidArray(sz : Int,body : (Int32,UnsafeMutablePointer<VoidPtr>,VoidBuf) -> VoidPtr) -> VoidPtr
{
   var ptr = UnsafeMutablePointer<VoidPtr>.alloc(sz)
   var ta = UnsafeMutableBufferPointer<VoidPtr>(start: ptr, count: sz)
   let rv = body(Int32(sz), ptr,ta)
   ptr.dealloc(sz)
   return rv;
}

public func »(a : UnsafeMutablePointer<Void>, b : UnsafeMutablePointer<Void>) -> UnsafeMutablePointer<Void> {
   return packageVoidArray(2) { n,base,ptr in
      var tracker = getSolver(a)
      ptr[0] = a
      ptr[1] = b
      return sequence(tracker,n,base)
   }
}

public func |(a : UnsafeMutablePointer<Void>, b : UnsafeMutablePointer<Void>) -> UnsafeMutablePointer<Void> {
   return packageVoidArray(2) { n,base,ptr in
      var tracker = getSolver(a)
      ptr[0] = a
      ptr[1] = b
      return alts(tracker,n,base)
   }
}

func sum(tracker : ORTracker,R : ORIntRange,b : ORInt -> ORExpr) -> ORExpr {
   return ORFactory.sum(tracker, over: R, suchThat: nil, of: b)
}
func range(tracker : ORTracker,r : Range<Int>) -> ORIntRange {
   return ORFactory.intRange(tracker, low: ORInt(r.startIndex), up: ORInt(r.endIndex - 1))
}

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
      let y = x[ORInt(k)]
      return whileDo(cp,{ !cp.bound(y)}) {
         let v = cp.min(y)
         return equal(cp,y,v) | diff(cp,y,v)
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

func sumOf(tracker : ORTracker,R : ORIntRange,b : ((ORInt) -> ORExpr)) -> ORExpr {
   var rv : ORExpr = ORFactory.integer(tracker, value: 0)
   for var i : ORInt = R.low(); i <= R.up(); i++ {
      rv = rv.plus(b(i))
   }
   return rv
}

let e = sumOf(model,R) { k in x[k]}
println(e)




