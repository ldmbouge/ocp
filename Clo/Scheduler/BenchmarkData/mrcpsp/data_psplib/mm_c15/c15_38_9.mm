************************************************************************
file with basedata            : c1538_.bas
initial value random generator: 669943871
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
    1     16      0       25        7       25
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          1          14
   3        3          1           6
   4        3          3           5   7  15
   5        3          3           6  10  16
   6        3          1          12
   7        3          3           8   9  11
   8        3          1          17
   9        3          3          10  13  16
  10        3          1          12
  11        3          1          13
  12        3          1          14
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
  2      1     4      10    5    6   10
         2     7       9    4    6    7
         3    10       7    4    5    7
  3      1     6       7    9    3   10
         2     7       4    9    2    8
         3    10       4    9    1    6
  4      1     4       7    4    8    8
         2     7       7    4    8    6
         3    10       7    2    7    3
  5      1     4       7    5    5    9
         2     5       6    5    4    9
         3     9       5    4    4    9
  6      1     2       6    4    4    2
         2    10       4    1    3    2
         3    10       4    3    2    2
  7      1     2       7    8    9    9
         2     5       3    5    6    8
         3    10       2    5    3    8
  8      1     1       8    6    5    4
         2     2       7    5    4    4
         3     6       6    5    2    3
  9      1     1       9    5    8    8
         2     1       8    4    8    9
         3     2       7    4    1    7
 10      1     2       5    6    9    7
         2     3       5    4    9    7
         3     4       4    3    9    6
 11      1     4       4    9    3    2
         2     8       3    7    2    2
         3    10       1    5    2    2
 12      1     5      10    7    4    2
         2     5       9    7    4    3
         3     8       8    7    2    2
 13      1     6      10    7    7    3
         2     8       6    6    7    3
         3    10       4    2    6    2
 14      1     4       8    8    7    9
         2     5       8    7    7    8
         3     9       8    6    7    8
 15      1     1       9    7    5    3
         2     2       7    7    5    3
         3     6       4    6    5    3
 16      1     6       9    7   10    3
         2     6      10    5   10    3
         3     9       7    5    9    3
 17      1     5       4    5    9    5
         2     9       3    4    8    3
         3    10       2    2    7    2
 18      1     0       0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2
   19   19   80   79
************************************************************************
