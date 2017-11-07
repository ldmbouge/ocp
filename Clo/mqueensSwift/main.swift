/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

import ORProgram

func varPermSym(m: ORModel,_ x : ORIntVarArray,_ p : ORIntMatrix) {
   let l = p.range(0).low()
   let u = p.range(0).up()
   let y = ORFactory.intVarArray(m,range: x.range()) { i in x[i] }
   for i in l...u {
      for j in l...u {
         if (i==j) { continue }
         let p1 = ORFactory.intArray(m,range:p.range(1)) { k in p[i,k] }
         let p2 = ORFactory.intArray(m,range:p.range(1)) { k in p[j,k] }
         varPermSymPairwise(m,y,p1,p2)
      }
   }
}

func varPermSymPairwise(m : ORModel,_ x : ORIntVarArray,_ p1 : ORIntArray,_ p2 : ORIntArray) {
   let invp1 = ORFactory.intArray(m,range:x.range()) { j in
      for i in x.range().low()...x.range().up() {
         if (p1.at(i) == j) {
            return j
         }
      }
      return -1
   }
   let y = ORFactory.intVarArray(m,range:x.range()) { i in x[p2.at(invp1.at(i))]}
   m.add(ORFactory.lex(x,leq:y))
}

autoreleasepool {
   let t0     = ORRuntimeMonitor.cputime()
   let n      = 10
   let l      = n*n
   let model  = ORFactory.createModel()
   let R      = range(model, 1...n)
   let filled = ORFactory.boolVarMatrix(model, range: R, R)
   let q      = ORFactory.intVarArray(model, range: R, domain: range(model,0...n))
   let obj    = ORFactory.intVar(model, domain: range(model,0...n))
   let y      = ORFactory.intVarArray(model,range:range(model,1...l))
   for i in 1...n {
      for j in 1...n {
         y[ORInt((i-1)*n + j)] = filled[i,j]
      }
   }
   let p = ORFactory.intMatrix(model,range: range(model,1...4),range(model,1...l))
   for k in 1...4 {
      for i in 1...n {
         for j in 1...n {
            switch k {
               case 1: p[k,(i-1)*n+j] = ORInt(i * n + j - n)
               case 2: p[k,(i-1)*n+j] = ORInt((n-j)*n + i)
               case 3: p[k,(i-1)*n+j] = ORInt((n-i)*n + (n-j)+1)
               default:p[k,(i-1)*n+j] = ORInt(i*n + (n-j)-n + 1)
            }
         }
      }
   }
   varPermSym(model,y,p)
   
   for i in 1...R.up() {
      for j in 1...R.up() {
         let e1 = exist(model, R, { k in j != k})  { k in filled[i,k]}
         let e2 = exist(model, R, { k in i != k})  { k in filled[k,j]}
         let e3 = exist(model, range(model,1..<n)) {
            k in
            let n = ORInt(n)
            var s : ORRelation? = nil
            if i+k <= n && j+k <= n { let x = filled[i+k,j+k]
               s = s==nil ? x : s!  ∨ x
            }
            if i-k >= 1 && j+k <= n { let x = filled[i-k,j+k]
               s = s==nil ? x : s!  ∨ x
            }
            if i+k <= n && j-k >= 1 { let x = filled[i+k,j-k]
               s = s==nil ? x : s!  ∨ x
            }
            if i-k >= 1 && j-k >= 1 { let x = filled[i-k,j-k]
               s = s==nil ? x : s!  ∨ x
            }
            if (s==nil) {
               return ORFactory.integer(model,value:0)
            } else {
               return s!
            }
         }
         model.add(filled[i,j] == !(e1 ∨ e2 ∨ e3))
      }
      model.add(q[i] == sum(model, R: R) { j in filled[i,j] * j })
   }
   model.add(obj == sum(model, R: R) { i in q[i] > 0 })
   model.minimize(obj)
   
   let cp = ORFactory.createCPProgram(model)
   cp.search {
      firstFail(cp, y) »
      Do(cp) {
         let qs = (1...n).map { i in cp.intValue(q[ORInt(i)]) }
         print("Q is: \(qs)\tObjective: \(cp.intValue(obj))")
      }
   }
   let t1     = ORRuntimeMonitor.cputime()
   print("Solver status: \(cp)\n")
   print("Quitting: \(t1 - t0)\n")
}