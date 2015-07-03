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

func sequence(solver: CPCommonProgram, s: [UnsafeMutablePointer<Void>]) -> UnsafeMutablePointer<Void> {
   let c : [AnyObject] = unsafeBitCast(s,[AnyObject].self)
   return sequence(solver,c)
}

func wrap<T>(x : T) -> UnsafeMutablePointer<Void> {
   return unsafeBitCast(x, UnsafeMutablePointer<Void>.self)
}
func unwrap<T>(x : UnsafeMutablePointer<Void>) -> T {
   return unsafeBitCast(x, T.self)
}

func sum(tracker : ORTracker,R : ORIntRange,b : ORInt -> ORExpr) -> ORExpr {
   return ORFactory.sum(tracker, over: R, suchThat: nil, of: b)
//   var rv : ORExpr = ORFactory.integer(tracker, value: 0)
//   for var i : ORInt = R.low(); i <= R.up(); i++ {
//      rv = rv.plus(b(i))
//   }
//   return rv
}
