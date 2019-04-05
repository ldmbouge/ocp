************************************************************************
file with basedata            : md212_.bas
initial value random generator: 2018848709
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  126
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       23        3       23
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          3           6   8  11
   3        3          3          11  16  17
   4        3          2           5   7
   5        3          2           8  15
   6        3          3           7   9  12
   7        3          3          13  14  15
   8        3          2           9  10
   9        3          1          13
  10        3          2          12  14
  11        3          1          15
  12        3          1          13
  13        3          2          16  17
  14        3          2          16  17
  15        3          1          18
  16        3          1          18
  17        3          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0
  2      1     3       0    9    2    0
         2     3       3    0    0    8
         3    10       3    0    0    4
  3      1     2       5    0    5    0
         2     3       5    0    2    0
         3     8       4    0    0    7
  4      1     3       0    8    0    6
         2     5       0    6    1    0
         3     6       0    6    0    1
  5      1     6       0    2   10    0
         2     8       0    1    0    8
         3    10       0    1    6    0
  6      1     2       7    0    9    0
         2     4       4    0    8    0
         3     6       3    0    7    0
  7      1     4       5    0    0    4
         2     6       0    7    8    0
         3     9       1    0    0    4
  8      1     3       1    0    0    6
         2     5       1    0    0    3
         3     5       0    6    0    3
  9      1     1       4    0    0    3
         2     1       4    0    2    0
         3     7       3    0    0    5
 10      1     3       0    5    9    0
         2     8       0    5    0    6
         3     9       0    5    6    0
 11      1     6       0    6    0    8
         2     9       0    5    0    2
         3    10       0    4    9    0
 12      1     4       6    0    0    5
         2     4       5    0    8    0
         3     9       3    0    0    6
 13      1     1       7    0    0    3
         2     5       0    7    0    3
         3     7       4    0    0    1
 14      1     3       6    0    0    2
         2     6       0    8    3    0
         3     7       0    2    0    2
 15      1     5       4    0    5    0
         2     6       0    3    4    0
         3     8       0    2    4    0
 16      1     1       0    5    0    4
         2     4       0    5    7    0
         3     8       0    3    6    0
 17      1     3       0    5    0    7
         2     5       1    0    0    7
         3     7       0    5    9    0
 18      1     0       0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2
   12   17   68   61
************************************************************************
