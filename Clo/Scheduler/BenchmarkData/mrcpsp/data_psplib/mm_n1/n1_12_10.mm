************************************************************************
file with basedata            : cn112_.bas
initial value random generator: 591537828
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  128
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  1   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       16        1       16
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          2           5   6
   3        3          2           5   6
   4        3          3           8  11  12
   5        3          2           7  12
   6        3          3           7   8  12
   7        3          3           9  11  16
   8        3          2          10  17
   9        3          2          14  17
  10        3          2          13  16
  11        3          3          13  14  17
  12        3          1          14
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
  2      1     2       0    2    9
         2     5       0    2    7
         3     6       0    1    7
  3      1     2       0    8    7
         2     6       0    4    6
         3    10       5    0    4
  4      1     4       0    4    7
         2     9       0    4    0
         3    10       4    0    7
  5      1     1       6    0    0
         2     6       4    0    7
         3     6       0    5    0
  6      1     2       8    0    0
         2     6       0    6    6
         3     7       0    3    2
  7      1     1       9    0    0
         2     3       8    0    0
         3     7       0    8    0
  8      1     4       8    0    2
         2     9       0    1    0
         3    10       7    0    0
  9      1     3       0    6    0
         2     4       8    0    0
         3    10       5    0    0
 10      1     3       0    9    6
         2     8       0    9    0
         3     9       7    0    0
 11      1     4       4    0    5
         2     4       0    8    8
         3     7       4    0    0
 12      1     1       0    6    0
         2     3       0    4    5
         3     5       0    2    0
 13      1     1       8    0    8
         2     3       8    0    7
         3     7       7    0    0
 14      1     1       3    0    6
         2     1       0    8    7
         3     7       4    0    0
 15      1     4       5    0    0
         2     4       0    6    0
         3     8       0    4    0
 16      1     1       8    0    6
         2     4       4    0    5
         3    10       0    4    0
 17      1     6       0    4    6
         2     8       8    0    4
         3     9       7    0    0
 18      1     0       0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1
   20   23   48
************************************************************************
