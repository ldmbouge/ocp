************************************************************************
file with basedata            : me9_.bas
initial value random generator: 1240915214
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  14
horizon                       :  104
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  0   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     12      0       19        1       19
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          2           7  10
   3        3          1           5
   4        3          3           6   7   8
   5        3          3           6   7   8
   6        3          3           9  11  12
   7        3          3          11  12  13
   8        3          3           9  11  12
   9        3          1          10
  10        3          1          13
  11        3          1          14
  12        3          1          14
  13        3          1          14
  14        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2
------------------------------------------------------------------------
  1      1     0       0    0
  2      1     5       5    0
         2     9       0    7
         3    10       0    6
  3      1     3       0    1
         2     5       4    0
         3    10       2    0
  4      1     4       0    7
         2     6       6    0
         3     8       0    6
  5      1     4       9    0
         2     4       0    3
         3     5       0    2
  6      1     1       0    9
         2     9       0    5
         3    10       6    0
  7      1     1       0    6
         2     6       4    0
         3    10       0    2
  8      1     2       0   10
         2     6       4    0
         3     8       0    2
  9      1     1       0    7
         2     9       0    3
         3    10       9    0
 10      1     6       0    2
         2     7       0    1
         3     8       5    0
 11      1     2       5    0
         2     7       4    0
         3    10       3    0
 12      1     8       1    0
         2     8       0    7
         3     9       0    6
 13      1     3       6    0
         2     5       0   10
         3     6       0    7
 14      1     0       0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2
    6    7
************************************************************************
