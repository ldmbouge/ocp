************************************************************************
file with basedata            : cn127_.bas
initial value random generator: 22655593
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  131
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  1   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       27       10       27
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          3           6   7   8
   3        3          3           5   7  11
   4        3          3           9  10  16
   5        3          3           8  12  15
   6        3          1          11
   7        3          3           9  10  14
   8        3          2          14  17
   9        3          2          12  15
  10        3          1          17
  11        3          3          12  13  15
  12        3          1          17
  13        3          1          14
  14        3          1          16
  15        3          1          18
  16        3          1          18
  17        3          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  N 1
------------------------------------------------------------------------
  1      1     0       0    0    0
  2      1     8       0    2    1
         2     9       8    0    0
         3     9       0    1    0
  3      1     7       2    0    0
         2     7       0    9    0
         3    10       0    7    5
  4      1     3       8    0    3
         2    10       0    4    2
         3    10       8    0    0
  5      1     1       0    8    0
         2     4       4    0    5
         3     6       0    7    4
  6      1     6       6    0    0
         2     7       5    0    0
         3    10       3    0    0
  7      1     2       0    6    9
         2     8       4    0    0
         3     9       0    6    0
  8      1     3       0    6    8
         2     6       0    5    8
         3     8       0    4    7
  9      1     1       5    0    0
         2     2       0    1    0
         3    10       4    0    0
 10      1     3       0    6    8
         2     4       1    0    7
         3     5       0    6    6
 11      1     2       4    0    0
         2     7       0    2    6
         3     8       0    1    0
 12      1     1       6    0    8
         2     2       0    7    0
         3     7       0    2    0
 13      1     5       0    7    0
         2     5       8    0    0
         3     8       0    5    0
 14      1     4       0    6    4
         2     5       0    3    3
         3     9       8    0    3
 15      1     3       5    0    8
         2     4       0    5    5
         3     8       4    0    0
 16      1     2       0    5    0
         2     5       2    0    7
         3     8       2    0    3
 17      1     1       0    4    4
         2     2       8    0    4
         3     6       0    2    0
 18      1     0       0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1
   16   15   76
************************************************************************
