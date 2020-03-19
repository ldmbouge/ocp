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
  let m = ORFactory.createModel(),
  R0 = range(m, 1...200),
  R1 = range(m,1...9),
    notes = ORFactory.annotation()
  let vars = ORFactory.intVarArray(m, range: R0, domain: R1)
  let cv1 = ORFactory.intSet(m, set: [2]),
    cv2 = ORFactory.intSet(m, set: [3]),
    cv3 = ORFactory.intSet(m, set: [4]),
    cv4 = ORFactory.intSet(m, set: [5])
    
    /*let relaxationSize = Int32(CommandLine.arguments[1])
    let usingArcs = Bool(CommandLine.arguments[2])
    let usingClosures = Bool(CommandLine.arguments[3])
    let usingFirstFail = Bool(CommandLine.arguments[4])
    let equalBuckets = Bool(CommandLine.arguments[5])
    let usingSlack = Bool(CommandLine.arguments[6])
    let recommendationStyle = UInt32(CommandLine.arguments[7])
    notes.ddWidth(relaxationSize!)
    notes.ddRelaxed(relaxationSize! != 0)
    notes.dd(withArcs: usingArcs!)
    notes.ddEqualBuckets(equalBuckets!)
    notes.dd(usingSlack: usingSlack!)
    notes.ddRecommendationStyle((MDDRecommendationStyle)(recommendationStyle!))
  
    if (!usingClosures!) {
  m.add(amongMDD(m: m, x: vars, lb: 2, ub: 5, values: cv1))
  m.add(amongMDD(m: m, x: vars, lb: 2, ub: 5, values: cv2))
  m.add(amongMDD(m: m, x: vars, lb: 3, ub: 5, values: cv3))
  m.add(amongMDD(m: m, x: vars, lb: 3, ub: 5, values: cv4))
    } else {*/
  
  
  m.add(amongMDDClosures(m: m, x: vars, lb: 2, ub: 5, values: cv1))
  m.add(amongMDDClosures(m: m, x: vars, lb: 2, ub: 5, values: cv2))
  m.add(amongMDDClosures(m: m, x: vars, lb: 3, ub: 5, values: cv3))
  m.add(amongMDDClosures(m: m, x: vars, lb: 3, ub: 5, values: cv4))
   // }
  
    
  notes.ddRelaxed(true)
    notes.ddWidth(4)
  notes.dd(withArcs:true)
    notes.ddEqualBuckets(true)
    notes.dd(usingSlack: false)
    notes.ddRecommendationStyle(MinDomain)
    notes.ddVariableOverlap(0)
  let cp = ORFactory.createCPMDDProgram(m, annotation: notes)
  var end:ORLong = 0
  var afterPropagation:ORLong = 0
  //  if (usingFirstFail!) {
  cp.search {
    Do(cp) {
      end = ORRuntimeMonitor.cputime()
    }
    »
    firstFailMDD(cp, vars)
      »
      Do(cp) {
        afterPropagation = ORRuntimeMonitor.cputime()
        let qs = (1..<R0.up()+1).map { i in cp.intValue(vars[ORInt(i)]) }
        print("sol is: \(qs)")
        print("CP: \(cp)")
      } 
  }
  /*  } else {
        cp.search {
          Do(cp) {
            end = ORRuntimeMonitor.cputime()
          }
          »
          labelArrayMDD(cp, vars)
            »
            Do(cp) {
              afterPropagation = ORRuntimeMonitor.cputime()
              let qs = (1..<R0.up()+1).map { i in cp.intValue(vars[ORInt(i)]) }
              print("sol is: \(qs)")
              print("CP: \(cp)")
            }
        }
    }*/
  print("Solver status: \(end - start)\n")
  print("Post duration: \(end - start)")
  print("Propagation duration: \(afterPropagation - end)")
  print("Quitting: \(afterPropagation - start)\n")
}
