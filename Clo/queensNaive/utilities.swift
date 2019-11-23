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
    let mdd1 = ORFactory.mddSpecs(m, variables: x, stateSize: 3)
    mdd1.state([ minC : 0,maxC : 0, rem : x.size ])
    mdd1.arc(minCnt + SVA(m) ∈ values ≤ ub && lb ≤ (maxCnt + SVA(m) ∈ values + remVal - 1))
    mdd1.transition([minC : minCnt + SVA(m) ∈ values,
                     maxC : maxCnt + SVA(m) ∈ values,
                     rem  : remVal - 1])
    mdd1.relaxation([minC : min(left(m,minC),right(m,minC)),
                     maxC : max(left(m,maxC),right(m,maxC)),
                     rem  : remVal])
    mdd1.similarity([minC : abs(left(m,minC) - right(m,minC)),
                     maxC : abs(left(m,maxC) - right(m,maxC)),
                     rem  : literal(m, 0)])
    return mdd1
}

public func allDiffMDD(_ vars : ORIntVarArray) -> ORMDDSpecs {
    let m = vars.tracker(),
        adom = arrayDomains(vars),
        minDom = Int(adom.low()),
        mdd1 = ORFactory.mddSpecs(m, variables: vars, stateSize: Int32(adom.size()))
    
    mdd1.state(toDict(adom) { (i : Int) -> (key: Int, value: Bool) in
        return (key : i,value:true)
    })
    mdd1.arc(Prop(m,SVA(m) - minDom))
    mdd1.transition(toDict(adom) { (i : Int) -> (key : Int,value : ORExpr) in
        return (key : i,Prop(m,i) && SVA(m) != i + minDom)
    })
    mdd1.relaxation(toDict(adom) {  (i : Int) -> (key : Int,value : ORExpr) in
        return (key : i,left(m,i) || right(m,i))
    })
    mdd1.similarity(toDict(adom) {  (i : Int) -> (key : Int,value : ORExpr) in
        return (key :i,abs(left(m,i) - right(m,i)))
    })
    return mdd1
}

public func seqMDD(_ vars : ORIntVarArray,len : Int,lb : Int,ub : Int,values : Set<Int>) -> ORMDDSpecs {
    let m = vars.tracker(),
        minFIdx = 0,minLIdx = len-1,
        maxFIdx = len,maxLIdx = len*2-1,
        theValues = ORFactory.intSet(m, set: values)
    let mdd1 = ORFactory.mddSpecs(m, variables: vars, stateSize: Int32(len*2))
    var sd : [Int:Int] = [:]
    /*for i in minFIdx...maxLIdx-1 {
        if (i != minLIdx) {
            sd[i] = -1
        }
    }*/
    for i in minFIdx...minLIdx {
        sd[i] = (i - minLIdx)
    }
    for i in maxFIdx...maxLIdx {
        sd[i] = (i - maxLIdx)
    }
    mdd1.state(sd)
    mdd1.arc((Prop(m,0) < literal(m,0) &&
                (Prop(m,maxLIdx)-Prop(m,minFIdx) + SVA(m) ∈ theValues ≥ lb) &&
                (Prop(m,minLIdx) + SVA(m) ∈ theValues ≤ ub)) ||
             (Prop(m,maxLIdx)-Prop(m,minFIdx) + SVA(m) ∈ theValues ≥ lb &&
              Prop(m,minLIdx)-Prop(m,maxFIdx) + SVA(m) ∈ theValues ≤ ub)
    )
    // transitions
    mdd1.transition(toDict(minFIdx,minLIdx) { (i:Int) -> (key:Int,value:ORExpr) in return (key:i,Prop(m,i+1)) })
    mdd1.transition(toDict(maxFIdx,maxLIdx) { (i:Int) -> (key:Int,value:ORExpr) in return (key:i,Prop(m,i+1)) })
    mdd1.addTransitionFunction(Prop(m,minLIdx) + SVA(m) ∈ theValues, toStateValue: Int32(minLIdx))
    mdd1.addTransitionFunction(Prop(m,maxLIdx) + SVA(m) ∈ theValues, toStateValue: Int32(maxLIdx))
    // relaxation
    mdd1.relaxation(toDict(minFIdx,minLIdx+1) { (i:Int) -> (key:Int,value:ORExpr) in return (key:i,min(left(m,i),right(m,i))) })
    mdd1.relaxation(toDict(maxFIdx,maxLIdx+1) { (i:Int) -> (key:Int,value:ORExpr) in return (key:i,max(left(m,i),right(m,i))) })
    // similarity
    mdd1.similarity(toDict(minFIdx,maxLIdx+1) { (i : Int) -> (key:Int,value:ORExpr) in return (key:i,value:abs(left(m,i)-right(m,i))) })
    return mdd1;
}

public func gccMDD(_ vars : ORIntVarArray, ub : [Int:Int]) -> ORMDDSpecs  {
    let m = vars.tracker(),
        adom = arrayDomains(vars),
        domsize = Int(adom.size()),
        minFDom = 0,minLDom = Int(domsize-1),
        maxFDom = Int(domsize),maxLDom = Int(domsize*2-1),
        minDom = Int(adom.low()),
        mdd1 = ORFactory.mddSpecs(m, variables: vars, stateSize: Int32(domsize*2))
    
    var sd : [Int:Int] = [:]
    for i in minFDom...maxLDom {
        sd[i] = 0
    }
    mdd1.state(sd)
    
    mdd1.arc(Prop(m,SVA(m) - minDom) < ub[m,SVA(m)])
    
    let SVAInDom = SVA(m) - minDom
    
    mdd1.transition(toDict(minFDom,minLDom+1) { (i:Int) -> (key:Int,value:ORExpr)
                in return (key:i,Prop(m,i) + (SVAInDom == i)) })
    mdd1.transition(toDict(maxFDom,maxLDom+1) { (i:Int) -> (key:Int,value:ORExpr)
                in return (key:i,Prop(m,i) + (SVAInDom == (i-domsize))) })
    
    mdd1.relaxation(toDict(minFDom,minLDom+1) { (i:Int) -> (key:Int,value:ORExpr) in return (key:i,min(left(m,i),right(m,i))) })
    mdd1.relaxation(toDict(maxFDom,maxLDom+1) { (i:Int) -> (key:Int,value:ORExpr) in return (key:i,max(left(m,i),right(m,i))) })
    
    mdd1.similarity(toDict(minFDom,minLDom+1) { (i : Int) -> (key:Int,value:ORExpr) in return (key:i,value:min(left(m,i),right(m,i))) })
    
    return mdd1;
}
