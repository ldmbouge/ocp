************************************************************************
file with basedata            : cm461_.bas
initial value random generator: 585029701
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  143
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       19       11       19
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        4          3           5   7  15
   3        4          3           6   8  12
   4        4          3           8  15  17
   5        4          1          11
   6        4          3           9  10  15
   7        4          3           8   9  12
   8        4          1          16
   9        4          2          11  13
  10        4          2          11  13
  11        4          2          14  16
  12        4          2          13  16
  13        4          1          14
  14        4          1          17
  15        4          1          18
  16        4          1          18
  17        4          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0
  2      1     2      10    8    4    4
         2     4       9    8    4    4
         3     5       9    7    4    4
         4     8       8    7    3    3
  3      1     4       7    7    7    4
         2     5       6    7    7    4
         3     8       5    3    5    4
         4    10       5    3    4    3
  4      1     3       2    6    9    9
         2     6       1    6    7    8
         3     6       2    6    6    8
         4     9       1    5    3    8
  5      1     2       5    7    6    9
         2     3       4    5    6    8
         3     4       4    5    6    7
         4    10       3    2    5    6
  6      1     3       6    1    7    6
         2     4       4    1    5    5
         3     9       4    1    4    3
         4    10       2    1    3    2
  7      1     2      10    8    9    4
         2     3       8    7    8    4
         3     5       6    5    4    4
         4     9       5    5    2    2
  8      1     3       1    9    9    5
         2     4       1    6    9    4
         3     4       1    8    9    3
         4     5       1    6    9    3
  9      1     2       3    6    5    4
         2     4       3    6    4    4
         3     9       3    4    4    4
         4    10       2    4    4    4
 10      1     2       9    6    8    6
         2     4       9    5    7    5
         3     8       8    4    4    3
         4    10       8    2    2    1
 11      1     5       4    4    9    3
         2     6       4    3    8    3
         3     7       3    3    8    2
         4     9       2    2    7    1
 12      1     2       6    2    8    1
         2     5       5    2    7    1
         3     9       4    1    6    1
         4    10       1    1    4    1
 13      1     2       6    8    5    8
         2     2       7    9    7    7
         3     4       4    6    3    6
         4     8       2    4    2    6
 14      1     4      10    5    7    8
         2     5       8    5    6    7
         3     8       5    5    5    6
         4    10       4    5    4    5
 15      1     2       7    6    5    7
         2     4       6    5    4    7
         3     8       5    3    4    6
         4     9       3    2    3    5
 16      1     1       6    5    9    8
         2     2       3    5    7    8
         3     7       2    4    7    6
         4     7       2    4    6    7
 17      1     1       5    8    8    7
         2     6       3    7    5    5
         3     6       2    7    6    7
         4     9       2    7    5    5
 18      1     0       0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2
   12   12  117   93
************************************************************************
