/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

import ORProgram

typealias SC = (len:Int,lower:Int,upper:Int,cv:Set<Int>)

autoreleasepool {
    let m  = ORFactory.createModel(),
        R0 = range(m, 1...20),
        R1 = range(m,0...20),
        notes = ORFactory.annotation(),
        nbSol = ORFactory.mutable(m, value: 0)
    let t0    = ORRuntimeMonitor.cputime()
    let s : [SC] = [(7,1,5,[0,2,9,11,13]),
                    (7,4,5,[0,1,2,4,5,6,10,11,12,14,16,18,19]),
                    (8,1,6,[0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 15, 16, 17, 18, 19]),
                    (5,1,1,[1]),
                    (9,1,6,[1, 3, 5, 8, 10, 11, 12, 15, 16, 19]),
                    (5,1,2,[2, 4, 5, 6, 8, 12, 18]),
                    (2,0,1,[0, 3, 5, 6, 7, 8, 9, 10, 11, 12, 13, 15, 16, 17, 18])
                   ]
    
    let vars = ORFactory.intVarArray(m, range: R0, domain: R1)

    for sc in s {
        m.add(seqMDD(vars,len: sc.len,lb:sc.lower,ub:sc.upper,values:sc.cv))
    }

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
