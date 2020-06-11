************************************************************************
file with basedata            : cn116_.bas
initial value random generator: 1843263447
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  118
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  1   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       14       12       14
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          2           5   6
   3        3          3           8   9  13
   4        3          1          11
   5        3          3           7  10  13
   6        3          3           7  13  14
   7        3          2           8  17
   8        3          1          16
   9        3          3          11  12  16
  10        3          3          11  14  16
  11        3          1          15
  12        3          1          14
  13        3          2          15  17
  14        3          2          15  17
  15        3          1          18
  16        3          1          18
  17        3          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  N 1
------------------------------------------------------------------------
  1      1     0       0    0    0
  2      1     1       9    6    0
         2     3       9    5    0
         3     6       8    2    0
  3      1     3       4    3    9
         2     5       4    3    0
         3     7       3    3    6
  4      1     2       7    7    9
         2     3       3    3    8
         3     3       4    2    0
  5      1     1       7   10    0
         2     2       6    7    0
         3     4       6    6    0
  6      1     4      10    8    4
         2     5       7    4    0
         3     9       5    3    0
  7      1     2      10    7    0
         2     5       9    6    4
         3     6       8    2    2
  8      1     2       8    9    0
         2     8       6    8    0
         3    10       5    7    0
  9      1     1       8    7    7
         2     4       7    7    6
         3     7       5    3    6
 10      1     5       6    8    3
         2     6       6    6    2
         3     9       6    4    2
 11      1     2      10    8    7
         2     3      10    6    6
         3     9      10    5    0
 12      1     4       6    5    0
         2     5       6    4    0
         3     9       6    3    0
 13      1     1       1    9    9
         2     3       1    7    6
         3    10       1    4    5
 14      1     2       8    6    3
         2     5       7    4    0
         3    10       2    1    3
 15      1     1       7    5    6
         2     2       7    3    0
         3     4       6    3    0
 16      1     1       6   10    0
         2     4       6    5    0
         3     9       6    4    5
 17      1     4       6    7    8
         2     6       4    5    4
         3     6       4    6    0
 18      1     0       0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1
   28   29   44
************************************************************************
