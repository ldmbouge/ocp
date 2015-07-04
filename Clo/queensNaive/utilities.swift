/************************************************************************
Mozilla Public License

Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.

***********************************************************************/

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


infix operator » { associativity left precedence 80 }
infix operator | { associativity left precedence 80 }

public func »(a : UnsafeMutablePointer<Void>, b : UnsafeMutablePointer<Void>) -> UnsafeMutablePointer<Void> {
   var at : AnyObject = Unmanaged<AnyObject>.fromOpaque(COpaquePointer(a)).takeUnretainedValue()
   var tracker =  at.tracker() as! CPCommonProgram
   var ptr = UnsafeMutablePointer<UnsafeMutablePointer<Void>>.alloc(2)
   var ta = UnsafeMutableBufferPointer<UnsafeMutablePointer<Void>>(start: ptr, count: 2)
   ta[0] = a
   ta[1] = b
   let rv = sequence(tracker, Int32(2), ptr)
   ptr.dealloc(2)
   return rv
}

public func |(a : UnsafeMutablePointer<Void>, b : UnsafeMutablePointer<Void>) -> UnsafeMutablePointer<Void> {
   var at : AnyObject = Unmanaged<AnyObject>.fromOpaque(COpaquePointer(a)).takeUnretainedValue()
   var tracker =  at.tracker() as! CPCommonProgram
   var ptr = UnsafeMutablePointer<UnsafeMutablePointer<Void>>.alloc(2)
   var ta = UnsafeMutableBufferPointer<UnsafeMutablePointer<Void>>(start: ptr, count: 2)
   ta[0] = a
   ta[1] = b
   let rv = alts(tracker, Int32(2), ptr)
   ptr.dealloc(2)
   return rv
}

func sum(tracker : ORTracker,R : ORIntRange,b : ORInt -> ORExpr) -> ORExpr {
   return ORFactory.sum(tracker, over: R, suchThat: nil, of: b)
//   var rv : ORExpr = ORFactory.integer(tracker, value: 0)
//   for var i : ORInt = R.low(); i <= R.up(); i++ {
//      rv = rv.plus(b(i))
//   }
//   return rv
}
func range(tracker : ORTracker,r : Range<Int>) -> ORIntRange {
   return ORFactory.intRange(tracker, low: ORInt(r.startIndex), up: ORInt(r.endIndex - 1))
}