/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

import ORProgram

func cleanRows(_ file:String)->String {
    var cleanFile = file
    cleanFile = cleanFile.replacingOccurrences(of: "\r", with: "\n")
    cleanFile = cleanFile.replacingOccurrences(of: "\n\n", with: "\n")
    return cleanFile
}

class Instance {
    let nbCars : Int
    let nbOpts : Int
    let nbConf : Int
    let lb : [Int]
    let ub : [Int]
    let demand : [Int]
    let require : [[Int]]
    init(_ nc : Int,_ no : Int,_ ncof : Int,lb : [Int],ub : [Int],demand : [Int],require : [[Int]]) {
        nbCars = nc
        nbOpts = no
        nbConf = ncof
        self.lb = lb
        self.ub = ub
        self.demand = demand
        self.require = require
    }
    func options() -> [Set<Int>] {
        var opt = [Set<Int>](repeating : Set<Int>(),count : nbOpts)
        for c in 0 ..< nbConf {
           for o in 0 ..< nbOpts {
              if (require[c][o] == 1) {
                 opt[o].insert(c)
              }
           }
        }
        return opt
    }
    func cars() -> [Int]  {
        var ca = [Int](repeating : 0,count : nbCars),
            n  = 0
        for c in 0 ..< nbConf {
            for _ in 0 ..< demand[c] {
                ca[n] = c
                n += 1
            }
        }
        return ca
    }
}

func readData(filePath:String)-> Instance? {
    do {
        var contents = try String(contentsOfFile: filePath, encoding: .utf8)
        contents = cleanRows(contents)
        let lines = contents.components(separatedBy: "\n")
        let sizes = lines[0].components(separatedBy: " ")
        let nbCars = Int(sizes[0])!,
            nbOpts = Int(sizes[1])!,
            nbConf = Int(sizes[2])!
        let lb = lines[1].components(separatedBy: " ").map { v in Int(v) ?? 0 }
        let ub = lines[2].components(separatedBy: " ").map { v in Int(v) ?? 0 }
        var require : [[Int]] = [[Int]](repeating: [Int](repeating : 0,count: nbOpts),count : nbConf)
        var demand  : [Int] = [Int](repeating: 0, count : nbConf)
        for cid in 0 ..< nbConf {
            let row = lines[3 + cid].components(separatedBy: " ").map { v in Int(v) }
            demand[row[0]!] = row[1]!
            for o in 0..<nbOpts {
                require[row[0]!][o] = row[2+o]!
            }
        }
        return Instance(nbCars,nbOpts,nbConf,lb: lb,ub: ub,demand: demand,require: require)
    } catch {
        print("File Read Error for file \(filePath)")
        return nil
    }
}


func all(_ t : ORTracker,_ over : Set<Int>,_ mf : (Int) -> ORIntVar) -> ORIntVarArray {
    let cvr = range(t,low:0,up:over.count-1)
    let cv = ORFactory.intVarArray(t, range: cvr)
    var cnt = 0
    for i in over {
        cv[cnt] = mf(i)
        cnt += 1
    }
    return cv
}

func buildPrefix(from : Int,to : Int,S : Set<Int>,NS : Set<Int>,cs : [Int],k : Int,l : Int,u : Int,states : inout Set<[Int]>) {
    let rem = to - from + 1
    if (k > u || k+rem < l) {
        return
    } else {
        states.insert(cs)
    }
    if (from < to) {
        for v in NS {
            var n0 = cs
            n0.append(v)
            buildPrefix(from: from + 1, to: to,S:S,NS:NS, cs: n0, k:k,l:l, u:u, states: &states)
        }
        for v in S {
            var n0 = cs
            n0.append(v)
            buildPrefix(from: from + 1, to: to,S:S,NS:NS, cs: n0, k:k+1,l:l, u:u, states: &states)
        }
    }
}

func sequence(x : ORIntVarArray,S : Set<Int>,len : Int,l : Int,u : Int) {
    var states : Set<[Int]> = [[]]
    var NS : Set<Int> = [0]
    buildPrefix(from :0,to : len-1,S : S,NS : NS,cs: [],k:0,l:l,u:u,states: &states)
    print(states)
}

autoreleasepool {
    let m  = ORFactory.createModel()
    let carI = readData(filePath: "/Users/ldm/Desktop/datao")!
    let options = carI.options()
    let cars =  carI.cars(),
        CR = range(m, low: 0,up: cars.count - 1),
        OR = range(m, low: 0, up: options.count - 1),
        CF = range(m,low: 0,up: carI.nbConf-1),
        demand   = ORFactory.intArray(m, range: CF) { i in ORInt(carI.demand[Int(i)]) },
        require  = carI.require
    
    let notes = ORFactory.annotation(),
        nbSol = ORFactory.mutable(m, value: 0),
        t0    = ORRuntimeMonitor.cputime()

    let line  = ORFactory.intVarArray(m, range: CR, domain: CF),
        setup = ORFactory.boolVarMatrix(m, range: OR, CR)
    
    //sequence(x: line, S: [1], len: 4, l: 2, u: 2)
    
    m.add(ORFactory.cardinality(line, low: demand, up: demand))
    for o in 0 ..< carI.nbOpts {
        for s in 0 ... cars.count - carI.ub[o] {
            let SR = range(m,low:s,up:s + carI.ub[o] - 1)
            m.add(sum(m, R: SR, b: { j in setup[ORInt(o),j] }) ≤ carI.lb[o])
        }
    }
    for c in 0 ..< cars.count {
        for o in 0 ..< carI.nbOpts {
            let rl = intArray(m, range: CF) { i in require[i][o] }
            m.add(setup[o,c] == rl[line[c]])
        }
    }
    for o in 0 ..< carI.nbOpts {
        for i in 1 ... demand[o] {
            let SR = range(m,low:0 ,up:cars.count - Int(i) * carI.ub[o] - 1)
            m.add(sum(m, R: SR) { s in setup[ORInt(o),s]} ≥ demand[o] - i * carI.lb[o])
        }
    }
    
    let cp = ORFactory.createCPProgram(m, annotation: notes)
    cp.search {
        firstFail(cp, line)
            »
            Do(cp) {
                let qs = (0 ..< cars.count).map { i in cp.intValue(line[ORInt(i)]) }
                print("sol is: \(qs)")
                for o in 0 ..< carI.nbOpts {
                    print("\(carI.lb[o])/\(carI.ub[o]) :",terminator:"")
                    for c in 0..<qs.count {
                        if (require[Int(qs[c])][o] == 1) {
                            print("Y",terminator:"")
                        } else {
                            print(" ",terminator:"")
                        }
                    }
                    print("")
                }
                nbSol.incr(cp)
            }
    }
    let t1     = ORRuntimeMonitor.cputime()
    print("Solver status: \(cp)\n")
    print("Quitting: \(t1 - t0)\n")
}
