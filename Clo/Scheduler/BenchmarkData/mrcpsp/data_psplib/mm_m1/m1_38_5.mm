************************************************************************
file with basedata            : cm138_.bas
initial value random generator: 183556058
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  85
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       35        5       35
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        1          3           5  11  12
   3        1          2           6  10
   4        1          3           7   8   9
   5        1          1          17
   6        1          2          14  16
   7        1          2          10  13
   8        1          3          11  13  14
   9        1          2          12  16
  10        1          3          11  12  16
  11        1          2          15  17
  12        1          1          14
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
  2      1     4       7    8    8    4
  3      1     5       2   10    5    7
  4      1     8       4    8    9   10
  5      1     4      10    2    9    3
  6      1     5      10    8    7    5
  7      1     8       8   10    5    9
  8      1     7       8    5    6    5
  9      1     9       7    5    5    2
 10      1     2       3    3    6    4
 11      1     3       9    7    2    9
 12      1    10       9    2    8    6
 13      1     5       3    3    7    2
 14      1     6       1    3    3    4
 15      1     1      10    4    3    2
 16      1     7       9    4    7    4
 17      1     1       6    7    8    7
 18      1     0       0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2
   22   19   98   83
************************************************************************
