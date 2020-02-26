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
  R0 = range(m, 1...12),
  R1 = range(m,1...9),
    notes = ORFactory.annotation()
  let vars = ORFactory.intVarArray(m, range: R0, domain: R1)
  let cv1 = ORFactory.intSet(m, set: [2]),
    cv2 = ORFactory.intSet(m, set: [3]),
    cv3 = ORFactory.intSet(m, set: [4]),
    cv4 = ORFactory.intSet(m, set: [5]),
   low = ORFactory.intArray(m, array: [0,0,2,2,3,3,0,0,0,0]),
   up = ORFactory.intArray(m,array:[0,200,5,5,5,5,200,200,200,200])
  
  m.add(ORFactory.among(vars, values:cv1 , low: 2, up: 5))
  m.add(ORFactory.among(vars, values: cv2, low: 2, up: 5))
  m.add(ORFactory.among(vars, values: cv3, low: 3, up: 5))
  m.add(ORFactory.among(vars, values: cv4, low: 3, up: 5))
  
  //m.add(ORFactory.cardinality(vars, low: low, up: up))
   
/*
  m.add(amongMDDClosures(m: m, x: vars, lb: 2, ub: 5, values: cv1))
  m.add(amongMDDClosures(m: m, x: vars, lb: 2, ub: 5, values: cv2))
  m.add(amongMDDClosures(m: m, x: vars, lb: 3, ub: 5, values: cv3))
  m.add(amongMDDClosures(m: m, x: vars, lb: 3, ub: 5, values: cv4))
  */
    
  //let relaxationSize = Int32(CommandLine.arguments[1])
  //notes.ddWidth(relaxationSize!)
  //notes.ddRelaxed(relaxationSize! != 0)
  notes.ddRelaxed(false)
  let cp = ORFactory.createCPMDDProgram(m, annotation: notes)
  var end:ORLong = 0
  var afterPropagation:ORLong = 0
  cp.search {
    Do(cp) {
      end = ORRuntimeMonitor.cputime()
      cp.add(vars[1] == 1)
      cp.add(vars[2] == 1)
      let cv = (1..<R0.up()+1).map { i in cp.concretize(vars[ORInt(i)])!}
      print("CC: \(cv)")
    }
    »
    labelArray(cp, vars)
      »
      Do(cp) {
        afterPropagation = ORRuntimeMonitor.cputime()
        let qs = (1..<R0.up()+1).map { i in cp.intValue(vars[ORInt(i)]) }
        print("sol is: \(qs)")
        print("CP: \(cp)")
      } 
  }
  print("Solver status: \(end - start)\n")
  print("Post duration: \(end - start)")
  print("Propagation duration: \(afterPropagation - end)")
  print("Quitting: \(afterPropagation - start)\n")
}

