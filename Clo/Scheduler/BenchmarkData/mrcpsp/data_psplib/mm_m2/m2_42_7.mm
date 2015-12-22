************************************************************************
file with basedata            : cm242_.bas
initial value random generator: 603456547
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  130
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       38       10       38
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        2          3           5   6  12
   3        2          3           6   7  13
   4        2          3           7   9  12
   5        2          1           9
   6        2          1          15
   7        2          3           8  10  11
   8        2          3          15  16  17
   9        2          3          10  13  14
  10        2          1          17
  11        2          2          14  16
  12        2          1          14
  13        2          1          16
  14        2          2          15  17
  15        2          1          18
  16        2          1          18
  17        2          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0
  2      1     5       2    0    1    5
         2    10       1    0    1    5
  3      1     4       0    4    8    8
         2     5       8    0    2    6
  4      1     5       0    5    8    3
         2     7       4    0    7    1
  5      1     9       0    8    7    9
         2     9       4    0    8    6
  6      1     6       9    0    7   10
         2     9       3    0    7    6
  7      1     2       0    3    7    6
         2     4       8    0    1    5
  8      1     5       6    0    5   10
         2     7       4    0    5    4
  9      1     5       4    0    7    6
         2    10       0    9    3    5
 10      1     2       0    4   10    8
         2     4       7    0    9    7
 11      1     4       5    0    3   10
         2     8       0    4    3    9
 12      1     7       5    0    5    3
         2    10       4    0    3    1
 13      1     9       2    0    1    7
         2    10       0    6    1    4
 14      1     5       0    4    6    7
         2     9       7    0    5    6
 15      1    10       0   10    8    7
         2    10       3    0    8    8
 16      1    10       0    8    6    5
         2    10       6    0    5    6
 17      1     6       0    4    3   10
         2     8       7    0    1    7
 18      1     0       0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2
   15   11   81  100
************************************************************************
