//: Playground - Experimental pen.
import ORFoundation
import ORProgram

sizeof(UnsafeMutablePointer<Void>)

/*: These should really be in a framework. Not quite working with Command line though */

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
public func +(lhs: ORExpr,rhs : AnyObject) -> ORExpr {
   return lhs.plus(rhs)
}
public func +(lhs: ORExpr,rhs : Int) -> ORExpr {
   return lhs.plus(rhs)
}
public func +(lhs: ORExpr,rhs : ORInt) -> ORExpr {
   return lhs.plus(ORFactory.integer(lhs.tracker(), value: ORInt(rhs)))
}
public func -(lhs: ORExpr,rhs : AnyObject) -> ORExpr {
   return lhs.sub(rhs)
}
public func -(lhs: ORExpr,rhs : Int) -> ORExpr {
   return lhs.sub(rhs)
}
public func -(lhs: ORExpr,rhs : ORInt) -> ORExpr {
   return lhs.sub(ORFactory.integer(lhs.tracker(), value: ORInt(rhs)))
}
public func *(lhs: ORExpr, rhs : ORExpr) -> ORExpr {
   return lhs.mul(rhs)
}
public func *(lhs: ORExpr, rhs : Int) -> ORExpr {
   return lhs.mul(rhs)
}
public func *(lhs: ORExpr, rhs : ORInt) -> ORExpr {
   return lhs.mul(ORFactory.integer(lhs.tracker(), value: ORInt(rhs)))
}
public func /(lhs: ORExpr, rhs : ORExpr) -> ORExpr {
   return lhs.div(rhs)
}
public func /(lhs: ORExpr, rhs : Int) -> ORExpr {
   return lhs.div(rhs)
}
public func /(lhs: ORExpr, rhs : ORInt) -> ORExpr {
   return lhs.div(ORFactory.integer(lhs.tracker(), value: ORInt(rhs)))
}

typealias VoidPtr = UnsafeMutablePointer<Void>
typealias VoidBuf = UnsafeMutableBufferPointer<VoidPtr>

infix operator » { associativity left precedence 70 }
infix operator | { associativity left precedence 80 }

func getSolver(a : VoidPtr) -> CPCommonProgram
{
   let at : AnyObject = Unmanaged<AnyObject>.fromOpaque(COpaquePointer(a)).takeUnretainedValue()
   let tracker =  at.tracker() as! CPCommonProgram
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

func range(tracker : ORTracker,r : Range<Int>) -> ORIntRange {
   return ORFactory.intRange(tracker, low: ORInt(r.startIndex), up: ORInt(r.endIndex - 1))
}
//: This is the model per se (vietnamese Snake)

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

