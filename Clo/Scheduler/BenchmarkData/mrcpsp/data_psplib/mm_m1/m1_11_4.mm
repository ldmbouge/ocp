************************************************************************
file with basedata            : cm111_.bas
initial value random generator: 284428386
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  72
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       29        3       29
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        1          2           6  14
   3        1          3           5   6   8
   4        1          3           6   7  10
   5        1          2          11  13
   6        1          2           9  11
   7        1          3          15  16  17
   8        1          2          10  12
   9        1          2          13  15
  10        1          2          13  14
  11        1          1          17
  12        1          1          14
  13        1          2          16  17
  14        1          2          15  16
  15        1          1          18
  16        1          1          18
  17        1          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0
  2      1     8       3    0    0    5
  3      1     8       7    0    0    4
  4      1     4       0    5    3    0
  5      1     6       8    0    4    0
  6      1     1       0    1    0    4
  7      1     7       0    6    7    0
  8      1     8       7    0    0    6
  9      1     2       2    0    9    0
 10      1     5       0    8    0    1
 11      1     8       7    0    0    4
 12      1     1       0    7    9    0
 13      1     1       8    0    0    8
 14      1     3       0    1    2    0
 15      1     1      10    0    4    0
 16      1     2       8    0    9    0
 17      1     7       0    9    0    5
 18      1     0       0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2
   16   14   47   37
************************************************************************
