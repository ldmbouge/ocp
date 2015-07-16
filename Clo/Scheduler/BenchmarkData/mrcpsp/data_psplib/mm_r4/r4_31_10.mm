************************************************************************
file with basedata            : cr431_.bas
initial value random generator: 1081865186
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  131
RESOURCES
  - renewable                 :  4   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       18        7       18
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          3           8   9  12
   3        3          1          15
   4        3          3           5   7  15
   5        3          2           6   9
   6        3          3          10  13  14
   7        3          3          10  13  14
   8        3          3          11  14  15
   9        3          2          11  17
  10        3          1          11
  11        3          1          16
  12        3          2          13  17
  13        3          1          16
  14        3          2          16  17
  15        3          1          18
  16        3          1          18
  17        3          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  R 3  R 4  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0    0    0
  2      1     2       8    5    6    3    0    6
         2     5       6    3    5    3    0    5
         3     8       4    1    4    3    5    0
  3      1     8       7    2    5    4    1    0
         2     8       5    2    6    3    0    4
         3    10       5    2    5    1    0    4
  4      1     2       4    9    6    7    9    0
         2     3       4    9    6    5    7    0
         3     7       4    8    6    3    0    5
  5      1     2       6    4    8    4    0    5
         2     5       3    4    6    4    0    5
         3     8       2    3    5    3    4    0
  6      1     4       5    8    4    9    0    9
         2     5       4    4    2    9    0    9
         3    10       2    3    2    8    0    6
  7      1     6       9    9    5    9    3    0
         2     8       6    8    5    6    0    2
         3     9       3    8    4    3    0    2
  8      1     9       8    9    6    6    3    0
         2    10       8    6    6    3    0    9
         3    10       8    7    6    3    2    0
  9      1     1       8    3    7    5    0    7
         2     2       6    2    7    5    0    6
         3    10       6    1    5    4    0    6
 10      1     2       7    7    6    5    0    4
         2    10       5    2    5    3    0    2
         3    10       3    2    2    4    0    1
 11      1     1       9    6    4    9    0    5
         2     3       8    3    2    8    0    3
         3     6       8    3    2    8    6    0
 12      1     3       4    8    6    9    0    8
         2     6       4    7    6    5    7    0
         3    10       4    4    4    4    5    0
 13      1     9       9   10    9    7    9    0
         2    10       8    4    6    7    5    0
         3    10       8    3    5    6    0    9
 14      1     1       7    6    3    4    0    3
         2     4       6    5    3    3    5    0
         3     5       5    5    2    2    2    0
 15      1     1       2    8    6    9    0    9
         2     4       2    7    4    4    0    8
         3     5       2    6    1    4    0    8
 16      1     1       8    9    1    5    6    0
         2     2       7    6    1    5    0    9
         3     3       7    4    1    4    0    8
 17      1     2       8    8    2    8    2    0
         2     6       5    7    2    7    0    6
         3    10       2    7    2    7    0    5
 18      1     0       0    0    0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  R 3  R 4  N 1  N 2
   33   31   27   34   60  100
************************************************************************
