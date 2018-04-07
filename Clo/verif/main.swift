/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

import ORProgram

// Datatype  to represent a single term (a_i * x_i) in a linear equation
struct Term {
   var vid : Int
   var coef : Double
}

enum Direction { case LEQ; case GEQ; case EQ ; case NEQ;}
func flip(_ d : Direction) -> Direction {
   switch(d) {
   case .LEQ: return .GEQ
   case .GEQ: return .LEQ
   case .EQ:  return .NEQ
   case .NEQ: return .EQ
   }
}
// Datatype to represent an equation sum(i in S) a_i * x_i ≤ rhs
struct Equation {
   var terms : [Term]
   var rhs  : Double
   var dir : Direction
   func state(_ m : ORModel,_ x : ORRealVarArray,negate negated : Bool = false) -> ORExpr {
      let lhs = sum(m, R: range(m,0...terms.count-1)) { t in
         x[self.terms[Int(t)].vid] * self.terms[Int(t)].coef
      }
      switch(negated ? flip(dir) : dir) {
      case .LEQ: return lhs ≤ rhs
      case .GEQ: return lhs ≥ rhs
      case .EQ: return lhs == rhs
      case .NEQ: return lhs ≠ rhs
      }
   }
}

// Datatype to represent one problem (A x ≤ b).
// solve method is to establish whether the isolated problem is feasible or not.
// addToModel is meant to add the set of equations for this one into a master problem (containing a conjunction
// of several subs.
class Problem {
   var allEqs : [Equation] = []
   init(_ ae : [Equation]) {
      allEqs = ae
   }
   func getVars() -> Set<Int> {
      var av : Set<Int> = []
      for eq in allEqs {
         for t  in eq.terms {
            av.insert(t.vid)
         }
      }
      return av
   }
   func solve() -> Bool {
      let m  = ORFactory.createModel()
      let av = getVars().sorted()
      //let Dom   = range(m,0...1)
      let dvars = ORFactory.realVarArray(m, range: range(m,av[0]...av[av.count-1]), low:-1000.0,up:1000.0)
      for eq in allEqs {
         m.add(eq.state(m,dvars))
      }
      let solver = ORFactory.createMIPProgram(m)
      solver.setIntParameter("OutputFlag", val: 0)
      let oc = solver.solve()
      //print("Model is \(oc)",terminator:"\n")
      return oc == ORinfeasible ? false : true
   }
   func addToModel(_ m : ORModel, _ dvars : ORRealVarArray) {
      for eq in allEqs {
         m.add(eq.state(m,dvars))
      }
   }
}

class Trajectory {
   var allProbs : [Problem] = []
   init(_ ap : [Problem]) {
      allProbs = ap
   }
   // Solve all the subproblems and get their statuses (feasible or not) in an array.
   func solveIsolated() -> [Bool] {
      return allProbs.map { (p) -> Bool in
         return p.solve()
      }
   }
   // Enumerate a power set (recursive code)
   func genSubset(_ src : [Int],_ from : Int,_ acc : inout Set<Int>,_ body : (_ sel : Set<Int>,_ ns : Set<Int>) -> Void) {
      if (from >= src.endIndex) {
         let negAcc = src.reduce([]) { (c, v) -> Set<Int> in
            return acc.contains(v) ? c : c.union([v])
         }
         body(acc,negAcc)
      } else {
         acc.insert(src[from])
         genSubset(src,from+1,&acc,body)
         acc.remove(src[from])
         genSubset(src,from+1,&acc,body)
      }
   }
   // Enumerate the power-set of src (top-level code). For each subset, call the 'body' closure
   func genSubset(_ src : [Int],_ body : (_ sel : Set<Int>,_ ns : Set<Int>) -> Void) {
      var sel : Set<Int> = []
      genSubset(src,src.startIndex,&sel,body)
   }
   // Extract the subset of problems that are _individually_ feasible.
   // Then enumerate the power set and for each subset we get, construct the problem which is the
   // conjunction of the selected sub-problems. Create a solver and resolve. If feasible, print-out.
   // TODO: When feasible, make sure that the sub-problems in the complement of 'sub' are indeed infeasible
   //       if one of them is not, create a cut to remove that solution and iterate. Repeat on all subs that
   //       are meant to be infeasible.
   func solveFeasibleTogether() {
      let pStatus = solveIsolated()
      let selection = pStatus.indices.filter { (j) -> Bool in pStatus[j]}

      genSubset(selection) { (_ sub : Set<Int>,_ ns : Set<Int>) in
         if (sub.count == 0) {
            return
         }
         let varIds = sub.reduce([]) { (acc : Set<Int>, p : Int) -> Set<Int> in
            return acc.union(allProbs[p].getVars())
         }.sorted()
         let m = ORFactory.createModel()
         let dvars = ORFactory.realVarArray(m, range: range(m,varIds[0]...varIds[varIds.count-1]), low:-1000.0,up:1000.0)
         for p in sub {
            allProbs[p].addToModel(m,dvars)
         }
         let solver = ORFactory.createMIPProgram(m)
         solver.setIntParameter("OutputFlag", val: 0)
         let oc = solver.solve()
         if (oc == ORoptimal) {
            print("Composite for \(sub) is \(oc)",terminator:"\n");
            for p in ns {
               let mc = m.copy()
               allProbs[p].addToModel(mc, dvars)
               let solver = ORFactory.createMIPProgram(mc)
               solver.setIntParameter("OutputFlag", val: 0)
               if solver.solve() == ORoptimal {
                  // the excluded problem can be satisfied too. Is there a point in the polytope
                  // of m that makes allProbs[p] infeasible ?
                  // Iterate over the hyperplanes of allProbs[p] and add their negation to m
                  // If that is feasible, such a point exist and we should keep that polytope
                  // If that is infeasible, then we can safely skip this half-space and move to the
                  // next one.
                  for e in allProbs[p].allEqs {
                     let mc = m.copy()
                     let ne = e.state(mc,dvars,negate : true)
                     mc.add(ne)
                     let solver = ORFactory.createMIPProgram(mc)
                     solver.setIntParameter("OutputFlag", val: 0)
                     if solver.solve() == ORoptimal {
                        print("Composite for \(sub) can exclude \(p) with \(ne)\n")
                     }
                  }
               }
            }
         }
      }
   }
}

// Input reading.
func readProblem(_ scan : Scanner) -> Problem {
   var nbc = 0
   scan.scanInt(&nbc)
   var allEqs : [Equation] = []
   for _ in 0..<nbc {
      var nbt = 0,rhs=0.0
      scan.scanInt(&nbt)
      var allTerms : [Term] = []
      for _ in 0..<nbt {
         var varId = -1,varCoef = 0.0
         scan.scanInt(&varId)
         scan.scanDouble(&varCoef)
         allTerms.append(Term(vid : varId,coef : varCoef))
      }
      scan.scanDouble(&rhs)
      allEqs.append(Equation(terms: allTerms,rhs : rhs, dir : Direction.LEQ))
   }
   return Problem(allEqs)
}

// Top-level code.
// Read all instances
// and call the main-routine (solveFeasibleTogether).
autoreleasepool {
   do {
      let buf = try String(contentsOfFile: "/Users/ldm/Desktop/sridhar.txt", encoding: String.Encoding.ascii)
      let scan = Scanner(string: buf)
      var ap : [Problem] = []
      while (!scan.isAtEnd) {
         let p : Problem = readProblem(scan)
         ap.append(p)
      }
      let t = Trajectory(ap)
      t.solveFeasibleTogether()

   } catch {
      print("Couldn't read the input file")
      return
   }
}
