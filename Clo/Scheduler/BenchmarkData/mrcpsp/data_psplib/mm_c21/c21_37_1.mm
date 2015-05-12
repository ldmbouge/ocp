************************************************************************
file with basedata            : c2137_.bas
initial value random generator: 23862
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  133
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       27        4       27
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          3          10  15  17
   3        3          3           6   7   8
   4        3          3           5   7   8
   5        3          3           9  12  14
   6        3          3          10  11  12
   7        3          2           9  14
   8        3          3           9  11  12
   9        3          3          10  13  17
  10        3          1          16
  11        3          2          13  14
  12        3          2          13  16
  13        3          1          15
  14        3          3          15  16  17
  15        3          1          18
  16        3          1          18
  17        3          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0
  2      1     1       5    8    8   10
         2     4       4    8    7    9
         3     7       1    8    5    9
  3      1     4       8    3    5    9
         2     5       6    3    5    9
         3    10       5    2    4    6
  4      1     7       6    9    6    6
         2     8       6    5    3    6
         3    10       6    4    2    6
  5      1     1       4    6   10    5
         2     8       4    5    8    5
         3    10       3    3    3    4
  6      1     1       8    9    4    7
         2     3       7    8    4    6
         3     6       5    5    3    5
  7      1     6       7    5    9    9
         2     9       2    5    7    4
         3     9       5    4    6    6
  8      1     6       7    6    5    7
         2     6       7    9    6    6
         3     7       7    5    2    2
  9      1     1       9    9   10    2
         2     4       9    9    7    1
         3     5       8    8    3    1
 10      1     7       3    8    7    9
         2     8       3    5    7    9
         3     9       2    2    6    9
 11      1     5       8    4   10    4
         2     6       6    4   10    1
         3     6       7    3    9    1
 12      1     5       6    4    8    6
         2     7       5    4    7    4
         3     9       3    3    6    3
 13      1     7       7    2    4    7
         2     8       6    2    3    6
         3     9       6    2    3    3
 14      1     2       4    7    4    4
         2     3       4    6    3    4
         3     9       3    5    3    1
 15      1     2       8    8    7    6
         2     9       6    6    6    6
         3    10       5    3    6    6
 16      1     3      10    7    5    3
         2     3      10    6    5    4
         3     8       7    5    4    2
 17      1     1       8    7    5   10
         2     6       6    6    5    8
         3     9       4    2    5    4
 18      1     0       0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2
   12   11   80   76
************************************************************************
