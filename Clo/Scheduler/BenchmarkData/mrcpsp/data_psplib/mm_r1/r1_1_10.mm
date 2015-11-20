************************************************************************
file with basedata            : cr11_.bas
initial value random generator: 1224872832
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  122
RESOURCES
  - renewable                 :  1   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       22       13       22
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          2           5   8
   3        3          1           5
   4        3          2           5   6
   5        3          2           7  10
   6        3          3           7   8  10
   7        3          2           9  14
   8        3          3          11  13  14
   9        3          2          11  13
  10        3          1          13
  11        3          2          12  15
  12        3          2          16  17
  13        3          2          16  17
  14        3          3          15  16  17
  15        3          1          18
  16        3          1          18
  17        3          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0
  2      1     3       5    0    5
         2     4       0    0    4
         3     6       0    3    0
  3      1     7       7    0    4
         2     8       5    0    3
         3    10       0    0    2
  4      1     2       0    4    0
         2     8       1    3    0
         3    10       0    0    7
  5      1     2       9    0   10
         2     8       5    2    0
         3     9       0    0    9
  6      1     1       0    9    0
         2     3       0    3    0
         3     6       5    0    4
  7      1     2       0    0    9
         2     3       1    0    5
         3     4       0    0    2
  8      1     4       0    6    0
         2     5       0    5    0
         3     7       0    0    1
  9      1     1       8    8    0
         2     2       8    7    0
         3     3       7    7    0
 10      1     3       7    7    0
         2     5       0    4    0
         3     7       6    1    0
 11      1     2       6    0    9
         2     3       4    5    0
         3     8       0    0    6
 12      1     1       9    9    0
         2     4       0    0    4
         3     4       0    7    0
 13      1     1       0    0    7
         2    10       6    2    0
         3    10       6    0    6
 14      1     2       0    0    7
         2     8       0    3    0
         3     9       0    2    0
 15      1     2       4    7    0
         2     5       0    7    0
         3     9       2    6    0
 16      1     1       9   10    0
         2     2       6   10    0
         3    10       0   10    0
 17      1     7       4    4    0
         2    10       3    0    3
         3    10       0    0    6
 18      1     0       0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  N 1  N 2
   10   38   21
************************************************************************