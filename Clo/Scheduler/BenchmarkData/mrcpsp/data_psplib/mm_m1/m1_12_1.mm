************************************************************************
file with basedata            : cm112_.bas
initial value random generator: 27987
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  83
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       33        2       33
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        1          3           7   9  10
   3        1          3           8  10  11
   4        1          3           5   6  10
   5        1          2          12  13
   6        1          3           9  13  16
   7        1          2           8  11
   8        1          2          16  17
   9        1          1          15
  10        1          1          17
  11        1          2          12  13
  12        1          2          14  16
  13        1          1          15
  14        1          2          15  17
  15        1          1          18
  16        1          1          18
  17        1          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0
  2      1     4       0    4    0    6
  3      1     3      10    0    0    5
  4      1    10       0    2    0    5
  5      1     6       3    0    4    0
  6      1     8       0    9    0    4
  7      1     5       9    0    0    3
  8      1     8       2    0    9    0
  9      1     8       3    0    0    3
 10      1     2       0    8    7    0
 11      1     2       0    3    8    0
 12      1     3       3    0    7    0
 13      1     3       4    0   10    0
 14      1     7       0    4    0    1
 15      1     4       4    0    0    5
 16      1     3       7    0    0    9
 17      1     7       0    4    6    0
 18      1     0       0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2
   14   20   51   41
************************************************************************
