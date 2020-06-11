************************************************************************
file with basedata            : c2155_.bas
initial value random generator: 1204531108
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  117
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       20       15       20
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          3           5   7  11
   3        3          3           6  10  11
   4        3          3           8  12  13
   5        3          3           6   8  12
   6        3          3           9  13  16
   7        3          3           9  10  12
   8        3          2           9  10
   9        3          2          14  15
  10        3          3          15  16  17
  11        3          3          13  14  16
  12        3          2          14  15
  13        3          1          17
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
  2      1     4       6    6    2    6
         2     6       6    5    1    5
         3     6       4    6    1    5
  3      1     1      10    7   10    4
         2     2      10    6   10    4
         3     6       9    4    9    4
  4      1     3       8    9    6    4
         2     8       7    5    5    3
         3     8       8    5    3    3
  5      1     2       9    6    9    7
         2     4       7    4    7    6
         3     5       4    4    7    6
  6      1     2       3    6    7   10
         2     4       3    5    6   10
         3    10       1    5    6   10
  7      1     3       7    6    5    3
         2     3       7    7    4    4
         3     7       6    5    1    1
  8      1     3       7    8    4   10
         2     3       6    4    6    9
         3     3       6    9    4    7
  9      1     1       6    9    9    4
         2     2       6    9    8    4
         3     8       5    8    8    3
 10      1     6       6    8    6    7
         2     9       3    8    4    7
         3    10       3    7    3    4
 11      1     2       4    4    5   10
         2     7       3    3    3   10
         3     8       3    3    3    9
 12      1     5       6    8    5    6
         2     9       5    7    5    4
         3    10       3    4    5    3
 13      1     1       4    6   10    8
         2     3       3    5   10    8
         3    10       3    3    9    7
 14      1     5       4    7    4    3
         2     5       4    6    6    3
         3     7       4    6    1    2
 15      1     5       4   10    4    8
         2     6       3    7    4    8
         3     7       3    5    3    7
 16      1     2       9    9    7    5
         2     4       8    8    4    5
         3     7       8    7    4    4
 17      1     2       2   10    9    1
         2     3       1    8    9    1
         3     5       1    6    8    1
 18      1     0       0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2
   20   22   98   92
************************************************************************
