//
//  main.swift
//  crossRE
//
//  Created by Laurent Michel on 12/13/15.
//
//

import ORProgram

func show(cp : CPProgram,_ x : ORIntVarMatrix)
{
   let r0 = x.range(0)
   let r1 = x.range(1)
   for i in r0.low()...r0.up() {
      for j in r1.low()...r1.up() {
         print("\(cp.intValue(x.at(i, j))) ",terminator:"")
      }
      print("")
   }
}

/*!
 * @brief Creates a DFA based on a sequence of numbers acquired from the scanner.
 * The first number is the length of the sequence (number of numbers). 
 * subsequent numbers are the length of black section (separated by at least one white)
 * The code create a transition table of triplets giving (StartState, Symbol, EndState)
 * On the edge, you do not have to start of finish with a blank.
 */
func readRE(scan : NSScanner,alphabet al : ORIntRange,forModel m: ORModel) -> ORAutomaton {
   var n : Int = 0
   var lState : ORInt = 1
   var f : [ORTransition] = []
   f.append((1, 0, 1))
   scan.scanInteger(&n)
   for i in 0..<n {
      var k : Int = 0
      scan.scanInteger(&k)
      for _ in 0..<k {
         f.append((lState,1,lState+1))
         lState = lState + 1
      }
      if i < n-1 {
         f.append((lState,0,lState+1))    // go to new state
         f.append((lState+1,0,lState+1))  // stay put on 0
         lState = lState + 1
      } else {
         f.append((lState,0,lState))      // stay put on 0
      }
   }
   let S = range(m,r: 1...Int(lState))
   let F = ORFactory.intSet(m)
   F.insert(lState)
   let a  = ORFactory.automaton(m, alphabet: al, states: S, transition: UnsafeMutablePointer<ORTransition>(f) ,
      size: ORInt(f.count), initial: 1, final: F)
   return a
}

autoreleasepool {
   do {
      let t0 =  ORRuntimeMonitor.cputime()
      let buf = try String(contentsOfFile: "crypto.txt", encoding: NSASCIIStringEncoding)
      let scan = NSScanner(string: buf)
      var n : Int = 0,f : Int = 0
      scan.scanInteger(&n)
      scan.scanInteger(&f)
      let model = ORFactory.createModel()
      let R     = range(model, r: 1...n)
      let B     = range(model, r: 0...1)
      let x     = ORFactory.boolVarMatrix(model, range: R, R)
      print("board: \(n) x \(n)\t fixed=\(f)\n")
      for i in 0..<f {
         var r : ORInt = 0,c : ORInt = 0
         scan.scanInt(&r)
         scan.scanInt(&c)
         model.add(x.at(r,c) == 1)
      }
      for r in 1...ORInt(n) {
         let row = all(model, r: R) { c in x.at(r,c) }
         let dfa = readRE(scan, alphabet: B, forModel: model)
         model.add(ORFactory.regular(row, belongs: dfa))
      }
      for c in 1...ORInt(n) {
         let col = all(model, r: R) { r in x.at(r,c) }
         let dfa = readRE(scan, alphabet: B, forModel: model)
         model.add(ORFactory.regular(col, belongs: dfa))
      }
      
      let cp = ORFactory.createCPProgram(model)
      cp.search {
         firstFail(cp, model.intVars()) » Do(cp) {
            show(cp,x)
         }
      }
      print("Solver status: \(cp)\n")
      let t1 =  ORRuntimeMonitor.cputime()
      print("Quitting after: \(t1-t0)ms\n")
   } catch {}
}