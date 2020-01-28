/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

import ORProgram
autoreleasepool {
   let start = ORRuntimeMonitor.cputime()
    let m  = ORFactory.createModel(),
    R0 = range(m, 1...200),
    R1 = range(m,1...9),
        notes = ORFactory.annotation()
    let vars = ORFactory.intVarArray(m, range: R0, domain: R1)
    let cv1 = ORFactory.intSet(m, set: [2]),
        cv2 = ORFactory.intSet(m, set: [3]),
        cv3 = ORFactory.intSet(m, set: [4]),
        cv4 = ORFactory.intSet(m, set: [5])
    m.add(amongMDD(m: m, x: vars, lb: 2, ub: 5, values: cv1))
    m.add(amongMDD(m: m, x: vars, lb: 2, ub: 5, values: cv2))
    m.add(amongMDD(m: m, x: vars, lb: 3, ub: 5, values: cv3))
    m.add(amongMDD(m: m, x: vars, lb: 3, ub: 5, values: cv4))

//    let vars = ORFactory.intVarArray(m, range: range(m,1...20), domain: range(m,1...20))
//    m.add(allDiffMDD(vars))
    notes.ddWidth(128)
    notes.ddRelaxed(true)
    let cp = ORFactory.createCPMDDProgram(m, annotation: notes)
   var end:ORLong = 0
    cp.search {
        Do(cp) {
           end = ORRuntimeMonitor.cputime()
        }
        »
        firstFail(cp, vars)
            »
            Do(cp) {
                let qs = (1..<R0.up()).map { i in cp.intValue(vars[ORInt(i)]) }
                print("sol is: \(qs)")
                print("CP: \(cp)")
            }
    }
    print("Solver status: \(end - start)\n")
}

