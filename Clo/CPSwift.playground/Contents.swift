//: Playground - The Queens Model.

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

precedencegroup ComparisonPrecedence {
   associativity : left
}
infix operator ≠ : ComparisonPrecedence

//infix operator ≠ { associativity left precedence 130 }
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

func convertArray(s : [UnsafeMutableRawPointer]) -> [AnyObject] {
   return s.map({v  in Unmanaged<AnyObject>.fromOpaque(v).takeUnretainedValue() })
}

func wrap<T>(x : T) -> UnsafeMutableRawPointer {
   return unsafeBitCast(x, to: UnsafeMutableRawPointer.self)
}
func unwrap<T>(x : UnsafeMutableRawPointer) -> T {
   return unsafeBitCast(x, to: T.self)
}

typealias VoidPtr = UnsafeMutableRawPointer
typealias VoidBuf = UnsafeMutableBufferPointer<VoidPtr>

precedencegroup CodePrecedence {
   associativity : left
   lowerThan : AssignmentPrecedence
}

infix operator » : CodePrecedence
infix operator | : CodePrecedence

//infix operator » { associativity left precedence 70 }
//infix operator | { associativity left precedence 80 }

func getSolver(anObject : VoidPtr) -> CPCommonProgram
{
   let at : AnyObject = Unmanaged<AnyObject>.fromOpaque(anObject).takeUnretainedValue()
   let tracker =  at.tracker() as! CPCommonProgram
   return tracker
}

func packageVoidArray(sz : Int,body : (Int32,UnsafeMutablePointer<VoidPtr>,VoidBuf) -> VoidPtr) -> VoidPtr
{
   let ptr = UnsafeMutablePointer<VoidPtr>.allocate(capacity: sz)
   let ta = UnsafeMutableBufferPointer<VoidPtr>(start: ptr, count: sz)
   let rv = body(Int32(sz), ptr,ta)
   ptr.deallocate(capacity: sz)
   return rv;
}

public func »(a : UnsafeMutableRawPointer, b : UnsafeMutableRawPointer) -> UnsafeMutableRawPointer {
   return packageVoidArray(sz: 2) { n,base,ptr in
      let tracker = getSolver(anObject: a)
      ptr[0] = a
      ptr[1] = b
      return sequence(tracker,n,base)
   }
}

public func |(a : UnsafeMutableRawPointer, b : UnsafeMutableRawPointer) -> UnsafeMutableRawPointer {
   return packageVoidArray(sz: 2) { n,base,ptr in
      let tracker = getSolver(anObject: a)
      ptr[0] = a
      ptr[1] = b
      return alts(tracker,n,base)
   }
}

func sum(tracker : ORTracker,R : ORIntRange,b : @escaping (ORInt) -> ORExpr) -> ORExpr {
   return ORFactory.sum(tracker, over: R, suchThat: nil, of: b)
}
func range(tracker : ORTracker,r : Range<Int>) -> ORIntRange {
   return ORFactory.intRange(tracker, low: ORInt(r.lowerBound), up: ORInt(r.upperBound - 1))
}

let n : UInt = 8
let model = ORFactory.createModel()
let R     = ORFactory.intRange(model, low: 0, up: ORInt(n) - 1)
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




