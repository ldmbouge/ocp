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
    let demand : [Int32]
    let require : [[Int]]
    init(_ nc : Int,_ no : Int,_ ncof : Int,lb : [Int],ub : [Int],demand : [Int32],require : [[Int]]) {
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
        var demand  : [Int32] = [Int32](repeating: 0, count : nbConf)
        for cid in 0 ..< nbConf {
            let row = lines[3 + cid].components(separatedBy: " ").map { v in Int(v) }
            demand[row[0]!] = Int32(row[1]!)
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

autoreleasepool {
    let arguments = CommandLine.arguments
    let numArguments = arguments.count
    
    let fileName = numArguments > 1 ? arguments[1] : "/Users/rebeccagentzel/Downloads/carseq_01"
    let mode = numArguments > 2 ? Int(arguments[2]) : 6
    let relaxationSize = numArguments > 3 ? Int32(arguments[3]) : 8
    let usingFirstFail = numArguments > 4 ? Bool(arguments[4]) : false
    let splitAllLayersBeforeFiltering = numArguments > 5 ? Bool(arguments[5]) : true
    let maxSplitIter = numArguments > 6 ? Int32(arguments[6]) : 1
    let maxRebootDistance = numArguments > 7 ? Int32(arguments[7]) : 0
    let recommendationStyle = numArguments > 8 ? Int(arguments[8]) : 0
    let variableOverlap = numArguments > 9 ? Int32(arguments[9]) : 0
    let useStateExistence = numArguments > 10 ? Bool(arguments[10]) : true
    let nodePriorityMode = numArguments > 11 ? Int32(arguments[11]) : 0
    let candidatePriorityMode = numArguments > 12 ? Int32(arguments[12]) : 0
    let stateEquivalenceMode = numArguments > 13 ? Int32(arguments[13]) : 0
    let numNodesSplitAtATime = numArguments > 14 ? Int32(arguments[14]) : 1
    let numNodesDefinedAsPercent = numArguments > 15 ? Bool(arguments[15]) : false
    let splittingStyle = numArguments > 16 ? Int32(arguments[16]) : 0
    let printSolutions = numArguments > 17 ? Bool(arguments[17]) : true

    let orderByOptions = true
    let optionOrdering = [0, 3, 4, 2, 1]
    
    let carI = readData(filePath: fileName)!
    
    let m  = ORFactory.createModel(),
        notes = ORFactory.annotation(),
        nbSol = ORFactory.mutable(m, value: 0),
        options = carI.options(),
        cars =  carI.cars()
    
    let programStart    = ORRuntimeMonitor.cputime()
    
    let CR = range(m, low: 0,up: cars.count - 1),
        CRP = range(m, low: 0,up: cars.count),
        OR = range(m, low: 0, up: options.count - 1),
        CF = range(m,low: 0,up: carI.nbConf-1),
        B = range(m,low: 0, up:1),
        demand   = ORFactory.intArray(m, range: CF) { i in ORInt(carI.demand[Int(i)]) },
        require  = carI.require
    
    
    var confOrdering : [Int] = Array(0..<carI.nbConf)
    if orderByOptions {
        var confOptionValues : [Int] = []
        for i in 0..<carI.nbConf {
            var optionValue = 0
            for j in 0..<options.count {
                optionValue *= 2
                optionValue += require[i][optionOrdering[j]]
            }
            confOptionValues.append(optionValue)
        }
        confOrdering.sort {
            confOptionValues[$0] > confOptionValues[$1]
        }
    } else {
        confOrdering.sort {
            require[$0].reduce(0,+) > require[$1].reduce(0,+)
        }
    }
    
    var varOrdering : [Int] = Array(0..<cars.count)
    varOrdering.sort {
        abs(cars.count/2 - $0) < abs(cars.count/2 - $1)
    }

    let line  = ORFactory.intVarArray(m, range: CR, domain: CF)
    let setup = ORFactory.boolVarMatrix(m, range: OR, CR)
    //Requires decomposition matches initial line
    for c in 0 ..< cars.count {
        for o in 0 ..< carI.nbOpts {
            let rl = intArray(m, range: CF) { i in require[i][o] }
            m.add(setup[o,c] == rl[line[c]])
        }
    }
    let assignmentVars = ORFactory.boolVarMatrix(m, range: range(m,low: 0, up:cars.count * options.count - 1), range(m,low:0, up:0))
    for o in 0 ..< options.count {
        for c in 0 ..< cars.count {
            m.add(setup[optionOrdering[o],c] == assignmentVars[o*cars.count + c,0])
        }
    }
    let orderedAssignmentVars = ORFactory.boolVarMatrix(m, range: range(m,low: 0, up:cars.count * options.count - 1), range(m,low:0, up:0))
    let midCar = Int(ceil(Double(cars.count)/2.0)) - 1
    for o in 0 ..< options.count {
        for i in 0 ... midCar {
            m.add(orderedAssignmentVars[2*i + o * cars.count,0] == assignmentVars[midCar - i + o * cars.count,0])
            m.add(orderedAssignmentVars[2*i + o * cars.count + 1,0] == assignmentVars[midCar + i + o * cars.count + 1,0])
        }
    }
    
    
    if mode! > 1 {
        notes.ddWidth(relaxationSize!)
        notes.ddRelaxed(relaxationSize! > 0)
        notes.ddRecommendationStyle(MDDRecommendationStyle(rawValue: MDDRecommendationStyle.RawValue(recommendationStyle!)))
        notes.ddVariableOverlap(variableOverlap!)
        notes.ddSplitAllLayers(beforeFiltering: splitAllLayersBeforeFiltering!)
        notes.ddMaxSplitIter(maxSplitIter!)
        notes.ddMaxRebootDistance(maxRebootDistance!)
        notes.ddUseStateExistence(useStateExistence!)
        notes.ddNumNodesSplit(atATime: numNodesSplitAtATime!)
        notes.ddNumNodesDefined(asPercent: numNodesDefinedAsPercent!)
        notes.ddSplittingStyle(splittingStyle!)
    }
    
    //let demandDict = Dictionary(uniqueKeysWithValues: zip(0...(carI.nbConf-1), carI.demand))
    
    //Mode 0: Classic constraint, sums, no redundant
    //Mode 1, Classic constraint, sums, w/ redundant
    //Mode 2: Classic constraint, cumulative sums
    //Mode 3: MDD, sequence on decompositions, no redundant
    //Mode 4: MDD, sequence on decompositions, w/ redundant
    //Mode 5: MDD, sequences on initial line, no redundant
    //Mode 6: MDD, sequences on initial line, w/ redundant
    
    if mode! == 0 || mode! == 1 {
        //Requires demand of # of each car type is met
        m.add(ORFactory.cardinality(line, low: demand, up: demand))
        
        //Requires that each part's capacity on the line isn't exceeded
        for o in 0 ..< carI.nbOpts {
            for s in 0 ... cars.count - carI.ub[o] {
                let SR = range(m,low:s,up:s + carI.ub[o] - 1)
                m.add(sum(m, R: SR, b: { j in setup[ORInt(o),j] }) ≤ carI.lb[o])
            }
            
            if mode! == 1 {
                //Implied constraints
                var demandForOption = 0
                for conf in 0 ..< carI.nbConf {
                    if require[conf][o] == 1 {
                        demandForOption += Int(demand[conf])
                    }
                }
                for i in 0 ... (demandForOption/carI.lb[o]) {
                    let SR = range(m,low:0 ,up:cars.count - Int(i) * carI.ub[o] - 1)
                    m.add(sum(m, R: SR) { s in setup[ORInt(o),s]} ≥ demandForOption - i * carI.lb[o])
                }
            }
        }
    } else if mode! == 2 {
        //Requires demand of # of each car type is met
        m.add(ORFactory.cardinality(line, low: demand, up: demand))
        
        for o in 0 ..< carI.nbOpts {
            var configurationsWithOption : [Int] = []
            for conf in 0 ..< carI.nbConf {
                if require[conf][o] == 1 {
                    configurationsWithOption.append(conf)
                }
            }
            let confSet = ORFactory.intSet(m, set: Set<Int>(configurationsWithOption))
            let cumul = ORFactory.intVarArray(m, range: CRP, domain: CR)
            m.add(cumul[0] == 0)
            let boolVars = ORFactory.intVarArray(m, range: CR, domain: B)
            for i in 0..<cars.count {
                m.add(boolVars[i] == (line[i] ∈ confSet))
                m.add(cumul[i+1] == (cumul[i] + boolVars[i]))
            }
            
            for i in 0...(cars.count-carI.ub[o]) {
                m.add(cumul[i+carI.ub[o]] ≤ cumul[i] + carI.lb[o])
                m.add(cumul[i+carI.ub[o]] ≥ cumul[i] + 0)
            }
        }
    } else if mode! == 3 || mode! == 4 {
        //Requires demand of # of each car type is met
        m.add(gccMDD(line, lb: carI.demand, ub: carI.demand, constraintPriority: 0, nodePriorityMode: nodePriorityMode!, candidatePriorityMode: candidatePriorityMode!, stateEquivalenceMode: stateEquivalenceMode!))
        
        //Requires that each part's capacity on the line isn't exceeded
        for o in 0 ..< carI.nbOpts {
            var configurationsWithOption : [Int] = []
            for conf in 0 ..< carI.nbConf {
                if require[conf][o] == 1 {
                    configurationsWithOption.append(conf)
                }
            }
            
            m.add(improvedSequenceMDD(all(m, CR) { i in setup[ORInt(o),i]}, len: carI.ub[o], lb: 0, ub: carI.lb[o], values: Set<Int>([1]), constraintPriority: 0))
            
            if mode! == 4 {
                //Implied
                var demandForOption = 0
                for conf in 0 ..< carI.nbConf {
                    if require[conf][o] == 1 {
                        demandForOption += Int(demand[conf])
                    }
                }
                for i in 0 ... (demandForOption/carI.lb[o]) {
                    let SR = range(m,low:0 ,up:cars.count - Int(i) * carI.ub[o] - 1)
                    m.add(sum(m, R: SR) { s in setup[ORInt(o),s]} ≥ demandForOption - i * carI.lb[o])
                }
            }
        }

        /*for o in 0 ..< carI.nbOpts {
            for i in 1 ... demand[o] {
                let SR = range(m,low:0 ,up:cars.count - Int(i) * carI.ub[o] - 1)
                m.add(sum(m, R: SR) { s in setup[ORInt(o),s]} ≥ demand[o] - i * carI.lb[o])
            }
        }*/
    } else {
        //Requires decomposition matches initial line
        /*for c in 0 ..< cars.count {
            for o in 0 ..< carI.nbOpts {
                let rl = intArray(m, range: CF) { i in require[i][o] }
                m.add(setup[o,c] == rl[line[c]])
            }
        }*/
        
        //Requires demand of # of each car type is met
        //m.add(gccMDD(line, lb: carI.demand, ub: carI.demand, constraintPriority: 0, nodePriorityMode: nodePriorityMode!, candidatePriorityMode: candidatePriorityMode!, stateEquivalenceMode: stateEquivalenceMode!))
        m.add(ORFactory.cardinality(line, low: demand, up: demand))

        //Requires that each part's capacity on the line isn't exceeded
        for o in 0 ..< carI.nbOpts {
            var configurationsWithOption : [Int] = []
            for conf in 0 ..< carI.nbConf {
                if require[conf][o] == 1 {
                    configurationsWithOption.append(conf)
                }
            }
            m.add(improvedSequenceMDD(all(m, CR) { i in line[i] }, len: carI.ub[o], lb: 0, ub: carI.lb[o], values: Set<Int>(configurationsWithOption), constraintPriority: 0))
            
            if mode! == 6 {
                //Implied
                var demandForOption = 0
                for conf in 0 ..< carI.nbConf {
                    if require[conf][o] == 1 {
                        demandForOption += Int(demand[conf])
                    }
                }
                let confSet = ORFactory.intSet(m, set: Set<Int>(configurationsWithOption))
                for i in 0 ... (demandForOption/carI.lb[o]) {
                    let SR = range(m,low:0 ,up:cars.count - Int(i) * carI.ub[o] - 1)
                    m.add(sum(m, R: SR) { s in line[s] ∈ confSet } ≥ demandForOption - i * carI.lb[o])
                }
            }
        }

        /*for o in 0 ..< carI.nbOpts {
            for i in 1 ... demand[o] {
                let SR = range(m,low:0 ,up:cars.count - Int(i) * carI.ub[o] - 1)
                m.add(sum(m, R: SR) { s in setup[ORInt(o),s]} ≥ demand[o] - i * carI.lb[o])
            }
        }*/
    }
    
    let cp = ORFactory.createCPMDDProgram(m, annotation: notes)
    
    var postEnd:ORLong = 0
    /*if usingFirstFail! {
        cp.search {
            Do(cp) {
                postEnd = ORRuntimeMonitor.cputime()
            }
            »
            firstFailMDD(cp, line)
            »
            Do(cp) {
                let qs = (0 ..< cars.count).map { i in cp.intValue(line[ORInt(i)]) }
                if (printSolutions!) {
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
                }
                nbSol.incr(cp)
            }
        }
    } else {
        cp.search {
            Do(cp) {
                postEnd = ORRuntimeMonitor.cputime()
            }
            »
            labelArrayMDD(cp, line)
            »
            Do(cp) {
                let qs = (0 ..< cars.count).map { i in cp.intValue(line[ORInt(i)]) }
                if (printSolutions!) {
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
                }
                nbSol.incr(cp)
            }
        }
    }*/
    
    cp.search {
        Do(cp) {
          postEnd = ORRuntimeMonitor.cputime()
        }
        »
        whileDo(cp, {!cp.allBound(line)}, {
            var bestVarIndex = 0
            for varIndex in 0..<(cars.count*options.count) {
                if (cp.domsize(orderedAssignmentVars[varIndex,0]) > 1) {
                    bestVarIndex = varIndex
                    break
                }
            }
            print("\(bestVarIndex)")
            for varIndex in 0..<(cars.count) {
                var domain = "["
                for dom in 0..<carI.nbConf {
                    if cp.member(ORInt(dom), in: line[varIndex]) == 1 {
                        if domain != "[" {
                            domain += ", "
                        }
                        domain += "\(dom)"
                    }
                }
                domain += "]"
                print("\(varIndex): \(domain)")
            }
            return whileDo(cp,{!cp.bound(orderedAssignmentVars[ORInt(bestVarIndex),0])}) {
                return equal(cp, orderedAssignmentVars[bestVarIndex,0], 1) | equal(cp, orderedAssignmentVars[bestVarIndex,0], 0)
            }
        })
        »
          Do(cp) {
              let qs = (0 ..< cars.count).map { i in cp.intValue(line[ORInt(i)]) }
              if (printSolutions!) {
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
              }
              nbSol.incr(cp)
        }
    }
    
    let programEnd     = ORRuntimeMonitor.cputime()
    print("Solver status: \(cp)\n")
    print("Time to post: \(postEnd - programStart)\n")
    print("Quitting: \(programEnd - programStart)\n")
}
