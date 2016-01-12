************************************************************************
file with basedata            : cn139_.bas
initial value random generator: 1093560280
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  147
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  1   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       19       11       19
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          3           5   7   8
   3        3          1           9
   4        3          3           6   8  10
   5        3          1          14
   6        3          2           7  14
   7        3          2           9  12
   8        3          2          11  14
   9        3          3          11  13  17
  10        3          2          11  12
  11        3          1          16
  12        3          3          15  16  17
  13        3          1          15
  14        3          3          15  16  17
  15        3          1          18
  16        3          1          18
  17        3          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  N 1
------------------------------------------------------------------------
  1      1     0       0    0    0
  2      1     8       7    8    5
         2     9       7    6    5
         3    10       6    6    4
  3      1     3       9    4    7
         2     6       9    3    7
         3     9       8    2    6
  4      1     4       4    6    7
         2     7       4    6    6
         3     8       2    6    6
  5      1     2       6    9    8
         2     7       6    7    7
         3    10       4    5    5
  6      1     6       7    2    5
         2     7       6    2    5
         3     8       5    1    3
  7      1     2       5    9    7
         2     6       4    6    5
         3     8       4    4    2
  8      1     3       9    6    8
         2     7       8    3    6
         3    10       7    2    5
  9      1     3       6    6    5
         2     5       3    3    3
         3     9       1    1    3
 10      1     1       9   10    7
         2     2       8   10    6
         3    10       6   10    5
 11      1     1       7    7    8
         2     6       5    7    6
         3     9       1    5    3
 12      1     3       9    9    8
         2     7       9    7    5
         3    10       8    7    4
 13      1     3       7    5    7
         2     3       5    6    6
         3     8       4    5    3
 14      1     1       6    4    5
         2     6       4    3    5
         3     8       4    2    3
 15      1     1       5    6    5
         2    10       5    3    4
         3    10       5    4    2
 16      1     3       3   10    8
         2     5       3    7    8
         3    10       2    5    7
 17      1     4      10    7    6
         2     6       7    7    4
         3    10       6    7    4
 18      1     0       0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1
   20   20   75
************************************************************************
