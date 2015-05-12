************************************************************************
file with basedata            : cm258_.bas
initial value random generator: 103751821
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  124
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       20        2       20
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        2          3           8  10  16
   3        2          3           5   6   7
   4        2          3           8   9  15
   5        2          3          10  12  16
   6        2          3           8  11  15
   7        2          2           9  10
   8        2          1          12
   9        2          2          12  14
  10        2          2          13  17
  11        2          2          14  17
  12        2          1          17
  13        2          1          15
  14        2          1          16
  15        2          1          18
  16        2          1          18
  17        2          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0
  2      1     2       4    0    1    6
         2     6       0    4    1    5
  3      1     5       7    0    5    6
         2     9       0    5    4    6
  4      1     5       0    3    6    5
         2    10       9    0    1    5
  5      1     8       4    0    6    9
         2     9       1    0    6    8
  6      1     1       6    0    8    2
         2     9       0    2    7    2
  7      1     3       7    0    3    1
         2     7       4    0    3    1
  8      1     3       0    7    9   10
         2     9       0    4    8    8
  9      1     1       6    0    5    9
         2     9       4    0    4    5
 10      1     1       7    0    9    6
         2     6       0    9    3    5
 11      1     7       0    7    7    2
         2    10       9    0    2    2
 12      1     4       8    0    8    8
         2     5       7    0    7    2
 13      1     3       7    0    7    5
         2     5       4    0    7    5
 14      1     6       6    0    7    8
         2     8       0    3    5    7
 15      1     3       0    8    4    8
         2     7       0    8    2    7
 16      1     1       1    0    7    9
         2    10       1    0    4    6
 17      1     3       6    0    5    6
         2     5       6    0    2    4
 18      1     0       0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2
   18   16   97  100
************************************************************************
