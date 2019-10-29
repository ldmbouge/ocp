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
//    enum Prop : Int {
//        case minC = 0
//        case maxC = 1
//        case rem  = 2
//        var value : ORInt { return ORInt(self.rawValue) }
//        func left(_ t : ORTracker)   -> ORExpr { return ORFactory.getLeftStateValue(t,lookup:Int32(self.rawValue)) }
//        func right(_ t : ORTracker)  -> ORExpr { return ORFactory.getRightStateValue(t,lookup:Int32(self.rawValue)) }
//    }
//    var minCnt = SVal(m,Prop.minC.value),maxCnt = SVal(m,Prop.maxC.value), rem = SVal(m,Prop.rem.value)
//
//    let mdd1 = ORFactory.mddSpecs(m, variables: vars, stateSize: 3)
//    mdd1.state([ Prop.minC.value : 0,Prop.maxC.value : 0, Prop.rem.value : vars.size ])
//    mdd1.arc(minCnt + SVA(m) ∈ cv1 ≤ 5 && 5 ≤ (maxCnt + SVA(m) ∈ cv1 + rem - 1))
//    mdd1.transition([Prop.minC.value : minCnt + SVA(m) ∈ cv1,
//                     Prop.maxC.value : maxCnt + SVA(m) ∈ cv1,
//                     Prop.rem.value  : rem - 1])
//    mdd1.relaxation([Prop.minC.value : min(Prop.minC.left(m),Prop.minC.right(m)),
//                     Prop.maxC.value : max(Prop.maxC.left(m),Prop.maxC.right(m)),
//                     Prop.rem.value  : rem])
//    mdd1.similarity([Prop.minC.value : abs(Prop.minC.left(m) - Prop.minC.right(m)),
//                     Prop.maxC.value : abs(Prop.maxC.left(m) - Prop.maxC.right(m)),
//                     Prop.rem.value  : literal(m, 0)])
//    m.add(mdd1)
//
//    minCnt = SVal(m,Prop.minC.value)
//    maxCnt = SVal(m,Prop.maxC.value)
//    rem = SVal(m,Prop.rem.value)
//    let mdd2 = ORFactory.mddSpecs(m, variables: vars, stateSize: 3)
//    mdd2.state([ Prop.minC.value : 0,Prop.maxC.value : 0,Prop.rem.value : vars.size ])
//    mdd2.arc(minCnt + SVA(m) ∈ cv2 ≤ 3 && 2 ≤ (maxCnt + SVA(m) ∈ cv2 + rem - 1))
//    mdd2.transition([Prop.minC.value : minCnt + SVA(m) ∈ cv2,
//                     Prop.maxC.value : maxCnt + SVA(m) ∈ cv2,
//                     Prop.rem.value  : rem - 1])
//    mdd2.relaxation([Prop.minC.value : min(Prop.minC.left(m),Prop.minC.right(m)),
//                     Prop.maxC.value : max(Prop.maxC.left(m),Prop.maxC.right(m)),
//                     Prop.rem.value  : rem])
//    mdd2.similarity([Prop.minC.value : abs(Prop.minC.left(m) - Prop.minC.right(m)),
//                     Prop.maxC.value : abs(Prop.maxC.left(m) - Prop.maxC.right(m)),
//                     Prop.rem.value  : literal(m, 0)])
//    m.add(mdd2)

    m.add(amongMDD(m: m, x: vars, lb: 5, ub: 5, values: cv1))
    m.add(amongMDD(m: m, x: vars, lb: 2, ub: 3, values: cv2))
    //m.add(amongMDD(m: m, x: vars, lb: 2, ub: 3, values: cv2))  // [Becca: If you uncomment this one, the whole thing blows up. Should have no effect of course!]
    notes.ddWidth(4)
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
