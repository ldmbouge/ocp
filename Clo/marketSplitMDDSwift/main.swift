/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

import ORProgram

autoreleasepool {
    let filename = "market.dta";
    var contents = try String(contentsOfFile: filepath, encoding: .utf8)
    
    FILE* dta = fopen(fn,"r");
    int n,m,z;
    fscanf(dta, "%d %d %d",&m,&n,&z);
    NSLog(@"m: %i, n: %i", m, n);
    id<ORIntRange> V = RANGE(model,0,n-1);
    int** w = alloca(sizeof(int*)*m);
    for(int k=0;k<m;k++)
       w[k] = alloca(sizeof(int)*n);
    
    int* rhs = alloca(sizeof(int)*m);
    for(int i=0;i<m;i++) {
       for(int j=0;j<n;j++)
          fscanf(dta,"%d ",w[i]+j);
       fscanf(dta,"%d ",rhs+i);
    }
    
    for(int i=0;i<m;i++) {
       for(int j=0;j<n;j++)
          printf("%d ",w[i][j]);
       printf(" <= %d\n",rhs[i]);
    }
    ORInt rrhs = 0;
    ORInt alpha = 1;
    ORInt* wr = malloc(sizeof(ORInt)*n);
    for(ORInt v = 0; v < n;v++) wr[v] = 0;
    for(ORInt c = 0; c < m;++c) {
       for(ORInt v = 0; v < n;v++) {
          wr[v] = wr[v] + alpha * w[c][v];
          rrhs = rrhs + alpha * rhs[c];
          alpha = alpha * 5;
       }
    }
    ORInt* tw = malloc(sizeof(ORInt)*n);
    for (ORInt v=0; v < n; ++v) {
       tw[v] = 0;
       for(ORInt c =0;c < m;++c)
          tw[v] += w[c][v];
    }
    id<ORIntVarArray> x = All(model,ORIntVar, i, V, [ORFactory intVar:model domain:RANGE(model,0,1)]);
    for(int i=0;i<m;i++) {
       id<ORIntArray> coef = [ORFactory intArray:model range:V with:^ORInt(ORInt j) { return w[i][j];}];
       id<ORIntVar>   r = [ORFactory intVar:model domain:RANGE(model,rhs[i],rhs[i])];
       [model add:[ORFactory knapsack:x weight:coef capacity:r]];
    }
    
    notes.ddWidth(relaxationSize)
    notes.ddRelaxed(true)
    let cp = ORFactory.createCPMDDProgram(m, annotation: notes)
    //let cp = ORFactory.createCPProgram(m, annotation: notes)
    cp.search {
        labelArray(cp, emp)
            »
            Do(cp) {
                let qs = (0..<AJ.count).map { i in cp.intValue(emp[ORInt(i)]) },
                    f  = cp.objectiveValue()!
                print("sol is: \(qs) f = \(f)")
                nbSol.incr(cp)
            }
    }
    let t1     = ORRuntimeMonitor.cputime()
    print("Solver status: \(cp)\n")
    print("Quitting: \(t1 - t0)\n")
}
