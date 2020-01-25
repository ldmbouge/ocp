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
        minDom = 0,maxDom = 74,
        minVar = 0,maxVar = 17,
        R0 = range(m, minDom...maxDom),
        R1 = range(m, minVar...maxVar),
        notes = ORFactory.annotation(),
        nbSol = ORFactory.mutable(m, value: 0)
    let t0    = ORRuntimeMonitor.cputime()

    let vars = ORFactory.intVarArray(m, range: R1, domain: R0)

    m.add(allDiffMDD(vars))
    //m.add(ORFactory.alldifferent(vars))

    notes.ddWidth(4)
    notes.ddRelaxed(true)
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
