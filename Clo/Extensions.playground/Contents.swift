//: Playground - noun: a place where people can play

import ORProgram

extension Array {
   subscript(i : ORInt) -> Element {
      get {
         return self[Int(i)]
      }
      set(nv) {
         self[Int(i)] = nv
      }
   }
}

var a = [1,2,3,4]

let i0 : ORInt = 1
let i1 : ORInt = 2
let w = a[i0]
a[i1] = 10

print(a)


