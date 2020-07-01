/************************************************************************
Mozilla Public License

Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.

***********************************************************************/

import ORProgram

//infix operator ∨ { associativity left precedence 110 }
infix operator ∨ : LogicalDisjunctionPrecedence
infix operator ∋ : MultiplicationPrecedence
infix operator ∈ : MultiplicationPrecedence
infix operator ∉ : MultiplicationPrecedence

public func ||(lhs : ORExpr,rhs : ORExpr) -> ORRelation {
   return lhs.lor(rhs)
}
public func ∨(lhs : ORExpr,rhs : ORExpr) -> ORRelation {
   return lhs.lor(rhs)
}
public func &&(lhs : ORExpr,rhs : ORExpr) -> ORRelation {
    return lhs.land(rhs)
}

prefix func !(lhs : ORExpr) -> ORRelation {
   return lhs.neg();
}
public func ==(lhs : ORExpr,rhs : ORExpr) -> ORRelation {
   return lhs.eq(rhs)
}
public func ==(lhs : ORExpr,rhs : Bool) -> ORRelation {
    return lhs.eq(ORFactory.integer(lhs.tracker(), value: ORInt(rhs ? 1 : 0)))
}
public func ==(lhs : ORExpr,rhs : Int) -> ORRelation {
   return lhs.eq(ORFactory.integer(lhs.tracker(), value: ORInt(rhs)))
}
public func ==(lhs : ORExpr,rhs : Int32) -> ORRelation {
   return lhs.eq(ORFactory.integer(lhs.tracker(), value: ORInt(rhs)))
}
public func ==(lhs : ORExpr,rhs : Double) -> ORRelation {
   return lhs.eq(ORFactory.double(lhs.tracker(), value: ORDouble(rhs)))
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

//infix operator ≤ { associativity left precedence 130 }
//infix operator ≥ { associativity left precedence 130 }
infix operator ≤ : ComparisonPrecedence
infix operator ≥ : ComparisonPrecedence

public func ≥(lhs : ORExpr,rhs : ORExpr) -> ORRelation {
   return lhs.geq(rhs)
}
public func ≥(lhs : ORExpr,rhs : Int) -> ORRelation {
   return lhs.geq(ORFactory.integer(lhs.tracker(), value: ORInt(rhs)))
}
public func ≥(lhs : ORExpr,rhs : Double) -> ORRelation {
   return lhs.geq(ORFactory.double(lhs.tracker(), value: ORDouble(rhs)))
}
public func ≥(lhs : ORExpr,rhs : Int32) -> ORRelation {
   return lhs.geq(ORFactory.integer(lhs.tracker(), value: ORInt(rhs)))
}
public func ≥(lhs : ORExpr,rhs : ORIntVar) -> ORRelation {
   return lhs.geq(rhs)
}
public func ≤(lhs : ORExpr,rhs : ORExpr) -> ORRelation {
   return lhs.leq(rhs)
}
public func ≤(lhs : ORExpr,rhs : Int) -> ORRelation {
   return lhs.leq(ORFactory.integer(lhs.tracker(), value: ORInt(rhs)))
}
public func ≤(lhs : ORExpr,rhs : Int32) -> ORRelation {
   return lhs.leq(ORFactory.integer(lhs.tracker(), value: ORInt(rhs)))
}
public func ≤(lhs : ORExpr,rhs : Double) -> ORRelation {
   return lhs.leq(ORFactory.double(lhs.tracker(), value: ORDouble(rhs)))
}
public func ≤(lhs : Int,rhs : ORExpr) -> ORRelation {
    return rhs.geq(ORFactory.integer(rhs.tracker(), value: ORInt(lhs)))
}

public func !=(lhs : ORExpr,rhs : ORExpr) -> ORRelation {
   return lhs.neq(rhs)
}
public func !=(lhs : ORExpr,rhs : Int) -> ORRelation {
   return lhs.neq(ORFactory.integer(lhs.tracker(), value: ORInt(rhs)))
}

public func ∉(lhs : ORExpr,rhs : ORExpr) -> ORExpr {
    return ORFactory.exprNegate(rhs.contains(lhs, track: lhs.tracker()), track: lhs.tracker())
}

//infix operator ≠ { associativity left precedence 130 }
infix operator ≠ : ComparisonPrecedence

public func ≠(lhs : ORExpr,rhs : ORExpr) -> ORRelation {
   return lhs.neq(rhs)
}
public func ≠(lhs : ORExpr,rhs : Double) -> ORRelation {
   return lhs.neq(ORFactory.double(lhs.tracker(), value: ORDouble(rhs)))
}
public func +(lhs: ORExpr,rhs : ORExpr) -> ORExpr {
    return lhs.plus(rhs)
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
public func -(lhs: ORExpr,rhs : ORExpr) -> ORExpr {
    return lhs.sub(rhs)
}
public func -(lhs: ORExpr,rhs : AnyObject) -> ORExpr {
   return lhs.sub(rhs)
}
public func -(lhs: ORExpr,rhs : Int) -> ORExpr {
   return lhs.sub(ORFactory.integer(lhs.tracker(), value: ORInt(rhs)))
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
public func *(lhs: ORExpr, rhs : Double) -> ORExpr {
   return lhs.mul(ORFactory.double(lhs.tracker(), value: ORDouble(rhs)))
}
public func *(lhs: ORInt, rhs : Int) -> ORInt {
   return lhs * ORInt(rhs)
}
public func *(lhs: Int, rhs : ORInt) -> ORInt {
   return ORInt(lhs) * rhs
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

public func min(_ lhs: ORExpr, _ rhs : ORExpr) -> ORExpr {
    return lhs.min(rhs)
}
public func min(_ lhs: ORExpr, _ rhs : Int) -> ORExpr {
    return lhs.min(rhs)
}
public func min(_ lhs: ORExpr, _ rhs : ORInt) -> ORExpr {
    return lhs.min(ORFactory.integer(lhs.tracker(), value: ORInt(rhs)))
}
public func max(_ lhs: ORExpr,_ rhs : ORExpr) -> ORExpr {
    return lhs.max(rhs)
}
public func max(_ lhs: ORExpr,_ rhs : Int) -> ORExpr {
    return lhs.max(rhs)
}
public func max(_ lhs: ORExpr,_ rhs : ORInt) -> ORExpr {
    return lhs.max(ORFactory.integer(lhs.tracker(), value: ORInt(rhs)))
}
public func abs(_ op : ORExpr) -> ORExpr {
    return op.abs()
}

public func literal(_ t : ORTracker,_ op : Int) -> ORExpr {
    return ORFactory.integer(t, value: ORInt(op))
}

func convertArray(s : [UnsafeMutablePointer<Any>]) -> [AnyObject] {
   return s.map({v  in Unmanaged<AnyObject>.fromOpaque(v).takeUnretainedValue() })
}

func wrap<T>(x : T) -> UnsafeMutablePointer<Any> {
   return unsafeBitCast(x, to:UnsafeMutablePointer.self)
}
func unwrap<T>(x : UnsafeMutablePointer<Any>) -> T {
   return unsafeBitCast(x, to:T.self)
}

typealias VoidPtr = UnsafeMutableRawPointer
typealias VoidBuf = UnsafeMutableBufferPointer<VoidPtr>

precedencegroup BranchingPrecedence {
   lowerThan : AssignmentPrecedence
   associativity : left
}
precedencegroup SequencingPrecedence {
   lowerThan     : AssignmentPrecedence
   associativity : left
}
//infix operator » { associativity left precedence 70 }
//infix operator | { associativity left precedence 80 }
infix operator » : SequencingPrecedence
infix operator | : BranchingPrecedence

func getSolver(_ a : VoidPtr) -> CPCommonProgram
{
   let at : AnyObject = Unmanaged<AnyObject>.fromOpaque(a).takeUnretainedValue()
   let tracker =  at.tracker() as! CPCommonProgram
   return tracker
}

func packageVoidArray(sz : Int,body : (Int32,UnsafeMutablePointer<VoidPtr>,VoidBuf) -> VoidPtr) -> VoidPtr
{
   let ptr = UnsafeMutablePointer<VoidPtr>.allocate(capacity:sz)
   let ta = UnsafeMutableBufferPointer<VoidPtr>(start: ptr, count: sz)
   let rv = body(Int32(sz), ptr,ta)
   ptr.deallocate()
   return rv;
}

public func »(a : UnsafeMutableRawPointer, b : UnsafeMutableRawPointer) -> UnsafeMutableRawPointer {
    return packageVoidArray(sz:2) { n,base,ptr in
      let tracker = getSolver(a)
      ptr[0] = a
      ptr[1] = b
      return sequence(tracker,n,base)
   }
}

public func |(a : UnsafeMutableRawPointer, b : UnsafeMutableRawPointer) -> UnsafeMutableRawPointer {
   return packageVoidArray(sz:2) { n,base,ptr in
      let tracker = getSolver(a)
      ptr[0] = a
      ptr[1] = b
      return alts(tracker,n,base)
   }
}

public func exist(_ tracker : ORTracker,_ r : ORIntRange,_ b : @escaping (ORInt) -> ORRelation) -> ORRelation {
   return ORFactory.lor(tracker, over: r, suchThat: nil, of: b)
}
public func exist(_ tracker : ORTracker,_ r : ORIntRange,_ f : @escaping (ORInt) -> Bool,_ b : @escaping (ORInt) -> ORRelation) -> ORRelation {
   return ORFactory.lor(tracker, over: r, suchThat: f, of: b)
}
public func sum(_ tracker : ORTracker,R : ORIntRange,_ f : @escaping (ORInt) -> Bool,b : @escaping (ORInt) -> ORExpr) -> ORExpr {
   return ORFactory.sum(tracker, over: R, suchThat: f, of: b)
}
public func sum(_ tracker : ORTracker,R : ORIntRange,b : @escaping (ORInt) -> ORExpr) -> ORExpr {
   return ORFactory.sum(tracker, over: R, suchThat: nil, of: b)
}
public func range(_ tracker : ORTracker,_ r : CountableClosedRange<Int>) -> ORIntRange {
   return ORFactory.intRange(tracker, low: ORInt(r.lowerBound), up: ORInt(r.upperBound))
}
public func range(_ tracker : ORTracker,low  : Int,up : Int) -> ORIntRange {
   return ORFactory.intRange(tracker, low: ORInt(low), up: ORInt(up))
}

public func Σ(_ tracker : ORTracker,R : ORIntRange,b : @escaping (ORInt) -> ORExpr) -> ORExpr {
   return ORFactory.sum(tracker, over: R, suchThat: nil, of: b)
}

public func all(_ t : ORTracker,_ r : ORIntRange,_ body : @escaping ((_ i : ORInt) -> ORIntVar)) -> ORIntVarArray {
   return ORFactory.intVarArray(t, range: r, with: body)
}

public func all(_ t : ORTracker,_ r1 : ORIntRange,_ r2 : ORIntRange, body : @escaping (_ i : ORInt,_ j : ORInt) -> ORIntVar) -> ORIntVarArray {
   return ORFactory.intVarArray(t, range: r1,r2, with: body)
}

public func Prop(_ t : ORTracker,_ name : Int32) -> ORExpr {
    return ORFactory.getStateValue(t,lookup:name)
}
public func Prop(_ t : ORTracker,_ name : Int) -> ORExpr {
    return ORFactory.getStateValue(t,lookup:Int32(name))
}
public func Prop(_ t : ORTracker,_ name : ORExpr) -> ORExpr {
    return ORFactory.getStateValue(t,lookupExpr:name)
}

public func StateProp(_ s : Optional<UnsafeMutablePointer<Int8>>,_ p : Int,_ fpi : Int,_ stateDesc : MDDStateDescriptor) -> Int {
    return Int(stateDesc.getProperty(Int32(p + fpi), forState: s))
}

public func SVA(_ t : ORTracker) -> ORExpr {
    return ORFactory.valueAssignment(t)
}
public func VariableIndex(_ t : ORTracker) -> ORExpr {
    return ORFactory.layerVariable(t)
}

public func intArray(_ t : ORTracker, range : ORIntRange, body  : @escaping (Int) -> Int) -> ORIntArray
{
    let m = ORFactory.intArray(t, range: range) { i in ORInt(body(Int(i))) }
    return m
}
public func intMatrix(_ t : ORTracker, r1 : ORIntRange,_ r2 : ORIntRange, body : (Int,Int) -> Int) -> ORIntMatrix
{
    let m = ORFactory.intMatrix(t, range: r1, r2)
    for i in r1.low() ... r1.up() {
        for j in r2.low() ... r2.up() {
           m[i,j] = ORInt(body(Int(i),Int(j)))
        }
    }
    return m
}

/*public func minClosure(_ p : Int, _ fpi : Int) -> DDMergeClosure {
    let minClosure : DDMergeClosure = { (newState, left,right) in
        return min(StateProp(left, p, fpi),StateProp(right, p, fpi))
    }
    return minClosure
}
public func maxClosure(_ p : Int, _ fpi : Int) -> DDMergeClosure {
    let maxClosure : DDMergeClosure = { (newState, left,right) in
        return max(StateProp(left, p, fpi),StateProp(right, p, fpi))
    }
    return maxClosure
}
public func leftClosure(_ p : Int, _ fpi : Int) -> DDMergeClosure {
    let leftClosure : DDMergeClosure = { (newState, left,right) in
        return StateProp(left, p, fpi)
    }
    return leftClosure
}
public func differenceClosure(_ p : Int, _ fpi : Int) -> DDMergeClosure {
    let diffClosure : DDMergeClosure = { (newState, left,right) in
        return abs(StateProp(left, p, fpi) - StateProp(right, p, fpi))
    }
    return diffClosure
}*/

extension Dictionary {
    subscript(t : ORTracker, i : ORExpr) -> ORExpr {
        get {
            return ORFactory.dictionaryValue(t, dictionary:self, key:i)
        }
    }
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

public func ∋(_ set: ORIntSet,_ e : ORExpr) -> ORExpr {
    return set.contains(e)
}
public func ∈(_ e : ORExpr,_ set: ORIntSet) -> ORExpr {
    return set.contains(e)
}

//extension ORIntArray {
//    subscript(index:ORExpr) -> ORExpr {
//        get {
//            return self.atIndex(index)
//        }
//    }
//}

extension ORMDDSpecs {
    func state<Key,Value>(_ d : [(Key,Value)]) -> Void where Key : BinaryInteger,Value : BinaryInteger {
        for (k,v) in d {
            self.addForwardStateCounter(ORInt(k), withDefaultValue: ORInt(v))
        }
    }
    func state<Key,Value>(_ d : Dictionary<Key,Value>) -> Void where Key : BinaryInteger,Value : BinaryInteger {
        for (k,v) in d {
            self.addForwardStateCounter(ORInt(k), withDefaultValue: ORInt(v))
        }
    }
    func state<Key>(_ d : [(Key,Bool)]) -> Void where Key : BinaryInteger {
        for (k,v) in d {
            self.addForwardStateBool(ORInt(k), withDefaultValue: v)
        }
    }
    func state<Key>(_ d : Dictionary<Key,Bool>) -> Void where Key : BinaryInteger {
        for (k,v) in d {
            self.addForwardStateBool(ORInt(k), withDefaultValue: v)
        }
    }
    func state<Key>(_ d : [(Key,Bool,Int)]) -> Void where Key : BinaryInteger {
        for (key,value,size) in d {
            self.addForwardStateBitSequence(ORInt(key), withDefaultValue: value, size:Int32(size))
        }
    }
    func bottomUpState<Key>(_ d : [(Key,Bool,Int)]) -> Void where Key : BinaryInteger {
        for (key,value,size) in d {
            self.addReverseStateBitSequence(ORInt(key), withDefaultValue: value, size:Int32(size))
        }
    }
    func bottomUpState<Key,Value>(_ d : [(Key,Value)]) -> Void where Key : BinaryInteger,Value : BinaryInteger {
        for (k,v) in d {
            self.addReverseStateCounter(ORInt(k), withDefaultValue: ORInt(v))
        }
    }
    func state2<Key,Value>(_ d : Dictionary<Key,Value>) -> [Key] where Key : BinaryInteger {
        for (k,v) in d {
            self.addForwardStateCounter(k as! Int32, withDefaultValue: (ORInt)( v as! Int))
        }
        return Array(d.keys)
    }
    func setAsAmong(_ domainRange : ORIntRange!, _ lb : Int, _ ub : Int, _ values : ORIntSet!) {
        self.setAsAmongConstraint(domainRange, lb: Int32(lb), ub: Int32(ub), values:values)
    }
    func setAsDualDirectionalAmong(_ domainRange : ORIntRange!, _ lb : Int, _ ub : Int, _ values : ORIntSet!) {
        self.setAsDualDirectionalAmongConstraint(domainRange, lb: Int32(lb), ub: Int32(ub), values:values)
    }
    func setAsSequence(_ domainRange : ORIntRange!, _ length : Int, _ lb : Int, _ ub : Int, _ values : ORIntSet!) {
        self.setAsSequenceConstraint(domainRange, length: Int32(length), lb: Int32(lb), ub: Int32(ub), values:values)
    }
    func setAsSequenceWithBitSequence(_ domainRange : ORIntRange!, _ length : Int, _ lb : Int, _ ub : Int, _ values : ORIntSet!) {
        self.setAsSequenceConstraintWithBitSequence(domainRange, length: Int32(length), lb: Int32(lb), ub: Int32(ub), values:values)
    }
}

extension ORIntArray {
    subscript (key : Int) -> ORInt {
        return self.at(ORInt(key))
    }
    subscript (key : ORExpr) -> ORExpr {
        return self.elt(key)
    }
}

extension ORIntVarArray {
   subscript (key: ORInt) -> ORIntVar {
      get {
         return self.at(key)
      }
      set(newValue) {
         return self.set(newValue, at: ORInt(key))
      }
   }
   subscript (key: Int) -> ORIntVar {
      get {
         return self.at(ORInt(key))
      }
      set(newValue) {
         return self.set(newValue, at: ORInt(key))
      }
   }
    var size : Int {
        get {
            return (Int)(self.count())
        }
    }
}

extension ORRealVarArray {
   subscript (key: ORInt) -> ORRealVar {
      get {
         return self.at(key)
      }
      set(newValue) {
         return self.set(newValue, at: ORInt(key))
      }
   }
   subscript (key: Int) -> ORRealVar {
      get {
         return self.at(ORInt(key))
      }
      set(newValue) {
         return self.set(newValue, at: ORInt(key))
      }
   }
}

public func left(_ t : ORTracker,_ v : Int)   -> ORExpr { return ORFactory.getLeftStateValue(t,lookup:Int32(v)) }
public func right(_ t : ORTracker,_ v : Int)  -> ORExpr { return ORFactory.getRightStateValue(t,lookup:Int32(v)) }

public func arrayDomains(_ t : ORIntVarArray) -> ORIntRange {
    var low = MAXINT,up = -ORInt(0x7FFFFFFF)
    for i in t.range().low() ... t.range().up() {
        low = min(t[i].domain().low() ,low)
        up  = max(t[i].domain().up(),up)
    }
    return ORFactory.intRange(t.tracker(), low: low, up: up)
}

public func toDict<V>(_ r: ORIntRange, map: (Int) -> (key: Int, value: V)) -> [Int : V] {
    var dict = [Int : V]()
    for element in 0 ..< r.size() {
        let (key, value) = map(Int(element))
        dict[key] = value
    }
    return dict
}

public func toDict<V>(_ low: Int,_ up : Int, map: (Int) -> (key: Int, value: V)) -> [Int : V] {
    var dict = [Int : V]()
    for element in low ..< up {
        let (key, value) = map(Int(element))
        dict[key] = value
    }
    return dict
}

extension Bool {
    var intValue: Int {
        return self ? 1 : 0
    }
}


// -----------------------------------------------------------------------------------------------------------------
// MDD constraints
// -----------------------------------------------------------------------------------------------------------------

public func amongMDDClosures(m : ORTracker,x : ORIntVarArray,lb : Int, ub : Int,values : ORIntSet) -> ORMDDSpecs {
    let minC = 0,maxC = 1
    let udom = arrayDomains(x)
    let mdd = ORFactory.mddSpecs(m, variables: x, numForwardProperties: 2, numReverseProperties: 2, numCombinedProperties: 0)
    mdd.state([(minC, 0),(maxC, 0)])
    mdd.bottomUpState([(minC, 0),(maxC, 0)])
    
    mdd.setAsDualDirectionalAmong(udom,lb,ub,values)
    return mdd
}

public func allDiffMDDWithSetsAndClosures(_ vars : ORIntVarArray) -> ORMDDSpecs {
    let m = vars.tracker(),
        udom = arrayDomains(vars)
    let domSize = Int(udom.size())
    let some = 0,
        all = 1,
        numAssigned = 2
        
    let mdd = ORFactory.mddSpecs(m, variables: vars, stateSize: 3)
    mdd.state([(some, false, domSize),(all, false, domSize)])
    mdd.state([(numAssigned,0)])
    mdd.setAsAllDifferent(udom)
    return mdd
}
public func allDiffDualDirectionalMDDWithSetsAndClosures(_ vars : ORIntVarArray) -> ORMDDSpecs {
    let m = vars.tracker(),
        udom = arrayDomains(vars)
    let domSize = Int(udom.size()),
        numVars = Int32(vars.count())
    let someDown = 0, allDown = 1, numAssignedDown = 2,
        someUp = 0, allUp = 1
        
    let mdd = ORFactory.mddSpecs(m, variables: vars, numForwardProperties: 3, numReverseProperties: 2, numCombinedProperties: 0)
    mdd.state([(someDown, false, domSize),(allDown, false, domSize)])
    mdd.state([(numAssignedDown,0)])
    mdd.bottomUpState([(someUp, false, domSize),(allUp, false, domSize)])
    mdd.setAsDualDirectionalAllDifferent(numVars, domain: udom)
    return mdd
}

public func sumMDD(m : ORTracker,vars : ORIntVarArray, weights : [Int], lb : Int32, ub : Int32) -> ORMDDSpecs {
    let udom = arrayDomains(vars)
    let maxDom = udom.up(),
        numVars = Int(vars.count())
    let minDown = 0, maxDown = 1, numAssignedDown = 2,
        minUp = 0, maxUp = 1
    var int32Weights : [Int32] = []
    for weight in weights { int32Weights.append(Int32(weight)) }
    let weightsPointer = UnsafeMutablePointer<Int32>.allocate(capacity: numVars)
    weightsPointer.initialize(from: int32Weights, count: numVars)
        
    let mdd = ORFactory.mddSpecs(m, variables: vars, numForwardProperties: 3, numReverseProperties: 2, numCombinedProperties: 0)
    mdd.state([(minDown, 0), (maxDown, 0), (numAssignedDown, 0)])
    mdd.bottomUpState([(minUp, 0), (maxUp, 0)])
    mdd.setAsDualDirectionalSum(Int32(numVars), maxDom: maxDom, weights: weightsPointer, lower: lb, upper: ub)
    return mdd
}
public func sumMDD(m : ORTracker,vars : ORIntVarArray, weights : [Int], equal : ORIntVar) -> ORMDDSpecs {
    let udom = arrayDomains(vars)
    let maxDom = udom.up(),
        numVars = Int(vars.count())
    let minDown = 0, maxDown = 1, numAssignedDown = 2,
        minUp = 0, maxUp = 1
    var int32Weights : [Int32] = []
    for weight in weights { int32Weights.append(Int32(weight)) }
    let weightsPointer = UnsafeMutablePointer<Int32>.allocate(capacity: numVars)
    weightsPointer.initialize(from: int32Weights, count: numVars)
        
    let mdd = ORFactory.mddSpecs(m, variables: vars, numForwardProperties: 3, numReverseProperties: 2, numCombinedProperties: 0)
    mdd.state([(minDown, 0), (maxDown, 0), (numAssignedDown, 0)])
    mdd.bottomUpState([(minUp, 0), (maxUp, 0)])
    mdd.setAsDualDirectionalSum(Int32(numVars), maxDom: maxDom, weights: weightsPointer, equal: equal)
    return mdd
}
public func sumMDD(m : ORTracker,vars : ORIntVarArray, weightMatrix : [[Int]], equal : ORIntVar) -> ORMDDSpecs {
    let udom = arrayDomains(vars)
    let maxDom = udom.up(),
        domSize = udom.size(),
        numVars = Int(vars.count())
    let minDown = 0, maxDown = 1, numAssignedDown = 2,
        minUp = 0, maxUp = 1
    let weightMatrixPointer = UnsafeMutablePointer<UnsafeMutablePointer<Int32>?>.allocate(capacity: numVars)
    weightMatrixPointer.initialize(repeating: UnsafeMutablePointer<Int32>.allocate(capacity: Int(domSize)), count: numVars)
    for i in 0..<numVars {
        var int32Weights : [Int32] = []
        for weight in weightMatrix[i] { int32Weights.append(Int32(weight)) }
        let weightsPointer : UnsafeMutablePointer<Int32> = UnsafeMutablePointer<Int32>.allocate(capacity: Int(domSize))
        weightsPointer.initialize(from: int32Weights, count: Int(domSize))
        weightMatrixPointer[i] = weightsPointer
    }
        
    let mdd = ORFactory.mddSpecs(m, variables: vars, numForwardProperties: 3, numReverseProperties: 2, numCombinedProperties: 0)
    mdd.state([(minDown, 0), (maxDown, 0), (numAssignedDown, 0)])
    mdd.bottomUpState([(minUp, 0), (maxUp, 0)])
    mdd.setAsDualDirectionalSum(Int32(numVars), maxDom: maxDom, weightMatrix: weightMatrixPointer, equal: equal)
    return mdd
}

public func seqMDDClosures(_ vars : ORIntVarArray,len : Int,lb : Int,ub : Int,values : Set<Int>) -> ORMDDSpecs {
    let m = vars.tracker(),
        minFIdx = 0,minLIdx = len-1,
        maxFIdx = len,maxLIdx = len*2-1,
        valueSet = ORFactory.intSet(m, set: values)
    let udom = arrayDomains(vars)
    let mdd = ORFactory.mddSpecs(m, variables: vars, stateSize: len*2)
    var sd : [(Int,Int)] = []
    for i in minFIdx...minLIdx {
        sd.append((i,i-minLIdx))
    }
    for i in maxFIdx...maxLIdx {
        sd.append((i,i-maxLIdx))
    }
    mdd.state(sd)
    mdd.setAsSequence(udom, len, lb, ub, valueSet)
    return mdd;
}
public func seqMDDClosuresWithBitSequence(_ vars : ORIntVarArray,len : Int,lb : Int,ub : Int,values : Set<Int>) -> ORMDDSpecs {
    let m = vars.tracker(),
        minCounts = 0,
        maxCounts = 1,
        numAssigned = 2,
        valueSet = ORFactory.intSet(m, set: values)
    let udom = arrayDomains(vars)
    let mdd = ORFactory.mddSpecs(m, variables: vars, stateSize: 3)
    //Each bit sequence is a len*2 shorts
    mdd.state([(minCounts, false, len * 16), (maxCounts, false, len * 16)])
    mdd.state([numAssigned:0])
    mdd.setAsSequenceWithBitSequence(udom, len, lb, ub, valueSet)
    return mdd;
}
public func seqDualDirectionalMDDClosuresWithBitSequence(_ vars : ORIntVarArray,len : Int,lb : Int,ub : Int,values : Set<Int>) -> ORMDDSpecs {
    let m = vars.tracker(),
        minCounts = 0,
        maxCounts = 1,
        numAssigned = 2,
        valueSet = ORFactory.intSet(m, set: values)
    let udom = arrayDomains(vars)
    let mdd = ORFactory.mddSpecs(m, variables: vars, stateSize: 3)
    //Each bit sequence is a len*2 shorts
    mdd.state([(minCounts, false, len * 16), (maxCounts, false, len * 16)])
    mdd.state([numAssigned:0])
    mdd.setAsSequenceWithBitSequence(udom, len, lb, ub, valueSet)
    return mdd;
}
