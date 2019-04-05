************************************************************************
file with basedata            : cm115_.bas
initial value random generator: 1093593989
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  84
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       27        6       27
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        1          3           5   8  12
   3        1          3          12  13  15
   4        1          3           6   7  11
   5        1          2          13  14
   6        1          2           8  17
   7        1          3           8   9  10
   8        1          1          14
   9        1          3          12  13  15
  10        1          2          14  17
  11        1          1          15
  12        1          1          16
  13        1          2          16  17
  14        1          1          16
  15        1          1          18
  16        1          1          18
  17        1          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0
  2      1     8       8    4    7    0
  3      1     6       7    1    0    4
  4      1     3       8    6    6    0
  5      1     3       9    7    0    6
  6      1     5       6    3    7    0
  7      1     2       9    5    8    0
  8      1     2       6    1    6    0
  9      1     1       4    3    0    5
 10      1     8       6    7    0    9
 11      1     8       4   10    0    9
 12      1     5       2    8    0    7
 13      1     3       8    9    0    5
 14      1     7       7    8    5    0
 15      1     9       9   10    0    9
 16      1     7       2    5    0    8
 17      1     7       6    3    2    0
 18      1     0       0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2
   29   28   41   62
************************************************************************
