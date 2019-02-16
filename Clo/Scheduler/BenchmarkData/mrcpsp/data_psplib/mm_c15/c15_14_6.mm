************************************************************************
file with basedata            : c1514_.bas
initial value random generator: 1991760874
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  138
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       27       14       27
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          1          14
   3        3          3           8   9  10
   4        3          3           5  12  14
   5        3          1           6
   6        3          2           7  11
   7        3          2          13  16
   8        3          1          12
   9        3          1          15
  10        3          1          11
  11        3          1          13
  12        3          2          15  17
  13        3          2          15  17
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
  2      1     4       2    6    0   10
         2     8       2    4    7    0
         3    10       1    3    4    0
  3      1     1       8    6    0    9
         2     1       6    6    5    0
         3     2       2    3    0    7
  4      1     1       3    9    9    0
         2     1       3    8    0    9
         3     9       3    6    9    0
  5      1     4       9    9    6    0
         2     5       8    8    5    0
         3     9       5    8    5    0
  6      1     4       4    3    4    0
         2     6       2    3    4    0
         3    10       1    2    4    0
  7      1     3       4   10   10    0
         2     6       4    7    0    6
         3     9       3    5    0    5
  8      1     1       9   10    0    3
         2     4       8    8    4    0
         3     7       8    8    0    1
  9      1     2       6    4    8    0
         2     7       5    4    7    0
         3    10       2    4    6    0
 10      1     2       5    3    0    5
         2     7       4    2    2    0
         3     9       3    1    2    0
 11      1     4      10    6    0    7
         2     8       8    6    0    7
         3     9       7    5    6    0
 12      1     7       9    9    6    0
         2     8       7    7    5    0
         3     8       7    7    0    6
 13      1     6       6    7    0    7
         2     9       6    6    2    0
         3     9       6    7    0    4
 14      1     1      10    3    0    7
         2     1       9    3    4    0
         3     9       6    3    2    0
 15      1     8       2    1    8    0
         2     9       1    1    7    0
         3    10       1    1    0    9
 16      1     4       3    2    0    7
         2     8       3    2    0    6
         3     9       2    1    5    0
 17      1     1       6    6    8    0
         2     6       5    5    0    6
         3     9       4    3    0    4
 18      1     0       0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2
   20   20   55   46
************************************************************************
