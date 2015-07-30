//: Playground - noun: a place where people can play

import Cocoa
import ORProgram

extension Array {
   subscript(i : ORInt) -> T {
      get {
         let x = self
         return x[Int(i)]
      }
   }
}

let a = [1,2,3]


