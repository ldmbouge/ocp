//: Playground - Experimental pen.

import ORFoundation
import ORProgram

sizeof(UnsafeMutablePointer<Void>)

func range(tracker : ORTracker,r : Range<Int>) -> ORIntRange {
   return ORFactory.intRange(tracker, low: ORInt(r.startIndex), up: ORInt(r.endIndex - 1))
}

var str = "Hello, playground"

let m  = ORFactory.createModel()
let cp = ORFactory.createCPProgram(m)
let x  = ORFactory.intVarArray(m, range: range(m,1..<10), domain: range(m,1..<10))


