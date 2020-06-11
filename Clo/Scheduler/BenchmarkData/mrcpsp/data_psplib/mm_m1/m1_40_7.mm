************************************************************************
file with basedata            : cm140_.bas
initial value random generator: 267901801
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  97
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       39       10       39
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        1          3           8  10  13
   3        1          2           5   8
   4        1          3           5   7  10
   5        1          3           6  14  16
   6        1          2           9  11
   7        1          3           8  11  12
   8        1          3           9  14  17
   9        1          1          15
  10        1          1          16
  11        1          1          13
  12        1          3          15  16  17
  13        1          1          17
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
  2      1     3       5    9    9    6
  3      1     3       4   10    3    5
  4      1     6       1    4    9    3
  5      1     7       1    2    3    4
  6      1     8       7    4    5    8
  7      1    10       3    5    4    5
  8      1     9       4    3    5    4
  9      1     6       7    2    8    3
 10      1     7       4    8    8    2
 11      1     6       6    7    6    8
 12      1     8       5    4    8    4
 13      1     1       4    6    7    3
 14      1     6       4    7    3    5
 15      1     8       5    9    5    7
 16      1     4      10    4   10    2
 17      1     5       4    4    7    4
 18      1     0       0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2
   27   23  100   73
************************************************************************
