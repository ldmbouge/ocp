************************************************************************
file with basedata            : cm258_.bas
initial value random generator: 837015666
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  124
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       37       15       37
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        2          2           8   9
   3        2          1           5
   4        2          2           6   7
   5        2          2           6   7
   6        2          3           9  10  13
   7        2          3           8  13  16
   8        2          2          10  17
   9        2          3          11  12  14
  10        2          1          14
  11        2          3          15  16  17
  12        2          2          15  16
  13        2          2          14  17
  14        2          1          15
  15        2          1          18
  16        2          1          18
  17        2          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0
  2      1     2       3    0    9    4
         2     6       2    0    8    1
  3      1     6       2    0    8    8
         2     9       0    4    6    7
  4      1     1       0    4    7    7
         2     2       3    0    3    7
  5      1     5       2    0    8    8
         2     7       0    1    5    5
  6      1    10       7    0    4    8
         2    10       0    6    5   10
  7      1     4       0    9    2    9
         2    10       0    7    2    9
  8      1     3       8    0    3    9
         2     8       5    0    3    5
  9      1     5       0    4    7    6
         2     8       2    0    6    4
 10      1     3       9    0    9   10
         2     9       8    0    8    9
 11      1     4       9    0    5    7
         2     9       5    0    4    1
 12      1     3       0    5    1    6
         2     7       5    0    1    4
 13      1     2       1    0    5    8
         2     4       0    8    3    3
 14      1     8       9    0    4    9
         2    10       0    4    2    3
 15      1     3      10    0    3   10
         2     5       7    0    1   10
 16      1     4       6    0    5   10
         2    10       6    0    4    3
 17      1     1       0    7    7    6
         2    10       0    3    5    6
 18      1     0       0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2
   16   11   88  127
************************************************************************
