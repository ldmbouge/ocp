/************************************************************************
Mozilla Public License

Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.

***********************************************************************/

import ORFoundation
import ORProgram


infix operator ∨ { associativity left precedence 110 }

public func ∨(lhs : ORExpr,rhs : ORExpr) -> ORRelation {
   return lhs.lor(rhs)
}
prefix func !(lhs : ORExpr) -> ORRelation {
   return lhs.neg();
}
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

public func <(lhs : ORExpr,rhs : ORExpr) -> ORRelation {
   return lhs.lt(rhs)
}
public func <(lhs : ORExpr,rhs : Int) -> ORRelation {
   return lhs.lt(ORFactory.integer(lhs.tracker(), value: ORInt(rhs)))
}
public func <(lhs : ORExpr,rhs : Int32) -> ORRelation {
   return lhs.lt(ORFactory.integer(lhs.tracker(), value: ORInt(rhs)))
}
public func <(lhs : ORExpr,rhs : ORIntVar) -> ORRelation {
   return lhs.lt(rhs)
}

public func >(lhs : ORExpr,rhs : ORExpr) -> ORRelation {
   return lhs.gt(rhs)
}
public func >(lhs : ORExpr,rhs : Int) -> ORRelation {
   return lhs.gt(ORFactory.integer(lhs.tracker(), value: ORInt(rhs)))
}
public func >(lhs : ORExpr,rhs : Int32) -> ORRelation {
   return lhs.gt(ORFactory.integer(lhs.tracker(), value: ORInt(rhs)))
}
public func >(lhs : ORExpr,rhs : ORIntVar) -> ORRelation {
   return lhs.gt(rhs)
}

infix operator ≤ { associativity left precedence 130 }
infix operator ≥ { associativity left precedence 130 }
public func ≥(lhs : ORExpr,rhs : ORExpr) -> ORRelation {
   return lhs.geq(rhs)
}
public func ≥(lhs : ORExpr,rhs : Int) -> ORRelation {
   return lhs.geq(ORFactory.integer(lhs.tracker(), value: ORInt(rhs)))
}
public func ≥(lhs : ORExpr,rhs : Int32) -> ORRelation {
   return lhs.geq(ORFactory.integer(lhs.tracker(), value: ORInt(rhs)))
}
public func ≥(lhs : ORExpr,rhs : ORIntVar) -> ORRelation {
   return lhs.geq(rhs)
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
   let at : AnyObject = Unmanaged<AnyObject>.fromOpaque(COpaquePointer(a)).takeUnretainedValue()
   let tracker =  at.tracker() as! CPCommonProgram
   return tracker
}

func packageVoidArray(sz : Int,body : (Int32,UnsafeMutablePointer<VoidPtr>,VoidBuf) -> VoidPtr) -> VoidPtr
{
   let ptr = UnsafeMutablePointer<VoidPtr>.alloc(sz)
   let ta = UnsafeMutableBufferPointer<VoidPtr>(start: ptr, count: sz)
   let rv = body(Int32(sz), ptr,ta)
   ptr.dealloc(sz)
   return rv;
}

public func »(a : UnsafeMutablePointer<Void>, b : UnsafeMutablePointer<Void>) -> UnsafeMutablePointer<Void> {
   return packageVoidArray(2) { n,base,ptr in
      let tracker = getSolver(a)
      ptr[0] = a
      ptr[1] = b
      return sequence(tracker,n,base)
   }
}

public func |(a : UnsafeMutablePointer<Void>, b : UnsafeMutablePointer<Void>) -> UnsafeMutablePointer<Void> {
   return packageVoidArray(2) { n,base,ptr in
      let tracker = getSolver(a)
      ptr[0] = a
      ptr[1] = b
      return alts(tracker,n,base)
   }
}

public func exist(tracker : ORTracker,_ r : ORIntRange,_ b : ORInt -> ORRelation) -> ORRelation {
   return ORFactory.lor(tracker, over: r, suchThat: nil, of: b)
}
public func exist(tracker : ORTracker,_ r : ORIntRange,_ f : (ORInt -> Bool),_ b : ORInt -> ORRelation) -> ORRelation {
   return ORFactory.lor(tracker, over: r, suchThat: f, of: b)
}
public func sum(tracker : ORTracker,R : ORIntRange,_ f : (ORInt -> Bool),b : ORInt -> ORExpr) -> ORExpr {
   return ORFactory.sum(tracker, over: R, suchThat: f, of: b)
}
public func sum(tracker : ORTracker,R : ORIntRange,b : ORInt -> ORExpr) -> ORExpr {
   return ORFactory.sum(tracker, over: R, suchThat: nil, of: b)
}
public func range(tracker : ORTracker,_ r : Range<Int>) -> ORIntRange {
   return ORFactory.intRange(tracker, low: ORInt(r.startIndex), up: ORInt(r.endIndex - 1))
}

public func Σ(tracker : ORTracker,R : ORIntRange,b : ORInt -> ORExpr) -> ORExpr {
   return ORFactory.sum(tracker, over: R, suchThat: nil, of: b)
}

public func all(t : ORTracker,_ r : ORIntRange,body : ((i : ORInt) -> ORIntVar)) -> ORIntVarArray {
   return ORFactory.intVarArray(t, range: r, with: body)
}

public func all(t : ORTracker,_ r1 : ORIntRange,_ r2 : ORIntRange, body : (i : ORInt, j : ORInt) -> ORIntVar) -> ORIntVarArray {
   return ORFactory.intVarArray(t, range: r1,r2, with: body)
}

extension ORIntVarMatrix {
   subscript(i : ORInt, j : ORInt) -> ORIntVar {
      get {
         return self.at(i, j)
      }
      set(newValue) {
         return self.set(newValue, at: i, j)
      }
   }
   subscript(i : Int, j : Int) -> ORIntVar {
      get {
         return self.at(ORInt(i), ORInt(j))
      }
      set(newValue) {
         return self.set(newValue, at: ORInt(i), ORInt(j))
      }
   }
}


extension ORIntMatrix {
   subscript(i : ORInt, j : ORInt) -> ORInt {
      get {
         return self.at(i, j)
      }
      set(newValue) {
         return self.set(newValue, at: i, j)
      }
   }
   subscript(i : Int, j : Int) -> ORInt {
      get {
         return self.at(ORInt(i), ORInt(j))
      }
      set(newValue) {
         return self.set(newValue, at: ORInt(i), ORInt(j))
      }
   }
}


//
//extension ORIntVarArray {
//   subscript (key: Int) -> ORIntVar {
//      get {
//         return self.at(key)
//      }
//      set(newValue) {
//         return self.set(newValue, ORInt(key))
//      }
//   }
//}
