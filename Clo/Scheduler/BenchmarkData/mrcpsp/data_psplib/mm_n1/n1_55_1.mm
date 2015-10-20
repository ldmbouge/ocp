************************************************************************
file with basedata            : cn155_.bas
initial value random generator: 11276
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  136
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  1   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       25        3       25
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          3           6   8  16
   3        3          2           5   8
   4        3          2           7   9
   5        3          3           9  12  13
   6        3          2          14  17
   7        3          3          10  13  17
   8        3          3          13  14  17
   9        3          2          11  14
  10        3          2          11  12
  11        3          1          16
  12        3          2          15  16
  13        3          1          15
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
  2      1     6       4    9    6
         2     8       4    7    5
         3     9       4    4    5
  3      1     9       6    6    9
         2    10       6    1    9
         3    10       6    3    8
  4      1     9       5    5    6
         2     9       5    6    5
         3     9       8    2    7
  5      1     1       8   10   10
         2     6       7    9   10
         3     8       5    7    9
  6      1     4       8    9    7
         2     7       6    8    6
         3     7       5    9    5
  7      1     6       7   10    9
         2     7       6    7    8
         3     9       6    6    7
  8      1     3       1    6    3
         2     5       1    4    3
         3     6       1    2    2
  9      1     2       7    9    4
         2     3       7    7    3
         3     7       7    7    2
 10      1     3       9   10    2
         2     6       7    9    2
         3     7       3    9    2
 11      1     6       7    4   10
         2     7       6    4    9
         3     9       6    3    9
 12      1     1       2    9    8
         2    10       2    9    1
         3    10       2    7    5
 13      1     2       9    4    9
         2     9       7    4    8
         3    10       3    2    7
 14      1     6       5    8    6
         2    10       4    8    4
         3    10       3    8    5
 15      1     1       6    5    9
         2     9       6    4    8
         3    10       5    2    8
 16      1     1       6    8    9
         2     4       5    6    6
         3     5       5    6    5
 17      1     2       5    6    8
         2     6       4    3    7
         3    10       2    2    5
 18      1     0       0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1
   23   29  108
************************************************************************
