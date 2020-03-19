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
    m.add(ORFactory.among(vars, values: cv1, low: 5, up: 5))
    m.add(ORFactory.among(vars, values: cv2, low: 2, up: 3))

    let cp = ORFactory.createCPProgram(m, annotation: notes)
    cp.search {
        labelArray(cp, vars)
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
