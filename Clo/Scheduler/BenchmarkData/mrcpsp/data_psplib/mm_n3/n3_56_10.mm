************************************************************************
file with basedata            : cn356_.bas
initial value random generator: 1400350229
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  132
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  3   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       21       15       21
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          3           6   7  10
   3        3          3           5   7   8
   4        3          3           5   9  15
   5        3          1          11
   6        3          3          11  12  15
   7        3          3           9  13  14
   8        3          2          10  14
   9        3          2          11  17
  10        3          2          16  17
  11        3          1          16
  12        3          2          13  17
  13        3          1          16
  14        3          1          15
  15        3          1          18
  16        3          1          18
  17        3          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  N 1  N 2  N 3
------------------------------------------------------------------------
  1      1     0       0    0    0    0    0
  2      1     5      10    4    8    7    7
         2     8       7    3    7    5    5
         3     9       7    3    5    3    5
  3      1     6       3   10    4    8    9
         2     8       2    6    4    7    5
         3     9       2    4    4    6    3
  4      1     1      10    8    8    7    8
         2     7      10    6    7    7    5
         3     9       9    5    5    6    4
  5      1     1       7    3    6    9   10
         2     7       7    3    6    7   10
         3    10       7    2    3    6   10
  6      1     4       3    9    8   10    4
         2     5       3    9    6    8    4
         3     9       2    8    6    7    3
  7      1     6       9    4    7    4   10
         2     7       5    4    5    3   10
         3     7       7    4    5    2   10
  8      1     5       8    3    4    5    5
         2     7       7    2    4    5    5
         3     8       7    1    1    4    4
  9      1     3       9    8    9    4    8
         2     5       8    7    7    2    7
         3     8       4    7    6    1    5
 10      1     1       8    9    3    8    5
         2     3       7    8    2    3    4
         3     4       6    6    2    1    2
 11      1     1       8    8    8    5    5
         2     4       7    7    8    3    4
         3     9       6    5    7    3    4
 12      1     1       6   10    8    7   10
         2     5       3   10    8    7   10
         3     9       1   10    8    6   10
 13      1     6       9    7    5    9    7
         2     7       7    6    5    8    4
         3     8       4    6    2    8    4
 14      1     3       2    4    6   10    8
         2     5       1    3    6    9    8
         3     8       1    3    3    9    7
 15      1     1       7    5    3    5    6
         2     2       4    5    2    4    5
         3    10       3    4    1    3    5
 16      1     3       6   10    3    6    7
         2     6       4    6    3    5    5
         3    10       1    4    3    5    4
 17      1     2       7    4    9    6    7
         2     4       4    4    8    5    6
         3     5       3    1    8    5    5
 18      1     0       0    0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2  N 3
   31   24   92  101  108
************************************************************************
