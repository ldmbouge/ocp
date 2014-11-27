************************************************************************
file with basedata            : cm154_.bas
initial value random generator: 695663071
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  88
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       39       14       39
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        1          3           6   9  12
   3        1          3           8  10  15
   4        1          2           5   6
   5        1          3           7   9  12
   6        1          3           8  10  13
   7        1          2           8  15
   8        1          1          11
   9        1          2          14  16
  10        1          2          11  14
  11        1          2          16  17
  12        1          1          13
  13        1          2          15  16
  14        1          1          17
  15        1          1          18
  16        1          1          18
  17        1          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0
  2      1     8       9    9    7    7
  3      1     5       2    2   10    5
  4      1     6      10    4    2    7
  5      1     6      10    4    3    8
  6      1     3       4    6    3    8
  7      1     9       7    6    6    3
  8      1     3       2    5    2    8
  9      1     2       8    7    8    3
 10      1     3       6    8    5    8
 11      1     7       3    4    4    6
 12      1     5       7   10   10    7
 13      1     3       3    9    2    4
 14      1    10      10    5    2    2
 15      1     4       8   10    3    5
 16      1     8       3   10    6    3
 17      1     6       8    7   10    7
 18      1     0       0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2
   19   21   83   91
************************************************************************
