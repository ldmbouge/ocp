/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

import ORProgram

autoreleasepool {
    let m  = ORFactory.createModel(),
        minDom = 1,maxDom = 5,
        minVar = 1,maxVar = 10,
        R0 = range(m, minDom...maxDom),
        R1 = range(m, minVar...maxVar),
        notes = ORFactory.annotation(),
        nbSol = ORFactory.mutable(m, value: 0)
    let t0    = ORRuntimeMonitor.cputime()

    let vars = ORFactory.intVarArray(m, range: R1, domain: R0)

    let setOfTwo = ORFactory.intSet(m, set: [2])
    let setOfThree = ORFactory.intSet(m, set: [3])
    let setOfFour = ORFactory.intSet(m, set: [4])
    let setOfFive = ORFactory.intSet(m, set: [5])
    m.add(amongMDDClosures(m: m, x: vars, lb: 2, ub: 2, values: setOfTwo))
    m.add(amongMDDClosures(m: m, x: vars, lb: 2, ub: 2, values: setOfThree))
    m.add(amongMDDClosures(m: m, x: vars, lb: 3, ub: 3, values: setOfFour))
    m.add(amongMDDClosures(m: m, x: vars, lb: 3, ub: 3, values: setOfFive))
    
    notes.ddWidth(8)
    notes.ddRelaxed(true)
    notes.dd(withArcs: true)
    notes.dd(usingSlack: false)
    notes.ddEqualBuckets(true)
    notes.ddVariableOverlap(0)
    notes.ddRecommendationStyle(MinDomain)
    let cp = ORFactory.createCPMDDProgram(m, annotation: notes)
    //let cp = ORFactory.createCPProgram(m)
    cp.search {
        labelArray(cp, vars)
            »
            Do(cp) {
                let qs = (minVar...maxVar).map { i in cp.intValue(vars[ORInt(i)]) }
                print("sol is: \(qs)")
                nbSol.incr(cp)
            }
    }
    let t1     = ORRuntimeMonitor.cputime()
    print("Solver status: \(cp)\n")
    print("Quitting: \(t1 - t0)\n")
}
