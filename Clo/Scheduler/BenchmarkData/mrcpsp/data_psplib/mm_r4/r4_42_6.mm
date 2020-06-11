************************************************************************
file with basedata            : cr442_.bas
initial value random generator: 2030532511
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  114
RESOURCES
  - renewable                 :  4   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       17        3       17
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          3           6   8  14
   3        3          2           7  10
   4        3          3           5   7  11
   5        3          3           9  12  13
   6        3          2          13  15
   7        3          3           8   9  14
   8        3          2          16  17
   9        3          1          16
  10        3          2          11  17
  11        3          2          13  15
  12        3          1          14
  13        3          1          16
  14        3          2          15  17
  15        3          1          18
  16        3          1          18
  17        3          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  R 3  R 4  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0    0    0
  2      1     1       0    0    5    0    4    8
         2     2       0    8    4    0    4    7
         3     7       0    8    0    0    3    5
  3      1     3       6    0    7    0    9    5
         2     4       0    0    0   10    6    4
         3     8       0    0    5    9    2    4
  4      1     2       5    0    7    0    4    9
         2     4       0    6    7    0    2    9
         3     7       0    5    0    2    2    7
  5      1     1       0    0    5    0    9    3
         2     2       0    7    4    0    5    3
         3     4       7    5    4    0    2    3
  6      1     9      10    4    0    0    5   10
         2    10       0    4    3    0    5   10
         3    10       9    0    0    3    5   10
  7      1     5       0    3    8    0   10    9
         2     6       9    0    4    6    6    7
         3     7       4    0    0    6    4    6
  8      1     3       8    1    8    9    6    7
         2     3       0    1    0    0    6    8
         3     5       7    0    0    0    5    2
  9      1     4       0    8    0    0    9    5
         2     4       0    0    8    0    9    3
         3     9       4    6    0    0    7    3
 10      1     5       0    1    0   10    3    5
         2     7       0    0    6    9    3    5
         3     9       7    0    5    8    2    4
 11      1     3       2    0    0   10    8    7
         2     5       0    6    4    0    6    6
         3     6       0    5    4    9    5    3
 12      1     3       2    8    7    9    7    7
         2     4       0    0    6    7    4    4
         3     6       0    5    0    6    3    2
 13      1     4       5    0    0    0    9    3
         2     8       0    6    8    0    8    3
         3     9       2    0    8    4    7    2
 14      1     4       1    6    0    6    2   10
         2     6       0    6    0    3    1    6
         3     8       0    6    0    0    1    3
 15      1     1       0   10    3   10    6    5
         2     2       5    8    0    0    5    4
         3     4       0    4    0    0    2    3
 16      1     2       0    5    7    0    4    7
         2     2       4    5    6    0    4    8
         3     6       0    4    6    0    2    7
 17      1     4       9    0    0   10    8    8
         2     9       0    0    4    0    8    8
         3     9       8    0    0    7    7    8
 18      1     0       0    0    0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  R 3  R 4  N 1  N 2
   17   16   16   18   81   91
************************************************************************
