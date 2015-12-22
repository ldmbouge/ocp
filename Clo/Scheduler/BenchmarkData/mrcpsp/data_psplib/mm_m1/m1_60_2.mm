************************************************************************
file with basedata            : cm160_.bas
initial value random generator: 746435051
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  92
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       40        3       40
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        1          3           5   6   7
   3        1          3           7   8  11
   4        1          3           7   9  13
   5        1          3           9  13  14
   6        1          1           9
   7        1          2          14  16
   8        1          2          10  12
   9        1          1          17
  10        1          1          15
  11        1          3          15  16  17
  12        1          3          13  14  17
  13        1          1          16
  14        1          1          15
  15        1          1          18
  16        1          1          18
  17        1          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0
  2      1     6       0    5    4    8
  3      1     5       0    3    1    6
  4      1     2       0    8    3    7
  5      1     1       0    2    4    8
  6      1     9       5    0    3    7
  7      1     1       6    0    6    4
  8      1    10       0    5    1    8
  9      1     6       0    5    8    8
 10      1     4       7    0    4    6
 11      1    10       0    3    5    4
 12      1    10       9    0    6    9
 13      1     2       3    0    5    8
 14      1     7       0    3    5    4
 15      1     8       1    0    8    8
 16      1     4       0    5    8    3
 17      1     7       0    3    8    6
 18      1     0       0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2
   16   16   79  104
************************************************************************
