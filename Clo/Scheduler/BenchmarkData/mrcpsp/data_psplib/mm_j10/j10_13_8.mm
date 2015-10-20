************************************************************************
file with basedata            : mm13_.bas
initial value random generator: 1378115193
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  12
horizon                       :  79
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     10      0       10        4       10
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          2           5   6
   3        3          1           9
   4        3          3           7   8  10
   5        3          1          10
   6        3          2           9  10
   7        3          2           9  11
   8        3          1          11
   9        3          1          12
  10        3          1          12
  11        3          1          12
  12        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0
  2      1     4       0    2    5    8
         2     5       0    1    3    6
         3     7       2    0    1    4
  3      1     4       0    7    7    6
         2     8       0    4    7    6
         3     9       0    3    6    5
  4      1     2       7    0   10    4
         2     4       7    0    7    4
         3    10       6    0    7    3
  5      1     1       0    4    8    7
         2     1       0    4    7    8
         3     3       0    2    2    4
  6      1     1       7    0    5    9
         2     6       0    6    5    7
         3     7       0    5    2    5
  7      1     4       0    6    8    7
         2    10       0    5    1    2
         3    10       0    4    3    1
  8      1     1       8    0    7    7
         2     5       0    5    4    5
         3     6       0    3    3    3
  9      1     1       6    0    8    7
         2     9       1    0    7    5
         3     9       0    4    7    5
 10      1     4       0    4    8    4
         2     6       0    2    7    4
         3     8      10    0    6    3
 11      1     4       6    0    5    9
         2     7       4    0    4    8
         3    10       0    1    3    7
 12      1     0       0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2
   14   13   45   46
************************************************************************
