//: Playground - Experimental pen.

import ORFoundation
import ORProgram

sizeof(UnsafeMutablePointer<Void>)

var str = "Hello, playground"

func sequence(solver: CPCommonProgram, s: [UnsafeMutablePointer<Void>]) -> UnsafeMutablePointer<Void> {
   let c : [AnyObject] = unsafeBitCast(s,[AnyObject].self)
   return sequence(solver,c)
}

func unwrap<T>(x : UnsafeMutablePointer<Void>) -> T {
   return unsafeBitCast(x, T.self)
}

func range(tracker : ORTracker,r : Range<Int>) -> ORIntRange {
   return ORFactory.intRange(tracker, low: ORInt(r.startIndex), up: ORInt(r.endIndex - 1))
}

infix operator » { associativity left precedence 80 }
infix operator | { associativity left precedence 80 }

public func »(a : UnsafeMutablePointer<Void>, b : UnsafeMutablePointer<Void>) -> UnsafeMutablePointer<Void> {
   let at : ORSTask = unwrap(a)
   let tracker =  at.tracker() as! CPCommonProgram
   return sequence(tracker, [a,b])
}

public func |(a : UnsafeMutablePointer<Void>, b : UnsafeMutablePointer<Void>) -> UnsafeMutablePointer<Void> {
   let at : ORSTask = unwrap(a)
   let bt : ORSTask = unwrap(a)
   let tracker =  at.tracker() as! CPCommonProgram
   return alts(tracker, [at,bt])
}

let m  = ORFactory.createModel()
let cp = ORFactory.createCPProgram(m)
let x  = ORFactory.intVarArray(m, range: range(m,1..<10), domain: range(m,1..<10))

let e0 = firstFail(cp, x) » firstFail(cp, x)
let e1 = equal(cp,x[1],1) | diff(cp, x[1],1)

let z0 = unsafeBitCast(e0, UnsafeMutablePointer<ORSTask>.self).memory
let z1 = unsafeBitCast(e1, UnsafeMutablePointer<ORSTask>.self).memory

