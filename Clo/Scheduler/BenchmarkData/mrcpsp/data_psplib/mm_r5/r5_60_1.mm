************************************************************************
file with basedata            : cr560_.bas
initial value random generator: 7447
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  133
RESOURCES
  - renewable                 :  5   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       24       15       24
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          3           5   6   7
   3        3          1           5
   4        3          3          12  14  15
   5        3          1           9
   6        3          2           8   9
   7        3          2           8  10
   8        3          3          11  13  14
   9        3          3          10  12  14
  10        3          2          11  13
  11        3          3          15  16  17
  12        3          1          17
  13        3          2          15  17
  14        3          1          16
  15        3          1          18
  16        3          1          18
  17        3          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  R 3  R 4  R 5  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0    0    0    0
  2      1     6       7    0    6    0    0    6    5
         2     7       0    6    0    0    0    5    4
         3     8       0    2    0    8    5    4    2
  3      1     1       0    0    0    0    6    3    7
         2     2       0    6    0    0    0    3    6
         3     5       0    2    4    0    4    2    5
  4      1     1       6    5    0    5    0    4    8
         2     4       6    4    2    4    0    4    7
         3     7       0    0    1    2    8    3    4
  5      1     1       0    9    7    6   10    6    9
         2     4       8    0    5    0    0    5    6
         3     8       7    0    0    3    8    4    6
  6      1     1       0    9    2    5    7    3    8
         2     5       6    8    0    0    4    3    7
         3    10       0    0    1    0    0    3    6
  7      1     8       0    7    0    9   10    9    6
         2     8       5    0    0    9    0    9   10
         3    10       0    7    0    9    9    8    2
  8      1     1       0    0    4    8    4    9    9
         2     5       0    0    3    3    0    9    7
         3     5       7    7    0    4    0    9    7
  9      1     3       1    0    0    0    0    5    9
         2     4       0    0    4    0    4    5    5
         3    10       0    4    0    0    3    5    4
 10      1     1      10    0    6   10   10    6    6
         2     7       0    6    5    9    0    5    5
         3     7       0    8    0    9    3    5    5
 11      1     3       4    0    0    7    0    7    4
         2     3       3    0    4    6    0    8    6
         3     9       0    0    0    0   10    7    2
 12      1     5       0    9    4    0    0   10    6
         2     9       0    0    0    5    7    5    5
         3    10       5    8    3    4    0    3    5
 13      1     3       0    3    0    0    0    9   10
         2     7       0    0    7    6    0    9   10
         3     8       1    0    5    0    0    8   10
 14      1     1       2    0    3    2    5    4    7
         2     9       2    7    0    0    5    4    5
         3    10       0    0    3    2    0    3    5
 15      1     1       1    0    4    4    8    9    3
         2     2       0    6    4    0    6    7    2
         3    10       0    0    3    0    0    5    2
 16      1     6       0    0    5    7    0    5    5
         2     7       0    9    0    4    8    4    4
         3     9       0    9    0    0    8    4    2
 17      1     1       0    0    8    5    7    7    9
         2     3       2    8    0    5    4    5    8
         3     7       0    0    0    4    4    4    6
 18      1     0       0    0    0    0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  R 3  R 4  R 5  N 1  N 2
   22   25   18   23   27  103  117
************************************************************************
