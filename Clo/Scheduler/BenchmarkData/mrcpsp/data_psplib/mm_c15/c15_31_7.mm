************************************************************************
file with basedata            : c1531_.bas
initial value random generator: 519469021
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  121
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       18       15       18
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          3          12  15  17
   3        3          1           5
   4        3          3           9  11  13
   5        3          3           6  11  15
   6        3          2           7  16
   7        3          2           8  13
   8        3          1          17
   9        3          1          10
  10        3          1          12
  11        3          1          16
  12        3          1          16
  13        3          1          14
  14        3          1          17
  15        3          1          18
  16        3          1          18
  17        3          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0
  2      1     6       4    3    8    0
         2     9       3    3    7    0
         3    10       2    3    5    0
  3      1     3       4    6    6    0
         2     5       4    3    4    0
         3     9       4    2    4    0
  4      1     3       3    3   10    0
         2     5       2    3    0    2
         3     9       2    2    0    2
  5      1     5       4    9    0    9
         2     6       3    6    0    9
         3     7       1    6   10    0
  6      1     1       8    8    8    0
         2     3       5    8    0    7
         3     3       5    8    4    0
  7      1     2      10    8    0    7
         2     7       7    5    0    5
         3     7       6    5    7    0
  8      1     5       8    3    0    6
         2     5      10    3    5    0
         3     7       7    1    4    0
  9      1     2       9    5    0    7
         2     6       7    5    9    0
         3     7       4    5    4    0
 10      1     1       9    4    0   10
         2     3       6    2    7    0
         3     7       4    1    7    0
 11      1     1       3    8    8    0
         2     2       3    6    0    7
         3     5       3    5    8    0
 12      1     5       9    5    5    0
         2     7       7    5    0    5
         3    10       2    5    0    5
 13      1     2       5    9    0    9
         2     3       4    9    6    0
         3     3       5    8    0    9
 14      1     4       4    7    4    0
         2     4       5    7    0    4
         3     7       2    7    4    0
 15      1     3       4    6    6    0
         2     3       4    7    0    5
         3    10       3    5    0    3
 16      1     1       8    4    9    0
         2     7       5    3    8    0
         3    10       3    2    8    0
 17      1     1       4    9    0    9
         2     1       6    8    0    2
         3    10       3    1    3    0
 18      1     0       0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2
   20   23  111   87
************************************************************************
