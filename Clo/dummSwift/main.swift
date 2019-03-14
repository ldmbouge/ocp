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
        R0 = range(m, 1...50),
        R1 = range(m,1...5),
        notes = ORFactory.annotation(),
        nbSol = ORFactory.mutable(m, value: 0)
    let t0    = ORRuntimeMonitor.cputime()

    let vars = ORFactory.intVarArray(m, range: R0, domain: R1)
    let cv1 = ORFactory.intSet(m, set: [2,4]),
        cv2 = ORFactory.intSet(m, set: [5])
    
    let mdd1 = ORFactory.mddSpecs(m, variables: vars)
    mdd1.state([ "count" : 0,"rem" : vars.size ])
    let cnt = SVal(m,"count"),rem = SVal(m,"rem")
    mdd1.arc(cnt + SVA(m) ∈ cv1 ≤ 10 && (cnt + SVA(m) ∈ cv1 + rem - 1) ≥ 5)
    mdd1.transition(["count" : cnt + SVA(m) ∈ cv1,
                     "rem"   : rem - 1])
    m.add(mdd1)

    let mdd2 = ORFactory.mddSpecs(m, variables: vars)
    mdd2.state([ "count" : 0,"rem" : vars.size ])
    //let cnt = SVal(m,"count"),rem = SVal(m,"rem")  // no need to repeat them. Those are the same
    mdd2.arc(cnt + SVA(m) ∈ cv2 ≤ 3 && (cnt + SVA(m) ∈ cv2 + rem - 1) ≥ 2)
    mdd2.transition(["count" : cnt + SVA(m) ∈ cv2,
                     "rem"   : rem - 1])
    m.add(mdd2)

    notes.ddWidth(8)
    notes.ddRelaxed(false)
    let cp = ORFactory.createCPMDDProgram(m, annotation: notes)
    cp.search {
        firstFail(cp, vars)
            »
            Do(cp) {
                let qs = (1...50).map { i in cp.intValue(vars[ORInt(i)]) }
                print("sol is: \(qs)")
                nbSol.incr(cp)
            }
    }
    let t1     = ORRuntimeMonitor.cputime()
    print("Solver status: \(cp)\n")
    print("Quitting: \(t1 - t0)\n")
}
