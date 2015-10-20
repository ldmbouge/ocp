************************************************************************
file with basedata            : cn157_.bas
initial value random generator: 616984622
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  131
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  1   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       27        1       27
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          3           5  10  13
   3        3          2           6   8
   4        3          3           5   6  16
   5        3          3           9  11  15
   6        3          2           7  11
   7        3          2           9  13
   8        3          2          13  16
   9        3          1          12
  10        3          3          15  16  17
  11        3          2          12  14
  12        3          1          17
  13        3          2          14  15
  14        3          1          17
  15        3          1          18
  16        3          1          18
  17        3          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  N 1
------------------------------------------------------------------------
  1      1     0       0    0    0
  2      1     1       3    0    8
         2     2       2    0    6
         3     8       0    5    6
  3      1     6       6    0    5
         2    10       0    5    5
         3    10       2    0    4
  4      1     1       0    9    4
         2     6       7    0    2
         3     6       0    8    2
  5      1     2       5    0    9
         2     4       0    9    9
         3     7       0    5    8
  6      1     1       8    0    6
         2     7       8    0    4
         3    10       7    0    3
  7      1     8       0    7    8
         2     9       0    7    7
         3    10       0    5    5
  8      1     1       2    0    5
         2     1       0    2    4
         3     5       0    1    3
  9      1     7       6    0    8
         2     8       0    3    7
         3    10       0    3    5
 10      1     5       8    0    8
         2     7       4    0    5
         3    10       0    8    1
 11      1     1       9    0    7
         2     1       8    0    9
         3     6       4    0    7
 12      1     2       7    0    7
         2     4       0    4    6
         3     8       6    0    3
 13      1     1       0    6    8
         2     5       0    6    5
         3    10       0    1    4
 14      1     2       0   10    3
         2     7       8    0    2
         3     7       7    0    3
 15      1     3       4    0    6
         2     6       0    2    4
         3     8       3    0    2
 16      1     3       3    0    8
         2     6       0    8    7
         3     7       3    0    5
 17      1     3       0    4    9
         2     6       8    0    7
         3     9       0    4    3
 18      1     0       0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1
   11   10  111
************************************************************************
