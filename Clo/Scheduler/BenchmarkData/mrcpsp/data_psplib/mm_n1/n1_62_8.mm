************************************************************************
file with basedata            : cn162_.bas
initial value random generator: 1285466889
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  127
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  1   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       22       13       22
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          2           5   7
   3        3          3           5   6  10
   4        3          3           5  13  16
   5        3          2          14  17
   6        3          3           8  11  17
   7        3          1          10
   8        3          3           9  12  13
   9        3          2          15  16
  10        3          3          12  15  17
  11        3          2          12  13
  12        3          1          16
  13        3          1          14
  14        3          1          15
  15        3          1          18
  16        3          1          18
  17        3          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  N 1
------------------------------------------------------------------------
  1      1     0       0    0    0
  2      1     2       7    6    6
         2     6       7    5    6
         3     7       6    3    5
  3      1     4       8    8    9
         2     4       9    8    8
         3     9       8    8    6
  4      1     5       5    7    7
         2     7       5    4    6
         3     9       5    4    5
  5      1     1       5    5    9
         2     2       4    2    7
         3     8       1    1    6
  6      1     3       4    5    8
         2     4       3    4    7
         3     5       3    1    6
  7      1     1       5    6   10
         2     1       6    7    9
         3     2       4    2    7
  8      1     3      10    9    6
         2     8       9    7    3
         3     9       8    6    3
  9      1     2       8    6   10
         2     6       7    6    9
         3     8       6    5    8
 10      1     5       7    9    6
         2     8       4    8    3
         3     8       6    8    2
 11      1     5       7    8    8
         2     6       6    6    8
         3     9       4    2    8
 12      1     3       7    6    5
         2     6       7    5    4
         3    10       5    4    2
 13      1     6       5    9    6
         2     8       4    9    3
         3     8       4    8    4
 14      1     1      10   10    7
         2     8       6   10    7
         3    10       4   10    7
 15      1     3       6    2    8
         2     8       5    2    4
         3    10       5    2    1
 16      1     3       9    6    4
         2     4       8    6    4
         3     5       7    3    3
 17      1     2       2    4    5
         2     3       2    3    3
         3    10       2    3    1
 18      1     0       0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1
   16   18  114
************************************************************************
