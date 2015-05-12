************************************************************************
file with basedata            : cm144_.bas
initial value random generator: 1478673052
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  89
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       32       14       32
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        1          3           6   9  12
   3        1          3           6   7  14
   4        1          3           5   8   9
   5        1          3          10  11  14
   6        1          1           8
   7        1          2          10  11
   8        1          2          10  13
   9        1          3          14  15  17
  10        1          1          15
  11        1          2          12  13
  12        1          2          15  17
  13        1          1          16
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
  2      1     8      10    0    6    3
  3      1     2       7    0    1    1
  4      1     2      10    0    3    9
  5      1     2       6    0    5   10
  6      1     6       0    6    7   10
  7      1     5       0    8    5    3
  8      1     4       6    0    2    8
  9      1     7       5    0    6    7
 10      1     4       0    4    5    6
 11      1     8       0    3   10    8
 12      1     8       1    0    3    8
 13      1     4       0    5    4    2
 14      1     6       3    0    9    3
 15      1     4       6    0    9    7
 16      1    10       0    8    6    7
 17      1     9       0    8    3    5
 18      1     0       0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2
   27   16   84   97
************************************************************************
