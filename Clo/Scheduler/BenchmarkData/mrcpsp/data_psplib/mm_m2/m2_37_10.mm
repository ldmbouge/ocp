************************************************************************
file with basedata            : cm237_.bas
initial value random generator: 1608292080
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  113
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       32        4       32
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        2          2           7   9
   3        2          2           8  17
   4        2          2           5   8
   5        2          3           6   7  10
   6        2          2           9  14
   7        2          2          11  14
   8        2          2          15  16
   9        2          1          11
  10        2          3          12  13  14
  11        2          3          12  13  17
  12        2          1          15
  13        2          2          15  16
  14        2          2          16  17
  15        2          1          18
  16        2          1          18
  17        2          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0
  2      1     5       9   10    6    4
         2     6       9    7    2    3
  3      1     5       5    7    9    8
         2     9       4    6    5    7
  4      1     3       5    7    5    9
         2     6       3    7    5    5
  5      1    10       2   10    9    3
         2    10       2    9    9    5
  6      1     3       5    1    9    4
         2     3       1    9    9    8
  7      1     1       4    6    6    7
         2     5       3    2    4    5
  8      1     5       5    5    3    4
         2     8       4    4    2    1
  9      1     7       5   10    8   10
         2    10       4   10    5    9
 10      1     1       6    4    8    6
         2     7       5    4    6    6
 11      1     3       1    3    8    4
         2     3       1    2    9    3
 12      1     2       6    9    8    6
         2     8       6    3    8    3
 13      1     2       8    5    1    6
         2     6       6    2    1    3
 14      1     8       5    3    3    6
         2     9       5    2    3    4
 15      1     1       4   10    7    4
         2     6       2    5    6    4
 16      1     4       7    5    9    3
         2     7       3    5    9    3
 17      1     6       5    6    4    8
         2    10       4    5    3    8
 18      1     0       0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2
   12   14   90   78
************************************************************************
