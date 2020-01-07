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
    func state<Key,Value>(_ d : Dictionary<Key,Value>) -> Void where Key : BinaryInteger,Value : BinaryInteger {
        for (k,v) in d {
            self.addStateInt(ORInt(k), withDefaultValue: ORInt(v))
        }
    }
    func state<Key>(_ d : Dictionary<Key,Bool>) -> Void where Key : BinaryInteger {
        for (k,v) in d {
            self.addStateBool(ORInt(k), withDefaultValue: v)
        }
    }
    func state<Key>(_ d : Dictionary<Key,Set<AnyHashable>?>) -> Void where Key : BinaryInteger {
        for (k,v) in d {
            self.addStateSet(ORInt(k), withDefaultValue: v)
        }
    }
    func state2<Key,Value>(_ d : Dictionary<Key,Value>) -> [Key] where Key : BinaryInteger {
        for (k,v) in d {
            self.addStateInt(k as! Int32, withDefaultValue: (ORInt)( v as! Int))
        }
        return Array(d.keys)
    }
    func arc(_ f : ORExpr) -> Void {
        self.setArcExistsFunction(f)
    }
    func transition<K,V>(_ d : Dictionary<K,V>) -> Void where K : BinaryInteger {
        for (k,v) in d {
            self.addTransitionFunction(v as? ORExpr, toStateValue: Int32(k))
        }
    }
    func relaxation<K,V>(_ d : Dictionary<K,V>) -> Void where K : BinaryInteger {
        for (k,v) in d {
            self.addRelaxationFunction(v as? ORExpr, toStateValue: Int32(k))
        }
    }
    func similarity<K,V>(_ d : Dictionary<K,V>) -> Void where K : BinaryInteger {
        for (k,v) in d {
            self.addStateDifferentialFunction(v as? ORExpr, toStateValue: Int32(k))
        }
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


// -----------------------------------------------------------------------------------------------------------------
// MDD constraints
// -----------------------------------------------------------------------------------------------------------------

public func amongMDD(m : ORTracker,x : ORIntVarArray,lb : Int, ub : Int,values : ORIntSet) -> ORMDDSpecs {
    let minC = 0,maxC = 1,rem = 2
    let minCnt = Prop(m,minC),maxCnt = Prop(m,maxC), remVal = Prop(m,rem)
    let mdd = ORFactory.mddSpecs(m, variables: x, stateSize: 3)
    mdd.state([ minC : 0,maxC : 0, rem : x.size ])
    mdd.arc(minCnt + SVA(m) ∈ values ≤ ub && lb ≤ (maxCnt + SVA(m) ∈ values + remVal - 1))
    mdd.transition([minC : minCnt + SVA(m) ∈ values,
                     maxC : maxCnt + SVA(m) ∈ values,
                     rem  : remVal - 1])
    mdd.relaxation([minC : min(left(m,minC),right(m,minC)),
                     maxC : max(left(m,maxC),right(m,maxC)),
                     rem  : remVal])
    mdd.similarity([minC : abs(left(m,minC) - right(m,minC)),
                     maxC : abs(left(m,maxC) - right(m,maxC)),
                     rem  : literal(m, 0)])
    return mdd
}

public func allDiffMDD(_ vars : ORIntVarArray) -> ORMDDSpecs {
    let m = vars.tracker(),
        udom = arrayDomains(vars),
        minDom = Int(udom.low()),
        mdd = ORFactory.mddSpecs(m, variables: vars, stateSize: Int32(udom.size()))
    
    mdd.state(toDict(udom) { i in (key : i,value:true) })
    mdd.arc(Prop(m,SVA(m) - minDom))
    mdd.transition(toDict(udom) { i in (key : i,Prop(m,i) && SVA(m) != i + minDom) })
    mdd.relaxation(toDict(udom) { i in (key : i,left(m,i) || right(m,i)) })
    mdd.similarity(toDict(udom) { i in (key :i,abs(left(m,i) - right(m,i))) })
    return mdd
}
/*public func allDiffMDDWithSets(_ vars : ORIntVarArray) -> ORMDDSpecs {
    let m = vars.tracker(),
        all = 0, some = 1, numAssigned = 2,
        udom = arrayDomains(vars),
        minDom = Int(udom.low()),
        mdd = ORFactory.mddSpecs(m, variables: vars, stateSize: Int32(udom.size()))
    
    mdd.state([all : Set<Int>(), some : Set<Int>(), ])
    mdd.arc((SVA(m) ∉ Prop(m,all)) && (count(Prop(m,sum) > numAssigned) || (SVA(m) ∉ Prop(m,sum))))
    mdd.transition([all : Prop(m,all) ∪ SVA(m),
                    some : Prop(m,some) ∪ SVA(m),
                    numAssigned : Prop(m,numAssigned) + 1])
    mdd.relaxation([all : left(m,all) ∩ right(m,all),
                   some : left(m,some) ∪ right(m,some),
            numAssigned : left(m,numAssigned)])
    mdd.similarity([all : count(left(m,all) - right(m,all)) + count(right(m,all) - left(m,all)),
                   some : count(left(m,some) - right(m,some)) + count(right(m,some) - left(m,some))])
    return mdd
}*/

public func knapsackMDD(_ vars : ORIntVarArray,weights : ORIntArray,capacity : ORInt) -> ORMDDSpecs {
    let m = vars.tracker()
    let minRemainingCapacityIndex = 0, maxRemainingCapacityIndex = 1, remainingWeightsIndex = 2
    let minRemainingCapacity = Prop(m,minRemainingCapacityIndex), maxRemainingCapacity = Prop(m,maxRemainingCapacityIndex), remainingWeights = Prop(m,remainingWeightsIndex)
    let variableWeight = weights.elt(VariableIndex(m))
    let addedWeight = SVA(m) * variableWeight,
        mdd = ORFactory.mddSpecs(m, variables: vars, stateSize: 3)
    
    let sumOfWeights : ORInt = weights.sum({(value : ORInt, idx : Int32)->ORInt in return value; })
    
    mdd.state([minRemainingCapacityIndex : capacity, maxRemainingCapacityIndex : capacity, remainingWeightsIndex : sumOfWeights])
    mdd.arc((maxRemainingCapacity - addedWeight ≥ 0) &&
            (minRemainingCapacity ≤ (remainingWeights + ((SVA(m) - 1) * variableWeight))))
    mdd.transition([minRemainingCapacityIndex : minRemainingCapacity - addedWeight,
                    maxRemainingCapacityIndex : maxRemainingCapacity - addedWeight,
                    remainingWeightsIndex : remainingWeights - variableWeight])
    mdd.relaxation([minRemainingCapacityIndex : min(left(m,minRemainingCapacityIndex),right(m,minRemainingCapacityIndex)),
                    maxRemainingCapacityIndex : max(left(m,maxRemainingCapacityIndex),right(m,maxRemainingCapacityIndex)),
                    remainingWeightsIndex : remainingWeights])
    mdd.similarity([minRemainingCapacityIndex : abs(left(m,minRemainingCapacityIndex) - right(m,minRemainingCapacityIndex)),
                    maxRemainingCapacityIndex : abs(left(m,maxRemainingCapacityIndex) - right(m,maxRemainingCapacityIndex))])
    return mdd
}

public func seqMDD(_ vars : ORIntVarArray,len : Int,lb : Int,ub : Int,values : Set<Int>) -> ORMDDSpecs {
    let m = vars.tracker(),
        minFIdx = 0,minLIdx = len-1,
        maxFIdx = len,maxLIdx = len*2-1,
        theValues = ORFactory.intSet(m, set: values)
    let mdd = ORFactory.mddSpecs(m, variables: vars, stateSize: Int32(len*2))
    var sd : [Int:Int] = [:]
    for i in minFIdx...minLIdx {
        sd[i] = (i - minLIdx)
    }
    for i in maxFIdx...maxLIdx {
        sd[i] = (i - maxLIdx)
    }
    mdd.state(sd)
    mdd.arc((Prop(m,0) < literal(m,0) &&
                (Prop(m,maxLIdx)-Prop(m,minFIdx) + SVA(m) ∈ theValues ≥ lb) &&
                (Prop(m,minLIdx) + SVA(m) ∈ theValues ≤ ub)) ||
             (Prop(m,maxLIdx)-Prop(m,minFIdx) + SVA(m) ∈ theValues ≥ lb &&
              Prop(m,minLIdx)-Prop(m,maxFIdx) + SVA(m) ∈ theValues ≤ ub)
    )
    // transitions
    mdd.transition(toDict(minFIdx,minLIdx) { i in return (key:i,Prop(m,i+1)) })
    mdd.transition(toDict(maxFIdx,maxLIdx) { i in return (key:i,Prop(m,i+1)) })
    mdd.addTransitionFunction(Prop(m,minLIdx) + SVA(m) ∈ theValues, toStateValue: Int32(minLIdx))
    mdd.addTransitionFunction(Prop(m,maxLIdx) + SVA(m) ∈ theValues, toStateValue: Int32(maxLIdx))
    // relaxation
    mdd.relaxation(toDict(minFIdx,minLIdx+1) { i in return (key:i,min(left(m,i),right(m,i))) })
    mdd.relaxation(toDict(maxFIdx,maxLIdx+1) { i in return (key:i,max(left(m,i),right(m,i))) })
    // similarity
    mdd.similarity(toDict(minFIdx,maxLIdx+1) { i in return (key:i,value:abs(left(m,i)-right(m,i))) })
    return mdd;
}

public func gccMDD(_ vars : ORIntVarArray, ub : [Int:Int]) -> ORMDDSpecs  {
    let m = vars.tracker(),
        udom = arrayDomains(vars),
        domsize = Int(udom.size()),
        minFDom = 0,minLDom = Int(domsize-1),
        maxFDom = Int(domsize),maxLDom = Int(domsize*2-1),
        minDom = Int(udom.low()),
        mdd = ORFactory.mddSpecs(m, variables: vars, stateSize: Int32(domsize*2))
    
    var sd : [Int:Int] = [:]
    for i in minFDom...maxLDom {
        sd[i] = 0
    }
    mdd.state(sd)
    
    mdd.arc(Prop(m,SVA(m) - minDom) < ub[m,SVA(m)])
    let SVAInDom = SVA(m) - minDom
    mdd.transition(toDict(minFDom,minLDom+1) { i in (key:i,Prop(m,i) + (SVAInDom == i)) })
    mdd.transition(toDict(maxFDom,maxLDom+1) { i in (key:i,Prop(m,i) + (SVAInDom == (i-domsize))) })
    mdd.relaxation(toDict(minFDom,minLDom+1) { i in (key:i,min(left(m,i),right(m,i))) })
    mdd.relaxation(toDict(maxFDom,maxLDom+1) { i in (key:i,max(left(m,i),right(m,i))) })
    mdd.similarity(toDict(minFDom,minLDom+1) { i in (key:i,value:min(left(m,i),right(m,i))) })    
    return mdd;
}
