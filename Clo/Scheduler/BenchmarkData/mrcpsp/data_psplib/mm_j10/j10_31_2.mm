************************************************************************
file with basedata            : mm31_.bas
initial value random generator: 1110348013
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  12
horizon                       :  82
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     10      0       15        1       15
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          2           6   8
   3        3          1           5
   4        3          2           5   7
   5        3          1           9
   6        3          1           7
   7        3          2           9  11
   8        3          3           9  10  11
   9        3          1          12
  10        3          1          12
  11        3          1          12
  12        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0
  2      1     5       6    0    5    5
         2     5       0    7    5    4
         3     8       0    5    5    1
  3      1     3       0    9    6    9
         2     7       0    9    3    9
         3    10       0    9    1    8
  4      1     1       4    0    6    8
         2     2       0    6    4    7
         3     8       0    3    3    5
  5      1     2       2    0    6    9
         2     6       0    7    5    8
         3     7       0    7    2    8
  6      1     2       0    6    5    7
         2     2       8    0    5    8
         3     6       0    5    5    7
  7      1     3       0    7    7    9
         2     3       8    0    7    8
         3     5       6    0    7    1
  8      1     1       0    2    4    9
         2     5       0    2    4    5
         3     9       0    1    3    5
  9      1     1       0    4    7    8
         2     8       9    0    5    6
         3     9       0    2    3    6
 10      1     2       5    0    7    9
         2     8       2    0    6    9
         3    10       0    2    6    9
 11      1     5       0    9    6    6
         2     8       9    0    6    4
         3    10       8    0    6    4
 12      1     0       0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2
   18   22   54   72
************************************************************************
