/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

import ORProgram

func toDict<V>(_ array: Range<Int>, map: (Int) -> (key: Int, value: V)?) -> [Int : V] {
    var dict = [Int : V]()
    for element in array {
        if let (key, value) = map(element) {
            dict[key] = value
        }
    }
    return dict
}

func left(_ t : ORTracker,_ v : Int)   -> ORExpr { return ORFactory.getLeftStateValue(t,lookup:Int32(v)) }
func right(_ t : ORTracker,_ v : Int)  -> ORExpr { return ORFactory.getRightStateValue(t,lookup:Int32(v)) }

autoreleasepool {
    let m  = ORFactory.createModel(),
        minDom = 1,maxDom = 10,sz = maxDom  - minDom + 1,
        R0 = range(m, minDom...maxDom),
        notes = ORFactory.annotation(),
        nbSol = ORFactory.mutable(m, value: 0)
    let t0    = ORRuntimeMonitor.cputime()

    let vars = ORFactory.intVarArray(m, range: R0, domain: R0)
    let mdd1 = ORFactory.mddSpecs(m, variables: vars, stateSize: Int32(maxDom - minDom + 1))
    mdd1.state(toDict(0..<sz) { (i : Int) -> ((key: Int, value: Bool)?) in
        return (key : i,value:true)
    })
    mdd1.arc(SVal(m,SVA(m) - minDom))
    mdd1.transition(toDict(0..<sz) { (i : Int) -> ((key : Int,value : ORExpr)?) in
        return (key : i,SVal(m,i) && !(SVA(m) == i + minDom))
    })
    mdd1.relaxation(toDict(0..<sz) {  (i : Int) -> ((key : Int,value : ORExpr)?) in
        return (key : i,left(m,i) || right(m,i))
    })
    mdd1.similarity(toDict(0..<sz) {  (i : Int) -> ((key : Int,value : ORExpr)?) in
        return (key :i,abs(left(m,i) - right(m,i)))
    })
    m.add(mdd1)

    notes.ddWidth(4)
    notes.ddRelaxed(false)
    let cp = ORFactory.createCPMDDProgram(m, annotation: notes)
    cp.search {
        firstFail(cp, vars)
            »
            Do(cp) {
                let qs = (1...10).map { i in cp.intValue(vars[ORInt(i)]) }
                print("sol is: \(qs)")
                nbSol.incr(cp)
            }
    }
    let t1     = ORRuntimeMonitor.cputime()
    print("Solver status: \(cp)\n")
    print("Quitting: \(t1 - t0)\n")
}
