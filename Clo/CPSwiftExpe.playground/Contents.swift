//: Playground - Experimental pen.
import ORProgram

MemoryLayout<UnsafeMutableRawPointer>.size

/*: These should really be in a framework. Not quite working with Command line though */
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
public func -(lhs: ORExpr,rhs : ORExpr) -> ORExpr {
   return lhs.sub(rhs);
}
public func -(lhs: ORExpr,rhs : Int) -> ORExpr {
   return lhs.sub(rhs);
}
public func -(lhs: ORExpr,rhs : AnyObject) -> ORExpr {
   return lhs.sub(rhs);
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
public func /(lhs: ORExpr,rhs : AnyObject) -> ORExpr {
   return lhs.div(rhs);
}
public func /(lhs: ORExpr,rhs : ORExpr) -> ORExpr {
   return lhs.div(rhs);
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

// This is the model

let m  = ORFactory.createModel()
let x  = ORFactory.intVarArray(m, range: range(tracker: m,r: 1..<10), domain: range(tracker:m,r:1..<10))
m.add(ORFactory.alldifferent(x))
let t2 = (x[2]*13)/x[3]
let t5 = x[5] * 12 - x[6]
let t7 = x[7]*(x[8]/x[9]) - 21
m.add(x[1] + t2 + x[4] + t5 + t7 == 66)

var nbs = 0
let cp = ORFactory.createCPProgram(m)
cp.search {
   firstFail(cp, x) » Do(cp) {
      nbs+=1
      print(ORFactory.intArray(cp,range:x.range()) {
         k in cp.intValue(x[UInt(k)])
      })
   }
}

print("Number of sols \(nbs)\n")
