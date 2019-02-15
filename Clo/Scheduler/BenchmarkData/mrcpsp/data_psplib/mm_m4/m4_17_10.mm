************************************************************************
file with basedata            : cm417_.bas
initial value random generator: 440733752
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  143
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       19       10       19
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        4          2           5  11
   3        4          3           9  12  13
   4        4          3           5   6  17
   5        4          3           7   9  12
   6        4          3           8   9  10
   7        4          1           8
   8        4          3          13  14  16
   9        4          2          14  16
  10        4          2          11  13
  11        4          2          12  16
  12        4          1          14
  13        4          1          15
  14        4          1          15
  15        4          1          18
  16        4          1          18
  17        4          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0
  2      1     6       2    0    9    0
         2     7       2    0    8    0
         3     8       0    8    5    0
         4    10       0    7    0    7
  3      1     1       3    0    0    6
         2     7       3    0    9    0
         3     8       2    0    7    0
         4    10       0    3    7    0
  4      1     2       0    4    5    0
         2     4       2    0    0    7
         3     5       1    0    3    0
         4    10       0    4    2    0
  5      1     2       0    9    0    9
         2     4       5    0    6    0
         3     5       0    9    5    0
         4     7       0    9    0    8
  6      1     2       7    0    8    0
         2     4       0   10    7    0
         3     6       0    6    0    2
         4     8       0    6    7    0
  7      1     1       0    9    0    4
         2     3       0    8    6    0
         3     7       8    0    0    4
         4     8       0    7    0    4
  8      1     1       0    5    0    8
         2     3       7    0    8    0
         3     6       0    3    0    6
         4    10       5    0    0    3
  9      1     8       0    5    9    0
         2     9       0    5    0    2
         3    10       0    4    9    0
         4    10       4    0    9    0
 10      1     2       1    0    2    0
         2     3       0    6    2    0
         3     4       0    5    0    8
         4     9       0    4    0    8
 11      1     2       0    5    0    7
         2     2       0    6    3    0
         3     3       7    0    0    8
         4     3       7    0    2    0
 12      1     2      10    0    0   10
         2     4      10    0    0    7
         3     7       0    8    8    0
         4    10       0    7    0    7
 13      1     2       4    0    0    4
         2     3       0    5    6    0
         3     8       3    0    6    0
         4    10       0    4    0    3
 14      1     2       0    8    0    1
         2     6       0    7    0    1
         3     7       0    6    0    1
         4     9       0    4    7    0
 15      1     1       9    0    9    0
         2     5       0    3    8    0
         3     5       0    4    7    0
         4     9       4    0    0    6
 16      1     1       0    8    0    1
         2     7       3    0    0    1
         3     8       0    7    6    0
         4    10       0    7    3    0
 17      1     1       2    0    0    7
         2     6       1    0    0    6
         3     7       1    0    0    5
         4    10       0    7    0    3
 18      1     0       0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2
    6   10   76   68
************************************************************************
