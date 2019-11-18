/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

import ORProgram

func toDict<V>(_ r: ORIntRange, map: (Int) -> (key: Int, value: V)) -> [Int : V] {
    var dict = [Int : V]()
    for element in 0 ..< r.size() {
        let (key, value) = map(Int(element))
        dict[key] = value
    }
    return dict
}

autoreleasepool {
    let m  = ORFactory.createModel(),
        minDom = 1,maxDom = 10,
        R0 = range(m, minDom...maxDom),
        notes = ORFactory.annotation(),
        nbSol = ORFactory.mutable(m, value: 0)
    let t0    = ORRuntimeMonitor.cputime()

    let vars = ORFactory.intVarArray(m, range: R0, domain: R0)

    m.add(allDiffMDD(vars))

    notes.ddWidth(4)
    notes.ddRelaxed(false)
    let cp = ORFactory.createCPMDDProgram(m, annotation: notes)
    cp.search {
        labelArray(cp, vars)
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
