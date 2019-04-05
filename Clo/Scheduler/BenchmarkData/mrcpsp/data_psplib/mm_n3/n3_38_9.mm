************************************************************************
file with basedata            : cn338_.bas
initial value random generator: 525459104
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  111
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  3   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       16        9       16
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          2           6   8
   3        3          3           5   8  11
   4        3          1           7
   5        3          2           6   7
   6        3          3           9  10  12
   7        3          2          15  16
   8        3          2          10  17
   9        3          3          13  14  17
  10        3          2          13  14
  11        3          1          15
  12        3          3          13  14  17
  13        3          2          15  16
  14        3          1          16
  15        3          1          18
  16        3          1          18
  17        3          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  N 1  N 2  N 3
------------------------------------------------------------------------
  1      1     0       0    0    0    0    0
  2      1     7       3    6    6    9    8
         2     8       3    3    4    8    7
         3     9       2    1    3    7    4
  3      1     3       7    8    7   10    7
         2     3       8    9    7    9    7
         3     5       6    8    7    4    7
  4      1     1       9    7    9    1    6
         2     1       8    7    7    1    8
         3    10       6    7    5    1    4
  5      1     1       7    5    3    9    7
         2     1       6    6    3    8    7
         3     3       2    5    1    6    7
  6      1     2       7    4    3    8    7
         2     4       5    4    2    7    6
         3     9       4    2    2    4    4
  7      1     1       7    6   10    5    8
         2     4       5    6    7    5    7
         3     5       5    4    5    5    6
  8      1     1       7    7    7    6    4
         2     9       7    3    3    2    4
         3     9       7    3    3    3    3
  9      1     1       5   10    5    8    5
         2     3       5   10    3    7    2
         3     4       5   10    2    3    2
 10      1     1      10    6    7    9    8
         2     5       7    5    7    7    8
         3     6       4    5    6    6    8
 11      1     1       6    9    3    9    4
         2     6       4    5    2    8    4
         3    10       1    3    2    7    1
 12      1     1       5    9    5    7    6
         2     2       5    9    4    5    6
         3     8       1    9    4    5    6
 13      1     2      10    8   10    4    8
         2     9      10    7   10    3    7
         3    10      10    5   10    1    7
 14      1     1      10    5    4    9    6
         2     2       9    4    4    8    6
         3     4       7    4    4    6    3
 15      1     3       9    5    9    8    4
         2     3       9    5    9   10    3
         3     4       7    5    3    4    2
 16      1     2       5    9    8    9    3
         2     3       4    4    6    6    3
         3     5       4    2    2    2    3
 17      1     6       9    8    6    8    4
         2     7       9    8    5    6    3
         3    10       8    7    1    6    2
 18      1     0       0    0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2  N 3
   20   18   71   82   76
************************************************************************
