************************************************************************
file with basedata            : mm14_.bas
initial value random generator: 207635904
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  12
horizon                       :  90
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     10      0       12        1       12
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          1           7
   3        3          3           5   8  11
   4        3          2           6  10
   5        3          2           9  10
   6        3          1           7
   7        3          2           8  11
   8        3          1           9
   9        3          1          12
  10        3          1          12
  11        3          1          12
  12        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0
  2      1     2       0    6   10    8
         2     4       0    2    8    6
         3     5       5    0    6    3
  3      1     5       5    0   10   10
         2     9       4    0    8   10
         3    10       1    0    7   10
  4      1     1       5    0    9    7
         2     5       4    0    9    5
         3     9       4    0    8    4
  5      1     5       0    8    8    6
         2     8       9    0    5    6
         3    10       0    7    3    6
  6      1     1       0    2    7   10
         2     3       9    0    6    9
         3     7       6    0    4    9
  7      1     6       0    8    4    2
         2     9       7    0    3    2
         3    10       5    0    3    2
  8      1     3       4    0    8    7
         2     6       4    0    6    5
         3    10       3    0    5    4
  9      1     1       7    0    6    2
         2     3       7    0    5    2
         3    10       7    0    4    1
 10      1     2       4    0   10    8
         2     4       0    8    9    7
         3    10       0    8    7    2
 11      1     1       0   10    6    5
         2     3       3    0    5    5
         3     9       2    0    5    5
 12      1     0       0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2
   13    9   65   56
************************************************************************
