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
        R0 = range(m, 1...20),
        R1 = range(m,1...5),
        notes = ORFactory.annotation(),
        nbSol = ORFactory.mutable(m, value: 0)
    let t0    = ORRuntimeMonitor.cputime()
    let ub : [Int:Int] = [1:2, 2:5, 3:10, 4:2, 5:1]
    
    let vars = ORFactory.intVarArray(m, range: R0, domain: R1)

    m.add(gccMDD(vars, ub: ub))

    notes.ddWidth(10)
    notes.ddRelaxed(true)
    let cp = ORFactory.createCPMDDProgram(m, annotation: notes)
    cp.search {
        labelArray(cp, vars)
            »
            Do(cp) {
                let qs = (vars.range().low()...vars.range().up()).map { i in cp.intValue(vars[ORInt(i)]) }
                print("sol is: \(qs)")
                nbSol.incr(cp)
            }
    }
    let t1     = ORRuntimeMonitor.cputime()
    print("Solver status: \(cp)\n")
    print("Quitting: \(t1 - t0)\n")
}
