************************************************************************
file with basedata            : cm152_.bas
initial value random generator: 2080654272
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
    1     16      0       28        9       28
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        1          3           6   7  15
   3        1          2           6  12
   4        1          3           5   8  17
   5        1          3          10  11  13
   6        1          3          10  11  14
   7        1          3           9  11  12
   8        1          3          10  14  15
   9        1          1          17
  10        1          1          16
  11        1          1          16
  12        1          2          14  17
  13        1          1          15
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
  2      1     3       8    0    4    2
  3      1    10       7    0    5    1
  4      1     5       0    7    7    7
  5      1     5       2    0    2    2
  6      1     2       3    0    7    6
  7      1     1       4    0    5    6
  8      1     1       0    3    7    1
  9      1     9       0    6    6    4
 10      1     6       3    0    3    8
 11      1     2       0    3    6    8
 12      1     5       9    0    9    4
 13      1     9       0    4    8    3
 14      1     4       9    0    8    1
 15      1     3       5    0    6    8
 16      1     9       0    2    8    5
 17      1    10       0    2    7    7
 18      1     0       0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2
   15   13   98   73
************************************************************************
