************************************************************************
file with basedata            : cm158_.bas
initial value random generator: 424022981
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  78
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       38        2       38
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        1          3           6  11  13
   3        1          3           6   7   9
   4        1          3           5  14  16
   5        1          2          10  17
   6        1          2          10  17
   7        1          1           8
   8        1          3          10  12  13
   9        1          3          13  15  16
  10        1          1          15
  11        1          2          12  16
  12        1          2          14  15
  13        1          1          14
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
  2      1    10       0    4    7    4
  3      1     1       0    2    9    8
  4      1     5       0    4    5    6
  5      1     4       9    0    6    9
  6      1     1       8    0    3    5
  7      1     9       0    7    3    5
  8      1     9       0    8    4    8
  9      1     8       0    5    7    8
 10      1     2       0    5   10    7
 11      1     1       2    0    6    8
 12      1     8       8    0    2    3
 13      1     2       8    0    7    2
 14      1     9       0    6    1   10
 15      1     6       0    6    3    5
 16      1     1       0    8    5    3
 17      1     2       0    8    2    8
 18      1     0       0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2
   13   14   80   99
************************************************************************
