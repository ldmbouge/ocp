************************************************************************
file with basedata            : md186_.bas
initial value random generator: 1081623465
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  16
horizon                       :  119
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     14      0       18       10       18
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          3           7   8   9
   3        3          1          10
   4        3          3           5   6  10
   5        3          3           8  11  12
   6        3          3           8   9  12
   7        3          1          10
   8        3          2          13  15
   9        3          3          11  13  15
  10        3          1          15
  11        3          1          14
  12        3          2          13  14
  13        3          1          16
  14        3          1          16
  15        3          1          16
  16        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0
  2      1     3       3    0    7    3
         2     4       2    0    6    3
         3     9       1    0    6    3
  3      1     2       4    0    6    9
         2    10       3    0    6    8
         3    10       0    4    6    8
  4      1     4       5    0    9    4
         2     6       2    0    8    4
         3     9       0    4    8    2
  5      1     3       0    9    8    5
         2     6       0    8    7    5
         3     9       0    8    3    4
  6      1     1       0    5    9    7
         2     3       0    3    8    6
         3     4       9    0    7    4
  7      1     4       2    0    7   10
         2     8       0    3    6    9
         3     9       0    3    5    9
  8      1     5       0    8    7    7
         2     8       5    0    7    3
         3     8       0    8    6    7
  9      1     8       0    3    4    5
         2     9       0    3    4    4
         3    10       0    3    4    3
 10      1     2       0    9    9    9
         2     5       0    8    7    7
         3    10       0    6    3    7
 11      1     4       0    5    3    4
         2     6       0    4    2    3
         3     7       5    0    1    2
 12      1     2       7    0    6   10
         2     8       4    0    5   10
         3    10       0    9    4   10
 13      1     1       0    7   10   10
         2     2       0    5   10    9
         3     9       2    0    9    9
 14      1     1       4    0    9    2
         2     1       0    7    9    2
         3     6       0    2    9    2
 15      1     4       0    5    6   10
         2     6       4    0    5   10
         3     9       1    0    3    9
 16      1     0       0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2
    7   19  100   95
************************************************************************
